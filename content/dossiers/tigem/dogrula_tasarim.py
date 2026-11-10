#!/usr/bin/env python3
"""TİGEM — tasarım künyesini YENİDEN ÖLÇEREK sınar.

DSİ dosyasında dört şerit kontrastı betikten okunmayıp TAHMİN EDİLMİŞ ve
dördü de yanlış çıkmıştı (§8.14.3: "ölçülmemiş varsayım sessiz bir mayındır").
Bu betik o hatayı imkânsız kılıyor: tasarim.json'daki her `kontrast_*` sayısı
burada yeniden hesaplanıyor ve birebir tutmazsa üretim duruyor.

ON KURAL
 1. Her hex geçerli ve altı basamaklı
 2. Her `kontrast_*` sayısı yeniden ölçülüyor, birebir tutuyor
 3. Metin renkleri (murekkep, sessiz, vurgu, ikincil) kağıt ve yüzeyde AA
 4. `cizgi` 3:1'in ALTINDA ve uyarısını taşıyor — dekoratif, anlam taşıyamaz
 5. `cizgiVurgu` 3:1'in üstünde — eksen ve odak halkası onunla çiziliyor
 6. Kapak vurgusu koyu zeminde AA
 7. Kümenin vurgusu mevcut sekiz kümenin hiçbiriyle AYNI DEĞİL
 8. Şerit vurgusu uygulamanın yapısal yeşiline çökme deseninden (1,05) uzak
 9. Tez cümlesinin iki sayısı data.json ile tutuyor — arazi payı yüzde birin
    altında, tohum payı beşte bir aralığında
10. `_yasak` listesi var ve kapakta fotoğrafı yasaklıyor
"""
from __future__ import annotations

import importlib.util
import json
import pathlib
import re
import sys

KOK = pathlib.Path(__file__).parent
spec = importlib.util.spec_from_file_location("kontrast", KOK / "_raw" / "kontrast.py")
k = importlib.util.module_from_spec(spec)
spec.loader.exec_module(k)

T = json.loads((KOK / "tasarim.json").read_text(encoding="utf-8"))
VERI = json.loads((KOK / "data.json").read_text(encoding="utf-8"))
hata: list[str] = []
olculen = 0

ZEMIN = {"kontrast_zemin": None, "kontrast_yuzey": None,
         "kontrast_krem": k.APP_KREM, "kontrast_app_krem": k.APP_KREM}

# 1 ve 2 — her hex geçerli, her kontrast yeniden ölçülüyor
def gez(dugum, iz: str, kapakta: bool):
    global olculen
    if not isinstance(dugum, dict):
        return
    hx = dugum.get("hex")
    if hx is not None:
        if not re.fullmatch(r"#[0-9A-Fa-f]{6}", hx):
            hata.append(f"{iz}: geçersiz hex '{hx}'")
            return
        zemin = k.KZEMIN if kapakta else k.KAGIT
        for alan, deger in dugum.items():
            if not alan.startswith("kontrast"):
                continue
            olculen += 1
            if alan == "kontrast_zemin":
                karsi = zemin
            elif alan == "kontrast_yuzey":
                karsi = k.YUZEY
            elif alan in ("kontrast_krem", "kontrast_app_krem"):
                karsi = k.APP_KREM
            else:
                hata.append(f"{iz}: bilinmeyen kontrast alanı '{alan}'")
                continue
            basamak = len(str(deger).split(".")[-1]) if "." in str(deger) else 2
            olcum = round(k.cr(hx, karsi), basamak)
            if olcum != deger:
                hata.append(f"{iz}.{alan}: yazılı {deger}, ölçülen {olcum}")
    for ad, alt in dugum.items():
        if isinstance(alt, dict) and not ad.startswith("_"):
            gez(alt, f"{iz}.{ad}", kapakta or ad == "kapak")

gez(T["palet"]["sayfa"], "palet.sayfa", False)
gez(T["palet"]["kapak"], "palet.kapak", True)
gez(T["palet"]["serit"], "palet.serit", False)

S = T["palet"]["sayfa"]
KP = T["palet"]["kapak"]

# 3 — metin renkleri AA
for ad in ("murekkep", "sessiz", "vurgu", "ikincil"):
    for alan in ("kontrast_zemin", "kontrast_yuzey"):
        v = S[ad].get(alan)
        if v is None or v < 4.5:
            hata.append(f"palet.sayfa.{ad}.{alan} = {v} — AA altı")

