import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'yz_metin_gorunumu.dart';
import 'yz_okuma.dart';
import 'yz_olcum_gonderici.dart';

/// Metne bağlı okuma izi (madde 17) ve okuma adımı olayı (madde 24) —
/// ERTELİ pakette (yalnız başlık ve teknoloji sayfaları kullanıyor).
///
///   · İlerleme sayfa boyuyla değil METNİN KELİMELERİYLE ölçülüyor: haberler,
///     komşu başlıklar, görseller ve grafikler hesaba girmiyor. Bir blok,
///     okuma çizgisinin (görünen alanın üstü; telefonda üst çubuğun altı)
///     geçtiği kadarıyla geçilmiş sayılıyor.
///   · "Okundu" = (son paragraf göründü YA DA kelimelerin ≥ %90'ı geçildi)
///     VE (okurun kendi kaydırmasıyla geçilen kelime ≥ %60 YA DA aktif süre ≥
///     beklenen okuma süresinin %30'u). İçindekiler, `?bolum=`, "Kaldığınız
///     yer", arama ve yazı boyu atlamaları kendi kaydırma sayılmıyor.
///   · Kayıt dosyadaki bloğa bağlı (ekranda bölünen parçaya değil): sıra,
///     ilk 24 harfin özeti, alt başlığın sırası ve adı.

final RegExp _kelime = RegExp(r'[\p{L}\p{N}]+', unicode: true);
final RegExp _harf = RegExp(r'[\p{L}\p{N}]', unicode: true);

/// Paragrafın ilk 24 görünen harfinin özeti (madde 17): metin canlıda
/// düzenlendiyse tutmuyor, okur alt başlığın başına açılıyor. Biçim işaretleri
/// (`**`, `*`) ve noktalama harf sayılmıyor.
String yzParagrafOzeti(String metin) {
  var h = 7;
  var n = 0;
  for (final m in _harf.allMatches(metin)) {
    for (final c in m.group(0)!.codeUnits) {
      h = (h * 31 + c) % 2147483647; // web'de de tam sayı sınırında kalıyor
    }
    if (++n == 24) break;
  }
  return '${h.toRadixString(36)}.$n';
}

/// Metnin blokları ve ağırlıkları: bir kez, sayfa açılınca hesaplanıyor.
class YzMetinHaritasi {
  YzMetinHaritasi._(this.en, this.kelime, this.ozet, this.altSira, this.altAdlari, this.altBloklari)
      : toplam = kelime.fold(0, (a, b) => a + b),
        sonMetin = kelime.lastIndexWhere((k) => k > 0);

  factory YzMetinHaritasi.kur(String md, bool en) {
    final kelime = <int>[];
    final ozet = <String>[];
    final altSira = <int>[];
    final altAdlari = <String>[];
    final altBloklari = <int>[];
    final bloklar = yzAyristir(md);
    for (var i = 0; i < bloklar.length; i++) {
      final b = bloklar[i];
      final metin = switch (b.tur) {
        YzBlokTuru.paragraf || YzBlokTuru.ozet || YzBlokTuru.altBaslik => b.metin,
        YzBlokTuru.liste => b.ogeler.join(' '),
        YzBlokTuru.tablo => [for (final s in b.satirlar) ...s].join(' '),
        YzBlokTuru.grafik || YzBlokTuru.gorsel || YzBlokTuru.cekme => '',
      };
      if (b.tur == YzBlokTuru.altBaslik) {
        altAdlari.add(b.metin);
        altBloklari.add(i);
      }
      kelime.add(_kelime.allMatches(metin).length);
      ozet.add(metin.isEmpty ? '' : yzParagrafOzeti(metin));
      altSira.add(altAdlari.length - 1);
    }
    return YzMetinHaritasi._(en, kelime, ozet, altSira, altAdlari, altBloklari);
  }

  final bool en;

  /// Blok başına kelime (grafik ve görselde 0). Toplamı yzKelimeSayisi'ne eşit.
  final List<int> kelime;
  final List<String> ozet;

  /// Bloğun içinde durduğu alt başlığın sırası (-1: ilkinden önce).
  final List<int> altSira;
  final List<String> altAdlari;

  /// Alt başlıkların blok sırası.
  final List<int> altBloklari;
  final int toplam;

  /// Kelimesi olan son blok.
  final int sonMetin;

  int get uzunluk => kelime.length;

  /// Beklenen okuma süresi, saniye (TR 180, EN 230 kelime/dk).
  double get beklenenSaniye => toplam / (en ? kYzDakikadaKelimeEn : kYzDakikadaKelimeTr) * 60;

