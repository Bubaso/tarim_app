import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarim_app/features/home/data/models/news_article.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_deposu.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_iskelet.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_metinler.g.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_baslik_ekrani.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_haber_vitrini.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_merkez_ekrani.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_metin_gorunumu.dart';
import 'package:tarim_app/features/yapay_zeka/yz_providers.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Makalenin sonu ve haber vitrini (madde 26-29)
// ──────────────────────────────────────────────────────────────────────────
//  · Sıra: metin → 48 px → Sonraki → 72/80 px ve çizgi → küçük etiket →
//    haberler. Telefonda alt alta dizilince önce SONRAKİ.
//  · Başlıkta en yeni 3 haber; fazlası "N haber daha" ile yerinde açılıyor
//    (en çok 12). Haber yoksa hiçbir şey (etiket ve çizgi de) çizilmiyor.
//  · Merkezde manşet + 3 yan haber (masaüstü), manşet + 4 küçük kart
//    (telefon); altında ızgara yok, "Tüm haberler (N)" yerinde açıyor.
//  · Sorgu ilk kareden ~1,5 s sonra; kartlar okur yaklaşınca kuruluyor,
//    o zamana kadar aynı boyda durağan çerçeve (yerleşim kaymıyor).
// ══════════════════════════════════════════════════════════════════════════

List<YzHaber> _haberler(int baslikNo, int n) => [
      for (var i = 0; i < n; i++)
        YzHaber(
          NewsArticle(
            id: 'h$baslikNo-$i',
            title: i.isEven
                ? 'Haber $i: yapay zekâ destekli sulama sistemi pilot ilde üreticilerle denendi ve ilk sonuçlar açıklandı'
                : 'Haber $i: dron haritası',
            summary: i == 0 ? 'Denemenin nerede, kimle ve nasıl yapıldığı anlatılıyor.' : null,
            content: '',
            createdAt: DateTime(2026, 11, 18 - i),
            sourceName: i % 3 == 0 ? 'Çok Uzun Adlı Bir Haber Ajansı ve Yayın Kuruluşu' : 'Tarım Portalı',
          ),
          baslikNo,
        ),
    ];

