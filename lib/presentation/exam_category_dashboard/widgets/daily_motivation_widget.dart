import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DailyMotivationWidget extends StatelessWidget {
  final String quote;
  final String author;
  final int studyStreak;

  const DailyMotivationWidget({
    Key? key,
    required this.quote,
    required this.author,
    required this.studyStreak,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0.w, vertical: 2.0.h),
      padding: EdgeInsets.all(4.0.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.lightTheme.colorScheme.primary.withValues(
              alpha: (0.1 * 255).toInt(),
            ),
            AppTheme.lightTheme.colorScheme.secondary.withValues(
              alpha: (0.1 * 255).toInt(),
            ),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'format_quote',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.0.w,
              ),
              SizedBox(width: 2.0.w),
              Text(
                "Daily Motivation",
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.0.h),
          Text(
            quote,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          SizedBox(height: 1.0.h),
          Text(
            "- $author",
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2.0.h),
          Divider(
            color: AppTheme.lightTheme.dividerColor,
            thickness: 1.0,
          ),
          SizedBox(height: 1.0.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'local_fire_department',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                size: 5.0.w,
              ),
              SizedBox(width: 2.0.w),
              Text(
                "Study Streak: ",
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "$studyStreak days",
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.0.w, vertical: 1.0.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  "Keep Going!",
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
