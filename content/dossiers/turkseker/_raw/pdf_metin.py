#!/usr/bin/env python3
"""PDF → metin. Kurumun kendi belgeleri gövdenin birincil katmanı.

pdftotext/mutool bu makinede yok; `pypdf` var ve yeterli. Çıkarılan metin
`kaynak_dosyalari/<ad>.txt` olarak yazılıyor ki sonraki turlar PDF'i yeniden
açmasın.

TUZAK: pypdf bazı PDF'lerde boş dize döndürüyor (taranmış sayfa, gömülü
font eşlemesi yok). Sayfa başına karakter sayısı yazılıyor; sıfıra yakınsa
belge METİN DEĞİL GÖRÜNTÜ demektir ve o belgeden rakam okunamaz.
"""
from __future__ import annotations
import pathlib, sys
from pypdf import PdfReader

KOK = pathlib.Path(__file__).parent / "kaynak_dosyalari"

def cikar(ad: str) -> None:
    yol = KOK / ad
    r = PdfReader(str(yol))
    sayfalar = []
    for s in r.pages:
        try:
            sayfalar.append(s.extract_text() or "")
        except Exception as e:
            sayfalar.append("")
    tum = "\n\n".join(sayfalar)
    (KOK / (yol.stem + ".txt")).write_text(tum, encoding="utf-8")
    dolu = sum(1 for s in sayfalar if len(s.strip()) > 40)
    print(f"  {ad:28s} {len(r.pages):4d} sayfa · {len(tum):8,d} karakter · "
          f"metinli sayfa {dolu}/{len(r.pages)}"
          + ("  ⚠ GÖRÜNTÜ OLABİLİR" if dolu < len(r.pages) * 0.4 else ""))

for a in (sys.argv[1:] or [p.name for p in sorted(KOK.glob("*.pdf"))]):
    cikar(a)
