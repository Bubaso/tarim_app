import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/features/dossiers/data/models/country_dossier.dart';
import 'package:tarim_app/features/dossiers/presentation/screens/country_dossier_screen.dart';
import 'package:tarim_app/features/dossiers/providers/dossier_providers.dart';

import 'support/dossier_fixture.dart';

/// Sayfanın tamamını gerçek dosyayla çizer.
///
/// Grafik testleri tek tek kutuları sınıyordu; buradaki soru başka: on üç
/// bölüm, on sekiz grafik, veri notları ve künye AYNI sayfada yan yana
/// dururken bir şey taşıyor mu, bir dil karışıyor mu.
Widget _sarmala(CountryDossier dosya, {required bool isEn}) {
  return ProviderScope(
    overrides: [
      // Ağ yok: sayfa provider'ı doğrudan seed'den kurulan dosyaya bağlanıyor.
      dossierBySlugProvider('hollanda').overrideWith((ref) async => dosya),
    ],
    child: MaterialApp(
      locale: Locale(isEn ? 'en' : 'tr'),
      // Uygulamanın kendi yığınının aynısı. Varsayılan MaterialApp yalnızca
      // İngilizce taşıyor; geri düğmesinin ipucu gibi çerçeve metinleri
      // Türkçe kipte bu delege olmadan çöküyor.
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr'), Locale('en')],
      home: const CountryDossierScreen(slug: 'hollanda'),
    ),
  );
}

/// Kaydırılabilir sayfayı baştan sona sürer.
///
/// `pumpWidget` yalnızca ilk ekranı kurar; bölümler `SliverList.builder` ile
/// tembel olduğu için alt taraf hiç kurulmaz ve oradaki bir taşma testten
/// kaçardı. Bu yüzden sayfa gerçekten sonuna kadar kaydırılıyor.
Future<void> _sonaKadarKaydir(WidgetTester tester, {required bool isEn}) async {
  final liste = find.byType(CustomScrollView);
  final son = find.text(isEn ? 'SOURCES' : 'KAYNAKLAR');

  // Sona VARDIĞI doğrulanıyor. Sabit sayıda sürükleyip bırakmak, sayfa
  // uzadığında testin sessizce yarısını sınamasına yol açardı; künye
  // görünmeden döngü bitmiyor.
  for (var i = 0; i < 200; i++) {
    if (son.evaluate().isNotEmpty) return;
    await tester.drag(liste, const Offset(0, -700));
    await tester.pump();
    expect(tester.takeException(), isNull, reason: '$i. kaydırmada patladı');
  }
  fail('Sayfanın sonundaki kaynak künyesine ulaşılamadı.');
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  final dosya = DossierFixture.hollanda();

  testWidgets('seed doğru okunuyor: 13 bölüm, 18 grafik', (tester) async {
    // Fixture'ın kendisi de sınanmalı. Bölüm ayrıştırıcısı sessizce üç bölüm
    // döndürseydi aşağıdaki tüm testler yeşil kalır ama hiçbir şey kanıtlamazdı.
    expect(dosya.sections.length, 13);
    expect(dosya.charts.length, 18);
    expect(dosya.summary.nameTr, 'Hollanda');
    expect(dosya.summary.nameEn, 'Netherlands');
    expect(dosya.gaps.length, 5);
    expect(dosya.sources, isNotEmpty);
    // Her bölümün grafik anahtarı gerçekten bir grafiğe denk gelmeli;
    // gelmiyorsa seed'de sahipsiz anahtar var demektir.
    for (final b in dosya.sections) {
      expect(dosya.chartsFor(b).length, b.chartKeys.length,
          reason: '${b.ord}. bölümde tanınmayan grafik anahtarı var');
    }
  });

  for (final genislik in [360.0, 768.0, 1200.0]) {
    for (final isEn in [false, true]) {
      testWidgets(
          'tam sayfa ${genislik.toInt()}px ${isEn ? 'en' : 'tr'} taşmadan çiziliyor',
          (tester) async {
        tester.view.physicalSize = Size(genislik, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(_sarmala(dosya, isEn: isEn));
        await tester.pump();
        expect(tester.takeException(), isNull, reason: 'kapak patladı');

        await _sonaKadarKaydir(tester, isEn: isEn);
      });
    }
  }

  testWidgets('kapak görselsiz de tam çalışıyor', (tester) async {
    // Faz 3'ün yazılı şartı. Seed'de cover_url şu an null; sayfa yine de
    // ülke adını, tez cümlesini ve ilk bölümü göstermeli.
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    expect(dosya.summary.coverUrl, isNull);
    await tester.pumpWidget(_sarmala(dosya, isEn: false));
    await tester.pump();

    expect(find.text('Hollanda'), findsWidgets);
    expect(find.text(dosya.summary.thesisTr), findsOneWidget);
    expect(find.text('ÜLKE DOSYASI · 01'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('kapak görseli geldiğinde metin yerinde kalıyor', (tester) async {
    // Görsel bir KATMAN, taşıyıcı değil: eklenince kapağın dört unsuru
    // (seri etiketi, ülke adı, tez, pencere) aynen durmalı. Görsel testte
    // ağdan gelmiyor; burada sınanan yerleşim, indirme değil.
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final gorselli = DossierFixture.hollanda(
      coverUrl: 'https://example.invalid/kapak.jpg',
    );
    await tester.pumpWidget(_sarmala(gorselli, isEn: false));
    await tester.pump();

    expect(find.text('ÜLKE DOSYASI · 01'), findsOneWidget);
    expect(find.text(gorselli.summary.thesisTr), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('İngilizce sayfada Türkçe metin kalmıyor', (tester) async {
    // Veri notları paneli uzun süre yalnızca Türkçeydi; İngilizce sayfada
    // Türkçe kalması tam da güven vermesi gereken yerde okunmazlık üretirdi.
    for (final b in dosya.gaps) {
      expect(b.konu(true), isNot(equals(b.konu(false))),
          reason: '"${b.konuTr}" başlığının İngilizcesi yok');
      expect(b.sorun(true), isNot(equals(b.sorun(false))));
      expect(b.cozum(true), isNot(equals(b.cozum(false))));
    }
    for (final b in dosya.sections) {
      expect(b.title(true), isNot(equals(b.title(false))),
          reason: '${b.ord}. bölüm başlığı çevrilmemiş');
      expect(b.body(true), isNot(equals(b.body(false))));
    }
  });

  testWidgets('sayfa açık/koyu sistem tercihini izlemiyor', (tester) async {
    // Dosya sayfası bilerek bir koyu ada. Aynı dosya iki farklı sistem
    // tercihiyle çizildiğinde zemin DEĞİŞMEMELİ.
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    Color zeminOku() {
      final scaffold = tester.widget<Scaffold>(
        find.descendant(
          of: find.byType(CountryDossierScreen),
          matching: find.byType(Scaffold),
        ),
      );
      return scaffold.backgroundColor!;
    }

    final renkler = <Color>[];
    for (final parlaklik in [Brightness.light, Brightness.dark]) {
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(platformBrightness: parlaklik),
          child: _sarmala(dosya, isEn: false),
        ),
      );
      await tester.pump();
      renkler.add(zeminOku());
    }

    expect(renkler[0], renkler[1]);
    // Ve gerçekten koyu — temanın kendi zemini.
    expect(renkler[0], dosya.summary.theme.zemin);
  });
}
