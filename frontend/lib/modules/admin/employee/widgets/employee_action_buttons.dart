import 'package:flutter/material.dart';
import 'package:frontend/modules/admin/employee/pages/add_data_page.dart';

class EmployeeActionButtons extends StatelessWidget {
  const EmployeeActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.filter_list),
          label: const Text("Filter"),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () {},
          child: const Text("Import"),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {},
          child: const Text("Export"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
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
