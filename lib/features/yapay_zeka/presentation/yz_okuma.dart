import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// HAFİF DOSYA: ana sayfa şeridi ("Kaldığınız yer", madde 18) bunu ilk yükte
// kullanıyor. Yalnız riverpod, shared_preferences ve iskelet (başlık adları;
// zaten ilk yükte). Bölümün metinlerini ya da ekranlarını içe aktarmaz.
import '../data/yz_iskelet.g.dart';

/// Okuma kolaylıkları (okuma deneyimi turu, 18 Kas 2026; karar 60):
/// okuma süresi, yazı boyu, sözlükten dönüşte kaldığı yer ve bölüm içi
/// aramanın eşleştiricisi.

// ── Okuma süresi ──────────────────────────────────────────────────────────

/// Dakikada okunan kelime: Türkçe açıklayıcı metin için ~180, İngilizce ~230.
const int kYzDakikadaKelimeTr = 180;
const int kYzDakikadaKelimeEn = 230;

final RegExp _yonergeSatiri = RegExp(r'^\[\[(grafik|gorsel):[a-z0-9-]+\]\]$');
final RegExp _ayiracSatiri = RegExp(r'^\|?[\s:|-]+\|?$');
final RegExp _kelime = RegExp(r'[\p{L}\p{N}]+', unicode: true);

/// Metnin kelime sayısı: başlık satırı, grafik/görsel yönergeleri ve tablo
/// ayıraçları sayılmaz.
int yzKelimeSayisi(String md) {
  var n = 0;
  for (final satir in md.split('\n')) {
    final t = satir.trim();
    if (t.isEmpty || t.startsWith('# ') || _yonergeSatiri.hasMatch(t) || _ayiracSatiri.hasMatch(t)) {
      continue;
    }
    n += _kelime.allMatches(t).length;
  }
  return n;
}

/// Kelime sayısından okuma süresi, dakika (en az 1). dart_uret.py'deki
/// `okuma_dakikasi` ile aynı kural.
int yzDakikaKelimeden(int kelime, bool en) {
  final dk = (kelime / (en ? kYzDakikadaKelimeEn : kYzDakikadaKelimeTr)).round();
  return dk < 1 ? 1 : dk;
}

/// Okuma süresi, dakika (en az 1).
int yzOkumaSuresi(String md, bool en) => yzDakikaKelimeden(yzKelimeSayisi(md), en);

String yzDakikaYazisi(int dk, bool en) => en ? '$dk min read' : '$dk dakikalık okuma';

String yzOkumaSuresiYazisi(String md, bool en) => yzDakikaYazisi(yzOkumaSuresi(md, en), en);

// ── Yazı boyu ────────────────────────────────────────────────────────────

/// Okurun seçebildiği yazı boyları (gövde metninin çarpanı). Telefonda sayfa
/// iki parmakla büyütülemiyor (`user-scalable=no`); okurun yolu bu.
const List<double> kYzYaziOlcekleri = [0.9, 1.0, 1.12, 1.25, 1.4];
const String _olcekAnahtari = 'yz_yazi_olcegi';

class YzYaziOlcegi extends StateNotifier<double> {
  YzYaziOlcegi() : super(1.0) {
    _yukle();
  }

  Future<void> _yukle() async {
    try {
      final p = await SharedPreferences.getInstance();
      final v = p.getDouble(_olcekAnahtari);
      if (v != null && kYzYaziOlcekleri.contains(v) && mounted) state = v;
    } catch (_) {
      // Depolama yoksa (gizli pencere, test) varsayılan boyda kalır.
    }
  }

  Future<void> _kaydet() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setDouble(_olcekAnahtari, state);
    } catch (_) {}
  }

  int get _sira => kYzYaziOlcekleri.indexOf(state).clamp(0, kYzYaziOlcekleri.length - 1);
  bool get buyuyebilir => _sira < kYzYaziOlcekleri.length - 1;
  bool get kuculebilir => _sira > 0;

  void buyut() {
    if (!buyuyebilir) return;
    state = kYzYaziOlcekleri[_sira + 1];
    _kaydet();
  }

  void kucult() {
    if (!kuculebilir) return;
    state = kYzYaziOlcekleri[_sira - 1];
    _kaydet();
  }

  void sifirla() {
    state = 1.0;
    _kaydet();
  }
}

