#!/usr/bin/env python3
"""Sektör raporu Tablo 26 → ciftci.json — pancar eken çiftçi sayısı

NEDEN AYRI: FAOSTAT'ta çiftçi sayısı YOK. Bu kalem yalnız Türkşeker'in
sektör raporunda var ve dosyanın en sert bulgusu orada: üretim yerinde
duruyor, çiftçi sayısı düşüyor.

AYRIŞMA SINANMASI: aynı yılın üretimi iki kaynakta farklı olabiliyor.
2023'te ikisi birebir aynı (25.250.213), 2024'te FAOSTAT 23.000.000 diyor —
sektör raporu 22.413.958. FAOSTAT'ın rakamı FAZLA YUVARLAK ve bayrağı 'A'
olsa da yuvarlaklık tahmin işareti. Türkiye'ye ait idari rakam için sektör
raporu esas alınıyor; fark ölçülüp yazılıyor, gizlenmiyor.
"""
from __future__ import annotations
import json, pathlib, re

KOK = pathlib.Path(__file__).parent
d = re.sub(r"\s+", " ", (KOK / "kaynak_dosyalari" / "sektor_raporu_2025.txt")
           .read_text(encoding="utf-8"))
# İKİ TABLO AYNI BAŞLIĞI TAŞIYOR VE BİRİ ÖTEKİNİN HEMEN ALTINDA:
#   Tablo 26 — Türkiye'DE  (ülke geneli)
#   Tablo 27 — TÜRKŞEKER'in (yalnız kurum)
# İlk yazımda `rfind` kullanıldı ve SON eşleşme alındı; yani ülke tablosu
# diye TÜRKŞEKER tablosu okundu. FAOSTAT karşılaştırması %+200 verince
# yakalandı — tek kaynakla çalışılsaydı sessizce yanlış kalırdı.
# Artık her tablo KENDİ ETİKETİNDEN bulunuyor ve ikisi de saklanıyor.
def tablo(etiket: str) -> str:
    k = d.find(etiket, 90000)          # içindekiler listesini atla
    if k < 0:
        raise SystemExit(f"✗ tablo bulunamadı: {etiket}")
    return d[k:k + 950]

blok = tablo("Tablo 26: Türkiye'de Şeker Pancarı Ekim")
blok_ts = tablo("Tablo 27: TÜRKŞEKER’in Şeker Pancarı Ekim")

sayi = lambda s: float(s.replace(".", "").replace(",", "."))
satir = re.findall(
    r"(20[12]\d)\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)\s+([\d,]+)\s+([\d.]+)", blok)
if len(satir) < 8:
    raise SystemExit(f"✗ yalnız {len(satir)} satır okundu — tablo biçimi değişmiş olabilir")

def coz(b):
    out = {}
    for y, c, a, u, v, f in re.findall(
            r"(20[12]\d)\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)\s+([\d,]+)\s+([\d.]+)", b):
        k = {"ciftci": int(sayi(c)), "alan_dekar": int(sayi(a)),
             "uretim_ton": int(sayi(u)), "verim_ton_dekar": sayi(v),
             "baz_fiyat_tl_ton": int(sayi(f))}
        # ÇÖP SATIR SÜZGECİ. Blokta grafik ekseninin yıl etiketleri de var
        # ("2015 2016 2017 2018 2020") ve kalıp onları satır sanıyordu:
        # çiftçi 2.016, üretim 2.018 gibi. Üç şart birden aranıyor —
        # bir pancar yılında çiftçi binlerle, üretim milyonlarla ölçülür ve
        # üretim çiftçiden büyüktür.
        if k["ciftci"] < 5_000 or k["uretim_ton"] < 1_000_000 \
                or k["uretim_ton"] <= k["ciftci"]:
            continue
        out[y] = k
    return out

kayit = coz(blok)
kayit_ts = coz(blok_ts)
if not kayit_ts:
    raise SystemExit("✗ TÜRKŞEKER tablosu okunamadı")
# İKİ TABLO BİRBİRİNİN AYNISI OLAMAZ — aynıysa yine aynı blok okunmuştur.
if kayit == kayit_ts:
    raise SystemExit("✗ iki tablo birebir aynı çıktı — aynı blok iki kez okundu")

# FAOSTAT ile karşılaştırma — ayrışma gizlenmiyor
fao = json.loads((KOK / "pancar.json").read_text(encoding="utf-8"))["uretim"]
ayrisma = {}
for y, v in kayit.items():
    if y in fao:
        f = fao[y]
        ayrisma[y] = {"sektor_raporu": v["uretim_ton"], "faostat": int(f),
                      "fark_ton": int(f) - v["uretim_ton"],
                      "fark_yuzde": round(100 * (f - v["uretim_ton"]) / v["uretim_ton"], 2)}

