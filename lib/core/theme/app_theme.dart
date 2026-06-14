import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Global layout constraint — maksimum içerik genişliği (desktop).
const double kDesktopMaxWidth = 1200.0;

/// Premium Medya Portalı Tasarım Sistemi
///
/// Renk, tipografi ve widget temalarını tek yerden yönetir.
/// [AppTheme.lightTheme] ve [AppTheme.darkTheme] ile erişilir.
class AppTheme {
  AppTheme._();

  // ─── Işık Teması Renk Paleti ───────────────────────────────────────────────
  static const Color background     = Color(0xFFFAF9F6); // Premium fildişi
  static const Color surface        = Color(0xFFFFFFFF); // Kart/panel yüzeyi
  static const Color primaryText    = Color(0xFF1A1A1A); // Sofistike koyu metin
  static const Color secondaryText  = Color(0xFF666666); // Okunabilir gri
  static const Color accent         = Color(0xFF004A99); // Derin gazete mavisi
  static const Color divider        = Color(0xFFE0E0E0); // İnce ayırıcı

  // ─── Karanlık Tema Renk Paleti ────────────────────────────────────────────
  static const Color darkBackground    = Color(0xFF0C1015); // Terminal siyahı
  static const Color darkSurface       = Color(0xFF161B22); // Panel yüzeyi
  static const Color darkPrimaryText   = Color(0xFFF0F6FC); // Açık metin
  static const Color darkSecondaryText = Color(0xFF8B949E); // Gri metin
  static const Color darkAccent        = Color(0xFF58A6FF); // Terminal mavisi
  static const Color darkDivider       = Color(0xFF30363D); // Koyu ayırıcı

  // ─── BorderRadius Sabiti ──────────────────────────────────────────────────
  /// Tüm widget'larda keskin ve ciddi köşe yarıçapı.
  static const BorderRadius _sharpRadius =
      BorderRadius.all(Radius.circular(4.0));

  // ═══════════════════════════════════════════════════════════════════════════
  //  IŞIK TEMASI
  // ═══════════════════════════════════════════════════════════════════════════
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: accent,
      dividerColor: divider,

