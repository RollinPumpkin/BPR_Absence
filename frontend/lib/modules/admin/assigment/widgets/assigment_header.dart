import 'package:flutter/material.dart';

class AssigmentHeader extends StatelessWidget {
  const AssigmentHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title and Setting Icon
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Assignment",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
 ],
    );
  }
}
