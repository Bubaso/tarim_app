// ÜRETİLMİŞ DOSYA — ELLE DEĞİŞTİRİLMEZ.
// Kaynak: content/yapay_zeka_dijital_tarim/iskelet.json
// Üretici: content/yapay_zeka_dijital_tarim/dart_uret.py
//
// Yapay Zeka ve Dijital Tarım bölümünün iskeleti: başlıklar, katmanlar,
// teknoloji etiketleri. Haber akışı ve etiketler veritabanında
// (`bolum_etiketleri`); başlık ADLARI burada.

/// Bölüm okura açık mı (content/yapay_zeka_dijital_tarim/yayin.json).
/// `false` iken okur rotaları kurulmaz, ana sayfa şeridi çizilmez; sabit
/// derleme anında bilindiği için okur ekranları pakete de girmez. Panel
/// bundan bağımsız. Açılış eşiği: 30 başlığın tamamı (kullanıcı kararı).
const bool kYzOkuraAcik = false;

const String kYzBolumu = "yapay-zeka-dijital-tarim";
const String kYzAdres = "/yapay-zeka-dijital-tarim";
const String kYzAdTr = "Yapay Zeka ve Dijital Tarım";
const String kYzAdEn = "AI and Digital Agriculture";

class YzBaslik {
  const YzBaslik(this.no, this.slug, this.katman, this.tr, this.en,
      this.haberAlir, this.teknoloji, this.yazildi, this.ozetTr, this.ozetEn);
  final int no;
  final String slug;
  final String katman;
  final String tr;
  final String en;

  /// Haber bu başlığın altına bağlanabilir mi (karar 32). Çerçeve,
  /// özet, dizin ve başvuru sayfaları elle yazılır, haber almaz.
  final bool haberAlir;
  final List<String> teknoloji;

  /// İki dili ve kilitli kaydı var, doğrulayıcıdan geçti (iskelet `durum`).
  final bool yazildi;
  final String ozetTr;
  final String ozetEn;

  String ad(bool en) => en ? this.en : tr;
  String ozet(bool en) => en ? ozetEn : ozetTr;
}

