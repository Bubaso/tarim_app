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

class GovdeGorseli extends HtmlExtension {
  const GovdeGorseli();

  @override
  Set<String> get supportedTags => {'img'};

  @override
  InlineSpan build(ExtensionContext context) {
    final src = context.attributes['src']?.trim() ?? '';
    if (src.isEmpty) return const TextSpan(text: '');
    final alt = context.attributes['alt']?.trim() ?? '';

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
