import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Telefonda görselin tam ekran gösterimi (mobil okuma turu, karar 62).
///
/// Koyu zemin, iki parmakla ya da çift dokunuşla 4 kata kadar yakınlaştırma,
/// sağ üstte 48 piksellik kapatma düğmesi, altta künye. Çentik ve alt çubuk
/// payı (güvenli alan) korunuyor. Masaüstünde eski büyütme penceresi
/// kullanılıyor (yz_gorsel.dart).
///
/// Kapatma yolları: Kapat düğmesi, görselin dışındaki koyu zemine tek
/// dokunuş ve (yakınlaşmamışken) görseli aşağı ya da yukarı çekip bırakmak.
///
/// Bilinen sınır: gösterim GoRouter'ın dışında, kök gezginde sayfasız bir
/// rota. Web'de tarayıcının geri düğmesi (ya da Android'in geri hareketi)
/// adres değişikliği olarak GoRouter'a gidiyor; gösterimi kapatmıyor,
/// makaleden de çıkıyor. Bunu düzeltmek gösterimi adres geçmişine bağlamayı
/// (yönlendirici dosyasında alt rota ya da sorgu değişkeni) gerektiriyor.
///
/// [uzun]: içerik ekran genişliğinde kuruluyor ve boyu sınırsız (çizilmiş
/// şemanın dar düzeni); 1 katta dikey kaydırılıyor, çekip kapatma yok.
Future<void> yzGorselTamEkran(
  BuildContext context, {
  required Widget gorunum,
  required String altyazi,
  required bool en,
  bool uzun = false,
}) =>
    Navigator.of(context, rootNavigator: true).push<void>(PageRouteBuilder<void>(
      opaque: true,
      fullscreenDialog: true,
      transitionDuration: const Duration(milliseconds: 180),
      reverseTransitionDuration: const Duration(milliseconds: 140),
      pageBuilder: (c, a1, a2) => YzGorselTamEkran(gorunum: gorunum, altyazi: altyazi, en: en, uzun: uzun),
      transitionsBuilder: (c, a, a2, cocuk) => FadeTransition(opacity: a, child: cocuk),
    ));

/// Görseli bu kadar çekip bırakınca gösterim kapanıyor.
const double kYzCekipKapatma = 120;

/// Neredeyse siyah; fotoğrafın renkleri ve koyu şemanın zemini ayrılıyor.
const Color kYzTamEkranZemin = Color(0xFF0C0E0D);

class YzGorselTamEkran extends StatefulWidget {
  const YzGorselTamEkran({
    super.key,
    required this.gorunum,
    required this.altyazi,
    required this.en,
    this.uzun = false,
  });
  final Widget gorunum;
  final String altyazi;
  final bool en;
  final bool uzun;

  @override
  State<YzGorselTamEkran> createState() => _YzGorselTamEkranState();
}

class _YzGorselTamEkranState extends State<YzGorselTamEkran> {
  static const double _ciftDokunusOlcegi = 2.5;

  final _donusum = TransformationController();
  Offset _dokunus = Offset.zero;

  @override
  void dispose() {
    _donusum.dispose();
    super.dispose();
  }

  /// Çekip kapatma: tek parmakla, yakınlaşmamışken başlayan hareket.
  bool _cekiliyor = false;
  double _cekme = 0;

  /// Çift dokunuş: yakın değilse dokunulan yere 2,5 kat yaklaş (o nokta
  /// yerinde kalır), yakınlaşmışsa geri dön.
  void _ciftDokunus() {
    final olcek = _donusum.value.getMaxScaleOnAxis();
    if (olcek > 1.01) {
      _donusum.value = Matrix4.identity();
      return;
    }
    const s = _ciftDokunusOlcegi;
    final p = _dokunus;
    _donusum.value = Matrix4.translationValues(p.dx, p.dy, 0)
      ..multiply(Matrix4.diagonal3Values(s, s, 1))
      ..multiply(Matrix4.translationValues(-p.dx, -p.dy, 0))
      ..multiply(_donusum.value);
  }

  void _kapat() => Navigator.of(context).maybePop();

