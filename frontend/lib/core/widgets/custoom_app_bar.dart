import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  String _getTitle(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name ?? "";

    switch (routeName) {
      case '/admin/dashboard':
        return "Dashboard";
      case '/admin/attendance':
        return "Attendance";
      case '/admin/assignment':
        return "Assignment";
      case '/admin/letter':
        return "Letter";
      case '/admin/employees':
        return "Employee Database";
      case '/admin/profile':
        return "Profile";
      case '/user/dashboard':
        return "Dashboard";
      case '/user/attendance':
        return "Attendance";
      case '/user/assignment':
        return "Assignment";
      case '/user/letter':
        return "Letter";
      case '/user/profile':
        return "Profile";
      default:
        return "App";
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        _getTitle(context),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
