#!/usr/bin/env python3
"""
Yapay Zeka ve Dijital Tarım — görsel adaylarını işler (karar 58).

    python3 -I gorsel_isle.py <aday_klasörü> [--kuru]

Aday klasöründe gorsel_adaylari.json (birleşik) ya da gorsel_adaylari_parca_*.json.

Aday klasöründeki `gorsel_adaylari_parca_*.json` dosyalarını okur; seçilen
her adayı `gorsel_al.py` ile indirip WebP'ye çevirir (web/yz/gorsel/),
`gorseller.json`'a künye, kaynak satırı, adres ve indirme günüyle yazar ve
[[gorsel:…]] yönergesini TR metinde adayın paragrafının ardına, EN metinde
aynı blok sırasına yerleştirir. Tekrar çalıştırmada var olanı yeniden
indirmez, yönergeyi ikinci kez eklemez.

Seçim ilkesi: bilgi taşıyan, metinde adı geçen gerçek şeyin görseli. Bizim
grafiklerimizin ya da metindeki bir tablonun aynısı olan kaynak grafikleri,
rapor ve broşür kapakları, logolar alınmaz. PDF içindeki şekiller ayrı adımda
(sayfadan kırpılarak) işlenir.
"""
from __future__ import annotations

import json
import re
import subprocess
import sys
import time
import unicodedata
from pathlib import Path

BURASI = Path(__file__).resolve().parent
BOLUMLER = BURASI.parent / "bolumler"
KAYIT = BURASI / "gorseller.json"
DEPO = BURASI.parents[2]
PYTHON = Path.home() / "tarim_ai_pipeline/venv/bin/python"

# Alınmayanlar (konu başı): grafiğimizin ya da tablonun aynısı, kapak, logo.
ALINMAZ = (
    "AB'de hassas tarım uygulayan çiftliklerin",          # §1 — b01 grafiği
    "ABD'de değişken oranlı teknolojinin ekili alandaki",  # §6 — b06-vrt grafiği
    "Geleneksel ve hermetik depolamada tahıl kayıpları",   # §11 — b11 grafiği
    "Holstein'da genomik seçilim öncesi ve sonrası",       # §12 — metindeki tablo
    "Hindistan'da tarım ürünü fiyat tahmini",              # §16 — b16 grafiği
    "GPT-4o ve Gemini'nin tarım sorularındaki",            # §18 — b18 grafiği
    "AB tarımsal veri paylaşımı davranış kuralları",       # broşür kapağı
    "FAO Gıda ve Tarımın Durumu 2022 raporu",              # rapor kapağı
    "Infarm şirket logosu", "AppHarvest şirket logosu",   # logo
)

# Kaynak satırındaki iç notlar okura gitmez.
IC_NOT = re.compile(r";\s*(PMC kopyası|sayfada fotoğraf künyesi yok)\s*$")

