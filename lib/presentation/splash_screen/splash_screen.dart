import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _textAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  String _loadingText = 'Preparing your exam journey...';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
      ),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: Curves.easeIn,
      ),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textAnimationController, curve: Curves.easeOutCubic),
    );

    _logoAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _textAnimationController.forward();
    });
  }

  Future<void> _initializeApp() async {
    try {
      await Future.wait([
        _checkAuthenticationStatus(),
        _loadUserPreferences(),
        _fetchExamCategories(),
        _prepareCachedData(),
      ]);

      await Future.delayed(const Duration(milliseconds: 2500));

      if (mounted) _navigateToNextScreen();
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _loadingText = 'Connection timeout. Tap to retry.';
        });
      }
    }
  }

  Future<void> _checkAuthenticationStatus() async =>
      Future.delayed(const Duration(milliseconds: 500));

  Future<void> _loadUserPreferences() async =>
      Future.delayed(const Duration(milliseconds: 300));

  Future<void> _fetchExamCategories() async =>
      Future.delayed(const Duration(milliseconds: 700));

  Future<void> _prepareCachedData() async =>
      Future.delayed(const Duration(milliseconds: 400));

  void _navigateToNextScreen() {
    Navigator.pushReplacementNamed(context, '/exam-category-dashboard');
  }

  void _retryInitialization() {
    setState(() {
      _hasError = false;
      _loadingText = 'Preparing your exam journey...';
    });
    _initializeApp();
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.lightTheme.primaryColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF005C97), // deep blue
                Color(0xFF363795), // indigo
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo section
                Expanded(
                  flex: 3,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _logoAnimationController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _logoFadeAnimation,
                          child: ScaleTransition(
                            scale: _logoScaleAnimation,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // App Logo Box
                                Container(
                                  width: 25.w,
                                  height: 25.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5.w),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CustomIconWidget(
                                          iconName: 'school',
                                          color: AppTheme.lightTheme.primaryColor,
                                          size: 9.w,
                                        ),
                                        SizedBox(height: 1.h),
                                        Text(
                                          'SB',
                                          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                                            color: AppTheme.lightTheme.primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 3.h),
                                // App Name
                                Text(
                                  'Study Build',
                                  style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.sp,
                                    letterSpacing: 1,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                // Tagline
                                Text(
                                  'Master Your Government Exam',
                                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 12.sp,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Loading / Retry section
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _hasError
                          ? GestureDetector(
                              onTap: _retryInitialization,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(2.w),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CustomIconWidget(
                                      iconName: 'refresh',
                                      color: Colors.white,
                                      size: 5.w,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      'Retry',
                                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SizedBox(
                              width: 7.w,
                              height: 7.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                            ),

                      SizedBox(height: 2.h),

                      // Loading text
                      AnimatedBuilder(
                        animation: _textAnimationController,
                        builder: (context, child) {
                          return SlideTransition(
                            position: _textSlideAnimation,
                            child: FadeTransition(
                              opacity: _textFadeAnimation,
                              child: Text(
                                _loadingText,
                                textAlign: TextAlign.center,
                                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 11.sp,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
