import 'package:flutter/material.dart';
import 'add_assignment_step3_page.dart';

class AddAssignmentStep2Page extends StatefulWidget {
  const AddAssignmentStep2Page({super.key});

  @override
  State<AddAssignmentStep2Page> createState() => _AddAssignmentStep2PageState();
}

class _AddAssignmentStep2PageState extends State<AddAssignmentStep2Page> {
  List<String> employees = [
    "Septa Puma",
    "John Doe",
    "Jane Smith",
    "Michael",
    "Sarah"
  ];

  final Set<String> selectedEmployees = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Assignment")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search Employee",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: employees.map((e) {
                final isSelected = selectedEmployees.contains(e);
                return ListTile(
                  leading: const CircleAvatar(),
                  title: Text(e),
                  subtitle: const Text("Manager"),
                  trailing: Checkbox(
                    value: isSelected,
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
                );
              }).toList(),
            ),
          ),
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
          )
        ],
      ),
    );
  }
}
