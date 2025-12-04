import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/modules/admin/employee/pages/add_data_page.dart';
import 'package:frontend/data/providers/user_provider.dart';
import 'package:frontend/data/services/employee_excel_service.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/modules/admin/employee/widgets/employee_filter.dart';

class EmployeeActionButtons extends StatelessWidget {
  const EmployeeActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Filter (netral, outline)
        OutlinedButton.icon(
          onPressed: () {
            _showFilterDialog(context);
          },
          icon: const Icon(Icons.filter_list, size: 18),
          label: const Text('Filter'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.neutral800,
            side: const BorderSide(color: AppColors.dividerGray),
            backgroundColor: AppColors.backgroundGray,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),

        // Import (hijau)
        ElevatedButton.icon(
          onPressed: () {
            _showImportDialog(context);
          },
          icon: const Icon(Icons.file_upload_outlined, size: 18),
          label: const Text('Import'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: AppColors.pureWhite,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            elevation: 0,
          ),
        ),

        // Export (merah) -> Excel
        ElevatedButton.icon(
          onPressed: () => _exportEmployeesToExcel(context),
          icon: const Icon(Icons.file_download_outlined, size: 18),
          label: const Text('Export'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryRed,
            foregroundColor: AppColors.pureWhite,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            elevation: 0,
          ),
        ),

        // Add Data (biru)
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEmployeePage()),
            );
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Data'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: AppColors.pureWhite,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  // Show filter dialog
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const EmployeeFilter(),
    );
  }

  // Show import dialog
  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Employees'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose an option to import employee data:'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _downloadTemplate(context);
                },
                icon: const Icon(Icons.download),
                label: const Text('Download Template'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _importFromExcel(context);
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Excel File'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Export employees to Excel
  Future<void> _exportEmployeesToExcel(BuildContext context) async {
    try {
      print('🔵 EXPORT: Starting export process...');
      
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final employees = userProvider.users;

      print('🔵 EXPORT: Found ${employees.length} employees');

      if (employees.isEmpty) {
        Navigator.pop(context); // Hide loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No employee data to export'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final excelService = EmployeeExcelService();
      print('🔵 EXPORT: Calling Excel service...');
      final response = await excelService.exportEmployeesToExcel(employees);

      Navigator.pop(context); // Hide loading
      print('🔵 EXPORT: Excel service response: ${response.success} - ${response.message}');

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Export successful'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Export failed'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    } catch (e) {
      print('🔴 EXPORT: Exception: $e');
      Navigator.pop(context); // Hide loading if still showing
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export error: $e'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }

  // Download import template
  Future<void> _downloadTemplate(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final excelService = EmployeeExcelService();
      final response = await excelService.generateImportTemplate();

      Navigator.pop(context);

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Template downloaded'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Download failed'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download error: $e'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }

  // Import from Excel
  Future<void> _importFromExcel(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final excelService = EmployeeExcelService();
      final importResponse = await excelService.importEmployeesFromExcel();

      Navigator.pop(context);

      if (!importResponse.success || importResponse.data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(importResponse.message ?? 'Import failed'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
        return;
      }

      final importedEmployees = importResponse.data!;
      
      // Show preview dialog
      _showImportPreviewDialog(context, importedEmployees);

    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import error: $e'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }

  // Show import preview dialog
  void _showImportPreviewDialog(BuildContext context, List<User> employees) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Import Preview (${employees.length} employees)'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final emp = employees[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(emp.fullName[0].toUpperCase()),
                ),
                title: Text(emp.fullName),
                subtitle: Text('${emp.email} • ${emp.role}'),
                trailing: Icon(
                  emp.isActive ? Icons.check_circle : Icons.cancel,
                  color: emp.isActive ? Colors.green : Colors.red,
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveImportedEmployees(context, employees);
            },
            child: const Text('Save to Database'),
          ),
        ],
      ),
    );
  }

  // Save imported employees
  Future<void> _saveImportedEmployees(BuildContext context, List<User> employees) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final excelService = EmployeeExcelService();
      final saveResponse = await excelService.saveImportedEmployees(employees);

      Navigator.pop(context);

      if (saveResponse.success) {
        // Refresh employee list
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.refreshUsers();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(saveResponse.message ?? 'Import completed'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(saveResponse.message ?? 'Save failed'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save error: $e'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }
}
