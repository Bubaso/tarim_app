import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tarim_app/core/theme/app_colors.dart';
import 'package:tarim_app/core/utils/localization_helper.dart';
import 'package:tarim_app/core/utils/fade_page_route.dart';
import 'package:tarim_app/core/utils/image_fallback_helper.dart';
import '../../data/models/news_article.dart';
import 'article_detail_screen.dart';
import '../widgets/portal_footer.dart';

class CategoryArticlesScreen extends ConsumerWidget {
  final String title;
  final List<NewsArticle> articles;

  const CategoryArticlesScreen({
    super.key,
    required this.title,
    required this.articles,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkGreen : const Color(0xFFF4F4F4);
    final textColor = isDark ? AppColors.wheat : AppColors.earthText;
    final dividerColor = isDark ? Colors.white12 : Colors.black12;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: isDark ? const Color(0xFF0A0D10) : Colors.white,
            elevation: 0,
            pinned: true,
            centerTitle: true,
            iconTheme: IconThemeData(color: textColor),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 8, height: 24, color: AppColors.primaryGreen),
                const SizedBox(width: 12),
                Text(
                  title.toUpperCase(),
                  style: GoogleFonts.inter(
                    color: textColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: dividerColor, height: 1),
            ),
          ),

          if (articles.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  isEn ? 'No articles found.' : 'Bu kategoride haber bulunmuyor.',
                  style: GoogleFonts.inter(color: textColor, fontSize: 16),
                ),
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 24, vertical: isMobile ? 0 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Hero ──────────────────────────────────────────────────────────
                        _HeroArticle(
                          article: articles.first,
                          categoryName: title,
                          isDark: isDark,
                          isMobile: isMobile,
                        ),

