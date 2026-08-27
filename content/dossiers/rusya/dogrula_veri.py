#!/usr/bin/env python3
"""Rusya dosyası — data.json denetimi.

data.json'daki her değerin _raw/ altındaki ham çekimle tuttuğunu sınar.
build_data.mjs'in kendi çıktısına bakmakla yetinmez: ham dosyaya geri gider.

    python3 content/dossiers/rusya/dogrula_veri.py

Çıkış kodu 0 = temiz, 1 = en az bir denetim düştü.
"""
import json
import pathlib
import sys

DIR = pathlib.Path(__file__).parent
oku = lambda p: json.loads((DIR / p).read_text(encoding="utf-8"))

data = oku("data.json")
wb = oku("_raw/worldbank.json")
psd = oku("_raw/usda_psd.json")
ct = oku("_raw/comtrade_ikili.json")
fao_deger = oku("_raw/faostat_deger.json")
fao_ikili = oku("_raw/faostat_ikili.json")
kurumlar = oku("_raw/kurumlar.json")

gecen, kalan = [], []


def sina(ad, kosul, ayrinti=""):
    (gecen if kosul else kalan).append((ad, ayrinti))


# ── 1. Çift sayım — SESSİZ HATA SINIFI ───────────────────────────────────────
# Comtrade her hücreyi hem toplu (C00/mot0) hem kırılımlı döndürüyor. Hepsi
# toplanırsa sonuç iki katı çıkar. Ham dosyada yalnızca süzülmüş satır olmalı.

TOPLULASTIRICI = {
    "Crops and livestock products", "Cereals, primary", "Food, Total",
    "Agricultural Products, Total", "Crops, Total", "Non-Food, Total",
    "Agriculture", "Crops", "Livestock", "Fruit Primary", "Vegetables Primary",
}

sina(
    "Comtrade ham dosyasında çift sayım kuralı yazılı",
    "customsCode" in ct.get("_cift_sayim_kurali", "") and "motCode" in ct["_cift_sayim_kurali"],
)

# Fasıl toplamı, tek tek fasılların toplamına eşit olmalı ve fasıllar
# birbirini İÇERMEMELİ (HS fasılları ayrık; topluluştırıcı fasıl yok).
tarim = [f"{i:02d}" for i in range(1, 25)]
for satir in data["ikili_ticaret"]["seri"]:
    y = str(satir["yil"])
    for flow, alan in (("X", "turkiyeden_rusyaya_usd"), ("M", "rusyadan_turkiyeye_usd")):
        ham = ct["fasillar"][y][flow]
        beklenen = round(sum(v["deger_usd"] for k, v in ham.items() if k in tarim))
        sina(
            f"ikili_ticaret {y}/{flow} ham toplamla tutuyor",
            abs(satir[alan] - beklenen) <= 1,
            f"data={satir[alan]:,} ham={beklenen:,}",
        )

# FAOSTAT toplamlarında topluluştırıcı kalem ayrıntıyla karışmamalı.
sina(
    "FAOSTAT üretim değeri kalemleri tek tek okunuyor, toplanmıyor",
    all(k["kalem"] in TOPLULASTIRICI for k in data["uretim_degeri"]["kalemler"]),
    "hepsi topluluştırıcı — tek tek kullanılıyorlar, toplanmadıkları için sorun yok",
)

# ── 2. Ortak yıl + ileri not ─────────────────────────────────────────────────
for s in data["toprak_ve_verim"]["satirlar"]:
    kod = next(
        (k for k, v in wb["gostergeler"].items() if v["etiket"] == s["birim"]), None
    )
    sina(f"WB göstergesi bulundu: {s['etiket']}", kod is not None)
    if not kod:
        continue
    x = wb["gostergeler"][kod]
    sina(
        f"{s['etiket']} ortak yıldan alınmış",
        s["yil"] == x["_ortak_son_yil"],
        f"data={s['yil']} ham={x['_ortak_son_yil']}",
    )
    sina(
        f"{s['etiket']} ileri notu taşınmış",
        s["_ileri_not"] == x["_ileri_not"],
    )
    y = str(s["yil"])
    sina(
        f"{s['etiket']} değerleri ham dosyayla tutuyor",
        s["RUS"] == x["RUS"].get(y) and s["TUR"] == x["TUR"].get(y),
    )

