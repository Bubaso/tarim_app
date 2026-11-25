#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""TÜRKŞEKER'in kendi iç verileri: personel ve gayrimenkul.
Kaynak: TÜRKŞEKER 2024-2028 Stratejik Plan, Tablo 16-18 ve Tablo 21."""
import json, pathlib, re

KOK = pathlib.Path(__file__).parent
M = (KOK / "kaynak_dosyalari" / "stratejik_plan_2024.txt").read_text(encoding="utf-8")


def sayi(s):
    return int(s.replace(".", ""))


# İÇİNDEKİLER TUZAĞI. Tablo adları belgede iki kez geçiyor: önce
# içindekiler listesinde, sonra tablonun kendisinde. Düz find() ilkini
# buluyor ve boş blok dönüyor — bu betik ilk koşuda tam buna düştü,
# aynı tuzak Tablo 26'da da yaşanmıştı. Listenin bittiği yer nokta
# dizili son satırdan hesaplanıyor; aramalar oradan sonra başlıyor.
_son_dizin = max((M.rfind("....."), 0))
DIZIN_SONU = M.find("\n", _son_dizin) + 1 if _son_dizin else 0


def blok(etiket, uzunluk, baslangic=None):
    k = M.find(etiket, DIZIN_SONU if baslangic is None else baslangic)
    if k < 0:
        raise SystemExit(f"✗ bulunamadı (içindekiler sonrası): {etiket}")
    return M[k:k + uzunluk]


# ── Tablo 17 · 5 yıllık fiili ortalama personel ──────────────────────
yillik = {}
for y, ms, di, mv, top in re.findall(
        r"(20[12]\d)\s+([\d.]{3,6})\s+([\d.]{3,6})\s+([\d.]{3,6})\s+([\d.]{3,6})\s*\n",
        blok("5 Yıllık Perso nel Sayısı", 700)):
    yillik[y] = {"memur_sozlesmeli": sayi(ms), "daimi_isci": sayi(di),
                 "kampanya_mevsimlik": sayi(mv), "toplam": sayi(top)}

# ── Tablo 21 · gayrimenkul ───────────────────────────────────────────
# BLOK TOPLAM SATIRINDA KESİLİYOR. Blok uzun tutulunca bir alttaki
# "Fiziki Kaynaklar" tablosundan iki satır (…2022 ve Lojman 1.346) da
# yutuldu ve toplam 3.368 m² fazla çıktı; tutar denetimi bunu yakaladı.
_gm = blok("Teşekkülün Gayrimenkulleri", 1100)
_son = _gm.find("TOPLAM")
if _son < 0:
    raise SystemExit("✗ gayrimenkul tablosunda TOPLAM satırı yok")
_gm = _gm[:_gm.find("\n", _son) + 1]
gm = {}
for ad, m2 in re.findall(r"^([A-ZÇĞİÖŞÜ][A-Za-zÇĞİÖŞÜçğıöşü ]{2,22})\s+([\d.]{3,12})\s*$",
                         _gm, re.M):
    gm[ad.strip()] = sayi(m2)

d = {
    "_kaynak": "TÜRKŞEKER, 2024-2028 Stratejik Plan — Tablo 17 (s. 49) ve Tablo 21 (s. 50)",
    "_cekim": "2026-11-23",
    "_veri_yili_siniri": ("Stratejik plan 2024-2028 dönemi için hazırlandı; içindeki en yeni "
                          "personel verisi 2022'ye ait. 2023 sonrası personel sayısı taranan "
                          "belgelerde YOK."),
    "personel_yillik": yillik,
    "personel_2022_statu": {"memur": 147, "sozlesmeli": 1088, "daimi_isci": 3551,
                            "kampanya_mevsimlik": 1238, "toplam": 6024,
                            "alt_isverenle_toplam": 10535,
                            "_dayanak": "147 memur, 1.088 sözleşmeli personel, 3.551 daimi işçi ve "
                                        "1.238 geçici işçi olmak üzere toplam 6.024 kişi istihdam "
                                        "edilmiştir. Alt-işverenle birlikte toplam 10.535 kişi"},
    "personel_2022_cinsiyet": {"erkek_yuzde": 91, "kadin_yuzde": 9,
                               "_dayanak": "çalışan personelin %91'i erkek, %9'u kadındır"},
    "gayrimenkul_m2": gm,
}

h = []
if sorted(yillik) != ["2018", "2019", "2020", "2021", "2022"]:
    h.append(f"personel yılları eksik: {sorted(yillik)}")
else:
    for y, v in yillik.items():
        bek = v["memur_sozlesmeli"] + v["daimi_isci"] + v["kampanya_mevsimlik"]
        if bek != v["toplam"]:
            h.append(f"{y} personel toplamı tutmuyor: {bek} ≠ {v['toplam']}")
    d["personel_dusus"] = {
        "_2018": yillik["2018"]["toplam"], "_2019": yillik["2019"]["toplam"],
        "_2022": yillik["2022"]["toplam"],
        "ozellestirme_yili_degisim_yuzde": round(
            (yillik["2019"]["toplam"] / yillik["2018"]["toplam"] - 1) * 100, 1),
        "_2018_2022_degisim_yuzde": round(
            (yillik["2022"]["toplam"] / yillik["2018"]["toplam"] - 1) * 100, 1),
        "_not": ("On fabrikanın özelleştirildiği 2018'in ardından personel bir yılda "
                 "2.076 kişi azaldı. İki olayın aynı yıla düşmesi ölçülmüş bir gerçek; "
                 "nedensellik bu belgelerden okunamaz."),
    }
if "TOPLAM" not in gm:
    h.append("gayrimenkul toplamı okunamadı")
else:
    kalem = {k: v for k, v in gm.items() if k != "TOPLAM"}
    if abs(sum(kalem.values()) - gm["TOPLAM"]) > 2:
        h.append(f"gayrimenkul toplamı tutmuyor: {sum(kalem.values()):,} ≠ {gm['TOPLAM']:,}")
    d["gayrimenkul_ozet"] = {
        "toplam_m2": gm["TOPLAM"], "toplam_km2": round(gm["TOPLAM"] / 1_000_000, 1),
        "yer_sayisi": len(kalem),
        "_serh": ("Liste 2022 tarihli ve özelleştirilen fabrikaların yerlerini de taşıyor "
                  "(Alpullu, Turhal, Uşak…). Bu kalemlerin neden listede durduğu belgede "
                  "AÇIKLANMIYOR; yayına tek başına gerekçe yapılamaz."),
    }
if h:
    raise SystemExit("✗ DOĞRULAMA DÜŞTÜ\n  " + "\n  ".join(h))

(KOK / "kurum.json").write_text(json.dumps(d, ensure_ascii=False, indent=2), encoding="utf-8")

print("  personel (fiili ortalama):")
for y, v in sorted(yillik.items()):
    print(f"    {y}  {v['toplam']:>6,}")
pd = d["personel_dusus"]
print(f"\n  2018→2019: %{pd['ozellestirme_yili_degisim_yuzde']}  (özelleştirme yılı)")
print(f"  2018→2022: %{pd['_2018_2022_degisim_yuzde']}")
print(f"\n  gayrimenkul: {d['gayrimenkul_ozet']['toplam_km2']} km² · "
      f"{d['gayrimenkul_ozet']['yer_sayisi']} yer")
print("\n  ✓ kurum.json yazıldı")
