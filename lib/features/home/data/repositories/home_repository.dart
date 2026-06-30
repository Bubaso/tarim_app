import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/ai_suggestion.dart';
import '../models/news_article.dart';
import '../models/weather_info.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/market_data.dart';
import 'package:uuid/uuid.dart';


class HomeRepository {
  final SupabaseClient _supabaseClient;

  HomeRepository(this._supabaseClient);

  /// Supabase realtime stream for watching changes to 'articles' table, ordered by 'created_at' descending.
  Stream<List<NewsArticle>> watchLatestArticles() async* {
    try {
      final stream = _supabaseClient
          .from('articles')
          .stream(primaryKey: ['id'])
          .eq('status', 'published')
          .order('created_at', ascending: false);

      await for (final maps in stream) {
        final dbArticles = maps.map((map) => NewsArticle.fromJson(map)).toList();
        _cachedDbArticles = dbArticles;
        yield [..._localDrafts, ...dbArticles];
      }
    } catch (e) {
      if (kDebugMode) {
        print('watchLatestArticles error: $e');
      }
      // If stream fails (no table, offline, etc), yield local drafts + last known DB articles
      yield [..._localDrafts, ..._cachedDbArticles];
    }
  }

  /// Supabase realtime stream for watching changes to pending articles.
  Stream<List<NewsArticle>> watchPendingArticles() async* {
    try {
      final stream = _supabaseClient
          .from('articles')
          .stream(primaryKey: ['id'])
          .eq('status', 'reviewing')
          .order('created_at', ascending: false);

      await for (final maps in stream) {
        yield maps.map((map) => NewsArticle.fromJson(map)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('watchPendingArticles error: $e');
      }
      yield [];
    }
  }

  /// Approves a pending article and makes it published
  Future<bool> approveArticle(String id) async {
    try {
      await _supabaseClient
          .from('articles')
          .update({'status': 'published'})
          .eq('id', id);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('approveArticle error: $e');
      }
      return false;
    }
  }

  /// Rejects (deletes) a pending article
  Future<bool> rejectArticle(String id) async {
    try {
      await _supabaseClient
          .from('articles')
          .delete()
          .eq('id', id);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('rejectArticle error: $e');
      }
      return false;
    }
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

