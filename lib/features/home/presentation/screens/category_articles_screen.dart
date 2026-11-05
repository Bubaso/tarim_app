import 'package:flutter/material.dart';
import 'package:tarim_app/core/utils/hover.dart';
import 'package:tarim_app/core/theme/app_dark_mode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/core/theme/app_colors.dart';
import 'package:tarim_app/core/utils/localization_helper.dart';
import 'package:tarim_app/core/utils/fade_page_route.dart';
import 'package:tarim_app/core/utils/responsive_breakpoints.dart';
import 'package:tarim_app/core/utils/image_fallback_helper.dart';
import 'package:tarim_app/core/widgets/article_timestamp.dart';
import '../../data/models/news_article.dart';
import '../../data/category_catalog.dart';
import '../../providers/home_providers.dart';
import '../../providers/font_scale_provider.dart';
import '../widgets/font_size_control_bar.dart';
import 'article_detail_screen.dart';
import '../widgets/portal_footer.dart';
import '../../../../core/utils/string_extensions.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/ana_sayfa_dugmesi.dart';
import '../widgets/category_nav_bar.dart';

class CategoryArticlesScreen extends ConsumerStatefulWidget {
  /// Uygulama içi gezinmede hazır liste + başlık taşınır. Doğrudan URL'de
  /// ikisi de null gelir ve ekran [slug]'dan çözer.
  final String? title;
  final String? slug;
  final List<NewsArticle>? articles;

  /// Doluysa ekran KATEGORİ değil ETİKET sayfasıdır (`/etiket/<slug>`).
  /// Sayfalama, üç durum ayrımı ve düzen aynı; değişen yalnızca sorgu ve
  /// başlık. Ayrı bir ekran yazmak bu işin tamamını ikinci kez kurmak olurdu.
  final String? tagSlug;

  const CategoryArticlesScreen({
    super.key,
    this.title,
    this.slug,
    this.articles,
    this.tagSlug,
  });

  @override
  ConsumerState<CategoryArticlesScreen> createState() =>
      _CategoryArticlesScreenState();
}

