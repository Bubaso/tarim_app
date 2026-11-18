import 'dart:async';

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/turkce_metin.dart' show buyukHarf;
import 'yz_mobil.dart';
import 'yz_okuma.dart';
import 'yz_tasarim.dart';

/// Makale sayfasının TELEFON çerçevesi (mobil okuma turu, karar 62).
///
/// Telefonda (< 640 px) metin ilk ekranın üçte birinde başlasın, okurken
/// ekranda yalnız metin kalsın diye:
///   · başlığın altındaki künye tek satır ve kısa ("4 dk · kaynaklar
///     17 Kas 2026"); teknoloji çipleri yana kayan tek satır;
///   · içindekiler, yazı boyu, arama ve paylaşma alttaki ince çubukta;
///     çubuk aşağı kaydırınca saklanıyor, yukarı kaydırınca geri geliyor;
///   · bir kez gösterilen ipucu ve işaret şeridi metnin üstünde değil,
///     alt çubuğun üstünde yüzüyor;
///   · üst şeridin altında 2 piksellik okuma çizgisi.
/// Masaüstü ve tablet düzeni bu dosyadaki hiçbir şeyi kullanmıyor.

/// Alt çubuğun yüksekliği (alt güvenli alan hariç).
const double kYzAltCubukYuksekligi = 56;

/// Üst şeridin yüksekliği (YzUstSerit).
const double kYzUstSeritYuksekligi = 52;

const _ayTr = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
const _ayEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// "2026-11-17" → "17 Kas 2026" / "17 Nov 2026".
String yzKisaTarih(String iso, bool en) {
  final t = DateTime.tryParse(iso);
  if (t == null) return iso;
  return '${t.day} ${(en ? _ayEn : _ayTr)[t.month - 1]} ${t.year}';
}

/// Telefondaki tek satırlık künye: okuma süresi ve kaynaklarından son
/// okunduğu gün, kısa biçimde.
String yzKisaKunye({int? dakika, String? guncellendi, required bool en}) => [
      if (dakika != null) en ? '$dakika min' : '$dakika dk',
      if (guncellendi != null)
        en
            ? 'sources checked ${yzKisaTarih(guncellendi, true)}'
            : 'kaynaklar ${yzKisaTarih(guncellendi, false)}',
    ].join(' · ');

TextStyle _sade({double boy = 13, Color renk = YzRenk.soluk, FontWeight kalinlik = FontWeight.w500}) =>
    GoogleFonts.outfit(fontSize: boy, fontWeight: kalinlik, color: renk, height: 1.25);

/// Başlıktaki teknoloji çipleri: tek satır, yana kayıyor; satır taşıyorsa
/// sağ kenarda yumuşak bir solma (kesik çip görünmesin).
class YzCerceveCipSirasi extends StatefulWidget {
  const YzCerceveCipSirasi({super.key, required this.cipler});
  final List<Widget> cipler;

  @override
  State<YzCerceveCipSirasi> createState() => _YzCerceveCipSirasiState();
}

class _YzCerceveCipSirasiState extends State<YzCerceveCipSirasi> {
  bool _solma = false;

  bool _olc(ScrollMetrics m) {
    final s = m.extentAfter > 0.5;
    if (s != _solma) setState(() => _solma = s);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      NotificationListener<ScrollMetricsNotification>(
        onNotification: (n) => _olc(n.metrics),
        child: NotificationListener<ScrollNotification>(
          onNotification: (n) => _olc(n.metrics),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              for (final c in widget.cipler) Padding(padding: const EdgeInsets.only(right: 6), child: c),
            ]),
          ),
        ),
      ),
      if (_solma)
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: 36,
          child: IgnorePointer(
            child: DecoratedBox(
              key: const ValueKey('yz-cip-solma'),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [YzRenk.zemin.withValues(alpha: 0), YzRenk.zemin],
                ),
              ),
            ),
          ),
        ),
    ]);
  }
}

