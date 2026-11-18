import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ECMWF'nin yapay zekâ tahmin sistemi AIFS'i anlatan bilgi şemasının
/// Türkçe uyarlaması (özgünü CC BY 4.0; §1'deki görsel `b01-ecmwf-…`).
///
/// Özgün şemanın teması ve akışı korunuyor: lacivert zemin, dört adım
/// (gözlem → özümseme → model → tahmin), tel kafes küreler, altta eğitim
/// döngüsü. Metinler özgün şemanın kendi metinlerinin çevirisi; yeni bir
/// bilgi eklenmiyor. Geniş ekranda özgün düzen (1000×700 tuvalde çizilip
/// sığdırılıyor), dar ekranda adımlar alt alta — yazı telefonda da okunuyor.
/// İngilizce sayfada özgün görsel gösteriliyor (yz_gorsel.dart).
class YzAifsSemasi extends StatelessWidget {
  const YzAifsSemasi({super.key, this.genisZorla = false});

  /// Büyütme penceresinde dar ekranda da geniş düzen.
  final bool genisZorla;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, kis) {
      if (genisZorla || kis.maxWidth >= 640) {
        return const AspectRatio(
          aspectRatio: 1000 / 700,
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(width: 1000, height: 700, child: _Genis()),
          ),
        );
      }
      return const _Dar();
    });
  }
}

// ── renkler ──────────────────────────────────────────────────────────────
const _zemin1 = Color(0xFF10163A);
const _zemin2 = Color(0xFF1A2152);
const _kutu = Color(0xFF283166);
const _beyaz = Color(0xFFF2F4FA);
const _soluk = Color(0xFFB4BDD8);
const _cizgi = Color(0xFF9AA6D4);
const _turkuaz = Color(0xFF63D2C3);
const _pembe = Color(0xFFE8709F);

TextStyle _yazi(double boy, {Color renk = _beyaz, FontWeight kalinlik = FontWeight.w400, double aralik = 0}) =>
    GoogleFonts.outfit(fontSize: boy, color: renk, fontWeight: kalinlik, height: 1.32, letterSpacing: aralik);

/// "**kalın**" işaretli kısa metni zengin metne çevirir.
TextSpan _zengin(String metin, TextStyle stil) {
  final parcalar = <TextSpan>[];
  final kaliplar = metin.split('**');
  for (var i = 0; i < kaliplar.length; i++) {
    parcalar.add(TextSpan(
        text: kaliplar[i], style: i.isOdd ? stil.copyWith(fontWeight: FontWeight.w700) : stil));
  }
  return TextSpan(children: parcalar);
}

const _adimlar = [
  ('1. Gözlem', "Her gün Dünya'nın atmosferine, rüzgârına, sıcaklığına ve daha fazlasına dair **800 milyon** gözlem toplanıyor"),
  ('2. Özümseme', "Kalite denetiminden geçen **60 milyon** gözlem, fizik tabanlı Bütünleşik Tahmin Sistemi'ne özümseniyor"),
  ('3. Model', "Bu gözlemler **AIFS**'in yeni yapay zekâ modelini besliyor; model Dünya'nın önümüzdeki günlerdeki havasını tahmin ediyor"),
  ('4. Tahmin', '**Şimdi: AIFS Single**, tek seferde tek tahmin'),
];
const _siradaki = '**Sırada: AIFS ENS**, 50 tahmin senaryosu için topluluk modellemesi';
const _egitimBaslik = 'Yapay zekâ modeli nasıl eğitiliyor';
const _egitim =
    "Dünya'nın saatlik havasının **veri arşivi**, 1979'dan bugüne verilerle yapay zekâ modelini besleyen bir eğitim döngüsü kuruyor";
const _duzeltme = 'Yapay zekâ modeli doğruluğu artırmak için hatalarını tekrar tekrar denetleyip düzeltiyor';

BoxDecoration get _zeminSusu => const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_zemin1, _zemin2],
      ),
    );

/// Geniş düzen: özgün şemanın yerleşimi, 1000×700 tuvalde.
class _Genis extends StatelessWidget {
  const _Genis();

