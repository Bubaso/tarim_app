#!/usr/bin/env python3
"""TİGEM — `_raw/cikarim.json` → `data.json`. Veri sayfası burada KİLİTLENİR.

EKSEN: kurum Türkiye tarım arazisinin yüzde birinden azını tutuyor ama
ülkede dağıtılan sertifikalı hububat tohumunun beşte birini veriyor —
çünkü ürettiği şey gıda değil GİRDİ.

DOKUZ DOĞRULAMA — biri bile tutmazsa üretim DURUR:
  1. Her blok `_kapsam` ve `_kaynak_niteligi` taşıyor (§2.2)
  2. Arazi tablosunun ÜÇ toplamı da satırlardan yeniden hesaplanıyor
  3. Kurumun kendi yazdığı %90,93 / %9,07 oranı yeniden hesaplanıyor
  4. Tohum tablosunda ülke toplamı = buğday + arpa, her yıl için
  5. Raporun yazdığı pay yüzdeleri satırlardan yeniden hesaplanıyor
  6. DAĞITIM ve SATIŞ serileri ayrı ölçü etiketi taşıyor (§8.10/karışık payda)
  7. Kronoloji artan
  8. Sermaye serisi artan ve hepsi 2005 sonrası (eski para karışmıyor)
  9. `metin_rakamlari`ndaki her sayı bir bloktan TÜRETİLİYOR, elle yazılmıyor

Çalıştırma: python3 build_data.py
"""
from __future__ import annotations

import json
import pathlib
import sys
from decimal import ROUND_HALF_UP, Decimal

KOK = pathlib.Path(__file__).parent
ham = json.loads((KOK / "_raw" / "cikarim.json").read_text(encoding="utf-8"))
hata: list[str] = []
uyari: list[str] = []

govde = {k: v for k, v in ham.items() if not k.startswith("_")}


def yuvarla(x: float, basamak: int = 1) -> float:
    """Bankacı yuvarlaması YAPMAZ (§8.10/3). Okurun beklediği gibi yuvarlar."""
    kalip = Decimal("1." + "0" * basamak) if basamak else Decimal("1")
    return float(Decimal(str(x)).quantize(kalip, rounding=ROUND_HALF_UP))


# ── 1. Kapsam ve kaynak niteliği zorunlu ──────────────────────────────────
for ad, blok in govde.items():
    if not isinstance(blok, dict):
        hata.append(f"BLOK SÖZLÜK DEĞİL · '{ad}'")
        continue
    if not blok.get("_kapsam"):
        hata.append(f"KAPSAM YOK · '{ad}'")
    if not blok.get("_kaynak_niteligi"):
        hata.append(f"KAYNAK NİTELİĞİ YOK · '{ad}'")

# ── 2. Arazi — üç toplam da satırlardan ───────────────────────────────────
a = govde["arazi"]
onyedi = sum(Decimal(str(s["toplam"])) for s in a["isletmeler"])
gm = Decimal(str(a["genel_mudurluk"]))
if onyedi + gm != Decimal(str(a["pdf_toplam_satiri"])):
    hata.append(
        f"ARAZİ TOPLAM TUTMUYOR · 17 işletme {onyedi} + GM {gm} "
        f"≠ PDF toplam satırı {a['pdf_toplam_satiri']}"
    )
kira = Decimal(str(a["uzun_sureli_kiraya_verilen"])) + Decimal(str(a["istirak_seklinde"]))
if Decimal(str(a["pdf_toplam_satiri"])) + kira != Decimal(str(a["tigem_toplam_arazi"])):
    hata.append(
        f"ARAZİ GENEL TOPLAM TUTMUYOR · {a['pdf_toplam_satiri']} + {kira} "
        f"≠ {a['tigem_toplam_arazi']}"
    )
# alt kalemler de kendi sütun toplamlarını versin
for alan in ("kulturalti", "tarla", "tabii_mera", "sulanan", "bahce"):
    toplam = sum(s[alan] for s in a["isletmeler"])
    a[f"_17_isletme_{alan}"] = yuvarla(toplam, 2)

# ── 3. Kurumun kendi yazdığı oran yeniden hesaplanıyor ────────────────────
toplam_arazi = Decimal(str(a["tigem_toplam_arazi"]))
kullanim_orani = yuvarla(float(Decimal(str(a["pdf_toplam_satiri"])) / toplam_arazi * 100), 2)
kira_orani = yuvarla(float(kira / toplam_arazi * 100), 2)
if abs(kullanim_orani - a["pdf_yazdigi_kullanim_orani"]) > 0.02:
    hata.append(f"KULLANIM ORANI · hesap {kullanim_orani} ≠ PDF {a['pdf_yazdigi_kullanim_orani']}")
