import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/turkce_metin.dart';
import '../data/yz_iskelet.g.dart';
import '../data/yz_teknoloji.g.dart';
import 'yz_makale.dart';
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

    final yonlendirici = GoRouter.maybeOf(context);
    final ara = yonlendirici == null
        ? ''
        : (GoRouterState.of(context).uri.queryParameters['ara'] ?? '').trim();

    return YzMakaleSayfasi(
      key: ValueKey('teknoloji-$kod'),
      konumAnahtari: 'teknoloji-$kod',
      geriAdres: yzPath,
      ustEtiket: en ? 'Technology' : 'Teknoloji',
      baslik: ad,
      metin: metin?.metin(en),
      en: en,
      guncellendi: metin?.guncellendi,
      kaynakSayfasi: 'tek_$kod',
      arama: ara.isEmpty ? null : ara,
      isaretiKaldir: yonlendirici == null ? null : () => context.go(yzTeknolojiPath(kod)),
      altlar: [
        const SizedBox(height: 30),
        YzBolumBasligi(
          en ? 'Where it comes up' : 'Geçtiği başlıklar',
          alt: en
              ? 'Open a heading to see the passages on ${ad.toLowerCase()} marked.'
              : 'Bir başlığı açınca ${kucukHarf(ad, false)} geçtiği yerler işaretli gelir.',
        ),
        for (final b in basliklar) YzKesisimSatiri(baslik: b, kod: kod, ana: ana.contains(b.no)),
      ],
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
