import 'package:flutter/material.dart';

import '../data/yz_grafik_veri.dart';
import 'yz_tasarim.dart';

/// Metindeki görsel (karar 58): görsel, altında künye ve kaynak satırı.
/// Dokununca tam ekranda, yakınlaştırılabilir açılıyor.
class YzGorselKarti extends StatelessWidget {
  const YzGorselKarti({super.key, required this.gorsel, required this.en});
  final YzGorsel gorsel;
  final bool en;

  @override
  Widget build(BuildContext context) {
    final g = gorsel;
    final kaynak = g.yapayZeka
        ? '${g.kaynak(en)} · ${en ? 'AI-generated illustration' : 'yapay zekâ ile üretilmiş çizim'}'
        : g.kaynak(en);
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Semantics(
          image: true,
          label: g.kunye(en),
          child: GestureDetector(
            onTap: () => _buyut(context),
            child: MouseRegion(
              cursor: SystemMouseCursors.zoomIn,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: AspectRatio(
                  aspectRatio: g.oran.clamp(0.6, 2.4),
                  child: Container(
                    color: YzRenk.zemin,
                    child: Image.network(
                      g.adres,
                      fit: BoxFit.cover,
                      errorBuilder: (c, h, i) => const Center(
                          child: Icon(Icons.image_not_supported_outlined, color: YzRenk.soluk)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(g.kunye(en), style: YzYazi.govde(boy: 14.5, renk: YzRenk.murekkep).copyWith(height: 1.45)),
        const SizedBox(height: 3),
        Text(kaynak, style: YzYazi.veri(boy: 11.5, renk: YzRenk.soluk)),
      ]),
    );
  }

  void _buyut(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (c) => GestureDetector(
        onTap: () => Navigator.of(c).pop(),
        child: Stack(children: [
          Positioned.fill(
            child: InteractiveViewer(
              maxScale: 4,
              child: Center(child: Image.network(gorsel.adres, fit: BoxFit.contain)),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Text('${gorsel.kunye(en)} — ${gorsel.kaynak(en)}',
                style: YzYazi.veri(boy: 12, renk: Colors.white)),
          ),
        ]),
      ),
    );
  }
}
