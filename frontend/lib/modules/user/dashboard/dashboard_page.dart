import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/custom_bottom_nav.dart';
import 'package:frontend/modules/user/attendance/attendance_page.dart';
import 'package:frontend/modules/user/assignment/assignment_page.dart';
import 'package:frontend/modules/user/letter/letter_page.dart';
import 'package:frontend/modules/user/profile/profile_page.dart';

import 'widgets/user_header.dart';
import 'widgets/figma_clock_card.dart';
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
            /// Header
            const UserHeader(),
            
            const SizedBox(height: 20),

            /// Clock In/Out Card
            const FigmaClockCard(),
            
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

      /// Bottom Navigation
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
        icons: const [
          Icons.home,
          Icons.calendar_today,
          Icons.check_box,
          Icons.access_time,
          Icons.person_outline,
        ],
        pages: [
          UserDashboardPage(),
          UserAttendancePage(),
          UserAssignmentPage(),
          UserLetterPage(),
          UserProfilePage(),
        ],
      ),
    );
  }
}