  /// Kayıttaki konumun bu metindeki bloğu; null: metnin başı.
  /// Önce paragraf (sıra + özet), tutmazsa alt başlığın başı; eski kayıtta oran.
  int? bul(YzSonOkunan k) {
    if (k.en == en && k.paragraf >= 0 && k.paragraf < uzunluk && ozet[k.paragraf] == k.ozet && kelime[k.paragraf] > 0) {
      return k.paragraf;
    }
    if (k.altSira >= 0 && altBloklari.isNotEmpty) {
      if (k.en == en) {
        final j = altAdlari.indexOf(k.altAd);
        if (j >= 0) return altBloklari[j];
      }
      return altBloklari[math.min(k.altSira, altBloklari.length - 1)];
    }
    if (k.paragraf < 0 && k.altSira < 0 && k.oran > 0 && toplam > 0) {
      // Eski kayıt (sayfa oranı): kelime oranına yakın blok.
      var birikim = 0;
      for (var i = 0; i < uzunluk; i++) {
        birikim += kelime[i];
        if (birikim / toplam >= k.oran && kelime[i] > 0) return i;
      }
    }
    return null;
  }
}

/// Eşikler (madde 24): metnin kelime oranı, yüzde.
const List<int> kYzOkumaEsikleri = [25, 50, 75, 100];

/// Okuma ölçüsünün saf hesabı (widget'sız; test doğrudan sınıyor).
class YzOkumaOlcer {
  YzOkumaOlcer(this.harita, {YzSonOkunan? onceki})
      : gecilen = List.filled(harita.uzunluk, 0),
        kendi = List.filled(harita.uzunluk, 0) {
    // Aynı sayfaya dönen okurun önceki ziyareti sayılıyor (aynı metin, aynı dil).
    if (onceki != null && onceki.en == harita.en && onceki.blokSayisi == harita.uzunluk) {
      if (onceki.kendi.length == harita.uzunluk) {
        for (var i = 0; i < harita.uzunluk; i++) {
          kendi[i] = (int.tryParse(onceki.kendi[i]) ?? 0) / 9;
        }
      }
      aktifMs = onceki.sure * 1000;
      enDerin = onceki.oran;
    }
  }

  final YzMetinHaritasi harita;

  /// Blok başına şu an geçilen kısım (0-1).
  final List<double> gecilen;

  /// Blok başına okurun kendi kaydırmasıyla geçilen en çok kısım.
  final List<double> kendi;

  /// Bütün ziyaretlerde ulaşılan en derin kelime oranı.
  double enDerin = 0;

  /// Bu ziyarette son paragraf göründü mü.
  bool sonGoruldu = false;

  /// Bu sayfa görüntülemesinin en derin ilerlemesi (eşikler bundan).
  double gorunumDerin = 0;
  int aktifMs = 0;
  final Set<int> _esikler = {};

  double _oran(List<double> l) {
    if (harita.toplam == 0) return 0;
    var n = 0.0;
    for (var i = 0; i < l.length; i++) {
      n += l[i] * harita.kelime[i];
    }
    return (n / harita.toplam).clamp(0.0, 1.0);
  }

  /// Şu an geçilen kelime oranı.
  double get oran => _oran(gecilen);

  /// Kendi kaydırmayla geçilen kelime oranı.
  double get kendiOrani => _oran(kendi);

  /// Okuma çizgisi: son paragraf görünüyorsa dolu.
  double cizgi(bool sonGorunuyor) => sonGorunuyor ? 1 : oran;

  /// [yeni]: blok başına geçilen kısım. [atlama]: bu değişiklik okurun kendi
  /// kaydırması değil.
  void guncelle(List<double> yeni, {required bool atlama, required bool sonGorunuyor}) {
    for (var i = 0; i < gecilen.length && i < yeni.length; i++) {
      if (!atlama && yeni[i] > gecilen[i] && yeni[i] > kendi[i]) kendi[i] = yeni[i];
      gecilen[i] = yeni[i];
    }
    if (sonGorunuyor) sonGoruldu = true;
    final o = oran;
    if (o > enDerin) enDerin = o;
    final g = sonGorunuyor ? 1.0 : o;
    if (g > gorunumDerin) gorunumDerin = g;
  }

  /// İlk koşul: son paragraf göründü ya da kelimelerin ≥ %90'ı geçildi.
  bool get sonaVardi => sonGoruldu || enDerin >= 0.9;

  /// İkinci koşul: kendi kaydırmayla ≥ %60 ya da aktif süre ≥ beklenenin %30'u.
  bool get emekVar => kendiOrani >= 0.6 || aktifMs / 1000 >= 0.3 * harita.beklenenSaniye;

