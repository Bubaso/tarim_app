import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/home/data/models/news_article.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Açılış mozaiğinin görsellerini bir sonraki açılış için saklar
// ──────────────────────────────────────────────────────────────────────────
//  `web/index.html`deki açılış ekranı, portalın kendi haber görsellerinden
//  kurulu bir mozaik. Veriyi İKİ yerden alabiliyor:
//
//    1. `localStorage` — burası. Uygulama bir kez açıldığında O GÜNÜN
//       haberlerini yazıyor, bir sonraki açılış onu okuyor.
//    2. Derlemeye gömülü yedek (`scripts/ana_sayfa_linkleri.py`) — ilk
//       ziyarette ve burası boşken kullanılıyor.
//
//  NEDEN SUNUCUDAN ÇEKİLMİYOR. "Her açılışta sunucudan taze liste" ilk
//  akla gelen çözümdü ama iki engeli var. Birincisi `homeRenderer`
//  fonksiyonunun kaynağı depoda yok (4 Ekim 2026 kaybı). İkincisi ve
//  asıl olanı: ana sayfa şu an statik olarak CDN kenarından geliyor
//  (TTFB 213 ms ölçüldü); onu bir fonksiyona bağlamak sitenin en çok
//  ziyaret edilen sayfasını yavaşlatırdı. Üstelik mozaiğin ANINDA dolu
//  açılması gerekiyor — bir gidiş-dönüş beklemek ekranın tek iyi
//  özelliğini öldürürdü.
//
//  Bu yolun bedeli: en fazla BİR ziyaret bayat kalıyor. Karşılığında ne
//  fonksiyon ne ek istek var; uygulama veriyi zaten çekiyor.
//
//  ANAHTAR ADI. `shared_preferences` web'de localStorage'a `flutter.`
//  önekiyle yazıyor, yani tarayıcıda görünen ad `flutter.mozaik_kareler`.
//  index.html bu adı arıyor; biri değişirse öteki de değişmeli.
// ══════════════════════════════════════════════════════════════════════════

const String mozaikAnahtari = 'mozaik_kareler';

/// Mozaikte kullanılacak benzersiz görsel sayısı.
///
/// `ana_sayfa_linkleri.py` içindeki `MOZAIK_ADET` ile aynı olmalı: ikisi
/// aynı ekranı besliyor ve farklı sayılar ilk ziyaretle sonrakiler
/// arasında görünür bir yoğunluk farkı yaratırdı.
const int mozaikAdet = 35;

/// Haber listesinden mozaik karelerini çıkarıp saklar.
///
/// Sessizce başarısız oluyor: bu bir yan iş. Yazılamazsa açılış ekranı
/// gömülü yedek setle çalışmaya devam ediyor.
Future<void> mozaigiSakla(List<NewsArticle> haberler) async {
  if (!kIsWeb) return;   // localStorage yalnız web'de bir şey ifade ediyor

  final kareler = <Map<String, String>>[];
  for (final h in haberler) {
    final t = (h.thumbImageUrl ?? '').trim();
    final l = (h.imageLqip ?? '').trim();
    // İKİSİ de zorunlu. LQIP olmadan kare gri bir kutu olarak açılır ve
    // mozaiğin "anında dolu" özelliği kaybolur; thumb olmadan da hiç
    // netleşmez.
    if (t.isEmpty || l.isEmpty) continue;
    kareler.add({'t': t, 'l': l});
    if (kareler.length >= mozaikAdet) break;
  }

  // Az sayıda kare desenin kendini sürekli tekrar etmesine yol açıyor;
  // böyle bir listeyi yazmaktansa gömülü yedek setle kalmak daha iyi.
  if (kareler.length < 12) return;

  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(mozaikAnahtari, jsonEncode(kareler));
  } catch (e) {
    if (kDebugMode) print('mozaigiSakla: $e');
  }
}
