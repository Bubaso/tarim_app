import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/features/commodities/data/models/commodity_price.dart';
import 'package:tarim_app/features/commodities/presentation/widgets/commodity_card.dart';

/// Kart yüksekliği 108/128'den 88/102'ye indirildi (bkz. commodity_strip.dart)
/// çünkü `spaceBetween` içerik ihtiyacından fazla boşluk bırakıyordu. Bu test
/// o indirimin GERÇEKTEN taşmadığını, en kötü senaryoyla doğruluyor: uzun bir
/// kaynak etiketi (TOBB) + aralık bloğu + genişlemiş kart — `_Details`in en
/// çok yer istediği kombinasyon.
CommodityPrice _fiyat({bool aralikli = true, String? kaynak}) => CommodityPrice(
      slug: 'nohut',
      nameTr: 'Nohut',
      nameEn: 'Chickpeas',
      category: 'bakliyat',
      unit: 'TL/kg',
      avgPrice: 36.5892,
      minPrice: aralikli ? 29.25 : null,
      maxPrice: aralikli ? 45.00 : null,
      priceDate: DateTime(2026, 8, 29),
      changePct: -1.8,
      source: 'tobb',
      sourceLabel: kaynak ?? 'TOBB — Türkiye Odalar ve Borsalar Birliği',
      sourceScope: 'Türkiye',
      stalenessDays: 0,
    );

Widget _sarmala({
  required CommodityPrice fiyat,
  required bool genis,
  required double stripYuksekligi,
  required Locale locale,
}) {
  final acikGenislik = genis ? 330.0 : 268.0;
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('tr'), Locale('en')],
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: acikGenislik,
          height: stripYuksekligi,
          child: CommodityCard(
            price: fiyat,
            isDark: false,
            isExpanded: true,
            isCompact: !genis,
            onTap: () {},
            onOpenDetail: () {},
          ),
        ),
      ),
    ),
  );
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('dar ekran (100px) — uzun kaynak adı + aralık, taşmıyor',
      (tester) async {
    await tester.pumpWidget(_sarmala(
      fiyat: _fiyat(),
      genis: false,
      stripYuksekligi: 100,
      locale: const Locale('tr'),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('geniş ekran (104px) — uzun kaynak adı + aralık, taşmıyor',
      (tester) async {
    await tester.pumpWidget(_sarmala(
      fiyat: _fiyat(),
      genis: true,
      stripYuksekligi: 104,
      locale: const Locale('tr'),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('İngilizce dilinde de taşmıyor', (tester) async {
    await tester.pumpWidget(_sarmala(
      fiyat: _fiyat(),
      genis: false,
      stripYuksekligi: 100,
      locale: const Locale('en'),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('ilan fiyatı (aralıksız, tek satır kaynak) taşmıyor',
      (tester) async {
    await tester.pumpWidget(_sarmala(
      fiyat: _fiyat(aralikli: false, kaynak: 'Ulusal Süt Konseyi'),
      genis: false,
      stripYuksekligi: 100,
      locale: const Locale('tr'),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
