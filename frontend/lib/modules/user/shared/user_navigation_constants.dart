import 'package:flutter/material.dart';
import '../dashboard/dashboard_page.dart';
import '../attendance/attendance_page.dart';
import '../assignment/assignment_page.dart';
import '../letter/letter_page.dart';
import '../profile/profile_page.dart';

class UserNavigationConstants {
  static const List<IconData> icons = [
    Icons.home,
    Icons.calendar_today,
    Icons.check_box,
    Icons.access_time,
    Icons.person_outline,
  ];

  static const List<Widget> pages = [
    UserDashboardPage(),
    UserAttendancePage(),
    UserAssignmentPage(),
    UserLetterPage(),
    UserProfilePage(),
  ];
}