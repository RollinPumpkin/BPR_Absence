import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String rightStatus;
  final int people;

  const StatCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.rightStatus,
    required this.people,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6E8F0)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFFF0F2F7),
            child: Icon(Icons.person, color: Color(0xFF8E96A4)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                    Text(
                      rightStatus,
                      style: const TextStyle(
                        color: Color(0xFF00B894),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                      color: Color(0xFF8E96A4), fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  'Absens  $people Orang',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF8E96A4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
