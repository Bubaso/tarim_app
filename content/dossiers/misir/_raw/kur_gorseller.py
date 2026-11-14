#!/usr/bin/env python3
"""İndirilen kareleri yayına hazırlar: kopyala → küçült → en_boy'u YENİDEN ÖLÇ.

Adımlar:
  1. _raw/gorseller/ → web/dosya/misir/   (yalnız altyazısı yazılmış olanlar)
  2. scripts/dosya_gorsel_optimize.py ile küçült
  3. kunye.json'daki `en_boy`'u OPTİMİZASYONDAN SONRA diskten yeniden ölç

ÜÇÜNCÜ ADIM NEDEN VAR: `en_boy` Commons API'sinin verdiği boyuttan
kopyalanırsa, kırpılan ya da yeniden boyutlanan bir karede YANLIŞ olur ve
sayfa görseli yanlış orana göre çizer. Irak dosyasında bu ölçülerek
yakalanmıştı: bir kare kırpılınca oranı 1,4585'ten 1,3806'ya inmişti.
dogrula_yayin.py 4. kuralı bu sayıyı diskle karşılaştırıyor.

Çalıştırma: python3 content/dossiers/misir/_raw/kur_gorseller.py
"""
from __future__ import annotations
import json, pathlib, shutil, subprocess, sys

KOK = pathlib.Path(__file__).resolve().parent
DOSYA = KOK.parent
DEPO = DOSYA.parents[2]
WEB = DEPO / "web" / "dosya" / "misir"

kunye_yolu = KOK / "gorseller" / "kunye.json"
if not kunye_yolu.exists():
    sys.exit("kunye.json yok — önce `node gorsel_indir.mjs` koşsun")
K = json.loads(kunye_yolu.read_text(encoding="utf-8"))
G = K["gorseller"]
ALT = json.loads((KOK / "altyazilar.json").read_text(encoding="utf-8"))
istenen = {k for k in ALT if not k.startswith("_")}

eksik = sorted(istenen - set(G))
if eksik:
    sys.exit(f"altyazısı yazılmış ama İNMEMİŞ kare: {eksik}")
fazla = sorted(set(G) - istenen)
if fazla:
    print(f"  ⚠ altyazısı olmayan inmiş kare (kopyalanmıyor): {fazla}")

WEB.mkdir(parents=True, exist_ok=True)
for ad in sorted(istenen):
    shutil.copy2(KOK / "gorseller" / G[ad]["dosya"], WEB / G[ad]["dosya"])
print(f"1. {len(istenen)} kare web/dosya/misir/ altına kopyalandı")

r = subprocess.run([sys.executable, str(DEPO / "scripts" / "dosya_gorsel_optimize.py"), "misir"],
                   capture_output=True, text=True)
cik = (r.stdout or r.stderr).strip().splitlines()
print("2. küçültme:", cik[-1] if cik else "çıktı yok")

try:
    from PIL import Image
except Exception:
    sys.exit("3. PIL yok — en_boy diskten ÖLÇÜLEMEZ. Kurulmadan devam edilmez: "
             "künyedeki oran yanlış kalırsa sayfa görseli yanlış çizer.")

degisen = 0
for ad in sorted(istenen):
    yol = WEB / G[ad]["dosya"]
    with Image.open(yol) as im:
        yeni = round(im.width / im.height, 4)
        G[ad]["genislik_yayin"], G[ad]["yukseklik_yayin"] = im.width, im.height
    G[ad]["bayt_yayin"] = yol.stat().st_size
    if abs(yeni - G[ad]["en_boy"]) > 0.0001:
        print(f"   · {ad}: en_boy {G[ad]['en_boy']} → {yeni}")
        G[ad]["en_boy"] = yeni
        degisen += 1
K["_en_boy_notu"] = ("en_boy YAYINA GİDEN dosyadan ölçüldü, Commons "
                     "boyutundan değil. Kırpma ya da küçültme oranı "
                     "değiştirirse künyeden kopyalanan sayı yanlış kalır.")
kunye_yolu.write_text(json.dumps(K, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"3. en_boy diskten ölçüldü · {degisen} kayıt güncellendi")
