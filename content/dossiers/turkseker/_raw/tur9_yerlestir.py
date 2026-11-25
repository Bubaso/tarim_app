#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Tur 9 — bölüm numaralarını yeniden eşler, 13 yeni bölüm görseli yerleştirir.

On üç yeni bölüm araya girdi (bkz. tur9_bulgular.md). Eski numaralar kaydı:
Kaynakça 16'dan 29'a, galeri 15'ten 28'e taşındı. `bolum_grafikleri`,
`bolum_gorselleri`, `bolum_turleri` ve `_bolum_basliklari` bu eşlemeye göre
yeniden kuruluyor.

YENİ GÖRSELLER SALT HAVUZUNDAN. 91 karenin 38'i galeride; kalan 53'ten 13'ü
bölüm görseli oldu. Galeriyle ÇAKIŞMIYOR — dogrula_galeri.py 7. kural bunu
sınıyor.
"""
import json, pathlib, shutil, sys
from PIL import Image

RAW = pathlib.Path(__file__).parent
KOK = RAW.parent
HEDEF = RAW / "gorseller"
KAYNAK = pathlib.Path.home() / "Downloads" / "SALT GÖRSELLER"
TAVAN = 1600
KOK_URL = "https://tarimportali.net/dosya/turkseker"

SALT = json.loads((RAW / "salt_kayitlari.json").read_text(encoding="utf-8"))
KAYIT, SAYFA = SALT["kayitlar"], SALT["sayfa_aciklamalari"]

# ── 1 · ESKİ → YENİ BÖLÜM NUMARASI ────────────────────────────────────────
ESLEME = {"1": "1", "2": "2", "3": "3", "4": "4", "5": "5", "6": "8", "7": "9",
          "8": "10", "9": "12", "10": "13", "11": "15", "12": "16", "13": "23",
          "14": "27", "15": "28", "16": "29"}

# ── 2 · YENİ BÖLÜM GÖRSELLERİ ─────────────────────────────────────────────
# (bölüm, kimlik, yerel dosya)
YENI = [
    ("6",  "turkseker_s06_makine",    "salt_alpullu_albumu_040.jpg"),
    ("7",  "turkseker_s07_ozbekistan", "salt_alpullu_albumu_042.jpg"),
    ("11", "turkseker_s11_tohum",     "salt_alpullu_albumu_021.jpg"),
    ("14", "turkseker_s14_uydu",      "salt_usak_albumu_002.jpg"),
    ("17", "turkseker_s17_kampanya",  "salt_usak_albumu_005.jpg"),
    ("18", "turkseker_s18_yatirim",   "salt_usak_albumu_007.jpg"),
    ("19", "turkseker_s19_yanurun",   "salt_alpullu_albumu_027.jpg"),
    ("20", "turkseker_s20_enerji",    "salt_alpullu_albumu_039.jpg"),
    ("21", "turkseker_s21_deprem",    "salt_alpullu_albumu_037.jpg"),
    ("22", "turkseker_s22_ekonomi",   "salt_alpullu_albumu_043.jpg"),
    ("24", "turkseker_s24_yerleske",  "salt_etimesgut_kompleksi_002.jpg"),
    ("25", "turkseker_s25_rolyef",    "salt_turhal_fabrika_002.jpg"),
    ("26", "turkseker_s26_turbin",    "salt_alpullu_albumu_036.jpg"),
]

EN_ALB = {
    "021": "Sections of the factory and staff",
    "027": "Interior of the factory and staff",
    "036": "Sections of the factory and staff",
    "037": "Interior of the factory",
    "039": "Interior of the factory and staff",
    "040": "Interior of the factory and staff",
    "042": "Interior of the factory and staff",
    "043": "Sections of the factory and staff",
}


def kayit_adi(dosya):
    g = dosya[len("salt_"):].rsplit(".", 1)[0]
    kok, _, no = g.rpartition("_")
    return kok, no


def kunye_satiri(k):
    p = [k["baslik"]]
    if k.get("ureten"):
        p.append(k["ureten"])
    if k.get("tarih"):
        p.append(k["tarih"])
    p += [k["kod"], "Salt Araştırma", "CC BY-NC-ND 4.0"]
    return " · ".join(p)


def main():
    ku_yol = HEDEF / "kunye.json"
    KU = json.loads(ku_yol.read_text(encoding="utf-8"))
    alt_yol = RAW / "altyazilar.json"
    ALT = json.loads(alt_yol.read_text(encoding="utf-8"))
    galeri = {k["dosya"] for k in json.loads(
        (RAW / "galeri_secim.json").read_text(encoding="utf-8"))["kareler"]
        if k["kaynak"] == "salt"}

    # 1 · eski numaraları kaydır
    #
    # TEK YÖNLÜ GÖÇ. Bu betik iki kez koşarsa ESLEME yeni numaraları bir kez
    # daha kaydırır ve eşleme bozulur. Koruma: kayıtlarda ESLEME'nin
    # dışında bir bölüm numarası varsa göç zaten yapılmıştır.
    if any(str(g["bolum"]) not in ESLEME for g in KU["gorseller"].values()):
        print("  · numara göçü zaten yapılmış, atlanıyor")
        return
    for kimlik, g in KU["gorseller"].items():
        eski = str(g["bolum"])
        if eski not in ESLEME:
            raise SystemExit(f"✗ {kimlik}: eşlenmemiş bölüm {eski}")
        g["bolum"] = ESLEME[eski]

    # 2 · yeni kareler
    hata = []
    for bolum, kimlik, dosya in YENI:
        if dosya in galeri:
            hata.append(f"{kimlik}: kare galeride de var — {dosya}")
            continue
        src = KAYNAK / dosya
        if not src.exists():
            hata.append(f"{kimlik}: dosya yok — {dosya}")
            continue
        kok, no = kayit_adi(dosya)
        k = KAYIT[kok]
        yol = HEDEF / f"{kimlik}.jpg"
        if not yol.exists():
            shutil.copy2(src, yol)
        with Image.open(yol) as im:
            im.load()
            g_, y_ = im.size
            if max(g_, y_) > TAVAN:
                im = im.convert("RGB")
                im.thumbnail((TAVAN, TAVAN))
                im.save(yol, "JPEG", quality=88, optimize=True)

        if kok == "alpullu_albumu":
            a = SAYFA["alpullu_albumu"][no]
            tr = (f"Alpullu Şeker ve İspirto Fabrikaları albümünden bir sayfa: "
                  f"{a}. {k['tarih']}.")
            en = (f"A page from the album of the Alpullu Sugar and Spirit "
                  f"Factories: {EN_ALB[no]}. {k['tarih']}.")
            day = "Albüm sayfasının kendi açıklaması (dataItemFiles)."
        elif kok == "etimesgut_kompleksi":
            tr = f"{k['baslik']} {k['ureten']} fotoğrafı. {k['yer']}."
            en = (f"Photographs of the Etimesgut Complex of Türkiye Şeker "
                  f"Fabrikası. Photograph by {k['ureten']}. {k['yer']}.")
            day = "Kaydın başlığı ve üreteni."
        elif kok == "turhal_fabrika":
            tr = "Turhal Şeker Fabrikası kartpostalının arka yüzü. Turhal, Tokat."
            en = ("The reverse of a postcard of the Turhal Sugar Factory. "
                  "Turhal, Tokat.")
            day = "Kaydın başlığı; dosya kaydın ikinci belgesi (arka yüz)."
        else:
            tr = f"{k['baslik']}."
            en = "The Uşak Sugar Factory."
            day = "Kaydın başlığı."

        KU["gorseller"][kimlik] = {
            "bolum": bolum, "ad": dosya, "nesne_adi": k["baslik"],
            "aciklama": tr, "tarih": k.get("tarih"),
            "atif": kunye_satiri(k), "kredi": "Salt Araştırma",
            "lisans": "CC BY-NC-ND 4.0",
            "lisans_adresi": "https://creativecommons.org/licenses/by-nc-nd/4.0/deed.tr",
            "sayfa": k["handle"], "dosya": yol.name,
            "bayt": yol.stat().st_size, "indirilen_adres": None,
        }
        ALT[kimlik] = {"tr": tr, "en": en,
                       "_dayanak": f"SALT Araştırma kaydı {k['kod']} "
                                   f"({k['handle']}). {day}"}

    if hata:
        raise SystemExit("✗ " + "\n  ".join(hata))

    ku_yol.write_text(json.dumps(KU, ensure_ascii=False, indent=2), encoding="utf-8")
    alt_yol.write_text(json.dumps(ALT, ensure_ascii=False, indent=2), encoding="utf-8")

    # 3 · yayin.json: grafik, tür, başlık eşlemeleri
    y_yol = KOK / "yayin.json"
    Y = json.loads(y_yol.read_text(encoding="utf-8"))

    eski_g = Y["bolum_grafikleri"]
    Y["bolum_grafikleri"] = {k: v for k, v in eski_g.items() if k.startswith("_")}
    for k, v in eski_g.items():
        if not k.startswith("_"):
            Y["bolum_grafikleri"][ESLEME[k]] = v

    YENI_TUR = {"6": "anlati", "7": "belge", "11": "anlati", "14": "anlati",
                "17": "veri", "18": "veri", "19": "anlati", "20": "veri",
                "21": "anlati", "22": "veri", "24": "anlati", "25": "belge",
                "26": "anlati"}
    eski_t = Y["bolum_turleri"]
    Y["bolum_turleri"] = {k: v for k, v in eski_t.items() if k.startswith("_")}
    for k, v in eski_t.items():
        if not k.startswith("_"):
            Y["bolum_turleri"][ESLEME[k]] = v
    Y["bolum_turleri"].update(YENI_TUR)
    Y["bolum_turleri"] = {k: Y["bolum_turleri"][k] for k in sorted(
        Y["bolum_turleri"], key=lambda x: (0, 0) if x.startswith("_") else (1, int(x)))}

    # Başlıklar metinden okunuyor — tek doğru kaynak orası.
    import re
    TR = (KOK / "metin_tr.md").read_text(encoding="utf-8")
    B = {m.group(1): m.group(2).strip()
         for m in re.finditer(r"^## (\d+)\. (.+)$", TR, flags=re.M)}
    Y["_bolum_basliklari"] = {
        "_notu": ("Metinden okunuyor. Tur 9'da on üç bölüm eklendi ve bütün "
                  "numaralar kaydı; başlıkları elle tutmak ayrışma riskiydi."),
        **{k: B[k] for k in sorted(B, key=int)}}
    Y["_tur9_notu"] = (
        "24 Kasım 2026, kullanıcı: '1-13 arası hepsini (13 dahil) bölüme çevir.' "
        "Bulgu listesindeki ilk on üç konu bölüme çevrildi; 14-16 alınmadı. "
        "Eski→yeni bölüm eşlemesi _raw/tur9_yerlestir.py/ESLEME içinde.")
    y_yol.write_text(json.dumps(Y, ensure_ascii=False, indent=2), encoding="utf-8")

    print(f"  ✓ {len(ESLEME)} eski bölüm eşlendi · {len(YENI)} yeni görsel")
    print(f"  grafik: {sorted([k for k in Y['bolum_grafikleri'] if not k.startswith('_')], key=int)}")
    print(f"  bölüm sayısı: {len(B)}")


main()
