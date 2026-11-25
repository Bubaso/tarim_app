#!/usr/bin/env python3
"""
Yapay Zeka ve Dijital Tarım — rakamın makbuzu (25 Kasım 2026).

    ~/tarim_ai_pipeline/venv/bin/python -I content/yapay_zeka_dijital_tarim/_raw/makbuz_uret.py
    python3 -I content/yapay_zeka_dijital_tarim/_raw/makbuz_uret.py --rapor

Mavi rakamın kaynak balonu (yz_kaynak_balonu.dart) rakamı taşıyan alıntıyı
gösteriyor. Alıntının kaynağının yerel PDF kopyası varsa bu betik alıntının
o PDF'teki SAYFASINI buluyor; kaynak RESMI, KURUMSAL, SATICI ya da PROJE
nitelikliyse o yerin küçük, vurgulu KESİTİNİ de çiziyor:

  · balonda "Kaynağında gör · s. N" → tam ekran görüntüleyici (kesit, künye,
    "s. N", "Belgenin tamamını aç"; bağlantı PDF'se `#page=N` ile);
  · HAKEMLI kaynakta kesit yok (yayıncının sayfası çoğaltılmıyor): balonun
    "Kaynağı aç"ı "Kaynakta aç · s. N" oluyor;
  · sayfası bulunamayan ya da PDF olmayan kaynakta balon değişmiyor.

KESİT KURALI. Bir PDF'in kesiti yalnız o dosyayı anan BÜTÜN kayıtların
(her `*_kaynaklar.json`) niteliği {RESMI, KURUMSAL, SATICI, PROJE} içindeyse
çiziliyor; tek bir kayıt HAKEMLI (ya da niteliksiz) ise o dosyanın hiçbir
alıntısının kesiti yok, yalnız sayfası var.

ÇİFT. Rakam eşlemesinin (rakam_kaynaklari.py › esle) her [kaynak, parça]
adayı, parçanın kayıttaki TAM alıntısına (`parca.strip('…')` alıntının
içinde) ve kaydın `dosya`sına bağlanıyor; (dosya, alıntı) çifti tekil.
Parçası boş aday (alıntısında rakam yok) makbuz almıyor.

ARAMA VE ÇİZİM `makbuz.swift`te (macOS PDFKit): yöntemi ve tuzakları
(characterBounds'un bağ harfinde kayması) orada yazılı. Bu betik:

  1. PDF'lerin SHA-256'sını content/dossiers/_ortak/ham_kaynaklar.json ile
     sınar (PDF git'te değil; tutmayan ya da eksik dosya DURDURUR);
  2. Swift'i çağırır, PNG kesitleri WebP'ye çevirir (Pillow: boru hattının
     sanal ortamı) ve `web/yz/makbuz/` altına yazar; artık dosyaları siler;
  3. `_raw/makbuz.json`u yazar: her çiftin sayfası, yöntemi, kesiti ya da
     bulunamama nedeni.

KESİT ADI `<pdf kökü>-s<sayfa>-<webp'nin sha256'sı[:10]>.webp`. Site webp'yi
bir yıl değişmez (immutable) önbelleğe alıyor (firebase.json): çizim
değişince içerik özeti, dolayısıyla ad da değişiyor; eski ad önbellekte
kalsa da yeni sayfa yeni adı istiyor.

Dart sabitini `dart_uret.py` yazar (`yz_makbuz.g.dart`, bu betiğin
`dart_kaynagi()`ıyla); `dogrula_bolumler.py` kural 19 makbuz.json'u eşlemeye,
kesit dosyalarına ve üretilmiş Dart dosyasına karşı sınar; `--makbuz` ile
Swift aramasını yeniden koşup sayfaları karşılaştırır.
"""
from __future__ import annotations

import hashlib
import importlib.util
import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path

