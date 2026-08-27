import 'dossier_chart.dart';
import 'dossier_theme.dart';

/// Ana sayfa şeridinin ihtiyacı olan kadarıyla bir ülke dosyası.
///
/// `active_country_dossier` görünümünden okunuyor ve `data` sütununu BİLEREK
/// taşımıyor: o blok 44 KB ve şeritte tek bir rakamı bile kullanılmıyor. Ana
/// sayfa her açılışta 44 KB fazladan indirmemeli.
class DossierSummary {
  final String slug;
  final String nameTr;
  final String nameEn;

  /// ISO 3166-1 alpha-3. Rakamların kaynağına dönmenin anahtarı.
  ///
  /// Kurum dosyasında boş: kurumun ISO kodu yok, onun yerine
  /// [kurulusBelgesi] aynı işi görüyor.
  final String iso3;

  /// `ulke` | `kurum`. Hangi diziye ait olduğu.
  ///
  /// Ana sayfa bandı iki kartı buna göre ayırıyor, arşiv buna göre süzüyor ve
  /// sayı numarası (`edition`) dizi İÇİNDE tekil — iki dizi de 01'den başlıyor.
  final String tur;

  bool get kurumDosyasi => tur == 'kurum';

  /// Kurumu kuran belge: "3491 sayılı Kanun · RG 13.07.1938".
  /// Ülke dosyasında null.
  final String? kurulusBelgesi;

  /// Kapaktaki "ÜLKE DOSYASI · 01" numarası.
  final int edition;

  final String thesisTr;
  final String thesisEn;

  final DossierTheme theme;

  final String? coverUrl;
  final String? coverCredit;

  /// Kapaktaki tanıtım videosu. null ise kapakta video bloğu hiç çizilmez.
  ///
  /// Yalnızca dosya sayfası dolduruyor; ana sayfa şeridi ve arşiv listesi
  /// görünümlerinde bu sütun yok ve orada video oynatılmıyor.
  ///
  /// Bu adres bir süre ekran kodunda gömülü durdu ve `slug.contains('hollanda')`
  /// koşuluyla çiziliyordu. İkinci ülkede koşul ikiye çıkacağı ve testlerde
  /// video platformu bulunmadığı için veriye taşındı.
  final String? videoUrl;

  final DateTime? startsAt;
  final DateTime? endsAt;

  /// Pencerenin bitmesine kaç gün kaldığı — veritabanında hesaplanıyor.
  ///
  /// İstemcide hesaplamak, cihaz saatinin doğru olduğunu varsaymak demekti.
  /// null ise dosya süresiz yayında.
  final int? daysRemaining;

  final int sectionCount;

  /// Bu dosya şu anda ana sayfada mı.
  ///
  /// Yalnızca arşiv görünümünden (`country_dossier_index`) geliyor; aktif
  /// dosya görünümünde alan yok ve orada zaten anlamsız — o görünümdeki tek
  /// satır tanımı gereği yayında. Arşivde ise on iki kartın hangisinin
  /// "şimdi" olduğunu okurun ayırt etmesi gerekiyor.
  final bool isActive;

  const DossierSummary({
    required this.slug,
    required this.nameTr,
    required this.nameEn,
    required this.iso3,
    this.tur = 'ulke',
    this.kurulusBelgesi,
    required this.edition,
    required this.thesisTr,
    required this.thesisEn,
    required this.theme,
    this.coverUrl,
    this.coverCredit,
    this.videoUrl,
    this.startsAt,
    this.endsAt,
    this.daysRemaining,
    this.sectionCount = 0,
    this.isActive = false,
  });

  factory DossierSummary.fromJson(Map<String, dynamic> json) {
    return DossierSummary(
      slug: json['slug']?.toString() ?? '',
      nameTr: json['name_tr']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      iso3: json['iso3']?.toString() ?? '',
      tur: json['tur']?.toString() == 'kurum' ? 'kurum' : 'ulke',
      kurulusBelgesi: json['kurulus_belgesi']?.toString(),
      edition: _toInt(json['edition']) ?? 0,
      thesisTr: json['thesis_tr']?.toString() ?? '',
      thesisEn: json['thesis_en']?.toString() ?? '',
      theme: DossierTheme.fromJson(json['theme'] as Map<String, dynamic>?),
      coverUrl: _bosDegilse(json['cover_url']),
      coverCredit: _bosDegilse(json['cover_credit']),
      videoUrl: _bosDegilse(json['video_url']),
      startsAt: DateTime.tryParse(json['starts_at']?.toString() ?? ''),
      endsAt: DateTime.tryParse(json['ends_at']?.toString() ?? ''),
      daysRemaining: _toInt(json['days_remaining']),
      sectionCount: _toInt(json['section_count']) ?? 0,
      isActive: json['is_active'] == true,
    );
  }