/// Sayfanın ne kadarının okunduğu: üst şeridin hemen altında 2 piksel.
class YzCerceveIlerleme extends StatelessWidget {
  const YzCerceveIlerleme({super.key, required this.oran, required this.en});
  final ValueListenable<double> oran;
  final bool en;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: oran,
      builder: (context, v, _) => Semantics(
        label: en ? 'Reading progress' : 'Okuma ilerlemesi',
        value: '%${(v * 100).round()}',
        child: Container(
          key: const ValueKey('yz-okuma-cizgisi'),
          height: 2,
          color: YzRenk.cizgi,
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: v.clamp(0.0, 1.0),
            heightFactor: 1,
            child: const ColoredBox(color: YzRenk.makine),
          ),
        ),
      ),
    );
  }
}

/// Alt çubuğun bir düğmesi: simge ve küçük ad, ≥ 44 px dokunma alanı.
class _AltDugme extends StatelessWidget {
  const _AltDugme({required this.simge, required this.ad, required this.onTap});
  final Widget simge;
  final String ad;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        label: ad,
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: kYzAltCubukYuksekligi,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(height: 24, child: Center(child: simge)),
              const SizedBox(height: 3),
              Text(ad,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _sade(boy: 11.5, renk: YzRenk.soluk)),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Telefonda yüzen "İçindekiler" düğmesinin yerine: ince alt çubuk.
class YzCerceveAltCubuk extends StatelessWidget {
  const YzCerceveAltCubuk({
    super.key,
    required this.en,
    required this.icindekiler,
    required this.yaziBoyu,
    required this.ara,
    required this.paylas,
  });
  final bool en;
  final VoidCallback icindekiler;
  final VoidCallback yaziBoyu;
  final VoidCallback? ara;
  final VoidCallback paylas;

  @override
  Widget build(BuildContext context) {
    final alt = MediaQuery.paddingOf(context).bottom;
    const renk = YzRenk.makine;
    return Material(
      color: YzRenk.yuzey,
      child: Container(
        key: const ValueKey('yz-alt-cubuk'),
        padding: EdgeInsets.only(bottom: alt),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: YzRenk.cizgi, width: 0.5)),
        ),
        child: Row(children: [
          _AltDugme(
            simge: const Icon(Icons.format_list_bulleted_rounded, size: 22, color: renk),
            ad: en ? 'Contents' : 'İçindekiler',
            onTap: icindekiler,
          ),
          _AltDugme(
            simge: Text('Aa', style: YzYazi.baslik(18, renk: renk)),
            ad: en ? 'Text size' : 'Yazı boyu',
            onTap: yaziBoyu,
          ),
          _AltDugme(
            simge: const Icon(Icons.search_rounded, size: 22, color: renk),
            ad: en ? 'Search' : 'Ara',
            onTap: ara,
          ),
          _AltDugme(
            simge: const Icon(Icons.ios_share_rounded, size: 21, color: renk),
            ad: en ? 'Share' : 'Paylaş',
            onTap: paylas,
          ),
        ]),
      ),
    );
  }
}

/// Alt sayfaların ortak satırı: simge, yazı, ≥ 48 px yükseklik.
class _SayfaSatiri extends StatelessWidget {
  const _SayfaSatiri({required this.simge, required this.yazi, required this.onTap});
  final IconData simge;
  final String yazi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(children: [
            Icon(simge, size: 20, color: YzRenk.makine),
            const SizedBox(width: 14),
            Expanded(child: Text(yazi, style: _sade(boy: 16, renk: YzRenk.murekkep))),
          ]),
        ),
      ),
    );
  }
}

