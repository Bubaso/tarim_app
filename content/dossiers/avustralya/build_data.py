#!/usr/bin/env python3
"""Avustralya — data.json üretimi.

    python3 content/dossiers/avustralya/build_data.py

NEDEN BETİK. Kalemler üç ayrı cinsten geliyor ve karıştırılmaları sessiz
hata üretir:
  BİRİNCİL        Water Act 1989 (Victoria) tasdikli metni; ACCC'nin imzalı
                  gözlemci beyanı
  SİCİLİN BEYANI  Victoria Su Sicili — piyasayı İŞLETEN idarenin kendi defteri
  BAĞIMSIZ        Meteoroloji Bürosu (su piyasasıyla ilgisi olmayan kurum)

Her blok `_kaynak_niteligi` taşımak ZORUNDA; taşımayan blok üretimi durdurur.

── DÖRT SAĞLAMA ────────────────────────────────────────────────────────────
1. ALINTI BAĞI. Her alıntı ham metinde aranır; bulunamazsa üretim durur.
   PDF çıkarımı kelime ortasına boşluk sokuyor ("oppor tunity") ve ulusal
   rapor binlik ayıracı olarak BOŞLUK kullanıyor ("14 270 GL") — bu yüzden
   karşılaştırma boşluk toleranslı.
2. KAPSAM. Her blok `_kapsam` taşımak zorunda; Victoria kaynaklı blokların
   kapsamında "Victoria" geçmek zorunda. Eyalet verisini ülke verisi gibi
   sunmak §2.2'nin yasağı.
3. ZAMAN FARKI. Ulusal rakam 2019-20'de, piyasa verisi 2023-24'te.
   `_zaman_farki` bunu kayda geçiriyor ki metinde aynı yılmış gibi sunulmasın.
4. İKİ AÇILIŞ. Temmuz 2026 raporu İKİ ticaret açılışı anlatıyor:
   Goulburn→Murray (darlık yok) ve Barmah Narrows (darlık var). İlk özette
   bu ikisinin rakamları karıştırılmıştı. Betik onları ayrı tutuyor ve onay
   oranlarını KARŞILAŞTIRILABİLİR kapsamda kendi hesaplıyor.
"""
import json, re, sys
from pathlib import Path

KOK = Path(__file__).parent
HAM = KOK / "_raw"
KD = HAM / "kaynak_dosyalari"
hata = []

oku_json = lambda p: json.loads((HAM / p).read_text(encoding="utf-8"))
oku_metin = lambda p: (KD / p).read_text(encoding="utf-8")

def harfler(s: str) -> str:
    """Boşluk toleranslı karşılaştırma anahtarı (bkz. sağlama 1)."""
    return re.sub(r"[^0-9a-zA-Z]", "", s).lower()

def alinti(dosya: str, metin: str, etiket: str) -> str:
    ham = harfler(oku_metin(dosya))
    if harfler(metin) not in ham:
        hata.append(f"ALINTI BAĞI KOPUK · {etiket} · {dosya}:\n    {metin[:110]}")
    return metin

KANUN, EGILIM, KURA, ACCC = ("vic_su_kanunu_1989.txt", "egilim_2001_2024.txt",
                             "kura_raporu_2026.txt", "accc_kura_2026.txt")
ULUSAL, BOM = "ulusal_su_2019_20.txt", "bom_kuraklik_merkezi.txt"

