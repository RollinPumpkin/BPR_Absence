import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/custom_bottom_nav_router.dart';
import 'package:frontend/modules/admin/shared/admin_nav_items.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/data/services/assignment_service.dart';
import 'package:frontend/data/models/assignment.dart';

// Widgets assignment
import 'widgets/assignment_tab_switcher.dart';
import 'widgets/daily/daily_assignment_ui.dart';
import 'widgets/weekly/weekly_assignment_ui.dart';
import 'widgets/monthly/monthly_assignment_ui.dart';
import 'widgets/assignment_summary_chart.dart';

class AssignmentPage extends StatefulWidget {
  const AssignmentPage({super.key});

  @override
  State<AssignmentPage> createState() => _AssignmentPageState();
}

class _AssignmentPageState extends State<AssignmentPage> {
  String selectedTab = 'Monthly';
  final AssignmentService _assignmentService = AssignmentService();
  
  List<Assignment> _assignments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      print('🚀 Starting to load assignments...');
      
      // Try to get assignments from API first
      List<Assignment> assignments = [];
      
      try {
        // Debug API connection first
        print('🔍 Running API debug check...');
        await _assignmentService.debugApiCall();
        
        // Try to get upcoming assignments first
        assignments = await _assignmentService.getUpcomingAssignments();
        
        // If no upcoming assignments, try to get all assignments
        if (assignments.isEmpty) {
          print('📋 No upcoming assignments, trying to get all assignments...');
          assignments = await _assignmentService.getAllAssignments();
        }
        
        print('📋 Loaded ${assignments.length} assignments from API');
      } catch (apiError) {
        print('❌ API Error: $apiError');
        print('🔄 Using fallback dummy data for testing...');
        
        // Fallback to dummy data for testing
        assignments = _createDummyAssignments();
        print('📋 Using ${assignments.length} dummy assignments as fallback');
      }

      setState(() {
        _assignments = assignments;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading assignments: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Assignment> _createDummyAssignments() {
    final now = DateTime.now();
    return [
      Assignment(
        id: '1',
        title: 'Morning Stand-up Meeting',
        description: 'Daily team synchronization meeting to discuss progress and blockers',
        dueDate: now.add(Duration(hours: 2)),
        priority: 'medium',
        status: 'pending',
        assignedTo: 'admin',
        assignedBy: 'admin',
        createdAt: now.subtract(Duration(days: 1)),
        updatedAt: now,
      ),
      Assignment(
        id: '2', 
        title: 'Code Review - Payment Module',
        description: 'Review and approve pull requests for payment gateway integration',
        dueDate: now.add(Duration(hours: 4)),
        priority: 'high',
        status: 'in-progress',
        assignedTo: 'admin',
        assignedBy: 'admin',
        createdAt: now.subtract(Duration(days: 1)),
        updatedAt: now,
      ),
      Assignment(
        id: '3',
        title: 'Monthly Financial Report',
        description: 'Compile and submit comprehensive financial report for October 2025',
        dueDate: now.add(Duration(days: 1)),
        priority: 'high',
        status: 'pending',
        assignedTo: 'admin',
        assignedBy: 'admin',
        createdAt: now.subtract(Duration(days: 2)),
        updatedAt: now,
      ),
      Assignment(
        id: '4',
        title: 'Database Optimization',
        description: 'Optimize database queries and implement indexing for better performance',
        dueDate: now.add(Duration(days: 3)),
        priority: 'medium',
        status: 'pending',
        assignedTo: 'admin',
        assignedBy: 'admin',
        createdAt: now.subtract(Duration(days: 1)),
        updatedAt: now,
      ),
      Assignment(
        id: '5',
        title: 'System Performance Analysis',
        description: 'Analyze system performance and create optimization recommendations',
        dueDate: now.subtract(Duration(days: 2)),
        priority: 'medium',
        status: 'overdue',
        assignedTo: 'admin',
        assignedBy: 'admin',
        createdAt: now.subtract(Duration(days: 5)),
        updatedAt: now,
      ),
      Assignment(
        id: '6',
        title: 'Weekly Team Retrospective',
        description: 'Facilitate weekly retrospective meeting to discuss improvements',
        dueDate: now.subtract(Duration(days: 1)),
        priority: 'low',
        status: 'completed',
        assignedTo: 'admin',
        assignedBy: 'admin', 
        createdAt: now.subtract(Duration(days: 3)),
        updatedAt: now,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,

      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: const Text(
          'Assignments',
          style: TextStyle(
            color: AppColors.neutral800,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAssignments,
          ),
        ],
      ),

      body: _buildBody(),

      bottomNavigationBar: const CustomBottomNavRouter(
        currentIndex: 2,
        items: AdminNavItems.items,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading assignments...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.errorRed),
            const SizedBox(height: 16),
            Text(
              'Error loading assignments:\n$_error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.errorRed),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAssignments,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Assignment summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Assignments',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.neutral800,
                        ),
                      ),
                      Text(
                        '${_assignments.length}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutral800,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.assignment,
                  size: 32,
                  color: AppColors.primaryBlue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tab switcher
          AssignmentTabSwitcher(
            selected: selectedTab,
            onChanged: (val) => setState(() => selectedTab = val),
          ),
          const SizedBox(height: 12),

          // Tampilkan chart saat Weekly
          if (selectedTab == 'Weekly') ...[
            AssignmentSummaryChart(period: 'Weekly'),
            const SizedBox(height: 12),
          ],

          // Konten sesuai tab dengan data real
          if (selectedTab == 'Daily')
            DailyAssignmentUI(assignments: _assignments)
          else if (selectedTab == 'Weekly')
            WeeklyAssignmentUI(assignments: _assignments)
          else
            MonthlyAssignmentUI(assignments: _assignments),
        ],
      ),
    );
  }
}
