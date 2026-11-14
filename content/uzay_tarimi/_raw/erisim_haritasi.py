#!/usr/bin/env python3
"""Kaynakların erişim durumunu ÖLÇER → erisim.json

YUMUŞAK 404 KURALI (§2.12.1). Durum koduna TEK BAŞINA bakılmaz. TÜBİTAK'ın
iki ayrı yolu HTTP 404 dönüyor ama gövde 180-330 KB'lık HTML; yalnız duruma
bakan "yok" der, yalnız gövdeye bakan "var" der. Üçü birden ölçülüyor:
durum · içerik türü · gövde uzunluğu. Beklenen türle gelen tür karşılaştırılır.

ÜÇÜNCÜ KAT — BOT DUVARI. Bu da ölçülerek eklendi. PMC (pmc.ncbi.nlm.nih.gov)
düz bir HTTP isteğine 200 + text/html dönüyor, yani üç ölçüt de "açık" diyor;
ama bazı istemcilere makale yerine "Checking your browser" doğrulama sayfası
veriyor. Tür beklenenle UYUŞUYOR, içerik ise duvar. Gövdede duvar imzası
aranıyor; bulunursa teşhis "bot duvarı".
"""
from __future__ import annotations
import json, pathlib, urllib.request, urllib.error, datetime, ssl

KOK = pathlib.Path(__file__).parent
UA = {"User-Agent": "tarimportali.net arastirma"}

KAYNAKLAR = [
    ("NASA OSDR arama API", "https://osdr.nasa.gov/osdr/data/search?term=plant&size=1&type=cgene", "json"),
    ("NASA görsel kütüphanesi API", "https://images-api.nasa.gov/search?q=veggie%20plant&media_type=image", "json"),
    ("NASA NTRS — ekin belgesi", "https://ntrs.nasa.gov/api/citations/20250001897/downloads/20231215%20Space%20Crops%20HRP%20FINAL%20STRIVES%203.pdf", "pdf"),
    ("Frontiers — marul makalesi", "https://www.frontiersin.org/journals/plant-science/articles/10.3389/fpls.2020.00199/pdf", "pdf"),
    ("PMC — marul makalesi", "https://pmc.ncbi.nlm.nih.gov/articles/PMC7067979/", "html"),
    ("Axiom — Extremophyte CRISPR", "https://axiomspace.com/research/extremophyte-crispr", "html"),
    ("TÜBA — 13 deney belgesi", "https://www.tuba.gov.tr/files/images/2024/AlperGezeravci/T%C3%BCrk%20Astronot%20Alper%20Gezeravc%C4%B1%E2%80%99n%C4%B1n%20Uzayda%20Yapaca%C4%9F%C4%B1%2013%20Bilimsel%20Deney.docx", "docx"),
    ("TÜBİTAK UZAY — biyoloji deneyleri", "https://uzay.tubitak.gov.tr/en/manned-space-missions/international-space-station-science-mission/biology-biotechnology/", "html"),
    ("TÜBİTAK bilimteknik — deney posteri", "https://bilimteknik.tubitak.gov.tr/sites/default/files/posterler/turkiyenin_insanli_ilk_uzay_misyonunda_gerceklestirilen_deneyler_posteri.pdf", "pdf"),
    ("TÜBİTAK — ikinci uzay yolculuğu", "https://tubitak.gov.tr/tr/haber/turkiyenin-ikinci-uzay-yolculugu-basariyla-tamamlandi", "html"),
    ("IAF — IAC-26 program dizini", "http://iafastro.directory/iac/browse/IAC-26/A1/IP/", "html"),
    ("TUA — IAC 2026 Antalya", "https://tua.gov.tr/en/international-activities/iac-2026-antalya-1", "html"),
]

BEKLENEN = {"json": "json", "pdf": "pdf", "html": "html",
            "docx": "officedocument"}

# Doğrulama/bot duvarı imzaları — gövde beklenen türde gelse bile içerik
# makale değil duvarsa yakalansın.
DUVAR = [b"Checking your browser", b"Just a moment", b"cf-browser-verification",
         b"Enable JavaScript and cookies to continue", b"captcha-delivery",
         b"Access to this page has been denied"]


def olc(url: str, beklenen: str) -> dict:
    try:
        istek = urllib.request.Request(url, headers=UA)
        with urllib.request.urlopen(istek, timeout=45) as r:
            govde = r.read(400_000)
            tur = r.headers.get("Content-Type", "")
            kod = r.status
    except urllib.error.HTTPError as e:
        govde = e.read(400_000) if hasattr(e, "read") else b""
        tur = e.headers.get("Content-Type", "") if e.headers else ""
        kod = e.code
    except Exception as e:
        return {"kod": None, "tur": None, "bayt": 0,
                "teshis": "ULAŞILAMADI", "hata": str(e)[:110]}

    # TEŞHİS — dört ölçüt birlikte
    uyum = BEKLENEN[beklenen] in tur.lower()
    duvar = next((d.decode() for d in DUVAR if d in govde[:200_000]), None)
    if duvar:
        teshis = f"BOT DUVARI · 200 ama içerik doğrulama sayfası ('{duvar[:28]}')"
    elif kod == 200 and uyum:
        teshis = "açık"
    elif kod == 200 and not uyum:
        teshis = f"YUMUŞAK 404 ŞÜPHESİ · 200 ama tür '{tur.split(';')[0]}'"
    elif kod != 200 and len(govde) > 50_000:
        teshis = f"YUMUŞAK 404 · kod {kod} ama {len(govde):,} bayt gövde"
    else:
        teshis = f"kapalı · kod {kod}"
    return {"kod": kod, "tur": tur.split(";")[0] or None,
            "bayt": len(govde), "beklenen": beklenen,
            "duvar_imzasi": duvar, "teshis": teshis}


sonuc = []
for ad, url, bek in KAYNAKLAR:
    o = olc(url, bek)
    o.update({"ad": ad, "adres": url})
    sonuc.append(o)
    print(f"  {o['teshis'][:52]:52s} {ad}")

acik = [s for s in sonuc if s["teshis"] == "açık"]
d = {
    "_ne": "Uzayda Tarım — kaynakların ölçülmüş erişim durumu",
    "_yontem": ("Durum kodu TEK BAŞINA yetmez. Üç ölçüt birlikte: kod · "
                "içerik türü · gövde uzunluğu. Beklenen tür ile gelen tür "
                "karşılaştırılıyor."),
    "_tarih": datetime.date.today().isoformat(),
    "_PMC_NOTU": ("PMC düz bir HTTP isteğine TAM MAKALEYİ veriyor (266 KB, "
                  "doğru başlık, Outredgeous/Veggie/anthocyanin gövdede). "
                  "Ama bazı getirici istemcilere 'Checking your browser' "
                  "doğrulama sayfası çıkarıyor. Yani kaynak AÇIK; engel "
                  "istemciye bağlı. Kural: PMC'den içerik alınacaksa düz "
                  "istek (curl) kullanılır, getirici değil."),
    "toplam": len(sonuc), "acik": len(acik),
    "kaynaklar": sonuc,
}
(KOK / "erisim.json").write_text(json.dumps(d, ensure_ascii=False, indent=1) + "\n",
                                 encoding="utf-8")
print(f"\n✓ erisim.json · {len(acik)}/{len(sonuc)} açık")
