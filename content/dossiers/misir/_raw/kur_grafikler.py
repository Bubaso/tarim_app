#!/usr/bin/env python3
"""Mısır grafikler.json — okunur kalsın diye betikle kuruluyor, elle değil.

Çalıştırma: python3 content/dossiers/misir/_raw/kur_grafikler.py
Sonra MUTLAKA: python3 content/dossiers/misir/dogrula_grafik.py

NEDEN BETİK: 16 grafiğin iki dilli tarifi elle yazılınca hem JSON sözdizimi
hatasına açık hem okunamaz oluyor. Burada yüzde işaretinin yeri (YUZDE_ON /
YUZDE_SON) tek yerde duruyor ve on altı grafiğin hepsi onu kullanıyor;
elle yazılsaydı biri unutulurdu ve Türkçe "4,25%" diye çizilirdi.
"""
import json, pathlib

def t(tr, en):
    return {"tr": tr, "en": en}

# Yüzde işareti Türkçede BAŞA, İngilizcede SONA gidiyor (DossierText.birebir).
YUZDE_ON = t("%", "")
YUZDE_SON = t("", "%")

G = {}

# ─── §1 · AÇILIŞ ─────────────────────────────────────────────────────────
G["feddan"] = {
    "tur": "kunye",
    "baslik": t("Dosyanın birimi", "The unit of this dossier"),
    "not": t(
        "Feddan Mısır'ın kendi arazi birimi: 4.200,833 m², hektarın biraz "
        "altında. Resmî istatistik hektarla yayımlanıyor, tarla hâlâ feddanla "
        "konuşuluyor. Dört rakamın üçü 2024-2025 ölçümü; su bağımlılığı "
        "FAO'nun 2016 taramasından ve belgenin kendi içindeki rakamların "
        "yılları ayrı.",
        "The feddan is Egypt's own land unit: 4,200.833 m², a little under a "
        "hectare. Official statistics are published in hectares; the field is "
        "still spoken of in feddans. Three of the four figures are 2024-2025 "
        "measurements; the water dependency comes from FAO's 2016 review, "
        "whose internal figures carry their own separate years."),
    "kaynak": "FAOSTAT 2024-2025 · FAO AQUASTAT 2016",
    "kalemler": [
        {"deger": "@arazi.feddan_ha", "ondalik": 2, "sonek": t(" ha", " ha"),
         "etiket": t("Bir feddan", "One feddan"),
         "alt": t("4.200,833 m²", "4,200.833 m²")},
        {"deger": "@turetilmis.feddan_kisi_misir", "ondalik": 2,
         "sonek": t(" feddan", " feddan"),
         "etiket": t("Tarım çalışanı başına arazi",
                     "Farmland per agricultural worker"),
         "alt": t("arazi 2024 · çalışan 2025", "land 2024 · workers 2025")},
        {"deger": "@turetilmis.tarim_arazisi_payi_misir", "ondalik": 2,
         "onek": YUZDE_ON, "sonek": YUZDE_SON,
         "etiket": t("Ülke yüzeyinin tarım arazisi olan payı",
                     "Share of the country's surface that is farmland"),
         "alt": t("2024", "2024")},
        {"deger": "@su.disa_bagimlilik_yuzde", "ondalik": 1,
         "onek": YUZDE_ON, "sonek": YUZDE_SON,
         "etiket": t("Suyun ülke dışından gelen payı",
                     "Share of water originating outside the country"),
         "alt": t("AQUASTAT, 2016 taraması", "AQUASTAT, 2016 review")},
    ],
}

# ─── §2 · KIRKTA BİR ─────────────────────────────────────────────────────
G["kirkta_bir"] = {
    "tur": "ikili_cubuk",
    "baslik": t("Kırkta bir", "One part in forty"),
    "not": t(
        "Mısır'ın yüzeyinin %4,25'i tarım arazisi; Türkiye'nin %50,21'i. "
        "Oran ülke yüzeyine göre, ekilebilir toprağa göre değil: Mısır'ın "
        "geri kalanı çöl ve tarım arazisi sayılmıyor. Her satır KENDİ içinde "
        "oranlanıyor; iki satır birbiriyle karşılaştırılmıyor — ülkelerin "
        "yüzeyleri farklı.",
        "4.25% of Egypt's surface is agricultural land; 50.21% of Türkiye's. "
        "The ratio is against total land area, not against arable soil: the "
        "rest of Egypt is desert and is not counted as farmland. Each row is "
        "scaled within itself; the two rows are not compared with each other "
        "— the countries' surfaces differ."),
    "kaynak": "FAOSTAT Inputs/LandUse, 2024",
    "seriler": [
        {"ad": t("Tarım arazisi", "Agricultural land"), "rol": "vurgu"},
        {"ad": t("Geri kalan yüzey", "The rest of the surface"), "rol": "ikincil"},
    ],
    "satirlar": [
        {"etiket": t("Mısır", "Egypt"), "yil": 2024,
         "degerler": ["@turetilmis.tarim_arazisi_payi_misir",
                      "@turetilmis.tarim_disi_payi_misir"],
         "ondalik": 2, "onek": YUZDE_ON, "sonek": YUZDE_SON,
         "rozet": t("99.545 bin ha yüzey", "99,545 thousand ha of land")},
        {"etiket": t("Türkiye", "Türkiye"), "yil": 2024,
         "degerler": ["@turetilmis.tarim_arazisi_payi_turkiye",
                      "@turetilmis.tarim_disi_payi_turkiye"],
         "ondalik": 2, "onek": YUZDE_ON, "sonek": YUZDE_SON,
         "rozet": t("76.963 bin ha yüzey", "76,963 thousand ha of land")},
    ],
}