class _CategoryArticlesScreenState
    extends ConsumerState<CategoryArticlesScreen> {
  // ── Sayfalama (§20.3) ──────────────────────────────────────────────────
  // Ekran artık ortak listeyi SÜZMÜYOR, kendi sorgusunu yapıyor. Eskiden
  // `latestArticlesProvider`ı süzüyordu; o liste `_listeSiniri` ile bağlı ve
  // arşivin derini oradan HİÇ görünmüyordu — hata vermeden, eksik göstererek.
  // §26.2'de yazar arşivinde aynısı yaşanmıştı: 20 yazısı olan yazarın
  // sayfasında 3 yazı çıkıyordu.
  static const int _sayfaBoyu = 40;

  final List<NewsArticle> _liste = [];
  bool _ilkYukleme = true;
  bool _yukleniyor = false;
  bool _dahaVar = true;
  String? _hata;

  @override
  void initState() {
    super.initState();
    // Uygulama içi gezinmede hazır liste geliyor: ilk kare BEKLETMEDEN
    // çiziliyor, sayfalama arkadan devralıyor.
    final tohum = widget.articles;
    if (tohum != null && tohum.isNotEmpty) {
      _liste.addAll(tohum);
      _ilkYukleme = false;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _sayfaYukle(ilk: true));
  }

  Future<void> _sayfaYukle({bool ilk = false}) async {
    final slug = widget.slug ?? widget.tagSlug;
    if (slug == null || _yukleniyor || (!ilk && !_dahaVar)) return;
    setState(() {
      _yukleniyor = true;
      if (ilk) _hata = null;
    });
    try {
      final offset = ilk ? 0 : _liste.length;
      final depo = ref.read(homeRepositoryProvider);
      final gelen = widget.tagSlug != null
          ? await depo.fetchEtiketSayfasi(widget.tagSlug!,
              offset: offset, limit: _sayfaBoyu)
          : await depo.fetchKategoriSayfasi(slug,
              offset: offset, limit: _sayfaBoyu);
      if (!mounted) return;
      setState(() {
        if (ilk) _liste.clear();
        // Kimlikle tekilleştirme: tohum listesiyle ilk sayfa çakışabiliyor ve
        // aynı haber iki kart olarak çizilirdi.
        final mevcut = _liste.map((a) => a.id).toSet();
        _liste.addAll(gelen.where((a) => mevcut.add(a.id)));
        _dahaVar = gelen.length >= _sayfaBoyu;
        _ilkYukleme = false;
        _yukleniyor = false;
      });
    } catch (e) {
      if (!mounted) return;
      // Hata YUTULMUYOR: boş liste "bu kategoride haber yok" demek, ağ hatası
      // bambaşka bir şey.
      setState(() {
        _hata = '$e';
        _ilkYukleme = false;
        _yukleniyor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final fontScale = ref.watch(fontScaleProvider);
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final isDark = appIsDark;

    // Başlık slug'dan çözülüyor; LİSTE artık sağlayıcıdan değil, ekranın
    // kendi sayfalanmış sorgusundan geliyor (§20.3).
    final def = widget.slug != null ? categoryBySlug(widget.slug!) : null;
    final String title =
        widget.title ?? def?.title(isEn) ?? (isEn ? 'Category' : 'Kategori');

    if (widget.tagSlug == null && widget.slug != null && def == null) {
      return _NotFound(isEn: isEn);
    }
    final List<NewsArticle> articles = _liste;
    final bgColor = isDark ? AppColors.darkGreen : const Color(0xFFF4F4F4);
    final textColor = isDark ? AppColors.wheat : AppColors.earthText;
    final dividerColor = isDark ? Colors.white12 : Colors.black12;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < ResponsiveBreakpoints.contentWide;

    // Izgara satırları `slivers` listesinin DIŞINDA hesaplanıyor: listenin
    // içinde bir `Builder` kullanılamaz çünkü `Builder` sıradan bir widget,
    // viewport ise yalnızca sliver kabul ediyor — ve bu hata derlemede
    // değil, ancak çalışma anında ortaya çıkardı.
    final izgaraSatirlari = articles.length > 1
        ? _MixedGrid(
            articles: articles.sublist(1),
            isDark: isDark,
            isMobile: isMobile,
            fontScale: fontScale,
          ).satirlar()
        : const <Widget>[];

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
            // Ana sayfa düğmesi 2. basamaktan itibaren belirir; altında
            // ikisi de null döner ve AppBar bugünkü otomatik geri düğmesini
            // çizmeye devam eder.
            leadingWidth: anaSayfaLeadingGenisligi(context),
            leading: anaSayfaliLeading(context, renk: textColor),
            title: Text(
              title.toTurkishUpperCase(),
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
            // Kategori şeridi başlığa YAPIŞIK: `bottom` olduğu için
            // SliverAppBar ile birlikte sabit kalıyor ve okur arşivin
            // derinine indiğinde de bölümler arasında geçebiliyor.
            // Eskiden şerit yalnızca ana sayfadaydı; kategoriye giren okur
            // başka bir bölüme ancak geri dönerek geçebiliyordu.
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(41),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CategoryNavBar(isDark: isDark, aktifSlug: widget.slug),
                  Container(color: dividerColor, height: 1),
                ],
              ),
            ),
          ),
          // YÜKLENİYOR · HATA · BOŞ — üçü ayrı. Eskiden üçü de "Bu kategoride
          // haber bulunmuyor." diyordu: veri gelene kadar ve ağ koptuğunda
          // okuyucu kategoride haber olmadığını sanıyordu.
          if (_ilkYukleme)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_hata != null && articles.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isEn
                            ? 'Articles could not be loaded.'
                            : 'Haberler yüklenemedi.',
                        style: GoogleFonts.inter(color: textColor, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      // Yeniden deneme ŞART: ekran kendi sorgusunu yapıyor ve
                      // hata sonrası kendiliğinden tekrar denemiyor; düğme
                      // olmazsa okuyucu burada tıkanıp kalır (§17.1).
                      TextButton(
                        onPressed: () => _sayfaYukle(ilk: true),
                        child: Text(isEn ? 'Try again' : 'Tekrar dene'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (articles.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  isEn
                      ? 'No articles found.'
                      : 'Bu kategoride haber bulunmuyor.',
                  style: GoogleFonts.inter(color: textColor, fontSize: 16),
                ),
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 0 : 24,
                        vertical: isMobile ? 0 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Hero ──────────────────────────────────────────────────────────
                        _HeroArticle(
                          article: articles.first,
                          categoryName: title,
                          isDark: isDark,
                          isMobile: isMobile,
                          fontScale: fontScale,
                        ),

                        if (articles.length > 1)
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                isMobile ? 16 : 0, 56, isMobile ? 16 : 0, 48),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                    width: 24,
                                    height: 2,
                                    color: AppColors.primaryGreen),
                                const SizedBox(width: 16),
                                Text(
                                  isEn ? 'MORE STORIES' : 'DİĞER HABERLER',
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
                                        height: 1, color: dividerColor)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Izgara — TEMBEL ────────────────────────────────────────
            // Satırlar tek tek çiziliyor; ekranda görünmeyen kartlar
            // kurulmuyor. Ortalama ve genişlik sınırı her satıra ayrı
            // uygulanıyor çünkü artık ortak bir sarmalayıcı yok.
            if (izgaraSatirlari.isNotEmpty)
              SliverList.builder(
                itemCount: izgaraSatirlari.length,
                itemBuilder: (context, i) => Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
                      child: izgaraSatirlari[i],
                    ),
                  ),
                ),
              ),
            if (_dahaVar || _yukleniyor)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                    child: _yukleniyor
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : OutlinedButton(
                            onPressed: () => _sayfaYukle(),
                            child: Text(
                              isEn ? 'Load more' : 'Daha fazla yükle',
                              style:
                                  GoogleFonts.inter(fontWeight: FontWeight.w600),
                            ),
                          ),
                  ),
                ),
              ),
            SliverToBoxAdapter(child: PortalFooter(isDark: isDark)),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mixed grid: builds entire body as a single Column inside SliverToBoxAdapter
