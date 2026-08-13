import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manşet sırasının ne zaman yenileneceğini belirleyen ziyaret defteri.
///
/// Manşet sıralaması bir tohumdan (`seed`) türetiliyor: aynı tohum aynı sırayı
/// verir. Sorun tohumun ne zaman değişeceğiydi.
///
/// Önceki hâlinde tohum, izolat ömrü boyunca yaşayan bir üst düzey `final`di.
/// Uygulama ana ekrandan açıldığında arka planda dondurulup geri getiriliyor,
/// sayfa yeniden yüklenmiyor — yani süreç günlerce ölmüyor ve okuyucu aynı
/// manşeti günlerce görüyordu.
///
/// Burada ölçüt süreç değil **duvar saati**: son etkinlikten bu yana
/// [visitGap] kadar zaman geçtiyse yeni bir ziyaret başlamış sayılır ve tohum
/// yenilenir. Böylece
///
///   • sayfalar arasında gezinirken ve geri dönerken sıra sabit kalır,
///   • aynı gün ikinci girişte manşet tazelenir,
///   • süreç hiç ölmese bile rotasyon işler.
class VisitTracker {
  const VisitTracker._();

  static const _seedKey = 'hero_visit_seed';
  static const _lastActiveKey = 'hero_last_active_at';

  /// İki etkinlik arasında bu kadar boşluk olursa yeni ziyaret sayılır.
  ///
  /// Başlangıçta 30 dakikaydı — analitikteki yerleşik oturum tanımı. Ama burada
  /// ölçtüğümüz şey bir oturum değil, okuyucunun manşeti "aynı" saydığı süre.
  /// Okuyucular sabah bakıp öğlen döndüklerinde sıranın değişmiş olmasından
  /// şikâyet etti: 30 dakika, haber okuma alışkanlığı için fazla kısa.
  ///
  /// 4 saat gün içindeki tipik iki bakış arasını kapsıyor; manşet gün boyu
  /// tanıdık kalıyor, ertesi sabah yine tazeleniyor.
  static const visitGap = Duration(hours: 4);

  /// Ziyareti açar; gerekiyorsa tohumu yeniler.
  ///
  /// Uygulama açılışında ve her öne gelişte çağrılır. [isNewVisit] yalnızca
  /// tohum gerçekten değiştiğinde `true` döner — çağıran taraf sıralamayı buna
  /// bakarak tazeler.
  static Future<({int seed, bool isNewVisit})> beginVisit() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastActive = prefs.getInt(_lastActiveKey);
    final storedSeed = prefs.getInt(_seedKey);

    final isNewVisit = storedSeed == null ||
        lastActive == null ||
        now - lastActive > visitGap.inMilliseconds;

    // Kayıt okunamazsa (ilk açılış, temizlenmiş depo) yeni ziyaret sayılıyor;
    // hata yönü rotasyona doğru, donmaya doğru değil.
    final seed = isNewVisit ? math.Random().nextInt(1 << 31) : storedSeed;
    if (isNewVisit) await prefs.setInt(_seedKey, seed);
    await prefs.setInt(_lastActiveKey, now);

    return (seed: seed, isNewVisit: isNewVisit);
  }

  /// Son etkinlik zamanını ilerletir.
  ///
  /// Uygulama arka plana alınırken çağrılıyor: boşluk, okuyucunun ayrıldığı
  /// andan itibaren ölçülmeli. Bu yazılmazsa uzun bir okuma seansının ardından
  /// 5 dakikalık bir aradan sonra dönen okuyucu da yeni ziyaret sayılırdı.
  static Future<void> markActive() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastActiveKey, DateTime.now().millisecondsSinceEpoch);
  }
}

/// Manşet sıralamasının rastgelelik tohumu.
///
/// `main` içinde ziyaret defterinden okunan değerle geçersiz kılınıyor; ziyaret
/// değiştiğinde [HeroSeed.rotate] ile tazeleniyor.
class HeroSeed extends Notifier<int> {
  HeroSeed(this._initial);

  final int _initial;

  @override
  int build() => _initial;

  void rotate(int seed) => state = seed;
}

final heroSeedProvider = NotifierProvider<HeroSeed, int>(
  // Varsayılan yalnızca `main` geçersiz kılmayı atlarsa devreye girer; sabit
  // bir değer bütün cihazlara aynı sırayı verirdi.
  () => HeroSeed(math.Random().nextInt(1 << 31)),
);
