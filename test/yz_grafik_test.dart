import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_grafik_veri.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_grafikler.g.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_gorsel.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_grafik.dart';

/// Grafik çizicisinin sınaması (karar 58): her tür iki genişlikte taşmadan
/// çiziliyor, tablo görünümü açılıyor, sayılar dile göre yazılıyor; gömülü
/// gerçek grafiklerin hepsi de aynı sınavdan geçiyor.
YzGrafik _ornek(String tur) {
  const diziler = [YzGrafikDizi('a', 'Laboratuvar', 'Laboratory'), YzGrafikDizi('b', 'Tarla', 'Field')];
  final noktalar = switch (tur) {
    'aralik' => const [
        YzGrafikNokta('1 hektardan küçük', 'Under 1 hectare', 'a', 24, uc: 'alt'),
        YzGrafikNokta('1 hektardan küçük', 'Under 1 hectare', 'a', 37, uc: 'ust'),
        YzGrafikNokta('200 hektardan büyük', 'Over 200 hectares', 'a', 74, uc: 'alt'),
        YzGrafikNokta('200 hektardan büyük', 'Over 200 hectares', 'a', 80, uc: 'ust'),
      ],
    'zaman' => const [
        YzGrafikNokta('Landsat 1 fırlatıldı', 'Landsat 1 launched', 'a', 1972),
        YzGrafikNokta('Uydudan Sovyet hasat tahmini', 'Satellite forecast of the Soviet harvest', 'b', 1977),
        YzGrafikNokta('Landsat arşivi ücretsiz', 'Landsat archive made free', 'a', 2008),
      ],
    'waffle' || 'kpi' => const [
        YzGrafikNokta('Tarım', 'Agriculture', 'a', 86.93),
        YzGrafikNokta('Belediyeler', 'Municipalities', 'b', 11.06),
      ],
    'pay' => const [
        YzGrafikNokta('Türkiye', 'Türkiye', 'a', 86.93),
        YzGrafikNokta('Türkiye', 'Türkiye', 'b', 13.07),
      ],
    'kucuk' => const [
        YzGrafikNokta('Tarımda çalışanlar', 'Agricultural workers', 'a', 46,
            panelTr: 'Ortalama yaş', panelEn: 'Average age', birimTr: 'yıl', birimEn: 'years'),
        YzGrafikNokta('Bütün istihdam', 'All employment', 'b', 39,
            panelTr: 'Ortalama yaş', panelEn: 'Average age', birimTr: 'yıl', birimEn: 'years'),
        YzGrafikNokta('Tarımda çalışanlar', 'Agricultural workers', 'a', 68.4,
            panelTr: '40 yaşın üzerindekilerin payı', panelEn: 'Share aged over 40'),
        YzGrafikNokta('Bütün istihdam', 'All employment', 'b', 47.1,
            panelTr: '40 yaşın üzerindekilerin payı', panelEn: 'Share aged over 40'),
      ],
    _ => const [
        YzGrafikNokta('Mohanty 2016', 'Mohanty 2016', 'a', 99.35),
        YzGrafikNokta('Mohanty 2016', 'Mohanty 2016', 'b', 31.4),
        YzGrafikNokta('Nuru 2020', 'Nuru 2020', 'a', 74),
        YzGrafikNokta('Nuru 2020', 'Nuru 2020', 'b', 65),
      ],
  };
  return YzGrafik(
    kimlik: 'ornek-$tur',
    tur: tur,
    baslikTr: 'Laboratuvarda yüksek, tarlada düşük doğruluk',
    baslikEn: 'High accuracy in the lab, lower in the field',
    aciklamaTr: 'Aynı modeller başka koşullarda çekilmiş görüntülerde geriledi.',
    aciklamaEn: 'The same models fell back on images taken in other conditions.',
    kaynakTr: 'Kaynak: örnek',
    kaynakEn: 'Source: example',
    birimTr: tur == 'zaman' ? '' : '%',
    birimEn: tur == 'zaman' ? '' : '%',
    diziler: diziler,
    noktalar: noktalar,
  );
}

const _turler = ['yatay_cubuk', 'dikey_cubuk', 'cizgi', 'alan', 'dumbbell', 'aralik', 'pay',
  'waffle', 'egim', 'kpi', 'isi', 'zaman', 'kucuk'];

Widget _sar(Widget w) => MaterialApp(home: Scaffold(body: SingleChildScrollView(
    child: Padding(padding: const EdgeInsets.all(16), child: w))));

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  test('sayı dile göre yazılıyor', () {
    expect(yzDeger(99.35, '%', false), '%99,35');
    expect(yzDeger(99.35, '%', true), '99.35%');
    expect(yzDeger(634575, 'ha', false), '634.575 ha');
    expect(yzDeger(634575, 'ha', true), '634,575 ha');
    expect(yzSayi(7, false), '7');
  });

  for (final olcu in const [Size(360, 900), Size(1280, 900)]) {
    for (final en in const [false, true]) {
      testWidgets('her grafik türü · ${en ? 'en' : 'tr'} · ${olcu.width.toInt()} piksel · taşmıyor', (t) async {
        t.view.physicalSize = olcu;
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        for (final tur in _turler) {
          await t.pumpWidget(_sar(YzGrafikKarti(grafik: _ornek(tur), en: en)));
          await t.pumpAndSettle();
          expect(t.takeException(), isNull, reason: tur);
          await t.tap(find.text(en ? 'Show table' : 'Tablo olarak gör'));
          await t.pumpAndSettle();
          expect(t.takeException(), isNull, reason: '$tur tablo');
          await t.pumpWidget(const SizedBox());
        }
        await t.pumpWidget(_sar(YzGorselKarti(en: en, gorsel: const YzGorsel(
            kimlik: 'ornek', adres: '/yz/gorsel/ornek.webp', genislik: 1600, yukseklik: 900,
            kunyeTr: 'Hands Free Hectare projesinin otonom traktörü, Harper Adams Üniversitesi, 2017.',
            kunyeEn: 'The autonomous tractor of the Hands Free Hectare project, Harper Adams University, 2017.',
            kaynakTr: 'Fotoğraf: Harper Adams Üniversitesi', kaynakEn: 'Photo: Harper Adams University'))));
        await t.pump();
        expect(t.takeException(), isNull, reason: 'görsel kartı');
        expect(find.textContaining(en ? 'autonomous tractor' : 'otonom traktörü'), findsOneWidget);
        for (final g in kYzGorseller.values) {
          await t.pumpWidget(_sar(YzGorselKarti(gorsel: g, en: en)));
          await t.pump();
          expect(t.takeException(), isNull, reason: g.kimlik);
        }
        for (final g in kYzGrafikler.values) {
          await t.pumpWidget(_sar(YzGrafikKarti(grafik: g, en: en)));
          await t.pumpAndSettle();
          expect(t.takeException(), isNull, reason: g.kimlik);
          await t.pumpWidget(const SizedBox());
        }
      });
    }
  }
}
