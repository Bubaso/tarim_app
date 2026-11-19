import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_cekmeler.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_deposu.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_metinler.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_teknoloji.g.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_arama_ekrani.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_cekme.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_metin_gorunumu.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_okuma.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_yollar.dart' show yzPath, yzAramaPath;
import 'package:tarim_app/features/yapay_zeka/presentation/yz_tasarim.dart';
import 'package:tarim_app/features/yapay_zeka/yz_providers.dart';

import 'yz_erteli_test.dart' show ilkYukKapanisi;

// ══════════════════════════════════════════════════════════════════════════
//  Öne çıkan cümle (madde 6) ve yönerge ayrıştırma
// ──────────────────────────────────────────────────────────────────────────
//  [[cekme:kimlik]] satırı metindeki bir cümleyi büyük puntoyla bir kez daha
//  çiziyor. Telefonda 23 px ≤5 satır, masaüstünde 28 px ≤3 satır (yazı boyu
//  en çok ×1,15 yansıyor; sınır bu etkin ölçekle sınanıyor); ekran okuyucu
//  ve sayfa seçimi görmüyor; arama, okuma süresi ve basılı sürüm saymıyor.
//  Tanınmayan yönerge blok değil, metin olarak da çizilmiyor.
// ══════════════════════════════════════════════════════════════════════════

final RegExp _cekmeSatiri = RegExp(r'^\[\[cekme:[a-z0-9-]+\]\]\n\n', multiLine: true);

/// Sayfanın metni, görselleri olmadan (ağdan resim istemesin); öne çıkan
/// cümle ve grafikler yerinde.
String _sayfa(YzCekmeCumlesi c, bool en) {
  final no = int.parse(c.sayfa.substring(1));
  return kYzMetinler[no]!.metin(en).replaceAll(RegExp(r'^\[\[gorsel:[a-z0-9-]+\]\]\n\n', multiLine: true), '');
}

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

