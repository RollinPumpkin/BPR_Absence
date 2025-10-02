import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/modules/admin/employee/pages/edit_page.dart';
import 'package:frontend/modules/admin/employee/pages/details_page.dart';
import 'package:frontend/modules/admin/employee/models/employee.dart';

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

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            'Confirm Delete',
            style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.neutral800),
          ),
          content: const Text(
            "Are you sure you want to delete this employee?",
            style: TextStyle(color: AppColors.neutral800),
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.neutral800),
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: AppColors.pureWhite,
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context);
                // TODO: delete logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Employee deleted'),
                    backgroundColor: AppColors.primaryRed,
                  ),
                );
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Instance Employee dari data yang ada di kartu
    final emp = Employee(
      fullName: name,
      division: division,
      position: position,
      mobileNumber: phone,
      // field lain boleh diisi saat punya data
    );

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsPage(employee: emp),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header: Avatar + Nama + Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.neutral300,
                    child: Icon(Icons.person, size: 32, color: AppColors.pureWhite),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColors.neutral800,
                                ),
                              ),
                            ),
                            Text(
                              status,
                              style: const TextStyle(
                                color: AppColors.primaryGreen,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          division,
                          style: const TextStyle(
                            color: AppColors.neutral100,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// Position & Phone
              const Text(
                "Position",
                style: TextStyle(
                  color: AppColors.neutral100,
                  fontSize: 13,
                ),
              ),
              Text(
                position,
                style: const TextStyle(fontSize: 14, color: AppColors.neutral800),
              ),
              const SizedBox(height: 8),
              const Text(
                "Phone",
                style: TextStyle(
                  color: AppColors.neutral100,
                  fontSize: 13,
                ),
              ),
              Text(
                phone,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.black,
                ),
              ),

              const SizedBox(height: 12),

              /// Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: 'Export PDF',
                    icon: const Icon(Icons.picture_as_pdf, color: AppColors.primaryGreen),
                    onPressed: () {
                      // TODO: export pdf
                    },
                  ),
                  IconButton(
                    tooltip: 'Edit',
                    icon: const Icon(Icons.edit, color: AppColors.primaryYellow),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditPage(employee: emp),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete, color: AppColors.primaryRed),
                    onPressed: () => _showDeleteDialog(context),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
