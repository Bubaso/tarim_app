#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Galeriye ikinci parti kareleri EKLER — mevcut 79 kareye dokunmadan.

Kullanıcı kararı (24 Kasım 2026): "SALT dosyasından hiç kullanmadığın
görselleri de galeriye ekle. ayrıca SALT haricinde bulduğun diğer
görselleri de galeriye koy. şuanki son resimden (79) sonra hepsini sırala."

NEDEN AYRI BİR BETİK. galeri_indir.py `galeri_kunye.json`u BAŞTAN yazıyor;
SALT kareleri oraya salt_yerlestir.py ile, yedi tanesi de
tur9_gorsel_degisim.py ile sonradan girdi. İndiriciyi yeniden koşturmak o
yedi kareyi sessizce düşürürdü. Bu betik hiçbir şeyi silmiyor, yalnız
ekliyor.

PARTİ ALANI. Mevcut kareler `parti: 1`, yenileri `parti: 2` alıyor;
kur_galeri.py önce partiye göre sıralıyor. Böylece ilk 79 kare bugünkü
sırasında kalıyor ve yeniler ARKAYA diziliyor — kullanıcının istediği bu.

ÜÇ KAYNAK:
  A · SALT   — kullanıcının indirdiği 91 dosyadan kullanılmayan 40'ı.
  B · Commons — Türkiye'yle ilgili, şeker sanayisini gösteren 19 kare.
  C · Kurum   — turkseker.gov.tr haber arşivinden 35 kare.

COMMONS'TA NE ELENDİ. Turhal ilçe manzaraları, kale tepesi görünümleri ve
bir konum haritası: şekerle bağı yok. "Murat Şeker", "Busem Şeker",
"şeker beji mermer", "Pancar soup" gibi soyadı/renk yanılgıları. Alpullu
albümünün Commons kopyası (AHTURAL013006), çünkü aynı sayfa SALT'tan
geliyor ve 8. kural tekrarı düşürür. Genel Müdürlük'ün tabela ağırlıklı
karesi, çünkü kullanıcı 12. bölümde tam olarak öyle bir kareyi reddetti.

