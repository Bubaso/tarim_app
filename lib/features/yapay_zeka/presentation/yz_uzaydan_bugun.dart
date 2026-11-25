import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'yz_gorsel_mobil.dart' show yzKunyeYazisi;
import 'yz_mobil.dart';
import 'yz_tasarim.dart';

/// "Uzaydan bugün" — §19'daki canlı uydu penceresi (`[[canli:uzaydan-bugun]]`).
///
/// Türkiye'nin bitki örtüsü endeksi (NDVI) haritası, NASA GIBS'in WMTS
/// döşemelerinden, sayfa açılınca çekiliyor (ERTELİ pakette; ilk yüke girmez):
///
///   · Katman `MODIS_Terra_NDVI_8Day`: günlük tarihli, kayan 8 günlük bileşik
///     (GIBS: "rolling 8-day", MOD13Q4N). Üstünde `Reference_Features`: kıyı
///     ve sınırlar ("© OpenStreetMap contributors, Natural Earth"). İkisi de
///     `GoogleMapsCompatible_Level9` matrisinde; z6'da 5 × 3 döşeme.
///   · Tarih: varsayılan en son yayımlanmış gün. Aday dünün UTC tarihi;
///     döşeme 404 dönerse bir gün geri, en çok [kYzDenemeGunu] gün (arşivdeki
///     boş günler de böyle atlanıyor). GIBS'in verdiği TEK tarih yazılıyor:
///     bileşiğin hangi 8 günü kapsadığı GIBS'in belgelerinde yazmıyor.
///   · Kaydırıcı: son 12 ay, 13 aylık durak (her ayın aynı günü; ilki ile
///     sonuncusu bir yıl arayla). Sürüklerken tarih anında, döşemeler
///     300 ms durunca ya da bırakınca.
///   · Hata (404 dışı yanıt, ağ yok, art arda 7 gün 404): ilk yüklemede blok
///     hiç çizilmez; sonradan seçilen tarih yüklenemezse kaydırıcı gösterilen
///     tarihe döner. Yükleme boyunca aynı boyda yer tutucu.
///   · Döşemeler tek tuvalde, kenar yumuşatmasız çiziliyor: ölçeklenince
///     döşemeler arasında dikiş kalmıyor.
///   · Basılı sürümde yok (yazdir_uret.py); arama, okuma süresi ve okuma izi
///     saymıyor (`YzBlok.parcalar` boş). Kurallar: dogrula_bolumler.py kural 20.

/// Bölümün tanıdığı canlı pencereler (`[[canli:<kimlik>]]`). Python eşi
/// `dogrula_bolumler.py` › `CANLI_PENCERELER`; test ikisini karşılaştırıyor.
const Set<String> kYzCanliPencereler = {'uzaydan-bugun'};

/// `[[canli:<kimlik>]]` yönergesinin çizimi; tanınmayan kimlik hiçbir şey çizmez.
Widget yzCanliPencere(String kimlik, {required bool en}) => switch (kimlik) {
      'uzaydan-bugun' => YzUzaydanBugun(key: const ValueKey('yz-canli-uzaydan-bugun'), en: en),
      _ => const SizedBox.shrink(),
    };

// ── GIBS ────────────────────────────────────────────────────────────────

const String kYzGibsWmts = 'https://gibs.earthdata.nasa.gov/wmts/epsg3857/best';
const String kYzNdviKatmani = 'MODIS_Terra_NDVI_8Day';
const String kYzSinirKatmani = 'Reference_Features';
const String kYzGibsMatrisi = 'GoogleMapsCompatible_Level9';
const int kYzDosemeBoyu = 256;

/// En son tarih yayımlanmamışsa (404) geriye kaç gün deneniyor (hedef dahil).
const int kYzDenemeGunu = 7;

/// Kaydırıcının kapsadığı ay sayısı (durak sayısı bir fazlası).
const int kYzAySayisi = 12;

/// Türkiye kesiti, derece (batı, güney, doğu, kuzey) ve düzey.
const double kYzKesitBati = 25.0;
const double kYzKesitGuney = 35.5;
const double kYzKesitDogu = 45.5;
const double kYzKesitKuzey = 42.6;
const int kYzKesitDuzeyi = 6;

/// Haritanın zemini: NDVI'si olmayan (deniz, veri yok) yerler. NDVI 0'ın
/// renginden (#F1ECEC) ayrı, açık gri-mavi.
const Color kYzHaritaZemini = Color(0xFFD9E2E9);