  @override
  Widget build(BuildContext context) {
    const sutunX = [28.0, 268.0, 508.0, 748.0];
    Widget metin(double x, double y, double w, String m, {double boy = 16, TextAlign hiza = TextAlign.center, Color renk = _beyaz}) =>
        Positioned(
          left: x,
          top: y,
          width: w,
          child: Text.rich(_zengin(m, _yazi(boy, renk: renk)), textAlign: hiza),
        );
    Widget simge(double cx, double cy, IconData ikon, {double r = 24}) => Positioned(
          left: cx - r,
          top: cy - r,
          width: r * 2,
          height: r * 2,
          child: Icon(ikon, color: _beyaz.withValues(alpha: 0.92), size: r * 0.95),
        );
    return DecoratedBox(
      decoration: _zeminSusu,
      child: Stack(children: [
        const Positioned.fill(child: CustomPaint(painter: _GenisCizer())),
        Positioned(
          left: 28,
          top: 26,
          child: Text('YAPAY ZEKÂ TAHMİN SİSTEMİ (AIFS)', style: _yazi(23, aralik: 3.2, kalinlik: FontWeight.w500)),
        ),
        Positioned(
          right: 28,
          top: 24,
          child: Text('ECMWF', style: _yazi(26, kalinlik: FontWeight.w800, aralik: 0.5)),
        ),
        for (var i = 0; i < 4; i++) ...[
          Positioned(
            left: sutunX[i],
            top: 86,
            width: 224,
            height: 42,
            child: Container(
              color: _kutu,
              alignment: Alignment.center,
              child: Text(_adimlar[i].$1, style: _yazi(17, kalinlik: FontWeight.w700)),
            ),
          ),
          metin(sutunX[i] + 2, 142, 220, _adimlar[i].$2, boy: 15.5),
        ],
        // 1 · gözlem simgeleri (küre çizerde)
        simge(80, 292, Icons.satellite_alt),
        simge(84, 392, Icons.settings_input_antenna),
        simge(212, 392, Icons.flight),
        // 2 · özümseme
        simge(338, 316, Icons.thermostat, r: 30),
        simge(430, 316, Icons.air, r: 30),
        simge(384, 378, Icons.cloud, r: 30),
        // 4 · sıradaki: topluluk
        metin(760, 398, 210, _siradaki, boy: 15.5),
        // eğitim döngüsü
        Positioned(
          left: 28,
          top: 432,
          width: 470,
          child: Text(_egitimBaslik, textAlign: TextAlign.center, style: _yazi(17, kalinlik: FontWeight.w700)),
        ),
        metin(28, 458, 470, _egitim, boy: 15),
        Positioned(left: 34, top: 600, child: Text('1979', style: _yazi(13, renk: _turkuaz, kalinlik: FontWeight.w600))),
        Positioned(left: 196, top: 600, child: Text('2025', style: _yazi(13, renk: _turkuaz, kalinlik: FontWeight.w600))),
        metin(222, 594, 186, _duzeltme, boy: 14.5),
      ]),
    );
  }
}

/// Dar düzen: adımlar alt alta.
class _Dar extends StatelessWidget {
  const _Dar();

  @override
  Widget build(BuildContext context) {
    Widget adim(int i, Widget resim) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
              color: _kutu,
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              child: Text(_adimlar[i].$1, style: _yazi(16, kalinlik: FontWeight.w700)),
            ),
            const SizedBox(height: 10),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              SizedBox(width: 78, height: 78, child: resim),
              const SizedBox(width: 12),
              Expanded(child: Text.rich(_zengin(_adimlar[i].$2, _yazi(15)))),
            ]),
          ]),
        );
    return DecoratedBox(
      decoration: _zeminSusu,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(
              child: Text('YAPAY ZEKÂ TAHMİN SİSTEMİ (AIFS)', style: _yazi(15, aralik: 1.6, kalinlik: FontWeight.w500)),
            ),
            Text('ECMWF', style: _yazi(17, kalinlik: FontWeight.w800)),
          ]),
          const SizedBox(height: 16),
          adim(0, const CustomPaint(painter: _KureCizer(tur: _Kure.tel))),
          adim(1, const Icon(Icons.thermostat, color: _beyaz, size: 40)),
          adim(2, const CustomPaint(painter: _KureCizer(tur: _Kure.nokta))),
          adim(3, const CustomPaint(painter: _KureCizer(tur: _Kure.tel))),
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            const SizedBox(width: 78, height: 78, child: CustomPaint(painter: _ToplulukCizer(sutun: 5, satir: 5))),
            const SizedBox(width: 12),
            Expanded(child: Text.rich(_zengin(_siradaki, _yazi(15)))),
          ]),
          const SizedBox(height: 18),
          Container(height: 1, color: _cizgi.withValues(alpha: 0.35)),
          const SizedBox(height: 14),
          Text(_egitimBaslik, style: _yazi(16, kalinlik: FontWeight.w700)),
          const SizedBox(height: 6),
          Text.rich(_zengin(_egitim, _yazi(15))),
          const SizedBox(height: 10),
          const SizedBox(height: 46, child: CustomPaint(painter: _ArsivCizer())),
          Row(children: [
            Text('1979', style: _yazi(12.5, renk: _turkuaz, kalinlik: FontWeight.w600)),
            const Spacer(),
            Text('2025', style: _yazi(12.5, renk: _turkuaz, kalinlik: FontWeight.w600)),
          ]),
          const SizedBox(height: 10),
          Text(_duzeltme, style: _yazi(14.5, renk: _soluk)),
        ]),
      ),
    );
  }
}

