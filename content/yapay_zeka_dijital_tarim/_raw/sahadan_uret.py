#!/usr/bin/env python3
"""Sahadan galerisi — kayıtlar ve Dart kaynağı (25 Kasım 2026).

    python3 -I content/yapay_zeka_dijital_tarim/_raw/sahadan_uret.py

Rapor basar: kare başına harf, kimlik, il (plaka), piksel ve dosya boyu,
başlık içinde de duran kareler ve merkez kartının küçük resimleri. Dart
sabitini `dart_uret.py` yazar (`lib/features/yapay_zeka/data/yz_sahadan.g.dart`,
bu betiğin `dart_kaynagi()`ıyla); `dogrula_bolumler.py` kural 21 kayıtları
dosyalara, `gorseller.json`'a ve metne karşı sınar ve üretilmiş dosyanın
güncel olduğunu denetler.

KAYIT — `_raw/sahadan.json` › `kareler` (sahibin seçtiği sekiz kare, A-H).
Künye fotoğrafın NE OLDUĞUNU söyler (proje ya da sistem, yer, tarih) ve
kaynak sayfadan yazılır; karede görünen tahlil edilmez. Kaynak satırı
"Fotoğraf: <yayımlayan kurum>". Başlık içinde de duran karenin
(`gorseller.json`'da aynı kimlik) dosyası, künyesi ve adresleri ortak: çift
dosya yok, iki kayıt alan alan aynı (kural 21).

  * `il`: atlasta "Fotoğraf" kaydı; boşsa (yeri yazmayan kare) atlasta yok.
    Plaka il ızgarasından (`il_izgarasi.json`).
  * `baslik` + `bolum`: karttaki başlık bağlantısı (`?bolum=` alt başlığa).
  * `merkez`: merkez sayfadaki "Sahadan" kartının küçük resimleri.

Galeri, atlas ve merkez kartı YALNIZ erteli paketten içe aktarır
(test/yz_erteli_test.dart).
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

BURASI = Path(__file__).resolve().parent                  # _raw
KOK = BURASI.parent                                        # content/yapay_zeka_dijital_tarim
DEPO = KOK.parents[1]
KAYIT = BURASI / "sahadan.json"
IZGARA = BURASI / "il_izgarasi.json"
GORSELLER = BURASI / "gorseller.json"
CIKIS = DEPO / "lib/features/yapay_zeka/data/yz_sahadan.g.dart"


def kareler() -> list[dict]:
    return json.loads(KAYIT.read_text(encoding="utf-8"))["kareler"]


def plakalar() -> dict[str, int]:
    """İl adı → plaka (atlasın ızgarası)."""
    return {v["ad"]: int(p) for p, v in json.loads(IZGARA.read_text(encoding="utf-8")).items()}


def metindekiler() -> set[str]:
    """Başlık ya da teknoloji metninde de duran kareler: gorseller.json'daki kimlikler."""
    return set(json.loads(GORSELLER.read_text(encoding="utf-8"))["gorseller"])


def adres(dosya: str) -> str:
    """Sitedeki yol: "web/yz/gorsel/x.webp" → "/yz/gorsel/x.webp"."""
    return "/" + dosya.removeprefix("web/")


def _dizgi(s: str | None) -> str:
    if s is None:
        return "null"
    return json.dumps(s, ensure_ascii=False).replace("$", r"\$")


