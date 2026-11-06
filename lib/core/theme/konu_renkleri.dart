import 'package:flutter/material.dart';

import 'app_colors.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Konu renkleri — portalın TEK renk dili
// ──────────────────────────────────────────────────────────────────────────
//  NEDEN TEK DOSYA. 6 Kasım 2026 denetimi (Ö7): portalda iki ayrı taksonomi
//  var ve ikisi de ayrı renk kullanıyordu.
//
//    · HABER konuları  — Bitkisel Üretim, Hayvancılık, Ekonomi, Tarım-Bilim.
//      Kısa Kısa bölümündeki `kisaKonuRengi` bunları boyuyordu.
//    · HİKÂYE kategorileri — Piyasa, Hasat, Destekleme, İhracat, Su & İklim,
//      Gıda, Teknoloji, Politika, Dünya. Hiçbiri renklenmiyordu.
//
//  İki kümenin ortak tek üyesi "Hayvancılık". Aynı portalda iki ayrı renk
//  dili olması sistemin parça parça büyüdüğünü ele veriyor.
//
//  RENK TEK BAŞINA TAŞIYICI DEĞİL. On üç ayrı kategoriye gerçekten ayırt
//  edilebilir on üç renk bulmak mümkün değil; komşu tonlar kaçınılmaz.
//  Bu yüzden renk her yerde YAZIYLA birlikte kullanılıyor (şeritte etiket,
//  çipte kategori adı, ilerleme çubuğunun altında başlık) ve hiçbir yerde
//  tek ayırt edici işaret değil. Renk körü okur için de, düşük kontrastlı
//  ekranda da bilgi kaybı olmuyor.
//
//  YAKIN DURANLAR BİLEREK EŞLEŞTİRİLDİ. "Piyasa" ile "Ekonomi" aynı altını
//  paylaşıyor çünkü aynı alanın iki adı; "Hasat" ile "Bitkisel Üretim" aynı
//  yeşili paylaşıyor. Zorlama bir ayrım yapmaktansa akrabalığı göstermek
//  daha doğru.
//
//  AÇIK/KOYU AYRI SEÇİLDİ. Koyu temada aynı ton kaybolur; her kategorinin
//  iki değeri var ve koyu tarafta doygunluk düşürülüp parlaklık artırıldı.
// ══════════════════════════════════════════════════════════════════════════

@immutable
class _KonuTonu {
  final Color acik;
  final Color koyu;
  const _KonuTonu(this.acik, this.koyu);
}

const _KonuTonu _notr = _KonuTonu(Color(0xFF7A6E60), Color(0xFF9E9384));

/// Kategori adı → ton. Anahtarlar hattın yazdığı adlarla BİREBİR.
const Map<String, _KonuTonu> _tonlar = {
  // ── Ekonomi ailesi: altın ────────────────────────────────────────────
  'Piyasa': _KonuTonu(Color(0xFF9A7224), Color(0xFFDCBB79)),
  'Ekonomi': _KonuTonu(Color(0xFF9A7224), Color(0xFFDCBB79)),

  // ── Üretim ailesi: yeşil ─────────────────────────────────────────────
  'Hasat': _KonuTonu(Color(0xFF5C8A4A), Color(0xFF7FB069)),
  'Bitkisel Üretim': _KonuTonu(Color(0xFF5C8A4A), Color(0xFF7FB069)),

  // ── Tek başına duranlar ──────────────────────────────────────────────
  // Açık ton AppColors.marketDown ile aynı: Kısa Kısa bölümü bu rengi
  // zaten kullanıyordu ve yeni sistem oradaki görüntüyü DEĞİŞTİRMEMELİ.
  'Hayvancılık': _KonuTonu(AppColors.marketDown, Color(0xFFC97B63)),
  'Su & İklim': _KonuTonu(Color(0xFF2C6E8F), Color(0xFF7FC4D9)),
  'Gıda': _KonuTonu(Color(0xFF9C3B28), Color(0xFFE8907A)),
  'Destekleme': _KonuTonu(Color(0xFF3B4C8A), Color(0xFF94A3DC)),
  'İhracat': _KonuTonu(Color(0xFF1F6F60), Color(0xFF7FC4B4)),
  'Teknoloji': _KonuTonu(Color(0xFF6B4A8A), Color(0xFFB49AD6)),
  'Politika': _KonuTonu(Color(0xFF4A5568), Color(0xFFA0AEC0)),
  'Dünya': _KonuTonu(Color(0xFF6B4A2E), Color(0xFFC4A48F)),

  // ── Bilim ─────────────────────────────────────────────────────────────
  'Tarım-Bilim': _KonuTonu(Color(0xFF2F6B60), Color(0xFF8FBFB4)),
  'YYT': _KonuTonu(Color(0xFF2F6B60), Color(0xFF8FBFB4)),

  // ── Dosyalar: portalın kendi koyu yeşili ─────────────────────────────
  // Sabit hikâyeler; şeritte zaten ayrı bir muamele görüyorlar.
  'Ülke Dosyası': _KonuTonu(Color(0xFF2F4B2E), Color(0xFFA7C49A)),
  'Kurum Dosyası': _KonuTonu(Color(0xFF2F4B2E), Color(0xFFA7C49A)),
};

/// Konunun rengi. Tanınmayan konu nötr toprak tonuna düşüyor.
///
/// Tanınmayan konuya RASTGELE renk ÜRETİLMİYOR: hat yarın yeni bir kategori
/// eklerse o kategori her açılışta başka renkte görünürdü. Nötr ton,
/// "bu kategori henüz sisteme girmedi" demenin dürüst yolu.
Color konuRengi(String? konu, bool isDark) {
  final ton = _tonlar[konu?.trim()] ?? _notr;
  return isDark ? ton.koyu : ton.acik;
}

/// Konunun BİLİNİP bilinmediği — sınama ve denetim için.
bool konuTaniniyor(String? konu) => _tonlar.containsKey(konu?.trim());

/// Sistemin tanıdığı bütün konular.
Iterable<String> get tanimliKonular => _tonlar.keys;

/// Koyu fotoğraf üzerine basılan çip için ton.
///
/// Şerit ve kart renkleri kâğıt zemine göre seçildi; hikâye çipi ise tam
/// ekran bir fotoğrafın üstünde duruyor ve oradaki zemin her kareyi
/// değiştiriyor. Açık tonu kullanmak çipi fotoğrafın içinde kaybediyor.
/// Koyu temanın parlak tonu burada her zaman doğru: altında koyulaştırma
/// perdesi var.
Color konuCipRengi(String? konu) => konuRengi(konu, true);

/// Çipin üstündeki yazının rengi — parlak tonlar üzerinde koyu mürekkep.
const Color konuCipMurekkebi = AppColors.darkGreen;
