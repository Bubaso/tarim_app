#!/usr/bin/env python3
"""Canlı pencere ([[canli:kimlik]], "Uzaydan bugün") için sınama:
dogrula_bolumler.py kural 20 ve bütün ayrıştırıcılar.

    python3 -I content/yapay_zeka_dijital_tarim/_raw/dogrula_canli_test.py

Depodaki metin geçmeli; bozulmuş kopyalar (geçici klasörde) yakalanmalı.
Ayrıştırıcıların hiçbiri yönerge satırını metin saymamalı (arama, okuma
süresi, sözlük, teknoloji izi, atlas, basılı sürüm), blok sırası ise
yzAyristir ile aynı kalmalı. Depoya yazmaz.
"""
from __future__ import annotations

import importlib.util
import io
import shutil
import tempfile
import unittest
from contextlib import redirect_stdout
from pathlib import Path

BURASI = Path(__file__).resolve().parent
KOK = BURASI.parent


def _yukle(ad: str, dosya: Path):
    spec = importlib.util.spec_from_file_location(ad, dosya)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


D = _yukle("dogrula_bolumler_canli", BURASI / "dogrula_bolumler.py")
TEL = _yukle("telefon_bolme_canli", BURASI / "telefon_bolme.py")
ATLAS = _yukle("atlas_uret_canli", BURASI / "atlas_uret.py")
YAZDIR = _yukle("yazdir_uret_canli", BURASI / "yazdir_uret.py")
IZ = _yukle("teknoloji_izi_canli", BURASI / "teknoloji_izi.py")
SOZLUK = _yukle("sozluk_uret_canli", BURASI / "sozluk_uret.py")
GORSEL = _yukle("gorsel_isle_canli", BURASI / "gorsel_isle.py")
GRAFIK = _yukle("grafik_donustur_canli", BURASI / "grafik_donustur.py")
DART = _yukle("dart_uret_canli", KOK / "dart_uret.py")

YONERGE = "[[canli:uzaydan-bugun]]"
SAYFA_TR = next((KOK / "bolumler").glob("19-*.tr.md"))
SAYFA_EN = SAYFA_TR.with_name(SAYFA_TR.name.replace(".tr.md", ".en.md"))
ORNEK = "# 19 · Deneme\n\nBir uydu cümlesi.\n\n[[gorsel:b19-x]]\n\n" + YONERGE + "\n\n## Alt\n\nİki.\n"
YALIN = ORNEK.replace(YONERGE + "\n\n", "")


class Kopya:
    """bolumler/ ve teknolojiler/ geçici kopyası; doğrulayıcının yolları ona çevriliyor."""

    def __enter__(self):
        self.gecici = tempfile.TemporaryDirectory()
        k = Path(self.gecici.name)
        shutil.copytree(KOK / "bolumler", k / "bolumler")
        shutil.copytree(KOK / "teknolojiler", k / "teknolojiler")
        self.eski = (D.BOLUMLER, D.TEKNOLOJILER)
        D.BOLUMLER, D.TEKNOLOJILER = k / "bolumler", k / "teknolojiler"
        self.tr = k / "bolumler" / SAYFA_TR.name
        self.en = k / "bolumler" / SAYFA_EN.name
        self.kok = k
        return self

    def __exit__(self, *a):
        D.BOLUMLER, D.TEKNOLOJILER = self.eski
        self.gecici.cleanup()

    def degistir(self, yol: Path, eski: str, yeni: str) -> None:
        t = yol.read_text(encoding="utf-8")
        assert eski in t, eski[:60]
        yol.write_text(t.replace(eski, yeni, 1), encoding="utf-8")


def hatalar(islev) -> list[str]:
    D.hatalar.clear()
    with redirect_stdout(io.StringIO()):
        islev()
    return list(D.hatalar)


