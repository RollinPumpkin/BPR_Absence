import 'package:flutter/material.dart';
import 'package:frontend/modules/admin/employee/pages/edit_page.dart';
import 'package:frontend/modules/admin/employee/pages/details_page.dart'; // 👉 import DetailsPage

class EmployeeCard extends StatelessWidget {
  final String name;
  final String division;
  final String position;
  final String phone;
  final String status;

  const EmployeeCard({
    super.key,
    required this.name,
    required this.division,
    required this.position,
    required this.phone,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DetailsPage(), // 👉 ke details
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const CircleAvatar(radius: 24, child: Icon(Icons.person)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          status,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Text(division),
                    Text("Jabatan: $position"),
                    Text("No. Hp: $phone"),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.green),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditPage(),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
