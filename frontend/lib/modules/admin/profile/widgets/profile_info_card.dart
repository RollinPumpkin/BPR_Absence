import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/data/models/user.dart';

class ProfileInfoCard extends StatelessWidget {
  final User user;
  final VoidCallback? onEditPressed;

  const ProfileInfoCard({
    super.key,
    required this.user,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
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
        children: [
          // Profile Picture and Basic Info
          Row(
            children: [
              // Profile Picture
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.primaryRed],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: AppColors.pureWhite,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Basic Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getRoleColor(user.role).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getRoleText(user.role),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getRoleColor(user.role),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Edit Button
              if (onEditPressed != null)
                IconButton(
                  onPressed: onEditPressed,
                  icon: const Icon(Icons.edit),
                  color: AppColors.primaryBlue,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          
          // Detailed Information
          _buildInfoRow(Icons.badge, 'Employee ID', user.employeeId.isNotEmpty ? user.employeeId : 'Not Set'),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.work, 'Position', user.position ?? 'Not Set'),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.business, 'Department', user.department ?? 'Not Set'),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.phone, 'Phone', user.phone ?? 'Not Set'),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.circle, 
            'Status', 
            user.isActive ? 'Active' : 'Inactive',
            valueColor: user.isActive ? AppColors.primaryGreen : AppColors.primaryRed,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.neutral800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
      case 'super_admin':
        return AppColors.primaryRed;
      case 'manager':
        return AppColors.primaryBlue;
      default:
        return AppColors.primaryGreen;
    }
  }

  String _getRoleText(String role) {
    switch (role.toLowerCase()) {
      case 'super_admin':
        return 'Super Admin';
      case 'admin':
        return 'Admin';
      case 'manager':
        return 'Manager';
      default:
        return 'Employee';
    }
  }
}