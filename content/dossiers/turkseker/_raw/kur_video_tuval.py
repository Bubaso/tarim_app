#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""22 planın hepsini 1920×1080 tuvale yerleştirir — Flow'a yüklenmeye hazır.

NEDEN HEPSİ, YALNIZ DİKEYLER DEĞİL. İlk sürüm yalnız sekiz dikey kareyi
alıyordu. Ama kaynakların en/boyu 1,33'ten 2,82'ye yayılıyor ve 16:9
(1,78) dışındaki her kareyi Flow kendi kırpıyor: 2,82'lik Genel Müdürlük
panoraması ile 1,33'lük kurucu portresi aynı kadrajda bambaşka davranır
ve denetim bizde olmaz.

Hepsi aynı muameleyi görüyor: dosyanın koyu zeminine, tuvalin %92'sine
sığacak biçimde ortalanmış, kenarında ince bir saç çizgisi. Arşiv belgesi
sunar gibi — tutarlı ve kırpma riski sıfır.

ÇEKİM LİSTESİ BURADA DEĞİL. video_plan.json'dan okunuyor; onu
kur_video_metni.py üretiyor. İki yerde tutulan liste er geç ayrışır.

ADLANDIRMA planNN_kimlik.jpg — Flow'un medya seçicisinde sıra böyle
korunuyor; 22 kare tek seferde sürüklenip bırakılabiliyor.

    python3 _raw/kur_video_metni.py      # plan değiştiyse önce bu
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
DOLULUK = 0.92
SAC_CIZGISI = 2

# KIRPMA. Kurumun haber görsellerinin bir kısmı altına "100 Türkşeker"
# logo bandı basılmış hâlde yayımlanıyor. Band belgeyi değil yayını
# anlatıyor ve belgeselde ekranda bir kurum logosu olarak okunur; kesiliyor.
# Değerler oran: (sol, üst, sağ, alt).
KIRP = {
    # Rölyefin iade törenini gösteren tek kare. Alttaki kavisli band sağda
    # %78'e kadar yükseliyor; kesim oradan. Rölyefin kendisi üst yarıda,
    # kayıp yok.
    "turkseker_s25_rolyef_teslim": (0.0, 0.0, 1.0, 0.78),
}


def hex_rgb(s):
    s = s.lstrip("#")
    return tuple(int(s[i:i + 2], 16) for i in (0, 2, 4))


def main():
    plan_yolu = RAW / "video_plan.json"
    if not plan_yolu.exists():
        sys.exit("✗ video_plan.json yok — önce: python3 _raw/kur_video_metni.py")
    planlar = json.loads(plan_yolu.read_text(encoding="utf-8"))["planlar"]

    T = json.loads((KOK / "tasarim.json").read_text(encoding="utf-8"))
    try:
        zemin = hex_rgb(T["palet"]["kapak"]["zemin"]["hex"])
        cizgi = hex_rgb(T["palet"]["kapak"]["sessiz"]["hex"])
    except (KeyError, TypeError) as e:
        sys.exit("✗ tasarim.json'da kapak paleti bulunamadı: %s" % e)

    # ESKİ ÇIKTILAR SİLİNİYOR. Plan değişince eski planNN dosyaları kalır
    # ve Flow'a yanlış kare yüklenir — sessiz ve pahalı bir hata.
    HEDEF.mkdir(exist_ok=True)
    for eski in HEDEF.glob("plan*.jpg"):
        eski.unlink()

    sinir_en, sinir_boy = int(EN * DOLULUK), int(BOY * DOLULUK)
    dikey = 0

    for p in planlar:
        kimlik, no = p["kimlik"], p["no"]
        kaynak = KAYNAK / (kimlik + ".jpg")
        if not kaynak.exists():
            sys.exit("✗ kaynak yok: %s" % kaynak)
        im = Image.open(kaynak).convert("RGB")
        ham = im.size
        if kimlik in KIRP:
            s, u, sa, a = KIRP[kimlik]
            im = im.crop((round(im.width * s), round(im.height * u),
                          round(im.width * sa), round(im.height * a)))
        if im.width < im.height:
            dikey += 1

        # İKİ YÖNDEN DE SIĞDIR. Dikeyde yükseklik, yatayda genişlik
        # kısıtlar; min() ikisini de tek kuralla çözüyor.
        olcek = min(sinir_en / im.width, sinir_boy / im.height)
        yeni = (max(1, round(im.width * olcek)), max(1, round(im.height * olcek)))
        im = im.resize(yeni, Image.LANCZOS)

        tuval = Image.new("RGB", (EN, BOY), zemin)
        x, y = (EN - yeni[0]) // 2, (BOY - yeni[1]) // 2
        c = SAC_CIZGISI
        tuval.paste(Image.new("RGB", (yeni[0] + 2 * c, yeni[1] + 2 * c), cizgi),
                    (x - c, y - c))
        tuval.paste(im, (x, y))

        cik = HEDEF / ("plan%02d_%s.jpg" % (no, kimlik))
        tuval.save(cik, "JPEG", quality=94, subsampling=0)
        print("  %2d %-32s %4dx%-5d %.2f%s  →  %4dx%d  %3.0f KB"
              % (no, kimlik, *ham, ham[0] / ham[1],
                 " kırpıldı" if kimlik in KIRP else "        ",
                 *yeni, cik.stat().st_size / 1024))

    toplam = sum(f.stat().st_size for f in HEDEF.glob("plan*.jpg")) / 1048576
    print("\n✓ %d kare · %.1f MB · %s/" % (len(planlar), toplam, HEDEF.name))
    print("  %d dikey, %d yatay · hepsi 1920×1080" % (dikey, len(planlar) - dikey))
    print("  zemin #%02X%02X%02X · çizgi #%02X%02X%02X (tasarim.json)"
          % (*zemin, *cizgi))
    return 0


sys.exit(main())
