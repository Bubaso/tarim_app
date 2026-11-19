import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

/// Okuma süresi, dakika (en az 1).
int yzOkumaSuresi(String md, bool en) {
  final dk = (yzKelimeSayisi(md) / (en ? kYzDakikadaKelimeEn : kYzDakikadaKelimeTr)).round();
  return dk < 1 ? 1 : dk;
}

String yzOkumaSuresiYazisi(String md, bool en) {
  final dk = yzOkumaSuresi(md, en);
  return en ? '$dk min read' : '$dk dakikalık okuma';
}

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
/// geri tuşu) sayfa o konumdan açılıyor. Merkez sayfadaki "Kaldığınız yer"
/// bağlantısı da konumu sayfadaki oranıyla buraya bırakıyor (karar 60).
/// Tek kayıt: başka bir başlık açılınca düşüyor.
class YzOkumaKonumu {
  YzOkumaKonumu._();
  static String? _slug;
  static double? _konum;
  static double? _oran;

  static void kaydet(String slug, double konum) {
    _slug = slug;
    _konum = konum;
    _oran = null;
  }

  /// Konum sayfadaki oranıyla (0-1): sayfa açılınca o orana kaydırılır.
  static void kaydetOran(String slug, double oran) {
    _slug = slug;
    _konum = null;
    _oran = oran;
  }

  /// [slug] için kayıtlı konumu (piksel) verir ve kaydı düşürür. Sözlük
  /// sayfası kaydı düşürmez (okur oradan dönecek).
  static double? al(String slug) => _al(slug)?.$1;

  /// Kayıt: (piksel, oran) — biri dolu. Okunduktan sonra düşer.
  static (double?, double?)? alHepsi(String slug) => _al(slug);

  static (double?, double?)? _al(String slug) {
    if (slug == 'sozluk') return null;
    if (_slug != slug) {
      _slug = null;
      _konum = null;
      _oran = null;
      return null;
    }
    final k = (_konum, _oran);
    _slug = null;
    _konum = null;
    _oran = null;
    return k;
  }
}

// ── Okuma izi (karar 60) ─────────────────────────────────────────────────
// Okunan sayfalar ve son kalınan yer yalnız okurun tarayıcısında tutuluyor;
// hesap gerekmiyor. Sayfanın %80'i geçilince okundu sayılıyor.

const double kYzOkunduEsigi = 0.8;
const String _okunanAnahtari = 'yz_okunan';
const String _sonAnahtari = 'yz_son_okunan';

class YzOkumaIzi {
  const YzOkumaIzi({this.okunan = const {}, this.sonYol, this.sonAd, this.sonOran = 0});

  /// Okunan sayfaların adresleri.
  final Set<String> okunan;
  final String? sonYol;
  final String? sonAd;
  final double sonOran;

  /// Yarıda bırakılmış son sayfa varsa.
  bool get yarimKaldi => sonYol != null && sonOran > 0.05 && sonOran < kYzOkunduEsigi;
}

class YzOkumaIziDenetcisi extends StateNotifier<YzOkumaIzi> {
  YzOkumaIziDenetcisi() : super(const YzOkumaIzi()) {
    _yukle();
  }

  Future<void> _yukle() async {
    try {
      final p = await SharedPreferences.getInstance();
      final okunan = p.getStringList(_okunanAnahtari) ?? const <String>[];
      final son = p.getStringList(_sonAnahtari);
      if (!mounted) return;
      state = YzOkumaIzi(
        okunan: {...okunan},
        sonYol: son != null && son.length == 3 ? son[0] : null,
        sonAd: son != null && son.length == 3 ? son[1] : null,
        sonOran: son != null && son.length == 3 ? (double.tryParse(son[2]) ?? 0) : 0,
      );
    } catch (_) {}
  }

  Future<void> _kaydet() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(_okunanAnahtari, state.okunan.toList()..sort());
      if (state.sonYol != null) {
        await p.setStringList(
            _sonAnahtari, [state.sonYol!, state.sonAd ?? '', state.sonOran.toStringAsFixed(3)]);
      }
    } catch (_) {}
  }

  /// Okur [yol] sayfasında [oran] kadar ilerledi.
  void ilerle(String yol, String ad, double oran) {
    final o = oran.clamp(0.0, 1.0).toDouble();
    final okundu = o >= kYzOkunduEsigi && !state.okunan.contains(yol);
    final kayda = state.sonYol != yol || (state.sonOran - o).abs() >= 0.04;
    if (!okundu && !kayda) return;
    state = YzOkumaIzi(
      okunan: okundu ? {...state.okunan, yol} : state.okunan,
      sonYol: yol,
      sonAd: ad,
      sonOran: o,
    );
    _kaydet();
  }
}

final yzOkumaIziProvider =
    StateNotifierProvider<YzOkumaIziDenetcisi, YzOkumaIzi>((ref) => YzOkumaIziDenetcisi());

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

// ── Sıradaki başlık (KALIP) ──────────────────────────────────────────────
/// [mevcut] başlığı bitiren okura önerilecek sıradaki başlığın slug'ı:
/// okunmamış ilk sonraki, başvuru sayfası (sözlük, kaynakça) değil.
/// null: öneri yok; çağıran sıradaki numaralı başlığa düşer.
String? yzSiradakiSlug(Set<String> okunanYollar, String mevcut) => null;
