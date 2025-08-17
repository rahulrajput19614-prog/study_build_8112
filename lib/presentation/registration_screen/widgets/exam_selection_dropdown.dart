import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ExamSelectionDropdown extends StatefulWidget {
  final List<String> selectedExams;
  final Function(List<String>) onExamsChanged;

  const ExamSelectionDropdown({
    Key? key,
    required this.selectedExams,
    required this.onExamsChanged,
  }) : super(key: key);

  @override
  State<ExamSelectionDropdown> createState() => _ExamSelectionDropdownState();
}

class _ExamSelectionDropdownState extends State<ExamSelectionDropdown> {
  final List<Map<String, dynamic>> examOptions = [
    {
      'id': 'upsc',
      'name': 'UPSC Civil Services',
      'description': 'Union Public Service Commission',
      'icon': 'account_balance',
    },
    {
      'id': 'ssc_cgl',
      'name': 'SSC CGL',
      'description': 'Staff Selection Commission Combined Graduate Level',
      'icon': 'work',
    },
    {
      'id': 'banking_po',
      'name': 'Banking PO',
      'description': 'Probationary Officer in Banks',
      'icon': 'account_balance_wallet',
    },
    {
      'id': 'railways',
      'name': 'Railways',
      'description': 'Indian Railways Recruitment',
      'icon': 'train',
    },
    {
      'id': 'ssc_chsl',
      'name': 'SSC CHSL',
      'description': 'Combined Higher Secondary Level',
      'icon': 'school',
    },
    {
      'id': 'banking_clerk',
      'name': 'Banking Clerk',
      'description': 'Clerical Cadre in Banks',
      'icon': 'receipt_long',
    },
    {
      'id': 'nda',
      'name': 'NDA',
      'description': 'National Defence Academy',
      'icon': 'security',
    },
    {
      'id': 'cds',
      'name': 'CDS',
      'description': 'Combined Defence Services',
      'icon': 'shield',
    },
  ];

  bool _isDropdownOpen = false;

  void _toggleExamSelection(String examId) {
    List<String> updatedExams = List.from(widget.selectedExams);

    if (updatedExams.contains(examId)) {
      updatedExams.remove(examId);
    } else {
      updatedExams.add(examId);
    }

    widget.onExamsChanged(updatedExams);
  }

  String _getDisplayText() {
    if (widget.selectedExams.isEmpty) {
      return 'Select Target Exams';
    } else if (widget.selectedExams.length == 1) {
      final exam = examOptions.firstWhere(
        (exam) => exam['id'] == widget.selectedExams.first,
        orElse: () => {'name': 'Unknown'},
      );
      return exam['name'];
    } else {
      return '${widget.selectedExams.length} exams selected';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Target Exam *',
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 1.h),
        GestureDetector(
          onTap: () {
            setState(() {
              _isDropdownOpen = !_isDropdownOpen;
            });
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isDropdownOpen
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.dividerColor,
                width: _isDropdownOpen ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _getDisplayText(),
                    style: widget.selectedExams.isEmpty
                        ? AppTheme.lightTheme.inputDecorationTheme.hintStyle
                        : AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                ),
                CustomIconWidget(
                  iconName: _isDropdownOpen
                      ? 'keyboard_arrow_up'
                      : 'keyboard_arrow_down',
                  size: 6.w,
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        if (_isDropdownOpen) ...[
          SizedBox(height: 1.h),
          Container(
            width: double.infinity,
            constraints: BoxConstraints(maxHeight: 40.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.lightTheme.dividerColor,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(vertical: 1.h),
              itemCount: examOptions.length,
              separatorBuilder: (context, index) => Divider(
                height: 0.1.h,
                color: AppTheme.lightTheme.dividerColor,
              ),
              itemBuilder: (context, index) {
                final exam = examOptions[index];
                final isSelected = widget.selectedExams.contains(exam['id']);

                return GestureDetector(
                  onTap: () => _toggleExamSelection(exam['id']),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.primaryContainer
                            .withValues(alpha: 0.3)
                        : Colors.transparent,
                    child: Row(
                      children: [
                        Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.lightTheme.colorScheme.primary
                                : AppTheme
                                    .lightTheme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: CustomIconWidget(
                              iconName: exam['icon'],
                              size: 6.w,
                              color: isSelected
                                  ? AppTheme.lightTheme.colorScheme.onPrimary
                                  : AppTheme.lightTheme.colorScheme.primary,
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exam['name'],
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? AppTheme.lightTheme.colorScheme.primary
                                      : AppTheme
                                          .lightTheme.colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                exam['description'],
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          CustomIconWidget(
                            iconName: 'check_circle',
                            size: 5.w,
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        if (widget.selectedExams.isNotEmpty) ...[
          SizedBox(height: 2.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: widget.selectedExams.map((examId) {
              final exam = examOptions.firstWhere(
                (exam) => exam['id'] == examId,
                orElse: () => {'name': 'Unknown', 'icon': 'help'},
              );

              return Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: exam['icon'],
                      size: 4.w,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      exam['name'],
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: 1.w),
                    GestureDetector(
                      onTap: () => _toggleExamSelection(examId),
                      child: CustomIconWidget(
                        iconName: 'close',
                        size: 4.w,
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
