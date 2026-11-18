import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/turkce_metin.dart' show buyukHarf, etiketSlug;
import '../data/yz_iskelet.g.dart';
import 'yz_cerceve_mobil.dart';
import 'yz_metin_gorunumu.dart';
import 'yz_mobil.dart';
import 'yz_okuma.dart';
import 'yz_parcalar.dart';
import 'yz_tasarim.dart';
import 'yz_teknoloji_izi.dart';

/// Başlık ve teknoloji sayfalarının ortak iskeleti (okuma deneyimi turu,
/// karar 60).
///
///   · Metin sütunu ~610 piksel (satır 70-75 harf); grafik, görsel ve tablo
///     760 piksel sütunun tamamında.
///   · İçindekiler: geniş ekranda (≥1100 px) solda sabit duran ray, okunan
///     bölüm vurgulu; telefonda tek satıra katlanan liste; dar ve orta
///     ekranda kaydırınca beliren "İçindekiler / Başa dön" düğmesi.
///   · Okur bir terimin balonundan sözlüğe gidip dönünce sayfa kaldığı
///     yerden açılıyor (`YzOkumaKonumu`).
///   · İşaret: merkez sayfadan seçilen teknoloji (karar 57), bölüm içi arama
///     ya da sözlükte açılan terim; şerit kaç yerde geçtiğini söylüyor,
///     "Sonraki ↓" sırayla geziyor.
///   · Telefonda (< 640 px, karar 62) çerçeve ayrı: kısa künye, alt çubuk
///     (içindekiler, yazı boyu, arama, paylaş), kaydırınca saklanan üst ve
///     alt çubuk, okuma çizgisi; ipucu ve işaret şeridi alt çubuğun üstünde
///     (`yz_cerceve_mobil.dart`). Masaüstü ve tablet düzeni değişmedi.
class YzMakaleSayfasi extends ConsumerStatefulWidget {
  const YzMakaleSayfasi({
    super.key,
    required this.konumAnahtari,
    required this.yol,
    required this.geriAdres,
    required this.ustEtiket,
    required this.baslik,
    required this.metin,
    required this.en,
    this.cipler = const [],
    this.guncellendi,
    this.sozluk = true,
    this.bolumNo,
    this.kaynakSayfasi,
    this.teknoloji,
    this.arama,
    this.odakTerim,
    this.isaretiKaldir,
    this.bolum,
    this.altlar = const [],
  });

  /// Kaydırma konumunun saklandığı ad (başlığın adresi).
  final String konumAnahtari;

  /// Sayfanın adresi: okuma izi (karar 60) ve bölüm bağlantısı bunu kullanıyor.
  final String yol;

  /// Açılışta kaydırılacak alt başlık (`?bolum=`, karar 60).
  final String? bolum;

  /// Yazdırılabilir sürümün dosya adı (`/yz/yazdir/<ad>.<dil>.html`): başlıkta
  /// adresi, teknoloji sayfasında `teknoloji-<kod>`.
  String get yazdirAdi => konumAnahtari;
  final String geriAdres;
  final String ustEtiket;
  final String baslik;

  /// Sayfanın metni (Markdown kesiti); yoksa yalnız başlık ve altlar.
  final String? metin;
  final bool en;
  final List<Widget> cipler;
  final String? guncellendi;
  final bool sozluk;
  final int? bolumNo;
  final String? kaynakSayfasi;

  /// Merkez sayfada seçilen teknoloji (karar 57).
  final String? teknoloji;

  /// Bölüm içi aramanın sorgusu (karar 60).
  final String? arama;

  /// Sözlük sayfasında açılan terim (karar 60).
  final String? odakTerim;

  /// İşareti (teknoloji ya da arama) kaldıran: adresi parametresiz açar.
  final VoidCallback? isaretiKaldir;

  /// Metnin ardından gelenler: haberler, komşu başlıklar, kesişimler.
  final List<Widget> altlar;

  @override
  ConsumerState<YzMakaleSayfasi> createState() => _YzMakaleSayfasiState();
}

/// Rayın genişliği ve sütunla arası (geniş ekran).
const double _rayGenisligi = 220;
const double _rayAraligi = 24;
const double _sutunGenisligi = 760;
const double _rayEsigi = 1100;

class _YzMakaleSayfasiState extends ConsumerState<YzMakaleSayfasi> {
  final _kaydirma = ScrollController();

