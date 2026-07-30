// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors (Luxury Theme)
  static const Color creamBackground = Color(0xFFF9F6F0);
  static const Color deepBurgundy = Color(0xFF6B1D2F);
  static const Color charcoalBlack = Color(0xFF1A1A1A);
  static const Color darkGrey = Color(0xFF555555);
  static const Color lightGrey = Color(0xFFE5E2DC);
  static const Color pureWhite = Color(0xFFFFFFFF);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: creamBackground,
      primaryColor: deepBurgundy,
      colorScheme: ColorScheme.fromSeed(
        seedColor: deepBurgundy,
        primary: deepBurgundy,
        background: creamBackground,
        surface: pureWhite,
        onPrimary: pureWhite,
        onSurface: charcoalBlack,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cairo(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: charcoalBlack,
        ),
        displayMedium: GoogleFonts.cairo(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: charcoalBlack,
        ),
        titleLarge: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: charcoalBlack,
        ),
        bodyLarge: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: charcoalBlack,
        ),
        bodyMedium: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: darkGrey,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: creamBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: charcoalBlack),
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: charcoalBlack,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: deepBurgundy,
          foregroundColor: pureWhite,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: pureWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: deepBurgundy, width: 2),
        ),
        hintStyle: GoogleFonts.cairo(
          color: darkGrey,
          fontSize: 14,
        ),
      ),
    );
  }
}