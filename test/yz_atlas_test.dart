import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarim_app/core/analitik/sayfa_gorunumu.dart' show kSiteAdi;
import 'package:tarim_app/core/router/app_router.dart';
import 'package:tarim_app/features/home/data/models/news_article.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_atlas.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_deposu.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_iskelet.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_metinler.g.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_atlas_ekrani.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_atlas_veri.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_matris.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_merkez_ekrani.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_metin_gorunumu.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_sekme_basligi.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_telefon_bolme.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_yollar.dart';
import 'package:tarim_app/features/yapay_zeka/yz_providers.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Türkiye Dijital Tarım Atlası (atlas turu, 25 Kasım 2026)
// ──────────────────────────────────────────────────────────────────────────
//  · Izgara: 81 plaka, 81 ayrı hücre, 17 × 7'nin içinde.
//  · Dosyada: her cümle metinde harfi harfine; Dart eşleştiricisi Python'un
//    çıkardığı kayıtların AYNISINI buluyor (eşlik; İngilizce hizalama dahil);
//    Van der Velde bir soyadı.
//  · Türkiye dizininde: her satırın ili eşleme dosyasında ya da Kuruluş
//    hücresinde; hücreler §25'te harfi harfine; kamu tabloları haritada yok.
//  · Haberlerde: başlık ve özette il; Türkçe ekler; büyük harf şartı.
//  · Rota: "atlas" bir başlık sanılmıyor. Sayfa 375/1280/1440 px TR/EN
//    taşmıyor; masaüstünde seçim, telefonda alttan sayfa.
// ══════════════════════════════════════════════════════════════════════════

const _bolumler = 'content/yapay_zeka_dijital_tarim/bolumler';

String _md(int no, String dil) {
  final ad = Directory(_bolumler)
      .listSync()
      .map((e) => e.uri.pathSegments.last)
      .firstWhere((f) => f.startsWith('${no.toString().padLeft(2, '0')}-') && f.endsWith('.$dil.md'));
  return File('$_bolumler/$ad').readAsStringSync();
}

Set<int> _iller(String metin, {bool en = false}) => {for (final e in yzAtlasIlleri(metin, en: en)) e.plaka};

YzHaber _haber(String id, String baslik, {String? ozet, String? baslikEn, DateTime? gun}) => YzHaber(
      NewsArticle(
        id: id,
        title: baslik,
        titleEn: baslikEn,
        summary: ozet,
        content: '',
        createdAt: gun ?? DateTime(2026, 11, 20),
        sourceName: 'Tarım Portalı',
      ),
      20,
    );

final _haberler = [
  _haber('h1', "Antalya'da seralarda yapay zekâ destekli sulama denemesi",
      baslikEn: 'AI-assisted irrigation trial in Antalya greenhouses'),
  _haber('h2', 'Akıllı sensörler zeytinde ilaçlamayı azalttı', ozet: 'Denemeler Aydın ve Muğla’da yapıldı.'),
  _haber('h3', 'Dron haritası buğdayda verimi ölçtü', ozet: 'Ölçüm yapılıyordu; ordu da değil.'),
];

