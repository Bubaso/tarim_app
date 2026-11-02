# Irak — Ülke Dosyası Sayı 05 · kaynak araştırması

Rotasyonda **Pazar** rolü (§2.11, sıra 5). Model → Pazar → Rakip döngüsünde
Avustralya'dan (Model) sonra gelen halka.

---

## Tur 1 — ERİŞİM HARİTASI

Önce bu okunur. Avustralya'da ulusal tarım kurumları kapalıydı ve dosya eyalet
siciline dayanmıştı; Irak'ta durum daha sert: **ülkenin kendi kurumlarının
hiçbiri bu ağdan iş görmüyor.**

### Açık

| kaynak | sınıf | ne veriyor |
|---|---|---|
| UN Comtrade preview API | BAĞIMSIZ | Türkiye–Irak ticareti, fasıl ayrıntısında |
| FAOSTAT toplu indirme (`bulks-faostat.fao.org`) | BAĞIMSIZ | Irak üretimi; 17 MB zip |
| Dünya Bankası API | BAĞIMSIZ | makro göstergeler, 1960'tan bugüne |
| Dünya Bankası belge arama API'si | BAĞIMSIZ | Irak su/tarım raporları |
| `resmigazete.gov.tr/arsiv/<sayı>.pdf` | BİRİNCİL | 1947 onay kanunu nüshası |
| `www5.tbmm.gov.tr` tutanak PDF'leri | BİRİNCİL | antlaşma ve protokol metni |
| `fao.org/4/<belge>.pdf` | BAĞIMSIZ | FAO belgeleri (gerçek PDF) |

### Kapalı — tekrar denenmesin

| kaynak | sonuç |
|---|---|
| Irak İstatistik Kurumu `cosit.gov.iq` | **404** |
| Irak Tarım Bakanlığı `mo-ag.gov.iq` | **000** — bağlantı kurulmuyor |
| Irak Su Kaynakları Bakanlığı `mowr.gov.iq` | 200 ama gövde **139 karakter** — kabuk |
| FAO AQUASTAT ülke profili (HTML) | 200 ama gövde **1.659 karakter** — JavaScript kabuğu |
| FAOSTAT REST API (`fenixservices`) | **521** — ama TOPLU İNDİRME çalışıyor |
| IPC gıda güvenliği | **403** |
| UN-ESCWA sınıraşan sular envanteri | **403** |
| ReliefWeb API | **410** — uç nokta kaldırılmış |
| FAO `countryprofiles` | **404** |
| `fao.org/3/<belge>.pdf` | 200 + `text/html` — **yumuşak 404** (§2.12.1) |

*Yöntem notu:* DSİ dosyasında bir konuyu "kaynaksız" ilan etmeden önce konunun
KENDİ TERİMİNİ aramamıştım ve yanılmıştım. Burada ters sıra uygulandı: önce
arandı, sonra adres denendi. 1946 antlaşmasının kanun numarasını tahmin
etmiştim ve tahmin tutmadı; arama doğru tarihi verdi (kabul 5 Eylül 1947,
RG 12 Eylül 1947) ve oradan TBMM tutanağına ulaşıldı.

---

## Tur 1 — ÖLÇÜLEN İLK RAKAMLAR

Hepsi bu turda canlı çekimle doğrulandı; hiçbiri bellekten yazılmadı.

### Ticaret — dosyanın omurgası

**Türkiye → Irak tarım ihracatı (HS 01-24), 2024: 4,64 milyar dolar**
(24 faslın tamamı dolu). Aynı yıl toplam ihracat 13,00 milyar dolar; yani
Irak'a satılan her üç doların biri tarım.

Fasıl liderleri (milyon dolar, 2024):

| fasıl | | değer |
|---|---|---|
| HS 19 | hamur işleri, bisküvi, makarna | 538,9 |
| HS 08 | meyve ve sert kabuklu yemiş | 498,3 |
| HS 11 | değirmencilik ürünleri — **un** | 496,6 |
| HS 02 | et | 444,4 |
| HS 07 | sebze | 432,8 |
| HS 10 | hububat | 408,3 |
| HS 15 | katı ve sıvı yağlar | 339,6 |
| HS 23 | yem artıkları | 298,1 |

**TERS YÖN NEREDEYSE BOŞ: Irak → Türkiye tarım ithalatı 30,2 milyon dolar.**
Oran **154 kat**. Dizide ölçülen en uç dengesizlik — Avustralya'da denge
3 kat Türkiye lehineydi, burada 154.

### Irak'ın kendi tarımı (Dünya Bankası)

| | yıl | değer |
|---|---|---|
| Nüfus | 2025 | 47.020.774 |
| Tarımın GSYH payı | 2025 | %3,41 |
| Tarımda istihdam | 2025 | %8,17 |
| Tarım arazisi payı | 2024 | %21,65 |
| Tahıl verimi | 2024 | 2.651 kg/ha |
| Gıda ithalatının mal ithalatındaki payı | 2024 | %14,24 |
| **Sulanan arazi payı** | — | **VERİ YOK** |

