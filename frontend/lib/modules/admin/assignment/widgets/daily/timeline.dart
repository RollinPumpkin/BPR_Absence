import 'package:flutter/material.dart';
import 'assignment_card.dart';
import 'package:frontend/core/constants/colors.dart';

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
            // Tanggal
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                date,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.black,
                ),
              ),
            ),
            // Timeline + Cards
            Column(
              children: List.generate(assignments.length, (index) {
                final assignment = assignments[index];
                final isLast = index == assignments.length - 1;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Garis merah vertikal
                    Column(
                      children: [
                        if (index == 0)
                          Container(
                            width: 4,
                            height: 10,
                            color: AppColors.transparent,
                          ),
                        Container(
                          width: 4,
                          height: 100, // tinggi card
                          color: AppColors.primaryRed,
                        ),
                        if (isLast)
                          Container(
                            width: 4,
                            height: 10,
                            color: AppColors.transparent,
                          ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    // Card
                    Expanded(
                      child: AssignmentCard(
                        title: assignment['title']!,
                        description: assignment['description']!,
                        status: assignment['status']!,
                        date: assignment['date']!,
                      ),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }
}
