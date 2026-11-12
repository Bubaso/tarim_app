#!/usr/bin/env python3
"""Sergi veri katmanını sınar. Hattı her koşturduktan sonra çalıştırılır.

Sınanan şey "JSON geçerli mi" değil; YAYINA ÇIKACAK ŞEYİN DOĞRU OLDUĞU:
künyesiz kare var mı, iki kare aynı dosyayı mı gösteriyor, dosya diskte
gerçekten duruyor mu, göçteki satır sayısı veriyle tutuyor mu.
"""
from __future__ import annotations

import json
import pathlib
import re
import sys

KOK = pathlib.Path(__file__).resolve().parent
DEPO = KOK.parent.parent
GOC = DEPO / "supabase/migrations/20261112190000_sergi.sql"
GORSEL = DEPO / "web/sergi/utoify-16"


def main() -> int:
    hata: list[str] = []
    v = json.loads((KOK / "veri.json").read_text(encoding="utf-8"))
    e = v["eserler"]

    # 1 — sayı
    if len(e) != 114:
        hata.append("114 eser bekleniyordu, %d var" % len(e))
    if sum(1 for x in e if x["tur"] == "odul") != 14:
        hata.append("14 ödül bekleniyordu")

    # 2 — KÜNYE. Bu sınamanın sebebi tek: künyesiz kare yayına çıkmasın.
    for x in e:
        for alan in ("fotografci", "eser", "ulke_tr", "ulke_en", "adres"):
            if not str(x.get(alan, "")).strip():
                hata.append("%s: %s boş" % (x["kod"], alan))

    # 3 — benzersizlik. İki kaydın aynı dosyayı göstermesi, bir fotoğrafın
    #     iki kişiye birden yazılması demek.
    for alan in ("kod", "dosya", "adres"):
        gorulen: dict[str, str] = {}
        for x in e:
            d = x[alan]
            if d in gorulen:
                hata.append("%s yinelendi: %s ve %s" % (alan, gorulen[d], x["kod"]))
            gorulen[d] = x["kod"]

    # 4 — dosya diskte var mı, adres dosyayla tutuyor mu
    for x in e:
        if not (GORSEL / x["dosya"]).exists():
            hata.append("%s: dosya yok → %s" % (x["kod"], x["dosya"]))
        if not x["adres"].endswith("/" + x["dosya"]):
            hata.append("%s: adres dosyayla tutmuyor" % x["kod"])

    diskte = {p.name for p in GORSEL.glob("*.jpg")}
    fazla = diskte - {x["dosya"] for x in e}
    if fazla:
        hata.append("veride karşılığı olmayan dosya: %s" % sorted(fazla)[:5])

    # 5 — ÇÖZÜNÜRLÜK TAVANI. Kaynak 613 pikseli aşmıyor; veride daha büyük bir
    #     değer varsa bir yerde büyütme yapılmış demektir.
    for x in e:
        if (x.get("en") or 0) > 700:
            hata.append("%s: kaynak tavanının üstünde (%s px)" % (x["kod"], x["en"]))

    # 6 — göç veriyle tutuyor mu
    if GOC.exists():
        sql = GOC.read_text(encoding="utf-8")
        n = len(re.findall(r"^\('(?:odul|sergi)-\d+'", sql, re.M))
        if n != len(e):
            hata.append("göçte %d satır, veride %d eser" % (n, len(e)))
        for x in e[:3] + e[-3:]:
            if x["fotografci"].replace("'", "''") not in sql:
                hata.append("%s göçte yok: %s" % (x["kod"], x["fotografci"]))
    else:
        hata.append("göç dosyası yok: %s" % GOC.name)

    # 7 — iki dillilik
    for x in e:
        if not x["odul_tr"] or not x["odul_en"]:
            hata.append("%s: ödül adı tek dilli" % x["kod"])

    for h in hata:
        print("  ✗ " + h)
    if hata:
        print("%d SORUN" % len(hata))
        return 1
    iller = {x["il"] for x in e if x["il"]}
    ulkeler = {x["ulke_tr"] for x in e}
    print("✓ %d eser · %d ödül · %d il · %d ülke · %d kare diskte"
          % (len(e), sum(1 for x in e if x["tur"] == "odul"),
             len(iller), len(ulkeler), len(diskte)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
