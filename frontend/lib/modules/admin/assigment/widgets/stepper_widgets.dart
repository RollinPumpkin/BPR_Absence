import 'package:flutter/material.dart';

/// 🔹 Widget lingkaran untuk stepper
class StepCircle extends StatelessWidget {
  final String number;
  final bool isActive;

  const StepCircle({
    super.key,
    required this.number,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: isActive ? Colors.red : Colors.grey.shade300,
      child: Text(
        number,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// 🔹 Widget garis penghubung antar step
class StepLine extends StatelessWidget {
  const StepLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        color: Colors.grey.shade400,
      ),
    );
  }
}
