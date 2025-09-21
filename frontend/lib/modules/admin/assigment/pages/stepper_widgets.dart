import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

/// 🔹 Widget lingkaran untuk stepper
class StepCircle extends StatelessWidget {
  final String number;
  final bool isActive;
  final bool isCompleted;

  const StepCircle({
    super.key,
    required this.number,
    required this.isActive,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: isCompleted
          ? AppColors.primaryGreen
          : (isActive ? AppColors.primaryRed : Colors.grey.shade300),
      child: isCompleted
          ? const Icon(Icons.check, color: Colors.white, size: 18)
          : Text(
              number,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
    );
  }
}

/// 🔹 Widget garis penghubung antar step
class StepLine extends StatelessWidget {
  final bool isActive;

  const StepLine({super.key, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: isActive ? AppColors.primaryRed : Colors.grey.shade400,
      ),
    );
  }
}
