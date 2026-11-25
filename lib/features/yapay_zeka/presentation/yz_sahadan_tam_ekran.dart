import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/yz_sahadan.g.dart';
import 'yz_gorsel_tam_ekran.dart' show kYzTamEkranZemin;

/// Sahadan galerisinin tam ekran görüntüleyicisi (25 Kasım 2026).
///
/// YALNIZ erteli pakette (galeri ve atlasın "Fotoğraf" kaydı açıyor).
/// yz_gorsel_tam_ekran.dart ilk yükte (ülke dosyalarının galerisi, metindeki
/// görsel); ona dokunulmadı, yalnız zemin rengi oradan alınıyor.
///
/// Koyu zemin, iki parmakla ya da çift dokunuşla 4 kata kadar yakınlaştırma,
/// sağ üstte 48 piksellik kapatma düğmesi, sol üstte sayaç; dizide oklarla,
/// klavyeyle (← →) ve yana kaydırarak geziliyor. Altta fotoğrafın künyesi,
/// kaynak satırı ve "Kaynağı aç ↗" (yayımlayan kurumun sayfası). Kapatma:
/// düğme, Esc, fotoğrafın dışındaki zemine dokunuş.
Future<void> yzSahadanTamEkran(
  BuildContext context, {
  required int baslangic,
  required bool en,
  List<YzSahadanKare> kareler = kYzSahadan,
}) async {
  if (kareler.isEmpty) return;
  await Navigator.of(context, rootNavigator: true).push<void>(PageRouteBuilder<void>(
    opaque: true,
    fullscreenDialog: true,
    transitionDuration: const Duration(milliseconds: 180),
    reverseTransitionDuration: const Duration(milliseconds: 140),
    pageBuilder: (c, a1, a2) => YzSahadanTamEkran(kareler: kareler, baslangic: baslangic, en: en),
    transitionsBuilder: (c, a, a2, cocuk) => FadeTransition(opacity: a, child: cocuk),
  ));
}

class YzSahadanTamEkran extends StatefulWidget {
  const YzSahadanTamEkran({super.key, required this.kareler, required this.baslangic, required this.en});

  /// Gezilen dizi (boş olmamalı): galeride bütün kareler, atlasta ilin kareleri.
  final List<YzSahadanKare> kareler;
  final int baslangic;
  final bool en;

  @override
  State<YzSahadanTamEkran> createState() => _YzSahadanTamEkranState();
}

class _YzSahadanTamEkranState extends State<YzSahadanTamEkran> {
  static const _yazi = Color(0xFFE6EAE7);
  static const _soluk = Color(0xFFAEB8B2);
  static const _baglanti = Color(0xFFB9CBEA);

  /// Yana bu kadar çekip bırakınca bir sonraki/önceki kareye geçiliyor.
  static const double _kaydirmaEsigi = 80;

  final _odak = FocusNode(debugLabel: 'yzSahadan');
  final _donusum = TransformationController();
  Offset _dokunus = Offset.zero;
  late int _i = widget.baslangic.clamp(0, widget.kareler.length - 1);

  /// Yana çekme: tek parmakla, yakınlaşmamışken.
  bool _kaydiriliyor = false;
  double _kaydirma = 0;

  YzSahadanKare get _kare => widget.kareler[_i];

  @override
  void dispose() {
    _odak.dispose();
    _donusum.dispose();
    super.dispose();
  }

  void _kapat() => Navigator.of(context).maybePop();

  /// Kare değişince yakınlaşma sıfırlanıyor: yeni kare eski karenin
  /// dönüşümüyle açılmasın.
  void _git(int yon) {
    final hedef = _i + yon;
    if (hedef < 0 || hedef >= widget.kareler.length) return;
    setState(() {
      _i = hedef;
      _donusum.value = Matrix4.identity();
      _kaydirma = 0;
    });
  }

