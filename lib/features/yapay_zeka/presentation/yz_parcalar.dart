import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/turkce_metin.dart';
import '../data/yz_deposu.dart';
import '../data/yz_iskelet.g.dart';
import '../yz_providers.dart';
import '../data/yz_teknoloji.g.dart';
import 'yz_tasarim.dart';

/// Bölümün adresleri. Adres ASCII (öteki bölümlerle aynı gerekçe).
const String yzPath = '/yapay-zeka-dijital-tarim';
String yzBaslikPath(String slug) => '$yzPath/$slug';

/// Teknolojinin alanlar arası durum sayfası (karar 57).
String yzTeknolojiPath(String kod) => '$yzPath/teknoloji/$kod';

bool yzIsEn(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'en';

/// Sayfaların üst şeridi: geri ve bölümün adı. Site çubuğu değil — bölüm
/// bir başvuru dosyası, okurun dikkati metinde kalsın.
class YzUstSerit extends StatelessWidget {
  const YzUstSerit({super.key, this.geriAdres = '/'});
  final String geriAdres;

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
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
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(geriAdres),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: InkWell(
            onTap: () => context.go(yzPath),
            child: Text(
              buyukHarf(en ? kYzAdEn : kYzAdTr, en),
              overflow: TextOverflow.ellipsis,
              style: YzYazi.ustEtiket(renk: YzRenk.murekkep),
            ),
          ),
        ),
        TextButton(
          onPressed: () => context.go('/'),
          child: Text('Tarım Portalı',
              style: YzYazi.veri(boy: 12, renk: YzRenk.makine)),
        ),
      ]),
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
        if (kYzTeknolojiMetinleri.containsKey(kod))
          TextButton(
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            onPressed: () => context.push(yzTeknolojiPath(kod)),
            child: Text(
              en ? '$ad across agriculture →' : '$ad: alanlar arası durum →',
              style: YzYazi.veri(boy: 13.5, renk: YzRenk.makine, kalinlik: FontWeight.w700),
            ),
          ),
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
    final y = baslik.yazildi;
    final secili = teknoloji != null && !sonuk;
    final izSayisi = secili ? (kYzTeknolojiIzi[baslik.no]?[teknoloji]?[en ? 1 : 0] ?? 0) : 0;
    final durum = secili
        ? (ana
            ? (en ? 'main heading · $izSayisi mentions' : 'ana başlık · $izSayisi yerde geçiyor')
            : (en ? '$izSayisi mentions' : '$izSayisi yerde geçiyor'))
        : (y ? (en ? 'written' : 'yazıldı') : (en ? 'in progress' : 'yazılıyor'));
    final adres = secili
        ? Uri(path: yzBaslikPath(baslik.slug), queryParameters: {'teknoloji': teknoloji!})
            .toString()
        : yzBaslikPath(baslik.slug);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: sonuk ? 0.32 : 1,
      child: Material(
        color: secili && ana ? YzRenk.makineAcik : (y ? YzRenk.bitkiAcik : YzRenk.yuzey),
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
                color: secili
                    ? YzRenk.makine
                    : (y ? YzRenk.bitki.withValues(alpha: 0.55) : YzRenk.cizgi),
                width: secili && ana ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  // Esnek: dar karoda İngilizce etiket ("in progress")
                  // taşmasın, kısalsın. Karoda numara yok: okur başlığı
                  // adıyla tanıyor.
                  Expanded(
                    child: Text(
                      durum,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: YzYazi.veri(
                          boy: 10.5,
                          renk: secili
                              ? YzRenk.makine
                              : (y ? YzRenk.bitki : YzRenk.bekleyenMetin)),
                    ),
                  ),
                ]),
                const SizedBox(height: 5),
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
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final h in liste.take(enCok))
                  _HaberSatiri(h, baslikGoster: baslikNo == null),
              ],
            ),
    );
  }

  Widget _bos(String metin) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Text(metin, style: YzYazi.govde(boy: 16, renk: YzRenk.soluk)),
      );
}

class _HaberSatiri extends StatelessWidget {
  const _HaberSatiri(this.h, {required this.baslikGoster});
  final YzHaber h;
  final bool baslikGoster;

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    final a = h.haber;
    final baslik = (en && (a.titleEn ?? '').isNotEmpty) ? a.titleEn! : a.title;
    final tarih = a.createdAt.toLocal();
    final gun = '${tarih.day.toString().padLeft(2, '0')}.'
        '${tarih.month.toString().padLeft(2, '0')}.${tarih.year}';
    return InkWell(
      onTap: () => context.push(articlePath(a.id)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: YzRenk.cizgi)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(gun, style: YzYazi.veri(boy: 11.5)),
                if ((a.sourceName ?? '').isNotEmpty)
                  Text(a.sourceName!, style: YzYazi.veri(boy: 11.5)),
                if (baslikGoster && h.baslik != null)
                  InkWell(
                    onTap: () => context.push(yzBaslikPath(h.baslik!.slug)),
                    child: Text(h.baslik!.ad(en),
                        style: YzYazi.veri(boy: 11.5, renk: YzRenk.bitki, kalinlik: FontWeight.w600)),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Text(baslik,
                style: YzYazi.baslik(16.5).copyWith(height: 1.3),
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
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
