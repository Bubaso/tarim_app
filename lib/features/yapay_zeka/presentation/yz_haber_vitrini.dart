import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/image_fallback_helper.dart';
import '../../../core/utils/turkce_metin.dart';
import '../data/yz_deposu.dart';
import 'yz_parcalar.dart';
import 'yz_tasarim.dart';

/// Bölümün haberleri, görselleriyle bir vitrin olarak (liste değil).
///
/// Merkez sayfada dergi düzeni: geniş ekranda solda büyük görselli manşet,
/// sağda küçük resimli üç haber, altında üç sütunlu kart ızgarası; orta
/// genişlikte manşet yatay, kartlar iki sütun; dar ekranda manşetin altında
/// küçük resimli satırlar. Başlık sayfasında aynı kartlar ızgarada.
///
/// Yükseklikler sabit ölçülerle kuruluyor (IntrinsicHeight yok): sitenin
/// görsel bileşeni içeride LayoutBuilder kullanıyor ve iç boy sorulamıyor.
/// Görseli olmayan haberde bölümün tarla dokusu ve haberin başlığının adı;
/// boş kutu ya da sonsuz yükleme yok.
class YzHaberVitrini extends StatelessWidget {
  const YzHaberVitrini({super.key, required this.haberler, this.merkez = true});
  final List<YzHaber> haberler;

  /// Merkez sayfa (dergi düzeni, kartta başlık etiketi) ya da başlık sayfası.
  final bool merkez;

  static const _ara = 20.0;

  @override
  Widget build(BuildContext context) {
    if (haberler.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(builder: (context, kis) {
      final w = kis.maxWidth;
      if (w < 600) {
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (merkez) ...[
            _Manset(haberler.first, baslikEtiketi: true),
            const SizedBox(height: 12),
          ],
          for (final h in merkez ? haberler.skip(1) : haberler) _Satir(h, baslikEtiketi: merkez),
        ]);
      }
      if (!merkez) {
        return _Izgara(haberler, sutun: w >= 900 ? 3 : 2, genislik: w, baslikEtiketi: false);
      }
      if (w < 900) {
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _MansetYatay(haberler.first),
          if (haberler.length > 1) ...[
            const SizedBox(height: _ara),
            _Izgara(haberler.skip(1).toList(), sutun: 2, genislik: w, baslikEtiketi: true),
          ],
        ]);
      }
      final yan = haberler.skip(1).take(3).toList();
      final alt = haberler.skip(4).toList();
      final mansetGenisligi = yan.isEmpty ? w : (w - _ara) * 3 / 5;
      final ustBoy = mansetGenisligi * 9 / 16 + 188;
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(
          height: ustBoy,
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(flex: 3, child: _Manset(haberler.first, baslikEtiketi: true, sabit: true)),
            if (yan.isNotEmpty) ...[
              const SizedBox(width: _ara),
              Expanded(
                flex: 2,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    Expanded(child: i < yan.length ? _Yan(yan[i]) : const SizedBox.shrink()),
                  ],
                ]),
              ),
            ],
          ]),
        ),
        if (alt.isNotEmpty) ...[
          const SizedBox(height: _ara),
          _Izgara(alt, sutun: 3, genislik: w, baslikEtiketi: true),
        ],
      ]);
    });
  }
}

/// Kartlar satır satır; her kartın metin alanı aynı boyda, satırlar eşit.
class _Izgara extends StatelessWidget {
  const _Izgara(this.haberler, {required this.sutun, required this.genislik, required this.baslikEtiketi});
  final List<YzHaber> haberler;
  final int sutun;
  final double genislik;
  final bool baslikEtiketi;

  @override
  Widget build(BuildContext context) {
    const ara = YzHaberVitrini._ara;
    final kartGenisligi = (genislik - (sutun - 1) * ara) / sutun;
    return Wrap(spacing: ara, runSpacing: ara, children: [
      for (final h in haberler)
        SizedBox(width: kartGenisligi, child: _Kart(h, baslikEtiketi: baslikEtiketi)),
    ]);
  }
}

String _gun(DateTime t, bool en) {
  const tr = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
  const ing = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final y = t.toLocal();
  return '${y.day} ${(en ? ing : tr)[y.month - 1]} ${y.year}';
}

String _baslik(YzHaber h, bool en) {
  final a = h.haber;
  return (en && (a.titleEn ?? '').isNotEmpty) ? a.titleEn! : a.title;
}