Son satır dosyanın en anlamlı boşluğu olabilir: suyun belirleyici olduğu bir
ülkede sulanan alan oranı yayımlanmıyor.

---

## AÇIK — tur 2'de karara bağlanacak

1. **AYNA İSTATİSTİK ZORUNLU.** Irak Comtrade'e muhabir olarak neredeyse hiç
   rapor vermiyor: 2018, 2020 ve 2022 için **sıfır satır**, 2024 için bir
   satır. Bütün ticaret rakamları TÜRKİYE'NİN beyanından okunacak ve metinde
   bu açıkça yazılacak — Rusya dosyasındaki "ticaret istatistiği 2022'den beri
   yayımlanmıyor" notunun karşılığı.

2. **ÇİFT SAYIM SÜZGECİ AÇIK** (§2.2.1): `customsCode=C00`, `motCode=0`,
   `partner2Code=0`. Çekimde hem sorguya hem gelen satıra uygulanıyor.
   Avustralya'da tonaj alanları boş geliyordu; Irak muhabirinde ayrıca
   sınanacak.

3. **TEK KAYNAK ÇAPRAZ KONTROLÜ ŞART** (§2.2.1 sonu). Comtrade tek yaka;
   manşet rakam TÜİK ya da FAOSTAT ticaret serisiyle oranlanacak. Beklenen
   oran 1'e yakın; 2'ye yakın çıkarsa çift sayım sayılır.

4. **SU TARAFI — birincil belge elde, metin henüz okunmadı.** 29 Mart 1946
   tarihli Dostluk ve İyi Komşuluk Antlaşması'nın 1 numaralı ek protokolü
   "Dicle, Fırat ve Kolları Sularının Düzene Konması" başlığını taşıyor.
   TBMM S. Sayısı 241 (2,6 MB PDF) indirildi. Protokolün NE SÖYLEDİĞİ
   okunmadan metne tek cümle girmeyecek.

5. **DSİ DOSYASIYLA BAĞ KENDİLİĞİNDEN KURULUYOR.** Kurum Dosyası Sayı 05 dün
   yayımlandı ve GAP'ın Fırat üzerindeki beş barajını adıyla sayıyor. Irak
   o nehrin mansabında. Bağ gerçek ve belgeli — ama **ton dikkat ister**:
   dosya tanıtım değil ülke dosyası, yine de taraf tutan bir anlatı
   kurulmayacak. Veri ne diyorsa o.

6. **§2.8'in beş kategorisi henüz boş.** Özellikle "Türkiye bağı" ve "terk
   edilen ürün" Irak için araştırılacak.

---

# Tur 2 — EKSEN KİLİTLENDİ

## Eksen (kullanıcı kararı, 2 Kasım 2026)

**Tek yönlü pazar.** Türkiye Irak'a 4,64 milyar dolarlık tarım ürünü satıyor,
karşılığında 30,2 milyon dolar alıyor — 154 kat. Satılan şey ham tahıl değil,
ekmeğin bütün zinciri: un, makarna, bisküvi.

## KULLANICI ŞARTI — dosyanın yarısı Irak'ın kendisi

> "bu eksen tamam ama bu dosya aynı zamanda Irak'ın tarım yönünden ele
> alınması dosyası. yalnızca Türkiye ile ilişkileri üzerinden bir dosya
> oluşmasın istiyorum. diğer ülkelerdeki konularda da bölüm veya bölümler
> olmalı."

Yani eksen ticaret, **konu Irak tarımı**. Avustralya dosyası da öyleydi:
ticaret bir bölümdü, ülkenin kendi tarımı (ölçek, destek, yün-et geçişi, su
piyasası) dosyanın gövdesiydi. Irak'ta da ülkenin kendi üretimi, suyu,
tarihi ve ürünleri kendi bölümlerini alacak.

## 1946 PROTOKOLÜ OKUNDU — altı madde

`tbmm_ss241_1947_antlasma.pdf`, 33 sayfa. 29 Mart 1946'da imzalanan Dostluk
ve İyi Komşuluk Andlaşması'nın **1 numaralı ek protokolü**: "Dicle, Fırat ve
Kolları Sularının Düzene Konması Protokolü". İmzalar: Hasan Saka, Nuri
Essaid, Feridun Cemal Erkin, Abdülilâh.

