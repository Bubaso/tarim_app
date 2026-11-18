import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_deposu.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_iskelet.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_kisaltmalar.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_metinler.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_sozluk.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_teknoloji.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_grafikler.g.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_gorsel.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_tasarim.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_arama_ekrani.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_baslik_ekrani.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_kisaltma.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_metin_gorunumu.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_okuma.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_parcalar.dart'
    show YzYonSatiri, yzPath, yzAramaPath;
import 'package:tarim_app/features/yapay_zeka/yz_providers.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Okuma deneyimi turu (karar 60, 18 Kas 2026)
// ──────────────────────────────────────────────────────────────────────────
//  Kısaltma balonu, temel terim, bölünmez boşluk, okuma süresi, arama,
//  kaldığı yer, içindekiler rayı ve telefonda katlanan içindekiler.
// ══════════════════════════════════════════════════════════════════════════

Widget _uygulama(Widget cocuk, {String dil = 'tr'}) => ProviderScope(
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
        home: cocuk,
      ),
    );

Widget _yonlendirmeli(String konum, {String dil = 'tr'}) {
  final r = GoRouter(initialLocation: konum, routes: [
    GoRoute(path: yzPath, builder: (c, s) => const Scaffold(body: Text('MERKEZ'))),
    GoRoute(path: yzAramaPath, builder: (c, s) => YzAramaEkrani(sorgu: s.uri.queryParameters['q'] ?? '')),
    GoRoute(path: '$yzPath/:slug', builder: (c, s) => YzBaslikEkrani(slug: s.pathParameters['slug'] ?? '')),
  ]);
  return ProviderScope(
    overrides: [
      yzBolumHaberleriProvider.overrideWith((ref, no) async => const <YzHaber>[]),
      yzDizinEklenenlerProvider.overrideWith((ref) async => const <YzDizinKaydi>[]),
    ],
    child: MaterialApp.router(
      routerConfig: r,
      locale: Locale(dil),
      supportedLocales: const [Locale('tr'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    ),
  );
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  // Okuma izi, yazı boyu ve ipucu tarayıcıda (SharedPreferences) tutuluyor.
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('kısaltma balonu', () {
    test('yalnız ilk geçiş; açılmışsa ve kalın içinde işaret yok', () {
      final gorulen = <String>{};
      const m = "TAGEM'in projesi. TAGEM yine geçti.";
      final i = yzKisaltmalariBul(m, gorulen);
      expect(i.length, 1);
      expect(m.substring(i.single.bas, i.single.son), 'TAGEM');
      expect(yzKisaltmalariBul('Başka bir paragrafta TAGEM.', gorulen), isEmpty,
          reason: 'sayfada bir kez');
      expect(
          yzKisaltmalariBul('Tarımsal Araştırmalar ve Politikalar Genel Müdürlüğü (TAGEM) dedi.', {}),
          isEmpty,
          reason: 'yanında açılmış');
      expect(yzKisaltmalariBul('Rapor **TAGEM** dedi.', {}), isEmpty, reason: 'kalın içi');
      expect(yzKisaltmalariBul('FAO (Christoplos, 2010) ve ÇKS.', {}).map((x) => x.kisaltma),
          ['ÇKS'],
          reason: 'atıf parantezi açılım sayılmaz; FAO bilinen');
    });

    test('her sayfada açılmayan her kısaltmanın ya balonu var ya listede', () {
      final sayfalar = <String, String>{
        for (final b in kYzBasliklar)
          if (kYzMetinler[b.no] != null && b.no != 29 && b.no != 30) ...{
            '§${b.no} tr': kYzMetinler[b.no]!.metin(false),
            '§${b.no} en': kYzMetinler[b.no]!.metin(true),
          },
        for (final e in kYzTeknolojiMetinleri.entries) ...{
          '${e.key} tr': e.value.metin(false),
          '${e.key} en': e.value.metin(true),
        },
      };
      final harf = RegExp(r'[A-ZÇĞİÖŞÜ]');
      final bicim = RegExp(r'\*\*.+?\*\*|\*[^*]+?\*');
      for (final s in sayfalar.entries) {
        final gorulen = <String>{};
        for (final b in yzAyristir(s.value)) {
          for (final p in b.parcalar) {
            final bicimli = [for (final m in bicim.allMatches(p)) (m.start, m.end)];
            for (final m in yzKisaltmaDeseni.allMatches(p)) {
              final k = m.group(1)!;
              if (harf.allMatches(k).length < 2 || gorulen.contains(k)) continue;
              if (bicimli.any((x) => m.start >= x.$1 && m.start < x.$2)) continue;
              gorulen.add(k);
              final tamam = kYzKisaltmalar.containsKey(k) ||
                  kYzKisaltmaDisi.contains(k) ||
                  yzKisaltmaAcilmis(p, m.start, m.end);
              expect(tamam, isTrue, reason: '${s.key}: $k açılmıyor ve balonu yok');
            }
          }
        }
      }
    });
  });

  group('temel terim ve bölünmez boşluk', () {
    test('temel terimin balonu yalnız Kavramlar sayfasında', () {
      final yz = kYzSozluk.firstWhere((t) => t.kimlik == 'yapay-zeka');
      expect(yz.temel, isTrue);
      expect(yz.balonda(kYzKavramlarNo), isTrue);
      expect(yz.balonda(8), isFalse);
      expect(yz.balonda(null), isFalse, reason: 'teknoloji sayfası');
      final ml = kYzSozluk.firstWhere((t) => t.kimlik == 'makine-ogrenmesi');
      expect(ml.balonda(8), isTrue, reason: 'temel olmayan terim her yerde');
    });

    test('rakam ile birim aynı satırda; uzunluk ve konum aynı', () {
      const m = 'Toplam **1,2 milyar** dolar, **47** milyar lira ve **3** ülke.';
      final b = yzBolunmez(m);
      expect(b.length, m.length);
      expect(b, contains('**1,2 milyar**'));
      expect(b, contains('**47** milyar'));
      expect(b, contains('**3** ülke'), reason: 'birim değil');
    });
  });

  group('okuma süresi ve arama', () {
    test('okuma süresi kelimeden; yönerge ve ayıraç sayılmaz', () {
      final md = '# 1 · Başlık\n\n${List.filled(360, 'kelime').join(' ')}\n\n[[grafik:x]]\n\n|---|---|\n';
      expect(yzKelimeSayisi(md), 360);
      expect(yzOkumaSuresi(md, false), 2);
      expect(yzOkumaSuresiYazisi(md, false), '2 dakikalık okuma');
      expect(yzOkumaSuresi('# 1 · B\n\nkısa', false), 1, reason: 'en az bir dakika');
    });

    test('arama büyük-küçük harf ve Türkçe karakter gözetmiyor', () {
      expect(yzAramaKatla('Çiftçi TARSİM Işık', false), 'ciftci tarsim isik');
      final k = yzAramaKelimeleri('çiftçi  sigorta', false);
      expect(k, ['ciftci', 'sigorta']);
      expect(yzAramaGeciyor('Çiftçiler tarım sigortası yaptırdı.', k, false), isTrue);
      expect(yzAramaGeciyor('Çiftçiler yaptırdı.', k, false), isFalse, reason: 'iki kelime de');
      const m = 'TARSİM ve tarsim';
      final a = yzAramaAraliklari(m, yzAramaKelimeleri('tarsim', false), false);
      expect([for (final x in a) m.substring(x.$1, x.$2)], ['TARSİM', 'tarsim']);
    });

    testWidgets('arama sayfası sonuç veriyor, sonuç işaretli açılıyor', (t) async {
      t.view.physicalSize = const Size(1280, 900);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(_yonlendirmeli('$yzAramaPath?q=TARSİM'));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.textContaining('sayfada'), findsWidgets);
      final kart = find.text('İklim, risk ve tarım sigortası');
      expect(kart, findsOneWidget);
      await t.tap(kart);
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.textContaining('“TARSİM” bu sayfada'), findsOneWidget);
      expect(find.text('Sonraki ↓'), findsOneWidget);
    });

    testWidgets('bulunmayan sorgu açık söyleniyor', (t) async {
      await t.pumpWidget(_yonlendirmeli('$yzAramaPath?q=zzqqxx'));
      await t.pumpAndSettle();
      expect(find.textContaining('bu bölümde geçmiyor'), findsOneWidget);
    });
  });

  group('kaldığı yer', () {
    test('kayıt bir kez okunur; başka başlık açılınca düşer', () {
      YzOkumaKonumu.kaydet('a', 420);
      expect(YzOkumaKonumu.al('sozluk'), isNull, reason: 'sözlük kaydı düşürmez');
      expect(YzOkumaKonumu.al('a'), 420);
      expect(YzOkumaKonumu.al('a'), isNull);
      YzOkumaKonumu.kaydet('a', 100);
      expect(YzOkumaKonumu.al('b'), isNull);
      expect(YzOkumaKonumu.al('a'), isNull);
    });

    testWidgets('sözlük terimin üstünde, terim işaretli açılıyor', (t) async {
      t.view.physicalSize = const Size(1280, 900);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(_yonlendirmeli('$yzPath/sozluk?terim=makine-ogrenmesi&geri=kavramlar'));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.textContaining('Makine öğrenmesi', findRichText: true), findsWidgets);
    });

    // Canlıda görüldü (18 Kas 2026): Wrap'le kurulan satırda telefonda
    // virgül satır başına düşüyor, "Kavramlar ." yazıyordu.
    for (final dil in ['tr', 'en']) {
      testWidgets('ilk kez gelen okura yön satırı tek paragraf, noktalama yapışık · $dil',
          (t) async {
        t.view.physicalSize = const Size(360, 800);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        await t.pumpWidget(_uygulama(
            const Scaffold(body: Padding(padding: EdgeInsets.all(16), child: YzYonSatiri())),
            dil: dil));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        final paragraf = find.byWidgetPredicate((w) =>
            w is RichText && w.text.toPlainText().startsWith(dil == 'tr' ? 'İlk kez' : 'New here'));
        expect(paragraf, findsOneWidget);
        final duz = t.widget<RichText>(paragraf).text.toPlainText();
        // Bağlantılar satır içi parça (U+FFFC); ardından gelen noktalama ona yapışık.
        expect(duz, dil == 'tr'
            ? 'İlk kez mi geliyorsunuz? Önce ￼, terimler için ￼.'
            : 'New here? Start with ￼; for the terms, ￼.');
        expect(find.text(yzBaslik(1)!.ad(dil == 'en')), findsOneWidget);
        expect(find.text(yzBaslik(2)!.ad(dil == 'en').split(':').first.trim()), findsOneWidget);
      });
    }
  });

  group('içindekiler', () {
    testWidgets('geniş ekranda ray, metnin üstünde içindekiler yok', (t) async {
      t.view.physicalSize = const Size(1280, 900);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(_uygulama(const YzBaslikEkrani(slug: 'saha-hikayeleri')));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.text('İÇİNDEKİLER'), findsOneWidget, reason: 'yalnız ray');
      expect(find.text('Başa dön'), findsOneWidget);
      expect(find.textContaining('dakikalık okuma'), findsOneWidget);
      expect(find.text('Yazdır / PDF'), findsOneWidget, reason: 'yazdırılabilir sürüm');
    });

    // Mobil tur (karar 62): telefonda metnin üstünde içindekiler kartı yok;
    // içindekiler alt çubuktan, alttan açılan sayfada.
    testWidgets('telefonda içindekiler alt çubuktan açılıyor', (t) async {
      t.view.physicalSize = const Size(375, 812);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(_uygulama(const YzBaslikEkrani(slug: 'saha-hikayeleri')));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.textContaining('İÇİNDEKİLER · '), findsNothing, reason: 'satır içi kart yok');
      expect(find.text('Türkiye: ilaçlama dronları'), findsWidgets,
          reason: 'alt başlık metinde var');
      await t.tap(find.text('İçindekiler'));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      // Açılınca alt başlık hem içindekilerde hem metinde.
      expect(find.text('Türkiye: ilaçlama dronları').evaluate().length, greaterThanOrEqualTo(2));
    });

    testWidgets('yazı boyu büyüyünce sayfa taşmıyor', (t) async {
      t.view.physicalSize = const Size(375, 812);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final kap = ProviderContainer(overrides: [
        yzBolumHaberleriProvider.overrideWith((ref, no) async => const <YzHaber>[]),
        yzDizinEklenenlerProvider.overrideWith((ref) async => const <YzDizinKaydi>[]),
      ]);
      addTearDown(kap.dispose);
      for (var i = 0; i < kYzYaziOlcekleri.length; i++) {
        kap.read(yzYaziOlcegiProvider.notifier).buyut();
      }
      expect(kap.read(yzYaziOlcegiProvider), kYzYaziOlcekleri.last);
      await t.pumpWidget(UncontrolledProviderScope(
        container: kap,
        child: const MaterialApp(home: YzBaslikEkrani(slug: 'turkiyede-durum')),
      ));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    });
  });

  testWidgets('madde işareti küçük kare; madde metni işaretin yanında', (t) async {
    t.view.physicalSize = const Size(800, 800);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: YzMetinGorunumu(
                    metin: '# 1 · B\n\nGiriş:\n\n- birinci madde\n- ikinci madde\n', en: false)))));
    await t.pumpAndSettle();
    final isaretler = find.byWidgetPredicate((w) =>
        w is Container &&
        w.decoration is BoxDecoration &&
        (w.decoration as BoxDecoration).borderRadius == BorderRadius.circular(1));
    expect(isaretler, findsNWidgets(2));
    for (final e in isaretler.evaluate()) {
      expect(t.getSize(find.byWidget(e.widget)), const Size(6, 6), reason: 'çubuk değil kare');
    }
    final kare = t.getRect(find.byWidget(isaretler.evaluate().first.widget));
    final madde = t.getRect(find.textContaining('birinci madde', findRichText: true).first);
    expect(madde.left - kare.right, greaterThanOrEqualTo(10), reason: 'madde metni işarete yapışmasın');
  });

  testWidgets('teknoloji vurgusu kelime düzeyinde; paragrafın solunda çizgi yok', (t) async {
    t.view.physicalSize = const Size(900, 900);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
        _yonlendirmeli('$yzPath/goruntu-isleme-ve-hedefli-ilaclama?teknoloji=goruntu'));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    final solCizgi = find.byWidgetPredicate((w) {
      if (w is! Container || w.decoration is! BoxDecoration) return false;
      final b = (w.decoration as BoxDecoration).border;
      return b is Border && b.left.width >= 2 && b.top == BorderSide.none;
    });
    expect(solCizgi, findsNothing,
        reason: 'paragraf, şerit ya da içindekiler solunda dikey çizgi (kullanıcı)');
    var kalem = 0;
    for (final e in find.byType(SelectableText).evaluate()) {
      (e.widget as SelectableText).textSpan?.visitChildren((span) {
        if (span is TextSpan && span.style?.backgroundColor == kYzKalemRengi) kalem++;
        return true;
      });
    }
    expect(kalem, greaterThan(0), reason: 'teknolojinin geçtiği kelimeler fosforlu kalemle');
    // Rakam gövde yazı tipinde (kullanıcının seçimi B): ayrı eşit genişlikli
    // yazı tipi yok, renk çelik mavisi.
    var rakam = 0;
    for (final e in find.byType(SelectableText).evaluate()) {
      (e.widget as SelectableText).textSpan?.visitChildren((span) {
        if (span is TextSpan && RegExp(r'^%?\d').hasMatch(span.text ?? '') &&
            span.style?.color == YzRenk.makine) {
          rakam++;
          expect(span.style?.fontFamily, isNull, reason: 'rakam gövdenin yazı tipini kullanmalı');
        }
        return true;
      });
    }
    expect(rakam, greaterThan(0));
    expect(find.textContaining('bu sayfada'), findsOneWidget);
  });

  group('okuma izi, ipucu, bölüm adresi (karar 60)', () {
    test('sayfanın %80\'i geçilince okundu; yarıda kalan son sayfa', () {
      final d = YzOkumaIziDenetcisi();
      addTearDown(d.dispose);
      d.ilerle('$yzPath/a', 'A', 0.3);
      expect(d.state.okunan, isEmpty);
      expect(d.state.yarimKaldi, isTrue);
      expect(d.state.sonAd, 'A');
      d.ilerle('$yzPath/a', 'A', 0.85);
      expect(d.state.okunan, {'$yzPath/a'});
      expect(d.state.yarimKaldi, isFalse, reason: 'okunan sayfa yarım sayılmaz');
      d.ilerle('$yzPath/b', 'B', 0.5);
      expect(d.state.sonYol, '$yzPath/b');
      expect(d.state.okunan, {'$yzPath/a'});
    });

    test('kaldığı yer oranla da saklanıyor', () {
      YzOkumaKonumu.kaydetOran('x', 0.4);
      final k = YzOkumaKonumu.alHepsi('x');
      expect(k?.$1, isNull);
      expect(k?.$2, 0.4);
      expect(YzOkumaKonumu.alHepsi('x'), isNull);
    });

    testWidgets('ipucu bir kez; kapatınca gelmiyor', (t) async {
      t.view.physicalSize = const Size(900, 900);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final kap = ProviderContainer(overrides: [
        yzBolumHaberleriProvider.overrideWith((ref, no) async => const <YzHaber>[]),
        yzDizinEklenenlerProvider.overrideWith((ref) async => const <YzDizinKaydi>[]),
      ]);
      addTearDown(kap.dispose);
      await t.pumpWidget(UncontrolledProviderScope(
        container: kap,
        child: _uygulama(const YzBaslikEkrani(slug: 'kavramlar')),
      ));
      await t.pumpAndSettle();
      if (kap.read(yzIpucuProvider) == false) {
        expect(find.textContaining('Mavi rakamlara dokunun'), findsOneWidget);
        await t.tap(find.text('Anladım'));
        await t.pumpAndSettle();
      }
      expect(kap.read(yzIpucuProvider), isTrue);
      expect(find.textContaining('Mavi rakamlara dokunun'), findsNothing);
    });

    testWidgets('?bolum= ile alt başlıktan açılıyor; bağlantı düğmesi var', (t) async {
      t.view.physicalSize = const Size(900, 900);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(_yonlendirmeli('$yzPath/saha-hikayeleri?bolum=turkiye-ilaclama-dronlari'));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      final baslik = find.text('Türkiye: ilaçlama dronları').last;
      final y = t.getTopLeft(baslik).dy;
      expect(y, lessThan(400), reason: 'sayfa o bölümden açılmalı');
      expect(find.byTooltip('Bu bölümün bağlantısını kopyala'), findsWidgets);
    });
  });

  testWidgets('İngilizce lejantlı haritada Türkçe sayfada çeviri satırı, İngilizcede yok', (t) async {
    final g = kYzGorseller['b14-global-fishing-watch-yapay-zeka-ve']!;
    expect(g.lejantTr, startsWith('Görseldeki yazılar:'));
    for (final en in [false, true]) {
      await t.pumpWidget(MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: YzGorselKarti(gorsel: g, en: en)))));
      expect(find.textContaining('Görseldeki yazılar:'), en ? findsNothing : findsOneWidget);
    }
    // Türkçe kopyası olan görselde Türkçe sayfa kopyayı gösteriyor.
    final k = kYzGorseller['b24-ab-yapay-zeka-tuzugu-risk-piramidi']!;
    expect(k.adresi(false), endsWith('.tr.webp'));
    expect(k.adresi(true), isNot(endsWith('.tr.webp')));
    expect(k.kaynak(false), contains('Türkçeye uyarlandı'));
  });

  test('bölümün arayüzünde hiçbir yerde sol çizgi yok (kullanıcı, 18 Kas 2026)', () {
    final desen = RegExp(r'Border\(\s*left:|left:\s*BorderSide');
    for (final f in Directory('lib/features/yapay_zeka/presentation')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      expect(desen.hasMatch(f.readAsStringSync()), isFalse, reason: '${f.path}: sol çizgi');
    }
  });

  test('her teknoloji sayfasında ve başlıkta listeler iki dilde aynı', () {
    for (final b in kYzBasliklar) {
      final m = kYzMetinler[b.no];
      if (m == null) continue;
      List<int> yapi(String md) =>
          [for (final x in yzAyristir(md)) if (x.tur == YzBlokTuru.liste) x.ogeler.length];
      expect(yapi(m.tr), yapi(m.en), reason: '§${b.no}: TR ve EN listeleri ayrı');
    }
  });
}
