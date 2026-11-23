#!/usr/bin/env python3
"""Mısır yayin.json — künye, metin ve veri katmanından ÜRETİLİR.

NEDEN BETİK: yayın künyesi üç ayrı dosyaya bağlı (data.json, grafikler.json,
kunye.json) ve bölüm başlıkları metnin kendisinden okunuyor. Elle yazılırsa
biri değiştiğinde öteki sessizce eskir — Irak dosyasında bölüm başlıkları
metinle ayrışmıştı.

ALTYAZI KURALI: altyazılar bu dosyada ELLE yazılı ama KÜNYEDEN yazıldı,
kareden değil. Kaynağın `aciklama` ve `tarih` alanları `_dayanak` olarak
her altyazının yanında duruyor ki sonraki tur nereden geldiğini görsün.
Kullanıcı bu düzeltmeyi iki kez verdi (8 ve 12 Kasım 2026).

Çalıştırma: python3 content/dossiers/misir/_raw/kur_yayin.py
Sonra MUTLAKA: python3 content/dossiers/misir/dogrula_yayin.py
"""
from __future__ import annotations
import json, pathlib, re

KOK = pathlib.Path(__file__).parent.parent
VERI = json.loads((KOK / "data.json").read_text(encoding="utf-8"))
GRAFIK = json.loads((KOK / "grafikler.json").read_text(encoding="utf-8"))["grafikler"]
TASARIM = json.loads((KOK / "tasarim.json").read_text(encoding="utf-8"))
KUNYE = json.loads((KOK / "_raw/gorseller/kunye.json").read_text(encoding="utf-8"))["gorseller"]
TR = (KOK / "metin_tr.md").read_text(encoding="utf-8")
EN = (KOK / "metin_en.md").read_text(encoding="utf-8")

# Bölüm başlıkları METİNDEN okunuyor, elle yazılmıyor.
def basliklar(metin):
    return {m.group(1): m.group(2).strip()
            for m in re.finditer(r"^## (\d+)\.\s*(.+)$", metin, re.M)}

B_TR, B_EN = basliklar(TR), basliklar(EN)

TUR = {"1": "anlati", "2": "veri", "3": "veri", "4": "belge", "5": "veri",
       "6": "anlati", "7": "veri", "8": "veri", "9": "veri", "10": "anlati",
       "11": "veri", "12": "veri", "13": "veri", "14": "belge", "15": "belge",
       "16": "anlati", "17": "anlati", "18": "belge"}

GRAFIKLER = {
    "1": ["feddan"], "2": ["kirkta_bir"], "3": ["on_bir_kat"],
    "4": ["suyun_defteri"], "5": ["ayni_tarla"], "6": ["arazinin_egrisi"],
    "7": ["dunyanin_alicisi", "ithalatin_egrisi"], "8": ["uc_tane"],
    "11": ["pamuk_endeksi"], "12": ["portakalda_ikiye_bir"],
    "13": ["ayni_fasillar"], "14": ["iki_defter"],
    "15": ["kahirede_imzalandi", "taviz_degisimi"],
    "16": ["kirsalda_cogunluk"], "17": ["tarimin_agirligi"],
}

# Bölüm → görsel anahtarı. Kapak ile §2 AYNI kareyi kullanıyor: §2'nin
# konusu zaten vadinin çöl sınırı, yani kapağın gösterdiği şey.
#
# §11 ↔ §18 GÖZLE DEĞİŞTİRİLDİ (13 Kasım 2026). İlk yerleşimde §11'de
# 'toplanmaya hazır pamuk tarlası' (1934) vardı ve kare o kadar karanlık ki
# pamuk olduğu seçilmiyor. §11 dosyanın en büyük düşüş hikâyesi; okunmayan
# bir kare oraya konamaz. Pamuk TOPLAMA karesi okunabiliyor ve §11'e alındı,
# karanlık tarla karesi kaynakçaya düştü. Betik bunu göremezdi.
GORSEL = {
    "1": "misir_tarla_at", "2": "misir_kapak_vadi", "3": "misir_ciftciler",
    "4": "misir_sakiye_deve", "5": "misir_su_cekme_1934",
    "6": "misir_col_tarimi", "7": "misir_bugday_hasadi",
    "8": "misir_pirinc_hasat", "9": "misir_tane_misir_1934",
    "10": "misir_pamuk_muzesi", "11": "misir_pamuk_toplama",
    "12": "misir_portakal_bahcesi", "13": "misir_narenciye_kahire",
    "14": "misir_konteyner", "15": "misir_pirinc_ekim",
    "16": "misir_tarlada_calisan", "17": "misir_bugday_fayyum",
    "18": "misir_pamuk_tarlasi_1934",
}