// ── çizerler ─────────────────────────────────────────────────────────────

/// Tel kafes küre: koyu dolgu, boylam elipsleri, enlem çizgileri.
void _telKure(Canvas c, Offset m, double r) {
  c.drawCircle(
    m,
    r,
    Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.35, -0.35),
        colors: [Color(0xFF5A6488), Color(0xFF232B52)],
      ).createShader(Rect.fromCircle(center: m, radius: r)),
  );
  final kalem = Paint()
    ..color = _cizgi.withValues(alpha: 0.65)
    ..style = PaintingStyle.stroke
    ..strokeWidth = r > 30 ? 1.1 : 0.8;
  c.save();
  c.clipPath(Path()..addOval(Rect.fromCircle(center: m, radius: r)));
  for (final f in const [0.32, 0.68, 1.0]) {
    c.drawOval(Rect.fromCenter(center: m, width: 2 * r * f, height: 2 * r), kalem);
  }
  for (final t in const [-0.66, -0.33, 0.0, 0.33, 0.66]) {
    final y = m.dy + r * t;
    final yarim = r * math.sqrt(1 - t * t);
    c.drawLine(Offset(m.dx - yarim, y), Offset(m.dx + yarim, y), kalem);
  }
  c.restore();
  c.drawCircle(m, r, kalem..color = _cizgi.withValues(alpha: 0.85));
}

/// Yapay zekâ modeli: noktalardan küre, bazı düğümler pembe.
void _noktaKure(Canvas c, Offset m, double r) {
  final beyaz = Paint()..color = _beyaz;
  final pembe = Paint()..color = _pembe;
  final ag = Paint()
    ..color = _pembe.withValues(alpha: 0.35)
    ..strokeWidth = 0.7;
  const egim = -0.35;
  final onceki = <Offset>[];
  for (var enlem = -75; enlem <= 75; enlem += 15) {
    final la = enlem * math.pi / 180;
    for (var boylam = 0; boylam < 360; boylam += 18) {
      final lo = boylam * math.pi / 180;
      final x = math.cos(la) * math.sin(lo);
      final y0 = math.sin(la);
      final z0 = math.cos(la) * math.cos(lo);
      final y = y0 * math.cos(egim) - z0 * math.sin(egim);
      final z = y0 * math.sin(egim) + z0 * math.cos(egim);
      if (z < -0.15) continue;
      final p = Offset(m.dx + x * r, m.dy - y * r);
      final secili = (enlem ~/ 15 + boylam ~/ 18) % 4 == 0;
      c.drawCircle(p, (secili ? 2.6 : 1.9) * (0.65 + 0.35 * z), secili ? pembe : (beyaz..color = _beyaz.withValues(alpha: 0.45 + 0.55 * z)));
      if (secili && onceki.isNotEmpty && (onceki.last - p).distance < r * 0.5) c.drawLine(onceki.last, p, ag);
      if (secili) onceki.add(p);
    }
  }
  // dış halka: pembe noktalı çember
  final halka = Paint()..color = _pembe.withValues(alpha: 0.75);
  for (var a = 0.0; a < 2 * math.pi; a += 2 * math.pi / 72) {
    c.drawCircle(Offset(m.dx + (r + 10) * math.cos(a), m.dy + (r + 10) * math.sin(a)), 1.2, halka);
  }
}

/// Ok: düz ya da kavisli (kontrol noktası verilirse), uçta ok başı.
void _ok(Canvas c, Offset a, Offset b, {Offset? kontrol, bool ciftYonlu = false}) {
  final kalem = Paint()
    ..color = _beyaz.withValues(alpha: 0.88)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6
    ..strokeCap = StrokeCap.round;
  final yol = Path()..moveTo(a.dx, a.dy);
  if (kontrol == null) {
    yol.lineTo(b.dx, b.dy);
  } else {
    yol.quadraticBezierTo(kontrol.dx, kontrol.dy, b.dx, b.dy);
  }
  c.drawPath(yol, kalem);
  void bas(Offset uc, Offset yon) {
    final d = yon / yon.distance;
    final n = Offset(-d.dy, d.dx);
    c.drawLine(uc, uc - d * 9 + n * 5, kalem);
    c.drawLine(uc, uc - d * 9 - n * 5, kalem);
  }

  bas(b, b - (kontrol ?? a));
  if (ciftYonlu) bas(a, a - (kontrol ?? b));
}

void _simgeHalkasi(Canvas c, Offset m, double r) {
  c.drawCircle(m, r, Paint()..color = const Color(0xFF232B52));
  c.drawCircle(
      m,
      r,
      Paint()
        ..color = _cizgi.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1);
}

