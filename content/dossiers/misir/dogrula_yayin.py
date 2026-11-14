#!/usr/bin/env python3
"""Mısır — `yayin.json`'u grafiklere, veri katmanına ve DİSKTEKİ dosyalara sınar.

NEDEN VAR. Yayın künyesi üç ayrı şeye söz veriyor: grafikler.json'daki
kimliklere, web/dosya/misir altındaki dosyalara ve data.json'daki sayılara.
Üçü de ayrı dosyada; aralarındaki kayma hiçbir denetimde görünmez. Dosya
yayına alındıktan sonra görünür ve o zaman geç olur.

ON İKİ KURAL — ilk sekizi Irak'tan, 9-11 TİGEM'in altyazı denetiminden,
12 bu dosyada doğdu:
  1. bolum_grafikleri'ndeki her kimlik grafikler.json'da VAR
  2. Her grafik en az bir bölüme yerleştirilmiş — yetim grafik yok
  3. Bölüm numaraları iskeletle tutuyor
  4. Her görselin dosyası DİSKTE var ve en_boy DOSYADAN ölçülenle aynı
  5. Her görselde atıf, lisans, alt_tr ve alt_en dolu; lisans kabul listesinde
  6. Hikâye slaytlarındaki her rakam data.json'da karşılığını buluyor
  7. Hikâye görselleri bölüm görselleriyle aynı havuzdan
  8. HER BÖLÜMDE görsel var — kaynakça dahil
  9. ALTYAZIDA KADRAJ SÖZCÜĞÜ YOK (arkada, ön planda, görülüyor…)
 10. ALTYAZIDA GÖRÜNÜŞ ENVANTERİ YOK (rengi, desenli, şapkalı…)
 11. ALTYAZIDA TARİH VAR; kaynak vermiyorsa altyazı bunu AÇIKÇA söylüyor
 12. HER ALTYAZININ `_dayanak`'ı VAR — hangi künye alanından yazıldığı
     yazılı. Bu alan olmadan 9-11 kuralları yalnız ÜSLUBU denetler; dayanak
     alanı altyazının KAYNAĞINI denetlenebilir kılıyor.

NEYİ KANITLAMAZ: görselin KONUYA uygun olduğunu. Başlık yalan söyleyebilir ve
Irak dosyasında söyledi — on dokuz adayın üçü gözle açıldığında reddedildi.
Bu betik gözün yerine geçmez.

Çalıştırma: python3 dogrula_yayin.py
"""
from __future__ import annotations

import json
import pathlib
import re
import sys

KOK = pathlib.Path(__file__).parent
DEPO = KOK.parent.parent.parent
Y = json.loads((KOK / "yayin.json").read_text(encoding="utf-8"))
G = json.loads((KOK / "grafikler.json").read_text(encoding="utf-8"))["grafikler"]
VERI = json.loads((KOK / "data.json").read_text(encoding="utf-8"))
hata: list[str] = []

LISANS = {"CC0", "Public domain", "CC BY 2.0", "CC BY 3.0", "CC BY 4.0",
          "CC BY-SA 2.0", "CC BY-SA 2.5", "CC BY-SA 3.0", "CC BY-SA 4.0",
          "CC BY-SA 3.0 igo"}
BOLUM = {int(k) for k in Y["_bolum_basliklari"] if not k.startswith("_")}
GB = {k: v for k, v in Y["bolum_grafikleri"].items() if not k.startswith("_")}
GOR = {int(k): v for k, v in Y["bolum_gorselleri"].items() if not k.startswith("_")}

# ── 1, 2, 3 — grafikler ve bölüm numaraları ──────────────────────────────
yerlesen = set()
for no, liste in GB.items():
    if int(no) not in BOLUM:
        hata.append(f"bolum_grafikleri: olmayan bölüm {no}")
    for gid in liste:
        if gid not in G:
            hata.append(f"bölüm {no}: '{gid}' grafikler.json'da YOK")
        yerlesen.add(gid)
yetim = sorted(set(G) - yerlesen - {k for k in G if k.startswith("_")})
if yetim:
    hata.append(f"YETİM GRAFİK — hiçbir bölüme yerleştirilmemiş: {yetim}")
if {int(k) for k in Y["bolum_turleri"] if not k.startswith("_")} != BOLUM:
    hata.append("bolum_turleri ile bölüm iskeleti ayrışmış")

# ── 4, 5, 8 — görseller ──────────────────────────────────────────────────
WEB = DEPO / "web" / "dosya" / "misir"
try:
    from PIL import Image          # noqa
    olcebilir = True
except Exception:
    olcebilir = False

for b in sorted(BOLUM):
    g = GOR.get(b)
    if not isinstance(g, dict):
        hata.append(f"bölüm {b}: GÖRSEL YOK — her bölümde bir görsel olacak")
        continue
    for alan in ("url", "atif", "lisans", "alt_tr", "alt_en", "en_boy"):
        if not g.get(alan):
            hata.append(f"bölüm {b}: '{alan}' boş")
    if g.get("lisans") and g["lisans"] not in LISANS:
        hata.append(f"bölüm {b}: lisans kabul listesinde değil — '{g['lisans']}'")
    ad = (g.get("url") or "").rsplit("/", 1)[-1]
    yol = WEB / ad
    if not yol.exists():
        hata.append(f"bölüm {b}: dosya DİSKTE YOK — web/dosya/misir/{ad}")
    elif olcebilir:
        with Image.open(yol) as im:
            olculen = round(im.width / im.height, 4)
        if abs(olculen - float(g["en_boy"])) > 0.01:
            hata.append(f"bölüm {b}: en_boy {g['en_boy']} ≠ diskte ölçülen "
                        f"{olculen} — künyeden kopyalanmış olabilir")