const List<YzBaslik> kYzBasliklar = [
  YzBaslik(
      1,
      "bugun-nerede-duruyoruz",
      "cerceve",
      "Bugün nerede duruyoruz",
      "Where things stand today",
      false,
      ["tahmin", "goruntu", "uzaktan", "robotik", "dil"],
      false,
      "Tezin yerine geçen durum tespiti: alanın bugünkü hâli, ölçülmüş birkaç rakamla. Tarama bu özeti günceller.",
      "A status reading in place of a thesis: the field today in a few measured figures. The scan keeps it current."),
  YzBaslik(
      2,
      "kavramlar",
      "cerceve",
      "Kavramlar: yapay zeka, dijital tarım, hassas tarım",
      "Terms: AI, digital farming, precision farming",
      false,
      ["veri", "karar"],
      false,
      "Üç kavram sık sık birbirinin yerine kullanılıyor ve aynı şey değiller.",
      "Three terms used as if interchangeable, which they are not."),
  YzBaslik(
      3,
      "tarihce",
      "cerceve",
      "Kısa tarihçe",
      "A short history",
      false,
      ["karar", "uzaktan", "goruntu"],
      false,
      "Uzman sistemlerden görüntü işlemeye, uydudan dil modellerine: dönüm noktaları ve kişiler.",
      "From expert systems to computer vision, from satellites to language models: turning points and people."),
  YzBaslik(
      4,
      "toprak-ve-arazi",
      "surec",
      "Toprak ve arazi",
      "Soil and land",
      true,
      ["uzaktan", "sensor", "tahmin", "veri"],
      true,
      "Toprak haritalama ve arazi planlaması: küresel haritanın gücü, tarla ölçeğinde sınırı, Türkiye'nin detaylı toprak etüdü.",
      "Soil mapping and land planning: the reach of the global map, its limits at field scale, Türkiye's detailed soil survey."),
  YzBaslik(
      5,
      "tohum-islah-genetik",
      "surec",
      "Tohum, ıslah ve genetik",
      "Seed, breeding and genetics",
      true,
      ["genomik", "tahmin", "goruntu"],
      true,
      "Fenotipleme, genomik seçilim, ıslah süresinin kısaltılması.",
      "Phenotyping, genomic selection, shortening the breeding cycle."),
  YzBaslik(
      6,
      "ekim-ve-degisken-oran",
      "surec",
      "Ekim ve değişken oranlı uygulama",
      "Sowing and variable-rate application",
      true,
      ["karar", "uzaktan", "robotik", "sensor"],
      true,
      "Tarlanın her parçasına aynı muameleyi bırakmak: değişken oranlı tohum ve gübre.",
      "Ending uniform treatment of a field: variable-rate seed and fertiliser."),
  YzBaslik(
      7,
      "sulama-ve-su",
      "surec",
      "Sulama ve su yönetimi",
      "Irrigation and water",
      true,
      ["sensor", "tahmin", "uzaktan", "karar"],
      true,
      "Ne zaman, ne kadar: sensör ve tahmine dayalı sulama.",
      "When and how much: irrigation driven by sensors and forecasts."),
  YzBaslik(
      8,
      "goruntu-isleme-ve-hedefli-ilaclama",
      "surec",
      "Görüntü işleme ve hedefli ilaçlama",
      "Computer vision and targeted spraying",
      true,
      ["goruntu", "robotik", "tahmin"],
      true,
      "Yabancı otu, hastalığı ve zararlıyı görmek — ve ilacı yalnız oraya atmak.",
      "Seeing weeds, disease and pests — and spraying only there."),
  YzBaslik(
      9,
      "urun-izleme-ve-verim-tahmini",
      "surec",
      "Ürün izleme ve verim tahmini",
      "Crop monitoring and yield forecasting",
      true,
      ["uzaktan", "tahmin", "goruntu"],
      true,
      "Hasattan önce rekoltenin bilinmesi: uydu, model ve belirsizlik.",
      "Knowing the harvest before it comes: satellites, models and uncertainty."),
  YzBaslik(
      10,
      "hasat-ve-robotik",
      "surec",
      "Hasat ve robotik",
      "Harvest and robotics",
      true,
      ["robotik", "goruntu"],
      true,
      "Hasat zamanlaması ve robotik toplama — en zor mühendislik problemi neden meyvede.",
      "Harvest timing and robotic picking — why fruit is the hardest engineering problem."),
  YzBaslik(
      11,
      "hasat-sonrasi",
      "surec",
      "Hasat sonrası: sınıflandırma, kalite, depolama",
      "Post-harvest: grading, quality, storage",
      true,
      ["goruntu", "sensor", "tahmin"],
      false,
      "Ürünün tarladan çıktıktan sonra kaybolmaması: sınıflandırma ve depolama.",
      "Keeping produce from being lost after it leaves the field: grading and storage."),
  YzBaslik(
      12,
      "hayvancilik",
      "alan",
      "Hayvancılık",
      "Livestock",
      true,
      ["sensor", "goruntu", "tahmin", "karar"],
      false,
      "Hassas hayvancılık: hastalığı belirtiden önce görmek, sürüyü tek tek tanımak.",
      "Precision livestock farming: seeing disease before symptoms, knowing animals one by one."),
  YzBaslik(
      13,
      "sera-ve-kontrollu-ortam",
      "alan",
      "Sera ve kontrollü ortam",
      "Greenhouse and controlled environment",
      true,
      ["sensor", "ikiz", "karar", "robotik"],
      false,
      "Her değişkenin ölçüldüğü yer: iklim kontrolü, dikey tarım, dijital ikiz.",
      "Where every variable is measured: climate control, vertical farming, digital twins."),
  YzBaslik(
      14,
      "su-urunleri",
      "alan",
      "Su ürünleri",
      "Aquaculture and fisheries",
      true,
      ["sensor", "goruntu", "tahmin"],
      false,
      "Yem, su kalitesi, balık sağlığı ve av takibi.",
      "Feed, water quality, fish health and catch monitoring."),
  YzBaslik(
      15,
      "ormancilik",
      "alan",
      "Ormancılık",
      "Forestry",
      true,
      ["uzaktan", "goruntu", "tahmin"],
      false,
      "Yangın erken uyarısı, ağaç sayımı, kaçak kesim tespiti.",
      "Fire early warning, tree counting, detecting illegal logging."),
  YzBaslik(
      16,
      "pazar-fiyat-tedarik",
      "zincir",
      "Pazar, fiyat ve tedarik zinciri",
      "Markets, prices and supply chain",
      true,
      ["tahmin", "veri"],
      false,
      "Fiyat tahmini, talep planlaması, izlenebilirlik.",
      "Price forecasting, demand planning, traceability."),
  YzBaslik(
      17,
      "iklim-risk-sigorta",
      "zincir",
      "İklim, risk ve tarım sigortası",
      "Climate, risk and crop insurance",
      true,
      ["uzaktan", "tahmin", "karar"],
      false,
      "Erken uyarı, hasar tespiti, endeks sigortası.",
      "Early warning, loss assessment, index insurance."),
  YzBaslik(
      18,
      "danismanlik-ve-dil-modelleri",
      "zincir",
      "Danışmanlık ve dil modelleri",
      "Advisory services and language models",
      true,
      ["dil", "karar"],
      false,
      "Çiftçinin sorusuna cevap veren makine: yayım hizmeti ve sohbet botları.",
      "A machine that answers the farmer: extension services and chatbots."),
  YzBaslik(
      19,
      "uydu-ve-uzaktan-algilama",
      "altyapi",
      "Uydu ve uzaktan algılama",
      "Satellites and remote sensing",
      true,
      ["uzaktan", "goruntu", "veri"],
      false,
      "Tarımsal yapay zekanın en büyük açık veri kaynağı: Sentinel, Landsat, ticari uydular, İHA.",
      "The largest open data source for agricultural AI: Sentinel, Landsat, commercial satellites, drones."),
  YzBaslik(
      20,
      "sensorler-ve-iot",
      "altyapi",
      "Sensörler ve tarımsal nesnelerin interneti",
      "Sensors and agricultural IoT",
      true,
      ["sensor", "veri"],
      false,
      "Tarladaki ölçüm cihazları ve onları birbirine bağlayan ağ — kırsal bağlantı sorunu dahil.",
      "Measuring devices in the field and the network that links them — rural connectivity included."),
  YzBaslik(
      21,
      "veri-sahiplik-platform",
      "altyapi",
      "Veri: sahiplik, platformlar, açık veri",
      "Data: ownership, platforms, open data",
      true,
      ["veri"],
      false,
      "Tarladan çıkan verinin kime ait olduğu — çiftçi mi, makine üreticisi mi, platform mu.",
      "Who owns the data that leaves the field — the farmer, the machinery maker or the platform."),
  YzBaslik(
      22,
      "dunyada-durum",
      "cografya",
      "Dünyada durum: bölge bölge",
      "The world, region by region",
      false,
      ["tahmin", "goruntu", "uzaktan", "robotik", "dil"],
      false,
      "AB, ABD, Çin, Hindistan, İsrail, Afrika: kim nerede, hangi ölçekte.",
      "EU, US, China, India, Israel, Africa: who is where, at what scale."),
  YzBaslik(
      23,
      "turkiyede-durum",
      "cografya",
      "Türkiye'de durum",
      "Türkiye today",
      false,
      ["karar", "uzaktan", "veri", "goruntu"],
      true,
      "TAGEM'in araştırma merkezi, bakanlığın strateji belgesi, KKYDP, Dijital Toprak Haritası — ve ulusal yapay zeka stratejisinde tarımın yokluğu.",
      "TAGEM's research centre, the ministry's strategy, rural development grants, the Digital Soil Map — and agriculture's absence from the national AI strategy."),
  YzBaslik(
      24,
      "mevzuat-ve-politika",
      "cografya",
      "Mevzuat ve politika",
      "Regulation and policy",
      true,
      ["veri", "karar"],
      true,
      "AB Yapay Zeka Yasası, veri mevzuatı, destek programları — ve beklemedeki belgeler.",
      "The EU AI Act, data law, support programmes — and documents still pending."),
  YzBaslik(
      25,
      "turkiye-dizini",
      "cografya",
      "Türkiye dizini: girişimler, üniversiteler, kamu projeleri",
      "Türkiye directory: start-ups, universities, public projects",
      false,
      ["goruntu", "tahmin", "robotik", "sensor", "dil", "uzaktan"],
      false,
      "Yaşayan bir dizin. Tarama yeni kaydı taslak olarak önerir, onayla girer.",
      "A living directory. The scan proposes new entries as drafts; they enter on approval."),
  YzBaslik(
      26,
      "riskler-ve-sinirlar",
      "elestiri",
      "Riskler ve sınırlar",
      "Risks and limits",
      true,
      ["veri", "tahmin", "dil"],
      false,
      "Dijital uçurum, model yanlılığı, veri sahipliği, maliyet ve enerji.",
      "The digital divide, model bias, data ownership, cost and energy."),
  YzBaslik(
      27,
      "basarisizliklar-ve-abartilar",
      "elestiri",
      "Başarısız örnekler ve abartılar",
      "Failures and overstatements",
      true,
      ["tahmin", "goruntu", "robotik"],
      false,
      "Tutmayan vaatler, kapanan girişimler, kaynağı bulunamayan dolaşımdaki rakamlar.",
      "Promises that failed, start-ups that closed, circulating figures with no source."),
  YzBaslik(
      28,
      "saha-hikayeleri",
      "basvuru",
      "Saha hikâyeleri",
      "Stories from the field",
      false,
      ["goruntu", "sensor", "dil", "robotik"],
      false,
      "Teknolojiyi kullanan gerçek üreticiler ve tarlalar — kaynaklı.",
      "Real growers and fields using the technology — with sources."),
  YzBaslik(
      29,
      "sozluk",
      "basvuru",
      "Sözlük",
      "Glossary",
      false,
      [
        "goruntu",
        "tahmin",
        "uzaktan",
        "robotik",
        "sensor",
        "dil",
        "karar",
        "ikiz",
        "veri",
        "genomik"
      ],
      false,
      "Metinde geçen her terim; metin içinde balon olarak da açılır.",
      "Every term used in the text; also opens as a tooltip in place."),
  YzBaslik(
      30,
      "kaynakca",
      "basvuru",
      "Kaynakça",
      "Sources",
      false,
      [],
      false,
      "Kaynakların listesi. Her rakamın niteliği kendi yanında duruyor.",
      "The list of sources. Each figure's standing is shown beside the figure itself."),
];

