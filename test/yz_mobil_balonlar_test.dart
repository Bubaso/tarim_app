import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_deposu.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_kisaltmalar.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_rakam_kaynaklari.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_sozluk.g.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_balon_kabugu.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_kaynak_balonu.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_kisaltma.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_okuma.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_sozluk_esle.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_yollar.dart';
import 'package:tarim_app/features/yapay_zeka/yz_providers.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Mobil okuma turu (karar 62, 18 Kas 2026) — balonlar
// ──────────────────────────────────────────────────────────────────────────
//  Telefonda (< 640 px) kaynak, sözlük ve kısaltma balonu alttan açılan
//  sayfada; masaüstünde (≥ 640 px) dokunulan yerin yanındaki kart aynen.
// ══════════════════════════════════════════════════════════════════════════

List<Override> get _ortusmeler => [
      yzBolumHaberleriProvider.overrideWith((ref, no) async => const <YzHaber>[]),
      yzDizinEklenenlerProvider.overrideWith((ref) async => const <YzDizinKaydi>[]),
    ];

const _yerellik = [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

/// Tek düğmeli sayfa: düğme balonu açar.
Widget _uygulama(void Function(BuildContext c) ac, {String dil = 'tr'}) => ProviderScope(
      overrides: _ortusmeler,
      child: MaterialApp(
        locale: Locale(dil),
        supportedLocales: const [Locale('tr'), Locale('en')],
        localizationsDelegates: _yerellik,
        home: Scaffold(
          body: Builder(
            builder: (c) => Center(
              child: TextButton(onPressed: () => ac(c), child: const Text('AÇ')),
            ),
          ),
        ),
      ),
    );

/// Yönlendiricili: başlık sayfası (kayan liste içinde düğme) ve sözlük.
Widget _yonlendirmeli() {
  final r = GoRouter(initialLocation: yzBaslikPath('baslik'), routes: [
    GoRoute(
      path: '$yzPath/:slug',
      builder: (c, s) => s.pathParameters['slug'] == 'sozluk'
          ? Scaffold(
              body: Text('SÖZLÜK ${s.uri.queryParameters['terim']} '
                  '${s.uri.queryParameters['geri']}'))
          : Scaffold(
              body: ListView(children: [
                Builder(
                  builder: (c) => TextButton(
                    onPressed: () => yzTerimBalonu(
                        c, _terim, const Offset(180, 120), false,
                        geri: 'baslik'),
                    child: const Text('AÇ'),
                  ),
                ),
              ]),
            ),
    ),
  ]);
  return ProviderScope(
    overrides: _ortusmeler,
    child: MaterialApp.router(
      routerConfig: r,
      locale: const Locale('tr'),
      supportedLocales: const [Locale('tr'), Locale('en')],
      localizationsDelegates: _yerellik,
    ),
  );
}

final YzTerim _terim = kYzSozluk.firstWhere((t) => t.kimlik == 'makine-ogrenmesi');

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

Future<void> _ac(WidgetTester t) async {
  await t.tap(find.text('AÇ'));
  await t.pumpAndSettle();
  expect(t.takeException(), isNull);
}

Finder _sayfada(Finder f) => find.descendant(of: find.byType(BottomSheet), matching: f);

Finder _semantik(String etiket) =>
    find.byWidgetPredicate((w) => w is Semantics && w.properties.label == etiket);

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  setUp(() => SharedPreferences.setMockInitialValues({}));

  // b01'de "10" iki kaynağa bağlı: çok kaynaklı balon.
  final adaylar = kYzRakamKaynak['b01:tr']!['10']!;
  final kunyeler = kYzKaynakKunye['b01']!;
  final bagliSayisi = adaylar.where((a) => (kunyeler[a[0]]?[1] ?? '').isNotEmpty).length;
  final tagem = kYzKisaltmalar['TAGEM']!;

  group('telefon (375 px): alt sayfa', () {
    testWidgets('kaynak balonu alt sayfada; künye, alıntı, 48 px bağlantılar', (t) async {
      _telefon(t);
      await t.pumpWidget(_uygulama((c) => yzKaynakBalonu(c, 'b01', '10', const Offset(180, 300), false)));
      await _ac(t);
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(_sayfada(find.text('10')), findsOneWidget);
      expect(_sayfada(find.text('kaynaklar')), findsOneWidget);
      expect(t.widget<Text>(_sayfada(find.text('10'))).style!.fontSize, 18);
      for (final a in adaylar) {
        final kunye = _sayfada(find.text(kunyeler[a[0]]![0]));
        expect(kunye, findsOneWidget);
        expect(t.widget<Text>(kunye).style!.fontSize, 16.5);
        if (a[1].isNotEmpty) {
          expect(_sayfada(find.textContaining(a[1].substring(0, 20))), findsOneWidget);
        }
      }
      expect(_semantik('10 rakamının kaynağı'), findsOneWidget);
      expect(_sayfada(find.byType(SingleChildScrollView)), findsOneWidget,
          reason: 'uzunsa kayıyor');
      final baglantilar = _sayfada(find.byType(YzBalonEylemi));
      expect(baglantilar, findsNWidgets(bagliSayisi));
      for (final e in baglantilar.evaluate()) {
        final r = t.getRect(find.byWidget(e.widget));
        expect(r.height, 48);
        expect(r.width, closeTo(375 - 40, 0.5), reason: 'tam genişlik, 20 px kenar');
      }
      // Dışarı (karartmaya) dokununca kapanıyor.
      await t.tapAt(const Offset(187, 20));
      await t.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
    });

    testWidgets('kısaltma balonu alt sayfada; aşağı çekince kapanıyor', (t) async {
      _telefon(t);
      await t.pumpWidget(_uygulama((c) => yzKisaltmaBalonu(c, 'TAGEM', const Offset(180, 300), false)));
      await _ac(t);
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(t.widget<Text>(_sayfada(find.text('TAGEM'))).style!.fontSize, 18);
      final acilim = _sayfada(find.text(tagem.acilim(false)));
      expect(acilim, findsOneWidget);
      expect(t.widget<Text>(acilim).style!.fontSize, 16.5);
      expect(_semantik('TAGEM'), findsOneWidget);
      // İçerik 20 px kenar boşluğuyla.
      expect(t.getTopLeft(acilim).dx, 20);
      await t.drag(find.byType(BottomSheet), const Offset(0, 500));
      await t.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
    });

    testWidgets('kısaltma balonu İngilizce', (t) async {
      _telefon(t);
      await t.pumpWidget(
          _uygulama((c) => yzKisaltmaBalonu(c, 'TAGEM', const Offset(180, 300), true), dil: 'en'));
      await _ac(t);
      expect(_sayfada(find.text(tagem.acilim(true))), findsOneWidget);
    });

    testWidgets('terim balonu alt sayfada; "Sözlükte aç" sayfayı kapatıp gidiyor', (t) async {
      _telefon(t);
      await t.pumpWidget(_yonlendirmeli());
      await t.pumpAndSettle();
      await _ac(t);
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(t.widget<Text>(_sayfada(find.text(_terim.ad(false)))).style!.fontSize, 18);
      final tanim = _sayfada(find.text(_terim.tanim(false)));
      expect(tanim, findsOneWidget);
      expect(t.widget<Text>(tanim).style!.fontSize, 16.5);
      expect(_sayfada(find.text(_terim.kaynak(false))), findsOneWidget);
      expect(_semantik(_terim.ad(false)), findsOneWidget);
      final eylem = _sayfada(find.widgetWithText(YzBalonEylemi, 'Sözlükte aç'));
      expect(t.getSize(eylem), const Size(375 - 40, 48));
      await t.tap(eylem);
      await t.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.text('SÖZLÜK makine-ogrenmesi baslik'), findsOneWidget);
      expect(YzOkumaKonumu.al('baslik'), 0, reason: 'kaydırma konumu saklandı');
    });

    testWidgets('alt güvenli alan: eylem iPhone çubuğunun altına girmiyor', (t) async {
      _telefon(t);
      t.view.padding = const FakeViewPadding(bottom: 34);
      await t.pumpWidget(_yonlendirmeli());
      await t.pumpAndSettle();
      await _ac(t);
      final eylem = _sayfada(find.byType(YzBalonEylemi));
      expect(t.getRect(eylem).bottom, lessThanOrEqualTo(812 - 34));
    });
  });

  group('masaüstü (1280 px): yanında kart, değişmedi', () {
    testWidgets('kaynak balonu kart olarak; alt sayfa yok', (t) async {
      _masaustu(t);
      await t.pumpWidget(_uygulama((c) => yzKaynakBalonu(c, 'b01', '10', const Offset(400, 300), false)));
      await _ac(t);
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.byType(YzBalonEylemi), findsNothing);
      expect(find.text('10 · kaynaklar'), findsOneWidget);
      for (final a in adaylar) {
        final kunye = find.text(kunyeler[a[0]]![0]);
        expect(kunye, findsOneWidget);
        expect(t.widget<Text>(kunye).style!.fontSize, 14);
      }
      expect(find.text('Kaynağı aç ↗'), findsNWidgets(bagliSayisi));
      expect(_semantik('10 rakamının kaynağı'), findsOneWidget);
      // Kart dokunulan yerin altında, 380 px genişlikte.
      final kart = find.ancestor(of: _semantik('10 rakamının kaynağı'), matching: find.byType(Positioned));
      expect(t.getRect(kart).left, 400 - 190);
      expect(t.getRect(kart).width, 380);
      expect(t.getRect(kart).top, 316);
      await t.tapAt(const Offset(5, 890));
      await t.pumpAndSettle();
      expect(find.text('10 · kaynaklar'), findsNothing);
    });

    testWidgets('kısaltma balonu kart olarak; alt sayfa yok', (t) async {
      _masaustu(t);
      await t.pumpWidget(_uygulama((c) => yzKisaltmaBalonu(c, 'TAGEM', const Offset(400, 300), false)));
      await _ac(t);
      expect(find.byType(BottomSheet), findsNothing);
      expect(t.widget<Text>(find.text('TAGEM')).style!.fontSize, 13);
      expect(t.widget<Text>(find.text(tagem.acilim(false))).style!.fontSize, 15.5);
      final kart = find.ancestor(of: _semantik('TAGEM'), matching: find.byType(Positioned));
      expect(t.getRect(kart).width, 320);
    });

    testWidgets('terim balonu kart olarak; "Sözlükte aç" yine gidiyor', (t) async {
      _masaustu(t);
      await t.pumpWidget(_yonlendirmeli());
      await t.pumpAndSettle();
      await _ac(t);
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.byType(YzBalonEylemi), findsNothing);
      expect(t.widget<Text>(find.text(_terim.ad(false))).style!.fontSize, 17);
      final kart = find.ancestor(of: _semantik(_terim.ad(false)), matching: find.byType(Positioned));
      expect(t.getRect(kart).width, 340);
      await t.tap(find.widgetWithText(TextButton, 'Sözlükte aç'));
      await t.pumpAndSettle();
      expect(find.text('SÖZLÜK makine-ogrenmesi baslik'), findsOneWidget);
    });
  });
}