/// İçindekiler (alt sayfa): önce "Başa dön", sonra alt başlıklar; okunan
/// bölüm yumuşak zeminle (sol çizgi yok). Dokununca sayfa kapanıp o bölüme
/// gidiliyor.
Future<void> yzCerceveIcindekiler(
  BuildContext context, {
  required bool en,
  required List<String> basliklar,
  required int aktif,
  required void Function(int) git,
  required VoidCallback basaDon,
}) =>
    yzAltSayfa<void>(
      context,
      builder: (c) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Text(buyukHarf(en ? 'Contents' : 'İçindekiler', en), style: YzYazi.ustEtiket()),
          ),
          _SayfaSatiri(
            simge: Icons.arrow_upward_rounded,
            yazi: en ? 'Back to top' : 'Başa dön',
            onTap: () {
              Navigator.of(c).pop();
              basaDon();
            },
          ),
          if (basliklar.isNotEmpty) const Divider(color: YzRenk.cizgi, height: 12),
          for (var i = 0; i < basliklar.length; i++)
            Semantics(
              button: true,
              selected: i == aktif,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Material(
                  color: i == aktif ? YzRenk.makineAcik : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      Navigator.of(c).pop();
                      git(i);
                    },
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            basliklar[i],
                            style: YzYazi.govde(boy: 16, renk: YzRenk.makine).copyWith(
                                height: 1.35,
                                fontWeight: i == aktif ? FontWeight.w600 : FontWeight.w400),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

/// Yazı boyu (alt sayfa): A− / A+ ve şimdiki boy. Okunan yer, makale
/// sayfasının yazı boyu dinleyicisiyle korunuyor.
Future<void> yzCerceveYaziBoyu(BuildContext context, {required bool en}) => yzAltSayfa<void>(
      context,
      builder: (c) => Consumer(builder: (c, ref, _) {
        final olcek = ref.watch(yzYaziOlcegiProvider);
        final denetci = ref.read(yzYaziOlcegiProvider.notifier);
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(buyukHarf(en ? 'Text size' : 'Yazı boyu', en), style: YzYazi.ustEtiket()),
              const SizedBox(height: 8),
              Row(children: [
                IconButton(
                  tooltip: en ? 'Smaller' : 'Küçült',
                  iconSize: 28,
                  constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
                  onPressed: denetci.kuculebilir ? denetci.kucult : null,
                  icon: Text('A−',
                      style: YzYazi.baslik(16, renk: denetci.kuculebilir ? YzRenk.makine : YzRenk.cizgi)),
                ),
                Expanded(
                  child: Text('%${(olcek * 100).round()}',
                      textAlign: TextAlign.center,
                      style: YzYazi.veri(boy: 15, renk: YzRenk.murekkep)),
                ),
                IconButton(
                  tooltip: en ? 'Larger' : 'Büyüt',
                  iconSize: 28,
                  constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
                  onPressed: denetci.buyuyebilir ? denetci.buyut : null,
                  icon: Text('A+',
                      style: YzYazi.baslik(22, renk: denetci.buyuyebilir ? YzRenk.makine : YzRenk.cizgi)),
                ),
              ]),
              if (olcek != 1.0)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    style: TextButton.styleFrom(minimumSize: const Size(48, 44)),
                    onPressed: denetci.sifirla,
                    child: Text(en ? 'Default' : 'Varsayılan',
                        style: YzYazi.veri(boy: 12.5, renk: YzRenk.makine)),
                  ),
                ),
            ],
          ),
        );
      }),
    );

/// Paylaş (alt sayfa): bağlantıyı paylaş, bağlantıyı kopyala, yazdır / PDF.
Future<void> yzCercevePaylas(
  BuildContext context, {
  required bool en,
  required VoidCallback paylas,
  required VoidCallback kopyala,
  required VoidCallback? yazdir,
}) =>
    yzAltSayfa<void>(
      context,
      builder: (c) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Text(buyukHarf(en ? 'Share' : 'Paylaş', en), style: YzYazi.ustEtiket()),
          ),
          _SayfaSatiri(
            simge: Icons.ios_share_rounded,
            yazi: en ? 'Share link' : 'Bağlantıyı paylaş',
            onTap: () {
              Navigator.of(c).pop();
              paylas();
            },
          ),
          _SayfaSatiri(
            simge: Icons.link_rounded,
            yazi: en ? 'Copy link' : 'Bağlantıyı kopyala',
            onTap: () {
              Navigator.of(c).pop();
              kopyala();
            },
          ),
          if (yazdir != null)
            _SayfaSatiri(
              simge: Icons.print_outlined,
              yazi: en ? 'Print / PDF' : 'Yazdır / PDF',
              onTap: () {
                Navigator.of(c).pop();
                yazdir();
              },
            ),
        ],
      ),
    );

