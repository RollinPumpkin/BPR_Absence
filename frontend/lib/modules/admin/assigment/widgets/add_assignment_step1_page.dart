import 'package:flutter/material.dart';
import 'add_assignment_step2_page.dart';
import 'stepper_widgets.dart';

class AddAssignmentStep1Page extends StatefulWidget {
  const AddAssignmentStep1Page({super.key});

  @override
  State<AddAssignmentStep1Page> createState() => _AddAssignmentStep1PageState();
}

class _AddAssignmentStep1PageState extends State<AddAssignmentStep1Page> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController linkController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? time;

  // kategori checkbox
  final List<String> categories = [
    "Tutup buku",
    "Rapat",
    "Seminar",
    "Pelaporan OJK",
    "Audit",
    "Training / Pelatihan",
    "Monitoring & Pengujian",
  ];
  final Set<String> selectedCategories = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Assignment")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Stepper indicator pakai widget baru
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                StepCircle(number: "1", isActive: true),
                StepLine(),
                StepCircle(number: "2", isActive: false),
                StepLine(),
                StepCircle(number: "3", isActive: false),
              ],
            ),
            const SizedBox(height: 24),

            // 🔹 Nama Kegiatan
            const Text("Nama Kegiatan",
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Nama Kegiatan",
              ),
            ),

            const SizedBox(height: 16),
            // 🔹 kategori checkbox
            Wrap(
              spacing: 8,
              children: categories.map((cat) {
                return FilterChip(
                  label: Text(cat),
                  selected: selectedCategories.contains(cat),
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        selectedCategories.add(cat);
                      } else {
                        selectedCategories.remove(cat);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),
            const Text("Description *",
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: descController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Deskripsi pekerjaan",
              ),
            ),

            const SizedBox(height: 16),
            // 🔹 Start Date & End Date
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: startDate == null
                          ? "dd/mm/yy"
                          : "${startDate!.day}/${startDate!.month}/${startDate!.year}",
                      labelText: "Start Date",
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() => startDate = picked);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: endDate == null
                          ? "dd/mm/yy"
                          : "${endDate!.day}/${endDate!.month}/${endDate!.year}",
                      labelText: "End Date",
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() => endDate = picked);
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            // 🔹 Jam
            TextField(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: "Jam",
                hintText: time == null
                    ? "00 : 00"
                    : "${time!.hour.toString().padLeft(2, '0')} : ${time!.minute.toString().padLeft(2, '0')}",
                suffixIcon: const Icon(Icons.access_time),
              ),
              readOnly: true,
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  setState(() => time = picked);
                }
              },
            ),
            const SizedBox(height: 6),
            const Text(
              "pss.. ini cuman muncul ketika terekor centang hari yang sama diaktifkan ya",
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),

            const SizedBox(height: 16),
            // 🔹 Link Optional
            TextField(
              controller: linkController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Evidence",
                labelText: "Link (Optional)",
              ),
            ),

            const SizedBox(height: 24),
            // 🔹 Tombol
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddAssignmentStep2Page(),
                        ),
                      );
                    },
                    child: const Text("Next"),
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
