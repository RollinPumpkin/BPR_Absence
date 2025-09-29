import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/custom_bottom_nav_router.dart';
import 'package:frontend/modules/admin/shared/admin_nav_items.dart';
import 'package:frontend/core/constants/colors.dart';

import 'package:frontend/modules/admin/profile/widgets/profile_header.dart';
import 'package:frontend/modules/admin/profile/widgets/contact_info_card.dart';
import 'package:frontend/modules/admin/profile/widgets/summary_section.dart';
import 'package:frontend/modules/admin/profile/pages/settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,

      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.neutral800,
            fontWeight: FontWeight.w800,
          ),
        ),
            actions: [
      IconButton(
        icon: const Icon(Icons.settings, color: AppColors.neutral800),
        splashRadius: 20,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsPage()),
          );
        },
      ),
    ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            ProfileHeader(),
            SizedBox(height: 16),
            ContactInfoCard(),
            SizedBox(height: 16),
            SummarySection(),
          ],
        ),
      ),

      bottomNavigationBar: CustomBottomNavRouter(
        currentIndex: 4,
        items: AdminNavItems.items,
      ),
    );
  }
}
