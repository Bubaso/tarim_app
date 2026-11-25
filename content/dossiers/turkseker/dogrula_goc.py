#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Beklemedeki göçlerin sağlamaları içerikle tutuyor mu.

NEDEN VAR. Göçlerin içindeki `if n <> 22` gibi sağlamalar ELLE yazılıyor ve
içerik her değiştiğinde bayatlıyor. 24 Kasım 2026'da iki kez oldu: bölüm
sayısı 29'dan 22'ye indi, galeri 173'ten 167'ye indi, sağlamalar eski
sayılarda kaldı. Bayat sağlama iki yönden de zararlı — doğru içerikte
düşer, yanlış içerikte geçer.

Burada göç dosyaları OKUNUYOR, çalıştırılmıyor. Beklenen sayılar
yayin.json ve galeri.json'dan geliyor.
"""
import json
import pathlib
import re
import sys

KOK = pathlib.Path(__file__).parent
BEK = KOK / "beklemede"
Y = json.loads((KOK / "yayin.json").read_text(encoding="utf-8"))
G = json.loads((KOK / "_raw" / "galeri.json").read_text(encoding="utf-8"))

BOLUM = len([n for n in Y["_bolum_basliklari"] if not n.startswith("_")])
KARE = len(G["kareler"])
GRAFIK = len(json.loads(
    (KOK / "grafikler.json").read_text(encoding="utf-8"))["grafikler"])

hata = []
MIG = KOK.parent.parent.parent / "supabase" / "migrations"

# GÖÇLER İKİ YERDE OLABİLİR. Onay öncesi beklemede/ altında dururlar; onay
# verilip taşındıklarında supabase/migrations/ altına geçerler ve orada da
# sağlamaları İÇERİKLE TUTMAYA DEVAM ETMELİ — taşınmak denetimi bitirmiyor.
ADLAR = ["20261123140000_dossier_bolum_turu_galeri.sql",
         "20261123150000_turkseker_icerik_draft.sql",
         "20261123151000_dosya_devri_turkseker.sql"]
gocler = sorted(BEK.glob("*.sql"))
tasindi = False
if not gocler:
    gocler = sorted(p for p in (MIG / a for a in ADLAR) if p.exists())
    tasindi = bool(gocler)
if not gocler:
    sys.exit("✗ göçler ne beklemede/ ne migrations/ altında — nerede?")

# 1 · BÖLÜM SAYISI. Her göçteki `<> N then` sağlamalarından bölüm sayısına
#     bakanlar, metindeki bölüm sayısını söylemeli.
bulunan_bolum, bulunan_kare, bulunan_grafik = [], [], []
for g in gocler:
    t = g.read_text(encoding="utf-8")
    for m in re.finditer(r"bölüm sayısı [^\n]*?<> (\d+) then|"
                         r"if n <> (\d+) then\s*\n\s*raise exception 'Bölüm sayısı (\d+)",
                         t):
        pass
    # Bölüm sayısı sağlamaları: metinde 'bölüm sayısı' ya da 'Bölüm sayısı'
    # geçen raise satırının hemen üstündeki karşılaştırma.
    for m in re.finditer(r"if n <> (\d+) then\s*\n\s*raise exception '([^']*)'", t):
        sayi, ileti = int(m.group(1)), m.group(2)
        if "ölüm sayısı" in ileti:
            bulunan_bolum.append((g.name, sayi))
    for m in re.finditer(r"galeri,kareler[^\n]*\n[^\n]*<> (\d+) then", t):
        bulunan_kare.append((g.name, int(m.group(1))))
    for m in re.finditer(r"jsonb_object_keys\(charts\)\) = (\d+)", t):
        bulunan_grafik.append((g.name, int(m.group(1))))

if not bulunan_bolum:
    hata.append("1 · hiçbir göçte bölüm sayısı sağlaması yok — denetçi kör")
for ad, sayi in bulunan_bolum:
    if sayi != BOLUM:
        hata.append("1 · %s bölüm sayısını %d diyor, metinde %d" % (ad, sayi, BOLUM))

# 2 · GALERİ KARESİ
if not bulunan_kare:
    hata.append("2 · hiçbir göçte galeri kare sağlaması yok — denetçi kör")
for ad, sayi in bulunan_kare:
    if sayi != KARE:
        hata.append("2 · %s galeriyi %d kare diyor, galeri.json %d"
                    % (ad, sayi, KARE))

# 3 · GRAFİK SAYISI
for ad, sayi in bulunan_grafik:
    if sayi != GRAFIK:
        hata.append("3 · %s grafik sayısını %d diyor, grafikler.json %d"
                    % (ad, sayi, GRAFIK))

# 4 · GÖÇLER migrations/ ALTINA KAÇMASIN. Beklemede duran bir göç oraya
#     taşınırsa ilgisiz bir `db push` onu onaysız uygular. 24 Kasım'da
#     tam bu oldu.
#     JOKERLE ARANMIYOR. İlk hâli "*turkseker*" arıyordu ve dosyayla
#     ilgisi olmayan, aylar önce uygulanmış iki göçü (ilan adresi, ilan
#     detayı) yakaladı. Aranan şey beklemede duran dosyaların TAM ADI.
bekleyen_adlar = {p.name for p in gocler}
kacan = sorted(p.name for p in MIG.glob("*.sql") if p.name in bekleyen_adlar)
if kacan and not tasindi:
    hata.append("4 · onaysız göç supabase/migrations/ altında: " + ", ".join(kacan))

# 5 · DAMGA SIRASI. Kısıt göçü içerik göçünden ÖNCE gelmeli.
adlar = [p.name for p in gocler]
kisit = [a for a in adlar if "bolum_turu_galeri" in a]
icerik = [a for a in adlar if "icerik_draft" in a]
if kisit and icerik and kisit[0] >= icerik[0]:
    hata.append("5 · kısıt göçünün damgası içerik göçünden sonra: %s ≥ %s"
                % (kisit[0], icerik[0]))

print("  %d göç (%s) · beklenen: %d bölüm · %d kare · %d grafik · 5 kural"
      % (len(gocler), "migrations/ — onay verilmiş" if tasindi else "beklemede/",
         BOLUM, KARE, GRAFIK))
if hata:
    print("\n  ✗ " + "\n  ✗ ".join(hata))
    sys.exit(1)
print("\n  ✓ göç denetimi temiz")
