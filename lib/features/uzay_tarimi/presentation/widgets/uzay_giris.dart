import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/uzay_duraklar.g.dart';
import '../uzay_tasarim.dart';

/// Bir oturumda bir kez oynar. İkinci kez gelen okur üç saniye beklemez.
bool uzayGirisOynandi = false;

/// AÇILIŞ — tohumdan yaprağa.
///
/// ══ NE ANLATIYOR ═════════════════════════════════════════════════════════
/// Dosyanın tamamının özeti, üç saniyede: karanlıkta bir tohum, inen bir
/// kök, açılan bir yaprak, yanan mor LED. Sonra kare yaprağın içinden
/// büyüyor ve başlık oturuyor.
///
/// Mor LED bir süs değil: Veggie ve Advanced Plant Habitat odalarının
/// kırmızı+mavi ışığı birleşince çıkan renk. Uzayda yetişen her bitkinin
/// fotoğrafındaki o parıltı. Açılış o rengi kurduğu için sayfanın geri
/// kalanı onu açıklamak zorunda kalmıyor.
///
/// ══ HER ZAMAN ATLANABİLİR ════════════════════════════════════════════════
/// Düğme ilk yarım saniyede beliriyor ve animasyonun üstünde kalıyor.
/// Atlanamayan bir açılış, ikinci kez gelmeyen bir okur demek. Üstelik
/// animasyon oturumda BİR KEZ oynuyor.
///
/// ══ ZAMANLAMA DÜZYAZIDA DEĞİL, SABİTTE ═══════════════════════════════════
/// Her evrenin başlangıcı ve bitişi aşağıdaki `_E` sabitlerinde. Düzyazıya
/// gömülen bir zamanlama, bir sonraki ayarda sessizce yanlışa döner.
class UzayGiris extends StatefulWidget {
  final VoidCallback onBitti;

  const UzayGiris({super.key, required this.onBitti});

  @override
  State<UzayGiris> createState() => _UzayGirisDurumu();
}

/// Evreler — denetleyicinin 0..1 ekseninde.
class _E {
  const _E._();
  // ══ SÜRE EŞİT DAĞITILMADI ═══════════════════════════════════════════
  // Toplam 6000 ms (veri katmanında). Eskiden 3200'dü ve yedi evre ona
  // sıkışıyordu: her evreye yarım saniye düşüyor, çizim okunmadan bitiyordu.
  //
  // Uzayan şey ANLAMI TAŞIYAN evreler: kök inişi ve gövde yükselişi artık
  // toplamın yarısına yakınını alıyor, çünkü animasyonun söylediği şey o —
  // bir tohumun kendini kurması. Kapanış (kare büyümesi ve başlık) kısa
  // kaldı; orada okur zaten ne olacağını biliyor ve beklemek istemiyor.
  //
  // SON KISIM İKİNCİ KEZ DENGELENDİ. Kullanıcı: "sona doğru rush edip
  // birden ilk kareye geçiyor." Çizim evreleri iyiydi; kare açılımı ile
  // başlık son yüzde on sekize sıkışmıştı ve ikisi birbirinin üstüne
  // biniyordu. Çizim öne alındı, kare ve başlığa yer açıldı, ve sonda
  // kısa bir DURUŞ bırakıldı (0,96-1,0) — animasyon bitmeden sayfa
  // değişmesin, okur ne olduğunu görsün.
  static const tohum = Interval(0.03, 0.11, curve: Curves.easeOut);
  static const kok = Interval(0.09, 0.31, curve: Curves.easeInOutCubic);
  static const govde = Interval(0.28, 0.48, curve: Curves.easeOutCubic);
  static const yaprak = Interval(0.42, 0.59, curve: Curves.easeOutBack);
  static const led = Interval(0.54, 0.68, curve: Curves.easeOutCubic);
  static const kare = Interval(0.64, 0.84, curve: Curves.easeInOutCubic);
  static const cizimSon = Interval(0.64, 0.76, curve: Curves.easeIn);
  static const baslik = Interval(0.74, 0.86, curve: Curves.easeOutCubic);

