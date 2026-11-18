import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/turkce_metin.dart';
import '../data/yz_iskelet.g.dart';
import '../yz_providers.dart';
import '../data/yz_teknoloji.g.dart';
import '../data/yz_metinler.g.dart';
import 'yz_haber_vitrini.dart';
import 'yz_okuma.dart';
import 'yz_tasarim.dart';

/// Bölümün adresleri. Adres ASCII (öteki bölümlerle aynı gerekçe).
const String yzPath = '/yapay-zeka-dijital-tarim';
String yzBaslikPath(String slug) => '$yzPath/$slug';

/// Teknolojinin alanlar arası durum sayfası (karar 57).
String yzTeknolojiPath(String kod) => '$yzPath/teknoloji/$kod';

/// Bölüm içi arama (karar 60).
const String yzAramaPath = '$yzPath/ara';

bool yzIsEn(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'en';

/// Sayfaların üst şeridi: geri ve bölümün adı. Site çubuğu değil — bölüm
/// bir başvuru dosyası, okurun dikkati metinde kalsın.
class YzUstSerit extends StatelessWidget {
  const YzUstSerit({super.key, this.geriAdres = '/', this.aramaDugmesi = true});
  final String geriAdres;

  /// Bölüm içi aramanın düğmesi (karar 60); arama sayfasının kendisinde yok.
  final bool aramaDugmesi;

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    final yonlendirici = GoRouter.maybeOf(context);
    return LayoutBuilder(builder: (context, kis) {
      // Telefonda "Tarım Portalı" yazısı yerine ev simgesi: bölümün adı sığsın.
      final dar = kis.maxWidth < 480;
      return Container(
        height: 52,
        decoration: const BoxDecoration(
          color: YzRenk.zemin,
          border: Border(bottom: BorderSide(color: YzRenk.cizgi)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(children: [
          IconButton(
            tooltip: en ? 'Back' : 'Geri',
            icon: const Icon(Icons.arrow_back_rounded, color: YzRenk.murekkep),
            onPressed: yonlendirici == null
                ? null
                : () => context.canPop() ? context.pop() : context.go(geriAdres),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: InkWell(
              onTap: yonlendirici == null ? null : () => context.go(yzPath),
              child: Text(
                buyukHarf(en ? kYzAdEn : kYzAdTr, en),
                overflow: TextOverflow.ellipsis,
                style: YzYazi.ustEtiket(renk: YzRenk.murekkep),
              ),
            ),
          ),
          if (aramaDugmesi)
            IconButton(
              tooltip: en ? 'Search the section' : 'Bölümde ara',
              icon: const Icon(Icons.search_rounded, color: YzRenk.makine),
              onPressed: yonlendirici == null ? null : () => context.push(yzAramaPath),
            ),
          const YzYaziBoyuDugmesi(),
          if (dar)
            IconButton(
              tooltip: 'Tarım Portalı',
              icon: const Icon(Icons.home_outlined, color: YzRenk.makine),
              onPressed: yonlendirici == null ? null : () => context.go('/'),
            )
          else
            TextButton(
              onPressed: yonlendirici == null ? null : () => context.go('/'),
              child: Text('Tarım Portalı',
                  style: YzYazi.veri(boy: 12, renk: YzRenk.makine)),
            ),
        ]),
      );
    });
  }
}

/// Merkez sayfadaki arama kutusu (karar 60): dokununca arama sayfası açılıyor.
class YzAramaKutusu extends StatelessWidget {
  const YzAramaKutusu({super.key});

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    return Semantics(
      button: true,
      label: en ? 'Search the section' : 'Bölümde ara',
      child: Material(
        color: YzRenk.yuzey,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: GoRouter.maybeOf(context) == null ? null : () => context.push(yzAramaPath),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: YzRenk.cizgi),
            ),
            child: Row(children: [
              const Icon(Icons.search_rounded, color: YzRenk.makine, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  en
                      ? 'Search the section: a concept, an institution, a product…'
                      : 'Bölümde ara: kavram, kurum, ürün…',
                  overflow: TextOverflow.ellipsis,
                  style: YzYazi.govde(boy: 17, renk: YzRenk.soluk),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Yazı boyu (karar 60): telefonda sayfa iki parmakla büyütülemiyor
/// (`user-scalable=no`); okur metnin boyunu buradan seçiyor. Seçim
/// tarayıcıda hatırlanıyor.
class YzYaziBoyuDugmesi extends ConsumerWidget {
  const YzYaziBoyuDugmesi({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final en = yzIsEn(context);
    return IconButton(
      tooltip: en ? 'Text size' : 'Yazı boyu',
      icon: const Icon(Icons.format_size_rounded, color: YzRenk.makine),
      onPressed: () {
        final kutu = context.findRenderObject() as RenderBox?;
        final konum = kutu?.localToGlobal(Offset.zero) ?? Offset.zero;
        final ekran = MediaQuery.sizeOf(context);
        showDialog<void>(
          context: context,
          barrierColor: Colors.transparent,
          barrierDismissible: true,
          barrierLabel: en ? 'Close' : 'Kapat',
          useSafeArea: false,
          builder: (c) => Stack(children: [
            Positioned(
              top: konum.dy + 46,
              right: (ekran.width - konum.dx - 48).clamp(8.0, ekran.width - 228),
              width: 220,
              child: Material(
                color: YzRenk.yuzey,
                elevation: 6,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 10, 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: YzRenk.cizgi),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Consumer(builder: (c, ref, _) {
                    final olcek = ref.watch(yzYaziOlcegiProvider);
                    final denetci = ref.read(yzYaziOlcegiProvider.notifier);
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(buyukHarf(en ? 'Text size' : 'Yazı boyu', en),
                            style: YzYazi.ustEtiket()),
                        const SizedBox(height: 6),
                        Row(children: [
                          IconButton(
                            tooltip: en ? 'Smaller' : 'Küçült',
                            onPressed: denetci.kuculebilir ? denetci.kucult : null,
                            icon: Text('A−', style: YzYazi.baslik(15, renk: denetci.kuculebilir ? YzRenk.makine : YzRenk.cizgi)),
                          ),
                          Expanded(
                            child: Text('%${(olcek * 100).round()}',
                                textAlign: TextAlign.center,
                                style: YzYazi.veri(boy: 13.5, renk: YzRenk.murekkep)),
                          ),
                          IconButton(
                            tooltip: en ? 'Larger' : 'Büyüt',
                            onPressed: denetci.buyuyebilir ? denetci.buyut : null,
                            icon: Text('A+', style: YzYazi.baslik(20, renk: denetci.buyuyebilir ? YzRenk.makine : YzRenk.cizgi)),
                          ),
                        ]),
                        if (olcek != 1.0)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: denetci.sifirla,
                              child: Text(en ? 'Default' : 'Varsayılan',
                                  style: YzYazi.veri(boy: 12, renk: YzRenk.makine)),
                            ),
                          ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }
}

/// Teknoloji etiketi çipi. Seçiliyse çelik mavisiyle dolu.
class YzTeknolojiCipi extends StatelessWidget {
  const YzTeknolojiCipi({super.key, required this.kod, this.secili = false, this.onTap});
  final String kod;
  final bool secili;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ad = kYzTeknoloji[kod]?[yzIsEn(context) ? 'en' : 'tr'] ?? kod;
    return Semantics(
      button: onTap != null,
      selected: secili,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(3),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: secili ? YzRenk.makine : YzRenk.yuzey,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: secili ? YzRenk.makine : YzRenk.cizgi),
          ),
          child: Text(ad,
              style: YzYazi.veri(
                  boy: 12, renk: secili ? Colors.white : YzRenk.makine)),
        ),
      ),
    );
  }
}

/// ETKİLEŞİMLİ HARİTA (karar 11) — veri-tarla ızgarasının kendisi.
///
/// Her satır bir katman, her karo bir başlık. Yazılmış başlık bitki
/// yeşiliyle dolu, yazılmakta olan boş bir karo: okur bölümün ne kadarının
/// hazır olduğunu süsten değil haritanın kendisinden okuyor. Teknoloji
/// etiketi seçilince (karar 13, çapraz eksen) o teknolojiyi taşımayan
/// başlıklar sönükleşiyor.
class YzHarita extends StatefulWidget {
  const YzHarita({super.key});

  @override
  State<YzHarita> createState() => _YzHaritaState();
}

class _YzHaritaState extends State<YzHarita> {
  String? _teknoloji;

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    final katmanlar = <String, List<YzBaslik>>{};
    for (final b in kYzBasliklar) {
      katmanlar.putIfAbsent(b.katman, () => []).add(b);
    }
    return LayoutBuilder(builder: (context, kis) {
      final genis = kis.maxWidth >= 760;
      final karoGenisligi = genis
          ? 196.0
          : ((kis.maxWidth - 8) / 2).clamp(140.0, 260.0).toDouble();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Telefonda çipler tek satırda yana kayıyor: başlık haritası ilk
          // ekrana yaklaşsın (karar 60).
          if (kis.maxWidth < 640)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                for (final kod in kYzTeknoloji.keys)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: YzTeknolojiCipi(
                      kod: kod,
                      secili: _teknoloji == kod,
                      onTap: () => setState(() => _teknoloji = _teknoloji == kod ? null : kod),
                    ),
                  ),
              ]),
            )
          else
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final kod in kYzTeknoloji.keys)
                YzTeknolojiCipi(
                  kod: kod,
                  secili: _teknoloji == kod,
                  onTap: () => setState(
                      () => _teknoloji = _teknoloji == kod ? null : kod),
                ),
            ]),
          if (_teknoloji != null) ...[
            const SizedBox(height: 12),
            _TeknolojiOzeti(kod: _teknoloji!, en: en),
          ],
          const SizedBox(height: 18),
          for (final k in katmanlar.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _katmanSatiri(k.key, k.value, genis, karoGenisligi, en),
            ),
        ],
      );
    });
  }

  /// Geniş ekranda katman adı solda, karolar sağda (Row + Expanded); dar
  /// ekranda alt alta (Column). Dikey bir Flex içinde Flexible KULLANILMAZ:
  /// kaydırılabilir alanın yüksekliği sınırsız, 360 pikselde test yakaladı.
  Widget _katmanSatiri(String katman, List<YzBaslik> basliklar, bool genis,
      double karoGenisligi, bool en) {
    final etiket = Text(
      buyukHarf(kYzKatmanlar[katman]?[en ? 'en' : 'tr'] ?? katman, en),
      style: YzYazi.ustEtiket(),
    );
    final karolar = Wrap(spacing: 8, runSpacing: 8, children: [
      for (final b in basliklar)
        SizedBox(
          width: karoGenisligi,
          child: YzBaslikKarosu(
            baslik: b,
            sonuk: _teknoloji != null && !b.teknoloji.contains(_teknoloji),
            teknoloji: _teknoloji,
            ana: _teknoloji != null && (kYzTeknolojiAna[_teknoloji]?.contains(b.no) ?? false),
          ),
        ),
    ]);
    if (!genis) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [etiket, const SizedBox(height: 6), karolar],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 170, child: Padding(padding: const EdgeInsets.only(top: 12), child: etiket)),
        const SizedBox(width: 10),
        Expanded(child: karolar),
      ],
    );
  }
}

