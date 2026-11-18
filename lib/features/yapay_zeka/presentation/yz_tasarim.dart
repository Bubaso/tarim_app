import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Yapay Zeka ve Dijital Tarım — bölümün görsel dili (karar 42-45).
///
/// ══ AÇIK ZEMİN ═══════════════════════════════════════════════════════════
/// Dizide ilk kez (karar 42): ülke ve kurum dosyaları koyu, bu bölüm açık.
/// Zemin saf beyaz değil; klorofile hafifçe eğilen bir kâğıt grisi. Kartlar
/// onun üstünde beyaz duruyor, gölgeyle değil saç çizgisiyle ayrılıyor.
///
/// ══ "MAKİNE VE BİTKİ" (karar 43) ═════════════════════════════════════════
/// İki renk, iki ses. Çelik mavisi makinenin: ölçüm, ızgara, düğme, rakam.
/// Klorofil yeşili bitkinin: yazılmış başlık, haber akışı, canlı olan.
/// Mürekkep grafit — siyah değil, yeşile eğilen bir koyu. Bekleyen
/// (yazılmamış başlık, yayımlanmamış belge) toprağın hardal tonunda.
///
/// ══ YAZI ═════════════════════════════════════════════════════════════════
/// Başlıklar Outfit — site kuralı (CLAUDE.md §36). Gövde Newsreader: uzun
/// okuma için optik boyutlu bir serif. Künyeler, etiketler ve grafik
/// değerleri IBM Plex Mono. Metindeki ölçülmüş sayı gövdenin kendi rakamıyla,
/// tam boy ve çelik mavisiyle (karar 60, kullanıcının seçimi): okur ölçülmüş
/// olanı renkten ayırt ediyor, cümlenin ritmi bölünmüyor.
class YzRenk {
  YzRenk._();
  static const zemin = Color(0xFFF3F5F1);
  static const yuzey = Color(0xFFFFFFFF);
  static const murekkep = Color(0xFF1D2321);
  static const soluk = Color(0xFF5C6662);
  static const cizgi = Color(0xFFD5DBD4);
  static const makine = Color(0xFF34507A);
  static const makineAcik = Color(0xFFE3E9F2);
  static const bitki = Color(0xFF3E7B3A);
  static const bitkiAcik = Color(0xFFE4EFE1);

  /// Bekleyen — çizgi ve simgede. Metinde [bekleyenMetin] (4,5:1 üstü).
  static const bekleyen = Color(0xFFA97C2F);
  static const bekleyenMetin = Color(0xFF7A5A1F);
}

class YzYazi {
  YzYazi._();

  static TextStyle baslik(double boy, {Color renk = YzRenk.murekkep}) =>
      GoogleFonts.outfit(
        fontSize: boy,
        fontWeight: FontWeight.w700,
        height: 1.14,
        letterSpacing: boy > 28 ? -0.6 : -0.2,
        color: renk,
      );

  static TextStyle govde({double boy = 18, Color renk = YzRenk.murekkep}) =>
      GoogleFonts.newsreader(fontSize: boy, height: 1.62, color: renk);

  /// Rakam, tarih, § numarası, künye.
  static TextStyle veri({
    double boy = 12.5,
    Color renk = YzRenk.soluk,
    FontWeight kalinlik = FontWeight.w500,
  }) =>
      GoogleFonts.ibmPlexMono(
        fontSize: boy,
        color: renk,
        fontWeight: kalinlik,
        letterSpacing: 0.2,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Büyük harfli üst etiket — biraz açık aralıkla.
  static TextStyle ustEtiket({Color renk = YzRenk.soluk}) =>
      GoogleFonts.ibmPlexMono(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
        color: renk,
      );
}

/// VERİ-TARLA IZGARASI (karar 44).
///
/// Tarlanın ekim sıraları — hafif eğik, ince, yeşil — ve üstüne binen
/// veri ızgarası — dik, çelik mavisi. İkisi aynı zemini paylaşıyor; bölümün
/// konusu da tam olarak bu: tarlanın düzeninin üstüne bir hesap katmanı.
///
/// Süs olarak değil zemin olarak kullanılıyor: alfa düşük, metnin
/// okunurluğuna dokunmuyor. [solma] sağdan sola solduruyor ki metin
/// tarafı temiz kalsın.
class TarlaIzgarasi extends CustomPainter {
  const TarlaIzgarasi({
    this.siraAraligi = 13,
    this.izgaraAraligi = 52,
    this.aci = -0.32,
    this.solma = true,
    this.yogunluk = 1,
  });

  final double siraAraligi;
  final double izgaraAraligi;

  /// Ekim sıralarının eğimi (radyan).
  final double aci;
  final bool solma;
  final double yogunluk;

  @override
  void paint(Canvas canvas, Size size) {
    final alan = Offset.zero & size;
    canvas.save();
    canvas.clipRect(alan);

    // ── ekim sıraları ──
    final sira = Paint()
      ..color = YzRenk.bitki.withValues(alpha: 0.16 * yogunluk)
      ..strokeWidth = 1.1;
    final kosegen = math.sqrt(size.width * size.width + size.height * size.height);
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(aci);
    for (double y = -kosegen; y <= kosegen; y += siraAraligi) {
      canvas.drawLine(Offset(-kosegen, y), Offset(kosegen, y), sira);
    }
    canvas.restore();

    // ── veri ızgarası ──
    final izgara = Paint()
      ..color = YzRenk.makine.withValues(alpha: 0.13 * yogunluk)
      ..strokeWidth = 1;
    for (double x = izgaraAraligi; x < size.width; x += izgaraAraligi) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), izgara);
    }
    for (double y = izgaraAraligi; y < size.height; y += izgaraAraligi) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), izgara);
    }
    // Izgara düğümleri: ölçüm noktaları.
    final dugum = Paint()..color = YzRenk.makine.withValues(alpha: 0.32 * yogunluk);
    for (double x = izgaraAraligi; x < size.width; x += izgaraAraligi) {
      for (double y = izgaraAraligi; y < size.height; y += izgaraAraligi) {
        canvas.drawCircle(Offset(x, y), 1.4, dugum);
      }
    }

    // ── metin tarafı temiz kalsın ──
    if (solma) {
      final ortu = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [YzRenk.zemin, YzRenk.zemin.withValues(alpha: 0.0)],
          stops: const [0.28, 0.82],
        ).createShader(alan);
      canvas.drawRect(alan, ortu);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant TarlaIzgarasi eski) =>
      eski.siraAraligi != siraAraligi ||
      eski.izgaraAraligi != izgaraAraligi ||
      eski.aci != aci ||
      eski.solma != solma ||
      eski.yogunluk != yogunluk;
}

/// Tarih "2026-11-16" → "16 Kasım 2026" / "16 November 2026".
String yzTarih(String iso, bool isEn) {
  final t = DateTime.tryParse(iso);
  if (t == null) return iso;
  const tr = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz',
    'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
  const en = ['January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December'];
  return '${t.day} ${(isEn ? en : tr)[t.month - 1]} ${t.year}';
}