KURUM'DA NE ELENDİ. 173 adayın 138'i: kürsü, kurdele, protokol sırası ve
ödül takdimi. Kalan 35'i işin kendisini gösteriyor — kantar, laboratuvar,
pancar hattı, kazan, çuval, tarla.
"""
import html
import json
import pathlib
import re
import shutil
import subprocess
import time

from PIL import Image

RAW = pathlib.Path(__file__).parent
HEDEF = RAW / "gorseller"
SALT_KAYNAK = pathlib.Path.home() / "Downloads" / "SALT GÖRSELLER"
KURUM_KAYNAK = pathlib.Path(
    "/private/tmp/claude-502/-Users-BURHAN-Desktop/"
    "597dfc7b-cfff-4806-ba01-33aa08a98d6d/scratchpad/turkseker_site")
TAVAN = 1600
UA = "research-client/1.0"          # kullanıcıya/projeye ait bilgi taşımıyor
API = "https://commons.wikimedia.org/w/api.php"

SALT_LISANS = "CC BY-NC-ND 4.0"
SALT_LISANS_ADRES = "https://creativecommons.org/licenses/by-nc-nd/4.0/deed.tr"
SALT_KREDI = "Salt Araştırma"
KURUM_ATIF = "Türkiye Şeker Fabrikaları A.Ş."
KURUM_LISANS = "Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını"
HABER_URL = "https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID={}"

# ═══ A · SALT ═══════════════════════════════════════════════════════════
# Albüm sayfalarının İngilizcesi — SALT'ın iki dilli açıklamasının ikinci
# yarısı, salt_yerlestir.py'deki EN_ALB'in sürdürülmesi.
EN_ALB = {
    "002": "Steiner, Alpullu 1929",
    "003": "An administrator",
    "004": "An administrator",
    "007": "The Alpullu Sinanlı Bridge",
    "010": "General view of the Alpullu Sugar Factory",
    "012": "Interior of the factory",
    "013": "The Alpullu Spirit Factory",
    "015": "Staff and administrators of the factory",
    "017": "Staff and administrators of the factory",
    "018": "Staff and administrators of the factory",
    "019": "Staff and administrators of the factory",
    "023": "Interior of the factory and staff",
    "024": "Sections of the factory and staff",
    "025": "Interior of the factory and staff",
    "026": "Interior of the factory and staff",
    "028": "Interior of the factory",
    "029": "Interior of the factory and staff",
    "030": "Interior of the factory and staff",
    "032": "Interior of the factory and staff",
    "033": "Interior of the factory and staff",
    "034": "Interior of the factory and staff",
    "035": "Interior of the factory and staff",
    "038": "Interior of the factory and staff",
    "045": "Staff of the factory",
}

# Albüm sayfasının öbeği: açıklaması ne diyorsa.
ALBUM_OBEK = {
    "002": "isci", "003": "isci", "004": "isci", "007": "alpullu",
    "010": "alpullu", "012": "fabrika_ici", "013": "alpullu",
    "015": "isci", "017": "isci", "018": "isci", "019": "isci",
    "023": "fabrika_ici", "024": "fabrika_ici", "025": "fabrika_ici",
    "026": "fabrika_ici", "028": "fabrika_ici", "029": "fabrika_ici",
    "030": "fabrika_ici", "032": "fabrika_ici", "033": "fabrika_ici",
    "034": "fabrika_ici", "035": "fabrika_ici", "038": "fabrika_ici",
    "045": "isci",
}

# Albüm dışı SALT kareleri: (dosya, kimlik, öbek, tr, en)
#
# ARKA YÜZLER. Fotokart kayıtlarının ikinci dosyası kartın arka yüzü:
# el yazısı mektup, pul ve damga. Altyazı kartın NE OLDUĞUNU söylüyor;
# mektubun metni aktarılmıyor.
SALT_ELLE = [
    ("salt_etimesgut_fabrika_002.jpg", "galeri_salt_etim_fabrika_arka", "fabrikalar",
     "Etimesgut Şeker Fabrikası fotokartının arka yüzü.",
     "The reverse of a photocard of the Etimesgut Sugar Factory."),
    ("salt_usak_fabrika_1_002.jpg", "galeri_salt_usak_kart_arka", "fabrikalar",
     "Uşak Şeker Fabrikası fotokartının arka yüzü.",
     "The reverse of a photocard of the Uşak Sugar Factory."),
    ("salt_usak_fabrika_2_002.jpg", "galeri_salt_usak_pancar_arka", "fabrikalar",
     "Uşak Şeker Fabrikası fotokartının arka yüzü: İstanbul'a, Göztepe'ye "
     "gönderilmiş bir mektup.",
     "The reverse of a photocard of the Uşak Sugar Factory: a letter sent to "
     "Göztepe, İstanbul."),
    ("salt_usak_makine_dairesi_002.jpg", "galeri_salt_usak_makine_arka", "fabrika_ici",
     "Uşak Şeker Fabrikası'nın makine dairesini gösteren fotokartın arka "
     "yüzü: Trabzon'a gönderilmiş bir mektup.",
     "The reverse of the photocard showing the engine room of the Uşak Sugar "
     "Factory: a letter sent to Trabzon."),
    ("salt_usak_makine_dairesi_calisanlar_002.jpg",
     "galeri_salt_usak_makine_isci_arka", "isci",
     "Uşak Şeker Fabrikası'nın makine dairesini ve çalışanlarını gösteren "
     "fotokartın arka yüzü: Trabzon'a gönderilmiş bir mektup.",
     "The reverse of the photocard showing the engine room of the Uşak Sugar "
     "Factory and its workers: a letter sent to Trabzon."),
    ("salt_usak_sosyal_tesisler_002.jpg", "galeri_salt_usak_havuz_arka", "cevresi",
     "Uşak Şeker Fabrikası Sosyal Tesisleri fotokartının arka yüzü: "
     "Betül'e yazılmış bir mektup.",
     "The reverse of a photocard of the social facilities of the Uşak Sugar "
     "Factory: a letter written to Betül."),
    ("salt_usak_sosyal_tesisler_003.jpg", "galeri_salt_usak_havuz_2", "cevresi",
     "Uşak Şeker Fabrikası Sosyal Tesisleri.",
     "The social facilities of the Uşak Sugar Factory."),
    ("salt_usak_sosyal_tesisler_004.jpg", "galeri_salt_usak_havuz_2_arka", "cevresi",
     "Aynı fotokartın arka yüzü: ablasına yazılmış bir mektup.",
     "The reverse of the same photocard: a letter written to an elder sister."),
]

# ═══ B · COMMONS ════════════════════════════════════════════════════════
# (dosya başlığı, kimlik, öbek, tr, en)
# Altyazılar API'den gelen nesne_adi / açıklama / tarih alanlarına dayanıyor;
# dayanak satırı her karede yazılı.
COMMONS = [
    ("File:Alpullu (near Babaeski), Sokollu era bridge over Ergene (L48a-22, 1970s).jpg",
     "galeri_alpullu_kopru_22", "alpullu",
     "Alpullu Köprüsü, Babaeski yakını, 1970'ler. Machiel Kiel fotoğrafı.",
     "The Alpullu bridge near Babaeski, 1970s. Photograph by Machiel Kiel."),
    ("File:Alpullu (near Babaeski), Sokollu era bridge over Ergene (L48a-24, 1970s).jpg",
     "galeri_alpullu_kopru_24", "alpullu",
     "Alpullu Köprüsü, Babaeski yakını, 1970'ler. Machiel Kiel fotoğrafı.",
     "The Alpullu bridge near Babaeski, 1970s. Photograph by Machiel Kiel."),
    ("File:AlpulluTrainStation (4).jpg", "galeri_alpullu_peron_4", "alpullu",
     "Alpullu tren istasyonu, Babaeski, Kırklareli, 4 Ağustos 2018.",
     "Alpullu railway station, Babaeski, Kırklareli, 4 August 2018."),
    ("File:AlpulluTrainStation (6).jpg", "galeri_alpullu_peron_6", "alpullu",
     "Alpullu tren istasyonu, Babaeski, Kırklareli, 4 Ağustos 2018.",
     "Alpullu railway station, Babaeski, Kırklareli, 4 August 2018."),
    ("File:E 68 017.jpg", "galeri_alpullu_lokomotif", "alpullu",
     "Alpullu Garı'nda TCDD'nin E 68 017 numaralı elektrikli lokomotifi, "
     "7 Temmuz 2016.",
     "TCDD electric locomotive E 68 017 at Alpullu station, 7 July 2016."),
    ("File:Bogazliyan sugar factory (Turkey).jpg", "galeri_bogazliyan", "fabrikalar",
     "Boğazlıyan Şeker Fabrikası, Yozgat, Ocak 2007.",
     "The Boğazlıyan sugar factory, Yozgat, January 2007."),
    ("File:Erzurum Şeker Fabrikası Giriş.jpg", "galeri_erzurum_giris", "fabrikalar",
     "Erzurum Şeker Fabrikası'nın girişi, 25 Ağustos 2012.",
     "The entrance of the Erzurum Sugar Factory, 25 August 2012."),
    ("File:Eskisehirseker.jpg", "galeri_eskisehir_giris", "fabrikalar",
     "Kâzım Taşkent Eskişehir Şeker Fabrikası'nın girişi, 2007.",
     "The entrance of the Kâzım Taşkent Eskişehir Sugar Factory, 2007."),
    ("File:Uşak Şeker Fabrikası Hisse Senedi.JPG", "galeri_usak_hisse", "tarih",
     "Uşak Şeker Fabrikası'nın hisse senedi.",
     "A share certificate of the Uşak Sugar Factory."),
    ("File:Uşak Şeker Fabrikası Kurucuları.jpg", "galeri_usak_kurucular", "tarih",
     "Uşak Şeker Fabrikası'nın kurucuları.",
     "The founders of the Uşak Sugar Factory."),
    ("File:Uşak Şeker Fabrikası Kuruluş İç Bölüm.jpg", "galeri_usak_kurulus_ic", "tarih",
     "Uşak Şeker Fabrikası'nın kuruluş yıllarında iç bölümü.",
     "The interior of the Uşak Sugar Factory in its founding years."),
    ("File:Uşak Şeker Fabrikası Kuruluşdaki Resmi.jpg", "galeri_usak_kurulus_dis", "tarih",
     "Uşak Şeker Fabrikası'nın kuruluş yıllarındaki hâli.",
     "The Uşak Sugar Factory in its founding years."),
    ("File:Serdivan, Sakarya.jpg", "galeri_adapazari_sehir", "cevresi",
     "Serdivan'dan Adapazarı Şeker Fabrikası, Sakarya, 24 Aralık 2014. "
     "Fabrika şehrin büyümesiyle şehir içinde kalmış.",
     "The Adapazarı Sugar Factory seen from Serdivan, Sakarya, 24 December "
     "2014. The city grew around the factory."),
    ("File:Eskişehir Şeker Sokak area Old situation in 2007 1783.jpg",
     "galeri_seker_sokak_3", "cevresi",
     "Eskişehir'de Şeker Sokak çevresi, 18 Aralık 2007.",
     "The Şeker Sokak area in Eskişehir, 18 December 2007."),
    ("File:Eskişehir Şeker Sokak area Old situation in 2007 1784.jpg",
     "galeri_seker_sokak_4", "cevresi",
     "Eskişehir'de Şeker Sokak çevresi, 18 Aralık 2007.",
     "The Şeker Sokak area in Eskişehir, 18 December 2007."),
    ("File:Eskişehir Şeker Sokak area Old situation in 2007 1785.jpg",
     "galeri_seker_sokak_5", "cevresi",
     "Eskişehir'de Şeker Sokak çevresi, 18 Aralık 2007.",
     "The Şeker Sokak area in Eskişehir, 18 December 2007."),
    ("File:Etimesgut Seker Fabrikasi C Tipi Lojmanlari Yikimi 2026.jpg",
     "galeri_etimesgut_c_tipi", "cevresi",
     "Etimesgut Havalimanı'nın genişletme çalışmaları kapsamında yıkılan "
     "C tipi lojmanlar, 15 Şubat 2026.",
     "The C-type staff housing demolished during the expansion of Etimesgut "
     "Airport, 15 February 2026."),
    ("File:Etimesgut Seker Fabrikasi Lojmanlari Yikimi 2026.jpg",
     "galeri_etimesgut_lojman_yikim", "cevresi",
     "Ankara Şeker Fabrikası'nın Etimesgut'taki lojmanlarının yıkımı, "
     "13 Ocak 2026.",
     "The demolition of the Ankara Sugar Factory's staff housing at "
     "Etimesgut, 13 January 2026."),
    ("File:Pancar şekerinden üretilmiştir yazısı.jpg", "galeri_pancar_yazisi", "urun",
     "Bir ambalajın üzerindeki “pancar şekerinden üretilmiştir” ibaresi, "
     "23 Eylül 2021.",
     "The phrase “made from beet sugar” on a package, 23 September 2021."),
]

# ═══ C · KURUM ══════════════════════════════════════════════════════════
# (yerel dosya, kimlik, öbek, haber kimliği, tr, en)
HABER = {
    "1077": ("6 Ağustos 2024", "6 August 2024"),
    "71":   ("18 Şubat 2022", "18 February 2022"),
    "5127": ("31 Mart 2026", "31 March 2026"),
    "5132": ("5 Ağustos 2026", "5 August 2026"),
    "5133": ("4 Eylül 2026", "4 September 2026"),
    "5135": ("8 Eylül 2026", "8 September 2026"),
    "5137": ("18 Eylül 2026", "18 September 2026"),
    "5138": ("21 Eylül 2026", "21 September 2026"),
    "5139": ("21 Eylül 2026", "21 September 2026"),
    "5141": ("23 Eylül 2026", "23 September 2026"),
    "5143": ("30 Eylül 2026", "30 September 2026"),
    "5145": ("2 Ekim 2026", "2 October 2026"),
    "5147": ("5 Ekim 2026", "5 October 2026"),
    "5148": ("5 Ekim 2026", "5 October 2026"),
    "5149": ("22 Ekim 2026", "22 October 2026"),
    "5153": ("11 Kasım 2026", "11 November 2026"),
    "5157": ("20 Kasım 2026", "20 November 2026"),
}

KURUM = [
    ("1077__1077_Haberler2024_08_06_11_34_08_171.jpeg", "galeri_kurum_tohum_avuc",
     "tarla", "1077",
     "İlk yerli şeker pancarı tohumlarının hasadı",
     "The harvest of the first domestically bred sugar beet seed"),
    ("1077__1077_Haberler2024_08_06_11_34_11_647.jpeg", "galeri_kurum_tohum_bitki",
     "tarla", "1077",
     "İlk yerli şeker pancarı tohumlarının hasadı",
     "The harvest of the first domestically bred sugar beet seed"),
    ("71__71_Haberler2022_02_18_14_00_47_255.png", "galeri_kurum_tohum_ciftci",
     "tarla", "71",
     "Sezonun ilk pancar tohumunun ekimi",
     "The sowing of the season's first beet seed"),
    ("5132__5132_Haberler2026_08_05_10_47_48_913.jpeg", "galeri_kurum_haymana_1",
     "tarla", "5132",
     "TÜRKŞEKER'in Haymana'da çiftçilerle buluşması",
     "TÜRKŞEKER meeting farmers at Haymana"),
    ("5132__5132_Haberler2026_08_05_10_47_49_289.jpeg", "galeri_kurum_haymana_2",
     "tarla", "5132",
     "TÜRKŞEKER'in Haymana'da çiftçilerle buluşması",
     "TÜRKŞEKER meeting farmers at Haymana"),
    ("5127__5127_Haberler2026_03_31_10_33_06_158.jpeg", "galeri_kurum_rolyef_2",
     "tarih", "5127",
     "1934'te Turhal Şeker Fabrikası'nın açılışı için yapılan ahşap rölyefin "
     "kuruma teslimi",
     "The wooden relief made for the 1934 opening of the Turhal Sugar Factory "
     "being handed back to the company"),
    ("5133__5133_Haberler2026_09_04_15_49_10_004.jpeg", "galeri_kurum_malatya_bosaltma",
     "yukleme", "5133",
     "Malatya Şeker Fabrikası'nda 71. kampanya döneminin açılışı",
     "The opening of the 71st campaign at the Malatya Sugar Factory"),
    ("5135__5135_Haberler2026_09_08_16_24_57_359.jpeg", "galeri_kurum_cuval_doldurma",
     "urun", "5135",
     "Malatya Şeker Fabrikası'nda yılın ilk şekerinin üretimi",
     "The season's first sugar being produced at the Malatya Sugar Factory"),
    ("5135__5135_Haberler2026_09_08_16_27_22_334.jpg", "galeri_kurum_malatya_salon",
     "fabrika_ici", "5135",
     "Malatya Şeker Fabrikası'nda inceleme",
     "An inspection at the Malatya Sugar Factory"),
    ("5135__5135_Haberler2026_09_08_16_27_50_316.jpg", "galeri_kurum_kozet_bandi",
     "fabrika_ici", "5135",
     "Malatya Şeker Fabrikası'nda pancar hattı",
     "The beet line at the Malatya Sugar Factory"),
    ("5135__5135_Haberler2026_09_08_16_27_55_850.jpg", "galeri_kurum_malatya_koridor",
     "fabrika_ici", "5135",
     "Malatya Şeker Fabrikası'nda inceleme",
     "An inspection at the Malatya Sugar Factory"),
    ("5137__5137_Haberler2026_09_18_15_42_40_200.jpeg", "galeri_kurum_ilgin_hava",
     "fabrikalar", "5137",
     "Ilgın Şeker Fabrikası",
     "The Ilgın Sugar Factory"),
    ("5137__5137_Haberler2026_09_18_16_33_00_720.jpeg", "galeri_kurum_laboratuvar_1",
     "isci", "5137",
     "Ereğli Şeker Fabrikası'nın laboratuvarı",
     "The laboratory of the Ereğli Sugar Factory"),
    ("5137__5137_Haberler2026_09_18_16_33_20_758.jpeg", "galeri_kurum_kantar_1",
     "yukleme", "5137",
     "Ereğli Şeker Fabrikası'nın kantarı",
     "The weighbridge of the Ereğli Sugar Factory"),
    ("5138__5138_Haberler2026_09_21_10_45_25_723.jpeg", "galeri_kurum_eskisehir_kapi",
     "fabrikalar", "5138",
     "Kâzım Taşkent Eskişehir Şeker Fabrikası'nda 94. pancar alım "
     "kampanyasının açılışı",
     "The opening of the 94th beet procurement campaign at the Kâzım Taşkent "
     "Eskişehir Sugar Factory"),
    ("5138__5138_Haberler2026_09_21_10_46_39_690.jpeg", "galeri_kurum_laboratuvar_2",
     "isci", "5138",
     "Kâzım Taşkent Eskişehir Şeker Fabrikası'nın laboratuvarı",
     "The laboratory of the Kâzım Taşkent Eskişehir Sugar Factory"),
    ("5138__5138_Haberler2026_09_21_10_46_47_242.jpeg", "galeri_kurum_pancar_bandi",
     "isci", "5138",
     "Kâzım Taşkent Eskişehir Şeker Fabrikası'nda pancar numune hattı",
     "The beet sampling line at the Kâzım Taşkent Eskişehir Sugar Factory"),
    ("5139__5139_Haberler2026_09_21_16_56_59_231.jpeg", "galeri_kurum_numune_1",
     "isci", "5139",
     "Ankara Şeker Fabrikası'nda pancar numune hattı",
     "The beet sampling line at the Ankara Sugar Factory"),
    ("5141__5141_Haberler2026_09_23_15_16_19_333.jpg", "galeri_kurum_numune_2",
     "isci", "5141",
     "Uşak, Elazığ ve Ağrı fabrikalarında kantarların açılışı",
     "The opening of the weighbridges at the Uşak, Elazığ and Ağrı factories"),
    ("5143__5143_Haberler2026_09_30_10_20_31_274.jpeg", "galeri_kurum_pancar_sahasi",
     "yukleme", "5143",
     "Yozgat Şeker Fabrikası'nda 29. pancar alım kampanyasının açılışı",
     "The opening of the 29th beet procurement campaign at the Yozgat Sugar "
     "Factory"),
    ("5145__5145_Haberler2026_10_02_15_53_04_556.jpeg", "galeri_kurum_kastamonu_hava",
     "fabrikalar", "5145",
     "Kastamonu Şeker Fabrikası",
     "The Kastamonu Sugar Factory"),
    ("5145__5145_Haberler2026_10_02_15_53_19_803.JPG", "galeri_kurum_kastamonu_saha",
     "fabrikalar", "5145",
     "Kastamonu Şeker Fabrikası'nda 64. pancar alım kampanyasının açılışı",
     "The opening of the 64th beet procurement campaign at the Kastamonu "
     "Sugar Factory"),
    ("5145__5145_Haberler2026_10_02_15_53_42_808.JPG", "galeri_kurum_kamyon",
     "yukleme", "5145",
     "Kastamonu Şeker Fabrikası'na pancar getiren kamyon",
     "A truck bringing beet to the Kastamonu Sugar Factory"),
    ("5145__5145_Haberler2026_10_02_15_53_47_017.JPG", "galeri_kurum_isciler",
     "isci", "5145",
     "Kastamonu Şeker Fabrikası'nın çalışanları",
     "The workers of the Kastamonu Sugar Factory"),
    ("5147__5147_Haberler2026_10_05_11_09_11_401.jpeg", "galeri_kurum_susurluk_hava",
     "fabrikalar", "5147",
     "Susurluk Şeker Fabrikası'nda 72. pancar alım kampanyasının açılışı",
     "The opening of the 72nd beet procurement campaign at the Susurluk Sugar "
     "Factory"),
    ("5148__5148_Haberler2026_10_05_14_58_04_611.jpeg", "galeri_kurum_sam_fuari",
     "urun", "5148",
     "TÜRKŞEKER'in Şam'daki 360 Food Syria & Agritech Expo'daki standı",
     "TÜRKŞEKER's stand at the 360 Food Syria & Agritech Expo in Damascus"),
    ("5149__5149_Haberler2026_10_22_13_51_21_472.jpeg", "galeri_kurum_tbmm",
     "tarih", "5149",
     "TÜRKŞEKER'in 2023-2024 dönemi faaliyetlerinin TBMM KİT Üst "
     "Komisyonu'nda görüşülmesi",
     "TÜRKŞEKER's 2023-2024 activities being discussed at the Turkish Grand "
     "National Assembly's SEE Commission"),
    ("5153__5153_Haberler2026_11_11_16_10_57_428.jpeg", "galeri_kurum_fidan_1",
     "cevresi", "5153",
     "TÜRKŞEKER Orman Anaokulu'nun fidan dikim etkinliği",
     "The sapling planting event of the TÜRKŞEKER Forest Nursery School"),
    ("5153__5153_Haberler2026_11_11_16_11_04_288.jpeg", "galeri_kurum_fidan_2",
     "cevresi", "5153",
     "TÜRKŞEKER Orman Anaokulu'nun fidan dikim etkinliği",
     "The sapling planting event of the TÜRKŞEKER Forest Nursery School"),
    ("5153__5153_Haberler2026_11_11_16_11_07_966.jpeg", "galeri_kurum_fidan_3",
     "cevresi", "5153",
     "TÜRKŞEKER Orman Anaokulu'nun fidan dikim etkinliği",
     "The sapling planting event of the TÜRKŞEKER Forest Nursery School"),
    ("5157__5157_Haberler2026_11_20_11_49_57_964.jpeg", "galeri_kurum_ilgin_depo",
     "urun", "5157",
     "Ilgın Şeker Fabrikası'ndaki yatırımların yerinde incelenmesi",
     "An on-site inspection of the investments at the Ilgın Sugar Factory"),
    ("5157__5157_Haberler2026_11_20_11_50_07_789.jpeg", "galeri_kurum_kazan_atesleme",
     "fabrika_ici", "5157",
     "Ilgın Şeker Fabrikası'nda kazanın ateşlenmesi",
     "The firing of the boiler at the Ilgın Sugar Factory"),
    ("5157__5157_Haberler2026_11_20_11_50_12_307.jpeg", "galeri_kurum_ilgin_makine",
     "fabrika_ici", "5157",
     "Ilgın Şeker Fabrikası'ndaki yatırımların yerinde incelenmesi",
     "An on-site inspection of the investments at the Ilgın Sugar Factory"),
    ("5157__5157_Haberler2026_11_20_11_50_27_789.jpeg", "galeri_kurum_cuval_depo",
     "urun", "5157",
     "Ilgın Şeker Fabrikası'nın şeker ambarı",
     "The sugar warehouse of the Ilgın Sugar Factory"),
    ("5157__5157_Haberler2026_11_20_11_50_32_223.jpeg", "galeri_kurum_ilgin_gezi",
     "fabrika_ici", "5157",
     "Ilgın Şeker Fabrikası'ndaki yatırımların yerinde incelenmesi",
     "An on-site inspection of the investments at the Ilgın Sugar Factory"),
]


# ═══ yardımcılar ════════════════════════════════════════════════════════
def duz(v):
    """HTML varlığı ÖNCE çözülüyor, etiket SONRA siliniyor (11. kural)."""
    if not v:
        return None
    s = html.unescape(v)
    s = re.sub(r"<[^>]+>", " ", s)
    return re.sub(r"\s+", " ", s).strip() or None


def tam_mi(yol):
    """Kesik dosya open() ile açılıyor, load() ile patlıyor — fark bu."""
    try:
        with Image.open(yol) as im:
            im.load()
        return True
    except Exception:
        return False


def kucult(yol):
    with Image.open(yol) as im:
        im.load()
        g, y = im.size
        if max(g, y) > TAVAN:
            im = im.convert("RGB")
            im.thumbnail((TAVAN, TAVAN))
            im.save(yol, "JPEG", quality=88, optimize=True)


def api(**p):
    p.setdefault("format", "json")
    p.setdefault("formatversion", "2")
    import urllib.parse
    import urllib.request
    r = urllib.request.Request(API + "?" + urllib.parse.urlencode(p),
                               headers={"User-Agent": UA})
    for deneme in range(4):
        try:
            with urllib.request.urlopen(r, timeout=45) as y:
                return json.loads(y.read().decode("utf-8"))
        except Exception as e:
            if deneme == 3:
                raise
            time.sleep(8 if getattr(e, "code", None) == 429 else 3)
    return {}


def salt_kunye_satiri(k):
    p = [k["baslik"]]
    if k.get("ureten"):
        p.append(k["ureten"])
    if k.get("tarih"):
        p.append(k["tarih"])
    p += [k["kod"], SALT_KREDI, SALT_LISANS]
    return " · ".join(p)


def main():
    SK = json.loads((RAW / "salt_kayitlari.json").read_text(encoding="utf-8"))
    KAYIT, SAYFA = SK["kayitlar"], SK["sayfa_aciklamalari"]

    sec_yol = RAW / "galeri_secim.json"
    ku_yol = HEDEF / "galeri_kunye.json"
    alt_yol = RAW / "galeri_altyazilar.json"
    SEC = json.loads(sec_yol.read_text(encoding="utf-8"))
    KUDOSYA = json.loads(ku_yol.read_text(encoding="utf-8"))
    KU = KUDOSYA["kareler"]
    ALT = json.loads(alt_yol.read_text(encoding="utf-8"))

    # Mevcut kareler birinci parti. TEK YÖNLÜ: zaten damgalıysa dokunulmuyor.
    onceki = [k for k in SEC["kareler"] if k.get("parti", 1) == 1]
    for k in SEC["kareler"]:
        k.setdefault("parti", 1)
    print("  mevcut: %d kare (parti 1)" % len(onceki))

    var = {k["kimlik"] for k in SEC["kareler"]}
    kullanilan_dosya = {k["dosya"] for k in SEC["kareler"]}
    BOLUM = json.loads((HEDEF / "kunye.json").read_text(encoding="utf-8"))["gorseller"]
    bolum_dosya = {g["ad"] for g in BOLUM.values()}

    hata, eklenen = [], []

    def ekle(kimlik, kaynak_turu, obek, yerel_ad, kunye, tr, en, dayanak):
        if kimlik in var:
            return
        KU[kimlik] = {**kunye, "kaynak_turu": kaynak_turu, "obek": obek}
        ALT[kimlik] = {"tr": tr, "en": en, "_dayanak": dayanak}
        SEC["kareler"].append({"kimlik": kimlik, "kaynak": kaynak_turu,
                               "dosya": yerel_ad, "obek": obek, "parti": 2})
        var.add(kimlik)
        eklenen.append((kaynak_turu, kimlik))

    # ── A · SALT ────────────────────────────────────────────────────────
    if not SALT_KAYNAK.is_dir():
        raise SystemExit("✗ SALT klasörü yok: %s" % SALT_KAYNAK)
    salt_bos = sorted(p.name for p in SALT_KAYNAK.iterdir()
                      if p.suffix.lower() in (".jpg", ".jpeg", ".png")
                      and p.name not in kullanilan_dosya
                      and p.name not in bolum_dosya)
    elle = {d: (kim, ob, tr, en) for d, kim, ob, tr, en in SALT_ELLE}
    for dosya in salt_bos:
        g = dosya[len("salt_"):].rsplit(".", 1)[0]
        kok, _, no = g.rpartition("_")
        k = KAYIT.get(kok)
        if not k:
            hata.append("SALT: kayıt tanımsız — %s" % kok)
            continue
        if dosya in elle:
            kimlik, obek, tr, en = elle[dosya]
            dayanak_son = "Kaydın başlığı; dosya kaydın ikinci belgesi."
        elif kok == "alpullu_albumu":
            a = SAYFA["alpullu_albumu"].get(no)
            if not a or no not in EN_ALB:
                hata.append("SALT: albüm sayfası %s açıklamasız" % no)
                continue
            kimlik = "galeri_salt_alb_%s" % no
            obek = ALBUM_OBEK[no]
            tr = ("Alpullu Şeker ve İspirto Fabrikaları albümünden bir sayfa: "
                  "%s. %s." % (a, k["tarih"]))
            en = ("A page from the album of the Alpullu Sugar and Spirit "
                  "Factories: %s. %s." % (EN_ALB[no], k["tarih"]))
            dayanak_son = "Albüm sayfasının kendi açıklaması (dataItemFiles)."
        elif kok == "etimesgut_kompleksi":
            kimlik = "galeri_salt_etim_k%s" % no
            obek = "cevresi"
            tr = "%s %s fotoğrafı. %s." % (k["baslik"], k["ureten"], k["yer"])
            en = ("Photographs of the Etimesgut Complex of Türkiye Şeker "
                  "Fabrikası. Photograph by %s. %s." % (k["ureten"], k["yer"]))
            dayanak_son = "Kaydın başlığı ve üreteni."
        else:
            hata.append("SALT: altyazısı tanımsız — %s" % dosya)
            continue

        hedef = HEDEF / ("%s.jpg" % kimlik)
        if not hedef.exists():
            shutil.copy2(SALT_KAYNAK / dosya, hedef)
        kucult(hedef)
        if not tam_mi(hedef):
            hata.append("SALT: %s kesik" % hedef.name)
            continue
        ekle(kimlik, "salt", obek, dosya, {
            "adres": None, "asil": None, "sayfa": k["handle"],
            "mime": "image/jpeg", "nesne_adi": k["baslik"], "aciklama": tr,
            "tarih": k.get("tarih"), "atif": salt_kunye_satiri(k),
            "kredi": SALT_KREDI, "lisans": SALT_LISANS,
            "lisans_adresi": SALT_LISANS_ADRES, "ad": dosya,
            "dosya": hedef.name, "bayt": hedef.stat().st_size,
        }, tr, en, "SALT Araştırma kaydı %s (%s). %s" % (k["kod"], k["handle"],
                                                         dayanak_son))

    # ── B · COMMONS ─────────────────────────────────────────────────────
    basliklar = [c[0] for c in COMMONS]
    ham = {}
    for i in range(0, len(basliklar), 20):
        d = api(action="query", prop="imageinfo",
                titles="|".join(basliklar[i:i + 20]),
                iiprop="url|size|mime|extmetadata", iiurlwidth="1920",
                iiextmetadatafilter="ImageDescription|ObjectName|"
                                    "DateTimeOriginal|Artist|LicenseShortName|"
                                    "Credit|LicenseUrl")
        for p in d.get("query", {}).get("pages", []):
            if p.get("missing"):
                continue
            ii = (p.get("imageinfo") or [{}])[0]
            em = ii.get("extmetadata", {}) or {}
            ham[p["title"]] = {
                "adres": ii.get("thumburl") or ii.get("url"),
                "asil": ii.get("url"), "sayfa": ii.get("descriptionurl"),
                "mime": ii.get("mime"),
                "nesne_adi": duz(em.get("ObjectName", {}).get("value")),
                "aciklama": duz(em.get("ImageDescription", {}).get("value")),
                "tarih": duz(em.get("DateTimeOriginal", {}).get("value")),
                "atif": duz(em.get("Artist", {}).get("value")),
                "kredi": duz(em.get("Credit", {}).get("value")),
                "lisans": duz(em.get("LicenseShortName", {}).get("value")),
                "lisans_adresi": duz(em.get("LicenseUrl", {}).get("value")),
            }
        time.sleep(1)

    for baslik, kimlik, obek, tr, en in COMMONS:
        h = ham.get(baslik)
        if not h or not h["adres"]:
            hata.append("Commons: %s kaynakta yok" % kimlik)
            continue
        if not h["atif"]:
            hata.append("Commons: %s ATIFSIZ — §2.4" % kimlik)
            continue
        uzanti = ".png" if (h["mime"] or "").endswith("png") else ".jpg"
        hedef = HEDEF / ("%s%s" % (kimlik, uzanti))
        if not (hedef.exists() and hedef.stat().st_size >= 4096 and tam_mi(hedef)):
            r = subprocess.run(["curl", "-sS", "--max-time", "120", "-L",
                                "-A", UA, "-o", str(hedef), h["adres"]],
                               capture_output=True, text=True)
            if r.returncode != 0:
                hata.append("Commons: %s curl %d" % (kimlik, r.returncode))
                continue
            time.sleep(0.4)
        bas = hedef.read_bytes()[:4] if hedef.exists() else b""
        if hedef.stat().st_size < 4096 or not (bas.startswith(b"\xff\xd8")
                                               or bas.startswith(b"\x89PNG")):
            hata.append("Commons: %s resim değil (%d bayt)"
                        % (kimlik, hedef.stat().st_size))
            continue
        kucult(hedef)
        if not tam_mi(hedef):
            hata.append("Commons: %s KESİK" % kimlik)
            continue
        ekle(kimlik, "commons", obek, baslik, {
            **h, "ad": baslik.split(":", 1)[-1], "dosya": hedef.name,
            "bayt": hedef.stat().st_size,
        }, tr, en,
            "Commons künyesi: nesne_adi '%s'%s%s."
            % (h["nesne_adi"] or "—",
               " + açıklama '%s'" % h["aciklama"][:70] if h["aciklama"] else "",
               " + tarih %s" % h["tarih"] if h["tarih"] else ""))

    # ── C · KURUM ───────────────────────────────────────────────────────
    havuz = {}
    for d in ("foto", "foto9", "foto_sec"):
        kl = KURUM_KAYNAK / d
        if kl.is_dir():
            for p in sorted(kl.iterdir()):
                havuz.setdefault(p.name, p)
    for dosya, kimlik, obek, hid, tr_konu, en_konu in KURUM:
        src = havuz.get(dosya)
        if src is None:
            hata.append("Kurum: dosya yok — %s" % dosya)
            continue
        tr_t, en_t = HABER[hid]
        tr = "%s, %s." % (tr_konu, tr_t)
        en = "%s, %s." % (en_konu, en_t)
        uzanti = ".png" if dosya.lower().endswith(".png") else ".jpg"
        hedef = HEDEF / ("%s%s" % (kimlik, uzanti))
        if not hedef.exists():
            shutil.copy2(src, hedef)
        # PNG'yi JPEG'e çevir: hat iki biçimi de taşıyor ama galeri
        # karelerinin tamamı JPEG olsun diye tek biçim tutuluyor.
        if uzanti == ".png":
            with Image.open(hedef) as im:
                im.load()
                im.convert("RGB").save(hedef.with_suffix(".jpg"), "JPEG",
                                       quality=92, optimize=True)
            hedef.unlink()
            hedef = hedef.with_suffix(".jpg")
        kucult(hedef)
        if not tam_mi(hedef):
            hata.append("Kurum: %s kesik" % hedef.name)
            continue
        ekle(kimlik, "kurum", obek, dosya, {
            "adres": None, "asil": None, "sayfa": HABER_URL.format(hid),
            "mime": "image/jpeg", "nesne_adi": tr_konu, "aciklama": tr,
            "tarih": None, "atif": KURUM_ATIF,
            "kredi": "turkseker.gov.tr haber arşivi",
            "lisans": KURUM_LISANS, "lisans_adresi": None,
            "ad": dosya, "dosya": hedef.name, "bayt": hedef.stat().st_size,
        }, tr, en,
            "turkseker.gov.tr haberi %s (%s); haberin başlığı ve tarihi."
            % (hid, HABER_URL.format(hid)))

    if hata:
        raise SystemExit("✗ " + "\n  ".join(hata))

    SEC["_parti2"] = (
        "24 Kasım 2026, kullanıcı: 'SALT dosyasından hiç kullanmadığın "
        "görselleri de galeriye ekle… şuanki son resimden (79) sonra hepsini "
        "sırala.' İkinci parti kareler `parti: 2` taşıyor; kur_galeri.py önce "
        "partiye göre sıralıyor, ilk 79 kare bugünkü sırasında kalıyor.")
    sec_yol.write_text(json.dumps(SEC, ensure_ascii=False, indent=2),
                       encoding="utf-8")
    ku_yol.write_text(json.dumps(KUDOSYA, ensure_ascii=False, indent=2),
                      encoding="utf-8")
    alt_yol.write_text(json.dumps(ALT, ensure_ascii=False, indent=2),
                       encoding="utf-8")

    from collections import Counter
    say = Counter(t for t, _ in eklenen)
    print("  ✓ %d kare eklendi · %s"
          % (len(eklenen), " · ".join("%s %d" % (a, b) for a, b in sorted(say.items()))))
    print("  galeri toplamı: %d kare" % len(SEC["kareler"]))


main()