  bool get okundu => sonaVardi && emekVar;

  /// Bu görüntülemede ilk kez geçilen eşikler; [atlama] ile geçilenler
  /// harcanıyor ama dönmüyor (gönderilmez).
  List<int> yeniEsikler({required bool atlama}) {
    final cikti = <int>[];
    for (final e in kYzOkumaEsikleri) {
      if (_esikler.contains(e) || gorunumDerin * 100 < e - 1e-6) continue;
      _esikler.add(e);
      if (!atlama) cikti.add(e);
    }
    return cikti;
  }

  /// [kendi]nin kaydı: blok başına bir hane.
  String get kendiDizgisi => [for (final k in kendi) (k * 9).round().clamp(0, 9)].join();
}

/// Sayfanın türü (madde 24'teki `sayfa_turu`).
String yzSayfaTuru(String yol) {
  if (yol.contains('/teknoloji/')) return 'teknoloji';
  final slug = yol.split('/').where((x) => x.isNotEmpty).lastOrNull ?? '';
  if (slug == 'sozluk' || slug == 'kaynakca') return slug;
  if (!yol.contains('/', 1) || slug.isEmpty) return 'merkez';
  return 'baslik';
}

/// Ekran sınıfı (madde 24'teki `cihaz`): telefon < 640, tablet < 1100.
String yzCihaz(double genislik) => genislik < 640 ? 'telefon' : (genislik < 1100 ? 'tablet' : 'masaustu');

/// Sayfanın okuma izini süren el: kaydırmayı dinliyor, ölçüyü güncelliyor,
/// kaydı ve olayları bırakıyor. YzMakaleSayfasi kuruyor.
class YzOkumaTakipcisi {
  YzOkumaTakipcisi({
    required this.md,
    required this.en,
    required this.yol,
    required this.ad,
    required this.kaydirma,
    required this.vurgu,
    required this.iz,
    required this.ilerleme,
    required this.cizgiPayi,
    required this.ortam,
  })  : harita = YzMetinHaritasi.kur(md, en),
        giris = YzGiris.al() {
    final s = iz.simdiki.son;
    olcer = YzOkumaOlcer(harita, onceki: s != null && s.yol == yol ? s : null);
    _zamanlayici = Timer.periodic(const Duration(seconds: 1), (_) => _saniyeGecti());
  }

  /// Olayların gittiği yer. TEST KANCASI: testler yakalamak için değiştirir.
  static void Function(String olay, Map<String, Object> parametreler) olcum = yzOlcum;

  final String md;
  final bool en;
  final String yol;
  final String ad;
  final ScrollController kaydirma;
  final YzVurguDenetcisi vurgu;
  final YzOkumaIziDenetcisi iz;

  /// Telefondaki okuma çizgisi.
  final ValueNotifier<double> ilerleme;

  /// Okuma çizgisinin görünen alanın üstünden uzaklığı (telefonda üst çubuk).
  final double Function() cizgiPayi;

  /// O anki ekran sınıfı ve yazı boyu.
  final ({String cihaz, double olcek}) Function() ortam;
  final YzMetinHaritasi harita;
  late final YzOkumaOlcer olcer;

  /// Sayfaya nereden gelindi; sözlükten dönüş sonradan işaretlenebiliyor.
  String giris;

  Timer? _zamanlayici;
  int _saniye = 0;
  int _sonEtkilesim = 0;
  bool _acildi = false;
  bool _okunduBildirildi = false;
  final List<int> _bekleyenEsikler = [];
  int _paragraf = -1;
  bool _kayitBekliyor = false;
  int _sonKayitSaniye = -10;

  // Atlama: programın yaptığı kaydırma (okurun kendi kaydırması değil).
  bool _atlama = false;
  ScrollPosition? _dinlenen;

  // Blokların içerikteki yeri ve boyu; yerleşim değişince yeniden ölçülür.
  List<double>? _ust;
  List<double>? _boy;
  double? _olculenEnCok;
  double? _olculenGorunen;

  String get _slug => yol.split('/').where((x) => x.isNotEmpty).lastOrNull ?? '';

