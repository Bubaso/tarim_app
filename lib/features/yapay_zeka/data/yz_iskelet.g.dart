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
const bool kYzOkuraAcik = true;

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
  YzBaslik(1, "bugun-nerede-duruyoruz", "cerceve",
      "Bugün nerede duruyoruz", "Where things stand today",
      false, ["goruntu", "tahmin", "uzaktan", "robotik"],
      true,
      "Bütün başlıkların özeti: yapay zekânın nerede sağlam sonuç verdiği, nerede tutarsız kaldığı ve Türkiye'de neyin ölçülmediği.", "The summary of all headings: where AI delivers solid results, where it is inconsistent, and what has not been measured in Türkiye."),
  YzBaslik(2, "kavramlar", "cerceve",
      "Kavramlar: yapay zekâ, dijital tarım, hassas tarım", "Terms: AI, digital farming, precision farming",
      false, ["tahmin", "robotik", "sensor", "karar"],
      true,
      "Üç kavram sık sık birbirinin yerine kullanılıyor ve aynı şey değiller.", "Three terms used as if interchangeable, which they are not."),
  YzBaslik(3, "tarihce", "cerceve",
      "Kısa tarihçe", "A short history",
      false, ["goruntu", "tahmin", "uzaktan", "dil", "veri"],
      true,
      "Uzman sistemlerden görüntü işlemeye, uydudan dil modellerine: dönüm noktaları ve kişiler.", "From expert systems to computer vision, from satellites to language models: turning points and people."),
  YzBaslik(4, "toprak-ve-arazi", "surec",
      "Toprak ve arazi", "Soil and land",
      true, ["tahmin"],
      true,
      "Toprak haritalama ve arazi planlaması: küresel haritanın gücü, tarla ölçeğinde sınırı, Türkiye'nin detaylı toprak etüdü.", "Soil mapping and land planning: the reach of the global map, its limits at field scale, Türkiye's detailed soil survey."),
  YzBaslik(5, "tohum-islah-genetik", "surec",
      "Tohum, ıslah ve genetik", "Seed, breeding and genetics",
      true, ["tahmin", "sensor", "genomik"],
      true,
      "Fenotipleme, genomik seçilim, ıslah süresinin kısaltılması.", "Phenotyping, genomic selection, shortening the breeding cycle."),
  YzBaslik(6, "ekim-ve-degisken-oran", "surec",
      "Ekim ve değişken oranlı uygulama", "Sowing and variable-rate application",
      true, ["tahmin", "uzaktan", "sensor", "karar"],
      true,
      "Tarlanın her parçasına aynı muameleyi bırakmak: değişken oranlı tohum ve gübre.", "Ending uniform treatment of a field: variable-rate seed and fertiliser."),
  YzBaslik(7, "sulama-ve-su", "surec",
      "Sulama ve su yönetimi", "Irrigation and water",
      true, ["uzaktan", "sensor", "karar"],
      true,
      "Ne zaman, ne kadar: sensör ve tahmine dayalı sulama.", "When and how much: irrigation driven by sensors and forecasts."),
  YzBaslik(8, "goruntu-isleme-ve-hedefli-ilaclama", "surec",
      "Görüntü işleme ve hedefli ilaçlama", "Computer vision and targeted spraying",
      true, ["goruntu"],
      true,
      "Yabancı otu, hastalığı ve zararlıyı görmek — ve ilacı yalnız oraya atmak.", "Seeing weeds, disease and pests — and spraying only there."),
  YzBaslik(9, "urun-izleme-ve-verim-tahmini", "surec",
      "Ürün izleme ve verim tahmini", "Crop monitoring and yield forecasting",
      true, ["tahmin", "uzaktan"],
      true,
      "Hasattan önce rekoltenin bilinmesi: uydu, model ve belirsizlik.", "Knowing the harvest before it comes: satellites, models and uncertainty."),
  YzBaslik(10, "hasat-ve-robotik", "surec",
      "Hasat ve robotik", "Harvest and robotics",
      true, ["goruntu", "robotik"],
      true,
      "Hasat zamanlaması ve robotik toplama — en zor mühendislik problemi neden meyvede.", "Harvest timing and robotic picking — why fruit is the hardest engineering problem."),
  YzBaslik(11, "hasat-sonrasi", "surec",
      "Hasat sonrası: sınıflandırma, kalite, depolama", "Post-harvest: grading, quality, storage",
      true, ["goruntu"],
      true,
      "Ürünün tarladan çıktıktan sonra kaybolmaması: sınıflandırma ve depolama.", "Keeping produce from being lost after it leaves the field: grading and storage."),
  YzBaslik(12, "hayvancilik", "alan",
      "Hayvancılık", "Livestock",
      true, ["goruntu", "tahmin", "robotik", "sensor", "genomik"],
      true,
      "Hassas hayvancılık: hastalığı belirtiden önce görmek, sürüyü tek tek tanımak.", "Precision livestock farming: seeing disease before symptoms, knowing animals one by one."),
  YzBaslik(13, "sera-ve-kontrollu-ortam", "alan",
      "Sera ve kontrollü ortam", "Greenhouse and controlled environment",
      true, ["robotik"],
      true,
      "Her değişkenin ölçüldüğü yer: yapay zekânın yetiştiriciyle yarıştığı sera, dikey tarım, sera robotu.", "Where every variable is measured: the greenhouse where AI competes with growers, vertical farming, a greenhouse robot."),
  YzBaslik(14, "su-urunleri", "alan",
      "Su ürünleri", "Aquaculture and fisheries",
      true, ["goruntu", "uzaktan"],
      true,
      "Yem, su kalitesi, balık sağlığı ve av takibi.", "Feed, water quality, fish health and catch monitoring."),
  YzBaslik(15, "ormancilik", "alan",
      "Ormancılık", "Forestry",
      true, ["goruntu", "tahmin", "uzaktan", "karar"],
      true,
      "Yangın erken uyarısı, ağaç sayımı, kaçak kesim tespiti.", "Fire early warning, tree counting, detecting illegal logging."),
  YzBaslik(16, "pazar-fiyat-tedarik", "zincir",
      "Pazar, fiyat ve tedarik zinciri", "Markets, prices and supply chain",
      true, ["tahmin", "veri"],
      true,
      "Fiyat tahmini, talep planlaması, izlenebilirlik.", "Price forecasting, demand planning, traceability."),
  YzBaslik(17, "iklim-risk-sigorta", "zincir",
      "İklim, risk ve tarım sigortası", "Climate, risk and crop insurance",
      true, ["tahmin", "uzaktan"],
      true,
      "Erken uyarı, hasar tespiti, endeks sigortası.", "Early warning, loss assessment, index insurance."),
  YzBaslik(18, "danismanlik-ve-dil-modelleri", "zincir",
      "Danışmanlık ve dil modelleri", "Advisory services and language models",
      true, ["dil"],
      true,
      "Çiftçinin sorusuna cevap veren makine: yayım hizmeti ve sohbet botları.", "A machine that answers the farmer: extension services and chatbots."),
  YzBaslik(19, "uydu-ve-uzaktan-algilama", "altyapi",
      "Uydu ve uzaktan algılama", "Satellites and remote sensing",
      true, ["goruntu", "tahmin", "uzaktan", "veri"],
      true,
      "Tarımsal yapay zekanın en büyük açık veri kaynağı: Sentinel, Landsat, ticari uydular, İHA.", "The largest open data source for agricultural AI: Sentinel, Landsat, commercial satellites, drones."),
  YzBaslik(20, "sensorler-ve-iot", "altyapi",
      "Sensörler ve tarımsal nesnelerin interneti", "Sensors and agricultural IoT",
      true, ["sensor"],
      true,
      "Tarladaki ölçüm cihazları ve onları birbirine bağlayan ağ — kırsal bağlantı sorunu dâhil.", "Measuring devices in the field and the network that links them — rural connectivity included."),
  YzBaslik(21, "veri-sahiplik-platform", "altyapi",
      "Veri: sahiplik, platformlar, açık veri", "Data: ownership, platforms, open data",
      true, ["veri"],
      true,
      "Tarladan çıkan verinin kime ait olduğu — çiftçi mi, makine üreticisi mi, platform mu.", "Who owns the data that leaves the field — the farmer, the machinery maker or the platform."),
  YzBaslik(22, "dunyada-durum", "cografya",
      "Dünyada durum: bölge bölge", "The world, region by region",
      false, ["tahmin", "robotik", "dil"],
      true,
      "AB, ABD, Çin, Hindistan, İsrail, Afrika: kim nerede, hangi ölçekte.", "EU, US, China, India, Israel, Africa: who is where, at what scale."),
  YzBaslik(23, "turkiyede-durum", "cografya",
      "Türkiye'de durum", "Türkiye today",
      false, ["goruntu", "tahmin", "uzaktan", "robotik", "karar"],
      true,
      "Ulusal planda tarım var, bakanlık yok; yıllık programın tarımdaki tek yapay zekâ işi, bakanlığın sahadaki izleme sistemleri, TAGEM'in projeleri ve beklemedeki strateji belgesi.", "Agriculture is in the national plan, the ministry is not; the annual programme's single AI task for agriculture, the ministry's monitoring systems in the field, TAGEM's projects and the pending strategy."),
  YzBaslik(24, "mevzuat-ve-politika", "cografya",
      "Mevzuat ve politika", "Regulation and policy",
      true, ["veri"],
      true,
      "AB Yapay Zeka Tüzüğü, veri ve makine mevzuatı, uydu izlemesini şart koşan tarım kuralı — ve Türkiye'de yolda olan çerçeve.", "The EU AI Act, data and machinery law, the farm rule that requires satellite monitoring — and the framework on its way in Türkiye."),
  YzBaslik(25, "turkiye-dizini", "cografya",
      "Türkiye dizini: girişimler, üniversiteler, kamu projeleri", "Türkiye directory: start-ups, universities, public projects",
      false, ["goruntu", "tahmin", "uzaktan", "robotik", "sensor", "veri"],
      true,
      "Kamunun yapay zekâ sistemleri ve projeleri, TÜBİTAK'ın tarım projeleri, üniversite merkezleri ve girişimler — her biri kaynağıyla.", "Public AI systems and projects, TÜBİTAK's agriculture projects, university centres and start-ups — each with its source."),
  YzBaslik(26, "riskler-ve-sinirlar", "elestiri",
      "Riskler ve sınırlar", "Risks and limits",
      true, ["goruntu", "robotik"],
      true,
      "Laboratuvarın dışında düşen model başarısı, dijital uçurum, emek, güvenlik ve enerji — ve Türkiye'nin küçük, yaşlanan işletmeleri.", "Model accuracy that falls outside the lab, the digital divide, labour, security and energy — and Türkiye's small, ageing farms."),
  YzBaslik(27, "basarisizliklar-ve-abartilar", "elestiri",
      "Başarısız örnekler ve abartılar", "Failures and overstatements",
      true, ["robotik"],
      true,
      "Yapay zekâ vaadiyle büyüyüp iflas eden şirketler, ticarileşmeyen hasat robotları, yeniden hesaplanan bir FAO rakamı ve hedeflerinin gerisinde kalan bir Türkiye projesi.", "Companies that grew on AI promises and went bankrupt, harvesting robots that never reached the market, a recalculated FAO figure and a Turkish project behind its targets."),
  YzBaslik(28, "saha-hikayeleri", "basvuru",
      "Saha hikâyeleri", "Stories from the field",
      false, ["goruntu", "uzaktan", "sensor"],
      true,
      "Teknolojiyi kullanan gerçek üreticiler ve tarlalar — kaynaklı.", "Real growers and fields using the technology — with sources."),
  YzBaslik(29, "sozluk", "basvuru",
      "Sözlük", "Glossary",
      false, [],
      true,
      "Başlıklarda geçen terimlerin kaynaklı tanımları; aynı tanım metinde terime dokununca balonda açılıyor.", "Sourced definitions of the terms used in the headings; the same definition opens in a bubble when a term is tapped in the text."),
  YzBaslik(30, "kaynakca", "basvuru",
      "Kaynakça", "Sources",
      false, [],
      true,
      "Kaynakların listesi. Her rakamın niteliği kendi yanında duruyor.", "The list of sources. Each figure's standing is shown beside the figure itself."),
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
  "robotik": {'tr': "Robotik ve otonom sistemler", 'en': "Robotics and autonomy"},
  "sensor": {'tr': "Sensörler ve nesnelerin interneti", 'en': "Sensors and IoT"},
  "dil": {'tr': "Dil modelleri", 'en': "Language models"},
  "karar": {'tr': "Karar destek sistemleri", 'en': "Decision support"},
  "veri": {'tr': "Veri platformları", 'en': "Data platforms"},
  "genomik": {'tr': "Genomik ve ıslah", 'en': "Genomics and breeding"},
};

