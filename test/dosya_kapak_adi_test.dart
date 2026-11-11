import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/core/theme/app_typography.dart';
import 'package:tarim_app/features/dossiers/presentation/screens/country_dossier_screen.dart'
    show kapakAdiOlcegi;

/// Kapaktaki adın kaç satıra indiğini ölçer.
///
/// `_KapakAdi` özel bir sınıf; testin ölçtüğü şey onun uyguladığı KURAL:
/// punto, adın tamamına değil EN GENİŞ KELİMESİNE bakarak küçülmeli.
///
/// Bu dosya 12 Kasım 2026'da düzeltildi: hem kural "en uzun kelime" (harf
/// sayısı) diye yazılmıştı hem de test onu birebir kopyalıyordu, yani test
/// hatanın bekçisi değil suç ortağıydı. Ölçek artık üretim kodundaki
/// `kapakAdiOlcegi` çağrılarak kuruluyor — kopya yok, kural tek yerde.
int _satirSayisi(String ad, TextStyle stil, double genislik) {
  final kelimeler = ad.trim().split(RegExp(r'\s+'));

  double olc(String k) => (TextPainter(
        text: TextSpan(text: k, style: stil),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout())
      .width;

  final olcek = kapakAdiOlcegi(kelimeler, genislik, olc);
  final punto = (stil.fontSize ?? 56) * olcek;
  final son = olcek >= 1.0
      ? stil
      : stil.copyWith(fontSize: punto, letterSpacing: punto * -0.022);

  final cizer = TextPainter(
    text: TextSpan(text: ad, style: son),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: genislik);

  return cizer.computeLineMetrics().length;
}

Future<TextStyle> _stil(WidgetTester tester, double ekranGenisligi) async {
  late TextStyle stil;
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: Size(ekranGenisligi, 900)),
      child: Builder(
        builder: (context) {
          stil = AppTypography.dossierCover(context, color: Colors.black);
          return const SizedBox();
        },
      ),
    ),
  );
  return stil;
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  // Okuma oluğu 720 px (CLAUDE.md §4). Masaüstünde 132 punto "Netherlands"
  // bunu birkaç piksel aşıyor ve son harf alt satıra düşüyordu.
  const oluk = 720.0;

  testWidgets('tek kelimelik ad tek satırda kalıyor', (tester) async {
    for (final ekran in [1280.0, 900.0, 420.0]) {
      final stil = await _stil(tester, ekran);
      for (final ad in ['Netherlands', 'Hollanda', 'Turkmenistan', 'Liechtenstein']) {
        expect(
          _satirSayisi(ad, stil, oluk),
          1,
          reason: '$ekran px ekranda "$ad" tek satıra sığmadı',
        );
      }
    }
  });

  testWidgets('ölçek adın tamamına değil en uzun kelimesine bakıyor', (tester) async {
    // Kural adın TAMAMINA uygulansaydı "Birleşik Krallık" tek satıra sığmak
    // için yarı yarıya küçülürdü; oysa bozan şey kelimenin ortadan bölünmesi,
    // kelimeler arasından sarması değil.
    //
    // İddia fonttan bağımsız kuruluyor: `flutter_test` varsayılan yazı tipi
    // her glifi punto kadar kare çiziyor ve o fontta "Birleşik" bile oluğu
    // aşıyor, dolayısıyla "punto 132 kalmalı" gibi bir ölçüm burada anlamsız.
    // Ölçülebilir olan ORAN: aynı harfler boşluklu yazıldığında, boşluksuz
    // yazıldığından daha az küçülmeli.
    final stil = await _stil(tester, 1280);

    double olcek(String ad) {
      double olc(String k) => (TextPainter(
            text: TextSpan(text: k, style: stil),
            textDirection: TextDirection.ltr,
            maxLines: 1,
          )..layout())
          .width;
      return kapakAdiOlcegi(ad.trim().split(RegExp(r'\s+')), oluk, olc);
    }

    expect(
      olcek('Birleşik Krallık'),
      greaterThan(olcek('BirleşikKrallık')),
      reason: 'iki kelimelik ad, aynı harflerin bitişik hâlinden daha az küçülmeli',
    );
  });

  // ── TİGEM kapağı: harf sayısı genişliğin vekili DEĞİL ──────────────────
  //
  // 12 Kasım 2026'da canlıda görüldü:
  //
  //     ... Genel
  //     Müdürlüğ
  //     ü
  //
  // "İşletmeleri" 11 harf, "Müdürlüğü" 9 — ama kapak yazı tipinde
  // "Müdürlüğü" daha GENİŞ çiziliyor. Eski kural ölçeği dar kelimeye göre
  // kurunca geniş olanı oluğu aşıyor ve Flutter onu ortasından bölüyor.
  //
  // `flutter_test`in varsayılan yazı tipinde her glif punto kadar kare, yani
  // genişlik harf sayısına EŞİT ve hata orada üretilemez. Bu yüzden ölçer
  // sahte: gerçek fontun davranışı birebir taklit ediliyor.
  test('ölçek en UZUN kelimeye değil en GENİŞ kelimeye bakıyor', () {
    const ad = 'TİGEM — Tarım İşletmeleri Genel Müdürlüğü';
    final kelimeler = ad.split(RegExp(r'\s+'));

    // Gerçek kapak fontunun ölçümü: geniş gövdeli harfler daha çok yer
    // kaplıyor, dolayısıyla kısa ama "şişman" kelime öne geçiyor.
    const genislikler = {
      'TİGEM': 360.0,
      '—': 70.0,
      'Tarım': 300.0,
      'İşletmeleri': 690.0,
      'Genel': 330.0,
      'Müdürlüğü': 760.0, // 9 harf ama EN GENİŞ olan
    };
    double olc(String k) => genislikler[k]!;

    const oluk = 720.0;
    final olcek = kapakAdiOlcegi(kelimeler, oluk, olc);

    // Her kelime ölçekten sonra oluğa SIĞMALI — kırılan tam buydu.
    for (final k in kelimeler) {
      expect(olc(k) * olcek, lessThanOrEqualTo(oluk + 0.01),
          reason: '"$k" ölçekten sonra oluğa sığmıyor, ortadan bölünür');
    }

    // Ve ölçek gereksiz yere küçültmemeli: en geniş kelime tam oturmalı.
    expect(olcek, closeTo(oluk / 760.0, 0.0001));
  });

  test('her kelime sığıyorsa punto hiç küçülmüyor', () {
    final olcek = kapakAdiOlcegi(['DSİ', 'Devlet', 'Su', 'İşleri'], 720.0,
        (k) => k.length * 40.0);
    expect(olcek, 1.0);
  });

  test('boş kelime ölçeği bozmuyor', () {
    // ad.trim().split(RegExp(r'\s+')) normalde boş üretmez ama ad tek bir
    // boşluksa üretir; sıfıra bölme olmamalı.
    expect(kapakAdiOlcegi(const [''], 720.0, (k) => 0.0), 1.0);
    expect(kapakAdiOlcegi(const [], 720.0, (k) => 0.0), 1.0);
  });
}
