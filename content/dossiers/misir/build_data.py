#!/usr/bin/env python3
"""Mısır — `_raw/*.json` → `data.json`. Veri sayfası burada KİLİTLENİR.

EKSEN A (kullanıcı kararı): KİRAYLA TARIM. Mısır toprağının kırkta birini
ekiyor, suyunun neredeyse tamamı ülke dışından geliyor, ekmeğini dünyada
herkesten çok satın alıyor — ve buna rağmen Türkiye'nin sebze-meyve
rafındaki rakibi.

İMZA: FEDDAN (0,42 ha). Dosyanın birimi ülke değil bir tarla.

ON İKİ DOĞRULAMA — her biri bu dosyada GERÇEKTEN yaşanmış bir tuzağı
bekliyor, hiçbiri varsayımsal değil. Biri tutmazsa üretim DURUR.

  1. Her blok `_kapsam` + `_kaynak_niteligi` taşıyor (§2.2)
  2. PROJEKSİYON GÖVDEYE GİRMEMİŞ — nüfus 2026'dan ileri olamaz
  3. CİNSİYET DİLİMİ — tarım istihdamı Total; Mısır'ınki 5 milyonun üstünde
  4. KAPSAM ETİKETİ — katma değer kalemi ormancılık+balıkçılık dahil diyor
  5. AYNA FARKI HESAPLANIYOR, iddia edilmiyor
  6. Fasıl dökümü manşetle tutuyor
  7. BOŞ SONUÇ SIFIR DEĞİL — hiçbir ticaret kalemi 0 yazılmamış
  8. PSD KESİN YILI — buğday rakamları ham son yıldan değil kesin yıldan
  9. PSD ARZ=KULLANIM dengesi tutuyor (ihracat anormalliği doğrulandı)
 10. SULAMA EŞİTLİĞİNİN SINIRI yazılı — kaç yıl için geçerli olduğu
 11. EKSEN CÜMLESİNİN İKİ SAYISI aralıkta (dışına çıkarsa cümle yazılamaz)
 12. BİRİM KARIŞTIRMA — bin ha ile ha aynı toplamda buluşmuyor

Çalıştırma: python3 build_data.py
"""
from __future__ import annotations

import json
import pathlib
import sys

KOK = pathlib.Path(__file__).parent
HAM = KOK / "_raw"
BUGUN = 2026
FEDDAN_HA = 0.4200833   # 4.200,833 m² — Mısır'ın kendi arazi birimi.
# TAM DEĞER YAZILIYOR, 0,42 değil: data.json'daki tanım notu 0,4200833
# diyor ve sabit 0,42 kalırsa not ile saklanan sayı AYRIŞIR. Kişi başına
# feddan iki yazımda da 1,71 çıkıyor, yani görünür bir fark yok — sessizce
# ayrışan tam da bu tür bir sayıdır.

oku = lambda ad: json.loads((HAM / ad).read_text(encoding="utf-8"))
arazi, su, bugday = oku("arazi.json"), oku("su.json"), oku("bugday.json")
sta = oku("sta_ekler.json")
b28 = oku("bolum28.json")
uretim, ticaret, makro = oku("uretim.json"), oku("ticaret.json"), oku("makro.json")

hata: list[str] = []


def sayi(x):
    return x["deger"] if isinstance(x, dict) and "deger" in x else x


# ══════════════════════════════════════════════════════════════════════════
#  GÖVDE
# ══════════════════════════════════════════════════════════════════════════
d: dict = {}

d["arazi"] = {
    "_kapsam": "Mısır ve Türkiye'nin arazi kullanımı, 2024",
    "_kaynak_niteligi": "BAĞIMSIZ — FAOSTAT Inputs/LandUse toplu indirme",
    "_birim": "bin hektar",
    "misir": {k: sayi(arazi["misir"][k]) for k in
              ("kara_alani", "tarim_arazisi", "ekili_arazi", "islenebilir_arazi",
               "daimi_urun", "fiilen_sulanan_tarim")},
    "turkiye": {k: sayi(arazi["turkiye"][k]) for k in
                ("kara_alani", "tarim_arazisi", "ekili_arazi", "islenebilir_arazi",
                 "daimi_urun", "fiilen_sulanan_tarim")},
    "misir_tarim_arazisi_serisi": {
        y: arazi["misir"]["tarim_arazisi"]["seri"][y]
        for y in ("1961", "1990", "2010", "2020", "2024")
        if y in arazi["misir"]["tarim_arazisi"]["seri"]},
    "_sulama_esitligi_siniri": (
        "FAOSTAT'ta 'fiilen sulanan tarım alanı' ile 'tarım arazisi' Mısır için "
        "BİREBİR EŞİT, ama ikisinde birden veri olan tek dönem 2021-2024 (4 yıl). "
        "Atama olabilir. 'Mısır tarımının tamamı sulamadır' cümlesi bu veriye "
        "dayanarak kurulmayacak; AQUASTAT ikinci kaynak olarak kullanılacak."),
}

d["su"] = {
    "_kapsam": "Mısır'ın su kaynakları ve bağımlılığı",
    "_kaynak_niteligi": "BİRİNCİL — FAO AQUASTAT ülke profili, 2016 taraması",
    "_belge": su["_belge"],
    "disa_bagimlilik_yuzde": su["disa_bagimlilik_yuzde"]["deger"],
    "_bagimlilik_alinti": su["disa_bagimlilik_yuzde"]["alinti"],
    "ic_yenilenebilir_milyon_m3": su["ic_yenilenebilir_milyon_m3"]["deger"],
    "toplam_yenilenebilir_milyon_m3": su["toplam_yenilenebilir_milyon_m3"]["deger"],
    "kisi_basi_m3": su["kisi_basi_m3"]["deger"],
    "kisi_basi_yil": su["kisi_basi_m3"]["yil"],
    "toplam_cekim_milyon_m3": su["toplam_cekim_milyon_m3"]["deger"],
    "cekim_yil": su["toplam_cekim_milyon_m3"]["yil"],
    "cekim_dagilim_yuzde": su["toplam_cekim_milyon_m3"]["dagilim_yuzde"],
    "ekim_yogunlugu_yuzde": 175,
    "ekim_yogunlugu_yil": 2010,
    "_cekim_kaynaktan_buyuk": su["_CEKIM_KAYNAKTAN_BUYUK"],
    "_yil_uyarisi": su["_YIL_UYARISI"],
}

