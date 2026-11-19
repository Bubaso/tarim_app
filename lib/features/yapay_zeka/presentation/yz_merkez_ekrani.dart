import 'package:flutter/material.dart';

import '../data/yz_iskelet.g.dart';
import '../data/yz_metinler.g.dart';
import 'yz_haber_vitrini.dart';
import 'yz_matris.dart';
import 'yz_merkez_liste.dart';
import 'yz_mobil.dart';
import 'yz_parcalar.dart';
import 'yz_tasarim.dart';

/// Yapay Zeka ve Dijital Tarım — merkez sayfa (karar 8: merkez + alt sayfalar).
///
/// Bir giriş sayfası değil, bir HARİTA: okur ilk bakışta bölümün neyi
/// kapsadığını ve son haberleri görüyor. Tez yok
/// (karar 6). "Bugün nerede duruyoruz" haritada bir başlık olarak duruyor;
/// merkez sayfada ayrıca özet kutusu yok (kullanıcı, 18 Kas 2026: aynı
/// metin başlıkta var). Son haberler görselli vitrin (yz_haber_vitrini.dart):
/// manşet ve üç yan haber; okur sona yaklaşınca kuruluyor (madde 28, 29).
///
/// Ekran argüman almıyor: iskelet ve metinler derlemede gömülü, haber
/// akışı veritabanından (karar 21). Adres tek başına sayfayı kuruyor.
class YzMerkezEkrani extends StatelessWidget {
  const YzMerkezEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    final sonGuncelleme = kYzMetinler.values.isEmpty
        ? null
        : (kYzMetinler.values.map((m) => m.guncellendi).toList()..sort()).last;

