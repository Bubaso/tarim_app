// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeConstants {
  // Brand Colors (Bloomberg / Financial Times - Premium Tarım & Ekonomi Gazetesi)
  static const Color primaryGreen = Color(0xFF1E3F20); // Premium deep forest green
  static const Color secondaryGold = Color(0xFF8B5E3C); // Zengin toprak tonu / Copper Gold
  static const Color earthBrown = Color(0xFF5D4037); // Koyu toprak tonu
  static const Color leafLight = Color(0xFFE8F5E9); // Açık zeytin tonu
  static const Color creamBackground = Color(0xFFFAF5EF); // Financial Times tarzı elit hafif gazete kağıdı kremi

  // Seed Color for Material 3 Scheme
  static const Color seedColor = primaryGreen;

  // Light Theme (Financial Times - Elit Tarım Gazetesi)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
        primary: primaryGreen,
        secondary: secondaryGold,
        tertiary: const Color(0xFF1B2A4A), // Deep navy
        surface: creamBackground,
        onSurface: const Color(0xFF1E1E1C),
        outlineVariant: const Color(0xFFEBE3D5), // Gazete sayfa çizgisi rengi
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: const Color(0xFF1E1E1C)),
        displayMedium: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: const Color(0xFF1E1E1C)),
        displaySmall: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: const Color(0xFF1E1E1C)),
        headlineLarge: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: const Color(0xFF1E1E1C)),
        headlineMedium: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: const Color(0xFF1E1E1C)),
        headlineSmall: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: const Color(0xFF1E1E1C)),
        titleLarge: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, fontSize: 22, color: const Color(0xFF1E1E1C)),
        titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w700, color: const Color(0xFF1E1E1C)),
        titleSmall: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF1E1E1C)),
        bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.normal, fontSize: 16, color: const Color(0xFF2C2C2A)),
        bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.normal, fontSize: 14, color: const Color(0xFF3C3C3A)),
        bodySmall: GoogleFonts.inter(color: const Color(0xFF5E5E5C), fontSize: 12),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: creamBackground,
        elevation: 0,
        scrolledUnderElevation: 1.0,
        iconTheme: const IconThemeData(color: primaryGreen),
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: primaryGreen,
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(
            color: Color(0xFFEBE3D5),
            width: 1.2,
          ),
        ),
        color: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFEBE3D5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFEBE3D5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
      ),
    );
  }

  // Dark Theme (Bloomberg Terminal - Yüksek Seviye Finans Arayüzü)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
        primary: const Color(0xFF00E676), // Bloomberg terminal neon yeşili
        secondary: const Color(0xFFB0BEC5), // Terminal gri/mavi
        tertiary: const Color(0xFFFFB74D), // Canlı turuncu/uyarı rengi
        surface: const Color(0xFF0C1015), // Bloomberg terminal koyu laciverti
        onSurface: const Color(0xFFECEFF1),
        outlineVariant: const Color(0xFF1E2631),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: const Color(0xFFECEFF1)),
        displayMedium: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: const Color(0xFFECEFF1)),
        displaySmall: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: const Color(0xFFECEFF1)),
        headlineLarge: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: const Color(0xFFECEFF1)),
        headlineMedium: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: const Color(0xFFECEFF1)),
        headlineSmall: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: const Color(0xFFECEFF1)),
        titleLarge: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, fontSize: 22, color: const Color(0xFFECEFF1)),
        titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w700, color: const Color(0xFFECEFF1)),
        titleSmall: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFFECEFF1)),
        bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.normal, fontSize: 16, color: const Color(0xFFCFD8DC)),
        bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.normal, fontSize: 14, color: const Color(0xFFB0BEC5)),
        bodySmall: GoogleFonts.inter(color: const Color(0xFF90A4AE), fontSize: 12),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: const Color(0xFF0C1015),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF00E676)),
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: const Color(0xFFECEFF1),
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(
            color: Color(0xFF1E2631),
            width: 1.2,
          ),
        ),
        color: const Color(0xFF121820),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF121820),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1E2631)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1E2631)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF00E676), width: 1.5),
        ),
      ),
    );
  }
}