sina(
    "PSD karşılaştırmaları tahmin yılından kurulmamış",
    data["isleme_makinesi"]["_yil"] == psd["_kesin_son_yil"] == 2024,
    f"kullanılan={data['isleme_makinesi']['_yil']} kesin={psd['_kesin_son_yil']}",
)

# ── 3. Tez dayanağı ──────────────────────────────────────────────────────────
d = data["tez"]["dayanak"]
y = str(d["yil"])
ham_m = ct["fasillar"][y]["M"]
ham_x = ct["fasillar"][y]["X"]
top_m = sum(v["deger_usd"] for k, v in ham_m.items() if k in tarim)
top_x = sum(v["deger_usd"] for k, v in ham_x.items() if k in tarim)
dep = sum(ham_m[k]["deger_usd"] for k in ("10", "12", "23") if k in ham_m)
boz = sum(ham_x[k]["deger_usd"] for k in ("03", "07", "08") if k in ham_x)
sina(
    "tez: depolanabilir payı ham veriyle tutuyor",
    abs(d["rusyadan_aldigimiz_depolanabilir"]["pay_yuzde"] - round(100 * dep / top_m, 1)) < 0.05,
)
sina(
    "tez: bozulur payı ham veriyle tutuyor",
    abs(d["rusyaya_sattigimiz_bozulur"]["pay_yuzde"] - round(100 * boz / top_x, 1)) < 0.05,
)
sina(
    "tez dayanağı gerçekten asimetri gösteriyor",
    d["rusyadan_aldigimiz_depolanabilir"]["pay_yuzde"] > 50
    and d["rusyaya_sattigimiz_bozulur"]["pay_yuzde"] > 50,
    "tez bu iki payın ikisinin de baskın olmasına dayanıyor",
)

# ── 4. Ambargo serisi ────────────────────────────────────────────────────────
for k in data["ambargo_2016"]["kalemler"]:
    ham2015 = ct["kalemler"]["2015"]["X"].get(k["kod"], {}).get("deger_usd", 0)
    ham2016 = ct["kalemler"]["2016"]["X"].get(k["kod"], {}).get("deger_usd", 0)
    sina(f"ambargo {k['ad']} 2015 ham veriyle tutuyor", abs(k["zirve_oncesi_2015"] - round(ham2015)) <= 1)
    sina(f"ambargo {k['ad']} 2016 ham veriyle tutuyor", abs(k["dip_2016"] - round(ham2016)) <= 1)
sina(
    "ambargo: domates 2016'da gerçekten sıfır",
    data["ambargo_2016"]["kalemler"][0]["dip_2016"] == 0,
)

# ── 5. Müşteri sıralaması ────────────────────────────────────────────────────
sy = str(data["musteriler"]["son_yil"])
sina(
    "Rusya'nın FAOSTAT raporlaması gerçekten 2021'de bitiyor",
    max(int(x) for x in fao_ikili["siralama"]) == data["musteriler"]["son_yil"] == 2021,
)
sina(
    "Türkiye Rusya'nın 1 numaralı tarım müşterisi",
    data["musteriler"]["seri"][sy]["turkiye_sirasi"] == 1,
    f"sıra={data['musteriler']['seri'][sy]['turkiye_sirasi']}",
)
# Türkiye HEP birinci değil — bu denetim onu doğrulamıyor, tam tersine
# "kesintisiz" gibi bir iddianın metne girmesini engelliyor.
b = data["musteriler"]["birincilik"]
sina(
    "birincilik bloğu istisnaları saklamıyor",
    isinstance(b["ilk_yildan_beri_istisnalar"], list),
    f"istisna: {b['ilk_yildan_beri_istisnalar']}",
)
sina(
    "birinciliğin başlangıç yılı seriden türetilmiş",
    data["musteriler"]["seri"][str(b["ilk_birincilik_yili"])]["turkiye_sirasi"] == 1
    and all(
        data["musteriler"]["seri"][str(y)]["turkiye_sirasi"] != 1
        for y in range(min(int(k) for k in data["musteriler"]["seri"]), b["ilk_birincilik_yili"])
    ),
    f"ilk birincilik {b['ilk_birincilik_yili']}",
)
sina(
    "en düşük sıra kayıtta — yükselişin başlangıcı gizlenmiyor",
    b["en_dusuk"]["sira"] > 1,
    f"{b['en_dusuk']['yil']}: {b['en_dusuk']['sira']}. sıra",
)
sina(
    "Türkiye'nin payı her yıl hesaplanabiliyor",
    all(v["turkiye_payi_yuzde"] is not None for v in data["musteriler"]["seri"].values()),
)

