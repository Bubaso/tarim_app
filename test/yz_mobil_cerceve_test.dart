import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarim_app/core/utils/turkce_metin.dart' show buyukHarf;
import 'package:tarim_app/features/yapay_zeka/data/yz_deposu.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_iskelet.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_metinler.g.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_arama_ekrani.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_baslik_ekrani.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_cerceve_mobil.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_metin_gorunumu.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_okuma.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_parcalar.dart'
    show YzUstSerit, YzTeknolojiCipi, yzPath, yzAramaPath;
import 'package:tarim_app/features/yapay_zeka/presentation/yz_tasarim.dart';
import 'package:tarim_app/features/yapay_zeka/yz_providers.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Mobil okuma turu — makale sayfasının telefon çerçevesi (karar 62)
// ──────────────────────────────────────────────────────────────────────────
//  Telefonda (< 640 px): kısa künye, yana kayan çipler, yüzen ipucu, alt
//  çubuk (içindekiler, yazı boyu, ara, paylaş), kaydırınca saklanan
//  çubuklar, okuma çizgisi, alt başlıkta bağlantı simgesi yok.
//  Masaüstünde (1280 px) her şey eskisi gibi.
// ══════════════════════════════════════════════════════════════════════════

List<Override> get _sahte => [
      yzBolumHaberleriProvider.overrideWith((ref, no) async => const <YzHaber>[]),
      yzDizinEklenenlerProvider.overrideWith((ref) async => const <YzDizinKaydi>[]),
    ];

