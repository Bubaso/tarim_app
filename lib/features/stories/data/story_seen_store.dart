import 'package:shared_preferences/shared_preferences.dart';

import 'story_constants.dart';

/// Hangi hikaye slaytının bu cihazda izlendiğinin defteri.
///
/// ── Neden gerekti ────────────────────────────────────────────────────────
/// Şeritteki halkanın rengi yalnızca `is_breaking`'e bağlıydı. Yani okuyucu,
/// hangi hikayeyi izlediğini baloncuğa bakarak ayırt edemiyordu; izlediği
/// hikaye ertesi açılışta yine aynı yerde, yine "yeni" görünümünde duruyordu.
/// Instagram'da çalışan tek mekanik budur: izlenmemiş olan öne gelir ve
/// renkli halkayla durur, izlenen soluklaşıp geri çekilir.
///
/// Defter cihazda kalır (hesap yok), [StoryRules.seenMemory] süresinden eski
/// kayıtlar her yazmada budanır — hikayeler zaten en fazla 36 saat yaşıyor.
class StorySeenStore {
  const StorySeenStore._();

  static const String _key = 'seen_story_items_v1';

  /// Kayıt biçimi: `<slaytId>|<epochMillis>`. Zaman damgası budama için.
  static const String _sep = '|';

  static Future<Set<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? const <String>[];
    final cutoff = DateTime.now().subtract(StoryRules.seenMemory);
    final result = <String>{};
    for (final entry in raw) {
      final parts = entry.split(_sep);
      if (parts.length != 2) continue;
      final millis = int.tryParse(parts[1]);
      if (millis == null) continue;
      if (DateTime.fromMillisecondsSinceEpoch(millis).isBefore(cutoff)) continue;
      result.add(parts[0]);
    }
    return result;
  }

  /// Verilen slaytları izlendi olarak işler ve defterin tamamını döndürür.
  static Future<Set<String>> markSeen(Iterable<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? const <String>[];
    final cutoff = DateTime.now().subtract(StoryRules.seenMemory);
    final now = DateTime.now().millisecondsSinceEpoch;

    // Aynı slaytın eski kaydını düşürüp yenisini yazıyoruz; böylece defter
    // tekrar etmez ve zaman damgası son izlemeyi gösterir.
    final incoming = ids.toSet();
    final kept = <String, int>{};
    for (final entry in raw) {
      final parts = entry.split(_sep);
      if (parts.length != 2) continue;
      final millis = int.tryParse(parts[1]);
      if (millis == null) continue;
      if (DateTime.fromMillisecondsSinceEpoch(millis).isBefore(cutoff)) continue;
      if (incoming.contains(parts[0])) continue;
      kept[parts[0]] = millis;
    }
    for (final id in incoming) {
      kept[id] = now;
    }

    await prefs.setStringList(
      _key,
      kept.entries.map((e) => '${e.key}$_sep${e.value}').toList(),
    );
    return kept.keys.toSet();
  }
}
