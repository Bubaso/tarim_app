#!/usr/bin/env python3
"""TİGEM — grafik tariflerini data.json'a karşı sınar. Tohumlamadan ÖNCE koşar.

ON BİR KURAL
 1. Her @yol çözülüyor
 2. Yol SAYI döndürüyor — küme yalnızca 'harita'/'liste' altında serbest
 3. Grafik kimlikleri benzersiz, türler çizici bulunan türlerden
 4. ikili_cubuk: en az iki seri, her satırın değer sayısı seri sayısına eşit
 5. cizgi: x ekseni SAYISAL ve noktalar `noktalar.liste` altında. Dizge yıl
    CizgiSeri._coz'dan geçmiyor ve seri SESSİZCE boş kalıyor
 6. Her grafikte başlık ve kaynak var
 7. ÖLÇÜ ADI NOTTA GEÇİYOR. Dağıtım serisi kullanan grafiğin notu "dağıtım",
    satış serisi kullananın notu "satış" demek zorunda. İki seri aynı yılda
    farklı rakam veriyor (104.319 ↔ 79.561) ve fark kurumun kendi ekilişi
 8. ikili_cubuk satırları KOMPOZİSYON: her satır ~100 etmeli. Bu tür satır
    satır oranlıyor; büyüklük karşılaştırması için kullanılırsa küçük değer
    büyük değerle AYNI uzunlukta çizilir (Irak dosyası tur 9'un hatası)
 9. islem_akisi: her adımın başlığı var; `sure` yazılmışsa boş dizge değil
10. kartlar çizicisi `rol`/`vurgu` okumuyor — kart tanımında rol varsa
    sessizce düşer, o yüzden yazılmaz
11. siralama aralığı 40 katı aşmıyor — bu tür bütün grafiği birden oranlar,
    aşarsa en küçük çubuk görünmez olur
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


G = TANIM["grafikler"]
if len(G) != len({k for k in G if not k.startswith("_")}):
    hata.append("GRAFİK KİMLİĞİ TEKRARLI")

for gid, g in G.items():
    if gid.startswith("_"):
        continue
    gez(g, gid, gid)

    tur = g.get("tur")
    if tur not in CIZICI:
        hata.append(f"{gid}: çizici yok — tür '{tur}'")
    if not g.get("baslik"):
        hata.append(f"{gid}: başlık yok")
    if not g.get("kaynak"):
        hata.append(f"{gid}: kaynak yok")

    notu = json.dumps(g.get("not", {}), ensure_ascii=False).lower()
    ham = json.dumps(g, ensure_ascii=False)

    # 7 — ölçü adı notta geçiyor
    if "@tohum_dagitim." in ham or "dagitim_kayitlari" in ham:
        if "dağıtım" not in notu and "dağıtıl" not in notu:
            hata.append(f"{gid}: DAĞITIM serisi kullanıyor ama notu ölçüyü söylemiyor")
    if "@tohum_satis." in ham:
        if "satış" not in notu and "satıl" not in notu:
            hata.append(f"{gid}: SATIŞ serisi kullanıyor ama notu ölçüyü söylemiyor")

    # 4 ve 8 — ikili_cubuk
    if tur == "ikili_cubuk":
        seriler = g.get("seriler", [])
        if len(seriler) < 2:
            hata.append(f"{gid}: ikili_cubuk en az iki seri ister")
        for i, s in enumerate(g.get("satirlar", [])):
            d = s.get("degerler", [])
            if len(d) != len(seriler):
                hata.append(f"{gid}.satirlar[{i}]: {len(d)} değer, {len(seriler)} seri")
            sayilar = [coz(x[1:]) if isinstance(x, str) and x.startswith("@") else x for x in d]
            if all(isinstance(x, (int, float)) for x in sayilar):
                toplam = sum(sayilar)
                if abs(toplam - 100) > 0.5:
                    hata.append(
                        f"{gid}.satirlar[{i}]: değerler {toplam} ediyor, 100 değil — "
                        f"ikili_cubuk SATIR SATIR oranlar, büyüklük karşılaştırmaz")

    # 5 — cizgi
    if tur == "cizgi":
        for i, s in enumerate(g.get("seriler", [])):
            n = s.get("noktalar")
            if not isinstance(n, dict) or not ({"harita", "liste"} & set(n)):
                hata.append(f"{gid}.seriler[{i}]: noktalar 'harita' ya da 'liste' altında değil")
                continue
            if "liste" in n:
                kayit = coz(n["liste"][1:]) if n["liste"].startswith("@") else None
                if not isinstance(kayit, list) or not kayit:
                    hata.append(f"{gid}.seriler[{i}]: '{n['liste']}' liste döndürmedi")
                    continue
                for k in (n.get("x"), n.get("y")):
                    if k not in kayit[0]:
                        hata.append(f"{gid}.seriler[{i}]: kayıtlarda '{k}' alanı yok")
                xdeger = [r.get(n["x"]) for r in kayit]
                if not all(isinstance(x, (int, float)) and not isinstance(x, bool) for x in xdeger):
                    hata.append(f"{gid}.seriler[{i}]: x ekseni SAYISAL değil — seri sessizce boş kalır")
                elif xdeger != sorted(xdeger):
                    hata.append(f"{gid}.seriler[{i}]: x ekseni artan değil {xdeger}")

    # 9 — islem_akisi
    if tur == "islem_akisi":
        adimlar = g.get("adimlar", [])
        if len(adimlar) < 2:
            hata.append(f"{gid}: islem_akisi en az iki adım ister")
        for i, a in enumerate(adimlar):
            if not a.get("baslik"):
                hata.append(f"{gid}.adimlar[{i}]: başlık yok")
            if "sure" in a and not (a["sure"] or {}).get("tr"):
                hata.append(f"{gid}.adimlar[{i}]: 'sure' var ama boş — tahmin yazılmaz, alan silinir")

    # 10 — kartlar rol okumuyor
    if tur == "kartlar":
        for i, k in enumerate(g.get("kartlar", [])):
            if "rol" in k or "vurgu" in k:
                hata.append(f"{gid}.kartlar[{i}]: 'rol' kartlar çizicisinde okunmuyor, sessizce düşer")
            if not k.get("baslik") or not k.get("govde"):
                hata.append(f"{gid}.kartlar[{i}]: başlık ya da gövde yok")

    # 11 — siralama aralığı. Bu tür BÜTÜN grafiği birden oranlıyor; en büyük
    # ile en küçük arasındaki oran 40'ı aşarsa en küçük çubuk 360 px'te
    # %2,5'in altına, yani 9 pikselin altına iner ve okur onu çizim hatası
    # sanar. Çözüm küçükleri DÜŞÜRMEK değil, TOPLAMAK (1937 cetvelinde öyle
    # yapıldı) — düşürmek yekûnu bozar.
    if tur == "siralama":
        sayilar = []
        for s in g.get("satirlar", []):
            v = s.get("deger")
            v = coz(v[1:]) if isinstance(v, str) and v.startswith("@") else v
            if isinstance(v, (int, float)) and v > 0:
                sayilar.append(v)
        if sayilar and max(sayilar) / min(sayilar) > 40:
            hata.append(
                f"{gid}: siralama aralığı {max(sayilar) / min(sayilar):.0f} kat — "
                f"en küçük çubuk görünmez. Küçükleri topla, düşürme")

    # zaman_cizelgesi — yıllar artan
    if tur == "zaman_cizelgesi":
        yillar = [o.get("yil") for o in g.get("olaylar", [])]
        if yillar != sorted(y for y in yillar if isinstance(y, int)):
            hata.append(f"{gid}: zaman çizelgesi yılları artan değil {yillar}")

if hata:
    print("GRAFİKLER KİLİTLENMEDİ:", file=sys.stderr)
    for h in hata:
        print("  ✗", h, file=sys.stderr)
    sys.exit(1)

sayac: dict[str, int] = {}
for gid, g in G.items():
    if not gid.startswith("_"):
        sayac[g["tur"]] = sayac.get(g["tur"], 0) + 1
print(f"grafikler kilitlendi · {len([k for k in G if not k.startswith('_')])} grafik · "
      f"{yol_sayisi} @yol çözüldü · 11 kuralın 11'i geçti")
for t, n in sorted(sayac.items()):
    print(f"  {t:18s} {n}")
