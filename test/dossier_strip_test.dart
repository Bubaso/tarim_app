import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/features/dossiers/data/models/country_dossier.dart';
import 'package:tarim_app/features/dossiers/presentation/widgets/dossier_strip.dart';
import 'package:tarim_app/features/dossiers/providers/dossier_providers.dart';

import 'support/dossier_fixture.dart';

/// Şeridi ana sayfadaki gibi, ama yalnız kurar.
///
/// [ozet] null verilirse "yayında dosya yok" hâli sınanıyor.
Widget _sarmala(
  DossierSummary? ozet, {
  required bool isDark,
  required bool isEn,
  double spacing = 32,
}) {
  return ProviderScope(
    overrides: [
      activeDossierProvider.overrideWith((ref) async => ozet),
    ],
    child: _iskelet(isDark: isDark, isEn: isEn, spacing: spacing),
  );
}

/// Hiç tamamlanmayan istek — şeridin yükleme anındaki hâli.
Widget _sarmalaBekleyen({required bool isDark}) {
  return ProviderScope(
    overrides: [
      activeDossierProvider
          .overrideWith((ref) => Completer<DossierSummary?>().future),
    ],
    child: _iskelet(isDark: isDark, isEn: false, spacing: 32),
  );
}

/// Hata dönen istek.
Widget _sarmalaHatali({required bool isDark}) {
  return ProviderScope(
    overrides: [
      activeDossierProvider.overrideWith(
        (ref) async => throw StateError('ağ yok'),
      ),
    ],
    child: _iskelet(isDark: isDark, isEn: false, spacing: 32),
  );
}

Widget _iskelet({
  required bool isDark,
  required bool isEn,
  required double spacing,
}) {
  return MaterialApp(
    locale: Locale(isEn ? 'en' : 'tr'),
    // Uygulamanın kendi yığını. Türkçe kipte çerçeve metinleri bu delegeler
    // olmadan çöküyor.
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('tr'), Locale('en')],
    home: Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            DossierStrip(isDark: isDark, spacing: spacing),
            // Künyenin yerini tutuyor: şerit kaybolduğunda geriye boşluk
            // kalıp kalmadığı ancak altında bir şey varken ölçülebilir.
            const SizedBox(key: ValueKey('kunye'), height: 10),
          ],
        ),
      ),
    ),
  );
}

