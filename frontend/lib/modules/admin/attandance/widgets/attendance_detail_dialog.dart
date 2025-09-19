import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'attendance_form_page.dart';

class AttendanceDetailDialog extends StatelessWidget {
  const AttendanceDetailDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔹 Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Attendance Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),

            const SizedBox(height: 8),

            // 🔹 Employee Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    child: Icon(Icons.person),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Septa Puma Surya",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const Text("Jabatan",
                            style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Check In",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 🔹 Attendance Information
            _sectionBox(
              "Attendance Information",
              Column(
                children: [
                  _infoRow("Date", "1 March 2025", "Check In", "09:00"),
                  const SizedBox(height: 8),
                  _infoRow("Status", "Present", "Check Out", "-"),
                  const SizedBox(height: 8),
                  _infoRow("Work Hours", "8 Hours", "", ""),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 🔹 Location Information
            _sectionBox(
              "Location Information",
              Column(
                children: [
                  _infoRow("Location", "Office", "Detail Address",
                      "Jl. Soekarno Hatta No. 8, Jatimulyo, Lowokwaru, Kota Malang"),
                  const SizedBox(height: 8),
                  _infoRow("Lat", "-2241720016", "Long", "2241720119"),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 🔹 Proof of Attendance
            _sectionBox(
              "Proof of Attendance",
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Expanded(child: Text("Wa003198373738.jpg")),
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 8),
                    Icon(Icons.visibility, size: 20),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: AppColors.primaryYellow),
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AttendanceFormPage()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: AppColors.primaryRed),
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Deleted Successfully")),
                      );
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // 🔹 Widget Section Box
  Widget _sectionBox(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const Divider(),
          child,
        ],
      ),
    );
  }

  // 🔹 Info Row
  Widget _infoRow(String label1, String value1, String label2, String value2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label1,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 2),
                Text(value1, style: const TextStyle(fontSize: 13)),
              ]),
        ),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label2,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 2),
                Text(value2, style: const TextStyle(fontSize: 13)),
              ]),
        ),
      ],
    );
  }
}