# 4 ve 5 — çizgi ayrımı
if S["cizgi"]["kontrast_zemin"] >= 3.0:
    hata.append("palet.sayfa.cizgi 3:1'in üstünde — o zaman cizgiVurgu'dan ayrı durmuyor")
if "_uyari" not in S["cizgi"]:
    hata.append("palet.sayfa.cizgi uyarısını taşımıyor")
if S["cizgiVurgu"]["kontrast_zemin"] < 3.0:
    hata.append("palet.sayfa.cizgiVurgu 3:1'in altında — eksen çizilemez")

# 6 — kapak vurgusu
if KP["vurgu"]["kontrast_zemin"] < 4.5:
    hata.append(f"palet.kapak.vurgu AA altı: {KP['vurgu']['kontrast_zemin']}")

# 7 — küme rengi benzersiz
yeni = T["kume"]["kagit_vurgu"].upper()
for ad, kagit_hx, kapak_hx in k.KUMELER:
    if yeni == kagit_hx.upper():
        hata.append(f"küme vurgusu '{ad}' kümesiyle aynı: {yeni}")
    if T["kume"]["kapak_vurgu"].upper() == kapak_hx.upper():
        hata.append(f"kapak vurgusu '{ad}' kümesiyle aynı")
if yeni != S["vurgu"]["hex"].upper():
    hata.append("kume.kagit_vurgu ile palet.sayfa.vurgu tutmuyor")

# 8 — şerit ayrışması
yapisal = T["palet"]["serit"]["_ayrisma"]["uygulamanin_yapisal_yesili"]
oran = round(k.cr(T["palet"]["serit"]["vurguKoyu"]["hex"], yapisal), 2)
if oran != T["palet"]["serit"]["_ayrisma"]["oran"]:
    hata.append(f"şerit ayrışma oranı: yazılı {T['palet']['serit']['_ayrisma']['oran']}, ölçülen {oran}")
if oran <= 1.05:
    hata.append(f"şerit vurgusu yapısal yeşile çökme deseninde: {oran} ≤ 1,05")

# 9 — tez cümlesinin sayıları data.json ile tutuyor
tur = VERI["turetilmis"]
if tur["turkiye_tarim_arazisi_payi_yuzde"] >= 1.0:
    hata.append("tez cümlesi 'yüzde birinden azı' diyor ama veri %"
                f"{tur['turkiye_tarim_arazisi_payi_yuzde']}")
son_pay = tur["tigem_birlesik_pay_yuzde"][-1]
if not 15 <= son_pay <= 25:
    hata.append(f"tez cümlesi 'beşte biri' diyor ama veri %{son_pay}")
for dil, sozcuk in (("tr", "dağıtılan"), ("en", "distributed")):
    if sozcuk not in T["tez_cumlesi"][dil]:
        hata.append(f"tez cümlesi ({dil}) paydayı söylemiyor — '{sozcuk}' geçmiyor")

# 10 — yasak listesi
yasak = " ".join(T.get("_yasak", [])).lower()
if "kapakta fotoğraf" not in yasak:
    hata.append("_yasak listesi kapakta fotoğrafı yasaklamıyor")
if len(T.get("_yasak", [])) < 4:
    hata.append("_yasak listesi çok kısa")

if hata:
    print("TASARIM KİLİTLENMEDİ:", file=sys.stderr)
    for h in hata:
        print("  ✗", h, file=sys.stderr)
    sys.exit(1)

rk = T["renk_korlugu"]
print(f"tasarım kilitlendi · {olculen} kontrast yeniden ölçüldü, hepsi tuttu · 10 kuralın 10'u geçti")
print(f"  küme              {T['kume']['ad']} (dizinin {T['kume']['sira']}'uncusu)")
print(f"  kağıt vurgusu     {S['vurgu']['hex']}  kağıt {S['vurgu']['kontrast_zemin']} · yüzey {S['vurgu']['kontrast_yuzey']}")
print(f"  kapak vurgusu     {KP['vurgu']['hex']}  kapak {KP['vurgu']['kontrast_zemin']}")
print(f"  şerit ayrışması   {oran} (çökme deseni 1,05)")
print(f"  renk körlüğü      ΔE normal {rk['kagit_vurgusu_en_yakin']['normal_dE']} · "
      f"deuteranopi {rk['kagit_vurgusu_en_yakin']['deuteranopi_dE']} "
      f"(mevcut sekizin tabanı {rk['mevcut_sekizin_tabani']['en_kucuk_deuteranopi_dE']})")
