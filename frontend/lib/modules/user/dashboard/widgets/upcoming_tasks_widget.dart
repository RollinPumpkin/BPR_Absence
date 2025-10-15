import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/data/services/assignment_service.dart';
import 'package:frontend/data/services/debug_service.dart';
import 'package:frontend/data/models/assignment.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

class UpcomingTasksWidget extends StatefulWidget {
  const UpcomingTasksWidget({super.key});

  @override
  State<UpcomingTasksWidget> createState() => _UpcomingTasksWidgetState();
}

class _UpcomingTasksWidgetState extends State<UpcomingTasksWidget> {
  final AssignmentService _assignmentService = AssignmentService();
  List<Assignment> _assignments = [];
  bool _isLoading = true;
  String? _error;
  bool _showAllTasks = false;
  static const int _maxTasksToShow = 3;

  @override
  void initState() {
    super.initState();
    _performConnectivityTests();
  }

  Future<void> _performConnectivityTests() async {
    print('[UpcomingTasksWidget] Starting connectivity tests...');
    
    try {
      // Skip debug tests for now and go directly to loading tasks
      print('[UpcomingTasksWidget] Skipping debug tests, loading tasks directly...');
      _loadUpcomingTasks();
      
    } catch (e) {
      print('[UpcomingTasksWidget] Error in connectivity tests: $e');
      _loadUpcomingTasks(); // Try to load tasks anyway
    }
  }

  Future<void> _loadUpcomingTasks() async {
    print('🎯 [UpcomingTasksWidget] Starting _loadUpcomingTasks');
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Directly try to get assignments without complex testing
      print('📱 Getting upcoming assignments...');
      final assignments = await _assignmentService.getUpcomingAssignments();
      
      print('✅ [UpcomingTasksWidget] Received ${assignments.length} assignments');
      for (var assignment in assignments) {
        print('📋 Assignment: ${assignment.title} - Due: ${assignment.dueDate}');
      }
      
      setState(() {
        _assignments = assignments;
        _isLoading = false;
      });
      
      print('✅ [UpcomingTasksWidget] State updated with ${_assignments.length} assignments');
    } catch (e) {
      print('❌ [UpcomingTasksWidget] Error loading tasks: $e');
      setState(() {
        _error = e.toString();
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
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Red Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.errorRed,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Tasks',
                  style: TextStyle(
                    color: AppColors.pureWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    // Reload button
                    IconButton(
                      onPressed: () {
                        print('🔄 Manual reload triggered');
                        _loadUpcomingTasks();
                      },
                      icon: const Icon(
                        Icons.refresh,
                        color: AppColors.pureWhite,
                        size: 16,
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
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          // Task List
          _buildTaskList(),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.errorRed,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Error loading tasks',
              style: TextStyle(
                color: AppColors.errorRed,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _error!,
              style: const TextStyle(
                color: AppColors.black54,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadUpcomingTasks,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(color: AppColors.pureWhite),
              ),
            ),
          ],
        ),
      );
    }

    if (_assignments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.assignment_outlined,
              color: Colors.grey.shade400,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'No upcoming tasks',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'You\'re all caught up!',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Determine which tasks to show
    List<Assignment> tasksToShow = _showAllTasks 
        ? _assignments 
        : _assignments.take(_maxTasksToShow).toList();

    return Column(
      children: [
        // Task items
        ...tasksToShow.map((assignment) => _buildTaskItem(assignment)).toList(),
        
        // View All / View Less button
        if (_assignments.length > _maxTasksToShow)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextButton(
              onPressed: () {
                setState(() {
                  _showAllTasks = !_showAllTasks;
                });
              },
              child: Text(
                _showAllTasks 
                    ? 'View Less' 
                    : 'View All (${_assignments.length} tasks)',
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryBlue.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: AppColors.primaryBlue.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildTaskItem(Assignment assignment) {
    final timeFormatter = DateFormat('HH:mm');
    final dateFormatter = DateFormat('MMM dd');
    final now = DateTime.now();
    final isToday = assignment.dueDate.year == now.year &&
                   assignment.dueDate.month == now.month &&
                   assignment.dueDate.day == now.day;
    
    Color priorityColor;
    switch (assignment.priority.toLowerCase()) {
      case 'high':
        priorityColor = AppColors.errorRed;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        break;
      case 'low':
        priorityColor = AppColors.primaryGreen;
        break;
      default:
        priorityColor = Colors.grey;
    }

    // Color coding for dates with tasks
    Color dateColor = isToday ? AppColors.errorRed : AppColors.primaryBlue;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Priority indicator
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: priorityColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          
          // Task details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black87,
                  ),
                ),
                if (assignment.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    assignment.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          
          // Date and time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: dateColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: dateColor, width: 1),
                ),
                child: Text(
                  isToday ? 'Today' : dateFormatter.format(assignment.dueDate),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: dateColor,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                timeFormatter.format(assignment.dueDate),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}