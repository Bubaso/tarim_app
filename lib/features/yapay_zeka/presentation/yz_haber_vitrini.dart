import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/turkce_metin.dart';
import '../data/yz_deposu.dart';
import '../yz_providers.dart';
import 'yz_olcum_gonderici.dart';
import 'yz_tasarim.dart';
import 'yz_yollar.dart';

/// Bölümün haberleri, görselleriyle bir vitrin olarak (karar 59: liste değil).
///
/// Başlık sayfasında (madde 27, seçenek A): en yeni 3 haber küçük kartlarda
/// (geniş sütunda yan yana üç, dar sütunda iki sütun); fazlası varsa
/// "N haber daha" listeyi yerinde açar (en çok 12). Özet yok.
///
/// Merkez sayfada (madde 28): geniş ekranda solda manşet, sağda üç yan
/// haber; tablette ve telefonda manşet ve altında iki sütunlu dört küçük
/// kart. "Tüm haberler (N)" geri kalanını yerinde açar.
///
/// Kartlarda üzerine gelince büyüme ya da gölge yok; kartın tamamı tek
/// dokunma hedefi (içinde ikinci bir bağlantı yok). Bütün boylar sabit
/// ölçülerle hesaplanıyor: [kur] kapalıyken aynı boyda durağan çerçeveler
/// çiziliyor, kartlar kurulunca yerleşim kaymıyor (madde 29).
///
/// Görsel: listelerde yalnız küçük görsel (`thumb_image_url`), merkezdeki
/// manşette büyük görsel; ikisi de yalnız portalın kendi deposundan. Dış
/// siteye doğrudan bağlanılmıyor; görsel yoksa yazısız tarla dokusu.
class YzHaberVitrini extends StatefulWidget {
  const YzHaberVitrini({
    super.key,
    required this.haberler,
    this.merkez = true,
    this.kur = true,
    this.olcumSayfasi,
  });
  final List<YzHaber> haberler;

  /// Merkez sayfa (manşet düzeni) ya da başlık sayfası (küçük kartlar).
  final bool merkez;

  /// false: kartların yerine aynı boyda durağan çerçeveler.
  final bool kur;

  /// Habere dokunulunca `yz_haber` ölçümüne giden sayfa (başlığın slug'ı).
  final String? olcumSayfasi;

  @override
  State<YzHaberVitrini> createState() => _YzHaberVitriniState();
}

/// Başlık sayfasında ilk gösterilen ve en çok açılan haber sayısı.
const int kYzBaslikHaberIlk = 3;
const int kYzBaslikHaberEnCok = 12;

class _YzHaberVitriniState extends State<YzHaberVitrini> {
  bool _acik = false;

  @override
  Widget build(BuildContext context) {
    if (widget.haberler.isEmpty) return const SizedBox.shrink();
    final en = yzIsEn(context);
    final s = MediaQuery.textScalerOf(context);
    return LayoutBuilder(builder: (context, kis) {
      final w = kis.maxWidth;
      return widget.merkez ? _merkez(w, s, en) : _baslik(w, en);
    });
  }

  void _ac() => setState(() => _acik = true);

