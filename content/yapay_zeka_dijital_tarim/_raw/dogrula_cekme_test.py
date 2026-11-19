#!/usr/bin/env python3
"""dogrula_bolumler.py kural 12 (görselin konumu, madde 5) ve kural 16
(öne çıkan cümle, madde 6) için sınama.

    python3 -I content/yapay_zeka_dijital_tarim/_raw/dogrula_cekme_test.py

Depodaki metin ve kayıtlar geçmeli; bozulmuş kopyalar (geçici klasörde)
yakalanmalı. Depoya yazmaz.
"""
from __future__ import annotations

import importlib.util
import io
import json
import shutil
import tempfile
import unittest
from contextlib import redirect_stdout
from pathlib import Path

BURASI = Path(__file__).resolve().parent
KOK = BURASI.parent


def _yukle():
    spec = importlib.util.spec_from_file_location("dogrula_bolumler_sina", BURASI / "dogrula_bolumler.py")
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


D = _yukle()
CEKMELER = json.loads((BURASI / "cekmeler.json").read_text(encoding="utf-8"))["cekmeler"]
ILK = CEKMELER[0]
SAYFA_TR = D.sayfa_dosyasi(ILK["sayfa"])
SAYFA_EN = SAYFA_TR.with_name(SAYFA_TR.name.replace(".tr.md", ".en.md"))
YONERGE = f"[[cekme:{ILK['kimlik']}]]"


class Kopya:
    """bolumler/ ve teknolojiler/ ile cekmeler.json'un geçici kopyası;
    doğrulayıcının yolları ona çevriliyor."""

    def __enter__(self):
        self.gecici = tempfile.TemporaryDirectory()
        k = Path(self.gecici.name)
        shutil.copytree(KOK / "bolumler", k / "bolumler")
        shutil.copytree(KOK / "teknolojiler", k / "teknolojiler")
        shutil.copy(BURASI / "cekmeler.json", k / "cekmeler.json")
        self.eski = (D.BOLUMLER, D.TEKNOLOJILER, D.CEKME_KAYDI)
        D.BOLUMLER, D.TEKNOLOJILER, D.CEKME_KAYDI = k / "bolumler", k / "teknolojiler", k / "cekmeler.json"
        self.tr = k / "bolumler" / SAYFA_TR.name
        self.en = k / "bolumler" / SAYFA_EN.name
        self.kayit = k / "cekmeler.json"
        return self

    def __exit__(self, *a):
        D.BOLUMLER, D.TEKNOLOJILER, D.CEKME_KAYDI = self.eski
        self.gecici.cleanup()

    def degistir(self, yol: Path, eski: str, yeni: str) -> None:
        t = yol.read_text(encoding="utf-8")
        assert eski in t, eski[:60]
        yol.write_text(t.replace(eski, yeni, 1), encoding="utf-8")

    def kayit_degistir(self, **alanlar) -> None:
        d = json.loads(self.kayit.read_text(encoding="utf-8"))
        d["cekmeler"][0].update(alanlar)
        self.kayit.write_text(json.dumps(d, ensure_ascii=False), encoding="utf-8")


def hatalar(islev) -> list[str]:
    D.hatalar.clear()
    with redirect_stdout(io.StringIO()):
        islev()
    return list(D.hatalar)


def yonerge_tasi(yol: Path, once_gelen) -> None:
    """Yönergeyi çıkarıp [once_gelen] (blok → bool) ilk tuttuğu bloğun önüne koyar."""
    t = yol.read_text(encoding="utf-8")
    g = t.rstrip("\n")
    bl = [x for x in g.split("\n\n") if x != YONERGE]
    i = next(i for i, x in enumerate(bl) if once_gelen(x))
    bl.insert(i, YONERGE)
    yol.write_text("\n\n".join(bl) + t[len(g):], encoding="utf-8")