  // ── yerleşim ──
  bool _geometri({bool zorla = false}) {
    if (!kaydirma.hasClients) return false;
    final p = kaydirma.position;
    if (!p.hasContentDimensions || !p.hasViewportDimension) return false;
    final anahtarlar = vurgu.blokAnahtarlari;
    if (anahtarlar.length != harita.uzunluk) return false;
    if (!zorla &&
        _ust != null &&
        p.maxScrollExtent == _olculenEnCok &&
        p.viewportDimension == _olculenGorunen) {
      return true;
    }
    final ust = List<double>.filled(harita.uzunluk, 0);
    final boy = List<double>.filled(harita.uzunluk, 0);
    for (var i = 0; i < harita.uzunluk; i++) {
      if (harita.kelime[i] == 0) continue;
      final ro = anahtarlar[i]?.currentContext?.findRenderObject();
      if (ro is! RenderBox || !ro.attached || !ro.hasSize) return false;
      final vp = RenderAbstractViewport.maybeOf(ro);
      if (vp == null) return false;
      ust[i] = vp.getOffsetToReveal(ro, 0).offset;
      boy[i] = ro.size.height;
    }
    _ust = ust;
    _boy = boy;
    _olculenEnCok = p.maxScrollExtent;
    _olculenGorunen = p.viewportDimension;
    return true;
  }

  /// Okuma çizgisindeki blok ve bloğun geçilen kısmı.
  (int, double)? _yer() {
    if (!_geometri()) return null;
    final c = kaydirma.position.pixels + cizgiPayi();
    for (var i = 0; i < harita.uzunluk; i++) {
      if (harita.kelime[i] == 0) continue;
      if (_ust![i] + _boy![i] > c) {
        return (i, _boy![i] <= 0 ? 0 : ((c - _ust![i]) / _boy![i]).clamp(0.0, 1.0));
      }
    }
    return harita.sonMetin < 0 ? null : (harita.sonMetin, 1);
  }

  // ── kaydırma ──
  void _kaydirmaBitti() {
    final p = _dinlenen;
    if (p == null || p.isScrollingNotifier.value) return;
    if (_atlama) {
      _degerlendir();
      _atlama = false;
    }
  }

  /// Kaydırıcının dinleyicisinden.
  void kaydirildi() {
    if (!kaydirma.hasClients) return;
    final p = kaydirma.position;
    if (!identical(p, _dinlenen)) {
      _dinlenen?.isScrollingNotifier.removeListener(_kaydirmaBitti);
      _dinlenen = p;
      p.isScrollingNotifier.addListener(_kaydirmaBitti);
    }
    if (!_atlama) _sonEtkilesim = _saniye;
    _degerlendir();
  }

  /// [f] programın kaydırması: içindekiler, `?bolum=`, kaldığınız yer, arama,
  /// yazı boyu. Geçilen kelimeler okurun kendi kaydırması sayılmaz.
  void atla(VoidCallback f) {
    _atlama = true;
    f();
    final p = kaydirma.hasClients ? kaydirma.position : null;
    if (p == null || !p.isScrollingNotifier.value) {
      _degerlendir();
      _atlama = false;
    } else if (!identical(p, _dinlenen)) {
      _dinlenen?.isScrollingNotifier.removeListener(_kaydirmaBitti);
      _dinlenen = p;
      p.isScrollingNotifier.addListener(_kaydirmaBitti);
    }
  }

  void _degerlendir() {
    if (!_geometri()) return;
    final p = kaydirma.position;
    final c = p.pixels + cizgiPayi();
    final alt = p.pixels + p.viewportDimension;
    final yeni = List<double>.filled(harita.uzunluk, 0);
    for (var i = 0; i < harita.uzunluk; i++) {
      final b = _boy![i];
      if (harita.kelime[i] == 0 || b <= 0) continue;
      yeni[i] = ((c - _ust![i]) / b).clamp(0.0, 1.0);
    }
    final s = harita.sonMetin;
    final sonGorunuyor = s >= 0 && (_ust![s] + _boy![s] <= alt + 1 || _ust![s] <= c);
    olcer.guncelle(yeni, atlama: _atlama, sonGorunuyor: sonGorunuyor);
    ilerleme.value = olcer.cizgi(sonGorunuyor);

    final yer = _yer();
    if (yer != null && yer.$1 != _paragraf) {
      _paragraf = yer.$1;
      _kayitBekliyor = true;
    }
    _esikleriDenetle();
    _okunduDenetle();
    if (_kayitBekliyor && _saniye - _sonKayitSaniye >= 1) _kaydet();
  }

  // ── kayıt ──
  void _kaydet() {
    _kayitBekliyor = false;
    if (!iz.mounted || _paragraf < 0) return;
    // Hiç ilerlemeden çıkılan sayfa öncekinin "Kaldığınız yer"ini silmesin.
    final onceki = iz.simdiki.son;
    if (olcer.enDerin <= kYzYarimEsigi && (onceki == null || onceki.yol != yol)) return;
    _sonKayitSaniye = _saniye;
    final alt = harita.altSira[_paragraf];
    try {
      iz.konum(YzSonOkunan(
        yol: yol,
        ad: ad,
        oran: olcer.enDerin,
        paragraf: _paragraf,
        ozet: harita.ozet[_paragraf],
        altSira: alt,
        altAd: alt >= 0 ? harita.altAdlari[alt] : '',
        en: en,
        zaman: DateTime.now(),
        kendi: olcer.kendiDizgisi,
        sure: olcer.aktifMs ~/ 1000,
        blokSayisi: harita.uzunluk,
      ));
    } catch (_) {}
  }

