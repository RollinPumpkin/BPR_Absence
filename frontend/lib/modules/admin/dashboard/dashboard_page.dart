import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/widgets/custom_bottom_nav_router.dart';
import 'package:frontend/modules/admin/shared/admin_nav_items.dart';
import 'package:frontend/data/services/letter_service.dart';
import 'package:frontend/data/models/letter.dart';
import 'package:frontend/modules/admin/letter/pages/letter_acceptance_page.dart';

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
  List<Letter> _pendingLetters = [];
  bool _isLoadingLetters = true;
  String? _letterError;

  @override
  void initState() {
    super.initState();
    _loadPendingLetters();
  }

  Future<void> _loadPendingLetters() async {
    print('🔄 Dashboard: Starting to load pending letters...');
    setState(() {
      _isLoadingLetters = true;
      _letterError = null;
    });

    try {
      // Try to get pending letters first
      print('📬 Dashboard: Attempting getPendingLetters()...');
      var response = await _letterService.getPendingLetters();
      
      if (response.success && response.data != null && response.data!.isNotEmpty) {
        print('✅ Dashboard: getPendingLetters() success - ${response.data!.length} letters');
        setState(() {
          _pendingLetters = response.data!;
          _isLoadingLetters = false;
        });
        return;
      }
      
      // Fallback 1: Try getReceivedLetters and filter for pending
      print('📬 Dashboard: Trying getReceivedLetters() as fallback...');
      final receivedResponse = await _letterService.getReceivedLetters();
      
      if (receivedResponse.success && receivedResponse.data != null) {
        final allLetters = receivedResponse.data!.items;
        final pendingLetters = allLetters.where((letter) => 
          letter.status == 'waiting_approval' || letter.status == 'pending'
        ).toList();
        
        print('✅ Dashboard: getReceivedLetters() success - ${allLetters.length} total, ${pendingLetters.length} pending');
        
        if (pendingLetters.isNotEmpty) {
          setState(() {
            _pendingLetters = pendingLetters;
            _isLoadingLetters = false;
          });
          return;
        }
      }
      
      // Fallback 2: Create dummy pending letters
      print('🔄 Dashboard: Creating dummy pending letters...');
      _pendingLetters = _createDummyPendingLetters();
      setState(() {
        _isLoadingLetters = false;
      });
      
    } catch (e) {
      print('❌ Dashboard: Error loading letters: $e');
      // Fallback: Create dummy data
      _pendingLetters = _createDummyPendingLetters();
      setState(() {
        _letterError = 'Using dummy data due to: $e';
        _isLoadingLetters = false;
      });
    }
  }

  List<Letter> _createDummyPendingLetters() {
    final now = DateTime.now();
    return [
      Letter(
        id: 'pending1',
        subject: 'Emergency Leave Request - Sari Indah',
        content: 'I need emergency leave due to family emergency.',
        letterType: 'emergency_leave',
        letterNumber: 'EL/2025/001',
        letterDate: now.subtract(Duration(hours: 2)),
        priority: 'high',
        status: 'waiting_approval',
        senderId: 'emp006',
        senderName: 'Sari Indah',
        senderPosition: 'Marketing Staff',
        recipientId: 'admin',
        createdAt: now.subtract(Duration(hours: 2)),
        updatedAt: now.subtract(Duration(hours: 2)),
        requiresResponse: true,
        responseDeadline: now.add(Duration(hours: 22)),
        responseReceived: false,
        attachments: [],
        ccRecipients: [],
      ),
      Letter(
        id: 'pending2',
        subject: 'Sick Leave - Budi Rahmat',
        content: 'Medical certificate attached for sick leave request.',
        letterType: 'sick_leave',
        letterNumber: 'SL/2025/002',
        letterDate: now.subtract(Duration(hours: 4)),
        priority: 'medium',
        status: 'waiting_approval',
        senderId: 'emp007',
        senderName: 'Budi Rahmat',
        senderPosition: 'IT Support',
        recipientId: 'admin',
        createdAt: now.subtract(Duration(hours: 4)),
        updatedAt: now.subtract(Duration(hours: 4)),
        requiresResponse: true,
        responseDeadline: now.add(Duration(days: 1)),
        responseReceived: false,
        attachments: [],
        ccRecipients: [],
      ),
    ];
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

    // Display up to 2 pending letters in dashboard overview
    final displayLetters = _pendingLetters.take(2).toList();

    return Column(
      children: displayLetters.map((letter) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,

      body: SafeArea(
        top: true,
        bottom: false, 
        child: SingleChildScrollView(
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
                action: "View",
                onTap: _navigateToLetterAcceptance,
              ),
              _buildLettersSection(),
              const SizedBox(height: 12),

              // ASSIGNMENT (ringkas)
              SectionTitle(
                title: "Assignment",
                action: "View",
                onTap: () => showSectionListModal(
                  context,
                  title: "All Assignments",
                  children: const [
                    AssignmentCard(
                      name: "Client Presentation Preparation",
                      status: "pending",
                      date: "15 Oktober 2025",
                      note: "HIGH",
                      description:
                          "Prepare slides and demo for tomorrow's client presentation on Q4 features",
                    ),
                    AssignmentCard(
                      name: "Client Portfolio Review",
                      status: "completed",
                      date: "15 Oktober 2025",
                      note: "MEDIUM",
                      description:
                          "Review portfolio klien untuk kuartal Q4 2025",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const AssignmentCard(
                name: "Client Presentation Preparation",
                status: "pending",
                date: "15 Oktober 2025",
                note: "HIGH",
                description:
                    "Prepare slides and demo for tomorrow's client presentation on Q4 features",
              ),
              const AssignmentCard(
                name: "Employee Performance Evaluation",
                status: "in_progress",
                date: "15 Oktober 2025",
                note: "MEDIUM",
                description:
                    "Melakukan evaluasi performa karyawan untuk periode semester 2",
              ),
              const SizedBox(height: 12),

              // ATTENDANCE (ringkas)
              SectionTitle(
                title: "Attendance",
                action: "View",
                onTap: () => showSectionListModal(
                  context,
                  title: "Attendance",
                  children: [
                    AttendanceCard(
                      title: "Attendance (Weekly)",
                      chart: AttendanceChart(
                        data: [9, 11, 5, 10, 8, 6, 3],
                        labels: ['S', 'S', 'R', 'K', 'J', 'S', 'M'],
                        barWidth: 16,
                        aspectRatio: 1.9,
                      ),
                      present: 132,
                      absent: 14,
                      lateCount: 9,
                    ),
                  ],
                ),
              ),
              AttendanceCard(
                title: "Attendance",
                chart: AttendanceChart(
                  data: [9, 11, 5, 10, 8, 6, 3],
                  labels: ['S', 'S', 'R', 'K', 'J', 'S', 'M'],
                  barWidth: 16,
                  aspectRatio: 1.9,
                ),
                present: 132,
                absent: 14,
                lateCount: 9,
              ),
              const SizedBox(height: 12),
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
