#!/usr/bin/env python3
"""Grafik envanterinden (_raw/grafik_envanteri.json) yayımlanacak grafikleri
(_raw/grafikler.json) üretir ve [[grafik:…]] yönergelerini TR/EN metinlere
aynı blok sırasına yerleştirir (karar 58).

    python3 -I grafik_donustur.py            # grafikler.json yaz, yönergeleri yerleştir
    python3 -I grafik_donustur.py --kuru     # yalnız özet, dosyaya dokunma

Envanter ham kalır; seçim, tür eşlemesi, birim, dizi adları ve rolleri burada.
Yönerge yerleştirme tekrar çalıştırmada aynı yönergeyi ikinci kez eklemez.
grafikler.json elle düzeltilirse düzeltme bu betiğe de işlenmeli; yoksa bir
sonraki çalıştırma onu ezer.
"""
from __future__ import annotations

import json
import re
import sys
import unicodedata
from pathlib import Path

KOK = Path(__file__).resolve().parent.parent
RAW = KOK / "_raw"
BOLUMLER = KOK / "bolumler"

# Metindeki tabloyu birebir tekrar edenler ve cümleye bir şey katmayanlar.
ATLA = {
    "b09-makine-ogrenmesi-mars", "b11-gida-kaybi-bolgeler", "b12-kusak-araligi",
    "b13-otonom-sera-turlari", "b15-ormansizlasma", "b07-sulama-orani",
    "b22-cin-bilisimlesme-hedefi",
}

TUR = {
    "yatay_cubuk": "yatay_cubuk", "dikey_cubuk": "dikey_cubuk", "gruplu_cubuk": "dikey_cubuk",
    "cizgi": "cizgi", "dumbbell": "dumbbell", "aralik_cubugu": "aralik",
    "yuzde100_yigilmis": "pay", "waffle": "waffle", "egim": "egim", "kucuk_coklu": "kucuk",
    "isi_haritasi": "isi", "zaman_cizelgesi": "zaman", "kpi_karti": "kpi",
}
TUR_DEGISIR = {
    "b03-imagenet-2012": "yatay_cubuk",
    "b05-hizli-islah-kusak": "aralik",
    "b08-laboratuvar-tarla-dogruluk": "yatay_cubuk",
    "b22-afrika-kayitli-kullanan": "aralik",
    "b23-uc-belgede-sifir": "waffle",
    "b26-manyok-f1-tarlada": "cizgi",
}