  /// BAŞLIK DEVİRDEN ÖNCE SİLİNİYOR.
  ///
  /// Eskiden başlık son kareye kadar tam opak duruyor ve devri bekliyordu;
  /// 560 ms'lik erime sırasında okur hem "Uzayda Tarım"ı hem durağın
  /// metnini aynı anda görüyordu. Kullanıcının tarifi: "ilk kareye geçtiği
  /// an UZAYDA TARIM metni hâlâ görünüyor."
  ///
  /// Artık başlık girişin KENDİ İÇİNDE sönüyor. Devir başladığında ekranda
  /// yalnız kare kalıyor — ve o kare durağın karesiyle birebir aynı
  /// olduğu için erime görünmüyor.
  static const baslikSon = Interval(0.93, 1.0, curve: Curves.easeIn);
}

class _UzayGirisDurumu extends State<UzayGiris>
    with SingleTickerProviderStateMixin {
  late final AnimationController _k;
  bool _kapaniyor = false;
  bool _kuruldu = false;

  @override
  void initState() {
    super.initState();
    final giris = uzayDuraklar['giris'] as Map;
    _k = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: giris['sure_ms'] as int),
    );
    // DİKKAT: `forward()` BURADA ÇAĞRILMIYOR. Sebebi aşağıda.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_kuruldu) return;
    _kuruldu = true;
    _hazirlanVeBasla();
  }

  /// ══ NEDEN ANİMASYON GECİKTİRİLEREK BAŞLIYOR ═══════════════════════════
  /// Önce `initState` içinde hemen başlıyordu ve canlıda şu şikâyeti aldı:
  /// "1 saniyeye bile varmadan kayboluyor."
  ///
  /// Sebep süre değildi — süre uzatıldıktan sonra da aynıydı. Sebep şu:
  /// `AnimationController` GERÇEK ZAMANLA ilerliyor. Soğuk açılışta
  /// CanvasKit ısınırken, yazı tipleri inerken ve ilk kareler düşerken
  /// animasyon arka planda akmaya devam ediyor; ekrana hiç çizilmiyor.
  /// Okur sayfa açıldığında çizimin ortasını ya da sonunu, bazen hiçbir
  /// şeyini görmüyor. Altı saniyeye çıkarmak bunu çözmedi, çünkü sorun
  /// sürenin kısalığı değil animasyonun GÖRÜNMEDEN akmasıydı.
  ///
  /// Şimdi iki şey bekleniyor:
  ///   1. Kapak karesinin çözülmesi — animasyonun sonunda o kare açılıyor
  ///      ve çözülmemişse tam orada takılıyor.
  ///   2. Bir gerçek karenin ekrana çizilmesi — motorun ısındığının tek
  ///      dürüst işareti.
  ///
  /// Kare gelmezse üç saniyede vazgeçiliyor: animasyon bir fotoğraf
  /// yüzünden hiç oynamamaktansa fotoğrafsız oynasın.
  Future<void> _hazirlanVeBasla() async {
    final durak = (uzayDuraklar['duraklar'] as List).first as Map;
    final url = '${(durak['gorsel'] as Map)['url']}';
    try {
      await precacheImage(NetworkImage(url), context)
          .timeout(const Duration(seconds: 3));
    } catch (_) {
      // Yutuluyor: kapak gelmese de giriş oynamalı.
    }
    if (!mounted) return;
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    _k.forward().whenComplete(_bitir);
  }

  void _bitir() {
    if (_kapaniyor || !mounted) return;
    _kapaniyor = true;
    uzayGirisOynandi = true;
    widget.onBitti();
  }

  @override
  void dispose() {
    _k.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final giris = uzayDuraklar['giris'] as Map;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final ekran = MediaQuery.sizeOf(context);
    final dar = UzayKirilma.darMi(ekran.width);

    return ColoredBox(
      color: const Color(0xFF07060A),
      child: AnimatedBuilder(
        animation: _k,
        builder: (context, _) {
          final t = _k.value;
          final kareT = _E.kare.transform(t);
          final cizimOpak = 1 - _E.cizimSon.transform(t);
          final baslikT = _E.baslik.transform(t);

          return Stack(
            fit: StackFit.expand,
            children: [
              // ── ÇİZİM ────────────────────────────────────────────────
              if (cizimOpak > 0.001)
                Opacity(
                  opacity: cizimOpak,
                  child: CustomPaint(
                    painter: _TohumBoyaci(
                      tohum: _E.tohum.transform(t),
                      kok: _E.kok.transform(t),
                      govde: _E.govde.transform(t),
                      yaprak: _E.yaprak.transform(t).clamp(0.0, 1.0),
                      led: _E.led.transform(t),
                    ),
                  ),
                ),

              // ── KARE YAPRAĞIN İÇİNDEN BÜYÜR ──────────────────────────
              // Daire yaprağın bulunduğu noktadan açılıyor; çizim o sırada
              // sönüyor, yani kare çizimin YERİNİ alıyor.
              if (kareT > 0)
                ClipPath(
                  clipper: _DaireAcilimi(ilerleme: kareT),
                  child: _Kapak(opak: kareT, dar: dar),
                ),

              // ── BAŞLIK ───────────────────────────────────────────────
              if (baslikT > 0)
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        dar ? 24 : 56, 0, dar ? 24 : 56, dar ? 48 : 72),
                    child: Opacity(
                      // Giriş biterken söner; gerekçe `_E.baslikSon`'da.
                      opacity: baslikT * (1 - _E.baslikSon.transform(t)),
                      child: Transform.translate(
                        offset: Offset(0, 26 * (1 - baslikT)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                                width: 26, height: 2, color: UzayRenk.led),
                            const SizedBox(width: 12),
                            Text(
                              isEn
                                  ? '${giris['baslik_en']}'
                                  : '${giris['baslik_tr']}',
                              style: UzayYazi.manset(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // ── GEÇ ──────────────────────────────────────────────────
              if (t > 0.08)
                Positioned(
                  top: MediaQuery.paddingOf(context).top + 14,
                  right: 16,
                  child: Opacity(
                    opacity: ((t - 0.08) * 6).clamp(0.0, 1.0),
                    child: _GecDugmesi(
                      etiket: isEn ? '${giris['gec_en']}' : '${giris['gec_tr']}',
                      onBas: () {
                        _k.stop();
                        _bitir();
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Kapak karesi — dairenin içinde beliren şey.
class _Kapak extends StatelessWidget {
  final double opak;
  final bool dar;

  const _Kapak({required this.opak, required this.dar});

  @override
  Widget build(BuildContext context) {
    final durak = (uzayDuraklar['duraklar'] as List).first as Map;
    final url = '${(durak['gorsel'] as Map)['url']}';

    // ══ DAR EKRANDA KARE TAM EKRAN DEĞİL ═══════════════════════════════
    // Kullanıcı: "önce tam ekran görselli kareye geçiyor, 1 sn kalmadan
    // asıl ilk kareye geçiyor." İki ayrı bileşim arka arkaya görünüyordu:
    // giriş kareyi TAM EKRAN açıyordu, ama telefonda ilk durak kareyi
    // 4:3 bantta gösteriyor. Devir anında kare bir büyüyüp bir küçülüyordu.
    //
    // Giriş artık durağın bileşimini taklit ediyor: aynı 4:3 bant, aynı
    // zemin. Devir görünmez oluyor çünkü devredilen şey zaten aynı.
    if (dar) {
      return ColoredBox(
        color: const Color(0xFF0C0A10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
            // ÖLÇEK 1,06 — DURAĞIN KARESİYLE AYNI.
            //
            // Durak karesini `Transform.scale(1.06)` ile çiziyor (parallaks
            // için). Giriş kapağı 1,0 ile çiziyordu ve aradaki yüzde altı,
            // 560 ms'lik erime boyunca karenin "nefes almasına" yol
            // açıyordu: okur kareyi iki kez belirmiş gibi görüyordu. Dar
            // ekranda daha da belirgindi, çünkü 4:3 bandın kenarları sabit
            // ve içindeki kayma gözden kaçmıyor.
            //
            // İki ölçek eşitlendi. Devredilen kare artık birebir aynı.
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Transform.scale(
                    scale: 1.06,
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      loadingBuilder: (c, child, i) =>
                          i == null ? child : const SizedBox.expand(),
                      errorBuilder: (c, h, i) => const SizedBox.expand(),
                    ),
                  ),
                  // ALT GEÇİŞ — DURAKTAKİYLE BİREBİR AYNI.
                  //
                  // Durak karesinin alt kenarında zemine eriyen bir geçiş
                  // var; girişin kapağında yoktu. Devir sırasında karenin
                  // altı bir anda koyulaşıyordu ve bu, karenin ikinci kez
                  // belirmesi gibi okunuyordu. Üç fark vardı ve bu
                  // üçüncüsü: ölçek, başlığın sönme anı, ve bu geçiş.
                  // Üçü de eşitlendi.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          const Color(0xFF0C0A10).withValues(alpha: 0.55),
                          Colors.transparent,
                        ],
                        stops: const [0, 0.22],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(child: SizedBox.shrink()),
          ],
        ),
      );
    }

    // Geniş ekranda da aynı eşitleme; orada kare tam ekran olduğu için
    // fark daha az görülüyordu ama vardı.
    return ColoredBox(
      color: const Color(0xFF0C0A10),
      child: Transform.scale(
        scale: 1.06,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (c, child, i) =>
              i == null ? child : const SizedBox.expand(),
          errorBuilder: (c, h, i) => const SizedBox.expand(),
        ),
      ),
    );
  }
}

/// Yaprağın bulunduğu noktadan açılan daire.
class _DaireAcilimi extends CustomClipper<Path> {
  final double ilerleme;

  _DaireAcilimi({required this.ilerleme});

  @override
  Path getClip(Size size) {
    final merkez = Offset(size.width / 2, size.height * 0.46);
    // Köşeye uzaklık: daire tam kapladığında ekranın tamamı görünüyor.
    final kose = math.sqrt(
        math.pow(math.max(merkez.dx, size.width - merkez.dx), 2) +
            math.pow(math.max(merkez.dy, size.height - merkez.dy), 2));
    return Path()
      ..addOval(Rect.fromCircle(center: merkez, radius: kose * ilerleme));
  }

  @override
  bool shouldReclip(_DaireAcilimi e) => e.ilerleme != ilerleme;
}

/// Tohum · kök · gövde · yaprak · LED.
///
/// Kök ve gövde PathMetric ile ÇİZİLİYOR (uzunluğun bir oranı
/// çıkarılıyor), yani gerçekten büyüyor gibi görünüyor — ölçeklenen bir
/// şekil değil.
class _TohumBoyaci extends CustomPainter {
  final double tohum, kok, govde, yaprak, led;

  _TohumBoyaci({
    required this.tohum,
    required this.kok,
    required this.govde,
    required this.yaprak,
    required this.led,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final m = Offset(size.width / 2, size.height * 0.60);
    final olcek = math.min(size.width, size.height);

    // ── LED ve ışık ────────────────────────────────────────────────────
    if (led > 0) {
      final y = size.height * 0.17;
      final genislik = olcek * 0.34 * Curves.easeOut.transform(led);
      // Işık huzmesi: LED'den aşağı inen yumuşak koni.
      final huzme = Path()
        ..moveTo(m.dx - genislik / 2, y)
        ..lineTo(m.dx + genislik / 2, y)
        ..lineTo(m.dx + genislik * 1.5, size.height * 0.78)
        ..lineTo(m.dx - genislik * 1.5, size.height * 0.78)
        ..close();
      canvas.drawPath(
        huzme,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              UzayRenk.led.withValues(alpha: 0.26 * led),
              UzayRenk.led.withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromLTWH(0, y, size.width, size.height)),
      );
      // Çubuğun kendisi ve parıltısı.
      final cubuk = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(m.dx, y), width: genislik, height: 5),
          const Radius.circular(3));
      canvas.drawRRect(
          cubuk,
          Paint()
            ..color = UzayRenk.led.withValues(alpha: 0.85 * led)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 14 * led));
      canvas.drawRRect(
          cubuk, Paint()..color = Color.lerp(
              const Color(0xFFFFFFFF), UzayRenk.led, 0.35)!
            .withValues(alpha: led));
    }

    // ── TOHUM ──────────────────────────────────────────────────────────
    if (tohum > 0) {
      final r = olcek * 0.009 * tohum;
      canvas.drawCircle(
          m,
          r * 3.4,
          Paint()
            ..color = const Color(0xFFD8C9A8).withValues(alpha: 0.30 * tohum)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
      canvas.drawCircle(
          m, r, Paint()..color = const Color(0xFFE8DCC0).withValues(alpha: tohum));
    }

    // ── KÖK ────────────────────────────────────────────────────────────
    if (kok > 0) {
      final boy = olcek * 0.17;
      final ana = Path()
        ..moveTo(m.dx, m.dy)
        ..cubicTo(m.dx + boy * 0.10, m.dy + boy * 0.35,
            m.dx - boy * 0.14, m.dy + boy * 0.62, m.dx + boy * 0.04,
            m.dy + boy);
      _ciz(canvas, ana, kok,
          Paint()
            ..color = const Color(0xFFBFAE8C).withValues(alpha: 0.85)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6
            ..strokeCap = StrokeCap.round);
      // Yan kökçükler, ana kök yarılandıktan sonra.
      final yan = ((kok - 0.45) / 0.55).clamp(0.0, 1.0);
      if (yan > 0) {
        for (final y in [0.45, 0.70]) {
          for (final yon in [-1.0, 1.0]) {
            final bas = Offset(m.dx, m.dy + boy * y);
            final p = Path()
              ..moveTo(bas.dx, bas.dy)
              ..quadraticBezierTo(bas.dx + yon * boy * 0.16,
                  bas.dy + boy * 0.06, bas.dx + yon * boy * 0.26,
                  bas.dy + boy * 0.20);
            _ciz(canvas, p, yan,
                Paint()
                  ..color = const Color(0xFFBFAE8C).withValues(alpha: 0.55)
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 1.1
                  ..strokeCap = StrokeCap.round);
          }
        }
      }
    }

    // ── GÖVDE ──────────────────────────────────────────────────────────
    final govdeBoy = olcek * 0.17;
    final uc = Offset(m.dx + govdeBoy * 0.05, m.dy - govdeBoy * govde);
    if (govde > 0) {
      final p = Path()
        ..moveTo(m.dx, m.dy)
        ..quadraticBezierTo(m.dx - govdeBoy * 0.07, m.dy - govdeBoy * 0.55,
            m.dx + govdeBoy * 0.05, m.dy - govdeBoy);
      _ciz(canvas, p, govde,
          Paint()
            ..color = Color.lerp(const Color(0xFF7E8C5A),
                UzayRenk.yaprak, led)!
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.1
            ..strokeCap = StrokeCap.round);
    }

    // ── YAPRAKLAR ──────────────────────────────────────────────────────
    if (yaprak > 0) {
      final renk = Color.lerp(const Color(0xFF6E7F4A), UzayRenk.yaprak, led)!;
      for (final (aci, gecikme) in [(-0.62, 0.0), (0.66, 0.22)]) {
        final y = ((yaprak - gecikme) / (1 - gecikme)).clamp(0.0, 1.0);
        if (y <= 0) continue;
        canvas.save();
        canvas.translate(uc.dx, uc.dy);
        canvas.rotate(aci);
        canvas.scale(y);
        final boy = olcek * 0.115;
        final en = olcek * 0.042;
        final yap = Path()
          ..moveTo(0, 0)
          ..quadraticBezierTo(en, -boy * 0.42, 0, -boy)
          ..quadraticBezierTo(-en, -boy * 0.42, 0, 0);
        if (led > 0) {
          canvas.drawPath(
              yap,
              Paint()
                ..color = UzayRenk.led.withValues(alpha: 0.30 * led)
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
        }
        canvas.drawPath(yap, Paint()..color = renk);
        canvas.drawPath(
            Path()
              ..moveTo(0, 0)
              ..lineTo(0, -boy),
            Paint()
              ..color = Colors.black.withValues(alpha: 0.22)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1);
        canvas.restore();
      }
    }
  }

  /// Yolun bir ORANINI çizer — şekli ölçeklemek yerine gerçekten büyütür.
  void _ciz(Canvas canvas, Path yol, double oran, Paint kalem) {
    for (final olcu in yol.computeMetrics()) {
      canvas.drawPath(olcu.extractPath(0, olcu.length * oran), kalem);
    }
  }

  @override
  bool shouldRepaint(_TohumBoyaci e) =>
      e.tohum != tohum ||
      e.kok != kok ||
      e.govde != govde ||
      e.yaprak != yaprak ||
      e.led != led;
}

class _GecDugmesi extends StatelessWidget {
  final String etiket;
  final VoidCallback onBas;

  const _GecDugmesi({required this.etiket, required this.onBas});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onBas,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 12, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(etiket,
                  style: UzayYazi.kunye(context).copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12.5)),
              const SizedBox(width: 5),
              Icon(Icons.chevron_right,
                  size: 16, color: Colors.white.withValues(alpha: 0.85)),
            ],
          ),
        ),
      ),
    );
  }
}
