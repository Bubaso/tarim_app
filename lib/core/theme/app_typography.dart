import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ─── Typography System ────────────────────────────────────────────────────
/// Breakpoints (matching the user's spec table):
///   Mobile   : ≤ 480 px
///   Tablet   : 481 – 1023 px
///   Desktop  : ≥ 1024 px
///
/// [scale] is the user-controlled font-scale multiplier (default 1.0).
/// Apply it only to reading content — never to UI chrome.
class AppTypography {
  AppTypography._();

  static const double _mobileMax = 480.0;
  static const double _tabletMax = 1024.0;

  static bool _isMobile(double w) => w <= _mobileMax;
  static bool _isTablet(double w) => w > _mobileMax && w < _tabletMax;

  // ── 1. Anasayfa manşeti H1 ──────────────────────────────────────────────
  // Mobile 26-28 → 27 | Tablet 34-38 → 36 | Desktop 44-52 → 48 | LH 1.1-1.15
  static TextStyle headlineHome(
    BuildContext context, {
    Color? color,
    double scale = 1.0,
  }) {
    final w = MediaQuery.of(context).size.width;
    double fontSize;
    if (_isMobile(w)) {
      fontSize = 27.0;
    } else if (_isTablet(w)) {
      fontSize = 36.0;
    } else {
      fontSize = 48.0;
    }
    return GoogleFonts.libreFranklin(
      fontSize: fontSize * scale,
      height: 1.12,
      fontWeight: FontWeight.w900,
      color: color,
    );
  }

  // ── 2. Haber detay başlığı H1 ───────────────────────────────────────────
  // Mobile 22-24 → 23 | Tablet 30-32 → 31 | Desktop 36-40 → 38 | LH 1.2
  static TextStyle headlineDetail(
    BuildContext context, {
    Color? color,
    double scale = 1.0,
  }) {
    final w = MediaQuery.of(context).size.width;
    double fontSize;
    if (_isMobile(w)) {
      fontSize = 23.0;
    } else if (_isTablet(w)) {
      fontSize = 31.0;
    } else {
      fontSize = 38.0;
    }
    return GoogleFonts.libreFranklin(
      fontSize: fontSize * scale,
      height: 1.20,
      fontWeight: FontWeight.w900,
      color: color,
    );
  }

  // ── 3. Liste/kart başlığı H2 ────────────────────────────────────────────
  // Mobile 16-17 → 16.5 | Tablet 18-19 → 18.5 | Desktop 20-22 → 21 | LH 1.25
  static TextStyle headlineCard(
    BuildContext context, {
    Color? color,
    double scale = 1.0,
  }) {
    final w = MediaQuery.of(context).size.width;
    double fontSize;
    if (_isMobile(w)) {
      fontSize = 16.5;
    } else if (_isTablet(w)) {
      fontSize = 18.5;
    } else {
      fontSize = 21.0;
    }
    return GoogleFonts.libreFranklin(
      fontSize: fontSize * scale,
      height: 1.25,
      fontWeight: FontWeight.w900,
      color: color,
    );
  }

  // ── 4. Spot / dek ────────────────────────────────────────────────────────
  // Mobile 15-16 → 15.5 | Tablet 16-17 → 16.5 | Desktop 17-18 → 17.5 | LH 1.4
  static TextStyle deck(
    BuildContext context, {
    Color? color,
    double scale = 1.0,
  }) {
    final w = MediaQuery.of(context).size.width;
    double fontSize;
    if (_isMobile(w)) {
      fontSize = 15.5;
    } else if (_isTablet(w)) {
      fontSize = 16.5;
    } else {
      fontSize = 17.5;
    }
    return GoogleFonts.libreFranklin(
      fontSize: fontSize * scale,
      height: 1.40,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.italic,
      color: color,
    );
  }

  // ── 5. Haber metni (gövde) ───────────────────────────────────────────────
  // Mobile 15-16 → 15.5 | Tablet 16 → 16 | Desktop 17-18 → 17.5 | LH 1.65-1.75
  static TextStyle body(
    BuildContext context, {
    Color? color,
    double scale = 1.0,
  }) {
    final w = MediaQuery.of(context).size.width;
    double fontSize;
    if (_isMobile(w)) {
      fontSize = 15.5;
    } else if (_isTablet(w)) {
      fontSize = 16.0;
    } else {
      fontSize = 17.5;
    }
    return GoogleFonts.lora(
      fontSize: fontSize * scale,
      height: 1.70,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  // ── 6. Meta (yazar, tarih, kategori) ────────────────────────────────────
  // Mobile 12-13 → 12.5 | Tablet 13 → 13 | Desktop 13-14 → 13.5 | LH 1.3
  // Note: scale is intentionally NOT applied to meta — it's UI chrome.
  static TextStyle meta(BuildContext context, {Color? color}) {
    final w = MediaQuery.of(context).size.width;
    double fontSize;
    if (_isMobile(w)) {
      fontSize = 12.5;
    } else if (_isTablet(w)) {
      fontSize = 13.0;
    } else {
      fontSize = 13.5;
    }
    return GoogleFonts.libreFranklin(
      fontSize: fontSize,
      height: 1.30,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  /// Returns the base body font size (without scale) for the current screen.
  /// Used for flutter_html FontSize calculations.
  static double bodyBaseFontSize(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (_isMobile(w)) return 15.5;
    if (_isTablet(w)) return 16.0;
    return 17.5;
  }

  /// Returns the base H2 font size for the current screen (used in flutter_html).
  static double h2BaseFontSize(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (_isMobile(w)) return 16.5;
    if (_isTablet(w)) return 18.5;
    return 21.0;
  }
}