Widget _uygulama(Widget cocuk, {String dil = 'tr', Future<List<YzHaber>> Function()? haber}) =>
    ProviderScope(
      overrides: [
        yzAtlasHaberleriProvider.overrideWith((ref) => (haber ?? () async => _haberler)()),
        yzBolumHaberleriProvider.overrideWith((ref, no) async => const <YzHaber>[]),
        yzDizinEklenenlerProvider.overrideWith((ref) async => const <YzDizinKaydi>[]),
      ],
      child: MaterialApp(
        locale: Locale(dil),
        supportedLocales: const [Locale('tr'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: cocuk,
      ),
    );

Future<void> _boyut(WidgetTester t, Size s) async {
  t.view.physicalSize = s;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

/// Python'un çıkarımının Dart'ta yeniden kuruluşu (atlas_uret.py ›
/// dosya_kayitlari): blok, cümle ve il eşleştiricisi Dart'ınki.
List<String> _dartCikarimi() {
  List<String> metinler(YzBlok b) => switch (b.tur) {
        YzBlokTuru.paragraf => [b.metin],
        YzBlokTuru.liste => b.ogeler,
        _ => const <String>[],
      };
  List<String> cumleler(String m, bool en) {
    final s = [0, ...yzCumleSinirlari(m, en: en), m.length];
    return [
      for (var i = 0; i + 1 < s.length; i++)
        if (m.substring(s[i], s[i + 1]).trim().isNotEmpty) m.substring(s[i], s[i + 1]).trim(),
    ];
  }

  final sonuc = <String>[];
  final basliklar = [...kYzBasliklar]..sort((a, b) => a.no - b.no);
  for (final b in basliklar) {
    final m = kYzMetinler[b.no];
    if (m == null || {29, 30}.contains(b.no)) continue;
    final tr = yzAyristir(m.metin(false));
    final en = yzAyristir(m.metin(true));
    String? altTr, altEn;
    for (var i = 0; i < tr.length; i++) {
      final x = tr[i];
      final karsi = i < en.length && en[i].tur == x.tur ? en[i] : null;
      if (x.tur == YzBlokTuru.altBaslik) {
        altTr = x.metin;
        altEn = karsi?.metin;
        continue;
      }
      final trM = metinler(x);
      final enM = karsi == null ? const <String>[] : metinler(karsi);
      for (var j = 0; j < trM.length; j++) {
        final trC = cumleler(trM[j], false);
        final enC = enM.length == trM.length ? cumleler(enM[j], true) : const <String>[];
        for (final c in trC) {
          for (final p in {for (final e in yzAtlasIlleri(c)) e.plaka}) {
            final trIl = [for (final x in trC) if (_iller(x).contains(p)) x];
            final enIl = [for (final x in enC) if (_iller(x, en: true).contains(p)) x];
            final ing = enIl.length == trIl.length ? enIl[trIl.indexOf(c)] : null;
            sonuc.add('$p|${b.no}|$altTr|${ing == null ? null : altEn}|$c|$ing');
          }
        }
      }
    }
  }
  return sonuc;
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('ızgara', () {
    test('81 plaka, 81 ayrı hücre, 17 × 7 içinde, plaka sırasıyla', () {
      expect(kYzAtlasSutun, 17);
      expect(kYzAtlasSatir, 7);
      expect(kYzAtlasIller.length, 81);
      expect([for (final il in kYzAtlasIller) il.plaka], List.generate(81, (i) => i + 1));
      expect({for (final il in kYzAtlasIller) (il.sutun, il.satir)}.length, 81, reason: 'iki il aynı hücrede');
      for (final il in kYzAtlasIller) {
        expect(il.sutun, inInclusiveRange(0, 16));
        expect(il.satir, inInclusiveRange(0, 6));
        expect(kYzAtlasAdlarTr[il.ad], il.plaka);
      }
      // Kaba coğrafya: batı batıda, doğu doğuda, kıyı kıyıda.
      expect(yzAtlasIl(22)!.sutun, 0, reason: 'Edirne en batıda');
      expect(yzAtlasIl(76)!.sutun, 16, reason: 'Iğdır en doğuda');
      expect(yzAtlasIl(57)!.satir, 0, reason: 'Sinop en kuzeyde');
      expect(yzAtlasIl(31)!.satir, 6, reason: 'Hatay en güneyde');
    });

    test('yerleşim üreticisi ve kaydı depoda', () {
      final json = jsonDecode(File('content/yapay_zeka_dijital_tarim/_raw/il_izgarasi.json').readAsStringSync())
          as Map<String, dynamic>;
      for (final il in kYzAtlasIller) {
        final k = json['${il.plaka}'] as Map<String, dynamic>;
        expect((k['ad'], k['sutun'], k['satir']), (il.ad, il.sutun, il.satir));
      }
      expect(File('content/yapay_zeka_dijital_tarim/_raw/il_izgarasi.py').existsSync(), isTrue);
    });
  });

  group('dosyada', () {
    test('her cümle kendi metninde harfi harfine ve ilin adını taşıyor', () {
      expect(kYzAtlasDosya, isNotEmpty);
      for (final r in kYzAtlasDosya) {
        expect({29, 30}, isNot(contains(r.baslikNo)), reason: 'sözlük ve kaynakça hariç');
        expect(_md(r.baslikNo, 'tr'), contains(r.tr), reason: 'TR §${r.baslikNo}: ${r.tr}');
        expect(kYzMetinler[r.baslikNo]!.metin(false), contains(r.tr));
        expect(_iller(r.tr), contains(r.il), reason: r.tr);
        if (r.en != null) {
          expect(_md(r.baslikNo, 'en'), contains(r.en), reason: 'EN §${r.baslikNo}: ${r.en}');
          expect(_iller(r.en!, en: true), contains(r.il), reason: r.en);
        } else {
          expect(r.altBaslikEn, isNull);
        }
        if (r.altBaslikTr != null) {
          expect(_md(r.baslikNo, 'tr'), contains('## ${r.altBaslikTr}'));
        }
      }
    });

    test('Dart eşleştiricisi Python çıkarımıyla aynı kayıtları buluyor (İngilizce hizalama dahil)', () {
      final uretilen = [
        for (final r in kYzAtlasDosya) '${r.il}|${r.baslikNo}|${r.altBaslikTr}|${r.altBaslikEn}|${r.tr}|${r.en}',
      ];
      expect(_dartCikarimi(), uretilen);
      final hizali = kYzAtlasDosya.where((r) => r.en != null).length;
      // ignore: avoid_print
      print('ATLAS: ${kYzAtlasDosya.length} dosya kaydı, İngilizce hizalama $hizali/${kYzAtlasDosya.length}');
    });

    test('dışlama: "Van der Velde" bir soyadı, Van ili değil', () {
      expect(kYzAtlasDislama, contains('Van der '));
      expect(_iller('Van der Velde ve Nisini (2019) yumuşak ve makarnalık buğdayı'), isEmpty);
      expect(_iller('Van der Velde and Nisini (2019) compared', en: true), isEmpty);
      expect(_md(9, 'tr'), contains('Van der Velde'), reason: 'metinde gerçekten geçiyor');
      expect(kYzAtlasDosya.where((r) => r.il == 65), isEmpty, reason: 'Van için uydurma kayıt yok');
      expect(_iller("Van'da tarım"), {65});
      expect(_iller('Van Gölü havzası'), {65});
    });

    test('kurum adındaki il sayılıyor', () {
      expect(_iller('Tekirdağ Namık Kemal Üniversitesi’nden bir ekip'), {59});
      expect(kYzAtlasDosya.where((r) => r.il == 59 && r.tr.contains('Tekirdağ Namık Kemal')), isNotEmpty);
    });

    test('derin bağlantı: alt başlık, sayfanın kendi ayrıştırdığı alt başlıklardan (?bolum=)', () {
      Set<String> altlar(int no, bool en) => {
            for (final b in yzAyristir(kYzMetinler[no]!.metin(en)))
              if (b.tur == YzBlokTuru.altBaslik) b.metin,
          };
      for (final r in kYzAtlasDosya) {
        if (r.altBaslikTr != null) expect(altlar(r.baslikNo, false), contains(r.altBaslikTr));
        if (r.altBaslikEn != null) expect(altlar(r.baslikNo, true), contains(r.altBaslikEn));
      }
      final no25 = kYzBasliklar.firstWhere((b) => b.slug == 'turkiye-dizini').no;
      for (final r in kYzAtlasDizin) {
        expect(altlar(no25, false), contains(r.bolumTr));
        expect(altlar(no25, true), contains(r.bolumEn));
      }
    });
  });

  group('Türkiye dizininde', () {
    final esleme = jsonDecode(File('content/yapay_zeka_dijital_tarim/_raw/atlas_kurum_ili.json').readAsStringSync())
        as Map<String, dynamic>;
    final kurumlar = (esleme['kurumlar'] as Map).cast<String, dynamic>();
    final dayanaklar = (esleme['dayanaklar'] as List).cast<String>();

    test('eşleme dosyası: geçerli il ve dayanak', () {
      expect(dayanaklar, ['adında', 'üniversitenin merkezinin bulunduğu il']);
      for (final e in kurumlar.entries) {
        final v = e.value as Map;
        expect(kYzAtlasAdlarTr.containsKey(v['il']), isTrue, reason: e.key);
        expect(dayanaklar, contains(v['dayanak']), reason: e.key);
        if (v['dayanak'] == 'adında') {
          expect(e.key, contains(v['il']), reason: '"adında" dayanağı: ${e.key}');
        }
      }
      expect((esleme['eslenmeyen'] as Map).keys, containsAll(['TAGEM', 'TÜBİTAK MAM']));
    });

    test('her satırın ili eşleme dosyasında ya da Kuruluş hücresinde; hücreler §25\'te', () {
      final tr = _md(25, 'tr'), en = _md(25, 'en');
      expect(kYzAtlasDizin, isNotEmpty);
      for (final r in kYzAtlasDizin) {
        final il = yzAtlasIl(r.il)!.ad;
        for (final x in [r.adTr, r.aciklamaTr, if (r.ekTr != null) r.ekTr!]) {
          expect(tr, contains('| $x |'), reason: x);
        }
        for (final x in [r.adEn, r.aciklamaEn, if (r.ekEn != null) r.ekEn!]) {
          expect(en, contains('| $x |'), reason: x);
        }
        expect(tr, contains('| ${r.aciklamaBasligiTr} |'));
        expect(en, contains('| ${r.aciklamaBasligiEn} |'));
        expect(r.bolumTr, isNot(startsWith('Kamu')), reason: 'kamu tabloları ulusal sistemler');
        expect(r.vurguTr, isNotEmpty);
        for (final v in r.vurguTr) {
          expect(r.ekTr ?? r.adTr, contains(v));
          if (r.bolumTr == 'Girişimler') {
            expect(kYzAtlasAdlarTr[v], r.il, reason: '${r.adTr}: Kuruluş hücresi ${r.ekTr}');
          } else {
            final kurum = kurumlar.containsKey(v) ? v : '$v Üniversitesi';
            expect(kurumlar[kurum]?['il'], il, reason: '${r.adTr}: $kurum → $il');
          }
        }
      }
    });

    test('birden çok üniversiteli satır birden çok ile; eşlenmeyen kurum haritada değil', () {
      final jeotermal = kYzAtlasDizin.where((r) => r.adTr.startsWith('Jeotermal')).map((r) => r.il).toSet();
      expect(jeotermal, {40, 6, 42}, reason: 'Kırşehir Ahi Evran, Ankara ve Selçuk (Konya)');
      expect(kYzAtlasDizin.where((r) => r.adTr == 'Merlab'), isEmpty, reason: 'yalnız TAGEM: tek ve açık il yok');
      final uzbas = kYzAtlasDizin.where((r) => r.adTr == 'Uzbaş').toList();
      expect(uzbas.length, 1, reason: 'Ege ve İYTE aynı ilde: tek kayıt');
      expect(uzbas.single.il, 35);
      expect(kYzAtlasDizin.where((r) => r.adTr == 'Doktar').single.il, 35, reason: '"2012, İzmir"');
      expect(kYzAtlasDizin.where((r) => r.adTr == 'Esular').single.vurguEn, ['Istanbul']);
    });
  });

  group('haber il tanıma', () {
    test('Türkçe ekler', () {
      expect(_iller("Antalya'da sera hasadı"), {7});
      expect(_iller('Antalya’da (eğik kesme)'), {7});
      expect(_iller('Antalyalı üreticiler'), {7});
      expect(_iller('Antalyalılar dron kullanıyor'), {7});
      expect(_iller("Sakarya'nın fındığı"), {54});
      expect(_iller('İzmirli girişim'), {35});
      expect(_iller('Ordulu fındık üreticisi'), {52});
      expect(_iller("Ordu'da hasat"), {52});
      expect(_iller('Hakkâri ve Hakkari'), {30}, reason: 'yazım çeşidi');
    });

    test('büyük harf şartı ve sözcük kıyası: "ordu" Ordu değil', () {
      expect(_iller('ordu tatbikatı'), isEmpty);
      expect(_iller('Çalışma yapılıyordu.'), isEmpty);
      expect(_iller('Sulama sistemi çalışıyordu'), isEmpty);
      expect(_iller('ORDU'), isEmpty, reason: 'yalnız ilk harfi büyük yazılış');
      expect(_iller('Aydınlık bir gelecek'), isEmpty, reason: '-lık eki il değil');
      expect(_iller('Aydınlı çiftçiler'), {9});
      expect(_iller('Konyaspor maçı'), isEmpty, reason: 'ek değil, başka sözcük');
      expect(_iller('mersin balığı'), isEmpty);
    });

    test('yalnız başlık ve özet; gövde taranmıyor', () {
      final a = NewsArticle(
          id: 'x', title: 'Akıllı tarım', summary: "Deneme Mersin'de yapıldı.", content: 'Ankara', createdAt: DateTime(2026));
      expect(yzAtlasHaberIlleri(a), {33});
      final b = NewsArticle(id: 'y', title: 'Konya Ovası’nda uydu', content: 'İzmir', createdAt: DateTime(2026));
      expect(yzAtlasHaberIlleri(b), {42});
    });

    test('İngilizce yazılışlar', () {
      expect(_iller("Istanbul's start-ups", en: true), {34});
      expect(_iller('in İzmir and Sanliurfa', en: true), {35, 63});
      expect(_iller('Istanbul', en: false), isEmpty, reason: 'Türkçede İstanbul');
    });
  });

  group('rota ve sekme', () {
    test('"atlas" bir başlığın adresi sanılmıyor', () {
      TestWidgetsFlutterBinding.ensureInitialized();
      final atlas = appRouter.configuration.findMatch(Uri.parse(yzAtlasPath));
      expect(atlas.last.route.path, yzAtlasPath);
      final baslik = appRouter.configuration.findMatch(Uri.parse(yzBaslikPath('sozluk')));
      expect(baslik.last.route.path, '$yzPath/:slug');
      expect(kYzBasliklar.map((b) => b.slug), isNot(contains('atlas')));
      final r = File('lib/core/router/app_router.dart').readAsStringSync();
      expect(r.indexOf('path: yzAtlasPath'), lessThan(r.indexOf("path: '\$yzPath/:slug'")));
    });

    test('sekme başlığı', () {
      // Sekmeye "<ad> | Tarım Portalı" yazılıyor (sayfa_gorunumu.dart).
      expect('${yzSekmeAdi(Uri.parse(yzAtlasPath), false)} | $kSiteAdi', 'Türkiye Dijital Tarım Atlası | Tarım Portalı');
      expect('${yzSekmeAdi(Uri.parse(yzAtlasPath), true)} | $kSiteAdi',
          'Türkiye Digital Agriculture Atlas | Tarım Portalı');
      expect(yzSekmeAdi(Uri.parse('$yzAtlasPath/x'), false), isNull, reason: 'alt adres yok');
    });

    testWidgets('kartlar kaynağına götürüyor: başlığın alt başlığı, §25\'in tablosu, haber', (t) async {
      await _boyut(t, const Size(1280, 900));
      final r = GoRouter(initialLocation: yzAtlasPath, routes: [
        GoRoute(path: yzAtlasPath, builder: (c, s) => const YzAtlasEkrani()),
        GoRoute(
            path: '/haber/:id',
            builder: (c, s) => Scaffold(body: Text('HABER ${s.pathParameters['id']}'))),
        GoRoute(
            path: '$yzPath/:slug',
            builder: (c, s) =>
                Scaffold(body: Text('BAŞLIK ${s.pathParameters['slug']} ${s.uri.queryParameters['bolum']}'))),
      ]);
      await t.pumpWidget(ProviderScope(
        overrides: [yzAtlasHaberleriProvider.overrideWith((ref) async => _haberler)],
        child: MaterialApp.router(
          routerConfig: r,
          locale: const Locale('tr'),
          supportedLocales: const [Locale('tr'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ));
      await t.pumpAndSettle();
      Future<void> ac(int plaka, String metin) async {
        final hucre = find.byKey(ValueKey('yz-atlas-hucre-$plaka'));
        await t.ensureVisible(hucre);
        await t.pumpAndSettle();
        await t.tap(hucre);
        await t.pumpAndSettle();
        final kart = find.textContaining(metin, findRichText: true).first;
        await t.ensureVisible(kart);
        await t.tap(kart);
        await t.pumpAndSettle();
      }

      // Konya: §5'in "Türkiye" alt başlığı.
      await ac(42, 'modern fenotipleme');
      final konya = kYzAtlasDosya.firstWhere((x) => x.il == 42);
      expect(find.text('BAŞLIK ${yzBaslik(konya.baslikNo)!.slug} turkiye'), findsOneWidget);
      r.pop();
      await t.pumpAndSettle();
      // Esular (İstanbul): §25'in "Girişimler" tablosu.
      await ac(34, 'Kablosuz toprak nem sensörü');
      expect(find.text('BAŞLIK turkiye-dizini girisimler'), findsOneWidget);
      r.pop();
      await t.pumpAndSettle();
      // Antalya: haber sayfası.
      await ac(7, 'seralarda yapay zekâ');
      expect(find.text('HABER h1'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  group('sayfa', () {
    for (final olcu in const [Size(375, 812), Size(1280, 900), Size(1440, 900)]) {
      for (final dil in const ['tr', 'en']) {
        testWidgets('${olcu.width.toInt()} px · $dil · taşmıyor', (t) async {
          await _boyut(t, olcu);
          await t.pumpWidget(_uygulama(const YzAtlasEkrani(), dil: dil));
          await t.pumpAndSettle();
          expect(t.takeException(), isNull);
          expect(find.text(dil == 'en' ? kYzAtlasAdEn : kYzAtlasAdTr), findsOneWidget);
          expect(find.byType(YzAtlasIzgarasi), findsOneWidget);
          final izgara = t.getRect(find.byType(YzAtlasIzgarasi));
          expect(izgara.right, lessThanOrEqualTo(olcu.width - 16 + 0.01), reason: 'yatay kaydırma yok');
          expect(
              find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.right),
              findsNothing);
          final hucre = t.getSize(find.byKey(const ValueKey('yz-atlas-hucre-6')));
          if (olcu.width < 640) {
            expect(hucre.width, inInclusiveRange(17, 20), reason: 'telefonda ~19 px');
            expect(find.byKey(const ValueKey('yz-atlas-satir-6')), findsOneWidget);
            expect(t.getSize(find.byKey(const ValueKey('yz-atlas-satir-6'))).height, greaterThanOrEqualTo(44));
            expect(find.descendant(of: find.byType(YzAtlasIzgarasi), matching: find.text('06')), findsNothing,
                reason: 'telefonda yazısız kareler');
          } else {
            expect(hucre.width, inInclusiveRange(40, 64));
            expect(find.descendant(of: find.byType(YzAtlasIzgarasi), matching: find.text('06')), findsOneWidget);
            expect(find.text(dil == 'en' ? 'Provinces with the most entries' : 'En çok kaydı olan iller'),
                findsOneWidget);
          }
          // Sola dikey çizgi yok: kayıt kartlarının kenarı dört yanda eşit.
          for (final e in find.byType(Container).evaluate()) {
            final d = (e.widget as Container).decoration;
            if (d is BoxDecoration && d.border is Border) {
              final b = d.border as Border;
              expect(b.left.width > b.top.width, isFalse, reason: 'sol kenarda vurgu çizgisi');
            }
          }
        });
      }
    }

    testWidgets('büyük yazı boyunda (A+) taşmıyor', (t) async {
      // Okurun seçimi tarayıcıda (yz_okuma.dart › YzYaziOlcegi).
      SharedPreferences.setMockInitialValues({'yz_yazi_olcegi': 1.4});
      for (final olcu in const [Size(375, 812), Size(1280, 900)]) {
        await _boyut(t, olcu);
        await t.pumpWidget(const SizedBox());
        await t.pumpWidget(_uygulama(const YzAtlasEkrani()));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull, reason: '${olcu.width}');
        final s = t.widget<MediaQuery>(find
                .ancestor(of: find.byType(YzAtlasIzgarasi), matching: find.byType(MediaQuery))
                .first)
            .data
            .textScaler
            .scale(10);
        expect(s, closeTo(14, 0.01), reason: 'yazı boyu sayfaya uygulanıyor');
      }
    });

    testWidgets('masaüstünde hücre seçimi kayıtları gösteriyor; yeniden dokununca kapanıyor', (t) async {
      await _boyut(t, const Size(1280, 900));
      await t.pumpWidget(_uygulama(const YzAtlasEkrani()));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('yz-atlas-kayitlar')), findsNothing);
      await t.tap(find.byKey(const ValueKey('yz-atlas-hucre-6')));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.byKey(const ValueKey('yz-atlas-kayitlar')), findsOneWidget);
      expect(find.byKey(const ValueKey('yz-atlas-dosyada')), findsOneWidget);
      expect(find.byKey(const ValueKey('yz-atlas-dizinde')), findsOneWidget);
      expect(find.byKey(const ValueKey('yz-atlas-haberlerde')), findsNothing, reason: 'Ankara haberde geçmiyor');
      final ankara = kYzAtlasDosya.where((r) => r.il == 6).first;
      expect(find.text(ankara.tr.replaceAll('**', ''), findRichText: true), findsOneWidget,
          reason: 'cümle kısaltılmadan');
      expect(find.text('Tarla.io'), findsOneWidget);
      expect(find.textContaining('Ne yapıyor (şirketin kendi tanımı): ', findRichText: true), findsWidgets);
      await t.ensureVisible(find.byKey(const ValueKey('yz-atlas-hucre-6')));
      await t.tap(find.byKey(const ValueKey('yz-atlas-hucre-6')));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('yz-atlas-kayitlar')), findsNothing);

      // Listeden seçim de aynı yere.
      await t.tap(find.byKey(const ValueKey('yz-atlas-cip-6')));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('yz-atlas-kayitlar')), findsOneWidget);
    });

    testWidgets('kayıtsız hücreye dokunulmuyor; üzerine gelince ad ve sayı', (t) async {
      await _boyut(t, const Size(1280, 900));
      await t.pumpWidget(_uygulama(const YzAtlasEkrani()));
      await t.pumpAndSettle();
      // 22 Edirne: dosyada ve dizinde yok, test haberlerinde de yok.
      await t.tap(find.byKey(const ValueKey('yz-atlas-hucre-22')));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('yz-atlas-kayitlar')), findsNothing);
      final n = yzAtlasKayitlari(en: false, haberler: _haberler)[6]!.sayi;
      expect(find.byTooltip('Ankara · $n kayıt'), findsOneWidget);
      expect(find.byTooltip('Edirne · kayıt yok'), findsOneWidget);
    });

    testWidgets('telefonda ile dokununca kayıtlar alttan açılıyor (listeden ve haritadan)', (t) async {
      await _boyut(t, const Size(375, 812));
      await t.pumpWidget(_uygulama(const YzAtlasEkrani()));
      await t.pumpAndSettle();
      final satir = find.byKey(const ValueKey('yz-atlas-satir-6'));
      await t.ensureVisible(satir);
      await t.tap(satir);
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.descendant(of: find.byType(BottomSheet), matching: find.byKey(const ValueKey('yz-atlas-dosyada'))),
          findsOneWidget);
      expect(
          find.descendant(of: find.byType(BottomSheet), matching: find.textContaining('Ankara', findRichText: true)),
          findsWidgets);
      // Kapanınca haritadan.
      Navigator.of(t.element(find.byKey(const ValueKey('yz-atlas-kayitlar')))).pop();
      await t.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
      await t.ensureVisible(find.byKey(const ValueKey('yz-atlas-hucre-35')));
      await t.tap(find.byKey(const ValueKey('yz-atlas-hucre-35')));
      await t.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.descendant(of: find.byType(BottomSheet), matching: find.text('Doktar')), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('telefonda alttan sayfa İngilizce de taşmıyor', (t) async {
      await _boyut(t, const Size(375, 812));
      await t.pumpWidget(_uygulama(const YzAtlasEkrani(), dil: 'en'));
      await t.pumpAndSettle();
      for (final p in [6, 34, 35]) {
        final satir = find.byKey(ValueKey('yz-atlas-satir-$p'));
        await t.ensureVisible(satir);
        await t.tap(satir);
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        expect(find.byType(BottomSheet), findsOneWidget);
        Navigator.of(t.element(find.byKey(const ValueKey('yz-atlas-kayitlar')))).pop();
        await t.pumpAndSettle();
      }
    });

    testWidgets('"Haberlerde": haber sağlayıcısından, başlık ve tarihiyle', (t) async {
      await _boyut(t, const Size(1280, 900));
      await t.pumpWidget(_uygulama(const YzAtlasEkrani()));
      await t.pumpAndSettle();
      // Antalya (7) yalnız haberde geçiyor.
      await t.tap(find.byKey(const ValueKey('yz-atlas-hucre-7')));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('yz-atlas-haberlerde')), findsOneWidget);
      expect(find.byKey(const ValueKey('yz-atlas-dosyada')), findsNothing);
      expect(find.text("Antalya'da seralarda yapay zekâ destekli sulama denemesi", findRichText: true),
          findsOneWidget);
      expect(find.text('Tarım Portalı · 20 Kas 2026'), findsOneWidget);
      // Özette geçen il (Muğla, 48): dosya ve dizin kayıtlarının yanında.
      await t.tap(find.byKey(const ValueKey('yz-atlas-hucre-48')));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('yz-atlas-haberlerde')), findsOneWidget);
      expect(find.text('Akıllı sensörler zeytinde ilaçlamayı azalttı', findRichText: true), findsOneWidget);
      // "ordu" geçen haber Ordu'ya düşmüyor.
      expect(yzAtlasKayitlari(en: false, haberler: _haberler)[52], isNull);
    });

    testWidgets('İngilizcede haber başlığı İngilizce', (t) async {
      await _boyut(t, const Size(1280, 900));
      await t.pumpWidget(_uygulama(const YzAtlasEkrani(), dil: 'en'));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const ValueKey('yz-atlas-hucre-7')));
      await t.pumpAndSettle();
      expect(find.text('AI-assisted irrigation trial in Antalya greenhouses', findRichText: true), findsOneWidget);
      expect(find.textContaining('In the news', findRichText: true), findsWidgets);
    });

    testWidgets('haber yüklenirken ya da hata verince sayfa çalışıyor, "Haberlerde" yok', (t) async {
      await _boyut(t, const Size(1280, 900));
      await t.pumpWidget(_uygulama(const YzAtlasEkrani(), haber: () async => throw StateError('ağ yok')));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      await t.tap(find.byKey(const ValueKey('yz-atlas-hucre-6')));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('yz-atlas-kayitlar')), findsOneWidget);
      expect(find.byKey(const ValueKey('yz-atlas-haberlerde')), findsNothing);
      // Antalya'nın tek kaydı haberdi: hücre kayıtsız.
      expect(yzAtlasKayitlari(en: false)[7], isNull);
    });

    test('İngilizcede İngilizce cümlesi olmayan dosya kaydı yok', () {
      final en = yzAtlasKayitlari(en: true);
      for (final k in en.values) {
        for (final r in k.dosya) {
          expect(r.en, isNotNull);
        }
      }
    });
  });

  group('merkez sayfa', () {
    testWidgets('atlas kartı ısı haritasından sonra, haberlerden önce; dokununca atlas', (t) async {
      await _boyut(t, const Size(1280, 900));
      final r = GoRouter(initialLocation: yzPath, routes: [
        GoRoute(path: yzPath, builder: (c, s) => const YzMerkezEkrani()),
        GoRoute(path: yzAtlasPath, builder: (c, s) => const YzAtlasEkrani()),
      ]);
      await t.pumpWidget(ProviderScope(
        overrides: [
          yzAtlasHaberleriProvider.overrideWith((ref) async => _haberler),
          yzBolumHaberleriProvider.overrideWith((ref, no) async =>
              no == null ? [_haber('m1', 'Merkez haberi', gun: DateTime(2026, 11, 21))] : const <YzHaber>[]),
          yzDizinEklenenlerProvider.overrideWith((ref) async => const <YzDizinKaydi>[]),
        ],
        child: MaterialApp.router(
          routerConfig: r,
          locale: const Locale('tr'),
          supportedLocales: const [Locale('tr'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ));
      await t.pumpAndSettle();
      await t.pump(const Duration(milliseconds: 1600));
      await t.pumpAndSettle();
      final kart = find.byKey(const ValueKey('yz-atlas-karti'));
      expect(kart, findsOneWidget);
      expect(find.descendant(of: kart, matching: find.text(kYzAtlasAdTr)), findsOneWidget);
      final matris = t.getRect(find.byType(YzTeknolojiMatrisi));
      final haberler = t.getRect(find.byKey(const ValueKey('yz-merkez-haberleri')));
      final k = t.getRect(kart);
      expect(k.top, greaterThan(matris.bottom));
      expect(k.bottom, lessThanOrEqualTo(haberler.top));
      await t.ensureVisible(kart);
      await t.pumpAndSettle();
      await t.tap(kart);
      await t.pumpAndSettle();
      // Bölümün öbür geçişleri gibi `push` (go_router 14'te adres çubuğu
      // üstteki ImperativeRouteMatch'te): geri ok merkez sayfaya döner.
      final ust = r.routerDelegate.currentConfiguration.last;
      expect(ust is ImperativeRouteMatch ? ust.matches.uri.path : ust.matchedLocation, yzAtlasPath);
      expect(find.byType(YzAtlasEkrani), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    for (final olcu in const [Size(375, 812), Size(1280, 900)]) {
      for (final dil in const ['tr', 'en']) {
        testWidgets('atlas kartı · ${olcu.width.toInt()} px · $dil · taşmıyor', (t) async {
          await _boyut(t, olcu);
          await t.pumpWidget(_uygulama(const Scaffold(body: SingleChildScrollView(child: YzAtlasKarti())), dil: dil));
          await t.pumpAndSettle();
          expect(t.takeException(), isNull);
          expect(find.text(dil == 'en' ? kYzAtlasAdEn : kYzAtlasAdTr), findsOneWidget);
        });
      }
    }
  });
}
