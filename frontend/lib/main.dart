import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/no_animations.dart';

import 'modules/auth/login_page.dart';
import 'modules/auth/forgot-pass_page.dart';
import 'modules/auth/email_page.dart';
import 'modules/auth/reset_password_page.dart';
import 'modules/auth/expired-link_page.dart';

import 'modules/splash_page.dart';

import 'modules/admin/dashboard/dashboard_page.dart';
import 'modules/admin/employee/employee_page.dart';
import 'modules/admin/report/report_page.dart';
import 'modules/admin/attendance/attendance_page.dart';
import 'modules/admin/assignment/assignment_page.dart';
import 'modules/admin/letter/letter_page.dart';
import 'modules/admin/profile/profile_page.dart';

import 'modules/user/dashboard/dashboard_page.dart' as user_dash;
import 'modules/user/attendance/attendance_page.dart' as user_att;
import 'modules/user/attendance/user_attendance_form_page.dart';
import 'modules/user/assignment/assignment_page.dart' as user_assign;
import 'modules/user/letters/letters_page.dart' as user_letters;
import 'modules/user/profile/profile_page.dart' as user_profile;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initializeDateFormatting('id_ID', null);
  } catch (_) {}
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BPR Absence',
      scrollBehavior: const AppScrollBehavior(),
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: NoTransitionsBuilder(),
            TargetPlatform.iOS: NoTransitionsBuilder(),
            TargetPlatform.macOS: NoTransitionsBuilder(),
            TargetPlatform.linux: NoTransitionsBuilder(),
            TargetPlatform.windows: NoTransitionsBuilder(),
            TargetPlatform.fuchsia: NoTransitionsBuilder(),
          },
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashPage(),
        '/login': (_) => const LoginPage(),
        '/forgot-password': (_) => const ForgotPassPage(),
        '/forgot-password/email': (_) => const EmailPage(),
        '/forgot-password/email/Expired-link': (_) => const LinkExpiredPage(),
        '/forgot-password/reset-password': (_) => const ResetPasswordPage(),

        '/admin/dashboard': (_) => const AdminDashboardPage(),
        '/admin/employees': (_) => const EmployeePage(),
        '/admin/report': (_) => const ReportPage(),
        '/admin/attendance': (_) => const AttendancePage(),
        '/admin/assignment': (_) => const AssignmentPage(),
        '/admin/letter': (_) => const LetterPage(),
        '/admin/profile': (_) => const ProfilePage(),

        '/user/dashboard': (_) => const user_dash.UserDashboardPage(),
        '/user/attendance': (_) => const user_att.UserAttendancePage(),
        '/user/attendance/form': (_) => const UserAttendanceFormPage(),
        '/user/assignment': (_) => const user_assign.UserAssignmentPage(),
        '/user/letter': (_) => const user_letters.UserLettersPage(),
        '/user/profile': (_) => const user_profile.UserProfilePage(),
      },
    );
  }
}
