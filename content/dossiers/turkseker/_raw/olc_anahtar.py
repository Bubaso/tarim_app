#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Anahtar kelime adaylarını GERÇEK HABERE karşı ölçer (§8.10/1).

Eşleşme kuralı dosya hattının kendi kuralıdır: terim_geciyor, yani
\\m TERİM \\M (sözcük sınırı), büyük/küçük harf duyarsız. Puan eşiği 2 —
yani başlık, seo_keywords, özet ya da spot. Gövde (içerik) sayılmaz.

TUZAK: 'şeker' tek başına Türkçe haberin en sık kelimelerinden
(Şeker Bayramı, kan şekeri, şeker hastalığı). Ziraat dosyasında aynı
hata yaşanmıştı: 'Ziraat' beş başlıkta geçiyordu ve beşi de Ziraat ODASI.
"""
import glob, json, re, sys, unicodedata

ADAYLAR = [
    "TÜRKŞEKER", "Türkiye Şeker Fabrikaları", "şeker pancarı", "pancar üreticisi",
    "şeker kotası", "Alpullu", "nişasta bazlı şeker", "Şeker Kurumu",
    # Sınanıp elenmesi beklenenler — ölçüm göstersin diye listede:
    "şeker", "pancar", "Şeker Fabrikası",
]

KAYIT = []
for f in sorted(glob.glob("/tmp/ts_olcum/*.json")):
    KAYIT += json.load(open(f, encoding="utf-8"))
if not KAYIT:
    sys.exit("✗ ölçülecek haber yok — önce veriyi çek")


def kucult(s):
    """TÜRKÇE KÜÇÜLTME TUZAĞI: lower() 'I' harfini 'i' yapıyor, Türkçede 'ı'.
    Karşılaştırma iki yanda da aynı eşlemeyi kullanıyor."""
    return (s or "").replace("I", "ı").replace("İ", "i").lower()


def geciyor(metin, terim):
    if not metin:
        return False
    m = unicodedata.normalize("NFC", kucult(metin))
    t = unicodedata.normalize("NFC", kucult(terim))
    return re.search(rf"(?<![0-9a-zçğıöşü]){re.escape(t)}(?![0-9a-zçğıöşü])", m) is not None


sonuc = {}
for terim in ADAYLAR:
    baslik = ozet = seo = 0
    ornek = []
    for a in KAYIT:
        b = geciyor(a.get("title"), terim)
        s = any(geciyor(k, terim) for k in (a.get("seo_keywords") or []))
        o = geciyor(a.get("summary"), terim) or geciyor(a.get("spot"), terim)
        if b:
            baslik += 1
        if s:
            seo += 1
        if o:
            ozet += 1
        if (b or s or o) and len(ornek) < 3:
            ornek.append((a.get("title") or "")[:72])
    sonuc[terim] = {"baslik": baslik, "seo": seo, "ozet_spot": ozet,
                    "toplam_eslesme": sum(1 for a in KAYIT
                                          if geciyor(a.get("title"), terim)
                                          or any(geciyor(k, terim) for k in (a.get("seo_keywords") or []))
                                          or geciyor(a.get("summary"), terim)
                                          or geciyor(a.get("spot"), terim)),
                    "ornekler": ornek}

print(f"  {len(KAYIT):,} yayımlanmış habere karşı ölçüldü\n")
print(f"  {'terim':<28} {'başlık':>7} {'seo':>5} {'özet':>6} {'toplam':>7}")
for t, v in sonuc.items():
    print(f"  {t:<28} {v['baslik']:>7} {v['seo']:>5} {v['ozet_spot']:>6} {v['toplam_eslesme']:>7}")
print("\n  örnekler:")
for t, v in sonuc.items():
    if v["ornekler"]:
        print(f"    {t}:")
        for o in v["ornekler"]:
            print(f"      · {o}")
json.dump({"_olcum": f"{len(KAYIT)} yayımlanmış haber", "_kural": "terim_geciyor · eşik 2",
           "sonuc": sonuc}, open("anahtar_olcum.json", "w", encoding="utf-8"),
          ensure_ascii=False, indent=2)
