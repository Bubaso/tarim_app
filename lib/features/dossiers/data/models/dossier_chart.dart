import 'dart:ui' show Color;

import 'package:flutter/foundation.dart' show immutable;
import 'package:intl/intl.dart';

import 'dossier_theme.dart';

/// `country_dossiers.charts` jsonb'sinin Dart karşılığı — grafik TARİFLERİ.
///
/// Buradaki sınıflar veri tutmuyor, veriyi nasıl çizeceğimizi tutuyor. Rakamlar
/// zaten çözülmüş hâlde geliyor: `grafikler.json`'da `"@makro.3.NLD.deger"`
/// yazıyor, seed betiği o yolu okuyup yerine gerçek sayıyı koyuyor. Yani
/// istemci hiçbir zaman `data` bloğuna bakmak zorunda değil — metindeki rakam
/// ile grafikteki rakam tek kaynaktan geldiği için ikisi ayrışamaz.
///
/// Neden etiketler de veritabanından geliyor: World Bank kalemleri Türkçe,
/// FAOSTAT kalemleri İngilizce adlandırılmış. İki dilli bir grafik çizmek için
/// ikinci dilin bir yerde yazılı olması gerekiyor ve o yer Dart kodu OLAMAZ —
/// yoksa her yeni ülke bir uygulama sürümü demek olurdu. 28 günde bir ülke
/// değişen bir bölümde bu sürdürülemez.

// ---------------------------------------------------------------------------
// Ortak parçalar
// ---------------------------------------------------------------------------

/// `{"tr": "...", "en": "..."}` — grafiklerin her yerinde geçen iki dilli alan.
@immutable
class DossierText {
  final String tr;
  final String en;

  const DossierText(this.tr, this.en);

  /// Nesne beklenen biçimde değilse null döner; çağıran taraf kendi kararını
  /// verir (başlık zorunlu, `not` değil).
  static DossierText? tryFrom(dynamic v) {
    if (v is Map) {
      final tr = v['tr']?.toString();
      final en = v['en']?.toString();
      if (tr == null && en == null) return null;
      return DossierText(tr ?? en ?? '', en ?? tr ?? '');
    }
    // Tek dilli bir dize geldiyse iki dilde de aynısını göster: eksik çeviri
    // yüzünden hiç etiket göstermemektense Türkçesini göstermek yeğdir.
    final s = v?.toString();
    if (s == null || s.isEmpty) return null;
    return DossierText(s, s);
  }

  /// Etiketler, başlıklar, notlar için. İngilizce boşsa Türkçeye düşer.
  String of(bool isEn) => isEn && en.isNotEmpty ? en : tr;

  /// Önek/sonek için — DÜŞMEDEN, birebir.
  ///
  /// Bu ayrım şart: yüzde işareti Türkçede başa, İngilizcede sona gidiyor, yani
  /// `onek {tr:"%", en:""}` ve `sonek {tr:"", en:"%"}`. [of] kullanılsaydı
  /// İngilizce önek boş olduğu için Türkçeye düşerdi ve sonuç `%0.56%` olurdu.
  /// Boş dize burada bir eksiklik değil, bilinçli bir karar.
  String birebir(bool isEn) => isEn ? en : tr;

  @override
  bool operator ==(Object other) =>
      other is DossierText && other.tr == tr && other.en == en;

  @override
  int get hashCode => Object.hash(tr, en);
}

/// Bir serinin ya da çubuğun görsel rolü.
///
/// `grafikler.json/_roller`: rol DossierTheme'deki renge işaret eder. Ama renk
/// TEK BAŞINA anlam taşımaz — Hollanda paletinde sodyum turuncusu (#FF9E5E) ile
/// cam yeşili (#7FC8A9) neredeyse eş parlaklıkta, deuteranopi altında ayırt
/// edilemiyorlar. Bu yüzden her rol bir de BİÇİM taşıyor.
///
/// Biçim seçimini çizicinin insafına bırakmamak için üç yardımcı burada:
/// [cizgiDeseni], [iciDolu], [taramali]. Çizici rengi alırken biçimi de almış
/// oluyor; unutmak için ayrıca uğraşmak gerekir.
enum ChartRole {
  /// Birinci seri — sodyum turuncusu, dolu/düz.
  vurgu,

  /// Karşılaştırmanın öteki tarafı (Türkiye serisi) — cam yeşili, taralı/kesikli.
  ikincil,

