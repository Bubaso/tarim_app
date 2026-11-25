import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:tarim_app/features/yapay_zeka/data/yz_grafikler.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_iskelet.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_metinler.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_sahadan.g.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_atlas_ekrani.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_atlas_veri.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_gorsel.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_merkez_ekrani.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_metin_gorunumu.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_sahadan_ekrani.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_sahadan_tam_ekran.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_sekme_basligi.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_yollar.dart';
import 'package:tarim_app/features/yapay_zeka/yz_providers.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Sahadan galerisi (25 Kasım 2026)
// ──────────────────────────────────────────────────────────────────────────
//  · Kayıt: sekiz kare (A-H), künye ve kaynak iki dilde, dosya diskte;
//    başlık içindeki kare (D §3, E §7, F §15) gorseller.json'la aynı dosya
//    ve künye; D ve E yer paragrafının hemen ardında, iki dilde.
//  · Rota: "sahadan" bir başlık sanılmıyor; sekme "Sahadan | Tarım Portalı".
//  · Galeri: 375/1280/1440 px TR/EN taşmıyor, telefonda 1, masaüstünde 3
//    sütun, yatay kaydırma ve sol dikey çizgi yok; fotoğraf tam ekranda
//    (erteli görüntüleyici) dizide geziliyor; "Kaynağı aç" kurumun sayfası;
//    başlık ve atlas bağlantıları.
//  · Atlas: ili olan her kare o ilin "Fotoğraf" kaydı; ?il= ile seçili açılış.
//  · Merkez: atlas kartının hemen altında, aynı biçimde Sahadan kartı.
// ══════════════════════════════════════════════════════════════════════════

YzHaber _haber(String id, String baslik, {DateTime? gun}) => YzHaber(
      NewsArticle(
        id: id,
        title: baslik,
        content: '',
        createdAt: gun ?? DateTime(2026, 11, 20),
        sourceName: 'Tarım Portalı',
      ),
      20,
    );

List<Override> get _saglayicilar => [
      yzAtlasHaberleriProvider.overrideWith((ref) async => const <YzHaber>[]),
      yzBolumHaberleriProvider.overrideWith((ref, no) async => const <YzHaber>[]),
      yzDizinEklenenlerProvider.overrideWith((ref) async => const <YzDizinKaydi>[]),
    ];

