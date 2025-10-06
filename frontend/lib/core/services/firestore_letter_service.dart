import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';
import 'user_context_service.dart';

class FirestoreLetterService {
  static FirebaseFirestore? _firestore;
  static final UserContextService _userContext = UserContextService();
  
  // Initialize Firebase
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _firestore = FirebaseFirestore.instance;
      print('✅ Firebase initialized successfully');
    } catch (e) {
      print('❌ Firebase initialization error: $e');
    }
  }
  
  static FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw Exception('Firestore not initialized. Call initialize() first.');
    }
    return _firestore!;
  }
  
  // Get letters for current user
  static Future<List<LetterModel>> getLetters({String? userId}) async {
    try {
      final String? currentUserId = userId ?? _userContext.currentUserId;
      
      if (currentUserId == null && !_userContext.isAdmin) {
        print('⚠️ No user ID found and user is not admin');
        return [];
      }

      Query query = firestore.collection('letters');
      
      // If user is not admin, filter by recipient_id to show only letters for this user
      if (!_userContext.isAdmin && currentUserId != null) {
        query = query.where('recipient_id', isEqualTo: currentUserId);
      }
      
      final QuerySnapshot snapshot = await query
          .orderBy('created_at', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return LetterModel.fromFirestore(doc.id, data);
      }).toList();
    } catch (e) {
      print('Error getting letters from Firestore: $e');
      return [];
    }
  }

  // Get all letters (admin only)
  static Future<List<LetterModel>> getAllLetters() async {
    try {
      if (!_userContext.isAdmin) {
        print('⚠️ Access denied: Only admins can view all letters');
        return [];
      }

      final QuerySnapshot snapshot = await firestore
          .collection('letters')
          .orderBy('created_at', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return LetterModel.fromFirestore(doc.id, data);
      }).toList();
    } catch (e) {
      print('Error getting all letters from Firestore: $e');
      return [];
    }
  }
  
  // Get letters by status for current user
  static Future<List<LetterModel>> getLettersByStatus(String status, {String? userId}) async {
    try {
      final String? currentUserId = userId ?? _userContext.currentUserId;
      
      if (currentUserId == null && !_userContext.isAdmin) {
        print('⚠️ No user ID found and user is not admin');
        return [];
      }

      Query query = firestore.collection('letters');
      
      // Apply status filter
      query = query.where('status', isEqualTo: status);
      
      // If user is not admin, filter by recipient_id
      if (!_userContext.isAdmin && currentUserId != null) {
        query = query.where('recipient_id', isEqualTo: currentUserId);
      }
      
      final QuerySnapshot snapshot = await query
          .orderBy('created_at', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return LetterModel.fromFirestore(doc.id, data);
      }).toList();
    } catch (e) {
      print('Error getting letters by status from Firestore: $e');
      return [];
    }
  }
  
  // Get letters by type for current user
  static Future<List<LetterModel>> getLettersByType(String letterType, {String? userId}) async {
    try {
      final String? currentUserId = userId ?? _userContext.currentUserId;
      
      if (currentUserId == null && !_userContext.isAdmin) {
        print('⚠️ No user ID found and user is not admin');
        return [];
      }

      Query query = firestore.collection('letters');
      
      // Apply type filter
      query = query.where('letter_type', isEqualTo: letterType);
      
      // If user is not admin, filter by recipient_id
      if (!_userContext.isAdmin && currentUserId != null) {
        query = query.where('recipient_id', isEqualTo: currentUserId);
      }
      
      final QuerySnapshot snapshot = await query
          .orderBy('created_at', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return LetterModel.fromFirestore(doc.id, data);
      }).toList();
    } catch (e) {
      print('Error getting letters by type from Firestore: $e');
      return [];
    }
  }
  
  // Add new letter (automatically sets current user as recipient unless specified)
  static Future<bool> addLetter(LetterModel letter, {String? recipientId}) async {
    try {
      final String? currentUserId = _userContext.currentUserId;
      
      if (currentUserId == null) {
        print('⚠️ Cannot create letter: No user logged in');
        return false;
      }

      // Create updated letter with proper user context
      final updatedLetter = LetterModel(
        id: letter.id,
        letterNumber: letter.letterNumber,
        letterType: letter.letterType,
        subject: letter.subject,
        content: letter.content,
        recipientId: recipientId ?? currentUserId, // Use current user as recipient unless specified
        recipientName: letter.recipientName.isNotEmpty ? letter.recipientName : _userContext.currentUserName ?? '',
        recipientEmployeeId: letter.recipientEmployeeId.isNotEmpty ? letter.recipientEmployeeId : _userContext.currentUserEmployeeId ?? '',
        recipientDepartment: letter.recipientDepartment,
        senderId: _userContext.isAdmin ? (letter.senderId.isNotEmpty ? letter.senderId : currentUserId) : currentUserId,
        senderName: letter.senderName.isNotEmpty ? letter.senderName : _userContext.currentUserName ?? '',
        senderPosition: letter.senderPosition.isNotEmpty ? letter.senderPosition : '',
        status: letter.status,
        priority: letter.priority,
        createdAt: letter.createdAt,
        updatedAt: letter.updatedAt,
        expiresAt: letter.expiresAt,
        approvalHistory: letter.approvalHistory,
        additionalInfo: letter.additionalInfo,
      );

      await firestore.collection('letters').add(updatedLetter.toFirestore());
      print('✅ Letter added successfully for user: ${updatedLetter.recipientId}');
      return true;
    } catch (e) {
      print('❌ Error adding letter: $e');
      return false;
    }
  }
  
  // Update letter status (with user permission check)
  static Future<bool> updateLetterStatus(String letterId, String status, String notes) async {
    try {
      final String? currentUserId = _userContext.currentUserId;
      
      if (currentUserId == null) {
        print('⚠️ Cannot update letter: No user logged in');
        return false;
      }

      // Check if letter exists and user has permission to update it
      final letterDoc = await firestore.collection('letters').doc(letterId).get();
      
      if (!letterDoc.exists) {
        print('⚠️ Letter not found');
        return false;
      }

      final letterData = letterDoc.data() as Map<String, dynamic>;
      final recipientId = letterData['recipient_id'] as String?;

      // Only admin or the letter recipient can update status
      if (!_userContext.isAdmin && recipientId != currentUserId) {
        print('⚠️ Permission denied: User can only update their own letters');
        return false;
      }

      await firestore.collection('letters').doc(letterId).update({
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
        'approval_history': FieldValue.arrayUnion([
          {
            'action': status,
            'timestamp': FieldValue.serverTimestamp(),
            'user_id': currentUserId,
            'user_name': _userContext.currentUserName ?? 'Unknown User',
            'notes': notes,
          }
        ]),
      });
      print('✅ Letter status updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating letter status: $e');
      return false;
    }
  }
  
  // Get letter statistics for current user
  static Future<LetterStatisticsModel> getStatistics({String? userId}) async {
    try {
      final String? currentUserId = userId ?? _userContext.currentUserId;
      
      if (currentUserId == null && !_userContext.isAdmin) {
        print('⚠️ No user ID found and user is not admin');
        return LetterStatisticsModel(
          totalLetters: 0,
          pendingLetters: 0,
          approvedLetters: 0,
          rejectedLetters: 0,
          lettersByType: {},
        );
      }

      Query query = firestore.collection('letters');
      
      // If user is not admin, filter by recipient_id
      if (!_userContext.isAdmin && currentUserId != null) {
        query = query.where('recipient_id', isEqualTo: currentUserId);
      }
      
      final QuerySnapshot allLetters = await query.get();
      
      int total = allLetters.size;
      int pending = 0;
      int approved = 0;
      int rejected = 0;
      Map<String, int> typeCount = {};
      
      for (var doc in allLetters.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] as String;
        final letterType = data['letter_type'] as String;
        
        switch (status) {
          case 'waiting_approval':
            pending++;
            break;
          case 'approved':
            approved++;
            break;
          case 'rejected':
            rejected++;
            break;
        }
        
        typeCount[letterType] = (typeCount[letterType] ?? 0) + 1;
      }
      
      return LetterStatisticsModel(
        totalLetters: total,
        pendingLetters: pending,
        approvedLetters: approved,
        rejectedLetters: rejected,
        lettersByType: typeCount,
      );
    } catch (e) {
      print('❌ Error getting letter statistics: $e');
      return LetterStatisticsModel(
        totalLetters: 0,
        pendingLetters: 0,
        approvedLetters: 0,
        rejectedLetters: 0,
        lettersByType: {},
      );
    }
  }

  // Initialize user context (call this after user login)
  static void initializeUserContext(String userId, String userName, String role) {
    print('🔐 Initializing letter service for user: $userName ($userId) - Role: $role');
  }

  // Check if current user can view letter
  static bool canViewLetter(LetterModel letter) {
    final String? currentUserId = _userContext.currentUserId;
    
    if (currentUserId == null) return false;
    if (_userContext.isAdmin) return true;
    
    return letter.recipientId == currentUserId || letter.senderId == currentUserId;
  }

  // Check if current user can edit letter
  static bool canEditLetter(LetterModel letter) {
    final String? currentUserId = _userContext.currentUserId;
    
    if (currentUserId == null) return false;
    if (_userContext.isAdmin) return true;
    
    // Users can only edit their own letters and only if status is waiting_approval
    return letter.recipientId == currentUserId && letter.status == 'waiting_approval';
  }
}

