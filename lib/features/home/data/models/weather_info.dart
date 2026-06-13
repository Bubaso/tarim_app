class WeatherInfo {
  final double temperature;
  final String city;
  final String description;
  final String iconCode;
  final String agriculturalWarning;
  final bool hasWarning;

  WeatherInfo({
    required this.temperature,
    required this.city,
    required this.description,
    required this.iconCode,
    required this.agriculturalWarning,
    required this.hasWarning,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    return WeatherInfo(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      city: json['city']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      iconCode: json['icon_code']?.toString() ?? '01d',
      agriculturalWarning: json['agricultural_warning']?.toString() ?? '',
      hasWarning: json['has_warning'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'city': city,
      'description': description,
      'icon_code': iconCode,
      'agricultural_warning': agriculturalWarning,
      'has_warning': hasWarning,
    };
  }
}
