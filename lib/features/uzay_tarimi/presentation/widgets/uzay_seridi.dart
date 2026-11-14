import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/uzay_duraklar.g.dart';
import '../uzay_tasarim.dart';

/// ANASAYFADAKİ UZAYDA TARIM ŞERİDİ — Tarım-Bilim ve Raporlar'ın altında.
///
/// ══ ALÇAK VE GENİŞ ═══════════════════════════════════════════════════════
/// Haber akışının içinde duruyor. Yüksek bir blok okuma sırasını keser ve
/// reklam gibi görünür; şerit üç satırı zor geçiyor, iki yana dayanıyor.
///
/// ══ NEDEN FOTOĞRAF YOK ═══════════════════════════════════════════════════
/// Anasayfada zaten iki fotoğraflı blok var: sergi bandı ve Nexus şeridi.
/// Üçüncüsü sayfada üç ayrı "koyu fotoğraflı kutu" demek olurdu ve okur
/// hangisinin ne olduğunu kareden anlayamazdı. Bu şerit onun yerine
/// DOSYANIN KENDİ ATMOSFERİNİ taşıyor: karanlık bir modül içi ve sol üstten
/// gelen pembe yetiştirme ışığı. Dosyayı açan okur aynı karanlığa ve aynı
/// pembeye giriyor — şerit bir afiş değil, kapının kendisi.
///
/// ══ GRAFİK SÜS DEĞİL, VERİ ═══════════════════════════════════════════════
/// Alt kenardaki çizgi dosyanın kendi zaman çizelgesi: on bir kilometre
/// taşı, GERÇEK yıl oranlarında. 1926 ile 1988 arasındaki altmış iki yıllık
/// boşluk şeritte de görünüyor, sağ uçtaki yığılma da. Yıllar
/// `uzay_duraklar.g.dart`'tan okunuyor; dosyaya durak eklenince çizgi
/// kendiliğinden değişiyor. Hiçbir nokta elle yerleştirilmedi.
///
/// ══ SAYI HAFIZADAN YAZILMIYOR ════════════════════════════════════════════
/// "On dokuz durak" da sayılıyor, yazılmıyor — dosyanın her yerindeki kural.
class UzaySeridi extends StatelessWidget {
  /// Şeritten SONRAKİ boşluk — anasayfanın öteki bölümleriyle aynı kural:
  /// boşluğu bölümün kendisi taşır.
  final double spacing;

  const UzaySeridi({super.key, this.spacing = 0});

  static List<int> get _yillar => [
        for (final t in (uzayDuraklar['duraklar'] as List)
            .firstWhere((s) => s['an_tipi'] == 'zaman_cizgisi')['kilometre_taslari']
            as List)
          t['yil'] as int
      ];

  static int get _durakSayisi =>
      (uzayDuraklar['duraklar'] as List).where((s) => s['hazir'] == true).length;

  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final g = MediaQuery.sizeOf(context).width;
    final dar = g < 600;
    final orta = !dar && g < 900;
    final boy = dar ? 142.0 : (orta ? 150.0 : 158.0);
    // Çizelge metnin YANINA ancak bu genişlikten sonra sığıyor.
    // Altında kalan şerit sağ tarafı boş bırakıyordu; yanına alınca hem
    // boşluk doluyor hem çizgiye nefes alanı kalıyor.
    //
    // EŞİK 900'DEN 1150'YE ÇIKTI. 900 ölçülmeden seçilmişti ve canlıda
    // 1024 piksellik ekranda tanıtım cümlesi ortasından kesiliyordu
    // ("…çabasının y…"). Hesap: yanlar 54 + filiz ve boşluğu 78 + ok 36 +
    // aradaki boşluklar 48 ≈ 216 piksel metne kalmıyor; geri kalanın
    // metne düşen payı cümleyi tek satırda taşıyacak kadar olmalı.
    // 1024'te olmuyor, 1150'de oluyor. Altındaki genişliklerde çizelge
    // metnin altına iniyor ve orada bütün satır onun.
    final genisCizelge = g >= 1150;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // `push`, `go` değil: anasayfa altta kalsın, okur geri döndüğünde
          // kaydırdığı yeri kaybetmesin.
          onTap: () => context.push('/uzayda-tarim'),
          child: SizedBox(
            height: boy,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: UzayRenk.zemin),

