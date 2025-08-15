import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TestSectionWidget extends StatefulWidget {
  final String title;
  final int testCount;
  final double completionPercentage;
  final List<Map<String, dynamic>> tests;
  final bool isExpanded;
  final VoidCallback onToggle;

  const TestSectionWidget({
    Key? key,
    required this.title,
    required this.testCount,
    required this.completionPercentage,
    required this.tests,
    required this.isExpanded,
    required this.onToggle,
  }) : super(key: key);

  @override
  State<TestSectionWidget> createState() => _TestSectionWidgetState();
}

class _TestSectionWidgetState extends State<TestSectionWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSectionHeader(),
          if (widget.isExpanded) _buildTestsList(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return InkWell(
      onTap: widget.onToggle,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${widget.testCount} Tests',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        '${widget.completionPercentage.toInt()}% Complete',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: widget.isExpanded
                    ? 'keyboard_arrow_up'
                    : 'keyboard_arrow_down',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestsList() {
    return Container(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Column(
        children: widget.tests.map((test) => _buildTestCard(test)).toList(),
      ),
    );
  }

  Widget _buildTestCard(Map<String, dynamic> test) {
    final isAttempted = test['isAttempted'] as bool;
    final score = test['score'] as int?;
    final percentile = test['percentile'] as double?;
    final difficulty = test['difficulty'] as String;
    final isOfflineAvailable = test['isOfflineAvailable'] as bool;
    final isPremium = test['isPremium'] as bool;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
      child: Dismissible(
        key: Key(test['id'].toString()),
        direction: DismissDirection.startToEnd,
        background: Container(
          decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: isAttempted ? 'analytics' : 'play_arrow',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(height: 0.5.h),
              Text(
                isAttempted ? 'Analysis' : 'Start',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        child: Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
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
                  Expanded(
                    child: Text(
                      test['name'] as String,
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isPremium)
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'PRO',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: Colors.amber[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  _buildInfoChip(
                    CustomIconWidget(
                      iconName: 'schedule',
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                      size: 14,
                    ),
                    '${test['duration']} min',
                  ),
                  SizedBox(width: 2.w),
                  _buildInfoChip(
                    CustomIconWidget(
                      iconName: 'quiz',
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                      size: 14,
                    ),
                    '${test['questions']} Qs',
                  ),
                  SizedBox(width: 2.w),
                  _buildDifficultyChip(difficulty),
                  const Spacer(),
                  if (isOfflineAvailable)
                    CustomIconWidget(
                      iconName: 'download_done',
                      color: AppTheme.lightTheme.colorScheme.secondary,
                      size: 16,
                    ),
                ],
              ),
              if (isAttempted) ...[
                SizedBox(height: 1.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.secondary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Score: $score/${test['questions']}',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (percentile != null)
                        Text(
                          'Percentile: ${percentile.toStringAsFixed(1)}',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(Widget icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        SizedBox(width: 1.w),
        Text(
          text,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyChip(String difficulty) {
    Color chipColor;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        chipColor = AppTheme.lightTheme.colorScheme.secondary;
        break;
      case 'medium':
        chipColor = Colors.orange;
        break;
      case 'hard':
        chipColor = AppTheme.lightTheme.colorScheme.error;
        break;
      default:
        chipColor = AppTheme.lightTheme.colorScheme.primary;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        difficulty,
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: chipColor,
          fontWeight: FontWeight.w500,
          fontSize: 10.sp,
        ),
      ),
    );
  }
}