// so there are ZERO Expanded widgets in a scrollable context.
// ─────────────────────────────────────────────────────────────────────────────
class _MixedGrid extends StatelessWidget {
  final List<NewsArticle> articles;
  final bool isDark;
  final bool isMobile;
  final double fontScale;

  const _MixedGrid(
      {required this.articles, required this.isDark, required this.isMobile, this.fontScale = 1.0});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: satirlar(),
      );

  /// Izgaranın satırları — AYRI bir liste olarak.
  ///
  /// **Neden böyle.** Eskiden bütün ızgara tek bir `Column` içinde, o da tek
  /// bir `SliverToBoxAdapter` içinde kuruluyordu: `SliverToBoxAdapter` tek
  /// bir kutu demek, tek kutu da ekranın altında kalan kartların da ÖLÇÜLÜP
  /// ÇİZİLMESİ demek. Ana sayfada çözülen kusurun (§20.4) kategori karşılığı
  /// buydu ve sayfalama eklendikçe büyüyordu: "Daha fazla yükle" her
  /// basıldığında daha önce kurulmuş kartların tamamı yeniden kuruluyordu.
  ///
  /// Widget NESNELERİ üretmek ucuz — asıl pahalı iş eleman ve render
  /// nesnelerini kurmak, onu da `SliverList.builder` görünür olanla
  /// sınırlıyor.
  List<Widget> satirlar() {
    final rows = <Widget>[];
    int i = 0;
    int blockIndex = 0;

    while (i < articles.length) {
      if (isMobile) {
        // Mobile pattern: alternate Large / SideBySide pair
        if (blockIndex % 2 == 0) {
          rows.add(
              _LargeCard(article: articles[i], isDark: isDark, isMobile: true, fontScale: fontScale));
          rows.add(const SizedBox(height: 32));
          i += 1;
        } else {
          // Up to 2 side-by-side list items
          rows.add(_SideCard(article: articles[i], isDark: isDark, fontScale: fontScale));
          rows.add(Divider(
              height: 32, color: isDark ? Colors.white12 : Colors.black12));
          i += 1;
          if (i < articles.length) {
            rows.add(_SideCard(article: articles[i], isDark: isDark, fontScale: fontScale));
            rows.add(Divider(
                height: 32, color: isDark ? Colors.white12 : Colors.black12));
            i += 1;
          }
        }
      } else {
        // Desktop: 4-pattern rotation
        final pattern = blockIndex % 4;

        if (pattern == 0) {
          // [LARGE(2) | COMPACT STACK(1)]  – 3 articles
          final a1 = articles[i];
          final a2 = i + 1 < articles.length ? articles[i + 1] : null;
          final a3 = i + 2 < articles.length ? articles[i + 2] : null;
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    flex: 2,
                    child: _LargeCard(
                        article: a1, isDark: isDark, isMobile: false, fontScale: fontScale)),
                if (a2 != null || a3 != null) ...[
                  const SizedBox(width: 32),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (a2 != null)
                          _CompactCard(article: a2, isDark: isDark, fontScale: fontScale),
                        if (a2 != null && a3 != null)
                          const SizedBox(height: 24),
                        if (a3 != null)
                          _CompactCard(article: a3, isDark: isDark, fontScale: fontScale),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
          i += 3;
        } else if (pattern == 1) {
          // 4 standard cards in a row
          final cards = <Widget>[];
          for (int k = 0; k < 4 && i + k < articles.length; k++) {
            if (cards.isNotEmpty) cards.add(const SizedBox(width: 32));
            cards.add(Expanded(
                child: _StdCard(article: articles[i + k], isDark: isDark, fontScale: fontScale)));
          }
          rows.add(Row(
              crossAxisAlignment: CrossAxisAlignment.start, children: cards));
          i += 4;
        } else if (pattern == 2) {
          // 2 large cards
          final a1 = articles[i];
          final a2 = i + 1 < articles.length ? articles[i + 1] : null;
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: _LargeCard(
                        article: a1, isDark: isDark, isMobile: false, fontScale: fontScale)),
                if (a2 != null) ...[
                  const SizedBox(width: 32),
                  Expanded(
                      child: _LargeCard(
                          article: a2, isDark: isDark, isMobile: false, fontScale: fontScale)),
                ],
              ],
            ),
          );
          i += 2;
        } else {
          // 3 standard cards
          final cards = <Widget>[];
          for (int k = 0; k < 3 && i + k < articles.length; k++) {
            if (cards.isNotEmpty) cards.add(const SizedBox(width: 32));
            cards.add(Expanded(
                child: _StdCard(article: articles[i + k], isDark: isDark, fontScale: fontScale)));
          }
          rows.add(Row(
              crossAxisAlignment: CrossAxisAlignment.start, children: cards));
          i += 3;
        }
      }

      rows.add(const SizedBox(height: 48));
      blockIndex++;
    }

    return rows;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  HERO (full-bleed cinematic)
