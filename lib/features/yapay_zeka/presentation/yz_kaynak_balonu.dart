import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/yz_makbuz.g.dart';
import '../data/yz_rakam_kaynaklari.g.dart';
import 'yz_balon_kabugu.dart';
import 'yz_makbuz.dart';
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
  return yzBalonAc(
    context,
    konum: konum,
    en: en,
    etiket: en ? 'Source of $kalin' : '$kalin rakamının kaynağı',
    genislik: 380,
    ustteOrani: 0.58,
    dolgu: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    azamiYukseklikOrani: 0.6,
    icerik: (ctx, telefon) => _icerik(ctx, telefon, sayfa, adaylar, kunyeler, kalin, en),
  );
}

/// Balonun içeriği; masaüstü kartı ve telefondaki alt sayfa ortak.
///
/// Rakamın makbuzu (yz_makbuz.dart): alıntının yerel PDF kopyasında sayfası
/// bulunduysa kesitli kaynakta alıntının altında "Kaynağında gör · s. N"
/// (tam ekran kesit; alt sayfa ya da balon altında açık kalıyor), kesitsiz
/// (hakemli) kaynakta "Kaynağı aç" yerine "Kaynakta aç · s. N" (bağlantı
/// PDF'se o sayfada). Sayfası bulunamayan ya da PDF olmayan kaynakta balon
/// değişmiyor.
Widget _icerik(BuildContext ctx, bool telefon, String sayfa, List<List<String>> adaylar,
    Map<String, List<String>> kunyeler, String kalin, bool en) {
  void ac(String adres) {
    final uri = Uri.tryParse(adres);
    if (uri != null) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  final makbuzlar = {for (final a in adaylar) a[0]: yzMakbuz(sayfa, en, kalin, a[0])};
  String gor(YzMakbuz m) => en
      ? 'See it in the source · ${yzSayfaYazisi(m.sayfa, en)}'
      : 'Kaynağında gör · ${yzSayfaYazisi(m.sayfa, en)}';
  void goster(String kaynak) => yzMakbuzGoster(ctx,
      makbuz: makbuzlar[kaynak]!, kunye: kunyeler[kaynak]?[0] ?? kaynak, en: en);
  // Kesitsiz makbuz: bağlantı yazısı sayfayı söylüyor, adres PDF'se o sayfada.
  String acYazisi(String kaynak) {
    final m = makbuzlar[kaynak];
    if (m == null || m.kesit != null) return en ? 'Open the source ↗' : 'Kaynağı aç ↗';
    return en
        ? 'Open in the source · ${yzSayfaYazisi(m.sayfa, en)} ↗'
        : 'Kaynakta aç · ${yzSayfaYazisi(m.sayfa, en)} ↗';
  }

  String acAdresi(String kaynak) {
    final m = makbuzlar[kaynak];
    return m != null && m.kesit == null ? m.adres : kunyeler[kaynak]![1];
  }

  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (telefon)
        // Telefon: başlık satırında rakamın kendisi, yanında küçük etiket.
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          children: [
            Text(kalin, style: YzYazi.baslik(18, renk: YzRenk.makine)),
            Text(
              adaylar.length > 1
                  ? (en ? 'sources' : 'kaynaklar')
                  : (en ? 'source' : 'kaynak'),
              style: YzYazi.ustEtiket(renk: YzRenk.soluk),
            ),
          ],
        )
      else
        Text(
          adaylar.length > 1
              ? (en ? 'Sources of $kalin' : '$kalin · kaynaklar')
              : (en ? 'Source of $kalin' : '$kalin · kaynak'),
          style: YzYazi.ustEtiket(renk: YzRenk.makine),
        ),
      for (final a in adaylar) ...[
        SizedBox(height: telefon ? 14 : 8),
        Text(kunyeler[a[0]]?[0] ?? a[0],
            style: telefon
                ? YzYazi.govde(boy: 16.5).copyWith(height: 1.45)
                : YzYazi.govde(boy: 14).copyWith(height: 1.4)),
        if (a[1].isNotEmpty) ...[
          SizedBox(height: telefon ? 8 : 6),
          // Belgeden birebir alıntı: yumuşak zeminli, yuvarlak
          // köşeli kutu; sol çizgi yok (kullanıcı, 18 Kas 2026).
          Container(
            width: double.infinity,
            padding: telefon
                ? const EdgeInsets.fromLTRB(12, 10, 12, 10)
                : const EdgeInsets.fromLTRB(10, 8, 10, 8),
            decoration: BoxDecoration(
              color: YzRenk.zemin,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('“${a[1]}”',
                style: YzYazi.govde(boy: telefon ? 15.5 : 13.5, renk: YzRenk.soluk)
                    .copyWith(fontStyle: FontStyle.italic, height: 1.45)),
          ),
        ],
        if (makbuzlar[a[0]]?.kesit != null)
          if (telefon) ...[
            const SizedBox(height: 10),
            // Telefon: alt sayfa açık kalıyor; kesit onun üstünde açılıyor.
            YzBalonEylemi(yazi: gor(makbuzlar[a[0]]!), onPressed: () => goster(a[0])),
          ] else
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                onPressed: () => goster(a[0]),
                child: Text(gor(makbuzlar[a[0]]!), style: YzYazi.veri(boy: 12.5, renk: YzRenk.makine)),
              ),
            ),
        if ((kunyeler[a[0]]?[1] ?? '').isNotEmpty)
          if (telefon) ...[
            const SizedBox(height: 10),
            // Telefon: önce alt sayfa kapanıyor, sonra kaynak dışarıda açılıyor.
            YzBalonEylemi(
              yazi: acYazisi(a[0]),
              onPressed: () {
                Navigator.of(ctx).pop();
                ac(acAdresi(a[0]));
              },
            ),
          ] else
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                onPressed: () => ac(acAdresi(a[0])),
                child: Text(acYazisi(a[0]),
                    style: YzYazi.veri(boy: 12.5, renk: YzRenk.makine)),
              ),
            ),
      ],
    ],
  );
}
