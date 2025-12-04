import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class ProfileStatsCard extends StatelessWidget {
  final double attendanceRate;
  final int totalPresent;
  final int totalAbsent;
  final int totalLate;

  const ProfileStatsCard({
    super.key,
    required this.attendanceRate,
    required this.totalPresent,
    required this.totalAbsent,
    required this.totalLate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral800,
            ),
          ),
          const SizedBox(height: 16),
          
          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Present',
                  '$totalPresent',
                  Icons.check_circle,
                  AppColors.primaryGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'Absent',
                  '$totalAbsent',
                  Icons.cancel,
                  AppColors.primaryRed,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Late',
                  '$totalLate',
                  Icons.access_time,
                  AppColors.primaryOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAttendanceRate(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceRate() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: attendanceRate / 100,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    attendanceRate >= 80 
                        ? AppColors.primaryGreen
                        : attendanceRate >= 60
                            ? AppColors.primaryOrange  
                            : AppColors.primaryRed,
                  ),
                ),
              ),
              Text(
                '${attendanceRate.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Attendance',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.neutral800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.neutral800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}