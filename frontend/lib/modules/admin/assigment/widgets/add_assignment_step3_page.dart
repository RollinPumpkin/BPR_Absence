import 'package:flutter/material.dart';

class AddAssignmentStep3Page extends StatelessWidget {
  final List<String> employees;

  const AddAssignmentStep3Page({super.key, required this.employees});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Assignment")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Review Data"),
            const SizedBox(height: 12),
            Text("Nama Kegiatan: Muncak Rinjani ikut Lorenzo"),
            Text("Description: Muncak bareng teman"),
            Text("Tanggal: 27/08/2025 - 27/08/2025"),
            Text("Jam: 17:45"),
            Text("Link: https://wordpress.anjay"),

            const SizedBox(height: 16),
            const Text("Employee Assignment:"),
            Column(
              children: employees.map((e) {
                return ListTile(
                  leading: const CircleAvatar(),
                  title: Text(e),
                  subtitle: const Text("Manager"),
                  trailing: const Text(
                    "Active",
                    style: TextStyle(color: Colors.green),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // ✅ Kembalikan result ke MonthlyAssignmentUI
                      Navigator.pop(context, true);
                    },
                    child: const Text("Save"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
