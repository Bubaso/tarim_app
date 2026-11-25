#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Yeni bölümlere DOĞRUDAN ilgili kareler; çıkan SALT kareleri galeriye.

Kullanıcı kararı (24 Kasım 2026): "erciş şeker fabrikası arazisinde kurulan
güneş enerji santralinin görselleri web'de var… sonradan eklenen bölümlerle
direk alakalı görseller bulabiliyor musun bir bak. bulamazsan mevcut
görseller kalsın. bulup değiştirdiğin eski görselleri galeriye taşırsın.
24. bölümün mevcut görseline dokunma."

ERCİŞ GES WEB'DE ARANDI. Haber siteleri konuyu yazıyor (Alfa Solar, 20 MWe
/ 25,3 MWp, 1,544 milyar TL) ama fotoğrafları ajans telifi. Santralin
kullanılabilir karesi kurumun KENDİ duyurusunda: havadan çekim.

YEDİ BÖLÜM DEĞİŞTİ. §17, §19, §22, §7 ve §26 için doğrudan ilgili kare
bulunamadı; onların SALT kareleri yerinde kaldı. §24'e dokunulmadı.
"""
import json, pathlib, shutil
from PIL import Image

RAW = pathlib.Path(__file__).parent
KOK = RAW.parent
HEDEF = RAW / "gorseller"
KAYNAK = pathlib.Path("/private/tmp/claude-502/-Users-BURHAN-Desktop/"
                      "597dfc7b-cfff-4806-ba01-33aa08a768d6d/scratchpad")  # yedek
TAVAN = 1600
ATIF = "Türkiye Şeker Fabrikaları A.Ş."
LISANS = "Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını"

# (bölüm, yeni kimlik, kaynak dosya, haber kimliği, tr, en)
DEGISIM = [
 ("6", "turkseker_s06_tanker", "5134__5134_Haberler2026_09_04_17_14_38_304.jpeg", "5134",
  "Makine fabrikalarında üretilen orman yangın söndürme tankerleri. Kurumun duyuru görseli, 4 Eylül 2026.",
  "Forest fire-fighting tankers built in the machine factories. The company's announcement image, 4 September 2026."),
 ("11", "turkseker_s11_tohum_el", "71__71_Haberler2022_02_18_14_00_50_784.png", "71",
  "Ekimi yapılan tarlada şeker pancarı tohumu, 18 Şubat 2022.",
  "Sugar beet seed in a field being sown, 18 February 2022."),
 ("14", "turkseker_s14_haymana", "5132__5132_Haberler2026_08_05_10_47_49_162.jpeg", "5132",
  "Haymana'da pancar tarlasında inceleme, 5 Ağustos 2026.",
  "An inspection in a beet field at Haymana, 5 August 2026."),
 ("18", "turkseker_s18_burdur", "5150__5150_Haberler2026_10_28_12_27_05_524.png", "5150",
  "Burdur Şeker Fabrikası'nda tamamlanan revizyon ve modernizasyon. Kurumun duyuru görseli, 28 Ekim 2026.",
  "The completed revision and modernisation at the Burdur Sugar Factory. The company's announcement image, 28 October 2026."),
 ("20", "turkseker_s20_ercis_ges", "5151__5151_Haberler2026_11_04_09_53_13_553.jpeg", "5151",
  "Erciş Şeker Fabrikası arazisinde kurulan güneş enerjisi santrali. Kurumun duyuru görseli, 4 Kasım 2026.",
  "The solar power plant built on the land of the Erciş Sugar Factory. The company's announcement image, 4 November 2026."),
 ("21", "turkseker_s21_malatya", "5135__5135_Haberler2026_09_08_16_27_42_062.jpg", "5135",
  "Malatya Şeker Fabrikası'nda yılın ilk şekerinin üretimi, 8 Eylül 2026.",
  "The season's first sugar being produced at the Malatya Sugar Factory, 8 September 2026."),
 ("25", "turkseker_s25_rolyef_teslim", "5127__5127_Haberler2026_03_31_10_32_58_937.jpg", "5127",
  "1934'te Turhal Şeker Fabrikası'nın açılışı için yapılan ahşap rölyefin kuruma teslimi, 31 Mart 2026.",
  "The wooden relief made for the opening of the Turhal Sugar Factory in 1934 being handed back to the company, 31 March 2026."),
]

HABER_URL = "https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID={}"


def main():
    foto = next((p for p in [
        pathlib.Path("/private/tmp/claude-502/-Users-BURHAN-Desktop/"
                     "597dfc7b-cfff-4806-ba01-33aa08a98d6d/scratchpad/"
                     "turkseker_site/foto9")] if p.is_dir()), None)
    if foto is None:
        raise SystemExit("✗ kaynak klasör bulunamadı")

    ku_yol = HEDEF / "kunye.json"
    KU = json.loads(ku_yol.read_text(encoding="utf-8"))
    alt_yol = RAW / "altyazilar.json"
    ALT = json.loads(alt_yol.read_text(encoding="utf-8"))
    gs_yol = RAW / "galeri_secim.json"
    GS = json.loads(gs_yol.read_text(encoding="utf-8"))
    gk_yol = HEDEF / "galeri_kunye.json"
    GK = json.loads(gk_yol.read_text(encoding="utf-8"))
    ga_yol = RAW / "galeri_altyazilar.json"
    GA = json.loads(ga_yol.read_text(encoding="utf-8"))

    bolum_kimlik = {str(v["bolum"]): k for k, v in KU["gorseller"].items()}
    tasinan, hata = [], []

    for bolum, kimlik, dosya, hid, tr, en in DEGISIM:
        src = foto / dosya
        if not src.exists():
            hata.append(f"§{bolum}: dosya yok — {dosya}")
            continue
        eski = bolum_kimlik.get(bolum)
        if eski is None:
            hata.append(f"§{bolum}: eski kare bulunamadı")
            continue

        uz = ".png" if dosya.lower().endswith(".png") else ".jpg"
        yol = HEDEF / f"{kimlik}{uz}"
        if not yol.exists():
            shutil.copy2(src, yol)
        with Image.open(yol) as im:
            im.load()
            g, y = im.size
            if max(g, y) > TAVAN:
                im = im.convert("RGB")
                im.thumbnail((TAVAN, TAVAN))
                yol = yol.with_suffix(".jpg")
                im.save(yol, "JPEG", quality=88, optimize=True)
                g, y = im.size
            elif uz == ".png":
                im.convert("RGB").save(yol.with_suffix(".jpg"), "JPEG",
                                       quality=92, optimize=True)
                yol.unlink()
                yol = yol.with_suffix(".jpg")

        KU["gorseller"][kimlik] = {
            "bolum": bolum, "ad": dosya, "nesne_adi": tr.split(".")[0],
            "aciklama": tr, "tarih": None,
            "atif": ATIF, "kredi": "turkseker.gov.tr haber arşivi",
            "lisans": LISANS, "lisans_adresi": None,
            "sayfa": HABER_URL.format(hid), "dosya": yol.name,
            "bayt": yol.stat().st_size, "indirilen_adres": None,
        }
        ALT[kimlik] = {"tr": tr, "en": en,
                       "_dayanak": (f"turkseker.gov.tr haberi {hid} "
                                    f"({HABER_URL.format(hid)}); haberin başlığı "
                                    f"ve tarihi.")}

        # ── eski SALT karesi galeriye ────────────────────────────────────
        e = KU["gorseller"].pop(eski)
        ea = ALT.pop(eski, None)
        gk = f"galeri_{eski}"
        GK["kareler"][gk] = {
            "adres": None, "asil": None, "sayfa": e["sayfa"], "mime": "image/jpeg",
            "nesne_adi": e["nesne_adi"], "aciklama": e["aciklama"],
            "tarih": e.get("tarih"), "atif": e["atif"], "kredi": e["kredi"],
            "lisans": e["lisans"], "lisans_adresi": e["lisans_adresi"],
            "ad": e["ad"], "dosya": e["dosya"], "bayt": e["bayt"],
            "kaynak_turu": "salt", "obek": "fabrika_ici",
        }
        GA[gk] = {"tr": ea["tr"], "en": ea["en"],
                  "_dayanak": ea["_dayanak"] + " §" + bolum +
                              " bölüm görseliyken kullanıcı kararıyla galeriye taşındı."}
        GS["kareler"].append({"kimlik": gk, "kaynak": "salt",
                              "dosya": e["ad"], "obek": "fabrika_ici",
                              "kayit": e["sayfa"]})
        tasinan.append((bolum, eski, gk))

    if hata:
        raise SystemExit("✗ " + "\n  ".join(hata))

    GS["_tur9_gorsel_degisimi"] = (
        "24 Kasım 2026: yedi yeni bölüm doğrudan ilgili kareye kavuştu "
        "(kurumun haber arşivi); yerlerini bırakan SALT kareleri galeriye "
        "taşındı. §17, §19, §22, §7 ve §26 için doğrudan ilgili kare "
        "bulunamadı, mevcut kareleri kaldı. §24'e dokunulmadı.")
    ku_yol.write_text(json.dumps(KU, ensure_ascii=False, indent=2), encoding="utf-8")
    alt_yol.write_text(json.dumps(ALT, ensure_ascii=False, indent=2), encoding="utf-8")
    gs_yol.write_text(json.dumps(GS, ensure_ascii=False, indent=2), encoding="utf-8")
    gk_yol.write_text(json.dumps(GK, ensure_ascii=False, indent=2), encoding="utf-8")
    ga_yol.write_text(json.dumps(GA, ensure_ascii=False, indent=2), encoding="utf-8")

    for b, e, g in tasinan:
        print(f"  §{b:>2}  {e:<28} → galeri ({g})")
    print(f"\n  ✓ {len(DEGISIM)} bölüm görseli değişti · {len(tasinan)} kare galeriye")
    print(f"  galeri: {len(GS['kareler'])} kare")


main()
