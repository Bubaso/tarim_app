import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// Haberin bilim/rapor içeriği olup olmadığını kapsamlı kontrol eder.
bool _articleIsScience(NewsArticle a) {
  final c = a.contentType?.toLowerCase().trim() ?? '';
  final t = a.topic?.toLowerCase().trim() ?? '';
  // taxonomy fields (yeni haberler)
  if (c == 'tarım-bilim' || c == 'rapor' || c == 'analiz') return true;
  if (t == 'tarım teknolojileri' || t == 'gıda güvenliği') return true;
  // kaynak adı
  if (_isScienceSource(a.sourceName)) return true;
  // başlıkta bilim/teknoloji kelimesi
  final title = a.title.toLowerCase();
  if (title.contains('araştırma') || title.contains('bilim') ||
      title.contains('teknoloji') || title.contains('rapor') ||
      title.contains('analiz') || title.contains('çalışma')) {
    return true;
  }
  return false;
}

/// Haberin Türkiye odaklı olup olmadığını kapsamlı kontrol eder.
bool _articleIsTurkey(NewsArticle a) {
  // 1) Açık taxonomy: region alanı
  if (_isRegionTurkey(a.region)) return true;
  // 2) Kaynak adı Türk medyası
  if (_isTurkeySource(a.sourceName)) return true;
  // 3) WKT koordinat Türkiye içinde
  if (_isGeoTurkey(a.geoLocation)) return true;
  // 4) topic veya title'da Türkiye anahtar kelimesi
  final t = a.topic?.toLowerCase() ?? '';
  final title = a.title.toLowerCase();
  if (t == 'ekonomi' || t == 'hayvancılık' || t == 'bitkisel üretim' || t == 'su ve iklim') {
    // Bu topic'ler çoğunlukla Türkiye haberi — region yoksa varsayılan Türkiye
    if (!_isRegionInternational(a.region) && !_isWorldSource(a.sourceName)) return true;
  }
  if (title.contains('türkiye') || title.contains('türk') || title.contains('ankara') ||
      title.contains('istanbul') || title.contains('çiftçi') || title.contains('konya') ||
      title.contains('antalya') || title.contains('ege') || title.contains('karadeniz')) {
    return true;
  }
  return false;
}

/// Haberin uluslararası (Dünya) odaklı olup olmadığını kontrol eder.
bool _articleIsWorld(NewsArticle a) {
  // 1) region açıkça uluslararası
  if (_isRegionInternational(a.region)) return true;
  // 2) Kaynak adı dünya kaynağı
  if (_isWorldSource(a.sourceName)) return true;
  // 3) topic küresel tarım
  final t = a.topic?.toLowerCase() ?? '';
  if (t == 'küresel tarım') return true;
  // 4) WKT koordinat Türkiye dışında
  if (_isGeoInternational(a.geoLocation)) return true;
  // 5) Başlıkta açık global anahtar kelime (Türkiye kaynağı değilse)
  if (!_isTurkeySource(a.sourceName)) {
    final title = a.title.toLowerCase();
    if (title.contains('küresel') || title.contains('global') ||
        title.contains('avrupa') || title.contains('dünya fiyat') ||
        title.contains('brezilya') || title.contains('hindistan') ||
        title.contains('abd') || title.contains('rusya') ||
        title.contains('ukrayna') || title.contains('çin')) {
      return true;
    }
  }
  return false;
}

// ─── PORTAL SECTION PROVIDERS ──────────────────────────────────────────────────

/// Manşet haberleri (Hero Section)
/// Tüm yayınlanmış, görseli olan haberler — zaman-ağırlıklı skor ile sıralı.
/// Türkiye haberleri ağırlıklı, dünyadan 1-2, bilim/rapor 1 adet.
final heroArticlesProvider = Provider<List<NewsArticle>>((ref) {
  final articlesAsync = ref.watch(latestArticlesProvider);
  return articlesAsync.when(
    data: (articles) {
      // Sadece published + görseli olan haberler
      final withImages = articles.where((a) =>
          a.status == 'published' &&
          a.imageUrl != null &&
          a.imageUrl!.isNotEmpty).toList();

      if (withImages.isEmpty) return [];

      // Zaman-ağırlıklı skor hesaplama (yeni + önemli haber önce)
      double heroScore(NewsArticle a) {
        final ageHours = DateTime.now().difference(a.createdAt).inHours;
        return (a.heroScore ?? 5) / math.pow(ageHours + 1, 1.5);
      }

      final manualHeroArticles = withImages.where((a) => a.isHero == true).toList();
      manualHeroArticles.sort((a, b) => (a.heroOrder ?? 999).compareTo(b.heroOrder ?? 999));

      final List<NewsArticle> hero = List.from(manualHeroArticles);
      final seen = hero.map((e) => e.id).toSet();
      
      if (hero.length < 12) {
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

        if (scienceBucket.isNotEmpty && hero.length < 12) hero.add(scienceBucket.first);
        if (hero.length < 12) hero.addAll(worldBucket.take(math.min(2, 12 - hero.length)));
        if (hero.length < 12) hero.addAll(turkeyBucket.take(math.min(8, 12 - hero.length)));
        if (hero.length < 12) hero.addAll(generalBucket.take(12 - hero.length));
        if (hero.length < 12) {
           final stillSeen = hero.map((e) => e.id).toSet();
           hero.addAll(remaining.where((a) => !stillSeen.contains(a.id)).take(12 - hero.length));
        }

        // Kalan (dinamik) olanları skorlarına göre sırala ama manuel olanları üstte tut
        final dynamicPart = hero.sublist(manualHeroArticles.length);
        dynamicPart.sort((a, b) => heroScore(b).compareTo(heroScore(a)));
        
        hero.replaceRange(manualHeroArticles.length, hero.length, dynamicPart);
      }

      return hero.take(12).toList();
    },
    loading: () => [],
    error: (e, s) => [],
  );
});