final yzYaziOlcegiProvider =
    StateNotifierProvider<YzYaziOlcegi, double>((ref) => YzYaziOlcegi());

// ── Kaldığı yer ──────────────────────────────────────────────────────────

/// Okur bir terimin balonundan sözlüğe gidince başlıktaki kaydırma konumu
/// burada tutuluyor; başlığa dönünce (sözlüğün geri oku ya da tarayıcının
/// geri tuşu) sayfa o konumdan açılıyor. "Kaldığınız yer" bağlantısı
/// (merkez sayfa ve ana sayfa şeridi) metindeki konumu buraya bırakıyor
/// (madde 17): sayfa açılınca o paragrafa gidiliyor.
/// Tek kayıt: başka bir başlık açılınca düşüyor.
class YzOkumaKonumu {
  YzOkumaKonumu._();
  static String? _slug;
  static double? _konum;
  static double? _oran;
  static YzSonOkunan? _metin;

  static void _sifirla() {
    _slug = null;
    _konum = null;
    _oran = null;
    _metin = null;
  }

  static void kaydet(String slug, double konum) {
    _sifirla();
    _slug = slug;
    _konum = konum;
  }

  /// Konum sayfadaki oranıyla (0-1): sayfa açılınca o orana kaydırılır.
  static void kaydetOran(String slug, double oran) {
    _sifirla();
    _slug = slug;
    _oran = oran;
  }

  /// Konum metinde (madde 17): sayfa açılınca kayıttaki paragrafa gidilir.
  static void kaydetMetin(String slug, YzSonOkunan kayit) {
    _sifirla();
    _slug = slug;
    _metin = kayit;
  }

  /// [slug] için kayıtlı konumu (piksel) verir ve kaydı düşürür. Sözlük
  /// sayfası kaydı düşürmez (okur oradan dönecek).
  static double? al(String slug) => _al(slug)?.$1;

  /// Kayıt: (piksel, oran) — biri dolu. Okunduktan sonra düşer.
  static (double?, double?)? alHepsi(String slug) {
    final k = _al(slug);
    return k == null ? null : (k.$1, k.$2);
  }

  /// Kayıt: (piksel, oran, metindeki konum) — biri dolu. Okunduktan sonra düşer.
  static (double?, double?, YzSonOkunan?)? alTumu(String slug) => _al(slug);

  static (double?, double?, YzSonOkunan?)? _al(String slug) {
    if (slug == 'sozluk') return null;
    if (_slug != slug) {
      _sifirla();
      return null;
    }
    final k = (_konum, _oran, _metin);
    _sifirla();
    return k;
  }
}

/// Sayfaya nereden gelindiği (madde 24'teki `giris`): bağlantı, gitmeden
/// hemen önce işaretliyor; sayfa açılınca bir kez okunuyor. İşaret yoksa
/// ya da bayatsa `dis`.
class YzGiris {
  YzGiris._();
  static String? _giris;
  static DateTime? _zaman;

  /// merkez / serit / devam / arama / sozluk / komsu / bildirim.
  static void isaretle(String giris) {
    _giris = giris;
    _zaman = DateTime.now();
  }

  static String al() {
    final g = _giris;
    final z = _zaman;
    _giris = null;
    _zaman = null;
    if (g == null || z == null || DateTime.now().difference(z).inSeconds > 20) return 'dis';
    return g;
  }
}

