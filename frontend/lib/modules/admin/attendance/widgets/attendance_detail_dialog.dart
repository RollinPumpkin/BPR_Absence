import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/data/models/user.dart';
import '../pages/attendance_edit_page.dart';

class AttendanceDetailDialog extends StatelessWidget {
  final User user;
  final String? clockIn;
  final String? clockOut;
  final String? status;
  final String? date;

  const AttendanceDetailDialog({
    super.key,
    required this.user,
    this.clockIn,
    this.clockOut,
    this.status,
    this.date,
  });  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Attendance Details',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.neutral800,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.neutral800),
                      onPressed: () => Navigator.pop(context),
                      splashRadius: 20,
                      tooltip: 'Close',
                    ),
                  ],
                ),
                const Divider(color: AppColors.dividerGray, height: 20),

                // Employee Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.dividerGray),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadowColor,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.neutral100,
                        child: Icon(Icons.person, color: AppColors.neutral500),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _EmpNamePosition(
                          name: user.fullName.isEmpty ? 'Unknown Employee' : user.fullName,
                          position: user.position?.isEmpty == false ? user.position! : 
                                   (user.department?.isEmpty == false ? user.department! : 'Unknown Position'),
                        ),
                      ),
                      const _StatusChip(text: 'Check In', color: AppColors.primaryGreen),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Attendance Information
                _SectionBox(
                  title: 'Attendance Information',
                  child: Column(
                    children: [
                      _TwoColRow(
                        leftLabel: 'Date',
                        leftValue: _formatCurrentDate(),
                        rightLabel: 'Check In',
                        rightValue: _getCheckInTime(),
                      ),
                      const SizedBox(height: 8),
                      _TwoColRow(
                        leftLabel: 'Status',
                        leftValue: _getAttendanceStatus(),
                        rightLabel: 'Check Out',
                        rightValue: _getCheckOutTime(),
                      ),
                      const SizedBox(height: 8),
                      _TwoColRow(
                        leftLabel: 'Work Hours',
                        leftValue: _getWorkHours(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Location Information
                _SectionBox(
                  title: 'Location Information',
                  child: Column(
                    children: const [
                      _TwoColRow(
                        leftLabel: 'Location',
                        leftValue: 'Office',
                        rightLabel: 'Detail Address',
                        rightValue:
                            'Jl. Soekarno Hatta No. 8, Jatimulyo, Lowokwaru, Kota Malang',
                      ),
                      SizedBox(height: 8),
                      _TwoColRow(
                        leftLabel: 'Lat',
                        leftValue: '-2241720016',
                        rightLabel: 'Long',
                        rightValue: '2241720119',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Proof of Attendance
                _SectionBox(
                  title: 'Proof of Attendance',
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.dividerGray),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Wa003198373738.jpg',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.neutral800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: 'Download',
                          child: IconButton(
                            icon: const Icon(Icons.file_download_outlined,
                                size: 20, color: AppColors.primaryBlue),
                            splashRadius: 18,
                            onPressed: () {
                              // TODO: implement download
                            },
                          ),
                        ),
                        Tooltip(
                          message: 'Preview',
                          child: IconButton(
                            icon: const Icon(Icons.visibility_outlined,
                                size: 20, color: AppColors.neutral800),
                            splashRadius: 18,
                            onPressed: () {
                              // TODO: implement preview
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _CircleAction(
                      color: AppColors.primaryYellow,
                      icon: Icons.edit,
                      tooltip: 'Edit',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AttendanceEditPage(
                              employeeName: "Septa Puma Surya",
                              position: "Jabatan",
                              attendanceType: "Check In",
                              date: "1 March 2025",
                              checkIn: "09:00",
                              checkOut: "-",
                              status: "Present",
                              workHours: "8 Hours",
                              location: "Office",
                              detailAddress:
                                  "Jl. Soekarno Hatta No. 8, Jatimulyo, Lowokwaru, Kota Malang",
                              lat: "-2241720016",
                              long: "2241720119",
                              proofFile: "Wa003198373738.jpg",
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _CircleAction(
                      color: AppColors.primaryRed,
                      icon: Icons.delete,
                      tooltip: 'Delete',
                      onTap: () => _confirmDelete(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatCurrentDate() {
    if (date != null) return date!;
    
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  String _getCheckInTime() {
    return clockIn ?? '-';
  }

  String _getCheckOutTime() {
    return clockOut ?? '-';
  }

  String _getAttendanceStatus() {
    return status ?? 'Present';
  }

  String _getWorkHours() {
    final checkOut = _getCheckOutTime();
    final checkIn = _getCheckInTime();
    
    if (checkOut == '-' || checkIn == '-') return '-';
    
    try {
      final checkInTime = TimeOfDay(
        hour: int.parse(checkIn.split(':')[0]),
        minute: int.parse(checkIn.split(':')[1]),
      );
      final checkOutTime = TimeOfDay(
        hour: int.parse(checkOut.split(':')[0]),
        minute: int.parse(checkOut.split(':')[1]),
      );
      
      final checkInMinutes = checkInTime.hour * 60 + checkInTime.minute;
      final checkOutMinutes = checkOutTime.hour * 60 + checkOutTime.minute;
      final workMinutes = checkOutMinutes - checkInMinutes;
      final hours = (workMinutes / 60).floor();
      
      return '$hours Hours';
    } catch (e) {
      return '-';
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Attendance'),
            content: const Text(
              'Are you sure you want to delete this record? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: AppColors.pureWhite,
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (ok) {
      Navigator.of(context).pop(); // close detail dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deleted Successfully'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }
}

/// ====== Small, focused widgets ======

class _EmpNamePosition extends StatelessWidget {
  final String name;
  final String position;
  const _EmpNamePosition({required this.name, required this.position});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: AppColors.neutral800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          position,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.neutral500,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;
  const _StatusChip({required this.text, required this.color});

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

class _SectionBox extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionBox({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerGray),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: AppColors.neutral800,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.dividerGray, height: 1),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _TwoColRow extends StatelessWidget {
  final String leftLabel;
  final String leftValue;
  final String? rightLabel;
  final String? rightValue;

  const _TwoColRow({
    required this.leftLabel,
    required this.leftValue,
    this.rightLabel,
    this.rightValue,
  });

  @override
  Widget build(BuildContext context) {
    final showRight =
        (rightLabel?.trim().isNotEmpty ?? false) || (rightValue?.trim().isNotEmpty ?? false);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _KV(leftLabel, leftValue)),
        if (showRight) const SizedBox(width: 12),
        if (showRight) Expanded(child: _KV(rightLabel ?? '', rightValue ?? '')),
      ],
    );
  }
}

class _KV extends StatelessWidget {
  final String label;
  final String value;
  const _KV(this.label, this.value);

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13.5,
            color: AppColors.neutral800,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _CircleAction extends StatelessWidget {
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  const _CircleAction({
    required this.color,
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final btn = Material(
      color: color,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: AppColors.pureWhite),
        ),
      ),
    );

    return tooltip == null ? btn : Tooltip(message: tooltip!, child: btn);
  }
}
