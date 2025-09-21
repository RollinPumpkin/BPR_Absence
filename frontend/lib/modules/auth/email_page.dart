import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class EmailPage extends StatelessWidget {
  const EmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.black12,
                child: Icon(Icons.mail_outline, size: 40, color: Colors.black54),
              ),
              const SizedBox(height: 32),

              const Text(
                "Check your email",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                "We sent a password reset link to your email uremail@gmail.com. "
                "The link is valid for 24 hours after it's received. "
                "Please check your inbox!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text(
                    "Open Your Email",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              GestureDetector(
                onTap: () {
                  // Logic resend email di sini
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Resend email clicked")),
                  );
                },
                child: const Text.rich(
                  TextSpan(
                    text: "Don’t receive the email? ",
                    style: TextStyle(color: Colors.black87),
                    children: [
                      TextSpan(
                        text: "Click here to resend!",
                        style: TextStyle(
                          color: AppColors.darkBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text(
                  "← Back to log in",
                  style: TextStyle(color: Colors.black87),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