                        if (articles.length > 1) ...[
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              isMobile ? 16 : 0, 56, isMobile ? 16 : 0, 48),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(width: 24, height: 2, color: AppColors.primaryGreen),
                                const SizedBox(width: 16),
                                Text(
                                  isEn ? 'MORE STORIES' : 'DİĞER HABERLER',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 3,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(child: Container(height: 1, color: dividerColor)),
                              ],
                            ),
                          ),

                          // ── Mixed-size body ──────────────────────────────────────────
                          Padding(
                            padding: EdgeInsets.only(
                              left: isMobile ? 16 : 0,
                              right: isMobile ? 16 : 0,
                              bottom: 80,
                            ),
                            child: _MixedGrid(
                              articles: articles.sublist(1),
                              isDark: isDark,
                              isMobile: isMobile,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(child: PortalFooter(isDark: isDark)),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mixed grid: builds entire body as a single Column inside SliverToBoxAdapter
// so there are ZERO Expanded widgets in a scrollable context.
// ─────────────────────────────────────────────────────────────────────────────
class _MixedGrid extends StatelessWidget {
  final List<NewsArticle> articles;
  final bool isDark;
  final bool isMobile;

  const _MixedGrid({required this.articles, required this.isDark, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    int i = 0;
    int blockIndex = 0;

    while (i < articles.length) {
      if (isMobile) {
        // Mobile pattern: alternate Large / SideBySide pair
        if (blockIndex % 2 == 0) {
          rows.add(_LargeCard(article: articles[i], isDark: isDark, isMobile: true));
          rows.add(const SizedBox(height: 32));
          i += 1;
        } else {
          // Up to 2 side-by-side list items
          rows.add(_SideCard(article: articles[i], isDark: isDark));
          rows.add(Divider(height: 32, color: isDark ? Colors.white12 : Colors.black12));
          i += 1;
          if (i < articles.length) {
            rows.add(_SideCard(article: articles[i], isDark: isDark));
            rows.add(Divider(height: 32, color: isDark ? Colors.white12 : Colors.black12));
            i += 1;
          }
        }
      } else {
        // Desktop: 4-pattern rotation
        final pattern = blockIndex % 4;

        if (pattern == 0) {
          // [LARGE(2) | COMPACT STACK(1)]  – 3 articles
          final a1 = articles[i];
          final a2 = i + 1 < articles.length ? articles[i + 1] : null;
          final a3 = i + 2 < articles.length ? articles[i + 2] : null;
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _LargeCard(article: a1, isDark: isDark, isMobile: false)),
                if (a2 != null || a3 != null) ...[
                  const SizedBox(width: 32),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (a2 != null) _CompactCard(article: a2, isDark: isDark),
                        if (a2 != null && a3 != null) const SizedBox(height: 24),
                        if (a3 != null) _CompactCard(article: a3, isDark: isDark),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
          i += 3;
        } else if (pattern == 1) {
          // 4 standard cards in a row
          final cards = <Widget>[];
          for (int k = 0; k < 4 && i + k < articles.length; k++) {
            if (cards.isNotEmpty) cards.add(const SizedBox(width: 32));
            cards.add(Expanded(child: _StdCard(article: articles[i + k], isDark: isDark)));
          }
          rows.add(Row(crossAxisAlignment: CrossAxisAlignment.start, children: cards));
          i += 4;
        } else if (pattern == 2) {
          // 2 large cards
          final a1 = articles[i];
          final a2 = i + 1 < articles.length ? articles[i + 1] : null;
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _LargeCard(article: a1, isDark: isDark, isMobile: false)),
                if (a2 != null) ...[
                  const SizedBox(width: 32),
                  Expanded(child: _LargeCard(article: a2, isDark: isDark, isMobile: false)),
                ],
              ],
            ),
          );
          i += 2;
        } else {
          // 3 standard cards
          final cards = <Widget>[];
          for (int k = 0; k < 3 && i + k < articles.length; k++) {
            if (cards.isNotEmpty) cards.add(const SizedBox(width: 32));
            cards.add(Expanded(child: _StdCard(article: articles[i + k], isDark: isDark)));
          }
          rows.add(Row(crossAxisAlignment: CrossAxisAlignment.start, children: cards));
          i += 3;
        }
      }

      rows.add(const SizedBox(height: 48));
      blockIndex++;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  HERO (full-bleed cinematic)
// ─────────────────────────────────────────────────────────────────────────────
class _HeroArticle extends StatefulWidget {
  final NewsArticle article;
  final String categoryName;
  final bool isDark;
  final bool isMobile;
  const _HeroArticle({required this.article, required this.categoryName, required this.isDark, required this.isMobile});

  @override
  State<_HeroArticle> createState() => _HeroArticleState();
}

class _HeroArticleState extends State<_HeroArticle> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final title = (isEn && a.titleEn != null && a.titleEn!.isNotEmpty) ? a.titleEn! : a.title;
    final summary = (isEn && a.summaryEn != null && a.summaryEn!.isNotEmpty) ? a.summaryEn! : (a.summary ?? '');
    final dateStr = DateFormat.yMMMd(isEn ? 'en_US' : 'tr_TR').format(a.createdAt);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(createFadeRoute(ArticleDetailScreen(article: a))),
        child: AspectRatio(
          aspectRatio: widget.isMobile ? 1.0 : 2.4,
          child: ClipRRect(
            borderRadius: widget.isMobile ? BorderRadius.zero : BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
              AnimatedScale(
                scale: _hovered ? 1.03 : 1.0,
                duration: const Duration(seconds: 4),
                curve: Curves.easeOutQuart,
                child: NewsArticleImage(imageUrl: a.imageUrl, fit: BoxFit.cover, isHighQuality: true),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.35, 0.75, 1.0],
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.transparent,
                      Colors.black.withOpacity(0.65),
                      Colors.black.withOpacity(0.95),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: widget.isMobile ? 24 : 48,
                left: widget.isMobile ? 16 : 48,
                right: widget.isMobile ? 16 : 48,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                              color: AppColors.primaryGreen,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              child: Text(widget.categoryName.toUpperCase(),
                                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white)),
                            ),
                            const SizedBox(width: 12),
                            Text(dateStr.toUpperCase(),
                                style: GoogleFonts.robotoMono(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70, letterSpacing: 1.5)),
                          ]),
                          const SizedBox(height: 20),
                          Text(title,
                              style: GoogleFonts.playfairDisplay(
                                  fontSize: widget.isMobile ? 30 : 54,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1.1)),
                          const SizedBox(height: 16),
                          Text(summary,
                              maxLines: widget.isMobile ? 2 : 3,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.lora(fontSize: widget.isMobile ? 15 : 19, color: Colors.white70, height: 1.5)),
                        ],
                      ),
                    ),
                    if (!widget.isMobile) ...[
                      const SizedBox(width: 24),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _hovered ? AppColors.primaryGreen : Colors.transparent,
                          border: Border.all(color: _hovered ? AppColors.primaryGreen : Colors.white30, width: 2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 30),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}

// ─────────────────────────────────────────────────────────────────────────────
//  LARGE CARD (16:9 image + text below) — no Expanded
// ─────────────────────────────────────────────────────────────────────────────
class _LargeCard extends StatefulWidget {
  final NewsArticle article;
  final bool isDark;
  final bool isMobile;
  const _LargeCard({required this.article, required this.isDark, required this.isMobile});

  @override
  State<_LargeCard> createState() => _LargeCardState();
}

