import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/custom_bottom_nav_router.dart';
import 'package:frontend/modules/user/shared/user_nav_items.dart';
import 'package:frontend/core/services/realtime_service.dart';

import 'widgets/user_header.dart';
import 'widgets/upcoming_tasks_widget.dart';
import 'widgets/activity_summary_widget.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  final RealtimeService _realtimeService = RealtimeService();

  @override
  void initState() {
    super.initState();
    _initializeRealtimeData();
  }

  Future<void> _initializeRealtimeData() async {
    await _realtimeService.initialize();
    _realtimeService.startAllListeners();
    print('🔄 User Dashboard: Realtime listeners started');
  }

  @override
  void dispose() {
    _realtimeService.stopAllListeners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      /// Body
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              /// Header with integrated clock card
              UserHeader(),

              SizedBox(height: 12),

              /// Upcoming Tasks
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: UpcomingTasksWidget(),
              ),

              SizedBox(height: 12),

              /// Activity Summary
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: ActivitySummaryWidget(),
              ),

              SizedBox(height: 80), // Extra space for bottom nav
            ],
          ),
        ),
      ),

      bottomNavigationBar: const CustomBottomNavRouter(
        currentIndex: 0,
        items: UserNavItems.items,
      ),
    );
  }
}
