import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/custom_bottom_nav.dart';
import 'package:frontend/core/constants/colors.dart';

import 'package:frontend/modules/admin/employee/employee_page.dart';
import 'package:frontend/modules/admin/attandance/attandace_page.dart';
import 'package:frontend/modules/admin/assigment/assigment_page.dart';
import 'package:frontend/modules/admin/letter/letter_page.dart';
import 'package:frontend/modules/admin/profile/profile_page.dart';

import 'widgets/header.dart';
import 'widgets/menu_button.dart';
import 'widgets/section_title.dart';
import 'widgets/letter_card.dart';
import 'widgets/assignment_card.dart';
import 'widgets/attendance_card.dart';
import 'widgets/attendance_chart.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

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
            const DashboardHeader(),
            const SizedBox(height: 20),

            /// Menu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MenuButton(
                    icon: Icons.people,
                    label: "Employee Data",
                    color: AppColors.primaryRed,
                    onTap: () {
                      Navigator.pushNamed(context, '/admin/employees');
                    },
                  ),

                  const MenuButton(
                    icon: Icons.book,
                    label: "Report",
                    color: AppColors.primaryGreen,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            /// Letter Section
            const SectionTitle(title: "Letter", action: "View"),
            const LetterCard(
              name: "Septa Puma",
              status: "Absence",
              statusColor: AppColors.primaryYellow,
            ),
            const LetterCard(
              name: "Septa Puma",
              status: "Absence",
              statusColor: AppColors.primaryRed,
            ),
            const SizedBox(height: 12),

            /// Assignment Section
            const SectionTitle(title: "Assignment", action: "View"),
            AssignmentCard(
              name: "Septa Puma",
              status: "Assigned",
              date: "27 Agustus 2024",
              note: "Doctor’s Note",
              description:
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            ),
            const SizedBox(height: 12),
            AssignmentCard(
              name: "Septa Puma",
              status: "Assigned",
              date: "27 Agustus 2024",
              note: "Doctor’s Note",
              description:
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            ),

            /// Attendance Section
            const AttendanceCard(title: "Attendance", chart: AttendanceChart()),
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
          Icons.mail_outline,
          Icons.person_outline,
        ],
        pages: const [
          AdminDashboardPage(),
          AttandancePage(),
          AssigmentPage(),
          LetterPage(),
          ProfilePage(),
        ],
      ),
    );
  }
}