KAYNAK_EN = {  # düz çeviriyle olmayanlar
    "Görsel: Toprak, Gübre ve Su Kaynakları Merkez Araştırma Enstitüsü; harita © FAO 2017 (GSOCmap V1.0)":
        "Image: Soil, Fertilizer and Water Resources Central Research Institute; map © FAO 2017 (GSOCmap V1.0)",
    "Görsel: Saikai, Peake ve Chenu 2023, PLOS Water (CC BY 4.0)":
        "Image: Saikai, Peake and Chenu 2023, PLOS Water (CC BY 4.0)",
    "Görsel: Mohanty, Hughes ve Salathé 2016, Frontiers in Plant Science (CC BY 4.0)":
        "Image: Mohanty, Hughes and Salathé 2016, Frontiers in Plant Science (CC BY 4.0)",
    "Görsel: ESA; Copernicus Sentinel ve Landsat verisi (2015-16), işleme: Humboldt Üniversitesi Berlin / P. Griffiths ve ZALF (ESA Standard Licence)":
        "Image: ESA; Copernicus Sentinel and Landsat data (2015–16), processed by Humboldt University of Berlin / P. Griffiths and ZALF (ESA Standard Licence)",
    "Görsel: Copernicus / ESA–Sen4CAP (UCLouvain, CS-Romania, e-GEOS, GISAT, Sinergise); değiştirilmiş Copernicus Sentinel verisi (2017)":
        "Image: Copernicus / ESA–Sen4CAP (UCLouvain, CS-Romania, e-GEOS, GISAT, Sinergise); contains modified Copernicus Sentinel data (2017)",
    "Görsel: Altun ve Türker 2021, AKÜ FEMÜBİD 21 (CC BY-NC 4.0)":
        "Image: Altun and Türker 2021, AKÜ FEMÜBİD 21 (CC BY-NC 4.0)",
    "Görsel: Gadalla ve Öztekin 2023, Tekirdağ Ziraat Fakültesi Dergisi 20(4) (CC BY-NC 4.0)":
        "Image: Gadalla and Öztekin 2023, Tekirdağ Ziraat Fakültesi Dergisi 20(4) (CC BY-NC 4.0)",
    "Görsel: Balendonck, Stenfert Kroese, Hilhorst ve Tüzel, AquaTag proje broşürü (Wageningen UR, SensorTagSolutions, Ege Üniversitesi)":
        "Image: Balendonck, Stenfert Kroese, Hilhorst and Tüzel, AquaTag project brochure (Wageningen UR, SensorTagSolutions, Ege University)",
    "Harita: Lang N., Jetz W., Schindler K., Wegner J.D. (ETH Zürih), 'A high-resolution canopy height model of the Earth' proje sayfası (veri ürünü CC BY 4.0)":
        "Map: Lang N., Jetz W., Schindler K., Wegner J.D. (ETH Zurich), 'A high-resolution canopy height model of the Earth' project page (data product CC BY 4.0)",
    "Görsel: Tarım ve Orman Bakanlığı / Bolu İl Tarım ve Orman Müdürlüğü":
        "Image: Ministry of Agriculture and Forestry / Bolu Provincial Directorate of Agriculture and Forestry",
    "Fotoğraf: Oklahoma Eyalet Üniversitesi, Azot Kullanım Etkinliği (NUE) sayfası":
        "Photo: Oklahoma State University, Nitrogen Use Efficiency (NUE) page",
    "Görsel: Şimşek 2023, Türk Uzaktan Algılama ve CBS Dergisi 4(2) (CC BY-NC-ND 4.0)":
        "Image: Şimşek 2023, Türk Uzaktan Algılama ve CBS Dergisi 4(2) (CC BY-NC-ND 4.0)",
}
ON_EK = {"Fotoğraf: ": "Photo: ", "Görsel: ": "Image: ", "Görüntü: ": "Image: ", "Şekil: ": "Figure: ",
         "Harita: ": "Map: ", "Grafik: ": "Chart: ", "Şema: ": "Diagram: "}
SOZ = [
    (" ve ark.", " et al."), (", Şekil ", ", Fig. "), ("Şekil ", "Fig. "), ("(kamu malı)", "(public domain)"),
    ("Wikimedia Commons üzerinden", "via Wikimedia Commons"), ("(basın bülteni görseli)", "(press release image)"),
    ("(tanıtım görseli)", "(promotional image)"), ("(tanıtım şeması)", "(promotional diagram)"),
    ("(ürün görseli)", "(product image)"),
    ("(şirket sitesindeki ürün ekran görüntüsü)", "(product screenshot from the company website)"),
    (" İl Tarım ve Orman Müdürlüğü", " Provincial Directorate of Agriculture and Forestry"),
    ("Avrupa Komisyonu", "European Commission"), (" haberi", " news item"), (" basın odası", " press room"),
    ("FIgLib arşivi", "FIgLib archive"), ("GRACE-FO verisi", "GRACE-FO data"),
    ("MODIS Atmosphere Science Team verisi", "MODIS Atmosphere Science Team data"),
    ("McFadden ve Njuki", "McFadden and Njuki"), ("Kumar ve Kalita", "Kumar and Kalita"),
]

