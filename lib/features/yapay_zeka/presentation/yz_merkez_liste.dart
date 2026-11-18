import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'yz_tasarim.dart';

/// Merkez sayfanın TELEFON düzeni (mobil tur, 18 Kasım 2026).
///
/// 375 piksellik ekranda iki sütun çerçeveli karo dört ekran kutu
/// ediyordu (★20). Telefonda başlıklar karosuz, ince çizgiyle ayrılmış tek
/// sütun bir liste; masaüstü ve tablet ızgarası değişmedi (yz_harita.dart).

/// Okuma süresi ve okundu işareti: düz, küçük yazı (★10; mono değil).
TextStyle yzMerkezMeta({Color renk = YzRenk.soluk, FontWeight kalinlik = FontWeight.w500}) =>
    GoogleFonts.outfit(fontSize: 13, fontWeight: kalinlik, color: renk, height: 1.2);

/// Telefonda teknoloji çiplerinin tek satırı (★2): yana kayıyor; taşıyorsa
/// sağ kenarda yumuşak bir solgunluk "devamı var" diyor, sonuna gelince
/// kalkıyor. Sağa kaydırılınca aynı solgunluk sol kenarda da: iki uçta da
/// kesik bir çip kalmıyor.
class YzMerkezCipSeridi extends StatefulWidget {
  const YzMerkezCipSeridi({super.key, required this.children, this.zemin = YzRenk.zemin});
  final List<Widget> children;
  final Color zemin;

  static const solgunlukAnahtari = ValueKey('yz-merkez-cip-solgunluk');
  static const solSolgunlukAnahtari = ValueKey('yz-merkez-cip-solgunluk-sol');

  @override
  State<YzMerkezCipSeridi> createState() => _YzMerkezCipSeridiState();
}

class _YzMerkezCipSeridiState extends State<YzMerkezCipSeridi> {
  final _kaydirma = ScrollController();
  bool _solgun = false;
  bool _solSolgun = false;

  @override
  void initState() {
    super.initState();
    _kaydirma.addListener(_guncelle);
    WidgetsBinding.instance.addPostFrameCallback((_) => _guncelle());
  }

  void _guncelle() {
    if (!mounted || !_kaydirma.hasClients) return;
    final p = _kaydirma.position;
    if (!p.hasContentDimensions) return;
    final sag = p.maxScrollExtent > 0.5 && p.pixels < p.maxScrollExtent - 0.5;
    final sol = p.maxScrollExtent > 0.5 && p.pixels > 0.5;
    if (sag != _solgun || sol != _solSolgun) {
      setState(() {
        _solgun = sag;
        _solSolgun = sol;
      });
    }
  }

  @override
  void dispose() {
    _kaydirma.removeListener(_guncelle);
    _kaydirma.dispose();
    super.dispose();
  }

  Widget _solgunluk(Key anahtar, bool gorunur, {required bool sol}) {
    final bos = widget.zemin.withValues(alpha: 0);
    return Positioned(
      top: 0,
      bottom: 0,
      left: sol ? 0 : null,
      right: sol ? null : 0,
      width: 44,
      child: IgnorePointer(
        child: AnimatedOpacity(
          key: anahtar,
          duration: const Duration(milliseconds: 160),
          opacity: gorunur ? 1 : 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: sol ? [widget.zemin, bos] : [bos, widget.zemin],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _guncelle());
        return false;
      },
      child: Stack(children: [
        SingleChildScrollView(
          controller: _kaydirma,
          scrollDirection: Axis.horizontal,
          child: Row(children: widget.children),
        ),
        _solgunluk(YzMerkezCipSeridi.solSolgunlukAnahtari, _solSolgun, sol: true),
        _solgunluk(YzMerkezCipSeridi.solgunlukAnahtari, _solgun, sol: false),
      ]),
    );
  }
}
