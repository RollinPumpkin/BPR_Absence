import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized Realtime Service for Firestore Data
/// Manages all realtime listeners across the application
class RealtimeService {
  static final RealtimeService _instance = RealtimeService._internal();
  factory RealtimeService() => _instance;
  RealtimeService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Stream controllers for broadcasting data
  final StreamController<List<Map<String, dynamic>>> _attendanceController = 
      StreamController<List<Map<String, dynamic>>>.broadcast();
  final StreamController<List<Map<String, dynamic>>> _assignmentsController = 
      StreamController<List<Map<String, dynamic>>>.broadcast();
  final StreamController<List<Map<String, dynamic>>> _lettersController = 
      StreamController<List<Map<String, dynamic>>>.broadcast();
  final StreamController<List<Map<String, dynamic>>> _usersController = 
      StreamController<List<Map<String, dynamic>>>.broadcast();
  final StreamController<Map<String, dynamic>> _dashboardStatsController = 
      StreamController<Map<String, dynamic>>.broadcast();

  // Stream subscriptions
  StreamSubscription<QuerySnapshot>? _attendanceListener;
  StreamSubscription<QuerySnapshot>? _assignmentsListener;
  StreamSubscription<QuerySnapshot>? _lettersListener;
  StreamSubscription<QuerySnapshot>? _usersListener;

  // Exposed streams
  Stream<List<Map<String, dynamic>>> get attendanceStream => _attendanceController.stream;
  Stream<List<Map<String, dynamic>>> get assignmentsStream => _assignmentsController.stream;
  Stream<List<Map<String, dynamic>>> get lettersStream => _lettersController.stream;
  Stream<List<Map<String, dynamic>>> get usersStream => _usersController.stream;
  Stream<Map<String, dynamic>> get dashboardStatsStream => _dashboardStatsController.stream;

  // User context
  String? _currentUserId;
  String? _currentEmployeeId;
  String? _currentRole;

  /// Initialize the realtime service with user context
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getString('user_id');
      _currentEmployeeId = prefs.getString('employee_id');
      _currentRole = prefs.getString('role');
      
