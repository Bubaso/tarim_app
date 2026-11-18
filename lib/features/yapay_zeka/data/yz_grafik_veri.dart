/// Grafik verisinin biçimi (karar 58).
///
/// Grafiklerin kendisi `content/yapay_zeka_dijital_tarim/_raw/grafikler.json`'da;
/// her değer bir kaydın sayısal alanına bağlı ve `dogrula_bolumler.py`
/// (kural 11) değeri o alanla karşılaştırıyor. `dart_uret.py` bunları
/// `yz_grafikler.g.dart`'a gömüyor. Metinde grafiğin yeri bir yönerge satırı:
/// `[[grafik:<kimlik>]]` (çizici: `yz_metin_gorunumu.dart`).
library;

class YzGrafikDizi {
  const YzGrafikDizi(this.kod, this.tr, this.en, {this.rol = ''});
  final String kod;
  final String tr;
  final String en;

  /// Dizinin grafikteki rolü:
  /// '' sıradan · 'ongoru' öngörü ya da hedef (açık tonla) ·
  /// 'referans' kesikli dikey çizgi (ör. rastgele tahmin) ·
  /// 'toplam' çizilmez, toplam etiketi ya da kare sayısı olur ·
  /// 'alt' bir kalemin alt kırılımı (girintili, açık tonla).
  final String rol;
  String ad(bool isEn) => isEn ? en : tr;
}

class YzGrafikNokta {
  const YzGrafikNokta(
    this.kategoriTr,
    this.kategoriEn,
    this.dizi,
    this.deger, {
    this.uc = '',
    this.ekTr = '',
    this.ekEn = '',
    this.panelTr = '',
    this.panelEn = '',
    this.birimTr,
    this.birimEn,
    this.satici = false,
  });
  final String kategoriTr;
  final String kategoriEn;
  final String dizi;

  /// Çizilen değer (kayıttaki değer; birim dönüşümü varsa dönüştürülmüş).
  final double deger;

  /// Aralıkta 'alt' ya da 'ust'; öbür türlerde boş.
  final String uc;

  /// Değerin yanına düşülen kısa not (ör. ölçüm yılı ya da olayın tarihi).
  final String ekTr, ekEn;

  /// Küçük çoklu grafikte noktanın paneli.
  final String panelTr, panelEn;

  /// Noktanın birimi grafiğinkinden farklıysa (ör. küçük çoklu panellerde).
  final String? birimTr, birimEn;

  /// Değer şirketin kendi beyanı (karar 34): zaman çizelgesinde içi boş işaret.
  final bool satici;

  String kategori(bool isEn) => isEn ? kategoriEn : kategoriTr;
  String ek(bool isEn) => isEn ? ekEn : ekTr;
  String panel(bool isEn) => isEn ? panelEn : panelTr;
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
    this.eksenTr = '',
    this.eksenEn = '',
    this.ust,
    this.ondalik,
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

  /// Ölçünün kısa adı, başlığın altında (ör. "Doğruluk, %"; "F-1 skoru, 0-1").
  final String eksenTr, eksenEn;

  /// Değer ekseninin üst sınırı elle verildiyse (ör. korelasyonda 1).
  final double? ust;

  /// Değerler kaç ondalıkla yazılsın (boşsa kayıttaki gibi).
  final int? ondalik;

  String baslik(bool en) => en ? baslikEn : baslikTr;
  String aciklama(bool en) => en ? aciklamaEn : aciklamaTr;
  String kaynak(bool en) => en ? kaynakEn : kaynakTr;
  String birim(bool en) => en ? birimEn : birimTr;
  String eksen(bool en) => en ? eksenEn : eksenTr;

  /// Dizinin rolü (yoksa '').
  String rol(String kod) {
    for (final d in diziler) {
      if (d.kod == kod) return d.rol;
    }
    return '';
  }

  /// Toplam ve referans dizileri dışındaki noktalar: çubuk, nokta, kare olarak
  /// çizilenler.
  List<YzGrafikNokta> get cizilenler =>
      [for (final n in noktalar) if (rol(n.dizi) != 'toplam' && rol(n.dizi) != 'referans') n];

  /// Noktanın birimi: kendi birimi yoksa grafiğinki.
  String noktaBirimi(YzGrafikNokta n, bool en) => (en ? n.birimEn : n.birimTr) ?? birim(en);

  /// Noktanın yazılışı: birimiyle, ondalık ayarıyla.
  String yaz(YzGrafikNokta n, bool en) => yzDeger(_yuvarla(n.deger), noktaBirimi(n, en), en);

  /// Bir değerin grafiğin birimiyle yazılışı.
  String yazDeger(double v, bool en) => yzDeger(_yuvarla(v), birim(en), en);

  double _yuvarla(double v) {
    final o = ondalik;
    if (o == null) return v;
    final k = [1, 10, 100, 1000][o.clamp(0, 3)];
    return (v * k).roundToDouble() / k;
  }

  /// Kategoriler, ilk göründükleri sırayla.
  List<String> kategoriler(bool en) {
    final c = <String>[];
    for (final n in cizilenler) {
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
  if (birim == '×') return '$s×';
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
    this.adresTr,
  });

  final String kimlik;

  /// Sitedeki yolu (`/yz/gorsel/…webp`).
  final String adres;

  /// Türkçeye uyarlanmış kopyası (karar 60): İngilizce yazılı şekil ve
  /// grafikte Türkçe sayfa bunu gösteriyor; İngilizce sayfa özgününü.
  final String? adresTr;

  /// Sayfanın diline göre gösterilecek dosya.
  String adresi(bool en) => !en && adresTr != null ? adresTr! : adres;
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
