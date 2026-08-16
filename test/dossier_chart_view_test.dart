import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/features/dossiers/data/models/country_dossier.dart';
import 'package:tarim_app/features/dossiers/data/models/dossier_chart.dart';
import 'package:tarim_app/features/dossiers/data/models/dossier_theme.dart';
import 'package:tarim_app/features/dossiers/presentation/widgets/dossier_chart_view.dart';

import 'support/dossier_fixture.dart';

/// Gerçek seed'deki 18 grafiği üç genişlikte çizer.
///
/// Bu testin yakaladığı şey `flutter analyze`'ın yakalayamadığı: taşan satır,
/// sıfıra bölünme, boş listede `.first`. Grafikler telefonda okunacak ve
/// etiketlerin bir kısmı uzun ("Tarım arazisinin örtüaltı payı"); dar ekranda
/// taşma en olası hata.
Widget _sarmala(DossierChart c, {required bool isEn}) {
  const tema = DossierTheme.yedek;
  return MaterialApp(
    home: Scaffold(
      backgroundColor: tema.zemin,
      body: SingleChildScrollView(
        child: DossierChartView(chart: c, tema: tema, isEn: isEn),
      ),
    ),
  );
}

void main() {
  // Testte ağdan yazı tipi çekilmesin; GoogleFonts varsayılana düşer.
  GoogleFonts.config.allowRuntimeFetching = false;

  final charts =
      CountryDossier.parseCharts(DossierFixture.hamCharts);

  for (final genislik in [360.0, 768.0, 1200.0]) {
    testWidgets('18 grafik ${genislik.toInt()}px genişlikte taşmadan çiziliyor',
        (tester) async {
      tester.view.physicalSize = Size(genislik, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      for (final c in charts.values) {
        for (final isEn in [false, true]) {
          await tester.pumpWidget(_sarmala(c, isEn: isEn));
          expect(
            tester.takeException(),
            isNull,
            reason: '${c.id} (${isEn ? 'en' : 'tr'}) ${genislik.toInt()}px\'te patladı',
          );
        }
      }
    });
  }

  testWidgets('her çubuğun rakamı METİN olarak da var', (tester) async {
    // Renk körlüğü şartının en derin karşılığı bu: ekrandaki tüm renk
    // kaybolsa bile grafik okunabilir kalmalı. Biçim farkı (taralı/düz)
    // yardımcı; asıl güvence rakamın yazılı olması.
    tester.view.physicalSize = const Size(500, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final siralama = charts['sera_urunler'] as SiralamaChart;
    await tester.pumpWidget(_sarmala(siralama, isEn: false));

    for (final satir in siralama.satirlar) {
      expect(
        find.text(siralama.bicim.bicimle(satir.deger, false)),
        findsWidgets,
        reason: '${satir.etiket.tr} çubuğunun rakamı yazılı değil',
      );
    }
  });

  testWidgets('yığın dilimleri yüzdesiyle birlikte yazılıyor', (tester) async {
    tester.view.physicalSize = const Size(500, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_sarmala(charts['ihracat_yigin']!, isEn: false));
    // Cironun %35,7'si, kazancın %11,6'sı — dosyanın ana savı bu iki sayıda.
    //
    // `textContaining` değil `text`: grafiğin NOT satırı da aynı iki rakamı
    // cümle içinde geçiriyor, gevşek arama ikisini birden yakalıyordu. Aranan
    // şey dilim etiketinin kendisi.
    expect(find.text('Yeniden ihracat · %35,7'), findsOneWidget);
    expect(find.text('Yeniden ihracat · %11,6'), findsOneWidget);
  });

  testWidgets('İngilizce sürümde yüzde sona geçiyor', (tester) async {
    tester.view.physicalSize = const Size(500, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_sarmala(charts['ihracat_yigin']!, isEn: true));
    expect(find.text('Re-export · 35.7%'), findsOneWidget);
    expect(find.textContaining('%35'), findsNothing);
  });

  testWidgets('kaynak künyesi her grafikte görünüyor', (tester) async {
    // Kaynağı olmayan bir rakam dosyanın kuralına aykırı; künye kaybolursa
    // izlenebilirlik zinciri ekranda kopar.
    tester.view.physicalSize = const Size(500, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    for (final c in charts.values) {
      expect(c.kaynak, isNotNull, reason: '${c.id} kaynaksız');
      await tester.pumpWidget(_sarmala(c, isEn: false));
      expect(find.text(c.kaynak!), findsOneWidget, reason: '${c.id} künyesi çizilmedi');
    }
  });
}
