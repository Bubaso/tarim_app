import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'yz_tasarim.dart';

/// Görselin altyazısı: künye, (varsa) harita açıklaması ve kaynak satırı.
///
/// Künyeler uzun (123 görselde ortanca 249 harf, 80'i 220'yi aşıyor) ve
/// metnin akışını kesiyordu. Kullanıcı (18 Kasım 2026): uzun açıklama ve
/// referanslar okur isterse açılsın. Kapalıyken künye iki satır, kaynak
/// satırı tek satır — lisans künyesi hep görünüyor; harita açıklaması
/// (lejant) okumanın parçası, hiç katlanmıyor. Sığan altyazı eskisi gibi,
/// düğmesiz. Tam ekran görüntüleyici altyazının tamamını gösteriyor.
class YzGorselAltyazisi extends StatefulWidget {
  const YzGorselAltyazisi({
    super.key,
    required this.kunye,
    required this.kaynak,
    required this.kaynakYazisi,
    required this.en,
    this.lejant,
  });

  final String kunye;
  final String? lejant;
  final String kaynak;
  final TextStyle kaynakYazisi;
  final bool en;

  /// Kapalıyken künyenin satır sayısı.
  static const int kapaliSatir = 2;

  @override
  State<YzGorselAltyazisi> createState() => _YzGorselAltyazisiState();
}

class _YzGorselAltyazisiState extends State<YzGorselAltyazisi> {
  bool _acik = false;

  static TextStyle get _kunyeYazisi =>
      YzYazi.govde(boy: 14.5, renk: YzRenk.murekkep).copyWith(height: 1.45);

  bool _tasiyor(String metin, TextStyle stil, int satir, double genislik) {
    final p = TextPainter(
      text: TextSpan(text: metin, style: stil),
      maxLines: satir,
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: genislik);
    final tasti = p.didExceedMaxLines;
    p.dispose();
    return tasti;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, kis) {
      final w = kis.maxWidth;
      final katlanir = _tasiyor(widget.kunye, _kunyeYazisi, YzGorselAltyazisi.kapaliSatir, w) ||
          _tasiyor(widget.kaynak, widget.kaynakYazisi, 1, w);
      final kapali = katlanir && !_acik;
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(
          widget.kunye,
          style: _kunyeYazisi,
          maxLines: kapali ? YzGorselAltyazisi.kapaliSatir : null,
          overflow: kapali ? TextOverflow.ellipsis : null,
        ),
        if (widget.lejant != null) ...[
          const SizedBox(height: 4),
          Text(widget.lejant!,
              style: YzYazi.govde(boy: 13.5, renk: YzRenk.soluk).copyWith(height: 1.4)),
        ],
        const SizedBox(height: 3),
        Text(
          widget.kaynak,
          style: widget.kaynakYazisi,
          maxLines: kapali ? 1 : null,
          overflow: kapali ? TextOverflow.ellipsis : null,
        ),
        if (katlanir)
          Align(
            alignment: Alignment.centerLeft,
            child: Semantics(
              button: true,
              expanded: _acik,
              child: InkWell(
                onTap: () => setState(() => _acik = !_acik),
                borderRadius: BorderRadius.circular(4),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 40),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2, right: 8),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(
                        _acik
                            ? (widget.en ? 'Show less' : 'Daha az göster')
                            : (widget.en ? 'Read more' : 'Devamını oku'),
                        style: GoogleFonts.outfit(
                            fontSize: 13, fontWeight: FontWeight.w600, color: YzRenk.makine),
                      ),
                      Icon(_acik ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                          size: 18, color: YzRenk.makine),
                    ]),
                  ),
                ),
              ),
            ),
          ),
      ]);
    });
  }
}