  KeyEventResult _tus(FocusNode _, KeyEvent olay) {
    if (olay is! KeyDownEvent && olay is! KeyRepeatEvent) return KeyEventResult.ignored;
    final t = olay.logicalKey;
    if (t == LogicalKeyboardKey.arrowRight) {
      _git(1);
      return KeyEventResult.handled;
    }
    if (t == LogicalKeyboardKey.arrowLeft) {
      _git(-1);
      return KeyEventResult.handled;
    }
    if (t == LogicalKeyboardKey.escape) {
      _kapat();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// Çift dokunuş: yakın değilse dokunulan yere 2,5 kat yaklaş, yakınsa dön.
  void _ciftDokunus() {
    if (_donusum.value.getMaxScaleOnAxis() > 1.01) {
      _donusum.value = Matrix4.identity();
      return;
    }
    const s = 2.5;
    final p = _dokunus;
    _donusum.value = Matrix4.translationValues(p.dx, p.dy, 0)
      ..multiply(Matrix4.diagonal3Values(s, s, 1))
      ..multiply(Matrix4.translationValues(-p.dx, -p.dy, 0));
  }

  void _basladi(ScaleStartDetails d) {
    _kaydiriliyor =
        widget.kareler.length > 1 && d.pointerCount == 1 && _donusum.value.getMaxScaleOnAxis() <= 1.01;
  }

  void _surdu(ScaleUpdateDetails d) {
    if (!_kaydiriliyor) return;
    if (d.pointerCount > 1 || (d.scale - 1).abs() > 0.01) {
      // İkinci parmak geldi: yakınlaştırma, kaydırma değil.
      _kaydiriliyor = false;
      if (_kaydirma != 0) setState(() => _kaydirma = 0);
      return;
    }
    setState(() => _kaydirma += d.focalPointDelta.dx);
  }

  void _bitti(ScaleEndDetails d) {
    if (!_kaydiriliyor) return;
    _kaydiriliyor = false;
    final hiz = d.velocity.pixelsPerSecond.dx;
    final gec = _kaydirma.abs() > _kaydirmaEsigi || (hiz.abs() > 900 && _kaydirma.abs() > 24);
    if (gec) {
      _git(_kaydirma < 0 ? 1 : -1); // sola çekmek ileri götürüyor
    } else {
      setState(() => _kaydirma = 0);
    }
  }

  void _kaynagiAc() {
    final uri = Uri.tryParse(_kare.sayfaAdresi);
    if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final en = widget.en;
    final k = _kare;
    final pay = MediaQuery.paddingOf(context);
    final kapat = en ? 'Close' : 'Kapat';
    final cok = widget.kareler.length > 1;
    final gorsel = GestureDetector(
      // Fotoğrafa tek dokunuş kapatmıyor; zemine dokunuş kapatıyor.
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Semantics(
        image: true,
        label: k.kunye(en),
        child: Image.network(
          k.adres,
          key: ValueKey('yz-sahadan-tam-${k.kimlik}'),
          fit: BoxFit.contain,
          excludeFromSemantics: true,
          errorBuilder: (c, h, i) =>
              const Icon(Icons.image_not_supported_outlined, color: Colors.white54, size: 40),
        ),
      ),
    );
    return Focus(
      focusNode: _odak,
      autofocus: true,
      onKeyEvent: _tus,
      child: Material(
        color: kYzTamEkranZemin,
        child: Stack(children: [
          Positioned.fill(
            child: Column(children: [
              SizedBox(height: pay.top + 56),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _kapat,
                  onDoubleTapDown: (d) => _dokunus = d.localPosition,
                  onDoubleTap: _ciftDokunus,
                  child: InteractiveViewer(
                    transformationController: _donusum,
                    minScale: 1,
                    maxScale: 4,
                    onInteractionStart: _basladi,
                    onInteractionUpdate: _surdu,
                    onInteractionEnd: _bitti,
                    child: Transform.translate(
                      offset: Offset(_kaydirma, 0),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(12 + pay.left, 0, 12 + pay.right, 0),
                        child: Center(child: gorsel),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16 + pay.left, 14, 16 + pay.right, 8 + pay.bottom),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      key: const ValueKey('yz-sahadan-tam-kunye'),
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ExcludeSemantics(
                          child: Text(
                            k.kunye(en),
                            // Telefonda satır kısa: künyenin tamamı sığsın.
                            maxLines: MediaQuery.sizeOf(context).width < 640 ? 6 : 4,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                                fontSize: 14, fontWeight: FontWeight.w500, height: 1.4, color: _yazi),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          k.kaynak(en),
                          style: GoogleFonts.ibmPlexMono(
                              fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.2, color: _soluk),
                        ),
                        TextButton(
                          key: const ValueKey('yz-sahadan-tam-kaynak'),
                          onPressed: _kaynagiAc,
                          style: TextButton.styleFrom(
                            foregroundColor: _baglanti,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: const Size(48, 44),
                          ),
                          child: Text(en ? 'Open the source ↗' : 'Kaynağı aç ↗',
                              style: GoogleFonts.ibmPlexMono(
                                  fontSize: 13, fontWeight: FontWeight.w600, color: _baglanti)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ]),
          ),
          if (cok)
            Positioned(
              top: pay.top + 16,
              left: pay.left + 20,
              child: IgnorePointer(
                child: Text(
                  '${_i + 1} / ${widget.kareler.length}',
                  style: GoogleFonts.outfit(
                      fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.4, color: _yazi),
                ),
              ),
            ),
          Positioned(
            top: pay.top + 4,
            right: pay.right + 4,
            child: _Dugme(etiket: kapat, ikon: Icons.close_rounded, bas: _kapat, boy: 26),
          ),
          // Oklar yalnız gidilecek yer varken: sönük ama basılabilen bir
          // düğme okura "burada bir şey var" deyip hiçbir şey yapmazdı.
          if (cok && _i > 0)
            Positioned(
              left: pay.left + 8,
              top: pay.top + 56,
              bottom: 160 + pay.bottom,
              child: Center(
                child: _Dugme(
                    etiket: en ? 'Previous' : 'Önceki', ikon: Icons.chevron_left_rounded, bas: () => _git(-1)),
              ),
            ),
          if (cok && _i < widget.kareler.length - 1)
            Positioned(
              right: pay.right + 8,
              top: pay.top + 56,
              bottom: 160 + pay.bottom,
              child: Center(
                child: _Dugme(
                    etiket: en ? 'Next' : 'Sonraki', ikon: Icons.chevron_right_rounded, bas: () => _git(1)),
              ),
            ),
        ]),
      ),
    );
  }
}

/// 48 piksellik yarı saydam siyah daire düğme (kapatma, önceki, sonraki).
class _Dugme extends StatelessWidget {
  const _Dugme({required this.etiket, required this.ikon, required this.bas, this.boy = 30});
  final String etiket;
  final IconData ikon;
  final VoidCallback bas;
  final double boy;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: etiket,
        onTap: bas,
        excludeSemantics: true,
        child: Material(
          color: Colors.black.withValues(alpha: 0.45),
          shape: const CircleBorder(),
          child: IconButton(
            tooltip: etiket,
            constraints: const BoxConstraints.tightFor(width: 48, height: 48),
            padding: EdgeInsets.zero,
            icon: Icon(ikon, color: Colors.white, size: boy),
            onPressed: bas,
          ),
        ),
      );
}