| madde | ne diyor |
|---|---|
| Başlangıç | Taşkından korunma **Irak için** önemli; uygun bent yerlerinin **Türk toprağında** bulunması umuluyor; yapılar mümkün olduğunca **sulama ve elektrik** amacına da uysun |
| 1 | Irak teknisyen gönderir, haritaları Türk kurumları hazırlar, **bütün harcamaları Irak öder** |
| 2 | Türkiye erişim, bilgi ve kolaylık sağlar |
| 3 | **Türkiye daimî gözetleme istasyonları kurar ve işletir**; işletme gideri yarı yarıya; taşkında her sabah 8'de seviye telgrafla bildirilir — Dicle'de **Diyarbakır, Cizre**, Fırat'ta **Keban** |
| 4 | Türkiye yapıları esas bakımından kabul eder; her biri ayrı anlaşmaya konu olacak — **Türkiye'nin kendi sulama ve enerji kullanımı dahil** |
| 5 | Türkiye tasarılarını Irak'a **haber vermeyi** kabul eder |
| 6 | İki taraf birer temsilci atar |

**KEBAN 1946'DA ADIYLA GEÇİYOR** — bir telgraf gözlem istasyonu olarak. Dün
yayımlanan DSİ dosyası aynı Keban'ı GAP'ın Fırat üzerindeki beş barajından
biri olarak sayıyor ve kurumun 1980'de orada su ürünleri şubesi açtığını
kaydediyor. Bağ gerçek ve belgeli.

**TON UYARISI.** Protokol metne girecek ama **nedensellik iddia
EDİLMEYECEK**: elimizde Türkiye'nin barajlarının Irak'ın suyunu ne kadar
azalttığına dair ölçüm YOK ve Irak'ın kendi kurumları kapalı. Protokol ne
diyorsa o yazılır, rakamlar ne gösteriyorsa o.

## IRAK'IN KENDİ ÜRETİMİ — FAOSTAT (bin ton)

| ürün | 2000 | 2010 | 2020 | 2022 | 2023 |
|---|---|---|---|---|---|
| Buğday | 384 | 2.749 | 6.238 | 2.765 | 4.248 |
| Arpa | 400 | 1.137 | 1.756 | **144** | 106 |
| **Pirinç** | 60 | 156 | **464** | **12** | 13 |
| Hurma | 932 | 568 | 735 | 704 | 615 |
| Domates | 989 | 1.013 | 755 | 630 | 535 |

**Pirinç iki yılda %97 düştü**; ekilen alan 102 bin hektardan 4 bine indi.
Suda duran tek ürün pirinç — su kıtlığı en net oradan okunuyor. Arpa %94
düştü. Hurma, derin köklü olduğu için yerinde duruyor.

### Hurmada dünya payı — Irak geride kaldı

| | 1961 | 1980 | 2000 | 2023 |
|---|---|---|---|---|
| Irak üretimi (bin ton) | 350 | 597 | 932 | 615 |
| Dünya payı | **%18,9** | %22,4 | %14,5 | **%6,2** |

Irak mutlak olarak çökmedi (350 → 615) ama dünya 5,4 kat büyürken Irak 1,8
kat büyüdü. Kaybedilen şey üretim değil, **yer**.

## Tur 2'de eklenen kaynaklar

| kaynak | sınıf | durum |
|---|---|---|
| TBMM S. Sayısı 241 (1947) | BİRİNCİL | indirildi, okundu |
| FAOSTAT üretim toplu indirme | BAĞIMSIZ | indirildi (34 MB), Irak 21.281 satır |
| Dünya Bankası belge arama | BAĞIMSIZ | doğrudan PDF adresi veriyor |
| FAO *Review of World Water Resources by Country* | BAĞIMSIZ | indirildi; Irak 7 kez geçiyor — **yenilenebilir suyunun yarısından fazlası için başka ülkelere bağımlı** ülkeler listesinde. ESKİ bir belge, tarihi metinde belirtilecek |
| UNESCO (Ahwar bataklıkları) | — | **403, kapalı** |

## Tur 3'te karara bağlanacak

1. **Bölüm iskeleti.** Eksen ticaret ama gövde Irak tarımı; dağılım kullanıcı
   onayına sunulacak.
2. **§2.8'in beş kategorisi.** Mezopotamya tarımın doğduğu yer — "bilim ve
   kişi" ile "kültürel açıklama" için en güçlü aday; "terk edilen ürün" için
   pirinç hazır; "Türkiye bağı" için 1946 protokolü.
3. **Çapraz kontrol borcu.** Comtrade tek yaka; 4,64 milyar dolar bağımsız
   bir seriyle oranlanacak (§2.2.1 sonu).
4. **Ortak yıl kuralı** (§2.7): Irak 2023, Türkiye 2024 verisi var;
   karşılaştırmalar ortak yıldan kurulacak, ileri not düşülecek.

---

# Tur 3 — BÖLÜM İSKELETİ (kullanıcı onaylı)

Eksen ticaret, **gövde Irak tarımı**. On dört bölümün dokuzu doğrudan
ülkenin kendi tarımı.

