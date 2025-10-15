import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/no_animations.dart';
import 'core/services/firestore_letter_service.dart';

import 'data/providers/auth_provider.dart';
import 'data/providers/attendance_provider.dart';
import 'data/providers/user_provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

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
import 'modules/user/attendance/attendance_form_page.dart';
// import 'modules/user/attendance/user_attendance_form_page.dart'; // Disabled - using attendance_form_page.dart instead
import 'modules/user/assignment/assignment_page.dart' as user_assign;
import 'modules/user/letters/letters_page.dart' as user_letters;
import 'modules/user/profile/profile_page.dart' as user_profile;
import 'data/services/api_service.dart';
import 'test_employee_fetch_page.dart';
import 'test/user_fetch_unit_test.dart';
import 'modules/admin/employee/employee_sync_page.dart';

class _CustomNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    print('🧭 NAVIGATION PUSH: ${route.settings.name}');
    print('🧭 NAVIGATION STACK TRACE: ${StackTrace.current}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    print('🧭 NAVIGATION REPLACE: ${oldRoute?.settings.name} → ${newRoute?.settings.name}');
    print('🧭 NAVIGATION STACK TRACE: ${StackTrace.current}');
  }
}

Future<void> requestCameraPermissionOnStartup() async {
  if (!kIsWeb) {
    try {
      final permission = await Permission.camera.status;
      print('📷 App Startup - Camera permission status: $permission');
      
      if (permission.isDenied || permission.isLimited) {
        print('📷 App Startup - Requesting camera permission...');
        final result = await Permission.camera.request();
        print('📷 App Startup - Camera permission result: $result');
        
        if (result.isGranted) {
          print('📷 App Startup - Camera permission granted successfully');
        } else if (result.isPermanentlyDenied) {
          print('📷 App Startup - Camera permission permanently denied');
        } else {
          print('📷 App Startup - Camera permission denied');
        }
      } else if (permission.isGranted) {
        print('📷 App Startup - Camera permission already granted');
      }
    } catch (e) {
      print('📷 App Startup - Error checking camera permission: $e');
    }
  } else {
    print('📷 App Startup - Web platform, camera permission handled by browser');
  }
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initializeDateFormatting('id_ID', null);
  } catch (_) {}
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirestoreLetterService.initialize();
  
  // Initialize API Service to load saved token
  await ApiService.initialize();
  
  // Request camera permission on app startup (for mobile platforms)
  await requestCameraPermissionOnStartup();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final authProvider = AuthProvider();
            authProvider.initialize(); // Initialize auth provider
            return authProvider;
          }
        ),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'BPR Absence',
        scrollBehavior: const AppScrollBehavior(),
        navigatorObservers: [
          _CustomNavigatorObserver(),
        ],
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
        '/admin/employees/test': (_) => const TestEmployeeFetchPage(),
        '/admin/employees/unit-test': (_) => const UserFetchUnitTest(),
        '/admin/employees/sync': (_) => const EmployeeSyncPage(),
        '/admin/report': (_) => const ReportPage(),
        '/admin/attendance': (_) => const AttendancePage(),
        '/admin/assignment': (_) => const AssignmentPage(),
        '/admin/letter': (_) => const LetterPage(),
        '/admin/profile': (_) => const ProfilePage(),

        '/user/dashboard': (_) => const user_dash.UserDashboardPage(),
        '/user/attendance': (_) => const user_att.UserAttendancePage(),
        '/user/attendance/form': (_) => const AttendanceFormPage(type: 'Clock In'),
        '/user/assignment': (_) => const user_assign.UserAssignmentPage(),
        '/user/letter': (_) => const user_letters.UserLettersPage(),
        '/user/profile': (_) => const user_profile.UserProfilePage(),
      },
      ),
    );
  }
}
