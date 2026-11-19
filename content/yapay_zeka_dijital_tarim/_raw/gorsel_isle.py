#!/usr/bin/env python3
"""
Yapay Zeka ve Dijital Tarım — görsel adaylarını işler (karar 58).

    python3 -I gorsel_isle.py <aday_klasörü> [--kuru]

Aday klasöründe gorsel_adaylari.json (birleşik) ya da gorsel_adaylari_parca_*.json.

Aday klasöründeki `gorsel_adaylari_parca_*.json` dosyalarını okur; seçilen
her adayı `gorsel_al.py` ile indirip WebP'ye çevirir (web/yz/gorsel/),
`gorseller.json`'a künye, kaynak satırı, adres ve indirme günüyle yazar ve
[[gorsel:…]] yönergesini TR metinde adayın paragrafının ardına (kayıtta
`konum: "önce"` ise önüne; `yer` her durumda görselin anlattığı paragraf),
EN metinde aynı blok sırasına yerleştirir. [[cekme:…]] ve tanınmayan
yönerge satırları blok sayılmaz. Tekrar çalıştırmada var olanı yeniden
indirmez, yönergeyi ikinci kez eklemez.

Seçim ilkesi: bilgi taşıyan, metinde adı geçen gerçek şeyin görseli. Bizim
grafiklerimizin ya da metindeki bir tablonun aynısı olan kaynak grafikleri,
rapor ve broşür kapakları, logolar alınmaz. PDF içindeki şekiller ayrı adımda
(sayfadan kırpılarak) işlenir.
"""
from __future__ import annotations

import json
import re
import subprocess
import sys
import time
import unicodedata
from pathlib import Path

BURASI = Path(__file__).resolve().parent
BOLUMLER = BURASI.parent / "bolumler"
KAYIT = BURASI / "gorseller.json"
DEPO = BURASI.parents[2]
PYTHON = Path.home() / "tarim_ai_pipeline/venv/bin/python"

# Alınmayanlar (konu başı): grafiğimizin ya da tablonun aynısı, kapak, logo.
ALINMAZ = (
    "AB'de hassas tarım uygulayan çiftliklerin",          # §1 — b01 grafiği
    "ABD'de değişken oranlı teknolojinin ekili alandaki",  # §6 — b06-vrt grafiği
    "Geleneksel ve hermetik depolamada tahıl kayıpları",   # §11 — b11 grafiği
    "Holstein'da genomik seçilim öncesi ve sonrası",       # §12 — metindeki tablo
    "Hindistan'da tarım ürünü fiyat tahmini",              # §16 — b16 grafiği
    "GPT-4o ve Gemini'nin tarım sorularındaki",            # §18 — b18 grafiği
    "AB tarımsal veri paylaşımı davranış kuralları",       # broşür kapağı
    "FAO Gıda ve Tarımın Durumu 2022 raporu",              # rapor kapağı
    "Infarm şirket logosu", "AppHarvest şirket logosu",   # logo
    "Zhou ve ark. (2022) derlemesinde",                    # şekil altyazısı doğrulanamadı
    "Türkiye'de tahıl hasadında biçerdöver",               # genel kare (süs)
    "Digital Green'in FarmerChat sohbet robotunun",        # aynı şekil dil sayfasında
    "De Lara ve ark. (2023): Arjantin'deki",               # aynı şekil uzaktan sayfasında
    "Ulusal Arazi Örtüsü Sınıflandırma ve İzleme",         # Programdaki tedbirle bağı kaynakta yok
    "İzmir'deki ıslah kampüsünde LED",                     # tesisin ne olduğu kaynakta yazmıyor
    "SoilGrids 2.0'ın üretim iş akışı",                    # §4'te SoilGrids şekli yeterli
    "Hands Free Hectare'de otonom traktörle ekim",         # §28'de aynı projenin görseli var
    "Silalatshani'de bir çiftçinin mısırında",             # aynı denemenin ikinci şekli
)

# Kaynak satırındaki iç notlar okura gitmez.
IC_NOT = re.compile(r";\s*(PMC kopyası|sayfada fotoğraf künyesi yok)\s*$")