# ══ 1. BİRİNCİL — hakkın hukuki kuruluşu ═════════════════════════════════
kanun = {
 "_kaynak_niteligi": "BİRİNCİL — Water Act 1989 (Victoria), Tasdikli Sürüm No. 147",
 "_kaynak": "legislation.vic.gov.au · Baş Parlamento Müşaviri tasdiki, 24 Haziran 2026",
 "_kapsam": "Victoria eyaleti mevzuatı",
 "surum": 147, "sayfa": 923,
 "tanim": alinti(KANUN, "water share means a water share issued under Division 2 of Part 3A", "su payı tanımı"),
 "ihdas": alinti(KANUN, "The Minister may issue a water share in respect of a declared water system", "m. 33F(1)"),
 "dayanak_dipnot": alinti(KANUN, "S. 33F inserted by No. 99/2005 s. 41", "m. 33F dayanağı"),
 "dayanak_kanun": "Water (Resource Management) Act 2005, No. 99/2005",
 "tasdik_tarihi": "2005-12-07",
 "yururluk_tarihi": "2006-08-03",
 "yururluk_dayanagi": "Özel Resmî Gazete No. 191, 2.8.06 s. 1 — ss 35–57 bu tarihte",
 "pay_kismi": alinti(KANUN, "Part 3A—Water shares", "Kısım 3A"),
 "kullanim_kismi": alinti(KANUN, "Part 4B—Water-use licences and water use registrations", "Kısım 4B"),
 "arazide_kullanim_yasagi": alinti(KANUN, "use water on land", "m. 64J"),
 "ipotek": alinti(KANUN, "mortgage of a water share", "payın ipoteği"),
 "sicil_kaydi": alinti(KANUN, "the name and address of", "m. 84I — malikin adı ve adresi"),
 "sicil_gecis_sayisi": 190, "memur_gecis_sayisi": 154,
 "_not": "Kanunda 'separate from land' gibi bir BEYAN cümlesi YOK. Ayrışma iki "
         "ayrı kısmın varlığından okunuyor. Metinde kanundan böyle bir cümle "
         "alıntılanmayacak.",
}

# ══ 2. SİCİLİN BEYANI — ayrışmanın takvimi ve tavanları ══════════════════
takvim = {
 "_kaynak_niteligi": "SİCİLİN BEYANI — Victoria Su Sicili, eğilim raporu Ek 1",
 "_kapsam": "kuzey Victoria",
 "ayrisma_gunu": "2007-07-01",
 "ayrisma_alintisi": alinti(EGILIM, "When unbundling occurred in northern Victoria (1 July 2007)", "ayrışmanın günü"),
 "ayrisma_notu": alinti(EGILIM, "all water shares were associated with land", "o gün hepsi toprakla birlikteydi"),
 "tavan_yuzde": 10,
 "tavan_alintisi": alinti(EGILIM, "no more than 10% of the water share volume in a system could be owned without being linked to land", "%10 tavanı"),
 "tavan_kaldirildi": 2009,
 "cikis_tavani_yuzde": 4,
 "cikis_tavani_alintisi": alinti(EGILIM, "no more than 4% of the water share volume in an irrigation area could be moved out the area in a year", "%4 çıkış tavanı"),
 "cikis_tavani_kaldirildi": 2014,
 "birliktelik_kaldirildi": "2023-11-20",
 "birliktelik_alintisi": alinti(EGILIM, "removed the ability to associate a water share with land", "birlikteliğin tasfiyesi"),
 "_yontem_uyarisi": "Rapor 2023 değişikliği nedeniyle 'linked to land' yöntemine "
   "geçti; eski 'tied to land' ile farkı Şekil 17'de, yani GRAFİKTE — metinden "
   "çıkarılamıyor. Tablo 6'nın başlığı eski ibareyi taşısa da verisi yeni yöntem "
   "(2023-24'te iki tablo da 1.262 GL). Metinde tied/linked ayrımı üzerine cümle "
   "kurulmayacak.",
}

# ══ 3. SİCİLİN BEYANI — seriler ══════════════════════════════════════════
T = oku_json("tablolar.json")
ORTAK = {"_kaynak_niteligi": "SİCİLİN BEYANI — Victoria Su Sicili",
         "_kapsam": "kuzey Victoria — Avustralya geneli DEĞİL"}

def seri(anahtar):
    k = T[anahtar]
    d = {**ORTAK, "_tablo": k["_tablo"], "_baslik": k["_baslik"],
         "_birim": k["_birim"], "kayitlar": k["kayitlar"]}
    for ek in ("_2008_09_tutarsizligi", "_nitelik"):
        if ek in k:
            d[ek] = k[ek]
    return d

sahiplik, kullanim = seri("sahiplik"), seri("kullanim")
ilk, son = sahiplik["kayitlar"][0], sahiplik["kayitlar"][-1]
sahiplik.update(ilk_yil=ilk["yil"], son_yil=son["yil"],
  ilk_topraga_bagli_yuzde=ilk["topraga_bagli_pay_yuzde"],
  son_topraga_bagli_yuzde=son["topraga_bagli_pay_yuzde"],
  son_topraksiz_yuzde=son["topraga_bagli_degil_pay_yuzde"],
  son_cevre_yuzde=son["cevre_pay_yuzde"])
