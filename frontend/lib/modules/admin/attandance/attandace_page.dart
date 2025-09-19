import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/custom_bottom_nav.dart';
import 'package:frontend/core/constants/colors.dart';

import 'package:frontend/modules/admin/dashboard/dashboard_page.dart';
import 'package:frontend/modules/admin/assigment/assigment_page.dart';
import 'package:frontend/modules/admin/letter/letter_page.dart';
import 'package:frontend/modules/admin/profile/profile_page.dart';
import 'widgets/date_row.dart';
import 'widgets/attendance_stat.dart';
import 'widgets/divider.dart';
import 'widgets/attendance_card.dart';
import 'widgets/attendance_form_page.dart';

class AttandancePage extends StatelessWidget {
  const AttandancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Attendance",
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
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const DateRow(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AttendanceStat(
                        label: "Clock In",
                        value: "208",
                        color: AppColors.primaryGreen,
                      ),
                      VerticalDividerCustom(),
                      AttendanceStat(
                        label: "Late",
                        value: "15",
                        color: AppColors.primaryRed,
                      ),
                      VerticalDividerCustom(),
                      AttendanceStat(
                        label: "Sick",
                        value: "15",
                        color: AppColors.primaryYellow,
                      ),
                      VerticalDividerCustom(),
                      AttendanceStat(
                        label: "Annual Leave",
                        value: "15",
                        color: AppColors.gradientBlue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Bagian Judul + Tombol + Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Data",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),

                  // Row Tombol
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.filter_list, size: 18),
                          label: const Text("Filter"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRed,
                          ),
                          child: const Text("Export"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // pindah ke halaman baru
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AttendanceFormPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                          ),
                          child: const Text("Add Data"),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search Employee",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const AttendanceCard(
              name: "Septa Puma",
              division: "IT Divisi",
              status: "Clock In",
              statusColor: AppColors.primaryGreen,
              clockIn: "07:45:56",
              clockOut: "Count",
              date: "18 Januari 2025",
            ),
            const AttendanceCard(
              name: "Septa Puma",
              division: "IT Divisi",
              status: "Late",
              statusColor: AppColors.primaryRed,
              clockIn: "09:45:56",
              clockOut: "-",
              date: "18 Januari 2025",
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1,
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
