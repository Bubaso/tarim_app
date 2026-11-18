import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// İngilizce şemaların Türkçe sayfada çizilen uyarlamaları (karar 59).
///
/// Metinler özgün şemaların çevirisi; yeni bilgi eklenmiyor. Geniş ekranda
/// özgün düzen, dar ekranda aynı içerik okunabilir bir düzende. İngilizce
/// sayfada özgün görseller gösteriliyor (yz_gorsel.dart `_cizim`).
///  · [YzErsSemasi]: ABD Tarım Bakanlığı ERS, EIB-248 Şekil 2 (kamu malı).
///  · [YzCemaSemasi]: CEMA, "Digital Farming: what does it really mean?" Şekil 1.
///  · [YzFarmerChatSemasi]: Singh ve ark. 2024, arXiv:2409.08916, Şekil 1 (CC BY-NC-SA 4.0).

TextStyle _y(double boy, {Color renk = const Color(0xFF22272B), FontWeight k = FontWeight.w400, FontStyle? stil, double aralik = 0}) =>
    GoogleFonts.outfit(fontSize: boy, color: renk, fontWeight: k, fontStyle: stil, height: 1.28, letterSpacing: aralik);

/// Kesikli ya da noktalı dikdörtgen çerçeve.
class _KesikliCerceve extends CustomPainter {
  const _KesikliCerceve({required this.renk, this.cizgi = 6, this.bosluk = 4, this.kalinlik = 1.6, this.yaricap = 0});
  final Color renk;
  final double cizgi, bosluk, kalinlik, yaricap;

  @override
  void paint(Canvas c, Size s) {
    final kalem = Paint()
      ..color = renk
      ..style = PaintingStyle.stroke
      ..strokeWidth = kalinlik;
    final yol = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & s, Radius.circular(yaricap)));
    for (final m in yol.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += cizgi + bosluk) {
        c.drawPath(m.extractPath(d, math.min(d + cizgi, m.length)), kalem);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _KesikliCerceve eski) => eski.renk != renk;
}

Widget _kesikli(Widget cocuk, {required Color renk, double cizgi = 6, double bosluk = 4, double kalinlik = 1.6, double yaricap = 0}) =>
    CustomPaint(
      foregroundPainter:
          _KesikliCerceve(renk: renk, cizgi: cizgi, bosluk: bosluk, kalinlik: kalinlik, yaricap: yaricap),
      child: cocuk,
    );

// ═════════════════════════════════════════════════════════════════════════
//  ERS — dijital tarımın temel bileşen teknolojileri
// ═════════════════════════════════════════════════════════════════════════

const _ersKirmizi = Color(0xFFD2283C);
const _ersMavi = Color(0xFF1F3A68);

class _ErsKutu {
  const _ErsKutu(this.baslik, {this.maddeler = const [], required this.renk, this.koyu = false, this.anket = true});
  final String baslik;
  final List<String> maddeler;
  final Color renk;
  final bool koyu;

  /// ARMS Faz II anketinde 2019'a kadar toplanan kalem (kırmızı noktalı çerçeve).
  final bool anket;
}

