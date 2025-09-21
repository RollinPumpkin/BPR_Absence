import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import '../../pages/detail_assigment_page.dart';

class AssignmentCard extends StatelessWidget {
  const AssignmentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // 🔹 Navigasi ke halaman detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DetailAssignmentPage(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Go To Bromo",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Assigned",
                  style: TextStyle(
                    color: AppColors.primaryYellow,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Tanggal
            const Text(
              "27 Agustus 2024",
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),

            // Deskripsi
            const Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit, "
              "sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
              style: TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    CircleAvatar(
                      radius: 14,
                      backgroundImage: NetworkImage("https://picsum.photos/200"),
                    ),
                    SizedBox(width: 6),
                    Text(
                      "27 People Assigned",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    // 🔹 Navigasi ke halaman detail
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DetailAssignmentPage(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primaryYellow),
                    ),
                    child: const Text(
                      "View",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryYellow,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