  Widget _baslik(double w, bool en) {
    final hepsi = widget.haberler.take(kYzBaslikHaberEnCok).toList();
    final gorunen = _acik ? hepsi : hepsi.take(kYzBaslikHaberIlk).toList();
    final kalan = hepsi.length - gorunen.length;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _KartIzgarasi(
        haberler: gorunen,
        sutun: w >= 480 ? 3 : 2,
        genislik: w,
        kur: widget.kur,
        baslikAdi: false,
        olcumSayfasi: widget.olcumSayfasi,
      ),
      if (kalan > 0)
        _AcmaBaglantisi(
          anahtar: const ValueKey('yz-haber-daha'),
          metin: en ? '$kalan more' : '$kalan haber daha',
          onTap: _ac,
        ),
    ]);
  }

  Widget _merkez(double w, TextScaler s, bool en) {
    final haberler = widget.haberler;
    final kur = widget.kur;
    final genis = w >= 900;
    final ilk = genis ? 4 : 5;
    final kalanlar = haberler.skip(ilk).toList();
    final ust = genis ? _MerkezBandi(haberler: haberler, genislik: w, kur: kur) : _merkezDar(w, s, kur);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ust,
      if (kalanlar.isNotEmpty && !_acik)
        _AcmaBaglantisi(
          anahtar: const ValueKey('yz-tum-haberler'),
          metin: en ? 'All news (${haberler.length})' : 'Tüm haberler (${haberler.length})',
          onTap: _ac,
        ),
      if (kalanlar.isNotEmpty && _acik) ...[
        SizedBox(height: _ara(w)),
        _KartIzgarasi(
          haberler: kalanlar,
          sutun: genis ? 4 : 2,
          genislik: w,
          kur: kur,
          baslikAdi: true,
        ),
      ],
    ]);
  }

  Widget _merkezDar(double w, TextScaler s, bool kur) {
    final haberler = widget.haberler;
    final manset = haberler.first;
    final kartlar = haberler.skip(1).take(4).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (w < 600)
        SizedBox(
          height: w * 9 / 16 + _Manset.metinBoyu(s, baslikBoyu: 21, baslikSatiri: 3),
          child: _Manset(manset, kur: kur, baslikBoyu: 21, baslikSatiri: 3),
        )
      else
        SizedBox(height: _MansetYatay.boy, child: _MansetYatay(manset, kur: kur)),
      if (kartlar.isNotEmpty) ...[
        SizedBox(height: _ara(w)),
        _KartIzgarasi(haberler: kartlar, sutun: 2, genislik: w, kur: kur, baslikAdi: true),
      ],
    ]);
  }
}

double _ara(double w) => w < 480 ? 12 : 16;

/// "N haber daha" / "Tüm haberler (N)": çelik mavisi, listeyi yerinde açar.
class _AcmaBaglantisi extends StatelessWidget {
  const _AcmaBaglantisi({required this.anahtar, required this.metin, required this.onTap});
  final Key anahtar;
  final String metin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            key: anahtar,
            onPressed: onTap,
            style: TextButton.styleFrom(
              minimumSize: const Size(44, 44),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              foregroundColor: YzRenk.makine,
            ),
            child: Text('$metin →',
                style: YzYazi.veri(boy: 13, renk: YzRenk.makine, kalinlik: FontWeight.w600)),
          ),
        ),
      );
}

// ── Ortak parçalar ───────────────────────────────────────────────────────

String _gun(DateTime t, bool en) {
  const tr = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
  const ing = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final y = t.toLocal();
  return '${y.day} ${(en ? ing : tr)[y.month - 1]} ${y.year}';
}

String _baslikMetni(YzHaber h, bool en) {
  final a = h.haber;
  return (en && (a.titleEn ?? '').isNotEmpty) ? a.titleEn! : a.title;
}

String? _ozet(YzHaber h, bool en) {
  final a = h.haber;
  final s = (en && (a.summaryEn ?? '').isNotEmpty) ? a.summaryEn : a.summary;
  return (s ?? '').trim().isEmpty ? null : s!.trim();
}

/// Künye: kaynak · tarih (mono 12 px).
String _kunyeMetni(YzHaber h, bool en) {
  final kaynak = (h.haber.sourceName ?? '').trim();
  final gun = _gun(h.haber.createdAt, en);
  return kaynak.isEmpty ? gun : '$kaynak · $gun';
}

const double _kunyeBoyu = 12;
const double _kunyeSatiri = 1.35;
const double _etiketBoyu = 11.5;
const double _etiketSatiri = 1.35;

TextStyle _kunyeYazisi() => YzYazi.veri(boy: _kunyeBoyu).copyWith(height: _kunyeSatiri);

/// Haberin başlığının adı — düz yazı (iç içe ikinci dokunma hedefi değil).
TextStyle _etiketYazisi() => YzYazi.ustEtiket(renk: YzRenk.bitki).copyWith(height: _etiketSatiri);

/// Künye bloğunun boyu: (isteğe bağlı) başlık adı + kaynak · tarih.
double _kunyeBlokBoyu(TextScaler s, {required bool baslikAdi}) =>
    (baslikAdi ? s.scale(_etiketBoyu) * _etiketSatiri + 3 : 0) + s.scale(_kunyeBoyu) * _kunyeSatiri;

