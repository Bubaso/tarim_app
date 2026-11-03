import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/features/home/data/models/news_article.dart';
import 'package:tarim_app/features/home/presentation/widgets/kisa_kisa_section.dart';
import 'package:tarim_app/features/home/providers/home_providers.dart';

// "Kısa Kısa" MASAÜSTÜNDE iki sütun (kullanıcı kararı, 3 Kasım 2026).
//
// Tek sütunda 1200 px'lik oluğun sağ yarısı boş kalıyordu. İki sütun aynı
// dikey yeri kullanıp iki katı haber gösteriyor; blok BÜYÜMÜYOR, yani
// "ana sayfanın omurgası gibi görünmesin" gerekçesi korunuyor.
//
// Dar ekranda düzen DEĞİŞMİYOR: tablette iki sütun satır başına ~460 px
// bırakıyor ve manşetler üç satıra sarıyor.

NewsArticle _kisa(int i) => NewsArticle(
      id: 'k$i',
      title: 'Kısa haber $i',
      content: 'x',
      createdAt: DateTime(2026, 11, 3).subtract(Duration(hours: i)),
      status: 'published',
      articleFormat: 'kisa',
      sourceName: 'Kaynak',
    );

Widget _sarmala(List<NewsArticle> haberler, Size ekran) {
  return ProviderScope(
    overrides: [
      latestArticlesProvider.overrideWith((ref) => Stream.value(haberler)),
    ],
    child: MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: ekran),
        child: Scaffold(
          body: SingleChildScrollView(
            child: KisaKisaSection(isDark: false, spacing: 0),
          ),
        ),
      ),
    ),
  );
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  final onIki = List.generate(14, _kisa);

  testWidgets('masaüstünde 12 satır, iki sütun', (tester) async {
    tester.view.physicalSize = const Size(1440, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_sarmala(onIki, const Size(1440, 2400)));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Kısa haber'), findsNWidgets(12));
    // İki sütun = iki Expanded'lı bir Row.
    final satir = find.ancestor(
      of: find.textContaining('Kısa haber').first,
      matching: find.byType(Row),
    );
    expect(satir, findsWidgets);
    expect(find.byType(Expanded), findsWidgets);
  });

  testWidgets('telefonda 6 satır, tek sütun', (tester) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_sarmala(onIki, const Size(390, 2400)));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Kısa haber'), findsNWidgets(6));
  });

  testWidgets('tek sayıda haberde fazlası SOLA gidiyor', (tester) async {
    // Göz soldan okumaya başlıyor; eksik satır sağ sütunun altında daha az
    // göze batıyor.
    tester.view.physicalSize = const Size(1440, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_sarmala(List.generate(7, _kisa), const Size(1440, 2400)));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Kısa haber'), findsNWidgets(7));
    final sol = tester.getTopLeft(find.text('Kısa haber 0')).dx;
    final sag = tester.getTopLeft(find.text('Kısa haber 4')).dx;
    expect(sag, greaterThan(sol), reason: '5. haber sağ sütunda başlamalı');
  });
}