| # | bölüm | tür | dayanak |
|---|---|---|---|
| 1 | Bir ülkenin ekmeği — açılış | anlati | Comtrade · %14,3 · 154 kat |
| 2 | Tarımın başladığı yer | anlati | **KAYNAK ARANACAK** |
| 3 | Bugünkü Irak | veri | Dünya Bankası + DB 2014 belgesi |
| 4 | İki nehrin ülkesi | anlati | FAO su raporu · DB 2014 |
| 5 | Savaş tarlaya ne yaptı | anlati | FAO Şubat 2016 saha değerlendirmesi |
| 6 | Üç şok: ambargo, IŞİD, kuraklık | veri | FAOSTAT 1988–2023 serisi |
| 7 | Pirinç kayboldu | veri | FAOSTAT |
| 8 | Hurma: dünya payı | veri | FAOSTAT + dünya serisi |
| 9 | Toprağın tuzu | anlati | DB 2014 · DB 1972 |
| 10 | Koyun, manda ve bataklık | anlati | FAOSTAT hayvan varlığı |
| 11 | Türkiye ne satıyor | veri | Comtrade fasıl dökümü |
| 12 | Ters yön neredeyse boş | veri | Comtrade |
| 13 | 1946: suyun protokolü | belge | TBMM S. Sayısı 241 |
| 14 | Kaynakça | belge | — |

**"DÜNYADA BENZERİ" BÖLÜMÜ YOK.** Bir taslakta vardı ve kullanıcı düşürdü:
o §8.9'un **kurum dosyası** kategorisi, ülke dosyasının beş kategorisinde
(§2.8) öyle bir madde yok. İki kural seti karıştırılmayacak.

### §2.8'in beş kategorisi nerede karşılanıyor

| | kategori | bölüm |
|---|---|---|
| 1 | Bilim ve kişi | 2 — Mezopotamya |
| 2 | Kültürel açıklama | 2 ve 10 — bataklık ve manda |
| 3 | Gündelik tarım | 10 |
| 4 | Türkiye bağı | 13 — 1946 protokolü ve Keban |
| 5 | Terk edilen ürün | 7 — pirinç |

## Tur 3'te eklenen kaynaklar

| kaynak | sınıf | ne veriyor |
|---|---|---|
| FAO, *Iraq Agriculture and Livelihoods Needs Assessment* (Şubat 2016, 79 s.) | BAĞIMSIZ | savaşın tarlaya verdiği hasar, saha ölçümüyle |
| FAO GIEWS Irak ülke bülteni arşivi (79 s.) | BAĞIMSIZ | gıda güvenliği serisi |
| Dünya Bankası PID P149803 (2014) | BAĞIMSIZ | tuzluluk, drenaj, su bağımlılığı |
| Dünya Bankası Lower Khalis (1972, 135 s.) | BAĞIMSIZ | tuzluluğun tarihsel kaydı |

### Savaş bölümünün belgelenmiş rakamları

FAO Şubat 2016, birebir alıntı:
> *"About 70 to 80% of cultivated area with corn, wheat, and barley was
> damaged (causing lower yields) or destroyed in areas in Salahadin. In
> Ninewa on average 32% of acres dedicated to wheat cultivations were badly
> damaged resulting in a lower yields, and 68% was completely lost.
> Likewise, 43% of the acres used for barley were damaged while 57% was
> completely destroyed."*

Sebep listesi de belgede: yerinden edilme, siloların ve tohum-gübre
depolarının yağmalanması, devlet girdi desteğinin çökmesi.

### FAOSTAT serisi savaşı kendisi gösteriyor (buğday, bin ton)

| yıl | buğday | arpa | |
|---|---|---|---|
| 2000 | **384** | 400 | ambargo dibi — serinin en düşüğü |
| 2014 | 5.055 | 1.278 | IŞİD'in geldiği yıl |
| 2015 | **2.645** | 499 | yarıya iniyor |
| 2018 | 2.178 | **191** | dip |
| 2020 | 6.238 | 1.756 | toparlanma |
| 2022 | 2.765 | 144 | kuraklık |

## BULUNAN BİR TUZAK — tarımın payı iki farklı rakam

Dünya Bankası API'si tarımın **GSYH payını %3,41** veriyor (2025). Aynı
kurumun 2014 tarihli proje belgesi ise *"The agricultural sector contributes
to 35 percent of Iraq's non-oil GDP"* diyor. İkisi çelişmiyor — biri TOPLAM
GSYH, öteki **PETROL DIŞI** GSYH. Yalnızca %3,41 yazmak Irak'ta tarımın
yerini olduğundan küçük gösterirdi. Metinde ikisi de, farkıyla birlikte
yazılacak.

## KAPANAN — §2 için kaynak bulundu

**Managing Change in the Marshlands: Iraq's Critical Challenge**, United
Nations Integrated Water Task Force for Iraq (UNAMI + UNESCO ortak yayını),
BM Beyaz Kitap, 2011. `kaynak_dosyalari/bm_bataklik_2011.pdf`.

