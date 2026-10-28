import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/features/dossiers/data/models/dossier_chart.dart';
import 'package:tarim_app/features/dossiers/data/models/dossier_theme.dart';
import 'package:tarim_app/features/dossiers/presentation/widgets/dossier_chart_view.dart';

/// `islem_akisi` ve `ticaret_akisi` — iki akış türü.
///
/// **Neden burada elle yazılmış tarif var.** Öteki grafik testleri koşumu
/// gerçek seed SQL'inden okuyor (`test/support/dossier_fixture.dart`) ve bu
/// bilinçli bir karar: elle yazılmış örnek, seed'in şekli değişince sessizce
/// eskir. Ama bu iki türü ÜRETEN bir dosya henüz yok — bağlanacak bir artefakt
/// olmadığı için kural burada askıda. İlk dosya bu türlerden birini
/// kullandığında bu testler koşuma taşınmalı ve buradaki tarifler silinmeli.
///
/// Sınanan şey türlerin kendi sözleşmesi: tarif doğru nesneye dönüyor mu, üç
/// genişlikte taşmadan çiziliyor mu, ve şartnamedeki kararlar (§8.5) kodda
/// gerçekten duruyor mu.
const _islemTarif = {
  'tur': 'islem_akisi',
  'baslik': {'tr': 'Tescil nasıl yapılıyor', 'en': 'How registration works'},
  'kaynak': 'Yönetmelik m. 12',
  'adimlar': [
    {
      'baslik': {'tr': 'Başvuru dilekçesi', 'en': 'Application letter'},
      'aktor': {'tr': 'üretici', 'en': 'the producer'},
      'sure': {'tr': 'aynı gün', 'en': 'same day'},
      'cikti': {'tr': 'Başvuru numarası', 'en': 'Application number'},
    },
    {
      'baslik': {'tr': 'İmza onayı', 'en': 'Signature attestation'},
      'aktor': {'tr': 'üretici', 'en': 'the producer'},
      // Süre BELGELENMEMİŞ: alan yok, tahmin yazılmıyor.
      'secenekler': [
        {'tr': 'noterde', 'en': 'at a notary'},
        {'tr': 'ihtiyar heyetinde', 'en': 'before the village council'},
      ],
    },
    {
      'baslik': {'tr': 'Kayda geçirme', 'en': 'Entry in the register'},
      'aktor': {'tr': 'il müdürlüğü', 'en': 'the provincial directorate'},
      'sure': {'tr': '15 gün', 'en': '15 days'},
      'cikti': {'tr': 'Tescil belgesi', 'en': 'Certificate of registration'},
    },
  ],
};

const _ticaretTarif = {
  'tur': 'ticaret_akisi',
  'baslik': {'tr': 'Dökme yağın yolu', 'en': 'The path of bulk oil'},
  'kaynak': 'UN Comtrade, 2024',
  'bolen': 1000000,
  'ondalik': 1,
  'onek': {'tr': '', 'en': r'$'},
  'sonek': {'tr': ' milyon \$', 'en': 'm'},
  'birim': {'tr': 'ABD doları', 'en': 'US dollars'},
  'giren_basligi': {'tr': 'Giren', 'en': 'Inbound'},
  'cikan_basligi': {'tr': 'Çıkan', 'en': 'Outbound'},
  'merkez': {
    'etiket': {'tr': 'İspanya', 'en': 'Spain'},
    'kendi': {
      'etiket': {'tr': 'İspanya\'nın kendi üretimi', 'en': 'Spain\'s own production'},
      'deger': 900000000,
      'rol': 'sessiz',
    },
  },
  'giren': [
    {
      'etiket': {'tr': 'Türkiye', 'en': 'Türkiye'},
      'deger': 420000000,
      'rol': 'ikincil',
    },
    {
      'etiket': {'tr': 'Tunus', 'en': 'Tunisia'},
      'deger': 180000000,
    },
    {
      // DEĞERİ BİLİNMEYEN KOL: listeden düşmeli, sıfır genişlikte çizilmemeli.
      'etiket': {'tr': 'Fas', 'en': 'Morocco'},
    },
  ],
  'cikan': [
    {
      'etiket': {'tr': 'Avrupa Birliği', 'en': 'European Union'},
      'deger': 1100000000,
      'rol': 'vurgu',
    },
    {
      'etiket': {'tr': 'Amerika Birleşik Devletleri', 'en': 'United States'},
      'deger': 260000000,
    },
  ],
};

