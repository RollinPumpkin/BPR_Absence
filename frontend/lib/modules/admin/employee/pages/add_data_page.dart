// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/constants/colors.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/services/api_service.dart';

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
  final TextEditingController divisionController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();

  // Dropdown values
  String? selectedGender;
  String? selectedContractType;
  String? selectedEducation;
  String? selectedRole;
  List<String> roleOptions = [];
  bool _isLoading = false;

  // Date of Birth
  DateTime? selectedDate;
  
  // Password visibility
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _setupRoleOptions();
  }

  void _setupRoleOptions() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserRole = authProvider.currentUser?.role;
    final currentEmployeeId = authProvider.currentUser?.employeeId ?? '';

    print('🎯 ADD EMPLOYEE: Current user role = "$currentUserRole"');
    print('🎯 ADD EMPLOYEE: Current employee ID = "$currentEmployeeId"');

    // Determine if current user has super admin privileges
    // Either by role or by employee ID pattern (SUP___)
    final isSuperAdmin = currentUserRole == 'super_admin' || currentEmployeeId.startsWith('SUP');
    final isAdmin = currentUserRole == 'admin' || currentEmployeeId.startsWith('ADM');

    print('🎯 ADD EMPLOYEE: Is Super Admin = $isSuperAdmin');
    print('🎯 ADD EMPLOYEE: Is Admin = $isAdmin');

    if (isSuperAdmin) {
      // Super Admin can add: Super Admin, Admin, Employee, Account Officer, Security, Office Boy
      roleOptions = ['SUPER ADMIN', 'ADMIN', 'EMPLOYEE', 'ACCOUNT OFFICER', 'SECURITY', 'OFFICE BOY'];
      print('🎯 ADD EMPLOYEE: Super Admin role options = $roleOptions');
    } else if (isAdmin) {
      // Admin can add: Employee, Account Officer, Security, Office Boy (no Admin)
      roleOptions = ['EMPLOYEE', 'ACCOUNT OFFICER', 'SECURITY', 'OFFICE BOY'];
      print('🎯 ADD EMPLOYEE: Admin role options = $roleOptions');
    } else {
      // Default fallback for other roles
      roleOptions = ['EMPLOYEE'];
      print('🎯 ADD EMPLOYEE: Default role options = $roleOptions');
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    fullnameController.dispose();
    passwordController.dispose();
    mobileController.dispose();
    placeOfBirthController.dispose();
    positionController.dispose();
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
                      // TODO: implement upload image
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
                    onPressed: _isLoading ? null : _saveEmployee,
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
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.pureWhite),
                          ),
                        )
                      : const Text('Save', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Save employee method
  Future<void> _saveEmployee() async {
    // Validate form
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final employeeId = await _generateEmployeeId();
      
      final employeeData = {
        'employee_id': employeeId,
        'full_name': fullnameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text,
        'phone': mobileController.text.trim(),
        'role': _convertRoleToBackend(selectedRole!),
        'position': positionController.text.trim(),
        'department': departmentController.text.trim(),
        'division': divisionController.text.trim(),
        'gender': selectedGender?.toLowerCase(),
        'place_of_birth': placeOfBirthController.text.trim(),
        'date_of_birth': selectedDate?.toIso8601String(),
        'contract_type': selectedContractType,
        'last_education': selectedEducation,
        'warning_letter_type': 'None', // Default value for new employees
      };

      final response = await ApiService.instance.post(
        '/auth/register',
        data: employeeData,
      );

      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Employee ${fullnameController.text} created successfully!'),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        _showError(response.message ?? 'Failed to create employee');
      }
    } catch (e) {
      _showError('Failed to create employee: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _validateForm() {
    if (fullnameController.text.trim().isEmpty) {
      _showError('Please enter full name');
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      _showError('Please enter email');
      return false;
    }
    if (passwordController.text.isEmpty) {
      _showError('Please enter password');
      return false;
    }
    if (selectedRole == null) {
      _showError('Please select a role');
      return false;
    }
    if (mobileController.text.trim().isEmpty) {
      _showError('Please enter mobile number');
      return false;
    }
    if (positionController.text.trim().isEmpty) {
      _showError('Please enter position');
      return false;
    }
    if (departmentController.text.trim().isEmpty) {
      _showError('Please enter department');
      return false;
    }
    return true;
  }

  Future<String> _generateEmployeeId() async {
    final role = selectedRole!;
    String prefix;
    
    // Use standardized prefixes based on new employee ID structure
    switch (role) {
      case 'SUPER ADMIN':
        prefix = 'SUP';
        break;
      case 'ADMIN':
        prefix = 'ADM';
        break;
      case 'EMPLOYEE':
        prefix = 'EMP';
        break;
      case 'ACCOUNT OFFICER':
        prefix = 'AO';  // Updated from 'AC' to 'AO'
        break;
      case 'SECURITY':
        prefix = 'SCR';
        break;
      case 'OFFICE BOY':
        prefix = 'OB';
        break;
      default:
        prefix = 'EMP';
    }

    // Get next sequential number for this role
    try {
      final response = await ApiService.instance.get('/users/next-employee-id/$prefix');
      if (response.success && response.data != null) {
        return response.data['employee_id'];
      }
    } catch (e) {
      print('Error getting next employee ID: $e');
    }

    // Fallback: Generate based on current timestamp if API fails
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final idNumber = (timestamp % 1000).toString().padLeft(3, '0');
    
    return '$prefix$idNumber';
  }

  String _convertRoleToBackend(String role) {
    switch (role) {
      case 'SUPER ADMIN':
        return 'super_admin';
      case 'ADMIN':
        return 'admin';
      case 'EMPLOYEE':
        return 'employee';
      case 'ACCOUNT OFFICER':
        return 'account_officer';
      case 'SECURITY':
        return 'security';
      case 'OFFICE BOY':
        return 'office_boy';
      default:
        return 'employee';
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
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