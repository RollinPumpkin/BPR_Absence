import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/data/services/dashboard_service.dart';
import 'package:frontend/data/models/activity_summary.dart';

class ActivitySummaryWidget extends StatefulWidget {
  const ActivitySummaryWidget({super.key});

  @override
  State<ActivitySummaryWidget> createState() => _ActivitySummaryWidgetState();
}

class _ActivitySummaryWidgetState extends State<ActivitySummaryWidget> {
  final DashboardService _dashboardService = DashboardService();
  
  ActivitySummary? _activitySummary;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadActivityData();
  }

  Future<void> _loadActivityData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get activity summary for this week
      final response = await _dashboardService.getActivitySummary(period: 'week');
      
      if (response.isSuccess && response.data != null) {
        setState(() {
          _activitySummary = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message ?? 'Failed to load activity data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading activity data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header with red background
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFE53E3E),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Activity Summary",
                  style: TextStyle(
                    color: AppColors.pureWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.pureWhite),
                    ),
                  )
                else if (_error != null)
                  GestureDetector(
                    onTap: _loadActivityData,
                    child: const Icon(
                      Icons.refresh,
                      color: AppColors.pureWhite,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),

          /// Activity Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _error != null
                    ? Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: AppColors.errorRed,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _error!,
                            style: const TextStyle(
                              color: AppColors.errorRed,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _loadActivityData,
                            child: const Text('Retry'),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _activitySummary?.summaryText ?? 'Loading...',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Weekly stats
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem("Days", _activitySummary?.daysDisplay ?? "0", AppColors.primaryBlue),
                              _buildStatItem("Hours", _activitySummary?.hoursDisplay ?? "0", AppColors.primaryGreen),
                              _buildStatItem("Tasks", _activitySummary?.tasksDisplay ?? "0", AppColors.vibrantOrange),
                            ],
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}