#!/usr/bin/env python3
"""USDA PSD → bugday.json — Mısır'ın buğday ithalatı ve dünyadaki yeri

PSD TUZAKLARI (Rusya dosyasında ölçüldü, burada da geçerli):
  · SON İKİ YIL ÖLÇÜM DEĞİL. PSD yürüyen ve gelecek pazarlama yılını da
    yayımlıyor. Son kesin yıl ayrıca hesaplanıyor (kesin_son_yil) ve
    karşılaştırma cümlesi ondan kurulur.
  · PAZARLAMA YILI TAKVİM YILI DEĞİL. Buğdayda Mısır için Temmuz-Haziran.
    Comtrade/Dünya Bankası takvim yılı serileriyle aynı cümlede oran
    olarak kullanılamaz.
  · Aynı ülke-yıl için birden çok 'Month' (revizyon) satırı gelebiliyor;
    en son revizyon alınıyor, satırlar TOPLANMIYOR.

ÖTEKİ TANELER (tur 7'de eklendi): dosyanın §9'u "mısırda da ithalat üretimin
üstünde" diyecek ve §8 pirincin tersini söyleyecek. İki rakam tur 3'te
ölçülmüştü ama VERİ SAYFASINA GİRMEMİŞTİ — grafik turunda açığa çıktı. Şimdi
burada üretiliyor.

ADLANDIRMA TUZAĞI: tane mısır ile ülke Mısır Türkçede aynı kelime. Çıktıdaki
anahtar `tane_misir`, ülke ise her yerde `misir`. Karıştırılırsa hata vermez,
SESSİZCE yanlış rakam yazar — bu projenin kayıtlı tuzağının bu dosyadaki
hâli.

YEMLİK NİTELİĞİNİN ADI: 'Feed Dom. Consumption'. 'Feed and Residual Use'
DEĞİL — o ad PSD'de yok ve yazılırsa alan sessizce boş döner (ilk yazımda
öyle oldu).
"""
from __future__ import annotations
import csv, io, json, pathlib
from collections import defaultdict

KOK = pathlib.Path(__file__).parent
CSV = KOK / "x" / "psd_grains_pulses.csv"
URUN = "Wheat"
ILGI = {"Imports": "ithalat", "Production": "uretim",
        "Domestic Consumption": "tuketim", "Exports": "ihracat",
        "Area Harvested": "hasat_alani"}

# Öteki taneler. Anahtar PSD'nin kendi ürün adı, değer çıktıdaki ad.
OTEKI = {"Corn": "tane_misir", "Rice, Milled": "pirinc"}
OTEKI_ILGI = dict(ILGI, **{"Feed Dom. Consumption": "yemlik"})

def oteki_taneler(kesin: int) -> dict:
    """Tane mısır ve pirinç — Mısır ve Türkiye, KESİN son yıl.

    Buğdayla aynı CSV, ayrı tarama. Tek taramada toplansaydı ILGI sözlüğü
    iki ürün için ortak olurdu ve yemlik niteliği buğdaya da yazılırdı;
    buğdayda yemlik PSD'de var ama dosyanın hiçbir cümlesi onu kullanmıyor,
    okunmayan alan yazılmaz.
    """
    ham = defaultdict(lambda: ("", None))
    with io.open(CSV, encoding="utf-8-sig", newline="") as f:
        for r in csv.DictReader(f):
            urun = OTEKI.get(r.get("Commodity_Description", "").strip())
            if not urun:
                continue
            nit = OTEKI_ILGI.get(r.get("Attribute_Description", "").strip())
            if not nit:
                continue
            v = r.get("Value")
            if v in (None, "", "NA"):
                continue
            try:
                yil = int(r["Market_Year"]); deg = float(v)
            except ValueError:
                continue
            ay = r.get("Month", "")
            k = (urun, r["Country_Name"].strip(), yil, nit)
            if ay >= ham[k][0]:
                ham[k] = (ay, deg)

    def al(urun, ulke, nit):
        v = ham.get((urun, ulke, kesin, nit), ("", None))[1]
        if v is None and ulke == "Turkey":
            v = ham.get((urun, "Türkiye", kesin, nit), ("", None))[1]
        return v

    cikti = {"_yil": kesin,
             "_ad_notu": ("'tane_misir' TANE MISIR (Corn). Ülke Mısır her yerde "
                          "'misir'. İki kelime Türkçede aynı; karıştırılırsa "
                          "betik hata vermez, sessizce yanlış rakam yazar.")}
    for urun in OTEKI.values():
        blok = {}
        for ulke, ad in (("Egypt", "misir"), ("Turkey", "turkiye")):
            blok[ad] = {n: al(urun, ulke, n) for n in OTEKI_ILGI.values()}
        # Boş gelen ülke SESSİZCE geçmiyor: PSD'de ürün adı değişirse
        # (örneğin 'Rice, Milled' → 'Rice') bütün blok None dolar.
        for ad, d in blok.items():
            if all(v is None for v in d.values()):
                raise SystemExit(f"✗ {urun}/{ad}: {kesin} yılında hiç satır yok "
                                 f"— PSD ürün ya da nitelik adı değişmiş olabilir")
        cikti[urun] = blok
    return cikti