en = max(kullanim["kayitlar"], key=lambda k: k["kullanim_oran_yuzde"])
az = min(kullanim["kayitlar"], key=lambda k: k["kullanim_oran_yuzde"])
kullanim["en_yuksek_oran"] = {"yil": en["yil"], "oran": en["kullanim_oran_yuzde"]}
kullanim["en_dusuk_oran"] = {"yil": az["yil"], "oran": az["kullanim_oran_yuzde"]}

fiyat = seri("pay_yuksek_guvenilir")
fy = [k for k in fiyat["kayitlar"] if k["medyan_fiyat_aud_ml"]]
fiyat["en_dusuk"] = min(fy, key=lambda k: k["medyan_fiyat_aud_ml"])
fiyat["en_yuksek"] = max(fy, key=lambda k: k["medyan_fiyat_aud_ml"])
fiyat["kat"] = round(fiyat["en_yuksek"]["medyan_fiyat_aud_ml"]
                     / fiyat["en_dusuk"]["medyan_fiyat_aud_ml"], 2)

fiyat_dusuk = seri("pay_dusuk_guvenilir")
topraksiz = seri("topraksiz_suyun_akibeti")
ticaret = seri("tahsis_ticareti")
katilim = seri("piyasa_katilimi")
kaynak_dag = seri("kaynak_dagilimi")
katilim["_bulgu"] = alinti(EGILIM, "no evidence of systematic differences in the price",
                           "sık ticaret yapanlar — fiyat farkı bulgusu")

# ══ 4. SİCİL — darlığın fiyat imzası, bağımlılık, gerekçe ════════════════
darlik_fiyati = {
 "_kaynak_niteligi": "SİCİLİN BEYANI — Victoria Su Sicili, eğilim raporu",
 "_kapsam": "kuzey Victoria, Murray 7. bölge (Barmah'ın aşağısı)",
 "bolge": "Murray zone 7 — Barmah'ın aşağısı",
 "dusuk_guvenilir_2018_07_aud_ml": 444,
 "dusuk_guvenilir_2024_06_aud_ml": 1861,
 "artis_kati": round(1861 / 444, 2),
 "alinti": alinti(EGILIM, "low-reliability water share prices increased from $444 per ML in July 2018 to $1,861 per ML in June 2024", "7. bölge fiyatı"),
 "neden_alintisi": alinti(EGILIM, "increasing allocation trade restrictions into the region", "ticaret kısıtlarının artması"),
 "talep_alintisi": alinti(EGILIM, "growth in perennial horticulture demand downstream of Barmah", "bahçe talebi"),
 "_not": "Rapor nedeni İKİ etkene bağlıyor: bahçe talebinin yüksek ödeme isteği "
         "VE bölgeye tahsis ticareti kısıtlarının artması. Tek nedene indirgenmeyecek.",
}
ticarete_bagimlilik = {
 "_kaynak_niteligi": "SİCİLİN BEYANI — Victoria Su Sicili, eğilim raporu",
 "_kapsam": "kuzey Victoria", "yil": "2023-24",
 "alinti": alinti(EGILIM, "LMW diverters are the private water user group most dependent on trade", "ticarete en bağımlı grup"),
 "lmw_ceken_kendi_kaynagi_yuzde": 61, "lmw_ceken_yeni_mevsimlik_gl": 237,
 "lmw_ceken_devreden_gl": 20, "gmw_bolge_yuzde": 140,
 "gmw_ceken_yuzde": 223, "lmw_bolge_yuzde": 103,
 "oran_alintisi": alinti(EGILIM, "accounted for only 61% of LMW diverters", "kendi kaynağının payı"),
}
gerekce = {
 "_kaynak_niteligi": "SİCİLİN BEYANI — Victoria Su Sicili, eğilim raporu",
 "_kapsam": "kuzey Victoria", "baslangic_yili": "2020-21",
 "baslangic_alintisi": alinti(EGILIM, "2020-21 was the year collection for", "gerekçe verisinin başlangıcı"),
 "kategori_alintisi": alinti(EGILIM, "standard commercial trade, related party trade, carryover parking, carryover parking return, private lease arrangement, allocation trade as part of a water share transfer, forward contract", "ticaret gerekçesi kategorileri"),
 "kategori_sayisi": 8,
 "_not": "Sekizinci kategori 'other'. Listede 'forward contract' ve 'private "
         "lease arrangement' var — vadeli sözleşme ve özel kira.",
}

