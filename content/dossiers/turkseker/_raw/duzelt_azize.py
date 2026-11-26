#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Azize–Betül akrabalığı ters yazılmıştı. 26 Kasım 2026.

NE OLDU. Galeri karesi `galeri_salt_hasat_mektup`un Türkçe altyazısı
"Azize'nin ablası Betül'e mektubu" diyordu — yani Betül abla, Azize kardeş.
Mektup video için 16:9 tuvale yerleştirilince okunur hâle geldi ve imza
bunun tersini söylüyor:

    "...senden mektup beklerim gözlerinden öperim ablan
     Azize"

"ablan Azize" = Azize ABLA, Betül KARDEŞ. Mektubun hitabı da bunu
destekliyor: "Benim canım Betülüm", "Betülcüm".

NEDEN GÖZDEN KAÇTI. Kare galeriye el yazısı okunmadan, SALT kaydının
başlığıyla yerleştirilmişti; akrabalık oradan değil, yorumdan gelmiş.
1012×1600'lük kare galeri ızgarasında 560 piksele inerek görünüyor ve o
ölçekte el yazısı okunmuyor.

İNGİLİZCESİ YANLIŞ DEĞİLDİ — "her sister Betül" diyordu, İngilizce
abla/kardeş ayrımı yapmıyor. Yine de artık bildiğimiz için "younger"
ekleniyor.

TEK KAYNAK galeri_altyazilar.json. kur_galeri.py oradan okuyup
galeri.json'a, build_data.py data.json'a, seed_dossier.mjs veritabanına
taşıyor. salt_yerlestir.py de düzeltiliyor: tarihsel bir kayıt ama yeniden
koşarsa hatayı geri getirirdi.

    python3 _raw/duzelt_azize.py
