#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Üçüncü parti: çiftçi, tarla ve şeker dışı kalemler.

Kullanıcı (24 Kasım 2026): "galeri tarafında çifti, tarla ve kurumun şeker
dışı üretim kalemleri yönleri eksik kaldı… sadece kuruma değil web'e de bak…
geniş tur at web'te" ve "galeriye ekleyeceğin görselleri 118'den sonra
devamına ekle."

ÖLÇÜLEN EKSİK. Eleme sonrası galeride tarla öbeğinde 6 kare vardı ve altısı
da tohumla ilgiliydi; ürün öbeğinde 2 kare; hasat öbeği boştu.

WEB TARANDI, COMMONS BOŞ ÇIKTI. Category:Sugar beets in Turkey = 2 dosya.
"Sugar beet fields" altındaki ülke kategorileri Belçika, Finlandiya,
Fransa, Almanya, Japonya, Slovakya, İsveç, İsviçre, İngiltere ve ABD;
Türkiye yok. Kullanıcının 23 Kasım kuralı yurtdışı tarlasını dışarıda
bırakıyor, dolayısıyla bu yön Commons'tan dolmuyor.

İKİ TÜRK KAYNAĞI VERİM VERDİ:
  1. Kurumun haber arşivinde İNDİRİLMEMİŞ 88 haber vardı (509 kare).
     Çiftçi, çiftçi lokali, sözleşme ve sulama kareleri orada duruyordu.
  2. Kurumun 2024-2028 Stratejik Planı PDF'i kendi fotoğraflarını taşıyor:
     hasat makinesi, melas, pelet tohum, çuvallama.

NE ELENDİ. 5129 numaralı haberin 101 karesi (sempozyum: kürsü, katılım
belgesi, salon), afişler ve bilgi grafikleri, stok görünümlü süs kareleri
(satranç, yapboz, merdiven).

