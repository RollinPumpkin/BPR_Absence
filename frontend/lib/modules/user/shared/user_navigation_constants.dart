import 'package:flutter/material.dart';
import '../dashboard/dashboard_page.dart';
import '../attendance/attendance_page.dart';
import '../assignment/assignment_page.dart';
import '../letters/letters_page.dart';
import '../profile/profile_page.dart';

class UserNavigationConstants {
  static const List<IconData> icons = [
    Icons.home,
    Icons.calendar_today,
    Icons.check_box,
    Icons.description,
    Icons.person_outline,
  ];

  static const List<Widget> pages = [
    UserDashboardPage(),
    UserAttendancePage(),
    UserAssignmentPage(),
    UserLettersPage(),
    UserProfilePage(),
  ];
}