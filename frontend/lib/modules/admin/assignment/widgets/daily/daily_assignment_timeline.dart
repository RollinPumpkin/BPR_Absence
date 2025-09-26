import 'package:flutter/material.dart';
import 'assignment_card.dart';
import 'package:frontend/core/constants/colors.dart';
import 'timeline_rail.dart';

class DailyAssignmentTimeline extends StatelessWidget {
  final Map<String, List<Map<String, String>>> assignmentsByDate;

  const DailyAssignmentTimeline({super.key, required this.assignmentsByDate});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: assignmentsByDate.entries.map((entry) {
        final date = entry.key;
        final assignments = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                date,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.neutral800,
                ),
              ),
            ),

            // Rail menyelimuti list untuk tanggal ini
            TimelineRail(
              leftInset: 12,
              railWidth: 4,
              topGap: 4,
              bottomGap: 4,
              contentSpacing: 10,
              child: Column(
                children: List.generate(assignments.length, (i) {
                  final a = assignments[i];
                  return Padding(
                    padding: EdgeInsets.only(bottom: i == assignments.length - 1 ? 0 : 12),
                    child: AssignmentCard(
                      title: a['title'] ?? '-',
                      description: a['description'] ?? '-',
                      status: a['status'] ?? '-',
                      date: a['date'] ?? '-',
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }
}