  void _okunduDenetle() {
    if (_okunduBildirildi || !olcer.okundu || !iz.mounted) return;
    _okunduBildirildi = true;
    try {
      iz.okundu(yol);
    } catch (_) {}
    _kayitBekliyor = true;
  }

  // ── olaylar (madde 24) ──
  Map<String, Object> _parametreler(String adim) {
    final o = ortam();
    final alt = _paragraf >= 0 ? harita.altSira[_paragraf] : -1;
    return {
      'adim': adim,
      'sayfa': _slug,
      'sayfa_turu': yzSayfaTuru(yol),
      'bolum_sira': alt + 1,
      'bolum_sayisi': harita.altAdlari.length,
      'cihaz': o.cihaz,
      'dil': en ? 'en' : 'tr',
      'yazi_olcegi': o.olcek,
      'giris': giris,
    };
  }

  void _gonder(String adim) {
    try {
      olcum('yz_okuma_adimi', _parametreler(adim));
    } catch (_) {}
  }

  void _esikleriDenetle() {
    if (!_acildi) return;
    _bekleyenEsikler.addAll(olcer.yeniEsikler(atlama: _atlama));
    // Sayfa 3 sn açık kalmadan eşik gönderilmez.
    if (_saniye < 3) return;
    for (final e in _bekleyenEsikler) {
      _gonder('y$e');
    }
    _bekleyenEsikler.clear();
  }

  /// Sayfa ilk kez çizildi: `acildi` gidiyor, ilk ölçü alınıyor.
  void baslat() {
    if (_acildi) return;
    _acildi = true;
    _sonEtkilesim = _saniye;
    _degerlendir();
    _gonder('acildi');
    _esikleriDenetle();
  }

  void _saniyeGecti() {
    _saniye++;
    final durum = WidgetsBinding.instance.lifecycleState;
    final onde = durum == null || durum == AppLifecycleState.resumed;
    // Okur 90 sn'den uzun süre kımıldamadıysa süre sayılmıyor.
    if (onde && _saniye - _sonEtkilesim <= 90) olcer.aktifMs += 1000;
    if (_saniye == 3) _esikleriDenetle();
    _okunduDenetle();
    if (_kayitBekliyor || _saniye % 15 == 0) _kaydet();
  }

  // ── konuma gitme ──
  double? _hedef(int blok, double kesir) {
    if (!_geometri(zorla: true)) return null;
    final p = kaydirma.position;
    final y = _ust![blok] + kesir * _boy![blok] - cizgiPayi() - (kesir == 0 ? 12 : 0);
    return y.clamp(p.minScrollExtent, p.maxScrollExtent).toDouble();
  }

  /// "Kaldığınız yer": kayıttaki paragrafa (madde 17). Hareket azaltma
  /// tercihi açıksa animasyonsuz (madde 14). true: gidildi.
  bool metneGit(YzSonOkunan kayit, {required bool hareketsiz}) {
    final blok = harita.bul(kayit);
    if (blok == null) return false;
    final h = _hedef(blok, 0);
    if (h == null) return false;
    atla(() {
      if (hareketsiz) {
        kaydirma.jumpTo(h);
      } else {
        kaydirma.animateTo(h, duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
      }
    });
    return true;
  }

  /// Yazı boyu değişmeden önce: okunan blok ve içindeki yer.
  (int, double)? yeriTut() => _yer();

  /// Yazı boyu değiştikten sonra: aynı blok ve yer.
  void yereDon((int, double) yer) {
    final h = _hedef(yer.$1, yer.$2);
    if (h != null) atla(() => kaydirma.jumpTo(h));
  }

  void kapat() {
    _zamanlayici?.cancel();
    _zamanlayici = null;
    _dinlenen?.isScrollingNotifier.removeListener(_kaydirmaBitti);
    _dinlenen = null;
    // Sayfa kapanırken ağaç kilitli: kayıt bir mikro görev sonra.
    if (_paragraf >= 0 || (olcer.okundu && !_okunduBildirildi)) {
      scheduleMicrotask(() {
        _okunduDenetle();
        if (_paragraf >= 0) _kaydet();
      });
    }
  }
}
