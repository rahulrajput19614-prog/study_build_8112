import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../models/test_result_model.dart';
import '../../../theme/app_theme.dart';

class OverviewTabWidget extends StatelessWidget {
  final TestResultModel testResult;

  const OverviewTabWidget({
    super.key,
    required this.testResult,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Performance Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Correct',
                  testResult.correctAnswers.toString(),
                  '${testResult.totalQuestions} Questions',
                  AppTheme.secondaryLight,
                  Icons.check_circle_outline,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildSummaryCard(
                  'Accuracy',
                  '${testResult.accuracyRate.toInt()}%',
                  'Overall Rate',
                  AppTheme.accentLight,
                  Icons.help_outline,
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Time Analysis
          _buildSectionTitle('Time Analysis'),
          SizedBox(height: 2.h),

          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(3.w),
              border: Border.all(color: AppTheme.dividerLight),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Time Spent',
                      style: GoogleFonts.roboto(
                        fontSize: 14.sp,
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                    Text(
                      '${testResult.timeSpent} minutes',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Avg. Time per Question',
                      style: GoogleFonts.roboto(
                        fontSize: 14.sp,
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                    Text(
                      '${(testResult.timeSpent / testResult.totalQuestions).toStringAsFixed(1)}m',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Comparison with Previous Attempt
          if (testResult.previousAttempt != null) ...[
            _buildSectionTitle('Performance Comparison'),
            SizedBox(height: 2.h),
            _buildComparisonCard(),
            SizedBox(height: 3.h),
          ],

          // Question Breakdown
          _buildSectionTitle('Question Breakdown'),
          SizedBox(height: 2.h),

          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(3.w),
              border: Border.all(color: AppTheme.dividerLight),
            ),
            child: Column(
              children: [
                _buildBreakdownRow(
                  'Correct',
                  testResult.correctAnswers,
                  testResult.totalQuestions,
                  AppTheme.secondaryLight,
                ),
                SizedBox(height: 2.h),
                _buildBreakdownRow(
                  'Incorrect',
                  testResult.incorrectAnswers,
                  testResult.totalQuestions,
                  AppTheme.errorLight,
                ),
                SizedBox(height: 2.h),
                _buildBreakdownRow(
                  'Unattempted',
                  testResult.unattempted,
                  testResult.totalQuestions,
                  AppTheme.textSecondaryLight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, String subtitle, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: AppTheme.dividerLight),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 6.w,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimaryLight,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.roboto(
              fontSize: 10.sp,
              color: AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimaryLight,
      ),
    );
  }

  Widget _buildComparisonCard() {
    final improvement =
        testResult.overallScore - testResult.previousAttempt!.score;
    final isImprovement = improvement > 0;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: AppTheme.dividerLight),
      ),
      child: Row(
        children: [
          Icon(
            isImprovement ? Icons.trending_up : Icons.trending_down,
            color:
                isImprovement ? AppTheme.secondaryLight : AppTheme.errorLight,
            size: 6.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isImprovement ? 'Great Improvement!' : 'Keep Practicing!',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                Text(
                  '${improvement.abs().toStringAsFixed(1)}% ${isImprovement ? 'better' : 'lower'} than last attempt',
                  style: GoogleFonts.roboto(
                    fontSize: 12.sp,
                    color: AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${improvement > 0 ? '+' : ''}${improvement.toStringAsFixed(1)}%',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color:
                  isImprovement ? AppTheme.secondaryLight : AppTheme.errorLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total) * 100 : 0.0;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 14.sp,
              color: AppTheme.textSecondaryLight,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: AppTheme.dividerLight,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 1.5.w,
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          flex: 2,
          child: Text(
            '$count (${percentage.toInt()}%)',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
