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

# 11 — ALTYAZI KÜNYEDİR, TAHLİL DEĞİL (kullanıcı kuralı, iki kez verildi)
#
# Kural: altyazı fotoğrafın NE OLDUĞUNU söyler — konu, yer, tarih. Kadrajda
# ne görüldüğünü ANLATMAZ. 12 Kasım 2026'da on dört altyazının tamamı bu
# yüzden yeniden yazıldı; üslup hatasının yanında dört maddi hata çıkmıştı ve
# hepsi kareye bakıp çıkarım yapmaktan geliyordu (ayrıntı: yayin.json
# _altyazi_duzeltmesi_12_kasim).
#
# Bu kuralı makineyle sınamanın yolu şu üç ölçü. Hiçbiri "iyi yazılmış"ı
# ölçmüyor; tahlile kayan yazının BIRAKTIĞI İZLERİ yakalıyorlar.

# (a) Kadraj sözcükleri. Altyazı yeri söyler, karedeki yerleşimi söylemez.
KADRAJ = [
    "arkada", "arka planda", "önde", "ön planda", "yakın planda", "kadrajda",
    "solda", "sağda", "altta", "üstte", "ortada", "görülüyor", "görünüyor",
    "foreground", "background", "behind them", "in the foreground",
    "in the background", "on the left", "on the right",
]
# (b) Görünüş envanteri. Rengi, deseni, kıyafeti — hiçbiri künye bilgisi değil.
GORUNUS = [
    "rengi", "renkli", "desenli", "tüylü", "giysi", "giysisiyle", "şapkalı",
    "takımlı", "parmaklıklı", "çatılı", "patterned", "coloured", "colored",
    "wearing", "-coloured", "sun canopy",
]
# (c) Tarih zorunluluğu. Künyenin olmazsa olmazı. Kaynak tarihi vermiyorsa
#     altyazı bunu AÇIKÇA yazacak — sessizce atlamayacak.
import re as _re
TARIHSIZ_MAZERET = ("tarihi kayıtlı değil", "tarihi bilinmiyor",
                    "date is not recorded", "date is unknown")
ALTYAZI_TAVAN = 230

for b in BOLUM:
    g = GOR.get(b)
    if not isinstance(g, dict):
        continue
    for dil, alan in (("tr", "alt_tr"), ("en", "alt_en")):
        a = (g.get(alan) or "")
        d = a.lower()
        for k in KADRAJ:
            if k in d:
                hata.append(f"bölüm {b} altyazı [{dil}]: KADRAJ SÖZCÜĞÜ '{k}' — "
                            f"altyazı fotoğrafın ne olduğunu söyler, karede neyin "
                            f"nerede durduğunu söylemez (kullanıcı kuralı)")
        for k in GORUNUS:
            if k in d:
                hata.append(f"bölüm {b} altyazı [{dil}]: GÖRÜNÜŞ ENVANTERİ '{k}' — "
                            f"renk, desen, kıyafet künye bilgisi değil (kullanıcı kuralı)")
        if not _re.search(r"\b(1[89]\d\d|20\d\d)\b", a) \
           and not any(m in d for m in TARIHSIZ_MAZERET):
            hata.append(f"bölüm {b} altyazı [{dil}]: TARİH YOK — künye tarih ister; "
                            f"kaynak vermiyorsa altyazı bunu açıkça yazacak")
        if len(a) > ALTYAZI_TAVAN:
            hata.append(f"bölüm {b} altyazı [{dil}]: {len(a)} karakter — "
                        f"{ALTYAZI_TAVAN} tavanı aşıldı; künye bu kadar uzun olmaz, "
                        f"tahlile kaymış olabilir")

# 13 — slaytlarda da "para" yasağı (kullanıcı kuralı, 10 Kasım 2026)
#
# Kural metnin 2. bölümü için verildi ama bir ÜSLUP kararı: ana sayfadaki
# baloncuk da aynı konuyu aynı sözcükle anlatmamalı. 12 Kasım 2026'da ilk
# slaytın İngilizcesi "THE MONEY CAME FIRST" diyordu — Türkçesi kuralı
# tutuyor, çevirisi çiğniyordu. Aynı delik metin tarafında da vardı
# (dogrula_metin.py 5. kural o gün iki dile açıldı).
import re as _re2
PARA_YASAK = _re2.compile(r"\b(para\w*|money|monies|cash)\b", _re2.I)
for i, sl in enumerate(slaytlar, 1):
    for alan in ("ust", "ust_en", "baslik", "baslik_en"):
        m = PARA_YASAK.search(str(sl.get(alan, "")))
        if m:
            hata.append(f"slayt {i} · {alan}: 'PARA' YASAĞI (kullanıcı kuralı) — "
                        f"'{m.group()}'; ödenek/kaynak/appropriation kullanılacak")

# 15 — SLAYT ÇİZİCİNİN İSTEDİĞİ ALANLARI TAŞIMALI
#
# 12 Kasım 2026: beş slaytın beşinde de `rakam` ve `etiket` YOKTU ve bunun
# sonucu sessizdi. dosya_hikayeleri.py slaytı şöyle eliyor:
#
#     slaytlar = [s for s in slaytlar if s["headline"] and s["big_stat_value"]]
#
# `big_stat_value` = slaytın `rakam` alanı. Beşi de elenince betik
# "tigem: 0 slayt — en az 3 gerekiyor, atlanıyor" deyip GEÇTİ, hata vermedi.
# Devirden sonra ana sayfada dosyayı tanıtan baloncuk hiç çıkmayacaktı ve
# bunu fark etmenin tek yolu betiğin çıktısını okumaktı.
#
# Sınırlar çizicinin kendi sınırları (dosya_hikayeleri.py SINIR sözlüğü).
# Aşan metin uyarıyla kırpılıyor ama kırpılmış bir etiket cümleyi yarıda
# bırakıyor; burada hata sayılıyor ki kaynak düzeltilsin.
CIZICI_SINIR = {"ust": 24, "ust_en": 24, "baslik": 60, "baslik_en": 60,
                "rakam": 12, "rakam_en": 12, "etiket": 48, "etiket_en": 48}
for i, sl in enumerate(slaytlar, 1):
    for alan in ("rakam", "etiket", "rakam_en", "etiket_en"):
        if not str(sl.get(alan, "")).strip():
            hata.append(f"slayt {i}: '{alan}' BOŞ — dosya_hikayeleri.py bu "
                        f"slaytı eler ve hikâye hiç yayımlanmaz")
    for alan, sinir in CIZICI_SINIR.items():
        v = str(sl.get(alan, ""))
        if len(v) > sinir:
            hata.append(f"slayt {i} · {alan}: {len(v)} karakter — çizici "
                        f"{sinir}'e kırpar, cümle yarıda kalır")

# 16 — pencere ve kapak
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
      f"{len([b for b in BOLUM if b in GOR])} görsel · {len(slaytlar)} slayt · 16 kuralın 16'sı geçti")
