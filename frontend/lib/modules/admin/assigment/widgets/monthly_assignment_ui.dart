import 'package:flutter/material.dart';
import 'add_assignment_step1_page.dart';
import 'assignment_card.dart';

class MonthlyAssignmentUI extends StatelessWidget {
  const MonthlyAssignmentUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Calendar Placeholder (nanti bisa diganti TableCalendar)
        Container(
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              "📅 Calendar Widget Placeholder",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 🔹 Add Data button
SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddAssignmentStep1Page(),
        ),
      );
    },
    icon: const Icon(Icons.add),
    label: const Text("Add Data"),
  ),
),
const SizedBox(height: 16),


        // 🔹 List Assignment
        const Text(
          "Assignments",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        const AssignmentCard(
          title: "Go To Bromo",
          description: "Team building activity at Bromo mountain.",
          status: "Assigned",
          date: "27 Agustus 2023",
        ),
        const SizedBox(height: 12),
        const AssignmentCard(
          title: "Go To Malang",
          description: "Business trip to Malang.",
          status: "Assigned",
          date: "30 Agustus 2023",
        ),
      ],
    );
  }
}