YUZDE = {"tr": "%", "en": "%"}
# (birim, eksen) — eksen: başlığın altındaki ölçü adı.
OLCU = {
    "b01-ab-hassas-tarim-pay-ve-alan": (YUZDE, None),
    "b03-donum-noktalari": (None, None),
    "b03-imagenet-2012": (YUZDE, ("Hata oranı, en iyi beş tahmin", "Top-5 error rate")),
    "b04-detayli-toprak-etudu": ({"tr": "milyon ha", "en": "million ha"}, ("Etüdü tamamlanan ya da öngörülen alan", "Area surveyed or planned")),
    "b05-genomik-secilim-isabeti": (None, ("Seçim isabeti (korelasyon, r)", "Selection accuracy (correlation, r)")),
    "b05-hizli-islah-kusak": ({"tr": "kuşak", "en": "generations"}, ("Bir yılda alınan kuşak sayısı", "Generations per year")),
    "b06-vrt-ekili-alan": (YUZDE, ("Ekili alandaki payı", "Share of planted acres")),
    "b06-sensorlu-azot-tarlalar": (YUZDE, ("Tarlaların payı", "Share of sites")),
    "b06-cukurova-farkindalik": (YUZDE, ("Katılımcıların payı", "Share of respondents")),
    "b07-su-cekimi-paylari": (YUZDE, ("Çekilen tatlı suyun payı", "Share of freshwater withdrawn")),
    "b08-laboratuvar-tarla-dogruluk": (YUZDE, ("Doğruluk", "Accuracy")),
    "b08-hedefli-ilaclama-azalmalar": (YUZDE, ("Yayma ilaçlamaya göre azalma", "Reduction compared with broadcast spraying")),
    "b10-sweeper-kosullar": (YUZDE, ("Hasat başarısı", "Harvest success")),
    "b10-hasat-robotu-basamaklari": (YUZDE, ("Başarı oranı, robotların ortalaması", "Success rate, average across robots")),
    "b11-depolama-kaybi": (YUZDE, ("Depoda kaybolan tahılın payı", "Share of grain lost in storage")),
    "b12-sensor-dogrulama": (YUZDE, ("Bağımsız olarak doğrulanmış olanların payı", "Share independently validated")),
    "b12-meta-analiz-eleme": ({"tr": "çalışma", "en": "studies"}, None),
    "b14-izlenmeyen-gemiler": (YUZDE, ("Kamuya açık izlemede görünmeyen pay", "Share missing from public tracking")),
    "b15-yanan-alan-son-bes-yil": (YUZDE, None),
    "b16-gru-arima-hata": (None, ("Hata (RMSE): düşük olan daha iyi", "Error (RMSE): lower is better")),
    "b17-zirai-don-2025": ({"tr": "milyar TL", "en": "billion TL"}, None),
    "b17-baz-riski": (YUZDE, None),
    "b17-don-ihbarlari": (YUZDE, None),
    "b18-chatgpt-yayim-elemani": (YUZDE, None),
    "b18-dil-modeli-dogruluk-araligi": (YUZDE, ("Doğruluk: istem stratejisine göre en düşük ve en yüksek", "Accuracy: lowest and highest by prompting strategy")),
    "b19-landsat-acik-veri": ({"tr": "kat", "en": "×"}, ("Artış", "Increase")),
    "b20-baglanti-isletme-buyuklugu": (YUZDE, ("Kapsama alanındaki işletmelerin payı", "Share of farms with coverage")),
    "b20-kent-kir-isi-haritasi": (YUZDE, ("Nüfusun payı", "Share of population")),
    "b20-akilli-tarim-anketi": ({"tr": "çiftçi", "en": "farmers"}, None),
    "b20-akilli-tarim-hedef": ({"tr": "işletme", "en": "farms"}, None),
    "b21-sozlesme-okunabilirlik": (YUZDE, ("Sözleşmelerin payı", "Share of agreements")),
    "b21-cks-kayitli-alan": ({"tr": "milyon ha", "en": "million ha"}, None),
    "b22-abd-iki-olcu": (YUZDE, None),
    "b22-ab-dijital-araclar": (YUZDE, ("Çiftliklerin payı", "Share of farms")),
    "b22-cin-kirsal-internet": (YUZDE, None),
    "b22-afrika-kayitli-kullanan": (YUZDE, ("Kayıtlı kullanıcıların payı", "Share of registered users")),
    "b23-uc-belgede-sifir": (None, None),
    "b23-strateji-belgesi-takvimi": (None, None),
    "b24-ab-mevzuat-takvimi": (None, None),
    "b25-ekosistem-baslangic-yillari": (None, None),
    "b26-manyok-f1-tarlada": (None, ("F-1 skoru", "F1 score")),
    "b26-fao-27-vaka": (None, None),
    "b26-tarim-yaslanma": (None, None),
    "b27-tucsap-harcama": (None, None),
    "b27-vaatten-iflasa": (None, None),
    "b28-nuru-teshis": (YUZDE, ("Doğru teşhis oranı", "Diagnostic accuracy")),
    "b28-dron-operatorleri": (YUZDE, ("Operatörlerin payı", "Share of operators")),
}
UST = {"b05-genomik-secilim-isabeti": 1, "b26-manyok-f1-tarlada": 1}
ONDALIK = {"b16-gru-arima-hata": 0}

