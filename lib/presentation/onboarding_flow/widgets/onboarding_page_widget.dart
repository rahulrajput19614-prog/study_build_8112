import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../models/onboarding_content.dart'; // Corrected import path

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingContent content;

  const OnboardingPageWidget({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            content.image,
            height: 40.h,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 5.h),
          Text(
            content.title,
            style: GoogleFonts.inter(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Text(
            content.description,
            style: GoogleFonts.roboto(
              fontSize: 14.sp,
              color: AppTheme.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
