import 'dart:async';

import 'package:flutter/material.dart';

import '../uzay_tasarim.dart';

/// ŞEMA — yetiştirme odası, altı parça, adım adım.
///
/// ══ NEDEN ÇİZİM ══════════════════════════════════════════════════════════
/// Üçüncü durak suyun yörüngede nasıl davrandığını ANLATIYOR. Anlatmak
/// yetmiyor: fitilin nerede durduğu, halkanın harcın içinde olduğu, LED'in
/// bitkinin üstünde olduğu ancak çizilince görülüyor. Fotoğraf da
/// göstermiyor — gerçek bir yastığın fotoğrafında fitil görünmez.
///
/// ══ ÇİZİMİN KAYNAĞI OLMAK ZORUNDA ════════════════════════════════════════
/// Bir şema her şeyi söyleyebilir ve kimse sormaz. Kaynağı olmayan bir ok,
/// kaynağı olmayan bir cümleden daha tehlikeli — çünkü cümle sorgulanır,
/// ok sorgulanmaz. Burada çizilen altı parçanın her birinin NASA'nın kendi
/// belgesinde bir cümlesi var ve o cümleler PDF'ten çekilip
/// `data.json`'ın `oda` bloğunda kilitli.
///
/// ══ KENDİ KENDİNE OYNUYOR, SONRA SİZE BIRAKIYOR ══════════════════════════
/// Durak ekranın ortasına gelince şema adımları kendi geçiyor. Okur
/// dokunduğu anda otomatik akış duruyor ve kumanda ona geçiyor. Hiç
/// dokunmayan biri de şemayı baştan sona görmüş oluyor; bir düğmeye
/// basmayı beklemek, çoğu okurun o şemayı hiç görmemesi demek.
class UzaySema extends StatefulWidget {
  final Map<String, dynamic> veri;
  final double ilerleme;
  final bool isEn;

  const UzaySema({
    super.key,
    required this.veri,
    required this.ilerleme,
    required this.isEn,
  });

  @override
  State<UzaySema> createState() => _UzaySemaDurumu();
}

