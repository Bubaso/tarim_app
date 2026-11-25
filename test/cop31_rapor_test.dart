import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/features/home/data/cop31_rapor_verisi.dart';
import 'package:tarim_app/features/home/data/models/news_article.dart';
import 'package:tarim_app/features/home/presentation/screens/cop31_rapor_ekrani.dart';
import 'package:tarim_app/features/home/presentation/widgets/portal_sections/cop31_rapor_seridi.dart';
import 'package:tarim_app/features/home/providers/home_providers.dart';

import 'yz_erteli_test.dart' show ilkYukKapanisi;

// ══════════════════════════════════════════════════════════════════════════
//  COP31 Değerlendirme Raporu
// ──────────────────────────────────────────────────────────────────────────
//  Raporun tek vaadi var: sayfadaki her cümlenin arkasında yayımlanmış bir
//  haber ya da adı görünen bir dış kaynak olacak.
//
//  Bu vaat gözle denetlenemez. Sayfa dolu görünür, cümleler düzgün okunur ve
//  dayanağı silinmiş bir iddia aralarında fark edilmeden durur. Buradaki
//  sınavların asıl işi o sessiz hâli yakalamak.
// ══════════════════════════════════════════════════════════════════════════

NewsArticle _h(String id, String baslik) => NewsArticle(
      id: id,
      title: baslik,
      content: 'Gövde metni burada duruyor.',
      createdAt: DateTime(2026, 11, 23, 10),
      status: 'published',
      topic: 'Genel',
      imageUrl: 'https://x/i.jpg',
    );

/// Hükmün ilk cümlesinin dayandığı haber.
final _hukumHaberi = kRaporHukmu.first;

Widget _ekran(List<NewsArticle> liste, {DateTime? simdi}) => ProviderScope(
      overrides: [
        cop31RaporAkisiProvider.overrideWith((ref) => Stream.value(liste)),
        simdiProvider.overrideWithValue(() => simdi ?? DateTime(2026, 11, 26)),
      ],
      child: const MaterialApp(home: Cop31RaporEkrani()),
    );

Widget _serit(List<NewsArticle> liste, DateTime simdi) => ProviderScope(
      overrides: [
        cop31RaporAkisiProvider.overrideWith((ref) => Stream.value(liste)),
        simdiProvider.overrideWithValue(() => simdi),
      ],
      child: MaterialApp(
        home: Scaffold(body: Cop31RaporSeridi(isDark: false, spacing: 28)),
      ),
    );

