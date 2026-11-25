#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Bölüm sırasını kronolojik ve konu bazlı olarak yeniden kurar.

Tur 9'da on üç bölüm araya girdi. Her biri YEREL olarak mantıklı bir noktaya
konmuştu ama yirmi dokuz bölüm bir DİZİ olarak okunmamıştı. Okunduğunda üç
kırık çıktı:

1. §5 → §6 → §7 → §8 üç kez ileri geri atlıyordu. §5 [1951-2001], §6 [2025],
   §7 [1990-1998], §8 [1925-2007]. Suçlu §6: bir "bugün" bölümü tarih
   omurgasının ortasına sıkışmıştı.
2. Tohum, pancardan SONRA geliyordu — oysa bölümün kendi ilk cümlesi
   "Pancarın şekere dönüşü tarlada değil, tohumda başlıyor" diyor.
3. Nişasta bazlı şeker tarla hattını kesiyordu (pancar → tohum → NBŞ →
   sözleşme → uydu). NBŞ bir kota hikâyesi; yeri kanun ve kotanın yanı.

ÇAPRAZ GÖNDERME SINANDI. Taşınan bölümlerin hiçbiri numarayla bir başka
bölüme atıf yapmıyor; §6'nın "Makine fabrikaları kurulduğunda…" açılışı ve
§7'nin "Kendi fabrikasını kurabilen bir sanayinin…" açılışı yeni yerlerinde
de geriye doğru çalışıyor.
"""
import json, pathlib, re, sys

KOK = pathlib.Path(__file__).parent.parent

# eski → yeni
ESLEME = {1: 1, 2: 2, 3: 3, 4: 4, 5: 5,
          6: 17,   # Bir fabrikanın yüzde yetmişi → "bugün" bloğuna
          7: 6,    # Özbekistan (1996-98) → genişlemenin hemen ardına
          8: 7, 9: 8,
          12: 9,   # Nişastadan gelen şeker → kotanın yanına
          11: 10,  # Tohum → pancardan ÖNCE
          10: 11,  # Pancardan şekere
          13: 12, 14: 13, 15: 14, 16: 15, 17: 16,
          18: 18, 19: 19, 20: 20, 21: 21, 22: 22, 23: 23,
          24: 24, 25: 25, 26: 26, 27: 27, 28: 28, 29: 29}

assert sorted(ESLEME) == list(range(1, 30)), "eksik eski numara"
assert sorted(ESLEME.values()) == list(range(1, 30)), "yeni numaralar birebir değil"


def bolumler(metin):
    p = re.split(r"^## (\d+)\. (.+)$", metin, flags=re.M)
    return p[0], [(int(p[i]), p[i + 1].strip(), p[i + 2].strip())
                  for i in range(1, len(p), 3)]


def yaz(bas, sirali):
    g = [bas.rstrip() + "\n\n"]
    for i, (_, baslik, govde) in enumerate(sirali, 1):
        g.append(f"## {i}. {baslik}\n\n{govde}\n\n")
    return "".join(g).rstrip() + "\n"


def siralat(metin, ad):
    bas, B = bolumler(metin)
    if len(B) != 29:
        raise SystemExit(f"✗ {ad}: {len(B)} bölüm, 29 bekleniyordu")
    yeni = sorted(B, key=lambda x: ESLEME[x[0]])
    return yaz(bas, yeni)


def main():
    for ad in ("metin_tr.md", "metin_en.md"):
        p = KOK / ad
        p.write_text(siralat(p.read_text(encoding="utf-8"), ad), encoding="utf-8")

    y = KOK / "yayin.json"
    Y = json.loads(y.read_text(encoding="utf-8"))

    def tasi(blok):
        yeni = {k: v for k, v in blok.items() if k.startswith("_")}
        for k, v in blok.items():
            if not k.startswith("_"):
                yeni[str(ESLEME[int(k)])] = v
        return {k: yeni[k] for k in sorted(
            yeni, key=lambda x: (0, 0) if x.startswith("_") else (1, int(x)))}

    for blok in ("bolum_grafikleri", "bolum_turleri", "bolum_gorselleri"):
        Y[blok] = tasi(Y[blok])

    TR = (KOK / "metin_tr.md").read_text(encoding="utf-8")
    B = {m.group(1): m.group(2).strip()
         for m in re.finditer(r"^## (\d+)\. (.+)$", TR, flags=re.M)}
    Y["_bolum_basliklari"] = {
        "_notu": Y["_bolum_basliklari"].get("_notu", "Metinden okunuyor."),
        **{k: B[k] for k in sorted(B, key=int)}}
    Y["_siralama_notu"] = (
        "24 Kasım 2026: yirmi dokuz bölüm bir dizi olarak okundu ve üç kırık "
        "düzeltildi — 'yüzde yetmiş' bölümü tarih omurgasından bugün bloğuna, "
        "Özbekistan genişlemenin ardına, tohum pancardan öne, NBŞ kotanın "
        "yanına alındı. Eşleme _raw/tur9_siralama.py/ESLEME içinde.")
    y.write_text(json.dumps(Y, ensure_ascii=False, indent=2), encoding="utf-8")

    # kunye.json'daki bolum alanı da kayıyor
    ku = KOK / "_raw" / "gorseller" / "kunye.json"
    KU = json.loads(ku.read_text(encoding="utf-8"))
    for g in KU["gorseller"].values():
        g["bolum"] = str(ESLEME[int(g["bolum"])])
    ku.write_text(json.dumps(KU, ensure_ascii=False, indent=2), encoding="utf-8")

    tasinan = [(e, n) for e, n in sorted(ESLEME.items()) if e != n]
    for e, n in tasinan:
        print(f"  §{e:>2} → §{n:<2}  {B[str(n)]}")
    print(f"\n  ✓ {len(tasinan)} bölüm taşındı · grafik/tür/görsel eşlemeleri kaydı")


main()