/// Seçili teknolojinin haritadaki özeti (karar 57): kaç başlıkta geçtiği ve
/// asıl konu olduğu başlık. Sayılar iskeletten; etiketler metinden çıkıyor.
class _TeknolojiOzeti extends StatelessWidget {
  const _TeknolojiOzeti({required this.kod, required this.en});
  final String kod;
  final bool en;

  @override
  Widget build(BuildContext context) {
    final ad = kYzTeknoloji[kod]?[en ? 'en' : 'tr'] ?? kod;
    final sayi = kYzBasliklar.where((b) => b.teknoloji.contains(kod)).length;
    final ana = [
      for (final no in kYzTeknolojiAna[kod] ?? const <int>[]) yzBaslik(no)?.ad(en),
    ].whereType<String>().toList();
    final anaMetni = ana.isEmpty
        ? ''
        : (en
            ? ' Main heading${ana.length > 1 ? 's' : ''}: ${ana.join('; ')}.'
            : ' Asıl konu olduğu başlık${ana.length > 1 ? 'lar' : ''}: ${ana.join('; ')}.');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          en
              ? '$ad comes up in $sayi headings; tap one to open it with the passages marked.$anaMetni'
              : '$ad $sayi başlıkta geçiyor; açtığınız başlıkta geçtiği yerler işaretli gelir.$anaMetni',
          style: YzYazi.govde(boy: 15, renk: YzRenk.makine),
        ),
        // Teknolojinin kendi sayfası (karar 57): küçük bir yazı bağlantısı
        // gözden kaçıyordu (kullanıcı, 18 Kas 2026); dolgulu, oklu bir kart.
        if (kYzTeknolojiMetinleri.containsKey(kod)) ...[
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Semantics(
              button: true,
              label: en ? '$ad across agriculture' : '$ad: alanlar arası durum',
              child: Material(
                color: YzRenk.makine,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => context.push(yzTeknolojiPath(kod)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
                    child: Row(children: [
                      const Icon(Icons.travel_explore_rounded, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(buyukHarf(en ? 'Technology page' : 'Teknoloji sayfası', en),
                                style: YzYazi.ustEtiket(renk: Colors.white.withValues(alpha: 0.78))),
                            const SizedBox(height: 3),
                            Text(
                              en ? '$ad across agriculture' : '$ad: alanlar arası durum',
                              style: YzYazi.baslik(17, renk: Colors.white).copyWith(height: 1.25),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
                    ]),
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

class YzBaslikKarosu extends StatelessWidget {
  const YzBaslikKarosu(
      {super.key, required this.baslik, this.sonuk = false, this.teknoloji, this.ana = false});
  final YzBaslik baslik;
  final bool sonuk;

  /// Merkez sayfada seçili teknoloji (karar 57). Karo o teknolojiyi
  /// taşıyorsa geçtiği yer sayısını gösteriyor ve dokununca başlık sayfası
  /// o teknolojinin geçtiği yerler işaretli açılıyor.
  final String? teknoloji;

  /// Teknolojinin asıl konu olduğu başlık.
  final bool ana;

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    final secili = teknoloji != null && !sonuk;
    final izSayisi = secili ? (kYzTeknolojiIzi[baslik.no]?[teknoloji]?[en ? 1 : 0] ?? 0) : 0;
    // Karoda yazım durumu yok (iç not; kullanıcı, 18 Kas 2026): yalnız seçili
    // teknolojinin bu başlıkta kaç yerde geçtiği.
    final metin = kYzMetinler[baslik.no];
    final durum = !secili
        ? (metin == null
            ? null
            : (en
                ? '${yzOkumaSuresi(metin.metin(true), true)} min'
                : '${yzOkumaSuresi(metin.metin(false), false)} dk okuma'))
        : (ana
            ? (en ? 'main heading · $izSayisi mentions' : 'ana başlık · $izSayisi yerde geçiyor')
            : (en ? '$izSayisi mentions' : '$izSayisi yerde geçiyor'));
    final adres = secili
        ? Uri(path: yzBaslikPath(baslik.slug), queryParameters: {'teknoloji': teknoloji!})
            .toString()
        : yzBaslikPath(baslik.slug);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: sonuk ? 0.32 : 1,
      child: Material(
        color: secili && ana ? YzRenk.makineAcik : YzRenk.bitkiAcik,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () => context.push(adres),
          child: Container(
            constraints: const BoxConstraints(minHeight: 76),
            padding: const EdgeInsets.fromLTRB(11, 9, 11, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: secili ? YzRenk.makine : YzRenk.bitki.withValues(alpha: 0.55),
                width: secili && ana ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Karoda numara yok: okur başlığı adıyla tanıyor.
                if (durum != null) ...[
                  Text(
                    durum,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: YzYazi.veri(boy: 10.5, renk: secili ? YzRenk.makine : YzRenk.soluk),
                  ),
                  const SizedBox(height: 5),
                ],
                Text(baslik.ad(en),
                    style: YzYazi.baslik(14.5).copyWith(height: 1.25),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
                // Karar 57: seçili teknolojinin bu başlıktaki durumu, tek cümle.
                if (secili && kYzKesisim[teknoloji]?[baslik.no] != null) ...[
                  const SizedBox(height: 6),
                  Text(kYzKesisim[teknoloji]![baslik.no]![en ? 1 : 0],
                      style: YzYazi.govde(boy: 12.5).copyWith(height: 1.35),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bölümün haber akışı (karar 32, 46). [baslikNo] verilirse yalnız o
/// başlığın haberleri; verilmezse bütün bölüm, her haberin başlık çipiyle.
class YzHaberListesi extends ConsumerWidget {
  const YzHaberListesi({super.key, this.baslikNo, this.enCok = 8});
  final int? baslikNo;
  final int enCok;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final en = yzIsEn(context);
    final durum = ref.watch(yzBolumHaberleriProvider(baslikNo));
    return durum.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: YzRenk.bitki))),
      ),
      error: (_, __) => _bos(en ? 'News could not be loaded.' : 'Haberler yüklenemedi.'),
      data: (liste) => liste.isEmpty
          ? _bos(baslikNo == null
              ? (en ? 'No news in this section yet.' : 'Bu bölümde henüz haber yok.')
              : (en ? 'No news under this heading yet.' : 'Bu başlıkta henüz haber yok.'))
          : YzHaberVitrini(haberler: liste.take(enCok).toList(), merkez: baslikNo == null),
    );
  }

  Widget _bos(String metin) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Text(metin, style: YzYazi.govde(boy: 16, renk: YzRenk.soluk)),
      );
}

/// Bölüm başlığı (h2) — sayfa içi.
class YzBolumBasligi extends StatelessWidget {
  const YzBolumBasligi(this.metin, {super.key, this.alt});
  final String metin;
  final String? alt;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(header: true, child: Text(metin, style: YzYazi.baslik(22))),
            if (alt != null) ...[
              const SizedBox(height: 4),
              Text(alt!, style: YzYazi.govde(boy: 15.5, renk: YzRenk.soluk)),
            ],
          ],
        ),
      );
}
