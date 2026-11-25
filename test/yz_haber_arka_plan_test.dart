import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/features/dossiers/data/models/dosya_haberi.dart';
import 'package:tarim_app/features/dossiers/providers/dossier_providers.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_iskelet.g.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_haber_arka_plan.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_okuma.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_yollar.dart';
import 'package:tarim_app/features/yapay_zeka/yz_providers.dart';

// Kullanıcı (25 Kasım 2026): haberler dosyayı göstermiyordu. Bölümde bir
// başlığa bağlanmış haberin sonunda o başlığa tek bir davet.

const _dosya = HaberinDosyasi(slug: 'misir', nameTr: 'Mısır', tur: 'ulke', edition: 1, thesisTr: 'Tez.');

Future<void> _kur(WidgetTester t,
    {required int? baslik, List<HaberinDosyasi> dosyalar = const [], String dil = 'tr', Size boy = const Size(1280, 900)}) async {
  t.view.physicalSize = boy;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  final r = GoRouter(routes: [
    GoRoute(
        path: '/',
        builder: (c, s) => Scaffold(
            body: SingleChildScrollView(child: YzHaberArkaPlanKarti(articleId: 'h1', isEn: dil == 'en'))),
        routes: const []),
    GoRoute(path: '$yzPath/:slug', builder: (c, s) => Scaffold(body: Text('BAŞLIK ${s.pathParameters['slug']}'))),
  ]);
  await t.pumpWidget(ProviderScope(
    overrides: [
      yzHaberBasligiProvider.overrideWith((ref, id) async => baslik),
      haberDosyalariProvider.overrideWith((ref, id) async => dosyalar),
    ],
    child: MaterialApp.router(
      routerConfig: r,
      locale: Locale(dil),
      supportedLocales: const [Locale('tr'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    ),
  ));
  await t.pumpAndSettle();
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  final ormancilik = kYzBasliklar.firstWhere((b) => b.slug == 'ormancilik');

  for (final boy in const [Size(375, 812), Size(1280, 900)]) {
    testWidgets('etiketli haberde kart: başlık adı, özeti, okuma süresi · ${boy.width.toInt()}', (t) async {
      await _kur(t, baslik: ormancilik.no, boy: boy);
      expect(t.takeException(), isNull, reason: 'taşma yok');
      expect(find.text('Bu haberin arka planı: Ormancılık'), findsOneWidget);
      expect(find.text(ormancilik.ozetTr), findsOneWidget);
      expect(find.text(yzDakikaYazisi(kYzOkumaDakikalari[ormancilik.no]![0], false)), findsOneWidget);
    });
  }

  testWidgets('dokununca başlık açılıyor, giriş "haber" işaretleniyor', (t) async {
    await _kur(t, baslik: ormancilik.no);
    await t.tap(find.byKey(const ValueKey('yz-haber-arka-plan')));
    await t.pumpAndSettle();
    expect(find.text('BAŞLIK ormancilik'), findsOneWidget);
    expect(YzGiris.al(), 'haber');
  });

  testWidgets('İngilizce', (t) async {
    await _kur(t, baslik: ormancilik.no, dil: 'en');
    expect(find.text('Background to this story: Forestry'), findsOneWidget);
    expect(find.text(ormancilik.ozetEn), findsOneWidget);
  });

  testWidgets('etiket yoksa hiçbir şey', (t) async {
    await _kur(t, baslik: null);
    expect(find.byKey(const ValueKey('yz-haber-arka-plan')), findsNothing);
  });

  testWidgets('haberin ülke ya da kurum dosyası varsa çizilmiyor (tek davet)', (t) async {
    await _kur(t, baslik: ormancilik.no, dosyalar: const [_dosya]);
    expect(find.byKey(const ValueKey('yz-haber-arka-plan')), findsNothing);
  });

  testWidgets('başvuru sayfasına (sözlük, kaynakça) davet yok', (t) async {
    final sozluk = kYzBasliklar.firstWhere((b) => b.slug == 'sozluk');
    await _kur(t, baslik: sozluk.no);
    expect(find.byKey(const ValueKey('yz-haber-arka-plan')), findsNothing);
  });
}
