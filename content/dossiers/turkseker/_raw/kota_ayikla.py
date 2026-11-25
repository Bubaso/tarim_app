#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""2025/26 kotaları + NBŞ kotasının yıllara göre seyri.
Kaynak: TÜRKŞEKER Şeker Sektör Raporu 2025, Tablo 23 ve Tablo 24.
Metin PDF'ten pypdf ile çıkarıldı (bkz. pdf_metin.py)."""
import json, pathlib, re

KOK = pathlib.Path(__file__).parent
METIN = (KOK / "kaynak_dosyalari" / "sektor_raporu_2025.txt").read_text(encoding="utf-8")


def sayi(s):
    """1.023.820 -> 1023820 · 36,08 -> 36.08"""
    s = s.strip().replace(".", "").replace(",", ".")
    return float(s) if "." in s else int(s)


def blok(etiket, uzunluk):
    k = METIN.find(etiket, 60000)        # içindekiler listesini atla
    if k < 0:
        raise SystemExit(f"✗ bulunamadı: {etiket}")
    return METIN[k:k + uzunluk]


# ── Tablo 23 · NBŞ kotasının seyri ───────────────────────────────────
nbs = {}
for y, pancar, nb, top in re.findall(
        r"(\d{4})/\d{4}\s+([\d.]+)\s+([\d.,]+)\s+([\d.]+)", blok("Tablo 23:  Pancar Şekeri", 1400)):
    nbs[y] = {"pancar_bin_ton": sayi(pancar), "nbs_bin_ton": sayi(nb),
              "toplam_bin_ton": sayi(top),
              "nbs_pay_yuzde": round(sayi(nb) / sayi(top) * 100, 2)}

# ── Tablo 24 · 2025/26 şirket kotaları ───────────────────────────────
t24 = blok("Tablo 24: 2025/2026 Pazarlama", 2200)

# SATIR SATIR OKUNUYOR. Çok satırlı kalıp denendi ve bir önceki satırı
# yuttu ("PANCAR ŞEKERİ" başlığı KAMU TÜRKŞEKER adına yapıştı), bu da
# üç kesim doğrulamasını düşürdü. Burada her satır kendi başına ele
# alınıyor; PDF'te ada sığmayıp alt satıra taşan parçalar (Alpullu,
# Afyon, Elbistan, Kayseri) bir önceki satırdan taşınıyor.
SAYISAL = re.compile(r"^(.*?)\s+([\d.]{4,12})\s+([\d,]{1,6})\s+([\d.]{3,10})\s*$")
# TAŞMA ÖLÇÜTÜ DAR TUTULDU. Önce "sayısal olmayan her satır devirdir"
# denendi; başlık satırı "(Ton) (%) (Ton)" KAMU TÜRKŞEKER adına yapıştı
# ve satır süzgece takıldı — üç kesim doğrulaması bunu yakaladı.
# Gerçek taşma dört yerde var ve hepsi şu iki işaretten birini taşıyor:
# ya parça "A.Ş." / "(" ile başlıyor, ya da üst satır virgülle bitiyor.
sirket, onceki = [], ""
for ham in t24[:t24.find("NİŞASTA BAZLI ŞEKER")].splitlines():
    sat = ham.strip()
    if not sat:
        continue
    m = SAYISAL.match(sat)
    if not m:
        onceki = sat
        continue
    ad, a, pay, b = m.groups()
    tasma = ad.startswith(("A.Ş.", "(")) or onceki.endswith(",")
    ad = re.sub(r"\s+", " ", f"{onceki} {ad}" if tasma else ad).strip(" .")
    onceki = ""
    if not ad or ad.startswith(("Tablo", "A Kotası", "(Ton)", "Şeker", "Pancar")):
        continue
    sirket.append({"ad": ad, "a_kotasi_ton": sayi(a),
                   "pancar_sekerinde_pay_yuzde": sayi(pay), "b_kotasi_ton": sayi(b)})

