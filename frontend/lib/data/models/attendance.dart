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

  // Getter for formatted date
  String get formattedDate {
    try {
      final parsedDate = DateTime.parse(date);
      final months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '${parsedDate.day} ${months[parsedDate.month - 1]} ${parsedDate.year}';
    } catch (e) {
      return date; // Return original if parsing fails
    }
  }

  factory Attendance.fromJson(Map<String, dynamic> json) {
    // Helper function to extract location string from object or string
    String? extractLocation(dynamic locationData) {
      if (locationData == null) return null;
      if (locationData is String) return locationData;
      if (locationData is Map<String, dynamic>) {
        return locationData['address'] ?? '';
      }
      return null;
    }
    
    // Helper to safely extract string
    String safeString(dynamic value, {String defaultValue = ''}) {
      if (value == null) return defaultValue;
      if (value is String) return value;
      return value.toString();
    }
    
    // Helper to safely extract nullable string
    String? safeNullableString(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      return value.toString();
    }
    
    // Helper to safely extract double
    double? safeDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          print('⚠️ Failed to parse double from string: $value');
          return null;
        }
      }
      return null;
    }
    
    // Helper to safely extract int
    int? safeInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          print('⚠️ Failed to parse int from string: $value');
          return null;
        }
      }
      return null;
    }

    try {
      print('🔍 Attendance.fromJson - Processing: ${json['id']}');
      print('🔍 Attendance.fromJson - Available keys: ${json.keys}');
      
      // Make sure we have required fields
      final attendanceId = safeString(json['id'], defaultValue: '');
      final attendanceUserId = safeString(
        json['userId'] ?? json['user_id'] ?? json['employee_id'],
        defaultValue: 'unknown'
      );
      final attendanceDate = safeString(json['date'], defaultValue: DateTime.now().toString());
      
      if (attendanceId.isEmpty) {
        print('⚠️ Attendance missing ID, JSON: $json');
      }
      
      return Attendance(
        id: attendanceId,
        userId: attendanceUserId,
        date: attendanceDate,
        checkInTime: safeNullableString(json['checkInTime'] ?? json['check_in_time'] ?? json['checkin_time']),
        checkOutTime: safeNullableString(json['checkOutTime'] ?? json['check_out_time'] ?? json['checkout_time']),
        checkInLocation: extractLocation(json['checkInLocation'] ?? json['check_in_location'] ?? json['checkin_location']),
        checkOutLocation: extractLocation(json['checkOutLocation'] ?? json['check_out_location'] ?? json['checkout_location']),
        status: safeString(json['status'], defaultValue: 'absent'),
        notes: safeNullableString(json['notes']),
        latitude: safeDouble(json['latitude']),
        longitude: safeDouble(json['longitude']),
        workingHours: safeInt(json['hoursWorked'] ?? json['working_hours'] ?? json['hours_worked']),
        createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
        updatedAt: _parseDateTime(json['updatedAt'] ?? json['updated_at']),
        userName: safeNullableString(json['userName'] ?? json['user_name']),
        employeeId: safeNullableString(json['employeeId'] ?? json['employee_id']),
        department: safeNullableString(json['department']),
      );
    } catch (e, stackTrace) {
      print('❌ Attendance.fromJson - Error: $e');
      print('❌ Attendance.fromJson - Error Type: ${e.runtimeType}');
      print('❌ Attendance.fromJson - Stack trace: $stackTrace');
      print('❌ Attendance.fromJson - Raw JSON: $json');
      print('❌ Attendance.fromJson - JSON Type: ${json.runtimeType}');
      rethrow;
    }
  }

  // Helper method to parse Firestore timestamp
  static DateTime? _parseDateTime(dynamic timestamp) {
    try {
      if (timestamp == null) return null;
      
      if (timestamp is Map<String, dynamic>) {
        final seconds = timestamp['_seconds'];
        final nanoseconds = timestamp['_nanoseconds'] ?? 0;
        if (seconds != null) {
          return DateTime.fromMillisecondsSinceEpoch(
            (seconds * 1000) + (nanoseconds ~/ 1000000)
          );
        }
      }
      
      if (timestamp is String) {
        return DateTime.parse(timestamp);
      }
      
      return null;
    } catch (e) {
      print('⚠️ _parseDateTime - Error parsing timestamp: $e');
      return null;
    }
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
    print('🔍 AttendanceMonthlySummary.fromJson - Input JSON: $json');
    print('🔍 AttendanceMonthlySummary.fromJson - JSON keys: ${json.keys}');
    print('🔍 AttendanceMonthlySummary.fromJson - Month: ${json['month']}');
    print('🔍 AttendanceMonthlySummary.fromJson - Year: ${json['year']}');
    print('🔍 AttendanceMonthlySummary.fromJson - Attendance type: ${json['attendance'].runtimeType}');
    print('🔍 AttendanceMonthlySummary.fromJson - Attendance length: ${(json['attendance'] as List?)?.length ?? 0}');
    print('🔍 AttendanceMonthlySummary.fromJson - Stats type: ${json['stats'].runtimeType}');
    print('🔍 AttendanceMonthlySummary.fromJson - Stats: ${json['stats']}');
    
    try {
      final attendanceList = <Attendance>[];
      final rawAttendanceList = json['attendance'] as List? ?? [];
      
      print('🔍 Processing ${rawAttendanceList.length} attendance records...');
      
      for (var i = 0; i < rawAttendanceList.length; i++) {
        try {
          final item = rawAttendanceList[i];
          print('🔍 Processing attendance item [$i]: $item');
          final attendance = Attendance.fromJson(item);
          attendanceList.add(attendance);
          print('✅ Successfully parsed attendance item [$i]');
        } catch (e) {
          print('❌ Failed to parse attendance item [$i]: $e');
          print('❌ Item data: ${rawAttendanceList[i]}');
          // Continue processing other items instead of failing completely
        }
      }
      
      print('🔍 AttendanceMonthlySummary.fromJson - Parsed ${attendanceList.length} attendance records');
      
      final stats = AttendanceMonthlyStats.fromJson(json['stats'] ?? {});
      print('🔍 AttendanceMonthlySummary.fromJson - Parsed stats successfully');
      
      return AttendanceMonthlySummary(
        month: json['month'] ?? 0,
        year: json['year'] ?? 0,
        attendance: attendanceList,
        stats: stats,
      );
    } catch (e, stackTrace) {
      print('❌ AttendanceMonthlySummary.fromJson - Error: $e');
      print('❌ AttendanceMonthlySummary.fromJson - Error type: ${e.runtimeType}');
      print('❌ AttendanceMonthlySummary.fromJson - Stack trace: $stackTrace');
      rethrow;
    }
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
    print('🔍 AttendanceMonthlyStats.fromJson - Input JSON: $json');
    print('🔍 AttendanceMonthlyStats.fromJson - total_days: ${json['total_days']}');
    print('🔍 AttendanceMonthlyStats.fromJson - present_days: ${json['present_days']}');
    print('🔍 AttendanceMonthlyStats.fromJson - late_days: ${json['late_days']}');
    print('🔍 AttendanceMonthlyStats.fromJson - absent_days: ${json['absent_days']}');
    
    // Safe int parser
    int safeInt(dynamic value, {int defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          return defaultValue;
        }
      }
      return defaultValue;
    }
    
    // Safe double parser
    double safeDouble(dynamic value, {double defaultValue = 0.0}) {
      if (value == null) return defaultValue;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          return defaultValue;
        }
      }
      return defaultValue;
    }
    
    return AttendanceMonthlyStats(
      totalDays: safeInt(json['total_days']),
      presentDays: safeInt(json['present_days']),
      lateDays: safeInt(json['late_days']),
      absentDays: safeInt(json['absent_days']),
      sickDays: safeInt(json['sick_days']),
      leaveDays: safeInt(json['leave_days']),
      totalHoursWorked: safeDouble(json['total_hours_worked']),
      totalOvertimeHours: safeDouble(json['total_overtime_hours']),
      averageHoursPerDay: safeDouble(json['average_hours_per_day']),
    );
  }

  // Calculated properties for UI display
  int get present => presentDays;
  int get late => lateDays;
  int get absent => absentDays;
  int get leave => leaveDays + sickDays; // Combine sick and leave for UI
}