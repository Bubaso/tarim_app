// ignore_for_file: deprecated_member_use
import 'package:tarim_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/article_timestamp.dart';
import '../../../../core/widgets/section_container.dart';
import '../../../../core/utils/responsive_breakpoints.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../commodities/presentation/widgets/commodity_strip.dart';
import '../../../commodities/providers/commodity_providers.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../data/models/news_article.dart';
import '../../providers/home_providers.dart';
import '../../../../core/services/notification_service.dart';
import '../widgets/agenda_bento_grid.dart';
import '../widgets/hero_fold.dart';
import '../widgets/news_ticker.dart';
import '../widgets/portal_sections/science_reports_dossier.dart';
import '../widgets/portal_sections/turkey_news_grid.dart';
import '../widgets/portal_sections/world_news_row.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../../../../core/utils/image_fallback_helper.dart';
import 'weather_detail_screen.dart';
import '../widgets/news_search_delegate.dart';
import '../widgets/portal_footer.dart';
import '../widgets/yyt_dosyasi_section.dart';
import '../widgets/kisa_kisa_section.dart';
import '../widgets/ios_pwa_prompt.dart';
import '../../../dossiers/presentation/widgets/dossier_strip.dart';
import 'article_detail_screen.dart';
import 'category_articles_screen.dart';
import '../../../../core/utils/string_extensions.dart';

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowSoftPrompt();
    });
  }

  Future<void> _checkAndShowSoftPrompt() async {
    final notifService = ref.read(notificationServiceProvider);
    final shouldShow = await notifService.shouldShowSoftPrompt();
    if (shouldShow && mounted) {
      _showSoftPromptDialog(context, notifService);
    }
  }

  void _showSoftPromptDialog(BuildContext context, NotificationService service) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkGreen : AppColors.creamBackground,
          title: Text(
            'Bildirimleri Açın',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: Text(
            'Piyasadaki ani değişimlerden ve önemli tarım haberlerinden anında haberdar olmak ister misiniz?',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () {
                service.denySoftPrompt();
                Navigator.of(context).pop();
              },
              child: const Text('Belki Daha Sonra', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await service.requestPermission();
              },
              child: const Text('Evet İsterim'),
            ),
          ],
        );
      },
    );
  }

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
            const NewsTicker(),
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
                error: (e, _) => _HomeErrorView(
                  isDark: isDark,
                  onRetry: () => ref.invalidate(latestArticlesProvider),
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
          Image.asset(
            'assets/images/logo_tp.png',
            height: isDesktop ? 38 : 32,
            errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.eco_rounded, color: theme.colorScheme.primary, size: isDesktop ? 28 : 24),
          ),
          SizedBox(width: isDesktop ? 8 : 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TARIM PORTALI',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.playfairDisplay(
                    fontWeight: FontWeight.w900,
                    fontSize: isDesktop ? 20 : 17,
                    color: isDark ? AppColors.creamBackground : AppColors.earthText,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'TARIMIN DOĞRU ADRESİ',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: isDesktop ? 10 : 8,
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
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
              if (value == 'settings') {
                pushScreen(context, const SettingsScreen());
              } else if (value == 'login') {
                pushScreen(context, const LoginScreen(),
                );
              } else if (value == 'dashboard') {
                pushScreen(context, const DashboardScreen(),
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
              // Oturumdan bağımsız: ayarlar okuyucunun kendi tercihleri,
              // editör hesabıyla ilgisi yok.
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.notifications_outlined, color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(currentLocale.languageCode == 'en' ? 'Notifications & Language' : 'Bildirimler ve Dil', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
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
      onRefresh: () async {
        ref.invalidate(latestArticlesProvider);
        ref.invalidate(latestCommodityPricesProvider);
      },
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          IosPwaPrompt(isDark: isDark),
          _PortalHeroSection(isDark: isDark),
          const SizedBox(height: 28),
          // Şerit "en son okuduklarınız"ın ÜSTÜNDE — masaüstündeki sırayla
          // aynı. O bölüm ilk kez gelen okuyucuda hiç çizilmiyor; altına
          // konduğunda fiyatların yeri okuyucudan okuyucuya kayıyordu.
          CommodityStrip(isDark: isDark, spacing: 28),
          _RecentlyReadSection(isDark: isDark, spacing: 28),
          YYTDosyasiSection(isDark: isDark),
          const SizedBox(height: 28),
          _TurkeyNewsSection(isDark: isDark),
          const SizedBox(height: 28),
          DossierStrip(isDark: isDark, spacing: 28),
          _ScienceAndReportsSection(isDark: isDark),
          const SizedBox(height: 28),
          _WorldNewsSection(isDark: isDark),
          const SizedBox(height: 28),
          _ICYMISection(isDark: isDark),
          const SizedBox(height: 28),
          // Günün ana haberlerinden sonra, konu bazlı bölümlerden önce.
          // Kısa haber ikincil haberdir; manşetin üstüne çıkmamalı ama
          // "hayvancılık" gibi gezinme bölümlerinin de altında kalmamalı.
          KisaKisaSection(isDark: isDark, spacing: 28),
          _SectoralNewsSection(topic: 'Hayvancılık', isDark: isDark),
          const SizedBox(height: 28),
          _SectoralNewsSection(topic: 'Bitkisel Üretim', isDark: isDark),
          const SizedBox(height: 28),
          _SectoralNewsSection(topic: 'Ekonomi', isDark: isDark),
          const SizedBox(height: 28),
          _TrendingSection(isDark: isDark),
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
      onRefresh: () async {
        ref.invalidate(latestArticlesProvider);
        ref.invalidate(latestCommodityPricesProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          IosPwaPrompt(isDark: isDark),
          _PortalHeroSection(isDark: isDark),
          const SizedBox(height: 36),
          CommodityStrip(isDark: isDark, spacing: 36),
          _RecentlyReadSection(isDark: isDark, spacing: 36),
          YYTDosyasiSection(isDark: isDark),
          const SizedBox(height: 36),
          _TurkeyNewsSection(isDark: isDark),
          const SizedBox(height: 36),
          DossierStrip(isDark: isDark, spacing: 36),
          _ScienceAndReportsSection(isDark: isDark),
          const SizedBox(height: 36),
          _WorldNewsSection(isDark: isDark),
          const SizedBox(height: 36),
          _ICYMISection(isDark: isDark),
          const SizedBox(height: 36),
          KisaKisaSection(isDark: isDark, spacing: 36),
          _SectoralNewsSection(topic: 'Hayvancılık', isDark: isDark),
          const SizedBox(height: 36),
          _SectoralNewsSection(topic: 'Bitkisel Üretim', isDark: isDark),
          const SizedBox(height: 36),
          _SectoralNewsSection(topic: 'Ekonomi', isDark: isDark),
          const SizedBox(height: 36),
          _TrendingSection(isDark: isDark),
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
                    IosPwaPrompt(isDark: isDark),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40, top: 16),
                      child: _PortalHeroSection(isDark: isDark),
                    ),
                    // Manşetin hemen altında, "en son okuduklarınız"ın ÜSTÜNDE.
                    // O bölüm ilk kez gelen okuyucuda hiç çizilmiyor; altına
                    // konsaydı fiyat şeridinin yeri okuyucudan okuyucuya
                    // değişirdi.
                    CommodityStrip(isDark: isDark, spacing: 40),
                    _RecentlyReadSection(isDark: isDark, spacing: 40),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: YYTDosyasiSection(isDark: isDark),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: _TurkeyNewsSection(isDark: isDark),
                    ),
                    DossierStrip(isDark: isDark, spacing: 40),
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
                      child: _ICYMISection(isDark: isDark),
                    ),
                    // Boşluğu Padding değil bölümün kendisi yayıyor: kısa haber
                    // üretilmemiş bir günde bölüm SizedBox.shrink() dönüyor ve
                    // sarmalayan Padding geriye 40 px boşluk bırakırdı.
                    KisaKisaSection(isDark: isDark, spacing: 40),
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
                      child: _TrendingSection(isDark: isDark),
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
        onTap: () => pushScreen(context, WeatherDetailScreen(weather: w),
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
//  Hata durumu — okura teknik ayrıntı değil, anlaşılır bir mesaj + tekrar dene
// ══════════════════════════════════════════════════════════════════════════════

class _HomeErrorView extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRetry;

  const _HomeErrorView({required this.isDark, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final textColor = isDark ? AppColors.creamBackground : AppColors.earthText;
    final subtleColor = isDark ? AppColors.wheat : const Color(0xFF6B6B6B);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: subtleColor,
            ),
            const SizedBox(height: 16),
            Text(
              isEn ? 'Could not load the news' : 'Haberler yüklenemedi',
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isEn
                  ? 'Please check your internet connection and try again.'
                  : 'İnternet bağlantınızı kontrol edip tekrar deneyin.',
              textAlign: TextAlign.center,
              style: GoogleFonts.libreFranklin(
                fontSize: 14,
                height: 1.45,
                color: subtleColor,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(isEn ? 'Try again' : 'Tekrar dene'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
                side: const BorderSide(color: AppColors.primaryGreen),
                // Erişilebilir dokunma alanı (min 44px).
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Home skeleton yükleyicisi — veri gelene kadar shimmer iskelet
// ══════════════════════════════════════════════════════════════════════════════

/// İskelet, yerini tuttuğu düzenin birebir aynısı olmalı; aksi hâlde veri
/// gelince sayfa zıplar. Bu yüzden [_buildBody] ile **aynı** kırılım
/// noktalarını ve aynı dolgu/boşluk değerlerini kullanıyoruz:
///   Mobil   (< 650)  → kenardan kenara, ListView padding yok
///   Tablet  (650–1099) → EdgeInsets.all(24)
///   Masaüstü (≥ 1100) → maxWidth 1200, hPad 24 / vPad 20
/// Hero bloğu ise HeroFold'un kendi 900 px eşiğini izler.
class _HomeSkeletonLoader extends StatelessWidget {
  final bool isDark;

  const _HomeSkeletonLoader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= ResponsiveBreakpoints.tabletMax) {
      return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _SkeletonHero(isDark: isDark, splitColumns: true),
                const SizedBox(height: 40),
                _SkeletonSection(isDark: isDark, compactHeader: false),
                const SizedBox(height: 40),
                _SkeletonSection(isDark: isDark, compactHeader: false),
              ],
            ),
          ),
        ),
      );
    }

    if (width >= ResponsiveBreakpoints.mobileMax) {
      final splitColumns = width >= 900;
      return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero kendi 900 px eşiğini izliyor; bölüm başlığı ise mobileMax'ı
            // — bu aralıkta (650–1099) başlık artık geniş sürümde.
            _SkeletonHero(isDark: isDark, splitColumns: splitColumns),
            const SizedBox(height: 36),
            _SkeletonSection(isDark: isDark, compactHeader: false),
            const SizedBox(height: 36),
            _SkeletonSection(isDark: isDark, compactHeader: false),
          ],
        ),
      );
    }

    // Mobil — gerçek düzende ListView padding'i sıfır, manşet kenardan kenara.
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkeletonHero(isDark: isDark, splitColumns: false),
          const SizedBox(height: 28),
          _SkeletonSection(isDark: isDark, compactHeader: true),
          const SizedBox(height: 28),
          _SkeletonSection(isDark: isDark, compactHeader: true),
        ],
      ),
    );
  }
}

