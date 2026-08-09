import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/supabase_client.dart';
import '../../../core/utils/localization_helper.dart';
import '../data/models/ai_suggestion.dart';
import '../data/models/news_article.dart';
import '../data/models/weather_info.dart';
import '../data/models/market_data.dart';
import '../data/repositories/home_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return HomeRepository(supabaseClient);
});

final initialReadArticlesProvider = FutureProvider<Set<String>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final list = prefs.getStringList('read_articles') ?? [];
  return list.toSet();
});

class ReadArticlesNotifier extends Notifier<Set<String>> {
  static const _key = 'read_articles';

  @override
  Set<String> build() {
    // Get initial state from the FutureProvider if available
    final initial = ref.watch(initialReadArticlesProvider).valueOrNull;
    return initial ?? {};
  }

  Future<void> markAsRead(String id) async {
    if (state.contains(id)) return;
    
    final newState = {...state, id};
    state = newState;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, newState.toList());
  }
}

final readArticlesProvider = NotifierProvider<ReadArticlesNotifier, Set<String>>(ReadArticlesNotifier.new);

/// Stream provider for realtime listening to articles from Supabase.
final latestArticlesProvider = StreamProvider<List<NewsArticle>>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.watchLatestArticles();
});

/// Fetches a single article by id — used for `/haber/:id` deep links.
final articleByIdProvider =
    FutureProvider.family<NewsArticle?, String>((ref, id) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.fetchArticleById(id);
});

/// Stream provider for realtime listening to pending articles from Supabase.
final pendingArticlesProvider = StreamProvider<List<NewsArticle>>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.watchPendingArticles();
});

// ─── KAYNAK / TAKSONOMİ SINIFLANDIRMA ─────────────────────────────────────────
//
// Sınıflandırma artık kaynak adı listelerine değil, pipeline'ın yazdığı
// `topic` ve `region` alanlarına bakarak yapılıyor.

/// Haberin bilim/rapor içeriği olup olmadığını kontrol eder.
bool _articleIsScience(NewsArticle a) {
  final t = a.topic?.toLowerCase().trim() ?? '';
  return t == 'tarım-bilim' || t == 'yyt';
}

/// Haberin Türkiye odaklı olup olmadığını kontrol eder.
bool _articleIsTurkey(NewsArticle a) {
  final r = a.region?.toLowerCase().trim() ?? '';
  return r == 'türkiye';
}

/// Haberin uluslararası (Dünya) odaklı olup olmadığını kontrol eder.
bool _articleIsWorld(NewsArticle a) {
  final r = a.region?.toLowerCase().trim() ?? '';
  return r == 'dünya' || r == 'uluslararası' || r == 'küresel';
}

// ─── PORTAL SECTION PROVIDERS ──────────────────────────────────────────────────

final _sessionHeroSeed = math.Random().nextInt(1000000);

