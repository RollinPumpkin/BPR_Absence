import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/data/constants/api_constants.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/models/attendance.dart';
import 'package:frontend/data/models/api_response.dart';

void main() {
  group('API Integration Tests', () {
    test('API Constants should be properly configured', () {
      expect(ApiConstants.baseUrl, isNotEmpty);
      expect(ApiConstants.auth.login, equals('/auth/login'));
      expect(ApiConstants.attendance.checkIn, equals('/attendance/checkin'));
      expect(ApiConstants.letters.send, equals('/letters/send'));
    });

    test('User model should serialize and deserialize correctly', () {
      final json = {
        'id': '1',
        'full_name': 'John Doe',
        'email': 'john@example.com',
        'employee_id': 'EMP001',
        'department': 'IT',
        'position': 'Developer',
        'role': 'employee',
        'is_active': true,
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-01T00:00:00.000Z',
      };

      final user = User.fromJson(json);
      
      expect(user.id, equals('1'));
      expect(user.fullName, equals('John Doe'));
      expect(user.email, equals('john@example.com'));
      expect(user.employeeId, equals('EMP001'));
      expect(user.department, equals('IT'));
      expect(user.position, equals('Developer'));
      expect(user.role, equals('employee'));
      expect(user.isActive, isTrue);
    });

    test('Attendance model should serialize and deserialize correctly', () {
      final json = {
        'id': '1',
        'user_id': 'user1',
        'check_in_time': '2024-01-01T09:00:00.000Z',
        'check_out_time': '2024-01-01T17:00:00.000Z',
        'check_in_location': 'Jakarta Office',
        'check_out_location': 'Jakarta Office',
        'status': 'completed',
        'working_hours': 8.0,
        'notes': 'On time',
        'created_at': '2024-01-01T09:00:00.000Z',
        'updated_at': '2024-01-01T17:00:00.000Z',
      };

      final attendance = Attendance.fromJson(json);
      
      expect(attendance.id, equals('1'));
      expect(attendance.userId, equals('user1'));
      expect(attendance.status, equals('completed'));
      expect(attendance.workingHours, equals(8.0));
      expect(attendance.notes, equals('On time'));
      expect(attendance.checkInLocation, equals('Jakarta Office'));
      expect(attendance.checkOutLocation, equals('Jakarta Office'));
    });

    test('ApiResponse model should handle success response', () {
      final response = ApiResponse<Map<String, dynamic>>(
        success: true,
        message: 'Success',
        data: {'id': '1', 'name': 'Test'},
      );

      expect(response.success, isTrue);
      expect(response.message, equals('Success'));
      expect(response.data, isNotNull);
      expect(response.data!['id'], equals('1'));
      expect(response.data!['name'], equals('Test'));
    });

    test('ApiResponse model should handle error response', () {
      final response = ApiResponse<String>(
        success: false,
        message: 'Error occurred',
      );

      expect(response.success, isFalse);
      expect(response.message, equals('Error occurred'));
      expect(response.data, isNull);
    });

    test('LoginResponse should work correctly', () {
      final json = {
        'token': 'jwt-token-here',
        'user': {
          'id': '1',
          'full_name': 'John Doe',
          'email': 'john@example.com',
          'employee_id': 'EMP001',
          'department': 'IT',
          'position': 'Developer',
          'role': 'employee',
          'is_active': true,
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-01T00:00:00.000Z',
        }
      };

      final loginResponse = LoginResponse.fromJson(json);
      
      expect(loginResponse.token, equals('jwt-token-here'));
      expect(loginResponse.user.fullName, equals('John Doe'));
      expect(loginResponse.user.email, equals('john@example.com'));
    });

    test('User helper methods should work correctly', () {
      final user = User(
        id: '1',
        fullName: 'John Doe',
        email: 'john@example.com',
        employeeId: 'EMP001',
        department: 'IT',
        position: 'Senior Developer',
        role: 'admin',
        status: 'active',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(user.isAdmin, isTrue);
      expect(user.isEmployee, isFalse);
      expect(user.isHR, isFalse);
      expect(user.isManager, isFalse);
      expect(user.displayRole, equals('Administrator'));
      expect(user.initials, equals('JD'));
    });

    test('Attendance statistics should calculate correctly', () {
      final json = {
        'total_days': 22,
        'present_days': 20,
        'absent_days': 2,
        'late_days': 3,
        'attendance_rate': 90.9,
        'punctuality_rate': 85.0,
        'average_working_hours': 8,
        'monthly_stats': {'January': 22, 'February': 20},
      };

      final stats = AttendanceStatistics.fromJson(json);
      
      expect(stats.totalDays, equals(22));
      expect(stats.presentDays, equals(20));
      expect(stats.absentDays, equals(2));
      expect(stats.lateDays, equals(3));
      expect(stats.averageWorkingHours, equals(8));
      expect(stats.attendanceRate, equals(90.9));
      expect(stats.punctualityRate, equals(85.0));
    });
  });
}