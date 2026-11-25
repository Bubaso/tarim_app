// ÜRETİLMİŞ DOSYA — ELLE DEĞİŞTİRİLMEZ.
// Kaynak: content/yapay_zeka_dijital_tarim/_raw/sahadan.json
// Üretici: content/yapay_zeka_dijital_tarim/dart_uret.py (_raw/sahadan_uret.py)
//
// Sahadan galerisi (25 Kasım 2026): Türkiye'de dijital tarımın sahadan
// fotoğrafları, her biri yayımlayan kurumun künyesi ve kaynağıyla. Galeri,
// atlasın "Fotoğraf" kayıtları ve merkez kartı buradan. YALNIZ erteli
// paketten içe aktarılır (test/yz_erteli_test.dart).

class YzSahadanKare {
  const YzSahadanKare({
    required this.harf,
    required this.kimlik,
    required this.adres,
    required this.genislik,
    required this.yukseklik,
    required this.kunyeTr,
    required this.kunyeEn,
    required this.kaynakTr,
    required this.kaynakEn,
    required this.sayfaAdresi,
    required this.tarih,
    required this.baslikNo,
    this.il,
    this.plaka,
    this.bolumTr,
    this.bolumEn,
    this.metinde = false,
    this.merkez = false,
  });

  /// Sahibin seçimindeki harf (A-H): galerinin sırası.
  final String harf;
  final String kimlik;

  /// Sitedeki yolu (`/yz/gorsel/…webp`).
  final String adres;
  final int genislik;
  final int yukseklik;

  /// Fotoğrafın ne olduğu (proje ya da sistem, yer, tarih).
  final String kunyeTr, kunyeEn;

  /// "Fotoğraf: <yayımlayan kurum>".
  final String kaynakTr, kaynakEn;

  /// Fotoğrafın yayımlandığı sayfa ("Kaynağı aç").
  final String sayfaAdresi;

  /// Kaynak sayfanın tarihi (YYYY-AA-GG).
  final String tarih;

  /// İlgili başlık ve alt başlığı (`?bolum=`).
  final int baslikNo;
  final String? bolumTr, bolumEn;

  /// Karenin ili; null ise atlasta yok.
  final String? il;
  final int? plaka;

  /// Başlık içinde de duruyor (gorseller.json'da aynı kimlik ve dosya).
  final bool metinde;

  /// Merkez sayfadaki kartın küçük resimlerinden.
  final bool merkez;

  String kunye(bool en) => en ? kunyeEn : kunyeTr;
  String kaynak(bool en) => en ? kaynakEn : kaynakTr;
  String? bolum(bool en) => en ? bolumEn : bolumTr;
  double get oran => yukseklik == 0 ? 1.5 : genislik / yukseklik;
}

