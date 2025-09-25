import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'assignment_detail_sheet.dart';

class AssignmentCard extends StatelessWidget {
  final String name;
  final String status;      // ex: todo | in_progress | in progress | done | overdue
  final String date;        // display string
  final String note;        // display string
  final String description; // short preview

  const AssignmentCard({
    super.key,
    required this.name,
    required this.status,
    required this.date,
    required this.note,
    required this.description,
  });

  Color _statusColor(String s) {
    final v = s.toLowerCase();
    if (v.contains('done')) return AppColors.primaryGreen;
    if (v.contains('progress')) return AppColors.primaryBlue;
    if (v.contains('overdue')) return AppColors.errorRed;
    if (v.contains('todo') || v.contains('pending')) return AppColors.primaryYellow;
    return AppColors.neutral500;
    }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(status);

    return Material(
      color: AppColors.pureWhite,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: AppColors.pureWhite,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (_) => AssignmentDetailSheet(
            name: name,
            status: status,
            date: date,
            note: note,
            description: description,
          ),
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
              // Name + Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.neutral800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Date + Note
              Text(
                "$date • $note",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.neutral500,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // Description preview
              Text(
                description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.neutral800,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
