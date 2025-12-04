import 'package:flutter/material.dart';
import 'lib/data/services/assignment_service.dart';
import 'lib/data/services/letter_service.dart';
import 'lib/data/services/attendance_service.dart';
import 'lib/data/services/user_service.dart';
import 'lib/data/services/employee_service.dart';
import 'lib/data/services/api_service.dart';

/// Script untuk test fetch data dari database ke frontend
/// 
/// Cara menjalankan:
/// flutter run test_data_fetch.dart
/// 
/// ATAU dari terminal:
/// dart run test_data_fetch.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('========================================');
  print('🚀 STARTING DATA FETCH TEST');
  print('========================================\n');
  
  // Initialize API Service
  await ApiService.initialize();
  print('✅ API Service initialized\n');
  
  // Test Results
  final results = <String, bool>{};
  
  // 1. TEST ASSIGNMENTS
  print('📋 TEST 1: Fetching Assignments...');
  results['assignments'] = await testAssignments();
  print('');
  
  // 2. TEST LETTERS
  print('✉️ TEST 2: Fetching Letters...');
  results['letters'] = await testLetters();
  print('');
  
  // 3. TEST ATTENDANCE
  print('📅 TEST 3: Fetching Attendance Records...');
  results['attendance'] = await testAttendance();
  print('');
  
  // 4. TEST USERS
  print('👥 TEST 4: Fetching Users...');
  results['users'] = await testUsers();
  print('');
  
  // 5. TEST EMPLOYEES
  print('👔 TEST 5: Fetching Employees...');
  results['employees'] = await testEmployees();
  print('');
  
  // SUMMARY
  print('========================================');
  print('📊 TEST SUMMARY');
  print('========================================');
  
  int passed = 0;
  int failed = 0;
  
  results.forEach((key, value) {
    final status = value ? '✅ PASSED' : '❌ FAILED';
    print('$status - $key');
    if (value) {
      passed++;
    } else {
      failed++;
    }
  });
  
  print('');
  print('Total Tests: ${results.length}');
  print('Passed: $passed');
  print('Failed: $failed');
  print('Success Rate: ${(passed / results.length * 100).toStringAsFixed(1)}%');
  print('========================================\n');
  
  if (failed == 0) {
    print('🎉 ALL TESTS PASSED! Data fetch working perfectly!');
  } else {
    print('⚠️ SOME TESTS FAILED! Please check the errors above.');
  }
}

Future<bool> testAssignments() async {
  try {
    final assignmentService = AssignmentService();
    
    // Test 1: Get All Assignments
    print('  → Testing getAllAssignments()...');
    final allAssignments = await assignmentService.getAllAssignments(
      page: 1,
      limit: 10,
      forceRefresh: true,
    );
    
    print('    ✓ Fetched ${allAssignments.length} assignments');
    
    if (allAssignments.isNotEmpty) {
      final first = allAssignments.first;
      print('    ✓ Sample assignment:');
      print('      - ID: ${first.id}');
      print('      - Title: ${first.title}');
      print('      - Status: ${first.status}');
      print('      - Priority: ${first.priority}');
      print('      - Due Date: ${first.dueDate}');
      
      // Validate assignment data structure
      if (first.id.isEmpty || first.title.isEmpty) {
        print('    ✗ Assignment data incomplete!');
        return false;
      }
    }
    
    // Test 2: Get Upcoming Assignments
    print('  → Testing getUpcomingAssignments()...');
    final upcomingAssignments = await assignmentService.getUpcomingAssignments(
      forceRefresh: true,
    );
    
    print('    ✓ Fetched ${upcomingAssignments.length} upcoming assignments');
    
    print('  ✅ Assignments fetch: SUCCESS');
    return true;
    
  } catch (e) {
    print('  ❌ Assignments fetch: FAILED');
    print('  Error: $e');
    return false;
  }
}

Future<bool> testLetters() async {
  try {
    final letterService = LetterService();
    
    // Test: Get Sent Letters
    print('  → Testing getSentLetters()...');
    final sentLetters = await letterService.getSentLetters(
      page: 1,
      limit: 10,
    );
    
    if (sentLetters.success) {
      final data = sentLetters.data;
      if (data != null && data.items.isNotEmpty) {
        print('    ✓ Fetched ${data.items.length} sent letters');
        
        final first = data.items.first;
        print('    ✓ Sample letter:');
        print('      - ID: ${first.id}');
        print('      - Subject: ${first.subject}');
        print('      - Status: ${first.status}');
        print('      - Type: ${first.letterType}');
        
        // Validate letter data structure
        if (first.id.isEmpty || first.subject.isEmpty) {
          print('    ✗ Letter data incomplete!');
          return false;
        }
      } else {
        print('    ℹ No sent letters found (OK)');
      }
    } else {
      print('    ✗ API response unsuccessful');
      return false;
    }
    
    // Test: Get Received Letters
    print('  → Testing getReceivedLetters()...');
    final receivedLetters = await letterService.getReceivedLetters(
      page: 1,
      limit: 10,
    );
    
    if (receivedLetters.success) {
      final data = receivedLetters.data;
      if (data != null) {
        print('    ✓ Fetched ${data.items.length} received letters');
      }
    }
    
    print('  ✅ Letters fetch: SUCCESS');
    return true;
    
  } catch (e) {
    print('  ❌ Letters fetch: FAILED');
    print('  Error: $e');
    return false;
  }
}

