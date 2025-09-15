import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/custom_bottom_nav.dart';
import 'package:frontend/modules/admin/dashboard/dashboard_page.dart';
import 'package:frontend/modules/admin/attandance/attandace_page.dart';
import 'package:frontend/modules/admin/assigment/assigment_page.dart';
import 'package:frontend/modules/admin/letter/letter_page.dart';
import 'package:frontend/modules/admin/profile/widgets/profile_header.dart';
import 'package:frontend/modules/admin/profile/widgets/contact_info_card.dart';
import 'package:frontend/modules/admin/profile/widgets/summary_section.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 4,
        icons: const [
          Icons.home,
          Icons.calendar_today,
          Icons.check_box,
          Icons.mail_outline,
          Icons.person_outline,
        ],
        pages: const [
          AdminDashboardPage(),
          AttandancePage(),
          AssigmentPage(),
          LetterPage(),
          ProfilePage(),
        ],
      ),
    );
  }
}
