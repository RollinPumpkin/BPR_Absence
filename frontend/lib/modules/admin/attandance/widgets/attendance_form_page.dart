import 'package:flutter/material.dart';

class AttendanceFormPage extends StatefulWidget {
  const AttendanceFormPage({super.key});

  @override
  State<AttendanceFormPage> createState() => _AttendanceFormPageState();
}

class _AttendanceFormPageState extends State<AttendanceFormPage> {
  String? selectedEmployee;
  String? absentType;
  String? location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Form"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time
            const Text("Time"),
            const SizedBox(height: 5),
            TextFormField(
              initialValue: "07 : 45 : 56",
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Employee Name
            const Text("Employee Name"),
            const SizedBox(height: 5),
            DropdownButtonFormField<String>(
              value: selectedEmployee,
              items: ["Employee 1", "Employee 2"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => selectedEmployee = val),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            // Absent Type
            const Text("Choose Absent Type"),
            const SizedBox(height: 5),
            DropdownButtonFormField<String>(
              value: absentType,
              items: [
                "Clock In",
                "Clock Out",
                "Absent",
                "Annual Leave",
                "Sick Leave"
              ]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => absentType = val),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            // Date
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Start Date",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: "End Date",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Upload Supporting Evidence
            const Text("Upload Supporting Evidence"),
            const SizedBox(height: 5),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Save Pictures"),
            ),
            const SizedBox(height: 16),

            // Location
            const Text("Location"),
            const SizedBox(height: 5),
            DropdownButtonFormField<String>(
              value: location,
              items: ["Office", "Home", "Other"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => location = val),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            // Map (dummy)
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
              child: const Center(child: Text("Map Preview Here")),
            ),
            const SizedBox(height: 16),

            // Detail Address
            TextFormField(
              initialValue: "Malang City, East Java",
              decoration: const InputDecoration(
                labelText: "Detail Address",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Lat & Long
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Lat lokasi",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Long lokasi",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Cancel & Save Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Save"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