YENİ ÖBEK: ÇİFTÇİ. Kullanıcının adını koyduğu yön mevcut öbeklerin hiçbirine
oturmuyordu — tarla toprağı, işçi fabrikayı anlatıyor. Akışta tarlanın hemen
ardına kondu: toprak → onu eken insan → fabrikadaki el.
"""
import json
import pathlib
import shutil
import sys

from PIL import Image

RAW = pathlib.Path(__file__).parent
HEDEF = RAW / "gorseller"
SC = pathlib.Path("/private/tmp/claude-502/-Users-BURHAN-Desktop/"
                  "597dfc7b-cfff-4806-ba01-33aa08a98d6d/scratchpad")
TAVAN = 1600

KURUM_ATIF = "Türkiye Şeker Fabrikaları A.Ş."
KURUM_LISANS = "Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını"
HABER_URL = "https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID={}"
PLAN_URL = "https://www.turkseker.gov.tr/Belgeler/stratejik_plan_12_09_2024_v4.pdf"
PLAN_ADI = "TÜRKŞEKER 2024-2028 Stratejik Planı"

HABER = {
    "62":   ("1 Eylül 2021", "1 September 2021",
             "Türkşeker'den Çiftçimize 650 Milyon TL Destek!"),
    "63":   ("6 Eylül 2021", "6 September 2021",
             "Türkşeker Çiftçi Lokalleri Yeni Üretim Sezonuna Hazır!"),
    "72":   ("18 Mart 2022", "18 March 2022",
             "Türkşeker Pancar Avans Fiyatını Artırdı!"),
    "73":   ("24 Haziran 2022", "24 June 2022", "Avans Ödemesi"),
    "3080": ("22 Nisan 2025", "22 April 2025",
             "Türkşeker'in İlk Tarım Ekolojik Marketi Ankara'da Açıldı!"),
    "5088": ("4 Eylül 2025", "4 September 2025",
             "Türkşeker Lojistik Filosu Yatırımlarla Güçleniyor"),
    "5099": ("19 Aralık 2025", "19 December 2025",
             "TAGEM Ürünleri TÜRKŞEKER Ekolojik Marketlerinde"),
}

# ── GALERİYE (parti 4) ────────────────────────────────────────────────────
# (kaynak dosya, kimlik, öbek, haber kimliği ya da None=plan, tr, en)
GALERI = [
    # ÇİFTÇİ
    ("62__Turkseker__5.jpeg", "galeri_ciftci_pancarla", "ciftci", "62",
     "Elinde şeker pancarıyla bir üretici, pancar tarlasında.",
     "A grower holding sugar beet in a beet field."),
    ("62__Turkseker__3.jpg", "galeri_ciftci_traktor", "ciftci", "62",
     "Ekim yapılan tarlada bir üretici ve mibzerli traktör.",
     "A grower and a tractor with a seed drill in a field being sown."),
    ("63__63_Haberler2021_09_06_09_40_39_060.jpg", "galeri_ciftci_lokal_masa", "ciftci", "63",
     "Çiftçi Lokali'nde üreticiler.",
     "Growers at a Çiftçi Lokali, the company's rest house for growers."),
    ("63__63_Haberler2021_09_06_09_40_44_562.JPG", "galeri_ciftci_lokal_gece", "ciftci", "63",
     "Bir Çiftçi Lokali, gece.",
     "A Çiftçi Lokali at night."),
    ("63__63_Haberler2021_09_06_09_40_50_702.jpg", "galeri_ciftci_lokal_cay", "ciftci", "63",
     "Çiftçi Lokali'nde çay içen üreticiler.",
     "Growers drinking tea at a Çiftçi Lokali."),
    ("72__72_Haberler2022_03_18_13_50_40_728.jpeg", "galeri_ciftci_sozlesme_kitapcik", "ciftci", "72",
     "Elinde şeker pancarı sözleşmesi kitapçığıyla bir üretici.",
     "A grower holding the company's beet contract booklet."),
    ("72__72_Haberler2022_03_18_13_50_45_179.jpeg", "galeri_ciftci_sozlesme_imza", "ciftci", "72",
     "Pancar sözleşmelerinin imzalanması.",
     "Beet contracts being signed."),
    # TARLA
    ("62__Turkseker__4.jpg", "galeri_tarla_mibzer", "tarla", "62",
     "Mibzerle pancar ekimi.",
     "Sowing beet with a seed drill."),
    ("72__72_Haberler2022_03_18_13_50_50_505.jpeg", "galeri_tarla_makine", "tarla", "72",
     "Pancar tarlasında tarım makinesi.",
     "An agricultural machine in a beet field."),
    ("73__73_Haberler2022_06_27_14_07_19_721.jpeg", "galeri_tarla_sulama_1", "tarla", "73",
     "Sulanan şeker pancarı tarlası.",
     "A sugar beet field under irrigation."),
    ("73__73_Haberler2022_06_27_14_07_23_197.jpeg", "galeri_tarla_sulama_isci", "tarla", "73",
     "Şeker pancarı tarlasında çalışanlar ve sulama.",
     "Workers and irrigation in a sugar beet field."),
    ("73__73_Haberler2022_06_27_14_07_26_676.jpeg", "galeri_tarla_sulama_2", "tarla", "73",
     "Sulanan şeker pancarı tarlası.",
     "A sugar beet field under irrigation."),
    ("stratejik_plan_s036_15.jpg", "galeri_tarla_hasat_makinesi", "hasat", None,
     "Şeker pancarı hasadı.",
     "The sugar beet harvest."),
    ("stratejik_plan_s064_25.jpg", "galeri_tarla_siralar", "tarla", None,
     "Tarlada şeker pancarı sıraları.",
     "Rows of sugar beet in a field."),
    ("stratejik_plan_s102_32.jpg", "galeri_tarla_traktor_plan", "tarla", None,
     "Pancar tarlasında traktör.",
     "A tractor in a beet field."),
    ("stratejik_plan_s059_22.jpg", "galeri_tarla_pelet_tohum", "tarla", None,
     "Pelet kaplı şeker pancarı tohumu.",
     "Pelleted sugar beet seed."),
    # YÜKLEME
    ("72__72_Haberler2022_03_18_13_50_53_787.jpeg", "galeri_yukleme_su_kanali", "yukleme", "72",
     "Fabrikaya gelen pancarın su kanalına verilmesi.",
     "Beet arriving at the factory being fed into the water flume."),
    ("stratejik_plan_s031_14.jpg", "galeri_yukleme_silo_bant", "yukleme", None,
     "Fabrika sahasında pancar siloları ve taşıma bandı.",
     "Beet silos and a conveyor in a factory yard."),
    ("5088__5088_Haberler2025_09_04_17_00_38_600.jpg", "galeri_yukleme_filo", "yukleme", "5088",
     "TÜRKŞEKER lojistik filosu.",
     "The TÜRKŞEKER logistics fleet."),
    # İŞÇİ
    ("stratejik_plan_s100_30.jpg", "galeri_isci_montaj", "isci", None,
     "TÜRKŞEKER çalışanları bir tesisin montajında.",
     "TÜRKŞEKER staff assembling a plant unit."),
    # ÜRÜN ve ŞEKER DIŞI
    ("stratejik_plan_s038_16.jpg", "galeri_urun_cuvallama", "urun", None,
     "TÜRKŞEKER şekerinin çuvallanması.",
     "TÜRKŞEKER sugar being bagged."),
    ("stratejik_plan_s105_34.jpg", "galeri_urun_kristal", "urun", None,
     "Kristal şeker.",
     "Crystal sugar."),
    ("3080__3080_Haberler2025_04_22_12_30_09_384.jpeg", "galeri_urun_market_raf", "urun", "3080",
     "TÜRKŞEKER Tarım Ekolojik Market'te raflar.",
     "The shelves of a TÜRKŞEKER agricultural ecological market."),
    ("5099__5099_Haberler2025_12_19_14_11_35_702.jpg", "galeri_cevresi_sera", "cevresi", "5099",
     "Ankara Şeker Fabrikası yerleşkesindeki serada TAGEM protokolünün imzalanması.",
     "The TAGEM protocol being signed in the greenhouse on the Ankara Sugar "
     "Factory estate."),
]

# ── §14'ÜN BÖLÜM GÖRSELİ ──────────────────────────────────────────────────
# Kullanıcı: "şeker dışı ile ilgili olan bölüme bunlardan bir tanesini
# kullanalım (melas, küspe vb..)". §14 "Şekerden sonra kalanlar" melasla
# açılıyor; mevcut karesi Alpullu albümünün bir iç mekân sayfasıydı ve
# konuyla bağı yoktu.
BOLUM14 = ("stratejik_plan_s040_17.jpg", "turkseker_s14_melas",
           "Melas, şeker üretiminin yan ürünü.",
           "Molasses, a by-product of sugar production.")


def kaynak_yolu(ad):
    for d in ("foto10", "pdf_gorsel"):
        p = SC / d / ad
        if p.exists():
            return p
    return None


def yerlestir(ad, kimlik):
    src = kaynak_yolu(ad)
    if src is None:
        return None
    uz = ".png" if ad.lower().endswith(".png") else ".jpg"
    yol = HEDEF / ("%s%s" % (kimlik, uz))
    if not yol.exists():
        shutil.copy2(src, yol)
    with Image.open(yol) as im:
        im.load()
        if max(im.size) > TAVAN:
            im = im.convert("RGB")
            im.thumbnail((TAVAN, TAVAN))
            im.save(yol, "JPEG", quality=88, optimize=True)
        elif uz == ".png":
            im.convert("RGB").save(yol.with_suffix(".jpg"), "JPEG",
                                   quality=92, optimize=True)
            yol.unlink()
            yol = yol.with_suffix(".jpg")
    return yol


def kunye(hid, tr):
    if hid is None:
        return {"sayfa": PLAN_URL, "atif": KURUM_ATIF,
                "kredi": PLAN_ADI, "lisans": KURUM_LISANS,
                "dayanak": "%s (%s); yayının kendi fotoğrafı." % (PLAN_ADI, PLAN_URL)}
    tarih_tr, _tarih_en, baslik = HABER[hid]
    return {"sayfa": HABER_URL.format(hid), "atif": KURUM_ATIF,
            "kredi": "turkseker.gov.tr haber arşivi", "lisans": KURUM_LISANS,
            "dayanak": "turkseker.gov.tr haberi %s, “%s”, %s (%s)."
                       % (hid, baslik, tarih_tr, HABER_URL.format(hid))}


def main():
    sec_yol = RAW / "galeri_secim.json"
    gk_yol = HEDEF / "galeri_kunye.json"
    ga_yol = RAW / "galeri_altyazilar.json"
    ku_yol = HEDEF / "kunye.json"
    alt_yol = RAW / "altyazilar.json"
    SEC = json.loads(sec_yol.read_text(encoding="utf-8"))
    GK = json.loads(gk_yol.read_text(encoding="utf-8"))
    GA = json.loads(ga_yol.read_text(encoding="utf-8"))
    KU = json.loads(ku_yol.read_text(encoding="utf-8"))
    ALT = json.loads(alt_yol.read_text(encoding="utf-8"))

    once = len(SEC["kareler"])
    var = {k["kimlik"] for k in SEC["kareler"]}
    hata, eklenen = [], 0

    for ad, kimlik, obek, hid, tr, en in GALERI:
        if kimlik in var:
            continue
        yol = yerlestir(ad, kimlik)
        if yol is None:
            hata.append("kaynak yok: %s" % ad)
            continue
        k = kunye(hid, tr)
        GK["kareler"][kimlik] = {
            "adres": None, "asil": None, "sayfa": k["sayfa"],
            "mime": "image/jpeg", "nesne_adi": tr.rstrip("."), "aciklama": tr,
            "tarih": None, "atif": k["atif"], "kredi": k["kredi"],
            "lisans": k["lisans"], "lisans_adresi": None,
            "ad": ad, "dosya": yol.name, "bayt": yol.stat().st_size,
            "kaynak_turu": "kurum", "obek": obek,
        }
        GA[kimlik] = {"tr": tr, "en": en, "_dayanak": k["dayanak"]}
        SEC["kareler"].append({"kimlik": kimlik, "kaynak": "kurum",
                               "dosya": ad, "obek": obek, "parti": 4})
        eklenen += 1

    # ── §14 ───────────────────────────────────────────────────────────────
    ad, kimlik, tr, en = BOLUM14
    eski = next((k for k, v in KU["gorseller"].items() if str(v["bolum"]) == "14"), None)
    if eski is None:
        hata.append("§14'ün mevcut görseli bulunamadı")
    elif kimlik not in KU["gorseller"]:
        yol = yerlestir(ad, kimlik)
        if yol is None:
            hata.append("§14 kaynağı yok: %s" % ad)
        else:
            k = kunye(None, tr)
            KU["gorseller"].pop(eski)
            ALT.pop(eski, None)
            KU["gorseller"][kimlik] = {
                "bolum": "14", "ad": ad, "nesne_adi": tr.rstrip("."),
                "aciklama": tr, "tarih": None, "atif": k["atif"],
                "kredi": k["kredi"], "lisans": k["lisans"],
                "lisans_adresi": None, "sayfa": k["sayfa"],
                "dosya": yol.name, "bayt": yol.stat().st_size,
                "indirilen_adres": None,
            }
            ALT[kimlik] = {"tr": tr, "en": en, "_dayanak": k["dayanak"]}

    if hata:
        raise SystemExit("✗ " + "\n  ".join(hata))

    SEC["_parti4"] = (
        "24 Kasım 2026: kullanıcı çiftçi, tarla ve şeker dışı kalemleri eksik "
        "buldu. Commons'ta Türkiye'den tarla yok (Category:Sugar beets in "
        "Turkey = 2 dosya); kareler kurumun indirilmemiş 88 haberinden ve "
        "2024-2028 Stratejik Planı'ndan geldi. Yeni öbek: ciftci.")
    sec_yol.write_text(json.dumps(SEC, ensure_ascii=False, indent=2), encoding="utf-8")
    gk_yol.write_text(json.dumps(GK, ensure_ascii=False, indent=2), encoding="utf-8")
    ga_yol.write_text(json.dumps(GA, ensure_ascii=False, indent=2), encoding="utf-8")
    ku_yol.write_text(json.dumps(KU, ensure_ascii=False, indent=2), encoding="utf-8")
    alt_yol.write_text(json.dumps(ALT, ensure_ascii=False, indent=2), encoding="utf-8")

    from collections import Counter
    ob = Counter(o for _a, _k, o, _h, _t, _e in GALERI)
    print("  ✓ %d kare eklendi · galeri %d → %d" % (eklenen, once, len(SEC["kareler"])))
    print("  öbekler: " + " · ".join("%s %d" % (a, b) for a, b in sorted(ob.items())))
    print("  ✓ §14 görseli melas karesiyle değişti (eski kare emekli, dosyası duruyor)")


main()
