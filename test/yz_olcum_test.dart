import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarim_app/core/analitik/analitik.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_olcum_gonderici.dart';

/// Madde 24: bölümün ince ölçüm göndericisi.
void main() {
  final olaylar = <(String, Map<String, Object>)>[];

  setUp(() {
    olaylar.clear();
    yzOlcumTestAyari();
    yzOlcumDinleyici = (o, p) => olaylar.add((o, p));
    sayfaGecisiOldu = true; // site içi geçiş: süre kronometreden
  });

  tearDown(() {
    yzOlcumDinleyici = null;
    analitikDinleyici = null;
    sayfaGecisiOldu = false;
    yzOlcumTestAyari();
  });

  group('gönderici', () {
    test('Firebase başlatılmamışken hata vermeden yutar', () {
      expect(() => yzOlcum('yz_sonraki_tik', {'sayfa': 'tarihce'}), returnsNormally);
      expect(olaylar.single.$1, 'yz_sonraki_tik');
    });

    test('ölçüm kapısı da Firebase yokken sessiz', () {
      final kapida = <String>[];
      analitikDinleyici = (o, _) => kapida.add(o);
      expect(analitikOrnegi(), isNull);
      expect(() => analitikOlay('page_view', {'page_location': '/'}), returnsNormally);
      expect(kapida, ['page_view']);
    });

    test('dinleyici hata fırlatsa bile çağıran düşmez', () {
      yzOlcumDinleyici = (_, __) => throw StateError('x');
      expect(() => yzOlcum('yz_haber_tik', {'yer': 'son'}), returnsNormally);
    });

    test('kişisel veri anahtarları reddedilir', () {
      yzOlcum('yz_okuma_adimi', {
        'adim': 'y50',
        'sayfa': 'sulama-ve-su',
        'email': 'a@b.co',
        'e_posta': 'x',
        'telefon': '555',
        'user_id': 'u1',
        'kullanici': 'k',
        'q': 'domates',
        'arama_sorgusu': 'domates',
        'search_term': 'tomato',
        'terim': 'NDVI',
        'ip': '1.2.3.4',
        'konum': '41,33',
        'ad_soyad': 'X Y',
      });
      final p = olaylar.single.$2;
      expect(p.keys.toSet(), {'adim', 'sayfa'});
    });

    test('benzer ama zararsız anahtarlar geçer', () {
      yzOlcum('yz_okuma_adimi', {
        'adim': 'y25',
        'sayfa_turu': 'baslik',
        'bolum_sira': 3,
        'bolum_sayisi': 7,
        'giris': 'arama', // DEĞER olarak "arama" girişi anlatır, sözcük değil
        'yazi_olcegi': 1.15,
        'tip': 'x',
      });
      expect(olaylar.single.$2.keys,
          containsAll(['adim', 'sayfa_turu', 'bolum_sira', 'bolum_sayisi', 'giris', 'yazi_olcegi', 'tip']));
    });

    test('değerler metin ya da sayıya çevrilir, 100 karaktere kırpılır', () {
      yzOlcum('yz_okuma_cikis', {
        'hizli': true,
        'uzun': 'ç' * 250,
        'liste': const ['a', 'b'],
        'sonsuz': double.infinity,
        'bos': '',
        'eposta_degeri': 'yaz: okur@ornek.com',
      });
      final p = olaylar.single.$2;
      expect(p['hizli'], 1);
      expect((p['uzun'] as String).length, 100);
      expect(p['liste'], '[a, b]');
      expect(p.containsKey('sonsuz'), isFalse);
      expect(p.containsKey('bos'), isFalse);
      expect(p.containsKey('eposta_degeri'), isFalse);
    });

    test('geçersiz olay adı gönderilmez; en çok 25 parametre', () {
      yzOlcum('firebase_x', {'a': 1});
      yzOlcum('1yanlis', {'a': 1});
      yzOlcum('bosluklu ad', {'a': 1});
      expect(olaylar, isEmpty);
      yzOlcum('yz_cok', {for (var i = 0; i < 40; i++) 'p$i': i});
      expect(olaylar.single.$2.length, 25);
    });
  });

  group('açılış hızı', () {
    test('kovalar', () {
      expect(yzHizKovasi(0), '<1');
      expect(yzHizKovasi(999), '<1');
      expect(yzHizKovasi(1000), '1-2');
      expect(yzHizKovasi(1999), '1-2');
      expect(yzHizKovasi(2000), '2-4');
      expect(yzHizKovasi(3999), '2-4');
      expect(yzHizKovasi(4000), '>4');
    });

    test('acildi ilk metin karesini bekler ve kovasıyla gider', () {
      var saat = 10000;
      yzOlcumTestAyari(saat: () => saat);
      yzOlcumAcilisBaslat();
      yzOlcum('yz_okuma_adimi', {'adim': 'acildi', 'sayfa': 'tarihce'});
      expect(olaylar, isEmpty, reason: 'kare çizilmeden gitmez');
      saat += 2500;
      yzOlcumKareCizildi();
      expect(olaylar.single.$2['ilk_kare'], '2-4');
      // Aynı açılışta ikinci acildi kovasız (kova bir kez).
      yzOlcum('yz_okuma_adimi', {'adim': 'acildi', 'sayfa': 'tarihce'});
      expect(olaylar.last.$2.containsKey('ilk_kare'), isFalse);
    });

    test('kare önce çizildiyse acildi hemen, kovasıyla gider', () {
      var saat = 0;
      yzOlcumTestAyari(saat: () => saat);
      yzOlcumAcilisBaslat();
      saat = 400;
      yzOlcumKareCizildi();
      yzOlcum('yz_okuma_adimi', {'adim': 'acildi'});
      expect(olaylar.single.$2['ilk_kare'], '<1');
    });

    test('öteki adımlar beklemez', () {
      yzOlcumAcilisBaslat();
      yzOlcum('yz_okuma_adimi', {'adim': 'y25'});
      yzOlcum('yz_serit_tik', {'sira': 1});
      expect(olaylar, hasLength(2));
    });

    test('yeni açılış, bekleyen acildi\'yi kovasız gönderir', () {
      yzOlcumAcilisBaslat();
      yzOlcum('yz_okuma_adimi', {'adim': 'acildi'});
      yzOlcumAcilisBaslat();
      expect(olaylar.single.$2.containsKey('ilk_kare'), isFalse);
    });

    testWidgets('ilk metin karesi gerçek karede ölçülür', (tester) async {
      var saat = 0;
      yzOlcumTestAyari(saat: () => saat);
      yzOlcumAcilisBaslat();
      yzOlcum('yz_okuma_adimi', {'adim': 'acildi'});
      saat = 1500;
      await tester.pumpWidget(Builder(builder: (_) {
        yzOlcumIlkMetinKaresi();
        yzOlcumIlkMetinKaresi(); // yeniden kurulum sayılmaz
        return const SizedBox();
      }));
      expect(olaylar.single.$2['ilk_kare'], '1-2');
    });
  });

  test('gönderici hafif: bölümün ağır dosyalarını içe aktarmıyor', () {
    final kaynak = File('lib/features/yapay_zeka/presentation/yz_olcum_gonderici.dart')
        .readAsStringSync();
    final aktarimlar = RegExp(r"^import '([^']+)';", multiLine: true)
        .allMatches(kaynak)
        .map((m) => m.group(1))
        .toSet();
    expect(aktarimlar, {
      'package:flutter/foundation.dart',
      'package:flutter/scheduler.dart',
      '../../../core/analitik/analitik.dart',
      '../../../core/analitik/belge.dart',
    });
  });
}