/// Web Mercator (EPSG:3857) dünya pikseli, [z] düzeyinde.
double yzMercatorX(double boylam, int z) => (boylam + 180) / 360 * kYzDosemeBoyu * (1 << z);

double yzMercatorY(double enlem, int z) {
  final r = enlem * math.pi / 180;
  return (1 - math.log(math.tan(r) + 1 / math.cos(r)) / math.pi) / 2 * kYzDosemeBoyu * (1 << z);
}

/// Haritanın kesiti: [z] düzeyinde dünya pikseliyle sınırlar ve onu örten
/// döşemeler.
class YzKesit {
  YzKesit.derece({
    required double bati,
    required double guney,
    required double dogu,
    required double kuzey,
    required this.z,
  })  : sol = yzMercatorX(bati, z),
        sag = yzMercatorX(dogu, z),
        ust = yzMercatorY(kuzey, z),
        alt = yzMercatorY(guney, z);

  final int z;
  final double sol, sag, ust, alt;

  int get ilkSutun => sol ~/ kYzDosemeBoyu;
  int get sonSutun => (sag - 1e-9) ~/ kYzDosemeBoyu;
  int get ilkSatir => ust ~/ kYzDosemeBoyu;
  int get sonSatir => (alt - 1e-9) ~/ kYzDosemeBoyu;
  int get sutunSayisi => sonSutun - ilkSutun + 1;
  double get genislik => sag - sol;
  double get yukseklik => alt - ust;

  /// Genişlik / yükseklik.
  double get oran => genislik / yukseklik;

  /// Döşemeler satır satır (y, x).
  List<(int, int)> get dosemeler => [
        for (var y = ilkSatir; y <= sonSatir; y++)
          for (var x = ilkSutun; x <= sonSutun; x++) (y, x),
      ];

  /// Yoklanan döşeme: kesitin ortasındaki (Türkiye'de İç Anadolu, 6/24/38).
  (int, int) get orta => ((ilkSatir + sonSatir) ~/ 2, (ilkSutun + sonSutun) ~/ 2);
}

final YzKesit kYzTurkiyeKesiti = YzKesit.derece(
    bati: kYzKesitBati, guney: kYzKesitGuney, dogu: kYzKesitDogu, kuzey: kYzKesitKuzey, z: kYzKesitDuzeyi);

String _iki(int n) => n.toString().padLeft(2, '0');

/// GIBS'in tarih biçimi: YYYY-MM-DD (UTC günü).
String yzGibsTarih(DateTime gun) => '${gun.year.toString().padLeft(4, '0')}-${_iki(gun.month)}-${_iki(gun.day)}';

/// En son tarihin adayı: dünün UTC tarihi (GIBS'in günleri UTC).
DateTime yzEnSonAday(DateTime simdi) {
  final u = simdi.toUtc();
  return DateTime.utc(u.year, u.month, u.day - 1);
}

/// [hedef] yüklenemezse (404) sırayla denenecek günler: hedef, bir gün önce…
List<DateTime> yzDenenecekGunler(DateTime hedef, {int sayi = kYzDenemeGunu}) => [
      for (var i = 0; i < sayi; i++) DateTime.utc(hedef.year, hedef.month, hedef.day - i),
    ];

/// [gun]den [ay] ay önceki aynı gün; o ayda o gün yoksa ayın son günü
/// (31 Mart → 28/29 Şubat).
DateTime yzAyGeri(DateTime gun, int ay) {
  final bas = DateTime.utc(gun.year, gun.month - ay, 1);
  final son = DateTime.utc(bas.year, bas.month + 1, 0).day;
  return DateTime.utc(bas.year, bas.month, math.min(gun.day, son));
}

/// Kaydırıcının durakları, eskiden yeniye: [enSon]dan [kYzAySayisi] ay önce
/// … [enSon].
List<DateTime> yzDuraklar(DateTime enSon) => [for (var k = kYzAySayisi; k >= 0; k--) yzAyGeri(enSon, k)];

Uri yzNdviDosemesi(DateTime gun, int z, int y, int x) =>
    Uri.parse('$kYzGibsWmts/$kYzNdviKatmani/default/${yzGibsTarih(gun)}/$kYzGibsMatrisi/$z/$y/$x.png');

