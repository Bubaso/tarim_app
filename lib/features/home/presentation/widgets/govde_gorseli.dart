import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../../core/utils/image_fallback_helper.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  Gövde görseli — `<img>` etiketi DEVRALINIYOR (CLAUDE.md §31)
// ──────────────────────────────────────────────────────────────────────────────
//  `flutter_html` 3.0.0'ın yerleşik `<img>` çizicisi stilin BİRİMİNİ OKUMUYOR,
//  yalnızca sayısını veriyor (`image_builtin.dart`):
//
//      width:  imageStyle.width?.value    // Width(100, Unit.percent) → 100 px
//      height: imageStyle.height?.value   // Height.auto()            → 0 px
//
//  Yani `"img": Style(width: Width(100, Unit.percent), height: Height.auto())`
//  orada "100 piksel genişlik, SIFIR piksel yükseklik" oluyor. Görsel iniyor,
//  satır kutusu yer ayırıyor, hiçbir piksel boyanmıyor. Hata vermiyor; panel
//  "başarılı" diyor, veritabanında adres duruyor, adres tarayıcıda açılıyor —
//  yalnızca sayfada görünmüyor.
//
//  Yüzdeyi düzeltmek YETMEZDİ: eklenti hiçbir birimi okumuyor, dolayısıyla
//  duyarlı bir genişlik o yoldan verilemiyor. Etiket tamamen devralındı.
//
//  Kullanıcı eklentileri yerleşiklerden ÖNCE deneniyor (`html_parser.dart`),
//  yani bu eklenti varken `ImageBuiltIn` hiç çalışmıyor. `htmlStyle`daki
//  `"img"` girdisi bu yüzden KALDIRILDI — geri konursa hiçbir işe yaramaz,
//  yalnızca yanıltır.
// ══════════════════════════════════════════════════════════════════════════════

/// Gövdedeki görsel adının karşılaştırma biçimi.
///
/// Adresler birebir aynı olmayabiliyor: dönüştürme uç noktası sorgu
/// parametresi ekliyor (`?width=...`) ve kapak bazen `/render/image/`,
/// gövde `/object/` yolundan geliyor. Karşılaştırma bu yüzden DOSYA ADI
/// üzerinden yapılıyor.
String _dosyaAdi(String url) {
  final q = url.split('?').first;
  final p = q.split('/');
  return p.isEmpty ? q : p.last.toLowerCase();
}

class GovdeGorseli extends HtmlExtension {
  /// Haberin KAPAK görseli. Gövdede aynısı geçiyorsa ÇİZİLMİYOR.
  ///
  /// Kaynak sayfadan alınan gövdede açılış görseli çoğu zaman metnin de
  /// içinde duruyor ve kapak olarak zaten yukarıda gösteriliyor. Aynı
  /// fotoğrafı iki kez göstermek okura hata gibi görünüyor.
  ///
  /// Bu kusur eklenti geri yazılana kadar GİZLİYDİ: yerleşik çizici gövde
  /// görsellerini 100×0 pikselde çiziyordu, yani tekrar da görünmüyordu
  /// (§31.2). Görsel düzelince tekrar ortaya çıktı.
  final String? kapakUrl;

  const GovdeGorseli({this.kapakUrl});

  @override
  Set<String> get supportedTags => {'img'};

  @override
  InlineSpan build(ExtensionContext context) {
    final src = context.attributes['src']?.trim() ?? '';
    if (src.isEmpty) return const TextSpan(text: '');
    final alt = context.attributes['alt']?.trim() ?? '';

    final kapak = kapakUrl?.trim() ?? '';
    if (kapak.isNotEmpty && _dosyaAdi(kapak) == _dosyaAdi(src)) {
      return const TextSpan(text: '');
    }

    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: LayoutBuilder(
        builder: (context, kisit) {
          // Genişlik EKRANI AŞAMAZ (§39.4). Paragrafın kısıtı telefonda da
          // okuma oluğu kadar (800) geliyor; yalnızca ona uyulsaydı görsel
          // 375 piksellik ekranın dışına taşıp iki yandan kırpılırdı —
          // masaüstünde görünmeyen bir kusur.
          final ekran = MediaQuery.of(context).size.width;
          final en = kisit.maxWidth.isFinite
              ? (kisit.maxWidth < ekran ? kisit.maxWidth : ekran)
              : ekran;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: en,
                // ORANI BİLMİYORUZ: gövde görselinin en/boy bilgisi
                // veritabanında yok. §8.14.3'ün kuralı: oranını BİLDİĞİMİZ
                // görselin tamamını göster, BİLMEDİĞİMİZ görselde kutuyu
                // doldur. Sınırsız yükseklikte `contain` denendi ve
                // yerleşim hatası veriyor — WidgetSpan içinde dikey kısıt
                // yok.
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: NewsArticleImage(
                    imageUrl: src,
                    fit: BoxFit.cover,
                    semanticLabel: alt.isEmpty ? null : alt,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
