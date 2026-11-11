#!/usr/bin/env python3
"""TİGEM — metni veri katmanına ve dizinin kurallarına karşı sınar.

ON KURAL
 1. UZUNLUK TABANI — TR gövdesi (kaynakça hariç) en az 4.000 kelime. Tur 3'te
    kilitlendi: yayımlanmış kurum dosyaları TMO 3.019, Ziraat 2.941, DSİ 3.063
    kelimeydi ve §8.1 ağır dosya için ~4.000 yazıyor. Kullanıcı kuralı
    (2 Kasım 2026): dosyalar küçülerek devam etmez.
 2. BÖLÜM SAYISI VE BAŞLIKLAR — iki dilde 15 bölüm; numaralar yayin.json ile
    birebir.
 3. META CÜMLE — dosyanın nasıl yapıldığı metne giremez (§8.11). Ayrım
    fiilde: "bu dosya ... anlatıyor" meşru, "hazırlanırken" değil.
 4. REKLAM DİLİ — kurumun tanıtım dili tırnaksız kullanılamaz (§8.14.2).
 5. BÖLÜM 2'DE "PARA" YASAĞI — KULLANICI KURALI (10 Kasım 2026). Belgenin
    kendi sözcükleri var ve daha doğru: tahsisat, ödenek, fasıl, kredi hesabı,
    sermaye.
 6. "YAZIM KURALLARI" BLOĞU YASAK — KULLANICI KURALI (3 Kasım 2026): dosyanın
    içine bizi ilgilendiren teknik şeyler yazılmaz.
 7. BÜYÜK SAYILAR RAKAMLA — KULLANICI KURALI (3 Kasım 2026): "hangi salak iki
    yüz altmış beş bin yüz on altı yazar."
 8. SAYI İZİ — gövdedeki her büyük sayı data.json havuzunda olmalı.
 9. ÇİZİCİNİN TANIMADIĞI BİÇİM — `dossier_prose.dart` yalnız paragraf,
    `**kalın**`, `*italik*` ve boru işaretli tablo tanıyor. `###`, madde
    işareti, bağlantı ve kod bloğu EKRANA OLDUĞU GİBİ basılır.
10. ÖLÇÜ VE PAYDA UYARISI — 9. bölüm "dağıtım" ile "satış"ı ayırmak,
    8. bölüm sulama oranlarının paydasının farklı olduğunu söylemek zorunda.
    Yazmazlarsa okur iki rakamı toplar ve bu sessiz bir hata olur.

NEYİ KANITLAMAZ: metnin VERİ KATMANINDAN sapmadığını kanıtlar. Veri katmanı
yanlışsa metin ona sadık kalır ve bu denetim yeşil yanar; o halkayı
build_data.py'nin on doğrulaması tutuyor.

Çalıştırma: python3 dogrula_metin.py
"""
from __future__ import annotations

import json
import pathlib
import re
import sys

KOK = pathlib.Path(__file__).parent
VERI = json.loads((KOK / "data.json").read_text(encoding="utf-8"))
YAYIN = json.loads((KOK / "yayin.json").read_text(encoding="utf-8"))
hata: list[str] = []
uyari: list[str] = []

TABAN_KELIME = 4000

# ── Sayı havuzu ───────────────────────────────────────────────────────────
havuz: set[float] = set()


def topla(o) -> None:
    if isinstance(o, dict):
        for k, v in o.items():
            if not k.startswith("_"):
                topla(k)
            topla(v)
    elif isinstance(o, list):
        for x in o:
            topla(x)
    elif isinstance(o, bool):
        pass
    elif isinstance(o, (int, float)):
        havuz.add(float(o))
        havuz.add(round(float(o)))
    elif isinstance(o, str):
        for m in re.finditer(r"\d[\d.,]*", o):
            try:
                havuz.add(float(m.group().replace(".", "").replace(",", ".")))
            except ValueError:
                pass


topla(VERI)
# Ölçek dönüşümleri İKİ YÖNLÜ (§8.10/4): 3.602.455 dekar ↔ 3.602 km² ↔
# 360.245 hektar; 1.019.000 doz ↔ 1.019 bin.
for v in list(havuz):
    for k in (1000, 10, 100, 1_000_000):
        havuz.add(v / k)
        havuz.add(v * k)
    havuz.add(round(v))


def bolumler(metin: str) -> list[tuple[str, str, str]]:
    parcalar = re.split(r"(?m)^##\s+(\d+)\.\s+(.+?)\s*$", metin)
    out = []
    for i in range(1, len(parcalar), 3):
        out.append((parcalar[i], parcalar[i + 1], parcalar[i + 2]))
    return out


