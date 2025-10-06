import '../models/attendance.dart';
import '../models/activity_summary.dart';
import '../models/user.dart';

class DummyData {
  // User data yang sesuai dengan backend - sekarang sesuai dengan Firestore
  static const Map<String, dynamic> currentUser = {
    'id': 'FBRpLyTyvIpGqGYdNURK',
    'employee_id': 'EMP001',
    'full_name': 'Ahmad Wijaya',
    'email': 'ahmad.wijaya@bpr.com',
    'phone': '+62812345678',
    'department': 'IT Department',
    'position': 'Software Developer',
    'role': 'user',
    'profile_picture': null,
    'address': 'Jl. Sudirman No. 123, Jakarta',
    'date_of_birth': '1990-05-15',
    'join_date': '2023-01-15',
    'status': 'active',
    'firebase_uid': 'KV7SleqWQic0rgH6ED7rblMLltl2',
    'created_at': '2023-01-15T00:00:00Z',
    'updated_at': '2025-10-05T10:30:00Z',
  };

  // Admin user data
  static const Map<String, dynamic> adminUser = {
    'id': 'admin_001',
    'employee_id': 'ADM001',
    'full_name': 'Dr. Sarah Manager',
    'email': 'sarah.manager@bpr.com',
    'phone': '+62811234567',
    'department': 'Management',
    'position': 'General Manager',
    'role': 'admin',
    'profile_picture': null,
    'address': 'Jl. Thamrin No. 456, Jakarta',
    'date_of_birth': '1985-03-20',
    'join_date': '2020-06-01',
    'status': 'active',
    'firebase_uid': 'aNdOoeaEPwMRgSajnUJC1wrsagI2',
    'created_at': '2020-06-01T00:00:00Z',
    'updated_at': '2025-10-05T10:30:00Z',
  };

  // Login credentials untuk testing
  static const List<Map<String, String>> loginCredentials = [
    {
      'email': 'ahmad.wijaya@bpr.com',
      'password': 'password123',
      'name': 'Ahmad Wijaya',
      'role': 'user',
    },
    {
      'email': 'sarah.manager@bpr.com', 
      'password': 'admin123456',
      'name': 'Dr. Sarah Manager',
      'role': 'admin',
    },
    {
      'email': 'siti.rahayu@bpr.com',
      'password': 'password123', 
      'name': 'Siti Rahayu',
      'role': 'user',
    },
    {
      'email': 'budi.santoso@bpr.com',
      'password': 'password123',
      'name': 'Budi Santoso', 
      'role': 'user',
    },
    // New users
    {
      'email': 'user@gmail.com',
      'password': 'user123',
      'name': 'User Test',
      'role': 'employee',
    },
    {
      'email': 'admin@gmail.com',
      'password': 'admin123',
      'name': 'Admin Test',
      'role': 'admin',
    },
  ];

  // Today's attendance data - sesuai dengan data Firestore
  static Map<String, dynamic> todayAttendance = {
    'id': '00L0w8P15DbF0cIdfJ7N',
    'user_id': 'FBRpLyTyvIpGqGYdNURK',
    'date': '2025-10-05',
    'check_in_time': '08:15:30',
    'check_out_time': null,
    'status': 'present',
    'check_in_location': {
      'latitude': -6.2088,
      'longitude': 106.8456,
      'address': 'Kantor Pusat BPR Adiarta Reksacipta'
    },
    'check_out_location': null,
    'total_hours_worked': null,
    'overtime_hours': 0.0,
    'notes': 'Normal check in',
    'qr_code_used': 'BPR_MainOffice_1759584606',
    'photo_check_in': null,
    'photo_check_out': null,
    'approved_by': null,
    'created_at': '2025-10-05T08:15:30Z',
    'updated_at': '2025-10-05T08:15:30Z',
  };

