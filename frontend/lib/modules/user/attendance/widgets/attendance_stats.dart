import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/data/services/attendance_service.dart';
import 'package:frontend/data/models/attendance.dart';

class AttendanceStats extends StatefulWidget {
  const AttendanceStats({super.key});

  @override
  State<AttendanceStats> createState() => _AttendanceStatsState();
}

class _AttendanceStatsState extends State<AttendanceStats> {
  final AttendanceService _attendanceService = AttendanceService();
  AttendanceMonthlyStats? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMonthlyStats();
  }

  Future<void> _loadMonthlyStats() async {
    try {
      print('🔍 Debug AttendanceStats: Loading monthly stats...');
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _attendanceService.getMonthlySummary();
      print('🔍 Debug AttendanceStats: Response success: ${response.success}');
      print('🔍 Debug AttendanceStats: Response message: ${response.message}');
      print('🔍 Debug AttendanceStats: Response data is null: ${response.data == null}');
      print('🔍 Debug AttendanceStats: Stats data: ${response.data?.stats}');
      
      if (response.success && response.data != null) {
        print('🔍 Debug AttendanceStats: Present: ${response.data!.stats.present}, Late: ${response.data!.stats.late}, Absent: ${response.data!.stats.absent}, Leave: ${response.data!.stats.leave}');
        setState(() {
          _stats = response.data!.stats;
          _isLoading = false;
        });
      } else {
        print('🔍 Debug AttendanceStats: Failed - ${response.message}');
        setState(() {
          _error = response.message ?? 'Failed to load attendance data';
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('🔍 Debug AttendanceStats: Exception - $e');
      print('🔍 Debug AttendanceStats: Stack trace: $stackTrace');
      setState(() {
        _error = 'Error loading attendance data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "This Month",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black87,
                      ),
                    ),
                    if (_isLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                  ],
                ),
                const SizedBox(height: 16.0),
              
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.errorRed,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.errorRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.check_circle,
                        iconColor: AppColors.primaryGreen,
                        value: _stats?.present.toString() ?? "0",
                        label: "Present",
                        iconSize: 24.0,
                        fontSize: 20.0,
                        labelFontSize: 12.0,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.access_time,
                        iconColor: AppColors.vibrantOrange,
                        value: _stats?.late.toString() ?? "0",
                        label: "Late",
                        iconSize: 24.0,
                        fontSize: 20.0,
                        labelFontSize: 12.0,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.cancel,
                        iconColor: AppColors.errorRed,
                        value: _stats?.absent.toString() ?? "0",
                        label: "Absent",
                        iconSize: 24.0,
                        fontSize: 20.0,
                        labelFontSize: 12.0,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.event_available,
                        iconColor: AppColors.primaryBlue,
                        value: _stats?.leave.toString() ?? "0",
                        label: "Leave",
                        iconSize: 24.0,
                        fontSize: 20.0,
                        labelFontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required double iconSize,
    required double fontSize,
    required double labelFontSize,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(iconSize < 20 ? 6.0 : 8.0),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: iconSize,
          ),
        ),
        SizedBox(height: iconSize < 20 ? 6.0 : 8.0),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: labelFontSize,
            color: Colors.grey.shade600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
