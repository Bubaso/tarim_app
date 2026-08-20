import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/supabase_client.dart';
import '../data/models/story_item.dart';
import '../data/story_constants.dart';
import '../data/story_seen_store.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  Hikaye akışı
// ──────────────────────────────────────────────────────────────────────────────
//  Akış üç katmandan geçiyor:
//    1) [storyFeedProvider]  — Supabase'ten satırları çeker, KONUYA göre
//                              gruplar (eskiden her haber tek slaytlık kendi
//                              grubuydu, çoklu ilerleme çubuğu boşuna duruyordu).
//    2) [storySeenProvider]  — cihazdaki "izlendi" defteri.
//    3) [storiesProvider]    — ikisini birleştirip süresi dolanları eler,
//                              izlenmemişleri öne alır, tazelik puanına göre
//                              sıralar ve [StoryRules.maxGroups] ile keser.
//
//  Sıralamanın eskisi `is_breaking` sonra `created_at` idi; 20 saatlik bir
//  "son dakika" taze haberin önünde duruyordu. Artık son dakika bonusunun da
//  ömrü var (bkz. [StoryRules.breakingBonusWindow]).
// ══════════════════════════════════════════════════════════════════════════════

/// Son başarılı çekimin zamanı. Uygulama öne geldiğinde listeyi yenilemeye
/// değip değmediğine bakmak için tutuluyor (bkz. [refreshStoriesIfStale]).
DateTime? _lastFetchedAt;

final storyFeedProvider = FutureProvider<List<StoryGroup>>((ref) async {
  final supabase = ref.read(supabaseClientProvider);

  final response = await supabase
      .from('portal_stories')
      .select('*, articles(image_url, story_image_url)')
      .gt('expires_at', DateTime.now().toUtc().toIso8601String())
      .order('created_at', ascending: false)
      .limit(StoryRules.fetchLimit);

  // Konu anahtarı -> o konudaki slaytlar. Gruplama tek geçişte, satırları
  // okurken yapılıyor.
  final buckets = <String, List<StoryItem>>{};
  final groupTitles = <String, _GroupTitle>{};

  for (final row in response) {
    final articleData = row['articles'] as Map<String, dynamic>?;
    final rawImage = articleData?['image_url']?.toString().trim() ?? '';
    // Görseli olmayan hikaye gösterilmez; yedek görsel kesinlikle kullanılmaz.
    if (rawImage.length < 6) continue;

    // Dar ekranlarda kullanılacak dikey türev. Boşsa haber bu göçten önce
    // işlenmiş ya da türev üretilememiş demektir; o durumda yatay kart tek
    // kaynak olarak kalır — eskiden beri olan davranış, gerileme değil.
    // Geniş ekranlarda zaten yatay kart kullanılıyor, seçimi görüntüleyici
    // yapıyor (bkz. storyBackgroundUrl).
    final rawStory = articleData?['story_image_url']?.toString().trim() ?? '';
    final portrait = rawStory.length < 6 ? '' : rawStory;

    final storyId = row['id'].toString();
    final articleId = row['article_id'].toString();
    final bool isBreaking = row['is_breaking'] == true;
    final DateTime createdAt =
        DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now();
    final DateTime? expiresAt =
        DateTime.tryParse(row['expires_at']?.toString() ?? '');

    final String title = row['group_title']?.toString().trim() ?? '';
    if (title.isEmpty) continue;
    final String key = title.toLowerCase();

    final itemsData = row['items'];
    if (itemsData is! List) continue;

    for (int i = 0; i < itemsData.length; i++) {
      final raw = itemsData[i];
      if (raw is! Map) continue;

      final headline = raw['headline']?.toString() ?? '';
      final bigStat = raw['big_stat_value']?.toString() ?? '';
      // Başlığı veya vurucu değeri olmayan slayt boş bir kart demek.
      if (headline.isEmpty || bigStat.isEmpty) continue;

      buckets.putIfAbsent(key, () => <StoryItem>[]).add(StoryItem(
        id: '$storyId#$i',
        storyId: storyId,
        articleId: articleId,
        superTitle: raw['super_title']?.toString() ?? '',
        superTitleEn: raw['super_title_en']?.toString() ?? '',
        headline: headline,
        headlineEn: raw['headline_en']?.toString() ?? '',
        bigStatValue: bigStat,
        bigStatValueEn: raw['big_stat_value_en']?.toString() ?? '',
        statLabel: raw['stat_label']?.toString() ?? '',
        statLabelEn: raw['stat_label_en']?.toString() ?? '',
        imageUrl: rawImage,
        portraitUrl: portrait,
        createdAt: createdAt,
        expiresAt: expiresAt,
        isBreaking: isBreaking,
      ));

      // Grubun görünen adını en taze satır belirler; satırlar zaten yeniden
      // eskiye geldiği için ilk gelen kazanır.
      groupTitles.putIfAbsent(
        key,
        () => _GroupTitle(
          title,
          raw['group_title_en']?.toString().trim() ?? '',
        ),
      );
    }
  }

  _lastFetchedAt = DateTime.now();
  return _buildGroups(buckets, groupTitles);
});

