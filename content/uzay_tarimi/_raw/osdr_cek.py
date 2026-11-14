#!/usr/bin/env python3
"""NASA OSDR/GeneLab → osdr.json — uzay bitki çalışmalarının kilitli listesi.

KAYNAK: osdr.nasa.gov/osdr/data/search · anahtarsız REST, JSON.

TUZAK — ÖLÇÜLDÜ. `type=cgene` SÜZGECİ ŞART. Onsuz "Arabidopsis" sorgusu
4.760 sonuç veriyor; bunlar çalışma değil ÖRNEK ve DOSYA kayıtları. Kürate
çalışma sayısı için süzgeç zorunlu: "plant" → 78.

İKİNCİ TUZAK: bazı alanlar bazen sayı, bazen dizge dönüyor (yayım tarihi
float gelebiliyor). Her alan str() ile sarmalanıyor; ilk yazımda
`'float' object is not subscriptable` ile düştü.
"""
from __future__ import annotations
import json, pathlib, urllib.parse, urllib.request, collections, datetime

KOK = pathlib.Path(__file__).parent
UA = {"User-Agent": "tarimportali.net arastirma"}
TABAN = "https://osdr.nasa.gov/osdr/data/search"

# Ürün cinsi → Türkçe ad. Arabidopsis MODEL ORGANİZMA, ekin değil; ayrı
# tutuluyor çünkü dosyanın en önemli ölçümü ikisinin ORANI.
EKIN = {"Lactuca": "marul", "Solanum": "domates/patates", "Triticum": "buğday",
        "Brassica": "lahanagiller", "Oryza": "pirinç", "Glycine": "soya",
        "Capsicum": "biber", "Raphanus": "turp", "Pisum": "bezelye",
        "Zea": "tane mısır", "Gossypium": "pamuk", "Lolium": "çim",
        "Brachypodium": "yalancı brom", "Hordeum": "arpa"}


def ara(terim: str, size: int = 100, tip: str = "cgene") -> dict:
    u = f"{TABAN}?term={urllib.parse.quote(terim)}&size={size}&type={tip}"
    with urllib.request.urlopen(urllib.request.Request(u, headers=UA), timeout=90) as r:
        return json.load(r)


def al(s: dict, alan: str) -> str:
    v = s.get(alan)
    return "" if v is None else str(v)


ham = ara("plant")
toplam = ham["hits"]["total"]
kayitlar = ham["hits"]["hits"]
if len(kayitlar) < toplam:
    raise SystemExit(f"✗ {toplam} kayıttan {len(kayitlar)}'i geldi — size artırılmalı")

calismalar, cins = [], collections.Counter()
for x in kayitlar:
    s = x["_source"]
    org = al(s, "organism")
    ilk = org.split()[0] if org.strip() else "?"
    cins[ilk] += 1
    k = {
        "erisim": al(s, "Accession"),
        "baslik": al(s, "Study Title"),
        "organizma": org,
        "cins": ilk,
        "olcum": al(s, "Study Assay Measurement Type"),
        "teknoloji": al(s, "Study Assay Technology Type"),
        "platform": al(s, "Experiment Platform"),
        "gorev": (s.get("Mission") or {}).get("Name", "") if isinstance(s.get("Mission"), dict) else "",
        "merkez": al(s, "Managing NASA Center"),
        "program": al(s, "Space Program"),
        "fon": al(s, "Study Funding Agency"),
        "etmen": al(s, "Study Factor Name"),
        "kaynak_yolu": al(s, "Authoritative Source URL"),
    }
    for c, ad in EKIN.items():
        if c in org:
            k["ekin"] = ad
            break
    calismalar.append(k)

calismalar.sort(key=lambda k: k["erisim"])
ekinler = [k for k in calismalar if "ekin" in k]
model = [k for k in calismalar if k["cins"] == "Arabidopsis"]

cikti = {
    "_kaynak": "NASA Open Science Data Repository (OSDR/GeneLab)",
    "_uc_nokta": f"{TABAN}?term=plant&size=100&type=cgene",
    "_nitelik": "BAĞIMSIZ — NASA'nın kendi kürate veri deposu",
    "_cekim": datetime.date.today().isoformat(),
    "_suzgec_notu": ("`type=cgene` ŞART. Onsuz 'Arabidopsis' sorgusu 4.760 "
                     "sonuç veriyor; bunlar çalışma değil örnek ve dosya "
                     "kayıtları."),
    "_sorgu_notu": ("Sorgu terimi 'plant'. Bu bir METİN eşleşmesi: bir "
                    "çalışma başlığında ya da tarifinde 'plant' geçtiği için "
                    "listeye giriyor. Yani sayı bitki çalışmalarının TAMAMI "
                    "değil, 'plant' diyen kürate çalışmalar. Daha geniş bir "
                    "liste için organizma bazlı ayrı sorgular gerekir."),
    "toplam": toplam,
    "cins_dagilimi": dict(cins.most_common()),
    "ekin_sayisi": len(ekinler),
    "model_organizma_sayisi": len(model),
    "_oran_notu": (f"{len(model)} çalışma Arabidopsis (MODEL ORGANİZMA), "
                   f"{len(ekinler)} çalışma gerçek ekin bitkisi. Dosyanın en "
                   f"önemli ölçümlerinden biri bu oran: uzay bitki bilimi "
                   f"ezici biçimde model organizma üzerinden yürüyor."),
    "ekin_calismalari": ekinler,
    "calismalar": calismalar,
}
(KOK / "osdr.json").write_text(json.dumps(cikti, ensure_ascii=False, indent=1) + "\n",
                               encoding="utf-8")
print(f"✓ osdr.json · {toplam} kürate çalışma")
print(f"  Arabidopsis (model) {len(model)} · gerçek ekin {len(ekinler)}")
for k in ekinler:
    print(f"    {k['erisim']:9s} {k['ekin']:16s} {k['baslik'][:60]}")
