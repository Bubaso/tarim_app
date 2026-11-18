import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarim_app/core/utils/turkce_metin.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_deposu.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_iskelet.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_metinler.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_teknoloji.g.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_harita.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_merkez_ekrani.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_merkez_liste.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_okuma.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_tasarim.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_yollar.dart';
import 'package:tarim_app/features/yapay_zeka/yz_providers.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Mobil tur · merkez sayfa (18 Kas 2026)
// ──────────────────────────────────────────────────────────────────────────
//  ★20 telefonda karosuz başlık listesi · ★2 çip satırında sağ solgunluk ·
//  ★10 okuma süresi düz yazıyla. Masaüstü ızgarası DEĞİŞMEDİ.
// ══════════════════════════════════════════════════════════════════════════

List<Override> get _gecersiz => [
      yzBolumHaberleriProvider.overrideWith((ref, no) async => const <YzHaber>[]),
      yzDizinEklenenlerProvider.overrideWith((ref) async => const <YzDizinKaydi>[]),
    ];

const _yerellik = [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

Widget _uygulama(Widget cocuk, {String dil = 'tr'}) => ProviderScope(
      overrides: _gecersiz,
      child: MaterialApp(
        locale: Locale(dil),
        supportedLocales: const [Locale('tr'), Locale('en')],
        localizationsDelegates: _yerellik,
        home: cocuk,
      ),
    );

/// Başlık sayfası yerine adresi yazan bir ekran: satırın nereye gittiği.
Widget _yonlendirmeli({String dil = 'tr'}) {
  final r = GoRouter(initialLocation: yzPath, routes: [
    GoRoute(path: yzPath, builder: (c, s) => const YzMerkezEkrani()),
    GoRoute(
      path: '$yzPath/:slug',
      builder: (c, s) => Scaffold(body: Text('GİDİLEN ${s.uri}')),
    ),
  ]);
  return ProviderScope(
    overrides: _gecersiz,
    child: MaterialApp.router(
      routerConfig: r,
      locale: Locale(dil),
      supportedLocales: const [Locale('tr'), Locale('en')],
      localizationsDelegates: _yerellik,
    ),
  );
}

/// Haritayı tek başına, verilen genişlikte (merkez sayfadaki yan boşlukla).
Widget _harita({String dil = 'tr'}) => _uygulama(
      const Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: YzHarita(),
        ),
      ),
      dil: dil,
    );

