import 'package:flutter/material.dart';
import 'package:frontend/data/models/assignment.dart';
import 'timeline_card.dart';

class WeeklyAssignmentUI extends StatelessWidget {
  final List<Assignment> assignments;
  
  const WeeklyAssignmentUI({
    super.key,
    required this.assignments,
  });

  @override
  Widget build(BuildContext context) {
    // Group assignments by date for the current week
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    Map<String, List<Assignment>> groupedAssignments = {};
    
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dateKey = '${date.day}/${date.month}';
      
      final dayAssignments = assignments.where((assignment) {
        return assignment.dueDate.year == date.year &&
               assignment.dueDate.month == date.month &&
               assignment.dueDate.day == date.day;
      }).toList();
      
      if (dayAssignments.isNotEmpty) {
        groupedAssignments[dateKey] = dayAssignments;
      }
    }

    if (groupedAssignments.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.assignment_outlined, size: 64, color: Color(0xFFA6A6A6)),
              SizedBox(height: 16),
              Text(
                'No assignments for this week',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final dates = groupedAssignments.keys.toList();

    return Column(
      children: List.generate(dates.length, (index) {
        final dateKey = dates[index];
        final dayAssignments = groupedAssignments[dateKey]!;
        
        return TimelineCard(
          date: dateKey,
          assignments: dayAssignments,
          isFirst: index == 0,
          isLast: index == dates.length - 1,
        );
      }),
    );
  }
}
