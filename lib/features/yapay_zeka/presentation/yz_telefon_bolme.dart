import 'dart:math' as math;

/// Telefonda uzun paragrafın YALNIZ GÖRÜNÜMDE cümle sonundan bölünmesi
/// (madde 2) ve giriş paragrafının kısa ilk parçası (madde 4).
///
/// Saf Dart: Flutter'a bağlı değil. Python ikizi
/// `content/yapay_zeka_dijital_tarim/_raw/telefon_bolme.py`; kural orada
/// ayrıntılı yazılı. İkisi aynı noktaları bulmak zorunda —
/// `test/yz_telefon_bolme_test.dart` Python'un ürettiği fikstürle
/// (`test/veri/yz_telefon_bolme.json`) karşılaştırıyor. Biri değişirse öbürü
/// de değişir ve fikstür yeniden üretilir.
///
/// Metin AYNEN kalır: parçalar birleşince (aralarına tek boşlukla) paragraf
/// dosyadakiyle bayt bayt aynı.

const double kYzBolmeTabanGenislik = 343;
const double _tabanEsik = 560;
const double _tabanEnAz = 180;
const double _altSinir = 120;
const double _girisTaban = 220;

/// Bölmenin kapalı olduğu başlıklar: Sözlük (§29) ve Kaynakça (§30).
const Set<int> kYzBolmesizBasliklar = {29, 30};

const String _buyuk = 'ABCDEFGHIJKLMNOPQRSTUVWXYZÇĞİÖŞÜÂÎÛ';
const String _noktalama = '.!?…';
const String _kapanis = '”"’)';
const String _atlanan = '*“"\'‘(«[';
const String _basTemiz = '(“"*\'‘';

const Set<String> _kisaltmalar = {
  'ör', 'vb', 'vs', 'bkz', 'Dr', 'Prof', 'Doç', 'yy', 'St', 'No', 'Av', 'Yrd', //
  'Öğr', 'Gör', 'Arş', 'Ltd', 'Şti', 'A.Ş', 'AŞ', 'Bşk', 'Md', 'Müd', 'çev', //
  'haz', 'yay', 's', 'ss', 'c', 'vd', 'Tel', 'Mah', 'Cad', 'Sok', 'Inc', 'Co', //
  'Corp', 'Jr', 'Sr', 'Mr', 'Ms', 'Mrs', 'Fig', 'vol', 'al', 'approx', 'e.g', //
  'i.e', 'etc', 'cf', 'U.S', 'U.K', 'U.N', 'Mt', 'Ave', 'Univ', 'Dept', //
  'est', 'ca', 'no', 'Nos', 'pp', 'p', 'Eq', 'Ref', 'viz', 'Gen', 'Col', //
  'Gov', 'Sen', 'Rep',
};

final RegExp _onceki = RegExp(r'(\S+)$');
final RegExp _roma = RegExp(r'^[IVX]{1,5}$');
final RegExp _basHarf = RegExp(r'^[A-ZÇĞİÖŞÜ]$');
final RegExp _noktali = RegExp(r'^(?:[A-Za-z]\.)+[A-Za-z]$');
final RegExp _sayi = RegExp(r'^\d{1,4}$');

/// Okurun gördüğü harf sayısı: `*` sayılmaz, uçtaki boşluk sayılmaz.
int yzGorunenUzunluk(String metin) {
  final t = metin.trim();
  var n = 0;
  for (var i = 0; i < t.length; i++) {
    if (t.codeUnitAt(i) != 0x2A) n++;
  }
  return n;
}

bool _buyukMu(String c) => c.isNotEmpty && _buyuk.contains(c);
bool _rakamMi(String c) => c.isNotEmpty && c.codeUnitAt(0) >= 0x30 && c.codeUnitAt(0) <= 0x39;

String _solTemizle(String s) {
  var i = 0;
  while (i < s.length && _basTemiz.contains(s[i])) {
    i++;
  }
  return s.substring(i);
}

String _sagNoktaTemizle(String s) {
  var i = s.length;
  while (i > 0 && s[i - 1] == '.') {
    i--;
  }
  return s.substring(0, i);
}

