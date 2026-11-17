#!/usr/bin/env python3
"""
Yapay Zeka ve Dijital Tarım — §29 Sözlük üreticisi (karar 14).

    python3 sozluk_uret.py            # yazar
    python3 sozluk_uret.py --denetle  # yazmaz; dosyalar güncel değilse çıkış 1

Tanımlar `_raw/sozluk.json`da elle yazılıyor; dayanakları `_raw/b29_kaynaklar.json`
kaydında birebir alıntıyla. Bu betik iki şeyi üretiyor:

  1. `bolumler/29-sozluk.{tr,en}.md` — sözlük sayfası. Her terimin yanında
     kaynağı ve geçtiği başlıklar.
  2. (dart_uret.py) aynı tanımlar `yz_sozluk.g.dart`a gömülüyor; metin içi
     balon onları gösteriyor.

EŞLEŞTİRME, Dart'taki `yzTerimleriBul` ile AYNI kural: küçük harfli desen
kelime başında aranır (Türkçe küçültme: I → ı, İ → i); `=` önekli desen
büyük-küçük harfe duyarlı ve tam kelime; kalın/italik parçanın ve adresin
içi sayılmaz. "Geçtiği başlıklar" balonun açılabildiği başlıklardır.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

RAW = Path(__file__).resolve().parent
BOLUMLER = RAW.parent / "bolumler"
SOZLUK = RAW / "sozluk.json"
ALFABE = "abcçdefgğhıijklmnoöpqrsştuüvwxyz"

BICIM = re.compile(r"\*\*(.+?)\*\*|\*(.+?)\*")
ADRES = re.compile(r'https?://[^\s<>"]+')
HARF = re.compile(r"[^\W_]", re.UNICODE)


def kucult(s: str, en: bool) -> str:
    """Uzunluğu koruyan küçültme. Türkçe: I → ı, İ → i. İngilizce metinde de
    "İMECE" gibi özel adlar var: İ önce i'ye iner, yoksa .lower() onu iki
    karaktere (i + birleşen nokta) açar ve konumlar kayar."""
    return s.replace("İ", "i").lower() if en else s.replace("I", "ı").replace("İ", "i").lower()


def _harf_mi(m: str, i: int) -> bool:
    return 0 <= i < len(m) and bool(HARF.match(m[i]))


def gecer_mi(metin: str, desenler: list[str], en: bool) -> bool:
    """Terim bu metinde balonun açılabileceği bir yerde geçiyor mu."""
    kucuk = kucult(metin, en)
    yasak = [(m.start(), m.end()) for m in BICIM.finditer(metin)]
    yasak += [(m.start(), m.end()) for m in ADRES.finditer(metin)]
    for d in desenler:
        tam = d.startswith("=")
        aranan = d[1:] if tam else d
        kaynak = metin if tam else kucuk
        i = kaynak.find(aranan)
        while i >= 0:
            j = i + len(aranan)
            if not _harf_mi(kaynak, i - 1) and (not tam or not _harf_mi(kaynak, j)):
                if not any(i < b and j > a for a, b in yasak):
                    return True
            i = kaynak.find(aranan, i + 1)
    return False


def metin_bloklari(md: str) -> str:
    """Balonun çalıştığı bloklar: özet ve paragraflar (başlık, alt başlık,
    tablo satırı hariç)."""
    satirlar = []
    for s in md.splitlines():
        t = s.strip()
        if not t or t.startswith("#") or t.startswith("|"):
            continue
        satirlar.append(t[1:].strip() if t.startswith(">") else t)
    return "\n".join(satirlar)


def siralama(s: str):
    k = kucult(s, False)
    return [ALFABE.index(c) if c in ALFABE else 100 + ord(c) for c in k if c.isalnum()]


def bas_harf(s: str) -> str:
    c = kucult(s, False)[:1]
    return {"i": "İ", "ı": "I"}.get(c, c.upper()) if c in ALFABE else "#"


def uret():
    veri = json.loads(SOZLUK.read_text(encoding="utf-8"))
    terimler = veri["terimler"]
    metinler = {}
    for yol in sorted(BOLUMLER.glob("*.md")):
        m = re.match(r"(\d{2})-.*\.(tr|en)\.md$", yol.name)
        if not m or m.group(1) in ("29", "30"):
            continue
        metinler.setdefault(m.group(2), {})[int(m.group(1))] = metin_bloklari(yol.read_text(encoding="utf-8"))

    def gecen(t, dil):
        return [no for no, m in sorted(metinler.get(dil, {}).items())
                if gecer_mi(m, t["desen_" + dil], dil == "en")]

    def sayfa(dil):
        en = dil == "en"
        ad = "en" if en else "tr"
        sirali = sorted(terimler, key=lambda t: siralama(t[ad]))
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
        out.append("A term is added when it is used in a newly written heading; each definition rests on a source in the glossary's record. New entries are added after an editor's approval." if en
                   else "Yeni yazılan bir başlıkta geçen terim sözlüğe ekleniyor; her tanım sözlüğün kaydındaki bir kaynağa dayanıyor. Yeni terim, editör onayından sonra ekleniyor.")
        return "\n".join(out) + "\n"

    return sayfa("tr"), sayfa("en"), None


HEDEFLER = {"tr": BOLUMLER / "29-sozluk.tr.md", "en": BOLUMLER / "29-sozluk.en.md"}


def main() -> int:
    tr, en, _ = uret()
    yeni = {"tr": tr, "en": en}
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
