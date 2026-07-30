import 'package:flutter/material.dart';

class AppColors {
  static const Color brandPrimary = Color(0xFF7658FE);
  static const Color brand50 = Color(0xFFF1EEFF);
  static const Color brand100 = Color(0xFFE2DBFF);
  static const Color brand200 = Color(0xFFC7B9FF);
  static const Color brand300 = Color(0xFFAC97FF);
  static const Color brand400 = Color(0xFF9175FF);
  static const Color brand500 = Color(0xFF7658FE);
  static const Color brand600 = Color(0xFF5A37FB);
  static const Color brand700 = Color(0xFF4319F4);
  static const Color brand800 = Color(0xFF320ED2);
  static const Color brand900 = Color(0xFF260AA3);
  static const Color brandGlow = Color(0x597658FE);

  static const Color darkBase = Color(0xFF0B0814);
  static const Color darkCard = Color(0xFF161228);
  static const Color darkBorder = Color(0x14FFFFFF);
  static const Color darkSurface = Color(0xFF1E1936);

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);

  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF22D3EE);
  static const Color purple = Color(0xFFA855F7);
  static const Color cyan = Color(0xFF22D3EE);
  static const Color amber = Color(0xFFFBBF24);
  static const Color emerald = Color(0xFF34D399);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBase,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.brandPrimary,
        secondary: AppColors.purple,
        surface: AppColors.darkCard,
        error: AppColors.danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
        headlineLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          color: AppColors.textTertiary,
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: AppColors.textTertiary,
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: 20,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 0.5,
      ),
    );
  }

  static BoxDecoration glassPanelDecoration = BoxDecoration(
    color: AppColors.darkCard.withOpacity(0.75),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: Colors.white.withOpacity(0.08),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.37),
        blurRadius: 32,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration glassCardDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(0.07),
        Colors.white.withOpacity(0.02),
      ],
    ),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.white.withOpacity(0.08),
      width: 1,
    ),
  );

  static BoxDecoration brandGradientDecoration = BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.brand500,
        AppColors.purple,
        Color(0xFF6366F1),
      ],
    ),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: AppColors.brandGlow,
        blurRadius: 25,
        offset: const Offset(0, 0),
        spreadRadius: -5,
      ),
    ],
  );

  static LinearGradient get brandGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.brand500,
          AppColors.purple,
          Color(0xFF6366F1),
        ],
      );

  static LinearGradient get readinessGradient => const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          AppColors.brand500,
          AppColors.emerald,
        ],
      );
}
