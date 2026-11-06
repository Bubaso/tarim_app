import 'package:flutter/material.dart';

import '../../data/models/commodity_price.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Fiyat eğrisi (sparkline)
// ──────────────────────────────────────────────────────────────────────────
//  6 Kasım 2026 anasayfa denetimi (A7/Ö4): emtia şeridi fiyatın BUGÜNKÜ
//  değerini söylüyordu ama YÖNÜNÜ söylemiyordu. "19,25 ▲%0,81" bir günlük
//  değişim; çiftçi için asıl soru fiyatın nereye gittiği.
//
//  Ayrıca şeritte yalnız ilk kart ayrıntı taşıyordu (aylık aralık, borsa,
//  tarih) ve yanındaki beşi yalnız fiyat. Aynı satırda iki farklı bilgi
//  yoğunluğu ilk kartı "seçili" gibi gösteriyordu — oysa seçili değil,
//  ayrıcalıklıydı. Eğri her karta girince fark anlamlı hâle geliyor:
//  açılan kart DAHA ÇOK şey gösteriyor, ötekiler de boş durmuyor.
//
//  Eksen, ızgara ve etiket YOK. Sparkline'ın işi tek bir şeyi söylemek:
//  şekil. Rakamlar zaten kartın üstünde duruyor; ikinci kez yazmak
//  kalabalık olurdu.
// ══════════════════════════════════════════════════════════════════════════

class FiyatEgrisi extends StatelessWidget {
  const FiyatEgrisi({
    super.key,
    required this.noktalar,
    required this.renk,
    this.yukseklik = 26,
  });

  final List<CommodityPricePoint> noktalar;
  final Color renk;
  final double yukseklik;

  /// Çizim için gereken en az nokta.
  ///
  /// İki nokta bir doğru çizer ve "eğilim" izlenimi verir; oysa iki günlük
  /// veriden eğilim okunmaz. Dört, bir haftanın kabaca yarısı.
  static const int enAzNokta = 4;

  @override
  Widget build(BuildContext context) {
    if (noktalar.length < enAzNokta) {
      // Veri yoksa HİÇBİR ŞEY çizilmiyor — boş bir kutu ya da düz bir
      // çizgi, "fiyat sabit" diye okunurdu.
      return SizedBox(height: yukseklik);
    }
    return SizedBox(
      height: yukseklik,
      width: double.infinity,
      child: CustomPaint(painter: _EgriCizici(noktalar: noktalar, renk: renk)),
    );
  }
}

class _EgriCizici extends CustomPainter {
  _EgriCizici({required this.noktalar, required this.renk});

  final List<CommodityPricePoint> noktalar;
  final Color renk;

  @override
  void paint(Canvas canvas, Size size) {
    final degerler = noktalar.map((n) => n.avgPrice).toList();
    final enAz = degerler.reduce((a, b) => a < b ? a : b);
    final enCok = degerler.reduce((a, b) => a > b ? a : b);
    // Düz bir seride bölme sıfıra düşüyor; o durumda çizgi ortadan geçiyor.
    final aralik = (enCok - enAz).abs() < 1e-9 ? 1.0 : (enCok - enAz);

    // Son nokta için sağda yer bırakılıyor: vurgu noktası kenara
    // yapışınca yarısı kırpılıyordu.
    final sagPay = 3.0;
    final w = size.width - sagPay;
    final h = size.height;

    Offset konum(int i) {
      final x = degerler.length == 1
          ? 0.0
          : w * (i / (degerler.length - 1));
      // Dikeyde %12 pay: tepe ve dip kenara değmesin.
      final t = (degerler[i] - enAz) / aralik;
      final y = h * (0.88 - t * 0.76);
      return Offset(x, y);
    }

    final yol = Path()..moveTo(konum(0).dx, konum(0).dy);
    for (var i = 1; i < degerler.length; i++) {
      yol.lineTo(konum(i).dx, konum(i).dy);
    }

    // Altındaki dolgu çok soluk: eğriyi "ağırlaştırmadan" oturtuyor.
    final dolgu = Path.from(yol)
      ..lineTo(konum(degerler.length - 1).dx, h)
      ..lineTo(konum(0).dx, h)
      ..close();
    canvas.drawPath(
      dolgu,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [renk.withValues(alpha: 0.22), renk.withValues(alpha: 0.0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, h)),
    );

    canvas.drawPath(
      yol,
      Paint()
        ..color = renk.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    // Son nokta vurgulu: gözün "bugün buradayız" diye tutunacağı yer.
    canvas.drawCircle(konum(degerler.length - 1), 2.4, Paint()..color = renk);
  }

  @override
  bool shouldRepaint(_EgriCizici eski) =>
      eski.renk != renk || eski.noktalar.length != noktalar.length;
}
