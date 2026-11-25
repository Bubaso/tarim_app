#!/usr/bin/env python3
"""USDA PSD → seker.json — Türkiye'nin şeker dengesi ve dünyadaki yeri

PSD TUZAKLARI (Rusya ve Mısır dosyalarında ölçüldü):
  · SON İKİ YIL ÖLÇÜM DEĞİL — yürüyen ve gelecek pazarlama yılı da
    yayımlanıyor. `kesin_son_yil` ayrıca hesaplanıyor.
  · PAZARLAMA YILI takvim yılı değil.
  · Aynı ülke-yıl için birden çok 'Month' (revizyon) satırı gelebiliyor;
    en son revizyon alınıyor, satırlar TOPLANMIYOR.
  · PSD'de "World" satırı YOK; dünya toplamı ülkeler toplanarak bulunuyor
    ve AB küme satırıyla çift sayım riski ölçülüyor.

ÜLKE ADI: PSD Türkiye'yi 'Turkey' diye yazıyor, 'Türkiye' değil. İkisi de
aranıyor — ad bir gün güncellenirse betik sessizce boş dönmesin.
"""
from __future__ import annotations
import csv, io, json, pathlib
from collections import defaultdict

KOK = pathlib.Path(__file__).parent
CSV = KOK / "x" / "psd_sugar.csv"
TR = ("Turkey", "Türkiye")
ILGI = {"Production": "uretim", "Beet Sugar Production": "pancar_sekeri",
        "Cane Sugar Production": "kamis_sekeri", "Imports": "ithalat",
        "Exports": "ihracat", "Human Dom. Consumption": "tuketim",
        "Ending Stocks": "stok"}

ham = defaultdict(lambda: ("", None))
birim = {}
with io.open(CSV, encoding="utf-8-sig", newline="") as f:
    for r in csv.DictReader(f):
        nit = ILGI.get((r.get("Attribute_Description") or "").strip())
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
        if ay >= ham[k][0]:
            ham[k] = (ay, deg)
        birim[nit] = r.get("Unit_Description")

yillar = sorted({y for (_, y, _) in ham})
son, kesin = yillar[-1], yillar[-1] - 2
al = lambda u, y, n: ham.get((u, y, n), ("", None))[1]
def tr(y, n):
    for ad in TR:
        v = al(ad, y, n)
        if v is not None:
            return v
    return None

# Dünya sıralaması — PANCAR ŞEKERİ üretimi, kesin son yıl
AB_UYE = {"France", "Germany", "Poland", "Spain", "Netherlands", "Belgium",
          "Czechia", "Austria", "Denmark", "Sweden", "Italy", "Romania",
          "Hungary", "Lithuania", "Finland", "Croatia", "Slovakia", "Greece"}
hepsi = {u: al(u, kesin, "pancar_sekeri") for (u, y, n) in ham
         if n == "pancar_sekeri" and y == kesin}
hepsi = {u: v for u, v in hepsi.items() if v}
cakisan = sorted(set(hepsi) & AB_UYE)
if cakisan and "European Union" in hepsi:
    raise SystemExit("✗ ÇİFT SAYIM: AB kümesi ile üye satırları bir arada: "
                     + ", ".join(cakisan))
sirali = sorted(hepsi.items(), key=lambda z: -z[1])
sira = next((i + 1 for i, (u, _) in enumerate(sirali) if u in TR), None)

cikti = {
    "_kaynak": "USDA FAS PSD · psd_sugar toplu CSV",
    "_urun": "Sugar, Centrifugal",
    "_cekim": "23 Kasım 2026",
    "_birim": birim,
    "_pazarlama_yili_notu": "PSD pazarlama yılı; takvim yılı serileriyle oran kurulamaz.",
    "_son_yil_ham": son, "kesin_son_yil": kesin,
    "_kesin_notu": f"PSD {son} ve {son-1} tahmin/öngörü; karşılaştırma {kesin}'ten.",
    "_dunya_notu": ("PSD'de World satırı yok; toplam ülkelerin toplamı. AB küme "
                    "satırı ile üye satırlarının çakışması ölçüldü ve yok."),
    "turkiye": {n: tr(kesin, n) for n in ILGI.values()},
    "dunya_pancar_sekeri": sum(hepsi.values()),
    "turkiye_pancar_sirasi": sira,
    "pancar_ilk_10": [{"ulke": u, "bin_ton": v} for u, v in sirali[:10]],
    "turkiye_uretim_serisi": {str(y): tr(y, "uretim") for y in yillar
                              if tr(y, "uretim") is not None and y <= kesin},
    "turkiye_tuketim_serisi": {str(y): tr(y, "tuketim") for y in yillar
                               if tr(y, "tuketim") is not None and y <= kesin},
}
(KOK / "seker.json").write_text(json.dumps(cikti, ensure_ascii=False, indent=1),
                                encoding="utf-8")
t = cikti["turkiye"]
print(f"PSD son ham yıl {son} · KESİN {kesin}")
print(f"\nTürkiye şekeri, {kesin} pazarlama yılı ({birim.get('uretim','')})")
for k, v in t.items():
    print(f"  {k:14} {'—' if v is None else f'{v:,.0f}'}")
print(f"\nDünya pancar şekeri {cikti['dunya_pancar_sekeri']:,.0f} · "
      f"Türkiye SIRA {sira}")
print("\nPancar şekerinde ilk 6:")
for i, x in enumerate(cikti["pancar_ilk_10"][:6], 1):
    print(f"  {i}. {x['ulke']:20} {x['bin_ton']:>9,.0f}")
s = cikti["turkiye_uretim_serisi"]
y0 = min(s, key=int)
print(f"\nÜretim serisi {y0} → {kesin}: {s[y0]:,.0f} → {s[str(kesin)]:,.0f}")
print("\n✓ seker.json")
