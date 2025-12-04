import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:frontend/core/constants/colors.dart';

class AddLetterPage extends StatefulWidget {
  const AddLetterPage({super.key});

  @override
  State<AddLetterPage> createState() => _AddLetterPageState();
}

class _AddLetterPageState extends State<AddLetterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? _employeeId;
  String? _letterType;
  String? _selectedStatus; // Changed from TextEditingController to String dropdown
  List<PlatformFile> _files = [];
  String? _filesError; // error untuk upload box

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  InputDecoration _inputDec(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.pureWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
          borderSide: const BorderSide(color: AppColors.accentBlue, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 1.2),
        ),
        errorStyle: const TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.w600),
      );

  TextStyle get _labelStyle => const TextStyle(
        fontWeight: FontWeight.w800,
        color: AppColors.neutral800,
      );

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true, // agar dapat bytes untuk preview
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (!mounted) return;
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _files = result.files;
        _filesError = null; // clear error saat user memilih
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (picked != null) {
      _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      setState(() {}); // trigger re-draw untuk validator tampil normal
    }
  }

  void _onSave() {
    final validForm = _formKey.currentState?.validate() ?? false;
    final hasFiles = _files.isNotEmpty;

    setState(() {
      _filesError = hasFiles ? null : 'Please upload at least one file';
    });

    if (validForm && hasFiles) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Letter Saved!')),
      );
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Row(
                  children: [
                    _BackButtonRounded(),
                    SizedBox(width: 8),
                    Text(
                      'Add Letter',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.neutral800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Employee
                Text('Employee', style: _labelStyle),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _employeeId,
                  decoration: _inputDec('-Choose Employee'),
                  items: const [
                    DropdownMenuItem(value: '1', child: Text('Septa Puma')),
                    DropdownMenuItem(value: '2', child: Text('Nurhaliza')),
                  ],
                  onChanged: (val) => setState(() => _employeeId = val),
                  validator: (val) => (val == null || val.isEmpty) ? 'This field is required' : null,
                ),
                const SizedBox(height: 16),

                // Letter Type
                Text('Letter Type', style: _labelStyle),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _letterType,
                  decoration: _inputDec('-Choose Letter Type'),
                  items: const [
                    DropdownMenuItem(value: 'doctor', child: Text("Doctor's Note")),
                    DropdownMenuItem(value: 'permit', child: Text('Permit Letter')),
                  ],
                  onChanged: (val) => setState(() => _letterType = val),
                  validator: (val) => (val == null || val.isEmpty) ? 'This field is required' : null,
                ),
                const SizedBox(height: 16),

                // Letter Name
                Text('Letter Name', style: _labelStyle),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDec('Enter Letter Name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'This field is required' : null,
                ),
                const SizedBox(height: 16),

                // Letter Description (Optional)
                Text('Letter Description', style: _labelStyle),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: _inputDec('Enter Letter Description (Optional)'),
                ),
                const SizedBox(height: 16),

                // Letter Status
                Text('Letter Status', style: _labelStyle),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration: _inputDec('Select Status'),
                  items: const [
                    DropdownMenuItem(
                      value: 'active',
                      child: Text('Active'),
                    ),
                    DropdownMenuItem(
                      value: 'inactive',
                      child: Text('Inactive'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                  validator: (v) => v == null ? 'Please select a status' : null,
                ),
                const SizedBox(height: 16),

                // Valid Until
                Text('Valid Until', style: _labelStyle),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: _inputDec('dd/mm/yyyy').copyWith(
                    prefixIcon: const Icon(Icons.calendar_today, color: AppColors.primaryBlue),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'This field is required' : null,
                ),
                const SizedBox(height: 16),

                // Upload Supporting Evidence
                Text('Upload Supporting Evidence', style: _labelStyle),
                const SizedBox(height: 6),
                UploadEvidenceBox(
                  files: _files,
                  onPick: _pickFiles,
                ),
                if (_filesError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _filesError!,
                    style: const TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.w700),
                  ),
                ],

                const SizedBox(height: 32),

                // Save
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.pureWhite,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Back icon dengan style bulat
class _BackButtonRounded extends StatelessWidget {
  const _BackButtonRounded();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.pureWhite,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => Navigator.pop(context),
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.arrow_back, color: AppColors.neutral800),
        ),
      ),
    );
  }
}

