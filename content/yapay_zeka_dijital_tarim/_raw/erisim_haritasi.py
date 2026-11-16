#!/usr/bin/env python3
"""Yapay Zeka ve Dijital Tarım — kaynak erişim haritası.

NE YAPAR: izlenmesi düşünülen her kaynağa tek bir istek atar ve ERİŞİM
NİTELİĞİNİ ölçer. Bölümün "kendini güncelleyen" yapısı bu ölçüme
dayanacak; hangi kaynağın API'si var, hangisi yalnız sayfa, hangisi
kapalı — tahmin edilmez, ölçülür.

YUMUŞAK 404 — BU PROJENİN KAYITLI TUZAĞI (§2.12.1, İspanya dosyası).
Durum kodu 200 dönmesi sayfanın VAR olduğu anlamına gelmiyor: FAO'nun
AQUASTAT sayfası 200 dönüyordu ama gövdesi 1.659 karakterlik bir
JavaScript kabuğuydu; fao.org/3/<belge>.pdf 200 + text/html dönüyordu.
Bu yüzden sınıflandırma üç şeye birden bakıyor:
    durum kodu  ·  içerik türü  ·  gövde uzunluğu
Beklenen tür ile gelen tür ayrışıyorsa ya da gövde eşiğin altındaysa
kaynak AÇIK sayılmıyor.

KULLANICI ADRESİ GÖNDERİLMİYOR. Dizideki bazı betikler User-Agent'a
kullanıcının e-postasını koyuyor; burada genel bir istemci adı var.

Çalıştırma: python3 content/yapay_zeka_dijital_tarim/_raw/erisim_haritasi.py
"""
from __future__ import annotations

import json
import pathlib
import ssl
import time
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor

KOK = pathlib.Path(__file__).parent
UA = "tarimportali.net bolum arastirmasi"
ZAMAN_ASIMI = 20
GOVDE_ESIGI = 2000          # bunun altı kabuk sayılıyor