Aranan cümle belgede harfi harfine var ve `bagla()` ile bağlandı:
*"as the birthplace of humanity and agricultural production"*. Artık
"Mezopotamya tarımın beşiğidir" cümlesi hatırlanan değil GETİRİLEN bilgi
(§2.14.1).

Aynı belge iki şey daha veriyor: bataklıkların **%90'ından fazlasının**
1970'lerden 2003'e kadar kurutulduğu, bugün **%38'inin** geri kazanıldığı; ve
mandanın bataklıktaki sürüsünün **80.000'den ~5.000'e** indiği.

### KAPSAM ÇARPIŞMASI — bu belgenin tuzağı

BM raporu mandayı **BATAKLIK** ölçeğinde sayıyor, FAOSTAT **ÜLKE** ölçeğinde.
Aynı yıl (2011): bataklıkta ~5.000, ülkede 302.000 — **60 kat**. Çelişki
değil, farklı şeyleri sayıyorlar. Yan yana yazılsalardı okur manda sayısının
altmış kat yanlış olduğunu sanırdı. `build_data.py`'ye sekizinci doğrulama
eklendi: iki ölçek arasında en az bir büyüklük mertebesi fark varsa blok
`_olcek_uyarisi` taşımak ZORUNDA. Uyarı silinerek sınandı, üretimi durdurdu.

Bu yüzden `tuzluluk` grafiğine BM'nin %58'lik yeraltı suyu rakamı
EKLENMEDİ: Dünya Bankası'nın %40/%70'i ülke ölçeğinde toprak tuzluluğu,
BM'ninki bataklıkta yeraltı suyu. Yeni kaynağı her yere sıkıştırmak bu
dosyanın kendi kuralını çiğnemek olurdu.

## AÇIK KALAN

1. **"En büyük pazar" iddiası ÖLÇÜLMEDİ.** Comtrade ABD ve Fransa için
   ısrarla BOŞ sonuç dönüyor (hata değil, boş dizi — §2.2.1'in dokuzuncu
   tuzağı: boş sonuç sıfır değildir). Ölçülen sekiz pazarda Irak birinci ve
   ikincinin iki katı, ama "en büyük" cümlesi ölçülene kadar yazılmayacak.
   Eksen zaten ölçülmüş bir orana dayanıyor: Irak tek başına Türkiye'nin
   tarım ihracatının **%14,3**'ünü alıyor (4,64 / 32,54 milyar $).

## TUR 5 — GRAFİKLER · GÖZLE DOĞRULAMA

Doğrulayıcı yeşil yanınca durulmadı; on iki grafiğin hepsi geçici golden
üretilip GÖZLE görüldü, sonra silindi. DSİ'de doğrulayıcılar yeşilken bir
çizgi grafiği canlıda hiç çizilmiyordu.

**`ticaret_akisi` bu dizide ilk kez kullanılıyor.** Alt yakanın neredeyse
boş çıkması ölçüldü: üst yaka 2.847 piksel sütun, alt yaka 11. İki yaka aynı
cetveli paylaşıyor, yani grafik bozuk değil — 154 katı birebir çiziyor.
Okurun "yüklenmedi" diye okumaması için not bunu açıkça söylüyor.

**Düzeltilen gerçek kusur.** `hayvan` grafiği koyun/sığır/manda taşıyordu ve
notu "koyun azalırken manda çoğaldı" diyordu. İddia doğru (koyun %30,5
azalmış, manda %80 artmış) ama manda 0,15–0,27 milyon başla 13 milyonluk
eksende DÜZ ÇİZGİ oluyordu: grafiğin söz verdiği karşılaştırma görünmüyordu.
Manda kendi grafiğine çıkarıldı — orada 1996 dibi ve 2003 sonrası toparlanma
net okunuyor. `hayvan` aynı mertebedeki üçlüye indi (koyun, sığır, keçi).

**9. kural eklendi — not içindeki sayı izi.** Notlar serbest metin; sekiz
kural oradaki rakamlara hiç bakmıyordu. Ölçüt yuvarlama: yazılan sayı veri
katmanındaki bir değerin kendi basamağında doğru yuvarlanmışı olmalı.
İlk çalıştırmada kuralın KENDİ kusurunu buldu — havuz sözlük anahtarlarını
atlıyordu, yıllar ise tam orada duruyor.

**9. kuralın gücü ölçüldü.** Rastgele uydurma sayının takılmadan geçme
oranı: 1–1000 arası tam sayıda %54,7, iki ondalıklıda %6,8. Havuz
daraltılarak denendi, tam sayıda en iyi %42,9 oldu — kusur ölçek
türevlerinde değil, altmış yıllık serilerin kendisinde. Kural kaba uydurmayı
yakalar, makul görünen küçük bir tam sayıyı yakalayacağına GÜVENİLMEZ. Bu
sınır dosyanın başına yazıldı.