Future<void> _ciz(WidgetTester tester, Widget w) async {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(w);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  group('veri bütünlüğü', () {
    // Kimlikler elle yazılmadı, veritabanından çözüldü — ama dosya elle
    // düzenlenebilir. Bozuk bir kimlik sayfada sessizce kaybolan bir satır
    // demek: kimse hata görmez, yalnız iddia eksilir.
    final hepsi = [
      ...kRaporHukmu, ...kAlinanKararlar, ...kAlinamayanlar, ...kTarimPayi,
    ];

    test('her satırın metni ve dayanağı var', () {
      expect(hepsi, isNotEmpty);
      for (final s in hepsi) {
        expect(s.metin.trim(), isNotEmpty, reason: 'boş metin');
        expect(s.haberId.trim(), isNotEmpty, reason: '"${s.metin}" dayanaksız');
      }
    });

    test('kimlikler UUID biçiminde', () {
      final uuid = RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$');
      for (final s in [...hepsi.map((e) => e.haberId),
                       ...kRaporRakamlari.map((e) => e.haberId)]) {
        expect(uuid.hasMatch(s), isTrue, reason: 'bozuk kimlik: $s');
      }
    });

    test('her rakamın değeri, etiketi ve dayanağı var', () {
      expect(kRaporRakamlari, isNotEmpty);
      for (final r in kRaporRakamlari) {
        expect(r.deger.trim(), isNotEmpty);
        expect(r.etiket.trim(), isNotEmpty);
        expect(r.haberId.trim(), isNotEmpty);
      }
    });

    test('dış kaynaklı her bilginin KAYNAĞI yazılı', () {
      // Dış bilgi, portal haberine dayanmayan tek satır türü. Kaynağı
      // görünmezse okur onu da bizim haberimiz sanır.
      for (final d in kRaporSirada) {
        expect(d.metin.trim(), isNotEmpty);
        expect(d.kaynak.trim(), isNotEmpty, reason: '"${d.metin}" kaynaksız');
      }
    });
  });

  group('tarih kapısı', () {
    // Kapı 30 Kasım'dan 5 ARALIK'a taşındı (kullanıcı, 25 Kasım 2026).
    //
    // Bu kapı YALNIZ ANASAYFA KARTINI kapatıyor. Sayfanın kendisi üst
    // çubuktaki COP31 düğmesinden açılmaya devam ediyor; o düğmenin tarih
    // kapısı yok (bkz. category_nav_bar.dart).
    test('4 Aralık\'ta açık', () {
      expect(raporAktif(DateTime(2026, 11, 30)), isTrue,
          reason: 'eski kapı buydu, artık kapanmıyor');
      expect(raporAktif(DateTime(2026, 12, 4, 23, 59)), isTrue);
    });

    test('5 Aralık\'ta kapalı', () {
      expect(raporAktif(DateTime(2026, 12, 5)), isFalse);
      expect(raporAktif(DateTime(2026, 12, 6)), isFalse);
    });

    testWidgets('kapalıyken şerit hiç çizilmiyor', (tester) async {
      await _ciz(tester, _serit([_h(_hukumHaberi.haberId, 'Başlık')],
          DateTime(2026, 12, 5)));
      expect(find.textContaining('COP31'), findsNothing);
    });

    testWidgets('arşiv boşken şerit hiç çizilmiyor', (tester) async {
      // Okuru boş bir rapora göndermemek için.
      await _ciz(tester, _serit(const [], DateTime(2026, 11, 26)));
      expect(find.textContaining('COP31'), findsNothing);
    });

    testWidgets('açıkken ve arşiv doluyken şerit çiziliyor', (tester) async {
      await _ciz(tester, _serit([_h(_hukumHaberi.haberId, 'Başlık')],
          DateTime(2026, 11, 26)));
      expect(find.text('Raporu aç'), findsOneWidget);
    });
  });

  group('dayanaksız satır çizilmiyor', () {
    testWidgets('dayanak haber yayındayken cümle görünüyor', (tester) async {
      await _ciz(tester,
          _ekran([_h(_hukumHaberi.haberId, 'Dayanak haberin başlığı')]));
      expect(find.text(_hukumHaberi.metin), findsOneWidget);
      // Künyesi de görünüyor: okur neye dayandığını okumadan tıklamasın.
      expect(find.textContaining('Dayanak haberin başlığı'), findsWidgets);
    });

    testWidgets('dayanak haber yayında DEĞİLSE cümle hiç çizilmiyor',
        (tester) async {
      // Arşivde başka haberler var ama bu iddianın dayanağı yok.
      await _ciz(tester, _ekran([
        _h('11111111-1111-4111-8111-111111111111', 'Alakasız bir haber'),
      ]));
      expect(find.text(_hukumHaberi.metin), findsNothing,
          reason: 'Dayanağı olmayan iddia sayfada kaldı.');
    });

    testWidgets('hiçbir dayanak yoksa sayfa açılıyor ama iddia taşımıyor',
        (tester) async {
      await _ciz(tester, _ekran(const []));
      expect(find.text('COP31 Değerlendirme'), findsOneWidget);
      for (final s in [...kRaporHukmu, ...kAlinanKararlar, ...kAlinamayanlar]) {
        expect(find.text(s.metin), findsNothing);
      }
    });
  });

  // ════════════════════════════════════════════════════════════════════
  //  Erteli paket
  // ────────────────────────────────────────────────────────────────────
  //  Sayfa beş gün yayında ve okurun küçük bir bölümü açıyor; ilk yükte
  //  kalsaydı portalın HER sayfası onu indirirdi. 25 Kasım 2026'da
  //  deploy.sh'in ağırlık bekçisi tam bunu yakaladı: main.dart.js
  //  1.838.608 bayt, tavan 1.830.000. Bekçinin kendi notu tavanı
  //  yükseltmeyi yasaklıyor.
  //
  //  Buradaki sınav, sayfanın ilk yüke SESSİZCE geri sızmasını yakalıyor:
  //  şeride ya da başka bir ilk yük dosyasına erteli olmayan tek bir
  //  `import` yeter, hiçbir şey görünürde bozulmaz ve ağırlık geri gelir.
  // ════════════════════════════════════════════════════════════════════
  group('erteli paket', () {
    const ekran = 'lib/features/home/presentation/screens/cop31_rapor_ekrani.dart';
    const veri = 'lib/features/home/data/cop31_rapor_verisi.dart';
    const serit =
        'lib/features/home/presentation/widgets/portal_sections/cop31_rapor_seridi.dart';

    test('ilk yükten rapor sayfasına erteli olmayan yol yok', () {
      final ilk = ilkYukKapanisi('lib/main.dart');
      // Tarama gerçekten yürüyor mu: şerit ve sağlayıcıları ilk yükte.
      expect(ilk, contains(serit));
      expect(ilk, contains('lib/features/home/providers/home_providers.dart'));
      expect(ilk, isNot(contains(ekran)),
          reason: 'rapor ekranı ilk yüke girmiş: portalın her sayfası onu '
              'indirir. Şerit ekranı yalnız `deferred as` ile almalı.');
      expect(ilk, isNot(contains(veri)), reason: 'rapor verisi ilk yüke girmiş');
    });

    test('şerit ekranı yalnız erteli giriş üzerinden alıyor', () {
      final k = File(serit).readAsStringSync();
      expect(
          k,
          matches(RegExp(
              r"import '[^']*cop31_rapor_ekrani\.dart'\s+deferred as cop31_rapor;")));
      expect(k, contains('cop31_rapor.loadLibrary()'));
      expect(k, contains('cop31_rapor.raporEkrani()'));
      // Erteli kütüphanenin tipi ilk yükte kullanılamaz: anılırsa derleme
      // değil, ÇALIŞMA ânı patlar.
      expect(k, isNot(contains('const Cop31RaporEkrani()')));
    });

    test('erteli giriş sayfanın tamamına ve verisine ulaşıyor', () {
      final erteli = ilkYukKapanisi(ekran);
      expect(erteli, contains(veri));
    });
  });

  // ════════════════════════════════════════════════════════════════════
  //  Üst çubuktaki COP31 düğmesi
  // ────────────────────────────────────────────────────────────────────
  //  Rapor kartı 5 Aralık'ta anasayfadan kalkıyor. O tarihten sonra sayfaya
  //  giden TEK yol üst çubuktaki düğme. Düğme yeniden bir tarih kapısına
  //  bağlanırsa sayfa sessizce erişilemez olur — görünürde hiçbir şey
  //  bozulmaz, kimse fark etmez.
  // ════════════════════════════════════════════════════════════════════
  group('üst çubuk düğmesi', () {
    const cubuk =
        'lib/features/home/presentation/widgets/category_nav_bar.dart';

    test('düğmenin tarih kapısı yok', () {
      final k = File(cubuk).readAsStringSync();
      expect(k, isNot(contains('ozelBolumAktif')),
          reason: 'düğme yeniden bölümün tarih kapısına bağlanmış: rapor '
              '5 Aralık\'tan sonra erişilemez olurdu');
      expect(k, isNot(contains('cop31Goster')));
      expect(k, contains('_Cop31Dugmesi'));
    });

    test('düğme raporu ERTELİ paketten açıyor', () {
      final k = File(cubuk).readAsStringSync();
      expect(
          k,
          matches(RegExp(
              r"import '[^']*cop31_rapor_ekrani\.dart'\s+deferred as cop31_rapor;")),
          reason: 'çubuk portalın HER sayfasında çiziliyor; erteli olmazsa '
              'rapor sayfası ilk yüke girer');
      expect(k, contains('cop31_rapor.loadLibrary()'));
      expect(k, contains('cop31_rapor.raporEkrani()'));
    });
  });

  // ════════════════════════════════════════════════════════════════════
  //  Arşiv gün gün
  // ────────────────────────────────────────────────────────────────────
  //  Düz liste 54 satır aynı ritimde akıyordu. Gün başlıkları ve değişen
  //  kart boyutları o düzlüğü kırıyor; burada aranan şey gün başlığının
  //  gerçekten çizildiği ve günlerin yeniden eskiye sıralandığı.
  // ════════════════════════════════════════════════════════════════════
  group('arşiv gün gün', () {
    NewsArticle gunluk(String id, String baslik, DateTime t, int puan) =>
        NewsArticle(
          id: id,
          title: baslik,
          content: 'Gövde.',
          createdAt: t,
          status: 'published',
          topic: 'Genel',
          imageUrl: 'https://x/i.jpg',
          heroScore: puan,
        );

    testWidgets('gün başlıkları çiziliyor ve yeniden eskiye sıralı',
        (tester) async {
      await _ciz(
          tester,
          _ekran([
            gunluk('a1', 'Yirmi üçün küçüğü', DateTime(2026, 11, 23, 9), 10),
            gunluk('a2', 'Yirmi üçün büyüğü', DateTime(2026, 11, 23, 18), 90),
            gunluk('a3', 'Yirmi birin haberi', DateTime(2026, 11, 21, 12), 50),
          ]));

      expect(find.text('23 Kasım'), findsOneWidget);
      expect(find.text('21 Kasım'), findsOneWidget);
      expect(find.text('Pazartesi'), findsOneWidget); // 23 Kasım 2026
      expect(find.text('2 haber'), findsOneWidget);
      expect(find.text('1 haber'), findsOneWidget);

      // Yeni gün önce: 23 Kasım, 21 Kasım'ın yukarısında.
      final y23 = tester.getTopLeft(find.text('23 Kasım')).dy;
      final y21 = tester.getTopLeft(find.text('21 Kasım')).dy;
      expect(y23, lessThan(y21));
    });

    testWidgets('günün en yüksek puanlısı büyük kartta', (tester) async {
      await _ciz(
          tester,
          _ekran([
            gunluk('b1', 'Düşük puanlı', DateTime(2026, 11, 23, 9), 10),
            gunluk('b2', 'Yüksek puanlı', DateTime(2026, 11, 23, 18), 90),
          ]));

      // Büyük kart gün başlığının hemen altında: puanı yüksek olan önce.
      final yYuksek = tester.getTopLeft(find.text('Yüksek puanlı')).dy;
      final yDusuk = tester.getTopLeft(find.text('Düşük puanlı')).dy;
      expect(yYuksek, lessThan(yDusuk),
          reason: 'sıralama editör puanından gelmeli, saatten değil');
    });
  });
}
