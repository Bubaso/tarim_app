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

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return HomeRepository(supabaseClient);
});

class ReadArticlesNotifier extends Notifier<Set<String>> {
  static const _key = 'read_articles';

  @override
  Set<String> build() {
    _loadReadArticles();
    return {};
  }

  Future<void> _loadReadArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    state = list.toSet();
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

/// Stream provider for realtime listening to pending articles from Supabase.
final pendingArticlesProvider = StreamProvider<List<NewsArticle>>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.watchPendingArticles();
});

// ─── KAYNAK / TAKSONOMİ SINIFLANDIRMA ─────────────────────────────────────────
//
// Pipeline'dan gelen source_name değerleri (agency_fetcher.py'deki feed isimleri):
//   Türkiye yerel kaynaklar:
//     Bloomberg HT, Hürriyet Ekonomi, Sabah Ekonomi, Dünya Gazetesi,
//     AA Tarım & Ekonomi, Milliyet Ekonomi, NTV Ekonomi,
//     Tarım Dünyası, GıdaTarım, Tarım Pusulası, TarımTR,
//     TMO, TZOB, Pankobirlik, Türkşeker, Türkşeker Duyurular
//   Uluslararası / Bilim kaynakları:
//     FAO Global News, EFSA News, EFSA Publications, IARC News, IARC Basın,
//     Food Safety News, ScienceDaily Beslenme, Food Chemistry Journal, Nature Food,
//     PubMed — Aspartam & Sağlık, PubMed — Yapay Tatlandırıcı & Bağırsak,
//     PubMed — YYT & Kanser, PubMed — Sukraloz & DNA

/// Türkiye yerel medya/kaynak adları (küçük harf karşılaştırma için)
const _turkeySourceSet = {
  'bloomberg ht',
  'hürriyet ekonomi',
  'sabah ekonomi',
  'dünya gazetesi',
  'aa tarım & ekonomi',
  'milliyet ekonomi',
  'ntv ekonomi',
  'tarım dünyası',
  'gıdatarım',
  'tarım pusulası',
  'tarımtr',
  'tmo',
  'tzob',
  'pankobirlik',
  'türkşeker',
  'türkşeker duyurular',
};

/// Bilim / Rapor kaynakları
const _scienceSourceSet = {
  'efsa news',
  'efsa publications',
  'iarc news',
  'iarc basın',
  'food safety news',
  'sciencedaily beslenme',
  'food chemistry journal',
  'nature food',
};

/// Uluslararası (Dünya) kaynakları
const _worldSourceSet = {
  'fao global news',
};

bool _isTurkeySource(String? sourceName) {
  if (sourceName == null || sourceName.isEmpty) return false;
  return _turkeySourceSet.contains(sourceName.toLowerCase().trim());
}

bool _isScienceSource(String? sourceName) {
  if (sourceName == null || sourceName.isEmpty) return false;
  final lower = sourceName.toLowerCase().trim();
  if (_scienceSourceSet.contains(lower)) return true;
  if (lower.startsWith('pubmed')) return true;
  return false;
}

bool _isWorldSource(String? sourceName) {
  if (sourceName == null || sourceName.isEmpty) return false;
  return _worldSourceSet.contains(sourceName.toLowerCase().trim());
}

/// region alanı veya geo_location WKT koordinatından Türkiye tespiti.
/// Pipeline'dan gelen region değerleri: 'Türkiye', 'Avrupa', 'Amerika', 'Asya', 'Afrika', 'Global'
bool _isRegionTurkey(String? region) {
  if (region == null || region.isEmpty) return false;
  final r = region.toLowerCase().trim();
  return r == 'türkiye' || r == 'turkey';
}

bool _isRegionInternational(String? region) {
  if (region == null || region.isEmpty) return false;
  final r = region.toLowerCase().trim();
  // 'global', 'avrupa', 'amerika', 'asya', 'afrika' → uluslararası
  return r != 'türkiye' && r != 'turkey';
}

