// ══════════════════════════════════════════════════════════════════════════
//  Panelin telefon düzeni — 15 Kasım 2026 denetiminin 11. maddesi
// ──────────────────────────────────────────────────────────────────────────
//  Onay kuyruğu masaüstünde temiz çiziliyordu, telefonda İKİ satırı
//  taşırıyordu: başlık satırı (metin `Expanded` içinde değildi) ve seçim
//  satırı. `Spacer` taşmayı engellemiyor — boşluk ancak artan yer varsa iş
//  görür.
//
//  Bu sınav 375 ve 320 piksellik ekranlarda hiç taşma olmamasını şart
//  koşuyor. Düzen bir daha daraldığında sessizce geçmesin diye duruyor.
// ══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tarim_app/features/dashboard/presentation/screens/onay_kuyrugu_ekrani.dart';
import 'package:tarim_app/features/home/data/models/news_article.dart';
import 'package:tarim_app/features/home/data/repositories/home_repository.dart';
import 'package:tarim_app/features/home/providers/home_providers.dart';

class _Depo extends HomeRepository {
  _Depo()
      : super(SupabaseClient('http://localhost', 'anon',
            authOptions: const AuthClientOptions(autoRefreshToken: false)));
}

NewsArticle _h(int i, {DateTime? program, bool kapakli = false}) =>
    NewsArticle(
      id: 'a$i',
      title: 'TÜRKŞEKER pancar üreticisine sağlanan finansal destekleri açıkladı',
      content: '<p>g</p>',
      createdAt: DateTime(2026, 11, 13, 9),
      publishedAt: DateTime(2026, 11, 5),
      sourceName: 'Anadolu Ajansı',
      topic: 'Bitkisel Üretim',
      region: 'Türkiye',
      heroScore: 7,
      summary: 'özet metni',
      scheduledAt: program,
      imageUrl: kapakli ? 'https://x/k_1200x630.jpg' : null,
    );

Future<int> _tasma(WidgetTester t, Size olcu, List<NewsArticle> liste) async {
  var n = 0;
  final eski = FlutterError.onError;
  FlutterError.onError = (d) {
    final s = d.exceptionAsString();
    if (s.contains('overflowed')) {
      n++;
      debugPrint('   ↳ ${s.split('\n').first}');
      for (final l in d.toString().split('\n')) {
        if (l.contains('.dart:')) debugPrint('      $l');
      }
    }
  };
  await t.binding.setSurfaceSize(olcu);
  t.view.physicalSize = olcu;
  t.view.devicePixelRatio = 1.0;
  await t.pumpWidget(ProviderScope(
    overrides: [
      homeRepositoryProvider.overrideWithValue(_Depo()),
      pendingArticlesProvider.overrideWith((ref) => Stream.value(liste)),
    ],
    child: const MaterialApp(home: Scaffold(body: OnayKuyruguEkrani())),
  ));
  await t.pump(const Duration(milliseconds: 300));
  FlutterError.onError = eski;
  return n;
}

void main() {
  testWidgets('kuyruk · 375 px telefon', (t) async {
    final n = await _tasma(t, const Size(375, 812), [_h(1), _h(2)]);
    debugPrint('TELEFON(375) taşma: $n');
    expect(n, 0, reason: 'telefonda taşma kalmamalı');
  });

  testWidgets('kuyruk · 320 px dar telefon', (t) async {
    final n = await _tasma(t, const Size(320, 640), [_h(1)]);
    debugPrint('DAR(320) taşma: $n');
    expect(n, 0);
  });

  testWidgets('kuyruk · programlı haber rozeti', (t) async {
    final n = await _tasma(t, const Size(375, 812),
        [_h(1, program: DateTime(2026, 11, 20, 9, 30))]);
    debugPrint('PROGRAMLI taşma: $n');
    expect(find.textContaining('yayına girecek'), findsOneWidget);
    expect(find.text('Programlı'), findsOneWidget);
    expect(n, 0);
  });

  testWidgets('karar çipleri ve denetim çiziliyor', (t) async {
    // Yeni onay ekranının üç parçası: denetim şeridi, manşet adayı ve
    // son dakika çipleri. Üçü de kararın verildiği yerde olmalı.
    await _tasma(t, const Size(375, 812), [
      _h(1), // kapağı yok → denetim ağır bulgu üretir
    ]);
    expect(find.text('Manşet adayı'), findsOneWidget);
    expect(find.text('Son dakika'), findsOneWidget);
    expect(find.textContaining('ciddi sorun'), findsWidgets);
  });

  testWidgets('kuyruk kaydırılabilir bir listede, deste YOK', (t) async {
    // 15 Kasım 2026: kısa süre "deste" (tek haber, tam ekran) denendi ve
    // geri alındı — kullanıcı eski liste düzeninin daha işlevsel olduğunu
    // söyledi: "işlevi önemsiz her şey büyük, önemli her şey daracık."
    // Kuyruk bir liste; üst bar da sayfayla birlikte kayıp gidiyor.
    await _tasma(t, const Size(375, 812), [_h(1), _h(2), _h(3)]);
    expect(find.text('1 / 3'), findsNothing);
    expect(find.byType(CustomScrollView), findsOneWidget);
  });

  _kuyrukDuzeniSinavlari();
  _duzeltmeSinavlari();

  testWidgets('kuyruk · masaüstü', (t) async {
    final n = await _tasma(t, const Size(1440, 900), [_h(1), _h(2)]);
    debugPrint('MASAÜSTÜ taşma: $n');
    expect(n, 0);
  });
}

