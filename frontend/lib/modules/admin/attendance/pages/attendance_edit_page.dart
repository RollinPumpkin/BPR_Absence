import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/utils/image_compress_helper.dart';
import 'dart:io';

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
  final _formKey = GlobalKey<FormState>();

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

  // ===== Image state (bytes-only → aman untuk web & mobile) =====
  final ImagePicker _picker = ImagePicker();
  Uint8List? _proofImageBytes;
  String? _proofImageName;

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

  // ===== Helpers UI =====
  static const _gap12 = SizedBox(height: 12);
  static const _gap16 = SizedBox(height: 16);
  static const _gap10w = SizedBox(width: 10);

  InputDecoration _dec(String label, {Widget? suffixIcon, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(
        color: AppColors.neutral500,
        fontWeight: FontWeight.w700,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.dividerGray),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.dividerGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accentBlue, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      suffixIcon: suffixIcon,
    );
  }

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: const Border.fromBorderSide(BorderSide(color: AppColors.dividerGray)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.neutral800,
              fontWeight: FontWeight.w800,
              fontSize: 14.5,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.dividerGray, height: 1),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final parts = _dateController.text.split('/');
    DateTime? initialDate;
    if (parts.length == 3) {
      final d = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final y = int.tryParse(parts[2]);
      if (d != null && m != null && y != null) initialDate = DateTime(y, m, d);
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select Date',
    );
    if (picked != null) {
      _dateController.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      setState(() {});
    }
  }

  Future<void> _pickTime(TextEditingController ctrl) async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: now,
      helpText: 'Select Time',
    );
    if (picked != null) {
      ctrl.text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {});
    }
  }

  // ===== Pick image cross-platform (web/mobile) =====
  Future<void> _pickImageFromGallery() async {
    try {
      if (kIsWeb) {
        // WEB → pakai file_picker
        final res = await FilePicker.platform.pickFiles(
          type: FileType.image,
          withData: true,
        );
        if (res != null && res.files.isNotEmpty) {
          final f = res.files.single;
          setState(() {
            _proofImageBytes = f.bytes!;
            _proofImageName = f.name;
            _proofFileController.text = f.name;
          });
        }
      } else {
        // ANDROID/iOS → pakai image_picker
        final XFile? x = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );
        if (x != null) {
          // Auto-compress if needed
          final compressedPath = await ImageCompressHelper.compressImageIfNeeded(x.path);
          final bytes = await File(compressedPath).readAsBytes();
          setState(() {
            _proofImageBytes = bytes;
            _proofImageName = x.name;
            _proofFileController.text = x.name;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }

  void _clearPickedImage() {
    setState(() {
      _proofImageBytes = null;
      _proofImageName = null;
      _proofFileController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        foregroundColor: AppColors.neutral800,
        title: const Text(
          'Edit Attendance',
          style: TextStyle(
            color: AppColors.neutral800,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            children: [
              // ===== Section: Employee =====
              _sectionCard(
                title: 'Employee',
                children: [
                  TextFormField(
                    controller: _employeeController,
                    decoration: _dec('Employee Name'),
                  ),
                  _gap12,
                  TextFormField(
                    controller: _positionController,
                    decoration: _dec('Position'),
                  ),
                  _gap12,
                  DropdownButtonFormField<String>(
                    initialValue: _attendanceType,
                    items: const [
                      'Check In',
                      'Check Out',
                      'Absent',
                      'Annual Leave',
                      'Sick Leave'
                    ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setState(() => _attendanceType = val),
                    decoration: _dec('Attendance Type'),
                  ),
                ],
              ),

              _gap16,

              // ===== Section: Schedule =====
              _sectionCard(
                title: 'Schedule',
                children: [
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: _dec(
                      'Date',
                      suffixIcon: IconButton(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.date_range, color: AppColors.neutral500),
                      ),
                    ),
                    onTap: _pickDate,
                  ),
                  _gap12,
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _checkInController,
                          readOnly: true,
                          decoration: _dec(
                            'Check In',
                            suffixIcon: IconButton(
                              onPressed: () => _pickTime(_checkInController),
                              icon: const Icon(Icons.access_time, color: AppColors.neutral500),
                            ),
                          ),
                          onTap: () => _pickTime(_checkInController),
                        ),
                      ),
                      _gap10w,
                      Expanded(
                        child: TextFormField(
                          controller: _checkOutController,
                          readOnly: true,
                          decoration: _dec(
                            'Check Out',
                            suffixIcon: IconButton(
                              onPressed: () => _pickTime(_checkOutController),
                              icon: const Icon(Icons.access_time, color: AppColors.neutral500),
                            ),
                          ),
                          onTap: () => _pickTime(_checkOutController),
                        ),
                      ),
                    ],
                  ),
                  _gap12,
                  TextFormField(
                    controller: _statusController,
                    decoration: _dec('Status', hint: 'Present / Sick / Late / Leave'),
                  ),
                  _gap12,
                  TextFormField(
                    controller: _workHoursController,
                    decoration: _dec('Work Hours', hint: 'e.g. 8 Hours'),
                  ),
                ],
              ),

              _gap16,

              // ===== Section: Location =====
              _sectionCard(
                title: 'Location',
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _location,
                    items: const ['Office', 'Home', 'Other']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => _location = val),
                    decoration: _dec('Location'),
                  ),
                  _gap12,
                  TextFormField(
                    controller: _detailAddressController,
                    decoration: _dec('Detail Address'),
                  ),
                  _gap12,
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latController,
                          decoration: _dec('Latitude'),
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true, signed: true),
                        ),
                      ),
                      _gap10w,
                      Expanded(
                        child: TextFormField(
                          controller: _longController,
                          decoration: _dec('Longitude'),
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true, signed: true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              _gap16,

              // ===== Section: Proof =====
              _sectionCard(
                title: 'Proof',
                children: [
                  TextFormField(
                    controller: _proofFileController,
                    readOnly: true,
                    decoration: _dec(
                      'Proof Image',
                      hint: 'Select image from gallery',
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_proofImageBytes != null)
                            IconButton(
                              tooltip: 'Clear',
                              onPressed: _clearPickedImage,
                              icon: const Icon(Icons.clear, color: AppColors.neutral500),
                            ),
                          IconButton(
                            tooltip: 'Pick from gallery',
                            onPressed: _pickImageFromGallery,
                            icon: const Icon(Icons.attach_file, color: AppColors.neutral500),
                          ),
                        ],
                      ),
                    ),
                    onTap: _pickImageFromGallery,
                  ),
                  if (_proofImageBytes != null) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        _proofImageBytes!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.neutral800,
                      side: const BorderSide(color: AppColors.dividerGray),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Save logic — kirim _proofImageBytes & _proofImageName kalau perlu
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Attendance Updated Successfully'),
                          backgroundColor: AppColors.primaryGreen,
                        ),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.pureWhite,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
