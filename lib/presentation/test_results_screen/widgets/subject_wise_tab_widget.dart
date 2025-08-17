import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../models/test_result_model.dart';
import '../../../theme/app_theme.dart';

class SubjectWiseTabWidget extends StatelessWidget {
  final TestResultModel testResult;

  const SubjectWiseTabWidget({
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
          Text(
            'Subject Performance',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryLight,
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            height: 40.h,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(3.w),
              border: Border.all(color: AppTheme.dividerLight),
            ),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final subject =
                          testResult.subjectResults.keys.elementAt(groupIndex);
                      return BarTooltipItem(
                        '$subject\n${rod.toY.toInt()}%',
                        GoogleFonts.roboto(
                          color: AppTheme.backgroundLight,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 8.w,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: GoogleFonts.roboto(
                            fontSize: 10.sp,
                            color: AppTheme.textSecondaryLight,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 8.w,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < testResult.subjectResults.length) {
                          final subject = testResult.subjectResults.keys
                              .elementAt(value.toInt());
                          return Padding(
                            padding: EdgeInsets.only(top: 1.h),
                            child: Text(
                              subject.length > 6
                                  ? '${subject.substring(0, 6)}...'
                                  : subject,
                              style: GoogleFonts.roboto(
                                fontSize: 10.sp,
                                color: AppTheme.textSecondaryLight,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.dividerLight,
                      strokeWidth: 1,
                    );
                  },
                  drawVerticalLine: false,
                ),
                barGroups: _buildBarGroups(),
              ),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Detailed Analysis',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryLight,
            ),
          ),
          SizedBox(height: 2.h),
          ...testResult.subjectResults.entries
              .map((entry) => _buildSubjectCard(entry.key, entry.value))
              .toList(),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return testResult.subjectResults.entries.map((entry) {
      final index = testResult.subjectResults.keys.toList().indexOf(entry.key);
      final score = entry.value.score;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: score,
            color: _getSubjectColor(score),
            width: 6.w,
            borderRadius: BorderRadius.circular(1.w),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 100,
              color: AppTheme.dividerLight,
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildSubjectCard(String subject, SubjectResult result) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: AppTheme.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subject,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryLight,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _getSubjectColor(result.score).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Text(
                  '${result.score.toInt()}%',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: _getSubjectColor(result.score),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          LinearProgressIndicator(
            value: result.score / 100,
            backgroundColor: AppTheme.dividerLight,
            valueColor:
                AlwaysStoppedAnimation<Color>(_getSubjectColor(result.score)),
            minHeight: 2.w,
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Flexible(
                child: _buildStatColumn(
                  'Correct',
                  '${result.correctAnswers}/${result.totalQuestions}',
                  AppTheme.secondaryLight,
                ),
              ),
              Flexible(
                child: _buildStatColumn(
                  'Accuracy',
                  '${result.totalQuestions == 0 ? 0 : result.accuracyRate.toInt()}%',
                  AppTheme.accentLight,
                ),
              ),
              Flexible(
                child: _buildStatColumn(
                  'Time',
                  '${result.timeSpent}m',
                  AppTheme.textPrimaryLight,
                ),
              ),
              Flexible(
                child: _buildStatColumn(
                  'Level',
                  result.difficulty,
                  AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Semantics(
                label: 'Performance status: ${_getPerformanceMessage(result.score)}',
                child: Icon(
                  result.score >= 80
                      ? Icons.star
                      : result.score >= 60
                          ? Icons.thumb_up_outlined
                          : Icons.info_outline,
                  color: _getSubjectColor(result.score),
                  size: 5.w,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  _getPerformanceMessage(result.score),
                  style: GoogleFonts.roboto(
                    fontSize: 12.sp,
                    color: AppTheme.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
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

  Color _getSubjectColor(double score) {
    if (score >= 80) return AppTheme.secondaryLight;
    if (score >= 60) return AppTheme.accentLight;
    return AppTheme.errorLight;
  }

  String _getPerformanceMessage(double score) {
    if (score >= 80) return 'Excellent performance! Keep it up.';
    if (score >= 60) return 'Good work! Room for improvement.';
    return 'Needs attention. Focus on this subject.';
  }
}