class _UzaySemaDurumu extends State<UzaySema>
    with SingleTickerProviderStateMixin {
  late final List<Map<String, dynamic>> _adimlar =
      (widget.veri['adimlar'] as List).cast<Map<String, dynamic>>();

  int _adim = 0;
  bool _dokunuldu = false;
  bool _basladi = false;
  Timer? _saat;
  late final AnimationController _k = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 760));

  @override
  void initState() {
    super.initState();
    _k.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _saat?.cancel();
    _k.dispose();
    super.dispose();
  }

  void _basla() {
    if (_basladi) return;
    _basladi = true;
    _k.forward(from: 0);
    _saat = Timer.periodic(const Duration(milliseconds: 2600), (t) {
      if (!mounted || _dokunuldu) return t.cancel();
      if (_adim >= _adimlar.length - 1) return t.cancel();
      setState(() => _adim++);
      _k.forward(from: 0);
    });
  }

  void _git(int i) {
    _saat?.cancel();
    setState(() {
      _dokunuldu = true;
      _adim = i.clamp(0, _adimlar.length - 1);
    });
    _k.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ilerleme.abs() < 0.12) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _basla();
      });
    }

    final vurgu = Color(int.parse('${widget.veri['vurgu']}'));
    final isEn = widget.isEn;
    final adim = _adimlar[_adim];
    final gorunurluk = (1 - (widget.ilerleme.abs() / 0.62)).clamp(0.0, 1.0);

    return LayoutBuilder(builder: (context, kis) {
      final dar = UzayKirilma.darMi(kis.maxWidth);
      final yan = dar ? 22.0 : 64.0;

      return Opacity(
        opacity: widget.ilerleme.abs() <= 0.58
            ? 1.0
            : (1 - (widget.ilerleme.abs() - 0.58) / 0.42).clamp(0.0, 1.0),
        child: Padding(
          padding: EdgeInsets.fromLTRB(yan, dar ? 66 : 88, yan, dar ? 30 : 48),
          child: Opacity(
            opacity: gorunurluk,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 20, height: 1.5, color: vurgu),
                    const SizedBox(width: 10),
                    Text('${widget.veri[isEn ? 'zaman_en' : 'zaman_tr']}',
                        style: UzayYazi.ustbaslik(context)
                            .copyWith(color: vurgu)),
                  ],
                ),
                SizedBox(height: dar ? 10 : 14),
                Text('${widget.veri[isEn ? 'baslik_en' : 'baslik_tr']}',
                    style: UzayYazi.bolumBasligi(context)),

                // ── ÇİZİM ──────────────────────────────────────────────
                Expanded(
                  child: GestureDetector(
                    onTap: () => _git(_adim + 1 >= _adimlar.length ? 0 : _adim + 1),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1.35,
                        child: CustomPaint(
                          painter: _OdaBoyaci(
                            adim: _adim,
                            t: Curves.easeOutCubic.transform(_k.value),
                            vurgu: vurgu,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── ADIM ───────────────────────────────────────────────
                SizedBox(height: dar ? 12 : 18),
                Row(
                  children: [
                    for (var i = 0; i < _adimlar.length; i++)
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _git(i),
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 6),
                            // ══ DOKUNMA HEDEFİ ÇİZGİ KADAR DEĞİL ════════
                            // Telefonda etiket gizleniyordu ve geriye iki
                            // piksellik bir çizgi kalıyordu: dokunma hedefi
                            // o kadardı. Canlıda şu şikâyeti aldı — "zor
                            // tıklanıyor, algılaması zayıf."
                            //
                            // Çizginin ince olması TASARIM; dokunağın ince
                            // olması kusur. İkisi ayrıldı: çizgi iki piksel
                            // kaldı, hedef 44 noktaya çıktı. Altındaki boş
                            // alan görünmüyor ama dokunağı yutuyor.
                            child: SizedBox(
                              height: dar ? 44 : 30,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 240),
                                    height: 2,
                                    color: i <= _adim
                                        ? vurgu
                                        : Colors.white.withValues(alpha: 0.16),
                                  ),
                                  const SizedBox(height: 7),
                                  // Telefonda etiket sığmıyor ama SIRA
                                  // NUMARASI sığıyor — ve altı parça gerçek
                                  // bir sıra, yani numara süs değil bilgi.
                                  Text(
                                    dar
                                        ? '${i + 1}'
                                        : '${_adimlar[i][isEn ? 'baslik_en' : 'baslik_tr']}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: UzayYazi.kunye(context).copyWith(
                                        fontSize: dar ? 12 : 11,
                                        color: i <= _adim
                                            ? UzayRenk.metin
                                            : UzayRenk.ikincil),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: dar ? 12 : 16),
                // ÖNCE SÖNSÜN, SONRA BELİRSİN.
                //
                // Varsayılan `AnimatedSwitcher` iki çocuğu AYNI ANDA
                // soluklaştırıp belirtiyor; iki farklı metin aynı yerde
                // üst üste binince çift pozlama gibi görünüyor ve ikisi de
                // okunmuyor. Ekranda görüldü. Aralıklar ayrıldı: eski
                // metin ilk yarıda gidiyor, yenisi ikinci yarıda geliyor.
                //
                // Kutunun en az yüksekliği de sabit: adım notları farklı
                // uzunlukta ve kutu her geçişte zıplıyordu.
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 340),
                  switchOutCurve: const Interval(0, 0.45, curve: Curves.easeIn),
                  switchInCurve: const Interval(0.55, 1, curve: Curves.easeOut),
                  child: ConstrainedBox(
                    key: ValueKey(adim['id']),
                    constraints: BoxConstraints(
                        maxWidth: 760, minHeight: dar ? 108 : 92),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            '${_adim + 1} · ${adim[isEn ? 'baslik_en' : 'baslik_tr']}',
                            style: UzayYazi.ustbaslik(context)
                                .copyWith(color: vurgu, letterSpacing: 1.4)),
                        const SizedBox(height: 8),
                        Text('${adim[isEn ? 'not_en' : 'not_tr']}',
                            style: UzayYazi.govde(context)
                                .copyWith(fontSize: dar ? 15.5 : 17.5)),
                      ],
                    ),
                  ),
                ),
                // 'DERİNE İN' KAPISI YOK (kullanıcı, 14 Kasım 2026).
                // Şemanın kendisi altı adım ve her adımın notu ekranda
                // yazılı; derin katman zaten görünür durumda. Durak 4'teki
                // zaman çizelgesiyle aynı gerekçe.
              ],
            ),
          ),
        ),
      );
    });
  }
}

