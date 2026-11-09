import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Üç yerleşim AYNI bölümleri AYNI sırada taşımalı
// ──────────────────────────────────────────────────────────────────────────
//  Ana sayfa üç ayrı sınıfta kuruluyor: _MobileContent, _TabletContent,
//  _DesktopContent. Üçü de aynı bölüm dizisini elle sıralıyor; aralarındaki
//  gerçek fark yalnızca boşluk (28/36/40) ve masaüstündeki genişlik sınırı.
//
//  Tehlike şu: yeni bir bölüm üç yere birden eklenmek zorunda ve biri
//  atlanırsa HİÇBİR hata çıkmıyor. Bölüm o kırılma noktasında sessizce yok
//  oluyor — derleme geçiyor, test geçiyor, yalnız telefonda bir bölüm
//  eksik kalıyor. 8 Kasım 2026'da SektorelBlok'un yeri değiştirilirken
//  tam olarak bu risk üç kez ayrı ayrı elle yönetildi.
//
//  Doğru çözüm tek bir bildirimsel liste ve yerleşime göre sarmalama.
//  O, ana sayfanın yeniden kurulması demek ve ayrı bir tura bırakıldı.
//  Bu test o güne kadar boşluğu kapatıyor: üç liste ayrışırsa kırılıyor.
//
//  Kaynak dosyayı OKUYOR, widget pump ETMİYOR. Ana sayfayı pump etmek
//  Supabase, Riverpod ve ağ gerektiriyor (widget_test.dart bu yüzden
//  kırık); oysa burada sorulan soru çalışma anına ait değil: üç listede
//  aynı adlar aynı sırada mı?
// ══════════════════════════════════════════════════════════════════════════

/// Yerleşime göre DEĞİŞMESİ normal olan, karşılaştırmaya girmeyen parçalar.
///
/// Boşluk kutuları ve sarmalayıcılar yerleşimin kendisi; bölüm değil.
const yoksay = <String>{
  'SizedBox', 'Center', 'ConstrainedBox', 'Padding', 'Column', 'Row',
  'ListView', 'CustomScrollView', 'SliverPadding', 'SliverToBoxAdapter',
  'SliverList', 'RefreshIndicator', 'Expanded', 'Flexible', 'Divider',
  'SliverFillRemaining', 'EdgeInsets', 'BoxConstraints',
};

/// Bir yerleşim sınıfının gövdesinden bölüm adlarını sırasıyla çıkarır.
List<String> bolumler(String kaynak, String sinif) {
  final bas = kaynak.indexOf('class $sinif');
  expect(bas, isNot(-1), reason: '$sinif bulunamadı — sınıf adı değişmiş.');
  // Bir sonraki üst düzey `class` bildirimine kadar.
  final son = kaynak.indexOf('\nclass ', bas + 1);
  final govde = son == -1 ? kaynak.substring(bas) : kaynak.substring(bas, son);

  final out = <String>[];
  for (final m in RegExp(r'\b([A-Z][A-Za-z0-9_]*)\(').allMatches(govde)) {
    final ad = m.group(1)!;
    if (yoksay.contains(ad)) continue;
    // Aynı bölüm iki kez arka arkaya yazılmıyor; tekrar eden ad bir
    // sarmalayıcıdır (örn. Text, Icon) — onları da eliyoruz.
    if (out.isNotEmpty && out.last == ad) continue;
    out.add(ad);
  }
  return out;
}

void main() {
  late String kaynak;

  setUpAll(() {
    kaynak = File('lib/features/home/presentation/screens/home_screen.dart')
        .readAsStringSync();
  });

  test('üç yerleşim aynı bölümleri aynı sırada taşıyor', () {
    final mobil = bolumler(kaynak, '_MobileContent');
    final tablet = bolumler(kaynak, '_TabletContent');
    final masaustu = bolumler(kaynak, '_DesktopContent');

    // Önce iş yapıldığını doğrula: boş listeler testi kendiliğinden geçerdi.
    expect(mobil.length, greaterThan(8),
        reason: 'Mobil yerleşimde bölüm bulunamadı — ayrıştırma bozulmuş.');

    // Yalnızca ÜÇÜNDE DE geçen adlar karşılaştırılıyor. Bir yerleşime özgü
    // parça olabilir (masaüstündeki yazar sütunu gibi); test onları değil,
    // ORTAK bölümlerin SIRASINI koruyor.
    final ortak = mobil.toSet()
      ..retainAll(tablet.toSet())
      ..retainAll(masaustu.toSet());

    List<String> suz(List<String> l) =>
        l.where(ortak.contains).toList(growable: false);

    expect(suz(tablet), equals(suz(mobil)),
        reason: 'Tablet yerleşimi mobilden farklı sıralıyor.');
    expect(suz(masaustu), equals(suz(mobil)),
        reason: 'Masaüstü yerleşimi mobilden farklı sıralıyor.');
  });

  test('bir yerleşimde olup ötekinde olmayan bölüm yok', () {
    final mobil = bolumler(kaynak, '_MobileContent').toSet();
    final tablet = bolumler(kaynak, '_TabletContent').toSet();
    final masaustu = bolumler(kaynak, '_DesktopContent').toSet();

    // Bilerek yerleşime özgü olanlar. Listeye eklemek BİLİNÇLİ bir karar
    // olmalı; yanlışlıkla atlanan bölüm buraya yazılmadığı sürece test
    // kırılıyor.
    const bilerekFarkli = <String>{
      'IosPwaPrompt', // yalnızca dar ekran
      'AuthorsRail', // yalnızca geniş ekran sütunu
    };

    final hepsi = {...mobil, ...tablet, ...masaustu};
    final eksikler = <String, List<String>>{};
    for (final ad in hepsi) {
      if (bilerekFarkli.contains(ad)) continue;
      final yok = <String>[
        if (!mobil.contains(ad)) 'mobil',
        if (!tablet.contains(ad)) 'tablet',
        if (!masaustu.contains(ad)) 'masaüstü',
      ];
      if (yok.isNotEmpty) eksikler[ad] = yok;
    }

    expect(eksikler, isEmpty,
        reason: 'Şu bölümler bazı yerleşimlerde YOK:\n'
            '${eksikler.entries.map((e) => '  ${e.key} → ${e.value.join(", ")}').join('\n')}');
  });
}