/// Teknoloji desenleri (karar 57): 'desen_tr', 'desen_en', 'haric_tr', 'haric_en'.
const Map<String, Map<String, List<String>>> kYzTeknolojiDesen = {
  "goruntu": {"desen_tr": ["görüntü işleme", "görüntü tanıma", "görüntüden", "görüntüde", "görüntülerde", "görüntülerden", "görüntü veri", "yaprak görüntü", "bilgisayarlı görü", "kamera", "fotoğraf", "multispektral görüntüleme", "görüntüyle", "görüntülük", "optik", "yapraktaki belirti"], "desen_en": ["image processing", "image recognition", "from images", "in images", "on images", "from an image", "image dataset", "image data set", "leaf images", "computer vision", "camera", "photo", "multispectral imaging", "using images", "image set", "optical", "leaf symptom"], "haric_tr": ["uydu görüntü", "optik uydu"], "haric_en": ["satellite image", "optical satellite"]},
  "tahmin": {"desen_tr": ["tahmin", "öngörü model", "erken uyarı"], "desen_en": ["forecast", "predict", "early warning"], "haric_tr": ["tahminen", "=Hava Tahminleri Merkezi"], "haric_en": ["=Medium-Range Weather Forecasts"]},
  "uzaktan": {"desen_tr": ["uzaktan algılama", "uydu", "=Sentinel", "=Landsat", "=İMECE", "radar"], "desen_en": ["remote sensing", "satellite", "=Sentinel", "=Landsat", "=İMECE", "radar"], "haric_tr": ["uydu konum"], "haric_en": ["satellite positioning"]},
  "robotik": {"desen_tr": ["robot", "otonom", "otomatik dümen", "otomatik yönlendirme"], "desen_en": ["robot", "autonomous", "autonomy", "auto-steer", "automated guidance"], "haric_tr": ["sohbet robot"], "haric_en": []},
  "sensor": {"desen_tr": ["sensör", "nesnelerin interneti", "=IoT", "=LoRaWAN"], "desen_en": ["sensor", "internet of things", "=IoT", "=LoRaWAN"], "haric_tr": [], "haric_en": []},
  "dil": {"desen_tr": ["dil model", "sohbet robot", "büyük dil", "=LLM", "yapay zekâ asistan"], "desen_en": ["language model", "chatbot", "=LLM", "AI assistant"], "haric_tr": [], "haric_en": []},
  "karar": {"desen_tr": ["karar destek", "tavsiye"], "desen_en": ["decision support", "decision-support", "recommendation", "advice engine"], "haric_tr": [], "haric_en": ["=Recommendation of the Council"]},
  "veri": {"desen_tr": ["veri platform", "açık veri", "veri paylaş", "veri alanı", "veri alanları", "veri sahipliğ", "veri tabanı", "verisine erişim", "veriye erişim", "kayıt sistem", "=Veri Tüzüğü"], "desen_en": ["data platform", "open data", "data sharing", "data space", "data ownership", "database", "access to the data", "access to data", "registration system", "register", "=Data Act"], "haric_tr": [], "haric_en": []},
  "genomik": {"desen_tr": ["genomik", "ıslah", "genetik"], "desen_en": ["genomic", "breeding", "genetic"], "haric_tr": [], "haric_en": []},
};

