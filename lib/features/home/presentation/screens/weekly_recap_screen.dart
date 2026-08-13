import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../../../../core/utils/image_fallback_helper.dart';
import '../../../../core/utils/iso_week.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../core/widgets/article_timestamp.dart';
import '../../data/models/news_article.dart';
import '../../providers/font_scale_provider.dart';
import '../../providers/home_providers.dart';
import '../widgets/font_size_control_bar.dart';
import '../widgets/portal_footer.dart';
import 'article_detail_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  /hafta/:slug — haftanın özeti
//
//  Haftalık bildirimin indiği yer. Eskiden bildirim tek bir habere
//  gönderiyordu; "haftanın özeti" diyen bir bildirimin tek bir haber açması,
//  vaat edileni vermiyordu. Artık bildirim bu sayfaya iniyor, öne çıkan haber
//  de sayfanın manşetinde duruyor.
//
//  ── Neden "öne çıkanlar", "en çok okunanlar" değil ────────────────────────
//  İlk tasarım haftanın EN ÇOK OKUNAN haberlerini listeleyecekti. Veriye
//  bakıldığında bunun şu an söylenemeyeceği görüldü: 374 haberde toplam 533
//  görüntülenme, medyan 1. Bu sayılarla "haftanın en çok okunanı" demek,
//  3 okunmayla 2 okunmayı yenen bir haberi manşete koymak olurdu — gürültüyü
//  sıralama diye sunmak.
//
//  Bunun yerine sıralama editöryel önem puanına (`hero_score`) dayanıyor ve
//  metin de bunu söylüyor: "öne çıkanlar". Sayılar hiçbir yerde GÖSTERİLMİYOR;
//  "3 okunma" yazan bir manşet sayfanın kendisini küçültür.
//
//  Okuma sayacı güvenilir hâle geldiğinde (cihaz başına tekilleştirme + okuma
//  eşiği; bkz. `data/read_receipts.dart`) ölçüt gerçek okunmaya çevrilecek —
//  o gün gelen değişiklik tek satır: aşağıdaki `_rank` karşılaştırıcısı.
// ═══════════════════════════════════════════════════════════════════════════

class WeeklyRecapScreen extends ConsumerWidget {
  const WeeklyRecapScreen({super.key, required this.week});

  final IsoWeek week;

