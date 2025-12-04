import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/no_animations.dart';
import 'core/services/firestore_letter_service.dart';
import 'core/services/data_archive_service.dart';

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
import 'modules/admin/archive/data_archive_page.dart';

import 'modules/user/dashboard/dashboard_page.dart' as user_dash;
import 'modules/user/attendance/attendance_page.dart' as user_att;
import 'modules/user/attendance/attendance_form_page.dart';
// import 'modules/user/attendance/user_attendance_form_page.dart'; // Disabled - using attendance_form_page.dart instead
import 'modules/user/assignment/assignment_page.dart' as user_assign;
import 'modules/user/letters/letters_page.dart' as user_letters;
import 'modules/user/profile/user_profile_page.dart' as user_profile;
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
  
  // Catch all errors in release mode
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In release mode, just print to console
      print('Flutter Error: ${details.exception}');
      print('Stack: ${details.stack}');
    }
  };
  
  try {
    await initializeDateFormatting('id_ID', null);
  } catch (e) {
    print('Date formatting error: $e');
  }
  
  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization error: $e');
    // Continue anyway - app might work with API only
  }
  
  try {
    await FirestoreLetterService.initialize();
    print('✅ Firestore Letter Service initialized');
  } catch (e) {
    print('❌ Firestore Letter Service error: $e');
  }
  
  // Initialize API Service to load saved token
  try {
    await ApiService.initialize();
    print('✅ API Service initialized');
  } catch (e) {
    print('❌ API Service initialization error: $e');
  }
  
  // Request camera permission on app startup (for mobile platforms)
  try {
    await requestCameraPermissionOnStartup();
  } catch (e) {
    print('❌ Camera permission error: $e');
  }
  
  // Initialize and start auto-archive service
  try {
    final archiveService = DataArchiveService();
    archiveService.startAutoArchive();
    print('✅ Auto-archive service started (runs daily at midnight)');
  } catch (e) {
    print('❌ Auto-archive service error: $e');
  }
  
  runApp(MyApp()); // Remove const to allow StatefulWidget to work
}

class MyApp extends StatefulWidget {
  const MyApp({super.key}); // Remove const constructor

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Create providers once and reuse
  final AuthProvider _authProvider = AuthProvider();
  final AttendanceProvider _attendanceProvider = AttendanceProvider();
  final UserProvider _userProvider = UserProvider();

  @override
  void initState() {
    super.initState();
    // Initialize auth provider once during app startup
    // Do NOT call initialize() here - it will logout after successful login!
    // The initialize() should only be called on actual app startup, not after navigation
  }

  @override
  void dispose() {
    _authProvider.dispose();
    _attendanceProvider.dispose();
    _userProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _attendanceProvider),
        ChangeNotifierProvider.value(value: _userProvider),
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
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
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
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashPage(),
          '/login': (_) => const LoginPage(),
          '/forgot-password': (_) => const ForgotPassPage(),
          '/forgot-password/email': (_) => const EmailPage(),
          '/forgot-password/email/Expired-link': (_) => const LinkExpiredPage(),
          '/forgot-password/reset-password': (_) => const ResetPasswordPage(),
          '/reset-password': (context) {
            final uri = Uri.parse(ModalRoute.of(context)!.settings.name ?? '');
            final token = uri.queryParameters['token'];
            final email = uri.queryParameters['email'];
            return ResetPasswordPage(token: token, email: email);
          },

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
          '/admin/archive': (_) => const DataArchiveManagementPage(),

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