BURASI = Path(__file__).resolve().parent                  # _raw
BOLUM = BURASI.parent                                      # content/yapay_zeka_dijital_tarim
DEPO = BOLUM.parents[1]
KAYIT = BURASI / "makbuz.json"
CIKIS = DEPO / "lib/features/yapay_zeka/data/yz_makbuz.g.dart"
KESITLER = DEPO / "web/yz/makbuz"
HAM = DEPO / "content/dossiers/_ortak/ham_kaynaklar.json"
SWIFT = BURASI / "makbuz.swift"

KESITLI = ("RESMI", "KURUMSAL", "SATICI", "PROJE")
NITELIKLER = ("RESMI", "KURUMSAL", "HAKEMLI", "PROJE", "SATICI")
# Kesitin çizimi: vurgulu satır ~30 piksel boyunda, genişlik en çok 1400
# piksel, vurgunun üstünde ve altında 3 satır. WebP kayıplı, kalite 80.
AYAR = {"satir": 30, "tavan": 1400, "baglam": 3}
WEBP = {"quality": 80, "method": 6}
# Toplam kesit boyutunun üst sınırı (bayt).
TAVAN_BAYT = 12 * 1024 * 1024
KESIT_ADI = re.compile(r"^(?P<kok>[A-Za-z0-9_.-]+)-s(?P<sayfa>\d+)-(?P<ozet>[0-9a-f]{10})\.webp$")


def _modul(ad: str):
    sp = importlib.util.spec_from_file_location(f"{ad}_makbuz", BURASI / f"{ad}.py")
    m = importlib.util.module_from_spec(sp)
    sp.loader.exec_module(m)
    return m


def _alintilar(k: dict) -> list[str]:
    a = k.get("alinti") or []
    return [str(x) for x in ([a] if isinstance(a, str) else a)]


def pdf_mi(dosya: str | None) -> bool:
    return bool(dosya) and str(dosya).lower().endswith(".pdf")


def tam_alinti(parca: str, alintilar: list[str]) -> str | None:
    """Balondaki parçanın (gerekirse "…" ile kısaltılmış) kayıttaki tam alıntısı."""
    cek = parca.strip("…").strip()
    return next((x for x in alintilar if cek and cek in x), None)


def dosya_nitelikleri() -> dict[str, set]:
    """{dosya: o dosyayı anan bütün kayıtların nitelikleri} (her *_kaynaklar.json)."""
    n: dict[str, set] = {}
    for yol in sorted(BURASI.glob("*_kaynaklar.json")):
        kaynaklar = json.loads(yol.read_text(encoding="utf-8")).get("kaynaklar", {})
        for k in kaynaklar.values():
            if isinstance(k, dict) and pdf_mi(k.get("dosya")):
                n.setdefault(k["dosya"], set()).add(k.get("nitelik"))
    return n


def kesitli_mi(nitelikler) -> bool:
    return bool(nitelikler) and all(x in KESITLI for x in nitelikler)


def ciftler(esleme: dict | None = None) -> tuple[dict, list[str]]:
    """({(dosya, alıntı): [(sayfa, dil, kalın, kaynak), …]}, eşlenemeyenler).
    Eşlenemeyen: parçası kaydın hiçbir alıntısında geçmeyen aday (olmamalı)."""
    rk = _modul("rakam_kaynaklari")
    if esleme is None:
        esleme = rk.esle()[0]
    yollar = {s: k for s, _, k in rk.sayfalar()}
    c: dict = {}
    eslenemeyen: list[str] = []
    for sayfa, diller in esleme.items():
        kaynaklar = json.loads(yollar[sayfa].read_text(encoding="utf-8")).get("kaynaklar", {})
        for dil, kalinlar in diller.items():
            for kalin, adaylar in kalinlar.items():
                for a, parca in adaylar:
                    k = kaynaklar.get(a) or {}
                    if not parca or not pdf_mi(k.get("dosya")):
                        continue
                    tam = tam_alinti(parca, _alintilar(k))
                    if tam is None:
                        eslenemeyen.append(f"{sayfa} {dil} «{kalin}» {a}: parça kayıtta yok")
                        continue
                    c.setdefault((k["dosya"], tam), []).append((sayfa, dil, kalin, a))
    return c, eslenemeyen


