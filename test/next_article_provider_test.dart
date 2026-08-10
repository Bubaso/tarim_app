import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarim_app/features/home/data/models/news_article.dart';
import 'package:tarim_app/features/home/providers/home_providers.dart';

NewsArticle a(
  String id, {
  String? topic,
  String? categoryId,
  int daysAgo = 0,
  String? imageUrl = 'https://x/i.jpg',
  String status = 'published',
}) =>
    NewsArticle(
      id: id,
      title: id,
      content: 'x',
      createdAt: DateTime(2026, 8, 10).subtract(Duration(days: daysAgo)),
      status: status,
      topic: topic,
      categoryId: categoryId,
      imageUrl: imageUrl,
    );

Future<NewsArticle?> pick(
  List<NewsArticle> list,
  String currentId, {
  Set<String> read = const {},
}) async {
  final container = ProviderContainer(overrides: [
    latestArticlesProvider.overrideWith((ref) => Stream.value(list)),
    initialReadArticlesProvider.overrideWith((ref) => read),
  ]);
  addTearDown(container.dispose);
  await container.read(latestArticlesProvider.future);
  return container.read(nextArticleProvider(currentId));
}

void main() {
  test('aynı konudan bir sonraki (daha eski) haberi seçer', () async {
    final list = [
      a('yeni', topic: 'hayvancilik', daysAgo: 0),
      a('current', topic: 'tarim', daysAgo: 1),
      a('tarim-eski', topic: 'tarim', daysAgo: 2),
      a('tarim-daha-eski', topic: 'tarim', daysAgo: 3),
    ];
    expect((await pick(list, 'current'))?.id, 'tarim-eski');
  });

  test('aynı konudan sonrası yoksa aynı konunun en yenisine döner', () async {
    final list = [
      a('tarim-yeni', topic: 'tarim', daysAgo: 0),
      a('current', topic: 'tarim', daysAgo: 5),
      a('baska', topic: 'hayvancilik', daysAgo: 6),
    ];
    expect((await pick(list, 'current'))?.id, 'tarim-yeni');
  });

  test('okunmuş haberleri atlar', () async {
    final list = [
      a('current', topic: 'tarim', daysAgo: 0),
      a('okundu', topic: 'tarim', daysAgo: 1),
      a('okunmadi', topic: 'tarim', daysAgo: 2),
    ];
    expect(
      (await pick(list, 'current', read: {'current', 'okundu'}))?.id,
      'okunmadi',
    );
  });

  test('konu eşleşmesi yoksa genel havuzun en yenisine düşer', () async {
    final list = [
      a('gundem-yeni', topic: 'hayvancilik', daysAgo: 0),
      a('current', topic: 'tarim', daysAgo: 1),
    ];
    expect((await pick(list, 'current'))?.id, 'gundem-yeni');
  });

  test('her şey okunmuşsa kartı gizlemek yerine en yeniyi verir', () async {
    final list = [
      a('en-yeni', topic: 'tarim', daysAgo: 0),
      a('current', topic: 'tarim', daysAgo: 1),
    ];
    expect(
      (await pick(list, 'current', read: {'current', 'en-yeni'}))?.id,
      'en-yeni',
    );
  });

  test('görselsiz ve yayınlanmamış haberler elenir', () async {
    final list = [
      a('gorselsiz', topic: 'tarim', daysAgo: 0, imageUrl: null),
      a('taslak', topic: 'tarim', daysAgo: 1, status: 'draft'),
      a('current', topic: 'tarim', daysAgo: 2),
      a('gecerli', topic: 'tarim', daysAgo: 3),
    ];
    expect((await pick(list, 'current'))?.id, 'gecerli');
  });

  test('tek haber varsa null döner (kart gizlenir)', () async {
    expect((await pick([a('current')], 'current')), isNull);
  });

  test('topic boşsa categoryId anahtar olur', () async {
    final list = [
      a('current', categoryId: 'c1', daysAgo: 0),
      a('baska-kategori', categoryId: 'c2', daysAgo: 1),
      a('ayni-kategori', categoryId: 'c1', daysAgo: 2),
    ];
    expect((await pick(list, 'current'))?.id, 'ayni-kategori');
  });
}
