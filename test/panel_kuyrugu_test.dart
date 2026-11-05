import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tarim_app/features/dashboard/presentation/screens/onay_kuyrugu_ekrani.dart';
import 'package:tarim_app/features/dashboard/presentation/widgets/inceleme_karti.dart';
import 'package:tarim_app/features/home/data/models/news_article.dart';
import 'package:tarim_app/features/home/data/repositories/home_repository.dart';
import 'package:tarim_app/features/home/presentation/widgets/category_nav_bar.dart';
import 'package:tarim_app/features/home/presentation/widgets/dynamic_chart_widget.dart';
import 'package:tarim_app/features/home/providers/home_providers.dart';

// ══════════════════════════════════════════════════════════════════════════
//  3 Kasım denetiminin panel ve okuyucu bulguları.
//
//  En kritik olanı ilk sırada: mükerrer denetimi hatada YEŞİL diyordu, yani
//  moderatör gerçekte yapılmamış bir denetimin onayını alıyordu. Sessiz bir
//  yalan, görünür bir hatadan tehlikeli.
// ══════════════════════════════════════════════════════════════════════════

NewsArticle _haber({
  String id = 'a1',
  String baslik = 'Buğday alım fiyatı açıklandı',
  DateTime? yayin,
  DateTime? giris,
  String? kaynak,
  String? konu,
  int? skor,
}) =>
    NewsArticle(
      id: id,
      title: baslik,
      content: '<p>gövde</p>',
      createdAt: giris ?? DateTime(2026, 11, 5, 9),
      publishedAt: yayin,
      sourceName: kaynak,
      topic: konu,
      heroScore: skor,
      summary: 'özet',
    );

/// `searchArticles`i istenen şekilde davranmaya zorlayan sahte depo.
class _SahteDepo extends HomeRepository {
  // `autoRefreshToken: false` ŞART: `SupabaseClient` kurulurken GoTrue 10
  // saniyelik yinelemeli bir zamanlayıcı başlatıyor ve test, ağaç
  // söküldükten sonra hâlâ bekleyen zamanlayıcı bulunca düşüyor.
  _SahteDepo({this.firlat, this.sonuc = const []})
      : super(SupabaseClient(
          'http://localhost',
          'anon',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        ));

  final Object? firlat;
  final List<NewsArticle> sonuc;

  @override
  Future<List<NewsArticle>> searchArticles(String query) async {
    if (firlat != null) throw firlat!;
    return sonuc;
  }
}

Widget _kartSar(HomeRepository depo, NewsArticle a) => ProviderScope(
      overrides: [homeRepositoryProvider.overrideWithValue(depo)],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: IncelemeKarti(article: a, isDark: false),
          ),
        ),
      ),
    );

Finder _metin(String parca) => find.byWidgetPredicate(
      (w) => w is Text && (w.data ?? '').contains(parca),
    );

