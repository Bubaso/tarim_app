import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ai_suggestion.dart';
import '../models/news_article.dart';
import '../models/weather_info.dart';
import '../models/market_data.dart';


class HomeRepository {
  final SupabaseClient _supabaseClient;

  HomeRepository(this._supabaseClient);

  /// Supabase realtime stream for watching changes to 'articles' table, ordered by 'created_at' descending.
  Stream<List<NewsArticle>> watchLatestArticles() {
    return _supabaseClient
        .from('articles')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((maps) => maps.map((map) => NewsArticle.fromJson(map)).toList());
  }

  /// Searches articles by query using ilike on title, content
  Future<List<NewsArticle>> searchArticles(String query) async {
    try {
      if (query.trim().isEmpty) return [];
      final response = await _supabaseClient
          .from('articles')
          .select()
          .or('title.ilike.%$query%,content.ilike.%$query%')
          .eq('status', 'published')
          .order('created_at', ascending: false)
          .limit(20);
      final list = response as List<dynamic>;
      return list.map((map) => NewsArticle.fromJson(map as Map<String, dynamic>)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Search failed: $e');
      }
      return [];
    }
  }

  /// Increments the view count of an article.
  Future<void> incrementArticleViewCount(String id) async {
    try {
      await _supabaseClient.rpc('increment_view_count', params: {'row_id': id});
    } catch (e) {
      // If RPC is not created, fallback to a simple read-and-update (not perfect for concurrency but works if RPC missing)
      try {
        final res = await _supabaseClient.from('articles').select('view_count').eq('id', id).single();
        final currentCount = (res['view_count'] as int?) ?? 0;
        await _supabaseClient.from('articles').update({'view_count': currentCount + 1}).eq('id', id);
      } catch (_) {}
    }
  }

  /// Watches top trending articles ordered by view_count
  Stream<List<NewsArticle>> watchTrendingArticles() {
    return _supabaseClient
        .from('articles')
        .stream(primaryKey: ['id'])
        .eq('status', 'published')
        .order('view_count', ascending: false)
        .order('created_at', ascending: false)
        .limit(10)
        .map((maps) => maps.map((map) => NewsArticle.fromJson(map)).toList());
  }

  /// Fetches agricultural weather data with TR/EN localization.
  /// Uses a safe HTTP call to a public API with an automatic fallback to rich, localized mock data.
  Future<WeatherInfo> fetchAgricultureWeather(
    String lang, {
    required double latitude,
    required double longitude,
    required String cityName,
  }) async {
    final isEn = lang.toLowerCase() == 'en';
    try {
      final url = 'https://api.open-meteo.com/v1/forecast'
          '?latitude=$latitude'
          '&longitude=$longitude'
          '&current=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code,soil_temperature_0_to_7cm,soil_moisture_0_to_1cm'
          '&daily=temperature_2m_max,temperature_2m_min,weather_code,et0_fao_evapotranspiration'
          '&timezone=auto';

      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 4));
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final current = json['current'];
        final dailyData = json['daily'];
        
        final temp = (current['temperature_2m'] as num?)?.toDouble() ?? 22.5;
        final relHumidity = (current['relative_humidity_2m'] as num?)?.toDouble() ?? 60.0;
        final windSpeed = (current['wind_speed_10m'] as num?)?.toDouble() ?? 10.0;
        final code = current['weather_code'] as int? ?? 0;
        final soilTemp = (current['soil_temperature_0_to_7cm'] as num?)?.toDouble() ?? (temp - 2.5);
        final soilMoisture = (current['soil_moisture_0_to_1cm'] as num?)?.toDouble() ?? 0.15;

        double et0 = 4.5;
        if (dailyData != null && dailyData['et0_fao_evapotranspiration'] != null) {
          final et0List = dailyData['et0_fao_evapotranspiration'] as List;
          if (et0List.isNotEmpty) {
            et0 = (et0List[0] as num?)?.toDouble() ?? 4.5;
          }
        }

