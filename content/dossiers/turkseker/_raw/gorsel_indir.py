#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Görselleri 1440 px indirir ve kunye.json'u yazar.

ASLI DEĞİL, KÜÇÜK RESİM İNDİRİLİYOR. Mısır dosyasında asıllar indirilmiş,
17 MB'lık dosyalar Commons'tan 429 yedirmişti; yayın genişliği 1440 px
olduğu için aslını çekmenin bir karşılığı yok. Aslı 1440'tan darsa
Commons zaten aslını veriyor — büyütme YAPILMIYOR.
"""
import json, pathlib, subprocess, sys

KOK = pathlib.Path(__file__).parent
HEDEF = KOK / "gorseller"
HEDEF.mkdir(exist_ok=True)
UA = "tarimportali-dosya/1.0 (research; contact via site)"
GENISLIK = 1920   # Commons'un sunduğu standart kova

adaylar = json.loads((KOK / "gorsel_adaylari.json").read_text(encoding="utf-8"))["adaylar"]

# ADRESLER API'NİN VERDİĞİ GİBİ KULLANILIYOR, "DÜZELTİLMİYOR".
# İlk denemede iki varsayım yapıp ikisinde de yanıldım: (a) API
# thumb.wikimedia.org dönünce bunu tarayıcının yeniden yazması sanıp
# upload.wikimedia.org'a çevirdim — oysa küçük resimlerin gerçek hostu
# artık thumb.wikimedia.org; (b) 1920px kovasını istediğim 1440'a
# çektim — Commons yalnız standart kovaları sunuyor ve 1440 ile 1024
# ikisi de HTTP 400 veriyor. Ölçüldü:
#   thumb…/1440px-  → 400      thumb…/1920px-  → 200
#   upload…/1024px- → 400
# Aslı 1920'den darsa API zaten aslının adresini veriyor; büyütme yok.
# §12 İSTİSNASI. turkseker_gm_binasi Commons'ta değil; adresi kurumun kendi
# sitesinde ve künyesi aday kaydında duruyor (bkz. gorsel_adaylari.json/
# _gm_binasi_notu). Haritaya ham_url'den giriyor ki indirme döngüsü ortak
# kalsın.
ADRES = {
 "turkseker_alpullu_1928": "https://thumb.wikimedia.org/wikipedia/commons/thumb/b/b6/AHTURAL013006.jpg/1920px-AHTURAL013006.jpg",
 "turkseker_usak_kurucular": "https://thumb.wikimedia.org/wikipedia/commons/thumb/2/2e/U%C5%9Fak_%C5%9Eeker_Fabrikas%C4%B1_Kurucular%C4%B1.jpg/1920px-U%C5%9Fak_%C5%9Eeker_Fabrikas%C4%B1_Kurucular%C4%B1.jpg",
 "turkseker_usak_hisse": "https://upload.wikimedia.org/wikipedia/commons/0/00/U%C5%9Fak_%C5%9Eeker_Fabrikas%C4%B1_Hisse_Senedi.JPG",
 "turkseker_usak_disaridan": "https://upload.wikimedia.org/wikipedia/commons/d/d2/U%C5%9Fak_%C5%9Eeker_Fabrikas%C4%B1_Kurulu%C5%9Fdaki_Resmi.jpg",
 "turkseker_eskisehir": "https://upload.wikimedia.org/wikipedia/commons/2/23/Eskisehirseker.jpg",
 "turkseker_bogazliyan": "https://upload.wikimedia.org/wikipedia/commons/a/a3/Bogazliyan_sugar_factory_%28Turkey%29.jpg",
 "turkseker_pancar_tarla": "https://thumb.wikimedia.org/wikipedia/commons/thumb/d/d1/Beta_vulgaris_subsp._vulgaris_var._altissima_drought_%2804%29.jpg/1920px-Beta_vulgaris_subsp._vulgaris_var._altissima_drought_%2804%29.jpg",
 "turkseker_pancar_kiyim": "https://thumb.wikimedia.org/wikipedia/commons/thumb/4/48/Sugar_beet_cossettes.jpg/1920px-Sugar_beet_cossettes.jpg",
 "turkseker_misir_tesisi": "https://thumb.wikimedia.org/wikipedia/commons/thumb/1/1d/ADM_corn_plant_%28Columbus%2C_Nebraska%29.JPG/1920px-ADM_corn_plant_%28Columbus%2C_Nebraska%29.JPG",
 "turkseker_pancar": "https://upload.wikimedia.org/wikipedia/commons/6/6b/Pancar_.jpg",
 "turkseker_erzurum": "https://thumb.wikimedia.org/wikipedia/commons/thumb/5/5d/Erzurum_%C5%9Eeker_Fabrikas%C4%B1_Giri%C5%9F.jpg/1920px-Erzurum_%C5%9Eeker_Fabrikas%C4%B1_Giri%C5%9F.jpg",
 "turkseker_chino_1906": "https://thumb.wikimedia.org/wikipedia/commons/thumb/a/ab/Sugar_factory_in_Chino%2C_California%2C_ca.1906_%28CHS-1663%29.jpg/1920px-Sugar_factory_in_Chino%2C_California%2C_ca.1906_%28CHS-1663%29.jpg",
 "turkseker_usak_ic": "https://upload.wikimedia.org/wikipedia/commons/f/f5/U%C5%9Fak_%C5%9Eeker_Fabrikas%C4%B1_Kurulu%C5%9F_%C4%B0%C3%A7_B%C3%B6l%C3%BCm.jpg",
}

for _a in adaylar:
    if _a["kimlik"] not in ADRES and _a.get("ham_url"):
        ADRES[_a["kimlik"]] = _a["ham_url"]

kunye, hata = {}, []
for a in adaylar:
    k = a["kimlik"]
    adres = ADRES.get(k)
    if not adres:
        hata.append(f"{k}: adres yok")
        continue
    uzanti = ".png" if adres.lower().endswith(".png") else ".jpg"
    yol = HEDEF / f"{k}{uzanti}"
    if not yol.exists() or yol.stat().st_size < 4096:
        r = subprocess.run(["curl", "-sS", "--max-time", "90", "-L",
                            "-A", UA, "-o", str(yol), adres], capture_output=True, text=True)
        if r.returncode != 0:
            hata.append(f"{k}: curl {r.returncode} {r.stderr[:70]}")
            continue
    bayt = yol.stat().st_size if yol.exists() else 0
    bas = yol.read_bytes()[:4] if bayt else b""
    # İÇERİK SINANIYOR, ÇIKIŞ KODU DEĞİL. Yanlış adres HTML hata sayfası
    # döndürüyor ve curl buna 0 diyor; ilk denemede tam bu oldu.
    if bayt < 4096 or not (bas.startswith(b"\xff\xd8") or bas.startswith(b"\x89PNG")):
        hata.append(f"{k}: resim değil ({bayt} bayt, baş {bas!r})")
        continue
    kunye[k] = {**{x: a[x] for x in ("bolum", "ad", "nesne_adi", "aciklama", "tarih",
                                     "atif", "kredi", "lisans", "lisans_adresi", "sayfa")},
                "dosya": yol.name, "bayt": bayt, "indirilen_adres": adres}

if kunye:
    (KOK / "gorseller" / "kunye.json").write_text(
        json.dumps({"_kural": "Atıf ve lisans Commons API'sinden geldi, elle yazılmadı.",
                    "_genislik": GENISLIK, "gorseller": kunye},
                   ensure_ascii=False, indent=2), encoding="utf-8")

for k, v in kunye.items():
    print(f"  ✓ §{v['bolum']:>2}  {k:<26} {v['bayt'] / 1024:>7.0f} KB  {v['lisans']}")
if hata:
    print("\n  ✗ " + "\n  ✗ ".join(hata))
    sys.exit(1)
print(f"\n  {len(kunye)} görsel · kunye.json yazıldı")