def dart_kaynagi(k: list[dict] | None = None) -> str:
    """`yz_sahadan.g.dart`ın içeriği (dart_uret.py yazar; kural 21 karşılaştırır)."""
    k = kareler() if k is None else k
    plaka = plakalar()
    metinde = metindekiler()
    d = [
        "// ÜRETİLMİŞ DOSYA — ELLE DEĞİŞTİRİLMEZ.",
        "// Kaynak: content/yapay_zeka_dijital_tarim/_raw/sahadan.json",
        "// Üretici: content/yapay_zeka_dijital_tarim/dart_uret.py (_raw/sahadan_uret.py)",
        "//",
        "// Sahadan galerisi (25 Kasım 2026): Türkiye'de dijital tarımın sahadan",
        "// fotoğrafları, her biri yayımlayan kurumun künyesi ve kaynağıyla. Galeri,",
        "// atlasın \"Fotoğraf\" kayıtları ve merkez kartı buradan. YALNIZ erteli",
        "// paketten içe aktarılır (test/yz_erteli_test.dart).",
        "",
        "class YzSahadanKare {",
        "  const YzSahadanKare({",
        "    required this.harf,",
        "    required this.kimlik,",
        "    required this.adres,",
        "    required this.genislik,",
        "    required this.yukseklik,",
        "    required this.kunyeTr,",
        "    required this.kunyeEn,",
        "    required this.kaynakTr,",
        "    required this.kaynakEn,",
        "    required this.sayfaAdresi,",
        "    required this.tarih,",
        "    required this.baslikNo,",
        "    this.il,",
        "    this.plaka,",
        "    this.bolumTr,",
        "    this.bolumEn,",
        "    this.metinde = false,",
        "    this.merkez = false,",
        "  });",
        "",
        "  /// Sahibin seçimindeki harf (A-H): galerinin sırası.",
        "  final String harf;",
        "  final String kimlik;",
        "",
        "  /// Sitedeki yolu (`/yz/gorsel/…webp`).",
        "  final String adres;",
        "  final int genislik;",
        "  final int yukseklik;",
        "",
        "  /// Fotoğrafın ne olduğu (proje ya da sistem, yer, tarih).",
        "  final String kunyeTr, kunyeEn;",
        "",
        "  /// \"Fotoğraf: <yayımlayan kurum>\".",
        "  final String kaynakTr, kaynakEn;",
        "",
        "  /// Fotoğrafın yayımlandığı sayfa (\"Kaynağı aç\").",
        "  final String sayfaAdresi;",
        "",
        "  /// Kaynak sayfanın tarihi (YYYY-AA-GG).",
        "  final String tarih;",
        "",
        "  /// İlgili başlık ve alt başlığı (`?bolum=`).",
        "  final int baslikNo;",
        "  final String? bolumTr, bolumEn;",
        "",
        "  /// Karenin ili; null ise atlasta yok.",
        "  final String? il;",
        "  final int? plaka;",
        "",
        "  /// Başlık içinde de duruyor (gorseller.json'da aynı kimlik ve dosya).",
        "  final bool metinde;",
        "",
        "  /// Merkez sayfadaki kartın küçük resimlerinden.",
        "  final bool merkez;",
        "",
        "  String kunye(bool en) => en ? kunyeEn : kunyeTr;",
        "  String kaynak(bool en) => en ? kaynakEn : kaynakTr;",
        "  String? bolum(bool en) => en ? bolumEn : bolumTr;",
        "  double get oran => yukseklik == 0 ? 1.5 : genislik / yukseklik;",
        "}",
        "",
        "/// Galerinin sırasıyla (harf).",
        "const List<YzSahadanKare> kYzSahadan = [",
    ]
    for r in k:
        bolum = r.get("bolum") or {}
        il = r.get("il")
        d += [
            "  YzSahadanKare(",
            f"    harf: {_dizgi(r['harf'])},",
            f"    kimlik: {_dizgi(r['kimlik'])},",
            f"    adres: {_dizgi(adres(r['dosya']))},",
            f"    genislik: {int(r['genislik'])},",
            f"    yukseklik: {int(r['yukseklik'])},",
            f"    kunyeTr: {_dizgi(r['kunye']['tr'])},",
            f"    kunyeEn: {_dizgi(r['kunye']['en'])},",
            f"    kaynakTr: {_dizgi(r['kaynak']['tr'])},",
            f"    kaynakEn: {_dizgi(r['kaynak']['en'])},",
            f"    sayfaAdresi: {_dizgi(r['sayfa_adresi'])},",
            f"    tarih: {_dizgi(r['tarih'])},",
            f"    baslikNo: {int(r['baslik'])},",
        ]
        if il:
            if il not in plaka:
                raise SystemExit(f"✗ sahadan.json {r['harf']}: il {il!r} ızgaradaki 81 ilden biri değil")
            d += [f"    il: {_dizgi(il)},", f"    plaka: {plaka[il]},"]
        if bolum.get("tr"):
            d.append(f"    bolumTr: {_dizgi(bolum['tr'])},")
        if bolum.get("en"):
            d.append(f"    bolumEn: {_dizgi(bolum['en'])},")
        if r["kimlik"] in metinde:
            d.append("    metinde: true,")
        if r.get("merkez"):
            d.append("    merkez: true,")
        d.append("  ),")
    d += ["];", ""]
    return "\n".join(d)


def rapor(k: list[dict] | None = None) -> None:
    k = kareler() if k is None else k
    plaka = plakalar()
    metinde = metindekiler()
    toplam = 0
    for r in k:
        yol = DEPO / r["dosya"]
        bayt = yol.stat().st_size if yol.exists() else 0
        toplam += bayt
        il = f"{r['il']} ({plaka.get(r['il'], '?')})" if r.get("il") else "—"
        ek = [x for x, var in (("başlık içinde", r["kimlik"] in metinde), ("merkez", r.get("merkez"))) if var]
        print(f"  {r['harf']} {r['kimlik']:<44} {il:<14} {r['genislik']}×{r['yukseklik']:<5} "
              f"{bayt / 1024:6.1f} KB  §{r['baslik']}{'  · ' + ', '.join(ek) if ek else ''}")
    print(f"{len(k)} kare · {toplam / 1024 / 1024:.2f} MB · ilsiz {sum(1 for r in k if not r.get('il'))}")


def main() -> int:
    rapor()
    return 0


if __name__ == "__main__":
    sys.exit(main())
