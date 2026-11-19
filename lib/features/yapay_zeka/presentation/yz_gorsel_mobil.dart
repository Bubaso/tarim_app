import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

import 'yz_tasarim.dart';

/// Görsel, grafik ve şemaların telefon düzeni — mobil okuma turu
/// (18 Kasım 2026, karar 62). Buradaki her şey yalnız telefonda
/// (`yzTelefon`, < 640 px) kullanılıyor; masaüstü ve tablet düzeni değişmez.

/// Telefonda küçük künye yazısı: görselin kaynak satırı ("Fotoğraf: …"),
/// grafiğin kaynak satırı ve lejant adları. IBM Plex Mono küçük puntoda
/// telefonda ağır duruyor; yerine sade Outfit, aynı renkte. Büyük harfli
/// küçük etiketler ve eksen rakamları mono kalıyor.
TextStyle yzKunyeYazisi({Color renk = YzRenk.soluk, double boy = 12.5}) =>
    GoogleFonts.outfit(fontSize: boy, fontWeight: FontWeight.w500, color: renk, height: 1.4);

/// Katlanmış şemada görünen yükseklik.
const double kYzKatliBoy = 420;

/// Bundan kısa şema katlanmıyor: 420 pikseli göstermek için katlamaya değmez.
const double kYzKatlamaEsigi = 540;

/// Uzun şema ve görsel telefonda katlanıyor: ilk [kYzKatliBoy] piksel
/// görünür, alt kenarı zemine soluyor, altında tam genişlikte "Şemanın
/// tamamını gör" düğmesi. Açılınca sonda "Şemayı daralt".
///
/// [tasma]: görsel metin sütununun iki yanından bu kadar taşıyor (kenardan
/// kenara fotoğraf); düğme sütunun içinde kalıyor.
class YzGorselKatlanir extends StatefulWidget {
  const YzGorselKatlanir({
    super.key,
    required this.child,
    required this.en,
    this.esik = kYzKatlamaEsigi,
    this.tasma = 0,
    this.sema = true,
    this.grafik = false,
    this.zemin = YzRenk.zemin,
  });

  final Widget child;
  final bool en;

  /// Çocuğun boyu bunu aşarsa katlanıyor.
  final double esik;
  final double tasma;

  /// Düğmenin dili: şema mı, görsel mi.
  final bool sema;

  /// Düğmenin dili grafik için (madde 7): "Grafiğin tamamını gör"; [sema]'yı
  /// geçersiz kılar.
  final bool grafik;

  /// Alt kenarın solduğu zemin: sayfa zemini; grafik kartında kartın beyazı.
  final Color zemin;

  @override
  State<YzGorselKatlanir> createState() => _YzGorselKatlanirState();
}

class _YzGorselKatlanirState extends State<YzGorselKatlanir> {
  bool _uzun = false;
  bool _acik = false;

  void _bildir(bool uzun) {
    if (mounted && uzun != _uzun) setState(() => _uzun = uzun);
  }

