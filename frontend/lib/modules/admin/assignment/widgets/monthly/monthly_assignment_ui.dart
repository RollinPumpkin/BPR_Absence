import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../pages/add_assignment_step1_page.dart';
import 'assignment_card.dart';
import 'package:frontend/core/constants/colors.dart';

class MonthlyAssignmentUI extends StatefulWidget {
  const MonthlyAssignmentUI({super.key});

  @override
  State<MonthlyAssignmentUI> createState() => _MonthlyAssignmentUIState();
}

class _MonthlyAssignmentUIState extends State<MonthlyAssignmentUI> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Calendar
        TableCalendar(
          firstDay: DateTime.utc(2000, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: CalendarFormat.month,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.black),
            rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.black),
          ),
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: AppColors.darkGray,
              shape: BoxShape.circle,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Add Data button
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.pureWhite,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.add),
            label: const Text("Add Data"),
          ),
        ),
        const SizedBox(height: 16),

        // List Assignment
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