/// Manşet haberleri (Hero Section)
/// Tüm yayınlanmış, görseli olan haberler — zaman-ağırlıklı skor ile sıralı.
/// Türkiye haberleri ağırlıklı, dünyadan 1-2, bilim/rapor 1 adet.
final heroArticlesProvider = Provider<List<NewsArticle>>((ref) {
  final articlesAsync = ref.watch(latestArticlesProvider);
  
  // Sadece oturum başındaki okuma durumunu alıyoruz. 
  // Böylece uygulama içindeyken okunan haberler sıralamayı anında DEĞİŞTİRMEZ.
  final initialReadIds = ref.watch(initialReadArticlesProvider).valueOrNull ?? {};

  return articlesAsync.when(
    data: (articles) {
      // Sadece published + görseli olan haberler
      final withImages = articles.where((a) =>
          a.status == 'published' &&
          a.imageUrl != null &&
          a.imageUrl!.isNotEmpty).toList();

      if (withImages.isEmpty) return [];

      // Zaman-ağırlıklı ve oturum-sabit skor hesaplama
      double heroScore(NewsArticle a) {
        final ageHours = DateTime.now().difference(a.createdAt).inHours;
        
        // Zaman cezasını biraz yumuşattık (1.5 yerine 0.8 üs) ki haberler hemen ölmesin
        double score = (a.heroScore ?? 5) / math.pow(ageHours + 1, 0.8);
        
        // Sadece DÜN veya ÖNCEKİ GÜNLERDE okunanları aşağı çeker
        if (initialReadIds.contains(a.id)) {
          score = score * 0.1; 
        } else if (ageHours < 24 * 7) {
          // Oturum bazlı sabit rastgelelik (aynı oturumda hep aynı noise değeri)
          final random = math.Random(_sessionHeroSeed ^ a.id.hashCode);
          final noise = random.nextDouble() * 4.0; // 0 ile 4.0 arası rastgele bonus
          score += noise;
        }
        
        return score;
      }

      const int heroLimit = 10;
      final List<NewsArticle> hero = [];
      
      final remaining = List<NewsArticle>.from(withImages);
      remaining.sort((a, b) => heroScore(b).compareTo(heroScore(a)));

      // Bucket'lara ayır
      final turkeyBucket = <NewsArticle>[];
      final worldBucket = <NewsArticle>[];
      final scienceBucket = <NewsArticle>[];
      final generalBucket = <NewsArticle>[];

      for (final a in remaining) {
        final isScience = _articleIsScience(a);
        final isTurkey = _articleIsTurkey(a);
        final isWorld = _articleIsWorld(a);

        if (isScience) {
          scienceBucket.add(a);
        } else if (isWorld && !isTurkey) {
          worldBucket.add(a);
        } else if (isTurkey) {
          turkeyBucket.add(a);
        } else {
          generalBucket.add(a);
        }
      }

      if (scienceBucket.isNotEmpty && hero.length < heroLimit) hero.add(scienceBucket.first);
      if (hero.length < heroLimit) hero.addAll(worldBucket.take(math.min(2, heroLimit - hero.length)));
      if (hero.length < heroLimit) hero.addAll(turkeyBucket.take(math.min(6, heroLimit - hero.length)));
      if (hero.length < heroLimit) hero.addAll(generalBucket.take(heroLimit - hero.length));
      
      if (hero.length < heroLimit) {
         final stillSeen = hero.map((e) => e.id).toSet();
         hero.addAll(remaining.where((a) => !stillSeen.contains(a.id)).take(heroLimit - hero.length));
      }

      return hero.take(heroLimit).toList();
    },
    loading: () => [],
    error: (e, s) => [],
  );
});

/// ICYMI (In Case You Missed It) / Gözden Kaçanlar
/// Strateji 5: Kullanıcının okumadığı, son 1-7 gün arası kaliteli içerikler.
final icymiArticlesProvider = Provider<List<NewsArticle>>((ref) {
  final articlesAsync = ref.watch(latestArticlesProvider);
  final readIds = ref.watch(readArticlesProvider);

  return articlesAsync.when(
    data: (articles) {
      final now = DateTime.now();
      
      final icymi = articles.where((a) {
        if (a.status != 'published') return false;
        if (a.imageUrl == null || a.imageUrl!.isEmpty) return false;
        if (readIds.contains(a.id)) return false; // Okunmamış olmalı
        
        // Sadece son 1-7 gün arasındaki haberler
        final ageHours = now.difference(a.createdAt).inHours;
        return ageHours > 12 && ageHours < (7 * 24);
      }).toList();

      if (icymi.isEmpty) return [];

      // Hero score'a göre yüksekten düşüğe sırala
      icymi.sort((a, b) => (b.heroScore ?? 0).compareTo(a.heroScore ?? 0));
      
      // En iyi 4'ünü al
      return icymi.take(4).toList();
    },
    loading: () => [],
    error: (e, s) => [],
  );
});

/// Türkiye'den Haberler
/// Sadece region (bölge) alanının Türkiye olup olmadığına bakar.
final turkeyNewsProvider = Provider<List<NewsArticle>>((ref) {
  final articlesAsync = ref.watch(latestArticlesProvider);
  return articlesAsync.when(
    data: (articles) {
      return articles.where((a) {
        if (a.status != 'published') return false;
        return _articleIsTurkey(a);
      }).toList();
    },
    loading: () => [],
    error: (e, s) => [],
  );
});

/// Seçtiğimiz Makaleler (Özel Kürasyon - MNT)
final curatedArticlesProvider = Provider<List<NewsArticle>>((ref) {
  final articlesAsync = ref.watch(latestArticlesProvider);
  return articlesAsync.when(
    data: (articles) {
      return articles.where((a) {
        if (a.status != 'published') return false;
        return a.sourceName?.toLowerCase() == 'medical news today';
      }).toList();
    },
    loading: () => [],
    error: (e, s) => [],
  );
});

/// Dünyadan Haberler (Türkiye dışı)
/// Sadece region (bölge) alanının Dünya olup olmadığına bakar.
final worldNewsProvider = Provider<List<NewsArticle>>((ref) {
  final articlesAsync = ref.watch(latestArticlesProvider);
  return articlesAsync.when(
    data: (articles) {
      return articles.where((a) {
        if (a.status != 'published') return false;
        return _articleIsWorld(a);
      }).toList();
    },
    loading: () => [],
    error: (e, s) => [],
  );
});