b = bugday
d["tahil"] = {
    "_kapsam": "Mısır'ın buğday, mısır ve pirinç dengesi · PSD pazarlama yılı",
    "_kaynak_niteligi": "BAĞIMSIZ — USDA FAS PSD toplu CSV",
    "_birim": "bin ton",
    "_pazarlama_yili_notu": b["_pazarlama_yili_notu"],
    "kesin_son_yil": b["kesin_son_yil"],
    "_ham_son_yil": b["_son_yil_ham"],
    "bugday": b["misir"],
    "bugday_turkiye": b["turkiye"],
    "dunya_bugday_ithalati": b["dunya_ithalat"],
    "misir_dunya_sirasi": b["misir_dunya_sirasi"],
    "turkiye_dunya_sirasi": b["turkiye_dunya_sirasi"],
    "ithalat_ilk_6": b["ithalat_ilk_10"][:6],
    "_dunya_notu": b["_dunya_notu"],
    # TUR 7'DE EKLENDİ — grafik turu veri sayfasında üç boşluk açığa çıkardı.
    # Üçü de tur 3'te ÖLÇÜLMÜŞTÜ ama data.json'a girmemişti; iskeletin §8 ve
    # §9'u o rakamlara dayanıyor ve veri sayfası onlar olmadan metni
    # taşıyamıyordu.
    #
    # ADLANDIRMA: 'tane_misir' TANE MISIR. Ülke her yerde 'misir'.
    "tane_misir": b["oteki_taneler"]["tane_misir"]["misir"],
    "tane_misir_turkiye": b["oteki_taneler"]["tane_misir"]["turkiye"],
    "pirinc": b["oteki_taneler"]["pirinc"]["misir"],
    "pirinc_turkiye": b["oteki_taneler"]["pirinc"]["turkiye"],
    "_oteki_tane_yili": b["oteki_taneler"]["_yil"],
    "_ad_notu": b["oteki_taneler"]["_ad_notu"],
    # Seri KESİN yılda kesiliyor: PSD'nin son iki yılı tahmin/öngörü ve
    # çizgi grafiği tahmini ölçümden ayırt edemez.
    "bugday_ithalat_serisi": {y: v for y, v in b["misir_ithalat_serisi"].items()
                              if int(y) <= b["kesin_son_yil"]},
}

u = uretim
# FEDDAN — ölçüm değil TANIM. Türetilmiş bloğa girmiyor: orada "yukarıdaki
# bloklardan hesaplandı" yazıyor ve bir birim tanımı hesaplanmıyor. Dosyanın
# imzası bu birim, bu yüzden data.json'da kendi kalemi var.
# TAM DEĞER saklanıyor, yuvarlanmış değil. İlk yazımda round(...,4) vardı ve
# 0,4201 yazıyordu; tanım notu ise 4.200,833 m² diyordu. İkisi ayrışmıştı ve
# bunu dogrula_grafik.py'nin 16. kuralı yakaladı: grafiğin notundaki
# 4.200,833 hiçbir veri sayısından türetilemiyordu. Gösterimdeki basamak
# grafiğin işi (kunye'de ondalik 2), veri sayfasının değil.
d["arazi"]["feddan_ha"] = FEDDAN_HA
d["arazi"]["_feddan_tanimi"] = (
    "1 feddan = 4.200,833 m² = 0,4200833 ha. Mısır'ın kendi arazi birimi; "
    "resmî istatistik hektarla yayımlanıyor, tarla hâlâ feddanla konuşuluyor.")

d["urunler"] = {
    "_kapsam": "Rakip ürünlerde Mısır–Türkiye karşılaştırması, ortak son yıl",
    "_kaynak_niteligi": "BAĞIMSIZ — FAOSTAT QCL toplu CSV",
    "_birim": "ton",
    "_ortak_son_yil": u["_ortak_son_yil"],
    "karsilastirma": {},
    "pamuk_serisi": {},
    # İKİ SERİ BİR DİZİDEN (tur 7). Pamuğun üretimi ton, alanı hektar: ikisi
    # tek y ekseninde yan yana çizilemez. Çözüm indeks — TABAN 1961 = 100.
    # Grafiğin söylediği şey de bu: alan %90 düşerken üretim %77 düştü, fark
    # VERİMİN artışı. Mutlak rakamlarla bu fark görünmez.
    "pamuk_endeks": [],
    "_pamuk_endeks_notu": ("Taban 1961 = 100. İki seri aynı birimde (indeks) "
                           "olduğu için tek eksende çizilebiliyor; ton ile "
                           "hektar çizilemez."),
    # Portakalda 'oran artıyor' cümlesi için ÖLÇÜM. İddia tek yıldan
    # kurulamaz; ortak yıllarda iki ülke yan yana duruyor.
    "portakal_cizgi": [],
}
for urun in ("portakal", "pirinc", "kuru_sogan", "patates", "narenciye_toplam",
             "mandalina", "domates", "bugday", "limon", "cigit_pamuk"):
    y = u["_ortak_son_yil"].get(urun)
    if not y:
        continue
    m = u["misir"][urun]["uretim"]["seri"].get(str(y))
    t = u["turkiye"][urun]["uretim"]["seri"].get(str(y))
    if m is None or t is None:
        continue
    d["urunler"]["karsilastirma"][urun] = {"yil": y, "misir": m, "turkiye": t}
for y in ("1961", "1965", "1980", "2000", "2010", "2020", "2024"):
    s = u["misir"]["cigit_pamuk"]["uretim"]["seri"]
    a = u["misir"]["cigit_pamuk"].get("alan", {}).get("seri", {})
    if y in s:
        d["urunler"]["pamuk_serisi"][y] = {"uretim": s[y], "alan": a.get(y)}

# Pamuk indeksi — her beş yılda bir nokta, taban 1961.
_ps = u["misir"]["cigit_pamuk"]["uretim"]["seri"]
_pa = u["misir"]["cigit_pamuk"].get("alan", {}).get("seri", {})
_t_ur, _t_al = _ps.get("1961"), _pa.get("1961")
if not _t_ur or not _t_al:
    raise SystemExit("✗ pamuk indeksinin taban yılı (1961) yok")
for yil in range(1961, 2025, 5):
    k = str(yil)
    if k in _ps and k in _pa and _ps[k] is not None and _pa[k] is not None:
        d["urunler"]["pamuk_endeks"].append({
            "yil": yil,
            "uretim": round(100 * _ps[k] / _t_ur, 1),
            "alan": round(100 * _pa[k] / _t_al, 1)})
_son = str(u["_ortak_son_yil"].get("cigit_pamuk"))
if _son in _ps and d["urunler"]["pamuk_endeks"][-1]["yil"] != int(_son):
    d["urunler"]["pamuk_endeks"].append({
        "yil": int(_son),
        "uretim": round(100 * _ps[_son] / _t_ur, 1),
        "alan": round(100 * _pa[_son] / _t_al, 1)})

