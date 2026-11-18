import 'package:flutter/material.dart';

import '../data/yz_grafik_veri.dart';
import 'yz_aifs_semasi.dart';
import 'yz_semalar.dart';
import 'yz_tasarim.dart';

/// Metindeki görsel (karar 58): görsel, altında künye ve kaynak satırı.
/// Dokununca tam ekranda, yakınlaştırılabilir açılıyor.
///
/// Bazı İngilizce bilgi şemalarının Türkçe sayfada çizilmiş uyarlaması var
/// ([_cizim]); İngilizce sayfada özgün görsel gösteriliyor.
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
              // Görselin tamamı görünür (şekil, harita ve grafikte kenar
              // kesilmez); dikey görsel en çok 560 piksel boyunda kalır,
              // yanları zeminle dolar.
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: _cizim(g.kimlik, en) ?? LayoutBuilder(builder: (context, kis) {
                  final boy = (kis.maxWidth / g.oran).clamp(120.0, 560.0).toDouble();
                  return Container(
                    height: boy,
                    color: YzRenk.zemin,
                    alignment: Alignment.center,
                    child: Image.network(
                      g.adres,
                      fit: BoxFit.contain,
                      errorBuilder: (c, h, i) => const Center(
                          child: Icon(Icons.image_not_supported_outlined, color: YzRenk.soluk)),
                    ),
                  );
                }),
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
              // Çizim büyütmede 1000 piksel genişlikte (geniş düzen) kurulup
              // ekrana sığdırılıyor; telefonda sütunlar sıkışmıyor.
              child: Center(child: _buyukGorunum()),
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

extension on YzGorselKarti {
  Widget _buyukGorunum() {
    final cizim = _cizim(gorsel.kimlik, en, buyuk: true);
    if (cizim == null) return Image.network(gorsel.adres, fit: BoxFit.contain);
    return FittedBox(fit: BoxFit.contain, child: SizedBox(width: 1000, child: cizim));
  }
}

/// Türkçe sayfada çizilmiş uyarlaması olan görseller (özgünü İngilizce).
Widget? _cizim(String kimlik, bool en, {bool buyuk = false}) {
  if (en) return null;
  return switch (kimlik) {
    'b01-ecmwf-nin-yapay-zeka-tahmin-sistemi' => YzAifsSemasi(genisZorla: buyuk),
    'b02-ers-nin-dijital-tarim-bilesenleri' => YzErsSemasi(genisZorla: buyuk),
    'b02-cema-nin-dijital-tarim-tarifi' => YzCemaSemasi(genisZorla: buyuk),
    't-dil-digital-green-in-sohbet-robotu' => YzFarmerChatSemasi(genisZorla: buyuk),
    _ => null,
  };
}
