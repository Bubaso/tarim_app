import 'package:flutter/material.dart';

import '../uzay_tasarim.dart';

/// SÜRGÜ — yolculuğun iki ucu.
///
/// ══ NE KARŞILAŞTIRIYOR ═══════════════════════════════════════════════════
/// Klasik "önce/sonra" değil. Solda otun GELDİĞİ yer — Tuz Gölü, yörüngeden
/// çekilmiş. Sağda GİTTİĞİ yer — istasyonun içi. Çizgiyi sürüklemek okuru
/// 420 kilometre aşağı ve yukarı taşıyor.
///
/// Bu durağın asıl söylediği şey bir simetri: bitki yukarı çıktı, istasyon
/// aşağı baktı. İki kare yan yana durduğunda cümleye gerek kalmıyor.
///
/// ══ SAĞDAKİ KARE O DENEYİN DEĞİL, VE BU YAZIYOR ══════════════════════════
/// Schrenkiella parvula'nın açık lisanslı tek bir fotoğrafı bulunamadı.
/// Sağdaki kare aynı aylarda aynı istasyonda büyüyen BAŞKA bir bitki ve
/// künyesi bunu söylüyor. Deneyin karesiymiş gibi göstermek, dosyanın
/// bütün geri kalanını şüpheye düşürürdü.
class UzaySurgu extends StatefulWidget {
  final Map<String, dynamic> veri;
  final double ilerleme;
  final bool isEn;
  final VoidCallback onDerine;

  const UzaySurgu({
    super.key,
    required this.veri,
    required this.ilerleme,
    required this.isEn,
    required this.onDerine,
  });

  @override
  State<UzaySurgu> createState() => _UzaySurguDurumu();
}