/// Teknolojinin asıl konu olduğu başlıklar (karar 57).
const Map<String, List<int>> kYzTeknolojiAna = {
  "goruntu": [8],
  "tahmin": [9, 17],
  "uzaktan": [19],
  "robotik": [10],
  "sensor": [20],
  "dil": [18],
  "karar": [],
  "veri": [21],
  "genomik": [5],
};

/// Python eşleştiricisinin her başlıkta saydığı paragraf (ve tablo satırı)
/// sayısı: {no: {teknoloji: [tr, en]}}. Yalnız eşlik testi için.
const Map<int, Map<String, List<int>>> kYzTeknolojiIzi = {
  1: {"goruntu": [3, 3], "tahmin": [3, 3], "uzaktan": [3, 3], "robotik": [2, 2], "sensor": [1, 1], "karar": [1, 1], "veri": [1, 1], "genomik": [1, 1]},
  2: {"goruntu": [1, 1], "tahmin": [5, 4], "uzaktan": [1, 1], "robotik": [6, 7], "sensor": [2, 2], "dil": [1, 1], "karar": [2, 2], "veri": [1, 1]},
  3: {"goruntu": [5, 5], "tahmin": [6, 3], "uzaktan": [7, 7], "robotik": [1, 0], "sensor": [1, 1], "dil": [2, 2], "karar": [0, 1], "veri": [3, 4]},
  4: {"tahmin": [5, 5], "uzaktan": [1, 1], "veri": [0, 1]},
  5: {"goruntu": [1, 0], "tahmin": [4, 4], "sensor": [2, 2], "genomik": [14, 12]},
  6: {"tahmin": [2, 2], "uzaktan": [3, 3], "robotik": [1, 1], "sensor": [4, 4], "karar": [2, 2], "veri": [1, 0]},
  7: {"tahmin": [2, 1], "uzaktan": [2, 2], "sensor": [7, 7], "karar": [2, 2]},
  8: {"goruntu": [7, 7], "tahmin": [1, 0]},
  9: {"goruntu": [0, 1], "tahmin": [13, 11], "uzaktan": [8, 7], "veri": [1, 1]},
  10: {"goruntu": [3, 3], "robotik": [11, 11], "karar": [0, 2]},
  11: {"goruntu": [4, 4], "sensor": [1, 1]},
  12: {"goruntu": [2, 2], "tahmin": [2, 2], "robotik": [2, 2], "sensor": [4, 4], "genomik": [8, 8]},
  13: {"goruntu": [1, 1], "robotik": [3, 3], "sensor": [1, 1]},
  14: {"goruntu": [2, 2], "tahmin": [2, 1], "uzaktan": [4, 4], "sensor": [1, 1]},
  15: {"goruntu": [6, 6], "tahmin": [3, 2], "uzaktan": [6, 5], "karar": [2, 2]},
  16: {"tahmin": [7, 8], "veri": [3, 4]},
  17: {"tahmin": [7, 6], "uzaktan": [8, 8], "sensor": [1, 1], "veri": [1, 1]},
  18: {"goruntu": [1, 1], "dil": [6, 6], "karar": [0, 1], "veri": [0, 1]},
  19: {"goruntu": [4, 3], "tahmin": [2, 2], "uzaktan": [9, 9], "karar": [1, 1], "veri": [2, 2]},
  20: {"tahmin": [1, 0], "sensor": [5, 6], "veri": [1, 1]},
  21: {"sensor": [1, 1], "veri": [7, 9]},
  22: {"tahmin": [3, 2], "robotik": [5, 5], "dil": [2, 2], "veri": [0, 2]},
  23: {"goruntu": [2, 2], "tahmin": [4, 5], "uzaktan": [7, 7], "robotik": [4, 4], "karar": [2, 3], "veri": [1, 1]},
  24: {"tahmin": [0, 1], "uzaktan": [1, 1], "robotik": [1, 1], "veri": [3, 3]},
  25: {"goruntu": [7, 6], "tahmin": [5, 6], "uzaktan": [12, 12], "robotik": [7, 7], "sensor": [9, 9], "dil": [1, 1], "karar": [1, 2], "veri": [2, 2]},
  26: {"goruntu": [2, 2], "tahmin": [1, 0], "uzaktan": [1, 1], "robotik": [2, 2], "sensor": [1, 1], "veri": [1, 1]},
  27: {"goruntu": [1, 1], "tahmin": [2, 1], "robotik": [4, 4], "sensor": [1, 1], "karar": [1, 1], "veri": [0, 2]},
  28: {"goruntu": [2, 2], "tahmin": [2, 1], "uzaktan": [2, 2], "robotik": [1, 1], "sensor": [5, 5], "karar": [0, 1]},
};
