#!/usr/bin/env python3
"""BDDK Aylık Bülten → sektörel kredi dağılımı (tarım satırı).

NEDEN GEREKLİ. Ziraat'in kendi faaliyet raporu "tarım kredileri bakiyesi 831
milyar TL" diyor ama bu rakamın BÜYÜKLÜĞÜ tek başına anlamsız: Türkiye'deki
toplam tarımsal kredinin ne kadarı olduğu bilinmeden ölçü kurulamaz.
Payda buradan geliyor.

KARŞILAŞTIRMA SINIRI — metne yazılacak. BDDK'nın "Tarım" sektör kodu ile
Ziraat'in kendi "tarım kredileri" tanımı BİREBİR AYNI OLMAYABİLİR. Oran bu
yüzden "yaklaşık" diye verilir, ondalıklı kesinlik iddia edilmez.

Uç nokta jqGrid'in kendi POST'u; sayfa JavaScript istiyor ama bu adres
düz JSON dönüyor. Birim: BİN TL.
"""
import json, urllib.request, urllib.parse, sys

UC = "https://www.bddk.org.tr/BultenAylik/tr/Home/BasitRaporGetir"
YILLAR = [2021, 2023, 2025]

def cek(yil, ay=12):
    veri = urllib.parse.urlencode({
        "tabloNo": 5,        # Sektörel Kredi Dağılımı
        "yil": yil, "ay": ay,
        "paraBirimi": "TL",
        "taraf": 10001,      # Sektör (bütün bankalar)
    }).encode()
    istek = urllib.request.Request(UC, data=veri, headers={
        "X-Requested-With": "XMLHttpRequest",
        "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
    })
    d = json.load(urllib.request.urlopen(istek, timeout=60))
    if not d.get("success"):
        raise SystemExit(f"{yil}: BDDK hata — {d.get('error')}")
    j = d["Json"]
    sutunlar = j["colNames"]
    satirlar = {}
    for r in j["data"]["rows"]:
        h = r["cell"]
        ad = str(h[2]).strip()
        satirlar[ad] = {sutunlar[i]: h[i] for i in range(4, len(h))}
    return {"donem": j.get("caption"), "birim": "bin TL", "satirlar": satirlar}

if __name__ == "__main__":
    cikti = {
        "_kaynak": "BDDK Aylık Bülten · Sektörel Kredi Dağılımı · Sektör (tüm bankalar)",
        "_adres": UC,
        "_birim": "bin TL",
        "_uyari": "BDDK'nın sektör tanımı ile bankanın kendi tarım kredisi "
                  "tanımı birebir örtüşmeyebilir; oran yaklaşık verilir.",
        "yillar": {},
    }
    for y in YILLAR:
        s = cek(y)
        cikti["yillar"][str(y)] = s
        t = s["satirlar"].get("Tarım", {})
        print(f"{y}/12  Tarım · toplam nakdi kredi: "
              f"{t.get('Toplam Nakdi Krediler', 0)/1e6:,.1f} milyar TL")
    json.dump(cikti, open("bddk_sektorel_kredi.json", "w"),
              ensure_ascii=False, indent=1)
    print("→ bddk_sektorel_kredi.json")
