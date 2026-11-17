#!/usr/bin/env python3
"""
Yapay Zeka ve Dijital Tarım — §29 Sözlük üreticisi (karar 14).

    python3 sozluk_uret.py            # yazar
    python3 sozluk_uret.py --denetle  # yazmaz; dosyalar güncel değilse çıkış 1
    python3 sozluk_uret.py --baglam [--en] [kimlik ...]
                                      # balonun açıldığı her yeri çevresiyle yazar

Tanımlar `_raw/sozluk.json`da elle yazılıyor; dayanakları `_raw/b29_kaynaklar.json`
kaydında birebir alıntıyla. Bu betik iki şeyi üretiyor:

  1. `bolumler/29-sozluk.{tr,en}.md` — sözlük sayfası. Her terimin yanında
     kaynağı ve geçtiği başlıklar.
  2. (dart_uret.py) aynı tanımlar `yz_sozluk.g.dart`a gömülüyor; metin içi
     balon onları gösteriyor.

EŞLEŞTİRME, Dart'taki `yzAyristir` + `yzTerimleriBul` ile BİREBİR aynı
(test/yz_bolum_test.dart iki tarafın aynı başlıkları bulduğunu sınıyor):
küçük harfli desen kelime başında aranır (Türkçe küçültme: I → ı, İ → i) ve
kelimenin sonuna uzanır; `=` önekli desen büyük-küçük harfe duyarlı ve tam
kelime; kalın/italik parçanın, adresin ve başka bir terimin işaretinin içi
sayılmaz; terim sayfada bir kez. "Geçtiği başlıklar" balonun gerçekten
açıldığı başlıklardır.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

RAW = Path(__file__).resolve().parent
BOLUMLER = RAW.parent / "bolumler"
SOZLUK = RAW / "sozluk.json"
KAYIT = RAW / "b29_kaynaklar.json"
ALFABE = "abcçdefgğhıijklmnoöpqrsştuüvwxyz"
ALFABE_EN = "abcdefghijklmnopqrstuvwxyz"

BICIM = re.compile(r"\*\*(.+?)\*\*|\*(.+?)\*")
ADRES = re.compile(r'https?://[^\s<>"]+')
TIRNAK = re.compile(r'"[^"]*"|“[^”]*”')
HARF = re.compile(r"[^\W_]", re.UNICODE)

# Terim balonu bu başlıkların sayfasında yok (yz_baslik_ekrani.dart ile aynı).
SOZLUKSUZ = {29, 30}


def kucult(s: str, en: bool) -> str:
    """Uzunluğu koruyan küçültme. Türkçe: I → ı, İ → i. İngilizce metinde de
    "İMECE" gibi özel adlar var: İ önce i'ye iner, yoksa .lower() onu iki
    karaktere (i + birleşen nokta) açar ve konumlar kayar."""
    return s.replace("İ", "i").lower() if en else s.replace("I", "ı").replace("İ", "i").lower()


def _harf_mi(m: str, i: int) -> bool:
    return 0 <= i < len(m) and bool(HARF.match(m[i]))


def adres_kirp(a: str) -> str:
    """yzAdresiKirp ile aynı: sondaki noktalama ve kapanmamış parantez adrese
    dahil değil."""
    while a:
        son = a[-1]
        if son in ".,;:!?":
            a = a[:-1]
        elif son == ")" and a.count("(") < a.count(")"):
            a = a[:-1]
        else:
            break
    return a


def adresler(metin: str) -> list[tuple[int, int]]:
    bicimli = [(m.start(), m.end()) for m in BICIM.finditer(metin)]
    cikti = []
    for m in ADRES.finditer(metin):
        son = m.start() + len(adres_kirp(m.group(0)))
        if any(m.start() < b and son > a for a, b in bicimli):
            continue
        cikti.append((m.start(), son))
    return cikti


def bloklar(md: str) -> list[tuple[str, str]]:
    """yzAyristir ile aynı bölme: (tür, metin). Tür: ozet, altBaslik,
    paragraf, tablo (tablonun metni boş)."""
    out, paragraf = [], []
    satirlar = md.replace("\r\n", "\n").split("\n")

    def kapat():
        if paragraf:
            out.append(("paragraf", " ".join(paragraf)))
            paragraf.clear()

    i = 0
    while i < len(satirlar):
        t = satirlar[i].strip()
        if not t:
            kapat(); i += 1
        elif t.startswith("# "):
            kapat(); i += 1
        elif t.startswith("## "):
            kapat(); out.append(("altBaslik", t[3:].strip())); i += 1
        elif t.startswith(">"):
            kapat()
            parca = []
            while i < len(satirlar) and satirlar[i].strip().startswith(">"):
                parca.append(re.sub(r"^>\s?", "", satirlar[i].strip(), count=1)); i += 1
            out.append(("ozet", " ".join(parca).strip()))
        elif t.startswith("|"):
            kapat()
            while i < len(satirlar) and satirlar[i].strip().startswith("|"):
                i += 1
            out.append(("tablo", ""))
        else:
            paragraf.append(t); i += 1
    kapat()
    return out


def baslikta(t: dict, no: int) -> bool:
    """YzTerim.baslikta ile aynı: `yalniz` verilmişse yalnız o başlıklarda,
    `haric`teki başlıklarda hiç."""
    return (not t.get("yalniz") or no in t["yalniz"]) and no not in t.get("haric", [])


def _cumle_basi(metin: str, i: int) -> bool:
    """_cumleBasi ile aynı: önceki anlamlı karakter cümle sonu mu (ya da blok
    başı). "**Özet.** Yapay" ve "(§7). Makine" cümle başı; "Türkiye Yapay Zekâ
    Eylem Planı" değil."""
    k = i - 1
    while k >= 0 and (metin[k].isspace() or metin[k] in '*"”’)'):
        k -= 1
    return k < 0 or metin[k] in ".!?"