Uri yzSinirDosemesi(int z, int y, int x) =>
    Uri.parse('$kYzGibsWmts/$kYzSinirKatmani/default/$kYzGibsMatrisi/$z/$y/$x.png');

String _derece(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

/// NASA Worldview'da aynı kesit, katman ve gün. Biçim Worldview'un kendi
/// kodundan ve yapılandırmasından doğrulandı (25 Kasım 2026): `v` batı,
/// güney, doğu, kuzey (derece); `l` katmanlar, üstteki önce; `t`
/// YYYY-MM-DD-THH:MM:SSZ. `Reference_Features`in Worldview'daki karşılığı
/// `Coastlines_15m` ve `DoS_International_Boundaries`.
Uri yzWorldviewAdresi(DateTime gun) => Uri.parse('https://worldview.earthdata.nasa.gov/'
    '?v=${_derece(kYzKesitBati)},${_derece(kYzKesitGuney)},${_derece(kYzKesitDogu)},${_derece(kYzKesitKuzey)}'
    '&l=Coastlines_15m,DoS_International_Boundaries,$kYzNdviKatmani'
    '&t=${yzGibsTarih(gun)}-T00%3A00%3A00Z');

// ── Künye ───────────────────────────────────────────────────────────────

String yzUzaydanTarihi(DateTime gun, bool en) => yzTarih(yzGibsTarih(gun), en);

/// Künyenin ilk parçası: ne olduğu ve GIBS'in tarihi (aralık yazılmaz).
String yzUzaydanKunyesi(DateTime gun, bool en) => en
    ? 'MODIS (Terra) vegetation index (NDVI), rolling 8-day composite, ${yzUzaydanTarihi(gun, true)}'
    : 'MODIS (Terra) bitki örtüsü endeksi (NDVI), 8 günlük kayan bileşik, ${yzUzaydanTarihi(gun, false)}';

/// Künyenin kaynak parçası (kıyı ve sınır katmanının atfı dahil).
String yzUzaydanKaynagi(bool en) => en
    ? 'NASA EOSDIS GIBS · Coastlines and borders: © OpenStreetMap contributors, Natural Earth'
    : 'NASA EOSDIS GIBS · Kıyı ve sınırlar: © OpenStreetMap katkıcıları, Natural Earth';

// ── Lejant ──────────────────────────────────────────────────────────────

/// GIBS'in `MODIS_NDVI` renk haritasının lejantı (colormaps/v1.3/MODIS_NDVI.xml,
/// "Vegetation Indices", 140 LegendEntry, id 3…142), sırasıyla. GIBS'in kendi
/// lejantındaki gibi eşit genişlikli dilimler.
const List<int> kYzNdviLejanti = [
  0xFFF1ECEC, 0xFFF1ECED, 0xFFEFE7E7, 0xFFEFE7E8, 0xFFECE2E2, 0xFFECE2E3, 0xFFE2D8D8, //
  0xFFE2D8D9, 0xFFE1D9D4, 0xFFE1D9D5, 0xFFE0DAD2, 0xFFE0DAD3, 0xFFDDD5CB, 0xFFDDD5CC,
  0xFFE5DBCD, 0xFFE5DBCE, 0xFFE1D2C5, 0xFFE1D2C6, 0xFFDFCEC1, 0xFFDFCEC2, 0xFFDDC9BC,
  0xFFDDC9BD, 0xFFD7C4B3, 0xFFD7C4B4, 0xFFD1C0AB, 0xFFD1C0AC, 0xFFCDBA9E, 0xFFCDBA9F,
  0xFFC8B5A5, 0xFFC8B5A6, 0xFFC0B096, 0xFFC0B097, 0xFFB9AB9B, 0xFFB9AB9C, 0xFFB4A595,
  0xFFB4A596, 0xFFB09F8E, 0xFFB09F8F, 0xFFB09B89, 0xFFB09B8A, 0xFFB19883, 0xFFB19884,
  0xFFB0957D, 0xFFB0957E, 0xFFB09278, 0xFFB09279, 0xFFAC8D73, 0xFFAC8D74, 0xFFA9896E,
  0xFFA9896F, 0xFFA58468, 0xFFA58469, 0xFFA18063, 0xFFA18064, 0xFF9D7C5E, 0xFF9D7C5F,
  0xFF9A6E59, 0xFF9A6E5A, 0xFF965A46, 0xFF965A47, 0xFFBFDE77, 0xFFBFDE78, 0xFFB0CF68,
  0xFFB0CF69, 0xFFA7CC4B, 0xFFA7CC4C, 0xFFA4C63D, 0xFFA4C63E, 0xFFA0C030, 0xFFA0C031,
  0xFF96BA20, 0xFF96BA21, 0xFF8FB715, 0xFF8FB716, 0xFF87B30A, 0xFF87B30B, 0xFF80B005,
  0xFF80B006, 0xFF78AD00, 0xFF78AD01, 0xFF6EAA00, 0xFF6EAA01, 0xFF64A600, 0xFF64A601,
  0xFF5DA300, 0xFF5DA301, 0xFF56A100, 0xFF56A101, 0xFF529800, 0xFF529801, 0xFF539700,
  0xFF539701, 0xFF4E9400, 0xFF4E9401, 0xFF489000, 0xFF489001, 0xFF438D00, 0xFF438D01,
  0xFF3E8A00, 0xFF3E8A01, 0xFF398700, 0xFF398701, 0xFF338300, 0xFF338301, 0xFF2E8000,
  0xFF2E8001, 0xFF297D00, 0xFF297D01, 0xFF217800, 0xFF217801, 0xFF1D7500, 0xFF1D7501,
  0xFF197300, 0xFF197301, 0xFF126E00, 0xFF126E01, 0xFF0A6900, 0xFF0A6901, 0xFF086700,
  0xFF086701, 0xFF056400, 0xFF056401, 0xFF006400, 0xFF006401, 0xFF006000, 0xFF006001,
  0xFF005A00, 0xFF005A01, 0xFF005400, 0xFF005401, 0xFF004800, 0xFF004801, 0xFF003C00,
  0xFF003C01, 0xFF003600, 0xFF003601, 0xFF002400, 0xFF002401, 0xFF001800, 0xFF001801,
];

/// Lejantın etiketleri: (dilim sırası / 140, değer). GIBS lejantının
/// `minLabel` 0.0 ve `maxLabel` 1.0'ı ile `showLabel` girdileri; çentik
/// dilimin sol kenarında.
const List<(int, String)> kYzNdviEtiketleri = [
  (0, '0.0'), (40, '0.2'), (60, '0.3'), (73, '0.4'), (100, '0.6'), (120, '0.8'), (140, '1.0'), //
];

/// Etiketsiz çentikler (GIBS'te yalnız `showTick`): 0.1, 0.5, 0.7, 0.9.
const List<int> kYzNdviCentikleri = [20, 86, 109, 130];

/// Yer darsa önce uçlar, sonra bu sırayla: çakışan etiket düşüyor.
const List<int> _etiketOnceligi = [0, 140, 40, 100, 73, 120, 60];

/// Sığan etiketler ve sol kenarları, soldan sağa. Uçlar kenara yaslı,
/// öbürleri çentiğin ortasında; [olc] etiketin genişliği.
List<(double, String)> yzLejantYerleri(double genislik, bool en, double Function(String) olc,
    {double bosluk = 6}) {
  final secilen = <(double, double, String)>[];
  for (final sira in _etiketOnceligi) {
    final deger = kYzNdviEtiketleri.firstWhere((e) => e.$1 == sira).$2;
    final metin = en ? deger : deger.replaceAll('.', ',');
    final w = olc(metin);
    final x = sira / kYzNdviLejanti.length * genislik;
    final sol = sira == 0 ? 0.0 : (sira == kYzNdviLejanti.length ? genislik - w : x - w / 2);
    final sag = sol + w;
    if (sol < 0 || sag > genislik + 0.01) continue;
    if (secilen.any((s) => sol < s.$2 + bosluk && s.$1 < sag + bosluk)) continue;
    secilen.add((sol, sag, metin));
  }
  secilen.sort((a, b) => a.$1.compareTo(b.$1));
  return [for (final s in secilen) (s.$1, s.$3)];
}

// ── Pencere ─────────────────────────────────────────────────────────────

class YzUzaydanBugun extends StatefulWidget {
  const YzUzaydanBugun({super.key, required this.en, this.dosemeSaglayici, this.simdi});

  final bool en;

  /// Döşemenin görsel sağlayıcısı; yoksa [saglayici] (ağdan).
  final ImageProvider Function(Uri adres)? dosemeSaglayici;

  /// Şimdiki zaman; yoksa [saat].
  final DateTime Function()? simdi;

  /// TEST KANCASI: sayfa düzeyindeki testler ağ yerine sahte döşeme verir.
  @visibleForTesting
  static ImageProvider Function(Uri adres) saglayici = _agdan;

  /// TEST KANCASI: sabit "şimdi".
  @visibleForTesting
  static DateTime Function() saat = DateTime.now;

  static ImageProvider _agdan(Uri adres) => NetworkImage(adres.toString());

  @override
  State<YzUzaydanBugun> createState() => _YzUzaydanBugunState();
}

enum _Durum { yukleniyor, hazir, gizli }

enum _Sonuc { tamam, yok, hata }

/// Bir döşemenin sonucu: görseli ya da hatası.
class _Cozum {
  _Cozum.tamam(ImageInfo this.bilgi) : hata = null;
  _Cozum.hata(Object this.hata) : bilgi = null;
  final ImageInfo? bilgi;
  final Object? hata;

  /// Yayımlanmamış ya da boş gün.
  bool get yok {
    final h = hata;
    return h is NetworkImageLoadException && h.statusCode == 404;
  }
}

class _YzUzaydanBugunState extends State<YzUzaydanBugun> {
  late final List<DateTime> _duraklar;
  late int _secili;
  int? _gosterilenDurak;
  DateTime? _gosterilen;
  List<ImageInfo>? _ndvi;
  List<ImageInfo>? _sinir;
  _Durum _durum = _Durum.yukleniyor;

  /// Yüklenmekte olan durak (ilk yükleme dahil); null: bekleyen yok.
  int? _yuklenen;
  int _nesil = 0;
  Timer? _zamanlayici;
  bool _kapandi = false;

  ImageProvider Function(Uri) get _saglayici => widget.dosemeSaglayici ?? YzUzaydanBugun.saglayici;

  @override
  void initState() {
    super.initState();
    _duraklar = yzDuraklar(yzEnSonAday((widget.simdi ?? YzUzaydanBugun.saat)()));
    _secili = _duraklar.length - 1;
    _yukle(_secili);
  }

  @override
  void dispose() {
    _kapandi = true;
    _nesil++;
    _zamanlayici?.cancel();
    _birak(_ndvi);
    _birak(_sinir);
    _ndvi = null;
    _sinir = null;
    super.dispose();
  }

  static void _birak(List<ImageInfo>? l) {
    for (final b in l ?? const <ImageInfo>[]) {
      b.dispose();
    }
  }

  /// Bir döşeme. Dinleyici sonuç gelene dek bağlı kalıyor (bileşen kapansa
  /// bile): hatayı dinleyen kalmazsa görsel servisi onu genel hata diye
  /// bildirirdi.
  Future<_Cozum> _coz(Uri adres) {
    final sonuc = Completer<_Cozum>();
    final akis = _saglayici(adres).resolve(ImageConfiguration.empty);
    late final ImageStreamListener dinleyici;
    void ayril() => scheduleMicrotask(() => akis.removeListener(dinleyici));
    dinleyici = ImageStreamListener((bilgi, _) {
      if (sonuc.isCompleted) {
        bilgi.dispose();
        return;
      }
      sonuc.complete(_Cozum.tamam(bilgi));
      ayril();
    }, onError: (hata, _) {
      if (!sonuc.isCompleted) sonuc.complete(_Cozum.hata(hata));
      ayril();
    });
    akis.addListener(dinleyici);
    return sonuc.future;
  }

  /// [adresler]in hepsi: tamamsa görseller sırasıyla; en az biri 404 ise
  /// (öbürleri 404 ya da tamam) yok; başka hata varsa hata.
  Future<(_Sonuc, List<ImageInfo>?)> _hepsi(List<Uri> adresler) async {
    final c = await Future.wait([for (final a in adresler) _coz(a)]);
    if (c.every((x) => x.hata == null)) return (_Sonuc.tamam, [for (final x in c) x.bilgi!]);
    for (final x in c) {
      x.bilgi?.dispose();
    }
    return (c.every((x) => x.hata == null || x.yok) ? _Sonuc.yok : _Sonuc.hata, null);
  }

  Future<void> _yukle(int durak) async {
    final nesil = ++_nesil;
    bool gecerli() => !_kapandi && nesil == _nesil;
    if (_durum == _Durum.hazir) {
      setState(() => _yuklenen = durak);
    } else {
      _yuklenen = durak;
    }
    final k = kYzTurkiyeKesiti;
    if (_sinir == null) {
      final (s, g) = await _hepsi([for (final (y, x) in k.dosemeler) yzSinirDosemesi(k.z, y, x)]);
      if (!gecerli()) {
        _birak(g);
        return;
      }
      if (s != _Sonuc.tamam) {
        _basarisiz();
        return;
      }
      _sinir = g;
    }
    final (oy, ox) = k.orta;
    for (final gun in yzDenenecekGunler(_duraklar[durak])) {
      // Önce bir döşeme: gün yayımlanmamışsa 15 istek boşa gitmesin.
      final yoklama = await _coz(yzNdviDosemesi(gun, k.z, oy, ox));
      if (!gecerli()) {
        yoklama.bilgi?.dispose();
        return;
      }
      if (yoklama.yok) continue;
      if (yoklama.hata != null) {
        _basarisiz();
        return;
      }
      final (s, g) = await _hepsi([for (final (y, x) in k.dosemeler) yzNdviDosemesi(gun, k.z, y, x)]);
      yoklama.bilgi?.dispose();
      if (!gecerli()) {
        _birak(g);
        return;
      }
      if (s == _Sonuc.yok) continue;
      if (s == _Sonuc.hata) {
        _basarisiz();
        return;
      }
      final eski = _ndvi;
      setState(() {
        _ndvi = g;
        _gosterilen = gun;
        _gosterilenDurak = durak;
        _durum = _Durum.hazir;
        _yuklenen = null;
      });
      // Eski döşemeler yeni kare çizildikten sonra bırakılıyor.
      WidgetsBinding.instance.addPostFrameCallback((_) => _birak(eski));
      return;
    }
    if (gecerli()) _basarisiz();
  }

  /// İlk yüklemede blok gizleniyor; sonradan seçilen tarih yüklenemezse
  /// kaydırıcı gösterilen tarihe dönüyor.
  void _basarisiz() {
    if (_kapandi) return;
    setState(() {
      _yuklenen = null;
      if (_gosterilen == null) {
        _durum = _Durum.gizli;
        _birak(_sinir);
        _sinir = null;
      } else {
        _secili = _gosterilenDurak!;
      }
    });
  }

  void _kaydirildi(double v) {
    final d = v.round();
    if (d == _secili) return;
    setState(() => _secili = d);
    _zamanlayici?.cancel();
    _zamanlayici = Timer(const Duration(milliseconds: 300), () => _sec(d));
  }

  void _birakildi(double v) {
    _zamanlayici?.cancel();
    _sec(v.round());
  }

  void _sec(int d) {
    if (_kapandi || d == _yuklenen) return;
    if (d == _gosterilenDurak) {
      // Gösterilen durağa dönüldü: bekleyen yükleme geçersiz.
      if (_yuklenen != null) {
        _nesil++;
        setState(() => _yuklenen = null);
      }
      return;
    }
    _yukle(d);
  }

  /// Kaydırıcının üstündeki tarih: seçilen durak; yüklendiyse GIBS'in günü
  /// (404 ile bir iki gün geri gelmiş olabilir).
  DateTime get _etiketGunu =>
      _secili == _gosterilenDurak && _yuklenen == null && _gosterilen != null ? _gosterilen! : _duraklar[_secili];

  String _ayYil(DateTime gun) => yzUzaydanTarihi(gun, widget.en).split(' ').skip(1).join(' ');

  @override
  Widget build(BuildContext context) {
    if (_durum == _Durum.gizli) return const SizedBox.shrink();
    final en = widget.en;
    final telefon = yzTelefon(context);
    final hareketsiz = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final hazir = _durum == _Durum.hazir;
    // İlk yükleme bitene dek yazılar görünmeden yer tutuyor (aday günle).
    final gun = _gosterilen ?? _duraklar.last;
    final kunye = yzUzaydanKunyesi(gun, en);
    final kaynakYazisi = telefon ? yzKunyeYazisi() : YzYazi.veri(boy: 11.5, renk: YzRenk.soluk);
    final kenar = YzYazi.veri(boy: 11, renk: YzRenk.soluk);
    final denetimler = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(yzUzaydanTarihi(_etiketGunu, en),
          key: const ValueKey('yz-uzaydan-tarih'),
          style: YzYazi.veri(boy: 13, renk: YzRenk.murekkep, kalinlik: FontWeight.w600)),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 4,
          activeTrackColor: YzRenk.makine,
          inactiveTrackColor: YzRenk.makineAcik,
          thumbColor: YzRenk.makine,
          overlayColor: YzRenk.makine.withValues(alpha: 0.12),
          activeTickMarkColor: YzRenk.yuzey.withValues(alpha: 0.75),
          inactiveTickMarkColor: YzRenk.makine.withValues(alpha: 0.45),
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 2),
          showValueIndicator: ShowValueIndicator.never,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        ),
        child: Slider(
          value: _secili.toDouble(),
          max: (_duraklar.length - 1).toDouble(),
          divisions: _duraklar.length - 1,
          label: en ? 'Date of the map' : 'Haritanın tarihi',
          semanticFormatterCallback: (v) => yzUzaydanTarihi(
              v.round() == _secili ? _etiketGunu : _duraklar[v.round().clamp(0, _duraklar.length - 1)], en),
          onChanged: hazir ? _kaydirildi : null,
          onChangeEnd: hazir ? _birakildi : null,
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(children: [
          Text(_ayYil(_duraklar.first), style: kenar),
          const Spacer(),
          Text(_ayYil(_duraklar.last), style: kenar),
        ]),
      ),
      const SizedBox(height: 12),
      Text(kunye, style: YzYazi.govde(boy: 14.5).copyWith(height: 1.45)),
      const SizedBox(height: 3),
      Text(yzUzaydanKaynagi(en), style: kaynakYazisi),
      Align(
        alignment: Alignment.centerLeft,
        child: Semantics(
          link: true,
          child: InkWell(
            onTap: _gosterilen == null
                ? null
                : () => launchUrl(yzWorldviewAdresi(_gosterilen!), mode: LaunchMode.externalApplication),
            borderRadius: BorderRadius.circular(4),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 40),
              child: Padding(
                padding: const EdgeInsets.only(top: 2, right: 8),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Flexible(
                    child: Text(en ? 'Open in NASA Worldview' : "NASA Worldview'da aç",
                        style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: YzRenk.makine)),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.open_in_new_rounded, size: 15, color: YzRenk.makine),
                ]),
              ),
            ),
          ),
        ),
      ),
    ]);
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _harita(telefon: telefon, hareketsiz: hareketsiz, kunye: kunye),
        const SizedBox(height: 10),
        _YzNdviLejanti(en: en),
        const SizedBox(height: 8),
        // Aynı ağaç her durumda: yüklenince kaydırıcının durumu kaybolmasın.
        ExcludeSemantics(
          excluding: !hazir,
          child: IgnorePointer(
            ignoring: !hazir,
            child: Opacity(opacity: hazir ? 1 : 0, child: denetimler),
          ),
        ),
      ]),
    );
  }

  /// Telefonda harita kenardan kenara (görseller gibi: makale sütununun 16
  /// piksellik yan payından taşıyor); masaüstünde sütun genişliğinde.
  Widget _harita({required bool telefon, required bool hareketsiz, required String kunye}) {
    return LayoutBuilder(builder: (context, kis) {
      final ekran = MediaQuery.sizeOf(context);
      final tasma = telefon ? ((ekran.width - kis.maxWidth) / 2).clamp(0.0, 16.0).toDouble() : 0.0;
      final w = kis.maxWidth + 2 * tasma;
      final h = w / kYzTurkiyeKesiti.oran;
      Widget harita = Semantics(
        image: true,
        label: _durum == _Durum.hazir ? kunye : null,
        child: AnimatedOpacity(
          // Başka tarih yüklenirken harita soluk; hareket azaltmada geçiş yok.
          opacity: _yuklenen != null && _durum == _Durum.hazir ? 0.55 : 1,
          duration: hareketsiz ? Duration.zero : const Duration(milliseconds: 180),
          child: CustomPaint(
            key: const ValueKey('yz-uzaydan-harita'),
            size: Size(w, h),
            painter: _KesitBoyaci(kYzTurkiyeKesiti, _ndvi, _sinir),
          ),
        ),
      );
      if (tasma == 0) harita = ClipRRect(borderRadius: BorderRadius.circular(4), child: harita);
      return SizedBox(
        height: h,
        child: OverflowBox(minWidth: w, maxWidth: w, minHeight: h, maxHeight: h, child: harita),
      );
    });
  }
}

