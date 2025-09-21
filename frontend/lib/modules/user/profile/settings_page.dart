import 'package:flutter/material.dart';
import 'check_email_page.dart';
import 'help_desk_page.dart';

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  bool notificationEnabled = true;
  bool faceIdEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preferences Section
            _buildSectionHeader('Preferences'),
            const SizedBox(height: 8),
            _buildSettingsCard([
              _buildToggleItem('Notification', notificationEnabled, (value) {
                setState(() {
                  notificationEnabled = value;
                });
              }),
              _buildDivider(),
              _buildNavigationItem('Language', 'English'),
              _buildDivider(),
              _buildNavigationItem('Theme', 'Light'),
            ]),
            
            const SizedBox(height: 24),
            
            // Account Section
            _buildSectionHeader('Account'),
            const SizedBox(height: 8),
            _buildSettingsCard([
              _buildNavigationItem('Change Password', '', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CheckEmailPage(),
                  ),
                );
              }),
              _buildDivider(),
              _buildToggleItem('Login with Face ID', faceIdEnabled, (value) {
                setState(() {
                  faceIdEnabled = value;
                });
              }),
              _buildDivider(),
              _buildNavigationItem('Manage Devices', ''),
            ]),
            
            const SizedBox(height: 24),
            
            // Support Section
            _buildSectionHeader('Support'),
            const SizedBox(height: 8),
            _buildSettingsCard([
              _buildNavigationItem('Location Settings', ''),
              _buildDivider(),
              _buildNavigationItem('App Version Info', 'v1.0.0'),
              _buildDivider(),
              _buildNavigationItem('Feedback', ''),
            ]),
            
            const SizedBox(height: 24),
            
            // Information Section
            _buildSectionHeader('Information'),
            const SizedBox(height: 8),
            _buildSettingsCard([
              _buildNavigationItem('Terms & Privacy Policy', ''),
              _buildDivider(),
              _buildNavigationItem('Help & Support', '', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpDeskPage(),
                  ),
                );
              }),
              _buildDivider(),
              _buildNavigationItem('Developer Team', ''),
            ]),
            
            const SizedBox(height: 32),
            
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildNavigationItem(String title, String subtitle, [VoidCallback? onTap]) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right,
            color: Colors.grey,
            size: 20,
          ),
        ],
      ),
      onTap: onTap ?? () {
        // Handle navigation to specific setting
      },
    );
  }

  Widget _buildToggleItem(String title, bool value, Function(bool) onChanged) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFFE53E3E),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF0F0F0),
      indent: 16,
      endIndent: 16,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}