// ─────────────────────────────────────────────────────────────────────────────
class _HeroArticle extends StatefulWidget {
  final NewsArticle article;
  final String categoryName;
  final bool isDark;
  final bool isMobile;
  final double fontScale;
  const _HeroArticle(
      {required this.article,
      required this.categoryName,
      required this.isDark,
      required this.isMobile,
      this.fontScale = 1.0});

  @override
  State<_HeroArticle> createState() => _HeroArticleState();
}

class _HeroArticleState extends State<_HeroArticle> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final title = (isEn && a.titleEn != null && a.titleEn!.isNotEmpty)
        ? a.titleEn!
        : a.title;
    final summary = (isEn && a.summaryEn != null && a.summaryEn!.isNotEmpty)
        ? a.summaryEn!
        : (a.summary ?? '');

    return MouseRegion(
      onEnter: (_) { if (hoverPointerLikely) setState(() => _hovered = true); },
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => pushScreen(context, ArticleDetailScreen(article: a)),
        child: AspectRatio(
          aspectRatio: widget.isMobile ? 1.0 : 2.4,
          child: ClipRRect(
            borderRadius:
                widget.isMobile ? BorderRadius.zero : BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedScale(
                  scale: _hovered ? 1.03 : 1.0,
                  duration: const Duration(seconds: 4),
                  curve: Curves.easeOutQuart,
                  child: NewsArticleImage(
                      imageUrl: a.imageUrl,
                      fit: BoxFit.cover,
                      isHighQuality: true),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.35, 0.75, 1.0],
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.transparent,
                        Colors.black.withOpacity(0.65),
                        Colors.black.withOpacity(0.95),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: widget.isMobile ? 24 : 48,
                  left: widget.isMobile ? 16 : 48,
                  right: widget.isMobile ? 16 : 48,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Container(
                                color: AppColors.primaryGreen,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                child: Text(widget.categoryName.toTurkishUpperCase(),
                                    style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.5,
                                        color: Colors.white)),
                              ),
                              const SizedBox(width: 12),
                            ]),
                            const SizedBox(height: 20),
                            Text(title,
                                style: GoogleFonts.outfit(
                                    fontSize: (widget.isMobile ? 27.0 : 48.0) * widget.fontScale,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.12)),
                            const SizedBox(height: 10),
                            ArticleTimestamp(
                              published: widget.article.createdAt,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                            const SizedBox(height: 16),
                            Text(summary,
                                maxLines: widget.isMobile ? 2 : 3,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.lora(
                                    fontSize: (widget.isMobile ? 15.5 : 17.5) * widget.fontScale,
                                    color: Colors.white70,
                                    height: 1.4)),
                          ],
                        ),
                      ),
                      if (!widget.isMobile) ...[
                        const SizedBox(width: 24),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _hovered
                                ? AppColors.primaryGreen
                                : Colors.transparent,
                            border: Border.all(
                                color: _hovered
                                    ? AppColors.primaryGreen
                                    : Colors.white30,
                                width: 2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 30),
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

// ─────────────────────────────────────────────────────────────────────────────
//  LARGE CARD (16:9 image + text below) — no Expanded
// ─────────────────────────────────────────────────────────────────────────────
class _LargeCard extends StatefulWidget {
  final NewsArticle article;
  final bool isDark;
  final bool isMobile;
  final double fontScale;
  const _LargeCard(
      {required this.article, required this.isDark, required this.isMobile, this.fontScale = 1.0});

  @override
  State<_LargeCard> createState() => _LargeCardState();
}

class _LargeCardState extends State<_LargeCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final title = (isEn && a.titleEn != null && a.titleEn!.isNotEmpty)
        ? a.titleEn!
        : a.title;
    final summary = (isEn && a.summaryEn != null && a.summaryEn!.isNotEmpty)
        ? a.summaryEn!
        : (a.summary ?? '');
    final textColor = widget.isDark ? Colors.white : Colors.black87;

    return MouseRegion(
      onEnter: (_) { if (hoverPointerLikely) setState(() => _hovered = true); },
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
              child: Stack(fit: StackFit.expand, children: [
                NewsArticleImage(imageUrl: a.imageUrl, fit: BoxFit.cover),
                if (_hovered)
                  Container(color: AppColors.primaryGreen.withOpacity(0.12)),
              ]),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 10),
            Text(title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                    fontSize: (widget.isMobile ? 23.0 : 34.0) * widget.fontScale,
                    fontWeight: FontWeight.w900,
                    color: _hovered ? AppColors.primaryGreen : textColor,
                    height: 1.20)),
            const SizedBox(height: 10),
            Text(summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lora(
                    fontSize: (widget.isMobile ? 15.5 : 16.0) * widget.fontScale,
                    color: widget.isDark ? Colors.white60 : Colors.black54,
                    height: 1.70)),
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

