import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/widgets/custom_bottom_nav_router.dart';
import 'package:frontend/modules/admin/shared/admin_nav_items.dart';
import 'package:frontend/data/services/letter_service.dart';
import 'package:frontend/data/services/assignment_service.dart';
import 'package:frontend/data/services/attendance_service.dart';
import 'package:frontend/data/models/letter.dart';
import 'package:frontend/data/models/assignment.dart';
import 'package:frontend/data/models/attendance.dart';
import 'package:frontend/modules/admin/letter/pages/letter_acceptance_page.dart';
import 'package:frontend/utils/diagnostic_service.dart';


import 'widgets/header.dart';
import 'widgets/menu_button.dart';
import 'widgets/section_title.dart';
import 'widgets/letter/letter_card.dart';
import 'widgets/assignment/assignment_card.dart';
import 'widgets/attendance/attendance_card.dart';
import 'widgets/attendance/attendance_chart.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final LetterService _letterService = LetterService();
  final AssignmentService _assignmentService = AssignmentService();
  final AttendanceService _attendanceService = AttendanceService();
  
  List<Letter> _pendingLetters = [];
  bool _isLoadingLetters = true;
  String? _letterError;

  List<Assignment> _assignments = [];
  bool _isLoadingAssignments = true;
  String? _assignmentError;

  List<Attendance> _attendanceRecords = [];
  bool _isLoadingAttendance = true;
  String? _attendanceError;

  bool _showAllLetters = false;
  bool _showAllAssignments = false;
  bool _showAllAttendance = false;

  @override
  void initState() {
    super.initState();
    // Load data after widget is built to prevent crashes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadPendingLetters().catchError((e) {
          print('❌ Error loading letters: $e');
        });
        _loadAssignments().catchError((e) {
          print('❌ Error loading assignments: $e');
        });
        _loadAttendanceRecords().catchError((e) {
          print('❌ Error loading attendance: $e');
        });
      }
    });
  }

  Future<void> _loadPendingLetters() async {
    print('🔄 Dashboard: Starting to load pending letters...');
    if (mounted) {
      setState(() {
        _isLoadingLetters = true;
        _letterError = null;
      });
    }

    try {
      print('🔍 Dashboard: Fetching pending letters...');
      final pendingResponse = await _letterService.getPendingLetters(limit: 50);
      
      print('🔍 Dashboard: Fetching received letters...');
      final receivedResponse = await _letterService.getReceivedLetters(limit: 50);
      
      print('🔍 Dashboard: Pending response success: ${pendingResponse.success}');
      print('🔍 Dashboard: Received response success: ${receivedResponse.success}');
      
      List<Letter> allLetters = [];
      
      // Add pending letters
      if (pendingResponse.success && pendingResponse.data != null) {
        print('🔍 Dashboard: Adding ${pendingResponse.data!.items.length} pending letters');
        allLetters.addAll(pendingResponse.data!.items);
      } else {
        print('🔍 Dashboard: No pending letters or error: ${pendingResponse.message}');
      }
      
      // Add received letters (approved/rejected)
      if (receivedResponse.success && receivedResponse.data != null) {
        print('🔍 Dashboard: Adding ${receivedResponse.data!.items.length} received letters');
        allLetters.addAll(receivedResponse.data!.items);
      } else {
        print('🔍 Dashboard: No received letters or error: ${receivedResponse.message}');
      }
      
      // Remove duplicates by ID
      final Map<String, Letter> uniqueLetters = {};
      for (Letter letter in allLetters) {
        uniqueLetters[letter.id] = letter;
      }
      
      print('🔍 Dashboard: Total unique letters: ${uniqueLetters.length}');
      
      // Filter for pending status only (same logic as Letters Page)
      final pendingLetters = uniqueLetters.values.where((letter) => 
        letter.status == 'waiting_approval' || letter.status == 'pending'
      ).toList();
      
      print('🔍 Dashboard: Filtered pending letters: ${pendingLetters.length}');
      
      if (mounted) {
        setState(() {
          _pendingLetters = pendingLetters;
          _isLoadingLetters = false;
        });
      }
      
    } catch (e) {
      print('❌ Dashboard: Error loading letters: $e');
      if (mounted) {
        setState(() {
          _letterError = 'Failed to load letters: $e';
          _isLoadingLetters = false;
          _pendingLetters = []; // Empty list instead of dummy data
        });
      }
    }
  }



  Future<void> _loadAssignments() async {
    print('🔄 Dashboard: Starting to load assignments...');
    if (mounted) {
      setState(() {
        _isLoadingAssignments = true;
        _assignmentError = null;
      });
    }

    try {
      DiagnosticService.logApiResponse('Assignments', 'Starting request...');
      final assignments = await _assignmentService.getAllAssignments();
      
      DiagnosticService.logApiResponse('Assignments', 'Response received, count: ${assignments.length}');
      print('✅ Dashboard: Assignments loaded - ${assignments.length} assignments');
      if (mounted) {
        setState(() {
          _assignments = assignments;
          _isLoadingAssignments = false;
        });
      }
    } catch (e, stackTrace) {
      DiagnosticService.logError('Dashboard Assignment Loading', e, stackTrace);
      print('❌ Dashboard: Error loading assignments: $e');
      if (mounted) {
        setState(() {
          _assignmentError = 'Failed to load assignments: $e';
          _isLoadingAssignments = false;
          _assignments = []; // Empty list instead of dummy data
        });
      }
    }
  }



  Future<void> _loadAttendanceRecords() async {
    print('🔄 Dashboard: Starting to load attendance records...');
    if (mounted) {
      setState(() {
        _isLoadingAttendance = true;
        _attendanceError = null;
      });
    }

    try {
      final response = await _attendanceService.getAttendanceRecords();
      
      if (response.success && response.data != null) {
        print('✅ Dashboard: Attendance loaded - ${response.data!.items.length} records');
        if (mounted) {
          setState(() {
            _attendanceRecords = response.data!.items;
            _isLoadingAttendance = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _attendanceError = 'Failed to load attendance data: ${response.message}';
            _isLoadingAttendance = false;
            _attendanceRecords = []; // Empty list instead of dummy data
          });
        }
      }
    } catch (e) {
      print('❌ Dashboard: Error loading attendance: $e');
      if (mounted) {
        setState(() {
          _attendanceError = 'Failed to load attendance: $e';
          _isLoadingAttendance = false;
          _attendanceRecords = []; // Empty list instead of dummy data
        });
      }
    }
  }



  Future<void> _approveLetter(Letter letter) async {
    try {
      final response = await _letterService.approveLetter(letter.id);
      
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Letter approved successfully'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        _loadPendingLetters(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to approve letter: ${response.message}'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error approving letter: $e'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }

  Future<void> _rejectLetter(Letter letter, String? reason) async {
    try {
      final response = await _letterService.rejectLetter(
        letter.id,
        reason: reason,
      );
      
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Letter rejected successfully'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
        _loadPendingLetters(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reject letter: ${response.message}'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error rejecting letter: $e'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }

  void _navigateToLetterAcceptance() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LetterAcceptancePage(),
      ),
    );
  }



  Widget _buildLettersSection() {
    if (_isLoadingLetters) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryBlue,
          ),
        ),
      );
    }

    if (_letterError != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: AppColors.primaryRed.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.error, color: AppColors.primaryRed),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _letterError!,
                    style: const TextStyle(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _loadPendingLetters,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_pendingLetters.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          color: AppColors.neutral100,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.primaryGreen),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No pending letters to review',
                    style: TextStyle(
                      color: AppColors.neutral500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Display letters based on _showAllLetters flag
    final displayLetters = _showAllLetters 
        ? _pendingLetters 
        : _pendingLetters.take(2).toList();

    return Column(
      children: [
        // Letters list - make it scrollable when showing all
        if (_showAllLetters)
          Container(
            height: 300, // Fixed height for scrollable area
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 0),
              itemCount: displayLetters.length,
              itemBuilder: (context, index) {
                final letter = displayLetters[index];
                return LetterCard(
                  name: letter.senderName ?? 'Unknown',
                  status: _getStatusText(letter.letterType),
                  statusColor: _getStatusColor(letter.letterType),
                  dateText: _formatDate(letter.createdAt ?? DateTime.now()),
                  category: _formatLetterType(letter.letterType),
                  summary: letter.content.length > 80 
                      ? '${letter.content.substring(0, 80)}...'
                      : letter.content,
                  stageText: 'Waiting Approval',
                  onViewTap: () => _showLetterQuickActions(letter),
                );
              },
            ),
          )
        else
          // Show limited letters without scroll for preview
          ...displayLetters.map((letter) {
            return LetterCard(
              name: letter.senderName ?? 'Unknown',
              status: _getStatusText(letter.letterType),
              statusColor: _getStatusColor(letter.letterType),
              dateText: _formatDate(letter.createdAt ?? DateTime.now()),
              category: _formatLetterType(letter.letterType),
              summary: letter.content.length > 80 
                  ? '${letter.content.substring(0, 80)}...'
                  : letter.content,
              stageText: 'Waiting Approval',
              onViewTap: () => _showLetterQuickActions(letter),
            );
          }).toList(),
        
        // Show more/less button if there are more than 2 letters
        if (_pendingLetters.length > 2)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextButton(
              onPressed: () {
                setState(() {
                  _showAllLetters = !_showAllLetters;
                });
              },
              child: Text(
                _showAllLetters 
                    ? 'Show Less' 
                    : 'Show All (${_pendingLetters.length} total)',
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _getStatusText(String letterType) {
    switch (letterType.toLowerCase()) {
      case 'sick_leave':
        return 'Sick Leave';
      case 'annual_leave':
        return 'Annual Leave';
      case 'personal_leave':
        return 'Personal Leave';
      case 'certificate':
        return 'Certificate';
      default:
        return 'Request';
    }
  }

  Color _getStatusColor(String letterType) {
    switch (letterType.toLowerCase()) {
      case 'sick_leave':
        return AppColors.primaryRed;
      case 'annual_leave':
        return AppColors.primaryYellow;
      case 'personal_leave':
        return AppColors.primaryBlue;
      case 'certificate':
        return AppColors.primaryGreen;
      default:
        return AppColors.neutral500;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatLetterType(String letterType) {
    switch (letterType.toLowerCase()) {
      case 'sick_leave':
        return 'Sick Leave Request';
      case 'annual_leave':
        return 'Annual Leave Request';
      case 'personal_leave':
        return 'Personal Leave Request';
      case 'certificate':
        return 'Work Certificate Request';
      default:
        return letterType.replaceAll('_', ' ').split(' ').map((word) => 
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)
        ).join(' ');
    }
  }

  void _showLetterQuickActions(Letter letter) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Letter Actions',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'From: ${letter.senderName ?? 'Unknown'}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              'Type: ${_formatLetterType(letter.letterType)}',
              style: const TextStyle(color: AppColors.neutral500),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _approveLetter(letter);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showRejectDialog(letter);
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToLetterAcceptance();
                },
                child: const Text('View Full Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(Letter letter) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Letter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to reject this letter from ${letter.senderName}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectLetter(letter, reasonController.text.trim().isEmpty 
                  ? null : reasonController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentsSection() {
    if (_isLoadingAssignments) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryBlue,
          ),
        ),
      );
    }

    if (_assignmentError != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: AppColors.primaryRed.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.error, color: AppColors.primaryRed),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _assignmentError!,
                    style: const TextStyle(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _loadAssignments,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_assignments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          color: AppColors.neutral100,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.primaryGreen),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No assignments available',
                    style: TextStyle(
                      color: AppColors.neutral500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Display assignments based on _showAllAssignments flag
    final displayAssignments = _showAllAssignments 
        ? _assignments 
        : _assignments.take(2).toList();

    return Column(
      children: [
        // Assignments list - make it scrollable when showing all
        if (_showAllAssignments)
          Container(
            height: 300, // Fixed height for scrollable area
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 0),
              itemCount: displayAssignments.length,
              itemBuilder: (context, index) {
                final assignment = displayAssignments[index];
                return AssignmentCard(
                  name: assignment.title,
                  status: assignment.status,
                  date: _formatDate(assignment.dueDate),
                  note: assignment.priority.toUpperCase(),
                  description: assignment.description,
                );
              },
            ),
          )
        else
          // Show limited assignments without scroll for preview
          ...displayAssignments.map((assignment) {
            return AssignmentCard(
              name: assignment.title,
              status: assignment.status,
              date: _formatDate(assignment.dueDate),
              note: assignment.priority.toUpperCase(),
              description: assignment.description,
            );
          }).toList(),
        
        // Show more/less button if there are more than 2 assignments
        if (_assignments.length > 2)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextButton(
              onPressed: () {
                setState(() {
                  _showAllAssignments = !_showAllAssignments;
                });
              },
              child: Text(
                _showAllAssignments 
                    ? 'Show Less' 
                    : 'Show All (${_assignments.length} total)',
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAttendanceSection() {
    if (_isLoadingAttendance) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryBlue,
          ),
        ),
      );
    }

    if (_attendanceError != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: AppColors.primaryRed.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.error, color: AppColors.primaryRed),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _attendanceError!,
                    style: const TextStyle(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _loadAttendanceRecords,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Generate chart data from attendance records
    final chartData = _generateAttendanceChartData();
    final stats = _calculateAttendanceStats();

    return Column(
      children: [
        // Attendance chart and stats
        AttendanceCard(
          title: "Attendance Overview",
          chart: AttendanceChart(
            data: chartData,
            labels: ['S', 'S', 'R', 'K', 'J', 'S', 'M'],
            barWidth: 16,
            aspectRatio: 1.9,
          ),
          present: stats['present'] ?? 0,
          absent: stats['absent'] ?? 0,
          lateCount: stats['late'] ?? 0,
          statusBreakdown: stats,
          showStatusBreakdown: true,
          chartHeight: 160,
        ),
        
        // Individual attendance records (if showing all)
        if (_showAllAttendance && _attendanceRecords.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            height: 300, // Increased height for consistency with other sections
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _attendanceRecords.length,
              itemBuilder: (context, index) {
                final record = _attendanceRecords[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getAttendanceStatusColor(record.status),
                      child: Text(
                        record.userName?.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(record.userName ?? 'Unknown User'),
                    subtitle: Text('${record.date} • ${record.status}'),
                    trailing: Text(
                      record.checkInTime ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        
        // Show more/less button for attendance records
        if (_attendanceRecords.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextButton(
              onPressed: () {
                setState(() {
                  _showAllAttendance = !_showAllAttendance;
                });
              },
              child: Text(
                _showAllAttendance 
                    ? 'Show Chart Only' 
                    : 'Show All Records (${_attendanceRecords.length} total)',
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<int> _generateAttendanceChartData() {
    // Generate chart data for the last 7 days
    final now = DateTime.now();
    final chartData = <int>[];
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      final dayRecords = _attendanceRecords.where((record) => record.date == dateStr).length;
      chartData.add(dayRecords);
    }
    
    // Return actual data only, no dummy fallback
    return chartData;
  }

  Map<String, int> _calculateAttendanceStats() {
    final stats = <String, int>{};
    for (final record in _attendanceRecords) {
      // Normalize status names for consistency
      String normalizedStatus = record.status.toLowerCase();
      if (normalizedStatus == 'sick_leave') {
        normalizedStatus = 'sick';
      }
      stats[normalizedStatus] = (stats[normalizedStatus] ?? 0) + 1;
    }
    
    return {
      'present': stats['present'] ?? 0,
      'late': stats['late'] ?? 0,
      'sick': stats['sick'] ?? 0,
      'leave': stats['leave'] ?? 0,
      'absent': stats['absent'] ?? 0,
    };
  }

  Color _getAttendanceStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return AppColors.primaryGreen;
      case 'late':
        return AppColors.primaryRed;
      case 'sick':
      case 'absent':
        return AppColors.primaryYellow;
      default:
        return AppColors.neutral500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,

      body: SafeArea(
        top: true,
        bottom: false, 
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashboardHeader(),
              const SizedBox(height: 20),

              // Menu
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MenuButton(
                      icon: Icons.people,
                      label: "Employee Data",
                      color: AppColors.primaryRed,
                      onTap: () => Navigator.pushNamed(context, '/admin/employees'),
                    ),
                    MenuButton(
                      icon: Icons.book,
                      label: "Report",
                      color: AppColors.primaryGreen,
                      onTap: () => Navigator.pushNamed(context, '/admin/report'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),



              // LETTERS (ringkas)
              SectionTitle(
                title: "Letter${_pendingLetters.isNotEmpty ? ' (${_pendingLetters.length} pending)' : ''}",
                action: _showAllLetters ? "Show Less" : "View All",
                onTap: () {
                  setState(() {
                    _showAllLetters = !_showAllLetters;
                  });
                },
              ),
              _buildLettersSection(),
              const SizedBox(height: 12),

              // ASSIGNMENT (ringkas)
              SectionTitle(
                title: "Assignment",
                action: _showAllAssignments ? "Show Less" : "View All",
                onTap: () {
                  setState(() {
                    _showAllAssignments = !_showAllAssignments;
                  });
                },
              ),
              const SizedBox(height: 8),
              _buildAssignmentsSection(),
              const SizedBox(height: 12),

              // ATTENDANCE (ringkas)
              SectionTitle(
                title: "Attendance",
                action: _showAllAttendance ? "Show Less" : "View All",
                onTap: () {
                  setState(() {
                    _showAllAttendance = !_showAllAttendance;
                  });
                },
              ),
              const SizedBox(height: 8),
              _buildAttendanceSection(),
              const SizedBox(height: 12),



              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const SafeArea(
        top: false,
        child: CustomBottomNavRouter(
          currentIndex: 0,
          items: AdminNavItems.items,
        ),
      ),
    );
  }
}
