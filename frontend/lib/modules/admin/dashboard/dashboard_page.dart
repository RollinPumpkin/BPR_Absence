import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/custom_bottom_nav.dart';
import 'package:frontend/modules/admin/attandance/attandace_page.dart';
import 'package:frontend/modules/admin/assigment/assigment_page.dart';
import 'package:frontend/modules/admin/letter/letter_page.dart';
import 'package:frontend/modules/admin/profile/profile_page.dart';
import 'widgets/header.dart';
import 'widgets/menu_button.dart';
import 'widgets/section_title.dart';
import 'widgets/letter_card.dart';
import 'widgets/assignment_card.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DashboardHeader(),

            const SizedBox(height: 20),

            // Menu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  MenuButton(icon: Icons.people, label: "Employee Data", color: Colors.red),
                  MenuButton(icon: Icons.book, label: "Report", color: Colors.green),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Letter Section
            const SectionTitle(title: "Letter", action: "View"),
            const LetterCard(name: "Septa Puma", status: "Absence", statusColor: Colors.orange),
            const LetterCard(name: "Septa Puma", status: "Absence", statusColor: Colors.red),

            // Assignment Section
            const SectionTitle(title: "Assignment", action: "View"),
            const AssignmentCard(title: "Weekly Report", description: "Complete weekly task"),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
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
