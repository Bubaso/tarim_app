#!/usr/bin/env python3
"""Arazi varlığı PDF'inden işletme işletme tabloyu çıkarır.

PDF TEK SAYFA ve 25.07.2023 tarihli. Başlığı kapsamı söylüyor:
"TİGEM'İN FAALİYETTE OLDUĞU 17 İŞLETMENİN ARAZİ VARLIĞI (Dekar)".
Tablonun altındaki üç satır (uzun süreli kira, iştirak, genel toplam)
AYRI KAPSAMDIR ve elle değil, PDF'in kendi rakamlarıyla taşınır.
"""
import json
import pathlib
import re

import pypdf

KOK = pathlib.Path(__file__).parent
PDF = KOK / "kaynak_dosyalari" / "tigem_arazi_varligi.pdf"

ham = "\n".join((s.extract_text() or "") for s in pypdf.PdfReader(PDF).pages)

SAYI = r"[\d.]+,\d+|[\d.]+"


def say(m: str) -> float:
    return float(m.replace(".", "").replace(",", "."))


satirlar = []
for cizgi in ham.split("\n"):
    m = re.match(
        r"\s*(\d{1,2})\s+(.+?Tarım İşletmesi Müdürlüğü)\s+(" + SAYI + r")\s+("
        + SAYI + r")\s+(" + SAYI + r")\s+(" + SAYI + r")\s+(" + SAYI + r")\s+("
        + SAYI + r")\s+(" + SAYI + r")\s+(" + SAYI + r")\s*$",
        cizgi,
    )
    if not m:
        continue
    satirlar.append({
        "sira": int(m.group(1)),
        "isletme": m.group(2).replace(" Tarım İşletmesi Müdürlüğü", ""),
        "toplam": say(m.group(3)),
        "kulturalti": say(m.group(4)),
        "tarla": say(m.group(5)),
        "yem_bitkileri": say(m.group(6)),
        "tabii_mera": say(m.group(7)),
        "bahce": say(m.group(8)),
        "kulturdisi": say(m.group(9)),
        "sulanan": say(m.group(10)),
    })

gm = re.search(r"Genel Müdürlük[^\n]*?(" + SAYI + r")\s", ham)
cikti = {
    "_kaynak": "tigem.gov.tr/Folder/AraziVarligiDosyasi — PDF üstündeki tarih 25.07.2023",
    "_kapsam": "Faaliyette olan 17 işletme + Genel Müdürlük yerleşkesi; kiraya verilenler AYRI",
    "_birim": "dekar",
    "genel_mudurluk_toplam": say(gm.group(1)) if gm else None,
    "isletmeler": satirlar,
}
print(json.dumps(cikti, ensure_ascii=False, indent=2))
