import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/core/theme/app_typography.dart';
import 'package:tarim_app/features/dossiers/data/models/country_dossier.dart';
import 'package:tarim_app/features/dossiers/presentation/screens/country_dossier_screen.dart';
import 'package:tarim_app/features/dossiers/presentation/widgets/dossier_contents_sheet.dart';
import 'package:tarim_app/features/dossiers/providers/dossier_providers.dart';
import 'package:tarim_app/features/home/presentation/widgets/reading_progress_bar.dart';

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

  // ─── İçindekiler paneli ───────────────────────────────────────────────────

  /// Sayfanın kendi kaydırma konumu.
  ///
  /// `ScrollController` ekranın özel alanında; testin tutamağı bu yüzden
  /// gövdedeki [Scrollable] durumu.
  double _konum(WidgetTester tester) {
    return tester
        .state<ScrollableState>(
          find.descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          ),
        )
        .position
        .pixels;
  }

  testWidgets('içindekiler paneli on üç bölümü de listeliyor', (tester) async {
    // Geniş ve uzun bir görüş alanı: panel ekranın dörtte üçüyle sınırlı,
    // dar bir ekranda on üç satırın bir kısmı panelin kendi listesinde
    // kaydırma gerektirir ve test satır varlığını değil kaydırmayı ölçerdi.
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_sarmala(dosya, isEn: false));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.list_rounded));
    await tester.pumpAndSettle();

    final panel = find.byType(DossierContentsSheet);
    expect(panel, findsOneWidget);

    for (final b in dosya.sections) {
      expect(
        find.descendant(of: panel, matching: find.text(b.title(false))),
        findsOneWidget,
        reason: '${b.ord}. bölüm içindekilerde yok',
      );
      expect(
        find.descendant(of: panel, matching: find.text(b.ordLabel)),
        findsOneWidget,
      );
    }
  });

  testWidgets('kapak ekranı dolduruyor', (tester) async {
    // Kapak bir zamanlar içeriği kadar yükselen bir banttı ve ilk ekranda hem
    // kapak hem gövdenin başı görünüyordu. Bu sınır olmadan kapağa bir öğe
    // eklendiğinde/çıkarıldığında yükseklik sessizce değişir ve tam ekran
    // kompozisyonu geri döner.
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_sarmala(dosya, isEn: false));
    await tester.pump();

    // Kapak, ülke adının en yakın kaydırılabilir olmayan atası değil; ölçüm
    // doğrudan başlıktan yukarı çıkmak yerine sayfanın ilk sliver'ının
    // yüksekliğine bakıyor: adın kutusu değil kapağın kendisi sınanıyor.
    final kapak = tester.getSize(
      find.ancestor(
        of: find.text(dosya.summary.name(false)),
        matching: find.byType(SizedBox),
      ).first,
    );
    expect(kapak.height, greaterThanOrEqualTo(900 * 0.85));
  });

  testWidgets('bölüm başlığı gövde metninin en az iki katı', (tester) async {
    // Sayfanın asıl tasarım sorunu buydu: başlık gövdeden yalnızca birkaç
    // punto büyüktü, bu yüzden on üç bölüm tek bir düz yüzey gibi okunuyordu.
    // Kademe daralırsa bu test kırılmalı.
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_sarmala(dosya, isEn: false));
    await tester.pump();
    // Kapak artık tam ekran; ilk bölüm başlığı ilk karede kurulmuyor.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
    await tester.pump();

    final baslik = tester.widget<Text>(
      find.descendant(
        of: find.byType(CustomScrollView),
        matching: find.text(dosya.sections.first.title(false)),
      ),
    );
    final govde = AppTypography.body(
      tester.element(find.byType(CustomScrollView)),
    ).fontSize!;
    expect(baslik.style!.fontSize!, greaterThanOrEqualTo(govde * 2));
  });

  testWidgets('içindekilerden seçilen bölüme kaydırılıyor', (tester) async {
    // Asıl sınanan şey: bölümler `SliverList.builder` ile tembel kuruluyor,
    // yani SON bölümün henüz bir `RenderBox`'ı yok. Ekran onu tahmin edip
    // sıçrayarak, bir kare bekleyip yeniden ölçerek buluyor. Bu döngü
    // kırılırsa panel sessizce hiçbir yere gitmez.
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_sarmala(dosya, isEn: false));
    await tester.pump();
    expect(_konum(tester), 0);

    // Sondan bir önceki bölüm: ilk karede kesinlikle kurulmamış durumda,
    // yani tahmin döngüsü çalışmak zorunda. Buna karşılık en SON bölüm
    // sınanmıyor — sayfanın kuyruğu (veri notları, künye, paylaşım çubuğu,
    // arşiv bağlantısı) bir ekrandan uzun olduğu için en dibe inildiğinde
    // son bölüm görüş alanının üstünde kalıyor; bu kaydırmanın kusuru değil,
    // sayfanın sonuna varmış olmanın kendisi.
    final hedef = dosya.sections[dosya.sections.length - 2];
    // Başlık metni sayfada iki yerde geçebiliyor: gövdedeki bölüm başlığı ve
    // üst çubuktaki yapışkan başlık. Aranan hep gövdedeki olduğu için arama
    // kaydırma alanının içine sınırlanıyor.
    final hedefBaslik = find.descendant(
      of: find.byType(CustomScrollView),
      matching: find.text(hedef.title(false)),
    );
    expect(hedefBaslik, findsNothing,
        reason: 'hedef bölüm zaten kuruluysa test tembelliği sınamıyor');

    await tester.tap(find.byIcon(Icons.list_rounded));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(DossierContentsSheet),
        matching: find.text(hedef.title(false)),
      ),
    );
    await tester.pumpAndSettle();

    // Panel kapandı ve sayfa gerçekten yol aldı.
    expect(find.byType(DossierContentsSheet), findsNothing);
    expect(_konum(tester), greaterThan(0));
    // Hedef bölüm artık kurulu ve görüş alanının içinde.
    expect(hedefBaslik, findsOneWidget);
    // Başlık ekranın üst şeridinde. Birkaç piksellik sapmaya izin var:
    // bölüm kutusunun üstü ile başlık metninin üstü arasında bölüm numarası
    // ve iç boşluk var, ayrıca beliriş kayması ölçüm anında bitmiş olsa da
    // yuvarlama artığı bırakabiliyor.
    final ust = tester.getTopLeft(hedefBaslik).dy;
    expect(ust, greaterThan(-40));
    expect(ust, lessThan(tester.view.physicalSize.height / 2),
        reason: 'bölüm ekranın üst yarısına getirilmeliydi');
  });

  testWidgets('ilerleme çubuğu metnin sonunda doluyor', (tester) async {
    // Payda bilerek `maxScrollExtent` değil. Sayfa son bölümden sonra veri
    // notları, kaynak künyesi, paylaşım çubuğu ve arşiv bağlantısıyla devam
    // ediyor; toplam yüksekliğe bölünseydi son cümleyi okuyan kişi çubuğu
    // ~%70'te görür, yani bitirdiğini anlayamazdı.
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_sarmala(dosya, isEn: false));
    await tester.pump();

    double oran() =>
        tester.widget<ReadingProgressBar>(find.byType(ReadingProgressBar))
            .progress
            .value;

    expect(oran(), 0);
    await _sonaKadarKaydir(tester, isEn: false);
    // Künye göründüğüne göre metin çoktan bitti; çubuk tam dolu olmalı,
    // "sona vardık ama %88" gibi bir artık kalmamalı.
    expect(oran(), 1.0);
  });
}