KAYNAK_EN = {  # düz çeviriyle olmayanlar
    "Görsel: Toprak, Gübre ve Su Kaynakları Merkez Araştırma Enstitüsü; harita © FAO 2017 (GSOCmap V1.0)":
        "Image: Soil, Fertilizer and Water Resources Central Research Institute; map © FAO 2017 (GSOCmap V1.0)",
    "Görsel: Saikai, Peake ve Chenu 2023, PLOS Water (CC BY 4.0)":
        "Image: Saikai, Peake and Chenu 2023, PLOS Water (CC BY 4.0)",
    "Görsel: Mohanty, Hughes ve Salathé 2016, Frontiers in Plant Science (CC BY 4.0)":
        "Image: Mohanty, Hughes and Salathé 2016, Frontiers in Plant Science (CC BY 4.0)",
    "Görsel: ESA; Copernicus Sentinel ve Landsat verisi (2015-16), işleme: Humboldt Üniversitesi Berlin / P. Griffiths ve ZALF (ESA Standard Licence)":
        "Image: ESA; Copernicus Sentinel and Landsat data (2015–16), processed by Humboldt University of Berlin / P. Griffiths and ZALF (ESA Standard Licence)",
    "Görsel: Copernicus / ESA–Sen4CAP (UCLouvain, CS-Romania, e-GEOS, GISAT, Sinergise); değiştirilmiş Copernicus Sentinel verisi (2017)":
        "Image: Copernicus / ESA–Sen4CAP (UCLouvain, CS-Romania, e-GEOS, GISAT, Sinergise); contains modified Copernicus Sentinel data (2017)",
    "Görsel: Altun ve Türker 2021, AKÜ FEMÜBİD 21 (CC BY-NC 4.0)":
        "Image: Altun and Türker 2021, AKÜ FEMÜBİD 21 (CC BY-NC 4.0)",
    "Görsel: Gadalla ve Öztekin 2023, Tekirdağ Ziraat Fakültesi Dergisi 20(4) (CC BY-NC 4.0)":
        "Image: Gadalla and Öztekin 2023, Tekirdağ Ziraat Fakültesi Dergisi 20(4) (CC BY-NC 4.0)",
    "Görsel: Balendonck, Stenfert Kroese, Hilhorst ve Tüzel, AquaTag proje broşürü (Wageningen UR, SensorTagSolutions, Ege Üniversitesi)":
        "Image: Balendonck, Stenfert Kroese, Hilhorst and Tüzel, AquaTag project brochure (Wageningen UR, SensorTagSolutions, Ege University)",
    "Harita: Lang N., Jetz W., Schindler K., Wegner J.D. (ETH Zürih), 'A high-resolution canopy height model of the Earth' proje sayfası (veri ürünü CC BY 4.0)":
        "Map: Lang N., Jetz W., Schindler K., Wegner J.D. (ETH Zurich), 'A high-resolution canopy height model of the Earth' project page (data product CC BY 4.0)",
    "Görsel: Tarım ve Orman Bakanlığı / Bolu İl Tarım ve Orman Müdürlüğü":
        "Image: Ministry of Agriculture and Forestry / Bolu Provincial Directorate of Agriculture and Forestry",
    "Fotoğraf: Oklahoma Eyalet Üniversitesi, Azot Kullanım Etkinliği (NUE) sayfası":
        "Photo: Oklahoma State University, Nitrogen Use Efficiency (NUE) page",
    "Görsel: Şimşek 2023, Türk Uzaktan Algılama ve CBS Dergisi 4(2) (CC BY-NC-ND 4.0)":
        "Image: Şimşek 2023, Türk Uzaktan Algılama ve CBS Dergisi 4(2) (CC BY-NC-ND 4.0)",
}
ON_EK = {"Fotoğraf: ": "Photo: ", "Görsel: ": "Image: ", "Görüntü: ": "Image: ", "Şekil: ": "Figure: ",
         "Harita: ": "Map: ", "Grafik: ": "Chart: ", "Şema: ": "Diagram: "}
SOZ = [
    (" ve ark.", " et al."), (", Şekil ", ", Fig. "), ("Şekil ", "Fig. "), ("(kamu malı)", "(public domain)"),
    ("Wikimedia Commons üzerinden", "via Wikimedia Commons"), ("(basın bülteni görseli)", "(press release image)"),
    ("(tanıtım görseli)", "(promotional image)"), ("(tanıtım şeması)", "(promotional diagram)"),
    ("(ürün görseli)", "(product image)"),
    ("(şirket sitesindeki ürün ekran görüntüsü)", "(product screenshot from the company website)"),
    (" İl Tarım ve Orman Müdürlüğü", " Provincial Directorate of Agriculture and Forestry"),
    ("Avrupa Komisyonu", "European Commission"), (" haberi", " news item"), (" basın odası", " press room"),
    ("FIgLib arşivi", "FIgLib archive"), ("GRACE-FO verisi", "GRACE-FO data"),
    ("MODIS Atmosphere Science Team verisi", "MODIS Atmosphere Science Team data"),
    ("McFadden ve Njuki", "McFadden and Njuki"), ("Kumar ve Kalita", "Kumar and Kalita"),
]