/// Upload box terkontrol (klik untuk browse, preview, hapus)
class UploadEvidenceBox extends StatelessWidget {
  final List<PlatformFile> files;
  final VoidCallback onPick;

  const UploadEvidenceBox({
    super.key,
    required this.files,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final hasFiles = files.isNotEmpty;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onPick,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.dividerGray),
          boxShadow: const [
            BoxShadow(color: AppColors.shadowColor, blurRadius: 10, offset: Offset(0, 3)),
          ],
        ),
        child: hasFiles ? _SelectedList(files: files, onPick: onPick) : _DropHint(),
      ),
    );
  }
}

class _DropHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.image_outlined, size: 40, color: AppColors.neutral500),
        SizedBox(height: 8),
        Text('Drag and Drop Here', style: TextStyle(color: AppColors.neutral500)),
        SizedBox(height: 4),
        Text('Or', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.neutral800)),
        SizedBox(height: 4),
        Text(
          'Browse',
          style: TextStyle(
            color: AppColors.primaryBlue,
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'JPG • PNG • JPEG',
          style: TextStyle(color: AppColors.neutral400, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _SelectedList extends StatefulWidget {
  final List<PlatformFile> files;
  final VoidCallback onPick;

  const _SelectedList({required this.files, required this.onPick});

  @override
  State<_SelectedList> createState() => _SelectedListState();
}

class _SelectedListState extends State<_SelectedList> {
  late List<PlatformFile> _files;

  @override
  void initState() {
    super.initState();
    _files = List<PlatformFile>.from(widget.files);
  }

  @override
  void didUpdateWidget(covariant _SelectedList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // sinkron saat parent update
    _files = List<PlatformFile>.from(widget.files);
  }

  void _remove(PlatformFile f) {
    setState(() {
      _files.remove(f);
    });
    // Tidak memanggil setState parent agar simpel (preview saja).
    // Saat user klik Save, parent tetap validasi jumlah awal yang diset.
    // Kalau mau ketat, jadikan UploadEvidenceBox juga stateful dan naikkan perubahan ke parent via callback.
  }

  bool _isImageExt(String ext) {
    final e = ext.toLowerCase();
    return e == 'jpg' || e == 'jpeg' || e == 'png';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selected Files',
          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.neutral800),
        ),
        const SizedBox(height: 10),
        ..._files.map((f) => _SelectedFileTile(
              name: f.name,
              bytes: f.bytes,
              ext: (f.extension ?? '').toLowerCase(),
              onRemove: () => _remove(f),
            )),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: widget.onPick,
            icon: const Icon(Icons.add),
            label: const Text('Add more'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.neutral800,
              side: const BorderSide(color: AppColors.dividerGray),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectedFileTile extends StatelessWidget {
  final String name;
  final Uint8List? bytes;
  final String ext;
  final VoidCallback onRemove;

  const _SelectedFileTile({
    required this.name,
    required this.bytes,
    required this.ext,
    required this.onRemove,
  });

  bool get _isImage => ext == 'jpg' || ext == 'jpeg' || ext == 'png';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.dividerGray),
      ),
      child: Row(
        children: [
          // preview
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 44,
              height: 44,
              child: _isImage && bytes != null
                  ? Image.memory(bytes!, fit: BoxFit.cover)
                  : const Icon(Icons.insert_drive_file, color: AppColors.neutral500),
            ),
          ),
          const SizedBox(width: 10),

          // name
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.neutral800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // remove
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 18, color: AppColors.neutral500),
            splashRadius: 18,
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }
}