/// Özel Dosya: Tarım & Bilim (Raporlar, Analizler, Bilim Haberleri)
final scienceAndReportsProvider = Provider<List<NewsArticle>>((ref) {
  final articlesAsync = ref.watch(latestArticlesProvider);
  return articlesAsync.when(
    data: (articles) {
      return articles.where((a) {
        if (a.status != 'published') return false;
        return _articleIsScience(a);
      }).toList();
    },
    loading: () => [],
    error: (e, s) => [],
  );
});

/// Sektörel / Kategori Bazlı Haberler
/// topic alanı (pipeline'dan gelen taxonomy) önce kontrol edilir.
/// topic boşsa başlık + özet üzerinden kesin anahtar kelime eşleşmesi yapılır.
/// Her haber yalnızca ilk eşleşen kategoriye girer — çakışma olmaz.
final categoryArticlesProvider = Provider.family<List<NewsArticle>, String>((ref, topic) {
  final articlesAsync = ref.watch(latestArticlesProvider);
  return articlesAsync.when(
    data: (articles) {
      final searchTopic = topic.toLowerCase().trim();

      return articles.where((a) {
        if (a.status != 'published') return false;
        final articleTopic = a.topic?.toLowerCase().trim() ?? '';
        return articleTopic == searchTopic;
      }).toList();
    },
    loading: () => [],
    error: (e, s) => [],
  );
});

class LocationData {
  final String name;
  final double latitude;
  final double longitude;

  const LocationData({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

class ActiveLocationNotifier extends Notifier<LocationData> {
  bool _hasAttemptedDetection = false;

  @override
  LocationData build() {
    if (!_hasAttemptedDetection) {
      _hasAttemptedDetection = true;
      Future.microtask(_detectLocation);
    }
    return const LocationData(
      name: 'Polatlı, Ankara',
      latitude: 39.58,
      longitude: 32.14,
    );
  }

  void update(LocationData value) {
    state = value;
  }

  Future<void> _detectLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );

      final isEn = ref.read(localeProvider).languageCode == 'en';
      String name = isEn ? 'GPS Location' : 'GPS Konumu';
      
      try {
        final res = await http.get(
          Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json&accept-language=${isEn ? "en" : "tr"}'),
          headers: {'User-Agent': 'tarim_app_agent'},
        ).timeout(const Duration(seconds: 3));
        
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final address = data['address'];
          if (address != null) {
            name = address['suburb'] ?? address['town'] ?? address['district'] ?? address['city'] ?? address['province'] ?? name;
            final prov = address['province'] ?? address['state'] ?? '';
            if (prov.isNotEmpty && !name.contains(prov)) {
              name = '$name, $prov';
            }
          }
        }
      } catch (_) {}

      state = LocationData(
        name: name,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      // Ignore errors, keep default location
    }
  }
}

/// State provider for tracking active weather location. Defaults to Polatlı, Ankara.
final activeLocationProvider = NotifierProvider<ActiveLocationNotifier, LocationData>(
  ActiveLocationNotifier.new,
);

/// Future provider for fetching agricultural weather info, reacting to locale & location changes.
final weatherProvider = FutureProvider<WeatherInfo>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  final locale = ref.watch(localeProvider);
  final location = ref.watch(activeLocationProvider);
  return repository.fetchAgricultureWeather(
    locale.languageCode,
    latitude: location.latitude,
    longitude: location.longitude,
    cityName: location.name,
  );
});

/// Future provider for fetching market commodity prices, reacting to locale changes.
final marketProvider = FutureProvider<MarketResult>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  final locale = ref.watch(localeProvider);
  return repository.fetchMarketPrices(locale.languageCode);
});

/// Future provider for fetching pending AI suggestions.
final pendingSuggestionsProvider = FutureProvider<List<AiSuggestion>>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.fetchPendingSuggestions();
});

/// Future provider for searching articles by query
final searchArticlesProvider = FutureProvider.family<List<NewsArticle>, String>((ref, query) {
  if (query.isEmpty) return Future.value([]);
  final repository = ref.watch(homeRepositoryProvider);
  return repository.searchArticles(query);
});

/// Stream provider for top trending articles
final trendingArticlesProvider = StreamProvider<List<NewsArticle>>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.watchTrendingArticles();
});

/// Stream provider for YYT (Yüksek Yoğunluklu Tatlandırıcılar) category articles
final yytArticlesProvider = StreamProvider<List<NewsArticle>>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.watchYYTArticles();
});
