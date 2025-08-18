import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Ye aapki main screen hogi jisko route me use karoge
class ExamCategoryDashboard extends StatelessWidget {
  const ExamCategoryDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Exam Category Dashboard"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Yaha apka DailyMotivationWidget call hoga
            DailyMotivationWidget(
              quote: "Success is not final, failure is not fatal.",
              author: "Winston Churchill",
              studyStreak: 5,
            ),

            // Aap aur widgets bhi add kar sakte ho
            SizedBox(height: 2.h),
            Center(
              child: Text(
                "Exam Categories aa jayenge yaha...",
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ye widget already aapne banaya tha
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
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            // ✅ `withValues` को `withOpacity` से बदला गया
            AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
            // ✅ `withValues` को `withOpacity` से बदला गया
            AppTheme.lightTheme.colorScheme.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
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
                size: 6.w,
              ),
              SizedBox(width: 2.w),
              Text(
                "Daily Motivation",
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            quote,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            "- $author",
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2.h),
          Divider(
            color: AppTheme.lightTheme.dividerColor,
            thickness: 1,
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'local_fire_department',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
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
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(20),
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
