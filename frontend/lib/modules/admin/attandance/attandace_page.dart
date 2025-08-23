import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/custom_bottom_nav.dart';
import 'package:frontend/modules/admin/dashboard/dashboard_page.dart';
import 'package:frontend/modules/admin/assigment/assigment_page.dart';
import 'package:frontend/modules/admin/letter/letter_page.dart';
import 'package:frontend/modules/admin/profile/profile_page.dart';

class AttandancePage extends StatelessWidget {
  const AttandancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Text("Attendance Page")),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1, 
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