  /// Bağlam satırları: sıralamada öne çıkarılmayan ülkeler, yığında arka plan.
  sessiz;

  static ChartRole coz(dynamic v) {
    switch (v?.toString()) {
      case 'vurgu':
        return ChartRole.vurgu;
      case 'ikincil':
        return ChartRole.ikincil;
      default:
        // Bilinmeyen ya da eksik rol sessize düşüyor: bir satır yanlışlıkla
        // vurgulanmaktansa yanlışlıkla sessiz kalsın.
        return ChartRole.sessiz;
    }
  }

  Color renk(DossierTheme t) => switch (this) {
        ChartRole.vurgu => t.vurgu,
        ChartRole.ikincil => t.ikincil,
        ChartRole.sessiz => t.sessiz,
      };

  /// Çizgi grafikte kesik desen. null = düz çizgi.
  List<double>? get cizgiDeseni => switch (this) {
        ChartRole.vurgu => null,
        ChartRole.ikincil => const [6, 4],
        ChartRole.sessiz => const [2, 3],
      };

  /// Çizgi grafiğin nokta işareti içi dolu mu.
  bool get iciDolu => this == ChartRole.vurgu;

  /// Çubuk taramalı mı çizilecek (düz dolgu yerine eğik tarama).
  bool get taramali => this == ChartRole.ikincil;
}

/// `bolen` / `ondalik` / `onek` / `sonek` — bir rakamın nasıl yazılacağı.
///
/// Neden ham değer saklanıp burada bölünüyor: seed betiği `@yol`'dan gelen
/// sayıyı tam duyarlıkla yazıyor (`1.68323077210041`), yuvarlamıyor. Böylece
/// depodaki sayı World Bank çıktısına birebir izlenebilir kalıyor ve "iki
/// ondalık gösterelim" kararı yeniden seed gerektirmiyor. Yuvarlama çizim
/// anında, burada oluyor.
@immutable
class SayiBicimi {
  /// Birim çevirimi: 1.000.000 bölenle "58.900.000 kg" → "58,9 milyon kg".
  final num? bolen;

  final int ondalik;
  final DossierText? onek;
  final DossierText? sonek;

  const SayiBicimi({this.bolen, this.ondalik = 0, this.onek, this.sonek});

  factory SayiBicimi.fromJson(Map<String, dynamic> json) => SayiBicimi(
        bolen: _sayi(json['bolen']),
        ondalik: _tamsayi(json['ondalik']) ?? 0,
        onek: DossierText.tryFrom(json['onek']),
        sonek: DossierText.tryFrom(json['sonek']),
      );

  /// Binlik ve ondalık ayıracı yerele göre değişiyor: `1.234,5` ve `1,234.5`.
  /// Elle yazmak yerine intl'e bırakıldı; tr_TR ile en_US sembolleri pakette
  /// gömülü geliyor, ayrıca yükleme gerekmiyor.
  String bicimle(num ham, bool isEn) {
    final v = (bolen == null || bolen == 0) ? ham : ham / bolen!;
    final desen = ondalik > 0 ? '#,##0.${'0' * ondalik}' : '#,##0';
    final govde = NumberFormat(desen, isEn ? 'en_US' : 'tr_TR').format(v);
    return '${onek?.birebir(isEn) ?? ''}$govde${sonek?.birebir(isEn) ?? ''}';
  }
}

// ---------------------------------------------------------------------------
// Grafik türleri
// ---------------------------------------------------------------------------

/// Yedi çizici türünün ortak atası.
///
/// `sealed` bilerek: dağıtıcıdaki `switch` bir tür eklendiğinde derleme
/// hatası versin, sessizce boş kutu çizmesin.
sealed class DossierChart {
  /// `grafikler.json`'daki kimlik — `dossier_sections.chart_keys` buna işaret
  /// eder.
  final String id;

  final DossierText baslik;

  /// Grafiğin altındaki uyarı satırı. Çoğunlukla bir metodoloji uyarısı:
  /// "cari dolar, enflasyondan arındırılmamıştır" gibi.
  final DossierText? not;

  /// Kaynak künyesi. Tek dilli — kurum adları çevrilmiyor.
  final String? kaynak;

  const DossierChart({
    required this.id,
    required this.baslik,
    this.not,
    this.kaynak,
  });