class Kural16(unittest.TestCase):
    def test_depo_geciyor(self):
        self.assertEqual(hatalar(D.sina_cekmeler), [])

    def test_harfi_harfine(self):
        with Kopya() as k:
            k.kayit_degistir(tr=ILK["tr"].replace("payı", "oranı"))
            self.assertTrue(any("tam bir kez geçmiyor" in h for h in hatalar(D.sina_cekmeler)))

    def test_cumle_siniri(self):
        with Kopya() as k:
            k.kayit_degistir(tr=ILK["tr"].split(" ", 1)[1])     # ilk kelimesiz: cümle ortası
            self.assertTrue(any("cümle sınırı" in h for h in hatalar(D.sina_cekmeler)))
        self.assertFalse(D.cumle_siniri_mi("Ayrı bir politika (**505.** paragraf). Son.", 0, 30))
        self.assertTrue(D.cumle_siniri_mi("Bir. İki üç dört.", 5, 17))

    def test_iki_dilin_rakamlari(self):
        with Kopya() as k:
            k.degistir(k.en, ILK["en"], ILK["en"].replace("**14%**", "**15%**"))
            k.kayit_degistir(en=ILK["en"].replace("**14%**", "**15%**"))
            self.assertTrue(any("rakamları farklı" in h for h in hatalar(D.sina_cekmeler)))

    def test_iki_dilde_ayni_yer(self):
        with Kopya() as k:
            k.degistir(k.en, YONERGE + "\n\n", "")
            self.assertTrue(any("aynı yerde değil" in h for h in hatalar(D.sina_cekmeler)))

    def test_kaynak_bitisigi(self):
        with Kopya() as k:
            yonerge_tasi(k.tr, lambda x: ILK["tr"] in x)
            yonerge_tasi(k.en, lambda x: ILK["en"] in x)
            h = hatalar(D.sina_cekmeler)
            self.assertTrue(any("yer kurala uymuyor" in x or "iki paragrafın arasında değil" in x for x in h), h)

    def test_ortaya_en_yakin(self):
        # Koşunun içinde ama ortaya en yakın uygun ara değil: bir paragraf aşağı.
        bl = SAYFA_TR.read_text(encoding="utf-8").rstrip("\n").split("\n\n")
        sonraki = bl[bl.index(YONERGE) + 1]
        bl_en = SAYFA_EN.read_text(encoding="utf-8").rstrip("\n").split("\n\n")
        sonraki_en = bl_en[bl_en.index(YONERGE) + 1]
        with Kopya() as k:
            yonerge_tasi(k.tr, lambda x: x == bl[bl.index(sonraki) + 1])
            yonerge_tasi(k.en, lambda x: x == bl_en[bl_en.index(sonraki_en) + 1])
            h = hatalar(D.sina_cekmeler)
            self.assertTrue(h, "yer değişti ama hata yok")

    def test_yer_hesabi(self):
        par = "Kelime " * 60 + "son."
        md = "# 9 · B\n\n" + par + "\n\n## Alt\n\n" + "\n\n".join([par] * 6) + "\n"
        bl = D.sayfa_bloklari(md)
        yerler = D.cekme_yerleri(bl)
        self.assertTrue(yerler)
        en_iyi = min(yerler, key=lambda u: (u[1], u[0]))[0]
        self.assertEqual(en_iyi, 4, yerler)                 # 6 eşit paragrafın ortası: 3. ile 4. arası
        self.assertNotIn(0, [u[0] for u in yerler])         # giriş paragrafının ardı değil
        kaynakli = D.cekme_yerleri(bl, kaynak=4)
        self.assertNotIn(4, [u[0] for u in kaynakli])       # kaynak paragrafın bitişiği değil
        self.assertNotIn(3, [u[0] for u in kaynakli])
        kisa = D.sayfa_bloklari("# 9 · B\n\n" + par + "\n\n## Alt\n\nKısa.\n\nKısa.\n")
        self.assertEqual(D.cekme_yerleri(kisa), [])         # 1,0 ekranı aşmayan koşu

    def test_giris_ardi(self):
        with Kopya() as k:
            yonerge_tasi(k.tr, lambda x: not x.startswith("# ") and x != k.tr.read_text().split("\n\n")[1])
            yonerge_tasi(k.en, lambda x: not x.startswith("# ") and x != k.en.read_text().split("\n\n")[1])
            h = hatalar(D.sina_cekmeler)
            self.assertTrue(any("bölümünde değil" in x or "yer kurala uymuyor" in x
                                or "iki paragrafın arasında değil" in x for x in h), h)

    def test_taninmayan_yonerge(self):
        bl = D.sayfa_bloklari("# 1 · B\n\nBir.\n\n[[alinti:x]]\n\nİki.\n")
        self.assertEqual([b["tur"] for b in bl], ["paragraf", "paragraf"])
        with Kopya() as k:
            k.degistir(k.tr, YONERGE, YONERGE + "\n\n[[alinti:deneme]]")
            self.assertTrue(any("tanınmayan yönerge" in h for h in hatalar(D.sina_cekmeler)))

    def test_kayitsiz_yonerge_ve_kullanilmayan_kayit(self):
        with Kopya() as k:
            k.kayit_degistir(kimlik="baska-kimlik")
            h = hatalar(D.sina_cekmeler)
            self.assertTrue(any("cekmeler.json'da yok" in x for x in h))
            self.assertTrue(any("yönergesi yok" in x for x in h))

    def test_satici_ve_gonderme(self):
        with Kopya() as k:
            k.degistir(k.tr, ILK["tr"], "Bu " + ILK["tr"])
            k.kayit_degistir(tr="Bu " + ILK["tr"])
            h = hatalar(D.sina_cekmeler)
            self.assertTrue(any("gönderme" in x or "cümle sınırı" in x for x in h), h)

    def test_sayi_izi_yonergeyi_okumuyor(self):
        self.assertEqual(D.metin_sayilari("[[cekme:b14-x2]]\n[[bilinmeyen:a1]]", "tr"), [])


