import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarim_app/core/utils/turkce_metin.dart' show etiketSlug;
import 'package:tarim_app/features/home/data/models/news_article.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_deposu.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_iskelet.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_metinler.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_teknoloji.g.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_baslik_ekrani.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_metin_gorunumu.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_okuma.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_okuma_olcer.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_olcum_gonderici.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_parcalar.dart'
    show YzBaslikKarosu, YzYonSatiri, yzPath, yzBaslikPath;
import 'package:tarim_app/features/yapay_zeka/presentation/yz_seridi.dart';
import 'package:tarim_app/features/yapay_zeka/yz_providers.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Okuma izi metne bağlı (madde 17), "Kaldığınız yer" şeritte (madde 18),
//  sıradaki başlık (madde 20), okuma adımı olayı (madde 24), karolar
//  yeniden kurulmuyor (madde 31). 19 Kas 2026.
// ══════════════════════════════════════════════════════════════════════════

const _slug = 'urun-izleme-ve-verim-tahmini';
final _no = kYzBasliklar.firstWhere((b) => b.slug == _slug).no;

List<Override> get _bos => [
      yzBolumHaberleriProvider.overrideWith((ref, no) async => const <YzHaber>[]),
      yzDizinEklenenlerProvider.overrideWith((ref) async => const <YzDizinKaydi>[]),
    ];

