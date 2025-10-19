// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/data/services/letter_service.dart';
import 'package:frontend/data/models/letter.dart';

class LetterAcceptancePage extends StatefulWidget {
  const LetterAcceptancePage({super.key});

  @override
  State<LetterAcceptancePage> createState() => _LetterAcceptancePageState();
}

class _LetterAcceptancePageState extends State<LetterAcceptancePage> {
  final List<String> _monthsId = const [
    'Januari','Februari','Maret','April','Mei','Juni',
    'Juli','Agustus','September','Oktober','November','Desember'
  ];
  int _monthIndex = DateTime.now().month - 1; // Current month (0-based)
  int _year = DateTime.now().year;

  final LetterService _letterService = LetterService();
  List<Letter> _pendingLetters = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPendingLetters();
  }

  Future<void> _loadPendingLetters() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _letterService.getPendingLetters();
      
      if (response.success && response.data != null) {
        setState(() {
          _pendingLetters = response.data!.items;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Failed to load pending letters';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading pending letters: $e';
        _isLoading = false;
      });
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

  void _showRejectDialog(Letter letter) {
    final TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Letter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to reject "${letter.subject}"?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for rejection (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _rejectLetter(letter, reasonController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _prevMonth() {
    setState(() {
      if (_monthIndex == 0) {
        _monthIndex = 11;
        _year -= 1;
      } else {
        _monthIndex -= 1;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_monthIndex == 11) {
        _monthIndex = 0;
        _year += 1;
      } else {
        _monthIndex += 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header dalam card (sesuai mockup)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.neutral800),
                        onPressed: () => Navigator.pop(context),
                        splashRadius: 22,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Letter Acceptance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.neutral800,
                        ),
                      ),
                    ],
                  ),
                ),

                // Row bulan - tahun dengan panah & chip
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ArrowChip(onTap: _prevMonth, isLeft: true),
                      const SizedBox(width: 8),
                      _Pill(
                        text: _monthsId[_monthIndex],
                        bg: AppColors.primaryGreen.withOpacity(.18),
                        fg: AppColors.neutral800,
                      ),
                      const SizedBox(width: 8),
                      const Text('-', style: TextStyle(color: AppColors.neutral500)),
                      const SizedBox(width: 8),
                      _Pill(
                        text: '$_year',
                        bg: AppColors.accentBlue.withOpacity(.18),
                        fg: AppColors.neutral800,
                      ),
                      const SizedBox(width: 8),
                      _ArrowChip(onTap: _nextMonth, isLeft: false),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // List + timeline merah di kiri
                Expanded(
                  child: Stack(
                    children: [
                      // garis timeline full (di kiri dalam card)
                      Positioned.fill(
                        left: 24,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            margin: const EdgeInsets.only(top: 12),
                            width: 4,
                            height: double.infinity,
                            color: AppColors.primaryRed,
                          ),
                        ),
                      ),

                      // daftar item
                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_errorMessage != null)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: AppColors.primaryRed),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadPendingLetters,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (_pendingLetters.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'No pending letters found',
                              style: TextStyle(color: AppColors.neutral800),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                          itemCount: _pendingLetters.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final letter = _pendingLetters[i];
                            final isFirst = i == 0;
                            final isLast = i == _pendingLetters.length - 1;
                            return _TimelineRow(
                              isFirst: isFirst,
                              isLast: isLast,
                              child: _LetterCard(
                                date: letter.letterDate?.toString().split(' ')[0] ?? letter.createdAt?.toString().split(' ')[0] ?? 'Unknown date',
                                title: letter.subject,
                                category: letter.letterType,
                                description: letter.content,
                                status: _mapStatusToDisplay(letter.status),
                                fileName: letter.attachments.isNotEmpty ? letter.attachments.first.filename : 'No attachment',
                                requesterName: letter.senderName ?? 'Unknown requester',
                                requesterEmployee: letter.recipientEmployeeId ?? '',
                                onApprove: () => _approveLetter(letter),
                                onReject: () => _showRejectDialog(letter),
                                onDownload: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Downloading proof...')),
                                  );
                                },
                                onPreview: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Preview proof...')),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _mapStatusToDisplay(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Waiting Approval';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }
}

/// ===== UI helpers =====

class _ArrowChip extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLeft;
  const _ArrowChip({required this.onTap, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.pureWhite,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            isLeft ? Icons.chevron_left : Icons.chevron_right,
            color: AppColors.neutral800,
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  const _Pill({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    }
}

/// Row dengan titik timeline (lingkaran) + kartu
class _TimelineRow extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final Widget child;
  const _TimelineRow({
    required this.isFirst,
    required this.isLast,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // titik di kiri (di atas garis yang sudah di Stack)
        SizedBox(
          width: 28,
          child: Column(
            children: [
              // ruang kecil agar posisi dot turun sedikit (mirip mockup)
              const SizedBox(height: 10),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryRed, width: 3),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: child),
      ],
    );
  }
}

class _LetterCard extends StatelessWidget {
  final String date;
  final String title;
  final String category;
  final String description;
  final String status;
  final String fileName;
  final String? requesterName;
  final String? requesterEmployee;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onDownload;
  final VoidCallback onPreview;

  const _LetterCard({
    required this.date,
    required this.title,
    required this.category,
    required this.description,
    required this.status,
    required this.fileName,
    this.requesterName,
    this.requesterEmployee,
    required this.onApprove,
    required this.onReject,
    required this.onDownload,
    required this.onPreview,
  });

  Color get _statusColor {
    switch (status.toLowerCase()) {
      case 'rejected':
        return AppColors.primaryRed;
      case 'approved':
        return AppColors.primaryGreen;
      default:
        return AppColors.primaryYellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dividerGray),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date + Status
          Row(
            children: [
              Expanded(
                child: Text(
                  date,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.neutral800,
                  ),
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: AppColors.neutral800,
            ),
          ),
          const SizedBox(height: 4),

          // Category
          Text(
            category,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.neutral800,
            ),
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            description,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.neutral800,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),

          // Attachment chip + actions
          Row(
            children: [
              // file chip (dengan shadow kecil)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.dividerGray),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fileName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.neutral800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: onPreview,
                      child: const Icon(Icons.visibility_outlined,
                          size: 18, color: AppColors.neutral800),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: onDownload,
                      child: const Icon(Icons.file_download_outlined,
                          size: 18, color: AppColors.neutral800),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // approve / reject
              _SquareAction(
                color: AppColors.primaryGreen,
                icon: Icons.check,
                onTap: onApprove,
              ),
              const SizedBox(width: 8),
              _SquareAction(
                color: AppColors.primaryRed,
                icon: Icons.close,
                onTap: onReject,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SquareAction extends StatelessWidget {
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  const _SquareAction({
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(Icons.check, color: AppColors.pureWhite, size: 20),
        ),
      ),
    );
  }
}
