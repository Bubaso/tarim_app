/// ISO-8601 hafta kimliği — `/hafta/2026-W33` adresinin taşıdığı değer.
///
/// ── Neden takvim haftası, neden "son 7 gün" değil ────────────────────────
/// Haftalık özet eskiden `created_at >= now() - 168 saat` ile seçiliyordu.
/// Pazar 19:00'da çalışan bir iş için bu pencere geçen Pazar 19:00'a uzanır:
/// iki takvim haftasından parçalar taşıyan, adreslenemeyen, iki kez
/// açıldığında farklı sonuç veren bir küme. "Bu haftanın özeti" diye
/// paylaşılabilir bir sayfanın böyle bir kümesi olamaz.
///
/// Takvim haftası ise sabit: `2026-W33` bugün de, altı ay sonra da aynı yedi
/// günü gösterir. Sayfa önbelleklenebilir, paylaşılan bağlantı bayatlamaz,
/// arşiv geriye doğru yürünebilir.
///
/// ── Saat dilimi ──────────────────────────────────────────────────────────
/// Hafta sınırları UTC'de değil, İSTANBUL duvar saatinde çizilir: Pazartesi
/// 00:00'da başlar. UTC kullanılsaydı Pazartesi 02:00'de yayımlanan bir haber
/// (UTC'de hâlâ Pazar 23:00) bir önceki haftanın özetinde çıkardı.
///
/// Ofset sabit +03:00 olarak yazılı. Türkiye 2016'dan beri yaz saati
/// uygulamıyor; kalıcı UTC+3. Bunun tek gerçek alternatifi `timezone`
/// paketini eklemek ve IANA veritabanını uygulamaya gömmekti — tek bir sabit
/// için ağır bir bedel. Türkiye yeniden yaz saatine geçerse burası ve
/// `functions/index.js` içindeki eşi birlikte güncellenmeli.
class IsoWeek {
  const IsoWeek(this.year, this.week);

  /// ISO hafta yılı. Yılbaşı haftalarında takvim yılından FARKLI olabilir:
  /// 1 Ocak 2027 Cuma, dolayısıyla 2026-W53'e aittir.
  final int year;

  /// 1–52 veya 1–53.
  final int week;

  static const Duration _tz = Duration(hours: 3);

