import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class LetterAcceptancePage extends StatefulWidget {
  const LetterAcceptancePage({super.key});

  @override
  State<LetterAcceptancePage> createState() => _LetterAcceptancePageState();
}

class _LetterAcceptancePageState extends State<LetterAcceptancePage> {
  final List<String> months = [
    "Jan 2024",
    "Feb 2024",
    "Mar 2024",
    "Apr 2024",
    "May 2024",
    "Jun 2024",
    "Jul 2024",
    "Aug 2024",
    "Sep 2024",
    "Oct 2024",
    "Nov 2024",
    "Dec 2024",
  ];

  int selectedMonthIndex = 7; // Default Agustus 2024

  final List<Map<String, dynamic>> letters = [
    {
      "date": "27 Aug 2024",
      "name": "Septa Puma",
      "type": "Doctor's Note",
      "desc":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
      "image": "https://via.placeholder.com/150",
    },
    {
      "date": "29 Aug 2024",
      "name": "Andi Wijaya",
      "type": "Permission Letter",
      "desc":
          "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium.",
      "image": "https://via.placeholder.com/150",
    },
  ];

  void _prevMonth() {
    setState(() {
      if (selectedMonthIndex > 0) {
        selectedMonthIndex--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (selectedMonthIndex < months.length - 1) {
        selectedMonthIndex++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Header
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Letter Acceptance",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            // 🔹 Bulan & Tahun dengan panah
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_left),
                  onPressed: _prevMonth,
                ),
                Text(
                  months[selectedMonthIndex],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_right),
                  onPressed: _nextMonth,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 🔹 Card list per tanggal
            Expanded(
              child: ListView.builder(
                itemCount: letters.length,
                itemBuilder: (context, index) {
                  final letter = letters[index];

                  final name = letter["name"] as String? ?? "-";
                  final type = letter["type"] as String? ?? "-";
                  final date = letter["date"] as String? ?? "-";
                  final desc = letter["desc"] as String? ?? "";
                  final image = letter["image"] as String? ?? "";

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Info dasar
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          type,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          desc,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 10),

                        // 🔹 Bukti Gambar + Action
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                image,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Tombol Aksi
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildActionButton(
                                    icon: Icons.download,
                                    label: "Download",
                                    color: AppColors.primaryBlue,
                                    onTap: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text("Downloading $type..."),
                                        ),
                                      );
                                    },
                                  ),
                                  _buildActionButton(
                                    icon: Icons.check_circle,
                                    label: "Approve",
                                    color: AppColors.primaryGreen,
                                    onTap: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text("$type Approved"),
                                        ),
                                      );
                                    },
                                  ),
                                  _buildActionButton(
                                    icon: Icons.cancel,
                                    label: "Reject",
                                    color: AppColors.primaryRed,
                                    onTap: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text("$type Rejected"),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: color, size: 22),
          onPressed: onTap,
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: color),
        ),
      ],
    );
  }
}
