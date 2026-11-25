import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarim_app/core/utils/erteli_sayfa.dart';

import 'yz_erteli_test.dart' show ilkYukKapanisi;

// ══════════════════════════════════════════════════════════════════════════
//  ErteliSayfa
// ──────────────────────────────────────────────────────────────────────────
//  Ayrı pakette duran bir ekranı indiren bekleme sayfası. Sınavların işi,
//  okurun bu sayfayı MÜMKÜN OLDUĞUNCA AZ görmesini güvence altına almak:
//  hızlı bağlantıda hiç, ikinci girişte hiç, düşen indirmede ise boş ekran
//  yerine bir cümle ve bir düğme.
// ══════════════════════════════════════════════════════════════════════════
void main() {
  Widget sar(Widget w) => MaterialApp(
        locale: const Locale('tr'),
        supportedLocales: const [Locale('tr'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: w,
      );

  setUp(ErteliSayfa.testIcinSifirla);

  testWidgets('gösterge 400 ms sonra beliriyor; paket inince ekran çiziliyor',
      (t) async {
    final c = Completer<void>();
    await t.pumpWidget(sar(ErteliSayfa(
      kimlik: 'a',
      yukle: () => c.future,
      kur: () => const Text('EKRAN'),
    )));
    expect(find.byType(CircularProgressIndicator), findsNothing,
        reason: 'hızlı bağlantıda okur hiçbir şey görmemeli');
    await t.pump(const Duration(milliseconds: 450));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    c.complete();
    await t.pump();
    expect(find.text('EKRAN'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('aynı paket ikinci girişte beklenmiyor', (t) async {
    await t.pumpWidget(sar(ErteliSayfa(
      kimlik: 'a',
      yukle: () async {},
      kur: () => const Text('BİR'),
    )));
    await t.pump();

    var cagri = 0;
    await t.pumpWidget(sar(ErteliSayfa(
      kimlik: 'a',
      yukle: () async => cagri++,
      kur: () => const Text('İKİ'),
    )));
    expect(find.text('İKİ'), findsOneWidget, reason: 'aynı karede, beklemeden');
    expect(cagri, 0);
  });

  testWidgets('başka paket kendi indirmesini bekliyor', (t) async {
    // Tek bir statik bayrak olsaydı bu paket inmiş sayılır ve HİÇ İNMEMİŞ
    // bir kütüphanenin ekranı kurulmaya çalışılırdı.
    await t.pumpWidget(sar(ErteliSayfa(
      kimlik: 'a',
      yukle: () async {},
      kur: () => const Text('A'),
    )));
    await t.pump();

    final c = Completer<void>();
    await t.pumpWidget(sar(ErteliSayfa(
      key: const ValueKey('b'),
      kimlik: 'b',
      yukle: () => c.future,
      kur: () => const Text('B'),
    )));
    await t.pump();
    expect(find.text('B'), findsNothing);
    c.complete();
    await t.pump();
    await t.pump();
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('indirme düşerse söylüyor; yeniden dene ekranı kuruyor',
      (t) async {
    var deneme = 0;
    await t.pumpWidget(sar(ErteliSayfa(
      kimlik: 'a',
      yukle: () async {
        deneme++;
        if (deneme == 1) throw Exception('ağ');
      },
      kur: () => const Text('EKRAN'),
    )));
    await t.pump();
    expect(
        find.text('Sayfa yüklenemedi. Bağlantınızı denetleyip yeniden deneyin.'),
        findsOneWidget);
    await t.tap(find.text('Yeniden dene'));
    await t.pump();
    await t.pump();
    expect(find.text('EKRAN'), findsOneWidget);
    expect(deneme, 2);
  });

  // ════════════════════════════════════════════════════════════════════
  //  Uzayda Tarım — erteli paket
  // ────────────────────────────────────────────────────────────────────
  //  Bölümün veri katmanı 322 KB kaynak (`uzay_veri.g.dart` 143 KB,
  //  `uzay_akis.g.dart` 27 KB). 25 Kasım 2026'da ağırlık bekçisi ilk yükü
  //  tavanın 2.882 bayt üstünde buldu; yer buradan açıldı ve ilk yük
  //  1.832.882 → 1.804.939 bayta indi.
  //
  //  Ana sayfa şeridi ilk yükte KALIYOR; sızma riski şeritten geliyor:
  //  oraya ekranı ya da `uzay_veri.g.dart`ı alan bir `import` eklenirse
  //  322 KB geri döner ve hiçbir şey görünürde bozulmaz.
  // ════════════════════════════════════════════════════════════════════
  group('uzay bölümü erteli', () {
    const ekran = 'lib/features/uzay_tarimi/presentation/screens/uzay_ekrani.dart';
    const veri = 'lib/features/uzay_tarimi/data/uzay_veri.g.dart';
    const akis = 'lib/features/uzay_tarimi/data/uzay_akis.g.dart';
    const serit = 'lib/features/uzay_tarimi/presentation/widgets/uzay_seridi.dart';
    const duraklar = 'lib/features/uzay_tarimi/data/uzay_duraklar.g.dart';
    const yonlendirici = 'lib/core/router/app_router.dart';

    test('ilk yükten bölümün veri katmanına erteli olmayan yol yok', () {
      final ilk = ilkYukKapanisi('lib/main.dart');
      // Tarama yürüyor mu: şerit ve onun verisi ilk yükte KALMALI.
      expect(ilk, contains(serit));
      expect(ilk, contains(duraklar));
      expect(ilk, isNot(contains(ekran)),
          reason: 'uzay ekranı ilk yüke girmiş: portalın her sayfası bölümün '
              '322 KB veri katmanını indirir.');
      expect(ilk, isNot(contains(veri)));
      expect(ilk, isNot(contains(akis)));
    });

    test('yönlendirici bölümü yalnız erteli giriş üzerinden alıyor', () {
      final r = File(yonlendirici).readAsStringSync();
      expect(
          r,
          matches(RegExp(
              r"import '[^']*uzay_ekrani\.dart'\s*\n?\s*deferred as uzay_ekran;")));
      expect(r, contains('uzay_ekran.loadLibrary()'));
      expect(r, contains('uzay_ekran.uzayEkrani()'));
      // Erteli kütüphanenin tipi ilk yükte kullanılamaz: anılırsa derleme
      // değil, ÇALIŞMA ânı patlar.
      expect(r, isNot(contains('const UzayEkrani()')));
    });

    test('erteli giriş bölümün veri katmanına ulaşıyor', () {
      final erteli = ilkYukKapanisi(ekran);
      expect(erteli, contains(veri));
      expect(erteli, contains(akis));
    });
  });
}
