import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../models/onboarding_content.dart';

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingContent content;

  const OnboardingPageWidget({required this.content, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image placeholder
          Container(
            height: 30.h,
            width: 50.w,
            color: Colors.grey.shade300,
            child: Center(child: Text('Image Placeholder')),
          ),
          SizedBox(height: 3.h),
          Text(
            content.title,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Text(
            content.description,
            style: TextStyle(fontSize: 12.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
