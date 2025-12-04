import 'package:flutter/material.dart';
import 'assignment_card.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/data/models/assignment.dart';
import 'timeline_rail.dart';

class DailyAssignmentUI extends StatelessWidget {
  final List<Assignment> assignments;
  
  const DailyAssignmentUI({
    super.key, 
    required this.assignments,
  });

  @override
  Widget build(BuildContext context) {
    // Filter assignments for today
    final today = DateTime.now();
    final todayAssignments = assignments.where((assignment) {
      return assignment.dueDate.year == today.year &&
             assignment.dueDate.month == today.month &&
             assignment.dueDate.day == today.day;
    }).toList();

    if (todayAssignments.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.assignment_outlined, size: 64, color: AppColors.neutral400),
              SizedBox(height: 16),
              Text(
                'No assignments for today',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today - ${today.day}/${today.month}/${today.year}',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: AppColors.neutral800,
          ),
        ),
        const SizedBox(height: 10),

        TimelineRail(
          leftInset: 12,   
          railWidth: 4,
          topGap: 4,
          bottomGap: 4,
          contentSpacing: 10,
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: todayAssignments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final assignment = todayAssignments[index];
              return AssignmentCard(
                assignment: assignment,
              );
            },
          ),
        ),
      ],
    );
  }
}