Future<bool> testAttendance() async {
  try {
    final attendanceService = AttendanceService();
    
    // Test: Get Attendance Records
    print('  → Testing getAttendanceRecords()...');
    
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = DateTime(now.year, now.month + 1, 0);
    
    final attendanceRecords = await attendanceService.getAttendanceRecords(
      page: 1,
      limit: 10,
      startDate: startDate.toIso8601String(),
      endDate: endDate.toIso8601String(),
    );
    
    if (attendanceRecords.success) {
      final data = attendanceRecords.data;
      if (data != null && data.items.isNotEmpty) {
        print('    ✓ Fetched ${data.items.length} attendance records');
        
        final first = data.items.first;
        print('    ✓ Sample attendance:');
        print('      - ID: ${first.id}');
        print('      - Date: ${first.date}');
        print('      - Status: ${first.status}');
        print('      - Check In: ${first.checkIn}');
        print('      - Check Out: ${first.checkOut ?? "Not checked out"}');
        
        // Validate attendance data structure
        if (first.id.isEmpty) {
          print('    ✗ Attendance data incomplete!');
          return false;
        }
      } else {
        print('    ℹ No attendance records found (OK)');
      }
    } else {
      print('    ✗ API response unsuccessful');
      print('    Message: ${attendanceRecords.message}');
      return false;
    }
    
    print('  ✅ Attendance fetch: SUCCESS');
    return true;
    
  } catch (e) {
    print('  ❌ Attendance fetch: FAILED');
    print('  Error: $e');
    return false;
  }
}

Future<bool> testUsers() async {
  try {
    final userService = UserService();
    
    // Test: Get All Users
    print('  → Testing getAllUsers()...');
    final usersResponse = await userService.getAllUsers(
      page: 1,
      limit: 10,
    );
    
    if (usersResponse.success) {
      final data = usersResponse.data;
      if (data != null && data.items.isNotEmpty) {
        print('    ✓ Fetched ${data.items.length} users');
        
        final first = data.items.first;
        print('    ✓ Sample user:');
        print('      - ID: ${first.id}');
        print('      - Name: ${first.fullName}');
        print('      - Email: ${first.email}');
        print('      - Role: ${first.role}');
        print('      - Department: ${first.department ?? "Not set"}');
        
        // Validate user data structure
        if (first.id.isEmpty || first.fullName.isEmpty || first.email.isEmpty) {
          print('    ✗ User data incomplete!');
          return false;
        }
      } else {
        print('    ℹ No users found (OK)');
      }
    } else {
      print('    ✗ API response unsuccessful');
      print('    Message: ${usersResponse.message}');
      return false;
    }
    
    print('  ✅ Users fetch: SUCCESS');
    return true;
    
  } catch (e) {
    print('  ❌ Users fetch: FAILED');
    print('  Error: $e');
    return false;
  }
}

Future<bool> testEmployees() async {
  try {
    // Test: Get All Employees
    print('  → Testing getAllEmployees()...');
    final employeesResponse = await EmployeeService.getAllEmployees();
    
    if (employeesResponse.success) {
      final data = employeesResponse.data;
      if (data != null) {
        // Try to get users list from data
        final usersList = data['users'];
        if (usersList != null && usersList is List && usersList.isNotEmpty) {
          print('    ✓ Fetched ${usersList.length} employees');
          
          final first = usersList.first;
          print('    ✓ Sample employee:');
          print('      - ID: ${first['id'] ?? first['user_id']}');
          print('      - Name: ${first['full_name'] ?? first['name']}');
          print('      - Email: ${first['email']}');
          print('      - Department: ${first['department'] ?? "Not set"}');
          
          // Validate employee data structure
          if (first['email'] == null || first['email'].toString().isEmpty) {
            print('    ✗ Employee data incomplete!');
            return false;
          }
        } else {
          print('    ℹ No employees found (OK)');
        }
      } else {
        print('    ℹ No employee data (OK)');
      }
    } else {
      print('    ✗ API response unsuccessful');
      print('    Message: ${employeesResponse.message}');
      return false;
    }
    
    print('  ✅ Employees fetch: SUCCESS');
    return true;
    
  } catch (e) {
    print('  ❌ Employees fetch: FAILED');
    print('  Error: $e');
    return false;
  }
}
