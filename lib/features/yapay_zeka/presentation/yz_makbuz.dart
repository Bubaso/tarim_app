import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/yz_makbuz.g.dart';
import 'yz_gorsel_tam_ekran.dart' show kYzTamEkranZemin;

/// Rakamın makbuzu (25 Kasım 2026): mavi rakamı taşıyan alıntının yerel PDF
/// kopyasındaki sayfası ve (resmî, kurumsal, satıcı, proje kaynağında)
/// o yerin vurgulu kesiti. Veri `_raw/makbuz_uret.py`den
/// (`yz_makbuz.g.dart`).
///
/// Balon (yz_kaynak_balonu.dart) bu dosyadan iki şey alıyor: [yzMakbuz] ve
/// tam ekran görüntüleyici [yzMakbuzGoster]. Görüntüleyici yz_gorsel_tam_ekran
/// .dart'tan AYRI: o dosya ilk yükte (ülke dosyalarının galerisi), bu dosya
/// yalnız erteli pakette (test/yz_erteli_test.dart).

/// Bir sayfanın (bNN ya da tek_<kod>) [kalin] rakamının [kaynak] adayının
/// makbuzu; alıntının sayfası bulunamadıysa ya da kaynak PDF değilse null.
YzMakbuz? yzMakbuz(String sayfa, bool en, String kalin, String kaynak) {
  final i = kYzMakbuzSirasi['$sayfa:${en ? 'en' : 'tr'}']?[kalin]?[kaynak];
  return i == null ? null : kYzMakbuzlar[i];
}

/// "s. 12" · "p. 12"
String yzSayfaYazisi(int sayfa, bool en) => en ? 'p. $sayfa' : 's. $sayfa';

/// Kesiti tam ekranda açar. Kök gezginde, sayfanın ÜSTÜNE: telefondaki alt
/// sayfa ya da masaüstündeki balon altında açık kalıyor, kapatınca okur
/// balona dönüyor.
Future<void> yzMakbuzGoster(
  BuildContext context, {
  required YzMakbuz makbuz,
  required String kunye,
  required bool en,
}) =>
    Navigator.of(context, rootNavigator: true).push<void>(PageRouteBuilder<void>(
      opaque: true,
      fullscreenDialog: true,
      transitionDuration: const Duration(milliseconds: 180),
      reverseTransitionDuration: const Duration(milliseconds: 140),
      pageBuilder: (c, a1, a2) => YzMakbuzGorunumu(makbuz: makbuz, kunye: kunye, en: en),
      transitionsBuilder: (c, a, a2, cocuk) => FadeTransition(opacity: a, child: cocuk),
    ));

/// Tam ekran kesit: koyu zemin, iki parmakla ya da çift dokunuşla 4 kata
/// kadar yakınlaştırma, sağ üstte 48 piksellik kapatma düğmesi; altta
/// künye, sayfa ve "Belgenin tamamını aç" (bağlantı PDF'se o sayfada
/// açılıyor). Kapatma: düğme, Esc, kesitin dışındaki zemine dokunuş.
class YzMakbuzGorunumu extends StatefulWidget {
  const YzMakbuzGorunumu({super.key, required this.makbuz, required this.kunye, required this.en});
  final YzMakbuz makbuz;
  final String kunye;
  final bool en;

  @override
  State<YzMakbuzGorunumu> createState() => _YzMakbuzGorunumuState();
}

class _YzMakbuzGorunumuState extends State<YzMakbuzGorunumu> {
  static const _yazi = Color(0xFFE6EAE7);
  static const _soluk = Color(0xFFAEB8B2);
  static const _baglanti = Color(0xFFB9CBEA);

  final _odak = FocusNode(debugLabel: 'yzMakbuz');
  final _donusum = TransformationController();
  Offset _dokunus = Offset.zero;

  @override
  void dispose() {
    _odak.dispose();
    _donusum.dispose();
    super.dispose();
  }

  void _kapat() => Navigator.of(context).maybePop();

  KeyEventResult _tus(FocusNode _, KeyEvent olay) {
    if (olay is KeyDownEvent && olay.logicalKey == LogicalKeyboardKey.escape) {
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

  void _belgeyiAc() {
    final uri = Uri.tryParse(widget.makbuz.adres);
    if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.makbuz;
    final en = widget.en;
    final pay = MediaQuery.paddingOf(context);
    final kapat = en ? 'Close' : 'Kapat';
    final sayfa = yzSayfaYazisi(m.sayfa, en);
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
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(12 + pay.left, 0, 12 + pay.right, 0),
                      child: Center(child: _kesit(m, en)),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16 + pay.left, 14, 16 + pay.right, 12 + pay.bottom),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.kunye,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, height: 1.4, color: _yazi),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 18,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(sayfa,
                                style: GoogleFonts.ibmPlexMono(
                                    fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.2, color: _soluk)),
                            if (m.adres.isNotEmpty)
                              TextButton(
                                onPressed: _belgeyiAc,
                                style: TextButton.styleFrom(
                                  foregroundColor: _baglanti,
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  minimumSize: const Size(48, 48),
                                ),
                                child: Text(en ? 'Open the full document ↗' : 'Belgenin tamamını aç ↗',
                                    style: GoogleFonts.ibmPlexMono(
                                        fontSize: 13, fontWeight: FontWeight.w600, color: _baglanti)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ]),
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
      ),
    );
  }

  /// Kesit, oranı korunarak alana sığdırılıyor; doğal boyunun 1/1,5'inden
  /// iri çizilmiyor (kesitte vurgulu satır 30 piksel: ekranda ~20 piksel).
  Widget _kesit(YzMakbuz m, bool en) {
    final adres = m.kesit;
    if (adres == null || m.genislik <= 0 || m.yukseklik <= 0) return const SizedBox.shrink();
    return LayoutBuilder(builder: (context, kis) {
      final oran = m.genislik / m.yukseklik;
      var g = math.min(kis.maxWidth, m.genislik / 1.5);
      if (kis.maxHeight.isFinite && g / oran > kis.maxHeight) g = kis.maxHeight * oran;
      return GestureDetector(
        // Kesitin kendisine tek dokunuş kapatmıyor; zemine dokunuş kapatıyor.
        onTap: () {},
        child: Semantics(
          image: true,
          label: en ? 'Excerpt from the source, ${yzSayfaYazisi(m.sayfa, en)}' : 'Kaynaktan kesit, ${yzSayfaYazisi(m.sayfa, en)}',
          child: SizedBox(
            width: g,
            height: g / oran,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: ColoredBox(
                color: Colors.white,
                child: Image.network(
                  adres,
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                  errorBuilder: (c, h, i) =>
                      const Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.black38, size: 36)),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
