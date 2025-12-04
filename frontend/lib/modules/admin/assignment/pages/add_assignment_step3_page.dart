import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/data/services/assignment_service.dart';
import 'stepper_widgets.dart';
import '../models/assignment_draft.dart';

class AddAssignmentStep3Page extends StatefulWidget {
  final AssignmentDraft draft;
  final List<String> employees; // User IDs for backend
  final List<String> employeeNames; // Names for display

  const AddAssignmentStep3Page({
    super.key,
    required this.draft,
    required this.employees,
    required this.employeeNames,
  });

  @override
  State<AddAssignmentStep3Page> createState() => _AddAssignmentStep3PageState();
}

class _AddAssignmentStep3PageState extends State<AddAssignmentStep3Page> {
  final AssignmentService _assignmentService = AssignmentService();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Assignment - Confirmation"),
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        foregroundColor: AppColors.black,
      ),
      body: Column(
        children: [
          // 🔹 Stepper Indicator
          const Padding(
            padding: EdgeInsets.only(top: 20, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StepCircle(number: "1", isActive: false),
                StepLine(),
                StepCircle(number: "2", isActive: false),
                StepLine(),
                StepCircle(number: "3", isActive: true),
              ],
            ),
          ),

          // 🔹 Summary Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Section
                  const Text(
                    "Review Assignment Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Please review the information before creating the assignment",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Assignment Details Card
                  _buildSectionCard(
                    title: "Assignment Details",
                    children: [
                      _buildDetailRow("Name", widget.draft.name),
                      const Divider(height: 20),
                      _buildDetailRow("Description", widget.draft.description),
                      const Divider(height: 20),
                      _buildDetailRow("Priority", widget.draft.priority.toUpperCase()),
                      if (widget.draft.startDate != null || widget.draft.endDate != null) ...[
                        const Divider(height: 20),
                        _buildDetailRow(
                          "Date Range",
                          "${widget.draft.startDate != null ? '${widget.draft.startDate!.day}/${widget.draft.startDate!.month}/${widget.draft.startDate!.year}' : 'Not set'} - ${widget.draft.endDate != null ? '${widget.draft.endDate!.day}/${widget.draft.endDate!.month}/${widget.draft.endDate!.year}' : 'Not set'}",
                        ),
                      ],
                      if (widget.draft.time != null) ...[
                        const Divider(height: 20),
                        _buildDetailRow(
                          "Time",
                          "${widget.draft.time!.hour.toString().padLeft(2, '0')}:${widget.draft.time!.minute.toString().padLeft(2, '0')}",
                        ),
                      ],
                      if (widget.draft.link != null && widget.draft.link!.isNotEmpty) ...[
                        const Divider(height: 20),
                        _buildDetailRow("Link", widget.draft.link!),
                      ],
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Assigned Employees Card
                  _buildSectionCard(
                    title: "Assigned Employees (${widget.employeeNames.length})",
                    children: [
                      ...widget.employeeNames.map((name) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 20,
                                color: AppColors.primaryGreen,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),

          // 🔹 Action Buttons
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
                    child: const Text("Back"),
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
                    onPressed: _isSaving ? null : () => _saveAssignment(context),
                    child: _isSaving
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.pureWhite,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text("Saving..."),
                            ],
                          )
                        : const Text("Save Assignment"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }

  void _saveAssignment(BuildContext context) async {
    if (_isSaving) return;
    
    setState(() {
      _isSaving = true;
    });

    try {
      print('[SAVE] Starting assignment save...');
      
      // Prepare data for backend
      // Backend expects: title, description, assignedTo (user IDs), dueDate, priority, category
      final assignmentData = {
        'title': widget.draft.name,
        'description': widget.draft.description,
        'assignedTo': widget.employees, // Send IDs for backend validation
        'dueDate': widget.draft.endDate?.toIso8601String() ?? DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        'priority': widget.draft.priority, // Use priority from draft (not hardcoded)
        'category': widget.draft.categories.isNotEmpty ? widget.draft.categories.first : 'general',
        'tags': widget.draft.categories,
        'attachments': widget.draft.link != null ? [widget.draft.link] : [],
      };
      
      print('[EMPLOYEE_DATA] IDs: ${widget.employees}');
      print('[EMPLOYEE_DATA] Names: ${widget.employeeNames}');
      print('[EMPLOYEE_DATA] Sending assignedTo (IDs): ${assignmentData['assignedTo']}');
      
      // Add time if available
      if (widget.draft.time != null) {
        assignmentData['time'] = "${widget.draft.time!.hour.toString().padLeft(2, '0')}:${widget.draft.time!.minute.toString().padLeft(2, '0')}";
      }
      
      // Add start date if available
      if (widget.draft.startDate != null) {
        assignmentData['startDate'] = widget.draft.startDate!.toIso8601String();
      }
      
      print('[DATA] Sending assignment data: $assignmentData');
      
      // Call API to create assignment
      final result = await _assignmentService.createAssignment(assignmentData);
      
      print('[SUCCESS] Assignment created: $result');
      
      setState(() {
        _isSaving = false;
      });
      
      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Assignment created successfully!"),
            backgroundColor: AppColors.primaryGreen,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Wait a moment for the snackbar to show
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Navigate back to assignment page and trigger refresh
        // Pop all 3 steps and return true to indicate success
        if (context.mounted) {
          Navigator.of(context)
            ..pop(true) // Step 3 -> Step 2 (return true)
            ..pop(true) // Step 2 -> Step 1 (return true)
            ..pop(true); // Step 1 -> Assignment Page (return true to trigger refresh)
        }
      }
      
    } catch (e) {
      print('[ERROR] Error saving assignment: $e');
      
      setState(() {
        _isSaving = false;
      });
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to create assignment: ${e.toString()}"),
            backgroundColor: AppColors.errorRed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