# ══ 5. BİRİNCİL + SİCİL — KURA ═══════════════════════════════════════════
oran = lambda a, b: round(100 * a / b, 1)
kura = {
 "_kaynak_niteligi": "BİRİNCİL (ACCC beyanı) + SİCİLİN BEYANI (açılış raporu)",
 "_kapsam": "Victoria ve NSW başvuruları, 2 Temmuz 2026 açılışı",
 "_uyari": "İKİ AYRI AÇILIŞ. Barmah'ta darlık var, Goulburn→Murray'de yok. "
           "Rakamları karıştırmak kolay; ilk özette karıştırılmıştı.",
 "basvuru_gunu": "2026-07-02", "cekilis_gunu": "2026-07-03",
 "bogaz_akis_siniri_ml_gun": 7000,
 "bogaz_alintisi": alinti(KURA, "restricts the river flow to just around 7,000 ML per day", "darlığın akış sınırı"),
 "kura_alintisi": alinti(KURA, "eligible applications were randomised to determine the order in which they would be processed", "kura mekanizması"),
 "gozlem_alintisi": alinti(KURA, "independently observed by the Australian Competition and Consumer Commission", "ACCC gözlemi"),
 "gecici_cozum": alinti(KURA, "The randomisation approach has been implemented as an interim solution", "sicilin kendi ifadesiyle geçici çözüm"),
 "accc": {
   "_kaynak_niteligi": "BİRİNCİL — ACCC'nin imzalı yazısı, 3 Ağustos 2026",
   "imza": alinti(ACCC, "Acting General Manager", "imza yetkisi"),
   "kayit_incelemesi": alinti(ACCC, "reviewed a recording of that process", "kaydın incelenmesi"),
   "duzenleme_yok": alinti(ACCC, "did not observe any editing or changes to the output of the randomisation tool", "çıktıda değişiklik yok beyanı"),
 },
 "barmah": {
   "_darlik": True, "kapasite_ml": 24121.3,
   "kapasite_alintisi": alinti(KURA, "The total Barmah trade opportunity made available at 7:00 am 2 July was 24,121.3 ML", "Barmah kapasitesi"),
   "uygun_basvuru_toplam": 214, "uygun_hacim_toplam_ml": 67445.2,
   "talep_alintisi": alinti(KURA, "significantly exceeded the available trade oppor tunity", "talebin kapasiteyi aşması"),
   "vic": {"alinan": 138, "alinan_hacim_ml": 31477.8, "uygun": 136,
           "uygun_hacim_ml": 31253.1, "onaylanan": 33,
           "onaylanan_hacim_ml": 8884.2, "reddedilen": 103,
           "reddedilen_hacim_ml": 22386.9},
   "nsw": {"uygun": 78, "uygun_hacim_ml": 36192.1, "onaylanan": 29,
           "onaylanan_hacim_ml": 15218.2},
   "vic_en_kucuk_ml": 20.4, "vic_en_buyuk_ml": 2484.4,
   "vic_ortanca_ml": 110, "vic_ortalama_ml": 230,
   "aracidan_basvuru": 73, "aracidan_hacim_ml": 17645.5,
   "cevrimici_basvuru": 65, "cevrimici_hacim_ml": 13832.3,
   "kanal_alintisi": alinti(KURA, "73 applications were received via the Broker Portal", "aracı portalı"),
   "ortanca_alintisi": alinti(KURA, "The median volume of Victorian applications was 110 ML", "ortanca başvuru"),
 },
 "goulburn_murray": {
   "_darlik": False,
   "_kapsam_notu": "Bu açılışın rakamları EYALET AYRIMI OLMADAN, iki eyaletin "
     "toplamı olarak yayımlanmış. Barmah rakamları ise eyalet eyalet. "
     "Karşılaştırma TOPLAMLAR üzerinden; Victoria'ya özel oranla yan yana konmaz.",
   "kapasite_ml": 112827.9,
   "kapasite_alintisi": alinti(KURA, "The total Goulburn-to-Murray trade opportunity made available at 7:00 am 2 July 2026 was 112,827.9 ML", "G→M kapasitesi"),
   "alinan": 290, "alinan_hacim_ml": 120869.9, "uygun": 286,
   "uygun_hacim_ml": 119285.3, "onaylanan": 282,
   "onaylanan_hacim_ml": 112555.3, "reddedilen": 4, "reddedilen_hacim_ml": 6730,
 },
}
b, g = kura["barmah"], kura["goulburn_murray"]
b["toplam_onaylanan"] = b["vic"]["onaylanan"] + b["nsw"]["onaylanan"]
b["onay_orani_yuzde"] = oran(b["toplam_onaylanan"], b["uygun_basvuru_toplam"])
b["vic_onay_orani_yuzde"] = oran(b["vic"]["onaylanan"], b["vic"]["uygun"])
b["asim_kati"] = round(b["uygun_hacim_toplam_ml"] / b["kapasite_ml"], 2)
g["onay_orani_yuzde"] = oran(g["onaylanan"], g["uygun"])
g["asim_kati"] = round(g["alinan_hacim_ml"] / g["kapasite_ml"], 2)
kura["talep_kapasite_kati"] = b["asim_kati"]

