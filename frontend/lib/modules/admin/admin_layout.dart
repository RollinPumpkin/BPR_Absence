import 'package:flutter/material.dart';
import '../../core/widgets/custom_bottom_nav.dart';
import 'package:frontend/modules/admin/dashboard/dashboard_page.dart';
import 'package:frontend/modules/admin/assigment/assigment_page.dart';
import 'package:frontend/modules/admin/attandance/attandace_page.dart';
import 'package:frontend/modules/admin/letter/letter_page.dart';
import 'package:frontend/modules/admin/profile/profile_page.dart';

class AdminLayout extends StatelessWidget {
  final int currentIndex;
  const AdminLayout({
    super.key,
    required this.currentIndex,
  });

  static final List<Widget> _pages = const [
    AdminDashboardPage(),
    AttandancePage(),
    AssigmentPage(),
    LetterPage(),
    ProfilePage(),
  ];

  static const List<IconData> _icons = [
    Icons.home,
    Icons.calendar_today,
    Icons.check_box,
    Icons.mail_outline,
    Icons.person_outline,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[currentIndex],
      bottomNavigationBar: CustomBottomNav(
        currentIndex: currentIndex,
        icons: _icons,
        pages: _pages,
      ),
    );
  }
}