  /// Kaydırılan sütunun kimliği: telefon ile geniş düzen arasında geçişte
  /// (telefonu yan çevirmek, pencereyi 640 pikselin ötesine açmak) kaydırıcı
  /// yeniden kurulmasın, okur kaldığı yerde kalsın (karar 62).
  final _kaydiriciAnahtari = GlobalKey(debugLabel: 'yz-makale-kaydirici');
  final _vurgu = YzVurguDenetcisi();
  int _aktif = 0;
  bool _dugme = false;

  // Telefon çerçevesi (karar 62). Kaydırırken değişenler ayrı dinleyicide:
  // çubuklar saklanıp göründükçe bütün sayfa (metin) yeniden kurulmasın.
  /// Okurun geçtiği son alt başlık; ilkine varılmadıysa -1.
  final _gecilen = ValueNotifier<int>(-1);

  /// Üst ve alt çubuk saklı mı (aşağı kaydırınca saklanıyor).
  final _gizli = ValueNotifier<bool>(false);
  double _sonKonum = 0;

  /// Aynı yönde biriken kaydırma: yavaş kaydırmada da çubuklar saklanıp
  /// gelsin (tek karedeki fark birkaç pikseli geçmiyor).
  double _birikim = 0;
  static const double _gizlemeEsigi = 16;

  // Ayrıştırma ve sayım her kurulumda yinelenmesin.
  String? _bellekMetin;
  List<String> _bellekBasliklar = const [];
  Object? _isaretAnahtari;
  _Isaret? _isaretBellegi;

