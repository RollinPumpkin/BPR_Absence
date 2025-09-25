import 'package:flutter/material.dart';
import 'timeline_card.dart';

class WeeklyAssignmentUI extends StatelessWidget {
  const WeeklyAssignmentUI({super.key});

  @override
  Widget build(BuildContext context) {
    final List<int> dates = [29, 28, 27];

    return Column(
      children: List.generate(dates.length, (index) {
        return TimelineCard(
          date: dates[index].toString(),
          isFirst: index == 0,
          isLast: index == dates.length - 1,
        );
      }),
    );
  }
}
