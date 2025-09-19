import 'package:flutter/material.dart';

class EmployeeHeader extends StatelessWidget {
  const EmployeeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title and Setting Icon
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Employee Database",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
 ],
    );
  }
}
