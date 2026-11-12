import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/tni_model.dart';

/// Bu sayfanın KENDİ tasarım dili.
///
/// NEDEN AYRI BİR PALET. Ülke ve kurum dosyaları kâğıt: krem zemin, toprak
/// mürekkep, serif gövde — okunacak bir metin. Bu sayfa metin değil, bir
/// GÖSTERGE PANOSU: bir taahhüdün nerede durduğunu gösteriyor. Kullanıcı
/// "gözle görünür derecede farklı" istedi; fark süsten değil işten geliyor.
/// Zemin derin turkuaz-mürekkep, tipografi geometrik, tarihler ve rakamlar
/// eşit genişlikli — ölçü aleti sözlüğü.
///
/// Adın gerekçesi aranıp BULUNAMADIĞI için turkuaz burada yalnız bir tasarım
/// tercihi; sayfa adın anlamına dair hiçbir iddia kurmuyor.
///
/// RENKLER SINANDI. `content/dossiers/_ortak/kontrast.py` ile ölçüldü; her
/// metin rengi kendi zemininde en az 4.5, çizgiler 3.0 üstünde. İki renk
/// ölçüm yüzünden değişti: gece `su` koyu yüzeyde 4.03 veriyordu (#3A7FD5 →
/// #4D8FE0), gündüz `askida` zeminde 4.25 veriyordu (#9A6B12 → #8A5F0D).
class TniRenk {
  const TniRenk._();

  // ── Gece ────────────────────────────────────────────────────────────────
  static const geceZemin = Color(0xFF04171A);
  static const geceYuzey = Color(0xFF0A2328);
  static const geceMetin = Color(0xFFE4F1F0);
  static const geceIkincil = Color(0xFF8CB0B2);
  static const geceCizgi = Color(0x1FFFFFFF);

  // ── Gündüz ──────────────────────────────────────────────────────────────
  static const gunZemin = Color(0xFFF0F5F4);
  static const gunYuzey = Color(0xFFFFFFFF);
  static const gunMetin = Color(0xFF0B2024);
  static const gunIkincil = Color(0xFF4C6B6E);
  static const gunCizgi = Color(0x1A0B2024);

  // ── Üç alan ─────────────────────────────────────────────────────────────
  // Girişimin birleştirmeye çalıştığı üç politika çerçevesi. Renkler
  // boşluğun haritasında ve takipçide aynı anlamı taşıyor.
  static const geceSu = Color(0xFF4D8FE0);
  static const geceTarim = Color(0xFF79AC46);
  static const geceIklim = Color(0xFF14B2A2);
  static const gunSu = Color(0xFF2A5FA6);
  static const gunTarim = Color(0xFF55792F);
  static const gunIklim = Color(0xFF0B7A6F);

  // ── Askıda ──────────────────────────────────────────────────────────────
  // "Çıktısı yayımlanmadı" ve "henüz bilinmiyor" aynı rengi paylaşıyor,
  // çünkü ikisi aynı şeyi söylüyor: burada bir boşluk var.
  static const geceAskida = Color(0xFFD69A2E);
  static const gunAskida = Color(0xFF8A5F0D);

  static Color zemin(bool k) => k ? geceZemin : gunZemin;
  static Color yuzey(bool k) => k ? geceYuzey : gunYuzey;
  static Color metin(bool k) => k ? geceMetin : gunMetin;
  static Color ikincil(bool k) => k ? geceIkincil : gunIkincil;
  static Color cizgi(bool k) => k ? geceCizgi : gunCizgi;
  static Color su(bool k) => k ? geceSu : gunSu;
  static Color tarim(bool k) => k ? geceTarim : gunTarim;
  static Color iklim(bool k) => k ? geceIklim : gunIklim;
  static Color askida(bool k) => k ? geceAskida : gunAskida;
}

/// Durumun ÜÇ AYRI işareti var: renk, simge ve dolgu.
///
/// Tek başına renk yetmez — renk körlüğü, güneş altındaki telefon, gri baskı.
/// Takipçinin bütün anlamı "oldu / askıda / bekliyor" ayrımında olduğu için
/// bu ayrımın tek bir kanala bırakılması kabul edilemez.
class TniDurumGorunumu {
  final Color renk;
  final IconData simge;
  final String etiketTr;
  final String etiketEn;

