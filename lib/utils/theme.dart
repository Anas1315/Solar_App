import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors - Teal/Cyan palette
  static const Color primary = Color(0xFF00BFA5);
  static const Color primaryDark = Color(0xFF00897B);
  static const Color primaryLight = Color(0xFF64FFDA);
  static const Color secondary = Color(0xFF26C6DA);
  static const Color accent = Color(0xFFFF9800);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF29B6F6);

  // Background Colors
  static const Color darkBg = Color(0xFF0F0F1A);
  static const Color darkerBg = Color(0xFF0A0A12);
  static const Color cardDark = Color(0xFF1E1E2E);
  static const Color cardLight = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textLight = Color(0xFF9E9E9E);

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primary,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      error: error,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F7FA),
    cardColor: cardLight,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent, // Update to transparent
      foregroundColor: textDark,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primary,
      unselectedItemColor: Color(0xFFBDBDBD),
      type: BottomNavigationBarType.fixed,
      elevation: 12,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primary,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      error: error,
    ),
    scaffoldBackgroundColor: darkBg,
    cardColor: cardDark,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: textPrimary,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1A1A2E),
      selectedItemColor: primary,
      unselectedItemColor: Color(0xFF616161),
      type: BottomNavigationBarType.fixed,
      elevation: 12,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
