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

  // Work Schedule Controllers
  final TextEditingController workStartTimeController = TextEditingController();
  final TextEditingController workEndTimeController = TextEditingController();
  final TextEditingController lateThresholdController = TextEditingController();
  
  // Shift Controllers (for roles with multiple shifts)
  final TextEditingController shift2StartTimeController = TextEditingController();
  final TextEditingController shift2EndTimeController = TextEditingController();

  // Dropdown values
  String? selectedGender;
  String? selectedContractType;
  String? selectedShiftType;

  String? selectedEducation;
  String? selectedWarningLetter;
  String? selectedRole;

  final List<String> roleOptions = [
    'Employee',
    'Account Officer',
    'Security',
    'Office Boy',
  ];

  final List<String> shiftTypeOptions = [
    'Single Shift',
    'Double Shift (Morning/Evening)',
    'Custom Hours',
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

      // Prefill work schedule
      workStartTimeController.text = emp.workStartTime ?? '08:00';
      workEndTimeController.text = emp.workEndTime ?? '17:00';
      lateThresholdController.text = (emp.lateThresholdMinutes ?? 15).toString();
      
      // Prefill shift data
      selectedShiftType = emp.shiftType ?? _getDefaultShiftType(emp.role);
      shift2StartTimeController.text = emp.shift2StartTime ?? '';
      shift2EndTimeController.text = emp.shift2EndTime ?? '';
      
      // Set default work hours based on role if not set
      if (emp.workStartTime == null || emp.workEndTime == null) {
        _setDefaultWorkHoursByRole(emp.role);
      }
    }
  }

  // Get default shift type based on role
  String _getDefaultShiftType(String? role) {
    if (role == null) return 'Single Shift';
    
    switch (role.toLowerCase()) {
      case 'security':
        return 'Double Shift (Morning/Evening)';
      case 'office_boy':
      case 'office boy':
        return 'Custom Hours';
      case 'employee':
      case 'account_officer':
      case 'account officer':
      default:
        return 'Single Shift';
    }
  }

  // Set default work hours based on role
  void _setDefaultWorkHoursByRole(String? role) {
    if (role == null) return;
    
    switch (role.toLowerCase()) {
      case 'security':
        // Security uses shift assignment, but set default
        workStartTimeController.text = '06:00';
        workEndTimeController.text = '14:00';
        shift2StartTimeController.text = '18:00';
        shift2EndTimeController.text = '02:00';
        break;
      case 'office_boy':
      case 'office boy':
        // Office Boy: 12 hours (6 AM - 6 PM)
        workStartTimeController.text = '06:00';
        workEndTimeController.text = '18:00';
        break;
      case 'employee':
      case 'account_officer':
      case 'account officer':
      default:
        // Regular office hours
        workStartTimeController.text = '08:00';
        workEndTimeController.text = '17:00';
        break;
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
      // Prepare updated data with all fields
      final updateData = {
        'full_name': fullnameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': mobileController.text.trim(),
        'position': positionController.text.trim(),
        'department': departmentController.text.trim(),
        'division': divisionController.text.trim(),
        'role': _convertRoleToBackend(selectedRole),
        // Additional fields now supported
        'gender': selectedGender?.toLowerCase(),
        'place_of_birth': placeOfBirthController.text.trim(),
        'contract_type': selectedContractType,
        'last_education': selectedEducation,
        'emergency_contact': emergencyContactController.text.trim(),
        // Work Schedule fields
        'work_start_time': workStartTimeController.text.trim(),
        'work_end_time': workEndTimeController.text.trim(),
        'late_threshold_minutes': int.tryParse(lateThresholdController.text.trim()) ?? 15,
        // Shift fields
        'shift_type': selectedShiftType,
        'shift2_start_time': shift2StartTimeController.text.trim().isEmpty ? null : shift2StartTimeController.text.trim(),
        'shift2_end_time': shift2EndTimeController.text.trim().isEmpty ? null : shift2EndTimeController.text.trim(),
      };

      // Add date_of_birth if selected
      if (selectedDate != null) {
        updateData['date_of_birth'] = selectedDate!.toIso8601String();
      }

      // Remove empty/null values to avoid overwriting with blanks
      updateData.removeWhere((key, value) => 
        value == null || 
        (value is String && value.isEmpty)
      );

      print('📝 Update data being sent: $updateData');

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
      initialValue: value,
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
    
    workStartTimeController.dispose();
    workEndTimeController.dispose();
    lateThresholdController.dispose();
    shift2StartTimeController.dispose();
    shift2EndTimeController.dispose();

    workStartTimeController.dispose();
    workEndTimeController.dispose();
    lateThresholdController.dispose();
    
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
                      onChanged: (v) {
                        setState(() {
                          selectedRole = v;
                          // Auto-set shift type and work hours based on role
                          if (v != null) {
                            selectedShiftType = _getDefaultShiftType(v);
                            _setDefaultWorkHoursByRole(v);
                          }
                        });
                      },
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

                  const _SectionDivider(title: 'Shift Configuration'),

                  _field(
                    child: _dropdown(
                      label: 'Shift Type',
                      value: selectedShiftType,
                      items: shiftTypeOptions,
                      onChanged: (v) => setState(() => selectedShiftType = v),
                    ),
                  ),

                  // Show work schedule ONLY for Single Shift and Custom Hours (not Double Shift)
                  if (selectedShiftType == 'Single Shift' || selectedShiftType == 'Custom Hours') ...[
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8, top: 8),
                      child: Text(
                        'Work Schedule',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    _field(
                      child: TextFormField(
                        controller: workStartTimeController,
                        readOnly: true,
                        decoration: _inputDec('Work Start Time', 'HH:mm',
                            prefixIcon: const Icon(Icons.access_time, size: 18)),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(
                              hour: int.tryParse(workStartTimeController.text.split(':').first) ?? 8,
                              minute: int.tryParse(workStartTimeController.text.split(':').last) ?? 0,
                            ),
                          );
                          if (time != null) {
                            setState(() {
                              workStartTimeController.text =
                                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                            });
                          }
                        },
                      ),
                    ),
                    _field(
                      child: TextFormField(
                        controller: workEndTimeController,
                        readOnly: true,
                        decoration: _inputDec('Work End Time', 'HH:mm',
                            prefixIcon: const Icon(Icons.access_time, size: 18)),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(
                              hour: int.tryParse(workEndTimeController.text.split(':').first) ?? 17,
                              minute: int.tryParse(workEndTimeController.text.split(':').last) ?? 0,
                            ),
                          );
                          if (time != null) {
                            setState(() {
                              workEndTimeController.text =
                                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                            });
                          }
                        },
                      ),
                    ),
                    _field(
                      child: TextField(
                        controller: lateThresholdController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDec(
                          'Late Threshold (Minutes)',
                          'e.g., 15',
                          prefixIcon: const Icon(Icons.timer, size: 18),
                        ),
                      ),
                    ),
                  ],

                  // Show second shift fields only if double shift is selected
                  if (selectedShiftType == 'Double Shift (Morning/Evening)') ...[
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Shift 2 (Evening/Night)',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    _field(
                      child: TextFormField(
                        controller: shift2StartTimeController,
                        readOnly: true,
                        decoration: _inputDec('Shift 2 Start Time', 'HH:mm',
                            prefixIcon: const Icon(Icons.access_time, size: 18)),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(
                              hour: int.tryParse(shift2StartTimeController.text.split(':').first) ?? 18,
                              minute: int.tryParse(shift2StartTimeController.text.split(':').last) ?? 0,
                            ),
                          );
                          if (time != null) {
                            setState(() {
                              shift2StartTimeController.text =
                                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                            });
                          }
                        },
                      ),
                    ),
                    _field(
                      child: TextFormField(
                        controller: shift2EndTimeController,
                        readOnly: true,
                        decoration: _inputDec('Shift 2 End Time', 'HH:mm',
                            prefixIcon: const Icon(Icons.access_time, size: 18)),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(
                              hour: int.tryParse(shift2EndTimeController.text.split(':').first) ?? 6,
                              minute: int.tryParse(shift2EndTimeController.text.split(':').last) ?? 0,
                            ),
                          );
                          if (time != null) {
                            setState(() {
                              shift2EndTimeController.text =
                                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                            });
                          }
                        },
                      ),
                    ),
                  ],

                  // Helper text for different roles
                  if (selectedRole == 'Security') 
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12, top: 8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Security menggunakan sistem shift roster (Pagi/Malam). Shift diatur per hari melalui Shift Roster Management.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (selectedRole == 'Office Boy') 
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12, top: 8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Colors.amber.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Office Boy: Jam kerja 12 jam (06:00 - 18:00)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.amber.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (selectedRole == 'Employee' || selectedRole == 'Account Officer') 
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12, top: 8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Colors.green.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Jam kerja regular kantor (08:00 - 17:00)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
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