def main():
    # (ülke, yıl, nitelik) → (en son ay, değer)
    ham = defaultdict(lambda: ("", None))
    birim = {}
    with io.open(CSV, encoding="utf-8-sig", newline="") as f:
        for r in csv.DictReader(f):
            if r.get("Commodity_Description", "").strip() != URUN:
                continue
            nit = ILGI.get(r.get("Attribute_Description", "").strip())
            if not nit:
                continue
            v = r.get("Value")
            if v in (None, "", "NA"):
                continue
            try:
                yil = int(r["Market_Year"]); deg = float(v)
            except ValueError:
                continue
            ay = r.get("Month", "")
            k = (r["Country_Name"].strip(), yil, nit)
            if ay >= ham[k][0]:            # en SON revizyon
                ham[k] = (ay, deg)
            birim[nit] = r.get("Unit_Description")

    yillar = sorted({y for (_, y, _) in ham})
    son = yillar[-1]
    kesin = son - 2                        # son iki yıl tahmin/öngörü

    def al(ulke, yil, nit):
        return ham.get((ulke, yil, nit), ("", None))[1]

    # Dünya sıralaması — ithalat, kesin son yıl.
    #
    # PSD'DE "World" SATIRI YOK: dünya toplamı ülkeleri toplayarak bulunuyor.
    # Bu doğrudan çift sayım riski (§2.2.1) — ölçüldü: "European Union" bir
    # KÜME satırı ve PSD'de hiçbir AB üyesinin ayrı satırı YOK. Yani küme ile
    # üyeler aynı toplamda buluşmuyor, toplama güvenli. Üye satırları bir gün
    # eklenirse aşağıdaki kontrol hata verir.
    AB_UYE = {"France", "Germany", "Poland", "Romania", "Spain", "Italy",
              "Bulgaria", "Hungary", "Czechia", "Czech Republic", "Lithuania",
              "Latvia", "Denmark", "Sweden", "Finland", "Austria", "Netherlands",
              "Belgium", "Greece", "Slovakia", "Croatia", "Ireland", "Portugal",
              "Estonia", "Slovenia", "Luxembourg", "Cyprus", "Malta"}
    hepsi = {u: al(u, kesin, "ithalat") for (u, y, n) in ham
             if n == "ithalat" and y == kesin}
    hepsi = {u: v for u, v in hepsi.items() if v}
    cakisan = sorted(set(hepsi) & AB_UYE)
    if cakisan and "European Union" in hepsi:
        raise SystemExit("✗ ÇİFT SAYIM: AB kümesi ile üye satırları bir arada: "
                         + ", ".join(cakisan))
    ith = sorted(hepsi.items(), key=lambda z: -z[1])
    sira = next((i + 1 for i, (u, _) in enumerate(ith) if u == "Egypt"), None)
    dunya = sum(hepsi.values())

    cikti = {
        "_kaynak": "USDA FAS PSD · psd_grains_pulses toplu CSV",
        "_urun": URUN, "_cekim": "12 Kasım 2026",
        "_birim": birim,
        "_pazarlama_yili_notu": ("PSD pazarlama yılı. Mısır'da buğday Temmuz-Haziran; "
                                 "takvim yılı serileriyle oran kurulamaz."),
        "_son_yil_ham": son,
        "kesin_son_yil": kesin,
        "_kesin_notu": f"PSD {son} ve {son-1} tahmin/öngörü; karşılaştırma {kesin}'ten kuruluyor.",
        "misir": {n: al("Egypt", kesin, n) for n in ILGI.values()},
        "turkiye": {n: al("Turkey", kesin, n) or al("Türkiye", kesin, n) for n in ILGI.values()},
        "dunya_ithalat": dunya,
        "_dunya_notu": ("PSD'de World satırı yok; toplam ülkelerin toplamı. "
                        "AB küme satırı var, üye satırı YOK — çift sayım ölçüldü ve yok."),
        "turkiye_dunya_sirasi": next((i + 1 for i, (u, _) in enumerate(ith)
                                      if u in ("Turkey", "Türkiye")), None),
        "misir_dunya_sirasi": sira,
        "ithalat_ilk_10": [{"ulke": u, "bin_ton": v} for u, v in ith[:10]],
        "misir_ithalat_serisi": {str(y): al("Egypt", y, "ithalat")
                                 for y in yillar if al("Egypt", y, "ithalat") is not None},
        "misir_uretim_serisi": {str(y): al("Egypt", y, "uretim")
                                for y in yillar if al("Egypt", y, "uretim") is not None},
        "oteki_taneler": oteki_taneler(kesin),
    }
    (KOK / "bugday.json").write_text(json.dumps(cikti, ensure_ascii=False, indent=1), encoding="utf-8")

    m = cikti["misir"]
    print(f"PSD son ham yıl {son} · KESİN son yıl {kesin} (son iki yıl tahmin)")
    print(f"\nMısır buğdayı, {kesin} pazarlama yılı (bin ton)")
    for k, v in m.items():
        print(f"  {k:14} {'—' if v is None else f'{v:,.0f}'}")
    if m["ithalat"] and m["tuketim"]:
        print(f"  → tüketimin %{100*m['ithalat']/m['tuketim']:.0f}'i ithal")
    print(f"\nDünya buğday ithalatı {dunya:,.0f} bin ton · Mısır'ın payı "
          f"%{100*m['ithalat']/dunya:.1f} · SIRA {sira}")
    print("\nİlk 6 ithalatçı:")
    for i, x in enumerate(cikti["ithalat_ilk_10"][:6], 1):
        print(f"  {i}. {x['ulke']:22} {x['bin_ton']:>10,.0f}")
    print("\n✓ bugday.json")

if __name__ == "__main__":
    main()
