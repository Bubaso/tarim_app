#!/usr/bin/env python3
"""Rakamın makbuzu için sınama: makbuz.swift (arama, vurgu hizası),
makbuz_uret.py (yardımcılar) ve dogrula_bolumler.py kural 19.

    python3 -I content/yapay_zeka_dijital_tarim/_raw/makbuz_test.py

Swift sınamaları macOS'ta `swift` varsa koşar (yoksa atlanır). Elle yazılmış
PDF'ler, kesitler ve bozulmuş kopyalar geçici klasörde; depoya yazmaz.
Yerel kopyası varsa 2027 Yıllık Programı'nın kayıtlı sayfaları
(`yillik_program_2027.json` › `pdf_sayfa`, alıntılar o kaydın) gerçek doğru
olarak kullanılıyor.
"""
from __future__ import annotations

import importlib.util
import io
import json
import shutil
import struct
import tempfile
import unittest
import zlib
from contextlib import redirect_stdout
from pathlib import Path

BURASI = Path(__file__).resolve().parent


def _modul(ad: str, dosya: str):
    sp = importlib.util.spec_from_file_location(ad, BURASI / dosya)
    m = importlib.util.module_from_spec(sp)
    sp.loader.exec_module(m)
    return m


MU = _modul("makbuz_uret_sina", "makbuz_uret.py")
SWIFT_VAR = shutil.which("swift") is not None


# ── elle yazılmış PDF ──────────────────────────────────────────────────────

def _pdf_dizgisi(s: str) -> str:
    return s.replace("\\", "\\\\").replace("(", "\\(").replace(")", "\\)")


