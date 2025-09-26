import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

/// Penanda tanggal + garis vertikal yang mengikuti tinggi card (via IntrinsicHeight).
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
    final Color railColor = isLast ? AppColors.primaryRed : AppColors.neutral300;

    return SizedBox(
      width: 40, // area tanggal + rail
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            date,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: AppColors.neutral800,
            ),
          ),
          const SizedBox(height: 6),
          // Expanded agar rail menyamai tinggi Row (card di kanan)
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 3,
                margin: EdgeInsets.only(top: isFirst ? 4 : 0, bottom: 4),
                decoration: BoxDecoration(
                  color: railColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
