import 'package:flutter/painting.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client.dart';
import '../data/models/story_item.dart';

final storiesProvider = FutureProvider<List<StoryGroup>>((ref) async {
  final supabase = ref.read(supabaseClientProvider);
  
  // Hatalı görselleri elemek için havuzu geniş tutuyoruz (En fazla 30 çek, sağlam 10 bulana kadar ele)
  final response = await supabase
      .from('portal_stories')
      .select('*, articles(image_url)')
      .gt('expires_at', DateTime.now().toUtc().toIso8601String())
      .order('is_breaking', ascending: false)
      .order('created_at', ascending: false)
      .limit(30);

  final List<StoryGroup> validStories = [];
  
  for (final row in response) {
    if (validStories.length >= 10) break; // Sadece sağlam 10 hikaye yeterli

    final articleData = row['articles'] as Map<String, dynamic>?;
    final String? avatarUrl = (articleData != null && articleData['image_url'] != null && articleData['image_url'].toString().trim().length > 5)
        ? articleData['image_url'] as String
        : null;

    // Resim yoksa (null ise) veya geçersizse direkt atla, yedek resim kesinlikle kullanılmaz!
    if (avatarUrl == null || avatarUrl.trim().isEmpty) continue;
    final String safeAvatarUrl = avatarUrl;

    final bool isBreaking = row['is_breaking'] == true;
    final List<dynamic> itemsData = row['items'] as List<dynamic>? ?? [];
    
    final List<StoryItem> parsedItems = itemsData.map((item) {
      return StoryItem(
        id: row['id'] + '_' + itemsData.indexOf(item).toString(),
        superTitle: item['super_title']?.toString() ?? '',
        headline: item['headline']?.toString() ?? '',
        bigStatValue: item['big_stat_value']?.toString() ?? '',
        statLabel: item['stat_label']?.toString() ?? '',
        backgroundUrl: safeAvatarUrl,
      );
    }).toList();

    if (parsedItems.isNotEmpty) {
      validStories.add(StoryGroup(
        id: row['id'].toString(),
        title: row['group_title']?.toString() ?? 'Hikaye',
        avatarUrl: safeAvatarUrl,
        articleId: row['article_id'].toString(),
        isNew: isBreaking,
        items: parsedItems,
      ));
    }
  }

  return validStories;
});
