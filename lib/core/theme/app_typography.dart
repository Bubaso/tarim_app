import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  // Breakpoints
  static const double _mobileMax = 480.0;
  static const double _tabletMax = 1024.0;

  static bool _isMobile(double width) => width <= _mobileMax;
  static bool _isTablet(double width) => width > _mobileMax && width <= _tabletMax;
  // Desktop is > 1024.0

  // 1) headlineHome (H1) - Anasayfa manşeti
  static TextStyle headlineHome(BuildContext context, {Color? color}) {
    final w = MediaQuery.of(context).size.width;
    double fontSize;
    double height = 1.15; // Ortalama line-height

    if (_isMobile(w)) {
      fontSize = 27.0;
    } else if (_isTablet(w)) {
      fontSize = 36.0;
    } else {
      fontSize = 48.0;
    }

    return GoogleFonts.libreFranklin(
      fontSize: fontSize,
      height: height,
      fontWeight: FontWeight.w900,
      color: color,
    );
  }

  // 2) headlineDetail (H1) - Haber detay sayfası başlığı
  static TextStyle headlineDetail(BuildContext context, {Color? color}) {
    final w = MediaQuery.of(context).size.width;
    double fontSize;
    const double height = 1.20;

    if (_isMobile(w)) {
      fontSize = 24.0;
    } else if (_isTablet(w)) {
      fontSize = 32.0;
    } else {
      fontSize = 40.0;
    }

    return GoogleFonts.libreFranklin(
      fontSize: fontSize,
      height: height,
      fontWeight: FontWeight.w900,
      color: color,
    );
  }

  // 3) headlineCard (H2) - Liste/kart başlığı
  static TextStyle headlineCard(BuildContext context, {Color? color}) {
    final w = MediaQuery.of(context).size.width;
    double fontSize;
    const double height = 1.25;

    if (_isMobile(w)) {
      fontSize = 17.0;
    } else if (_isTablet(w)) {
      fontSize = 19.0;
    } else {
      fontSize = 22.0;
    }

    return GoogleFonts.libreFranklin(
      fontSize: fontSize,
      height: height,
      fontWeight: FontWeight.w900,
      color: color,
    );
  }

  // 4) deck / spot - Alt başlık / özet (italik)
  static TextStyle deck(BuildContext context, {Color? color}) {
    final w = MediaQuery.of(context).size.width;
    double fontSize;
    const double height = 1.40;

    if (_isMobile(w)) {
      fontSize = 16.0;
    } else if (_isTablet(w)) {
      fontSize = 17.0;
    } else {
      fontSize = 18.0;
    }

    return GoogleFonts.libreFranklin(
      fontSize: fontSize,
      height: height,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.italic,
      color: color,
    );
  }

  // 5) body - Haber gövde metni
  static TextStyle body(BuildContext context, {Color? color}) {
    final w = MediaQuery.of(context).size.width;
    double fontSize;
    const double height = 1.70;

    if (_isMobile(w)) {
      fontSize = 16.0;
    } else if (_isTablet(w)) {
      fontSize = 16.0;
    } else {
      fontSize = 18.0;
    }

    return GoogleFonts.lora(
      fontSize: fontSize,
      height: height,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  // 6) meta - Yazar, tarih, kategori etiketi
  static TextStyle meta(BuildContext context, {Color? color}) {
    final w = MediaQuery.of(context).size.width;
    double fontSize;
    const double height = 1.30;

    if (_isMobile(w)) {
      fontSize = 13.0;
    } else if (_isTablet(w)) {
      fontSize = 13.0;
    } else {
      fontSize = 14.0;
    }

    return GoogleFonts.libreFranklin(
      fontSize: fontSize,
      height: height,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }
}
