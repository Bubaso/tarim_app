#!/usr/bin/env python3
"""
Yapay Zeka ve Dijital Tarım — metindeki her kalın rakamın kaynağı (karar 58,
etkileşim: "rakamdan kaynağa").

    python3 -I rakam_kaynaklari.py           # kapsama özeti
    python3 -I rakam_kaynaklari.py b07 tr    # bir sayfanın eşlemesi

Okur bir rakama dokununca o rakamın geldiği kaynağın künyesi, belgeden
birebir alıntısı ve bağlantısı açılıyor. Doğrulayıcı (dogrula_bolumler.py,
kural 1) her rakamın kaydın BÜTÜNÜNDEN türetilebildiğini sınıyor; bu betik
bir adım ileri gidip rakamı TEK TEK KAYNAĞA bağlıyor:

  · kalın parçanın bütün sayıları aynı kaynağın sayılarından türetilebiliyorsa
    o kaynak aday; hiçbiri hepsini karşılamıyorsa en az birini karşılayanlar;
  · adaylar, rakamı alıntısında birebir taşıyanlar önce gelecek biçimde
    sıralanıyor, en çok üçü gösteriliyor;
  · balondaki alıntı, rakamı taşıyan alıntı parçası (yoksa boş).

Eşleme `dart_uret.py` ile `yz_rakam_kaynaklari.g.dart`'a gömülüyor.
Sayfa kimliği: başlık için "bNN", teknoloji sayfası için "tek_<kod>".
"""
from __future__ import annotations

import importlib.util
import json
import re
import sys
from pathlib import Path

BURASI = Path(__file__).resolve().parent
BOLUMLER = BURASI.parent / "bolumler"
TEKNOLOJILER = BURASI.parent / "teknolojiler"

_spec = importlib.util.spec_from_file_location("dogrula_bolumler", BURASI / "dogrula_bolumler.py")
D = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(D)

KALIN = re.compile(r"\*\*(.+?)\*\*")
EN_COK = 3
ALINTI_UZUNLUGU = 320


def sayfalar() -> list[tuple[str, dict[str, Path], Path]]:
    """(sayfa kimliği, {dil: md}, kayıt yolu)"""
    cikti = []
    for tr in sorted(BOLUMLER.glob("[0-2][0-9]-*.tr.md")):
        no = tr.name[:2]
        if no in ("29", "30"):
            continue
        cikti.append((f"b{no}", {"tr": tr, "en": tr.with_name(tr.name.replace(".tr.md", ".en.md"))},
                      BURASI / f"b{no}_kaynaklar.json"))
    for tr in sorted(TEKNOLOJILER.glob("*.tr.md")):
        kod = tr.name.split(".")[0]
        cikti.append((f"tek_{kod}", {"tr": tr, "en": tr.with_name(f"{kod}.en.md")},
                      BURASI / f"tek_{kod}_kaynaklar.json"))
    return cikti


def _bicimler(deger: float) -> list[str]:
    """Rakamın alıntıda arama biçimleri: 86.93 / 86,93 / 1,234 / 1.234 / 1234."""
    if deger == int(deger):
        n = int(deger)
        cikti = [str(n)]
        if n >= 1000:
            cikti += [f"{n:,}", f"{n:,}".replace(",", ".")]
        return cikti
    s = repr(deger).rstrip("0").rstrip(".")
    return [s, s.replace(".", ",")]


YUZDE = re.compile(r"^\s?(%|percent|per cent|yüzde)", re.I)


