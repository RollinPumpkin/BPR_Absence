import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

/// Judul section dengan garis memanjang di kanan.
/// Contoh:  Data  ─────────────────────────
class LinedSectionTitle extends StatelessWidget {
  final String title;
  final EdgeInsets padding;
  final double lineThickness;
  final Color lineColor;
  final TextStyle? textStyle;
  final double gap;

  const LinedSectionTitle({
    super.key,
    required this.title,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    this.lineThickness = 1.2,
    this.lineColor = AppColors.dividerGray,
    this.textStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w800,
      color: AppColors.neutral800,
    ),
    this.gap = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Text(title, style: textStyle),
          SizedBox(width: gap),
          Expanded(
            child: Container(
              height: lineThickness,
              decoration: BoxDecoration(
                color: lineColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
