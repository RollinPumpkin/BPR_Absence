import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/custom_bottom_nav.dart';
import 'package:frontend/modules/user/shared/user_navigation_constants.dart';

import 'widgets/attendance_stats.dart';
import 'widgets/attendance_chart.dart';
import 'widgets/attendance_history_card.dart';
import 'widgets/attendance_detail_dialog.dart';
import 'attendance_history_page.dart';

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
            /// Attendance Statistics
            Padding(
              padding: const EdgeInsets.all(16),
              child: AttendanceStats(),
            ),

            /// Total Attendance Report Chart - THE GRAPHIC YOU WANT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AttendanceChart(),
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AttendanceHistoryPage(),
                        ),
                      );
                    },
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
                String status;
                Color statusColor;
                String clockIn;
                
                if (index == 0) {
                  status = "Working";
                  statusColor = Colors.green;
                  clockIn = "08:30 AM";
                } else if (index == 1) {
                  status = "Late";
                  statusColor = Colors.orange;
                  clockIn = "08:45 AM";
                } else {
                  status = "Completed";
                  statusColor = Colors.blue;
                  clockIn = "08:30 AM";
                }
                
                return AttendanceHistoryCard(
                  date: "January ${18 - index}, 2025",
                  clockIn: clockIn,
                  clockOut: index == 0 ? "-" : "17:30 PM",
                  status: status,
                  statusColor: statusColor,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AttendanceDetailDialog(
                        date: "January ${18 - index}, 2025",
                        status: status,
                        checkIn: clockIn,
                        checkOut: index == 0 ? "-" : "17:30 PM",
                        workHours: index == 0 ? "-" : "8h 30m",
                        location: "Main Office",
                        address: "123 Business District, City Center",
                        lat: "40.7128",
                        long: "-74.0060",
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1,
        icons: UserNavigationConstants.icons,
        pages: UserNavigationConstants.pages,
      ),
    );
  }
}
