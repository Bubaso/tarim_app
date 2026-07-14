class NewsArticle {
  final String id;
  final String title;
  final String? titleEn;
  final String content;
  final String? contentEn;
  final String? summary;
  final String? summaryEn;
  final String? imageUrl;
  final List<String>? seoKeywords;
  final String? sourceName;
  final String? sourceUrl;
  final DateTime createdAt;
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
  
  // Yeni editoryal alanlar
  final String? spot;
  final String? spotEn;
  final List<String>? keyTakeaways;
  final List<String>? keyTakeawaysEn;
  final String? expertInsight;
  final String? expertInsightEn;
  final Map<String, dynamic>? chartData;

  NewsArticle({
    required this.id,
    required this.title,
    this.titleEn,
    required this.content,
    this.contentEn,
    this.summary,
    this.summaryEn,
    this.imageUrl,
    this.seoKeywords,
    this.sourceName,
    this.sourceUrl,
    required this.createdAt,
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
    this.spot,
    this.spotEn,
    this.keyTakeaways,
    this.keyTakeawaysEn,
    this.expertInsight,
    this.expertInsightEn,
    this.chartData,
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
      seoKeywords: keywords,
      sourceName: json['source_name']?.toString(),
      sourceUrl: json['source_url']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString()) 
          : DateTime.now(),
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
      spot: json['spot']?.toString(),
      spotEn: json['spot_en']?.toString(),
      keyTakeaways: takeaways,
      keyTakeawaysEn: takeawaysEn,
      expertInsight: json['expert_insight']?.toString(),
      expertInsightEn: json['expert_insight_en']?.toString(),
      chartData: json['chart_data'] as Map<String, dynamic>?,
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
      'seo_keywords': seoKeywords,
      'source_name': sourceName,
      'source_url': sourceUrl,
      'created_at': createdAt.toIso8601String(),
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
      'spot': spot,
      'spot_en': spotEn,
      'key_takeaways': keyTakeaways,
      'key_takeaways_en': keyTakeawaysEn,
      'expert_insight': expertInsight,
      'expert_insight_en': expertInsightEn,
      'chart_data': chartData,
    };
  }
}