        final List<DailyForecastItem> dailyForecast = [];
        if (dailyData != null) {
          final times = dailyData['time'] as List? ?? [];
          final maxTemps = dailyData['temperature_2m_max'] as List? ?? [];
          final minTemps = dailyData['temperature_2m_min'] as List? ?? [];
          final weatherCodes = dailyData['weather_code'] as List? ?? [];
          final et0List = dailyData['et0_fao_evapotranspiration'] as List? ?? [];

          for (int i = 0; i < times.length; i++) {
            if (i < maxTemps.length && i < minTemps.length) {
              dailyForecast.add(DailyForecastItem(
                date: times[i]?.toString() ?? '',
                maxTemp: (maxTemps[i] as num?)?.toDouble() ?? 0.0,
                minTemp: (minTemps[i] as num?)?.toDouble() ?? 0.0,
                weatherCode: (weatherCodes.length > i ? weatherCodes[i] as int? : null) ?? 0,
                et0: (et0List.length > i ? et0List[i] as num? : null)?.toDouble() ?? 0.0,
              ));
            }
          }
        }

        HistoricalInfo? historicalInfo;
        try {
          final now = DateTime.now();
          final lastYear = DateTime(now.year - 1, now.month, now.day);
          final dateStr = '${lastYear.year}-${lastYear.month.toString().padLeft(2, '0')}-${lastYear.day.toString().padLeft(2, '0')}';
          
          final histUrl = 'https://archive-api.open-meteo.com/v1/archive'
              '?latitude=$latitude'
              '&longitude=$longitude'
              '&start_date=$dateStr'
              '&end_date=$dateStr'
              '&daily=temperature_2m_max,temperature_2m_min,et0_fao_evapotranspiration'
              '&timezone=auto';
          
          final histResponse = await http.get(Uri.parse(histUrl)).timeout(const Duration(seconds: 2));
          if (histResponse.statusCode == 200) {
            final histJson = jsonDecode(histResponse.body);
            final histDaily = histJson['daily'];
            if (histDaily != null) {
              final hMaxList = histDaily['temperature_2m_max'] as List? ?? [];
              final hMinList = histDaily['temperature_2m_min'] as List? ?? [];
              final hEt0List = histDaily['et0_fao_evapotranspiration'] as List? ?? [];
              
              if (hMaxList.isNotEmpty && hMinList.isNotEmpty) {
                historicalInfo = HistoricalInfo(
                  lastYearMaxTemp: (hMaxList[0] as num?)?.toDouble() ?? 0.0,
                  lastYearMinTemp: (hMinList[0] as num?)?.toDouble() ?? 0.0,
                  lastYearEt0: (hEt0List.isNotEmpty ? hEt0List[0] as num? : null)?.toDouble() ?? 0.0,
                );
              }
            }
          }
        } catch (_) {
          // Fall back gracefully if archive API fails
        }

        // Interpret weather code (WMO Weather interpretation codes)
        String description;
        String icon;
        String warning;
        bool hasWarning = false;

        if (code >= 51 && code <= 67) {
          description = isEn ? 'Rainy & Damp' : 'Yağışlı ve Nemli';
          icon = '09d';
          warning = isEn ? 'High Humidity - Watch out for Mildew!' : 'Yüksek Nem - Mildiyö Hastalığına Dikkat!';
          hasWarning = true;
        } else if (code >= 71 && code <= 77) {
          description = isEn ? 'Snowy' : 'Karlı';
          icon = '13d';
          warning = isEn ? 'Severe Frost Risk!' : 'Şiddetli Don Riski!';
          hasWarning = true;
        } else if (code >= 80 && code <= 82) {
          description = isEn ? 'Heavy Rain Showers' : 'Sağnak Yağışlı';
          icon = '09d';
          warning = isEn ? 'Soil Erosion Risk - Avoid Planting' : 'Erozyon Riski - Ekim Yapmaktan Kaçının';
          hasWarning = true;
        } else if (temp < 4.0) {
          description = isEn ? 'Cold & Clear' : 'Soğuk ve Açık';
          icon = '01d';
          warning = isEn ? 'Frost Risk Tonight!' : 'Bu Gece Don Riski Var!';
          hasWarning = true;
        } else {
          description = isEn ? 'Sunny & Warm' : 'Güneşli ve Ilık';
          icon = '01d';
          warning = isEn ? 'Good Conditions for Irrigation & Harvest' : 'Sulama ve Hasat İçin Mükemmel Şartlar';
        }

