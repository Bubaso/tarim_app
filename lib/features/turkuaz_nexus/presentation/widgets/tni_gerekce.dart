import 'package:flutter/material.dart';

import '../../data/tni_veri.g.dart';
import '../tni_tasarim.dart';
import 'tni_parcalar.dart';

/// GEREKÇE PANOSU — girişimin dayandığı altı rakam.
///
/// Hepsi birincil belgenin §1.1 gerekçesinden ve her birinin kaynağı
/// kendisiyle birlikte duruyor; karta dokununca kaynak ve varsa ÇEKİNCE
/// açılıyor. Rakamı kaynağından ayırmak, onu bir slogana çevirmenin en kolay
/// yolu.
///
/// İKİ ÖLÇÜ KURALI:
///   · Çubuk yalnız yüzde olan rakamlarda çiziliyor. 673 milyon kişinin yüzde
///     ölçeği yok; ona çubuk çizmek uydurma bir oran üretirdi.
///   · Belge "approximately half" diyor, kesin yüzde vermiyor. O kart "≈
///     yarısı" yazıyor; 50 sayısı yalnız çubuğun boyunu belirliyor.
class TniGerekce extends StatefulWidget {
  final bool karanlik;
  final bool isEn;

  const TniGerekce({super.key, required this.karanlik, required this.isEn});

  @override
  State<TniGerekce> createState() => _TniGerekceDurumu();
}

class _TniGerekceDurumu extends State<TniGerekce> {
  String? _acik;

