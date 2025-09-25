import 'package:flutter/material.dart';
import 'assignment_card.dart';
import 'package:frontend/core/constants/colors.dart';

class DailyAssignmentUI extends StatelessWidget {
  const DailyAssignmentUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline Jam
        const Text(
          "09 AM",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 10),

        // Daftar Card Assignment
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return Row(
              children: [
                // Garis merah di kiri
                Container(
                  width: 4,
                  height: 100, // tinggi bisa disesuaikan dengan card
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),

                // Card Assignment
                Expanded(
                  child: AssignmentCard(
                    title: "Go To Bromo",
                    date: "27 Agustus 2024",
                    description:
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, "
                        "sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                    status: "Assigned",
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