String? _ozet(YzHaber h, bool en) {
  final a = h.haber;
  final s = (en && (a.summaryEn ?? '').isNotEmpty) ? a.summaryEn : a.summary;
  return (s ?? '').trim().isEmpty ? null : s!.trim();
}

/// Kartın görseli; görsel yoksa tarla dokusu ve haberin başlığının adı.
class _Gorsel extends StatelessWidget {
  const _Gorsel(this.h, {required this.buyuk});
  final YzHaber h;
  final bool buyuk;

  @override
  Widget build(BuildContext context) {
    final a = h.haber;
    final kucuk = (a.thumbImageUrl ?? '').trim();
    final asil = (a.imageUrl ?? '').trim();
    final adres = buyuk ? (asil.isNotEmpty ? asil : kucuk) : (kucuk.isNotEmpty ? kucuk : asil);
    if (adres.startsWith('http')) {
      return NewsArticleImage(imageUrl: adres, isHighQuality: buyuk, semanticLabel: a.imageCaption);
    }
    final en = yzIsEn(context);
    return Container(
      color: YzRenk.bitkiAcik,
      child: Stack(fit: StackFit.expand, children: [
        const CustomPaint(painter: TarlaIzgarasi(solma: false, yogunluk: 1.4)),
        if (h.baslik != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(buyukHarf(h.baslik!.ad(en), en),
                  maxLines: 2, overflow: TextOverflow.ellipsis, style: YzYazi.ustEtiket(renk: YzRenk.bitki)),
            ),
          ),
      ]),
    );
  }
}

/// Künye: (merkez sayfada) başlığın adı, altında tarih · kaynak.
class _Kunye extends StatelessWidget {
  const _Kunye(this.h, {required this.baslikEtiketi});
  final YzHaber h;
  final bool baslikEtiketi;

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    final a = h.haber;
    final kaynak = (a.sourceName ?? '').trim();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      if (baslikEtiketi && h.baslik != null)
        InkWell(
          onTap: () => context.push(yzBaslikPath(h.baslik!.slug)),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text(buyukHarf(h.baslik!.ad(en), en),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: YzYazi.ustEtiket(renk: YzRenk.bitki).copyWith(fontWeight: FontWeight.w600)),
          ),
        ),
      Text(kaynak.isEmpty ? _gun(a.createdAt, en) : '${_gun(a.createdAt, en)} · $kaynak',
          maxLines: 1, overflow: TextOverflow.ellipsis, style: YzYazi.veri(boy: 11.5)),
    ]);
  }
}

/// Üstüne gelince hafifçe yükselen, görseli yavaşça büyüyen dokunulabilir kart.
class _Dokunulur extends StatefulWidget {
  const _Dokunulur({required this.h, required this.cocuk});
  final YzHaber h;
  final Widget Function(bool uzerinde) cocuk;

  @override
  State<_Dokunulur> createState() => _DokunulurState();
}

class _DokunulurState extends State<_Dokunulur> {
  bool _uzerinde = false;

  @override
  Widget build(BuildContext context) {
    final hareketsiz = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return Semantics(
      button: true,
      label: _baslik(widget.h, yzIsEn(context)),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _uzerinde = true),
        onExit: (_) => setState(() => _uzerinde = false),
        child: GestureDetector(
          onTap: () => context.push(articlePath(widget.h.haber.id)),
          child: AnimatedContainer(
            duration: hareketsiz ? Duration.zero : const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: YzRenk.yuzey,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _uzerinde ? YzRenk.bitki.withValues(alpha: 0.55) : YzRenk.cizgi),
              boxShadow: _uzerinde
                  ? [BoxShadow(color: YzRenk.murekkep.withValues(alpha: 0.08), blurRadius: 18, offset: const Offset(0, 6))]
                  : const [],
            ),
            clipBehavior: Clip.antiAlias,
            child: widget.cocuk(_uzerinde && !hareketsiz),
          ),
        ),
      ),
    );
  }
}

Widget _yakinlasan(Widget gorsel, bool uzerinde) => ClipRect(
      child: AnimatedScale(
        scale: uzerinde ? 1.035 : 1,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        child: gorsel,
      ),
    );

