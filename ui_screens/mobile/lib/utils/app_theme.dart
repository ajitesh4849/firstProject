import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Enterprise design tokens for FoodScan mobile.
class AppColors {
  static const Color primary = Color(0xFF0F766E);
  static const Color primaryDark = Color(0xFF0B5C56);
  static const Color primarySoft = Color(0xFFE6F4F2);
  static const Color accent = Color(0xFFC97816);
  static const Color background = Color(0xFFF3F6F4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEEF2EF);
  static const Color textPrimary = Color(0xFF15201B);
  static const Color textSecondary = Color(0xFF5B6A63);
  static const Color textTertiary = Color(0xFF8A9790);
  static const Color border = Color(0xFFD8E2DC);
  static const Color danger = Color(0xFFB42318);
  static const Color dangerSoft = Color(0xFFFEE4E2);
  static const Color success = Color(0xFF067647);
  static const Color warning = Color(0xFFB54708);
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const EdgeInsets page = EdgeInsets.fromLTRB(20, 8, 20, 24);
  static const EdgeInsets pageCompact = EdgeInsets.fromLTRB(20, 12, 20, 20);
}

class AppRadii {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double full = 999;
}

class AppShadows {
  static List<BoxShadow> get soft => [
        BoxShadow(
          color: const Color(0xFF15201B).withValues(alpha: 0.06),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> get card => [
        BoxShadow(
          color: const Color(0xFF15201B).withValues(alpha: 0.045),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];
}

class AppTheme {
  static ThemeData get light {
    final baseText = GoogleFonts.plusJakartaSansTextTheme();

    TextStyle style(
      double size, {
      FontWeight weight = FontWeight.w400,
      Color color = AppColors.textPrimary,
      double height = 1.35,
      double letterSpacing = 0,
    }) {
      return GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );
    }

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      error: AppColors.danger,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      textTheme: baseText.copyWith(
        headlineLarge: style(34, weight: FontWeight.w800, letterSpacing: -0.6, height: 1.15),
        headlineMedium: style(26, weight: FontWeight.w700, letterSpacing: -0.4, height: 1.2),
        titleLarge: style(20, weight: FontWeight.w700, letterSpacing: -0.2),
        titleMedium: style(16, weight: FontWeight.w600),
        bodyLarge: style(16, weight: FontWeight.w500),
        bodyMedium: style(14, color: AppColors.textSecondary, height: 1.45),
        bodySmall: style(12, color: AppColors.textTertiary, height: 1.4),
        labelLarge: style(15, weight: FontWeight.w700, color: Colors.white),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: style(20, weight: FontWeight.w700, letterSpacing: -0.2),
        iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 22),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: style(14, color: Colors.white, weight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        height: 72,
        indicatorColor: AppColors.primarySoft,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return style(
            12,
            weight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.primaryDark : AppColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: selected ? AppColors.primary : AppColors.textSecondary,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: style(14, color: AppColors.textTertiary),
        labelStyle: style(14, color: AppColors.textSecondary, weight: FontWeight.w500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.45),
          disabledForegroundColor: Colors.white,
          minimumSize: const Size(48, 54),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
          textStyle: style(15, weight: FontWeight.w700, color: Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          side: const BorderSide(color: AppColors.border, width: 1.4),
          minimumSize: const Size(48, 54),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
          textStyle: style(15, weight: FontWeight.w700, color: AppColors.primaryDark),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.border,
      ),
    );
  }
}