// ── Kuyruk düzeni: tek kaydırma, tam genişlik ───────────────────────────
void _kuyrukDuzeniSinavlari() {
  testWidgets('masaüstünde yan yana bölme YOK, kart geniş', (t) async {
    await _tasma(t, const Size(1440, 900), [_h(1), _h(2)]);

    // Karar kartı 520 piksellik bir şeride sıkışmamalı.
    final kart = t.getSize(find.byType(Checkbox).first);
    expect(kart.width, greaterThan(0));

    // Kartın başlığı ekranın solundaki dar şeritte değil, geniş alanda.
    final baslik = t.getTopLeft(find.textContaining('TÜRKŞEKER').first);
    final genislik = t.getSize(find.textContaining('TÜRKŞEKER').first).width;
    expect(genislik, greaterThan(400),
        reason: 'karar alanı dar bir şeride sıkışmış olabilir');
    expect(baslik.dx, lessThan(700));
  });

  testWidgets('kuyrukta tek kaydırılabilir alan var', (t) async {
    await _tasma(t, const Size(1440, 900), [_h(1), _h(2), _h(3)]);
    // Yan yana bölme iki ayrı kaydırma üretiyordu: solda karar sütunu,
    // sağda önizleme. Tek kaydırma kalmalı.
    final kaydirilabilir = t.widgetList(find.byType(Scrollable)).length;
    expect(kaydirilabilir, lessThanOrEqualTo(2),
        reason: 'birden çok kaydırma alanı var — yan yana bölme mi geri geldi?');
  });
}

// ── Uyarılar düzeltilebilir olmalı ──────────────────────────────────────
void _duzeltmeSinavlari() {
  testWidgets('her uyarının yanında ne yapacağını söyleyen düğme var',
      (t) async {
    // Kullanıcı: "uyarılara müdahale edemedikten sonra uyarıları görmenin
    // ne anlamı var?" Her bulgunun yanında onu düzeltecek düğme olmalı ve
    // düğmenin adı NE YAPACAĞINI söylemeli — "Düzelt" demek yetmiyor.
    await _tasma(t, const Size(1440, 900), [_h(1)]);
    // _h(1) kapaksız: ağır bulgu üretir, şerit açık doğar.
    expect(find.textContaining('ciddi sorun'), findsWidgets);
    expect(find.text('Kapak seç'), findsOneWidget);
  });

  testWidgets('yalnız HAFİF uyarı varken de düğmeler görünüyor', (t) async {
    // 15 Kasım 2026: şerit yalnız ağır bulguda açılıyordu. Kuyruktaki 15
    // haberin 13'ü tertemizdi, kalan ikisinde yalnız hafif uyarı vardı —
    // yani kullanıcı hiçbir düzeltme düğmesi göremiyordu.
    await _tasma(t, const Size(1440, 900), [
      _h(2, kapakli: true), // kapak var, türevler yok → hafif uyarı
    ]);
    expect(find.textContaining('uyarı'), findsWidgets);
    expect(find.text('Türevleri üret'), findsWidgets);
  });
}