# ── NBŞ şirketleri (B kotası yok, üç sütun) ──────────────────────────
nbs_sirket = [{"ad": re.sub(r"\s+", " ", ad).strip(), "a_kotasi_ton": sayi(a),
               "nbs_icinde_pay_yuzde": sayi(p)}
              for ad, a, p in re.findall(
                  r"([A-ZÇĞİÖŞÜ][A-Za-zÇĞİÖŞÜçğıöşü.ŞveTic&\- ]{6,60}A\.Ş\.|Sunar Mısır Entegre Tesisleri)\s+([\d.]{4,8})\s+([\d,]{1,6})\s*\n",
                  t24[t24.find("NİŞASTA BAZLI ŞEKER"):])]

d = {
    "_kaynak": "TÜRKŞEKER, Şeker Sektör Raporu 2025 — Tablo 23 (s. 44) ve Tablo 24 (s. 45)",
    "_cekim": "2026-11-23",
    "nbs_kotasi_seyri": nbs,
    "pancar_sekeri_2025_26": {"sirketler": sirket},
    "nbs_2025_26": {"sirketler": nbs_sirket},
}

# ── DOĞRULAMALAR ─────────────────────────────────────────────────────
h = []
tpl = next((s for s in sirket if "PANCAR ŞEKERİ TOPLAMI" in s["ad"]), None)
if not tpl or tpl["a_kotasi_ton"] != 2_837_250:
    h.append("pancar şekeri toplamı 2.837.250 değil")
üc = {k: next((s["pancar_sekerinde_pay_yuzde"] for s in sirket if s["ad"].startswith(k)), None)
      for k in ("KAMU TÜRKŞEKER", "KOOPERATİF FAB. TOPLAMI", "ÖZEL ŞEKER ŞİRKETLERİ TOPLAMI")}
if None in üc.values():
    h.append(f"üç kesimden biri okunamadı: {üc}")
else:
    d["uc_kesim_yuzde"] = {"kamu": üc["KAMU TÜRKŞEKER"],
                           "kooperatif": üc["KOOPERATİF FAB. TOPLAMI"],
                           "ozel": üc["ÖZEL ŞEKER ŞİRKETLERİ TOPLAMI"]}
    if abs(sum(üc.values()) - 100) > 0.05:
        h.append(f"üç kesim payı 100 etmiyor: {sum(üc.values())}")
alp = next((s for s in sirket if "Binbirgıda" in s["ad"]), None)
if not alp:
    h.append("Alpullu (Binbirgıda) satırı bulunamadı")
else:
    d["alpullu"] = alp
if not nbs or "2017" not in nbs or "2025" not in nbs:
    h.append(f"NBŞ seyri eksik: {sorted(nbs)}")
else:
    d["nbs_dusus"] = {"_2017_18_bin_ton": nbs["2017"]["nbs_bin_ton"],
                      "_2019_20_bin_ton": nbs["2019"]["nbs_bin_ton"],
                      "degisim_yuzde": round(
                          (nbs["2019"]["nbs_bin_ton"] / nbs["2017"]["nbs_bin_ton"] - 1) * 100, 1)}
if sum(s["a_kotasi_ton"] for s in nbs_sirket) != 72_750:
    h.append(f"NBŞ şirket toplamı 72.750 değil: {sum(s['a_kotasi_ton'] for s in nbs_sirket)}")
if h:
    raise SystemExit("✗ DOĞRULAMA DÜŞTÜ\n  " + "\n  ".join(h))

(KOK / "kota.json").write_text(json.dumps(d, ensure_ascii=False, indent=2), encoding="utf-8")

print(f"  üç kesim: kamu %{üc['KAMU TÜRKŞEKER']} · kooperatif %{üc['KOOPERATİF FAB. TOPLAMI']}"
      f" · özel %{üc['ÖZEL ŞEKER ŞİRKETLERİ TOPLAMI']}")
print(f"  Alpullu: {alp['a_kotasi_ton']:,} ton · %{alp['pancar_sekerinde_pay_yuzde']} — 15 üreticinin en küçüğü")
print(f"\n  NBŞ kotası (bin ton):")
for y, v in sorted(nbs.items()):
    print(f"    {y}/{int(y)+1}  NBŞ {v['nbs_bin_ton']:>6}  ·  toplamın %{v['nbs_pay_yuzde']}")
print(f"\n  2017/18 → 2019/20: %{d['nbs_dusus']['degisim_yuzde']}")
print(f"\n  ✓ {len(sirket)} satır pancar · {len(nbs_sirket)} şirket NBŞ · kota.json yazıldı")