/// Türkiye'den Haberler
/// Bilim ve kesinlikle uluslararası haberler hariç, geri kalanı Türkiye haberi sayılır.
final turkeyNewsProvider = Provider<List<NewsArticle>>((ref) {
  final articlesAsync = ref.watch(latestArticlesProvider);
  return articlesAsync.when(
    data: (articles) {
      return articles.where((a) {
        if (a.status != 'published') return false;
        // Bilim haberleri kendi bölümüne gidiyor
        if (_articleIsScience(a)) return false;
        // Kesinlikle uluslararası olanlar dışarı
        if (_articleIsWorld(a) && !_articleIsTurkey(a)) return false;
        // Türkiye kontrolü
        return _articleIsTurkey(a);
      }).toList();
    },
    loading: () => [],
    error: (e, s) => [],
  );
});

/// Dünyadan Haberler (Türkiye dışı)
final worldNewsProvider = Provider<List<NewsArticle>>((ref) {
  final articlesAsync = ref.watch(latestArticlesProvider);
  return articlesAsync.when(
    data: (articles) {
      return articles.where((a) {
        if (a.status != 'published') return false;
        if (_articleIsScience(a)) return false;
        if (_articleIsTurkey(a)) return false;
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

      // Hayvancılık kategorisi için özgün bileşik kelimeler
      // (Tek heceli veya başka kategorilere giren kelimeler yok)
      const livestockKws = [
        'büyükbaş', 'küçükbaş', 'sığır', 'koyun', 'keçi',
        'kümes hayvan', 'kanatlı hayvan', 'besi hayvan',
        'hayvancılık', 'çiftlik hayvanı',
        'süt üretimi', 'süt inekleri', 'et üretimi',
        'balıkçılık', 'aquakültür', 'yem fiyat', 'hayvan yemi',
        'çiğ süt fiyat', 'inek sütü', 'hayvan hastalık',
        'şap hastalık', 'kuş gribi', 'avian influenza',
        'besilik', 'süt verimi', 'canlı hayvan', 'kesimlik',
        'kırmızı et fiyat', 'beyaz et fiyat',
      ];

      // Bitkisel üretim için özgün kelimeler
      // 'pirinç', 'çeltik' burada — hayvancılıkla çakışmaz
      const bitkiselKelimeler = [
        'buğday', 'arpa', 'mısır', 'çeltik', 'pirinç', 'tahıl',
        'hububat', 'nohut', 'mercimek', 'fasulye', 'soya', 'kanola',
        'hasat', 'ekim alanı', 'rekolte', 'tarla', 'toprak sağlığı',
        'gübre fiyat', 'mazot fiyat', 'sulama sistemi', 'bitki zararlı',
        'don hasarı', 'kuraklık zararı', 'tarım arazisi',
        'mibzer', 'biçerdöver', 'buğday fiyat', 'arpa fiyat',
        'mısır fiyat', 'ürün verimi', 'verim kaybı',
        'zeytin', 'pamuk', 'şeker pancarı', 'tütün', 'fındık',
        'kiraz', 'elma', 'domates', 'biber', 'salatalık',
      ];

      // Ekonomi kategorisi — fiyat + politika + ticaret
      const ekonomiKelimeler = [
        'ihracat rakam', 'ithalat rakam',
        'piyasa fiyat', 'borsada', 'enflasyon',
        'destek ödemesi', 'tarımsal kredi', 'kooperatif',
        'sübvansiyon', 'tarım politika', 'gümrük vergisi',
        'tarım ticareti', 'tarım bütçe', 'üretici fiyat',
        'taban fiyat', 'alım fiyat', 'çiftçi destekle',
        'tarımsal gelir', 'tarım sigortası',
      ];

      return articles.where((a) {
        if (a.status != 'published') return false;

        final articleTopic = a.topic?.toLowerCase().trim() ?? '';

        // 1) topic alanı pipeline tarafından set edilmişse direkt kullan
        if (articleTopic.isNotEmpty && articleTopic != 'genel') {
          return articleTopic == searchTopic;
        }

        // 2) topic yok/genel → başlık + özet üzerinden kesin kelime eşleşmesi
        final text = '${a.title} ${a.summary ?? ''}'.toLowerCase();

        if (searchTopic == 'hayvancılık') {
          return livestockKws.any((kw) => text.contains(kw));
        } else if (searchTopic == 'bitkisel üretim') {
          // Önce hayvancılık kelimeleri yoksa bitkisel üretim olabilir (çakışma önleme)
          final isHayvancilik = livestockKws.any((kw) => text.contains(kw));
          if (isHayvancilik) return false;
          return bitkiselKelimeler.any((kw) => text.contains(kw));
        } else if (searchTopic == 'ekonomi') {
          final isHayvancilik = livestockKws.any((kw) => text.contains(kw));
          final isBitkisel = bitkiselKelimeler.any((kw) => text.contains(kw));
          if (isHayvancilik || isBitkisel) return false;
          return ekonomiKelimeler.any((kw) => text.contains(kw));
        }

        return false;
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
