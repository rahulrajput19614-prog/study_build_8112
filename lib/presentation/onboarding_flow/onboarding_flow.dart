import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // Correct import

import '../../../core/app_export.dart';
import '../../../widgets/custom_button.dart';
import '../../onboarding_flow/models/onboarding_content.dart'; // Correct import path
import '../widgets/onboarding_page_widget.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({Key? key}) : super(key: key);

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  final int _numPages = 3;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

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
                  final content = _onboardingContents[index];
                  return OnboardingPageWidget(
                    imageUrl: content.imageUrl,
                    title: content.title,
                    description: content.description,
                  );
                },
              ),
            ),
            SizedBox(height: 4.h),
            SmoothPageIndicator(
              controller: _pageController,
              count: _numPages,
              effect: ExpandingDotsEffect(
                dotHeight: 1.h,
                dotWidth: 2.5.w,
                activeDotColor: AppTheme.primaryLight,
                dotColor: AppTheme.primaryLight.withValues(alpha: (0.1 * 255).toInt()), // Fixed deprecated issue
                spacing: 1.w,
              ),
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