/// Manşet: büyük görsel, başlık, özet. [sabit]: dışarıdan verilen boya
/// sığar (görsel 16:9, metin alanı kalan yer).
class _Manset extends StatelessWidget {
  const _Manset(this.h, {required this.baslikEtiketi, this.sabit = false});
  final YzHaber h;
  final bool baslikEtiketi;
  final bool sabit;

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    final ozet = _ozet(h, en);
    final metin = Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _Kunye(h, baslikEtiketi: baslikEtiketi),
        const SizedBox(height: 8),
        Text(_baslik(h, en),
            maxLines: sabit ? 2 : 4,
            overflow: TextOverflow.ellipsis,
            style: YzYazi.baslik(sabit ? 24 : 21).copyWith(height: 1.22)),
        if (ozet != null) ...[
          const SizedBox(height: 6),
          // Sabit boyda özet kalan yere sığar (taşarsa kesilir, hata vermez);
          // serbest boyda (dar ekran) olduğu gibi.
          if (sabit)
            Flexible(child: _ozetYazisi(ozet))
          else
            _ozetYazisi(ozet),
        ],
      ]),
    );
    return _Dokunulur(
      h: h,
      cocuk: (u) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        AspectRatio(aspectRatio: 16 / 9, child: _yakinlasan(_Gorsel(h, buyuk: true), u)),
        if (sabit) Expanded(child: ClipRect(child: metin)) else metin,
      ]),
    );
  }
}

Widget _ozetYazisi(String ozet) => Text(ozet,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    style: YzYazi.govde(boy: 15.5, renk: YzRenk.soluk).copyWith(height: 1.45));

/// Orta genişlikte manşet: solda görsel, sağda metin; sabit boy.
class _MansetYatay extends StatelessWidget {
  const _MansetYatay(this.h);
  final YzHaber h;

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    final ozet = _ozet(h, en);
    return SizedBox(
      height: 250,
      child: _Dokunulur(
        h: h,
        cocuk: (u) => Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(flex: 11, child: _yakinlasan(_Gorsel(h, buyuk: true), u)),
          Expanded(
            flex: 9,
            child: ClipRect(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _Kunye(h, baslikEtiketi: true),
                  const SizedBox(height: 8),
                  Text(_baslik(h, en),
                      maxLines: 3, overflow: TextOverflow.ellipsis, style: YzYazi.baslik(21).copyWith(height: 1.25)),
                  if (ozet != null) ...[
                    const SizedBox(height: 8),
                    Text(ozet,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: YzYazi.govde(boy: 15, renk: YzRenk.soluk).copyWith(height: 1.45)),
                  ],
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

/// Manşetin yanındaki haber: solda küçük resim, sağda künye ve başlık.
class _Yan extends StatelessWidget {
  const _Yan(this.h);
  final YzHaber h;

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    return _Dokunulur(
      h: h,
      cocuk: (u) => Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(width: 136, child: _yakinlasan(_Gorsel(h, buyuk: false), u)),
        Expanded(
          child: ClipRect(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Kunye(h, baslikEtiketi: true),
                    const SizedBox(height: 5),
                    Text(_baslik(h, en),
                        maxLines: 3, overflow: TextOverflow.ellipsis, style: YzYazi.baslik(16).copyWith(height: 1.28)),
                  ]),
            ),
          ),
        ),
      ]),
    );
  }
}

/// Izgara kartı: görsel 16:10, altında sabit boylu metin alanı.
class _Kart extends StatelessWidget {
  const _Kart(this.h, {required this.baslikEtiketi});
  final YzHaber h;
  final bool baslikEtiketi;

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    return _Dokunulur(
      h: h,
      cocuk: (u) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        AspectRatio(aspectRatio: 16 / 10, child: _yakinlasan(_Gorsel(h, buyuk: false), u)),
        SizedBox(
          height: baslikEtiketi ? 132 : 116,
          child: ClipRect(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _Kunye(h, baslikEtiketi: baslikEtiketi),
                const SizedBox(height: 6),
                Text(_baslik(h, en),
                    maxLines: 3, overflow: TextOverflow.ellipsis, style: YzYazi.baslik(17).copyWith(height: 1.28)),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

/// Dar ekranda satır: solda küçük resim, sağda künye ve başlık.
class _Satir extends StatelessWidget {
  const _Satir(this.h, {required this.baslikEtiketi});
  final YzHaber h;
  final bool baslikEtiketi;

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 104,
        child: _Dokunulur(
          h: h,
          cocuk: (u) => Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SizedBox(width: 112, child: _yakinlasan(_Gorsel(h, buyuk: false), u)),
            Expanded(
              child: ClipRect(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _Kunye(h, baslikEtiketi: baslikEtiketi),
                        const SizedBox(height: 4),
                        Text(_baslik(h, en),
                            maxLines: 2, overflow: TextOverflow.ellipsis, style: YzYazi.baslik(15).copyWith(height: 1.25)),
                      ]),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
