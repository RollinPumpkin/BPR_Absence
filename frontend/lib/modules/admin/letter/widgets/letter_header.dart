import 'package:flutter/material.dart';

class LetterHeader extends StatelessWidget {
  const LetterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title and Setting Icon
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Letter Overview",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
 ],
    );
  }
}
