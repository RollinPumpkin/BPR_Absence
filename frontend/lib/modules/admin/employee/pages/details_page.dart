import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/modules/admin/employee/models/employee.dart';
import 'package:frontend/modules/admin/employee/pages/edit_page.dart';
import 'package:frontend/data/services/employee_service.dart';
import 'package:frontend/data/providers/user_provider.dart';
import 'package:intl/intl.dart';

class DetailsPage extends StatelessWidget {
  final Employee employee;
  const DetailsPage({super.key, required this.employee});

  String _fmtDate(DateTime? d) {
    if (d == null) return '—';
    // tampilkan mirip form: dd / mm / yyyy
    return '${d.day.toString().padLeft(2, '0')} / '
           '${d.month.toString().padLeft(2, '0')} / '
           '${d.year}';
  }

  String _val(String? s) => (s == null || s.trim().isEmpty) ? '—' : s.trim();

  // untuk masking/spasi nomor telepon agar rapi
  String _fmtPhone(String? s) {
    final v = _val(s);
    if (v == '—') return v;
    // sederhana: tambahkan spasi setiap 4-5 digit (biar kebaca)
    final digits = v.replaceAll(RegExp(r'\s+'), '');
    final parts = <String>[];
    for (var i = 0; i < digits.length; i += 4) {
      parts.add(digits.substring(i, i + 4 > digits.length ? digits.length : i + 4));
    }
    return parts.join(' ');
  }

  Future<void> _deleteEmployee(BuildContext context) async {
    if (employee.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete employee: No ID available'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
      return;
    }

    try {
      final response = await EmployeeService.deleteEmployee(employee.id!);
      
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Employee deleted successfully'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        
        // Refresh the employee list through UserProvider and go back
        if (context.mounted) {
          Provider.of<UserProvider>(context, listen: false).refreshUsers();
          Navigator.of(context).pop(); // Go back to employee list
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
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.pureWhite,
        foregroundColor: AppColors.neutral800,
        centerTitle: false,
        title: const Text(
          'Information Profile',
          style: TextStyle(
            color: AppColors.neutral800,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar + edit icon (dummy)
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowColor,
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person, size: 52, color: AppColors.neutral400),
                  ),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: Material(
                      color: AppColors.pureWhite,
                      shape: const CircleBorder(),
                      elevation: 0,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Change profile picture')),
                          );
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.dividerGray),
                          ),
                          child: const Icon(Icons.edit, size: 18, color: AppColors.accentBlue),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card detail
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionDivider(title: 'Personal Information'),
                  _DetailItem(label: 'Full Name', value: _val(employee.fullName)),
                  const _DividerLine(),
                  _DetailItem(label: 'Email', value: _val(employee.email)),
                  const _DividerLine(),
                  _DetailItem(label: 'Role', value: _val(employee.role)),
                  const _DividerLine(),
                  _DetailItem(label: 'Mobile Number', value: _fmtPhone(employee.mobileNumber)),
                  const _DividerLine(),
                  _DetailItem(label: 'Gender', value: _val(employee.gender)),
                  const _DividerLine(),
                  _DetailItem(label: 'Place of Birth', value: _val(employee.placeOfBirth)),
                  const _DividerLine(),
                  _DetailItem(
                    label: 'Date of Birth',
                    value: _fmtDate(employee.dateOfBirth),
                    icon: Icons.calendar_today,
                    iconColor: AppColors.darkBlue,
                  ),

                  const SizedBox(height: 8),
                  const _SectionDivider(title: 'Employment'),
                  _DetailItem(label: 'Position', value: _val(employee.position)),
                  const _DividerLine(),
                  _DetailItem(label: 'Contract Type', value: _val(employee.contractType)),
                  const _DividerLine(),
                  _DetailItem(label: 'Division', value: _val(employee.division)),
                  const _DividerLine(),
                  _DetailItem(label: 'Last Education', value: _val(employee.lastEducation)),

                  const SizedBox(height: 8),
                  const _SectionDivider(title: 'Other'),
                  _DetailItem(label: 'Warning Letter Type', value: _val(employee.warningLetterType ?? 'None')),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    foregroundColor: AppColors.pureWhite,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit', style: TextStyle(fontWeight: FontWeight.w700)),
                  onPressed: () async {
                    // Pass the employee data to EditPage for prefilling
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EditPage(employee: employee)),
                    );
                    
                    // If edit was successful, refresh the provider and pop back
                    if (result == true && context.mounted) {
                      Provider.of<UserProvider>(context, listen: false).refreshUsers();
                      // Pop back to employee list to show updated data
                      Navigator.of(context).pop();
                    }
                  },
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: AppColors.pureWhite,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        title: const Text(
                          'Confirm Delete',
                          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.neutral800),
                        ),
                        content: const Text(
                          'Are you sure you want to delete this employee?',
                          style: TextStyle(color: AppColors.neutral800),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel', style: TextStyle(color: AppColors.neutral800)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryRed,
                              foregroundColor: AppColors.pureWhite,
                              elevation: 0,
                            ),
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await _deleteEmployee(context);
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ===== Utilities konsisten dengan Add/Edit =====

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Divider(color: AppColors.dividerGray, height: 1),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  final String title;
  const _SectionDivider({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 6),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.neutral800,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(child: Divider(color: AppColors.dividerGray, height: 1)),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;

  const _DetailItem({
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      fontSize: 12,
      color: AppColors.neutral500,
      fontWeight: FontWeight.w700,
    );
    const valueStyle = TextStyle(
      fontSize: 14,
      color: AppColors.neutral800,
      fontWeight: FontWeight.w600,
      height: 1.35,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 2),
            child: Icon(icon, color: iconColor ?? AppColors.neutral400, size: 18),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: labelStyle),
              const SizedBox(height: 4),
              Text(value, style: valueStyle),
            ],
          ),
        ),
      ],
    );
  }
}
