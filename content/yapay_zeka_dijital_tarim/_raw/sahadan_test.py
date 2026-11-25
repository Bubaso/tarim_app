#!/usr/bin/env python3
"""Sahadan galerisi için sınama: dogrula_bolumler.py kural 21 ve
sahadan_uret.py.

    python3 -I content/yapay_zeka_dijital_tarim/_raw/sahadan_test.py

Depodaki kayıt geçiyor; geçici kopyada (sahadan.json, gorseller.json, kare
dosyaları, yz_sahadan.g.dart) bilerek bozulan her durum yakalanıyor. Depoya
yazmaz.
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


def _modul(ad: str, dosya: str):
    sp = importlib.util.spec_from_file_location(ad, BURASI / dosya)
    m = importlib.util.module_from_spec(sp)
    sp.loader.exec_module(m)
    return m


SU = _modul("sahadan_uret_sina", "sahadan_uret.py")


class Kural21(unittest.TestCase):
    """Depodaki galeri geçiyor; geçici kopyada bozulanlar yakalanıyor."""

    def setUp(self):
        self.D = _modul("dogrula_bolumler_sahadan", "dogrula_bolumler.py")
        self.su = _modul("sahadan_uret_k21_sina", "sahadan_uret.py")
        self.gecici = Path(tempfile.mkdtemp(prefix="sahadan_k21_"))
        klasor = self.gecici / "web/yz/gorsel"
        klasor.mkdir(parents=True)
        for r in SU.kareler():
            shutil.copy(SU.DEPO / r["dosya"], klasor / Path(r["dosya"]).name)
        shutil.copy(SU.KAYIT, self.gecici / "sahadan.json")
        shutil.copy(SU.GORSELLER, self.gecici / "gorseller.json")
        shutil.copy(SU.CIKIS, self.gecici / "yz_sahadan.g.dart")
        self.su.DEPO = self.gecici
        self.su.KAYIT = self.gecici / "sahadan.json"
        self.su.GORSELLER = self.gecici / "gorseller.json"
        self.su.CIKIS = self.gecici / "yz_sahadan.g.dart"

    def tearDown(self):
        shutil.rmtree(self.gecici, ignore_errors=True)

    def hatalar(self) -> list[str]:
        self.D.hatalar.clear()
        with redirect_stdout(io.StringIO()):
            self.D.sina_sahadan(su=self.su)
        return list(self.D.hatalar)

    def kare_degistir(self, islev, dart: bool = True) -> None:
        """sahadan.json'u bozar; [dart] ise üretilmiş dosyayı da yeniler
        (yalnız bozulan kural yakalansın, "eski" değil)."""
        k = json.loads(self.su.KAYIT.read_text(encoding="utf-8"))
        islev(k["kareler"])
        self.su.KAYIT.write_text(json.dumps(k, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
        if dart:
            self.su.CIKIS.write_text(self.su.dart_kaynagi(), encoding="utf-8")

    def kare(self, kareler: list[dict], harf: str) -> dict:
        return next(r for r in kareler if r["harf"] == harf)

    def test_depodaki_geciyor(self):
        self.assertEqual(self.hatalar(), [])

    def test_kunye_bos(self):
        self.kare_degistir(lambda ks: self.kare(ks, "A")["kunye"].update(en=" "))
        self.assertTrue(any("kunye iki dilde de dolu değil" in h for h in self.hatalar()))

    def test_kaynak_satiri_bicimi(self):
        self.kare_degistir(lambda ks: self.kare(ks, "C")["kaynak"].update(tr="Elazığ İl Tarım ve Orman Müdürlüğü"))
        self.assertTrue(any("'Fotoğraf: <kurum>'" in h for h in self.hatalar()))

    def test_ajans_izi(self):
        self.kare_degistir(lambda ks: self.kare(ks, "G").update(ajans_izi="evet – AA"))
        self.assertTrue(any("ajans izi" in h for h in self.hatalar()))

    def test_adres_yok(self):
        self.kare_degistir(lambda ks: self.kare(ks, "H").update(sayfa_adresi=""))
        self.assertTrue(any("sayfa_adresi yok" in h for h in self.hatalar()))

    def test_dosya_degisti(self):
        f = self.gecici / "web/yz/gorsel/sahadan-kocaeli-akilli-zirai-mucadele-2.webp"
        veri = bytearray(f.read_bytes())
        veri[-1] ^= 0xFF
        f.write_bytes(bytes(veri))
        self.assertTrue(any("sha256 tutmuyor" in h for h in self.hatalar()))

    def test_piksel_boyu(self):
        self.kare_degistir(lambda ks: self.kare(ks, "B").update(genislik=801))
        self.assertTrue(any("piksel boyu" in h for h in self.hatalar()))

    def test_dosya_yok(self):
        (self.gecici / "web/yz/gorsel/sahadan-antalya-akuaponik-sazan-ve-enginar.webp").unlink()
        self.assertTrue(any("dosya yok" in h for h in self.hatalar()))

    def test_il_gecersiz(self):
        # Üretici de durur (dart_uret.py geçersiz ille Dart yazmaz).
        with self.assertRaises(SystemExit):
            self.kare_degistir(lambda ks: self.kare(ks, "A").update(il="Kandıra"))
        h = self.hatalar()
        self.assertTrue(any("81 ilden biri değil" in x for x in h), h)

    def test_baslik_icindekiyle_ayrisma(self):
        # Başlık içindeki kare (D) ile galerideki aynı künyeyi taşımalı.
        self.kare_degistir(lambda ks: self.kare(ks, "D")["kunye"].update(tr="Başka bir künye."))
        self.assertTrue(any("'kunye' gorseller.json'daki kayıttan ayrışmış" in h for h in self.hatalar()))

    def test_cift_dosya(self):
        # F'nin görseli başka kimlikle yeniden indirilmiş gibi: çift dosya.
        def bozan(ks):
            f = self.kare(ks, "F")
            yeni = {**f, "harf": "I", "kimlik": "sahadan-adana-yangin-kulesi", "merkez": False,
                    "dosya": "web/yz/gorsel/sahadan-adana-yangin-kulesi.webp",
                    "gorsel_adresi": f["gorsel_adresi"] + "?RenditionID=7"}
            shutil.copy(self.su.DEPO / f["dosya"], self.su.DEPO / yeni["dosya"])
            ks.append(yeni)
        self.kare_degistir(bozan)
        self.assertTrue(any("çift dosya, o kaydı kullan" in h for h in self.hatalar()))

    def test_ayni_dosyayi_baska_kimlikle_kullanmak_serbest(self):
        # Teknoloji sayfasındaki yeniden kullanım gibi: aynı adres, AYNI dosya.
        g = json.loads(self.su.GORSELLER.read_text(encoding="utf-8"))
        f = g["gorseller"]["b15-kamerali-insansiz-yangin-gozetleme"]
        g["gorseller"]["t-karar-ornek-yeniden-kullanim"] = {**f, "sayfa": "tek_karar"}
        self.su.GORSELLER.write_text(json.dumps(g, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
        self.assertEqual(self.hatalar(), [])

    def test_alt_baslik_yonergeyle_tutmuyor(self):
        # E'nin yönergesi §7'nin "Türkiye" alt başlığında.
        self.kare_degistir(lambda ks: self.kare(ks, "E").update(bolum={"tr": "Ne yapıyor", "en": "What it does"}))
        self.assertTrue(any("alt başlığında, kayıtta" in h for h in self.hatalar()))

    def test_alt_baslik_metinde_yok(self):
        self.kare_degistir(lambda ks: self.kare(ks, "G").update(bolum={"tr": "Türkiye'de", "en": "Türkiye"}))
        self.assertTrue(any("metninde yok" in h for h in self.hatalar()))

    def test_yonerge_metinden_silindi(self):
        # Başlık içindeki karenin yönergesi metinde yoksa galeri bağlantısı boşa düşer.
        g = json.loads(self.su.GORSELLER.read_text(encoding="utf-8"))
        g["gorseller"]["b07-dijital-sulama-yonetim-sistemi-disu"]["sayfa"] = "b06"
        self.su.GORSELLER.write_text(json.dumps(g, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
        self.su.CIKIS.write_text(self.su.dart_kaynagi(), encoding="utf-8")
        self.assertTrue(any("gorseller.json'da sayfa 'b06'" in h for h in self.hatalar()))

    def test_galeriye_ozel_kimlik(self):
        def bozan(ks):
            a = self.kare(ks, "A")
            yeni = "kocaeli-akilli-zirai-mucadele-1"
            (self.su.DEPO / a["dosya"]).rename(self.su.DEPO / f"web/yz/gorsel/{yeni}.webp")
            a.update(kimlik=yeni, dosya=f"web/yz/gorsel/{yeni}.webp")
        self.kare_degistir(bozan)
        self.assertTrue(any("'sahadan-' ile başlamalı" in h for h in self.hatalar()))

    def test_artik_dosya(self):
        (self.gecici / "web/yz/gorsel/sahadan-eski-kare.webp").write_bytes(b"RIFF")
        self.assertTrue(any("artık dosya" in h for h in self.hatalar()))

    def test_harf_iki_kez(self):
        self.kare_degistir(lambda ks: self.kare(ks, "B").update(harf="A"))
        self.assertTrue(any("harf 'A' iki kez" in h for h in self.hatalar()))

    def test_merkez_sayisi(self):
        self.kare_degistir(lambda ks: [r.update(merkez=True) for r in ks])
        self.assertTrue(any("merkez kartı için 8 kare" in h for h in self.hatalar()))

    def test_dart_eski(self):
        self.kare_degistir(lambda ks: self.kare(ks, "H")["kunye"].update(tr="Yeni künye."), dart=False)
        self.assertTrue(any("eski — dart_uret.py" in h for h in self.hatalar()))


class Uretici(unittest.TestCase):
    def test_dart_kaynagi(self):
        d = SU.dart_kaynagi()
        self.assertIn("const List<YzSahadanKare> kYzSahadan = [", d)
        self.assertEqual(d.count("  YzSahadanKare("), len(SU.kareler()))
        # İl → plaka ızgaradan; ilsiz kare plakasız.
        self.assertIn('il: "Kocaeli",\n    plaka: 41,', d)
        e = d.split('harf: "E",')[1].split("  ),")[0]
        self.assertNotIn("plaka:", e)
        self.assertIn("metinde: true", e)
        # Dart dizgisinde $ kaçışı.
        self.assertEqual(SU._dizgi("a$b"), '"a\\$b"')

    def test_adres(self):
        self.assertEqual(SU.adres("web/yz/gorsel/x.webp"), "/yz/gorsel/x.webp")


if __name__ == "__main__":
    unittest.main(verbosity=2)
