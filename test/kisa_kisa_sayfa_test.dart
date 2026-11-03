import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/features/home/data/models/news_article.dart';
import 'package:tarim_app/features/home/presentation/screens/kisa_kisa_screen.dart';
import 'package:tarim_app/features/home/providers/home_providers.dart';

// "Günün tezgâhı" düzeni — masaüstü ve mobil AYRI sınanıyor.
//
// Taşma ölçüsü projenin kuralı (§5): 360 / 768 / 1200 px × tr/en.
// `flutter_test`in varsayılan yazı tipi her glifi yazı boyu kadar kare
// çiziyor, yani metin gerçekte olduğundan geniş görünüyor — kötümser,
// dolayısıyla iyi bir taşma dedektörü.

const _konular = ['Bitkisel Üretim', 'Ekonomi', 'Hayvancılık', 'Genel'];

NewsArticle _k(int i, {int gunOnce = 0}) => NewsArticle(
      id: 'k$i',
      title: 'Kısa haber başlığı numara $i burada duruyor',
      content: 'x',
      createdAt: DateTime(2026, 11, 3, 9, 0)
          .subtract(Duration(days: gunOnce, minutes: i * 17)),
      status: 'published',
      articleFormat: 'kisa',
      topic: _konular[i % _konular.length],
      sourceName: 'Kaynak $i',
      imageUrl: 'https://x/i$i.jpg',
    );

Widget _sayfa(List<NewsArticle> haberler) => ProviderScope(
      overrides: [
        latestArticlesProvider.overrideWith((ref) => Stream.value(haberler)),
      ],
      child: const MaterialApp(home: KisaKisaScreen()),
    );

Future<void> _ciz(WidgetTester tester, List<NewsArticle> h, Size ekran) async {
  tester.view.physicalSize = ekran;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_sayfa(h));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  // İki gün × sekiz haber: ritmin her üç vuruşu da (açılış, ikili, telgraf)
  // en az bir kez kuruluyor.
  final veri = [
    for (var g = 0; g < 2; g++) for (var i = 0; i < 8; i++) _k(g * 8 + i, gunOnce: g),
  ];

  for (final ekran in const [
    (ad: 'telefon 360', boyut: Size(360, 3000)),
    (ad: 'tablet 768', boyut: Size(768, 3000)),
    (ad: 'masaüstü 1200', boyut: Size(1200, 3000)),
    (ad: 'geniş 1920', boyut: Size(1920, 3000)),
  ]) {
    testWidgets('${ekran.ad} — taşmadan çiziliyor', (tester) async {
      await _ciz(tester, veri, ekran.boyut);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('içerik 1920 px ekranda 1200 oluğu içinde kalıyor', (tester) async {
    // Sınır olmasaydı telgraf satırı baştan başa uzar, göz satır sonundan
    // satır başına dönerken yerini kaybederdi. Ölçü, içeriğin SOL KENARI:
    // 1920'de oluk (1920-1200)/2 = 360 px'ten başlamalı.
    await _ciz(tester, veri, const Size(1920, 3000));
    final ilkBaslik = find.textContaining('Kısa haber başlığı').first;
    final sol = tester.getTopLeft(ilkBaslik).dx;
    final sag = tester.getBottomRight(ilkBaslik).dx;
    expect(sol, greaterThan(340), reason: 'sol oluk açılmalı');
    expect(sag, lessThan(1580), reason: 'sağ oluk açılmalı');
  });

  testWidgets('konu süzgeci listeyi daraltıyor', (tester) async {
    await _ciz(tester, veri, const Size(1200, 3000));
    final once = find.textContaining('Kısa haber başlığı').evaluate().length;
    await tester.tap(find.text('Ekonomi').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final sonra = find.textContaining('Kısa haber başlığı').evaluate().length;
    expect(sonra, lessThan(once));
    expect(tester.takeException(), isNull);
  });

  testWidgets('gün başlığı Türkçe büyük harfi doğru yazıyor', (tester) async {
    // Ham `toUpperCase()` "Cumartesi"yi "CUMARTESI", "Nisan"ı "NISAN"
    // yapıyordu (§39.5). Eski sürümde tam bu hata vardı.
    await _ciz(tester, veri, const Size(1200, 3000));
    expect(find.textContaining('CUMARTESI'), findsNothing);
    expect(find.textContaining('NISAN'), findsNothing);
  });
}