/// Yetiştirme odasının kesiti. Parçalar BİRİKEREK çiziliyor: her adım bir
/// öncekini silmiyor, üstüne ekliyor — şemanın anlattığı şey zaten bu,
/// parçaların birlikte çalıştığı.
class _OdaBoyaci extends CustomPainter {
  final int adim;
  final double t;
  final Color vurgu;

  _OdaBoyaci({required this.adim, required this.t, required this.vurgu});

  double _evre(int i) => adim > i ? 1.0 : (adim == i ? t : 0.0);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final cizgi = Colors.white.withValues(alpha: 0.30);
    final soluk = Colors.white.withValues(alpha: 0.14);

    // Oda gövdesi — hep duruyor, parçalar içine geliyor.
    final oda = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.10, h * 0.08, w * 0.80, h * 0.84),
        const Radius.circular(10));
    canvas.drawRRect(oda, Paint()..color = Colors.white.withValues(alpha: 0.025));
    canvas.drawRRect(
        oda,
        Paint()
          ..color = soluk
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);

    final yastikUst = h * 0.62;
    final yastikSol = w * 0.28, yastikSag = w * 0.72;

    // ── 1 · YASTIK ────────────────────────────────────────────────────
    final e1 = _evre(0);
    if (e1 > 0) {
      final yastik = RRect.fromRectAndRadius(
          Rect.fromLTRB(yastikSol, yastikUst, yastikSag, h * 0.84),
          const Radius.circular(8));
      canvas.save();
      canvas.clipRRect(RRect.fromRectAndRadius(
          Rect.fromLTRB(yastikSol, yastikUst,
              yastikSol + (yastikSag - yastikSol) * e1, h * 0.84),
          const Radius.circular(8)));
      canvas.drawRRect(
          yastik, Paint()..color = const Color(0xFF3A3340).withValues(alpha: 0.9));
      // Gözenekli seramik harç — taneler.
      for (var i = 0; i < 46; i++) {
        final x = yastikSol + ((i * 37) % 100) / 100 * (yastikSag - yastikSol);
        final y = yastikUst + ((i * 53) % 100) / 100 * (h * 0.22);
        canvas.drawCircle(Offset(x + 4, y + 4), 1.6,
            Paint()..color = Colors.white.withValues(alpha: 0.18));
      }
      canvas.restore();
      canvas.drawRRect(
          yastik,
          Paint()
            ..color = cizgi
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1);
      _etiket(canvas, size, Offset(yastikSol, h * 0.885), 'yastık', e1);
    }

    // ── 2 · SU ────────────────────────────────────────────────────────
    final e2 = _evre(1);
    if (e2 > 0) {
      final kalem = Paint()
        ..color = const Color(0xFF6FB2E8).withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round;
      // Dışarıdan gelen boru.
      final boru = Path()
        ..moveTo(w * 0.10, h * 0.74)
        ..lineTo(yastikSol + 14, h * 0.74);
      _cizOran(canvas, boru, e2, kalem);
      // Harcın içindeki dağıtım halkası.
      if (e2 > 0.45) {
        final o = ((e2 - 0.45) / 0.55).clamp(0.0, 1.0);
        canvas.drawArc(
            Rect.fromCenter(
                center: Offset(w * 0.50, h * 0.74),
                width: (yastikSag - yastikSol) * 0.62,
                height: h * 0.08),
            3.14159,
            6.28318 * o,
            false,
            kalem);
        // Fitiller — halkadan yukarı.
        for (final fx in [0.40, 0.50, 0.60]) {
          final p = Path()
            ..moveTo(w * fx, h * 0.74)
            ..lineTo(w * fx, yastikUst - h * 0.02);
          _cizOran(canvas, p, o, kalem..strokeWidth = 1.2);
        }
        // Kökler.
        for (final fx in [0.42, 0.50, 0.58]) {
          final p = Path()
            ..moveTo(w * fx, h * 0.68)
            ..quadraticBezierTo(
                w * (fx + 0.03), h * 0.76, w * (fx - 0.01), h * 0.82);
          _cizOran(canvas, p, o,
              Paint()
                ..color = const Color(0xFFBFAE8C).withValues(alpha: 0.75)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.1
                ..strokeCap = StrokeCap.round);
        }
      }
      _etiket(canvas, size, Offset(w * 0.10, h * 0.70), 'sulama borusu', e2);
    }

    // ── BİTKİ ─────────────────────────────────────────────────────────
    final bitkiBoy = (_evre(1) * 0.5 + _evre(2) * 0.5).clamp(0.0, 1.0);
    if (bitkiBoy > 0) {
      final yesil = Color.lerp(
          const Color(0xFF6E7F4A), UzayRenk.yaprak, _evre(2))!;
      final tepe = yastikUst - h * 0.26 * bitkiBoy;
      final govde = Path()
        ..moveTo(w * 0.50, yastikUst)
        ..quadraticBezierTo(w * 0.485, (yastikUst + tepe) / 2, w * 0.50, tepe);
      canvas.drawPath(
          govde,
          Paint()
            ..color = yesil
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2
            ..strokeCap = StrokeCap.round);
      for (final (aci, yon) in [(-0.7, -1.0), (0.7, 1.0)]) {
        canvas.save();
        canvas.translate(w * 0.50, tepe + h * 0.03);
        canvas.rotate(aci);
        canvas.scale(bitkiBoy);
        final b = h * 0.11, en = w * 0.035;
        final yap = Path()
          ..moveTo(0, 0)
          ..quadraticBezierTo(en * yon.abs(), -b * 0.42, 0, -b)
          ..quadraticBezierTo(-en * yon.abs(), -b * 0.42, 0, 0);
        canvas.drawPath(yap, Paint()..color = yesil);
        canvas.restore();
      }
    }

    // ── 3 · IŞIK ──────────────────────────────────────────────────────
    final e3 = _evre(2);
    if (e3 > 0) {
      final y = h * 0.14;
      final sol = w * 0.30, sag = w * 0.70;
      // Huzme.
      final huzme = Path()
        ..moveTo(sol, y + 6)
        ..lineTo(sag, y + 6)
        ..lineTo(w * 0.80, yastikUst)
        ..lineTo(w * 0.20, yastikUst)
        ..close();
      canvas.drawPath(
          huzme,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                vurgu.withValues(alpha: 0.26 * e3),
                vurgu.withValues(alpha: 0.0),
              ],
            ).createShader(Rect.fromLTRB(sol, y, sag, yastikUst)));
      // Kırmızı ve mavi diyotlar.
      const adet = 7;
      for (var i = 0; i < adet; i++) {
        final o = (e3 * adet - i).clamp(0.0, 1.0);
        if (o <= 0) continue;
        final x = sol + (sag - sol) * (i + 0.5) / adet;
        canvas.drawCircle(
            Offset(x, y),
            3.2 * o,
            Paint()
              ..color = (i.isEven
                      ? const Color(0xFFE2614A)
                      : const Color(0xFF6F8FE8))
                  .withValues(alpha: o));
      }
      canvas.drawLine(
          Offset(sol, y + 7),
          Offset(sol + (sag - sol) * e3, y + 7),
          Paint()
            ..color = cizgi
            ..strokeWidth = 1.4);
      _etiket(canvas, size, Offset(sag + 8, y - 4), 'LED', e3);
    }

    // ── 4 · HAVA ──────────────────────────────────────────────────────
    final e4 = _evre(3);
    if (e4 > 0) {
      final m = Offset(w * 0.845, h * 0.40);
      canvas.drawCircle(
          m,
          w * 0.028 * e4,
          Paint()
            ..color = soluk
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2);
      for (var i = 0; i < 3; i++) {
        canvas.save();
        canvas.translate(m.dx, m.dy);
        canvas.rotate(i * 2.094 + t * 3.2);
        canvas.drawLine(Offset.zero, Offset(w * 0.022 * e4, 0),
            Paint()..color = cizgi..strokeWidth = 1.4);
        canvas.restore();
      }
      // Dolaşım oku.
      final yol = Path()
        ..moveTo(w * 0.82, h * 0.46)
        ..quadraticBezierTo(w * 0.50, h * 0.52, w * 0.18, h * 0.40)
        ..quadraticBezierTo(w * 0.14, h * 0.24, w * 0.50, h * 0.22)
        ..quadraticBezierTo(w * 0.80, h * 0.22, w * 0.845, h * 0.34);
      _cizOran(
          canvas,
          yol,
          e4,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.26)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.1);
      _etiket(canvas, size, Offset(w * 0.80, h * 0.50), 'hava akışı', e4);
    }

    // ── 5 · CO2 ───────────────────────────────────────────────────────
    final e5 = _evre(4);
    if (e5 > 0) {
      for (var i = 0; i < 9; i++) {
        final o = (e5 * 9 - i).clamp(0.0, 1.0);
        if (o <= 0) continue;
        final x = w * (0.22 + (i * 0.067) % 0.56);
        final y = h * (0.26 + ((i * 29) % 100) / 100 * 0.22);
        canvas.drawCircle(Offset(x, y), 2.4 * o,
            Paint()..color = const Color(0xFFBFBFC6).withValues(alpha: 0.5 * o));
      }
      _etiket(canvas, size, Offset(w * 0.14, h * 0.20), 'CO₂', e5);
    }

    // ── 6 · TUTUCU ────────────────────────────────────────────────────
    final e6 = _evre(5);
    if (e6 > 0) {
      final kutu = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.125, h * 0.34, w * 0.055 * e6, h * 0.12),
          const Radius.circular(3));
      canvas.drawRRect(kutu, Paint()..color = vurgu.withValues(alpha: 0.22));
      canvas.drawRRect(
          kutu,
          Paint()
            ..color = vurgu.withValues(alpha: 0.8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2);
      // Yakalanan uçucular.
      for (var i = 0; i < 4; i++) {
        final o = (e6 * 4 - i).clamp(0.0, 1.0);
        if (o <= 0) continue;
        final x = w * (0.26 - i * 0.022);
        canvas.drawCircle(Offset(x, h * 0.40), 2.0 * o,
            Paint()..color = vurgu.withValues(alpha: 0.75 * o));
      }
      _etiket(canvas, size, Offset(w * 0.105, h * 0.49), 'tutucu', e6);
    }
  }

  void _etiket(Canvas canvas, Size size, Offset yer, String metin, double o) {
    if (o < 0.35) return;
    final tp = TextPainter(
      text: TextSpan(
          text: metin,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.52 * o),
              fontSize: size.width * 0.021,
              letterSpacing: 0.4)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, yer);
  }

  void _cizOran(Canvas canvas, Path yol, double oran, Paint kalem) {
    for (final olcu in yol.computeMetrics()) {
      canvas.drawPath(olcu.extractPath(0, olcu.length * oran), kalem);
    }
  }

  @override
  bool shouldRepaint(_OdaBoyaci e) =>
      e.adim != adim || e.t != t || e.vurgu != vurgu;
}
