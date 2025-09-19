import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/custom_bottom_nav.dart';
import 'package:frontend/modules/user/dashboard/dashboard_page.dart';
import 'package:frontend/modules/user/attendance/attendance_page.dart';
import 'package:frontend/modules/user/letter/letter_page.dart';
import 'package:frontend/modules/user/profile/profile_page.dart';
import 'package:frontend/modules/user/shared/user_navigation_constants.dart';

import 'widgets/assignment_card.dart';
import 'widgets/assignment_filter.dart';

class UserAssignmentPage extends StatefulWidget {
  const UserAssignmentPage({super.key});

  @override
  State<UserAssignmentPage> createState() => _UserAssignmentPageState();
}

class _UserAssignmentPageState extends State<UserAssignmentPage> {
  String selectedFilter = "All";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "My Assignments",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// Filter Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: AssignmentFilter(
                selectedFilter: selectedFilter,
                onFilterChanged: (filter) {
                  setState(() {
                    selectedFilter = filter;
                  });
                },
              ),
            ),

            /// Assignments List
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return UserAssignmentCard(
                  title: _getAssignmentTitle(index),
                  description: _getAssignmentDescription(index),
                  deadline: _getAssignmentDeadline(index),
                  status: _getAssignmentStatus(index),
                  statusColor: _getAssignmentStatusColor(index),
                  priority: _getAssignmentPriority(index),
                  priorityColor: _getAssignmentPriorityColor(index),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 2,
        icons: UserNavigationConstants.icons,
        pages: UserNavigationConstants.pages,
      ),
    );
  }

  String _getAssignmentTitle(int index) {
    final titles = [
      "Weekly Report",
      "Client Meeting Preparation",
      "Budget Analysis",
      "Team Presentation",
      "Project Review",
      "Documentation Update",
    ];
    return titles[index % titles.length];
  }

  String _getAssignmentDescription(int index) {
    final descriptions = [
      "Prepare and submit weekly progress report",
      "Prepare materials for upcoming client meeting",
      "Analyze budget allocation for Q1",
      "Create presentation for team meeting",
      "Review and evaluate current project status",
      "Update project documentation and guidelines",
    ];
    return descriptions[index % descriptions.length];
  }

  String _getAssignmentDeadline(int index) {
    final deadlines = [
      "Today, 5:00 PM",
      "Tomorrow, 2:00 PM",
      "Jan 20, 2025",
      "Jan 22, 2025",
      "Jan 25, 2025",
      "Jan 28, 2025",
    ];
    return deadlines[index % deadlines.length];
  }

  String _getAssignmentStatus(int index) {
    final statuses = ["Pending", "In Progress", "Review", "Completed", "Overdue", "Pending"];
    return statuses[index % statuses.length];
  }

  Color _getAssignmentStatusColor(int index) {
    final colors = [Colors.orange, Colors.blue, Colors.purple, Colors.green, Colors.red, Colors.orange];
    return colors[index % colors.length];
  }

  String _getAssignmentPriority(int index) {
    final priorities = ["High", "Medium", "Low", "High", "Medium", "Low"];
    return priorities[index % priorities.length];
  }

  Color _getAssignmentPriorityColor(int index) {
    final colors = [Colors.red, Colors.orange, Colors.green, Colors.red, Colors.orange, Colors.green];
    return colors[index % colors.length];
  }
}
