#!/usr/bin/env python3
"""NASA görsel kütüphanesi → gorseller.json — konu konu ölçülmüş envanter.

NEDEN COMMONS DEĞİL: NASA'nın kendi medyası ABD hükümeti eseri, yani kamu
malı; künye alanları (title, date_created, center, nasa_id) zaten AYRI
duruyor, düzyazıdan kazınmıyor. Commons'ta yaşanan 429 kısıtlaması da
burada ölçülmedi.

SORGU TUZAĞI — ÖLÇÜLDÜ. API terimleri VE'liyor; uzun betimleyici sorgu
sonuç kümesini çökertiyor. Aynı arşivde:
    "Arabidopsis seedling spaceflight experiment"  →   1 sonuç
    "Arabidopsis"                                  →  75 sonuç
    "astronaut tending plants space station"       →   0 sonuç
    "astronaut plants harvest"                     → 558 sonuç
İlk ölçüm üç konuda SIFIR dönmüştü ve bu "görsel yok" diye kaydedilseydi
yanlış olurdu. Sorgular kısa ve özel terimlere çevrildi.

ALTYAZI KURALI AYNEN GEÇERLİ: altyazı KÜNYEDİR — konu + yer + tarih,
kaynağın kendi alanlarından. Karede ne görüldüğü anlatılmaz.

TELİF UYARISI — ÖLÇÜLMEDEN KULLANILMAZ: kütüphanede NASA dışı kaynaklı
kareler de var (ESA, Roscosmos, ticari ortaklar, fotoğrafçı telifi). Her
kaydın `center` ve `photographer`/`secondary_creator` alanları ayrı
tutuluyor; NASA dışı görünen kayıt KULLANILMADAN ÖNCE tek tek okunacak.
"""
from __future__ import annotations
import json, pathlib, urllib.parse, urllib.request, datetime, time, collections

KOK = pathlib.Path(__file__).parent
UA = {"User-Agent": "tarimportali.net arastirma"}
API = "https://images-api.nasa.gov/search"

KONULAR = {
    "veggie": "Veggie",
    "apdh": "Advanced Plant Habitat",
    "marul": "lettuce",
    "biber": "chile pepper",
    "turp": "radish",
    "arabidopsis": "Arabidopsis",
    "bugday": "dwarf wheat",
    "tohum": "seed germination",
    "regolit": "regolith simulant",
    "bitki_odasi": "plant growth chamber",
    "hasat": "astronaut plants harvest",
    "mikroyercekimi_bitki": "plant experiment microgravity",
}


def ara(q: str) -> list[dict]:
    u = f"{API}?{urllib.parse.urlencode({'q': q, 'media_type': 'image'})}"
    with urllib.request.urlopen(urllib.request.Request(u, headers=UA), timeout=60) as r:
        d = json.load(r)
    c = d.get("collection", {})
    out = []
    for it in c.get("items", [])[:25]:
        x = (it.get("data") or [{}])[0]
        out.append({
            "nasa_id": x.get("nasa_id"),
            "baslik": x.get("title"),
            "tarih": (x.get("date_created") or "")[:10],
            "merkez": x.get("center"),
            "fotografci": x.get("photographer") or x.get("secondary_creator"),
            "anahtar": (x.get("keywords") or [])[:6],
            "aciklama": (x.get("description") or "")[:300],
            "sayfa": it.get("href"),
        })
    return out, c.get("metadata", {}).get("total_hits", 0)


envanter, sayac = {}, {}
merkezler = collections.Counter()
nasa_disi = []
for ad, q in KONULAR.items():
    kayitlar, toplam = ara(q)
    envanter[ad] = {"sorgu": q, "toplam_sonuc": toplam,
                    "cekilen": len(kayitlar), "kayitlar": kayitlar}
    sayac[ad] = toplam
    for k in kayitlar:
        merkezler[k["merkez"] or "?"] += 1
        if k["fotografci"]:
            nasa_disi.append({"konu": ad, "nasa_id": k["nasa_id"],
                              "fotografci": k["fotografci"]})
    print(f"  {ad:16s} {toplam:5d} sonuç · {len(kayitlar)} kayıt alındı")
    time.sleep(1.2)

d = {
    "_kaynak": "NASA Image and Video Library · images-api.nasa.gov",
    "_nitelik": "BAĞIMSIZ — NASA'nın kendi medya kütüphanesi",
    "_telif": ("NASA medyası genel olarak kamu malıdır AMA kütüphanede NASA "
               "dışı kaynaklı kareler de bulunur. `fotografci` alanı dolu "
               "olan kayıtlar KULLANILMADAN ÖNCE tek tek okunacak."),
    "_altyazi_kurali": ("Altyazı KÜNYEDİR: konu + yer + tarih, kaynağın "
                        "`baslik`, `tarih`, `merkez` alanlarından. Karede ne "
                        "görüldüğü ANLATILMAZ."),
    "_cekim": datetime.date.today().isoformat(),
    "konu_sayilari": sayac,
    "merkez_dagilimi": dict(merkezler.most_common()),
    "fotografci_alani_dolu": nasa_disi,
    "konular": envanter,
}
(KOK / "gorseller.json").write_text(json.dumps(d, ensure_ascii=False, indent=1) + "\n",
                                    encoding="utf-8")
print(f"\n✓ gorseller.json · {len(KONULAR)} konu · toplam {sum(sayac.values())} sonuç")
print(f"  merkezler: {dict(merkezler.most_common(6))}")
print(f"  fotoğrafçı alanı dolu (telifi okunacak): {len(nasa_disi)} kayıt")