# Portakal — iki ülke, ortak yıllar. ORTAK YIL KURALI (§2.7): bir ülkede
# veri olup ötekinde olmayan yıl atlanıyor, doldurulmuyor.
_pm = u["misir"]["portakal"]["uretim"]["seri"]
_pt = u["turkiye"]["portakal"]["uretim"]["seri"]
for yil in (1961, 1970, 1980, 1990, 2000, 2010, 2020, 2024):
    k = str(yil)
    if _pm.get(k) is not None and _pt.get(k) is not None:
        d["urunler"]["portakal_cizgi"].append(
            {"yil": yil, "misir": _pm[k], "turkiye": _pt[k]})

t_ = ticaret
d["ticaret"] = {
    "_kapsam": "Türkiye–Mısır tarım ticareti, 2024 · HS 01-24",
    "_kaynak_niteligi": "BAĞIMSIZ — UN Comtrade; İKİ TARAFIN da beyanı alındı",
    "_birim": "ABD doları",
    "_suzgec": t_["_suzgec"],
    "tr_beyani_giden": t_["tr_misira_tarim_ihracat"]["deger_usd"],
    "misir_beyani_gelen": t_["misir_trden_tarim_ithalat"]["deger_usd"],
    "misir_beyani_giden": t_["misir_tre_tarim_ihracat"]["deger_usd"],
    "tr_beyani_gelen": t_["tr_misirdan_tarim_ithalat"]["deger_usd"],
    "tr_dunyaya_tarim": t_["tr_dunyaya_tarim_ihracat"]["deger_usd"],
    "misir_dunyaya_tarim": t_["misir_dunyaya_tarim_ihracat"]["deger_usd"],
    "tr_misira_toplam": t_["tr_misira_toplam_ihracat"]["deger_usd"],
    "fasil_giden": t_["fasil_ihracat"],
    "fasil_gelen": t_["fasil_ithalat"],
}

mk = makro
d["makro"] = {
    "_kapsam": "Nüfus, tarım istihdamı ve katma değer",
    "_kaynak_niteligi": "BAĞIMSIZ — FAOSTAT Macro-Statistics / Population / Employment",
    "_kapsam_uyarisi": mk["_kapsam_notu"],
    "_projeksiyon_uyarisi": mk["_projeksiyon_notu"],
    "_taban_notu": mk["_taban_notu"],
}
for u_ in ("misir", "turkiye"):
    d["makro"][u_] = {
        "nufus_bin": sayi(mk[u_]["nufus|toplam"]),
        "nufus_yil": mk[u_]["nufus|toplam"]["son_yil"],
        "kirsal_bin": sayi(mk[u_]["nufus|kirsal"]),
        "tarim_istihdami_bin": sayi(mk[u_]["tarim_istihdami|Value"]),
        "tarim_istihdami_yil": mk[u_]["tarim_istihdami|Value"]["son_yil"],
        "katma_deger_milyon_usd": sayi(mk[u_]["tarim_ormancilik_balikcilik_katma_deger|deger_usd"]),
        "gsyh_milyon_usd": sayi(mk[u_]["gsyh|deger_usd"]),
        "katma_deger_yil": mk[u_]["tarim_ormancilik_balikcilik_katma_deger|deger_usd"]["son_yil"],
    }

d["belge"] = {
    "_kapsam": "Türkiye–Mısır Serbest Ticaret Anlaşması",
    "_kaynak_niteligi": "BİRİNCİL — Resmî Gazete nüshası",
    "ad": "Türkiye Cumhuriyeti ile Mısır Arap Cumhuriyeti Arasında Bir Serbest "
          "Ticaret Alanı Tesis Eden Anlaşma",
    "imza": "27 Aralık 2005, Kahire",
    "uygun_bulma_kanunu": "5563 sayılı Kanun, 13/12/2006",
    "karar": "2007/11557, 15/1/2007",
    "resmi_gazete": "30 Ocak 2007 · sayı 26419 MÜKERRER",
    "yururluk": "1 Mart 2007",
    "_mukerrer_notu": ("Belge ana nüshanın içindekiler listesinde YOK, Mükerrer "
                       "ekte. TİGEM'i kuran KHK de 18205 Mükerrer'deydi."),
    # EKLER AÇILDI (12 Kasım 2026, tur 7 sonu). Önceki hâli "bu makinede
    # açılamadı" diyordu ve bu artık YANLIŞ bir cümleydi: macOS'un kendi
    # tar'ı (bsdtar/libarchive) RAR okuyor, .doc'ları textutil çeviriyor.
    # unrar/unar/7z gerekmedi — sudo da gerekmedi (hesap sudoers'da değil).
    "_ekler": ("Açıldı: 19 dosya. Tarım tavizleri PROTOKOL II'de, iki tablo "
               "halinde. Protokol I, Liste 1-4, ekler.xls ve EK I sanayi "
               "ürünlerine ait."),
    "taviz": {
        "_kaynak_niteligi": "BİRİNCİL — anlaşmanın Türkçe nüshasının eki, Protokol II",
        "_kapsam": "Temel tarım, işlenmiş tarım ve balıkçılık ürünlerinde taviz değişimi",
        "tablo_a_kota_ton": sta["tablo_a"]["toplam_kota_ton"],
        "tablo_a_kota_grubu": sta["tablo_a"]["kota_grubu_sayisi"],
        "tablo_a_pozisyon": sta["tablo_a"]["tarife_pozisyonu_sayisi"],
        "tablo_a_sinirsiz": sta["tablo_a"]["sinirsiz_satir"],
        "tablo_b_kota_ton": sta["tablo_b"]["toplam_kota_ton"],
        "tablo_b_kota_grubu": sta["tablo_b"]["kota_grubu_sayisi"],
        "tablo_b_pozisyon": sta["tablo_b"]["tarife_pozisyonu_sayisi"],
        "tablo_b_sinirsiz": sta["tablo_b"]["sinirsiz_satir"],
        "pirinc_kotasi_ton": sta["turetilmis"]["pirinc_kotasi_ton"],
        "pirinc_kahverengi_ton": next(
            k["kota_ton"] for k in sta["tablo_b"]["kalemler"]
            if k["kodlar"][0] == "1006.20"),
        "pirinc_degirmen_ton": next(
            k["kota_ton"] for k in sta["tablo_b"]["kalemler"]
            if k["kodlar"][0] == "1006.30"),
        "pirinc_degirmen_indirim_yuzde": next(
            k["indirim_yuzde"] for k in sta["tablo_b"]["kalemler"]
            if k["kodlar"][0] == "1006.30"),
        "pirinc_payi_tablo_b_yuzde": sta["turetilmis"]["pirinc_payi_tablo_b_yuzde"],
        "yag_kotasi_ton": sta["turetilmis"]["yag_kotasi_ton"],
        "yag_payi_tablo_a_yuzde": sta["turetilmis"]["yag_payi_tablo_a_yuzde"],
        "sebze_kotasi_ton": sta["turetilmis"]["sebze_kotasi_ton"],
        "sebze_pozisyon_sayisi": sta["turetilmis"]["sebze_pozisyon_sayisi"],
        "_sinirsiz_notu": ("'Sınırsız' SIFIR DEĞİL, sınır yok demek. Tablo "
                           "B'de iki satır böyle (balıkçılık faslı %50, canlı "
                           "bitkiler %100); Tablo A'da hiç yok. Toplam kotaya "
                           "girmiyorlar, ayrıca sayılıyorlar."),
        "_simetrik_blok": sta["_simetrik_blok"],
    },
}