# ─── §3 · ON BİR KAT ─────────────────────────────────────────────────────
G["on_bir_kat"] = {
    "tur": "siralama",
    "baslik": t("Bir çalışanın tarlası", "One worker's field"),
    "birim": t("hektar · tarım çalışanı başına tarım arazisi",
               "hectares · agricultural land per agricultural worker"),
    "ondalik": 2,
    "not": t(
        "Mısır'da tarımda çalışan 5.898 bin kişiye 4.229 bin hektar tarım "
        "arazisi düşüyor: kişi başına 0,72 hektar, yani 1,71 feddan. "
        "Türkiye'de 4.899 bin kişiye 38.640 bin hektar düşüyor: 7,89 hektar. "
        "Arada 11,0 kat var. Payda İSTİHDAM, nüfus değil; cinsiyet dilimi "
        "Total alındı (ilk ölçümde yalnız bir dilim okunmuş ve Mısır 1.102 "
        "bin çıkmıştı).",
        "In Egypt 5,898 thousand people working in agriculture share 4,229 "
        "thousand hectares of farmland: 0.72 hectares each, that is 1.71 "
        "feddans. In Türkiye 4,899 thousand people share 38,640 thousand "
        "hectares: 7.89 hectares. The gap is 11.0 fold. The denominator is "
        "EMPLOYMENT, not population; the sex dimension was taken as Total "
        "(the first measurement read a single slice and returned 1,102 "
        "thousand for Egypt)."),
    "kaynak": "FAOSTAT LandUse 2024 · FAOSTAT Employment Indicators 2025",
    "_olcum_disi": {
        "1102": ("İlk ölçümün YANLIŞ sonucu. Cinsiyet boyutu süzülmediği için "
                 "yalnız bir dilim okunmuştu. Doğrusu data.json'da (5.898 bin); "
                 "bu rakam kasıtlı olarak orada yok, notta uyarı olarak duruyor."),
    },
    "satirlar": [
        {"etiket": t("Türkiye", "Türkiye"),
         "deger": "@turetilmis.ha_kisi_turkiye", "rol": "ikincil"},
        {"etiket": t("Mısır", "Egypt"),
         "deger": "@turetilmis.ha_kisi_misir", "rol": "vurgu"},
    ],
}

# ─── §4 · SU ─────────────────────────────────────────────────────────────
G["suyun_defteri"] = {
    "tur": "siralama",
    "baslik": t("Çekilen su, kaynaktan fazla",
                "More water withdrawn than the source holds"),
    "birim": t("milyon m³ · yıl", "million m³ · year"),
    "ondalik": 0,
    "not": t(
        "Üç rakam aynı suyu üç ayrı yerden sayıyor. Ülke içinde yenilenen su "
        "1.800 milyon m³; bütün yenilenebilir kaynak 58.300 milyon m³, yani "
        "%96,9'u ülke dışından geliyor. Çekim ise 68.300 milyon m³ — "
        "kaynağın kendisinden BÜYÜK. Veri hatası değil: belge sebebini "
        "yazıyor, tahliye suyu yeniden kullanılıyor ve bir kez çekilen su "
        "sisteme geri dönüyor. Çekimin %86'sı tarıma gidiyor. Üç rakamın "
        "yılları ayrı (kaynak 2016 taraması, çekim 2000) ve bu grafikte "
        "toplanmıyorlar.",
        "Three figures count the same water in three different places. Water "
        "renewed inside the country is 1,800 million m³; all renewable "
        "resources are 58,300 million m³, so 96.9% originates outside. "
        "Withdrawal is 68,300 million m³ — LARGER than the resource itself. "
        "This is not a data error: the source document explains it, drainage "
        "water is reused and water withdrawn once returns to the system. "
        "86% of withdrawal goes to agriculture. The three figures carry "
        "different years (resources from the 2016 review, withdrawal from "
        "2000) and are not added together here."),
    "kaynak": "FAO AQUASTAT · Mısır ülke profili, 2016 taraması",
    "_aralik_notu": (
        "En büyük ile en küçük arasında 37,9 kat var — 40 kat eşiğinin hemen "
        "altında. En küçük çubuk (iç yenilenebilir su) bilerek burada: "
        "grafiğin söylediği şey o çubuğun ne kadar küçük olduğu. Kaynak "
        "rakamları bir gün eşiği geçerse çözüm çubuğu düşürmek değil, "
        "dogrula_grafik.py'nin uyarısını okuyup grafiği bölmek."),
    "satirlar": [
        {"etiket": t("Çekilen su · 2000", "Water withdrawn · 2000"),
         "deger": "@su.toplam_cekim_milyon_m3", "rol": "vurgu"},
        {"etiket": t("Yenilenebilir kaynağın tamamı",
                     "All renewable resources"),
         "deger": "@su.toplam_yenilenebilir_milyon_m3", "rol": "ikincil"},
        {"etiket": t("Ülke içinde yenilenen",
                     "Renewed inside the country"),
         "deger": "@su.ic_yenilenebilir_milyon_m3", "rol": "sessiz"},
    ],
}

