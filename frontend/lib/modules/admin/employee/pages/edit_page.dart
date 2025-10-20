import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/modules/admin/employee/models/employee.dart';
import 'package:frontend/data/services/employee_service.dart';

class EditPage extends StatefulWidget {
  final Employee? employee; // ⬅️ optional prefill
  const EditPage({super.key, this.employee});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController placeOfBirthController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController emergencyContactController = TextEditingController();

  final TextEditingController divisionController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();

  // Dropdown values
  String? selectedGender;
  String? selectedContractType;

  String? selectedEducation;
  String? selectedWarningLetter;
  String? selectedRole;

  final List<String> roleOptions = [
    'Employee',
    'Account Officer',
    'Security',
    'Office Boy',
  ];

  DateTime? selectedDate;
  
  // Password visibility
  bool _isPasswordVisible = false;
  
  // Loading state
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Prefill dari employee bila ada
    final emp = widget.employee;
    if (emp != null) {
      fullnameController.text = emp.fullName ?? '';
      emailController.text = emp.email ?? '';
      // password: jangan diprefill (keamanan), biarkan kosong
      mobileController.text = emp.mobileNumber ?? '';
      placeOfBirthController.text = emp.placeOfBirth ?? '';
      positionController.text = emp.position ?? '';
      emergencyContactController.text = emp.emergencyContact ?? '';

      divisionController.text = emp.division ?? '';
      departmentController.text = emp.department ?? '';

      selectedGender = _convertGenderForDropdown(emp.gender);
      selectedContractType = emp.contractType;
      selectedEducation = emp.lastEducation;
      selectedWarningLetter = emp.warningLetterType;
      selectedRole = _convertRoleForDropdown(emp.role);

      if (emp.dateOfBirth != null) {
        selectedDate = emp.dateOfBirth;
        _dobController.text =
            '${emp.dateOfBirth!.day}/${emp.dateOfBirth!.month}/${emp.dateOfBirth!.year}';
      }
    }
  }

  // Convert role from database format to dropdown format
  String? _convertRoleForDropdown(String? role) {
    if (role == null) return null;
    
    switch (role.toLowerCase()) {
      case 'employee':
        return 'Employee';
      case 'account_officer':
      case 'account officer':
        return 'Account Officer';
      case 'security':
        return 'Security';
      case 'office_boy':
      case 'office boy':
        return 'Office Boy';
      case 'admin':
        return 'Employee'; // Default admin to Employee if not in dropdown
      case 'super_admin':
        return 'Employee'; // Default super_admin to Employee if not in dropdown
      default:
        return roleOptions.contains(role) ? role : 'Employee'; // Default fallback
    }
  }

  // Convert gender from database format to dropdown format
  String? _convertGenderForDropdown(String? gender) {
    if (gender == null) return null;
    
    switch (gender.toLowerCase()) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      default:
        return ['Male', 'Female'].contains(gender) ? gender : null; // Default fallback
    }
  }

  // Save employee data
  Future<void> _saveEmployeeData() async {
    if (widget.employee?.id == null) {
      _showError('No employee ID available for update');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare updated data (only fields supported by current endpoint)
      final updateData = {
        'full_name': fullnameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': mobileController.text.trim(),
        'position': positionController.text.trim(),
        'department': departmentController.text.trim(),
        'role': _convertRoleToBackend(selectedRole),
        // Note: gender, place_of_birth, date_of_birth, contract_type, last_education
        // are not yet supported by the backend endpoint
        // emergency_contact field not in UI form yet
      };

      // Update user via admin endpoint
      final response = await EmployeeService.updateEmployee(
        widget.employee!.id!,
        updateData,
      );

      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        _showError(response.message ?? 'Failed to update profile');
      }
    } catch (e) {
      _showError('Failed to update profile: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Convert role from dropdown format to backend format
  String? _convertRoleToBackend(String? role) {
    if (role == null) return null;
    
    switch (role) {
      case 'Employee':
        return 'employee';
      case 'Account Officer':
        return 'account_officer';
      case 'Security':
        return 'security';
      case 'Office Boy':
        return 'office_boy';
      default:
        return role.toLowerCase();
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }

  // Helpers
  InputDecoration _inputDec(
    String label,
    String hint, {
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
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

  Widget _field({required Widget child}) =>
      Padding(padding: const EdgeInsets.only(bottom: 12), child: child);

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

  @override
  void dispose() {
    emailController.dispose();
    fullnameController.dispose();
    passwordController.dispose();
    mobileController.dispose();
    placeOfBirthController.dispose();
    positionController.dispose();
    emergencyContactController.dispose();

    divisionController.dispose();
    _dobController.dispose();
    departmentController.dispose();
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
                  // Personal
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
                      decoration: _inputDec('Email', 'Enter the Email',
                          prefixIcon: const Icon(Icons.email, size: 18)),
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
                      decoration: _inputDec('Mobile Number', 'Enter the Mobile Number',
                          prefixIcon: const Icon(Icons.phone, size: 18)),
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
                            _dobController.text =
                                '${picked.day}/${picked.month}/${picked.year}';
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
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Actions
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
                  onPressed: _isLoading ? null : _saveEmployeeData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.pureWhite,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.pureWhite,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Save', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Divider section (konsisten)
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
