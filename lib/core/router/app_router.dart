import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/home/data/models/news_article.dart';
import '../../features/home/data/models/weather_info.dart';
import '../../features/home/presentation/screens/about_screen.dart';
import '../../features/home/presentation/screens/all_columnists_screen.dart';
import '../../features/home/presentation/screens/article_detail_screen.dart';
import '../../features/home/presentation/screens/author_article_detail_screen.dart';
import '../../features/home/presentation/screens/category_articles_screen.dart';
import '../../features/home/presentation/screens/financial_terminal_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/weather_detail_screen.dart';
import '../../features/home/presentation/screens/yyt_dosyasi_screen.dart';
import '../../features/home/presentation/widgets/ai_columnists.dart';
import '../../features/home/providers/home_providers.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  Uygulama yönlendirmesi (Router API)
//
//  Router API kullanıldığında Flutter web motoru "multi-entry" geçmiş moduna
//  geçer: her sayfa geçişi tarayıcı geçmişine GERÇEK bir kayıt ekler.
//  Bunun iki doğrudan sonucu var:
//    1) iOS'ta kenardan sağa kaydırma hareketi bir önceki sayfaya döner,
//       uygulamadan çıkmaz.
//    2) Geri gitmek belge yeniden yüklemesi tetiklemediği için beyaz ekran
//       oluşmaz.
//  (Eski kurulum MaterialApp(home:) + Navigator.push idi; bu, motoru
//  "single-entry" moduna zorlar ve geçmiş yığını hiç büyümez.)
// ═══════════════════════════════════════════════════════════════════════════

String articlePath(String id) => '/haber/$id';
String columnistPath(String name) => '/yazar/${Uri.encodeComponent(name)}';
String categoryPath(String title) => '/kategori/${Uri.encodeComponent(title)}';

/// [CategoryArticlesScreen] için adres dışında taşınan argümanlar.
class CategoryArgs {
  const CategoryArgs(this.title, this.articles);
  final String title;
  final List<NewsArticle> articles;
}

/// Verilen ekran widget'ının router karşılığı. Tanımlı değilse `null`.
({String path, Object? extra})? routeFor(Widget page) {
  if (page is ArticleDetailScreen) {
    return (path: articlePath(page.article.id), extra: page.article);
  }
  if (page is AuthorArticleDetailScreen) {
    return (path: columnistPath(page.columnist.name), extra: page.columnist);
  }
  if (page is CategoryArticlesScreen) {
    return (
      path: categoryPath(page.title),
      extra: CategoryArgs(page.title, page.articles),
    );
  }
  if (page is WeatherDetailScreen) {
    return (path: '/hava-durumu', extra: page.weather);
  }
  if (page is AllColumnistsScreen) return (path: '/yazarlar', extra: null);
  if (page is YYTDosyasiScreen) return (path: '/yyt-dosyasi', extra: null);
  if (page is FinancialTerminalScreen) return (path: '/piyasalar', extra: null);
  if (page is AboutScreen) return (path: '/hakkimizda', extra: null);
  if (page is LoginScreen) return (path: '/giris', extra: null);
  if (page is DashboardScreen) return (path: '/panel', extra: null);
  if (page is HomeScreen) return (path: '/', extra: null);
  return null;
}

// ─── Oturum içi argüman önbelleği ──────────────────────────────────────────
// Tarayıcı geçmişi yalnızca JSON'a çevrilebilen veri saklar; NewsArticle veya
// makale listesi gibi nesneler geri/ileri hareketinde kaybolur. Bu önbellek
// sayesinde aynı oturum içinde geri gidildiğinde sayfa yeniden veri çekmeden
// kurulur. Sekme yenilendiğinde (soğuk açılış) önbellek boştur ve rotalar
// kendi yedek davranışına düşer.
const int _extraCacheLimit = 40;
final Map<String, Object> _extraCache = <String, Object>{};

Object? _resolveExtra(GoRouterState state) {
  final key = state.uri.path;
  final extra = state.extra;
  if (extra != null) {
    if (!_extraCache.containsKey(key) && _extraCache.length >= _extraCacheLimit) {
      _extraCache.remove(_extraCache.keys.first);
    }
    _extraCache[key] = extra;
    return extra;
  }
  return _extraCache[key];
}

