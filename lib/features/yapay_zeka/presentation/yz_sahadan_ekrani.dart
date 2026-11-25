import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/turkce_metin.dart';
import '../data/yz_iskelet.g.dart';
import '../data/yz_sahadan.g.dart';
import 'yz_mobil.dart';
import 'yz_parcalar.dart';
import 'yz_sahadan_tam_ekran.dart';
import 'yz_tasarim.dart';

/// Sahadan — `/yapay-zeka-dijital-tarim/sahadan` (25 Kasım 2026).
///
/// Türkiye'de dijital tarımın sahadan fotoğrafları: sahibin seçtiği kareler
/// (`_raw/sahadan.json` → `yz_sahadan.g.dart`), her biri yayımlayan kurumun
/// künyesi ve kaynağıyla. Künye fotoğrafın ne olduğunu söylüyor (proje ya da
/// sistem, yer, tarih); kaynak satırı "Fotoğraf: <yayımlayan kurum>", yanında
/// kurumun sayfasına bağlantı. Başlık içinde de duran karenin dosyası ve
/// künyesi ortak (doğrulayıcı kural 21).
///
/// Izgara: telefonda (< 640 px) tek sütun, daha geniş ekranda 2, içerik
/// 900 pikseli aşınca 3 sütun; yatay kaydırma yok. Fotoğrafa dokununca erteli
/// tam ekran görüntüleyici (yz_sahadan_tam_ekran.dart) bütün dizide geziyor.
/// Her kartta ilgili başlığa (alt başlığıyla, `?bolum=`) ve atlastaki iline
/// (`?il=`; ili olmayan karede yok) küçük bağlantılar.
class YzSahadanEkrani extends StatelessWidget {
  const YzSahadanEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    final telefon = yzTelefon(context);
    return Scaffold(
      backgroundColor: YzRenk.zemin,
      body: Column(children: [
        const YzUstSerit(geriAdres: yzPath),
        Expanded(
          child: YzOlcekliIcerik(
            child: LayoutBuilder(builder: (context, kis) {
              final yan = kis.maxWidth < 640 ? 16.0 : 32.0;
              return SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(yan, telefon ? 24 : 44, yan, 56),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(buyukHarf(en ? 'Gallery' : 'Galeri', en),
                              style: YzYazi.ustEtiket(renk: YzRenk.makine)),
                          const SizedBox(height: 12),
                          Semantics(
                            header: true,
                            child: Text(en ? kYzSahadanAdEn : kYzSahadanAdTr,
                                style: YzYazi.baslik(telefon ? 30 : 42)),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 760),
                              child: Text(yzSahadanAciklamasi(en),
                                  style: YzYazi.govde(boy: telefon ? 17 : 18, renk: YzRenk.soluk)),
                            ),
                          ),
                          SizedBox(height: telefon ? 26 : 34),
                          const YzSahadanIzgarasi(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ]),
    );
  }
}

/// Sayfanın ve merkez kartının tek satırlık açıklaması (ekranın kendi yazısı).
String yzSahadanAciklamasi(bool en) => en
    ? "Photographs of digital agriculture in Türkiye from the field, each with the publishing institution's caption and source."
    : "Türkiye'de dijital tarımın sahadan fotoğrafları; her biri yayımlayan kurumun künyesi ve kaynağıyla.";

/// Sütun sayısı: telefonda 1, içerik 900 pikselden darsa 2, değilse 3.
int yzSahadanSutun(double genislik, {required bool telefon}) => telefon ? 1 : (genislik < 900 ? 2 : 3);

/// Galerinin ızgarası. Satırlar üstten hizalı (künyeler farklı uzunlukta);
/// kartlar çerçevesiz, aralarında boşluk.
class YzSahadanIzgarasi extends StatelessWidget {
  const YzSahadanIzgarasi({super.key, this.kareler = kYzSahadan});
  final List<YzSahadanKare> kareler;

  @override
  Widget build(BuildContext context) {
    final telefon = yzTelefon(context);
    return LayoutBuilder(builder: (context, kis) {
      final sutun = yzSahadanSutun(kis.maxWidth, telefon: telefon);
      final satirlar = <Widget>[];
      for (var i = 0; i < kareler.length; i += sutun) {
        if (i > 0) satirlar.add(SizedBox(height: telefon ? 34 : 44));
        satirlar.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var j = 0; j < sutun; j++) ...[
              if (j > 0) const SizedBox(width: 28),
              Expanded(
                child: i + j < kareler.length
                    ? _KareKarti(kareler: kareler, sira: i + j)
                    : const SizedBox.shrink(),
              ),
            ],
          ],
        ));
      }
      return Column(
        key: const ValueKey('yz-sahadan-izgara'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: satirlar,
      );
    });
  }
}

