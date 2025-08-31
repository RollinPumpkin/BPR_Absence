import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/custom_bottom_nav.dart';
import 'package:frontend/modules/admin/dashboard/dashboard_page.dart';
import 'package:frontend/modules/admin/attandance/attandace_page.dart';
import 'package:frontend/modules/admin/letter/letter_page.dart';
import 'package:frontend/modules/admin/profile/profile_page.dart';

// Widgets assignment
import 'widgets/assignment_tab_switcher.dart';
import 'widgets/daily_assignment_ui.dart';
import 'widgets/weekly_assignment_ui.dart';
import 'widgets/monthly_assignment_ui.dart';

class AssigmentPage extends StatefulWidget {
  const AssigmentPage({super.key});

  @override
  State<AssigmentPage> createState() => _AssigmentPageState();
}

class _AssigmentPageState extends State<AssigmentPage> {
  String selectedTab = "Monthly";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Assignment")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Tab Switcher
            AssignmentTabSwitcher(
              selected: selectedTab,
              onChanged: (val) {
                setState(() {
                  selectedTab = val;
                });
              },
            ),
            const SizedBox(height: 16),

            // 🔹 Content berubah sesuai tab
            if (selectedTab == "Daily") const DailyAssignmentUI(),
            if (selectedTab == "Weekly") const WeeklyAssignmentUI(),
            if (selectedTab == "Monthly") const MonthlyAssignmentUI(),
          ],
        ),
      ),

      // 🔹 Bottom Navigation
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 2,
        icons: const [
          Icons.home,
          Icons.calendar_today,
          Icons.check_box,
          Icons.mail_outline,
          Icons.person_outline,
        ],
        pages: [
          const AdminDashboardPage(),
          const AttandancePage(),
          const AssigmentPage(), // ⚠️ jangan recursive import
          const LetterPage(),
          const ProfilePage(),
        ],
      ),
    );
  }
}