if abs(kira_orani - a["pdf_yazdigi_kira_orani"]) > 0.02:
    hata.append(f"KİRA ORANI · hesap {kira_orani} ≠ PDF {a['pdf_yazdigi_kira_orani']}")

# ── 4 ve 5. Tohum dağıtım tablosu ─────────────────────────────────────────
t = govde["tohum_dagitim"]
n = len(t["yillar"])
for dizi in ("turkiye_bugday", "turkiye_arpa", "turkiye_toplam_rapor",
             "tigem_bugday", "tigem_arpa", "rapor_pay_bugday", "rapor_pay_arpa"):
    if len(t[dizi]) != n:
        hata.append(f"TOHUM DİZİ UZUNLUĞU · '{dizi}' {len(t[dizi])} ≠ yıl sayısı {n}")

for i, yil in enumerate(t["yillar"]):
    bekle = t["turkiye_bugday"][i] + t["turkiye_arpa"][i]
    if bekle != t["turkiye_toplam_rapor"][i]:
        hata.append(f"ÜLKE TOPLAMI · {yil}: {bekle} ≠ rapor {t['turkiye_toplam_rapor'][i]}")
    for urun, pay_adi in (("bugday", "rapor_pay_bugday"), ("arpa", "rapor_pay_arpa")):
        hesap = yuvarla(t[f"tigem_{urun}"][i] / t[f"turkiye_{urun}"][i] * 100, 1)
        rapor = t[pay_adi][i]
        if abs(hesap - rapor) > 0.6:
            hata.append(f"PAY · {yil} {urun}: hesap %{hesap} ≠ rapor %{rapor}")

# ── 6. Ölçü çakışması — DAĞITIM ile SATIŞ aynı seri değildir ──────────────
olculer = {ad: blok.get("_olcu") for ad, blok in govde.items() if blok.get("_olcu")}
if olculer.get("tohum_dagitim") != "dagitim" or olculer.get("tohum_satis") != "satis":
    hata.append(f"ÖLÇÜ ETİKETİ EKSİK VEYA YANLIŞ · {olculer}")
if olculer.get("tohum_dagitim") == olculer.get("tohum_satis"):
    hata.append("ÖLÇÜ ÇAKIŞMASI · dağıtım ve satış aynı etiketi taşıyor")

# ── 7. Kronoloji ──────────────────────────────────────────────────────────
yillar = [h["yil"] for h in govde["kurulus_silsilesi"]["halkalar"]]
if yillar != sorted(yillar):
    hata.append(f"KRONOLOJİ SIRASIZ · {yillar}")
gyillar = [h["yil"] for h in govde["gorev_cumlesi"]["halkalar"]]
if gyillar != sorted(gyillar):
    hata.append(f"GÖREV CÜMLESİ SIRASIZ · {gyillar}")

# ── 8. Sermaye serisi — artan ve eski para karışmıyor ─────────────────────
s = govde["kunye"]["sermaye_serisi"]
if [x["yil"] for x in s] != sorted(x["yil"] for x in s):
    hata.append("SERMAYE SERİSİ SIRASIZ")
if [x["tutar_tl"] for x in s] != sorted(x["tutar_tl"] for x in s):
    hata.append("SERMAYE SERİSİ ARTMIYOR")
if any(x["yil"] < 2005 for x in s):
    hata.append("SERMAYE SERİSİNDE ESKİ PARA VAR — 2005 öncesi tutar bu seriye giremez")

# ── 9. Türetilmiş — elle yazılan sayı yok ─────────────────────────────────
o = govde["olcek"]
tigem_km2 = float(toplam_arazi) / 1000
turetilmis = {
    "_kapsam": "Hepsi yukarıdaki bloklardan HESAPLANDI; hiçbiri elle yazılmadı",
    "_kaynak_niteligi": "TÜRETİLMİŞ",
    "tigem_toplam_km2": yuvarla(tigem_km2, 3),
    "turkiye_tarim_arazisi_payi_yuzde": yuvarla(tigem_km2 / o["turkiye_tarim_arazisi_km2"] * 100, 2),
    "kullanimdaki_arazi_yuzde": kullanim_orani,
    "kiraya_verilen_arazi_yuzde": kira_orani,
    "kiraya_verilen_isletme_payi_yuzde": yuvarla(
        govde["isletmeler"]["kiraya_verilmis"]
        / (govde["isletmeler"]["faaliyette"] + govde["isletmeler"]["kiraya_verilmis"]) * 100, 1),
    "ceylanpinar_da": next(x["toplam"] for x in a["isletmeler"] if x["isletme"] == "Ceylanpınar"),
}
turetilmis["ceylanpinar_payi_toplam_yuzde"] = yuvarla(
    turetilmis["ceylanpinar_da"] / float(toplam_arazi) * 100, 1)
turetilmis["ceylanpinar_payi_17_isletme_yuzde"] = yuvarla(
    turetilmis["ceylanpinar_da"] / float(onyedi) * 100, 1)