  String name(bool isEn) => isEn && nameEn.isNotEmpty ? nameEn : nameTr;
  String thesis(bool isEn) => isEn && thesisEn.isNotEmpty ? thesisEn : thesisTr;

  /// Kapakta "ÜLKE DOSYASI · 01" biçiminde görünür.
  String get editionLabel => edition.toString().padLeft(2, '0');

  /// Kapağın ve ana sayfa kartının üst satırı: "KURUM DOSYASI · 01".
  ///
  /// Dizi adı KODA GÖMÜLMÜYOR. Sabit yazıldığında kurum dosyası ana sayfada
  /// "ÜLKE DOSYASI" diye çıkıyordu — iki dizi aynı ekranı paylaştığı için
  /// etiketin de veriden gelmesi gerekiyor.
  String seriEtiketi(bool isEn) {
    final dizi = kurumDosyasi
        ? (isEn ? 'INSTITUTION DOSSIER' : 'KURUM DOSYASI')
        : (isEn ? 'COUNTRY DOSSIER' : 'ÜLKE DOSYASI');
    return '$dizi · $editionLabel';
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.round();
    return int.tryParse(v.toString());
  }

  static String? _bosDegilse(dynamic v) {
    final s = v?.toString();
    return (s == null || s.isEmpty) ? null : s;
  }
}

/// Dosyanın tamamı — metin sayfası için.
///
/// [data] kilitli veri sayfasının (`data.json`) tamamı. Sütunlara
/// parçalanmadı çünkü her ülkenin veri şekli farklı: Hollanda'da `sera`
/// bloğu var, Mısır'da `sulama` olacak. Grafikler bloğu anahtarla buluyor.
class CountryDossier {
  final DossierSummary summary;
  final Map<String, dynamic> data;
  final List<DossierSection> sections;

  /// Grafik kimliğinden tarifine. `country_dossiers.charts` sütunundan.
  ///
  /// Ayrıştırma burada, dosya indirildiğinde bir kez yapılıyor. Çizim anında
  /// yapılsaydı altmış üç noktalı ihracat serisi her yeniden çizimde baştan
  /// çözülürdü.
  final Map<String, DossierChart> charts;

  const CountryDossier({
    required this.summary,
    required this.data,
    required this.sections,
    this.charts = const {},
  });

  /// Bir bölümün grafikleri, `chart_keys` sırasıyla.
  ///
  /// Tanınmayan kimlik SESSİZCE atlanıyor. Bu bilinçli: eski bir istemci yeni
  /// bir dosyayı açtığında henüz bilmediği bir grafik türüyle karşılaşabilir.
  /// O durumda o grafik çizilmez ama bölümün metni okunmaya devam eder —
  /// hata vermek ya da boş çerçeve çizmek sayfayı kullanılmaz yapardı.
  List<DossierChart> chartsFor(DossierSection section) => section.chartKeys
      .map((k) => charts[k])
      .whereType<DossierChart>()
      .toList();

  /// jsonb sözlüğünü tariflere çevirir.
  static Map<String, DossierChart> parseCharts(dynamic ham) {
    if (ham is! Map) return const {};
    final cikti = <String, DossierChart>{};
    for (final girdi in ham.entries) {
      final id = girdi.key.toString();
      final grafik = DossierChart.fromJson(id, girdi.value);
      if (grafik != null) cikti[id] = grafik;
    }
    return cikti;
  }

  /// Sayfa sonundaki "veri notları" paneli.
  ///
  /// Dosyanın dürüstlük bölümü: hangi rakam neden bulunamadı, yerine ne
  /// kondu. Bir bölüme değil sayfanın tamamına ait olduğu için ayrı duruyor.
  List<DossierGap> get gaps {
    final ham = data['bosluklar'];
    if (ham is! List) return const [];
    return ham.whereType<Map>().map(DossierGap.fromJson).toList();
  }

  /// Kaynak künyesi — hangi kurumdan ne çekildi.
  ///
  /// Anahtar sırası korunuyor: `data.json` kaynakları önem sırasına göre
  /// yazıyor (WB, FAOSTAT, sonra ulusal kurumlar) ve künye o sırayı gösteriyor.
  List<DossierSource> get sources {
    final ham = data['_kaynaklar'];
    if (ham is! Map) return const [];
    return ham.entries
        .map((e) => DossierSource.fromJson(e.key.toString(), e.value))
        .whereType<DossierSource>()
        .toList();
  }
}

