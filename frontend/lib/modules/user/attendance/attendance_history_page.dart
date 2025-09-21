import 'package:flutter/material.dart';
import 'widgets/attendance_detail_dialog.dart';

class AttendanceHistoryPage extends StatefulWidget {
  const AttendanceHistoryPage({super.key});

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Attendance History'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterChip('Filter', Icons.filter_list, isFilter: true),
                const SizedBox(width: 12),
                _buildFilterChip('All', null, isSelected: selectedFilter == 'All'),
                const SizedBox(width: 12),
                _buildFilterChip('Late', null, isSelected: selectedFilter == 'Late'),
                const SizedBox(width: 12),
                _buildFilterChip('Leave', null, isSelected: selectedFilter == 'Leave'),
              ],
            ),
          ),
          
          // Attendance List
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: _buildAttendanceList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAttendanceList() {
    List<Widget> items = [];
    
    // All attendance data
    final allItems = [
      {'status': 'On Time', 'date': '27 Aug', 'time': '07:45:32 - 16:06:44', 'duration': '10 hr 15 mins', 'color': Colors.green, 'category': 'on_time'},
      {'status': 'Late', 'date': '26 Aug', 'time': '08:45:32 - 16:06:44', 'duration': '08 hr 15 mins', 'color': Colors.red, 'category': 'late'},
      {'status': 'Annual Leave', 'date': '25 Aug', 'time': 'Weekend Annual', 'duration': 'Thu weekend', 'color': Colors.grey, 'category': 'leave'},
      {'status': 'Sick', 'date': '24 Aug', 'time': '07:45:32', 'duration': '', 'color': Colors.orange, 'category': 'leave'},
      {'status': 'Late', 'date': '23 Aug', 'time': '08:45:32 - 16:06:44', 'duration': '08 hr 15 mins', 'color': Colors.red, 'category': 'late'},
      {'status': 'On Time', 'date': '22 Aug', 'time': '07:45:32 - 16:06:44', 'duration': '10 hr 15 mins', 'color': Colors.green, 'category': 'on_time'},
      {'status': 'On Time', 'date': '21 Aug', 'time': '07:45:32 - 16:06:44', 'duration': '10 hr 15 mins', 'color': Colors.green, 'category': 'on_time'},
    ];

    for (int i = 0; i < allItems.length; i++) {
      final item = allItems[i];
      bool shouldShow = false;
      
      if (selectedFilter == 'All') {
        shouldShow = true;
      } else if (selectedFilter == 'Late' && item['category'] == 'late') {
        shouldShow = true;
      } else if (selectedFilter == 'Leave' && item['category'] == 'leave') {
        shouldShow = true;
      }
      
      if (shouldShow) {
        items.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildAttendanceItem(
              item['status'] as String,
              item['date'] as String,
              item['time'] as String,
              item['duration'] as String,
              item['color'] as Color,
            ),
          ),
        );
      }
    }
    
    return items;
  }

  Widget _buildFilterChip(String label, IconData? icon, {bool isFilter = false, bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        if (!isFilter) {
          setState(() {
            selectedFilter = label;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.blue : Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.blue : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceItem(String status, String date, String time, String duration, Color statusColor) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AttendanceDetailDialog(
            status: status,
            date: date,
            checkIn: time.contains('-') ? time.split(' - ')[0] : time,
            checkOut: time.contains('-') ? time.split(' - ')[1] : '16:00',
            workHours: duration.isNotEmpty ? duration : '8 Hours',
            location: 'Office',
            address: 'Jln. Soekarno Hatta No. 8, Jatimulyo, Lowokwaru, Kota Malang',
            lat: '-7.9417200116',
            long: '112.6119',
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  if (duration.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      duration,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              date,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}