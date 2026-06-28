// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/models/news_article.dart';
import '../../../../core/utils/image_fallback_helper.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../screens/article_detail_screen.dart';

// ─── Sınır sabitleri ──────────────────────────────────────────────────────
const double _kBentoBreakpoint = 900.0;

// ─── Renk sabitleri ───────────────────────────────────────────────────────
const Color _kAccent        = Color(0xFF004A99);
const Color _kDividerDark   = Color(0xFF30363D);
const Color _kDividerLight  = Color(0xFF1A1A1A);

// ─── Rozet türleri ────────────────────────────────────────────────────────
enum _BadgeType { editorunAnalizi, ozelDosya }
enum _CardType { square, vertical, horizontal }

// ═══════════════════════════════════════════════════════════════════════════
//  AgendaBentoGrid — Gündem & Özel Dosyalar bölümü
// ═══════════════════════════════════════════════════════════════════════════

class AgendaBentoGrid extends StatelessWidget {
  final List<NewsArticle> articles;
  final bool isDark;

  const AgendaBentoGrid({
    super.key,
    required this.articles,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Özel dosya/analizler: sourceName boş olanlar (bizim taraftan üretilenler)
    final specials = articles
        .where((a) => a.sourceName == null || a.sourceName!.trim().isEmpty)
        .toList();

    // Gündem haberleri: sourceName dolu olanlar
    final agenda = articles
        .where((a) => a.sourceName != null && a.sourceName!.trim().isNotEmpty)
        .toList();

    // Birleştirilmiş liste — önce özel dosyalar, arkaya gündem
    final combined = [...specials, ...agenda];

    if (combined.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'Henüz içerik bulunamadı.',
            style: GoogleFonts.lora(
              fontSize: 15,
              color: isDark ? const Color(0xFF8B949E) : const Color(0xFF888888),
            ),
          ),
        ),
      );
    }

    final width = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Gazete tarzı bölüm başlığı ──────────────────────────────────
        _NewspaperSectionHeader(isDark: isDark),
        const SizedBox(height: 20),

        // ── Asimetrik bento ─────────────────────────────────────────────
        if (width >= _kBentoBreakpoint)
          _DesktopBento(articles: combined, isDark: isDark)
        else
          _MobileBento(articles: combined, isDark: isDark),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Gazete Tarzı Bölüm Başlığı (BBC Hiyerarşisi)
// ═══════════════════════════════════════════════════════════════════════════

class _NewspaperSectionHeader extends StatelessWidget {
  final bool isDark;

