// ignore_for_file: deprecated_member_use
import 'package:tarim_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/responsive_breakpoints.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../dashboard/presentation/widgets/market_ticker.dart';
import '../../data/models/news_article.dart';
import '../../providers/home_providers.dart';
import '../widgets/agenda_bento_grid.dart';
import '../widgets/hero_fold.dart';
import '../widgets/portal_sections/science_reports_dossier.dart';
import '../widgets/portal_sections/turkey_news_grid.dart';
import '../widgets/portal_sections/world_news_row.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../../../../core/utils/image_fallback_helper.dart';
import 'weather_detail_screen.dart';
import '../widgets/news_search_delegate.dart';
import '../widgets/portal_footer.dart';
import '../widgets/yyt_dosyasi_section.dart';
import 'article_detail_screen.dart';
import 'category_articles_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme         = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);
    final user          = ref.watch(currentUserProvider);
    final isDark        = theme.brightness == Brightness.dark;
    final rawNewsAsync = ref.watch(latestArticlesProvider);

    final bgColor = isDark
        ? AppColors.darkGreen
        : AppColors.creamBackground;

    final appBarBgColor = isDark
        ? const Color(0xFF080B0E)
        : const Color(0xFFF3F2ED);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(36 + kToolbarHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MarketTicker(),
            _buildAppBar(
              context:       context,
              ref:           ref,
              theme:         theme,
              localizations: localizations,
              currentLocale: currentLocale,
              isDark:        isDark,
              bgColor:       appBarBgColor,
              user:          user,
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: rawNewsAsync.when(
                data: (_) {
                  return _buildBody(
                    context:       context,
                    ref:           ref,
                    theme:         theme,
                    isDark:        isDark,
                    localizations: localizations,
                  );
                },
                loading: () => _HomeSkeletonLoader(isDark: isDark),
                error: (e, _) => Center(
                  child: Text(
                    'Hata: $e',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.error),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Responsive yönlendirici ───────────────────────────────────────────────
  Widget _buildBody({
    required BuildContext context,
    required WidgetRef ref,
    required ThemeData theme,
    required bool isDark,
    required AppLocalizations localizations,
  }) {
    final width = MediaQuery.of(context).size.width;

    if (width >= ResponsiveBreakpoints.desktopMax) {
      return _DesktopContent(
        theme: theme,
        isDark: isDark,
        localizations: localizations,
        maxWidth: 1200,
        hPad: 24,
        vPad: 20,
      );
    }
    if (width >= ResponsiveBreakpoints.tabletMax) {
      return _DesktopContent(
        theme: theme,
        isDark: isDark,
        localizations: localizations,
        maxWidth: 1200,
        hPad: 24,
        vPad: 20,
      );
    }
    if (width >= ResponsiveBreakpoints.mobileMax) {
      return _TabletContent(
        theme: theme,
        isDark: isDark,
        localizations: localizations,
      );
    }
    return _MobileContent(
      theme: theme,
      isDark: isDark,
      localizations: localizations,
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  AppBar _buildAppBar({
    required BuildContext context,
    required WidgetRef ref,
    required ThemeData theme,
    required AppLocalizations localizations,
    required Locale currentLocale,
    required bool isDark,
    required Color bgColor,
    required User? user,
  }) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    if (_isSearchExpanded) {
      return AppBar(
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : Colors.black),
          onPressed: () {
            setState(() {
              _isSearchExpanded = false;
              _searchController.clear();
            });
          },
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          style: GoogleFonts.inter(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: currentLocale.languageCode == 'en' ? 'Search news...' : 'Haberlerde ara...',
            hintStyle: GoogleFonts.inter(color: isDark ? Colors.white54 : Colors.black54),
            border: InputBorder.none,
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (val) {
            if (val.trim().isNotEmpty) {
              final query = val.trim();
              setState(() {
                _isSearchExpanded = false;
                _searchController.clear();
              });
              showSearch(
                context: context,
                delegate: NewsSearchDelegate(ref: ref, isEn: currentLocale.languageCode == 'en'),
                query: query,
              );
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, color: isDark ? Colors.white : Colors.black),
            onPressed: () {
              if (_searchController.text.trim().isNotEmpty) {
                final query = _searchController.text.trim();
                setState(() {
                  _isSearchExpanded = false;
                  _searchController.clear();
                });
                showSearch(
                  context: context,
                  delegate: NewsSearchDelegate(ref: ref, isEn: currentLocale.languageCode == 'en'),
                  query: query,
                );
              }
            },
          ),
        ],
      );
    }

    return AppBar(
      backgroundColor: bgColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1.0,
      shadowColor: isDark
          ? AppColors.wheat
          : AppColors.wheat,
      titleSpacing: isDesktop ? NavigationToolbar.kMiddleSpacing : 4,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.eco_rounded, color: theme.colorScheme.primary, size: isDesktop ? 26 : 22),
          SizedBox(width: isDesktop ? 8 : 4),
          Expanded(
            child: Text(
              'TARIM PORTALI',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.w900,
                fontSize: isDesktop ? 20 : 17,
                color: isDark
                    ? AppColors.creamBackground
                    : AppColors.earthText,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (isDesktop)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: isDark 
                    ? theme.colorScheme.primary.withValues(alpha: 0.15) 
                    : theme.colorScheme.primary.withValues(alpha: 0.1),
                foregroundColor: isDark ? AppColors.primaryGreen : AppColors.primaryGreen,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(Icons.search_rounded, size: 22),
              label: Text(
                currentLocale.languageCode == 'en' ? 'Search' : 'Ara',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
              onPressed: () {
                setState(() {
                  _isSearchExpanded = true;
                });
                Future.delayed(const Duration(milliseconds: 100), () {
                  _searchFocusNode.requestFocus();
                });
              },
            ),
          )
        else
          IconButton(
            icon: Icon(Icons.search_rounded, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {
              setState(() {
                _isSearchExpanded = true;
              });
              Future.delayed(const Duration(milliseconds: 100), () {
                _searchFocusNode.requestFocus();
              });
            },
          ),
        
        _LanguageToggle(currentLocale: currentLocale, isDark: isDark),
        if (isDesktop) const SizedBox(width: 4),
        _WeatherChip(isDark: isDark),
        
        if (isDesktop) ...[
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            icon: Icon(
              user == null ? Icons.account_circle_outlined : Icons.admin_panel_settings_rounded,
              color: isDark ? AppColors.creamBackground : AppColors.earthText,
            ),
            tooltip: 'Hesap Menüsü',
            onSelected: (value) async {
              if (value == 'login') {
                Navigator.of(context).push(
                  createFadeRoute(const LoginScreen()),
                );
              } else if (value == 'dashboard') {
                Navigator.of(context).push(
                  createFadeRoute(const DashboardScreen()),
                );
              } else if (value == 'logout') {
                await ref.read(supabaseClientProvider).auth.signOut();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Başarıyla çıkış yapıldı.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              if (user == null)
                PopupMenuItem(
                  value: 'login',
                  child: Row(
                    children: [
                      Icon(Icons.login_rounded, color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(currentLocale.languageCode == 'en' ? 'Editor Login' : 'Yazar Girişi', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              else ...[
                PopupMenuItem(
                  value: 'dashboard',
                  child: Row(
                    children: [
                      Icon(Icons.admin_panel_settings_rounded, color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(currentLocale.languageCode == 'en' ? 'Dashboard' : 'Yönetim Paneli', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 8),
                      Text(currentLocale.languageCode == 'en' ? 'Logout' : 'Çıkış Yap', style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
        if (isDesktop) const SizedBox(width: 8),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  İÇERİK LAYOUT SINIFLAR (TAM GENİŞLİK VE TEMİZ İSKELET)
// ═══════════════════════════════════════════════════════════════════════════

// ─── Mobil (< 650px) ─────────────────────────────────────────────────────

class _MobileContent extends ConsumerWidget {
  final ThemeData theme;
  final bool isDark;
  final AppLocalizations localizations;

  const _MobileContent({
    required this.theme,
    required this.isDark,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(latestArticlesProvider),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _PortalHeroSection(isDark: isDark),
          const SizedBox(height: 28),
          YYTDosyasiSection(isDark: isDark),
          const SizedBox(height: 28),
          _TurkeyNewsSection(isDark: isDark),
          const SizedBox(height: 28),
          _ScienceAndReportsSection(isDark: isDark),
          const SizedBox(height: 28),
          _WorldNewsSection(isDark: isDark),
          const SizedBox(height: 28),
          _TrendingSection(isDark: isDark),
          const SizedBox(height: 28),
          _SectoralNewsSection(topic: 'Hayvancılık', isDark: isDark),
          const SizedBox(height: 28),
          _SectoralNewsSection(topic: 'Bitkisel Üretim', isDark: isDark),
          const SizedBox(height: 28),
          _SectoralNewsSection(topic: 'Ekonomi', isDark: isDark),
          const SizedBox(height: 28),
          _SectoralNewsSection(topic: 'Genel', isDark: isDark),
          const SizedBox(height: 32),
          PortalFooter(isDark: isDark),
        ],
      ),
    );
  }
}

// ─── Tablet (650–1100px) ──────────────────────────────────────────────────

class _TabletContent extends ConsumerWidget {
  final ThemeData theme;
  final bool isDark;
  final AppLocalizations localizations;

  const _TabletContent({
    required this.theme,
    required this.isDark,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(latestArticlesProvider),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _PortalHeroSection(isDark: isDark),
          const SizedBox(height: 36),
          YYTDosyasiSection(isDark: isDark),
          const SizedBox(height: 36),
          _TurkeyNewsSection(isDark: isDark),
          const SizedBox(height: 36),
          _ScienceAndReportsSection(isDark: isDark),
          const SizedBox(height: 36),
          _WorldNewsSection(isDark: isDark),
          const SizedBox(height: 36),
          _TrendingSection(isDark: isDark),
          const SizedBox(height: 36),
          _SectoralNewsSection(topic: 'Hayvancılık', isDark: isDark),
          const SizedBox(height: 36),
          _SectoralNewsSection(topic: 'Bitkisel Üretim', isDark: isDark),
          const SizedBox(height: 36),
          _SectoralNewsSection(topic: 'Ekonomi', isDark: isDark),
          const SizedBox(height: 36),
          _SectoralNewsSection(topic: 'Genel', isDark: isDark),
          const SizedBox(height: 48),
          PortalFooter(isDark: isDark),
        ],
      ),
    );
  }
}

// ─── Desktop / LargeScreen (> 1100px) ────────────────────────────────────

class _DesktopContent extends ConsumerWidget {
  final ThemeData theme;
  final bool isDark;
  final AppLocalizations localizations;
  final double maxWidth;
  final double hPad;
  final double vPad;

  const _DesktopContent({
    required this.theme,
    required this.isDark,
    required this.localizations,
    required this.maxWidth,
    required this.hPad,
    required this.vPad,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: _PortalHeroSection(isDark: isDark),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: YYTDosyasiSection(isDark: isDark),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: _TurkeyNewsSection(isDark: isDark),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: _ScienceAndReportsSection(isDark: isDark),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: _WorldNewsSection(isDark: isDark),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: _TrendingSection(isDark: isDark),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: _SectoralNewsSection(topic: 'Hayvancılık', isDark: isDark),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: _SectoralNewsSection(topic: 'Bitkisel Üretim', isDark: isDark),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: _SectoralNewsSection(topic: 'Ekonomi', isDark: isDark),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: _SectoralNewsSection(topic: 'Genel', isDark: isDark),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: PortalFooter(isDark: isDark),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  KÜÇÜK PAYLAŞILAN WIDGET'LAR
// ═══════════════════════════════════════════════════════════════════════════

class _WeatherChip extends ConsumerWidget {
  final bool isDark;

  const _WeatherChip({required this.isDark});

  String _icon(String code) {
    switch (code) {
      case '01d': return '☀️';
      case '01n': return '🌙';
      case '02d':
      case '02n': return '⛅';
      case '03d':
      case '03n':
      case '04d':
      case '04n': return '☁️';
      case '09d':
      case '09n':
      case '10d':
      case '10n': return '🌧️';
      case '11d':
      case '11n': return '⛈️';
      case '13d':
      case '13n': return '❄️';
      default:    return '⛅';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);
    final w = weatherAsync.value;
    
    if (w != null) {
      final color = isDark
          ? const Color(0xFFCCCCCC)
          : const Color(0xFF444444);
      return InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () => Navigator.of(context).push(
          createFadeRoute(WeatherDetailScreen(weather: w)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _icon(w.iconCode),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 4),
              Text(
                '${w.temperature.toStringAsFixed(0)}°C',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Home skeleton yükleyicisi — veri gelene kadar shimmer iskelet
// ══════════════════════════════════════════════════════════════════════════════

class _HomeSkeletonLoader extends StatelessWidget {
  final bool isDark;

  const _HomeSkeletonLoader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero carousel iskelet (16:9)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ShimmerPlaceholder(
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          const SizedBox(height: 24),

          // Bölüm başlığı iskelet
          ShimmerPlaceholder(width: 260, height: 18),
          const SizedBox(height: 14),
          ShimmerPlaceholder(width: double.infinity, height: 1),
          const SizedBox(height: 20),

          // Büyük featured kart iskeleti
          NewsCardSkeleton(isDark: isDark),
          const SizedBox(height: 12),

          // 2-sütun satır iskeleti
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: SmallCardSkeleton(isDark: isDark)),
                const SizedBox(width: 10),
                Expanded(child: SmallCardSkeleton(isDark: isDark)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 3-kart satır iskeleti
          Row(
            children: [
              Expanded(child: NewsCardSkeleton(isDark: isDark)),
              const SizedBox(width: 12),
              Expanded(child: NewsCardSkeleton(isDark: isDark)),
              const SizedBox(width: 12),
              Expanded(child: NewsCardSkeleton(isDark: isDark)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LanguageToggle extends ConsumerWidget {
  final Locale currentLocale;
  final bool isDark;

  const _LanguageToggle({
    required this.currentLocale,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = isDark
        ? AppColors.wheat
        : AppColors.earthText;

    return TextButton(
      onPressed: () => ref.read(localeProvider.notifier).toggleLocale(),
      style: TextButton.styleFrom(
        foregroundColor: color,
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.language_rounded, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            currentLocale.languageCode.toUpperCase(),
            style: GoogleFonts.robotoMono(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  EN ÇOK OKUNANLAR (TRENDING) BÖLÜMÜ
// ═══════════════════════════════════════════════════════════════════════════

class _TrendingSection extends ConsumerWidget {
  final bool isDark;

  const _TrendingSection({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider); // Rebuild when language changes
    final trendingAsync = ref.watch(trendingArticlesProvider);
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final titleText = isEn ? 'TRENDING' : 'EN ÇOK OKUNANLAR';
    
    final headerColor = isDark ? AppColors.creamBackground : AppColors.earthText;
    final dividerColor = isDark ? AppColors.creamBackground : AppColors.earthText;

    return trendingAsync.when(
      data: (articles) {
        if (articles.isEmpty) return const SizedBox.shrink();
        
        // Show up to 5 trending articles
        final topArticles = articles.take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 3, width: double.infinity, color: dividerColor),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        titleText,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                          color: headerColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120, // Enough for a compact horizontal card
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: topArticles.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final a = topArticles[i];
                  return _TrendingCard(article: a, index: i, isDark: isDark, isEn: isEn);
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _TrendingCard extends StatefulWidget {
  final NewsArticle article;
  final int index;
  final bool isDark;
  final bool isEn;

  const _TrendingCard({
    required this.article,
    required this.index,
    required this.isDark,
    required this.isEn,
  });

  @override
  State<_TrendingCard> createState() => _TrendingCardState();
}

class _TrendingCardState extends State<_TrendingCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    final title = (widget.isEn && a.titleEn != null && a.titleEn!.isNotEmpty) ? a.titleEn! : a.title;
    
    final bg = widget.isDark ? AppColors.darkGreen : const Color(0xFFF9F9F9);
    final border = widget.isDark ? AppColors.wheat : AppColors.wheat;
    final textCol = widget.isDark ? const Color(0xFFE6EDF3) : const Color(0xFF24292F);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(createFadeRoute(ArticleDetailScreen(article: a)));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 280,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hover ? Theme.of(context).colorScheme.primary : border,
              width: _hover ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(
                '#${widget.index + 1}',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: widget.isDark ? Colors.white24 : Colors.black12,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textCol,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          '${a.viewCount} ${widget.isEn ? 'Views' : 'Okuma'}',
                          style: GoogleFonts.robotoMono(
                            fontSize: 10,
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  PORTAL SECTIONS (YENİ MİMARİ)
// ═══════════════════════════════════════════════════════════════════════════

class _PortalHeroSection extends ConsumerWidget {
  final bool isDark;
  const _PortalHeroSection({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(heroArticlesProvider);
    if (articles.isEmpty) return const SizedBox.shrink();
    
    // For now we reuse HeroFold but pass only the top hero articles
    return HeroFold(articles: articles);
  }
}

class _TurkeyNewsSection extends ConsumerWidget {
  final bool isDark;
  const _TurkeyNewsSection({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(turkeyNewsProvider);
    if (articles.isEmpty) return const SizedBox.shrink();

    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final title = isEn ? 'NEWS FROM TURKEY' : 'TÜRKİYE\'DEN HABERLER';

    return Column(
      children: [
        _SectionContainer(
          title: title,
          icon: Icons.location_on_rounded,
          iconColor: Colors.redAccent,
          isDark: isDark,
          onSeeAll: articles.isNotEmpty ? () {
            Navigator.of(context).push(createFadeRoute(CategoryArticlesScreen(title: title, articles: articles)));
          } : null,
          child: TurkeyNewsGrid(
            articles: articles.take(6).toList(),
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _WorldNewsSection extends ConsumerWidget {
  final bool isDark;
  const _WorldNewsSection({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(worldNewsProvider);
    if (articles.isEmpty) return const SizedBox.shrink();

    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final title = isEn ? 'WORLD NEWS' : 'DÜNYADAN HABERLER';

    return Column(
      children: [
        _SectionContainer(
          title: title,
          icon: Icons.public_rounded,
          iconColor: Colors.blueAccent,
          isDark: isDark,
          onSeeAll: articles.isNotEmpty ? () {
            Navigator.of(context).push(createFadeRoute(CategoryArticlesScreen(title: title, articles: articles)));
          } : null,
          child: WorldNewsRow(
            articles: articles.take(10).toList(), // Show up to 10 for scroll
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _ScienceAndReportsSection extends ConsumerWidget {
  final bool isDark;
  const _ScienceAndReportsSection({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(scienceAndReportsProvider);
    if (articles.isEmpty) return const SizedBox.shrink();

    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final title = isEn ? 'SCIENCE & REPORTS' : 'TARIM-BİLİM VE RAPORLAR';

    return Column(
      children: [
        _SectionContainer(
          title: title,
          icon: Icons.science_rounded,
          iconColor: Colors.purpleAccent,
          isDark: isDark,
          onSeeAll: articles.isNotEmpty ? () {
            Navigator.of(context).push(createFadeRoute(CategoryArticlesScreen(title: title, articles: articles)));
          } : null,
          child: ScienceReportsDossier(
            articles: articles.take(6).toList(),
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _SectoralNewsSection extends ConsumerWidget {
  final String topic;
  final bool isDark;
  
  const _SectoralNewsSection({required this.topic, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider); // Rebuild when language changes
    final articles = ref.watch(categoryArticlesProvider(topic));
    if (articles.isEmpty) return const SizedBox.shrink();

    final isEn = Localizations.localeOf(context).languageCode == 'en';
    String displayTopic = topic.toUpperCase();
    if (isEn) {
      if (topic == 'Hayvancılık') displayTopic = 'LIVESTOCK';
      if (topic == 'Bitkisel Üretim') displayTopic = 'CROP PRODUCTION';
      if (topic == 'Ekonomi') displayTopic = 'ECONOMY';
    }

    return _SectionContainer(
      title: displayTopic,
      icon: Icons.category_rounded,
      iconColor: Theme.of(context).colorScheme.primary,
      isDark: isDark,
      onSeeAll: articles.isNotEmpty ? () {
        Navigator.of(context).push(
          createFadeRoute(CategoryArticlesScreen(title: displayTopic, articles: articles)),
        );
      } : null,
      child: AgendaBentoGrid(articles: articles.take(6).toList(), isDark: isDark),
    );
  }
}

class _SectionContainer extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  final bool isDark;
  final VoidCallback? onSeeAll;

  const _SectionContainer({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
    required this.isDark,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final headerColor = isDark ? AppColors.creamBackground : AppColors.earthText;
    final dividerColor = isDark ? AppColors.creamBackground : AppColors.earthText;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 3, width: double.infinity, color: dividerColor),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(icon, color: iconColor, size: isMobile ? 18 : 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: isMobile ? 16 : 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                        color: headerColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onSeeAll != null)
                    TextButton(
                      onPressed: onSeeAll,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isEn ? 'See All' : 'Daha fazla',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_rounded, size: 16),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: child,
        ),
      ],
    );
  }
}