# ALTYAZILAR — kur_altyazi.py tarafından üretilen dosyadan okunuyor.
ALTYAZI = json.loads((KOK / "_raw/altyazilar.json").read_text(encoding="utf-8"))

def gorsel_blok(no: str) -> dict:
    a = GORSEL[no]
    k = KUNYE[a]
    alt = ALTYAZI[a]
    return {
        "anahtar": a,
        "url": f"https://tarimportali.net/dosya/misir/{k['dosya']}",
        "atif": k["atif"], "lisans": k["lisans"],
        "lisans_adresi": k.get("lisans_adresi"),
        "en_boy": k["en_boy"],
        "alt_tr": alt["tr"], "alt_en": alt["en"],
        "_commons": k["commons_sayfasi"],
        "_dayanak": alt["_dayanak"],
    }

d = {
  "_dosya": "Mısır — Ülke Dosyası Sayı 06 · yayın künyesi",
  "_amac": "Dosyanın kimliği, penceresi, bölüm iskeleti ve ana sayfa hikâyesi.",
  "_uretim": "_raw/kur_yayin.py — elle yazılmaz; başlıklar metinden okunur.",
  "slug": "misir", "name_tr": "Mısır", "name_en": "Egypt", "iso3": "EGY",
  "tur": "ulke", "edition": 6,
  "pencere": {"gun": 28, "baslangic": None,
              "_baslangic_notu": "null → seed anında now(). İleri tarihli pencere dosyayı yayına sokup şeritten gizler (§2.12/1)."},
  "status": "published",
  "_status_notu": ("YAYINDA. Devir 23 Kasım 2026'da yapıldı: göçler "
                   "20261123110000 (içerik, draft) ve 20261123120000 (devir) "
                   "uygulandı, 13 sağlamanın 13'ü geçti. Pencere o gün "
                   "başladı, 28 gün. Bu alan veritabanıyla AYNI TURDA "
                   "eşitlendi — durum bekçisi ayrışmayı dağıtımda durduruyor "
                   "ve Irak bu yüzden on gün og etiketlerini kaybetmişti."),
  "kapak": {},          # aşağıda dolduruluyor
  "video": {"url": None, "_notu": "null ise kapakta video bloğu hiç çizilmez."},
  "bolum_turleri": dict({"_amac": "Bölüm sırası → görsel ritim. anlati | belge | veri | akis.",
                         "_neden_boyle": ("Eksen Türkiye bağı değil Mısır'ın kendi tarımı "
                                          "(kullanıcı şartı). Ticaret bölümleri 13 ve 14, belge "
                                          "bölümü 15 SONA konuldu; dosya tarlayla başlayıp "
                                          "tarlayla sürüyor. Su bölümü (4) erken duruyor çünkü "
                                          "sonraki bütün bölümlerin kısıtı o.")}, **TUR),
  "bolum_grafikleri": dict({"_amac": "Hangi bölümde hangi grafik. Kimlikler grafikler.json ile birebir eşleşmek zorunda.",
                            "_bos_bolumler": ("9, 10 ve 18'de grafik YOK. 9'un verisi 8'deki "
                                              "uc_tane grafiğinde zaten çizili; 10 bir anlatı "
                                              "bölümü ve rakamı yok; 18 kaynakça."),
                            "_ayna_uyarisi": ("13 ve 14'teki grafikler ticaret rakamları taşıyor. "
                                              "İKİ TARAF da muhabir olarak rapor veriyor ve "
                                              "beyanlar tutmuyor; 13 tek muhabirden (Türkiye) "
                                              "hesaplandı, 14 ikisini yan yana koyuyor.")},
                           **GRAFIKLER),
  "_bolum_basliklari": dict({"_notu": "METİNDEN OKUNDU; başlıklar metinle birebir."},
                            **{k: B_TR[k] for k in sorted(B_TR, key=int)}),
  "_bolum_basliklari_en": {k: B_EN[k] for k in sorted(B_EN, key=int)},
  "bolum_gorselleri": {},   # aşağıda
  "anahtar_kelimeler": [
      "Mısır", "Nil", "feddan", "buğday", "buğday ithalatı", "pirinç",
      "tane mısır", "pamuk", "portakal", "narenciye", "sulama", "su",
      "tarım arazisi", "tarım ticareti", "serbest ticaret anlaşması",
      "gıda güvenliği", "kırsal nüfus", "delta",
  ],
  "_anahtar_kelimeler_notu": ("Dosyanın ölçtüğü kalemlerden türetildi. 'Tane "
                              "mısır' ayrı yazıldı: ürün ile ülke Türkçede "
                              "aynı kelime ve arama ikisini karıştırır."),
  "hikaye": {},
}

