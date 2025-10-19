// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/modules/user/profile/check_email_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ForgotPassPage extends StatefulWidget {
  const ForgotPassPage({super.key});

  @override
  State<ForgotPassPage> createState() => _ForgotPassPageState();
}

class _ForgotPassPageState extends State<ForgotPassPage> {
  final TextEditingController emailController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPasswordWithEmail() async {
    final email = emailController.text.trim();
    
    if (email.isEmpty) {
      _showSnackBar('Please enter your email address', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // Call our backend API for password reset
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        // Always navigate to check email page - whether real email was sent or demo mode
        _showSnackBar('Password reset email sent! Check your inbox.', isError: false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CheckEmailPage(email: email),
          ),
        );
      } else {
        String message = data['message'] ?? 'Failed to send reset email';
        _showSnackBar(message, isError: true);
      }
    } catch (e) {
      _showSnackBar('An error occurred. Please try again.', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPasswordWithGoogle() async {
    setState(() => _isLoading = true);
    
    try {
      // Sign out first to ensure account picker shows
      await _googleSignIn.signOut();
      
      // Sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return; // User canceled
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        _showSnackBar('Signed in successfully with Google account');
        // You can redirect to password change page or main app
        Navigator.pushReplacementNamed(context, '/login');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Failed to sign in with Google';
      if (e.code == 'account-exists-with-different-credential') {
        message = 'Account exists with different sign-in method';
      }
      _showSnackBar(message, isError: true);
    } catch (e) {
      _showSnackBar('An error occurred during Google sign-in', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.errorRed : AppColors.primaryGreen,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showDemoModeDialog(String email, String resetLink, String resetToken) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: Colors.orange),
            SizedBox(width: 8),
            Text('Demo Mode'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email service not configured. Use this reset link:'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reset Token:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SelectableText(resetToken),
                  SizedBox(height: 8),
                  Text('Reset Link:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SelectableText(resetLink, style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to check email page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CheckEmailPage(email: email),
                ),
              );
            },
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Logo
              Image.asset('assets/images/logo.png', height: 80),
              const SizedBox(height: 64),

              // Title
              const Text(
                "Forgot Password",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Subtitle
              const Text(
                "No worries! Enter your email address below, and we’ll send you a link to reset your password.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.black),
              ),
              const SizedBox(height: 24),

              // Input Email
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Email",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "Enter your email address",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),

              // Reset password button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.errorRed,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    _resetPasswordWithEmail();
                  },
                  child: const Text(
                    "Reset password",
                    style: TextStyle(fontSize: 16, color: AppColors.pureWhite),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Back to login
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // kembali ke login
                },
                child: const Text(
                  "← Back to log in",
                  style: TextStyle(color: AppColors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
