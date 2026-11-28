import 'package:flutter/material.dart';

import 'yz_tasarim.dart';

/// Başlık sayfalarının ortak iskeleti (mizansen turu, 28 Kasım 2026).
///
/// Süreç, alan ve zincir başlıklarının çoğu aynı sırayı izliyor: *Ne
/// yapıyor → Saha ne diyor → Yapay zekâ nerede duruyor → Türkiye*. Her
/// kesit türü sabit bir küçük simge ve renk tonuyla çiziliyor: okur kalıbı
/// bir kez öğreniyor, öbür başlıklarda aynı kesite doğrudan gidiyor. Alt
/// başlığın METNİ değişmiyor; eşleşme birebir başlık adıyla (sözcük
/// avlamak yok — "Türkiye'de durum" gibi başlık ADLARI kesit sayılmıyor).
enum YzKesitTuru { ne, saha, yz, turkiye }

const Map<String, YzKesitTuru> _kesitler = {
  'Ne yapıyor': YzKesitTuru.ne,
  'What it does': YzKesitTuru.ne,
  'Saha ne diyor': YzKesitTuru.saha,
  'Saha denemeleri ne diyor': YzKesitTuru.saha,
  'What the field says': YzKesitTuru.saha,
  'What the field trials say': YzKesitTuru.saha,
  'Yapay zekâ nerede duruyor': YzKesitTuru.yz,
  'Where AI stands': YzKesitTuru.yz,
  'Türkiye': YzKesitTuru.turkiye,
  "Türkiye'de kullanım": YzKesitTuru.turkiye,
  'Usage in Türkiye': YzKesitTuru.turkiye,
};

/// Alt başlığın kesit türü; ortak iskeletten değilse null.
YzKesitTuru? yzKesitTuru(String altBaslik) => _kesitler[altBaslik.trim()];

/// Türkiye kesitinin rengi: soluk bir kiremit — bölümün iki sesinden
/// (makine mavisi, bitki yeşili) ve bekleyenin hardalından ayrı. Zemin ve
/// beyaz üstünde 4,5:1'in üstünde.
const Color kYzTurkiyeRengi = Color(0xFFA8402F);
const Color kYzTurkiyeAcik = Color(0xFFF6E5E0);

(IconData, Color, Color) _gorunus(YzKesitTuru t) => switch (t) {
      YzKesitTuru.ne => (Icons.settings_suggest_outlined, YzRenk.murekkep, const Color(0xFFE6EAE4)),
      YzKesitTuru.saha => (Icons.grass_rounded, YzRenk.bitki, YzRenk.bitkiAcik),
      YzKesitTuru.yz => (Icons.memory_rounded, YzRenk.makine, YzRenk.makineAcik),
      YzKesitTuru.turkiye => (Icons.place_outlined, kYzTurkiyeRengi, kYzTurkiyeAcik),
    };

/// Kesitin simgesi: yuvarlak köşeli küçük kare içinde. Anlamı yanındaki
/// başlık taşıyor; ekran okuyucuya kapalı.
class YzKesitSimgesi extends StatelessWidget {
  const YzKesitSimgesi(this.tur, {super.key, this.boy = 30});
  final YzKesitTuru tur;
  final double boy;

  @override
  Widget build(BuildContext context) {
    final (simge, renk, zemin) = _gorunus(tur);
    return ExcludeSemantics(
      child: Container(
        width: boy,
        height: boy,
        decoration: BoxDecoration(color: zemin, borderRadius: BorderRadius.circular(boy * 0.27)),
        alignment: Alignment.center,
        child: Icon(simge, size: boy * 0.6, color: renk),
      ),
    );
  }
}
