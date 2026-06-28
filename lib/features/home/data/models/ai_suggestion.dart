class AiSuggestion {
  final int? id;
  final String suggestedTitle;
  final String suggestionReason;
  final String sourceArticleTitle;
  final String sourceUrl;
  final String status;
  final DateTime? createdAt;

  AiSuggestion({
    this.id,
    required this.suggestedTitle,
    required this.suggestionReason,
    required this.sourceArticleTitle,
    required this.sourceUrl,
    required this.status,
    this.createdAt,
  });

  factory AiSuggestion.fromJson(Map<String, dynamic> json) {
    return AiSuggestion(
      id: json['id'] as int?,
      suggestedTitle: json['suggested_title']?.toString() ?? '',
      suggestionReason: json['suggestion_reason']?.toString() ?? '',
      sourceArticleTitle: json['source_article_title']?.toString() ?? '',
      sourceUrl: json['source_url']?.toString() ?? '',
      status: json['status']?.toString() ?? 'reviewing',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'suggested_title': suggestedTitle,
      'suggestion_reason': suggestionReason,
      'source_article_title': sourceArticleTitle,
      'source_url': sourceUrl,
      'status': status,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