# sinif: BIRINCIL (resmî/kurumsal belge) · BAGIMSIZ (veri/akademik) · SEKTOR
KAYNAKLAR = [
    # ── TÜRKİYE · mevzuat ve kamu ─────────────────────────────────────
    ("Resmî Gazete · güncel", "https://www.resmigazete.gov.tr/", "html", "BIRINCIL", "mevzuat"),
    ("Resmî Gazete · arşiv PDF", "https://www.resmigazete.gov.tr/arsiv/10127.pdf", "pdf", "BIRINCIL", "mevzuat"),
    ("Tarım ve Orman Bakanlığı", "https://www.tarimorman.gov.tr/", "html", "BIRINCIL", "mevzuat"),
    ("TAGEM", "https://www.tarimorman.gov.tr/TAGEM", "html", "BIRINCIL", "mevzuat"),
    ("Mevzuat Bilgi Sistemi", "https://www.mevzuat.gov.tr/", "html", "BIRINCIL", "mevzuat"),
    ("Dijital Dönüşüm Ofisi", "https://cbddo.gov.tr/", "html", "BIRINCIL", "mevzuat"),
    ("Ulusal Yapay Zeka Stratejisi", "https://cbddo.gov.tr/uyzs/", "html", "BIRINCIL", "mevzuat"),
    ("Sanayi ve Teknoloji Bakanlığı", "https://www.sanayi.gov.tr/", "html", "BIRINCIL", "mevzuat"),
    # JS KABUĞUNUN ALTINDAKİ VERİ (Tur 2). Sayfa Angular kabuğu ama liste
    # düz bir JSON'dan yükleniyor: bakanlığın BÜTÜN strateji belgelerinin
    # dizini. Yeni bir strateji belgesi yayımlandığında tarama bunu
    # otomatik yakalar. Mevzuat katmanının ilk makine okunur kaynağı.
    ("Sanayi ve Teknoloji Bak. · belge dizini", "https://www.sanayi.gov.tr/assets/data/planning.json", "json", "BIRINCIL", "mevzuat"),
    ("TÜBİTAK", "https://www.tubitak.gov.tr/", "html", "BIRINCIL", "mevzuat"),
    ("TÜİK · kurumsal", "https://www.tuik.gov.tr/", "html", "BAGIMSIZ", "veri"),
    ("TÜİK · veri portalı", "https://data.tuik.gov.tr/", "html", "BAGIMSIZ", "veri"),
    ("TBMM · yasama", "https://www.tbmm.gov.tr/", "html", "BIRINCIL", "mevzuat"),

    # ── AKADEMİK ──────────────────────────────────────────────────────
    ("arXiv API", "http://export.arxiv.org/api/query?search_query=all:agriculture+AND+cat:cs.AI&max_results=2", "xml", "BAGIMSIZ", "akademik"),
    ("OpenAlex API", "https://api.openalex.org/works?search=artificial%20intelligence%20agriculture&per-page=2", "json", "BAGIMSIZ", "akademik"),
    ("Semantic Scholar API", "https://api.semanticscholar.org/graph/v1/paper/search?query=precision+agriculture+AI&limit=2", "json", "BAGIMSIZ", "akademik"),
    ("Crossref API", "https://api.crossref.org/works?query=artificial+intelligence+agriculture&rows=2", "json", "BAGIMSIZ", "akademik"),
    ("Europe PMC API", "https://www.ebi.ac.uk/europepmc/webservices/rest/search?query=agriculture%20AI&format=json&pageSize=2", "json", "BAGIMSIZ", "akademik"),
    ("DOAJ API", "https://doaj.org/api/search/articles/agriculture%20artificial%20intelligence?pageSize=2", "json", "BAGIMSIZ", "akademik"),
    ("CORE API", "https://api.core.ac.uk/v3/search/works?q=agriculture+AI", "json", "BAGIMSIZ", "akademik"),
    ("DergiPark", "https://dergipark.org.tr/tr/", "html", "BAGIMSIZ", "akademik"),
    ("YÖK Tez Merkezi", "https://tez.yok.gov.tr/UlusalTezMerkezi/", "html", "BAGIMSIZ", "akademik"),

    # ── KURUMSAL / ULUSLARARASI ───────────────────────────────────────
    ("FAO · yayınlar", "https://www.fao.org/publications/en", "html", "BIRINCIL", "kurumsal"),
    ("FAO · açık bilgi deposu", "https://openknowledge.fao.org/", "html", "BIRINCIL", "kurumsal"),
    ("FAOSTAT API", "https://faostatservices.fao.org/api/v1/en/dimensions", "json", "BAGIMSIZ", "veri"),
    ("OECD · iLibrary", "https://www.oecd-ilibrary.org/agriculture-and-food", "html", "BIRINCIL", "kurumsal"),
    ("OECD · veri API", "https://sdmx.oecd.org/public/rest/dataflow/OECD.TAD.ARP/all/latest", "xml", "BAGIMSIZ", "veri"),
    ("Dünya Bankası API", "https://api.worldbank.org/v2/indicator?format=json&per_page=2", "json", "BAGIMSIZ", "veri"),
    ("AB · CORDIS", "https://cordis.europa.eu/search?q=agriculture%20artificial%20intelligence", "html", "BIRINCIL", "kurumsal"),
    ("AB · Açık Veri Portalı", "https://data.europa.eu/api/hub/search/search?q=agriculture%20AI&limit=2", "json", "BAGIMSIZ", "veri"),
    ("AB · JRC", "https://joint-research-centre.ec.europa.eu/index_en", "html", "BIRINCIL", "kurumsal"),
    ("CGIAR", "https://www.cgiar.org/", "html", "BIRINCIL", "kurumsal"),
    ("IFPRI", "https://www.ifpri.org/", "html", "BIRINCIL", "kurumsal"),
    ("USDA · ERS", "https://www.ers.usda.gov/", "html", "BIRINCIL", "kurumsal"),
    ("USDA · NASS API", "https://quickstats.nass.usda.gov/api/get_param_values/?key=&param=source_desc", "json", "BAGIMSIZ", "veri"),
    ("WIPO", "https://www.wipo.int/", "html", "BIRINCIL", "patent"),
    ("PatentsView API", "https://search.patentsview.org/api/v1/patent/?q={}", "json", "BAGIMSIZ", "patent"),
    ("EPO · Espacenet", "https://worldwide.espacenet.com/", "html", "BAGIMSIZ", "patent"),
    ("TÜRKPATENT", "https://www.turkpatent.gov.tr/", "html", "BIRINCIL", "patent"),

    # ── SEKTÖR VE GİRİŞİM ─────────────────────────────────────────────
    ("AgFunder News", "https://agfundernews.com/", "html", "SEKTOR", "sektor"),
    ("AgFunder · RSS", "https://agfundernews.com/feed", "xml", "SEKTOR", "sektor"),
    ("Precision Agriculture dergisi", "https://link.springer.com/journal/11119", "html", "BAGIMSIZ", "akademik"),
    ("Future Farming", "https://www.futurefarming.com/", "html", "SEKTOR", "sektor"),
    ("Webrazzi", "https://webrazzi.com/", "html", "SEKTOR", "sektor"),
    ("Startups.watch", "https://startups.watch/", "html", "SEKTOR", "sektor"),
    ("TechCrunch · RSS", "https://techcrunch.com/feed/", "xml", "SEKTOR", "sektor"),
    ("Google News RSS · tarımda yapay zeka", "https://news.google.com/rss/search?q=tar%C4%B1mda+yapay+zeka&hl=tr&gl=TR&ceid=TR:tr", "xml", "SEKTOR", "sektor"),
    # ══ İKİNCİ DALGA — kullanıcı: "kaynakları olabildiğine geniş tut" ══

    # ── TÜRKİYE · kurum, birlik, sektör örgütü ────────────────────────
    ("TZOB · Ziraat Odaları Birliği", "https://www.tzob.org.tr/", "html", "BIRINCIL", "mevzuat"),
    ("TOBB", "https://www.tobb.org.tr/", "html", "BIRINCIL", "mevzuat"),
    ("Ziraat Mühendisleri Odası", "https://www.zmo.org.tr/", "html", "BAGIMSIZ", "mevzuat"),
    ("BTK", "https://www.btk.gov.tr/", "html", "BIRINCIL", "mevzuat"),
    ("TARSİM", "https://www.tarsim.gov.tr/", "html", "BIRINCIL", "mevzuat"),
    ("TİGEM", "https://www.tigem.gov.tr/", "html", "BIRINCIL", "mevzuat"),
    ("DSİ", "https://www.dsi.gov.tr/", "html", "BIRINCIL", "mevzuat"),
    ("Tarım Kredi", "https://www.tarimkredi.org.tr/", "html", "BIRINCIL", "mevzuat"),
    ("TEKNOFEST", "https://www.teknofest.org/", "html", "SEKTOR", "sektor"),
    ("TÜBİTAK BİLGEM", "https://bilgem.tubitak.gov.tr/", "html", "BIRINCIL", "mevzuat"),
    ("KOSGEB", "https://www.kosgeb.gov.tr/", "html", "BIRINCIL", "mevzuat"),
    ("Kalkınma Ajansları", "https://www.sanayi.gov.tr/kalkinma-ajanslari", "html", "BIRINCIL", "mevzuat"),

    # ── ULUSLARARASI KURUM ────────────────────────────────────────────
    ("IFAD", "https://www.ifad.org/en/", "html", "BIRINCIL", "kurumsal"),
    ("Dünya Gıda Programı", "https://www.wfp.org/", "html", "BIRINCIL", "kurumsal"),
    ("UNDP", "https://www.undp.org/", "html", "BIRINCIL", "kurumsal"),
    ("ITU · AI for Good", "https://aiforgood.itu.int/", "html", "BIRINCIL", "kurumsal"),
    ("GSMA · AgriTech", "https://www.gsma.com/solutions-and-impact/connectivity-for-good/mobile-for-development/agritech/", "html", "SEKTOR", "kurumsal"),
    ("AB · Tarım Genel Müdürlüğü", "https://agriculture.ec.europa.eu/index_en", "html", "BIRINCIL", "kurumsal"),
    ("AB · Yapay Zeka Yasası", "https://artificialintelligenceact.eu/", "html", "BAGIMSIZ", "kurumsal"),
    ("AB · EUR-Lex", "https://eur-lex.europa.eu/homepage.html", "html", "BIRINCIL", "mevzuat"),
    ("EIT Food", "https://www.eitfood.eu/", "html", "SEKTOR", "kurumsal"),
    ("CABI", "https://www.cabi.org/", "html", "BIRINCIL", "kurumsal"),
    ("IRRI · pirinç", "https://www.irri.org/", "html", "BIRINCIL", "kurumsal"),
    ("CIMMYT · buğday-mısır", "https://www.cimmyt.org/", "html", "BIRINCIL", "kurumsal"),
    ("ICRISAT", "https://www.icrisat.org/", "html", "BIRINCIL", "kurumsal"),
    ("Gates Vakfı · tarım", "https://www.gatesfoundation.org/our-work/programs/global-growth-and-opportunity/agricultural-development", "html", "SEKTOR", "kurumsal"),
    ("OECD · AI Politika Gözlemevi", "https://oecd.ai/en/", "html", "BIRINCIL", "kurumsal"),

    # ── UYDU VE YER GÖZLEMİ — tarımsal yapay zekanın veri tabanı ───────
    ("Copernicus", "https://www.copernicus.eu/en", "html", "BIRINCIL", "veri"),
    ("Copernicus · Data Space API", "https://catalogue.dataspace.copernicus.eu/odata/v1/Collections", "json", "BAGIMSIZ", "veri"),
    ("NASA Earthdata", "https://www.earthdata.nasa.gov/", "html", "BIRINCIL", "veri"),
    ("NASA · CMR API", "https://cmr.earthdata.nasa.gov/search/collections.json?keyword=crop&page_size=2", "json", "BAGIMSIZ", "veri"),
    ("GEOGLAM · Crop Monitor", "https://cropmonitor.org/", "html", "BIRINCIL", "veri"),
    ("Sentinel Hub", "https://www.sentinel-hub.com/", "html", "SEKTOR", "veri"),

    # ── AKADEMİK DERGİ VE AÇIK ARŞİV ──────────────────────────────────
    ("Computers and Electronics in Agriculture", "https://www.sciencedirect.com/journal/computers-and-electronics-in-agriculture", "html", "BAGIMSIZ", "akademik"),
    ("Smart Agricultural Technology", "https://www.sciencedirect.com/journal/smart-agricultural-technology", "html", "BAGIMSIZ", "akademik"),
    ("Frontiers in Plant Science", "https://www.frontiersin.org/journals/plant-science", "html", "BAGIMSIZ", "akademik"),
    ("MDPI · Agriculture", "https://www.mdpi.com/journal/agriculture", "html", "BAGIMSIZ", "akademik"),
    ("Papers with Code · tarım", "https://paperswithcode.com/search?q=agriculture", "html", "BAGIMSIZ", "akademik"),
    ("Hugging Face · tarım veri setleri", "https://huggingface.co/api/datasets?search=agriculture&limit=2", "json", "BAGIMSIZ", "akademik"),
    ("Zenodo API", "https://zenodo.org/api/records?q=agriculture%20machine%20learning&size=2", "json", "BAGIMSIZ", "akademik"),

    # ── SEKTÖR YAYINI ─────────────────────────────────────────────────
    ("Precision Ag", "https://www.precisionag.com/", "html", "SEKTOR", "sektor"),
    ("AgriTechTomorrow", "https://www.agritechtomorrow.com/", "html", "SEKTOR", "sektor"),
    ("Farmers Weekly", "https://www.fwi.co.uk/", "html", "SEKTOR", "sektor"),
    ("Agri-Pulse", "https://www.agri-pulse.com/", "html", "SEKTOR", "sektor"),
    ("Successful Farming", "https://www.agriculture.com/", "html", "SEKTOR", "sektor"),
    ("Google News RSS · AI agriculture", "https://news.google.com/rss/search?q=artificial+intelligence+agriculture&hl=en&gl=US&ceid=US:en", "xml", "SEKTOR", "sektor"),
    ("Google News RSS · dijital tarım", "https://news.google.com/rss/search?q=dijital+tar%C4%B1m&hl=tr&gl=TR&ceid=TR:tr", "xml", "SEKTOR", "sektor"),
]

