import 'package:tarim_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/utils/fade_page_route.dart';
import '../../../../../core/utils/image_fallback_helper.dart';
import '../../../../../core/utils/localization_helper.dart';
import '../../../data/models/news_article.dart';
import '../../screens/article_detail_screen.dart';

class TurkeyNewsGrid extends ConsumerWidget {
  final List<NewsArticle> articles;
  final bool isDark;

  const TurkeyNewsGrid({
    super.key,
    required this.articles,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (articles.isEmpty) return const SizedBox.shrink();
    ref.watch(localeProvider); // Rebuild when language changes
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;
    
    final headerColor = isDark ? AppColors.creamBackground : AppColors.earthText;
    final borderColor = isDark ? AppColors.wheat : const Color(0xFFE5E5E5);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 0.0),
      child: Column(
        children: [
          if (isMobile)
            _MobileGrid(articles: articles, isDark: isDark, borderColor: borderColor)
          else
            _DesktopGrid(articles: articles, isDark: isDark, borderColor: borderColor),
        ],
      ),
    );
  }
}

class _DesktopGrid extends StatelessWidget {
  final List<NewsArticle> articles;
  final bool isDark;
  final Color borderColor;

  const _DesktopGrid({
    required this.articles,
    required this.isDark,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final topTwo = articles.take(2).toList();
    final remaining = articles.skip(2).take(4).toList();

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: topTwo.map((a) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: a == topTwo.last ? 0 : 24),
                child: _TurkeyNewsCard(article: a, isDark: isDark, isLarge: true),
              ),
            );
          }).toList(),
        ),
        if (remaining.isNotEmpty) ...[
          const SizedBox(height: 32),
          Container(height: 1, color: borderColor),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: remaining.map((a) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: a == remaining.last ? 0 : 16),
                  child: _TurkeyNewsCard(article: a, isDark: isDark, isLarge: false),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _MobileGrid extends StatelessWidget {
  final List<NewsArticle> articles;
  final bool isDark;
  final Color borderColor;

  const _MobileGrid({
    required this.articles,
    required this.isDark,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final topArticle = articles.first;
    final remaining = articles.skip(1).take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TurkeyNewsCard(article: topArticle, isDark: isDark, isLarge: true),
        if (remaining.isNotEmpty) ...[
          const SizedBox(height: 24),
          Container(height: 1, color: borderColor),
          const SizedBox(height: 24),
          ...remaining.map((a) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _TurkeyNewsCard(article: a, isDark: isDark, isLarge: false, isRow: true),
            );
          }),
        ],
      ],
    );
  }
}

class _TurkeyNewsCard extends StatefulWidget {
  final NewsArticle article;
  final bool isDark;
  final bool isLarge;
  final bool isRow;

  const _TurkeyNewsCard({
    required this.article,
    required this.isDark,
    required this.isLarge,
    this.isRow = false,
  });

  @override
  State<_TurkeyNewsCard> createState() => _TurkeyNewsCardState();
}

class _TurkeyNewsCardState extends State<_TurkeyNewsCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final title = (isEn && a.titleEn != null && a.titleEn!.isNotEmpty) ? a.titleEn! : a.title;
    final dateStr = DateFormat.yMMMd(isEn ? 'en_US' : 'tr_TR').format(a.createdAt);
    
    final titleColor = _hovered
        ? const Color(0xFFE30A17) // Turkish Red on hover
        : (widget.isDark ? AppColors.creamBackground : AppColors.earthText);

    if (widget.isRow) {
      return MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => pushScreen(context, ArticleDetailScreen(article: a)),
          child: AnimatedScale(
            scale: _hovered ? 1.02 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: 120,
                    height: 80,
                    child: NewsArticleImage(
                      imageUrl: a.imageUrl,
                      fit: BoxFit.cover,
                      semanticLabel: title,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => pushScreen(context, ArticleDetailScreen(article: a)),
        child: AnimatedScale(
          scale: _hovered ? 1.01 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: widget.isLarge ? 16 / 9 : 3 / 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: NewsArticleImage(
                    imageUrl: a.imageUrl,
                    fit: BoxFit.cover,
                    semanticLabel: title,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                title,
                maxLines: widget.isLarge ? 3 : 4,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.playfairDisplay(
                  fontSize: widget.isLarge ? 22 : 16,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
