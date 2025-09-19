import 'package:flutter/material.dart';
import 'widgets/employee_stat_section.dart';
import 'widgets/employee_action_buttons.dart';
import 'widgets/employee_search.dart';
import 'widgets/employee_card.dart';
import 'package:frontend/core/widgets/custoom_app_bar.dart';

class EmployeePage extends StatelessWidget {
  const EmployeePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
    );
  }
}