# ─── §5 · AYNI TARLA, YILDA BİR BUÇUK KEZ ────────────────────────────────
G["ayni_tarla"] = {
    "tur": "kartlar",
    "baslik": t("Aynı tarla, yılda bir buçuk kez",
                "The same field, one and a half times a year"),
    "not": t(
        "Üç rakam tek bir düzeni anlatıyor: arazi az, su dışarıdan geliyor, "
        "o yüzden aynı toprak yılda birden fazla hasat veriyor. Ekim "
        "yoğunluğu 2010 taramasından; kişi başına su 2014. Kartlardaki "
        "rakamlar ayrı yıllardan ve birbirine oranlanmıyor.",
        "Three figures describe one arrangement: land is scarce, water comes "
        "from outside, and so the same soil yields more than one harvest a "
        "year. The cropping intensity is from the 2010 review, the per capita "
        "water figure from 2014. The figures on the cards come from different "
        "years and are not ratios of one another."),
    "kaynak": "FAO AQUASTAT 2016 taraması · FAOSTAT LandUse 2024",
    "kartlar": [
        {"ust": t("AQUASTAT · 2010", "AQUASTAT · 2010"),
         "baslik": t("Ekim yoğunluğu", "Cropping intensity"),
         "govde": t("Yüzde yüzün üstündeki her puan, aynı tarlanın yıl "
                    "içinde ikinci kez ekildiği anlamına geliyor. 175, "
                    "ortalama bir tarlanın yılda bir buçuk kattan fazla "
                    "hasat verdiğini söylüyor.",
                    "Every point above one hundred per cent means the same "
                    "field was sown a second time within the year. 175 says "
                    "the average field yields more than one and a half "
                    "harvests a year."),
         "rakam": {"deger": "@su.ekim_yogunlugu_yuzde", "ondalik": 0,
                   "onek": YUZDE_ON, "sonek": YUZDE_SON,
                   "etiket": t("ekilen alan / tarım arazisi",
                               "area sown / agricultural land")}},
        {"ust": t("FAOSTAT · 2024", "FAOSTAT · 2024"),
         "baslik": t("Sulanan tarım arazisi", "Irrigated agricultural land"),
         "govde": t("FAOSTAT'ta Mısır'ın fiilen sulanan alanı ile tarım "
                    "arazisi BİREBİR aynı sayı. Eşitlik yalnız 2021-2024 "
                    "için var; daha eski yıllarda iki kalem ayrışıyor. "
                    "Sulanmayan tarım arazisi kaydı yok demek daha doğru.",
                    "In FAOSTAT the area actually irrigated and the "
                    "agricultural land of Egypt are the SAME number. The "
                    "identity holds only for 2021-2024; in earlier years the "
                    "two items diverge. It is more accurate to say no "
                    "unirrigated farmland is recorded."),
         "rakam": {"deger": "@turetilmis.sulanan_payi_misir", "ondalik": 0,
                   "onek": YUZDE_ON, "sonek": YUZDE_SON,
                   "etiket": t("2021-2024 için", "for 2021-2024")}},
        {"ust": t("AQUASTAT · 2014", "AQUASTAT · 2014"),
         "baslik": t("Kişi başına yenilenebilir su",
                     "Renewable water per person"),
         "govde": t("Bin metreküpün altı uluslararası tanımda su kıtlığı "
                    "sayılıyor. Rakam 2014'e ait; nüfus o yıldan bugüne "
                    "yirmi milyondan fazla arttı, yani pay azaldı.",
                    "Below one thousand cubic metres counts as water scarcity "
                    "in the international definition. The figure is for 2014; "
                    "the population has since grown by more than twenty "
                    "million, so the share has fallen."),
         "rakam": {"deger": "@su.kisi_basi_m3", "ondalik": 0,
                   "sonek": t(" m³", " m³"),
                   "etiket": t("kişi başına · yıl", "per person · year")}},
    ],
}

# ─── §6 · ESKİ TOPRAK, YENİ TOPRAK ───────────────────────────────────────
G["arazinin_egrisi"] = {
    "tur": "cizgi",
    "baslik": t("Altmış üç yılda kazanılan toprak",
                "Land gained in sixty-three years"),
    "birim": t("bin hektar · tarım arazisi",
               "thousand hectares · agricultural land"),
    "ondalik": 0,
    "not": t(
        "Mısır'ın tarım arazisi 1961'de 2.568 bin hektardı, 2024'te 4.229 "
        "bin hektar: %64,7 artış. Artışın kaynağı çölde açılan yeni araziler. "
        "Eğri beş ölçüm noktasından geçiyor (1961, 1990, 2010, 2020, 2024) — "
        "aradaki yıllar çizilmedi, ara dalgalanma bu grafikte görünmez.",
        "Egypt's agricultural land was 2,568 thousand hectares in 1961 and "
        "4,229 thousand in 2024: a 64.7% increase. The increase comes from "
        "new land opened in the desert. The curve passes through five "
        "measured points (1961, 1990, 2010, 2020, 2024) — the years between "
        "were not plotted, so intermediate swings are invisible here."),
    "kaynak": "FAOSTAT Inputs/LandUse · 1961-2024",
    "seriler": [
        {"ad": t("Mısır · tarım arazisi", "Egypt · agricultural land"),
         "rol": "vurgu",
         "noktalar": {"harita": "@arazi.misir_tarim_arazisi_serisi"}},
    ],
}

# ─── §7 · DÜNYANIN EN BÜYÜK ALICISI ──────────────────────────────────────
G["dunyanin_alicisi"] = {
    "tur": "siralama",
    "baslik": t("Dünyanın en büyük buğday alıcısı",
                "The world's largest wheat buyer"),
    "birim": t("bin ton · ithalat · 2024/25 pazarlama yılı",
               "thousand tonnes · imports · 2024/25 marketing year"),
    "ondalik": 0,
    "not": t(
        "Mısır 12.467 bin ton buğday ithal ediyor ve listenin başında. "
        "İkinci sıradaki Avrupa Birliği bir KÜME satırı; PSD'de hiçbir AB "
        "üyesinin ayrı satırı yok, yani küme ile üyeler aynı toplamda "
        "buluşmuyor ve çift sayım ölçülerek yok olduğu doğrulandı. Dünya "
        "toplamı ülkelerin toplanmasıyla bulundu — PSD'de World satırı yok.",
        "Egypt imports 12,467 thousand tonnes of wheat and heads the list. "
        "The European Union in second place is an AGGREGATE row; PSD carries "
        "no separate row for any EU member, so the aggregate and its members "
        "never meet in the same total, and the absence of double counting was "
        "verified by measurement. The world total was obtained by summing "
        "countries — PSD has no World row."),
    "kaynak": "USDA FAS PSD · 2024/25 pazarlama yılı",
    "satirlar": [
        {"etiket": t("Mısır", "Egypt"), "deger": "@tahil.ithalat_ilk_6.0.bin_ton",
         "rol": "vurgu", "_kimlik": ["@tahil.ithalat_ilk_6.0.ulke", "Egypt"]},
        {"etiket": t("Avrupa Birliği · küme", "European Union · aggregate"),
         "deger": "@tahil.ithalat_ilk_6.1.bin_ton", "rol": "sessiz",
         "_kimlik": ["@tahil.ithalat_ilk_6.1.ulke", "European Union"]},
        {"etiket": t("Endonezya", "Indonesia"),
         "deger": "@tahil.ithalat_ilk_6.2.bin_ton", "rol": "sessiz",
         "_kimlik": ["@tahil.ithalat_ilk_6.2.ulke", "Indonesia"]},
        {"etiket": t("Cezayir", "Algeria"),
         "deger": "@tahil.ithalat_ilk_6.3.bin_ton", "rol": "sessiz",
         "_kimlik": ["@tahil.ithalat_ilk_6.3.ulke", "Algeria"]},
        {"etiket": t("Brezilya", "Brazil"),
         "deger": "@tahil.ithalat_ilk_6.4.bin_ton", "rol": "sessiz",
         "_kimlik": ["@tahil.ithalat_ilk_6.4.ulke", "Brazil"]},
        {"etiket": t("Filipinler", "Philippines"),
         "deger": "@tahil.ithalat_ilk_6.5.bin_ton", "rol": "sessiz",
         "_kimlik": ["@tahil.ithalat_ilk_6.5.ulke", "Philippines"]},
    ],
}

