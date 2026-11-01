#!/usr/bin/env python3
"""DSİ — grafik tariflerini data.json'a karşı sınar. Tohumlamadan ÖNCE koşar.

YEDİ KURAL
 1. Her @yol çözülüyor
 2. Yol SAYI döndürüyor — küme yalnızca 'harita'/'liste' altında serbest
 3. Grafik kimlikleri benzersiz, türler çizici bulunan türlerden
 4. ikili_cubuk: en az iki seri, her satırın değer sayısı seri sayısına eşit
 5. cizgi: x ekseni SAYISAL. Dizge yıl ("2000-01") CizgiSeri._coz'dan geçmiyor
    ve seri SESSİZCE boş kalıyor — grafik ne başlıkla ne hatayla görünüyor.
    Avustralya'da beş çizgi grafiğin beşi de böyle boş kalacaktı.
 6. Her grafikte başlık ve kaynak var
 7. KAPSAMI DAR grafiğin notu kapsamını SÖYLÜYOR — YAS serisi bütün
    tesislerle karıştırılamaz (build_data.py'deki doğrulamanın grafik tarafı)
"""
from __future__ import annotations

import json
import pathlib
import sys

KOK = pathlib.Path(__file__).parent
VERI = json.loads((KOK / "data.json").read_text(encoding="utf-8"))
TANIM = json.loads((KOK / "grafikler.json").read_text(encoding="utf-8"))
CIZICI = {"ikili_cubuk", "siralama", "cizgi", "yigin", "kunye",
          "zaman_cizelgesi", "kartlar", "islem_akisi", "ticaret_akisi"}
KUME = {"harita", "liste"}

hata: list[str] = []
yol_sayisi = 0


def coz(yol: str):
    d = VERI
    for p in yol.split("."):
        if isinstance(d, list):
            try:
                d = d[int(p)]
            except (ValueError, IndexError):
                return None
        elif isinstance(d, dict):
            if p not in d:
                return None
            d = d[p]
        else:
            return None
    return d


def gez(dugum, anahtar: str, iz: str):
    global yol_sayisi
    if isinstance(dugum, str) and dugum.startswith("@"):
        yol_sayisi += 1
        v = coz(dugum[1:])
        if v is None:
            hata.append(f"{iz}: '{dugum}' data.json'da yok")
        elif isinstance(v, (dict, list)):
            if anahtar not in KUME:
                hata.append(f"{iz}: '{dugum}' küme döndürdü ama '{anahtar}' sayı bekliyor")
        elif not isinstance(v, (int, float)) or isinstance(v, bool):
            hata.append(f"{iz}: '{dugum}' sayı değil ({v!r})")
    elif isinstance(dugum, list):
        for i, x in enumerate(dugum):
            gez(x, anahtar, f"{iz}[{i}]")
    elif isinstance(dugum, dict):
        for k, v in dugum.items():
            if not k.startswith("_"):
                gez(v, k, f"{iz}.{k}")


for gid, g in TANIM["grafikler"].items():
    iz = f"grafikler.{gid}"
    gez(g, gid, iz)

    if g.get("tur") not in CIZICI:
        hata.append(f"{iz}: tanımsız tür '{g.get('tur')}'")
    if not g.get("baslik"):
        hata.append(f"{iz}: başlık yok")
    if not g.get("kaynak"):
        hata.append(f"{iz}: KAYNAK YOK — kaynaksız grafik yayımlanmaz")

    if g.get("tur") == "ikili_cubuk":
        n = len(g.get("seriler", []))
        if n < 2:
            hata.append(f"{iz}: ikili_cubuk en az iki seri ister, {n} var")
        for i, s in enumerate(g.get("satirlar", [])):
            if len(s.get("degerler", [])) != n:
                hata.append(f"{iz}.satirlar[{i}]: {len(s.get('degerler', []))} değer, "
                            f"{n} seri — eşleşmiyor")

    if g.get("tur") == "cizgi":
        # ŞEKİL ÖNCE, İÇERİK SONRA. Bu blok bir kez YANLIŞ yazıldı: liste/x/y'yi
        # serinin ÜST DÜZEYİNDE arıyordu ve tanım da öyle yazılmıştı, yani
        # doğrulayıcı üreticinin hatasını onaylıyordu. Model ise
        # `seri['noktalar']`'a bakıyor; bulamayınca seriyi null döndürüyor,
        # grafik hiç çizilmiyor ve HİÇBİR YERDE hata çıkmıyor. §8.14.2'nin
        # dersi: doğrulayıcı üreticinin varsayımını paylaşırsa ikisi aynı yönde
        # yanılır. Dayanak artık dossier_chart.dart/CizgiSeri._coz.
        for i, s in enumerate(g.get("seriler", [])):
            for kacak in ("liste", "harita", "x", "y"):
                if kacak in s:
                    hata.append(f"{iz}.seriler[{i}]: '{kacak}' serinin üst "
                                "düzeyinde — model onu 'noktalar' ALTINDA arıyor, "
                                "burada kalırsa grafik sessizce çizilmez")
            n = s.get("noktalar")
            if not isinstance(n, dict):
                hata.append(f"{iz}.seriler[{i}]: 'noktalar' sözlüğü yok")
                continue
            if "harita" in n:
                continue
            if "liste" not in n:
                hata.append(f"{iz}.seriler[{i}].noktalar: ne 'liste' ne 'harita' var")
                continue
            xa, ya = n.get("x"), n.get("y")
            kayitlar = coz(n["liste"][1:]) if isinstance(n["liste"], str) else None
            if not kayitlar or not xa or not ya:
                hata.append(f"{iz}.seriler[{i}].noktalar: liste/x/y eksik"); continue
            for k in kayitlar:
                x, y = k.get(xa), k.get(ya)
                if not isinstance(x, (int, float)) or isinstance(x, bool):
                    hata.append(f"{iz}.seriler[{i}]: x ekseni SAYISAL DEĞİL "
                                f"({x!r}) — seri sessizce boş kalır")
                    break
                if not isinstance(y, (int, float)) or isinstance(y, bool):
                    hata.append(f"{iz}.seriler[{i}]: y ekseni SAYISAL DEĞİL "
                                f"({y!r}) — nokta sessizce düşer")
                    break

# Kural 7 — kapsamı dar grafiğin notu bunu söylemeli
dar = TANIM["grafikler"].get("devir_egrisi", {})
notu = json.dumps(dar.get("not", {}), ensure_ascii=False).upper()
if "YERALT" not in notu and "GROUNDWATER" not in notu.upper():
    hata.append("devir_egrisi: notu kapsamın YAS olduğunu söylemiyor")

if hata:
    print("GRAFİK SINAMASI BAŞARISIZ:\n", file=sys.stderr)
    for h in hata:
        print("  ✗ " + h, file=sys.stderr)
    sys.exit(1)

print(f"✓ {len(TANIM['grafikler'])} grafik · {yol_sayisi} @yol çözüldü · 7 kural geçti")
for gid, g in TANIM["grafikler"].items():
    n = (len(g.get("satirlar", [])) or len(g.get("kalemler", []))
         or len(g.get("olaylar", [])) or len(g.get("kartlar", []))
         or len(g.get("seriler", [])))
    print(f"  {gid:<20s} {g['tur']:<16s} {n} öğe")