  /// Sayfanın okunan oranı (okuma çizgisi); her kaydırmada bütün sayfa
  /// yeniden çizilmesin diye ayrı.
  final _ilerleme = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _kaydirma.addListener(_kaydirildi);
    WidgetsBinding.instance.addPostFrameCallback((_) => _ilkKonum());
  }

  @override
  void didUpdateWidget(covariant YzMakaleSayfasi eski) {
    super.didUpdateWidget(eski);
    if ((eski.arama != widget.arama && widget.arama != null) ||
        (eski.odakTerim != widget.odakTerim && widget.odakTerim != null)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _vurgu.sonraki();
      });
    }
  }

  void _ilkKonum() {
    if (!mounted || !_kaydirma.hasClients) return;
    final k = YzOkumaKonumu.alHepsi(widget.konumAnahtari);
    final enCok = _kaydirma.position.maxScrollExtent;
    if (k != null && (k.$1 != null || k.$2 != null)) {
      _kaydirma.jumpTo(math.min(k.$1 ?? (k.$2! * enCok), enCok));
      return;
    }
    // Alt başlığın adresiyle gelindiyse (`?bolum=`) o bölüme.
    final bolum = widget.bolum;
    if (bolum != null && widget.metin != null) {
      final basliklar = [
        for (final x in yzAyristir(widget.metin!)) if (x.tur == YzBlokTuru.altBaslik) x.metin,
      ];
      final i = basliklar.indexWhere((b) => etiketSlug(b) == bolum);
      if (i >= 0) {
        // Telefonda üst çubuk alt başlığı örtmesin (karar 62).
        if (yzTelefon(context)) {
          _telefondaBasligaGit(i);
        } else {
          _vurgu.basligaGit(i);
        }
        return;
      }
    }
    // Aramadan ya da sözlük balonundan gelindiyse ilk işaretli yere.
    if (widget.arama != null || widget.odakTerim != null) _vurgu.sonraki();
  }

  void _kaydirildi() {
    if (!_kaydirma.hasClients) return;
    // Okuma izi (karar 60): sayfanın ne kadarının geçildiği.
    final enCok = _kaydirma.position.maxScrollExtent;
    if (enCok > 0 && widget.metin != null) {
      ref.read(yzOkumaIziProvider.notifier).ilerle(widget.yol, widget.baslik, _kaydirma.offset / enCok);
    }
    final dugme = _kaydirma.offset > 480;
    var gecilen = -1;
    final anahtarlar = _vurgu.basliklar;
    for (var i = 0; i < anahtarlar.length; i++) {
      final ro = anahtarlar[i].currentContext?.findRenderObject();
      if (ro is! RenderBox || !ro.attached) continue;
      if (ro.localToGlobal(Offset.zero).dy <= 170) {
        gecilen = i;
      } else {
        break;
      }
    }
    final aktif = math.max(0, gecilen);
    if (yzTelefon(context)) {
      // Telefonda ray ve yüzen düğme yok: sayfa yeniden kurulmuyor, yalnız
      // çubuklar ve okuma çizgisi dinleyicilerinden güncelleniyor.
      _dugme = dugme;
      _aktif = aktif;
      final p = _kaydirma.position;
      _ilerleme.value = enCok > 0 ? (p.pixels / enCok).clamp(0.0, 1.0) : 0.0;
      _gecilen.value = gecilen;
      final fark = p.pixels - _sonKonum;
      _sonKonum = p.pixels;
      if (p.pixels <= kYzUstSeritYuksekligi || p.pixels >= enCok - 24) {
        // En üstte ve sayfanın sonunda çubuklar hep görünür.
        _birikim = 0;
        _gizli.value = false;
      } else if (fark != 0) {
        // Yön değişince birikim sıfırdan başlıyor.
        if (_birikim != 0 && fark.sign != _birikim.sign) _birikim = 0;
        _birikim += fark;
        if (p.userScrollDirection == ScrollDirection.reverse && _birikim > _gizlemeEsigi) {
          _gizli.value = true;
        } else if (p.userScrollDirection == ScrollDirection.forward && _birikim < -_gizlemeEsigi) {
          _gizli.value = false;
        }
      }
      return;
    }
    if (dugme != _dugme || aktif != _aktif) {
      setState(() {
        _dugme = dugme;
        _aktif = aktif;
      });
    }
  }

  void _basaDon() {
    if (_kaydirma.hasClients) {
      _kaydirma.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
    }
  }

  @override
  void dispose() {
    _kaydirma.dispose();
    _ilerleme.dispose();
    _gecilen.dispose();
    _gizli.dispose();
    super.dispose();
  }

  /// Yazdırılabilir sürüm (karar 60): tuvale çizilen sayfa düzgün basılamıyor;
  /// duru HTML sayfası yazdırılıyor ya da PDF olarak kaydediliyor
  /// (`_raw/yazdir_uret.py`).
  void _yazdir() => launchUrl(
      Uri.parse('/yz/yazdir/${widget.yazdirAdi}.${widget.en ? 'en' : 'tr'}.html'),
      webOnlyWindowName: '_blank');

  /// Sayfanın paylaşılan adresi (telefondaki Paylaş).
  String get _adres => 'https://tarimportali.net${widget.yol}';

  Future<void> _baglantiyiPaylas() async {
    try {
      final sonuc = await SharePlus.instance.share(ShareParams(
        uri: Uri.parse(_adres),
        title: widget.baslik,
        subject: widget.baslik,
        // Web'de paylaşma yoksa e-posta açılmasın; bağlantı panoya.
        mailToFallbackEnabled: false,
      ));
      if (sonuc.status == ShareResultStatus.unavailable) _baglantiyiKopyala();
    } catch (_) {
      // Tarayıcı paylaşmayı desteklemiyorsa bağlantı panoya.
      _baglantiyiKopyala();
    }
  }

  void _baglantiyiKopyala() {
    Clipboard.setData(ClipboardData(text: _adres));
    if (!mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
      content: Text(widget.en ? 'Link copied' : 'Bağlantı kopyalandı'),
      behavior: SnackBarBehavior.floating,
      // Alt çubuğun üstünde.
      margin: EdgeInsets.fromLTRB(
          16, 0, 16, kYzAltCubukYuksekligi + MediaQuery.paddingOf(context).bottom + 8),
      duration: const Duration(seconds: 2),
    ));
  }

  /// Alt başlığın adresini panoya kopyalar (karar 60).
  void _bolumBaglantisi(String altBaslik) {
    final b = Uri.base;
    final kok = (b.scheme == 'http' || b.scheme == 'https') ? b.origin : 'https://tarimportali.net';
    final adres = Uri.parse(kok)
        .replace(path: widget.yol, queryParameters: {'bolum': etiketSlug(altBaslik)})
        .toString();
    Clipboard.setData(ClipboardData(text: adres));
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
      content: Text(widget.en ? 'Link to this section copied' : 'Bölümün bağlantısı kopyalandı'),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
  }

  /// Yazı boyu değişince okunan yer kaymasın: kaydırma, sayfadaki oranıyla
  /// korunuyor (metin uzayınca piksel konumu başka bir paragrafa düşerdi).
  void _olcekDegisti(double? eski, double yeni) {
    if (eski == null || eski == yeni || !_kaydirma.hasClients) return;
    final p = _kaydirma.position;
    if (p.maxScrollExtent <= 0) return;
    final oran = p.pixels / p.maxScrollExtent;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_kaydirma.hasClients) return;
      final q = _kaydirma.position;
      _kaydirma.jumpTo((oran * q.maxScrollExtent).clamp(0.0, q.maxScrollExtent));
    });
  }

  /// Telefonda içindekilerden bir bölüme gidiş: üst çubuk başlığı örtmesin
  /// diye çubuklar saklanıyor (kaydırma okurun değil, kendiliğinden).
  void _telefondaBasligaGit(int i) {
    _birikim = 0;
    _gizli.value = true;
    _vurgu.basligaGit(i);
  }

  List<String> _altBasliklar(String? md) {
    if (md == null) return const [];
    if (!identical(md, _bellekMetin)) {
      _bellekMetin = md;
      _bellekBasliklar = [for (final x in yzAyristir(md)) if (x.tur == YzBlokTuru.altBaslik) x.metin];
    }
    return _bellekBasliklar;
  }

  void _icindekileriAc(BuildContext context, bool en, List<String> altBasliklar) =>
      yzCerceveIcindekiler(
        context,
        en: en,
        basliklar: altBasliklar,
        aktif: _gecilen.value,
        git: _telefondaBasligaGit,
        basaDon: _basaDon,
      );

  @override
  Widget build(BuildContext context) {
    final en = widget.en;
    ref.listen<double>(yzYaziOlcegiProvider, _olcekDegisti);
    final olcek = ref.watch(yzYaziOlcegiProvider);
    final md = widget.metin;
    final altBasliklar = _altBasliklar(md);
    final telefon = yzTelefon(context);
    final isaretAnahtari = (md, widget.teknoloji, widget.arama, en);
    if (isaretAnahtari != _isaretAnahtari) {
      _isaretAnahtari = isaretAnahtari;
      _isaretBellegi = _isaret(md, en);
    }
    final isaret = _isaretBellegi;
    final ipucu = md != null && ref.watch(yzIpucuProvider) == false;

    Widget icerik(BuildContext context, BoxConstraints kis) {
      final g = kis.maxWidth;
      final dar = g < 640;
      final rayli = g >= _rayEsigi && altBasliklar.length >= 3;
      final yan = dar ? 16.0 : 32.0;
      final ic = math.min(g, _sutunGenisligi) - 2 * yan;
      final ust = math.min(ic, kYzMetinGenisligi);

      Widget ortala(Widget w) => Center(child: SizedBox(width: ust, child: w));

      // Telefonda üst çubuk metnin üstünde yüzüyor, alt çubuk ve işaret
      // çubuğu altta: metnin başı ve sonu onların altında kalmasın.
      final ustBosluk = telefon ? kYzUstSeritYuksekligi + 16 : (dar ? 24.0 : 44.0);
      final altBosluk = telefon
          ? 72 +
              kYzAltCubukYuksekligi +
              MediaQuery.paddingOf(context).bottom +
              (isaret != null ? YzCerceveIsaretCubugu.yukseklik + 8 : 0)
          : 72.0;

      final sutun = ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _sutunGenisligi),
        child: Padding(
          padding: EdgeInsets.fromLTRB(yan, ustBosluk, yan, altBosluk),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ortala(_baslikBlogu(dar, en, md, telefon)),
              if (!telefon && ipucu)
                ortala(_Ipucu(en: en, kapat: ref.read(yzIpucuProvider.notifier).kapat)),
              if (!telefon && !rayli && altBasliklar.length >= 3)
                ortala(_Icindekiler(
                  basliklar: altBasliklar,
                  en: en,
                  daralt: dar,
                  git: _vurgu.basligaGit,
                )),
              if (!telefon && isaret != null)
                ortala(Padding(
                    padding: const EdgeInsets.only(bottom: 18), child: _isaretSeridi(isaret, en))),
              if (md != null)
                YzMetinGorunumu(
                  metin: md,
                  en: en,
                  sozluk: widget.sozluk,
                  bolumNo: widget.bolumNo,
                  vurgu: widget.teknoloji,
                  arama: widget.arama,
                  odakTerim: widget.odakTerim,
                  vurguDenetcisi: _vurgu,
                  kaynakSayfasi: widget.kaynakSayfasi,
                  olcek: olcek,
                  // Telefonda alt başlıkların bağlantı simgesi yok:
                  // paylaşmak alt çubuktaki Paylaş'tan.
                  bolumBaglantisi: telefon ? null : _bolumBaglantisi,
                ),
              ...widget.altlar,
            ],
          ),
        ),
      );
      final govde = rayli
          ? Center(
              child: SizedBox(
                width: _rayGenisligi + _rayAraligi + _sutunGenisligi,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: _rayGenisligi + _rayAraligi),
                    SizedBox(width: _sutunGenisligi, child: sutun),
                  ],
                ),
              ),
            )
          : Center(child: sutun);
      return Stack(children: [
        Positioned.fill(
          child: SingleChildScrollView(key: _kaydiriciAnahtari, controller: _kaydirma, child: govde),
        ),
        if (rayli)
          Positioned(
            left: (g - (_rayGenisligi + _rayAraligi + _sutunGenisligi)) / 2,
            top: 0,
            bottom: 0,
            width: _rayGenisligi,
            child: _Ray(
              basliklar: altBasliklar,
              aktif: _aktif,
              en: en,
              git: _vurgu.basligaGit,
              basaDon: _basaDon,
            ),
          ),
        if (!telefon && !rayli && _dugme)
          Positioned(
            right: 16,
            bottom: 16,
            child: _YuzenDugme(
              basliklar: altBasliklar.length >= 3 ? altBasliklar : const [],
              en: en,
              git: _vurgu.basligaGit,
              basaDon: _basaDon,
            ),
          ),
      ]);
    }

    if (!telefon) {
      return Scaffold(
        backgroundColor: YzRenk.zemin,
        body: Column(children: [
          YzUstSerit(geriAdres: widget.geriAdres),
          Expanded(child: LayoutBuilder(builder: icerik)),
        ]),
      );
    }

    // ── Telefon çerçevesi (karar 62) ──
    const sure = Duration(milliseconds: 200);
    final altGuvenli = MediaQuery.paddingOf(context).bottom;
    final yonlendirici = GoRouter.maybeOf(context);
    Widget gizliyle(Widget Function(bool gizli) kur) =>
        ValueListenableBuilder<bool>(valueListenable: _gizli, builder: (_, g, __) => kur(g));
    return Scaffold(
      backgroundColor: YzRenk.zemin,
      body: Stack(children: [
        Positioned.fill(child: LayoutBuilder(builder: icerik)),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: gizliyle((gizli) => AnimatedSlide(
                offset: gizli ? const Offset(0, -1) : Offset.zero,
                duration: sure,
                curve: Curves.easeOut,
                child: ValueListenableBuilder<int>(
                  valueListenable: _gecilen,
                  builder: (context, gecilen, _) {
                    final okunan = gecilen >= 0 && gecilen < altBasliklar.length
                        ? altBasliklar[gecilen]
                        : null;
                    return YzUstSerit(
                      geriAdres: widget.geriAdres,
                      aramaDugmesi: false,
                      yaziBoyuDugmesi: false,
                      altBaslik: okunan,
                      // Okunan alt başlığa dokunan okur sayfadan çıkmasın:
                      // içindekiler açılıyor.
                      etiketeDokununca:
                          okunan == null ? null : () => _icindekileriAc(context, en, altBasliklar),
                    );
                  },
                ),
              )),
        ),
        // Okuma çizgisi: üst çubuk saklanınca ekranın en üstünde kalıyor.
        gizliyle((gizli) => AnimatedPositioned(
              duration: sure,
              curve: Curves.easeOut,
              top: gizli ? 0 : kYzUstSeritYuksekligi,
              left: 0,
              right: 0,
              height: 2,
              child: YzCerceveIlerleme(oran: _ilerleme, en: en),
            )),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: gizliyle((gizli) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // İpucu ve işaret çubuğu alt çubuğun üstünde; alt çubuk
                  // saklanınca alt güvenli alanın üstüne iniyorlar.
                  AnimatedPadding(
                    duration: sure,
                    curve: Curves.easeOut,
                    padding: EdgeInsets.only(bottom: gizli ? altGuvenli : 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (ipucu)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                            child: YzCerceveIpucu(en: en, kapat: ref.read(yzIpucuProvider.notifier).kapat),
                          ),
                        if (isaret != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                            child: YzCerceveIsaretCubugu(
                              ad: isaret.ad,
                              sayi: isaret.sayi,
                              en: en,
                              kalem: isaret.kalem,
                              sonraki: _vurgu.sonraki,
                              kapat: widget.isaretiKaldir,
                            ),
                          ),
                      ],
                    ),
                  ),
                  ClipRect(
                    child: AnimatedAlign(
                      duration: sure,
                      curve: Curves.easeOut,
                      alignment: Alignment.topCenter,
                      heightFactor: gizli ? 0 : 1,
                      child: YzCerceveAltCubuk(
                        en: en,
                        icindekiler: () => _icindekileriAc(context, en, altBasliklar),
                        yaziBoyu: () => yzCerceveYaziBoyu(context, en: en),
                        ara: yonlendirici == null ? null : () => context.push(yzAramaPath),
                        paylas: () => yzCercevePaylas(
                          context,
                          en: en,
                          paylas: _baglantiyiPaylas,
                          kopyala: _baglantiyiKopyala,
                          yazdir: md == null ? null : _yazdir,
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ]),
    );
  }

  Widget _baslikBlogu(bool dar, bool en, String? md, bool telefon) {
    final sure = md == null ? null : yzOkumaSuresiYazisi(md, en);
    final tarih = widget.guncellendi == null
        ? null
        : (en
            ? 'Last checked against its sources: ${yzTarih(widget.guncellendi!, true)}'
            : 'Kaynaklarından son okunduğu gün: ${yzTarih(widget.guncellendi!, false)}');
    final satir = [if (sure != null) sure, if (tarih != null) tarih].join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(buyukHarf(widget.ustEtiket, en), style: YzYazi.ustEtiket(renk: YzRenk.makine)),
        SizedBox(height: telefon ? 8 : 10),
        // Telefonda başlık bir kademe küçük: uzun başlık üç satıra inmesin,
        // metin ilk ekranın üçte birinde başlasın (karar 62).
        Semantics(
          header: true,
          child: Text(widget.baslik, style: YzYazi.baslik(telefon ? 27 : (dar ? 30 : 40))),
        ),
        if (widget.cipler.isNotEmpty) ...[
          SizedBox(height: telefon ? 10 : 14),
          // Telefonda çipler tek satırda yana kayıyor: metin ilk ekrana sığsın.
          // Satır taşıyorsa sağ kenarda solma (karar 62).
          telefon
              ? YzCerceveCipSirasi(cipler: widget.cipler)
              : dar
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        for (final c in widget.cipler)
                          Padding(padding: const EdgeInsets.only(right: 6), child: c),
                      ]),
                    )
                  : Wrap(spacing: 6, runSpacing: 6, children: widget.cipler),
        ],
        // Telefonda künye tek satır ve kısa; yazdırma Paylaş'ta (karar 62).
        if (telefon && satir.isNotEmpty) ...[
          const SizedBox(height: 8),
          YzCerceveKunye(yzKisaKunye(
            dakika: md == null ? null : yzOkumaSuresi(md, en),
            guncellendi: widget.guncellendi,
            en: en,
          )),
        ],
        if (!telefon && satir.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 0,
            children: [
              Text(satir, style: YzYazi.veri(boy: 12.5, renk: YzRenk.soluk)),
              // Yazdırılabilir sürüm (karar 60): tuvale çizilen sayfa düzgün
              // basılamıyor; duru HTML sayfası yazdırılıyor ya da PDF olarak
              // kaydediliyor (`_raw/yazdir_uret.py`).
              if (md != null)
                TextButton.icon(
                  onPressed: _yazdir,
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      visualDensity: VisualDensity.compact),
                  icon: const Icon(Icons.print_outlined, size: 16, color: YzRenk.makine),
                  label: Text(en ? 'Print / PDF' : 'Yazdır / PDF',
                      style: YzYazi.veri(boy: 12.5, renk: YzRenk.makine)),
                ),
            ],
          ),
        ],
        SizedBox(height: telefon ? 16 : (dar ? 20 : 26)),
      ],
    );
  }

  /// Teknoloji ya da arama işaretinin bilgisi; yoksa null.
  _Isaret? _isaret(String? md, bool en) {
    if (md == null) return null;
    final kod = widget.teknoloji;
    if (kod != null && kYzTeknoloji.containsKey(kod)) {
      final ad = kYzTeknoloji[kod]?[en ? 'en' : 'tr'] ?? kod;
      return (
        ad: ad,
        sayi: yzTeknolojiSay(md, kod, en),
        kalem: kYzKalemRengi,
      );
    }
    final q = widget.arama?.trim();
    if (q != null && q.isNotEmpty) {
      return (
        ad: '“$q”',
        sayi: yzAramaSay(md, yzAramaKelimeleri(q, en), en),
        kalem: kYzAramaRengi,
      );
    }
    return null;
  }

  /// Masaüstü ve tablette metnin üstündeki işaret şeridi (değişmedi).
  Widget _isaretSeridi(_Isaret i, bool en) {
    final ad = i.ad;
    final sayi = i.sayi;
    return _IsaretSeridi(
      metin: sayi == 0
          ? (en ? '$ad does not come up on this page.' : '$ad bu sayfada geçmiyor.')
          : (en
              ? '$ad comes up in $sayi places on this page; they are marked.'
              : '$ad bu sayfada $sayi yerde geçiyor; geçtiği yerler işaretli.'),
      sayi: sayi,
      en: en,
      sonraki: _vurgu.sonraki,
      kalem: i.kalem,
      kapat: widget.isaretiKaldir,
    );
  }
}