class _UzaySurguDurumu extends State<UzaySurgu>
    with SingleTickerProviderStateMixin {
  double _oran = 0.5;
  bool _dokunuldu = false;
  bool _basladi = false;
  late final AnimationController _k = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500));

  @override
  void initState() {
    super.initState();
    _k.addListener(() {
      if (_dokunuldu) return;
      // İPUCU HAREKETİ. Durak ekrana gelince çizgi bir gidip geliyor;
      // duran bir çizgi "beni sürükle" demiyor. Okur dokunduğu anda
      // hareket kesiliyor ve kumanda ona geçiyor.
      final t = Curves.easeInOut.transform(_k.value);
      setState(() => _oran = 0.5 + 0.13 * (t < 0.5 ? t * 2 : (1 - t) * 2));
    });
  }

  @override
  void dispose() {
    _k.dispose();
    super.dispose();
  }

  void _basla() {
    if (_basladi) return;
    _basladi = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_dokunuldu) _k.forward(from: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ilerleme.abs() < 0.12) _basla();

    final v = widget.veri;
    final isEn = widget.isEn;
    final vurgu = Color(int.parse('${v['vurgu']}'));
    final sol = v['sol'] as Map;
    final sag = v['sag'] as Map;
    final gorunurluk = (1 - (widget.ilerleme.abs() / 0.62)).clamp(0.0, 1.0);

    return LayoutBuilder(builder: (context, kis) {
      final dar = UzayKirilma.darMi(kis.maxWidth);
      final g = kis.maxWidth;

      void surukle(Offset yerel) {
        _k.stop();
        setState(() {
          _dokunuldu = true;
          _oran = (yerel.dx / g).clamp(0.04, 0.96);
        });
      }

      return Opacity(
        opacity: widget.ilerleme.abs() <= 0.58
            ? 1.0
            : (1 - (widget.ilerleme.abs() - 0.58) / 0.42).clamp(0.0, 1.0),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (e) => surukle(e.localPosition),
          onHorizontalDragStart: (e) => surukle(e.localPosition),
          onHorizontalDragUpdate: (e) => surukle(e.localPosition),
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeLeftRight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _Kare(url: '${sol['url']}', alt: '${sol[isEn ? 'alt_en' : 'alt_tr']}'),
                ClipRect(
                  clipper: _SagKirpici(_oran),
                  child: _Kare(
                      url: '${sag['url']}',
                      alt: '${sag[isEn ? 'alt_en' : 'alt_tr']}'),
                ),

                // Ayırıcı çizgi ve tutamak.
                Positioned(
                  left: g * _oran - 1,
                  top: 0,
                  bottom: 0,
                  child: Container(width: 2, color: Colors.white),
                ),
                Positioned(
                  left: g * _oran - 21,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 14)
                        ],
                      ),
                      // Yatay sürgünün oku da yatay. Dikey çizilen bir
                      // ok, sürüklenecek yönü yanlış söylüyordu.
                      child: RotatedBox(
                        quarterTurns: 1,
                        child: Icon(Icons.unfold_more,
                            size: 22, color: vurgu),
                      ),
                    ),
                  ),
                ),

                // Üst perde ve başlık.
                const Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: 280,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xCC07060A), Color(0x0007060A)],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: dar ? 22 : 64,
                  right: dar ? 22 : 64,
                  top: dar ? 64 : 86,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: gorunurluk,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  width: 20, height: 1.5, color: Colors.white),
                              const SizedBox(width: 10),
                              Text('${v[isEn ? 'zaman_en' : 'zaman_tr']}',
                                  style: UzayYazi.ustbaslik(context)
                                      .copyWith(color: Colors.white)),
                            ],
                          ),
                          SizedBox(height: dar ? 10 : 14),
                          Text('${v[isEn ? 'baslik_en' : 'baslik_tr']}',
                              style: UzayYazi.bolumBasligi(context)
                                  .copyWith(color: Colors.white)),
                          SizedBox(height: dar ? 8 : 12),
                          Text('${v[isEn ? 'giris_en' : 'giris_tr']}',
                              style: UzayYazi.govde(context).copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: dar ? 15.5 : 17.5)),
                        ],
                      ),
                    ),
                  ),
                ),


                // Alt perde, künyeler ve kapı.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: dar ? 150 : 160,
                  child: const IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Color(0xE607060A), Color(0x0007060A)],
                        ),
                      ),
                    ),
                  ),
                ),
                // ETİKETLER PERDEDEN SONRA. Önce çizildiklerinde alt
                // perde onların üstüne biniyor ve parlak kareye düşen
                // etiket okunmuyordu — ekranda görüldü.
                Positioned(
                  left: dar ? 18 : 40,
                  bottom: dar ? 104 : 118,
                  child: IgnorePointer(
                    child: _Etiket(
                        metin: '${sol[isEn ? 'etiket_en' : 'etiket_tr']}',
                        gorunur: _oran > 0.22),
                  ),
                ),
                Positioned(
                  right: dar ? 18 : 40,
                  bottom: dar ? 104 : 118,
                  child: IgnorePointer(
                    child: _Etiket(
                        metin: '${sag[isEn ? 'etiket_en' : 'etiket_tr']}',
                        gorunur: _oran < 0.78),
                  ),
                ),
                Positioned(
                  left: dar ? 22 : 64,
                  right: dar ? 22 : 64,
                  bottom: dar ? 24 : 36,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: IgnorePointer(
                          child: Text(
                            '${sol['atif']}   ·   ${sag['atif']}',
                            maxLines: 2,
                            style: UzayYazi.kunye(context).copyWith(
                                color: Colors.white.withValues(alpha: 0.55),
                                fontSize: 10.5),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      _DerineKapisi(isEn: isEn, onBas: widget.onDerine),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _Kare extends StatelessWidget {
  final String url, alt;

  const _Kare({required this.url, required this.alt});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      semanticLabel: alt,
      loadingBuilder: (c, child, i) =>
          i == null ? child : const SizedBox.expand(),
      errorBuilder: (c, h, i) => const SizedBox.expand(),
    );
  }
}

/// Sağdaki kareyi çizginin sağında bırakan kırpıcı. Kare TAM BOYUNDA
/// yerleşiyor ve sonra kırpılıyor; genişliği değiştirilseydi görüntü
/// ezilirdi.
class _SagKirpici extends CustomClipper<Rect> {
  final double oran;

  _SagKirpici(this.oran);

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(size.width * oran, 0, size.width, size.height);

  @override
  bool shouldReclip(_SagKirpici e) => e.oran != oran;
}

class _Etiket extends StatelessWidget {
  final String metin;
  final bool gorunur;

  const _Etiket({required this.metin, required this.gorunur});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: gorunur ? 1 : 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(metin,
            style: UzayYazi.ustbaslik(context)
                .copyWith(color: Colors.white, fontSize: 11)),
      ),
    );
  }
}

class _DerineKapisi extends StatelessWidget {
  final bool isEn;
  final VoidCallback onBas;

  const _DerineKapisi({required this.isEn, required this.onBas});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onBas,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 13, 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isEn ? 'go deeper' : 'derine in',
                  style: UzayYazi.kunye(context).copyWith(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4)),
              const SizedBox(width: 6),
              const Icon(Icons.add, size: 15, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
