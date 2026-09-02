// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../../../../core/utils/hover.dart';
import '../../../../core/utils/image_fallback_helper.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../../../core/widgets/article_timestamp.dart';
import '../../../../core/widgets/section_container.dart';
import '../../data/models/news_article.dart';
import '../../providers/home_providers.dart';
import '../screens/article_detail_screen.dart';

//  GÖZDEN KAÇANLAR (ICYMI) BÖLÜMÜ
// ═══════════════════════════════════════════════════════════════════════════

class IcymiSection extends ConsumerWidget {
  final bool isDark;

  const IcymiSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final articles = ref.watch(icymiArticlesProvider);
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final titleText = isEn ? 'IN CASE YOU MISSED IT' : 'GÖZDEN KAÇANLAR';

    if (articles.isEmpty) return const SizedBox.shrink();

    return SectionContainer(
      title: titleText,
      icon: Icons.history_rounded,
      isDark: isDark,
      child: SizedBox(
        height: 320,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          itemCount: articles.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0.0 : 8.0,
                right: index == articles.length - 1 ? 0.0 : 8.0,
              ),
              child: SizedBox(
                width: 260,
                child: _IcymiCard(article: articles[index], isDark: isDark),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _IcymiCard extends StatefulWidget {
  final NewsArticle article;
  final bool isDark;

  const _IcymiCard({
    required this.article,
    required this.isDark,
  });

  @override
  State<_IcymiCard> createState() => _IcymiCardState();
}

class _IcymiCardState extends State<_IcymiCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final title = (isEn && a.titleEn != null && a.titleEn!.isNotEmpty)
        ? a.titleEn!
        : a.title;

    final accentCol = AppColors.accentFor(isDark: widget.isDark);
    final titleColor = _hovered
        ? accentCol
        : (widget.isDark ? AppColors.creamBackground : AppColors.earthText);
    final bgColor = widget.isDark ? AppColors.darkGreen : Colors.white;
    final borderColor =
        widget.isDark ? AppColors.wheat : const Color(0xFFE5E5E5);

    return MouseRegion(
      onEnter: (_) { if (hoverPointerLikely) setState(() => _hovered = true); },
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => pushScreen(context, ArticleDetailScreen(article: a)),
        child: AnimatedScale(
          scale: _hovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: _hovered
                      ? accentCol.withValues(alpha: 0.5)
                      : borderColor),
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
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(11)),
                    child: NewsArticleImage(
                      imageUrl: a.imageUrl,
                      fit: BoxFit.cover,
                      semanticLabel: title,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (a.topic != null && a.topic!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              a.topic!.toTurkishUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: AppTypography.minLabelSize,
                                fontWeight: FontWeight.bold,
                                color: accentCol,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: titleColor,
                              height: 1.25,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        ArticleTimestamp(
                          published: a.createdAt,
                          color: widget.isDark
                              ? AppColors.wheat
                              : AppColors.earthText.withValues(alpha: 0.70),
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