  /// Tarifi çözer. Çizilemeyecek bir tarif için null döner.
  ///
  /// null dönmesinin iki sebebi olabilir: (1) tür bu istemci sürümünde yok,
  /// (2) grafiğin gövdesi boş. İkisinde de doğru davranış grafiği ATLAMAK.
  /// Eski bir istemcinin yeni bir dosyayı açtığında başlığı ve kaynak satırı
  /// olan ama içi boş bir çerçeve çizmesi, hiç çizmemesinden kötüdür.
  static DossierChart? fromJson(String id, dynamic ham) {
    if (ham is! Map) return null;
    final json = Map<String, dynamic>.from(ham);
    final baslik = DossierText.tryFrom(json['baslik']);
    if (baslik == null) return null;

    final not = DossierText.tryFrom(json['not']);
    final kaynak = json['kaynak']?.toString();

    switch (json['tur']?.toString()) {
      case 'ikili_cubuk':
        final seriler = _liste(json['seriler']).map(CubukSeri._coz).toList();
        final satirlar = _liste(json['satirlar']).map(IkiliSatir._coz).toList();
        if (seriler.length < 2 || satirlar.isEmpty) return null;
        return IkiliCubukChart(
          id: id,
          baslik: baslik,
          not: not,
          kaynak: kaynak,
          seriler: seriler,
          satirlar: satirlar,
        );

      case 'siralama':
        final satirlar = _liste(json['satirlar']).map(SiralamaSatir._coz).toList();
        if (satirlar.isEmpty) return null;
        return SiralamaChart(
          id: id,
          baslik: baslik,
          not: not,
          kaynak: kaynak,
          birim: DossierText.tryFrom(json['birim']),
          bicim: SayiBicimi.fromJson(json),
          satirlar: satirlar,
        );

      case 'cizgi':
        final seriler = _liste(json['seriler'])
            .map(CizgiSeri._coz)
            .whereType<CizgiSeri>()
            .toList();
        if (seriler.isEmpty) return null;
        return CizgiChart(
          id: id,
          baslik: baslik,
          not: not,
          kaynak: kaynak,
          birim: DossierText.tryFrom(json['birim']),
          bicim: SayiBicimi.fromJson(json),
          seriler: seriler,
        );

      case 'yigin':
        final cubuklar = _liste(json['cubuklar'])
            .map(YiginCubuk._coz)
            .whereType<YiginCubuk>()
            .toList();
        if (cubuklar.isEmpty) return null;
        return YiginChart(
          id: id,
          baslik: baslik,
          not: not,
          kaynak: kaynak,
          cubuklar: cubuklar,
        );

      case 'kunye':
        final kalemler = _liste(json['kalemler']).map(KunyeKalem._coz).toList();
        if (kalemler.isEmpty) return null;
        return KunyeChart(
          id: id,
          baslik: baslik,
          not: not,
          kaynak: kaynak,
          kalemler: kalemler,
        );

      case 'zaman_cizelgesi':
        final olaylar = _liste(json['olaylar'])
            .map(CizelgeOlay._coz)
            .whereType<CizelgeOlay>()
            .toList();
        if (olaylar.isEmpty) return null;
        return ZamanCizelgesiChart(
          id: id,
          baslik: baslik,
          not: not,
          kaynak: kaynak,
          olaylar: olaylar,
        );

      case 'kartlar':
        final kartlar = _liste(json['kartlar'])
            .map(KurumKart._coz)
            .whereType<KurumKart>()
            .toList();
        if (kartlar.isEmpty) return null;
        return KartlarChart(
          id: id,
          baslik: baslik,
          not: not,
          kaynak: kaynak,
          kartlar: kartlar,
        );

      default:
        return null;
    }
  }
}

/// İki seriyi satır satır karşılaştırır.
///
/// Her satırın KENDİ ölçeği var; ortak bir eksen yok. Sebebi tarif dosyasında
/// yazılı: bir satır yüzde, öteki km² olabiliyor ve bunları aynı eksene koymak
/// karşılaştırma değil çarpıtma olur. Çizici her satırı kendi içinde
/// oranlıyor.
@immutable
class IkiliCubukChart extends DossierChart {
  final List<CubukSeri> seriler;
  final List<IkiliSatir> satirlar;

  const IkiliCubukChart({
    required super.id,
    required super.baslik,
    super.not,
    super.kaynak,
    required this.seriler,
    required this.satirlar,
  });
}

@immutable
class CubukSeri {
  final DossierText ad;
  final ChartRole rol;

  const CubukSeri({required this.ad, required this.rol});

