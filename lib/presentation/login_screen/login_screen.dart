import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/app_logo_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/social_login_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final FocusNode _focusNode = FocusNode();

  // Mock credentials for testing
  final Map<String, String> _mockCredentials = {
    'admin@studybuild.com': 'admin123',
    'student@studybuild.com': 'student123',
    'test@studybuild.com': 'test123',
  };

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    // Add haptic feedback
    HapticFeedback.lightImpact();

    // Simulate authentication delay
    await Future.delayed(const Duration(seconds: 2));

    // Check mock credentials
    if (_mockCredentials.containsKey(email) &&
        _mockCredentials[email] == password) {
      // Success - navigate to dashboard
      if (mounted) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Login successful! Welcome back.'),
            backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate to exam category dashboard
        Navigator.pushReplacementNamed(context, '/exam-category-dashboard');
      }
    } else {
      // Failed authentication
      if (mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Invalid email or password. Please try again.'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
    });

    HapticFeedback.lightImpact();

    // Simulate Google Sign-In process
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Google Sign-In successful!'),
          backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pushReplacementNamed(context, '/exam-category-dashboard');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleMobileOtpLogin() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mobile OTP login feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToSignUp() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/registration-screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            // Dismiss keyboard when tapping outside
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 4.h),

                    // App Logo and Welcome Text
                    const AppLogoWidget(),

                    SizedBox(height: 6.h),

                    // Login Form
                    LoginFormWidget(
                      onLogin: _handleLogin,
                      isLoading: _isLoading,
                    ),

                    SizedBox(height: 4.h),

                    // Social Login Options
                    SocialLoginWidget(
                      onGoogleLogin: _handleGoogleLogin,
                      onMobileOtpLogin: _handleMobileOtpLogin,
                      isLoading: _isLoading,
                    ),

                    const Spacer(),

                    SizedBox(height: 4.h),

                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'New to Study Build? ',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        GestureDetector(
                          onTap: _isLoading ? null : _navigateToSignUp,
                          child: Text(
                            'Sign Up',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}