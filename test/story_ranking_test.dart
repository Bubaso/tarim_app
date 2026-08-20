import 'package:flutter_test/flutter_test.dart';
import 'package:tarim_app/features/stories/data/models/story_item.dart';
import 'package:tarim_app/features/stories/data/story_constants.dart';
import 'package:tarim_app/features/stories/providers/story_providers.dart';

StoryItem _item(
  String id, {
  required DateTime createdAt,
  DateTime? expiresAt,
  bool isBreaking = false,
}) {
  return StoryItem(
    id: id,
    storyId: id,
    articleId: 'a-$id',
    superTitle: 'ETİKET',
    headline: 'Başlık $id',
    bigStatValue: '+%4.2',
    statLabel: 'Etiket',
    imageUrl: 'https://example.com/$id.jpg',
    createdAt: createdAt,
    expiresAt: expiresAt,
    isBreaking: isBreaking,
  );
}

StoryGroup _group(
  String key,
  List<StoryItem> items, {
  bool isBreaking = false,
}) {
  return StoryGroup(
    key: key,
    title: key,
    avatarUrl: items.first.imageUrl,
    items: items,
    latestAt: items.first.createdAt,
    isBreaking: isBreaking,
  );
}

void main() {
  final now = DateTime(2026, 8, 20, 12);

  group('rankStoryGroups', () {
    test('süresi dolan slaytları eler, grubu boşalırsa düşürür', () {
      final live = _item('live',
          createdAt: now.subtract(const Duration(hours: 1)),
          expiresAt: now.add(const Duration(hours: 5)));
      final dead = _item('dead',
          createdAt: now.subtract(const Duration(hours: 2)),
          expiresAt: now.subtract(const Duration(minutes: 1)));

      final result = rankStoryGroups(
        [
          _group('piyasa', [live, dead]),
          _group('hasat', [dead]),
        ],
        const <String>{},
        now,
      );

      expect(result.length, 1);
      expect(result.single.key, 'piyasa');
      expect(result.single.items.map((i) => i.id), ['live']);
    });

    test('izlenmemiş grup, daha taze ama izlenmiş grubun önüne geçer', () {
      final seenFresh = _item('fresh', createdAt: now);
      final unseenOld =
          _item('old', createdAt: now.subtract(const Duration(hours: 10)));

      final result = rankStoryGroups(
        [
          _group('taze', [seenFresh]),
          _group('eski', [unseenOld]),
        ],
        {'fresh'},
        now,
      );

      expect(result.map((g) => g.key), ['eski', 'taze']);
      expect(result.first.isSeen, isFalse);
      expect(result.last.isSeen, isTrue);
    });

    test('son dakika bonusu süresi dolunca tazelik kazanır', () {
      final staleBreaking = _item('breaking',
          createdAt: now.subtract(StoryRules.breakingBonusWindow +
              const Duration(hours: 1)),
          isBreaking: true);
      final fresh =
          _item('normal', createdAt: now.subtract(const Duration(hours: 1)));

      final result = rankStoryGroups(
        [
          _group('sondakika', [staleBreaking], isBreaking: true),
          _group('normal', [fresh]),
        ],
        const <String>{},
        now,
      );

      expect(result.map((g) => g.key), ['normal', 'sondakika']);
    });

    test('taze son dakika, aynı yaştaki normal haberin önünde', () {
      final breaking = _item('b',
          createdAt: now.subtract(const Duration(hours: 2)), isBreaking: true);
      final normal =
          _item('n', createdAt: now.subtract(const Duration(hours: 2)));

      final result = rankStoryGroups(
        [
          _group('normal', [normal]),
          _group('sondakika', [breaking], isBreaking: true),
        ],
        const <String>{},
        now,
      );

      expect(result.first.key, 'sondakika');
    });

    test('grup sayısı üst sınırla kesilir', () {
      final groups = List.generate(
        StoryRules.maxGroups + 4,
        (i) => _group('konu$i', [
          _item('i$i', createdAt: now.subtract(Duration(minutes: i))),
        ]),
      );

      expect(rankStoryGroups(groups, const <String>{}, now).length,
          StoryRules.maxGroups);
    });
  });

  group('storySlideDuration', () {
    test('metin yoksa taban süre', () {
      expect(storySlideDuration('', ''), StoryRules.minSlideDuration);
    });

    test('uzun metinde tavan süreyi aşmaz', () {
      final duration = storySlideDuration('x' * 200, 'y' * 200);
      expect(duration, StoryRules.maxSlideDuration);
    });

    test('metin uzadıkça süre artar', () {
      final short = storySlideDuration('x' * 10, '');
      final long = storySlideDuration('x' * 60, '');
      expect(long, greaterThan(short));
      expect(long, lessThanOrEqualTo(StoryRules.maxSlideDuration));
    });
  });
}
