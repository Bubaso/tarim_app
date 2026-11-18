import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Telefonda görselin tam ekran gösterimi (mobil okuma turu, karar 62).
///
/// Koyu zemin, iki parmakla ya da çift dokunuşla 4 kata kadar yakınlaştırma,
/// sağ üstte 48 piksellik kapatma düğmesi, altta künye. Çentik ve alt çubuk
/// payı (güvenli alan) korunuyor. Masaüstünde eski büyütme penceresi
/// kullanılıyor (yz_gorsel.dart).
Future<void> yzGorselTamEkran(
  BuildContext context, {
  required Widget gorunum,
  required String altyazi,
  required bool en,
}) =>
    Navigator.of(context, rootNavigator: true).push<void>(PageRouteBuilder<void>(
      opaque: true,
      fullscreenDialog: true,
      transitionDuration: const Duration(milliseconds: 180),
      reverseTransitionDuration: const Duration(milliseconds: 140),
      pageBuilder: (c, a1, a2) => YzGorselTamEkran(gorunum: gorunum, altyazi: altyazi, en: en),
      transitionsBuilder: (c, a, a2, cocuk) => FadeTransition(opacity: a, child: cocuk),
    ));

/// Neredeyse siyah; fotoğrafın renkleri ve koyu şemanın zemini ayrılıyor.
const Color kYzTamEkranZemin = Color(0xFF0C0E0D);

class YzGorselTamEkran extends StatefulWidget {
  const YzGorselTamEkran({super.key, required this.gorunum, required this.altyazi, required this.en});
  final Widget gorunum;
  final String altyazi;
  final bool en;

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

  /// Çift dokunuş: yakınsa dokunulan yere 2,5 kat yaklaş, yakınlaşmışsa geri dön.
  void _ciftDokunus() {
    final olcek = _donusum.value.getMaxScaleOnAxis();
    if (olcek > 1.01) {
      _donusum.value = Matrix4.identity();
      return;
    }
    const s = _ciftDokunusOlcegi;
    _donusum.value = Matrix4.diagonal3Values(s, s, 1)
      ..setTranslationRaw(-_dokunus.dx * (s - 1), -_dokunus.dy * (s - 1), 0);
  }

  @override
  Widget build(BuildContext context) {
    final en = widget.en;
    final pay = MediaQuery.paddingOf(context);
    final kapat = en ? 'Close' : 'Kapat';
    return Material(
      color: kYzTamEkranZemin,
      child: Stack(children: [
        Positioned.fill(
          child: GestureDetector(
            onDoubleTapDown: (d) => _dokunus = d.localPosition,
            onDoubleTap: _ciftDokunus,
            child: InteractiveViewer(
              transformationController: _donusum,
              minScale: 1,
              maxScale: 4,
              child: Padding(
                padding: EdgeInsets.only(top: pay.top, bottom: pay.bottom),
                child: Center(
                  child: Semantics(image: true, label: widget.altyazi, child: widget.gorunum),
                ),
              ),
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
            onTap: () => Navigator.of(context).maybePop(),
            excludeSemantics: true,
            child: Material(
              color: Colors.black.withValues(alpha: 0.45),
              shape: const CircleBorder(),
              child: IconButton(
                tooltip: kapat,
                constraints: const BoxConstraints.tightFor(width: 48, height: 48),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
