/// Bir tarım ürününün son fiyatı — şerit kartının gösterdiği her şey.
///
/// `commodity_latest_prices` görünümünden okunuyor. Değişim yüzdesi ve
/// bayatlık gün sayısı veritabanında hesaplanıyor: istemcide hesaplamak için
/// her ürünün geçmişini indirmek gerekirdi.
class CommodityPrice {
  final String slug;
  final String nameTr;
  final String nameEn;
  final String category;

  /// 'TL/kg'. Sütun olarak var çünkü canlı hayvan (TL/adet) eklendiğinde
  /// kartın birimi veriden gelmeli, koda gömülü olmamalı.
  final String unit;

  final double avgPrice;
  final double? minPrice;
  final double? maxPrice;
  final double? volumeKg;

  /// Borsanın kendi bülten tarihi; verinin çekildiği tarih değil.
  final DateTime priceDate;

  /// Bir önceki İŞLEM gününe göre yüzde değişim.
  ///
  /// null olabilir — iki sebeple: ürünün ilk kaydıysa, ya da önceki işlem
  /// günü bir haftadan eskiyse. İkincisi seyrek işlem gören ürünler için:
  /// bir aylık farkı "günlük değişim" diye göstermek okuyucuyu yanıltır.
  final double? changePct;

  final String source;
  final String sourceLabel;
  final String? sourceUrl;

  /// Kaynağın kapsadığı coğrafya ("Polatlı"). Türkiye ortalaması değil;
  /// kart bunu saklamamalı.
  final String sourceScope;

  /// Fiyatın bugüne göre kaç gün eski olduğu. Görünüm 14 günden eskisini
  /// zaten gizliyor; kart 3 günü aşanı soluklaştırıyor.
  final int stalenessDays;

  /// 'traded' ya da 'administered'.
  ///
  /// Buğday fiyatı borsada her gün yeniden oluşuyor; şeker fiyatını Türkşeker
  /// ilan ediyor ve bir sonraki ilana kadar yürürlükte kalıyor. Kart bu ikisini
  /// aynı dille anlatamaz: "18 gün önceki" ilan fiyatı bayat değil, yürürlükte.
  final String priceKind;

  const CommodityPrice({
    required this.slug,
    required this.nameTr,
    required this.nameEn,
    required this.category,
    required this.unit,
    required this.avgPrice,
    this.minPrice,
    this.maxPrice,
    this.volumeKg,
    required this.priceDate,
    this.changePct,
    required this.source,
    required this.sourceLabel,
    this.sourceUrl,
    required this.sourceScope,
    required this.stalenessDays,
    this.priceKind = 'traded',
  });

  factory CommodityPrice.fromJson(Map<String, dynamic> json) {
    return CommodityPrice(
      slug: json['slug']?.toString() ?? '',
      nameTr: json['name_tr']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      unit: json['unit']?.toString() ?? 'TL/kg',
      // Postgres numeric'i PostgREST metin olarak döndürebiliyor; num cast'i
      // tek başına yeterli değil.
      avgPrice: _toDouble(json['avg_price']) ?? 0.0,
      minPrice: _toDouble(json['min_price']),
      maxPrice: _toDouble(json['max_price']),
      volumeKg: _toDouble(json['volume_kg']),
      priceDate: DateTime.tryParse(json['price_date']?.toString() ?? '') ?? DateTime.now(),
      changePct: _toDouble(json['change_pct']),
      source: json['source']?.toString() ?? '',
      sourceLabel: json['source_label']?.toString() ?? '',
      sourceUrl: json['source_url']?.toString(),
      sourceScope: json['source_scope']?.toString() ?? '',
      stalenessDays: (_toDouble(json['staleness_days']) ?? 0).round(),
      priceKind: json['price_kind']?.toString() ?? 'traded',
    );
  }

  String name(bool isEn) => isEn && nameEn.isNotEmpty ? nameEn : nameTr;

  bool get isUp => (changePct ?? 0) > 0;
  bool get isDown => (changePct ?? 0) < 0;

  /// Fiyat ilanla belirleniyor, işlemle değil.
  bool get isAdministered => priceKind == 'administered';

  /// Üç günden eski fiyat "bugünün fiyatı" gibi sunulamaz.
  ///
  /// İlan fiyatı için geçerli değil: 27 Temmuz'da yürürlüğe giren şeker fiyatı
  /// bugün de o fiyat. Eskimiş olan veri değil, sadece ilanın tarihi.
  bool get isStale => !isAdministered && stalenessDays > 3;

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

/// Detay sayfasındaki grafiğin tek bir noktası.
class CommodityPricePoint {
  final DateTime date;
  final double avgPrice;

  const CommodityPricePoint({required this.date, required this.avgPrice});

  factory CommodityPricePoint.fromJson(Map<String, dynamic> json) {
    return CommodityPricePoint(
      date: DateTime.tryParse(json['price_date']?.toString() ?? '') ?? DateTime.now(),
      avgPrice: CommodityPrice._toDouble(json['avg_price']) ?? 0.0,
    );
  }
}