"""
import pathlib
import sys

RAW = pathlib.Path(__file__).resolve().parent

DEGISIMLER = [
    ("galeri_altyazilar.json",
     '"tr": "Aynı fotokartın arka yüzü: Azize\'nin ablası Betül\'e mektubu."',
     '"tr": "Aynı fotokartın arka yüzü: Azize\'den kardeşi Betül\'e mektup."'),
    ("galeri_altyazilar.json",
     '"en": "The reverse of the same photocard: a letter from Azize to her sister Betül."',
     '"en": "The reverse of the same photocard: a letter from Azize to her younger sister Betül."'),

    # Tek seferlik yerleştirme betiği. Yeniden koşarsa hatayı geri getirir.
    ("salt_yerlestir.py",
     '"Aynı fotokartın arka yüzü: Azize\'nin ablası Betül\'e mektubu."',
     '"Aynı fotokartın arka yüzü: Azize\'den kardeşi Betül\'e mektup."'),

    # Depo belgesi.
    ("README.md",
     "toplanırken\"* yazıyor; arka yüzünde Azize'nin ablası Betül'e mektubu var.",
     "toplanırken\"* yazıyor; arka yüzünde Azize'den kardeşi Betül'e mektup var."),
    ("README.md",
     "İki kare bilerek arka yüz: Azize'nin ablası Betül'e mektubu ve \"Pancar",
     "İki kare bilerek arka yüz: Azize'den kardeşi Betül'e mektup ve \"Pancar"),

    # ── AYNI YAZIŞMANIN ÖTEKİ İKİ KARESİ ────────────────────────────────
    # Mektup okunabilir hâle gelince ötekiler de açıldı. Üçü de aynı
    # kişiden: Azize'den kardeşi Betül'e. İmzalar:
    #   galeri_salt_hasat_mektup        "ablan / Azize"
    #   galeri_salt_usak_havuz_arka     "ablan Azize"
    #   galeri_salt_usak_havuz_2_arka   "seni seven ablan / Azize Kıpçak"
    # Soyadı yalnız sonuncusunda görünüyor; altyazıda da yalnız orada
    # yazılıyor — künye karede ne varsa onu söyler.
    #
    # 115 YANLIŞ DEĞİLDİ, belirsizdi ("Betül'e yazılmış bir mektup").
    # 117 İSE TERSTİ: "ablasına yazılmış" diyordu, oysa mektubu ablası
    # YAZMIŞ. İngilizcesi de aynı şekilde ters: "to an elder sister".
    ("galeri_altyazilar.json",
     '"tr": "Uşak Şeker Fabrikası Sosyal Tesisleri fotokartının arka yüzü: Betül\'e yazılmış bir mektup."',
     '"tr": "Uşak Şeker Fabrikası Sosyal Tesisleri fotokartının arka yüzü: Azize\'den kardeşi Betül\'e mektup."'),
    ("galeri_altyazilar.json",
     '"en": "The reverse of a photocard of the social facilities of the Uşak Sugar Factory: a letter written to Betül."',
     '"en": "The reverse of a photocard of the social facilities of the Uşak Sugar Factory: a letter from Azize to her younger sister Betül."'),
    ("galeri_altyazilar.json",
     '"tr": "Aynı fotokartın arka yüzü: ablasına yazılmış bir mektup."',
     '"tr": "Aynı fotokartın arka yüzü: Azize Kıpçak\'tan kardeşi Betül\'e mektup."'),
    ("galeri_altyazilar.json",
     '"en": "The reverse of the same photocard: a letter written to an elder sister."',
     '"en": "The reverse of the same photocard: a letter from Azize Kıpçak to her younger sister Betül."'),

    # Video metninin üreteci. video_metni.md yeniden üretilince düzelir.
    ("kur_video_metni.py",
     "Arka yüzünde bir mektup var: Azize, ablası Betül'e yazmış. Fotokart Salt",
     "Arka yüzünde bir mektup var: Azize, kardeşi Betül'e yazmış. Fotokart Salt"),
    ("kur_video_metni.py",
     '("Azize\'nin ablası Betül\'e mektubu", "galeri karesi `galeri_salt_hasat_mektup` altyazısı"),',
     '("Azize\'den kardeşi Betül\'e mektup", "karenin altyazısı · imza: \\"ablan Azize\\""),'),
]


def main():
    # YENİDEN KOŞULABİLİR. Betik bir kez koşmuştu, sonra aynı yazışmanın
    # öteki iki karesi bulunup listeye eklendi. Uygulanmış bir değişimin
    # eskisi artık bulunmuyor; bunu hata saymak yerine YENİSİNİN yerinde
    # olduğu sınanıyor. Ne eskisi ne yenisi varsa gerçekten hata var.
    metinler = {}
    yapilacak = []
    for ad, eski, yeni in DEGISIMLER:
        if ad not in metinler:
            metinler[ad] = (RAW / ad).read_text(encoding="utf-8")
        n = metinler[ad].count(eski)
        if n == 1:
            yapilacak.append((ad, eski, yeni))
        elif n == 0 and yeni in metinler[ad]:
            continue                      # zaten uygulanmış
        else:
            print("✗ %s · eski %d kez bulundu, yeni %s"
                  % (ad, n, "var" if yeni in metinler[ad] else "YOK"))
            print("  aranan: " + eski[:160])
            return 1

    if not yapilacak:
        print("· değişen bir şey yok, hepsi zaten uygulanmış")
        return 0

    for ad, eski, yeni in yapilacak:
        metinler[ad] = metinler[ad].replace(eski, yeni, 1)
    for ad, icerik in metinler.items():
        (RAW / ad).write_text(icerik, encoding="utf-8")
        print("· %s yazıldı" % ad)

    kalan = [ad for ad in metinler if "ablası Betül" in (RAW / ad).read_text(encoding="utf-8")]
    if kalan:
        print("\n✗ kalıntı: " + ", ".join(kalan))
        return 1

    print("\n✓ akrabalık düzeltildi")
    print("  sıradaki: ./yenile.sh  →  seed_dossier.mjs  →  göç")
    return 0


sys.exit(main())
