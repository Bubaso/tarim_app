// ignore_for_file: deprecated_member_use
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
import '../../../../core/utils/fade_page_route.dart';
import '../../../../core/utils/image_fallback_helper.dart';
import 'weather_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme         = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);
    final user          = ref.watch(currentUserProvider);
    final isDark        = theme.brightness == Brightness.dark;
    final newsAsync     = ref.watch(latestArticlesProvider);

    final bgColor = isDark
        ? const Color(0xFF0C1015)
        : const Color(0xFFFAF9F6);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(28 + kToolbarHeight),
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
              bgColor:       bgColor,
              user:          user,
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: newsAsync.when(
          data: (articles) => _buildBody(
            context:       context,
            ref:           ref,
            theme:         theme,
            isDark:        isDark,
            localizations: localizations,
            articles:      articles,
          ),
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
    );
  }

  // ── Responsive yönlendirici ───────────────────────────────────────────────
  Widget _buildBody({
    required BuildContext context,
    required WidgetRef ref,
    required ThemeData theme,
    required bool isDark,
    required AppLocalizations localizations,
    required List<NewsArticle> articles,
  }) {
    final width = MediaQuery.of(context).size.width;

    if (width >= ResponsiveBreakpoints.desktopMax) {
      return _DesktopContent(
        theme: theme,
        isDark: isDark,
        localizations: localizations,
        articles: articles,
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
        articles: articles,
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
        articles: articles,
      );
    }
    return _MobileContent(
      theme: theme,
      isDark: isDark,
      localizations: localizations,
      articles: articles,
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
    return AppBar(
      backgroundColor: bgColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1.0,
      shadowColor: isDark
          ? const Color(0xFF30363D)
          : const Color(0xFFE0E0E0),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.eco_rounded, color: theme.colorScheme.primary, size: 26),
          const SizedBox(width: 8),
          Text(
            localizations.translate('app_title').toUpperCase(),
            style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: isDark
                  ? const Color(0xFFF0F6FC)
                  : const Color(0xFF1A1A1A),
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      actions: [
        _LanguageToggle(currentLocale: currentLocale, isDark: isDark),
        const SizedBox(width: 4),
        _WeatherChip(isDark: isDark),
        const SizedBox(width: 4),
        PopupMenuButton<String>(
          icon: Icon(
            user == null ? Icons.account_circle_outlined : Icons.admin_panel_settings_rounded,
            color: isDark ? const Color(0xFFF0F6FC) : const Color(0xFF1A1A1A),
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
                    Text('Yazar Girişi', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
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
                    Text('Yönetim Paneli', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 8),
                    Text('Çıkış Yap', style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(width: 12),
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
  final List<NewsArticle> articles;

  const _MobileContent({
    required this.theme,
    required this.isDark,
    required this.localizations,
    required this.articles,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(latestArticlesProvider),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          HeroFold(articles: articles),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AgendaBentoGrid(articles: articles, isDark: isDark),
          ),
          const SizedBox(height: 32),
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
  final List<NewsArticle> articles;

  const _TabletContent({
    required this.theme,
    required this.isDark,
    required this.localizations,
    required this.articles,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(latestArticlesProvider),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          HeroFold(articles: articles),
          const SizedBox(height: 36),
          AgendaBentoGrid(articles: articles, isDark: isDark),
          const SizedBox(height: 32),
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
  final List<NewsArticle> articles;
  final double maxWidth;
  final double hPad;
  final double vPad;

  const _DesktopContent({
    required this.theme,
    required this.isDark,
    required this.localizations,
    required this.articles,
    required this.maxWidth,
    required this.hPad,
    required this.vPad,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: HeroFold(articles: articles),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: AgendaBentoGrid(
                    articles: articles,
                    isDark: isDark,
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
    return ref.watch(weatherProvider).when(
      data: (w) {
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
      },
      loading: () => const SizedBox.shrink(),
      error:   (error, _) => const SizedBox.shrink(),
    );
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
        ? const Color(0xFF8B949E)
        : const Color(0xFF666666);

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
