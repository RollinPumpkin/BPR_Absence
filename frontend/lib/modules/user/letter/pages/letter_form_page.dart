import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/utils/image_compress_helper.dart';

class LetterFormPage extends StatefulWidget {
  final String letterType;
  final String letterTitle;
  final Color letterColor;

  const LetterFormPage({
    super.key,
    required this.letterType,
    required this.letterTitle,
    required this.letterColor,
  });

  @override
  State<LetterFormPage> createState() => _LetterFormPageState();
}

class _LetterFormPageState extends State<LetterFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _reasonController = TextEditingController();
  final _messageController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;
  File? _attachedFile;
  Uint8List? _attachedFileBytes;
  String? _attachedFileName;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _reasonController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        title: Text(
          widget.letterTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        foregroundColor: AppColors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.letterColor.withOpacity(0.1),
                      widget.letterColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.letterColor.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.letterColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIconForLetterType(),
                        color: widget.letterColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.letterTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getDescriptionForLetterType(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Subject Field
              _buildSectionTitle("Subject"),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _subjectController,
                hintText: "Enter subject of your letter",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Subject is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Date Fields (for leave requests)
              if (_needsDateFields()) ...[
                _buildSectionTitle("Duration"),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildDateField(
                        label: "Start Date",
                        selectedDate: _startDate,
                        onTap: () => _selectDate(context, true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDateField(
                        label: "End Date",
                        selectedDate: _endDate,
                        onTap: () => _selectDate(context, false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // Reason Field
              _buildSectionTitle("Reason"),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _reasonController,
                hintText: "Explain the reason for your request",
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Reason is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Additional Message
              _buildSectionTitle("Additional Message (Optional)"),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _messageController,
                hintText: "Any additional information...",
                maxLines: 4,
              ),

              const SizedBox(height: 20),

              // File Attachment Section
              _buildSectionTitle("Attachment (Optional)"),
              const SizedBox(height: 8),
              _buildAttachmentSection(),

              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSubmitting 
                        ? Colors.grey 
                        : widget.letterColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _submitLetter,
                  child: _isSubmitting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.pureWhite,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Submitting...',
                              style: TextStyle(
                                color: AppColors.pureWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Submit Letter',
                          style: TextStyle(
                            color: AppColors.pureWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: widget.letterColor),
        ),
        filled: true,
        fillColor: AppColors.pureWhite,
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedDate != null
                        ? DateFormat('dd/MM/yyyy').format(selectedDate)
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 14,
                      color: selectedDate != null 
                          ? AppColors.black87 
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: widget.letterColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          if (_attachedFileName != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.letterColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.attach_file,
                    color: widget.letterColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _attachedFileName!,
                      style: TextStyle(
                        color: widget.letterColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _removeAttachment,
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.errorRed,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            GestureDetector(
              onTap: _pickFile,
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    color: Colors.grey.shade600,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to attach document',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Supported: PDF, DOC, DOCX, JPG, PNG',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _needsDateFields() {
    return widget.letterType.toLowerCase().contains('leave') ||
           widget.letterType.toLowerCase().contains('permission');
  }

  IconData _getIconForLetterType() {
    switch (widget.letterType.toLowerCase()) {
      case 'leave request':
        return Icons.event_available;
      case 'permission letter':
        return Icons.schedule;
      case 'overtime request':
        return Icons.access_time;
      default:
        return Icons.description;
    }
  }

  String _getDescriptionForLetterType() {
    switch (widget.letterType.toLowerCase()) {
      case 'leave request':
        return 'Request for annual leave, sick leave, or personal leave';
      case 'permission letter':
        return 'Request permission to leave during work hours';
      case 'overtime request':
        return 'Request for overtime work authorization';
      default:
        return 'Submit your request or inquiry';
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: widget.letterColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Reset end date if it's before start date
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (file != null) {
        // Auto-compress if needed
        final compressedPath = await ImageCompressHelper.compressImageIfNeeded(file.path);
        final bytes = await File(compressedPath).readAsBytes();
        setState(() {
          if (kIsWeb) {
            _attachedFileBytes = bytes;
          } else {
            _attachedFile = File(compressedPath);
          }
          _attachedFileName = file.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  void _removeAttachment() {
    setState(() {
      _attachedFile = null;
      _attachedFileBytes = null;
      _attachedFileName = null;
    });
  }

  Future<void> _submitLetter() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_needsDateFields() && (_startDate == null || _endDate == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start and end dates'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Letter submitted successfully!'),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Return to previous page
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error submitting letter: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}