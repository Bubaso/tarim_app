import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import '../../../core/analitik/analitik.dart';
import '../../../core/analitik/belge.dart';

/// Bölümün okuma olayları için İNCE gönderici — ilk yükte durabilecek kadar
/// hafif; bölümün ağır dosyalarını içe aktarmaz.
///
/// Olaylar kişisel veri taşımaz: kimlik, arama sözcüğü, alt başlık metni
/// gitmez. Hatalar yutulur; ölçüm okumayı asla bozmaz.
///
/// KALIP (birleştirme sözleşmesi): öteki gruplar yalnız [yzOlcum]'u çağırır.
/// Olay adları ve parametre listesi: `content/yapay_zeka_dijital_tarim/
/// _raw/README.md`, "Ölçüm" bölümü.
///
/// Temizlik: değerler metne ya da sayıya çevrilir (bool → 1/0), metin 100
/// karaktere kırpılır, en çok 25 parametre gider. Adı kişisel veri
/// çağrıştıran anahtar (e-posta, telefon, ad, kullanıcı, IP, konum, sorgu,
/// arama, terim…) ve e-posta biçimli değer atılır. Alt başlığın METNİ
/// gönderilmez; yalnız sırası (`bolum_sira`).
void yzOlcum(String olay, Map<String, Object> parametreler) {
  try {
    if (!_adGecerli(olay)) return;
    final temiz = _temizle(parametreler);
    if (olay == 'yz_okuma_adimi' && temiz['adim'] == 'acildi') {
      // Hız kovası daha hesaplanmadıysa (ilk metin karesi henüz çizilmedi)
      // olay o kareye kadar bekletilir; çizilince kovasıyla gider.
      if (_kareBekleniyor) {
        _bekleyenler.add((olay, temiz));
        return;
      }
      final kova = _hizKovasi;
      _hizKovasi = null;
      if (kova != null) temiz['ilk_kare'] = kova;
    }
    _gonder(olay, temiz);
  } catch (_) {}
}

/// Testlerde çağrıları (temizlenmiş parametreleriyle) yakalamak için.
@visibleForTesting
void Function(String olay, Map<String, Object> parametreler)? yzOlcumDinleyici;

void _gonder(String olay, Map<String, Object> p) {
  yzOlcumDinleyici?.call(olay, p);
  analitikOlay(olay, p);
}

// ─── Açılış hızı ───────────────────────────────────────────────────────────
//
// `acildi` olayı ilk metin karesine kadar geçen sürenin kovasını taşır
// (`ilk_kare`): okurun YAVAŞLIK yüzünden mi, metin yüzünden mi bıraktığı
// ancak böyle ayrılır. Ölçümü `YzErteliSayfa` başlatıyor (kurulunca) ve
// bitiriyor (bölüm ekranını ilk kez kurunca); süre bu dosyada tutulur.
//
// Soğuk açılışta (okur siteye doğrudan bölümden girdi) süre SAYFANIN
// açılışından ölçülür: okurun beklediği, uygulamanın inmesi dahil, budur.
// Site içi geçişte YzErteliSayfa'nın kurulduğu andan.

final Stopwatch _kronometre = Stopwatch()..start();
int _kronometreSaati() => _kronometre.elapsedMilliseconds;
int Function() _saat = _kronometreSaati;

int? _baslangic;
bool _soguk = false;
bool _kareBekleniyor = false;
bool _kareIstendi = false;
String? _hizKovasi;
final List<(String, Map<String, Object>)> _bekleyenler = [];

/// Testte saati elle sürmek ve durumu sıfırlamak için.
@visibleForTesting
void yzOlcumTestAyari({int Function()? saat}) {
  _saat = saat ?? _kronometreSaati;
  _baslangic = null;
  _kareBekleniyor = false;
  _kareIstendi = false;
  _hizKovasi = null;
  _bekleyenler.clear();
}

/// Süre kovası: <1, 1-2, 2-4, >4 saniye.
String yzHizKovasi(int ms) {
  if (ms < 1000) return '<1';
  if (ms < 2000) return '1-2';
  if (ms < 4000) return '2-4';
  return '>4';
}