const _ersSutunlar = [
  ('Veri ve veri toplama', [
    _ErsKutu('Verim monitörleri', renk: Color(0xFFD4E9E6)),
    _ErsKutu('Toprak izleme', maddeler: ['Karot örnekleri', 'Yakın algılama'], renk: Color(0xFFB5DAD5)),
    _ErsKutu('Diğer veri toplama yöntemleri',
        maddeler: ['Uydu, hava ve dron görüntüleri', 'Ürün durumu sensörleri'], renk: Color(0xFF97CBC4)),
    _ErsKutu('Diğer veri toplama yöntemleri',
        maddeler: ['Elle ya da otomatik tarla taraması', 'Su sayaçları ve sensörler'], renk: Color(0xFF97CBC4), anket: false),
    _ErsKutu('Diğer tarla verileri',
        maddeler: ['Topoğrafya', 'Geniş ölçekli toprak etütleri', 'Sıcaklık, yağış, rüzgâr ve diğer hava verileri'],
        renk: Color(0xFF5FA8A0), koyu: true, anket: false),
  ]),
  ('Karar destek (KD)', [
    _ErsKutu('Verim haritaları', renk: Color(0xFFE2EDCF)),
    _ErsKutu('Toprak haritaları', renk: Color(0xFFD0E2B4)),
    _ErsKutu('Yabancı ot ya da diğer zararlı haritaları', renk: Color(0xFFB9D394)),
    _ErsKutu('Kârlılık haritaları', renk: Color(0xFF8DB35E), koyu: true),
    _ErsKutu('Diğer (harita dışı) KD sistemleri',
        maddeler: ['Kamu ya da özel sektörün analizleri ya da ürün yönetimi önerileri'], renk: Color(0xFF4E7F2C), koyu: true),
    _ErsKutu('Diğer (harita dışı) KD sistemleri',
        maddeler: ['Akıllı telefon uygulamaları'], renk: Color(0xFF4E7F2C), koyu: true, anket: false),
  ]),
  ('Veriye dayalı ekipman ve girdi ayarlaması', [
    _ErsKutu('Yönlendirme sistemleri', renk: Color(0xFFF4C987)),
    _ErsKutu('Otomatik bölüm kontrolü', renk: Color(0xFFF4C987)),
    _ErsKutu('Değişken oranlı uygulamalar (DOU)', maddeler: ['Tohum', 'Gübre ve kireç', 'Pestisit'], renk: Color(0xFFF4C987)),
    _ErsKutu('Değişken oranlı uygulamalar (DOU)', maddeler: ['Sulama'], renk: Color(0xFFF4C987), anket: false),
  ]),
];

class YzErsSemasi extends StatelessWidget {
  const YzErsSemasi({super.key, this.genisZorla = false});
  final bool genisZorla;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, kis) {
      final genis = genisZorla || kis.maxWidth >= 640;
      Widget kutu(_ErsKutu k) {
        final metin = k.koyu ? Colors.white : const Color(0xFF1E2A2A);
        final govde = Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(9, 7, 9, 7),
          decoration: BoxDecoration(color: k.renk, borderRadius: BorderRadius.circular(7)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(k.baslik, style: _y(12.5, renk: metin, k: FontWeight.w700)),
            for (final m in k.maddeler) Text('• $m', style: _y(11.5, renk: metin)),
          ]),
        );
        return Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: k.anket ? _kesikli(govde, renk: _ersKirmizi, cizgi: 2.2, bosluk: 2.2, kalinlik: 1.8, yaricap: 7) : govde,
        );
      }

      Widget sutun(int i) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFF22272B), width: 1.2)),
              alignment: Alignment.center,
              child: Text(_ersSutunlar[i].$1, textAlign: TextAlign.center, style: _y(13.5, k: FontWeight.w700)),
            ),
            const SizedBox(height: 10),
            for (final k in _ersSutunlar[i].$2) kutu(k),
          ]);

      Widget not(String m) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Text(m, textAlign: TextAlign.center, style: _y(11.5, renk: const Color(0xFF3A4046))),
          );
      const ok = Icon(Icons.arrow_downward, size: 16, color: Color(0xFF3A4046));
      final lejant = Wrap(spacing: 18, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.redo, size: 18, color: Color(0xFF22272B)),
          const SizedBox(width: 5),
          Flexible(child: Text('Telematik', style: _y(11.5))),
        ]),
        Row(mainAxisSize: MainAxisSize.min, children: [
          _kesikli(const SizedBox(width: 26, height: 14), renk: _ersKirmizi, cizgi: 2.2, bosluk: 2.2, kalinlik: 1.8),
          const SizedBox(width: 6),
          Flexible(child: Text("2019'a kadar ARMS Faz II anketinde toplananlar", style: _y(11.5))),
        ]),
        Row(mainAxisSize: MainAxisSize.min, children: [
          _kesikli(const SizedBox(width: 26, height: 14), renk: _ersMavi, cizgi: 6, bosluk: 4, kalinlik: 1.8),
          const SizedBox(width: 6),
          Flexible(child: Text('Otomatikleştirilebilir', style: _y(11.5))),
        ]),
      ]);

      Widget cerceve(Widget icerik) => _kesikli(
            Padding(padding: const EdgeInsets.all(12), child: icerik),
            renk: _ersMavi,
            cizgi: 7,
            bosluk: 5,
            kalinlik: 2,
          );

      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
          if (genis) ...[
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(child: Column(children: [
                not('Veri kalitesi için dağıtık defter teknolojileri (DLT) ve/veya veri temizleme algoritmaları'),
                ok,
              ])),
              const SizedBox(width: 26),
              Expanded(
                flex: 2,
                child: Column(children: [
                  not('Girdi izlenebilirliği için dağıtık defter teknolojileri (DLT)'),
                  const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [ok, ok]),
                ]),
              ),
            ]),
            const SizedBox(height: 4),
            cerceve(Column(mainAxisSize: MainAxisSize.min, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: sutun(0)),
                const SizedBox(width: 26, child: Padding(padding: EdgeInsets.only(top: 60), child: _AkisOku())),
                Expanded(child: sutun(1)),
                const SizedBox(width: 26, child: Padding(padding: EdgeInsets.only(top: 60), child: _AkisOku())),
                Expanded(child: sutun(2)),
              ]),
              const SizedBox(height: 4),
              // Telematik: tarla verisinden karar desteğe ve ekipmana.
              const SizedBox(height: 34, width: double.infinity, child: CustomPaint(painter: _TelematikCizer())),
            ])),
          ] else ...[
            not('Veri kalitesi ve girdi izlenebilirliği için dağıtık defter teknolojileri (DLT), veri temizleme algoritmaları'),
            const SizedBox(height: 4),
            cerceve(Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
              sutun(0),
              const Center(child: Icon(Icons.arrow_downward, color: Color(0xFF3A4046))),
              const SizedBox(height: 6),
              sutun(1),
              const Center(child: Icon(Icons.arrow_downward, color: Color(0xFF3A4046))),
              const SizedBox(height: 6),
              sutun(2),
            ])),
          ],
          const SizedBox(height: 12),
          lejant,
        ]),
      );
    });
  }
}