class _LargeCardState extends State<_LargeCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final title = (isEn && a.titleEn != null && a.titleEn!.isNotEmpty) ? a.titleEn! : a.title;
    final summary = (isEn && a.summaryEn != null && a.summaryEn!.isNotEmpty) ? a.summaryEn! : (a.summary ?? '');
    final dateStr = DateFormat.yMMMd(isEn ? 'en_US' : 'tr_TR').format(a.createdAt);
    final textColor = widget.isDark ? Colors.white : Colors.black87;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(createFadeRoute(ArticleDetailScreen(article: a))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(fit: StackFit.expand, children: [
                NewsArticleImage(imageUrl: a.imageUrl, fit: BoxFit.cover),
                if (_hovered) Container(color: AppColors.primaryGreen.withOpacity(0.12)),
              ]),
            ),
            const SizedBox(height: 20),
            Text(dateStr.toUpperCase(),
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryGreen, letterSpacing: 2)),
            const SizedBox(height: 10),
            Text(title,
                maxLines: 3, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.playfairDisplay(
                    fontSize: widget.isMobile ? 26 : 34,
                    fontWeight: FontWeight.w900,
                    color: _hovered ? AppColors.primaryGreen : textColor,
                    height: 1.15)),
            const SizedBox(height: 10),
            Text(summary,
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lora(fontSize: 15, color: widget.isDark ? Colors.white60 : Colors.black54, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  STANDARD CARD (3:2 image + text below)
// ─────────────────────────────────────────────────────────────────────────────
class _StdCard extends StatefulWidget {
  final NewsArticle article;
  final bool isDark;
  const _StdCard({required this.article, required this.isDark});

  @override
  State<_StdCard> createState() => _StdCardState();
}

class _StdCardState extends State<_StdCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final title = (isEn && a.titleEn != null && a.titleEn!.isNotEmpty) ? a.titleEn! : a.title;
    final dateStr = DateFormat.yMMMd(isEn ? 'en_US' : 'tr_TR').format(a.createdAt);
    final textColor = widget.isDark ? Colors.white : Colors.black87;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(createFadeRoute(ArticleDetailScreen(article: a))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 3 / 2,
              child: Stack(fit: StackFit.expand, children: [
                NewsArticleImage(imageUrl: a.imageUrl, fit: BoxFit.cover),
                if (_hovered) Container(color: AppColors.primaryGreen.withOpacity(0.12)),
              ]),
            ),
            const SizedBox(height: 14),
            Text(dateStr.toUpperCase(),
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primaryGreen, letterSpacing: 1.5)),
            const SizedBox(height: 8),
            Text(title,
                maxLines: 4, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.playfairDisplay(
                    fontSize: 20, fontWeight: FontWeight.w900,
                    color: _hovered ? AppColors.primaryGreen : textColor, height: 1.2)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  COMPACT CARD (16:9 image + title) — used in the right column of pattern 0
// ─────────────────────────────────────────────────────────────────────────────
class _CompactCard extends StatefulWidget {
  final NewsArticle article;
  final bool isDark;
  const _CompactCard({required this.article, required this.isDark});

  @override
  State<_CompactCard> createState() => _CompactCardState();
}

class _CompactCardState extends State<_CompactCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final title = (isEn && a.titleEn != null && a.titleEn!.isNotEmpty) ? a.titleEn! : a.title;
    final dateStr = DateFormat.yMMMd(isEn ? 'en_US' : 'tr_TR').format(a.createdAt);
    final textColor = widget.isDark ? Colors.white : Colors.black87;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(createFadeRoute(ArticleDetailScreen(article: a))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(fit: StackFit.expand, children: [
                NewsArticleImage(imageUrl: a.imageUrl, fit: BoxFit.cover),
                if (_hovered) Container(color: AppColors.primaryGreen.withOpacity(0.12)),
              ]),
            ),
            const SizedBox(height: 12),
            Text(dateStr.toUpperCase(),
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primaryGreen, letterSpacing: 1)),
            const SizedBox(height: 6),
            Text(title,
                maxLines: 3, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.playfairDisplay(
                    fontSize: 17, fontWeight: FontWeight.w800,
                    color: _hovered ? AppColors.primaryGreen : textColor, height: 1.2)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SIDE CARD (mobile: thumbnail left + title right)
// ─────────────────────────────────────────────────────────────────────────────
class _SideCard extends StatefulWidget {
  final NewsArticle article;
  final bool isDark;
  const _SideCard({required this.article, required this.isDark});

  @override
  State<_SideCard> createState() => _SideCardState();
}

class _SideCardState extends State<_SideCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final title = (isEn && a.titleEn != null && a.titleEn!.isNotEmpty) ? a.titleEn! : a.title;
    final dateStr = DateFormat.yMMMd(isEn ? 'en_US' : 'tr_TR').format(a.createdAt);
    final textColor = widget.isDark ? Colors.white : Colors.black87;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(createFadeRoute(ArticleDetailScreen(article: a))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              height: 80,
              child: Stack(fit: StackFit.expand, children: [
                NewsArticleImage(imageUrl: a.imageUrl, fit: BoxFit.cover),
                if (_hovered) Container(color: AppColors.primaryGreen.withOpacity(0.12)),
              ]),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateStr.toUpperCase(),
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primaryGreen, letterSpacing: 1)),
                  const SizedBox(height: 6),
                  Text(title,
                      maxLines: 3, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 16, fontWeight: FontWeight.w800,
                          color: _hovered ? AppColors.primaryGreen : textColor, height: 1.2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
