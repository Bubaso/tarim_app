import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/features/home/providers/home_providers.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_deposu.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_iskelet.g.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_etiket_satiri.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_panel_ekrani.dart';
import 'package:tarim_app/features/yapay_zeka/yz_providers.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Yapay Zeka ve Dijital Tarım — panel
// ──────────────────────────────────────────────────────────────────────────
//  Panel yönetici girişi istiyor; tarayıcıda açıp bakmak test değil. Burada
//  ekranlar sahte veriyle çiziliyor ve üç vaat ölçülüyor:
//
//  1. Haber alan başlık kümesi iskeletle ve hatla AYNI (4-21, 24, 26, 27).
//     Hattın `BASLIKLAR` sözlüğü aynı kümeyi `iskeletle_tutarli_mi` ile
//     sınıyor; panelin seçicisi bu sabitten okuyor.
//  2. Veritabanı satırı doğru ayrıştırılıyor: gömülü `articles` ve
//     `gerekce` içindeki kanıt cümlesi kaybolmuyor.
//  3. Sekme dar ekranda taşmıyor; aylık tarama 30 günü geçince hatırlatıyor.
// ══════════════════════════════════════════════════════════════════════════

final _aktif = YzEtiket.fromJson({
  'article_id': 'a1',
  'durum': 'aktif',
  'baslik_no': 15,
  'kaynak': 'geriye_donuk',
  'gerekce': {
    'kanit': 'Orman yangınlarıyla mücadelede yapay zeka temelli Karar Destek '
        'Sistemi sayesinde riskli alanları 1 hafta önceden belirlediklerini '
        'belirten Bakan, yangınların azaldığını söyledi.',
    'kanit_dogrulandi': true,
    'karar': 'EVET',
    'anahtarlar': ['yapay zeka', 'karar destek'],
  },
  'updated_at': '2026-11-16T13:30:00Z',
  'articles': {
    'title': 'Bakan Yumaklı tarım ve gıdada yeni yol haritasını açıkladı',
    'status': 'published',
    'created_at': '2026-11-14T08:00:00Z',
    'topic': 'Genel',
    'source_name': 'AA',
  },
});

final _sinirda = YzEtiket.fromJson({
  'article_id': 'a2',
  'durum': 'sinirda',
  'baslik_no': null,
  'kaynak': 'ajan',
  'gerekce': {
    'kanit': null,
    'kanit_dogrulandi': false,
    'karar': 'HAYIR',
    'anahtarlar': ['dijital tarim'],
  },
  'updated_at': '2026-11-16T13:31:00Z',
  'articles': {
    'title': "Bakan Yumaklı COP31'de kadın çiftçilere finansman istedi "
        've dijital tarım olanaklarının üretime entegrasyonunu anlattı',
    'status': 'reviewing',
    'created_at': '2026-11-13T08:00:00Z',
    'topic': 'Ekonomi',
    'source_name': 'Tarım Portalı',
  },
});

final _oneriler = [
  YzGuncelleme.fromJson({
    'id': 'g1',
    'tur': 'yeni_kaynak',
    'baslik_no': 4,
    'kaynak': 'tarama:openalex',
    'icerik': {
      'baslik': 'Spatial Enhancement of Satellite Soil Moisture Using '
          'Machine Learning Approach',
      'tarih': '2026-11-14',
      'adres': 'https://doi.org/10.0000/ornek',
      'dergi': 'Remote Sensing',
      'nitelik': 'yayımlanmış makale — hakem durumu kaynağa göre değişir',
    },
    'durum': 'bekliyor',
    'created_at': '2026-11-16T13:26:00Z',
  }),
  YzGuncelleme.fromJson({
    'id': 'g2',
    'tur': 'sayfa_degisti',
    'baslik_no': 24,
    'kaynak': 'tarama:sayfa',
    'icerik': {
      'sayfa': 'Resmî Gazete · günlük dizin',
      'adres': '',
      'yeni_baglantilar': [
        'https://ornek/1 | Birinci yeni duyuru başlığı',
        'https://ornek/2 | İkinci yeni duyuru başlığı',
        'https://ornek/3 | Üçüncü yeni duyuru başlığı',
        'https://ornek/4 | Dördüncü yeni duyuru başlığı',
      ],
      'yeni_sayisi': 4,
    },
    'durum': 'bekliyor',
    'created_at': '2026-11-16T13:27:00Z',
  }),
];

