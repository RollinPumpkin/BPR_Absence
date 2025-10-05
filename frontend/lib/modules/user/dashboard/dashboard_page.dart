import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/custom_bottom_nav_router.dart';
import 'package:frontend/modules/user/shared/user_nav_items.dart';

import 'widgets/user_header.dart';
import 'widgets/upcoming_tasks_widget.dart';
import 'widgets/activity_summary_widget.dart';

class UserDashboardPage extends StatelessWidget {
  const UserDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      /// Body
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header with integrated clock card
            const UserHeader(),

            const SizedBox(height: 20),

            /// Upcoming Tasks
            const UpcomingTasksWidget(),

            const SizedBox(height: 20),

            /// Activity Summary
            const ActivitySummaryWidget(),

            const SizedBox(height: 20),
          ],
        ),
      ),

      bottomNavigationBar: CustomBottomNavRouter(
        currentIndex: 0,
        items: UserNavItems.items,
      ),
    );
  }
}