/// Sütunlar arasında soldan sağa akış: birkaç ince ok.
class _AkisOku extends StatelessWidget {
  const _AkisOku();

  @override
  Widget build(BuildContext context) =>
      const SizedBox(height: 260, child: CustomPaint(painter: _AkisCizer()));
}

class _AkisCizer extends CustomPainter {
  const _AkisCizer();

  @override
  void paint(Canvas c, Size s) {
    final kalem = Paint()
      ..color = const Color(0xFF6E9C8F)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 6; i++) {
      final y1 = s.height * (0.06 + i * 0.17);
      final y2 = s.height * (0.10 + ((i * 3) % 6) * 0.15);
      final a = Offset(1, y1), b = Offset(s.width - 2, y2);
      c.drawLine(a, b, kalem);
      final d = (b - a) / (b - a).distance;
      final n = Offset(-d.dy, d.dx);
      c.drawLine(b, b - d * 6 + n * 3.5, kalem);
      c.drawLine(b, b - d * 6 - n * 3.5, kalem);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _TelematikCizer extends CustomPainter {
  const _TelematikCizer();

  @override
  void paint(Canvas c, Size s) {
    final kalem = Paint()
      ..color = const Color(0xFF22272B)
      ..strokeWidth = 2.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final bas = Offset(s.width * 0.16, 2);
    for (final hedef in [Offset(s.width * 0.5, 2), Offset(s.width * 0.84, 2)]) {
      final yol = Path()
        ..moveTo(bas.dx, bas.dy)
        ..quadraticBezierTo((bas.dx + hedef.dx) / 2, s.height * 1.9, hedef.dx, hedef.dy + 6);
      c.drawPath(yol, kalem);
      c.drawLine(hedef + const Offset(0, 6), hedef + const Offset(-7, 14), kalem);
      c.drawLine(hedef + const Offset(0, 6), hedef + const Offset(7, 14), kalem);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ═════════════════════════════════════════════════════════════════════════
//  CEMA — bir çiftliğin dijital ağı
// ═════════════════════════════════════════════════════════════════════════

const _cemaYesil = Color(0xFF1E9A3A);
const _cemaGri = Color(0xFF9EA2A6);
const _cemaMavi = Color(0xFFC9DBF0);

class YzCemaSemasi extends StatelessWidget {
  const YzCemaSemasi({super.key, this.genisZorla = false});
  final bool genisZorla;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, kis) {
      if (genisZorla || kis.maxWidth >= 600) {
        return const AspectRatio(
          aspectRatio: 900 / 560,
          child: FittedBox(fit: BoxFit.contain, child: SizedBox(width: 900, height: 560, child: _CemaGenis())),
        );
      }
      return const _CemaDar();
    });
  }
}

Widget _kutuC(String m, Color renk, {double boy = 15, double? genislik}) => Container(
      width: genislik,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      color: renk,
      alignment: Alignment.center,
      child: Text(m, textAlign: TextAlign.center, style: _y(boy, renk: Colors.white, k: FontWeight.w700)),
    );

class _CemaGenis extends StatelessWidget {
  const _CemaGenis();

  @override
  Widget build(BuildContext context) {
    // Yükseklik sabit değil, en az: yazı tipi ya da boyut değişse de taşmaz.
    Widget yer(double x, double y, Widget w, {double? gen, double? yuk}) => Positioned(
        left: x,
        top: y,
        width: gen,
        child: yuk == null ? w : ConstrainedBox(constraints: BoxConstraints(minHeight: yuk), child: w));
    Widget elips(String baslik, {String? alt, bool veri = true}) => Container(
          decoration: const ShapeDecoration(color: _cemaMavi, shape: StadiumBorder()),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(baslik, style: _y(16.5, k: FontWeight.w700)),
            if (alt != null) Text(alt, textAlign: TextAlign.center, style: _y(12.5)),
            if (veri) ...[const SizedBox(height: 4), _kutuC('Veri', _cemaYesil, boy: 13)],
          ]),
        );
    return Container(
      color: Colors.white,
      child: Stack(children: [
        const Positioned.fill(child: CustomPaint(painter: _CemaCizer())),
        // iş ortakları
        yer(230, 16, _kutuC('Müşteri', _cemaGri, boy: 14), gen: 110),
        yer(190, 62, _kutuC('Tedarikçi', _cemaGri, boy: 14), gen: 120),
        yer(150, 108, _kutuC('Danışman', _cemaGri, boy: 14), gen: 120),
        yer(110, 154, _kutuC('Resmî kurum', _cemaGri, boy: 14), gen: 130),
        yer(20, 270, _kutuC('Makine üreticisi', _cemaGri, boy: 14), gen: 150),
        yer(20, 350, _kutuC('Bayi', _cemaGri, boy: 14), gen: 110),
        yer(205, 315, _kutuC('Yüklenici', _cemaGri, boy: 14), gen: 120),
        // veri portalları
        yer(395, 70, elips('Veri portalı A', alt: 'Yazılım hizmetleri'), gen: 250, yuk: 120),
        yer(640, 16, elips('Veri portalı C', alt: 'Bilgi ve hizmetler (hava, toprak, malzeme…)', veri: false),
            gen: 240, yuk: 92),
        yer(650, 196, elips('Veri portalı B'), gen: 200, yuk: 92),
        // çiftlik, mobil birim, GPS
        yer(430, 300, _kutuC('Çiftlik', _cemaYesil, boy: 22), gen: 160, yuk: 78),
        yer(620, 318, _kutuC('Mobil birim', _cemaYesil, boy: 12.5), gen: 96),
        yer(800, 298, _kutuC('GPS', _cemaGri, boy: 14), gen: 70),
        // makineler
        yer(300, 420, _kutuC('Traktör', _cemaYesil, boy: 14), gen: 118, yuk: 58),
        yer(432, 420, _kutuC('Ekipman', _cemaYesil, boy: 14), gen: 118, yuk: 58),
        yer(564, 420, _kutuC('Hasat makinesi', _cemaYesil, boy: 14), gen: 118, yuk: 58),
        yer(696, 420, _kutuC('Sağım, soğutma ve yemleme ekipmanı', _cemaYesil, boy: 12.5), gen: 160, yuk: 58),
        yer(452, 516, Text('ISOBUS', style: _y(13.5, k: FontWeight.w600))),
      ]),
    );
  }
}

