import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckEmailPage extends StatelessWidget {
  final String? email;
  const CheckEmailPage({super.key, this.email});

  Future<void> _openGmail() async {
    // Try to open Gmail app first, fallback to web Gmail
    const gmailAppUrl = 'googlegmail://';
    const webGmailUrl = 'https://gmail.com';
    
    try {
      // Try to launch Gmail app
      if (await canLaunchUrl(Uri.parse(gmailAppUrl))) {
        await launchUrl(Uri.parse(gmailAppUrl), mode: LaunchMode.externalApplication);
      } else {
        // Fallback to web Gmail
        await launchUrl(Uri.parse(webGmailUrl), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // If all fails, try web Gmail as last resort
      try {
        await launchUrl(Uri.parse(webGmailUrl), mode: LaunchMode.externalApplication);
      } catch (e) {
        print('Error opening Gmail: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 80),
              
              // Email Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.email_outlined,
                  size: 60,
                  color: Colors.grey.shade600,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Title
              const Text(
                "Check your email",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Description
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.black54,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: "We sent a password reset link to your email\n"),
                    TextSpan(
                      text: email ?? "your-email@gmail.com",
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const TextSpan(
                      text: ". The link is valid for 24 hours after it's received. Please check your inbox!",
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Open Email Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await _openGmail();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B), // Orange color
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Open Your Email",
                    style: TextStyle(
                      color: AppColors.pureWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Resend Email Link
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.black54,
                  ),
                  children: [
                    const TextSpan(text: "Don't receive the email? "),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Password reset email resent!"),
                              backgroundColor: AppColors.primaryGreen,
                            ),
                          );
                        },
                        child: Text(
                          "Click here to resend!",
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Back to Login
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back_ios,
                      size: 16,
                      color: AppColors.black87,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "Back to log in",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}