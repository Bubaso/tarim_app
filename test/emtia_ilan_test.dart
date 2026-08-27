import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/features/commodities/data/models/commodity_price.dart';
import 'package:tarim_app/features/commodities/presentation/screens/commodity_detail_screen.dart';
import 'package:tarim_app/features/commodities/providers/commodity_providers.dart';

/// 21.08.2026 tarihli gerçek Türkşeker duyurusu.
///
/// Dizinin en zor örneği ve testin tamamı onun üzerine kurulu: başlığı 17.07
/// ilanıyla birebir aynı ("İNDİRİMLİ VADELİ ŞEKER SATIŞI") ama içeriği
/// bambaşka — beş fabrika, bir haftalık süre ve tonaja/ödeme biçimine göre
/// DÖRT ayrı fiyat. Kartta bunlardan yalnızca biri görünüyor; testin işi geri
/// kalanının okuyucudan saklanmadığını sınamak.
CommodityNotice _ilan({DateTime? bitis}) => CommodityNotice(
      titleTr: 'İNDİRİMLİ VADELİ ŞEKER SATIŞI',
      titleEn: 'DISCOUNTED DEFERRED SUGAR SALE',
      summaryTr: '28 Ağustos 2026 tarihine kadar beş fabrikadan indirimli satış.',
      scopeTr: 'Burdur, Ereğli, Ilgın, Kastamonu ve Yozgat',
      scopeEn: 'Burdur, Ereğli, Ilgın, Kastamonu and Yozgat',
      nationwide: false,
      termsTr: '5.000 ton ve üzeri, peşin',
      termsEn: '5,000 tonnes and above, cash payment',
      published: DateTime(2026, 8, 21),
      effective: DateTime(2026, 8, 21),
      validUntil: bitis ?? DateTime(2026, 8, 28),
      prices: const [
        CommodityNoticePrice(
          price: 37.6238,
          labelTr: '5.000 ton ve üzeri, peşin',
          labelEn: '5,000 tonnes and above, cash payment',
        ),
        CommodityNoticePrice(price: 38.6139, labelTr: '0 - 5.000 tona kadar, peşin'),
        CommodityNoticePrice(price: 42.3269, labelTr: '5.000 ton ve üzeri, 3 eşit taksit ödemeli'),
        CommodityNoticePrice(price: 43.4159, labelTr: '0 - 5.000 tona kadar, 3 eşit taksit ödemeli'),
      ],
      pdfUrl: 'https://www.turkseker.gov.tr/data/ihaleler/Duyurular_ILAN_2026_08_21.pdf',
    );

CommodityPrice _seker({CommodityNotice? ilan}) => CommodityPrice(
      slug: 'kristal-seker',
      nameTr: 'Kristal Şeker',
      nameEn: 'Crystal Sugar',
      category: 'seker',
      unit: 'TL/kg',
      avgPrice: 37.6238,
      minPrice: 37.6238,
      maxPrice: 43.4159,
      priceDate: DateTime(2026, 8, 21),
      changePct: -10.42,
      source: 'turkseker',
      sourceLabel: 'Türkiye Şeker Fabrikaları',
      sourceUrl: 'https://www.turkseker.gov.tr/?ModulID=9&MenuID=52',
      sourceScope: 'Türkiye',
      stalenessDays: 3,
      priceKind: 'administered',
      notice: ilan ?? _ilan(),
    );

