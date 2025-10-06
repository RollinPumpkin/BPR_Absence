
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class AddEmployeePage extends StatefulWidget {
  const AddEmployeePage({super.key});

  @override
  State<AddEmployeePage> createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController placeOfBirthController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController nikController = TextEditingController();
  final TextEditingController accountHolderController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController divisionController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();

  // Dropdown values
  String? selectedGender;
  String? selectedContractType;
  String? selectedBank;
  String? selectedEducation;
  String? selectedWarningLetter;
  String? selectedRole;
  final List<String> roleOptions = ['Employee', 'Account Officer', 'Security', 'Office Boy'];

  // Date of Birth
  DateTime? selectedDate;
  
  // Password visibility
  bool _isPasswordVisible = false;

  @override
  void dispose() {
  emailController.dispose();
  fullnameController.dispose();
  passwordController.dispose();
    mobileController.dispose();
    placeOfBirthController.dispose();
    positionController.dispose();
    nikController.dispose();
    accountHolderController.dispose();
    accountNumberController.dispose();
    divisionController.dispose();
    _dobController.dispose();
    departmentController.dispose();
    super.dispose();
  }

  InputDecoration _inputDec(String label, String hint, {Widget? prefixIcon, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
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
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }

  TextStyle get _labelStyle => const TextStyle(
        fontWeight: FontWeight.w800,
        color: AppColors.neutral800,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,

      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Add New Employee',
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
        child: Container(
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upload foto
              Text('Photo', style: _labelStyle),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person, color: AppColors.neutral500, size: 40),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: implement upload image (pakai image_picker/file_picker bila diperlukan)
                    },
                    icon: const Icon(Icons.upload, size: 18),
                    label: const Text('Upload Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.pureWhite,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const _SectionDivider(title: 'Personal Information'),

              _field(
                child: TextField(
                  controller: fullnameController,
                  keyboardType: TextInputType.name,
                  decoration: _inputDec('Full Name', 'Enter the Full Name'),
                ),
              ),
              _field(
                child: TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDec('Email', 'Enter the Email', prefixIcon: const Icon(Icons.email, size: 18)),
                ),
              ),
              _field(
                child: TextField(
                  controller: passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: _inputDec('Password', 'Enter the Password', 
                    prefixIcon: const Icon(Icons.lock, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        size: 18,
                        color: AppColors.neutral500,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
              ),
              _field(
                child: _dropdown(
                  label: 'Role',
                  value: selectedRole,
                  items: roleOptions,
                  onChanged: (v) => setState(() => selectedRole = v),
                ),
              ),
              _field(
                child: TextField(
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDec('Mobile Number', 'Enter the Mobile Number', prefixIcon: const Icon(Icons.phone, size: 18)),
                ),
              ),
              _field(
                child: _dropdown(
                  label: 'Gender',
                  value: selectedGender,
                  items: const ['Male', 'Female'],
                  onChanged: (v) => setState(() => selectedGender = v),
                ),
              ),
              _field(
                child: TextField(
                  controller: placeOfBirthController,
                  decoration: _inputDec('Place of Birth', 'Enter the Place of Birth'),
                ),
              ),
              _field(
                child: TextFormField(
                  readOnly: true,
                  controller: _dobController,
                  decoration: _inputDec('Date of Birth', 'dd/mm/yyyy',
                      suffixIcon: const Icon(Icons.calendar_today, color: AppColors.neutral500)),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime(2000),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                        _dobController.text = '${picked.day}/${picked.month}/${picked.year}';
                      });
                    }
                  },
                ),
              ),

              const SizedBox(height: 8),
              const _SectionDivider(title: 'Employment'),

              _field(
                child: TextField(
                  controller: positionController,
                  decoration: _inputDec('Position', 'Enter the Position'),
                ),
              ),
              _field(
                child: _dropdown(
                  label: 'Contract Type',
                  value: selectedContractType,
                  items: const ['3 Months', '6 Months', '1 Year'],
                  onChanged: (v) => setState(() => selectedContractType = v),
                ),
              ),
              _field(
                child: TextField(
                  controller: divisionController,
                  decoration: _inputDec('Division', 'Enter the Division'),
                ),
              ),
              _field(
                child: TextField(
                  controller: departmentController,
                  decoration: _inputDec('Department', 'Enter the Department'),
                ),
              ),
              _field(
                child: _dropdown(
                  label: 'Last Education',
                  value: selectedEducation,
                  items: const ['High School', 'Diploma', 'Bachelor', 'Master'],
                  onChanged: (v) => setState(() => selectedEducation = v),
                ),
              ),
              _field(
                child: TextField(
                  controller: nikController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDec('NIK', 'Enter the NIK', prefixIcon: const Icon(Icons.badge_outlined, size: 18)),
                ),
              ),

              const SizedBox(height: 8),
              const _SectionDivider(title: 'Banking'),

              _field(
                child: _dropdown(
                  label: 'Bank',
                  value: selectedBank,
                  items: const ['BCA', 'BRI', 'Mandiri', 'BNI'],
                  onChanged: (v) => setState(() => selectedBank = v),
                ),
              ),
              _field(
                child: TextField(
                  controller: accountHolderController,
                  decoration: _inputDec("Account Holder’s Name", 'Bank Number Account Holder Name'),
                ),
              ),
              _field(
                child: TextField(
                  controller: accountNumberController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDec('Account Number', 'Enter the Account Number'),
                ),
              ),

              const SizedBox(height: 8),
              const _SectionDivider(title: 'Other'),

              _field(
                child: _dropdown(
                  label: 'Warning Letter Type',
                  value: selectedWarningLetter,
                  items: const ['None', 'SP1', 'SP2', 'SP3'],
                  onChanged: (v) => setState(() => selectedWarningLetter = v),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.neutral800,
                      side: const BorderSide(color: AppColors.dividerGray),
                      backgroundColor: AppColors.pureWhite,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Save logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Employee saved'),
                          backgroundColor: AppColors.primaryGreen,
                        ),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.pureWhite,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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

  // ===== Helpers =====
  Widget _field({required Widget child}) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: child,
      );

  Widget _dropdown({
    required String label,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: _inputDec(label, '-Choose $label'),
      borderRadius: BorderRadius.circular(12),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  final String title;
  const _SectionDivider({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 6),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.neutral800,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(child: Divider(color: AppColors.dividerGray, height: 1)),
        ],
      ),
    );
  }
}
