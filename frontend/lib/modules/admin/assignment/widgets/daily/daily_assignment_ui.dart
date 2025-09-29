import 'package:flutter/material.dart';
import 'assignment_card.dart';
import 'package:frontend/core/constants/colors.dart';
import 'timeline_rail.dart';

class DailyAssignmentUI extends StatelessWidget {
  const DailyAssignmentUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '09 AM',
          style: TextStyle(
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
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return const AssignmentCard(
                title: 'Go To Bromo',
                date: '27 Agustus 2024',
                description:
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, '
                    'sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                status: 'Assigned',
              );
            },
          ),
        ),
      ],
    );
  }
}
