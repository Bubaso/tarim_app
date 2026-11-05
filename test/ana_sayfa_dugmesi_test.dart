import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tarim_app/core/router/gezinti_derinligi.dart';
import 'package:tarim_app/core/widgets/ana_sayfa_dugmesi.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Ana sayfa düğmesi — 2. basamaktan itibaren geri tuşunun yanında.
//
//  Sınamanın asıl işi EŞİĞİN ALTINI korumak: düğme yoksa hiçbir ekranın
//  yerleşimi bir piksel oynamamalı. Bu alan daha önce bir kez bozuldu
//  (AppBar leading/leadingWidth), o yüzden "görünmüyor" durumu da en az
//  "görünüyor" durumu kadar sınanıyor.
// ══════════════════════════════════════════════════════════════════════════

/// Her basamağı AppBar'lı bir sayfa olan sınama yönlendiricisi.
GoRouter _yonlendirici() => GoRouter(
      initialLocation: '/',
      observers: [GezintiDerinligi()],
      routes: [
        for (final yol in ['/', '/bir', '/iki', '/uc'])
          GoRoute(
            path: yol,
            builder: (context, state) => Scaffold(
              appBar: AppBar(
                leadingWidth: anaSayfaLeadingGenisligi(context),
                leading: anaSayfaliLeading(context, renk: Colors.black),
                title: Text('sayfa $yol'),
              ),
              body: Text('derinlik: ${gezintiDerinligi(context)}'),
            ),
          ),
      ],
    );

Future<GoRouter> _kur(WidgetTester tester) async {
  GezintiDerinligi.sifirla();
  final r = _yonlendirici();
  await tester.pumpWidget(MaterialApp.router(routerConfig: r));
  await tester.pumpAndSettle();
  return r;
}

Finder get _ev => find.byIcon(Icons.home_rounded);

