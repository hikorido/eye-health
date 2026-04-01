import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFF0E9D8);
  static const cardSurface = Color(0xFFFAF7EE);
  static const topBar = Color(0xFFB5CDE0);
  static const accent = Color(0xFF4A8FD4);

  static const darkBackground = Color(0xFF1A1F2E);
  static const darkSurface = Color(0xFF252B3B);
  static const darkTopBar = Color(0xFF1E2A3A);
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.light(
        primary: AppColors.accent,
        surface: AppColors.cardSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.topBar,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: ColorScheme.dark(
        primary: AppColors.accent,
        surface: AppColors.darkSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkTopBar,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}