def terimleri_bul(metin: str, en: bool, gorulen: set, sozluk: list[dict]) -> list[tuple[int, int, dict]]:
    """yzTerimleriBul'un birebir karşılığı. Terimler uzun desenliden kısaya
    (eşitlikte sözlük sırası) taranır; her terimin bütün geçişleri sonraki
    terimlere GÖLGE olur ("iklim akıllı tarım"ın içindeki "akıllı tarım",
    "sohbet robotu"nun içindeki "robot" ayrıca işaretlenmez). Terim, `gorulen`de
    değilse, gölgede kalmayan ilk geçişinde işaretlenir. Kalın/italik parça,
    tırnak içi (birebir alıntı) ve adres sayılmaz; cümle ortasında büyük harfle
    başlayan geçiş özel adın parçasıdır ("UCI Machine Learning Repository")."""
    if not sozluk or not metin:
        return []
    kucuk = kucult(metin, en)
    if len(kucuk) != len(metin):
        return []
    anahtar = "desen_en" if en else "desen_tr"
    yasak = ([(m.start(), m.end()) for m in BICIM.finditer(metin)]
             + [(m.start(), m.end()) for m in TIRNAK.finditer(metin)]
             + adresler(metin))
    isaretler: list[tuple[int, int, dict]] = []
    golge: list[tuple[int, int]] = []

    def ortusur(araliklar, b, s):
        return any(b < y2 and s > y1 for y1, y2 in araliklar)

    for t in sorted(sozluk, key=lambda t: -max(len(d) for d in t[anahtar])):
        goruldu = t["kimlik"] in gorulen
        bulunan = None
        yeni: list[tuple[int, int]] = []
        for d in t[anahtar]:
            tam = d.startswith("=")
            aranan = d[1:] if tam else d
            kaynak = metin if tam else kucuk
            if not aranan:
                continue
            i = kaynak.find(aranan)
            while i >= 0:
                j = i + len(aranan)
                if not _harf_mi(kaynak, i - 1) and (not tam or not _harf_mi(kaynak, j)):
                    if not tam:
                        while _harf_mi(kaynak, j):
                            j += 1
                    ad = not tam and metin[i] != kucuk[i] and not _cumle_basi(metin, i)
                    if not ad and not ortusur(yasak, i, j):
                        if not goruldu and bulunan is None and not ortusur(golge, i, j):
                            bulunan = (i, j, t)
                        yeni.append((i, j))
                i = kaynak.find(aranan, i + 1)
        if bulunan:
            isaretler.append(bulunan)
            gorulen.add(t["kimlik"])
        golge.extend(yeni)
    return sorted(isaretler, key=lambda x: x[0])


