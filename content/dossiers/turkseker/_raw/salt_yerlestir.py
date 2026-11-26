#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""SALT Araştırma karelerini galeriye yerleştirir.

ÜÇÜNCÜ KAYNAK. Commons API'den, turkseker.gov.tr adresten geliyordu;
bunlar KULLANICININ İNDİRDİĞİ dosyalar. archives.saltresearch.org
Cloudflare arkasında ve betikten indirilemiyor; kullanıcı 24 Kasım 2026'da
91 dosyayı kendi tarayıcısından indirdi.

ALTYAZILAR SALT'IN KENDİ AÇIKLAMALARINDAN. Albüm sayfalarının her birinin
ayrı açıklaması var (kayıt sayfasındaki dataItemFiles/description); kalan
kayıtlarda kaydın başlığı geçerli. Karede ne görüldüğü TAHLİL EDİLMİYOR —
künye kuralı.

TAM KÜNYE (kullanıcı kuralı, 24 Kasım 2026): atıf satırı kaydın başlığını,
varsa üretenini ve tarihini, kayıt kodunu, "Salt Araştırma" kredisini ve
lisansı taşıyor. Kaynak alanı kaydın adresini veriyor.

ND MADDESİ: kırpma YOK. Yalnız ölçü küçültme yapılıyor; CC'nin kendi
açıklamasında biçim/ölçü değişikliği türev sayılmıyor.
"""
import json, pathlib, shutil, sys
from PIL import Image

KOK = pathlib.Path(__file__).parent
HEDEF = KOK / "gorseller"
KAYNAK = pathlib.Path.home() / "Downloads" / "SALT GÖRSELLER"
TAVAN = 1600
LISANS = "CC BY-NC-ND 4.0"
KREDI = "Salt Araştırma"

K = json.loads((KOK / "salt_kayitlari.json").read_text(encoding="utf-8"))
KAYIT, SAYFA = K["kayitlar"], K["sayfa_aciklamalari"]

# ── SEÇİM ──────────────────────────────────────────────────────────────────
# Kullanıcı: "olabildiğince geniş bir yelpazede seç." On dört kaydın
# HEPSİNDEN kare var ve aynı sahnenin tekrarı alınmadı: kapak, istasyon,
# açılış töreni, genel görünüm, pancar, laboratuvar, makine salonu,
# personel, lojman, çarşı, havuz, tarla, vagon, çizim.
#
# (yerel_dosya, kimlik, öbek, tr, en)
S = [
    # ── TARLA ve ÇİFTÇİ ───────────────────────────────────────────────
    ("salt_pancar_hasadi_001.jpg", "galeri_salt_hasat", "tarla",
     "Şeker pancarı tarlasında hasat yapılırken. Fotokartın ön yüzünde "
     "“Fabrika için pancar toplanırken” yazıyor.",
     "Harvesting in a sugar beet field. The front of the photocard reads "
     "“gathering beet for the factory”."),
    ("salt_pancar_hasadi_002.jpg", "galeri_salt_hasat_mektup", "tarla",
     "Aynı fotokartın arka yüzü: Azize'den kardeşi Betül'e mektup.",
     "The reverse of the same photocard: a letter from Azize to her sister Betül."),

    # ── YÜKLEME ───────────────────────────────────────────────────────
    ("salt_usak_vagondan_aktarma_001.jpg", "galeri_salt_vagon", "yukleme",
     "Uşak Şeker Fabrikası'na gelen şeker pancarları vagonlardan aktarılırken.",
     "Sugar beet arriving at the Uşak Sugar Factory being transferred from railway wagons."),
    ("salt_alpullu_fabrika_001.jpg", "galeri_salt_silo", "yukleme",
     "Alpullu Şeker Fabrikası.",
     "The Alpullu Sugar Factory."),
    ("salt_alpullu_fabrika_002.jpg", "galeri_salt_silo_arka", "yukleme",
     "Aynı fotoğrafın arka yüzü: “Pancar silolarının su tazyiki ile "
     "tahliyesi, Alpullu”.",
     "The reverse of the same photograph: “emptying the beet silos by water "
     "pressure, Alpullu”."),
    ("salt_usak_fabrika_2_001.jpg", "galeri_salt_usak_pancar", "yukleme",
     "Uşak Şeker Fabrikası.",
     "The Uşak Sugar Factory."),

    # ── ALPULLU ALBÜMÜ (1928-1929) ────────────────────────────────────
    ("salt_alpullu_albumu_001.jpg", "galeri_salt_alb_kapak", "alpullu", None, None),
    ("salt_alpullu_albumu_005.jpg", "galeri_salt_alb_istasyon", "alpullu", None, None),
    ("salt_alpullu_albumu_006.jpg", "galeri_salt_alb_kusat", "alpullu", None, None),
    ("salt_alpullu_albumu_008.jpg", "galeri_salt_alb_acilis", "alpullu", None, None),
    ("salt_alpullu_albumu_009.jpg", "galeri_salt_alb_genel", "alpullu", None, None),
    ("salt_alpullu_albumu_011.jpg", "galeri_salt_alb_ispirto", "alpullu", None, None),
    ("salt_alpullu_albumu_014.jpg", "galeri_salt_alb_pancar", "alpullu", None, None),
    ("salt_alpullu_albumu_016.jpg", "galeri_salt_alb_personel", "isci", None, None),
    ("salt_alpullu_albumu_020.jpg", "galeri_salt_alb_laboratuvar", "isci", None, None),
    ("salt_alpullu_albumu_022.jpg", "galeri_salt_alb_ic1", "fabrika_ici", None, None),
    ("salt_alpullu_albumu_031.jpg", "galeri_salt_alb_ic2", "fabrika_ici", None, None),
    ("salt_alpullu_albumu_041.jpg", "galeri_salt_alb_ic3", "fabrika_ici", None, None),
    ("salt_alpullu_albumu_044.jpg", "galeri_salt_alb_personel2", "isci", None, None),

    # ── UŞAK ──────────────────────────────────────────────────────────
    ("salt_usak_albumu_001.jpg", "galeri_salt_usak_genel", "fabrikalar",
     "Uşak Şeker Fabrikası.", "The Uşak Sugar Factory."),
    ("salt_usak_albumu_003.jpg", "galeri_salt_usak_avlu", "fabrikalar",
     "Uşak Şeker Fabrikası.", "The Uşak Sugar Factory."),
    ("salt_usak_albumu_004.jpg", "galeri_salt_usak_salon1", "fabrika_ici",
     "Uşak Şeker Fabrikası.", "The Uşak Sugar Factory."),
    ("salt_usak_albumu_006.jpg", "galeri_salt_usak_salon2", "fabrika_ici",
     "Uşak Şeker Fabrikası.", "The Uşak Sugar Factory."),
    ("salt_usak_albumu_008.jpg", "galeri_salt_usak_salon3", "fabrika_ici",
     "Uşak Şeker Fabrikası.", "The Uşak Sugar Factory."),
    ("salt_usak_makine_dairesi_001.jpg", "galeri_salt_usak_makine", "fabrika_ici",
     "Uşak Şeker Fabrikası'nın makine dairesi.",
     "The engine room of the Uşak Sugar Factory."),
    ("salt_usak_makine_dairesi_calisanlar_001.jpg", "galeri_salt_usak_makine_isci", "isci",
     "Uşak Şeker Fabrikası'nın makine dairesi ve çalışanları.",
     "The engine room of the Uşak Sugar Factory and its workers."),
    ("salt_usak_fabrika_1_001.jpg", "galeri_salt_usak_kart", "fabrikalar",
     "Uşak Şeker Fabrikası.", "The Uşak Sugar Factory."),
    ("salt_usak_sosyal_tesisler_001.jpg", "galeri_salt_usak_havuz", "cevresi",
     "Uşak Şeker Fabrikası Sosyal Tesisleri.",
     "The social facilities of the Uşak Sugar Factory."),

    # ── ETİMESGUT ─────────────────────────────────────────────────────
    ("salt_etimesgut_fabrika_001.jpg", "galeri_salt_etim_fabrika", "fabrikalar",
     "Etimesgut Şeker Fabrikası. Etimesgut, Ankara.",
     "The Etimesgut Sugar Factory, Ankara."),
    ("salt_etimesgut_kompleksi_001.jpg", "galeri_salt_etim_1", "cevresi", None, None),
    ("salt_etimesgut_kompleksi_003.jpg", "galeri_salt_etim_2", "cevresi", None, None),
    ("salt_etimesgut_kompleksi_005.jpg", "galeri_salt_etim_3", "cevresi", None, None),
    ("salt_etimesgut_kompleksi_009.jpg", "galeri_salt_etim_4", "cevresi", None, None),
    ("salt_etimesgut_kompleksi_012.jpg", "galeri_salt_etim_5", "cevresi", None, None),
    ("salt_etimesgut_kompleksi_014.jpg", "galeri_salt_etim_6", "cevresi", None, None),
    ("salt_etimesgut_kompleksi_015.jpg", "galeri_salt_etim_7", "cevresi", None, None),

    # ── TURHAL · ESKİŞEHİR ────────────────────────────────────────────
    ("salt_turhal_fabrika_001.jpg", "galeri_salt_turhal", "fabrikalar",
     "Turhal Şeker Fabrikası. Turhal, Tokat.",
     "The Turhal Sugar Factory, Turhal, Tokat."),
    ("salt_eskisehir_cizim_001.jpg", "galeri_salt_eskisehir", "tarih",
     "Eskişehir Şeker Fabrikası çizimi.",
     "A drawing of the Eskişehir Sugar Factory."),
]

# Albüm sayfalarının İngilizce karşılıkları — SALT'ın kendi iki dilli
# açıklamasının ikinci yarısı.
EN_ALB = {
    "001": "Cover of album",
    "005": "Kırklareli Alpullu Sugar Factory. Kırklareli Alpullu Train Station",
    "006": "“Opening ceremony of the Alpullu Spirit Factory, 28 December 1928”",
    "008": "Opening ceremony of the Alpullu Spirit Factory, 28 December 1928",
    "009": "General view of the Alpullu Sugar Factory",
    "011": "The Alpullu Spirit Factory",
    "014": "The Alpullu Sugar Factory and sugar beets. Interior of the factory",
    "016": "Staff and administrators of the factory",
    "020": "Laboratory and staff of the factory",
    "022": "Interior of the factory and staff",
    "031": "Interior of the factory and staff",
    "041": "Interior of the factory",
    "044": "Sections of the factory and staff",
}
EN_ETIM = "Photographs of the Etimesgut Complex of Türkiye Şeker Fabrikası."


def kayit_adi(dosya):
    """salt_usak_albumu_003.jpg → ('usak_albumu', '003')"""
    g = dosya[len("salt_"):].rsplit(".", 1)[0]
    kok, _, no = g.rpartition("_")
    return kok, no


def kunye_satiri(k):
    p = [k["baslik"]]
    if k.get("ureten"):
        p.append(k["ureten"])
    if k.get("tarih"):
        p.append(k["tarih"])
    p += [k["kod"], KREDI, LISANS]
    return " · ".join(p)


def main():
    if not KAYNAK.is_dir():
        raise SystemExit(f"✗ kaynak dizin yok: {KAYNAK}")
    ku_yol = HEDEF / "galeri_kunye.json"
    KUDOSYA = json.loads(ku_yol.read_text(encoding="utf-8"))
    # KAREler SÖZLÜĞÜNE yazılıyor. İlk yazımda en üst düzeye konmuştu ve
    # kur_galeri.py ["kareler"] okuduğu için hiçbirini görmedi.
    KU = KUDOSYA["kareler"]
    sec_yol = KOK / "galeri_secim.json"
    SEC = json.loads(sec_yol.read_text(encoding="utf-8"))
    alt_yol = KOK / "galeri_altyazilar.json"
    ALT = json.loads(alt_yol.read_text(encoding="utf-8"))

    var = {k["kimlik"] for k in SEC["kareler"]}
    hata, eklenen = [], 0

    for dosya, kimlik, obek, tr, en in S:
        kaynak_dosya = KAYNAK / dosya
        if not kaynak_dosya.exists():
            hata.append(f"{kimlik}: dosya yok — {dosya}")
            continue
        kok, no = kayit_adi(dosya)
        k = KAYIT.get(kok)
        if not k:
            hata.append(f"{kimlik}: kayıt tanımsız — {kok}")
            continue

        # Altyazı: elle verilmediyse SALT'ın sayfa açıklamasından.
        if tr is None:
            if kok == "alpullu_albumu":
                a = SAYFA["alpullu_albumu"].get(no)
                if not a:
                    hata.append(f"{kimlik}: albüm sayfası {no} açıklamasız")
                    continue
                tr = (f"Alpullu Şeker ve İspirto Fabrikaları albümünden bir sayfa: "
                      f"{a}. {k['tarih']}.")
                en = (f"A page from the album of the Alpullu Sugar and Spirit "
                      f"Factories: {EN_ALB.get(no, a)}. {k['tarih']}.")
            elif kok == "etimesgut_kompleksi":
                tr = (f"{k['baslik']} {k['ureten']} fotoğrafı. {k['yer']}.")
                en = f"{EN_ETIM} Photograph by {k['ureten']}. {k['yer']}."
            else:
                hata.append(f"{kimlik}: altyazı yok")
                continue

        # Kopyala + ölçü küçült (kırpma YOK — ND).
        hedef_dosya = HEDEF / f"{kimlik}.jpg"
        if not hedef_dosya.exists():
            shutil.copy2(kaynak_dosya, hedef_dosya)
        with Image.open(hedef_dosya) as im:
            im.load()
            g, y = im.size
            if g > TAVAN or y > TAVAN:
                im = im.convert("RGB")
                im.thumbnail((TAVAN, TAVAN))
                im.save(hedef_dosya, "JPEG", quality=88, optimize=True)
                g, y = im.size

        KU[kimlik] = {
            "adres": None, "asil": None, "sayfa": k["handle"],
            "mime": "image/jpeg",
            "nesne_adi": k["baslik"], "aciklama": tr, "tarih": k.get("tarih"),
            "atif": kunye_satiri(k), "kredi": KREDI,
            "lisans": LISANS,
            "lisans_adresi": "https://creativecommons.org/licenses/by-nc-nd/4.0/deed.tr",
            "ad": dosya, "dosya": hedef_dosya.name,
            "bayt": hedef_dosya.stat().st_size,
            "kaynak_turu": "salt", "obek": obek,
        }
        ALT[kimlik] = {
            "tr": tr, "en": en,
            "_dayanak": (f"SALT Araştırma kaydı {k['kod']} ({k['handle']}). "
                         + ("Albüm sayfasının kendi açıklaması (dataItemFiles)."
                            if kok in ("alpullu_albumu",)
                            else "Kaydın başlığı.")),
        }
        if kimlik not in var:
            SEC["kareler"].append({"kimlik": kimlik, "kaynak": "salt",
                                   "dosya": dosya, "obek": obek,
                                   "kayit": k["handle"]})
        eklenen += 1

    if hata:
        raise SystemExit("✗ " + "\n  ".join(hata))

    SEC["_salt"] = (
        "SALT Araştırma kareleri 24 Kasım 2026'da eklendi. Kullanıcı yurtdışı "
        "karelerini reddedince (23 Kasım) aynı konular Türkiye'den arandı; "
        "Commons'ta yok, SALT'ta var. Kullanıcı: 'kullandığın her görsele tam "
        "künye yazmayı unutma. izne gerek yok.' ve 'olabildiğince geniş bir "
        "yelpazede seç.' On dört kaydın hepsinden kare alındı.")
    ku_yol.write_text(json.dumps(KUDOSYA, ensure_ascii=False, indent=2), encoding="utf-8")
    sec_yol.write_text(json.dumps(SEC, ensure_ascii=False, indent=2), encoding="utf-8")
    alt_yol.write_text(json.dumps(ALT, ensure_ascii=False, indent=2), encoding="utf-8")

    from collections import Counter
    ob = Counter(x[2] for x in S)
    print(f"  ✓ {eklenen} SALT karesi yerleştirildi")
    print("  öbekler: " + " · ".join(f"{a} {b}" for a, b in sorted(ob.items())))
    print(f"  galeri toplamı: {len(SEC['kareler'])} kare")


main()