/// İzlenmişleri, izlenmemişleri ve sıralamayı uygulanmış nihai liste.
final storiesProvider = Provider<AsyncValue<List<StoryGroup>>>((ref) {
  final feed = ref.watch(storyFeedProvider);
  final seen = ref.watch(storySeenProvider);
  return feed.whenData((groups) => rankStoryGroups(groups, seen, DateTime.now()));
});

/// Cihazdaki izlendi defteri. Görüntüleyici her slaytı gösterdiğinde işler.
final storySeenProvider =
    StateNotifierProvider<StorySeenNotifier, Set<String>>((ref) {
  return StorySeenNotifier();
});

class StorySeenNotifier extends StateNotifier<Set<String>> {
  StorySeenNotifier() : super(const <String>{}) {
    _load();
  }

  Future<void> _load() async {
    final loaded = await StorySeenStore.load();
    if (!mounted) return;
    state = loaded;
  }

  Future<void> markSeen(Iterable<String> ids) async {
    final fresh = ids.where((id) => !state.contains(id)).toList();
    if (fresh.isEmpty) return;
    final updated = await StorySeenStore.markSeen(fresh);
    if (!mounted) return;
    state = updated;
  }
}

/// Uygulama öne geldiğinde çağrılır: liste [StoryRules.refreshAfter] süresinden
/// eskiyse yeniden çekilir.
///
/// Eskiden akış tek sefer çekilip uygulama kapanana kadar öyle kalıyordu;
/// süresi dolmuş hikayeler ekranda duruyor, yeni üretilenler hiç görünmüyordu.
void refreshStoriesIfStale(WidgetRef ref) {
  final last = _lastFetchedAt;
  if (last != null && DateTime.now().difference(last) < StoryRules.refreshAfter) {
    return;
  }
  ref.invalidate(storyFeedProvider);
}

// ── Gruplama ve sıralama ──────────────────────────────────────────────────────

class _GroupTitle {
  final String tr;
  final String en;
  const _GroupTitle(this.tr, this.en);
}

/// Kovaları gruplara çevirir; her grupta en taze
/// [StoryRules.maxItemsPerGroup] slayt kalır.
List<StoryGroup> _buildGroups(
  Map<String, List<StoryItem>> buckets,
  Map<String, _GroupTitle> titles,
) {
  final groups = <StoryGroup>[];
  buckets.forEach((key, bucket) {
    bucket.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final trimmed = bucket.take(StoryRules.maxItemsPerGroup).toList();
    final title = titles[key];
    groups.add(StoryGroup(
      key: key,
      title: title?.tr ?? key,
      titleEn: title?.en ?? '',
      // Baloncuk yatay karttan besleniyor: dikey türevin ortasından kare
      // kesmek kartta görünen çerçeveyi vermiyor.
      avatarUrl: trimmed.first.imageUrl,
      items: trimmed,
      latestAt: trimmed.first.createdAt,
      isBreaking: trimmed.any((i) => i.isBreaking),
    ));
  });

  return groups;
}

/// Süresi dolanları eler, izlendi durumunu işler, sıralar ve keser.
///
/// Test edilebilir olsun diye [now] dışarıdan veriliyor.
List<StoryGroup> rankStoryGroups(
  List<StoryGroup> groups,
  Set<String> seen,
  DateTime now,
) {
  final live = <StoryGroup>[];

  for (final group in groups) {
    // Sunucudan gelen liste çekildiği andaki durumu yansıtıyor; uygulama açık
    // kaldıkça hikayelerin süresi doluyor. İstemcide de eliyoruz.
    final items = group.items
        .where((i) => i.expiresAt == null || i.expiresAt!.isAfter(now))
        .toList();
    if (items.isEmpty) continue;

    live.add(group.copyWith(
      items: items,
      isSeen: items.every((i) => seen.contains(i.id)),
    ));
  }

  live.sort((a, b) {
    // İzlenmemişler her zaman önce.
    if (a.isSeen != b.isSeen) return a.isSeen ? 1 : -1;
    return _score(b, now).compareTo(_score(a, now));
  });

  return live.take(StoryRules.maxGroups).toList();
}

double _score(StoryGroup group, DateTime now) {
  final double ageHours = now.difference(group.latestAt).inMinutes / 60.0;
  final double halfLife = StoryRules.freshnessHalfLife.inMinutes / 60.0;
  double score = math.pow(0.5, ageHours / halfLife).toDouble();
  if (group.isBreaking &&
      now.difference(group.latestAt) < StoryRules.breakingBonusWindow) {
    score += StoryRules.breakingBonus;
  }
  return score;
}
