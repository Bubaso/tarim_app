import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_erteli.dart';

/// Bölüm ERTELİ pakette (bkz. lib/features/yapay_zeka/presentation/
/// yz_ekranlar.dart). 18 Kasım 2026'da açılış derlemesi deploy.sh'in ağırlık
/// bekçisine takıldı: bölümün metinleri ilk yükteydi ve sitenin her sayfası
/// onları indiriyordu (main.dart.js 2,28 MB, tavan 1,8 MB).

/// [baslangic]tan erteli OLMAYAN içe/dışa aktarımlarla ulaşılan depo
/// dosyaları (lib/ altındaki göreli yollar).
Set<String> ilkYukKapanisi(String baslangic) {
  final aktarim = RegExp(r"^\s*(import|export|part)\s+'([^']+)'([^;]*);", multiLine: true);
  final gorulen = <String>{};
  final kuyruk = <String>[baslangic];
  while (kuyruk.isNotEmpty) {
    final yol = kuyruk.removeLast();
    if (!gorulen.add(yol)) continue;
    final dosya = File(yol);
    if (!dosya.existsSync()) continue;
    final dizin = dosya.parent.uri;
    for (final m in aktarim.allMatches(dosya.readAsStringSync())) {
      final kuyrugu = m.group(3)!;
      if (RegExp(r'\bdeferred\b').hasMatch(kuyrugu)) continue;
      // Koşullu aktarımın öbür adayları da (`if (dart.library.x) '...'`).
      final hedefler = [m.group(2)!, ...RegExp(r"'([^']+)'").allMatches(kuyrugu).map((x) => x.group(1)!)];
      for (final h in hedefler) {
        if (h.startsWith('dart:')) continue;
        String? cozulen;
        if (h.startsWith('package:tarim_app/')) {
          cozulen = 'lib/${h.substring('package:tarim_app/'.length)}';
        } else if (!h.startsWith('package:')) {
          cozulen = Directory.current.uri
              .resolveUri(dizin.resolve(h))
              .toFilePath()
              .replaceFirst('${Directory.current.path}/', '');
        }
        if (cozulen != null) kuyruk.add(cozulen);
      }
    }
  }
  return gorulen;
}