  const _NewspaperSectionHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < _kBentoBreakpoint;
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    if (isMobile) {
      final dividerColor = isDark ? const Color(0xFF58A6FF) : const Color(0xFF1A1A1A);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'AGENDA & SPECIAL REPORTS' : 'GÜNDEM & ÖZEL DOSYALAR',
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
            color: dividerColor,
          ),
        ],
      );
    }

    final heavyDividerColor = isDark ? const Color(0xFFF0F6FC) : _kDividerLight;
    final lightDividerColor = isDark ? _kDividerDark : const Color(0xFFBBBBBB);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 3px kalın gazete çizgisi — üst
        Container(
          height: 3,
          color: heavyDividerColor,
        ),
        const SizedBox(height: 10),

        // Başlık metni
        Text(
          isEn ? 'AGENDA & SPECIAL REPORTS' : 'GÜNDEM & ÖZEL DOSYALAR',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: isDark ? const Color(0xFFF0F6FC) : const Color(0xFF1A1A1A),
          ),
        ),

        const SizedBox(height: 10),

        // 1px ince alt çizgi
        Container(
          height: 1,
          color: lightDividerColor,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Masaüstü Asimetrik Bento (≥ 900px)
// ═══════════════════════════════════════════════════════════════════════════

class _DesktopBento extends StatelessWidget {
  final List<NewsArticle> articles;
  final bool isDark;

  const _DesktopBento({required this.articles, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) return const SizedBox.shrink();

    // Profesyonel Haber Portalı Masaüstü Layout'u (3 Sütunlu)
    // Sütun 1: Ana Manşet (1 adet büyük) + Altında Liste (2 adet)
    // Sütun 2: Standart Haberler (3 adet)
    // Sütun 3: Standart Haberler (3 adet)
    // Geri kalanlar ExtraListSection ile alta.

    final col1 = <NewsArticle>[];
    final col2 = <NewsArticle>[];
    final col3 = <NewsArticle>[];

    for (int i = 0; i < articles.length && i < 9; i++) {
      if (i == 0) col1.add(articles[i]); 
      else if (i == 1 || i == 2) col1.add(articles[i]);
      else if (i >= 3 && i <= 5) col2.add(articles[i]); 
      else if (i >= 6 && i <= 8) col3.add(articles[i]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (col1.isNotEmpty)
              Expanded(
                flex: 11,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DesktopCardHoverBox(article: col1[0], isDark: isDark, isFeature: true),
                    if (col1.length > 1) ...[
                      const SizedBox(height: 32),
                      Divider(color: isDark ? const Color(0xFF30363D) : const Color(0xFFE5E5E5)),
                      const SizedBox(height: 24),
                      _DesktopCardHoverBox(article: col1[1], isDark: isDark, isList: true),
                    ],
                    if (col1.length > 2) ...[
                      const SizedBox(height: 24),
                      Divider(color: isDark ? const Color(0xFF30363D) : const Color(0xFFE5E5E5)),
                      const SizedBox(height: 24),
                      _DesktopCardHoverBox(article: col1[2], isDark: isDark, isList: true),
                    ],
                  ],
                ),
              ),
            if (col2.isNotEmpty) ...[
              const SizedBox(width: 32),
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: col2.map((a) {
                    final isLast = a == col2.last;
                    return Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 32),
                      child: _DesktopCardHoverBox(article: a, isDark: isDark),
                    );
                  }).toList(),
                ),
              ),
            ],
            if (col3.isNotEmpty) ...[
              const SizedBox(width: 32),
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: col3.map((a) {
                    final isLast = a == col3.last;
                    return Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 32),
                      child: _DesktopCardHoverBox(article: a, isDark: isDark),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
        if (articles.length > 9) ...[
          const SizedBox(height: 32),
          Divider(color: isDark ? const Color(0xFF30363D) : const Color(0xFFE5E5E5), thickness: 2),
          const SizedBox(height: 24),
          _ExtraListSection(articles: articles.sublist(9), isDark: isDark),
        ],
      ],
    );
  }
}

class _DesktopCardHoverBox extends StatefulWidget {
  final NewsArticle article;
  final bool isDark;
  final bool isFeature;
  final bool isList;

  const _DesktopCardHoverBox({
    required this.article, 
    required this.isDark, 
    this.isFeature = false,
    this.isList = false,
  });

  @override
  State<_DesktopCardHoverBox> createState() => _DesktopCardHoverBoxState();
}