/// HeroFold'un iskeleti. [splitColumns] true iken masaüstündeki 7:3 satır,
/// false iken mobildeki "manşet + yatay yazar şeridi" sütunu taklit edilir.
class _SkeletonHero extends StatelessWidget {
  final bool isDark;
  final bool splitColumns;

  const _SkeletonHero({required this.isDark, required this.splitColumns});

  @override
  Widget build(BuildContext context) {
    // HeroFold'daki carousel ile aynı en–boy oranı.
    const carousel = AspectRatio(
      aspectRatio: 1.8,
      child: ShimmerPlaceholder(width: double.infinity, height: double.infinity),
    );

    if (splitColumns) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(flex: 7, child: carousel),
            const SizedBox(width: 28),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerPlaceholder(width: 140, height: 20),
                  const SizedBox(height: 6),
                  const ShimmerPlaceholder(width: 40, height: 3),
                  const SizedBox(height: 16),
                  for (var i = 0; i < 3; i++) ...[
                    SmallCardSkeleton(isDark: isDark),
                    const SizedBox(height: 14),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        carousel,
        const SizedBox(height: 28),
        // "YAZARLARIMIZ" başlığı — gerçek düzende 16 px yatay dolgulu.
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerPlaceholder(width: 160, height: 20),
              SizedBox(height: 6),
              ShimmerPlaceholder(width: 40, height: 3),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Yatay kaydırılabilir yazar şeridi (gerçek yükseklik: 180).
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 4,
            itemBuilder: (context, index) => const Padding(
              padding: EdgeInsets.only(right: 12),
              child: ShimmerPlaceholder(width: 130, height: 180),
            ),
          ),
        ),
      ],
    );
  }
}