# ══ 6. BAĞIMSIZ — kuraklık ═══════════════════════════════════════════════
kh = oku_json("kuraklik.json")
kuraklik = {
 "_kaynak_niteligi": "BAĞIMSIZ — Meteoroloji Bürosu",
 "_kapsam": "Avustralya geneli; bildiriler BÖLGE bölge yazılmış",
 "bildiri_sayisi": kh["bildiri_sayisi"], "ilk": kh["ilk"], "son": kh["son"],
 "bildirisiz_dizi_ay": kh["en_uzun_bildirisiz_dizi_ay"],
 "bildirisiz_dizi": "Ekim 2011 – Mayıs 2012",
 "ilan_yok": alinti(BOM, "the Bureau does not declare a drought", "Büro ilan etmez"),
 "ilan_yok_devam": alinti(BOM, "The Australian Government does not make drought declarations", "hükûmet de etmez"),
 "eyalet_yetkisi": alinti(BOM, "State and territory governments administer and coordinate drought policies", "politika eyaletlerde"),
 "tanim": alinti(BOM, "a prolonged, abnormally dry period when there's not enough water available for normal use", "kuraklık tanımı"),
 "_bolge_uyarisi": "2011'de yayımlanan bildiriler güneybatı Batı Avustralya'yı "
   "anlatıyor, Murray-Darling'i değil. Doğudaki kuraklık o sırada kırılmıştı. "
   "'Avustralya'nın kuraklığı' denmeyecek.",
 "_zamanlama_uyarisi": "Bildirisiz dizi su yılı 2011-12'ye düşüyor (kullanım "
   "oranı %118). En düşük oran (%41) 2010-11'de. 'Büro susunca kullanım düştü' "
   "nedenselliği KURULAMAZ.",
}

# ══ 7. BAĞIMSIZ — ulusal ölçek ═══════════════════════════════════════════
ulusal = {
 "_kaynak_niteligi": "BAĞIMSIZ — Meteoroloji Bürosu, Water in Australia 2019–20",
 "_kapsam": "Avustralya geneli",
 "_zaman_farki": "Bu blok 2019-20'ye ait. Piyasa serileri 2023-24'e kadar "
   "geliyor. DÖRT YILLIK FARK; aynı cümlede aynı yılmış gibi sunulmayacak. "
   "Raporun 2020-21 ve sonrası sürümleri yayımda değil.",
 "yil": "2019-20", "tuketim_toplam_gl": 14270,
 "tuketim_alintisi": alinti(ULUSAL, "Total water taken in Australia for consumptive use was 14 270 GL", "ulusal tüketim"),
 "vic_nsw_payi": alinti(ULUSAL, "Agricultural water-use in Victoria and New South Wales accounted for half of Australia", "Vic+NSW yarısı"),
 "nsw_tarim_gl": 2490,
 "depo_doluluk_gl": 23140, "depo_doluluk_yuzde": 46, "depo_kapasite_gl": 50500,
 "piyasa_cirosu": "1–7 milyar AUD/yıl (BoM tahmini)",
 "_ciro_uyarisi": "Aralık çok geniş; 'tahmini' ibaresi düşürülmeyecek.",
}

