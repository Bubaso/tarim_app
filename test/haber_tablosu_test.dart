import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/features/home/presentation/widgets/dynamic_chart_widget.dart';

/// Gerçek bir haberden alınmış tablo (bati-akdeniz-ihracatinda-hacim-uyarisi).
///
/// Sütun sırası Değer | Dönem | Ölçüm ve şeklin tuzağı burada: en KISA içerik
/// ilk sütunda, en uzunu sonda. Eski kod ilk sütuna sabit çift genişlik
/// veriyordu; boş duran sütun yerin yarısını alıyor, açıklama dörtte bire
/// sıkışıp kesiliyordu.
const _tablo = {
  'type': 'table',
  'title': 'Kaynaktaki Veriler',
  'subtitle': 'Kaynak: BAİB',
  'data': [
    {
      'Değer': '564.188.810 dolar',
      'Dönem': '1 Ocak-31 Temmuz 2026',
      'Ölçüm': 'Yaş meyve ve sebze ihracat geliri',
    },
    {
      'Değer': '-15,44 %',
      'Dönem': '1 Ocak-31 Temmuz 2026',
      'Ölçüm': 'Yaş meyve ve sebze ihracatı miktar değişimi',
    },
  ],
};

Widget _sarmala({required double genislik}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: genislik,
          child: const DynamicChartWidget(
            chartData: _tablo,
            isDark: false,
            accent: Color(0xFF5C8A4A),
          ),
        ),
      ),
    ),
  );
}

/// Metni, parçalanmış Text widget'larında da bulur.
Finder _iceren(String parca) => find.byWidgetPredicate(
      (w) => w is Text && (w.data ?? '').contains(parca),
    );

Future<void> _kur(WidgetTester tester, double genislik) async {
  tester.view.physicalSize = Size(genislik, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_sarmala(genislik: genislik));
  await tester.pump();
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  group('geniş ekran', () {
    testWidgets('tablo düzeni ve bütün hücreler tam', (tester) async {
      await _kur(tester, 900);

      expect(find.byType(Table), findsOneWidget);
      for (final metin in [
        'Değer',
        'Ölçüm',
        '564.188.810 dolar',
        'Yaş meyve ve sebze ihracatı miktar değişimi',
        '1 Ocak-31 Temmuz 2026',
      ]) {
        expect(_iceren(metin), findsWidgets, reason: '"$metin" yok');
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('hiçbir hücre kırpılmıyor', (tester) async {
      // Eski kodda hücrelerde `TextOverflow.ellipsis` vardı: dar sütuna
      // sığmayan içerik üç noktayla kesiliyordu. Sarmak, kesmekten iyidir.
      await _kur(tester, 900);

      final hucreler = tester.widgetList<Text>(find.byType(Text));
      for (final hucre in hucreler) {
        expect(hucre.overflow, isNot(TextOverflow.ellipsis),
            reason: '"${hucre.data}" kırpılacak biçimde');
      }
    });
  });

  group('dar ekran', () {
    testWidgets('blok düzenine geçiyor, bilgi düşmüyor', (tester) async {
      // 360 px'de üç sütun yan yana okunmuyor: 90 px'lik bir sütunda uzun
      // açıklama yedi satıra iniyor. Blok düzeninde başlıklar da duruyor.
      await _kur(tester, 360);

      expect(find.byType(Table), findsNothing);
      for (final metin in [
        'Yaş meyve ve sebze ihracat geliri',
        '564.188.810 dolar',
        '1 Ocak-31 Temmuz 2026',
        'DEĞER',
        'DÖNEM',
      ]) {
        expect(_iceren(metin), findsWidgets, reason: '"$metin" yok');
      }
      expect(tester.takeException(), isNull);
    });
  });

  group('taşma', () {
    for (final genislik in [360.0, 414.0, 768.0, 1200.0]) {
      testWidgets('${genislik.toInt()} px', (tester) async {
        await _kur(tester, genislik);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
