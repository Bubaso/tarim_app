import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/turkce_metin.dart';
import '../data/yz_iskelet.g.dart';
import '../data/yz_teknoloji.g.dart';
import 'yz_metin_gorunumu.dart';
import 'yz_parcalar.dart';
import 'yz_tasarim.dart';

/// Bir teknolojinin alanlar arası durum sayfası —
/// `/yapay-zeka-dijital-tarim/teknoloji/<kod>` (karar 57).
///
/// Başlıklar alana göre yazılı (kanıt alana bağlı); bu sayfa aynı kanıtı
/// teknolojinin gözünden topluyor: nerede ölçülmüş sonuç veriyor, nerede
/// tutmuyor, Türkiye'de ne var. Altında teknolojinin geçtiği başlıklar,
/// her biri tek cümlelik notuyla; dokununca başlık o teknolojinin geçtiği
/// yerler işaretli açılıyor.
class YzTeknolojiEkrani extends StatelessWidget {
  const YzTeknolojiEkrani({super.key, required this.kod});
  final String kod;

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    final ad = kYzTeknoloji[kod]?[en ? 'en' : 'tr'];
    if (ad == null) return const _Yok();
    final metin = kYzTeknolojiMetinleri[kod];
    final basliklar = kYzBasliklar.where((b) => b.teknoloji.contains(kod)).toList();
    final ana = kYzTeknolojiAna[kod] ?? const <int>[];
    // Ana başlık önce, sonra öbürleri tarım yılının sırasıyla.
    basliklar.sort((a, b) {
      final aa = ana.contains(a.no) ? 0 : 1, bb = ana.contains(b.no) ? 0 : 1;
      return aa != bb ? aa - bb : a.no - b.no;
    });

    return Scaffold(
      backgroundColor: YzRenk.zemin,
      body: Column(children: [
        const YzUstSerit(geriAdres: yzPath),
        Expanded(
          child: LayoutBuilder(builder: (context, kis) {
            final dar = kis.maxWidth < 640;
            final yan = dar ? 16.0 : 32.0;
            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(yan, dar ? 24 : 44, yan, 56),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(buyukHarf(en ? 'Technology' : 'Teknoloji', en),
                            style: YzYazi.ustEtiket(renk: YzRenk.makine)),
                        const SizedBox(height: 10),
                        Semantics(
                          header: true,
                          child: Text(ad, style: YzYazi.baslik(dar ? 30 : 40)),
                        ),
                        const SizedBox(height: 14),
                        if (metin != null) ...[
                          Text(
                            en
                                ? 'Last checked against its sources: ${yzTarih(metin.guncellendi, true)}'
                                : 'Kaynaklarından son okunduğu gün: ${yzTarih(metin.guncellendi, false)}',
                            style: YzYazi.veri(boy: 12.5, renk: YzRenk.soluk),
                          ),
                          const SizedBox(height: 26),
                          YzMetinGorunumu(metin: metin.metin(en), en: en, kaynakSayfasi: 'tek_$kod'),
                        ] else
                          Text(en ? 'This page is being written.' : 'Bu sayfa yazılıyor.',
                              style: YzYazi.veri(boy: 12.5, renk: YzRenk.bekleyenMetin)),
                        const SizedBox(height: 30),
                        YzBolumBasligi(
                          en ? 'Where it comes up' : 'Geçtiği başlıklar',
                          alt: en
                              ? 'Open a heading to see the passages on ${ad.toLowerCase()} marked.'
                              : 'Bir başlığı açınca ${kucukHarf(ad, false)} geçtiği yerler işaretli gelir.',
                        ),
                        for (final b in basliklar)
                          YzKesisimSatiri(baslik: b, kod: kod, ana: ana.contains(b.no)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ]),
    );
  }
}

/// Teknoloji–başlık kesişiminin satırı: başlığın adı, notu ve teknolojinin o
/// başlıkta kaç yerde geçtiği. Dokununca başlık işaretli açılıyor.
class YzKesisimSatiri extends StatelessWidget {
  const YzKesisimSatiri({super.key, required this.baslik, required this.kod, this.ana = false});
  final YzBaslik baslik;
  final String kod;
  final bool ana;

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    final not = kYzKesisim[kod]?[baslik.no]?[en ? 1 : 0];
    final sayi = kYzTeknolojiIzi[baslik.no]?[kod]?[en ? 1 : 0] ?? 0;
    final etiket = ana
        ? (en ? 'main heading · $sayi mentions' : 'ana başlık · $sayi yerde geçiyor')
        : (en ? '$sayi mentions' : '$sayi yerde geçiyor');
    final adres =
        Uri(path: yzBaslikPath(baslik.slug), queryParameters: {'teknoloji': kod}).toString();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: ana ? YzRenk.makineAcik : YzRenk.yuzey,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: GoRouter.maybeOf(context) == null ? null : () => context.push(adres),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: ana ? YzRenk.makine : YzRenk.cizgi),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(etiket, style: YzYazi.veri(boy: 11, renk: YzRenk.makine)),
                const SizedBox(height: 4),
                Text(baslik.ad(en), style: YzYazi.baslik(16.5).copyWith(height: 1.3)),
                if (not != null) ...[
                  const SizedBox(height: 6),
                  Text(not, style: YzYazi.govde(boy: 15.5).copyWith(height: 1.45)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Yok extends StatelessWidget {
  const _Yok();

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    return Scaffold(
      backgroundColor: YzRenk.zemin,
      body: Column(children: [
        const YzUstSerit(geriAdres: yzPath),
        Expanded(
          child: Center(
            child: Text(en ? 'No such technology.' : 'Böyle bir teknoloji yok.',
                style: YzYazi.govde(boy: 17)),
          ),
        ),
      ]),
    );
  }
}