const _dilVekilleri = [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

Widget _uygulama(Widget cocuk, {String dil = 'tr', ProviderContainer? kap}) {
  final app = MaterialApp(
    locale: Locale(dil),
    supportedLocales: const [Locale('tr'), Locale('en')],
    localizationsDelegates: _dilVekilleri,
    home: cocuk,
  );
  return kap == null
      ? ProviderScope(overrides: _sahte, child: app)
      : UncontrolledProviderScope(container: kap, child: app);
}

GoRouter _yonlendirici(String konum) => GoRouter(initialLocation: konum, routes: [
      GoRoute(path: yzPath, builder: (c, s) => const Scaffold(body: Text('MERKEZ'))),
      GoRoute(path: yzAramaPath, builder: (c, s) => YzAramaEkrani(sorgu: s.uri.queryParameters['q'] ?? '')),
      GoRoute(path: '$yzPath/:slug', builder: (c, s) => YzBaslikEkrani(slug: s.pathParameters['slug'] ?? '')),
    ]);

Widget _yonlendirmeli(GoRouter r, {String dil = 'tr'}) => ProviderScope(
      overrides: _sahte,
      child: MaterialApp.router(
        routerConfig: r,
        locale: Locale(dil),
        supportedLocales: const [Locale('tr'), Locale('en')],
        localizationsDelegates: _dilVekilleri,
      ),
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

/// İpucu önceden görülmüş sayılsın (ipucunu sınamayan testlerde alt
/// çubuğun üstünde yüzmesin).
void _ipucuGoruldu() => SharedPreferences.setMockInitialValues({'yz_ipucu_goruldu': true});

const _saha = 'saha-hikayeleri';
const _dron = 'Türkiye: ilaçlama dronları';

Finder get _altCubuk => find.byKey(const ValueKey('yz-alt-cubuk'));

double _ustKayma(WidgetTester t) =>
    t.widget<AnimatedSlide>(find.ancestor(of: find.byType(YzUstSerit), matching: find.byType(AnimatedSlide))).offset.dy;

double _altYukseklikCarpani(WidgetTester t) => t
    .widget<AnimatedAlign>(find.ancestor(of: _altCubuk, matching: find.byType(AnimatedAlign)))
    .heightFactor!;

ScrollPosition _konum(WidgetTester t) =>
    t.state<ScrollableState>(find.byType(Scrollable).first).position;

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('kısa künye', () {
    test('kısaltılmış ay adları, iki dil', () {
      expect(yzKisaTarih('2026-11-17', false), '17 Kas 2026');
      expect(yzKisaTarih('2026-08-03', false), '3 Ağu 2026');
      expect(yzKisaTarih('2026-11-17', true), '17 Nov 2026');
      expect(yzKisaKunye(dakika: 4, guncellendi: '2026-11-17', en: false), '4 dk · kaynaklar 17 Kas 2026');
      expect(yzKisaKunye(dakika: 4, guncellendi: '2026-11-17', en: true),
          '4 min · sources checked 17 Nov 2026');
      expect(yzKisaKunye(dakika: 2, en: false), '2 dk');
    });
  });

  group('telefon · başlık', () {
    for (final dil in ['tr', 'en']) {
      testWidgets('künye tek satır, yazdır başlıkta yok, metin ilk ekranın üçte birinde · $dil',
          (t) async {
        _telefon(t);
        _ipucuGoruldu();
        await t.pumpWidget(_uygulama(const YzBaslikEkrani(slug: _saha), dil: dil));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        final en = dil == 'en';
        final b = kYzBasliklar.firstWhere((x) => x.slug == _saha);
        final m = kYzMetinler[b.no]!;
        final kunye = yzKisaKunye(dakika: yzOkumaSuresi(m.metin(en), en), guncellendi: m.guncellendi, en: en);
        expect(find.text(kunye), findsOneWidget);
        final kunyeKutusu = t.getSize(find.text(kunye));
        expect(kunyeKutusu.height, lessThan(24), reason: 'tek satır');
        expect(find.textContaining(en ? 'Last checked' : 'Kaynaklarından'), findsNothing);
        expect(find.text(en ? 'Print / PDF' : 'Yazdır / PDF'), findsNothing,
            reason: 'yazdırma Paylaş sayfasında');
        // Satır içi içindekiler kartı ve alt başlık bağlantı simgesi yok.
        expect(find.textContaining(en ? 'CONTENTS · ' : 'İÇİNDEKİLER · '), findsNothing);
        expect(find.byTooltip(en ? 'Copy the link to this section' : 'Bu bölümün bağlantısını kopyala'),
            findsNothing);
        // Metin ilk ekranın üçte birinde başlıyor.
        final ilkMetin = find.byType(SelectableText).first;
        expect(t.getTopLeft(ilkMetin).dy, lessThan(812 / 3));
        // Alt çubuk dört düğmeyle; üst şeritte arama ve yazı boyu yok (alt çubukta).
        expect(_altCubuk, findsOneWidget);
        for (final ad in en
            ? ['Contents', 'Text size', 'Search', 'Share']
            : ['İçindekiler', 'Yazı boyu', 'Ara', 'Paylaş']) {
          expect(find.descendant(of: _altCubuk, matching: find.text(ad)), findsOneWidget, reason: ad);
        }
        expect(find.descendant(of: find.byType(YzUstSerit), matching: find.byIcon(Icons.search_rounded)),
            findsNothing);
        expect(find.byKey(const ValueKey('yz-okuma-cizgisi')), findsOneWidget);
      });
    }

    // Her yazılmış başlıkta, iki dilde: metin ilk ekranın üçte birinde.
    testWidgets('her başlıkta metin ilk ekranın üçte birinde başlıyor', (t) async {
      _telefon(t);
      _ipucuGoruldu();
      for (final dil in ['tr', 'en']) {
        for (final b in kYzBasliklar.where((b) => b.yazildi)) {
          await t.pumpWidget(_uygulama(YzBaslikEkrani(slug: b.slug), dil: dil));
          await t.pumpAndSettle();
          final metin = find.byType(SelectableText);
          if (metin.evaluate().isNotEmpty) {
            expect(t.getTopLeft(metin.first).dy, lessThan(812 / 3), reason: '§${b.no} $dil');
          }
          await t.pumpWidget(const SizedBox());
        }
      }
    });

    testWidgets('dokunma alanları en az 44 piksel', (t) async {
      _telefon(t);
      _ipucuGoruldu();
      await t.pumpWidget(_uygulama(const YzBaslikEkrani(slug: _saha)));
      await t.pumpAndSettle();
      for (final ad in ['İçindekiler', 'Yazı boyu', 'Ara', 'Paylaş']) {
        final dugme = find.ancestor(of: find.text(ad), matching: find.byType(InkWell)).first;
        final s = t.getSize(dugme);
        expect(s.height, greaterThanOrEqualTo(44), reason: ad);
        expect(s.width, greaterThanOrEqualTo(44), reason: ad);
      }
    });

    testWidgets('alt güvenli alan: alt çubuk iPhone çentiğinin üstünde', (t) async {
      _telefon(t);
      _ipucuGoruldu();
      t.view.padding = const FakeViewPadding(bottom: 34);
      addTearDown(t.view.resetPadding);
      await t.pumpWidget(_uygulama(const YzBaslikEkrani(slug: _saha)));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      final ic = find.descendant(of: _altCubuk, matching: find.text('Ara'));
      expect(t.getBottomLeft(ic).dy, lessThan(812 - 34));
      expect(t.getSize(_altCubuk).height, greaterThanOrEqualTo(kYzAltCubukYuksekligi + 34));
    });
  });

  group('telefon · teknoloji çipleri', () {
    testWidgets('taşan satır yana kayıyor, sağda solma; taşmayanda solma yok', (t) async {
      _telefon(t);
      Future<void> ciz(List<String> kodlar) async {
        await t.pumpWidget(_uygulama(Scaffold(
          body: Center(
            child: SizedBox(
              width: 343,
              child: YzCerceveCipSirasi(cipler: [for (final k in kodlar) YzTeknolojiCipi(kod: k)]),
            ),
          ),
        )));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
      }

      final hepsi = kYzTeknoloji.keys.toList();
      await ciz(hepsi);
      expect(find.byKey(const ValueKey('yz-cip-solma')), findsOneWidget);
      expect(t.getSize(find.byType(YzCerceveCipSirasi)).height, lessThan(40), reason: 'tek satır');
      // Sona kaydırınca solma kalkıyor.
      await t.drag(find.byType(SingleChildScrollView), const Offset(-3000, 0));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('yz-cip-solma')), findsNothing);

      await ciz([hepsi.first]);
      expect(find.byKey(const ValueKey('yz-cip-solma')), findsNothing);
    });
  });

  group('telefon · ipucu', () {
    testWidgets('alt çubuğun üstünde yüzüyor; 8 saniye sonra kapanıp görülmüş sayılıyor', (t) async {
      _telefon(t);
      final kap = ProviderContainer(overrides: _sahte);
      addTearDown(kap.dispose);
      await t.pumpWidget(_uygulama(const YzBaslikEkrani(slug: 'kavramlar'), kap: kap));
      await t.pumpAndSettle();
      expect(kap.read(yzIpucuProvider), isFalse);
      final kart = find.byKey(const ValueKey('yz-yuzen-ipucu'));
      expect(kart, findsOneWidget);
      expect(t.getBottomLeft(kart).dy, lessThanOrEqualTo(t.getTopLeft(_altCubuk).dy),
          reason: 'alt çubuğun üstünde');
      // Metnin üstünde değil: kart kaydırılan içerikte değil.
      expect(find.descendant(of: find.byType(SingleChildScrollView).first, matching: kart), findsNothing);
      await t.pump(const Duration(seconds: 7));
      expect(kart, findsOneWidget);
      await t.pump(const Duration(seconds: 2));
      await t.pumpAndSettle();
      expect(kart, findsNothing);
      expect(kap.read(yzIpucuProvider), isTrue);
    });

    testWidgets('"Anladım" kapatıyor', (t) async {
      _telefon(t);
      final kap = ProviderContainer(overrides: _sahte);
      addTearDown(kap.dispose);
      await t.pumpWidget(_uygulama(const YzBaslikEkrani(slug: 'kavramlar'), kap: kap));
      await t.pumpAndSettle();
      await t.tap(find.text('Anladım'));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('yz-yuzen-ipucu')), findsNothing);
      expect(kap.read(yzIpucuProvider), isTrue);
    });
  });

  group('telefon · içindekiler, kaydırma, üst şerit', () {
    testWidgets('içindekiler: önce başa dön, okunan bölüm vurgulu; dokununca gidiyor', (t) async {
      _telefon(t);
      _ipucuGoruldu();
      await t.pumpWidget(_uygulama(const YzBaslikEkrani(slug: _saha)));
      await t.pumpAndSettle();
      await t.tap(find.text('İçindekiler'));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      final basaDon = find.text('Başa dön');
      expect(basaDon, findsOneWidget);
      final ilkBaslik = find.descendant(of: find.byType(BottomSheet), matching: find.text(_dron));
      expect(ilkBaslik, findsOneWidget);
      expect(t.getTopLeft(basaDon).dy, lessThan(t.getTopLeft(ilkBaslik).dy), reason: 'ilk satır başa dön');
      await t.tap(ilkBaslik);
      await t.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing, reason: 'sayfa kapanıyor');
      expect(_konum(t).pixels, greaterThan(0));
      // Gidilen başlık görünür; üst çubuk onu örtmüyor (çubuklar saklı).
      final metindeki =
          find.descendant(of: find.byType(SingleChildScrollView).first, matching: find.text(_dron));
      expect(t.getTopLeft(metindeki).dy, greaterThanOrEqualTo(0));
      expect(t.getTopLeft(metindeki).dy, lessThan(812 / 2));
      expect(_ustKayma(t), -1);
      // Okunan bölüm üst şeritte, tek satır.
      final serittekiAd =
          find.descendant(of: find.byType(YzUstSerit), matching: find.text(_dron));
      expect(serittekiAd, findsOneWidget);
      expect(t.widget<Text>(serittekiAd).maxLines, 1);
      // İçindekiler yeniden açılınca okunan bölüm yumuşak zeminle.
      await t.drag(find.byType(SingleChildScrollView).first, const Offset(0, 30));
      await t.pumpAndSettle();
      await t.tap(find.text('İçindekiler'));
      await t.pumpAndSettle();
      final vurgulu = find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byWidgetPredicate((w) => w is Material && w.color == YzRenk.makineAcik),
      );
      expect(vurgulu, findsOneWidget);
      // Başa dön.
      await t.tap(find.text('Başa dön'));
      await t.pumpAndSettle();
      expect(_konum(t).pixels, 0);
      expect(_ustKayma(t), 0);
      expect(find.descendant(of: find.byType(YzUstSerit), matching: find.text(_dron)), findsNothing);
    });

    testWidgets('?bolum= ile açılınca üst çubuk alt başlığı örtmüyor', (t) async {
      _telefon(t);
      _ipucuGoruldu();
      await t.pumpWidget(_yonlendirmeli(_yonlendirici('$yzPath/$_saha?bolum=turkiye-ilaclama-dronlari')));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      final metindeki =
          find.descendant(of: find.byType(SingleChildScrollView).first, matching: find.text(_dron));
      final y = t.getTopLeft(metindeki).dy;
      expect(y, lessThan(400), reason: 'o bölümden açılıyor');
      expect(_ustKayma(t) == -1 || y >= kYzUstSeritYuksekligi, isTrue, reason: 'örtülmüyor');
    });

    testWidgets('aşağı kaydırınca çubuklar saklanıyor, yukarı kaydırınca geliyor; okuma çizgisi',
        (t) async {
      _telefon(t);
      _ipucuGoruldu();
      await t.pumpWidget(_uygulama(const YzBaslikEkrani(slug: _saha)));
      await t.pumpAndSettle();
      expect(_ustKayma(t), 0);
      expect(_altYukseklikCarpani(t), 1);
      final kaydirici = find.byType(SingleChildScrollView).first;
      await t.drag(kaydirici, const Offset(0, -600));
      await t.pumpAndSettle();
      expect(_ustKayma(t), -1, reason: 'üst çubuk saklı');
      expect(_altYukseklikCarpani(t), 0, reason: 'alt çubuk saklı');
      // Okuma çizgisi en üstte kalıyor ve ilerlemiş.
      final cizgi = find.byKey(const ValueKey('yz-okuma-cizgisi'));
      expect(t.getTopLeft(cizgi).dy, 0);
      final dolu = t.widget<FractionallySizedBox>(
          find.descendant(of: cizgi, matching: find.byType(FractionallySizedBox)));
      expect(dolu.widthFactor, greaterThan(0));
      await t.drag(kaydirici, const Offset(0, 120));
      await t.pumpAndSettle();
      expect(_ustKayma(t), 0, reason: 'yukarı kaydırınca geri');
      expect(_altYukseklikCarpani(t), 1);
      expect(t.getTopLeft(cizgi).dy, kYzUstSeritYuksekligi, reason: 'üst çubuğun hemen altında');
      // Sayfanın sonunda alt çubuk görünüyor; son kart örtülmüyor.
      final p = _konum(t);
      await t.drag(kaydirici, Offset(0, -(p.maxScrollExtent + 2000)));
      await t.pumpAndSettle();
      expect(_altYukseklikCarpani(t), 1, reason: 'sonda görünür');
      expect(t.takeException(), isNull);
    });
  });

  group('telefon · alt çubuk sayfaları', () {
    testWidgets('yazı boyu: A+ büyütüyor, boy yazıyor', (t) async {
      _telefon(t);
      _ipucuGoruldu();
      final kap = ProviderContainer(overrides: _sahte);
      addTearDown(kap.dispose);
      await t.pumpWidget(_uygulama(const YzBaslikEkrani(slug: _saha), kap: kap));
      await t.pumpAndSettle();
      await t.tap(find.text('Yazı boyu'));
      await t.pumpAndSettle();
      expect(find.text('%100'), findsOneWidget);
      await t.tap(find.byTooltip('Büyüt'));
      await t.pumpAndSettle();
      expect(kap.read(yzYaziOlcegiProvider), kYzYaziOlcekleri[2]);
      expect(find.text('%112'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('paylaş: üç satır; bağlantıyı kopyala tam adres veriyor', (t) async {
      _telefon(t);
      _ipucuGoruldu();
      String? kopya;
      t.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (c) async {
        if (c.method == 'Clipboard.setData') kopya = (c.arguments as Map)['text'] as String?;
        return null;
      });
      addTearDown(() => t.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
      await t.pumpWidget(_uygulama(const YzBaslikEkrani(slug: _saha)));
      await t.pumpAndSettle();
      await t.tap(find.text('Paylaş'));
      await t.pumpAndSettle();
      expect(find.text('Bağlantıyı paylaş'), findsOneWidget);
      expect(find.text('Yazdır / PDF'), findsOneWidget);
      await t.tap(find.text('Bağlantıyı kopyala'));
      await t.pumpAndSettle();
      expect(kopya, 'https://tarimportali.net$yzPath/$_saha');
      expect(find.text('Bağlantı kopyalandı'), findsOneWidget);
    });

    testWidgets('ara: bölüm içi arama açılıyor', (t) async {
      _telefon(t);
      _ipucuGoruldu();
      final r = _yonlendirici('$yzPath/$_saha');
      await t.pumpWidget(_yonlendirmeli(r));
      await t.pumpAndSettle();
      await t.tap(find.descendant(of: _altCubuk, matching: find.text('Ara')));
      await t.pumpAndSettle();
      expect(find.byType(YzAramaEkrani), findsOneWidget);
    });
  });

  group('telefon · işaret çubuğu', () {
    testWidgets('metnin üstünde değil, alt çubuğun üstünde: ad · N yer, sonraki, kapat', (t) async {
      _telefon(t);
      _ipucuGoruldu();
      final r = _yonlendirici('$yzPath/goruntu-isleme-ve-hedefli-ilaclama?teknoloji=goruntu');
      await t.pumpWidget(_yonlendirmeli(r));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      final sayi = kYzTeknolojiIzi[8]!['goruntu']![0];
      expect(sayi, greaterThan(0));
      final ad = kYzTeknoloji['goruntu']!['tr']!;
      final cubuk = find.byKey(const ValueKey('yz-isaret-cubugu'));
      expect(cubuk, findsOneWidget);
      expect(find.descendant(of: cubuk, matching: find.text('$ad · $sayi yer')), findsOneWidget);
      expect(find.textContaining('geçtiği yerler işaretli'), findsNothing, reason: 'uzun şerit yok');
      expect(t.getBottomLeft(cubuk).dy, lessThanOrEqualTo(t.getTopLeft(_altCubuk).dy));
      // Metin yine ilk ekranın üçte birinde (çipler ve işaretle).
      expect(t.getTopLeft(find.byType(SelectableText).first).dy, lessThan(812 / 3));
      await t.tap(find.descendant(of: cubuk, matching: find.text('Sonraki ↓')));
      await t.pumpAndSettle();
      expect(_konum(t).pixels, greaterThan(0));
      await t.tap(find.byTooltip('İşareti kaldır'));
      await t.pumpAndSettle();
      expect(r.routerDelegate.currentConfiguration.uri.queryParameters.containsKey('teknoloji'), isFalse);
      expect(cubuk, findsNothing);
    });
  });

  group('masaüstü değişmedi (1280 piksel)', () {
    testWidgets('künye uzun, yazdır başlıkta, ray, bağlantı simgesi, üst şerit düğmeleri; alt çubuk yok',
        (t) async {
      _masaustu(t);
      final kap = ProviderContainer(overrides: _sahte);
      addTearDown(kap.dispose);
      await t.pumpWidget(_uygulama(const YzBaslikEkrani(slug: _saha), kap: kap));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.textContaining('Kaynaklarından son okunduğu gün'), findsOneWidget);
      expect(find.textContaining('dakikalık okuma'), findsOneWidget);
      expect(find.text('Yazdır / PDF'), findsOneWidget);
      expect(find.text('İÇİNDEKİLER'), findsOneWidget, reason: 'ray');
      expect(find.byTooltip('Bu bölümün bağlantısını kopyala'), findsWidgets);
      expect(find.byTooltip('Bölümde ara'), findsOneWidget);
      expect(find.byTooltip('Yazı boyu'), findsOneWidget);
      expect(_altCubuk, findsNothing);
      expect(find.byKey(const ValueKey('yz-okuma-cizgisi')), findsNothing);
      expect(find.byType(AnimatedSlide), findsNothing);
      // İpucu metnin üstünde, yüzen kart yok.
      expect(kap.read(yzIpucuProvider), isFalse);
      expect(find.textContaining('Mavi rakamlara dokunun'), findsOneWidget);
      expect(find.byKey(const ValueKey('yz-yuzen-ipucu')), findsNothing);
      // Kaydırınca üst şerit yerinde, bölümün adı değişmiyor.
      await t.drag(find.byType(SingleChildScrollView).at(1), const Offset(0, -1500));
      await t.pumpAndSettle();
      expect(t.getTopLeft(find.byType(YzUstSerit)).dy, 0);
      expect(find.descendant(of: find.byType(YzUstSerit), matching: find.text(buyukHarf(kYzAdTr, false))), findsOneWidget);
    });

    testWidgets('işaret şeridi metnin üstünde, uzun cümleyle', (t) async {
      _masaustu(t);
      final r = _yonlendirici('$yzPath/goruntu-isleme-ve-hedefli-ilaclama?teknoloji=goruntu');
      await t.pumpWidget(_yonlendirmeli(r));
      await t.pumpAndSettle();
      expect(find.textContaining('geçtiği yerler işaretli'), findsOneWidget);
      expect(find.byKey(const ValueKey('yz-isaret-cubugu')), findsNothing);
    });

    testWidgets('tablette (800 piksel) satır içi içindekiler ve yüzen düğme', (t) async {
      t.view.physicalSize = const Size(800, 900);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      _ipucuGoruldu();
      await t.pumpWidget(_uygulama(const YzBaslikEkrani(slug: _saha)));
      await t.pumpAndSettle();
      expect(find.text('İÇİNDEKİLER'), findsOneWidget);
      expect(_altCubuk, findsNothing);
      await t.drag(find.byType(SingleChildScrollView).first, const Offset(0, -900));
      await t.pumpAndSettle();
      expect(find.widgetWithText(Material, 'İçindekiler'), findsWidgets, reason: 'yüzen düğme');
      expect(find.byType(YzMetinGorunumu), findsOneWidget);
    });
  });
}