  static CubukSeri _coz(Map<String, dynamic> j) => CubukSeri(
        ad: DossierText.tryFrom(j['ad']) ?? const DossierText('', ''),
        rol: ChartRole.coz(j['rol']),
      );
}

@immutable
class IkiliSatir {
  final DossierText etiket;

  /// Satırın kendi birimi — ortak eksen olmadığı için satır başına yazılıyor.
  final DossierText? birim;

  final int? yil;
  final SayiBicimi bicim;

  /// [CubukSeri] sırasıyla eşleşir. Çizici iki listenin kısasına göre eşler:
  /// eksik bir değer yüzünden tüm grafik kaybolmasın.
  final List<num> degerler;

  /// "12 kat" / "12×" gibi hazır bir oran etiketi.
  ///
  /// Hesaplanmıyor, yazılıyor: ondalık ayıracı dile göre değişiyor ("5,1 kat"
  /// ve "5.1×") ve hangi oranın anlamlı olduğu bir yayın kararı.
  final DossierText? rozet;

  const IkiliSatir({
    required this.etiket,
    this.birim,
    this.yil,
    required this.bicim,
    required this.degerler,
    this.rozet,
  });

  static IkiliSatir _coz(Map<String, dynamic> j) => IkiliSatir(
        etiket: DossierText.tryFrom(j['etiket']) ?? const DossierText('', ''),
        birim: DossierText.tryFrom(j['birim']),
        yil: _tamsayi(j['yil']),
        bicim: SayiBicimi.fromJson(j),
        degerler: _liste2(j['degerler']).map(_sayi).whereType<num>().toList(),
        rozet: DossierText.tryFrom(j['rozet']),
      );
}

/// Tek seri, büyükten küçüğe yatay çubuk.
@immutable
class SiralamaChart extends DossierChart {
  final DossierText? birim;
  final SayiBicimi bicim;
  final List<SiralamaSatir> satirlar;

  const SiralamaChart({
    required super.id,
    required super.baslik,
    super.not,
    super.kaynak,
    this.birim,
    required this.bicim,
    required this.satirlar,
  });

  /// Çubuk boylarını oranlamak için — sıfır bölmeye karşı en az 1.
  num get enBuyuk =>
      satirlar.fold<num>(0, (e, s) => s.deger > e ? s.deger : e).clamp(1, double.infinity);
}

@immutable
class SiralamaSatir {
  final DossierText etiket;
  final num deger;
  final ChartRole rol;

  const SiralamaSatir({required this.etiket, required this.deger, required this.rol});

  static SiralamaSatir _coz(Map<String, dynamic> j) => SiralamaSatir(
        etiket: DossierText.tryFrom(j['etiket']) ?? const DossierText('', ''),
        deger: _sayi(j['deger']) ?? 0,
        rol: ChartRole.coz(j['rol']),
      );
}

/// Zaman serisi, bir ya da iki seri.
@immutable
class CizgiChart extends DossierChart {
  final DossierText? birim;
  final SayiBicimi bicim;
  final List<CizgiSeri> seriler;

  const CizgiChart({
    required super.id,
    required super.baslik,
    super.not,
    super.kaynak,
    this.birim,
    required this.bicim,
    required this.seriler,
  });

  /// Ortak eksen sınırları.
  ///
  /// Çizgide durum ikili çubuğun tersi: iki seri de aynı birimde ve
  /// karşılaştırılmaları isteniyor (Hollanda→Türkiye ile Türkiye→Hollanda).
  /// Ayrı eksen verilse çizgiler yanıltıcı biçimde eşit görünürdü.
  (double, double) get xAralik => _aralik(seriler.expand((s) => s.noktalar).map((n) => n.x));

  (double, double) get yAralik {
    final (alt, ust) = _aralik(seriler.expand((s) => s.noktalar).map((n) => n.y));
    // Taban her zaman sıfır: kırpılmış bir taban artışı olduğundan büyük
    // gösterir. Altmış yıllık ihracat eğrisinde bu ciddi bir çarpıtma olurdu.
    return (alt < 0 ? alt : 0, ust);
  }

  static (double, double) _aralik(Iterable<double> v) {
    if (v.isEmpty) return (0, 1);
    var alt = v.first, ust = v.first;
    for (final x in v) {
      if (x < alt) alt = x;
      if (x > ust) ust = x;
    }
    return (alt, ust == alt ? ust + 1 : ust);
  }
}

@immutable
class CizgiSeri {
  final DossierText ad;
  final ChartRole rol;