  /// Haftanın sıralaması: editöryel önem, eşitlikte yeni olan önde.
  ///
  /// Manşetteki gibi bir tazelik bölmesi BİLEREK yok. `hero_score/(yaş+1)^0.8`
  /// burada her hafta Pazar gününün haberini seçerdi; oysa sorulan soru "bu
  /// haftanın en önemlisi", "en yenisi" değil.
  static int _rank(NewsArticle a, NewsArticle b) {
    final byScore = (b.heroScore ?? 0).compareTo(a.heroScore ?? 0);
    return byScore != 0 ? byScore : b.createdAt.compareTo(a.createdAt);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 900;

    final bgColor = isDark ? AppColors.darkGreen : const Color(0xFFF4F4F4);
    final textColor = isDark ? AppColors.wheat : AppColors.earthText;
    final dividerColor = isDark ? Colors.white12 : Colors.black12;

    final recap = ref.watch(weeklyRecapProvider(week));

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: isDark ? const Color(0xFF0A0D10) : Colors.white,
            elevation: 0,
            pinned: true,
            centerTitle: false,
            iconTheme: IconThemeData(color: textColor),
            title: Text(
              isEn ? 'THE WEEK IN REVIEW' : 'HAFTANIN ÖZETİ',
              style: GoogleFonts.inter(
                color: textColor,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 2.0,
              ),
            ),
            actions: [
              FontSizeControlBar(isDark: isDark),
              const SizedBox(width: 12),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: dividerColor, height: 1),
            ),
          ),
          ...recap.when(
            data: (articles) => _body(
              context,
              ref,
              articles: articles.toList()..sort(_rank),
              isEn: isEn,
              isDark: isDark,
              isMobile: isMobile,
            ),
            loading: () => const [
              SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
            // Boş hafta ile yüklenememiş hafta ayrı mesajlar: ikisini
            // birleştirmek, bağlantısı kopmuş okuyucuya "o hafta hiç haber
            // yayımlanmamış" demek olurdu.
            error: (_, __) => [
              SliverFillRemaining(
                child: _Notice(
                  message: isEn
                      ? 'This week could not be loaded.'
                      : 'Bu hafta yüklenemedi.',
                  actionLabel: isEn ? 'Try again' : 'Yeniden dene',
                  onAction: () => ref.invalidate(weeklyRecapProvider(week)),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _body(
    BuildContext context,
    WidgetRef ref, {
    required List<NewsArticle> articles,
    required bool isEn,
    required bool isDark,
    required bool isMobile,
  }) {
    final fontScale = ref.watch(fontScaleProvider);

    return [
      SliverToBoxAdapter(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  _Masthead(
                    week: week,
                    count: articles.length,
                    isEn: isEn,
                    isDark: isDark,
                    isMobile: isMobile,
                    fontScale: fontScale,
                  ),
                  const SizedBox(height: 40),

                  if (articles.isEmpty)
                    _Notice(
                      message: isEn
                          ? 'No articles were published this week.'
                          : 'Bu hafta yayımlanmış haber yok.',
                      isDark: isDark,
                    )
                  else ...[
                    _RecapHero(
                      article: articles.first,
                      isEn: isEn,
                      isMobile: isMobile,
                      fontScale: fontScale,
                    ),
                    if (articles.length > 1) ...[
                      const SizedBox(height: 56),
                      _SectionRule(
                        label: isEn ? 'ALSO THIS WEEK' : 'HAFTANIN DİĞERLERİ',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 32),
                      _RecapGrid(
                        // 24 haber: 51 haberlik bir günü olan akışta haftalık
                        // liste 300 karta ulaşabilirdi. Özet demek seçmek
                        // demek; gerisi zaten ana sayfada ve arşivde.
                        articles: articles.skip(1).take(24).toList(),
                        isEn: isEn,
                        isDark: isDark,
                        isMobile: isMobile,
                        fontScale: fontScale,
                      ),
                    ],
                  ],

                  const SizedBox(height: 56),
                  _WeekNav(week: week, isEn: isEn, isDark: isDark),
                  const SizedBox(height: 64),
                ],
              ),
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(child: PortalFooter(isDark: isDark)),
    ];
  }
}

// ─── Başlık bloğu ──────────────────────────────────────────────────────────

class _Masthead extends StatelessWidget {
  const _Masthead({
    required this.week,
    required this.count,
    required this.isEn,
    required this.isDark,
    required this.isMobile,
    required this.fontScale,
  });

  final IsoWeek week;
  final int count;
  final bool isEn;
  final bool isDark;
  final bool isMobile;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accentFor(isDark: isDark);
    final textColor = isDark ? Colors.white : Colors.black87;
    final mutedColor = isDark ? Colors.white60 : Colors.black54;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 24, height: 2, color: accent),
            const SizedBox(width: 12),
            Text(
              week.ordinalLabel(isEn: isEn).toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          week.label(isEn: isEn),
          style: GoogleFonts.playfairDisplay(
            fontSize: (isMobile ? 30.0 : 46.0) * fontScale,
            fontWeight: FontWeight.w900,
            color: textColor,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          // Sayı vaadi tutuyor: "özet" diyen sayfa neyin özeti olduğunu
          // söylemeli. Görüntülenme sayısı ise BİLEREK yok — bkz. dosya başı.
          count == 0
              ? (isEn ? 'No articles published.' : 'Yayımlanan haber yok.')
              : (isEn
                  ? '$count articles published this week — the highlights below.'
                  : 'Bu hafta $count haber yayımlandı — öne çıkanlar aşağıda.'),
          style: GoogleFonts.lora(
            fontSize: (isMobile ? 15.5 : 17.0) * fontScale,
            color: mutedColor,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _SectionRule extends StatelessWidget {
  const _SectionRule({required this.label, required this.isDark});

  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.wheat : AppColors.earthText;
    return Row(
      children: [
        Container(width: 24, height: 2, color: AppColors.accentFor(isDark: isDark)),
        const SizedBox(width: 16),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            color: textColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 1,
            color: isDark ? Colors.white12 : Colors.black12,
          ),
        ),
      ],
    );
  }
}

// ─── Haftanın öne çıkanı ───────────────────────────────────────────────────

class _RecapHero extends StatelessWidget {
  const _RecapHero({
    required this.article,
    required this.isEn,
    required this.isMobile,
    required this.fontScale,
  });

  final NewsArticle article;
  final bool isEn;
  final bool isMobile;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final title = (isEn && (article.titleEn?.isNotEmpty ?? false))
        ? article.titleEn!
        : article.title;
    final summary = (isEn && (article.summaryEn?.isNotEmpty ?? false))
        ? article.summaryEn!
        : (article.summary ?? '');

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => pushScreen(context, ArticleDetailScreen(article: article)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: isMobile ? 1.0 : 2.4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                NewsArticleImage(
                  imageUrl: article.imageUrl,
                  fit: BoxFit.cover,
                  isHighQuality: true,
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.35, 0.75, 1.0],
                      colors: [
                        Colors.black.withValues(alpha: 0.10),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.65),
                        Colors.black.withValues(alpha: 0.95),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: isMobile ? 16 : 40,
                  right: isMobile ? 16 : 40,
                  bottom: isMobile ? 20 : 40,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: AppColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        child: Text(
                          isEn ? 'STORY OF THE WEEK' : 'HAFTANIN ÖNE ÇIKANI',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: (isMobile ? 26.0 : 44.0) * fontScale,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ArticleTimestamp(
                        published: article.createdAt,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                      if (summary.isNotEmpty && !isMobile) ...[
                        const SizedBox(height: 14),
                        Text(
                          summary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.lora(
                            fontSize: 17.0 * fontScale,
                            color: Colors.white70,
                            height: 1.4,
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
    );
  }
}

// ─── Kalan haberler ────────────────────────────────────────────────────────

class _RecapGrid extends StatelessWidget {
  const _RecapGrid({
    required this.articles,
    required this.isEn,
    required this.isDark,
    required this.isMobile,
    required this.fontScale,
  });

  final List<NewsArticle> articles;
  final bool isEn;
  final bool isDark;
  final bool isMobile;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    // Mobilde tek sütun; masaüstünde üçlü satırlar. `GridView` yerine elle
    // kurulmuş `Row`lar: kartların yüksekliği başlık uzunluğuna göre değişiyor
    // ve sabit en/boy oranı kısa başlıklı kartların altında büyük boşluklar
    // bırakıyordu.
    if (isMobile) {
      return Column(
        children: [
          for (var i = 0; i < articles.length; i++) ...[
            _RecapCard(
              article: articles[i],
              rank: i + 2,
              isEn: isEn,
              isDark: isDark,
              fontScale: fontScale,
            ),
            if (i != articles.length - 1)
              Divider(
                height: 40,
                color: isDark ? Colors.white12 : Colors.black12,
              ),
          ],
        ],
      );
    }

    const columns = 3;
    final rows = <Widget>[];
    for (var i = 0; i < articles.length; i += columns) {
      final cells = <Widget>[];
      for (var c = 0; c < columns; c++) {
        if (c > 0) cells.add(const SizedBox(width: 32));
        final index = i + c;
        cells.add(
          Expanded(
            // Son satır eksik kalabilir; boş `Expanded` kartların genişliğini
            // korur, aksi hâlde tek kalan haber satırın tamamına yayılırdı.
            child: index < articles.length
                ? _RecapCard(
                    article: articles[index],
                    rank: index + 2,
                    isEn: isEn,
                    isDark: isDark,
                    fontScale: fontScale,
                  )
                : const SizedBox.shrink(),
          ),
        );
      }
      rows.add(
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: cells),
      );
      if (i + columns < articles.length) rows.add(const SizedBox(height: 48));
    }
    return Column(children: rows);
  }
}

class _RecapCard extends StatefulWidget {
  const _RecapCard({
    required this.article,
    required this.rank,
    required this.isEn,
    required this.isDark,
    required this.fontScale,
  });

  final NewsArticle article;
  final int rank;
  final bool isEn;
  final bool isDark;
  final double fontScale;

  @override
  State<_RecapCard> createState() => _RecapCardState();
}

class _RecapCardState extends State<_RecapCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    final title = (widget.isEn && (a.titleEn?.isNotEmpty ?? false))
        ? a.titleEn!
        : a.title;
    final textColor = widget.isDark ? Colors.white : Colors.black87;
    final accent = AppColors.accentFor(isDark: widget.isDark);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => pushScreen(context, ArticleDetailScreen(article: a)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NewsArticleImage(imageUrl: a.imageUrl, fit: BoxFit.cover),
                  if (_hovered)
                    ColoredBox(
                      color: AppColors.primaryGreen.withValues(alpha: 0.12),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sıra numarası listenin bir SIRALAMA olduğunu görünür kılıyor;
                // sayfanın vaadi "haftanın öne çıkanları" ve numara bunu
                // hatırlatıyor. Bir ölçüm değeri değil, yalnızca konum.
                Padding(
                  padding: const EdgeInsets.only(right: 10, top: 2),
                  child: Text(
                    '${widget.rank}',
                    style: GoogleFonts.inter(
                      fontSize: 13 * widget.fontScale,
                      fontWeight: FontWeight.w900,
                      color: accent,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20.0 * widget.fontScale,
                      fontWeight: FontWeight.w900,
                      color: _hovered ? AppColors.primaryGreen : textColor,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ArticleTimestamp(
              published: a.createdAt,
              color: widget.isDark
                  ? AppColors.wheat
                  : AppColors.earthText.withValues(alpha: 0.70),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Haftalar arası gezinme ────────────────────────────────────────────────

/// Önceki/sonraki hafta bağlantıları — arşivi yürünebilir kılan tek şey.
///
/// İleri yön GELECEĞE gitmiyor: içinde bulunulan haftadan sonrası her zaman
/// boş olacağı için o bağlantı gizleniyor.
class _WeekNav extends StatelessWidget {
  const _WeekNav({required this.week, required this.isEn, required this.isDark});

  final IsoWeek week;
  final bool isEn;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final current = IsoWeek.of(DateTime.now());
    final next = week.next;
    final showNext = !next.isAfter(current);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _NavLink(
          week: week.previous,
          label: isEn ? 'Previous week' : 'Önceki hafta',
          icon: Icons.arrow_back_rounded,
          leadingIcon: true,
          isDark: isDark,
          isEn: isEn,
        ),
        if (showNext)
          _NavLink(
            week: next,
            label: isEn ? 'Next week' : 'Sonraki hafta',
            icon: Icons.arrow_forward_rounded,
            leadingIcon: false,
            isDark: isDark,
            isEn: isEn,
          ),
      ],
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.week,
    required this.label,
    required this.icon,
    required this.leadingIcon,
    required this.isDark,
    required this.isEn,
  });

  final IsoWeek week;
  final String label;
  final IconData icon;
  final bool leadingIcon;
  final bool isDark;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accentFor(isDark: isDark);
    final mutedColor = isDark ? Colors.white60 : Colors.black54;

    final text = Column(
      crossAxisAlignment:
          leadingIcon ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: accent,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          week.label(isEn: isEn),
          style: GoogleFonts.lora(fontSize: 14, color: mutedColor),
        ),
      ],
    );

    return InkWell(
      // `go` değil `push`: geri düğmesi haftalar arasında gezinmenin izini
      // korumalı. Bildirimden gelen okuyucu için de geri, geldiği yere döner.
      onTap: () => GoRouter.of(context).push(weekPath(week)),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: leadingIcon
              ? [Icon(icon, size: 18, color: accent), const SizedBox(width: 10), text]
              : [text, const SizedBox(width: 10), Icon(icon, size: 18, color: accent)],
        ),
      ),
    );
  }
}

// ─── Boş / hatalı durum ────────────────────────────────────────────────────

class _Notice extends StatelessWidget {
  const _Notice({
    required this.message,
    required this.isDark,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final bool isDark;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white70 : Colors.black54;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.lora(fontSize: 17, color: textColor),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