def isaretle(md: str, en: bool, no: int, terimler: list[dict]) -> list[tuple[str, str, int, int]]:
    """Bir başlık sayfasında balon açan bütün işaretler: (kimlik, blok, baş, son).
    YzMetinGorunumu gibi: özet ve paragraf blokları sırayla, aynı küme taşınarak."""
    if no in SOZLUKSUZ:
        return []
    sozluk = [t for t in terimler if baslikta(t, no)]
    gorulen: set = set()
    cikti = []
    for tur, metin in bloklar(md):
        if tur in ("ozet", "paragraf"):
            for b, s, t in terimleri_bul(metin, en, gorulen, sozluk):
                cikti.append((t["kimlik"], metin, b, s))
    return cikti


def siralama(s: str, en: bool = False):
    """Kelime kelime: boşluk her harften önce ("Nesne tanıma" < "Nesnelerin
    interneti"), rakam harften önce ("F-1" < "Fidye"); noktalama sayılmaz.
    Türkçe adlar Türk alfabesiyle, İngilizceler İngiliz alfabesiyle."""
    alfabe = ALFABE_EN if en else ALFABE
    k = kucult(s, en)
    return [alfabe.index(c) if c in alfabe else -10 + int(c) if c.isdigit() else -20
            for c in k if c in alfabe or c.isdigit() or c == " "]


def bas_harf(s: str) -> str:
    c = kucult(s, False)[:1]
    return {"i": "İ", "ı": "I"}.get(c, c.upper()) if c in ALFABE else "#"


def basliklar() -> dict[str, dict[int, str]]:
    """{dil: {no: md}} — §29 ve §30 dışındaki yazılmış başlıklar."""
    metinler: dict[str, dict[int, str]] = {}
    for yol in sorted(BOLUMLER.glob("*.md")):
        m = re.match(r"(\d{2})-.*\.(tr|en)\.md$", yol.name)
        if not m or int(m.group(1)) in SOZLUKSUZ:
            continue
        metinler.setdefault(m.group(2), {})[int(m.group(1))] = yol.read_text(encoding="utf-8")
    return metinler


