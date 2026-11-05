import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarim_app/core/utils/sayi_yazimi.dart';
import 'package:tarim_app/features/home/presentation/widgets/dynamic_chart_widget.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Haber grafiğinde rakam yazımı, Türkçe büyük harf, künye ve yazı ölçeği.
//
//  Hepsi 3 Kasım 2026'daki denetimin bulguları. Dördü de GÖZLE fark edilmesi
//  zor hatalardı: "45000TL/ton" bir rakam gibi duruyor, "HIBE" bir büyük harf
//  gibi duruyor, eksik kaynak satırı hiçbir iz bırakmıyor.
// ══════════════════════════════════════════════════════════════════════════

Widget _sar(Map<String, dynamic> grafik,
        {bool isEn = false, double olcek = 1.0, String? kunye, double genislik = 1200}) =>
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: genislik,
            child: DynamicChartWidget(
              chartData: grafik,
              isDark: false,
              accent: const Color(0xFF5C8A4A),
              isEn: isEn,
              olcek: olcek,
              kunye: kunye,
            ),
          ),
        ),
      ),
    );

Finder _iceren(String parca) => find.byWidgetPredicate(
      (w) => w is Text && (w.data ?? '').contains(parca),
    );

void main() {
  group('sayı yazımı', () {
    test('binlik ayıracı Türkçe', () {
      expect(sayiYaz(45000, false), '45.000');
      expect(sayiYaz(1234567, false), '1.234.567');
      expect(sayiYaz(45000, true), '45,000');
    });

    test('tam sayıya ondalık EKLENMİYOR, kesirli sayıda bir basamak kalıyor', () {
      expect(sayiYaz(12, false), '12');
      expect(sayiYaz(12.4, false), '12,4');
    });

    test('birim araya bölünmez boşlukla giriyor', () {
      expect(birimliYaz(45000, 'TL/ton', false), '45.000\u00A0TL/ton');
      // Normal boşluk OLMAMALI: dar sütunda rakamı biriminden ayırıp alt
      // satıra atıyor.
      expect(birimliYaz(45000, 'TL/ton', false).contains(' '), isFalse);
    });

    test('yüzde Türkçede önde, İngilizcede arkada', () {
      expect(birimliYaz(45, '%', false), '%45');
      expect(birimliYaz(45, '%', true), '45%');
    });

    test('birim yoksa yalnız rakam', () {
      expect(birimliYaz(45000, '', false), '45.000');
      expect(birimliYaz(45000, '   ', false), '45.000');
    });

    test('sayı olmayan değer OLDUĞU GİBİ geçiyor', () {
      // Grafik verisi dil modelinden geliyor; `value` her zaman sayı değil.
      expect(degerYaz('veri yok', false), 'veri yok');
      expect(degerYaz('1 Ocak-31 Temmuz', false), '1 Ocak-31 Temmuz');
      expect(degerYaz(null, false), '');
    });
  });

  group('tablo hücresi', () {
    test('beş basamaklı sayı ayıraç alıyor, birim korunuyor', () {
      expect(hucreYaz('100000 adet', false), '100.000 adet');
      expect(hucreYaz('100000', false), '100.000');
    });

    test('YIL biçimlenmiyor — eşik tam da bunun için beş basamak', () {
      // "2026" → "2.026" düpedüz hata olurdu ve tablolarda dönem sütunu
      // yaygın.
      expect(hucreYaz('2026', false), '2026');
      expect(hucreYaz('2026 yılı', false), '2026 yılı');
    });

    test('küçük sayıya dokunulmuyor', () {
      expect(hucreYaz('2 adet', false), '2 adet');
      expect(hucreYaz('17 Etap', false), '17 Etap');
    });

    test('zaten biçimli ya da ondalıklı hücreye dokunulmuyor', () {
      expect(hucreYaz('100.000 adet', false), '100.000 adet');
      expect(hucreYaz('1.234,5 ton', false), '1.234,5 ton');
    });

    test('sayıyla başlamayan hücre olduğu gibi', () {
      expect(hucreYaz('Toplam yatırım bedeli', false), 'Toplam yatırım bedeli');
      expect(hucreYaz('60 milyon TL', false), '60 milyon TL');
    });

    test('İngilizcede virgüllü ayıraç', () {
      expect(hucreYaz('100000 units', true), '100,000 units');
    });
  });

  group('grafik künyesi', () {
    test('kaynak ve tek dönem yazılıyor', () {
      final k = grafikKunyesi([
        {'label': 'Buğday', 'value': 1, 'source': 'TÜİK', 'period': 'Ocak 2026'},
      ], false);
      expect(k, 'Kaynak: TÜİK · Dönem: Ocak 2026');
    });

    test('aynı kaynak TEKRARLANMIYOR', () {
      final k = grafikKunyesi([
        {'value': 1, 'source': 'TÜİK'},
        {'value': 2, 'source': 'TÜİK'},
        {'value': 3, 'source': 'TMO'},
      ], false);
      expect(k, 'Kaynak: TÜİK, TMO');
    });

    test('birden çok dönem varsa dönem HİÇ yazılmıyor', () {
      // "Dönem: 2024, 2025" hangi rakamın hangi yıla ait olduğunu söylemiyor.
      final k = grafikKunyesi([
        {'value': 1, 'source': 'TÜİK', 'period': '2024'},
        {'value': 2, 'source': 'TÜİK', 'period': '2025'},
      ], false);
      expect(k, 'Kaynak: TÜİK');
    });

    test('ne kaynak ne dönem varsa null', () {
      expect(grafikKunyesi([{'value': 1}], false), isNull);
      expect(grafikKunyesi([], false), isNull);
      expect(grafikKunyesi(null, false), isNull);
    });

    test('İngilizce etiketler', () {
      expect(
        grafikKunyesi([{'value': 1, 'source': 'TurkStat', 'period': '2026'}], true),
        'Source: TurkStat · Period: 2026',
      );
    });
  });

  group('sütun birleşimi', () {
    test('ilk satırda olmayan sütun DÜŞMÜYOR', () {
      final s = sutunlariTopla([
        {'Değer': '1', 'Dönem': '2026'},
        {'Değer': '2', 'Dönem': '2025', 'Ölçüm': 'ihracat'},
      ]);
      expect(s, ['Değer', 'Dönem', 'Ölçüm']);
    });

    test('sıra ilk görülme sırası, alfabetik DEĞİL', () {
      final s = sutunlariTopla([
        {'Ölçüm': 'a', 'Değer': '1'},
      ]);
      expect(s, ['Ölçüm', 'Değer']);
    });
  });

  group('çizim', () {
    testWidgets('rakam binlik ayıraçlı ve birimden boşlukla ayrı çiziliyor',
        (tester) async {
      await tester.pumpWidget(_sar({
        'type': 'bar',
        'title': 'Buğday fiyatı',
        'unit': 'TL/ton',
        'data': [
          {'label': 'Ankara', 'value': 45000},
        ],
      }));
      await tester.pump();
      expect(_iceren('45.000\u00A0TL/ton'), findsOneWidget);
      expect(_iceren('45000TL/ton'), findsNothing);
    });

    testWidgets('tek rakam kartında etiket Türkçe büyük harfe çevriliyor',
        (tester) async {
      await tester.pumpWidget(_sar({
        'type': 'stat',
        'title': 'Destek',
        'unit': 'TL',
        'data': [
          {'label': 'Hibe desteği', 'value': 250000},
        ],
      }));
      await tester.pump();
      // Ham `toUpperCase()` "HIBE DESTEĞI" üretiyordu — noktasız I.
      expect(_iceren('HİBE DESTEĞİ'), findsOneWidget);
      expect(_iceren('HIBE'), findsNothing);
    });

    testWidgets('altlık boşsa künye çiziliyor', (tester) async {
      await tester.pumpWidget(_sar(
        {
          'type': 'bar',
          'title': 'Buğday fiyatı',
          'data': [
            {'label': 'Ankara', 'value': 45000},
          ],
        },
        kunye: 'Kaynak: TÜİK · Dönem: Ocak 2026',
      ));
      await tester.pump();
      expect(_iceren('Kaynak: TÜİK'), findsOneWidget);
    });

    testWidgets('dolu altlık künyeyi EZİYOR', (tester) async {
      await tester.pumpWidget(_sar(
        {
          'type': 'bar',
          'title': 'Buğday fiyatı',
          'subtitle': 'Haftalık ortalama',
          'data': [
            {'label': 'Ankara', 'value': 45000},
          ],
        },
        kunye: 'Kaynak: TÜİK',
      ));
      await tester.pump();
      expect(_iceren('Haftalık ortalama'), findsOneWidget);
      expect(_iceren('Kaynak: TÜİK'), findsNothing);
    });

    testWidgets('yazı ölçeği grafiğe işliyor', (tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      Future<double> yuksekligi(double olcek) async {
        await tester.pumpWidget(_sar({
          'type': 'table',
          'title': 'Tablo',
          'data': [
            {'Değer': '45.000', 'Dönem': 'Ocak 2026', 'Ölçüm': 'Buğday alım fiyatı'},
          ],
        }, olcek: olcek));
        await tester.pump();
        return tester.getSize(_iceren('Buğday alım fiyatı').first).height;
      }

      final bir = await yuksekligi(1.0);
      final birBucuk = await yuksekligi(1.5);
      // Tablo hücresi 11 puntoda ÇAKILI kalıyordu; artık gövdeyle birlikte
      // büyüyor.
      expect(birBucuk, greaterThan(bir * 1.3));
    });

    testWidgets('grafik ekran okuyucuya düz metin olarak veriliyor',
        (tester) async {
      final tanik = tester.ensureSemantics();

      await tester.pumpWidget(_sar({
        'type': 'table',
        'title': 'Buğday alımı',
        'data': [
          {'Değer': '45.000', 'Ölçüm': 'alım fiyatı'},
        ],
      }));
      await tester.pump();

      // CanvasKit bütün yazıyı tuvale boyuyor: etiket olmadan bu hücreler
      // ekran okuyucu için YOK.
      expect(
        find.bySemanticsLabel(RegExp(r'Buğday alımı.*Değer: 45\.000')),
        findsOneWidget,
      );
      // Tutamak test BİTMEDEN bırakılmak zorunda: `addTearDown` doğrulamadan
      // sonra çalışıyor ve "SemanticsHandle hâlâ açık" hatası veriyor.
      tanik.dispose();
    });
  });

  yatayCubukSinamalari();
}