void main() {
  group('gezinti derinliği', () {
    testWidgets('ana sayfa 0, her itme bir artırıyor', (tester) async {
      final r = await _kur(tester);
      expect(find.text('derinlik: 0'), findsOneWidget);

      r.push('/bir');
      await tester.pumpAndSettle();
      expect(find.text('derinlik: 1'), findsOneWidget);

      r.push('/iki');
      await tester.pumpAndSettle();
      expect(find.text('derinlik: 2'), findsOneWidget);
    });

    testWidgets('geri gelince derinlik düşüyor', (tester) async {
      final r = await _kur(tester);
      r.push('/bir');
      await tester.pumpAndSettle();
      r.push('/iki');
      await tester.pumpAndSettle();
      expect(find.text('derinlik: 2'), findsOneWidget);

      r.pop();
      await tester.pumpAndSettle();
      expect(find.text('derinlik: 1'), findsOneWidget);
    });

    testWidgets('diyalog derinliği ARTIRMIYOR', (tester) async {
      final r = await _kur(tester);
      r.push('/bir');
      await tester.pumpAndSettle();
      final boy = GezintiDerinligi.yiginBoyu;

      showDialog<void>(
        context: tester.element(find.text('derinlik: 1')),
        builder: (_) => const AlertDialog(content: Text('onay')),
      );
      await tester.pumpAndSettle();
      expect(find.text('onay'), findsOneWidget);
      // Onay kutusu açmak okuru hiçbir yere götürmüyor.
      expect(GezintiDerinligi.yiginBoyu, boy);
    });
  });

  group('düğmenin görünürlüğü', () {
    testWidgets('ana sayfada YOK', (tester) async {
      await _kur(tester);
      expect(_ev, findsNothing);
    });

    testWidgets('birinci basamakta YOK — geri tuşu zaten eve götürüyor',
        (tester) async {
      final r = await _kur(tester);
      r.push('/bir');
      await tester.pumpAndSettle();
      expect(_ev, findsNothing);
    });

    testWidgets('ikinci basamakta VAR', (tester) async {
      final r = await _kur(tester);
      r.push('/bir');
      await tester.pumpAndSettle();
      r.push('/iki');
      await tester.pumpAndSettle();
      expect(_ev, findsOneWidget);
    });

    testWidgets('üçüncü basamakta da duruyor', (tester) async {
      final r = await _kur(tester);
      for (final y in ['/bir', '/iki', '/uc']) {
        r.push(y);
        await tester.pumpAndSettle();
      }
      expect(_ev, findsOneWidget);
    });

    testWidgets('geri gelip birinci basamağa inince KAYBOLUYOR',
        (tester) async {
      final r = await _kur(tester);
      r.push('/bir');
      await tester.pumpAndSettle();
      r.push('/iki');
      await tester.pumpAndSettle();
      expect(_ev, findsOneWidget);

      r.pop();
      await tester.pumpAndSettle();
      expect(_ev, findsNothing);
    });
  });

  group('yerleşim korunuyor', () {
    testWidgets('eşiğin altında leadingWidth DOKUNULMAMIŞ kalıyor',
        (tester) async {
      final r = await _kur(tester);
      r.push('/bir');
      await tester.pumpAndSettle();
      final bar = tester.widget<AppBar>(find.byType(AppBar));
      // null = Flutter'ın varsayılanı. Bir sayı yazmak başlığı kaydırırdı.
      expect(bar.leadingWidth, isNull);
      expect(bar.leading, isNull);
    });

    testWidgets('eşiğin üstünde iki düğmeye yer açılıyor', (tester) async {
      final r = await _kur(tester);
      r.push('/bir');
      await tester.pumpAndSettle();
      r.push('/iki');
      await tester.pumpAndSettle();
      final bar = tester.widget<AppBar>(find.byType(AppBar));
      expect(bar.leadingWidth, 100);
    });

    testWidgets('dar ekranda taşma yok', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final r = await _kur(tester);
      r.push('/bir');
      await tester.pumpAndSettle();
      r.push('/iki');
      await tester.pumpAndSettle();

      expect(_ev, findsOneWidget);
      expect(tester.takeException(), isNull);
      // Düğme ekranın İÇİNDE kalmalı.
      final kutu = tester.getRect(_ev);
      expect(kutu.right, lessThanOrEqualTo(360.0));
    });
  });

  group('Navigator sökülüp yeniden kurulursa', () {
    // `main.dart` telefon yatay moda çevrildiğinde `builder` içinde `child`
    // yerine uyarı ekranını döndürüyor: Navigator tamamen sökülüyor ve
    // rotalar hiçbir pop/remove olayı üretmeden ölüyor. Dikeye dönünce
    // yenisi kuruluyor. Ölü kayıtlar süpürülmezse derinlik şişiyor ve düğme
    // birinci basamakta da beliriyor.
    testWidgets('derinlik şişmiyor', (tester) async {
      final r1 = await _kur(tester);
      r1.push('/bir');
      await tester.pumpAndSettle();
      r1.push('/iki');
      await tester.pumpAndSettle();
      expect(_ev, findsOneWidget);

      // Yatay mod: ağaçta Navigator KALMIYOR.
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('telefonu dikey tutun'))),
      );
      await tester.pumpAndSettle();
      expect(find.text('telefonu dikey tutun'), findsOneWidget);

      // Dikeye dönüş: yepyeni bir yönlendirici, yepyeni bir yığın.
      final r2 = _yonlendirici();
      await tester.pumpWidget(MaterialApp.router(routerConfig: r2));
      await tester.pumpAndSettle();
      expect(find.text('derinlik: 0'), findsOneWidget);

      r2.push('/bir');
      await tester.pumpAndSettle();
      // Eski üç rota listede asılı kalsaydı burası 3 okurdu.
      expect(find.text('derinlik: 1'), findsOneWidget);
      expect(_ev, findsNothing);
    });
  });

  group('kendi satırını kuran ekranlar', () {
    // Haber detayı ve ülke dosyası `AppBar.leading` kullanmıyor; kendi
    // Row'larını kuruyorlar ve düğmeyi doğrudan araya koyuyorlar. Yol farklı
    // olduğu için ayrıca sınanıyor — dar ekranda taşan yer tam burası olurdu.
    Widget _satir(double genislik) => MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: genislik,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
                    onPressed: () {},
                  ),
                  const AnaSayfaIkonu(renk: Colors.black),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Antalya hallerinde domates fiyatı yıllık yüzde 101 arttı',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

    for (final g in [360.0, 414.0, 768.0, 1200.0]) {
      testWidgets('taşma yok — ${g.toInt()} px', (tester) async {
        tester.view.physicalSize = Size(g, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(_satir(g));
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(_ev, findsOneWidget);
        final kutu = tester.getRect(_ev);
        expect(kutu.right, lessThanOrEqualTo(g));
        // Başlığa yer kalmalı: düğmeler satırın yarısını yememeli.
        final baslik = tester.getRect(find.byType(Text).last);
        expect(baslik.width, greaterThan(g * 0.5));
      });
    }
  });

  group('davranış', () {
    testWidgets('düğme ana sayfaya GÖTÜRÜYOR ve yığını boşaltıyor',
        (tester) async {
      final r = await _kur(tester);
      r.push('/bir');
      await tester.pumpAndSettle();
      r.push('/iki');
      await tester.pumpAndSettle();

      await tester.tap(_ev);
      await tester.pumpAndSettle();

      expect(find.text('sayfa /'), findsOneWidget);
      // `push` olsaydı ana sayfa yığının ÜSTÜNE binerdi ve derinlik 3
      // olurdu; okur geri tuşuna basınca kaçtığı sayfaya dönerdi.
      expect(find.text('derinlik: 0'), findsOneWidget);
      expect(_ev, findsNothing);
    });

    testWidgets('geri tuşu hâlâ bir basamak geri gidiyor', (tester) async {
      final r = await _kur(tester);
      r.push('/bir');
      await tester.pumpAndSettle();
      r.push('/iki');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('sayfa /bir'), findsOneWidget);
    });
  });
}