CommodityPrice _bugday() => CommodityPrice(
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

List<CommodityPricePoint> _gecmis() => [
      CommodityPricePoint(date: DateTime(2026, 7, 4), avgPrice: 40.0),
      CommodityPricePoint(
        date: DateTime(2026, 7, 20),
        avgPrice: 38.6139,
        notice: const CommodityNotice(
          titleTr: 'İNDİRİMLİ VADELİ ŞEKER SATIŞI',
          scopeTr: 'Ankara, Burdur, Elazığ ve diğerleri',
          nationwide: false,
          termsTr: '50.001 ton ve üzeri, 60 gün vadeli',
        ),
      ),
      CommodityPricePoint(date: DateTime(2026, 7, 27), avgPrice: 42.0),
      CommodityPricePoint(date: DateTime(2026, 8, 21), avgPrice: 37.6238),
    ];

Widget _sarmala(
  CommodityPrice fiyat, {
  bool isEn = false,
  List<CommodityPricePoint>? gecmis,
  Size boyut = const Size(390, 900),
}) {
  return ProviderScope(
    overrides: [
      latestCommodityPricesProvider.overrideWith((ref) async => [fiyat]),
      commodityHistoryProvider.overrideWith((ref, slug) async => gecmis ?? _gecmis()),
    ],
    child: MaterialApp(
      locale: Locale(isEn ? 'en' : 'tr'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr'), Locale('en')],
      home: MediaQuery(
        data: MediaQueryData(size: boyut),
        child: CommodityDetailScreen(slug: fiyat.slug),
      ),
    ),
  );
}

/// Sayfayı kurar ve sağlayıcıların çözülmesini bekler.
///
/// Görüş alanı bilerek uzun: sayfa `ListView` ve tembel kuruluyor, 900 px'lik
/// bir ekranda duyuru bölümü hiç inşa edilmiyor — test "bulunamadı" der ve
/// aslında bakmamış olur.
Future<void> _kur(
  WidgetTester tester,
  CommodityPrice fiyat, {
  bool isEn = false,
  List<CommodityPricePoint>? gecmis,
  double genislik = 390,
}) async {
  tester.view.physicalSize = Size(genislik, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    _sarmala(fiyat, isEn: isEn, gecmis: gecmis, boyut: Size(genislik, 2600)),
  );
  await tester.pump();
  await tester.pump();
}

/// Metni parçalanmış Text widget'larında da bulur.
Finder _iceren(String parca) => find.byWidgetPredicate((w) {
      if (w is Text) return (w.data ?? '').contains(parca);
      if (w is SelectableText) return (w.data ?? '').contains(parca);
      return false;
    });

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  group('ilan fiyatı kartta', () {
    testWidgets('en düşük fiyat duyuruda yazdığı gibi, dört haneyle', (tester) async {
      // Kartın "37,62" göstermesi teknik olarak doğru ama pratikte yanlış:
      // okuyucu belgeyi açtığında 37,6238 görüyor ve iki rakamın aynı şey
      // olduğuna karar vermek zorunda kalıyor.
      await _kur(tester, _seker());

      expect(_iceren('37,6238'), findsWidgets);
      expect(_iceren('37,62 '), findsNothing);
    });

    testWidgets('rakamın şartı, kapsamı ve süresi manşetin altında', (tester) async {
      await _kur(tester, _seker());

      // Üçü birden olmadan 37,6238 "şekerin fiyatı" gibi okunur.
      expect(_iceren('5.000 ton ve üzeri, peşin'), findsWidgets);
      expect(_iceren('Burdur, Ereğli, Ilgın, Kastamonu ve Yozgat'), findsWidgets);
      expect(_iceren('28 Ağustos 2026'), findsWidgets);
    });

    testWidgets('ilandaki diğer kademeler de listeleniyor', (tester) async {
      await _kur(tester, _seker());

      expect(_iceren('BU İLANDAKİ FİYATLAR'), findsOneWidget);
      for (final fiyat in ['37,6238', '38,6139', '42,3269', '43,4159']) {
        expect(_iceren(fiyat), findsWidgets, reason: '$fiyat listede yok');
      }
    });

    testWidgets('duyurunun aslına bağlantı var, tıpkıbasımı yok', (tester) async {
      // Belgenin tam metni bir dönem kartın içindeydi; çıkarıldı. Sayfada
      // kalan bizim yorumumuz (şart, kapsam, kademeler); belgenin kendisi bir
      // tık ötede. Bağlantının kaybolmadığını sınamak bu testin asıl işi —
      // yorum tek başına kalırsa denetlenemez hale gelir.
      await _kur(tester, _seker());

      expect(_iceren('Duyurunun aslını Türkşeker sitesinde açın'), findsOneWidget);
      expect(_iceren('DUYURUNUN ASLI'), findsNothing);
      expect(_iceren('mesai bitimine kadar'), findsNothing);
    });

    testWidgets('süresi dolmuş kampanya söyleniyor', (tester) async {
      // Hat kampanya bitiminde fiyatı kendiliğinden geri alıyor; ama hattın
      // çalışmadığı bir gün (24.08.2026'da ağ yüzünden çalışmadı) kart süresi
      // geçmiş bir rakamı güncel gibi gösterirdi.
      await _kur(tester, _seker(ilan: _ilan(bitis: DateTime(2020, 1, 1))));

      expect(_iceren('süresi doldu'), findsOneWidget);
    });
  });

  group('EN dilinde', () {
    testWidgets('ilan verisi de İngilizce geliyor', (tester) async {
      // Arayüz metinleri baştan iki dilliydi ama duyurudan gelen ALANLAR
      // (şart, kapsam, kademe etiketleri) Türkçe kalıyordu: İngilizce sayfada
      // "5.000 ton ve üzeri, peşin" yazıyordu. Duyuru Türkçe yayımlanıyor;
      // İngilizcesi okuma sırasında aynı geçişte üretiliyor.
      await _kur(tester, _seker(), isEn: true);

      expect(_iceren('5,000 tonnes and above, cash payment'), findsWidgets);
      expect(_iceren('Kastamonu and Yozgat'), findsWidgets);
      expect(_iceren('5.000 ton ve üzeri, peşin'), findsNothing);
    });

    testWidgets('İngilizcesi olmayan alan Türkçesine düşüyor', (tester) async {
      // Fabrika adlarından oluşan bir kapsam iki dilde de aynı; eksik alan
      // yüzünden satırı boş bırakmak bilgi kaybı olurdu.
      await _kur(tester, _seker(), isEn: true);

      expect(_iceren('0 - 5.000 tona kadar, peşin'), findsWidgets);
    });
  });

  group('borsa fiyatında', () {
    testWidgets('ilan bölümleri hiç çıkmıyor', (tester) async {
      // Buğdayın arkasında okunacak bir belge yok; boş başlık bırakmak
      // eksik veri izlenimi verirdi.
      await _kur(tester, _bugday(), gecmis: const []);

      expect(_iceren('BU İLANDAKİ FİYATLAR'), findsNothing);
      expect(_iceren('Duyurunun aslını'), findsNothing);
      // Borsada gün içi aralık yerini koruyor.
      expect(_iceren('Gün içi aralık'), findsOneWidget);
    });
  });

  group('taşma', () {
    for (final genislik in [360.0, 768.0, 1200.0]) {
      for (final isEn in [false, true]) {
        testWidgets('${genislik.toInt()} px · ${isEn ? 'en' : 'tr'}', (tester) async {
          await _kur(tester, _seker(), isEn: isEn, genislik: genislik);

          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}
