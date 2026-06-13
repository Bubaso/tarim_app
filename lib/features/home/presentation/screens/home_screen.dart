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
import '../../providers/home_providers.dart';
import '../widgets/market_widget.dart';
import '../widgets/news_card.dart';
import '../widgets/weather_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);
    final user = ref.watch(currentUserProvider);
    final isDark = theme.brightness == Brightness.dark;
    
    // Listen to realtime articles stream
    final newsAsyncValue = ref.watch(latestArticlesProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C1015) : const Color(0xFFFAF5EF),
      drawer: ResponsiveBreakpoints.isMobileOrTablet(context)
          ? _buildDrawer(context, ref, theme, localizations, user)
          : null,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0C1015) : const Color(0xFFFAF5EF),
        leading: ResponsiveBreakpoints.isMobileOrTablet(context)
            ? Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                ),
              )
            : null,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.eco_rounded, 
              color: isDark ? const Color(0xFF00E676) : theme.colorScheme.primary, 
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(
              localizations.translate('app_title').toUpperCase(),
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                color: isDark ? const Color(0xFFECEFF1) : theme.colorScheme.primary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          // Dynamic Language Selection Button
          TextButton.icon(
            onPressed: () {
              ref.read(localeProvider.notifier).toggleLocale();
            },
            icon: Icon(
              Icons.language_rounded,
              color: isDark ? const Color(0xFF00E676) : theme.colorScheme.primary,
            ),
            label: Text(
              currentLocale.languageCode.toUpperCase(),
              style: GoogleFonts.robotoMono(
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFFECEFF1) : theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: _buildMobileLayout(context, ref, newsAsyncValue),
          tablet: _buildTabletLayout(context, ref, newsAsyncValue),
          desktop: _buildDesktopLayout(context, ref, newsAsyncValue),
          largeScreen: _buildLargeScreenLayout(context, ref, newsAsyncValue),
        ),
      ),
    );
  }

  // Mobile Layout: 1 Column News list
  Widget _buildMobileLayout(BuildContext context, WidgetRef ref, AsyncValue newsAsyncValue) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(latestArticlesProvider),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const WeatherWidget(),
          const SizedBox(height: 16),
          const MarketWidget(),
          const SizedBox(height: 28),
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                color: isDark ? const Color(0xFF00E676) : theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                localizations.translate('news_feed').toUpperCase(),
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 0.8,
                  color: isDark ? const Color(0xFFECEFF1) : theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNewsList(newsAsyncValue, crossAxisCount: 1),
        ],
      ),
    );
  }

  // Tablet Layout: 2 Columns Grid News list
  Widget _buildTabletLayout(BuildContext context, WidgetRef ref, AsyncValue newsAsyncValue) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(latestArticlesProvider),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(child: WeatherWidget()),
              const SizedBox(width: 20),
              const Expanded(child: MarketWidget()),
            ],
          ),
          const SizedBox(height: 36),
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                color: isDark ? const Color(0xFF00E676) : theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                localizations.translate('news_feed').toUpperCase(),
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  letterSpacing: 0.8,
                  color: isDark ? const Color(0xFFECEFF1) : theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildNewsList(newsAsyncValue, crossAxisCount: 2),
        ],
      ),
    );
  }

  // Desktop Layout: Left rail, 3 Columns News Grid, Right Widgets
  Widget _buildDesktopLayout(BuildContext context, WidgetRef ref, AsyncValue newsAsyncValue) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1400),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Navigation Menu Mock
            Container(
              width: 220,
              padding: const EdgeInsets.only(right: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNavItem(context, Icons.newspaper_rounded, localizations.translate('news_feed'), true),
                  _buildNavItem(context, Icons.show_chart_rounded, localizations.translate('market_status'), false),
                  _buildNavItem(context, Icons.wb_sunny_rounded, localizations.translate('weather_forecast'), false),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(height: 1),
                  ),
                  if (user == null)
                    _buildNavItem(
                      context,
                      Icons.login_rounded,
                      'Yazar Girişi',
                      false,
                      color: isDark ? const Color(0xFF00E676) : theme.colorScheme.primary,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                    )
                  else ...[
                    _buildNavItem(
                      context,
                      Icons.admin_panel_settings_rounded,
                      'Yönetim Paneli',
                      false,
                      color: isDark ? const Color(0xFF00E676) : theme.colorScheme.primary,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const DashboardScreen()),
                        );
                      },
                    ),
                    _buildNavItem(
                      context,
                      Icons.logout_rounded,
                      'Çıkış Yap',
                      false,
                      color: Colors.redAccent,
                      onTap: () async {
                        await ref.read(supabaseClientProvider).auth.signOut();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Başarıyla çıkış yapıldı.'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
            // Center News Feed (3 Columns Grid)
            Expanded(
              flex: 4,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 22,
                                color: isDark ? const Color(0xFF00E676) : theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                localizations.translate('news_feed').toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  letterSpacing: 0.8,
                                  color: isDark ? const Color(0xFFECEFF1) : theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () => ref.invalidate(latestArticlesProvider),
                            icon: const Icon(Icons.refresh_rounded),
                            tooltip: 'Refresh',
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildSliverNewsList(newsAsyncValue, crossAxisCount: 3),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Right Side Utilities
            const Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    WeatherWidget(),
                    SizedBox(height: 20),
                    MarketWidget(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Large Screen / TV Layout: Constrained width, 4 Columns News Grid, Right Sidebar
  Widget _buildLargeScreenLayout(BuildContext context, WidgetRef ref, AsyncValue newsAsyncValue) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1600),
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Side Menu
            Container(
              width: 260,
              padding: const EdgeInsets.only(right: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNavItem(context, Icons.newspaper_rounded, localizations.translate('news_feed'), true, large: true),
                  _buildNavItem(context, Icons.show_chart_rounded, localizations.translate('market_status'), false, large: true),
                  _buildNavItem(context, Icons.wb_sunny_rounded, localizations.translate('weather_forecast'), false, large: true),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Divider(height: 1),
                  ),
                  if (user == null)
                    _buildNavItem(
                      context,
                      Icons.login_rounded,
                      'Yazar Girişi',
                      false,
                      large: true,
                      color: isDark ? const Color(0xFF00E676) : theme.colorScheme.primary,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                    )
                  else ...[
                    _buildNavItem(
                      context,
                      Icons.admin_panel_settings_rounded,
                      'Yönetim Paneli',
                      false,
                      large: true,
                      color: isDark ? const Color(0xFF00E676) : theme.colorScheme.primary,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const DashboardScreen()),
                        );
                      },
                    ),
                    _buildNavItem(
                      context,
                      Icons.logout_rounded,
                      'Çıkış Yap',
                      false,
                      large: true,
                      color: Colors.redAccent,
                      onTap: () async {
                        await ref.read(supabaseClientProvider).auth.signOut();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Başarıyla çıkış yapıldı.'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
            // Center content (4 Columns Grid)
            Expanded(
              flex: 5,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 26,
                                color: isDark ? const Color(0xFF00E676) : theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                localizations.translate('news_feed').toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                  letterSpacing: 0.8,
                                  color: isDark ? const Color(0xFFECEFF1) : theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () => ref.invalidate(latestArticlesProvider),
                            icon: const Icon(Icons.refresh_rounded, size: 28),
                            tooltip: 'Refresh',
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildSliverNewsList(newsAsyncValue, crossAxisCount: 4),
                ],
              ),
            ),
            const SizedBox(width: 32),
            // Right Sidebar
            const Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    WeatherWidget(),
                    SizedBox(height: 24),
                    MarketWidget(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String title,
    bool isActive, {
    bool large = false,
    Color? color,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeColor = color ?? (isDark ? const Color(0xFF00E676) : theme.colorScheme.primary);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: large ? 14 : 10),
          decoration: BoxDecoration(
            color: isActive 
                ? (isDark ? const Color(0xFF1E2631) : const Color(0xFFEBE3D5)) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: isActive ? Border(
              left: BorderSide(
                color: activeColor,
                width: 3.5,
              )
            ) : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive 
                    ? activeColor
                    : (color ?? theme.hintColor),
                size: large ? 24 : 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                    color: isActive 
                        ? (isDark ? Colors.white : activeColor) 
                        : (color ?? theme.textTheme.bodyLarge?.color),
                    fontSize: large ? 16 : 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations localizations,
    User? user,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF0C1015) : const Color(0xFFFAF5EF),
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF121820) : const Color(0xFFFAF5EF),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF1E2631) : const Color(0xFFEBE3D5),
                  width: 1,
                ),
              ),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.eco_rounded, 
                    color: isDark ? const Color(0xFF00E676) : theme.colorScheme.primary, 
                    size: 32,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    localizations.translate('app_title').toUpperCase(),
                    style: GoogleFonts.playfairDisplay(
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : theme.colorScheme.primary,
                      fontSize: 18,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.newspaper_rounded),
            title: Text(
              localizations.translate('news_feed'),
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          const Divider(),
          const Spacer(),
          if (user == null)
            ListTile(
              leading: Icon(
                Icons.login_rounded, 
                color: isDark ? const Color(0xFF00E676) : theme.colorScheme.primary,
              ),
              title: Text(
                'Yazar Girişi',
                style: GoogleFonts.inter(
                  color: isDark ? const Color(0xFF00E676) : theme.colorScheme.primary, 
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            )
          else ...[
            ListTile(
              leading: Icon(
                Icons.admin_panel_settings_rounded, 
                color: isDark ? const Color(0xFF00E676) : theme.colorScheme.primary,
              ),
              title: Text(
                'Yönetim Paneli',
                style: GoogleFonts.inter(
                  color: isDark ? const Color(0xFF00E676) : theme.colorScheme.primary, 
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const DashboardScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: Text(
                'Çıkış Yap',
                style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                await ref.read(supabaseClientProvider).auth.signOut();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Başarıyla çıkış yapıldı.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNewsList(AsyncValue newsAsyncValue, {required int crossAxisCount}) {
    if (crossAxisCount == 1) {
      return newsAsyncValue.when(
        data: (news) => ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: news.length,
          itemBuilder: (context, index) {
            return NewsCard(article: news[index]);
          },
        ),
        loading: () => const Center(child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        )),
        error: (error, stackTrace) => Center(child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text('Hata: $error'),
        )),
      );
    }

    final double aspectRatio = crossAxisCount == 4
        ? 0.48
        : (crossAxisCount == 3 ? 0.52 : (crossAxisCount == 2 ? 0.60 : 0.85));

    return newsAsyncValue.when(
      data: (news) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: aspectRatio,
        ),
        itemCount: news.length,
        itemBuilder: (context, index) {
          return NewsCard(article: news[index]);
        },
      ),
      loading: () => const Center(child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      )),
      error: (error, stackTrace) => Center(child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text('Hata: $error'),
      )),
    );
  }

  Widget _buildSliverNewsList(AsyncValue newsAsyncValue, {required int crossAxisCount}) {
    final double aspectRatio = crossAxisCount == 4
        ? 0.48
        : (crossAxisCount == 3 ? 0.52 : (crossAxisCount == 2 ? 0.60 : 0.85));

    return newsAsyncValue.when(
      data: (news) => SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: aspectRatio,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return NewsCard(article: news[index]);
          },
          childCount: news.length,
        ),
      ),
      loading: () => const SliverToBoxAdapter(
        child: Center(child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        )),
      ),
      error: (error, stackTrace) => SliverToBoxAdapter(
        child: Center(child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text('Hata: $error'),
        )),
      ),
    );
  }
}
