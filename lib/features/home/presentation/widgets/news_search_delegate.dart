import 'package:tarim_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/home_providers.dart';
import '../widgets/news_card.dart'; // To use SmallNewsCard or similar, let's use a standard ListTile for simplicity if NewsCard is not easily imported, but we can try importing news_card.dart or just build a custom tile.
import '../../data/models/news_article.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../screens/article_detail_screen.dart';
import '../../../../core/utils/image_fallback_helper.dart';

class NewsSearchDelegate extends SearchDelegate<NewsArticle?> {
  final WidgetRef ref;
  final bool isEn;

  NewsSearchDelegate({required this.ref, required this.isEn}) : super(
    searchFieldLabel: isEn ? 'Search news...' : 'Haberlerde Ara...',
    searchFieldStyle: GoogleFonts.inter(fontSize: 16),
  );

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.darkGreen : AppColors.creamBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return _buildMessage(context, isEn ? 'Enter a keyword to search.' : 'Aramak istediğiniz kelimeyi girin.');
    }

    return Consumer(
      builder: (context, ref, _) {
        final searchAsync = ref.watch(searchArticlesProvider(query));

        return searchAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => _buildMessage(context, isEn ? 'An error occurred: $err' : 'Bir hata oluştu: $err'),
          data: (articles) {
            if (articles.isEmpty) {
              return _buildMessage(context, isEn ? 'No results found for "$query".' : '"$query" için sonuç bulunamadı.');
            }
            return _buildSearchResults(context, articles);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return _buildMessage(context, isEn ? 'Search in news titles or contents.' : 'Haber başlıklarında veya içeriklerinde arama yapın.');
    }
    // Show results directly as suggestions for real-time feel
    return Consumer(
      builder: (context, ref, _) {
        final searchAsync = ref.watch(searchArticlesProvider(query));

        return searchAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => const SizedBox.shrink(),
          data: (articles) {
            if (articles.isEmpty) {
              return _buildMessage(context, isEn ? 'No results found.' : 'Sonuç bulunamadı.');
            }
            return _buildSearchResults(context, articles);
          },
        );
      },
    );
  }

  Widget _buildSearchResults(BuildContext context, List<NewsArticle> articles) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: articles.length,
      separatorBuilder: (_, __) => Divider(color: isDark ? Colors.white10 : Colors.black12),
      itemBuilder: (context, index) {
        final article = articles[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 80,
              height: 80,
              child: NewsArticleImage(
                imageUrl: article.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Text(
            article.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: textColor,
            ),
          ),
          onTap: () {
            pushScreen(context, ArticleDetailScreen(article: article),
            );
          },
        );
      },
    );
  }

  Widget _buildMessage(BuildContext context, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Text(
        message,
        style: GoogleFonts.inter(
          color: isDark ? Colors.white54 : Colors.black54,
          fontSize: 16,
        ),
      ),
    );
  }
}