/// Döşemeleri tek tuvale çiziyor: önce NDVI, üstüne kıyı ve sınırlar.
/// Kenar yumuşatması kapalı ve komşu döşemeler aynı kenar değerini
/// paylaşıyor: ölçekte aralarından zemin sızmıyor.
class _KesitBoyaci extends CustomPainter {
  _KesitBoyaci(this.kesit, this.ndvi, this.sinir);
  final YzKesit kesit;
  final List<ImageInfo>? ndvi;
  final List<ImageInfo>? sinir;

  @override
  void paint(Canvas canvas, Size size) {
    final alan = Offset.zero & size;
    canvas.drawRect(alan, Paint()..color = kYzHaritaZemini);
    final n = ndvi, s = sinir;
    if (n == null || s == null) return;
    final o = size.width / kesit.genislik;
    final sutun = kesit.sutunSayisi;
    double x(int c) => ((kesit.ilkSutun + c) * kYzDosemeBoyu - kesit.sol) * o;
    double y(int r) => ((kesit.ilkSatir + r) * kYzDosemeBoyu - kesit.ust) * o;
    final kalem = Paint()
      ..filterQuality = FilterQuality.medium
      ..isAntiAlias = false;
    canvas.save();
    canvas.clipRect(alan);
    for (final katman in [n, s]) {
      for (var i = 0; i < katman.length; i++) {
        final r = i ~/ sutun, c = i % sutun;
        final g = katman[i].image;
        canvas.drawImageRect(g, Rect.fromLTWH(0, 0, g.width.toDouble(), g.height.toDouble()),
            Rect.fromLTRB(x(c), y(r), x(c + 1), y(r + 1)), kalem);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_KesitBoyaci eski) => !identical(eski.ndvi, ndvi) || !identical(eski.sinir, sinir);
}

/// Lejant: "NDVI", 140 dilimli renk şeridi, çentikler ve sığan etiketler.
class _YzNdviLejanti extends StatelessWidget {
  const _YzNdviLejanti({required this.en});
  final bool en;

  @override
  Widget build(BuildContext context) {
    final yazi = YzYazi.veri(boy: 11, renk: YzRenk.soluk);
    final olcek = MediaQuery.textScalerOf(context);
    Size olc(String m) {
      final p = TextPainter(text: TextSpan(text: m, style: yazi), textDirection: TextDirection.ltr, textScaler: olcek)
        ..layout();
      final s = p.size;
      p.dispose();
      return s;
    }

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('NDVI', style: YzYazi.ustEtiket(renk: YzRenk.murekkep)),
      const SizedBox(width: 12),
      Expanded(
        child: LayoutBuilder(builder: (context, kis) {
          final w = kis.maxWidth;
          final yerler = yzLejantYerleri(w, en, (m) => olc(m).width);
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            CustomPaint(size: Size(w, 14), painter: const _LejantBoyaci()),
            const SizedBox(height: 2),
            SizedBox(
              height: olc('0').height,
              child: Stack(clipBehavior: Clip.none, children: [
                for (final (sol, metin) in yerler) Positioned(left: sol, top: 0, child: Text(metin, style: yazi)),
              ]),
            ),
          ]);
        }),
      ),
    ]);
  }
}

class _LejantBoyaci extends CustomPainter {
  const _LejantBoyaci();

  static const double _serit = 10;

  @override
  void paint(Canvas canvas, Size size) {
    final n = kYzNdviLejanti.length;
    final d = size.width / n;
    final kalem = Paint()..isAntiAlias = false;
    for (var i = 0; i < n; i++) {
      kalem.color = Color(kYzNdviLejanti[i]);
      canvas.drawRect(Rect.fromLTRB(i * d, 0, (i + 1) * d, _serit), kalem);
    }
    // Çentikler: şeridin altında kısa, ince işaretler (GIBS lejantındaki gibi).
    final centik = Paint()
      ..color = YzRenk.soluk
      ..strokeWidth = 1;
    for (final i in [for (final e in kYzNdviEtiketleri) e.$1, ...kYzNdviCentikleri]) {
      final x = (i * d).clamp(0.5, size.width - 0.5).toDouble();
      canvas.drawLine(Offset(x, _serit), Offset(x, size.height), centik);
    }
  }

  @override
  bool shouldRepaint(_LejantBoyaci eski) => false;
}