class _CemaCizer extends CustomPainter {
  const _CemaCizer();

  @override
  void paint(Canvas c, Size s) {
    final kesik = Paint()
      ..color = _cemaYesil
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    final gri = Paint()
      ..color = _cemaGri
      ..strokeWidth = 1.3;
    final kalin = Paint()
      ..color = _cemaYesil
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    void kesikli(Offset a, Offset b) {
      final d = b - a;
      final boy = d.distance;
      for (var t = 0.0; t < boy; t += 10) {
        c.drawLine(a + d * (t / boy), a + d * (math.min(t + 6, boy) / boy), kesik);
      }
      final u = d / boy, n = Offset(-u.dy, u.dx);
      c.drawLine(b, b - u * 9 + n * 5, kesik);
      c.drawLine(b, b - u * 9 - n * 5, kesik);
    }

    const veriA = Offset(520, 160);
    for (final h in const [
      Offset(340, 34), Offset(310, 80), Offset(270, 126), Offset(240, 172), // ortaklar
      Offset(170, 288), Offset(130, 362), Offset(265, 330), // üretici, bayi, yüklenici
      Offset(359, 420), Offset(491, 420), Offset(623, 420), Offset(776, 420), // makineler
      Offset(668, 318), // mobil birim
    ]) {
      kesikli(veriA, h);
    }
    // portal B ile mobil birim, portal A ile C
    kesikli(const Offset(750, 270), const Offset(690, 318));
    c.drawLine(const Offset(640, 120), const Offset(680, 100), Paint()
      ..color = const Color(0xFF6C8FBF)
      ..strokeWidth = 1.5);
    // çiftlik ↔ veri portalı A
    c.drawLine(const Offset(510, 188), const Offset(510, 298), kalin);
    c.drawLine(const Offset(510, 188), const Offset(500, 202), kalin);
    c.drawLine(const Offset(510, 188), const Offset(520, 202), kalin);
    c.drawLine(const Offset(510, 298), const Offset(500, 284), kalin);
    c.drawLine(const Offset(510, 298), const Offset(520, 284), kalin);
    // GPS → makineler ve mobil birim
    for (final h in const [Offset(359, 420), Offset(623, 420), Offset(776, 420), Offset(716, 330)]) {
      c.drawLine(const Offset(835, 330), h, gri);
    }
    // ISOBUS: traktör ile hasat makinesi arası kavis
    final isobus = Paint()
      ..color = _cemaYesil
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final yol = Path()
      ..moveTo(359, 480)
      ..quadraticBezierTo(491, 560, 623, 480);
    c.drawPath(yol, isobus);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _CemaDar extends StatelessWidget {
  const _CemaDar();

  @override
  Widget build(BuildContext context) {
    Widget grup(String baslik, List<String> ogeler, Color renk) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: _y(13, k: FontWeight.w700, renk: const Color(0xFF3A4046))),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 6, children: [for (final o in ogeler) _kutuC(o, renk, boy: 12.5)]),
          ],
        );
    Widget portal(String ad, String alt) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: const ShapeDecoration(color: _cemaMavi, shape: StadiumBorder()),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(ad, style: _y(13.5, k: FontWeight.w700)),
            Text(alt, textAlign: TextAlign.center, style: _y(11.5)),
          ]),
        );
    const asagi = Center(child: Icon(Icons.swap_vert, color: _cemaYesil, size: 26));
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
          portal('Veri portalı A', 'veri · yazılım hizmetleri'),
          portal('Veri portalı B', 'veri'),
          portal('Veri portalı C', 'bilgi ve hizmetler (hava, toprak, malzeme…)'),
        ]),
        asagi,
        Center(child: _kutuC('Çiftlik', _cemaYesil, boy: 18, genislik: 160)),
        const SizedBox(height: 14),
        grup('İş ortakları (veri portalı A üzerinden)',
            ['Müşteri', 'Tedarikçi', 'Danışman', 'Resmî kurum', 'Makine üreticisi', 'Bayi', 'Yüklenici'], _cemaGri),
        const SizedBox(height: 14),
        grup('Makineler (ISOBUS ile birbirine bağlı, konumu GPS\'ten)',
            ['Traktör', 'Ekipman', 'Hasat makinesi', 'Sağım, soğutma ve yemleme ekipmanı', 'Mobil birim'], _cemaYesil),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
