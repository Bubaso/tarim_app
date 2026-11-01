#!/usr/bin/env python3
"""DSİ — `_raw/cikarim.json` → `data.json`. Veri sayfası burada KİLİTLENİR.

EKSEN: kurum kuraklıktan doğdu, ülkenin su altyapısını kurdu, kurduğunun
işletmesini elli dört yılda devretti, ve 2018'de kendi kuruluş metni de
kanundan kararnameye devredildi.

DÖRT DOĞRULAMA — biri bile tutmazsa üretim DURUR:
  1. Her blok `_kapsam` taşıyor (§2.2 — kapsamsız rakam karşılaştırılamaz)
  2. Devir tablosunun İKİ toplamı da satırlardan yeniden hesaplanıyor
  3. Kronoloji artan
  4. Kapsamı DAR olan seri, kapsamı GENİŞ olanla aynı birimde sunulmuyor

Çalıştırma: ~/tarim_ai_pipeline/venv/bin/python build_data.py
"""
from __future__ import annotations

import json
import pathlib
import sys

KOK = pathlib.Path(__file__).parent
ham = json.loads((KOK / "_raw" / "cikarim.json").read_text(encoding="utf-8"))
hata: list[str] = []

govde = {k: v for k, v in ham.items() if not k.startswith("_")}

# ── 1. Kapsam zorunlu ─────────────────────────────────────────────────────
for ad, blok in govde.items():
    if not isinstance(blok, dict) or not blok.get("_kapsam"):
        hata.append(f"KAPSAM YOK · '{ad}'")
    if not blok.get("_kaynak_niteligi"):
        hata.append(f"KAYNAK NİTELİĞİ YOK · '{ad}'")

# ── 2. Devir tablosu — iki toplam da yeniden hesaplanıyor ─────────────────
d = govde["devir_dagilimi"]
adet = sum(s["adet"] for s in d["satirlar"])
alan = sum(s["alan_ha"] for s in d["satirlar"])
if adet != d["toplam_adet"]:
    hata.append(f"DEVİR ADET TUTMUYOR · satırlar {adet} ≠ toplam {d['toplam_adet']}")
if alan != d["toplam_alan_ha"]:
    hata.append(f"DEVİR ALAN TUTMUYOR · satırlar {alan:,} ≠ toplam {d['toplam_alan_ha']:,}")
# Yüzdeler de satırdan hesaplanıyor: raporun yazdığıyla karşılaştırılıyor.
for s in d["satirlar"]:
    hesap = round(s["alan_ha"] / alan * 100, 1)
    if abs(hesap - s["alan_yuzde"]) > 0.15:
        hata.append(f"DEVİR YÜZDE · {s['devralan']}: hesap {hesap} ≠ rapor {s['alan_yuzde']}")
d["_toplam_dogrulandi"] = "adet ve alan satırlardan yeniden hesaplandı; yüzdeler de"

# ── 3. Kronoloji ──────────────────────────────────────────────────────────
kron = [
    ("ilk_orgutlenme", 1914), ("sular_fen_heyeti", 1925),
    ("sular_umum_mudurlugu", 1929), ("dsi_kurulus", 1953),
    ("teskilatlanma", 1954), ("ilk_devir", govde["devir_serisi"]["kayitlar"][0]["yil"]),
    ("sulama_birlikleri_kanunu", 2011), ("maddelerin_mulgasi", 2018),
]
yillar = [y for _, y in kron]
if yillar != sorted(yillar):
    hata.append(f"KRONOLOJİ SIRASIZ · {yillar}")

# ── 4. Kapsam ayrımı korunuyor ────────────────────────────────────────────
ds = govde["devir_serisi"]
if "YERALTISUYU" not in ds["_kapsam"].upper():
    hata.append("devir_serisi kapsamı YAS olduğunu söylemiyor")
son_seri = ds["kayitlar"][-1]["alan_ha"]
if son_seri >= d["toplam_alan_ha"]:
    hata.append(f"KAPSAM ÇELİŞKİSİ · YAS serisi ({son_seri:,}) bütün tesislerden "
                f"({d['toplam_alan_ha']:,}) büyük olamaz")
