import 'package:flutter/material.dart';

class UpcomingTasksWidget extends StatelessWidget {
  const UpcomingTasksWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header with red background
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFE53E3E),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Text(
              "Upcoming Tasks",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          /// Task List
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildTaskItem("Team Meeting at 14:00"),
                _buildDivider(),
                _buildTaskItem("Team Meeting at 14:00"),
                _buildDivider(),
                _buildTaskItem("Team Meeting at 14:00"),
                _buildDivider(),
                _buildTaskItem("Team Meeting at 14:00"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(String taskTitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        taskTitle,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: Colors.grey.shade200,
      margin: const EdgeInsets.symmetric(vertical: 4),
    );
  }
}