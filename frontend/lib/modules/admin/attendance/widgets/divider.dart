import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class VerticalDividerCustom extends StatelessWidget {
  const VerticalDividerCustom({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      width: 1.2,
      color: AppColors.black,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
