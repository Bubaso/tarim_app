import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/turkce_metin.dart';
import '../data/yz_iskelet.g.dart';
import '../yz_providers.dart';
import 'yz_haber_vitrini.dart';
import 'yz_okuma.dart';
import 'yz_tasarim.dart';
import 'yz_yollar.dart';

// Adresler ve dil sorusu ilk yükte kalan hafif dosyada; bölümün öbür
// dosyaları onları buradan almaya devam ediyor.
export 'yz_yollar.dart';
// Merkez sayfanın haritası (başlık karoları, teknoloji çipleri) kendi dosyasında.
export 'yz_harita.dart';

/// Sayfaların üst şeridi: geri ve bölümün adı. Site çubuğu değil — bölüm
/// bir başvuru dosyası, okurun dikkati metinde kalsın.
class YzUstSerit extends StatelessWidget {
  const YzUstSerit({
    super.key,
    this.geriAdres = '/',
    this.aramaDugmesi = true,
    this.yaziBoyuDugmesi = true,
    this.altBaslik,
    this.etiketeDokununca,
  });
  final String geriAdres;

  /// Bölüm içi aramanın düğmesi (karar 60); arama sayfasının kendisinde yok.
  final bool aramaDugmesi;

  /// Yazı boyu düğmesi. Telefonda makale sayfası onu alt çubuğa taşıyor
  /// (karar 62).
  final bool yaziBoyuDugmesi;

  /// Telefonda okur ilk alt başlığı geçince bölümün adı yerine okunan alt
  /// başlık (tek satır, karar 62). Verilmezse bölümün adı.
  final String? altBaslik;

  /// Ortadaki ada dokununca: verilmezse bölümün merkez sayfası (eskisi gibi).
  /// Telefondaki makale şeridi okunan alt başlığı gösterirken içindekileri
  /// açıyor; okur sayfadan çıkmıyor (karar 62).
  final VoidCallback? etiketeDokununca;

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
              onTap: etiketeDokununca ?? (yonlendirici == null ? null : () => context.go(yzPath)),
              // Varsayılan şerit eskisi gibi düz yazı; telefondaki makale
              // şeridi (yazı boyu alt çubukta) ad ile alt başlık arasında
              // geçişli.
              child: yaziBoyuDugmesi && altBaslik == null
                  ? _bolumAdi(en)
                  : _gecisli(altBaslik == null
                      ? _bolumAdi(en)
                      : Text(
                          altBaslik!,
                          key: ValueKey(altBaslik),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: YzYazi.baslik(15, renk: YzRenk.murekkep),
                        )),
            ),
          ),
          if (aramaDugmesi)
            IconButton(
              tooltip: en ? 'Search the section' : 'Bölümde ara',
              icon: const Icon(Icons.search_rounded, color: YzRenk.makine),
              onPressed: yonlendirici == null ? null : () => context.push(yzAramaPath),
            ),
          if (yaziBoyuDugmesi) const YzYaziBoyuDugmesi(),
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

  Widget _bolumAdi(bool en) => Text(
        buyukHarf(en ? kYzAdEn : kYzAdTr, en),
        key: const ValueKey('yz-bolum-adi'),
        overflow: TextOverflow.ellipsis,
        style: YzYazi.ustEtiket(renk: YzRenk.murekkep),
      );

  /// Bölüm adı ile alt başlık arasında yumuşak geçiş (telefon).
  Widget _gecisli(Widget cocuk) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        layoutBuilder: (simdiki, onceki) => Stack(
          alignment: Alignment.centerLeft,
          children: [...onceki, if (simdiki != null) simdiki],
        ),
        child: cocuk,
      );
}

/// Merkez sayfada yön satırı (karar 60): yarıda bırakılan sayfa varsa
/// "Kaldığınız yer" (madde 17-18; ana sayfa şeridiyle aynı yardımcı), yoksa
/// okumuş okura sıradaki okunmamış başlık (madde 20), ilk kez gelen okura
/// nereden başlayacağı. Okuma izi yalnız okurun tarayıcısında.
class YzYonSatiri extends ConsumerWidget {
  const YzYonSatiri({super.key});

