import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_deposu.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_grafik_veri.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_grafikler.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_metinler.g.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_aifs_semasi.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_gorsel.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_gorsel_mobil.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_gorsel_tam_ekran.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_grafik.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_metin_gorunumu.dart';
import 'package:tarim_app/features/yapay_zeka/yz_providers.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Mobil okuma turu — metin ritmi, görsel, grafik ve şema (karar 62)
// ──────────────────────────────────────────────────────────────────────────
//  Telefonda (< 640 px): künye ve lejant sade Outfit, alt başlık aralığı
//  44/10, fotoğraf kenardan kenara ve dokununca tam ekran, uzun şema
//  katlanıyor. 1280 piksellik masaüstünde hepsi eskisi gibi.
// ══════════════════════════════════════════════════════════════════════════

/// Makale sütunu gibi: telefonda 16 piksel yan pay (yz_makale.dart).
Widget _uygulama(Widget cocuk, {String dil = 'tr', double yan = 16}) => ProviderScope(
      overrides: [
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
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(padding: EdgeInsets.symmetric(horizontal: yan), child: cocuk),
          ),
        ),
      ),
    );

Future<void> _telefon(WidgetTester t, {Size olcu = const Size(375, 812)}) async {
  t.view.physicalSize = olcu;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

Future<void> _masaustu(WidgetTester t) async {
  t.view.physicalSize = const Size(1280, 900);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

const _foto = YzGorsel(
  kimlik: 'ornek',
  adres: '/yz/gorsel/ornek.webp',
  genislik: 1600,
  yukseklik: 900,
  kunyeTr: 'Hands Free Hectare projesinin otonom traktörü, Harper Adams Üniversitesi, 2017.',
  kunyeEn: 'The autonomous tractor of the Hands Free Hectare project, Harper Adams University, 2017.',
  kaynakTr: 'Fotoğraf: Harper Adams Üniversitesi',
  kaynakEn: 'Photo: Harper Adams University',
);

/// Dikey bir görsel: 375 genişlikte 560 piksele sınırlanıyor.
const _dikey = YzGorsel(
  kimlik: 'dikey',
  adres: '/yz/gorsel/dikey.webp',
  genislik: 600,
  yukseklik: 1400,
  kunyeTr: 'Dikey bir bilgi şeması.',
  kunyeEn: 'A tall infographic.',
  kaynakTr: 'Görsel: örnek',
  kaynakEn: 'Image: example',
);

YzGrafik _grafik() => const YzGrafik(
      kimlik: 'ornek-cubuk',
      tur: 'yatay_cubuk',
      baslikTr: 'Laboratuvarda yüksek, tarlada düşük doğruluk',
      baslikEn: 'High accuracy in the lab, lower in the field',
      aciklamaTr: 'Aynı modeller başka koşullarda çekilmiş görüntülerde geriledi.',
      aciklamaEn: 'The same models fell back on images taken in other conditions.',
      kaynakTr: 'Kaynak: örnek',
      kaynakEn: 'Source: example',
      birimTr: '%',
      birimEn: '%',
      diziler: [YzGrafikDizi('a', 'Laboratuvar', 'Laboratory'), YzGrafikDizi('b', 'Tarla', 'Field')],
      noktalar: [
        YzGrafikNokta('Mohanty 2016', 'Mohanty 2016', 'a', 99.35),
        YzGrafikNokta('Mohanty 2016', 'Mohanty 2016', 'b', 31.4),
        YzGrafikNokta('Nuru 2020', 'Nuru 2020', 'a', 74),
        YzGrafikNokta('Nuru 2020', 'Nuru 2020', 'b', 65),
      ],
    );

String _aile(WidgetTester t, Finder f) => t.widget<Text>(f).style?.fontFamily ?? '';

Iterable<String> _aileler(WidgetTester t, String metin) =>
    t.widgetList<Text>(find.text(metin)).map((w) => w.style?.fontFamily ?? '');

/// Görselin dokunulan alanı (Semantics → GestureDetector).
Finder _dokunulan() => find
    .descendant(of: find.byType(YzGorselKarti), matching: find.byType(GestureDetector))
    .first;

/// Katlanmış görselin altındaki solma geçişi.
Finder _solma() => find.descendant(
    of: find.byType(YzGorselKatlanir),
    matching: find.byWidgetPredicate((w) {
      if (w is! DecoratedBox || w.decoration is! BoxDecoration) return false;
      final g = (w.decoration as BoxDecoration).gradient;
      // Saydamdan zemine, yukarıdan aşağı (şemanın kendi geçişleri değil).
      return g is LinearGradient &&
          g.begin == Alignment.topCenter &&
          g.end == Alignment.bottomCenter &&
          g.colors.first.a == 0;
    }));

/// Pay çubuğu: lejantta dizi adı ve değer yan yana.
YzGrafik _payGrafigi() => const YzGrafik(
      kimlik: 'ornek-pay',
      tur: 'pay',
      baslikTr: 'Pay',
      baslikEn: 'Share',
      aciklamaTr: 'Açıklama.',
      aciklamaEn: 'Description.',
      kaynakTr: 'Kaynak: örnek',
      kaynakEn: 'Source: example',
      birimTr: '%',
      birimEn: '%',
      diziler: [YzGrafikDizi('a', 'Küçük işletme', 'Small farms'), YzGrafikDizi('b', 'Büyük işletme', 'Large farms')],
      noktalar: [
        YzGrafikNokta('Dünya', 'World', 'a', 35),
        YzGrafikNokta('Dünya', 'World', 'b', 65),
      ],
    );

/// Lejanttaki dizi adının yazı ailesi (düz Text ya da Text.rich parçası).
List<String> _lejantAileleri(WidgetTester t, String ad) {
  final sonuc = <String>[];
  for (final r in t.widgetList<RichText>(find.byType(RichText))) {
    r.text.visitChildren((s) {
      if (s is TextSpan && (s.text ?? '').contains(ad)) {
        sonuc.add(s.style?.fontFamily ?? r.text.style?.fontFamily ?? '');
      }
      return true;
    });
  }
  return sonuc;
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('telefon (375 piksel)', () {
    testWidgets('fotoğraf kenardan kenara, köşesiz; künye sütunda; kaynak satırı Outfit', (t) async {
      await _telefon(t);
      await t.pumpWidget(_uygulama(const YzGorselKarti(gorsel: _foto, en: false)));
      await t.pump();
      expect(t.takeException(), isNull);
      final r = t.getRect(_dokunulan());
      expect(r.left, 0, reason: 'görsel ekranın sol kenarından başlamalı');
      expect(r.width, 375, reason: 'görsel 16 piksellik yan paydan taşmalı');
      expect(
          find.ancestor(of: find.byType(Image), matching: find.byType(ClipRRect)), findsNothing,
          reason: 'ekran kenarında köşe yuvarlatılmaz');
      // Künye ve kaynak satırı metin payının içinde.
      final kunye = find.textContaining('otonom traktörü');
      expect(t.getRect(kunye).left, 16);
      final kaynak = find.text('Fotoğraf: Harper Adams Üniversitesi');
      expect(t.getRect(kaynak).left, 16);
      expect(_aile(t, kaynak), contains('Outfit'));
      expect(t.widget<Text>(kaynak).style!.fontSize, inInclusiveRange(12.5, 13));
      expect(t.widget<Text>(kaynak).style!.fontWeight, FontWeight.w500);
    });

    testWidgets('dokununca tam ekran: koyu zemin, 4 kat, çift dokunuş, Kapat düğmesi', (t) async {
      await _telefon(t);
      await t.pumpWidget(_uygulama(const YzGorselKarti(gorsel: _foto, en: false)));
      await t.pump();
      await t.tap(_dokunulan());
      await t.pumpAndSettle();
      expect(find.byType(YzGorselTamEkran), findsOneWidget);
      final m = t.widget<Material>(find
          .descendant(of: find.byType(YzGorselTamEkran), matching: find.byType(Material))
          .first);
      expect(m.color, kYzTamEkranZemin);
      final iv = t.widget<InteractiveViewer>(find.byType(InteractiveViewer));
      expect(iv.maxScale, 4);
      // Künye altta, kaynakla birlikte.
      expect(find.textContaining('otonom traktörü, Harper Adams Üniversitesi, 2017. — Fotoğraf'),
          findsOneWidget);
      // Çift dokunuş yakınlaştırıyor, ikincisi geri alıyor.
      final merkez = t.getCenter(find.byType(InteractiveViewer));
      await t.tapAt(merkez);
      await t.pump(const Duration(milliseconds: 60));
      await t.tapAt(merkez);
      await t.pumpAndSettle();
      expect(iv.transformationController!.value.getMaxScaleOnAxis(), closeTo(2.5, 0.01));
      await t.tapAt(merkez);
      await t.pump(const Duration(milliseconds: 60));
      await t.tapAt(merkez);
      await t.pumpAndSettle();
      expect(iv.transformationController!.value.getMaxScaleOnAxis(), closeTo(1, 0.01));
      // Kapat: anlamsal adı var, dokunma alanı en az 48 piksel.
      expect(find.bySemanticsLabel('Kapat'), findsOneWidget);
      final dugme = find.byTooltip('Kapat');
      expect(t.getSize(dugme).width, greaterThanOrEqualTo(48));
      expect(t.getSize(dugme).height, greaterThanOrEqualTo(48));
      await t.tap(dugme);
      await t.pumpAndSettle();
      expect(find.byType(YzGorselTamEkran), findsNothing);
      expect(t.takeException(), isNull);
    });

    testWidgets('tam ekranda İngilizce kapatma adı ve güvenli alan', (t) async {
      await _telefon(t);
      t.view.padding = const FakeViewPadding(top: 47, bottom: 34);
      addTearDown(t.view.resetPadding);
      await t.pumpWidget(_uygulama(const YzGorselKarti(gorsel: _foto, en: true), dil: 'en'));
      await t.pump();
      await t.tap(_dokunulan());
      await t.pumpAndSettle();
      expect(find.bySemanticsLabel('Close'), findsOneWidget);
      final dugme = t.getRect(find.byTooltip('Close'));
      expect(dugme.top, greaterThanOrEqualTo(47), reason: 'çentiğin altında');
      final altyazi = t.getRect(find.textContaining('autonomous tractor'));
      expect(altyazi.bottom, lessThanOrEqualTo(812 - 34), reason: 'alt çubuğun üstünde');
      await t.tap(find.byTooltip('Close'));
      await t.pumpAndSettle();
    });

    testWidgets('ECMWF/AIFS şeması katlanıyor: 420 piksel, solma, düğme; açılıp daralıyor', (t) async {
      await _telefon(t);
      final g = kYzGorseller['b01-ecmwf-nin-yapay-zeka-tahmin-sistemi']!;
      await t.pumpWidget(_uygulama(YzGorselKarti(gorsel: g, en: false)));
      await t.pump();
      await t.pump();
      expect(t.takeException(), isNull);
      expect(find.byType(YzAifsSemasi), findsOneWidget);
      final katlanir = find.byType(YzGorselKatlanir);
      final gorunen = find.descendant(of: katlanir, matching: find.byType(Stack)).first;
      expect(t.getSize(gorunen).height, kYzKatliBoy);
      // Çizilmiş şema sütunun içinde kalıyor (kenardan kenara değil).
      expect(t.getRect(gorunen).left, 16);
      // Alt kenar zemine soluyor (96 piksellik geçiş), açılınca kalkıyor.
      expect(_solma(), findsOneWidget);
      expect(t.getSize(_solma()).height, 96);
      expect(t.getRect(_solma()).bottom, t.getRect(gorunen).bottom);
      final ac = find.text('Şemanın tamamını gör');
      expect(ac, findsOneWidget);
      final dugme = find.ancestor(of: ac, matching: find.byType(TextButton));
      expect(t.getSize(dugme).height, greaterThanOrEqualTo(44));
      expect(t.getSize(dugme).width, 375 - 32, reason: 'tam genişlikte düğme');
      await t.tap(ac);
      await t.pumpAndSettle();
      expect(t.getSize(gorunen).height, greaterThan(kYzKatlamaEsigi));
      expect(find.text('Şemayı daralt'), findsOneWidget);
      expect(_solma(), findsNothing);
      // Düğme şemanın sonunda.
      expect(t.getRect(find.text('Şemayı daralt')).top, greaterThan(t.getRect(gorunen).bottom));
      await t.ensureVisible(find.text('Şemayı daralt'));
      await t.pumpAndSettle();
      await t.tap(find.text('Şemayı daralt'));
      await t.pumpAndSettle();
      expect(t.getSize(gorunen).height, kYzKatliBoy);
      expect(_solma(), findsOneWidget);
      // Daraltınca şemanın başı yeniden görünür.
      expect(t.getRect(gorunen).top, greaterThanOrEqualTo(0));
      expect(t.takeException(), isNull);
    });

    testWidgets('çizilmiş şemaların hepsi telefonda katlanıyor ve taşmıyor', (t) async {
      await _telefon(t);
      for (final k in const [
        'b01-ecmwf-nin-yapay-zeka-tahmin-sistemi',
        'b02-ers-nin-dijital-tarim-bilesenleri',
        'b02-cema-nin-dijital-tarim-tarifi',
        't-dil-digital-green-in-sohbet-robotu',
      ]) {
        final g = kYzGorseller[k];
        expect(g, isNotNull, reason: k);
        await t.pumpWidget(_uygulama(YzGorselKarti(gorsel: g!, en: false)));
        await t.pump();
        await t.pump();
        expect(t.takeException(), isNull, reason: k);
        expect(find.text('Şemanın tamamını gör'), findsOneWidget, reason: k);
        // Tam ekran gösterimi de dar düzende taşmadan açılıyor.
        await t.tap(find.byType(YzGorselKatlanir), warnIfMissed: false);
        await t.pumpAndSettle();
        expect(find.byType(YzGorselTamEkran), findsOneWidget, reason: k);
        expect(t.takeException(), isNull, reason: k);
        await t.tap(find.byTooltip('Kapat'));
        await t.pumpAndSettle();
        await t.pumpWidget(const SizedBox());
      }
    });

    testWidgets('ekranın %85inden uzun görsel katlanıyor (İngilizce düğme)', (t) async {
      await _telefon(t, olcu: const Size(375, 600));
      await t.pumpWidget(_uygulama(const YzGorselKarti(gorsel: _dikey, en: true), dil: 'en'));
      await t.pump();
      await t.pump();
      expect(find.text('Show the full image'), findsOneWidget);
      await t.tap(find.text('Show the full image'));
      await t.pumpAndSettle();
      expect(find.text('Collapse image'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('kısa fotoğraf katlanmıyor', (t) async {
      await _telefon(t);
      await t.pumpWidget(_uygulama(const YzGorselKarti(gorsel: _foto, en: false)));
      await t.pump();
      await t.pump();
      expect(find.text('Görselin tamamını gör'), findsNothing);
      expect(find.text('Şemanın tamamını gör'), findsNothing);
    });

    testWidgets('alt başlık aralığı 48 üstte, 12 altta (madde 3)', (t) async {
      await _telefon(t);
      await t.pumpWidget(_uygulama(const YzMetinGorunumu(
          metin: 'Giriş paragrafı.\n\n## Alt başlık\n\nİkinci paragraf.', en: false)));
      await t.pump();
      final dolgular = t
          .widgetList<Padding>(find.ancestor(of: find.text('Alt başlık'), matching: find.byType(Padding)))
          .map((p) => p.padding);
      expect(dolgular, contains(const EdgeInsets.only(top: 48, bottom: 12)));
      expect(dolgular, isNot(contains(const EdgeInsets.only(top: 48, bottom: 14))));
    });

    testWidgets('aralıklar yazı boyuyla büyüyor: × (1 + (s − 1) × 0,6)', (t) async {
      await _telefon(t);
      await t.pumpWidget(_uygulama(const YzMetinGorunumu(
          metin: 'Giriş paragrafı.\n\n## Alt başlık\n\nİkinci paragraf.\n\n- bir\n- iki\n\nSon.',
          en: false,
          olcek: 1.25)));
      await t.pump();
      const k = 1 + 0.25 * 0.6;
      final dolgular = t.widgetList<Padding>(find.byType(Padding)).map((p) => p.padding).toList();
      expect(dolgular, contains(const EdgeInsets.only(top: 48 * k, bottom: 12 * k)));
      expect(dolgular, contains(const EdgeInsets.only(bottom: 28 * k)), reason: 'paragraf arası');
      expect(dolgular, contains(const EdgeInsets.only(top: 2, bottom: 28 * k)), reason: 'liste altı');
      expect(dolgular, contains(const EdgeInsets.only(bottom: 12 * k)), reason: 'maddeler arası');
    });

    testWidgets('gövde satırı 1,68, giriş 1,60; tablo hücresi 1,45 kalıyor', (t) async {
      await _telefon(t);
      await t.pumpWidget(_uygulama(const YzMetinGorunumu(
          metin: 'Giriş paragrafı.\n\nİkinci paragraf.\n\n| A | B |\n|---|---|\n| x | y |', en: false)));
      await t.pump();
      double? satir(String m) {
        double? h;
        for (final r in t.widgetList<RichText>(find.byType(RichText))) {
          if (r.text.toPlainText() != m) continue;
          void gez(InlineSpan span) {
            if (span.style?.height != null) h = span.style!.height;
            if (span is TextSpan) span.children?.forEach(gez);
          }

          gez(r.text);
        }
        return h;
      }

      expect(satir('Giriş paragrafı.'), 1.60);
      expect(satir('İkinci paragraf.'), 1.68);
      expect(satir('x'), 1.45);
    });

    testWidgets('uzun grafik katlanıyor: 420 piksel, solma, düğme; başlık ve kaynak dışarıda', (t) async {
      await _telefon(t);
      final g = kYzGrafikler['b03-donum-noktalari']!;
      await t.pumpWidget(_uygulama(YzGrafikKarti(grafik: g, en: false)));
      await t.pump();
      await t.pump();
      expect(t.takeException(), isNull);
      final katlanir = find.byType(YzGorselKatlanir);
      expect(katlanir, findsOneWidget);
      final gorunen = find.descendant(of: katlanir, matching: find.byType(Stack)).first;
      expect(t.getSize(gorunen).height, kYzKatliBoy);
      expect(_solma(), findsOneWidget);
      final ac = find.text('Grafiğin tamamını gör');
      expect(ac, findsOneWidget);
      expect(t.getSize(find.ancestor(of: ac, matching: find.byType(TextButton))).width, 375 - 32 - 32 - 2,
          reason: 'kartın içinde tam genişlik');
      // Başlık, açıklama, kaynak ve "Tablo olarak gör" katlamanın dışında.
      for (final m in [g.baslik(false), g.aciklama(false), 'Tablo olarak gör']) {
        expect(find.descendant(of: katlanir, matching: find.text(m)), findsNothing, reason: m);
        expect(find.text(m), findsOneWidget, reason: m);
      }
      await t.tap(ac);
      await t.pumpAndSettle();
      expect(t.getSize(gorunen).height, greaterThan(812 * 0.85));
      await t.ensureVisible(find.text('Grafiği daralt'));
      await t.pumpAndSettle();
      await t.tap(find.text('Grafiği daralt'));
      await t.pumpAndSettle();
      expect(t.getSize(gorunen).height, kYzKatliBoy);
      expect(t.getRect(gorunen).top, greaterThanOrEqualTo(0), reason: 'daraltınca grafiğin başı görünür');
      // Tablo görünümü katlanmıyor.
      await t.ensureVisible(find.text('Tablo olarak gör'));
      await t.tap(find.text('Tablo olarak gör'));
      await t.pumpAndSettle();
      expect(find.byType(YzGorselKatlanir), findsNothing);
      expect(t.takeException(), isNull);
    });

    testWidgets('hareket azaltma açıksa grafik daraltınca konum anında', (t) async {
      await _telefon(t);
      final g = kYzGrafikler['b03-donum-noktalari']!;
      t.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
      await t.pumpWidget(_uygulama(YzGrafikKarti(grafik: g, en: false)));
      await t.pump();
      await t.pump();
      await t.tap(find.text('Grafiğin tamamını gör'));
      await t.pumpAndSettle();
      await t.ensureVisible(find.text('Grafiği daralt'));
      await t.pumpAndSettle();
      await t.tap(find.text('Grafiği daralt'));
      await t.pump();
      await t.pump();
      final gorunen = find.descendant(of: find.byType(YzGorselKatlanir), matching: find.byType(Stack)).first;
      expect(t.getRect(gorunen).top, greaterThanOrEqualTo(0), reason: 'animasyonsuz, tek karede');
    });

    testWidgets('kısa grafik katlanmıyor', (t) async {
      await _telefon(t);
      await t.pumpWidget(_uygulama(YzGrafikKarti(grafik: _grafik(), en: false)));
      await t.pump();
      await t.pump();
      expect(find.text('Grafiğin tamamını gör'), findsNothing);
    });

    testWidgets('uzun paragraf parçalara bölünüyor; arama vurgusu masaüstüyle aynı', (t) async {
      final md = kYzMetinler[1]!.tr;
      int vurgulu(WidgetTester t) {
        var n = 0;
        for (final r in t.widgetList<RichText>(find.descendant(of: find.byType(YzMetinGorunumu), matching: find.byType(RichText)))) {
          r.text.visitChildren((span) {
            if (span is TextSpan && span.style?.backgroundColor == kYzAramaRengi) n += (span.text ?? '').length;
            return true;
          });
        }
        return n;
      }

      final paragraf = yzAyristir(md).where((b) => b.tur == YzBlokTuru.paragraf).length;
      int bloklar(WidgetTester t) => t
          .widget<Column>(find.descendant(of: find.byType(YzMetinGorunumu), matching: find.byType(Column)).first)
          .children
          .length;
      // Metin parçaları (paragraf, parça, liste maddesi, hücre…).
      int parcalar(WidgetTester t) =>
          find.descendant(of: find.byType(YzMetinGorunumu), matching: find.byType(RichText)).evaluate().length;
      final hepsi = yzAyristir(md).length;

      await _telefon(t);
      await t.pumpWidget(_uygulama(YzMetinGorunumu(metin: md, en: false, bolumNo: 1, arama: 'yapay zekâ')));
      await t.pump();
      expect(t.takeException(), isNull);
      final telefonda = vurgulu(t);
      final telefonParca = parcalar(t);
      // Dosyadaki bir paragraf telefonda da tek (anahtarlı) blok; parçalar içinde.
      expect(bloklar(t), hepsi);
      expect(telefonda, greaterThan(0));

      await _masaustu(t);
      await t.pumpWidget(_uygulama(YzMetinGorunumu(metin: md, en: false, bolumNo: 1, arama: 'yapay zekâ'), yan: 32));
      await t.pump();
      expect(bloklar(t), hepsi, reason: 'masaüstünde blok sayısı = blok sayısı ($paragraf paragraf)');
      expect(telefonParca, greaterThan(parcalar(t)), reason: 'telefonda paragraflar parçalara bölünüyor');
      expect(vurgulu(t), telefonda, reason: 'arama vurgusu parçalara aynen dağılıyor');
    });

    testWidgets('tam ekran: zemine tek dokunuş kapatıyor, görsele dokunuş kapatmıyor', (t) async {
      await _telefon(t);
      await t.pumpWidget(_uygulama(const YzGorselKarti(gorsel: _foto, en: false)));
      await t.pump();
      await t.tap(_dokunulan());
      await t.pumpAndSettle();
      expect(find.byType(YzGorselTamEkran), findsOneWidget);
      // Görselin üstüne (ortaya) tek dokunuş: açık kalıyor.
      await t.tapAt(t.getCenter(find.byType(InteractiveViewer)));
      await t.pump(const Duration(milliseconds: 400));
      await t.pumpAndSettle();
      expect(find.byType(YzGorselTamEkran), findsOneWidget);
      // Koyu zemine tek dokunuş: kapanıyor.
      await t.tapAt(const Offset(12, 300));
      await t.pump(const Duration(milliseconds: 400));
      await t.pumpAndSettle();
      expect(find.byType(YzGorselTamEkran), findsNothing);
      expect(t.takeException(), isNull);
    });

    testWidgets('tam ekran: aşağı çekip bırakınca kapanıyor, az çekince yerine dönüyor', (t) async {
      await _telefon(t);
      await t.pumpWidget(_uygulama(const YzGorselKarti(gorsel: _foto, en: false)));
      await t.pump();
      await t.tap(_dokunulan());
      await t.pumpAndSettle();
      final alan = find.byType(InteractiveViewer);
      await t.timedDrag(alan, const Offset(0, 50), const Duration(milliseconds: 800));
      await t.pumpAndSettle();
      expect(find.byType(YzGorselTamEkran), findsOneWidget, reason: 'az çekme kapatmaz');
      for (final k in t.widgetList<Transform>(find.descendant(of: alan, matching: find.byType(Transform)))) {
        expect(k.transform.getTranslation().y, closeTo(0, 0.01), reason: 'bırakınca yerine dönüyor');
      }
      await t.timedDrag(alan, const Offset(0, 220), const Duration(milliseconds: 800));
      await t.pumpAndSettle();
      expect(find.byType(YzGorselTamEkran), findsNothing);
      expect(t.takeException(), isNull);
    });

    testWidgets('çizilmiş şema tam ekranda dar düzende, ekran genişliğinde ve kaydırılabilir', (t) async {
      await _telefon(t);
      final g = kYzGorseller['b01-ecmwf-nin-yapay-zeka-tahmin-sistemi']!;
      await t.pumpWidget(_uygulama(YzGorselKarti(gorsel: g, en: false)));
      await t.pump();
      await t.pump();
      await t.tap(find.descendant(of: find.byType(YzAifsSemasi), matching: find.byType(Container)).first,
          warnIfMissed: false);
      await t.pumpAndSettle();
      expect(find.byType(YzGorselTamEkran), findsOneWidget);
      final tam = find.descendant(of: find.byType(YzGorselTamEkran), matching: find.byType(YzAifsSemasi));
      expect(tam, findsOneWidget);
      expect(t.widget<YzAifsSemasi>(tam).genisZorla, isFalse, reason: 'dar düzen');
      expect(find.descendant(of: find.byType(YzGorselTamEkran), matching: find.byType(FittedBox)),
          findsNothing, reason: '1000 piksellik düzen ekrana sığdırılmıyor');
      expect(t.getSize(tam).width, 375 - 24);
      final iv = t.widget<InteractiveViewer>(find.byType(InteractiveViewer));
      expect(iv.constrained, isFalse, reason: 'uzun şema dikey kaydırılıyor');
      expect(iv.maxScale, 4);
      expect(t.takeException(), isNull);
      await t.tap(find.byTooltip('Kapat'));
      await t.pumpAndSettle();
      expect(find.byType(YzGorselTamEkran), findsNothing);
    });

    testWidgets('pay çubuğunun lejantında dizi adı Outfit, değer mono', (t) async {
      await _telefon(t);
      await t.pumpWidget(_uygulama(YzGrafikKarti(grafik: _payGrafigi(), en: false)));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      final adlar = _lejantAileleri(t, 'Küçük işletme');
      expect(adlar, isNotEmpty);
      expect(adlar, everyElement(contains('Outfit')));
      final degerler = _lejantAileleri(t, '%35');
      expect(degerler, isNotEmpty);
      expect(degerler, everyElement(isNot(contains('Outfit'))));
    });

    testWidgets('grafiğin lejant adları ve kaynak satırı Outfit; eksen değerleri mono', (t) async {
      await _telefon(t);
      await t.pumpWidget(_uygulama(YzGrafikKarti(grafik: _grafik(), en: false)));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(_aile(t, find.text('Kaynak: örnek')), contains('Outfit'));
      expect(_aileler(t, 'Laboratuvar'), contains(predicate<String>((a) => a.contains('Outfit'))));
      expect(_aileler(t, 'Tarla'), contains(predicate<String>((a) => a.contains('Outfit'))));
      // Değer etiketleri mono kalıyor.
      final degerler = t.widgetList<Text>(find.textContaining('99,35')).toList();
      expect(degerler, isNotEmpty);
      for (final w in degerler) {
        expect(w.style?.fontFamily ?? '', isNot(contains('Outfit')));
      }
    });
  });

  group('masaüstü (1280 piksel) eskisi gibi', () {
    testWidgets('görsel sütunda, köşeli; kaynak mono; dokununca eski büyütme penceresi', (t) async {
      await _masaustu(t);
      await t.pumpWidget(_uygulama(const YzGorselKarti(gorsel: _foto, en: false), yan: 32));
      await t.pump();
      expect(t.takeException(), isNull);
      final r = t.getRect(_dokunulan());
      expect(r.left, 32);
      expect(r.width, 1280 - 64);
      expect(find.ancestor(of: find.byType(Image), matching: find.byType(ClipRRect)), findsOneWidget);
      expect(_aile(t, find.text('Fotoğraf: Harper Adams Üniversitesi')), contains('IBMPlexMono'));
      await t.tap(_dokunulan());
      await t.pumpAndSettle();
      expect(find.byType(YzGorselTamEkran), findsNothing);
      expect(find.byType(InteractiveViewer), findsOneWidget, reason: 'eski büyütme penceresi');
      // Sınamada ağ yok; eski pencerenin görselinde hata gösterici yok
      // (masaüstü davranışı değiştirilmedi), yükleme hatası burada yutuluyor.
      t.takeException();
      expect(find.text('Görselin tamamını gör'), findsNothing);
    });

    testWidgets('ECMWF/AIFS şeması katlanmıyor', (t) async {
      await _masaustu(t);
      final g = kYzGorseller['b01-ecmwf-nin-yapay-zeka-tahmin-sistemi']!;
      await t.pumpWidget(_uygulama(YzGorselKarti(gorsel: g, en: false), yan: 32));
      await t.pump();
      await t.pump();
      expect(find.byType(YzGorselKatlanir), findsNothing);
      expect(find.text('Şemanın tamamını gör'), findsNothing);
    });

    testWidgets('alt başlık aralığı 48/14 (madde 3)', (t) async {
      await _masaustu(t);
      await t.pumpWidget(_uygulama(
          const YzMetinGorunumu(metin: 'Giriş paragrafı.\n\n## Alt başlık\n\nİkinci paragraf.', en: false),
          yan: 32));
      await t.pump();
      final dolgular = t
          .widgetList<Padding>(find.ancestor(of: find.text('Alt başlık'), matching: find.byType(Padding)))
          .map((p) => p.padding);
      expect(dolgular, contains(const EdgeInsets.only(top: 48, bottom: 14)));
    });

    testWidgets('uzun grafik masaüstünde katlanmıyor', (t) async {
      await _masaustu(t);
      await t.pumpWidget(_uygulama(YzGrafikKarti(grafik: kYzGrafikler['b03-donum-noktalari']!, en: false), yan: 32));
      await t.pump();
      await t.pump();
      expect(find.byType(YzGorselKatlanir), findsNothing);
      expect(t.takeException(), isNull);
    });

    testWidgets('grafiğin lejantı ve kaynak satırı mono', (t) async {
      await _masaustu(t);
      await t.pumpWidget(_uygulama(YzGrafikKarti(grafik: _grafik(), en: false), yan: 32));
      await t.pumpAndSettle();
      expect(_aile(t, find.text('Kaynak: örnek')), contains('IBMPlexMono'));
      expect(_aileler(t, 'Laboratuvar'), isNot(contains(predicate<String>((a) => a.contains('Outfit')))));
      expect(_aileler(t, 'Laboratuvar'), contains(predicate<String>((a) => a.contains('IBMPlexMono'))));
    });
    testWidgets('pay çubuğunun lejantı mono', (t) async {
      await _masaustu(t);
      await t.pumpWidget(_uygulama(YzGrafikKarti(grafik: _payGrafigi(), en: false), yan: 32));
      await t.pumpAndSettle();
      final adlar = _lejantAileleri(t, 'Küçük işletme');
      expect(adlar, isNotEmpty);
      expect(adlar, everyElement(contains('IBMPlexMono')));
    });
  });
}