AiColumnist? _findColumnist(String rawName) {
  final name = Uri.decodeComponent(rawName);
  for (final c in aiColumnists) {
    if (c.name == name || c.name == rawName) return c;
  }
  return null;
}

CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 100),
    reverseTransitionDuration: const Duration(milliseconds: 100),
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

final appRouter = GoRouter(
  initialLocation: '/',
  onException: (context, state, router) => router.go('/'),
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),

    // Haber detayı — paylaşılabilir kalıcı adres.
    GoRoute(
      path: '/haber/:id',
      pageBuilder: (context, state) {
        final cached = _resolveExtra(state);
        if (cached is NewsArticle) {
          return _fadePage(state, ArticleDetailScreen(article: cached));
        }
        return _fadePage(state, _ArticleLoader(id: state.pathParameters['id']!));
      },
    ),

    // Yazar köşesi — yazar listesi kod içinde sabit, adresten doğrudan çözülür.
    GoRoute(
      path: '/yazar/:name',
      redirect: (context, state) =>
          _findColumnist(state.pathParameters['name']!) == null
              ? '/yazarlar'
              : null,
      pageBuilder: (context, state) => _fadePage(
        state,
        AuthorArticleDetailScreen(
          columnist: _findColumnist(state.pathParameters['name']!)!,
        ),
      ),
    ),

    // Kategori listesi — makale kümesi adresten üretilemez; önbellekte karşılığı
    // yoksa ana sayfaya düşer.
    GoRoute(
      path: '/kategori/:title',
      redirect: (context, state) =>
          _resolveExtra(state) is CategoryArgs ? null : '/',
      pageBuilder: (context, state) {
        final args = _resolveExtra(state)! as CategoryArgs;
        return _fadePage(
          state,
          CategoryArticlesScreen(title: args.title, articles: args.articles),
        );
      },
    ),

    GoRoute(
      path: '/hava-durumu',
      pageBuilder: (context, state) {
        final cached = _resolveExtra(state);
        if (cached is WeatherInfo) {
          return _fadePage(state, WeatherDetailScreen(weather: cached));
        }
        return _fadePage(state, const _WeatherLoader());
      },
    ),

    GoRoute(
      path: '/yazarlar',
      pageBuilder: (context, state) =>
          _fadePage(state, const AllColumnistsScreen()),
    ),
    GoRoute(
      path: '/yyt-dosyasi',
      pageBuilder: (context, state) =>
          _fadePage(state, const YYTDosyasiScreen()),
    ),
    GoRoute(
      path: '/piyasalar',
      pageBuilder: (context, state) =>
          _fadePage(state, const FinancialTerminalScreen()),
    ),
    GoRoute(
      path: '/hakkimizda',
      pageBuilder: (context, state) => _fadePage(state, const AboutScreen()),
    ),
    GoRoute(
      path: '/giris',
      pageBuilder: (context, state) => _fadePage(state, const LoginScreen()),
    ),
    GoRoute(
      path: '/panel',
      redirect: (context, state) =>
          Supabase.instance.client.auth.currentSession == null ? '/giris' : null,
      pageBuilder: (context, state) => _fadePage(state, const DashboardScreen()),
    ),
  ],
);

/// Doğrudan `/haber/:id` adresiyle açıldığında makaleyi kimliğinden çeker.
class _ArticleLoader extends ConsumerWidget {
  const _ArticleLoader({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(articleByIdProvider(id)).when(
          data: (article) => article == null
              ? const _RouteError(message: 'Haber bulunamadı.')
              : ArticleDetailScreen(article: article),
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const _RouteError(message: 'Haber yüklenemedi.'),
        );
  }
}

/// Doğrudan `/hava-durumu` adresiyle açıldığında güncel hava verisini bekler.
class _WeatherLoader extends ConsumerWidget {
  const _WeatherLoader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(weatherProvider).when(
          data: (weather) => WeatherDetailScreen(weather: weather),
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) =>
              const _RouteError(message: 'Hava durumu yüklenemedi.'),
        );
  }
}

class _RouteError extends StatelessWidget {
  const _RouteError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => GoRouter.of(context).go('/'),
              child: const Text('Ana sayfaya dön'),
            ),
          ],
        ),
      ),
    );
  }
}
