// ignore_for_file: deprecated_member_use
import 'dart:ui';
import 'package:tarim_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../../data/models/news_article.dart';
import '../../../../core/utils/image_fallback_helper.dart';
import '../../../../core/theme/app_typography.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../../providers/home_providers.dart';

// ─── Renk sabitleri ───────────────────────────────────────────────────────
const Color _kAccent      = AppColors.primaryGreen;
const Color _kAccentDark  = AppColors.primaryGreen;
const Color _kBgLight     = AppColors.creamBackground;
const Color _kBgDark      = AppColors.darkGreen;
const Color _kSurfaceDark = Color(0xFF111721);

// ═══════════════════════════════════════════════════════════════════════════
//  ArticleDetailScreen — tam sayfa makale okuma deneyimi
// ═══════════════════════════════════════════════════════════════════════════

class ArticleDetailScreen extends ConsumerStatefulWidget {
  final NewsArticle article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  ConsumerState<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends ConsumerState<ArticleDetailScreen> {
  late final ScrollController _scrollController;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(() {
      final isScrolled = _scrollController.offset > 150;
      if (_isScrolled != isScrolled) {
        setState(() {
          _isScrolled = isScrolled;
        });
      }
    });

    // Increment view count when article is opened
    Future.microtask(() {
      ref.read(homeRepositoryProvider).incrementArticleViewCount(widget.article.id);
      ref.read(readArticlesProvider.notifier).markAsRead(widget.article.id);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    final theme  = Theme.of(context);
    final isEn   = Localizations.localeOf(context).languageCode == 'en';
    final isDark = theme.brightness == Brightness.dark;

    final displayTitle = (isEn && article.titleEn != null && article.titleEn!.isNotEmpty)
        ? article.titleEn!
        : article.title;

    final displayContent = (isEn && article.contentEn != null && article.contentEn!.isNotEmpty)
        ? article.contentEn!
        : article.content;

    final displaySpot = (isEn && article.spotEn != null && article.spotEn!.isNotEmpty)
        ? article.spotEn!
        : (article.spot ?? article.summary ?? '');

    final displayTakeaways = (isEn && article.keyTakeawaysEn != null && article.keyTakeawaysEn!.isNotEmpty)
        ? article.keyTakeawaysEn!
        : (article.keyTakeaways ?? []);

    final displayInsight = (isEn && article.expertInsightEn != null && article.expertInsightEn!.isNotEmpty)
        ? article.expertInsightEn!
        : (article.expertInsight ?? '');
        
    final formattedDate = DateFormat.yMMMd(isEn ? 'en_US' : 'tr_TR')
        .add_Hm()
        .format(article.createdAt);

    final wordCount = displayContent
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;
    final readMins = (wordCount / 200).ceil().clamp(1, 99);
    final readLabel = isEn ? '$readMins min read' : '$readMins dk okuma';

    final hasSource = article.sourceName != null &&
        article.sourceName!.trim().isNotEmpty;
    final hasSourceUrl = article.sourceUrl != null &&
        article.sourceUrl!.trim().isNotEmpty;

    final bg     = isDark ? _kBgDark  : _kBgLight;
    final onBg   = isDark ? AppColors.creamBackground : AppColors.earthText;
    final subtle = isDark ? AppColors.wheat : AppColors.earthText;
    final accent = isDark ? _kAccentDark : _kAccent;

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop   = screenWidth > 900;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── 16:9 Hero Görseli (Sayfanın en üstünde) ─────────────────
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 900 : double.infinity,
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: isDesktop ? 24 : 0,
                        left: isDesktop ? 24 : 0,
                        right: isDesktop ? 24 : 0,
                      ),
                      child: ClipRRect(
                        borderRadius: isDesktop
                            ? BorderRadius.circular(12)
                            : BorderRadius.zero,
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Tek Görsel: Kutuyu tam dolduran, yüksek kaliteli (cover)
                              NewsArticleImage(
                                imageUrl: article.imageUrl,
                                fit: BoxFit.cover,
                                isHighQuality: true,
                                semanticLabel: displayTitle,
                              ),
                              // Alt gradient — başlık alanına geçişi yumuşatır
                              const DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    stops: [0.55, 1.0],
                                    colors: [Color(0x00000000), Color(0x55000000)],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Makale içeriği ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 24 : 20,
                        vertical: 36,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Meta: kaynak + tarih + okuma süresi ──────────
                          _MetaRow(
                            hasSource:    hasSource,
                            sourceName:   article.sourceName ?? '',
                            formattedDate: formattedDate,
                            readLabel:    readLabel,
                            accent:       accent,
                            subtle:       subtle,
                            viewCount:    article.viewCount,
                          ),
                          const SizedBox(height: 20),

                          // ── Başlık (Libre Franklin, H1) ─────────────────────
                          Text(
                            displayTitle,
                            style: AppTypography.headlineDetail(context, color: onBg),
                          ),
                          const SizedBox(height: 24),

                          // ── Özet (Spot) ─────────────────────────────
                          if (displaySpot.isNotEmpty) ...[
                            Text(
                              displaySpot,
                              style: AppTypography.deck(
                                context,
                                color: isDark
                                    ? const Color(0xFFB0BEC5)
                                    : const Color(0xFF424242),
                              ),
                            ),
                            const SizedBox(height: 28),
                          ],
                          
                          // ── Anahtar Çıkarımlar ──────────────────────────
                          if (displayTakeaways.isNotEmpty) ...[
                             _KeyTakeawaysBox(takeaways: displayTakeaways, isEn: isEn, isDark: isDark, accent: accent),
                             const SizedBox(height: 28),
                          ],

                          // ── Bölme çizgisi ─────────────────────────────────
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: isDark
                                ? AppColors.wheat
                                : AppColors.wheat,
                          ),
                          const SizedBox(height: 28),

                          // ── Dinamik Grafik ─────────────────────────────
                          if (article.chartData != null) ...[
                             _DynamicChart(chartData: article.chartData!, isDark: isDark, accent: accent),
                             const SizedBox(height: 28),
                          ],

                          // ── Gövde metni (Html) ─────
                          Html(
                            data: displayContent,
                            style: {
                              "body": Style(
                                margin: Margins.zero,
                                padding: HtmlPaddings.zero,
                                fontSize: FontSize(18),
                                fontFamily: GoogleFonts.lora().fontFamily,
                                color: isDark ? const Color(0xFFCFD8DC) : const Color(0xFF2C2C2A),
                                lineHeight: const LineHeight(1.6),
                              ),
                              "p": Style(
                                margin: Margins.only(bottom: 16),
                              ),
                              "img": Style(
                                width: Width(100, Unit.percent),
                                height: Height.auto(),
                              ),
                              "h2": Style(
                                margin: Margins.only(top: 24, bottom: 16),
                                fontFamily: GoogleFonts.libreFranklin().fontFamily,
                                fontSize: FontSize(22),
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              "blockquote": Style(
                                margin: Margins.only(left: 16, right: 0, top: 16, bottom: 16),
                                padding: HtmlPaddings.only(left: 16),
                                border: Border(left: BorderSide(color: accent, width: 4)),
                                fontStyle: FontStyle.italic,
                                color: isDark ? AppColors.wheat : AppColors.earthText,
                              ),
                              "table": Style(
                                margin: Margins.symmetric(vertical: 24),
                                width: Width(100, Unit.percent),
                                border: Border.all(color: isDark ? const Color(0xFF2C394B) : const Color(0xFFEEEEEE)),
                              ),
                              "th": Style(
                                padding: HtmlPaddings.all(12),
                                backgroundColor: isDark ? const Color(0xFF1B232E) : const Color(0xFFF8F9FA),
                                fontWeight: FontWeight.bold,
                                border: Border.all(color: isDark ? const Color(0xFF2C394B) : const Color(0xFFEEEEEE)),
                              ),
                              "td": Style(
                                padding: HtmlPaddings.all(12),
                                border: Border.all(color: isDark ? const Color(0xFF2C394B) : const Color(0xFFEEEEEE)),
                              ),
                            },
                          ),
                          
                          // ── Uzman Görüşü ─────────────────────────────
                          if (displayInsight.isNotEmpty) ...[
                             const SizedBox(height: 36),
                             _ExpertInsightBox(insight: displayInsight, isEn: isEn, isDark: isDark, accent: accent),
                          ],

                          // ── Etiketler ─────────────────────────────────────
                          if (article.seoKeywords != null &&
                              article.seoKeywords!.isNotEmpty) ...[
                            const SizedBox(height: 36),
                            _KeywordsRow(
                              keywords: article.seoKeywords!,
                              accent: accent,
                              isDark: isDark,
                            ),
                          ],

                          if (hasSourceUrl) ...[
                            const SizedBox(height: 40),
                            _SourceButton(
                              sourceName: article.sourceName ?? (isEn ? 'Source' : 'Kaynak'),
                              sourceUrl:  article.sourceUrl!,
                              isEn:       isEn,
                              accent:     accent,
                            ),
                          ],

                          const SizedBox(height: 48),
                          _ShareBar(article: article, isDark: isDark, isEn: isEn, accent: accent),

                          const SizedBox(height: 56),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── İlgili Haberler bölümü ────────────────────────────────────
              SliverToBoxAdapter(
                child: _RelatedSection(
                  currentId: article.id,
                  isEn:      isEn,
                  isDark:    isDark,
                ),
              ),

              // Alt boşluk
              const SliverToBoxAdapter(child: SizedBox(height: 48)),
            ],
          ),
          
          // ── Modern Dinamik AppBar ─────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                left: 8,
                right: 16,
              ),
              height: MediaQuery.of(context).padding.top + kToolbarHeight,
              decoration: BoxDecoration(
                color: _isScrolled ? bg.withValues(alpha: 0.98) : Colors.transparent,
                boxShadow: _isScrolled
                    ? [
                        BoxShadow(
                          color: isDark ? Colors.black45 : Colors.black12,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Geri Butonu
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isScrolled
                          ? Colors.transparent
                          : (isDark ? const Color(0xAA0C1015) : const Color(0xAAFAF9F6)),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 19,
                        color: _isScrolled
                            ? onBg
                            : (isDark ? Colors.white : AppColors.earthText),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Dinamik Başlık
                  Expanded(
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      offset: _isScrolled ? Offset.zero : const Offset(0, 0.5),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        opacity: _isScrolled ? 1.0 : 0.0,
                        child: Text(
                          displayTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.headlineCard(context, color: onBg),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Başlığı merkeze yakın tutmak için sağ boşluk
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// ═══════════════════════════════════════════════════════════════════════════
//  Meta satırı: Kaynak etiketi + tarih + okuma süresi
// ═══════════════════════════════════════════════════════════════════════════

class _MetaRow extends StatelessWidget {
  final bool hasSource;
  final String sourceName;
  final String formattedDate;
  final String readLabel;
  final Color accent;
  final Color subtle;
  final int viewCount;

  const _MetaRow({
    required this.hasSource,
    required this.sourceName,
    required this.formattedDate,
    required this.readLabel,
    required this.accent,
    required this.subtle,
    this.viewCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (hasSource)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              border: Border.all(color: accent.withValues(alpha: 0.3)),
            ),
            child: Text(
              sourceName.toUpperCase(),
              style: GoogleFonts.inter(
                color: accent,
                fontWeight: FontWeight.w800,
                fontSize: 10,
                letterSpacing: 0.8,
              ),
            ),
          ),
        Text(
          '$formattedDate  •  $readLabel',
          style: GoogleFonts.robotoMono(
            color: subtle,
            fontSize: 11,
          ),
        ),
        if (viewCount > 0)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 14),
              const SizedBox(width: 4),
              Text(
                '$viewCount',
                style: GoogleFonts.robotoMono(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  SEO Etiketleri
// ═══════════════════════════════════════════════════════════════════════════

class _KeywordsRow extends StatelessWidget {
  final List<String> keywords;
  final Color accent;
  final bool isDark;

  const _KeywordsRow({
    required this.keywords,
    required this.accent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final chipBg = isDark ? AppColors.wheat : const Color(0xFFEBE3D5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Localizations.localeOf(context).languageCode == 'en'
              ? 'TAGS'
              : 'ETİKETLER',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: isDark ? AppColors.wheat : const Color(0xFF888888),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: keywords.map((kw) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                '#$kw',
                style: GoogleFonts.inter(
                  color: accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Kaynak butonu
// ═══════════════════════════════════════════════════════════════════════════

class _SourceButton extends StatelessWidget {
  final String sourceName;
  final String sourceUrl;
  final bool isEn;
  final Color accent;

  const _SourceButton({
    required this.sourceName,
    required this.sourceUrl,
    required this.isEn,
    required this.accent,
  });

  Future<void> _launch(BuildContext context) async {
    final uri = Uri.tryParse(sourceUrl.trim());
    if (uri == null) return;
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final label = isEn
        ? 'Go to Original Source ↗'
        : 'Orijinal Kaynağa Git ↗';

    return Center(
      child: OutlinedButton(
        onPressed: () => _launch(context),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: accent, width: 1.5),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: accent,
            fontWeight: FontWeight.w700,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Sosyal Paylaşım Çubuğu (ShareBar)
// ═══════════════════════════════════════════════════════════════════════════

class _ShareBar extends StatelessWidget {
  final NewsArticle article;
  final bool isDark;
  final bool isEn;
  final Color accent;

  const _ShareBar({
    required this.article,
    required this.isDark,
    required this.isEn,
    required this.accent,
  });

  String _buildShareUrl() {
    // Generate a unique URL for the article
    return 'https://tarim-app-2026.web.app/haber/${article.id}';
  }

  void _shareNative(BuildContext context) {
    final url = _buildShareUrl();
    final text = isEn 
        ? '${article.title}\nRead more at: $url' 
        : '${article.title}\nDetaylar için: $url';
        
    final box = context.findRenderObject() as RenderBox?;
    try {
      Share.share(
        text,
        sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null,
      );
    } catch (e) {
      // Fallback if native share is unavailable (e.g., unsupported Web environment)
      _copyToClipboard(context);
    }
  }

  void _copyToClipboard(BuildContext context) {
    final url = _buildShareUrl();
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEn ? 'Link copied to clipboard!' : 'Bağlantı panoya kopyalandı!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareToWhatsApp() async {
    final url = _buildShareUrl();
    final text = isEn 
        ? '${article.title} - $url' 
        : '${article.title} - $url';
        
    final whatsappAppUrl = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(text)}');
    final whatsappWebUrl = Uri.parse('https://api.whatsapp.com/send?text=${Uri.encodeComponent(text)}');
    
    try {
      if (await canLaunchUrl(whatsappAppUrl)) {
        await launchUrl(whatsappAppUrl);
      } else {
        await launchUrl(whatsappWebUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _shareToTwitter() async {
    final url = _buildShareUrl();
    final text = article.title;
    final twitterUrl = Uri.parse('https://twitter.com/intent/tweet?text=${Uri.encodeComponent(text)}&url=${Uri.encodeComponent(url)}');
    try {
      if (await canLaunchUrl(twitterUrl)) {
        await launchUrl(twitterUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _shareToLinkedIn() async {
    final url = _buildShareUrl();
    final linkedInUrl = Uri.parse('https://www.linkedin.com/sharing/share-offsite/?url=${Uri.encodeComponent(url)}');
    try {
      if (await canLaunchUrl(linkedInUrl)) {
        await launchUrl(linkedInUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final label = isEn ? 'SHARE THIS ARTICLE' : 'BU HABERİ PAYLAŞ';
    final headerColor = isDark ? AppColors.creamBackground : AppColors.earthText;
    final iconColor = isDark ? Colors.white70 : Colors.black87;
    final bgColor = isDark ? AppColors.darkGreen : const Color(0xFFF5F5F5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: headerColor,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _ShareButton(
              icon: Icons.share_rounded,
              color: iconColor,
              bgColor: bgColor,
              onTap: () => _shareNative(context),
              tooltip: isEn ? 'Share' : 'Paylaş',
            ),
            _ShareButton(
              icon: Icons.copy_rounded,
              color: iconColor,
              bgColor: bgColor,
              onTap: () => _copyToClipboard(context),
              tooltip: isEn ? 'Copy Link' : 'Kopyala',
            ),
            _ShareButton(
              icon: Icons.chat_rounded, // fallback icon for whatsapp
              color: const Color(0xFF25D366),
              bgColor: bgColor,
              onTap: _shareToWhatsApp,
              tooltip: 'WhatsApp',
            ),
            _ShareButton(
              icon: Icons.alternate_email_rounded, // fallback icon for twitter/X
              color: isDark ? Colors.white : Colors.black,
              bgColor: bgColor,
              onTap: _shareToTwitter,
              tooltip: 'X (Twitter)',
            ),
            _ShareButton(
              icon: Icons.work_rounded, // fallback icon for linkedin
              color: const Color(0xFF0A66C2),
              bgColor: bgColor,
              onTap: _shareToLinkedIn,
              tooltip: 'LinkedIn',
            ),
          ],
        ),
      ],
    );
  }
}

class _ShareButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;
  final String tooltip;

  const _ShareButton({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 24, color: color),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  İlgili Haberler — yatay kaydırmalı kart şeridi
// ═══════════════════════════════════════════════════════════════════════════

class _RelatedSection extends ConsumerWidget {
  final String currentId;
  final bool isEn;
  final bool isDark;

  const _RelatedSection({
    required this.currentId,
    required this.isEn,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(latestArticlesProvider).when(
      data: (articles) {
        final related = articles
            .where((a) => a.id != currentId)
            .take(6)
            .toList();

        if (related.isEmpty) return const SizedBox.shrink();

        final dividerColor =
            isDark ? AppColors.creamBackground : AppColors.earthText;
        final headerColor =
            isDark ? AppColors.creamBackground : AppColors.earthText;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kalın siyah bölme çizgisi
            Container(height: 3, color: dividerColor),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Text(
                isEn ? 'RELATED STORIES' : 'İLGİLİ HABERLER',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                  color: headerColor,
                ),
              ),
            ),

            // Yatay kaydırmalı kart şeridi
            SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: related.length,
                itemBuilder: (context, i) => Padding(
                  padding: EdgeInsets.only(
                    right: i < related.length - 1 ? 16 : 0,
                  ),
                  child: _RelatedCard(
                    article: related[i],
                    isEn: isEn,
                    isDark: isDark,
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => _RelatedShimmer(isDark: isDark),
      error: (error, _) => const SizedBox.shrink(),
    );
  }
}

// ─── İlgili haberler yükleme iskeleti ─────────────────────────────────────

class _RelatedShimmer extends StatelessWidget {
  final bool isDark;

  const _RelatedShimmer({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final dividerColor =
        isDark ? AppColors.creamBackground : AppColors.earthText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 3, color: dividerColor),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: ShimmerPlaceholder(width: 180, height: 22),
        ),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: 4,
            itemBuilder: (_, i) => Padding(
              padding: EdgeInsets.only(right: i < 3 ? 16 : 0),
              child: RelatedCardSkeleton(isDark: isDark),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Tek bir ilgili haber kartı (yatay şerit içinde) ─────────────────────

class _RelatedCard extends StatefulWidget {
  final NewsArticle article;
  final bool isEn;
  final bool isDark;

  const _RelatedCard({
    required this.article,
    required this.isEn,
    required this.isDark,
  });

  @override
  State<_RelatedCard> createState() => _RelatedCardState();
}

class _RelatedCardState extends State<_RelatedCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    final isEn = widget.isEn;
    final isDark = widget.isDark;

    final title = (isEn && a.titleEn != null && a.titleEn!.isNotEmpty)
        ? a.titleEn!
        : a.title;
    final date = DateFormat.yMMMd(isEn ? 'en_US' : 'tr_TR')
        .format(a.createdAt);

    final cardBg = isDark ? _kSurfaceDark : Colors.white;
    final borderColor = isDark ? AppColors.wheat : AppColors.wheat;
    final accent = isDark ? _kAccentDark : _kAccent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => pushScreen(context, ArticleDetailScreen(article: a),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 220,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _hovered ? accent : borderColor,
              width: _hovered ? 1.5 : 1.0,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
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
              // Görsel (16:9)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: NewsArticleImage(
                  imageUrl: a.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),

              // Metin
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kaynak etiketi
                      if (a.sourceName != null && a.sourceName!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            a.sourceName!.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: accent,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      // Başlık
                      Text(
                        title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _hovered
                              ? accent
                              : (isDark
                                  ? AppColors.creamBackground
                                  : AppColors.earthText),
                          height: 1.25,
                        ),
                      ),

                      const Spacer(),

                      // Tarih
                      Text(
                        date,
                        style: GoogleFonts.robotoMono(
                          fontSize: 9,
                          color: isDark
                              ? AppColors.wheat
                              : const Color(0xFF888888),
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

// ═══════════════════════════════════════════════════════════════════════════
//  Editoryal Bileşenler
// ═══════════════════════════════════════════════════════════════════════════

class _KeyTakeawaysBox extends StatelessWidget {
  final List<String> takeaways;
  final bool isEn;
  final bool isDark;
  final Color accent;

  const _KeyTakeawaysBox({
    required this.takeaways,
    required this.isEn,
    required this.isDark,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF161F2C) : const Color(0xFFF9F6F0);
    final borderColor = isDark ? const Color(0xFF2C394B) : const Color(0xFFE5E0D8);
    final textColor = isDark ? AppColors.creamBackground : AppColors.earthText;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_list_bulleted_rounded, color: accent, size: 20),
              const SizedBox(width: 8),
              Text(
                isEn ? 'KEY TAKEAWAYS' : 'ÖNE ÇIKANLAR',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...takeaways.map((takeaway) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 7),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        takeaway,
                        style: GoogleFonts.lora(
                          fontSize: 16,
                          height: 1.5,
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _ExpertInsightBox extends StatelessWidget {
  final String insight;
  final bool isEn;
  final bool isDark;
  final Color accent;

  const _ExpertInsightBox({
    required this.insight,
    required this.isEn,
    required this.isDark,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF1B232E) : const Color(0xFFF2F4F8);
    final textColor = isDark ? AppColors.creamBackground : AppColors.earthText;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(left: BorderSide(color: accent, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: accent, size: 20),
              const SizedBox(width: 8),
              Text(
                isEn ? 'EXPERT INSIGHT' : 'UZMAN GÖRÜŞÜ',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insight,
            style: GoogleFonts.lora(
              fontSize: 17,
              height: 1.6,
              color: textColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _DynamicChart extends StatelessWidget {
  final Map<String, dynamic> chartData;
  final bool isDark;
  final Color accent;

  const _DynamicChart({
    required this.chartData,
    required this.isDark,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final type = chartData['type'] as String?;
    final title = chartData['title'] as String?;
    final rawData = chartData['data'] as List<dynamic>?;
    
    if (type == null || rawData == null || rawData.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final data = rawData.map((e) => e as Map<String, dynamic>).toList();
    final textColor = isDark ? AppColors.creamBackground : AppColors.earthText;
    
    Widget chartWidget;
    
    if (type == 'pie') {
      chartWidget = AspectRatio(
        aspectRatio: 1.3,
        child: PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 40,
            sections: data.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final value = (item['value'] as num).toDouble();
              final label = item['label'] as String;
              
              // Generate colors automatically based on index
              final hue = (index * 137.5) % 360; // Golden angle for distribution
              final color = HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor();
              
              return PieChartSectionData(
                color: color,
                value: value,
                title: '$label\\n${value.toInt()}%',
                radius: 60,
                titleStyle: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }).toList(),
          ),
        ),
      );
    } else {
      // Default to bar chart
      final maxY = data.map((e) => (e['value'] as num).toDouble()).reduce((a, b) => a > b ? a : b) * 1.2;
      
      chartWidget = AspectRatio(
        aspectRatio: 1.5,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 && value.toInt() < data.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          data[value.toInt()]['label'] as String,
                          style: GoogleFonts.inter(
                            color: textColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  reservedSize: 32,
                ),
              ),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxY / 4 > 0 ? maxY / 4 : 1,
              getDrawingHorizontalLine: (value) => FlLine(
                color: isDark ? Colors.white10 : Colors.black12,
                strokeWidth: 1,
                dashArray: [5, 5],
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: data.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: (entry.value['value'] as num).toDouble(),
                    color: accent,
                    width: 22,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxY,
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                  )
                ],
              );
            }).toList(),
          ),
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A212A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF2C394B) : const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (title != null && title.isNotEmpty) ...[
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.libreFranklin(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 24),
          ],
          chartWidget,
        ],
      ),
    );
  }
}
