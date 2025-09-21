import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class DetailAssignmentPage extends StatelessWidget {
  const DetailAssignmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Assignment"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // 🔹 Body
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Nama Kegiatan
            const Text(
              "Nama Kegiatan",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            _buildReadonlyBox("Muncak Rinjani Ikut Lorenzo"),
            const SizedBox(height: 16),

            // 🔹 Tags
            Wrap(
              spacing: 8,
              children: [
                _buildTag("Tugas Buku"),
                _buildTag("Report"),
                _buildTag("Seminar"),
                _buildTag("Pelaporan OJK"),
                _buildTag("Audit"),
                _buildTag("Training / Pelatihan"),
                _buildTag("Monitoring & Pengkajian"),
              ],
            ),
            const SizedBox(height: 16),

            // 🔹 Description
            const Text(
              "Description",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            _buildReadonlyBox(
              "Muncak bersama bunga agam dan lorenzo membawa 3 ayam 2 bebek ...",
              maxLines: 4,
            ),
            const SizedBox(height: 16),

            // 🔹 Start & End Date
            Row(
              children: [
                Expanded(
                  child: _buildReadonlyBox("27/08/2025", label: "Start Date"),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildReadonlyBox("End Date", label: "End Date"),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 🔹 Jam
            const Text(
              "Jam",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            _buildReadonlyBox("17:45:00"),
            const SizedBox(height: 16),

            // 🔹 Link
            const Text(
              "Link (Optional)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            _buildReadonlyBox("https://wordpress.anjay"),
            const SizedBox(height: 16),

            // 🔹 Employee Assignment
            const Text(
              "Employee Assignment",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.primaryBlue,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Septa Puma",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("Manager"),
                    ],
                  ),
                  const Spacer(),
                  const Text(
                    "Active",
                    style: TextStyle(color: AppColors.primaryGreen),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Custom Tag Widget
  Widget _buildTag(String text) {
    return Chip(
      label: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: Colors.grey.shade200,
    );
  }

  // 🔹 Read-only box widget
  Widget _buildReadonlyBox(String value, {int maxLines = 1, String? label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }
}