/// Başlığın kısa adı: iki noktadan öncesi (atlasın kartlarındaki kural).
String _kisaAd(YzBaslik b, bool en) => b.ad(en).split(':').first.trim();

/// Galerideki kart: fotoğraf (3:2, dokununca tam ekran), künye, kaynak
/// satırı, "Kaynağı aç ↗" ve küçük bağlantılar.
class _KareKarti extends StatelessWidget {
  const _KareKarti({required this.kareler, required this.sira});
  final List<YzSahadanKare> kareler;
  final int sira;

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    final k = kareler[sira];
    final yonlendirici = GoRouter.maybeOf(context);
    final b = yzBaslik(k.baslikNo);
    final bolum = k.bolum(en);
    final baslikAdresi = b == null
        ? null
        : Uri(path: yzBaslikPath(b.slug), queryParameters: bolum == null ? null : {'bolum': etiketSlug(bolum)})
            .toString();
    final atlasAdresi =
        k.plaka == null ? null : Uri(path: yzAtlasPath, queryParameters: {'il': '${k.plaka}'}).toString();
    void ac() => yzSahadanTamEkran(context, baslangic: sira, en: en, kareler: kareler);
    return Column(
      key: ValueKey('yz-sahadan-kare-${k.harf}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          image: true,
          label: en ? 'Photo: open full screen' : 'Fotoğraf: tam ekranda aç',
          excludeSemantics: true,
          onTap: ac,
          child: MouseRegion(
            cursor: SystemMouseCursors.zoomIn,
            child: GestureDetector(
              key: ValueKey('yz-sahadan-foto-${k.harf}'),
              onTap: ac,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: AspectRatio(
                  aspectRatio: 3 / 2,
                  child: ColoredBox(
                    color: YzRenk.cizgi,
                    child: Image.network(
                      k.adres,
                      fit: BoxFit.cover,
                      errorBuilder: (c, h, i) =>
                          const Center(child: Icon(Icons.image_not_supported_outlined, color: YzRenk.soluk)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(k.kunye(en), style: YzYazi.govde(boy: 15.5).copyWith(height: 1.5)),
        const SizedBox(height: 6),
        Text(k.kaynak(en), style: YzYazi.veri(boy: 11.5, renk: YzRenk.soluk).copyWith(height: 1.45)),
        const SizedBox(height: 2),
        Wrap(
          spacing: 18,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _Baglanti(
              key: ValueKey('yz-sahadan-kaynak-${k.harf}'),
              yazi: en ? 'Open the source ↗' : 'Kaynağı aç ↗',
              bas: () {
                final uri = Uri.tryParse(k.sayfaAdresi);
                if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication);
              },
            ),
            if (b != null && baslikAdresi != null)
              _Baglanti(
                key: ValueKey('yz-sahadan-baslik-${k.harf}'),
                yazi: en ? 'In the file: ${_kisaAd(b, en)}' : 'Dosyada: ${_kisaAd(b, en)}',
                bas: yonlendirici == null ? null : () => context.push(baslikAdresi),
              ),
            if (atlasAdresi != null && k.il != null)
              _Baglanti(
                key: ValueKey('yz-sahadan-atlas-${k.harf}'),
                yazi: en ? 'In the atlas: ${k.il}' : "Atlas'ta: ${k.il}",
                bas: yonlendirici == null ? null : () => context.push(atlasAdresi),
              ),
          ],
        ),
      ],
    );
  }
}

/// Kartın küçük bağlantısı: mono, çelik mavisi, 40 piksel dokunma yüksekliği;
/// yazısı künyenin sol kenarıyla hizalı (yan dolgu yok).
class _Baglanti extends StatelessWidget {
  const _Baglanti({super.key, required this.yazi, required this.bas});
  final String yazi;
  final VoidCallback? bas;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: bas,
        style: TextButton.styleFrom(
          foregroundColor: YzRenk.makine,
          padding: EdgeInsets.zero,
          minimumSize: const Size(40, 40),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(yazi, style: YzYazi.veri(boy: 12.5, renk: YzRenk.makine).copyWith(height: 1.35)),
      );
}

// ── Merkez sayfadaki giriş kartı ─────────────────────────────────────────

/// Merkez sayfada atlas kartının hemen altında, aynı biçimde: galerinin adı,
/// açıklaması, sağda `merkez` işaretli kareler (küçük resim) ve ok.
/// Küçük resmin kaynağı üzerine gelince (ve ekran okuyucuda) yazıyor;
/// künye ve kaynak satırı galeride.
class YzSahadanKarti extends StatelessWidget {
  const YzSahadanKarti({super.key});

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    final telefon = yzTelefon(context);
    final yonlendirici = GoRouter.maybeOf(context);
    final ad = en ? kYzSahadanAdEn : kYzSahadanAdTr;
    final aciklama = yzSahadanAciklamasi(en);
    final resimler = _KucukResimler(
      kareler: [for (final k in kYzSahadan) if (k.merkez) k],
      genislik: telefon ? 64 : 72,
      en: en,
    );
    const ok = Icon(Icons.arrow_forward_rounded, color: YzRenk.makine);
    return Semantics(
      button: true,
      child: Material(
        key: const ValueKey('yz-sahadan-karti'),
        color: YzRenk.yuzey,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: yonlendirici == null ? null : () => context.push(yzSahadanPath),
          child: Container(
            padding: EdgeInsets.all(telefon ? 14 : 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: YzRenk.cizgi),
            ),
            child: telefon
                ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(child: Text(ad, style: YzYazi.baslik(19).copyWith(height: 1.25))),
                      const SizedBox(width: 8),
                      ok,
                    ]),
                    const SizedBox(height: 6),
                    Text(aciklama, style: YzYazi.govde(boy: 15.5, renk: YzRenk.soluk).copyWith(height: 1.45)),
                    const SizedBox(height: 12),
                    resimler,
                  ])
                : Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(ad, style: YzYazi.baslik(21).copyWith(height: 1.25)),
                        const SizedBox(height: 6),
                        Text(aciklama,
                            style: YzYazi.govde(boy: 15.5, renk: YzRenk.soluk).copyWith(height: 1.45)),
                      ]),
                    ),
                    const SizedBox(width: 24),
                    resimler,
                    const SizedBox(width: 18),
                    ok,
                  ]),
          ),
        ),
      ),
    );
  }
}

/// Merkez kartının küçük resimleri (4:3, aralarında 6 piksel).
class _KucukResimler extends StatelessWidget {
  const _KucukResimler({required this.kareler, required this.genislik, required this.en});
  final List<YzSahadanKare> kareler;
  final double genislik;
  final bool en;

  @override
  Widget build(BuildContext context) {
    final boy = (genislik * 3 / 4).roundToDouble();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < kareler.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Tooltip(
            message: kareler[i].kaynak(en),
            waitDuration: const Duration(milliseconds: 300),
            child: ClipRRect(
              key: ValueKey('yz-sahadan-kucuk-${kareler[i].harf}'),
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                width: genislik,
                height: boy,
                child: ColoredBox(
                  color: YzRenk.cizgi,
                  child: Image.network(
                    kareler[i].adres,
                    fit: BoxFit.cover,
                    excludeFromSemantics: true,
                    errorBuilder: (c, h, x) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
