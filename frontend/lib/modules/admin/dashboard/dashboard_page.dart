import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/widgets/custom_bottom_nav_router.dart';
import 'package:frontend/modules/admin/shared/admin_nav_items.dart';

import 'widgets/header.dart';
import 'widgets/menu_button.dart';
import 'widgets/section_title.dart';
import 'widgets/letter/letter_card.dart';
import 'widgets/assignment/assignment_card.dart';
import 'widgets/attendance/attendance_card.dart';
import 'widgets/attendance/attendance_chart.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,

      body: SafeArea(
        top: true,
        bottom: false, 
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashboardHeader(),
              const SizedBox(height: 20),

              // Menu
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MenuButton(
                      icon: Icons.people,
                      label: "Employee Data",
                      color: AppColors.primaryRed,
                      onTap: () => Navigator.pushNamed(context, '/admin/employees'),
                    ),
                    MenuButton(
                      icon: Icons.book,
                      label: "Report",
                      color: AppColors.primaryGreen,
                      onTap: () => Navigator.pushNamed(context, '/admin/report'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // LETTERS (ringkas)
              SectionTitle(
                title: "Letter",
                action: "View",
                onTap: () => showSectionListModal(
                  context,
                  title: "All Letters",
                  children: const [
                    LetterCard(
                      name: "Nurhaliza Anindya",
                      status: "Absence",
                      statusColor: AppColors.primaryRed,
                      dateText: "02 September 2024",
                      category: "Annual Leave",
                      summary: "Izin cuti tahunan 2 hari karena perjalanan keluarga.",
                      stageText: "Approved",
                    ),
                    LetterCard(
                      name: "Septa Puma",
                      status: "Absence",
                      statusColor: AppColors.primaryRed,
                      dateText: "02 September 2024",
                      category: "Annual Leave",
                      summary: "Izin cuti tahunan 2 hari karena perjalanan keluarga.",
                      stageText: "Approved",
                    ),
                  ],
                ),
              ),
              const LetterCard(
                name: "Nurhaliza Anindya",
                status: "Absence",
                statusColor: AppColors.primaryRed,
                dateText: "02 September 2024",
                category: "Annual Leave",
                summary: "Izin cuti tahunan 2 hari karena perjalanan keluarga.",
                stageText: "Approved",
              ),
              const LetterCard(
                name: "Septa Puma",
                status: "Absence",
                statusColor: AppColors.primaryRed,
                dateText: "02 September 2024",
                category: "Annual Leave",
                summary: "Izin cuti tahunan 2 hari karena perjalanan keluarga.",
                stageText: "Approved",
              ),
              const SizedBox(height: 12),

              // ASSIGNMENT (ringkas)
              SectionTitle(
                title: "Assignment",
                action: "View",
                onTap: () => showSectionListModal(
                  context,
                  title: "All Assignments",
                  children: const [
                    AssignmentCard(
                      name: "Septa Puma",
                      status: "In Progress",
                      date: "27 Agustus 2024",
                      note: "Doctor’s Note",
                      description:
                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                    ),
                    AssignmentCard(
                      name: "Septa Puma",
                      status: "Assigned",
                      date: "27 Agustus 2024",
                      note: "Doctor’s Note",
                      description:
                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const AssignmentCard(
                name: "Septa Puma",
                status: "In Progress",
                date: "27 Agustus 2024",
                note: "Doctor’s Note",
                description:
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
              ),
              const AssignmentCard(
                name: "Septa Puma",
                status: "Assigned",
                date: "27 Agustus 2024",
                note: "Doctor’s Note",
                description:
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
              ),
              const SizedBox(height: 12),

              // ATTENDANCE (ringkas)
              SectionTitle(
                title: "Attendance",
                action: "View",
                onTap: () => showSectionListModal(
                  context,
                  title: "Attendance",
                  children: [
                    AttendanceCard(
                      title: "Attendance (Weekly)",
                      chart: AttendanceChart(
                        data: [9, 11, 5, 10, 8, 6, 3],
                        labels: ['S', 'S', 'R', 'K', 'J', 'S', 'M'],
                        barWidth: 16,
                        aspectRatio: 1.9,
                      ),
                      present: 132,
                      absent: 14,
                      lateCount: 9,
                    ),
                  ],
                ),
              ),
              AttendanceCard(
                title: "Attendance",
                chart: AttendanceChart(
                  data: [9, 11, 5, 10, 8, 6, 3],
                  labels: ['S', 'S', 'R', 'K', 'J', 'S', 'M'],
                  barWidth: 16,
                  aspectRatio: 1.9,
                ),
                present: 132,
                absent: 14,
                lateCount: 9,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const SafeArea(
        top: false,
        child: CustomBottomNavRouter(
          currentIndex: 0,
          items: AdminNavItems.items,
        ),
      ),
    );
  }
}
