import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../models/test_result_model.dart';
import '../../../services/gemini_service.dart';
import '../../../theme/app_theme.dart';

class RecommendationsTabWidget extends StatefulWidget {
  final TestResultModel testResult;

  const RecommendationsTabWidget({
    super.key,
    required this.testResult,
  });

  @override
  State<RecommendationsTabWidget> createState() =>
      _RecommendationsTabWidgetState();
}

class _RecommendationsTabWidgetState extends State<RecommendationsTabWidget> {
  String? aiRecommendations;
  String? performanceInsights;
  bool isLoadingRecommendations = false;
  bool isLoadingInsights = false;

  @override
  void initState() {
    super.initState();
    try {
      _loadRecommendations();
    } catch (e) {
      geminiClient = GeminiClient(
        GeminiService().dio,
        'mock_key',
      );
    }
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      isLoadingRecommendations = true;
      isLoadingInsights = true;
    });

    try {
      final recommendations = await generateStudyRecommendations(
        apiKey: 'mock_key',
        overallScore: widget.testResult.overallScore,
        subjectScores: widget.testResult.subjectResults.map(
          (key, value) => MapEntry(key, value.score),
        ),
        weakTopics: widget.testResult.weakTopics,
        timeSpent: widget.testResult.timeSpent,
        accuracyRate: widget.testResult.accuracyRate,
      );

      final insights = 'Performance insights unavailable';
      setState(() {
        aiRecommendations = recommendations;
        performanceInsights = insights;
        isLoadingRecommendations = false;
        isLoadingInsights = false;
      });
    } catch (e) {
      setState(() {
        aiRecommendations = _generateFallbackRecommendations();
        performanceInsights = _generateFallbackInsights();
        isLoadingRecommendations = false;
        isLoadingInsights = false;
      });
    }
  }

  String _generateFallbackRecommendations() {
    final weakTopics = widget.testResult.weakTopics;
    final strongTopics = widget.testResult.strongTopics;
    return '''
📚 Study Recommendations:
1. Focus on weak areas: ${weakTopics.isNotEmpty ? weakTopics.join(', ') : 'Continue balanced practice'}
2. Strengthen your foundation in subjects scoring below 70%
3. Practice time management - aim for ${(widget.testResult.timeSpent / widget.testResult.totalQuestions).toStringAsFixed(1)} minutes per question
4. Review explanations for incorrect answers to understand concepts better
✨ Your strong subjects: ${strongTopics.isNotEmpty ? strongTopics.join(', ') : 'Keep up consistent practice across all subjects'}
    ''';
  }

  String _generateFallbackInsights() {
    final isImprovement = widget.testResult.previousAttempt != null &&
        widget.testResult.overallScore >
            widget.testResult.previousAttempt!.score;
    return '''
🎯 Performance Insights:
Your current score of ${widget.testResult.overallScore.toStringAsFixed(1)}% places you in the ${widget.testResult.percentileRank}th percentile.
${isImprovement ? 'Great improvement since your last attempt! Keep up the momentum.' : 'Focus on consistent practice to improve your performance.'}
Grade: ${widget.testResult.performanceGrade}
Next steps: ${widget.testResult.overallScore >= 85 ? 'Maintain excellence and help others' : widget.testResult.overallScore >= 70 ? 'Work on weak areas to reach excellence' : 'Build strong fundamentals through regular practice'}
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('AI Performance Insights', Icons.psychology),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryLight.withOpacity(0.1),
                  AppTheme.accentLight.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(3.w),
              border: Border.all(
                color: AppTheme.primaryLight.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: AppTheme.primaryLight,
                      size: 5.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'AI Powered by Gemini',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryLight,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                if (isLoadingInsights)
                  _buildLoadingWidget()
                else
                  Text(
                    performanceInsights ?? 'Unable to load insights',
                    style: GoogleFonts.roboto(
                      fontSize: 13.sp,
                      color: AppTheme.textPrimaryLight,
                      height: 1.4,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          _buildSectionTitle('Personalized Study Plan', Icons.school),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(3.w),
              border: Border.all(color: AppTheme.dividerLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLoadingRecommendations)
                  _buildLoadingWidget()
                else
                  Text(
                    aiRecommendations ?? 'Unable to load recommendations',
                    style: GoogleFonts.roboto(
                      fontSize: 13.sp,
                      color: AppTheme.textPrimaryLight,
                      height: 1.4,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          if (widget.testResult.weakTopics.isNotEmpty) ...[
            _buildSectionTitle('Priority Topics', Icons.priority_high),
            SizedBox(height: 2.h),
            ...widget.testResult.weakTopics.map(
              (topic) => _buildTopicCard(
                topic,
                widget.testResult.subjectResults[topic]?.score ?? 0,
                true,
              ),
            ),
            SizedBox(height: 3.h),
          ],
          if (widget.testResult.strongTopics.isNotEmpty) ...[
            _buildSectionTitle('Strong Areas', Icons.star),
            SizedBox(height: 2.h),
            ...widget.testResult.strongTopics.take(3).map(
              (topic) => _buildTopicCard(
                topic,
                widget.testResult.subjectResults[topic]?.score ?? 0,
                false,
              ),
            ),
            SizedBox(height: 3.h),
          ],
          _buildSectionTitle('Suggested Actions', Icons.assignment),
          SizedBox(height: 2.h),
          _buildActionCard(
            'Retake Test',
            'Take this test again to track improvement',
            Icons.replay,
            AppTheme.primaryLight,
            _onRetakeTest,
          ),
          _buildActionCard(
            'Practice Weak Topics',
            'Focus practice on ${widget.testResult.weakTopics.isNotEmpty ? widget.testResult.weakTopics.first : 'identified areas'}',
            Icons.fitness_center,
            AppTheme.accentLight,
            _onPracticeWeakTopics,
          ),
          _buildActionCard(
            'Study Schedule',
            'Create a personalized study plan',
            Icons.schedule,
            AppTheme.secondaryLight,
            _onCreateSchedule,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryLight,
          size: 5.w,
        ),
        SizedBox(width: 2.w),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Row(
      children: [
        SizedBox(
          width: 4.w,
          height: 4.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
          ),
        ),
        SizedBox(width: 3.w),
        Text(
          'Generating AI insights...',
          style: GoogleFonts.roboto(
            fontSize: 12.sp,
            color: AppTheme.textSecondaryLight,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildTopicCard(String topic, double score, bool isWeak) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isWeak ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: isWeak ? Colors.red.shade200 : Colors.green.shade200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            topic,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimaryLight,
            ),
          ),
          Text(
            '${score.toStringAsFixed(1)}%',
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: isWeak ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 1.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(2.w),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 6.w),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryLight,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.roboto(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onRetakeTest() {
    // TODO: Implement navigation to retake test screen
  }

  void _onPracticeWeakTopics() {
    // TODO: Implement navigation to topic-wise practice screen
  }

  void _onCreateSchedule() {
    // TODO: Implement navigation to study planner screen
  }
}
