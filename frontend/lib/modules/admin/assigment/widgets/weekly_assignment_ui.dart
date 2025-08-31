import 'package:flutter/material.dart';

class WeeklyAssignmentUI extends StatelessWidget {
  const WeeklyAssignmentUI({super.key});

  @override
  Widget build(BuildContext context) {
    final List<int> dates = [29, 28, 27]; // contoh tanggal dummy

    return Column(
      children: List.generate(dates.length, (index) {
        return _buildTimelineCard(
          date: dates[index].toString(),
          isFirst: index == 0,
          isLast: index == dates.length - 1,
        );
      }),
    );
  }

  Widget _buildTimelineCard({
    required String date,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // === KIRI: Timeline Line + Tanggal ===
        Column(
          children: [
            // Tanggal
            Text(
              date,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            // Garis Vertikal
            Container(
              width: 2,
              height: 100, // tinggi disesuaikan dengan tinggi card
              color: isFirst
                  ? Colors.grey // atas abu
                  : isLast
                      ? Colors.red // terakhir merah
                      : Colors.grey,
            ),
          ],
        ),
        const SizedBox(width: 12),

        // === KANAN: Card Assignment ===
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade100,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 5,
                )
              ],
              border: Border.all(color: Colors.black12, width: 1),
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
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Tanggal
                const Text(
                  "27 Agustus 2024",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 8),

                // Deskripsi
                const Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit, "
                  "sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 10),

                // Footer (People + Tombol View)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        CircleAvatar(
                          radius: 14,
                          backgroundImage:
                              NetworkImage("https://picsum.photos/200"),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: const Text(
                        "View",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
