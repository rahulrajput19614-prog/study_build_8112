import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/onboarding_navigation_widget.dart';
import './widgets/onboarding_page_widget.dart';
import './widgets/page_indicator_widget.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({Key? key}) : super(key: key);

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoAdvanceTimer;
  bool _userInteracted = false;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "AI-Powered Doubt Solver",
      "description":
          "Get instant solutions to your exam doubts with our advanced AI chat assistant. Available 24/7 to help you understand complex concepts and solve problems step-by-step.",
      "imageUrl":
          "https://images.unsplash.com/photo-1677442136019-21780ecad995?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8YWklMjBjaGF0Ym90fGVufDB8fDB8fHww",
    },
    {
      "title": "Comprehensive Test Series",
      "description":
          "Practice with full-length mock tests, sectional tests, and previous year questions. Experience real exam conditions with our advanced test interface and timer system.",
      "imageUrl":
          "https://images.unsplash.com/photo-1434030216411-0b793f4b4173?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8ZXhhbXxlbnwwfHwwfHx8MA%3D%3D",
    },
    {
      "title": "Performance Analytics",
      "description":
          "Track your progress with detailed performance analysis, rank comparison, and personalized study recommendations. Identify your strengths and areas for improvement.",
      "imageUrl":
          "https://images.unsplash.com/photo-1551288049-bebda4e38f71?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8YW5hbHl0aWNzfGVufDB8fDB8fHww",
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoAdvance();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoAdvanceTimer?.cancel();
    super.dispose();
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_userInteracted && mounted) {
        if (_currentPage < _onboardingData.length - 1) {
          _nextPage();
        } else {
          timer.cancel();
        }
      }
    });
  }

  void _pauseAutoAdvance() {
    setState(() {
      _userInteracted = true;
    });
    _autoAdvanceTimer?.cancel();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _triggerHapticFeedback();
    }
  }

  void _skipOnboarding() {
    _pauseAutoAdvance();
    _completeOnboarding();
  }

  void _completeOnboarding() {
    // Store onboarding completion flag
    _storeOnboardingCompletion();

    // Navigate to exam category dashboard
    Navigator.pushReplacementNamed(context, '/exam-category-dashboard');
  }

  void _storeOnboardingCompletion() {
    // This would typically use SharedPreferences or similar storage
    // For now, we'll just mark it as completed in memory
    // In a real app, you would do:
    // SharedPreferences.getInstance().then((prefs) => prefs.setBool('onboarding_completed', true));
  }

  void _triggerHapticFeedback() {
    HapticFeedback.lightImpact();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _triggerHapticFeedback();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: _pauseAutoAdvance,
          onPanStart: (_) => _pauseAutoAdvance(),
          child: Column(
            children: [
              // Top bar with skip button
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Progress indicator text
                    Text(
                      '${_currentPage + 1}/${_onboardingData.length}',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // Skip button
                    if (_currentPage < _onboardingData.length - 1)
                      TextButton(
                        onPressed: _skipOnboarding,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 4.w, vertical: 1.h),
                        ),
                        child: Text(
                          'Skip',
                          style:
                              AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Page view with onboarding screens
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) {
                    final data = _onboardingData[index];
                    return OnboardingPageWidget(
                      imageUrl: data["imageUrl"] as String,
                      title: data["title"] as String,
                      description: data["description"] as String,
                    );
                  },
                ),
              ),

              // Page indicator dots
              Container(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: PageIndicatorWidget(
                  currentPage: _currentPage,
                  totalPages: _onboardingData.length,
                ),
              ),

              // Navigation buttons
              OnboardingNavigationWidget(
                currentPage: _currentPage,
                totalPages: _onboardingData.length,
                onNext: () {
                  _pauseAutoAdvance();
                  _nextPage();
                },
                onSkip: _skipOnboarding,
                onGetStarted: () {
                  _pauseAutoAdvance();
                  _completeOnboarding();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