# PDF içindeki şekiller: (yerel kopya [kaynak_dosyalari/] ya da None → adresten indir, sayfa, kutu).
# Kutu sayfanın 0-1 kesirleri; sayfa çizimlerine bakılarak belirlendi (18 Kas 2026).
KIRP = {
    "https://edepot.wur.nl/283306": ("aquatag_wur_283306.pdf", 1, "0.029,0.548,0.484,0.713"),
    "https://dergipark.org.tr/tr/download/article-file/1615376": ("altun_turker_2021_kiziltepe.pdf", 11, "0.093,0.064,0.913,0.438"),
    "https://dergipark.org.tr/tr/download/article-file/3023466": ("simsek_2023_apts_siniflandirma.pdf", 11, "0.104,0.285,0.913,0.759"),
    "https://dergipark.org.tr/en/download/article-file/4074610": (None, 16, "0.214,0.154,0.848,0.330"),
    "https://dergipark.org.tr/en/download/article-file/2608585": (None, 4, "0.224,0.564,0.795,0.721"),
    "https://dergipark.org.tr/en/download/article-file/1201243": ("civelek_2022_tarim_bilimleri_dergisi.pdf", 3, "0.127,0.449,0.876,0.598"),
    # İkinci tur (18 Kas 2026)
    'https://oar.icrisat.org/11550/1/The%20dynamics%20between%20irrigation%20frequency%20and%20soil%20nutrient%20management%20transitioning%20smallholder%20irrigation%20towards%20more%20profitable%20and%20sustainable.pdf': (None, 7, '0.279,0.492,0.721,0.821'),
    'https://assets.gov.ie/static/documents/3864056a/1._Responding_to_an_AMS_Notification_July_2026.pdf': (None, 23, '0.119,0.575,0.775,0.908'),
    'https://ers.usda.gov/sites/default/files/_laserfiche/publications/105894/EIB-248.pdf?v=27908': (None, 12, '0.115,0.080,0.885,0.632'),
    'https://www.cema-agri.org/images/publications/position-papers/CEMA_Digital_Farming_-_Agriculture_4.0__13_02_2017_0.pdf': (None, 2, '0.390,0.246,0.886,0.466'),
    'https://ntrs.nasa.gov/api/citations/19790010237/downloads/19790010237.pdf': (None, 24, '0.165,0.142,0.910,0.776'),
    'https://www.fao.org/3/a-i5316e.pdf': (None, 71, '0.143,0.600,0.828,0.848'),
    'https://dergipark.org.tr/en/download/article-file/2752142': (None, 5, '0.296,0.425,0.704,0.855'),
    'https://dergipark.org.tr/tr/download/article-file/3870675': (None, 5, '0.140,0.115,0.866,0.502'),
    'https://arastirma.tarimorman.gov.tr/toprakgubre/Belgeler/Tar%C4%B1msal%20%C3%9Cr%C3%BCn%20%C4%B0zleme%20ve%20Verim%20Tahmin%20B%C3%BClteni/AGROSENS%20-%20Agrometeoroloji%20ve%20Uzaktan%20Alg%C4%B1lama%20Destekli%20Tar%C4%B1msal%20%C4%B0zleme%20B%C3%BClteni%20Nisan%202026.pdf': (None, 5, '0.096,0.136,0.903,0.361'),
    'https://dergipark.org.tr/en/download/article-file/2622098': (None, 5, '0.155,0.104,0.844,0.394'),
    'https://mdpi-res.com/d_attachment/remotesensing/remotesensing-12-00166/article_deploy/remotesensing-12-00166.pdf': (None, 6, '0.130,0.400,0.873,0.779'),
    'https://ccsenet.org/journal/index.php/jas/article/download/0/0/49707/53720': (None, 11, '0.482,0.084,0.772,0.515'),
    'https://dergipark.org.tr/tr/download/article-file/3187958': (None, 11, '0.113,0.640,0.886,0.869'),
}

