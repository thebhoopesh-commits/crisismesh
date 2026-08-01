import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App Colors & Design Tokens derived from the Handoff PDF
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF20328F);
  static const Color primaryDark = Color(0xFF16215F);
  static const Color accent = Color(0xFF7EA8FF);
  static const Color userDot = Color(0xFF3F7BE8);

  static const Color critical = Color(0xFFE5484D);
  static const Color urgent = Color(0xFFF2A33C);
  static const Color stable = Color(0xFF34A853);
  
  static const Color bg = Color(0xFFEEF0F4);
  static const Color surface = Color(0xFFFFFFFF);
  
  static const Color text = Color(0xFF1D1F20);
  static const Color textMuted = Color(0xFF8A90A0);
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.critical,
        onPrimary: Colors.white,
        onSurface: AppColors.text,
      ),
      textTheme: TextTheme(
        bodyLarge: GoogleFonts.roboto(color: AppColors.text),
        bodyMedium: GoogleFonts.roboto(color: AppColors.text),
        bodySmall: GoogleFonts.roboto(color: AppColors.textMuted),
        titleLarge: GoogleFonts.roboto(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
        titleMedium: GoogleFonts.roboto(color: AppColors.text, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        elevation: 20,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        elevation: 8,
      ),
    );
  }
}