# PDF içindeki şekiller: (yerel kopya [kaynak_dosyalari/] ya da None → adresten indir, sayfa, kutu).
# Kutu sayfanın 0-1 kesirleri; sayfa çizimlerine bakılarak belirlendi (18 Kas 2026).
KIRP = {
    "https://edepot.wur.nl/283306": ("aquatag_wur_283306.pdf", 1, "0.029,0.548,0.484,0.713"),
    "https://dergipark.org.tr/tr/download/article-file/1615376": ("altun_turker_2021_kiziltepe.pdf", 11, "0.093,0.064,0.913,0.438"),
    "https://dergipark.org.tr/tr/download/article-file/3023466": ("simsek_2023_apts_siniflandirma.pdf", 11, "0.104,0.285,0.913,0.759"),
    "https://dergipark.org.tr/en/download/article-file/4074610": (None, 16, "0.214,0.154,0.848,0.330"),
    "https://dergipark.org.tr/en/download/article-file/2608585": (None, 4, "0.224,0.564,0.795,0.721"),
    "https://dergipark.org.tr/en/download/article-file/1201243": ("civelek_2022_tarim_bilimleri_dergisi.pdf", 3, "0.127,0.449,0.876,0.598"),
}

# Künye düzeltmeleri: künye görselin ne olduğudur; şerh ve yorum girmez.
KUNYE = {
    "b01-ecmwf-nin-yapay-zeka-tahmin-sistemi": {
        "tr": "ECMWF'nin yapay zekâ tahmin sistemi AIFS'i sadeleştirilmiş biçimde anlatan bilgi şemasının Türkçeye "
              "uyarlanmış hâli; özgün şema, AIFS'in 25 Şubat 2025'te işletime alındığını duyuran ECMWF haberinde yayımlandı.",
        "en": None,  # özgün İngilizce künye kalır
    },
    "b06-bitki-ortusu-sensoruyle-azot": {
        "tr": "Nebraska Üniversitesi–Lincoln'ün Project SENSE çalışmasını tanıtan CropWatch yazısındaki yüksek "
              "açıklıklı uygulama makinesi; çalışma, mısırda bitki örtüsü sensörüne dayalı sezon içi değişken oranlı "
              "azot uygulamasını çiftlik denemeleriyle sınıyor. Yazı 2 Aralık 2014 tarihli.",
        "en": "A high-clearance applicator in UNL CropWatch's article introducing Project SENSE, an on-farm research "
              "project testing in-season, crop-canopy-sensor-based variable-rate nitrogen application in corn. "
              "Article dated 2 December 2014.",
    },
}


# Kaynak satırı düzeltmeleri (ör. Türkçe uyarlama).
KAYNAK = {
    "b01-ecmwf-nin-yapay-zeka-tahmin-sistemi": {"tr": "Görsel: ECMWF (CC BY 4.0); Türkçeye uyarlandı", "en": None},
}


def kunye_duzelt(gorseller: dict) -> None:
    for k, g in gorseller.items():
        for alan, tablo in (("kunye", KUNYE), ("kaynak", KAYNAK)):
            for dil, metin in tablo.get(k, {}).items():
                if metin:
                    g[alan][dil] = metin
        for dil in ("tr", "en"):
            m = g["kunye"][dil].rstrip()
            g["kunye"][dil] = m if m.endswith((".", "!", "?")) else m + "."


TUR = {"Fotoğraf": "foto", "Görsel": "gorsel", "Görüntü": "goruntu", "Şekil": "sema", "Şema": "sema",
       "Harita": "harita", "Grafik": "grafik"}