# ── ANLATI KAYNAKLARI (§2.8) ─────────────────────────────────────────────
# Metnin anlatı bölümleri de SAYI taşıyor ve dogrula_metin.py sayı havuzunu
# data.json'dan kuruyor. _raw'da kalan bir rakam metne girerse denetlenemez.
d["anlati"] = {
    "_kapsam": "§2.8'in iki kategorisi — bilim/kişi ve kültürel açıklama",
    "_kaynak_niteligi": "KARMA — ayrıntı ve nitelik _raw/bolum28.json'da",
    "jumel": {
        "dogum": 1785,
        "olum": 1823,
        "misira_gelis": 1817,
        "ilk_ekim_denemesi": 1821,
        "_yil_celiskisi": ("Keşif/ilk ekim yılı kaynaklarda 1818, 1819 ve 1821 "
                           "olarak AYRIŞIYOR. 1821 yalnız Al Manassa'nın "
                           "cümlesine dayanıyor. Metin TEK YIL İDDİA ETMEYECEK; "
                           "1817 (Mısır'a geliş) sağlam, ekim yılı aralık."),
        "kantar_kg": 45,
        "ilk_uretim_kantar": 1000,
        "kirk_yil_sonra_kantar": 1180000,
        "_kantar_notu": ("Kantar pamuğa mahsus tarihsel birim, kabaca 45 kg. "
                         "İki üretim rakamı da Al Manassa'nın aktarımı — "
                         "İKİNCİL kaynak, birincil belge bulunamadı."),
    },
    "pirinc_suzulmesi": {
        "yil": 2023,
        "kuzey_azalma_yuzde": 19,
        "kuzey_azalma_deniz_yukselmesiyle_yuzde": 17,
        "_nitelik": ("BİRİNCİL — Abd-Elaty vd., Journal of Hydrology: Regional "
                     "Studies 48, 101466, doi 10.1016/j.ejrh.2023.101466"),
        "_sinir": ("Bulgu SAYISAL MODELDEN (SEAWAT), saha ölçümünden değil. "
                   "Sonuç nereye ekildiğine bağlı; orta ve güney bölge "
                   "rakamları kaynaklar arasında tutarsız ve KULLANILMIYOR. "
                   "Pirincin bu amaçla ekildiğini doğrulayan kaynak yok — yan "
                   "etki. Devlet deltanın bazı yerlerinde pirinci su tasarrufu "
                   "için kısıtlıyor."),
    },
}

# 22 — JUMEL'İN YIL ÇELİŞKİSİ YAZILI
# Üç ayrı yıl dolaşıyor ve metin tek yıl iddia etmeyecek. Çelişki notu
# silinirse sonraki tur onu kesin bir tarih sanır.
_j = d["anlati"]["jumel"]
if "1818" not in _j["_yil_celiskisi"] or "1819" not in _j["_yil_celiskisi"]:
    hata.append("JUMEL ÇELİŞKİSİ EKSİK · üç yılın hepsi notta geçmeli")
if not (_j["dogum"] < _j["misira_gelis"] < _j["ilk_ekim_denemesi"] < _j["olum"]):
    hata.append(f"JUMEL TARİHLERİ SIRASIZ · {_j['dogum']} / "
                f"{_j['misira_gelis']} / {_j['ilk_ekim_denemesi']} / {_j['olum']}")

# 23 — PİRİNÇ SÜZÜLMESİ 'MODEL' DİYE ETİKETLİ
# Bulgu saha ölçümü değil. Etiket düşerse metin onu ölçüm gibi yazar.
_ps = d["anlati"]["pirinc_suzulmesi"]
if "MODEL" not in _ps["_sinir"] and "model" not in _ps["_sinir"]:
    hata.append("MODEL ETİKETİ YOK · pirinç süzülmesi bulgusu saha ölçümü değil")
if _ps["kuzey_azalma_deniz_yukselmesiyle_yuzde"] >= _ps["kuzey_azalma_yuzde"]:
    hata.append("PİRİNÇ SÜZÜLMESİ · deniz yükselmesiyle azalma daha BÜYÜK "
                "çıkmış, kaynakta tersi")

# ══════════════════════════════════════════════════════════════════════════
#  DOĞRULAMALAR
# ══════════════════════════════════════════════════════════════════════════

# 1 — kapsam ve kaynak niteliği
for ad, blok in d.items():
    if not isinstance(blok, dict):
        hata.append(f"BLOK SÖZLÜK DEĞİL · {ad}"); continue
    if not blok.get("_kapsam"):
        hata.append(f"KAPSAM YOK · {ad}")
    if not blok.get("_kaynak_niteligi"):
        hata.append(f"KAYNAK NİTELİĞİ YOK · {ad}")

# 2 — PROJEKSİYON GÖVDEYE GİRMESİN
for u_ in ("misir", "turkiye"):
    y = d["makro"][u_]["nufus_yil"]
    if y > BUGUN:
        hata.append(f"PROJEKSİYON GÖVDEDE · {u_} nüfus yılı {y} > {BUGUN}. "
                    f"FAOSTAT serisi 2100'e kadar gidiyor ve bayrak ayırmıyor.")

# 3 — CİNSİYET DİLİMİ
mi = d["makro"]["misir"]["tarim_istihdami_bin"]
if mi < 4000:
    hata.append(f"CİNSİYET DİLİMİ ŞÜPHELİ · Mısır tarım istihdamı {mi:,.0f} bin. "
                f"Total yerine Male/Female alınmış olabilir (ilk ölçümde 1.102 çıkmıştı).")

