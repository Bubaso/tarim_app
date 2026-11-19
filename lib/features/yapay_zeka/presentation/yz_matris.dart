import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/yz_iskelet.g.dart';
import '../data/yz_teknoloji.g.dart';
import 'yz_parcalar.dart';
import 'yz_tasarim.dart';

/// Teknoloji × başlık ısı haritası (karar 57, 58): her hücre bir teknolojinin
/// bir başlıkta kaç paragrafta (ya da tablo satırında) geçtiği. Sayılar
/// `teknoloji_izi.py`'nin sayımı (iskelette, Dart eşleştiricisiyle eşlik
/// testli). Hücreye dokununca başlık o teknolojinin geçtiği yerler işaretli,
/// sütun başlığına dokununca teknolojinin alanlar arası sayfası açılıyor.
class YzTeknolojiMatrisi extends StatefulWidget {
  const YzTeknolojiMatrisi({super.key});

  @override
  State<YzTeknolojiMatrisi> createState() => _YzTeknolojiMatrisiState();
}

class _YzTeknolojiMatrisiState extends State<YzTeknolojiMatrisi> {
  (int, String)? _uzerinde;

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    final kodlar = kYzTeknoloji.keys.toList();
    final basliklar = kYzBasliklar.where((b) => kYzTeknolojiIzi.containsKey(b.no)).toList();
    int sayi(int no, String kod) => kYzTeknolojiIzi[no]?[kod]?[en ? 1 : 0] ?? 0;
    final enBuyuk = [
      for (final b in basliklar)
        for (final k in kodlar) sayi(b.no, k),
    ].fold<int>(1, (a, b) => a > b ? a : b);
    const hucre = 34.0;
    final yonlendirici = GoRouter.maybeOf(context);

    Widget sutunBasi(String kod) {
      final ad = kYzTeknoloji[kod]![en ? 'en' : 'tr']!;
      final sayfaVar = kYzTeknolojiMetinleri.containsKey(kod);
      return SizedBox(
        width: hucre + 4,
        height: 112,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: RotatedBox(
            quarterTurns: 3,
            child: InkWell(
              onTap: sayfaVar && yonlendirici != null ? () => context.push(yzTeknolojiPath(kod)) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(ad,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: YzYazi.veri(
                        boy: 11.5,
                        renk: _uzerinde?.$2 == kod ? YzRenk.makine : YzRenk.soluk,
                        kalinlik: FontWeight.w600)),
              ),
            ),
          ),
        ),
      );
    }

    Widget hucreW(YzBaslik b, String kod, {double genislik = hucre}) {
      final n = sayi(b.no, kod);
      final etiketli = b.teknoloji.contains(kod);
      final oran = n / enBuyuk;
      final renk = n == 0
          ? YzRenk.yuzey
          : Color.lerp(YzRenk.makineAcik, YzRenk.makine, etiketli ? 0.25 + 0.75 * oran : 0.08)!;
      final ad = kYzTeknoloji[kod]![en ? 'en' : 'tr']!;
      final ipucu = n == 0
          ? '$ad · ${b.ad(en)}: ${en ? 'does not come up' : 'geçmiyor'}'
          : '$ad · ${b.ad(en)}: ${en ? '$n mentions' : '$n yerde geçiyor'}';
      return Tooltip(
        message: ipucu,
        waitDuration: const Duration(milliseconds: 250),
        child: MouseRegion(
          onEnter: (_) => setState(() => _uzerinde = (b.no, kod)),
          onExit: (_) => setState(() => _uzerinde = null),
          cursor: n > 0 ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: n == 0 || yonlendirici == null
                ? null
                : () => context.push(Uri(
                      path: yzBaslikPath(b.slug),
                      queryParameters: {'teknoloji': kod},
                    ).toString()),
            child: Container(
              width: genislik,
              height: hucre - 6,
              margin: const EdgeInsets.all(2),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: renk,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: _uzerinde == (b.no, kod) ? YzRenk.murekkep : YzRenk.cizgi,
                  width: _uzerinde == (b.no, kod) ? 1.5 : 0.6,
                ),
              ),
              child: n == 0
                  ? null
                  : Text('$n',
                      style: YzYazi.veri(
                          boy: 11,
                          renk: etiketli && oran > 0.45 ? Colors.white : YzRenk.makine,
                          kalinlik: FontWeight.w600)),
            ),
          ),
        ),
      );
    }

    Widget dikey() => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const SizedBox(width: 210),
            for (final k in kodlar) sutunBasi(k),
          ]),
          for (final b in basliklar)
            Row(children: [
              SizedBox(
                width: 210,
                child: InkWell(
                  onTap: yonlendirici == null ? null : () => context.push(yzBaslikPath(b.slug)),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Text(b.ad(en),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: YzYazi.govde(
                            boy: 13.5,
                            renk: _uzerinde?.$1 == b.no ? YzRenk.makine : YzRenk.murekkep)),
                  ),
                ),
              ),
              for (final k in kodlar) hucreW(b, k),
            ]),
        ],
      ),
    );

    // Masaüstünde yan yatık (kullanıcı, 19 Kas 2026: "ısı haritası dikeye
    // uzamasın yataya uzasın"): teknolojiler satırda, başlıklar sütunda.
    // Hücre genişliği sütun sayısına göre ekrana sığdırılıyor; dar
    // pencerede ve telefonda eski düzen (başlık satırda, yatay kaydırma).
    Widget yatay(double genislik) {
      const solEn = 214.0;
      final hucreEn = ((genislik - solEn) / basliklar.length - 4).clamp(22.0, hucre);

      Widget sutunBasi(YzBaslik b) => SizedBox(
            width: hucreEn + 4,
            height: 168,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: RotatedBox(
                quarterTurns: 3,
                child: InkWell(
                  onTap: yonlendirici == null ? null : () => context.push(yzBaslikPath(b.slug)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(b.ad(en),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: YzYazi.govde(
                            boy: 12.5,
                            renk: _uzerinde?.$1 == b.no ? YzRenk.makine : YzRenk.murekkep)),
                  ),
                ),
              ),
            ),
          );

      Widget satirBasi(String kod) {
        final ad = kYzTeknoloji[kod]![en ? 'en' : 'tr']!;
        final sayfaVar = kYzTeknolojiMetinleri.containsKey(kod);
        return SizedBox(
          width: solEn,
          child: InkWell(
            onTap: sayfaVar && yonlendirici != null ? () => context.push(yzTeknolojiPath(kod)) : null,
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(ad,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: YzYazi.govde(
                      boy: 13.5,
                      renk: _uzerinde?.$2 == kod ? YzRenk.makine : YzRenk.murekkep)),
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const SizedBox(width: solEn),
            for (final b in basliklar) sutunBasi(b),
          ]),
          for (final k in kodlar)
            Row(children: [
              satirBasi(k),
              for (final b in basliklar) hucreW(b, k, genislik: hucreEn),
            ]),
        ],
      );
    }

    return LayoutBuilder(builder: (context, kis) {
      final yataySigar = kis.maxWidth >= 214 + basliklar.length * 26.0;
      if (yataySigar) return yatay(kis.maxWidth);
      return dikey();
    });
  }
}