/// WKT POINT(lon lat) formatından Türkiye koordinat kontrolü
/// Türkiye: lon 25-45, lat 35.5-42.5
bool _isGeoTurkey(String? geoLocation) {
  if (geoLocation == null || geoLocation.isEmpty) return false;
  final lower = geoLocation.toLowerCase().trim();
  if (!lower.startsWith('point(')) return false;
  try {
    final inner = geoLocation.substring(6, geoLocation.length - 1);
    final parts = inner.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      final lon = double.parse(parts[0]);
      final lat = double.parse(parts[1]);
      return lon >= 25.0 && lon <= 45.0 && lat >= 35.5 && lat <= 42.5;
    }
  } catch (_) {}
  return false;
}

bool _isGeoInternational(String? geoLocation) {
  if (geoLocation == null || geoLocation.isEmpty) return false;
  final lower = geoLocation.toLowerCase().trim();
  if (!lower.startsWith('point(')) return false;
  try {
    final inner = geoLocation.substring(6, geoLocation.length - 1);
    final parts = inner.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      final lon = double.parse(parts[0]);
      final lat = double.parse(parts[1]);
      return !(lon >= 25.0 && lon <= 45.0 && lat >= 35.5 && lat <= 42.5);
    }
  } catch (_) {}
  return false;
}

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

/// Manşet haberleri (Hero Section)
/// Tüm yayınlanmış, görseli olan haberler — zaman-ağırlıklı skor ile sıralı.
/// Türkiye haberleri ağırlıklı, dünyadan 1-2, bilim/rapor 1 adet.
final heroArticlesProvider = Provider<List<NewsArticle>>((ref) {
  final articlesAsync = ref.watch(latestArticlesProvider);
  final readIds = ref.watch(readArticlesProvider);

  return articlesAsync.when(
    data: (articles) {
      // Sadece published + görseli olan haberler
      final withImages = articles.where((a) =>
          a.status == 'published' &&
          a.imageUrl != null &&
          a.imageUrl!.isNotEmpty).toList();

      if (withImages.isEmpty) return [];

      // Zaman-ağırlıklı ve okunma durumuna bağlı akıllı skor hesaplama
      double heroScore(NewsArticle a) {
        final ageHours = DateTime.now().difference(a.createdAt).inHours;
        double score = (a.heroScore ?? 5) / math.pow(ageHours + 1, 1.5);
        
        // Strateji 2: Okunanları Geri İtme
        if (readIds.contains(a.id)) {
          score = score * 0.3; // Okunanlara %70 ceza
        } else if (score > 2) {
          // Strateji 1: Mikro-Karıştırma (Okunmamış ve kaliteli olanlar için)
          // Saate bağlı ufak bir rastgelelik ekleyerek vitrini canlı tut
          final hour = DateTime.now().hour;
          final hash = a.id.hashCode ^ hour;
          final noise = (hash % 100) / 1000.0; // 0.0 - 0.1 arası
          score += noise;
        }
        
        return score;
      }

      final manualHeroArticles = withImages.where((a) => a.isHero == true).toList();
      manualHeroArticles.sort((a, b) => (a.heroOrder ?? 999).compareTo(b.heroOrder ?? 999));

      final List<NewsArticle> hero = List.from(manualHeroArticles);
      final seen = hero.map((e) => e.id).toSet();
      
      const int heroLimit = 10;
      
      if (hero.length < heroLimit) {
        final remaining = withImages.where((a) => !seen.contains(a.id)).toList();
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

        // Kalan (dinamik) olanları skorlarına göre sırala ama manuel olanları üstte tut
        final dynamicPart = hero.sublist(manualHeroArticles.length);
        dynamicPart.sort((a, b) => heroScore(b).compareTo(heroScore(a)));
        
        hero.replaceRange(manualHeroArticles.length, hero.length, dynamicPart);
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
  @override
  LocationData build() {
    return const LocationData(
      name: 'Polatlı, Ankara',
      latitude: 39.58,
      longitude: 32.14,
    );
  }

  void update(LocationData value) {
    state = value;
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
