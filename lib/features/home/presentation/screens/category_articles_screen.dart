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

class CategoryArticlesScreen extends ConsumerStatefulWidget {
  final String title;
  final List<NewsArticle> articles;

  const CategoryArticlesScreen({
    super.key,
    required this.title,
    required this.articles,
  });

  @override
  ConsumerState<CategoryArticlesScreen> createState() => _CategoryArticlesScreenState();
}

class _CategoryArticlesScreenState extends ConsumerState<CategoryArticlesScreen> {
  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider); // Rebuild when language changes
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.darkGreen : const Color(0xFFF9F9F7);
    final textColor = isDark ? AppColors.wheat : AppColors.earthText;
    final dividerColor = isDark ? Colors.white12 : Colors.black12;

    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // Premium SliverAppBar
          SliverAppBar(
            backgroundColor: isDark ? const Color(0xFF0C1014) : Colors.white,
            elevation: 0,
            pinned: true,
            centerTitle: true,
            iconTheme: IconThemeData(color: textColor),
            title: Text(
              widget.title.toUpperCase(),
              style: GoogleFonts.playfairDisplay(
                color: textColor,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: 1.5,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: dividerColor, height: 1),
            ),
          ),

          if (widget.articles.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  isEn ? 'No articles found in this category.' : 'Bu kategoride henüz haber bulunmuyor.',
                  style: GoogleFonts.inter(color: textColor, fontSize: 16),
                ),
              ),
            )
          else ...[
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 48, vertical: 32),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // A massive header title to anchor the page
                    Text(
                      isEn ? 'LATEST IN ${widget.title.toUpperCase()}' : '${widget.title.toUpperCase()} HABERLERİ',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: isMobile ? 32 : 54,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(width: 60, height: 4, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 48),
                    
                    // The Featured Article (First article)
                    _FeaturedCategoryArticle(
                      article: widget.articles.first,
                      isDark: isDark,
                      isMobile: isMobile,
                    ),
                  ],
                ),
              ),
            ),

            if (widget.articles.length > 1)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 48),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: Container(height: 1, color: dividerColor)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              isEn ? 'MORE STORIES' : 'DİĞER HABERLER',
                              style: GoogleFonts.robotoMono(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                            ),
                          ),
                          Expanded(child: Container(height: 1, color: dividerColor)),
                        ],
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),

            // The remaining articles grid
            if (widget.articles.length > 1)
              SliverPadding(
                padding: EdgeInsets.only(
                  left: isMobile ? 16 : 48,
                  right: isMobile ? 16 : 48,
                  bottom: 64,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isMobile ? 1 : 3,
                    crossAxisSpacing: 32,
                    mainAxisSpacing: 48,
                    childAspectRatio: isMobile ? 1.1 : 0.75, // Taller cards for elegant text layout
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _StandardCategoryCard(
                        article: widget.articles[index + 1],
                        isDark: isDark,
                      );
                    },
                    childCount: widget.articles.length - 1,
                  ),
                ),
              ),
              
            SliverToBoxAdapter(
              child: PortalFooter(isDark: isDark),
            ),
          ],
        ],
      ),
    );
  }
}

class _FeaturedCategoryArticle extends StatefulWidget {
  final NewsArticle article;
  final bool isDark;
  final bool isMobile;

  const _FeaturedCategoryArticle({
    required this.article,
    required this.isDark,
    required this.isMobile,
  });

  @override
  State<_FeaturedCategoryArticle> createState() => _FeaturedCategoryArticleState();
}

class _FeaturedCategoryArticleState extends State<_FeaturedCategoryArticle> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final title = (isEn && a.titleEn != null && a.titleEn!.isNotEmpty) ? a.titleEn! : a.title;
    final summary = (isEn && a.summaryEn != null && a.summaryEn!.isNotEmpty) ? a.summaryEn! : (a.summary ?? '');
    final dateStr = DateFormat.yMMMd(isEn ? 'en_US' : 'tr_TR').format(a.createdAt);
    
    final textColor = widget.isDark ? AppColors.wheat : AppColors.earthText;
    final hoverTitleColor = Theme.of(context).colorScheme.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(createFadeRoute(ArticleDetailScreen(article: a))),
        child: widget.isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: NewsArticleImage(
                        imageUrl: a.imageUrl,
                        fit: BoxFit.cover,
                        semanticLabel: title,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    dateStr.toUpperCase(),
                    style: GoogleFonts.robotoMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: _hovered ? hoverTitleColor : textColor,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    summary,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lora(
                      fontSize: 16,
                      color: widget.isDark ? Colors.white70 : Colors.black87,
                      height: 1.6,
                    ),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 12,
                    child: AspectRatio(
                      aspectRatio: 16 / 10,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedScale(
                          scale: _hovered ? 1.03 : 1.0,
                          duration: const Duration(seconds: 1),
                          curve: Curves.easeOutQuart,
                          child: NewsArticleImage(
                            imageUrl: a.imageUrl,
                            fit: BoxFit.cover,
                            semanticLabel: title,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                  Expanded(
                    flex: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateStr.toUpperCase(),
                          style: GoogleFonts.robotoMono(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.primary,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          title,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: _hovered ? hoverTitleColor : textColor,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          summary,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.lora(
                            fontSize: 18,
                            color: widget.isDark ? Colors.white70 : Colors.black87,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: _hovered ? hoverTitleColor : (widget.isDark ? Colors.white24 : Colors.black26)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isEn ? 'READ MORE' : 'HABERİ OKU',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                  color: _hovered ? hoverTitleColor : textColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 16, color: _hovered ? hoverTitleColor : textColor),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _StandardCategoryCard extends StatefulWidget {
  final NewsArticle article;
  final bool isDark;

  const _StandardCategoryCard({
    required this.article,
    required this.isDark,
  });

  @override
  State<_StandardCategoryCard> createState() => _StandardCategoryCardState();
}

class _StandardCategoryCardState extends State<_StandardCategoryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final title = (isEn && a.titleEn != null && a.titleEn!.isNotEmpty) ? a.titleEn! : a.title;
    final summary = (isEn && a.summaryEn != null && a.summaryEn!.isNotEmpty) ? a.summaryEn! : (a.summary ?? '');
    final dateStr = DateFormat.yMMMd(isEn ? 'en_US' : 'tr_TR').format(a.createdAt);
    
    final textColor = widget.isDark ? AppColors.wheat : AppColors.earthText;
    final hoverTitleColor = Theme.of(context).colorScheme.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(createFadeRoute(ArticleDetailScreen(article: a))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 3 / 2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: AnimatedScale(
                  scale: _hovered ? 1.05 : 1.0,
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeOutQuart,
                  child: NewsArticleImage(
                    imageUrl: a.imageUrl,
                    fit: BoxFit.cover,
                    semanticLabel: title,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              dateStr.toUpperCase(),
              style: GoogleFonts.robotoMono(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _hovered ? hoverTitleColor : textColor,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                summary,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lora(
                  fontSize: 15,
                  color: widget.isDark ? Colors.white60 : Colors.black54,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
