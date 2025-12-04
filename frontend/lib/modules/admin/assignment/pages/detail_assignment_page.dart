import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/data/models/assignment.dart';
import 'package:frontend/data/services/assignment_service.dart';
import 'package:intl/intl.dart';

class DetailAssignmentPage extends StatefulWidget {
  final Assignment assignment;
  
  const DetailAssignmentPage({
    super.key,
    required this.assignment,
  });

  @override
  State<DetailAssignmentPage> createState() => _DetailAssignmentPageState();
}

class _DetailAssignmentPageState extends State<DetailAssignmentPage> {
  final AssignmentService _assignmentService = AssignmentService();
  bool _isDeleting = false;

  Future<void> _deleteAssignment() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assignment'),
        content: const Text('Are you sure you want to delete this assignment? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isDeleting = true);

    try {
      print('[DELETE] Deleting assignment: ${widget.assignment.id}');
      await _assignmentService.deleteAssignment(widget.assignment.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Assignment deleted successfully'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        Navigator.pop(context, true); // Return true to trigger refresh
      }
    } catch (e) {
      print('[ERROR] Failed to delete assignment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete assignment: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignment = widget.assignment;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        foregroundColor: AppColors.neutral800,
        title: const Text(
          'Detail Assignment',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral800,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.errorRed),
            onPressed: _isDeleting ? null : _deleteAssignment,
            tooltip: 'Delete Assignment',
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Nama Kegiatan'),
            const SizedBox(height: 6),
            _buildReadonlyBox(
              assignment.title,
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            if (assignment.tags.isNotEmpty) ...[
              _sectionTitle('Tags'),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: assignment.tags.map((tag) => _TagChip(tag)).toList(),
              ),
              const SizedBox(height: 16),
            ],

            _sectionTitle('Description'),
            const SizedBox(height: 6),
            _buildReadonlyBox(
              assignment.description,
              maxLines: 4,
            ),
            const SizedBox(height: 16),

            _sectionTitle('Due Date'),
            const SizedBox(height: 6),
            _buildReadonlyBox(
              DateFormat('dd/MM/yyyy').format(assignment.dueDate),
            ),
            const SizedBox(height: 16),

            _sectionTitle('Priority'),
            const SizedBox(height: 6),
            _buildReadonlyBox(
              assignment.priority.toUpperCase(),
            ),
            const SizedBox(height: 16),

            _sectionTitle('Category'),
            const SizedBox(height: 6),
            _buildReadonlyBox(
              assignment.category,
            ),
            const SizedBox(height: 16),

            if (assignment.attachments.isNotEmpty) ...[
              _sectionTitle('Link (Optional)'),
              const SizedBox(height: 6),
              _buildReadonlyBox(assignment.attachments.first),
              const SizedBox(height: 16),
            ],

            _sectionTitle('Assigned To'),
            const SizedBox(height: 6),
            if (assignment.assignedTo.isEmpty)
              _buildReadonlyBox('No employees assigned')
            else
              ...assignment.assignedTo.map((employeeName) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.dividerGray),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowColor,
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: AppColors.primaryBlue,
                          child: Icon(Icons.person, color: AppColors.pureWhite),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            employeeName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.neutral800,
                            ),
                          ),
                        ),
                        _StatusPill(
                          text: assignment.status,
                          color: _getStatusColor(assignment.status),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            
            const SizedBox(height: 24),
            
            // Delete button at bottom
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isDeleting ? null : _deleteAssignment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorRed,
                  foregroundColor: AppColors.pureWhite,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isDeleting 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.pureWhite),
                      ),
                    )
                  : const Icon(Icons.delete),
                label: Text(_isDeleting ? 'Deleting...' : 'Delete Assignment'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('progress')) return AppColors.primaryYellow;
    if (s.contains('pending')) return AppColors.accentBlue;
    if (s.contains('done') || s.contains('complete')) return AppColors.primaryGreen;
    if (s.contains('overdue') || s.contains('late')) return AppColors.errorRed;
    return AppColors.neutral800;
  }

  // ---------- Helpers (kecil & reusable) ----------

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 14.5,
        color: AppColors.neutral800,
      ),
    );
    }

  /// Read-only box. Kalau [label] diisi, label ditampilkan di atas box.
  Widget _buildReadonlyBox(
    String value, {
    int maxLines = 1,
    String? label,
  }) {
    final box = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.dividerGray),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        value,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.neutral800,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
    );

    if (label == null) return box;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.neutral500,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        box,
      ],
    );
  }
}

// ---------- Tiny widgets ----------

class _TagChip extends StatelessWidget {
  final String text;
  const _TagChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dividerGray),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.neutral800,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  final Color color;
  const _StatusPill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(.35)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}