    return Scaffold(
      backgroundColor: YzRenk.zemin,
      body: Column(children: [
        const YzUstSerit(),
        Expanded(
          child: YzOlcekliIcerik(
            child: LayoutBuilder(builder: (context, kis) {
            final dar = kis.maxWidth < 640;
            // Mobil tur: telefona özgü seçimler, listeyi seçen ölçüyle aynı
            // (yzTelefon); alt yazı ile düzen hiç ayrışmasın.
            final telefon = yzTelefon(context);
            final yan = dar ? 16.0 : 32.0;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── GİRİŞ: tarlanın üstünde ızgara ──
                  Stack(children: [
                    const Positioned.fill(
                      child: CustomPaint(painter: TarlaIzgarasi()),
                    ),
                    // Sola yaslı, TAM genişlikte: yazı bloğu kendi genişliği
                    // kadar kalınca `Center` onu ortaya itiyor ve altındaki
                    // "Başlıklar"ın sol kenarıyla hizası kayıyordu.
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1120),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(yan, dar ? 28 : 56, yan, dar ? 28 : 48),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(en ? 'SECTION · REFERENCE FILE' : 'BÖLÜM · BAŞVURU DOSYASI',
                                  style: YzYazi.ustEtiket(renk: YzRenk.makine)),
                              const SizedBox(height: 12),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 680),
                                child: Semantics(
                                  header: true,
                                  child: Text(en ? kYzAdEn : kYzAdTr,
                                      style: YzYazi.baslik(dar ? 32 : 46)),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 620),
                                child: Text(
                                  en
                                      ? 'Where artificial intelligence and digital technology in farming stand today: a reference file built on measured, sourced figures and scanned on a regular schedule.'
                                      : 'Yapay zekâ ve dijital teknolojiler tarımda bugün nerede duruyor: ölçülmüş, kaynaklı rakamlar üzerine kurulan ve düzenli taranan bir başvuru dosyası.',
                                  style: YzYazi.govde(boy: dar ? 18 : 20),
                                ),
                              ),
                              const SizedBox(height: 22),
                              // Bölüm içi arama (karar 60): tarayıcının "sayfada
                              // bul"u tuval metnini bulamıyor. Telefonda kutu yok
                              // (kullanıcı, 18 Kas 2026: "gerek yok"); arama üst
                              // şeritteki simgeden açılıyor.
                              if (!telefon) ...[
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 620),
                                  child: const YzAramaKutusu(),
                                ),
                                const SizedBox(height: 12),
                              ],
                              // Kaldığınız yer ya da nereden başlamalı (karar 60).
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 620),
                                child: const YzYonSatiri(),
                              ),
                              const SizedBox(height: 14),
                              Wrap(spacing: 18, runSpacing: 6, children: [
                                Text(
                                  en ? '${kYzBasliklar.length} headings' : '${kYzBasliklar.length} başlık',
                                  // Telefonda düz, küçük yazı (★10); masaüstünde mono.
                                  style: telefon
                                      ? yzMerkezMeta()
                                      : YzYazi.veri(boy: 13, renk: YzRenk.murekkep),
                                ),
                                if (sonGuncelleme != null)
                                  Text(
                                    en
                                        ? 'last updated ${yzTarih(sonGuncelleme, true)}'
                                        : 'son güncelleme ${yzTarih(sonGuncelleme, false)}',
                                    style: telefon ? yzMerkezMeta() : YzYazi.veri(boy: 13),
                                  ),
                              ]),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]),
                  // ── HARİTA ve HABERLER ──
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1120),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(yan, 12, yan, 48),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            YzBolumBasligi(
                              en ? 'The headings' : 'Başlıklar',
                              // Telefonda karo yok, liste var (★20): alt yazı ona göre.
                              alt: telefon
                                  ? (en
                                      ? 'From the soil to the market, in the order of the farming year. Pick a technology: each heading shows what it says about it, and the technology has a page of its own across agriculture.'
                                      : 'Topraktan pazara, tarım yılının sırasıyla. Bir teknoloji seçin: her başlık o teknolojinin oradaki durumunu gösterir; teknolojinin alanlar arası durumu da ayrı bir sayfada.')
                                  : (en
                                      ? 'From the soil to the market, in the order of the farming year. Pick a technology: the tiles show what each heading says about it, and the technology has a page of its own across agriculture.'
                                      : 'Topraktan pazara, tarım yılının sırasıyla. Bir teknoloji seçin: karolar o teknolojinin her başlıktaki durumunu gösterir; teknolojinin alanlar arası durumu da ayrı bir sayfada.'),
                            ),
                            const YzHarita(),
                            const SizedBox(height: 34),
                            YzBolumBasligi(
                              en ? 'Technology and Field Heat Map' : 'Teknoloji ve Alan Isı Haritası',
                              vurgu: en
                                  ? 'Follow the pulse of AI use in agriculture here.'
                                  : 'Tarımda Yapay Zeka kullanımının nabzını buradan takip edin.',
                              alt: en
                                  ? 'Each cell counts the passages where a technology comes up in a heading. Tap a cell to open the heading with those passages marked, or a technology to open its page.'
                                  : 'Her hücre, bir teknolojinin bir başlıkta geçtiği yer sayısı. Hücreye dokununca başlık o yerler işaretli açılır; teknolojinin adına dokununca kendi sayfası.',
                            ),
                            const YzTeknolojiMatrisi(),
                            // Son haberler (madde 28): manşet + üç yan haber;
                            // haber yoksa başlığıyla birlikte hiç çizilmiyor.
                            YzHaberBlogu(
                              key: const ValueKey('yz-merkez-haberleri'),
                              ust: [
                                const SizedBox(height: 34),
                                YzBolumBasligi(
                                  en ? 'Latest news' : 'Son haberler',
                                  alt: en
                                      ? 'News from the portal that carries a concrete statement about these technologies, each under its heading.'
                                      : 'Portaldaki haberlerden bu teknolojilere dair somut bir bilgi taşıyanlar, her biri kendi başlığının altında.',
                                ),
                              ],
                            ),
                            // "Bu dosya nasıl güncel tutuluyor" bölümü kaldırıldı
                            // (kullanıcı, 18 Kas 2026).
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          })),
        ),
      ]),
    );
  }
}