/// İşaretin bilgisi: ad (teknoloji adı ya da tırnaklı sorgu), kaç yerde
/// geçtiği ve fosforlu kalemin rengi.
typedef _Isaret = ({String ad, int sayi, Color kalem});

/// Seçili teknolojinin ya da aramanın bu sayfadaki izi: kaç yerde geçtiği,
/// sıradaki işaretli yere gitme ve işareti kaldırma.
class _IsaretSeridi extends StatelessWidget {
  const _IsaretSeridi(
      {required this.metin,
      required this.sayi,
      required this.en,
      required this.sonraki,
      required this.kalem,
      this.kapat});
  final String metin;
  final int sayi;
  final bool en;
  final VoidCallback sonraki;

  /// Metindeki fosforlu kalemin rengi: şeritteki küçük örnek okura işaretin
  /// neye benzediğini gösteriyor. Sol çizgi yok (karar 60).
  final Color kalem;
  final VoidCallback? kapat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 4, 6),
      decoration: BoxDecoration(
        color: YzRenk.yuzey,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: YzRenk.cizgi),
      ),
      child: Row(children: [
        Container(
          width: 22,
          height: 12,
          decoration: BoxDecoration(color: kalem, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(metin, style: YzYazi.govde(boy: 15))),
        if (sayi > 0)
          TextButton(
            onPressed: sonraki,
            child: Text(en ? 'Next ↓' : 'Sonraki ↓', style: YzYazi.veri(boy: 13, renk: YzRenk.makine)),
          ),
        if (kapat != null)
          IconButton(
            tooltip: en ? 'Remove marking' : 'İşareti kaldır',
            icon: const Icon(Icons.close_rounded, size: 18, color: YzRenk.makine),
            onPressed: kapat,
          ),
      ]),
    );
  }
}