// ── Okuma izi (karar 60; madde 17) ───────────────────────────────────────
// Okunan sayfalar ve son kalınan yer yalnız okurun tarayıcısında tutuluyor;
// hesap gerekmiyor. Kayıt sayfa boyuna değil METİNDEKİ konuma bağlı:
// dosyadaki paragrafın sırası ve ilk 24 harfinin özeti, alt başlığın sırası
// ve adı. "Okundu"nun tanımı yz_okuma_olcer.dart'ta (erteli pakette).

/// Başvuru sayfaları (sözlük, kaynakça): son okunan sayfanın yerine geçmez,
/// "Sırada" önerisine girmez.
const Set<String> kYzBasvuruSayfalari = {'sozluk', 'kaynakca'};

/// "Yarım": metnin en az bu kadarı geçilmiş ama okundu sayılmamış.
const double kYzYarimEsigi = 0.05;

/// "Kaldığınız yer" bu kadar gün geçerli.
const int kYzDevamGunu = 30;

const String _okunanAnahtari = 'yz_okunan';
const String _sonAnahtari = 'yz_son_okunan_m';

/// Eski (karar 60) kayıt: [yol, ad, sayfa oranı]. Yalnız yedek olarak okunur.
const String _eskiSonAnahtari = 'yz_son_okunan';

/// Son okunan sayfadaki konum (madde 17).
class YzSonOkunan {
  const YzSonOkunan({
    required this.yol,
    this.ad = '',
    this.oran = 0,
    this.paragraf = -1,
    this.ozet = '',
    this.altSira = -1,
    this.altAd = '',
    this.en = false,
    this.zaman,
    this.kendi = '',
    this.sure = 0,
    this.blokSayisi = 0,
  });

  /// Sayfanın adresi.
  final String yol;

  /// Sayfanın adı (kaydedildiği dilde).
  final String ad;

  /// Metnin geçilen kelime oranı, en derin nokta (0-1). Eski kayıtta sayfa oranı.
  final double oran;

  /// Okunan paragrafın dosyadaki sırası (`yzAyristir` bloğu); -1: bilinmiyor.
  final int paragraf;

  /// Paragrafın ilk 24 görünen harfinin özeti: metin değiştiyse tutmaz.
  final String ozet;

  /// Alt başlığın sırası (-1: ilk alt başlıktan önce) ve adı ([en] dilinde).
  final int altSira;
  final String altAd;
  final bool en;

  /// Kaydın zamanı; eski kayıtta yok.
  final DateTime? zaman;

  /// Okurun kendi kaydırmasıyla geçtiği bloklar: blok başına bir hane (0-9).
  final String kendi;

  /// Sayfada geçen aktif süre, saniye.
  final int sure;

  /// Kayıttaki metnin blok sayısı ([kendi] yalnız aynı metinde geçerli).
  final int blokSayisi;

  String get slug {
    final p = yol.split('/').where((x) => x.isNotEmpty).toList();
    return p.isEmpty ? '' : p.last;
  }

  bool get teknoloji => yol.contains('/teknoloji/');

  /// `YzOkumaKonumu` anahtarı: başlıkta adres, teknolojide `teknoloji-<kod>`.
  String get konumAnahtari => teknoloji ? 'teknoloji-$slug' : slug;

  bool get basvuru => !teknoloji && kYzBasvuruSayfalari.contains(slug);

  Map<String, Object?> toJson() => {
        'v': 1,
        'yol': yol,
        'ad': ad,
        'oran': double.parse(oran.toStringAsFixed(4)),
        'p': paragraf,
        'oz': ozet,
        'as': altSira,
        'aa': altAd,
        'dil': en ? 'en' : 'tr',
        'z': zaman?.millisecondsSinceEpoch,
        'k': kendi,
        's': sure,
        'b': blokSayisi,
      };