                // ── Yetiştirme ışığı ──────────────────────────────────────
                // Dosyanın her durağında sol üstten gelen aynı pembe var:
                // kadrajın dışında kalmış bir LED paneli. Şeritte de öyle.
                // Önce zayıf bir radyal gradyandı ve şerit düz siyah bir
                // çubuk gibi okunuyordu; ışık artık yatay bir geçişle
                // destekleniyor — sol aydınlık, sağ karanlığa düşüyor.
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0x33E86FBE), Color(0x0DE86FBE), Color(0x00E86FBE)],
                      stops: [0.0, 0.42, 0.78],
                    ),
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(-0.92, -1.4),
                      radius: 0.95,
                      colors: [Color(0x59E86FBE), Color(0x00E86FBE)],
                    ),
                  ),
                ),
                // Sağ altta çok sönük bir yeşil: yaprak.
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(1.25, 1.5),
                      radius: 0.85,
                      colors: [Color(0x268ACB55), Color(0x008ACB55)],
                    ),
                  ),
                ),

                // ── Yazı ve çizelge ───────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      dar ? 18 : 30, dar ? 15 : 18, dar ? 14 : 24, dar ? 13 : 18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Filiz, ışığın zaten düştüğü sol uçta. Telefonda da
                      // var — küçülüyor ama kalkmıyor: animasyon bu kartın
                      // karakteri, ve okurların çoğu telefondan bakıyor.
                      Center(
                        child: _Filiz(
                          en: dar ? 32 : (orta ? 46 : 54),
                          boy: dar ? 62 : (orta ? 86 : 98),
                        ),
                      ),
                      SizedBox(width: dar ? 13 : (orta ? 18 : 24)),
                      Expanded(
                        flex: genisCizelge ? 6 : 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isEn ? 'SPECIAL DOSSIER' : 'ÖZEL DOSYA',
                              style: GoogleFonts.inter(
                                color: UzayRenk.led,
                                fontSize: dar ? 9.5 : 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                            SizedBox(height: dar ? 6 : 8),
                            Text(
                              isEn ? 'Farming in Space' : 'Uzayda Tarım',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                color: UzayRenk.metin,
                                fontSize: dar ? 20 : (orta ? 24 : 28),
                                fontWeight: FontWeight.w600,
                                height: 1.1,
                                letterSpacing: -0.4,
                              ),
                            ),
                            SizedBox(height: dar ? 4 : 6),
                            Text(
                              isEn
                                  ? 'A hundred years of trying to grow food '
                                      'beyond Earth · $_durakSayisi stops'
                                  : 'Dünya dışında yemek yetiştirme çabasının '
                                      'yüz yılı · $_durakSayisi durak',
                              maxLines: dar ? 2 : 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.sourceSerif4(
                                color: UzayRenk.ikincil,
                                fontSize: dar ? 12.5 : 14,
                                height: 1.35,
                              ),
                            ),
                            // Dar ekranda çizelge metnin ALTINA iniyor:
                            // yan yana sığmıyor ve sıkıştırılsaydı noktalar
                            // birbirine girerdi.
                            if (!genisCizelge) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 14,
                                child: _Cizelge(
                                    yillar: _yillar, yillariGoster: false),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (genisCizelge) ...[
                        const SizedBox(width: 34),
                        Expanded(
                          flex: 5,
                          child: Center(
                            child: _Cizelge(yillar: _yillar),
                          ),
                        ),
                      ],
                      const SizedBox(width: 14),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Icon(Icons.arrow_forward_rounded,
                            size: dar ? 18 : 22, color: UzayRenk.led),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Şeritteki zaman çizelgesi — çizgi, noktalar ve iki uç yılı.
///
/// Boyacı yalnız kendi kutusunu boyuyor; yıllar ayrı bir satırda, altında.
/// Önce ikisi üst üste bindiriliyordu ve çizgi etiketlerin içinden geçiyordu.
class _Cizelge extends StatelessWidget {
  final List<int> yillar;
  final bool yillariGoster;

  const _Cizelge({required this.yillar, this.yillariGoster = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 14,
          width: double.infinity,
          child: CustomPaint(painter: _CizgiBoyaci(yillar: yillar)),
        ),
        if (yillariGoster) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_Yil('${yillar.first}'), _Yil('${yillar.last}')],
          ),
        ],
      ],
    );
  }
}

class _Yil extends StatelessWidget {
  final String metin;

  const _Yil(this.metin);

