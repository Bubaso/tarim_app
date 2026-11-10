#!/usr/bin/env python3
"""Commons'tan görsel indirir; atıf ve lisansı API'den alır, ELLE YAZILMAZ.

Atıfsız görsel yayımlanmaz (§2.4). Lisansı serbest olmayan ya da atıf alanı
boş dönen dosya İNDİRİLMEZ — indirip sonra 'atıf bulamadım' demek, dosyaya
atıfsız bir kare sokmanın en kolay yolu.
"""
import json, pathlib, re, sys, time, urllib.parse, urllib.request

UA = "tarimportali-dosya/1.0 (https://tarimportali.net) python-urllib"
API = "https://commons.wikimedia.org/w/api.php"
KOK = pathlib.Path(__file__).parent / "gorseller"
KOK.mkdir(exist_ok=True)
SERBEST = re.compile(r"CC[ -]|public domain|CC0|no restrictions|GODL", re.I)


def meta(ad):
    time.sleep(1.5)
    url = API + "?" + urllib.parse.urlencode({
        "action": "query", "format": "json", "titles": "File:" + ad,
        "prop": "imageinfo", "iiprop": "url|size|extmetadata",
        "iiurlwidth": 2400,
        "iiextmetadatafilter": "Artist|LicenseShortName|LicenseUrl|ImageDescription|DateTimeOriginal"})
    with urllib.request.urlopen(urllib.request.Request(url, headers={"User-Agent": UA}), timeout=40) as r:
        d = json.loads(r.read().decode())
    s = next(iter(d["query"]["pages"].values()))
    ii = (s.get("imageinfo") or [{}])[0]
    md = ii.get("extmetadata", {}) or {}
    g = lambda k: re.sub(r"<[^>]+>", "", (md.get(k) or {}).get("value", "")).strip()
    return {"ad": ad, "url": ii.get("thumburl") or ii.get("url"), "ham_url": ii.get("url"), "g": ii.get("width"), "y": ii.get("height"),
            "atif": g("Artist"), "lisans": g("LicenseShortName"),
            "lisans_adresi": g("LicenseUrl") or None, "aciklama": g("ImageDescription"),
            "tarih": g("DateTimeOriginal"),
            "sayfa": "https://commons.wikimedia.org/wiki/File:" + urllib.parse.quote(ad.replace(" ", "_"))}


def indir(ad, yerel):
    m = meta(ad)
    if not m["atif"]:
        print(f"  ATIF YOK, İNDİRİLMEDİ · {ad}"); return None
    if not SERBEST.search(m["lisans"] or ""):
        print(f"  LİSANS SERBEST DEĞİL ({m['lisans']}), İNDİRİLMEDİ · {ad}"); return None
    hedef = KOK / yerel
    if hedef.exists():                      # yeniden çalıştırılabilir
        ham = hedef.read_bytes()
    else:
        time.sleep(20)          # dosya sunucusuna nazik aralık
        req = urllib.request.Request(m["url"], headers={"User-Agent": UA})
        ham = None
        for deneme in range(5):             # Commons 429 veriyor, geri çekil
            try:
                with urllib.request.urlopen(req, timeout=120) as r:
                    ham = r.read()
                break
            except urllib.error.HTTPError as e:
                if e.code != 429 or deneme == 4:
                    print(f"  İNDİRİLEMEDİ ({e.code}) · {ad}")
                    return None
                time.sleep(30 * (deneme + 1))
        if ham is None:
            return None
    hedef.write_bytes(ham)
    m["dosya"] = yerel
    m["bayt"] = len(ham)
    m["en_boy"] = round(m["g"] / m["y"], 4) if m["g"] and m["y"] else None
    print(f"  ✓ {yerel:38s} {m['g']}x{m['y']} {m['lisans'][:14]:14s} {m['atif'][:34]}")
    return m


if __name__ == "__main__":
    istek = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))
    kunye = {}
    for yerel, ad in istek.items():
        m = indir(ad, yerel)
        if m:
            kunye[yerel.rsplit(".", 1)[0]] = m
    out = KOK / "kunye_ham.json"
    out.write_text(json.dumps(kunye, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"\n{len(kunye)}/{len(istek)} indirildi → {out}")