/// Numarası verilen başlık; yoksa null.
YzBaslik? yzBaslik(int? no) {
  if (no == null) return null;
  for (final b in kYzBasliklar) {
    if (b.no == no) return b;
  }
  return null;
}

/// Haber alabilen başlıklar — panelin başlık seçicisi bunu gösterir.
final List<YzBaslik> kYzHaberBasliklari =
    kYzBasliklar.where((b) => b.haberAlir).toList(growable: false);

const Map<String, Map<String, String>> kYzKatmanlar = {
  "cerceve": {'tr': "Çerçeve", 'en': "Framework"},
  "surec": {'tr': "Tarlanın takvimi", 'en': "The field's calendar"},
  "alan": {'tr': "Üretim alanları", 'en': "Production domains"},
  "zincir": {'tr': "Zincirin öteki ucu", 'en': "Along the chain"},
  "altyapi": {'tr': "Altyapı", 'en': "Infrastructure"},
  "cografya": {'tr': "Dünya ve Türkiye", 'en': "World and Türkiye"},
  "elestiri": {'tr': "Eleştirel bakış", 'en': "Critical view"},
  "basvuru": {'tr': "Anlatı ve başvuru", 'en': "Stories and reference"},
};

const Map<String, Map<String, String>> kYzTeknoloji = {
  "goruntu": {'tr': "Görüntü işleme", 'en': "Computer vision"},
  "tahmin": {'tr': "Tahmin modelleri", 'en': "Predictive models"},
  "uzaktan": {'tr': "Uzaktan algılama", 'en': "Remote sensing"},
  "robotik": {
    'tr': "Robotik ve otonom sistemler",
    'en': "Robotics and autonomy"
  },
  "sensor": {
    'tr': "Sensörler ve nesnelerin interneti",
    'en': "Sensors and IoT"
  },
  "dil": {'tr': "Dil modelleri", 'en': "Language models"},
  "karar": {'tr': "Karar destek sistemleri", 'en': "Decision support"},
  "ikiz": {'tr': "Dijital ikiz", 'en': "Digital twin"},
  "veri": {'tr': "Veri platformları", 'en': "Data platforms"},
  "genomik": {'tr': "Genomik ve ıslah", 'en': "Genomics and breeding"},
};
