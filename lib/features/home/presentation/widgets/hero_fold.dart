// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:ui';
import 'package:tarim_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/models/news_article.dart';
import '../../../../core/utils/image_fallback_helper.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../core/theme/app_typography.dart';
import '../screens/article_detail_screen.dart';
import '../screens/author_article_detail_screen.dart';
import 'ai_columnists.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../providers/home_providers.dart';


// ─── Ayrıştırma yardımcıları ──────────────────────────────────────────────
bool _isHeadline(NewsArticle a) {
  return true; // We use smart filtering now instead of just sourceName
}

// Köşe yazarı makalesi mi? source_name'e bakarak kontrol eder.
bool _isOpEd(NewsArticle a) {
  return aiColumnists.any((col) => col.name == a.sourceName?.trim());
}

// ─── Renk / stil sabitleri ────────────────────────────────────────────────
const double _kDesktopBreakpoint = 900.0;

// ═══════════════════════════════════════════════════════════════════════════
//  HeroFold — anasayfanın en üst "above the fold" bölümü
// ═══════════════════════════════════════════════════════════════════════════
class HeroFold extends ConsumerWidget {
  final List<NewsArticle> articles;

  const HeroFold({super.key, required this.articles});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider); // Rebuild when language changes
    final headlines = articles;

    // Yazar yazılarını tüm yayınlanmış makaleler arasından çek (hero listesinden değil!)
    final allArticlesAsync = ref.watch(latestArticlesProvider);
    final allPublished = allArticlesAsync.valueOrNull ?? [];
    final opEds = allPublished.where(_isOpEd).toList();

    final width = MediaQuery.of(context).size.width;

    if (width >= _kDesktopBreakpoint) {
      return _DesktopHeroFold(headlines: headlines, opEds: opEds);
    } else {
      return _MobileHeroFold(headlines: headlines, opEds: opEds);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Masaüstü: 7:3 Row — Carousel | Op-Ed Sütunu
// ═══════════════════════════════════════════════════════════════════════════
class _DesktopHeroFold extends ConsumerWidget {
  final List<NewsArticle> headlines;
  final List<NewsArticle> opEds;

  const _DesktopHeroFold({required this.headlines, required this.opEds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider); // Rebuild when language changes
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sol %70 — Manşet Galerisi
              Expanded(
                flex: 7,
                child: headlines.isEmpty
                    ? _EmptySlot(isDark: isDark)
                    : _HeadlineCarousel(headlines: headlines),
              ),
              const SizedBox(width: 28),
              // Sağ %30 — Köşe Yazıları / Yazarlarımız
              Expanded(
                flex: 3,
                child: _OpEdColumn(opEds: opEds, isDark: isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Mobil: Column — Carousel, ardından Op-Ed Listesi
// ═══════════════════════════════════════════════════════════════════════════
class _MobileHeroFold extends ConsumerWidget {
  final List<NewsArticle> headlines;
  final List<NewsArticle> opEds;

  const _MobileHeroFold({required this.headlines, required this.opEds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider); // Rebuild when language changes
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Üst — Manşet Galerisi (Edge-to-edge on mobile)
        if (headlines.isNotEmpty)
          _HeadlineCarousel(headlines: headlines),
        const SizedBox(height: 28),
        
        // "Yazarlarımız" Bölüm Başlığı (16px Padding ile)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEn ? 'OUR COLUMNISTS' : 'YAZARLARIMIZ',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isDark ? AppColors.creamBackground : AppColors.earthText,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 40,
                height: 3,
                color: isDark ? AppColors.primaryGreen : AppColors.earthText,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Yatay kaydırılabilir yazar listesi
        _MobileOpEdHorizontalList(opEds: opEds, isDark: isDark),
      ],
    );
  }
}

String _resolveAuthorName(NewsArticle a, bool isEn) {
  if (a.sourceName != null && a.sourceName!.trim().isNotEmpty) {
    return a.sourceName!.trim();
  }
  if (a.geoLocation != null && a.geoLocation!.trim().isNotEmpty) {
    return a.geoLocation!.trim();
  }
  return '';
}

class _MobileOpEdHorizontalList extends StatelessWidget {
  final List<NewsArticle> opEds;
  final bool isDark;

  const _MobileOpEdHorizontalList({required this.opEds, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: aiColumnists.length,
        itemBuilder: (context, index) {
          final col = aiColumnists[index];
          // Find if this columnist has an article
          final article = opEds.where((a) => a.sourceName?.trim() == col.name).firstOrNull;
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: _MobileRealWriterCard(columnist: col, article: article, isDark: isDark),
          );
        },
      ),
    );
  }
}

class _MobileRealWriterCard extends StatefulWidget {
  final AiColumnist columnist;
  final NewsArticle? article;
  final bool isDark;

  const _MobileRealWriterCard({required this.columnist, this.article, required this.isDark});

  @override
  State<_MobileRealWriterCard> createState() => _MobileRealWriterCardState();
}

class _MobileRealWriterCardState extends State<_MobileRealWriterCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final article = widget.article;
    final col = widget.columnist;
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    final title = article != null 
        ? ((isEn && article.titleEn != null && article.titleEn!.isNotEmpty) ? article.titleEn! : article.title)
        : (isEn ? 'Analysis in progress...' : 'Yeni yazısı hazırlanıyor...');

    // Newspaper aesthetic colors
    final cardBg = isDark ? const Color(0xFF1E242B) : const Color(0xFFF9F7F1); // Slightly beige/cream for light mode
    final borderColor = isDark ? AppColors.wheat.withOpacity(0.3) : const Color(0xFFE5DCC5);
    final nameColor = isDark ? AppColors.primaryGreen : const Color(0xFF1B3B36);
    final titleColor = isDark ? AppColors.creamBackground : const Color(0xFF2C2C2A);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
            pushScreen(context, AuthorArticleDetailScreen(columnist: col));
        },
        child: AnimatedScale(
          scale: _hovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Container(
            width: 160,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _hovered ? Theme.of(context).colorScheme.primary : borderColor,
                width: _hovered ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Quote watermark
                Positioned(
                  right: -10,
                  top: -10,
                  child: Text(
                    '"',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 80,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Image.network(
                          col.avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: isDark ? AppColors.wheat : const Color(0xFFEBEAE6),
                            alignment: Alignment.center,
                            child: Text(
                              col.name[0],
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.wheat : AppColors.earthText,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      col.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: nameColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 12,
                          fontWeight: article != null ? FontWeight.w700 : FontWeight.w400,
                          fontStyle: article != null ? FontStyle.normal : FontStyle.italic,
                          color: titleColor,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeadlineCarousel extends StatefulWidget {
  final List<NewsArticle> headlines;

  const _HeadlineCarousel({required this.headlines});

  @override
  State<_HeadlineCarousel> createState() => _HeadlineCarouselState();
}

class _HeadlineCarouselState extends State<_HeadlineCarousel> {
  late final PageController _pc;
  Timer? _timer;
  int _current = 0;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _pc = PageController();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted) return;
      final next = (_current + 1) % widget.headlines.length;
      _pc.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.headlines.length;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < _kDesktopBreakpoint;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AspectRatio(
            aspectRatio: 1.8, // 16/9'a yakın geniş (daha dar kutu, kaplama için daha uygun)
            child: ClipRRect(
              borderRadius: isMobile ? BorderRadius.zero : BorderRadius.circular(4),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ── PageView ────────────────────────────────────────────────
                  NotificationListener<UserScrollNotification>(
                    onNotification: (notification) {
                      _stopTimer();
                      return false; // Let the scroll propagate
                    },
                    child: Listener(
                      onPointerDown: (_) => _stopTimer(),
                      child: ScrollConfiguration(
                        behavior: AppScrollBehavior(),
                        child: PageView.builder(
                          controller: _pc,
                          itemCount: total,
                          onPageChanged: (i) => setState(() => _current = i),
                          itemBuilder: (context, index) {
                            final article = widget.headlines[index];
                            return _HeadlineSlide(article: article);
                          },
                        ),
                      ),
                    ),
                  ),

                  // ── Sol / Sağ Manuel Oklar ──────────────────────────────
                  if (!isMobile && total > 1) ...[
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 250),
                      left: _isHovered ? 16 : -50,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _CarouselArrowButton(
                          icon: Icons.chevron_left,
                          onTap: () {
                            _stopTimer();
                            final prev = (_current - 1 + total) % total;
                            _pc.animateToPage(
                              prev,
                              duration: const Duration(milliseconds: 450),
                              curve: Curves.easeOutCubic,
                            );
                          },
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 250),
                      right: _isHovered ? 16 : -50,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _CarouselArrowButton(
                          icon: Icons.chevron_right,
                          onTap: () {
                            _stopTimer();
                            final next = (_current + 1) % total;
                            _pc.animateToPage(
                              next,
                              duration: const Duration(milliseconds: 450),
                              curve: Curves.easeOutCubic,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Nokta göstergeleri
          if (total > 1)
            _PageDotsIndicator(
              current: _current,
              total: total,
              onDotTapped: (index) {
                _stopTimer();
                _pc.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutCubic,
                );
              },
            ),
        ],
      ),
    );
  }
}

// ─── Tek bir manşet slaytı ────────────────────────────────────────────────
class _HeadlineSlide extends StatelessWidget {
  final NewsArticle article;

  const _HeadlineSlide({required this.article});

  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final title = (isEn && article.titleEn != null && article.titleEn!.isNotEmpty)
        ? article.titleEn!
        : article.title;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: MergeSemantics(
        child: GestureDetector(
          onTap: () => pushScreen(context, ArticleDetailScreen(article: article),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Tek Görsel: Kutuyu tam dolduran, yüksek kaliteli (cover)
              NewsArticleImage(
                imageUrl: article.imageUrl,
                fit: BoxFit.cover,
                isHighQuality: true,
                semanticLabel: title,
              ),

            // Alttan yukarı siyah gradient karartma
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.25, 0.65, 1.0],
                  colors: [
                    Colors.transparent,
                    Color(0x7F000000),
                    Color(0xDD000000),
                  ],
                ),
              ),
            ),

            // Kaynak rozeti + Başlık (Playfair Display)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (article.sourceName != null &&
                      article.sourceName!.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        color: AppColors.primaryGreen,
                        child: Text(
                          article.sourceName!.toTurkishUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.headlineHome(context, color: Colors.white).copyWith(
                      shadows: const [
                        Shadow(
                          color: Color(0x88000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}



// ─── Boş durum (headline yoksa) ───────────────────────────────────────────
class _EmptySlot extends StatelessWidget {
  final bool isDark;

  const _EmptySlot({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkGreen : const Color(0xFFEBEAE6),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(
          'Henüz manşet haberi yok',
          style: GoogleFonts.inter(
            color: isDark ? AppColors.wheat : const Color(0xFF888888),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Yazarlarımız Sütunu (Op-Ed & Mock)
// ═══════════════════════════════════════════════════════════════════════════
class _OpEdColumn extends StatelessWidget {
  final List<NewsArticle> opEds;
  final bool isDark;

  const _OpEdColumn({required this.opEds, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // "Yazarlarımız" başlığı
        Text(
          isEn ? 'OUR COLUMNISTS' : 'YAZARLARIMIZ',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: isDark ? AppColors.creamBackground : AppColors.earthText,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 40,
          height: 3,
          color: isDark ? AppColors.primaryGreen : AppColors.earthText,
        ),
        const SizedBox(height: 16),
        
        // Yazar Listesi — IntrinsicHeight ile uyumlu olması için Expanded yerine Container
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B22) : const Color(0xFFF9F7F1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isDark ? AppColors.wheat.withOpacity(0.1) : const Color(0xFFEAE3CD),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int index = 0; index < aiColumnists.length; index++) ...[
                if (index > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: isDark ? AppColors.wheat.withOpacity(0.1) : const Color(0xFFEAE3CD),
                    indent: 16,
                    endIndent: 16,
                  ),
                Builder(builder: (context) {
                  final col = aiColumnists[index];
                  final article = opEds.where((a) => a.sourceName?.trim() == col.name).firstOrNull;
                  return _OpEdCard(columnist: col, article: article, isDark: isDark);
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _OpEdCard extends StatefulWidget {
  final AiColumnist columnist;
  final NewsArticle? article;
  final bool isDark;

  const _OpEdCard({required this.columnist, this.article, required this.isDark});

  @override
  State<_OpEdCard> createState() => _OpEdCardState();
}

class _OpEdCardState extends State<_OpEdCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final col = widget.columnist;
    final article = widget.article;
    final isDark = widget.isDark;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    
    final title = article != null 
        ? ((isEn && article.titleEn != null && article.titleEn!.isNotEmpty) ? article.titleEn! : article.title)
        : (isEn ? 'Analysis in progress...' : 'Yeni yazısı hazırlanıyor...');

    final hoverBgColor = isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02);
    final nameColor = isDark ? AppColors.primaryGreen : const Color(0xFF1B3B36);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
            pushScreen(context, AuthorArticleDetailScreen(columnist: col));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: _hovered ? hoverBgColor : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Image.network(
                    col.avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: isDark ? AppColors.wheat : const Color(0xFFEBEAE6),
                      alignment: Alignment.center,
                      child: Text(
                        col.name[0],
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.wheat : AppColors.earthText,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      col.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: nameColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 14,
                        fontWeight: article != null ? FontWeight.w700 : FontWeight.w400,
                        fontStyle: article != null ? FontStyle.normal : FontStyle.italic,
                        color: isDark ? AppColors.creamBackground : const Color(0xFF2C2C2A),
                        height: 1.3,
                      ),
                    ),
                    if (article != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        isEn ? 'Read article →' : 'Yazıyı oku →',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.wheat : const Color(0xFF888888),
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
    );
  }
}


class _AuthorAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final bool isDark;

  const _AuthorAvatar({
    required this.imageUrl,
    required this.name,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const double size = 44;
    final bg = isDark ? AppColors.wheat : const Color(0xFFEBEAE6);
    final fg = isDark ? AppColors.wheat : AppColors.earthText;

    final url = imageUrl?.trim();
    final hasImage = url != null &&
        url.isNotEmpty &&
        (url.startsWith('http://') || url.startsWith('https://'));

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: hasImage
            ? Image.network(
                url,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _InitialAvatar(name: name, bg: bg, fg: fg, size: size),
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : _InitialAvatar(name: name, bg: bg, fg: fg, size: size),
              )
            : _InitialAvatar(name: name, bg: bg, fg: fg, size: size),
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  final String name;
  final Color bg;
  final Color fg;
  final double size;

  const _InitialAvatar({
    required this.name,
    required this.bg,
    required this.fg,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toTurkishUpperCase() : '?';

    return Container(
      width: size,
      height: size,
      color: bg,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.playfairDisplay(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

// ─── Desktop Drag-to-Scroll Desteği ──────────────────────────────────────
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

// ─── Carousel Sol/Sağ Ok Butonu ──────────────────────────────────────────
class _CarouselArrowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CarouselArrowButton({required this.icon, required this.onTap});

  @override
  State<_CarouselArrowButton> createState() => _CarouselArrowButtonState();
}

class _CarouselArrowButtonState extends State<_CarouselArrowButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isHovered
                ? Colors.black.withOpacity(0.85)
                : Colors.black.withOpacity(0.5),
            border: Border.all(
              color: Colors.white.withOpacity(_isHovered ? 0.8 : 0.4),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}

// ─── Carousel Nokta Göstergeleri ──────────────────────────────────────────
class _PageDotsIndicator extends StatelessWidget {
  final int current;
  final int total;
  final ValueChanged<int> onDotTapped;

  const _PageDotsIndicator({
    required this.current,
    required this.total,
    required this.onDotTapped,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final isActive = index == current;
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => onDotTapped(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 20.0 : 8.0,
              height: 8.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isActive
                    ? (isDark ? AppColors.primaryGreen : AppColors.primaryGreen)
                    : (isDark ? Colors.white24 : Colors.black12),
              ),
            ),
          ),
        );
      }),
    );
  }
}