  @override
  Widget build(BuildContext context) {
    return Text(
      metin,
      style: GoogleFonts.inter(
        color: UzayRenk.ikincil.withValues(alpha: 0.8),
        fontSize: 9.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

/// Dosyanın zaman çizelgesinin şeritteki küçük hâli.
///
/// Noktalar yıl ekseninde GERÇEK oranda duruyor; eşit aralığa dağıtılsaydı
/// çizgi süs olurdu. Dağıtılmadığı için 1926-1988 arasındaki altmış iki
/// yıllık boşluk burada da görülüyor, sağ uçtaki yığılma da — şerit, bakan
/// kişiye dosyanın söylediği şeyi tek bakışta söylüyor.
class _CizgiBoyaci extends CustomPainter {
  final List<int> yillar;

  const _CizgiBoyaci({required this.yillar});

  @override
  void paint(Canvas canvas, Size size) {
    if (yillar.length < 2) return;
    final ilk = yillar.first, son = yillar.last;
    final y = size.height / 2;
    final sonDizin = yillar.length - 1;

    // Eksen: ilk duraktan son durağa kadar aydınlık, ötesi sönük. Burada
    // sönük bir kısım kalmıyor çünkü uçlar zaten ilk ve son durak — ama
    // çizgi uçlarda hafifçe eriyor ki kesik gibi durmasın.
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0x1AFFFFFF), Color(0x4DFFFFFF), Color(0x1AFFFFFF)],
          stops: [0, 0.5, 1],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..strokeWidth = 1.2,
    );

    for (var i = 0; i <= sonDizin; i++) {
      final x = (yillar[i] - ilk) / (son - ilk) * size.width;
      final sonuncu = i == sonDizin;
      if (sonuncu) {
        // Bugün: çevresinde bir hale. Dosyanın son durağı burada duruyor.
        canvas.drawCircle(Offset(x, y), 6.5,
            Paint()..color = UzayRenk.led.withValues(alpha: 0.22));
        canvas.drawCircle(Offset(x, y), 3.4, Paint()..color = UzayRenk.led);
      } else {
        canvas.drawCircle(Offset(x, y), 2.4,
            Paint()..color = UzayRenk.led.withValues(alpha: 0.78));
      }
    }
  }

  @override
  bool shouldRepaint(_CizgiBoyaci eski) => eski.yillar != yillar;
}

/// Şeritteki filiz — açılış animasyonunun küçük kardeşi.
///
/// ══ NEDEN AYRI BİR ÇİZİM ═════════════════════════════════════════════════
/// Açılıştaki `_TohumBoyaci` tam ekran için ölçülmüş: ışık konisi, bulanıklık
/// yarıçapları ve kök dallanması o boyutta anlamlı. Altmış piksellik bir
/// kutuya sokulduğunda hepsi lekeye dönüyor. Bu yüzden şeridin kendi, daha
/// yalın çizimi var: tohum, gövde, iki yaprak, üstte bir LED çubuğu.
/// Teknik aynı — yol ÖLÇEKLENMİYOR, `extractPath` ile gerçekten çiziliyor.
///
/// ══ NEDEN YAVAŞ VE ARALIKLI ══════════════════════════════════════════════
/// Şerit haber akışının içinde. Sürekli dönen bir animasyon okuma sırasını
/// keser ve reklam gibi okunur. Döngü sekiz saniyenin üstünde: çizim üç
/// saniye, sonra uzun bir duruş, sonra sönüp yeniden. Okur dönüp baktığında
/// hareket ediyor, gözünün ucunda dururken rahatsız etmiyor.
///
/// ══ HAREKETİ AZALT AYARINA UYUYOR ════════════════════════════════════════
/// Cihazda hareket azaltma açıksa animasyon hiç kurulmuyor; filiz çizilmiş
/// hâliyle duruyor. Erişilebilirlik ayarını yok sayan bir süs olmaz.
class _Filiz extends StatefulWidget {
  final double en, boy;

  const _Filiz({required this.en, required this.boy});

  @override
  State<_Filiz> createState() => _FilizDurumu();
}

class _FilizDurumu extends State<_Filiz> with SingleTickerProviderStateMixin {
  AnimationController? _k;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final kapali = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (kapali) {
      _k?.dispose();
      _k = null;
      return;
    }
    _k ??= AnimationController(
        vsync: this, duration: const Duration(milliseconds: 8400))
      ..repeat();
  }

