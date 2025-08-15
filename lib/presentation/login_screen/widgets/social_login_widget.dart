import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SocialLoginWidget extends StatelessWidget {
  final Function() onGoogleLogin;
  final Function() onMobileOtpLogin;
  final bool isLoading;

  const SocialLoginWidget({
    Key? key,
    required this.onGoogleLogin,
    required this.onMobileOtpLogin,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider with text
        Row(
          children: [
            Expanded(
              child: Divider(
                color: AppTheme.lightTheme.dividerColor,
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Or continue with',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: AppTheme.lightTheme.dividerColor,
                thickness: 1,
              ),
            ),
          ],
        ),

        SizedBox(height: 3.h),

        // Social Login Buttons
        Row(
          children: [
            // Google Sign-In Button
            Expanded(
              child: SizedBox(
                height: 6.h,
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : onGoogleLogin,
                  icon: CustomImageWidget(
                    imageUrl:
                        'https://developers.google.com/identity/images/g-logo.png',
                    width: 5.w,
                    height: 5.w,
                    fit: BoxFit.contain,
                  ),
                  label: Text(
                    'Google',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppTheme.lightTheme.dividerColor,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(width: 4.w),

            // Mobile OTP Button
            Expanded(
              child: SizedBox(
                height: 6.h,
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : onMobileOtpLogin,
                  icon: CustomIconWidget(
                    iconName: 'phone_android',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 5.w,
                  ),
                  label: Text(
                    'Mobile OTP',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppTheme.lightTheme.dividerColor,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