/// Cümle sınırları: bir sonraki cümlenin ilk karakterinin konumu.
List<int> yzCumleSinirlari(String metin, {bool en = false}) {
  final sinirlar = <int>[];
  var par = 0;
  var tirnak = false;
  var kalin = false;
  final n = metin.length;
  var i = 0;
  while (i < n) {
    if (metin.startsWith('**', i)) {
      kalin = !kalin;
      i += 2;
      continue;
    }
    final c = metin[i];
    if (c == '(') {
      par++;
    } else if (c == ')') {
      par = math.max(0, par - 1);
    } else if (c == '“') {
      tirnak = true;
    } else if (c == '”') {
      tirnak = false;
    } else if (c == '"') {
      tirnak = !tirnak;
    }
    if (_noktalama.contains(c) && par == 0 && !tirnak && !kalin) {
      var son = i + 1;
      while (son < n && _noktalama.contains(metin[son])) {
        son++;
      }
      var j = son;
      while (j < n && (_kapanis.contains(metin[j]) || metin.startsWith('**', j))) {
        j += metin.startsWith('**', j) ? 2 : 1;
      }
      if (j < n && metin[j] == ' ') {
        var k = j;
        while (k < n && metin[k] == ' ') {
          k++;
        }
        var a = k;
        while (a < n && _atlanan.contains(metin[a])) {
          a++;
        }
        final ilk = a < n ? metin[a] : '';
        if (_buyukMu(ilk) || _rakamMi(ilk) || ilk == '%') {
          final m = _onceki.firstMatch(metin.substring(0, i));
          final onceki = _solTemizle(m?.group(1) ?? '');
          var kisaltma = false;
          if (c == '.') {
            if (_kisaltmalar.contains(onceki) || _kisaltmalar.contains(_sagNoktaTemizle(onceki))) {
              kisaltma = true;
            } else if (!en && _roma.hasMatch(onceki)) {
              kisaltma = true; // "IV. Tarım Orman Şûrası"
            } else if (_basHarf.hasMatch(onceki) && !(en && onceki == 'I')) {
              kisaltma = true; // baş harf ("J. Smith"); İngilizcede "Annex I." sınır
            } else if (_noktali.hasMatch(onceki)) {
              kisaltma = true; // U.S, e.g
            } else if (!en && _sayi.hasMatch(onceki) && _buyukMu(ilk)) {
              kisaltma = true; // sıra sayısı: "2. Dünya Savaşı"
            }
          }
          if (!kisaltma) sinirlar.add(k);
        }
      }
      // Kapanışlar ana döngüde işlensin (** durumunu doğru çevirsin).
      i = son;
      continue;
    }
    i++;
  }
  return sinirlar;
}

/// Eşik E = 560 × (W/343) / s² görünen harf.
double yzBolmeEsigi(double genislik, double s) => _tabanEsik * (genislik / kYzBolmeTabanGenislik) / (s * s);

/// En küçük parça M = max(120, 180/s).
double yzEnAzParca(double s) => math.max(_altSinir, _tabanEnAz / s);

/// Giriş paragrafının ilk parçası en çok G = 220 × (W/343) / s harf
/// (giriş puntosunda ~6 satır).
double yzGirisSiniri(double genislik, double s) => _girisTaban * (genislik / kYzBolmeTabanGenislik) / s;

/// [bas, son) aralığının gövde kuralıyla bölme noktaları (mutlak konum).
List<int> yzBolmeNoktalari(String metin, double esik, double enAz, {bool en = false, int bas = 0, int? son}) {
  final bitis = son ?? metin.length;
  final parca = metin.substring(bas, bitis);
  if (yzGorunenUzunluk(parca) <= esik) return const [];
  int? enIyi;
  int? enIyiFark;
  for (final k in yzCumleSinirlari(parca, en: en)) {
    final sol = yzGorunenUzunluk(parca.substring(0, k));
    final sag = yzGorunenUzunluk(parca.substring(k));
    if (sol < enAz || sag < enAz) continue;
    final fark = (sol - sag).abs();
    if (enIyiFark == null || fark < enIyiFark) {
      enIyi = k;
      enIyiFark = fark;
    }
  }
  if (enIyi == null) return const [];
  final mutlak = bas + enIyi;
  return [
    ...yzBolmeNoktalari(metin, esik, enAz, en: en, bas: bas, son: mutlak),
    mutlak,
    ...yzBolmeNoktalari(metin, esik, enAz, en: en, bas: mutlak, son: bitis),
  ];
}

/// Giriş paragrafının ilk parçasının bittiği yer; bölünmüyorsa null.
int? yzGirisNoktasi(String metin, double sinir, double enAz, {bool en = false}) {
  if (yzGorunenUzunluk(metin) <= sinir) return null;
  final adaylar = [
    for (final k in yzCumleSinirlari(metin, en: en))
      if (yzGorunenUzunluk(metin.substring(k)) >= enAz) k,
  ];
  if (adaylar.isEmpty) return null;
  final sigan = [
    for (final k in adaylar)
      if (yzGorunenUzunluk(metin.substring(0, k)) <= sinir) k,
  ];
  return sigan.isNotEmpty ? sigan.last : adaylar.first;
}

/// Çizicinin kullandığı bütün bölme noktaları (artan sırada).
/// [genislik]: metin sütununun genişliği; [s]: etkin ölçek (sistem yazı
/// büyütmesi × okurun yazı boyu).
List<int> yzTelefonNoktalari(String metin,
    {required double genislik, required double s, bool giris = false, bool en = false}) {
  final e = yzBolmeEsigi(genislik, s);
  final m = yzEnAzParca(s);
  if (giris) {
    final k = yzGirisNoktasi(metin, yzGirisSiniri(genislik, s), m, en: en);
    if (k == null) return const [];
    return [k, ...yzBolmeNoktalari(metin, e, m, en: en, bas: k)];
  }
  return yzBolmeNoktalari(metin, e, m, en: en);
}

/// Parçaların ham metindeki aralıkları: [bas, son), uçtaki boşluklar dışarıda.
List<(int, int)> yzParcaAraliklari(String metin, List<int> noktalar) {
  final sinir = [0, ...noktalar, metin.length];
  final cikti = <(int, int)>[];
  for (var i = 0; i + 1 < sinir.length; i++) {
    var a = sinir[i], b = sinir[i + 1];
    while (a < b && metin.codeUnitAt(a) == 0x20) {
      a++;
    }
    while (b > a && metin.codeUnitAt(b - 1) == 0x20) {
      b--;
    }
    cikti.add((a, b));
  }
  return cikti;
}
