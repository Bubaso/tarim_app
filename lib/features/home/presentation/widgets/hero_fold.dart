// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/models/news_article.dart';
import '../../../../core/utils/image_fallback_helper.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../screens/article_detail_screen.dart';
import '../screens/author_article_detail_screen.dart';

// ─── Ayrıştırma yardımcıları ──────────────────────────────────────────────
bool _isHeadline(NewsArticle a) =>
    a.sourceName != null && a.sourceName!.trim().isNotEmpty;

// Şimdilik veritabanında gerçek "Köşe Yazısı" ayrımı olmadığı için,
// AI tarafından üretilen (sourceName == null) makalelerin Yazarlarımız
// sütununu ezmemesi adına hep false dönüyoruz. Böylece mock yazarlar korunur.
bool _isOpEd(NewsArticle a) => false;

// ─── Renk / stil sabitleri ────────────────────────────────────────────────
const double _kDesktopBreakpoint = 900.0;

// ─── Mock Yazar Veri Modeli ───────────────────────────────────────────────
class _MockWriter {
  final String name;
  final String title;
  final String articleTitle;
  final String initial;
  final String avatarUrl;

  const _MockWriter({
    required this.name,
    required this.title,
    required this.articleTitle,
    required this.initial,
    required this.avatarUrl,
  });
}

List<_MockWriter> _getMockWriters(bool isEn) {
  return [
    _MockWriter(
      name: 'Prof. Dr. Ahmet Yılmaz',
      title: isEn ? 'Agricultural Economist' : 'Tarım Ekonomisti',
      articleTitle: isEn ? 'Financial Impacts of Global Fertilizer Crisis on Turkish Agriculture' : 'Küresel Gübre Krizinin Türkiye Tarımına Finansal Etkileri',
      initial: 'A',
      avatarUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=100&auto=format&fit=crop&q=80',
    ),
    _MockWriter(
      name: 'Dr. Selen Soylu',
      title: isEn ? 'Senior Agricultural Engineer' : 'Ziraat Yüksek Mühendisi',
      articleTitle: isEn ? 'Smart Irrigation Technologies and Sustainable Water Management' : 'Akıllı Sulama Teknolojileri ve Sürdürülebilir Su Yönetimi',
      initial: 'S',
      avatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=100&auto=format&fit=crop&q=80',
    ),
    _MockWriter(
      name: 'Mehmet Demir',
      title: isEn ? 'Food and Agriculture Policy Analyst' : 'Gıda ve Tarım Politikaları Analisti',
      articleTitle: isEn ? 'New Paradigms and Digital Transformation in Agricultural Production' : 'Tarımsal Üretimde Yeni Paradigmalar ve Dijital Dönüşüm',
      initial: 'M',
      avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&auto=format&fit=crop&q=80',
    ),
  ];
}

// ═══════════════════════════════════════════════════════════════════════════
//  HeroFold — anasayfanın en üst "above the fold" bölümü
// ═══════════════════════════════════════════════════════════════════════════
class HeroFold extends StatelessWidget {
  final List<NewsArticle> articles;

  const HeroFold({super.key, required this.articles});

