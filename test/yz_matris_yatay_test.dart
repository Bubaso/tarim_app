import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_iskelet.g.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_matris.dart';

// Kullanıcı (19 Kas 2026): masaüstünde ısı haritası yataya uzasın —
// teknolojiler satırda, başlıklar sütunda. Telefonda eski düzen.
Widget _uygulama(double genislik) => MaterialApp(
      locale: const Locale('tr'),
      supportedLocales: const [Locale('tr'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        body: SingleChildScrollView(
          child: Center(child: SizedBox(width: genislik, child: const YzTeknolojiMatrisi())),
        ),
      ),
    );

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  bool yatik(WidgetTester t, String metin) =>
      find.ancestor(of: find.text(metin).first, matching: find.byType(RotatedBox)).evaluate().isNotEmpty;

  testWidgets('masaüstü: teknoloji adları satır başında, yatay kaydırma yok, taşma yok', (t) async {
    t.view.physicalSize = const Size(1280, 900);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(_uygulama(1056));
    await t.pump();
    expect(t.takeException(), isNull);
    final ad = kYzTeknoloji.values.first['tr']!;
    expect(yatik(t, ad), isFalse, reason: 'teknoloji satır başı, döndürülmüş değil');
    final boy = t.getSize(find.byType(YzTeknolojiMatrisi));
    expect(boy.width, lessThanOrEqualTo(1056));
    expect(boy.height, lessThan(600), reason: 'dikeye değil yataya uzuyor');
    expect(find.byWidgetPredicate((w) => w is SingleChildScrollView && w.scrollDirection == Axis.horizontal),
        findsNothing);
  });

  testWidgets('telefon: eski düzen (teknoloji sütun başında, döndürülmüş)', (t) async {
    t.view.physicalSize = const Size(375, 812);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(_uygulama(343));
    await t.pump();
    expect(t.takeException(), isNull);
    expect(yatik(t, kYzTeknoloji.values.first['tr']!), isTrue);
  });
}
