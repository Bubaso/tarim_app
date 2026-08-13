import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bildirim türleri.
///
/// [wireName] değerleri sunucudaki `sendToAll({ kind: … })` çağrılarıyla BİREBİR
/// aynı olmak zorunda (functions/index.js). Uyuşmayan tek bir harf, o türü
/// isteyen cihazın onu hiç almamasına yol açar ve hiçbir yerde hata üretmez.
enum NotificationKind {
  breaking('breaking'),
  morning('morning'),
  weekly('weekly'),
  author('author');

  const NotificationKind(this.wireName);
  final String wireName;

  static NotificationKind? fromWire(String name) {
    for (final k in NotificationKind.values) {
      if (k.wireName == name) return k;
    }
    return null;
  }
}

/// Cihazın almak istediği bildirim türleri.
///
/// ── NULL ile BOŞ arasındaki fark ─────────────────────────────────────────
/// Disk anahtarı YOKSA kullanıcı hiç seçim yapmamıştır; cihaz her şeyi alır ve
/// sunucuya `kinds: null` yazılır. Anahtar VARSA kullanıcı seçim yapmıştır ve
/// liste birebir uygulanır — hepsini kapattıysa liste boştur ve cihaz hiçbir
/// şey almaz.
///
/// Bu ayrım olmadan "hepsini kapat" ile "hiç dokunmadım" aynı görünürdü ve
/// kullanıcı bildirimleri kapattığında hepsini almaya devam ederdi.
class NotificationPrefsNotifier extends Notifier<Set<NotificationKind>> {
  static const _key = 'notification_kinds';

  @override
  Set<NotificationKind> build() {
    _load();
    return NotificationKind.values.toSet();
  }

  Future<void> _load() async {
    final saved = await readSavedKinds();
    if (saved != null) state = saved;
  }

  /// Diskteki seçim. Kullanıcı hiç seçim yapmadıysa `null`.
  ///
  /// `NotificationService` de bunu okuyor: Riverpod state'i yerine diski
  /// kaynak almak, provider daha yüklenmeden token yazılırsa cihazın yanlışlıkla
  /// "hepsi kapalı" olarak kaydedilmesini imkânsız kılıyor.
  static Future<Set<NotificationKind>?> readSavedKinds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_key);
      if (list == null) return null;
      return list
          .map(NotificationKind.fromWire)
          .whereType<NotificationKind>()
          .toSet();
    } catch (_) {
      return null;
    }
  }

  Future<void> setEnabled(NotificationKind kind, bool enabled) async {
    final next = {...state};
    if (enabled) {
      next.add(kind);
    } else {
      next.remove(kind);
    }
    state = next;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _key,
        next.map((k) => k.wireName).toList(),
      );
    } catch (_) {
      // Yazılamazsa seçim yalnızca bu oturum için geçerli olur.
    }
  }
}

final notificationPrefsProvider =
    NotifierProvider<NotificationPrefsNotifier, Set<NotificationKind>>(
  NotificationPrefsNotifier.new,
);
