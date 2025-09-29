// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class LetterCard extends StatelessWidget {
  final String name;
  final String date;
  final String type;
  final String status;
  final Color statusColor;
  final String absence;
  final Color absenceColor;
  final VoidCallback? onTap;

  const LetterCard({
    super.key,
    required this.name,
    required this.date,
    required this.type,
    required this.status,
    required this.statusColor,
    required this.absence,
    required this.absenceColor,
    this.onTap, // 👈 opsional
  });

  @override
  Widget build(BuildContext context) {
    return InkWell( // 👈 bikin bisa di-klik
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name + Absence
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  absence,
                  style: TextStyle(
                    color: absenceColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Date + Type
            Text(date,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            Text(type,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 8),

            // Description preview
            const Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit...",
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),

            // Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  "View",
                  style: TextStyle(
                      color: statusColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class LetterCard extends StatelessWidget {
  final String name;
  final String date;
  final String type;
  final String status;
  final Color statusColor;
  final String absence;
  final Color absenceColor;
  final VoidCallback? onTap;

  const LetterCard({
    super.key,
    required this.name,
    required this.date,
    required this.type,
    required this.status,
    required this.statusColor,
    required this.absence,
    required this.absenceColor,
    this.onTap, // 👈 opsional
  });

  @override
  Widget build(BuildContext context) {
    return InkWell( // 👈 bikin bisa di-klik
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name + Absence
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  absence,
                  style: TextStyle(
                    color: absenceColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Date + Type
            Text(date,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            Text(type,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 8),

            // Description preview
            const Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit...",
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),

            // Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  "View",
                  style: TextStyle(
                      color: statusColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}