/// Bir kez gösterilen ipucu (karar 60): rakamlardaki noktalı çizgi kalktı;
/// okura mavi rakamın ve altı noktalı terimin dokunulabildiği söyleniyor.
class _Ipucu extends StatelessWidget {
  const _Ipucu({required this.en, required this.kapat});
  final bool en;
  final VoidCallback kapat;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
        decoration: BoxDecoration(
          color: YzRenk.bitkiAcik,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const Icon(Icons.touch_app_outlined, size: 20, color: YzRenk.bitki),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              en
                  ? 'Tap a blue figure to see its source; tap a term or abbreviation with a dotted underline to see what it means.'
                  : 'Mavi rakamlara dokunun, kaynağı açılır. Altı noktalı terim ve kısaltmalara dokunun, ne demek olduğu açılır.',
              style: YzYazi.govde(boy: 14.5).copyWith(height: 1.4),
            ),
          ),
          TextButton(
            onPressed: kapat,
            child: Text(en ? 'Got it' : 'Anladım',
                style: YzYazi.veri(boy: 12.5, renk: YzRenk.bitki, kalinlik: FontWeight.w700)),
          ),
        ]),
      ),
    );
  }
}

/// Metnin üstündeki içindekiler (rayın olmadığı ekranlar). Telefonda tek
/// satıra katlanıyor; dokununca açılıyor. Alt başlığa dokununca o bölüme
/// kaydırıyor.
class _Icindekiler extends StatefulWidget {
  const _Icindekiler(
      {required this.basliklar, required this.en, required this.daralt, required this.git});
  final List<String> basliklar;
  final bool en;
  final bool daralt;
  final void Function(int) git;