class _DesktopCardHoverBoxState extends State<_DesktopCardHoverBox> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    final isDark = widget.isDark;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final title = (isEn && a.titleEn != null && a.titleEn!.isNotEmpty) ? a.titleEn! : a.title;
    final summary = (isEn && a.summaryEn != null && a.summaryEn!.isNotEmpty) ? a.summaryEn! : (a.summary ?? '');
    final dateStr = DateFormat.yMMMd(isEn ? 'en_US' : 'tr_TR').format(a.createdAt);
    
    final isSpecial = a.sourceName == null || a.sourceName!.trim().isEmpty;
    final badge = isSpecial
        ? (a.summary != null && a.summary!.trim().isNotEmpty
            ? _BadgeType.editorunAnalizi
            : _BadgeType.ozelDosya)
        : null;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: MergeSemantics(
        child: GestureDetector(
          onTap: () => Navigator.of(context).push(
            createFadeRoute(ArticleDetailScreen(article: a)),
          ),
          child: AnimatedScale(
            scale: _hovered ? 1.01 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: widget.isList 
              ? _buildListLayout(title, summary, dateStr, badge, isDark)
              : _buildStandardLayout(title, summary, dateStr, badge, isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildStandardLayout(String title, String summary, String dateStr, _BadgeType? badge, bool isDark) {
    final a = widget.article;
    final titleColor = _hovered
        ? (isDark ? const Color(0xFF58A6FF) : const Color(0xFF004A99))
        : (isDark ? const Color(0xFFECEFF1) : const Color(0xFF1A1A1A));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: widget.isFeature ? 16/9 : 3/2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              fit: StackFit.expand,
              children: [
                NewsArticleImage(imageUrl: a.imageUrl, fit: BoxFit.cover, semanticLabel: title),
                if (badge != null)
                  Positioned(top: 10, left: 10, child: _ArticleBadge(type: badge))
                else if (a.sourceName != null && a.sourceName!.isNotEmpty)
                  Positioned(top: 10, left: 10, child: _SourceBadge(label: a.sourceName!)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          dateStr.toUpperCase(),
          style: GoogleFonts.robotoMono(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFF8B949E) : const Color(0xFF888888),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          maxLines: widget.isFeature ? 3 : 4,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.playfairDisplay(
            fontSize: widget.isFeature ? 28 : 18,
            fontWeight: FontWeight.w800,
            color: titleColor,
            height: 1.2,
          ),
        ),
        if (widget.isFeature && summary.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            summary,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lora(
              fontSize: 15,
              color: isDark ? const Color(0xFF8B949E) : const Color(0xFF555555),
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildListLayout(String title, String summary, String dateStr, _BadgeType? badge, bool isDark) {
    final a = widget.article;
    final titleColor = _hovered
        ? (isDark ? const Color(0xFF58A6FF) : const Color(0xFF004A99))
        : (isDark ? const Color(0xFFECEFF1) : const Color(0xFF1A1A1A));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            width: 140,
            height: 90,
            child: Stack(
              fit: StackFit.expand,
              children: [
                NewsArticleImage(imageUrl: a.imageUrl, fit: BoxFit.cover, semanticLabel: title),
                if (badge != null)
                  Positioned(top: 4, left: 4, child: Transform.scale(scale: 0.8, alignment: Alignment.topLeft, child: _ArticleBadge(type: badge)))
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateStr.toUpperCase(),
                style: GoogleFonts.robotoMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF8B949E) : const Color(0xFF888888),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Mobil Bento (< 900px)
// ═══════════════════════════════════════════════════════════════════════════

class _MobileBento extends StatelessWidget {
  final List<NewsArticle> articles;
  final bool isDark;

  const _MobileBento({required this.articles, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];
    int i = 0;
    while (i < articles.length) {
      // 1. Haber: Büyük kart (Tam genişlik)
      final large1 = articles[i];
      children.add(_buildLargeCard(context, large1));
      i++;

      if (i >= articles.length) break;

      // 2. ve 3. Haber: Yan yana iki küçük kart
      final small1 = articles[i];
      i++;
      final small2 = i < articles.length ? articles[i] : null;
      if (small2 != null) {
        i++;
        children.add(
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildSmallCard(context, small1)),
                const SizedBox(width: 12),
                Expanded(child: _buildSmallCard(context, small2)),
              ],
            ),
          ),
        );
      } else {
        // Tek kalırsa tam genişlikte göster
        children.add(_buildLargeCard(context, small1));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int index = 0; index < children.length; index++) ...[
          if (index > 0) const SizedBox(height: 16),
          children[index],
        ],
      ],
    );
  }

  Widget _buildLargeCard(BuildContext context, NewsArticle article) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final title = (isEn && article.titleEn != null && article.titleEn!.isNotEmpty)
        ? article.titleEn!
        : article.title;
    final summary = (isEn && article.summaryEn != null && article.summaryEn!.isNotEmpty)
        ? article.summaryEn!
        : (article.summary ?? '');

    final isSpecial = article.sourceName == null || article.sourceName!.trim().isEmpty;
    final dateStr = DateFormat.yMMMd(isEn ? 'en_US' : 'tr_TR').format(article.createdAt);
    final bgColor = isDark ? const Color(0xFF121820) : Colors.white;
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE0E0E0);

    return MergeSemantics(
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          createFadeRoute(ArticleDetailScreen(article: article)),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    NewsArticleImage(
                      imageUrl: article.imageUrl,
                      fit: BoxFit.cover,
                      semanticLabel: title,
                    ),
                    if (isSpecial)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: _ArticleBadge(
                          type: summary.isNotEmpty
                              ? _BadgeType.editorunAnalizi
                              : _BadgeType.ozelDosya,
                        ),
                      )
                    else if (article.sourceName != null && article.sourceName!.isNotEmpty)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: _SourceBadge(label: article.sourceName!),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr.toUpperCase(),
                      style: GoogleFonts.robotoMono(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        color: isDark ? const Color(0xFF8B949E) : const Color(0xFF888888),
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFFECEFF1) : const Color(0xFF1A1A1A),
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildSmallCard(BuildContext context, NewsArticle article) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final title = (isEn && article.titleEn != null && article.titleEn!.isNotEmpty)
        ? article.titleEn!
        : article.title;
    final summary = (isEn && article.summaryEn != null && article.summaryEn!.isNotEmpty)
        ? article.summaryEn!
        : (article.summary ?? '');

    final isSpecial = article.sourceName == null || article.sourceName!.trim().isEmpty;
    final dateStr = DateFormat.yMMMd(isEn ? 'en_US' : 'tr_TR').format(article.createdAt);
    final bgColor = isDark ? const Color(0xFF121820) : Colors.white;
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE0E0E0);

    return MergeSemantics(
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          createFadeRoute(ArticleDetailScreen(article: article)),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 1.0),
          ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    NewsArticleImage(
                      imageUrl: article.imageUrl,
                      fit: BoxFit.cover,
                      semanticLabel: title,
                    ),
                    if (isSpecial)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: _ArticleBadge(
                          type: summary.isNotEmpty
                              ? _BadgeType.editorunAnalizi
                              : _BadgeType.ozelDosya,
                        ),
                      )
                    else if (article.sourceName != null && article.sourceName!.isNotEmpty)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: _SourceBadge(label: article.sourceName!),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr.toUpperCase(),
                      style: GoogleFonts.robotoMono(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        color: isDark ? const Color(0xFF8B949E) : const Color(0xFF888888),
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFFECEFF1) : const Color(0xFF1A1A1A),
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

// ─── Altın sarısı renginde şık Editör Rozeti (Kategoriler için) ──────────────

class _ArticleBadge extends StatelessWidget {
  final _BadgeType type;

  const _ArticleBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final label = type == _BadgeType.editorunAnalizi
        ? (isEn ? 'EDITOR\'S ANALYSIS' : 'EDİTÖRÜN ANALİZİ')
        : (isEn ? 'SPECIAL REPORT' : 'ÖZEL DOSYA');

    // Şık koyu altın/bronz rengi
    const bgColor = Color(0xFF9E7E38);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ─── Haber Kaynağı Rozeti ──────────────────────────────────────────────────

class _SourceBadge extends StatelessWidget {
  final String label;

  const _SourceBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF004A99),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
          color: Colors.white,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Ek içerikler — 8'den fazla haber varsa liste görünümü
// ═══════════════════════════════════════════════════════════════════════════

class _ExtraListSection extends StatelessWidget {
  final List<NewsArticle> articles;
  final bool isDark;

  const _ExtraListSection({
    required this.articles,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE0E0E0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 1, color: borderColor),
        ...articles.asMap().entries.map((entry) {
          final i = entry.key;
          final a = entry.value;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ListItem(article: a, isDark: isDark),
              if (i < articles.length - 1)
                Container(height: 1, color: borderColor),
            ],
          );
        }),
      ],
    );
  }
}