G["ithalatin_egrisi"] = {
    "tur": "cizgi",
    "baslik": t("Altmış dört yılda on iki kat",
                "Twelvefold in sixty-four years"),
    "birim": t("bin ton · Mısır'ın buğday ithalatı",
               "thousand tonnes · Egypt's wheat imports"),
    "ondalik": 0,
    "not": t(
        "1960'ta 996 bin ton, 2024'te 12.467 bin ton: 12,5 kat. Aynı "
        "dönemde nüfus da dört kattan fazla arttı, yani eğrinin tamamı "
        "nüfusla açıklanmıyor ama bir kısmı onunla açıklanıyor. Seri KESİN "
        "son yılda kesildi; PSD'nin yayımladığı son iki pazarlama yılı "
        "tahmin ve öngörü, çizgiye katılmadı.",
        "996 thousand tonnes in 1960, 12,467 thousand in 2024: 12.5 fold. "
        "Over the same period the population more than quadrupled, so the "
        "curve is not fully explained by population growth — but part of it "
        "is. The series was cut at the last DEFINITE year; the two most "
        "recent marketing years PSD publishes are an estimate and a forecast "
        "and were left out of the line."),
    "kaynak": "USDA FAS PSD · 1960-2024 pazarlama yılları",
    "seriler": [
        {"ad": t("Mısır · buğday ithalatı", "Egypt · wheat imports"),
         "rol": "vurgu",
         "noktalar": {"harita": "@tahil.bugday_ithalat_serisi"}},
    ],
}

# ─── §8-9 · ÜÇ TANE ──────────────────────────────────────────────────────
G["uc_tane"] = {
    "tur": "yigin",
    "baslik": t("Susuz taneyi alıyor, susuz olmayanı ekiyor",
                "It buys the thirsty-less grain and grows the thirsty one"),
    "not": t(
        "Üç çubuk, üç tane. Her çubuk kendi arzına oranlanıyor: üretim artı "
        "ithalat. Buğdayda arzın %58,1'i, tane mısırda %60,1'i dışarıdan "
        "geliyor; pirinçte yalnız %3,9'u. Pirinç üçünün en çok su isteyeni "
        "ve ülke onu kendisi yetiştiriyor. Çubuklar arz; tüketim, stok ve "
        "ihracat bu grafikte yok — dengenin tamamı değil, arzın kaynağı "
        "çiziliyor. 'Tane mısır' TANE MISIR; ülkenin adıyla karıştırılmaz.",
        "Three bars, three grains. Each bar is scaled to its own supply: "
        "production plus imports. In wheat 58.1% of supply comes from "
        "outside, in maize 60.1%; in rice only 3.9%. Rice is the thirstiest "
        "of the three and the country grows it itself. The bars show supply; "
        "consumption, stocks and exports are not in this chart — what is "
        "drawn is the origin of supply, not the full balance."),
    "kaynak": "USDA FAS PSD · 2024/25 pazarlama yılı",
    "cubuklar": [
        {"etiket": t("Buğday", "Wheat"),
         "dilimler": [
             {"ad": t("Kendi üretimi", "Own production"),
              "deger": "@tahil.bugday.uretim", "rol": "vurgu"},
             {"ad": t("İthalat", "Imports"),
              "deger": "@tahil.bugday.ithalat", "rol": "ikincil"},
         ]},
        {"etiket": t("Tane mısır", "Maize"),
         "dilimler": [
             {"ad": t("Kendi üretimi", "Own production"),
              "deger": "@tahil.tane_misir.uretim", "rol": "vurgu"},
             {"ad": t("İthalat", "Imports"),
              "deger": "@tahil.tane_misir.ithalat", "rol": "ikincil"},
         ]},
        {"etiket": t("Pirinç · kabuğu alınmış", "Rice · milled"),
         "dilimler": [
             {"ad": t("Kendi üretimi", "Own production"),
              "deger": "@tahil.pirinc.uretim", "rol": "vurgu"},
             {"ad": t("İthalat", "Imports"),
              "deger": "@tahil.pirinc.ithalat", "rol": "ikincil"},
         ]},
    ],
}

# ─── §11 · PAMUK ─────────────────────────────────────────────────────────
G["pamuk_endeksi"] = {
    "tur": "cizgi",
    "baslik": t("Mısır pamuğunun altmış üç yılı",
                "Sixty-three years of Egyptian cotton"),
    "birim": t("indeks · 1961 = 100", "index · 1961 = 100"),
    "ondalik": 0,
    "not": t(
        "İki seri de indeks, taban 1961. Mutlak rakamlarla çizilemezdi: "
        "üretim ton, alan hektar ve tek eksende yan yana konamazlar. "
        "Grafiğin söylediği şey iki eğrinin AÇILMASI: alan 1961'in %9,8'ine "
        "indi, üretim %23,0'ına — aradaki fark verimin 2,35 katına "
        "çıkması. Zirve 1965'te; üretim o yıl tabanın %129,7'siydi.",
        "Both series are indices with 1961 as the base. They could not be "
        "drawn in absolute terms: production is in tonnes, area in hectares, "
        "and the two cannot share an axis. What the chart says is that the "
        "curves SEPARATE: area fell to 9.8% of its 1961 level, production to "
        "23.0% — the gap is yield rising to 2.35 times its starting value. "
        "The peak is 1965, when production stood at 129.7% of the base."),
    "kaynak": "FAOSTAT QCL · çiğit pamuk, 1961-2024",
    "seriler": [
        {"ad": t("Üretim", "Production"), "rol": "vurgu",
         "noktalar": {"liste": "@urunler.pamuk_endeks", "x": "yil", "y": "uretim"}},
        {"ad": t("Hasat alanı", "Area harvested"), "rol": "ikincil",
         "noktalar": {"liste": "@urunler.pamuk_endeks", "x": "yil", "y": "alan"}},
    ],
}

