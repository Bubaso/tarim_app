import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'core/constants/api_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/localization_helper.dart';
import 'features/home/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase initialization with environment variables or fallback values
  await Supabase.initialize(
    url: ApiConstants.supabaseUrl,
    publishableKey: ApiConstants.supabaseAnonKey,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dynamic locale from Riverpod notifier
    final currentLocale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Gerçek Tarım',
      debugShowCheckedModeBanner: false,
      
      // Theme definitions — Premium Medya Portalı Tasarım Sistemi
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

      // PWA Browser History senkronizasyonu için
      onGenerateRoute: (settings) {
        if (settings.arguments is Widget) {
          final page = settings.arguments as Widget;
          // CupertinoPageRoute / createFadeRoute dönüyoruz ki swipe-back çalışmaya devam etsin
          return CupertinoPageRoute(
            settings: RouteSettings(name: settings.name),
            builder: (context) => page,
          );
        }
        
        // Tanımlanamayan bir rota (örneğin sayfa yenilenmesi) olursa veya / ise anasayfaya at.
        if (settings.name != '/') {
          return CupertinoPageRoute(
            settings: const RouteSettings(name: '/'),
            builder: (context) => const HomeScreen(),
          );
        }
        return null; // let the default fallback handle it
      },

      home: const HomeScreen(),
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
