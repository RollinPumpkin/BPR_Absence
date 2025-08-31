import 'package:flutter/material.dart';
import 'attendance_detail_dialog.dart';

class AttendanceCard extends StatelessWidget {
  final String name;
  final String division;
  final String status;
  final Color statusColor;
  final String clockIn;
  final String clockOut;
  final String date;

  const AttendanceCard({
    super.key,
    required this.name,
    required this.division,
    required this.status,
    required this.statusColor,
    required this.clockIn,
    required this.clockOut,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=5"),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      division,
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                status,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Clock In / Out
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Clock In: $clockIn", style: const TextStyle(fontSize: 13)),
              Text("Clock Out: $clockOut",
                  style: const TextStyle(fontSize: 13, color: Colors.black54)),
            ],
          ),

          const SizedBox(height: 6),

          // Date
          Text(date, style: const TextStyle(color: Colors.black54, fontSize: 12)),

          const SizedBox(height: 12),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  // buka detail attendance
                  showDialog(
                    context: context,
                    builder: (context) => const AttendanceDetailDialog(),
                  );
                },
                icon: const Icon(Icons.edit, color: Colors.orange),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  // konfirmasi hapus
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Delete Attendance"),
                      content: const Text(
                          "Are you sure you want to delete this record?"),
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
                                  content: Text("Deleted Successfully")),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: const Text("Delete"),
                        )
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete, color: Colors.red),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          )
        ],
      ),
    );
  }
}