  @override
  Widget build(BuildContext context) {
    final headlines = articles.where(_isHeadline).take(8).toList();
    final opEds     = articles.where(_isOpEd).take(6).toList();

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
class _DesktopHeroFold extends StatelessWidget {
  final List<NewsArticle> headlines;
  final List<NewsArticle> opEds;

  const _DesktopHeroFold({required this.headlines, required this.opEds});

  @override
  Widget build(BuildContext context) {
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
class _MobileHeroFold extends StatelessWidget {
  final List<NewsArticle> headlines;
  final List<NewsArticle> opEds;

  const _MobileHeroFold({required this.headlines, required this.opEds});

  @override
  Widget build(BuildContext context) {
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
                  color: isDark ? const Color(0xFFF0F6FC) : const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 40,
                height: 3,
                color: isDark ? const Color(0xFF58A6FF) : const Color(0xFF1A1A1A),
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
      height: 165,
      child: opEds.isEmpty
          ? ListView.builder(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: 3, // _getMockWriters(isEn).length
              itemBuilder: (context, index) {
                final isEn = Localizations.localeOf(context).languageCode == 'en';
                final writers = _getMockWriters(isEn);
                final writer = writers[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: _MobileMockWriterCard(writer: writer, isDark: isDark),
                );
              },
            )
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: opEds.length,
              itemBuilder: (context, index) {
                final article = opEds[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: _MobileRealWriterCard(article: article, isDark: isDark),
                );
              },
            ),
    );
  }
}

class _MobileMockWriterCard extends StatefulWidget {
  final _MockWriter writer;
  final bool isDark;

  const _MobileMockWriterCard({required this.writer, required this.isDark});

  @override
  State<_MobileMockWriterCard> createState() => _MobileMockWriterCardState();
}

class _MobileMockWriterCardState extends State<_MobileMockWriterCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final writer = widget.writer;
    final cardBg = isDark ? const Color(0xFF121820) : Colors.white;
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE5E5E5);
    final nameColor = isDark ? const Color(0xFF58A6FF) : const Color(0xFF004A99);
    final titleColor = isDark ? const Color(0xFFECEFF1) : const Color(0xFF1A1A1A);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          final name = writer.name;
          final isEn = Localizations.localeOf(context).languageCode == 'en';
          final paragraphs = AuthorArticleDetailScreen.getAuthorParagraphs(isEn)[name] ?? (isEn ? [
            'In recent years, structural changes and economic fluctuations in the agricultural sector have led our producers to seek new pursuits. Increasing efficiency and reducing input costs stand out as the most fundamental goals.',
            'The future of agricultural production will be shaped by data-driven planning and the integration of modern technologies. Local producer-oriented policies should be developed for sustainable development.'
          ] : [
            'Son yıllarda tarım sektöründe yaşanan yapısal değişimler ve ekonomik dalgalanmalar, üreticilerimizi yeni arayışlara sevk etmektedir. Verimlilik artışı ve girdi maliyetlerinin azaltılması en temel hedefler olarak öne çıkmaktadır.',
            'Tarımsal üretimin geleceği veriye dayalı planlama ve modern teknolojilerin entegrasyonu ile şekillenecektir. Sürdürülebilir kalkınma için yerel üretici odaklı politikalar geliştirilmelidir.'
          ]);
          final coverImage = _authorArticleCoverImage(name);

