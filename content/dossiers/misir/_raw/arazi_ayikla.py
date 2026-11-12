#!/usr/bin/env python3
"""FAOSTAT Arazi Kullanımı → arazi.json (Mısır + Türkiye)

TUZAKLAR — önceki dosyalardan devralındı:
  · FAOSTAT CSV'lerinde HER ALAN TIRNAKLI (Hollanda/Rusya notu).
  · Türkiye FAOSTAT'ta ASYA, Mısır AFRİKA grubunda — ama arazi kullanımı
    dosyası tek ve dünya çapında, bölge ayrımı YOK. Yine de ülke adı değil
    ALAN KODU ile eşleşiliyor: ad yazımı değişebiliyor.
  · "Land area" ile "Country area" aynı şey değil: ilki iç sularsız. Payda
    seçimi metni değiştirir, ikisi de yazılıyor.
  · Boş hücre 0 DEĞİL. Değer yoksa seriye hiç girmiyor.
"""
from __future__ import annotations
import csv, io, json, pathlib

KOK = pathlib.Path(__file__).parent
CSV = KOK / "x" / "Inputs_LandUse_E_All_Data_(Normalized).csv"

ULKE = {59: "misir", 223: "turkiye"}          # FAOSTAT alan kodları
KALEM = {
    6601: "kara_alani",
    6610: "tarim_arazisi",
    6620: "ekili_arazi",            # cropland
    6621: "islenebilir_arazi",      # arable
    6650: "daimi_urun",
    6616: "fiilen_sulanan_kara",
    6611: "fiilen_sulanan_tarim",
    6690: "sulamaya_donatilmis",
}

def main():
    seri = {u: {k: {} for k in KALEM.values()} for u in ULKE.values()}
    birim = {}
    with io.open(CSV, encoding="utf-8-sig", newline="") as f:
        for r in csv.DictReader(f):
            try:
                ak = int(r["Area Code"]); ik = int(r["Item Code"])
            except (ValueError, TypeError):
                continue
            if ak not in ULKE or ik not in KALEM:
                continue
            if r.get("Element") != "Area":
                continue
            v = r.get("Value")
            if v in (None, "", "NA"):
                continue                      # boş hücre sıfır değil
            try:
                yil = int(r["Year"]); deger = float(v)
            except ValueError:
                continue
            seri[ULKE[ak]][KALEM[ik]][yil] = deger
            birim[KALEM[ik]] = r.get("Unit")

    cikti = {
        "_kaynak": "FAOSTAT · Inputs/LandUse · toplu indirme",
        "_cekim": "12 Kasım 2026",
        "_birim": birim,
        "_payda_notu": ("'kara alanı' iç sular HARİÇ. Ülke yüzölçümü değil; "
                        "pay hesabında hangisi kullanıldığı metinde yazılacak."),
        "_bos_notu": "Değeri olmayan yıl seriye GİRMEDİ — sıfır yazılmadı.",
    }
    for u in ULKE.values():
        cikti[u] = {}
        for k in KALEM.values():
            s = seri[u][k]
            if not s:
                cikti[u][k] = None
                continue
            y = max(s)
            cikti[u][k] = {"son_yil": y, "deger": s[y], "seri": {str(a): s[a] for a in sorted(s)}}
    # ortak son yıl (§2.7)
    for k in KALEM.values():
        a, b = cikti["misir"].get(k), cikti["turkiye"].get(k)
        if a and b:
            ortak = sorted(set(a["seri"]) & set(b["seri"]))
            cikti.setdefault("_ortak_son_yil", {})[k] = int(ortak[-1]) if ortak else None
    (KOK / "arazi.json").write_text(json.dumps(cikti, ensure_ascii=False, indent=1), encoding="utf-8")

    print(f"{'kalem':24} {'birim':10} {'MISIR':>16} {'yıl':>6} {'TÜRKİYE':>16} {'yıl':>6}")
    print("─"*84)
    for k in KALEM.values():
        m, t = cikti["misir"][k], cikti["turkiye"][k]
        f = lambda x: f"{x['deger']:,.0f}" if x else "—"
        y = lambda x: str(x["son_yil"]) if x else "—"
        print(f"{k:24} {str(birim.get(k,'')):10} {f(m):>16} {y(m):>6} {f(t):>16} {y(t):>6}")
    print("\n✓ arazi.json")

if __name__ == "__main__":
    main()
