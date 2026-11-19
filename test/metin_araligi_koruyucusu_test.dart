import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarim_app/core/widgets/metin_araligi_koruyucusu.dart';

// flutter#190350: Android WebView sistem yazısı büyütülmüşken satır
// çarpanını ~624,9 bildiriyor ve metin görünmez oluyor.
void main() {
  Future<double> yukseklik(WidgetTester t, double? carpan) async {
    await t.pumpWidget(MediaQuery(
      data: MediaQueryData(
          lineHeightScaleFactorOverride: carpan, textScaler: const TextScaler.linear(1.15)),
      child: const Directionality(
        textDirection: TextDirection.ltr,
        child: MetinAraligiKoruyucusu(
          child: Align(alignment: Alignment.topLeft, child: Text('Toprak', style: TextStyle(fontSize: 18))),
        ),
      ),
    ));
    return t.getSize(find.text('Toprak')).height;
  }

  testWidgets('624,9 çarpanında başlık ve paragraf makul yükseklikte', (t) async {
    final normal = await yukseklik(t, null);
    final bozuk = await yukseklik(t, 624.94);
    expect(bozuk, closeTo(normal, 0.5));
    expect(bozuk, lessThan(60));
  });

  testWidgets('makul satır aralığı tercihi korunuyor', (t) async {
    final normal = await yukseklik(t, null);
    final tercih = await yukseklik(t, 1.5);
    expect(tercih, greaterThan(normal));
  });

  testWidgets('okurun yazı büyütmesi korunuyor', (t) async {
    await t.pumpWidget(MediaQuery(
      data: const MediaQueryData(lineHeightScaleFactorOverride: 624.94, textScaler: TextScaler.linear(1.3)),
      child: MetinAraligiKoruyucusu(child: Builder(builder: (c) {
        return Text('${MediaQuery.textScalerOf(c).scale(10)}', textDirection: TextDirection.ltr);
      })),
    ));
    expect(find.text('13.0'), findsOneWidget);
  });
}