# Künye düzeltmeleri: künye görselin ne olduğudur; şerh ve yorum girmez.
KUNYE = {
    "b02-ers-nin-dijital-tarim-bilesenleri": {
        "tr": "ABD Tarım Bakanlığı Ekonomik Araştırma Servisi'nin (ERS) dijital tarımın temel bileşen teknolojilerini veri ve "
              "veri toplama, karar destek ve veriye dayalı ekipman ve girdi ayarlaması olarak üç grupta gösteren şemasının "
              "Türkçeye uyarlanmış hâli; özgünü McFadden, Njuki ve Griffin'in Şubat 2023 tarihli 'Precision Agriculture in "
              "the Digital Era: Recent Adoption on U.S. Farms' raporunun (EIB-248) 2. şekli.",
        "en": None,
    },
    "b02-cema-nin-dijital-tarim-tarifi": {
        "tr": "Avrupa tarım makineleri sanayi birliği CEMA'nın çiftlik düzeyinde dijital tarım ağını örnekleyen şemasının "
              "(makineler, ISOBUS, GPS, veri portalları ve çiftliğin iş ortakları) Türkçeye uyarlanmış hâli; özgünü CEMA'nın "
              "13 Şubat 2017 tarihli 'Digital Farming: what does it really mean?' tutum belgesinin 1. şekli.",
        "en": None,
    },
    "t-dil-digital-green-in-sohbet-robotu": {
        "tr": "Digital Green'in üretken yapay zekâyla çalışan sohbet robotu Farmer.Chat'in etkileşim akışını gösteren şemanın "
              "Türkçeye uyarlanmış hâli: Telegram üzerinden katılım, dil ve değer zinciri seçimi, soru-yanıt ve takip soruları, "
              "geri bildirim ve hatırlatmalar; özgünü geliştiricilerinin arXiv'de yayımlanan makalesinin (Singh ve ark., 2024) "
              "Şekil 1'i.",
        "en": None,
    },
    "b01-ecmwf-nin-yapay-zeka-tahmin-sistemi": {
        "tr": "ECMWF'nin yapay zekâ tahmin sistemi AIFS'i sadeleştirilmiş biçimde anlatan bilgi şemasının Türkçeye "
              "uyarlanmış hâli; özgün şema, AIFS'in 25 Şubat 2025'te işletime alındığını duyuran ECMWF haberinde yayımlandı.",
        "en": None,  # özgün İngilizce künye kalır
    },
    "b06-bitki-ortusu-sensoruyle-azot": {
        "tr": "Nebraska Üniversitesi–Lincoln'ün Project SENSE çalışmasını tanıtan CropWatch yazısındaki yüksek "
              "açıklıklı uygulama makinesi; çalışma, mısırda bitki örtüsü sensörüne dayalı sezon içi değişken oranlı "
              "azot uygulamasını çiftlik denemeleriyle sınıyor. Yazı 2 Aralık 2014 tarihli.",
        "en": "A high-clearance applicator in UNL CropWatch's article introducing Project SENSE, an on-farm research "
              "project testing in-season, crop-canopy-sensor-based variable-rate nitrogen application in corn. "
              "Article dated 2 December 2014.",
    },
}


# Kaynak satırı düzeltmeleri (ör. Türkçe uyarlama).
KAYNAK = {
    "b01-ecmwf-nin-yapay-zeka-tahmin-sistemi": {"tr": "Görsel: ECMWF (CC BY 4.0); Türkçeye uyarlandı", "en": None},
    "b02-ers-nin-dijital-tarim-bilesenleri": {
        "tr": "Şekil: McFadden, Njuki ve Griffin 2023, USDA ERS, EIB-248, Şekil 2 (kamu malı); Türkçeye uyarlandı", "en": None},
    "b02-cema-nin-dijital-tarim-tarifi": {
        "tr": "Şekil: CEMA 2017, 'Digital Farming: what does it really mean?', Şekil 1; Türkçeye uyarlandı", "en": None},
    "t-dil-digital-green-in-sohbet-robotu": {
        "tr": "Şekil: Singh N. ve ark. 2024, Farmer.Chat, arXiv:2409.08916, Şekil 1 (CC BY-NC-SA 4.0); Türkçeye uyarlandı",
        "en": None},
}


