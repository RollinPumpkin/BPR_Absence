import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/modules/admin/employee/pages/add_data_page.dart';

class EmployeeActionButtons extends StatelessWidget {
  const EmployeeActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            foregroundColor: AppColors.black,
            backgroundColor: AppColors.transparent
          ),
          onPressed: () {},
          icon: const Icon(Icons.filter_list),
          label: const Text("Filter"),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: AppColors.pureWhite,
            backgroundColor: AppColors.primaryGreen
          ),
          onPressed: () {},
          child: const Text("Import"),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: AppColors.pureWhite,
            backgroundColor: AppColors.primaryRed
          ),
          onPressed: () {},
          child: const Text("Export"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: AppColors.pureWhite,
            backgroundColor: AppColors.primaryBlue
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddEmployeePage(),
              ),
            );
          },
          child: const Text("Add Data"),
        ),
      ],
    );
  }
}
