import 'package:flutter/material.dart';
import 'timeline_date.dart';
import 'assignment_card.dart';

class TimelineCard extends StatelessWidget {
  final String date;
  final bool isFirst;
  final bool isLast;

  const TimelineCard({
    super.key,
    required this.date,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TimelineDate(date: date, isFirst: isFirst, isLast: isLast),
        const SizedBox(width: 12),
        const Expanded(child: AssignmentCard()),
      ],
    );
  }
}