# ─── §12 · PORTAKAL ──────────────────────────────────────────────────────
G["portakalda_ikiye_bir"] = {
    "tur": "cizgi",
    "baslik": t("Portakalda açılan makas", "The widening gap in oranges"),
    "birim": t("ton · portakal üretimi", "tonnes · orange production"),
    "bolen": 1000,
    "ondalik": 0,
    "not": t(
        "1961'de Türkiye öndeydi. 1970'te Mısır geçti ve bir daha geri "
        "vermedi: 1990'da oran 2,14 kat, 2024'te 2,61 kat. Oranın ARTTIĞI "
        "iki yılın ölçümüdür, tek yılın değil. İki ülkenin ortak veri yılları "
        "alındı; bir ülkede olup ötekinde olmayan yıl atlandı, "
        "doldurulmadı. Eksen bin tona bölünmüş.",
        "In 1961 Türkiye was ahead. In 1970 Egypt passed it and never gave "
        "the lead back: the ratio was 2.14 fold in 1990 and 2.61 fold in "
        "2024. That the ratio is RISING is a measurement of two years, not "
        "one. Years with data in both countries were used; a year present in "
        "one and missing in the other was skipped, not filled. The axis is "
        "divided by one thousand tonnes."),
    "kaynak": "FAOSTAT QCL · portakal, 1961-2024",
    "seriler": [
        {"ad": t("Mısır", "Egypt"), "rol": "vurgu",
         "noktalar": {"liste": "@urunler.portakal_cizgi", "x": "yil", "y": "misir"}},
        {"ad": t("Türkiye", "Türkiye"), "rol": "ikincil",
         "noktalar": {"liste": "@urunler.portakal_cizgi", "x": "yil", "y": "turkiye"}},
    ],
}

# ─── §13 · AYNI FASILLAR ─────────────────────────────────────────────────
G["ayni_fasillar"] = {
    "tur": "ikili_cubuk",
    "baslik": t("Aynı rafta iki satıcı", "Two sellers on the same shelf"),
    "not": t(
        "Beş fasılda da iki yön birden var: hem satıyoruz hem alıyoruz. Pay "
        "O FASLIN iki yönlü toplamına göre, bütün ticarete göre değil — her "
        "satır kendi içinde oranlanıyor. Sebzede Mısır önde (%60,9), meyvede "
        "Türkiye (%60,7). Yağda tek yönlülüğe yakın bir denge var (%98,9). "
        "Tek yönlü fasıllar listede yok: tek yönlü faslın payı olmaz. "
        "Rakamlar TÜRKİYE'NİN beyanından.",
        "In all five chapters both directions exist at once: we sell and we "
        "buy. The share is against THAT CHAPTER's two-way total, not against "
        "all trade — each row is scaled within itself. In vegetables Egypt "
        "leads (60.9%), in fruit Türkiye (60.7%). In fats the balance is "
        "close to one-directional (98.9%). One-directional chapters are not "
        "on the list: a one-way chapter has no share. The figures come from "
        "TÜRKİYE's reporting."),
    "kaynak": "UN Comtrade, 2024 · muhabir Türkiye · HS 01-24",
    "seriler": [
        {"ad": t("Türkiye satıyor", "Türkiye sells"), "rol": "vurgu"},
        {"ad": t("Mısır satıyor", "Egypt sells"), "rol": "ikincil"},
    ],
    "satirlar": [
        {"etiket": t("07 · Sebzeler", "07 · Vegetables"), "yil": 2024,
         "degerler": ["@turetilmis.fasil_iki_yonlu.0.giden_yuzde",
                      "@turetilmis.fasil_iki_yonlu.0.gelen_yuzde"],
         "ondalik": 1, "onek": YUZDE_ON, "sonek": YUZDE_SON,
         "_kimlik": ["@turetilmis.fasil_iki_yonlu.0.fasil", "07"]},
        {"etiket": t("08 · Meyveler ve yemişler", "08 · Fruit and nuts"),
         "yil": 2024,
         "degerler": ["@turetilmis.fasil_iki_yonlu.1.giden_yuzde",
                      "@turetilmis.fasil_iki_yonlu.1.gelen_yuzde"],
         "ondalik": 1, "onek": YUZDE_ON, "sonek": YUZDE_SON,
         "_kimlik": ["@turetilmis.fasil_iki_yonlu.1.fasil", "08"]},
        {"etiket": t("15 · Katı ve sıvı yağlar", "15 · Fats and oils"),
         "yil": 2024,
         "degerler": ["@turetilmis.fasil_iki_yonlu.2.giden_yuzde",
                      "@turetilmis.fasil_iki_yonlu.2.gelen_yuzde"],
         "ondalik": 1, "onek": YUZDE_ON, "sonek": YUZDE_SON,
         "_kimlik": ["@turetilmis.fasil_iki_yonlu.2.fasil", "15"]},
        {"etiket": t("20 · Sebze ve meyve müstahzarları",
                     "20 · Preparations of vegetables and fruit"), "yil": 2024,
         "degerler": ["@turetilmis.fasil_iki_yonlu.3.giden_yuzde",
                      "@turetilmis.fasil_iki_yonlu.3.gelen_yuzde"],
         "ondalik": 1, "onek": YUZDE_ON, "sonek": YUZDE_SON,
         "_kimlik": ["@turetilmis.fasil_iki_yonlu.3.fasil", "20"]},
        {"etiket": t("17 · Şeker ve şeker mamulleri",
                     "17 · Sugars and sugar confectionery"), "yil": 2024,
         "degerler": ["@turetilmis.fasil_iki_yonlu.4.giden_yuzde",
                      "@turetilmis.fasil_iki_yonlu.4.gelen_yuzde"],
         "ondalik": 1, "onek": YUZDE_ON, "sonek": YUZDE_SON,
         "_kimlik": ["@turetilmis.fasil_iki_yonlu.4.fasil", "17"]},
    ],
}

