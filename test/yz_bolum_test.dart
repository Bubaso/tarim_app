import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/features/home/data/models/news_article.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_deposu.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_iskelet.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_metinler.g.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_baslik_ekrani.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_merkez_ekrani.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_metin_gorunumu.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_seridi.dart';
import 'package:tarim_app/features/yapay_zeka/yz_providers.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Yapay Zeka ve Dijital Tarım — okur tarafı
// ──────────────────────────────────────────────────────────────────────────
//  1. ÇİZİCİ metinlerin kullandığı Markdown kesitini doğru ayrıştırıyor:
//     `>` özet, `##` alt başlık, tablo (ayıraç satırı düşüyor), paragraf.
//     Tanımadığı şeyi yutmuyor, düz metin bırakıyor.
//  2. GÖMÜLÜ METİN depodaki .md ile AYNI: üretici unutulursa sayfa eski
//     metni gösterir ve hiçbir şey kırılmaz. Bu test kırılır.
//  3. Sayfalar telefonda ve masaüstünde TAŞMIYOR; haber akışı sahte veriyle.
//  4. "Şu an öne çıkan" takvime bağlı dönüyor ve yalnız yazılmış başlıktan.
// ══════════════════════════════════════════════════════════════════════════

final _haberler = [
  YzHaber(
    NewsArticle(
      id: 'h1',
      title: 'Orman yangınlarıyla mücadelede yapay zekâ ve İHA dönemi',
      content: '',
      createdAt: DateTime(2026, 11, 10),
      sourceName: 'Tarım Portalı',
    ),
    15,
  ),
  YzHaber(
    NewsArticle(
      id: 'h2',
      title: 'Akıllı sensörler zeytinde ilaçlama masrafını düşürdü',
      content: '',
      createdAt: DateTime(2026, 11, 16),
    ),
    20,
  ),
];

