import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    tabBarTheme: const TabBarThemeData(
      labelColor: Colors.blue,
      unselectedLabelColor: Colors.grey,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.blue),
        foregroundColor: WidgetStateProperty.all(Colors.white),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
    tabBarTheme: const TabBarThemeData(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.grey,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.blue),
        foregroundColor: WidgetStateProperty.all(Colors.white),
      ),
    ),
  );

  /// Example utility method for new `.withValues()` replacement
  static Color withOpacityFix(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  /// Example utility for new color channel access
  static int extractAlpha(Color color) => (color.a * 255).round() & 0xff;
  static int extractRed(Color color) => (color.r * 255).round() & 0xff;
  static int extractGreen(Color color) => (color.g * 255).round() & 0xff;
  static int extractBlue(Color color) => (color.b * 255).round() & 0xff;
}