//  FarmerChat — etkileşim akışı
// ═════════════════════════════════════════════════════════════════════════

const _fcYesil = Color(0xFF1F9F6A);
const _fcGri = Color(0xFFEFF1F2);

class YzFarmerChatSemasi extends StatelessWidget {
  const YzFarmerChatSemasi({super.key, this.genisZorla = false});
  final bool genisZorla;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, kis) {
      final uc = genisZorla || kis.maxWidth >= 600;
      final sutunlar = [
        const _FcSutun('KATILIM', [
          _FcKart('Karşılama ve Telegram botu bağlantısı', [
            _Bot("Farmer.Chat'e hoş geldiniz! Bütün tarım ihtiyaçlarınızda size yardım etmek için buradayız. Sohbete başlamak için bağlantıya dokunun!"),
            _Secenekler(['Bağlantı: Farmer.Chat Telegram'], yesil: true),
          ]),
          _FcKart('Bot nasıl kullanılır?', [
            _Bot('Sorunuzu yazmanız ya da sesli mesaj kaydetmeniz yeterli.'),
          ]),
          _FcKart('Dil seçimi', [
            _Bot('Lütfen tercih ettiğiniz dili seçin.'),
            _Secenekler(['İngilizce', 'Svahili', 'Hintçe', 'Diğer']),
          ]),
          _FcKart('Değer zinciri seçimi', [
            _Bot('Kullanıcının tarımın hangi alanında yardım istediği (ör. ürün yönetimi, makine vb.)'),
            _Secenekler(['Ürün yönetimi', 'Hayvancılık yönetimi', 'Vb.']),
          ]),
        ]),
        const _FcSutun('BOTLA ETKİLEŞİM', [
          _FcKart('Sohbetin başlaması', [
            _Kullanici('Ürünlerimi zararlılardan nasıl korurum?'),
            _Ara('Yanıt üretiliyor…'),
            _Bot('Ürünlerinizi neem yağı gibi organik ilaçlarla zararlılardan koruyabilirsiniz.', vurgu: true),
            _Video(),
          ]),
          _FcKart('Takip soruları', [
            _Bot('Ne tür bir zararlıyla uğraşıyorsunuz?', vurgu: true),
            _Ara('Takip soruları üretildi'),
            _Kullanici('Kullanıcı yanıt veriyor, etkileşim sürüyor…'),
            _Ara('Kullanıcının takip soruları'),
            _Kullanici('Sohbete dayanarak başka bir soru soruyor'),
            _Ara('Yanıt üretiliyor…'),
            _Bot('Takip sorusuna daha ayrıntılı tavsiyeyle yanıt veriyor.', koyu: true),
          ]),
        ]),
        const _FcSutun('SÜREN ETKİLEŞİM', [
          _FcKart('Sohbetin sonu', [
            _Kullanici('Sohbetin bittiğini belirtiyor (ör. "Bugünlük bu kadar, teşekkürler!").', ince: true),
            _Bot("Farmer.Chat'i kullandığınız için teşekkürler! Umarız bugün size yardımcı olabilmişizdir.", vurgu: true),
          ]),
          _FcKart('Ayrıntılı geri bildirim', [
            _Bot('Kullanıcı ayrıntılı geri bildirimi seçerse bot 1-5 arası bir puan ya da serbest giriş (metin, ses ya da görüntü) istiyor.', koyu: true),
            _GeriBildirim(),
            _Kullanici('Kısa bir etkileşimle geri bildirim veriyor.'),
          ]),
          _FcKart('Süren etkileşim ve hatırlatmalar', [
            _Bot('Belirli aralıklarla bildirim ya da hatırlatma gönderiyor (ör. "Yaklaşan muson mevsimi için daha fazla tavsiye ister misiniz?" ya da "Yeni ürün danışmanlığı özelliklerimize göz atın").', koyu: true),
            _Kullanici('Yeni sorular sormak ya da başka özellikleri keşfetmek için geri dönüyor.', ince: true),
          ]),
        ]),
      ];
      return Container(
        color: const Color(0xFFF8F9F8),
        padding: const EdgeInsets.all(12),
        child: uc
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: sutunlar[0]),
                const SizedBox(width: 10),
                Expanded(child: sutunlar[1]),
                const SizedBox(width: 10),
                Expanded(child: sutunlar[2]),
              ])
            : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                sutunlar[0],
                const SizedBox(height: 12),
                sutunlar[1],
                const SizedBox(height: 12),
                sutunlar[2],
              ]),
      );
    });
  }
}

