import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/yz_iskelet.g.dart';
import '../data/yz_metinler.g.dart';
import '../data/yz_teknoloji.g.dart';
import 'yz_okuma.dart';
import 'yz_tasarim.dart';
import 'yz_yollar.dart';

/// Merkez sayfanın TELEFON düzeni (mobil tur, 18 Kasım 2026).
///
/// 375 piksellik ekranda iki sütun çerçeveli karo dört ekran kutu
/// ediyordu (★20). Telefonda başlıklar karosuz, ince çizgiyle ayrılmış tek
/// sütun bir liste; masaüstü ve tablet ızgarası değişmedi (yz_harita.dart).

/// Okuma süresi ve okundu işareti: düz, küçük yazı (★10; mono değil).
TextStyle yzMerkezMeta({Color renk = YzRenk.soluk, FontWeight kalinlik = FontWeight.w500}) =>
    GoogleFonts.outfit(fontSize: 13, fontWeight: kalinlik, color: renk, height: 1.2);

/// Satırlar arasındaki ince çizgi.
class YzMerkezCizgi extends StatelessWidget {
  const YzMerkezCizgi({super.key});

  @override
  Widget build(BuildContext context) =>
      const SizedBox(height: 1, width: double.infinity, child: ColoredBox(color: YzRenk.cizgi));
}

/// Telefonda bir başlık satırı. [YzBaslikKarosu]nun taşıdığı her durumu
/// taşıyor: okuma süresi ve okundu işareti; teknoloji seçiliyken o
/// teknolojiyi taşımayan başlık sönük, taşıyanda geçtiği yer sayısı, asıl
/// konu olduğu başlıkta "ana" ve yumuşak mavi zemin, altında kesişim
/// cümlesi; dokununca aynı adres (seçiliyse `?teknoloji=` ile).
class YzBaslikSatiri extends ConsumerWidget {
  const YzBaslikSatiri(
      {super.key, required this.baslik, this.sonuk = false, this.teknoloji, this.ana = false});
  final YzBaslik baslik;
  final bool sonuk;
  final String? teknoloji;
  final bool ana;

  static const double enAzYukseklik = 52;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final en = yzIsEn(context);
    final secili = teknoloji != null && !sonuk;
    final anaVurgu = secili && ana;
    final izSayisi = secili ? (kYzTeknolojiIzi[baslik.no]?[teknoloji]?[en ? 1 : 0] ?? 0) : 0;
    final metin = kYzMetinler[baslik.no];
    final okundu = ref.watch(yzOkumaIziProvider).okunan.contains(yzBaslikPath(baslik.slug));
    final dakika = metin == null ? null : yzOkumaSuresi(metin.metin(en), en);
    final kesisimler = secili ? kYzKesisim[teknoloji] : null;
    final kesisimCifti = kesisimler == null ? null : kesisimler[baslik.no];
    final kesisim = kesisimCifti == null ? null : kesisimCifti[en ? 1 : 0];
    final adres = secili
        ? Uri(path: yzBaslikPath(baslik.slug), queryParameters: {'teknoloji': teknoloji!}).toString()
        : yzBaslikPath(baslik.slug);
    void git() => context.push(adres);

    // Ekran okuyucuya tek cümle: karodaki etiketin tamamı.
    final durum = !secili
        ? (dakika == null
            ? null
            : (en
                ? '$dakika min read${okundu ? ', read' : ''}'
                : '$dakika dk okuma${okundu ? ', okundu' : ''}'))
        : (ana
            ? (en ? 'main heading, $izSayisi mentions' : 'ana başlık, $izSayisi yerde geçiyor')
            : (en ? '$izSayisi mentions' : '$izSayisi yerde geçiyor'));
    final etiket = [baslik.ad(en), if (durum != null) durum, if (kesisim != null) kesisim].join('. ');

    Widget sag;
    if (secili) {
      sag = Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: anaVurgu ? YzRenk.makine : YzRenk.makineAcik,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          ana
              ? (en ? 'main · $izSayisi' : 'ana · $izSayisi')
              : (en ? '$izSayisi mentions' : '$izSayisi yerde'),
          style: yzMerkezMeta(
              renk: anaVurgu ? Colors.white : YzRenk.makine, kalinlik: FontWeight.w600),
        ),
      );
    } else {
      sag = Row(mainAxisSize: MainAxisSize.min, children: [
        if (dakika != null) Text(en ? '$dakika min' : '$dakika dk', style: yzMerkezMeta()),
        if (okundu) ...[
          const SizedBox(width: 6),
          Text('✓', style: yzMerkezMeta(renk: YzRenk.bitki, kalinlik: FontWeight.w700)),
        ],
      ]);
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: sonuk ? 0.32 : 1,
      child: Semantics(
        button: true,
        label: etiket,
        onTap: git,
        excludeSemantics: true,
        child: Material(
          color: anaVurgu ? YzRenk.makineAcik : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: git,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: enAzYukseklik),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          baslik.ad(en),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: YzRenk.murekkep,
                            height: 1.25,
                          ),
                        ),
                        if (kesisim != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            kesisim,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: YzYazi.govde(boy: 14, renk: YzRenk.soluk).copyWith(height: 1.35),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  sag,
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Telefonda teknoloji çiplerinin tek satırı (★2): yana kayıyor; taşıyorsa
/// sağ kenarda yumuşak bir solgunluk "devamı var" diyor, sonuna gelince
/// kalkıyor. Kesik bir çip kalmıyor.
class YzMerkezCipSeridi extends StatefulWidget {
  const YzMerkezCipSeridi({super.key, required this.children, this.zemin = YzRenk.zemin});
  final List<Widget> children;
  final Color zemin;

  static const solgunlukAnahtari = ValueKey('yz-merkez-cip-solgunluk');

  @override
  State<YzMerkezCipSeridi> createState() => _YzMerkezCipSeridiState();
}

class _YzMerkezCipSeridiState extends State<YzMerkezCipSeridi> {
  final _kaydirma = ScrollController();
  bool _solgun = false;

  @override
  void initState() {
    super.initState();
    _kaydirma.addListener(_guncelle);
    WidgetsBinding.instance.addPostFrameCallback((_) => _guncelle());
  }

  void _guncelle() {
    if (!mounted || !_kaydirma.hasClients) return;
    final p = _kaydirma.position;
    if (!p.hasContentDimensions) return;
    final yeni = p.maxScrollExtent > 0.5 && p.pixels < p.maxScrollExtent - 0.5;
    if (yeni != _solgun) setState(() => _solgun = yeni);
  }

  @override
  void dispose() {
    _kaydirma.removeListener(_guncelle);
    _kaydirma.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _guncelle());
        return false;
      },
      child: Stack(children: [
        SingleChildScrollView(
          controller: _kaydirma,
          scrollDirection: Axis.horizontal,
          child: Row(children: widget.children),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          width: 44,
          child: IgnorePointer(
            child: AnimatedOpacity(
              key: YzMerkezCipSeridi.solgunlukAnahtari,
              duration: const Duration(milliseconds: 160),
              opacity: _solgun ? 1 : 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.zemin.withValues(alpha: 0), widget.zemin],
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
