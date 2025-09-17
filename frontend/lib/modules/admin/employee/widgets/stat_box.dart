import 'package:flutter/material.dart';

class StatBox extends StatelessWidget {
  final String title;
  final String value;

  const StatBox({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(title),
      ],
    );
  }
}