void main() {
  group('mükerrer denetimi', () {
    testWidgets('RPC düşerse YEŞİL "bulunamadı" DEMİYOR', (tester) async {
      await tester.pumpWidget(
          _kartSar(_SahteDepo(firlat: Exception('PostgrestException: 500')), _haber()));
      await tester.tap(find.text('Benzer yayınları denetle'));
      await tester.pumpAndSettle();

      // Asıl iddia bu: temiz raporu VERİLMEMELİ.
      expect(_metin('Benzer haber bulunamadı'), findsNothing);
      expect(_metin('Denetim yapılamadı'), findsOneWidget);
      expect(_metin('mükerrer OLABİLİR'), findsOneWidget);
      expect(find.text('Yeniden dene'), findsOneWidget);
    });

    testWidgets('gerçekten temizse YEŞİL diyor', (tester) async {
      await tester.pumpWidget(_kartSar(_SahteDepo(), _haber()));
      await tester.tap(find.text('Benzer yayınları denetle'));
      await tester.pumpAndSettle();

      expect(_metin('Benzer haber bulunamadı'), findsOneWidget);
      expect(_metin('Denetim yapılamadı'), findsNothing);
    });

    testWidgets('benzer bulursa uyarıyor', (tester) async {
      final depo = _SahteDepo(sonuc: [
        _haber(id: 'baska', baslik: 'Buğday alım fiyatı belli oldu'),
      ]);
      await tester.pumpWidget(_kartSar(depo, _haber()));
      await tester.tap(find.text('Benzer yayınları denetle'));
      await tester.pumpAndSettle();

      expect(_metin('Buğday alım fiyatı belli oldu'), findsOneWidget);
      expect(_metin('Benzer haber bulunamadı'), findsNothing);
    });

    testWidgets('haberin KENDİSİ mükerrer sayılmıyor', (tester) async {
      final kendisi = _haber();
      await tester
          .pumpWidget(_kartSar(_SahteDepo(sonuc: [kendisi]), kendisi));
      await tester.tap(find.text('Benzer yayınları denetle'));
      await tester.pumpAndSettle();

      expect(_metin('Benzer haber bulunamadı'), findsOneWidget);
    });

    testWidgets('yeniden deneme başarılı olursa hata temizleniyor',
        (tester) async {
      // Aynı depo iki farklı davranış veremiyor; ikinci turda hatasız bir
      // depoyla yeniden kuruluyor — kullanıcının gördüğü akışın aynısı.
      await tester.pumpWidget(
          _kartSar(_SahteDepo(firlat: Exception('kopuk')), _haber()));
      await tester.tap(find.text('Benzer yayınları denetle'));
      await tester.pumpAndSettle();
      expect(_metin('Denetim yapılamadı'), findsOneWidget);

      await tester.pumpWidget(_kartSar(_SahteDepo(), _haber()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Benzer yayınları denetle'));
      await tester.pumpAndSettle();
      expect(_metin('Denetim yapılamadı'), findsNothing);
      expect(_metin('Benzer haber bulunamadı'), findsOneWidget);
    });
  });

  group('bayatlık', () {
    final bugun = DateTime(2026, 11, 5);

    test('aynı gün yayımlanan 0', () {
      expect(bayatlikGunu(_haber(yayin: DateTime(2026, 11, 5)), simdi: bugun), 0);
    });

    test('üç gün önce yayımlanan 3', () {
      expect(bayatlikGunu(_haber(yayin: DateTime(2026, 11, 2)), simdi: bugun), 3);
    });

    test('tarih yoksa null — "bilinmiyor" sıfır DEĞİL', () {
      expect(bayatlikGunu(_haber(), simdi: bugun), isNull);
    });

    test('gelecek tarihli kayıt eksiye düşmüyor', () {
      // Kaynağın saat dilimi bizden ileriyse olabiliyor.
      expect(bayatlikGunu(_haber(yayin: DateTime(2026, 11, 7)), simdi: bugun), 0);
    });

    test('saat farkı günü kaydırmıyor', () {
      // `published_at` tarih (saat yok) ama `simdi` saatli geliyor; saatli
      // çıkarma "0,96 gün" üretip yanlış yuvarlardı.
      expect(
        bayatlikGunu(_haber(yayin: DateTime(2026, 11, 4)),
            simdi: DateTime(2026, 11, 5, 23, 30)),
        1,
      );
    });
  });

  group('kategori şeridi', () {
    Widget sar(String? aktif) => ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CategoryNavBar(isDark: false, aktifSlug: aktif),
            ),
          ),
        );

    testWidgets('etkin kategori tıklanamıyor, ötekiler tıklanabiliyor',
        (tester) async {
      await tester.pumpWidget(sar('ekonomi'));
      await tester.pumpAndSettle();

      final dugmeler = tester.widgetList<TextButton>(find.byType(TextButton));
      final kapali = dugmeler.where((d) => d.onPressed == null).length;
      // Bulunduğun kategoriye tekrar gitmek aynı sayfayı yığına bindirirdi.
      expect(kapali, 1);
      expect(dugmeler.length, greaterThan(1));
    });

    testWidgets('etkin yokken hepsi tıklanabilir', (tester) async {
      await tester.pumpWidget(sar(null));
      await tester.pumpAndSettle();
      final dugmeler = tester.widgetList<TextButton>(find.byType(TextButton));
      expect(dugmeler.where((d) => d.onPressed == null), isEmpty);
    });

    testWidgets('etkin öğenin altı çiziliyor — renk TEK BAŞINA yetmez',
        (tester) async {
      tester.view.physicalSize = const Size(1400, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(sar('ekonomi'));
      await tester.pumpAndSettle();

      // Şeritteki altı çizgilerinden TAM BİRİ genişlik almalı: rengi tek
      // başına ayırt edici saymak renk körü okuru dışarıda bırakırdı.
      final genisler = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) {
        final k = c.constraints;
        return k != null &&
            k.maxHeight == 2 &&
            k.minHeight == 2 &&
            k.maxWidth > 0;
      });
      expect(genisler.length, 1);
    });
  });

  group('tablo panoya alınabiliyor', () {
    const tablo = {
      'type': 'table',
      'title': 'Hal fiyatları',
      'data': [
        {'Ürün': 'Domates', 'Fiyat': '45.000'},
        {'Ürün': 'Salatalık', 'Fiyat': '12.500', 'Not': 'tahmin'},
      ],
    };

    testWidgets('kopyalanan metin TSV ve bütün sütunları taşıyor',
        (tester) async {
      String? panoya;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            panoya = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(() => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null));

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 1000,
              child: DynamicChartWidget(
                chartData: tablo,
                isDark: false,
                accent: Color(0xFF5C8A4A),
                isEn: false,
              ),
            ),
          ),
        ),
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.copy_all_outlined));
      await tester.pump();
      // Düğme iki saniye onay işareti gösteriyor; o zamanlayıcı bitmeden
      // test kapanırsa "bekleyen zamanlayıcı" hatası veriyor.
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      expect(panoya, isNotNull);
      final satirlar = panoya!.split('\n');
      // Başlık satırı + iki veri satırı.
      expect(satirlar.length, 3);
      // İkinci satırda olan 'Not' sütunu da başlıkta OLMALI (sütun birleşimi).
      expect(satirlar.first, 'Ürün\tFiyat\tNot');
      expect(satirlar[1], 'Domates\t45.000\t');
      expect(satirlar[2], 'Salatalık\t12.500\ttahmin');
    });

    testWidgets('tablo olmayan grafikte kopyalama düğmesi YOK',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1000,
            child: DynamicChartWidget(
              chartData: {
                'type': 'bar',
                'title': 'Fiyat',
                'data': [
                  {'label': 'Domates', 'value': 45000},
                ],
              },
              isDark: false,
              accent: Color(0xFF5C8A4A),
              isEn: false,
            ),
          ),
        ),
      ));
      await tester.pump();
      expect(find.byIcon(Icons.copy_all_outlined), findsNothing);
    });
  });
}
