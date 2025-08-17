import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

// Placeholder classes and constants

class AppTheme {
  static const Color primaryLight = Colors.blue;
}

class AppRoutes {
  static const String login = '/login';
}

class OnboardingContent {
  final String imageUrl;
  final String title;
  final String description;

  OnboardingContent({
    required this.imageUrl,
    required this.title,
    required this.description,
  });
}

class ImageConstant {
  static const String imgIllustration1 = '';
  static const String imgIllustration2 = '';
  static const String imgIllustration3 = '';
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({required this.text, required this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
      style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
    );
  }
}

class OnboardingPageWidget extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;

  const OnboardingPageWidget({
    required this.imageUrl,
    required this.title,
    required this.description,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 30.h,
            width: 50.w,
            color: Colors.grey.shade300,
            child: Center(child: Text('Image Placeholder')),
          ),
          SizedBox(height: 3.h),
          Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 2.h),
          Text(description, style: TextStyle(fontSize: 12.sp), textAlign: TextAlign.center),
        ],
      ),
    );
  }
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
            // Placeholder for page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_numPages, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  height: 8,
                  width: _currentPage == index ? 16 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? AppTheme.primaryLight : AppTheme.primaryLight.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
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
