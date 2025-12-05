import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/widgets/custom_bottom_nav_router.dart';
import 'package:frontend/modules/user/shared/user_nav_items.dart';
import 'package:frontend/data/services/attendance_service.dart';
import 'package:frontend/data/models/attendance.dart';
import 'package:frontend/data/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/services/realtime_service.dart';
import 'package:provider/provider.dart';
import 'dart:async';

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
  final RealtimeService _realtimeService = RealtimeService();
  StreamSubscription? _attendanceSubscription;
  
  List<Attendance> _recentAttendance = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeRealtime();
  }

  Future<void> _initializeRealtime() async {
    await _realtimeService.initialize();
    _realtimeService.startAttendanceListener();
    
    _attendanceSubscription = _realtimeService.attendanceStream.listen((attendanceData) {
      if (mounted) {
        setState(() {
          _recentAttendance = attendanceData
              .map((data) => Attendance.fromJson(data))
              .take(10)
              .toList();
          _isLoading = false;
        });
        print('🔄 User Attendance: Realtime updated (${attendanceData.length} records)');
      }
    });
  }

  @override
  void dispose() {
    _attendanceSubscription?.cancel();
    _realtimeService.stopAllListeners();
    super.dispose();
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
      print('[AttendancePage] Debug: Attendance response success: ${response.success}');
      print('[AttendancePage] Debug: Response message: ${response.message}');
      print('[AttendancePage] Debug: Response data is null: ${response.data == null}');
      
      if (response.success) {
        if (response.data != null) {
          print('[AttendancePage] Debug: Data object exists');
          print('[AttendancePage] Debug: Month: ${response.data!.month}');
          print('[AttendancePage] Debug: Year: ${response.data!.year}');
          print('[AttendancePage] Debug: Attendance list length: ${response.data!.attendance.length}');
          print('[AttendancePage] Debug: Stats total days: ${response.data!.stats.totalDays}');
          
          if (mounted) {
            setState(() {
              // Take only the last 5 records for recent history
              _recentAttendance = response.data!.attendance.take(5).toList();
              _isLoading = false;
            });
          }
          
          // Debug each attendance record
          for (var i = 0; i < _recentAttendance.length; i++) {
            final attendance = _recentAttendance[i];
            print('[AttendancePage] Debug Record $i: Date=${attendance.date}, CheckIn=${attendance.checkInTime}, CheckOut=${attendance.checkOutTime}, Status=${attendance.status}');
          }
        } else {
          print('[AttendancePage] Debug: Response data is NULL despite success=true');
          if (mounted) {
            setState(() {
              _error = 'No data received from server';
              _isLoading = false;
            });
          }
        }
      } else {
        print('[AttendancePage] Debug: Response failed - ${response.message}');
        if (mounted) {
          setState(() {
            _error = response.message ?? 'Failed to load attendance data';
            _isLoading = false;
          });
        }
      }
    } catch (e, stackTrace) {
      print('[AttendancePage] Debug: Exception loading attendance: $e');
      print('[AttendancePage] Debug: Stack trace: $stackTrace');
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
    
    // Always prioritize status from database
    // Database has the correct status calculated by backend
    if (attendance.status.isNotEmpty) {
      // If no check out and it's today, override to show "Working"
      if (attendance.checkOutTime == null && isToday && 
          (attendance.status == 'present' || attendance.status == 'late')) {
        return 'Working';
      }
      
      // If no check out and not today, show as incomplete
      if (attendance.checkOutTime == null && !isToday && 
          (attendance.status == 'present' || attendance.status == 'late')) {
        return 'Incomplete';
      }
      
      // Map database status to display status
      switch (attendance.status.toLowerCase()) {
        case 'present':
          return 'Completed';
        case 'late':
          return 'Late';
        case 'absent':
          return 'Absent';
        case 'leave':
        case 'sick':
          return 'Leave';
        default:
          return attendance.status;
      }
    }
    
    // Fallback: If no status in database and no check in
    if (attendance.checkInTime == null) {
      return 'Absent';
    }
    
    // Fallback: If has check in but no status
    if (attendance.checkOutTime == null) {
      return isToday ? 'Working' : 'Incomplete';
    }
    
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
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: AttendanceStats(),
                    ),

                    /// History Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(
                            child: Text(
                              "Recent History",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
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
                                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                          final currentUser = authProvider.currentUser;
                                          
                                          showDialog(
                                            context: context,
                                            builder: (context) => AttendanceDetailDialog(
                                              date: formattedDate,
                                              status: attendance.status, // Use database status directly
                                              checkIn: attendance.checkInTime ?? "-",
                                              checkOut: attendance.checkOutTime ?? "-",
                                              workHours: _calculateWorkHours(attendance),
                                              location: attendance.checkInLocation ?? "Unknown",
                                              address: attendance.checkInLocation ?? "Address not available",
                                              lat: attendance.latitude?.toString() ?? "0",
                                              long: attendance.longitude?.toString() ?? "0",
                                              userName: attendance.userName ?? currentUser?.fullName,
                                              employeeId: attendance.employeeId ?? currentUser?.employeeId,
                                              photoUrl: null, // TODO: Add photo URL when available in attendance model
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

      bottomNavigationBar: const CustomBottomNavRouter(
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
          Flexible(
            child: Text(
              "My Attendance",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
