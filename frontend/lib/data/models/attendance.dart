class Attendance {
  final String id;
  final String userId;
  final String date;
  final String? checkInTime;
  final String? checkOutTime;
  final String? checkInLocation;
  final String? checkOutLocation;
  final String status;
  final String? notes;
  final double? latitude;
  final double? longitude;
  final int? workingHours;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // User details (for admin views)
  final String? userName;
  final String? employeeId;
  final String? department;

  Attendance({
    required this.id,
    required this.userId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.checkInLocation,
    this.checkOutLocation,
    required this.status,
    this.notes,
    this.latitude,
    this.longitude,
    this.workingHours,
    this.createdAt,
    this.updatedAt,
    this.userName,
    this.employeeId,
    this.department,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      date: json['date'] ?? '',
      checkInTime: json['check_in_time'],
      checkOutTime: json['check_out_time'],
      checkInLocation: json['check_in_location'],
      checkOutLocation: json['check_out_location'],
      status: json['status'] ?? 'absent',
      notes: json['notes'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      workingHours: json['working_hours']?.toInt(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      userName: json['user_name'],
      employeeId: json['employee_id'],
      department: json['department'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'check_in_location': checkInLocation,
      'check_out_location': checkOutLocation,
      'status': status,
      'notes': notes,
      'latitude': latitude,
      'longitude': longitude,
      'working_hours': workingHours,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isPresent => status == 'present';
  bool get isAbsent => status == 'absent';
  bool get hasCheckedIn => checkInTime != null;
  bool get hasCheckedOut => checkOutTime != null;
  bool get isComplete => hasCheckedIn && hasCheckedOut;
}

class AttendanceStatistics {
  final int totalDays;
  final int presentDays;
  final int absentDays;
  final int lateDays;
  final double attendanceRate;
  final double punctualityRate;
  final int averageWorkingHours;
  final Map<String, int> monthlyStats;

  AttendanceStatistics({
    required this.totalDays,
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
    required this.attendanceRate,
    required this.punctualityRate,
    required this.averageWorkingHours,
    required this.monthlyStats,
  });

  factory AttendanceStatistics.fromJson(Map<String, dynamic> json) {
    return AttendanceStatistics(
      totalDays: json['total_days'] ?? 0,
      presentDays: json['present_days'] ?? 0,
      absentDays: json['absent_days'] ?? 0,
      lateDays: json['late_days'] ?? 0,
      attendanceRate: (json['attendance_rate'] ?? 0.0).toDouble(),
      punctualityRate: (json['punctuality_rate'] ?? 0.0).toDouble(),
      averageWorkingHours: json['average_working_hours'] ?? 0,
      monthlyStats: Map<String, int>.from(json['monthly_stats'] ?? {}),
    );
  }
}

class CheckInRequest {
  final String qrCode;
  final String location;
  final String? notes;
  final double? latitude;
  final double? longitude;

  CheckInRequest({
    required this.qrCode,
    required this.location,
    this.notes,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'qr_code': qrCode,
      'location': location,
      'notes': notes,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class CheckOutRequest {
  final String qrCode;
  final String location;
  final String? notes;
  final double? latitude;
  final double? longitude;

  CheckOutRequest({
    required this.qrCode,
    required this.location,
    this.notes,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'qr_code': qrCode,
      'location': location,
      'notes': notes,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class AttendanceMonthlySummary {
  final int month;
  final int year;
  final List<Attendance> attendance;
  final AttendanceMonthlyStats stats;

  AttendanceMonthlySummary({
    required this.month,
    required this.year,
    required this.attendance,
    required this.stats,
  });

  factory AttendanceMonthlySummary.fromJson(Map<String, dynamic> json) {
    return AttendanceMonthlySummary(
      month: json['month'] ?? 0,
      year: json['year'] ?? 0,
      attendance: (json['attendance'] as List? ?? [])
          .map((item) => Attendance.fromJson(item))
          .toList(),
      stats: AttendanceMonthlyStats.fromJson(json['stats'] ?? {}),
    );
  }
}

class AttendanceMonthlyStats {
  final int totalDays;
  final int presentDays;
  final int lateDays;
  final int absentDays;
  final int sickDays;
  final int leaveDays;
  final double totalHoursWorked;
  final double totalOvertimeHours;
  final double averageHoursPerDay;

  AttendanceMonthlyStats({
    required this.totalDays,
    required this.presentDays,
    required this.lateDays,
    required this.absentDays,
    required this.sickDays,
    required this.leaveDays,
    required this.totalHoursWorked,
    required this.totalOvertimeHours,
    required this.averageHoursPerDay,
  });

  factory AttendanceMonthlyStats.fromJson(Map<String, dynamic> json) {
    return AttendanceMonthlyStats(
      totalDays: json['total_days'] ?? 0,
      presentDays: json['present_days'] ?? 0,
      lateDays: json['late_days'] ?? 0,
      absentDays: json['absent_days'] ?? 0,
      sickDays: json['sick_days'] ?? 0,
      leaveDays: json['leave_days'] ?? 0,
      totalHoursWorked: (json['total_hours_worked'] ?? 0.0).toDouble(),
      totalOvertimeHours: (json['total_overtime_hours'] ?? 0.0).toDouble(),
      averageHoursPerDay: (json['average_hours_per_day'] ?? 0.0).toDouble(),
    );
  }

  // Calculated properties for UI display
  int get present => presentDays;
  int get late => lateDays;
  int get absent => absentDays;
  int get leave => leaveDays + sickDays; // Combine sick and leave for UI
}