Widget _sarmala(Widget cocuk, {String dil = 'tr'}) => ProviderScope(
      overrides: [
        yzBolumHaberleriProvider.overrideWith((ref, no) async =>
            no == null ? _haberler : _haberler.where((h) => h.baslikNo == no).toList()),
      ],
      // Bölüm metni dile göre seçiliyor; varsayılan test dili İngilizce.
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

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  group('çizici', () {
    test('özet, alt başlık, tablo, paragraf', () {
      final b = yzAyristir('''# 8 · Başlık

> **Özet.** Birinci satır
> ikinci satır.

## Ne yapıyor

İlk paragraf
devam ediyor.

| A | B |
|---|---|
| 1 | **%35** |

- liste satırı düz metin kalır
''');
      expect(b.map((x) => x.tur).toList(), [
        YzBlokTuru.ozet,
        YzBlokTuru.altBaslik,
        YzBlokTuru.paragraf,
        YzBlokTuru.tablo,
        YzBlokTuru.paragraf,
      ]);
      expect(b[0].metin, '**Özet.** Birinci satır ikinci satır.');
      expect(b[1].metin, 'Ne yapıyor');
      expect(b[2].metin, 'İlk paragraf devam ediyor.');
      expect(b[3].satirlar, [
        ['A', 'B'],
        ['1', '**%35**'],
      ], reason: 'ayıraç satırı tabloya girmemeli');
      expect(b[4].metin, '- liste satırı düz metin kalır');
    });

    test('bütün gömülü metinler bloklara ayrılıyor ve başlık satırı düşüyor', () {
      for (final m in kYzMetinler.values) {
        for (final metin in [m.tr, m.en]) {
          final b = yzAyristir(metin);
          expect(b.first.tur, YzBlokTuru.ozet, reason: '§${m.no}: özet bloğu ilk sırada değil');
          expect(b.where((x) => x.tur == YzBlokTuru.altBaslik), isNotEmpty);
          expect(b.any((x) => x.metin.startsWith('# ')), isFalse);
        }
      }
    });
  });

  test('gömülü metin depodaki .md ile aynı (üretici koşmuş)', () {
    final klasor = Directory('content/yapay_zeka_dijital_tarim/bolumler');
    for (final b in kYzBasliklar.where((b) => b.yazildi)) {
      final on = '${b.no.toString().padLeft(2, '0')}-${b.slug}';
      final tr = File('${klasor.path}/$on.tr.md').readAsStringSync();
      final en = File('${klasor.path}/$on.en.md').readAsStringSync();
      expect(kYzMetinler[b.no]?.tr, tr, reason: '§${b.no} TR eski — dart_uret.py koşturulmalı');
      expect(kYzMetinler[b.no]?.en, en, reason: '§${b.no} EN eski — dart_uret.py koşturulmalı');
    }
    expect(kYzMetinler.length, kYzBasliklar.where((b) => b.yazildi).length);
  });

  test('öne çıkan başlık takvime bağlı dönüyor, yalnız yazılmıştan', () {
    final yazilan = kYzBasliklar.where((b) => b.yazildi).map((b) => b.no).toSet();
    final gorulen = <int>{};
    for (var g = 0; g < 10; g++) {
      final b = yzOneCikan(DateTime(2026, 11, 1).add(Duration(days: g)));
      expect(b, isNotNull);
      expect(yazilan.contains(b!.no), isTrue);
      gorulen.add(b.no);
    }
    expect(gorulen, yazilan, reason: 'on günde bütün yazılmış başlıklar dönmeli');
    expect(yzOneCikan(DateTime(2026, 11, 5))!.no, yzOneCikan(DateTime(2026, 11, 5, 23))!.no,
        reason: 'aynı gün aynı başlık');
  });

  for (final olcu in const [Size(360, 800), Size(1280, 900)]) {
    final ad = '${olcu.width.toInt()} piksel';

    testWidgets('merkez sayfa · $ad · taşmıyor', (t) async {
      t.view.physicalSize = olcu;
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(_sarmala(const YzMerkezEkrani()));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.text(kYzAdTr), findsOneWidget);
      expect(find.text('§23'), findsOneWidget, reason: 'harita karosu');
      expect(find.textContaining('Orman yangınlarıyla'), findsOneWidget, reason: 'haber akışı');
      // teknoloji süzgeci
      await t.tap(find.text('Dil modelleri'));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    });

    for (final slug in ['turkiyede-durum', 'goruntu-isleme-ve-hedefli-ilaclama',
                        'mevzuat-ve-politika', 'hayvancilik']) {
      testWidgets('başlık sayfası · $slug · $ad · taşmıyor', (t) async {
        t.view.physicalSize = olcu;
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        await t.pumpWidget(_sarmala(YzBaslikEkrani(slug: slug)));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        final b = kYzBasliklar.firstWhere((x) => x.slug == slug);
        expect(find.text(b.tr), findsOneWidget);
        if (b.yazildi) {
          expect(find.textContaining('Kaynaklarından son okunduğu gün'), findsOneWidget);
        } else {
          expect(find.text('Bu başlık yazılıyor.'), findsOneWidget);
          expect(find.text('BU BAŞLIK NEYİ ANLATACAK'), findsOneWidget);
        }
      });
    }

    testWidgets('ana sayfa şeridi · $ad · taşmıyor', (t) async {
      t.view.physicalSize = olcu;
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(_sarmala(const Scaffold(body: SingleChildScrollView(child: YzSeridi(okuraAcik: true)))));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.text(kYzAdTr), findsOneWidget);
      expect(find.textContaining('Şu an öne çıkan'), findsOneWidget);
    });
  }

  // İngilizce metinler daha uzun ("in progress", katman adları): dar
  // ekranda bir de İngilizce çizilsin.
  for (final sayfa in <String, Widget>{
    'merkez': const YzMerkezEkrani(),
    'başlık §23': const YzBaslikEkrani(slug: 'turkiyede-durum'),
    'başlık §12': const YzBaslikEkrani(slug: 'hayvancilik'),
    'şerit': const Scaffold(body: SingleChildScrollView(child: YzSeridi(okuraAcik: true))),
  }.entries) {
    testWidgets('İngilizce · ${sayfa.key} · 360 piksel · taşmıyor', (t) async {
      t.view.physicalSize = const Size(360, 800);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(_sarmala(sayfa.value, dil: 'en'));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    });
  }

  testWidgets('okura kapalıyken şerit HİÇ çizilmiyor (yayin.json)', (t) async {
    expect(kYzOkuraAcik, isFalse,
        reason: 'bölüm 30 başlığın tamamı yazılınca açılır — kullanıcı kararı');
    await t.pumpWidget(_sarmala(const Scaffold(body: SingleChildScrollView(child: YzSeridi()))));
    await t.pumpAndSettle();
    expect(find.text(kYzAdTr), findsNothing);
    expect(find.byType(SizedBox), findsWidgets);
  });

  testWidgets('bilinmeyen adres: bulunamadı, çökmüyor', (t) async {
    await t.pumpWidget(_sarmala(const YzBaslikEkrani(slug: 'yok-boyle-bir-sey')));
    await t.pumpAndSettle();
    expect(find.text('Böyle bir başlık yok.'), findsOneWidget);
  });
}
