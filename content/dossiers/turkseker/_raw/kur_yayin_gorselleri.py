#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Dosyanın kullandığı kareleri `web/dosya/turkseker/` altına eşitler.

NEDEN VAR. Bu kopyalama 23 Kasım'dan beri ELLE yapılıyordu ve 24 Kasım'da
galeri 79'dan 173 kareye çıkınca unutuldu: önizleme JSON'u 200 kare
gösteriyordu, yayın dizininde 106 dosya vardı. Eksik doksan dördü tarayıcı
sessizce boş kutu olarak çizdi — `Image.network`un hata kurucusu
`SizedBox.expand()`. Yani hata GÖRÜNMÜYORDU.

NE SİLİYOR: hiçbir şey. Yalnız eksikleri kopyalıyor, fazlaları SAYIYOR.
Bir kare dosyadan çıkarıldığında eski dosyası yayın dizininde kalıyor;
onu silmek yayındaki bir adresi kırabilir (paylaşılmış bağlantı, önbellek)
ve bu kararı betik kendi başına veremez.
"""
import json
import pathlib
import shutil
import sys

from PIL import Image

RAW = pathlib.Path(__file__).parent
KOK = RAW.parent
DEPO = KOK.parent.parent.parent          # …/tarim_app
KAYNAK = RAW / "gorseller"
HEDEF = DEPO / "web" / "dosya" / "turkseker"
KUCUK = HEDEF / "k"

# Izgara gözü en geniş hâlinde ~250 px; iki kat yoğunluklu ekranda 500.
KUCUK_EN = 560


def adlar():
    """Dosyanın gerçekten gösterdiği her karenin dosya adı.

    İkinci küme ızgara boyu kopyası gerekenler: yalnız galeri kareleri.
    Bölüm görseli sayfada tam genişlikte tek başına duruyor, küçüğü yok.
    """
    Y = json.loads((KOK / "yayin.json").read_text(encoding="utf-8"))
    G = json.loads((RAW / "galeri.json").read_text(encoding="utf-8"))
    a, k = set(), set()
    for b, v in Y["bolum_gorselleri"].items():
        if not b.startswith("_"):
            a.add(v["url"].rsplit("/", 1)[-1])
    for kare in G["kareler"]:
        a.add(kare["url"].rsplit("/", 1)[-1])
        if kare.get("kucuk"):
            k.add(kare["kucuk"].rsplit("/", 1)[-1])
    return a, k


def main():
    HEDEF.mkdir(parents=True, exist_ok=True)
    KUCUK.mkdir(parents=True, exist_ok=True)
    gerekli, kucukler = adlar()
    if len(gerekli) < 50:
        raise SystemExit("✗ denetçi kör: yalnız %d kare okundu" % len(gerekli))

    kopyalanan, eksik = 0, []
    for ad in sorted(gerekli):
        k, h = KAYNAK / ad, HEDEF / ad
        if not k.exists():
            eksik.append(ad)
            continue
        # Boyut karşılaştırması yeterli: kareler küçültüldükten sonra
        # yeniden yazılmıyor, aynı ad aynı dosya demek.
        if not h.exists() or h.stat().st_size != k.stat().st_size:
            shutil.copy2(k, h)
            kopyalanan += 1

    if eksik:
        raise SystemExit("✗ _raw/gorseller altında yok: " + ", ".join(eksik[:6]))

    # ── ızgara boyu kopyalar ────────────────────────────────────────────
    uretilen = 0
    for ad in sorted(kucukler):
        k, h = KAYNAK / ad, KUCUK / ad
        if not k.exists():
            raise SystemExit("✗ küçüğü üretilemeyen kare: %s" % ad)
        if h.exists() and h.stat().st_mtime >= k.stat().st_mtime:
            continue
        with Image.open(k) as im:
            im.load()
            im = im.convert("RGB")
            if im.width > KUCUK_EN:
                im.thumbnail((KUCUK_EN, KUCUK_EN * 10))
            im.save(h, "JPEG", quality=82, optimize=True)
        uretilen += 1

    fazla = sorted(p.name for p in HEDEF.iterdir()
                   if p.is_file() and p.name not in gerekli)
    boyut = sum(p.stat().st_size for p in HEDEF.iterdir() if p.is_file())
    kboyut = sum(p.stat().st_size for p in KUCUK.iterdir() if p.is_file())
    print("  ✓ %d kare yayın dizininde · %d kopyalandı · %.1f MB"
          % (len(gerekli), kopyalanan, boyut / 1e6))
    print("  ✓ %d ızgara kopyası · %d üretildi · %.1f MB"
          % (len(kucukler), uretilen, kboyut / 1e6))
    fazla_k = sorted(p.name for p in KUCUK.iterdir()
                     if p.is_file() and p.name not in kucukler)
    if fazla or fazla_k:
        # SİLME SEÇMELİ. Varsayılan sayar, silmez: yayındaki bir adresi
        # kırma kararını betik kendi başına veremez. `--temizle` ile
        # silmek güvenli, çünkü asılları _raw/gorseller/ altında duruyor
        # ve bu betik hepsini yeniden üretiyor.
        if "--temizle" in sys.argv:
            n = 0
            for ad in fazla:
                (HEDEF / ad).unlink(); n += 1
            for ad in fazla_k:
                (KUCUK / ad).unlink(); n += 1
            print("  ✓ artık kullanılmayan %d dosya silindi" % n)
        else:
            print("  · artık kullanılmayan %d kare + %d küçük duruyor "
                  "(silinmedi; --temizle ile silinir)" % (len(fazla), len(fazla_k)))


main()