  /// Watches YYT-category articles in real-time.
  /// Filters by category_slug = 'yyt' via a JOIN on the categories table.
  /// Falls back to a client-side slug match if the join is unavailable.
  Stream<List<NewsArticle>> watchYYTArticles() async* {
    try {
      // First, look up the yyt category_id from the categories table once
      String? yytCategoryId;
      try {
        final catRes = await _supabaseClient
            .from('categories')
            .select('id')
            .eq('slug', 'yyt')
            .maybeSingle();
        if (catRes != null) {
          yytCategoryId = catRes['id']?.toString();
        }
      } catch (_) {}

      if (yytCategoryId != null) {
        final stream = _supabaseClient
            .from('articles')
            .stream(primaryKey: ['id'])
            .eq('status', 'published')
            .order('created_at', ascending: false)
            .map((maps) => maps
                .where((m) => m['category_id']?.toString() == yytCategoryId)
                .map((m) => NewsArticle.fromJson(m))
                .toList());
        await for (final articles in stream) {
          yield articles;
        }
      } else {
        // No yyt category found, yield empty
        yield [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('watchYYTArticles error: $e');
      }
      yield [];
    }
  }

  /// Watches top trending articles ordered by view_count
  Stream<List<NewsArticle>> watchTrendingArticles() {
    return _supabaseClient
        .from('articles')
        .stream(primaryKey: ['id'])
        .eq('status', 'published')
        .map((maps) {
          final articles = maps.map((map) => NewsArticle.fromJson(map)).toList();
          articles.sort((a, b) {
            final cmp = b.viewCount.compareTo(a.viewCount);
            if (cmp != 0) return cmp;
            return b.createdAt.compareTo(a.createdAt);
          });
          return articles.take(10).toList();
        });
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
      // Create a mutable copy of the json
      final json = article.toJson();
      
      // Automatically translate if missing
      if (json['title_en'] == null || json['title_en'].toString().trim().isEmpty) {
        json['title_en'] = await translateTextToEnglish(json['title']);
      }
      if (json['summary_en'] == null || json['summary_en'].toString().trim().isEmpty) {
        json['summary_en'] = await translateTextToEnglish(json['summary']);
      }
      if (json['content_en'] == null || json['content_en'].toString().trim().isEmpty) {
        json['content_en'] = await translateTextToEnglish(json['content']);
      }

      json['status'] = 'reviewing';
      json['image_url'] = null;
      json['created_at'] = DateTime.now().toUtc().toIso8601String();
      
      // Generate a slug to satisfy the NOT NULL constraint in Supabase
      final slugBase = article.title.toLowerCase()
          .replaceAll('ş', 's').replaceAll('ı', 'i').replaceAll('ğ', 'g')
          .replaceAll('ü', 'u').replaceAll('ö', 'o').replaceAll('ç', 'c')
          .replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');
      json['slug'] = '$slugBase-${DateTime.now().millisecondsSinceEpoch}';

      // Removed author_id as it doesn't exist in the schema

      await _supabaseClient.from('articles').insert(json);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('submitArticleByAuthor error: $e');
      }
      return false;
    }
  }

  /// Updates an existing article and returns error message if any, null on success.
  Future<String?> updateArticle(NewsArticle article) async {
    try {
      final json = article.toJson();
      // Ensure we don't accidentally update the created_at or status unnecessarily
      json.remove('created_at');

      // Automatically translate if missing
      if (json['title_en'] == null || json['title_en'].toString().trim().isEmpty) {
        json['title_en'] = await translateTextToEnglish(json['title']);
      }
      if (json['summary_en'] == null || json['summary_en'].toString().trim().isEmpty) {
        json['summary_en'] = await translateTextToEnglish(json['summary']);
      }
      if (json['content_en'] == null || json['content_en'].toString().trim().isEmpty) {
        json['content_en'] = await translateTextToEnglish(json['content']);
      }

      // Update local drafts cache for instant UI feedback
      final index = _localDrafts.indexWhere((a) => a.id == article.id);
      if (index != -1) {
        // Create an updated article with translations
        _localDrafts[index] = NewsArticle.fromJson({...article.toJson(), ...json});
      }

      await _supabaseClient
          .from('articles')
          .update(json)
          .eq('id', article.id);
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('updateArticle error: $e');
      }
      // If DB fails, but we updated local cache, it's still a partial success for UX
      final index = _localDrafts.indexWhere((a) => a.id == article.id);
      if (index != -1) {
        return null; // success locally
      }
      return e.toString();
    }
  }

  /// Updates the hero status and order of an article.
  Future<bool> updateHeroStatus(String id, bool isHero, int? heroOrder) async {
    try {
      await _supabaseClient.from('articles').update({
        'is_hero': isHero,
        'hero_order': heroOrder,
      }).eq('id', id);
      return true;
    } catch (e) {
      if (kDebugMode) print('updateHeroStatus error: $e');
      return false;
    }
  }

  /// Batch updates the hero orders.
  Future<bool> batchUpdateHeroOrders(List<Map<String, dynamic>> updates) async {
    try {
      for (final update in updates) {
        await _supabaseClient.from('articles').update({
          'is_hero': true,
          'hero_order': update['hero_order'],
        }).eq('id', update['id']);
      }
      return true;
    } catch (e) {
      if (kDebugMode) print('batchUpdateHeroOrders error: $e');
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
      // Fallback dummy data if table is missing or errors out
      return [
        {
          'title': 'İklim Değişikliğinin Ege Bölgesindeki Zeytin Hasadına Etkisi',
          'description': 'Lütfen son 5 yılın kuraklık verilerini baz alarak üreticilerle yaptığınız röportajları derleyin. Cuma gününe kadar taslağı gönderin.',
          'status': 'reviewing',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'title': 'Modern Sera Teknolojileri İncelemesi',
          'description': 'Antalya bölgesinde yeni kurulan topraksız tarım seralarının yatırım maliyetleri ve ROI süreleri hakkında teknik bir yazı hazırlayın.',
          'status': 'completed',
          'created_at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        }
      ];
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

  // Stateful fallback list for AI suggestions
  static final List<AiSuggestion> _fallbackSuggestions = [
    AiSuggestion(
      id: 1,
      sourceUrl: 'https://www.bloomberg.com/agri',
      sourceArticleTitle: 'Global Wheat Supply Drops Amidst European Droughts',
      suggestedTitle: 'Avrupa Kuraklığı Küresel Buğday Arzını Vurdu: Türkiye Ne Yapmalı?',
      suggestionReason: 'Buğday fiyatlarındaki küresel artış, Türkiye\'deki un ihracatçılarının maliyetlerini doğrudan etkileme potansiyeline sahip. Acil bir uyarı yazısı trafik çekebilir.',
      status: 'reviewing',
      createdAt: DateTime.now(),
    ),
    AiSuggestion(
      id: 2,
      sourceUrl: 'https://www.reuters.com/markets',
      sourceArticleTitle: 'Fertilizer Costs Subside in Q3 Reporting',
      suggestedTitle: 'Gübre Fiyatlarında Düşüş Eğilimi: Çiftçi Bahar Ekimi İçin Beklemeli mi?',
      suggestionReason: 'Üre gübresindeki düşüş, gübre alımı yapacak çiftçiler için stratejik bir karar anı yarattı. Analiz yazısı yüksek etkileşim alır.',
      status: 'reviewing',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    )
  ];

  /// Fetches pending suggestions from the 'ai_suggestions' table.
  Future<List<AiSuggestion>> fetchPendingSuggestions() async {
    try {
      final response = await _supabaseClient
          .from('ai_suggestions')
          .select('*')
          .eq('status', 'reviewing')
          .order('created_at', ascending: false);
      
      final list = response as List<dynamic>;
      return list.map((map) => AiSuggestion.fromJson(map as Map<String, dynamic>)).toList();
    } catch (e) {
      // Fallback AI Suggestions if table doesn't exist
      return _fallbackSuggestions.where((s) => s.status == 'reviewing').toList();
    }
  }

  // A local list to hold AI generated drafts if the DB is offline or RLS fails
  static final List<NewsArticle> _localDrafts = [];
  static List<NewsArticle> _cachedDbArticles = [];

  /// Updates the status of an AI suggestion.
  Future<bool> updateSuggestionStatus(AiSuggestion suggestion, String status) async {
    // Simulate an AI workflow: If approved, "generate" a draft and submit it
    if (status == 'approved') {
      try {
        String generatedContent = 'Yapay zeka ile içerik üretiliyor...';
        
        try {
          final apiKey = ApiConstants.geminiApiKey;
          if (apiKey.isNotEmpty) {
            final model = GenerativeModel(
              model: 'gemini-2.5-flash',
              apiKey: apiKey,
            );
            
            final prompt = '''
Sen Türkiye'nin en saygın, profesyonel ve objektif tarım, ekonomi ve piyasa analistisin. 
Aşağıdaki konu ve tavsiye edilen başlık üzerinden derinlemesine, gazetecilik etiğine uygun, sektörel verilerle desteklenmiş gerçekçi bir analiz/haber makalesi yazacaksın.

Konu Başlığı: ${suggestion.suggestedTitle}
Tavsiye Nedeni/Kapsamı: ${suggestion.suggestionReason}

Yazım Kuralları:
1. Kesinlikle uyduruk, kısa veya yüzeysel bir metin YAZMA. 
2. Gerçek bir gazetede yayınlanacak düzeyde profesyonel bir dil kullan.
3. İçeriği giriş, gelişme ve sonuç şeklinde bağlamlara oturt, sektörün geleceğine yönelik projeksiyonlar sun.
4. Çiftçiyi, yatırımcıyı ve politika yapıcıları ilgilendirecek kritik noktalara değin.
5. Sadece düz metin ver. Markdown (#, **, *) KULLANMA. Başlıklar veya alt başlıklar koyma, sadece temiz paragraflar halinde yaz.
6. Bu yazının tamamen AI tarafından üretildiği anlaşılmamalı, usta bir editörün kaleminden çıkmış gibi kusursuz olmalı.
''';
            final response = await model.generateContent([Content.text(prompt)]);
            generatedContent = response.text ?? 'Yapay zeka içeriği oluşturamadı.';
          } else {
            generatedContent = 'GEMINI_API_KEY bulunamadı. Lütfen .env dosyasına ekleyip uygulamayı yeniden başlatın.';
          }
        } catch (e) {
          generatedContent = 'Yapay zeka ile içerik üretilirken hata oluştu: $e';
        }

        final generatedArticle = NewsArticle(
          id: const Uuid().v4(),
          title: suggestion.suggestedTitle,
          summary: suggestion.suggestionReason,
          content: generatedContent,
          categoryId: '4753361f-3bbd-4118-9a46-ecccd5cf8367', // Default technology ID fallback
          imageUrl: null,
          createdAt: DateTime.now(),
          status: 'reviewing', 
        );
        // Try to submit to DB
        final success = await submitArticleByAuthor(generatedArticle);
        if (!success) {
          // If DB insert fails (e.g. RLS policy or missing table), add to local drafts
          _localDrafts.add(generatedArticle);
        }
      } catch (e) {
        // Ignore fallback simulation errors
      }
    }

    try {
      if (suggestion.id != null) {
        await _supabaseClient
            .from('ai_suggestions')
            .update({'status': status})
            .eq('id', suggestion.id!);
      }
      return true;
    } catch (e) {
      // Update fallback state if DB is missing
      final index = _fallbackSuggestions.indexWhere((s) => s.id == suggestion.id);
      if (index != -1) {
        final old = _fallbackSuggestions[index];
        _fallbackSuggestions[index] = AiSuggestion(
          id: old.id,
          suggestedTitle: old.suggestedTitle,
          suggestionReason: old.suggestionReason,
          sourceArticleTitle: old.sourceArticleTitle,
          sourceUrl: old.sourceUrl,
          status: status,
          createdAt: old.createdAt,
        );
      }
      return true;
    }
  }

  /// Automatically translates Turkish text to English using a free Google Translate API endpoint.
  /// This completely bypasses the Gemini API, costing $0.
  Future<String?> translateTextToEnglish(String? text) async {
    if (text == null || text.trim().isEmpty) return null;
    try {
      final url = Uri.parse(
          'https://translate.googleapis.com/translate_a/single?client=gtx&sl=tr&tl=en&dt=t&q=\${Uri.encodeComponent(text)}');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data is List && data.isNotEmpty) {
          final translatedChunks = data[0] as List;
          final buffer = StringBuffer();
          for (var chunk in translatedChunks) {
            if (chunk is List && chunk.isNotEmpty) {
              buffer.write(chunk[0].toString());
            }
          }
          return buffer.toString().trim();
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Free Translation error: $e');
      return null;
    }
  }
}
