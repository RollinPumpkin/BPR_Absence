import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// User Notification Service
/// Manages assignments and clock-in reminders for regular users
class UserNotificationService {
  static final UserNotificationService _instance = UserNotificationService._internal();
  factory UserNotificationService() => _instance;
  UserNotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  
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
  bool _isInitialized = false;

  /// Initialize notification service and Android notifications
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getString('user_id');
      
      print('🔔 UserNotificationService initialized');
      print('👤 User ID: $_currentUserId');
      
      // Initialize timezone
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
      
      // Initialize Android notifications
      await _initializeAndroidNotifications();
      
      _isInitialized = true;
      
      // Start listening to notifications
      if (_currentUserId != null) {
        startNotificationsListener();
        // Schedule daily clock-in reminder
        await scheduleDailyClockInReminder();
      }
    } catch (e) {
      print('❌ Error initializing UserNotificationService: $e');
    }
  }

  /// Initialize Android local notifications
  Future<void> _initializeAndroidNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permission for Android 13+
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    
    print('✅ Android notifications initialized');
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('🔔 Notification tapped: ${response.payload}');
    // You can navigate to specific page based on payload
  }

  /// Show Android notification
  Future<void> _showAndroidNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) return;

    const androidDetails = AndroidNotificationDetails(
      'bpr_absence_channel',
      'BPR Absence Notifications',
      channelDescription: 'Notifications for assignments and reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Create assignment notification
  Future<bool> createAssignmentNotification({
    required String assignmentId,
    required String assignmentTitle,
    required String assignedBy,
    required DateTime deadline,
  }) async {
    try {
      await _firestore.collection('user_notifications').add({
        'type': 'assignment',
        'title': 'New Assignment',
        'message': assignmentTitle,
        'data': {
          'assignment_id': assignmentId,
          'assigned_by': assignedBy,
          'deadline': deadline,
        },
        'is_read': false,
        'user_id': _currentUserId,
        'created_at': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
      
      // Show Android notification
      await _showAndroidNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'New Assignment',
        body: assignmentTitle,
        payload: 'assignment:$assignmentId',
      );
      
      print('✅ Assignment notification created');
      return true;
    } catch (e) {
      print('❌ Error creating assignment notification: $e');
      return false;
    }
  }

  /// Schedule daily clock-in reminder (7:30 AM)
  Future<void> scheduleDailyClockInReminder() async {
    try {
      // Cancel existing reminder
      await _flutterLocalNotificationsPlugin.cancel(999);

      final now = DateTime.now();
      var scheduledTime = DateTime(now.year, now.month, now.day, 7, 30);
      
      // If it's past 7:30 AM today, schedule for tomorrow
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        999, // Fixed ID for clock-in reminder
        'Clock In Reminder',
        'Don\'t forget to clock in today!',
        tz.TZDateTime.from(scheduledTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'clock_in_reminder',
            'Clock In Reminders',
            channelDescription: 'Daily reminders to clock in',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      );

      print('✅ Daily clock-in reminder scheduled for 7:30 AM');
    } catch (e) {
      print('❌ Error scheduling clock-in reminder: $e');
    }
  }

  /// Cancel clock-in reminder
  Future<void> cancelClockInReminder() async {
    await _flutterLocalNotificationsPlugin.cancel(999);
    print('🔕 Clock-in reminder cancelled');
  }

  /// Start listening to notifications for current user
  void startNotificationsListener() {
    if (_currentUserId == null) {
      print('⚠️ User notifications listener: No user ID');
      return;
    }

    _notificationsListener?.cancel();

    Query query = _firestore.collection('user_notifications')
        .where('user_id', isEqualTo: _currentUserId)
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
      
      print('🔔 User Notifications updated: ${notifications.length} total, $unreadCount unread');
    }, onError: (error) {
      print('❌ User Notifications listener error: $error');
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
      await _firestore.collection('user_notifications').doc(notificationId).update({
        'is_read': true,
        'read_at': FieldValue.serverTimestamp(),
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
          .collection('user_notifications')
          .where('user_id', isEqualTo: _currentUserId)
          .where('is_read', isEqualTo: false)
          .get();

      for (final doc in unreadNotifications.docs) {
        batch.update(doc.reference, {
          'is_read': true,
          'read_at': FieldValue.serverTimestamp(),
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
      await _firestore.collection('user_notifications').doc(notificationId).delete();
      print('✅ Notification deleted: $notificationId');
      return true;
    } catch (e) {
      print('❌ Error deleting notification: $e');
      return false;
    }
  }

  /// Get unread count (one-time fetch)
  Future<int> getUnreadCount() async {
    try {
      if (_currentUserId == null) return 0;

      final snapshot = await _firestore
          .collection('user_notifications')
          .where('user_id', isEqualTo: _currentUserId)
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
      if (_currentUserId == null) return [];

      final snapshot = await _firestore
          .collection('user_notifications')
          .where('user_id', isEqualTo: _currentUserId)
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
    print('🔔 UserNotificationService disposed');
  }
}
