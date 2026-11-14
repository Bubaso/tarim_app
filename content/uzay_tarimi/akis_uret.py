#!/usr/bin/env python3
"""`akis.json` → `uzay_akis.g.dart` — dosyanın OKUNAN katmanı.

Veri katmanı (`data.json` → `uzay_veri.g.dart`) rakamları taşıyor; bu
üretici anlatıyı taşıyor. İkisi ayrı çünkü ayrı şeyler: biri kilitli
ölçüm, öteki yazılmış metin. Aynı dosyaya konsaydı bir cümle düzeltmek
veri doğrulamasını yeniden koşturmak demek olurdu.

DOLAR İŞARETİ TUZAĞI. Dart tek tırnaklı dizgede bile `$` görünce
interpolasyon arıyor. Metinde dolar geçebilir; kaçırılıyor.
"""
from __future__ import annotations
import json, pathlib, re, subprocess, sys

KOK = pathlib.Path(__file__).parent
DEPO = KOK.parent.parent
CIKTI = DEPO / "lib/features/uzay_tarimi/data/uzay_akis.g.dart"

akis = json.loads((KOK / "akis.json").read_text(encoding="utf-8"))

# ── SINAMA — metin kurallarının kendisi sınanıyor ────────────────────────
hata: list[str] = []

if not akis.get("kapak", {}).get("gorsel", {}).get("atif"):
    hata.append("KAPAK GÖRSELİNİN ATFI YOK · atıfsız görsel yayına çıkmaz")

for b in akis["bolumler"]:
    yer = f"bölüm {b['no']}"
    if not b.get("baslik"):
        hata.append(f"{yer}: başlık yok")
    if not b.get("govde"):
        hata.append(f"{yer}: gövde boş")
    g = b.get("gorsel")
    if g:
        for alan in ("url", "atif", "alt"):
            if not g.get(alan):
                hata.append(f"{yer}: görselin '{alan}' alanı boş — "
                            f"yarım künye, künyesizlikten farksız")
    # SAHNE KURALI: her bölüm bir yer-zaman-insan ile açılmalı. Üstbaşlık
    # o çapayı taşıyor; boşsa bölüm havada başlıyor.
    if not b.get("ustbaslik"):
        hata.append(f"{yer}: üstbaşlık yok — sahnenin zaman çapası eksik")
    # Paragraf uzunluğu. Belgesel akışında dört satırı aşan paragraf
    # nefesi kesiyor; bu dosya bir kez bu yüzden rapora döndü.
    for i, p in enumerate(b["govde"]):
        if len(p) > 700:
            hata.append(f"{yer} paragraf {i+1}: {len(p)} karakter — "
                        f"700'ü aşıyor, bölünmeli")

if hata:
    print("AKIŞ KİLİTLENMEDİ:", file=sys.stderr)
    for h in hata:
        print(f"  ✗ {h}", file=sys.stderr)
    raise SystemExit(1)


def kacir(s: str) -> str:
    return s.replace("\\", "\\\\").replace("'", "\\'").replace("$", "\\$")


def dart(v, girinti=2) -> str:
    bo = " " * girinti
    ic = " " * (girinti + 2)
    if isinstance(v, str):
        return f"'{kacir(v)}'"
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)):
        return str(v)
    if v is None:
        return "null"
    if isinstance(v, list):
        if not v:
            return "[]"
        ogeler = ",\n".join(ic + dart(x, girinti + 2) for x in v)
        return "[\n" + ogeler + ",\n" + bo + "]"
    if isinstance(v, dict):
        if not v:
            return "{}"
        ogeler = ",\n".join(
            f"{ic}'{kacir(str(k))}': {dart(x, girinti + 2)}"
            for k, x in v.items())
        return "{\n" + ogeler + ",\n" + bo + "}"
    raise TypeError(type(v))


govde = f"""// ÜRETİLMİŞ DOSYA — ELLE DEĞİŞTİRİLMEZ.
// Kaynak: content/uzay_tarimi/akis.json
// Üretici: content/uzay_tarimi/akis_uret.py
//
// Dosyanın OKUNAN katmanı: bölüm metinleri ve görsel künyeleri.
// Rakamlar burada değil — onlar `uzay_veri.g.dart`'ta kilitli.

const Map<String, dynamic> uzayAkis = {dart(akis)};
"""

CIKTI.parent.mkdir(parents=True, exist_ok=True)
CIKTI.write_text(govde, encoding="utf-8")
kb = CIKTI.stat().st_size / 1024
print(f"✓ {CIKTI.relative_to(DEPO)}  ({kb:.1f} KB)")
print(f"  {len(akis['bolumler'])} bölüm · "
      f"{sum(len(b['govde']) for b in akis['bolumler'])} paragraf · "
      f"{sum(1 for b in akis['bolumler'] if b.get('gorsel'))} görsel")

r = subprocess.run(["dart", "analyze", str(CIKTI)],
                   capture_output=True, text=True, cwd=DEPO)
if r.returncode:
    print(r.stdout[-1500:], file=sys.stderr)
    raise SystemExit("✗ dart analyze düştü")
print("✓ dart analyze temiz")