  void _cekmeBasladi(ScaleStartDetails d) {
    _cekiliyor = !widget.uzun && d.pointerCount == 1 && _donusum.value.getMaxScaleOnAxis() <= 1.01;
  }

  void _cekmeSurdu(ScaleUpdateDetails d) {
    if (!_cekiliyor) return;
    if (d.pointerCount > 1 || (d.scale - 1).abs() > 0.01) {
      // İkinci parmak geldi: yakınlaştırma, çekme değil.
      _cekiliyor = false;
      if (_cekme != 0) setState(() => _cekme = 0);
      return;
    }
    setState(() => _cekme += d.focalPointDelta.dy);
  }

  void _cekmeBitti(ScaleEndDetails d) {
    final hiz = d.velocity.pixelsPerSecond.dy.abs();
    final kapat = _cekiliyor && (_cekme.abs() > kYzCekipKapatma || (hiz > 900 && _cekme.abs() > 24));
    _cekiliyor = false;
    if (kapat) {
      _kapat();
    } else if (_cekme != 0) {
      setState(() => _cekme = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final en = widget.en;
    final pay = MediaQuery.paddingOf(context);
    final kapat = en ? 'Close' : 'Kapat';
    // Görselin kendisine tek dokunuş bir şey yapmıyor (zemine dokunuş
    // kapatıyor); çift dokunuş dıştaki algılayıcıya kalıyor.
    final gorsel = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Semantics(image: true, label: widget.altyazi, child: widget.gorunum),
    );
    final Widget icerik;
    if (widget.uzun) {
      // Genişlik ve en az boy dıştaki InteractiveViewer kısmında veriliyor;
      // üstte kapatma düğmesine, altta künyeye yer bırakılıyor.
      icerik = Padding(
        padding: EdgeInsets.fromLTRB(12 + pay.left, pay.top + 60, 12 + pay.right, pay.bottom + 110),
        child: Center(child: gorsel),
      );
    } else {
      icerik = Transform.translate(
        offset: Offset(0, _cekme),
        child: Padding(
          padding: EdgeInsets.only(top: pay.top, bottom: pay.bottom),
          child: Center(child: gorsel),
        ),
      );
    }
    return Material(
      color: kYzTamEkranZemin,
      child: Stack(children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: _kapat,
            onDoubleTapDown: (d) => _dokunus = d.localPosition,
            onDoubleTap: _ciftDokunus,
            child: widget.uzun
                ? LayoutBuilder(
                    builder: (context, kis) => InteractiveViewer(
                      transformationController: _donusum,
                      constrained: false,
                      minScale: 1,
                      maxScale: 4,
                      child: SizedBox(
                        width: kis.maxWidth,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: kis.maxHeight),
                          child: icerik,
                        ),
                      ),
                    ),
                  )
                : InteractiveViewer(
                    transformationController: _donusum,
                    minScale: 1,
                    maxScale: 4,
                    onInteractionStart: _cekmeBasladi,
                    onInteractionUpdate: _cekmeSurdu,
                    onInteractionEnd: _cekmeBitti,
                    child: icerik,
                  ),
          ),
        ),
        // Künye: altta, zemine koyulaşan bir geçişin üstünde.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [kYzTamEkranZemin.withValues(alpha: 0), kYzTamEkranZemin.withValues(alpha: 0.88)],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16 + pay.left, 28, 16 + pay.right, 16 + pay.bottom),
                child: ExcludeSemantics(
                  child: Text(
                    widget.altyazi,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                        fontSize: 14, fontWeight: FontWeight.w500, height: 1.4, color: const Color(0xFFE6EAE7)),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: pay.top + 4,
          right: pay.right + 4,
          child: Semantics(
            button: true,
            label: kapat,
            onTap: _kapat,
            excludeSemantics: true,
            child: Material(
              color: Colors.black.withValues(alpha: 0.45),
              shape: const CircleBorder(),
              child: IconButton(
                tooltip: kapat,
                constraints: const BoxConstraints.tightFor(width: 48, height: 48),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
                onPressed: _kapat,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
