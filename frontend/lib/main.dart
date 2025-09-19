import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

// Auth
import 'modules/auth/login_page.dart';
// import 'modules/auth/register_page.dart';
import 'modules/auth/forgot-pass_page.dart';
import 'modules/auth/email_page.dart';
import 'modules/auth/reset_password_page.dart';
import 'modules/auth/expired-link_page.dart';

// Splash
import 'modules/splash_page.dart';

// Admin
import 'modules/admin/dashboard/dashboard_page.dart';
import 'modules/admin/attandance/attandace_page.dart';
import 'modules/admin/assigment/assigment_page.dart';
import 'modules/admin/letter/letter_page.dart';
import 'modules/admin/profile/profile_page.dart';

// User
import 'modules/user/dashboard/dashboard_page.dart';
import 'modules/user/attendance/attendance_page.dart';
import 'modules/user/assignment/assignment_page.dart';
import 'modules/user/letter/letter_page.dart';
import 'modules/user/profile/profile_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BPR Absence',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/', // Splash pertama
      routes: {
        // General
        '/': (_) => const SplashPage(),
        '/login': (_) => const LoginPage(),
        // '/register': (_) => const RegisterPage(),
        '/forgot-password': (_) => const ForgotPassPage(),
        '/forgot-password/email': (_) => const EmailPage(),
        '/forgot-password/email/Expired-link': (_) => const LinkExpiredPage(),
        '/forgot-password/reset-password': (_) => const ResetPasswordPage(),

        // Admin routes
        '/admin/dashboard': (_) => const AdminDashboardPage(),
        '/admin/attendance': (_) => const AttandancePage(),
        '/admin/assigment': (_) => const AssigmentPage(),
        '/admin/letter': (_) => const LetterPage(),
        '/admin/profile': (_) => const ProfilePage(),

        // User routes
        '/user/dashboard': (_) => const UserDashboardPage(),
        '/user/attendance': (_) => const UserAttendancePage(),
        '/user/assignment': (_) => const UserAssignmentPage(),
        '/user/letter': (_) => const UserLetterPage(),
        '/user/profile': (_) => const UserProfilePage(),
      },
    );
  }
}