yil = sorted(kayit)
zirve = max(kayit, key=lambda k: kayit[k]["ciftci"])
cikti = {
    "_kaynak": "TÜRKŞEKER 2025 Sektör Raporu · Tablo 26",
    "_nitelik": "BİRİNCİL — kurumun kendi yayını",
    "_kapsam": "Türkiye geneli, pancar eken çiftçi sayısı ve ekiliş",
    "_cekim": "23 Kasım 2026",
    "_ayrisma_notu": ("Aynı yılın üretimi FAOSTAT ile sektör raporunda farklı "
                      "olabiliyor. 2023'te ikisi birebir aynı; 2024'te FAOSTAT "
                      "23.000.000 diyor, rapor 22.413.958. FAOSTAT'ın rakamı "
                      "yuvarlak. Türkiye'ye ait idari rakam için rapor esas."),
    "_iki_tablo_notu": ("Tablo 26 ÜLKE geneli, Tablo 27 yalnız TÜRKŞEKER. "
                        "İkisi aynı başlığı taşıyor ve arka arkaya geliyor; "
                        "ilk yazımda karıştırıldı ve FAOSTAT karşılaştırması "
                        "yakaladı."),
    "yillar": kayit,
    "turkseker": kayit_ts,
    "ciftci_zirve_yil": int(zirve),
    "ciftci_zirve": kayit[zirve]["ciftci"],
    "ciftci_son_yil": int(yil[-1]),
    "ciftci_son": kayit[yil[-1]]["ciftci"],
    "ciftci_dusus_yuzde": round(
        100 * (kayit[yil[-1]]["ciftci"] / kayit[zirve]["ciftci"] - 1), 1),
    "faostat_ayrismasi": ayrisma,
}

# ── ÜLKE DÜŞÜŞÜ TÜRKŞEKER'İN DÜŞÜŞÜ DEĞİLDİR ─────────────────────────
# Bu hesap önce tek seferlik bir yamayla ciftci.json'a eklenmişti ve
# çıkarıcı yeniden koşunca SİLİNDİ; build_data.py o yüzden düştü.
# Artık burada, kaynağında duruyor.
_ortak = sorted(set(cikti["yillar"]) & set(cikti["turkseker"]))
if len(_ortak) < 2:
    raise SystemExit("✗ iki tablonun ortak yılı yok")
_ilk, _son = "2017" if "2017" in _ortak else _ortak[0], _ortak[-1]
_u, _t = cikti["yillar"], cikti["turkseker"]
_disi_ilk = _u[_ilk]["ciftci"] - _t[_ilk]["ciftci"]
_disi_son = _u[_son]["ciftci"] - _t[_son]["ciftci"]
if _disi_ilk <= 0 or _disi_son <= 0:
    raise SystemExit("✗ TÜRKŞEKER çiftçisi ülke toplamını aşıyor — tablolar karışmış")
cikti["ciftci_dususu_kimin"] = {
    "_uyari": ("Ülke rakamı ile TÜRKŞEKER rakamı ayrı şeylerdir ve yayında biri "
               "diğerinin yerine yazılamaz. Düşüş iki tarafta da ağırdır."),
    "_karsilastirma_yili": f"{_ilk}-{_son} (iki tablonun ortak aralığı)",
    "ulke_degisim_yuzde": round((_u[_son]["ciftci"] / _u[_ilk]["ciftci"] - 1) * 100, 1),
    "turkseker_degisim_yuzde": round((_t[_son]["ciftci"] / _t[_ilk]["ciftci"] - 1) * 100, 1),
    "turkseker_disi_degisim_yuzde": round((_disi_son / _disi_ilk - 1) * 100, 1),
    "ulke_ilk": _u[_ilk]["ciftci"], "ulke_son": _u[_son]["ciftci"],
    "turkseker_ilk": _t[_ilk]["ciftci"], "turkseker_son": _t[_son]["ciftci"],
    "turkseker_disi_ilk": _disi_ilk, "turkseker_disi_son": _disi_son,
}

(KOK / "ciftci.json").write_text(json.dumps(cikti, ensure_ascii=False, indent=1),
                                 encoding="utf-8")
print(f"Tablo 26 ÜLKE · {len(kayit)} yıl · Tablo 27 TÜRKŞEKER · {len(kayit_ts)} yıl\n")
print(f"  {'yıl':5} {'çiftçi':>9} {'alan (da)':>12} {'üretim (t)':>13} {'fiyat':>7}")
for y in yil:
    k = kayit[y]
    print(f"  {y:5} {k['ciftci']:>9,} {k['alan_dekar']:>12,} "
          f"{k['uretim_ton']:>13,} {k['baz_fiyat_tl_ton']:>7,}")
print(f"\n  çiftçi zirvesi {zirve}: {cikti['ciftci_zirve']:,}")
print(f"  {yil[-1]}: {cikti['ciftci_son']:,}  →  %{cikti['ciftci_dusus_yuzde']}")
print("\n  FAOSTAT ayrışması:")
for y, a in sorted(ayrisma.items()):
    im = "  ✓ aynı" if a["fark_ton"] == 0 else f"  ⚠ %{a['fark_yuzde']:+.2f}"
    print(f"    {y}  rapor {a['sektor_raporu']:>12,}  FAOSTAT {a['faostat']:>12,}{im}")
y2 = sorted(kayit_ts)[-1]
pay = 100 * kayit_ts[y2]["uretim_ton"] / kayit[y2]["uretim_ton"]
print(f"\n  {y2} TÜRKŞEKER payı: {kayit_ts[y2]['uretim_ton']:,} / "
      f"{kayit[y2]['uretim_ton']:,} = %{pay:.1f}")
print("\n✓ ciftci.json")