  /// Dolgu: olmuş halka DOLU, askıda olan ÇİZGİLİ, bekleyen BOŞ.
  final bool dolu;
  final bool kesikli;

  const TniDurumGorunumu({
    required this.renk,
    required this.simge,
    required this.etiketTr,
    required this.etiketEn,
    required this.dolu,
    required this.kesikli,
  });

  String etiket(bool isEn) => isEn ? etiketEn : etiketTr;

  static TniDurumGorunumu of(HalkaDurumu d, bool karanlik) => switch (d) {
        HalkaDurumu.gerceklesti => TniDurumGorunumu(
            renk: TniRenk.iklim(karanlik),
            simge: Icons.check_rounded,
            etiketTr: 'OLDU',
            etiketEn: 'HAPPENED',
            dolu: true,
            kesikli: false,
          ),
        HalkaDurumu.ciktisiYayimlanmadi => TniDurumGorunumu(
            renk: TniRenk.askida(karanlik),
            simge: Icons.priority_high_rounded,
            etiketTr: 'SONUÇ DUYURULMADI',
            etiketEn: 'NO OUTCOME ANNOUNCED',
            dolu: false,
            kesikli: true,
          ),
        HalkaDurumu.bekliyor => TniDurumGorunumu(
            renk: TniRenk.ikincil(karanlik),
            simge: Icons.schedule_rounded,
            etiketTr: 'BEKLENİYOR',
            etiketEn: 'EXPECTED',
            dolu: false,
            kesikli: false,
          ),
      };
}

/// Tipografi. Üç rol, üç aile:
///   gosterge  Outfit     — başlıklar, geometrik, dosyaların serifine karşıt
///   govde     Inter      — okunacak metin
///   olcu      RobotoMono — tarih, rakam, etiket; eşit genişlikli rakam şart,
///                          çünkü takipçide sayılar sütun hâlinde hizalanıyor
class TniYazi {
  const TniYazi._();

  static TextStyle gosterge({
    required double punto,
    required Color renk,
    FontWeight kalinlik = FontWeight.w700,
    double? aralik,
    double? satir,
  }) =>
      GoogleFonts.outfit(
        fontSize: punto,
        color: renk,
        fontWeight: kalinlik,
        letterSpacing: aralik,
        height: satir,
      );

  static TextStyle govde({
    required double punto,
    required Color renk,
    FontWeight kalinlik = FontWeight.w400,
    double satir = 1.55,
  }) =>
      GoogleFonts.inter(
        fontSize: punto,
        color: renk,
        fontWeight: kalinlik,
        height: satir,
      );

  static TextStyle olcu({
    required double punto,
    required Color renk,
    FontWeight kalinlik = FontWeight.w500,
    double aralik = 0.6,
  }) =>
      GoogleFonts.robotoMono(
        fontSize: punto,
        color: renk,
        fontWeight: kalinlik,
        letterSpacing: aralik,
      );
}

/// Tarihi OLDUĞU KADAR kesin yazar.
///
/// Halkaların tarihi üç hassasiyette geliyor: `2030`, `2022-11`, `2026-11-10`.
/// Üçünü de güne indirip "1 Ocak 2030" yazmak uydurma bir kesinlik olurdu —
/// belge yalnızca "By 2030" diyor.
String tniTarihYaz(String ham, bool isEn) {
  final aylarTr = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
  ];
  final aylarEn = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  final p = ham.split('-');
  final yil = p[0];
  if (p.length == 1) return isEn ? 'By $yil' : '$yil\'a kadar';
  final ay = int.tryParse(p[1]) ?? 1;
  final adi = (isEn ? aylarEn : aylarTr)[(ay - 1).clamp(0, 11)];
  if (p.length == 2) return isEn ? '$adi $yil' : '$adi $yil';
  final gun = int.tryParse(p[2]) ?? 1;
  return isEn ? '$gun $adi $yil' : '$gun $adi $yil';
}

/// Sayfanın her yerinde aynı yatay kenar boşluğu.
double tniKenar(double genislik) {
  if (genislik < 520) return 18;
  if (genislik < 900) return 28;
  return 40;
}

/// Gövde genişliği tavanı — satır 65 karakteri aşmasın.
const double tniOkumaTavani = 720;
const double tniPanoTavani = 1140;
