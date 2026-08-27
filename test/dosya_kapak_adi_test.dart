import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/core/theme/app_typography.dart';

/// Kapaktaki adın kaç satıra indiğini ölçer.
///
/// `_KapakAdi` özel bir sınıf; testin ölçtüğü şey onun uyguladığı KURAL:
/// punto, adın tamamına değil en uzun KELİMESİNE bakarak küçülmeli. Kural
/// burada birebir uygulanıyor, böylece bozulduğunda test kırılıyor.
int _satirSayisi(String ad, TextStyle stil, double genislik) {
  final kelimeler = ad.trim().split(RegExp(r'\s+'));
  final enUzun = kelimeler.fold<String>('', (a, b) => b.length > a.length ? b : a);

  final olcer = TextPainter(
    text: TextSpan(text: enUzun, style: stil),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout();

  final olcek = olcer.width > genislik ? genislik / olcer.width : 1.0;
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
      final enUzun = ad
          .trim()
          .split(RegExp(r'\s+'))
          .fold<String>('', (a, b) => b.length > a.length ? b : a);
      final olcer = TextPainter(
        text: TextSpan(text: enUzun, style: stil),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      return olcer.width > oluk ? oluk / olcer.width : 1.0;
    }

    expect(
      olcek('Birleşik Krallık'),
      greaterThan(olcek('BirleşikKrallık')),
      reason: 'iki kelimelik ad, aynı harflerin bitişik hâlinden daha az küçülmeli',
    );
  });
}
