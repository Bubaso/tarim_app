import 'package:shared_preferences/shared_preferences.dart';

/// Okuma sayacının cihaz tarafındaki makbuz defteri.
///
/// ── Neden gerekti ────────────────────────────────────────────────────────
/// `view_count` bugüne kadar haber ekranı her AÇILDIĞINDA artıyordu. Bu, adı
/// "okunma" olan ama aslında "açılma" sayan bir metrik üretiyor:
///
///   • Aynı haberi ikinci kez açan kişi ikinci kez sayılıyordu.
///   • Başlığa tıklayıp yarım saniyede geri dönen kişi, baştan sona okuyan
///     kişiyle aynı ağırlıktaydı.
///   • Panelden haberini gözden geçiren editör kendi sayacını şişiriyordu.
///
/// Ölçemediğimiz bir şeyi ölçüyormuş gibi göstermek, hiç ölçmemekten kötü:
/// "haftanın en çok okunanı" gibi bir iddia bu sayaca dayandığında yanlış
/// bilgi üretir.
///
/// ── Ne yapıyor ───────────────────────────────────────────────────────────
/// Bir haberin sayacı bu cihazda BİR KEZ artırılır. [claim] ilk çağrıda
/// `true`, sonraki her çağrıda `false` döner.
///
/// ── Ne YAPMIYOR ──────────────────────────────────────────────────────────
/// Bu bir istemci tarafı önlemi; kararlı bir kişi depoyu temizleyip sayacı
/// yine şişirebilir. Sunucu tarafında gerçek tekilleştirme, sayaç yerine
/// olay tablosuna geçildiğinde (`article_reads`) mümkün olacak. Buradaki
/// amaç kötü niyeti değil, kendi kendine oluşan gürültüyü ayıklamak.
///
/// Defter `read_articles`tan AYRI tutuluyor. O küme haber açılır açılmaz
/// yazılıyor (manşette geri düşsün diye); sayaç ise okuma eşiği aşıldığında
/// artıyor. Tek küme kullanılsaydı eşik anında haber çoktan defterde olur ve
/// hiçbir okuma sayılmazdı.
class ReadReceipts {
  const ReadReceipts._();

  static const _key = 'counted_articles';

  /// Defterin üst sınırı. Kayıt cihazda kalıcı; sınırsız büyürse yıllar içinde
  /// her açılışta okunan şişkin bir listeye dönüşür. Sınır aşıldığında en eski
  /// kayıtlar düşer — o haberler yeniden sayılabilir hâle gelir, ama 500
  /// haberlik bir geçmişten sonra bunun ölçüme etkisi ihmal edilebilir.
  static const _limit = 500;

  /// Bu haberin sayacını artırma hakkını ister.
  ///
  /// İlk çağrıda `true` döner ve haber deftere işlenir; aynı haber için
  /// sonraki çağrılar `false` döner.
  static Future<bool> claim(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? const <String>[];
    if (list.contains(id)) return false;

    final next = [...list, id];
    if (next.length > _limit) {
      next.removeRange(0, next.length - _limit);
    }
    await prefs.setStringList(_key, next);
    return true;
  }
}