/// Kapatılmış (ya da kalmış) bir veri boşluğu.
///
/// Alanlar iki dilli çünkü panel güvenle ilgili: İngilizce okuyan birine
/// "şu rakamı neden başka yerden aldık" açıklamasını Türkçe göstermek,
/// açıklamayı hiç göstermemekle aynı kapıya çıkardı.
class DossierGap {
  final String konuTr;
  final String konuEn;
  final String sorunTr;
  final String sorunEn;
  final String cozumTr;
  final String cozumEn;

  /// `durum: 'KAPANDI'` — panelde işaretli görünür.
  ///
  /// Kapanmamış boşluk gizlenmiyor, tam tersine: kapanmamış olması okurun
  /// bilmesi gereken şey.
  final bool kapandi;

  const DossierGap({
    required this.konuTr,
    required this.konuEn,
    required this.sorunTr,
    required this.sorunEn,
    required this.cozumTr,
    required this.cozumEn,
    required this.kapandi,
  });

  factory DossierGap.fromJson(Map ham) {
    String al(String anahtar) => ham[anahtar]?.toString() ?? '';
    String ikiDilli(String anahtar, bool en) {
      final v = al(en ? '${anahtar}_en' : anahtar);
      return v.isEmpty ? al(anahtar) : v;
    }

    return DossierGap(
      konuTr: ikiDilli('konu', false),
      konuEn: ikiDilli('konu', true),
      sorunTr: ikiDilli('sorun', false),
      sorunEn: ikiDilli('sorun', true),
      cozumTr: ikiDilli('cozum', false),
      cozumEn: ikiDilli('cozum', true),
      kapandi: al('durum') == 'KAPANDI',
    );
  }

  String konu(bool isEn) => isEn ? konuEn : konuTr;
  String sorun(bool isEn) => isEn ? sorunEn : sorunTr;
  String cozum(bool isEn) => isEn ? cozumEn : cozumTr;
}

/// Künyedeki tek bir kaynak.
class DossierSource {
  /// `WB`, `FAO_QCL`, `CBS` — grafiklerin `kaynak` alanında geçen kod.
  final String kod;
  final String ad;
  final String? url;
  final String? lisans;

  const DossierSource({
    required this.kod,
    required this.ad,
    this.url,
    this.lisans,
  });

  static DossierSource? fromJson(String kod, dynamic ham) {
    if (ham is! Map) return null;
    final ad = ham['ad']?.toString();
    if (ad == null || ad.isEmpty) return null;
    return DossierSource(
      kod: kod,
      ad: ad,
      url: DossierSummary._bosDegilse(ham['url']),
      lisans: DossierSummary._bosDegilse(ham['lisans']),
    );
  }
}

/// Dosyanın tek bir bölümü.
/// Bölüm görseli — adres, atıf ve iki dilli alt metin bir arada.
///
/// Atıf ayrı bir alan DEĞİL, zorunlu bir alan: bu dizide telifi belirsiz görsel
/// kullanılmıyor ve atfı olmayan görsel yayımlanmıyor. Kural üretim betiğinde,
/// doğrulayıcıda ve burada üç kez sınanıyor; üçü de aynı şeyi söylüyor çünkü
/// zincirin herhangi bir halkasında gevşerse kural kalmaz.
class DossierGorsel {
  final String url;
  final String atif;

  /// Görselin geldiği sayfa. Atıf metni kimin ürettiğini söyler, bu adres
  /// nereden alındığını — tartışmaya açıldığında kaynağa dönmenin yolu.
  final String? kaynak;

  final String altTr;
  final String altEn;

  const DossierGorsel({
    required this.url,
    required this.atif,
    required this.altTr,
    required this.altEn,
    this.kaynak,
  });

  /// Eksik alanlı görsel çizilmez: yarım atıf, atıfsızlıktan farksız.
  static DossierGorsel? fromJson(Object? ham) {
    if (ham is! Map) return null;
    final url = ham['url']?.toString() ?? '';
    final atif = ham['atif']?.toString() ?? '';
    if (url.isEmpty || atif.isEmpty) return null;
    return DossierGorsel(
      url: url,
      atif: atif,
      kaynak: ham['kaynak']?.toString(),
      altTr: ham['alt_tr']?.toString() ?? '',
      altEn: ham['alt_en']?.toString() ?? '',
    );
  }

  String alt(bool isEn) => isEn && altEn.isNotEmpty ? altEn : altTr;
}

class DossierSection {
  /// 1'den başlar. Metindeki "üçüncü bölümde geri gelecek" gibi ileri
  /// göndermeler bu numaraya dayanıyor.
  final int ord;

  final String titleTr;
  final String titleEn;

  /// Markdown. Kullanılan alt küme dar ve sabit: paragraf, `**kalın**`,
  /// `*italik*` ve tablo. Liste, başlık, bağlantı, kod yok — DossierProse
  /// tam olarak bu kadarını çiziyor.
  final String bodyTr;
  final String bodyEn;