BEKLENEN_TUR = {
    "html": ("text/html", "application/xhtml"),
    "json": ("application/json", "text/json", "application/vnd.api+json"),
    "xml": ("xml", "rss", "atom"),
    "pdf": ("application/pdf",),
}


def olc(kayit):
    ad, adres, beklenen, sinif, katman = kayit
    sonuc = {"ad": ad, "adres": adres, "beklenen": beklenen,
             "sinif": sinif, "katman": katman}
    baslangic = time.time()
    try:
        istek = urllib.request.Request(adres, headers={
            "User-Agent": UA, "Accept": "*/*"})
        baglam = ssl.create_default_context()
        with urllib.request.urlopen(istek, timeout=ZAMAN_ASIMI,
                                    context=baglam) as cevap:
            govde = cevap.read(400_000)
            sonuc["kod"] = cevap.status
            sonuc["tur"] = (cevap.headers.get("Content-Type") or "").split(";")[0].strip()
            sonuc["bayt"] = len(govde)
            sonuc["son_adres"] = cevap.geturl()
            sonuc["_govde"] = govde
    except urllib.error.HTTPError as e:
        sonuc.update({"kod": e.code, "tur": (e.headers.get("Content-Type") or "").split(";")[0] if e.headers else "",
                      "bayt": 0, "hata": f"HTTP {e.code}"})
    except Exception as e:
        sonuc.update({"kod": 0, "tur": "", "bayt": 0,
                      "hata": f"{type(e).__name__}: {str(e)[:90]}"})
    sonuc["saniye"] = round(time.time() - baslangic, 2)

    # ── SINIFLANDIRMA — üç ölçüye birden bakılıyor ───────────────────
    kod, tur, bayt = sonuc.get("kod", 0), sonuc.get("tur", ""), sonuc.get("bayt", 0)
    if kod == 0:
        sonuc["teshis"] = "KAPALI · bağlantı kurulmadı"
    elif kod in (401, 403):
        sonuc["teshis"] = "ANAHTAR GEREKLİ ya da engelli"
    elif kod == 429:
        sonuc["teshis"] = "KISITLI · hız sınırı"
    elif kod >= 400:
        sonuc["teshis"] = f"KAPALI · HTTP {kod}"
    elif not any(b in tur.lower() for b in BEKLENEN_TUR[beklenen]):
        # Durum kodu 200 ama tür beklenenden başka: klasik yumuşak 404.
        sonuc["teshis"] = f"YUMUŞAK 404 · {beklenen} beklendi, '{tur}' geldi"
    elif beklenen == "html" and gorunur_metin(sonuc.get("_govde", b"")) < GORUNUR_ESIGI:
        # ÜÇÜNCÜ KUSUR (Tur 2): sanayi.gov.tr 2.496 bayt döndürüyordu — eşiği
        # geçiyor, "açık" sayıldı. Ama gövde bir Angular kabuğuydu: başlık,
        # Google Analytics ve boş bir gövde. Görünür metni ~40 karakter. ÜÇ
        # FARKLI ADRES bayt bayt AYNI cevabı verdi (aynı MD5). Ham bayt kabuğu
        # ölçmez; görünür metin ölçer.
        sonuc["teshis"] = (f"JS KABUĞU · {bayt} bayt ama görünür metin "
                           f"{gorunur_metin(sonuc.get('_govde', b''))} karakter")
    elif beklenen == "html" and bayt < GOVDE_ESIGI:
        # Eşik YALNIZ HTML için. İlk sürüm onu her türe uyguluyordu ve
        # sayfa başına iki kayıt istenen API'leri kabuk saydı: Dünya
        # Bankası 872 bayt, Europe PMC 1.904 bayt — ikisi de gerçek veri.
        # Kısa bir JSON cevabı kabuk değildir; kabuk HTML'in hastalığı.
        sonuc["teshis"] = f"KABUK · gövde {bayt} bayt, eşik {GOVDE_ESIGI}"
    else:
        sonuc["teshis"] = icerik_sina(beklenen, sonuc.get("_govde", b""))
    sonuc.pop("_govde", None)
    return sonuc


