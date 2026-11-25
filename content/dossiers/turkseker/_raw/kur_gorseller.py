#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""yayin.json → bolum_gorselleri. kunye.json + altyazilar.json'dan kuruluyor."""
import json, pathlib
from PIL import Image

KOK = pathlib.Path(__file__).parent.parent
RAW = KOK / "_raw"
KUNYE = json.loads((RAW / "gorseller" / "kunye.json").read_text(encoding="utf-8"))["gorseller"]
ALT = json.loads((RAW / "altyazilar.json").read_text(encoding="utf-8"))
YOL = KOK / "yayin.json"
Y = json.loads(YOL.read_text(encoding="utf-8"))

KOK_URL = "https://tarimportali.net/dosya/turkseker"
# Gözle açılıp bakılan kareler (bkz. altyazilar.json/_gozle_dogrulama).
GOZLE = {"turkseker_alpullu_1928", "turkseker_usak_kurucular",
         "turkseker_usak_hisse", "turkseker_ankara"}
bolumler, hata = {}, []

for kimlik, k in KUNYE.items():
    a = ALT.get(kimlik)
    if not a:
        hata.append(f"{kimlik}: altyazı yok")
        continue
    # ALAN ADLARI seed_dossier.mjs'in BEKLEDİĞİ GİBİ. İlk yazımda
    # altyazı {tr,en} sözlüğü olarak konmuştu ve seed "1. bölümün
    # görselinde 'alt_tr' eksik" diyerek durdu — doğru davranış:
    # atıfsız ya da alt metinsiz görsel yayımlanmıyor.
    dosya = RAW / "gorseller" / k["dosya"]
    with Image.open(dosya) as im:
        g_, y_ = im.size
    atif = k["atif"].strip()
    # Atıf biçimi: "Üreten — Lisans". Lisans ayrıca kendi alanında duruyor
    # ama atıf satırı görselin ALTINDA tek başına görünüyor (§8.4).
    # TEKRAR İKİ YÖNLÜ. §12'nin kurum karesinde atıf "Türkiye Şeker
    # Fabrikaları A.Ş.", lisans ise onu İÇEREN daha uzun cümle; tek yönlü
    # kontrol kurum adını iki kez yazdırıyordu. Hangi taraf ötekini
    # içeriyorsa uzun olan kalıyor.
    lis = (k["lisans"] or "").strip()
    if lis:
        if atif.lower() in lis.lower():
            atif = lis
        elif lis.lower() not in atif.lower():
            atif = f"{atif} — {lis}"
    bolumler[k["bolum"]] = {
        "url": f"{KOK_URL}/{k['dosya']}",
        "atif": atif,
        "lisans": k["lisans"],
        "alt_tr": a["tr"],
        "alt_en": a["en"],
        "en_boy": round(g_ / y_, 4),
        "_kimlik": kimlik,
        "_commons": k["sayfa"],
        "_lisans_adresi": k["lisans_adresi"] or None,
        "_gozle_dogrulandi": kimlik in GOZLE,
        "_dayanak": a["_dayanak"],
    }

# §15 galeri, §16 kaynakça: ikisi de BAŞ GÖRSEL almıyor. Galerinin otuz yedi
# karesi var; üstüne bir de tek bir "bölüm görseli" koymak, ızgaranın önüne
# sebepsiz bir kapak asmak olurdu.
# NUMARA SABİT DEĞİL. Tur 9'da on üç bölüm araya girdi ve galeri 15'ten
# 28'e, kaynakça 16'dan 29'a kaydı. Sabit numara yazmak yerine SON İKİ
# bölüm alınıyor: galeri ve kaynakça her zaman sonda.
BASSIZ = {n for n in sorted(
    (x for x in Y["_bolum_basliklari"] if not x.startswith("_")), key=int)[-2:]}
bekl = {n for n in Y["_bolum_basliklari"] if not n.startswith("_") and n not in BASSIZ}
eksik = bekl - set(bolumler)
if eksik:
    hata.append(f"görseli olmayan bölüm: {sorted(eksik, key=int)}")
if hata:
    raise SystemExit("✗ " + "\n  ".join(hata))

Y["bolum_gorselleri"] = {
    "_amac": "Grafik veriyi anlatır, görsel konuyu gösterir. Atıfsız görsel yayımlanmaz (§2.4).",
    "_kaynak": "Hepsi Wikimedia Commons; atıf ve lisans Commons API'sinden çekildi, elle yazılmadı.",
    "_kural": "HER BÖLÜMDE BİR GÖRSEL — kullanıcı kuralı. dogrula_yayin.py boş bölümü hata sayıyor.",
    "_altyazi_kurali": ALT["_kural"],
    "_yer_kurali": ALT["_yer_kurali"],
    "_gozle_dogrulama": ALT["_gozle_dogrulama"],
    "_kitlik": json.loads((RAW / "gorsel_adaylari.json").read_text(encoding="utf-8"))["_kitlik_bulgusu"],
    "_bos_birakilanlar": "YOK.",
    **{n: bolumler[n] for n in sorted(bolumler, key=int)},
}
YOL.write_text(json.dumps(Y, ensure_ascii=False, indent=2), encoding="utf-8")
print(f"  ✓ {len(bolumler)} bölüm görseli yerleştirildi (galeri ve kaynakça baş görselsiz)")
lis = {}
for b in bolumler.values():
    lis[b["lisans"]] = lis.get(b["lisans"], 0) + 1
print("  lisanslar: " + " · ".join(f"{k} {v}" for k, v in sorted(lis.items())))
