import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/custom_bottom_nav_router.dart';
import 'package:frontend/modules/admin/shared/admin_nav_items.dart';
import 'package:frontend/core/constants/colors.dart';

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

      bottomNavigationBar: CustomBottomNavRouter(
        currentIndex: 0,
        items: AdminNavItems.items,
      ),
    );
  }
}
