import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/yz_rakam_kaynaklari.g.dart';
import 'yz_tasarim.dart';

/// Rakamdan kaynağa (karar 58): metindeki kalın bir rakama dokununca o
/// rakamın geldiği kaynağın künyesi, belgeden birebir alıntısı ve bağlantısı
/// bir balonda açılıyor. Eşleme `_raw/rakam_kaynaklari.py`'den; her rakam
/// ayrıca kayda karşı doğrulayıcıdan geçiyor.
///
/// [sayfa]: "bNN" (başlık) ya da "tek_<kod>" (teknoloji sayfası).
bool yzRakamKaynagiVar(String sayfa, String kalin, bool en) =>
    kYzRakamKaynak['$sayfa:${en ? 'en' : 'tr'}']?.containsKey(kalin) ?? false;

Future<void> yzKaynakBalonu(
    BuildContext context, String sayfa, String kalin, Offset konum, bool en) {
  final adaylar = kYzRakamKaynak['$sayfa:${en ? 'en' : 'tr'}']?[kalin] ?? const [];
  final kunyeler = kYzKaynakKunye[sayfa] ?? const {};
  return showDialog<void>(
    context: context,
    barrierColor: Colors.transparent,
    barrierDismissible: true,
    barrierLabel: en ? 'Close' : 'Kapat',
    useSafeArea: false,
    builder: (ctx) {
      final ekran = MediaQuery.sizeOf(ctx);
      final genislik = math.min(380.0, ekran.width - 24);
      final sol = (konum.dx - genislik / 2)
          .clamp(12.0, math.max(12.0, ekran.width - genislik - 12))
          .toDouble();
      final ustte = konum.dy > ekran.height * 0.58;
      return Stack(children: [
        Positioned(
          left: sol,
          width: genislik,
          top: ustte ? null : konum.dy + 16,
          bottom: ustte ? ekran.height - konum.dy + 16 : null,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: ekran.height * 0.6),
            child: Semantics(
              container: true,
              label: en ? 'Source of $kalin' : '$kalin rakamının kaynağı',
              child: Material(
                color: YzRenk.yuzey,
                elevation: 6,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: YzRenk.cizgi),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          adaylar.length > 1
                              ? (en ? 'Sources of $kalin' : '$kalin · kaynaklar')
                              : (en ? 'Source of $kalin' : '$kalin · kaynak'),
                          style: YzYazi.ustEtiket(renk: YzRenk.makine),
                        ),
                        for (final a in adaylar) ...[
                          const SizedBox(height: 8),
                          Text(kunyeler[a[0]]?[0] ?? a[0],
                              style: YzYazi.govde(boy: 14).copyWith(height: 1.4)),
                          if (a[1].isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.only(left: 10),
                              decoration: const BoxDecoration(
                                border: Border(left: BorderSide(color: YzRenk.cizgi, width: 2)),
                              ),
                              child: Text('“${a[1]}”',
                                  style: YzYazi.govde(boy: 13.5, renk: YzRenk.soluk)
                                      .copyWith(fontStyle: FontStyle.italic, height: 1.45)),
                            ),
                          ],
                          if ((kunyeler[a[0]]?[1] ?? '').isNotEmpty)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                onPressed: () {
                                  final uri = Uri.tryParse(kunyeler[a[0]]![1]);
                                  if (uri != null) {
                                    launchUrl(uri, mode: LaunchMode.externalApplication);
                                  }
                                },
                                child: Text(en ? 'Open the source ↗' : 'Kaynağı aç ↗',
                                    style: YzYazi.veri(boy: 12.5, renk: YzRenk.makine)),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ]);
    },
  );
}
