#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Galeriden tekrar eden kareleri çıkarır.

24 Kasım 2026'da ikinci parti eklendikten sonra algısal karşılaştırma on üç
çift buldu. Hiçbiri adresten görünmüyordu: aynı fotoğraf farklı kaynaktan,
farklı dosya adıyla iki kez girmişti.

  · Yedisi Commons'tan yeniden alınmış BÖLÜM GÖRSELİ. Dosyanın bölüm
    kareleri zaten Commons'tan gelmişti; yeni seçim onları bir kez daha
    aldı. galeri_ek.py SALT adaylarını bölüm görselleriyle karşılaştırıyordu
    ama Commons listesi elle yazılmıştı ve o süzgeçten geçmedi.
  · Biri SALT albüm sayfası (§1'in karesi albümün 007. sayfası).
  · Üçü SALT'ın Etimesgut kaydındaki ÇİFT TARAMA — aynı kare iki ayrı
    dosya olarak taranmış.
  · İkisi ilk 79'un içinde duruyordu ve bugüne dek fark edilmemişti.

Bölüm görseli her zaman kalıyor, galeri karesi çıkıyor (7. kuralın niyeti
bu). Galeri içi çiftte kurumun kendi yayını tercih ediliyor.

Dosyalar diskte SİLİNMİYOR: kur_yayin_gorselleri.py artık kullanılmayanları
sayıyor, silmiyor. Yayındaki bir adresi kırma kararını betik veremez.
"""
import json
import pathlib
import sys

RAW = pathlib.Path(__file__).parent

# kimlik → neden
CIKAR = {
    "galeri_salt_alb_007":     "§1'in bölüm görseli (Alpullu albümü, 007)",
    "galeri_usak_kurucular":   "§2'nin bölüm görseli",
    "galeri_usak_hisse":       "§3'ün bölüm görseli",
    "galeri_usak_kurulus_dis": "§4'ün bölüm görseli",
    "galeri_eskisehir_giris":  "§5'in bölüm görseli",
    "galeri_bogazliyan":       "§7'nin bölüm görseli",
    "galeri_erzurum_giris":    "§14'ün bölüm görseli",
    "galeri_salt_etim_1":      "§24'ün bölüm görseli (SALT çift tarama)",
    "galeri_usak_kurulus_ic":  "§27'nin bölüm görseli",
    "galeri_eskisehir_2018":   "galeri_fab_eskisehir ile aynı kare; "
                               "kurumun kendi yayını tutuldu",
    "galeri_salt_etim_k010":   "galeri_salt_etim_4 ile aynı kare",
    "galeri_salt_etim_k013":   "galeri_salt_etim_5 ile aynı kare",
    "galeri_salt_etim_k016":   "galeri_salt_etim_7 ile aynı kare",
}


def main():
    sec_yol = RAW / "galeri_secim.json"
    ku_yol = RAW / "gorseller" / "galeri_kunye.json"
    alt_yol = RAW / "galeri_altyazilar.json"
    SEC = json.loads(sec_yol.read_text(encoding="utf-8"))
    KUDOSYA = json.loads(ku_yol.read_text(encoding="utf-8"))
    ALT = json.loads(alt_yol.read_text(encoding="utf-8"))

    var = {k["kimlik"] for k in SEC["kareler"]}
    kalan = [k for k in CIKAR if k in var]
    if not kalan:
        print("  · çıkarılacak kare yok, daha önce koşmuş")
        return
    # TEK YÖNLÜ DEĞİL AMA GÜVENLİ: ikinci koşuda liste boş çıkar.
    eksik = [k for k in CIKAR if k not in var]
    if eksik and len(eksik) != len(CIKAR):
        sys.exit("✗ liste yarım uygulanmış, elle bak: " + ", ".join(eksik))

    once = len(SEC["kareler"])
    SEC["kareler"] = [k for k in SEC["kareler"] if k["kimlik"] not in CIKAR]
    for kimlik in CIKAR:
        KUDOSYA["kareler"].pop(kimlik, None)
        ALT.pop(kimlik, None)

    SEC["_tekrar_cikarma"] = (
        "24 Kasım 2026: algısal karşılaştırma (dHash) on üç tekrar buldu ve "
        "hepsi çıkarıldı — yedisi Commons'tan yeniden alınmış bölüm görseli, "
        "biri SALT albüm sayfası, üçü SALT'ın çift taraması, ikisi ilk 79'un "
        "içinde duran eski tekrar. Gerekçeler galeri_cikar.py/CIKAR içinde. "
        "dogrula_galeri.py 13. kural bundan sonra adrese değil görüntüye "
        "bakıyor.")
    sec_yol.write_text(json.dumps(SEC, ensure_ascii=False, indent=2),
                       encoding="utf-8")
    ku_yol.write_text(json.dumps(KUDOSYA, ensure_ascii=False, indent=2),
                      encoding="utf-8")
    alt_yol.write_text(json.dumps(ALT, ensure_ascii=False, indent=2),
                       encoding="utf-8")

    for kimlik, neden in CIKAR.items():
        print("  − %-26s %s" % (kimlik, neden))
    print("\n  ✓ %d kare çıkarıldı · galeri %d → %d"
          % (len(CIKAR), once, len(SEC["kareler"])))


main()