class _Kunye extends StatelessWidget {
  const _Kunye(this.h, {required this.baslikAdi});
  final YzHaber h;
  final bool baslikAdi;

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    final ad = h.baslik?.ad(en);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      if (baslikAdi) ...[
        Text(ad == null ? '' : buyukHarf(ad, en),
            maxLines: 1, overflow: TextOverflow.ellipsis, style: _etiketYazisi()),
        const SizedBox(height: 3),
      ],
      Text(_kunyeMetni(h, en), maxLines: 1, overflow: TextOverflow.ellipsis, style: _kunyeYazisi()),
    ]);
  }
}

/// Görsel yalnız portalın kendi deposundan: dış siteye doğrudan bağlanılmaz.
String? _kendiGorseli(String? ham) {
  final u = (ham ?? '').trim();
  if (!u.startsWith('https://')) return null;
  final host = Uri.tryParse(u)?.host ?? '';
  if (host.isEmpty) return null;
  if (host == Uri.tryParse(ApiConstants.supabaseUrl)?.host) return u;
  final firebase = host.endsWith('.firebasestorage.app') ||
      host == 'firebasestorage.googleapis.com' ||
      host == 'storage.googleapis.com';
  return firebase && u.contains('tarim-app-2026') ? u : null;
}

/// Kartın görseli; yoksa (ya da inemezse) yazısız tarla dokusu. Dönen
/// gösterge ya da parıltı yok: görsel inene kadar da doku duruyor.
class _Gorsel extends StatelessWidget {
  const _Gorsel(this.h, {required this.buyuk});
  final YzHaber h;

  /// Merkezdeki manşet: büyük görsel. Öbür her yerde küçük görsel.
  final bool buyuk;

  static Widget doku() => Container(
        color: YzRenk.bitkiAcik,
        child: const CustomPaint(
          painter: TarlaIzgarasi(solma: false, yogunluk: 1.4),
          child: SizedBox.expand(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final a = h.haber;
    final adres = buyuk
        ? (_kendiGorseli(a.imageUrl) ?? _kendiGorseli(a.thumbImageUrl))
        : _kendiGorseli(a.thumbImageUrl);
    if (adres == null) return doku();
    final altyazi = (a.imageCaption ?? '').trim();
    return LayoutBuilder(builder: (context, kis) {
      final dpr = MediaQuery.devicePixelRatioOf(context);
      final gen = kis.maxWidth.isFinite ? kis.maxWidth : 320.0;
      final cozum = (gen * dpr).clamp(160.0, buyuk ? 1400.0 : 640.0).round();
      return Image(
        image: ResizeImage(CachedNetworkImageProvider(adres), width: cozum),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
        semanticLabel: altyazi.isEmpty ? null : altyazi,
        excludeFromSemantics: altyazi.isEmpty,
        frameBuilder: (context, cocuk, kare, esZamanli) => kare == null && !esZamanli ? doku() : cocuk,
        errorBuilder: (_, __, ___) => doku(),
      );
    });
  }
}

/// Kartın kabuğu: çerçeve; [kur] açıksa dokunulur (tamamı tek hedef),
/// kapalıysa aynı boyda boş, durağan çerçeve.
class _Kabuk extends StatelessWidget {
  const _Kabuk({required this.h, required this.kur, required this.cocuk, this.olcumSayfasi});
  final YzHaber h;
  final bool kur;
  final Widget Function() cocuk;
  final String? olcumSayfasi;

  static const _cerceve = BoxDecoration(
    color: YzRenk.yuzey,
    borderRadius: BorderRadius.all(Radius.circular(6)),
    border: Border.fromBorderSide(BorderSide(color: YzRenk.cizgi)),
  );

  @override
  Widget build(BuildContext context) {
    if (!kur) return const DecoratedBox(decoration: _cerceve, child: SizedBox.expand());
    return Semantics(
      button: true,
      label: _baslikMetni(h, yzIsEn(context)),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            final sayfa = olcumSayfasi;
            if (sayfa != null) yzOlcum('yz_haber', {'sayfa': sayfa});
            context.push(articlePath(h.haber.id));
          },
          child: Container(decoration: _cerceve, clipBehavior: Clip.antiAlias, child: cocuk()),
        ),
      ),
    );
  }
}