class Kural20(unittest.TestCase):
    def test_depo_geciyor(self):
        self.assertEqual(hatalar(D.sina_canli_pencereler), [])
        # Kural 16'nın "tanınmayan yönerge" denetimi canli'yi tanıyor.
        self.assertFalse([h for h in hatalar(D.sina_cekmeler) if "canli" in h])

    def test_yalniz_bir_dilde(self):
        with Kopya() as k:
            k.degistir(k.en, YONERGE + "\n\n", "")
            h = hatalar(D.sina_canli_pencereler)
            self.assertTrue(any("iki dilde aynı yerde değil" in x for x in h), h)

    def test_farkli_yerde(self):
        with Kopya() as k:
            k.degistir(k.en, YONERGE + "\n\n", "")
            k.degistir(k.en, "## What the field says\n\n", "## What the field says\n\n" + YONERGE + "\n\n")
            h = hatalar(D.sina_canli_pencereler)
            self.assertTrue(any("iki dilde aynı yerde değil" in x for x in h), h)

    def test_bilinmeyen_kimlik(self):
        with Kopya() as k:
            for yol in (k.tr, k.en):
                k.degistir(yol, YONERGE, "[[canli:yarin-uzaydan]]")
            h = hatalar(D.sina_canli_pencereler)
            self.assertTrue(any("tanınmıyor" in x for x in h), h)
            self.assertTrue(any("hiçbir metinde yönergesi yok" in x for x in h), h)

    def test_iki_kez(self):
        with Kopya() as k:
            for yol, alt in ((k.tr, "## Saha ne diyor\n\n"), (k.en, "## What the field says\n\n")):
                k.degistir(yol, alt, alt + YONERGE + "\n\n")
            h = hatalar(D.sina_canli_pencereler)
            self.assertTrue(any("2 kez" in x for x in h), h)

    def test_teknoloji_sayfasinda(self):
        with Kopya() as k:
            tek = sorted((k.kok / "teknolojiler").glob("*.tr.md"))[0]
            t = tek.read_text(encoding="utf-8")
            tek.write_text(t.rstrip("\n") + "\n\n" + YONERGE + "\n", encoding="utf-8")
            h = hatalar(D.sina_canli_pencereler)
            self.assertTrue(any("teknoloji sayfasında" in x for x in h), h)

    def test_telefon_yuksekligi(self):
        b = {"tur": "canli", "metin": "uzaydan-bugun", "ogeler": []}
        self.assertEqual(D.tel_yuksekligi(b), D.CANLI_TEL_YUKSEKLIGI)
        self.assertGreater(D.CANLI_TEL_YUKSEKLIGI, 300)


class Ayristiricilar(unittest.TestCase):
    """Yönerge metin değil; blok sırası yzAyristir ile aynı."""

    def test_dogrulayici_bloklari(self):
        bl = D.sayfa_bloklari(ORNEK)
        self.assertEqual([b["tur"] for b in bl], ["paragraf", "gorsel", "canli", "altBaslik", "paragraf"])
        self.assertEqual(bl[2]["metin"], "uzaydan-bugun")
        self.assertEqual(D.metin_parcalari(ORNEK), D.metin_parcalari(YALIN))

    def test_telefon_bolme(self):
        bl = TEL.bloklar(ORNEK)
        self.assertEqual([t for t, _ in bl], ["paragraf", "yonerge", "yonerge", "altBaslik", "paragraf"])
        # Gerçek §19: yönergeden sonraki paragraflar bir blok kayık (fikstür yenilendi).
        tr = TEL.bloklar(SAYFA_TR.read_text(encoding="utf-8"))
        self.assertNotIn(YONERGE, [m for _, m in tr])

    def test_atlas(self):
        bl = ATLAS.bloklar(ORNEK)
        self.assertEqual([b["tur"] for b in bl], ["paragraf", "gorsel", "canli", "altBaslik", "paragraf"])

    def test_basili_surumde_yok(self):
        bl = YAZDIR.bloklar(ORNEK)
        self.assertEqual([t for t, _ in bl], ["p", "gorsel", "h", "p"])
        self.assertFalse(any("canli" in str(x) or "uzaydan" in str(x) for _, x in bl))

    def test_teknoloji_izi_ve_sozluk(self):
        self.assertEqual(IZ.bloklar(ORNEK), IZ.bloklar(YALIN))
        self.assertFalse(any("uzaydan" in b for b in IZ.bloklar(ORNEK)))
        sozluk = SOZLUK.bloklar(ORNEK)
        self.assertIn(("yonerge", YONERGE), sozluk, "yönerge olarak tanınıyor, terim aranmıyor")
        self.assertEqual([x for x in sozluk if x[0] != "yonerge"],
                         [x for x in SOZLUK.bloklar(YALIN) if x[0] != "yonerge"])

    def test_gorsel_ve_grafik_yerlestirici_saymiyor(self):
        for m in (GORSEL, GRAFIK):
            self.assertEqual(m.bloklar(ORNEK), m.bloklar(YALIN), m.__name__)

    def test_okuma_suresi(self):
        self.assertEqual(DART.kelime_sayisi(ORNEK), DART.kelime_sayisi(YALIN))
        for yol in (SAYFA_TR, SAYFA_EN):
            md = yol.read_text(encoding="utf-8")
            self.assertIn(YONERGE, md)
            self.assertEqual(DART.kelime_sayisi(md), DART.kelime_sayisi(md.replace(YONERGE + "\n\n", "")))


if __name__ == "__main__":
    unittest.main(verbosity=1)
