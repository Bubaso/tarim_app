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

  /// İlan fiyatının dayandığı duyuru — yalnızca `administered` fiyatlarda dolu.
  ///
  /// Buğdayda kartın rakamı kendini açıklıyor: bir borsada, bir günde, işlem
  /// görmüş ortalama. Şekerde rakam bir METNİN yorumu; üstelik aynı duyuruda
  /// tonaja ve ödeme biçimine göre dört ayrı fiyat olabiliyor. Gösterilen
  /// rakamın hangisi olduğu ancak duyurunun kendisiyle birlikte anlaşılıyor.
  final CommodityNotice? notice;

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
    this.notice,
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
      notice: CommodityNotice.fromJson(json['notice']),
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

  /// O basamağı doğuran duyuru. Grafikte bir noktaya dokunulduğunda açılan
  /// belge bu: "temmuzda neden 38,61'e indi" sorusunun cevabı o günün
  /// ilanında (beş günlük bir kampanyaydı) ve başka hiçbir yerde yok.
  final CommodityNotice? notice;

  const CommodityPricePoint({
    required this.date,
    required this.avgPrice,
    this.notice,
  });

  factory CommodityPricePoint.fromJson(Map<String, dynamic> json) {
    return CommodityPricePoint(
      date: DateTime.tryParse(json['price_date']?.toString() ?? '') ?? DateTime.now(),
      avgPrice: CommodityPrice._toDouble(json['avg_price']) ?? 0.0,
      notice: CommodityNotice.fromJson(json['notice']),
    );
  }
}

/// Türkşeker'in yayımladığı bir fiyat duyurusu.
///
/// Hattın PDF'ten okuduğu her şey burada: ilanın başlığı, kapsamı, geçerlilik
/// tarihleri, İÇİNDEKİ BÜTÜN FİYATLAR ve belgenin tablo hizası korunmuş metni.
/// Kart tek bir rakam gösteriyor (ilandaki en düşüğü); geri kalanı okuyucunun
/// o rakamı doğrulayabilmesi için duruyor.
class CommodityNotice {
  /// Metin alanları iki dilde birden taşınıyor.
  ///
  /// Duyuru Türkçe yayımlanıyor ve fiyatın şartı ("5.000 ton ve üzeri, peşin")
  /// ile kapsamı okunurken zaten modelden geçiyor; İngilizcesini aynı geçişte
  /// üretmek ayrı bir çeviri adımından hem ucuz hem tutarlı. Fabrika ADLARI
  /// çevrilmiyor, yalnızca ölçü ve şart dili değişiyor.
  final String titleTr;
  final String titleEn;
  final String summaryTr;
  final String summaryEn;

  /// Fiyatın bağladığı fabrikalar: "Tüm fabrikalar" ya da sayılı isimler.
  final String scopeTr;
  final String scopeEn;
  final bool nationwide;

  /// Gösterilen fiyatın şartı: "5.000 ton ve üzeri, peşin" gibi.
  final String termsTr;
  final String termsEn;

  String title(bool isEn) => isEn && titleEn.isNotEmpty ? titleEn : titleTr;
  String summary(bool isEn) => isEn && summaryEn.isNotEmpty ? summaryEn : summaryTr;
  String scope(bool isEn) => isEn && scopeEn.isNotEmpty ? scopeEn : scopeTr;
  String terms(bool isEn) => isEn && termsEn.isNotEmpty ? termsEn : termsTr;

  final DateTime? published;
  final DateTime? effective;

  /// Kampanyanın son günü. null ise fiyat bir sonraki ilana kadar geçerli.
  final DateTime? validUntil;

  /// İlandaki bütün fiyatlar — kartta görünen dahil.
  final List<CommodityNoticePrice> prices;

  final String? pdfUrl;