Widget _sarmala(DossierChart c, {required bool isEn}) {
  const tema = DossierTheme.yedek;
  return MaterialApp(
    home: Scaffold(
      backgroundColor: tema.zemin,
      body: SingleChildScrollView(
        child: DossierChartView(chart: c, tema: tema, isEn: isEn),
      ),
    ),
  );
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  final islem = DossierChart.fromJson('tescil', _islemTarif) as IslemAkisiChart;
  final ticaret =
      DossierChart.fromJson('yag_akisi', _ticaretTarif) as TicaretAkisiChart;

  // ─── Model sözleşmesi ───────────────────────────────────────────────────

  test('belgelenmemiş süre BOŞ kalıyor, tahmin üretilmiyor', () {
    expect(islem.adimlar[1].sure, isNull);
    expect(islem.adimlar[0].sure, isNotNull);
  });

  test('seçenekler ayrı satırlarda duruyor, tek dizgeye birleşmiyor', () {
    expect(islem.adimlar[1].secenekler.length, 2);
    expect(islem.adimlar[0].secenekler, isEmpty);
  });

  test('değeri bilinmeyen kol listeden DÜŞÜYOR', () {
    // Sıfır genişlikte çizmek okura "hiç almadı" demek olurdu; oysa bilinmiyor.
    expect(ticaret.giren.length, 2);
    expect(ticaret.giren.map((k) => k.etiket.tr), isNot(contains('Fas')));
  });

  test('cetvel iki yakanın büyüğü, fark yorumsuz sayı', () {
    // Giren 420 + 180 + kendi 900 = 1.500; çıkan 1.100 + 260 = 1.360.
    expect(ticaret.girenToplam, 600000000);
    expect(ticaret.cikanToplam, 1360000000);
    expect(ticaret.cetvel, 1500000000);
    expect(ticaret.fark, 140000000);
  });

  test('tek yakası boş akış çizilmiyor', () {
    final tek = Map<String, dynamic>.from(_ticaretTarif)..['cikan'] = const [];
    expect(DossierChart.fromJson('x', tek), isNull);
  });

  test('merkezsiz tarif null döner', () {
    final merkezsiz = Map<String, dynamic>.from(_ticaretTarif)..remove('merkez');
    expect(DossierChart.fromJson('x', merkezsiz), isNull);
  });

  test('adımsız işlem akışı çizilmiyor', () {
    final bos = Map<String, dynamic>.from(_islemTarif)..['adimlar'] = const [];
    expect(DossierChart.fromJson('x', bos), isNull);
  });

  // ─── Çizim ──────────────────────────────────────────────────────────────

  for (final genislik in [360.0, 768.0, 1200.0]) {
    testWidgets('akış grafikleri ${genislik.toInt()}px\'te taşmadan çiziliyor',
        (tester) async {
      tester.view.physicalSize = Size(genislik, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      for (final c in [islem, ticaret]) {
        for (final isEn in [false, true]) {
          await tester.pumpWidget(_sarmala(c, isEn: isEn));
          expect(
            tester.takeException(),
            isNull,
            reason: '${c.id} (${isEn ? 'en' : 'tr'}) ${genislik.toInt()}px\'te patladı',
          );
        }
      }
    });
  }

  testWidgets('adım numarası yazılı — çizelgenin yılından biçimle ayrışıyor',
      (tester) async {
    tester.view.physicalSize = const Size(500, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_sarmala(islem, isEn: false));
    for (var i = 1; i <= islem.adimlar.length; i++) {
      expect(find.text('$i'), findsOneWidget, reason: '$i. adımın numarası yok');
    }
    // Çıktı belgesi ekranda duruyor: adımın sonunda eline ne geçtiği.
    expect(find.text('Tescil belgesi'), findsOneWidget);
  });

  testWidgets('her seçenek KENDİ satırında', (tester) async {
    tester.view.physicalSize = const Size(500, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_sarmala(islem, isEn: false));
    expect(find.text('noterde'), findsOneWidget);
    expect(find.text('ihtiyar heyetinde'), findsOneWidget);
    // Virgülle birleşmiş tek satır OLMAMALI: okur bunu seçim değil, art arda
    // iki iş sanardı.
    expect(find.textContaining('noterde,'), findsNothing);
  });

  testWidgets('her kolun rakamı METİN olarak da var', (tester) async {
    // Renk körlüğü şartı: ekrandaki tüm renk kaybolsa grafik yine okunur.
    tester.view.physicalSize = const Size(500, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_sarmala(ticaret, isEn: false));
    for (final k in [...ticaret.giren, ...ticaret.cikan, ticaret.merkez.kendi!]) {
      expect(
        find.text(ticaret.bicim.bicimle(k.deger, false)),
        findsWidgets,
        reason: '${k.etiket.tr} kolunun rakamı yazılı değil',
      );
    }
  });

  testWidgets('yaka başlığı yazılmazsa HİÇBİR metin gömülmüyor', (tester) async {
    // Dart'ta varsayılan "Giren"/"Çıkan" olsaydı İngilizcesi de gömülü olurdu
    // ve "etiketler veritabanından gelir" kuralı kırılırdı.
    tester.view.physicalSize = const Size(500, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final basliksiz = Map<String, dynamic>.from(_ticaretTarif)
      ..remove('giren_basligi')
      ..remove('cikan_basligi');
    final c = DossierChart.fromJson('x', basliksiz)!;
    await tester.pumpWidget(_sarmala(c, isEn: false));

    expect(find.text('GİREN'), findsNothing);
    expect(find.text('ÇIKAN'), findsNothing);
    expect(find.textContaining('Inbound'), findsNothing);
    // Başlıklı sürümde ikisi de var.
    await tester.pumpWidget(_sarmala(ticaret, isEn: false));
    expect(find.text('GİREN'), findsOneWidget);
    expect(find.text('ÇIKAN'), findsOneWidget);
  });

  testWidgets('İngilizce sürümde önek/sonek yer değiştiriyor', (tester) async {
    tester.view.physicalSize = const Size(500, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_sarmala(ticaret, isEn: true));
    expect(find.text(r'$420.0m'), findsOneWidget);
    expect(find.textContaining('milyon'), findsNothing);
  });

  testWidgets('kaynak künyesi iki türde de çiziliyor', (tester) async {
    tester.view.physicalSize = const Size(500, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    for (final c in [islem, ticaret]) {
      expect(c.kaynak, isNotNull, reason: '${c.id} kaynaksız');
      await tester.pumpWidget(_sarmala(c, isEn: false));
      expect(find.text(c.kaynak!), findsOneWidget, reason: '${c.id} künyesi çizilmedi');
    }
  });
}
