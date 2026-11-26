#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Dikey kareleri 16:9 tuvale yerleştirir — Flow'a verilmeye hazır.

NEDEN. Video 16:9. Flow'a dikey bir kare verilirse kadraja KIRPAR; 0,63
en/boylu bir mektubun 16:9'a kırpılması belgeden bir şerit bırakır. Sekiz
kaynak dikey, dördü de belge (mektup, hisse senedi, rölyef, melas kavanozu).

ÇÖZÜM: kareyi dosyanın kendi koyu zeminine ortalamak — belge sunar gibi.
İş yerelde yapılıyor, kredi harcamıyor ve kadrajın denetimi bizde kalıyor.

ÖLÇÜ. Yüksekliğin %92'si. Kalan pay üstte ve altta eşit; kenarda ince bir
saç çizgisi, karenin nerede bittiğini belli ediyor. Büyütme sorun değil:
tuval 1920×1080, 720p çıkışta 1280×720'ye inecek, yani 994 piksellik kare
663'e düşüyor — en küçük kaynak (melas, 568×661) bile orada kendi
boyutunun altında kalıyor.

RENK KODA GÖMÜLMÜYOR. Zemin ve çizgi tasarim.json'dan okunuyor; dosyanın
paleti değişirse tuval de değişir.

    python3 _raw/kur_video_tuval.py
"""
import json
import pathlib
import sys

from PIL import Image

KOK = pathlib.Path(__file__).resolve().parent.parent
RAW = KOK / "_raw"
KAYNAK = RAW / "gorseller"
HEDEF = RAW / "video_kareleri"

EN, BOY = 1920, 1080
DOLULUK = 0.92          # yüksekliğin kaçını kaplasın
SAC_CIZGISI = 2         # piksel

# Çekim listesindeki ▲ işaretli sekiz kare. Sıra video_metni.md'deki plan
# numarasına göre.
DIKEYLER = [
    (4,  "turkseker_usak_hisse"),
    (7,  "galeri_salt_hasat_mektup"),
    (9,  "galeri_salt_silo"),
    (13, "galeri_tarla_hasat_makinesi"),
    (15, "turkseker_s14_melas"),
    (16, "galeri_urun_cuvallama"),
    (18, "galeri_kurum_malatya_bosaltma"),
    (21, "turkseker_s25_rolyef_teslim"),
]


def hex_rgb(s):
    s = s.lstrip("#")
    return tuple(int(s[i:i + 2], 16) for i in (0, 2, 4))


def main():
    T = json.loads((KOK / "tasarim.json").read_text(encoding="utf-8"))
    try:
        zemin = hex_rgb(T["palet"]["kapak"]["zemin"]["hex"])
        cizgi = hex_rgb(T["palet"]["kapak"]["sessiz"]["hex"])
    except (KeyError, TypeError) as e:
        sys.exit("✗ tasarim.json'da kapak paleti bulunamadı: %s" % e)

    HEDEF.mkdir(exist_ok=True)
    hedef_boy = int(BOY * DOLULUK)
    yazilan = 0

    for no, kimlik in DIKEYLER:
        p = KAYNAK / (kimlik + ".jpg")
        if not p.exists():
            sys.exit("✗ kaynak yok: %s" % p)
        im = Image.open(p).convert("RGB")

        # DİKEY OLDUĞU SINANIYOR. Liste elle yazıldı; kaynak bir gün yatay
        # bir kareyle değişirse tuvale koymak yanlış olur ve sessiz kalır.
        if im.width >= im.height:
            sys.exit("✗ %s dikey değil (%dx%d) — çekim listesini gözden geçir"
                     % (kimlik, im.width, im.height))

        olcek = hedef_boy / im.height
        yeni = (max(1, round(im.width * olcek)), hedef_boy)
        if yeni[0] >= EN:
            sys.exit("✗ %s tuvale sığmıyor (%dx%d) — DOLULUK düşürülmeli"
                     % (kimlik, *yeni))
        im = im.resize(yeni, Image.LANCZOS)

        tuval = Image.new("RGB", (EN, BOY), zemin)
        x, y = (EN - yeni[0]) // 2, (BOY - yeni[1]) // 2

        # Saç çizgisi karenin ARKASINA, biraz taşan bir dikdörtgen olarak
        # konuyor; görüntünün kendi pikselleri örtülmüyor.
        c = SAC_CIZGISI
        tuval.paste(Image.new("RGB", (yeni[0] + 2 * c, yeni[1] + 2 * c), cizgi),
                    (x - c, y - c))
        tuval.paste(im, (x, y))

        cik = HEDEF / ("plan%02d_%s.jpg" % (no, kimlik))
        tuval.save(cik, "JPEG", quality=94, subsampling=0)
        print("· plan %-3d %-32s %4dx%-4d → %dx%d  (%.0f KB)"
              % (no, kimlik, yeni[0], yeni[1], EN, BOY,
                 cik.stat().st_size / 1024))
        yazilan += 1

    print("\n✓ %d kare %s altına yazıldı" % (yazilan, HEDEF.name))
    print("  zemin #%02X%02X%02X · çizgi #%02X%02X%02X (tasarim.json)"
          % (*zemin, *cizgi))
    return 0


sys.exit(main())
