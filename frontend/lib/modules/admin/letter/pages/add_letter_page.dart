import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class AddLetterPage extends StatelessWidget {
  const AddLetterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController statusController = TextEditingController();
    final TextEditingController dateController = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Add Letter",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Employee Dropdown
              const Text("Employee"),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: "1", child: Text("Septa Puma")),
                  DropdownMenuItem(value: "2", child: Text("Nurhaliza")),
                ],
                onChanged: (value) {},
                hint: const Text("-Choose Employee"),
              ),
              const SizedBox(height: 16),

              // Letter Type Dropdown
              const Text("Letter Type"),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: "doctor", child: Text("Doctor's Note")),
                  DropdownMenuItem(value: "permit", child: Text("Permit Letter")),
                ],
                onChanged: (value) {},
                hint: const Text("-Choose Letter Type"),
              ),
              const SizedBox(height: 16),

              // Letter Name
              const Text("Letter Name"),
              const SizedBox(height: 6),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: "Enter Letter Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Letter Description
              const Text("Letter Description"),
              const SizedBox(height: 6),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: "Enter Letter Description (Optional)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Letter Status
              const Text("Letter Status"),
              const SizedBox(height: 6),
              TextField(
                controller: statusController,
                decoration: InputDecoration(
                  hintText: "Enter the Status",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Valid Until (Date Picker)
              const Text("Valid Until"),
              const SizedBox(height: 6),
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: "dd/mm/yyyy",
                  prefixIcon: const Icon(Icons.calendar_today, color: AppColors.primaryBlue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    initialDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    dateController.text =
                        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                  }
                },
              ),
              const SizedBox(height: 16),

              // Upload Supporting Evidence
              const Text("Upload Supporting Evidence"),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.image_outlined, size: 40),
                    SizedBox(height: 8),
                    Text("Drag and Drop Here"),
                    SizedBox(height: 4),
                    Text(
                      "Or",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Browse",
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Letter Saved!")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(fontSize: 16, color: AppColors.pureWhite),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
