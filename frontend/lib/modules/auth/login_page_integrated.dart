import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../data/providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPageIntegrated extends StatefulWidget {
  const LoginPageIntegrated({super.key});

  @override
  State<LoginPageIntegrated> createState() => _LoginPageIntegratedState();
}

class _LoginPageIntegratedState extends State<LoginPageIntegrated>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _rememberMe = false;
  bool _obscurePassword = true;

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

    // Start animation
    _animController.forward();

    // Initialize authentication
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      // Clear form
      _emailController.clear();
      _passwordController.clear();
      
      // Navigate based on user role
      final user = authProvider.currentUser;
      print('🎯 ROUTING DEBUG: User object: $user');
      print('🎯 ROUTING DEBUG: User role: ${user?.role}');
      print('🎯 ROUTING DEBUG: User role type: ${user?.role.runtimeType}');
      
      if (user != null) {
        print('🎯 ROUTING DEBUG: Entering switch statement with role: "${user.role}"');
        switch (user.role) {
          case 'admin':
            print('🎯 ROUTING DEBUG: Matched admin case');
            Navigator.pushReplacementNamed(context, '/admin/dashboard');
            break;
          case 'super_admin':
            print('🎯 ROUTING DEBUG: Matched super_admin case');
            Navigator.pushReplacementNamed(context, '/admin/dashboard');
            break;
          case 'hr':
            print('🎯 ROUTING DEBUG: Matched hr case');
            Navigator.pushReplacementNamed(context, '/admin/dashboard');
            break;
          case 'manager':
            print('🎯 ROUTING DEBUG: Matched manager case');
            Navigator.pushReplacementNamed(context, '/admin/dashboard');
            break;
          default:
            print('🎯 ROUTING DEBUG: Matched default case - going to user dashboard');
            Navigator.pushReplacementNamed(context, '/user/dashboard');
        }
        print('🎯 ROUTING DEBUG: Navigation call completed');
      } else {
        print('🎯 ROUTING DEBUG: User is null!');
      }
    } else if (mounted) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50, // Changed from AppColors.background
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            // Check if already authenticated
            if (authProvider.isAuthenticated && authProvider.currentUser != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final user = authProvider.currentUser!;
                print('🎯 POSTFRAME ROUTING DEBUG: User role: "${user.role}"');
                print('🎯 POSTFRAME ROUTING DEBUG: User role type: ${user.role.runtimeType}');
                
                switch (user.role) {
                  case 'admin':
                    print('🎯 POSTFRAME ROUTING DEBUG: Matched admin case');
                    Navigator.pushReplacementNamed(context, '/admin/dashboard');
                    break;
                  case 'super_admin':
                    print('🎯 POSTFRAME ROUTING DEBUG: Matched super_admin case');
                    Navigator.pushReplacementNamed(context, '/admin/dashboard');
                    break;
                  case 'hr':
                    print('🎯 POSTFRAME ROUTING DEBUG: Matched hr case');
                    Navigator.pushReplacementNamed(context, '/admin/dashboard');
                    break;
                  case 'manager':
                    print('🎯 POSTFRAME ROUTING DEBUG: Matched manager case');
                    Navigator.pushReplacementNamed(context, '/admin/dashboard');
                    break;
                  default:
                    print('🎯 POSTFRAME ROUTING DEBUG: Matched default case - going to user dashboard');
                    Navigator.pushReplacementNamed(context, '/user/dashboard');
                }
                print('🎯 POSTFRAME ROUTING DEBUG: Navigation call completed');
              });
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      
                      // Logo and Title
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: SlideTransition(
                          position: _slideAnim,
                          child: Column(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue, // Changed from AppColors.primary
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryBlue.withOpacity(0.3), // Changed from AppColors.primary
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.business,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'BPR Absence',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.black87, // Changed from AppColors.textPrimary
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Employee Management System',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.neutral500, // Changed from AppColors.textSecondary
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Email Field
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.primaryBlue), // Changed from AppColors.primary
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Password Field
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: const Icon(Icons.lock_outlined),
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.primaryBlue), // Changed from AppColors.primary
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Remember Me and Forgot Password
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: Row(
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
                                  activeColor: AppColors.primaryBlue, // Changed from AppColors.primary
                                ),
                                const Text('Remember me'),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/forgot-password');
                              },
                              child: const Text('Forgot Password?'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Login Button
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: authProvider.isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue, // Changed from AppColors.primary
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: authProvider.isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Error Message
                      if (authProvider.errorMessage != null)
                        FadeTransition(
                          opacity: _fadeAnim,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    authProvider.errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    authProvider.clearError();
                                  },
                                  icon: const Icon(Icons.close, size: 16, color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 32),

                      // Footer
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: Column(
                          children: [
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.neutral500, // Changed from AppColors.textSecondary
                                ),
                                children: [
                                  const TextSpan(text: 'By signing in, you agree to our '),
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: TextStyle(
                                      color: AppColors.primaryBlue, // Changed from AppColors.primary
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        launchUrl(Uri.parse('https://example.com/terms'));
                                      },
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                      color: AppColors.primaryBlue, // Changed from AppColors.primary
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        launchUrl(Uri.parse('https://example.com/privacy'));
                                      },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '© 2024 BPR Absence System',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.neutral500, // Changed from AppColors.textSecondary
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}