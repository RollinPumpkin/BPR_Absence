import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/providers/auth_provider.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));

    _slideAnim = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
    _loadCredentials();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Get route destination based on user role
  String _getRouteByRole(String role) {
    switch (role.toLowerCase()) {
      case 'super_admin':
      case 'admin':
      case 'hr':
      case 'manager':
        print('🎯 ROLE ROUTING: $role → Admin Dashboard');
        return '/admin/dashboard';
      
      case 'employee':
      case 'account_officer':
      case 'security':
      case 'office_boy':
      default:
        print('🎯 ROLE ROUTING: $role → User Dashboard');
        return '/user/dashboard';
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    print('🚀 LOGIN_ATTEMPT: Starting login process...');

    try {
      final identifier = _emailController.text.trim();
      final password = _passwordController.text;

      print('🚀 LOGIN_ATTEMPT: Calling authProvider.login...');
      
      // Use Firebase Authentication Provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        email: identifier,
        password: password,
      );

      print('🚀 LOGIN_ATTEMPT: AuthProvider.login result: $success');

      if (success && authProvider.currentUser != null) {
        print('🚀 LOGIN_ATTEMPT: Login successful, starting routing logic...');
        
        // Save credentials if remember me is checked
        await _saveCredentials();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful!'),
              backgroundColor: AppColors.primaryGreen,
            ),
          );

          // ROLE BASED ROUTING - Clean and comprehensive
          final userRole = authProvider.currentUser!.role;
          String routeDestination = _getRouteByRole(userRole);
          
          print('🎯 LOGIN SUCCESS: User ${authProvider.currentUser!.email} (${userRole}) → ${routeDestination}');
          
          // Navigate with error handling to prevent crashes
          try {
            await Future.delayed(const Duration(milliseconds: 300)); // Give time for state to update
            if (mounted) {
              Navigator.pushReplacementNamed(context, routeDestination);
              print('✅ Navigation started to: $routeDestination');
            }
          } catch (e) {
            print('❌ Navigation exception: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to navigate: ${e.toString()}'),
                  backgroundColor: AppColors.errorRed,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          }
        }
      } else {
        print('🚀 LOGIN_ATTEMPT: Login failed or no user data');
        final errorMessage = authProvider.errorMessage ?? 'Invalid email/employee ID or password';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    } catch (e) {
      print('🚀 LOGIN_ATTEMPT: Exception caught: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),

                  // Logo
                  Image.asset('assets/images/logo.png', height: 80),
                  const SizedBox(height: 64),

                  // Email / Phone / ID
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "Email / Phone Number / ID Employee",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Field tidak boleh kosong";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password tidak boleh kosong";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Remember Me & Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                          ),
                          const Text("Remember Me"),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/forgot-password');
                        },
                        child: const Text("Lupa Password?"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Footer
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "By continuing, you agree to our ",
                      style: const TextStyle(
                        color: AppColors.neutral500,
                        fontSize: 12,
                      ),
                      children: [
                        TextSpan(
                          text: "Terms of Service",
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              const url = 'https://example.com/terms';
                              if (await canLaunchUrl(Uri.parse(url))) {
                                await launchUrl(Uri.parse(url));
                              }
                            },
                        ),
                        const TextSpan(text: " and "),
                        TextSpan(
                          text: "Privacy Policy",
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              const url = 'https://example.com/privacy';
                              if (await canLaunchUrl(Uri.parse(url))) {
                                await launchUrl(Uri.parse(url));
                              }
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Load saved credentials
  Future<void> _loadCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool('remember_me') ?? false;
      if (rememberMe) {
        final email = prefs.getString('saved_email') ?? '';
        final password = prefs.getString('saved_password') ?? '';
        setState(() {
          _rememberMe = rememberMe;
          _emailController.text = email;
          _passwordController.text = password;
        });
      }
    } catch (e) {
      print('Failed to load credentials: $e');
    }
  }

  // Save credentials if remember me is checked
  Future<void> _saveCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setBool('remember_me', true);
        await prefs.setString('saved_email', _emailController.text);
        await prefs.setString('saved_password', _passwordController.text);
      } else {
        await prefs.remove('remember_me');
        await prefs.remove('saved_email');
        await prefs.remove('saved_password');
      }
    } catch (e) {
      print('Failed to save credentials: $e');
    }
  }
}