  /// Satır neden o gün yazıldı. Kampanya bittiğinde fiyat yürürlükteki ilana
  /// dönüyor ve o gün yeni bir duyuru yayımlanmış olmuyor; bu alan olmadan
  /// eski bir ilan "bugün ilan edildi" gibi görünürdü.
  final String? reason;

  const CommodityNotice({
    required this.titleTr,
    this.titleEn = '',
    this.summaryTr = '',
    this.summaryEn = '',
    this.scopeTr = '',
    this.scopeEn = '',
    required this.nationwide,
    this.termsTr = '',
    this.termsEn = '',
    this.published,
    this.effective,
    this.validUntil,
    this.prices = const [],
    this.pdfUrl,
    this.reason,
  });

  /// Alan yoksa ya da beklenen biçimde değilse null döner.
  ///
  /// İşlem gören fiyatlarda görünüm bu alanı zaten boş bırakıyor; ayrıca
  /// hattın eski sürümüyle yazılmış satırlarda alanların bir kısmı eksik
  /// olabiliyor. Eksik duyuru, bozuk ekrandan iyidir.
  static CommodityNotice? fromJson(dynamic raw) {
    if (raw is! Map) return null;
    final json = raw.cast<String, dynamic>();

    // Başlık yoksa gösterilecek bir duyuru da yok. Hattın eski sürümüyle
    // yazılmış satırlarda bu alan boş olabiliyor.
    final title = json['title']?.toString() ?? '';
    if (title.isEmpty) return null;

    final rawPrices = json['prices'];
    final prices = rawPrices is List
        ? rawPrices
            .whereType<Map>()
            .map((row) => CommodityNoticePrice.fromJson(row.cast<String, dynamic>()))
            .toList()
        : <CommodityNoticePrice>[];

    // Fiyatlar ilanda yazdığı sırayla değil, ucuzdan pahalıya gösteriliyor:
    // kartın rakamı en düşük olan ve listenin başında onu görmek okuyucunun
    // aradığı doğrulamayı ilk satırda veriyor.
    prices.sort((a, b) => a.price.compareTo(b.price));

    return CommodityNotice(
      titleTr: title,
      titleEn: json['title_en']?.toString() ?? '',
      summaryTr: json['summary']?.toString() ?? '',
      summaryEn: json['summary_en']?.toString() ?? '',
      scopeTr: json['scope']?.toString() ?? '',
      scopeEn: json['scope_en']?.toString() ?? '',
      nationwide: json['nationwide'] == true,
      termsTr: json['terms']?.toString() ?? '',
      termsEn: json['terms_en']?.toString() ?? '',
      published: DateTime.tryParse(json['published']?.toString() ?? ''),
      effective: DateTime.tryParse(json['effective']?.toString() ?? ''),
      validUntil: DateTime.tryParse(json['valid_until']?.toString() ?? ''),
      prices: prices,
      pdfUrl: json['pdf_url']?.toString(),
      reason: json['reason']?.toString(),
    );
  }
}

/// İlandaki tek bir fiyat: rakam ve hangi şartla geçerli olduğu.
class CommodityNoticePrice {
  final double price;
  final String labelTr;
  final String labelEn;
  final String scopeTr;
  final String scopeEn;

  const CommodityNoticePrice({
    required this.price,
    required this.labelTr,
    this.labelEn = '',
    this.scopeTr = '',
    this.scopeEn = '',
  });

  String label(bool isEn) => isEn && labelEn.isNotEmpty ? labelEn : labelTr;
  String scope(bool isEn) => isEn && scopeEn.isNotEmpty ? scopeEn : scopeTr;

  factory CommodityNoticePrice.fromJson(Map<String, dynamic> json) {
    return CommodityNoticePrice(
      price: CommodityPrice._toDouble(json['price']) ?? 0.0,
      labelTr: json['label']?.toString() ?? '',
      labelEn: json['label_en']?.toString() ?? '',
      scopeTr: json['scope']?.toString() ?? '',
      scopeEn: json['scope_en']?.toString() ?? '',
    );
  }
}
