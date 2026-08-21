import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/commodities/presentation/screens/commodity_detail_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/dossiers/presentation/screens/country_dossier_screen.dart';
import '../../features/dossiers/presentation/screens/dossier_index_screen.dart';
import '../../features/home/data/models/news_article.dart';
import '../../features/home/data/models/weather_info.dart';
import '../../features/home/presentation/screens/about_screen.dart';
import '../../features/home/presentation/screens/all_columnists_screen.dart';
import '../../features/home/presentation/screens/article_detail_screen.dart';
import '../../features/home/presentation/screens/author_article_detail_screen.dart';
import '../../features/home/presentation/screens/category_articles_screen.dart';
import '../../features/home/presentation/screens/financial_terminal_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/kisa_kisa_screen.dart';
import '../../features/home/presentation/screens/weather_detail_screen.dart';
import '../../features/home/presentation/screens/weekly_recap_screen.dart';
import '../../features/home/presentation/screens/yyt_dosyasi_screen.dart';
import '../../features/home/presentation/widgets/ai_columnists.dart';
import '../../features/home/providers/home_providers.dart';
import '../utils/iso_week.dart';
import '../../features/legal/data/legal_documents.dart';
import '../../features/legal/presentation/screens/legal_page_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

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
String columnistPath(String slug) => '/yazar/$slug';
String categoryPath(String title) => '/kategori/${Uri.encodeComponent(title)}';

/// Haftalık özet — `/hafta/2026-W33`. Haftalık bildirim de bu adrese iniyor
/// (bkz. `functions/index.js`, `weeklyBriefing`).
String weekPath(IsoWeek week) => '/hafta/${week.slug}';

/// Emtia fiyat detayı — `/emtia/bugday`. Slug veritabanındaki ürün anahtarı.
String commodityPath(String slug) => '/emtia/$slug';

/// Ülke dosyası — `/ulke/hollanda`.
///
/// Adres ASCII: dosya yirmi sekiz gün boyunca paylaşılmak üzere duruyor ve
/// `/ülke/` yazan bir adres mesajlaşma uygulamalarında yüzde kodlamasına
/// dönüşüp okunmaz hâle geliyor (aynı gerekçe [legalPath] için de geçerli).
String countryPath(String slug) => '/ulke/$slug';

/// Ülke dosyaları arşivi.
const String dossierIndexPath = '/ulkeler';

/// Künye, iletişim ve yasal metinlerin adresi. Slug'lar ASCII tutulur —
/// Türkçe karakterli adresler kopyalanıp yapıştırıldığında ve mesajlaşma
/// uygulamalarında yüzde kodlamasına dönüşüp okunmaz hâle geliyor.
String legalPath(String slug) => '/$slug';

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
    return (path: columnistPath(page.columnist.slug), extra: page.columnist);
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
  if (page is WeeklyRecapScreen) {
    return (path: weekPath(page.week), extra: null);
  }
  if (page is CommodityDetailScreen) {
    return (path: commodityPath(page.slug), extra: null);
  }
  if (page is CountryDossierScreen) {
    return (path: countryPath(page.slug), extra: null);
  }
  if (page is DossierIndexScreen) {
    return (path: dossierIndexPath, extra: null);
  }
  if (page is AllColumnistsScreen) return (path: '/yazarlar', extra: null);
  if (page is KisaKisaScreen) return (path: '/kisa-kisa', extra: null);
  if (page is YYTDosyasiScreen) return (path: '/yyt-dosyasi', extra: null);
  if (page is FinancialTerminalScreen) return (path: '/piyasalar', extra: null);
  if (page is AboutScreen) return (path: '/hakkimizda', extra: null);
  if (page is SettingsScreen) return (path: '/ayarlar', extra: null);
  if (page is LegalPageScreen) {
    return (path: legalPath(page.doc.slug), extra: null);
  }
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

