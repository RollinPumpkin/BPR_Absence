import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class TimelineRail extends StatelessWidget {
  final Widget child;

  final double leftInset;

  final double railWidth;

  final double topGap;
  final double bottomGap;

  final double contentSpacing;

  const TimelineRail({
    super.key,
    required this.child,
    this.leftInset = 12,
    this.railWidth = 4,
    this.topGap = 4,
    this.bottomGap = 4,
    this.contentSpacing = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Rail merah memanjang
        Positioned.fill(
          left: leftInset,
          child: Padding(
            padding: EdgeInsets.only(top: topGap, bottom: bottomGap),
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: railWidth,
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.only(left: leftInset + railWidth + contentSpacing),
          child: child,
        ),
      ],
    );
  }
}