def ham_ozetler() -> dict[str, dict]:
    """{_raw'a göreli dosya yolu: ham_kaynaklar.json kaydı}."""
    onek = str(BURASI.relative_to(DEPO)) + "/"
    return {d["yol"][len(onek):]: d for d in json.loads(HAM.read_text(encoding="utf-8"))["dosyalar"]
            if d["yol"].startswith(onek)}


def sha256(yol: Path) -> str:
    h = hashlib.sha256()
    with open(yol, "rb") as f:
        for p in iter(lambda: f.read(1 << 20), b""):
            h.update(p)
    return h.hexdigest()


def indirme_adresi(ham: dict | None) -> str:
    """ham_kaynaklar.json'daki indirme adresi (alandaki ilk URL)."""
    m = re.search(r"https?://[^\s<>\"]+", str(((ham or {}).get("kaynak") or {}).get("adres") or ""))
    return m.group(0).rstrip(".,;:)") if m else ""


def baglanti_pdf_mi(baglanti: str, ham: dict | None) -> bool:
    """Bağlantı PDF'in kendisi mi: yolu .pdf ile bitiyor ya da yerel kopyanın
    indirildiği adres. `#page=N` yalnız o zaman ekleniyor."""
    if not baglanti:
        return False
    yol = re.sub(r"[?#].*$", "", baglanti)
    return yol.lower().endswith(".pdf") or baglanti == indirme_adresi(ham)


def adres(baglanti: str, sayfa: int, ham: dict | None) -> str:
    return f"{baglanti}#page={sayfa}" if baglanti_pdf_mi(baglanti, ham) else baglanti


# ── Swift ──────────────────────────────────────────────────────────────────

def swift(isler: list[dict], ayar: dict | None = None) -> list[dict]:
    """makbuz.swift'i koşar; sonuçlar kimlik sırasıyla değil, iş sırasıyla."""
    with tempfile.TemporaryDirectory(prefix="makbuz_is_") as d:
        yol = Path(d) / "is.json"
        yol.write_text(json.dumps({"isler": isler, **(ayar or AYAR)}, ensure_ascii=False), encoding="utf-8")
        c = subprocess.run(["swift", str(SWIFT), str(yol)], capture_output=True, text=True)
    # PDFKit'in attributedString'i her çağrıda bir günlük satırı basıyor.
    hata = "\n".join(s for s in c.stderr.splitlines() if "attributedStringScaled" not in s)
    if c.returncode != 0:
        raise SystemExit(f"makbuz.swift durdu ({c.returncode}): {hata[-2000:]}")
    return json.loads(c.stdout)["sonuclar"]


def is_listesi(cift: list[tuple[str, str]], cikis: dict[tuple[str, str], str] | None = None) -> tuple[list, dict]:
    """(Swift iş listesi, {kimlik: (dosya, alıntı)})."""
    belgeler: dict[str, list] = {}
    kimlik: dict[str, tuple[str, str]] = {}
    for i, (dosya, alinti) in enumerate(cift):
        k = f"a{i}"
        kimlik[k] = (dosya, alinti)
        belgeler.setdefault(dosya, []).append(
            {"kimlik": k, "alinti": alinti, "cikis": (cikis or {}).get((dosya, alinti))})
    return [{"pdf": str(BURASI / d), "alintilar": a} for d, a in belgeler.items()], kimlik


def yeniden_bul(k: dict | None = None) -> dict[tuple[str, str], int | None]:
    """Kural 19'un ağır sınaması: kayıtlardaki her çiftin sayfası, Swift
    aramasıyla yeniden (kesit çizilmeden)."""
    k = k or kayitlar()
    cift = [(r["dosya"], r["alinti"]) for r in k["kayitlar"]]
    isler, kimlik = is_listesi(cift)
    return {kimlik[s["kimlik"]]: s["sayfa"] for s in swift(isler)}


