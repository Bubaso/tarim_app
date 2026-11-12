#!/usr/bin/env python3
"""FAOSTAT QCL → uretim.json — Mısır ve Türkiye'nin rakip ürünleri

BÖLGE TUZAĞI (Rusya dosyasında ölçüldü): FAOSTAT Türkiye'yi ASYA, Mısır'ı
AFRİKA dosyasına koyuyor. Tek bölge okunursa karşılaştırmanın yarısı
SESSİZCE boş gelir — hata vermez, satır bulunmaz. İkisi birden okunuyor.

BİÇİM TUZAĞI — BU DOSYADA YAKALANDI. QCL BÖLGE dosyaları GENİŞ biçimde:
yıllar ayrı sütun (Y1961, Y1961F, Y1961N, Y1962...). Arazi kullanımı dosyası
ise NORMALİZE (Year/Value sütunlu). İkisi aynı sanılırsa betik hata VERMEZ,
sessizce boş döner — ilk yazımda tam olarak öyle oldu, on iki ürünün hepsi
"—" çıktı. Rusya günlüğündeki "sessizce boş gelir" uyarısının aynısı.

BAYRAK SÜTUNU OKUNUYOR: Y<yıl>F alanı hücrenin niteliğini söylüyor
(E=tahmin, I=atama, A=resmî...). Tahmin edilmiş bir hücre ölçülmüş gibi
yazılamaz; bayrak seriyle birlikte taşınıyor.

CSV TUZAĞI: FAOSTAT'ta her alan tırnaklı. csv modülü çözüyor, elle
ayrıştırılmıyor.

PAMUK AYRI DURUYOR: Mısır pamuğu dosyanın "terk edilen ürün" adayı (§2.8/5).
Lif ve çiğit ayrı kalem; toplanmıyorlar.
"""
from __future__ import annotations
import csv, io, json, pathlib
from collections import defaultdict

KOK = pathlib.Path(__file__).parent
DOSYA = {"misir": KOK/"x"/"Production_Crops_Livestock_E_Africa.csv",
         "turkiye": KOK/"x"/"Production_Crops_Livestock_E_Asia.csv"}
ALAN = {"misir": 59, "turkiye": 223}
URUN = {1804:"narenciye_toplam", 490:"portakal", 495:"mandalina", 497:"limon",
        116:"patates", 403:"kuru_sogan", 388:"domates", 27:"pirinc",
        328:"cigit_pamuk", 767:"pamuk_lifi", 156:"seker_kamisi", 15:"bugday"}
ELEMAN = {"Production":"uretim", "Area harvested":"alan", "Yield":"verim"}

def main():
    veri = {u: defaultdict(lambda: defaultdict(dict)) for u in DOSYA}
    bayrak = {u: defaultdict(lambda: defaultdict(dict)) for u in DOSYA}
    birim = {}
    for u, yol in DOSYA.items():
        with io.open(yol, encoding="utf-8-sig", newline="") as f:
            oku = csv.DictReader(f)
            yillar = [a for a in oku.fieldnames
                      if a.startswith("Y") and a[1:].isdigit()]
            if not yillar:
                raise SystemExit(f"✗ {yol.name}: yıl sütunu yok — biçim değişmiş")
            for r in oku:
                try:
                    ak = int(r["Area Code"]); ik = int(r["Item Code"])
                except (ValueError, TypeError, KeyError):
                    continue
                if ak != ALAN[u] or ik not in URUN:
                    continue
                el = ELEMAN.get((r.get("Element") or "").strip())
                if not el:
                    continue
                for ys in yillar:
                    v = r.get(ys)
                    if v in (None, "", "NA"):
                        continue                 # boş hücre sıfır değil
                    try:
                        deg = float(v)
                    except ValueError:
                        continue
                    yil = int(ys[1:])
                    veri[u][URUN[ik]][el][yil] = deg
                    f_ = (r.get(ys + "F") or "").strip()
                    if f_:
                        bayrak[u][URUN[ik]][el][yil] = f_
                birim[(URUN[ik], el)] = r.get("Unit")

    cikti = {"_kaynak": "FAOSTAT · Production/Crops and livestock products · toplu CSV",
             "_cekim": "12 Kasım 2026",
             "_bolge_notu": "Mısır Afrika, Türkiye Asya dosyasından; ikisi birden okundu.",
             "_bicim_notu": "QCL bölge dosyaları GENİŞ biçimde (Y<yıl> sütunları).",
             "_bayrak_notu": "F sütunu: E=tahmin, I=atama, A=resmî. Tahmin ölçüm gibi yazılmaz.",
             "_birim": {f"{a}|{b}": c for (a, b), c in birim.items()}}
    for u in DOSYA:
        cikti[u] = {}
        for urun, el in veri[u].items():
            cikti[u][urun] = {}
            for e, s_ in el.items():
                if not s_:
                    continue
                y = max(s_)
                cikti[u][urun][e] = {
                    "son_yil": y, "deger": s_[y],
                    "son_yil_bayrak": bayrak[u][urun][e].get(y),
                    "seri": {str(a): s_[a] for a in sorted(s_)},
                    "bayrak": {str(a): b for a, b in sorted(bayrak[u][urun][e].items())}}
    # ortak son yıl
    cikti["_ortak_son_yil"]={}
    for urun in URUN.values():
        a=cikti["misir"].get(urun,{}).get("uretim"); b=cikti["turkiye"].get(urun,{}).get("uretim")
        if a and b:
            o=sorted(set(a["seri"])&set(b["seri"]))
            cikti["_ortak_son_yil"][urun]=int(o[-1]) if o else None
    (KOK/"uretim.json").write_text(json.dumps(cikti,ensure_ascii=False,indent=1),encoding="utf-8")

    oy=cikti["_ortak_son_yil"]
    print(f"{'ürün':18} {'yıl':>5} {'MISIR (t)':>16} {'TÜRKİYE (t)':>16}  oran")
    print("─"*70)
    for urun in URUN.values():
        y=oy.get(urun)
        if not y: 
            print(f"{urun:18} {'—':>5}")
            continue
        m=cikti["misir"][urun]["uretim"]["seri"].get(str(y))
        t=cikti["turkiye"][urun]["uretim"]["seri"].get(str(y))
        o=f"{m/t:.2f}×" if (m and t) else "—"
        print(f"{urun:18} {y:>5} {m:>16,.0f} {t:>16,.0f}  {o}")
    print("\n✓ uretim.json")

if __name__ == "__main__":
    main()
