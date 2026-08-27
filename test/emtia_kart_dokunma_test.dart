import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/features/commodities/data/models/commodity_price.dart';
import 'package:tarim_app/features/commodities/presentation/widgets/commodity_card.dart';

/// Kartta dokunmanın anlamı duruma göre değişiyor; testin tamamı bunu sınıyor.
CommodityPrice _fiyat() => CommodityPrice(
      slug: 'bugday',
      nameTr: 'Buğday',
      nameEn: 'Wheat',
      category: 'hububat',
      unit: 'TL/kg',
      avgPrice: 16.6365,
      minPrice: 13.52,
      maxPrice: 19.48,
      priceDate: DateTime(2026, 8, 24),
      changePct: 0.4,
      source: 'polatli',
      sourceLabel: 'Polatlı Ticaret Borsası',
      sourceScope: 'Polatlı',
      stalenessDays: 0,
    );

Widget _sarmala({
  required bool acik,
  required VoidCallback onTap,
  required VoidCallback onOpenDetail,
}) {
  return MaterialApp(
    locale: const Locale('tr'),
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('tr'), Locale('en')],
    home: Scaffold(
      body: Center(
        // Şeritteki gerçek ölçüler (dar ekran).
        child: SizedBox(
          width: acik ? 268 : 152,
          height: 108,
          child: CommodityCard(
            price: _fiyat(),
            isDark: false,
            isExpanded: acik,
            isCompact: true,
            onTap: onTap,
            onOpenDetail: onOpenDetail,
          ),
        ),
      ),
    ),
  );
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('kapalı kart açılıyor, grafiğe gitmiyor', (tester) async {
    var acildi = 0;
    var grafik = 0;
    await tester.pumpWidget(_sarmala(
      acik: false,
      onTap: () => acildi++,
      onOpenDetail: () => grafik++,
    ));

    await tester.tap(find.byType(CommodityCard));
    await tester.pump();

    expect(acildi, 1);
    expect(grafik, 0);
  });

  testWidgets('açık kartın HER YERİ grafiği açıyor', (tester) async {
    // Eskiden yalnızca sağ alttaki 11 puntoluk "Grafik →" bağlantısı
    // götürüyordu; kartın geri kalanı kapatma tuşuydu. Açık bir kartta
    // okuyucunun dokunmak istediği şey grafiktir.
    var acildi = 0;
    var grafik = 0;
    await tester.pumpWidget(_sarmala(
      acik: true,
      onTap: () => acildi++,
      onOpenDetail: () => grafik++,
    ));

    final kart = tester.getRect(find.byType(CommodityCard));

    // Sol üst (ürün adı), orta (aralık) ve sağ alt ("Grafik →") — üçü de aynı
    // şeyi yapmalı.
    for (final nokta in [
      Offset(kart.left + 20, kart.top + 16),
      kart.center,
      Offset(kart.right - 24, kart.bottom - 14),
    ]) {
      await tester.tapAt(nokta);
      await tester.pump();
    }

    expect(grafik, 3);
    expect(acildi, 0, reason: 'açık kart artık kapanmıyor');
  });
}