GORUNUR_ESIGI = 300      # görünür karakter; bunun altı JS kabuğu


def gorunur_metin(govde: bytes) -> int:
    """Betik, stil ve etiketler atıldıktan sonra kalan görünür metin."""
    import re as _re
    m = govde.decode("utf-8", "replace")
    m = _re.sub(r"(?is)<(script|style|noscript)[^>]*>.*?</\1>", " ", m)
    m = _re.sub(r"(?s)<[^>]+>", " ", m)
    m = _re.sub(r"&[a-z#0-9]+;", " ", m)
    return len(_re.sub(r"\s+", " ", m).strip())


def icerik_sina(beklenen: str, govde: bytes) -> str:
    """Türüne göre GERÇEK içerik var mı. Durum kodu ve tür doğru ama içi
    boş bir cevap da yumuşak 404'ün bir biçimi."""
    if beklenen == "json":
        try:
            veri = json.loads(govde.decode("utf-8", "replace"))
        except Exception:
            return "YUMUŞAK 404 · JSON bekleniyordu, ayrıştırılamadı"
        if veri in ({}, [], None):
            return "BOŞ · JSON geçerli ama içerik yok"
        return "AÇIK"
    if beklenen == "xml":
        metin = govde.decode("utf-8", "replace")
        if not any(e in metin for e in ("<entry", "<item", "<Dataflow", "<structure:", "<feed")):
            return "BOŞ · XML geldi ama kayıt yok"
        return "AÇIK"
    if beklenen == "pdf":
        return "AÇIK" if govde[:5] == b"%PDF-" else "YUMUŞAK 404 · PDF imzası yok"
    return "AÇIK"


