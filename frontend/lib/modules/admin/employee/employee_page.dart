import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/custom_bottom_nav.dart';

import 'package:frontend/core/widgets/custoom_app_bar.dart';
import 'package:frontend/modules/admin/dashboard/dashboard_page.dart';
import 'package:frontend/modules/admin/attandance/attandace_page.dart';
import 'package:frontend/modules/admin/assigment/assigment_page.dart';
import 'package:frontend/modules/admin/employee/widgets/employee_header.dart';
import 'package:frontend/modules/admin/letter/letter_page.dart';
import 'package:frontend/modules/admin/profile/profile_page.dart';

import 'widgets/employee_header.dart';
import 'widgets/employee_stat_section.dart';
import 'widgets/employee_action_buttons.dart';
import 'widgets/employee_search.dart';
import 'widgets/employee_card.dart';

class EmployeePage extends StatelessWidget {
  const EmployeePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EmployeeHeader(),
            const EmployeeStatSection(),
            const SizedBox(height: 16),
            const EmployeeActionButtons(),
            const SizedBox(height: 12),
            const EmployeeSearch(),
            const SizedBox(height: 16),
            Column(
              children: List.generate(
                2,
                (index) => const EmployeeCard(
                  name: "Septa Puma",
                  division: "IT Divisi",
                  position: "Manager",
                  phone: "+62 73832",
                  status: "Active",
                ),
              ),
            ),
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
