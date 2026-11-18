import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/yz_iskelet.g.dart';
import '../yz_providers.dart';
import 'yz_tasarim.dart';
// yz_parcalar DEĞİL: şerit ana sayfada, ilk yükte. yz_parcalar bölümün
// metinlerini içe aktarıyor; buradan aktarılırsa metinler yeniden her
// ziyaretçiye iner (bkz. yz_yollar.dart).
import 'yz_yollar.dart';

/// Yazılmış başlıklar arasından bugünün öne çıkanı (karar 2: pencere yok,
/// ama kartta "şu an öne çıkan" başlık dönüyor). Rastgele değil, takvime
/// bağlı: aynı gün herkes aynı başlığı görüyor, ertesi gün sıradaki geliyor.
YzBaslik? yzOneCikan([DateTime? gun]) {
  final yazilan = kYzBasliklar.where((b) => b.yazildi).toList();
  if (yazilan.isEmpty) return null;
  final t = (gun ?? DateTime.now()).toLocal();
  final yilinGunu = t.difference(DateTime(t.year)).inDays;
  return yazilan[yilinGunu % yazilan.length];
}

/// ANASAYFADAKİ YAPAY ZEKA VE DİJİTAL TARIM ŞERİDİ (karar 46: kart + canlı
/// haber şeridi). Uzayda Tarım şeridinin hemen altında: ikisi de bilim ve
/// teknoloji okuyan okurun komşuluğunda.
///
/// ══ BÖLÜMÜN KENDİ ZEMİNİ ═════════════════════════════════════════════════
/// Anasayfadaki öteki dosya şeritleri koyu; bu bölüm dizide ilk açık zeminli
/// olan (karar 42) ve şerit kapının kendisi: okur tıkladığında aynı kâğıt
/// grisine, aynı ızgaraya giriyor.
///
/// ══ CANLI HABER ═══════════════════════════════════════════════════════════
/// Geniş ekranda bölümün son iki haberi şeridin sağında. Veri gelmezse
/// (ağ, boş akış) o sütun hiç çizilmiyor — şerit yine tam.
class YzSeridi extends ConsumerWidget {
  const YzSeridi({super.key, this.spacing = 0, this.okuraAcik = kYzOkuraAcik});

  /// Şeritten SONRAKİ boşluk — anasayfanın öteki bölümleriyle aynı kural.
  final double spacing;

  /// Varsayılanı yayin.json'daki bayrak. Testler açık hâli de çizebilsin
  /// diye parametre.
  final bool okuraAcik;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // OKURA KAPALI: şerit hiç çizilmiyor ve — sağlayıcıyı izlemeden önce
    // döndüğü için — veritabanına sorgu da atmıyor. Boşluğu da yok: kapalı
    // bölümün yeri ana sayfada görünmemeli.
    if (!okuraAcik) return const SizedBox.shrink();
    final en = yzIsEn(context);
    final g = MediaQuery.sizeOf(context).width;
    final dar = g < 700;
    final oneCikan = yzOneCikan();
    final haberler = dar
        ? const <Never>[]
        : (ref.watch(yzBolumHaberleriProvider(null)).valueOrNull ?? const []);

    return Padding(
      padding: EdgeInsets.only(bottom: spacing),
      child: Material(
        color: YzRenk.zemin,
        child: InkWell(
          // `push`, `go` değil: anasayfa altta kalsın.
          onTap: () => context.push(yzPath),
          child: Container(
            decoration: const BoxDecoration(
              border: Border.symmetric(horizontal: BorderSide(color: YzRenk.cizgi)),
            ),
            child: Stack(children: [
              const Positioned.fill(
                child: CustomPaint(painter: TarlaIzgarasi(yogunluk: 0.9)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: dar ? 18 : 28, vertical: dar ? 18 : 22),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(en ? 'REFERENCE FILE' : 'BAŞVURU DOSYASI',
                              style: YzYazi.ustEtiket(renk: YzRenk.makine)),
                          const SizedBox(height: 6),
                          Text(en ? kYzAdEn : kYzAdTr,
                              style: YzYazi.baslik(dar ? 21 : 25)),
                          if (oneCikan != null) ...[
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => context.push(yzBaslikPath(oneCikan.slug)),
                              child: Text.rich(
                                TextSpan(children: [
                                  TextSpan(
                                    text: en ? 'Now featured: ' : 'Şu an öne çıkan: ',
                                    style: YzYazi.veri(boy: 12.5),
                                  ),
                                  TextSpan(
                                    text: oneCikan.ad(en),
                                    style: YzYazi.veri(
                                        boy: 12.5,
                                        renk: YzRenk.bitki,
                                        kalinlik: FontWeight.w600),
                                  ),
                                ]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (haberler.isNotEmpty) ...[
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (final h in haberler.take(2))
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6, right: 8),
                                      child: Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                              color: YzRenk.bitki,
                                              shape: BoxShape.circle)),
                                    ),
                                    Expanded(
                                      child: Text(
                                        (en && (h.haber.titleEn ?? '').isNotEmpty)
                                            ? h.haber.titleEn!
                                            : h.haber.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: YzYazi.baslik(14.5).copyWith(
                                            fontWeight: FontWeight.w500, height: 1.3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(width: 12),
                    const Icon(Icons.arrow_forward_rounded, color: YzRenk.makine),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