DIZI_EN = {
    "hassas tarım uygulayan": "farms using precision farming", "Dünya": "World", "Türkiye": "Türkiye",
    "2012": "2012", "tamamlanan": "completed", "öngörülen": "planned", "tane verimi": "grain yield",
    "normal sera": "normal glasshouse", "hızlı ıslah": "speed breeding", "ilk ölçüm": "first measurement",
    "son ölçüm": "latest measurement", "tek ölçüm": "single measurement", "verim": "yield", "kâr": "profit",
    "beklenti": "expectations", "bilgi": "knowledge", "tarım": "agriculture", "sanayi": "industry",
    "hizmet / belediye": "services / municipal", "laboratuvar": "controlled conditions",
    "başka koşullar": "other conditions", "referans": "random guess", "ilaç": "herbicide use",
    "akış suyu": "runoff", "uygun koşul": "best-fit conditions", "olağan koşul": "current conditions",
    "ortalama başarı": "average success", "geleneksel depo": "deficient storage",
    "bilimsel depolama": "scientific storage", "türe göre": "by type", "genel": "all technologies",
    "eleme": "screening", "birleşik analiz dökümü": "pooled analysis breakdown", "balıkçılık": "fishing",
    "taşıma ve enerji": "transport and energy", "son beş yıl": "last five years",
    "GRU (derin öğrenme)": "GRU (deep learning)", "ARIMA (klasik)": "ARIMA (classic)",
    "sigorta": "insurance", "destekleme": "support payment", "toplam": "total",
    "ortak risk": "covariate risk", "asıl risk": "original risk", "don": "frost",
    "GPT-4o": "GPT-4o", "Gemini": "Gemini", "artış": "increase", "küçük işletme": "small farms",
    "büyük işletme": "large farms", "Kent": "Urban", "Kır": "Rural", "kullanan": "users",
    "istekli": "keen to use", "kullanmayan": "non-users", "hedef": "target", "gerçekleşme": "actual",
    "okunabilirlik": "readability", "eğitim düzeyi": "education level", "oran": "rate",
    "çiftlik payı": "share of farms", "alan payı": "share of acres", "dijital araç": "digital tools",
    "hassas tarım": "precision farming", "hassas tarım alt kalemi": "precision farming techniques",
    "yüksek etkin": "highly active", "vurgu": "highlighted", "süreç": "process", "vaat": "promise",
    "durum": "status", "Yapay Zekâ Tüzüğü": "AI Act", "Veri Tüzüğü": "Data Act",
    "Makine Tüzüğü": "Machinery Regulation", "Girişimler": "Startups",
    "Üniversite merkezleri": "University centres", "Programlar": "Programmes",
    "belirgin belirti": "clear symptoms", "hafif belirti": "mild symptoms", "kârlı": "profitable",
    "bütün istihdam": "all employment", "bütçe": "budget", "harcama": "spending", "harcanan": "spent",
    "planlanan": "planned", "Infarm": "Infarm", "AppHarvest": "AppHarvest",
    "Small Robot Company": "Small Robot Company", "insan": "people", "uygulama": "app",
    "uygulama koşulu": "application practice", "risk ve sorun": "risks and problems",
    "en iyi puan sıklığı": "best-score frequency",
    "kırsal internet yaygınlığı (%)": "rural internet penetration", "kent-kır farkı (puan)": "urban–rural gap",
}
DIZI_TR = {  # okura görünen Türkçe ad (envanterdeki kısa ad yetmediğinde)
    "hassas tarım uygulayan": "Hassas tarım uygulayan çiftlikler",
    "hassas tarım alt kalemi": "Hassas tarım teknikleri",
    "birleşik analiz dökümü": "Birleşik analizin dökümü",
    "laboratuvar": "Denetimli koşullar",
    "referans": "Rastgele tahmin",
    "genel": "Bütün teknolojiler",
}
ROL = {
    ("b04-detayli-toprak-etudu", "öngörülen"): "ongoru",
    ("b08-laboratuvar-tarla-dogruluk", "referans"): "referans",
    ("b12-sensor-dogrulama", "genel"): "referans",
    ("b12-meta-analiz-eleme", "birleşik analiz dökümü"): "alt",
    ("b17-zirai-don-2025", "toplam"): "toplam",
    ("b20-akilli-tarim-anketi", "toplam"): "toplam",
    ("b22-ab-dijital-araclar", "hassas tarım alt kalemi"): "alt",
    ("b23-uc-belgede-sifir", "toplam"): "toplam",
    ("b26-fao-27-vaka", "toplam"): "toplam",
    ("b20-akilli-tarim-hedef", "hedef"): "ongoru",
    ("b21-cks-kayitli-alan", "hedef"): "ongoru",
    ("b27-tucsap-harcama", "hedef"): "ongoru",
    ("b27-tucsap-harcama", "planlanan"): "ongoru",
}
PANEL_EN = {
    "Çiftlik payı · hassas tarım uygulaması (NASS)": "Share of farms · precision agriculture practices (NASS)",
    "Ekili alan payı · mısırda otomatik dümen (ERS)": "Share of planted acres · auto-steer on corn (ERS)",
    "Ulusal YZ Stratejisi 2024-2025 Eylem Planı": "National AI Strategy 2024–2025 Action Plan",
    "Türkiye Yapay Zekâ Eylem Planı (2026-2030)": "Türkiye AI Action Plan (2026–2030)",
    "2027 Yıllık Programı": "2027 Annual Programme",
    "Ortalama yaş": "Average age",
    "40 yaşın üzerindekilerin payı": "Share aged over 40",
    "2025 bütçesi ve harcama": "2025 budget and spending",
    "Kredi": "Loan",
    "Hibe": "Grants",
    "İklim akıllı teknoloji benimseyen çiftçi": "Farmers adopting climate-smart technology",
}
NOKTA_BIRIMI = {
    "yıl": {"tr": "yıl", "en": "years"}, "%": YUZDE, "milyon €": {"tr": "milyon avro", "en": "million euros"},
    "avro": {"tr": "avro", "en": "euros"}, "çiftçi": {"tr": "çiftçi", "en": "farmers"},
    "bin ha": None,  # b04: milyon ha'ya çevriliyor (çarpan)
}
# Grafiğe girmeyen, başlıkta ya da açıklamada kalan bağlam rakamları.
DUS = {
    ("b15-yanan-alan-son-bes-yil", "toplam"), ("b17-don-ihbarlari", None), ("b21-sozlesme-okunabilirlik", "toplam"),
    ("b22-afrika-kayitli-kullanan", "toplam"), ("b27-tucsap-harcama", "oran"),
}

