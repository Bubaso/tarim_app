import '../../../core/utils/turkce_metin.dart';
import '../data/yz_iskelet.g.dart';
import 'yz_metin_gorunumu.dart';

/// Teknolojinin metindeki izi (karar 57).
///
/// Merkez sayfada bir teknoloji seçilince başlık sayfası o teknolojinin
/// geçtiği paragrafları (ve tablo satırlarını) işaretliyor. Desenler ve
/// kurallar `content/yapay_zeka_dijital_tarim/_raw/teknoloji_izi.py`'de;
/// buradaki eşleştirici onun birebir karşılığı. Başlıkların teknoloji
/// etiketleri de aynı sayımdan çıkıyor: Python'un her başlıkta saydığı
/// blok sayısı `kYzTeknolojiIzi`'de, eşlik testi Dart'ın aynı sayıyı
/// bulduğunu sınıyor (`yz_bolum_test.dart`).
///
/// Kurallar: küçük harfli desen kelime başında ve harf büyüklüğüne
/// duyarsız (Türkçe küçültme), `=` önekli desen duyarlı; `haric`
/// desenlerinin içine düşen geçiş sayılmıyor; kalın parça (`**…**`) yok
/// sayılıyor.

final RegExp _harfVeRakam = RegExp(r'[\p{L}\p{N}]', unicode: true);
final RegExp _kalin = RegExp(r'\*\*.+?\*\*');

String _kucult(String s, bool en) =>
    en ? s.replaceAll('İ', 'i').toLowerCase() : kucukHarf(s, false);

List<(int, int)> _gecisler(String metin, List<String> desenler, bool en) {
  final kucuk = _kucult(metin, en);
  final cikti = <(int, int)>[];
  for (final d in desenler) {
    final esit = d.startsWith('=');
    final hedef = esit ? d.substring(1) : _kucult(d, en);
    final kaynak = esit ? metin : kucuk;
    if (hedef.isEmpty) continue;
    var i = kaynak.indexOf(hedef);
    while (i >= 0) {
      if (!(i > 0 && _harfVeRakam.hasMatch(kaynak[i - 1]))) {
        cikti.add((i, i + hedef.length));
      }
      // re.finditer gibi örtüşmeyen arama: bir sonraki arama eşleşmenin sonundan.
      i = kaynak.indexOf(hedef, i + hedef.length);
    }
  }
  return cikti;
}

/// Blokta (paragraf ya da tablo satırı) teknolojinin sayılan bir geçişi var mı.
bool yzTeknolojiGeciyor(String blok, String kod, bool en) {
  final t = kYzTeknolojiDesen[kod];
  if (t == null) return false;
  final dil = en ? 'en' : 'tr';
  final metin = blok.replaceAllMapped(_kalin, (m) => ' ' * m[0]!.length);
  final haric = _gecisler(metin, t['haric_$dil'] ?? const [], en);
  for (final (a, b) in _gecisler(metin, t['desen_$dil'] ?? const [], en)) {
    if (!haric.any((h) => h.$1 <= a && b <= h.$2)) return true;
  }
  return false;
}

/// Tablo satırının eşleştiricinin gördüğü metni: Python satırın kendisini
/// ("| a | b |") okuyor; ayraç karakteri harf olmadığı için hücreleri " | "
/// ile birleştirmek aynı sonucu veriyor.
String yzTabloSatiri(List<String> hucreler) => '| ${hucreler.join(' | ')} |';

/// Bir metinde teknolojinin geçtiği blok sayısı (paragraflar, listeler,
/// tablo satırları) — Python'daki `teknoloji_izi.iz()` sayımının karşılığı.
int yzTeknolojiSay(String md, String kod, bool en) {
  var n = 0;
  for (final b in yzAyristir(md)) {
    if (b.tur == YzBlokTuru.paragraf || b.tur == YzBlokTuru.ozet) {
      if (yzTeknolojiGeciyor(b.metin, kod, en)) n++;
    } else if (b.tur == YzBlokTuru.liste) {
      // Python listeyi tek blok sayıyor (satırlar boşlukla birleşik).
      if (yzTeknolojiGeciyor(yzListeMetni(b.ogeler), kod, en)) n++;
    } else if (b.tur == YzBlokTuru.tablo) {
      for (final s in b.satirlar) {
        if (yzTeknolojiGeciyor(yzTabloSatiri(s), kod, en)) n++;
      }
    }
  }
  return n;
}

/// Geçerli bir teknoloji kodu mu (adres parametresi okurdan geliyor).
bool yzTeknolojiVar(String? kod) => kod != null && kYzTeknolojiDesen.containsKey(kod);