/// `_SectionContainer` + yatay kart şeridinin iskeleti.
class _SkeletonSection extends StatelessWidget {
  final bool isDark;

  /// `_SectionContainer` başlığı `ResponsiveBreakpoints.mobileMax` altında
  /// küçülüyor; iskelet aynı eşiği izlemeli, yoksa veri gelince başlık zıplar.
  final bool compactHeader;

  const _SkeletonSection({required this.isDark, required this.compactHeader});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bölüm üstündeki 1 px ayırıcı.
              const ShimmerPlaceholder(width: double.infinity, height: 1),
              const SizedBox(height: 16),
              Row(
                children: [
                  ShimmerPlaceholder(
                    width: compactHeader ? 20 : 24,
                    height: compactHeader ? 20 : 24,
                  ),
                  const SizedBox(width: 8),
                  ShimmerPlaceholder(
                    width: compactHeader ? 200 : 260,
                    height: compactHeader ? 17 : 20,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Yatay kart şeridi — gerçek düzende 320 yükseklik / 260 genişlik.
        SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 4,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 260,
                child: NewsCardSkeleton(isDark: isDark),
              ),
            ),
          ),
        ),
      ],
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
      onPressed: () async {
        ref.read(localeProvider.notifier).toggleLocale();
        // Dil yalnızca arayüzü değil bildirim metnini de belirliyor; cihaz
        // kaydı burada güncellenmezse okuyucu bir sonraki bildirimini eski
        // dilde alırdı (bkz. push_tokens.locale).
        await ref.read(notificationServiceProvider).syncPreferences();
      },
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
                  Container(height: 1, width: double.infinity, color: dividerColor),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.local_fire_department_rounded,
                          color: AppColors.accentFor(isDark: isDark), size: 24),
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
    final accentCol = AppColors.accentFor(isDark: widget.isDark);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          pushScreen(context, ArticleDetailScreen(article: a));
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
                        // Colors.orangeAccent (#FFAB40) krem/beyaz zeminde
                        // ~1.9:1 kontrast veriyordu — okunaksızdı ve palet dışıydı.
                        Icon(Icons.local_fire_department_rounded,
                            color: accentCol, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          '${a.viewCount} ${widget.isEn ? 'Views' : 'Okuma'}',
                          style: GoogleFonts.robotoMono(
                            fontSize: AppTypography.minLabelSize,
                            color: accentCol,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: ArticleTimestamp(
                            published: a.createdAt,
                            color: widget.isDark
                                ? AppColors.wheat
                                : AppColors.earthText.withValues(alpha: 0.70),
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
          isDark: isDark,
          onSeeAll: articles.isNotEmpty ? () {
            pushScreen(context, CategoryArticlesScreen(title: title, articles: articles));
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
          isDark: isDark,
          onSeeAll: articles.isNotEmpty ? () {
            pushScreen(context, CategoryArticlesScreen(title: title, articles: articles));
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
          isDark: isDark,
          onSeeAll: articles.isNotEmpty ? () {
            pushScreen(context, CategoryArticlesScreen(title: title, articles: articles));
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
    String displayTopic = topic.toTurkishUpperCase();
    if (isEn) {
      if (topic == 'Hayvancılık') displayTopic = 'LIVESTOCK';
      if (topic == 'Bitkisel Üretim') displayTopic = 'CROP PRODUCTION';
      if (topic == 'Ekonomi') displayTopic = 'ECONOMY';
    }

    return _SectionContainer(
      title: displayTopic,
      icon: Icons.category_rounded,
      isDark: isDark,
      onSeeAll: articles.isNotEmpty ? () {
        pushScreen(context, CategoryArticlesScreen(title: displayTopic, articles: articles),
        );
      } : null,
      child: AgendaBentoGrid(articles: articles.take(6).toList(), isDark: isDark),
    );
  }
}

/// Bölüm başlığı artık `core/widgets/section_container.dart` içinde yaşıyor:
/// emtia şeridi bu dosyanın dışında olduğu halde aynı başlığı kullanıyor.
///
/// Bu dosyada 11 kullanım yeri var; hepsini yeniden adlandırmak, taşımanın
/// görsel bir şey değiştirmediğini kanıtlaması gereken farkı okunmaz hale
/// getirirdi. Takma ad o gürültüyü engelliyor.
typedef _SectionContainer = SectionContainer;

// ═══════════════════════════════════════════════════════════════════════════
//  SON OKUDUKLARINIZ BÖLÜMÜ
// ═══════════════════════════════════════════════════════════════════════════

/// Okuyucunun kendi okuma geçmişi — manşetin hemen altında.
///
/// Şikâyet şuydu: "gördüğüm haberi bir daha bulamıyorum." Manşet sıralaması
/// okunmuş haberi bilinçli olarak geriye itiyor (kendini tekrar etmesin diye);
/// bu şerit o haberin sabit bir adresi oluyor. Sıralama algoritmasına
/// dokunmadan şikâyetin en doğrudan cevabı.
///
/// Manşetin ÜSTÜNE değil ALTINA konuyor: ana sayfanın işi önce yeni haberi
/// göstermek. Geçmiş, aranınca bulunan bir şey.
class _RecentlyReadSection extends ConsumerWidget {
  final bool isDark;

  /// Bölümden sonraki boşluk. Bölümün KENDİSİ yayıyor, yerleştiği liste değil:
  /// hiç okunmuş haber yokken (yeni ziyaretçi) geriye tek bir piksel bile
  /// kalmasın, sayfa eskisiyle birebir aynı görünsün diye.
  final double spacing;

  const _RecentlyReadSection({required this.isDark, required this.spacing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final articles = ref.watch(recentlyReadArticlesProvider);
    if (articles.isEmpty) return const SizedBox.shrink();

    final isEn = Localizations.localeOf(context).languageCode == 'en';

    return Column(
      children: [
        _SectionContainer(
          title: isEn ? 'RECENTLY READ' : 'SON OKUDUKLARINIZ',
          icon: Icons.auto_stories_rounded,
          isDark: isDark,
          child: SizedBox(
            // Diğer şeritlerden bilerek alçak. Bu bölüm keşif değil geri dönüş
            // için: kart tanınacak kadar büyük, dikkat çekecek kadar değil.
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: articles.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) => SizedBox(
                width: 260,
                child: _RecentlyReadCard(article: articles[i], isDark: isDark),
              ),
            ),
          ),
        ),
        SizedBox(height: spacing),
      ],
    );
  }
}

class _RecentlyReadCard extends StatelessWidget {
  final NewsArticle article;
  final bool isDark;

  const _RecentlyReadCard({required this.article, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final a = article;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final title =
        (isEn && a.titleEn != null && a.titleEn!.isNotEmpty) ? a.titleEn! : a.title;

    final bgColor = isDark ? AppColors.darkGreen : Colors.white;
    final borderColor = isDark ? AppColors.wheat : const Color(0xFFE5E5E5);
    final titleColor = isDark ? AppColors.creamBackground : AppColors.earthText;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => pushScreen(context, ArticleDetailScreen(article: a)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          // Yatay düzen: okuyucu bu haberi zaten gördü, büyük görsele ihtiyacı
          // yok — küçük bir küçük resim onu hatırlatmaya yetiyor.
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(11)),
                child: SizedBox(
                  width: 80,
                  child: NewsArticleImage(
                    imageUrl: a.imageUrl,
                    fit: BoxFit.cover,
                    semanticLabel: title,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                        height: 1.3,
                      ),
                    ),
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
//  GÖZDEN KAÇANLAR (ICYMI) BÖLÜMÜ
// ═══════════════════════════════════════════════════════════════════════════

class _ICYMISection extends ConsumerWidget {
  final bool isDark;

  const _ICYMISection({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final articles = ref.watch(icymiArticlesProvider);
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final titleText = isEn ? 'IN CASE YOU MISSED IT' : 'GÖZDEN KAÇANLAR';

    if (articles.isEmpty) return const SizedBox.shrink();

    return _SectionContainer(
      title: titleText,
      icon: Icons.history_rounded,
      isDark: isDark,
      child: SizedBox(
        height: 320,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          itemCount: articles.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0.0 : 8.0,
                right: index == articles.length - 1 ? 0.0 : 8.0,
              ),
              child: SizedBox(
                width: 260,
                child: _ICYMICard(article: articles[index], isDark: isDark),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ICYMICard extends StatefulWidget {
  final NewsArticle article;
  final bool isDark;

  const _ICYMICard({
    required this.article,
    required this.isDark,
  });

  @override
  State<_ICYMICard> createState() => _ICYMICardState();
}

class _ICYMICardState extends State<_ICYMICard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final title = (isEn && a.titleEn != null && a.titleEn!.isNotEmpty) ? a.titleEn! : a.title;
    
    final accentCol = AppColors.accentFor(isDark: widget.isDark);
    final titleColor = _hovered
        ? accentCol
        : (widget.isDark ? AppColors.creamBackground : AppColors.earthText);
    final bgColor = widget.isDark ? AppColors.darkGreen : Colors.white;
    final borderColor = widget.isDark ? AppColors.wheat : const Color(0xFFE5E5E5);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => pushScreen(context, ArticleDetailScreen(article: a)),
        child: AnimatedScale(
          scale: _hovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _hovered ? accentCol.withValues(alpha: 0.5) : borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(widget.isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 3 / 2,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                    child: NewsArticleImage(
                      imageUrl: a.imageUrl,
                      fit: BoxFit.cover,
                      semanticLabel: title,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (a.topic != null && a.topic!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              a.topic!.toTurkishUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: AppTypography.minLabelSize,
                                fontWeight: FontWeight.bold,
                                color: accentCol,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: titleColor,
                              height: 1.25,
                            ),
                          ),
                        ),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

