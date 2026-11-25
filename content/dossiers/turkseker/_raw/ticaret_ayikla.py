#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Dış ticaret: kristal şeker ithalatı, NBŞ ithalat-ihracatı.
Kaynak: TÜRKŞEKER Şeker Sektör Raporu 2025, Tablo 36 (TÜİK/DTM)."""
import json, pathlib, re

KOK = pathlib.Path(__file__).parent
M = (KOK / "kaynak_dosyalari" / "sektor_raporu_2025.txt").read_text(encoding="utf-8")

# İçindekiler tuzağı: tablo adı belgede iki kez geçiyor (bkz. kurum_ayikla.py).
_d = M.rfind(".....")
k = M.find("Tablo 36: Yıllar İtibariyle İthalat", M.find("\n", _d) + 1)
if k < 0:
    raise SystemExit("✗ Tablo 36 bulunamadı")
blok = M[k:k + 700]

yillar = {}
for y, kristal, nbs_it, nbs_ih in re.findall(
        r"(20[12]\d)\s+([\d.]+)\*{0,2}\s+([\d.]+)\s+([\d.]+)\s*\n", blok):
    yillar[y] = {"kristal_seker_ithalat_ton": int(kristal.replace(".", "")),
                 "nbs_ithalat_ton": int(nbs_it.replace(".", "")),
                 "nbs_ihracat_ton": int(nbs_ih.replace(".", ""))}

d = {
    "_kaynak": "TÜRKŞEKER, Şeker Sektör Raporu 2025 — Tablo 36 (s. 58). Raporun kendi kaynağı: "
               "Şeker Dairesi Başkanlığı (DTM, TÜİK)",
    "_cekim": "2026-11-23",
    "_birim": "ton, takvim yılı",
    "yillar": yillar,
}

h = []
if len(yillar) != 10:
    h.append(f"10 yıl beklenirken {len(yillar)} yıl okundu: {sorted(yillar)}")
if "2016" not in yillar or "2025" not in yillar:
    h.append("seri 2016-2025 aralığını kapsamıyor")
if not h:
    zirve = max(yillar.items(), key=lambda t: t[1]["kristal_seker_ithalat_ton"])
    dip = min(yillar.items(), key=lambda t: t[1]["kristal_seker_ithalat_ton"])
    if zirve[0] != "2022":
        h.append(f"ithalat zirvesi 2022 değil: {zirve[0]}")
    d["ithalat_dalgasi"] = {
        "zirve_yil": zirve[0], "zirve_ton": zirve[1]["kristal_seker_ithalat_ton"],
        "onceki_yil": "2021", "onceki_ton": yillar["2021"]["kristal_seker_ithalat_ton"],
        "kat": round(zirve[1]["kristal_seker_ithalat_ton"]
                     / yillar["2021"]["kristal_seker_ithalat_ton"], 1),
        "dip_yil": dip[0], "dip_ton": dip[1]["kristal_seker_ithalat_ton"],
    }
    # NBŞ: kotası kesilen ürün dışarı dönüyor mu?
    d["nbs_disa_donuk"] = {
        "ihracat_ithalat_orani": {y: round(v["nbs_ihracat_ton"] / v["nbs_ithalat_ton"], 1)
                                  for y, v in sorted(yillar.items())},
        "_2018_ihracat": yillar["2018"]["nbs_ihracat_ton"],
        "_2021_ihracat": yillar["2021"]["nbs_ihracat_ton"],
        "_serh": ("NBŞ yurt içi kotası 2018/19'dan başlayarak kesildi ve aynı yıllarda NBŞ "
                  "ihracatı yükseldi. İki olgu ÖLÇÜLMÜŞTÜR; aralarındaki bağı bu belge "
                  "kurmuyor, yayına nedensellik olarak yazılamaz."),
    }
    if any(v["nbs_ihracat_ton"] <= v["nbs_ithalat_ton"] for v in yillar.values()):
        h.append("bir yılda NBŞ ihracatı ithalatını aşmıyor — 'dışa dönük' çıkarımı yanlış olur")
if h:
    raise SystemExit("✗ DOĞRULAMA DÜŞTÜ\n  " + "\n  ".join(h))

(KOK / "ticaret.json").write_text(json.dumps(d, ensure_ascii=False, indent=2), encoding="utf-8")

print("  yıl   kristal ithalat   NBŞ ithalat   NBŞ ihracat   oran")
for y, v in sorted(yillar.items()):
    o = v["nbs_ihracat_ton"] / v["nbs_ithalat_ton"]
    print(f"  {y}  {v['kristal_seker_ithalat_ton']:>13,}  {v['nbs_ithalat_ton']:>12,}"
          f"  {v['nbs_ihracat_ton']:>12,}   {o:>4.1f}×")
dd = d["ithalat_dalgasi"]
print(f"\n  ithalat zirvesi {dd['zirve_yil']}: {dd['zirve_ton']:,} ton "
      f"— bir önceki yılın {dd['kat']} katı")
print("\n  ✓ ticaret.json yazıldı")
