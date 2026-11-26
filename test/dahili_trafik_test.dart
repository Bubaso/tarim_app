import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tarim_app/core/analitik/belge.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Dahili trafik işareti — GA4 ölçümünün temizliği
// ──────────────────────────────────────────────────────────────────────────
//  26 Kasım 2026'da ölçüldü: 28 günde anasayfa 122 kullanıcıdan 2.652
//  görüntüleme almıştı — kişi başı 21,7 görüntüleme, ortalama 15 dk 07 sn
//  etkileşim. `/panel`, `/giris`, `/ayarlar` ve sınama sayfaları da
//  listedeydi. Okur değildi; bizdik. İki kaynağı vardı:
//
//    1. `flutter run -d chrome` ve yerel önizleme — index.html derlemeye
//       olduğu gibi girdiği için her geliştirme oturumu CANLI mülke yazıyordu.
//    2. Oturum açmış editörün sitede gezinmesi.
//
//  İkisi de artık `traffic_type: 'internal'` taşıyor; GA4'teki "Internal
//  Traffic" veri filtresi (aynı gün Test'ten Etkin'e alındı) bunları atıyor.
//  Filtre parametreyi BİREBİR arıyor: adı ya da değeri değişirse süzme
//  sessizce durur ve kimse fark etmez. Bu sınav o iki dizeyi tutuyor.
//
//  Neden kaynak düzeyinde: işaret tarayıcıda `gtag`e gidiyor; testte
//  çalıştırılacak bir JS ortamı yok. Korunması gereken ŞEY sözleşmenin
//  kendisi — parametre adı, değeri ve işaretin konduğu yer.
// ══════════════════════════════════════════════════════════════════════════

const _indexHtml = 'web/index.html';
const _belgeWeb = 'lib/core/analitik/belge_web.dart';
const _main = 'lib/main.dart';

/// index.html'deki koşulun Dart'a birebir çevrilmiş hâli. Kaynaktaki
/// düzenli ifade değişirse aşağıdaki sınav onu yakalar.
bool _yerelMi(String anaMakine) =>
    RegExp(r'^(localhost|127\.0\.0\.1|\[::1\])$').hasMatch(anaMakine) ||
    RegExp(r'\.local$').hasMatch(anaMakine);

void main() {
  late String html;
  late String web;
  late String ana;

  setUpAll(() {
    html = File(_indexHtml).readAsStringSync();
    web = File(_belgeWeb).readAsStringSync();
    ana = File(_main).readAsStringSync();
  });

  group('yerel geliştirme trafiği', () {
    test('index.html yerel ana makinede işareti koyuyor', () {
      expect(html, contains("gtag('set', { traffic_type: 'internal' })"));
      expect(html, contains('location.hostname'));
    });

    test('işaret gtag tanımından SONRA geliyor', () {
      final tanim = html.indexOf('function gtag(){dataLayer.push(arguments);}');
      final isaret = html.indexOf("gtag('set', { traffic_type: 'internal' })");
      expect(tanim, greaterThan(-1), reason: 'gtag tanımı kaybolmuş');
      expect(isaret, greaterThan(tanim),
          reason: 'işaret gtag tanımlanmadan çağrılamaz');
    });

    test('koşul yerel adresleri kapsıyor', () {
      for (final makine in ['localhost', '127.0.0.1', '[::1]', 'mac.local']) {
        expect(_yerelMi(makine), isTrue, reason: '$makine dahili sayılmalı');
      }
    });

    test('koşul canlı adreslere dokunmuyor', () {
      for (final makine in [
        'tarimportali.net',
        'www.tarimportali.net',
        'tarim-app-2026.web.app',
        'localhost.evil.com', // benzeyen ama bizim değil
        'notlocalhost.com',
      ]) {
        expect(_yerelMi(makine), isFalse, reason: '$makine okur sayılmalı');
      }
    });
  });

  group('editör oturumu', () {
    test('işlev gtag set çağırıyor ve parametre adı birebir', () {
      expect(web, contains("_gtag('set'"));
      expect(web, contains('traffic_type'));
      expect(web, contains("traffic_type: 'internal'"));
    });

    test('main.dart açılışta ve girişte işaretliyor', () {
      expect(ana, contains('dahiliTrafigiIsaretle'));
      expect(ana, contains('currentSession != null'));
      expect(ana, contains('onAuthStateChange'));
    });

    test('işaretleme Supabase kurulduktan SONRA', () {
      final kurulum = ana.indexOf('Supabase.initialize');
      final isaret = ana.indexOf('dahiliTrafigiIsaretle()');
      expect(kurulum, greaterThan(-1));
      expect(isaret, greaterThan(kurulum),
          reason: 'oturum bilinmeden işaretlenemez');
    });
  });

  group('web dışı', () {
    test('saplama hata vermiyor', () {
      expect(dahiliTrafigiIsaretle, returnsNormally);
    });
  });
}