# ─── §14 · İKİ DEFTER ────────────────────────────────────────────────────
G["iki_defter"] = {
    "tur": "siralama",
    "baslik": t("İki defter, iki rakam", "Two ledgers, two figures"),
    "birim": t("milyon dolar · tarım ürünleri · 2024",
               "million dollars · agricultural goods · 2024"),
    "bolen": 1000000,
    "ondalik": 1,
    "onek": t("$", "$"),
    "not": t(
        "Aynı iki akış, iki ayrı defterden okunuyor. Türkiye'den Mısır'a "
        "giden mal Türkiye'nin defterinde 424,0 milyon, Mısır'ın defterinde "
        "267,0 milyon: arada %58,8 fark var. Ters yönde Mısır'ın beyanı "
        "282,0 milyon, Türkiye'nin beyanı 184,2 milyon: %53,1 fark. İki "
        "taraf da kendi GİDENİNİ fazla sayıyor — fark hesaplandı, sebebi "
        "iddia edilmedi; navlun, sigorta, serbest bölge ve kayıt zamanı "
        "farkları ayrı ayrı ölçülmedi.",
        "The same two flows, read from two separate ledgers. Goods going "
        "from Türkiye to Egypt are 424.0 million in Türkiye's ledger and "
        "267.0 million in Egypt's: a gap of 58.8%. In the other direction "
        "Egypt declares 282.0 million and Türkiye 184.2 million: a gap of "
        "53.1%. Each side counts its own OUTGOING flow higher — the gap was "
        "computed, its cause was not asserted; freight, insurance, free-zone "
        "treatment and timing differences were not measured separately."),
    "kaynak": "UN Comtrade, 2024 · iki muhabirin beyanı · HS 01-24",
    "satirlar": [
        {"etiket": t("Türkiye → Mısır · Türkiye'nin beyanı",
                     "Türkiye → Egypt · as Türkiye reports"),
         "deger": "@ticaret.tr_beyani_giden", "rol": "vurgu"},
        {"etiket": t("Türkiye → Mısır · Mısır'ın beyanı",
                     "Türkiye → Egypt · as Egypt reports"),
         "deger": "@ticaret.misir_beyani_gelen", "rol": "sessiz"},
        {"etiket": t("Mısır → Türkiye · Mısır'ın beyanı",
                     "Egypt → Türkiye · as Egypt reports"),
         "deger": "@ticaret.misir_beyani_giden", "rol": "ikincil"},
        {"etiket": t("Mısır → Türkiye · Türkiye'nin beyanı",
                     "Egypt → Türkiye · as Türkiye reports"),
         "deger": "@ticaret.tr_beyani_gelen", "rol": "sessiz"},
    ],
}

# ─── §15 · BELGE ─────────────────────────────────────────────────────────
G["kahirede_imzalandi"] = {
    "tur": "zaman_cizelgesi",
    "baslik": t("Kahire'de imzalandı, Mükerrer'de yayımlandı",
                "Signed in Cairo, published in a supplement"),
    "not": t(
        "Serbest Ticaret Anlaşması'nın yürürlüğe giriş yolu. Belge ana "
        "nüshanın içindekiler listesinde YOK; Mükerrer ekte. Bu tuzak bu "
        "projede daha önce de çıktı: TİGEM'i kuran kararname de 1984'te "
        "Mükerrer'de yayımlanmıştı. Anlaşmanın ekleri okundu: 19 dosya, "
        "tarım tavizleri Protokol II'de. Öteki ekler — Protokol I ve "
        "Liste 1-4 — sanayi ürünlerine ait ve bu dosyanın konusu değil.",
        "The route by which the Free Trade Agreement entered into force. The "
        "document is NOT in the table of contents of the main issue; it is in "
        "a supplement. This trap has appeared in this project before: the "
        "decree establishing TİGEM was likewise published in a supplement in "
        "1984. The annexes were read: 19 files, with the agricultural "
        "concessions in Protocol II. The other annexes — Protocol I and "
        "Lists 1 to 4 — cover industrial goods and are not this dossier's "
        "subject."),
    "kaynak": "Resmî Gazete 30 Ocak 2007 · sayı 26419 Mükerrer",
    "olaylar": [
        {"yil": 2005, "baslik": t("Kahire'de imza", "Signed in Cairo"),
         "aciklama": t("27 Aralık 2005.", "27 December 2005.")},
        {"yil": 2006,
         "baslik": t("Uygun bulma kanunu", "Act of approval"),
         "aciklama": t("5563 sayılı Kanun, 13 Aralık 2006.",
                       "Act no. 5563, 13 December 2006.")},
        {"yil": 2007, "baslik": t("Bakanlar Kurulu kararı",
                                  "Council of Ministers decision"),
         "aciklama": t("2007/11557, 15 Ocak 2007.",
                       "2007/11557, 15 January 2007.")},
        {"yil": 2007, "baslik": t("Resmî Gazete · Mükerrer",
                                  "Official Gazette · supplement"),
         "aciklama": t("30 Ocak 2007, sayı 26419 Mükerrer. Ana nüshanın "
                       "içindekiler listesinde görünmüyor.",
                       "30 January 2007, issue 26419 supplement. It does not "
                       "appear in the main issue's table of contents.")},
        {"yil": 2007, "baslik": t("Yürürlük", "Entry into force"),
         "aciklama": t("1 Mart 2007.", "1 March 2007.")},
    ],
}

