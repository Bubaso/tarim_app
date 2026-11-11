class NewsArticle {
  final String id;
  final String title;
  final String? titleEn;
  final String content;
  final String? contentEn;
  final String? summary;
  final String? summaryEn;
  final String? imageUrl;

  /// Görselin kaynağı — "AA", "Tarım Pusulası", "sondakika.com".
  /// §8.3: atıfsız görsel yayımlanmaz. Boşsa arayüz künye satırını HİÇ
  /// çizmiyor; boş bir "Fotoğraf:" satırı hiç satır olmamasından kötü.
  final String? imageCredit;

  /// Görselin ne gösterdiği. Belgelenmemişse boş — uydurulmaz.
  final String? imageCaption;
  final List<String>? seoKeywords;
  final String? sourceName;
  final String? sourceUrl;
  final DateTime createdAt;

  /// Haberin KAYNAKTA yayımlandığı gün.
  ///
  /// `createdAt`ten farkı önemli: `createdAt` haberin bizim hattımıza GİRDİĞİ
  /// an, bu alan ise kaynağın onu yayımladığı gün. İkisi arasındaki açıklık
  /// bayatlığın ölçüsü — sabah 09:00'da hatta giren bir haber üç gün önce
  /// yayımlanmış olabilir ve bunu yalnızca bu alan söylüyor.
  ///
  /// Veritabanında `date` (saat yok), o yüzden gün hassasiyetinde.
  /// 1659 kaydın 1615'inde dolu; eski kayıtlarda boş olabilir.
  final DateTime? publishedAt;

  /// 320×320 kare türev — hikâye baloncuğu ve avatar.
  ///
  /// Boşsa `imageUrl`a düşülüyor. Bu yedek gerçekten devreye giriyor:
  /// türev 6 Kasım 2026'da eklendi, ondan eski haberlerin çoğunda yok.
  final String? thumbImageUrl;

  /// 24 piksellik önizlemenin base64 `data:` URI'si.
  ///
  /// Tek işi görselin rengini İLK KAREDE ekrana koymak. Ağ isteği
  /// gerektirmiyor çünkü satırla birlikte geliyor — ayrı bir dosya olsaydı
  /// çözmeye çalıştığı beklemeyi yeniden üretirdi.
  final String? imageLqip;

  final String? status;
  final String? categoryId;
  final String? geoLocation;
  final int viewCount;
  
  // Yeni eklenen taksonomi alanları
  final String? contentType;
  final String? topic;
  final String? region;
  final int? heroScore;
  final bool? isHero;
  final int? heroOrder;

  /// Editörün haberi manşete ittiği an.
  ///
  /// Sabitleme kalıcı değil, zamanla eriyor; erimenin başlangıcı bu damga.
  /// `createdAt` bu iş için kullanılamaz — eski bir haberi bugün öne çıkarmak
  /// isteyen editörün müdahalesi doğduğu anda ölürdü.
  final DateTime? heroPinnedAt;
  final bool? isBreaking;
  
  // Yeni editoryal alanlar
  final String? spot;
  final String? spotEn;
  final List<String>? keyTakeaways;
  final List<String>? keyTakeawaysEn;
  final String? expertInsight;
  final String? expertInsightEn;
  /// "Türkiye'den haberler" bölümünde 2. sıraya sabitlenmiş haber.
  ///
  /// Manşetin ilk üç slotu `hero_order` ile sabitleniyor; dördüncü yayın
  /// kararı burada. Tek bir haber işaretli olur.
  final bool? turkiyePin;

  /// Süreli anasayfa bölümü işareti — bugünkü tek değeri `'cop31'`.
  ///
  /// [topic] ve [region]'ın YERİNE geçmiyor, ÜSTÜNE biniyor: işaretli haber
  /// Dünya/Türkiye/Hayvancılık kimliğini hiç kaybetmiyor. Bölümün ömrü
  /// `kOzelBolumBitis` sabitinde; süre dolunca işaret okunmaz hâle geliyor ve
  /// haber kendi konu/bölge bölümüne kendiliğinden akıyor. 25 Kasım'da veri
  /// taşımak gerekmemesinin sebebi bu.
  final String? ozelBolum;

  /// Reddin zamanı ve gerekçesi.
  ///
  /// Sütunlar veritabanında vardı ama modele hiç alınmamıştı; red artık
  /// silmek yerine arşivleyen bir durum değişikliği olduğu için
  /// (§29.1) reddedilenler ekranının "ne zaman, neden" sorusuna cevap
  /// verebilmesi gerekiyor. İkisi de null olabilir: toplu red gerekçe
  /// sormuyor ve eski kayıtlarda damga yok.
  final DateTime? rejectedAt;
  final String? rejectionReason;

  /// Muhabir ajanının ürettiği doğrulama verisi (§29.2).
  ///
  /// Bunlar hat içinde kullanılıp ATILIYORDU; kararı veren kişi görmüyordu.
  /// `facts` 5N1K sözlüğü, `figures` [{label,value,unit,period,source}],
  /// `quotes` [{speaker,title,text}]. Eski kayıtlarda null.
  final Map<String, dynamic>? facts;
  final List<dynamic>? figures;
  final List<dynamic>? quotes;

  final Map<String, dynamic>? chartData;

  /// `chartData`'nın İngilizcesi. null ise İngilizce sayfa Türkçesini gösteriyor.
  ///
  /// Çeviri hattında doğrulamadan geçemeyen grafik ÇEVRİLMİYOR (bkz.
  /// `chart_translate.py`): tablodaki bir rakam çeviride değişmişse yarısı
  /// çevrilmiş bir tablo göstermektense hepsini Türkçe bırakmak dürüst olan.
  final Map<String, dynamic>? chartDataEn;

  /// Editörün verdiği biçim kararı: `'kisa'` ya da `'tam'`.
  ///
  /// Eski hattan gelen 507 haberde `null`; [isBrief] onları tam haber sayıyor.
  final String? articleFormat;

  /// Kısa haber mi — ara başlıksız, çıkarımsız, analizsiz, grafiksiz.
  ///
  /// Karar Python tarafında bir kez veriliyor ve sütun olarak taşınıyor.
  /// Uygulamada "çıkarım listesi boşsa kısadır" diye çıkarım yapmıyoruz:
  /// o kural, modelin alanı doldurmayı unuttuğu haberi de kısa sayardı.
  bool get isBrief => articleFormat == 'kisa';

  NewsArticle({
    required this.id,
    required this.title,
    this.titleEn,
    required this.content,
    this.contentEn,
    this.summary,
    this.summaryEn,
    this.imageUrl,
    this.imageCredit,
    this.imageCaption,
    this.seoKeywords,
    this.sourceName,
    this.sourceUrl,
    required this.createdAt,
    this.publishedAt,
    this.thumbImageUrl,
    this.imageLqip,
    this.status,
    this.categoryId,
    this.geoLocation,
    this.viewCount = 0,
    this.contentType,
    this.topic,
    this.region,
    this.heroScore,
    this.isHero,
    this.heroOrder,
    this.heroPinnedAt,
    this.isBreaking,
    this.spot,
    this.spotEn,
    this.keyTakeaways,
    this.keyTakeawaysEn,
    this.expertInsight,
    this.expertInsightEn,
    this.turkiyePin,
    this.ozelBolum,
    this.rejectedAt,
    this.rejectionReason,
    this.facts,
    this.figures,
    this.quotes,
    this.chartData,
    this.chartDataEn,
    this.articleFormat,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    // Parse SEO Keywords list
    List<String>? keywords;
    if (json['seo_keywords'] != null) {
      if (json['seo_keywords'] is List) {
        keywords = (json['seo_keywords'] as List).map((e) => e.toString()).toList();
      } else if (json['seo_keywords'] is String) {
        // Fallback for string-encoded array
        keywords = [json['seo_keywords'].toString()];
      }
    }
    
    // Parse Key Takeaways lists
    List<String>? takeaways;
    if (json['key_takeaways'] != null && json['key_takeaways'] is List) {
      takeaways = (json['key_takeaways'] as List).map((e) => e.toString()).toList();
    }
    
    List<String>? takeawaysEn;
    if (json['key_takeaways_en'] != null && json['key_takeaways_en'] is List) {
      takeawaysEn = (json['key_takeaways_en'] as List).map((e) => e.toString()).toList();
    }

    return NewsArticle(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      titleEn: json['title_en']?.toString(),
      content: json['content']?.toString() ?? '',
      contentEn: json['content_en']?.toString(),
      summary: json['summary']?.toString(),
      summaryEn: json['summary_en']?.toString(),
      imageUrl: json['image_url']?.toString(),
      imageCredit: json['image_credit']?.toString(),
      imageCaption: json['image_caption']?.toString(),
      seoKeywords: keywords,
      sourceName: json['source_name']?.toString(),
      sourceUrl: json['source_url']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString()) 
          : DateTime.now(),
      // `tryParse`, `parse` DEĞİL: bu alan kaynaktan geliyor ve biçimi
      // garanti değil. Bozuk bir tarih yüzünden haberin TAMAMININ
      // ayrıştırılamaması, tarihin boş kalmasından çok daha kötü.
      publishedAt: DateTime.tryParse(json['published_at']?.toString() ?? ''),
      thumbImageUrl: json['thumb_image_url']?.toString(),
      imageLqip: json['image_lqip']?.toString(),
      status: json['status']?.toString(),
      categoryId: json['category_id']?.toString(),
      geoLocation: json['geo_location']?.toString(),
      viewCount: json['view_count'] != null ? (json['view_count'] as num).toInt() : 0,
      contentType: json['content_type']?.toString(),
      topic: json['topic']?.toString(),
      region: json['region']?.toString(),
      heroScore: json['hero_score'] != null ? (json['hero_score'] as num).toInt() : null,
      isHero: json['is_hero'] as bool?,
      heroOrder: json['hero_order'] != null ? (json['hero_order'] as num).toInt() : null,
      heroPinnedAt: json['hero_pinned_at'] != null
          ? DateTime.tryParse(json['hero_pinned_at'] as String)
          : null,
      isBreaking: json['is_breaking'] as bool?,
      spot: json['spot']?.toString(),
      spotEn: json['spot_en']?.toString(),
      keyTakeaways: takeaways,
      keyTakeawaysEn: takeawaysEn,
      expertInsight: json['expert_insight']?.toString(),
      expertInsightEn: json['expert_insight_en']?.toString(),
      turkiyePin: json['turkiye_pin'] as bool?,
      ozelBolum: json['ozel_bolum']?.toString(),
      rejectedAt: json['rejected_at'] == null
          ? null
          : DateTime.tryParse(json['rejected_at'].toString()),
      rejectionReason: json['rejection_reason']?.toString(),
      facts: json['facts'] as Map<String, dynamic>?,
      figures: json['figures'] as List<dynamic>?,
      quotes: json['quotes'] as List<dynamic>?,
      chartData: json['chart_data'] as Map<String, dynamic>?,
      chartDataEn: json['chart_data_en'] as Map<String, dynamic>?,
      articleFormat: json['article_format']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'title_en': titleEn,
      'content': content,
      'content_en': contentEn,
      'summary': summary,
      'summary_en': summaryEn,
      'image_url': imageUrl,
      'image_credit': imageCredit,
      'image_caption': imageCaption,
      'seo_keywords': seoKeywords,
      'source_name': sourceName,
      'source_url': sourceUrl,
      'created_at': createdAt.toIso8601String(),
      'published_at': publishedAt?.toIso8601String(),
      'thumb_image_url': thumbImageUrl,
      'image_lqip': imageLqip,
      'status': status,
      'category_id': categoryId,
      'geo_location': geoLocation,
      'view_count': viewCount,
      'content_type': contentType,
      'topic': topic,
      'region': region,
      'hero_score': heroScore,
      'is_hero': isHero,
      'hero_order': heroOrder,
      'hero_pinned_at': heroPinnedAt?.toIso8601String(),
      'is_breaking': isBreaking,
      'spot': spot,
      'spot_en': spotEn,
      'key_takeaways': keyTakeaways,
      'key_takeaways_en': keyTakeawaysEn,
      'expert_insight': expertInsight,
      'expert_insight_en': expertInsightEn,
      'turkiye_pin': turkiyePin,
      'ozel_bolum': ozelBolum,
      // `rejected_at` ve `rejection_reason` toJson'a BİLEREK girmiyor.
      // İkisini de yazan tek yer `haberiReddet` ve o alan alan yazıyor.
      // toJson'a konsalardı, bu iki alanı taşımayan her çağrı (örneğin
      // yazarın yeni haber göndermesi) reddin kaydını siler ya da
      // sıfırlardı — §25.1'in tam olarak aynı tuzağı.
      'facts': facts,
      'figures': figures,
      'quotes': quotes,
      'chart_data': chartData,
      'chart_data_en': chartDataEn,
      'article_format': articleFormat,
    };
  }

  NewsArticle copyWith({
    String? id,
    String? title,
    String? titleEn,
    String? content,
    String? contentEn,
    String? summary,
    String? summaryEn,
    String? imageUrl,
    List<String>? seoKeywords,
    String? sourceName,
    String? sourceUrl,
    DateTime? createdAt,
    DateTime? publishedAt,
    String? thumbImageUrl,
    String? imageLqip,
    String? status,
    String? categoryId,
    String? geoLocation,
    int? viewCount,
    String? contentType,
    String? topic,
    String? region,
    int? heroScore,
    bool? isHero,
    int? heroOrder,
    DateTime? heroPinnedAt,
    bool? isBreaking,
    String? spot,
    String? spotEn,
    List<String>? keyTakeaways,
    List<String>? keyTakeawaysEn,
    String? expertInsight,
    String? expertInsightEn,
    Map<String, dynamic>? chartData,
    Map<String, dynamic>? chartDataEn,
    String? articleFormat,
  }) {
    return NewsArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      titleEn: titleEn ?? this.titleEn,
      content: content ?? this.content,
      contentEn: contentEn ?? this.contentEn,
      summary: summary ?? this.summary,
      summaryEn: summaryEn ?? this.summaryEn,
      imageUrl: imageUrl ?? this.imageUrl,
      seoKeywords: seoKeywords ?? this.seoKeywords,
      sourceName: sourceName ?? this.sourceName,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      createdAt: createdAt ?? this.createdAt,
      publishedAt: publishedAt ?? this.publishedAt,
      thumbImageUrl: thumbImageUrl ?? this.thumbImageUrl,
      imageLqip: imageLqip ?? this.imageLqip,
      status: status ?? this.status,
      categoryId: categoryId ?? this.categoryId,
      geoLocation: geoLocation ?? this.geoLocation,
      viewCount: viewCount ?? this.viewCount,
      contentType: contentType ?? this.contentType,
      topic: topic ?? this.topic,
      region: region ?? this.region,
      heroScore: heroScore ?? this.heroScore,
      isHero: isHero ?? this.isHero,
      heroOrder: heroOrder ?? this.heroOrder,
      heroPinnedAt: heroPinnedAt ?? this.heroPinnedAt,
      isBreaking: isBreaking ?? this.isBreaking,
      spot: spot ?? this.spot,
      spotEn: spotEn ?? this.spotEn,
      keyTakeaways: keyTakeaways ?? this.keyTakeaways,
      keyTakeawaysEn: keyTakeawaysEn ?? this.keyTakeawaysEn,
      expertInsight: expertInsight ?? this.expertInsight,
      expertInsightEn: expertInsightEn ?? this.expertInsightEn,
      chartData: chartData ?? this.chartData,
      chartDataEn: chartDataEn ?? this.chartDataEn,
      articleFormat: articleFormat ?? this.articleFormat,
    );
  }
}
