import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class SuccessResetPage extends StatelessWidget {
  const SuccessResetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 120),

              /// Circle Icon Placeholder
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.black12,
              ),
              const SizedBox(height: 40),

              /// Success Text
              const Text(
                "Your password has been\nsuccessfully reset",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              const Text(
                "You can log in with your new password. If you encounter any issues, please contact support !",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 40),

              /// Login Now Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Navigasi ke halaman login
                  },
                  child: const Text(
                    "Login Now",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              /// Back to login
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back, size: 16, color: Colors.black),
                label: const Text(
                  "Back to log in",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Spacer(),

              /// Footer text
              const Text(
                "If you encounter any issues, please contact support!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