def el_pdf(sayfalar: list[list[tuple[float, float, str]]], kirpma: tuple[float, float, float, float] | None = None,
           punto: float = 12) -> bytes:
    """Helvetica ile, satırları verilen yerlere yazılmış PDF. [kirpma]: her
    sayfanın kırpma kutusu (sıfırdan başlamayan kutuyu sınamak için)."""
    nesneler: list[bytes] = []
    n = len(sayfalar)
    sayfa_no = [3 + 2 * i for i in range(n)]
    font_no = 3 + 2 * n
    nesneler.append(b"<< /Type /Catalog /Pages 2 0 R >>")
    nesneler.append(("<< /Type /Pages /Kids [" + " ".join(f"{s} 0 R" for s in sayfa_no)
                     + f"] /Count {n} >>").encode())
    for i, satirlar in enumerate(sayfalar):
        akis = "".join(f"BT /F1 {punto:g} Tf {x:g} {y:g} Td ({_pdf_dizgisi(t)}) Tj ET\n" for x, y, t in satirlar).encode("latin-1")
        kirp = f" /CropBox [{' '.join(f'{v:g}' for v in kirpma)}]" if kirpma else ""
        nesneler.append((f"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792]{kirp} "
                         f"/Resources << /Font << /F1 {font_no} 0 R >> >> /Contents {sayfa_no[i] + 1} 0 R >>").encode())
        nesneler.append(f"<< /Length {len(akis)} >>\nstream\n".encode() + akis + b"endstream")
    nesneler.append(b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>")
    cikti = bytearray(b"%PDF-1.4\n")
    yerler = []
    for i, govde in enumerate(nesneler, 1):
        yerler.append(len(cikti))
        cikti += f"{i} 0 obj\n".encode() + govde + b"\nendobj\n"
    xref = len(cikti)
    cikti += f"xref\n0 {len(nesneler) + 1}\n0000000000 65535 f \n".encode()
    for y in yerler:
        cikti += f"{y:010d} 00000 n \n".encode()
    cikti += f"trailer\n<< /Size {len(nesneler) + 1} /Root 1 0 R >>\nstartxref\n{xref}\n%%EOF\n".encode()
    return bytes(cikti)


def png_oku(yol: Path) -> tuple[int, int, list[bytes]]:
    """8 bit RGB/RGBA PNG → (genişlik, yükseklik, satırlar [RGBA baytları])."""
    veri = yol.read_bytes()
    assert veri[:8] == b"\x89PNG\r\n\x1a\n"
    i, idat = 8, b""
    g = y = tur = 0
    while i < len(veri):
        uz, ad = struct.unpack(">I4s", veri[i:i + 8])
        govde = veri[i + 8:i + 8 + uz]
        if ad == b"IHDR":
            g, y, derinlik, tur, _, _, aralik = struct.unpack(">IIBBBBB", govde)
            assert derinlik == 8 and tur in (2, 6) and aralik == 0, (derinlik, tur, aralik)
        elif ad == b"IDAT":
            idat += govde
        i += 12 + uz
    bpp = 4 if tur == 6 else 3
    ham = zlib.decompress(idat)
    satirlar: list[bytes] = []
    onceki = bytearray(g * bpp)
    for r in range(y):
        f = ham[r * (g * bpp + 1)]
        s = bytearray(ham[r * (g * bpp + 1) + 1:(r + 1) * (g * bpp + 1)])
        for k in range(len(s)):
            a = s[k - bpp] if k >= bpp else 0
            b = onceki[k]
            c = onceki[k - bpp] if k >= bpp else 0
            if f == 1:
                s[k] = (s[k] + a) & 255
            elif f == 2:
                s[k] = (s[k] + b) & 255
            elif f == 3:
                s[k] = (s[k] + (a + b) // 2) & 255
            elif f == 4:
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                s[k] = (s[k] + (a if pa <= pb and pa <= pc else b if pb <= pc else c)) & 255
        onceki = s
        satirlar.append(bytes(s) if bpp == 4 else bytes(x for j in range(g) for x in (*s[3 * j:3 * j + 3], 255)))
    return g, y, satirlar


def sari_orani(png: tuple[int, int, list[bytes]], x0: float, y0: float, x1: float, y1: float) -> float:
    """Piksel dikdörtgenindeki (üstten) fosforlu kalem sarısı payı."""
    g, y, satirlar = png
    say = sari = 0
    for r in range(max(0, int(y0)), min(y, int(y1))):
        for c in range(max(0, int(x0)), min(g, int(x1))):
            R, G, B = satirlar[r][4 * c:4 * c + 3]
            say += 1
            if R > 200 and G > 170 and B < 150:
                sari += 1
    return sari / max(say, 1)


# Sayfa 2'nin satırları: 12 punto Helvetica, taban çizgisi y'de, x = 72.
SATIRLAR = [
    (72, 700, "Field trials were repeated across three provinces in two seasons."),
    (72, 684, "Precision agriculture adoption reached 27 percent among au-"),
    (72, 668, "tomation users in the region, according to the survey."),
    (72, 652, "The yield rose by 12 percent over three seasons in the trial plots."),
    (72, 636, "Farm sizes vary widely between the coastal and inland districts."),
    (72, 620, "Most holdings remain under five hectares in every district studied."),
    (72, 604, "Extension services reached fewer farms than planned last year."),
]
KIRPMA = (20.0, 40.0, 612.0, 792.0)
TIRE = "Precision agriculture adoption reached 27 percent among automation users in the region"
NOT = "The yield rose by 12 percent (according to the field trial) over three seasons"
YOK = "Nothing in this document mentions orbital launch schedules at all"


@unittest.skipUnless(SWIFT_VAR, "swift yok (macOS PDFKit gerekir)")
class ElPdf(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.gecici = Path(tempfile.mkdtemp(prefix="makbuz_sina_"))
        pdf = cls.gecici / "el.pdf"
        pdf.write_bytes(el_pdf([[(72, 700, "Weather stations report rainfall every ten minutes.")], SATIRLAR],
                               kirpma=KIRPMA))
        isler = [{"pdf": str(pdf), "alintilar": [
            {"kimlik": "tire", "alinti": TIRE, "cikis": str(cls.gecici / "tire.png")},
            {"kimlik": "not", "alinti": NOT, "cikis": None},
            {"kimlik": "yok", "alinti": YOK, "cikis": None},
        ]}]
        cls.sonuc = {s["kimlik"]: s for s in MU.swift(isler)}

    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(cls.gecici, ignore_errors=True)

    def test_tireleme_tam_eslesme(self):
        s = self.sonuc["tire"]
        self.assertEqual(s["sayfa"], 2)
        self.assertEqual(s["sayfa_sayisi"], 2)
        self.assertEqual(s["yontem"], "tam", "satır sonu tirelemesi ('au-⏎tomation') eşleşmeyi bozmuyor")

    def test_parantez_ici_not_parca(self):
        s = self.sonuc["not"]
        self.assertEqual(s["sayfa"], 2)
        self.assertEqual(s["yontem"], "parca",
                         "kayıttaki not PDF'te yok; notun kelimeleri sayfada başka yerde (according, field "
                         "trials) olsa da sıra dışı eşleşme onları toplamamalı")
        self.assertLess(s["kapsama"], 1)

    def test_bulunamayan(self):
        s = self.sonuc["yok"]
        self.assertIsNone(s["sayfa"])
        self.assertIsNone(s["kesit"])
        self.assertTrue(s.get("neden"))

    def test_vurgu_yaziyla_hizali_kirpma_kutusu_sifirdan_baslamiyor(self):
        """Kırpma kutusu (20, 40)'tan başlıyor: vurgu kaysaydı satırın üstünde
        sarı olmazdı. Satır 2 ve 3 (tirelenmiş alıntı) sarı; satır 4 değil."""
        k = self.sonuc["tire"]["kesit"]
        self.assertIsNotNone(k)
        self.assertEqual(k["donus"], 0)
        png = png_oku(self.gecici / "tire.png")
        self.assertEqual((png[0], png[1]), (k["genislik"], k["yukseklik"]))
        x0, y0 = k["kutu"][0], k["kutu"][1]
        o = k["olcek"]

        def bolge(sx0: float, sx1: float, taban: float) -> tuple[float, float, float, float]:
            # çizim uzayı = sayfa − kırpma başlangıcı; satırın gövdesi tabanın 1-8 pt üstü
            cx0, cx1 = sx0 - KIRPMA[0], sx1 - KIRPMA[0]
            cy0, cy1 = taban - KIRPMA[1] + 1, taban - KIRPMA[1] + 8
            return ((cx0 - x0) * o, png[1] - (cy1 - y0) * o, (cx1 - x0) * o, png[1] - (cy0 - y0) * o)

        self.assertGreater(sari_orani(png, *bolge(80, 300, 684)), 0.35, "satır 2 vurgulu")
        self.assertGreater(sari_orani(png, *bolge(80, 200, 668)), 0.35, "satır 3 (tirelemenin devamı) vurgulu")
        self.assertLess(sari_orani(png, *bolge(80, 300, 652)), 0.02, "satır 4 vurgusuz")
        self.assertLess(sari_orani(png, *bolge(80, 300, 700)), 0.02, "satır 1 vurgusuz")
        # Sol dikey çizgi yok: vurgunun solundaki şerit beyaz.
        self.assertLess(sari_orani(png, *bolge(40, 66, 684)), 0.02, "vurgunun solunda çizgi ya da dolgu yok")


@unittest.skipUnless(SWIFT_VAR and (BURASI / "kaynak_dosyalari/yillik_program_2027.pdf").exists(),
                     "swift ya da yillik_program_2027.pdf yok")
class YillikProgram(unittest.TestCase):
    """Kayıtlı PDF sayfaları gerçek doğru: alıntıların bulunduğu sayfa kayıttaki."""

    def test_kayitli_sayfalar(self):
        k = json.loads((BURASI / "yillik_program_2027.json").read_text(encoding="utf-8"))
        beklenen: list[tuple[str, list[int]]] = []
        for m in k["mevcut_durum"] + k["bolum_disi"]:
            beklenen += [(a, m["pdf_sayfa"]) for a in m["alinti"]]
        for p in k["politika_ve_tedbirler"]:
            if "politika" in p:
                beklenen.append((p["politika"], p["pdf_sayfa"]))
            for t in p["tedbirler"]:
                beklenen += [(x, p["pdf_sayfa"]) for x in [t.get("tedbir"), *t["faaliyet"]] if x]
        # Tablo satırı: PDF metninde hücreler başka sırada (sıra dışı eşleşme).
        beklenen.append(("Tarım Sigortası Destekleme Hizmetleri 19 200,0 23 000,0 30 000,0", [177]))
        isler = [{"pdf": str(BURASI / k["kunye"]["kaynak_dosyasi"]),
                  "alintilar": [{"kimlik": str(i), "alinti": a, "cikis": None} for i, (a, _) in enumerate(beklenen)]}]
        sonuc = {s["kimlik"]: s for s in MU.swift(isler)}
        self.assertGreater(len(beklenen), 20)
        for i, (a, sayfalar) in enumerate(beklenen):
            self.assertIn(sonuc[str(i)]["sayfa"], sayfalar, a[:80])
        self.assertEqual(sonuc[str(len(beklenen) - 1)]["yontem"], "sira_disi")


class Yardimcilar(unittest.TestCase):
    def test_tam_alinti(self):
        als = ["Birinci alıntı burada.", "İkinci alıntı, 27 rakamını taşıyan uzun bir cümle."]
        self.assertEqual(MU.tam_alinti("…27 rakamını taşıyan uzun…", als), als[1])
        self.assertEqual(MU.tam_alinti(als[0], als), als[0])
        self.assertIsNone(MU.tam_alinti("yok", als))
        self.assertIsNone(MU.tam_alinti("…", als))

    def test_bagalanti_pdf_mi_ve_sayfa(self):
        ham = {"kaynak": {"adres": "https://ornek.org/indir?id=7 (kurumun sitesi)"}}
        self.assertTrue(MU.baglanti_pdf_mi("https://a.org/b/RAPOR.PDF", None))
        self.assertTrue(MU.baglanti_pdf_mi("https://a.org/b/x.pdf?v=2", None))
        self.assertTrue(MU.baglanti_pdf_mi("https://ornek.org/indir?id=7", ham), "indirme adresinin kendisi")
        self.assertFalse(MU.baglanti_pdf_mi("https://doi.org/10.1/abc", ham))
        self.assertFalse(MU.baglanti_pdf_mi("", ham))
        self.assertEqual(MU.adres("https://a.org/x.pdf?v=2", 12, None), "https://a.org/x.pdf?v=2#page=12")
        self.assertEqual(MU.adres("https://doi.org/10.1/abc", 12, None), "https://doi.org/10.1/abc")
        self.assertEqual(MU.adres("", 12, ham), "")

    def test_kesit_kurali(self):
        self.assertTrue(MU.kesitli_mi({"RESMI", "KURUMSAL"}))
        self.assertTrue(MU.kesitli_mi({"SATICI"}))
        self.assertTrue(MU.kesitli_mi({"PROJE"}))
        self.assertFalse(MU.kesitli_mi({"RESMI", "HAKEMLI"}), "bir kayıt bile hakemliyse kesit yok")
        self.assertFalse(MU.kesitli_mi({None}))
        self.assertFalse(MU.kesitli_mi(set()))

    def test_kesit_adi(self):
        self.assertTrue(MU.KESIT_ADI.match("fao_2022_sofa-s20-0123456789.webp"))
        self.assertFalse(MU.KESIT_ADI.match("fao_2022_sofa-s20.webp"))
        self.assertFalse(MU.KESIT_ADI.match("fao_2022_sofa-s20-0123456789.png"))


class Kural19(unittest.TestCase):
    """Depodaki makbuz geçiyor; geçici kopyada bozulanlar yakalanıyor."""

    def setUp(self):
        self.D = _modul("dogrula_bolumler_makbuz", "dogrula_bolumler.py")
        self.mu = _modul("makbuz_uret_k19_sina", "makbuz_uret.py")
        self.gecici = Path(tempfile.mkdtemp(prefix="makbuz_k19_"))
        shutil.copy(MU.KAYIT, self.gecici / "makbuz.json")
        shutil.copytree(MU.KESITLER, self.gecici / "makbuz")
        shutil.copy(MU.CIKIS, self.gecici / "yz_makbuz.g.dart")
        self.mu.KAYIT = self.gecici / "makbuz.json"
        self.mu.KESITLER = self.gecici / "makbuz"
        self.mu.CIKIS = self.gecici / "yz_makbuz.g.dart"

    def tearDown(self):
        shutil.rmtree(self.gecici, ignore_errors=True)

    def hatalar(self) -> list[str]:
        self.D.hatalar.clear()
        with redirect_stdout(io.StringIO()):
            self.D.sina_makbuz(mu=self.mu)
        return list(self.D.hatalar)

    def kayit_degistir(self, islev) -> None:
        k = json.loads(self.mu.KAYIT.read_text(encoding="utf-8"))
        islev(k["kayitlar"])
        self.mu.KAYIT.write_text(json.dumps(k, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")

    def test_depodaki_geciyor(self):
        self.assertEqual(self.hatalar(), [])

    def test_kesit_dosyasi_yok(self):
        next(self.mu.KESITLER.iterdir()).unlink()
        self.assertTrue(any("yok — makbuz_uret.py" in h for h in self.hatalar()))

    def test_artik_dosya(self):
        (self.mu.KESITLER / "eski-s1-0000000000.webp").write_bytes(b"RIFF")
        self.assertTrue(any("artık dosya" in h for h in self.hatalar()))

    def test_ad_degismeden_cizim_degisti(self):
        f = sorted(self.mu.KESITLER.iterdir())[0]
        veri = bytearray(f.read_bytes())
        veri[-1] ^= 0xFF
        f.write_bytes(bytes(veri))
        self.assertTrue(any("özetle tutmuyor" in h for h in self.hatalar()))

    def test_hakemli_kaynakta_kesit_yasak(self):
        def bozan(kayitlar):
            hakemli = next(r for r in kayitlar if "HAKEMLI" in r["nitelik"] and r.get("sayfa"))
            kesitli = next(r for r in kayitlar if r.get("kesit"))
            for a in ("kesit", "genislik", "yukseklik", "bayt", "donus"):
                hakemli[a] = kesitli[a]
        self.kayit_degistir(bozan)
        self.assertTrue(any("dışında" in h and "HAKEMLI" in h for h in self.hatalar()))

    def test_eslemede_olmayan_kayit(self):
        self.kayit_degistir(lambda ks: ks.append({**ks[0], "alinti": ks[0]["alinti"] + " (fazla)"}))
        self.assertTrue(any("eşlemede yok" in h for h in self.hatalar()))

    def test_eksik_kayit(self):
        self.kayit_degistir(lambda ks: ks.pop(0))
        self.assertTrue(any("makbuz.json'da yok" in h for h in self.hatalar()))

    def test_dart_eski(self):
        self.mu.CIKIS.write_text(self.mu.CIKIS.read_text(encoding="utf-8") + "// eski\n", encoding="utf-8")
        self.assertTrue(any("eski — dart_uret.py" in h for h in self.hatalar()))

    def test_webp_boyu(self):
        k = json.loads(MU.KAYIT.read_text(encoding="utf-8"))
        r = next(x for x in k["kayitlar"] if x.get("kesit"))
        veri = (MU.KESITLER / Path(r["kesit"]).name).read_bytes()
        self.assertEqual(self.D.webp_boyu(veri), (r["genislik"], r["yukseklik"]))
        self.assertIsNone(self.D.webp_boyu(b"RIFF0000WEBPxxxx"))


if __name__ == "__main__":
    unittest.main(verbosity=1)