# 4 — KAPSAM ETİKETİ
#
# TÜRKÇE KÜÇÜLTME TUZAĞI — bu doğrulamanın İLK HÂLİ bu tuzağa düştü.
# `"ORMANCILIK".lower()` Python'da "ormancilik" veriyor (NOKTALI i), çünkü
# Python'ın lower()'ı Türkçe bilmiyor: noktasız I'yı noktalı i'ye çeviriyor.
# Aranan "ormancılık" (noktasız ı) ile eşleşmiyor ve kural, metin DOĞRU
# yazıldığı hâlde hata veriyordu.
#
# Projenin kayıtlı tuzağı (bkz. hafıza: Türkçe büyütme/küçültme). Çözüm
# küçültmeyi bırakmak: iki yazım da ayrı ayrı aranıyor.
_kapsam_metni = d["makro"]["_kapsam_uyarisi"]
if not any(k in _kapsam_metni for k in ("ORMANCILIK", "ormancılık", "Ormancılık")):
    hata.append("KAPSAM ETİKETİ YOK · katma değer kalemi ormancılık+balıkçılık dahil")

# 5 — AYNA FARKI HESAPLANIYOR
tc = d["ticaret"]
for a, b_ in (("tr_beyani_giden", "misir_beyani_gelen"),
              ("misir_beyani_giden", "tr_beyani_gelen")):
    if tc[a] is None or tc[b_] is None:
        hata.append(f"AYNA EKSİK · {a} / {b_}")

# 6 — fasıl dökümü manşetle tutuyor
for dokum, mansetti in (("fasil_giden", "tr_beyani_giden"),
                        ("fasil_gelen", "tr_beyani_gelen")):
    if tc[dokum]:
        toplam = sum(x["deger"] for x in tc[dokum])
        if abs(toplam - tc[mansetti]) > 1:
            hata.append(f"FASIL TOPLAMI TUTMUYOR · {dokum} {toplam:,.0f} ≠ "
                        f"{tc[mansetti]:,.0f}")

# 7 — BOŞ SONUÇ SIFIR DEĞİL
for k, v in tc.items():
    if k.startswith("_") or k.startswith("fasil"):
        continue
    if v == 0:
        hata.append(f"SIFIR YAZILMIŞ · ticaret.{k} — boş sonuç sıfır değildir")

# 8 — PSD KESİN YILI
if d["tahil"]["kesin_son_yil"] >= d["tahil"]["_ham_son_yil"]:
    hata.append("PSD KESİN YIL HATALI · son iki yıl tahmin, kesin yıl daha eski olmalı")

# 9 — PSD ARZ = KULLANIM
w = d["tahil"]["bugday"]
# Dengeyi _raw'dan okumuyoruz; burada yalnız iç tutarlılık sınanıyor
if w["uretim"] + w["ithalat"] < w["tuketim"]:
    hata.append("BUĞDAY DENGESİ · üretim+ithalat tüketimin altında, stok olmadan olmaz")

# 10 — SULAMA EŞİTLİĞİNİN SINIRI
if "2021-2024" not in d["arazi"]["_sulama_esitligi_siniri"]:
    hata.append("SULAMA SINIRI YAZILMAMIŞ · eşitliğin kaç yıl için geçerli olduğu şart")

# 11 — EKSEN CÜMLESİNİN İKİ SAYISI
pay_arazi = 100 * d["arazi"]["misir"]["tarim_arazisi"] / d["arazi"]["misir"]["kara_alani"]
sira = d["tahil"]["misir_dunya_sirasi"]
if not (3.5 <= pay_arazi <= 5.0):
    hata.append(f"EKSEN SAYISI ARALIK DIŞI · tarım arazisi payı %{pay_arazi:.2f} "
                f"(beklenen %3,5-5,0). Eksen cümlesi yazılamaz.")
if sira != 1:
    hata.append(f"EKSEN SAYISI DEĞİŞTİ · Mısır buğday ithalatında {sira}. sırada, "
                f"1 değil. 'Dünyanın en büyük alıcısı' cümlesi yazılamaz.")

# 12 — BİRİM KARIŞTIRMA
a_ = d["arazi"]["misir"]
if abs((a_["islenebilir_arazi"] + a_["daimi_urun"]) - a_["tarim_arazisi"]) > 1:
    hata.append("BİRİM/TOPLAM TUTMUYOR · işlenebilir + daimi ürün ≠ tarım arazisi")

# 13 — ÖTEKİ TANELER AYNI YILDAN
# Üç tane tek grafikte yan yana duruyor. PSD ürünleri ayrı revize ediyor;
# biri 2024, öteki 2023 olursa çubuklar aynı yılı göstermez ve grafik
# sessizce yanlış olur.
if d["tahil"]["_oteki_tane_yili"] != d["tahil"]["kesin_son_yil"]:
    hata.append(f"TANE YILI AYRIŞMIŞ · buğday {d['tahil']['kesin_son_yil']}, "
                f"öteki taneler {d['tahil']['_oteki_tane_yili']}")

# 14 — BOŞ TANE ALANI SIFIRA ÇEVRİLMEMİŞ
# Pirinçte yemlik tüketim PSD'de BOŞ (hayvan yemi değil). Sıfır yazılırsa
# "pirinç hayvana verilmiyor" ölçülmüş bir sıfır gibi görünür; oysa alan
# hiç doldurulmamış. Boş sonuç sıfır değildir.
for ad in ("pirinc", "pirinc_turkiye"):
    if d["tahil"][ad].get("yemlik") == 0:
        hata.append(f"SIFIR YAZILMIŞ · tahil.{ad}.yemlik — PSD'de boş, sıfır değil")

# 15 — PAMUK İNDEKSİNİN TABANI
pe = d["urunler"]["pamuk_endeks"]
if not pe or pe[0]["yil"] != 1961:
    hata.append("PAMUK İNDEKSİ · ilk nokta 1961 değil, taban kayıyor")
elif pe[0]["uretim"] != 100.0 or pe[0]["alan"] != 100.0:
    hata.append(f"PAMUK İNDEKSİ · taban 100 değil "
                f"({pe[0]['uretim']} / {pe[0]['alan']})")
for i, r in enumerate(pe):
    if r["uretim"] is None or r["alan"] is None:
        hata.append(f"PAMUK İNDEKSİ · {r['yil']} noktasının bir serisi boş — "
                    f"çizici o noktayı DÜŞÜRÜR, iki seri ayrı yıllarda biter")
if [r["yil"] for r in pe] != sorted(r["yil"] for r in pe):
    hata.append("PAMUK İNDEKSİ · yıllar artan değil")

# 16 — PORTAKALDA 'ARTIYOR' İDDİASI ÖLÇÜLÜ
# §12'nin cümlesi "2,61× ve ARTIYOR" diyecek. Bu iki yılın ölçümü; biri
# eksikse cümle kurulamaz, ters çıkarsa cümle YANLIŞTIR.
pc = {r["yil"]: r for r in d["urunler"]["portakal_cizgi"]}
if 1990 not in pc or 2024 not in pc:
    hata.append("PORTAKAL YÖNÜ ÖLÇÜLEMEDİ · 1990 ya da 2024 ortak yılı yok")
