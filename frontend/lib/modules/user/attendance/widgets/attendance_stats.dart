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
      print('🔍 Debug AttendanceStats: Response success: ${response.isSuccess}');
      print('🔍 Debug AttendanceStats: Stats data: ${response.data?.stats}');
      
      if (response.isSuccess && response.data != null) {
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
    } catch (e) {
      print('🔍 Debug AttendanceStats: Exception - $e');
      setState(() {
        _error = 'Error loading attendance data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  fontSize: 16,
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
              else if (_error != null)
                GestureDetector(
                  onTap: _loadMonthlyStats,
                  child: Icon(
                    Icons.refresh,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (_error != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppColors.errorRed,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.check_circle,
                  iconColor: AppColors.primaryGreen,
                  value: _stats?.present.toString() ?? "0",
                  label: "Present",
                ),
                _buildStatItem(
                  icon: Icons.access_time,
                  iconColor: AppColors.vibrantOrange,
                  value: _stats?.late.toString() ?? "0",
                  label: "Late",
                ),
                _buildStatItem(
                  icon: Icons.cancel,
                  iconColor: AppColors.errorRed,
                  value: _stats?.absent.toString() ?? "0",
                  label: "Absent",
                ),
                _buildStatItem(
                  icon: Icons.event_available,
                  iconColor: AppColors.primaryBlue,
                  value: _stats?.leave.toString() ?? "0",
                  label: "Leave",
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
