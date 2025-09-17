import 'package:flutter/material.dart';
import 'widgets/employee_stat_section.dart';
import 'widgets/employee_action_buttons.dart';
import 'widgets/employee_search.dart';
import 'widgets/employee_card.dart';

class EmployeePage extends StatelessWidget {
  const EmployeePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee Database"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Statistik Section
            const EmployeeStatSection(),
            const SizedBox(height: 16),

            /// Action Buttons (Filter, Import, Export, Add New)
            const EmployeeActionButtons(),
            const SizedBox(height: 12),

            /// Search
            const EmployeeSearch(),
            const SizedBox(height: 16),

            /// Employee Cards
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