          Navigator.of(context).push(
            createFadeRoute(
              AuthorArticleDetailScreen(
                authorName: writer.name,
                authorTitle: writer.title,
                authorAvatarUrl: writer.avatarUrl,
                articleTitle: writer.articleTitle,
                coverImageUrl: coverImage,
                paragraphs: paragraphs,
              ),
            ),
          );
        },
        child: AnimatedScale(
          scale: _hovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Container(
            width: 150,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _hovered ? Theme.of(context).colorScheme.primary : borderColor,
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Image.network(
                      writer.avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: isDark ? const Color(0xFF1E2631) : const Color(0xFFEBEAE6),
                        alignment: Alignment.center,
                        child: Text(
                          writer.initial,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFF8B949E) : const Color(0xFF666666),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  writer.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: nameColor,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    writer.articleTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                      height: 1.25,
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

  String _authorArticleCoverImage(String name) {
    return AuthorArticleDetailScreen.authorCoverImages[name] ??
        'https://images.unsplash.com/photo-1625246333195-78d9c38ad49f?w=900&auto=format&fit=crop&q=80';
  }
}

class _MobileRealWriterCard extends StatefulWidget {
  final NewsArticle article;
  final bool isDark;

  const _MobileRealWriterCard({required this.article, required this.isDark});

  @override
  State<_MobileRealWriterCard> createState() => _MobileRealWriterCardState();
}

class _MobileRealWriterCardState extends State<_MobileRealWriterCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final article = widget.article;
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    final title = (isEn && article.titleEn != null && article.titleEn!.isNotEmpty)
        ? article.titleEn!
        : article.title;
    final authorName = _resolveAuthorName(article, isEn);

    final cardBg = isDark ? const Color(0xFF121820) : Colors.white;
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE5E5E5);
    final nameColor = isDark ? const Color(0xFF58A6FF) : const Color(0xFF004A99);
    final titleColor = isDark ? const Color(0xFFECEFF1) : const Color(0xFF1A1A1A);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          createFadeRoute(ArticleDetailScreen(article: article)),
        ),
        child: AnimatedScale(
          scale: _hovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Container(
            width: 150,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _hovered ? Theme.of(context).colorScheme.primary : borderColor,
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _AuthorAvatar(
                  imageUrl: article.imageUrl,
                  name: authorName.isNotEmpty ? authorName : 'Y',
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                Text(
                  authorName.isNotEmpty ? authorName : (Localizations.localeOf(context).languageCode == 'en' ? 'Columnist' : 'Köşe Yazarı'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: nameColor,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                      height: 1.25,
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

// ═══════════════════════════════════════════════════════════════════════════
//  Manşet Carousel — PageView + Timer + sayfa sayacı (rakamlı)
// ═══════════════════════════════════════════════════════════════════════════
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

  void _resetTimer() {
    _startTimer();
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
            aspectRatio: 1.52, // 16/9'dan %15 daha uzun
            child: ClipRRect(
              borderRadius: isMobile ? BorderRadius.zero : BorderRadius.circular(4),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ── PageView ────────────────────────────────────────────────
                  ScrollConfiguration(
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
                            _resetTimer();
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
                            _resetTimer();
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
                _resetTimer();
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
          onTap: () => Navigator.of(context).push(
            createFadeRoute(ArticleDetailScreen(article: article)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Fotoğraf (16:9 Aspect Ratio)
              NewsArticleImage(
                imageUrl: article.imageUrl,
                fit: BoxFit.cover,
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
                        color: const Color(0xFF004A99),
                        child: Text(
                          article.sourceName!.toUpperCase(),
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
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.2,
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
          color: isDark ? const Color(0xFF161B22) : const Color(0xFFEBEAE6),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(
          'Henüz manşet haberi yok',
          style: GoogleFonts.inter(
            color: isDark ? const Color(0xFF8B949E) : const Color(0xFF888888),
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
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: isDark ? const Color(0xFFF0F6FC) : const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 6),
        // İnce siyah çizgi (Divider)
        Divider(
          height: 1,
          thickness: 1.0,
          color: isDark ? const Color(0xFF30363D) : const Color(0xFF1A1A1A),
        ),
        const SizedBox(height: 12),

        if (opEds.isEmpty)
          // Veritabanında yazar yazısı yoksa 3 adet MOCK yazar kartı
          ..._getMockWriters(isEn).asMap().entries.map((entry) {
            final idx = entry.key;
            final writer = entry.value;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MockWriterCard(writer: writer, isDark: isDark),
                if (idx < _getMockWriters(isEn).length - 1)
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: isDark ? const Color(0xFF21262D) : const Color(0xFFE5E5E5),
                  ),
              ],
            );
          })
        else
          // Veritabanındaki gerçek köşe yazıları
          ...opEds.asMap().entries.map((entry) {
            final idx = entry.key;
            final article = entry.value;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _OpEdCard(article: article, isDark: isDark),
                if (idx < opEds.length - 1)
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: isDark ? const Color(0xFF21262D) : const Color(0xFFE5E5E5),
                  ),
              ],
            );
          }),
      ],
    );
  }
}

// ─── Mock Yazar Kartı ─────────────────────────────────────────────────────
class _MockWriterCard extends StatefulWidget {
  final _MockWriter writer;
  final bool isDark;

  const _MockWriterCard({required this.writer, required this.isDark});

  @override
  State<_MockWriterCard> createState() => _MockWriterCardState();
}

class _MockWriterCardState extends State<_MockWriterCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final titleColor = widget.isDark ? const Color(0xFFECEFF1) : const Color(0xFF1A1A1A);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          final name = widget.writer.name;
          final isEn = Localizations.localeOf(context).languageCode == 'en';
          final paragraphs = AuthorArticleDetailScreen.getAuthorParagraphs(isEn)[name] ?? (isEn ? [
            'In recent years, structural changes and economic fluctuations in the agricultural sector have led our producers to seek new pursuits. Increasing efficiency and reducing input costs stand out as the most fundamental goals.',
            'The future of agricultural production will be shaped by data-driven planning and the integration of modern technologies. Local producer-oriented policies should be developed for sustainable development.'
          ] : [
            'Son yıllarda tarım sektöründe yaşanan yapısal değişimler ve ekonomik dalgalanmalar, üreticilerimizi yeni arayışlara sevk etmektedir. Verimlilik artışı ve girdi maliyetlerinin azaltılması en temel hedefler olarak öne çıkmaktadır.',
            'Tarımsal üretimin geleceği veriye dayalı planlama ve modern teknolojilerin entegrasyonu ile şekillenecektir. Sürdürülebilir kalkınma için yerel üretici odaklı politikalar geliştirilmelidir.'
          ]);
          final coverImage = AuthorArticleDetailScreen.authorCoverImages[name] ??
              'https://images.unsplash.com/photo-1625246333195-78d9c38ad49f?w=900&auto=format&fit=crop&q=80';

          Navigator.of(context).push(
            createFadeRoute(
              AuthorArticleDetailScreen(
                authorName: widget.writer.name,
                authorTitle: widget.writer.title,
                authorAvatarUrl: widget.writer.avatarUrl,
                articleTitle: widget.writer.articleTitle,
                coverImageUrl: coverImage,
                paragraphs: paragraphs,
              ),
            ),
          );
        },
        child: AnimatedScale(
          scale: _hovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Yuvarlak avatar
                ClipOval(
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Image.network(
                      widget.writer.avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: widget.isDark ? const Color(0xFF1E2631) : const Color(0xFFEBEAE6),
                        alignment: Alignment.center,
                        child: Text(
                          widget.writer.initial,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: widget.isDark ? const Color(0xFF8B949E) : const Color(0xFF666666),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Yazar detayları
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.writer.name,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: widget.isDark ? const Color(0xFF58A6FF) : const Color(0xFF004A99),
                        ),
                      ),
                      Text(
                        widget.writer.title,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: widget.isDark ? const Color(0xFF8B949E) : const Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.writer.articleTitle,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _hovered
                              ? (widget.isDark ? const Color(0xFF58A6FF) : const Color(0xFF004A99))
                              : titleColor,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

// ─── Gerçek Köşe Yazısı Kartı ─────────────────────────────────────────────
class _OpEdCard extends StatefulWidget {
  final NewsArticle article;
  final bool isDark;

  const _OpEdCard({required this.article, required this.isDark});

  @override
  State<_OpEdCard> createState() => _OpEdCardState();
}

class _OpEdCardState extends State<_OpEdCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final article = widget.article;

    final title = (isEn && article.titleEn != null && article.titleEn!.isNotEmpty)
        ? article.titleEn!
        : article.title;

    final date = DateFormat.yMMMd(isEn ? 'en_US' : 'tr_TR').format(article.createdAt);
    final authorName = _resolveAuthor(article, isEn);

    final titleColor = widget.isDark
        ? (_hovered ? Colors.white : const Color(0xFFECEFF1))
        : (_hovered ? const Color(0xFF004A99) : const Color(0xFF1A1A1A));

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          createFadeRoute(ArticleDetailScreen(article: article)),
        ),
        child: AnimatedScale(
          scale: _hovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AuthorAvatar(
                  imageUrl: article.imageUrl,
                  name: authorName.isNotEmpty ? authorName : 'Y',
                  isDark: widget.isDark,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        authorName.isNotEmpty ? authorName : (Localizations.localeOf(context).languageCode == 'en' ? 'Columnist' : 'Köşe Yazarı'),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: widget.isDark ? const Color(0xFF58A6FF) : const Color(0xFF004A99),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        date,
                        style: GoogleFonts.robotoMono(
                          fontSize: 9,
                          color: widget.isDark ? const Color(0xFF8B949E) : const Color(0xFF888888),
                        ),
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

  String _resolveAuthor(NewsArticle a, bool isEn) {
    if (a.sourceName != null && a.sourceName!.trim().isNotEmpty) {
      return a.sourceName!.trim();
    }
    if (a.geoLocation != null && a.geoLocation!.trim().isNotEmpty) {
      return a.geoLocation!.trim();
    }
    return '';
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
    final bg = isDark ? const Color(0xFF1E2631) : const Color(0xFFEBEAE6);
    final fg = isDark ? const Color(0xFF8B949E) : const Color(0xFF666666);

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
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

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
                    ? (isDark ? const Color(0xFF58A6FF) : const Color(0xFF004A99))
                    : (isDark ? Colors.white24 : Colors.black12),
              ),
            ),
          ),
        );
      }),
    );
  }
}
