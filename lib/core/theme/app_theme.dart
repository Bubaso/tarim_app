import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Global layout constraint — maksimum içerik genişliği (desktop).
const double kDesktopMaxWidth = 1200.0;

/// Premium Medya Portalı Tasarım Sistemi
///
/// Renk, tipografi ve widget temalarını tek yerden yönetir.
/// [AppTheme.lightTheme] ile erişilir.
class AppTheme {
  AppTheme._();

  // ─── BorderRadius Sabiti ──────────────────────────────────────────────────
  /// Tüm widget'larda keskin ve ciddi köşe yarıçapı.
  static const BorderRadius _sharpRadius =
      BorderRadius.all(Radius.circular(4.0));

  // ═══════════════════════════════════════════════════════════════════════════
  //  IŞIK TEMASI (Kurumsal Renk Paleti Kullanımı)
  // ═══════════════════════════════════════════════════════════════════════════
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);

    // ColorScheme oluşturuluyor
    final colorScheme = const ColorScheme.light(
      primary: AppColors.primaryGreen,
      onPrimary: Colors.white,
      primaryContainer: AppColors.darkGreen,
      onPrimaryContainer: Colors.white,
      secondary: AppColors.darkGreen,
      onSecondary: Colors.white,
      tertiary: AppColors.wheat,
      onTertiary: Colors.white,
      surface: AppColors.creamBackground,
      onSurface: AppColors.earthText,
      // ignore: deprecated_member_use
      background: AppColors.creamBackground,
      // ignore: deprecated_member_use
      onBackground: AppColors.earthText,
      error: Color(0xFFD32F2F),
      onError: Colors.white,
      outline: AppColors.wheat, // Ayırıcı ince çizgiler vb. için wheat
    );

    return base.copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.creamBackground,
      primaryColor: AppColors.primaryGreen,
      dividerColor: AppColors.wheat,
      colorScheme: colorScheme,

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.creamBackground,
        foregroundColor: AppColors.earthText,
        elevation: 0,
        scrolledUnderElevation: 0, // Gölgeden kaçınmak için
        shadowColor: Colors.transparent,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.earthText, size: 22),
      ),

      // ── Card ──────────────────────────────────────────────────────────────
      cardTheme: const CardThemeData(
        color: Colors.white, // Kartlarda daha beyaz/krem hissi
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.wheat, width: 1.0),
          borderRadius: _sharpRadius,
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.wheat,
        thickness: 1.0,
        space: 1.0,
      ),

      // ── ElevatedButton ────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: _sharpRadius),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // ── OutlinedButton ────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.earthText,
          side: const BorderSide(color: AppColors.wheat, width: 1.5),
          shape: const RoundedRectangleBorder(borderRadius: _sharpRadius),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── TextButton ────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          shape: const RoundedRectangleBorder(borderRadius: _sharpRadius),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── InputDecoration ───────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.wheat, width: 1.0),
          borderRadius: _sharpRadius,
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.wheat, width: 1.0),
          borderRadius: _sharpRadius,
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryGreen, width: 1.5),
          borderRadius: _sharpRadius,
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFD32F2F), width: 1.0),
          borderRadius: _sharpRadius,
        ),
        labelStyle: GoogleFonts.inter(color: AppColors.earthText.withOpacity(0.7), fontSize: 14),
        hintStyle: GoogleFonts.inter(color: AppColors.earthText.withOpacity(0.5), fontSize: 14),
      ),

      // ── Chip ──────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.creamBackground,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: AppColors.wheat),
          borderRadius: _sharpRadius,
        ),
        labelStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.earthText),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),

      // ── Scrollbar ─────────────────────────────────────────────────────────
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(AppColors.wheat),
        trackColor: WidgetStateProperty.all(AppColors.creamBackground),
        thickness: WidgetStateProperty.all(4.0),
        radius: const Radius.circular(0),
      ),

      // ── ListTile ──────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        dense: true,
        iconColor: AppColors.earthText.withOpacity(0.7),
      ),

      // ── Tipografi ─────────────────────────────────────────────────────────
      textTheme: _buildTextTheme(
        headingColor: AppColors.earthText,
        bodyColor: AppColors.earthText,
        subtleColor: AppColors.earthText.withOpacity(0.6),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  ORTAK TİPOGRAFİ OLUŞTURUCU
  // ═══════════════════════════════════════════════════════════════════════════
  static TextTheme _buildTextTheme({
    required Color headingColor,
    required Color bodyColor,
    required Color subtleColor,
  }) {
    return TextTheme(
      // ── Display — Libre Franklin (Büyük manşetler vb.) ──────────────────────
      displayLarge: GoogleFonts.libreFranklin(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        color: headingColor,
        height: 1.15,
      ),
      displayMedium: GoogleFonts.libreFranklin(
        fontSize: 36,
        fontWeight: FontWeight.w900,
        color: headingColor,
        height: 1.15,
      ),
      displaySmall: GoogleFonts.libreFranklin(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        color: headingColor,
        height: 1.15,
      ),

      // ── Headline — Libre Franklin (Haber detay başlığı, Kart başlıkları) ───
      headlineLarge: GoogleFonts.libreFranklin(
        fontSize: 40, // desktop headlineDetail
        fontWeight: FontWeight.w900,
        color: headingColor,
        height: 1.2,
      ),
      headlineMedium: GoogleFonts.libreFranklin(
        fontSize: 22, // desktop headlineCard
        fontWeight: FontWeight.w900,
        color: headingColor,
        height: 1.25,
      ),
      headlineSmall: GoogleFonts.libreFranklin(
        fontSize: 18, // desktop deck/spot
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
        color: headingColor,
        height: 1.40,
      ),

      // ── Title — Libre Franklin ───────────────────────────────
      titleLarge: GoogleFonts.libreFranklin(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: headingColor,
        height: 1.25,
      ),
      titleMedium: GoogleFonts.libreFranklin(
        fontSize: 15,
        fontWeight: FontWeight.w500, // meta style baseline
        color: headingColor,
        height: 1.3,
      ),
      titleSmall: GoogleFonts.libreFranklin(
        fontSize: 13,
        fontWeight: FontWeight.w500, // meta style baseline
        color: headingColor,
        height: 1.3,
      ),

      // ── Body — Lora (Haber gövde metni ve uzun okuma) ───────────────────
      bodyLarge: GoogleFonts.lora(
        fontSize: 18, // desktop body
        fontWeight: FontWeight.w400,
        color: bodyColor,
        height: 1.70,
      ),
      bodyMedium: GoogleFonts.lora(
        fontSize: 16, // tablet/mobile body
        fontWeight: FontWeight.w400,
        color: bodyColor,
        height: 1.70,
      ),
      bodySmall: GoogleFonts.lora(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: subtleColor,
        height: 1.70,
      ),

      // ── Label — Libre Franklin (UI etiketleri) ──────────────────────────────────
      labelLarge: GoogleFonts.libreFranklin(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: bodyColor,
        height: 1.3,
      ),
      labelMedium: GoogleFonts.libreFranklin(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: subtleColor,
        height: 1.3,
      ),
      labelSmall: GoogleFonts.libreFranklin(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: subtleColor,
        height: 1.3,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  YARDIMCI: Finansal/Borsa Verileri için Roboto Mono TextStyle
  // ═══════════════════════════════════════════════════════════════════════════

  /// Borsa fiyatları, yüzde değişimleri vb. sayısal veriler için kullanın.
  static TextStyle monoLarge({Color? color}) => GoogleFonts.robotoMono(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: -0.3,
      );

  static TextStyle monoMedium({Color? color}) => GoogleFonts.robotoMono(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: -0.2,
      );

  static TextStyle monoSmall({Color? color}) => GoogleFonts.robotoMono(
        fontSize: 11,
        fontWeight: FontWeight.normal,
        color: color,
      );
}