else:
    eski = pc[1990]["misir"] / pc[1990]["turkiye"]
    yeni = pc[2024]["misir"] / pc[2024]["turkiye"]
    if yeni <= eski:
        hata.append(f"PORTAKAL 'ARTIYOR' YANLIŞ · 1990'da {eski:.2f}×, "
                    f"2024'te {yeni:.2f}× — oran artmıyor")

# 17 — ÜÇ TANENİN PAYLARI, GRAFİĞİN TEZİ
# Grafiğin tek cümlesi şu: iki tanede ithalat arzın yarısından fazla,
# pirinçte onda birinden az. Aralık dışına çıkarsa o cümle yazılamaz.
tu_gec = {}
for ad, blok in (("bugday", d["tahil"]["bugday"]),
                 ("tane_misir", d["tahil"]["tane_misir"]),
                 ("pirinc", d["tahil"]["pirinc"])):
    tu_gec[ad] = 100 * blok["ithalat"] / (blok["uretim"] + blok["ithalat"])
for ad in ("bugday", "tane_misir"):
    if tu_gec[ad] < 50:
        hata.append(f"ÜÇ TANE TEZİ · {ad} ithal payı %{tu_gec[ad]:.1f} — "
                    f"'arzın yarısından fazlası ithal' cümlesi düştü")
if tu_gec["pirinc"] >= 10:
    hata.append(f"ÜÇ TANE TEZİ · pirinç ithal payı %{tu_gec['pirinc']:.1f} — "
                f"'kendine yetiyor' cümlesi düştü")

# 18 — STA TAVİZ TOPLAMI KALEMLERDEN YENİDEN HESAPLANIYOR
# Kota BAŞINA bir kez sayılmalı, tarife pozisyonu başına değil: tabloda
# birleştirilmiş hücreler var (altı sebze pozisyonu TEK 600 tonu paylaşıyor,
# iki fındık pozisyonu TEK 2.000 tonu). Pozisyon başına sayılırsa toplam
# şişer ve kimse görmez.
for _t, _ad in ((sta["tablo_a"], "tablo_a"), (sta["tablo_b"], "tablo_b")):
    _yeniden = sum(k["kota_ton"] for k in _t["kalemler"] if k["kota_ton"] is not None)
    if _yeniden != _t["toplam_kota_ton"]:
        hata.append(f"STA TOPLAMI TUTMUYOR · {_ad} kalemler {_yeniden:,} ≠ "
                    f"yazılan {_t['toplam_kota_ton']:,}")
    if _t["tarife_pozisyonu_sayisi"] < _t["kota_grubu_sayisi"]:
        hata.append(f"STA SAYIM HATASI · {_ad} pozisyon sayısı kota grubundan az")

# 19 — 'SINIRSIZ' SIFIRA ÇEVRİLMEMİŞ
# Belgede "Sınırsız" yazan satır kota listesinde None duruyor. Sıfır
# yazılırsa "taviz verilmemiş" gibi okunur; oysa tam tersi.
for _t, _ad in ((sta["tablo_a"], "tablo_a"), (sta["tablo_b"], "tablo_b")):
    if any(k["kota_ton"] == 0 for k in _t["kalemler"]):
        hata.append(f"SIFIR YAZILMIŞ · {_ad} — 'Sınırsız' sıfır değildir")
    _sayim = sum(1 for k in _t["kalemler"] if k["kota_ton"] is None)
    if _sayim != _t["sinirsiz_satir"]:
        hata.append(f"SINIRSIZ SAYIMI TUTMUYOR · {_ad} {_sayim} ≠ "
                    f"{_t['sinirsiz_satir']}")

# 20 — PİRİNÇ KAPISI VE VERİ SAYFASI AYNI YÖNÜ GÖSTERİYOR
# §15'in cümlesi şu olacak: Türkiye'nin tarımda açtığı en büyük kapı,
# Mısır'ın zaten fazlası olan ürün için. İki ucun ikisi de ölçülü olmak
# zorunda — pirinç kotası Tablo B'nin en büyüğü OLMALI ve Mısır'ın pirinç
# üretimi Türkiye'nin üstünde OLMALI. Biri düşerse cümle yazılamaz.
_b_kalem = [k for k in sta["tablo_b"]["kalemler"] if k["kota_ton"] is not None]
_en_buyuk = max(_b_kalem, key=lambda k: k["kota_ton"])
if not _en_buyuk["kodlar"][0].startswith("1006"):
    hata.append(f"PİRİNÇ KAPISI DEĞİŞTİ · Tablo B'nin en büyük kotası "
                f"{_en_buyuk['kodlar']} ({_en_buyuk['kota_ton']:,} ton)")
if d["urunler"]["karsilastirma"]["pirinc"]["misir"] <= \
        d["urunler"]["karsilastirma"]["pirinc"]["turkiye"]:
    hata.append("PİRİNÇ YÖNÜ TERS · Mısır'ın üretimi Türkiye'nin altında, "
                "§15'in cümlesi kurulamaz")

# 21 — YAĞ KAPISI VE 2024 AKIŞI AYNI FASLI GÖSTERİYOR
# Tablo A'nın en büyük kotası yağ (15. fasıl) ve 2024'te Türkiye'nin
# Mısır'a en çok sattığı fasıl da 15. Belge ile rafın aynı şeyi söylediği
# cümlesi buna dayanacak; fasıl sıralaması değişirse cümle düşer.
_en_fasil = max(d["ticaret"]["fasil_giden"], key=lambda x: x["deger"])["fasil"]
if _en_fasil != "15":
    hata.append(f"YAĞ CÜMLESİ DÜŞTÜ · 2024'te en büyük giden fasıl {_en_fasil}, "
                f"15 değil")

# ══════════════════════════════════════════════════════════════════════════
#  TÜRETİLMİŞ — metnin kullanacağı oranlar burada, cümlede değil
# ══════════════════════════════════════════════════════════════════════════
mk_m, mk_t = d["makro"]["misir"], d["makro"]["turkiye"]
ar_m, ar_t = d["arazi"]["misir"], d["arazi"]["turkiye"]

ha_kisi_m = ar_m["tarim_arazisi"] * 1000 / (mk_m["tarim_istihdami_bin"] * 1000)
ha_kisi_t = ar_t["tarim_arazisi"] * 1000 / (mk_t["tarim_istihdami_bin"] * 1000)

