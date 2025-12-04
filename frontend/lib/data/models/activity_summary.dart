class ActivitySummary {
  final int workingDays;
  final double totalHours;
  final int totalTasks;
  final String period;
  final AttendanceSummary attendanceSummary;
  final AssignmentSummary assignmentSummary;

  ActivitySummary({
    required this.workingDays,
    required this.totalHours,
    required this.totalTasks,
    required this.period,
    required this.attendanceSummary,
    required this.assignmentSummary,
  });

  factory ActivitySummary.fromJson(Map<String, dynamic> json) {
    final attendanceSummary = AttendanceSummary.fromJson(json['attendance_summary'] ?? {});
    final assignmentSummary = AssignmentSummary.fromJson(json['assignment_summary'] ?? {});
    
    // Safe parsing of total hours
    double totalHours;
    try {
      totalHours = double.parse(attendanceSummary.totalHours);
    } catch (e) {
      totalHours = 0.0;
    }
    
    return ActivitySummary(
      workingDays: attendanceSummary.totalDaysWorked,
      totalHours: totalHours,
      totalTasks: assignmentSummary.totalAssignments,
      period: json['period'] ?? 'This Week',
      attendanceSummary: attendanceSummary,
      assignmentSummary: assignmentSummary,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'working_days': workingDays,
      'total_hours': totalHours,
      'total_tasks': totalTasks,
      'period': period,
      'attendance_summary': attendanceSummary.toJson(),
      'assignment_summary': assignmentSummary.toJson(),
    };
  }

  // Helper getters for UI
  String get hoursDisplay => totalHours.toStringAsFixed(0);
  String get daysDisplay => workingDays.toString();
  String get tasksDisplay => totalTasks.toString();
  String get summaryText => totalHours > 0 
      ? 'You worked $hoursDisplay hours this ${period.toLowerCase()}! Great job!'
      : 'Ready to start your productive work!';
}

class AttendanceSummary {
  final int totalDaysWorked;
  final int presentDays;
  final int lateDays;
  final String totalHours;
  final String overtimeHours;
  final String averageHoursPerDay;

  AttendanceSummary({
    required this.totalDaysWorked,
    required this.presentDays,
    required this.lateDays,
    required this.totalHours,
    required this.overtimeHours,
    required this.averageHoursPerDay,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      totalDaysWorked: json['total_days_worked'] ?? 0,
      presentDays: json['present_days'] ?? 0,
      lateDays: json['late_days'] ?? 0,
      totalHours: json['total_hours'] ?? '0.00',
      overtimeHours: json['overtime_hours'] ?? '0.00',
      averageHoursPerDay: json['average_hours_per_day'] ?? '0.00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_days_worked': totalDaysWorked,
      'present_days': presentDays,
      'late_days': lateDays,
      'total_hours': totalHours,
      'overtime_hours': overtimeHours,
      'average_hours_per_day': averageHoursPerDay,
    };
  }
}

class AssignmentSummary {
  final int totalAssignments;
  final int completed;
  final int inProgress;
  final int pending;
  final int completionRate;

  AssignmentSummary({
    required this.totalAssignments,
    required this.completed,
    required this.inProgress,
    required this.pending,
    required this.completionRate,
  });

  factory AssignmentSummary.fromJson(Map<String, dynamic> json) {
    return AssignmentSummary(
      totalAssignments: json['total_assignments'] ?? 0,
      completed: json['completed'] ?? 0,
      inProgress: json['in_progress'] ?? 0,
      pending: json['pending'] ?? 0,
      completionRate: json['completion_rate'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_assignments': totalAssignments,
      'completed': completed,
      'in_progress': inProgress,
      'pending': pending,
      'completion_rate': completionRate,
    };
  }
}

class DashboardSummary {
  final ActivitySummary activitySummary;
  final Map<String, dynamic> additionalData;

  DashboardSummary({
    required this.activitySummary,
    required this.additionalData,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      activitySummary: ActivitySummary.fromJson(json['activity_summary'] ?? {}),
      additionalData: Map<String, dynamic>.from(json['additional_data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activity_summary': activitySummary.toJson(),
      'additional_data': additionalData,
    };
  }
}