  void _degistir() {
    setState(() => _acik = !_acik);
    if (!_acik) {
      // Daraltınca şemanın başı ekranın üstünde kaldıysa oraya dönülüyor.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final hareketsiz = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
        Scrollable.ensureVisible(
          context,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
          duration: hareketsiz ? Duration.zero : const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final en = widget.en;
    final katli = _uzun && !_acik;
    Widget gorsel = Stack(fit: StackFit.passthrough, children: [
      _Kirp(esik: widget.esik, azami: kYzKatliBoy, acik: _acik, bildir: _bildir, child: widget.child),
      if (katli)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 96,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [widget.zemin.withValues(alpha: 0), widget.zemin],
                ),
              ),
            ),
          ),
        ),
    ]);
    if (widget.tasma > 0) {
      // Ayrı değişken: kapanış `gorsel`i değil iç kutuyu yakalamalı (yoksa
      // LayoutBuilder kendini sonsuza dek iç içe kurar).
      final ic = gorsel;
      gorsel = LayoutBuilder(
        builder: (context, kis) => OverflowBox(
          fit: OverflowBoxFit.deferToChild,
          minWidth: kis.maxWidth + 2 * widget.tasma,
          maxWidth: kis.maxWidth + 2 * widget.tasma,
          child: ic,
        ),
      );
    }
    // Ağaç yapısı uzunluk anlaşılınca değişmesin (görsel yeniden yüklenmesin):
    // her zaman aynı Column, düğme yalnız uzunsa.
    if (!_uzun) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [gorsel]);
    }
    final etiket = widget.grafik
        ? (_acik
            ? (en ? 'Collapse chart' : 'Grafiği daralt')
            : (en ? 'Show the full chart' : 'Grafiğin tamamını gör'))
        : widget.sema
        ? (_acik
            ? (en ? 'Collapse diagram' : 'Şemayı daralt')
            : (en ? 'Show the full diagram' : 'Şemanın tamamını gör'))
        : (_acik
            ? (en ? 'Collapse image' : 'Görseli daralt')
            : (en ? 'Show the full image' : 'Görselin tamamını gör'));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      gorsel,
      const SizedBox(height: 8),
      TextButton.icon(
        onPressed: _degistir,
        icon: Icon(_acik ? Icons.expand_less_rounded : Icons.expand_more_rounded, size: 20),
        label: Text(etiket),
        style: TextButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          foregroundColor: YzRenk.makine,
          backgroundColor: YzRenk.makineAcik,
          textStyle: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ]);
  }
}

/// Çocuğunu boyu sınırsız kurar; boyu [esik]'i aşar ve [acik] değilse
/// [azami] yükseklikte kırpar. Uzun olup olmadığını kare bitince bildirir.
class _Kirp extends SingleChildRenderObjectWidget {
  const _Kirp({
    required this.esik,
    required this.azami,
    required this.acik,
    required this.bildir,
    required super.child,
  });

  final double esik;
  final double azami;
  final bool acik;
  final ValueChanged<bool> bildir;

  @override
  _KirpKutusu createRenderObject(BuildContext context) =>
      _KirpKutusu(esik: esik, azami: azami, acik: acik, bildir: bildir);

  @override
  void updateRenderObject(BuildContext context, _KirpKutusu kutu) {
    kutu
      ..esik = esik
      ..azami = azami
      ..acik = acik
      ..bildir = bildir;
  }
}

class _KirpKutusu extends RenderProxyBox {
  _KirpKutusu({
    required double esik,
    required double azami,
    required bool acik,
    required this.bildir,
  })  : _esik = esik,
        _azami = azami,
        _acik = acik;

  ValueChanged<bool> bildir;
  bool? _sonUzun;
  bool _kirpik = false;
  final _kirpma = LayerHandle<ClipRectLayer>();

  double _esik;
  set esik(double d) {
    if (d == _esik) return;
    _esik = d;
    markNeedsLayout();
  }

  double _azami;
  set azami(double d) {
    if (d == _azami) return;
    _azami = d;
    markNeedsLayout();
  }

  bool _acik;
  set acik(bool d) {
    if (d == _acik) return;
    _acik = d;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final c = child;
    if (c == null) {
      size = constraints.smallest;
      return;
    }
    c.layout(constraints.copyWith(minHeight: 0, maxHeight: double.infinity), parentUsesSize: true);
    final boy = c.size.height;
    final uzun = boy > _esik;
    _kirpik = uzun && !_acik;
    size = constraints.constrain(Size(c.size.width, _kirpik ? _azami : boy));
    if (uzun != _sonUzun) {
      _sonUzun = uzun;
      final b = bildir;
      SchedulerBinding.instance.addPostFrameCallback((_) => b(uzun));
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    if (_kirpik) {
      _kirpma.layer = context.pushClipRect(
        needsCompositing,
        offset,
        Offset.zero & size,
        super.paint,
        oldLayer: _kirpma.layer,
      );
    } else {
      _kirpma.layer = null;
      super.paint(context, offset);
    }
  }

  @override
  Rect? describeApproximatePaintClip(RenderObject child) => _kirpik ? Offset.zero & size : null;

  @override
  void dispose() {
    _kirpma.layer = null;
    super.dispose();
  }
}
