import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import 'analitik.dart';
import 'belge.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  Site içi sayfa geçişleri GA'ya + bölüm sayfalarının sekme başlığı
//
//  GA bugüne kadar yalnız okurun siteye İLK girdiği sayfayı görüyordu
//  (ölçüldü: geçişte 15 sn içinde 0 isabet, pushState/popstate ile de 0).
//  `FirebaseAnalyticsObserver` bunu kapatmıyor: adı olan rotada yalnız
//  `screen_view` yazıyor, oysa rotaların neredeyse hepsi `pageBuilder` ile
//  ADSIZ sayfa kuruyor (yalnız `/` ve `/hikaye-arsivi` ad taşıyor) ve
//  `screen_view` GA'nın sayfa raporlarına girmiyor.
//
//  Çözüm yönlendiricinin kendisini dinlemek: adres her değiştiğinde, kare
//  çizildikten (sayfa sekme başlığını yazdıktan) sonra bir `page_view`.
//  • İlk sayfa ATLANIR: onu `web/index.html`'deki SDK'nın açılıştaki
//    `config`'i zaten sayıyor.
//  • Aynı adres art arda gelirse ELENİR (yeniden çizim, geri-ileri
//    titremesi, yalnız arama sözcüğünün değişmesi).
//  • Adresten `bolum` ve `teknoloji` dışındaki sorgu parametreleri ATILIR:
//    `q`, `ara`, `terim`, `geri` okurun yazdığı sözcüğü taşıyabilir.
// ═══════════════════════════════════════════════════════════════════════════

/// Sekme başlığının sonundaki ad (MaterialApp `title` ile aynı).
const String kSiteAdi = 'Tarım Portalı';

/// Ölçüme giden adreste kalan sorgu parametreleri; ötekiler atılır.
const Set<String> kOlcumdeKalanParametreler = {'bolum', 'teknoloji'};

/// Adresin ölçüme giden hâli: yol + yalnız izinli parametreler, parça yok.
Uri olcumAdresi(Uri adres) {
  final kalan = <String, String>{
    for (final e in adres.queryParameters.entries)
      if (kOlcumdeKalanParametreler.contains(e.key)) e.key: e.value,
  };
  return Uri(
    path: adres.path.isEmpty ? '/' : adres.path,
    queryParameters: kalan.isEmpty ? null : kalan,
  );
}

/// Sayfa adı: bölümün sayfası için ad, bölüm dışı için null.
typedef SekmeAdi = String? Function(Uri adres, bool ingilizce);

/// Yönlendiriciyi dinleyip sekme başlığını yazan ve `page_view` gönderen
/// nesne. Bağımlılıkları dışarıdan alıyor ki testte gerçek tarayıcı
/// olmadan sınanabilsin.
class SayfaIzleyici {
  SayfaIzleyici({
    required this.konum,
    required this.sekmeAdi,
    required this.basligiYaz,
    required this.belgeBasligiOku,
    required this.gonder,
    this.kok = '',
    void Function(VoidCallback)? kareSonra,
    this.gecisSonrasiDenetim = const Duration(milliseconds: 600),
  }) : _kareSonra = kareSonra ?? _sonrakiKareden;

  /// Yönlendiricinin o anki adresi (henüz yoksa null).
  final Uri? Function() konum;
  final SekmeAdi sekmeAdi;
  final void Function(String baslik) basligiYaz;
  final String? Function() belgeBasligiOku;
  final void Function(String olay, Map<String, Object> parametreler) gonder;

  /// `https://tarimportali.net` gibi; adresin önüne eklenir.
  final String kok;
  final void Function(VoidCallback) _kareSonra;

  /// Bölümden bir habere gidip geri dönüldüğünde haber ekranı KAPANIRKEN
  /// (geçiş bittikten sonra) sekmeyi kendi varsayılanına çeviriyor; bölüm
  /// başlığı bu süre sonunda bir kez daha denetlenip gerekirse yazılıyor.
  final Duration gecisSonrasiDenetim;

  bool _ingilizce = false;
  Uri? _ilkAdres;
  Uri? _sonOlculen;
  bool _kareBekleniyor = false;
  String? _bolumBasligi;
  Timer? _denetim;

  static void _sonrakiKareden(VoidCallback f) {
    final b = SchedulerBinding.instance;
    b.addPostFrameCallback((_) => f());
    b.ensureVisualUpdate();
  }

  /// Site dili değişti (ya da ilk kez bilindi): bölüm başlığı yeni dilde.
  void dilDegisti(bool ingilizce) {
    _ingilizce = ingilizce;
    basligiYenile();
  }

  /// Uygulamanın `Title`'ı sekmeyi ezdiyse bölüm başlığını geri yazar.
  void basligiYenile() {
    final adres = konum();
    if (adres != null) _basligiUygula(adres);
  }

  /// `routerDelegate` dinleyicisi.
  void rotaDegisti() {
    final adres = konum();
    if (adres == null) return;
    final temiz = olcumAdresi(adres);
    if (_ilkAdres == null) {
      _ilkAdres = temiz;
    } else if (temiz != _ilkAdres) {
      sayfaGecisiOldu = true;
    }
    _basligiUygula(adres);
    if (_kareBekleniyor) return;
    _kareBekleniyor = true;
    _kareSonra(_olc);
  }

