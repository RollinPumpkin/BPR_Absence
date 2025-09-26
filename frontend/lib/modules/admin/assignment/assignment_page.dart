import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/custom_bottom_nav_router.dart';
import 'package:frontend/modules/admin/shared/admin_nav_items.dart';
import 'package:frontend/core/constants/colors.dart';

// Widgets assignment
import 'widgets/assignment_tab_switcher.dart';
import 'widgets/daily/daily_assignment_ui.dart';
import 'widgets/weekly/weekly_assignment_ui.dart';
import 'widgets/monthly/monthly_assignment_ui.dart';
import 'widgets/assignment_summary_chart.dart';

class AssignmentPage extends StatefulWidget {
  const AssignmentPage({super.key});

  @override
  State<AssignmentPage> createState() => _AssignmentPageState();
}

class _AssignmentPageState extends State<AssignmentPage> {
  String selectedTab = 'Monthly';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,

      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: const Text(
          'Assignments',
          style: TextStyle(
            color: AppColors.neutral800,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tab switcher
            AssignmentTabSwitcher(
              selected: selectedTab,
              onChanged: (val) => setState(() => selectedTab = val),
            ),
            const SizedBox(height: 12),

            // Tampilkan chart saat Weekly
            if (selectedTab == 'Weekly') ...[
              AssignmentSummaryChart(period: 'Weekly'),
              const SizedBox(height: 12),
            ],

            // Konten sesuai tab
            if (selectedTab == 'Daily')
              const DailyAssignmentUI()
            else if (selectedTab == 'Weekly')
              const WeeklyAssignmentUI()
            else
              const MonthlyAssignmentUI(),
          ],
        ),
      ),

      bottomNavigationBar: const CustomBottomNavRouter(
        currentIndex: 2,
        items: AdminNavItems.items,
      ),
    );
  }
}
