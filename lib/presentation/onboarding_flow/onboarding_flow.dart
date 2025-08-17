import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/onboarding_content.dart';
import '../../routes/app_routes.dart';
import './widgets/onboarding_page_widget.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  final int _numPages = 3;
  int _currentPage = 0;

  final List<OnboardingContent> _onboardingPages = [
    OnboardingContent(
      title: 'Your Ultimate Exam Prep Partner',
      description: 'Find mock tests, past papers, and study materials for every competitive exam.',
      image: ImageConstant.imgOnboarding1,
    ),
    OnboardingContent(
      title: 'Real-time Performance Analysis',
      description: 'Get instant feedback on your tests and track your progress with in-depth reports.',
      image: ImageConstant.imgOnboarding2,
    ),
    OnboardingContent(
      title: 'AI-Powered Doubt Solver',
      description: 'Snap a picture of your question and get instant, detailed answers from our AI assistant.',
      image: ImageConstant.imgOnboarding3,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _numPages,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return OnboardingPageWidget(
                content: _onboardingPages[index],
              );
            },
          ),
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 5.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Column(
          children: [
            SmoothPageIndicator(
              controller: _pageController,
              count: _numPages,
              effect: ExpandingDotsEffect(
                dotColor: AppTheme.primaryLight.withOpacity(0.3),
                activeDotColor: AppTheme.primaryLight,
                dotHeight: 1.h,
                dotWidth: 2.w,
                expansionFactor: 3,
                spacing: 2.w,
              ),
            ),
            SizedBox(height: 4.h),
            _currentPage == _numPages - 1
                ? ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 6.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.w),
                      ),
                    ),
                    child: Text(
                      'Get Started',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, AppRoutes.login);
                        },
                        child: Text(
                          'Skip',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: AppTheme.textSecondaryLight,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(25.w, 5.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.w),
                          ),
                        ),
                        child: Text(
                          'Next',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
