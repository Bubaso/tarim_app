import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../../../../core/utils/image_fallback_helper.dart';
import '../../data/models/news_article.dart';
import '../../providers/home_providers.dart';
import '../screens/article_detail_screen.dart';

/// Makale bittiğinde çıkan "Sonraki haber" çağrısı.
///
/// Otomatik geçiş yerine bilinçli olarak bir kart:
///   • Dibe inince otomatik yönlendirme kaydırmayı gasp eder — İlgili
///     Haberler'e bakmak için aşağı inen okuyucu istemediği bir habere
///     fırlatılır ve geri düğmesi gitmeyi seçmediği bir yerden geri getirir.
///   • Sonraki haberi aynı kaydırma görünümüne eklemek (gerçek sonsuz
///     kaydırma) adres çubuğunu ilk haberde bırakırdı: paylaşılan link yanlış
///     habere giderdi ve `functions/index.js`'in ürettiği sosyal önizleme
///     kartı anlamsızlaşırdı.
///
/// Kart bu ikisini de yapmadan aynı işi görüyor: bir haber = bir adres = bir
/// geçmiş kaydı kuralı bozulmuyor.
class NextArticleCard extends ConsumerStatefulWidget {
  final NewsArticle currentArticle;
  final bool isEn;
  final bool isDark;

  const NextArticleCard({
    super.key,
    required this.currentArticle,
    required this.isEn,
    required this.isDark,
  });

  @override
  ConsumerState<NextArticleCard> createState() => _NextArticleCardState();
}

class _NextArticleCardState extends ConsumerState<NextArticleCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final next = ref.watch(nextArticleProvider(widget.currentArticle.id));
    if (next == null) return const SizedBox.shrink();

    final isEn = widget.isEn;
    final isDark = widget.isDark;

    final title = (isEn && next.titleEn != null && next.titleEn!.isNotEmpty)
        ? next.titleEn!
        : next.title;

    final content = (isEn && next.contentEn != null && next.contentEn!.isNotEmpty)
        ? next.contentEn!
        : next.content;

    // Gövdedeki okuma süresi hesabının aynısı — iki yerde farklı sayı çıkması
    // okuyucuya tutarsız görünürdü.
    final wordCount =
        content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final readMins = (wordCount / 200).ceil().clamp(1, 99);
    final readLabel = isEn ? '$readMins min read' : '$readMins dk okuma';

    final hasSource =
        next.sourceName != null && next.sourceName!.trim().isNotEmpty;

    final onBg = isDark ? AppColors.creamBackground : AppColors.earthText;
    final subtle = isDark
        ? AppColors.wheat
        : AppColors.earthText.withValues(alpha: 0.70);
    final cardBg = isDark ? const Color(0xFF111721) : Colors.white;
    const accent = AppColors.primaryGreen;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: Semantics(
        button: true,
        label: isEn ? 'Up next: $title' : 'Sonraki haber: $title',
        child: InkWell(
          onTap: () =>
              pushScreen(context, ArticleDetailScreen(article: next)),
          borderRadius: BorderRadius.circular(4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _hovered ? accent : AppColors.wheat,
                width: _hovered ? 1.5 : 1.0,
              ),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : const [],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Üst şerit: "SONRAKİ HABER" ────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 16,
                        color: AppColors.wheat,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isEn ? 'UP NEXT' : 'SONRAKİ HABER',
                        style: AppTypography.meta(context, color: subtle)
                            .copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),

                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: NewsArticleImage(
                    imageUrl: next.imageUrl,
                    fit: BoxFit.cover,
                    semanticLabel: title,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.headlineCard(context, color: onBg),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              hasSource
                                  ? '${next.sourceName} · $readLabel'
                                  : readLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.meta(context, color: subtle),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 20,
                            color: accent,
                          ),
                        ],
                      ),
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
