import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/custom_bottom_nav_router.dart';
import 'package:frontend/modules/admin/shared/admin_nav_items.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/data/services/assignment_service.dart';
import 'package:frontend/data/models/assignment.dart';
import 'package:frontend/utils/diagnostic_service.dart';
import 'package:frontend/core/services/realtime_service.dart';
import 'dart:async';

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
  final RealtimeService _realtimeService = RealtimeService();
  
  StreamSubscription? _assignmentsSubscription;
  List<Assignment> _assignments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeRealtime();
  }

  Future<void> _initializeRealtime() async {
    await _realtimeService.initialize();
    _realtimeService.startAssignmentsListener();
    
    _assignmentsSubscription = _realtimeService.assignmentsStream.listen((assignmentsData) {
      if (mounted) {
        setState(() {
          _assignments = assignmentsData.map((data) => Assignment.fromJson(data)).toList();
          _isLoading = false;
        });
        print('🔄 Admin Assignments: Realtime updated (${assignmentsData.length} assignments)');
      }
    });
  }

  @override
  void dispose() {
    _assignmentsSubscription?.cancel();
    _realtimeService.stopAllListeners();
    super.dispose();
  }

  Future<void> _loadAssignments({bool forceRefresh = false}) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
        _assignments = []; // Clear old data first
      });

      print('[REFRESH] _loadAssignments called (forceRefresh: $forceRefresh)');
      print('[ADMIN] Starting to load assignments...');
      
      // Try to get assignments from API first
      List<Assignment> assignments = [];
      
      try {
        // Debug API connection first (only if not force refresh)
        if (!forceRefresh) {
          print('🔍 ADMIN: Running API debug check...');
          await _assignmentService.debugApiCall();
        }
        
        // Try to get all assignments (admin should see all assignments)
        print('📋 ADMIN: Getting all assignments (forceRefresh: $forceRefresh)...');
        assignments = await _assignmentService.getAllAssignments(forceRefresh: forceRefresh);
        
        print('📋 ADMIN: Loaded ${assignments.length} assignments from Firestore');
        
        // If we got assignments, show some details
        if (assignments.isNotEmpty) {
          print('📋 ADMIN: First assignment: ${assignments.first.title}');
          print('📋 ADMIN: Assignment statuses: ${assignments.map((a) => a.status).toSet().toList()}');
        }
        
      } catch (apiError) {
        print('❌ ADMIN API Error: $apiError');
        print('❌ ADMIN Error type: ${apiError.runtimeType}');
        // Set error for display but still use empty list
        _error = 'Failed to load assignments from database: $apiError';
        assignments = [];
      }

      if (mounted) {
        setState(() {
          _assignments = List.from(assignments); // Create new list instance
          _isLoading = false;
        });
      }
      
      print('📋 ADMIN: Final state - ${assignments.length} assignments loaded');
      
    } catch (e, stackTrace) {
      print('❌ ADMIN: Error loading assignments: $e');
      print('❌ ADMIN: Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _error = 'Error loading assignments: $e';
          _isLoading = false;
          _assignments = [];
        });
      }
    }
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
            const AssignmentSummaryChart(period: 'Weekly'),
            const SizedBox(height: 12),
          ],

          // Konten sesuai tab dengan data real
          if (selectedTab == 'Daily')
            DailyAssignmentUI(assignments: _assignments)
          else if (selectedTab == 'Weekly')
            WeeklyAssignmentUI(assignments: _assignments)
          else
            MonthlyAssignmentUI(
              assignments: _assignments,
              onRefreshNeeded: () => _loadAssignments(forceRefresh: true),
            ),
        ],
      ),
    );
  }
}
