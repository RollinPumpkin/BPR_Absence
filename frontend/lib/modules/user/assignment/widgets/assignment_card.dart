import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class UserAssignmentCard extends StatelessWidget {
  final String title;
  final String description;
  final String deadline;
  final String status;
  final Color statusColor;
  final String priority;
  final Color priorityColor;

  const UserAssignmentCard({
    super.key,
    required this.title,
    required this.description,
    required this.deadline,
    required this.status,
    required this.statusColor,
    required this.priority,
    required this.priorityColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and priority
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  priority,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: priorityColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),

          // Deadline and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    deadline,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _showAssignmentDetails(context);
                  },
                  child: const Text("View Details"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: status == "Completed" ? null : () {
                    _showSubmitDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: status == "Completed" ? Colors.grey : AppColors.primaryBlue,
                  ),
                  child: Text(
                    status == "Completed" ? "Completed" : "Submit",
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAssignmentDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Description:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(description),
            SizedBox(height: 8),
            Text("Deadline:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(deadline),
            SizedBox(height: 8),
            Text("Priority:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(priority),
            SizedBox(height: 8),
            Text("Status:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(status),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showSubmitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Submit Assignment"),
        content: const Text("Are you sure you want to submit this assignment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Assignment submitted successfully!"),
                  backgroundColor: AppColors.primaryGreen,
                ),
              );
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}
