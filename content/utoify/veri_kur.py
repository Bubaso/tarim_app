#!/usr/bin/env python3
"""Ödül + sergileme künyelerini tek veri katmanında birleştirir: veri.json

Eser ADLARI ÇEVRİLMİYOR. Bir fotoğrafın adı o eserin kendi adıdır; "Bulgur"
İngilizce sayfada da "Bulgur", "The Last Racks" Türkçe sayfada da öyle kalır.
Çevrilen şey yalnızca ödülün adı ve ülke adı.
"""
from __future__ import annotations

import json
import pathlib
import sys

KOK = pathlib.Path(__file__).resolve().parent

ULKE_EN = {
    "Türkiye": "Türkiye", "Endonezya": "Indonesia", "İtalya": "Italy",
    "Bangladeş": "Bangladesh", "Çin": "China", "Vietnam": "Viet Nam",
    "Nepal": "Nepal", "Hindistan": "India", "İran": "Iran",
    "Rusya": "Russia", "Myanmar": "Myanmar", "Hollanda": "Netherlands",
}
ADRES = "https://tarimportali.net/sergi/utoify-16/"


def main() -> int:
    odul = json.loads(
        (KOK / "_raw/odul_kunyeleri_dosyali.json").read_text(encoding="utf-8"))
    sergi = json.loads(
        (KOK / "_raw/sergileme_kunyeleri.json").read_text(encoding="utf-8"))

    eserler = []
    for k in odul["kayitlar"]:
        il, _, ulke = (k["yer"].partition(",") if "," in k["yer"]
                       else ("", "", k["yer"]))
        eserler.append({
            "kod": k["kod"], "tur": "odul", "sira": len(eserler) + 1,
            "kategori": k["kategori"],
            "odul_tr": k["odul_tr"], "odul_en": k["odul_en"],
            "fotografci": k["fotografci"], "eser": k["eser"],
            "il": il.strip(), "ulke_tr": ulke.strip(),
            "ulke_en": ULKE_EN.get(ulke.strip(), ulke.strip()),
            "dosya": k["dosya"], "adres": ADRES + k["dosya"],
            "en": k["en"], "boy": k["boy"], "en_boy": k["en_boy"],
        })
    for k in sergi["kayitlar"]:
        eserler.append({
            "kod": k["kod"], "tur": "sergileme", "sira": len(eserler) + 1,
            "kategori": "sergileme",
            "odul_tr": "Sergilemeye değer bulundu",
            "odul_en": "Selected for exhibition",
            "fotografci": k["fotografci"], "eser": k["eser"],
            "il": k["il"], "ulke_tr": k["ulke"],
            "ulke_en": ULKE_EN.get(k["ulke"], k["ulke"]),
            "dosya": k["dosya"], "adres": ADRES + k["dosya"],
            "en": k["en"], "boy": k["boy"], "en_boy": k["en_boy"],
        })

    eksik = [e["kod"] for e in eserler
             if not e["fotografci"] or not e["eser"] or not e["dosya"]
             or e["ulke_tr"] not in ULKE_EN]
    if eksik:
        print("  ! eksik ya da tanınmayan ülke: %s" % eksik)
        return 1

    veri = {
        "_dosya": "16. UTOİFY — Tarım Portalı sergi veri katmanı",
        "_kural": "Her kare künyesiyle birlikte duruyor: fotoğrafçı, eser adı, "
                  "yer. Künyesiz kare bu dosyaya giremez, dolayısıyla sayfaya "
                  "da giremez.",
        "_cekim": "2026-11-12",
        "yarisma": {
            "kod": "utoify-16",
            "sira": 16,
            "yil": 2026,
            "ad_tr": "16. Uluslararası Tarım Orman ve İnsan Fotoğraf Yarışması",
            "ad_en": "16th International Photo Contest on Agriculture, "
                     "Forest and People",
            "kisa": "UTOİFY",
            "tema_tr": "Kadının Emeği, Tarımın Geleceği",
            "tema_en": "Labour of Woman, Future of Agriculture",
            "duzenleyen_tr": "T.C. Tarım ve Orman Bakanlığı, Eğitim ve Yayın "
                             "Dairesi Başkanlığı",
            "duzenleyen_en": "Ministry of Agriculture and Forestry of Türkiye, "
                             "Department of Training and Extension",
            "destekci": "DenizBank",
            "basvuru_baslangic": "2026-04-13",
            "basvuru_bitis": "2026-08-31",
            "ilan_baslangic": "2026-09-28",
            "ilan_bitis": "2026-10-28",
            "kaynak_adres": "https://www.tarimormaninsan.com/",
            "odul_listesi": "https://www.tarimormaninsan.com/16th_utoify_odul.pdf",
            "sergileme_listesi":
                "https://www.tarimormaninsan.com/16th_utoify_sergileme.pdf",
            "basvuru_adres": "https://utoify.tarimorman.gov.tr/",
            "_hikaye_notu":
                "Şartname her esere bir HİKÂYE zorunluluğu koyuyor: "
                "“Katılımcıların başvurduğu her eserin bir hikâyesi "
                "olacaktır. Hikâyesi olmayan eserlere ait başvurular kabul "
                "edilmeyecektir.” Bu hikâyeler hiçbir yerde yayımlanmadı.",
            "_telif_notu":
                "Kareler fotoğrafçılarının telifinde. Yarışmanın katılım "
                "şartları sayfası (tarimormaninsan.com/Katilim-Sartlari) BOŞ "
                "dönüyor; kamuya açık bir kullanım lisansı bulunamadı. Yayım "
                "kararı 12 Kasım 2026'da kullanıcıya ait: sonuçlar kamuya açık "
                "bir ilan ve sergi; her kare fotoğrafçı adı, eser adı ve "
                "kaynağa bağlantıyla yayımlanıyor.",
        },
        "sayilar": {
            "toplam": len(eserler),
            "odul": sum(1 for e in eserler if e["tur"] == "odul"),
            "sergileme": sum(1 for e in eserler if e["tur"] == "sergileme"),
        },
        "eserler": eserler,
    }
    (KOK / "veri.json").write_text(
        json.dumps(veri, ensure_ascii=False, indent=1), encoding="utf-8")
    print("✓ %d eser (%d ödül + %d sergileme) → content/utoify/veri.json"
          % (len(eserler), veri["sayilar"]["odul"], veri["sayilar"]["sergileme"]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