        return WeatherInfo(
          temperature: temp,
          relativeHumidity: relHumidity,
          windSpeed: windSpeed,
          soilTemperature: soilTemp,
          soilMoisture: soilMoisture,
          evapotranspiration: et0,
          city: cityName,
          description: description,
          iconCode: icon,
          agriculturalWarning: warning,
          hasWarning: hasWarning,
          dailyForecast: dailyForecast,
          historicalInfo: historicalInfo,
        );
      }
    } catch (_) {
      // Catch network errors and fall back gracefully
    }

    // Dynamic, realistic localized Fallback
    return WeatherInfo(
      temperature: 24.5,
      relativeHumidity: 62.0,
      windSpeed: 14.0,
      soilTemperature: 22.0,
      soilMoisture: 0.18,
      evapotranspiration: 4.8,
      city: cityName,
      description: isEn ? 'Partly Cloudy' : 'Parçalı Bulutlu',
      iconCode: '03d',
      agriculturalWarning: isEn 
          ? 'Mild wind. Perfect time for spraying pesticide.'
          : 'Hafif rüzgar. İlaçlama için en uygun zaman dilimi.',
      hasWarning: false,
      dailyForecast: List.generate(7, (i) {
        final date = DateTime.now().add(Duration(days: i));
        return DailyForecastItem(
          date: '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
          maxTemp: 26.0 + i,
          minTemp: 15.0 - (i % 2),
          weatherCode: i % 3 == 0 ? 3 : 1,
          et0: 5.0 - (i * 0.2),
        );
      }),
      historicalInfo: HistoricalInfo(
        lastYearMaxTemp: 23.5,
        lastYearMinTemp: 14.0,
        lastYearEt0: 4.2,
      ),
    );
  }

  Future<String> _fetchWithFallback(String url) async {
    // Attempt 1: Direct fetch
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: kIsWeb
            ? null
            : {
                'User-Agent':
                    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
              },
      ).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Direct fetch failed for $url: $e');
      }
    }

    // Attempt 2: CORS Proxy 1 (corsproxy.io)
    try {
      final proxyUrl = 'https://corsproxy.io/?${Uri.encodeComponent(url)}';
      final response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      if (kDebugMode) {
        print('corsproxy.io failed for $url: $e');
      }
    }

    // Attempt 3: CORS Proxy 2 (allorigins)
    try {
      final proxyUrl = 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(url)}';
      final response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      if (kDebugMode) {
        print('allorigins failed for $url: $e');
      }
    }

    // Attempt 4: CORS Proxy 3 (codetabs)
    try {
      final proxyUrl = 'https://api.codetabs.com/v1/proxy?quest=${Uri.encodeComponent(url)}';
      final response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      if (kDebugMode) {
        print('codetabs failed for $url: $e');
      }
    }

    throw Exception('All fetch methods failed');
  }


  Map<String, dynamic> _parseYahooChart(String body) {
    final json = jsonDecode(body);
    final chart = json['chart'];
    if (chart == null) throw Exception('Chart key missing');
    final resultList = chart['result'] as List?;
    if (resultList == null || resultList.isEmpty) throw Exception('Result list empty');
    final result = resultList[0] as Map<String, dynamic>;
    final meta = result['meta'] as Map<String, dynamic>;
    final price = (meta['regularMarketPrice'] as num).toDouble();
    final prevClose = (meta['chartPreviousClose'] as num).toDouble();
    final changePercent = ((price - prevClose) / prevClose) * 100;
    return {
      'price': price,
      'change': changePercent,
    };
  }

  /// Fetches market/bazaar agricultural prices with TR/EN localization.
  /// Fetches real-time tickers from Yahoo Finance and calculates local prices.
  Future<MarketResult> fetchMarketPrices(String lang) async {
    final isEn = lang.toLowerCase() == 'en';
    
    try {
      // Fetch live data from Yahoo Finance
      final usdTryFuture = _fetchWithFallback('https://query1.finance.yahoo.com/v8/finance/chart/USDTRY=X');
      final sbFuture = _fetchWithFallback('https://query1.finance.yahoo.com/v8/finance/chart/SB=F');
      final hoFuture = _fetchWithFallback('https://query1.finance.yahoo.com/v8/finance/chart/HO=F');
      final wheatFuture = _fetchWithFallback('https://query1.finance.yahoo.com/v8/finance/chart/W=F');
      final cornFuture = _fetchWithFallback('https://query1.finance.yahoo.com/v8/finance/chart/C=F');

      // Wait for all to complete
      final results = await Future.wait([
        usdTryFuture,
        sbFuture,
        hoFuture,
        wheatFuture,
        cornFuture,
      ]);

      final usdTryData = _parseYahooChart(results[0]);
      final sbData = _parseYahooChart(results[1]);
      final hoData = _parseYahooChart(results[2]);
      final wheatData = _parseYahooChart(results[3]);
      final cornData = _parseYahooChart(results[4]);

      final usdTry = usdTryData['price'];

      // Wheat: conversion from cents/bushel to USD/Kg (1 bushel of wheat = 27.2155 Kg)
      final wheatUsd = (wheatData['price'] / 100.0) / 27.2155;
      final wheatPrice = isEn ? wheatUsd : wheatUsd * usdTry;

      // Corn: conversion from cents/bushel to USD/Kg (1 bushel of corn = 25.4012 Kg)
      final cornUsd = (cornData['price'] / 100.0) / 25.4012;
      final cornPrice = isEn ? cornUsd : cornUsd * usdTry;

      // Barley: follows Corn changes
      final barleyBaseUsd = 0.20;
      final barleyBaseTry = 6.70;
      final barleyPrice = isEn
          ? barleyBaseUsd * (1 + cornData['change'] / 100.0)
          : barleyBaseTry * (1 + cornData['change'] / 100.0);

      // Urea Fertilizer: follows Heating Oil (energy commodity) changes
      final fertilizerBaseUsd = 435.0;
      final fertilizerBaseTry = 14350.0;
      final fertilizerPrice = isEn
          ? fertilizerBaseUsd * (1 + hoData['change'] / 100.0)
          : fertilizerBaseTry * (1 + hoData['change'] / 100.0);

      // Diesel: Heating Oil price per gallon / 3.78541 * 1.35 * USD/TRY
      final dieselUsd = (hoData['price'] / 3.78541) * 1.35;
      final dieselPrice = isEn ? dieselUsd : dieselUsd * usdTry;

      final sbPrice = sbData['price']; // e.g. 14.24 Cent/Lb
      final lsuPrice = (sbData['price'] * 22.0462) + 120.0; // e.g. 433.90 USD/Ton

      final commodities = [
        MarketData(
          productName: isEn ? 'Bread Wheat' : 'Ekmeklik Buğday',
          price: wheatPrice,
          changePercentage: wheatData['change'],
          unit: isEn ? 'USD/Kg' : 'TL/Kg',
        ),
        MarketData(
          productName: isEn ? 'Grain Corn' : 'Tane Mısır',
          price: cornPrice,
          changePercentage: cornData['change'],
          unit: isEn ? 'USD/Kg' : 'TL/Kg',
        ),
        MarketData(
          productName: isEn ? 'Feed Barley' : 'Yemlik Arpa',
          price: barleyPrice,
          changePercentage: cornData['change'],
          unit: isEn ? 'USD/Kg' : 'TL/Kg',
        ),
        MarketData(
          productName: isEn ? 'Urea Fertilizer' : 'Üre Gübresi',
          price: fertilizerPrice,
          changePercentage: hoData['change'],
          unit: isEn ? 'USD/Ton' : 'TL/Ton',
        ),
        MarketData(
          productName: isEn ? 'Mazot (Diesel)' : 'Mazot (Dizel)',
          price: dieselPrice,
          changePercentage: hoData['change'],
          unit: isEn ? 'USD/Litre' : 'TL/Litre',
        ),
        MarketData(
          productName: isEn ? 'Sugar No.11 (NY)' : 'Şeker No.11 (NY)',
          price: sbPrice,
          changePercentage: sbData['change'],
          unit: 'Cent/Lb',
        ),
        MarketData(
          productName: isEn ? 'Sugar No.5 (LDN)' : 'Şeker No.5 (LDN)',
          price: lsuPrice,
          changePercentage: sbData['change'],
          unit: 'USD/Ton',
        ),
      ];

      return MarketResult(
        commodities: commodities,
        isRealTime: true,
        lastUpdated: DateTime.now(),
      );

    } catch (e) {
      if (kDebugMode) {
        print('fetchMarketPrices failed: $e');
      }
      // Return fallback data with isRealTime: false
      final fallbackList = isEn ? [
        MarketData(productName: 'Bread Wheat', price: 0.29, changePercentage: 1.4, unit: 'USD/Kg'),
        MarketData(productName: 'Grain Corn', price: 0.22, changePercentage: -0.8, unit: 'USD/Kg'),
        MarketData(productName: 'Feed Barley', price: 0.20, changePercentage: 0.5, unit: 'USD/Kg'),
        MarketData(productName: 'Urea Fertilizer', price: 435.0, changePercentage: 2.8, unit: 'USD/Ton'),
        MarketData(productName: 'Mazot (Diesel)', price: 1.28, changePercentage: -1.1, unit: 'USD/Liter'),
        MarketData(productName: 'Sugar No.11 (NY)', price: 19.34, changePercentage: 0.3, unit: 'Cent/Lb'),
        MarketData(productName: 'Sugar No.5 (LDN)', price: 546.40, changePercentage: 0.3, unit: 'USD/Ton'),
      ] : [
        MarketData(productName: 'Ekmeklik Buğday', price: 9.60, changePercentage: 1.4, unit: 'TL/Kg'),
        MarketData(productName: 'Tane Mısır', price: 7.25, changePercentage: -0.8, unit: 'TL/Kg'),
        MarketData(productName: 'Yemlik Arpa', price: 6.70, changePercentage: 0.5, unit: 'TL/Kg'),
        MarketData(productName: 'Üre Gübresi', price: 14350.0, changePercentage: 2.8, unit: 'TL/Ton'),
        MarketData(productName: 'Mazot (Dizel)', price: 42.40, changePercentage: -1.1, unit: 'TL/Litre'),
        MarketData(productName: 'Şeker No.11 (NY)', price: 19.34, changePercentage: 0.3, unit: 'Cent/Lb'),
        MarketData(productName: 'Şeker No.5 (LDN)', price: 546.40, changePercentage: 0.3, unit: 'USD/Ton'),
      ];

      return MarketResult(
        commodities: fallbackList,
        isRealTime: false,
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// Submits a new article by an authenticated author.
  /// Sets status to 'reviewing', image_url to null, and created_at to current time.
  Future<bool> submitArticleByAuthor(NewsArticle article) async {
    try {
      final json = article.toJson();
      json['status'] = 'reviewing';
      json['image_url'] = null;
      json['created_at'] = DateTime.now().toUtc().toIso8601String();

      await _supabaseClient.from('articles').insert(json);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Fetches the list of article assignments from the database.
  Future<List<Map<String, dynamic>>> fetchArticleAssignments() async {
    try {
      final List<dynamic> response = await _supabaseClient
          .from('article_assignments')
          .select('*')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  /// Fetches the list of categories from the database.
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    try {
      final List<dynamic> response = await _supabaseClient
          .from('categories')
          .select('*')
          .order('name', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  /// Fetches pending suggestions from the 'ai_suggestions' table.
  Future<List<AiSuggestion>> fetchPendingSuggestions() async {
    try {
      final response = await _supabaseClient
          .from('ai_suggestions')
          .select('*')
          .eq('status', 'pending')
          .order('created_at', ascending: false);
      
      final list = response as List<dynamic>;
      return list.map((map) => AiSuggestion.fromJson(map as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Updates the status of an AI suggestion.
  Future<bool> updateSuggestionStatus(int id, String status) async {
    try {
      await _supabaseClient
          .from('ai_suggestions')
          .update({'status': status})
          .eq('id', id);
      return true;
    } catch (e) {
      return false;
    }
  }
}
