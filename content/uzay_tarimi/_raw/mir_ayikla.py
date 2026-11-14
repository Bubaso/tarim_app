#!/usr/bin/env python3
"""Mir / Svet buğdayı → mir.json.

Durak 2 ve şema durağının etilen adımının dayanağı.

══ NEDEN BU BETİK VAR ══════════════════════════════════════════════════════
Durak 2 bir süre şu cümleyle yayındaydı: "istasyon havasındaki eser etilen
bitkiyi kısırlaştırıyordu." Doğru çıktı — ama yazıldığı anda KİLİTLİ
KAYNAĞI YOKTU. Dosyanın kendi kuralı "kaynağı olmayan bilgi yayına çıkmaz"
diyordu ve bu cümle o kuralı deliyordu. Şema aynı iddiaya yaslanacağı için
önce kaynak bulundu, sonra çizildi.

İKİ MAKALE, İKİSİ DE BİRİNCİL:
  · Salisbury vd. — Mir'deki Sera II deneyinin sonuç raporu
  · Campbell vd. 2001, J. Plant Physiol. 158: 1051-1060 — Mir'de yetişen
    buğdayla, yerde etilene maruz bırakılmış buğdayın çiçek gelişimini
    KARŞILAŞTIRAN çalışma. Nedensellik iddiasını taşıyan budur.
"""
from __future__ import annotations
import json, pathlib, re, sys, datetime
from pypdf import PdfReader

KOK = pathlib.Path(__file__).parent


def oku(ad: str) -> str:
    y = KOK / "kaynak_dosyalari" / ad
    return re.sub(r"\s+", " ",
                  " ".join((p.extract_text() or "") for p in PdfReader(str(y)).pages))


sal = oku("mir_salisbury.pdf")
cam = oku("mir_campbell.pdf")

PASAJLAR = [
    ("sal", "basak_sayisi", "the ca. 280 wheat heads", 180),
    ("sal", "polen", "Microscopic analysis of a sizeable sample", 380),
    ("cam", "etilen_olcumu", "To ascertain if Super Dwarf wheat responded", 300),
    ("cam", "kisirlik", "Upon harvest in space and return to earth", 160),
    ("cam", "anter", "examination of florets from Mir-grown", 260),
    ("cam", "cekirdek", "examination of pollen grains from Mir", 300),
    ("cam", "oda", "we grew Super Dwarf wheat", 220),
]

cikti = {
    "_ne": "Mir / Svet buğday deneyi — durak 2 ve şemanın etilen adımı",
    "_nitelik": "BİRİNCİL — iki hakemli makale",
    "_cekim": datetime.date.today().isoformat(),
    "_kaynaklar": [
        {"kod": "SALISBURY",
         "kunye": "F.B. Salisbury, W.F. Campbell, J.G. Carman, G.E. Bingham, "
                  "D.L. Bubenheim, B. Yendler, V. Sytchev, M.A. Levinskikh, "
                  "I. Ivanova, L. Chernova, I. Podolsky · "
                  "'Plant growth during the Greenhouse II experiment on the "
                  "Mir orbital station'",
         "belge": "kaynak_dosyalari/mir_salisbury.pdf",
         "adres": "https://ntrs.nasa.gov/api/citations/20020047053/downloads/20020047053.pdf"},
        {"kod": "CAMPBELL",
         "kunye": "W.F. Campbell, F.B. Salisbury, B. Bugbee ve ark. · "
                  "'Comparative floral development of Mir-grown and "
                  "ethylene-treated, earth-grown Super Dwarf wheat' · "
                  "J. Plant Physiol. 158: 1051-1060 (2001)",
         "belge": "kaynak_dosyalari/mir_campbell.pdf",
         "adres": "https://extension.usu.edu/apec/files/publications/publication/pub__4572067.pdf"},
    ],
    "pasajlar": {},
    "_NEDENSELLIK_NOTU": (
        "Nedensellik iddiası ÇAPRAZ DENEYE dayanıyor, gözleme değil: "
        "Campbell ekibi yerde yetiştirdiği buğdayı Mir'de ölçülen etilen "
        "aralığına maruz bıraktı ve aynı kısırlığı üretti. 'Birlikte "
        "bulundu' değil, 'tekrarlandı'."),
}

eksik = []
for kaynak, ad, capa, uzunluk in PASAJLAR:
    t = sal if kaynak == "sal" else cam
    i = t.find(capa)
    if i < 0:
        eksik.append(f"{ad}: '{capa[:42]}…' bulunamadı ({kaynak})")
        continue
    cikti["pasajlar"][ad] = {"kaynak": kaynak.upper(),
                             "metin": t[i:i + uzunluk].strip()}

if eksik:
    print("MIR AYRIŞTIRMASI DÜŞTÜ:", file=sys.stderr)
    for e in eksik:
        print(f"  ✗ {e}", file=sys.stderr)
    raise SystemExit(1)

(KOK / "mir.json").write_text(
    json.dumps(cikti, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
print(f"✓ mir.json · {len(cikti['pasajlar'])} pasaj · 2 makale")
for ad, p in cikti["pasajlar"].items():
    print(f"\n── {ad}  [{p['kaynak']}]\n   {p['metin'][:240]}")
