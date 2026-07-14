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

class ScienceReportsDossier extends ConsumerWidget {
  final List<NewsArticle> articles;
  final bool isDark;

  const ScienceReportsDossier({
    super.key,
    required this.articles,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (articles.isEmpty) return const SizedBox.shrink();
    ref.watch(localeProvider); // Rebuild when language changes
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;
    
    // Aesthetic: Dark teal/emerald background for the "Science" feeling
    final bgColor = isDark ? AppColors.darkGreen : AppColors.darkGreen;
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile)
            _MobileDossierLayout(articles: articles)
          else
            _DesktopDossierLayout(articles: articles),
        ],
      ),
    );
  }
}

class _DesktopDossierLayout extends StatelessWidget {
  final List<NewsArticle> articles;

  const _DesktopDossierLayout({required this.articles});

  @override
  Widget build(BuildContext context) {
    final featured = articles.first;
    final others = articles.skip(1).take(4).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 13,
          child: _DossierFeaturedCard(article: featured),
        ),
        if (others.isNotEmpty) ...[
          const SizedBox(width: 32),
          Container(
            width: 1,
            height: 400,
            color: Colors.tealAccent.withOpacity(0.2),
          ),
          const SizedBox(width: 32),
          Expanded(
            flex: 10,
            child: Column(
              children: others.asMap().entries.map((entry) {
                return Padding(
                  padding: EdgeInsets.only(bottom: entry.key == others.length - 1 ? 0 : 24),
                  child: _DossierListCard(article: entry.value),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}

class _MobileDossierLayout extends StatelessWidget {
  final List<NewsArticle> articles;

  const _MobileDossierLayout({required this.articles});

  @override
  Widget build(BuildContext context) {
    final featured = articles.first;
    final others = articles.skip(1).take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DossierFeaturedCard(article: featured),
        if (others.isNotEmpty) ...[
          const SizedBox(height: 24),
          Divider(color: Colors.tealAccent.withOpacity(0.2)),
          const SizedBox(height: 24),
          ...others.asMap().entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(bottom: entry.key == others.length - 1 ? 0 : 20),
              child: _DossierListCard(article: entry.value),
            );
          }).toList(),
        ],
      ],
    );
  }
}

class _DossierFeaturedCard extends StatefulWidget {
  final NewsArticle article;

  const _DossierFeaturedCard({required this.article});

  @override
  State<_DossierFeaturedCard> createState() => _DossierFeaturedCardState();
}

class _DossierFeaturedCardState extends State<_DossierFeaturedCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final title = (isEn && a.titleEn != null && a.titleEn!.isNotEmpty) ? a.titleEn! : a.title;
    final summary = (isEn && a.summaryEn != null && a.summaryEn!.isNotEmpty) ? a.summaryEn! : (a.summary ?? '');
    
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => pushScreen(context, ArticleDetailScreen(article: a),
        ),
        child: AnimatedScale(
          scale: _hovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      NewsArticleImage(
                        imageUrl: a.imageUrl,
                        fit: BoxFit.cover,
                        semanticLabel: title,
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.tealAccent.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isEn ? 'REPORT' : 'RAPOR',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: _hovered ? Colors.tealAccent : Colors.white,
                  height: 1.2,
                ),
              ),
              if (summary.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  summary,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lora(
                    fontSize: 15,
                    color: Colors.white70,
                    height: 1.6,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DossierListCard extends StatefulWidget {
  final NewsArticle article;

  const _DossierListCard({required this.article});

  @override
  State<_DossierListCard> createState() => _DossierListCardState();
}

class _DossierListCardState extends State<_DossierListCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final title = (isEn && a.titleEn != null && a.titleEn!.isNotEmpty) ? a.titleEn! : a.title;
    final dateStr = DateFormat.yMMMd(isEn ? 'en_US' : 'tr_TR').format(a.createdAt);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => pushScreen(context, ArticleDetailScreen(article: a),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _hovered ? Colors.white.withOpacity(0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hovered ? Colors.tealAccent.withOpacity(0.3) : Colors.transparent,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 100,
                  height: 70,
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _hovered ? Colors.tealAccent : Colors.white,
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
}
