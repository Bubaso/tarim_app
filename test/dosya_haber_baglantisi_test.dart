import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarim_app/features/dossiers/data/models/dosya_haberi.dart';
import 'package:tarim_app/features/dossiers/data/models/dossier_theme.dart';
import 'package:tarim_app/features/dossiers/presentation/widgets/dosya_haberleri_bolumu.dart';
import 'package:tarim_app/features/dossiers/presentation/widgets/haber_dosya_seridi.dart';
import 'package:tarim_app/features/dossiers/providers/dossier_providers.dart';

import 'support/dossier_fixture.dart';

/// Dosya ↔ haber bağlantısının iki ucu.
///
/// Taşma testleri 360 / 768 / 1200 px × tr/en olarak yazılıyor (CLAUDE.md §5):
/// `flutter_test` varsayılan yazı tipi her glifi yazı boyu kadar kare çizer,
/// yani metin gerçekte olduğundan geniş görünür. Kötümser, dolayısıyla iyi bir
/// taşma dedektörü.
void main() {
  final tema = DossierFixture.hollanda().summary.theme;

  DosyaHaberi haber(String baslik, {String? gorsel, int puan = 3}) =>
      DosyaHaberi(
        id: 'a1',
        slug: 'bir-haber',
        titleTr: baslik,
        titleEn: 'An English headline that is deliberately on the long side',
        summaryTr: 'Özet',
        imageUrl: gorsel,
        yayinTarihi: DateTime(2026, 8, 26),
        kaynak: 'GıdaTarım',
        puan: puan,
      );

  const dosya = HaberinDosyasi(
    slug: 'tmo',
    nameTr: 'Toprak Mahsulleri Ofisi',
    nameEn: 'Turkish Grain Board',
    tur: 'kurum',
    edition: 1,
    thesisTr:
        'Buğdaydan afyona: Türkiye\'nin tahıl piyasasını seksen sekiz yıldır '
        'dengeleyen kurum.',
    thesisEn:
        'From wheat to opium: the institution that has balanced Türkiye\'s '
        'grain market for eighty-eight years.',
    puan: 3,
  );

  Widget iskelet({required Widget child, required double genislik}) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr'), Locale('en')],
      home: Scaffold(
        body: SizedBox(width: genislik, child: SingleChildScrollView(child: child)),
      ),
    );
  }

  // ── Dosya sayfasındaki haber bölümü ──────────────────────────────────────

  testWidgets('eşleşen haber yoksa bölüm HİÇ çizilmiyor', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        dosyaHaberleriProvider('tmo').overrideWith((ref) async => []),
      ],
      child: iskelet(
        genislik: 800,
        child: DosyaHaberleriBolumu(slug: 'tmo', tema: tema, isEn: false),
      ),
    ));
    await tester.pumpAndSettle();

    // Başlık da, açıklama da yok: boş bir bölüm başlığı göstermektense hiç
    // göstermemek doğru.
    expect(find.text('BU KONUDAKİ HABERLER'), findsNothing);
    expect(find.byType(SizedBox), findsWidgets);
  });

  testWidgets('yükleme sırasında yer AYIRMIYOR', (tester) async {
    // Bölümün var olup olmayacağı henüz bilinmiyor; iskelet göstermek
    // sayfayı sonradan zıplatırdı.
    await tester.pumpWidget(ProviderScope(
      overrides: [
        dosyaHaberleriProvider('tmo')
            .overrideWith((ref) => Completer<List<DosyaHaberi>>().future),
      ],
      child: iskelet(
        genislik: 800,
        child: DosyaHaberleriBolumu(slug: 'tmo', tema: tema, isEn: false),
      ),
    ));
    await tester.pump();

    expect(find.text('BU KONUDAKİ HABERLER'), findsNothing);
  });

  for (final genislik in [360.0, 768.0, 1200.0]) {
    for (final isEn in [false, true]) {
      testWidgets(
          'haber bölümü ${genislik.toInt()}px ${isEn ? 'en' : 'tr'} taşmadan çiziliyor',
          (tester) async {
        tester.view.physicalSize = Size(genislik, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(ProviderScope(
          overrides: [
            dosyaHaberleriProvider('tmo').overrideWith((ref) async => [
                  haber('TMO Giresun\'da Sezonun İlk Fındık Alımını Yaptı'),
                  haber('TMO Hububat ve Haşhaş Alım Ödemelerini Aktardı'),
                  haber(
                      'Çiftçi-Sen Kuru Üzüm İçin 151 Lira Taban Fiyat İstedi',
                      puan: 2),
                ]),
          ],
          child: iskelet(
            genislik: genislik,
            child: DosyaHaberleriBolumu(slug: 'tmo', tema: tema, isEn: isEn),
          ),
        ));
        await tester.pumpAndSettle();

        expect(
          find.text(isEn ? 'IN THE NEWS' : 'BU KONUDAKİ HABERLER'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  // ── Haber sayfasındaki dosya şeridi ──────────────────────────────────────

  testWidgets('eşleşen dosya yoksa şerit HİÇ çizilmiyor', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        haberDosyalariProvider('a1').overrideWith((ref) async => []),
      ],
      child: iskelet(
        genislik: 800,
        child: const HaberDosyaSeridi(articleId: 'a1', isEn: false),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('dosyamız var'), findsNothing);
  });

  testWidgets('birden fazla dosya eşleşse de TEK şerit çiziliyor',
      (tester) async {
    // İki şerit üst üste haberin kendi akışını böler; en alakalısı gösteriliyor.
    await tester.pumpWidget(ProviderScope(
      overrides: [
        haberDosyalariProvider('a1').overrideWith((ref) async => [
              dosya,
              const HaberinDosyasi(
                slug: 'hollanda',
                nameTr: 'Hollanda',
                tur: 'ulke',
                edition: 1,
                thesisTr: 'İkinci dosya.',
                puan: 2,
              ),
            ]),
      ],
      child: iskelet(
        genislik: 800,
        child: const HaberDosyaSeridi(articleId: 'a1', isEn: false),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Toprak Mahsulleri Ofisi hakkında bir dosyamız var.'),
        findsOneWidget);
    expect(find.text('Hollanda hakkında bir dosyamız var.'), findsNothing);
  });

  testWidgets('şerit türe göre doğru adrese gidiyor', (tester) async {
    // Kurum dosyası /kurum/<slug>, ülke dosyası /ulke/<slug>. Adres ASCII
    // (CLAUDE.md §2.1) ve türden türetiliyor, koda gömülmüyor.
    expect(dosya.yol, '/kurum/tmo');
    expect(
      const HaberinDosyasi(
        slug: 'hollanda',
        nameTr: 'Hollanda',
        tur: 'ulke',
        edition: 1,
        thesisTr: '',
      ).yol,
      '/ulke/hollanda',
    );
  });

  testWidgets('seri etiketi diziyi ve sayıyı iki dilde veriyor', (tester) async {
    expect(dosya.seriEtiketi(false), 'KURUM DOSYASI · 01');
    expect(dosya.seriEtiketi(true), 'INSTITUTION DOSSIER · 01');
  });

  for (final genislik in [360.0, 768.0, 1200.0]) {
    for (final isEn in [false, true]) {
      testWidgets(
          'dosya şeridi ${genislik.toInt()}px ${isEn ? 'en' : 'tr'} taşmadan çiziliyor',
          (tester) async {
        tester.view.physicalSize = Size(genislik, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(ProviderScope(
          overrides: [
            haberDosyalariProvider('a1').overrideWith((ref) async => [dosya]),
          ],
          child: iskelet(
            genislik: genislik,
            child: HaberDosyaSeridi(articleId: 'a1', isEn: isEn),
          ),
        ));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }
  }
}
