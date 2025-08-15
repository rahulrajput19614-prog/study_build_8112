import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import './widgets/bottom_tab_bar.dart';
import './widgets/daily_motivation_widget.dart';
import './widgets/exam_category_card.dart';
import './widgets/featured_section.dart';
import './widgets/header_section.dart';

class ExamCategoryDashboard extends StatefulWidget {
  const ExamCategoryDashboard({super.key});

  @override
  State<ExamCategoryDashboard> createState() => _ExamCategoryDashboardState();
}

class _ExamCategoryDashboardState extends State<ExamCategoryDashboard> {
  int _currentIndex = 0;

  // Mock data for exam categories
  final List<Map<String, dynamic>> examCategories = [
    {
      "id": 1,
      "name": "UPSC",
      "fullName": "Union Public Service Commission",
      "icon": "account_balance",
      "color": AppTheme.lightTheme.colorScheme.primary,
      "activeTests": 45,
      "completedTests": 12,
      "progressPercentage": 68,
      "hasRecentActivity": true,
    },
    {
      "id": 2,
      "name": "SSC",
      "fullName": "Staff Selection Commission",
      "icon": "work",
      "color": AppTheme.lightTheme.colorScheme.secondary,
      "activeTests": 32,
      "completedTests": 8,
      "progressPercentage": 45,
      "hasRecentActivity": false,
    },
    {
      "id": 3,
      "name": "Banking",
      "fullName": "Banking & Financial Services",
      "icon": "account_balance_wallet",
      "color": AppTheme.lightTheme.colorScheme.tertiary,
      "activeTests": 28,
      "completedTests": 15,
      "progressPercentage": 72,
      "hasRecentActivity": true,
    },
    {
      "id": 4,
      "name": "Railways",
      "fullName": "Indian Railway Recruitment",
      "icon": "train",
      "color": const Color(0xFF8E24AA),
      "activeTests": 38,
      "completedTests": 6,
      "progressPercentage": 35,
      "hasRecentActivity": false,
    },
  ];

  // Mock data for featured items
  final List<Map<String, dynamic>> featuredItems = [
    {
      "title": "UPSC Prelims 2024 Mock Test Series",
      "description": "Complete test series with detailed analysis",
      "badge": "NEW",
      "primaryColor": AppTheme.lightTheme.colorScheme.primary,
      "participants": 15420,
    },
    {
      "title": "SSC CGL Tier-1 Practice Tests",
      "description": "Latest pattern questions with solutions",
      "badge": "TRENDING",
      "primaryColor": AppTheme.lightTheme.colorScheme.secondary,
      "participants": 8750,
    },
    {
      "title": "Banking PO Preparation Kit",
      "description": "Comprehensive study material and tests",
      "badge": "POPULAR",
      "primaryColor": AppTheme.lightTheme.colorScheme.tertiary,
      "participants": 12300,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              HeaderSection(
                userName: "User",
                onNotificationTap: () {},
                onSearchTap: () {},
              ),
              const SizedBox(height: 24),

              // Daily Motivation
              DailyMotivationWidget(
                quote:
                    "Success is not final, failure is not fatal: it is the courage to continue that counts.",
                author: "Winston Churchill",
                studyStreak: 7,
              ),
              const SizedBox(height: 24),

              // Featured Section
              FeaturedSection(
                featuredItems: featuredItems,
              ),
              const SizedBox(height: 24),

              // AI Doubt Solver Quick Access
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context)
                          .primaryColor
                          .withOpacity(0.1), // FIXED HERE
                      Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.1), // FIXED HERE
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context)
                        .primaryColor
                        .withOpacity(0.2), // FIXED HERE
                    width: 1,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.aiDoubtSolver);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.psychology,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Doubt Solver',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'किसी भी subject का doubt पूछें - Math, Science, History और भी बहुत कुछ!',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Exam Categories Grid
              Text(
                'Exam Categories',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: [
                  ExamCategoryCard(
                    examData: examCategories[0],
                    onTap: () {},
                  ),
                  ExamCategoryCard(
                    examData: examCategories[1],
                    onTap: () {},
                  ),
                  ExamCategoryCard(
                    examData: examCategories[2],
                    onTap: () {},
                  ),
                  ExamCategoryCard(
                    examData: examCategories[3],
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 100), // Space for bottom navigation
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomTabBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          // Handle AI Doubt Solver navigation
          if (index == 2) {
            Navigator.pushNamed(context, AppRoutes.aiDoubtSolver);
          }
        },
      ),
    );
  }
}