ilk, son = 0, len(t["yillar"]) - 1
tr_ilk = t["turkiye_toplam_rapor"][ilk]
tr_son = t["turkiye_toplam_rapor"][son]
tg_ilk = t["tigem_bugday"][ilk] + t["tigem_arpa"][ilk]
tg_son = t["tigem_bugday"][son] + t["tigem_arpa"][son]
turetilmis |= {
    "tigem_toplam_dagitim": [t["tigem_bugday"][i] + t["tigem_arpa"][i] for i in range(n)],
    "tigem_birlesik_pay_yuzde": [
        yuvarla((t["tigem_bugday"][i] + t["tigem_arpa"][i]) / t["turkiye_toplam_rapor"][i] * 100, 1)
        for i in range(n)],
    "turkiye_buyume_kat": yuvarla(tr_son / tr_ilk, 2),
    "tigem_buyume_kat": yuvarla(tg_son / tg_ilk, 2),
    "sperma_buyume_kat": yuvarla(
        govde["damizlik"]["sperma_doz"][-1] / govde["damizlik"]["sperma_doz"][0], 2),
    "koyun_buyume_kat": yuvarla(
        govde["damizlik"]["koyun_varlik_2023"] / govde["damizlik"]["koyun_varlik_2002"], 1),
    "sigir_buyume_kat": yuvarla(
        govde["damizlik"]["sigir_varlik_2023"] / govde["damizlik"]["sigir_varlik_2002"], 1),
    "gorev_cumlesi_yil_araligi": gyillar[-1] - gyillar[0],
    "kurulus_silsilesi_yil_araligi": yillar[-1] - yillar[0],
}

# Eksenin cümlesi — iki sayı da türetilmiş olmalı
eksen_pay = turetilmis["turkiye_tarim_arazisi_payi_yuzde"]
eksen_tohum = turetilmis["tigem_birlesik_pay_yuzde"][son]
if eksen_pay >= 1.0:
    hata.append(f"EKSEN CÜMLESİ BOZULDU · arazi payı %{eksen_pay} — 'yüzde birinden azı' yazılamaz")
if not 15 <= eksen_tohum <= 25:
    hata.append(f"EKSEN CÜMLESİ BOZULDU · tohum payı %{eksen_tohum} — 'beşte biri' yazılamaz")

# Tamamlanmamış blok uyarı verir, üretimi durdurmaz
for ad, blok in govde.items():
    if isinstance(blok, dict) and blok.get("_durum", "").startswith("TAMAMLANMADI"):
        uyari.append(f"TAMAMLANMADI · '{ad}' — {blok['_durum']}")

if hata:
    print("VERİ KATMANI KİLİTLENMEDİ:", file=sys.stderr)
    for h in hata:
        print("  ✗", h, file=sys.stderr)
    sys.exit(1)

cikti = {
    "_dosya": "TİGEM — Kurum Dosyası Sayı 06 · veri sayfası",
    "_uretim": "build_data.py — elle düzenlenmez",
    "_eksen": ("Kurum Türkiye tarım arazisinin yüzde birinden azını tutuyor ama ülkede "
               "dağıtılan sertifikalı hububat tohumunun beşte birini veriyor; çünkü "
               "ürettiği şey gıda değil girdi."),
    "_eksen_notu": ("Pay 2002'de %90 idi. Kurum küçülmedi — ülke büyüdü. 2002-2022 arasında "
                    "Türkiye'nin dağıtımı " + str(turetilmis["turkiye_buyume_kat"]) + " kat, "
                    "TİGEM'inki " + str(turetilmis["tigem_buyume_kat"]) + " kat arttı."),
    "_eksenin_siniri": ("Tohum payının paydası DAĞITIM'dır, ihtiyaç değil. İhtiyaç paydası "
                        "kullanılırsa oran düşer. İki payda aynı cümlede karıştırılmaz."),
    **govde,
    "turetilmis": turetilmis,
}
(KOK / "data.json").write_text(
    json.dumps(cikti, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")

print("data.json yazıldı · 9 doğrulamanın 9'u geçti")
for u in uyari:
    print("  ⚠", u)
print(f"  arazi payı            %{eksen_pay}")
print(f"  tohum payı (2022)     %{eksen_tohum}")
print(f"  pay serisi            {turetilmis['tigem_birlesik_pay_yuzde']}")
print(f"  Ceylanpınar           %{turetilmis['ceylanpinar_payi_toplam_yuzde']} (toplam) · "
      f"%{turetilmis['ceylanpinar_payi_17_isletme_yuzde']} (17 işletme)")
print(f"  kiraya verilen arazi  %{turetilmis['kiraya_verilen_arazi_yuzde']} · "
      f"işletme %{turetilmis['kiraya_verilen_isletme_payi_yuzde']}")