  /// x'e göre artan sırada. Sıralama burada bir kez yapılıyor ki çizici her
  /// karede altmış noktayı yeniden sıralamasın.
  final List<CizgiNokta> noktalar;

  const CizgiSeri({required this.ad, required this.rol, required this.noktalar});

  /// Noktalar iki biçimden birinde gelir:
  ///  · `harita` — `{"1961": 1234, ...}` yıl→değer sözlüğü
  ///  · `liste` + `x`/`y` — kayıt dizisi, hangi alanın hangi eksen olduğu yazılı
  ///
  /// İkinci biçim aynı diziden iki seri çıkarmak için var: ikili ticaret
  /// verisinde her satırda hem gidiş hem geliş rakamı duruyor.
  static CizgiSeri? _coz(Map<String, dynamic> j) {
    final ham = j['noktalar'];
    if (ham is! Map) return null;

    final noktalar = <CizgiNokta>[];

    final harita = ham['harita'];
    if (harita is Map) {
      for (final girdi in harita.entries) {
        final x = double.tryParse(girdi.key.toString());
        final y = _sayi(girdi.value);
        if (x != null && y != null) noktalar.add(CizgiNokta(x, y.toDouble()));
      }
    }

    final liste = ham['liste'];
    if (liste is List) {
      final xAlan = ham['x']?.toString();
      final yAlan = ham['y']?.toString();
      if (xAlan == null || yAlan == null) return null;
      for (final kayit in liste) {
        if (kayit is! Map) continue;
        final x = _sayi(kayit[xAlan]);
        final y = _sayi(kayit[yAlan]);
        if (x != null && y != null) noktalar.add(CizgiNokta(x.toDouble(), y.toDouble()));
      }
    }

    if (noktalar.isEmpty) return null;
    noktalar.sort((a, b) => a.x.compareTo(b.x));

    return CizgiSeri(
      ad: DossierText.tryFrom(j['ad']) ?? const DossierText('', ''),
      rol: ChartRole.coz(j['rol']),
      noktalar: noktalar,
    );
  }
}

@immutable
class CizgiNokta {
  /// Genellikle yıl. Kesirli tutuluyor ki eksen hesabı tamsayıya sıkışmasın.
  final double x;
  final double y;

  const CizgiNokta(this.x, this.y);
}

/// Bütünün parçaları. Her çubuk kendi içinde %100'e normalize edilir.
@immutable
class YiginChart extends DossierChart {
  final List<YiginCubuk> cubuklar;

  const YiginChart({
    required super.id,
    required super.baslik,
    super.not,
    super.kaynak,
    required this.cubuklar,
  });
}

@immutable
class YiginCubuk {
  final DossierText etiket;
  final List<YiginDilim> dilimler;

  const YiginCubuk({required this.etiket, required this.dilimler});

  /// Çubuğun kendi toplamı.
  ///
  /// Her çubuk KENDİ toplamına oranlanıyor, çubuklar birbirine değil: grafiğin
  /// söylediği şey "ciro 137,5 milyar, kazanç 49 milyar" değil, "yeniden
  /// ihracat cironun %35,7'si ama kazancın yalnızca %11,6'sı". İki çubuğu ortak
  /// ölçeğe koymak bu karşılaştırmayı görünmez kılardı.
  num get toplam =>
      dilimler.fold<num>(0, (t, d) => t + d.deger).clamp(1, double.infinity);

  static YiginCubuk? _coz(Map<String, dynamic> j) {
    final dilimler = _liste(j['dilimler']).map(YiginDilim._coz).toList();
    if (dilimler.isEmpty) return null;
    return YiginCubuk(
      etiket: DossierText.tryFrom(j['etiket']) ?? const DossierText('', ''),
      dilimler: dilimler,
    );
  }
}

@immutable
class YiginDilim {
  final DossierText ad;
  final num deger;
  final ChartRole rol;

  const YiginDilim({required this.ad, required this.deger, required this.rol});

  static YiginDilim _coz(Map<String, dynamic> j) => YiginDilim(
        ad: DossierText.tryFrom(j['ad']) ?? const DossierText('', ''),
        deger: _sayi(j['deger']) ?? 0,
        rol: ChartRole.coz(j['rol']),
      );
}

/// Rakam ızgarası — grafik değil, sayı panosu.
@immutable
class KunyeChart extends DossierChart {
  final List<KunyeKalem> kalemler;

  const KunyeChart({
    required super.id,
    required super.baslik,
    super.not,
    super.kaynak,
    required this.kalemler,
  });
}