      colorScheme: const ColorScheme.light(
        primary:         accent,
        onPrimary:       Colors.white,
        secondary:       secondaryText,
        onSecondary:     Colors.white,
        surface:         surface,
        onSurface:       primaryText,
        error:           Color(0xFFD32F2F),
        onError:         Colors.white,
        outline:         divider,
      ),

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: primaryText,
        elevation: 0,
        scrolledUnderElevation: 1.0,
        shadowColor: divider,
        centerTitle: false,
        iconTheme: const IconThemeData(color: primaryText, size: 22),
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: primaryText,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),

      // ── Card ──────────────────────────────────────────────────────────────
      cardTheme: const CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: divider, width: 1.0),
          borderRadius: _sharpRadius,
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1.0,
        space: 1.0,
      ),

      // ── ElevatedButton ────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
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
          foregroundColor: primaryText,
          side: const BorderSide(color: divider, width: 1.5),
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
          foregroundColor: accent,
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
        fillColor: surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: divider, width: 1.0),
          borderRadius: _sharpRadius,
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: divider, width: 1.0),
          borderRadius: _sharpRadius,
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: accent, width: 1.5),
          borderRadius: _sharpRadius,
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFD32F2F), width: 1.0),
          borderRadius: _sharpRadius,
        ),
        labelStyle: GoogleFonts.inter(color: secondaryText, fontSize: 14),
        hintStyle: GoogleFonts.inter(color: secondaryText, fontSize: 14),
      ),

      // ── Chip ──────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: background,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: divider),
          borderRadius: _sharpRadius,
        ),
        labelStyle: GoogleFonts.inter(fontSize: 12, color: primaryText),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),

      // ── Scrollbar ─────────────────────────────────────────────────────────
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(divider),
        trackColor: WidgetStateProperty.all(background),
        thickness: WidgetStateProperty.all(4.0),
        radius: const Radius.circular(0),
      ),

      // ── ListTile ──────────────────────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        dense: true,
        iconColor: secondaryText,
      ),

      // ── Tipografi ─────────────────────────────────────────────────────────
      // Başlıklar: Playfair Display (serif, ağırbaşlı)
      // Gövde:     Lora (gazete standardı, serif body)
      // UI:        Inter (temiz, modern sans-serif)
      // Monospace: Roboto Mono (finansal/borsa verileri)
      textTheme: _buildTextTheme(
        headingColor: primaryText,
        bodyColor: primaryText,
        subtleColor: secondaryText,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  KARANLIK TEMA
  // ═══════════════════════════════════════════════════════════════════════════
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: darkAccent,
      dividerColor: darkDivider,

      colorScheme: const ColorScheme.dark(
        primary:         darkAccent,
        onPrimary:       darkBackground,
        secondary:       darkSecondaryText,
        onSecondary:     darkBackground,
        surface:         darkSurface,
        onSurface:       darkPrimaryText,
        error:           Color(0xFFCF6679),
        onError:         Colors.black,
        outline:         darkDivider,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkPrimaryText,
        elevation: 0,
        scrolledUnderElevation: 1.0,
        shadowColor: darkDivider,
        centerTitle: false,
        iconTheme: const IconThemeData(color: darkPrimaryText, size: 22),
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: darkPrimaryText,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),

      cardTheme: const CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: darkDivider, width: 1.0),
          borderRadius: _sharpRadius,
        ),
        margin: EdgeInsets.zero,
      ),

      dividerTheme: const DividerThemeData(
        color: darkDivider,
        thickness: 1.0,
        space: 1.0,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkAccent,
          foregroundColor: darkBackground,
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

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkPrimaryText,
          side: const BorderSide(color: darkDivider, width: 1.5),
          shape: const RoundedRectangleBorder(borderRadius: _sharpRadius),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkAccent,
          shape: const RoundedRectangleBorder(borderRadius: _sharpRadius),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: darkDivider, width: 1.0),
          borderRadius: _sharpRadius,
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: darkDivider, width: 1.0),
          borderRadius: _sharpRadius,
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: darkAccent, width: 1.5),
          borderRadius: _sharpRadius,
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFCF6679), width: 1.0),
          borderRadius: _sharpRadius,
        ),
        labelStyle:
            GoogleFonts.inter(color: darkSecondaryText, fontSize: 14),
        hintStyle:
            GoogleFonts.inter(color: darkSecondaryText, fontSize: 14),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: darkSurface,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: darkDivider),
          borderRadius: _sharpRadius,
        ),
        labelStyle:
            GoogleFonts.inter(fontSize: 12, color: darkPrimaryText),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),

      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(darkDivider),
        trackColor: WidgetStateProperty.all(darkBackground),
        thickness: WidgetStateProperty.all(4.0),
        radius: const Radius.circular(0),
      ),

      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        dense: true,
        iconColor: darkSecondaryText,
      ),

      textTheme: _buildTextTheme(
        headingColor: darkPrimaryText,
        bodyColor: darkPrimaryText,
        subtleColor: darkSecondaryText,
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
      // ── Display — Playfair Display (manşet boyutu) ──────────────────────
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        color: headingColor,
        height: 1.1,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 36,
        fontWeight: FontWeight.w900,
        color: headingColor,
        height: 1.1,
        letterSpacing: -0.3,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: headingColor,
        height: 1.15,
      ),

      // ── Headline — Playfair Display (bölüm başlıkları) ─────────────────
      headlineLarge: GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: headingColor,
        height: 1.2,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: headingColor,
        height: 1.25,
      ),
      headlineSmall: GoogleFonts.playfairDisplay(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: headingColor,
        height: 1.25,
      ),

      // ── Title — Playfair Display / Inter ───────────────────────────────
      titleLarge: GoogleFonts.playfairDisplay(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: headingColor,
        height: 1.3,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: headingColor,
        height: 1.3,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: headingColor,
        height: 1.3,
      ),

      // ── Body — Lora (gazete standardı okunabilirlik) ───────────────────
      bodyLarge: GoogleFonts.lora(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: bodyColor,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.lora(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: bodyColor,
        height: 1.55,
      ),
      bodySmall: GoogleFonts.lora(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: subtleColor,
        height: 1.5,
      ),

      // ── Label — Inter (UI etiketleri) ──────────────────────────────────
      labelLarge: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: bodyColor,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: subtleColor,
        letterSpacing: 0.2,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: subtleColor,
        letterSpacing: 0.3,
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