Widget _uygulama(Widget cocuk, {required Future<List<YzHaber>> Function(int? no) haber}) => ProviderScope(
      overrides: [
        yzBolumHaberleriProvider.overrideWith((ref, no) => haber(no)),
        yzDizinEklenenlerProvider.overrideWith((ref) async => const <YzDizinKaydi>[]),
      ],
      child: MaterialApp(
        locale: const Locale('tr'),
        supportedLocales: const [Locale('tr'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: cocuk,
      ),
    );

/// Haber alan, metni yazılmış, öncesi ve sonrası olan bir başlık.
YzBaslik get _baslik {
  for (var i = 1; i < kYzBasliklar.length - 1; i++) {
    final b = kYzBasliklar[i];
    if (b.haberAlir && kYzMetinler[b.no] != null) return b;
  }
  throw StateError('haber alan yazılmış başlık yok');
}

const _telefon = Size(375, 812);
const _masaustu = Size(1280, 900);

Future<void> _boyut(WidgetTester t, Size s) async {
  t.view.physicalSize = s;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

/// Sorgu gecikmesini geçir, haber bloğuna kaydır, kartlar kurulsun.
Future<void> _sonaGit(WidgetTester t, Key anahtar) async {
  await t.pump(const Duration(milliseconds: 1600));
  await t.pumpAndSettle();
  await t.ensureVisible(find.byKey(anahtar));
  await t.pumpAndSettle();
}

Finder _haberBasligi(int i) => find.textContaining('Haber $i:');

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  setUp(() => SharedPreferences.setMockInitialValues({}));

  const blok = ValueKey('yz-baslik-haberleri');

  for (final olcu in const [_telefon, _masaustu]) {
    final telefon = olcu == _telefon;
    final ad = '${olcu.width.toInt()} piksel';

    testWidgets('sıra: metin → Sonraki → çizgi → etiket → haberler · $ad', (t) async {
      await _boyut(t, olcu);
      final b = _baslik;
      await t.pumpWidget(_uygulama(YzBaslikEkrani(slug: b.slug),
          haber: (no) async => no == b.no ? _haberler(b.no, 5) : const []));
      await _sonaGit(t, blok);
      expect(t.takeException(), isNull);

      final metinSonu = t.getRect(find.byType(YzMetinGorunumu)).bottom;
      final sonraki = t.getRect(find.byKey(const ValueKey('yz-sonraki')));
      final onceki = t.getRect(find.byKey(const ValueKey('yz-onceki')));
      final cizgi = t.getRect(find.descendant(of: find.byKey(blok), matching: find.byType(Divider)));
      final etiket = t.getRect(find.byKey(const ValueKey('yz-haber-etiketi')));
      final vitrin = t.getRect(find.byType(YzHaberVitrini));

      expect(sonraki.top - metinSonu, closeTo(48, 0.5), reason: 'metnin sonundan Sonraki kartına 48 px');
      if (telefon) {
        expect(sonraki.top, lessThan(onceki.top), reason: 'telefonda önce SONRAKİ');
      } else {
        expect(sonraki.top, onceki.top, reason: 'masaüstünde yan yana');
        expect(onceki.left, lessThan(sonraki.left));
      }
      final komsuSonu = telefon ? onceki.bottom : sonraki.bottom;
      expect(cizgi.top - komsuSonu, closeTo(telefon ? 72 : 80, 0.5));
      expect(cizgi.height, 1);
      expect(etiket.top, greaterThan(cizgi.bottom));
      expect(vitrin.top, greaterThan(etiket.bottom));
      expect(find.text('BU BAŞLIKTAKİ HABERLER'), findsOneWidget);
      // Sütun genişliğinde: masaüstünde metin sütunu (610 px).
      expect(cizgi.width, telefon ? 375 - 32 : kYzMetinGenisligi);
      expect(vitrin.width, cizgi.width);

      // En yeni 3 haber; fazlası "2 haber daha" ile yerinde açılıyor.
      for (var i = 0; i < 3; i++) {
        expect(_haberBasligi(i), findsOneWidget);
      }
      expect(_haberBasligi(3), findsNothing);
      expect(find.text('2 haber daha →'), findsOneWidget);
      final daha = t.getRect(find.byKey(const ValueKey('yz-haber-daha')));
      // ignore: avoid_print
      print('ÖLÇÜM $ad: metin sonu → Sonraki ${(sonraki.top - metinSonu).toStringAsFixed(0)} px; '
          '3 kartlık blok ${(daha.top - 6 - vitrin.top).toStringAsFixed(0)} px, '
          '"haber daha" ile ${vitrin.height.toStringAsFixed(0)} px; '
          'çizgiden bloğun sonuna ${(vitrin.bottom - cizgi.top).toStringAsFixed(0)} px; '
          'metin sonundan haber bloğunun sonuna ${(vitrin.bottom - metinSonu).toStringAsFixed(0)} px');
      if (telefon) {
        // İki sütun: ilk iki kart yan yana, üçüncüsü altta.
        expect(t.getRect(_haberBasligi(0)).top, closeTo(t.getRect(_haberBasligi(1)).top, 0.5));
        expect(t.getRect(_haberBasligi(2)).top, greaterThan(t.getRect(_haberBasligi(0)).bottom));
      } else {
        // Üç kart yan yana.
        expect(t.getRect(_haberBasligi(2)).top, closeTo(t.getRect(_haberBasligi(0)).top, 0.5));
      }

      await t.ensureVisible(find.byKey(const ValueKey('yz-haber-daha')));
      await t.tap(find.byKey(const ValueKey('yz-haber-daha')));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      for (var i = 0; i < 5; i++) {
        expect(_haberBasligi(i), findsOneWidget);
      }
      expect(find.byKey(const ValueKey('yz-haber-daha')), findsNothing);
    });

    testWidgets('haber yokken hiçbir şey çizilmiyor · $ad', (t) async {
      await _boyut(t, olcu);
      final b = _baslik;
      await t.pumpWidget(_uygulama(YzBaslikEkrani(slug: b.slug), haber: (no) async => const []));
      await _sonaGit(t, blok);
      expect(t.takeException(), isNull);
      expect(t.getSize(find.byKey(blok)).height, 0);
      expect(find.byKey(const ValueKey('yz-haber-etiketi')), findsNothing);
      expect(find.textContaining('henüz haber yok'), findsNothing);
      expect(find.textContaining('yüklenemedi'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byKey(const ValueKey('yz-sonraki')), findsOneWidget);
    });

    testWidgets('sorgu hata verirse de hiçbir şey · $ad', (t) async {
      await _boyut(t, olcu);
      final b = _baslik;
      await t.pumpWidget(_uygulama(YzBaslikEkrani(slug: b.slug), haber: (no) async => throw StateError('ağ')));
      await _sonaGit(t, blok);
      expect(t.takeException(), isNull);
      expect(t.getSize(find.byKey(blok)).height, 0);
      expect(find.byKey(const ValueKey('yz-haber-etiketi')), findsNothing);
    });

    testWidgets('merkez: manşet düzeni, ızgara yok, "Tüm haberler" yerinde açıyor · $ad', (t) async {
      await _boyut(t, olcu);
      final hepsi = _haberler(15, 10);
      await t.pumpWidget(_uygulama(const YzMerkezEkrani(), haber: (no) async => no == null ? hepsi : const []));
      await _sonaGit(t, const ValueKey('yz-merkez-haberleri'));
      expect(t.takeException(), isNull);
      expect(find.text('Son haberler'), findsOneWidget);
      // Masaüstü: manşet + 3 yan haber. Telefon: manşet + 4 küçük kart.
      final gorunen = telefon ? 5 : 4;
      for (var i = 0; i < gorunen; i++) {
        expect(_haberBasligi(i), findsOneWidget, reason: 'haber $i');
      }
      expect(_haberBasligi(gorunen), findsNothing, reason: 'altında ızgara yok');
      final manset = t.getRect(_haberBasligi(0));
      if (telefon) {
        // Manşetin altında iki sütunlu küçük kartlar.
        expect(t.getRect(_haberBasligi(1)).top, greaterThan(manset.bottom));
        expect(t.getRect(_haberBasligi(1)).top, closeTo(t.getRect(_haberBasligi(2)).top, 0.5));
        expect(t.getRect(_haberBasligi(3)).top, closeTo(t.getRect(_haberBasligi(4)).top, 0.5));
      } else {
        // Yan haberler manşetin sağında, alt alta.
        for (var i = 1; i < 4; i++) {
          expect(t.getRect(_haberBasligi(i)).left, greaterThan(manset.right));
        }
      }
      // Kart içinde başlığın adı düz yazı: ikinci bir dokunma hedefi yok.
      // (Vitrindeki tek InkWell "Tüm haberler" düğmesinin kendisi.)
      expect(find.descendant(of: find.byType(YzHaberVitrini), matching: find.byType(InkWell)), findsOneWidget);
      final tum = find.text('Tüm haberler (10) →');
      expect(tum, findsOneWidget);
      await t.ensureVisible(tum);
      await t.tap(tum);
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      for (var i = 0; i < 10; i++) {
        expect(_haberBasligi(i), findsOneWidget, reason: 'açılınca haber $i');
      }
    });
  }

  testWidgets('sorgu ilk kareden ~1,5 s sonra; kartlar uzaktayken aynı boyda yer tutucu', (t) async {
    await _boyut(t, _masaustu);
    final b = _baslik;
    var sorgu = 0;
    await t.pumpWidget(_uygulama(YzBaslikEkrani(slug: b.slug), haber: (no) async {
      sorgu++;
      return _haberler(b.no, 3);
    }));
    await t.pump();
    await t.pump(const Duration(milliseconds: 1000));
    expect(sorgu, 0, reason: 'ilk saniyede haber sorgusu yok');
    await t.pump(const Duration(milliseconds: 600));
    await t.pump();
    expect(sorgu, 1);
    // Okur hâlâ metnin başında: kartlar kurulmadı, ama yerleri ayrıldı.
    final once = t.getSize(find.byType(YzHaberVitrini));
    expect(once.height, greaterThan(100));
    expect(_haberBasligi(0), findsNothing);
    expect(find.descendant(of: find.byKey(blok), matching: find.byType(Image)), findsNothing);
    await t.ensureVisible(find.byKey(blok));
    await t.pumpAndSettle();
    expect(_haberBasligi(0), findsOneWidget);
    expect(t.getSize(find.byType(YzHaberVitrini)), once, reason: 'kartlar kurulunca yerleşim kaymıyor');
    expect(find.descendant(of: find.byKey(blok), matching: find.byType(RepaintBoundary)), findsWidgets);
  });

  testWidgets('dış sitedeki görsele bağlanılmıyor; küçük görsel yoksa tarla dokusu', (t) async {
    await _boyut(t, _masaustu);
    final haberler = [
      YzHaber(
        NewsArticle(
          id: 'd1',
          title: 'Haber 0: dış görsel',
          content: '',
          createdAt: DateTime(2026, 11, 10),
          imageUrl: 'https://www.ornek-dis-site.gov.tr/foto.jpg',
          thumbImageUrl: 'https://www.ornek-dis-site.gov.tr/kucuk.jpg',
        ),
        15,
      ),
      YzHaber(
        NewsArticle(
          id: 'd2',
          title: 'Haber 1: büyük görsel var, küçük yok',
          content: '',
          createdAt: DateTime(2026, 11, 9),
          imageUrl: 'https://xkwcyavcltrweunvooeu.supabase.co/storage/v1/object/public/article-images/a_1200x630.jpg',
        ),
        15,
      ),
    ];
    await t.pumpWidget(_uygulama(
        Scaffold(body: SingleChildScrollView(child: YzHaberVitrini(haberler: haberler, merkez: false))),
        haber: (no) async => const []));
    await t.pump();
    expect(t.takeException(), isNull);
    expect(find.byType(Image), findsNothing, reason: 'listede yalnız portalın küçük görseli');
    expect(_haberBasligi(0), findsOneWidget);
  });
}