# ══ 8. KRONOLOJİ — türetilmiş, yeni olgu YOK ═════════════════════════════
kronoloji = {
 "_kaynak_niteligi": "TÜRETİLMİŞ — yukarıdaki bloklardaki tarihlerin sayısal "
                     "izdüşümü; yeni olgu içermez",
 "_kapsam": "Victoria",
 "kanun_yili": 1989,
 "dayanak_tasdik_yili": int(kanun["tasdik_tarihi"][:4]),
 "yururluk_yili": int(kanun["yururluk_tarihi"][:4]),
 "ayrisma_yili": int(takvim["ayrisma_gunu"][:4]),
 "tavan_kaldirma_yili": takvim["tavan_kaldirildi"],
 "cikis_tavani_kaldirma_yili": takvim["cikis_tavani_kaldirildi"],
 "birliktelik_kaldirma_yili": int(takvim["birliktelik_kaldirildi"][:4]),
 "kura_yili": int(kura["cekilis_gunu"][:4]),
 "ulusal_olcum_yili": 2019,
}

# ══ SAĞLAMALAR ═══════════════════════════════════════════════════════════
govde = {"kanun": kanun, "ayrisma_takvimi": takvim, "sahiplik": sahiplik,
 "kullanim": kullanim, "pay_fiyati": fiyat, "pay_fiyati_dusuk": fiyat_dusuk,
 "topraksiz_su": topraksiz, "tahsis_ticareti": ticaret,
 "piyasa_katilimi": katilim, "kaynak_dagilimi": kaynak_dag,
 "darlik_fiyati": darlik_fiyati, "ticarete_bagimlilik": ticarete_bagimlilik,
 "ticaret_gerekcesi": gerekce, "kura": kura, "kuraklik": kuraklik,
 "ulusal": ulusal, "kronoloji": kronoloji}

for ad, blok in govde.items():
    if "_kaynak_niteligi" not in blok:
        hata.append(f"KAYNAK NİTELİĞİ YOK · '{ad}'")
    if "_kapsam" not in blok:
        hata.append(f"KAPSAM YOK · '{ad}'")

VIC = ("sahiplik","kullanim","pay_fiyati","pay_fiyati_dusuk","topraksiz_su",
       "tahsis_ticareti","piyasa_katilimi","kaynak_dagilimi")
for ad in VIC:
    if "Victoria" not in govde[ad]["_kapsam"]:
        hata.append(f"KAPSAM HATASI · '{ad}' Victoria verisi ama kapsamı öyle demiyor")
    for k in govde[ad].get("kayitlar", []):
        if not isinstance(k.get("yil_no"), int):
            hata.append(f"SAYISAL YIL YOK · '{ad}' · {k.get('yil')}")
            break

_k = [kronoloji[a] for a in ("kanun_yili","dayanak_tasdik_yili","yururluk_yili",
      "ayrisma_yili","tavan_kaldirma_yili","cikis_tavani_kaldirma_yili",
      "birliktelik_kaldirma_yili","kura_yili")]
if _k != sorted(_k):
    hata.append(f"KRONOLOJİ SIRASIZ · {_k}")

if hata:
    print("ÜRETİM DURDU:\n", file=sys.stderr)
    for h in hata:
        print("  ✗ " + h, file=sys.stderr)
    sys.exit(1)

out = {"_dosya": "Avustralya — Ülke Dosyası Sayı 04 · veri katmanı",
       "_uretim": "build_data.py — elle düzenlenmez",
       "_eksen": "Su, topraktan hukuken ayrılmış, fiyatı olan, alınıp satılan "
                 "bir mülkiyet hakkıdır; kapasite bittiğinde sıra kurayla belirlenir.",
       **govde}
(KOK / "data.json").write_text(json.dumps(out, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

print(f"✓ data.json · {len(govde)} blok")
for ad, b_ in govde.items():
    n = len(b_.get("kayitlar", [])) if isinstance(b_.get("kayitlar"), list) else 0
    print(f"  {ad:<22s} {b_['_kaynak_niteligi'][:44]:<46s}" + (f"{n:>4d} satır" if n else ""))
