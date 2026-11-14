#!/usr/bin/env python3
"""Türkiye görsellerinin lisans durumunu YOKLAR → turkiye_gorsel.json

NEDEN AYRI BETİK: NASA kütüphanesindeki kareler kamu malı ve künyesi
yapılandırılmış. Türkiye tarafı öyle değil — Ax-3 kareleri Axiom Space'in
(ticari), üniversite kareleri kurumların, basın kareleri ajansların.
Her biri AYRI telif ve "basında yayımlandı" açık lisans demek değildir.

Bu betik üç havuzu yokluyor:
  1. NASA görsel kütüphanesi — Ax-3 NASA'nın da ilgilendiği bir görev
  2. Wikimedia Commons — açık lisanslı tek havuz
  3. (elle) kurum siteleri — betik DEĞİL, insan okur

Ölçüm: kaç kare var, lisansı ne, atfı var mı.
"""
from __future__ import annotations
import json, pathlib, urllib.parse, urllib.request, datetime, time

KOK = pathlib.Path(__file__).parent
UA = {"User-Agent": "tarimportali.net arastirma"}

NASA_API = "https://images-api.nasa.gov/search"
COMMONS = "https://commons.wikimedia.org/w/api.php"
KABUL = ("cc0", "public domain", "cc by", "cc-by", "pd-")


def nasa(q: str):
    u = f"{NASA_API}?{urllib.parse.urlencode({'q': q, 'media_type': 'image'})}"
    with urllib.request.urlopen(urllib.request.Request(u, headers=UA), timeout=60) as r:
        d = json.load(r)
    c = d.get("collection", {})
    kayit = []
    for it in c.get("items", [])[:12]:
        x = (it.get("data") or [{}])[0]
        kayit.append({"nasa_id": x.get("nasa_id"), "baslik": x.get("title"),
                      "tarih": (x.get("date_created") or "")[:10],
                      "merkez": x.get("center"),
                      "fotografci": x.get("photographer") or x.get("secondary_creator")})
    return c.get("metadata", {}).get("total_hits", 0), kayit


def commons(q: str):
    u = COMMONS + "?" + urllib.parse.urlencode({
        "format": "json", "action": "query", "list": "search",
        "srsearch": f"{q} filetype:bitmap", "srnamespace": 6, "srlimit": 12})
    with urllib.request.urlopen(urllib.request.Request(u, headers=UA), timeout=60) as r:
        d = json.load(r)
    basliklar = [x["title"] for x in d.get("query", {}).get("search", [])]
    toplam = d.get("query", {}).get("searchinfo", {}).get("totalhits", 0)
    if not basliklar:
        return toplam, []
    time.sleep(1.5)
    u2 = COMMONS + "?" + urllib.parse.urlencode({
        "format": "json", "action": "query", "titles": "|".join(basliklar),
        "prop": "imageinfo", "iiprop": "url|size|extmetadata|mime"})
    with urllib.request.urlopen(urllib.request.Request(u2, headers=UA), timeout=60) as r:
        d2 = json.load(r)
    kayit = []
    for s in (d2.get("query", {}).get("pages") or {}).values():
        i = (s.get("imageinfo") or [{}])[0]
        m = i.get("extmetadata") or {}
        lis = (m.get("LicenseShortName", {}).get("value") or "").strip()
        atf = (m.get("Artist", {}).get("value") or "")
        atf = __import__("re").sub(r"<[^>]+>", "", atf).strip()
        kayit.append({"ad": s.get("title", "")[5:], "lisans": lis,
                      "atif": atf[:70] or None,
                      "kabul": any(k in lis.lower() for k in KABUL),
                      "boyut": f"{i.get('width')}×{i.get('height')}"})
    return toplam, kayit


KONULAR = {
    "gezeravci": "Alper Gezeravcı",
    "ax3": "Axiom Mission 3",
    "ax3_murettebat": "Ax-3 crew",
    "atasever": "Tuva Cihangir Atasever",
    "tua": "Turkish Space Agency",
    "schrenkiella": "Schrenkiella parvula",
    "tuz_golu": "Tuz Gölü salt lake Turkey",
}

sonuc = {}
for ad, q in KONULAR.items():
    n_t, n_k = nasa(q); time.sleep(1.2)
    c_t, c_k = commons(q); time.sleep(1.5)
    kabul = [k for k in c_k if k["kabul"]]
    sonuc[ad] = {"sorgu": q,
                 "nasa": {"toplam": n_t, "kayitlar": n_k},
                 "commons": {"toplam": c_t, "kayitlar": c_k,
                             "kabul_edilebilir": len(kabul)}}
    print(f"  {ad:16s} NASA {n_t:5d} · Commons {c_t:5d} (lisansı uygun {len(kabul)}/{len(c_k)})")

d = {
    "_ne": "Türkiye görsellerinin lisans yoklaması",
    "_neden": ("NASA kareleri kamu malı; Türkiye tarafı değil. Ax-3 kareleri "
               "Axiom Space'in (ticari), üniversite ve basın kareleri ayrı "
               "telif. 'Basında yayımlandı' açık lisans DEĞİLDİR."),
    "_kabul_listesi": list(KABUL),
    "_tarih": datetime.date.today().isoformat(),
    "_ELLE_OKUNACAK": ["axiomspace.com medya sayfaları — ticari, lisans okunmalı",
                       "ege.edu.tr ve TÜBİTAK basın görselleri — açık lisans beklenmiyor",
                       "tua.gov.tr görselleri — lisans belirtilmemiş"],
    "konular": sonuc,
}
(KOK / "turkiye_gorsel.json").write_text(json.dumps(d, ensure_ascii=False, indent=1) + "\n",
                                         encoding="utf-8")
print("\n✓ turkiye_gorsel.json")