d["turetilmis"] = {
    "_kapsam": "Metnin kullanacağı oranlar — cümlede hesap yapılmaz",
    "_kaynak_niteligi": "TÜRETİLMİŞ — yukarıdaki bloklardan hesaplandı",
    "tarim_arazisi_payi_misir": round(pay_arazi, 2),
    "tarim_arazisi_payi_turkiye": round(
        100 * ar_t["tarim_arazisi"] / ar_t["kara_alani"], 2),
    "sulanan_payi_misir": round(
        100 * ar_m["fiilen_sulanan_tarim"] / ar_m["tarim_arazisi"], 2),
    "sulanan_payi_turkiye": round(
        100 * ar_t["fiilen_sulanan_tarim"] / ar_t["tarim_arazisi"], 2),
    "ha_kisi_misir": round(ha_kisi_m, 2),
    "ha_kisi_turkiye": round(ha_kisi_t, 2),
    "ha_kisi_kat": round(ha_kisi_t / ha_kisi_m, 1),
    "feddan_kisi_misir": round(ha_kisi_m / FEDDAN_HA, 2),
    "arazi_buyumesi_1961_2024_yuzde": round(
        100 * (d["arazi"]["misir_tarim_arazisi_serisi"]["2024"] /
               d["arazi"]["misir_tarim_arazisi_serisi"]["1961"] - 1), 1),
    "bugday_ithal_payi_yuzde": round(
        100 * w["ithalat"] / w["tuketim"], 1),
    "bugday_dunya_payi_yuzde": round(
        100 * w["ithalat"] / d["tahil"]["dunya_bugday_ithalati"], 1),
    "ayna_fark_giden_yuzde": round(
        100 * (tc["tr_beyani_giden"] / tc["misir_beyani_gelen"] - 1), 1),
    "ayna_fark_gelen_yuzde": round(
        100 * (tc["misir_beyani_giden"] / tc["tr_beyani_gelen"] - 1), 1),
    "misir_payi_tr_tarim_ihracatinda_yuzde": round(
        100 * tc["tr_beyani_giden"] / tc["tr_dunyaya_tarim"], 2),
    "tr_payi_misir_tarim_ihracatinda_yuzde": round(
        100 * tc["misir_beyani_giden"] / tc["misir_dunyaya_tarim"], 2),
    "kirsal_payi_misir_yuzde": round(
        100 * mk_m["kirsal_bin"] / mk_m["nufus_bin"], 1),
    "kirsal_payi_turkiye_yuzde": round(
        100 * mk_t["kirsal_bin"] / mk_t["nufus_bin"], 1),
    "katma_deger_payi_misir_yuzde": round(
        100 * mk_m["katma_deger_milyon_usd"] / mk_m["gsyh_milyon_usd"], 2),
    "katma_deger_payi_turkiye_yuzde": round(
        100 * mk_t["katma_deger_milyon_usd"] / mk_t["gsyh_milyon_usd"], 2),
    "pamuk_dusus_yuzde": round(
        100 * (d["urunler"]["pamuk_serisi"]["2024"]["uretim"] /
               d["urunler"]["pamuk_serisi"]["1965"]["uretim"] - 1), 1),
    "pamuk_alan_dusus_yuzde": round(
        100 * (d["urunler"]["pamuk_serisi"]["2024"]["alan"] /
               d["urunler"]["pamuk_serisi"]["1961"]["alan"] - 1), 1),
    # ORTAK TABAN (tur 7). Yukarıdaki iki düşüş ayrı yıllardan ölçülüyor:
    # üretim 1965 ZİRVESİNDEN, alan 1961 BAŞINDAN. İkisi aynı cümlede
    # yan yana konulamaz. Grafik indeksi 1961'den kuruyor; cümle de o
    # tabandan konuşacaksa karşılığı burada duruyor.
    "pamuk_dusus_1961_tabanli_yuzde": round(
        100 * (d["urunler"]["pamuk_serisi"]["2024"]["uretim"] /
               d["urunler"]["pamuk_serisi"]["1961"]["uretim"] - 1), 1),
}
for urun, v in d["urunler"]["karsilastirma"].items():
    d["turetilmis"][f"oran_{urun}"] = round(v["misir"] / v["turkiye"], 2)

# ÜÇ TANENİN İTHAL PAYI — dosyanın çelişkisi tek yerde ölçülüyor.
# Payda ÜRETİM+İTHALAT, tüketim değil: grafiğin çubukları da bu ikisinden
# kuruluyor ve nottaki yüzde ile çubuğun uzunluğu aynı şeyi söylemek
# zorunda. Tüketimle ölçülse çubukla not ayrışırdı.
for ad, blok in (("bugday", d["tahil"]["bugday"]),
                 ("tane_misir", d["tahil"]["tane_misir"]),
                 ("pirinc", d["tahil"]["pirinc"])):
    arz = blok["uretim"] + blok["ithalat"]
    d["turetilmis"][f"{ad}_ithal_payi_arzda_yuzde"] = round(
        100 * blok["ithalat"] / arz, 1)

# PORTAKALIN YÖNÜ — "artıyor" bir iddia; ölçülmeden yazılmaz.
_pc = {r["yil"]: r for r in d["urunler"]["portakal_cizgi"]}
for yil in (1990, 2024):
    if yil in _pc:
        d["turetilmis"][f"oran_portakal_{yil}"] = round(
            _pc[yil]["misir"] / _pc[yil]["turkiye"], 2)

# REDDEDİLEN İLK ÖLÇÜM. Metin bu rakamı UYARI olarak anıyor ("yalnız bir
# dilim okunursa 1.102 bin çıkıyor"). Kaydı olmazsa doğrulayıcı onu uydurma
# sayar; kaydı olurken de doğru rakam gibi görünmemesi için adı açık.
d["makro"]["_reddedilen_ilk_olcum_bin"] = 1102
d["makro"]["_reddedilen_olcum_notu"] = (
    "YANLIŞ RAKAM, kasıtlı olarak kayıtlı. Cinsiyet boyutu süzülmediği için "
    "yalnız bir dilim okunduğunda Mısır tarım istihdamı 1.102 bin çıkıyor. "
    "Doğrusu 5.898 bin. Metin bunu uyarı olarak anıyor.")

# ── GRAFİKLERİN İSTEDİĞİ TÜMLEYENLER ─────────────────────────────────────
# `ikili_cubuk` çizicisi her satırı KENDİ içinde oranlıyor, yani satırın
# bileşen olması şart (TİGEM tur 9'da ölçüldü: bileşen değilse küçük değer
# büyük değerle aynı uzunlukta çiziliyor). Payın tümleyeni burada
# hesaplanıyor; grafik tarifinde "100 eksi şu" diye bir ifade yazılamaz.
tu = d["turetilmis"]
tu["tarim_disi_payi_misir"] = round(100 - tu["tarim_arazisi_payi_misir"], 2)
tu["tarim_disi_payi_turkiye"] = round(100 - tu["tarim_arazisi_payi_turkiye"], 2)
tu["kentli_payi_misir_yuzde"] = round(100 - tu["kirsal_payi_misir_yuzde"], 1)
tu["kentli_payi_turkiye_yuzde"] = round(100 - tu["kirsal_payi_turkiye_yuzde"], 1)
tu["ic_kaynak_payi_yuzde"] = round(100 - d["su"]["disa_bagimlilik_yuzde"], 1)
# METNİN KULLANACAĞI FARKLAR — cümlede çıkarma yapılmaz.
tu["tarim_istihdami_fark_bin"] = round(
    d["makro"]["misir"]["tarim_istihdami_bin"]
    - d["makro"]["turkiye"]["tarim_istihdami_bin"])
