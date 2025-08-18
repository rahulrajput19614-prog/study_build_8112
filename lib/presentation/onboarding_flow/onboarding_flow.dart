import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../constants/image_constant.dart';
import '../widgets/custom_button.dart';
import 'models/onboarding_content.dart';
import 'widgets/onboarding_page_widget.dart';

// Placeholder theme and routes
class AppTheme {
  static const Color primaryLight = Colors.blue;
}

class AppRoutes {
  static const String login = '/login';
}

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({Key? key}) : super(key: key);

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  final int _numPages = 3;
  int _currentPage = 0;

  final List<OnboardingContent> _onboardingContents = [
    OnboardingContent(
      imageUrl: ImageConstant.imgIllustration1,
      title: 'Welcome to Study Build',
      description:
          'Your personalized study companion to ace your exams with confidence.',
    ),
    OnboardingContent(
      imageUrl: ImageConstant.imgIllustration2,
      title: 'Smart Learning Paths',
      description:
          'Our AI-powered engine crafts a custom study plan based on your strengths and weaknesses.',
    ),
    OnboardingContent(
      imageUrl: ImageConstant.imgIllustration3,
      title: 'Track Your Progress',
      description:
          'Monitor your performance, get real-time insights, and achieve your study goals.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _numPages,
                itemBuilder: (context, index) {
                  return OnboardingPageWidget(
                    content: _onboardingContents[index],
                  );
                },
              ),
            ),
            SizedBox(height: 4.h),
            // Simple page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_numPages, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 8,
                  width: _currentPage == index ? 16 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppTheme.primaryLight
                        // ✅ FIX: replaced .withValues with .withOpacity
                        : AppTheme.primaryLight.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                );
              }),
            ),
            SizedBox(height: 4.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: CustomButton(
                text: _currentPage == _numPages - 1 ? 'Get Started' : 'Next',
                onPressed: () {
                  if (_currentPage == _numPages - 1) {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeIn,
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 6.h),
          ],
        ),
      ),
    );
  }
}