class _FcSutun extends StatelessWidget {
  const _FcSutun(this.baslik, this.kartlar);
  final String baslik;
  final List<Widget> kartlar;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(
          height: 34,
          child: CustomPaint(
            painter: const _Ok(),
            child: Center(
              child: Text(baslik, style: _y(12, renk: Colors.white, k: FontWeight.w700, aralik: 2.6)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        for (final k in kartlar) ...[k, const SizedBox(height: 10)],
      ]);
}

/// Sütun başlığının şerit oku (sağa bakan köşeli bant).
class _Ok extends CustomPainter {
  const _Ok();

  @override
  void paint(Canvas c, Size s) {
    final u = s.height * 0.42;
    final yol = Path()
      ..moveTo(0, 0)
      ..lineTo(s.width - u, 0)
      ..lineTo(s.width, s.height / 2)
      ..lineTo(s.width - u, s.height)
      ..lineTo(0, s.height)
      ..lineTo(u * 0.8, s.height / 2)
      ..close();
    c.drawPath(yol, Paint()..color = _fcYesil);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _FcKart extends StatelessWidget {
  const _FcKart(this.baslik, this.satirlar);
  final String baslik;
  final List<Widget> satirlar;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            color: _fcGri,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Text(baslik, textAlign: TextAlign.center, style: _y(13.5, k: FontWeight.w600)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (var i = 0; i < satirlar.length; i++) ...[if (i > 0) const SizedBox(height: 8), satirlar[i]],
            ]),
          ),
        ]),
      );
}

