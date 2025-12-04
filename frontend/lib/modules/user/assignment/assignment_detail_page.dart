import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/data/services/assignment_service.dart';

class AssignmentDetailPage extends StatefulWidget {
  final Map<String, dynamic> assignment;

  const AssignmentDetailPage({
    super.key,
    required this.assignment,
  });

  @override
  State<AssignmentDetailPage> createState() => _AssignmentDetailPageState();
}

class _AssignmentDetailPageState extends State<AssignmentDetailPage> {
  String activityName = "";
  String description = "";
  String time = "";
  String link = "";
  
  String selectedStartDate = "";
  String selectedEndDate = "";
  
  // User info from SharedPreferences
  String userName = "";
  String userRole = "";
  
  // Real-time clock
  Timer? _timer;
  String currentTime = "";
  bool _isLoading = false;
  final AssignmentService _assignmentService = AssignmentService();
  
  // Completion status
  bool isCompleted = false;
  String? completionTime;

  @override
  void initState() {
    super.initState();
    _loadAssignmentData(); // Load data first
    _loadUserInfo();
    // _startClock will be called after data is loaded
  }
  
  void _startClock() {
    // Don't start clock if already completed
    if (isCompleted) {
      setState(() {
        currentTime = completionTime ?? "00:00:00";
      });
      return;
    }
    
    // Set initial time
    setState(() {
      currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
    });
    
    // Update every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Stop timer if completed
      if (isCompleted) {
        timer.cancel();
        return;
      }
      
      if (mounted) {
        setState(() {
          currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
        });
      }
    });
  }
  
  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'User';
      userRole = prefs.getString('user_role') ?? 'Employee';
    });
  }
  
  void _loadAssignmentData() {
    print('📥 [INIT] Loading assignment data...');
    print('📥 [INIT] Raw assignment data: ${widget.assignment}');
    
    setState(() {
      // Load data from widget.assignment
      activityName = widget.assignment['title'] ?? '';
      description = widget.assignment['description'] ?? '';
      
      // Check if already completed
      final status = widget.assignment['status']?.toString().toLowerCase();
      isCompleted = status == 'completed';
      
      // If completed, get completion time
      if (isCompleted && widget.assignment['completionTime'] != null) {
        completionTime = widget.assignment['completionTime'];
      }
      
      print('🔍 [INIT] Assignment loaded: $activityName');
      print('🔍 [INIT] Status: $status, isCompleted: $isCompleted');
      print('🔍 [INIT] Completion time from data: ${widget.assignment['completionTime']}');
      print('🔍 [INIT] Completion time variable: $completionTime');
      
      // Parse dates
      if (widget.assignment['startDate'] != null) {
        final startDate = _parseDate(widget.assignment['startDate']);
        if (startDate != null) {
          selectedStartDate = DateFormat('dd/MM/yyyy').format(startDate);
        }
      }
      
      if (widget.assignment['dueDate'] != null) {
        final dueDate = _parseDate(widget.assignment['dueDate']);
        if (dueDate != null) {
          selectedEndDate = DateFormat('dd/MM/yyyy').format(dueDate);
        }
      }
      
      // Parse attachments/links
      if (widget.assignment['attachments'] != null && widget.assignment['attachments'] is List) {
        final attachments = List<String>.from(widget.assignment['attachments']);
        if (attachments.isNotEmpty) {
          link = attachments.first;
        }
      }
    });
    
    // NOW start the clock after data is loaded
    _startClock();
  }
  
  DateTime? _parseDate(dynamic dateData) {
    if (dateData == null) return null;
    
    // Handle Firestore timestamp format
    if (dateData is Map<String, dynamic> && dateData.containsKey('_seconds')) {
      final seconds = dateData['_seconds'] as int;
      final nanoseconds = dateData['_nanoseconds'] as int? ?? 0;
      return DateTime.fromMillisecondsSinceEpoch(
        seconds * 1000 + (nanoseconds ~/ 1000000),
        isUtc: false,
      );
    }
    
    // Handle string format
    if (dateData is String) {
      return DateTime.tryParse(dateData)?.toLocal();
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Detail Assignment",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Activity Name Section
            /// Activity Name Section (READ ONLY)
            const Text(
              "Nama Kegiatan",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                activityName.isEmpty ? "-" : activityName,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.black,
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            /// Description Section (READ ONLY)
            const Text(
              "Description*",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              constraints: const BoxConstraints(minHeight: 100),
              child: Text(
                description.isEmpty ? "-" : description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.black,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Date Section (READ-ONLY FROM DATABASE)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Start Date",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.grey.shade600, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              selectedStartDate.isEmpty ? "-" : selectedStartDate,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "End Date",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.grey.shade600, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              selectedEndDate.isEmpty ? "-" : selectedEndDate,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// Time Section (REAL-TIME CLOCK OR COMPLETION TIME)
            Text(
              isCompleted ? "Waktu Selesai" : "Waktu Penyelesaian",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCompleted 
                    ? AppColors.primaryGreen.withOpacity(0.1)
                    : AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCompleted
                      ? AppColors.primaryGreen.withOpacity(0.3)
                      : AppColors.primaryBlue.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isCompleted ? Icons.check_circle : Icons.access_time,
                    color: isCompleted ? AppColors.primaryGreen : AppColors.primaryBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currentTime,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? AppColors.primaryGreen : AppColors.primaryBlue,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isCompleted
                  ? "Assignment telah diselesaikan"
                  : "Jam akan tersimpan otomatis saat Anda menekan Done",
              style: TextStyle(
                fontSize: 12,
                color: isCompleted ? AppColors.primaryGreen : Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: 20),

            /// Link Section (READ ONLY)
            const Text(
              "Link (Optional)",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                link.isEmpty ? "-" : link,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryBlue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Employee Assignment Section (SHOW CURRENT USER ONLY)
            const Text(
              "Employee Assignment",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.black87,
              ),
            ),

            const SizedBox(height: 12),

            /// Current User Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryBlue.withOpacity(0.2),
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName.isEmpty ? "Loading..." : userName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black87,
                          ),
                        ),
                        Text(
                          userRole,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Assigned",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// Done Button (SAVE COMPLETION TIMESTAMP OR DISABLED IF COMPLETED)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (isCompleted || _isLoading) ? null : _completeAssignment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted ? Colors.grey : AppColors.primaryBlue,
                  foregroundColor: AppColors.pureWhite,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        isCompleted ? "Selesai ✓" : "Done",
                        style: const TextStyle(
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
    );
  }
  
  Future<void> _completeAssignment() async {
    try {
      // Get current timestamp FIRST before any async operations
      final now = DateTime.now();
      final completionDate = DateFormat('yyyy-MM-dd').format(now);
      final completionTimeString = DateFormat('HH:mm:ss').format(now);
      
      print('⏰ [COMPLETE] Starting completion at: $completionTimeString');
      
      // Stop the timer IMMEDIATELY before setState
      _timer?.cancel();
      _timer = null;
      print('⏹️ [COMPLETE] Timer stopped');
      
      // Update UI immediately to freeze the clock
      setState(() {
        _isLoading = true;
        isCompleted = true;
        completionTime = completionTimeString;
        currentTime = completionTimeString; // Freeze at completion time
      });
      print('🔒 [COMPLETE] UI frozen at: $completionTimeString');
      
      // Debug: Print entire assignment object
      print('🔍 [DEBUG] widget.assignment keys: ${widget.assignment.keys.toList()}');
      print('🔍 [DEBUG] widget.assignment values:');
      widget.assignment.forEach((key, value) {
        print('  $key: $value (${value.runtimeType})');
      });
      
      // Try multiple ways to get ID
      final assignmentId = widget.assignment['id'] ?? 
                          widget.assignment['_id'] ?? 
                          widget.assignment['assignmentId'];
      
      if (assignmentId == null || assignmentId.toString().isEmpty) {
        print('❌ [ERROR] Assignment ID is null or empty');
        print('🔍 Available keys: ${widget.assignment.keys.toList()}');
        
        // Revert state if ID not found
        if (mounted) {
          setState(() {
            isCompleted = false;
            completionTime = null;
            _isLoading = false;
          });
          _startClock(); // Restart clock
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Assignment ID tidak ditemukan'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      print('✅ Assignment ID found: $assignmentId');
      print('📝 Completing assignment: $assignmentId');
      print('⏰ Completion time: $completionDate $completionTimeString');
      print('📤 [COMPLETE] Sending to server...');
      
      // NOW update to server (async operation)
      await _assignmentService.updateAssignment(
        assignmentId,
        {
          'status': 'completed',
          'completedAt': now.toIso8601String(),
          'completionDate': completionDate,
          'completionTime': completionTimeString,
        },
      );
      
      print('✅ [COMPLETE] Server updated successfully');
      
      if (mounted) {
        // Update loading state
        setState(() {
          _isLoading = false;
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Assignment selesai pada $completionTimeString'),
            backgroundColor: AppColors.primaryGreen,
            duration: const Duration(seconds: 1),
          ),
        );
        
        // Wait a moment for user to see the success message
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Go back with refresh flag
        if (mounted) {
          print('🔙 [COMPLETE] Navigating back with refresh flag');
          Navigator.pop(context, true); // Return true to indicate completion
        }
      }
    } catch (e) {
      print('❌ Error completing assignment: $e');
      
      if (mounted) {
        // Revert completion state on error
        setState(() {
          isCompleted = false;
          completionTime = null;
          _isLoading = false;
        });
        _startClock(); // Restart clock
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyelesaikan assignment: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  @override
  void dispose() {
    _timer?.cancel(); // Stop the clock timer
    super.dispose();
  }
}