// ─── Kompakt Haber Satırı ──────────────────────────────────────────────────

class _ListItem extends StatefulWidget {
  final NewsArticle article;
  final bool isDark;

  const _ListItem({required this.article, required this.isDark});

  @override
  State<_ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<_ListItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final a = widget.article;
    final isDark = widget.isDark;

    final title = (isEn && a.titleEn != null && a.titleEn!.isNotEmpty)
        ? a.titleEn!
        : a.title;

    final isSpecial = a.sourceName == null || a.sourceName!.trim().isEmpty;
    final badge = isSpecial
        ? (a.summary != null && a.summary!.trim().isNotEmpty
            ? _BadgeType.editorunAnalizi
            : _BadgeType.ozelDosya)
        : null;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          createFadeRoute(ArticleDetailScreen(article: a)),
        ),
        child: AnimatedScale(
          scale: _hovered ? 1.015 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: Container(
          color: _hovered
              ? (isDark ? const Color(0xFF161B22) : const Color(0xFFF5F3EF))
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SizedBox(
                  width: 72,
                  height: 54,
                  child: NewsArticleImage(
                    imageUrl: a.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (badge != null) ...[
                      _ArticleBadge(type: badge),
                      const SizedBox(height: 5),
                    ] else if (a.sourceName != null && a.sourceName!.isNotEmpty) ...[
                      _SourceBadge(label: a.sourceName!),
                      const SizedBox(height: 5),
                    ],
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _hovered
                            ? (isDark ? const Color(0xFF58A6FF) : _kAccent)
                            : (isDark ? const Color(0xFFECEFF1) : const Color(0xFF1A1A1A)),
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat.yMMMd(isEn ? 'en_US' : 'tr_TR').format(a.createdAt),
                      style: GoogleFonts.robotoMono(
                        fontSize: 9,
                        color: isDark ? const Color(0xFF8B949E) : const Color(0xFF888888),
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
}
