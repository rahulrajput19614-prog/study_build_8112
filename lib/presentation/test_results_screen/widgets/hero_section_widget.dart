import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../models/test_result_model.dart';
import '../../../theme/app_theme.dart';

class HeroSectionWidget extends StatelessWidget {
  final TestResultModel testResult;

  const HeroSectionWidget({
    super.key,
    required this.testResult,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryLight.withValues(alpha: 0.1),
            AppTheme.secondaryLight.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(3.w),
      ),
      child: Column(
        children: [
          Text(
            testResult.testName,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),

          // Circular Progress Indicator with Score (Animated)
          SizedBox(
            width: 40.w,
            height: 40.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: testResult.overallScore),
                  duration: const Duration(seconds: 1),
                  builder: (context, value, _) {
                    return PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: value,
                            color: _getPerformanceColor(value),
                            title: '',
                            radius: 8.w,
                          ),
                          PieChartSectionData(
                            value: 100 - value,
                            color: AppTheme.dividerLight,
                            title: '',
                            radius: 8.w,
                          ),
                        ],
                        sectionsSpace: 0,
                        centerSpaceRadius: 14.w,
                        startDegreeOffset: -90,
                      ),
                    );
                  },
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${testResult.overallScore.toInt()}%',
                      style: GoogleFonts.inter(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: _getPerformanceColor(testResult.overallScore),
                      ),
                    ),
                    Text(
                      'Score',
                      style: GoogleFonts.roboto(
                        fontSize: 12.sp,
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Performance Grade and Percentile
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                'Grade',
                testResult.performanceGrade,
                _getPerformanceColor(testResult.overallScore),
              ),
              Container(
                height: 6.h,
                width: 1,
                color: AppTheme.dividerLight,
              ),
              _buildStatItem(
                'Percentile',
                _ordinalSuffix(testResult.percentileRank),
                AppTheme.accentLight,
              ),
              Container(
                height: 6.h,
                width: 1,
                color: AppTheme.dividerLight,
              ),
              _buildStatItem(
                'Time',
                '${testResult.timeSpent}m',
                AppTheme.textPrimaryLight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 11.sp,
            color: AppTheme.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Color _getPerformanceColor(double score) {
    if (score >= 85) return AppTheme.secondaryLight;
    if (score >= 70) return AppTheme.accentLight;
    return AppTheme.errorLight;
  }

  String _ordinalSuffix(int number) {
    if (number >= 11 && number <= 13) return '${number}th';
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }
}