def uret():
    veri = json.loads(SOZLUK.read_text(encoding="utf-8"))
    terimler = veri["terimler"]
    metinler = basliklar()
    # "Geçtiği başlıklar": balonun gerçekten açıldığı başlıklar.
    isaretli = {dil: {no: {k for k, *_ in isaretle(md, dil == "en", no, terimler)}
                      for no, md in sorted(m.items())}
                for dil, m in metinler.items()}

    def gecen(t, dil):
        return [no for no, kume in isaretli.get(dil, {}).items() if t["kimlik"] in kume]

    kayit_veri = json.loads(KAYIT.read_text(encoding="utf-8"))
    kayit = kayit_veri["kaynaklar"]
    hatalar = []
    kimlikler = [t["kimlik"] for t in terimler]
    hatalar += [f"iki kez: {k}" for k in sorted({k for k in kimlikler if kimlikler.count(k) > 1})]
    for t in terimler:
        for k in ([t["kaynak"]] if isinstance(t["kaynak"], str) else t["kaynak"]):
            if k not in kayit:
                hatalar.append(f"{t['kimlik']}: kaynak '{k}' b29 kaydında yok")
        for dil in ("tr", "en"):
            if not gecen(t, dil):
                hatalar.append(f"{t['kimlik']}: {dil} metinlerinde balon açtığı başlık yok")
    if hatalar:
        raise SystemExit("✗ sozluk.json:\n  " + "\n  ".join(hatalar))

    def sayfa(dil):
        en = dil == "en"
        ad = "en" if en else "tr"
        sirali = sorted(terimler, key=lambda t: siralama(t[ad], en))
        n = len(terimler)
        out = ["# 29 · Glossary" if en else "# 29 · Sözlük", ""]
        if en:
            out.append(f"> **Summary.** Short definitions of the **{n}** terms used across this file. Where a term first appears on a page it is underlined with dots; tapping it opens the same definition in a bubble. The source of each definition is given beside it, together with the headings where the term appears.")
        else:
            out.append(f"> **Özet.** Bu dosyada geçen **{n}** terimin kısa tanımı. Bir terim bir sayfada ilk geçtiği yerde noktalı çizgiyle altı çizili görünür; üstüne dokununca aynı tanım bir balonda açılır. Her tanımın kaynağı ve terimin geçtiği başlıklar yanında yazıyor.")
        out.append("")
        harf = None
        for t in sirali:
            h = bas_harf(t[ad]) if not en else (t[ad][:1].upper() if t[ad][:1].isalpha() else "#")
            if h != harf:
                harf = h
                out += [f"## {h}", ""]
            karsi = t["tr"] if en else t["en"]
            tanim = t["tanim_en"] if en else t["tanim_tr"]
            kaynak = t["kaynak_en"] if en else t["kaynak_tr"]
            bol = gecen(t, dil)
            satir = f"**{t[ad]}** (*{karsi}*). {tanim} *{kaynak}*"
            if bol:
                satir += (" · Appears in " if en else " · Geçtiği başlıklar: ") + ", ".join(f"§{b}" for b in bol) + "."
            out += [satir, ""]
        out.append("## How this page is kept up to date" if en else "## Bu sayfa nasıl güncelleniyor")
        out.append("")
        out.append("This page is rebuilt each time a heading is written or updated: the headings where each term appears are read from the texts themselves. New terms are added to the glossary after an editor's approval." if en
                   else "Bu sayfa, bir başlık her yazıldığında ya da güncellendiğinde yeniden kuruluyor: terimin geçtiği başlıklar metinlerin kendisinden okunuyor. Yeni terim, editör onayından sonra sözlüğe ekleniyor.")
        return "\n".join(out) + "\n"

    # Özetteki terim sayısı kayda da yazılıyor: dogrula_bolumler.py metindeki
    # her sayıyı kayıtta arıyor.
    kayit_veri["terim_sayisi"] = len(terimler)
    return sayfa("tr"), sayfa("en"), json.dumps(kayit_veri, ensure_ascii=False, indent=2) + "\n"


HEDEFLER = {"tr": BOLUMLER / "29-sozluk.tr.md", "en": BOLUMLER / "29-sozluk.en.md", "kayit": KAYIT}


def baglam(dil: str, kimlikler: list[str]) -> None:
    """Her terimin, balon açtığı her başlıktaki geçişi (çevresiyle)."""
    terimler = json.loads(SOZLUK.read_text(encoding="utf-8"))["terimler"]
    metinler = basliklar().get(dil, {})
    for t in terimler:
        if kimlikler and t["kimlik"] not in kimlikler:
            continue
        for no, md in sorted(metinler.items()):
            for k, blok, b, s in isaretle(md, dil == "en", no, terimler):
                if k == t["kimlik"]:
                    print(f"{k:24} §{no:<2} …{blok[max(0, b - 55):b]}[{blok[b:s]}]{blok[s:s + 55]}…")


def main() -> int:
    if "--baglam" in sys.argv:
        dil = "en" if "--en" in sys.argv else "tr"
        baglam(dil, [a for a in sys.argv[1:] if not a.startswith("--")])
        return 0
    tr, en, kayit = uret()
    yeni = {"tr": tr, "en": en, "kayit": kayit}
    if "--denetle" in sys.argv:
        farkli = [k for k, p in HEDEFLER.items()
                  if not p.exists() or p.read_text(encoding="utf-8") != yeni[k]]
        if farkli:
            print(f"✗ §29 güncel değil ({', '.join(farkli)}) — sozluk_uret.py koşturulmalı")
            return 1
        print("✓ §29 sözlük güncel")
        return 0
    for k, p in HEDEFLER.items():
        p.write_text(yeni[k], encoding="utf-8")
    print(f"✓ §29 sözlük · {len(json.loads(SOZLUK.read_text(encoding='utf-8'))['terimler'])} terim")
    return 0


if __name__ == "__main__":
    sys.exit(main())
