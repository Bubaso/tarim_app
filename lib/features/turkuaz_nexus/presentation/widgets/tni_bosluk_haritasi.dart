import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/tni_veri.g.dart';
import '../tni_tasarim.dart';
import 'tni_parcalar.dart';

/// BOŞLUĞUN HARİTASI.
///
/// Üç politika çerçevesi — gıda, su, iklim — belgeye göre ayrı ayrı kurulmuş
/// ve birbirini görmüyor. Çizim bunu olduğu gibi gösteriyor: üç daire önce
/// AYRI duruyor, okur sayfayı indirdikçe kendiliğinden birleşiyor ve
/// ortalarında açılan ortak kümede girişimin adı beliriyor.
///
/// HAREKET SÜS DEĞİL, TEZİN KENDİSİ. Girişimin iddiası tam olarak "bu üçü
/// ayrı durmasın". Önce bir düğmeyle yapılıyordu; düğme okurdan sayfayı
/// anlamadan önce bir karar vermesini istiyordu. Şimdi çizim okur ona
/// baktığı anda birleşiyor: önce boşluğu görüyor, sonra kapandığını.
/// Bir daireye dokunulunca o çerçevenin NEYİ GÖRMEDİĞİ yazılıyor; üç
/// cümlenin üçü de belgenin §1.1 teşhisinden.
class TniBoslukHaritasi extends StatefulWidget {
  final bool karanlik;
  final bool isEn;

  const TniBoslukHaritasi({
    super.key,
    required this.karanlik,
    required this.isEn,
  });

  @override
  State<TniBoslukHaritasi> createState() => _TniBoslukHaritasiDurumu();
}

class _TniBoslukHaritasiDurumu extends State<TniBoslukHaritasi>
    with SingleTickerProviderStateMixin {
  late final AnimationController _kumanda;
  // Açılış hâli AYRI. Sayfa önce teşhisi gösteriyor, çözümü değil.
  bool _birlesti = false;
  String? _secili;

  /// Çizimin içinde yaşadığı kaydırma. `visibility_detector` paketi projede
  /// yok ve bir görünürlük sezgisi için paket eklemek fazlaydı; en yakın
  /// `Scrollable`'ın konumu dinleniyor.
  ScrollPosition? _konum;

  @override
  void initState() {
    super.initState();
    _kumanda = AnimationController(
      vsync: this,
      // Birleşme düğmeden daha yavaş: okur bunu kendi tetiklemiyor, o yüzden
      // hareketin gözle takip edilebilmesi gerekiyor.
      duration: const Duration(milliseconds: 2200),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _konum?.removeListener(_bakVeBirlestir);
    _konum = Scrollable.maybeOf(context)?.position;
    _konum?.addListener(_bakVeBirlestir);
    // Çizim ilk karede zaten ekrandaysa (kısa ekran, doğrudan bağlantı)
    // kaydırma hiç olmayabilir; bir kez de açılışta bakılıyor.
    WidgetsBinding.instance.addPostFrameCallback((_) => _bakVeBirlestir());
  }

  @override
  void dispose() {
    _konum?.removeListener(_bakVeBirlestir);
    _kumanda.dispose();
    super.dispose();
  }

  /// TEK YÖNLÜ. Birleşme bir kez olur ve geri alınmaz: okur yukarı
  /// kaydırdığında daireler yeniden ayrılsaydı, çizim gördüğü şeyi geri alan
  /// bir oyuncağa dönerdi. Teşhis bir kez kurulur, bir kez kapanır.
  void _bakVeBirlestir() {
    if (_birlesti || !mounted) return;
    final kutu = context.findRenderObject() as RenderBox?;
    if (kutu == null || !kutu.attached) return;
    final tepe = kutu.localToGlobal(Offset.zero).dy;
    final ekran = MediaQuery.sizeOf(context).height;
    // Bölümün üstü ekranın alt dörtte birine girdiğinde başlıyor: çizim
    // henüz tam görünmeden hareket başlarsa okur başlangıç hâlini hiç
    // görmez ve birleşmenin anlamı kaybolur.
    if (tepe < ekran * 0.75) {
      _birlesti = true;
      _kumanda.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.karanlik;
    final isEn = widget.isEn;
    final teshis = (tniVeri['teshis'] as Map).cast<String, dynamic>();
    final kopukluklar = (teshis['kopukluklar'] as List)
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();
    final genislik = MediaQuery.sizeOf(context).width;
    final buyuk = genislik >= 760;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TniBolumBasligi(
          no: '02',
          etiket: isEn ? 'THE DIAGNOSIS' : 'TEŞHİS',
          baslik: isEn ? 'Map of the gap' : 'Boşluğun haritası',
          giris: (isEn ? teshis['en'] : teshis['tr']) as String,
          vurgu: TniRenk.su(k),
          karanlik: k,
        ),
        const TniAra(boy: 26),
        // ── Çizim ───────────────────────────────────────────────────────────
        LayoutBuilder(builder: (context, kis) {
          final g = math.min(kis.maxWidth, 620.0);
          return Center(
            child: SizedBox(
              width: g,
              height: g * 0.68,
              child: AnimatedBuilder(
                animation: _kumanda,
                builder: (context, _) => _DaireKatmani(
                  t: Curves.easeInOutCubic.transform(_kumanda.value),
                  karanlik: k,
                  isEn: isEn,
                  secili: _secili,
                  sec: (kod) => setState(
                      () => _secili = _secili == kod ? null : kod),
                ),
              ),
            ),
          );
        }),
        const TniAra(boy: 22),
        // ── Üç kopukluk ─────────────────────────────────────────────────────
        ...[
          for (final kp in kopukluklar)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _KopuklukSatiri(
                kp: kp,
                karanlik: k,
                isEn: isEn,
                acik: _secili == null || _secili == kp['cerceve'],
                bas: () => setState(() => _secili =
                    _secili == kp['cerceve'] ? null : kp['cerceve'] as String),
              ),
            ),
        ],
        const TniAra(boy: 26),
        TniSoz(
          kod: 'ozkan_yapisal',
          karanlik: k,
          isEn: isEn,
          vurgu: TniRenk.su(k),
        ),
        if (buyuk) const TniAra(boy: 8),
      ],
    );
  }
}

