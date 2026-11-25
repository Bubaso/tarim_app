#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Galeri denetimi — Türkşeker, Kurum Dosyası Sayı 07.

Dizide ilk galeri bu. Kurallar bölüm görselinin kurallarının aynısı artı
galeriye özgü üç tanesi: kare sayısı, bölüm görselleriyle çakışmama ve
"galeri bölümü var ama galeri yok" (ya da tersi) ayrışması.
"""
import json, pathlib, re, sys
from PIL import Image

KOK = pathlib.Path(__file__).parent
RAW = KOK / "_raw"
D = json.loads((KOK / "data.json").read_text(encoding="utf-8"))
Y = json.loads((KOK / "yayin.json").read_text(encoding="utf-8"))
ALT = json.loads((RAW / "galeri_altyazilar.json").read_text(encoding="utf-8"))
hata, uyari = [], []

G = D.get("galeri") or {}
K = G.get("kareler") or []
OBEKLER = {"alpullu", "tarih", "tarla", "ciftci", "isci", "hasat",
           "yukleme", "fabrikalar", "fabrika_ici", "kendi_makinesi", "urun",
           "cevresi"}

# 1 · KULLANICI TABANI: en az 30 kare
# "en az 30-35 görsel olsun bu galeride" — 23 Kasım 2026.
if len(K) < 30:
    hata.append(f"1 · galeride {len(K)} kare var, kullanıcı en az 30 istedi")

# 2 · GALERİ BÖLÜMÜ İLE GALERİ BİRLİKTE VAR OLUR
# Tek çapa kuralı: türü 'galeri' olan bölüm galeriyi açıyor. Biri varken
# öteki yoksa galeri SESSİZCE çizilmez — denetimin yakalaması gereken hata
# tam olarak bu.
galeri_bolumu = [n for n, t in Y["bolum_turleri"].items()
                 if not n.startswith("_") and t == "galeri"]
if K and len(galeri_bolumu) != 1:
    hata.append(f"2 · data.json'da {len(K)} kare var ama türü 'galeri' olan "
                f"bölüm sayısı {len(galeri_bolumu)} (tam 1 olmalı)")
if galeri_bolumu and not K:
    hata.append(f"2 · §{galeri_bolumu[0]} galeri bölümü ama data.json'da kare yok")
if galeri_bolumu and galeri_bolumu[0] not in Y["_bolum_basliklari"]:
    hata.append(f"2 · §{galeri_bolumu[0]} başlıklarda yok")

# 3 · ZORUNLU ALANLAR (§2.4 — atıfsız görsel yayımlanmaz)
for i, k in enumerate(K, 1):
    for alan in ("url", "atif", "lisans", "alt_tr", "alt_en", "en_boy"):
        if not k.get(alan):
            hata.append(f"3 · {i}. karede '{alan}' boş ({k.get('_kimlik')})")

# 4 · DOSYA DİSKTE, RESİM VE KESİK DEĞİL
for k in K:
    y = RAW / "gorseller" / k["url"].rsplit("/", 1)[-1]
    if not y.exists():
        hata.append(f"4 · dosya yok: {y.name}")
        continue
    try:
        with Image.open(y) as im:
            im.load()                       # kesik JPEG burada patlıyor
            g, b = im.size
    except Exception as e:
        hata.append(f"4 · {y.name} okunamadı/kesik: {str(e)[:50]}")
        continue
    if round(g / b, 4) != k["en_boy"]:
        hata.append(f"4 · {y.name} en-boy tutmuyor: kayıt {k['en_boy']}, "
                    f"dosya {round(g / b, 4)}")
    if y.stat().st_size < 20_000:
        uyari.append(f"4 · {y.name} küçük ({y.stat().st_size // 1024} KB)")

# 5 · ALTYAZI KÜNYEDİR, TAHLİL DEĞİL (bölüm görselindeki kuralın aynısı)
TAHLIL = [r"\bgörülüyor\b", r"\bgörülmekte\b", r"\barka planda\b", r"\bön planda\b",
          r"\bkadraj\w*\b", r"\bsolda\b", r"\bsağda\b", r"\bdikkat çek\w+",
          r"\bcan be seen\b", r"\bin the background\b", r"\bin the foreground\b",
          r"\bon the left\b", r"\bon the right\b"]
for k in K:
    for dil, alan in (("tr", "alt_tr"), ("en", "alt_en")):
        m = k.get(alan) or ""
        for kalip in TAHLIL:
            if re.search(kalip, m, re.I):
                hata.append(f"5 · {k['_kimlik']}/{dil} kareyi tarif ediyor: {m[:60]}")

# 6 · HER ALTYAZININ DAYANAĞI VAR
for k in K:
    if not k.get("_dayanak"):
        hata.append(f"6 · {k['_kimlik']} altyazısının dayanağı yazılmamış")
    if k["_kimlik"] not in ALT:
        hata.append(f"6 · {k['_kimlik']} galeri_altyazilar.json'da yok")

# 7 · BÖLÜM GÖRSELLERİYLE ÇAKIŞMA YOK
# Kullanıcı kararı: "diğer görselleri koruyalım ancak FAZLASINI bulup"
# galeriye koyalım. Galeri bölüm görselini tekrar ederse "fazlası" olmaz.
bolum_url = {v["url"] for b, v in Y["bolum_gorselleri"].items()
             if not b.startswith("_")}
for k in K:
    if k["url"] in bolum_url:
        hata.append(f"7 · {k['_kimlik']} zaten bir bölüm görseli: {k['url']}")

# 8 · GALERİ İÇİNDE TEKRAR YOK
for alan in ("url", "_kimlik"):
    degerler = [k.get(alan) for k in K]
    tekrar = {d for d in degerler if degerler.count(d) > 1}
    if tekrar:
        hata.append(f"8 · galeride tekrar eden {alan}: {sorted(tekrar)}")

# 9 · ÖBEK BİLİNEN KÜMEDEN
for k in K:
    if k.get("_obek") not in OBEKLER:
        hata.append(f"9 · {k['_kimlik']} bilinmeyen öbek: {k.get('_obek')}")

# 10 · KAYNAK SAYFASI VE LİSANS DÜRÜSTLÜĞÜ
# Kurum karesine CC rozeti TAKILMAZ. Bu kareler Commons'tan gelmiyor;
# lisans alanı kurumun kendi yayını olduğunu söylemeli.
for k in K:
    tur = k.get("_kaynak_turu")
    if not k.get("kaynak"):
        hata.append(f"10 · {k['_kimlik']} kaynak sayfası yok")
    elif tur == "commons" and "commons.wikimedia.org" not in k["kaynak"]:
        hata.append(f"10 · {k['_kimlik']} commons dedi ama kaynak {k['kaynak'][:40]}")
    elif tur == "kurum" and "turkseker.gov.tr" not in k["kaynak"]:
        hata.append(f"10 · {k['_kimlik']} kurum dedi ama kaynak {k['kaynak'][:40]}")
    elif tur == "salt" and "saltresearch.org" not in k["kaynak"]:
        hata.append(f"10 · {k['_kimlik']} salt dedi ama kaynak {k['kaynak'][:40]}")
    if tur == "kurum" and re.search(r"\bCC\b|public domain", k["lisans"], re.I):
        hata.append(f"10 · {k['_kimlik']} kurum karesine CC/PD lisansı yazılmış: "
                    f"{k['lisans']}")
    if tur == "commons" and "Türkiye Şeker" in (k["lisans"] or ""):
        hata.append(f"10 · {k['_kimlik']} commons karesine kurum lisansı yazılmış")

# 10b · SALT KARESİNİN LİSANSI NC-ND
# SALT'ın kendi şartı bu; kareye daha serbest bir lisans yazmak kaynağın
# koşulunu yok saymak olurdu.
for k in K:
    if k.get("_kaynak_turu") == "salt" and "BY-NC-ND" not in (k["lisans"] or ""):
        hata.append(f"10b · {k['_kimlik']} SALT karesi ama lisans: {k['lisans']}")

# 11 · HAM HTML VARLIĞI YOK
# Önizlemede atıf satırı "OSU Special Collections &amp; Archives" olarak
# çıktı: Commons'un Credit alanı HTML varlığı taşıyor ve ilk duz() yalnız
# etiket siliyordu. Okur &amp; görmemeli.
VARLIK = re.compile(r"&(?:[a-zA-Z]{2,8}|#\d{2,5}|#x[0-9a-fA-F]{2,5});")
for k in K:
    for alan in ("atif", "lisans", "alt_tr", "alt_en"):
        m = k.get(alan) or ""
        if VARLIK.search(m):
            hata.append(f"11 · {k['_kimlik']}/{alan} ham HTML varlığı taşıyor: {m[:60]}")

# 12 · İKİ DİLLİ EKSİKSİZ
for k in K:
    if (k.get("alt_tr") or "") == (k.get("alt_en") or ""):
        uyari.append(f"12 · {k['_kimlik']} iki dilde aynı altyazı")
for alan in ("baslik_tr", "baslik_en"):
    if not G.get(alan):
        hata.append(f"12 · galeri '{alan}' boş")

# 13 · AYNI KARE İKİ KEZ GİRMESİN — ADRESE DEĞİL, GÖRÜNTÜYE BAKARAK
#
# 8. kural adresi, 7. kural bölüm görselinin adresini sınıyordu. İkisi de
# AYNI FOTOĞRAFIN farklı dosya adıyla iki kez girmesini göremiyor. 24 Kasım
# 2026'da tam olarak bu oldu: Uşak'ın kurucuları, hisse senedi, Boğazlıyan,
# Erzurum ve Eskişehir fabrikaları hem bölüm görseliydi hem Commons'tan
# yeniden galeriye kondu; SALT'ın Etimesgut kaydında da aynı kare iki kez
# taranmıştı. On üç çift. Hiçbiri adresten görünmüyordu.
#
# Fark karması (dHash): kareyi 17×16 griye indirip komşu piksellerin
# parlaklık işaretini yazıyor. Ölçek, sıkıştırma ve küçük ton farkı
# karmayı değiştirmiyor; başka bir fotoğraf ise değiştiriyor.
def _dhash(yol, en=16):
    with Image.open(yol) as im:
        im.load()
        g = im.convert("L").resize((en + 1, en), Image.LANCZOS)
    p = list(g.getdata())
    b = 0
    for y in range(en):
        for x in range(en):
            b = (b << 1) | (p[y * (en + 1) + x] > p[y * (en + 1) + x + 1])
    return b


# 256 bitte 28: ölçülen on üç çiftin en uzağı 21, sonraki en yakın çift
# 50'nin üstünde. Arada geniş bir boşluk var, eşik oraya konuyor.
ESIK = 28
_ad = lambda u: u.rsplit("/", 1)[-1]
_kayit = [("bölüm §%s" % b, _ad(v["url"]))
          for b, v in Y["bolum_gorselleri"].items() if not b.startswith("_")]
_kayit += [(k.get("_kimlik") or "?", _ad(k["url"])) for k in K]
_karma = {}
for _et, _dosya in _kayit:
    _y = RAW / "gorseller" / _dosya
    if _y.exists():
        try:
            _karma[_et] = _dhash(_y)
        except Exception as e:
            hata.append(f"13 · {_et} okunamadı: {str(e)[:40]}")
if len(_karma) < 30:
    hata.append(f"13 · denetçi kör: yalnız {len(_karma)} kare karmalandı")
_liste = list(_karma.items())
for _i in range(len(_liste)):
    for _j in range(_i + 1, len(_liste)):
        _m = bin(_liste[_i][1] ^ _liste[_j][1]).count("1")
        if _m <= ESIK:
            hata.append(f"13 · aynı kare iki kez (fark {_m}): "
                        f"{_liste[_i][0]} ≈ {_liste[_j][0]}")

from collections import Counter
ob = Counter(k.get("_obek") for k in K)
kt = Counter(k.get("_kaynak_turu") for k in K)
print(f"  {len(K)} kare · {len(ob)} öbek · "
      + " · ".join(f"{a} {b}" for a, b in kt.items()) + " · 14 kural")
for u in uyari:
    print(f"  ! {u}")
if hata:
    print("\n  ✗ " + "\n  ✗ ".join(hata))
    sys.exit(1)
print("\n  ✓ galeri denetimi temiz")