  void _basligiUygula(Uri adres) {
    final ad = sekmeAdi(adres, _ingilizce);
    if (ad != null) {
      final baslik = '$ad | $kSiteAdi';
      _bolumBasligi = baslik;
      basligiYaz(baslik);
      _denetim?.cancel();
      _denetim = Timer(gecisSonrasiDenetim, () {
        final b = _bolumBasligi;
        if (b != null && belgeBasligiOku() != b) basligiYaz(b);
      });
    } else if (_bolumBasligi != null) {
      // Bölümden çıkıldı: sitenin varsayılanı. Kendi başlığını yazan ekran
      // (haber, ülke dosyası) bunun ARDINDAN, kurulurken yazıyor.
      _bolumBasligi = null;
      _denetim?.cancel();
      basligiYaz(kSiteAdi);
    }
  }

  void _olc() {
    _kareBekleniyor = false;
    final adres = konum();
    if (adres == null) return;
    final temiz = olcumAdresi(adres);
    final onceki = _sonOlculen;
    if (onceki == null) {
      // İlk sayfa: gtag açılışta saydı.
      _sonOlculen = temiz;
      return;
    }
    if (temiz == onceki) return;
    _sonOlculen = temiz;
    gonder('page_view', {
      'page_location': '$kok$temiz',
      'page_title': _bolumBasligi ?? belgeBasligiOku() ?? kSiteAdi,
      'page_referrer': '$kok$onceki',
    });
  }

  @visibleForTesting
  void kapat() => _denetim?.cancel();
}

SayfaIzleyici? _etkin;

/// Uygulamanın izleyicisi (yönlendirici kurulduysa).
SayfaIzleyici? get sayfaIzleyici => _etkin;

/// Testte kendi kurduğu izleyiciyi [BelgeDili]'ye bağlamak için.
@visibleForTesting
set sayfaIzleyici(SayfaIzleyici? izleyici) => _etkin = izleyici;

void _sekmeyeYaz(String baslik) {
  SystemChrome.setApplicationSwitcherDescription(ApplicationSwitcherDescription(
    label: baslik,
    // MaterialApp'in `Title`'ının kullandığı renk: tarayıcı çubuğunun
    // rengi (theme-color) sayfadan sayfaya oynamasın.
    primaryColor: AppColors.primaryGreen.toARGB32(),
  ));
}

/// Okurun o an gördüğü sayfanın adresi.
///
/// `context.push` (bölüme ve bölüm içinde geçişlerin çoğu) go_router 14'te
/// adres çubuğunu DEĞİŞTİRMİYOR ve `currentConfiguration.uri` de eski
/// adreste kalıyor; itilen sayfanın adresi en üstteki
/// [ImperativeRouteMatch]'in içinde. Onu okumazsak itilen hiçbir sayfa
/// sayılmaz, sekme başlığı da yazılmaz.
Uri? yonlendiriciAdresi(GoRouter yonlendirici) {
  try {
    final c = yonlendirici.routerDelegate.currentConfiguration;
    if (c.isEmpty) return null;
    final ust = c.matches.last;
    if (ust is ImperativeRouteMatch) return ust.matches.uri;
    return c.uri;
  } catch (_) {
    return null;
  }
}

/// Yönlendiriciye izleyiciyi bağlar ve yönlendiricinin kendisini döndürür.
GoRouter sayfaGorunumunuIzle(GoRouter yonlendirici, {required SekmeAdi sekmeAdi}) {
  // Ölçüm örneği `send_page_view: false` ile ŞİMDİ önbelleğe girsin;
  // başka bir çağrı (`FirebaseAnalytics.instance`) seçeneksiz kurmadan.
  analitikOrnegi();
  final izleyici = SayfaIzleyici(
    konum: () => yonlendiriciAdresi(yonlendirici),
    sekmeAdi: sekmeAdi,
    basligiYaz: _sekmeyeYaz,
    belgeBasligiOku: belgeBasligi,
    // Yalnız web: telefon uygulamasında `page_view` anlamsız.
    gonder: kIsWeb ? analitikOlay : (_, __) {},
    kok: kIsWeb ? Uri.base.origin : '',
  );
  _etkin = izleyici;
  yonlendirici.routerDelegate.addListener(izleyici.rotaDegisti);
  return yonlendirici;
}

/// Belge dilini (`<html lang>`) sitenin diline eşitler ve dil değişince
/// bölüm sekme başlığını yeniden yazar. MaterialApp'in `builder`'ında,
/// `Localizations`'ın altında durur.
class BelgeDili extends StatefulWidget {
  const BelgeDili({super.key, required this.child, this.yaz = belgeDiliniYaz});

  final Widget child;

  /// Testte yakalanabilsin diye.
  final void Function(String dil) yaz;

  @override
  State<BelgeDili> createState() => _BelgeDiliState();
}

class _BelgeDiliState extends State<BelgeDili> {
  String? _dil;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dil = Localizations.maybeLocaleOf(context)?.languageCode == 'en' ? 'en' : 'tr';
    if (dil == _dil) return;
    _dil = dil;
    widget.yaz(dil);
    _etkin?.dilDegisti(dil == 'en');
  }

  @override
  void didUpdateWidget(BelgeDili eski) {
    super.didUpdateWidget(eski);
    // Uygulama yeniden kurulunca `Title` sekmeyi 'Tarım Portalı'na çekiyor
    // (atası olduğu için bizden önce); bölümdeysek başlığı geri yaz.
    _etkin?.basligiYenile();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
