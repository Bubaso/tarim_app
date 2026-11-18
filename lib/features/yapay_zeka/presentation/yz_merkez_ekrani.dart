import 'package:flutter/material.dart';

import '../data/yz_iskelet.g.dart';
import '../data/yz_metinler.g.dart';
import 'yz_matris.dart';
import 'yz_parcalar.dart';
import 'yz_tasarim.dart';

/// Yapay Zeka ve Dijital Tarım — merkez sayfa (karar 8: merkez + alt sayfalar).
///
/// Bir giriş sayfası değil, bir HARİTA: okur ilk bakışta bölümün neyi
/// kapsadığını ve son haberleri görüyor. Tez yok
/// (karar 6). "Bugün nerede duruyoruz" haritada bir başlık olarak duruyor;
/// merkez sayfada ayrıca özet kutusu yok (kullanıcı, 18 Kas 2026: aynı
/// metin başlıkta var). Son haberler görselli vitrin (yz_haber_vitrini.dart).
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
          child: LayoutBuilder(builder: (context, kis) {
            final dar = kis.maxWidth < 640;
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
                                      ? 'Where artificial intelligence and digital technology in farming stand today: a reference file built on measured, sourced figures and scanned on a regular schedule. Every figure carries its standing next to it; a vendor claim is labelled as a vendor claim.'
                                      : 'Yapay zekâ ve dijital teknolojiler tarımda bugün nerede duruyor: ölçülmüş, kaynaklı rakamlar üzerine kurulan ve düzenli taranan bir başvuru dosyası. Her rakamın niteliği yanında yazıyor; satıcı beyanı, satıcı beyanı olarak.',
                                  style: YzYazi.govde(boy: dar ? 18 : 20),
                                ),
                              ),
                              const SizedBox(height: 22),
                              // Bölüm içi arama (karar 60): tarayıcının "sayfada
                              // bul"u tuval metnini bulamıyor.
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 620),
                                child: const YzAramaKutusu(),
                              ),
                              const SizedBox(height: 16),
                              Wrap(spacing: 18, runSpacing: 6, children: [
                                Text(
                                  en ? '${kYzBasliklar.length} headings' : '${kYzBasliklar.length} başlık',
                                  style: YzYazi.veri(boy: 13, renk: YzRenk.murekkep),
                                ),
                                if (sonGuncelleme != null)
                                  Text(
                                    en
                                        ? 'last updated ${yzTarih(sonGuncelleme, true)}'
                                        : 'son güncelleme ${yzTarih(sonGuncelleme, false)}',
                                    style: YzYazi.veri(boy: 13),
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
                              alt: en
                                  ? 'From the soil to the market, in the order of the farming year. Pick a technology: the tiles show what each heading says about it, and the technology has a page of its own across agriculture.'
                                  : 'Topraktan pazara, tarım yılının sırasıyla. Bir teknoloji seçin: karolar o teknolojinin her başlıktaki durumunu gösterir; teknolojinin alanlar arası durumu da ayrı bir sayfada.',
                            ),
                            const YzHarita(),
                            const SizedBox(height: 34),
                            YzBolumBasligi(
                              en ? 'Technology by field' : 'Teknoloji ve alan',
                              alt: en
                                  ? 'Each cell counts the passages where a technology comes up in a heading. Tap a cell to open the heading with those passages marked, or a technology to open its page.'
                                  : 'Her hücre, bir teknolojinin bir başlıkta geçtiği yer sayısı. Hücreye dokununca başlık o yerler işaretli açılır; teknolojinin adına dokununca kendi sayfası.',
                            ),
                            const YzTeknolojiMatrisi(),
                            const SizedBox(height: 34),
                            YzBolumBasligi(
                              en ? 'Latest news' : 'Son haberler',
                              alt: en
                                  ? 'News from the portal that carries a concrete statement about these technologies, each under its heading.'
                                  : 'Portaldaki haberlerden bu teknolojilere dair somut bir bilgi taşıyanlar, her biri kendi başlığının altında.',
                            ),
                            const YzHaberListesi(enCok: 10),
                            const SizedBox(height: 34),
                            YzBolumBasligi(en ? 'How this guide is kept up to date' : 'Bu dosya nasıl güncel tutuluyor'),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 720),
                              child: Text(
                                en
                                    ? 'Every time the portal pulls news, an editorial agent checks each item that mentions these technologies and links it to a heading only if it can quote a concrete sentence from the text; an editor can remove it with one click. Once a month a wider scan reads academic databases, news and official pages. Nothing it finds enters a page directly: it goes to an approval queue and becomes material for the next round of writing.'
                                    : 'Portal her haber çektiğinde, bu teknolojileri anan her haberi bir editör ajanı okuyor ve haberi bir başlığa ancak metinden somut bir cümle gösterebildiğinde bağlıyor; editör tek tıkla kaldırabiliyor. Ayda bir daha geniş bir tarama akademik veritabanlarını, haberleri ve resmî sayfaları okuyor. Bulduğu hiçbir şey sayfaya doğrudan girmiyor: önce onaya düşüyor, onaylanınca bir sonraki yazım turunun malzemesi oluyor.',
                                style: YzYazi.govde(boy: 17),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ]),
    );
  }
}
