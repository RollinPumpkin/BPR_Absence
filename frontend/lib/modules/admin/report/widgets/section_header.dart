import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? trailingText;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(
                color: Color(0xFF8E96A4),
                fontWeight: FontWeight.w500,
              )),
          const Spacer(),
          if (trailingText != null)
            Text(
              trailingText!,
              style: const TextStyle(
                color: Color(0xFF8E96A4),
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
