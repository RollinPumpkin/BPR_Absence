import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'stepper_widgets.dart';

class AddAssignmentStep3Page extends StatefulWidget {
  final List<String> employees;

  const AddAssignmentStep3Page({super.key, required this.employees});

  @override
  State<AddAssignmentStep3Page> createState() => _AddAssignmentStep3PageState();
}

class _AddAssignmentStep3PageState extends State<AddAssignmentStep3Page> {
  bool sameDay = false;
  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? selectedTime;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  final List<String> categories = [
    "Tugas Audit",
    "Rapat",
    "Seminar",
    "Pelaporan OJK",
    "Training / Pelatihan",
    "Monitoring & Pengujian",
  ];
  final List<String> selectedCategories = [];

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          if (sameDay) endDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Assignment"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // 🔹 Stepper Indicator
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                StepCircle(number: "1", isActive: false),
                StepLine(),
                StepCircle(number: "2", isActive: false),
                StepLine(),
                StepCircle(number: "3", isActive: true),
              ],
            ),
          ),

          // 🔹 Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Kegiatan
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Nama Kegiatan",
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Checkbox kategori
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((category) {
                      return FilterChip(
                        label: Text(category),
                        selected: selectedCategories.contains(category),
                        selectedColor: AppColors.primaryGreen.withOpacity(0.2),
                        checkmarkColor: AppColors.primaryGreen,
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              selectedCategories.add(category);
                            } else {
                              selectedCategories.remove(category);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  TextField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: "Description"),
                  ),
                  const SizedBox(height: 12),

                  // Start Date & End Date
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _pickDate(context, true),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: "Start Date",
                            ),
                            child: Text(
                              startDate != null
                                  ? "${startDate!.day}/${startDate!.month}/${startDate!.year}"
                                  : "Pilih tanggal",
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: sameDay
                              ? null
                              : () => _pickDate(context, false),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: "End Date",
                            ),
                            child: Text(
                              endDate != null
                                  ? "${endDate!.day}/${endDate!.month}/${endDate!.year}"
                                  : "Pilih tanggal",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: sameDay,
                        onChanged: (val) {
                          setState(() {
                            sameDay = val ?? false;
                            if (sameDay && startDate != null) {
                              endDate = startDate;
                            }
                          });
                        },
                      ),
                      const Text("Hari yang sama"),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Jam
                  InkWell(
                    onTap: () => _pickTime(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: "Jam"),
                      child: Text(
                        selectedTime != null
                            ? selectedTime!.format(context)
                            : "Pilih jam",
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "P.S.: Harap mencantumkan waktu tanda tangan kontrak jika ada",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),

                  // Link (optional)
                  TextField(
                    controller: _linkController,
                    decoration: const InputDecoration(
                      labelText: "Link (Optional)",
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Employee Assignment
                  const Text(
                    "Employee Assignment",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ...widget.employees.map((e) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(e),
                        subtitle: const Text("Manager"),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Active",
                            style: TextStyle(color: AppColors.primaryGreen),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          // 🔹 Tombol Save
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/admin/assigment',
                      );
                    },
                    child: const Text("Save", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