/// Bölüm sayfası açılmaya başladı (paket inmeden önce).
void yzOlcumAcilisBaslat() {
  try {
    _bekleyenleriGonder(); // önceki açılıştan kalan olay kovasız gider
    _baslangic = _saat();
    _soguk = !sayfaGecisiOldu;
    _kareBekleniyor = true;
    _kareIstendi = false;
    _hizKovasi = null;
  } catch (_) {}
}

/// Bölüm ekranı kuruldu; bu karenin çizilmesi "ilk metin karesi". Her
/// kurulumda çağrılabilir; açılış başına bir kez sayılır.
void yzOlcumIlkMetinKaresi() {
  if (!_kareBekleniyor || _kareIstendi) return;
  _kareIstendi = true;
  try {
    SchedulerBinding.instance.addPostFrameCallback((_) => yzOlcumKareCizildi());
  } catch (_) {}
}

/// Kare çizildi: süreyi kovaya çevirir, bekleyen `acildi`'yi gönderir.
/// (Testler kareyi beklemeden doğrudan çağırabilir.)
@visibleForTesting
void yzOlcumKareCizildi() {
  if (!_kareBekleniyor) return;
  try {
    final bas = _baslangic ?? _saat();
    final sayfadan = _soguk ? belgeSuresiMs() : null;
    final ms = sayfadan?.round() ?? (_saat() - bas);
    _hizKovasi = yzHizKovasi(ms < 0 ? 0 : ms);
  } catch (_) {}
  _bekleyenleriGonder();
}

void _bekleyenleriGonder() {
  _kareBekleniyor = false;
  if (_bekleyenler.isEmpty) return;
  final liste = List.of(_bekleyenler);
  _bekleyenler.clear();
  for (final (olay, p) in liste) {
    final kova = _hizKovasi;
    _hizKovasi = null;
    if (kova != null) p['ilk_kare'] = kova;
    _gonder(olay, p);
  }
}

// ─── Temizlik ──────────────────────────────────────────────────────────────

final RegExp _adKalibi = RegExp(r'^[A-Za-z][A-Za-z0-9_]{0,39}$');

bool _adGecerli(String ad) =>
    _adKalibi.hasMatch(ad) &&
    !ad.startsWith('firebase_') &&
    !ad.startsWith('google_') &&
    !ad.startsWith('ga_');

/// Kişisel veri taşıyabilecek anahtar parçaları. Anahtar `_` ile bölünüp
/// her parça ayrı sınanır (`tip` geçer, `ip` geçmez; `adim` geçer, `ad`
/// geçmez).
final RegExp _kisiselParca = RegExp(
  r'^(e?mail|eposta|posta|telefon|tel|phone|gsm|isim|name|ad|soyad|user|userid|'
  r'kullanici|uid|kimlik|tc|tckn|ip|adres|address|konum|location|lat|lng|lon|'
  r'enlem|boylam|sorgu|query|q|arama|ara|search|terim|term|token|sifre|password|'
  r'cerez|cookie)$',
  caseSensitive: false,
);

final RegExp _eposta = RegExp(r'[^\s@]+@[^\s@]+\.[^\s@]+');

const int _degerSiniri = 100;
const int _parametreSiniri = 25;

bool _anahtarKisisel(String anahtar) =>
    anahtar.split('_').any(_kisiselParca.hasMatch);

Map<String, Object> _temizle(Map<String, Object> girdi) {
  final cikti = <String, Object>{};
  for (final e in girdi.entries) {
    if (cikti.length >= _parametreSiniri) break;
    final k = e.key;
    if (!_adGecerli(k) || _anahtarKisisel(k)) continue;
    final v = e.value;
    if (v is num) {
      if (v.isFinite) cikti[k] = v;
    } else if (v is bool) {
      cikti[k] = v ? 1 : 0;
    } else {
      final s = _kirp(v.toString());
      if (s.isEmpty || _eposta.hasMatch(s)) continue;
      cikti[k] = s;
    }
  }
  return cikti;
}

String _kirp(String s) {
  if (s.length <= _degerSiniri) return s;
  var son = _degerSiniri;
  // Vekil çiftini ortadan bölme.
  final c = s.codeUnitAt(son - 1);
  if (c >= 0xD800 && c <= 0xDBFF) son--;
  return s.substring(0, son);
}
