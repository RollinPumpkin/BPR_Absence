import 'package:flutter/material.dart';
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
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashPage(),
        '/login': (_) => const LoginPage(),
        '/admin-dashboard': (_) => const AdminDashboardPage(),
      },
    );
  }
}
