import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/exam_selection_dropdown.dart';
import './widgets/profile_photo_section.dart';
import './widgets/registration_form.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  bool _isLoading = false;
  List<String> _selectedExams = [];
  XFile? _selectedPhoto;

  // Mock user data for demonstration
  final List<Map<String, dynamic>> existingUsers = [
    {
      "email": "john.doe@example.com",
      "mobile": "9876543210",
    },
    {
      "email": "admin@studybuild.com",
      "mobile": "9123456789",
    },
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  void _onExamsChanged(List<String> exams) {
    setState(() {
      _selectedExams = exams;
    });
  }

  void _onPhotoSelected(XFile? photo) {
    setState(() {
      _selectedPhoto = photo;
    });
  }

  bool _isFormValid() {
    return _formKey.currentState?.validate() == true &&
        _selectedExams.isNotEmpty &&
        _acceptTerms;
  }

  Future<void> _handleRegistration() async {
    if (!_isFormValid()) {
      if (_selectedExams.isEmpty) {
        Fluttertoast.showToast(
          msg: "Please select at least one target exam",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
          textColor: Colors.white,
        );
      }
      if (!_acceptTerms) {
        Fluttertoast.showToast(
          msg: "Please accept the terms and privacy policy",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
          textColor: Colors.white,
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call delay
      await Future.delayed(Duration(seconds: 2));

      // Check for duplicate email
      bool emailExists = existingUsers.any((user) =>
          user['email'].toLowerCase() == _emailController.text.toLowerCase());

      if (emailExists) {
        throw Exception('An account with this email already exists');
      }

      // Check for duplicate mobile
      bool mobileExists =
          existingUsers.any((user) => user['mobile'] == _mobileController.text);

      if (mobileExists) {
        throw Exception('An account with this mobile number already exists');
      }

      // Simulate successful registration
      Fluttertoast.showToast(
        msg: "Registration successful! Please verify your email.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
        textColor: Colors.white,
      );

      // Navigate to onboarding flow
      Navigator.pushReplacementNamed(context, '/onboarding-flow');
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString().replaceAll('Exception: ', ''),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate Google Sign-In delay
      await Future.delayed(Duration(seconds: 1));

      Fluttertoast.showToast(
        msg: "Google Sign-In successful!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
        textColor: Colors.white,
      );

      Navigator.pushReplacementNamed(context, '/onboarding-flow');
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Google Sign-In failed. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleOTPVerification() async {
    if (_mobileController.text.isEmpty || _mobileController.text.length != 10) {
      Fluttertoast.showToast(
        msg: "Please enter a valid mobile number first",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate OTP sending delay
      await Future.delayed(Duration(seconds: 1));

      Fluttertoast.showToast(
        msg: "OTP sent to +91${_mobileController.text}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
        textColor: Colors.white,
      );

      // In a real app, this would navigate to OTP verification screen
      Navigator.pushReplacementNamed(context, '/onboarding-flow');
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to send OTP. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _openTermsAndPrivacy(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          type == 'terms' ? 'Terms of Service' : 'Privacy Policy',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        content: SingleChildScrollView(
          child: Text(
            type == 'terms'
                ? 'By using StudyBuild, you agree to our terms of service. This includes responsible use of our platform, respect for intellectual property, and compliance with applicable laws. Users must be at least 13 years old to create an account.'
                : 'We collect and use your personal information to provide better exam preparation services. Your data is encrypted and never shared with third parties without your consent. We use cookies to improve your experience and track progress.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            size: 6.w,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        title: Text(
          'Create Account',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Center(
                child: Column(
                  children: [
                    Text(
                      'Join StudyBuild Family',
                      style:
                          AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Start your journey to crack government exams',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),

              // Profile Photo Section
              Center(
                child: ProfilePhotoSection(
                  onPhotoSelected: _onPhotoSelected,
                  selectedPhoto: _selectedPhoto,
                ),
              ),
              SizedBox(height: 4.h),

              // Registration Form
              RegistrationForm(
                formKey: _formKey,
                fullNameController: _fullNameController,
                emailController: _emailController,
                mobileController: _mobileController,
                passwordController: _passwordController,
                confirmPasswordController: _confirmPasswordController,
                isPasswordVisible: _isPasswordVisible,
                isConfirmPasswordVisible: _isConfirmPasswordVisible,
                togglePasswordVisibility: _togglePasswordVisibility,
                toggleConfirmPasswordVisibility:
                    _toggleConfirmPasswordVisibility,
              ),
              SizedBox(height: 3.h),

              // Exam Selection
              ExamSelectionDropdown(
                selectedExams: _selectedExams,
                onExamsChanged: _onExamsChanged,
              ),
              SizedBox(height: 4.h),

              // Terms and Privacy Policy
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _acceptTerms = !_acceptTerms;
                      });
                    },
                    child: Container(
                      width: 5.w,
                      height: 5.w,
                      decoration: BoxDecoration(
                        color: _acceptTerms
                            ? AppTheme.lightTheme.colorScheme.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: _acceptTerms
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.dividerColor,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: _acceptTerms
                          ? CustomIconWidget(
                              iconName: 'check',
                              size: 3.w,
                              color: AppTheme.lightTheme.colorScheme.onPrimary,
                            )
                          : null,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                        children: [
                          TextSpan(text: 'I agree to the '),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => _openTermsAndPrivacy('terms'),
                              child: Text(
                                'Terms of Service',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          TextSpan(text: ' and '),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => _openTermsAndPrivacy('privacy'),
                              child: Text(
                                'Privacy Policy',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),

              // Create Account Button
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFormValid()
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.dividerColor,
                    foregroundColor: _isFormValid()
                        ? AppTheme.lightTheme.colorScheme.onPrimary
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 5.w,
                          height: 5.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                          ),
                        )
                      : Text(
                          'Create Account',
                          style: AppTheme.lightTheme.textTheme.labelLarge
                              ?.copyWith(
                            color: _isFormValid()
                                ? AppTheme.lightTheme.colorScheme.onPrimary
                                : AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 3.h),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Text(
                      'OR',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              SizedBox(height: 3.h),

              // Alternative Registration Methods
              Column(
                children: [
                  // Google Sign-In
                  SizedBox(
                    width: double.infinity,
                    height: 6.h,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _handleGoogleSignIn,
                      icon: CustomIconWidget(
                        iconName: 'g_translate',
                        size: 5.w,
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                      label: Text('Continue with Google'),
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Mobile OTP
                  SizedBox(
                    width: double.infinity,
                    height: 6.h,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _handleOTPVerification,
                      icon: CustomIconWidget(
                        iconName: 'sms',
                        size: 5.w,
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                      label: Text('Continue with OTP'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),

              // Login Link
              Center(
                child: RichText(
                  text: TextSpan(
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                    children: [
                      TextSpan(text: 'Already have an account? '),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(
                              context, '/login-screen'),
                          child: Text(
                            'Sign In',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}