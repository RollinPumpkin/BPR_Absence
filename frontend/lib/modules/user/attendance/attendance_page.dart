import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/widgets/custom_bottom_nav_router.dart';
import 'package:frontend/modules/user/shared/user_nav_items.dart';
import 'package:frontend/data/services/attendance_service.dart';
import 'package:frontend/data/models/attendance.dart';
import 'package:intl/intl.dart';

import 'widgets/attendance_stats.dart';
import 'widgets/attendance_history_card.dart';
import 'widgets/attendance_detail_dialog.dart';
import 'attendance_history_page.dart';

class UserAttendancePage extends StatefulWidget {
  const UserAttendancePage({super.key});

  @override
  State<UserAttendancePage> createState() => _UserAttendancePageState();
}

class _UserAttendancePageState extends State<UserAttendancePage> {
  final AttendanceService _attendanceService = AttendanceService();
  List<Attendance> _recentAttendance = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecentAttendance();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when user navigates back to this page
    print('[AttendancePage] Debug: Page dependencies changed, refreshing data...');
    _loadRecentAttendance();
  }

  Future<void> _loadRecentAttendance() async {
    try {
      print('[AttendancePage] Debug: Loading attendance data...');
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      final response = await _attendanceService.getMonthlySummary();
      print('[AttendancePage] Debug: Attendance response: ${response.isSuccess}');
      print('[AttendancePage] Debug: Response message: ${response.message}');
      print('[AttendancePage] Debug: Response data: ${response.data}');
      
      if (response.isSuccess && response.data != null) {
        print('[AttendancePage] Debug: Found ${response.data!.attendance.length} attendance records');
        if (mounted) {
          setState(() {
            // Take only the last 5 records for recent history
            _recentAttendance = response.data!.attendance.take(5).toList();
            _isLoading = false;
          });
        }
        
        // Debug each attendance record
        for (var attendance in _recentAttendance) {
          print('[AttendancePage] Debug: Attendance - Date: ${attendance.date}, CheckIn: ${attendance.checkInTime}, CheckOut: ${attendance.checkOutTime}');
        }
      } else {
        print('[AttendancePage] Debug: Failed to load - ${response.message}');
        if (mounted) {
          setState(() {
            _error = response.message ?? 'Failed to load attendance data';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('[AttendancePage] Debug: Exception loading attendance: $e');
      if (mounted) {
        setState(() {
          _error = 'Error loading attendance data: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  String _getAttendanceStatus(Attendance attendance) {
    final now = DateTime.now();
    final attendanceDate = DateTime.parse(attendance.date);
    final isToday = DateFormat('yyyy-MM-dd').format(now) == attendance.date;
    
    // If no check in, check the database status first
    if (attendance.checkInTime == null) {
      // Check if there's a leave/sick status from database
      if (attendance.status == 'leave' || attendance.status == 'sick') {
        return 'Leave';
      }
      // If no status in database, it's absent
      return 'Absent';
    }
    
    // Parse check in time
    final checkInTime = TimeOfDay(
      hour: int.parse(attendance.checkInTime!.split(':')[0]),
      minute: int.parse(attendance.checkInTime!.split(':')[1]),
    );
    
    // Define work start time (8:00 AM)
    const workStartTime = TimeOfDay(hour: 8, minute: 0);
    
    // Check if late (after 8:00 AM)
    final isLate = checkInTime.hour > workStartTime.hour || 
                   (checkInTime.hour == workStartTime.hour && checkInTime.minute > workStartTime.minute);
    
    // If no check out and it's today, show "Working"
    if (attendance.checkOutTime == null) {
      if (isToday) {
        return 'Working';
      } else {
        // If it's not today and no checkout, it's incomplete
        return 'Incomplete';
      }
    }
    
    // Parse check out time
    final checkOutTime = TimeOfDay(
      hour: int.parse(attendance.checkOutTime!.split(':')[0]),
      minute: int.parse(attendance.checkOutTime!.split(':')[1]),
    );
    
    // Define normal work end time (17:00 PM)
    const workEndTime = TimeOfDay(hour: 17, minute: 0);
    
    // Check if early departure (before 17:00 PM)
    final isEarly = checkOutTime.hour < workEndTime.hour || 
                    (checkOutTime.hour == workEndTime.hour && checkOutTime.minute < workEndTime.minute);
    
    // Priority: Late stays late even if completed (as per requirement)
    if (isLate) {
      return 'Late';
    }
    
    // Early departure (leave early)
    if (isEarly) {
      return 'Leave';
    }
    
    // Normal completion
    return 'Completed';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'working':
        return AppColors.primaryGreen;
      case 'late':
        return AppColors.vibrantOrange;
      case 'completed':
        return AppColors.primaryBlue;
      case 'leave':
        return AppColors.primaryBlue;
      case 'absent':
        return AppColors.errorRed;
      case 'incomplete':
        return Colors.grey;
      default:
        return AppColors.black;
    }
  }

  String _calculateWorkHours(Attendance attendance) {
    if (attendance.checkInTime == null || attendance.checkOutTime == null) {
      return "-";
    }

    try {
      final checkIn = TimeOfDay(
        hour: int.parse(attendance.checkInTime!.split(':')[0]),
        minute: int.parse(attendance.checkInTime!.split(':')[1]),
      );
      
      final checkOut = TimeOfDay(
        hour: int.parse(attendance.checkOutTime!.split(':')[0]),
        minute: int.parse(attendance.checkOutTime!.split(':')[1]),
      );

      // Convert to minutes for easier calculation
      final checkInMinutes = checkIn.hour * 60 + checkIn.minute;
      final checkOutMinutes = checkOut.hour * 60 + checkOut.minute;
      
      final totalMinutes = checkOutMinutes - checkInMinutes;
      
      if (totalMinutes <= 0) return "-";
      
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      
      return "${hours}h ${minutes}m";
    } catch (e) {
      return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    /// Attendance Statistics
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: AttendanceStats(),
                    ),

                    /// History Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Recent History",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AttendanceHistoryPage(),
                                ),
                              );
                            },
                            child: const Text("View All"),
                          ),
                        ],
                      ),
                    ),

                    /// History List
                    _isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : _error != null
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Text(
                                      _error!,
                                      style: const TextStyle(color: AppColors.errorRed),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: _loadRecentAttendance,
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              )
                            : _recentAttendance.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.all(32),
                                    child: Center(
                                      child: Text(
                                        'No attendance records found',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    itemCount: _recentAttendance.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final attendance = _recentAttendance[index];
                                      final status = _getAttendanceStatus(attendance);
                                      final statusColor = _getStatusColor(status);
                                      
                                      // Format date
                                      final date = DateTime.parse(attendance.date);
                                      final formattedDate = DateFormat('MMMM d, yyyy').format(date);

                                      return AttendanceHistoryCard(
                                        date: formattedDate,
                                        clockIn: attendance.checkInTime ?? "-",
                                        clockOut: attendance.checkOutTime ?? "-",
                                        status: status,
                                        statusColor: statusColor,
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AttendanceDetailDialog(
                                              date: formattedDate,
                                              status: status,
                                              checkIn: attendance.checkInTime ?? "-",
                                              checkOut: attendance.checkOutTime ?? "-",
                                              workHours: _calculateWorkHours(attendance),
                                              location: attendance.checkInLocation ?? "Unknown",
                                              address: attendance.checkInLocation ?? "Address not available",
                                              lat: attendance.latitude?.toString() ?? "0",
                                              long: attendance.longitude?.toString() ?? "0",
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: CustomBottomNavRouter(
        currentIndex: 1,
        items: UserNavItems.items,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "My Attendance",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.black87,
            ),
          ),
          IconButton(
            onPressed: () {
              print('🔍 Debug: Manual refresh triggered');
              _loadRecentAttendance();
            },
            icon: const Icon(
              Icons.refresh,
              color: AppColors.primaryBlue,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