const _yerellestirme = [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

Widget _uygulama(Widget cocuk, {String dil = 'tr'}) => ProviderScope(
      overrides: _saglayicilar,
      child: MaterialApp(
        locale: Locale(dil),
        supportedLocales: const [Locale('tr'), Locale('en')],
        localizationsDelegates: _yerellestirme,
        home: cocuk,
      ),
    );

Widget _yonlendirici(GoRouter r, {String dil = 'tr', List<Override>? saglayicilar}) => ProviderScope(
      overrides: saglayicilar ?? _saglayicilar,
      child: MaterialApp.router(
        routerConfig: r,
        locale: Locale(dil),
        supportedLocales: const [Locale('tr'), Locale('en')],
        localizationsDelegates: _yerellestirme,
      ),
    );

Future<void> _boyut(WidgetTester t, Size s) async {
  t.view.physicalSize = s;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

YzSahadanKare _kare(String harf) => kYzSahadan.firstWhere((k) => k.harf == harf);

/// Sol kenarda vurgu çizgisi (dikey çizgi) yok: kenarı olan kutuların sol
/// kenarı üst kenarından kalın değil.
void _solCizgiYok(WidgetTester t) {
  for (final e in find.byType(Container).evaluate()) {
    final d = (e.widget as Container).decoration;
    if (d is BoxDecoration && d.border is Border) {
      final b = d.border as Border;
      expect(b.left.width > b.top.width, isFalse, reason: 'sol kenarda vurgu çizgisi');
    }
  }
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('kayıt', () {
    test('sekiz kare A-H sırasıyla; künye ve kaynak iki dilde; dosya diskte', () {
      expect(kYzSahadan.map((k) => k.harf).join(), 'ABCDEFGH');
      expect(kYzSahadan.map((k) => k.kimlik).toSet().length, 8);
      expect(kYzSahadan.map((k) => k.adres).toSet().length, 8, reason: 'çift dosya yok');
      for (final k in kYzSahadan) {
        expect(File('web${k.adres}').existsSync(), isTrue, reason: k.adres);
        expect(k.kunyeTr.trim(), isNotEmpty);
        expect(k.kunyeEn.trim(), isNotEmpty);
        expect(k.kaynakTr, startsWith('Fotoğraf: '));
        expect(k.kaynakEn, startsWith('Photo: '));
        expect(k.sayfaAdresi, startsWith('https://'));
        expect(k.genislik, greaterThan(0));
        expect(k.yukseklik, greaterThan(0));
        expect(yzBaslik(k.baslikNo), isNotNull);
        // Künye karede görüneni tahlil etmiyor (sahibin kuralı).
        for (final s in ['görülüyor', 'görünüyor', 'karede', 'fotoğrafta']) {
          expect(k.kunyeTr, isNot(contains(s)), reason: '${k.harf}: $s');
        }
      }
    });

    test('kayıt dosyası ve üretilmiş sabit aynı sırada, aynı künyeyle', () {
      final j = jsonDecode(File('content/yapay_zeka_dijital_tarim/_raw/sahadan.json').readAsStringSync()) as Map;
      final kareler = (j['kareler'] as List).cast<Map>();
      expect([for (final r in kareler) r['kimlik']], [for (final k in kYzSahadan) k.kimlik]);
      for (final r in kareler) {
        final k = kYzSahadan.firstWhere((x) => x.kimlik == r['kimlik']);
        expect(k.kunyeTr, (r['kunye'] as Map)['tr']);
        expect(k.kaynakEn, (r['kaynak'] as Map)['en']);
        expect(r['ajans_izi'] as String, startsWith('hayır'));
      }
    });

    test('başlık içinde de duran kareler (D, E, F) gorseller kaydıyla aynı dosya ve künye', () {
      final metinde = [for (final k in kYzSahadan) if (k.metinde) k.harf];
      expect(metinde, ['D', 'E', 'F']);
      for (final k in kYzSahadan.where((k) => k.metinde)) {
        final g = kYzGorseller[k.kimlik]!;
        expect(k.adres, g.adres);
        expect((k.genislik, k.yukseklik), (g.genislik, g.yukseklik));
        expect((k.kunyeTr, k.kunyeEn), (g.kunyeTr, g.kunyeEn));
        expect((k.kaynakTr, k.kaynakEn), (g.kaynakTr, g.kaynakEn));
      }
      for (final k in kYzSahadan.where((k) => !k.metinde)) {
        expect(kYzGorseller.containsKey(k.kimlik), isFalse);
        expect(k.kimlik, startsWith('sahadan-'));
      }
    });

    test('il ve plaka: E ilsiz; plakalar ızgarayla aynı', () {
      expect(_kare('E').il, isNull);
      expect(_kare('E').plaka, isNull);
      for (final k in kYzSahadan.where((k) => k.il != null)) {
        expect(kYzAtlasAdlarTr[k.il!], k.plaka, reason: k.harf);
      }
      expect({for (final k in kYzSahadan) k.harf: k.plaka},
          {'A': 41, 'B': 41, 'C': 23, 'D': 40, 'E': null, 'F': 1, 'G': 18, 'H': 7});
    });
  });

  group('başlık içi', () {
    // (başlık, kare, Türkçe yer paragrafının başı)
    const yerler = [
      (3, 'D', "Bakanlığın sayfasına göre Tarımsal İzleme ve Bilgi Sistemi (TARBİL), 2008'de"),
      (7, 'E', 'Dijital tarafta iki tedbir var. Uzaktan algılama ve coğrafi bilgi sistemleriyle'),
    ];

    test('D §3 ve E §7: yer paragrafının hemen ardında, iki dilde aynı sırada', () {
      for (final (no, harf, bas) in yerler) {
        final kimlik = _kare(harf).kimlik;
        final tr = yzAyristir(kYzMetinler[no]!.metin(false));
        final en = yzAyristir(kYzMetinler[no]!.metin(true));
        final i = tr.indexWhere((b) => b.tur == YzBlokTuru.paragraf && b.metin.startsWith(bas));
        expect(i, greaterThanOrEqualTo(0), reason: '§$no yer paragrafı');
        expect((tr[i + 1].tur, tr[i + 1].metin), (YzBlokTuru.gorsel, kimlik), reason: '§$no TR');
        expect(en[i].tur, YzBlokTuru.paragraf, reason: '§$no EN aynı sırada paragraf');
        expect((en[i + 1].tur, en[i + 1].metin), (YzBlokTuru.gorsel, kimlik), reason: '§$no EN');
        expect(kYzGorseller.containsKey(kimlik), isTrue);
      }
      // E, aynı paragrafın ardındaki TAGEM-SuET görselinden önce.
      final tr7 = yzAyristir(kYzMetinler[7]!.metin(false));
      final e = tr7.indexWhere((b) => b.tur == YzBlokTuru.gorsel && b.metin == _kare('E').kimlik);
      expect(tr7[e + 1].metin, 'b07-tagem-suet-uygulama-ekrani-referans');
    });

    for (final dil in const ['tr', 'en']) {
      testWidgets('çizimde de paragrafın ardında ve künyesiyle · $dil', (t) async {
        await _boyut(t, const Size(1280, 24000));
        final en = dil == 'en';
        for (final (no, harf, _) in yerler) {
          final k = _kare(harf);
          await t.pumpWidget(_uygulama(
              Scaffold(
                body: SingleChildScrollView(
                  child: Center(
                    child: SizedBox(
                      width: kYzMetinGenisligi,
                      child: YzMetinGorunumu(metin: kYzMetinler[no]!.metin(en), en: en, bolumNo: no),
                    ),
                  ),
                ),
              ),
              dil: dil));
          await t.pumpAndSettle();
          expect(t.takeException(), isNull, reason: '§$no');
          final kart = find.byWidgetPredicate((w) => w is YzGorselKarti && w.gorsel.kimlik == k.kimlik);
          expect(kart, findsOneWidget, reason: '§$no');
          expect(find.descendant(of: kart, matching: find.text(k.kunye(en))), findsOneWidget);
          expect(find.descendant(of: kart, matching: find.text(k.kaynak(en))), findsOneWidget);
          // Yer paragrafı kartın hemen üstünde.
          final bloklar = yzAyristir(kYzMetinler[no]!.metin(en));
          final i = bloklar.indexWhere((b) => b.tur == YzBlokTuru.gorsel && b.metin == k.kimlik);
          final paragraf = bloklar[i - 1].metin;
          final parca = paragraf.substring(0, 40).replaceAll('**', '');
          final p = find.textContaining(parca, findRichText: true);
          expect(p, findsWidgets, reason: parca);
          final ust = t.getRect(p.first);
          final kr = t.getRect(kart);
          expect(ust.top, lessThan(kr.top));
          expect(kr.top - ust.bottom, lessThan(400), reason: 'arada başka blok yok');
          await t.pumpWidget(const SizedBox());
        }
      });
    }
  });

  group('rota ve sekme', () {
    test('"sahadan" bir başlığın adresi sanılmıyor; yönlendiricide :slug\'dan önce', () {
      TestWidgetsFlutterBinding.ensureInitialized();
      final m = appRouter.configuration.findMatch(Uri.parse(yzSahadanPath));
      expect(m.last.route.path, yzSahadanPath);
      expect(appRouter.configuration.findMatch(Uri.parse(yzBaslikPath('sulama-ve-su'))).last.route.path,
          '$yzPath/:slug');
      expect(kYzBasliklar.map((b) => b.slug), isNot(contains('sahadan')));
      final r = File('lib/core/router/app_router.dart').readAsStringSync();
      expect(r.indexOf('path: yzSahadanPath'), greaterThan(0));
      expect(r.indexOf('path: yzSahadanPath'), lessThan(r.indexOf("path: '\$yzPath/:slug'")));
    });

    test('sekme başlığı', () {
      expect('${yzSekmeAdi(Uri.parse(yzSahadanPath), false)} | $kSiteAdi', 'Sahadan | Tarım Portalı');
      expect('${yzSekmeAdi(Uri.parse(yzSahadanPath), true)} | $kSiteAdi', 'From the Field | Tarım Portalı');
      expect(yzSekmeAdi(Uri.parse('$yzSahadanPath/x'), false), isNull, reason: 'alt adres yok');
    });
  });

  group('galeri', () {
    for (final olcu in const [Size(375, 812), Size(1280, 900), Size(1440, 900)]) {
      for (final dil in const ['tr', 'en']) {
        testWidgets('${olcu.width.toInt()} px · $dil · taşmıyor, sütunlar, bağlantılar', (t) async {
          await _boyut(t, olcu);
          final en = dil == 'en';
          await t.pumpWidget(_uygulama(const YzSahadanEkrani(), dil: dil));
          await t.pumpAndSettle();
          expect(t.takeException(), isNull);
          expect(find.text(en ? 'From the Field' : 'Sahadan'), findsOneWidget);
          expect(find.text(yzSahadanAciklamasi(en)), findsOneWidget);
          expect(
              yzSahadanAciklamasi(false),
              "Türkiye'de dijital tarımın sahadan fotoğrafları; her biri yayımlayan kurumun künyesi ve kaynağıyla.");
          expect(find.text(en ? 'Open the source ↗' : 'Kaynağı aç ↗'), findsNWidgets(8));
          for (final k in kYzSahadan) {
            final kart = find.byKey(ValueKey('yz-sahadan-kare-${k.harf}'));
            expect(kart, findsOneWidget);
            expect(find.descendant(of: kart, matching: find.text(k.kunye(en))), findsOneWidget);
            expect(find.descendant(of: kart, matching: find.text(k.kaynak(en))), findsOneWidget);
            expect(find.byKey(ValueKey('yz-sahadan-atlas-${k.harf}')), k.il == null ? findsNothing : findsOneWidget);
            expect(find.byKey(ValueKey('yz-sahadan-baslik-${k.harf}')), findsOneWidget);
            final r = t.getRect(kart);
            expect(r.right, lessThanOrEqualTo(olcu.width - 16 + 0.01), reason: 'yatay taşma yok');
            expect(r.left, greaterThanOrEqualTo(16 - 0.01));
          }
          final a = t.getRect(find.byKey(const ValueKey('yz-sahadan-kare-A')));
          final b = t.getRect(find.byKey(const ValueKey('yz-sahadan-kare-B')));
          final c = t.getRect(find.byKey(const ValueKey('yz-sahadan-kare-C')));
          final d = t.getRect(find.byKey(const ValueKey('yz-sahadan-kare-D')));
          if (olcu.width < 640) {
            expect(a.left, b.left, reason: 'telefonda tek sütun');
            expect(b.top, greaterThan(a.bottom));
            expect(a.width, closeTo(olcu.width - 32, 0.5));
          } else {
            expect((a.top, b.top, c.top), (a.top, a.top, a.top), reason: 'masaüstünde üç sütun');
            expect(b.left, greaterThan(a.right));
            expect(c.left, greaterThan(b.right));
            expect(d.left, a.left, reason: 'dördüncü kare yeni satırda');
            expect(d.top, greaterThan(a.bottom));
          }
          expect(find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.right),
              findsNothing);
          _solCizgiYok(t);
        });
      }
    }

    testWidgets('büyük yazı boyunda (A+) taşmıyor', (t) async {
      SharedPreferences.setMockInitialValues({'yz_yazi_olcegi': 1.4});
      for (final olcu in const [Size(375, 812), Size(1280, 900)]) {
        await _boyut(t, olcu);
        await t.pumpWidget(const SizedBox());
        await t.pumpWidget(_uygulama(const YzSahadanEkrani()));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull, reason: '${olcu.width}');
      }
    });

    for (final olcu in const [Size(375, 812), Size(1280, 900)]) {
      testWidgets('fotoğrafa dokununca tam ekran; oklar, klavye ve Esc · ${olcu.width.toInt()} px', (t) async {
        await _boyut(t, olcu);
        await t.pumpWidget(_uygulama(const YzSahadanEkrani()));
        await t.pumpAndSettle();
        final foto = find.byKey(const ValueKey('yz-sahadan-foto-B'));
        await t.ensureVisible(foto);
        await t.pumpAndSettle();
        await t.tap(foto);
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        expect(find.byType(YzSahadanTamEkran), findsOneWidget);
        expect(find.text('2 / 8'), findsOneWidget);
        final kunye = find.byKey(const ValueKey('yz-sahadan-tam-kunye'));
        expect(find.descendant(of: kunye, matching: find.text(_kare('B').kunyeTr)), findsOneWidget);
        expect(find.descendant(of: kunye, matching: find.text(_kare('B').kaynakTr)), findsOneWidget);
        expect(find.byKey(const ValueKey('yz-sahadan-tam-kaynak')), findsOneWidget);
        await t.tap(find.byTooltip('Sonraki'));
        await t.pumpAndSettle();
        expect(find.text('3 / 8'), findsOneWidget);
        expect(find.descendant(of: kunye, matching: find.text(_kare('C').kaynakTr)), findsOneWidget);
        await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await t.pumpAndSettle();
        expect(find.text('4 / 8'), findsOneWidget);
        await t.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await t.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await t.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await t.pumpAndSettle();
        expect(find.text('1 / 8'), findsOneWidget);
        expect(find.byTooltip('Önceki'), findsNothing, reason: 'ilk karede geri oku yok');
        // Yana kaydırma da geziyor (sola çekmek ileri).
        await t.drag(find.byType(InteractiveViewer), const Offset(-200, 0));
        await t.pumpAndSettle();
        expect(find.text('2 / 8'), findsOneWidget);
        await t.sendKeyEvent(LogicalKeyboardKey.escape);
        await t.pumpAndSettle();
        expect(find.byType(YzSahadanTamEkran), findsNothing);
        expect(t.takeException(), isNull);
      });
    }

    testWidgets('tam ekran İngilizce; son karede ileri oku yok; Kapat düğmesi', (t) async {
      await _boyut(t, const Size(1280, 900));
      await t.pumpWidget(_uygulama(const YzSahadanEkrani(), dil: 'en'));
      await t.pumpAndSettle();
      final foto = find.byKey(const ValueKey('yz-sahadan-foto-H'));
      await t.ensureVisible(foto);
      await t.pumpAndSettle();
      await t.tap(foto);
      await t.pumpAndSettle();
      expect(find.text('8 / 8'), findsOneWidget);
      expect(find.text('Open the source ↗'), findsWidgets);
      expect(find.byTooltip('Next'), findsNothing);
      expect(find.byTooltip('Previous'), findsOneWidget);
      await t.tap(find.byTooltip('Close'));
      await t.pumpAndSettle();
      expect(find.byType(YzSahadanTamEkran), findsNothing);
    });

    testWidgets('"Kaynağı aç" yayımlayan kurumun sayfasını açıyor (kart ve tam ekran)', (t) async {
      await _boyut(t, const Size(1280, 900));
      const kanal = MethodChannel('plugins.flutter.io/url_launcher');
      final acilan = <String>[];
      t.binding.defaultBinaryMessenger.setMockMethodCallHandler(kanal, (c) async {
        if (c.method == 'launch') acilan.add((c.arguments as Map)['url'] as String);
        return true;
      });
      addTearDown(() => t.binding.defaultBinaryMessenger.setMockMethodCallHandler(kanal, null));
      await t.pumpWidget(_uygulama(const YzSahadanEkrani()));
      await t.pumpAndSettle();
      final g = find.byKey(const ValueKey('yz-sahadan-kaynak-G'));
      await t.ensureVisible(g);
      await t.pumpAndSettle();
      await t.tap(g);
      await t.pumpAndSettle();
      expect(acilan, [_kare('G').sayfaAdresi]);
      final foto = find.byKey(const ValueKey('yz-sahadan-foto-E'));
      await t.ensureVisible(foto);
      await t.pumpAndSettle();
      await t.tap(foto);
      await t.pumpAndSettle();
      await t.tap(find.byKey(const ValueKey('yz-sahadan-tam-kaynak')));
      await t.pumpAndSettle();
      expect(acilan, [_kare('G').sayfaAdresi, _kare('E').sayfaAdresi]);
    });

    testWidgets('başlık bağlantısı alt başlığa (?bolum=), atlas bağlantısı ile (?il=)', (t) async {
      await _boyut(t, const Size(1280, 900));
      final r = GoRouter(initialLocation: yzSahadanPath, routes: [
        GoRoute(path: yzSahadanPath, builder: (c, s) => const YzSahadanEkrani()),
        GoRoute(
            path: yzAtlasPath,
            builder: (c, s) => Scaffold(body: Text('ATLAS ${s.uri.queryParameters['il']}'))),
        GoRoute(
            path: '$yzPath/:slug',
            builder: (c, s) =>
                Scaffold(body: Text('BAŞLIK ${s.pathParameters['slug']} ${s.uri.queryParameters['bolum']}'))),
      ]);
      await t.pumpWidget(_yonlendirici(r));
      await t.pumpAndSettle();
      Future<void> dokun(String anahtar) async {
        final f = find.byKey(ValueKey(anahtar));
        await t.ensureVisible(f);
        await t.pumpAndSettle();
        await t.tap(f);
        await t.pumpAndSettle();
      }

      expect(find.text('Dosyada: Sulama ve su yönetimi'), findsOneWidget);
      await dokun('yz-sahadan-baslik-E');
      expect(find.text('BAŞLIK sulama-ve-su turkiye'), findsOneWidget);
      r.pop();
      await t.pumpAndSettle();
      await dokun('yz-sahadan-baslik-A');
      expect(find.text('BAŞLIK sensorler-ve-iot turkiye'), findsOneWidget);
      r.pop();
      await t.pumpAndSettle();
      expect(find.text("Atlas'ta: Kocaeli"), findsNWidgets(2));
      await dokun('yz-sahadan-atlas-A');
      expect(find.text('ATLAS 41'), findsOneWidget);
      r.pop();
      await t.pumpAndSettle();
      await dokun('yz-sahadan-atlas-H');
      expect(find.text('ATLAS 7'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  group('atlas', () {
    test('ili olan her kare o ilin "Fotoğraf" kaydı; E atlasta yok', () {
      for (final en in [false, true]) {
        final k = yzAtlasKayitlari(en: en);
        expect(k[41]!.foto.map((f) => f.harf), ['A', 'B']);
        expect(k[23]!.foto.map((f) => f.harf), ['C']);
        expect(k[40]!.foto.map((f) => f.harf), ['D']);
        expect(k[1]!.foto.map((f) => f.harf), ['F']);
        expect(k[18]!.foto.map((f) => f.harf), ['G']);
        expect(k[7]!.foto.map((f) => f.harf), ['H']);
        final hepsi = [for (final x in k.values) ...x.foto];
        expect(hepsi.length, 7);
        expect(hepsi.map((f) => f.harf), isNot(contains('E')));
        // Kayıt sayısına giriyor (hücrenin rengi).
        expect(k[23]!.sayi, k[23]!.dosya.length + k[23]!.dizin.length + 1);
      }
    });

    for (final olcu in const [Size(1280, 900), Size(1440, 900)]) {
      for (final dil in const ['tr', 'en']) {
        testWidgets(
            'masaüstünde Kocaeli · ${olcu.width.toInt()} px · $dil: Fotoğraf kayıtları; dokununca ilin kareleri tam ekranda',
            (t) async {
          await _boyut(t, olcu);
          final en = dil == 'en';
          await t.pumpWidget(_uygulama(const YzAtlasEkrani(), dil: dil));
          await t.pumpAndSettle();
          await t.tap(find.byKey(const ValueKey('yz-atlas-hucre-41')));
          await t.pumpAndSettle();
          expect(t.takeException(), isNull);
          final bolum = find.byKey(const ValueKey('yz-atlas-fotograf'));
          expect(bolum, findsOneWidget);
          expect(find.descendant(of: bolum, matching: find.text('${en ? 'Photos' : 'Fotoğraf'}  2', findRichText: true)),
              findsOneWidget);
          expect(find.byKey(const ValueKey('yz-atlas-foto-A')), findsOneWidget);
          expect(find.byKey(const ValueKey('yz-atlas-foto-B')), findsOneWidget);
          expect(find.descendant(of: bolum, matching: find.text(_kare('A').kunye(en))), findsNWidgets(2));
          expect(find.descendant(of: bolum, matching: find.text(_kare('A').kaynak(en))), findsNWidgets(2));
          final kart = find.byKey(const ValueKey('yz-atlas-foto-B'));
          await t.ensureVisible(kart);
          await t.pumpAndSettle();
          await t.tap(kart);
          await t.pumpAndSettle();
          expect(find.byType(YzSahadanTamEkran), findsOneWidget);
          expect(find.text('2 / 2'), findsOneWidget, reason: 'ilin kareleri arasında');
          await t.sendKeyEvent(LogicalKeyboardKey.escape);
          await t.pumpAndSettle();
          expect(find.byType(YzSahadanTamEkran), findsNothing);
          expect(find.byKey(const ValueKey('yz-atlas-kayitlar')), findsOneWidget, reason: 'atlasa dönülüyor');
          expect(t.takeException(), isNull);
          _solCizgiYok(t);
        });
      }
    }

    for (final dil in const ['tr', 'en']) {
      testWidgets('telefonda alttan sayfada Fotoğraf · $dil · taşmıyor', (t) async {
        await _boyut(t, const Size(375, 812));
        await t.pumpWidget(_uygulama(const YzAtlasEkrani(), dil: dil));
        await t.pumpAndSettle();
        for (final p in [23, 41, 7]) {
          final satir = find.byKey(ValueKey('yz-atlas-satir-$p'));
          await t.ensureVisible(satir);
          await t.tap(satir);
          await t.pumpAndSettle();
          expect(t.takeException(), isNull, reason: '$p');
          final sayfa = find.byType(BottomSheet);
          expect(sayfa, findsOneWidget);
          expect(find.descendant(of: sayfa, matching: find.byKey(const ValueKey('yz-atlas-fotograf'))),
              findsOneWidget);
          final n = yzAtlasKayitlari(en: dil == 'en')[p]!.foto.length;
          expect(
              find.descendant(
                  of: sayfa, matching: find.text('${dil == 'en' ? 'Photos' : 'Fotoğraf'}  $n', findRichText: true)),
              findsOneWidget);
          Navigator.of(t.element(find.byKey(const ValueKey('yz-atlas-kayitlar')))).pop();
          await t.pumpAndSettle();
        }
      });
    }

    testWidgets('?il= ile o il seçili açılıyor: masaüstünde kayıtlar, telefonda alttan sayfa', (t) async {
      for (final olcu in const [Size(1280, 900), Size(375, 812)]) {
        await _boyut(t, olcu);
        final r = GoRouter(initialLocation: '$yzAtlasPath?il=41', routes: [
          GoRoute(path: yzAtlasPath, builder: (c, s) => const YzAtlasEkrani()),
        ]);
        await t.pumpWidget(const SizedBox());
        await t.pumpWidget(_yonlendirici(r));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        expect(find.byKey(const ValueKey('yz-atlas-kayitlar')), findsOneWidget, reason: '${olcu.width}');
        expect(find.byKey(const ValueKey('yz-atlas-fotograf')), findsOneWidget);
        expect(find.byType(BottomSheet), olcu.width < 640 ? findsOneWidget : findsNothing);
      }
      // Geçersiz ya da kaydı olmayan plaka yok sayılıyor.
      await _boyut(t, const Size(1280, 900));
      for (final il in ['99', 'x', '22']) {
        final r = GoRouter(initialLocation: '$yzAtlasPath?il=$il', routes: [
          GoRoute(path: yzAtlasPath, builder: (c, s) => const YzAtlasEkrani()),
        ]);
        await t.pumpWidget(const SizedBox());
        await t.pumpWidget(_yonlendirici(r));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull, reason: il);
        expect(find.byKey(const ValueKey('yz-atlas-kayitlar')), findsNothing, reason: il);
      }
    });
  });

  group('merkez sayfa', () {
    testWidgets('Sahadan kartı atlas kartının hemen altında, haberlerden önce; dokununca galeri', (t) async {
      await _boyut(t, const Size(1280, 900));
      final r = GoRouter(initialLocation: yzPath, routes: [
        GoRoute(path: yzPath, builder: (c, s) => const YzMerkezEkrani()),
        GoRoute(path: yzSahadanPath, builder: (c, s) => const YzSahadanEkrani()),
      ]);
      await t.pumpWidget(_yonlendirici(r, saglayicilar: [
        yzAtlasHaberleriProvider.overrideWith((ref) async => const <YzHaber>[]),
        yzBolumHaberleriProvider.overrideWith((ref, no) async =>
            no == null ? [_haber('m1', 'Merkez haberi', gun: DateTime(2026, 11, 21))] : const <YzHaber>[]),
        yzDizinEklenenlerProvider.overrideWith((ref) async => const <YzDizinKaydi>[]),
      ]));
      await t.pumpAndSettle();
      await t.pump(const Duration(milliseconds: 1600));
      await t.pumpAndSettle();
      final kart = find.byKey(const ValueKey('yz-sahadan-karti'));
      expect(kart, findsOneWidget);
      expect(find.descendant(of: kart, matching: find.text('Sahadan')), findsOneWidget);
      expect(find.descendant(of: kart, matching: find.text(yzSahadanAciklamasi(false))), findsOneWidget);
      final atlas = t.getRect(find.byKey(const ValueKey('yz-atlas-karti')));
      final s = t.getRect(kart);
      final haberler = t.getRect(find.byKey(const ValueKey('yz-merkez-haberleri')));
      expect(s.top - atlas.bottom, inInclusiveRange(0, 20), reason: 'hemen altında');
      expect(s.bottom, lessThanOrEqualTo(haberler.top));
      expect((s.left, s.width), (atlas.left, atlas.width), reason: 'aynı biçimde, aynı genişlikte');
      await t.ensureVisible(kart);
      await t.pumpAndSettle();
      await t.tap(kart);
      await t.pumpAndSettle();
      final ust = r.routerDelegate.currentConfiguration.last;
      expect(ust is ImperativeRouteMatch ? ust.matches.uri.path : ust.matchedLocation, yzSahadanPath);
      expect(find.byType(YzSahadanEkrani), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    for (final olcu in const [Size(375, 812), Size(1280, 900), Size(1440, 900)]) {
      for (final dil in const ['tr', 'en']) {
        testWidgets('Sahadan kartı · ${olcu.width.toInt()} px · $dil · taşmıyor, üç küçük resim', (t) async {
          await _boyut(t, olcu);
          await t.pumpWidget(
              _uygulama(const Scaffold(body: SingleChildScrollView(child: YzSahadanKarti())), dil: dil));
          await t.pumpAndSettle();
          expect(t.takeException(), isNull);
          expect(find.text(dil == 'en' ? kYzSahadanAdEn : kYzSahadanAdTr), findsOneWidget);
          final merkez = [for (final k in kYzSahadan) if (k.merkez) k.harf];
          expect(merkez.length, inInclusiveRange(2, 3));
          for (final h in merkez) {
            expect(find.byKey(ValueKey('yz-sahadan-kucuk-$h')), findsOneWidget);
          }
          // Küçük resmin kaynağı ipucunda.
          expect(find.byTooltip(_kare(merkez.first).kaynak(dil == 'en')), findsOneWidget);
          final r = t.getRect(find.byKey(const ValueKey('yz-sahadan-karti')));
          expect(r.right, lessThanOrEqualTo(olcu.width + 0.01));
          _solCizgiYok(t);
        });
      }
    }
  });
}
