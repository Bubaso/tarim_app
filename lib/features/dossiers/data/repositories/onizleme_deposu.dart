import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/country_dossier.dart';
import 'dossier_repository.dart';

/// Yayımlanmamış bir dosyayı yerelde göstermek için depo.
///
/// NEDEN VAR. Taslak dosya canlıda görülemez: RLS anon'a yalnızca `published`
/// ve `archived` açıyor, taslak sızmasın diye. Ama dosya yayına alınmadan
/// önce gerçek hâliyle — kendi paleti, kendi grafikleri, kendi dizgisiyle —
/// görülebilmeli. Metni ayrı bir HTML'e dökmek bunu vermiyor; dizgi ve
/// grafikler uygulamanın kendi çiziciyle çıkıyor.
///
/// Burada yapılan şey: `seed_dossier.mjs`'nin ürettiği, veritabanına
/// yazılacak satırın AYNISI olan `web/onizleme/<slug>.json` okunuyor ve
/// depo yerine konuyor.
///
/// YAYINA GİDEN YOLA DOKUNMAZ. Yalnızca `--dart-define=DOSYA_ONIZLEME=<slug>`
/// verildiğinde devreye girer; bayrak yoksa `main.dart` bu sınıfı hiç
/// kurmaz. Dağıtım betiği bu bayrağı geçmiyor.
///
///   flutter run -d chrome --dart-define=DOSYA_ONIZLEME=rusya
class OnizlemeDeposu extends DossierRepository {
  /// Önizlenecek dosyanın slug'ı. Yalnızca bu slug yerelden gelir; diğer
  /// bütün dosyalar normal yoldan, veritabanından okunmaya devam eder.
  final String onizlenenSlug;

  OnizlemeDeposu(super.client, this.onizlenenSlug);

  Map<String, dynamic>? _bellek;

  /// Önizleme satırını bir kez okur. Ağ hatası yutulur: önizleme
  /// bulunamazsa uygulama normal davranışına döner, çökmez.
  Future<Map<String, dynamic>?> _oku() async {
    if (_bellek != null) return _bellek;
    try {
      final yanit = await http.get(Uri.parse('/onizleme/$onizlenenSlug.json'));
      if (yanit.statusCode != 200) {
        if (kDebugMode) {
          print('ÖNİZLEME: /onizleme/$onizlenenSlug.json → HTTP ${yanit.statusCode}');
        }
        return null;
      }
      // Görsel adresleri MUTLAK ve üretim sunucusunu gösteriyor (CLAUDE.md
      // §2.4). Yayımlanmamış dosyanın görselleri orada henüz yok, dolayısıyla
      // kapak ve bölüm görselleri boş çıkar. Önizlemede adresler çalışılan
      // köke çevriliyor — GÖRELİ YAPILAMAZ, NewsArticleImage göreli yolu
      // kabul etmiyor; o yüzden mutlak kalıp yalnızca konak değişiyor.
      final metin = utf8
          .decode(yanit.bodyBytes)
          .replaceAll('https://tarim-app-2026.web.app/dosya/',
              '${Uri.base.origin}/dosya/');
      _bellek = jsonDecode(metin) as Map<String, dynamic>;
      if (kDebugMode) {
        final n = (_bellek!['sections'] as List).length;
        print('ÖNİZLEME: $onizlenenSlug yüklendi — $n bölüm');
      }
      return _bellek;
    } catch (e) {
      if (kDebugMode) print('ÖNİZLEME okunamadı: $e');
      return null;
    }
  }

  Future<DossierSummary?> _ozet() async {
    final ham = await _oku();
    if (ham == null) return null;
    return DossierSummary.fromJson(
      (ham['summary'] as Map).cast<String, dynamic>(),
    );
  }

  @override
  Future<CountryDossier?> fetchBySlug(String slug) async {
    if (slug != onizlenenSlug) return super.fetchBySlug(slug);
    final ham = await _oku();
    if (ham == null) return super.fetchBySlug(slug);
    return CountryDossier(
      summary: DossierSummary.fromJson(
        (ham['summary'] as Map).cast<String, dynamic>(),
      ),
      data: (ham['data'] as Map?)?.cast<String, dynamic>() ?? const {},
      charts: CountryDossier.parseCharts(ham['charts']),
      sections: (ham['sections'] as List)
          .map((r) => DossierSection.fromJson((r as Map).cast<String, dynamic>()))
          .toList(),
    );
  }

  /// Ana sayfa şeridi. Önizlenen dosya kendi dizisinin şeridini devralır ki
  /// kart da görülebilsin; öbür dizi olduğu gibi veritabanından gelir.
  @override
  Future<DossierSummary?> fetchActive({String tur = 'ulke'}) async {
    final o = await _ozet();
    if (o == null || o.tur != tur) return super.fetchActive(tur: tur);
    return o;
  }

  /// Arşiv listesi. Önizlenen dosya listenin başına ekleniyor; aynı slug
  /// veritabanında da varsa (yeniden yayın durumu) yerel sürüm onun yerine
  /// geçiyor, iki kez görünmüyor.
  @override
  Future<List<DossierSummary>> fetchIndex({String tur = 'ulke'}) async {
    final liste = await super.fetchIndex(tur: tur);
    final o = await _ozet();
    if (o == null || o.tur != tur) return liste;
    return [o, ...liste.where((d) => d.slug != o.slug)];
  }
}