# ─── §15b · TAVİZ DEĞİŞİMİ ───────────────────────────────────────────────
G["taviz_degisimi"] = {
    "tur": "kartlar",
    "baslik": t("İki tablo, iki kapı", "Two tables, two doors"),
    "not": t(
        "Protokol II tarım tavizlerini iki tabloda sıralıyor: Tablo A "
        "Türkiye'nin Mısır'a sattıklarını, Tablo B Mısır'ın Türkiye'ye "
        "sattıklarını. Toplam kota Tablo A'da 54.500 ton, Tablo B'de 58.015 "
        "ton — ama toplamlar değil, hangi ürüne ne kadar yer açıldığı "
        "anlamlı. Kota KOTA BAŞINA sayıldı, tarife pozisyonu başına değil: "
        "tabloda birleştirilmiş hücreler var. Tablo B'de iki satır "
        "'Sınırsız' diyor, Tablo A'da hiç yok.",
        "Protocol II lists the agricultural concessions in two tables: Table "
        "A what Türkiye sells to Egypt, Table B what Egypt sells to Türkiye. "
        "The total quota is 54,500 tonnes in Table A and 58,015 in Table B — "
        "but the totals are not the point; what matters is how much room was "
        "made for which product. Quotas were counted PER QUOTA, not per "
        "tariff line: the table has merged cells. Two lines in Table B read "
        "'Unlimited'; Table A has none."),
    "kaynak": "Türkiye–Mısır STA · Protokol II · RG 26419 Mükerrer, 30 Ocak 2007",
    "kartlar": [
        {"ust": t("Tablo B · Mısır → Türkiye", "Table B · Egypt → Türkiye"),
         "baslik": t("Pirinç", "Rice"),
         "govde": t("Türkiye'nin tarımda açtığı en büyük kapı pirinç: 30.000 "
                    "ton kahverengi pirinçte vergi tamamen kalkıyor, 10.000 "
                    "ton değirmenden geçmiş pirinçte %50 iniyor. İkisi Tablo "
                    "B'nin bütün kotasının %68,9'u. Mısır'ın pirinçte fazlası "
                    "var — üretimi Türkiye'nin 6,31 katı ve arzının yalnız "
                    "%3,9'u ithal.",
                    "The largest agricultural door Türkiye opened is rice: "
                    "duties go entirely on 30,000 tonnes of brown rice and "
                    "down by 50% on 10,000 tonnes of milled rice. Together "
                    "that is 68.9% of all quota in Table B. Egypt has a "
                    "surplus in rice — it produces 6.31 times Türkiye's "
                    "output and imports only 3.9% of its supply."),
         "rakam": {"deger": "@belge.taviz.pirinc_kotasi_ton", "ondalik": 0,
                   "sonek": t(" ton", " t"),
                   "etiket": t("iki pozisyonda toplam kota",
                               "total quota across two lines")}},
        {"ust": t("Tablo A · Türkiye → Mısır", "Table A · Türkiye → Egypt"),
         "baslik": t("Yağ", "Oils"),
         "govde": t("Mısır'ın açtığı en büyük kapı bitkisel yağ: ham "
                    "ayçiçeği ve aspir yağında 20.000 ton, soya ve ham mısır "
                    "yağında 10.000 ton, margarinde 1.000 ton — hepsinde "
                    "vergi tamamen kalkıyor. Tablo A'nın bütün kotasının "
                    "%75,2'si. On yedi yıl sonra, 2024'te Türkiye'nin Mısır'a "
                    "en çok sattığı fasıl hâlâ 15. fasıl, yani yağ.",
                    "The largest door Egypt opened is vegetable oil: 20,000 "
                    "tonnes of crude sunflower and safflower oil, 10,000 "
                    "tonnes each of soy and crude maize oil, 1,000 tonnes of "
                    "margarine — duties go entirely in all of them. That is "
                    "75.2% of all quota in Table A. Seventeen years later, in "
                    "2024, the chapter Türkiye sells most to Egypt is still "
                    "chapter 15: fats and oils."),
         "rakam": {"deger": "@belge.taviz.yag_kotasi_ton", "ondalik": 0,
                   "sonek": t(" ton", " t"),
                   "etiket": t("yağ ve margarin kotası",
                               "oil and margarine quota")}},
        {"ust": t("Tablo B · altı pozisyon", "Table B · six lines"),
         "baslik": t("Sebze", "Vegetables"),
         "govde": t("Marul, havuç, diğer taze sebzeler, dondurulmuşlar, "
                    "geçici konserveler ve kurutulmuş sebzeler — altı tarife "
                    "pozisyonu TEK kotayı paylaşıyor: 600 ton. Aynı tabloda "
                    "pirinç tek başına 40.000 ton alıyor. Oysa 2024'te "
                    "Türkiye'nin Mısır'dan en çok aldığı fasıl sebze (7. "
                    "fasıl) ve o fasılda Mısır iki yönlü akışın %60,9'unu "
                    "tutuyor. Belgenin en dar kapısı, rafın en kalabalık "
                    "rafı.",
                    "Lettuce, carrots, other fresh vegetables, frozen ones, "
                    "provisionally preserved ones and dried vegetables — six "
                    "tariff lines SHARE a single quota of 600 tonnes. In the "
                    "same table rice alone gets 40,000. Yet in 2024 the "
                    "chapter Türkiye buys most from Egypt is vegetables "
                    "(chapter 7), where Egypt holds 60.9% of the two-way "
                    "flow. The document's narrowest door is the shelf's "
                    "busiest."),
         "rakam": {"deger": "@belge.taviz.sebze_kotasi_ton", "ondalik": 0,
                   "sonek": t(" ton", " t"),
                   "etiket": t("altı pozisyon paylaşıyor",
                               "shared by six lines")}},
    ],
}

# ─── §16 · KIRSALDA ÇOĞUNLUK ─────────────────────────────────────────────
G["kirsalda_cogunluk"] = {
    "tur": "ikili_cubuk",
    "baslik": t("Hâlâ kırsalda yaşayan çoğunluk",
                "A majority still living in the countryside"),
    "not": t(
        "Mısır nüfusunun %53,1'i kırsalda; Türkiye'de %20,9. Mısır'da "
        "kırsalda yaşayan 63,7 milyon kişi var — Türkiye'nin bütün "
        "nüfusundan fazla. Her satır kendi nüfusuna oranlanıyor; iki satır "
        "birbiriyle karşılaştırılmıyor. Nüfus 2026 kalemi ve FAOSTAT'ın "
        "serisi 2100'e kadar gidiyor; projeksiyon yılları bu dosyaya "
        "alınmadı.",
        "53.1% of Egypt's population lives in rural areas; in Türkiye 20.9%. "
        "Egypt has 63.7 million people living in rural areas — more than "
        "Türkiye's entire population. Each row is scaled to its own "
        "population; the two rows are not compared with each other. The "
        "population item is for 2026 and FAOSTAT's series runs to 2100; "
        "projection years were not taken into this dossier."),
    "kaynak": "FAOSTAT Population · 2026",
    "seriler": [
        {"ad": t("Kırsal", "Rural"), "rol": "vurgu"},
        {"ad": t("Kentli", "Urban"), "rol": "ikincil"},
    ],
    "satirlar": [
        {"etiket": t("Mısır", "Egypt"), "yil": 2026,
         "degerler": ["@turetilmis.kirsal_payi_misir_yuzde",
                      "@turetilmis.kentli_payi_misir_yuzde"],
         "ondalik": 1, "onek": YUZDE_ON, "sonek": YUZDE_SON,
         "rozet": t("120,1 milyon kişi", "120.1 million people")},
        {"etiket": t("Türkiye", "Türkiye"), "yil": 2026,
         "degerler": ["@turetilmis.kirsal_payi_turkiye_yuzde",
                      "@turetilmis.kentli_payi_turkiye_yuzde"],
         "ondalik": 1, "onek": YUZDE_ON, "sonek": YUZDE_SON,
         "rozet": t("87,9 milyon kişi", "87.9 million people")},
    ],
}

