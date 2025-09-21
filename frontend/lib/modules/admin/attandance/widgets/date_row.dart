import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/constants/colors.dart';

class DateRow extends StatelessWidget {
  const DateRow({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final day = DateFormat('d').format(now);
    final month = DateFormat('MMMM', 'id_ID').format(now);
    final year = DateFormat('y').format(now);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _DateBox(text: day),
        const SizedBox(width: 6),
        const Text("-", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 6),
        _DateBox(text: month),
        const SizedBox(width: 6),
        const Text("-", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 6),
        _DateBox(text: year),
      ],
    );
  }
}

class _DateBox extends StatelessWidget {
  final String text;
  const _DateBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}