Widget _simge({required bool bot}) => Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(color: bot ? _fcYesil : const Color(0xFFB9C3CC), shape: BoxShape.circle),
      child: Icon(bot ? Icons.forum_outlined : Icons.person, size: 14, color: Colors.white),
    );

class _Bot extends StatelessWidget {
  const _Bot(this.metin, {this.vurgu = false, this.koyu = false});
  final String metin;
  final bool vurgu;
  final bool koyu;

  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _simge(bot: true),
        const SizedBox(width: 8),
        Expanded(
          child: Text(metin,
              style: vurgu
                  ? _y(12.5, renk: _fcYesil, k: FontWeight.w700, stil: FontStyle.italic)
                  : (koyu ? _y(12, k: FontWeight.w600) : _y(12, renk: const Color(0xFF4A5056), stil: FontStyle.italic))),
        ),
      ]);
}

class _Kullanici extends StatelessWidget {
  const _Kullanici(this.metin, {this.ince = false});
  final String metin;
  final bool ince;

  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _simge(bot: false),
        const SizedBox(width: 8),
        Expanded(
          child: Text(metin,
              style: ince ? _y(12, k: FontWeight.w600) : _y(12.5, k: FontWeight.w700, stil: FontStyle.italic)),
        ),
      ]);
}

class _Ara extends StatelessWidget {
  const _Ara(this.metin);
  final String metin;

