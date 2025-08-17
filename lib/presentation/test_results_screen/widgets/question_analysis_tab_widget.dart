import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../models/test_result_model.dart';
import '../../../theme/app_theme.dart';

class QuestionAnalysisTabWidget extends StatefulWidget {
  final TestResultModel testResult;

  const QuestionAnalysisTabWidget({
    super.key,
    required this.testResult,
  });

  @override
  State<QuestionAnalysisTabWidget> createState() =>
      _QuestionAnalysisTabWidgetState();
}

class _QuestionAnalysisTabWidgetState extends State<QuestionAnalysisTabWidget> {
  String selectedFilter = 'All';
  final List<String> filterOptions = [
    'All',
    'Correct',
    'Incorrect',
    'Easy',
    'Medium',
    'Hard'
  ];
  final Set<String> bookmarkedQuestions = <String>{};

  @override
  Widget build(BuildContext context) {
    final filteredQuestions = _getFilteredQuestions();

    return Column(
      children: [
        // Filter Section
        Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Questions',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryLight,
                ),
              ),
              SizedBox(height: 1.h),
              Wrap(
                spacing: 2.w,
                runSpacing: 1.h,
                children: filterOptions.map((option) {
                  final isSelected = selectedFilter == option;
                  return FilterChip(
                    selected: isSelected,
                    label: Text(
                      option,
                      style: GoogleFonts.roboto(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? AppTheme.backgroundLight
                            : AppTheme.textSecondaryLight,
                      ),
                    ),
                    backgroundColor: AppTheme.surfaceLight,
                    selectedColor: AppTheme.primaryLight,
                    checkmarkColor: AppTheme.backgroundLight,
                    onSelected: (_) {
                      setState(() {
                        selectedFilter = option;
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        // Questions List
        Expanded(
          child: filteredQuestions.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  physics: BouncingScrollPhysics(),
                  itemCount: filteredQuestions.length,
                  itemBuilder: (context, index) {
                    final question = filteredQuestions[index];
                    return _buildQuestionCard(question, index + 1);
                  },
                ),
        ),
      ],
    );
  }

  List<QuestionResult> _getFilteredQuestions() {
    return widget.testResult.questionResults.where((question) {
      switch (selectedFilter) {
        case 'Correct':
          return question.isCorrect;
        case 'Incorrect':
          return !question.isCorrect;
        case 'Easy':
          return question.difficulty == 'Easy';
        case 'Medium':
          return question.difficulty == 'Medium';
        case 'Hard':
          return question.difficulty == 'Hard';
        default:
          return true;
      }
    }).toList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_list_off,
            size: 15.w,
            color: AppTheme.textSecondaryLight,
            semanticLabel: 'No questions found',
          ),
          SizedBox(height: 2.h),
          Text(
            'No questions found',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondaryLight,
            ),
          ),
          Text(
            'Try adjusting your filter',
            style: GoogleFonts.roboto(
              fontSize: 12.sp,
              color: AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuestionResult question, int questionNumber) {
    final isBookmarked = bookmarkedQuestions.contains(question.questionId);

    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: question.isCorrect
              ? AppTheme.secondaryLight
              : AppTheme.errorLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: question.isCorrect
                      ? AppTheme.secondaryLight.withValues(
                          alpha: (0.1 * 255).toInt())
                      : AppTheme.errorLight.withValues(
                          alpha: (0.1 * 255).toInt()),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Text(
                  'Q$questionNumber',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: question.isCorrect
                        ? AppTheme.secondaryLight
                        : AppTheme.errorLight,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              // Subject Tag
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withValues(
                      alpha: (0.1 * 255).toInt()),
                  borderRadius: BorderRadius.circular(1.w),
                ),
                child: Text(
                  question.subject,
                  style: GoogleFonts.roboto(
                    fontSize: 10.sp,
                    color: AppTheme.primaryLight,
                  ),
                ),
              ),
              const Spacer(),
              // Difficulty Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(question.difficulty).withValues(
                      alpha: (0.1 * 255).toInt()),
                  borderRadius: BorderRadius.circular(1.w),
                ),
                child: Text(
                  question.difficulty,
                  style: GoogleFonts.roboto(
                    fontSize: 10.sp,
                    color: _getDifficultyColor(question.difficulty),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              // Bookmark Button
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isBookmarked) {
                      bookmarkedQuestions.remove(question.questionId);
                    } else {
                      bookmarkedQuestions.add(question.questionId);
                    }
                  });
                },
                child: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked
                      ? AppTheme.accentLight
                      : AppTheme.textSecondaryLight,
                  size: 5.w,
                  semanticLabel: 'Bookmark question',
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Question Text
          Text(
            question.question,
            style: GoogleFonts.roboto(
              fontSize: 14.sp,
              color: AppTheme.textPrimaryLight,
              height: 1.4,
            ),
          ),
          SizedBox(height: 2.h),

          // Answer Section
          if (question.userAnswer.isNotEmpty) ...[
            _buildAnswerRow(
              'Your Answer:',
              question.userAnswer,
              question.isCorrect ? AppTheme.secondaryLight : AppTheme.errorLight,
              question.isCorrect ? Icons.check_circle : Icons.cancel,
            ),
            SizedBox(height: 1.h),
          ],
          if (!question.isCorrect) ...[
            _buildAnswerRow(
              'Correct Answer:',
              question.correctAnswer,
              AppTheme.secondaryLight,
              Icons.check_circle,
            ),
            SizedBox(height: 1.h),
          ],

          // Time Spent
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 4.w,
                color: AppTheme.textSecondaryLight,
                semanticLabel: 'Time spent',
              ),
              SizedBox(width: 1.w),
              Text(
                'Time: ${question.timeSpent}s',
                style: GoogleFonts.roboto(
                  fontSize: 12.sp,
                  color: AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),

          // Explanation Section
          if (question.explanation.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withValues(alpha: (0.05 * 255).toInt()),
                borderRadius: BorderRadius.circular(2.w),
                border: Border.all(
                  color: AppTheme.primaryLight.withValues(alpha: (0.2 * 255).toInt()),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppTheme.primaryLight,
                        size: 4.w,
                        semanticLabel: 'Explanation icon',
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Explanation',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryLight,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    question.explanation,
                    style: GoogleFonts.roboto(
                      fontSize: 12.sp,
                      color: AppTheme.textPrimaryLight,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerRow(String label, String answer, Color color, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: color,
          size: 4.w,
          semanticLabel: label,
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label ',
                  style: GoogleFonts.roboto(
                    fontSize: 12.sp,
                    color: AppTheme.textSecondaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: answer,
                  style: GoogleFonts.roboto(
                    fontSize: 12.sp,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppTheme.secondaryLight;
      case 'medium':
        return AppTheme.accentLight;
      case 'hard':
        return AppTheme.errorLight;
      default:
        return AppTheme.textSecondaryLight;
    }
  }
}