## TUR 6 — TASARIM

**Palet "Hurma ve Nehir".** Manzaradan değil, Irak tarımının başka yerden
gelmeyen iki maddesinden: hurma ülkenin kendi ürünü (dünya payı %18,9 → %5,9),
nehir ise değil — Dicle ve Fırat yukarıdan geliyor. Üçüncü madde, tuz, renk
değil MOTİF oldu.

**Motif "tuz poligonu" — dizinin ortak fikri bilerek kırılıyor.** Hollanda
dikey şerit, Rusya yatay bant, İspanya nokta, Avustralya ortogonal ızgara:
dördü de insan yapımı düzendi. Tuz poligonu tasarlanmaz; drenaj yetmediğinde
toprağın kendiliğinden aldığı biçimdir. Dosyanın ölçtüğü şeyle birebir: ekili
alanın %70'i tuzdan etkilenmiş. Çizici YAZILMADI — künyede açıkça belirtildi,
sayfada polder motifi görünmeye devam ediyor.

**Renk körlüğü: vekil ölçü yanıldı, benzetim yakaladı.** Dizi Hollanda'dan
beri iki serinin bağıl parlaklık oranını ölçüyor (orada 1,05 çıkmış ve
deuteranopi altında iki renk ayırt edilemiyormuş). Bu dosyada ikinci şerit
denemesi (#1C3A54 / #3F240D) normal görmede **1,67** verdi — eşiği rahat
geçiyor — ama deuteranopi altında **1,34**'e düştü. kontrast.py artık üç
körlük tipini doğrudan benzetiyor (Viénot-Mollon) ve oranı benzetim
SONRASINDA ölçüyor. Son çift: şerit 3,50, gövde 1,59 (en kötü durum).

**Ana sayfadan ayrışma artık hesaplanıyor.** Avustralya'nın künyesi bu
sayıları yazıyordu ama hiçbir betikte hesaplanmıyorlardı. Burada hesaplanıyor
ve ilk palet denemesini durdurdu: nehir koyusu #15526B ile ana sayfanın
yapısal yeşili #2F4B2E arasında oran **1,24** çıktı — kart sayfanın kendi
rengiyle aynı ağırlıkta olurdu.

**dogrula_tasarim.py — altı kural.** Künyedeki her kontrast sayısı künyenin
KENDİ hex'lerinden yeniden hesaplanıp karşılaştırılıyor; elle yazılan sayı
yazıldığı anda doğru olsa bile paletin bir sonraki değişikliğinde sessizce
yanlışa döner. Dört negatif sınav yapıldı, dördü de durdurdu.

### Doğrulayıcının bulduğu iki kendi hatam

1. **Ölçüler düzyazıya gömülmüştü.** İlk sürüm renk körlüğü sayılarını nottan
   regex ile kazıyordu ve "şerit" kelimesi notun başka bir cümlesinde geçtiği
   için gövdenin sayılarını şeride atadı. Ölçüler düzyazıdan çıkarılıp
   `_olculen_ayrisma` alanına taşındı; doğrulayıcı artık düzyazıda ölçü
   listesi kalmışsa da uyarıyor.
2. **"ikincil — Türkiye serisi" yanlıştı.** İkincil rollü seriler sayıldı:
   arpa, ekilen alan, sığır, hasar sınıfı, ticaretin çıkan yakası. Hiçbirinde
   Türkiye yok. Sebebi kullanıcı şartı — dosya yalnızca Türkiye ilişkisi
   üzerinden kurulmuyor, iki renk de çoğu grafikte Irak'ı gösteriyor. Kural 6
   künyenin rol iddiasını grafikler.json'a bağlıyor.

### Kullanıcıya sorulacak — tek taraflı yapılmadı

`kartlar` türündeki grafiklerde vurgu rengi hiç kullanılmıyor (tuzluluk
kartında amber piksel sayısı **sıfır**). Çizici kart başlığını `tema.murekkep`
ile sabitlemiş. Düzeltmek ortak çiziciye dokunmayı, yani yayındaki beş
dosyanın kart görünümünü birden değiştirmeyi gerektirir.

## TUR 7 — YAYIN KÜNYESİ VE GÖRSELLER

On dokuz aday indirildi, **hepsi gözle açıldı**, üçü reddedildi. Sekiz bölüm
görseli ve bir kapak yayına hazır (toplam 1,8 MB).

### İki başlık yalan söylüyordu

| dosya | başlık ne diyor | karede ne var |
|---|---|---|
| `Chibayish Marshes in Iraq 01.jpg` | bataklık manzarası | keffiyeli yaşlı bir adamın **portresi** |
| `Iraqi Rice Farmers DVIDS127458.jpg` | Iraklı pirinç çiftçileri | **üniformalı askerler ve çocuklar** — ne pirinç ne çiftçi |

İkincisi hem olgusal olarak yanlıştı hem de `tasarim.json`'un asker yasağını
çiğnerdi. Üçüncü ret (`Field irrigation in Iraq`) başlığı DOĞRU olan bir
kareydi: gerçekten damla sulamalı fide tarlası. Arka planda kamuflajlı bir
figür olduğu için düşürüldü; temiz alternatif vardı. Üçü de `kunye.json`'un
`_reddedilenler` bloğunda sebebiyle duruyor — sessizce silinselerdi sonraki
turda aynı başlıklar yeniden seçilirdi.

### Üçüncü kusur: EXIF yönelimi — DEPO ÇAPINDA ONARILDI

`نخيل العراق.jpg` Commons'tan **EXIF Orientation=3** ile geldi: pikselleri
180 derece dönük saklanıyor, görüntüleyici çeviriyor. Pillow bunu
`Image.open`'da **uygulamıyor**. `scripts/dosya_gorsel_optimize.py` yeniden
kodlarken etiket düşer, pikseller olduğu gibi kalırdı — hurma ağaçları
**baş aşağı** yayına çıkardı. Betikte EXIF işlemesi hiç yoktu.

Yayındaki **bütün** dosya görselleri tarandı: hiçbirinde yönelim etiketi yok,
yani canlıda kırık bir şey bulunmadı ve bu ilk vaka olacaktı. Betiğe
`ImageOps.exif_transpose` eklendi; bundan sonraki her dosya korunuyor.

### Bir tuzak daha: en-boy oranı künyeden kopyalanamaz

`irak_harman_ninova` arşiv negatifiydi; çerçevesi ve el yazısı kırpıldı ve
oranı **1,4585 → 1,3806** değişti. `kunye.json`'daki oran Commons'taki ÖZGÜN
dosyaya ait. Kopyalansaydı yerleşim yanlış olurdu. `yayin.json`'daki bütün
oranlar yayına giden dosyadan ölçüldü ve `dogrula_yayin.py` bunu her koşuda
yeniden ölçüp karşılaştırıyor.

### Görselsiz bırakılan altı bölüm — sebebiyle

| § | neden |
|---|---|
| 5 savaş | asker/tank/patlama/mülteci yasak; FAO'nun saha ölçümünü gösteren onurlu bir kare yok |
| 7 pirinç | `rice field Iraq` 58 dosya döndürdü, görülenlerin tamamı askerî ya da insanî yardım kareleri |
| 9 tuz | Irak'a ait tuz kabuğu görseli yok; başka ülkeden tuz fotoğrafı klişenin ta kendisi olurdu |
| 11, 12 | grafik zaten gövdeyi taşıyor |
| 14 | kaynakça |

### dogrula_yayin.py — yedi kural

Künye üç ayrı şeye söz veriyor: `grafikler.json` kimliklerine, diskteki
dosyalara, `data.json` sayılarına. Üçü arasındaki kayma başka hiçbir
denetimde görünmez. **Yetim grafik** kuralı da burada: üretilip hiçbir bölüme
yerleştirilmemiş bir grafik sessizce kaybolur. Beş negatif sınav, beşi de
durdurdu.

## TUR 8 — METİN

Türkçe 3.054 kelime, İngilizce karşılığı; on dört bölüm. `dogrula_metin.py`
dokuz avcı, altı negatif sınav, altısı da durdurdu.

### Seriler 2024'e kadar okununca iskeletin bir iddiası çöktü

Tur 3'te §7 "Pirinç kayboldu" başlığını taşıyordu ve §2.8'in **terk edilen
ürün** kategorisi pirince bağlanmıştı. Metni yazarken seriler son yıla kadar
okundu:

| | 2020 | 2022 | 2024 | bugün 2020'nin |
|---|---|---|---|---|
| pirinç | 464.159 t | 11.637 t | 227.508 t | **%49'u** |
| arpa | 1.756.200 t | 144.000 t | 164.495 t | **%9,4'ü** |

Pirinç geri geldi; arpa gelmedi. Dahası arpanın **altmış dört yıllık serideki
en düşük yılı ambargo dibi değil 2023** (105.903 ton). Yani terk edilen tahıl
arpa, pirinç ise kapatılıp açılabilen ürün.

İskelet düzeltildi: §7 "Kapatılıp açılan ürün", §6 "Üç şok ve geri gelmeyen
tahıl". §2.8/5 kategorisi arpaya taşındı. `pirinc` ve `uc_sok` grafiklerinin
notları, ana sayfa hikâyesinin birinci slaytı ve bölüm başlıkları da aynı
bulguya göre yeniden yazıldı. Bir grafik de kodla duruyordu ("HS 04"); adı
yazıldı.

### §2.8/1 için kaynak arandı ve SINIRIYLA birlikte bulundu

"Bilim ve kişi" kategorisi için Ebu Garib tohum bankası araştırıldı. Ağda
dolaşan ayrıntılı anlatı (2003'te bombalanma, sınırdan geçirilen yedek
koleksiyon, 1.400 kaybolan çeşit) **birincil kaynağa bağlanamadı**: Nature'ın
ilgili yazısı kimlik doğrulama istiyor, ikincil özetler kaynak sayılmıyor
(§2.14.1). Metin yalnız BM Irak / FAO duyurusunun (19 Mayıs 2024) kendi
ifadelerini kullanıyor: banka 1977'den beri çalışıyor, altyapısı hasarlı,
ICARDA ile onarım projesi var. Kayıp iddiası yazılmadı.

### Doğrulayıcının yakaladığı kendi hatalarım

1. **Yuvarlanmış rakam.** Slayta 227.544 ve 101.600 yazmıştım; gerçek
   değerler 227.508 ve 101.594. `dogrula_yayin.py` durdurdu.
2. **Kendi vurgu tırnaklarım kaynak alıntısı sanılıyordu.** Dizinin kuralı
   kaynak alıntısının `*"..."*` ile yazılması; düz tırnak yazarın kendi
   terimi. Ayrım koda geçti, uzun düz tırnak (60+) yine de bağlanmak zorunda.
3. **Düzenli ifade ardışık tırnak çiftlerini yanlış eşleştiriyordu** —
   birinin kapanışıyla ötekinin açılışını. `split('"')[1::2]` ile düzeltildi.
4. **Numaralı liste kuralı yanlıştı.** "154." ve "2024." satır başına düşmüş
   ve kural onları madde sandı. `dossier_prose.dart` numaralı listeyi
   BİLEREK desteklemiyor, gerekçesini de kendi yazıyor. Kural kaldırıldı:
   yanlış olan metin değil kuraldı.

### Çeviri muafiyetinin bedeli: alıntı paritesi

1946 protokolü Türkçe. İngilizce metin onu çeviriyle veriyor ve çeviri kaynak
metninde harfi harfine bulunmaz. Bu DÜŞÜRMÜYOR, kayda geçiyor — ama muafiyet
uydurma alıntıya kapı açmasın diye bölüm başına alıntı SAYISI iki dilde aynı
olmak zorunda (9. avcı). §13'te yedi çeviri alıntısı var ve yedisi de kayıtlı.

## TUR 8 DÜZELTMESİ — UZUNLUK (kullanıcı uyarısı, 2 Kasım 2026)

Dosya 14 bölüm ve **2.544 kelimeyle dizinin en kısasıydı**:

| | bölüm | gövde | bölüm başına |
|---|---:|---:|---:|
| Hollanda (01) | 17 | 5.325 | 332 |
| Rusya (02) | 20 | 4.928 | 259 |
| Avustralya (04) | 17 | 3.788 | 236 |
| Irak — ÖNCE | 14 | 2.544 | 195 |
| **Irak — SONRA** | **18** | **4.470** | **262** |

"Kaynak az" gerekçe değildi: eklenen dört bölümün tamamı veri katmanında
DURAN ama hiçbir bölümde geçmeyen bloklardan geldi.

### §8 — sekiz tur boyunca görülmemiş bulgu

Üretim = alan × verim. Ayrıştırılınca hurmanın hikâyesi değişti: üretim 1,7
kat artmış görünüyor ama **alan 2,45 kat artmış, verim 0,62 kata düşmüş**.
Dünya payının %18,9'dan %5,9'a inişinin mekanizması bu. Sekiz tur boyunca
üretim serisine tek başına bakılmıştı.

### Yanlış grafik türü seçtim ve golden ölçerek yakaladım

§8 için önce `ikili_cubuk` kullandım. Çizici o türde **her satırı kendi içinde
ölçekliyor** (`dossier_chart_view.dart` satır 263); `siralama` ise grafik
genelinde (satır 373). Yani mısırın 50 katlık alanı, pirincin 2 katıyla aynı
uzunlukta çiziliyordu. Doğrulayıcı bunu göremez — tür geçerli, @yollar çözülü,
dokuz kural yeşil. Golden'ın piksel genişlikleri ölçülerek bulundu. İki
`siralama`ya çevrildi.

`savas_hasari`'nın notu zaten söylüyormuş: "her satır kendi içinde %100'e
tamamlanıyor". `ikili_cubuk` BİLEŞİM içindir, büyüklük karşılaştırması için
değil. Bu ayrım yayin.json'a yazıldı.

### Göçe uzunluk sağlaması eklendi

Gövde 4.300 kelimenin altına düşerse migration durur. İlk sürümü yalnız
boşluk sayıyordu ve 4.470 kelimelik gövdeyi 4.020 görüp göçü haksız yere
durduruyordu — metin sabit genişlikte sarılı, kelimelerin bir kısmını satır
sonu ayırıyor. Satır sonu da ayraç sayıldı.
