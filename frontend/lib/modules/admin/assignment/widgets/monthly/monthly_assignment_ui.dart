import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:frontend/data/models/assignment.dart';
import '../../pages/add_assignment_step1_page.dart';
import 'assignment_card.dart';
import 'package:frontend/core/constants/colors.dart';

class MonthlyAssignmentUI extends StatefulWidget {
  final List<Assignment> assignments;
  
  const MonthlyAssignmentUI({
    super.key,
    required this.assignments,
  });

  @override
  State<MonthlyAssignmentUI> createState() => _MonthlyAssignmentUIState();
}

class _MonthlyAssignmentUIState extends State<MonthlyAssignmentUI> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Assignment> _selectedDayAssignments = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _updateSelectedDayAssignments();
  }

  void _updateSelectedDayAssignments() {
    if (_selectedDay == null) {
      _selectedDayAssignments = [];
      return;
    }
    
    _selectedDayAssignments = widget.assignments.where((assignment) {
      return assignment.dueDate.year == _selectedDay!.year &&
             assignment.dueDate.month == _selectedDay!.month &&
             assignment.dueDate.day == _selectedDay!.day;
    }).toList();
  }

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
              _updateSelectedDayAssignments();
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

        // List Assignment for selected day
        Row(
          children: [
            const Text(
              "Assignments",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (_selectedDay != null)
              Text(
                "${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}",
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.neutral500,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Show assignments for selected day
        if (_selectedDayAssignments.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.dividerGray),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.assignment_outlined, size: 48, color: AppColors.neutral400),
                  SizedBox(height: 8),
                  Text(
                    'No assignments for this date',
                    style: TextStyle(
                      color: AppColors.neutral500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ..._selectedDayAssignments.map((assignment) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AssignmentCard(assignment: assignment),
              )).toList(),
      ],
    );
  }
}
