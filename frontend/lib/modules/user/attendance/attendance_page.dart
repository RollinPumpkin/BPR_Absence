import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/custom_bottom_nav.dart';
import 'package:frontend/modules/user/dashboard/dashboard_page.dart';
import 'package:frontend/modules/user/assignment/assignment_page.dart';
import 'package:frontend/modules/user/letter/letter_page.dart';
import 'package:frontend/modules/user/profile/profile_page.dart';

import 'widgets/clock_in_out_card.dart';
import 'widgets/attendance_history_card.dart';
import 'widgets/attendance_stats.dart';

class UserAttendancePage extends StatelessWidget {
  const UserAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "My Attendance",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// Clock In/Out Section
            Padding(
              padding: EdgeInsets.all(16),
              child: ClockInOutCard(),
            ),

            /// Attendance Stats
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: AttendanceStats(),
            ),
            const SizedBox(height: 20),

            /// History Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent History",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text("View All"),
                  ),
                ],
              ),
            ),

            /// History List
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return AttendanceHistoryCard(
                  date: "January ${18 - index}, 2025",
                  clockIn: "08:30 AM",
                  clockOut: index == 0 ? "-" : "17:30 PM",
                  status: index == 0 ? "Working" : "Completed",
                  statusColor: index == 0 ? Colors.green : Colors.blue,
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1,
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