  // This week's attendance data - sesuai dengan Firestore
  static List<Map<String, dynamic>> weeklyAttendance = [
    {
      'id': 'att_20251001_001',
      'user_id': 'FBRpLyTyvIpGqGYdNURK',
      'date': '2025-10-01',
      'check_in_time': '08:00:00',
      'check_out_time': '17:30:00',
      'status': 'present',
      'total_hours_worked': 8.5,
      'overtime_hours': 0.5,
      'notes': 'Completed daily tasks',
      'qr_code_used': 'BPR_MainOffice_1759584606',
    },
    {
      'id': 'att_20251003_001',
      'user_id': 'FBRpLyTyvIpGqGYdNURK',
      'date': '2025-10-03',
      'check_in_time': '08:10:00',
      'check_out_time': '17:00:00',
      'status': 'late',
      'total_hours_worked': 7.83,
      'overtime_hours': 0.0,
      'notes': 'Late due to traffic',
      'qr_code_used': 'BPR_MainOffice_1759584606',
    },
    {
      'id': 'att_20251004_001',
      'user_id': 'FBRpLyTyvIpGqGYdNURK',
      'date': '2025-10-04',
      'check_in_time': '07:55:00',
      'check_out_time': '18:00:00',
      'status': 'present',
      'total_hours_worked': 9.08,
      'overtime_hours': 1.08,
      'notes': 'Working on urgent project',
      'qr_code_used': 'BPR_MainOffice_1759584606',
    },
    {
      'id': '00L0w8P15DbF0cIdfJ7N',
      'user_id': 'FBRpLyTyvIpGqGYdNURK',
      'date': '2025-10-02',
      'check_in_time': '08:00:00',
      'check_out_time': '17:00:00',
      'status': 'present',
      'total_hours_worked': 8.0,
      'overtime_hours': 0.0,
      'notes': '',
      'qr_code_used': 'BPR_MainOffice_1759584606',
    },
    {
      'id': 'att_20251005_001',
      'user_id': 'FBRpLyTyvIpGqGYdNURK',
      'date': '2025-10-05',
      'check_in_time': '08:15:30',
      'check_out_time': null,
      'status': 'present',
      'total_hours_worked': null,
      'overtime_hours': 0.0,
      'notes': 'Normal check in',
      'qr_code_used': 'BPR_MainOffice_1759584606',
    },
  ];

  // Monthly attendance summary
  static Map<String, dynamic> monthlyAttendanceSummary = {
    'total_days_worked': 22,
    'present_days': 20,
    'late_days': 2,
    'total_hours': '176.50',
    'overtime_hours': '8.75',
    'average_hours_per_day': '8.02',
  };

  // Assignment/Task data - sesuai dengan Firestore
  static List<Map<String, dynamic>> assignments = [
    {
      'id': 'assign_001',
      'user_id': 'FBRpLyTyvIpGqGYdNURK',
      'title': 'Update Employee Management System',
      'description': 'Implement new features for employee data management including real-time attendance tracking and reporting dashboard.',
      'status': 'in_progress',
      'priority': 'high',
      'due_date': '2025-10-10',
      'assigned_by': 'admin_001',
      'progress': 65,
      'created_at': '2025-10-01T09:00:00Z',
      'updated_at': '2025-10-05T14:30:00Z',
    },
    {
      'id': 'assign_002',
      'user_id': 'FBRpLyTyvIpGqGYdNURK',
      'title': 'Database Optimization',
      'description': 'Optimize database queries for better performance and implement proper indexing strategies.',
      'status': 'assigned',
      'priority': 'medium',
      'due_date': '2025-10-15',
      'assigned_by': 'admin_001',
      'progress': 0,
      'created_at': '2025-10-02T10:00:00Z',
      'updated_at': '2025-10-02T10:00:00Z',
    },
    {
      'id': 'assign_003',
      'user_id': 'FBRpLyTyvIpGqGYdNURK',
      'title': 'Security Audit Report',
      'description': 'Conduct comprehensive security audit and prepare detailed report with recommendations.',
      'status': 'completed',
      'priority': 'high',
      'due_date': '2025-09-30',
      'assigned_by': 'admin_001',
      'progress': 100,
      'created_at': '2025-09-25T08:00:00Z',
      'updated_at': '2025-09-29T16:00:00Z',
    },
    {
      'id': 'assign_004',
      'user_id': 'user_002',
      'title': 'Financial Analysis Q3',
      'description': 'Prepare quarterly financial analysis report for Q3 2025 with budget variance analysis.',
      'status': 'in_progress',
      'priority': 'high',
      'due_date': '2025-10-08',
      'assigned_by': 'admin_001',
      'progress': 80,
      'created_at': '2025-09-30T09:00:00Z',
      'updated_at': '2025-10-05T11:30:00Z',
    },
  ];