      print('🔄 RealtimeService initialized');
      print('👤 User ID: $_currentUserId');
      print('🆔 Employee ID: $_currentEmployeeId');
      print('👑 Role: $_currentRole');
    } catch (e) {
      print('❌ Error initializing RealtimeService: $e');
    }
  }

  /// Check if user is admin
  bool get isAdmin => _currentRole == 'admin' || 
                      _currentRole == 'super_admin' || 
                      _currentRole == 'account_officer';

  // ==================== ATTENDANCE LISTENERS ====================

  /// Start listening to attendance data
  void startAttendanceListener({String? date, String? userId}) {
    _attendanceListener?.cancel();

    Query query = _firestore.collection('attendance');

    // Filter by date if provided
    if (date != null) {
      query = query.where('date', isEqualTo: date);
    }

    // Filter by user if not admin
    if (!isAdmin && (userId ?? _currentEmployeeId ?? _currentUserId) != null) {
      final filterUserId = userId ?? _currentEmployeeId ?? _currentUserId;
      query = query.where('employee_id', isEqualTo: filterUserId);
    }

    _attendanceListener = query
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen((snapshot) {
      final data = snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();

      _attendanceController.add(data);
      print('🔄 Attendance updated: ${data.length} records');
    }, onError: (error) {
      print('❌ Attendance listener error: $error');
    });
  }

  /// Stop attendance listener
  void stopAttendanceListener() {
    _attendanceListener?.cancel();
    _attendanceListener = null;
  }

  // ==================== ASSIGNMENTS LISTENERS ====================

  /// Start listening to assignments data
  void startAssignmentsListener({String? status, String? userId}) {
    _assignmentsListener?.cancel();

    Query query = _firestore.collection('assignments');

    // Filter by status if provided
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    // Filter by assigned user if not admin
    if (!isAdmin && (userId ?? _currentEmployeeId ?? _currentUserId) != null) {
      final filterUserId = userId ?? _currentEmployeeId ?? _currentUserId;
      query = query.where('assignedTo', arrayContains: filterUserId);
    }

    _assignmentsListener = query
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen((snapshot) {
      final data = snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();

      _assignmentsController.add(data);
      print('🔄 Assignments updated: ${data.length} records');
    }, onError: (error) {
      print('❌ Assignments listener error: $error');
    });
  }

  /// Stop assignments listener
  void stopAssignmentsListener() {
    _assignmentsListener?.cancel();
    _assignmentsListener = null;
  }

  // ==================== LETTERS LISTENERS ====================

  /// Start listening to letters data
  void startLettersListener({String? status, String? letterType, String? userId}) {
    _lettersListener?.cancel();

    Query query = _firestore.collection('letters');

    // Filter by status if provided
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    // Filter by type if provided
    if (letterType != null) {
      query = query.where('letter_type', isEqualTo: letterType);
    }

    // Filter by recipient if not admin
    if (!isAdmin && (userId ?? _currentEmployeeId ?? _currentUserId) != null) {
      final filterUserId = userId ?? _currentEmployeeId ?? _currentUserId;
      query = query.where('recipient_id', isEqualTo: filterUserId);
    }

    _lettersListener = query
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen((snapshot) {
      final data = snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();

      _lettersController.add(data);
      print('🔄 Letters updated: ${data.length} records');
    }, onError: (error) {
      print('❌ Letters listener error: $error');
    });
  }

  /// Stop letters listener
  void stopLettersListener() {
    _lettersListener?.cancel();
    _lettersListener = null;
  }

  // ==================== USERS LISTENERS (Admin Only) ====================

  /// Start listening to users data (admin only)
  void startUsersListener({String? role, String? division}) {
    if (!isAdmin) {
      print('⚠️ Users listener: Access denied. Admin only.');
      return;
    }

    _usersListener?.cancel();

    Query query = _firestore.collection('users');

    // Filter by role if provided
    if (role != null) {
      query = query.where('role', isEqualTo: role);
    }

    // Filter by division if provided
    if (division != null) {
      query = query.where('division', isEqualTo: division);
    }

    _usersListener = query
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen((snapshot) {
      final data = snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();

      _usersController.add(data);
      print('🔄 Users updated: ${data.length} records');
    }, onError: (error) {
      print('❌ Users listener error: $error');
    });
  }

  /// Stop users listener
  void stopUsersListener() {
    _usersListener?.cancel();
    _usersListener = null;
  }

  // ==================== DASHBOARD STATS LISTENER ====================

  /// Calculate and stream dashboard statistics in realtime
  void startDashboardStatsListener() {
    // Combine all data streams to calculate dashboard stats
    Stream.periodic(const Duration(seconds: 5)).listen((_) async {
      try {
        final stats = await _calculateDashboardStats();
        _dashboardStatsController.add(stats);
      } catch (e) {
        print('❌ Error calculating dashboard stats: $e');
      }
    });
  }

  Future<Map<String, dynamic>> _calculateDashboardStats() async {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // Get today's attendance
    Query attendanceQuery = _firestore.collection('attendance')
        .where('date', isEqualTo: todayStr);
    
    if (!isAdmin && _currentEmployeeId != null) {
      attendanceQuery = attendanceQuery.where('employee_id', isEqualTo: _currentEmployeeId);
    }

    final attendanceSnapshot = await attendanceQuery.get();

    // Get pending assignments
    Query assignmentsQuery = _firestore.collection('assignments')
        .where('status', whereIn: ['pending', 'in-progress']);
    
    if (!isAdmin && _currentEmployeeId != null) {
      assignmentsQuery = assignmentsQuery.where('assignedTo', arrayContains: _currentEmployeeId);
    }

    final assignmentsSnapshot = await assignmentsQuery.get();

    // Get pending letters
    Query lettersQuery = _firestore.collection('letters')
        .where('status', isEqualTo: 'pending');
    
    if (!isAdmin && _currentEmployeeId != null) {
      lettersQuery = lettersQuery.where('recipient_id', isEqualTo: _currentEmployeeId);
    }

    final lettersSnapshot = await lettersQuery.get();

    return {
      'attendance': {
        'today': attendanceSnapshot.size,
      },
      'assignments': {
        'pending': assignmentsSnapshot.size,
      },
      'letters': {
        'pending': lettersSnapshot.size,
      },
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  // ==================== DISPOSAL ====================

  /// Stop all listeners and close controllers
  void dispose() {
    stopAttendanceListener();
    stopAssignmentsListener();
    stopLettersListener();
    stopUsersListener();
    
    _attendanceController.close();
    _assignmentsController.close();
    _lettersController.close();
    _usersController.close();
    _dashboardStatsController.close();
    
    print('🔄 RealtimeService disposed');
  }

  /// Start all listeners at once
  void startAllListeners() {
    startAttendanceListener();
    startAssignmentsListener();
    startLettersListener();
    if (isAdmin) {
      startUsersListener();
    }
    startDashboardStatsListener();
    
    print('🔄 All realtime listeners started');
  }

  /// Stop all listeners
  void stopAllListeners() {
    stopAttendanceListener();
    stopAssignmentsListener();
    stopLettersListener();
    stopUsersListener();
    
    print('🔄 All realtime listeners stopped');
  }
}