// ══════════════════════════════════════════════════════════════════════════
//  Yatay çubukta değer yazısının yeri.
//
//  Doğrulama sırasında çıkan ayrı bir hata: yazı rayın tamamına göre
//  hizalanıyordu, renkli dolguya göre değil. İki yönde de okunamıyordu —
//  beyaz yazı açık zemine düşüyor ya da renkli yazı aynı renge biniyordu.
// ══════════════════════════════════════════════════════════════════════════
void yatayCubukSinamalari() {
  group('yatay çubuk değer yazısı', () {
    /// Grafiği kurar ve ölçülen değerin yazısının dikdörtgenini döndürür.
    ///
    /// `tekBasina` ile tek satırlık grafik çiziliyor: o zaman dolgu oranı 1
    /// oluyor. İki satırda aynı sayıyı kullanmak bulucuya İKİ eşleşme
    /// veriyordu — sınama kendi kurgusu yüzünden düşüyordu.
    Future<Rect> kutu(
      WidgetTester tester,
      num deger,
      String yazili, {
      bool tekBasina = false,
    }) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            child: DynamicChartWidget(
              chartData: {
                'type': 'horizontal_bar',
                'title': 'Maliyet',
                'unit': 'Milyar Euro',
                'data': [
                  if (!tekBasina) {'label': 'Ölçek', 'value': 12},
                  {'label': 'Ölçülen', 'value': deger},
                ],
              },
              isDark: false,
              accent: const Color(0xFF5C8A4A),
              isEn: false,
            ),
          ),
        ),
      ));
      await tester.pump();
      final f = find.byWidgetPredicate(
        // Ayıraç bölünmez boşluk (U+00A0) — normal boşluk HİÇ eşleşmiyor.
        (w) => w is Text && (w.data ?? '').startsWith('$yazili\u00A0'),
      );
      expect(f, findsOneWidget, reason: '$yazili çizilmedi');
      return tester.getRect(f);
    }

    Text yazi(WidgetTester tester, String yazili) => tester.widget<Text>(
          find.byWidgetPredicate(
            (w) => w is Text && (w.data ?? '').startsWith('$yazili\u00A0'),
          ),
        );

    testWidgets('kısa çubukta yazı dolgunun DIŞINDA ve çubuk rengiyle',
        (tester) async {
      // 1,5 / 12 = %12,5: yazı dolguya sığmıyor.
      await kutu(tester, 1.5, '1,5');
      // Beyaz OLMAMALI — dolgunun dışı açık zemin.
      expect(yazi(tester, '1,5').style?.color, isNot(Colors.white));
    });

    testWidgets('dolu çubukta yazı İÇERİDE ve beyaz', (tester) async {
      await kutu(tester, 12, '12', tekBasina: true);
      expect(yazi(tester, '12').style?.color, Colors.white);
    });

    testWidgets('yazı hiçbir durumda rayın dışına taşmıyor', (tester) async {
      const durumlar = [
        (0.1, '0,1'), (1.5, '1,5'), (5, '5'), (9.9, '9,9'), (11.9, '11,9'),
      ];
      for (final (deger, yazili) in durumlar) {
        final r = await kutu(tester, deger, yazili);
        expect(r.right, lessThanOrEqualTo(1200.0),
            reason: '$yazili değerinde yazı sağa taştı');
        expect(r.left, greaterThanOrEqualTo(0.0));
      }
    });
  });
}
