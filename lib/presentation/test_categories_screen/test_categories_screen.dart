import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/quick_stats_widget.dart';
import './widgets/test_section_widget.dart';

class TestCategoriesScreen extends StatefulWidget {
  const TestCategoriesScreen({Key? key}) : super(key: key);

  @override
  State<TestCategoriesScreen> createState() => _TestCategoriesScreenState();
}

class _TestCategoriesScreenState extends State<TestCategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';
  Map<String, bool> _expandedSections = {
    'Full Length Tests': false,
    'Subject-wise Tests': false,
    'Previous Year Papers': false,
    'Mock Series': false,
  };

  Map<String, dynamic> _currentFilters = {
    'sortBy': 'Recent',
    'difficulty': 'All',
    'duration': 'All',
    'subject': 'All',
    'status': 'All',
  };

  String _selectedExam = 'SSC CGL';

  // Mock data for test categories
  final Map<String, List<Map<String, dynamic>>> _testData = {
    'Full Length Tests': [
      {
        'id': 1,
        'name': 'SSC CGL Tier 1 Mock Test 2024 - Set 1',
        'duration': 60,
        'questions': 100,
        'difficulty': 'Medium',
        'isAttempted': true,
        'score': 78,
        'percentile': 85.6,
        'isOfflineAvailable': true,
        'isPremium': false,
        'subject': 'All',
      },
      {
        'id': 2,
        'name': 'SSC CGL Tier 1 Mock Test 2024 - Set 2',
        'duration': 60,
        'questions': 100,
        'difficulty': 'Hard',
        'isAttempted': false,
        'score': null,
        'percentile': null,
        'isOfflineAvailable': false,
        'isPremium': true,
        'subject': 'All',
      },
    ],
    'Subject-wise Tests': [
      {
        'id': 3,
        'name': 'Quantitative Aptitude - Advanced Level',
        'duration': 30,
        'questions': 25,
        'difficulty': 'Hard',
        'isAttempted': false,
        'score': null,
        'percentile': null,
        'isOfflineAvailable': true,
        'isPremium': false,
        'subject': 'Mathematics',
      },
      {
        'id': 4,
        'name': 'English Comprehension - Basic to Intermediate',
        'duration': 25,
        'questions': 20,
        'difficulty': 'Medium',
        'isAttempted': true,
        'score': 18,
        'percentile': 90.2,
        'isOfflineAvailable': false,
        'isPremium': false,
        'subject': 'English',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  Future<void> _onRefresh() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    setState(() {});
  }

  void _toggleSection(String sectionName) {
    setState(() {
      _expandedSections[sectionName] = !_expandedSections[sectionName]!;
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        currentFilters: _currentFilters,
        onFiltersApplied: (filters) {
          setState(() {
            _currentFilters = filters;
          });
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredTests(
      List<Map<String, dynamic>> tests) {
    List<Map<String, dynamic>> filteredTests = tests;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filteredTests = filteredTests.where((test) {
        return (test['name'] as String).toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Difficulty filter
    if (_currentFilters['difficulty'] != 'All') {
      filteredTests = filteredTests.where((test) {
        return test['difficulty'] == _currentFilters['difficulty'];
      }).toList();
    }

    // Subject filter
    if (_currentFilters['subject'] != 'All') {
      filteredTests = filteredTests.where((test) {
        return test['subject'] == _currentFilters['subject'];
      }).toList();
    }

    // Status filter
    if (_currentFilters['status'] != 'All') {
      switch (_currentFilters['status']) {
        case 'Attempted':
          filteredTests =
              filteredTests.where((test) => test['isAttempted'] == true).toList();
          break;
        case 'Not Attempted':
          filteredTests =
              filteredTests.where((test) => test['isAttempted'] == false).toList();
          break;
        case 'Offline Available':
          filteredTests = filteredTests
              .where((test) => test['isOfflineAvailable'] == true)
              .toList();
          break;
      }
    }

    return filteredTests;
  }

  int _getTotalTests() {
    return _testData.values.fold(0, (sum, tests) => sum + tests.length);
  }

  int _getCompletedTests() {
    return _testData.values
        .expand((tests) => tests)
        .where((test) => test['isAttempted'] == true)
        .length;
  }

  double _getAveragePerformance() {
    final attemptedTests = _testData.values
        .expand((tests) => tests)
        .where((test) => test['isAttempted'] == true && test['score'] != null)
        .toList();

    if (attemptedTests.isEmpty) return 0.0;

    final totalScore = attemptedTests.fold(0.0, (sum, test) {
      final score = test['score'] as int;
      final questions = test['questions'] as int;
      return sum + (score / questions * 100);
    });

    return totalScore / attemptedTests.length;
  }

  @override
  Widget build(BuildContext context) {
    final totalTests = _getTotalTests();
    final completedTests = _getCompletedTests();
    final averagePerformance = _getAveragePerformance();

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: totalTests == 0
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppTheme.lightTheme.colorScheme.primary,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        QuickStatsWidget(
                          totalTests: totalTests,
                          completedTests: completedTests,
                          averagePerformance: averagePerformance,
                        ),
                        _buildSearchBar(),
                      ],
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final sectionName = _testData.keys.elementAt(index);
                        final sectionTests = _testData[sectionName]!;
                        final filteredTests = _getFilteredTests(sectionTests);

                        return TestSectionWidget(
                          title: sectionName,
                          testCount: filteredTests.length,
                          completionPercentage: sectionTests.isEmpty
                              ? 0.0
                              : (sectionTests
                                      .where((t) => t['isAttempted'] == true)
                                      .length /
                                  sectionTests.length *
                                  100),
                          tests: filteredTests,
                          isExpanded: _expandedSections[sectionName] ?? false,
                          onToggle: () => _toggleSection(sectionName),
                        );
                      },
                      childCount: _testData.keys.length,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(height: 4.h),
                  ),
                ],
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: AppTheme.lightTheme.colorScheme.onSurface,
          size: 24,
        ),
      ),
      title: Text(
        '$_selectedExam Tests',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _showFilterBottomSheet,
          icon: CustomIconWidget(
            iconName: 'filter_list',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 24,
          ),
        ),
        SizedBox(width: 2.w),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search tests by name or subject...',
          prefixIcon: Padding(
            padding: EdgeInsets.all(3.w),
            child: CustomIconWidget(
              iconName: 'search',
              color:
                  AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.6),
              size: 20,
            ),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  icon: CustomIconWidget(
                    iconName: 'clear',
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withOpacity(0.6),
                    size: 20,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.lightTheme.dividerColor,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.lightTheme.colorScheme.primary,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: AppTheme.lightTheme.colorScheme.surface,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      title: 'No Tests Available',
      subtitle:
          'Tests for this category are being prepared. Check back soon for exciting practice sessions!',
      buttonText: 'Explore Other Categories',
      onButtonPressed: () {
        Navigator.pushNamed(context, '/exam-category-dashboard');
      },
    );
  }
}
