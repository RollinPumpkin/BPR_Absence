import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

import 'widgets/employee_stat_section.dart';
import 'widgets/employee_action_buttons.dart';
import 'widgets/employee_search.dart';
import 'widgets/employee_card.dart';

class EmployeePage extends StatelessWidget {
  const EmployeePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,

      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.neutral800),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          splashRadius: 20,
        ),
        title: const Text(
          'Employee Database',
          style: TextStyle(
            color: AppColors.neutral800,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

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

            // contoh list karyawan
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
