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
/// geri tuşu) sayfa o konumdan açılıyor. Tek kayıt: başka bir başlık
/// açılınca düşüyor.
class YzOkumaKonumu {
  YzOkumaKonumu._();
  static String? _slug;
  static double? _konum;

  static void kaydet(String slug, double konum) {
    _slug = slug;
    _konum = konum;
  }

  /// [slug] için kayıtlı konumu verir ve kaydı düşürür. Sözlük sayfası
  /// kaydı düşürmez (okur oradan dönecek).
  static double? al(String slug) {
    if (slug == 'sozluk') return null;
    if (_slug != slug) {
      _slug = null;
      _konum = null;
      return null;
    }
    final k = _konum;
    _slug = null;
    _konum = null;
    return k;
  }
}

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
