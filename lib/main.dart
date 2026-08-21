import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/constants/api_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/localization_helper.dart';
import 'core/services/notification_service.dart';
import 'core/utils/url_strategy.dart';
import 'features/home/providers/hero_rotation.dart';
import 'features/home/providers/home_providers.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Rotayı adresin `#` sonrasından yola taşır. `runApp`tan ÖNCE çağrılmak
  // zorunda: router başlangıç adresini ilk karede okuyor.
  configureUrlStrategy();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error (might be offline): $e');
  }

  // Bu çağrı olmadan `DateFormat.yMMMd('tr_TR')` sessizce en_US'a düşüyor ve
  // Türkçe arayüzde tarihler "Aug 8, 2026" olarak yazılıyordu.
  await initializeDateFormatting('tr_TR');
  await initializeDateFormatting('en_US');

  try {
    await Supabase.initialize(
      url: ApiConstants.supabaseUrl,
      publishableKey: ApiConstants.supabaseAnonKey,
    );
  } catch (e) {
    debugPrint('Supabase init error (might be offline): $e');
  }

  // Initialize notifications safely in the background
  // We use Future.microtask so it doesn't block runApp in any way.
  Future.microtask(() async {
    try {
      await NotificationService().initialize();
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  });

  // Manşet tohumu `runApp`tan önce okunuyor: ilk kare doğru sırayla çizilsin,
  // liste gözün önünde yeniden dizilmesin.
  final visit = await VisitTracker.beginVisit();

  try {
    // Telefonlarda sadece dikey mod (Portrait), tabletlerde ise hem dikey hem yatay serbest.
    final view = PlatformDispatcher.instance.views.first;
    final physicalSize = view.physicalSize;
    final pixelRatio = view.devicePixelRatio;
    final logicalSize = physicalSize / pixelRatio;
    
    if (logicalSize.shortestSide < 600) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  } catch (e) {
    debugPrint('Orientation setup error: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        heroSeedProvider.overrideWith(() => HeroSeed(visit.seed)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Uygulama öne geldiğinde ziyaretin hâlâ sürüp sürmediğine bakar.
  ///
  /// Ana ekrandan açılan bir PWA arka planda dondurulup geri getiriliyor;
  /// süreç ölmediği için `main` bir daha çalışmıyor. Rotasyonun tek tetikleyicisi
  /// burası: aradan [VisitTracker.visitGap] geçtiyse tohum yenilenir ve okuma
  /// durumu tazelenir — okuyucunun az önce okuduğu haber artık manşetin başında
  /// durmaz.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      // Boşluk, okuyucunun ayrıldığı andan itibaren ölçülmeli.
      VisitTracker.markActive();
      return;
    }

    VisitTracker.beginVisit().then((visit) {
      if (!mounted || !visit.isNewVisit) return;

      // Haber havuzu tek seferlik bir sorguyla dolduruluyor (`asStream`), yani
      // uygulama açık kaldığı sürece yeni yayımlanan haberleri hiç görmüyor.
      // Yeni ziyaret, havuzun yeniden çekilmesi için de doğru an: aradan geçen
      // sürede yayımlananlar sıraya kendi tazelik puanlarıyla giriyor.
      ref.invalidate(latestArticlesProvider);

      ref.read(heroSeedProvider.notifier).rotate(visit.seed);
      // Okunanlar anlık görüntüsü ziyaret başında alınıyor; bu olmadan bugün
      // okunan haber ancak süreç ölünce sıradan düşerdi.
      ref.invalidate(initialReadArticlesProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Tarım Portalı',
      debugShowCheckedModeBanner: false,

      // Ön planda gelen bildirimi gösterebilmek için; NotificationService
      // widget ağacının dışından bu anahtarla SnackBar açıyor.
      scaffoldMessengerKey: appMessengerKey,

      // Router API — her sayfa geçişi tarayıcı geçmişine gerçek bir kayıt
      // ekler. iOS'ta kenardan kaydırarak geri gelme hareketinin uygulamadan
      // çıkmaması ve geri dönüşte beyaz ekran oluşmaması bu moda bağlı.
      routerConfig: appRouter,

      builder: (context, child) {
        return OrientationBuilder(
          builder: (context, orientation) {
            // Telefonlarda (en kısa kenar < 600) yatay moda geçildiğinde uyarı göster
            final isPhone = MediaQuery.of(context).size.shortestSide < 600;
            if (isPhone && orientation == Orientation.landscape) {
              return const Directionality(
                textDirection: TextDirection.ltr,
                child: Scaffold(
                  backgroundColor: Color(0xFFF6F1E7),
                  body: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.screen_rotation, size: 48, color: Color(0xFF3A2E20)),
                          SizedBox(height: 16),
                          Text(
                            'Lütfen telefonunuzu dikey tutunuz.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3A2E20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
            return child ?? const SizedBox.shrink();
          },
        );
      },

      // Theme definitions
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,

      // Masaüstü web için fare ile kaydırmayı aktifleştiren özel ayar
      scrollBehavior: AppScrollBehavior(),

      // Localization Configuration
      locale: currentLocale,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
    );
  }
}

/// Masaüstü tarayıcılarda da (mouse ile) listelerin kaydırılabilmesini sağlayan özel ScrollBehavior
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}
