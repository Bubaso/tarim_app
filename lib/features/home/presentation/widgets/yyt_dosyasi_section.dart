// ignore_for_file: deprecated_member_use
import 'package:tarim_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../../../../core/utils/image_fallback_helper.dart';
import '../../data/models/news_article.dart';
import '../../providers/home_providers.dart';
import '../screens/article_detail_screen.dart';
import '../screens/yyt_dosyasi_screen.dart';

/// Sub-hero YYT Dosyası section for the homepage.
/// Appears between the Trending section and AgendaBentoGrid.
/// Hidden when there are no YYT articles.
class YYTDosyasiSection extends ConsumerWidget {
  final bool isDark;

  const YYTDosyasiSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yytAsync = ref.watch(yytArticlesProvider);
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    return yytAsync.when(
      data: (articles) {
        if (articles.isEmpty) return const SizedBox.shrink();
        return _YYTSectionContent(
          articles: articles,
          isDark: isDark,
          isEn: isEn,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

// ─── Section content ─────────────────────────────────────────────────────────

class _YYTSectionContent extends StatelessWidget {
  final List<NewsArticle> articles;
  final bool isDark;
  final bool isEn;

  const _YYTSectionContent({
    required this.articles,
    required this.isDark,
    required this.isEn,
  });

  @override
  Widget build(BuildContext context) {
    // Show up to 4 cards in the horizontal strip
    final preview = articles.take(4).toList();

    final sectionBg = isDark
        ? const Color(0xFF100A0A)
        : const Color(0xFFFFF8F8);
    final borderColor = isDark
        ? const Color(0xFFD32F2F).withValues(alpha: 0.25)
        : const Color(0xFFD32F2F).withValues(alpha: 0.15);
    final accentRed = const Color(0xFFD32F2F);
    final headerColor = isDark ? AppColors.creamBackground : AppColors.earthText;
    final subColor = isDark ? Colors.white54 : Colors.black54;

    return Container(
      decoration: BoxDecoration(
        color: sectionBg,
        border: Border.symmetric(
          horizontal: BorderSide(color: borderColor, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Red accent bar
                Container(
                  width: 4,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accentRed,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: accentRed,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              'YYT',
                              style: GoogleFonts.robotoMono(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isEn ? 'DOSSIER' : 'ÖZEL DOSYA',
                            style: GoogleFonts.robotoMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: accentRed,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isEn
                            ? 'High Intensity Sweeteners'
                            : 'Yüksek Yoğunluklu Tatlandırıcılar',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: headerColor,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                // "See all" button
                TextButton.icon(
                  onPressed: () => pushScreen(context, const YYTDosyasiScreen(),
                  ),
                  icon: Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: accentRed,
                  ),
                  label: Text(
                    isEn ? 'All' : 'Tümü',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: accentRed,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // ── Subtitle ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              isEn
                  ? 'Scientific research & regulatory news on artificial sweeteners'
                  : 'Yapay tatlandırıcılara ilişkin bilimsel araştırmalar ve düzenleyici haberler',
              style: GoogleFonts.lora(
                fontSize: 12,
                color: subColor,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 18),

          // ── Article cards (horizontal scroll) ───────────────────────────
          SizedBox(
            height: 210,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: preview.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) => _YYTPreviewCard(
                article: preview[i],
                isDark: isDark,
                isEn: isEn,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── "See full dossier" bottom link ───────────────────────────────
          Center(
            child: OutlinedButton.icon(
              onPressed: () => pushScreen(context, const YYTDosyasiScreen(),
              ),
              icon: Icon(Icons.folder_special_rounded, size: 16, color: accentRed),
              label: Text(
                isEn ? 'Open Full YYT Dossier' : 'Tüm YYT Dosyasını Aç',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: accentRed,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: accentRed.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                foregroundColor: accentRed,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Individual preview card ──────────────────────────────────────────────────

class _YYTPreviewCard extends StatefulWidget {
  final NewsArticle article;
  final bool isDark;
  final bool isEn;

  const _YYTPreviewCard({
    required this.article,
    required this.isDark,
    required this.isEn,
  });

  @override
  State<_YYTPreviewCard> createState() => _YYTPreviewCardState();
}

class _YYTPreviewCardState extends State<_YYTPreviewCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    final title = (widget.isEn && a.titleEn != null && a.titleEn!.isNotEmpty)
        ? a.titleEn!
        : a.title;

    final bg = widget.isDark ? const Color(0xFF1A0F0F) : Colors.white;
    final border = widget.isDark ? const Color(0xFF3D1A1A) : const Color(0xFFEEDDDD);
    final textCol = widget.isDark ? const Color(0xFFE6EDF3) : AppColors.earthText;
    final accentRed = const Color(0xFFD32F2F);

    final months = widget.isEn
        ? ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
        : ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
    final dt = a.createdAt;
    final dateStr = '${dt.day} ${months[dt.month - 1]}';

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => pushScreen(context, ArticleDetailScreen(article: a),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 200,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hover ? accentRed.withValues(alpha: 0.7) : border,
              width: _hover ? 1.5 : 1,
            ),
            boxShadow: _hover
                ? [
                    BoxShadow(
                      color: accentRed.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(7),
                  topRight: Radius.circular(7),
                ),
                child: SizedBox(
                  height: 110,
                  width: double.infinity,
                  child: a.imageUrl != null
                      ? NewsArticleImage(imageUrl: a.imageUrl, fit: BoxFit.cover)
                      : Container(
                          color: widget.isDark
                              ? const Color(0xFF2A1010)
                              : const Color(0xFFFCEEEE),
                          child: Center(
                            child: Icon(
                              Icons.science_outlined,
                              size: 36,
                              color: accentRed.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                ),
              ),
              // Text area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: textCol,
                          height: 1.3,
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
    );
  }
}
