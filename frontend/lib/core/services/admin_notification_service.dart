import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Admin Notification Service
/// Manages account requests and admin notifications
class AdminNotificationService {
  static final AdminNotificationService _instance = AdminNotificationService._internal();
  factory AdminNotificationService() => _instance;
  AdminNotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Stream controllers
  final StreamController<List<Map<String, dynamic>>> _notificationsController = 
      StreamController<List<Map<String, dynamic>>>.broadcast();
  final StreamController<int> _unreadCountController = 
      StreamController<int>.broadcast();

  // Stream subscriptions
  StreamSubscription<QuerySnapshot>? _notificationsListener;
  
  // Exposed streams
  Stream<List<Map<String, dynamic>>> get notificationsStream => 
      _notificationsController.stream;
  Stream<int> get unreadCountStream => _unreadCountController.stream;

  // User context
  String? _currentUserId;
  String? _currentRole;

  /// Initialize notification service
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getString('user_id');
      _currentRole = prefs.getString('role');
      
      print('🔔 AdminNotificationService initialized');
      print('👤 User ID: $_currentUserId');
      print('👑 Role: $_currentRole');
      
      // Start listening if admin/superadmin
      if (isAdmin) {
        startNotificationsListener();
      }
    } catch (e) {
      print('❌ Error initializing AdminNotificationService: $e');
    }
  }

  /// Check if current user is admin
  bool get isAdmin => _currentRole == 'admin' || 
                      _currentRole == 'super_admin' || 
                      _currentRole == 'account_officer';

  /// Create account request notification (from login page)
  Future<bool> createAccountRequest({
    required String fullName,
    required String email,
    required String phone,
    required String division,
    String? additionalNotes,
  }) async {
    try {
      await _firestore.collection('admin_notifications').add({
        'type': 'account_request',
        'title': 'New Account Request',
        'message': '$fullName requested a new account',
        'data': {
          'full_name': fullName,
          'email': email,
          'phone': phone,
          'division': division,
          'additional_notes': additionalNotes,
        },
        'is_read': false,
        'target_roles': ['admin', 'super_admin', 'account_officer'],
        'created_at': FieldValue.serverTimestamp(),
        'created_by': 'system',
        'status': 'pending',
      });
      
      print('✅ Account request notification created');
      return true;
    } catch (e) {
      print('❌ Error creating account request: $e');
      return false;
    }
  }

  /// Start listening to notifications for admin
  void startNotificationsListener() {
    if (!isAdmin) {
      print('⚠️ Admin notifications listener: Access denied. Admin only.');
      return;
    }

    _notificationsListener?.cancel();

    // Query notifications for admin roles
    Query query = _firestore.collection('admin_notifications')
        .where('target_roles', arrayContains: _currentRole)
        .orderBy('created_at', descending: true)
        .limit(50);

    _notificationsListener = query.snapshots().listen((snapshot) {
      final notifications = snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();

      // Calculate unread count
      final unreadCount = notifications.where((n) => n['is_read'] == false).length;

      _notificationsController.add(notifications);
      _unreadCountController.add(unreadCount);
      
      print('🔔 Admin Notifications updated: ${notifications.length} total, $unreadCount unread');
    }, onError: (error) {
      print('❌ Admin Notifications listener error: $error');
    });
  }

  /// Stop notifications listener
  void stopNotificationsListener() {
    _notificationsListener?.cancel();
    _notificationsListener = null;
  }

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('admin_notifications').doc(notificationId).update({
        'is_read': true,
        'read_at': FieldValue.serverTimestamp(),
        'read_by': _currentUserId,
      });
      
      print('✅ Notification marked as read: $notificationId');
      return true;
    } catch (e) {
      print('❌ Error marking notification as read: $e');
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final batch = _firestore.batch();
      
      final unreadNotifications = await _firestore
          .collection('admin_notifications')
          .where('target_roles', arrayContains: _currentRole)
          .where('is_read', isEqualTo: false)
          .get();

      for (final doc in unreadNotifications.docs) {
        batch.update(doc.reference, {
          'is_read': true,
          'read_at': FieldValue.serverTimestamp(),
          'read_by': _currentUserId,
        });
      }

      await batch.commit();
      print('✅ All notifications marked as read');
      return true;
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
      return false;
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('admin_notifications').doc(notificationId).delete();
      print('✅ Notification deleted: $notificationId');
      return true;
    } catch (e) {
      print('❌ Error deleting notification: $e');
      return false;
    }
  }

  /// Update account request status (approve/reject)
  Future<bool> updateAccountRequestStatus({
    required String notificationId,
    required String status, // 'approved', 'rejected'
    String? adminNotes,
  }) async {
    try {
      await _firestore.collection('admin_notifications').doc(notificationId).update({
        'status': status,
        'admin_notes': adminNotes,
        'processed_at': FieldValue.serverTimestamp(),
        'processed_by': _currentUserId,
      });
      
      print('✅ Account request status updated: $status');
      return true;
    } catch (e) {
      print('❌ Error updating account request status: $e');
      return false;
    }
  }

  /// Get unread count (one-time fetch)
  Future<int> getUnreadCount() async {
    try {
      if (!isAdmin) return 0;

      final snapshot = await _firestore
          .collection('admin_notifications')
          .where('target_roles', arrayContains: _currentRole)
          .where('is_read', isEqualTo: false)
          .get();

      return snapshot.size;
    } catch (e) {
      print('❌ Error getting unread count: $e');
      return 0;
    }
  }

  /// Get all notifications (one-time fetch)
  Future<List<Map<String, dynamic>>> getAllNotifications({int limit = 50}) async {
    try {
      if (!isAdmin) return [];

      final snapshot = await _firestore
          .collection('admin_notifications')
          .where('target_roles', arrayContains: _currentRole)
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      print('❌ Error getting notifications: $e');
      return [];
    }
  }

  /// Dispose and cleanup
  void dispose() {
    stopNotificationsListener();
    _notificationsController.close();
    _unreadCountController.close();
    print('🔔 AdminNotificationService disposed');
  }
}
