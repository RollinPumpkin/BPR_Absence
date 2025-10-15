import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/data/models/assignment.dart';
import '../../pages/detail_assignment_page.dart';

class AssignmentCard extends StatelessWidget {
  final Assignment assignment;

  const AssignmentCard({
    super.key,
    required this.assignment,
  });

  Color _statusColor(String s) {
    final x = s.toLowerCase();
    if (x.contains('progress')) return AppColors.primaryYellow;
    if (x.contains('assign')) return AppColors.accentBlue;
    if (x.contains('done') || x.contains('complete')) return AppColors.primaryGreen;
    if (x.contains('overdue') || x.contains('late')) return AppColors.primaryRed;
    return AppColors.neutral800;
  }

  @override
  Widget build(BuildContext context) {
    final c = _statusColor(assignment.status);

    return Material(
      color: AppColors.pureWhite,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DetailAssignmentPage()),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.dividerGray),
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
              // Title + status chip
              Row(
                children: [
                  Expanded(
                    child: Text(
                      assignment.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.neutral800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(text: assignment.status, color: c),
                ],
              ),
              const SizedBox(height: 6),

              // Date
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: AppColors.neutral500),
                  const SizedBox(width: 6),
                  Text(
                    assignment.formattedDueDate,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.neutral500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Description
              Text(
                assignment.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: AppColors.neutral800,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),

              // Priority + People Count
              Row(
                children: [
                  // Priority chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: assignment.priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: assignment.priorityColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      assignment.priority.toUpperCase(),
                      style: TextStyle(
                        color: assignment.priorityColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // People count (dummy for now)
                  const Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: AppColors.neutral100,
                        backgroundImage: NetworkImage('https://picsum.photos/200'),
                      ),
                      SizedBox(width: 4),
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: AppColors.neutral100,
                        backgroundImage: NetworkImage('https://picsum.photos/201'),
                      ),
                      SizedBox(width: 6),
                      Text(
                        '+2',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.neutral500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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

class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;
  const _StatusChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(.35)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 11.5,
        ),
      ),
    );
  }
}