// ── Küçük kart (madde 27, seçenek A) ─────────────────────────────────────

/// 16:9 küçük görsel, künye (mono 12 px), en çok 3 satır başlık
/// (Outfit 700, 15 px). Boyu genişlikten ve yazı ölçeğinden hesaplanıyor.
class _KucukKart extends StatelessWidget {
  const _KucukKart(this.h, {required this.kur, required this.baslikAdi, this.olcumSayfasi});
  final YzHaber h;
  final bool kur;
  final bool baslikAdi;
  final String? olcumSayfasi;

  static const double _ustPay = 10;
  static const double _altPay = 12;
  static const double _baslikBoyu = 15;
  static const double _baslikSatiri = 1.25;

  static double gorselBoyu(double genislik) => (genislik * 9 / 16).roundToDouble();

  static double metinBoyu(TextScaler s, {required bool baslikAdi}) =>
      (_ustPay + _kunyeBlokBoyu(s, baslikAdi: baslikAdi) + 5 + 3 * s.scale(_baslikBoyu) * _baslikSatiri + _altPay)
          .ceilToDouble() +
      2;

  static double boy(double genislik, TextScaler s, {required bool baslikAdi}) =>
      gorselBoyu(genislik) + metinBoyu(s, baslikAdi: baslikAdi);

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    return _Kabuk(
      h: h,
      kur: kur,
      olcumSayfasi: olcumSayfasi,
      cocuk: () => LayoutBuilder(
        builder: (context, kis) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SizedBox(height: gorselBoyu(kis.maxWidth), child: _Gorsel(h, buyuk: false)),
          Expanded(
            child: ClipRect(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, _ustPay, 10, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _Kunye(h, baslikAdi: baslikAdi),
                  const SizedBox(height: 5),
                  Text(_baslikMetni(h, en),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: YzYazi.baslik(_baslikBoyu).copyWith(height: _baslikSatiri)),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

/// Küçük kartlar satır satır; satırdaki kartlar eşit genişlik ve boyda.
class _KartIzgarasi extends StatelessWidget {
  const _KartIzgarasi({
    required this.haberler,
    required this.sutun,
    required this.genislik,
    required this.kur,
    required this.baslikAdi,
    this.olcumSayfasi,
  });
  final List<YzHaber> haberler;
  final int sutun;
  final double genislik;
  final bool kur;
  final bool baslikAdi;
  final String? olcumSayfasi;

  @override
  Widget build(BuildContext context) {
    final ara = _ara(genislik);
    final kartGenisligi = (genislik - (sutun - 1) * ara) / sutun;
    final kartBoyu = _KucukKart.boy(kartGenisligi, MediaQuery.textScalerOf(context), baslikAdi: baslikAdi);
    final satirlar = <Widget>[];
    for (var i = 0; i < haberler.length; i += sutun) {
      if (i > 0) satirlar.add(SizedBox(height: ara));
      satirlar.add(SizedBox(
        height: kartBoyu,
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (var j = 0; j < sutun; j++) ...[
            if (j > 0) SizedBox(width: ara),
            Expanded(
              child: i + j < haberler.length
                  ? _KucukKart(haberler[i + j], kur: kur, baslikAdi: baslikAdi, olcumSayfasi: olcumSayfasi)
                  : const SizedBox.shrink(),
            ),
          ],
        ]),
      ));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: satirlar);
  }
}

// ── Merkez: manşet ve yan haberler (madde 28) ───────────────────────────

/// Geniş ekranda tek bant: solda manşet, sağda üç yan haber. Altında ızgara yok.
class _MerkezBandi extends StatelessWidget {
  const _MerkezBandi({required this.haberler, required this.genislik, required this.kur});
  final List<YzHaber> haberler;
  final double genislik;
  final bool kur;

  static const double _ara = 20;

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.textScalerOf(context);
    final yan = haberler.skip(1).take(3).toList();
    final mansetGenisligi = yan.isEmpty ? genislik : (genislik - _ara) * 3 / 5;
    final boy = mansetGenisligi * 9 / 16 + _Manset.metinBoyu(s, baslikBoyu: 24, baslikSatiri: 2);
    return SizedBox(
      height: boy,
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(flex: 3, child: _Manset(haberler.first, kur: kur, baslikBoyu: 24, baslikSatiri: 2)),
        if (yan.isNotEmpty) ...[
          const SizedBox(width: _ara),
          Expanded(
            flex: 2,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                Expanded(child: i < yan.length ? _Yan(yan[i], kur: kur) : const SizedBox.shrink()),
              ],
            ]),
          ),
        ],
      ]),
    );
  }
}