// Letter Model for Firestore
class LetterModel {
  final String id;
  final String letterNumber;
  final String letterType;
  final String subject;
  final String content;
  final String recipientId;
  final String recipientName;
  final String recipientEmployeeId;
  final String recipientDepartment;
  final String senderId;
  final String senderName;
  final String senderPosition;
  final String status;
  final String priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expiresAt;
  final List<ApprovalHistoryModel> approvalHistory;
  final Map<String, dynamic>? additionalInfo;
  
  LetterModel({
    required this.id,
    required this.letterNumber,
    required this.letterType,
    required this.subject,
    required this.content,
    required this.recipientId,
    required this.recipientName,
    required this.recipientEmployeeId,
    required this.recipientDepartment,
    required this.senderId,
    required this.senderName,
    required this.senderPosition,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
    this.expiresAt,
    required this.approvalHistory,
    this.additionalInfo,
  });
  
  factory LetterModel.fromFirestore(String id, Map<String, dynamic> data) {
    return LetterModel(
      id: id,
      letterNumber: data['letter_number'] ?? '',
      letterType: data['letter_type'] ?? '',
      subject: data['subject'] ?? '',
      content: data['content'] ?? '',
      recipientId: data['recipient_id'] ?? '',
      recipientName: data['recipient_name'] ?? '',
      recipientEmployeeId: data['recipient_employee_id'] ?? '',
      recipientDepartment: data['recipient_department'] ?? '',
      senderId: data['sender_id'] ?? '',
      senderName: data['sender_name'] ?? '',
      senderPosition: data['sender_position'] ?? '',
      status: data['status'] ?? 'waiting_approval',
      priority: data['priority'] ?? 'medium',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expires_at'] as Timestamp?)?.toDate(),
      approvalHistory: (data['approval_history'] as List?)
          ?.map((item) => ApprovalHistoryModel.fromMap(item))
          .toList() ?? [],
      additionalInfo: data['medical_info'] ?? data['vacation_info'] ?? data['wfh_info'],
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'letter_number': letterNumber,
      'letter_type': letterType,
      'subject': subject,
      'content': content,
      'recipient_id': recipientId,
      'recipient_name': recipientName,
      'recipient_employee_id': recipientEmployeeId,
      'recipient_department': recipientDepartment,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_position': senderPosition,
      'status': status,
      'priority': priority,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      if (expiresAt != null) 'expires_at': Timestamp.fromDate(expiresAt!),
      'approval_history': approvalHistory.map((h) => h.toMap()).toList(),
      if (additionalInfo != null) ...additionalInfo!,
    };
  }
}

class ApprovalHistoryModel {
  final String action;
  final DateTime timestamp;
  final String userId;
  final String userName;
  final String notes;
  
  ApprovalHistoryModel({
    required this.action,
    required this.timestamp,
    required this.userId,
    required this.userName,
    required this.notes,
  });
  
  factory ApprovalHistoryModel.fromMap(Map<String, dynamic> map) {
    return ApprovalHistoryModel(
      action: map['action'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: map['user_id'] ?? '',
      userName: map['user_name'] ?? '',
      notes: map['notes'] ?? '',
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'action': action,
      'timestamp': Timestamp.fromDate(timestamp),
      'user_id': userId,
      'user_name': userName,
      'notes': notes,
    };
  }
}

class LetterStatisticsModel {
  final int totalLetters;
  final int pendingLetters;
  final int approvedLetters;
  final int rejectedLetters;
  final Map<String, int> lettersByType;
  
  LetterStatisticsModel({
    required this.totalLetters,
    required this.pendingLetters,
    required this.approvedLetters,
    required this.rejectedLetters,
    required this.lettersByType,
  });
}