/// Satır sayısı gerçek yazı tipiyle ölçülsün: gömülü Newsreader dosyası
/// google_fonts'un aile adıyla yükleniyor (testte ağ yok).
Future<void> _yaziTipiniYukle(WidgetTester t) async {
  final aile = yzCekmeStili(telefon: true).fontFamily!;
  final bayt = File('assets/google_fonts/Newsreader-Regular.ttf').readAsBytesSync();
  await t.runAsync(() async {
    await (FontLoader(aile)..addFont(Future.value(ByteData.view(bayt.buffer)))).load();
  });
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('yönerge ayrıştırma', () {
    test('cekme blok türü; tanınmayan yönerge blok değil ve metin olarak çizilmez', () {
      final b = yzAyristir('# 1 · B\n\nBir.\n\n[[cekme:x-1]]\n\n[[alinti:y]]\n\nİki.\n');
      expect(b.map((x) => x.tur).toList(),
          [YzBlokTuru.paragraf, YzBlokTuru.cekme, YzBlokTuru.paragraf]);
      expect(b[1].metin, 'x-1');
      expect(b[1].parcalar, isEmpty, reason: 'sözlük, kısaltma ve arama görmüyor');
      expect(b.any((x) => x.metin.contains('[[')), isFalse);
    });

    test('gömülü her sayfada TR ve EN blok dizisi aynı (yönerge sırası dahil)', () {
      final sayfalar = <String, (String, String)>{
        for (final m in kYzMetinler.values) '§${m.no}': (m.tr, m.en),
        for (final e in kYzTeknolojiMetinleri.entries) e.key: (e.value.tr, e.value.en),
      };
      for (final s in sayfalar.entries) {
        if (s.key == '§29' || s.key == '§30') continue; // üretilmiş: harf başlıkları dile göre
        String imza(String md) => [
              for (final b in yzAyristir(md))
                switch (b.tur) {
                  YzBlokTuru.grafik || YzBlokTuru.gorsel || YzBlokTuru.cekme => '${b.tur.name}:${b.metin}',
                  _ => b.tur.name,
                },
            ].join(' ');
        expect(imza(s.value.$2), imza(s.value.$1), reason: '${s.key}: TR ve EN blokları ayrışmış');
      }
    });

    test('her kayıtlı cümle kendi sayfasında, iki dilde, yönergesiyle', () {
      expect(kYzCekmeler, isNotEmpty);
      for (final c in kYzCekmeler.values) {
        for (final en in [false, true]) {
          final md = _sayfa(c, en);
          expect(md, contains('[[cekme:${c.kimlik}]]'));
          expect(yzCekmeCumlesi(c.kimlik, yzAyristir(md), en), c.cumle(en),
              reason: '${c.kimlik} ($en): cümle sayfanın paragraflarında yok');
          expect(c.cumle(en), contains('**'), reason: 'A sınıfı: kalın rakam');
        }
      }
    });
  });

  group('sayılara girmiyor', () {
    for (final c in kYzCekmeler.values) {
      for (final en in [false, true]) {
        test('${c.kimlik} · ${en ? 'en' : 'tr'} · okuma süresi ve arama sayısı değişmiyor', () {
          final md = kYzMetinler[int.parse(c.sayfa.substring(1))]!.metin(en);
          final yalin = md.replaceAll(_cekmeSatiri, '');
          expect(yalin, isNot(md));
          expect(yzKelimeSayisi(md), yzKelimeSayisi(yalin));
          expect(yzOkumaSuresi(md, en), yzOkumaSuresi(yalin, en));
          // Cümlenin kelimeleriyle arama: yalnız paragrafın kendisi sayılıyor.
          final uzun = RegExp(r'\p{L}{6,}', unicode: true).allMatches(c.cumle(en)).map((m) => m[0]!).join(' ');
          final kelimeler = yzAramaKelimeleri(uzun, en);
          expect(kelimeler, isNotEmpty);
          expect(yzAramaSay(md, kelimeler, en), yzAramaSay(yalin, kelimeler, en));
          expect(yzAramaSay(md, kelimeler, en), greaterThan(0));
        });
      }
    }
  });

  testWidgets('arama ekranı cümleyi bir kez buluyor (alıntı sonuç değil)', (t) async {
    final c = kYzCekmeler.values.first;
    final r = GoRouter(
        initialLocation: '$yzAramaPath?q=${Uri.encodeQueryComponent(c.tr.replaceAll('*', ''))}',
        routes: [
          GoRoute(path: yzPath, builder: (c, s) => const Scaffold(body: Text('MERKEZ'))),
          GoRoute(path: yzAramaPath, builder: (c, s) => YzAramaEkrani(sorgu: s.uri.queryParameters['q'] ?? '')),
        ]);
    t.view.physicalSize = const Size(1280, 900);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(ProviderScope(
      child: MaterialApp.router(
        routerConfig: r,
        locale: const Locale('tr'),
        supportedLocales: const [Locale('tr'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    ));
    await t.pumpAndSettle();
    expect(find.textContaining('1 sayfada 1 yerde geçiyor'), findsOneWidget);
  });

  group('çizim', () {
    for (final c in kYzCekmeler.values) {
      for (final en in [false, true]) {
        for (final (ad, olcu, telefon) in const [
          ('telefon', Size(375, 812), true),
          ('masaüstü', Size(1280, 900), false),
        ]) {
          for (final olcek in [1.0, kYzYaziOlcekleri.last]) {
            testWidgets('${c.kimlik} · ${en ? 'en' : 'tr'} · $ad · yazı boyu $olcek', (t) async {
              await _yaziTipiniYukle(t);
              t.view.physicalSize = olcu;
              t.view.devicePixelRatio = 1;
              addTearDown(t.view.reset);
              final semantik = t.ensureSemantics();
              await t.pumpWidget(_uygulama(
                  Center(
                    child: SizedBox(
                      width: telefon ? olcu.width - 32 : kYzMetinGenisligi,
                      child: YzMetinGorunumu(
                          metin: _sayfa(c, en), en: en, olcek: olcek, kaynakSayfasi: c.sayfa, bolumNo: 26),
                    ),
                  ),
                  dil: en ? 'en' : 'tr'));
              await t.pumpAndSettle();
              expect(t.takeException(), isNull, reason: 'taşma ya da çizim hatası');

              final kutu = find.byKey(ValueKey('yz-cekme-${c.kimlik}'));
              expect(kutu, findsOneWidget);
              final yazi = find.descendant(of: kutu, matching: find.byType(RichText));
              expect(yazi, findsOneWidget);
              final rich = t.widget<RichText>(yazi);
              // Text.rich varsayılan stili kök yapıyor; alıntının kendi kökü ilk çocuk.
              final kok = (rich.text as TextSpan).children!.single as TextSpan;

              // Punto ve satır sınırı (etkin ölçek en çok ×1,15).
              final boy = yzCekmeBoyu(telefon: telefon, olcek: olcek);
              expect(boy, (telefon ? 23.0 : 28.0) * (olcek > 1.15 ? 1.15 : olcek));
              expect(kok.style!.fontSize, boy);
              expect(kok.style!.height, 1.3);
              final satir = (t.getSize(yazi).height / (boy * 1.3)).round();
              expect(satir, lessThanOrEqualTo(telefon ? 5 : 3),
                  reason: '${c.cumle(en)}: $satir satır');

              // Masaüstünde en çok 560 px, metin sütununun içinde.
              final dikdortgen = t.getRect(yazi);
              expect(dikdortgen.width, lessThanOrEqualTo(kYzCekmeGenisligi + 0.1));
              final sutun = t.getRect(find.byType(YzMetinGorunumu));
              expect(dikdortgen.left, greaterThanOrEqualTo(sutun.left));
              expect(dikdortgen.right, lessThanOrEqualTo(sutun.right));

              // Üstte kısa yatay çizgi; kutu, zemin, kenarlık, sol dikey çizgi yok.
              final cizgi = find.descendant(of: kutu, matching: find.byType(ColoredBox));
              expect(cizgi, findsOneWidget);
              final cs = t.getSize(cizgi);
              expect(cs.width, inInclusiveRange(40, 48));
              expect(cs.height, lessThanOrEqualTo(3));
              expect(t.getRect(cizgi).bottom, lessThan(dikdortgen.top), reason: 'çizgi üstte');
              expect(find.descendant(of: kutu, matching: find.byType(DecoratedBox)), findsNothing);
              expect(find.descendant(of: kutu, matching: find.byType(Container)).evaluate().where((e) {
                final w = e.widget as Container;
                return w.decoration != null;
              }), isEmpty);

              // Tırnak, atıf, etiket yok: görünen metin cümlenin kendisi.
              final gorunen = rich.text.toPlainText();
              expect(gorunen.replaceAll('\u00A0', ' '), c.cumle(en).replaceAll('*', ''));

              // Rakam metindeki gibi mavi ve kaynağı açıyor.
              final rakamlar = <TextSpan>[];
              rich.text.visitChildren((s) {
                if (s is TextSpan && s.style?.color == YzRenk.makine) rakamlar.add(s);
                return true;
              });
              expect(rakamlar, isNotEmpty);
              expect(rakamlar.every((s) => s.recognizer is TapGestureRecognizer), isTrue,
                  reason: 'kaynaklı rakam dokununca kaynağı açmalı');
              // Sözlük ve kısaltmanın noktalı işareti alıntıda yok.
              var noktali = false;
              rich.text.visitChildren((s) {
                if (s is TextSpan && s.style?.decorationStyle == TextDecorationStyle.dotted) noktali = true;
                return true;
              });
              expect(noktali, isFalse);

              // Ekran okuyucu ve sayfa seçimi görmüyor.
              expect(find.ancestor(of: yazi, matching: find.byType(ExcludeSemantics)), findsWidgets);
              expect(find.ancestor(of: yazi, matching: find.byType(SelectionContainer)), findsWidgets);
              semantik.dispose();

              // Üst ve alt boşluk 48 px (önceki paragrafın 22 px'i dahil).
              final pay = find.descendant(of: kutu, matching: find.byType(Padding)).first;
              final p = t.widget<Padding>(pay).padding as EdgeInsets;
              expect(p.top + 22, kYzCekmeBoslugu);
              expect(p.bottom, kYzCekmeBoslugu);
            });
          }
        }
      }
    }
  });

  for (final en in [false, true]) {
    testWidgets('ekran okuyucu cümleyi bir kez okuyor (paragrafta), alıntıda değil · ${en ? 'en' : 'tr'}',
        (t) async {
      final c = kYzCekmeler.values.first;
      final semantik = t.ensureSemantics();
      t.view.physicalSize = const Size(1280, 2400);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      // Hepsi ekranda: kaydırılabilir alanın dışındaki düğümler ağaca girmiyor.
      await t.pumpWidget(_uygulama(
          YzMetinGorunumu(
              metin: '# 26 · B\n\nGiriş.\n\nÖnce. ${c.cumle(en)} Sonra.\n\n[[cekme:${c.kimlik}]]\n\nSon.\n',
              en: en,
              kaynakSayfasi: c.sayfa),
          dil: en ? 'en' : 'tr'));
      await t.pumpAndSettle();
      expect(find.byKey(ValueKey('yz-cekme-${c.kimlik}')), findsOneWidget);
      // Dokunulabilir rakam anlamsal ağaçta ayrı düğüm: rakamdan önceki kesit aranıyor.
      final duz = c.cumle(en).split('**').first.trim();
      expect(duz.length, greaterThan(10));
      var gecen = 0;
      void gez(SemanticsNode n) {
        final s = '${n.label} ${n.value}'.replaceAll('\u00A0', ' ');
        if (s.contains(duz)) gecen++;
        n.visitChildren((x) {
          gez(x);
          return true;
        });
      }

      var kok = t.getSemantics(find.byType(YzMetinGorunumu));
      while (kok.parent != null) {
        kok = kok.parent!;
      }
      gez(kok);
      expect(gecen, 1, reason: 'paragraf bir kez okunmalı, alıntı hiç');
      semantik.dispose();
    });
  }

  testWidgets('cümle sayfa metninde yoksa hiçbir şey çizilmiyor', (t) async {
    final c = kYzCekmeler.values.first;
    await t.pumpWidget(_uygulama(YzMetinGorunumu(
        metin: '# 26 · B\n\nBaşka bir giriş.\n\n[[cekme:${c.kimlik}]]\n\nBaşka bir paragraf.\n', en: false)));
    await t.pumpAndSettle();
    expect(find.byKey(ValueKey('yz-cekme-${c.kimlik}')), findsNothing);
    expect(find.textContaining('[[', findRichText: true), findsNothing);
    // Kaydı olmayan kimlik.
    await t.pumpWidget(_uygulama(
        const YzMetinGorunumu(metin: '# 26 · B\n\nBir.\n\n[[cekme:kayitsiz]]\n\nİki.\n', en: false)));
    await t.pumpAndSettle();
    expect(find.byType(RichText).evaluate().where((e) => (e.widget as RichText).text.toPlainText().contains('[[')),
        isEmpty);
    expect(t.takeException(), isNull);
  });

  test('öne çıkan cümle erteli pakette: ilk yüke girmiyor', () {
    final ilk = ilkYukKapanisi('lib/main.dart');
    expect(ilk, isNot(contains('lib/features/yapay_zeka/presentation/yz_cekme.dart')));
    expect(ilk, isNot(contains('lib/features/yapay_zeka/data/yz_cekmeler.g.dart')));
    final erteli = ilkYukKapanisi('lib/features/yapay_zeka/presentation/yz_ekranlar.dart');
    expect(erteli, contains('lib/features/yapay_zeka/presentation/yz_cekme.dart'));
  });
}