# ── 9, 10, 11, 12 — ALTYAZI KÜNYEDİR ─────────────────────────────────────
# Kullanıcı bu düzeltmeyi İKİ KEZ verdi (8 ve 12 Kasım 2026). TİGEM
# dosyasında kareye bakarak yazılan on dört altyazıdan dördü maddi hata
# çıkmıştı.
KADRAJ = ["arkada", "arka planda", "önde", "ön planda", "yakın planda",
          "kadrajda", "solda", "sağda", "altta", "üstte", "ortada",
          "görülüyor", "görünüyor", "foreground", "background",
          "behind them", "in the foreground", "in the background",
          "on the left", "on the right"]
GORUNUS = ["rengi", "renkli", "desenli", "tüylü", "giysi", "giysisiyle",
           "şapkalı", "takımlı", "parmaklıklı", "çatılı", "patterned",
           "coloured", "colored", "wearing", "sun canopy"]
TARIHSIZ_MAZERET = ("tarihi kayıtlı değil", "tarihi bilinmiyor",
                    "date is not recorded", "date is unknown")
TAVAN = 230

def altyazi_denetle(iz: str, g: dict) -> None:
    for dil, alan in (("tr", "alt_tr"), ("en", "alt_en")):
        a = g.get(alan) or ""
        d = a.lower()
        for k in KADRAJ:
            if k in d:
                hata.append(f"{iz} [{dil}]: KADRAJ SÖZCÜĞÜ '{k}' — altyazı "
                            f"fotoğrafın NE OLDUĞUNU söyler, karede neyin "
                            f"nerede durduğunu söylemez")
        for k in GORUNUS:
            if k in d:
                hata.append(f"{iz} [{dil}]: GÖRÜNÜŞ ENVANTERİ '{k}' — renk, "
                            f"desen, kıyafet künye bilgisi değil")
        if not re.search(r"\b(1[89]\d\d|20\d\d)\b", a) \
                and not any(m in d for m in TARIHSIZ_MAZERET):
            hata.append(f"{iz} [{dil}]: TARİH YOK — künye tarih ister; kaynak "
                        f"vermiyorsa altyazı bunu açıkça yazacak")
        if len(a) > TAVAN:
            hata.append(f"{iz} [{dil}]: {len(a)} karakter, tavan {TAVAN}")
    # 12 — dayanak
    if not g.get("_dayanak"):
        hata.append(f"{iz}: `_dayanak` YOK — altyazının hangi künye alanından "
                    f"yazıldığı yazılmadan üslup denetimi tek başına yetmez")

for b in sorted(BOLUM):
    if isinstance(GOR.get(b), dict):
        altyazi_denetle(f"bölüm {b} altyazı", GOR[b])
if isinstance(Y.get("kapak"), dict):
    altyazi_denetle("kapak altyazısı", Y["kapak"])

# ── 6, 7 — hikâye ────────────────────────────────────────────────────────
SAYILAR: list[float] = []
def topla(o):
    if isinstance(o, bool):
        return
    if isinstance(o, (int, float)):
        SAYILAR.append(float(o))
    elif isinstance(o, dict):
        for v in o.values():
            topla(v)
    elif isinstance(o, list):
        for v in o:
            topla(v)
topla(VERI)
OLCEK = [10.0 ** k for k in range(-9, 10)]

def veride_var(d: float, b: int) -> bool:
    return any(round(abs(x) * s, b) == d for x in SAYILAR for s in OLCEK)

hik = Y.get("hikaye") or {}
slaytlar = hik.get("slaytlar") or []
havuz = {(g.get("url") or "") for g in GOR.values() if isinstance(g, dict)}
havuz.add((Y.get("kapak") or {}).get("url", ""))
for i, s in enumerate(slaytlar):
    metin = " ".join(str(v) for k, v in s.items()
                     if not k.startswith("_") and isinstance(v, str))
    for m in re.finditer(r"\d{1,3}(?:\.\d{3})+(?:,\d+)?|\d+,\d+", metin):
        ham = m.group().replace(".", "").replace(",", ".")
        bas = len(ham.split(".")[1]) if "." in ham else 0
        if not veride_var(float(ham), bas):
            hata.append(f"hikâye slayt {i}: '{m.group()}' data.json'da yok")
    if s.get("gorsel") and s["gorsel"] not in havuz:
        hata.append(f"hikâye slayt {i}: görsel bölüm havuzunda yok")

if hata:
    print("YAYIN KÜNYESİ KİLİTLENMEDİ:", file=sys.stderr)
    for h in hata:
        print("  ✗", h, file=sys.stderr)
    sys.exit(1)

print(f"yayın künyesi kilitlendi · {len(BOLUM)} bölüm · {len(GOR)} görsel · "
      f"{len(yerlesen)} grafik yerleşimi · {len(slaytlar)} slayt · "
      f"12 kuralın 12'si geçti")
if not olcebilir:
    print("  ⚠ PIL yok — en_boy diskten ÖLÇÜLEMEDİ, kural 4 yarım koştu")