# EŞZAMANLILIK 2. İlk koşu 8 idi ve OpenAlex, Semantic Scholar, CORE
# 429 döndü — üçü de açık API, sınırı biz zorladık. Ölçüm aracı ölçtüğü
# şeyi bozmamalı.
with ThreadPoolExecutor(max_workers=2) as havuz:
    sonuclar = list(havuz.map(olc, KAYNAKLAR))

cikti = {
    "_ne": "Yapay Zeka ve Dijital Tarım bölümü — kaynak erişim haritası",
    "_yontem": ("Her kaynağa tek istek. Sınıflandırma durum kodu, içerik "
                "türü ve gövde uzunluğuna BİRDEN bakıyor; yalnız duruma "
                "bakmak yumuşak 404'ü kaçırır (§2.12.1)."),
    "_tarih": time.strftime("%Y-%m-%d"),
    "_govde_esigi": GOVDE_ESIGI,
    "_uyari": ("Bu ölçüm ANLIK. Bir kaynağın bugün açık olması yarın açık "
               "kalacağı anlamına gelmiyor; tarama her koşuda yeniden "
               "ölçmeli ve düşen kaynağı bildirmeli."),
    "kaynaklar": sorted(sonuclar, key=lambda s: (s["katman"], s["ad"])),
}
(KOK / "erisim.json").write_text(
    json.dumps(cikti, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")

sayac = {}
for s in sonuclar:
    anahtar = s["teshis"].split(" · ")[0]
    sayac[anahtar] = sayac.get(anahtar, 0) + 1
print(f"{len(sonuclar)} kaynak ölçüldü\n")
for katman in ("mevzuat", "akademik", "kurumsal", "veri", "patent", "sektor"):
    grup = [s for s in sonuclar if s["katman"] == katman]
    if not grup:
        continue
    print(f"── {katman.upper()}")
    for s in sorted(grup, key=lambda x: x["ad"]):
        im = "✓" if s["teshis"] == "AÇIK" else "✗"
        print(f"  {im} {s['ad']:36s} {s['teshis'][:52]}")
    print()
print("ÖZET: " + " · ".join(f"{k} {v}" for k, v in sorted(sayac.items())))
print("\n✓ erisim.json")