@immutable
class KunyeKalem {
  final num deger;
  final SayiBicimi bicim;
  final DossierText etiket;

  /// Yıl ya da kısa nitelik — "2025", "2020 tahmini".
  final DossierText? alt;

  const KunyeKalem({
    required this.deger,
    required this.bicim,
    required this.etiket,
    this.alt,
  });

  String bicimli(bool isEn) => bicim.bicimle(deger, isEn);

  static KunyeKalem _coz(Map<String, dynamic> j) => KunyeKalem(
        deger: _sayi(j['deger']) ?? 0,
        bicim: SayiBicimi.fromJson(j),
        etiket: DossierText.tryFrom(j['etiket']) ?? const DossierText('', ''),
        alt: DossierText.tryFrom(j['alt']),
      );
}

/// Yıl + olay dizisi.
@immutable
class ZamanCizelgesiChart extends DossierChart {
  final List<CizelgeOlay> olaylar;

  const ZamanCizelgesiChart({
    required super.id,
    required super.baslik,
    super.not,
    super.kaynak,
    required this.olaylar,
  });
}

@immutable
class CizelgeOlay {
  final int yil;

  /// "1940–45" gibi bir aralığın ikinci yarısı. Ayrı duruyor çünkü [yil]
  /// sıralama için sayı kalmak zorunda.
  final DossierText? yilEk;

  final DossierText baslik;
  final DossierText? aciklama;

  const CizelgeOlay({
    required this.yil,
    this.yilEk,
    required this.baslik,
    this.aciklama,
  });

  String yilEtiketi(bool isEn) => '$yil${yilEk?.of(isEn) ?? ''}';

  static CizelgeOlay? _coz(Map<String, dynamic> j) {
    final yil = _tamsayi(j['yil']);
    final baslik = DossierText.tryFrom(j['baslik']);
    if (yil == null || baslik == null) return null;
    return CizelgeOlay(
      yil: yil,
      yilEk: DossierText.tryFrom(j['yil_ek']),
      baslik: baslik,
      aciklama: DossierText.tryFrom(j['aciklama']),
    );
  }
}

/// Kurum/aktör kartları.
@immutable
class KartlarChart extends DossierChart {
  final List<KurumKart> kartlar;

  const KartlarChart({
    required super.id,
    required super.baslik,
    super.not,
    super.kaynak,
    required this.kartlar,
  });
}

@immutable
class KurumKart {
  /// Kartın üstündeki künye satırı — "Üretici kooperatifi · 1911".
  final DossierText? ust;

  final DossierText baslik;
  final DossierText govde;

  /// Kartın köşesindeki tek rakam. Her kurumun öyle bir rakamı yok.
  final KartRakam? rakam;

  const KurumKart({
    this.ust,
    required this.baslik,
    required this.govde,
    this.rakam,
  });

  static KurumKart? _coz(Map<String, dynamic> j) {
    final baslik = DossierText.tryFrom(j['baslik']);
    final govde = DossierText.tryFrom(j['govde']);
    if (baslik == null || govde == null) return null;
    return KurumKart(
      ust: DossierText.tryFrom(j['ust']),
      baslik: baslik,
      govde: govde,
      rakam: KartRakam._coz(j['rakam']),
    );
  }
}

@immutable
class KartRakam {
  final num deger;
  final SayiBicimi bicim;
  final DossierText etiket;

  const KartRakam({required this.deger, required this.bicim, required this.etiket});

  String bicimli(bool isEn) => bicim.bicimle(deger, isEn);

  static KartRakam? _coz(dynamic ham) {
    if (ham is! Map) return null;
    final j = Map<String, dynamic>.from(ham);
    final deger = _sayi(j['deger']);
    if (deger == null) return null;
    return KartRakam(
      deger: deger,
      bicim: SayiBicimi.fromJson(j),
      etiket: DossierText.tryFrom(j['etiket']) ?? const DossierText('', ''),
    );
  }
}

// ---------------------------------------------------------------------------
// Çözüm yardımcıları
// ---------------------------------------------------------------------------

List<Map<String, dynamic>> _liste(dynamic v) => v is List
    ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : const [];

List<dynamic> _liste2(dynamic v) => v is List ? v : const [];

num? _sayi(dynamic v) {
  if (v is num) return v;
  return v == null ? null : num.tryParse(v.toString());
}

int? _tamsayi(dynamic v) {
  final n = _sayi(v);
  return n?.round();
}