void _arsiv(Canvas c, Rect alan) {
  final rnd = math.Random(7);
  const sutun = 30;
  final adim = alan.width / sutun;
  for (var i = 0; i < sutun; i++) {
    final boy = 2 + rnd.nextInt(5);
    for (var j = 0; j < boy; j++) {
      final y = alan.center.dy + (j - (boy - 1) / 2) * (alan.height / 7);
      final renk = (i + j) % 5 == 0 ? _pembe : _turkuaz;
      c.drawCircle(Offset(alan.left + adim * (i + 0.5), y), math.min(3.0, adim * 0.3),
          Paint()..color = renk.withValues(alpha: 0.55 + 0.45 * rnd.nextDouble()));
    }
  }
}

void _topluluk(Canvas c, Rect alan, int sutun, int satir) {
  final w = alan.width / sutun, h = alan.height / satir;
  final r = math.min(w, h) * 0.4;
  for (var i = 0; i < sutun; i++) {
    for (var j = 0; j < satir; j++) {
      final m = Offset(alan.left + w * (i + 0.5), alan.top + h * (j + 0.5));
      c.drawCircle(m, r, Paint()..color = const Color(0xFF3A456E));
      c.drawCircle(
          m,
          r,
          Paint()
            ..color = _cizgi.withValues(alpha: 0.7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.7);
      c.drawLine(Offset(m.dx - r, m.dy), Offset(m.dx + r, m.dy), Paint()..color = _cizgi.withValues(alpha: 0.45));
    }
  }
}

class _GenisCizer extends CustomPainter {
  const _GenisCizer();

  @override
  void paint(Canvas c, Size s) {
    // 1 · gözlem: küre ve simge halkaları
    const kure1 = Offset(146, 340);
    for (final p in const [Offset(80, 292), Offset(84, 392), Offset(212, 392)]) {
      c.drawLine(p, kure1, Paint()
        ..color = _cizgi.withValues(alpha: 0.6)
        ..strokeWidth = 1);
      _simgeHalkasi(c, p, 24);
    }
    _telKure(c, kure1, 40);
    _ok(c, const Offset(204, 318), const Offset(290, 318));
    // 2 · özümseme
    for (final p in const [Offset(338, 316), Offset(430, 316), Offset(384, 378)]) {
      _simgeHalkasi(c, p, 30);
    }
    _ok(c, const Offset(474, 318), const Offset(560, 372), kontrol: const Offset(540, 318));
    // 3 · model
    const model = Offset(626, 440);
    _noktaKure(c, model, 64);
    // 4 · tahmin: tek tahmin küresi ve topluluk
    _ok(c, const Offset(690, 380), const Offset(780, 312), kontrol: const Offset(714, 312));
    _telKure(c, const Offset(858, 300), 62);
    _ok(c, const Offset(694, 470), const Offset(780, 520), kontrol: const Offset(730, 520));
    _topluluk(c, const Rect.fromLTWH(800, 470, 120, 210), 5, 10);
    // eğitim döngüsü: arşiv, çift yönlü ok, döngü küresi, modele ok
    _arsiv(c, const Rect.fromLTWH(30, 528, 200, 64));
    _ok(c, const Offset(240, 560), const Offset(330, 560), ciftYonlu: true);
    const dongu = Offset(396, 560);
    _telKure(c, dongu, 34);
    final yay = Paint()
      ..color = _turkuaz.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    c.drawArc(Rect.fromCircle(center: dongu, radius: 46), -2.6, 2.2, false, yay);
    c.drawArc(Rect.fromCircle(center: dongu, radius: 46), 0.55, 2.2, false, yay);
    _ok(c, const Offset(452, 600), const Offset(612, 520), kontrol: const Offset(600, 610));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

enum _Kure { tel, nokta }

class _KureCizer extends CustomPainter {
  const _KureCizer({required this.tur});
  final _Kure tur;

  @override
  void paint(Canvas c, Size s) {
    final m = s.center(Offset.zero);
    final r = math.min(s.width, s.height) / 2 - (tur == _Kure.nokta ? 12 : 3);
    tur == _Kure.tel ? _telKure(c, m, r) : _noktaKure(c, m, r);
  }

  @override
  bool shouldRepaint(covariant _KureCizer old) => old.tur != tur;
}

class _ToplulukCizer extends CustomPainter {
  const _ToplulukCizer({required this.sutun, required this.satir});
  final int sutun, satir;

  @override
  void paint(Canvas c, Size s) => _topluluk(c, Offset.zero & s, sutun, satir);

  @override
  bool shouldRepaint(covariant _ToplulukCizer old) => false;
}

class _ArsivCizer extends CustomPainter {
  const _ArsivCizer();

  @override
  void paint(Canvas c, Size s) => _arsiv(c, Offset.zero & s);

  @override
  bool shouldRepaint(covariant _ArsivCizer old) => false;
}
