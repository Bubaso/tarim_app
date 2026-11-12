#!/usr/bin/env python3
"""veri.json → web/onizleme/sergi-<kod>.json

Dosya önizlemesiyle aynı mantık: üretilen JSON, veritabanının DÖNDÜRECEĞİ
satırların aynısı. Böylece önizlemede görülen şeyle yayında görülecek şey
arasında bir çeviri katmanı kalmıyor — iki ayrı biçim olsaydı önizleme
"çalışıyor" görünüp yayın bozulabilirdi.
"""
from __future__ import annotations

import json
import pathlib
import sys

KOK = pathlib.Path(__file__).resolve().parent
DEPO = KOK.parent.parent


def main() -> int:
    v = json.loads((KOK / "veri.json").read_text(encoding="utf-8"))
    y = v["yarisma"]
    cikti = {
        "_ne": "Sergi önizlemesi. YALNIZCA yerelde kullanılır: "
               "flutter run --dart-define=SERGI_ONIZLEME=%s" % y["kod"],
        "yarisma": {
            "kod": y["kod"], "sira": y["sira"], "yil": y["yil"],
            "ad_tr": y["ad_tr"], "ad_en": y["ad_en"], "kisa": y["kisa"],
            "tema_tr": y["tema_tr"], "tema_en": y["tema_en"],
            "duzenleyen_tr": y["duzenleyen_tr"],
            "duzenleyen_en": y["duzenleyen_en"],
            "destekci": y["destekci"],
            "kaynak_adres": y["kaynak_adres"],
            "odul_listesi": y["odul_listesi"],
            "sergileme_listesi": y["sergileme_listesi"],
        },
        "eserler": [
            {
                "kod": e["kod"], "yarisma_kod": y["kod"], "tur": e["tur"],
                "kategori": e["kategori"], "sira": e["sira"],
                "odul_tr": e["odul_tr"], "odul_en": e["odul_en"],
                "fotografci": e["fotografci"], "eser": e["eser"],
                "il": e["il"], "ulke_tr": e["ulke_tr"], "ulke_en": e["ulke_en"],
                "adres": e["adres"], "en": e["en"], "boy": e["boy"],
                "en_boy": e["en_boy"],
            }
            for e in v["eserler"]
        ],
    }
    hedef = DEPO / ("web/onizleme/sergi-%s.json" % y["kod"])
    hedef.parent.mkdir(parents=True, exist_ok=True)
    hedef.write_text(json.dumps(cikti, ensure_ascii=False), encoding="utf-8")
    print("✓ %d kare → %s (%.0f KB)"
          % (len(cikti["eserler"]), hedef.relative_to(DEPO),
             hedef.stat().st_size / 1024))
    return 0


if __name__ == "__main__":
    sys.exit(main())
