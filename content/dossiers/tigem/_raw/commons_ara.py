#!/usr/bin/env python3
"""Wikimedia Commons'ta görsel arar. Atıf ve lisans API'den gelir, elle yazılmaz."""
import json, sys, time, urllib.parse, urllib.request

UA = "tarimportali-dosya/1.0 (research; contact via site)"
API = "https://commons.wikimedia.org/w/api.php"


def cagir(params):
    time.sleep(2.5)   # Commons 429 veriyor; arama hızı sınırlı
    url = API + "?" + urllib.parse.urlencode(params)
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=40) as r:
        return json.loads(r.read().decode())


def ara(terim, n=12):
    d = cagir({"action": "query", "format": "json", "generator": "search",
               "gsrsearch": f"filetype:bitmap {terim}", "gsrnamespace": 6, "gsrlimit": n,
               "prop": "imageinfo", "iiprop": "url|size|extmetadata",
               "iiextmetadatafilter": "Artist|LicenseShortName|License|LicenseUrl|ImageDescription",
               "iiurlwidth": 200})
    out = []
    for s in (d.get("query", {}).get("pages") or {}).values():
        ii = (s.get("imageinfo") or [{}])[0]
        md = ii.get("extmetadata", {}) or {}
        def g(k):
            v = (md.get(k) or {}).get("value", "")
            import re
            return re.sub(r"<[^>]+>", "", v).strip()
        out.append({
            "ad": s["title"].removeprefix("File:"),
            "g": ii.get("width"), "y": ii.get("height"),
            "bayt": ii.get("size"),
            "atif": g("Artist")[:70],
            "lisans": g("LicenseShortName"),
            "url": ii.get("url"),
            "aciklama": g("ImageDescription")[:110],
        })
    return out


if __name__ == "__main__":
    for terim in sys.argv[1:]:
        print(f"\n══════ {terim}")
        try:
            for r in ara(terim):
                boyut = f"{r['g']}x{r['y']}" if r['g'] else "?"
                print(f"  {r['ad'][:62]:62s} {boyut:>11s} {r['lisans'][:16]:16s} {r['atif'][:28]}")
        except Exception as e:
            print("  HATA", e)