  static YzSonOkunan? fromJson(Object? j) {
    if (j is! Map) return null;
    final yol = j['yol'];
    if (yol is! String || yol.isEmpty) return null;
    final z = j['z'];
    return YzSonOkunan(
      yol: yol,
      ad: j['ad'] is String ? j['ad'] as String : '',
      oran: j['oran'] is num ? (j['oran'] as num).toDouble().clamp(0.0, 1.0) : 0,
      paragraf: j['p'] is int ? j['p'] as int : -1,
      ozet: j['oz'] is String ? j['oz'] as String : '',
      altSira: j['as'] is int ? j['as'] as int : -1,
      altAd: j['aa'] is String ? j['aa'] as String : '',
      en: j['dil'] == 'en',
      zaman: z is int ? DateTime.fromMillisecondsSinceEpoch(z) : null,
      kendi: j['k'] is String ? j['k'] as String : '',
      sure: j['s'] is int ? j['s'] as int : 0,
      blokSayisi: j['b'] is int ? j['b'] as int : 0,
    );
  }
}

class YzOkumaIzi {
  const YzOkumaIzi({this.okunan = const {}, this.son});

  /// Okunan sayfaların adresleri.
  final Set<String> okunan;

  /// Son okunan sayfa ve metindeki konum.
  final YzSonOkunan? son;

  String? get sonYol => son?.yol;
  String? get sonAd => son?.ad;
  double get sonOran => son?.oran ?? 0;

  /// Yarıda bırakılmış son sayfa varsa: metnin %5'i geçilmiş, okundu değil.
  bool get yarimKaldi {
    final s = son;
    return s != null && s.oran > kYzYarimEsigi && !okunan.contains(s.yol);
  }
}

class YzOkumaIziDenetcisi extends StateNotifier<YzOkumaIzi> {
  YzOkumaIziDenetcisi() : super(const YzOkumaIzi()) {
    _yukle();
  }

  bool _yuklendi = false;

  /// Yükleme bitmeden gelen değişiklikler kaybolmasın.
  bool _degisti = false;

  Future<void> _yukle() async {
    try {
      final p = await SharedPreferences.getInstance();
      final okunan = p.getStringList(_okunanAnahtari) ?? const <String>[];
      YzSonOkunan? son;
      final yeni = p.getString(_sonAnahtari);
      if (yeni != null) {
        try {
          son = YzSonOkunan.fromJson(jsonDecode(yeni));
        } catch (_) {}
      }
      if (son == null) {
        // Eski kayıt (karar 60): yalnız yedek. Konum sayfa oranıyla.
        final eski = p.getStringList(_eskiSonAnahtari);
        if (eski != null && eski.length == 3 && eski[0].isNotEmpty) {
          son = YzSonOkunan(
            yol: eski[0],
            ad: eski[1],
            oran: (double.tryParse(eski[2]) ?? 0).clamp(0.0, 1.0),
          );
        }
      }
      if (!mounted) return;
      state = YzOkumaIzi(
        okunan: {...okunan, ...state.okunan},
        son: _degisti ? state.son : son,
      );
    } catch (_) {
    } finally {
      _yuklendi = true;
      if (_degisti) _kaydet();
    }
  }

  Future<void> _kaydet() async {
    if (!_yuklendi) return;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(_okunanAnahtari, state.okunan.toList()..sort());
      final son = state.son;
      if (son != null) await p.setString(_sonAnahtari, jsonEncode(son.toJson()));
    } catch (_) {}
  }

  /// Şu anki iz (dinlemeden okumak için).
  YzOkumaIzi get simdiki => state;

  /// Okurun son konumu. Başvuru sayfaları (sözlük, kaynakça) son okunan
  /// sayfanın yerine geçmez.
  void konum(YzSonOkunan son) {
    if (son.basvuru) return;
    _degisti = true;
    state = YzOkumaIzi(okunan: state.okunan, son: son);
    _kaydet();
  }

  /// [yol] okundu (tanım: yz_okuma_olcer.dart).
  void okundu(String yol) {
    if (state.okunan.contains(yol)) return;
    _degisti = true;
    state = YzOkumaIzi(okunan: {...state.okunan, yol}, son: state.son);
    _kaydet();
  }
}

final yzOkumaIziProvider =
    StateNotifierProvider<YzOkumaIziDenetcisi, YzOkumaIzi>((ref) => YzOkumaIziDenetcisi());