const _agir = [
  'lib/features/yapay_zeka/data/yz_metinler.g.dart',
  'lib/features/yapay_zeka/data/yz_rakam_kaynaklari.g.dart',
  // Kaynak karnesi: yalnız erteli ekranlardan (yz_makale.dart, yz_matris.dart).
  'lib/features/yapay_zeka/data/yz_kaynak_karnesi.g.dart',
  'lib/features/yapay_zeka/presentation/yz_kaynak_karnesi.dart',
  'lib/features/yapay_zeka/data/yz_grafikler.g.dart',
  'lib/features/yapay_zeka/data/yz_teknoloji.g.dart',
  'lib/features/yapay_zeka/data/yz_sozluk.g.dart',
  'lib/features/yapay_zeka/presentation/yz_parcalar.dart',
  'lib/features/yapay_zeka/presentation/yz_metin_gorunumu.dart',
  'lib/features/yapay_zeka/presentation/yz_ekranlar.dart',
  // Türkiye Dijital Tarım Atlası (atlas turu): ızgara ve kayıtlar yalnız erteli.
  'lib/features/yapay_zeka/data/yz_atlas.g.dart',
  'lib/features/yapay_zeka/presentation/yz_atlas_veri.dart',
  'lib/features/yapay_zeka/presentation/yz_atlas_ekrani.dart',
  // "Uzaydan bugün" canlı uydu penceresi: yalnız bölüm metninin çizicisinden.
  'lib/features/yapay_zeka/presentation/yz_uzaydan_bugun.dart',
  // Rakamın makbuzu: sayfa ve kesit tablosu ile tam ekran görüntüleyici
  // yalnız erteli (balondan; yz_gorsel_tam_ekran.dart ilk yükte, ona ek yok).
  'lib/features/yapay_zeka/data/yz_makbuz.g.dart',
  'lib/features/yapay_zeka/presentation/yz_makbuz.dart',
  // Sahadan galerisi: kareler, galeri ve merkez kartı, tam ekran görüntüleyici
  // yalnız erteli (yz_gorsel_tam_ekran.dart ilk yükte, ona ek yok).
  'lib/features/yapay_zeka/data/yz_sahadan.g.dart',
  'lib/features/yapay_zeka/presentation/yz_sahadan_ekrani.dart',
  'lib/features/yapay_zeka/presentation/yz_sahadan_tam_ekran.dart',
];

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  group('erteli paket', () {
    test('ilk yükten bölümün ağır dosyalarına erteli olmayan yol yok', () {
      final ilk = ilkYukKapanisi('lib/main.dart');
      // Tarama gerçekten yürüyor mu: yönlendirici ve ana sayfa şeridi ilk yükte.
      expect(ilk, contains('lib/core/router/app_router.dart'));
      expect(ilk, contains('lib/features/yapay_zeka/presentation/yz_seridi.dart'));
      expect(ilk, contains('lib/features/yapay_zeka/data/yz_iskelet.g.dart'));
      for (final a in _agir) {
        expect(ilk, isNot(contains(a)),
            reason: '$a ilk yüke girmiş: sitenin her sayfası bölümü indirir. '
                'Bölümün ekranları yalnız yz_ekranlar.dart üzerinden, erteli.');
      }
    });

    test('erteli giriş bölümün bütün ekranlarına ve verisine ulaşıyor', () {
      final erteli = ilkYukKapanisi('lib/features/yapay_zeka/presentation/yz_ekranlar.dart');
      for (final a in _agir) {
        expect(erteli, contains(a), reason: a);
      }
    });

    test('yönlendirici bölümü yalnız erteli giriş üzerinden alıyor', () {
      final r = File('lib/core/router/app_router.dart').readAsStringSync();
      expect(r, matches(RegExp(r"import '[^']*yz_ekranlar\.dart'\s+deferred as yz_ekranlar;")));
      expect(r, isNot(contains('yz_baslik_ekrani.dart')));
      expect(r, isNot(contains('yz_merkez_ekrani.dart')));
      expect('yz_ekranlar.loadLibrary()'.allMatches(r).length, 6,
          reason: 'merkez, arama, teknoloji, atlas, sahadan, başlık');
      expect(r, isNot(contains('yz_atlas_ekrani.dart')));
      expect(r, isNot(contains('yz_sahadan_ekrani.dart')));
    });
  });

  group('YzErteliSayfa', () {
    // Bölümün dili okurun yerel ayarından (yzIsEn); okur Türkçe.
    Widget sar(Widget w) => MaterialApp(
          locale: const Locale('tr'),
          supportedLocales: const [Locale('tr'), Locale('en')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: w,
        );

    testWidgets('yavaş indirmede gösterge 400 ms sonra; inince ekran, ikinci girişte bekleme yok',
        (t) async {
      YzErteliSayfa.testIcinSifirla();
      final c = Completer<void>();
      await t.pumpWidget(sar(YzErteliSayfa(yukle: () => c.future, kur: () => const Text('EKRAN'))));
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await t.pump(const Duration(milliseconds: 450));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      c.complete();
      await t.pump();
      expect(find.text('EKRAN'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      var cagri = 0;
      await t.pumpWidget(sar(YzErteliSayfa(
          yukle: () async => cagri++, kur: () => const Text('İKİNCİ'))));
      expect(find.text('İKİNCİ'), findsOneWidget, reason: 'aynı karede, beklemeden');
      expect(cagri, 0);
    });

    testWidgets('paket ve yazı tipleri birlikte bekleniyor; ikinci girişte yazı tipi beklenmiyor (madde 16)',
        (t) async {
      YzErteliSayfa.testIcinSifirla(yaziTipleri: true);
      final paket = Completer<void>();
      final yazi = Completer<void>();
      var yaziCagri = 0;
      Future<void> yaziTipleri() {
        yaziCagri++;
        return yazi.future;
      }

      await t.pumpWidget(sar(YzErteliSayfa(
          yukle: () => paket.future, kur: () => const Text('EKRAN'), yaziTipleri: yaziTipleri)));
      expect(yaziCagri, 1, reason: 'paketle aynı anda isteniyor');
      paket.complete();
      await t.pump();
      expect(find.text('EKRAN'), findsNothing, reason: 'yazı tipi gelmeden metin yedek yazıyla çizilmiyor');
      yazi.complete();
      await t.pump();
      await t.pump();
      expect(find.text('EKRAN'), findsOneWidget);

      // Yazı tipi hata verirse sayfa yine açılıyor.
      YzErteliSayfa.testIcinSifirla(yaziTipleri: true);
      await t.pumpWidget(sar(YzErteliSayfa(
          key: const ValueKey(2),
          yukle: () => paket.future,
          kur: () => const Text('EKRAN'),
          yaziTipleri: () async => throw 'x')));
      await t.pump();
      await t.pump();
      expect(find.text('EKRAN'), findsOneWidget, reason: 'yazı tipi hatası sayfayı durdurmuyor');
    });

    testWidgets('yazı tipi beklemesi üst sınırda bitiyor, hata yakalanıyor', (t) async {
      await t.runAsync(() async {
        final sw = Stopwatch()..start();
        await yzYaziTipleriniBekle(azami: const Duration(milliseconds: 100));
        expect(sw.elapsedMilliseconds, lessThan(1000));
      });
    });

    test('üst sınır 1.200 ms; firebase.json\'a dokunulmadı', () {
      final s = File('lib/features/yapay_zeka/presentation/yz_erteli.dart').readAsStringSync();
      expect(s, contains('Duration(milliseconds: 1200)'));
      expect(s, contains('GoogleFonts.pendingFonts()'));
    });

    testWidgets('indirme düşerse söylüyor; yeniden dene ekranı kuruyor', (t) async {
      YzErteliSayfa.testIcinSifirla();
      var deneme = 0;
      await t.pumpWidget(sar(YzErteliSayfa(
          yukle: () async {
            deneme++;
            if (deneme == 1) throw Exception('ağ');
          },
          kur: () => const Text('EKRAN'))));
      await t.pump();
      expect(find.text('Sayfa yüklenemedi. Bağlantınızı denetleyip yeniden deneyin.'), findsOneWidget);
      await t.tap(find.text('Yeniden dene'));
      await t.pump();
      await t.pump();
      expect(find.text('EKRAN'), findsOneWidget);
      expect(deneme, 2);
    });
  });
}
