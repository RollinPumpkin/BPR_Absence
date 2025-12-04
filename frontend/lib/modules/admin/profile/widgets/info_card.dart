import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final Color borderColor;

  const InfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    this.borderColor = AppColors.primaryRed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: borderColor, width: 6)),
        color: AppColors.pureWhite,
        boxShadow: const [
          BoxShadow(
            color: AppColors.black,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
