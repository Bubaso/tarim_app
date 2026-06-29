import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/utils/fade_page_route.dart';
import '../../../../../core/utils/image_fallback_helper.dart';
import '../../../data/models/news_article.dart';
import '../../screens/article_detail_screen.dart';

class WorldNewsRow extends StatelessWidget {
  final List<NewsArticle> articles;
  final bool isDark;

  const WorldNewsRow({
    super.key,
    required this.articles,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) return const SizedBox.shrink();

    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final headerColor = isDark ? const Color(0xFFECEFF1) : const Color(0xFF111111);
    final dividerColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE5E5E5);

    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Premium Header for World News
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 0.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 4,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3), // Global Blue
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isEn ? "WORLD NEWS" : "DÜNYADAN HABERLER",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: headerColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 1,
                  color: dividerColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Horizontal Scrollable Cards
        SizedBox(
          height: 320, // fixed height for horizontal scroll
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final isFirst = index == 0;
              final isLast = index == articles.length - 1;
              return Padding(
                padding: EdgeInsets.only(
                  left: (isMobile && isFirst) ? 16.0 : 0.0,
                  right: isLast ? (isMobile ? 16.0 : 0.0) : 20.0,
                ),
                child: _WorldNewsCard(article: articles[index], isDark: isDark),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WorldNewsCard extends StatefulWidget {
  final NewsArticle article;
  final bool isDark;

  const _WorldNewsCard({
    required this.article,
    required this.isDark,
  });

  @override
  State<_WorldNewsCard> createState() => _WorldNewsCardState();
}

class _WorldNewsCardState extends State<_WorldNewsCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final title = (isEn && a.titleEn != null && a.titleEn!.isNotEmpty) ? a.titleEn! : a.title;
    final dateStr = DateFormat.yMMMd(isEn ? 'en_US' : 'tr_TR').format(a.createdAt);
    
    final titleColor = _hovered
        ? const Color(0xFF2196F3) // Global Blue on hover
        : (widget.isDark ? const Color(0xFFECEFF1) : const Color(0xFF111111));
    final bgColor = widget.isDark ? const Color(0xFF161B22) : Colors.white;
    final borderColor = widget.isDark ? const Color(0xFF30363D) : const Color(0xFFE5E5E5);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(createFadeRoute(ArticleDetailScreen(article: a))),
        child: AnimatedScale(
          scale: _hovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Container(
            width: 260,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _hovered ? const Color(0xFF2196F3).withOpacity(0.5) : borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(widget.isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 3 / 2,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        NewsArticleImage(
                          imageUrl: a.imageUrl,
                          fit: BoxFit.cover,
                          semanticLabel: title,
                        ),
                        if (a.region != null && a.region!.isNotEmpty)
                          Positioned(
                            bottom: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2196F3).withOpacity(0.9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                a.region!.toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Expanded(
                          child: Text(
                            title,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: titleColor,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ],
                    ),
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
