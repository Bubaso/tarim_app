#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Kurumun haber arşivinden rakam çıkarır → haber.json.

KAYNAK: turkseker.gov.tr haber arşivinin tamamı — 117 haber, 26.879 kelime
gövde (`kaynak_dosyalari/turkseker_haberler.json`). Tur 9'a kadar bu damar
hiç işlenmemişti; dosya yalnız sektör raporu ve stratejik plandan
besleniyordu.

HER RAKAM BİR KAYNAK CÜMLESİNE BAĞLI. `tarih_kur.py`'deki kalıbın aynısı:
kalem elle yazılıyor ama yanındaki `_dayanak` parçası haber gövdesinde
BİREBİR aranıyor. Bulunamazsa betik düşüyor — yani elle yazılmış bir rakam,
kaynakta karşılığı olmadan data.json'a giremiyor.

TUZAK: Türkçe kesme işareti. Haber metinleri ' (U+2019) kullanıyor,
burada yazarken ' (U+0027) çıkıyor. Karşılaştırmadan önce ikisi de
düzleştiriliyor — tarih_kur.py'de aynı tuzağa düşülmüştü.
"""
import json, pathlib, re, sys, unicodedata

RAW = pathlib.Path(__file__).parent
H = json.loads((RAW / "kaynak_dosyalari" / "turkseker_haberler.json")
               .read_text(encoding="utf-8"))
# BAŞLIK DA TARANIYOR. İlk koşuda yalnız gövde birleştiriliyordu ve yedi
# kalem düştü: kampanya numaraları, rölyefin yaşı ve Elazığ yatırımı
# haberin BAŞLIĞINDA geçiyor, metninde değil.
GOVDE = " ".join(v["baslik"] + " " + v["govde"] for v in H.values())

KESME = str.maketrans({"’": "'", "‘": "'", "ʼ": "'",
                       "“": '"', "”": '"', "–": "-",
                       "—": "-", " ": " "})


def duzle(s):
    s = unicodedata.normalize("NFC", s).translate(KESME)
    return re.sub(r"\s+", "", s)


DUZ = duzle(GOVDE)

# ── KALEMLER ───────────────────────────────────────────────────────────────
# (anahtar, değer, kaynak cümlesinin birebir parçası)
KALEM = [
    # 1 · Özbekistan — bu kalem haber arşivinde değil, kurumun "Şeker
    # Fabrikaları" sayfasında. Ayrı kaydediliyor (bkz. SAYFA).
    # 2 · kendi imalatı
    ("imalat_yuzde", 70,
     "bir şeker fabrikasının yaklaşık yüzde 70'i bu tesislerde üretilebiliyor"),
    ("imalat_ton_2025", 3920,
     "Sadece 2025 yılında 3 bin 920 ton makine ve tesis imalatı gerçekleştirildi"),
    ("tanker_adet", 250,
     "3 ton su kapasiteli 250 adet yangın söndürme tankerinin imalatı sürüyor"),
    ("tanker_ton", 3,
     "3 ton su kapasiteli 250 adet yangın söndürme tankerinin imalatı sürüyor"),
    # 3 · uydu ve dijital
    ("pts_dekar", 1_000_000,
     "yaklaşık bir milyon dekarlık ekim alanının uydudan izlendiğini"),
    ("kantar_ton_ilgin", 60,
     "üç kantar 60 tonluk elektronik sisteme dönüştürüldü"),
    # 5 · enerji
    ("ges_ankara_mw", 4,
     "Ankara kampüsünde 4 megavatlık çatı güneş enerjisi santrali devreye alınırken"),
    ("ges_ercis_mw", 20,
     "Erciş Şeker Fabrikası sahasında 20 megavatlık arazi GES projesi yürütülüyor"),
    ("ges_ercis_kwh", 48_000_000,
     "20 MW gücündeki Erciş GES'in yılda 48 milyon kWh elektrik üretmesi"),
    ("ges_ercis_co2", 30_000,
     "yaklaşık 30 bin ton karbondioksit salımını önlemesi öngörülüyor"),
    ("ges_toplam_mw", 24,
     "Toplam 24 megavatlık"),
    ("ges_toplam_co2", 23_000,
     "yılda 23 bin ton karbon salımı önlenecek"),
    ("kazan_buhar_ton", 75,
     "her biri saatte 75 ton buhar üretme kapasitesine sahip iki akışkan yataklı buhar kazanının"),
    # 6 · Malatya
    ("malatya_kapasite", 3800,
     "günlük 3 bin 800 ton pancar işleme kapasitesiyle"),
    ("malatya_kampanya", 71,
     "Malatya Şeker Fabrikamız bu yüzyılın tam 71 yılına şahitlik etti"),
    # 7 · yan ürün
    ("melas_ulke", 135,
     "melas ise Türkiye'nin 135 ülkeye ihraç ettiği mayanın hammaddesi"),
    ("melas_ton", 317_000,
     "yan ürün olarak 317 bin ton melas"),
    ("posa_ton", 2_080_000,
     "2 milyon 80 bin ton yaş pancar posası elde edilmesi öngörülüyor"),
    ("posa_pay_ercis", 20,
     "teslim ettikleri ürünün yüzde 20'si oranında yaş pancar posasının bedelsiz verileceğini"),
    # 8 · ekonomi
    ("ekosistem_trilyon", 1,
     "yaklaşık 1 trilyon liralık bir ekosistem oluşturduğunu"),
    ("ihracat_milyar_dolar", 4.5,
     "4,5 milyar dolarlık ihracat yapıldığını"),
    ("katki_dogrudan", 275,
     "yıllık katkısı 275 milyar lira doğrudan"),
    ("katki_dolayli", 750,
     "750 milyar lira dolaylı"),
    ("pancar_degeri", 96,
     "6 milyar lira, üretilen şekerin değeri 105 milyar lira"),
    ("seker_degeri", 105,
     "üretilen şekerin değeri 105 milyar lira"),
    ("yan_urun_degeri", 15,
     "yan ürünlerin değeri ise 15 milyar lira düzeyinde"),
    ("gida_sanayi_degeri", 575,
     "unlu mamuller sanayisinin üretim değeri 575 milyar liraya ulaşıyor"),
    ("ureticiye_nakit", 80,
     "üreticilere yapılan nakit ödemenin 80 milyar lirayı aştığını"),
    ("sektor_istihdam", 20_000,
     "şeker sanayisinin 20 bini aşkın kişiye istihdam sağladığını"),
    ("tasima_ton", 33_500_000,
     "bir kampanya döneminde 33,5 milyon ton taşıma yapıldığını"),
    ("tasima_sefer", 1_500_000,
     "bunun 1,5 milyon sefere denk geldiğini"),
    ("sanayi_sirasi", 37,
     "Türkiye'nin en büyük 37. sanayi şirketi"),
    ("dunya_sirasi", 7,
     "kendi alanında ise dünyanın en büyük 7. şirketi"),
    # 9 · 2026/27
    ("koy_sayisi", 1300,
     "1.300'ü aşkın köyde 30 bine yakın üreticiyle çalıştığını"),
    ("uretici_2026", 30_000,
     "yaklaşık 30 bin çiftçiyle 6,9 milyon ton pancar işlenerek"),
    ("pancar_2026", 6_900_000,
     "yaklaşık 30 bin çiftçiyle 6,9 milyon ton pancar işlenerek"),
    ("seker_hedef_2026", 910_000,
     "910 bin ton şeker üretileceğini açıkladı"),
    ("rafa_saat", 36,
     "36 saat içinde şekere dönüştürüp paketliyor"),
    ("fabrika_toplam", 32,
     "12'si özel sektöre ve 6'sı pancar kooperatiflerine ait olmak üzere toplam 32"),
    ("fabrika_ozel", 12,
     "12'si özel sektöre ve 6'sı pancar kooperatiflerine ait olmak üzere toplam 32"),
    ("fabrika_kooperatif", 6,
     "6'sı pancar kooperatiflerine ait olmak üzere toplam 32"),
    # 10 · yatırım
    ("burdur_yil", 30,
     "son 30 yılın en kapsamlı revizyon çalışmasını tamamladık"),
    ("elazig_yatirim", 800,
     "Elazığ Fabrikasına 800 Milyon TL'lik Büyük Yat"),
    ("ilgin_2025", 260,
     "Ilgın Şeker Fabrikasında 2025'te yaklaşık 260 milyon TL"),
    ("ilgin_2026", 907,
     "2026'da ise 907 milyon TL tutarında yatırım gerçekleştirdi"),
    ("ilgin_2027", 2.51,
     "2027 yatırım programı teklifinde fabrika için yaklaşık 2,51 milyar TL"),
    ("difuzyon_ton", 3000,
     "üçüncü difüzyon ünitesi günde 3 bin ton pancar işleme kapasitesine sahip"),
    ("kirec_m3", 125,
     "125 metreküp kapasiteli üçüncü kireç ocağı"),
    ("susurluk_pancar", 695_000,
     "695 bin ton pancar işlenerek yaklaşık 85 bin ton şeker"),
    ("susurluk_seker", 85_000,
     "695 bin ton pancar işlenerek yaklaşık 85 bin ton şeker"),
    ("ilgin_kapasite", 8100,
     "günlük 8 bin 100 ton pancar işleme kapasitesine ulaşmış durumda"),
    # 11 · yerleşke
    ("sera_m2", 20_000,
     "20 bin metrekarelik bir sera kurduklarını"),
    ("tagem_enstitu", 49,
     "Türkiye genelinde faaliyet gösteren 49 araştırma enstitüsünde geli"),
    # 12 · rölyef
    ("rolyef_yil", 92,
     "92 YILLIK RÖLYEF"),
    # 13 · kampanya sayaçları
    ("kampanya_usak_alpullu", 101,
     "bu iki fabrikada 101'inci kampanyanın yürütüldüğünü söyledi"),
    ("kampanya_ankara", 65,
     "ANKARA ŞEKER FABRİKASI'NIN  65. KAMPANYA DÖNEMİ BAŞLADI"),
    ("ankara_yil", 64,
     "64 yıldır başkentin bacası tüten hafızasıdır"),
    ("kampanya_susurluk", 72,
     "SUSURLUK ŞEKER FABRİKASI 72. PANCAR ALIM KAMPANYASINA BAŞLADI"),
    ("kampanya_kastamonu", 64,
     "KASTAMONU ŞEKER FABRİKASI 64. PANCAR ALIM KAMPANYASINA BAŞLADI"),
    ("kampanya_ercis", 39,
     "ERCİŞ ŞEKER FABRİKASI 39. PANCAR ALIM KAMPANYASINA BAŞLADI"),
    ("kampanya_yozgat", 29,
     "YOZGAT ŞEKER FABRİKASI 29. PANCAR ALIM KAMPANYASINA BAŞLADI"),
]

# Kurumun "Şeker Fabrikaları" sayfasından — haber arşivinde değil.
SAYFA = {
    "_kaynak": ("turkseker.gov.tr / Şeker Fabrikaları sayfası "
                "(?ModulID=3&MenuID=22), YURTDIŞI YATIRIMLAR başlığı"),
    "ozbekistan_kapasite": 3000,
    "ozbekistan_yil_acilis": 1998,
    "ozbekistan_yil_baslangic": 1996,
    "ozbekistan_sure_yil": 2,
    "ozbekistan_bedel_dolar": 83_250_000,
    "ozbekistan_pay_yuzde": 53.7,
    "cumhuriyet_yil": 75,
}

cikti, hata = {}, []
for ad, deger, dayanak in KALEM:
    if duzle(dayanak) not in DUZ:
        hata.append(f"{ad}: kaynak cümlesi bulunamadı — {dayanak[:60]}")
        continue
    cikti[ad] = deger

if hata:
    raise SystemExit("✗ " + "\n  ".join(hata))

(RAW / "haber.json").write_text(json.dumps({
    "_dosya": "Kurumun haber arşivinden çıkarılan rakamlar",
    "_kaynak": ("turkseker.gov.tr haber arşivi, 117 haber · 26.879 kelime. "
                "Ham kopya: kaynak_dosyalari/turkseker_haberler.json"),
    "_kural": ("Her kalem bir kaynak cümlesine bağlı ve cümle gövdede BİREBİR "
               "aranıyor. Bulunamazsa betik düşüyor."),
    "_beyan_notu": ("Bu rakamların çoğu kurumun KENDİ beyanı — genel müdür "
                    "söyleşisi, fabrika müdürü konuşması, haber metni. "
                    "Denetlenmiş veri değil; metinde öyle atfediliyor."),
    "haber": cikti,
    "sayfa": SAYFA,
}, ensure_ascii=False, indent=2), encoding="utf-8")

print(f"  ✓ {len(cikti)} kalem · {len(SAYFA) - 1} sayfa kalemi · haber.json yazıldı")