TR = (KOK / "metin_tr.md").read_text(encoding="utf-8")
EN = (KOK / "metin_en.md").read_text(encoding="utf-8")
btr, ben = bolumler(TR), bolumler(EN)

# ── 1. Uzunluk tabanı ─────────────────────────────────────────────────────
govde = " ".join(g for no, _, g in btr if no != "15")
kelime = len(re.findall(r"\S+", govde))
if kelime < TABAN_KELIME:
    hata.append(f"UZUNLUK · TR gövdesi {kelime} kelime, taban {TABAN_KELIME}")

# ── 2. Bölüm sayısı ve başlıklar ──────────────────────────────────────────
bekle = [k for k in YAYIN["_bolum_basliklari"] if not k.startswith("_")]
for ad, b in (("tr", btr), ("en", ben)):
    if [no for no, _, _ in b] != bekle:
        hata.append(f"[{ad}] BÖLÜM NUMARALARI · {[n for n,_,_ in b]} ≠ {bekle}")

# ── 3-4. Meta cümle ve reklam dili ────────────────────────────────────────
META = {
    "tr": ["hazırlanırken", "bu dosyayı yazarken", "doğrulanamadı", "erişilemedi",
           "bulamadık", "veri katmanı", "kaynağa ulaşılamadı", "teyit edilemedi",
           "araştırma sırasında", "bu turda", "kaynak taraması"],
    "en": ["while preparing", "could not be verified", "we could not find",
           "was not accessible", "data layer", "during our research", "we were unable"],
}
REKLAM = {
    "tr": ["en büyük", "lider", "lokomotif", "öncü rol", "dev kuruluş",
           "başarıyla", "gururla", "göz dolduran", "örnek teşkil eden"],
    "en": ["the largest", "leading role", "flagship", "successfully", "proudly",
           "pioneering role", "world class"],
}


def sade(s: str) -> str:
    return re.sub(r"\s+", " ", s.lower())


for dil, b in (("tr", btr), ("en", ben)):
    for no, _, g in b:
        if no == "15":
            continue          # kaynakça kaynak anlatır, kural listesi değil
        disari = sade(re.sub(r"[\"“”*].*?[\"“”*]", " ", g, flags=re.S))
        for k in META[dil]:
            if sade(k) in disari:
                hata.append(f"[{dil}] §{no} · META CÜMLE: '{k}'")
        for k in REKLAM[dil]:
            if re.search(r"\b" + re.escape(sade(k)), disari):
                hata.append(f"[{dil}] §{no} · REKLAM DİLİ (tırnaksız): '{k}'")

# ── 5. Bölüm 2'de "para" yasağı — İKİ DİLDE ───────────────────────────────
#
# Kullanıcı kuralı (10 Kasım 2026): "2. bölümde direk para kelimesini
# kullanma. daha başka bir ifade biçimi bul. uygunsa önce kaynak geldi, kanun
# sonra vb. olabilir."
#
# İLK SÜRÜM YALNIZCA TÜRKÇEYE BAKIYORDU ve bu bir delikti: 12 Kasım 2026'da
# ölçüldü, İngilizce §2 iki yerde "the money" diyordu ("where the money was to
# go", "how the money was spent") — yani kural Türkçede tutuluyor,
# çevirisinde çiğneniyordu. Kural bir ÜSLUP kararı; dile göre değişmez.
#
# Yasak YALNIZCA doğrudan karşılıklara konuyor. "appropriation", "funding",
# "credit", "ödenek", "kaynak" serbest — kullanıcının kendi önerdiği ifade
# biçimi bunlar.
YASAK_2 = {
    "tr": r"\bpara\w*",
    "en": r"\b(money|monies|cash)\b",
}
for dil, b in (("tr", btr), ("en", ben)):
    g2 = next((g for no, _, g in b if no == "2"), "")
    for m in re.finditer(YASAK_2[dil], g2, re.I):
        hata.append(f"[{dil}] §2 · 'PARA' YASAĞI (kullanıcı kuralı): '{m.group()}'")

# ── 6. "Yazım kuralları" bloğu ────────────────────────────────────────────
for dil, t in (("tr", TR), ("en", EN)):
    if re.search(r"(?mi)^##\s*(yazım kuralları|house rules|writing rules)", t):
        hata.append(f"[{dil}] 'Yazım kuralları' bloğu var — kullanıcı kuralı yasaklıyor")