# ── Üretim ─────────────────────────────────────────────────────────────────

def _webp(png: Path) -> bytes:
    from io import BytesIO

    from PIL import Image  # tembel: dart_uret.py ve doğrulayıcı Pillow'suz koşuyor

    with Image.open(png) as im:
        b = BytesIO()
        im.convert("RGB").save(b, "WEBP", **WEBP)
    return b.getvalue()


def uret() -> dict:
    cift_haritasi, eslenemeyen = ciftler()
    if eslenemeyen:
        raise SystemExit("eşlenemeyen parça: " + "; ".join(eslenemeyen))
    cift = sorted(cift_haritasi)
    nitelik = dosya_nitelikleri()
    ham = ham_ozetler()
    # 1. Yerel kopyalar kayıtlı ve değişmemiş.
    ozet: dict[str, str] = {}
    for dosya in sorted({d for d, _ in cift}):
        yol = BURASI / dosya
        if dosya not in ham:
            raise SystemExit(f"{dosya} ham_kaynaklar.json'da kayıtlı değil")
        if not yol.exists():
            raise SystemExit(f"{dosya} diskte yok — yerel kopya olmadan makbuz üretilmez")
        ozet[dosya] = sha256(yol)
        if ozet[dosya] != ham[dosya]["sha256"]:
            raise SystemExit(f"{dosya} SHA-256 tutmuyor: {ozet[dosya][:12]}… ≠ {ham[dosya]['sha256'][:12]}…")
    # 2. Arama ve çizim.
    KESITLER.mkdir(parents=True, exist_ok=True)
    kayit: list[dict] = []
    yazilan: set[str] = set()
    with tempfile.TemporaryDirectory(prefix="makbuz_png_") as gecici:
        cikis = {c: str(Path(gecici) / f"a{i}.png") for i, c in enumerate(cift)
                 if kesitli_mi(nitelik.get(c[0]))}
        isler, kimlik = is_listesi(cift, cikis)
        for s in swift(isler):
            dosya, alinti = kimlik[s["kimlik"]]
            r = {"dosya": dosya, "sha256": ozet[dosya], "alinti": alinti,
                 "nitelik": sorted(x for x in nitelik.get(dosya, set()) if x),
                 "sayfa": s["sayfa"], "sayfa_sayisi": s.get("sayfa_sayisi"),
                 "yontem": s["yontem"], "kapsama": s["kapsama"], "kesit": None}
            if s.get("kesit"):
                veri = _webp(Path(cikis[(dosya, alinti)]))
                ad = f"{Path(dosya).stem}-s{s['sayfa']}-{hashlib.sha256(veri).hexdigest()[:10]}.webp"
                (KESITLER / ad).write_bytes(veri)
                yazilan.add(ad)
                r["kesit"] = f"web/yz/makbuz/{ad}"
                r.update(genislik=s["kesit"]["genislik"], yukseklik=s["kesit"]["yukseklik"],
                         bayt=len(veri), donus=s["kesit"]["donus"])
            if s.get("neden"):
                r["neden"] = s["neden"]
            kayit.append(r)
    for f in KESITLER.iterdir():
        if f.name not in yazilan:
            f.unlink()
    k = {
        "_ne": "Rakamın makbuzu: rakamı taşıyan alıntının yerel PDF kopyasındaki sayfası ve "
               "(resmî, kurumsal, satıcı, proje kaynağında) vurgulu kesiti.",
        "_uretici": "content/yapay_zeka_dijital_tarim/_raw/makbuz_uret.py (makbuz.swift)",
        "ayar": {**AYAR, "webp": WEBP},
        "kayitlar": kayit,
    }
    KAYIT.write_text(json.dumps(k, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    return k


def kayitlar() -> dict:
    return json.loads(KAYIT.read_text(encoding="utf-8"))


# ── Dart ───────────────────────────────────────────────────────────────────

def _dizgi(s: str | None) -> str:
    if s is None:
        return "null"
    return json.dumps(s, ensure_ascii=False).replace("$", r"\$")


def dart_verisi(k: dict | None = None) -> tuple[list[tuple], dict]:
    """(tekil makbuzlar [(sayfa, kesit adresi | None, genişlik, yükseklik, adres)],
    sıra haritası {"sayfa:dil": {kalın: {kaynak: i}}})."""
    k = k or kayitlar()
    rk = _modul("rakam_kaynaklari")
    esleme, kunyeler, _ = rk.esle()
    yollar = {s: y for s, _, y in rk.sayfalar()}
    ham = ham_ozetler()
    bul = {(r["dosya"], r["alinti"]): r for r in k["kayitlar"]}
    tekil: list[tuple] = []
    sira: dict[tuple, int] = {}
    harita: dict = {}
    for sayfa, diller in esleme.items():
        kaynaklar = json.loads(yollar[sayfa].read_text(encoding="utf-8")).get("kaynaklar", {})
        for dil, kalinlar in diller.items():
            for kalin, adaylar in kalinlar.items():
                for a, parca in adaylar:
                    kay = kaynaklar.get(a) or {}
                    if not parca or not pdf_mi(kay.get("dosya")):
                        continue
                    r = bul.get((kay["dosya"], tam_alinti(parca, _alintilar(kay))))
                    if r is None or not r.get("sayfa"):
                        continue
                    kesit = "/" + r["kesit"].removeprefix("web/") if r.get("kesit") else None
                    m = (r["sayfa"], kesit, r.get("genislik", 0) if kesit else 0,
                         r.get("yukseklik", 0) if kesit else 0,
                         adres(kunyeler[sayfa][a][1], r["sayfa"], ham.get(kay["dosya"])))
                    if m not in sira:
                        sira[m] = len(tekil)
                        tekil.append(m)
                    harita.setdefault(f"{sayfa}:{dil}", {}).setdefault(kalin, {})[a] = sira[m]
    return tekil, harita


def dart_kaynagi(k: dict | None = None) -> str:
    """`yz_makbuz.g.dart`ın içeriği (dart_uret.py yazar; kural 19 karşılaştırır)."""
    tekil, harita = dart_verisi(k)
    d = [
        "// ÜRETİLMİŞ DOSYA — ELLE DEĞİŞTİRİLMEZ.",
        "// Kaynak: content/yapay_zeka_dijital_tarim/_raw/makbuz.json + rakam eşlemesi",
        "// Üretici: content/yapay_zeka_dijital_tarim/dart_uret.py (_raw/makbuz_uret.py)",
        "//",
        "// Rakamın makbuzu: mavi rakamı taşıyan alıntının yerel PDF kopyasındaki",
        "// sayfası ve (resmî, kurumsal, satıcı, proje kaynağında) vurgulu kesiti.",
        "// YALNIZ erteli paketten içe aktarılır (test/yz_erteli_test.dart).",
        "",
        "class YzMakbuz {",
        "  const YzMakbuz(this.sayfa, this.kesit, this.genislik, this.yukseklik, this.adres);",
        "",
        "  /// Alıntının PDF'teki sayfası (1'den; PDF'in kendi sırası).",
        "  final int sayfa;",
        "",
        "  /// Vurgulu kesit (`/yz/makbuz/….webp`); hakemli kaynakta null.",
        "  final String? kesit;",
        "",
        "  /// Kesitin piksel boyu (kesit yoksa 0).",
        "  final int genislik;",
        "  final int yukseklik;",
        "",
        "  /// Belgenin bağlantısı; bağlantı PDF'in kendisiyse sonunda `#page=N`.",
        "  /// Kaydın bağlantısı yoksa boş.",
        "  final String adres;",
        "}",
        "",
        "const List<YzMakbuz> kYzMakbuzlar = [",
    ]
    for s, kesit, g, y, a in tekil:
        d.append(f"  YzMakbuz({s}, {_dizgi(kesit)}, {g}, {y}, {_dizgi(a)}),")
    d += [
        "];",
        "",
        "/// {\"sayfa:dil\": {kalın rakam: {kaynak: kYzMakbuzlar sırası}}}",
        "const Map<String, Map<String, Map<String, int>>> kYzMakbuzSirasi = {",
    ]
    for sd, kalinlar in harita.items():
        d.append(f"  {_dizgi(sd)}: {{")
        for kalin, kaynaklar in kalinlar.items():
            ic = ", ".join(f"{_dizgi(a)}: {i}" for a, i in kaynaklar.items())
            d.append(f"    {_dizgi(kalin)}: {{{ic}}},")
        d.append("  },")
    d += ["};", ""]
    return "\n".join(d)


# ── Rapor ──────────────────────────────────────────────────────────────────

def ozet(k: dict | None = None) -> dict:
    """Kapsama: çift ve (sayfa, kaynak, parça) üçlüsü başına, niteliğe göre."""
    k = k or kayitlar()
    sonuc = {"cift": len(k["kayitlar"]), "sayfa": 0, "kesit": 0, "bayt": 0, "nitelik": {}}
    for r in k["kayitlar"]:
        n = "/".join(r["nitelik"]) or "?"
        x = sonuc["nitelik"].setdefault(n, {"cift": 0, "sayfa": 0, "kesit": 0})
        x["cift"] += 1
        if r.get("sayfa"):
            x["sayfa"] += 1
            sonuc["sayfa"] += 1
        if r.get("kesit"):
            x["kesit"] += 1
            sonuc["kesit"] += 1
            sonuc["bayt"] += r["bayt"]
    return sonuc


def rapor(k: dict | None = None) -> None:
    k = k or kayitlar()
    o = ozet(k)
    print(f"Çift (dosya, alıntı): {o['cift']} · sayfası bulunan {o['sayfa']} · kesitli {o['kesit']}")
    print(f"Kesitlerin toplamı: {o['bayt'] / 1024 / 1024:.2f} MB (tavan {TAVAN_BAYT / 1024 / 1024:.0f} MB)")
    print("Niteliğe göre (çift / sayfa / kesit):")
    for n, x in sorted(o["nitelik"].items()):
        print(f"  {n:<18} {x['cift']:>4} {x['sayfa']:>5} {x['kesit']:>6}")
    yon: dict[str, int] = {}
    for r in k["kayitlar"]:
        yon[r.get("yontem") or "bulunamadı"] = yon.get(r.get("yontem") or "bulunamadı", 0) + 1
    print("Yöntem: " + ", ".join(f"{a} {b}" for a, b in sorted(yon.items())))
    for r in k["kayitlar"]:
        if r.get("yontem") == "parca" and r["kapsama"] < 1:
            print(f"  · parça ({r['kapsama']:.2f}): {Path(r['dosya']).name} s. {r['sayfa']} — {r['alinti'][:70]}")
    for r in k["kayitlar"]:
        if not r.get("sayfa"):
            print(f"  ✗ sayfa yok: {Path(r['dosya']).name} — {r.get('neden')} — {r['alinti'][:70]}")
    if o["bayt"] > TAVAN_BAYT:
        print(f"  ✗ kesitler {TAVAN_BAYT / 1024 / 1024:.0f} MB tavanını aşıyor")


def main() -> int:
    if "--rapor" in sys.argv[1:]:
        rapor()
        return 0
    k = uret()
    rapor(k)
    return 1 if ozet(k)["bayt"] > TAVAN_BAYT else 0


if __name__ == "__main__":
    sys.exit(main())
