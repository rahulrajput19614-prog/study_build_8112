import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

// Placeholder OnboardingContent class
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

// Placeholder ImageConstant
class ImageConstant {
  static const String imgIllustration1 = '';
  static const String imgIllustration2 = '';
  static const String imgIllustration3 = '';
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
      padding: EdgeInsets.all(4.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Placeholder for image
          Container(
            height: 30.h,
            width: 50.w,
            color: Colors.grey.shade300,
            child: Center(
              child: Text('Image Placeholder', textAlign: TextAlign.center),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            title,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Text(
            description,
            style: TextStyle(fontSize: 12.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