# ── 7. Büyük sayılar rakamla ──────────────────────────────────────────────
YAZIYLA = re.compile(
    r"\b(iki|üç|dört|beş|altı|yedi|sekiz|dokuz|on|yirmi|otuz|kırk|elli|altmış|"
    r"yetmiş|seksen|doksan|yüz)\s+(bin|milyon|milyar)\b", re.I)
for no, _, g in btr:
    for m in YAZIYLA.finditer(g):
        hata.append(f"[tr] §{no} · SAYI YAZIYLA: '{m.group()}' — rakamla yazılacak")

# ── 8. Sayı izi ───────────────────────────────────────────────────────────
TR_SAYI = re.compile(r"\b\d{1,3}(?:\.\d{3})+(?:,\d+)?\b|\b\d+,\d+\b")
kacan = 0
for no, _, g in btr:
    if no == "15":
        continue
    disari = re.sub(r"\|.*?\|", " ", g)            # tablolar ayrı sınandı
    for m in TR_SAYI.finditer(disari):
        try:
            v = float(m.group().replace(".", "").replace(",", "."))
        except ValueError:
            continue
        if v < 1000:
            continue
        if not any(abs(v - h) < 0.51 for h in havuz):
            hata.append(f"[tr] §{no} · SAYI İZİ YOK: {m.group()}")
        else:
            kacan += 1

# ── 9. Çizicinin tanımadığı biçim ─────────────────────────────────────────
for dil, b in (("tr", btr), ("en", ben)):
    for no, _, g in b:
        for satir in g.split("\n"):
            s = satir.strip()
            if re.match(r"^#{3,}\s", s):
                hata.append(f"[{dil}] §{no} · ALT BAŞLIK: '{s[:40]}'")
            if re.match(r"^[-*+]\s+\S", s):
                hata.append(f"[{dil}] §{no} · MADDE İŞARETİ: '{s[:40]}'")
            if re.search(r"\[[^\]]+\]\([^)]+\)", s):
                hata.append(f"[{dil}] §{no} · BAĞLANTI: '{s[:40]}'")
            if s.startswith("```"):
                hata.append(f"[{dil}] §{no} · KOD BLOĞU")
            # ALINTI BLOĞU — bu kural ilk yazımda UNUTULDU ve metin on iki
            # satırlık alıntı bloğuyla yazıldı. `dossier_prose.dart` alıntı
            # tanımıyor; ekrana '>' işareti olduğu gibi basılırdı. Göç
            # dosyasının sağlaması yakaladı, betik yakalamadı.
            if s.startswith(">"):
                hata.append(f"[{dil}] §{no} · ALINTI BLOĞU: '{s[:40]}'")

# ── 10. Ölçü ve payda uyarısı ─────────────────────────────────────────────
# Eksik bölümde ÇÖKMEZ, hata yazar. Bir doğrulayıcının çökmesi geçmekle
# karışır: kullanıcı yığın izini görür, hangi kuralın düştüğünü görmez.
def gov(b, no):
    return next((g for n, _, g in b if n == no), None)

g9 = gov(btr, "9")
if g9 is None:
    hata.append("[tr] §9 bölümü YOK")
elif "dağıtım" not in g9 or "satış" not in g9:
    hata.append("[tr] §9 · DAĞITIM ile SATIŞ ayrımı yazılmamış")
g8 = gov(btr, "8")
if g8 is None:
    hata.append("[tr] §8 bölümü YOK")
elif "payda" not in g8.lower():
    hata.append("[tr] §8 · sulama oranlarının PAYDASININ farklı olduğu yazılmamış")
g9en = gov(ben, "9")
if g9en is None:
    hata.append("[en] §9 bölümü YOK")
elif "distribution" not in g9en.lower() or "sales" not in g9en.lower():
    hata.append("[en] §9 · distribution/sales ayrımı yazılmamış")

if hata:
    print("METİN KİLİTLENMEDİ:", file=sys.stderr)
    for h in hata:
        print("  ✗", h, file=sys.stderr)
    sys.exit(1)

enkelime = len(re.findall(r"\S+", " ".join(g for no, _, g in ben if no != "15")))
print(f"metin kilitlendi · 10 kuralın 10'u geçti")
print(f"  TR gövde   {kelime} kelime (taban {TABAN_KELIME})")
print(f"  EN gövde   {enkelime} kelime")
print(f"  bölüm      {len(btr)} / {len(ben)}")
print(f"  sayı izi   {kacan} sayı data.json'a bağlandı")
for u in uyari:
    print("  ⚠", u)
