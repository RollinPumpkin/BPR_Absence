import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/providers/user_provider.dart';
import 'package:frontend/data/providers/auth_provider.dart';
import 'package:frontend/modules/admin/profile/widgets/profile_info_card.dart';
import 'package:frontend/modules/admin/profile/widgets/profile_stats_card.dart';
import 'package:frontend/modules/admin/profile/widgets/profile_action_card.dart';
import 'package:frontend/modules/admin/profile/pages/edit_profile_page.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _isLoading = true;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.getCurrentUser();
      
      if (mounted) {
        setState(() {
          _currentUser = userProvider.currentUser;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $e'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neutral800),
          onPressed: () => Navigator.of(context).pushReplacementNamed('/user/dashboard'),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: AppColors.neutral800,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_currentUser != null)
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.neutral800),
              onPressed: () => _navigateToEditProfile(),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
              ? const Center(
                  child: Text(
                    'Unable to load profile data',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUserData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Information Card
                        ProfileInfoCard(
                          user: _currentUser!,
                          onEditPressed: _navigateToEditProfile,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Statistics Card
                        Consumer<UserProvider>(
                          builder: (context, userProvider, child) {
                            return ProfileStatsCard(
                              attendanceRate: userProvider.userStatistics?['attendance_rate'] ?? 0.0,
                              totalPresent: userProvider.userStatistics?['total_present'] ?? 0,
                              totalAbsent: userProvider.userStatistics?['total_absent'] ?? 0,
                              totalLate: userProvider.userStatistics?['total_late'] ?? 0,
                            );
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Quick Actions Card
                        ProfileActionCard(
                          title: 'Quick Actions',
                          actions: _getUserActions(),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Account Settings Card
                        _buildAccountSettingsCard(),
                      ],
                    ),
                  ),
                ),
    );
  }

  List<ProfileAction> _getUserActions() {
    return [
      ProfileAction(
        icon: Icons.schedule,
        title: 'My Attendance',
        subtitle: 'View attendance history',
        color: AppColors.primaryBlue,
        onTap: () {
          // Navigate to attendance history
          Navigator.pushNamed(context, '/attendance');
        },
      ),
      ProfileAction(
        icon: Icons.mail,
        title: 'Submit Request',
        subtitle: 'Request leave or permission',
        color: AppColors.primaryGreen,
        onTap: () {
          // Navigate to request submission
          Navigator.pushNamed(context, '/submit-request');
        },
      ),
      ProfileAction(
        icon: Icons.history,
        title: 'Request History',
        subtitle: 'View submitted requests',
        color: AppColors.primaryOrange,
        onTap: () {
          // Navigate to request history
          Navigator.pushNamed(context, '/request-history');
        },
      ),
      ProfileAction(
        icon: Icons.notifications,
        title: 'Notifications',
        subtitle: 'View notifications',
        color: AppColors.primaryPurple,
        onTap: () {
          // Navigate to notifications
          Navigator.pushNamed(context, '/notifications');
        },
      ),
    ];
  }

  Widget _buildAccountSettingsCard() {
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
            'Account Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral800,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildSettingsItem(
            icon: Icons.lock,
            title: 'Change Password',
            subtitle: 'Update your password',
            onTap: _showChangePasswordDialog,
          ),
          
          const Divider(height: 32),
          
          _buildSettingsItem(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'Bahasa Indonesia',
            onTap: () {
              // Language settings
            },
          ),
          
          const Divider(height: 32),
          
          _buildSettingsItem(
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () {
              // Help and support
            },
          ),
          
          const Divider(height: 32),
          
          _buildSettingsItem(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            color: AppColors.primaryRed,
            onTap: _showLogoutDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? color,
    required VoidCallback onTap,
  }) {
    final itemColor = color ?? AppColors.neutral800;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: itemColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: itemColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: itemColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEditProfile() {
    if (_currentUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfilePage(user: _currentUser!),
        ),
      ).then((_) {
        // Refresh data when returning from edit page
        _loadUserData();
      });
    }
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Change Password'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: currentPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Current Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Current password is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'New password is required';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm New Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value != newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    if (formKey.currentState!.validate()) {
                      setState(() {
                        isLoading = true;
                      });

                      try {
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        final success = await authProvider.changeUserPassword(
                          currentPasswordController.text,
                          newPasswordController.text,
                        );

                        if (success && mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password changed successfully'),
                              backgroundColor: AppColors.primaryGreen,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to change password: $e'),
                              backgroundColor: AppColors.primaryRed,
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      }
                    }
                  },
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Change'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                
                try {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  await authProvider.logout();
                  
                  if (mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Logout failed: $e'),
                        backgroundColor: AppColors.primaryRed,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}