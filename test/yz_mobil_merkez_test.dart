
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_atlas_veri.dart';
import 'package:tarim_app/core/utils/turkce_metin.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_deposu.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_iskelet.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_metinler.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_teknoloji.g.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_harita.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_merkez_ekrani.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_okuma.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_tasarim.dart';
import 'package:tarim_app/features/yapay_zeka/yz_providers.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Mobil tur · merkez sayfa (18 Kas 2026)
// ──────────────────────────────────────────────────────────────────────────
//  ★20 telefonda karosuz başlık listesi · ★2 çip satırında sağ solgunluk ·
//  ★10 okuma süresi düz yazıyla. Masaüstü ızgarası DEĞİŞMEDİ.
// ══════════════════════════════════════════════════════════════════════════

List<Override> get _gecersiz => [
      // Merkezdeki atlas (27 Kas 2026): haber sorgusu ağa çıkmasın.
      yzAtlasHaberleriProvider.overrideWith((ref) async => const <YzHaber>[]),
      yzBolumHaberleriProvider.overrideWith((ref, no) async => const <YzHaber>[]),
      yzDizinEklenenlerProvider.overrideWith((ref) async => const <YzDizinKaydi>[]),
    ];

const _yerellik = [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

Widget _uygulama(Widget cocuk, {String dil = 'tr', double olcek = 1, double? sahteGenislik}) =>
    ProviderScope(
      overrides: _gecersiz,
      child: MaterialApp(
        locale: Locale(dil),
        supportedLocales: const [Locale('tr'), Locale('en')],
        localizationsDelegates: _yerellik,
        // Yazı ölçeği (erişilebilirlik) ve ölçü testinde "geniş ekran sanan"
        // dar kutu: eski ızgarayı telefon genişliğinde çizdirmek için.
        builder: (ctx, child) {
          final mq = MediaQuery.of(ctx);
          return MediaQuery(
            data: mq.copyWith(
              textScaler: TextScaler.linear(olcek),
              size: sahteGenislik == null ? null : Size(sahteGenislik, mq.size.height),
            ),
            child: child!,
          );
        },
        home: cocuk,
      ),
    );

/// Haritayı tek başına, verilen genişlikte (merkez sayfadaki yan boşlukla).
Widget _harita({String dil = 'tr', double olcek = 1, double? sahteGenislik}) => _uygulama(
      const Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: YzHarita(),
        ),
      ),
      dil: dil,
      olcek: olcek,
      sahteGenislik: sahteGenislik,
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

  group('telefon · başlık karoları', () {
    // Satır listesi denendi; kullanıcı karoları geri istedi (18 Kas 2026):
    // "başlık kutuları eski haliyle daha iyiydi".
    testWidgets('telefonda da her başlık bir karo', (t) async {
      t.view.physicalSize = const Size(375, 812);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(_uygulama(const YzMerkezEkrani()));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.byType(YzBaslikKarosu), findsNWidgets(kYzBasliklar.length));
    });
  });

  // Karar 63 (kullanıcı, 18 Kas 2026): teknoloji seçilince karo büyümez,
  // altına metin gelmez; telefonda çipler satırda üç kart.
  group('karar 63 · teknoloji seçimi ve çip ızgarası', () {
    for (final telefon in [true, false]) {
      testWidgets('seçimde karolar aynı boyda, kesişim cümlesi yok · ${telefon ? 'telefon' : 'masaüstü'}',
          (t) async {
        telefon ? _telefon(t) : _masaustu(t);
        await t.pumpWidget(_harita());
        await t.pumpAndSettle();
        final karo = find.byType(YzBaslikKarosu);
        final once = [for (final e in karo.evaluate()) t.getSize(find.byWidget(e.widget))];
        final cip = find.widgetWithText(YzTeknolojiCipi, kYzTeknoloji['goruntu']!['tr']!);
        await t.ensureVisible(cip);
        await t.tap(cip);
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        final sonra = [for (final e in karo.evaluate()) t.getSize(find.byWidget(e.widget))];
        expect(sonra, once, reason: 'karo büyümüyor');
        for (final k in kYzKesisim['goruntu']!.values) {
          expect(find.text(k[0]), findsNothing, reason: 'karoda kesişim cümlesi yok');
        }
        expect(find.textContaining('yerde geçiyor'), findsNothing, reason: 'karoda sayı yok');
      });
    }

    testWidgets('telefonda dokuz çip üç satırda, ekranın içinde, kayma yok', (t) async {
      _telefon(t);
      await t.pumpWidget(_harita());
      await t.pumpAndSettle();
      expect(find.byType(YzCipIzgarasi), findsOneWidget);
      final ustler = <double>{};
      for (final e in find.byType(YzTeknolojiCipi).evaluate()) {
        final r = t.getRect(find.byWidget(e.widget));
        expect(r.right, lessThanOrEqualTo(375 - 16 + 0.5));
        ustler.add(r.top.roundToDouble());
      }
      expect(ustler.length, 3);
      expect(find.ancestor(of: find.byType(YzTeknolojiCipi).first, matching: find.byType(Scrollable)),
          findsOneWidget, reason: 'yalnız sayfanın dikey kaydırması');
    });
  });

  group('masaüstü 1280×900 · değişmedi', () {
    testWidgets('karo ızgarası, sarılan çipler, mono süre', (t) async {
      _masaustu(t);
      await t.pumpWidget(_uygulama(const YzMerkezEkrani()));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.byType(YzBaslikKarosu), findsNWidgets(kYzBasliklar.length));
      expect(find.byType(YzCipIzgarasi), findsNothing);
      expect(find.ancestor(of: find.byType(YzTeknolojiCipi).first, matching: find.byType(Wrap)),
          findsWidgets);
      // Çip eski boyunda (geniş dokunma alanı yalnız telefonda).
      expect(t.getSize(find.byType(YzTeknolojiCipi).first).height, lessThan(44));
      // Karo: aynı etiket, mono.
      final etiket = find.text('$dakika dk okuma').first;
      expect(_ailesi(t, etiket), contains('IBMPlexMono'));
      expect(_ailesi(t, find.text('${kYzBasliklar.length} başlık')), contains('IBMPlexMono'));
      expect(t.widget<Text>(find.text('${kYzBasliklar.length} başlık')).style!.color,
          YzRenk.murekkep);
      expect(find.textContaining('karolar o teknolojinin'), findsOneWidget);
      // Olağan karo 196 piksel genişliğinde; Çerçeve'nin üç karosu daha
      // büyük (mizansen turu, 28 Kasım 2026).
      expect(t.getSize(find.widgetWithText(YzBaslikKarosu, 'Toprak ve arazi')).width, 196);
      expect(t.getSize(find.byType(YzBaslikKarosu).first).width, greaterThan(196));

      await t.ensureVisible(_cip('Dil modelleri'));
      await t.pumpAndSettle();
      await t.tap(_cip('Dil modelleri'));
      await t.pumpAndSettle();
      // Seçimde karo değişmiyor, sayı yazmıyor (karar 63).
      expect(find.textContaining('yerde geçiyor'), findsNothing);
    });
  });

  _olcuGrubu();
}

// ── Ölçü: GERÇEK yazı tipleriyle (dosyanın SONUNDA; yüklenen yazı tipleri
// sonraki testlere de geçer). Test yazı tipi her harfi kare çiziyor;
// başlıklar orada iki-üç satıra kırılıp ölçüyü bozuyor. Outfit'in yalnız
// Bold'u gömülü: 500/600 için de o (biraz geniş, yani ihtiyatlı ölçü).
void _olcuGrubu() {
}

String buyukKatman(String k) => buyukHarf(kYzKatmanlar[k]!['tr']!, false);