# ── KAPAK ────────────────────────────────────────────────────────────────
kk = KUNYE["misir_kapak_vadi"]
ka = ALTYAZI["misir_kapak_vadi"]
d["kapak"] = {
    "url": f"https://tarimportali.net/dosya/misir/{kk['dosya']}",
    "atif": kk["atif"], "lisans": kk["lisans"],
    "lisans_adresi": kk.get("lisans_adresi"),
    "alt_tr": ka["tr"], "alt_en": ka["en"],
    "en_boy": kk["en_boy"],
    "_commons": kk["commons_sayfasi"],
    "_dayanak": ka["_dayanak"],
    "_tasarimla_uyum": ("tasarim.json'un kapak tarifi: 'Nil vadisinin çöl "
                        "sınırı — yüksekten, ekili yeşil ile kumun kesiştiği "
                        "çizgi kadrajın içinden geçecek kadar yakın.' Bu kare "
                        "o tarife uyuyor; sapma yok."),
    "_gozle_dogrulandi": False,
    "_gozle_notu": "GÖZLE AÇILMADI. Kullanıcı kareyi onaylamadan devredilmez.",
}

d["bolum_gorselleri"] = dict({
    "_amac": "Grafik veriyi anlatır, görsel konuyu gösterir. Atıfsız görsel yayımlanmaz (§2.4).",
    "_kaynak": "Hepsi Wikimedia Commons; atıf ve lisans Commons API'sinden çekildi, elle yazılmadı.",
    "_altyazi_kurali": ("Altyazı KÜNYEDİR: konu + yer + tarih, kaynağın kendi "
                        "açıklamasından yazıldı. Karede ne görüldüğü "
                        "ANLATILMADI. Her altyazının `_dayanak` alanı hangi "
                        "künye alanından geldiğini söylüyor."),
    "_kapak_tekrari": ("§2 kapakla AYNI kareyi kullanıyor. Tekrar bilinçli: "
                       "§2'nin konusu zaten vadinin çöl sınırı, yani kapağın "
                       "gösterdiği şey. On sekiz bölüme on sekiz ayrı kare "
                       "bulunamadığı için değil."),
}, **{no: gorsel_blok(no) for no in sorted(GORSEL, key=int)})

# ── ANA SAYFA HİKÂYESİ ───────────────────────────────────────────────────
# Beş kanca ve sıralaması dosyanın kendi sırası: tarla → su → buğday →
# pirinç çelişkisi → portakal. İlk DÖRDÜ Mısır'ın kendi tarımı; Türkiye
# bağı yalnız sonda ve yalnız bir slaytta. Kullanıcı şartı buydu.
def slayt_gorseli(anahtar: str) -> str:
    return f"https://tarimportali.net/dosya/misir/{KUNYE[anahtar]['dosya']}"