// ─────────────────────────────────────────────────────────────────────────────
//  STANDARD CARD (3:2 image + text below)
// ─────────────────────────────────────────────────────────────────────────────
class _StdCard extends StatefulWidget {
  final NewsArticle article;
  final bool isDark;
  final double fontScale;
  const _StdCard({required this.article, required this.isDark, this.fontScale = 1.0});

  @override
  State<_StdCard> createState() => _StdCardState();
}

class _StdCardState extends State<_StdCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final title = (isEn && a.titleEn != null && a.titleEn!.isNotEmpty)
        ? a.titleEn!
        : a.title;
    final textColor = widget.isDark ? Colors.white : Colors.black87;

    return MouseRegion(
      onEnter: (_) { if (hoverPointerLikely) setState(() => _hovered = true); },
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => pushScreen(context, ArticleDetailScreen(article: a)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 3 / 2,
              child: Stack(fit: StackFit.expand, children: [
                NewsArticleImage(imageUrl: a.imageUrl, fit: BoxFit.cover),
                if (_hovered)
                  Container(color: AppColors.primaryGreen.withOpacity(0.12)),
              ]),
            ),
            const SizedBox(height: 14),
            const SizedBox(height: 8),
            Text(title,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                    fontSize: 21.0 * widget.fontScale,
                    fontWeight: FontWeight.w900,
                    color: _hovered ? AppColors.primaryGreen : textColor,
                    height: 1.25)),
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

