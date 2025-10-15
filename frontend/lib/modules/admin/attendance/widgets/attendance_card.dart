// lib/modules/admin/attendance/widgets/attendance_card.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/data/models/user.dart';
import 'attendance_detail_dialog.dart';
import '../pages/attendance_edit_page.dart';

class AttendanceCard extends StatelessWidget {
  final String name;
  final String division;
  final String status;
  final Color statusColor;
  final String clockIn;
  final String clockOut;
  final String date;
  final User? user; // Add User parameter

  // optional override (kalau mau custom perilaku)
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AttendanceCard({
    super.key,
    required this.name,
    required this.division,
    required this.status,
    required this.statusColor,
    required this.clockIn,
    required this.clockOut,
    required this.date,
    this.user, // Add user parameter
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  void _openDetail(BuildContext context) {
    if (user != null) {
      showDialog(
        context: context,
        builder: (context) => AttendanceDetailDialog(
          user: user!,
          clockIn: clockIn,
          clockOut: clockOut,
          status: status,
          date: date,
        ),
      );
    } else {
      // Fallback jika user null, gunakan dummy user
      final dummyUser = User(
        id: 'dummy',
        email: 'dummy@email.com',
        fullName: name,
        employeeId: 'EMP001',
        department: division,
        role: 'employee',
        status: 'active',
        isActive: true,
      );
      showDialog(
        context: context,
        builder: (context) => AttendanceDetailDialog(
          user: dummyUser,
          clockIn: clockIn,
          clockOut: clockOut,
          status: status,
          date: date,
        ),
      );
    }
  }

  void _openEdit(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AttendanceEditPage(
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
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Attendance"),
        content: const Text(
          "Are you sure you want to delete this record?",
        ),
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
                  content: Text("Deleted Successfully"),
                  backgroundColor: AppColors.primaryRed,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: AppColors.pureWhite,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.pureWhite,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap ?? () => _openDetail(context),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final narrow = w < 360;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== Header: avatar + name/division + status chip
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.neutral100,
                        backgroundImage:
                            NetworkImage("https://i.pravatar.cc/150?img=5"),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.neutral800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              division,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.neutral500,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _StatusChip(text: status, color: statusColor),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ===== Clock In / Out (responsif)
                  narrow
                      ? Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _InfoPill(
                              icon: Icons.login_rounded,
                              label: "Clock In",
                              value: clockIn,
                            ),
                            _InfoPill(
                              icon: Icons.logout_rounded,
                              label: "Clock Out",
                              value: clockOut,
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: _InfoPill(
                                icon: Icons.login_rounded,
                                label: "Clock In",
                                value: clockIn,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _InfoPill(
                                icon: Icons.logout_rounded,
                                label: "Clock Out",
                                value: clockOut,
                              ),
                            ),
                          ],
                        ),

                  const SizedBox(height: 8),

                  // ===== Date
                  Row(
                    children: [
                      const Icon(Icons.event, size: 16, color: AppColors.neutral500),
                      const SizedBox(width: 6),
                      Text(
                        date,
                        style: const TextStyle(
                          color: AppColors.neutral800,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ===== Actions (Edit / Delete)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _ActionIcon(
                        icon: Icons.edit,
                        color: AppColors.primaryYellow,
                        onTap: onEdit ?? () => _openEdit(context),
                        tooltip: 'Edit',
                      ),
                      const SizedBox(width: 8),
                      _ActionIcon(
                        icon: Icons.delete,
                        color: AppColors.primaryRed,
                        onTap: onDelete ?? () => _confirmDelete(context),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
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
        border: Border.all(color: color.withOpacity(.35)),
        borderRadius: BorderRadius.circular(20),
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

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoPill({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerGray),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.neutral500),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.neutral500,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.neutral800,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? tooltip;

  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final btn = InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          border: Border.all(color: AppColors.dividerGray),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );

    return tooltip == null
        ? btn
        : Tooltip(message: tooltip!, child: btn);
  }
}