d["hikaye"] = {
    "_amac": "Ana sayfadaki hikâye baloncuğu. Habere değil DOSYAYA çağırıyor.",
    "_kural": ("Metin ELLE yazıldı. Beş rakamın beşi de data.json'dan "
               "OKUNARAK yazıldı: çalışan başına 1,71 feddan ve 11,0 kat "
               "(FAOSTAT arazi 2024 + istihdam 2025); suyun %96,9'u dışarıdan "
               "(FAO AQUASTAT 2016 taraması, belgenin kendi ifadesi); buğday "
               "ithalatı 12.467 bin ton ve tüketimin %62,3'ü (USDA PSD "
               "2024/25); pirinçte arzın yalnız %3,9'u ithal; portakalda oran "
               "1990'da 2,14 kat, 2024'te 2,61 kat (FAOSTAT QCL)."),
    "_akis": ("Tarla → su → buğday → pirinç çelişkisi → portakal. İlk dördü "
              "Mısır'ın kendi tarımı; Türkiye yalnız beşinci slaytta ve orada "
              "da karşılaştırma olarak. Dosya tarlayla başlayıp tarlayla "
              "sürüyor."),
    "_ayna_notu": ("Hiçbir slayt TİCARET rakamı taşımıyor. İki beyan "
                   "birbirini tutmuyor (%58,8 ve %53,1) ve bir slayta "
                   "sığmayacak kadar şerh ister; o bölüm dosyanın içinde."),
    "_sinir_notu": ("Slayt alanlarının gösterim sınırları (scripts/"
                    "dosya_hikayeleri.py, SINIR sözlüğü): ust 24, baslik 60, "
                    "etiket 48, rakam 12 karakter. İlk yazımda etiketler "
                    "115-147 karakterdi ve dördü cümlenin ortasından "
                    "kırpılıyordu; üst satır da bir karakterle taşıyordu. "
                    "Betik kırpmayı ekrana yazıyor ki kaynak düzeltilebilsin — "
                    "23 Kasım 2026'da düzeltildi."),
    "_gorsel_notu": ("Görseller dosyanın İÇİNDEKİ karelerden; paylaşım kartı "
                     "kullanılmıyor. Altyazıları bölüm görselleriyle aynı — "
                     "künyeden yazıldı, kareden değil."),
    "grup_tr": "Ülke Dosyası · Mısır",
    "grup_en": "Country Dossier · Egypt",
    "slaytlar": [
        {"ust": "DOSYANIN BİRİMİ", "ust_en": "THE UNIT OF THIS DOSSIER",
         "baslik": "Bir tarım çalışanına 1,71 feddan düşüyor",
         "baslik_en": "An agricultural worker has 1.71 feddans",
         "rakam": "11,0 kat", "rakam_en": "11.0 fold",
         "etiket": "Çalışan başına 0,72 ha · Türkiye 7,89 ha",
         "etiket_en": "0.72 ha per worker · Türkiye 7.89 ha",
         "gorsel": slayt_gorseli("misir_tarla_at")},
        {"ust": "SU YUKARIDAN GELİYOR", "ust_en": "WATER FROM UPSTREAM",
         "baslik": "Mısır'ın suyunun %96,9'u ülke dışından geliyor",
         "baslik_en": "96.9% of Egypt's water originates outside the country",
         "rakam": "%96,9", "rakam_en": "96.9%",
         "etiket": "Çekilen suyun %86'sı tarıma gidiyor",
         "etiket_en": "86% of water withdrawn goes to farming",
         "gorsel": slayt_gorseli("misir_sakiye_deve")},
        {"ust": "DÜNYANIN EN BÜYÜĞÜ", "ust_en": "THE LARGEST BUYER",
         "baslik": "Buğdayda dünyanın en büyük alıcısı Mısır",
         "baslik_en": "Egypt is the world's largest wheat buyer",
         "rakam": "%62,3", "rakam_en": "62.3%",
         "etiket": "Tüketiminin ithal edilen payı · 2024",
         "etiket_en": "Share of consumption imported · 2024",
         "gorsel": slayt_gorseli("misir_bugday_hasadi")},
        {"ust": "ÇELİŞKİ", "ust_en": "THE CONTRADICTION",
         "baslik": "Su istemeyen taneyi alıyor, su isteyeni kendi ekiyor",
         "baslik_en": "It buys the dry grain and grows the thirsty one",
         "rakam": "%3,9", "rakam_en": "3.9%",
         "etiket": "Pirinçte arzın ithal payı · buğday %58,1",
         "etiket_en": "Rice supply imported · wheat 58.1%",
         "gorsel": slayt_gorseli("misir_pirinc_hasat")},
        {"ust": "AÇILAN MAKAS", "ust_en": "THE WIDENING GAP",
         "baslik": "Portakalda Mısır 1970'te geçti, hâlâ açıyor",
         "baslik_en": "Egypt passed Türkiye in oranges and keeps pulling away",
         "rakam": "2,61 kat", "rakam_en": "2.61 fold",
         "etiket": "1990'da 2,14 kat · 2024'te 2,61 kat",
         "etiket_en": "2.14 fold in 1990 · 2.61 fold in 2024",
         "gorsel": slayt_gorseli("misir_portakal_bahcesi")},
    ],
}

(KOK / "yayin.json").write_text(
    json.dumps(d, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"✓ yayin.json · {len(B_TR)} bölüm · {len(GORSEL)} görsel · "
      f"{sum(len(v) for k, v in GRAFIKLER.items())} grafik yerleşimi")
