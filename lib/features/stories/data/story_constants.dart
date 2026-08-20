/// Hikaye sisteminin tüm sayısal kuralları.
///
/// Bu değerler daha önce üç ayrı yere dağılmıştı (Python üretici, Riverpod
/// sağlayıcı, şerit widget'ı) ve birbirini tutmuyordu: üretici 10'da duruyor
/// ama ekrana "Limit: 7" yazıyor, sağlayıcı 10 grup döndürüyor ama şerit 7
/// tanesini gösterip görüntüleyiciye 10'unu birden veriyordu. Tek kaynak.
///
/// Python tarafındaki karşılıkları `scripts/generate_stories.py` başındaki
/// `StoryRules` sınıfındadır; ikisini birlikte güncelleyin.
class StoryRules {
  const StoryRules._();

  /// Veritabanından çekilen ham satır sayısı. Görseli bozuk olanlar elendiği
  /// ve satırlar gruplandığı için havuzu gösterilecek grup sayısından geniş
  /// tutuyoruz.
  static const int fetchLimit = 40;

  /// Şeritte ve görüntüleyicide gösterilen en fazla grup (konu) sayısı.
  static const int maxGroups = 10;

  /// Bir grubun içindeki en fazla slayt sayısı. Beşten uzun bir hikaye
  /// dizisini kimse sonuna kadar izlemiyor.
  static const int maxItemsPerGroup = 5;

  /// Şeridi göstermek için gereken en az grup sayısı. Tek başına duran bir
  /// baloncuk "sistem çalışmıyor" izlenimi veriyor.
  static const int minGroupsToShow = 3;

  /// Tazelik puanının yarılanma süresi. 8 saatlik bir haber, yeni bir haberin
  /// yarısı kadar puan alır.
  static const Duration freshnessHalfLife = Duration(hours: 8);

  /// Son dakika haberlerine eklenen puan (tazelik puanı 0..1 aralığında).
  static const double breakingBonus = 0.6;

  /// Son dakika bonusunun geçerli olduğu süre. 20 saatlik bir "son dakika"
  /// artık son dakika değildir.
  static const Duration breakingBonusWindow = Duration(hours: 12);

  /// Uygulama öne geldiğinde listenin yeniden çekilmesi için gereken süre.
  static const Duration refreshAfter = Duration(minutes: 5);

  /// Slayt süresinin alt ve üst sınırı; aradaki değer metin uzunluğundan
  /// hesaplanır (bkz. `storySlideDuration`).
  static const Duration minSlideDuration = Duration(seconds: 5);
  static const Duration maxSlideDuration = Duration(seconds: 7);

  /// İzlendi defterinin cihazda tutulduğu süre. Hikayeler en fazla 36 saat
  /// yaşadığı için bir haftalık defter fazlasıyla yeterli.
  static const Duration seenMemory = Duration(days: 7);
}

/// Slaytın ekranda kalma süresi: taban süre + okunacak metin kadar ek süre.
///
/// Sabit 7 saniye, tek satırlık bir istatistik kartı için uzundu; okuyucu
/// dokunarak geçmek zorunda kalıyordu. Karakter sayısı arttıkça süre
/// [StoryRules.maxSlideDuration]'a kadar uzar.
Duration storySlideDuration(String headline, String statLabel) {
  final int chars = headline.length + statLabel.length;
  final int minMs = StoryRules.minSlideDuration.inMilliseconds;
  final int maxMs = StoryRules.maxSlideDuration.inMilliseconds;
  // ~100 karakter, süreyi tabandan tavana taşır.
  final double ratio = (chars / 100).clamp(0.0, 1.0);
  return Duration(milliseconds: minMs + ((maxMs - minMs) * ratio).round());
}