# 1999 ünite değeri düşürülmüş olmalı
bin999 = next((k for k in ds["kayitlar"] if k["yil"] == 1999), None)
if bin999 and bin999["unite"] is not None:
    hata.append("1999 ünite değeri hâlâ dolu — kaynak hatası düşürülmeliydi")

# ── Türetilmiş ────────────────────────────────────────────────────────────
ilk, son = ds["kayitlar"][0], ds["kayitlar"][-1]
govde["turetilmis"] = {
    "_kaynak_niteligi": "TÜRETİLMİŞ — yukarıdaki blokların hesabı",
    "_kapsam": "Türetilmiş; her satırın kapsamı kendi kaynağınınkidir",
    "devir_suresi_yil": son["yil"] - ilk["yil"],
    "_devir_suresi_kapsam": "YAS tesisleri · ilk kat'i devir → son kayıt",
    "birlik_alan_payi_yuzde": next(
        s["alan_yuzde"] for s in d["satirlar"] if s["devralan"] == "Sulama Birliği"),
    "birlik_adet_payi_yuzde": next(
        s["adet_yuzde"] for s in d["satirlar"] if s["devralan"] == "Sulama Birliği"),
    "kooperatif_alan_payi_yuzde": next(
        s["alan_yuzde"] for s in d["satirlar"] if s["devralan"] == "Kooperatif"),
    "kooperatif_adet_payi_yuzde": next(
        s["adet_yuzde"] for s in d["satirlar"] if s["devralan"] == "Kooperatif"),
    "devredilen_milyon_ha": round(d["toplam_alan_ha"] / 1e6, 3),
    "hedefe_oran_yuzde": round(
        d["toplam_alan_ha"] / (govde["olcek"]["hedef_2028_brut_milyon_ha"] * 1e6) * 100, 1),
    "_hedefe_oran_uyarisi": ("Payda 2028 HEDEFİ, gerçekleşen alan değil. 'Devredilen "
                            "alan açılanın şu kadarı' DENMEZ — gerçekleşen kümülatif "
                            "alan hiçbir kaynakta bulunamadı (README tur 3/3)."),
    "kronoloji": dict(kron),
}

if hata:
    print("ÜRETİM DURDU:\n", file=sys.stderr)
    for h in hata:
        print("  ✗ " + h, file=sys.stderr)
    sys.exit(1)

out = {
    "_dosya": "DSİ — Kurum Dosyası Sayı 05 · veri katmanı",
    "_uretim": "build_data.py — elle düzenlenmez",
    "_eksen": ("Kuraklıktan doğan kurum ülkenin su altyapısını kurdu ve kurduğunun "
               f"işletmesini {govde['turetilmis']['devir_suresi_yil']} yılda "
               "başkalarına devretti; 2018'de kendi kuruluş metni de kanundan "
               "kararnameye devredildi."),
    "_eksen_notu": ("Süre SABİT YAZILMIYOR, turetilmis.devir_suresi_yil'den "
                    "kuruluyor. İlk taslakta 'elli dört yıl' yazmıştım; seri 54 "
                    "KAYIT taşıyor ama 1967-2020 arası 53 YIL. Metinle veri "
                    "ayrışmasın diye sayı tek yerden geliyor."),
    "_eksenin_siniri": ("'Yapıyor ama işletmiyor' DENMİYOR. DSİ'nin kendi işlettiği "
                        "ulusal alan hiçbir kaynakta tek rakam olarak yok; iddia "
                        "devrin ÖLÇEĞİ ve SÜRESİ ile sınırlı."),
    **govde,
}
(KOK / "data.json").write_text(
    json.dumps(out, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
t = govde["turetilmis"]
print(f"✓ data.json · {len(govde)} blok")
print(f"  devir {d['toplam_adet']} tesis · {t['devredilen_milyon_ha']} milyon ha · "
      f"birlikler alanın %{t['birlik_alan_payi_yuzde']}'i ama tesislerin "
      f"%{t['birlik_adet_payi_yuzde']}'u")
print(f"  devir süresi {t['devir_suresi_yil']} yıl (YAS serisi)")
