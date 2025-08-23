import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/custom_bottom_nav.dart';
import 'package:frontend/modules/admin/dashboard/dashboard_page.dart';
import 'package:frontend/modules/admin/attandance/attandace_page.dart';
import 'package:frontend/modules/admin/letter/letter_page.dart';
import 'package:frontend/modules/admin/profile/profile_page.dart';

class AssigmentPage extends StatelessWidget {
  const AssigmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Text("Assigment Page")),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 2,
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