def commons_kucuk(adres: str) -> str:
    """Wikimedia Commons özgün dosyası yerine 1280 piksellik küçük resmi
    (Wikimedia'nın önerdiği yol; özgün dosyalarda hız sınırı sıkı). Commons
    API'si küçük resim adresini verir; özgün daha darsa özgünün adresini."""
    if "upload.wikimedia.org/wikipedia/commons/" not in adres or "/thumb/" in adres:
        return adres
    import urllib.parse
    import urllib.request
    ad = urllib.parse.unquote(adres.rsplit("/", 1)[-1])

    def sor(genislik: int) -> str:
        sorgu = urllib.parse.urlencode({"action": "query", "titles": f"File:{ad}", "prop": "imageinfo",
                                        "iiprop": "url", "iiurlwidth": str(genislik), "format": "json"})
        istek = urllib.request.Request(f"https://commons.wikimedia.org/w/api.php?{sorgu}",
                                       headers={"User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                                                "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120 Safari/537.36"})
        try:
            with urllib.request.urlopen(istek, timeout=30) as y:
                veri = json.loads(y.read().decode("utf-8"))
            for sayfa in veri.get("query", {}).get("pages", {}).values():
                for bilgi in sayfa.get("imageinfo", []):
                    return bilgi.get("thumburl") or ""
        except Exception:
            pass
        return ""

    # Özgün 1280'den darsa API özgünün adresini döner; o zaman daha dar küçük resim.
    for genislik in (1280, 600):
        kucuk = sor(genislik)
        if "/thumb/" in kucuk:
            return kucuk
    # Küçük özgünlerde API özgünü veriyor; standart 500 piksellik küçük resim.
    yol = adres.split("/wikipedia/commons/", 1)[1]
    dosya = yol.rsplit("/", 1)[-1]
    return f"https://upload.wikimedia.org/wikipedia/commons/thumb/{yol}/500px-{dosya}"


def kaynak_en(tr: str) -> str:
    if tr in KAYNAK_EN:
        return KAYNAK_EN[tr]
    en = tr
    for a, b in ON_EK.items():
        if en.startswith(a):
            en = b + en[len(a):]
    for a, b in SOZ:
        en = en.replace(a, b)
    return en


def kimlik(no: int, konu: str) -> str:
    s = re.sub(r"\([^)]*\)", "", konu).replace("ı", "i").replace("İ", "i")
    s = unicodedata.normalize("NFKD", s).encode("ascii", "ignore").decode().lower()
    kelimeler = [k for k in re.split(r"[^a-z0-9]+", s) if k]
    sonuc = ""
    for k in kelimeler:
        if len(sonuc) + len(k) + 1 > 36:
            break
        sonuc = f"{sonuc}-{k}" if sonuc else k
    return f"b{no:02d}-{sonuc}"


def bloklar(metin: str) -> list[str]:
    return [b for b in re.split(r"\n\s*\n", metin.strip()) if b.strip()]


def yerlestir(metin: str, eklenecek: dict[int, list[str]]) -> str:
    parcalar = re.split(r"(\n[ \t]*\n\s*)", metin)
    sayac = -1
    for j in range(0, len(parcalar), 2):
        if parcalar[j].strip():
            sayac += 1
            if sayac in eklenecek:
                parcalar[j] = parcalar[j].rstrip("\n") + "".join(f"\n\n{y}" for y in eklenecek[sayac])
    return "".join(parcalar)


def pdf_mi(a: dict) -> bool:
    return "PDF" in str(a.get("boyut", "")) or a["gorsel_adresi"].lower().endswith(".pdf")


def main() -> int:
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    klasor = Path(sys.argv[1])
    kuru = "--kuru" in sys.argv
    adaylar, gorulen = [], set()
    for f in [*sorted(klasor.glob("gorsel_adaylari_parca_*.json")), klasor / "gorsel_adaylari.json"]:
        if not f.exists():
            continue
        d = json.loads(f.read_text(encoding="utf-8"))
        for a in (d.get("adaylar", []) if isinstance(d, dict) else d):
            if a["gorsel_adresi"] not in gorulen:
                gorulen.add(a["gorsel_adresi"])
                adaylar.append(a)
    kayit = json.loads(KAYIT.read_text(encoding="utf-8")) if KAYIT.exists() else {
        "_ne": "Bölüm görselleri (karar 58). Dosyalar web/yz/gorsel/ altında; künye görselin ne olduğudur, "
               "kaynak satırı ayrı. Hak sahibi itiraz ederse kayıt ve yönerge silinir (dogrula_bolumler.py kural 12).",
        "gorseller": {}}
    gorseller = kayit["gorseller"]
    secilen, atlanan, pdf = [], [], []
    for a in adaylar:
        if a.get("indirme_yasagi") or any(a["konu"].startswith(x) for x in ALINMAZ):
            atlanan.append(a)
        elif pdf_mi(a) and a["gorsel_adresi"] not in KIRP:
            pdf.append(a)
        else:
            secilen.append(a)
    print(f"{len(adaylar)} aday · {len(secilen)} işlenecek · {len(pdf)} PDF şekli (ayrı adım) · {len(atlanan)} alınmıyor")
    if kuru:
        for a in secilen:
            print(f"  {kimlik(a['baslik_no'], a['konu'])} ← {a['gorsel_adresi'][:80]}")
        return 0
    hatalar = []
    for a in secilen:
        k = kimlik(a["baslik_no"], a["konu"])
        if k in gorseller and (DEPO / gorseller[k]["dosya"]).exists():
            continue
        if a["gorsel_adresi"] in KIRP:
            yerel, sayfa, kutu = KIRP[a["gorsel_adresi"]]
            kaynak_pdf = str(BURASI / "kaynak_dosyalari" / yerel) if yerel else a["gorsel_adresi"]
            komut = [str(PYTHON), "-I", str(BURASI / "gorsel_kirp.py"), k, kaynak_pdf, str(sayfa), kutu]
        else:
            indirilecek = commons_kucuk(a["gorsel_adresi"])
            komut = [str(PYTHON), "-I", str(BURASI / "gorsel_al.py"), k, indirilecek]
        cikti = subprocess.run(komut, capture_output=True, text=True, timeout=400)
        # Sunucuları yormamak için; Wikimedia'da daha uzun ara (hız sınırı: 429).
        time.sleep(8 if "wikimedia.org" in a["gorsel_adresi"] else 3)
        son = (cikti.stdout.strip().splitlines() or [""])[-1]
        if cikti.returncode != 0 or not son.startswith("{"):
            hatalar.append((k, (son or (cikti.stderr.strip().splitlines() or ["?"])[-1])[:160]))
            print(f"  ✗ {k}: {hatalar[-1][1]}")
            continue
        sonuc = json.loads(son)
        kaynak_tr = IC_NOT.sub("", a.get("kaynak_satiri", "")).strip()
        on = kaynak_tr.split(":")[0]
        gorseller[k] = {
            "baslik_no": a["baslik_no"],
            "dosya": sonuc["dosya"],
            "genislik": sonuc["genislik"],
            "yukseklik": sonuc["yukseklik"],
            "sha256": sonuc["sha256"],
            "kunye": {"tr": a["kunye_tr"].strip(), "en": a["kunye_en"].strip()},
            "kaynak": {"tr": kaynak_tr, "en": kaynak_en(kaynak_tr)},
            "sayfa_adresi": a.get("sayfa_adresi", ""),
            "gorsel_adresi": sonuc["gorsel_adresi"] or a["gorsel_adresi"],
            "indirme_gunu": sonuc["indirme_gunu"],
            "lisans_notu": a.get("lisans_notu", ""),
            "tur": TUR.get(on, "gorsel"),
            "yapay_zeka": False,
            "yer": a["metindeki_yer"],
        }
        print(f"  ✓ {k} · {sonuc['genislik']}×{sonuc['yukseklik']} · {sonuc['bayt'] // 1024} KB")
        KAYIT.write_text(json.dumps(kayit, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    # Yönergeler.
    for no in sorted({g["baslik_no"] for g in gorseller.values()}):
        tr = next(BOLUMLER.glob(f"{no:02d}-*.tr.md"))
        en = tr.with_name(tr.name.replace(".tr.md", ".en.md"))
        mt, me = tr.read_text(encoding="utf-8"), en.read_text(encoding="utf-8")
        bt, be = bloklar(mt), bloklar(me)
        if len(bt) != len(be):
            print(f"  ! {tr.name}: TR {len(bt)}, EN {len(be)} blok — yerleştirilmedi")
            continue
        eklenecek: dict[int, list[str]] = {}
        for k, g in gorseller.items():
            if g["baslik_no"] != no or f"[[gorsel:{k}]]" in mt:
                continue
            i = [j for j, b in enumerate(bt) if b.startswith(g["yer"])]
            if len(i) != 1:
                print(f"  ! {k}: yer bulunamadı ya da birden çok ({len(i)})")
                continue
            eklenecek.setdefault(i[0], []).append(f"[[gorsel:{k}]]")
        if eklenecek:
            tr.write_text(yerlestir(mt, eklenecek), encoding="utf-8")
            en.write_text(yerlestir(me, eklenecek), encoding="utf-8")
            print(f"  · {tr.name}: {sum(len(v) for v in eklenecek.values())} görsel")
    kunye_duzelt(gorseller)
    KAYIT.write_text(json.dumps(kayit, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    print(f"✓ {len(gorseller)} görsel kayıtta · {len(hatalar)} alınamadı")
    for k, h in hatalar:
        print(f"  ✗ {k}: {h}")
    if pdf:
        print("PDF şekilleri (ayrı adım):")
        for a in pdf:
            print(f"  {kimlik(a['baslik_no'], a['konu'])} ← {a['sayfa_adresi']} · {a.get('boyut')}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
