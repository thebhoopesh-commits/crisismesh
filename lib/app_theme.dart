import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 🎨 Tactical Color Tokens — single source of truth for all UI agents.
///
/// Re-exported through [[TacticalColors]] so every widget references the
/// exact values defined in the Architecture document — no hardcoded colors
/// anywhere else in the codebase.
class TacticalColors {
  TacticalColors._();

  // Backgrounds & Surface
  static const Color background = Color(0xFF0F172A); // Slate 900 (Dark Tactical Slate)
  static const Color surface = Color(0xFF1E293B); // Slate 800 (Card Surface)
  static const Color surfaceBorder = Color(0xFF334155); // Slate 700 (High-contrast Border)

  // Emergency Triage Priority Colors
  static const Color priorityRed = Color(0xFFEF4444); // RED: Critical / Life Threatening
  static const Color priorityYellow = Color(0xFFF59E0B); // YELLOW: Urgent / Stable
  static const Color priorityGreen = Color(0xFF10B981); // GREEN: Minor / Supplies Only

  // Tactical Accents & Text
  static const Color accentBlue = Color(0xFF3B82F6); // Command Blue
  static const Color textPrimary = Color(0xFFF8FAFC); // Slate 50 (High Legibility)
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color offgridStatus = Color(0xFF22C55E); // Glowing Green Status Pulse

  // Translucent fills for triage badges
  static const Color priorityRedFill = Color(0x33EF4444); // 20% Red
  static const Color priorityYellowFill = Color(0x33F59E0B); // 20% Amber
  static const Color priorityGreenFill = Color(0x3310B981); // 20% Green
}

/// 🧱 Material 3 Tactical Dark Theme.
///
/// Provides consistent typography, spacing, and component shaping so the
/// UI Agent doesn't have to redefine styles per widget.
class TacticalTheme {
  TacticalTheme._();

  static const double _touchTargetMin = 48.0;
  static const double _radius = 14.0;
  static const double _radiusLarge = 20.0;

  static ThemeData dark() {
    const ColorScheme scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: TacticalColors.accentBlue,
      onPrimary: TacticalColors.textPrimary,
      secondary: TacticalColors.offgridStatus,
      onSecondary: TacticalColors.background,
      error: TacticalColors.priorityRed,
      onError: TacticalColors.textPrimary,
      surface: TacticalColors.surface,
      onSurface: TacticalColors.textPrimary,
      surfaceContainerHighest: TacticalColors.surfaceBorder,
      outline: TacticalColors.surfaceBorder,
    );

    final TextTheme textTheme = const TextTheme(
      displayLarge: TextStyle(
        color: TacticalColors.textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        color: TacticalColors.textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        color: TacticalColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: TacticalColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: TacticalColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.35,
      ),
      bodyMedium: TextStyle(
        color: TacticalColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.35,
      ),
      bodySmall: TextStyle(
        color: TacticalColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
      ),
      labelLarge: TextStyle(
        color: TacticalColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: TacticalColors.background,
      canvasColor: TacticalColors.background,
      textTheme: textTheme,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: TacticalColors.background,
        foregroundColor: TacticalColors.textPrimary,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          color: TacticalColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
      iconTheme: const IconThemeData(
        color: TacticalColors.textPrimary,
        size: 22,
      ),
      cardTheme: CardThemeData(
        color: TacticalColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: const BorderSide(color: TacticalColors.surfaceBorder, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: TacticalColors.surfaceBorder,
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, _touchTargetMin),
          backgroundColor: TacticalColors.accentBlue,
          foregroundColor: TacticalColors.textPrimary,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, _touchTargetMin),
          backgroundColor: TacticalColors.accentBlue,
          foregroundColor: TacticalColors.textPrimary,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, _touchTargetMin),
          foregroundColor: TacticalColors.textPrimary,
          side: const BorderSide(color: TacticalColors.surfaceBorder, width: 1.5),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, _touchTargetMin),
          foregroundColor: TacticalColors.accentBlue,
          textStyle: textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: TacticalColors.priorityRed,
        foregroundColor: TacticalColors.textPrimary,
        elevation: 6,
        focusElevation: 8,
        hoverElevation: 8,
        highlightElevation: 10,
        extendedTextStyle: TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
          fontSize: 14,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TacticalColors.surface,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: TacticalColors.textSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: TacticalColors.surfaceBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: TacticalColors.surfaceBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: TacticalColors.accentBlue, width: 1.5),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: TacticalColors.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: TacticalColors.surface,
        modalElevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(_radiusLarge)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: TacticalColors.surface,
        contentTextStyle: textTheme.bodyMedium,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: const BorderSide(color: TacticalColors.surfaceBorder, width: 1),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: TacticalColors.accentBlue,
        linearTrackColor: TacticalColors.surfaceBorder,
      ),
    );
  }
}
