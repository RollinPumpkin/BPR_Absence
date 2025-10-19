import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/providers/user_provider.dart';

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({
    super.key,
    required this.user,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _positionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _employeeIdController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _fullNameController.text = widget.user.fullName;
    _emailController.text = widget.user.email;
    _phoneController.text = widget.user.phone ?? '';
    _positionController.text = widget.user.position ?? '';
    _departmentController.text = widget.user.department ?? '';
    _employeeIdController.text = widget.user.employeeId;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _departmentController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColors.neutral800,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: Text(
              'Save',
              style: TextStyle(
                color: _isLoading ? Colors.grey : AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture Section
              _buildProfilePictureSection(),
              
              const SizedBox(height: 24),
              
              // Form Fields
              _buildFormCard(),
              
              const SizedBox(height: 24),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.pureWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.pureWhite,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.primaryRed],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: AppColors.pureWhite,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.pureWhite, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: AppColors.pureWhite,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Tap to change profile picture',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral800,
            ),
          ),
          const SizedBox(height: 20),
          
          // Full Name
          _buildTextField(
            controller: _fullNameController,
            label: 'Full Name',
            icon: Icons.person,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Full name is required';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Email
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Employee ID
          _buildTextField(
            controller: _employeeIdController,
            label: 'Employee ID',
            icon: Icons.badge,
          ),
          
          const SizedBox(height: 16),
          
          // Phone
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
          
          const SizedBox(height: 16),
          
          // Position
          _buildTextField(
            controller: _positionController,
            label: 'Position',
            icon: Icons.work,
          ),
          
          const SizedBox(height: 16),
          
          // Department
          _buildTextField(
            controller: _departmentController,
            label: 'Department',
            icon: Icons.business,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      final updatedData = {
        'full_name': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'employee_id': _employeeIdController.text.trim(),
        'phone': _phoneController.text.trim(),
        'position': _positionController.text.trim(),
        'department': _departmentController.text.trim(),
      };

      final success = await userProvider.updateProfile(widget.user.id, updatedData);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}