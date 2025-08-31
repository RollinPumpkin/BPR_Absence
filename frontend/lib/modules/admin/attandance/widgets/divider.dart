import 'package:flutter/material.dart';

class VerticalDividerCustom extends StatelessWidget {
  const VerticalDividerCustom({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      width: 1.2,
      color: Colors.black26,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