const _yerel = [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

Widget _sayfa(ProviderContainer kap, String konum, {bool hareketsiz = false}) {
  final r = GoRouter(initialLocation: konum, routes: [
    GoRoute(path: yzPath, builder: (c, s) => const Scaffold(body: Text('MERKEZ'))),
    GoRoute(path: '$yzPath/:slug', builder: (c, s) => YzBaslikEkrani(slug: s.pathParameters['slug'] ?? '')),
  ]);
  return UncontrolledProviderScope(
    container: kap,
    child: MaterialApp.router(
      routerConfig: r,
      locale: const Locale('tr'),
      supportedLocales: const [Locale('tr'), Locale('en')],
      localizationsDelegates: _yerel,
      builder: (c, w) => hareketsiz
          ? MediaQuery(data: MediaQuery.of(c).copyWith(disableAnimations: true), child: w!)
          : w!,
    ),
  );
}

void _ekran(WidgetTester t, Size boy) {
  t.view.physicalSize = boy;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

/// Sayfanın kaydırıcısı (metin sütunu).
ScrollPosition _konum(WidgetTester t) => t
    .state<ScrollableState>(find
        .descendant(of: find.byType(SingleChildScrollView), matching: find.byType(Scrollable))
        .first)
    .position;

/// Okurun kendi kaydırması: parmakla, ekran ekran.
Future<void> _parmakla(WidgetTester t, {int kez = 1, double dy = -500}) async {
  for (var i = 0; i < kez; i++) {
    await t.dragFrom(const Offset(180, 500), Offset(0, dy));
    await t.pump(const Duration(milliseconds: 100));
  }
  await t.pumpAndSettle();
}

YzSonOkunan _kayit(String slug,
        {double oran = 0.4, int paragraf = 5, String ozet = 'x', int altSira = 1, String altAd = 'Bölüm', DateTime? zaman}) =>
    YzSonOkunan(
      yol: yzBaslikPath(slug),
      ad: 'Ad',
      oran: oran,
      paragraf: paragraf,
      ozet: ozet,
      altSira: altSira,
      altAd: altAd,
      zaman: zaman ?? DateTime.now(),
    );

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final olaylar = <(String, Map<String, Object>)>[];
  setUp(() {
    olaylar.clear();
    YzGiris.al(); // önceki testin işareti kalmasın
    YzOkumaTakipcisi.olcum = (o, p) => olaylar.add((o, p));
  });
  tearDown(() => YzOkumaTakipcisi.olcum = yzOlcum);
  List<String> adimlar() => [for (final o in olaylar) o.$2['adim'] as String];

  group('madde 31: önceden sayılmış kelime ve süre', () {
    test('iskeletteki sayılar yzKelimeSayisi ile aynı; dakikalar değişmedi', () {
      expect(kYzKelimeSayilari.keys.toSet(), kYzMetinler.keys.toSet());
      for (final m in kYzMetinler.values) {
        for (final en in [false, true]) {
          final md = m.metin(en);
          expect(kYzKelimeSayilari[m.no]![en ? 1 : 0], yzKelimeSayisi(md), reason: '§${m.no} $en');
          expect(yzBaslikDakikasi(m.no, en), yzOkumaSuresi(md, en), reason: '§${m.no} $en dakika');
        }
      }
    });

    test('metin haritasının blok ağırlıklarının toplamı da aynı (başlık ve teknoloji)', () {
      final metinler = [
        for (final m in kYzMetinler.values) ...[m.metin(false), m.metin(true)],
        for (final m in kYzTeknolojiMetinleri.values) ...[m.metin(false), m.metin(true)],
      ];
      for (final md in metinler) {
        expect(YzMetinHaritasi.kur(md, false).toplam, yzKelimeSayisi(md));
      }
    });

    testWidgets('karo yalnız kendi okundu durumu değişince yeniden kuruluyor', (t) async {
      final kap = ProviderContainer(overrides: _bos);
      addTearDown(kap.dispose);
      final a = kYzBasliklar[0], b = kYzBasliklar[1];
      await t.pumpWidget(UncontrolledProviderScope(
        container: kap,
        child: MaterialApp(
          locale: const Locale('tr'),
          supportedLocales: const [Locale('tr'), Locale('en')],
          localizationsDelegates: _yerel,
          home: Scaffold(
            body: Column(children: [
              YzBaslikKarosu(baslik: a),
              YzBaslikKarosu(baslik: b),
              const YzYonSatiri(),
            ]),
          ),
        ),
      ));
      await t.pumpAndSettle();
      expect(find.textContaining('dk okuma'), findsNWidgets(2));
      final d = kap.read(yzOkumaIziProvider.notifier);
      Element karo(int i) => t.element(find.byType(YzBaslikKarosu).at(i));
      Element yon() => t.element(find.byType(YzYonSatiri));

      // Başka bir sayfada ilerleme: hiçbir karo kirlenmiyor.
      d.konum(_kayit('tarihce', oran: 0.3, paragraf: 3, altSira: 0, altAd: 'X'));
      await t.pump();
      expect(yon().dirty, isFalse);
      d.konum(_kayit('tarihce', oran: 0.35, paragraf: 4, altSira: 0, altAd: 'X'));
      expect(karo(0).dirty, isFalse);
      expect(karo(1).dirty, isFalse);
      expect(yon().dirty, isFalse, reason: 'yön satırının gösterdiği alanlar değişmedi');
      await t.pump();

      // Karonun kendi başlığı okundu: yalnız o karo.
      d.okundu(yzBaslikPath(a.slug));
      expect(karo(0).dirty, isTrue);
      expect(karo(1).dirty, isFalse);
      await t.pump();
      expect(find.textContaining('✓ okundu'), findsOneWidget);
    });
  });

  group('madde 17: kayıt ve okundu tanımı', () {
    test('eski kayıt yalnız yedek okunuyor; yeni anahtar öncelikli', () async {
      SharedPreferences.setMockInitialValues({
        'yz_okunan': ['$yzPath/kavramlar'],
        'yz_son_okunan': ['$yzPath/$_slug', 'Eski ad', '0.400'],
      });
      final d = YzOkumaIziDenetcisi();
      addTearDown(d.dispose);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(d.state.okunan, {'$yzPath/kavramlar'}, reason: 'eski okundu bilgisi korunuyor');
      expect(d.state.son?.yol, '$yzPath/$_slug');
      expect(d.state.son?.paragraf, -1);
      expect(d.state.son?.oran, 0.4);
      expect(d.state.yarimKaldi, isTrue);
      final devam = yzDevam(d.state, en: false);
      expect(devam?.baslik, kYzBasliklar.firstWhere((b) => b.slug == _slug).tr,
          reason: 'başlık adı iskeletten');
      expect(devam?.altBaslik, isNull, reason: 'eski kayıtta alt başlık yok');
      // Eski kayıt konumu oranla açıyor.
      expect(yzDevamHazirla(d.state, 'devam'), '$yzPath/$_slug');
      expect(YzOkumaKonumu.alTumu(_slug)?.$2, 0.4);

      // İlk güncelleme yeni anahtara yazıyor; eskisine dokunmuyor.
      d.konum(_kayit(_slug, oran: 0.5, paragraf: 7, altSira: 1, altAd: 'B'));
      await Future<void>.delayed(Duration.zero);
      final p = await SharedPreferences.getInstance();
      final yeni = jsonDecode(p.getString('yz_son_okunan_m')!) as Map;
      expect(yeni['p'], 7);
      expect(yeni['aa'], 'B');
      expect(p.getStringList('yz_son_okunan'), ['$yzPath/$_slug', 'Eski ad', '0.400']);

      SharedPreferences.setMockInitialValues({
        'yz_son_okunan': ['$yzPath/kavramlar', 'Eski', '0.5'],
        'yz_son_okunan_m': jsonEncode(_kayit(_slug, paragraf: 9).toJson()),
      });
      final d2 = YzOkumaIziDenetcisi();
      addTearDown(d2.dispose);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(d2.state.son?.yol, '$yzPath/$_slug');
      expect(d2.state.son?.paragraf, 9);
    });

    test('başvuru sayfası ve bayat kayıt "Kaldığınız yer" olmuyor', () {
      final d = YzOkumaIziDenetcisi();
      addTearDown(d.dispose);
      d.konum(_kayit('kavramlar'));
      d.konum(_kayit('sozluk'));
      expect(d.state.son?.slug, 'kavramlar', reason: 'sözlük son okunanın yerine geçmez');
      expect(yzDevam(d.state, en: false), isNotNull);
      expect(yzDevam(d.state, en: false, simdi: DateTime.now().add(const Duration(days: 31))), isNull,
          reason: '30 günden eski');
      expect(yzDevam(d.state, en: true)?.altBaslik, isNull, reason: 'alt başlık başka dilde okunmuş');
      d.konum(_kayit('kavramlar', oran: 0.03));
      expect(yzDevam(d.state, en: false), isNull, reason: '%5 geçilmeden yarım değil');
    });

    test('okundu: sona varmak yetmez, okurun kendi kaydırması ya da süresi gerek', () {
      final md = kYzMetinler[_no]!.metin(false);
      final h = YzMetinHaritasi.kur(md, false);
      List<double> kadar(double oran) {
        final l = List<double>.filled(h.uzunluk, 0);
        var birikim = 0;
        for (var i = 0; i < h.uzunluk; i++) {
          birikim += h.kelime[i];
          if (birikim / h.toplam <= oran) l[i] = 1;
        }
        return l;
      }

      // İçindekilerden sona atlayan okur.
      final atlayan = YzOkumaOlcer(h);
      atlayan.guncelle(kadar(1), atlama: true, sonGorunuyor: true);
      expect(atlayan.sonaVardi, isTrue);
      expect(atlayan.okundu, isFalse, reason: 'atlama kendi kaydırma sayılmaz');
      expect(atlayan.yeniEsikler(atlama: true), isEmpty, reason: 'atlamayla geçilen eşik gitmez');

      // %65'i kendisi okuyup gerisini atlayan okur.
      final okuyan = YzOkumaOlcer(h);
      okuyan.guncelle(kadar(0.65), atlama: false, sonGorunuyor: false);
      expect(okuyan.okundu, isFalse, reason: 'sona varmadı');
      okuyan.guncelle(kadar(1), atlama: true, sonGorunuyor: true);
      expect(okuyan.okundu, isTrue);

      // Yavaş okur: kendi kaydırması az ama süresi beklenenin %30'unu geçti.
      final yavas = YzOkumaOlcer(h);
      yavas.guncelle(kadar(1), atlama: true, sonGorunuyor: true);
      yavas.aktifMs = (h.beklenenSaniye * 0.31 * 1000).round();
      expect(yavas.okundu, isTrue);

      // Önceki ziyaretin kendi kaydırması kayıttan geri geliyor.
      final kayit = YzSonOkunan(
        yol: yzBaslikPath(_slug),
        oran: okuyan.enDerin,
        kendi: okuyan.kendiDizgisi,
        blokSayisi: h.uzunluk,
      );
      final donen = YzOkumaOlcer(h, onceki: kayit);
      expect(donen.kendiOrani, closeTo(okuyan.kendiOrani, 0.05));
    });

    test('kayıt dosyadaki paragrafa bağlı; özet tutmazsa alt başlığın başı', () {
      final md = kYzMetinler[_no]!.metin(false);
      final h = YzMetinHaritasi.kur(md, false);
      final bloklar = yzAyristir(md);
      final p = bloklar.lastIndexWhere((b) => b.tur == YzBlokTuru.paragraf);
      final alt = h.altSira[p];
      final dogru = YzSonOkunan(
          yol: yzBaslikPath(_slug), paragraf: p, ozet: h.ozet[p], altSira: alt, altAd: h.altAdlari[alt]);
      expect(h.bul(dogru), p);
      expect(yzParagrafOzeti('**Bir** paragraf, kalın ve *italik*'), yzParagrafOzeti('Bir paragraf kalın ve italik'),
          reason: 'görünen harfler');
      final degisti = YzSonOkunan(
          yol: dogru.yol, paragraf: p, ozet: 'baska', altSira: alt, altAd: h.altAdlari[alt]);
      expect(h.bul(degisti), h.altBloklari[alt]);
      final baskaDil = YzSonOkunan(yol: dogru.yol, paragraf: p, ozet: h.ozet[p], altSira: alt, altAd: 'x', en: true);
      expect(h.bul(baskaDil), h.altBloklari[alt], reason: 'öbür dilde sırası');
    });

    testWidgets('kendi kaydırmasıyla sona inen okur okudu; çizgi kelimeyle ilerliyor', (t) async {
      _ekran(t, const Size(375, 812));
      final kap = ProviderContainer(overrides: _bos);
      addTearDown(kap.dispose);
      await t.pumpWidget(_sayfa(kap, yzBaslikPath(_slug)));
      await t.pump();
      await t.pump();
      expect(adimlar(), ['acildi']);
      final acildi = olaylar.single.$2;
      expect(acildi.keys.toSet(), {
        'adim', 'sayfa', 'sayfa_turu', 'bolum_sira', 'bolum_sayisi', 'cihaz', 'dil', 'yazi_olcegi', 'giris',
      });
      expect(acildi['sayfa'], _slug);
      expect(acildi['sayfa_turu'], 'baslik');
      expect(acildi['cihaz'], 'telefon');
      expect(acildi['giris'], 'dis');
      expect(acildi['bolum_sayisi'], YzMetinHaritasi.kur(kYzMetinler[_no]!.metin(false), false).altAdlari.length);

      final cizgi = t.widget<FractionallySizedBox>(find.descendant(
          of: find.byKey(const ValueKey('yz-okuma-cizgisi')), matching: find.byType(FractionallySizedBox)));
      expect(cizgi.widthFactor, lessThan(0.05));

      // Eşik sayfa 3 sn açık kalmadan gitmiyor (okurun kaydırması anında).
      final p = _konum(t);
      p.jumpTo(p.maxScrollExtent * 0.4);
      await t.pump();
      expect(adimlar(), ['acildi'], reason: '3 sn dolmadı');
      await t.pump(const Duration(seconds: 4));
      expect(adimlar(), contains('y25'));

      for (var i = 0; i < 40 && _konum(t).pixels < _konum(t).maxScrollExtent - 1; i++) {
        await _parmakla(t, kez: 3);
      }
      await t.pump(const Duration(seconds: 1));
      expect(kap.read(yzOkumaIziProvider).okunan, contains(yzBaslikPath(_slug)));
      expect(adimlar().where((a) => a.startsWith('y')), ['y25', 'y50', 'y75', 'y100']);
      final cizgi2 = t.widget<FractionallySizedBox>(find.descendant(
          of: find.byKey(const ValueKey('yz-okuma-cizgisi')), matching: find.byType(FractionallySizedBox)));
      expect(cizgi2.widthFactor, 1);
      for (final o in olaylar) {
        expect(o.$1, 'yz_okuma_adimi');
        for (final v in o.$2.values) {
          expect(v is num || (v is String && v.length <= 32), isTrue, reason: 'alt başlık metni gitmez: $v');
        }
      }
    });

    testWidgets('?bolum= ile sona atlayan okur okumuş sayılmıyor; atlanan eşikler gitmiyor', (t) async {
      _ekran(t, const Size(375, 812));
      final kap = ProviderContainer(overrides: _bos);
      addTearDown(kap.dispose);
      final h = YzMetinHaritasi.kur(kYzMetinler[_no]!.metin(false), false);
      final son = etiketSlug(h.altAdlari.last);
      await t.pumpWidget(_sayfa(kap, '${yzBaslikPath(_slug)}?bolum=$son'));
      await t.pumpAndSettle();
      expect(_konum(t).pixels, greaterThan(1000), reason: 'son bölüme atlandı');
      await _parmakla(t, kez: 6);
      await t.pump(const Duration(seconds: 5));
      expect(kap.read(yzOkumaIziProvider).okunan, isNot(contains(yzBaslikPath(_slug))));
      expect(adimlar(), isNot(contains('y25')));
      expect(adimlar(), isNot(contains('y50')));
      // Okur bu sayfada ilerledi: "Kaldığınız yer" son bölümde.
      final kayit = kap.read(yzOkumaIziProvider).son;
      expect(kayit?.altSira, h.altAdlari.length - 1);
      expect(kap.read(yzOkumaIziProvider).yarimKaldi, isTrue);
    });

    testWidgets('"Kaldığınız yer" paragrafa açılıyor; hareket azaltılmışsa animasyonsuz', (t) async {
      _ekran(t, const Size(375, 812));
      final kap = ProviderContainer(overrides: _bos);
      addTearDown(kap.dispose);
      final md = kYzMetinler[_no]!.metin(false);
      final h = YzMetinHaritasi.kur(md, false);
      final bloklar = yzAyristir(md);
      final p = bloklar.lastIndexWhere((b) => b.tur == YzBlokTuru.paragraf);
      final alt = h.altSira[p];
      kap.read(yzOkumaIziProvider.notifier).konum(YzSonOkunan(
          yol: yzBaslikPath(_slug), ad: 'x', oran: 0.6, paragraf: p, ozet: h.ozet[p],
          altSira: alt, altAd: h.altAdlari[alt], zaman: DateTime.now()));
      expect(yzDevamHazirla(kap.read(yzOkumaIziProvider), 'devam'), yzBaslikPath(_slug));
      await t.pumpWidget(_sayfa(kap, yzBaslikPath(_slug), hareketsiz: true));
      await t.pump();
      await t.pump();
      await t.pump();
      expect(_konum(t).isScrollingNotifier.value, isFalse, reason: 'animasyon yok');
      expect(_konum(t).pixels, greaterThan(0));
      final bas = bloklar[p].metin.replaceAll('*', '').substring(0, 20);
      final y = t.getTopLeft(find.textContaining(bas).first).dy;
      expect(y, inInclusiveRange(40, 140), reason: 'paragraf üst çubuğun hemen altında');
      await t.pumpAndSettle();
      expect(olaylar.first.$2['giris'], 'devam');
    });
  });

  group('madde 18: ana sayfa şeridi', () {
    NewsArticle haber(int i) => NewsArticle(
          id: 'h$i',
          title: 'Şerit haberi $i',
          content: 'x',
          createdAt: DateTime(2026, 11, 18).subtract(Duration(hours: i)),
          status: 'published',
          sourceName: 'Kaynak',
        );

    Future<ProviderContainer> serit(WidgetTester t, Size boy) async {
      _ekran(t, boy);
      final kap = ProviderContainer(overrides: [
        yzBolumHaberleriProvider.overrideWith((ref, no) async => [YzHaber(haber(1), 4), YzHaber(haber(2), 9)]),
      ]);
      addTearDown(kap.dispose);
      final r = GoRouter(routes: [
        GoRoute(
            path: '/',
            builder: (c, s) => const Scaffold(body: SingleChildScrollView(child: YzSeridi(okuraAcik: true)))),
        GoRoute(path: '$yzPath/:slug', builder: (c, s) => Scaffold(body: Text('SAYFA ${s.pathParameters['slug']}'))),
        GoRoute(path: yzPath, builder: (c, s) => const Scaffold(body: Text('MERKEZ'))),
        GoRoute(path: '/haber/:id', builder: (c, s) => Scaffold(body: Text('HABER ${s.pathParameters['id']}'))),
      ]);
      await t.pumpWidget(UncontrolledProviderScope(
        container: kap,
        child: MaterialApp.router(
          routerConfig: r,
          locale: const Locale('tr'),
          supportedLocales: const [Locale('tr'), Locale('en')],
          localizationsDelegates: _yerel,
        ),
      ));
      await t.pumpAndSettle();
      return kap;
    }

    for (final boy in const [Size(1280, 900), Size(375, 812)]) {
      testWidgets('yarım başlık yok: öne çıkan; masaüstünde tek haber, habere gidiyor · ${boy.width}', (t) async {
        await serit(t, boy);
        expect(t.takeException(), isNull, reason: 'taşma yok');
        expect(find.textContaining('Kaldığınız yer'), findsNothing);
        expect(find.textContaining('Şu an öne çıkan'), findsOneWidget);
        if (boy.width >= 700) {
          expect(find.text('Şerit haberi 1'), findsOneWidget);
          expect(find.text('Şerit haberi 2'), findsNothing, reason: 'en çok 1 haber');
          await t.tap(find.text('Şerit haberi 1'));
          await t.pumpAndSettle();
          expect(find.text('HABER h1'), findsOneWidget);
        } else {
          expect(find.textContaining('Şerit haberi'), findsNothing);
        }
      });

      testWidgets('yarım başlık var: "Kaldığınız yer", haber yok, ≥ 44 px · ${boy.width}', (t) async {
        SharedPreferences.setMockInitialValues({
          'yz_son_okunan_m': jsonEncode(_kayit(_slug, altAd: 'Türkiye', altSira: 3).toJson()),
        });
        await serit(t, boy);
        expect(t.takeException(), isNull, reason: 'taşma yok');
        final ad = kYzBasliklar.firstWhere((b) => b.slug == _slug).tr;
        final satir = find.textContaining('Kaldığınız yer: ');
        expect(satir, findsOneWidget);
        expect(find.textContaining('$ad · Türkiye →'), findsOneWidget);
        expect(find.textContaining('%'), findsNothing, reason: 'yüzde yok');
        expect(find.textContaining('Şu an öne çıkan'), findsNothing);
        expect(find.textContaining('Şerit haberi'), findsNothing);
        final alan = t.getSize(find.ancestor(of: satir, matching: find.byType(InkWell)).first);
        expect(alan.height, greaterThanOrEqualTo(44));
        await t.tap(satir);
        await t.pumpAndSettle();
        expect(find.text('SAYFA $_slug'), findsOneWidget);
        expect(YzOkumaKonumu.alTumu(_slug)?.$3?.altAd, 'Türkiye');
      });
    }
  });

  group('madde 20: sıradaki başlık', () {
    final sira = [for (final b in kYzBasliklar) if (b.yazildi && !kYzBasvuruSayfalari.contains(b.slug)) b.slug];

    test('okunmamış ilk sonraki; başvuru sayfası değil; hepsi okunduysa null', () {
      expect(yzSiradakiSlug({}, sira[0]), sira[1]);
      expect(yzSiradakiSlug({yzBaslikPath(sira[1])}, sira[0]), sira[2]);
      expect(yzSiradakiSlug({sira[1], sira[2]}, sira[0]), sira[3], reason: 'slug da kabul');
      expect(yzSiradakiSlug({}, sira.last), sira.first, reason: 'sondan sonra baştan; Sözlük değil');
      expect(yzSiradakiSlug({}, 'sozluk'), sira.first);
      expect(yzSiradakiSlug({for (final s in sira) yzBaslikPath(s)}, sira.first), isNull);
      expect(yzSiradakiSlug({for (final s in sira.skip(1)) yzBaslikPath(s)}, sira.last), sira.first);
      expect(sira, isNot(contains('sozluk')));
      expect(sira, isNot(contains('kaynakca')));
    });

    for (final boy in const [Size(1280, 900), Size(375, 812)]) {
      testWidgets('merkezde yarım başlık yokken "Sırada:" · ${boy.width}', (t) async {
        _ekran(t, boy);
        SharedPreferences.setMockInitialValues({
          'yz_okunan': [yzBaslikPath(sira[0])],
        });
        final kap = ProviderContainer(overrides: _bos);
        addTearDown(kap.dispose);
        await t.pumpWidget(UncontrolledProviderScope(
          container: kap,
          child: const MaterialApp(
            locale: Locale('tr'),
            supportedLocales: [Locale('tr'), Locale('en')],
            localizationsDelegates: _yerel,
            home: Scaffold(body: Padding(padding: EdgeInsets.all(16), child: YzYonSatiri())),
          ),
        ));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        expect(find.text('Sırada:'), findsOneWidget);
        expect(find.text('${kYzBasliklar.firstWhere((b) => b.slug == sira[1]).tr} →'), findsOneWidget);
      });
    }
  });

  test('yz_okuma.dart hafif: yalnız riverpod, shared_preferences ve iskelet', () {
    final s = File('lib/features/yapay_zeka/presentation/yz_okuma.dart').readAsStringSync();
    final aktarimlar = RegExp(r"^import '([^']+)'", multiLine: true).allMatches(s).map((m) => m.group(1)).toSet();
    expect(aktarimlar, {
      'dart:convert',
      'package:flutter_riverpod/flutter_riverpod.dart',
      'package:shared_preferences/shared_preferences.dart',
      '../data/yz_iskelet.g.dart',
    });
    final serit = File('lib/features/yapay_zeka/presentation/yz_seridi.dart').readAsStringSync();
    expect(serit, isNot(contains("import 'yz_okuma_olcer.dart'")));
    expect(serit, isNot(contains("import 'yz_parcalar.dart'")));
  });
}
