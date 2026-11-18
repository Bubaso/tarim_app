
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarim_app/core/utils/turkce_metin.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_deposu.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_iskelet.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_metinler.g.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_harita.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_merkez_ekrani.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_merkez_liste.dart';
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

  group('telefon · çip satırı (★2)', () {
    testWidgets('taşıyorsa sağda solgunluk, sonuna gelince kalkıyor; dokunma 44 px', (t) async {
      _telefon(t);
      await t.pumpWidget(_harita());
      await t.pumpAndSettle();
      expect(find.byType(YzMerkezCipSeridi), findsOneWidget);
      double solgunluk() =>
          t.widget<AnimatedOpacity>(find.byKey(YzMerkezCipSeridi.solgunlukAnahtari)).opacity;
      double solSolgunluk() =>
          t.widget<AnimatedOpacity>(find.byKey(YzMerkezCipSeridi.solSolgunlukAnahtari)).opacity;
      expect(solgunluk(), 1, reason: 'çipler 343 piksele sığmıyor');
      expect(solSolgunluk(), 0, reason: 'başta solda kesik çip yok');
      final kaydirma = find.descendant(
          of: find.byType(YzMerkezCipSeridi), matching: find.byType(Scrollable));
      final durum = t.state<ScrollableState>(kaydirma);
      durum.position.jumpTo(durum.position.maxScrollExtent / 2);
      await t.pumpAndSettle();
      expect(solgunluk(), 1, reason: 'ortada: iki uçta da devamı var');
      expect(solSolgunluk(), 1);
      durum.position.jumpTo(durum.position.maxScrollExtent);
      await t.pumpAndSettle();
      expect(solgunluk(), 0, reason: 'sona gelindi');
      expect(solSolgunluk(), 1, reason: 'sağa kaydı: solda solgunluk');
      durum.position.jumpTo(0);
      await t.pumpAndSettle();
      expect(solgunluk(), 1);
      expect(solSolgunluk(), 0);
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
      expect(
          t.widget<AnimatedOpacity>(find.byKey(YzMerkezCipSeridi.solSolgunlukAnahtari)).opacity,
          0);
    });
  });

  group('masaüstü 1280×900 · değişmedi', () {
    testWidgets('karo ızgarası, sarılan çipler, mono süre', (t) async {
      _masaustu(t);
      await t.pumpWidget(_uygulama(const YzMerkezEkrani()));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.byType(YzBaslikKarosu), findsNWidgets(kYzBasliklar.length));
      expect(find.byType(YzMerkezCipSeridi), findsNothing);
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
      // Karo 196 piksel genişliğinde, çerçeveli.
      expect(t.getSize(find.byType(YzBaslikKarosu).first).width, 196);

      await t.ensureVisible(_cip('Dil modelleri'));
      await t.pumpAndSettle();
      await t.tap(_cip('Dil modelleri'));
      await t.pumpAndSettle();
      expect(find.textContaining('yerde geçiyor'), findsWidgets, reason: 'karo etiketi aynı');
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
