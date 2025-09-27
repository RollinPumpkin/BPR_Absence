import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  // Dropdown states
  String? _gender;
  String? _contract;
  String? _bank;
  String? _education;
  String? _warning;

  // Date of birth
  final _dobCtrl = TextEditingController();

  InputDecoration _dec(String hint) => InputDecoration(
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
      );

  TextStyle get _labelStyle => const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: AppColors.neutral800,
      );

  @override
  void dispose() {
    _dobCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.pureWhite,
        foregroundColor: AppColors.neutral800,
        centerTitle: false,
        title: const Text(
          'Edit Information Profile',
          style: TextStyle(
            color: AppColors.neutral800,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar + edit
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowColor,
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person, size: 52, color: AppColors.neutral400),
                  ),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: Material(
                      color: AppColors.pureWhite,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Change profile picture')),
                          );
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.dividerGray),
                          ),
                          child: const Icon(Icons.edit, size: 18, color: AppColors.accentBlue),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card form
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(12),
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
                  // First Name
                  Text('First Name', style: _labelStyle),
                  const SizedBox(height: 6),
                  TextField(decoration: _dec('Enter the First Name')),
                  const SizedBox(height: 16),

                  // Mobile Number
                  Text('Mobile Number', style: _labelStyle),
                  const SizedBox(height: 6),
                  TextField(
                    keyboardType: TextInputType.phone,
                    decoration: _dec('Enter the Mobile Number'),
                  ),
                  const SizedBox(height: 16),

                  // Gender
                  Text('Gender', style: _labelStyle),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: _dec('-Choose Gender'),
                    items: const ['Male', 'Female']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _gender = v),
                  ),
                  const SizedBox(height: 16),

                  // Place of Birth
                  Text('Place of Birth', style: _labelStyle),
                  const SizedBox(height: 6),
                  TextField(decoration: _dec('Enter the Place of Birth')),
                  const SizedBox(height: 16),

                  // Position
                  Text('Position', style: _labelStyle),
                  const SizedBox(height: 6),
                  TextField(decoration: _dec('Enter the Position')),
                  const SizedBox(height: 16),

                  // Contract Type
                  Text('Contract Type', style: _labelStyle),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _contract,
                    decoration: _dec('-Choose Type'),
                    items: const ['Full Time', 'Part Time', 'Internship']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _contract = v),
                  ),
                  const SizedBox(height: 16),

                  // Bank
                  Text('Bank', style: _labelStyle),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _bank,
                    decoration: _dec('-Choose Bank'),
                    items: const ['BCA', 'BRI', 'Mandiri', 'BNI']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _bank = v),
                  ),
                  const SizedBox(height: 16),

                  // Account Holder’s Name
                  Text('Account Holder’s Name', style: _labelStyle),
                  const SizedBox(height: 6),
                  TextField(decoration: _dec('Bank Number Account Holder Name')),
                  const SizedBox(height: 16),

                  // Last Name
                  Text('Last Name', style: _labelStyle),
                  const SizedBox(height: 6),
                  TextField(decoration: _dec('Enter the Last Name')),
                  const SizedBox(height: 16),

                  // NIK
                  Text('NIK', style: _labelStyle),
                  const SizedBox(height: 6),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: _dec('Enter the NIK'),
                  ),
                  const SizedBox(height: 16),

                  // Last Education
                  Text('Last Education', style: _labelStyle),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _education,
                    decoration: _dec('-Choose Education'),
                    items: const ['SMA', 'D3', 'S1', 'S2']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _education = v),
                  ),
                  const SizedBox(height: 16),

                  // Date of Birth
                  Text('Date of Birth', style: _labelStyle),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _dobCtrl,
                    readOnly: true,
                    decoration: _dec('dd/mm/yyyy').copyWith(
                      prefixIcon: const Icon(Icons.calendar_today, color: AppColors.accentBlue),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                        initialDate: DateTime(2000),
                      );
                      if (picked != null) {
                        _dobCtrl.text = '${picked.day}/${picked.month}/${picked.year}';
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Devision
                  Text('Devision', style: _labelStyle),
                  const SizedBox(height: 6),
                  TextField(decoration: _dec('Enter the Devision')),
                  const SizedBox(height: 16),

                  // Account Number
                  Text('Account Number', style: _labelStyle),
                  const SizedBox(height: 6),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: _dec('Enter the Account Number'),
                  ),
                  const SizedBox(height: 16),

                  // Warning Letter Type
                  Text('Warning Letter Type', style: _labelStyle),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _warning,
                    decoration: _dec('-Choose Type'),
                    items: const ['SP1', 'SP2', 'SP3']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _warning = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: AppColors.pureWhite,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.pureWhite,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    // TODO: save logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated'),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
