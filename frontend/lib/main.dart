import 'package:flutter/material.dart';
import 'package:frontend/modules/admin/assigment/assigment_page.dart';
import 'package:frontend/modules/admin/attandance/attandace_page.dart';
import 'package:frontend/modules/admin/letter/letter_page.dart';
import 'package:frontend/modules/admin/profile/profile_page.dart';
import 'modules/splash_page.dart';
import 'modules/auth/login_page.dart';
import 'modules/admin/dashboard/dashboard_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BPR Absence',
      theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashPage(),
        '/login': (_) => const LoginPage(),

        // Admin
        '/admin/dashboard': (_) => const AdminDashboardPage(),
        '/admin/attendance': (_) => const AttandancePage(),
        '/admin/assigment': (_) => const AssigmentPage(),
        '/admin/letter': (_) => const LetterPage(),
        '/admin/profile': (_) => const ProfilePage(),

        // User
        // '/user/dashboard': (_) => const UserDashboardPage(),
        // '/user/attendance': (_) => const UserAttendancePage(),
        // '/user/assigment': (_) => const UserAssigmentPage(),
        // '/user/letter': (_) => const UserLetterPage(),
        // '/user/profile': (_) => const UserProfilePage(),
      },
    );
  }
}
