import 'package:flutter/material.dart';
import 'package:frontend/data/models/assignment.dart';
import 'timeline_date.dart';
import 'assignment_card.dart';

class TimelineCard extends StatelessWidget {
  final String date;
  final List<Assignment> assignments;
  final bool isFirst;
  final bool isLast;

  const TimelineCard({
    super.key,
    required this.date,
    required this.assignments,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TimelineDate(date: date, isFirst: isFirst, isLast: isLast),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: assignments.map((assignment) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: AssignmentCard(
                    assignment: assignment,
                  ),
                )
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