  @override
  void dispose() {
    _k?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final k = _k;
    if (k == null) {
      // Hareket kapalı: çizim tamamlanmış hâliyle duruyor.
      return SizedBox(
        width: widget.en,
        height: widget.boy,
        child: const CustomPaint(
          painter: _FilizBoyaci(t: 0.70, opak: 1),
        ),
      );
    }
    return SizedBox(
      width: widget.en,
      height: widget.boy,
      child: AnimatedBuilder(
        animation: k,
        builder: (_, __) => CustomPaint(
          painter: _FilizBoyaci(
            t: k.value,
            // Son yüzde on dörtte sönüyor, başta geri geliyor.
            opak: k.value < 0.86
                ? (k.value / 0.05).clamp(0.0, 1.0)
                : (1 - (k.value - 0.86) / 0.14).clamp(0.0, 1.0),
          ),
        ),
      ),
    );
  }
}

class _FilizBoyaci extends CustomPainter {
  final double t, opak;

  const _FilizBoyaci({required this.t, required this.opak});

  static double _evre(double t, double bas, double son) =>
      ((t - bas) / (son - bas)).clamp(0.0, 1.0);

  void _ciz(Canvas c, Path yol, double oran, Paint kalem) {
    if (oran <= 0) return;
    for (final o in yol.computeMetrics()) {
      c.drawPath(o.extractPath(0, o.length * oran), kalem);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (opak <= 0) return;
    final tohum = Curves.easeOut.transform(_evre(t, 0.02, 0.09));
    final govde = Curves.easeInOut.transform(_evre(t, 0.07, 0.34));
    final yaprak = Curves.easeOutCubic.transform(_evre(t, 0.26, 0.52));
    final led = Curves.easeOut.transform(_evre(t, 0.38, 0.58));

    final taban = Offset(size.width / 2, size.height * 0.86);
    final govdeBoy = size.height * 0.46;
    final uc = Offset(taban.dx + govdeBoy * 0.06, taban.dy - govdeBoy * govde);

    // ── LED çubuğu ve huzmesi ─────────────────────────────────────────
    if (led > 0) {
      final y = size.height * 0.10;
      final en = size.width * 0.52 * led;
      canvas.drawPath(
        Path()
          ..moveTo(taban.dx - en / 2, y)
          ..lineTo(taban.dx + en / 2, y)
          ..lineTo(taban.dx + en * 1.25, size.height * 0.80)
          ..lineTo(taban.dx - en * 1.25, size.height * 0.80)
          ..close(),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              UzayRenk.led.withValues(alpha: 0.24 * led * opak),
              UzayRenk.led.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromLTWH(0, y, size.width, size.height)),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(taban.dx, y), width: en, height: 3),
            const Radius.circular(2)),
        Paint()..color = UzayRenk.led.withValues(alpha: 0.95 * led * opak),
      );
    }

    // ── Tohum ─────────────────────────────────────────────────────────
    if (tohum > 0) {
      canvas.drawCircle(
          taban,
          2.1 * tohum,
          Paint()
            ..color = const Color(0xFFE8DCC0).withValues(alpha: tohum * opak));
    }

    // ── Gövde ─────────────────────────────────────────────────────────
    if (govde > 0) {
      _ciz(
        canvas,
        Path()
          ..moveTo(taban.dx, taban.dy)
          ..quadraticBezierTo(taban.dx - govdeBoy * 0.09,
              taban.dy - govdeBoy * 0.55, taban.dx + govdeBoy * 0.06,
              taban.dy - govdeBoy),
        govde,
        Paint()
          ..color = Color.lerp(const Color(0xFF7E8C5A), UzayRenk.yaprak, led)!
              .withValues(alpha: opak)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round,
      );
    }

    // ── İki yaprak ────────────────────────────────────────────────────
    if (yaprak > 0) {
      final renk = Color.lerp(const Color(0xFF6E7F4A), UzayRenk.yaprak, led)!
          .withValues(alpha: opak);
      for (final (aci, gecikme) in [(-0.60, 0.0), (0.64, 0.26)]) {
        final y = ((yaprak - gecikme) / (1 - gecikme)).clamp(0.0, 1.0);
        if (y <= 0) continue;
        canvas.save();
        canvas.translate(uc.dx, uc.dy);
        canvas.rotate(aci);
        canvas.scale(y);
        final b = size.height * 0.30, e = size.width * 0.20;
        canvas.drawPath(
          Path()
            ..moveTo(0, 0)
            ..quadraticBezierTo(e, -b * 0.42, 0, -b)
            ..quadraticBezierTo(-e, -b * 0.42, 0, 0),
          Paint()..color = renk,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_FilizBoyaci e) => e.t != t || e.opak != opak;
}