# Lejant çevirisi (karar 60, ○ 16): yazısı İngilizce kalan haritalarda Türkçe
# sayfa görselin altında görseldeki yazıların karşılığını veriyor. Yalnız
# Türkçe; künye değil (görselin ne olduğu künyede).
LEJANT = {
    "b06-degisken-oranli-ekim-recete-haritasi":
        "Görseldeki yazılar: 32,000 / 28,000 / 24,000 spa = akre başına 32.000 / 28.000 / 24.000 tohum "
        "(spa: seeds per acre).",
    "b06-soya-ekim-sikligi-ciftlik":
        "Görseldeki yazılar: Data-intensive prescription research layout for the Saunders County site = "
        "Saunders County'deki veri yoğun reçete denemesinin parsel düzeni; Soybean Prescription Target Rate "
        "(sds/ac) = soya reçetesinde hedef ekim sıklığı (akre başına tohum); Feet = fit.",
    "b09-makine-ogrenmesiyle-almanya-urun":
        "Görseldeki yazılar: Germany's agricultural landscape = Almanya'nın tarım peyzajı; Grassland = "
        "çayır-mera; Winter Wheat & Triticale = kışlık buğday ve tritikale; Winter Rye = kışlık çavdar; "
        "Winter Barley = kışlık arpa; Winter Spelt = kışlık kavılca; Maize = mısır; Winter Rapeseed = "
        "kışlık kolza; Summer Cereals = yazlık tahıllar; Lupine = acı bakla; Sugar Beet = şeker pancarı; "
        "Sunflower = ayçiçeği; Potatoes = patates; Beans = bakla ve fasulye; Peas = bezelye; Soy = soya; "
        "Orchards & Vineyards = meyve bahçeleri ve bağlar; Deciduous & Mixed Forest = yaprak döken ve "
        "karışık orman; Coniferous Forest = iğne yapraklı orman; Built-up = yerleşim; Water = su; "
        "Other = diğer.",
    "b09-sen4cap-sentinel-1-ve-sentinel-2-ile":
        "Görseldeki yazılar: Agricultural landscape of the Netherlands = Hollanda'nın tarım peyzajı; "
        "Oat = yulaf; Sugar beet = şeker pancarı; Clover root = üçgül kökü; Winter barley = kışlık arpa; "
        "Summer barley = yazlık arpa; Lilium = zambak; Medicago = yonca; Onion = soğan; Potato = patates; "
        "Tulip = lale; Winter carrot = kışlık havuç; Winter wheat = kışlık buğday; Maize = mısır; "
        "Permanent crops = çok yıllık bitkiler; Grass = çayır; Summer wheat = yazlık buğday; "
        "Fallow = nadas; Other crops = diğer ürünler.",
    "b14-kamuya-acik-izlemede-gorunmeyen":
        "Görseldeki yazılar: a Industrial fishing vessels = a endüstriyel balıkçı gemileri; b Transport "
        "and energy vessels = b taşıma ve enerji gemileri; publicly tracked = kamuya açık izlenen; "
        "Fraction of vessels publicly tracked per km² = kilometrekare başına kamuya açık izlenen gemilerin "
        "payı; Industrial fishing / Transport and energy (number of vessels) = endüstriyel balıkçılık / "
        "taşıma ve enerji (gemi sayısı); Asia = Asya; Europe = Avrupa; N. America = Kuzey Amerika; "
        "Africa = Afrika; S. America = Güney Amerika; Australia = Avustralya; Not publicly tracked = "
        "kamuya açık izlenmeyen; Publicly tracked = kamuya açık izlenen.",
    "b14-global-fishing-watch-yapay-zeka-ve":
        "Görseldeki yazılar: Offshore infrastructure = açık deniz yapıları; Oil platforms = petrol "
        "platformları; Wind turbines = rüzgâr türbinleri; Vessel activity = gemi hareketleri; Oil vessels "
        "= petrol gemileri; Wind vessels = rüzgâr santrali gemileri; Fishing vessels = balıkçı gemileri; "
        "Non-fishing vessels = balıkçılık dışı gemiler.",
    "b02-verim-haritasi":
        "Görseldeki yazılar: Estimated Volume (Dry) (bu/ac) = tahmini kuru verim (akre başına buşel); "
        "parantez içindeki ac = sınıfın kapladığı alan (akre).",
    "b11-meyve-boylamasinda-makine-gorusunun":
        "Görseldeki yazılar: Emlid GNSS = Emlid GNSS alıcısı; LED light panels = LED aydınlatma "
        "panelleri; Basler cameras = Basler kameraları; Generator = jeneratör; Computer = bilgisayar.",
    "t-goruntu-avustralya-seker-kamisi":
        "Görseldeki yazılar: Spray Application = ilaç atılan alan; Spray Trial Boundary = deneme alanının "
        "sınırı; Spray Trial 1-6 = ilaçlama denemesi 1-6.",
    "t-sensor-nebraska-da-bitki-ortusu-sensoruyle":
        "Görseldeki yazılar: 2020 Sites / 2019 Sites = 2020 / 2019 deneme yerleri; NE_Cities = Nebraska "
        "kentleri; NE_NRDs = Nebraska doğal kaynak bölgeleri; NE_Counties = Nebraska ilçeleri; Treatments "
        "= uygulamalar; Active Sensor Management = aktif sensörle yönetim; Grower = üreticinin uygulaması; "
        "High N Reference = yüksek azotlu karşılaştırma; Rate Block - Grower Timing = doz bloğu, üreticinin "
        "zamanlaması; Rate Block - Sensor-Based Timing = doz bloğu, sensöre dayalı zamanlama.",
    "b28-digital-green-video-egitimi":
        "Görseldeki yazılar: Treatments = gruplar; Any DG = Digital Green'in videolu eğitimi; Control = "
        "karşılaştırma grubu (yalnız yüz yüze eğitim).",
}


def kunye_duzelt(gorseller: dict) -> None:
    for k, g in gorseller.items():
        for alan, tablo in (("kunye", KUNYE), ("kaynak", KAYNAK)):
            for dil, metin in tablo.get(k, {}).items():
                if metin:
                    g[alan][dil] = metin
        for dil in ("tr", "en"):
            m = g["kunye"][dil].rstrip()
            g["kunye"][dil] = m if m.endswith((".", "!", "?")) else m + "."
        turkce_kopya(k, g)
        if k in LEJANT:
            g["lejant"] = {"tr": LEJANT[k]}
        else:
            g.pop("lejant", None)


GORSEL_KLASORU = BURASI.parents[2] / "web" / "yz" / "gorsel"
UYARLANDI = "; Türkçeye uyarlandı"


