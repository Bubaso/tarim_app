// ignore_for_file: deprecated_member_use
import 'package:tarim_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/models/news_article.dart';
import '../../../../core/utils/image_fallback_helper.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../screens/article_detail_screen.dart';

class NewsCard extends StatefulWidget {
  final NewsArticle article;

  const NewsCard({
    super.key,
    required this.article,
  });

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final isDark = theme.brightness == Brightness.dark;

    final displayTitle = (isEn && widget.article.titleEn != null && widget.article.titleEn!.isNotEmpty)
        ? widget.article.titleEn!
        : widget.article.title;

    final displaySummary = (isEn && widget.article.summaryEn != null && widget.article.summaryEn!.isNotEmpty)
        ? widget.article.summaryEn!
        : (widget.article.summary ?? '');

    final hasSource = widget.article.sourceName != null && widget.article.sourceName!.isNotEmpty;
    final formattedDate = DateFormat.yMMMd(isEn ? 'en_US' : 'tr_TR').add_Hm().format(widget.article.createdAt);

    final cardBg = isDark ? AppColors.darkGreen : Colors.white;
    final borderColor = isDark ? AppColors.wheat : AppColors.wheat;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: MergeSemantics(
        child: GestureDetector(
          onTap: () => pushScreen(context, ArticleDetailScreen(article: widget.article),
          ),
        child: AnimatedScale(
          scale: _hovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _hovered ? theme.colorScheme.primary : borderColor,
                width: _hovered ? 1.5 : 1.0,
              ),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 16:9 görsel ─────────────────────────────────────────
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: NewsArticleImage(
                    imageUrl: widget.article.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    semanticLabel: displayTitle,
                  ),
                ),

                // ── Metin bölümü ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kaynak etiketi + tarih
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                if (hasSource)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: Text(
                                      widget.article.sourceName!.toUpperCase(),
                                      style: GoogleFonts.inter(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 9,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                if (widget.article.topic != null && widget.article.topic!.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.wheat : AppColors.wheat,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: Text(
                                      widget.article.topic!.toUpperCase(),
                                      style: GoogleFonts.inter(
                                        color: isDark ? AppColors.wheat : AppColors.earthText,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 9,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                if (widget.article.region != null && widget.article.region!.isNotEmpty && widget.article.region != 'Türkiye')
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF3B2A10) : const Color(0xFFFFF2D9),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: Text(
                                      widget.article.region!.toUpperCase(),
                                      style: GoogleFonts.inter(
                                        color: Colors.orangeAccent,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 9,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Playfair başlık
                      Text(
                        displayTitle,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _hovered
                              ? (isDark ? AppColors.primaryGreen : AppColors.primaryGreen)
                              : (isDark ? AppColors.creamBackground : AppColors.earthText),
                          height: 1.25,
                        ),
                      ),

                      // Lora özet
                      if (displaySummary.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          displaySummary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.lora(
                            color: isDark
                                ? AppColors.wheat
                                : AppColors.earthText,
                            fontSize: 13,
                            height: 1.5,
                          ),
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
    ));
  }
}
