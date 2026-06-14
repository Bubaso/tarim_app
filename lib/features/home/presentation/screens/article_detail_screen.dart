// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/news_article.dart';
import '../../../../core/utils/image_fallback_helper.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../../providers/home_providers.dart';

// ─── Renk sabitleri ───────────────────────────────────────────────────────
const Color _kAccent      = Color(0xFF004A99);
const Color _kAccentDark  = Color(0xFF58A6FF);
const Color _kBgLight     = Color(0xFFFAF9F6);
const Color _kBgDark      = Color(0xFF0C1015);
const Color _kSurfaceDark = Color(0xFF111721);

// ═══════════════════════════════════════════════════════════════════════════
//  ArticleDetailScreen — tam sayfa makale okuma deneyimi
// ═══════════════════════════════════════════════════════════════════════════

class ArticleDetailScreen extends ConsumerWidget {
  final NewsArticle article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme  = Theme.of(context);
    final isEn   = Localizations.localeOf(context).languageCode == 'en';
    final isDark = theme.brightness == Brightness.dark;

    final displayTitle = (isEn && article.titleEn != null && article.titleEn!.isNotEmpty)
        ? article.titleEn!
        : article.title;

    final displayContent = (isEn && article.contentEn != null && article.contentEn!.isNotEmpty)
        ? article.contentEn!
        : article.content;

    final displaySummary = (isEn && article.summaryEn != null && article.summaryEn!.isNotEmpty)
        ? article.summaryEn!
        : (article.summary ?? '');

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
    final onBg   = isDark ? const Color(0xFFECEFF1) : const Color(0xFF111111);
    final subtle = isDark ? const Color(0xFF8B949E) : const Color(0xFF666666);
    final accent = isDark ? _kAccentDark : _kAccent;

    // ── Hero görsel yüksekliği: SliverAppBar expanded height ────────────
    // Genişlik bilinmediğinden oran korunur; SliverAppBar expandedHeight
    // kullanmak yerine 16:9 AspectRatio ile kendisi belirlensin.
    // Bunun için SliverToBoxAdapter içinde AspectRatio kullanıyoruz.

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── 16:9 Hero Görseli (Sayfanın en üstünde) ─────────────────
              SliverToBoxAdapter(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Görsel (shimmer fallback)
                      NewsArticleImage(
                        imageUrl: article.imageUrl,
                        fit: BoxFit.cover,
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

              // ── Makale içeriği ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
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
                          ),
                          const SizedBox(height: 20),

                          // ── Başlık (Playfair, devasa) ─────────────────────
                          Text(
                            displayTitle,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: onBg,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── Alıntı (özet) — sol kenar vurgusu ─────────────
                          if (displaySummary.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.only(
                                left: 16,
                                top: 10,
                                bottom: 10,
                                right: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(color: accent, width: 4),
                                ),
                                color: isDark
                                    ? const Color(0xFF161B22)
                                    : const Color(0xFFF0EDE8),
                              ),
                              child: Text(
                                displaySummary,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.italic,
                                  color: isDark
                                      ? const Color(0xFFB0BEC5)
                                      : const Color(0xFF424242),
                                  height: 1.55,
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                          ],

                          // ── Bölme çizgisi ─────────────────────────────────
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: isDark
                                ? const Color(0xFF1E2631)
                                : const Color(0xFFE0E0E0),
                          ),
                          const SizedBox(height: 28),

                          // ── Gövde metni (Lora, 18px, 1.6 line-height) ─────
                          Text(
                            displayContent,
                            style: GoogleFonts.lora(
                              fontSize: 18,
                              color: isDark
                                  ? const Color(0xFFCFD8DC)
                                  : const Color(0xFF2C2C2A),
                              height: 1.6,
                            ),
                          ),

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

                          // ── Orijinal kaynak butonu ────────────────────────
                          if (hasSourceUrl) ...[
                            const SizedBox(height: 40),
                            _SourceButton(
                              sourceName: article.sourceName ?? 'Kaynak',
                              sourceUrl:  article.sourceUrl!,
                              isEn:       isEn,
                              accent:     accent,
                            ),
                          ],

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
          // ── Yüzen Geri Butonu (Floating Back Button at top-left) ───────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: ClipOval(
              child: Material(
                color: isDark ? const Color(0xAA0C1015) : const Color(0xAAFAF9F6),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                ),
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

  const _MetaRow({
    required this.hasSource,
    required this.sourceName,
    required this.formattedDate,
    required this.readLabel,
    required this.accent,
    required this.subtle,
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
    final chipBg = isDark ? const Color(0xFF1E2631) : const Color(0xFFEBE3D5);

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
            color: isDark ? const Color(0xFF8B949E) : const Color(0xFF888888),
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
            isDark ? const Color(0xFFF0F6FC) : const Color(0xFF1A1A1A);
        final headerColor =
            isDark ? const Color(0xFFECEFF1) : const Color(0xFF111111);

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
        isDark ? const Color(0xFFF0F6FC) : const Color(0xFF1A1A1A);

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
    final borderColor = isDark ? const Color(0xFF1E2631) : const Color(0xFFE0E0E0);
    final accent = isDark ? _kAccentDark : _kAccent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          createFadeRoute(ArticleDetailScreen(article: a)),
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
                                  ? const Color(0xFFECEFF1)
                                  : const Color(0xFF1A1A1A)),
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
                              ? const Color(0xFF8B949E)
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
