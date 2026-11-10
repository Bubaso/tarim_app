#!/usr/bin/env python3
"""İndirilen görselleri yayına hazırlar ve yayin.json'a yerleştirir.

Adımlar:
  1. _raw/gorseller/ → web/dosya/tigem/  (yalnız altyazısı yazılmış olanlar)
  2. scripts/dosya_gorsel_optimize.py ile 1440 px'e indir
  3. en_boy'u OPTİMİZASYONDAN SONRA yeniden ÖLÇ — yayin.json'daki sayı
     diskteki dosyanın kendisinden gelir, API'den değil
  4. kunye.json yaz (atıf ve lisans API'den; altyazılar elle)
  5. yayin.json/bolum_gorselleri ve hikaye slayt görsellerini yaz

Altyazılar `altyazilar.json` dosyasından okunur ve ELLE yazılır: karede NE
GÖRÜNÜYORSA o. Kullanıcı kuralı (8 Kasım 2026): "görselin ne olduğunu
kullanıcı için yaz, teknik analiz tahlilini değil."
"""
from __future__ import annotations

import json
import pathlib
import shutil
import subprocess
import sys

KOK = pathlib.Path(__file__).resolve().parent
DOSYA = KOK.parent
DEPO = DOSYA.parents[2]
WEB = DEPO / "web" / "dosya" / "tigem"
TABAN = "https://tarimportali.net/dosya/tigem/"

ham = json.loads((KOK / "gorseller" / "kunye_ham.json").read_text(encoding="utf-8"))
alt = json.loads((KOK / "altyazilar.json").read_text(encoding="utf-8"))
WEB.mkdir(parents=True, exist_ok=True)

eksik = [k for k in alt["bolumler"].values() if k and k not in ham]
if eksik:
    sys.exit(f"altyazısı olan ama indirilmemiş görsel: {eksik}")

# 1 — kopyala
kullanilan = {v for v in alt["bolumler"].values() if v} | {v for v in alt["slaytlar"].values() if v}
for ad in kullanilan:
    kaynak = KOK / "gorseller" / ham[ad]["dosya"]
    shutil.copy2(kaynak, WEB / ham[ad]["dosya"])
print(f"1. {len(kullanilan)} görsel web/dosya/tigem/ altına kopyalandı")

# 2 — optimize
r = subprocess.run([sys.executable, str(DEPO / "scripts" / "dosya_gorsel_optimize.py"), "tigem"],
                   capture_output=True, text=True)
print("2. optimizasyon:", (r.stdout or r.stderr).strip().splitlines()[-1] if (r.stdout or r.stderr) else "çıktı yok")

# 3 — en_boy diskten yeniden ölçülüyor
from PIL import Image
for ad in kullanilan:
    with Image.open(WEB / ham[ad]["dosya"]) as im:
        g, y = im.size
    ham[ad]["yayin_genislik"], ham[ad]["yayin_yukseklik"] = g, y
    ham[ad]["en_boy"] = round(g / y, 4)
    ham[ad]["yayin_bayt"] = (WEB / ham[ad]["dosya"]).stat().st_size
print("3. en_boy diskteki dosyadan yeniden ölçüldü")

# 4 — kunye.json
kunye = {
    "_dosya": "TİGEM dosyası — görsel künyesi",
    "_kural": "Atıf ve lisans Commons API'sinden çekildi, ELLE YAZILMADI. Atıfsız görsel yayımlanmaz (§2.4). Altyazılar elle yazıldı: karede ne görünüyorsa o.",
    "_reddedilenler": alt.get("_reddedilenler", {}),
    "gorseller": {ad: ham[ad] for ad in sorted(kullanilan)},
}
(KOK / "gorseller" / "kunye.json").write_text(
    json.dumps(kunye, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
print(f"4. kunye.json yazıldı · {len(kullanilan)} görsel")

# 5 — yayin.json
yp = DOSYA / "yayin.json"
Y = json.loads(yp.read_text(encoding="utf-8"))
blok = {
    "_amac": "Grafik veriyi anlatır, görsel konuyu gösterir. Atıfsız görsel yayımlanmaz (§2.4).",
    "_kaynak": "Hepsi Wikimedia Commons; atıf ve lisans Commons API'sinden çekildi, elle yazılmadı.",
    "_kural": "HER BÖLÜMDE BİR GÖRSEL — kullanıcı kuralı. dogrula_yayin.py boş bırakılan bölümü hata sayıyor.",
    "_altyazi_kurali": "Altyazı GÖRÜLENİ söyler. Kullanıcı kuralı (8 Kasım 2026): 'görselin ne olduğunu kullanıcı için yaz, teknik analiz tahlilini değil.'",
    "_gozle_dogrulama": alt["_gozle_dogrulama"],
    "_bos_birakilanlar": "YOK.",
}
for b, ad in alt["bolumler"].items():
    m = ham[ad]
    a = alt["metin"][ad]
    blok[b] = {
        "url": TABAN + m["dosya"],
        "atif": f"{m['atif']} — {m['lisans']}" if m["lisans"].lower() != "public domain" else f"{m['atif']} — kamu malı",
        "lisans": m["lisans"],
        "alt_tr": a["tr"],
        "alt_en": a["en"],
        "en_boy": m["en_boy"],
        "_commons": m["sayfa"],
        "_gozle_dogrulandi": True,
    }
Y["bolum_gorselleri"] = blok
for i, s in enumerate(Y["hikaye"]["slaytlar"], 1):
    ad = alt["slaytlar"][str(i)]
    s["gorsel"] = TABAN + ham[ad]["dosya"]
yp.write_text(json.dumps(Y, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
print("5. yayin.json/bolum_gorselleri ve hikâye slayt görselleri yazıldı")
