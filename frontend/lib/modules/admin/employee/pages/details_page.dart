import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/modules/admin/employee/pages/edit_page.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

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
            // Avatar + edit
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
                          // opsional: buka ganti foto
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

            // Kartu detail
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
                children: const [
                  _DetailItem(label: 'First Name', value: 'Septa Puma Surya'),
                  _DividerLine(),
                  _DetailItem(label: 'Last Name', value: 'Surya'),
                  _DividerLine(),
                  _DetailItem(
                    label: 'Date of Birth',
                    value: '22 / 05 / 2004',
                    icon: Icons.calendar_today,
                    iconColor: AppColors.darkBlue,
                  ),
                  _DividerLine(),
                  _DetailItem(label: 'Place of Birth', value: 'DKI Jakarta 1'),
                  _DividerLine(),
                  _DetailItem(label: 'NIK', value: '22323233746474876382393'),
                  _DividerLine(),
                  _DetailItem(label: 'Gender', value: 'Male'),
                  _DividerLine(),
                  _DetailItem(label: 'Mobile Number', value: '+62174844749043'),
                  _DividerLine(),
                  _DetailItem(label: 'Last Education', value: 'Vocational High School'),
                  _DividerLine(),
                  _DetailItem(label: 'Contract Type', value: '3 Months'),
                  _DividerLine(),
                  _DetailItem(label: 'Position', value: 'Employee'),
                  _DividerLine(),
                  _DetailItem(label: 'Devision', value: 'Technology'),
                  _DividerLine(),
                  _DetailItem(label: 'Bank', value: 'Bank Central Asia (BCA)'),
                  _DividerLine(),
                  _DetailItem(label: 'Account Number', value: '5362728301239437'),
                  _DividerLine(),
                  _DetailItem(label: "Account Holder's Name", value: 'Septa Puma Surya'),
                  _DividerLine(),
                  _DetailItem(label: 'Warning Letter Type', value: 'None'),
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditPage()),
                    );
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
                            onPressed: () {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Employee deleted'),
                                  backgroundColor: AppColors.primaryRed,
                                ),
                              );
                              // TODO: delete action
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
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.neutral500,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.neutral800,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
