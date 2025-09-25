import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class AttendanceEditPage extends StatefulWidget {
  final String employeeName;
  final String position;
  final String attendanceType;
  final String date;
  final String checkIn;
  final String checkOut;
  final String status;
  final String workHours;
  final String location;
  final String detailAddress;
  final String lat;
  final String long;
  final String proofFile;

  const AttendanceEditPage({
    super.key,
    required this.employeeName,
    required this.position,
    required this.attendanceType,
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    required this.workHours,
    required this.location,
    required this.detailAddress,
    required this.lat,
    required this.long,
    required this.proofFile,
  });

  @override
  State<AttendanceEditPage> createState() => _AttendanceEditPageState();
}

class _AttendanceEditPageState extends State<AttendanceEditPage> {
  late TextEditingController _employeeController;
  late TextEditingController _positionController;
  late TextEditingController _dateController;
  late TextEditingController _checkInController;
  late TextEditingController _checkOutController;
  late TextEditingController _statusController;
  late TextEditingController _workHoursController;
  late TextEditingController _detailAddressController;
  late TextEditingController _latController;
  late TextEditingController _longController;
  late TextEditingController _proofFileController;

  String? _attendanceType;
  String? _location;

  @override
  void initState() {
    super.initState();
    _employeeController = TextEditingController(text: widget.employeeName);
    _positionController = TextEditingController(text: widget.position);
    _dateController = TextEditingController(text: widget.date);
    _checkInController = TextEditingController(text: widget.checkIn);
    _checkOutController = TextEditingController(text: widget.checkOut);
    _statusController = TextEditingController(text: widget.status);
    _workHoursController = TextEditingController(text: widget.workHours);
    _detailAddressController = TextEditingController(text: widget.detailAddress);
    _latController = TextEditingController(text: widget.lat);
    _longController = TextEditingController(text: widget.long);
    _proofFileController = TextEditingController(text: widget.proofFile);

    _attendanceType = widget.attendanceType;
    _location = widget.location;
  }

  @override
  void dispose() {
    _employeeController.dispose();
    _positionController.dispose();
    _dateController.dispose();
    _checkInController.dispose();
    _checkOutController.dispose();
    _statusController.dispose();
    _workHoursController.dispose();
    _detailAddressController.dispose();
    _latController.dispose();
    _longController.dispose();
    _proofFileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Attendance"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _employeeController,
              decoration: const InputDecoration(
                labelText: "Employee Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _positionController,
              decoration: const InputDecoration(
                labelText: "Position",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _attendanceType,
              items: ["Check In", "Check Out", "Absent", "Annual Leave", "Sick Leave"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => _attendanceType = val),
              decoration: const InputDecoration(
                labelText: "Attendance Type",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: "Date",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _checkInController,
                    decoration: const InputDecoration(
                      labelText: "Check In",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _checkOutController,
                    decoration: const InputDecoration(
                      labelText: "Check Out",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _statusController,
              decoration: const InputDecoration(
                labelText: "Status",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _workHoursController,
              decoration: const InputDecoration(
                labelText: "Work Hours",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _location,
              items: ["Office", "Home", "Other"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => _location = val),
              decoration: const InputDecoration(
                labelText: "Location",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _detailAddressController,
              decoration: const InputDecoration(
                labelText: "Detail Address",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latController,
                    decoration: const InputDecoration(
                      labelText: "Latitude",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _longController,
                    decoration: const InputDecoration(
                      labelText: "Longitude",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _proofFileController,
              decoration: const InputDecoration(
                labelText: "Proof File",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Save logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Attendance Updated Successfully")),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                  ),
                  child: const Text("Save", style: TextStyle(color: AppColors.pureWhite)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
