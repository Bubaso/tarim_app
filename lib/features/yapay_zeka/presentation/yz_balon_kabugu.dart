import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'yz_mobil.dart';
import 'yz_tasarim.dart';

/// Metin içi balonların ortak kabuğu: kaynak (rakam), sözlük terimi ve
/// kısaltma balonu aynı içeriği iki biçimde açıyor.
///
/// * Masaüstü ve tablet (≥ 640 px): dokunulan yerin altında (ekranın alt
///   kısmındaysa üstünde) açılan küçük kart; dışarı dokununca ya da Esc ile
///   kapanıyor. Görünümü mobil turdan önceki ile birebir aynı.
/// * Telefon (< 640 px, mobil okuma turu, karar 62): aynı içerik alttan açılan
///   sayfada ([yzAltSayfa]). Okunan satırı örtmüyor; aşağı çekince ya da
///   dışarı dokununca kapanıyor; uzunsa kayıyor.
///
/// [icerik] içeriği bir kez kuruyor; `telefon` bayrağı yalnız yazı boyunu ve
/// bağlantıların dokunma alanını değiştiriyor. `ctx` balonun kendi bağlamı:
/// `Navigator.of(ctx).pop()` balonu (ya da alt sayfayı) kapatır.
Future<void> yzBalonAc(
  BuildContext context, {
  required Offset konum,
  required bool en,
  required String etiket,
  required double genislik,
  required double ustteOrani,
  required EdgeInsets dolgu,
  double? azamiYukseklikOrani,
  required Widget Function(BuildContext ctx, bool telefon) icerik,
}) {
  if (yzTelefon(context)) {
    return yzAltSayfa<void>(
      context,
      builder: (ctx) => Semantics(
        container: true,
        label: etiket,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: icerik(ctx, true),
        ),
      ),
    );
  }
  return showDialog<void>(
    context: context,
    barrierColor: Colors.transparent,
    barrierDismissible: true,
    barrierLabel: en ? 'Close' : 'Kapat',
    useSafeArea: false,
    builder: (ctx) {
      final ekran = MediaQuery.sizeOf(ctx);
      final g = math.min(genislik, ekran.width - 24);
      final sol = (konum.dx - g / 2)
          .clamp(12.0, math.max(12.0, ekran.width - g - 12))
          .toDouble();
      final ustte = konum.dy > ekran.height * ustteOrani;
      Widget kart = Semantics(
        container: true,
        label: etiket,
        child: Material(
          color: YzRenk.yuzey,
          elevation: 6,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: dolgu,
            decoration: BoxDecoration(
              border: Border.all(color: YzRenk.cizgi),
              borderRadius: BorderRadius.circular(6),
            ),
            child: azamiYukseklikOrani == null
                ? icerik(ctx, false)
                : SingleChildScrollView(child: icerik(ctx, false)),
          ),
        ),
      );
      if (azamiYukseklikOrani != null) {
        kart = ConstrainedBox(
          constraints: BoxConstraints(maxHeight: ekran.height * azamiYukseklikOrani),
          child: kart,
        );
      }
      return Stack(children: [
        Positioned(
          left: sol,
          width: g,
          top: ustte ? null : konum.dy + 16,
          bottom: ustte ? ekran.height - konum.dy + 16 : null,
          child: kart,
        ),
      ]);
    },
  );
}

/// Telefondaki alt sayfada bağlantı ya da eylem: tam genişlik, 48 px yüksek,
/// yumuşak zeminli, yuvarlak köşeli (sol çizgi yok).
class YzBalonEylemi extends StatelessWidget {
  const YzBalonEylemi({super.key, required this.yazi, required this.onPressed});

  final String yazi;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 48,
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            backgroundColor: YzRenk.makineAcik,
            foregroundColor: YzRenk.makine,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(yazi,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: YzYazi.veri(boy: 13.5, renk: YzRenk.makine, kalinlik: FontWeight.w600)),
        ),
      );
}