/// Galerinin sırasıyla (harf).
const List<YzSahadanKare> kYzSahadan = [
  YzSahadanKare(
    harf: "A",
    kimlik: "sahadan-kocaeli-akilli-zirai-mucadele-1",
    adres: "/yz/gorsel/sahadan-kocaeli-akilli-zirai-mucadele-1.webp",
    genislik: 800,
    yukseklik: 600,
    kunyeTr: "Kocaeli Büyükşehir Belediyesi ile Kocaeli İl Tarım ve Orman Müdürlüğü'nün Akıllı Zirai Mücadele Projesi'nin Kandıra'daki pilot uygulaması (Selimköy): tarlalar dron ve İHA ile havadan tarandı, akıllı zararlı tuzakları kuruldu. Kocaeli Büyükşehir Belediyesi'nin 18 Eylül 2026 tarihli haberinden.",
    kunyeEn: "The Kandıra pilot (Selimköy) of the Smart Plant Protection Project run by Kocaeli Metropolitan Municipality and the Kocaeli Provincial Directorate of Agriculture and Forestry: fields were scanned from the air by drone and UAV, and smart pest traps were installed. From Kocaeli Metropolitan Municipality's news item of 18 September 2026.",
    kaynakTr: "Fotoğraf: Kocaeli Büyükşehir Belediyesi",
    kaynakEn: "Photo: Kocaeli Metropolitan Municipality",
    sayfaAdresi: "https://www.kocaeli.bel.tr/haber/kocaelide-yapay-zeka-tarlaya-indi-52013.html",
    tarih: "2026-09-18",
    baslikNo: 20,
    il: "Kocaeli",
    plaka: 41,
    bolumTr: "Türkiye",
    bolumEn: "Türkiye",
    merkez: true,
  ),
  YzSahadanKare(
    harf: "B",
    kimlik: "sahadan-kocaeli-akilli-zirai-mucadele-2",
    adres: "/yz/gorsel/sahadan-kocaeli-akilli-zirai-mucadele-2.webp",
    genislik: 800,
    yukseklik: 449,
    kunyeTr: "Kocaeli Büyükşehir Belediyesi ile Kocaeli İl Tarım ve Orman Müdürlüğü'nün Akıllı Zirai Mücadele Projesi'nin Kandıra'daki pilot uygulaması (Selimköy): tarlalar dron ve İHA ile havadan tarandı, akıllı zararlı tuzakları kuruldu. Kocaeli Büyükşehir Belediyesi'nin 18 Eylül 2026 tarihli haberinden.",
    kunyeEn: "The Kandıra pilot (Selimköy) of the Smart Plant Protection Project run by Kocaeli Metropolitan Municipality and the Kocaeli Provincial Directorate of Agriculture and Forestry: fields were scanned from the air by drone and UAV, and smart pest traps were installed. From Kocaeli Metropolitan Municipality's news item of 18 September 2026.",
    kaynakTr: "Fotoğraf: Kocaeli Büyükşehir Belediyesi",
    kaynakEn: "Photo: Kocaeli Metropolitan Municipality",
    sayfaAdresi: "https://www.kocaeli.bel.tr/haber/kocaelide-yapay-zeka-tarlaya-indi-52013.html",
    tarih: "2026-09-18",
    baslikNo: 20,
    il: "Kocaeli",
    plaka: 41,
    bolumTr: "Türkiye",
    bolumEn: "Türkiye",
  ),
  YzSahadanKare(
    harf: "C",
    kimlik: "sahadan-elazig-tahmin-ve-uyari-istasyonu",
    adres: "/yz/gorsel/sahadan-elazig-tahmin-ve-uyari-istasyonu.webp",
    genislik: 1600,
    yukseklik: 1066,
    kunyeTr: "Elazığ İl Tarım ve Orman Müdürlüğü'nün 2022'de projelendirdiği tahmin ve uyarı istasyonlarının Çatalharman köyünde faaliyete geçen beşincisi; müdürlüğün 26 Mayıs 2023 tarihli haberinden.",
    kunyeEn: "The fifth of the forecasting and warning stations planned by the Elazığ Provincial Directorate of Agriculture and Forestry in 2022, put into service in Çatalharman village; from the directorate's news item of 26 May 2023.",
    kaynakTr: "Fotoğraf: Elazığ İl Tarım ve Orman Müdürlüğü",
    kaynakEn: "Photo: Elazığ Provincial Directorate of Agriculture and Forestry",
    sayfaAdresi: "https://elazig.tarimorman.gov.tr/Haber/1355/Tahmin-Ve-Uyari-Istasyonunun-5-Si-Catalharman-Koyunde-Kuruldu",
    tarih: "2023-05-26",
    baslikNo: 20,
    il: "Elazığ",
    plaka: 23,
    bolumTr: "Türkiye",
    bolumEn: "Türkiye",
  ),
  YzSahadanKare(
    harf: "D",
    kimlik: "b03-tarbil-zirai-gozlem-ve-meteoroloji",
    adres: "/yz/gorsel/b03-tarbil-zirai-gozlem-ve-meteoroloji.webp",
    genislik: 1600,
    yukseklik: 900,
    kunyeTr: "Tarımsal İzleme ve Bilgi Sistemi (TARBİL) kapsamında Kırşehir'de kurulan zirai gözlem ve meteoroloji yer istasyonları; Kırşehir İl Tarım ve Orman Müdürlüğü'nün, ilde İTÜ iş birliğiyle 12 istasyon kurulduğunu duyuran 23 Ocak 2015 tarihli haberinin fotoğraf galerisinden.",
    kunyeEn: "TARBİL (Agricultural Monitoring and Information System) agro-meteorological ground observation stations in Kırşehir province; from the photo gallery of the Kırşehir Provincial Directorate of Agriculture and Forestry's news item of 23 January 2015 announcing 12 stations set up in the province in cooperation with Istanbul Technical University.",
    kaynakTr: "Fotoğraf: Kırşehir İl Tarım ve Orman Müdürlüğü",
    kaynakEn: "Photo: Kırşehir Provincial Directorate of Agriculture and Forestry",
    sayfaAdresi: "https://kirsehir.tarimorman.gov.tr/Haber/75/Ilimizde-Tarbil-Projesi-Kapsaminda-12-Adet-Zirai-Gozlem-Yer-Istasyonu-Kuruldu",
    tarih: "2015-01-23",
    baslikNo: 3,
    il: "Kırşehir",
    plaka: 40,
    bolumTr: "Türkiye",
    bolumEn: "Türkiye",
    metinde: true,
  ),
  YzSahadanKare(
    harf: "E",
    kimlik: "b07-dijital-sulama-yonetim-sistemi-disu",
    adres: "/yz/gorsel/b07-dijital-sulama-yonetim-sistemi-disu.webp",
    genislik: 640,
    yukseklik: 512,
    kunyeTr: "Atatürk Toprak, Su ve Tarımsal Meteoroloji Araştırma Enstitüsü'nün geliştirdiği Dijital Sulama Yönetim Sistemi (DİSU) çalışmalarında deneme alanlarının İHA, multispektral ve termal kamera sistemiyle izlenmesi; enstitünün 9 Mayıs 2022 tarihli haberinden.",
    kunyeEn: "Monitoring of trial plots with a UAV, multispectral and thermal camera system in work on the Digital Irrigation Management System (DİSU) developed by the Atatürk Soil, Water and Agricultural Meteorology Research Institute; from the institute's news item of 9 May 2022.",
    kaynakTr: "Fotoğraf: Atatürk Toprak, Su ve Tarımsal Meteoroloji Araştırma Enstitüsü Müdürlüğü",
    kaynakEn: "Photo: Atatürk Soil, Water and Agricultural Meteorology Research Institute",
    sayfaAdresi: "https://arastirma.tarimorman.gov.tr/kirklarelitopraksu/Haber/85/Tarimda-Dijital-Sulama-Yonetimi-Siteminin-Gelistirilmesi-Calismalarimiz-Devam-Ediyor",
    tarih: "2022-05-09",
    baslikNo: 7,
    bolumTr: "Türkiye",
    bolumEn: "Türkiye",
    metinde: true,
  ),
  YzSahadanKare(
    harf: "F",
    kimlik: "b15-kamerali-insansiz-yangin-gozetleme",
    adres: "/yz/gorsel/b15-kamerali-insansiz-yangin-gozetleme.webp",
    genislik: 1600,
    yukseklik: 1067,
    kunyeTr: "Orman Genel Müdürlüğü ile Anadolu Sigorta'nın 'Ormanın Gözleri' projesi kapsamında Adana Orman Bölge Müdürlüğü'ne bağlı Balcalı Orman İşletme Şefliği yerleşkesine kurulan insansız yangın gözetleme kulesi: 50 metrelik kafes kule, yapay zekâ yazılımlı iki IP kamera. OGM'nin 8 Aralık 2022 tarihli açılış haberinden.",
    kunyeEn: "Unmanned fire lookout tower built at the Balcalı Forest Management Chiefdom of the Adana Regional Directorate of Forestry under the 'Eyes of the Forest' project of Türkiye's General Directorate of Forestry (OGM) and Anadolu Sigorta: a 50-metre lattice tower with two IP cameras running AI software. From OGM's opening news item of 8 December 2022.",
    kaynakTr: "Fotoğraf: Orman Genel Müdürlüğü",
    kaynakEn: "Photo: Orman Genel Müdürlüğü",
    sayfaAdresi: "https://www.ogm.gov.tr/tr/haberler/i%CC%87lk-i%CC%87nsansiz-yangin-gozetleme-kulesi-balcali%E2%80%99da-hizmete-acildi",
    tarih: "2022-12-08",
    baslikNo: 15,
    il: "Adana",
    plaka: 1,
    bolumTr: "Türkiye",
    bolumEn: "Türkiye",
    metinde: true,
    merkez: true,
  ),
  YzSahadanKare(
    harf: "G",
    kimlik: "sahadan-cankiri-zirai-iha-ile-celtik-ekimi",
    adres: "/yz/gorsel/sahadan-cankiri-zirai-iha-ile-celtik-ekimi.webp",
    genislik: 1365,
    yukseklik: 768,
    kunyeTr: "Çankırı'nın Kızılırmak ilçesi Kavlaklı köyünde, Kızılırmak İlçe Tarım ve Orman Müdürlüğü koordinasyonunda başlayan çeltik ekimi; ekim elle, traktörle ve zirai İHA (dron) ile yapıldı. Çankırı İl Tarım ve Orman Müdürlüğü'nün 22 Mayıs 2024 tarihli haberinden.",
    kunyeEn: "Rice planting that began in Kavlaklı village, Kızılırmak district, Çankırı, coordinated by the Kızılırmak District Directorate of Agriculture and Forestry; planting was done by hand, by tractor and by agricultural UAV (drone). From the Çankırı Provincial Directorate of Agriculture and Forestry's news item of 22 May 2024.",
    kaynakTr: "Fotoğraf: Çankırı İl Tarım ve Orman Müdürlüğü",
    kaynakEn: "Photo: Çankırı Provincial Directorate of Agriculture and Forestry",
    sayfaAdresi: "https://cankiri.tarimorman.gov.tr/Sayfalar/Detay.aspx?TermStoreId=368e785b-af33-487d-a98d-c11d5495130b&TermSetId=74fd6fe8-0af5-45b7-a7b6-7836480b06f3&TermId=226376ed-398a-4280-8dd3-fdd2fa7abd05&UrlSuffix=1158/Cankirida-Celtik-Uretiminde-Zirai-Drone_iha_-Kullanimi-Yayginlasiyor",
    tarih: "2024-05-22",
    baslikNo: 6,
    il: "Çankırı",
    plaka: 18,
    bolumTr: "Türkiye",
    bolumEn: "Türkiye",
    merkez: true,
  ),
  YzSahadanKare(
    harf: "H",
    kimlik: "sahadan-antalya-akuaponik-sazan-ve-enginar",
    adres: "/yz/gorsel/sahadan-antalya-akuaponik-sazan-ve-enginar.webp",
    genislik: 1600,
    yukseklik: 1067,
    kunyeTr: "Akdeniz Su Ürünleri Araştırma, Üretme ve Eğitim Enstitüsü'nün (AKSAM) Kepez Birimi'nde, Batı Akdeniz Tarımsal Araştırma ve Eğirdir Su Ürünleri ve Meyvecilik Araştırma enstitüleriyle yürütülen ön projede sazan ve enginarın kapalı devre akuaponik sistemde birlikte yetiştirilmesi; enstitünün 3 Ağustos 2016 tarihli haberinden.",
    kunyeEn: "Carp and artichoke grown together in a closed-loop aquaponic system in a preliminary project at the Kepez Unit of the Mediterranean Fisheries Research, Production and Training Institute (AKSAM), run with the West Mediterranean Agricultural Research Institute and the Eğirdir Fisheries and Fruit Research institutes; from the institute's news item of 3 August 2016.",
    kaynakTr: "Fotoğraf: Akdeniz Su Ürünleri Araştırma, Üretme ve Eğitim Enstitüsü Müdürlüğü",
    kaynakEn: "Photo: Mediterranean Fisheries Research, Production and Training Institute",
    sayfaAdresi: "https://arastirma.tarimorman.gov.tr/akdenizsuurunleri/Haber/33/Balik-Ve-Sebze-Akuaponikte-Bulusuyor",
    tarih: "2016-08-03",
    baslikNo: 14,
    il: "Antalya",
    plaka: 7,
    bolumTr: "Türkiye",
    bolumEn: "Türkiye",
  ),
];
