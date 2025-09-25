import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'add_assignment_step3_page.dart';
import 'stepper_widgets.dart';

class AddAssignmentStep2Page extends StatefulWidget {
  const AddAssignmentStep2Page({super.key});

  @override
  State<AddAssignmentStep2Page> createState() => _AddAssignmentStep2PageState();
}

class _AddAssignmentStep2PageState extends State<AddAssignmentStep2Page> {
  final List<String> employees = [
    "Septa Puma",
    "John Doe",
    "Jane Smith",
    "Michael",
    "Sarah",
  ];

  final Set<String> selectedEmployees = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Assignment"),
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        foregroundColor: AppColors.black,
      ),
      body: Column(
        children: [
          // 🔹 Stepper Indicator
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                StepCircle(number: "1", isActive: false),
                StepLine(),
                StepCircle(number: "2", isActive: true),
                StepLine(),
                StepCircle(number: "3", isActive: false),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 🔹 Konten
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search Employee",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // List Employee
                  Expanded(
                    child: ListView.builder(
                      itemCount: employees.length,
                      itemBuilder: (context, index) {
                        final e = employees[index];
                        final isSelected = selectedEmployees.contains(e);

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 1,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person, color: AppColors.pureWhite),
                            ),
                            title: Text(e),
                            subtitle: const Text("Manager"),
                            trailing: Checkbox(
                              value: isSelected,
                              activeColor: AppColors.primaryGreen,
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    selectedEmployees.add(e);
                                  } else {
                                    selectedEmployees.remove(e);
                                  }
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🔹 Tombol
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddAssignmentStep3Page(
                            employees: selectedEmployees.toList(),
                          ),
                        ),
                      );
                    },
                    child: const Text("Next"),
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
