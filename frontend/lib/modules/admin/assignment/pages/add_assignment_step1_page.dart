import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'add_assignment_step2_page.dart';
import 'stepper_widgets.dart';
import '../models/assignment_draft.dart';

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
  String? selectedPriority; // New: Priority dropdown

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Assignment"),
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        foregroundColor: AppColors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Stepper Indicator
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StepCircle(number: "1", isActive: true),
                StepLine(),
                StepCircle(number: "2", isActive: false),
                StepLine(),
                StepCircle(number: "3", isActive: false),
              ],
            ),
            const SizedBox(height: 28),

            // 🔹 Nama Kegiatan
            const Text(
              "Nama Kegiatan",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Nama Kegiatan",
              ),
            ),

            const SizedBox(height: 18),

            // 🔹 Priority Dropdown
            const Text(
              "Priority *",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: selectedPriority,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Select Priority",
              ),
              items: const [
                DropdownMenuItem(value: "low", child: Text("Low")),
                DropdownMenuItem(value: "medium", child: Text("Medium")),
                DropdownMenuItem(value: "high", child: Text("High")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedPriority = value;
                });
              },
            ),

            const SizedBox(height: 20),

            // 🔹 Deskripsi
            const Text(
              "Description *",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: descController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Deskripsi pekerjaan",
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Start Date & End Date
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(
                      text: startDate == null
                          ? ""
                          : "${startDate!.day}/${startDate!.month}/${startDate!.year}",
                    ),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Start Date",
                      hintText: "dd/mm/yyyy",
                      suffixIcon: Icon(Icons.calendar_today, size: 20),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
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
                    controller: TextEditingController(
                      text: endDate == null
                          ? ""
                          : "${endDate!.day}/${endDate!.month}/${endDate!.year}",
                    ),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "End Date",
                      hintText: "dd/mm/yyyy",
                      suffixIcon: Icon(Icons.calendar_today, size: 20),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: endDate ?? startDate ?? DateTime.now(),
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

            const SizedBox(height: 20),

            // 🔹 Time
            TextField(
              controller: TextEditingController(
                text: time == null
                    ? ""
                    : "${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}",
              ),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Time",
                hintText: "00:00",
                suffixIcon: Icon(Icons.access_time, size: 20),
              ),
              readOnly: true,
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: time ?? TimeOfDay.now(),
                );
                if (picked != null) {
                  setState(() => time = picked);
                }
              },
            ),
            const SizedBox(height: 6),

            const SizedBox(height: 20),

            // 🔹 Link Optional
            TextField(
              controller: linkController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Link (Optional)",
                hintText: "Evidence",
              ),
            ),

            const SizedBox(height: 28),

            // 🔹 Tombol
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.black,
                      side: const BorderSide(color: AppColors.black),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.pureWhite,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      // Validate required fields
                      if (nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please enter assignment name")),
                        );
                        return;
                      }
                      if (descController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please enter description")),
                        );
                        return;
                      }
                      if (selectedPriority == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please select priority")),
                        );
                        return;
                      }
                      
                      // Create draft with form data
                      final draft = AssignmentDraft(
                        name: nameController.text.trim(),
                        description: descController.text.trim(),
                        startDate: startDate,
                        endDate: endDate,
                        time: time,
                        categories: [], // Empty categories since we removed chips
                        priority: selectedPriority!, // Add priority
                        link: linkController.text.trim().isEmpty 
                            ? null 
                            : linkController.text.trim(),
                      );
                      
                      // Pass draft to Step 2
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddAssignmentStep2Page(draft: draft),
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
