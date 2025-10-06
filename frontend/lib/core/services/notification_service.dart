import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static const String _notificationEnabledKey = 'notification_enabled';
  
  // Request notification permission on app startup
  static Future<bool> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      
      // Save permission status to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final isGranted = status == PermissionStatus.granted;
      await prefs.setBool(_notificationEnabledKey, isGranted);
      
      return isGranted;
    } catch (e) {
      print('Error requesting notification permission: $e');
      return false;
    }
  }
  
  // Check current notification permission status
  static Future<bool> checkNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      return status == PermissionStatus.granted;
    } catch (e) {
      print('Error checking notification permission: $e');
      return false;
    }
  }
  
  // Get notification setting from SharedPreferences with employee_id
  static Future<bool> getNotificationSetting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final employeeId = prefs.getString('employee_id') ?? '';
      
      // Use employee-specific key if available, otherwise fallback to general key
      String key = employeeId.isNotEmpty 
          ? '${_notificationEnabledKey}_$employeeId'
          : _notificationEnabledKey;
      
      return prefs.getBool(key) ?? false;
    } catch (e) {
      print('Error getting notification setting: $e');
      return false;
    }
  }
  
  // Update notification setting in SharedPreferences with employee_id
  static Future<void> setNotificationSetting(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final employeeId = prefs.getString('employee_id') ?? '';
      
      // Use employee-specific key if available, otherwise fallback to general key
      String key = employeeId.isNotEmpty 
          ? '${_notificationEnabledKey}_$employeeId'
          : _notificationEnabledKey;
      
      await prefs.setBool(key, enabled);
      
      // Also save to general key for backward compatibility
      await prefs.setBool(_notificationEnabledKey, enabled);
      
      print('💾 Notification setting saved for employee: $employeeId, enabled: $enabled');
      
      // If user enables notifications, check if permission is granted
      if (enabled) {
        final hasPermission = await checkNotificationPermission();
        if (!hasPermission) {
          // Request permission if not granted
          await requestNotificationPermission();
        }
      }
    } catch (e) {
      print('Error setting notification setting: $e');
    }
  }
  
  // Show permission dialog if not already requested
  static Future<bool> showPermissionDialog(BuildContext context) async {
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Enable Notifications',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: const Text(
            'Stay updated with important announcements, task reminders, and attendance notifications.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Not Now',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5FB5),
                foregroundColor: Colors.white,
              ),
              child: const Text('Allow Notifications'),
            ),
          ],
        );
      },
    );
    
    if (result == true) {
      return await requestNotificationPermission();
    }
    
    // Save that user declined for now
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationEnabledKey, false);
    return false;
  }
  
  // Check if permission was already requested today
  static Future<bool> shouldShowPermissionDialog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastRequestDate = prefs.getString('last_notification_request_date');
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      // Show dialog if not requested today or if notification is not enabled
      final notificationEnabled = prefs.getBool(_notificationEnabledKey) ?? false;
      
      return lastRequestDate != today && !notificationEnabled;
    } catch (e) {
      print('Error checking if should show permission dialog: $e');
      return true;
    }
  }
  
  // Mark that permission was requested today
  static Future<void> markPermissionRequested() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      await prefs.setString('last_notification_request_date', today);
    } catch (e) {
      print('Error marking permission requested: $e');
    }
  }
}