  @override
  State<_Icindekiler> createState() => _IcindekilerState();
}

class _IcindekilerState extends State<_Icindekiler> {
  bool _acik = false;

  @override
  Widget build(BuildContext context) {
    final en = widget.en;
    final acik = !widget.daralt || _acik;
    final baslik = widget.daralt
        ? '${buyukHarf(en ? 'Contents' : 'İçindekiler', en)} · ${widget.basliklar.length} ${buyukHarf(en ? 'sections' : 'bölüm', en)}'
        : buyukHarf(en ? 'Contents' : 'İçindekiler', en);
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      // Sol çizgi yok (kullanıcı, 18 Kas 2026): beyaz, yuvarlak köşeli kart.
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 4, 10, 4),
        decoration: BoxDecoration(
          color: YzRenk.yuzey,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: YzRenk.cizgi),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.daralt)
              Semantics(
                button: true,
                expanded: _acik,
                child: InkWell(
                  onTap: () => setState(() => _acik = !_acik),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(children: [
                      Expanded(child: Text(baslik, style: YzYazi.ustEtiket())),
                      Icon(_acik ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                          size: 20, color: YzRenk.soluk),
                    ]),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 2),
                child: Text(baslik, style: YzYazi.ustEtiket()),
              ),
            if (acik)
              for (var i = 0; i < widget.basliklar.length; i++)
                InkWell(
                  onTap: () => widget.git(i),
                  child: Padding(
                    // Dokunma yüksekliği ~44 px (karar 60).
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(widget.basliklar[i],
                        style: YzYazi.govde(boy: 15, renk: YzRenk.makine).copyWith(height: 1.35)),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

/// Geniş ekranda solda sabit duran içindekiler; okunan bölüm vurgulu.
class _Ray extends StatelessWidget {
  const _Ray(
      {required this.basliklar,
      required this.aktif,
      required this.en,
      required this.git,
      required this.basaDon});
  final List<String> basliklar;
  final int aktif;
  final bool en;
  final void Function(int) git;
  final VoidCallback basaDon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(buyukHarf(en ? 'Contents' : 'İçindekiler', en), style: YzYazi.ustEtiket()),
          const SizedBox(height: 10),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < basliklar.length; i++)
                    Semantics(
                      button: true,
                      selected: i == aktif,
                      child: InkWell(
                        onTap: () => git(i),
                        borderRadius: BorderRadius.circular(6),
                        // Okunan bölüm yumuşak zeminle; sol çizgi yok.
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
                          decoration: BoxDecoration(
                            color: i == aktif ? YzRenk.makineAcik : null,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            basliklar[i],
                            style: YzYazi.govde(
                                    boy: 14.5, renk: i == aktif ? YzRenk.makine : YzRenk.soluk)
                                .copyWith(
                                    height: 1.35,
                                    fontWeight: i == aktif ? FontWeight.w600 : FontWeight.w400),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: basaDon,
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
            icon: const Icon(Icons.arrow_upward_rounded, size: 16, color: YzRenk.makine),
            label: Text(en ? 'Back to top' : 'Başa dön',
                style: YzYazi.veri(boy: 12.5, renk: YzRenk.makine)),
          ),
        ],
      ),
    );
  }
}