  @override
  Widget build(BuildContext context) {
    final k = widget.karanlik;
    final isEn = widget.isEn;
    final rakamlar = (tniVeri['gerekce_rakamlari'] as List)
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();
    final genislik = MediaQuery.sizeOf(context).width;
    final sutun = genislik >= 1000 ? 3 : (genislik >= 640 ? 2 : 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TniBolumBasligi(
          no: '03',
          etiket: isEn ? 'THE RATIONALE' : 'GEREKÇE',
          baslik: isEn ? 'Rationale panel' : 'Gerekçe panosu',
          // ARAYÜZ TARİFİ OKURA ANLATILMIYOR. Önce "dokununca kaynak ve
          // varsa çekince açılıyor" yazıyordu; bu bir kullanım kılavuzu
          // cümlesi. Kartlar zaten dokunulabilir göründüğü için
          // söylenmesine gerek yok.
          giris: isEn
              ? 'Six figures describe the problem the initiative was set up '
                  'to address.'
              : 'Girişimin karşısına koyduğu sorunu altı rakam anlatıyor.',
          vurgu: TniRenk.tarim(k),
          karanlik: k,
        ),
        const TniAra(boy: 24),
        LayoutBuilder(builder: (context, kis) {
          const ara = 14.0;
          final kartG = (kis.maxWidth - ara * (sutun - 1)) / sutun;
          return Wrap(
            spacing: ara,
            runSpacing: ara,
            children: [
              for (final r in rakamlar)
                SizedBox(
                  width: (r['one_cikan'] == true && sutun > 1)
                      ? kis.maxWidth
                      : kartG,
                  child: _RakamKarti(
                    r: r,
                    karanlik: k,
                    isEn: isEn,
                    acik: _acik == r['anahtar'],
                    genis: r['one_cikan'] == true && sutun > 1,
                    bas: () => setState(() => _acik =
                        _acik == r['anahtar'] ? null : r['anahtar'] as String),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }
}

class _RakamKarti extends StatelessWidget {
  final Map<String, dynamic> r;
  final bool karanlik;
  final bool isEn;
  final bool acik;
  final bool genis;
  final VoidCallback bas;

  const _RakamKarti({
    required this.r,
    required this.karanlik,
    required this.isEn,
    required this.acik,
    required this.genis,
    required this.bas,
  });

  @override
  Widget build(BuildContext context) {
    final k = karanlik;
    final oneCikan = r['one_cikan'] == true;
    final vurgu = oneCikan ? TniRenk.askida(k) : TniRenk.tarim(k);
    final gosterim = (isEn ? r['gosterim_en'] : r['gosterim_tr']) as String?;
    final birim = (isEn ? r['birim_en'] : r['birim_tr']) as String? ?? '';
    final ifade = (isEn ? r['ifade_en'] : r['ifade_tr']) as String? ?? '';
    // Okura gösterilen çekince İKİ DİLLİ. Alt çizgiyle başlayan alanlar
    // (`_not_tr`, `_ek_tr`) bize ait notlar; sayfaya girmiyor.
    final cekince = (isEn ? r['cekince_en'] : r['cekince_tr']) as String?;
    final rol = r['_rol'] as String?;
    final olcek = (r['olcek'] as num?)?.toDouble();

    return TniKart(
      karanlik: k,
      kenarRengi: oneCikan ? vurgu.withValues(alpha: 0.45) : null,
      dolgu: const EdgeInsets.all(18),
      child: InkWell(
        onTap: bas,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                // RAKAM KESİLMİYOR, KÜÇÜLÜYOR.
                //
                // Kartların çoğunda burada iki üç haneli bir sayı var ve
                // sorun çıkmıyor. Ama bir kartta sayı yerine kelime duruyor
                // ("≈ yarısı"), çünkü belge kesin bir yüzde vermiyor. O
                // kelime dar kartta kesiliyor ve ekranda "≈ ya…" diye
                // görünüyordu — okurun anlamasına imkân yok.
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      gosterim ?? '${r['deger']}',
                      style: TniYazi.olcu(
                        punto: genis ? 48 : 40,
                        renk: vurgu,
                        kalinlik: FontWeight.w700,
                        aralik: -1,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
                if (gosterim == null) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      birim,
                      style: TniYazi.govde(
                        punto: 13,
                        renk: TniRenk.ikincil(k),
                        kalinlik: FontWeight.w600,
                      ),
                      maxLines: 2,
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  '${r['yil']}',
                  style: TniYazi.olcu(
                    punto: 11,
                    renk: TniRenk.ikincil(k).withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
            if (olcek != null) ...[
              const SizedBox(height: 10),
              // Çubuk ölçeği 0-100. Yüzde olmayan rakamda hiç çizilmiyor.
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: (olcek / 100).clamp(0.0, 1.0),
                  minHeight: 4,
                  backgroundColor: vurgu.withValues(alpha: 0.14),
                  valueColor: AlwaysStoppedAnimation(vurgu),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              ifade,
              style: TniYazi.govde(
                punto: 14.5,
                renk: TniRenk.metin(k),
                satir: 1.5,
              ),
            ),
            if (oneCikan && rol != null) ...[
              const SizedBox(height: 10),
              TniEtiket(
                isEn ? 'WHY THE INITIATIVE EXISTS' : 'GİRİŞİMİN VARLIK SEBEBİ',
                renk: vurgu,
                simge: Icons.center_focus_strong_rounded,
              ),
            ],
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState:
                  acik ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              firstChild: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Icon(Icons.add_rounded,
                        size: 14,
                        color: TniRenk.ikincil(k).withValues(alpha: 0.7)),
                    const SizedBox(width: 6),
                    Text(
                      isEn ? 'source' : 'kaynak',
                      style: TniYazi.olcu(
                        punto: 10.5,
                        renk: TniRenk.ikincil(k).withValues(alpha: 0.7),
                        aralik: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 1,
                      color: TniRenk.cizgi(k),
                      margin: const EdgeInsets.only(bottom: 12),
                    ),
                    Text(
                      '${isEn ? "Source" : "Kaynak"}: ${r['kaynak']}',
                      style: TniYazi.olcu(
                        punto: 11,
                        renk: TniRenk.ikincil(k),
                        aralik: 0.2,
                      ),
                    ),
                    if (cekince != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 13, color: TniRenk.askida(k)),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              cekince,
                              style: TniYazi.govde(
                                punto: 12.5,
                                renk: TniRenk.askida(k),
                                satir: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
