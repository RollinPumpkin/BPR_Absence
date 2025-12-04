import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:frontend/data/models/assignment.dart';
import '../../pages/add_assignment_step1_page.dart';
import 'assignment_card.dart';
import 'package:frontend/core/constants/colors.dart';

class MonthlyAssignmentUI extends StatefulWidget {
  final List<Assignment> assignments;
  final VoidCallback? onRefreshNeeded;
  
  const MonthlyAssignmentUI({
    super.key,
    required this.assignments,
    this.onRefreshNeeded,
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

  @override
  void didUpdateWidget(MonthlyAssignmentUI oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update selected day assignments when widget is rebuilt with new data
    if (oldWidget.assignments != widget.assignments) {
      print('[MONTHLY_UI] Assignments updated - refreshing selected day');
      _updateSelectedDayAssignments();
    }
  }

  void _updateSelectedDayAssignments() {
    if (_selectedDay == null) {
      _selectedDayAssignments = [];
      return;
    }
    
    // Get assignments that fall on selected day (considering date range from startDate to dueDate)
    _selectedDayAssignments = widget.assignments.where((assignment) {
      final selectedDate = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
      final dueDate = DateTime(assignment.dueDate.year, assignment.dueDate.month, assignment.dueDate.day);
      
      // If assignment has startDate, check if selected day is within range
      if (assignment.startDate != null) {
        final startDate = DateTime(assignment.startDate!.year, assignment.startDate!.month, assignment.startDate!.day);
        // Selected day must be between startDate and dueDate (inclusive)
        return (selectedDate.isAtSameMomentAs(startDate) || selectedDate.isAfter(startDate)) &&
               (selectedDate.isAtSameMomentAs(dueDate) || selectedDate.isBefore(dueDate));
      } else {
        // If no startDate, only show on due date
        return assignment.dueDate.year == _selectedDay!.year &&
               assignment.dueDate.month == _selectedDay!.month &&
               assignment.dueDate.day == _selectedDay!.day;
      }
    }).toList();
  }

  // Check if a date has any assignments (considering date ranges)
  bool _hasAssignments(DateTime day) {
    final checkDate = DateTime(day.year, day.month, day.day);
    
    return widget.assignments.any((assignment) {
      final dueDate = DateTime(assignment.dueDate.year, assignment.dueDate.month, assignment.dueDate.day);
      
      // If assignment has startDate, check if day is within range
      if (assignment.startDate != null) {
        final startDate = DateTime(assignment.startDate!.year, assignment.startDate!.month, assignment.startDate!.day);
        // Check if day is between startDate and dueDate (inclusive)
        return (checkDate.isAtSameMomentAs(startDate) || checkDate.isAfter(startDate)) &&
               (checkDate.isAtSameMomentAs(dueDate) || checkDate.isBefore(dueDate));
      } else {
        // If no startDate, only check due date
        return assignment.dueDate.year == day.year &&
               assignment.dueDate.month == day.month &&
               assignment.dueDate.day == day.day;
      }
    });
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
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.black),
            rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.black),
          ),
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: AppColors.primaryYellow,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: TextStyle(
              color: AppColors.pureWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              // Color dates with assignments in red
              if (_hasAssignments(day)) {
                final isSelected = isSameDay(_selectedDay, day);
                final isToday = isSameDay(DateTime.now(), day);
                
                // Don't override today or selected styling
                if (isToday || isSelected) return null;
                
                return Container(
                  margin: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryRed,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(
                        color: AppColors.pureWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }
              return null;
            },
          ),
        ),

        const SizedBox(height: 12),

        // Add Data button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              print('[ADD_DATA] Button clicked - navigating to Step 1');
              try {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddAssignmentStep1Page(),
                  ),
                );
                
                print('[RETURN] Returned from assignment creation with result: $result');
                
                // Always trigger refresh to ensure data is up to date
                if (widget.onRefreshNeeded != null) {
                  print('[REFRESH] Triggering refresh callback...');
                  widget.onRefreshNeeded!();
                  
                  // Show success message if assignment was created
                  if (result == true && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Assignment list refreshed!'),
                        backgroundColor: AppColors.primaryGreen,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                } else {
                  print('[WARNING] Callback is null - cannot refresh');
                }
              } catch (e) {
                print('[ERROR] Navigation error: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.errorRed,
                    ),
                  );
                }
              }
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
                child: AssignmentCard(
                  assignment: assignment,
                  onDeleted: widget.onRefreshNeeded,
                ),
              )),
      ],
    );
  }
}
