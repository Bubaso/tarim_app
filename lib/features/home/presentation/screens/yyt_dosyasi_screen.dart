// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../../../../core/utils/image_fallback_helper.dart';
import '../../data/models/news_article.dart';
import '../../providers/home_providers.dart';
import 'article_detail_screen.dart';

class YYTDosyasiScreen extends ConsumerWidget {
  const YYTDosyasiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final yytAsync = ref.watch(yytArticlesProvider);

    final bgColor = isDark ? const Color(0xFF0C1015) : const Color(0xFFFAF9F6);
    final appBarBg = isDark ? const Color(0xFF080B0E) : const Color(0xFFF3F2ED);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFD32F2F),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'YYT',
                style: GoogleFonts.robotoMono(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              isEn ? 'YYT DOSSIER' : 'YYT DOSYASI',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: isDark ? const Color(0xFFF0F6FC) : const Color(0xFF1A1A1A),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
      body: yytAsync.when(
        data: (articles) => _buildContent(context, articles, isDark, isEn),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              isEn ? 'Failed to load YYT articles.' : 'YYT haberleri yüklenemedi.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<NewsArticle> articles,
    bool isDark,
    bool isEn,
  ) {
    if (articles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.science_outlined,
                size: 56,
                color: isDark ? Colors.white24 : Colors.black26,
              ),
              const SizedBox(height: 20),
              Text(
                isEn
                    ? 'No YYT articles yet.\nContent will appear here once approved.'
                    : 'Henüz YYT haberi bulunmuyor.\nOnaylanan içerikler burada görünecek.',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: isDark ? Colors.white54 : Colors.black45,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {},
      child: CustomScrollView(
        slivers: [
          // Banner header
          SliverToBoxAdapter(
            child: _YYTBanner(isDark: isDark, isEn: isEn, count: articles.length),
          ),
          // Article list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _YYTArticleCard(
                    article: articles[index],
                    isDark: isDark,
                    isEn: isEn,
                  );
                },
                childCount: articles.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

// ─── Banner at top of YYT screen ────────────────────────────────────────────

class _YYTBanner extends StatelessWidget {
  final bool isDark;
  final bool isEn;
  final int count;

  const _YYTBanner({
    required this.isDark,
    required this.isEn,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A0505) : const Color(0xFFFFF3F3),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFD32F2F).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'YYT',
                  style: GoogleFonts.robotoMono(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$count ${isEn ? 'article' : 'haber'}',
                  style: GoogleFonts.robotoMono(
                    color: const Color(0xFFD32F2F),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isEn ? 'High Intensity Sweeteners Dossier' : 'Yüksek Yoğunluklu Tatlandırıcılar Dosyası',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isDark ? const Color(0xFFF0F6FC) : const Color(0xFF1A1A1A),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isEn
                ? 'Scientific research, regulatory news, and analysis on artificial sweeteners and sugar substitutes (aspartame, sucralose, stevia, and more).'
                : 'Aspartam, sukraloz, stevia ve diğer yapay tatlandırıcılara ilişkin bilimsel araştırmalar, düzenleyici haberler ve analizler.',
            style: GoogleFonts.lora(
              fontSize: 13,
              color: isDark ? Colors.white54 : Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Individual article card for YYT screen ─────────────────────────────────

class _YYTArticleCard extends StatefulWidget {
  final NewsArticle article;
  final bool isDark;
  final bool isEn;

  const _YYTArticleCard({
    required this.article,
    required this.isDark,
    required this.isEn,
  });

  @override
  State<_YYTArticleCard> createState() => _YYTArticleCardState();
}

class _YYTArticleCardState extends State<_YYTArticleCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    final title = (widget.isEn && a.titleEn != null && a.titleEn!.isNotEmpty)
        ? a.titleEn!
        : a.title;
    final summary = (widget.isEn && a.summaryEn != null && a.summaryEn!.isNotEmpty)
        ? a.summaryEn!
        : (a.summary ?? '');

    final bg = widget.isDark ? const Color(0xFF161B22) : Colors.white;
    final border = widget.isDark ? const Color(0xFF30363D) : const Color(0xFFE5E5E5);
    final textCol = widget.isDark ? const Color(0xFFE6EDF3) : const Color(0xFF1A1A1A);
    final subCol = widget.isDark ? Colors.white54 : Colors.black54;

    final dateStr = _formatDate(a.createdAt, widget.isEn);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => Navigator.of(context).push(
            createFadeRoute(ArticleDetailScreen(article: a)),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _hover
                    ? const Color(0xFFD32F2F).withValues(alpha: 0.6)
                    : border,
                width: _hover ? 1.5 : 1,
              ),
              boxShadow: _hover
                  ? [
                      BoxShadow(
                        color: const Color(0xFFD32F2F).withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image thumbnail
                if (a.imageUrl != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      bottomLeft: Radius.circular(5),
                    ),
                    child: SizedBox(
                      width: 110,
                      height: 90,
                      child: NewsArticleImage(
                        imageUrl: a.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Source badge
                        if (a.sourceName != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD32F2F).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              a.sourceName!.toUpperCase(),
                              style: GoogleFonts.robotoMono(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFD32F2F),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textCol,
                            height: 1.3,
                          ),
                        ),
                        if (summary.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            summary,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.lora(
                              fontSize: 12,
                              color: subCol,
                              height: 1.4,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          dateStr,
                          style: GoogleFonts.robotoMono(
                            fontSize: 10,
                            color: subCol,
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

  String _formatDate(DateTime dt, bool isEn) {
    final months = isEn
        ? ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
        : ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