AiColumnist? _findColumnist(String slug) {
  for (final c in aiColumnists) {
    if (c.slug == slug) return c;
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
  observers: [
    if (Firebase.apps.isNotEmpty)
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
  ],
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

    // Haftalık özet — kategori listelerinin aksine adresten TAMAMEN yeniden
    // kurulabilir: `2026-W33` haftanın hangi yedi gün olduğunu tek başına
    // söylüyor, ekran veriyi kendi çekiyor. Haftalık bildirim buraya iniyor ve
    // bildirime tıklayan okuyucunun uygulaması kapalı olabilir; önbelleğe bağlı
    // bir rota o durumda ana sayfaya düşerdi.
    GoRoute(
      path: '/hafta/:slug',
      redirect: (context, state) =>
          IsoWeek.parse(state.pathParameters['slug']!) == null ? '/' : null,
      pageBuilder: (context, state) => _fadePage(
        state,
        WeeklyRecapScreen(week: IsoWeek.parse(state.pathParameters['slug']!)!),
      ),
    ),

    // Emtia fiyat detayı. Haftalık özet gibi adresten tamamen yeniden
    // kurulabilir: ekran slug ile kendi verisini çekiyor, önbelleğe bağlı
    // değil. Bilinmeyen slug'da ekranın kendisi "ürün bulunamadı" gösteriyor;
    // burada redirect yok çünkü ürün listesi sunucuda, elde değil.
    GoRoute(
      path: '/emtia/:slug',
      pageBuilder: (context, state) => _fadePage(
        state,
        CommodityDetailScreen(slug: state.pathParameters['slug']!),
      ),
    ),

    // Ülke dosyası. Emtia rotasıyla aynı kurulum ve aynı sebeple: slug tek
    // başına sayfayı yeniden kurmaya yetiyor, ekran veriyi kendi çekiyor.
    // Önbelleğe bağlanamazdı — dosyanın en çok kullanılacak girişi paylaşılan
    // bir bağlantı olacak ve o okuyucu uygulamayı ilk kez açıyor.
    //
    // Bilinmeyen slug'da redirect yok: dosya listesi sunucuda ve ekran
    // "Dosya bulunamadı" durumunu zaten kendi çiziyor. Burada yönlendirme
    // olsaydı yavaş bağlantıda henüz gelmemiş bir dosya "yok" sayılırdı.
    GoRoute(
      path: '/ulke/:slug',
      pageBuilder: (context, state) => _fadePage(
        state,
        CountryDossierScreen(slug: state.pathParameters['slug']!),
      ),
    ),

    // Arşiv. Şeritten düşen dosyaların tek girişi.
    GoRoute(
      path: dossierIndexPath,
      pageBuilder: (context, state) =>
          _fadePage(state, const DossierIndexScreen()),
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
    // Kısa haberlerin günlük bülteni. Adresten tamamen yeniden kurulabiliyor:
    // ekran hiçbir argüman almıyor, listeyi kendi süzüyor.
    GoRoute(
      path: '/kisa-kisa',
      pageBuilder: (context, state) => _fadePage(state, const KisaKisaScreen()),
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

    // Bildirim tercihleri ve dil. Adresten tamamen yeniden kurulabiliyor:
    // ekran hiçbir argüman almıyor, durumu diskten okuyor.
    GoRoute(
      path: '/ayarlar',
      pageBuilder: (context, state) => _fadePage(state, const SettingsScreen()),
    ),

    // Künye, iletişim ve yasal metinler. Rotalar içerik haritasından üretilir;
    // yeni bir belge eklemek için yalnızca `legalDocs`'a kayıt eklemek yeterli.
    // Bu sayfalar adresten tamamen yeniden kurulabildiği için (kategori
    // listelerinin aksine) yenilemede kaybolmaz.
    for (final doc in legalDocs.values)
      GoRoute(
        path: legalPath(doc.slug),
        pageBuilder: (context, state) =>
            _fadePage(state, LegalPageScreen(doc: doc)),
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
