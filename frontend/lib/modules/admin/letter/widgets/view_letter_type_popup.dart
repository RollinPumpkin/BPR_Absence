import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'edit_letter_type_popup.dart';

class ViewLetterTypePopup extends StatelessWidget {
  const ViewLetterTypePopup({super.key});

  @override
  Widget build(BuildContext context) {
    // contoh data: name + contents
    final List<Map<String, String>> letterTypes = [
      {
        'name': "Doctor's Note",
        'contents': "This is to certify that the bearer is under my care."
      },
      {
        'name': "Permission Letter",
        'contents': "Please grant permission for the employee due to family matters."
      },
      {
        'name': "Business Trip Letter",
        'contents': "Employee is assigned to a business trip for official duties."
      },
    ];

    return Dialog(
      backgroundColor: AppColors.pureWhite,         
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: const [
                  Expanded(
                    child: Text(
                      'View Letter Types',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.neutral800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Divider(color: AppColors.dividerGray, height: 1),
              const SizedBox(height: 12),

              // List (scrollable tinggi tetap)
              SizedBox(
                height: 380,
                child: ListView.separated(
                  itemCount: letterTypes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = letterTypes[index];
                    final name = item['name'] ?? '-';
                    final contents = item['contents'] ?? '';

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.dividerGray),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadowColor,
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.mail_outline, color: AppColors.neutral500),
                          const SizedBox(width: 10),
                          // title + preview contents
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.neutral800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  contents,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.neutral500,
                                    height: 1.35,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // actions: view, edit, delete
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'View',
                                icon: const Icon(Icons.visibility_outlined,
                                    color: AppColors.primaryBlue),
                                onPressed: () => _showContents(context, name, contents),
                              ),
                              IconButton(
                                tooltip: 'Edit',
                                icon: const Icon(Icons.edit, color: AppColors.primaryYellow),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => EditLetterTypePopup(
                                      initialName: name,
                                      initialContent: contents,
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                tooltip: 'Delete',
                                icon: const Icon(Icons.delete, color: AppColors.primaryRed),
                                onPressed: () => _confirmDelete(context, name),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(foregroundColor: AppColors.neutral800),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContents(BuildContext context, String name, String contents) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.neutral800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.neutral800),
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Divider(color: AppColors.dividerGray, height: 1),
              const SizedBox(height: 12),
              Text(
                contents,
                style: const TextStyle(
                  color: AppColors.neutral800,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String name) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Letter Type'),
            content: Text("Are you sure you want to delete '$name'?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: AppColors.pureWhite,
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Deleted $name"),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }
}
