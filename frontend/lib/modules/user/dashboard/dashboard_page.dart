import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/custom_bottom_nav.dart';
import 'package:frontend/modules/user/attendance/attendance_page.dart';
import 'package:frontend/modules/user/assignment/assignment_page.dart';
import 'package:frontend/modules/user/letter/letter_page.dart';
import 'package:frontend/modules/user/profile/profile_page.dart';

import 'widgets/user_header.dart';
import 'widgets/quick_action_button.dart';
import 'widgets/section_title.dart';
import 'widgets/recent_activity_card.dart';
import 'widgets/attendance_summary_card.dart';

class UserDashboardPage extends StatelessWidget {
  const UserDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// Body
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            const UserHeader(),
            const SizedBox(height: 20),

            /// Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  QuickActionButton(
                    icon: Icons.access_time,
                    label: "Clock In/Out",
                    color: Colors.green,
                  ),
                  QuickActionButton(
                    icon: Icons.assignment,
                    label: "My Tasks",
                    color: Colors.blue,
                  ),
                  QuickActionButton(
                    icon: Icons.mail_outline,
                    label: "Submit Letter",
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            /// Today's Attendance Summary
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: AttendanceSummaryCard(),
            ),
            const SizedBox(height: 20),

            /// Recent Activities Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SectionTitle(
                title: "Recent Activities",
                action: "View All",
              ),
            ),
            const SizedBox(height: 12),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: RecentActivityCard(
                title: "Checked In",
                description: "Successfully checked in at office",
                time: "08:30 AM",
                icon: Icons.login,
                iconColor: Colors.green,
              ),
            ),
            const SizedBox(height: 8),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: RecentActivityCard(
                title: "Task Completed",
                description: "Weekly Report submitted",
                time: "Yesterday",
                icon: Icons.check_circle,
                iconColor: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: RecentActivityCard(
                title: "Leave Request",
                description: "Annual leave request approved",
                time: "2 days ago",
                icon: Icons.event_available,
                iconColor: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),

      /// Bottom Navigation
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
        icons: const [
          Icons.home,
          Icons.access_time,
          Icons.assignment,
          Icons.mail_outline,
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