// ── Kaldığınız yer ve sırada (madde 18, 20) ──────────────────────────────
// Ana sayfa şeridi ve merkezdeki yön satırı aynı yardımcıyı kullanıyor.

String _baslikYolu(String slug) => '$kYzAdres/$slug';

/// "Kaldığınız yer" satırının bilgisi (kayıt — eşitlik yapısal, `select`
/// yalnız bu alanlar değişince yeniden kuruyor).
typedef YzDevamBilgisi = ({String yol, String baslik, String? altBaslik});

/// Yarım kalmış, son [kYzDevamGunu] gün içinde okunmuş ve başvuru sayfası
/// olmayan son sayfa; yoksa null. Başlık adı iskeletten (okurun dilinde),
/// alt başlık kayıttan — yalnız aynı dilde okunduysa.
YzDevamBilgisi? yzDevam(YzOkumaIzi iz, {required bool en, DateTime? simdi}) {
  final s = iz.son;
  if (s == null || !iz.yarimKaldi || s.basvuru) return null;
  final z = s.zaman;
  if (z != null && (simdi ?? DateTime.now()).difference(z).inDays >= kYzDevamGunu) return null;
  String? ad;
  if (s.teknoloji) {
    ad = kYzTeknoloji[s.slug]?[en ? 'en' : 'tr'];
  } else {
    for (final b in kYzBasliklar) {
      if (_baslikYolu(b.slug) == s.yol) ad = b.ad(en);
    }
  }
  ad ??= s.ad;
  if (ad.isEmpty) return null;
  final alt = s.en == en && s.altAd.isNotEmpty ? s.altAd : null;
  return (yol: s.yol, baslik: ad, altBaslik: alt);
}

/// "Kaldığınız yer"e dokununca: konumu ve girişi bırakır, gidilecek adresi
/// verir (yoksa null).
String? yzDevamHazirla(YzOkumaIzi iz, String giris) {
  final s = iz.son;
  if (s == null) return null;
  if (s.paragraf >= 0 || s.altSira >= 0) {
    YzOkumaKonumu.kaydetMetin(s.konumAnahtari, s);
  } else {
    // Eski kayıt: yalnız oran var.
    YzOkumaKonumu.kaydetOran(s.konumAnahtari, s.oran);
  }
  YzGiris.isaretle(giris);
  return s.yol;
}

/// Slug'ı verilen başlık; yoksa null.
YzBaslik? yzBaslikSlugla(String? slug) {
  if (slug == null) return null;
  for (final b in kYzBasliklar) {
    if (b.slug == slug) return b;
  }
  return null;
}

/// Başlığın okuma süresi (dakika), önceden hesaplanmış (madde 31); yoksa null.
int? yzBaslikDakikasi(int no, bool en) => kYzOkumaDakikalari[no]?[en ? 1 : 0];

// ── Bir kez ipucu (karar 60) ─────────────────────────────────────────────
// Rakamlardaki noktalı çizgi kalktı: mavi rakamın dokunulabildiğini okura
// bir kez söyleyen ipucu. null: henüz bilinmiyor (gösterilmez).

const String _ipucuAnahtari = 'yz_ipucu_goruldu';

class YzIpucu extends StateNotifier<bool?> {
  YzIpucu() : super(null) {
    _yukle();
  }

  Future<void> _yukle() async {
    try {
      final p = await SharedPreferences.getInstance();
      if (mounted) state = p.getBool(_ipucuAnahtari) ?? false;
    } catch (_) {
      if (mounted) state = false;
    }
  }

  Future<void> kapat() async {
    state = true;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_ipucuAnahtari, true);
    } catch (_) {}
  }
}

/// true: ipucu görüldü; false: gösterilecek; null: henüz yüklenmedi.
final yzIpucuProvider = StateNotifierProvider<YzIpucu, bool?>((ref) => YzIpucu());

// ── Arama ────────────────────────────────────────────────────────────────

