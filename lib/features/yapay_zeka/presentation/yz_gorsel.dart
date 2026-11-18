import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/yz_grafik_veri.dart';
import 'yz_aifs_semasi.dart';
import 'yz_gorsel_altyazi.dart';
import 'yz_gorsel_mobil.dart';
import 'yz_gorsel_tam_ekran.dart';
import 'yz_mobil.dart';
import 'yz_semalar.dart';
import 'yz_tasarim.dart';

/// Metindeki görsel (karar 58): görsel, altında künye ve kaynak satırı.
/// Dokununca tam ekranda, yakınlaştırılabilir açılıyor.
///
/// Bazı İngilizce bilgi şemalarının Türkçe sayfada çizilmiş uyarlaması var
/// ([_cizim]); İngilizce sayfada özgün görsel gösteriliyor.
///
/// Telefonda (< 640 px, mobil okuma turu) ayrı düzen: [_telefon].
class YzGorselKarti extends StatelessWidget {
  const YzGorselKarti({super.key, required this.gorsel, required this.en});
  final YzGorsel gorsel;
  final bool en;

  String get _kaynakSatiri => gorsel.yapayZeka
      ? '${gorsel.kaynak(en)} · ${en ? 'AI-generated illustration' : 'yapay zekâ ile üretilmiş çizim'}'
      : gorsel.kaynak(en);

  @override
  Widget build(BuildContext context) {
    if (yzTelefon(context)) return _telefon(context);
    final g = gorsel;
    final kaynak = _kaynakSatiri;
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
                      g.adresi(en),
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
        YzGorselAltyazisi(
          kunye: g.kunye(en),
          lejant: !en ? g.lejantTr : null,
          kaynak: kaynak,
          kaynakYazisi: YzYazi.veri(boy: 11.5, renk: YzRenk.soluk),
          en: en,
        ),
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
  /// Telefon düzeni (mobil okuma turu, karar 62):
  ///  · fotoğraf ve raster şekil kenardan kenara: makale sütununun 16 piksel
  ///    yan payından taşıyor, ekran kenarında köşe yuvarlatılmıyor; künye ve
  ///    kaynak satırı metin payının içinde kalıyor;
  ///  · dokununca tam ekran gösterim (koyu zemin, 4 kata kadar yakınlaştırma);
  ///  · çizilmiş şemalar (ECMWF/AIFS, ERS, CEMA, FarmerChat) ve ekran boyunun
  ///    %85'ini aşan görsel katlanıyor (yz_gorsel_mobil.dart);
  ///  · kaynak satırı mono değil, sade küçük Outfit.
  Widget _telefon(BuildContext context) {
    final g = gorsel;
    final ekran = MediaQuery.sizeOf(context);
    final cizim = _cizim(g.kimlik, en);
    // Çizilmiş şema tam ekranda dar düzeninde, ekran genişliğinde kuruluyor
    // ve dikey kaydırılıyor (1000 piksellik geniş düzen telefona sığdırılınca
    // yazıları okunmuyordu).
    void ac() => yzGorselTamEkran(context,
        gorunum: _buyukGorunum(telefon: true),
        altyazi: '${g.kunye(en)} — ${g.kaynak(en)}',
        en: en,
        uzun: cizim != null);
    Widget dokunulur(Widget cocuk) => Semantics(
          image: true,
          label: g.kunye(en),
          child: GestureDetector(onTap: ac, child: cocuk),
        );
    final Widget gorselAlani;
    if (cizim != null) {
      // Çizilmiş şema sütunun içinde kalıyor (kenardan kenara yalnız
      // fotoğraf ve raster şekil).
      gorselAlani = YzGorselKatlanir(
        en: en,
        child: dokunulur(ClipRRect(borderRadius: BorderRadius.circular(4), child: cizim)),
      );
    } else {
      gorselAlani = LayoutBuilder(builder: (context, kis) {
        // Makale sütununun yan payı telefonda 16 piksel (yz_makale.dart);
        // sütun ekrandan dar değilse taşma yok.
        final tasma = ((ekran.width - kis.maxWidth) / 2).clamp(0.0, 16.0).toDouble();
        final genislik = kis.maxWidth + 2 * tasma;
        final boy = (genislik / g.oran).clamp(120.0, 560.0).toDouble();
        final resim = Container(
          height: boy,
          color: YzRenk.zemin,
          alignment: Alignment.center,
          child: Image.network(
            g.adresi(en),
            fit: BoxFit.contain,
            errorBuilder: (c, h, i) =>
                const Center(child: Icon(Icons.image_not_supported_outlined, color: YzRenk.soluk)),
          ),
        );
        return YzGorselKatlanir(
          en: en,
          sema: false,
          tasma: tasma,
          // Ekran boyunun %85'ini aşan görsel katlanıyor. Alt sınır: katlama
          // en az 60 pikseli gizlemeli, yoksa düğme kazandırdığından fazla
          // yer kaplıyor (çok kısa ekranlar).
          esik: math.max(ekran.height * 0.85, kYzKatliBoy + 60),
          child: dokunulur(tasma > 0
              ? resim
              : ClipRRect(borderRadius: BorderRadius.circular(4), child: resim)),
        );
      });
    }
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        gorselAlani,
        const SizedBox(height: 8),
        YzGorselAltyazisi(
          kunye: g.kunye(en),
          lejant: !en ? g.lejantTr : null,
          kaynak: _kaynakSatiri,
          kaynakYazisi: yzKunyeYazisi(),
          en: en,
        ),
      ]),
    );
  }

  Widget _buyukGorunum({bool telefon = false}) {
    final cizim = _cizim(gorsel.kimlik, en, buyuk: !telefon);
    if (cizim == null) {
      return Image.network(gorsel.adresi(en),
          fit: BoxFit.contain,
          // Telefonun tam ekran gösteriminde yüklenemeyen görsel için simge.
          errorBuilder: telefon
              ? (c, h, i) => const Icon(Icons.image_not_supported_outlined, color: Colors.white54, size: 40)
              : null);
    }
    if (telefon) return cizim;
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
