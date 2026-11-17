/// Grafik verisinin biçimi (karar 58).
///
/// Grafiklerin kendisi `content/yapay_zeka_dijital_tarim/_raw/grafikler.json`'da;
/// her değer bir kaydın sayısal alanına bağlı ve `dogrula_bolumler.py`
/// (kural 11) değeri o alanla karşılaştırıyor. `dart_uret.py` bunları
/// `yz_grafikler.g.dart`'a gömüyor. Metinde grafiğin yeri bir yönerge satırı:
/// `[[grafik:<kimlik>]]` (çizici: `yz_metin_gorunumu.dart`).
library;

class YzGrafikDizi {
  const YzGrafikDizi(this.kod, this.tr, this.en);
  final String kod;
  final String tr;
  final String en;
  String ad(bool isEn) => isEn ? en : tr;
}

class YzGrafikNokta {
  const YzGrafikNokta(this.kategoriTr, this.kategoriEn, this.dizi, this.deger, [this.uc = '']);
  final String kategoriTr;
  final String kategoriEn;
  final String dizi;
  final double deger;

  /// Aralıkta 'alt' ya da 'ust'; öbür türlerde boş.
  final String uc;

  String kategori(bool isEn) => isEn ? kategoriEn : kategoriTr;
}

class YzGrafik {
  const YzGrafik({
    required this.kimlik,
    required this.tur,
    required this.baslikTr,
    required this.baslikEn,
    required this.aciklamaTr,
    required this.aciklamaEn,
    required this.kaynakTr,
    required this.kaynakEn,
    this.birimTr = '',
    this.birimEn = '',
    this.diziler = const [],
    this.noktalar = const [],
    this.satici = false,
  });

  final String kimlik;

  /// yatay_cubuk · dikey_cubuk · cizgi · alan · dumbbell · aralik · pay ·
  /// waffle · egim · kpi · isi · zaman
  final String tur;
  final String baslikTr, baslikEn;
  final String aciklamaTr, aciklamaEn;
  final String kaynakTr, kaynakEn;
  final String birimTr, birimEn;
  final List<YzGrafikDizi> diziler;
  final List<YzGrafikNokta> noktalar;

  /// Değerlerden biri şirketin kendi beyanı (karar 34): kartta yazar.
  final bool satici;

  String baslik(bool en) => en ? baslikEn : baslikTr;
  String aciklama(bool en) => en ? aciklamaEn : aciklamaTr;
  String kaynak(bool en) => en ? kaynakEn : kaynakTr;
  String birim(bool en) => en ? birimEn : birimTr;

  /// Kategoriler, ilk göründükleri sırayla.
  List<String> kategoriler(bool en) {
    final c = <String>[];
    for (final n in noktalar) {
      final k = n.kategori(en);
      if (!c.contains(k)) c.add(k);
    }
    return c;
  }

  /// Dizi adı (yoksa kodu).
  String diziAdi(String kod, bool en) {
    for (final d in diziler) {
      if (d.kod == kod) return d.ad(en);
    }
    return kod;
  }
}

/// Sayıyı dile göre yazar: TR 1.234,5 · EN 1,234.5. Ondalık basamak sayısı
/// değerin kendisinden (kayıttaki gibi) — 99,35 99,35 kalır, 7 7.
String yzSayi(double v, bool en) {
  final negatif = v < 0;
  var s = v.abs().toString();
  if (s.endsWith('.0')) s = s.substring(0, s.length - 2);
  final parca = s.split('.');
  final tam = parca[0];
  final ondalik = parca.length > 1 ? parca[1] : '';
  final buf = StringBuffer();
  for (var i = 0; i < tam.length; i++) {
    if (i > 0 && (tam.length - i) % 3 == 0) buf.write(en ? ',' : '.');
    buf.write(tam[i]);
  }
  final sonuc = ondalik.isEmpty ? buf.toString() : '$buf${en ? '.' : ','}$ondalik';
  return negatif ? '-$sonuc' : sonuc;
}

/// Değer ve birim: TR "%35", EN "35%"; öbür birimler sonra ("4,5 ton").
String yzDeger(double v, String birim, bool en) {
  final s = yzSayi(v, en);
  if (birim == '%') return en ? '$s%' : '%$s';
  return birim.isEmpty ? s : '$s $birim';
}

/// Görsel (karar 58): dosya `web/yz/gorsel/` altında, sitenin kendisinden
/// sunuluyor. Altyazı künyedir (görselin ne olduğu); kaynak satırı ayrı.
class YzGorsel {
  const YzGorsel({
    required this.kimlik,
    required this.adres,
    required this.genislik,
    required this.yukseklik,
    required this.kunyeTr,
    required this.kunyeEn,
    required this.kaynakTr,
    required this.kaynakEn,
    this.yapayZeka = false,
  });

  final String kimlik;

  /// Sitedeki yolu (`/yz/gorsel/…webp`).
  final String adres;
  final int genislik;
  final int yukseklik;
  final String kunyeTr, kunyeEn;
  final String kaynakTr, kaynakEn;

  /// Yapay zekâ üretimi şema ya da illüstrasyon (karar 58): altyazıda yazar.
  final bool yapayZeka;

  String kunye(bool en) => en ? kunyeEn : kunyeTr;
  String kaynak(bool en) => en ? kaynakEn : kaynakTr;
  double get oran => yukseklik == 0 ? 1.6 : genislik / yukseklik;
}
