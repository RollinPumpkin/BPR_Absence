import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class AssignmentTabSwitcher extends StatelessWidget {
  final String selected;
  final Function(String) onChanged;

  const AssignmentTabSwitcher({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = ["Daily", "Weekly", "Monthly"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: tabs.map((tab) {
        final isActive = selected == tab;
        return GestureDetector(
          onTap: () => onChanged(tab),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryBlue : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryBlue),
            ),
            child: Text(
              tab,
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
