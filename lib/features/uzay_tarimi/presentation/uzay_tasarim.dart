import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Uzayda Tarım — dosyanın görsel kimliği.
///
/// ══ SAYFA KOYU, VE UYGULAMAYI İZLEMİYOR ══════════════════════════════════
/// Portalın dosya sayfalarının kuralı: "içeri girdiğinizde başka bir yere
/// geldiğinizi anlamalısınız." Bu dosya için koyu zeminin ikinci ve daha
/// güçlü bir gerekçesi var: anlatının TAMAMI karanlığın içindeki aydınlık
/// kutularda geçiyor. Modül gecesi, yetiştirme odasının mor parıltısı,
/// altında dönen Dünya'nın gece yarısı.
///
/// Pratik sebep de aynı yere çıkıyor. Dosya on beş fotoğraf taşıyacak.
/// Beyaz zeminde on beş fotoğraf bir KATALOG olur; koyu zeminde FİLM olur.
/// Kareler kendi ışığını taşıyor, sayfa onlara yer açıyor.
///
/// ══ İLK SÜRÜM NEDEN ÇÖPE GİTTİ ═══════════════════════════════════════════
/// Bu dosyanın ilk hâli açık zeminde, arayüz yazı tipiyle, görselsiz ve on
/// bölümü de veri bileşeni olan bir sayfaydı. Okur bir dosya değil bir
/// DENETİM RAPORU buluyordu: her bölüm bir sayı ve onun şerhiydi.
/// Araştırmanın kendisi sağlamdı; hata, doğrulama aygıtını sahneye
/// koymaktı. Aygıt artık zeminde — şerhler sayfanın sonundaki panelde,
/// anlatının içinde değil.
///
/// ══ RENGİN KAYNAĞI ═══════════════════════════════════════════════════════
/// "Uzay = lacivert + yıldız" klişesi kullanılmadı. Renkler konunun kendi
/// maddesinden: Veggie ve Advanced Plant Habitat odalarının kırmızı+mavi
/// LED'leri birleşince çıkan MOR ışık. Uzayda yetişen her bitkinin
/// fotoğrafındaki o pembe parıltı. Zemin istasyon içinin nötr karanlığı,
/// ikinci renk yaprağın kendisi.
class UzayRenk {
  const UzayRenk._();

  /// Modül karanlığı — mor meyilli, nötr siyah değil. Saf siyah fotoğrafın
  /// kenarını keser; bu zemin kareyi içine alır.
  static const zemin = Color(0xFF0C0A10);

  /// Yüzey: alıntı, panel, kart. Zeminden bir adım yukarıda.
  static const yuzey = Color(0xFF17141E);

  /// Gövde metni. Saf beyaz değil — koyu zeminde saf beyaz titreşiyor.
  static const metin = Color(0xFFF4F0F7);

  /// Künye, altyazı, meta.
  static const ikincil = Color(0xFFA69FB0);

  /// Ayırıcı ve kenarlık.
  static const cizgi = Color(0xFF2A2533);

  /// LED moru. Üstbaşlık ve küçük işaretler — GENİŞ ALANDA KULLANILMAZ.
  /// İlk sürümde her yerdeydi ve sayfayı bir arayüze çeviriyordu.
  static const led = Color(0xFFE86FBE);

  /// Yaprak. Bitkiye ait olan şey.
  static const yaprak = Color(0xFF8ACB55);
}

/// Okuma oluğu. 19 punto serifte 65-70 karakter eder.
///
/// Metin bunun üstüne ÇIKMAZ. Görsel çıkar — kare metinden geniştir ve bu
/// bilerek: dergi dosyasında fotoğraf sütunu kırar.
const double uzayOluk = 680;

/// Görselin oluğu. Metinden geniş, sayfadan dar.
const double uzayGorselOluk = 1000;

class UzayKirilma {
  const UzayKirilma._();

  static const dar = 700.0;

  static bool darMi(double g) => g < dar;
}

/// Tipografi.
///
/// GÖVDE SERİF. İlk sürüm Inter kullanıyordu — bir arayüz yazı tipi — ve
/// metin otomatik olarak "ekran metni" gibi okunuyordu. Portalın dosya
/// sayfaları Source Serif 4 ile okunuyor; bu dosya da öyle. Serif uzun
/// metinde satır takibini kolaylaştırıyor ve sayfaya belge ağırlığı
/// veriyor.
///
/// BAŞLIKLAR OUTFIT. Portalın kendi gösterim yazı tipi; palet sayfayı
/// ayırırken yazı tipi onu portala bağlıyor.
class UzayYazi {
  const UzayYazi._();

  static bool _dar(BuildContext c) =>
      MediaQuery.sizeOf(c).width < UzayKirilma.dar;

  /// Kapak başlığı.
  static TextStyle manset(BuildContext c) => GoogleFonts.outfit(
        fontSize: _dar(c) ? 38 : 68,
        height: 1.04,
        fontWeight: FontWeight.w600,
        letterSpacing: -1.2,
        color: UzayRenk.metin,
      );

  /// Bölüm başlığı.
  static TextStyle bolumBasligi(BuildContext c) => GoogleFonts.outfit(
        fontSize: _dar(c) ? 27 : 40,
        height: 1.12,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.7,
        color: UzayRenk.metin,
      );

  /// Tez cümlesi — kapakta, gövdeden büyük.
  static TextStyle tez(BuildContext c) => GoogleFonts.sourceSerif4(
        fontSize: _dar(c) ? 19 : 24,
        height: 1.55,
        color: UzayRenk.metin,
      );

  /// Okunan metin. Satır yüksekliği cömert — "nefes alabilecekleri" bir
  /// sayfanın ilk şartı boşluk.
  static TextStyle govde(BuildContext c) => GoogleFonts.sourceSerif4(
        fontSize: _dar(c) ? 17.5 : 19,
        height: 1.78,
        color: UzayRenk.metin.withValues(alpha: 0.92),
      );

  /// Üstbaşlık: tarih ya da yer. Sahnenin çapası.
  static TextStyle ustbaslik(BuildContext c) => GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.2,
        color: UzayRenk.led,
      );

  /// Görsel altyazısı ve künye.
  static TextStyle kunye(BuildContext c) => GoogleFonts.inter(
        fontSize: 12.5,
        height: 1.5,
        color: UzayRenk.ikincil,
      );
}
