#!/usr/bin/env python3
"""FAOSTAT QCL → pancar.json — Türkiye'nin şeker pancarı, 1961-2024

BÖLGE TUZAĞI (Rusya dosyasında ölçüldü, Mısır'da tekrar yaşandı): FAOSTAT
Türkiye'yi ASYA dosyasına koyuyor. Dosya Mısır turunda zaten indirilmişti;
yeniden indirilmiyor, oradan okunuyor.

BİÇİM TUZAĞI: QCL BÖLGE dosyaları GENİŞ biçimde (Y1961, Y1961F, Y1961N...).
Normalize sanılırsa betik hata VERMEZ, sessizce boş döner.

BAYRAK SÜTUNU OKUNUYOR: Y<yıl>F hücrenin niteliğini söylüyor (E=tahmin,
I=atama, A=resmî). Tahmin edilmiş hücre ölçülmüş gibi yazılamaz.
"""
from __future__ import annotations
import csv, io, json, pathlib

KOK = pathlib.Path(__file__).parent
QCL = KOK.parent.parent / "misir" / "_raw" / "x" / "Production_Crops_Livestock_E_Asia.csv"
TURKIYE = "223"
ELEMAN = {"Production": "uretim", "Area harvested": "alan", "Yield": "verim"}

if not QCL.exists():
    raise SystemExit(f"✗ QCL Asya dosyası yok: {QCL}")

seri: dict[str, dict] = {}
birim: dict[str, str] = {}
with io.open(QCL, encoding="utf-8-sig", newline="") as f:
    oku = csv.DictReader(f)
    yillar = [a for a in oku.fieldnames if a.startswith("Y") and a[1:].isdigit()]
    if not yillar:
        raise SystemExit("✗ YIL SÜTUNU YOK — dosya normalize biçimde olabilir")
    for r in oku:
        if r.get("Area Code") != TURKIYE:
            continue
        if "Sugar beet" not in (r.get("Item") or ""):
            continue
        ad = ELEMAN.get((r.get("Element") or "").strip())
        if not ad:
            continue
        birim[ad] = r.get("Unit") or ""
        kayit, bayrak = {}, {}
        for y in yillar:
            v = r.get(y)
            if v in (None, ""):
                continue
            try:
                kayit[y[1:]] = float(v)
            except ValueError:
                continue
            bayrak[y[1:]] = (r.get(y + "F") or "").strip()
        seri[ad] = {"seri": kayit, "bayrak": bayrak}

if set(seri) != set(ELEMAN.values()):
    raise SystemExit(f"✗ eksik eleman: {set(ELEMAN.values()) - set(seri)}")

u = seri["uretim"]["seri"]
yil = sorted(u, key=int)
ilk, son = yil[0], yil[-1]
# Yüzüncü yılın iki ucu: ilk Türk şekeri 1926, serinin başı 1961.
zirve = max(u, key=lambda k: u[k])

cikti = {
    "_kaynak": "FAOSTAT QCL · Production_Crops_Livestock_E_Asia (Mısır turunda indirildi)",
    "_urun": "Sugar beet · şeker pancarı",
    "_alan_kodu": TURKIYE,
    "_cekim": "23 Kasım 2026",
    "_birim": birim,
    "_bayrak_notu": ("Y<yıl>F bayrağı hücrenin niteliğini söylüyor: A resmî, "
                     "E tahmin, I atama. Son yılın bayrağı ayrıca yazıldı."),
    "_seri_siniri": (f"FAOSTAT serisi {ilk}'de başlıyor; ilk Türk şekeri 1926'da "
                     f"üretildi. Yüzyılın ilk otuz beş yılı bu seride YOK ve "
                     f"başka kaynaktan gelmek zorunda."),
    "ilk_yil": int(ilk), "son_yil": int(son),
    "son_yil_bayragi": seri["uretim"]["bayrak"].get(son, ""),
    "zirve_yil": int(zirve), "zirve_uretim": u[zirve],
    "uretim": seri["uretim"]["seri"],
    "alan": seri["alan"]["seri"],
    "verim": seri["verim"]["seri"],
}
(KOK / "pancar.json").write_text(json.dumps(cikti, ensure_ascii=False, indent=1),
                                 encoding="utf-8")
print(f"Türkiye şeker pancarı · {ilk}-{son} ({len(u)} yıl)")
print(f"  {ilk}: {u[ilk]:>12,.0f} t   ·  alan {seri['alan']['seri'][ilk]:>10,.0f} ha")
print(f"  zirve {zirve}: {u[zirve]:>8,.0f} t")
print(f"  {son}: {u[son]:>12,.0f} t   ·  alan {seri['alan']['seri'][son]:>10,.0f} ha"
      f"  · bayrak {cikti['son_yil_bayragi'] or '—'}")
print(f"  verim {ilk} → {son}: {seri['verim']['seri'][ilk]:,.0f} → "
      f"{seri['verim']['seri'][son]:,.0f} {birim.get('verim','')}")
print("\n✓ pancar.json")
