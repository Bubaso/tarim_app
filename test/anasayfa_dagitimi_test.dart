import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarim_app/features/home/data/models/news_article.dart';
import 'package:tarim_app/features/home/providers/home_providers.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Anasayfa dağıtımı: bir haber en fazla BİR bölümde
// ──────────────────────────────────────────────────────────────────────────
//  [homeAllocationProvider]'ın tek vaadi bu. Vaat kodda bir `spent` kümesiyle
//  tutuluyor ve kümeye eklemeyi unutan tek bir `claim` çağrısı sessizce
//  bozuyor: sayfa yine doluyor, yalnız aynı haber iki yerde görünüyor.
//  Gözle fark edilmesi zor — iki bölüm arasında bir ekran boyu mesafe var.
//
//  6 Kasım 2026 anasayfa denetiminin teknik maddesi.
// ══════════════════════════════════════════════════════════════════════════

NewsArticle h(
  String id, {
  String? topic,
  String? region,
  int saatOnce = 0,
  String? imageUrl = 'https://x/i.jpg',
  String? articleFormat,
  String status = 'published',
  int? heroScore,
}) =>
    NewsArticle(
      id: id,
      title: id,
      content: 'x',
      createdAt: DateTime.now().subtract(Duration(hours: saatOnce)),
      status: status,
      topic: topic,
      region: region,
      imageUrl: imageUrl,
      articleFormat: articleFormat,
      heroScore: heroScore,
    );

/// Dağıtımın ürettiği bütün listeleri tek bir düzlemde toplar.
List<String> _tumKimlikler(HomeAllocation d) => [
      ...d.turkey.map((a) => a.id),
      ...d.science.map((a) => a.id),
      ...d.world.map((a) => a.id),
      ...d.byTopic.values.expand((l) => l).map((a) => a.id),
      ...d.icymi.map((a) => a.id),
    ];

Future<HomeAllocation> dagit(List<NewsArticle> liste) async {
  final container = ProviderContainer(overrides: [
    latestArticlesProvider.overrideWith((ref) => Stream.value(liste)),
    initialReadArticlesProvider.overrideWith((ref) => const <String>{}),
  ]);
  addTearDown(container.dispose);
  await container.read(latestArticlesProvider.future);
  return container.read(homeAllocationProvider);
}

void main() {
  test('hiçbir haber iki bölümde birden görünmüyor', () async {
    // Kesişime açık bir havuz: bölgesi Türkiye OLAN ve aynı zamanda
    // sektörel konusu olan haberler. Dağıtım olmasaydı bunlar hem
    // "Türkiye'den" hem "Hayvancılık" altında çıkardı.
    final liste = <NewsArticle>[
      for (var i = 0; i < 10; i++)
        h('tr-hayvan-$i',
            region: 'Türkiye', topic: 'Hayvancılık', saatOnce: i + 1),
      for (var i = 0; i < 10; i++)
        h('tr-bitki-$i',
            region: 'Türkiye', topic: 'Bitkisel Üretim', saatOnce: i + 20),
      for (var i = 0; i < 6; i++)
        h('dunya-eko-$i',
            region: 'Dünya', topic: 'Ekonomi', saatOnce: i + 40),
      for (var i = 0; i < 5; i++)
        h('bilim-$i',
            region: 'Türkiye', topic: 'Tarım-Bilim', saatOnce: i + 60),
    ];

    final kimlikler = _tumKimlikler(await dagit(liste));

    // Boş bir dağıtım "tekrar yok" testini kendiliğinden geçerdi; önce
    // gerçekten iş yapıldığını doğrula.
    expect(kimlikler.length, greaterThan(10),
        reason: 'Dağıtım neredeyse boş — test bir şey kanıtlamıyor.');

    expect(
      kimlikler.length,
      kimlikler.toSet().length,
      reason: 'Tekrar eden haber: '
          '${kimlikler.where((k) => kimlikler.where((x) => x == k).length > 1).toSet()}',
    );
  });

  test('hero haberleri hiçbir bölüme düşmüyor', () async {
    final liste = <NewsArticle>[
      for (var i = 0; i < 12; i++)
        h('tr-$i',
            region: 'Türkiye',
            topic: 'Hayvancılık',
            saatOnce: i + 1,
            heroScore: 100 - i),
    ];

    final container = ProviderContainer(overrides: [
      latestArticlesProvider.overrideWith((ref) => Stream.value(liste)),
      initialReadArticlesProvider.overrideWith((ref) => const <String>{}),
    ]);
    addTearDown(container.dispose);
    await container.read(latestArticlesProvider.future);

    final hero = container.read(heroArticlesProvider).map((a) => a.id).toSet();
    final bolumler = _tumKimlikler(container.read(homeAllocationProvider));

    expect(hero, isNotEmpty, reason: 'Hero boşsa test bir şey kanıtlamıyor.');
    expect(
      bolumler.where(hero.contains),
      isEmpty,
      reason: 'Hero haberi aşağıdaki bölümlerde de görünüyor.',
    );
  });

  test('konu eşleşmesi Türkçe küçültmeyle yapılıyor', () async {
    // 'HAYVANCILIK'.toLowerCase() → 'hayvancilik' (noktalı i). Dart'ın
    // standart küçültmesiyle bu haber sektörel bölüme hiç girmezdi.
    // Havuz hero'nun alacağından BÜYÜK olmalı: birkaç haber verilince
    // hepsini hero yutuyor ve test konu eşleşmesini değil hero'yu ölçüyor.
    final konulu = await dagit([
      for (var i = 0; i < 20; i++)
        h('k-$i', topic: 'HAYVANCILIK', saatOnce: i + 30),
    ]);

    expect(
      konulu.byTopic['Hayvancılık'],
      isNotEmpty,
      reason: 'Büyük harfli konu sektörel bölüme düşmedi.',
    );
  });
}
