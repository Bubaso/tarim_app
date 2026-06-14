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
          'GÜNDEM & ÖZEL DOSYALAR',
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
    NewsArticle? at(int i) => i < articles.length ? articles[i] : null;

    final a0 = at(0); // Büyük Kare
    final a1 = at(1); // Dikey Dikdörtgen
    final a2 = at(2); // Yatay Kutu 1
    final a3 = at(3); // Yatay Kutu 2

    final a4 = at(4); // Yatay Kutu 3
    final a5 = at(5); // Yatay Kutu 4
    final a6 = at(6); // Dikey Dikdörtgen 2
    final a7 = at(7); // Büyük Kare 2

    return Column(
      children: [
        // ── Birinci Satır (a0, a1, a2, a3) ──────────────────────────────────
        if (a0 != null)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sol: Büyük Kare (AspectRatio 1.0)
                Expanded(
                  flex: 4,
                  child: _BentoItem(
                    article: a0,
                    isDark: isDark,
                    cardType: _CardType.square,
                  ),
                ),
                const SizedBox(width: 16),
                // Orta: Dikey Dikdörtgen (AspectRatio 3:4)
                if (a1 != null) ...[
                  Expanded(
                    flex: 3,
                    child: _BentoItem(
                      article: a1,
                      isDark: isDark,
                      cardType: _CardType.vertical,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                // Sağ: İki Yatay Kutu (Column)
                if (a2 != null || a3 != null)
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (a2 != null)
                          Expanded(
                            child: _BentoItem(
                              article: a2,
                              isDark: isDark,
                              cardType: _CardType.horizontal,
                            ),
                          ),
                        if (a2 != null && a3 != null) const SizedBox(height: 16),
                        if (a3 != null)
                          Expanded(
                            child: _BentoItem(
                              article: a3,
                              isDark: isDark,
                              cardType: _CardType.horizontal,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

        // ── İkinci Satır (a4, a5, a6, a7) - Simetriyi bozup asimetriyi artırmak için ters düzen ────
        if (a4 != null) ...[
          const SizedBox(height: 24),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sol: İki Yatay Kutu (Column)
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _BentoItem(
                          article: a4,
                          isDark: isDark,
                          cardType: _CardType.horizontal,
                        ),
                      ),
                      if (a5 != null) ...[
                        const SizedBox(height: 16),
                        Expanded(
                          child: _BentoItem(
                            article: a5,
                            isDark: isDark,
                            cardType: _CardType.horizontal,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Orta: Dikey Dikdörtgen (AspectRatio 3:4)
                if (a6 != null) ...[
                  Expanded(
                    flex: 3,
                    child: _BentoItem(
                      article: a6,
                      isDark: isDark,
                      cardType: _CardType.vertical,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                // Sağ: Büyük Kare (AspectRatio 1.0)
                if (a7 != null)
                  Expanded(
                    flex: 4,
                    child: _BentoItem(
                      article: a7,
                      isDark: isDark,
                      cardType: _CardType.square,
                    ),
                  ),
              ],
            ),
          ),
        ],

        // ── Kalan Diğer Haberler (Liste Görünümü) ──────────────────────────
        if (articles.length > 8) ...[
          const SizedBox(height: 24),
          _ExtraListSection(
            articles: articles.sublist(8),
            isDark: isDark,
          ),
        ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < articles.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          _buildMobileItem(articles[i], i),
        ],
      ],
    );
  }

  Widget _buildMobileItem(NewsArticle article, int index) {
    // Mobil için kart tiplerini sırayla ata
    final type = index % 3 == 0
        ? _CardType.square
        : (index % 3 == 1 ? _CardType.vertical : _CardType.horizontal);

    final double aspect = type == _CardType.square
        ? 1.0
        : (type == _CardType.vertical ? 0.8 : 1.77);

    return AspectRatio(
      aspectRatio: aspect,
      child: _BentoItem(
        article: article,
        isDark: isDark,
        cardType: type,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Bento Haber Kartı (Asimetrik Gösterim Yardımcısı)
// ═══════════════════════════════════════════════════════════════════════════

class _BentoItem extends StatefulWidget {
  final NewsArticle article;
  final bool isDark;
  final _CardType cardType;

  const _BentoItem({
    required this.article,
    required this.isDark,
    required this.cardType,
  });

  @override
  State<_BentoItem> createState() => _BentoItemState();
}

class _BentoItemState extends State<_BentoItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final a = widget.article;
    final isDark = widget.isDark;

    final title = (isEn && a.titleEn != null && a.titleEn!.isNotEmpty)
        ? a.titleEn!
        : a.title;
    final summary = (isEn && a.summaryEn != null && a.summaryEn!.isNotEmpty)
        ? a.summaryEn!
        : (a.summary ?? '');

    // AI kaynak kontrolü
    final isSpecial = a.sourceName == null || a.sourceName!.trim().isEmpty;
    final badge = isSpecial
        ? (a.summary != null && a.summary!.trim().isNotEmpty
            ? _BadgeType.editorunAnalizi
            : _BadgeType.ozelDosya)
        : null;

    final theme = Theme.of(context);
    final bgColor = isDark ? const Color(0xFF121820) : Colors.white;
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE0E0E0);
    final dateStr = DateFormat.yMMMd(isEn ? 'en_US' : 'tr_TR').format(a.createdAt);

    // Kart tipine göre tipografik ayarlar
    double titleSize = 14.0;
    int maxLines = 3;
    bool showSummary = false;

    if (widget.cardType == _CardType.square) {
      titleSize = 18.0;
      maxLines = 4;
      showSummary = true;
    } else if (widget.cardType == _CardType.vertical) {
      titleSize = 15.0;
      maxLines = 4;
      showSummary = false;
    } else if (widget.cardType == _CardType.horizontal) {
      titleSize = 13.0;
      maxLines = 2;
      showSummary = false;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          createFadeRoute(ArticleDetailScreen(article: a)),
        ),
        child: AnimatedScale(
          scale: _hovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _hovered ? theme.colorScheme.primary : borderColor,
              width: 1.0,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Görsel alanı
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      NewsArticleImage(
                        imageUrl: a.imageUrl,
                        fit: BoxFit.cover,
                      ),
                      if (badge != null)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: _ArticleBadge(type: badge),
                        )
                      else if (a.sourceName != null && a.sourceName!.isNotEmpty)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: _SourceBadge(label: a.sourceName!),
                        ),
                    ],
                  ),
                ),
                // Metin alanı
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        dateStr.toUpperCase(),
                        style: GoogleFonts.robotoMono(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFF8B949E) : const Color(0xFF888888),
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        maxLines: maxLines,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w800,
                          color: _hovered
                              ? (isDark ? const Color(0xFF58A6FF) : _kAccent)
                              : (isDark ? const Color(0xFFECEFF1) : const Color(0xFF1A1A1A)),
                          height: 1.25,
                        ),
                      ),
                      if (showSummary && summary.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          summary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.lora(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF8B949E) : const Color(0xFF666666),
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
    ),
  );
  }
}

// ─── Altın sarısı renginde şık Editör Rozeti (Kategoriler için) ──────────────

class _ArticleBadge extends StatelessWidget {
  final _BadgeType type;

  const _ArticleBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final label = type == _BadgeType.editorunAnalizi
        ? 'EDİTÖRÜN ANALİZİ'
        : 'ÖZEL DOSYA';

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