  // Assignment summary - sesuai dengan assignments yang ada
  static Map<String, dynamic> assignmentSummary = {
    'total_assignments': 3, // untuk user FBRpLyTyvIpGqGYdNURK
    'completed': 1,
    'in_progress': 1,
    'pending': 1, // assigned status
    'completion_rate': 33,
  };

  // Activity summary data (sesuai dengan backend response)
  static Map<String, dynamic> activitySummary = {
    'period': 'This Week',
    'date_range': {
      'start': '2025-09-30',
      'end': '2025-10-06',
    },
    'attendance_summary': {
      'total_days_worked': 5,
      'present_days': 4,
      'late_days': 1,
      'total_hours': '33.58',
      'overtime_hours': '1.75',
      'average_hours_per_day': '6.72',
    },
    'assignment_summary': {
      'total_assignments': 4,
      'completed': 1,
      'in_progress': 1,
      'pending': 2,
      'completion_rate': 25,
    },
    'daily_breakdown': [
      {
        'date': '2025-10-01',
        'day': 'Tuesday',
        'status': 'present',
        'check_in_time': '08:00:00',
        'check_out_time': '17:30:00',
        'hours_worked': '8.50',
        'overtime_hours': '0.50',
      },
      {
        'date': '2025-10-02',
        'day': 'Wednesday',
        'status': 'late',
        'check_in_time': '08:10:00',
        'check_out_time': '17:00:00',
        'hours_worked': '7.83',
        'overtime_hours': '0.00',
      },
      {
        'date': '2025-10-03',
        'day': 'Thursday',
        'status': 'present',
        'check_in_time': '07:55:00',
        'check_out_time': '18:00:00',
        'hours_worked': '9.08',
        'overtime_hours': '1.08',
      },
      {
        'date': '2025-10-04',
        'day': 'Friday',
        'status': 'present',
        'check_in_time': '08:05:00',
        'check_out_time': '17:15:00',
        'hours_worked': '8.17',
        'overtime_hours': '0.17',
      },
      {
        'date': '2025-10-05',
        'day': 'Saturday',
        'status': 'present',
        'check_in_time': '08:15:30',
        'check_out_time': null,
        'hours_worked': '0.00',
        'overtime_hours': '0.00',
      },
    ],
  };

  // Letters/Leave requests data - sesuai dengan Firestore
  static List<Map<String, dynamic>> letters = [
    {
      'id': 'leave_001',
      'user_id': 'FBRpLyTyvIpGqGYdNURK',
      'type': 'annual_leave',
      'title': 'Cuti Tahunan',
      'description': 'Cuti tahunan untuk liburan keluarga ke Bali',
      'start_date': '2025-10-15',
      'end_date': '2025-10-17',
      'total_days': 3,
      'status': 'pending',
      'file_url': null,
      'approved_by': null,
      'approval_date': null,
      'rejection_reason': null,
      'created_at': '2025-10-03T10:00:00Z',
      'updated_at': '2025-10-03T10:00:00Z',
    },
    {
      'id': 'leave_002',
      'user_id': 'FBRpLyTyvIpGqGYdNURK',
      'type': 'sick_leave',
      'title': 'Izin Sakit',
      'description': 'Sakit demam dan flu, perlu istirahat di rumah',
      'start_date': '2025-09-25',
      'end_date': '2025-09-25',
      'total_days': 1,
      'status': 'approved',
      'file_url': 'uploads/sick_certificate_20250925.pdf',
      'approved_by': 'admin_001',
      'approval_date': '2025-09-25',
      'rejection_reason': null,
      'created_at': '2025-09-25T07:00:00Z',
      'updated_at': '2025-09-25T09:30:00Z',
    },
  ];