/// Rayın olmadığı ekranlarda kaydırınca beliren düğme: içindekiler ve başa
/// dönüş bir dokunuşta.
class _YuzenDugme extends StatelessWidget {
  const _YuzenDugme(
      {required this.basliklar, required this.en, required this.git, required this.basaDon});
  final List<String> basliklar;
  final bool en;
  final void Function(int) git;
  final VoidCallback basaDon;

  void _ac(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: YzRenk.yuzey,
      showDragHandle: true,
      isScrollControlled: true,
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
      builder: (c) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          children: [
            Text(buyukHarf(en ? 'Contents' : 'İçindekiler', en), style: YzYazi.ustEtiket()),
            const SizedBox(height: 6),
            for (var i = 0; i < basliklar.length; i++)
              InkWell(
                onTap: () {
                  Navigator.of(c).pop();
                  git(i);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  child: Text(basliklar[i],
                      style: YzYazi.govde(boy: 16, renk: YzRenk.makine).copyWith(height: 1.35)),
                ),
              ),
            const Divider(color: YzRenk.cizgi),
            InkWell(
              onTap: () {
                Navigator.of(c).pop();
                basaDon();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 11),
                child: Text(en ? '↑ Back to top' : '↑ Başa dön',
                    style: YzYazi.veri(boy: 13.5, renk: YzRenk.makine)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final icindekiler = basliklar.isNotEmpty;
    return Semantics(
      button: true,
      label: icindekiler ? (en ? 'Contents' : 'İçindekiler') : (en ? 'Back to top' : 'Başa dön'),
      child: Material(
        color: YzRenk.makine,
        elevation: 3,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: icindekiler ? () => _ac(context) : basaDon,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icindekiler ? Icons.format_list_bulleted_rounded : Icons.arrow_upward_rounded,
                  size: 18, color: Colors.white),
              if (icindekiler) ...[
                const SizedBox(width: 6),
                Text(en ? 'Contents' : 'İçindekiler',
                    style: YzYazi.veri(boy: 12.5, renk: Colors.white, kalinlik: FontWeight.w600)),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}