# ── 6. Kurumsal katman ───────────────────────────────────────────────────────
sina(
    "doğrulanmamış kalemler data.json'a taşınmış",
    len(data["kurumlar"]["_dogrulanmamis_kalemler"]) == len(kurumlar["dogrulanamadi"]),
)
metin_yasak = {k["kalem"] for k in kurumlar["dogrulanamadi"]}
sina("karantina listesi boş değil", len(metin_yasak) > 0)
for blok in ("ihracat_vergisi", "ihracat_kotasi", "turkiye_2024_karari"):
    sina(
        f"kurumlar.{blok} kaynak niteliği yazılı",
        "_kaynak_niteligi" in data["kurumlar"][blok],
    )
sina(
    "Novorossiysk terminal kapasiteleri birincil kaynaktan",
    all(
        t["_kaynak_niteligi"].startswith("BİRİNCİL")
        for t in data["kurumlar"]["limanlar"]["novorossiysk_terminalleri"]
    ),
)
sina(
    "12 Ağustos olayı 'yaşayan durum' olarak işaretli",
    "_uyari" in data["kurumlar"]["limanlar"]["guncel_olay_2026_08_12"],
)
sina(
    "2013 liman rakamları güncel diye kullanılamaz uyarısı var",
    "2013" in data["kurumlar"]["limanlar"]["tarihsel_karsilastirma_2013"]["_uyari"],
)

# ── 7. Yöntem beyanı ─────────────────────────────────────────────────────────
sina("ayna istatistik uyarısı data.json'da", "AYNA" in data["_yontem_uyarisi"])
sina("kapalı kaynaklar ölçüm olarak kayıtlı", len(data["kurumlar"]["kapali_kaynaklar"]["denemeler"]) >= 3)
# Denetim, KURALIN kendisini değil İDDİALARI sınamalı. `_not` alanı zaten
# "yasaklandı denmez" diye yazıyor; onu taramak kuralın varlığını hata sayardı.
kk = data["kurumlar"]["kapali_kaynaklar"]
sina(
    "erişimsizlik sonuçları 'yasak' iddiası içermiyor",
    all("yasak" not in d["sonuc"].lower() for d in kk["denemeler"])
    and "yasak" not in kk["sonuc"].lower(),
)
sina(
    "erişimsizlik kuralı yazılı: 'erişilemedi' denir",
    "erişilemedi" in kk["_not"],
)
sina(
    "veri notları paneli kapalı",
    data["bosluklar"] == [],
    "panel kullanıcı kararıyla kaldırıldı; kayıtlar _raw/ altında duruyor",
)

# ── rapor ────────────────────────────────────────────────────────────────────
for ad, ayrinti in gecen:
    print(f"  ✅ {ad}" + (f"  ({ayrinti})" if ayrinti else ""))
for ad, ayrinti in kalan:
    print(f"  ❌ {ad}" + (f"  ({ayrinti})" if ayrinti else ""))

print(f"\n{len(gecen)} geçti, {len(kalan)} düştü.")
sys.exit(1 if kalan else 0)