def _alinti_parcasi(alintilar: list[str], degerler: list[float], yuzde: bool) -> tuple[str, int]:
    """(alıntı parçası, güç). Güç 2: yüzde rakamı alıntıda da yüzdeyle
    ("72 percent", "%72", "yüzde 72"); 1: rakam düz geçiyor; 0: geçmiyor.
    Dipnot işareti ("(1)") ve yıl içindeki rakam eşleşme sayılmıyor."""
    en_iyi, guc = "", 0
    for a in alintilar:
        for d in degerler:
            for b in _bicimler(d):
                for m in re.finditer(rf"(?<![\d.,(]){re.escape(b)}(?![\d)])", a):
                    g = 1
                    if yuzde and (YUZDE.match(a[m.end():]) or a[max(0, m.start() - 7):m.start()].rstrip().lower().endswith(("%", "yüzde"))):
                        g = 2
                    if g > guc:
                        if len(a) <= ALINTI_UZUNLUGU:
                            parca = a
                        else:
                            bas = max(0, m.start() - ALINTI_UZUNLUGU // 2)
                            son = min(len(a), bas + ALINTI_UZUNLUGU)
                            parca = ("…" if bas > 0 else "") + a[bas:son].strip() + ("…" if son < len(a) else "")
                        en_iyi, guc = parca, g
                    if guc == 2:
                        return en_iyi, guc
    return en_iyi, guc


def kunye_kisa(k: dict) -> str:
    return (k.get("kunye") or "").strip()


def baglanti(k: dict) -> str:
    if k.get("doi"):
        return f"https://doi.org/{k['doi']}"
    m = re.search(r"https?://[^\s<>\"]+", str(k.get("adres") or ""))
    return m.group(0).rstrip(".,;:)") if m else ""


def esle() -> tuple[dict, dict, dict]:
    """(eşleme {sayfa: {dil: {kalın: [[anahtar, alıntı], …]}}},
        künyeler {sayfa: {anahtar: [künye, bağlantı]}},
        kapsama {sayfa: (eşlenen, toplam)})"""
    esleme: dict = {}
    kunyeler: dict = {}
    kapsama: dict = {}
    for sayfa, dosyalar, kayit_yolu in sayfalar():
        if not kayit_yolu.exists():
            continue
        kaynaklar = json.loads(kayit_yolu.read_text(encoding="utf-8")).get("kaynaklar", {})
        havuzlar = {a: D.kayit_sayilari({x: y for x, y in k.items() if x != "kunye"})
                    for a, k in kaynaklar.items() if isinstance(k, dict)}
        esleme[sayfa] = {}
        kullanilan: set[str] = set()
        es, top = 0, 0
        for dil, md in dosyalar.items():
            if not md.exists():
                continue
            esleme[sayfa][dil] = {}
            for m in KALIN.finditer(md.read_text(encoding="utf-8")):
                kalin = m.group(1)
                sayilar = D.metin_sayilari(kalin, dil)
                if not sayilar or kalin in esleme[sayfa][dil]:
                    continue
                top += 1
                hepsi = [a for a, h in havuzlar.items()
                         if all(D.izlenir(v, b, h) for v, b, _ in sayilar)]
                adaylar = hepsi or [a for a, h in havuzlar.items()
                                    if any(D.izlenir(v, b, h) for v, b, _ in sayilar)]
                if not adaylar:
                    continue
                degerler = [v for v, _, _ in sayilar]
                yuzde = "%" in kalin
                secim = []
                for a in adaylar:
                    alintilar = kaynaklar[a].get("alinti") or []
                    alintilar = [alintilar] if isinstance(alintilar, str) else alintilar
                    parca, guc = _alinti_parcasi([str(x) for x in alintilar], degerler, yuzde)
                    secim.append((a, parca, guc))
                # En güçlü eşleşme varsa yalnız o güçtekiler kalır: doğru kaynak
                # dururken zayıf adaylar (aynı rakam başka anlamda) gösterilmez.
                en_guclu = max(g for _, _, g in secim)
                secim = [s for s in secim if s[2] == en_guclu]
                secim.sort(key=lambda x: list(kaynaklar).index(x[0]))
                esleme[sayfa][dil][kalin] = [[a, p] for a, p, _ in secim[:EN_COK]]
                kullanilan.update(a for a, _, _ in secim[:EN_COK])
                es += 1
        kunyeler[sayfa] = {a: [kunye_kisa(kaynaklar[a]), baglanti(kaynaklar[a])] for a in sorted(kullanilan)}
        kapsama[sayfa] = (es, top)
    return esleme, kunyeler, kapsama


def main() -> int:
    esleme, kunyeler, kapsama = esle()
    if len(sys.argv) > 2:
        print(json.dumps(esleme.get(sys.argv[1], {}).get(sys.argv[2], {}), ensure_ascii=False, indent=1))
        return 0
    es = sum(e for e, _ in kapsama.values())
    top = sum(t for _, t in kapsama.values())
    for s, (e, t) in sorted(kapsama.items()):
        if e < t:
            print(f"  {s}: {e}/{t}")
    print(f"✓ {es}/{top} kalın rakam bir kaynağa bağlandı ({len(kapsama)} sayfa)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
