import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/api_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/localization_helper.dart';
import 'features/home/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    final currentLocale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Tarım Portalı',
      debugShowCheckedModeBanner: false,

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

      // Ana sayfa: HomeScreen doğrudan verilir.
      // Tüm geçişler Navigator.push ile yönetilir — tarayıcı
      // history API'siyle otomatik entegre olur.
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