# ─── §17 · KAPANIŞ ───────────────────────────────────────────────────────
G["tarimin_agirligi"] = {
    "tur": "ikili_cubuk",
    "baslik": t("Ekonomide tarımın ağırlığı",
                "Agriculture's weight in the economy"),
    "not": t(
        "Mısır'da tarım, ormancılık ve balıkçılık gayrisafi yurt içi "
        "hasılanın %11,39'u; Türkiye'de %4,42. Kalem ORMANCILIK VE BALIKÇILIK "
        "DAHİL: FAOSTAT'ın saf tarım kalemi bu iki ülke için boş ve boş sonuç "
        "sıfır değildir, o yüzden geniş kalem alındı ve kapsamı burada "
        "yazılıyor. Pay dolar tabanlı; yerel para tabanlı seriyle aynı "
        "değildir. Her satır kendi hasılasına oranlanıyor.",
        "In Egypt agriculture, forestry and fishing account for 11.39% of "
        "gross domestic product; in Türkiye 4.42%. The item INCLUDES FORESTRY "
        "AND FISHING: FAOSTAT's pure-agriculture item is empty for both "
        "countries, and an empty result is not a zero, so the wider item was "
        "used and its scope is stated here. The share is on a dollar basis "
        "and is not the same as the local-currency series. Each row is scaled "
        "to its own output."),
    "kaynak": "FAOSTAT Macro-Statistics · 2025 · kalem 22016",
    "seriler": [
        {"ad": t("Tarım, ormancılık ve balıkçılık",
                 "Agriculture, forestry and fishing"), "rol": "vurgu"},
        {"ad": t("Ekonominin geri kalanı", "The rest of the economy"),
         "rol": "ikincil"},
    ],
    "satirlar": [
        {"etiket": t("Mısır", "Egypt"), "yil": 2025,
         "degerler": ["@turetilmis.katma_deger_payi_misir_yuzde",
                      "@turetilmis.katma_deger_disi_payi_misir_yuzde"],
         "ondalik": 2, "onek": YUZDE_ON, "sonek": YUZDE_SON},
        {"etiket": t("Türkiye", "Türkiye"), "yil": 2025,
         "degerler": ["@turetilmis.katma_deger_payi_turkiye_yuzde",
                      "@turetilmis.katma_deger_disi_payi_turkiye_yuzde"],
         "ondalik": 2, "onek": YUZDE_ON, "sonek": YUZDE_SON},
    ],
}

cikti = {
    "_dosya": "Mısır — Ülke Dosyası Sayı 06 · grafik tarifleri",
    "_kural": "Sayılar @yol ile data.json'a bağlanır; elle rakam yazılmaz.",
    "_cizici_notu": (
        "Kullanılan tipler: kunye, ikili_cubuk, siralama, yigin, cizgi, "
        "kartlar, zaman_cizelgesi. ticaret_akisi ve islem_akisi BİLEREK "
        "kullanılmadı: ilki Irak dosyasının imzasıydı, ikincisi TİGEM'in. "
        "Dizide her dosyanın kendi grafik dağarcığı var."),
    "_bicim_notu": (
        "ikili_cubuk'ta sayı biçimi HER SATIRDA tekrarlanıyor. Grafik "
        "düzeyindeki sonek/ondalik çizici tarafından okunmuyor "
        "(dossier_chart.dart — IkiliSatir biçimi satır sözlüğünden kuruyor); "
        "TİGEM dosyasında ölçüldü, %90,93 '91' diye çiziliyordu."),
    "_yuzde_notu": (
        "Yüzde işareti Türkçede BAŞA, İngilizcede SONA gidiyor: "
        "onek {tr:'%', en:''} ve sonek {tr:'', en:'%'}. Boş dize eksiklik "
        "değil, DossierText.birebir'in beklediği şey."),
    "_rol_notu": (
        "`ikili_cubuk` ve `yigin` serileri vurgu + ikincil; `sessiz` seri "
        "olarak KULLANILMIYOR. Gerekçe kodda ölçülü: `ChartRole.taramali` "
        "yalnız ikincil için true, yani vurgu ile sessiz aynı çubukta yan "
        "yana durduğunda ayrımı taşıyan tek şey renk olur — ve bu paletin "
        "vurgu↔sessiz oranı deuteranopi altında 1,31'e düşüyor (ölçüm: "
        "_raw/kontrast.py). Vurgu ile ikincil yan yana durduğunda renk VE "
        "tarama birlikte taşıyor. `sessiz` yalnız `siralama`da bağlam "
        "satırı; orada ayrımı etiket ve çubuk uzunluğu taşıyor."),
    "_kimlik_notu": (
        "Sıralı bir listeden indeksle okunan satırlarda `_kimlik` alanı var: "
        "[yol, beklenen değer]. Etiket elle yazılıyor ama o indeksteki kaydın "
        "kime ait olduğu ÖLÇÜLMEMİŞ olurdu — kaynak veri sıralaması "
        "değişirse çubuk sessizce başka ülkeyi/faslı gösterir. "
        "dogrula_grafik.py bu eşleşmeyi sınıyor. Çizici `_` ile başlayan "
        "alanları okumuyor."),
    "grafikler": G,
}

yol = pathlib.Path(__file__).parent.parent / "grafikler.json"
yol.write_text(json.dumps(cikti, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"✓ {yol} · {len(G)} grafik")
for k, v in G.items():
    print(f"  {k:24s} {v['tur']}")