AY = {"tr": ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"],
      "en": ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October",
             "November", "December"]}


def bas_buyuk_tr(ad: str) -> str:
    """Türkçe baş harf büyütme: i → İ, ı → I (str.upper 'i'yi 'I' yapar)."""
    if not ad or ad[0].isupper():
        return ad
    return {"i": "İ", "ı": "I"}.get(ad[0], ad[0].upper()) + ad[1:]


def kod(ad: str) -> str:
    s = unicodedata.normalize("NFKD", ad.replace("ı", "i").replace("İ", "i")).encode("ascii", "ignore").decode().lower()
    return re.sub(r"[^a-z0-9]+", "-", s).strip("-") or "dizi"


def tarih_yazisi(iso: str, dil: str) -> str:
    def tek(x: str) -> str:
        p = x.split("-")
        if len(p) == 1:
            return p[0]
        ay = AY[dil][int(p[1]) - 1]
        return f"{ay} {p[0]}" if len(p) == 2 else f"{int(p[2])} {ay} {p[0]}"
    if "/" in iso:
        a, b = iso.split("/")
        pa, pb = a.split("-"), b.split("-")
        if len(pa) == 3 and len(pb) == 3 and pa[:2] == pb[:2]:
            ayrac = "-" if dil == "tr" else "–"
            return f"{int(pa[2])}{ayrac}{int(pb[2])} {AY[dil][int(pa[1]) - 1]} {pa[0]}"
        return f"{tek(a)} – {tek(b)}"
    return tek(iso)


def yil_kesri(iso: str) -> float:
    p = iso.split("/")[0].split("-")
    y, m, g = int(p[0]), (int(p[1]) if len(p) > 1 else 1), (int(p[2]) if len(p) > 2 else 1)
    return round(y + (m - 1) / 12 + (g - 1) / 372, 4)


def iki(tr: str, en: str) -> dict:
    return {"tr": tr, "en": en}