  static const String _ilk = 'bugun-nerede-duruyoruz';
  static const String _kavramlar = 'kavramlar';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final en = yzIsEn(context);
    // Yalnız bu satırın gösterdiği alanlar (madde 31): okur okurken iz her
    // paragrafta güncelleniyor; satır yalnız bunlar değişince kuruluyor.
    final yon = ref.watch(yzOkumaIziProvider.select((iz) {
      final devam = yzDevam(iz, en: en);
      if (devam != null) return (devam: devam, sirada: null as String?, ilkOkundu: true);
      final son = iz.son;
      final mevcut = son != null && !son.teknoloji ? son.slug : '';
      return (
        devam: null as YzDevamBilgisi?,
        sirada: iz.okunan.isEmpty ? null : yzSiradakiSlug(iz.okunan, mevcut),
        ilkOkundu: iz.okunan.contains(yzBaslikPath(_ilk)),
      );
    }));
    final yonlendirici = GoRouter.maybeOf(context);
    final duz = YzYazi.govde(boy: 15.5, renk: YzRenk.soluk);
    final bag = YzYazi.govde(boy: 15.5, renk: YzRenk.makine).copyWith(
        decoration: TextDecoration.underline,
        decorationColor: YzRenk.makine.withValues(alpha: 0.4));
    Widget baglanti(String metin, VoidCallback git) => InkWell(
          onTap: yonlendirici == null ? null : git,
          child: Text(metin, style: bag),
        );
    final devam = yon.devam;
    if (devam != null) {
      final ad = devam.altBaslik == null ? devam.baslik : '${devam.baslik} · ${devam.altBaslik}';
      return Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 6, runSpacing: 4, children: [
        Text(en ? 'Where you left off:' : 'Kaldığınız yer:', style: duz),
        baglanti('$ad →', () {
          final yol = yzDevamHazirla(ref.read(yzOkumaIziProvider), 'devam');
          if (yol != null) context.push(yol);
        }),
      ]);
    }
    final sirada = yzBaslikSlugla(yon.sirada);
    if (sirada != null) {
      return Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 6, runSpacing: 4, children: [
        Text(en ? 'Up next:' : 'Sırada:', style: duz),
        baglanti('${sirada.ad(en)} →', () {
          YzGiris.isaretle('merkez');
          context.push(yzBaslikPath(sirada.slug));
        }),
      ]);
    }
    if (yon.ilkOkundu) return const SizedBox.shrink();
    final ilk = yzBaslik(1)?.ad(en) ?? '';
    final kav = yzBaslik(2)?.ad(en).split(':').first.trim() ?? '';
    // TEK PARAGRAF: noktalama bağlantıya yapışık, satır doğal yerinde
    // kırılıyor. Wrap'le kurulduğunda dar ekranda virgül satır başına
    // düşüyor, noktadan önce boşluk kalıyordu (canlıda görüldü, 18 Kas 2026).
    // Noktalama bağlantıyla AYNI satır içi parçada: Flutter satır içi
    // parçadan sonra noktalamanın önünde de kırabiliyor (telefonda "."
    // tek başına alt satıra düştü).
    InlineSpan baglantiParcasi(String metin, String noktalama, VoidCallback git) => WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic, children: [
            Flexible(child: baglanti(metin, git)),
            Text(noktalama, style: duz),
          ]),
        );
    return Text.rich(TextSpan(style: duz, children: [
      TextSpan(text: en ? 'New here? Start with ' : 'İlk kez mi geliyorsunuz? Önce '),
      baglantiParcasi(ilk, en ? ';' : ',', () => context.push(yzBaslikPath(_ilk))),
      TextSpan(text: en ? ' for the terms, ' : ' terimler için '),
      baglantiParcasi(kav, '.', () => context.push(yzBaslikPath(_kavramlar))),
    ]));
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
  const YzBolumBasligi(this.metin, {super.key, this.alt, this.vurgu});
  final String metin;
  final String? alt;

  /// Açıklamanın önünde, ayrı vurguyla duran cümle (ısı haritası, karar 63).
  final String? vurgu;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(header: true, child: Text(metin, style: YzYazi.baslik(22))),
            if (vurgu != null) ...[
              const SizedBox(height: 6),
              Text(vurgu!,
                  style: YzYazi.baslik(16.5, renk: YzRenk.bitki)
                      .copyWith(fontWeight: FontWeight.w600, height: 1.3)),
            ],
            if (alt != null) ...[
              const SizedBox(height: 4),
              Text(alt!, style: YzYazi.govde(boy: 15.5, renk: YzRenk.soluk)),
            ],
          ],
        ),
      );
}

/// Yazı boyu düğmesinin seçtiği ölçek makale dışındaki sayfalarda da
/// (merkez sayfa, arama): düğme bu sayfalarda görünüyor ama hiçbir yazı onu
/// dinlemiyordu — kullanıcı (18 Kas 2026): "büyütsen de birşey değişmiyor".
/// Üst şerit ölçeklenmiyor (makalede de öyle).
class YzOlcekliIcerik extends ConsumerWidget {
  const YzOlcekliIcerik({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final olcek = ref.watch(yzYaziOlcegiProvider);
    if (olcek == 1.0) return child;
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(textScaler: TextScaler.linear(mq.textScaler.scale(1) * olcek)),
      child: child,
    );
  }
}