def turkce_kopya(kimlik: str, g: dict) -> None:
    """Türkçeye uyarlanmış kopya (karar 60): İngilizce yazılı şekil ve
    grafiğin yazıları Türkçeye çevrilmiş hâli `web/yz/gorsel/<kimlik>.tr.webp`
    (gorsel_turkce.py üretiyor). Varsa Türkçe sayfa onu gösterir; kaynak
    satırı uyarlandığını söyler. Künye değişmez: görsel aynı görsel."""
    import hashlib
    yol = GORSEL_KLASORU / f"{kimlik}.tr.webp"
    if yol.exists():
        g["dosya_tr"] = f"web/yz/gorsel/{kimlik}.tr.webp"
        g["sha256_tr"] = hashlib.sha256(yol.read_bytes()).hexdigest()
        if UYARLANDI not in g["kaynak"]["tr"]:
            g["kaynak"]["tr"] = g["kaynak"]["tr"].rstrip(". ") + UYARLANDI
    else:
        g.pop("dosya_tr", None)
        g.pop("sha256_tr", None)


def turkce_kopyalari_isle() -> int:
    """Yalnız Türkçe kopyaları kayda işler (aday klasörü olmadan):
    `python3 -I gorsel_isle.py --turkce`."""
    kayit = json.loads(KAYIT.read_text(encoding="utf-8"))
    kunye_duzelt(kayit["gorseller"])
    KAYIT.write_text(json.dumps(kayit, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    n = sum(1 for g in kayit["gorseller"].values() if g.get("dosya_tr"))
    print(f"✓ {n} görselin Türkçe kopyası kayıtta")
    return 0


TUR = {"Fotoğraf": "foto", "Görsel": "gorsel", "Görüntü": "goruntu", "Şekil": "sema", "Şema": "sema",
       "Harita": "harita", "Grafik": "grafik"}


def commons_kucukleri(adres: str) -> list[str]:
    """Wikimedia Commons özgün dosyası yerine küçük resim adresleri (sırayla
    1280, 960, 500 piksel). Commons'ın robots.txt'si API yolunu (/w/) kapattığı
    için API'ye gidilmiyor; adres upload.wikimedia.org'un standart küçük resim
    deseninden kuruluyor (özgün dosyalarda hız sınırı sıkı: 429)."""
    if "upload.wikimedia.org/wikipedia/commons/" not in adres or "/thumb/" in adres:
        return [adres]
    yol = adres.split("/wikipedia/commons/", 1)[1]
    dosya = yol.rsplit("/", 1)[-1]
    ek = ".png" if dosya.lower().endswith((".svg", ".tif", ".tiff")) else ""
    return [f"https://upload.wikimedia.org/wikipedia/commons/thumb/{yol}/{g}px-{dosya}{ek}" for g in (1280, 960, 500)]


def kaynak_en(tr: str) -> str:
    if tr in KAYNAK_EN:
        return KAYNAK_EN[tr]
    en = tr
    for a, b in ON_EK.items():
        if en.startswith(a):
            en = b + en[len(a):]
    for a, b in SOZ:
        en = en.replace(a, b)
    return en


def sayfa_kodu(a: dict) -> str:
    """Adayın sayfası: başlık "bNN" ya da teknoloji sayfası "tek_<kod>"."""
    if a.get("teknoloji"):
        return f"tek_{a['teknoloji']}"
    return f"b{int(a['baslik_no']):02d}"


def sayfa_dosyasi(kod: str) -> Path:
    if kod.startswith("tek_"):
        return BURASI.parent / "teknolojiler" / f"{kod[4:]}.tr.md"
    return next(BOLUMLER.glob(f"{kod[1:]}-*.tr.md"))


def kimlik(no, konu: str) -> str:
    s = re.sub(r"\([^)]*\)", "", konu).replace("ı", "i").replace("İ", "i")
    s = unicodedata.normalize("NFKD", s).encode("ascii", "ignore").decode().lower()
    kelimeler = [k for k in re.split(r"[^a-z0-9]+", s) if k]
    sonuc = ""
    for k in kelimeler:
        if len(sonuc) + len(k) + 1 > 36:
            break
        sonuc = f"{sonuc}-{k}" if sonuc else k
    return f"{no}-{sonuc}" if isinstance(no, str) else f"b{no:02d}-{sonuc}"


def aday_kimligi(a: dict) -> str:
    """Başlık adayı "bNN-…", teknoloji sayfası adayı "t-<kod>-…"."""
    return kimlik("t-" + a["teknoloji"] if a.get("teknoloji") else a["baslik_no"], a["konu"])


# Blok sayılmayan yönerge: öne çıkan cümle ([[cekme:…]], madde 6) ve
# tanınmayan her [[ad:kimlik]] satırı. Sayılsaydı bir dilde eksik kalan
# satır öteki dilin blok sırasını kaydırırdı.
SAYILMAZ = re.compile(r"\[\[(?!(?:grafik|gorsel):)[a-z]+:[a-z0-9-]+\]\]")


def bloklar(metin: str) -> list[str]:
    return [b for b in re.split(r"\n\s*\n", metin.strip()) if b.strip() and not SAYILMAZ.fullmatch(b.strip())]


def yerlestir(metin: str, eklenecek: dict[int, list[str]], once: dict[int, list[str]] | None = None) -> str:
    """[eklenecek]: blok dizini → ardına konacak yönergeler; [once]: önüne
    konacaklar (`konum: "önce"`, madde 5)."""
    once = once or {}
    parcalar = re.split(r"(\n[ \t]*\n\s*)", metin)
    sayac = -1
    for j in range(0, len(parcalar), 2):
        if parcalar[j].strip() and not SAYILMAZ.fullmatch(parcalar[j].strip()):
            sayac += 1
            if sayac in once:
                parcalar[j] = "".join(f"{y}\n\n" for y in once[sayac]) + parcalar[j]
            if sayac in eklenecek:
                parcalar[j] = parcalar[j].rstrip("\n") + "".join(f"\n\n{y}" for y in eklenecek[sayac])
    return "".join(parcalar)


def pdf_mi(a: dict) -> bool:
    return "PDF" in str(a.get("boyut", "")) or a["gorsel_adresi"].lower().endswith(".pdf")


def main() -> int:
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    if sys.argv[1] == "--turkce":
        return turkce_kopyalari_isle()
    klasor = Path(sys.argv[1])
    kuru = "--kuru" in sys.argv
    adaylar, gorulen = [], set()
    for f in [*sorted(klasor.glob("gorsel_adaylari_parca_*.json")), klasor / "gorsel_adaylari.json"]:
        if not f.exists():
            continue
        d = json.loads(f.read_text(encoding="utf-8"))
        for a in (d.get("adaylar", []) if isinstance(d, dict) else d):
            if a["gorsel_adresi"] not in gorulen:
                gorulen.add(a["gorsel_adresi"])
                adaylar.append(a)
    kayit = json.loads(KAYIT.read_text(encoding="utf-8")) if KAYIT.exists() else {
        "_ne": "Bölüm görselleri (karar 58). Dosyalar web/yz/gorsel/ altında; künye görselin ne olduğudur, "
               "kaynak satırı ayrı. Hak sahibi itiraz ederse kayıt ve yönerge silinir (dogrula_bolumler.py kural 12).",
        "gorseller": {}}
    gorseller = kayit["gorseller"]
    secilen, atlanan, pdf = [], [], []
    for a in adaylar:
        if a.get("indirme_yasagi") or any(a["konu"].startswith(x) for x in ALINMAZ):
            atlanan.append(a)
        elif pdf_mi(a) and a["gorsel_adresi"] not in KIRP:
            pdf.append(a)
        else:
            secilen.append(a)
    print(f"{len(adaylar)} aday · {len(secilen)} işlenecek · {len(pdf)} PDF şekli (ayrı adım) · {len(atlanan)} alınmıyor")
    if kuru:
        for a in secilen:
            print(f"  {aday_kimligi(a)} ← {a['gorsel_adresi'][:80]}")
        return 0
    hatalar = []
    for a in secilen:
        k = aday_kimligi(a)
        if k in gorseller and (DEPO / gorseller[k]["dosya"]).exists():
            continue
        # Aynı görsel başka bir sayfada zaten varsa yeniden indirilmez: aynı
        # dosya bu sayfanın künyesi ve yeriyle ikinci bir kayıt olur.
        es = next((x for x in gorseller.values()
                   if x.get("gorsel_adresi") == a["gorsel_adresi"] and (DEPO / x["dosya"]).exists()), None)
        if es is not None:
            kaynak_tr = IC_NOT.sub("", a.get("kaynak_satiri", "")).strip() or es["kaynak"]["tr"]
            gorseller[k] = {
                "sayfa": sayfa_kodu(a),
                **({"baslik_no": a["baslik_no"]} if a.get("baslik_no") else {}),
                **{alan: es[alan] for alan in ("dosya", "genislik", "yukseklik", "sha256", "gorsel_adresi", "indirme_gunu")},
                "kunye": {"tr": a["kunye_tr"].strip(), "en": a["kunye_en"].strip()},
                "kaynak": {"tr": kaynak_tr, "en": kaynak_en(kaynak_tr)},
                "sayfa_adresi": a.get("sayfa_adresi", "") or es.get("sayfa_adresi", ""),
                "lisans_notu": a.get("lisans_notu", "") or es.get("lisans_notu", ""),
                "tur": es.get("tur", "gorsel"),
                "yapay_zeka": False,
                "yer": a["metindeki_yer"],
            "konum": "sonra",
            }
            print(f"  ↺ {k} · {es['dosya'].rsplit('/', 1)[-1]} yeniden kullanıldı")
            continue
        if a["gorsel_adresi"] in KIRP:
            yerel, sayfa, kutu = KIRP[a["gorsel_adresi"]]
            kaynak_pdf = str(BURASI / "kaynak_dosyalari" / yerel) if yerel else a["gorsel_adresi"]
            komut = [str(PYTHON), "-I", str(BURASI / "gorsel_kirp.py"), k, kaynak_pdf, str(sayfa), kutu]
        else:
            komut = None
        if komut is not None:
            cikti = subprocess.run(komut, capture_output=True, text=True, timeout=400)
        else:
            for indirilecek in commons_kucukleri(a["gorsel_adresi"]):
                cikti = subprocess.run([str(PYTHON), "-I", str(BURASI / "gorsel_al.py"), k, indirilecek],
                                       capture_output=True, text=True, timeout=400)
                if cikti.returncode == 0:
                    break
                time.sleep(3)
        # Sunucuları yormamak için; Wikimedia'da daha uzun ara (hız sınırı: 429).
        time.sleep(8 if "wikimedia.org" in a["gorsel_adresi"] else 3)
        son = (cikti.stdout.strip().splitlines() or [""])[-1]
        if cikti.returncode != 0 or not son.startswith("{"):
            hatalar.append((k, (son or (cikti.stderr.strip().splitlines() or ["?"])[-1])[:160]))
            print(f"  ✗ {k}: {hatalar[-1][1]}")
            continue
        sonuc = json.loads(son)
        kaynak_tr = IC_NOT.sub("", a.get("kaynak_satiri", "")).strip()
        on = kaynak_tr.split(":")[0]
        gorseller[k] = {
            "sayfa": sayfa_kodu(a),
            **({"baslik_no": a["baslik_no"]} if a.get("baslik_no") else {}),
            "dosya": sonuc["dosya"],
            "genislik": sonuc["genislik"],
            "yukseklik": sonuc["yukseklik"],
            "sha256": sonuc["sha256"],
            "kunye": {"tr": a["kunye_tr"].strip(), "en": a["kunye_en"].strip()},
            "kaynak": {"tr": kaynak_tr, "en": kaynak_en(kaynak_tr)},
            "sayfa_adresi": a.get("sayfa_adresi", ""),
            "gorsel_adresi": sonuc["gorsel_adresi"] or a["gorsel_adresi"],
            "indirme_gunu": sonuc["indirme_gunu"],
            "lisans_notu": a.get("lisans_notu", ""),
            "tur": TUR.get(on, "gorsel"),
            "yapay_zeka": False,
            "yer": a["metindeki_yer"],
            "konum": "sonra",
        }
        print(f"  ✓ {k} · {sonuc['genislik']}×{sonuc['yukseklik']} · {sonuc['bayt'] // 1024} KB")
        KAYIT.write_text(json.dumps(kayit, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    # Yönergeler: TR'de adayın paragrafının ardına, EN'de aynı blok sırasına.
    for g in gorseller.values():
        g.setdefault("sayfa", f"b{int(g['baslik_no']):02d}" if g.get("baslik_no") else "")
    for kod in sorted({g["sayfa"] for g in gorseller.values() if g["sayfa"]}):
        tr = sayfa_dosyasi(kod)
        en = tr.with_name(tr.name.replace(".tr.md", ".en.md"))
        mt, me = tr.read_text(encoding="utf-8"), en.read_text(encoding="utf-8")
        bt, be = bloklar(mt), bloklar(me)
        if len(bt) != len(be):
            print(f"  ! {tr.name}: TR {len(bt)}, EN {len(be)} blok — yerleştirilmedi")
            continue
        eklenecek: dict[int, list[str]] = {}
        once: dict[int, list[str]] = {}
        for k, g in gorseller.items():
            if g["sayfa"] != kod or f"[[gorsel:{k}]]" in mt:
                continue
            i = [j for j, b in enumerate(bt) if b.startswith(g["yer"])]
            if len(i) != 1:
                print(f"  ! {k}: yer bulunamadı ya da birden çok ({len(i)})")
                continue
            # `yer` görselin anlattığı paragraf; `konum` görselin o paragrafın
            # önünde mi ardında mı durduğu (madde 5; yoksa ardında).
            hedef = once if g.get("konum") == "önce" else eklenecek
            hedef.setdefault(i[0], []).append(f"[[gorsel:{k}]]")
        if eklenecek or once:
            tr.write_text(yerlestir(mt, eklenecek, once), encoding="utf-8")
            en.write_text(yerlestir(me, eklenecek, once), encoding="utf-8")
            print(f"  · {tr.name}: {sum(len(v) for v in [*eklenecek.values(), *once.values()])} görsel")
    kunye_duzelt(gorseller)
    KAYIT.write_text(json.dumps(kayit, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    print(f"✓ {len(gorseller)} görsel kayıtta · {len(hatalar)} alınamadı")
    for k, h in hatalar:
        print(f"  ✗ {k}: {h}")
    if pdf:
        print("PDF şekilleri (ayrı adım):")
        for a in pdf:
            print(f"  {aday_kimligi(a)} ← {a['sayfa_adresi']} · {a.get('boyut')}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
