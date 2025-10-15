import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:provider/provid          print('🔥 CRITICAL DEBUG: Route destination = "$routeDestination"');
          print('🔥 CRITICAL DEBUG: Expected for admin: "/admin/dashboard"');
          print('🔥 CRITICAL DEBUG: Route matches admin? ${routeDestination == "/admin/dashboard"}');
          print('🚀 NAVIGATION: About to navigate to $routeDestination');.dart';
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
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    // Load saved credentials if remember me was checked
    _loadSavedCredentials();

    // mulai animasi
    _animController.forward();
  }

  // Load saved credentials if remember me was enabled
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('remember_me') ?? false;
    
    if (rememberMe) {
      final savedEmail = prefs.getString('saved_email') ?? '';
      final savedPassword = prefs.getString('saved_password') ?? '';
      
      setState(() {
        _rememberMe = rememberMe;
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
      });
    }
  }

  // Save or clear credentials based on remember me state
  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (_rememberMe) {
      await prefs.setString('saved_email', _emailController.text.trim());
      await prefs.setString('saved_password', _passwordController.text);
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      await prefs.setBool('remember_me', false);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
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
          
          print('🔥 CRITICAL DEBUG: Raw user data = ${authProvider.currentUser}');
          print('🔥 CRITICAL DEBUG: User Role = "$userRole"');
          print('🔥 CRITICAL DEBUG: Role type = ${userRole.runtimeType}');
          print('🔥 CRITICAL DEBUG: Role isEmpty = ${userRole.isEmpty}');
          print('🔥 CRITICAL DEBUG: Role == "admin" = ${userRole == "admin"}');
          print('🔥 CRITICAL DEBUG: Role == "super_admin" = ${userRole == "super_admin"}');
          
          // Route based on User Role (clean logic)
          String routeDestination = _getRouteByRole(userRole);
          
          print('� CRITICAL DEBUG: Route destination = $routeDestination');
          print('�🚀 NAVIGATION: About to navigate to $routeDestination');
          
          // Force show alert to see what's happening
          // REMOVED - Debug alert removed for clean routing
          
          Navigator.pushReplacementNamed(context, routeDestination);
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
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
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

                  // Remember Me + Forgot Password
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (v) async {
                          final newValue = v ?? false;
                          setState(() {
                            _rememberMe = newValue;
                          });
                          
                          // If unchecked, clear saved credentials immediately
                          if (!newValue) {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.remove('saved_email');
                            await prefs.remove('saved_password');
                            await prefs.setBool('remember_me', false);
                          }
                        },
                      ),
                      const Text("Remember Me"),
                      const Spacer(),
                      RichText(
                        text: TextSpan(
                          text: "Forgot Password?",
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushNamed(context, '/forgot-password');
                            },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Sign In Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: AppColors.pureWhite,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.pureWhite,
                                ),
                              ),
                            )
                          : const Text("SIGN IN"),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Request Account Hyperlink
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(color: AppColors.black, fontSize: 14),
                      children: [
                        const TextSpan(text: "Don’t have an account? "),
                        TextSpan(
                          text: "Request from Data Team",
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              // Open WhatsApp chat with admin
                              const adminPhone = '6285250600020';
                                final waMessage = Uri.encodeComponent(
                                  'Halo Admin, saya ingin request akun BPR Absence.\n\n'
                                  'Nama Lengkap:\n'
                                  'Email:\n'
                                  'Role: Employee, AO, Security, OB (Pilih salah satu)\n'
                                  'Departemen:\n'
                                  'Posisi:\n'
                                  'No. Tlp.:'
                                );
                                final url = 'https://wa.me/$adminPhone?text=$waMessage';
                                if (await canLaunch(url)) {
                                  await launch(url);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Could not open WhatsApp. Please contact admin manually (Pak Agus)."),
                                  ),
                                );
                              }
                            },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
