#!/usr/bin/env python3
"""
Yapay Zeka ve Dijital Tarım — kaynak adreslerinin canlılık denetimi.

    python3 kaynak_canlilik.py            # bütün kayıtların adreslerini dener, rapor yazar
    python3 kaynak_canlilik.py --ozet     # son raporu özetler (ağa çıkmaz)

Açılıştan önce ve her dağıtımdan önce koşar (README "Açılış adımları").
§30 Kaynakça okura bu adresleri veriyor; ölü ya da başka sayfaya yönlenen
adres okuru boşa gönderir.

Her kaydın (`bNN_kaynaklar.json`, üretilmiş b30 hariç) her kaynağının
`adres`i — yoksa DOI'si (https://doi.org/…) — GET ile denenir: durum kodu,
son adres, içerik türü, gövde boyu. İstekler sırayla, aynı sunucuya en çok
saniyede bir. Yalnız GET; form, oturum, çerez yok; bot korumasına takılan
adres "engelli" yazılır ve elle bakılır, aşılmaz. İstek kimliği genel bir
tarayıcı kimliği: kullanıcının ya da projenin adı gitmez.

SINIFLAR
  acik      2xx, gövde 1.000 bayttan büyük
  yonlendi  2xx ama derin bir adres sitenin ana sayfasına ya da genel bir
            sayfaya düşmüş (ör. kaldırılan basın bülteni → içerik kütüphanesi)
  engelli   401 / 403 / 429 — erişim engeli; içerik ölü olmayabilir. Betiğin
            TLS ya da bağlantı sıfırlama yüzünden kuramadığı bağlantı da
            burada (sunucu ayakta, betiği geri çeviriyor): tarayıcıyla bakılır
  kisa      2xx ama gövde 1.000 bayttan küçük — betikle yönlendiren sayfa
            olabilir; elle bakılır
  kapali    öbür 4xx / 5xx, zaman aşımı ya da alan adı çözülmüyor
Kaynağın kendi kopyası `kaynak_dosyalari/`da (sha256 ile kayıtlı) durur;
bu denetim yalnız okura verilen adresi sınar (karar 24: kaynak düşerse eski
değer tutulur, tarihi gösterilir).

Rapor: `_raw/kaynak_canlilik.json`.
"""
from __future__ import annotations

import json
import re
import sys
import time
import urllib.error
import urllib.request
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import urlparse

BURASI = Path(__file__).resolve().parent
RAPOR = BURASI / "kaynak_canlilik.json"
UA = ("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 "
      "(KHTML, like Gecko) Chrome/120 Safari/537.36")
ZAMAN_ASIMI = 25
EN_AZ_GOVDE = 1000
GENEL_YOLLAR = ("content-library", "not-found", "notfound", "404", "hata", "error")


def adresler() -> dict[str, list[str]]:
    """{adres: [kayıt · kaynak, …]} — aynı adres bir kez denenir."""
    cikti: dict[str, list[str]] = {}
    for yol in sorted(BURASI.glob("b[0-9][0-9]_kaynaklar.json")):
        if yol.name == "b30_kaynaklar.json":
            continue
        kayit = json.loads(yol.read_text(encoding="utf-8"))
        for anahtar, k in kayit.get("kaynaklar", {}).items():
            adres = k.get("adres")
            # Adres alanı bazen bir not taşıyor: "https://… (yönlendirme: …)".
            # Okura giden bağlantı, kaynakçadaki gibi, ilk adres parçası.
            m = re.search(r"https?://[^\s<>\"]+", adres) if isinstance(adres, str) else None
            adres = m.group(0).rstrip(".,;:)") if m else None
            if not adres and k.get("doi"):
                adres = f"https://doi.org/{k['doi']}"
            if adres:
                cikti.setdefault(adres, []).append(f"{yol.name[:3]} · {anahtar}")
    return cikti


def _derinlik(yol: str) -> int:
    return len([p for p in yol.split("/") if p])


ENGEL_HATALARI = ("SSL", "TLS", "Connection reset", "reset by peer", "EOF occurred")


def siniflandir(adres: str, kod: int | None, son: str | None, boy: int, hata: str = "") -> str:
    if kod is None:
        return "engelli" if any(h in hata for h in ENGEL_HATALARI) else "kapali"
    if kod in (401, 403, 429):
        return "engelli"
    if kod >= 400:
        return "kapali"
    if boy < EN_AZ_GOVDE:
        return "kisa"
    if son and not adres.startswith("https://doi.org/"):
        ilk, sonra = urlparse(adres), urlparse(son)
        genel = any(g in sonra.path.lower() for g in GENEL_YOLLAR)
        anasayfa = _derinlik(ilk.path) >= 2 and _derinlik(sonra.path) <= 1
        if genel or anasayfa:
            return "yonlendi"
    return "acik"


def dene(adres: str) -> dict:
    istek = urllib.request.Request(adres, headers={"User-Agent": UA, "Accept": "*/*"})
    try:
        with urllib.request.urlopen(istek, timeout=ZAMAN_ASIMI) as y:
            govde = y.read(2_000_000)
            return {"kod": y.status, "son_adres": y.geturl(),
                    "tur": y.headers.get("Content-Type", ""), "boy": len(govde)}
    except urllib.error.HTTPError as e:
        return {"kod": e.code, "son_adres": e.geturl(), "tur": e.headers.get("Content-Type", "") if e.headers else "", "boy": 0}
    except Exception as e:  # zaman aşımı, DNS, TLS…
        return {"kod": None, "son_adres": None, "tur": "", "boy": 0, "hata": str(e)[:160]}


def kos() -> dict:
    hedefler = adresler()
    son_istek: dict[str, float] = {}
    sonuc = []
    for i, (adres, kullanan) in enumerate(sorted(hedefler.items()), 1):
        sunucu = urlparse(adres).hostname or ""
        bekle = 1.0 - (time.monotonic() - son_istek.get(sunucu, 0))
        if bekle > 0:
            time.sleep(bekle)
        r = dene(adres)
        son_istek[sunucu] = time.monotonic()
        r.update({"adres": adres, "kullanan": kullanan,
                  "sinif": siniflandir(adres, r["kod"], r.get("son_adres"), r["boy"], r.get("hata", ""))})
        sonuc.append(r)
        if r["sinif"] != "acik":
            print(f"  {r['sinif']:8} {r['kod']} {adres[:110]}")
        if i % 25 == 0:
            print(f"  · {i}/{len(hedefler)}")
    rapor = {"_ne": "Kaynak adreslerinin canlılık denetimi (kaynak_canlilik.py)",
             "tarih": datetime.now(timezone.utc).isoformat(timespec="seconds"),
             "sayac": {s: sum(1 for r in sonuc if r["sinif"] == s)
                       for s in ("acik", "yonlendi", "kisa", "engelli", "kapali")},
             "adresler": sonuc}
    RAPOR.write_text(json.dumps(rapor, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    return rapor


def ozet(rapor: dict) -> None:
    print(f"{rapor['tarih']} · " + " · ".join(f"{k} {v}" for k, v in rapor["sayac"].items()))
    for r in rapor["adresler"]:
        if r["sinif"] != "acik":
            print(f"  {r['sinif']:8} {r['kod']} {r['adres'][:100]}  ← {', '.join(r['kullanan'][:3])}")


if __name__ == "__main__":
    if "--ozet" in sys.argv:
        ozet(json.loads(RAPOR.read_text(encoding="utf-8")))
    else:
        ozet(kos())