/// Manşet: 16:9 görsel, başlık, 2 satır özet. Dışarıdan verilen boya sığar.
class _Manset extends StatelessWidget {
  const _Manset(this.h, {required this.kur, required this.baslikBoyu, required this.baslikSatiri});
  final YzHaber h;
  final bool kur;
  final double baslikBoyu;
  final int baslikSatiri;

  static const double _satir = 1.22;
  static const double _ozetBoyu = 15.5;
  static const double _ozetSatiri = 1.45;

  /// Görselin altındaki metin alanının boyu (özet yoksa da aynı: boy sabit).
  static double metinBoyu(TextScaler s, {required double baslikBoyu, required int baslikSatiri}) =>
      (14 +
              _kunyeBlokBoyu(s, baslikAdi: true) +
              8 +
              baslikSatiri * s.scale(baslikBoyu) * _satir +
              6 +
              2 * s.scale(_ozetBoyu) * _ozetSatiri +
              14)
          .ceilToDouble() +
      2;

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    final ozet = _ozet(h, en);
    return _Kabuk(
      h: h,
      kur: kur,
      cocuk: () => LayoutBuilder(
        builder: (context, kis) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SizedBox(height: kis.maxWidth * 9 / 16, child: _Gorsel(h, buyuk: true)),
          Expanded(
            child: ClipRect(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _Kunye(h, baslikAdi: true),
                  const SizedBox(height: 8),
                  Text(_baslikMetni(h, en),
                      maxLines: baslikSatiri,
                      overflow: TextOverflow.ellipsis,
                      style: YzYazi.baslik(baslikBoyu).copyWith(height: _satir)),
                  if (ozet != null) ...[
                    const SizedBox(height: 6),
                    Text(ozet,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: YzYazi.govde(boy: _ozetBoyu, renk: YzRenk.soluk).copyWith(height: _ozetSatiri)),
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

/// Tablette manşet: solda görsel, sağda metin; sabit boy.
class _MansetYatay extends StatelessWidget {
  const _MansetYatay(this.h, {required this.kur});
  final YzHaber h;
  final bool kur;

  static const double boy = 250;

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    final ozet = _ozet(h, en);
    return _Kabuk(
      h: h,
      kur: kur,
      cocuk: () => Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(flex: 11, child: _Gorsel(h, buyuk: true)),
        Expanded(
          flex: 9,
          child: ClipRect(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _Kunye(h, baslikAdi: true),
                const SizedBox(height: 8),
                Text(_baslikMetni(h, en),
                    maxLines: 3, overflow: TextOverflow.ellipsis, style: YzYazi.baslik(21).copyWith(height: 1.25)),
                if (ozet != null) ...[
                  const SizedBox(height: 8),
                  Text(ozet,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: YzYazi.govde(boy: 15, renk: YzRenk.soluk).copyWith(height: 1.45)),
                ],
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

/// Manşetin yanındaki haber: solda küçük görsel, sağda künye ve başlık.
class _Yan extends StatelessWidget {
  const _Yan(this.h, {required this.kur});
  final YzHaber h;
  final bool kur;

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    return _Kabuk(
      h: h,
      kur: kur,
      cocuk: () => Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(width: 136, child: _Gorsel(h, buyuk: false)),
        Expanded(
          child: ClipRect(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Kunye(h, baslikAdi: true),
                    const SizedBox(height: 5),
                    Text(_baslikMetni(h, en),
                        maxLines: 3, overflow: TextOverflow.ellipsis, style: YzYazi.baslik(16).copyWith(height: 1.28)),
                  ]),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Haber bloğu: sorgu ve kurulum zamanlaması (madde 29) ─────────────────

/// Okur haber bloğuna bu kadar yaklaşmadan kartlar kurulmuyor (piksel).
const double kYzHaberKurmaMesafesi = 1250;

/// Haber sorgusu metnin ilk karesinden bu kadar sonra başlıyor.
const Duration kYzHaberSorguGecikmesi = Duration(milliseconds: 1500);

/// Haberler: sorgu metnin yüklenmesiyle yarışmasın, görseller okur
/// yaklaşmadan inmesin. Haber sorgusu ilk kareden ~1,5 s sonra ya da okur
/// sayfanın yarısına gelince başlıyor; okur bloğa ~1.250 px yaklaşınca
/// kartlar kuruluyor, o zamana kadar aynı boyda durağan çerçeveler.
///
/// Haber yoksa, yüklenirken ya da sorgu hata verirse hiçbir şey çizilmiyor
/// ([ust] de: boşluk, çizgi, etiket). Liste RepaintBoundary içinde.
class YzHaberBlogu extends ConsumerStatefulWidget {
  const YzHaberBlogu({super.key, this.baslikNo, this.ust = const [], this.olcumSayfasi});

  /// null: bütün bölüm (merkez sayfa); sayı: o başlığın haberleri.
  final int? baslikNo;

  /// Haber varsa listenin üstünde çizilenler (boşluk, çizgi, etiket).
  final List<Widget> ust;

  /// Habere dokunulunca `yz_haber` ölçümüne giden sayfa.
  final String? olcumSayfasi;

  @override
  ConsumerState<YzHaberBlogu> createState() => _YzHaberBloguState();
}

class _YzHaberBloguState extends ConsumerState<YzHaberBlogu> {
  bool _sorgu = false;
  bool _yakin = false;
  Timer? _zamanlayici;
  ScrollPosition? _konum;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _zamanlayici = Timer(kYzHaberSorguGecikmesi, () {
        if (mounted && !_sorgu) setState(() => _sorgu = true);
      });
      _denetle();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final yeni = Scrollable.maybeOf(context)?.position;
    if (!identical(yeni, _konum)) {
      _konum?.removeListener(_denetle);
      _konum = yeni;
      _konum?.addListener(_denetle);
    }
  }

  @override
  void dispose() {
    _zamanlayici?.cancel();
    _konum?.removeListener(_denetle);
    super.dispose();
  }

  void _denetle() {
    if (!mounted || (_sorgu && _yakin)) return;
    final ro = context.findRenderObject();
    if (ro is! RenderBox || !ro.attached || !ro.hasSize) return;
    final konum = _konum;
    final vp = RenderAbstractViewport.maybeOf(ro);
    var kalan = 0.0;
    var oran = 1.0;
    if (konum != null && vp != null && konum.hasContentDimensions && konum.hasPixels) {
      // Bloğun üst kenarının kaydırma içindeki yeri ≈ metnin sonu.
      final ust = vp.getOffsetToReveal(ro, 0).offset;
      final gorulen = konum.pixels + konum.viewportDimension;
      kalan = ust - gorulen;
      oran = ust <= 0 ? 1 : gorulen / ust;
    }
    final yakin = kalan < kYzHaberKurmaMesafesi;
    final sorgu = yakin || oran >= 0.5;
    if ((yakin && !_yakin) || (sorgu && !_sorgu)) {
      setState(() {
        _yakin = _yakin || yakin;
        _sorgu = _sorgu || sorgu;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const hicbiri = SizedBox(width: double.infinity);
    if (!_sorgu) return hicbiri;
    final liste = ref.watch(yzBolumHaberleriProvider(widget.baslikNo)).valueOrNull ?? const <YzHaber>[];
    if (liste.isEmpty) return hicbiri;
    return RepaintBoundary(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ...widget.ust,
        YzHaberVitrini(
          haberler: liste,
          merkez: widget.baslikNo == null,
          kur: _yakin,
          olcumSayfasi: widget.olcumSayfasi,
        ),
      ]),
    );
  }
}