_as = d["arazi"]["misir_tarim_arazisi_serisi"]
tu["arazi_artis_1961_1990_bin_ha"] = round(_as["1990"] - _as["1961"])
tu["arazi_artis_1990_2010_bin_ha"] = round(_as["2010"] - _as["1990"])
# Metnin iki oranı daha — cümlede bölme yapılmaz.
tu["kirsal_nufusun_tarim_calisani_payi_yuzde"] = round(
    100 * d["makro"]["misir"]["tarim_istihdami_bin"]
    / d["makro"]["misir"]["kirsal_bin"], 1)
tu["katma_deger_payi_kat"] = round(
    tu["katma_deger_payi_misir_yuzde"] / tu["katma_deger_payi_turkiye_yuzde"], 2)
tu["uc_tane_hasat_alani_bin_ha"] = round(
    d["tahil"]["bugday"]["hasat_alani"] + d["tahil"]["tane_misir"]["hasat_alani"]
    + d["tahil"]["pirinc"]["hasat_alani"])
tu["bugday_tane_misir_alani_bin_ha"] = round(
    d["tahil"]["bugday"]["hasat_alani"] + d["tahil"]["tane_misir"]["hasat_alani"])
# SU DEFTERİNİN ARALIĞI — grafiğin 40 kat kuralına ne kadar yakın olduğu.
# Sayı grafiğin `_aralik_notu` alanında da yazılı; orada ölçülmemiş bir
# rakam bırakmak, sonraki turda onu doğru sanmaya yol açar.
tu["su_aralik_kati"] = round(
    d["su"]["toplam_cekim_milyon_m3"] / d["su"]["ic_yenilenebilir_milyon_m3"], 1)
tu["katma_deger_disi_payi_misir_yuzde"] = round(
    100 - tu["katma_deger_payi_misir_yuzde"], 2)
tu["katma_deger_disi_payi_turkiye_yuzde"] = round(
    100 - tu["katma_deger_payi_turkiye_yuzde"], 2)

# BUĞDAY İTHALATININ KATI — çizginin iki ucu. Tek sayı ama cümlede
# hesaplanmayacak.
_bs = d["tahil"]["bugday_ithalat_serisi"]
_ilk_y = min(_bs, key=int)
tu["bugday_ithalat_ilk_yil"] = int(_ilk_y)
tu["bugday_ithalat_kati"] = round(
    _bs[str(d["tahil"]["kesin_son_yil"])] / _bs[_ilk_y], 1)

# PAMUKTA VERİMİN KATI — indeksin iki serisinin son noktadaki oranı.
# Grafiğin asıl söylediği şey bu: alan üretimden daha çok düştü, aradaki
# fark verim.
_pson = d["urunler"]["pamuk_endeks"][-1]
tu["pamuk_verim_kati"] = round(_pson["uretim"] / _pson["alan"], 2)

# FASILLARIN İKİ YÖNÜ — aynı fasılda hem satıyor hem alıyoruz. Pay, O
# FASLIN iki yönlü toplamına göre; satır toplamı 100 etmek zorunda çünkü
# çizici satır satır oranlıyor.
_gid = {x["fasil"]: x["deger"] for x in d["ticaret"]["fasil_giden"]}
_gel = {x["fasil"]: x["deger"] for x in d["ticaret"]["fasil_gelen"]}
_iki_yonlu = []
for f in sorted(set(_gid) & set(_gel), key=lambda k: -(_gid[k] + _gel[k])):
    t = _gid[f] + _gel[f]
    _iki_yonlu.append({"fasil": f, "toplam_usd": t,
                       "giden_yuzde": round(100 * _gid[f] / t, 1),
                       "gelen_yuzde": round(100 * _gel[f] / t, 1)})
tu["fasil_iki_yonlu"] = _iki_yonlu[:5]
tu["_fasil_iki_yonlu_notu"] = (
    "Pay O FASLIN iki yönlü toplamına göre, bütün ticarete göre değil. "
    "Yalnız iki yönde de satır bulunan fasıllar var; tek yönlü olanlar "
    "(yağ, süt) buraya girmiyor — tek yönlü faslın 'payı' yoktur.")

d["bosluklar"] = []        # §2.2 — her dosyada boş

d["_dosya"] = "Mısır — Ülke Dosyası sayı 06"
d["_eksen"] = ("Kirayla tarım: toprağının kırkta birini ekiyor, suyunun %96,9'u "
               "dışarıdan geliyor, buğdayda dünyanın en büyük alıcısı — ve "
               "rafımızdaki rakip.")
d["_imza"] = "Feddan (0,42 ha). Dosyanın birimi ülke değil bir tarla."
d["_uretim"] = "build_data.py · 12 Kasım 2026"

if hata:
    print("VERİ SAYFASI KİLİTLENMEDİ:", file=sys.stderr)
    for h in hata:
        print("  ✗", h, file=sys.stderr)
    sys.exit(1)

(KOK / "data.json").write_text(json.dumps(d, ensure_ascii=False, indent=1),
                               encoding="utf-8")

kalem = sum(1 for b_ in d.values() if isinstance(b_, dict)
            for k in b_ if not k.startswith("_"))
print(f"veri sayfası kilitlendi · {len(d)-4} blok · ~{kalem} kalem · 23 doğrulamanın 23'ü geçti")
tu = d["turetilmis"]
print(f"  arazi payı      Mısır %{tu['tarim_arazisi_payi_misir']} · Türkiye %{tu['tarim_arazisi_payi_turkiye']}")
print(f"  kişi başına ha  {tu['ha_kisi_misir']} ({tu['feddan_kisi_misir']} feddan) · "
      f"Türkiye {tu['ha_kisi_turkiye']} — {tu['ha_kisi_kat']} kat")
print(f"  buğday          dünya 1.si · tüketimin %{tu['bugday_ithal_payi_yuzde']}'i ithal")
print(f"  ayna farkı      giden %{tu['ayna_fark_giden_yuzde']} · gelen %{tu['ayna_fark_gelen_yuzde']}")
print(f"  pamuk           üretim %{tu['pamuk_dusus_yuzde']} · alan %{tu['pamuk_alan_dusus_yuzde']}")
