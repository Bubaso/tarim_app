#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""metin_tr.md / metin_en.md denetimi — Türkşeker, Kurum Dosyası Sayı 07.

Mısır dosyasının avcılarından devralındı; iki tanesi bu diziye özgü:
§8.2'nin TANITIM tonu (iddianame dili yasak) ve kullanıcının "2. bölümde
para kelimesini kullanma" kuralı.
"""
import json, pathlib, re, sys
from decimal import Decimal, ROUND_HALF_UP

KOK = pathlib.Path(__file__).parent
D = json.loads((KOK / "data.json").read_text(encoding="utf-8"))
Y = json.loads((KOK / "yayin.json").read_text(encoding="utf-8"))
hata, uyari = [], []


def bolumler(metin):
    out = {}
    for blok in re.split(r"^## ", metin, flags=re.M)[1:]:
        bas = blok.split("\n", 1)[0]
        no = bas.split(".")[0].strip()
        out[no] = blok
    return out


METIN = {}
for dil, ad in (("tr", "metin_tr.md"), ("en", "metin_en.md")):
    y = KOK / ad
    if y.exists():
        METIN[dil] = y.read_text(encoding="utf-8")

if "tr" not in METIN:
    sys.exit("✗ metin_tr.md yok")

# ── 1 · bölüm sayısı ve başlıkları yayin.json ile tutuyor ────────────
for dil, m in METIN.items():
    b = bolumler(m)
    bekl = {k for k in Y["_bolum_basliklari"] if not k.startswith("_")}
    if set(b) != bekl:
        hata.append(f"1/{dil} · bölüm numaraları tutmuyor: {sorted(set(b) ^ bekl)}")

# ── 2 · SAYI İZİ · metindeki her ölçüm data.json'da olmalı ───────────
sayilar = set()
def topla(o):
    if isinstance(o, bool):
        return
    if isinstance(o, (int, float)):
        sayilar.add(abs(float(o)))
    elif isinstance(o, dict):
        for k, v in o.items():
            if not k.startswith("_"):
                topla(v)
    elif isinstance(o, list):
        for v in o:
            topla(v)
topla(D)
olcekli = {round(s * k, 3) for s in sayilar for k in (1, 0.001, 1000, 0.01, 100, 1e6, 1e-6)}

# Mevzuat ve belge numaraları ölçüm değildir (grafik denetimiyle aynı mantık).
OLCUM_DISI = {7103, 4634, 6747, 3923, 4083, 9315, 9316, 10279, 2000, 2008, 47, 49, 11,
              18205, 31738, 600000, 500000, 1100000}
PAZARLAMA_YILI = re.compile(r"\b(19|20)\d{2}\s*/\s*\d{2,4}\b")
# AYIN GÜNÜ ÖLÇÜM DEĞİLDİR. "26 Kasım 1926" kalıbında 26 bir tarih
# parçası; ilk koşuda avcı bunu ölçüm sanıp onlarca hata verdi.
AY = ("Ocak|Şubat|Mart|Nisan|Mayıs|Haziran|Temmuz|Ağustos|Eylül|Ekim|Kasım|Aralık"
      "|January|February|March|April|May|June|July|August|September|October"
      "|November|December")
GUN = re.compile(rf"\b\d{{1,2}}\s+(?:{AY})\b")
# "md. 47", "47'nci madde", "7103 sayılı" gibi mevzuat atıfları da ölçüm değil.
MEVZUAT = re.compile(r"\b\d+\s*(?:sayılı|'?n?[ciıu]?ncı madde|'?[ıiu]?nc[iı] madde|\. madde)")

# BİLEŞİK SAYI BİRLEŞTİRİLİYOR. Metin "1 milyon 176 bin ton" diye
# yazıyor; ham kalıp bunu 1 ve 176 diye iki parçaya bölüp 176'yı
# izlenemeyen bir ölçüm sanıyordu.
BILESIK = re.compile(r"\b(\d+)\s+milyon\s+(\d+)\s+bin\b")


def birlestir(metin):
    return BILESIK.sub(lambda m: str(int(m.group(1)) * 1000 + int(m.group(2))) + " bin", metin)


for dil, m in METIN.items():
    # KAYNAKÇA TARANMIYOR. Oradaki "Tablo 36", "Tablo 16, 17, 18" belge
    # numarası; ölçüm değil ve data.json'da bulunmaları beklenmez.
    # KAYNAKCA SON BOLUM; numarasi sabit degil. Kalip "15" diye cakiliydi:
    # Tur 9'da on uc bolum araya girince 15'TEN SONUNA KADAR her sey
    # siliniyordu — yani on dort bolum sessizce sinanmiyordu.
    _son = max((int(x) for x in re.findall(r"^## (\d+)\.", m, flags=re.M)),
               default=0)
    govde = re.sub(rf"^## {_son}\..*", "", m, flags=re.M | re.S)
    govde = birlestir(re.sub(r"^#.*$", "", govde, flags=re.M))
    for kalip in (PAZARLAMA_YILI, GUN, MEVZUAT):
        govde = kalip.sub(" ", govde)
    for ham in re.findall(r"\d[\d.,]*", govde):
        t = ham.rstrip(".,")
        t = t.replace(".", "").replace(",", ".") if dil == "tr" else t.replace(",", "")
        try:
            v = abs(float(t))
        except ValueError:
            continue
        if v < 10 or 1900 <= v <= 2100 or v in OLCUM_DISI or int(v) in OLCUM_DISI:
            continue
        if not any(abs(v - o) < max(0.05, v * 0.0006) for o in olcekli):
            hata.append(f"2/{dil} · metinde '{ham}' var, data.json'da yok")

# ── 3 · SÜREÇ DİLİ YASAK (§8.2) ──────────────────────────────────────
SUREC = {
    "tr": [r"\bbu dosya\w*\b", r"\belimizdeki\b", r"\bbulunamad\w+\b", r"\bdoğrulanamad\w+\b",
           r"\bkaynak cevap vermedi\b", r"\btaranan\b", r"\bbu taramada\b",
           r"\bveri notu\b", r"\baçık soru\w*\b", r"\byazarken\b"],
    "en": [r"\bthis dossier\b", r"\bwe could not\b", r"\bnot found in\b", r"\bunverified\b",
           r"\bdata note\b", r"\bopen question\w*\b"],
}
for dil, m in METIN.items():
    # KAYNAKCA SON BOLUM; numarasi sabit degil. Kalip "15" diye cakiliydi:
    # Tur 9'da on uc bolum araya girince 15'TEN SONUNA KADAR her sey
    # siliniyordu — yani on dort bolum sessizce sinanmiyordu.
    _son = max((int(x) for x in re.findall(r"^## (\d+)\.", m, flags=re.M)),
               default=0)
    govde = re.sub(rf"^## {_son}\..*", "", m, flags=re.M | re.S)   # kaynakca haric
    for kalip in SUREC[dil]:
        for mt in re.finditer(kalip, govde, re.I):
            hata.append(f"3/{dil} · süreç dili: …{govde[max(0,mt.start()-40):mt.end()+30]}…")

# ── 4 · İDDİANAME DİLİ (§8.2 — dizi bir kez bu yüzden durduruldu) ────
IDDIA = {
    "tr": [r"\bskandal\w*\b", r"\bbaşarısız\w*\b", r"\bihmal\w*\b", r"\bsorumlu tut\w+",
           r"\bhesap ver\w+", r"\bdenetim bulgu\w*", r"\beleştir\w+", r"\bsuçla\w+",
           r"\bçelişki\w*\b", r"\bgizle\w+", r"\bsaklan\w+"],
    "en": [r"\bscandal\w*\b", r"\bfail(ed|ure)\b", r"\bnegligen\w+", r"\baccountab\w+",
           r"\baudit finding\w*", r"\bcriticis\w+", r"\bcontradict\w+", r"\bconceal\w+"],
}
for dil, m in METIN.items():
    for kalip in IDDIA[dil]:
        for mt in re.finditer(kalip, m, re.I):
            hata.append(f"4/{dil} · iddianame dili: …{m[max(0,mt.start()-40):mt.end()+30]}…")

# ── 5 · KULLANICI KURALI: 2. bölümde 'para' kelimesi yok ─────────────
for dil, m in METIN.items():
    b2 = bolumler(m).get("2", "")
    kalip = r"\bpara\w*\b" if dil == "tr" else r"\bmoney\b"
    for mt in re.finditer(kalip, b2, re.I):
        hata.append(f"5/{dil} · 2. bölümde yasak kelime: …{b2[max(0,mt.start()-40):mt.end()+25]}…")

# ── 6 · yüzde işareti TR'de ÖNDE ─────────────────────────────────────
for mt in re.finditer(r"\d\s*%", METIN["tr"]):
    hata.append(f"6/tr · yüzde işareti arkada: …{METIN['tr'][mt.start()-25:mt.end()+10]}…")
if "en" in METIN:
    for mt in re.finditer(r"%\s*\d", METIN["en"]):
        hata.append(f"6/en · yüzde işareti önde: …{METIN['en'][mt.start()-25:mt.end()+10]}…")

# ── 7 · rakamlar basamakla yazılmalı (kullanıcı kararı) ──────────────
# KURAL DARALTILDI. İlk kalıp "milyon" sözcüğünü de arıyordu ve
# "22,4 milyon ton" gibi RAKAMLA yazılmış her ölçümü yakalıyordu —
# 25 uyarının 19'u yanlış pozitifti. Şimdi yalnız sayının KENDİSİ
# yazıyla yazılmışsa, yani bir ölçü birimi izliyorsa yakalanıyor.
ONLUK = "on|yirmi|otuz|kırk|elli|altmış|yetmiş|seksen|doksan"
BIRLER = "bir|iki|üç|dört|beş|altı|yedi|sekiz|dokuz"
BIRIM = "yıl|ay|gün|saat|ton|kat|kişi|fabrika|şirket|bin|milyon|lira|hektar|dekar"
YAZI = rf"(?<!\d)\b(?:{ONLUK})(?:\s+(?:{BIRLER}))?\s+(?:{BIRIM})\b"
# BAŞLIKLAR MUAF. Dizinin kendi başlıkları sayıyı yazıyla taşıyor
# (TİGEM: "Ülkenin tohumu: doksandan yirmiye", "arazinin onda biri").
# Kural GÖVDE metni için; başlık satırları çıkarılıyor.
_govde_tr = re.sub(r"^#.*$", "", METIN["tr"], flags=re.M)
for mt in re.finditer(YAZI, _govde_tr):
    uyari.append(f"7/tr · rakam yazıyla: …{_govde_tr[max(0,mt.start()-35):mt.end()+20]}…")

# ── 8 · her bölüm en az bir paragraf taşıyor ─────────────────────────
for dil, m in METIN.items():
    for no, blok in bolumler(m).items():
        govde = blok.split("\n", 1)[1].strip() if "\n" in blok else ""
        if len(govde.split()) < 40:
            hata.append(f"8/{dil} · §{no} çok kısa ({len(govde.split())} kelime)")

# ── 9 · kaynakça var ve kaynak sayıyor ───────────────────────────────
# Kaynakça SON bölüm; numarası sabit değil. 15'e çakılıydı ve galeri
# araya girip kaynakçayı 16'ya ittiğinde kural boş bölüme bakıp düştü.
for dil, m in METIN.items():
    B = bolumler(m)
    son = B.get(max(B, key=int), "") if B else ""
    if son.count("- **") < 4:
        hata.append(f"9/{dil} · kaynakça dörtten az kalem taşıyor")

# ── 10 · TR ve EN bölüm bölüm aynı yapıda ────────────────────────────
if "en" in METIN:
    btr, ben = bolumler(METIN["tr"]), bolumler(METIN["en"])
    for no in sorted(btr, key=int):
        if no not in ben:
            hata.append(f"10 · §{no} İngilizcede yok")
            continue
        o = len(ben[no].split()) / max(1, len(btr[no].split()))
        if not 0.85 <= o <= 1.7:
            uyari.append(f"10 · §{no} uzunluk oranı {o:.2f} (EN/TR) — beklenen 0,85-1,70")

kelime = {d: len(re.sub(r"^#.*$", "", m, flags=re.M).split()) for d, m in METIN.items()}
print("  " + " · ".join(f"{d.upper()} {k:,} kelime" for d, k in kelime.items()))
print(f"  {len(bolumler(METIN['tr']))} bölüm · 10 kural")
for u in uyari[:6]:
    print(f"  ⚠ {u}")
if len(uyari) > 6:
    print(f"  ⚠ … ve {len(uyari)-6} uyarı daha")
if hata:
    print("\n  ✗ " + "\n  ✗ ".join(hata[:16]))
    if len(hata) > 16:
        print(f"  ✗ … ve {len(hata)-16} hata daha")
    sys.exit(1)
print("\n  ✓ denetim temiz")
