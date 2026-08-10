import 'dart:ui';
import 'package:flutter/material.dart';
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
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Bu çağrı olmadan `DateFormat.yMMMd('tr_TR')` sessizce en_US'a düşüyor ve
  // Türkçe arayüzde tarihler "Aug 8, 2026" olarak yazılıyordu.
  await initializeDateFormatting('tr_TR');
  await initializeDateFormatting('en_US');

  await Supabase.initialize(
    url: ApiConstants.supabaseUrl,
    publishableKey: ApiConstants.supabaseAnonKey,
  );

  // Initialize notifications safely in the background
  // We use Future.microtask so it doesn't block runApp in any way.
  Future.microtask(() async {
    try {
      await NotificationService().initialize();
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  });

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

    return MaterialApp.router(
      title: 'Tarım Portalı',
      debugShowCheckedModeBanner: false,

      // Router API — her sayfa geçişi tarayıcı geçmişine gerçek bir kayıt
      // ekler. iOS'ta kenardan kaydırarak geri gelme hareketinin uygulamadan
      // çıkmaması ve geri dönüşte beyaz ekran oluşmaması bu moda bağlı.
      routerConfig: appRouter,

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