  @override
  Widget build(BuildContext context) => Column(children: [
        const Icon(Icons.south, size: 14, color: Color(0xFF6B7278)),
        Text(metin, textAlign: TextAlign.center, style: _y(11.5, renk: const Color(0xFF6B7278), stil: FontStyle.italic)),
        const Icon(Icons.south, size: 14, color: Color(0xFF6B7278)),
      ]);
}

class _Secenekler extends StatelessWidget {
  const _Secenekler(this.ogeler, {this.yesil = false});
  final List<String> ogeler;
  final bool yesil;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (var i = 0; i < ogeler.length; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 5),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: BoxDecoration(color: _fcGri, borderRadius: BorderRadius.circular(5)),
              child: Row(children: [
                Expanded(
                  child: Text(ogeler[i],
                      textAlign: TextAlign.center,
                      style: _y(11.5, renk: yesil ? _fcYesil : const Color(0xFF3A4046), stil: yesil ? FontStyle.italic : null)),
                ),
                if (i == 0) const Icon(Icons.touch_app, size: 14, color: Color(0xFFF2A33A)),
              ]),
            ),
        ]),
      );
}

class _Video extends StatelessWidget {
  const _Video();

  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 52,
          height: 40,
          decoration: BoxDecoration(color: const Color(0xFFE9EEF5), borderRadius: BorderRadius.circular(4)),
          child: const Icon(Icons.play_circle_fill, color: Color(0xFFE5534B), size: 24),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Daha fazla bilgi ve iyi uygulamalar için bu videoya göz atın.',
                style: _y(11.5, renk: _fcYesil, k: FontWeight.w600, stil: FontStyle.italic)),
            const SizedBox(height: 4),
            const Row(children: [
              Icon(Icons.volume_up, size: 14, color: Color(0xFF6B7278)),
              SizedBox(width: 6),
              Icon(Icons.thumb_up_alt_outlined, size: 14, color: Color(0xFF6B7278)),
              SizedBox(width: 6),
              Icon(Icons.thumb_down_alt_outlined, size: 14, color: Color(0xFF6B7278)),
            ]),
          ]),
        ),
      ]);
}

class _GeriBildirim extends StatelessWidget {
  const _GeriBildirim();

  @override
  Widget build(BuildContext context) {
    Widget cip(String m) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(border: Border.all(color: const Color(0xFF4A5056)), borderRadius: BorderRadius.circular(14)),
          child: Text(m, style: _y(10.5, k: FontWeight.w600)),
        );
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: const Color(0xFFF7F8F9), borderRadius: BorderRadius.circular(6)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Bu yanıtı nasıl puanlarsınız?', style: _y(11, k: FontWeight.w600)),
        const SizedBox(height: 4),
        Row(children: [
          for (var i = 0; i < 5; i++) const Icon(Icons.star, color: Color(0xFFF5B301), size: 18),
        ]),
        const SizedBox(height: 6),
        Text('Bir ya da daha fazla sorun seçin', style: _y(10.5, k: FontWeight.w600)),
        const SizedBox(height: 5),
        Wrap(spacing: 5, runSpacing: 5, children: [
          cip('Yanlış bilgi'),
          cip('Eksik içerik'),
          cip('İlgili yanıt yok'),
          cip('Zorluk düzeyi'),
          cip('Diğer'),
        ]),
        const SizedBox(height: 6),
        Text('Ayrıntı ekleyin (isteğe bağlı)', style: _y(10.5, k: FontWeight.w600)),
        const SizedBox(height: 4),
        Container(
          height: 34,
          width: double.infinity,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFC8CDD2))),
          child: Text('Geri bildiriminizi buraya yazın', style: _y(10.5, renk: const Color(0xFF9AA1A7))),
        ),
      ]),
    );
  }
}