/// Bir kez gösterilen ipucu, telefonda: metnin üstünde değil, alt çubuğun
/// üstünde yüzen küçük kart. 8 saniye sonra kendiliğinden kapanıyor;
/// kapanınca görülmüş sayılıyor (aynı `yzIpucuProvider`).
class YzCerceveIpucu extends StatefulWidget {
  const YzCerceveIpucu({super.key, required this.en, required this.kapat});
  final bool en;
  final VoidCallback kapat;

  static const Duration sure = Duration(seconds: 8);

  @override
  State<YzCerceveIpucu> createState() => _YzCerceveIpucuState();
}

class _YzCerceveIpucuState extends State<YzCerceveIpucu> {
  Timer? _sayac;

  @override
  void initState() {
    super.initState();
    _sayac = Timer(YzCerceveIpucu.sure, () {
      if (mounted) widget.kapat();
    });
  }

  @override
  void dispose() {
    _sayac?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final en = widget.en;
    return Material(
      key: const ValueKey('yz-yuzen-ipucu'),
      color: YzRenk.bitkiAcik,
      elevation: 3,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
        child: Row(children: [
          const Icon(Icons.touch_app_outlined, size: 18, color: YzRenk.bitki),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              en
                  ? 'Tap a blue figure to see its source; tap a term or abbreviation with a dotted underline to see what it means.'
                  : 'Mavi rakamlara dokunun, kaynağı açılır. Altı noktalı terim ve kısaltmalara dokunun, ne demek olduğu açılır.',
              style: YzYazi.govde(boy: 13.5).copyWith(height: 1.35),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(minimumSize: const Size(48, 44)),
            onPressed: () {
              _sayac?.cancel();
              widget.kapat();
            },
            child: Text(en ? 'Got it' : 'Anladım',
                style: YzYazi.veri(boy: 12.5, renk: YzRenk.bitki, kalinlik: FontWeight.w700)),
          ),
        ]),
      ),
    );
  }
}

/// İşaret şeridi, telefonda: alt çubuğun üstünde ince çubuk —
/// "<ad> · N yer", "Sonraki ↓" ve kapat.
class YzCerceveIsaretCubugu extends StatelessWidget {
  const YzCerceveIsaretCubugu({
    super.key,
    required this.ad,
    required this.sayi,
    required this.en,
    required this.kalem,
    required this.sonraki,
    this.kapat,
  });
  final String ad;
  final int sayi;
  final bool en;
  final Color kalem;
  final VoidCallback sonraki;
  final VoidCallback? kapat;

  /// Çubuğun yaklaşık yüksekliği (kaydırma boşluğu için).
  static const double yukseklik = 52;

  @override
  Widget build(BuildContext context) {
    final sayiYazisi = sayi == 0
        ? (en ? 'not on this page' : 'bu sayfada geçmiyor')
        : (en ? '$sayi ${sayi == 1 ? 'place' : 'places'}' : '$sayi yer');
    return Material(
      key: const ValueKey('yz-isaret-cubugu'),
      color: YzRenk.yuzey,
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: YzRenk.cizgi),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Row(children: [
          Container(
            width: 18,
            height: 10,
            decoration: BoxDecoration(color: kalem, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text('$ad · $sayiYazisi',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _sade(boy: 14, renk: YzRenk.murekkep)),
          ),
          if (sayi > 0)
            TextButton(
              style: TextButton.styleFrom(
                  minimumSize: const Size(48, 44), padding: const EdgeInsets.symmetric(horizontal: 8)),
              onPressed: sonraki,
              child: Text(en ? 'Next ↓' : 'Sonraki ↓', style: YzYazi.veri(boy: 13, renk: YzRenk.makine)),
            ),
          if (kapat != null)
            IconButton(
              tooltip: en ? 'Remove marking' : 'İşareti kaldır',
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              icon: const Icon(Icons.close_rounded, size: 18, color: YzRenk.makine),
              onPressed: kapat,
            ),
        ]),
      ),
    );
  }
}

/// Künyenin telefondaki satırı.
class YzCerceveKunye extends StatelessWidget {
  const YzCerceveKunye(this.metin, {super.key});
  final String metin;

  @override
  Widget build(BuildContext context) =>
      Text(metin, maxLines: 1, overflow: TextOverflow.ellipsis, style: _sade());
}
