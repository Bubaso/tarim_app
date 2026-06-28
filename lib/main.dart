import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
      title: 'Tarım Portalı',
      debugShowCheckedModeBanner: false,
      
      // Theme definitions — Premium Medya Portalı Tasarım Sistemi
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

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

      home: const HomeScreen(),
    );
  }
}
