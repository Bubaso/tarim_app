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

  // ══════════════════════════════════════════════════════════════════════
  //  TAZELİK PAYI
  // ────────────────────────────────────────────────────────────────────
  //  19 Kasım 2026'da ölçüldü: sektör sekmeleri öncelik kuyruğunun
  //  sonundaydı (manşet 10 + Bilim 8 + Türkiye 12 + Dünya 10 = 40 haber
  //  önce harcanıyordu) ve günlük arz 15,3 haber olduğu için KALICI olarak
  //  ~3 gün geride kalıyorlardı. Ölçülen: Hayvancılık 3,6 / Bitkisel 3,0 /
  //  Ekonomi 3,1 gün. Aynı sekmeye dokununca ilk kart bugünün haberiydi.
  //
  //  Manşet burada BOŞ bırakılıyor: ölçülen şey dağıtımın kendi sırası.
  //  Manşetin havuzdan önce seçtiği gerçeği değişmiyor, testi başka yerde.
  // ══════════════════════════════════════════════════════════════════════
  group('tazelik payı', () {
    Future<HomeAllocation> dagitMansetsiz(List<NewsArticle> liste) async {
      final container = ProviderContainer(overrides: [
        latestArticlesProvider.overrideWith((ref) => Stream.value(liste)),
        initialReadArticlesProvider.overrideWith((ref) => const <String>{}),
        heroArticlesProvider.overrideWithValue(const <NewsArticle>[]),
      ]);
      addTearDown(container.dispose);
      await container.read(latestArticlesProvider.future);
      return container.read(homeAllocationProvider);
    }

    test('sektör sekmesi kuyruğun ARTIĞIYLA değil, en tazeyle açılıyor',
        () async {
      // Hepsi Türkiye + Ekonomi: Türkiye kovası ile sektör kovası aynı
      // havuz için yarışıyor. Tazelik payı olmadan Türkiye en taze 12'yi
      // alır ve Ekonomi sekmesi 13. haberle açılırdı.
      final d = await dagitMansetsiz([
        for (var i = 1; i <= 30; i++)
          h('e-$i', region: 'Türkiye', topic: 'Ekonomi', saatOnce: i),
      ]);

      expect(d.byTopic['Ekonomi']!.first.id, 'e-1',
          reason: 'Sektör sekmesi havuzun en taze haberiyle açılmalı.');
      // Pay TUR TUR dağıtılıyor: 1. turda Ekonomi e-1'i, Türkiye e-2'yi alır;
      // 2. turda Ekonomi e-3'ü, Türkiye e-4'ü. Yani sektör her turda önce
      // geçiyor ama Türkiye'yi kuyruğa atmıyor.
      expect(d.turkey.first.id, 'e-2',
          reason: 'Türkiye de taze bir kartla açılmalı, artıkla değil.');
      expect(d.byTopic['Ekonomi']!.take(2).map((a) => a.id),
          ['e-1', 'e-3'],
          reason: 'Sektörün iki paylık kartı tur sırasına göre gelmeli.');
    });

    test('tazelik payı tavanları ve tekrarsızlığı bozmuyor', () async {
      final d = await dagitMansetsiz([
        for (var i = 1; i <= 30; i++)
          h('e-$i', region: 'Türkiye', topic: 'Ekonomi', saatOnce: i),
      ]);

      expect(d.turkey.length, 12, reason: 'Türkiye tavanı 12 kalmalı.');
      expect(d.byTopic['Ekonomi']!.length, 10,
          reason: 'Sektör tavanı 10 kalmalı.');
      final k = _tumKimlikler(d);
      expect(k.length, k.toSet().length, reason: 'Tazelik payı tekrar üretti.');
    });

    test('her sektör sekmesi KENDİ en taze haberiyle açılıyor', () async {
      final d = await dagitMansetsiz([
        h('hayvan-taze', region: 'Türkiye', topic: 'Hayvancılık', saatOnce: 2),
        h('bitki-taze', region: 'Türkiye', topic: 'Bitkisel Üretim',
            saatOnce: 3),
        h('eko-taze', region: 'Türkiye', topic: 'Ekonomi', saatOnce: 4),
        for (var i = 10; i <= 40; i++)
          h('dolgu-$i', region: 'Türkiye', topic: 'Ekonomi', saatOnce: i),
      ]);

      expect(d.byTopic['Hayvancılık']!.first.id, 'hayvan-taze');
      expect(d.byTopic['Bitkisel Üretim']!.first.id, 'bitki-taze');
      expect(d.byTopic['Ekonomi']!.first.id, 'eko-taze');
    });

    test('bölüm sırası NEWEST-FIRST kalıyor', () async {
      final d = await dagitMansetsiz([
        for (var i = 1; i <= 30; i++)
          h('e-$i', region: 'Türkiye', topic: 'Ekonomi', saatOnce: i),
      ]);
      for (final liste in [d.turkey, d.byTopic['Ekonomi']!]) {
        for (var i = 1; i < liste.length; i++) {
          expect(
            liste[i].createdAt.isAfter(liste[i - 1].createdAt),
            isFalse,
            reason: 'Liste eskiden yeniye kaymış: '
                '${liste[i - 1].id} → ${liste[i].id}',
          );
        }
      }
    });
  });
}
