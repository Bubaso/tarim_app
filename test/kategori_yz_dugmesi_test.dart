import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/features/home/presentation/widgets/category_nav_bar.dart';

// Kullanıcı (19 Kas 2026): ana sayfanın başındaki kategori şeridine
// (COP31, Türkiye, Dünya…) Yapay Zeka dosyasının düğmesi, en sona.
void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('şeridin sonunda "Yapay Zeka"; basınca bölümün ana sayfası', (t) async {
    t.view.physicalSize = const Size(2400, 900);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final r = GoRouter(routes: [
      GoRoute(path: '/', builder: (c, s) => const Scaffold(body: CategoryNavBar(isDark: false))),
      GoRoute(path: '/yapay-zeka-dijital-tarim', builder: (c, s) => const Scaffold(body: Text('MERKEZ'))),
    ]);
    await t.pumpWidget(ProviderScope(
      child: MaterialApp.router(
        routerConfig: r,
        locale: const Locale('tr'),
        supportedLocales: const [Locale('tr'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    ));
    await t.pumpAndSettle();
    final dugme = find.text('Yapay Zeka');
    expect(dugme, findsOneWidget);
    // En sonda: öbür bütün öğelerin sağında.
    final x = t.getTopLeft(dugme).dx;
    for (final e in find.byType(Text).evaluate()) {
      final w = e.widget as Text;
      if (w.data == 'Yapay Zeka' || w.data == null) continue;
      expect(t.getTopLeft(find.byWidget(w)).dx, lessThan(x), reason: '${w.data} solda olmalı');
    }
    expect(t.getSize(find.byType(CategoryNavBar)).height, 40);
    expect(t.takeException(), isNull);
    await t.tap(dugme);
    await t.pumpAndSettle();
    expect(find.text('MERKEZ'), findsOneWidget);
  });
}
