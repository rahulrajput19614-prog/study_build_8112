import 'package:flutter/material.dart';

class AppTheme {
  // Light Colors
  static const Color primaryLight = Color(0xFF1976D2);
  static const Color secondaryLight = Color(0xFF42A5F5);
  static const Color accentLight = Color(0xFFFFC107);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color dividerLight = Color(0xFFBDBDBD);
  static const Color errorLight = Color(0xFFD32F2F);

  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);

  // Dark Colors
  static const Color primaryDark = Color(0xFF90CAF9);
  static const Color secondaryDark = Color(0xFF64B5F6);
  static const Color accentDark = Color(0xFFFFD54F);
  static const Color backgroundDark = Color(0xFF303030);
  static const Color surfaceDark = Color(0xFF424242);
  static const Color dividerDark = Color(0xFF616161);
  static const Color errorDark = Color(0xFFEF5350);

  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  // ✅ यहाँ से अतिरिक्त 'const' हटाया गया है
  static const Color textSecondaryDark = Color(0xFFB0BEC5);

  // Light theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryLight,
    colorScheme: ColorScheme.fromSeed(seedColor: primaryLight, brightness: Brightness.light),
    scaffoldBackgroundColor: backgroundLight,
    dividerColor: dividerLight,
    // ✅ Class का नाम सही किया गया है
    tabBarTheme: const TabBarTheme(
      labelColor: primaryLight,
      unselectedLabelColor: textSecondaryLight,
    ),
    // ✅ Class का नाम सही किया गया है
    dialogTheme: const DialogTheme(
      backgroundColor: surfaceLight,
    ),
  );

  // Dark theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryDark,
    colorScheme: ColorScheme.fromSeed(seedColor: primaryDark, brightness: Brightness.dark),
    scaffoldBackgroundColor: backgroundDark,
    dividerColor: dividerDark,
    // ✅ Class का नाम सही किया गया है
    tabBarTheme: const TabBarTheme(
      labelColor: primaryDark,
      unselectedLabelColor: textSecondaryDark,
    ),
    // ✅ Class का नाम सही किया गया है
    dialogTheme: const DialogTheme(
      backgroundColor: surfaceDark,
    ),
  );

  /// ✅ withValues को withOpacity से बदला गया है
  static Color withOpacityFix(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}
