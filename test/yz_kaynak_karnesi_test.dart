import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_deposu.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_iskelet.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_kaynak_karnesi.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_rakam_kaynaklari.g.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_baslik_ekrani.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_cerceve_mobil.dart' show YzCerceveKunye;
import 'package:tarim_app/features/yapay_zeka/presentation/yz_kaynak_karnesi.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_matris.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_merkez_ekrani.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_metin_gorunumu.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_parcalar.dart' show yzPath;
import 'package:tarim_app/features/yapay_zeka/presentation/yz_tasarim.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_teknoloji_ekrani.dart';
import 'package:tarim_app/features/yapay_zeka/yz_providers.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Kaynak karnesi (25 Kasım 2026)
// ──────────────────────────────────────────────────────────────────────────
//  Her başlığın ve teknoloji sayfasının mavi rakamları hangi tür kaynağa
//  dayanıyor: hakemli çalışma, kurumsal rapor (KURUMSAL + PROJE), resmî
//  kaynak, satıcı beyanı. Okuma sayfasında künyenin altında tek satır
//  (telefonda kısa satır + alttan açılan döküm); merkezde ısı haritasının
//  ikinci görünümü. Yorum yok, hesap var: karne kayıtlardan yeniden
//  hesaplanınca aynı (Python'da dogrula_bolumler.py kural 18, burada Dart).
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

Widget _uygulama(Widget cocuk, {String dil = 'tr'}) => ProviderScope(
      overrides: _sahte,
      child: MaterialApp(
        locale: Locale(dil),
        supportedLocales: const [Locale('tr'), Locale('en')],
        localizationsDelegates: _dilVekilleri,
        home: cocuk,
      ),
    );

/// Merkez sayfa yönlendiriciyle: hücreye dokununca başlık açılıyor mu.
Widget _yonlendirmeli(String dil) => ProviderScope(
      overrides: _sahte,
      child: MaterialApp.router(
        routerConfig: GoRouter(initialLocation: yzPath, routes: [
          GoRoute(path: yzPath, builder: (c, s) => const YzMerkezEkrani()),
          GoRoute(
              path: '$yzPath/:slug',
              builder: (c, s) => Scaffold(body: Text('BAŞLIK ${s.pathParameters['slug']}'))),
        ]),
        locale: Locale(dil),
        supportedLocales: const [Locale('tr'), Locale('en')],
        localizationsDelegates: _dilVekilleri,
      ),
    );

