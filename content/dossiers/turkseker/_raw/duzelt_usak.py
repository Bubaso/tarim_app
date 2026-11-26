#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Uşak hatasını iki dilde düzeltir. 26 Kasım 2026.

NE OLDU. Dosya yayına girdikten sonra, video metninin kapanış cümlesinin
dayanağı aranırken iki maddi hata çıktı. İkisi de aynı yanlış okumadan
doğuyor: 2025/26 kota çizelgesi ŞİRKETLERİ sayıyor, fabrikaları değil.
Çizelgede "KAMU TÜRKŞEKER (14 Fabrika)" tek satır — Uşak adı o yüzden
listede görünmüyor. Buradan "Uşak'ta fabrika yok" sonucu çıkarılmış.

  §2  "Bugün Uşak'ta pancar şekeri üreten bir fabrika bulunmuyor."
  §19 "İki fabrika da artık TÜRKŞEKER'e ait değil."

KAYNAK NE DİYOR. `_raw/kaynak_dosyalari/turkseker_haberler.json`, 22 Eylül
2026 törenleri haberi:

  "Türkiye Şeker Fabrikaları A.Ş.'ye (TÜRKŞEKER) bağlı Uşak, Elazığ ve Ağrı
   Şeker Fabrikalarında 2026/2027 pancar alımı ve işleme kampanyası 22
   Eylül'de yapılan törenlerle başladı."
  "…temeli atılan Nuri Şeker Uşak Şeker Fabrikası, Cumhuriyet'in ilk sanayi
   hamlelerinden biri olarak 101. kampanyasına başladı."

Yani Uşak kurumun on dört fabrikasından biri ve üretimde. Alpullu için
"artık TÜRKŞEKER'e ait değil" DOĞRU — 2018'de satıldı, bugün Binbirgıda'nın
(§17 · `_raw/kota.json` %0,94). Hata Uşak'ı Alpullu'yla aynı kefeye koymak.
Ayrıca genel müdürün 12 Kasım 2026 sözü yalnız "bu iki fabrikada 101'inci
kampanya yürütülüyor" diyor; mülkiyete dair bir cümle kaynakta YOK.

SAYIM KORUMALI. Her değişimin tam olarak bir karşılığı olmalı. Sıfır eşleşme
metnin zaten değiştiğini, birden çoğu yanlış yere yazacağımı gösterir;
ikisinde de betik düşüyor ve hiçbir dosyaya dokunmuyor.

    python3 _raw/duzelt_usak.py
"""
import pathlib
import sys

KOK = pathlib.Path(__file__).resolve().parent.parent

DEGISIMLER = [
    # ── §2 "İki şirket, iki temel" · Türkçe ──────────────────────────────
    ("metin_tr.md",
     """Bugün Uşak'ta pancar şekeri üreten bir fabrika bulunmuyor. 2025/26 pazarlama
yılında kota tahsis edilen 15 üreticinin listesinde Uşak yok. Buna karşılık
kurumun gayrimenkul kayıtlarında Uşak hâlâ duruyor.""",
     """Uşak'ta kurulan fabrika hâlâ çalışıyor ve kurucusunun adını taşıyor: Nuri
Şeker Uşak Şeker Fabrikası. TÜRKŞEKER'in on dört fabrikasından biri; 2026/27
kampanyası 22 Eylül 2026'da, fabrikanın **101**'inci kampanyası olarak
açıldı."""),

    # ── §2 "Two companies, two foundations" · İngilizce ──────────────────
    ("metin_en.md",
     """There is no beet sugar factory at Uşak today. Uşak does not appear among the
15 producers allocated quota for the 2025/26 marketing year. The
institution's property records, however, still list Uşak.""",
     """The factory built at Uşak is still running, and it carries its founder's
name: Nuri Şeker Uşak Sugar Factory. It is one of TÜRKŞEKER's fourteen
factories; the 2026/27 campaign opened on 22 September 2026 as the
factory's **101st**."""),

    # ── §19 "Bir rölyef, bir türbin" · Türkçe ───────────────────────────
    ("metin_tr.md",
     """fabrikada — **101**'inci kampanya yürütülüyor. İki fabrika da artık
TÜRKŞEKER'e ait değil; ama bacaları tütüyor ve sayaç işliyor.""",
     """fabrikada — **101**'inci kampanya yürütülüyor. Uşak hâlâ TÜRKŞEKER'in;
Alpullu 2018'de satıldı ve üretimi başka bir şirket sürdürüyor. İkisinin de
bacası tütüyor ve sayaç işliyor."""),

    # ── §19 "A relief, a turbine" · İngilizce ───────────────────────────
    ("metin_en.md",
     """Alpullu — the first two factories — the **101st** campaign is under way.
Neither belongs to TÜRKŞEKER any longer; but their chimneys are smoking and
the counter is running.""",
     """Alpullu — the first two factories — the **101st** campaign is under way.
Uşak still belongs to TÜRKŞEKER; Alpullu was sold in 2018 and another
company runs production there now. Both chimneys are smoking and the
counter is running."""),
]


def main():
    # ÖNCE HEPSİNİ SINA, SONRA HİÇBİRİNİ YA DA HEPSİNİ YAZ. Yarım
    # uygulanmış bir düzeltme iki dili ayrıştırır ve seed_dossier bölüm
    # sayısını tutturduğu için bunu yakalamaz.
    metinler = {}
    for ad, eski, _ in DEGISIMLER:
        if ad not in metinler:
            metinler[ad] = (KOK / ad).read_text(encoding="utf-8")
        n = metinler[ad].count(eski)
        if n != 1:
            print("✗ %s · %d eşleşme (1 bekleniyordu)" % (ad, n))
            print("  aranan:\n    " + eski.replace("\n", "\n    ")[:300])
            return 1

    for ad, eski, yeni in DEGISIMLER:
        metinler[ad] = metinler[ad].replace(eski, yeni, 1)

    for ad, icerik in metinler.items():
        (KOK / ad).write_text(icerik, encoding="utf-8")
        print("· %s yazıldı" % ad)

    # SON SINAMA. Hatalı ifadeler iki dilde de gitmiş olmalı.
    kalinti = []
    for ad, parcalar in (
        ("metin_tr.md", ["pancar şekeri üreten bir fabrika bulunmuyor",
                         "İki fabrika da artık"]),
        ("metin_en.md", ["no beet sugar factory at Uşak",
                         "Neither belongs to TÜRKŞEKER"]),
    ):
        t = (KOK / ad).read_text(encoding="utf-8")
        for p in parcalar:
            if p in t:
                kalinti.append("%s · %s" % (ad, p))
    if kalinti:
        print("\n✗ kalıntı: " + " | ".join(kalinti))
        return 1

    print("\n✓ dört paragraf düzeltildi, hatalı ifade kalmadı")
    print("  sıradaki: ./yenile.sh  →  node content/dossiers/seed_dossier.mjs turkseker")
    return 0


sys.exit(main())