  /// `charts` içindeki grafik kimlikleri. Boşsa bölümde grafik yok.
  ///
  /// Veri bloğunun değil GRAFİĞİN adı: bir veri bloğu birden çok grafiğe
  /// kaynaklık ediyor (sera → hem künye hem sıralama) ve bir grafik birden çok
  /// bloktan besleniyor. Eşleme bu yüzden veriye değil grafiğe yapılıyor.
  ///
  /// Dizi çünkü 10. bölüm hem altmış yıllık ihracat eğrisini hem dünya
  /// sıralaması tablosunu taşıyor.
  final List<String> chartKeys;

  /// Bölümün görsel ritmi: `anlati` | `belge` | `veri` | `akis`.
  ///
  /// On üç bölüm tek ritimde akarsa sayfa düzleşiyor — beş bin kelime boyunca
  /// zemin hiç değişmiyor ve okurun "burası farklı" diyeceği bir an olmuyor.
  /// Tür, o anı veriyor: `veri` bölümlerinde grafikler okuma oluğunu kırıp
  /// genişliyor.
  ///
  /// `chartKeys`'ten türetilmiyor. "Grafiği olan bölüm geniştir" kuralı iki
  /// yerde kırılıyor: grafiksiz bir `belge` bölümü olabiliyor, ve Hollanda'nın
  /// 9. bölümü kart grafiği taşıdığı hâlde anlatı ritminde kalmalı. Tür bir
  /// yayın kararı; veriden çıkarılmaz, yazılır.
  ///
  /// Bilinmeyen bir değer gelirse `anlati` kabul edilir: eski bir istemci yeni
  /// bir türle karşılaştığında bölümü çizemeyip boş bırakmamalı.
  final String tur;

  bool get genisVeri => tur == 'veri';

  /// Bölümün konusunu gösteren görsel. null ise bölümde görsel yok ve hiçbir
  /// şey eksilmez — kapakta olduğu gibi görsel bir katman, taşıyıcı değil.
  final DossierGorsel? gorsel;

  const DossierSection({
    required this.ord,
    required this.titleTr,
    required this.titleEn,
    required this.bodyTr,
    required this.bodyEn,
    this.chartKeys = const [],
    this.tur = 'anlati',
    this.gorsel,
  });

  factory DossierSection.fromJson(Map<String, dynamic> json) {
    return DossierSection(
      ord: DossierSummary._toInt(json['ord']) ?? 0,
      titleTr: json['title_tr']?.toString() ?? '',
      titleEn: json['title_en']?.toString() ?? '',
      bodyTr: json['body_tr']?.toString() ?? '',
      bodyEn: json['body_en']?.toString() ?? '',
      chartKeys:
          (json['chart_keys'] as List?)?.map((e) => e.toString()).toList() ??
              const [],
      tur: _turVeya(json['tur']),
      gorsel: DossierGorsel.fromJson(json['gorsel']),
    );
  }

  String title(bool isEn) => isEn && titleEn.isNotEmpty ? titleEn : titleTr;
  String body(bool isEn) => isEn && bodyEn.isNotEmpty ? bodyEn : bodyTr;

  /// Bölüm numarası "01", "02" biçiminde.
  String get ordLabel => ord.toString().padLeft(2, '0');

  static const _turler = {'anlati', 'belge', 'veri', 'akis'};

  static String _turVeya(Object? ham) {
    final t = ham?.toString();
    return t != null && _turler.contains(t) ? t : 'anlati';
  }
}

/// Yaklaşan dosya — arşivdeki "Yakında" kartı.
///
/// Bir dosya DEĞİL: içeriği, teması, metni yok. Yalnızca sıradaki başlık.
/// Okur dizinin devam ettiğini görsün diye var.
///
/// Geri sayım burada tutulmuyor. Yayındaki dosyanın penceresi kapandığında
/// sıradaki açılacağı için sayaç oradan hesaplanıyor — takvime elle tarih
/// yazmak, pencere kaydığında yalan söyleyen bir sayı bırakırdı.
class DossierTakvim {
  final String tur;
  final String adTr;
  final String adEn;
  final int sira;

  const DossierTakvim({
    required this.tur,
    required this.adTr,
    required this.adEn,
    this.sira = 1,
  });

  factory DossierTakvim.fromJson(Map<String, dynamic> json) => DossierTakvim(
        tur: json['tur']?.toString() == 'kurum' ? 'kurum' : 'ulke',
        adTr: json['ad_tr']?.toString() ?? '',
        adEn: json['ad_en']?.toString() ?? '',
        sira: DossierSummary._toInt(json['sira']) ?? 1,
      );

  String ad(bool isEn) => isEn && adEn.isNotEmpty ? adEn : adTr;
}