const Map<String, String> _katlama = {
  'ç': 'c', 'ğ': 'g', 'ı': 'i', 'ö': 'o', 'ş': 's', 'ü': 'u',
  'â': 'a', 'î': 'i', 'û': 'u', 'é': 'e', 'è': 'e', 'á': 'a', 'à': 'a',
  'ó': 'o', 'ò': 'o', 'í': 'i', 'ñ': 'n', 'ã': 'a', 'õ': 'o', 'ä': 'a',
};

/// Aramanın karşılaştırdığı biçim: küçük harf (Türkçe kurallarla) ve
/// aksansız ("Çiftçi" → "ciftci", "TARSİM" → "tarsim"). Uzunluğu koruyor:
/// eşleşmenin konumu özgün metinde de aynı.
String yzAramaKatla(String s, bool en) {
  final b = StringBuffer();
  for (final c in s.split('')) {
    String k;
    if (c == 'I') {
      k = en ? 'i' : 'ı';
    } else if (c == 'İ') {
      k = 'i';
    } else {
      final l = c.toLowerCase();
      k = l.length == 1 ? l : c;
    }
    b.write(_katlama[k] ?? k);
  }
  return b.toString();
}

/// Sorgunun kelimeleri (katlanmış). İki harften kısa kelime atılıyor.
List<String> yzAramaKelimeleri(String sorgu, bool en) => [
      for (final k in yzAramaKatla(sorgu.trim(), en).split(RegExp(r'\s+')))
        if (k.length >= 2) k,
    ];

/// Blokta sorgunun bütün kelimeleri geçiyor mu.
bool yzAramaGeciyor(String metin, List<String> kelimeler, bool en) {
  if (kelimeler.isEmpty) return false;
  final k = yzAramaKatla(metin, en);
  return kelimeler.every(k.contains);
}

/// Kelimelerin metindeki bütün geçişleri [bas, son); çakışanlar birleşik.
List<(int, int)> yzAramaAraliklari(String metin, List<String> kelimeler, bool en) {
  if (kelimeler.isEmpty) return const [];
  final k = yzAramaKatla(metin, en);
  final ham = <(int, int)>[];
  for (final w in kelimeler) {
    var i = k.indexOf(w);
    while (i >= 0) {
      ham.add((i, i + w.length));
      i = k.indexOf(w, i + w.length);
    }
  }
  ham.sort((a, b) => a.$1.compareTo(b.$1));
  final cikti = <(int, int)>[];
  for (final a in ham) {
    if (cikti.isNotEmpty && a.$1 <= cikti.last.$2) {
      final son = cikti.removeLast();
      cikti.add((son.$1, a.$2 > son.$2 ? a.$2 : son.$2));
    } else {
      cikti.add(a);
    }
  }
  return cikti;
}

// ── Sıradaki başlık (madde 20) ───────────────────────────────────────────
/// [mevcut] başlığı bitiren okura önerilecek sıradaki başlığın slug'ı:
/// [mevcut]tan sonraki ilk okunmamış başlık (sona varınca baştan), başvuru
/// sayfası (sözlük, kaynakça) değil. [okunanYollar] sayfa adresleri (slug da
/// kabul). null: okunmamış başlık yok; çağıran sıradaki numaralı başlığa düşer.
String? yzSiradakiSlug(Set<String> okunanYollar, String mevcut) {
  final adaylar = [
    for (final b in kYzBasliklar)
      if (b.yazildi && !kYzBasvuruSayfalari.contains(b.slug)) b.slug,
  ];
  if (adaylar.isEmpty) return null;
  bool okundu(String s) => okunanYollar.contains(_baslikYolu(s)) || okunanYollar.contains(s);
  final i = adaylar.indexOf(mevcut);
  for (var k = 1; k <= adaylar.length; k++) {
    final s = adaylar[(i + k) % adaylar.length];
    if (s != mevcut && !okundu(s)) return s;
  }
  return null;
}