void _telefon(WidgetTester t) {
  t.view.physicalSize = const Size(375, 812);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

void _masaustu(WidgetTester t) {
  t.view.physicalSize = const Size(1280, 900);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

String _ailesi(WidgetTester t, Finder f) => t.widget<Text>(f).style?.fontFamily ?? '';

Finder _cip(String ad) => find.widgetWithText(YzTeknolojiCipi, ad);

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final ilk = kYzBasliklar.first;
  final dakika = yzOkumaSuresi(kYzMetinler[ilk.no]!.metin(false), false);

  group('telefon · başlık listesi (★20)', () {
    testWidgets('karo yok; her başlık bir satır, en az 52 piksel', (t) async {
      _telefon(t);
      await t.pumpWidget(_harita());
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.byType(YzBaslikKarosu), findsNothing);
      expect(find.byType(YzBaslikSatiri), findsNWidgets(kYzBasliklar.length));
      for (final e in find.byType(YzBaslikSatiri).evaluate()) {
        expect(e.size!.height, greaterThanOrEqualTo(52));
        expect(e.size!.width, greaterThan(300), reason: 'tek sütun, tam genişlik');
      }
      // Satırlar çerçevesiz: ince çizgiyle ayrılıyor (katman başına n-1).
      final katmanSayisi = kYzBasliklar.map((b) => b.katman).toSet().length;
      expect(find.byType(YzMerkezCizgi), findsNWidgets(kYzBasliklar.length - katmanSayisi));
      final satirKutulari = find.descendant(
          of: find.byType(YzBaslikSatiri), matching: find.byType(DecoratedBox));
      for (final e in satirKutulari.evaluate()) {
        final d = (e.widget as DecoratedBox).decoration;
        if (d is BoxDecoration) expect(d.border, isNull, reason: 'satırda kutu çerçevesi yok');
      }
      // Katman etiketi duruyor.
      expect(find.text(buyukKatman('cerceve')), findsOneWidget);
    });

    testWidgets('başlık Outfit 16 w600; süre düz yazı "N dk", mono değil (★10)', (t) async {
      _telefon(t);
      await t.pumpWidget(_harita());
      await t.pumpAndSettle();
      final ad = find.descendant(of: find.byType(YzBaslikSatiri), matching: find.text(ilk.tr));
      final s = t.widget<Text>(ad).style!;
      expect(s.fontSize, 16);
      expect(s.fontWeight, FontWeight.w600);
      expect(s.color, YzRenk.murekkep);
      expect(s.fontFamily, contains('Outfit'));
      final sure = find.text('$dakika dk').first;
      expect(_ailesi(t, sure), contains('Outfit'));
      expect(t.widget<Text>(sure).style!.color, YzRenk.soluk);
      expect(find.textContaining('dk okuma'), findsNothing, reason: 'telefonda kısa: "N dk"');
      expect(find.text('✓'), findsNothing, reason: 'okunmamış');
    });

    testWidgets('okunan başlıkta ✓; okuma izi sağlayıcısından', (t) async {
      SharedPreferences.setMockInitialValues({
        'yz_okunan': [yzBaslikPath(ilk.slug)],
      });
      _telefon(t);
      await t.pumpWidget(_harita());
      await t.pumpAndSettle();
      final satir = find.widgetWithText(YzBaslikSatiri, ilk.tr);
      expect(find.descendant(of: satir, matching: find.text('✓')), findsOneWidget);
      expect(find.text('✓'), findsOneWidget);
    });

    testWidgets('satır sık: karo gibi şişmiyor, seçimsizken kesişim cümlesi yok', (t) async {
      _telefon(t);
      await t.pumpWidget(_harita());
      await t.pumpAndSettle();
      // Başlık en çok üç satır (16 px, 1,25): 52 + 2 × 20.
      for (final e in find.byType(YzBaslikSatiri).evaluate()) {
        expect(e.size!.height, lessThanOrEqualTo(92));
      }
      for (final m in kYzKesisim.values) {
        for (final c in m.values) {
          expect(find.text(c[0]), findsNothing);
        }
      }
    });

    testWidgets('satıra dokununca başlık sayfası', (t) async {
      _telefon(t);
      await t.pumpWidget(_yonlendirmeli());
      await t.pumpAndSettle();
      final satir = find.widgetWithText(YzBaslikSatiri, ilk.tr);
      await t.ensureVisible(satir);
      await t.pumpAndSettle();
      // Başlığın yanına değil, satırın sağ boşluğuna: bütün satır dokunulabilir.
      final r = t.getRect(satir);
      await t.tapAt(Offset(r.right - 4, r.center.dy));
      await t.pumpAndSettle();
      expect(find.text('GİDİLEN ${yzBaslikPath(ilk.slug)}'), findsOneWidget);
    });

    testWidgets('teknoloji seçilince: sayı, ana başlık, sönük, ?teknoloji= ile gidiş', (t) async {
      _telefon(t);
      await t.pumpWidget(_yonlendirmeli());
      await t.pumpAndSettle();
      const kod = 'dil';
      final ad = kYzTeknoloji[kod]!['tr']!;
      await t.ensureVisible(_cip(ad));
      await t.pumpAndSettle();
      await t.tap(_cip(ad));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      final sayi = kYzBasliklar.where((b) => b.teknoloji.contains(kod)).length;
      expect(find.textContaining('$ad $sayi başlıkta geçiyor'), findsOneWidget);

      final anaNo = kYzTeknolojiAna[kod]!.first;
      final tasiyan = kYzBasliklar.firstWhere(
          (b) => b.teknoloji.contains(kod) && !kYzTeknolojiAna[kod]!.contains(b.no));
      final tasimayan = kYzBasliklar.firstWhere((b) => !b.teknoloji.contains(kod));
      final anaB = yzBaslik(anaNo)!;

      // Taşıyan başlık: kaç yerde geçtiği, kesişim cümlesi.
      final iz = kYzTeknolojiIzi[tasiyan.no]![kod]![0];
      final tasiyanSatir = find.widgetWithText(YzBaslikSatiri, tasiyan.tr);
      expect(find.descendant(of: tasiyanSatir, matching: find.text('$iz yerde')), findsOneWidget);
      final kesisim = kYzKesisim[kod]?[tasiyan.no]?[0];
      if (kesisim != null) {
        expect(find.descendant(of: tasiyanSatir, matching: find.text(kesisim)), findsOneWidget);
      }
      // Ana başlık: "ana · N", yumuşak mavi zemin.
      final anaIz = kYzTeknolojiIzi[anaB.no]![kod]![0];
      final anaSatir = find.widgetWithText(YzBaslikSatiri, anaB.tr);
      expect(find.descendant(of: anaSatir, matching: find.text('ana · $anaIz')), findsOneWidget);
      final zemin = t.widget<Material>(
          find.descendant(of: anaSatir, matching: find.byType(Material)).first);
      expect(zemin.color, YzRenk.makineAcik);
      // Taşımayan: sönük, sayı yok, okuma süresi duruyor.
      final sonukSatir = find.widgetWithText(YzBaslikSatiri, tasimayan.tr);
      final opak = t.widget<AnimatedOpacity>(
          find.descendant(of: sonukSatir, matching: find.byType(AnimatedOpacity)).first);
      expect(opak.opacity, closeTo(0.32, 0.001));
      expect(t.widget<AnimatedOpacity>(find.descendant(
              of: tasiyanSatir, matching: find.byType(AnimatedOpacity)).first).opacity, 1);
      expect(find.descendant(of: sonukSatir, matching: find.textContaining('yerde')), findsNothing);

      // Dokununca o teknolojinin yerleri işaretli açılıyor.
      await t.ensureVisible(tasiyanSatir);
      await t.pumpAndSettle();
      await t.tap(tasiyanSatir);
      await t.pumpAndSettle();
      expect(find.text('GİDİLEN ${yzBaslikPath(tasiyan.slug)}?teknoloji=$kod'), findsOneWidget);
    });

    testWidgets('İngilizce: "N min", "N mentions", taşma yok', (t) async {
      _telefon(t);
      await t.pumpWidget(_harita(dil: 'en'));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      final d = yzOkumaSuresi(kYzMetinler[ilk.no]!.metin(true), true);
      expect(find.descendant(of: find.widgetWithText(YzBaslikSatiri, ilk.en), matching: find.text('$d min')),
          findsOneWidget);
      await t.ensureVisible(_cip(kYzTeknoloji['dil']!['en']!));
      await t.pumpAndSettle();
      await t.tap(_cip(kYzTeknoloji['dil']!['en']!));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.textContaining(RegExp(r'^\d+ mentions$')), findsWidgets);
    });

    testWidgets('merkez sayfa telefonda: sayı satırı düz yazı, taşma yok', (t) async {
      _telefon(t);
      await t.pumpWidget(_uygulama(const YzMerkezEkrani()));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(_ailesi(t, find.text('${kYzBasliklar.length} başlık')), contains('Outfit'));
      expect(find.byType(YzBaslikSatiri), findsNWidgets(kYzBasliklar.length));
      expect(find.textContaining('karolar'), findsNothing, reason: 'telefonda karo yok');
    });
  });

  group('telefon · çip satırı (★2)', () {
    testWidgets('taşıyorsa sağda solgunluk, sonuna gelince kalkıyor; dokunma 44 px', (t) async {
      _telefon(t);
      await t.pumpWidget(_harita());
      await t.pumpAndSettle();
      expect(find.byType(YzMerkezCipSeridi), findsOneWidget);
      double solgunluk() =>
          t.widget<AnimatedOpacity>(find.byKey(YzMerkezCipSeridi.solgunlukAnahtari)).opacity;
      expect(solgunluk(), 1, reason: 'çipler 343 piksele sığmıyor');
      final kaydirma = find.descendant(
          of: find.byType(YzMerkezCipSeridi), matching: find.byType(Scrollable));
      final durum = t.state<ScrollableState>(kaydirma);
      durum.position.jumpTo(durum.position.maxScrollExtent);
      await t.pumpAndSettle();
      expect(solgunluk(), 0, reason: 'sona gelindi');
      durum.position.jumpTo(0);
      await t.pumpAndSettle();
      expect(solgunluk(), 1);
      for (final e in find.byType(YzTeknolojiCipi).evaluate()) {
        expect(e.size!.height, greaterThanOrEqualTo(44));
      }
      // Görünen çipin üstündeki boşluğa dokunmak da seçiyor.
      final ad = kYzTeknoloji.values.first['tr']!;
      final r = t.getRect(_cip(ad));
      await t.tapAt(Offset(r.center.dx, r.top + 2));
      await t.pumpAndSettle();
      expect(find.textContaining('$ad '), findsWidgets);
      expect(find.textContaining('başlıkta geçiyor'), findsOneWidget);
    });

    testWidgets('sığıyorsa solgunluk yok', (t) async {
      _telefon(t);
      await t.pumpWidget(_uygulama(const Scaffold(
        body: YzMerkezCipSeridi(children: [Text('kısa')]),
      )));
      await t.pumpAndSettle();
      expect(
          t.widget<AnimatedOpacity>(find.byKey(YzMerkezCipSeridi.solgunlukAnahtari)).opacity, 0);
    });
  });

  group('masaüstü 1280×900 · değişmedi', () {
    testWidgets('karo ızgarası, sarılan çipler, mono süre', (t) async {
      _masaustu(t);
      await t.pumpWidget(_uygulama(const YzMerkezEkrani()));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.byType(YzBaslikKarosu), findsNWidgets(kYzBasliklar.length));
      expect(find.byType(YzBaslikSatiri), findsNothing);
      expect(find.byType(YzMerkezCizgi), findsNothing);
      expect(find.byType(YzMerkezCipSeridi), findsNothing);
      expect(find.ancestor(of: find.byType(YzTeknolojiCipi).first, matching: find.byType(Wrap)),
          findsWidgets);
      // Çip eski boyunda (geniş dokunma alanı yalnız telefonda).
      expect(t.getSize(find.byType(YzTeknolojiCipi).first).height, lessThan(44));
      // Karo: aynı etiket, mono.
      final etiket = find.text('$dakika dk okuma').first;
      expect(_ailesi(t, etiket), contains('IBMPlexMono'));
      expect(_ailesi(t, find.text('${kYzBasliklar.length} başlık')), contains('IBMPlexMono'));
      expect(find.textContaining('karolar o teknolojinin'), findsOneWidget);
      // Karo 196 piksel genişliğinde, çerçeveli.
      expect(t.getSize(find.byType(YzBaslikKarosu).first).width, 196);

      await t.ensureVisible(_cip('Dil modelleri'));
      await t.pumpAndSettle();
      await t.tap(_cip('Dil modelleri'));
      await t.pumpAndSettle();
      expect(find.textContaining('yerde geçiyor'), findsWidgets, reason: 'karo etiketi aynı');
    });
  });
}

String buyukKatman(String k) => buyukHarf(kYzKatmanlar[k]!['tr']!, false);
