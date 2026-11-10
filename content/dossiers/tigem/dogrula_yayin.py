#!/usr/bin/env python3
"""TİGEM — yayın künyesini sınar. Tohumlamadan ÖNCE koşar.

ON KURAL
 1. Her bölümün (1..14) türü var ve bilinen bir tür
 2. Grafik eşlemesi grafikler.json ile ÇİFT YÖNLÜ tutuyor: yerleştirilen her
    kimlik var, var olan her grafik bir bölüme yerleşmiş
 3. HER BÖLÜMDE BİR GÖRSEL VAR — kullanıcı kuralı (3 Kasım 2026). Boş bırakılan
    bölüm hata sayılır
 4. Her görselde atıf, lisans, iki dilde altyazı ve ölçülmüş en_boy var
 5. Görsel adresleri MUTLAK — NewsArticleImage göreli yol kabul etmiyor (§2.4)
 6. en_boy 0,5 ile 2,0 arasında; dışına çıkan kare kırpılırken konusunu kaybeder
 7. Hikâye beş slayt ve HER SLAYT AYRI GÖRSEL taşıyor — kullanıcı kuralı
    (8 Kasım 2026): "her bir slayt ayrı görsel taşısın, aynı görsel her
    slaytda tekrarlanmasın"
 8. Hikâye başlıkları KISA ve DOĞRUDAN — kullanıcı kuralı: "sik gibi uzun
    cümleler kurma", "bilmece gibi başlık koyuyorsun". Sınır 60 karakter
 9. Anahtar kelimeler §8.10/1'e uyuyor: hiçbiri tek başına 'tarım' gibi her
    haberde geçecek bir sözcük değil
10. Kurum penceresi 14 gün; kapak tipografik (null) ve notu bunu söylüyor
"""
from __future__ import annotations

import json
import pathlib
import sys

KOK = pathlib.Path(__file__).parent
Y = json.loads((KOK / "yayin.json").read_text(encoding="utf-8"))
G = json.loads((KOK / "grafikler.json").read_text(encoding="utf-8"))["grafikler"]
hata: list[str] = []

BOLUM = [str(i) for i in range(1, 15)]
TURLER = {"anlati", "belge", "veri", "akis"}
COK_GENEL = {"tarım", "tarim", "çiftçi", "tohum", "buğday", "devlet", "kurum"}

# 1 — bölüm türleri
for b in BOLUM:
    t = Y["bolum_turleri"].get(b)
    if t not in TURLER:
        hata.append(f"bölüm {b}: tür yok ya da bilinmiyor ({t!r})")

# 2 — grafik eşlemesi çift yönlü
yerlesen: dict[str, str] = {}
for b, liste in Y["bolum_grafikleri"].items():
    if b.startswith("_"):
        continue
    if b not in BOLUM:
        hata.append(f"bolum_grafikleri: '{b}' diye bir bölüm yok")
        continue
    for gid in liste:
        if gid not in G:
            hata.append(f"bölüm {b}: '{gid}' grafikler.json'da yok")
        elif gid in yerlesen:
            hata.append(f"'{gid}' iki bölüme birden konmuş: {yerlesen[gid]} ve {b}")
        else:
            yerlesen[gid] = b
for gid in G:
    if not gid.startswith("_") and gid not in yerlesen:
        hata.append(f"'{gid}' hiçbir bölüme yerleşmemiş — çizilmez")

# 3-6 — görseller
GOR = Y.get("bolum_gorselleri", {})
for b in BOLUM:
    g = GOR.get(b)
    if not isinstance(g, dict):
        hata.append(f"bölüm {b}: GÖRSEL YOK — her bölümde bir görsel olacak (kullanıcı kuralı)")
        continue
    for alan in ("url", "atif", "lisans", "alt_tr", "alt_en", "en_boy"):
        if not g.get(alan):
            hata.append(f"bölüm {b} görseli: '{alan}' boş")
    u = g.get("url", "")
    if not u.startswith("https://"):
        hata.append(f"bölüm {b} görseli: adres mutlak değil ({u!r})")
    eb = g.get("en_boy")
    if isinstance(eb, (int, float)) and not (0.5 <= eb <= 2.0):
        hata.append(f"bölüm {b} görseli: en_boy {eb} — 0,5–2,0 kıskacının dışında")
    if not g.get("_commons"):
        hata.append(f"bölüm {b} görseli: Commons sayfası yazılmamış")

# 7-8 — hikâye
H = Y.get("hikaye", {})
slaytlar = H.get("slaytlar", [])
if len(slaytlar) != 5:
    hata.append(f"hikâye {len(slaytlar)} slayt — beş olmalı")
gorseller = [s.get("gorsel") for s in slaytlar]
if len(set(g for g in gorseller if g)) != len(slaytlar):
    hata.append(f"hikâye slaytları aynı görseli tekrarlıyor: {gorseller}")
for i, s in enumerate(slaytlar, 1):
    for alan in ("ust", "baslik", "gorsel"):
        if not s.get(alan):
            hata.append(f"slayt {i}: '{alan}' boş")
    b = s.get("baslik", "")
    if len(b) > 60:
        hata.append(f"slayt {i}: başlık {len(b)} karakter — 60 sınırı, kısa ve doğrudan olacak")
    if b.endswith("?"):
        hata.append(f"slayt {i}: başlık soru — bilmece değil, cümle kurulacak")

# 9 — anahtar kelimeler
for ak in Y.get("anahtar_kelimeler", []):
    if ak.strip().lower() in COK_GENEL:
        hata.append(f"anahtar kelime '{ak}' çok genel — her haberde geçer (§8.10/1)")

# 10 — pencere ve kapak
if Y["pencere"]["gun"] != 14:
    hata.append(f"kurum penceresi 14 gün olmalı, {Y['pencere']['gun']} yazılmış")
if Y.get("kapak") is not None:
    hata.append("kapak null değil — bu dizide kurum kapağı TİPOGRAFİK (§8.4, §8.8)")
if "_kapak_notu" not in Y:
    hata.append("kapak null ama sebebi yazılmamış")
if Y.get("tur") != "kurum" or Y.get("edition") != 6:
    hata.append(f"künye tutmuyor: tur={Y.get('tur')} edition={Y.get('edition')}")

if hata:
    print("YAYIN KÜNYESİ KİLİTLENMEDİ:", file=sys.stderr)
    for h in hata:
        print("  ✗", h, file=sys.stderr)
    sys.exit(1)

print(f"yayın künyesi kilitlendi · {len(BOLUM)} bölüm · {len(yerlesen)} grafik yerleşti · "
      f"{len([b for b in BOLUM if b in GOR])} görsel · {len(slaytlar)} slayt · 10 kuralın 10'u geçti")