Widget _sarmala(Widget cocuk, {Map<String, dynamic>? tarama}) =>
    ProviderScope(
      overrides: [
        yzEtiketListesiProvider.overrideWith((ref, durum) async =>
            durum == 'aktif' ? [_aktif] : (durum == 'sinirda' ? [_sinirda] : [])),
        yzKuyrukProvider.overrideWith((ref) async => _oneriler),
        yzSonTaramaProvider.overrideWith((ref) async => tarama),
        dinleyiciAcikProvider.overrideWith((ref) async => false),
      ],
      child: MaterialApp(home: Scaffold(body: cocuk)),
    );

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  test('haber alan başlıklar hatla ve iskeletle aynı küme', () {
    expect(kYzBasliklar.length, 30);
    expect(kYzHaberBasliklari.map((b) => b.no).toList(),
        [for (var i = 4; i <= 21; i++) i, 24, 26, 27]);
    expect(yzBaslik(15)?.tr, 'Ormancılık');
    expect(yzBaslik(99), isNull);
  });

  test('satır ayrıştırma: kanıt ve gömülü haber kaybolmuyor', () {
    expect(_aktif.aktif, isTrue);
    expect(_aktif.baslik?.no, 15);
    expect(_aktif.kanit, contains('Karar Destek'));
    expect(_aktif.kanitDogrulandi, isTrue);
    expect(_aktif.haberBasligi, contains('yol haritası'));
    expect(_aktif.anahtarlar, ['yapay zeka', 'karar destek']);
    expect(_sinirda.sinirda, isTrue);
    expect(_sinirda.baslikNo, isNull);
    expect(_oneriler[0].adres, 'https://doi.org/10.0000/ornek');
    expect(_oneriler[1].adres, isNull, reason: 'boş adres düğme çizdirmemeli');
    expect(_oneriler[1].baslikMetni, 'Resmî Gazete · günlük dizin');
  });

  for (final genislik in [375.0, 1200.0]) {
    testWidgets('panel sekmesi ${genislik.toInt()} piksel — taşmıyor, sayaçlar doğru',
        (tester) async {
      tester.view.physicalSize = Size(genislik, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_sarmala(const YzPanelEkrani(), tarama: {
        'bitti': DateTime.now()
            .subtract(const Duration(days: 34))
            .toUtc()
            .toIso8601String(),
        'ozet': {'oneri': 31},
      }));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      expect(find.text('Sınırda (1)'), findsOneWidget);
      expect(find.text('Bölümde (1)'), findsOneWidget);
      expect(find.text('Kuyruk (2)'), findsOneWidget);
      expect(find.textContaining('Aylık kapsamlı tarama zamanı geldi'),
          findsOneWidget);
      expect(find.textContaining('dinleyici kapalı'), findsOneWidget);

      // Bölümde sekmesi: başlık çipi ve kanıt cümlesi görünüyor
      await tester.tap(find.text('Bölümde (1)'));
      await tester.pumpAndSettle();
      expect(find.text('§15 Ormancılık'), findsOneWidget);
      expect(find.textContaining('Karar Destek'), findsOneWidget);
      expect(find.text('Bölümden kaldır'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Kuyruk: yeni bağlantıların ilk üçü + "… ve 1 bağlantı daha"
      await tester.tap(find.text('Kuyruk (2)'));
      await tester.pumpAndSettle();
      expect(find.text('Sayfada yeni bağlantı'), findsOneWidget);
      expect(find.textContaining('ve 1 bağlantı daha'), findsOneWidget);
      expect(find.text('Kaynağı aç'), findsOneWidget,
          reason: 'yalnız adresi olan öneri düğme çizer');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('tarama 30 günden yeniyse hatırlatma YOK', (tester) async {
    await tester.pumpWidget(_sarmala(const YzPanelEkrani(), tarama: {
      'bitti': DateTime.now()
          .subtract(const Duration(days: 3))
          .toUtc()
          .toIso8601String(),
      'ozet': {'oneri': 31},
    }));
    await tester.pumpAndSettle();
    expect(find.textContaining('zamanı geldi'), findsNothing);
    expect(find.textContaining('3 gün önce'), findsOneWidget);
  });

  testWidgets('onay kartı satırı: aktif ve sınırda, dar ekranda', (tester) async {
    tester.view.physicalSize = const Size(340, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_sarmala(Column(children: [
      YzEtiketSatiri(etiket: _aktif),
      YzEtiketSatiri(etiket: _sinirda),
    ])));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.textContaining('Bölümde · §15 Ormancılık'), findsOneWidget);
    expect(find.textContaining('Sınırda'), findsOneWidget);
    final anahtarlar = tester.widgetList<Switch>(find.byType(Switch)).toList();
    expect(anahtarlar.map((s) => s.value).toList(), [true, false]);
  });
}
