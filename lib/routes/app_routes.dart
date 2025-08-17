import 'package:flutter/material.dart';

// Screens
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/test_categories_screen/test_categories_screen.dart';
import '../presentation/exam_category_dashboard/exam_category_dashboard.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/registration_screen/registration_screen.dart';
import '../presentation/ai_doubt_solver/ai_doubt_solver_screen.dart';
import '../presentation/test_results_screen/test_results_screen.dart';
import '../presentation/study_reels_screen.dart';
import '../presentation/profile_screen.dart';
import '../presentation/home_screen.dart';

/// Centralized route management
class AppRoutes {
  // 🔹 Route names (use constants for easy navigation)
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String testCategories = '/test-categories-screen';
  static const String examCategoryDashboard = '/exam-category-dashboard';
  static const String login = '/login-screen';
  static const String onboardingFlow = '/onboarding-flow';
  static const String registration = '/registration-screen';
  static const String aiDoubtSolver = '/ai-doubt-solver';
  static const String testResults = '/test-results-screen';
  static const String studyReels = '/study-reels-screen';
  static const String profile = '/profile-screen';
  static const String home = '/home-screen';

  /// 🔹 All route mappings
  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    testCategories: (context) => const TestCategoriesScreen(),
    examCategoryDashboard: (context) => const ExamCategoryDashboard(),
    login: (context) => const LoginScreen(),
    onboardingFlow: (context) => const OnboardingFlow(),
    registration: (context) => const RegistrationScreen(),
    aiDoubtSolver: (context) => const AiDoubtSolverScreen(),
    testResults: (context) => const TestResultsScreen(),
    studyReels: (context) => const StudyReelsScreen(),
    profile: (context) => const ProfileScreen(),
    home: (context) => const HomeScreen(),
  };
}
