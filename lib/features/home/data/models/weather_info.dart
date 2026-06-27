class DailyForecastItem {
  final String date;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;
  final double et0;

  DailyForecastItem({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
    required this.et0,
  });

  factory DailyForecastItem.fromJson(Map<String, dynamic> json) {
    return DailyForecastItem(
      date: json['date'] as String? ?? '',
      maxTemp: (json['max_temp'] as num?)?.toDouble() ?? 0.0,
      minTemp: (json['min_temp'] as num?)?.toDouble() ?? 0.0,
      weatherCode: json['weather_code'] as int? ?? 0,
      et0: (json['et0'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'max_temp': maxTemp,
      'min_temp': minTemp,
      'weather_code': weatherCode,
      'et0': et0,
    };
  }
}

class HistoricalInfo {
  final double lastYearMaxTemp;
  final double lastYearMinTemp;
  final double lastYearEt0;

  HistoricalInfo({
    required this.lastYearMaxTemp,
    required this.lastYearMinTemp,
    required this.lastYearEt0,
  });

  factory HistoricalInfo.fromJson(Map<String, dynamic> json) {
    return HistoricalInfo(
      lastYearMaxTemp: (json['last_year_max_temp'] as num?)?.toDouble() ?? 0.0,
      lastYearMinTemp: (json['last_year_min_temp'] as num?)?.toDouble() ?? 0.0,
      lastYearEt0: (json['last_year_et0'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'last_year_max_temp': lastYearMaxTemp,
      'last_year_min_temp': lastYearMinTemp,
      'last_year_et0': lastYearEt0,
    };
  }
}

class WeatherInfo {
  final double temperature;
  final double relativeHumidity;
  final double windSpeed;
  final double soilTemperature;
  final double soilMoisture;
  final double evapotranspiration;
  final String city;
  final String description;
  final String iconCode;
  final String agriculturalWarning;
  final bool hasWarning;
  final List<DailyForecastItem> dailyForecast;
  final HistoricalInfo? historicalInfo;

  WeatherInfo({
    required this.temperature,
    required this.relativeHumidity,
    required this.windSpeed,
    required this.soilTemperature,
    required this.soilMoisture,
    required this.evapotranspiration,
    required this.city,
    required this.description,
    required this.iconCode,
    required this.agriculturalWarning,
    required this.hasWarning,
    required this.dailyForecast,
    this.historicalInfo,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    final forecastList = json['daily_forecast'] as List?;
    final daily = forecastList != null
        ? forecastList.map((item) => DailyForecastItem.fromJson(item as Map<String, dynamic>)).toList()
        : <DailyForecastItem>[];

    return WeatherInfo(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      relativeHumidity: (json['relative_humidity'] as num?)?.toDouble() ?? 0.0,
      windSpeed: (json['wind_speed'] as num?)?.toDouble() ?? 0.0,
      soilTemperature: (json['soil_temperature'] as num?)?.toDouble() ?? 0.0,
      soilMoisture: (json['soil_moisture'] as num?)?.toDouble() ?? 0.0,
      evapotranspiration: (json['evapotranspiration'] as num?)?.toDouble() ?? 0.0,
      city: json['city']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      iconCode: json['icon_code']?.toString() ?? '01d',
      agriculturalWarning: json['agricultural_warning']?.toString() ?? '',
      hasWarning: json['has_warning'] as bool? ?? false,
      dailyForecast: daily,
      historicalInfo: json['historical_info'] != null
          ? HistoricalInfo.fromJson(json['historical_info'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'relative_humidity': relativeHumidity,
      'wind_speed': windSpeed,
      'soil_temperature': soilTemperature,
      'soil_moisture': soilMoisture,
      'evapotranspiration': evapotranspiration,
      'city': city,
      'description': description,
      'icon_code': iconCode,
      'agricultural_warning': agriculturalWarning,
      'has_warning': hasWarning,
      'daily_forecast': dailyForecast.map((item) => item.toJson()).toList(),
      'historical_info': historicalInfo?.toJson(),
    };
  }
}
