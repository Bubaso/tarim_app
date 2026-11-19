import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/features/home/presentation/widgets/category_nav_bar.dart';

// Kullanıcı (19 Kas 2026): ana sayfanın başındaki kategori şeridine
// (COP31, Türkiye, Dünya…) Yapay Zeka dosyasının düğmesi; COP31 gibi
// vurgulu, Tarım-Bilim'in sağında.
void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('Tarım-Bilim düğmesinin sağında dolgulu "Yapay Zeka"; basınca bölümün ana sayfası', (t) async {
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
    // Tarım-Bilim'in hemen sağında, Hayvancılık'ın solunda (19 Kas 2026).
    final x = t.getTopLeft(dugme).dx;
    expect(t.getTopLeft(find.text('Tarım-Bilim')).dx, lessThan(x));
    expect(t.getTopLeft(find.text('Hayvancılık')).dx, greaterThan(x));
    // COP31 gibi dolgulu: çelik mavisi zemin, beyaz yazı.
    final zemin = t.widget<Material>(find.ancestor(of: dugme, matching: find.byType(Material)).first);
    expect(zemin.color, const Color(0xFF34507A));
    expect(t.widget<Text>(dugme).style?.color, Colors.white);
    expect(t.getSize(find.byType(CategoryNavBar)).height, 40);
    expect(t.takeException(), isNull);
    await t.tap(dugme);
    await t.pumpAndSettle();
    expect(find.text('MERKEZ'), findsOneWidget);
  });
}
