#!/usr/bin/env python3
"""Avustralya — grafik tariflerini seed'den ÖNCE sınar.

seed_dossier.mjs aynı denetimleri yapıyor ama veritabanına bağlanıyor.
Bu betik bağlanmadan aynı kuralları uygular, böylece kopuk bir yol
veritabanı turuna çıkmadan yakalanır.

SINANAN KURALLAR
1. Tür, çizicide GERÇEKTEN bulunan dokuz tipten biri olmalı (§8.12).
2. Her @yol data.json'da çözülmeli.
3. 'harita'/'liste' dışındaki her yol tek bir SAYI vermeli.
4. 'liste' dizi, 'harita' nesne vermeli.
5. Her iki dilli alan hem tr hem en taşımalı.
6. Çizgi grafiğinin x alanı listedeki kayıtlarda SAYISAL olmalı — dizgi yıl
   ("2023-24") SESSİZCE boş seri üretir: CizgiSeri._coz nokta bulamayınca
   null döner, grafik atlanır, ne başlık ne hata kalır.
7. Her grafiğin kaynağı yazılı olmalı.
8. Gövdesi boş grafik olmamalı.
"""
import json, sys
from pathlib import Path

KOK = Path(__file__).parent
VERI = json.loads((KOK / "data.json").read_text(encoding="utf-8"))
TARIF = json.loads((KOK / "grafikler.json").read_text(encoding="utf-8"))

TURLER = {"ikili_cubuk","siralama","cizgi","yigin","kunye","zaman_cizelgesi",
          "kartlar","islem_akisi","ticaret_akisi"}
KUME = {"harita", "liste"}
GOVDE = {"ikili_cubuk":"satirlar","siralama":"satirlar","cizgi":"seriler",
         "yigin":"cubuklar","kunye":"kalemler","zaman_cizelgesi":"olaylar",
         "kartlar":"kartlar","islem_akisi":"adimlar","ticaret_akisi":"giren"}

hata, yol_sayisi = [], 0

def coz_yol(yol):
    d = VERI
    for p in yol.split("."):
        if isinstance(d, list):
            if not p.isdigit() or int(p) >= len(d): return None
            d = d[int(p)]
        elif isinstance(d, dict):
            if p not in d: return None
            d = d[p]
        else: return None
    return d

def gez(dugum, anahtar, iz):
    global yol_sayisi
    if isinstance(dugum, str) and dugum.startswith("@"):
        yol_sayisi += 1
        yol = dugum[1:]
        deger = coz_yol(yol)
        if deger is None:
            hata.append(f"{iz}: '@{yol}' data.json'da YOK"); return
        kume = isinstance(deger, (list, dict))
        if kume and anahtar not in KUME:
            hata.append(f"{iz}: '@{yol}' {'dizi' if isinstance(deger,list) else 'nesne'} döndürdü, '{anahtar}' tek sayı bekliyor")
        if not kume and not isinstance(deger, (int, float)):
            hata.append(f"{iz}: '@{yol}' sayı değil ({deger!r})")
        if anahtar == "liste" and not isinstance(deger, list):
            hata.append(f"{iz}: 'liste' dizi beklerken {type(deger).__name__}")
        if anahtar == "harita" and not isinstance(deger, dict):
            hata.append(f"{iz}: 'harita' nesne beklerken {type(deger).__name__}")
        return
    if isinstance(dugum, list):
        for i, x in enumerate(dugum): gez(x, anahtar, f"{iz}[{i}]")
        return
    if isinstance(dugum, dict):
        if "tr" in dugum or "en" in dugum:
            for dil in ("tr", "en"):
                if not isinstance(dugum.get(dil), str) or not dugum[dil].strip():
                    hata.append(f"{iz}: iki dilli alanda '{dil}' eksik ya da boş")
        for k, v in dugum.items():
            if not k.startswith("_"): gez(v, k, f"{iz}.{k}")

for gid, g in TARIF["grafikler"].items():
    iz = f"grafikler.{gid}"
    tur = g.get("tur")
    if tur not in TURLER:
        hata.append(f"{iz}: tür '{tur}' çizicide YOK"); continue
    if not g.get("kaynak"):
        hata.append(f"{iz}: kaynak satırı yok")
    govde = g.get(GOVDE[tur])
    if not isinstance(govde, list) or not govde:
        hata.append(f"{iz}: '{GOVDE[tur]}' boş ya da yok — çizici atlar")
    gez(g, None, iz)
    if tur == "cizgi":
        for i, s in enumerate(g.get("seriler", [])):
            n = s.get("noktalar", {})
            ly, xa, ya = n.get("liste"), n.get("x"), n.get("y")
            if isinstance(ly, str) and ly.startswith("@"):
                kayitlar = coz_yol(ly[1:])
                if not isinstance(kayitlar, list) or not kayitlar: continue
                if not xa or not ya:
                    hata.append(f"{iz}.seriler[{i}]: 'liste' biçimi x ve y alan adı istiyor"); continue
                gecer = [k for k in kayitlar if isinstance(k.get(xa), (int, float))
                         and isinstance(k.get(ya), (int, float))]
                if not gecer:
                    hata.append(f"{iz}.seriler[{i}]: hiçbir kayıtta sayısal '{xa}'/'{ya}' yok — seri BOŞ çizilir")
                elif len(gecer) < len(kayitlar):
                    print(f"  ⚠ {iz}.seriler[{i}]: {len(kayitlar)-len(gecer)}/{len(kayitlar)} nokta düşüyor")

if hata:
    print("GRAFİK SINAMASI BAŞARISIZ:\n", file=sys.stderr)
    for h in hata: print("  ✗ " + h, file=sys.stderr)
    sys.exit(1)

print(f"✓ {len(TARIF['grafikler'])} grafik · {yol_sayisi} @yol çözüldü · 8 kural geçti")
for gid, g in TARIF["grafikler"].items():
    print(f"  {gid:<26s} {g['tur']:<16s} {len(g.get(GOVDE[g['tur']], []))} öğe")
