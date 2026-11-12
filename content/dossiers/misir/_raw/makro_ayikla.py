#!/usr/bin/env python3
"""FAOSTAT → makro.json — Dünya Bankası'nın YERİNE

NEDEN FAOSTAT. Dünya Bankası API'si dört turda dört farklı davrandı
(zaman aşımı · 502 · tek çağrı açık · hepsi hata). Kaynak kapalı değil
KARARSIZ, ve kararsız kaynağa bağlı rakam dosyaya giremez. FAOSTAT toplu
indirme her turda çalıştı.

PARA BİRİMİ TUZAĞI (Rusya dosyası): FAOSTAT payı iki ayrı elemanla veriyor
— "Share of GDP US$" (6103) ve "Share of GDP Standard Local Currency"
(61570). İkisi AYNI ŞEY DEĞİL ve kur hareketiyle ayrışıyorlar. Burada
US$ tabanı alınıyor ve hangisi olduğu çıktıya YAZILIYOR; iki taban aynı
cümlede karşılaştırılmaz.
"""
from __future__ import annotations
import csv, io, json, pathlib
from collections import defaultdict

KOK = pathlib.Path(__file__).parent
BUGUN = 2026          # bu yıldan SONRASI projeksiyon
ULKE = {59: "misir", 223: "turkiye"}

ISTEK = [
    # 22010 "Value Added (Agriculture)" Mısır ve Türkiye için YOK — ölçüldü.
    # Mevcut olan 22016: ORMANCILIK VE BALIKÇILIK DAHİL. Saf tarım değil ve
    # adı çıktıda öyle duruyor; "tarımın GSYH payı" diye yazılamaz.
    ("makro", "Macro-Statistics_Key_Indicators_E_All_Data_(Normalized).csv",
     {22016: "tarim_ormancilik_balikcilik_katma_deger"},
     {6103: "gsyh_payi_usd", 6110: "deger_usd"}),
    ("makro", "Macro-Statistics_Key_Indicators_E_All_Data_(Normalized).csv",
     {22008: "gsyh"}, {6110: "deger_usd"}),
    ("nufus", "Population_E_All_Data_(Normalized).csv",
     {3010: "nufus"}, {511: "toplam", 551: "kirsal", 561: "kentsel"}),
    ("istihdam", "Employment_Indicators_Agriculture_E_All_Data_(Normalized).csv",
     {21144: "tarim_istihdami"}, None),
]

def oku(dosya, kalemler, elemanlar):
    yol = KOK / "x" / dosya
    cik = defaultdict(lambda: defaultdict(dict))
    birim = {}
    with io.open(yol, encoding="utf-8-sig", newline="") as f:
        oku_ = csv.DictReader(f)
        for r in oku_:
            try:
                ak = int(r["Area Code"])
            except (ValueError, TypeError, KeyError):
                continue
            if ak not in ULKE:
                continue
            ik = r.get("Item Code") or r.get("Indicator Code")
            try:
                ik = int(ik)
            except (ValueError, TypeError):
                continue
            if ik not in kalemler:
                continue
            # CİNSİYET BOYUTU — sessiz dilim hatası burada yakalandı.
            # İstihdam göstergesi aynı ülke-yıl için Total/Male/Female
            # satırları veriyor. Süzülmezse sözlük son geleni tutuyor ve
            # "tarım istihdamı" aslında yalnız kadın istihdamı oluyordu.
            # Hata vermez, makul görünür — §2.2.1'in tam tarifi.
            cins = (r.get("Sex") or "").strip()
            if cins and cins != "Total":
                continue
            if elemanlar is not None:
                try:
                    ek = int(r["Element Code"])
                except (ValueError, TypeError, KeyError):
                    continue
                if ek not in elemanlar:
                    continue
                en = elemanlar[ek]
            else:
                en = (r.get("Element") or "deger").strip()
            v = r.get("Value")
            if v in (None, "", "NA"):
                continue
            try:
                yil = int(r["Year"]); deg = float(v)
            except ValueError:
                continue
            cik[ULKE[ak]][f"{kalemler[ik]}|{en}"][yil] = deg
            birim[f"{kalemler[ik]}|{en}"] = r.get("Unit")
    return cik, birim

def main():
    out = {"_kaynak": "FAOSTAT toplu indirme (Macro-Statistics, Population, Employment)",
           "_cekim": "12 Kasım 2026",
           "_neden": "Dünya Bankası API'si kararsız; makro katman FAOSTAT'tan kuruldu.",
           "_taban_notu": "GSYH payı US$ tabanlı (eleman 6103). Yerel para tabanıyla (61570) AYNI DEĞİL.",
           "_kapsam_notu": ("Katma değer kalemi ORMANCILIK VE BALIKÇILIK DAHİL (22016). "
                            "Saf tarım kalemi (22010) bu iki ülke için FAOSTAT'ta yok."),
           "_projeksiyon_notu": (f"Nüfus serisi FAOSTAT'ta 2100'e kadar gidiyor ve BAYRAK AYIRMIYOR "
                                 f"(1950-2100 arası hepsi 'X' = dış kuruluş rakamı). Tahmin ile "
                                 f"PROJEKSİYON yıla göre ayrıldı: {BUGUN}'den sonrası projeksiyondur "
                                 f"ve ayrı alanda duruyor. 'Mısır'ın nüfusu' cümlesi projeksiyon "
                                 f"yılından kurulamaz."),
           "misir": {}, "turkiye": {}, "_birim": {}, "_ortak_son_yil": {}}
    for _, dosya, kalemler, elemanlar in ISTEK:
        c, b = oku(dosya, kalemler, elemanlar)
        out["_birim"].update(b)
        for u in ("misir", "turkiye"):
            for anahtar, seri in c.get(u, {}).items():
                if not seri:
                    continue
                olculen = {a: v for a, v in seri.items() if a <= BUGUN}
                ileri = {a: v for a, v in seri.items() if a > BUGUN}
                if not olculen:
                    continue
                y = max(olculen)
                out[u][anahtar] = {
                    "son_yil": y, "deger": olculen[y],
                    "seri": {str(a): olculen[a] for a in sorted(olculen)}}
                if ileri:
                    out[u][anahtar]["projeksiyon"] = {
                        "_uyari": "PROJEKSİYON — ölçüm değil, metne giremez",
                        "seri": {str(a): ileri[a] for a in sorted(ileri)}}
    for anahtar in set(out["misir"]) & set(out["turkiye"]):
        o = sorted(set(out["misir"][anahtar]["seri"]) & set(out["turkiye"][anahtar]["seri"]))
        out["_ortak_son_yil"][anahtar] = int(o[-1]) if o else None
    (KOK / "makro.json").write_text(json.dumps(out, ensure_ascii=False, indent=1), encoding="utf-8")

    print(f"{'gösterge':34} {'yıl':>5} {'MISIR':>18} {'TÜRKİYE':>18}")
    print("─" * 80)
    for anahtar in sorted(out["_ortak_son_yil"]):
        y = out["_ortak_son_yil"][anahtar]
        m = out["misir"][anahtar]["seri"].get(str(y))
        t = out["turkiye"][anahtar]["seri"].get(str(y))
        bi = (out["_birim"].get(anahtar) or "")[:10]
        print(f"{anahtar[:34]:34} {y:>5} {m:>18,.1f} {t:>18,.1f}  {bi}")
    print("\n✓ makro.json")

if __name__ == "__main__":
    main()
