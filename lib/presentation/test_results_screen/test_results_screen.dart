import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/test_result_model.dart';
import './widgets/hero_section_widget.dart';
import './widgets/overview_tab_widget.dart';
import './widgets/question_analysis_tab_widget.dart';
import './widgets/recommendations_tab_widget.dart';
import './widgets/subject_wise_tab_widget.dart';

class TestResultsScreen extends StatefulWidget {
  const TestResultsScreen({super.key});

  @override
  State<TestResultsScreen> createState() => _TestResultsScreenState();
}

class _TestResultsScreenState extends State<TestResultsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  TestResultModel? testResult;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadTestResult();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is TestResultModel) {
      testResult = args;
    } else {
      _loadMockData();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadTestResult() {
    setState(() {
      isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  void _loadMockData() {
    testResult = TestResultModel(
      testId: 'test_001',
      testName: 'JEE Main Mock Test - Mathematics',
      overallScore: 78.5,
      percentileRank: 85,
      performanceGrade: 'Good',
      timeSpent: 180,
      totalQuestions: 90,
      correctAnswers: 71,
      incorrectAnswers: 15,
      unattempted: 4,
      accuracyRate: 82.6,
      completedAt: DateTime.now().subtract(const Duration(hours: 2)),
      subjectResults: {
        'Mathematics': SubjectResult(
          subject: 'Mathematics',
          score: 85.0,
          totalQuestions: 30,
          correctAnswers: 25,
          timeSpent: 65,
          difficulty: 'Medium',
        ),
        'Physics': SubjectResult(
          subject: 'Physics',
          score: 75.0,
          totalQuestions: 30,
          correctAnswers: 23,
          timeSpent: 58,
          difficulty: 'Hard',
        ),
        'Chemistry': SubjectResult(
          subject: 'Chemistry',
          score: 72.0,
          totalQuestions: 30,
          correctAnswers: 23,
          timeSpent: 57,
          difficulty: 'Medium',
        ),
      },
      questionResults: List.generate(
        20,
        (index) => QuestionResult(
          questionId: 'q_${index + 1}',
          question:
              'Sample question ${index + 1} - What is the derivative of x²?',
          userAnswer: index % 3 == 0 ? 'Wrong Answer' : '2x',
          correctAnswer: '2x',
          isCorrect: index % 3 != 0,
          explanation:
              'The derivative of x² with respect to x is 2x using the power rule.',
          difficulty: index % 3 == 0
              ? 'Hard'
              : index % 2 == 0
                  ? 'Medium'
                  : 'Easy',
          subject: index < 7
              ? 'Mathematics'
              : index < 14
                  ? 'Physics'
                  : 'Chemistry',
          timeSpent: 45 + (index % 3) * 15,
        ),
      ),
      previousAttempt: TestStats(
        score: 72.0,
        date: DateTime.now().subtract(const Duration(days: 7)),
        timeSpent: 175,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
              ),
              SizedBox(height: 3.h),
              Text(
                'Analyzing your performance...',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (testResult == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Test Results',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 15.w,
                color: AppTheme.errorLight,
              ),
              SizedBox(height: 2.h),
              Text(
                'No test results found',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimaryLight,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Please take a test to see results',
                style: GoogleFonts.roboto(
                  fontSize: 12.sp,
                  color: AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 75.h,
              pinned: true,
              elevation: 0,
              backgroundColor: AppTheme.backgroundLight,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: AppTheme.textPrimaryLight,
                  size: 5.w,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.share,
                    color: AppTheme.textPrimaryLight,
                    size: 5.w,
                  ),
                  onPressed: _onShareResults,
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: AppTheme.textPrimaryLight,
                    size: 5.w,
                  ),
                  onSelected: _onMenuSelected,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'download',
                      child: Row(
                        children: [
                          Icon(Icons.download, size: 4.w),
                          SizedBox(width: 2.w),
                          Text('Download PDF'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'retake',
                      child: Row(
                        children: [
                          Icon(Icons.replay, size: 4.w),
                          SizedBox(width: 2.w),
                          Text('Retake Test'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + kToolbarHeight,
                    left: 4.w,
                    right: 4.w,
                    bottom: 2.h,
                  ),
                  child: HeroSectionWidget(testResult: testResult!),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(12.h),
                child: Container(
                  color: AppTheme.backgroundLight,
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: 'Overview'),
                          Tab(text: 'Subject-wise'),
                          Tab(text: 'Questions'),
                          Tab(text: 'AI Insights'),
                        ],
                        labelStyle: GoogleFonts.roboto(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: GoogleFonts.roboto(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        indicatorSize: TabBarIndicatorSize.label,
                        isScrollable: false,
                      ),
                      SizedBox(height: 1.h),
                    ],
                  ),
                ),
              ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            OverviewTabWidget(testResult: testResult!),
            SubjectWiseTabWidget(testResult: testResult!),
            QuestionAnalysisTabWidget(testResult: testResult!),
            RecommendationsTabWidget(testResult: testResult!),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'retake',
            onPressed: _onRetakeTest,
            icon: const Icon(Icons.replay),
            label: Text(
              'Retake Test',
              style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
            ),
            backgroundColor: AppTheme.primaryLight,
          ),
          SizedBox(height: 2.h),
          FloatingActionButton(
            heroTag: 'review',
            onPressed: _onReviewAnswers,
            child: const Icon(Icons.quiz),
            backgroundColor: AppTheme.secondaryLight,
          ),
        ],
      ),
    );
  }

  void _onShareResults() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share Your Results',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryLight,
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption('Social Media', Icons.share, () {}),
                _buildShareOption('Download PDF', Icons.download, () {}),
                _buildShareOption('Copy Link', Icons.link, () {}),
              ],
            ),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(3.w),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryLight,
              size: 6.w,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 11.sp,
              color: AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  void _onMenuSelected(String value) {
    switch (value) {
      case 'download':
        _onDownloadPDF();
        break;
      case 'retake':
        _onRetakeTest();
        break;
    }
  }

  void _onDownloadPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF download started'),
        backgroundColor: AppTheme.secondaryLight,
      ),
    );
  }

  void _onRetakeTest() {
    Navigator.pushNamed(context, AppRoutes.testCategories);
  }

  void _onReviewAnswers() {
    _tabController.animateTo(2);
  }
}