/// FutureProvider'ın çözülmesini bekler.
Future<void> _coz(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  final ozet = DossierFixture.hollanda().summary;

  group('yayında dosya yokken', () {
    testWidgets('tek piksel bile bırakmıyor', (tester) async {
      // Şeridin en önemli davranışı bu. Yirmi sekiz günlük pencerelerin
      // arasında dosya olmayan bir hafta olabilir; o hafta ana sayfanın
      // künyeden önce açıklanamayan bir boşluğu olmamalı.
      await tester.pumpWidget(_sarmala(null, isDark: false, isEn: false));
      await _coz(tester);

      expect(tester.getSize(find.byType(DossierStrip)).height, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('yüklenirken de iskelet göstermiyor', (tester) async {
      // İskelet kutu, gelmeyebilecek bir içeriğin sözünü verir; dosya
      // yoksa sonra çöker ve künye zıplar.
      await tester.pumpWidget(_sarmalaBekleyen(isDark: false));
      await _coz(tester);

      expect(tester.getSize(find.byType(DossierStrip)).height, 0);
    });

    testWidgets('istek hata verdiğinde de sessiz', (tester) async {
      await tester.pumpWidget(_sarmalaHatali(isDark: false));
      await _coz(tester);

      expect(tester.getSize(find.byType(DossierStrip)).height, 0);
      expect(tester.takeException(), isNull);
    });
  });

  for (final genislik in [360.0, 768.0, 1200.0]) {
    for (final isDark in [false, true]) {
      for (final isEn in [false, true]) {
        testWidgets(
            'şerit ${genislik.toInt()}px '
            '${isDark ? 'koyu' : 'açık'} '
            '${isEn ? 'en' : 'tr'} taşmadan çiziliyor', (tester) async {
          tester.view.physicalSize = Size(genislik, 1200);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(
            _sarmala(ozet, isDark: isDark, isEn: isEn),
          );
          await _coz(tester);

          expect(tester.takeException(), isNull);
          expect(find.text(ozet.name(isEn)), findsOneWidget);
          expect(find.text(ozet.thesis(isEn)), findsOneWidget);
        });
      }
    }
  }

  testWidgets('vurgu rengi zemine göre değişiyor', (tester) async {
    // Şeridin varlık sebebi olan kural. Hollanda'nın sodyum turuncusu
    // (#FF9E5E) beyaz üstünde 2,04:1 veriyor — okunmuyor. Açık modda
    // paletin koyulaştırılmış karşılığı (#AB4F16, 5,44:1) kullanılmalı.
    // Bu test kırılırsa şerit erişilemez hâle gelmiş demektir.
    tester.view.physicalSize = const Size(500, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    Future<Color?> okChizgisiRengi({required bool isDark}) async {
      await tester.pumpWidget(_sarmala(ozet, isDark: isDark, isEn: false));
      await _coz(tester);
      return tester
          .widget<Icon>(find.byIcon(Icons.arrow_forward_rounded))
          .color;
    }

    expect(await okChizgisiRengi(isDark: false), ozet.theme.seritVurgu);
    expect(await okChizgisiRengi(isDark: true), ozet.theme.vurgu);
    // Ve ikisi gerçekten farklı — tema tek renk döndürseydi test yeşil
    // kalır ama hiçbir şey kanıtlamazdı.
    expect(ozet.theme.seritVurgu, isNot(equals(ozet.theme.vurgu)));
  });

  testWidgets('geniş ekranda iki sütuna geçiyor', (tester) async {
    // Dar ekranda tez ülke adının ALTINDA, geniş ekranda SAĞINDA.
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    Future<(Offset ad, Offset tez)> yerler(double genislik) async {
      tester.view.physicalSize = Size(genislik, 1200);
      await tester.pumpWidget(_sarmala(ozet, isDark: false, isEn: false));
      await _coz(tester);
      return (
        tester.getTopLeft(find.text(ozet.nameTr)),
        tester.getTopLeft(find.text(ozet.thesisTr)),
      );
    }

    final dar = await yerler(360);
    expect(dar.$2.dy, greaterThan(dar.$1.dy), reason: 'darda tez altta değil');
    expect(dar.$2.dx, closeTo(dar.$1.dx, 1), reason: 'darda hizalar ayrışmış');

    final genis = await yerler(1200);
    expect(genis.$2.dx, greaterThan(genis.$1.dx),
        reason: 'genişte tez sağ sütuna geçmemiş');
  });

  testWidgets('bölüm sayısı ve kalan gün yazılı', (tester) async {
    tester.view.physicalSize = const Size(500, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_sarmala(ozet, isDark: false, isEn: false));
    await _coz(tester);

    expect(find.text('13 bölüm · 21 gün kaldı'), findsOneWidget);
  });

  testWidgets('süresiz dosyada gün sayacı hiç yazılmıyor', (tester) async {
    // daysRemaining null ya da 0 iken "0 gün kaldı" yazmak hem yanlış hem
    // caydırıcı olurdu; dosya hâlâ yayında.
    tester.view.physicalSize = const Size(500, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    for (final kalan in [null, 0]) {
      await tester.pumpWidget(
        _sarmala(_kalanGun(ozet, kalan), isDark: false, isEn: false),
      );
      await _coz(tester);

      expect(find.textContaining('gün kaldı'), findsNothing,
          reason: 'kalan=$kalan iken sayaç yazılmış');
      expect(find.text('13 bölüm'), findsOneWidget);
    }
  });

  testWidgets('İngilizce şeritte Türkçe metin kalmıyor', (tester) async {
    tester.view.physicalSize = const Size(500, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_sarmala(ozet, isDark: false, isEn: true));
    await _coz(tester);

    expect(find.text('COUNTRY DOSSIER · 01'), findsOneWidget);
    expect(find.text('Read the dossier'), findsOneWidget);
    expect(find.text('13 sections · 21 days left'), findsOneWidget);
    expect(find.textContaining('bölüm'), findsNothing);
    expect(find.textContaining('Dosyayı'), findsNothing);
  });

  testWidgets('şeridin tamamı tek dokunma hedefi', (tester) async {
    // Okuyucu karta nereye dokunursa dokunsun dosya açılmalı; ülke adının
    // üstündeki bir bağlantıyı aramak zorunda kalmamalı.
    tester.view.physicalSize = const Size(500, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_sarmala(ozet, isDark: false, isEn: false));
    await _coz(tester);

    final tiklanabilir = find.descendant(
      of: find.byType(DossierStrip),
      matching: find.byType(InkWell),
    );
    expect(tiklanabilir, findsOneWidget);

    // Kartın kendisi kadar geniş: iç kısımda ayrı bir küçük düğme yok.
    final kart = tester.getSize(find.byType(InkWell));
    expect(kart.width, greaterThan(300));
  });
}

/// [ozet]'in kalan gün sayısı değiştirilmiş kopyası.
DossierSummary _kalanGun(DossierSummary ozet, int? kalan) {
  return DossierSummary(
    slug: ozet.slug,
    nameTr: ozet.nameTr,
    nameEn: ozet.nameEn,
    iso3: ozet.iso3,
    edition: ozet.edition,
    thesisTr: ozet.thesisTr,
    thesisEn: ozet.thesisEn,
    theme: ozet.theme,
    coverUrl: ozet.coverUrl,
    daysRemaining: kalan,
    sectionCount: ozet.sectionCount,
  );
}
