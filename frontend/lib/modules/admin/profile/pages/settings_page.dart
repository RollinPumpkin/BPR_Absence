import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/data/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'develop_team_page.dart';
import 'help_support_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan back button
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Settings",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Preferences
              _buildSectionTitle("Preferences"),
              _buildSwitchTile("Notification", true, (val) {}),
              _buildTile("Language", trailing: const Text("English")),
              _buildTile("Theme", trailing: const Text("Light")),

              const SizedBox(height: 16),

              // Account
              _buildSectionTitle("Account"),
              _buildTile("Change Password"),
              _buildSwitchTile("Login with Face ID", false, (val) {}),
              _buildTile("Manage Devices"),

              const SizedBox(height: 16),

              // Support
              _buildSectionTitle("Support"),
              _buildTile("Location Settings"),
              _buildTile("App Version Info", trailing: const Text("v1.0.0")),
              _buildTile("Feedback"),

              const SizedBox(height: 16),

              // Information
              _buildSectionTitle("Information"),
              _buildTile("Terms & Privacy Policy"),
              _buildTile(
                "Help & Support",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HelpSupportPage(),
                    ),
                  );
                },
              ),
              _buildTile(
                "Developer Team",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DevelopTeamPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Logout Section
              _buildSectionTitle("Account"),
              _buildLogoutTile(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
    );
  }

  Widget _buildTile(String title, {Widget? trailing, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.pureWhite,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 14)),
            trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
      String title, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.pureWhite,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14)),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutTile() {
    return GestureDetector(
      onTap: _showLogoutDialog,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.errorRed.withValues(alpha: 0.05),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.logout, color: AppColors.errorRed, size: 20),
                SizedBox(width: 12),
                Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.errorRed,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Icon(Icons.chevron_right, color: AppColors.errorRed),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Konfirmasi Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performLogout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Perform logout
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();

      // Navigate to login page and remove all previous routes
      if (mounted) {
        Navigator.of(context).pop(); // Remove loading dialog
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      // Remove loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during logout: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }
}
