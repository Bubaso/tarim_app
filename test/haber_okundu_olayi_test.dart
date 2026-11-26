import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tarim_app/core/analitik/belge.dart';

// ══════════════════════════════════════════════════════════════════════════
//  "haber_okundu" olayı — Google Ads dönüşümünün kaynağı
// ──────────────────────────────────────────────────────────────────────────
//  Google Ads'in gördüğü dönüşüm bu olaya bağlı. Olay YANLIŞ YERDEN
//  çıkarsa hiçbir şey görünürde bozulmaz: reklam paneli dönüşüm saymaya
//  devam eder, ama saydığı şey okuma değil açılma olur. Haftalık bütçenin
//  dörtte üçü "mazot fiyatları"na gidiyor ve o paranın karşılığını tam da
//  bu sayı ile değerlendiriyoruz.
//
//  Olayın çıkması gereken yer `_maybeCountRead`, hem de iki koşul (gövdenin
//  yarısı + 10 saniye) ve editör elemesi geçildikten SONRA.
//
//  Neden kaynak düzeyinde sınav: ArticleDetailScreen'i widget testinde
//  kurmak Supabase oturumu, sağlayıcılar ve Html ayrıştırıcısı istiyor;
//  aynı ailedeki author_article_detail_test bu yüzden zaten düşüyor.
//  Buradaki sınav, korunması gereken ŞEYİ koruyor.
// ══════════════════════════════════════════════════════════════════════════

const _ekran =
    'lib/features/home/presentation/screens/article_detail_screen.dart';

void main() {
  late String kaynak;

  setUpAll(() {
    kaynak = File(_ekran).readAsStringSync();
  });

  group('olayın yeri', () {
    test('olay _maybeCountRead içinde', () {
      final bas = kaynak.indexOf('void _maybeCountRead()');
      expect(bas, greaterThan(-1), reason: '_maybeCountRead kaybolmuş');
      final son = kaynak.indexOf('void _updateProgress()', bas);
      expect(son, greaterThan(bas));
      final govde = kaynak.substring(bas, son);

      expect(govde, contains("analitikOlay('haber_okundu'"));
      expect(govde, contains("dataLayerOlayi('haber_okundu')"));
    });

    test('olay initState içinde DEĞİL', () {
      final bas = kaynak.indexOf('void initState()');
      final son = kaynak.indexOf('void _maybeCountRead()', bas);
      final govde = kaynak.substring(bas, son);
      expect(govde, isNot(contains('haber_okundu')),
          reason: 'olay açılışa taşınmış: dönüşüm okumayı değil açılmayı '
              'saymaya başlar ve bu dışarıdan fark edilmez');
    });

    test('iki eşik de yerinde', () {
      expect(kaynak, contains('_readThreshold = 0.5'),
          reason: 'gövdenin yarısı koşulu');
      expect(kaynak, contains('_readDwell = Duration(seconds: 10)'),
          reason: 'ekranda kalma koşulu');
      // Her ikisi de _maybeCountRead'in erken çıkışlarında kullanılmalı.
      final bas = kaynak.indexOf('void _maybeCountRead()');
      final son = kaynak.indexOf('void _updateProgress()', bas);
      final govde = kaynak.substring(bas, son);
      expect(govde, contains('_progress.value < _readThreshold'));
      expect(govde, contains('< _readDwell'));
    });

    test('editör elemesi olaydan ÖNCE', () {
      final bas = kaynak.indexOf('void _maybeCountRead()');
      final son = kaynak.indexOf('void _updateProgress()', bas);
      final govde = kaynak.substring(bas, son);
      final eleme = govde.indexOf('currentSession != null');
      final olay = govde.indexOf("dataLayerOlayi('haber_okundu')");
      expect(eleme, greaterThan(-1), reason: 'editör elemesi kaybolmuş');
      expect(eleme, lessThan(olay),
          reason: 'panelden bakan editörün okuması reklam dönüşümü sayılmamalı');
    });
  });

  group('dataLayerOlayi', () {
    test('web dışında etkisiz ve hata vermiyor', () {
      // Testler web değil: stub çalışıyor. Çağrı sessizce yutulmalı, yoksa
      // her widget testi bu satırda patlardı.
      expect(() => dataLayerOlayi('haber_okundu'), returnsNormally);
    });
  });

  group('ölçüm kapısı', () {
    test('web uygulaması dataLayer kuyruğunu oluşturuyor', () {
      // `dataLayerOlayi` var olan kuyruğa yazıyor, kendisi yaratmıyor.
      // Kuyruk index.html'deki Google etiketiyle geliyor; o blok silinirse
      // olay sessizce kaybolur.
      final html = File('web/index.html').readAsStringSync();
      expect(html, contains('window.dataLayer = window.dataLayer || []'));
      expect(html, contains('googletagmanager.com/gtm.js'));
    });
  });
}