void _boyut(WidgetTester t, Size s) {
  t.view.physicalSize = s;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

const _telefon = Size(375, 812);
const _masaustu = Size(1280, 900);
const _genis = Size(1440, 900);

/// İpucu önceden görülmüş: telefonda alt çubuğun üstünde yüzmesin.
void _ipucuGoruldu() => SharedPreferences.setMockInitialValues({'yz_ipucu_goruldu': true});

const _turkiye = 'turkiyede-durum'; // §23
const _tarihce = 'tarihce'; // §3: dört türün dördü de var

Finder get _satir => find.byKey(const ValueKey('yz-karne-satiri'));
Finder get _mobil => find.byKey(const ValueKey('yz-karne-mobil'));
Finder get _makaleMetni =>
    find.descendant(of: find.byType(YzMetinGorunumu), matching: find.byType(RichText));

String _satirMetni(WidgetTester t) =>
    t.widget<Text>(find.descendant(of: _satir, matching: find.byType(Text))).data!;

/// Ekrandaki biçim → düz cümle (bölünmez boşluk ve satır sonu düz boşluk).
String _duz(String s) => s.replaceAll(' ', ' ').replaceAll(':\n', ': ');

String _sayfa(String slug) {
  final b = kYzBasliklar.firstWhere((x) => x.slug == slug);
  return 'b${b.no.toString().padLeft(2, '0')}';
}

const _teknolojiAciklamasiTr =
    'Her hücre, bir teknolojinin bir başlıkta geçtiği yer sayısı. Hücreye dokununca başlık o yerler işaretli açılır; teknolojinin adına dokununca kendi sayfası.';
const _kaynakAciklamasiTr =
    'Her hücre, bir başlıktaki mavi rakamların dayandığı kaynak sayısı, kaynağın türüne göre: hakemli çalışma, kurumsal rapor, resmî kaynak, satıcı ya da proje beyanı. Hücreye dokununca başlık açılır.';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  setUp(_ipucuGoruldu);

  // ── Gerçek yazı tipiyle (DOSYANIN BAŞINDA: yazı tipi bekleyen widget
  // kurulmadan yükleniyor; yüklenen yazı tipi sonraki testlere de geçer).
  group('masaüstü satırı gerçek yazı tipiyle (gömülü Newsreader)', () {
    testWidgets('üç türe kadar tek satır; dört türde ayrıntı ikinci satırda; 653 px\'i aşmıyor',
        (t) async {
      final aile = YzYazi.govde(boy: 13).fontFamily!;
      final bayt = File('assets/google_fonts/Newsreader-Regular.ttf').readAsBytesSync();
      await t.runAsync(() async {
        await (FontLoader(aile)..addFont(Future.value(ByteData.view(bayt.buffer)))).load();
      });
      _boyut(t, _masaustu);
      for (final dil in ['tr', 'en']) {
        for (final e in kYzKaynakKarnesi.entries) {
          // Başlık bloğu 610 px; görsel ve tablonun payı 43 px (760 px sütun).
          await t.pumpWidget(_uygulama(
            Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(width: 610, child: YzKarneSatiri(karne: e.value, en: dil == 'en', sagPay: 43)),
              ),
            ),
            dil: dil,
          ));
          expect(t.takeException(), isNull);
          final metin = find.descendant(of: _satir, matching: find.byType(Text));
          final yukseklik = t.getSize(metin).height;
          final satir = find.descendant(of: _satir, matching: find.byType(Row));
          expect(t.getSize(satir).width, lessThanOrEqualTo(653), reason: '${e.key} $dil');
          final dortTur = e.value.turler.every((n) => n > 0);
          if (dortTur) {
            expect(_satirMetni(t), contains(':\n'), reason: '${e.key} $dil: ayrıntı ikinci satırda');
            expect(yukseklik, lessThan(13 * 1.4 * 2 + 1), reason: '${e.key} $dil: iki satır');
          } else {
            expect(yukseklik, lessThan(13 * 1.4 + 1), reason: '${e.key} $dil: tek satır');
          }
          expect(_duz(_satirMetni(t)), yzKarneCumlesi(e.value, dil == 'en'));
        }
      }
    });
  });

  group('veri', () {
    test('karne kayıtlardan yeniden hesaplanınca aynı (her sayfa, TR ve EN birleşimi)', () {
      // Proje beyanı satıcı beyanıyla aynı kümede (metin ona "proje beyanı" diyor).
      const tur = {'HAKEMLI': 0, 'KURUMSAL': 1, 'RESMI': 2, 'SATICI': 3, 'PROJE': 3};
      final sayfalar = {for (final k in kYzRakamKaynak.keys) k.split(':').first};
      expect(sayfalar, isNotEmpty);
      expect(kYzKaynakKarnesi.keys.toSet(), sayfalar, reason: 'rakam eşlemesindeki her sayfanın karnesi var');
      for (final s in sayfalar) {
        final kayit = jsonDecode(
                File('content/yapay_zeka_dijital_tarim/_raw/${s}_kaynaklar.json').readAsStringSync())
            as Map<String, dynamic>;
        final kaynaklar = kayit['kaynaklar'] as Map<String, dynamic>;
        final destek = <String>{
          for (final dil in ['tr', 'en'])
            for (final adaylar in (kYzRakamKaynak['$s:$dil'] ?? const {}).values)
              for (final a in adaylar) a[0],
        };
        expect(destek, kYzKaynakKunye[s]!.keys.toSet(), reason: '$s: farklı kaynaklar = künyeler');
        final say = [0, 0, 0, 0];
        for (final a in destek) {
          final i = tur[(kaynaklar[a] as Map<String, dynamic>?)?['nitelik']];
          if (i != null) say[i]++;
        }
        final k = kYzKaynakKarnesi[s]!;
        expect(k.turler, say, reason: s);
        expect(k.toplam, say.reduce((a, b) => a + b), reason: s);
        expect(k.rakamTr, kYzRakamKaynak['$s:tr']!.length, reason: '$s kaynaklı rakam (TR)');
        expect(k.rakamEn, kYzRakamKaynak['$s:en']!.length, reason: '$s kaynaklı rakam (EN)');
        expect([...k.turler, k.rakamTr, k.rakamEn].every((n) => n >= 0), isTrue);
      }
      expect(kYzKaynakKarnesi.values.any((k) => k.toplam >= 1), isTrue);
      // Sözlük ve kaynakça: karne yok.
      expect(yzKarne('b29'), isNull);
      expect(yzKarne('b30'), isNull);
      expect(yzKarne(null), isNull);
    });

    test('cümle: sıra sabit, sıfır tür yazılmaz, tekil ve çoğul doğru', () {
      const k = YzKarne(12, 6, 4, 1, 0, 0, 0);
      expect(yzKarneCumlesi(k, false),
          'Rakamlar 23 kaynağa dayanıyor: 12 hakemli çalışma · 6 kurumsal rapor · 4 resmî kaynak · 1 satıcı beyanı');
      expect(yzKarneCumlesi(k, true),
          'Figures rest on 23 sources: 12 peer-reviewed · 6 institutional reports · 4 official sources · 1 vendor claim');
      const iki = YzKarne(0, 1, 0, 2, 0, 0, 0);
      expect(yzKarneCumlesi(iki, false), 'Rakamlar 3 kaynağa dayanıyor: 1 kurumsal rapor · 2 satıcı beyanı');
      expect(yzKarneCumlesi(iki, true), 'Figures rest on 3 sources: 1 institutional report · 2 vendor claims');
      const bir = YzKarne(0, 0, 1, 0, 0, 0, 0);
      expect(yzKarneCumlesi(bir, true), 'Figures rest on 1 source: 1 official source');
      expect(yzKarneKisa(k, false), '23 kaynak');
      expect(yzKarneKisa(k, true), '23 sources');
      expect(yzKarneKisa(bir, true), '1 source');
      expect(yzKarne('b23'), same(kYzKaynakKarnesi['b23']));
      // Proje beyanı adıyla ayrı yazılıyor, satıcı beyanıyla aynı kümede.
      const proje = YzKarne(2, 1, 0, 0, 1, 0, 0);
      expect(yzKarneCumlesi(proje, false), 'Rakamlar 4 kaynağa dayanıyor: 2 hakemli çalışma · 1 kurumsal rapor · 1 proje beyanı');
      expect(yzKarneCumlesi(proje, true), 'Figures rest on 4 sources: 2 peer-reviewed · 1 institutional report · 1 project claim');
      expect(proje.turler, [2, 1, 0, 1]);
      expect(kYzKaynakKarnesi['b07']!.proje, greaterThan(0), reason: 'AquaTag proje broşürü');
    });

    test('renkler WCAG AA: dilimler ≥ 3:1, resmî metinde de ≥ 4,5:1, hücre yazısı ≥ 4,5:1', () {
      expect(kYzKarneRenkleri, [YzRenk.bitki, YzRenk.makine, kYzKarneResmi, YzRenk.bekleyen]);
      for (final r in kYzKarneRenkleri) {
        expect(yzKontrast(r, YzRenk.zemin), greaterThanOrEqualTo(3));
        expect(yzKontrast(r, YzRenk.yuzey), greaterThanOrEqualTo(3));
      }
      expect(yzKontrast(kYzKarneResmi, YzRenk.zemin), greaterThanOrEqualTo(4.5));
      expect(yzKontrast(kYzKarneResmi, YzRenk.yuzey), greaterThanOrEqualTo(4.5));
      for (final enBuyuk in [1, 3, 12, 20]) {
        for (var tur = 0; tur < kYzKarneTurSayisi; tur++) {
          for (var n = 1; n <= enBuyuk; n++) {
            final (zemin, yazi) = yzKaynakHucreRengi(tur, n, enBuyuk);
            expect(yzKontrast(yazi, zemin), greaterThanOrEqualTo(4.5), reason: 'tür $tur, $n/$enBuyuk');
          }
        }
      }
    });
  });

  group('okuma sayfası · masaüstü', () {
    for (final boy in [_masaustu, _genis]) {
      for (final dil in ['tr', 'en']) {
        testWidgets('başlık: künyenin hemen altında tek satır · ${boy.width.toInt()} · $dil', (t) async {
          _boyut(t, boy);
          final en = dil == 'en';
          await t.pumpWidget(_uygulama(const YzBaslikEkrani(slug: _turkiye), dil: dil));
          await t.pumpAndSettle();
          expect(t.takeException(), isNull);
          final k = kYzKaynakKarnesi[_sayfa(_turkiye)]!;
          expect(_satir, findsOneWidget);
          expect(_mobil, findsNothing);
          expect(_duz(_satirMetni(t)), yzKarneCumlesi(k, en));
          expect(find.descendant(of: _satir, matching: find.byType(YzKarneCubugu)), findsOneWidget);
          expect(t.getSize(find.byType(YzKarneCubugu)), const Size(140, 6));
          // Yeri: künye satırının (yazdır düğmesi dahil) hemen altında, metnin üstünde.
          final yazdir = find.ancestor(
              of: find.text(en ? 'Print / PDF' : 'Yazdır / PDF'), matching: find.byType(TextButton));
          final ust = t.getTopLeft(_satir).dy;
          expect(ust, greaterThanOrEqualTo(t.getBottomLeft(yazdir).dy - 0.5));
          expect(ust - t.getBottomLeft(yazdir).dy, lessThan(12), reason: 'hemen altında');
          expect(t.getBottomLeft(_satir).dy, lessThan(t.getTopLeft(_makaleMetni.first).dy));
          // Satır başlığın sol kenarında başlıyor.
          expect(t.getTopLeft(_satir).dx, t.getTopLeft(find.text(yzBaslik(23)!.ad(en)).first).dx);
        });
      }
    }

    for (final dil in ['tr', 'en']) {
      testWidgets('teknoloji sayfası: satır var · $dil', (t) async {
        _boyut(t, _masaustu);
        await t.pumpWidget(_uygulama(const YzTeknolojiEkrani(kod: 'genomik'), dil: dil));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        expect(_satir, findsOneWidget);
        expect(_duz(_satirMetni(t)), yzKarneCumlesi(kYzKaynakKarnesi['tek_genomik']!, dil == 'en'));
      });
    }
  });

  group('okuma sayfası · telefon', () {
    for (final dil in ['tr', 'en']) {
      testWidgets('başlık: kısa künyenin altında tek satır, dokununca döküm · $dil', (t) async {
        _boyut(t, _telefon);
        final en = dil == 'en';
        await t.pumpWidget(_uygulama(const YzBaslikEkrani(slug: _turkiye), dil: dil));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        final k = kYzKaynakKarnesi[_sayfa(_turkiye)]!;
        expect(_mobil, findsOneWidget);
        expect(_satir, findsNothing, reason: 'uzun cümle yalnız masaüstünde');
        expect(find.descendant(of: _mobil, matching: find.text(yzKarneKisa(k, en))), findsOneWidget);
        expect(find.descendant(of: _mobil, matching: find.byIcon(Icons.info_outline_rounded)), findsOneWidget);
        expect(find.descendant(of: _mobil, matching: find.byType(YzKarneCubugu)), findsOneWidget);
        // Kısa künyenin hemen altında; tek satır; üst bölüm en çok ~24 px uzuyor.
        final kunye = find.byType(YzCerceveKunye);
        final mobilUst = t.getTopLeft(_mobil).dy;
        expect(mobilUst, greaterThanOrEqualTo(t.getBottomLeft(kunye).dy - 0.5));
        expect(mobilUst - t.getBottomLeft(kunye).dy, lessThan(4));
        expect(t.getSize(find.descendant(of: _mobil, matching: find.byType(Text))).height, lessThan(24));
        const eskiBosluk = 16.0; // karnesiz telefon başlık bloğunun alt boşluğu
        final eklenen = t.getTopLeft(_makaleMetni.first).dy - t.getBottomLeft(kunye).dy - eskiBosluk;
        expect(eklenen, lessThanOrEqualTo(24), reason: 'üst bölüm en çok ~24 px uzar');
        expect(eklenen, lessThanOrEqualTo(6), reason: 'bugünkü ölçü: 15 + 6 − 16');
        expect(t.getSize(_mobil).height, greaterThanOrEqualTo(20), reason: 'dokunma alanı (tam genişlik)');
        expect(t.getSize(_mobil).width, greaterThanOrEqualTo(375 - 32 - 0.5));

        await t.tap(_mobil);
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        final sayfa = find.byType(BottomSheet);
        expect(sayfa, findsOneWidget);
        Finder icinde(String s) => find.descendant(of: sayfa, matching: find.text(s));
        expect(icinde(en ? 'Figures rest on ${k.toplam} sources' : 'Rakamlar ${k.toplam} kaynağa dayanıyor'),
            findsOneWidget);
        for (var i = 0; i < kYzKarneTurSayisi; i++) {
          expect(icinde(yzKarneTurAdi(i, en)), findsOneWidget, reason: 'türün adı yazılı');
          expect(icinde(yzKarneTanimi(i, en)), findsOneWidget, reason: 'bir cümlelik tanım');
        }
        final sayilar = [
          for (final e in find.descendant(of: sayfa, matching: find.byType(Text)).evaluate())
            if (RegExp(r'^\d+$').hasMatch((e.widget as Text).data ?? '')) int.parse((e.widget as Text).data!),
        ];
        expect(sayilar, k.turler, reason: 'dört türün sayısı, sırayla (sıfır dahil)');
        expect(find.descendant(of: sayfa, matching: find.byType(YzKarneCubugu)), findsOneWidget);
      });

      testWidgets('teknoloji sayfası: satır ve döküm · $dil', (t) async {
        _boyut(t, _telefon);
        await t.pumpWidget(_uygulama(const YzTeknolojiEkrani(kod: 'uzaktan'), dil: dil));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        final k = kYzKaynakKarnesi['tek_uzaktan']!;
        expect(find.descendant(of: _mobil, matching: find.text(yzKarneKisa(k, dil == 'en'))), findsOneWidget);
        await t.tap(_mobil);
        await t.pumpAndSettle();
        expect(find.byKey(const ValueKey('yz-karne-dokumu')), findsOneWidget);
        expect(t.takeException(), isNull);
      });
    }
  });

  group('karnesi olmayan sayfa', () {
    for (final slug in ['sozluk', 'kaynakca']) {
      for (final boy in [_telefon, _masaustu]) {
        testWidgets('$slug: hiçbir şey çizilmiyor · ${boy.width.toInt()}', (t) async {
          _boyut(t, boy);
          await t.pumpWidget(_uygulama(YzBaslikEkrani(slug: slug)));
          await t.pumpAndSettle();
          expect(t.takeException(), isNull);
          expect(_satir, findsNothing);
          expect(_mobil, findsNothing);
          expect(find.byType(YzKarneCubugu), findsNothing);
        });
      }
    }
  });

  group('merkez · ısı haritasının ikinci görünümü', () {
    Finder secenek(String ad) => find.byKey(ValueKey('yz-isi-secenek-$ad'));

    Future<void> kaynagaGec(WidgetTester t) async {
      await t.ensureVisible(secenek('kaynak'));
      await t.pumpAndSettle();
      await t.tap(secenek('kaynak'));
      await t.pumpAndSettle();
    }

    testWidgets('başlık ve vurgu aynen; varsayılan teknoloji; seçici iki görünümü değiştiriyor', (t) async {
      _boyut(t, _masaustu);
      await t.pumpWidget(_uygulama(const YzMerkezEkrani()));
      await t.pumpAndSettle();
      expect(find.text('Teknoloji ve Alan Isı Haritası'), findsOneWidget);
      expect(find.text('Tarımda Yapay Zeka kullanımının nabzını buradan takip edin.'), findsOneWidget);
      expect(find.descendant(of: secenek('teknoloji'), matching: find.text('Teknoloji')), findsOneWidget);
      expect(find.descendant(of: secenek('kaynak'), matching: find.text('Kaynak niteliği')), findsOneWidget);
      // Varsayılan: bugünkü görünüm.
      expect(find.text(_teknolojiAciklamasiTr), findsOneWidget);
      expect(find.text(_kaynakAciklamasiTr), findsNothing);
      expect(find.byType(YzKaynakMatrisi), findsNothing);
      expect(find.text(kYzTeknoloji.values.first['tr']!), findsWidgets);
      bool secili(String ad) => t
          .widget<Semantics>(find
              .ancestor(
                  of: secenek(ad),
                  matching: find.byWidgetPredicate(
                      (w) => w is Semantics && w.properties.inMutuallyExclusiveGroup == true))
              .first)
          .properties
          .selected!;
      expect(secili('teknoloji'), isTrue);
      expect(secili('kaynak'), isFalse);

      await kaynagaGec(t);
      expect(t.takeException(), isNull);
      expect(secili('kaynak'), isTrue);
      expect(find.byType(YzKaynakMatrisi), findsOneWidget);
      expect(find.byKey(const ValueKey('yz-kaynak-matrisi-yatay')), findsOneWidget, reason: 'masaüstü yatay');
      expect(find.text(_kaynakAciklamasiTr), findsOneWidget);
      expect(find.text(_teknolojiAciklamasiTr), findsNothing);
      // Satırlar dört tür, sütunlar karnesi olan başlıklar.
      for (var i = 0; i < kYzKarneTurSayisi; i++) {
        expect(find.descendant(of: find.byType(YzKaynakMatrisi), matching: find.text(yzKarneTurAdi(i, false))),
            findsOneWidget);
      }
      final karneli = kYzBasliklar.where((b) => yzKarne('b${b.no.toString().padLeft(2, '0')}') != null);
      expect(karneli.length, 28);
      for (final b in karneli) {
        expect(find.byKey(ValueKey('yz-kaynak-hucre-${b.no}-0')), findsOneWidget);
      }
      expect(find.byKey(const ValueKey('yz-kaynak-hucre-29-0')), findsNothing, reason: 'sözlüğün karnesi yok');
      // Hücre: o türden kaynak sayısı; ipucu biçimi.
      final k = kYzKaynakKarnesi['b23']!;
      final hucre = find.byKey(const ValueKey('yz-kaynak-hucre-23-2'));
      expect(t.widget<Tooltip>(find.ancestor(of: hucre, matching: find.byType(Tooltip))).message,
          "§23 Türkiye'de durum · resmî kaynak: ${k.resmi}");
      expect(find.descendant(of: hucre, matching: find.text('${k.resmi}')), findsOneWidget);
      expect(find.descendant(of: find.byKey(const ValueKey('yz-kaynak-hucre-23-0')), matching: find.byType(Text)),
          k.hakemli == 0 ? findsNothing : findsOneWidget);

      // Teknolojiye dönüş.
      await t.tap(secenek('teknoloji'));
      await t.pumpAndSettle();
      expect(find.byType(YzKaynakMatrisi), findsNothing);
      expect(find.text(_teknolojiAciklamasiTr), findsOneWidget);

      // Yeni açılan sayfada yine teknoloji.
      await kaynagaGec(t);
      await t.pumpWidget(const SizedBox());
      await t.pumpWidget(_uygulama(const YzMerkezEkrani()));
      await t.pumpAndSettle();
      expect(find.byType(YzKaynakMatrisi), findsNothing);
      expect(find.text(_teknolojiAciklamasiTr), findsOneWidget);
    });

    testWidgets('İngilizce: seçenek adları ve açıklama', (t) async {
      _boyut(t, _masaustu);
      await t.pumpWidget(_uygulama(const YzMerkezEkrani(), dil: 'en'));
      await t.pumpAndSettle();
      expect(find.descendant(of: secenek('teknoloji'), matching: find.text('Technology')), findsOneWidget);
      expect(find.descendant(of: secenek('kaynak'), matching: find.text('Source type')), findsOneWidget);
      await kaynagaGec(t);
      expect(find.byKey(const ValueKey('yz-isi-aciklama-kaynak')), findsOneWidget);
      expect(t.widget<Text>(find.byKey(const ValueKey('yz-isi-aciklama-kaynak'))).data,
          startsWith('Each cell is the number of sources the blue figures in a heading rest on'));
      final hucre = find.byKey(const ValueKey('yz-kaynak-hucre-23-2'));
      expect(t.widget<Tooltip>(find.ancestor(of: hucre, matching: find.byType(Tooltip))).message,
          '§23 ${yzBaslik(23)!.ad(true)} · official source: ${kYzKaynakKarnesi['b23']!.resmi}');
    });

    for (final dil in ['tr', 'en']) {
      testWidgets('hücreye dokununca başlık açılıyor · $dil', (t) async {
        _boyut(t, _masaustu);
        await t.pumpWidget(_yonlendirmeli(dil));
        await t.pumpAndSettle();
        await kaynagaGec(t);
        final hucre = find.byKey(const ValueKey('yz-kaynak-hucre-23-2'));
        await t.ensureVisible(hucre);
        await t.pumpAndSettle();
        await t.tap(hucre);
        await t.pumpAndSettle();
        expect(find.text('BAŞLIK $_turkiye'), findsOneWidget);
      });
    }

    testWidgets('telefon: başlıklar satırda, dört tür sütunda, yatay kaydırma yok; dokununca başlık', (t) async {
      _boyut(t, _telefon);
      await t.pumpWidget(_yonlendirmeli('tr'));
      await t.pumpAndSettle();
      await kaynagaGec(t);
      expect(t.takeException(), isNull);
      final harita = find.byType(YzKaynakMatrisi);
      expect(find.byKey(const ValueKey('yz-kaynak-matrisi-dikey')), findsOneWidget);
      expect(find.descendant(of: harita, matching: find.byType(Scrollable)), findsNothing);
      final r = t.getRect(harita);
      expect(r.left, greaterThanOrEqualTo(16 - 0.5));
      expect(r.right, lessThanOrEqualTo(375 - 16 + 0.5));
      // Seçici telefonda 44 px dokunma yüksekliğinde.
      expect(t.getSize(secenek('kaynak')).height, greaterThanOrEqualTo(44));
      final hucre = find.byKey(const ValueKey('yz-kaynak-hucre-1-0'));
      await t.ensureVisible(hucre);
      await t.pumpAndSettle();
      expect(t.getRect(hucre).right, lessThanOrEqualTo(375 - 16 + 0.5));
      await t.tap(hucre);
      await t.pumpAndSettle();
      expect(find.text('BAŞLIK ${kYzBasliklar.first.slug}'), findsOneWidget);
    });
  });

  group('taşma yok · 375, 1280, 1440 · TR ve EN', () {
    for (final boy in [_telefon, _masaustu, _genis]) {
      for (final dil in ['tr', 'en']) {
        final ad = '${boy.width.toInt()} · $dil';
        testWidgets('başlık (iki ve dört türlü) ve teknoloji sayfası · $ad', (t) async {
          _boyut(t, boy);
          for (final w in const [
            YzBaslikEkrani(slug: _turkiye),
            YzBaslikEkrani(slug: _tarihce),
            YzTeknolojiEkrani(kod: 'robotik'),
          ]) {
            await t.pumpWidget(_uygulama(w, dil: dil));
            await t.pumpAndSettle();
            expect(t.takeException(), isNull, reason: '$w');
            expect(boy.width < 640 ? _mobil : _satir, findsOneWidget);
            await t.pumpWidget(const SizedBox());
          }
        });

        testWidgets('merkez, kaynak niteliği görünümü · $ad', (t) async {
          _boyut(t, boy);
          await t.pumpWidget(_uygulama(const YzMerkezEkrani(), dil: dil));
          await t.pumpAndSettle();
          await t.ensureVisible(find.byKey(const ValueKey('yz-isi-secenek-kaynak')));
          await t.pumpAndSettle();
          await t.tap(find.byKey(const ValueKey('yz-isi-secenek-kaynak')));
          await t.pumpAndSettle();
          expect(t.takeException(), isNull);
          expect(find.byType(YzKaynakMatrisi), findsOneWidget);
          final r = t.getRect(find.byType(YzKaynakMatrisi));
          expect(r.right, lessThanOrEqualTo(boy.width + 0.5));
        });
      }
    }

    for (final boy in [_telefon, _masaustu]) {
      testWidgets('merkez en büyük yazıda, kaynak görünümü · ${boy.width.toInt()}', (t) async {
        _boyut(t, boy);
        SharedPreferences.setMockInitialValues({'yz_yazi_olcegi': 1.4});
        await t.pumpWidget(_uygulama(const YzMerkezEkrani()));
        await t.pumpAndSettle();
        await t.ensureVisible(find.byKey(const ValueKey('yz-isi-secenek-kaynak')));
        await t.pumpAndSettle();
        await t.tap(find.byKey(const ValueKey('yz-isi-secenek-kaynak')));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
      });
    }
  });
}