def donustur(o: dict) -> dict:
    kimlik = o["id"]
    tur = TUR_DEGISIR.get(kimlik, TUR[o["tur"]])
    birim, eksen = OLCU[kimlik]
    noktalar, dizi_sirasi = [], []
    for x in o["veri"]:
        dz = x.get("dizi") or ""
        if (kimlik, dz) in DUS or ((kimlik, None) in DUS and x.get("birim")):
            continue
        n: dict = {"kategori": iki(x["etiket_tr"], x["etiket_en"]), "dizi": kod(dz)}
        if dz not in dizi_sirasi:
            dizi_sirasi.append(dz)
        if tur == "zaman":
            n["deger"] = yil_kesri(str(x["tarih_iso"]))
            n["ek"] = iki(tarih_yazisi(str(x["tarih_iso"]), "tr"), tarih_yazisi(str(x["tarih_iso"]), "en"))
        else:
            n["deger"] = x["deger"]
        if x.get("uc"):
            n["uc"] = x["uc"]
        if x.get("panel"):
            n["panel"] = iki(x["panel"], PANEL_EN[x["panel"]])
        if x.get("birim") and tur != "zaman":
            b = NOKTA_BIRIMI.get(x["birim"])
            if x["birim"] == "bin ha":
                n["carpan"] = 0.001
            elif b is not None:
                n["birim"] = b
        if x.get("satici"):
            n["satici"] = True
        for a in ("kayit", "kaynak"):
            n[a] = x[a]
        if kimlik == "b23-strateji-belgesi-takvimi" and x.get("alan") == "durum":
            n["alan"] = "yayim"  # yılın (2026) geçtiği alan: belgenin durumu bu tarih itibarıyla
        elif x.get("alan"):
            n["alan"] = x["alan"]
        elif x.get("alinti"):
            n["alinti"] = x["alinti"]
        noktalar.append(n)
    diziler = []
    for dz in dizi_sirasi:
        d = {"kod": kod(dz), "tr": DIZI_TR.get(dz, bas_buyuk_tr(dz)),
             "en": DIZI_EN[dz][:1].upper() + DIZI_EN[dz][1:]}
        if ROL.get((kimlik, dz)):
            d["rol"] = ROL[(kimlik, dz)]
        diziler.append(d)

    # Türe özgü düzenlemeler.
    if kimlik == "b06-vrt-ekili-alan":
        for n in noktalar:  # "Mısır · 2005" → kategori "Mısır", not "2005"
            for dil in ("tr", "en"):
                ad, yil = n["kategori"][dil].rsplit(" · ", 1)
                n["kategori"][dil] = ad
                n.setdefault("ek", {"tr": "", "en": ""})[dil] = yil
    if kimlik in ("b07-su-cekimi-paylari",):
        for n in noktalar:
            for dil in ("tr", "en"):
                n["kategori"][dil] = n["kategori"][dil].split(" · ")[0]
    if kimlik == "b17-zirai-don-2025":
        for n in noktalar:
            if n["dizi"] != "toplam":
                n["kategori"] = iki("2025 zirai donu için yapılan ödemeler", "Payments for the 2025 frost")
        diziler = [dict(d, tr={"sigorta": "Sigorta hasar tazminatı", "destekleme": "Cumhurbaşkanı Kararı'yla destekleme ödemesi"}.get(d["kod"], d["tr"]),
                        en={"sigorta": "Insurance indemnities", "destekleme": "Support payment by Presidential Decision"}.get(d["kod"], d["en"]))
                   for d in diziler]
    if kimlik == "b20-akilli-tarim-anketi":
        adlar = {}
        for n in noktalar:
            if n["dizi"] != "toplam":
                adlar[n["dizi"]] = dict(n["kategori"])
                n["kategori"] = iki("Ankete katılan çiftçiler", "Surveyed farmers")
        diziler = [dict(d, tr=adlar.get(d["kod"], {}).get("tr", d["tr"]), en=adlar.get(d["kod"], {}).get("en", d["en"]))
                   for d in diziler]
    if kimlik in ("b10-sweeper-kosullar", "b18-chatgpt-yayim-elemani"):
        ortak = {"b10-sweeper-kosullar": iki("SWEEPER biber hasat robotu", "SWEEPER sweet pepper harvesting robot"),
                 "b18-chatgpt-yayim-elemani": iki("Yanıtların en iyi puanı alma sıklığı", "How often answers got the best score")}[kimlik]
        yeni_diziler = []
        for n in noktalar:
            yeni_diziler.append({"kod": kod(n["kategori"]["tr"]), "tr": n["kategori"]["tr"], "en": n["kategori"]["en"]})
            n["dizi"] = kod(n["kategori"]["tr"])
            n["kategori"] = dict(ortak)
        diziler = yeni_diziler
    if kimlik == "b22-ab-dijital-araclar":
        for n in noktalar:
            for dil in ("tr", "en"):
                n["kategori"][dil] = n["kategori"][dil].removeprefix("· ")
    if kimlik == "b22-cin-kirsal-internet":
        # Eğim: diziler zaman noktaları, kategoriler ölçüler.
        olcu = {"kirsal-internet-yayginligi": iki("Kırsal internet yaygınlığı", "Rural internet penetration"),
                "kent-kir-farki-puan": iki("Kent ile kır arasındaki fark", "Urban–rural gap")}
        yeni_diziler = []
        for n in noktalar:
            zaman = n["kategori"]
            zk = kod(zaman["tr"])
            if zk not in [d["kod"] for d in yeni_diziler]:
                yeni_diziler.append({"kod": zk, **zaman})
            eski = n["dizi"]
            n["kategori"] = dict(olcu[eski])
            n["dizi"] = zk
            if eski == "kent-kir-farki-puan":
                n["birim"] = {"tr": "puan", "en": "points"}
        diziler = yeni_diziler
    if kimlik == "b26-tarim-yaslanma":
        pass
    g = {
        "baslik_no": o["baslik_no"],
        "tur": tur,
        "baslik": iki(o["baslik_tr"], o["baslik_en"]),
        "aciklama": iki(o["aciklama_tr"], o["aciklama_en"]),
        "kaynak": iki(o["kaynak_satiri_tr"], o["kaynak_satiri_en"]),
    }
    if birim:
        g["birim"] = birim
    if eksen:
        g["eksen"] = iki(*eksen)
    if kimlik in UST:
        g["ust"] = UST[kimlik]
    if kimlik in ONDALIK:
        g["ondalik"] = ONDALIK[kimlik]
    g["diziler"] = diziler
    g["noktalar"] = noktalar
    g["yer"] = o["yer"]
    return g