class Kural12Konum(unittest.TestCase):
    def test_depo_geciyor(self):
        g = json.loads((BURASI / "gorseller.json").read_text(encoding="utf-8"))["gorseller"]
        self.assertEqual(hatalar(lambda: D.sina_gorsel_yerleri(g)), [])
        self.assertTrue(all(x.get("konum") in ("önce", "sonra") for x in g.values()))

    def test_ters_konum_yakalaniyor(self):
        g = json.loads((BURASI / "gorseller.json").read_text(encoding="utf-8"))["gorseller"]
        once = next(k for k, x in g.items() if x["konum"] == "önce")
        g[once]["konum"] = "sonra"
        self.assertTrue(any(once in h for h in hatalar(lambda: D.sina_gorsel_yerleri(g))))


def _modul(ad: str):
    spec = importlib.util.spec_from_file_location(f"{ad}_sina", BURASI / f"{ad}.py")
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


class Ayristiricilar(unittest.TestCase):
    """Öne çıkan cümle ve tanınmayan yönerge hiçbir ayrıştırıcıda blok ya da
    metin değil; basılı sürüme ve teknoloji izine girmiyor."""
    MD = "# 1 · B\n\nBir.\n\n[[cekme:k-1]]\n\n[[bilinmeyen:z]]\n\n[[grafik:g]]\n\nİki.\n"

    def test_basili_surum(self):
        self.assertEqual(_modul("yazdir_uret").bloklar(self.MD), [("p", "Bir."), ("grafik", "g"), ("p", "İki.")])

    def test_teknoloji_izi(self):
        self.assertEqual(_modul("teknoloji_izi").bloklar(self.MD), ["Bir.", "İki."])

    def test_yerlestiriciler_blok_saymiyor(self):
        for ad in ("gorsel_isle", "grafik_donustur"):
            m = _modul(ad)
            self.assertEqual(m.bloklar(self.MD), ["# 1 · B", "Bir.", "[[grafik:g]]", "İki."], ad)
            # 3. blok (İki.) ardına: cekme satırları sayılmadan.
            self.assertTrue(m.yerlestir(self.MD, {3: ["[[gorsel:x]]"]}).rstrip().endswith("İki.\n\n[[gorsel:x]]"), ad)

    def test_gorsel_once_yerlesiyor(self):
        m = _modul("gorsel_isle")
        self.assertIn("[[gorsel:x]]\n\nİki.", m.yerlestir(self.MD, {}, {3: ["[[gorsel:x]]"]}))

    def test_sozluk_terim_aramiyor(self):
        bl = _modul("sozluk_uret").bloklar(self.MD)
        self.assertEqual([m for t, m in bl if t == "paragraf"], ["Bir.", "İki."])

    def test_dogrulayici_parcalari(self):
        self.assertEqual(D.metin_parcalari(self.MD), ["Bir.", "İki."])


if __name__ == "__main__":
    unittest.main(verbosity=1)
