import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class TimelineDate extends StatelessWidget {
  final String date;
  final bool isFirst;
  final bool isLast;

  const TimelineDate({
    super.key,
    required this.date,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          date,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Container(
          width: 2,
          height: 100,
          color: isFirst
              ? Colors.grey
              : isLast
                  ? AppColors.primaryRed
                  : Colors.grey,
        ),
      ],
    );
  }
}