  // Recent activities data
  static List<Map<String, dynamic>> recentActivities = [
    {
      'id': 'activity_001',
      'type': 'attendance',
      'title': 'Clock In',
      'description': 'Checked in at 08:15 AM',
      'timestamp': '2025-10-05T08:15:30Z',
      'status': 'completed',
    },
    {
      'id': 'activity_002',
      'type': 'assignment',
      'title': 'Task Updated',
      'description': 'Updated progress on Employee Management System',
      'timestamp': '2025-10-04T14:30:00Z',
      'status': 'completed',
    },
    {
      'id': 'activity_003',
      'type': 'letter',
      'title': 'Leave Request',
      'description': 'Submitted annual leave request',
      'timestamp': '2025-10-03T10:00:00Z',
      'status': 'pending',
    },
    {
      'id': 'activity_004',
      'type': 'assignment',
      'title': 'Task Completed',
      'description': 'Completed Security Audit Report',
      'timestamp': '2025-09-29T16:00:00Z',
      'status': 'completed',
    },
  ];

  // Employee list for admin - sesuai dengan users di Firestore
  static List<Map<String, dynamic>> employees = [
    {
      'id': 'FBRpLyTyvIpGqGYdNURK',
      'employee_id': 'EMP001',
      'full_name': 'Ahmad Wijaya',
      'email': 'ahmad.wijaya@bpr.com',
      'department': 'IT Department',
      'position': 'Software Developer',
      'role': 'user',
      'status': 'active',
      'join_date': '2023-01-15',
    },
    {
      'id': 'user_002',
      'employee_id': 'EMP002',
      'full_name': 'Siti Rahayu',
      'email': 'siti.rahayu@bpr.com',
      'department': 'Finance',
      'position': 'Financial Analyst',
      'role': 'user',
      'status': 'active',
      'join_date': '2023-03-01',
    },
    {
      'id': 'user_003',
      'employee_id': 'EMP003',
      'full_name': 'Budi Santoso',
      'email': 'budi.santoso@bpr.com',
      'department': 'Operations',
      'position': 'Operations Manager',
      'role': 'user',
      'status': 'active',
      'join_date': '2022-11-15',
    },
    {
      'id': 'admin_001',
      'employee_id': 'ADM001',
      'full_name': 'Dr. Sarah Manager',
      'email': 'sarah.manager@bpr.com',
      'department': 'Management',
      'position': 'General Manager',
      'role': 'admin',
      'status': 'active',
      'join_date': '2020-06-01',
    },
  ];

  // Admin dashboard statistics
  static Map<String, dynamic> adminDashboardStats = {
    'total_employees': 4,
    'present_today': 3,
    'absent_today': 1,
    'late_today': 1,
    'total_departments': 4,
    'pending_leave_requests': 1,
    'monthly_attendance_rate': 92.5,
    'recent_joiners': 2,
  };

  // Division reports untuk admin report page
  static List<Map<String, dynamic>> divisionReports = [
    {
      'divisionName': 'IT Department',
      'points': [85.0, 90.0, 78.0, 92.0, 88.0, 95.0, 89.0],
      'labels': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      'minY': 70.0,
      'maxY': 100.0,
      'yInterval': 10.0,
      'highlightStart': 4,
      'highlightEnd': 5,
    },
    {
      'divisionName': 'Finance',
      'points': [92.0, 88.0, 85.0, 90.0, 94.0, 87.0, 91.0],
      'labels': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      'minY': 70.0,
      'maxY': 100.0,
      'yInterval': 10.0,
      'highlightStart': 2,
      'highlightEnd': 3,
    },
    {
      'divisionName': 'Operations',
      'points': [76.0, 82.0, 79.0, 85.0, 88.0, 83.0, 86.0],
      'labels': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      'minY': 70.0,
      'maxY': 100.0,
      'yInterval': 10.0,
      'highlightStart': 1,
      'highlightEnd': 2,
    },
    {
      'divisionName': 'Management',
      'points': [95.0, 98.0, 96.0, 97.0, 99.0, 94.0, 96.0],
      'labels': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      'minY': 70.0,
      'maxY': 100.0,
      'yInterval': 10.0,
      'highlightStart': 0,
      'highlightEnd': 1,
    },
  ];
}