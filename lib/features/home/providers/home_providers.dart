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