  static const List<String> _monthsTr = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
  ];

  static const List<String> _monthsEn = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  /// Verilen anın ait olduğu hafta.
  ///
  /// ISO kuralı: bir tarihin haftası, O HAFTANIN PERŞEMBESİNİN düştüğü yılın
  /// haftasıdır. Yıl sınırındaki tuhaflıkları (1 Ocak'ın geçen yılın son
  /// haftasına ait olması) tek başına bu kural çözer.
  static IsoWeek of(DateTime instant) {
    final local = instant.toUtc().add(_tz);
    // Aritmetik UTC'de yapılıyor: yerel `DateTime` üzerinde gün eklemek yaz
    // saati geçişlerinde 23 veya 25 saatlik günler üretebilir.
    final day = DateTime.utc(local.year, local.month, local.day);
    final thursday = day.add(Duration(days: 4 - day.weekday));
    final jan1 = DateTime.utc(thursday.year, 1, 1);
    return IsoWeek(thursday.year, thursday.difference(jan1).inDays ~/ 7 + 1);
  }

  /// Bir ISO yılındaki hafta sayısı (52 ya da 53).
  ///
  /// 28 Aralık her zaman yılın SON ISO haftasına düşer — tanımın kendisinden
  /// gelen bir değişmez, ayrıca kural yazmaya gerek yok.
  static int weeksInYear(int year) => of(DateTime.utc(year, 12, 28, 12)).week;

  /// `2026-W33` biçimini çözer. Geçersizse `null`.
  ///
  /// Adres çubuğuna elle yazılan her şey buradan geçiyor; hafta numarası o yıl
  /// için gerçekten var mı diye de bakılıyor (`2026-W54` yok).
  static IsoWeek? parse(String raw) {
    final match = RegExp(r'^(\d{4})-W(\d{1,2})$').firstMatch(raw.trim().toUpperCase());
    if (match == null) return null;
    final year = int.parse(match.group(1)!);
    final week = int.parse(match.group(2)!);
    if (year < 2000 || year > 2999) return null;
    if (week < 1 || week > weeksInYear(year)) return null;
    return IsoWeek(year, week);
  }

  /// Adreste ve bildirimde kullanılan biçim. Hafta numarası iki hane —
  /// `2026-W7` ile `2026-W07` iki ayrı adres olmasın.
  String get slug => '$year-W${week.toString().padLeft(2, '0')}';

  /// Haftanın başladığı an (Pazartesi 00:00 İstanbul), UTC olarak.
  ///
  /// 4 Ocak her zaman 1. haftadadır (28 Aralık kuralının aynadaki eşi), o
  /// yüzden yılın ilk Pazartesi'si oradan geriye sayılarak bulunuyor.
  DateTime get startUtc {
    final jan4 = DateTime.utc(year, 1, 4);
    final firstMonday = jan4.subtract(Duration(days: jan4.weekday - 1));
    return firstMonday.add(Duration(days: (week - 1) * 7)).subtract(_tz);
  }

  /// Haftanın bittiği an — bir SONRAKİ Pazartesi 00:00. Sorgularda `<` ile
  /// kullanılır, `<=` ile değil: Pazartesi 00:00:00.000'da yayımlanan haber
  /// yeni haftaya aittir.
  DateTime get endUtc => startUtc.add(const Duration(days: 7));

  DateTime get _firstDay {
    final d = startUtc.add(_tz);
    return DateTime.utc(d.year, d.month, d.day);
  }

  DateTime get _lastDay => _firstDay.add(const Duration(days: 6));

  /// Haftanın gün aralığı: "10 – 16 Ağustos 2026", "26 Ocak – 1 Şubat 2026",
  /// "28 Aralık 2026 – 3 Ocak 2027".
  ///
  /// Ay ve yıl yalnızca hafta onları aştığında iki kez yazılıyor.
  ///
  /// İki dil ayrı ele alınıyor çünkü tekrarı atlanan parça farklı: Türkçe'de ay
  /// tarihten SONRA geldiği için ortak ay sondaki günde yazılır ("10 – 16
  /// Ağustos"), İngilizce'de ÖNCE geldiği için baştaki günde ("August 10 – 16").
  /// Tek bir şablonla ikisi de üretilemiyordu.
  String label({bool isEn = false}) {
    final months = isEn ? _monthsEn : _monthsTr;
    final a = _firstDay;
    final b = _lastDay;
    final sameYear = a.year == b.year;
    final sameMonth = sameYear && a.month == b.month;

    if (isEn) {
      final first = sameMonth
          ? '${months[a.month - 1]} ${a.day}'
          : '${months[a.month - 1]} ${a.day}${sameYear ? '' : ', ${a.year}'}';
      final last = sameMonth ? '${b.day}' : '${months[b.month - 1]} ${b.day}';
      return '$first – $last, ${b.year}';
    }

    final first = sameMonth
        ? '${a.day}'
        : '${a.day} ${months[a.month - 1]}${sameYear ? '' : ' ${a.year}'}';
    return '$first – ${b.day} ${months[b.month - 1]} ${b.year}';
  }

  /// "33. hafta" / "Week 33".
  String ordinalLabel({bool isEn = false}) =>
      isEn ? 'Week $week, $year' : '$year, $week. hafta';

  IsoWeek get previous =>
      week > 1 ? IsoWeek(year, week - 1) : IsoWeek(year - 1, weeksInYear(year - 1));

  IsoWeek get next =>
      week < weeksInYear(year) ? IsoWeek(year, week + 1) : IsoWeek(year + 1, 1);

  /// Karşılaştırma için tek sayıya indirgenmiş hâli. Hafta numarası iki hane
  /// olduğu için çarpan 100 yeterli.
  int get _ordinal => year * 100 + week;

  bool isAfter(IsoWeek other) => _ordinal > other._ordinal;

  @override
  bool operator ==(Object other) =>
      other is IsoWeek && other.year == year && other.week == week;

  @override
  int get hashCode => _ordinal;

  @override
  String toString() => slug;
}
