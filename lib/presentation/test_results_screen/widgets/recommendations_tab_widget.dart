import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../models/test_result_model.dart';
// import '../../../services/gemini_service.dart'; // Gemini ka code missing hai
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
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      isLoadingRecommendations = true;
      isLoadingInsights = true;
    });

    try {
      final recommendations = _generateFallbackRecommendations();
      final insights = _generateFallbackInsights();

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
                  AppTheme.primaryLight.withAlpha((0.1 * 255).round()),
                  AppTheme.accentLight.withAlpha((0.05 * 255).round()),
                ],
              ),
              borderRadius: BorderRadius.circular(3.w.toDouble()),
              border: Border.all(
                color: AppTheme.primaryLight.withAlpha((0.3 * 255).round()),
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
                      size: 5.w.toDouble(),
                    ),
                    SizedBox(width: 2.w.toDouble()),
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
                SizedBox(height: 2.h.toDouble()),
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
          SizedBox(height: 3.h.toDouble()),
          _buildSectionTitle('Personalized Study Plan', Icons.school),
          SizedBox(height: 2.h.toDouble()),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w.toDouble()),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(3.w.toDouble()),
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
          SizedBox(height: 3.h.toDouble()),
          if (widget.testResult.weakTopics.isNotEmpty) ...[
            _buildSectionTitle('Priority Topics', Icons.priority_high),
            SizedBox(height: 2.h.toDouble()),
            ...widget.testResult.weakTopics.map(
              (topic) => _buildTopicCard(
                topic,
                widget.testResult.subjectResults[topic]?.score ?? 0,
                true,
              ),
            ),
            SizedBox(height: 3.h.toDouble()),
          ],
          if (widget.testResult.strongTopics.isNotEmpty) ...[
            _buildSectionTitle('Strong Areas', Icons.star),
            SizedBox(height: 2.h.toDouble()),
            ...widget.testResult.strongTopics.take(3).map(
              (topic) => _buildTopicCard(
                topic,
                widget.testResult.subjectResults[topic]?.score ?? 0,
                false,
              ),
            ),
            SizedBox(height: 3.h.toDouble()),
          ],
          _buildSectionTitle('Suggested Actions', Icons.assignment),
          SizedBox(height: 2.h.toDouble()),
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
          size: 5.w.toDouble(),
        ),
        SizedBox(width: 2.w.toDouble()),
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
          width: 4.w.toDouble(),
          height: 4.w.toDouble(),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
          ),
        ),
        SizedBox(width: 3.w.toDouble()),
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
      margin: EdgeInsets.symmetric(vertical: 1.h.toDouble()),
      padding: EdgeInsets.all(3.w.toDouble()),
      decoration: BoxDecoration(
        color: isWeak ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(2.w.toDouble()),
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
      String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 1.h.toDouble()),
        padding: EdgeInsets.all(3.w.toDouble()),
        decoration: BoxDecoration(
          color: color.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(2.w.toDouble()),
          border: Border.all(color: color.withAlpha((0.3 * 255).round())),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 6.w.toDouble()),
            SizedBox(width: 3.w.toDouble()),
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
                  SizedBox(height: 0.5.h.toDouble()),
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

  void _onRetakeTest() {}
  void _onPracticeWeakTopics() {}
  void _onCreateSchedule() {}
}
