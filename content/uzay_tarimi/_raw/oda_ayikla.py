#!/usr/bin/env python3
"""NASA/TM-20250001897 → oda.json — yetiştirme odasının donanımı.

Şema durağının (durak 5) dayanağı. Çizilen her parçanın belgede bir
cümlesi var; betik o cümleleri PDF'ten ÇEKİYOR, elle kopyalamıyor.
Belge sürümü değişip cümle kaybolursa betik düşer ve şema dayanaksız
kalmaz.

Niye önemli: şema bir çizim ve çizim her şeyi söyleyebilir. Kaynağı
olmayan bir ok, kaynağı olmayan bir cümleden daha tehlikeli — çünkü
sorgulanması daha zor.
"""
from __future__ import annotations
import json, pathlib, re, sys, datetime
from pypdf import PdfReader

KOK = pathlib.Path(__file__).parent
PDF = KOK / "kaynak_dosyalari" / "nasa_space_crops.pdf"
metin = "\n".join((s.extract_text() or "") for s in PdfReader(str(PDF)).pages)
duz = re.sub(r"\s+", " ", metin)

# Aranan pasajlar: (anahtar, çapa dizge, kaç karakter alınacak)
PASAJLAR = [
    ("yastik", "grown using small plant pillows", 420),
    ("sulama", "The plant pillows have an external irrigation tube", 330),
    ("aph_isik", "It provides independent control of red", 300),
    ("tutucular", "Volatile organics are removed from the atmosphere", 160),
    ("aph_sensor", "APH has over 180 sensors", 150),
]

cikti = {
    "_kaynak": ("NASA/TM-20250001897 · Space Crop Considerations for Human "
                "Exploration · Temmuz 2024 · Kennedy Uzay Merkezi"),
    "_nitelik": "BİRİNCİL — NASA teknik memorandumu",
    "_belge": "kaynak_dosyalari/nasa_space_crops.pdf",
    "_cekim": datetime.date.today().isoformat(),
    "_NE": ("Yetiştirme odasının donanımı. Şema durağında çizilen her parça "
            "buradaki bir cümleye dayanıyor."),
    "pasajlar": {},
    "elenen_ornekler": [],
}

eksik = []
for ad, capa, uzunluk in PASAJLAR:
    i = duz.find(capa)
    if i < 0:
        eksik.append(f"{ad}: '{capa[:40]}…' belgede bulunamadı")
        continue
    cikti["pasajlar"][ad] = duz[i:i + uzunluk].strip()

# ── ELENEN EKİNLERİN SEBEPLERİ ───────────────────────────────────────────
# Belgenin kendi çizelgesi, hangi ekinin NEDEN düştüğünü yazıyor. Şemanın
# en güçlü iki adımı buradan geliyor: havalandırma ve CO2 soyut değil,
# birer ekini düşürmüş somut sebepler.
ARANANLAR = {
    "havalandirma": r"(Shungiku[^0-9]{0,120}airflow[^0-9]{0,40})",
    "co2": r"(‘?Tokyo Bekana’? Chinese cabbage[^0-9]{0,90})",
}
for ad, kalip in ARANANLAR.items():
    m = re.search(kalip, duz)
    if not m:
        eksik.append(f"elenen/{ad}: çizelge satırı bulunamadı")
        continue
    cikti["elenen_ornekler"].append({"ad": ad, "satir": m.group(1).strip()})

if eksik:
    print("ODA AYRIŞTIRMASI DÜŞTÜ:", file=sys.stderr)
    for e in eksik:
        print(f"  ✗ {e}", file=sys.stderr)
    raise SystemExit(1)

(KOK / "oda.json").write_text(
    json.dumps(cikti, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
print(f"✓ oda.json · {len(cikti['pasajlar'])} pasaj · "
      f"{len(cikti['elenen_ornekler'])} elenme sebebi")
for ad, p in cikti["pasajlar"].items():
    print(f"\n── {ad}\n   {p[:300]}")
for e in cikti["elenen_ornekler"]:
    print(f"\n── elenen/{e['ad']}\n   {e['satir'][:200]}")
