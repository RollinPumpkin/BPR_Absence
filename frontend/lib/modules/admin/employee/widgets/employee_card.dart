import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/modules/admin/employee/pages/edit_page.dart';
import 'package:frontend/modules/admin/employee/pages/details_page.dart';
import 'package:frontend/modules/admin/employee/models/employee.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/services/employee_service.dart';
import 'package:frontend/data/providers/user_provider.dart';

class EmployeeCard extends StatelessWidget {
  final User user;

  const EmployeeCard({
    super.key,
    required this.user,
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
              onPressed: () async {
                Navigator.pop(context);
                await _deleteEmployee(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteEmployee(BuildContext context) async {
    if (user.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete employee: No ID available'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
      return;
    }

    try {
      final response = await EmployeeService.deleteEmployee(user.id!);
      
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Employee deleted successfully'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        
        // Refresh the employee list through UserProvider
        if (context.mounted) {
          Provider.of<UserProvider>(context, listen: false).refreshUsers();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Failed to delete employee'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting employee: $e'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Convert User object to Employee object with all available data
    final emp = Employee(
      id: user.id,  // Add user ID
      fullName: user.fullName,
      email: user.email,
      role: user.role,
      mobileNumber: user.phone,
      gender: user.gender,
      placeOfBirth: user.placeOfBirth,  // Now use correct field
      dateOfBirth: user.dateOfBirth,
      position: user.position,
      department: user.department,
      division: user.department, // Note: User model uses department, Employee uses division
      contractType: user.contractType,  // Now available
      lastEducation: user.lastEducation, // Now available
      emergencyContact: user.emergencyContact, // Add emergency contact mapping
      // Note: Some fields still might not be available in User model
      // nik: user.nationalId, // Map if needed
      // bank: user.bankName,
      // accountHolderName: user.fullName, // Assumption
      // accountNumber: user.bankAccount,
      warningLetterType: 'None', // Default for existing users
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
                                user.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColors.neutral800,
                                ),
                              ),
                            ),
                            Text(
                              user.status,
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
                          user.department ?? 'Unknown Division',
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
                user.position ?? 'Unknown Position',
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
                user.phone ?? 'No Phone',
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
