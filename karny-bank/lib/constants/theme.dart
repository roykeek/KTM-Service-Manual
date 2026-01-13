// lib/constants/theme.dart
// Design tokens and theme configuration for Karny Bank

import 'package:flutter/material.dart';

class KarnyColors {
  // Primary & Neutral
  static const Color background = Color(0xFFF8F8F8);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFFE0E0E0);
  static const Color darkGrey = Color(0xFF757575);

  // Accent Colors
  static const Color primary = Color(0xFF4DB6AC); // Soft Teal
  static const Color primaryLight = Color(0xFF80CBC4);
  static const Color primaryDark = Color(0xFF26A69A);

  // Status Colors
  static const Color success = Color(0xFF81C784); // Light Green (Deposits)
  static const Color successLight = Color(0xFFC8E6C9);
  static const Color warning = Color(0xFFFFB74D); // Soft Orange (Withdrawals)
  static const Color warningLight = Color(0xFFFFE0B2);
  static const Color error = Color(0xFFEF5350);
  static const Color errorLight = Color(0xFFEF9A9A);
  static const Color info = Color(0xFF29B6F6);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFA0A0A0);
}

class KarnySpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
}

class KarnyRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double round = 100.0;
}

class KarnyFontSize {
  static const double xs = 10.0;
  static const double sm = 12.0;
  static const double md = 14.0;
  static const double lg = 16.0;
  static const double xl = 18.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
}

class KarnyTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: KarnyColors.primary,
      scaffoldBackgroundColor: KarnyColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: KarnyColors.primary,
        foregroundColor: KarnyColors.white,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: KarnyColors.white,
        selectedItemColor: KarnyColors.primary,
        unselectedItemColor: KarnyColors.textLight,
        elevation: 8,
      ),
      cardTheme: CardTheme(
        color: KarnyColors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KarnyRadius.lg),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KarnyRadius.md),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: KarnySpacing.lg,
            vertical: KarnySpacing.md,
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: KarnyFontSize.xxxl,
          fontWeight: FontWeight.bold,
          color: KarnyColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: KarnyFontSize.xxl,
          fontWeight: FontWeight.bold,
          color: KarnyColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: KarnyFontSize.xl,
          fontWeight: FontWeight.w600,
          color: KarnyColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: KarnyFontSize.lg,
          color: KarnyColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: KarnyFontSize.md,
          color: KarnyColors.textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: KarnyFontSize.sm,
          color: KarnyColors.textSecondary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: KarnySpacing.md,
          vertical: KarnySpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KarnyRadius.md),
          borderSide: const BorderSide(color: KarnyColors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KarnyRadius.md),
          borderSide: const BorderSide(color: KarnyColors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KarnyRadius.md),
          borderSide: const BorderSide(
            color: KarnyColors.primary,
            width: 2,
          ),
        ),
      ),
    );
  }
}