// ─────────────────────────────────────────────────────────────────────────────
//  COMPACT CARD (16:9 image + title) — used in the right column of pattern 0
// ─────────────────────────────────────────────────────────────────────────────
class _CompactCard extends StatefulWidget {
  final NewsArticle article;
  final bool isDark;
  final double fontScale;
  const _CompactCard({required this.article, required this.isDark, this.fontScale = 1.0});

  @override
  State<_CompactCard> createState() => _CompactCardState();
}

class _CompactCardState extends State<_CompactCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final title = (isEn && a.titleEn != null && a.titleEn!.isNotEmpty)
        ? a.titleEn!
        : a.title;
    final textColor = widget.isDark ? Colors.white : Colors.black87;

    return MouseRegion(
      onEnter: (_) { if (hoverPointerLikely) setState(() => _hovered = true); },
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
              child: Stack(fit: StackFit.expand, children: [
                NewsArticleImage(imageUrl: a.imageUrl, fit: BoxFit.cover),
                if (_hovered)
                  Container(color: AppColors.primaryGreen.withOpacity(0.12)),
              ]),
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 6),
            Text(title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                    fontSize: 18.5 * widget.fontScale,
                    fontWeight: FontWeight.w800,
                    color: _hovered ? AppColors.primaryGreen : textColor,
                    height: 1.25)),
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

// ─────────────────────────────────────────────────────────────────────────────
//  SIDE CARD (mobile: thumbnail left + title right)
// ─────────────────────────────────────────────────────────────────────────────
class _SideCard extends StatefulWidget {
  final NewsArticle article;
  final bool isDark;
  final double fontScale;
  const _SideCard({required this.article, required this.isDark, this.fontScale = 1.0});

  @override
  State<_SideCard> createState() => _SideCardState();
}

class _SideCardState extends State<_SideCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final title = (isEn && a.titleEn != null && a.titleEn!.isNotEmpty)
        ? a.titleEn!
        : a.title;
    final textColor = widget.isDark ? Colors.white : Colors.black87;

    return MouseRegion(
      onEnter: (_) { if (hoverPointerLikely) setState(() => _hovered = true); },
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => pushScreen(context, ArticleDetailScreen(article: a)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              height: 80,
              child: Stack(fit: StackFit.expand, children: [
                NewsArticleImage(imageUrl: a.imageUrl, fit: BoxFit.cover),
                if (_hovered)
                  Container(color: AppColors.primaryGreen.withOpacity(0.12)),
              ]),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                          fontSize: 16.5 * widget.fontScale,
                          fontWeight: FontWeight.w800,
                          color: _hovered ? AppColors.primaryGreen : textColor,
                          height: 1.25)),
                  const SizedBox(height: 6),
                  ArticleTimestamp(
                    published: a.createdAt,
                    color: widget.isDark
                        ? AppColors.wheat
                        : AppColors.earthText.withValues(alpha: 0.70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bilinmeyen slug ile doğrudan açılan `/kategori/...` adresi.
class _NotFound extends StatelessWidget {
  final bool isEn;
  const _NotFound({required this.isEn});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEn ? 'Category not found' : 'Kategori bulunamadı',
                style: GoogleFonts.outfit(
                    fontSize: 22, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => context.go('/'),
                child: Text(isEn ? 'Go to home' : 'Ana sayfaya dön'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
