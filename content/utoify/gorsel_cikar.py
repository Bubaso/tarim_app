#!/usr/bin/env python3
"""114 kareyi PDF'lerden çıkarır, RGB'ye çevirir, web/sergi/utoify-16/ altına yazar.

KAYNAK TAVANI DÜŞÜK ve bu bilinçli bir kısıt: ödül kareleri 613×399,
sergileme kareleri 549×364. Yarışmanın kendi sitesi de yalnız 400 piksel
servis ediyor (800/1200/orijinal → 404). Yani bundan büyüğü HİÇBİR YERDE yok.
Büyütmek yapmıyoruz: 550 pikseli şişirip bulanık göstermek, kareyi çeken
kişiye yapılabilecek en kötü şey.

CMYK → RGB çevirisi şart: PDF baskı için hazırlanmış, kareler CMYK. Çevirisiz
kaydedilen JPEG tarayıcıda açılmıyor.
"""
from __future__ import annotations

import json
import pathlib
import re
import sys

import pypdf
from PIL import Image

KOK = pathlib.Path(__file__).resolve().parent
DEPO = KOK.parent.parent
HEDEF = DEPO / "web/sergi/utoify-16"

# Türkçe harf eşlemesi ELLE yazılı. `str.lower()` Türkçede "I" → "i" yapıyor
# ve "İ" → "i̇" (birleşik nokta) üretiyor; ikisi de dosya adında bozuk sonuç.
ESLEME = str.maketrans({
    "ç": "c", "Ç": "c", "ğ": "g", "Ğ": "g", "ı": "i", "I": "i",
    "İ": "i", "i": "i", "ö": "o", "Ö": "o", "ş": "s", "Ş": "s",
    "ü": "u", "Ü": "u", "â": "a", "Â": "a", "î": "i", "Î": "i",
    "û": "u", "Û": "u", "’": "", "'": "", "”": "", "“": "",
})


def slug(s: str) -> str:
    s = s.translate(ESLEME).lower()
    s = re.sub(r"[^a-z0-9]+", "-", s).strip("-")
    return re.sub(r"-{2,}", "-", s)


def kareler(pdf: pathlib.Path) -> dict:
    r = pypdf.PdfReader(str(pdf))
    out = {}
    for sno, sayfa in enumerate(r.pages, start=1):
        for im in sayfa.images:
            out[(sno, "/" + im.name.split(".")[0])] = im
    return out


def main() -> int:
    odul_pdf = KOK / "_raw/kaynak_dosyalari/16th_utoify_odul.pdf"
    sergi_pdf = KOK / "_raw/kaynak_dosyalari/16th_utoify_sergileme.pdf"
    for p in (odul_pdf, sergi_pdf):
        if not p.exists():
            print("HAM PDF YOK: %s — _raw/README.md'deki adresten indir." % p.name)
            return 1

    odul = json.loads((KOK / "odul_kunyeleri.json").read_text(encoding="utf-8"))
    sergi = json.loads(
        (KOK / "_raw/sergileme_kunyeleri.json").read_text(encoding="utf-8"))

    HEDEF.mkdir(parents=True, exist_ok=True)
    o_im, s_im = kareler(odul_pdf), kareler(sergi_pdf)
    yazildi, toplam = 0, 0

    for k in odul["kayitlar"]:
        k["sayfa"] = 1
    birlesik = [("odul", k, o_im) for k in odul["kayitlar"]] + \
               [("sergi", k, s_im) for k in sergi["kayitlar"]]

    for tur, k, havuz in birlesik:
        im = havuz.get((k["sayfa"], k["im"]))
        if im is None:
            print("  ! %s: görsel bulunamadı (%s s%d)" % (k["kod"], k["im"], k["sayfa"]))
            continue
        g = im.image
        if g.mode != "RGB":
            g = g.convert("RGB")      # CMYK baskı karesi → ekran
        ad = "%s-%s.jpg" % (k["kod"], slug(k["fotografci"]))
        yol = HEDEF / ad
        g.save(yol, "JPEG", quality=72, optimize=True, progressive=True)
        k["dosya"] = ad
        k["en"], k["boy"] = g.width, g.height
        k["en_boy"] = round(g.width / g.height, 4)
        toplam += yol.stat().st_size
        yazildi += 1

    (KOK / "_raw/odul_kunyeleri_dosyali.json").write_text(
        json.dumps(odul, ensure_ascii=False, indent=1), encoding="utf-8")
    (KOK / "_raw/sergileme_kunyeleri.json").write_text(
        json.dumps(sergi, ensure_ascii=False, indent=1), encoding="utf-8")
    print("✓ %d kare → %s (%.1f MB, ortalama %d KB)"
          % (yazildi, HEDEF.relative_to(DEPO), toplam / 1048576,
             toplam / max(yazildi, 1) / 1024))
    return 0


if __name__ == "__main__":
    sys.exit(main())