/// Üç dairenin kendisi. `t = 0` ayrı, `t = 1` birleşik.
class _DaireKatmani extends StatelessWidget {
  final double t;
  final bool karanlik;
  final bool isEn;
  final String? secili;
  final void Function(String) sec;

  const _DaireKatmani({
    required this.t,
    required this.karanlik,
    required this.isEn,
    required this.secili,
    required this.sec,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, kis) {
      final g = kis.maxWidth;
      final y = kis.maxHeight;
      final r = g * 0.215;
      // Ayrı hâlde merkezler uzak, birleşik hâlde klasik Venn aralığı.
      // Ayrık hâl BİLEREK uzak: daireler birbirine yakın başlarsa birleşme
      // küçük bir kıpırtıya dönüyor ve hareketin söylediği şey — üç ayrı
      // çerçevenin bir araya gelmesi — görünmüyor.
      final ayrikAra = r * 2.75;
      final birlesikAra = r * 1.02;
      final ara = ayrikAra + (birlesikAra - ayrikAra) * t;
      final merkezY = y * 0.42;
      final altY = merkezY + ara * 0.84;
      final noktalar = <String, Offset>{
        'gida': Offset(g / 2 - ara / 2, merkezY),
        'iklim': Offset(g / 2 + ara / 2, merkezY),
        'su': Offset(g / 2, altY),
      };
      final renkler = <String, Color>{
        'gida': TniRenk.tarim(karanlik),
        'iklim': TniRenk.iklim(karanlik),
        'su': TniRenk.su(karanlik),
      };
      final adlar = <String, String>{
        'gida': isEn ? 'FOOD' : 'GIDA',
        'iklim': isEn ? 'CLIMATE' : 'İKLİM',
        'su': isEn ? 'WATER' : 'SU',
      };

      // Etiketlerin birleşik hâldeki yerleri. Daireler üst üste binince
      // ortası ortak kümeye ait oluyor; adlar oradan çekiliyor ki ortada
      // yalnız girişimin adı kalsın. Yönler dairelerin dizilişinden:
      // soldaki sola, sağdaki sağa, alttaki aşağı.
      const hedefler = <String, Alignment>{
        'gida': Alignment(-0.42, -0.42),   // sol üst
        'iklim': Alignment(0.42, -0.42),   // sağ üst
        'su': Alignment(0, 0.62),          // alt orta
      };

      // Üç dairenin ortak kesişiminin ağırlık merkezi.
      final ortakY = merkezY + ara * 0.28;

      // Ad, birleşme büyük ölçüde bittikten SONRA beliriyor: iki hareket
      // aynı anda olursa göz ikisini de kaçırıyor.
      final adT = ((t - 0.55) / 0.45).clamp(0.0, 1.0);
      final adPerde = Curves.easeOutCubic.transform(adT);

      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _DairePainter(
                noktalar: noktalar,
                r: r,
                renkler: renkler,
                secili: secili,
                t: t,
                cizgi: TniRenk.cizgi(karanlik),
                murekkep: TniRenk.metin(karanlik),
              ),
            ),
          ),
          for (final e in noktalar.entries)
            Positioned(
              left: e.value.dx - r,
              top: e.value.dy - r,
              width: r * 2,
              height: r * 2,
              child: Semantics(
                button: true,
                label: adlar[e.key],
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => sec(e.key),
                  child: Align(
                    // Ortadan kenara doğru kayıyor. `Alignment.lerp` ikisinin
                    // arasını veriyor; t ile sürülüyor.
                    alignment: Alignment.lerp(
                        Alignment.center, hedefler[e.key]!, t)!,
                    child: Text(
                      adlar[e.key]!,
                      style: TniYazi.olcu(
                        // Küçülüyor: ortak küme büyürken çerçeve adlarının
                        // onunla yarışmaması gerekiyor.
                        punto: r * (0.19 - 0.065 * t),
                        renk: secili == null || secili == e.key
                            ? TniRenk.metin(karanlik)
                            : TniRenk.ikincil(karanlik)
                                .withValues(alpha: 0.55),
                        kalinlik: FontWeight.w700,
                        aralik: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // ORTAK KÜMEDE GİRİŞİMİN ADI. Ayrı hâlde böyle bir yer YOK — sayfanın
          // bütün teşhisi bu. Ad belirirken hafifçe büyüyor; sabit punto ile
          // açılan bir yazı belirmiyor, "yanıp sönüyor" gibi duruyordu.
          if (adPerde > 0)
            Positioned(
              left: 0,
              right: 0,
              top: ortakY - r * 0.26,
              child: Opacity(
                opacity: adPerde,
                child: Transform.scale(
                  scale: 0.84 + 0.16 * adPerde,
                  child: Center(
                    child: Text(
                      'TNI',
                      style: TniYazi.olcu(
                        // ORTAK KÜMEYE SIĞIYOR. Önce r*0.5 idi ve yazı
                        // kesişimin dışına taşıyordu: ad, içinde durduğu
                        // şeklin sınırını aşınca "ortak küme" fikri
                        // görünmez oluyordu.
                        punto: r * 0.3,
                        renk: TniRenk.metin(karanlik),
                        kalinlik: FontWeight.w700,
                        aralik: 3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}

class _DairePainter extends CustomPainter {
  final Map<String, Offset> noktalar;
  final double r;
  final Map<String, Color> renkler;
  final String? secili;
  final double t;
  final Color cizgi;

  /// Ortak kümenin katı ve kenarı bununla çiziliyor. `cizgi` KULLANILMADI:
  /// o renk dekoratif ayırıcı için ve kontrastı anlam taşıyacak kadar yüksek
  /// değil — ortak küme ise sayfanın en çok anlam taşıyan şekli.
  final Color murekkep;

  _DairePainter({
    required this.noktalar,
    required this.r,
    required this.renkler,
    required this.secili,
    required this.t,
    required this.cizgi,
    required this.murekkep,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final e in noktalar.entries) {
      final sonuk = secili != null && secili != e.key;
      final renk = renkler[e.key]!;
      final dolgu = Paint()
        ..style = PaintingStyle.fill
        ..color = renk.withValues(alpha: sonuk ? 0.05 : 0.16 + 0.06 * t);
      final kenar = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = sonuk ? 1.0 : 1.8
        ..color = renk.withValues(alpha: sonuk ? 0.3 : 0.95);
      canvas.drawCircle(e.value, r, dolgu);
      canvas.drawCircle(e.value, r, kenar);
    }

    // ORTAK KÜME ÇİZİLİYOR — üç dairenin birden kesiştiği alan.
    //
    // Girişimin adı orada duracaksa o "ora"nın görünmesi gerekiyor; yoksa
    // ad üç saydam dairenin üst üste bindiği bulanık bir yerde asılı kalıyor
    // ve okur neye baktığını anlamıyor. Alan `Path.combine` ile ikişer ikişer
    // kesiştirilerek bulunuyor, elle çizilmiyor: daireler kımıldadıkça kesişim
    // de kımıldıyor ve iki çizim birbirinden ayrılamaz.
    //
    // Yalnız bir daire seçiliyken çizilmiyor: o an okurun baktığı şey ortaklık
    // değil, tek bir çerçevenin neyi görmediği.
    if (t > 0.02 && secili == null && noktalar.length == 3) {
      final daireler = noktalar.values
          .map((o) => Path()..addOval(Rect.fromCircle(center: o, radius: r)))
          .toList();
      final ortak = Path.combine(
        PathOperation.intersect,
        Path.combine(PathOperation.intersect, daireler[0], daireler[1]),
        daireler[2],
      );
      // Dolgu, altındaki üç rengi silmiyor; üstlerine ince bir KAT koyuyor,
      // böylece ortak alan bir ton daha yoğun duruyor ama hangi üç dairenin
      // kesiştiği görünmeye devam ediyor. Kat koyu zeminde AÇIK, açık zeminde
      // KOYU: tersi olsaydı alan ayrışmak yerine zemine karışırdı.
      canvas.drawPath(
        ortak,
        Paint()
          ..style = PaintingStyle.fill
          ..color = murekkep.withValues(alpha: 0.07 * t),
      );
      canvas.drawPath(
        ortak,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = murekkep.withValues(alpha: 0.40 * t),
      );
    }
  }

  @override
  bool shouldRepaint(_DairePainter o) =>
      o.t != t || o.secili != secili || o.r != r || o.murekkep != murekkep;
}

class _KopuklukSatiri extends StatelessWidget {
  final Map<String, dynamic> kp;
  final bool karanlik;
  final bool isEn;
  final bool acik;
  final VoidCallback bas;

  const _KopuklukSatiri({
    required this.kp,
    required this.karanlik,
    required this.isEn,
    required this.acik,
    required this.bas,
  });

  @override
  Widget build(BuildContext context) {
    final k = karanlik;
    final renk = switch (kp['cerceve'] as String) {
      'gida' => TniRenk.tarim(k),
      'su' => TniRenk.su(k),
      _ => TniRenk.iklim(k),
    };
    return InkWell(
      onTap: bas,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: acik ? 1 : 0.42,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: tniOkumaTavani),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 7, right: 12),
                decoration: BoxDecoration(color: renk, shape: BoxShape.circle),
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: (isEn ? kp['cerceve_en'] : kp['cerceve_tr'])
                          as String,
                      style: TniYazi.govde(
                        punto: 15,
                        renk: TniRenk.metin(k),
                        kalinlik: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: ' — ${isEn ? kp['gormuyor_en'] : kp['gormuyor_tr']}',
                      style: TniYazi.govde(
                        punto: 15,
                        renk: TniRenk.ikincil(k),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
