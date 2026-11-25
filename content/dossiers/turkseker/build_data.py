#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Türkşeker — Kurum Dosyası Sayı 07 · kilitli veri katmanı.

_raw/ altındaki yedi çıkarımı tek data.json'da topluyor. Her çıkarım kendi
doğrulamasını zaten geçti; burada ARALARINDAKİ tutarlılık sınanıyor. Bir
sınama düşerse data.json YAZILMAZ — yarım veri yayına sızmasın.
"""
import json, pathlib
from decimal import Decimal, ROUND_HALF_UP

KOK = pathlib.Path(__file__).parent
RAW = KOK / "_raw"


def oku(ad):
    return json.loads((RAW / ad).read_text(encoding="utf-8"))


def yuvarla(x, basamak=1):
    """Python'un round()'u bankacı yuvarlaması yapıyor: round(1224.5)=1224.
    Yayına giden rakam okurun beklediği gibi yuvarlanmalı (§8.10/3)."""
    q = Decimal(1).scaleb(-basamak)
    return float(Decimal(str(x)).quantize(q, rounding=ROUND_HALF_UP))


tarih, kota, pancar = oku("tarih.json"), oku("kota.json"), oku("pancar.json")
seker, ciftci = oku("seker.json"), oku("ciftci.json")
kurum, ticaret = oku("kurum.json"), oku("ticaret.json")

SON = "2025"          # sektör raporunun son pazarlama yılı
PANCAR_SON = "2024"   # FAOSTAT'ın son yılı

d = {
    "_dosya": "Türkşeker — Kurum Dosyası Sayı 07",
    "_kural": ("KİLİTLİ KATMAN. Metindeki her rakam buradan okunur; metne elle "
               "rakam yazılmaz. Kaynaklar _raw/ altındaki çıkarımlar, onlar da "
               "kurumun kendi belgelerine ve FAOSTAT/USDA'ya bağlı."),
    "_uretim": "build_data.py · 2026-11-23",

    "kimlik": {
        "ilk_seker_tarihi": tarih["ilk_seker"]["tarih"],
        "ilk_seker_yeri": tarih["ilk_seker"]["yer"],
        "yuzuncu_yil": tarih["ilk_seker"]["yuzuncu_yil"],
        "sirket_kurulus": "6 Temmuz 1935",
        "sirket_kurulus_sermaye_tl": 22_000_000,
        "fabrika_1990_oncesi": tarih["fabrika_sayisi"]["1990_oncesi_turkseker"],
        "fabrika_bugun": tarih["fabrika_sayisi"]["2025_26_turkseker"],
        "_sermaye_dayanak": "22 milyon TL sermayeli Türkiye Şeker Fabrikaları A.Ş.",
    },

    "tarih": {"maddeler": tarih["maddeler"], "_yontem": tarih["_yontem"]},

    "kota": {
        "yil": "2025/26",
        "pancar_sekeri_toplam_ton": 2_837_250,
        "ulke_toplam_ton": 2_910_000,
        "uc_kesim_yuzde": kota["uc_kesim_yuzde"],
        "turkseker_a_kotasi_ton": 1_023_820,
        "alpullu": kota["alpullu"],
        "sirketler": kota["pancar_sekeri_2025_26"]["sirketler"],
        "nbs_seyri": kota["nbs_kotasi_seyri"],
        "nbs_dusus": kota["nbs_dusus"],
        "nbs_sirketler": kota["nbs_2025_26"]["sirketler"],
    },

    "pancar": {
        "ilk_yil": pancar["ilk_yil"], "son_yil": pancar["son_yil"],
        "verim_ilk": pancar["verim"][str(pancar["ilk_yil"])],
        "verim_son": pancar["verim"][PANCAR_SON],
        "verim_artis_yuzde": yuvarla(
            (pancar["verim"][PANCAR_SON] / pancar["verim"][str(pancar["ilk_yil"])] - 1) * 100, 0),
        "uretim": pancar["uretim"], "alan": pancar["alan"], "verim": pancar["verim"],
        "_seri_siniri": ("FAOSTAT 1961'de başlıyor. İlk Türk şekeri 1926'da üretildi; "
                         "yüzyılın ilk otuz beş yılı taranan hiçbir kaynakta sayı olarak YOK."),
    },

    "seker": {
        "yil": seker["kesin_son_yil"],
        "uretim_bin_ton": seker["turkiye"]["uretim"],
        "pancar_sekeri_bin_ton": seker["turkiye"]["pancar_sekeri"],
        "kamis_sekeri_bin_ton": seker["turkiye"]["kamis_sekeri"],
        "tuketim_bin_ton": seker["turkiye"]["tuketim"],
        "ithalat_bin_ton": seker["turkiye"]["ithalat"],
        "ihracat_bin_ton": seker["turkiye"]["ihracat"],
        "stok_bin_ton": seker["turkiye"]["stok"],
        "dunya_toplam_bin_ton": seker["dunya_pancar_sekeri"],
        "dunya_ilk_10": seker["pancar_ilk_10"],
        "turkiye_sirasi": seker["turkiye_pancar_sirasi"],
    },

    "ciftci": {
        "zirve_yil": str(ciftci["ciftci_zirve_yil"]),
        "zirve_sayi": ciftci["yillar"][str(ciftci["ciftci_zirve_yil"])]["ciftci"],
        "son_yil": SON, "son_sayi": ciftci["yillar"][SON]["ciftci"],
        "ulke": ciftci["yillar"], "turkseker": ciftci["turkseker"],
        "dusus": ciftci["ciftci_dususu_kimin"],
    },

    "kurum": {
        "personel_yillik": kurum["personel_yillik"],
        "personel_dusus": kurum["personel_dusus"],
        "personel_2022": kurum["personel_2022_statu"],
        "cinsiyet": kurum["personel_2022_cinsiyet"],
        "_veri_yili_siniri": kurum["_veri_yili_siniri"],
    },

    "ticaret": {"yillar": ticaret["yillar"], "ithalat_dalgasi": ticaret["ithalat_dalgasi"],
                "nbs": ticaret["nbs_disa_donuk"]},
}

# ── METİN DAYANAKLARI ───────────────────────────────────────────────
# Metinde geçen ama yukarıdaki bloklarda ÖLÇÜM olarak yer almayan
# rakamlar. Hepsi kurumun kendi belgelerinden birebir alındı ve buraya
# yazıldı ki sayı izi denetimi (dogrula_metin.py kural 2) onları
# bulabilsin. Burada olmayan bir rakam metne giremez.
d["metin_dayanaklari"] = {
    "_kaynak": "TÜRKŞEKER · Şeker Sektör Raporu 2025 ve 2024-2028 Stratejik Plan",
    "ankara_kastamonu_yerli_imalat_yuzde": 65,
    "afyon_elbistan_yerli_imalat_yuzde": 95,
    "turkseker_2002_03_pay_yuzde": 74,
    "kapasite_2018_bin_ton": 1176,
    "kapasite_2023_bin_ton": 1235,
    "kapasite_artis_esigi_yuzde": 90,
    "turkseker_b_kotasi_ton": 51_191,
    "avans_orani_yuzde": 35,
    "pancar_sekeri_ihtiyac_payi_yuzde": 95,
    "nbs_ihtiyac_payi_yuzde": 5,
    "konya_ekim_alani_yuzde": 26,
    "konya_uretim_yuzde_alt": 30,
    "konya_uretim_yuzde_ust": 33,
    "eskisehir_uretim_yuzde_alt": 7,
    "eskisehir_uretim_yuzde_ust": 9,
    "pancar_oksijen_kat": 3,
    "biyoetanol_hibrit_yuzde": 85,
    "biyoetanol_emisyon_azaltma_yuzde": 74,
    "melas_2020_ton": 31_200,
    "alkol_2020_bin_litre": 8_957,
    "melas_2023_ton": 5_660,
    "alkol_2023_bin_litre": 1_556,
    "personel_lisans_yuzde": 15.26,
    "personel_lisansustu_yuzde": 2.63,
    "personel_lise_yuzde": 53.61,
    "usak_sirket_sermaye_tl": 600_000,
    "istanbul_trakya_sermaye_tl": 500_000,
    "iki_sirket_sermaye_toplam_tl": 1_100_000,
    "ab_kota_kaldirma_yili": 2017,
    # Metinde yuvarlak yazılan verim. Ölçüm pancar bloğunda tam duruyor
    # (22.073 ve 70.925 kg/ha); okur için ton/hektara yuvarlanıyor.
    "verim_1961_ton_hektar": 22,
    "verim_2024_ton_hektar": 71,
}

# ── TÜRETİLMİŞ ─────────────────────────────────────────────────────
# Çiziciler kayıt LİSTESİ istiyor (@turetilmis.<ad>, x/y alan adlarıyla).
# Sözlükten listeye çevirme burada bir kez yapılıyor ki grafikler.json
# ham veriyi yeniden düzenlemek zorunda kalmasın.
uc = d["kota"]["uc_kesim_yuzde"]
sir = d["kota"]["sirketler"]
sayi_kamu, sayi_koop, sayi_ozel = 1, 3, 11   # ŞİRKET sayısı (fabrika değil)
toplam_sirket = sayi_kamu + sayi_koop + sayi_ozel

d["turetilmis"] = {
    "_ne": "Çizici kayıt listeleri. Hepsi yukarıdaki bloklardan türetildi.",

    "verim_kayitlari": [{"yil": int(y), "verim": v}
                        for y, v in sorted(d["pancar"]["verim"].items())],

    "ciftci_kayitlari": [
        {"yil": int(y), "ulke": d["ciftci"]["ulke"][y]["ciftci"],
         "turkseker": d["ciftci"]["turkseker"][y]["ciftci"],
         "uretim": d["ciftci"]["ulke"][y]["uretim_ton"]}
        for y in sorted(set(d["ciftci"]["ulke"]) & set(d["ciftci"]["turkseker"]))],

    "nbs_kayitlari": [{"yil": int(y), "kota": v["nbs_bin_ton"], "pay": v["nbs_pay_yuzde"]}
                      for y, v in sorted(d["kota"]["nbs_seyri"].items())],

    "ithalat_kayitlari": [{"yil": int(y), "kristal": v["kristal_seker_ithalat_ton"],
                           "nbs_ihracat": v["nbs_ihracat_ton"]}
                          for y, v in sorted(d["ticaret"]["yillar"].items())],

    # Kesim payları: ŞİRKET sayısı ↔ KOTA payı. İki ölçü, aynı satırda.
    # İKİ ONDALIK. Bir ondalığa yuvarlanıp iki ondalıkla çizilince
    # 1/15 = %6,67 ekranda "%6,70" görünüyordu — önizlemede yakalandı.
    # Satırdaki iki değer aynı duyarlıkta olmak zorunda: kota payı
    # kaynakta iki ondalıklı.
    "kesimler": [
        {"ad": "kamu", "sirket_yuzde": yuvarla(sayi_kamu / toplam_sirket * 100, 2),
         "kota_yuzde": uc["kamu"], "sirket_sayisi": sayi_kamu},
        {"ad": "kooperatif", "sirket_yuzde": yuvarla(sayi_koop / toplam_sirket * 100, 2),
         "kota_yuzde": uc["kooperatif"], "sirket_sayisi": sayi_koop},
        {"ad": "ozel", "sirket_yuzde": yuvarla(sayi_ozel / toplam_sirket * 100, 2),
         "kota_yuzde": uc["ozel"], "sirket_sayisi": sayi_ozel},
    ],

    # Şirket kotaları, büyükten küçüğe. Toplam satırları dışarıda.
    "kota_siralamasi": sorted(
        [s for s in sir if "TOPLAMI" not in s["ad"]],
        key=lambda s: -s["a_kotasi_ton"]),

    "dunya_siralamasi": d["seker"]["dunya_ilk_10"],
}

# ── SINAMALAR ────────────────────────────────────────────────────────
h = []

# 1 · yüzüncü yıl gerçekten yüzüncü mü
if d["kimlik"]["yuzuncu_yil"] - 1926 != 100:
    h.append("yüzüncü yıl 1926+100 etmiyor")

# 2 · üç kesim yüzdesi 100
if abs(sum(d["kota"]["uc_kesim_yuzde"].values()) - 100) > 0.05:
    h.append(f"üç kesim payı 100 değil: {sum(d['kota']['uc_kesim_yuzde'].values())}")

# 3 · kota kalemleri toplamı
kal = sum(s["a_kotasi_ton"] for s in d["kota"]["sirketler"]
          if "TOPLAMI" not in s["ad"] and not s["ad"].startswith("KAMU"))
kamu = next(s["a_kotasi_ton"] for s in d["kota"]["sirketler"] if s["ad"].startswith("KAMU"))
if kal + kamu != d["kota"]["pancar_sekeri_toplam_ton"]:
    h.append(f"kota kalemleri {kal + kamu:,} ≠ {d['kota']['pancar_sekeri_toplam_ton']:,}")

# 4 · TÜRKŞEKER kotası üç kesim yüzdesiyle tutuyor mu
pay = d["kota"]["turkseker_a_kotasi_ton"] / d["kota"]["pancar_sekeri_toplam_ton"] * 100
if abs(pay - d["kota"]["uc_kesim_yuzde"]["kamu"]) > 0.02:
    h.append(f"TÜRKŞEKER payı hesapla {pay:.2f}, tabloda {d['kota']['uc_kesim_yuzde']['kamu']}")

# 5 · randıman: şeker ÷ pancar makul mü (üç bağımsız kaynak)
rand = d["seker"]["uretim_bin_ton"] * 1000 / ciftci["yillar"][PANCAR_SON]["uretim_ton"] * 100
if not 9 <= rand <= 16:
    h.append(f"randıman %{rand:.1f} — pancar şekeri için beklenen aralık dışında")
d["seker"]["randiman_yuzde"] = yuvarla(rand)

# 6 · kamış şekeri ölçülmüş sıfır olmalı
if d["seker"]["kamis_sekeri_bin_ton"] != 0:
    h.append("kamış şekeri sıfır değil — 'şekerin tamamı pancardan' cümlesi düşer")

# 7 · çiftçi düşüşü iki tabloda da ölçülü
if d["ciftci"]["son_sayi"] >= d["ciftci"]["zirve_sayi"]:
    h.append("çiftçi zirvesi son yıldan küçük")
d["ciftci"]["dusus_yuzde"] = yuvarla(
    (d["ciftci"]["son_sayi"] / d["ciftci"]["zirve_sayi"] - 1) * 100)

# 8 · personel bileşenleri toplamı
for y, v in d["kurum"]["personel_yillik"].items():
    if v["memur_sozlesmeli"] + v["daimi_isci"] + v["kampanya_mevsimlik"] != v["toplam"]:
        h.append(f"{y} personel toplamı tutmuyor")

# 9 · NBŞ kotası gerçekten dörtte bire indi mi
if d["kota"]["nbs_dusus"]["degisim_yuzde"] > -70:
    h.append(f"NBŞ düşüşü beklenenden küçük: %{d['kota']['nbs_dusus']['degisim_yuzde']}")

# 10 · fabrika sayısı azaldı mı
if d["kimlik"]["fabrika_bugun"] >= d["kimlik"]["fabrika_1990_oncesi"]:
    h.append("fabrika sayısı azalmamış görünüyor")

# 11 · zaman çizelgesi kronolojik
yillar = [m["yil"] for m in d["tarih"]["maddeler"]]
if yillar != sorted(yillar):
    h.append("zaman çizelgesi kronolojik değil")

# 12 · ticaret zirvesi 2022
if d["ticaret"]["ithalat_dalgasi"]["zirve_yil"] != "2022":
    h.append("ithalat zirvesi 2022 değil")

# 13 · ÜÇ PAY KARIŞMASIN — ayrı ayrı yazılıyor ve birbirine eşit olmamalı
d["_uc_pay"] = {
    "kota_payi_yuzde": d["kota"]["uc_kesim_yuzde"]["kamu"],
    "pancar_payi_yuzde": yuvarla(
        ciftci["turkseker"][SON]["uretim_ton"] / ciftci["yillar"][SON]["uretim_ton"] * 100),
    "uretim_payi_yuzde": 32,
    "_uyari": ("Üçü AYRI şeyi ölçer: kota bölüşümü · işlenen pancar · üretilen şeker. "
               "Yayında biri diğerinin yerine yazılamaz."),
}
if len({d["_uc_pay"]["kota_payi_yuzde"], d["_uc_pay"]["pancar_payi_yuzde"],
        d["_uc_pay"]["uretim_payi_yuzde"]}) != 3:
    h.append("üç pay birbirine eşit çıktı — ölçüler karışmış olabilir")

# 14 · türetilmiş listeler boş kalmasın
# LİSTE OLDUĞU DA SINANIYOR. İlk yazımda yalnız "boş mu" bakılıyordu ve
# dunya_siralamasi yanlışlıkla bir SAYIYA (dünya toplamı) bağlanmıştı;
# float boş sayılmadığı için sınama sessizce geçti. Tür de aranıyor.
for ad, liste in d["turetilmis"].items():
    if ad.startswith("_"):
        continue
    if not isinstance(liste, list):
        h.append(f"türetilmiş alan liste değil: {ad} ({type(liste).__name__})")
    elif not liste:
        h.append(f"türetilmiş liste boş: {ad}")
    elif not isinstance(liste[0], dict):
        h.append(f"türetilmiş liste kayıt taşımıyor: {ad}")

# 15 · şirket sayısı kota tablosundaki kalem sayısıyla tutuyor mu
_kalem = len([s for s in sir if "TOPLAMI" not in s["ad"] and not s["ad"].startswith("KAMU")])
if _kalem != sayi_koop + sayi_ozel:
    h.append(f"şirket sayısı tutmuyor: tabloda {_kalem}, elle yazılan {sayi_koop + sayi_ozel}")

# 16 · kesim payları iki ölçüde de 100
for olcu in ("sirket_yuzde", "kota_yuzde"):
    t = sum(k[olcu] for k in d["turetilmis"]["kesimler"])
    if abs(t - 100) > 0.15:
        h.append(f"kesimler {olcu} toplamı 100 değil: {t}")

if h:
    raise SystemExit("✗ SINAMA DÜŞTÜ · data.json YAZILMADI\n  " + "\n  ".join(h))

# HABER ARŞİVİ RAKAMLARI. Kurumun kendi haber arşivinden çıkarılan ve her
# biri bir kaynak cümlesine bağlanan kalemler (haber_ayikla.py). Tur 9'a
# kadar bu damar hiç işlenmemişti. KURUMUN KENDİ BEYANI olduğu için metinde
# öyle atfediliyor; denetlenmiş veri değil.
_h = RAW / "haber.json"
if _h.exists():
    _hd = json.loads(_h.read_text(encoding="utf-8"))
    d["haber"] = _hd["haber"]
    d["yurtdisi"] = {k: v for k, v in _hd["sayfa"].items() if not k.startswith("_")}

# GALERİ. Kareler _raw/galeri.json'da; kur_galeri.py yazıyor. Buraya
# OLDUĞU GİBİ giriyor çünkü içinde rakam yok — tutarlılık sınaması gerektiren
# bir veri değil, künyeli bir kare listesi. Dosya yoksa galeri de yok ve
# bu bir hata değil: galerisi olmayan dosyalar bu bloğu hiç taşımıyor.
_g = RAW / "galeri.json"
if _g.exists():
    d["galeri"] = json.loads(_g.read_text(encoding="utf-8"))

(KOK / "data.json").write_text(json.dumps(d, ensure_ascii=False, indent=2), encoding="utf-8")

print(f"  ✓ 16 sınama geçti · {len(json.dumps(d)):,} bayt"
      + (f" · galeri {len(d['galeri']['kareler'])} kare" if "galeri" in d else ""))
print(f"\n  ilk şeker      {d['kimlik']['ilk_seker_tarihi']} · {d['kimlik']['ilk_seker_yeri']}"
      f" → {d['kimlik']['yuzuncu_yil']}")
print(f"  fabrika        {d['kimlik']['fabrika_1990_oncesi']} → {d['kimlik']['fabrika_bugun']}")
print(f"  kota           kamu %{d['kota']['uc_kesim_yuzde']['kamu']}"
      f" · kooperatif %{d['kota']['uc_kesim_yuzde']['kooperatif']}"
      f" · özel %{d['kota']['uc_kesim_yuzde']['ozel']}")
print(f"  Alpullu        {d['kota']['alpullu']['a_kotasi_ton']:,} ton"
      f" · %{d['kota']['alpullu']['pancar_sekerinde_pay_yuzde']}")
print(f"  verim          {d['pancar']['verim_ilk']:,.0f} → {d['pancar']['verim_son']:,.0f} kg/ha"
      f"  (%{d['pancar']['verim_artis_yuzde']:+.0f})")
print(f"  randıman       %{d['seker']['randiman_yuzde']}")
print(f"  çiftçi         {d['ciftci']['zirve_sayi']:,} → {d['ciftci']['son_sayi']:,}"
      f"  (%{d['ciftci']['dusus_yuzde']})")
print(f"  personel       {d['kurum']['personel_dusus']['_2018']:,} →"
      f" {d['kurum']['personel_dusus']['_2022']:,}")
print(f"  NBŞ kotası     %{d['kota']['nbs_dusus']['degisim_yuzde']}")
print(f"\n  üç pay: kota %{d['_uc_pay']['kota_payi_yuzde']}"
      f" · pancar %{d['_uc_pay']['pancar_payi_yuzde']} · üretim %{d['_uc_pay']['uretim_payi_yuzde']}")