def bloklar(metin: str) -> list[str]:
    return [b for b in re.split(r"\n\s*\n", metin.strip()) if b.strip()]


def yerlestir(metin: str, eklenecek: dict[int, list[str]]) -> str:
    parcalar = re.split(r"(\n[ \t]*\n\s*)", metin)
    sayac = -1
    for j in range(0, len(parcalar), 2):
        if parcalar[j].strip():
            sayac += 1
            if sayac in eklenecek:
                parcalar[j] = parcalar[j].rstrip("\n") + "".join(f"\n\n{y}" for y in eklenecek[sayac])
    return "".join(parcalar)


def main() -> int:
    kuru = "--kuru" in sys.argv
    env = json.loads((RAW / "grafik_envanteri.json").read_text(encoding="utf-8"))
    secilen = [o for o in env["oneriler"] if o["id"] not in ATLA]
    secilen.sort(key=lambda o: (o["baslik_no"], env["oneriler"].index(o)))
    grafikler = {o["id"]: donustur(o) for o in secilen}
    print(f"{len(grafikler)} grafik ({len(env['oneriler']) - len(grafikler)} atlandı)")
    if kuru:
        return 0
    (RAW / "grafikler.json").write_text(json.dumps(
        {"_ne": "Yayımlanan grafikler (karar 58). Envanter: grafik_envanteri.json; her değer kayda bağlı "
                "(dogrula_bolumler.py kural 11). Yönerge: metinde [[grafik:<kimlik>]] satırı, 'yer' paragrafının ardında.",
         "grafikler": grafikler}, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    # Yönergeler: TR'de 'yer' paragrafının ardına, EN'de aynı blok sırasına.
    for no in sorted({g["baslik_no"] for g in grafikler.values()}):
        tr = next(BOLUMLER.glob(f"{no:02d}-*.tr.md"))
        en = tr.with_name(tr.name.replace(".tr.md", ".en.md"))
        mt, me = tr.read_text(encoding="utf-8"), en.read_text(encoding="utf-8")
        bt, be = bloklar(mt), bloklar(me)
        if len(bt) != len(be):
            print(f"  ! {tr.name}: TR {len(bt)}, EN {len(be)} blok — yerleştirilmedi")
            continue
        eklenecek: dict[int, list[str]] = {}
        for kimlik, g in grafikler.items():
            if g["baslik_no"] != no or f"[[grafik:{kimlik}]]" in mt:
                continue
            i = [k for k, b in enumerate(bt) if b.startswith(g["yer"])]
            if len(i) != 1:
                print(f"  ! {kimlik}: yer bulunamadı ya da birden çok")
                continue
            eklenecek.setdefault(i[0], []).append(f"[[grafik:{kimlik}]]")
        if eklenecek:
            tr.write_text(yerlestir(mt, eklenecek), encoding="utf-8")
            en.write_text(yerlestir(me, eklenecek), encoding="utf-8")
            print(f"  · {tr.name}: {sum(len(v) for v in eklenecek.values())} grafik")
    return 0


if __name__ == "__main__":
    sys.exit(main())
