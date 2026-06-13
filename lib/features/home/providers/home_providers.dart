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

/// Future provider for fetching agricultural weather info, reacting to locale changes.
final weatherProvider = FutureProvider<WeatherInfo>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  final locale = ref.watch(localeProvider);
  return repository.fetchAgricultureWeather(locale.languageCode);
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
