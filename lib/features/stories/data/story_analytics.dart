import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Hikaye olayları.
///
/// Hangi hikayenin izlendiğini, hangisinin sonuna kadar gidildiğini ve
/// hangisinden habere geçildiğini ölçmeden "haber çekme kuralı" ayarlanamaz:
/// üretim tarafında eşiği değiştirdiğimizde işe yarayıp yaramadığını
/// görebileceğimiz tek yer burası.
///
/// Analytics'in kurulu olmadığı hedeflerde (masaüstü) çağrı hata fırlatabilir;
/// ölçüm uğruna hikaye ekranını düşürmemek için hepsi yutuluyor.
class StoryAnalytics {
  const StoryAnalytics._();

  static Future<void> _log(String name, Map<String, Object> params) async {
    try {
      await FirebaseAnalytics.instance.logEvent(name: name, parameters: params);
    } catch (error) {
      debugPrint('StoryAnalytics: "$name" gönderilemedi ($error)');
    }
  }

  /// Görüntüleyici açıldı.
  static void opened({required String groupKey, required int groupCount}) {
    _log('story_open', {'group_key': groupKey, 'group_count': groupCount});
  }

  /// Bir grubun son slaytı da izlendi (dokunarak atlanmadan).
  static void completed({required String groupKey, required int itemCount}) {
    _log('story_complete', {'group_key': groupKey, 'item_count': itemCount});
  }

  /// "Haberi Oku" tıklandı.
  static void articleOpened({
    required String groupKey,
    required String articleId,
    required int slideIndex,
  }) {
    _log('story_article_click', {
      'group_key': groupKey,
      'article_id': articleId,
      'slide_index': slideIndex,
    });
  }

  /// Hikaye paylaşıldı.
  static void shared({required String groupKey, required String articleId}) {
    _log('story_share', {'group_key': groupKey, 'article_id': articleId});
  }
}
