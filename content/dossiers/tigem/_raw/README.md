# TİGEM — Kurum Dosyası Sayı 06 · kaynak araştırması

**Tarım İşletmeleri Genel Müdürlüğü.** Kurum rotasyonunda sıra 6 (§8.13);
DSİ devir göçü takvime "Yakında: TİGEM" yazdı. DSİ penceresi **16 Kasım
2026**'da kapanıyor.

> **SUPABASE KAPALI.** Proje `exceed_storage_size_quota` nedeniyle 402
> veriyor; canlı site içeriksiz. Bu dosyanın 1–9. turları Supabase'e hiç
> dokunmuyor. Yalnız devir (tur 10) bekliyor.

---

## Erişim haritası

Önce bu okunur. **Durum koduna değil içerik türüne ve gövde uzunluğuna
bakıldı** — Irak dosyasının dersi: pek çok kurum sitesi olmayan yol için
200 + text/html döndürüyor.

### Açık

| kaynak | sınıf | ne veriyor |
|---|---|---|
| `tigem.gov.tr/Tarih` | KURUMUN BEYANI | İki kök: Osmanlı haraları ve 1937 Zirai Kombinaları; 1984 birleşmesi |
| `tigem.gov.tr/Hakkimizda` | KURUMUN BEYANI | Ana statü görevleri; "yer kiralar, **kiraya verir**" |
| `tigem.gov.tr/Isletme/Index/1` | KURUMUN BEYANI | Faaliyette olan işletmeler |
| `tigem.gov.tr/Isletme/Index/2` | KURUMUN BEYANI | **Kiraya verilen işletmeler — kiracı şirketlerle birlikte** |
| `tigem.gov.tr/Isletme/Index/3` | KURUMUN BEYANI | İştirakler |
| `tigem.gov.tr/Mevzuat/Index/1,2,3` | — | Ana Statü · kanunlar ve KHK'lar · ikincil mevzuat (61 PDF) |
| `tigem.gov.tr/Bilgi/Tohumluk`, `/Bilgi/Damizlik`, `/Bilgi/Istatistikler` | KURUMUN BEYANI | Tohumluk, damızlık, istatistik sayfaları |
| `resmigazete.gov.tr/arsiv/18435_1.pdf` | **BİRİNCİL** | 233 sayılı KHK'nın yayımlandığı RG nüshası · 11,7 MB · `%PDF` doğrulandı |
| `mevzuat.gov.tr/MevzuatMetin/4.5.233.pdf` | **BİRİNCİL** | 233 sayılı KHK, derlenmiş metin · 524 KB · `%PDF` doğrulandı |
| `sayistay.gov.tr/reports/category/8-kamu-isletmeleri-genel-raporlari` | **BAĞIMSIZ** | Kamu İşletmeleri Genel Raporu, **2015–2024 serisi** |
| `sayistay.gov.tr/reports/download/<id>` | **BAĞIMSIZ** | Raporun kendisi · 2024: 532 KB, 37 sayfa, `%PDF` |

**Sayıştay raporu doğrulandı:** 2024 nüshasının 27. sayfasında TİGEM'in mali
satırı var ve **TMO ile TCDD aynı tabloda** — kurumlar arası karşılaştırma
hazır geliyor. On yıllık seri grafik için yeterli.

### Kapalı ya da sorunlu — tekrar denenmesin

| kaynak | sonuç |
|---|---|
| `tigem.gov.tr/Sayfa/Detay/<ad>` (tahminî yollar) | 200 ama **tam olarak 40.313 bayt** — üç ayrı yol aynı kabuk, yumuşak 404 |
| `tigem.gov.tr/AraziVarligi` | 200, sayfa gerçek, ama HTML'de **ölçülü tek rakam yok** — JavaScript ya da bulunamayan bir PDF |
| `tigem.gov.tr/StratejikPlan` | aynı — gövdede rakam yok |
| `mevzuat.gov.tr/MevzuatMetin/1.3.5433.pdf` | 200 ama **text/html** — yumuşak 404; 1950 Devlet Üretme Çiftlikleri kanunu başka yoldan aranacak |
| `sayistay.gov.tr/reports?q=…` ve `?category=…` | **418** — sorgu parametresine bot savunması. Temiz kategori yolu çalışıyor |
| `sbb.gov.tr/kamu-isletmeleri-raporu/` | 404 |
| `tbmm.gov.tr/komisyon/kit` | 404 — üstelik hata sayfası `image/png` döndürüyor |
| `data.tuik.gov.tr/Kategori/GetKategori` | 200 ama 3,6 KB — JavaScript kabuğu |

---

## Tur 1'de çıkan ve tur 2'ye taşınan izler

**1. İki kök, ikisi de orduyla başlıyor.** `/Tarih` sayfası TİGEM'in iki
koluna işaret ediyor: Osmanlı **haraları** (ordunun ve sarayın iaşesi, at
yetiştirme) ve Cumhuriyet'in **Zirai Kombinaları** (1937; ordunun gerektiğinde
halkın gıda ihtiyacı). İkisi 1984'te 233 sayılı KHK ile tek çatı altında
toplanıyor. §8.9/1 "kurucu kişi ve fikir" için tek kurucu yok — **iki soy** var.

**2. Devletin çiftçisi, çiftliklerinin bir bölümünü kiraya vermiş.**
`/Isletme/Index/2` kiraya verilen işletmeleri kiracı şirketlerin iletişim
bilgileriyle listeliyor (Acıpayam–Denizli, Alparslan–Muş, Altındere–Van,
Atatürk–Yalova, Çiçekdağı–Kırşehir, Gelemen–Samsun…). Ana statü de bunu
açıkça yetki olarak sayıyor: "yer kiralar, kiraya verir". Eksen adayı.

**3. Dizide dördüncü kurum türü.** TMO kırmızı = kamu gücü, Ziraat yeşil =
finans, Tarım Kredi toprak = üretici örgütü, DSİ = altyapı. TİGEM bunların
hiçbiri değil: **devletin bizzat üretici olması.** Küme ve palet tur 6'da
buradan kurulacak.

## Açık kalan — tur 2'de aranacak

1. **Arazi varlığı rakamı.** Kurumun tanımlayıcı sayısı; sayfada yok.
   Sayıştay raporunda ya da faaliyet raporunda aranacak.
2. **TİGEM faaliyet raporları.** Site haritasında görünmedi; `/Folder/`
   altındaki PDF'ler taranacak.
3. **1950 tarihli 5433 sayılı kanun** (Devlet Üretme Çiftlikleri) — Resmî
   Gazete arşivinden sayı numarasıyla aranacak.
4. **İşletme sayıları.** Faaliyette olan ve kiraya verilen işletmelerin
   kesin sayısı; HTML'den sayılacak, menü tekrarından ayıklanarak.

---

# Tur 2 — EKSEN

## Ölçülenler

**Arazi** (`/Folder/AraziVarligiDosyasi/…pdf`, işletme işletme tablo):

| | dekar |
|---|---:|
| Toplam arazi | **3.273.792** |
| Kültüraltı | 2.788.405 |
| Tarla | 1.756.580 |
| Tabii mera | 629.138 |
| Sulanan | 940.568 |
| **Ceylanpınar tek başına** | **1.633.157 — toplamın yarısı** |

**İşletme sayısı** (`/Isletme/Index/1,2,3`, adlar tek tek sayıldı):
**17 faaliyette · 17 kiraya verilmiş · 2 iştirak.** Yarı yarıya.

**Ölçek karşılaştırması** (Dünya Bankası, bağımsız): Türkiye'nin tarım
arazisi 386.400 km² (2024). TİGEM 3.274 km² → **%0,85.**

**Sulama karşılaştırması:** TİGEM'in kültüraltı arazisinin %33,7'si sulanıyor;
Türkiye'de tarım arazisinin %12,7'si (Dünya Bankası 2024). **2,6 kat.**
İki oranın PAYDASI farklı — biri kültüraltı, öteki tüm tarım arazisi. Metinde
bu fark yazılmadan karşılaştırma kurulmayacak.

**Tohumluk payı** (TİGEM'in kendi kataloğu, s. 5): TÜİK 2025 verisiyle
Türkiye'de 7,1 milyon hektar buğday, 3,2 milyon hektar arpa ekiliyor. Tohumun
3 yılda bir yenilenmesi esasına göre sertifikalı hububat tohumu ihtiyacı
buğdayda 547 bin ton, arpada 243 bin ton, **toplam 790 bin ton**. Bunun
**yaklaşık %20'si TİGEM tarafından karşılanıyor.**

> **KAYNAK SINIRI.** Bu %20 KURUMUN KENDİ BEYANI. Bağımsız bir karşılığı
> (BÜGEM ya da TÜİK tohumculuk istatistiği) henüz bulunamadı. Metinde ya
> bağımsız kaynak bulunur ya da "kurumun kendi bildirimi" diye yazılır.

## Eksen adayları

**A — Az toprak, çok tohum.** Kurum Türkiye tarım arazisinin %0,85'ini
tutuyor ama sertifikalı hububat tohumunun yaklaşık beşte birini veriyor.
Sebebi: ürettiği şey gıda değil **girdi**. Çiftçi TİGEM ile pazarda değil,
ekim zamanında karşılaşıyor. Dizideki öteki dört kurumdan ayrıldığı nokta da
tam burası — TMO ürünü alır, Ziraat kredi verir, Tarım Kredi ortaklık kurar,
DSİ suyu getirir; TİGEM tohumu ÜRETİR.

**B — Devletin çiftliklerinin yarısı kirada.** 34 işletmenin 17'si özel
şirketlere kiralanmış; ana statü bunu açıkça yetki sayıyor ("yer kiralar,
kiraya verir"). Çarpıcı ama dosyayı özelleştirme tartışmasına çeker;
kullanıcı kararı: *"maliyet hesabı dosyası yapmıyoruz, kurumu tanıtıyoruz."*
Eksen değil, kendi bölümü olmalı.

**C — İki kök, ikisi de ordu.** Osmanlı haraları (ordu ve sarayın iaşesi,
at) + 1937 Zirai Kombinaları (ordunun gerektiğinde halkın gıdası) → 1984'te
233 sayılı KHK ile tek çatı. §8.9/1'in karşılığı; eksen değil, açılış.

## Tur 2'de çıkan ek malzeme

Kurumun kataloğu, tohum ve damızlığın yanında şunları da koruduğunu yazıyor:
**yerel (Ata) tohumları, Safkan Arap Atı, Ankara Tiftik Keçisi, Kangal Köpeği
ve Asya Ceylanı.** Bir devlet çiftliğinin aynı zamanda Kangal'ı ve ceylanı
kaybolmaktan koruması §8.9/3 "gündelik karşılık" ve kültürel açıklama için
güçlü malzeme.

---

# Tur 3 — BİRİNCİL BELGELER VE İSKELET

Eksen **A — Az toprak, çok tohum** kullanıcı tarafından kilitlendi
(10 Kasım 2026). Bu tur eksenin altına birincil belge koydu ve dosyanın
bölüm iskeletini kurdu.

## Birincil belge zinciri — hepsi indirildi, imzası doğrulandı

Beş kanun da **TBMM Kanunlar Dergisi**'nden alındı; her biri Resmî Gazete
tarih ve sayısını kendi ilk satırında taşıyor. Yol deseni kayda geçti:
`www5.tbmm.gov.tr/tutanaklar/KANUNLAR_KARARLAR/kanuntbmmc0<CC>/kanuntbmmc0<CC>/kanuntbmmc0<CC>0<NO>.pdf`
— cilt numarası bilinmiyorsa 15–36 arası taranır.

| belge | tarih | RG | ne veriyor |
|---|---|---|---|
| **3130** sayılı Kanun | kabul 12.II.1937 | 19/11/1937 · 3538 | Zirai Kombinalar Kurumu'nun **tahsisatı** |
| **3308** sayılı Kanun | kabul 7.I.1938 | 13/1/1938 · 3807 | Devlet Ziraat İşletmeleri Kurumu; **Atatürk'ün bağışı sermaye oluyor** |
| **5254** sayılı Kanun | kabul 8.VII.1948 | 14/7/1948 · 6957 | Muhtaç çiftçiye ödünç tohumluk — 2001'de mülga |
| **5433** sayılı Kanun | kabul 7.VI.1949 | 13/6/1949 · 7231 | Devlet Üretme Çiftlikleri; **görev cümlesi** |
| **5659** sayılı Kanun | kabul 24.III.1950 | 1/4/1950 · 7472 | Atatürk Orman Çiftliği ayrı müdürlük oluyor |
| **3646** sayılı Kanun | kabul 16.V.1990 | 25/5/1990 · 20528 | Arazi TİGEM adına tapuya geçiyor |
| **233** sayılı KHK | 8.6.1984 | 18435 | TİGEM ekli cetvelde; dipnot 47 |
| **Ana Statü** · CB Kararı 5141 | 1.2.2022 | 2/2/2022 · 31738 | Bugünkü kurucu metin |

### 1. Ödeneğin kanundan önce geldiği yer — 3130 (1937)

Zirai Kombinalar Kurumu'nu kuran bir kanun yok. **3130 sayılı Kanun bir ek
bütçe kanunu**: 1936 malî yılı muvazenei umumiyesine 4.512.636 liralık
fevkalade tahsisat koyuyor ve bunun **3.000.000 lirası** tek bir fasla,
Ziraat Vekâleti bütçesinde yeni açılan **858'inci fasıl, "Ziraî kombinalar
kurumu masrafları"** faslına gidiyor. Tek fasıl, o kanunun koyduğu bütün
fevkalade tahsisatın üçte ikisi.

Dördüncü madde tahsisatın nereye yatırılacağını da yazıyor: **Ziraat Bankasında
açtırılacak hususî bir kredi hesabına.** Ve şu cümleyi kuruyor —
*"Bu krediden yapılacak masraflar hususî bir kanun ile tayin olunur. Ancak
bu kanunun tanzim ve meriyete girmesine kadar İcra Vekilleri Heyeti kararile
tayin edilecek işler için sarfiyat yapılır."*

Yani kurumun ödeneği, kurumun kanunundan on bir ay önce ayrılmış. §8.9/2'nin
("parayı nereden buldu") karşılığı bu. Ve tahsisat **Ziraat Bankası'nda** duruyor —
Sayı 02'ye bağ.

### 2. Atatürk'ün mektubu sermaye oluyor — 3308 (1938)

Beklenen "hususî kanun" 3308. Birinci madde Ankara merkezli, hükmî
şahsiyeti haiz **Devlet Ziraat İşletmeleri Kurumu**'nu kuruyor.

**BEŞİNCİ MADDE, kelimesi kelimesine:** *"Atatürkün 11-VI-1937 tarihli mektub
ile Hazineye teberru ettiği bütün menkul ve gayrimenkul mallar ve bunlara aid
hak ve vecibeler bu kanunun neşri tarihinden itibaren Devlet ziraat işletmeleri
kurumuna intikal eder."*

Aynı maddenin sonu, bu malların Maliye, Ziraat ve kurumdan birer kişilik üç
kişilik bir komisyonca değerlenip **"sermaye hesabına mahsuben vukubulmuş
tediye sayıl"**acağını söylüyor. İtibarî sermaye 15.000.000 TL (madde 6).

Kurumun ilk sermayesi nakit değil **toprak**. Kurumun sitesi bunu "Atatürk'ün
çiftliklerini bağışlamasıyla" diye yazıyor; kanun metni tarihi ve mekanizmayı
da veriyor. §8.9/1 ve §8.9/2 aynı maddede.

### 3. 1949 cümlesi ile 2022 cümlesi aynı cümle

**5433/1. madde (1949):** *"Yurt çiftçiliğinin zirai verimini artırmak,
istihsalini çeşitlendirmek ve mahsulün kalitesini yükseltmek amacı ile **iyi
tohumluk, damızlık ve fidan** ihtiyacını sağlamak, tarım alanında çiftçiye
örneklik ve öğreticilik etmek üzere…"*

**Ana Statü/5. madde (2022):** *"Ülkenin bitkisel ve hayvansal üretimini
artırmak, çeşitlendirmek ve ürün kalitesini iyileştirmek amacıyla kurulan
TİGEM'in faaliyet konuları…: a) Ürettiği **tohumluk, fidan, fide** ve benzeri
ürünler ile yetiştirdiği **damızlık** hayvanlar ve spermalarını üreticilere
intikal ettirmek."*

Yetmiş üç yıl, iki ayrı rejim, üç ayrı kurum adı — **görev tanımı aynı.**
Dosyanın omurgası bu eşleşme. Eksen A'nın belge karşılığı da bu: kurumun
ürettiği şey gıda değil, **girdi**.

5433/2-c ayrıca satışı da yazıyor: *"Yüksek vasıflı tohum, damızlık ve
fidanları **bedeli karşılığında** çiftçiye dağıtmak."* Bedava değil, bedelle.

### 4. 1984 ve 1994 — iki ayrı statü

233 sayılı KHK'nın ekli cetvelinde TİGEM, "İlgili Bakanlık: **TARIM VE
KÖYİŞLERİ BAKANLIĞI**" başlığı altında, **Toprak Mahsulleri Ofisi, Türkiye
Zirai Donatım Kurumu ve Türkiye Süt Endüstrisi (SEK) ile aynı tabloda**
duruyor. Dördünden ikisi bugün kapanmış kurum (§8.13'te sıra 15 ve 20), biri
dizinin Sayı 01'i.

TİGEM satırının **dipnot 47'si**: *"24/11/1994 tarih ve 4046 sayılı Kanun'un
35 inci maddesi ile İktisadi Devlet Teşekkülü (İDT) bölümüne eklenmiştir."*

Kurumun kendi `/Tarih` sayfası da aynısını söylüyor: 1984'te **KİK** olarak
kuruldu, **1994'te İDT** oldu. İki kaynak birbirini doğruluyor.

> **SINIR — bu cümle böyle yazılmayacak.** 4046 özelleştirme kanunudur ama
> 35. maddesi 233'ün ekli cetvellerini topluca yeniden tespit etmiştir;
> TİGEM hakkında özel bir karar değildir. Metinde "özelleştirme kanunuyla
> listeye girdi" denmez; "statüsü 1994'te KİK'ten İDT'ye geçti, dayanağı
> 4046'nın 35. maddesidir" denir.

### 5. Toprak altı yıl sonra tapuya geçiyor — 3646 (1990)

Kanunun adı zaten her şeyi söylüyor: *Tarım İşletmeleri Genel Müdürlüğü Adına
Tescil Edilecek Taşınmaz Mallar Hakkında Kanun.* Birinci madde iki soyu tek
tek sayıyor:

- (a) **mülga 5433 sayılı Kanunla Devlet Üretme Çiftlikleri'ne intikal eden**
  taşınmazlar,
- (b) Hazineye ait olup **hara ve inekhanelere** tahsisli taşınmazlar.

Yani "iki kök" kurumun anlatısı değil, kanunun kendi tasnifi. Madde 4
tescili yapılan taşınmazların **sermayeye ilave** edileceğini, madde 6
işlemlerin her türlü vergi ve harçtan muaf olduğunu söylüyor.

**Madde 5, 2001'de eklenen fıkra:** Bandırma-Marmara Hayvancılık, Lalahan
Hayvancılık Merkez, Yerköy Tiftik Keçisi Araştırma Enstitüleri ve
Konya/Ereğli Koyunculuk Üretme İstasyonu bu kanunun dışında bırakılıyor —
**araştırma enstitüleri TİGEM'e geçmiyor.** Sayı 04'e (TAGEM) doğrudan bağ.

### 6. Çiftçinin tohuma ulaştığı yol belgelenmiş

`Tohumluk Satış ve Dağıtım Yönergesi` (YKK 10/03/2017-80, değişik
22.12.2022-401) **dört dağıtım kanalı** sayıyor (madde 7):

1. **İşletmeler** — doğrudan peşin satış. *"Yönetim Kurulu tarafından
   belirlenen peşin satış fiyatı üzerinden çiftçinin Genel Müdürlüğe veya
   İşletmelere **yazılı müracaatı** ile gerçekleştirilir."*
2. **TİGEM Bayileri** — Bayilik Sözleşmesi, süre 1 yıl, kendiliğinden uzar.
3. **İl Müdürlükleri** — yazıyla talep, Genel Müdürlük tahsis eder.
4. **Dağıtıcı kuruluşlar** — yönergede adıyla: **Tarım Kredi Kooperatifleri
   (T.K.K.)** ve **Pankobirlik**. Sayı 03'e ve rotasyonda 19'a bağ.

Bayi yolu adım adım ve süreli (madde 9): Bayi Otomasyon Sistemi'nden ön talep
→ TİGEM ön tahsis → **5 iş günü** içinde bedelin **%10'u** peşin yatırılırsa
kesin tahsis → çevrilmeyen ön tahsis sistemce otomatik iptal → kesin tahsis
**20 takvim günü** içinde işletmeden teslim alınır → ödeme nakit veya teminat
mektubu → sevkiyat randevuyla. Yükleme işletmenin, nakliye bayinin.

Fiyatlar **her yıl Haziran–Ağustos'ta Yönetim Kurulunca** belirleniyor
(madde 6).

> §8.12 kuralı sağlandı: biçim kaynaktan sonra seçildi. Adımlar, aktörler ve
> **süreler** belgede yazılı olduğu için bu bölüm `islem_akisi` olacak.
> Ziraat dosyasında bu tür yoktu çünkü kaynak yoktu; burada var.

### 7. Kiralama yetkisi nerede yazılı — ve nerede yazılı değil

Ana Statü madde 5/1-(f) *"yer kiralamak, kiraya vermek"* diyor ama bağlamı
**üretim, işleme ve pazarlama tesisi kurmak**; (g) ise **fonksiyonunu
yitirmiş kümes, ahır, depo** gibi binaları kapsıyor. İkisi de "işletmenin
tamamını kiraya vermek" demiyor.

İşletmelerin uzun süreli kiralanmasının kendi yönergesi var ve dayanağını
233 sayılı KHK, Ana Statü, **641 sayılı KHK** ve YK kararları olarak
gösteriyor. Karar zinciri yönergede sırayla yazılı:

Strateji Geliştirme Dairesi raporu → **Yönetim Kurulu kararı** → İnşaat ve
Emlak Dairesi, şartname ve sözleşmelerle birlikte **Cumhurbaşkanlığına**
sunar → **Cumhurbaşkanlığı Kararı** (süre ve şartları o belirler) → Kira
Tespit Komisyonu (en az üç kişi, işletmenin bulunduğu yerde, **30 gün**,
oybirliği, çekimser olamaz) → ihale → Yönetim Kurulu onayı.

Kararın kurumun kendi elinde olmadığı burada görünüyor: süreyi ve şartları
Cumhurbaşkanlığı belirliyor. Bölüm bunu **anlatır, tartışmaz** — kullanıcı
kararı: *"maliyet hesabı dosyası yapmıyoruz. kurumu tanıtıyoruz."*

---

## EKSENİN RAKAMI DÜZELTİLDİ — tur 2'deki %20 yanlış paydaydı

Tur 2, kurumun kataloğundan **"790 bin ton ihtiyacın ~%20'si TİGEM'den"**
diye kaydetmişti ve bağımsız karşılığı bulunamadığı not edilmişti. Bu turda
karşılık bulundu ve **payda hatası çıktı.**

`Tohumculuk Sektör Raporu 2022` (TİGEM yayını) Tablo 9 ve Tablo 10'u yan yana
basıyor; Tablo 9'un kaynağı **TOB — Tarım ve Orman Bakanlığı**, yani ülke
rakamı kurumun kendi beyanı değil.

| ton | 2002 | 2010 | 2015 | 2020 | 2021 | 2022 |
|---|---:|---:|---:|---:|---:|---:|
| Türkiye buğday | 80.089 | 262.764 | 483.819 | 485.366 | 490.027 | 443.978 |
| Türkiye arpa | 4.127 | 31.822 | 124.932 | 221.526 | 139.292 | 169.228 |
| **Türkiye toplam** | **84.216** | **294.586** | **608.751** | **706.892** | **629.319** | **613.206** |
| TİGEM buğday | 72.059 | 156.925 | 128.383 | 136.055 | 106.631 | 104.319 |
| TİGEM arpa | 3.753 | 16.795 | 14.484 | 19.893 | 11.168 | 17.726 |
| **TİGEM toplam** | **75.812** | **173.720** | **142.867** | **155.948** | **117.799** | **122.045** |
| **TİGEM payı** | **%90,0** | **%59,0** | **%23,5** | **%22,1** | **%18,7** | **%19,9** |

- **%20, "ihtiyacın" değil "dağıtılanın" payı.** 122.045 / 613.206 = %19,9.
  Aynı miktarın 790 bin tonluk ihtiyaca oranı **%15,4**. Kataloğun cümlesi iki
  paydayı birbirine karıştırıyor; metin dağıtım paydasını kullanacak ve
  paydayı cümlenin içinde yazacak.
- **Pay düşüyor ve sebebi kurumun küçülmesi değil.** 2002–2022 arasında
  Türkiye'nin sertifikalı hububat tohumu dağıtımı **7,28 kat**, TİGEM'inki
  **1,61 kat** arttı. Kurum büyüdü, ülke daha hızlı büyüdü.
- Raporun kendi cümlesi de aynısını söylüyor: payın düşmesi *"özel sektör
  firmalarının da sertifikalı hububat tohumu üretimi alanında hızlı bir
  şekilde geliştiğini net olarak göstermektedir."*

**Eksen bundan güçlendi, zayıflamadı.** Az toprakla çok tohum hâlâ doğru; üstüne
bir de tarih geldi: kurum bir zamanlar ülkedeki sertifikalı hububat tohumunun
**neredeyse tamamıydı**; bugün beşte birini veriyor çünkü var olmak için
kurulduğu pazar nihayet oluştu. Tanıtım dosyasının tonuna da uyuyor (§8.2) —
bu bir başarı cümlesi, suçlama değil.

## Tur 3'te çıkan ek malzeme

- **341 ton/saat** tohum hazırlama kapasitesi; otomatik paketleme, barkodlama,
  paletleme (Sektör Raporu 2022, s. 19–20).
- **Özel Bayilik Sistemi 2004'te** devreye girmiş (aynı rapor, s. 18).
- **5254 sayılı Kanun (1948):** kuraklık, don, sel, haşere ve yangından
  mahsulü en az %40 zarar görmüş çiftçiye, **Ziraat Bankası eliyle ödünç ve
  faizsiz** tohumluk. Kanun Tarım Kredi Kooperatiflerini de adıyla anıyor.
  Sektör Raporu'na göre **TİGEM ürettiği tohumun yarısından fazlasını** bu
  kanun çerçevesinde dağıtmış; kanun 2001'de 4684 sayılı Kanunla kalkmış ve
  2001–2002'de ülkede sertifikalı tohum kullanımı hızla düşmüş.
- **5659 sayılı Kanun (1950):** Atatürk Orman Çiftliği ayrı bir müdürlük
  oluyor, sermayesi 7.500.000 lira. 5433'ten dokuz ay sonra: soy yeni adını
  aldığı anda en ünlü çiftliği soydan ayrılıyor.
- **Sayıştay 2024 künye satırı:** esas sermaye 9.356.000 bin TL, ödenmiş
  7.855.747 bin TL, özkaynak 22.856.983 bin TL, uzun vadeli yabancı kaynak
  yok. Aynı tabloda TMO ve TCDD var. *(Künye için; bölüm değil.)*
- **Ana Statü sermaye dizisi:** 3,316 milyar TL (CB Kararı 5141, Şubat 2022)
  → 4,356 milyar TL (CB Kararı 6650, Ocak 2023) → 9,356 milyar TL esas
  (Sayıştay 2024).
- **Yerel Çeşit Listesi** 37 sayfa, çeşit çeşit künyeli (Şahnalı Acı Biber
  TGM18335 gibi). 11. bölümün malzemesi.
- **TİGEM-TAGEM ortak** "Yerli ve Millî Sebze Tohumları" yayını var.

## Tur 3'te yoklanan ve işe yaramayanlar

| kaynak | sonuç |
|---|---|
| `tigem.gov.tr/Folder/MevzuatDosyasi/…ana_statu.pdf` | PDF gerçek ama metin **JBIG2 taranmış görüntü**; pypdf 311 karakter çıkarıyor |
| `resmigazete.gov.tr/eskiler/2022/02/20220202-13.htm` | 404 — RG'nin bu nüshasında htm sürümü yok |
| `mevzuat.gov.tr/mevzuat?MevzuatNo=5141…` | 200 ama JavaScript kabuğu, 1.725 karakter |
| `mevzuat.gov.tr/MevzuatMetin/1.3.5433.pdf` | yumuşak 404 (tur 1) — **TBMM Kanunlar Dergisi çözdü** |
| `tigem.gov.tr/Bilgi/Istatistikler` | sayfa JavaScript'e bağlı; rakam HTML'de yok |

**Taranmış PDF okuma yolu kayda geçti** (poppler, tesseract, pymupdf yok):
`pypdf` ile sayfa sayfa tek sayfalık PDF'e böl → `qlmanage -t -s 2400 -o <dizin>`
ile PNG üret → görüntüyü oku. 2400 piksel genişlik hukuk metni için yeterli.

---

# TUR 3 — İSKELET (13 bölüm + kaynakça)

§8.3: iskelet sabit değil. Önceki kurum dosyaları TMO 11, Ziraat 13, TAGEM 13,
DSİ 10 bölüm kullandı. TİGEM'de **14 bölüm** var çünkü dosyada iki soy, bir
eksen, bir süreç ve bir koruma hikâyesi birlikte duruyor.

**UZUNLUK TABANI — pazarlık dışı.** Yayımlanmış kurum dosyalarının gövdesi:
TMO 3.019, Ziraat 2.941, DSİ 3.063 kelime. §8.1 ağır dosya için ~4.000 kelime
yazıyor. **TİGEM'in TR gövdesi en az 4.000 kelime olacak** (kaynakça hariç) —
hem şartnamenin yazdığı rakam, hem bugüne kadarki her kurum dosyasının üstü.
Tur 8'de `dogrula_metin.py`, tur 9'da göç dosyası bunu sınayacak.

| # | bölüm | tür | dayanak | §8.9 |
|---|---|---|---|---|
| 1 | **Tohumun geldiği yer** | anlatı | Ana Statü md. 4–5; arazi varlığı; Tablo 9–10 | — |
| 2 | **Önce ödenek, sonra kanun** | belge | 3130 md. 2 ve 4; fasıl 858 | 1, 2 |
| 3 | **Haralar: ordunun atı** | anlatı | kurumun `/Tarih` beyanı; 3646 md. 1-b | 1 |
| 4 | **Atatürk'ün mektubu** | belge | 3308 md. 1, 5, 6 | 1, 2 |
| 5 | **1949'da yazılan cümle** | belge | 5433 md. 1, 2; Ana Statü md. 5 | — |
| 6 | **Kuruluş 1983, çerçeve 1984** | belge | 95 sayılı KHK; 233 KHK ekli cetvel + dipnot 47 | — |
| 7 | **Toprak 1990'da tapuya geçti** | veri | 3646; arazi varlığı tablosu | 2 |
| 8 | **Türkiye'nin yüzde birinden azı** | veri | arazi 3.602.454,68 da; DB 386.400 km² | — |
| 9 | **Ülkenin tohumu: doksandan yirmiye** | veri | Tablo 9–10 serisi 2002–2022 | — |
| 10 | **Çiftçi tohumu nasıl alıyor** | akış | Tohumluk Satış ve Dağıtım Yönergesi | 3 |
| 11 | **İşletmelerin yarısı, arazinin onda biri** | belge | Uzun Süreli Kira Yönergesi; arazi varlığı PDF'i | — |
| 12 | **Tohumdan başkasını da koruyor** | anlatı | Yerel Çeşit Listesi; At Yetiştirme Yönergesi | 3 |
| 13 | **Bıraktığı iş** | anlatı | 5254 (mülga 2001); 5433 md. 2-g; 5659; 3646 md. 5 | 5 |
| 14 | **Dünyada benzeri: iki model** | anlatı | OECD Tohum Şemaları listesi; Hindistan SFCI–NSC | 4 |
| — | **Kaynakça** | belge | §2.14 — bölümdür, unutulmaz | — |

*(Kaynakça 14'ten sonra gelir ve numara almaz; yukarıdaki 14 bölüm metnin
kendisidir. Toplam 15 başlık.)*

**Görsel ritim:** anlatı 1-3-12-13-14 · belge 2-4-5-6-11 · veri 7-8-9 ·
akış 10. Belge yoğunluğu ortada toplanıyor, veri çekirdeği 7-8-9'da ardışık,
akış tek ve 10'da. §8.4'ün "Evrak" diline uygun: dosyanın ortası belgedir.

**Her bölümde bir görsel olacak** — kullanıcı kuralı (8 Kasım 2026, Irak
dosyası): *"her bölümde bir görselin (ilgili olabilirse ne ala yoksa herhangi
bir görsel) olmasını unutma."* 14 bölüm = en az 14 görsel.

## Bölümlerin neden bu sırada olduğu

- **2, 3, 4 bilerek kronolojik değil.** Ödenek (1937) → haralar (Osmanlı) →
  mektup (1937) sırası, iki soyun aynı yıla düğümlendiğini gösteriyor:
  1937'de hem Zirai Kombinalar'ın tahsisatı ayrılıyor hem Atatürk mektubunu
  yazıyor. Haralar araya girince okur iki kolun da aynı noktada birleştiğini
  görüyor.
- **5 dosyanın merkezi.** 1949 cümlesi ile 2022 cümlesi yan yana basılacak.
- **9 eksen bölümü** ve veri çekirdeğinin sonunda duruyor; 7 ve 8 onu
  hazırlıyor (önce toprak, sonra ölçek, sonra tohum).
- **10 eksenin gündelik karşılığı**; eksen bölümünden hemen sonra geliyor ki
  okur "beşte biri" rakamından kendi tarlasına inebilsin.
- **11 eksen değil bölüm.** Kullanıcı kararı. Olanı anlatır, hesap sormaz.
- **13 diziyi kendi içine bağlıyor** (§8.9/5): Ziraat Bankası, Tarım Kredi,
  TAGEM ve AOÇ dördü birden bu bölümde.

## Dizi içi bağlar — bu dosyanın en yoğunu

| bağ | nerede | hangi sayı |
|---|---|---|
| Üç milyonluk tahsisat **Ziraat Bankası**'nda hususî hesapta | bölüm 2 | Sayı 02 |
| **TMO**, Zirai Donatım, SEK ile aynı ekli cetvel tablosu | bölüm 6 | Sayı 01, rotasyon 15 ve 20 |
| **Tarım Kredi Kooperatifleri** ve **Pankobirlik** adıyla dağıtım kanalı | bölüm 10 | Sayı 03, rotasyon 19 |
| Araştırma enstitüleri 3646'nın dışında — **TAGEM** | bölüm 13 | Sayı 04 |
| 5254: tohumluk **Ziraat Bankası eliyle**, Tarım Kredi de anılıyor | bölüm 13 | Sayı 02, Sayı 03 |
| **Devlet Üretme Çiftlikleri** rotasyonda ayrı kapanmış kurum | bölüm 5, 13 | rotasyon 18 |

> **ROTASYON UYARISI.** §8.13'ün 18. sırası **Devlet Üretme Çiftlikleri**
> (kapanmış kurum). Bu dosya 5433'ü ve DÜÇ'ü kullanacak ama **tüketmeyecek**:
> DÜÇ'ün kendi iç tarihi (1950–1984 arası işletme sayısı, makineleşme,
> Marshall yardımı dönemi) burada açılmıyor, 18. sayıya bırakılıyor. Bu
> dosyada DÜÇ yalnız TİGEM'in soyu olarak geçiyor.

## Tur 4'e açık kalanlar

1. **Dünyada benzeri (bölüm 14).** Aranacak aday: Hindistan'ın
   **State Farms Corporation of India** ve **National Seeds Corporation**
   (2014'te birleştiler) — devletin çiftlik işletip sertifikalı tohum ürettiği
   en yakın örnek. Fas SONACOS, Mısır ve Pakistan'ın eyalet tohum kurumları
   da bakılacak. DSİ dosyasının dersi: **ilk arama boş dönerse soru yanlış
   sorulmuştur** (§8.14 / DSİ tur 13).
2. **5433'ü ne mülga etti.** 3646 (1990) ona "mülga" diyor; mülga eden belge
   henüz bulunamadı. 1984 tarihli ilk Ana Statü ile birlikte aranacak.
3. **2023–2025 rakamları.** Elimizdeki sektör raporu 2022. Daha yeni bir
   sektör raporu ya da faaliyet raporu aranacak; bulunamazsa seri 2022'de
   biter ve metin bunu tarihle söyler.
4. **Hara arazisinin 3–4 milyon dekardan 450 bin dekara düşmesi** kurumun
   kendi beyanı; bağımsız karşılığı aranacak, bulunamazsa beyan olarak
   yazılır.
5. **Damızlık tarafının rakamları** — hayvan varlığı, sperma üretimi.
   Bölüm 1 ve 12 için gerekli.

---

## KULLANICI KURALI — 10 Kasım 2026, bölüm 2

Bölüm 2'nin başlığı ve gövdesi **"para" kelimesini kullanmayacak.** Belgenin
kendi sözcükleri var ve daha doğru: **tahsisat, ödenek, fasıl, kredi hesabı,
sermaye.** Başlık bu yüzden "Önce ödenek, sonra kanun" oldu. Tur 8'de
`dogrula_metin.py`'ye bir avcı eklenecek: bölüm 2 gövdesinde "para" kökü
geçerse çıkış kodu 1.


---

# Tur 4 — VERİ KATMANI KİLİTLENDİ

`cikarim.json` → `build_data.py` → `data.json`. **On üç blok, dokuz doğrulama,
dokuzu da geçti.** Veri sayfası artık elle düzenlenmez.

```
data.json yazıldı · 9 doğrulamanın 9'u geçti
  arazi payı            %0.93
  tohum payı (2022)     %19.9
  pay serisi            [90.0, 59.0, 23.5, 22.1, 18.7, 19.9]
  Ceylanpınar           %45.3 (toplam) · %49.9 (17 işletme)
  kiraya verilen arazi  %9.07 · işletme %50.0
```

## Dokuz doğrulama

| # | ne sınıyor |
|---|---|
| 1 | Her blok `_kapsam` ve `_kaynak_niteligi` taşıyor (§2.2) |
| 2 | Arazi tablosunun **üç** toplamı da satırlardan yeniden hesaplanıyor |
| 3 | Kurumun kendi yazdığı %90,93 / %9,07 oranı yeniden hesaplanıyor |
| 4 | Tohum tablosunda ülke toplamı = buğday + arpa, **her yıl için** |
| 5 | Raporun yazdığı pay yüzdeleri satırlardan yeniden hesaplanıyor |
| 6 | DAĞITIM ve SATIŞ serileri ayrı `_olcu` etiketi taşıyor |
| 7 | Kronoloji artan (hem kuruluş silsilesi hem görev cümlesi) |
| 8 | Sermaye serisi artan ve **hepsi 2005 sonrası** — eski para karışmıyor |
| 9 | Eksen cümlesi hâlâ yazılabiliyor mu: arazi payı <%1, tohum payı %15–25 |

Dokuzuncu doğrulama dizide yeni. Eksen bir cümledir ve iki sayıya dayanır;
o sayılar aralığın dışına çıkarsa cümle yalan olur. Betik bunu üretim
anında sınıyor, metin yazılırken değil.

## Arazi varlığı betikle çıkarıldı — ve tur 2'nin rakamı eksik kapsamdı

`cikar_arazi.py` PDF'ten işletme işletme 17 satırı okuyor. Üç sütun toplamı
da PDF'in kendi toplam satırını **birebir** veriyor: 3.273.792,46 da ·
tarla 1.756.580 · sulanan 940.568.

**Kapsam ayrımı netleşti.** PDF'in başlığı kapsamı söylüyor: *"TİGEM'İN
FAALİYETTE OLDUĞU 17 İŞLETMENİN ARAZİ VARLIĞI"*. Altındaki üç satır ayrı
kapsamdır:

| | dekar |
|---|---:|
| 17 işletme (Genel Müdürlük hariç) | 3.273.792,46 |
| Genel Müdürlük yerleşkesi | 1.771,22 |
| **PDF'in toplam satırı** | **3.275.563,68** |
| uzun süreli kiraya verilen | 238.203,00 |
| iştirak şeklinde | 88.688,00 |
| **TİGEM TOPLAM ARAZİ VARLIĞI** | **3.602.454,68** |

Tur 2 **3.273.792**'yi "toplam arazi" diye kaydetmişti; o rakam Genel
Müdürlük yerleşkesini ve kiraya verilenleri dışarıda bırakıyor. İkisi de
doğru, kapsamları farklı. Eksen cümlesinin paydası bundan böyle **toplam**:
3.602.454,68 da = 3.602,455 km² → Türkiye tarım arazisinin **%0,93'ü**.
Hâlâ yüzde birin altında, cümle ayakta.

PDF kendi oranını da yazıyor — %90,93 kullanımda, %9,07 kiraya verilmiş —
ve betik ikisini de satırlardan yeniden hesaplayıp PDF'in yazdığıyla
karşılaştırıyor. Tutuyor.

## BÖLÜM 11'İN BULGUSU TERSİNE DÖNDÜ

Tur 2 "**işletmelerin yarısı kirada**" demişti ve bunu çarpıcı bulmuştu.
Arazi rakamı gelince resim değişti:

> İşletmelerin **yarısı** kiraya verilmiş ama bu işletmeler TİGEM
> arazisinin **onda birinden azını** (%9,07) tutuyor. Kiraya verilenler
> küçük işletmeler.

Bu hem daha doğru hem kullanıcının istediği tona daha uygun: *"maliyet
hesabı dosyası yapmıyoruz, kurumu tanıtıyoruz."* Bölümün adı da buna göre
değişti: **"İşletmelerin yarısı, arazinin onda biri"**.

## KURULUŞ TARİHİ DÜZELDİ — 1984 DEĞİL, 28 EKİM 1983

Kurumun kendi sayfası ve Mart 2024 sunumu "1984'te kuruldu" diyor. Birincil
belge başka söylüyor.

**Resmî Gazete 28 Ekim 1983, sayı 18205 Mükerrer.** O nüsha bütün KİT'lerin
kuruluş kararnamelerini birden yayımlıyor. Fihristte sırayla:

| KHK | kurum | sayfa |
|---:|---|---:|
| 94 | Türkiye Kömür İşletmeleri | 1 |
| **95** | **Tarım İşletmeleri Genel Müdürlüğü** | **6** |
| 96 | Türkiye Taşkömürü Kurumu | 10 |
| **97** | **Türkiye Zirai Donatım Kurumu** | 15 |
| **107** | **T.C. Ziraat Bankası** | 52 |
| **113** | **Toprak Mahsulleri Ofisi** | 94 |

**95 sayılı KHK, madde 2:** *"Bu Kanun Hükmünde Kararname ile Tarım
İşletmeleri Genel Müdürlüğü (TİGEM) adında, tüzel kişiliğe sahip,
faaliyetlerinde özerk ve sorumluluğu sermayesiyle sınırlı bir **Kamu
İktisadi Kuruluşu kurulmuştur**."* Merkez Ankara, sermaye 30 milyar TL,
Bakanlar Kurulu kararı 10/10/1983.

1984'te olan şey kuruluş değil: KİT çerçevesi 60 sayılı KHK'den **233 sayılı
KHK'ye** geçti ve TİGEM 18 Haziran 1984 tarihli 18435 Mükerrer sayılı
nüshada, "TARIM, ORMAN VE KÖYİŞLERİ BAKANLIĞI" başlığı altında **Kamu
İktisadi Kuruluşu** olarak ekli cetvele yazıldı. 1994'te de 4046'nın 35.
maddesiyle İDT bölümüne geçti.

Üç tarih, üç ayrı şey. Metin üçünü de doğru adlandıracak.

> **DİZİ İÇİ BAĞ — dizinin en güçlüsü.** Sayı 01 (TMO), Sayı 02 (Ziraat
> Bankası) ve bu dosya **aynı gün, aynı Resmî Gazete nüshasında** yeniden
> kuruldu. Rotasyonun 15. sırasındaki Zirai Donatım Kurumu da iki numara
> sonra. 28 Ekim 1983, sayı 18205 Mükerrer.

## GÖREV CÜMLESİ ÜÇ BELGEDE AYNI

Tur 3 iki belge bulmuştu; 95 sayılı KHK üçüncüsünü verdi ve halka kapandı.

| yıl | belge | cümle |
|---|---|---|
| 1949 | 5433 md. 1 | "…**iyi tohumluk, damızlık ve fidan** ihtiyacını sağlamak, tarım alanında çiftçiye örneklik ve öğreticilik etmek üzere" |
| 1983 | 95 sayılı KHK md. 3/1 | "…yetiştirdiği **damızlık hayvan, tohum, fidan, fide** ve benzerleriyle ürettiği **spermaları yetiştiricilere intikal ettirmek**" |
| 2022 | Ana Statü md. 5/1-a | "Ürettiği **tohumluk, fidan, fide** ve benzeri ürünler ile yetiştirdiği **damızlık hayvanlar ve spermalarını üreticilere intikal ettirmek**" |

1983 ile 2022 cümleleri neredeyse kelimesi kelimesine aynı; tek fark
"yetiştiricilere" → "üreticilere". **Yetmiş üç yıl, üç kurum adı, bir
cümle.** Bölüm 5'in tamamı bu.

## Damızlık tarafı geldi

Mart 2024'te yayımlanan kurum sunumu (Erzurum Ticaret Borsası üzerinden
bulundu; kurumun kendi sitesinde yok) güncel rakamları veriyor:

| | 2002 | 2023 | kat |
|---|---:|---:|---:|
| damızlık sığır varlığı | 17.000 baş | 27.000 baş | 1,6 |
| damızlık koyun varlığı | 71.000 baş | 284.000 baş | 4,0 |

| sperma satışı (doz) | 2018 | 2020 | 2021 | 2022 | 2023 |
|---|---:|---:|---:|---:|---:|
| | 460.000 | 658.000 | 874.000 | 945.000 | **1.019.000** |

Boğa Sperması Üretim Merkezi Malatya/Sultansuyu'nda **2012**'de açılmış;
satış beş yılda **2,22 kat** artmış. Eksenin ikinci ayağı bu: kurum yalnız
tohum değil, **damızlık ve sperma** da üretiyor — ikisi de girdi.

Safkan Arap Atı üç işletmede, **1.549 baş**, yılda ortalama **260 yarış
tayı**. Sunumun kendi ifadesi soyu da söylüyor: *"Çiftlikat-ı Hümayun adı
altında Osmanlının kuruluşundan beri devam eden atçılık faaliyetleri."*
Bölüm 3 ve bölüm 12 bu ifadeyi kullanacak.

Ayrıca: 10 işletmede **10 ırk koyun — beşi yerli, beşi TİGEM'in kendi ıslah
çalışmasıyla elde edilmiş melez**; Ceylanpınar'da 2013'ten beri **1.000 ana
baş Halep ırkı keçi**; **5.000 kovan** arıcılık; **303 TİGEM bayisi**
(2003–2023 arasında kurulmuş).

## ÖLÇÜ ÇAKIŞMASI YAKALANDI — "dağıtım" ile "satış" aynı şey değil

Sektör raporu 2022'de TİGEM buğday tohumu **dağıtımını** 104.319 ton
gösteriyor. Stratejik plan aynı yıl buğday tohumu **satışını** 79.561 ton
gösteriyor. Fark 24.758 ton ve sebebi raporun kendi dipnotunda: TİGEM'in
dağıtım satırı **kurumun kendi ekilişlerini de içeriyor**.

İki seri aynı grafikte gösterilemez. `build_data.py`'nin 6. doğrulaması
bunu zorunlu kılıyor: her iki blok da `_olcu` etiketi taşıyor
(`dagitim` / `satis`) ve ikisi aynı olamaz. Tur 5'te grafik kurarken bu
etiket okunacak.

## BÖLÜM 14 TAMAMLANDI — iki model

Soru §8.9/4'ün sorusu: *aynı sorun başka yerde nasıl çözüldü?* Cevap tek
değil, iki:

**1. Devlet kendi çiftliğinde üretir.** Hindistan'ın **State Farms
Corporation of India**'sı tam TİGEM'in ikizi: devletin büyük, makineli
çiftliklerini sertifikalı tohum üretmek için işletiyordu. Rajasthan,
Haryana ve Karnataka'da **beş Merkezî Devlet Çiftliği, 21.908 hektar**.
Hindistan bu yapıyı 2013'te **National Seeds Corporation** (kuruluş 1963,
yılda ~150.000 ton tohum) bünyesine kattı; gerekçe, SFCI'nin arazisiyle
NSC'nin dağıtım ağını birleştirmekti.

Karşılaştırma kendiliğinden çıkıyor: SFCI'nin 21.908 hektarına karşılık
TİGEM'in **360.245 hektarı** — on altı katı. Ve Hindistan iki kurumu
birleştirmek zorunda kaldı; **TİGEM 1983'ten beri zaten ikisi birden.**

**2. Devlet üretmez, belgeler.** **OECD Tohum Şemaları**'na altmıştan fazla
ülke katılıyor ve listede Türkiye de var — Hindistan, Mısır, Fas, Rusya,
İran ve Amerika Birleşik Devletleri ile aynı listede. Bu modelde devletin
işi tohum üretmek değil, üretilenin belgesini vermek.

Türkiye ikisinde birden. Bölüm bunu söyleyecek.

> **SAYI UYARISI.** OECD listesinden ayıklanan ülke sayısı 64; OECD'nin
> kendi sayfası 62, broşürü 64 diyor. Metinde kesin sayı yazılmayacak,
> "altmıştan fazla" denecek.

## Tur 4'te eklenen kaynaklar

| dosya | ne |
|---|---|
| `rg_18205_khk95_tigem_kurulus.pdf` | **Kuruluş belgesi.** RG 28/10/1983 · 18205 Mükerrer; künye, KHK/95 tam metni, fihrist. 160 sayfalık nüshadan 7 sayfa alındı |
| `rg_18435_khk233_tigem.pdf` | RG 18/6/1984 · 18435 Mükerrer; TİGEM'in ekli cetveldeki satırı. 256 sayfadan 3 sayfa |
| `tigem_stratejik_plan.pdf` | **2024–2028 Stratejik Plan**, 82 sayfa; arazi, personel, satış ve hedef tabloları |
| `tigem_sunum_mart_2024.pdf` | Mart 2024 kurum sunumu; damızlık ve bayi rakamları |
| `oecd_tohum_semalari_ulkeler.pdf` | OECD Tohum Şemaları katılımcı ülke listesi |

## Tur 5'e açık kalanlar

1. **Stratejik Plan Tablo 12 ile arazi varlığı PDF'i aynı şeyi söylemiyor.**
   Plan genel toplamı 3.638.482 da, PDF 3.602.454,68 da; tarla rakamları da
   farklı (2.293.944 ↔ 1.756.580). İki ayrı tarih ve muhtemelen iki ayrı
   tasnif. **Veri katmanı PDF'i esas aldı**; plan çapraz okuma olarak durur.
   Metinde tek rakam kullanılacak ve tarihi yazılacak.
2. **Sulanan arazi iki rakam veriyor:** PDF 940.568 da (17 işletme),
   Stratejik Plan Tablo 13 ise 994.798 da (2023). Biri "sulanan", öteki
   "sulu tarım arazi varlığı" olabilir. Tur 5'te ayrım yazılmadan grafik
   kurulmayacak.
3. **Hara arazisinin 3–4 milyon dekardan 450 bin dekara düşmesi** hâlâ
   kurumun kendi beyanı; bağımsız karşılık bulunamadı.
4. **Hindistan rakamları İKİNCİL.** SFCI'nin 21.908 hektarı basın yoluyla
   aktarılmış bir hükûmet rakamı; `eparlib.sansad.in` ve `pib.gov.in`
   doğrudan açılamadı (biri zaman aşımı, öteki yanlış duyuru numarası).
   Metinde "Hindistan hükûmetinin bildirdiği" diye yazılacak.

---

# Tur 5 — GRAFİKLER KİLİTLENDİ

**On üç grafik, 42 `@yol`, on bir kural — on biri de geçti.** Sayılar
grafik dosyasında yazılı değil; hepsi `data.json`'dan okunuyor.

```
grafikler kilitlendi · 13 grafik · 42 @yol çözüldü · 11 kuralın 11'i geçti
  cizgi 3 · ikili_cubuk 1 · islem_akisi 1 · kartlar 3 · kunye 1
  siralama 3 · zaman_cizelgesi 1
```

| grafik | tür | bölüm |
|---|---|---|
| `kunye_tigem` | kunye | 1 |
| `fevkalade_tahsisat_1937` | siralama | 2 |
| `silsile` | zaman_cizelgesi | 6 |
| `isletme_arazileri` | siralama | 7 |
| `arazi_kullanimi` | siralama | 8 |
| `tohum_dagitimi` | cizgi | 9 |
| `tigem_payi` | cizgi | 9 |
| `tohum_yolu` | islem_akisi | 10 |
| `dagitim_kanallari` | kartlar | 10 |
| `kira_asimetrisi` | ikili_cubuk | 11 |
| `sperma_satisi` | cizgi | 12 |
| `korunanlar` | kartlar | 12 |
| `iki_model` | kartlar | 14 |

Bölüm 3, 4, 5 ve 13 grafiksiz. Dördü de belge ve anlatı bölümü; sayı
göstermek için grafik kurmak, §8.12'nin tersi olurdu.

## YENİ KURAL: siralama aralığı 40 katı aşamaz

Irak dosyası tur 9'da `ikili_cubuk`'un satır satır oranladığı yakalanmıştı.
Bu turda **`siralama`'nın tersi** yakalandı: o bütün grafiği birden oranlıyor
ve aralık açıldıkça en küçük çubuk yok oluyor.

1937 bütçe cetveli dokuz fasıl taşıyor. En büyüğü 3.000.000 lira, en küçüğü
**3.000 lira** — **bin kat.** 360 pikselde en küçük çubuk yarım pikselin
altına iner; okur onu çizim hatası sanar, bulgu değil.

Çözüm küçükleri düşürmek değil — düşürmek yekûnu bozar ve 4.512.636'lık
basılı toplam tutmaz. **En küçük dört fasıl tek satırda toplandı.** Aralık
22,6 kata indi, yekûn korundu, `build_data.py` gruplamanın toplamını basılı
yekûna karşı sınıyor.

`dogrula_grafik.py`'nin **11'inci kuralı** bunu kalıcı hâle getirdi: bir
`siralama`'da en büyük/en küçük oranı 40'ı aşarsa üretim durur.

## Kurallar gerçekten ateş ediyor mu — ölçüldü

Ateş etmeyen kural kural değildir. Beş kural bilerek bozuldu ve beşi de
yakaladı; dosya sonra geri alındı:

| bozulan | yakalandı mı |
|---|---|
| siralama aralığı 1000 kata çıkarıldı | ✓ "aralığı 1000 kat — en küçük çubuk görünmez" |
| ikili_cubuk satırı 34 etti (100 yerine) | ✓ "ikili_cubuk SATIR SATIR oranlar" |
| cizgi'nin x alanı kayıtlarda yok | ✓ "kayıtlarda 'yok_boyle_alan' alanı yok" |
| dağıtım grafiğinin notundan ölçü adı silindi | ✓ "notu ölçüyü söylemiyor" |
| `@yol` kırıldı | ✓ "data.json'da yok" |

## Ölçü çakışması kurala bağlandı

Tur 4 dağıtım (104.319 ton) ile satışın (79.561 ton) aynı yıl farklı rakam
verdiğini bulmuştu. Yedinci kural bunu grafik tarafında kapatıyor: **dağıtım
serisi kullanan bir grafiğin notu "dağıtım" demek zorunda, satış serisi
kullananınki "satış".** Okur hangi ölçüye baktığını grafiğin altında görüyor.

## `islem_akisi` nihayet kullanıldı

§8.5 bu türü 2024'te tanımlamıştı, Ziraat dosyasında **kaynak olmadığı için**
kullanılmamıştı (§8.12). Burada kaynak var: Tohumluk Satış ve Dağıtım
Yönergesi'nin dokuzuncu maddesi adımları, aktörleri **ve süreleri** yazıyor.

Altı adım: ön talep → ön tahsis → **5 iş günü** içinde %10 peşinatla kesin
tahsis → **20 takvim günü** içinde teslim → ödeme → sevkiyat. Ödeme adımı
`secenekler` alanını kullanıyor (nakit *ya da* teminat mektubu), çünkü bu bir
seçim; tek satıra sıkışsa okur iki zorunlu adım sanardı.

Süresi belgelenmemiş adımlarda `sure` alanı **yok** — boş bırakılmadı,
silindi. Dokuzuncu kural boş süreyi hata sayıyor: uydurulmuş bir süre, okurun
kendi işini ona göre planlaması demek.

## `kartlar` üç kez kullanıldı — ve `rol` yazılmadı

§8'de kayıtlı sınır: `kartlar` çizicisi kart başlığı için `tema.murekkep`
kullanıyor, `vurgu` oraya hiç ulaşmıyor. Onuncu kural kart tanımında `rol`
görürse hata veriyor — sessizce düşen bir alan yazılmasın diye.

Üç kart grafiği: dağıtım kanalları (dört kapı), korunanlar (Ata tohumu,
Safkan Arap Atı, Ankara Tiftik Keçisi, Kangal ve Asya Ceylanı), iki model
(Türkiye, Hindistan, OECD).

## Kurulmayan iki grafik — ve neden

| kurulmadı | sebep |
|---|---|
| Dünya arazi sıralaması | İki çubuk grafik değildir. TİGEM 360.245 ha, SFCI 21.908 ha karşılaştırması `iki_model` kartlarının rakam alanına taşındı |
| Sermaye serisi | Üç nokta, biri yıl içi karar. Ayrıca kullanıcı kararı gereği bu dosya malî tartışmaya girmiyor; künyede satır olarak kalıyor |

## Tur 5'te veri katmanına eklenenler

- `butce_1937` — 3130 sayılı Kanunun ikinci cetveli, dokuz fasıl. Satırlar
  basılı yekûnu (4.512.636) **birebir** veriyor; onuncu doğrulama bunu sınıyor
  ve ayrıca Ziraî kombinalar faslının listenin en büyüğü olduğunu doğruluyor —
  olmasaydı bölüm 2'nin cümlesi yazılamazdı.
- `turetilmis.dagitim_kayitlari`, `turetilmis.sperma_kayitlari` — `cizgi`
  çizicisi noktaları **kayıt dizisinde** arıyor, paralel dizilerden okumuyor.
- `turetilmis.isletme_siralamasi` — ilk sekiz işletme + kalan dokuzun toplamı.
- `turetilmis.arazi_kullanimi` — beş kalem.
- `turetilmis.kira_asimetrisi` — iki satır, her biri %100.
- `turetilmis.tahsisat_1937_gruplu` — grafiğe giren altı satır.

**Kaynağın yuvarlama farkı kaydedildi, yutulmadı.** Arazi tablosunun alt
sütunları altı işletme satırında birer dekarın altında sapıyor; toplam fark
3,27 milyon dekarda **1,67 dekar**. Doğrulama 2 dekarı aşarsa duruyor, çünkü
o zaman yuvarlama değil hata demektir. Grafiğin notu da farkı söylüyor.

## Kaynaktaki iki aksaklık

1. **Kaynak tabloda bir işletme adı yanlış basılmış:** "Kazım Karabekirekir".
   Grafikte doğru yazılıyor, notta kaynağın yazdığı hâli belirtiliyor.
2. **Sperma serisinde 2019 yok.** Kurumun yayımladığı dizide o yıl bulunmuyor;
   uydurulmadı, grafiğin notu eksikliği söylüyor.

## Tur 6'ya açık kalanlar

1. Tasarım künyesi: kurum **beşinci küme** mi, yoksa var olan bir kümeye mi
   giriyor? TMO kırmızı, Ziraat yeşil, Tarım Kredi toprak, DSİ su-toprak.
   TİGEM bunların hiçbiri değil — devletin bizzat üretici olması.
2. Kapak: tipografik, kuruluş belgesinden. Aday belge **95 sayılı KHK'nin
   Resmî Gazete künyesi** (28 Ekim 1983, sayı 18205 Mükerrer).
3. Kontrast ve renk körlüğü denetimi `_ortak/kontrast.py` ile.

---

# Tur 6 — TASARIM KÜNYESİ KİLİTLENDİ

**Yirmi kontrast yeniden ölçüldü, on kuralın onu da geçti.** Ve bu turda
dizinin **dokuzuncu kümesi** kuruldu.

```
tasarım kilitlendi · 20 kontrast yeniden ölçüldü, hepsi tuttu · 10 kuralın 10'u geçti
  küme              Üretim (dizinin 9'uncusu)
  kağıt vurgusu     #1F5626  kağıt 6.96 · yüzey 7.72
  kapak vurgusu     #4CC756  kapak 8.26
  şerit ayrışması   1.12 (çökme deseni 1,05)
  renk körlüğü      ΔE normal 19,35 · deuteranopi 3,62 (mevcut sekizin tabanı 1,95)
```

## Dizinin dokuzuncu kümesi: **Üretim**

Mevcut sekizin hiçbiri tutmadı:

| küme | ne demek | kimde |
|---|---|---|
| Kamu gücü | piyasaya fiyatla müdahale eden KİT | TMO |
| Finans | kredi açan | Ziraat Bankası |
| Üretici örgütü | ortaklık kuran | Tarım Kredi |
| Piyasa altyapısı | borsa, lisanslı depoculuk | — |
| Bilgi | araştırma | TAGEM |
| Su-toprak | altyapı | DSİ |
| Meslek | oda | — |
| Hayalet | kapanmış kurum | — |

TİGEM bunların hiçbiri değil: **devletin bizzat üretici olması.**

**Küme tek seferlik değil** — gerekçenin kilit noktası bu. Rotasyonun
7. sırasındaki **Türkşeker** ve 8. sırasındaki **Et ve Süt Kurumu** da aynı
kümeye girer; üçü de devletin kendi tesisinde üretim yapan KİT'i. Tek bir
dosya için küme açılmıyor, üç dosyalık bir aile için açılıyor.

Renk: **#1F5626** kağıt, **#4CC756** kapak. Ton 125° — paletteki kullanılmayan
tek geniş aralık; Finans (160°, mavi-yeşil) ile Meslek (52°, sarı-zeytin)
iki yanında duruyor. Kümenin maddesi tarla.

## RENK KÖRLÜĞÜ ÖLÇÜLDÜ — ve bulgu dizinin tamamını ilgilendiriyor

Irak dosyası renk körlüğü benzetimini (Viénot-Mollon) eklemişti ama orada
iki şerit renginin ayrımına bakılmıştı. Burada ilk kez **kümelerin
birbirinden ayrımına** uygulandı, çünkü yeni bir rengin eskilerden ayrılıp
ayrılmadığı tahminle bilinemez.

**Önce bir ölçü hatası düzeltildi.** WCAG kontrast oranı **hue ayrımını
ölçmez**. İki renk aynı parlaklıkta ama bambaşka tonda olabilir; kontrast
oranı 1,0 çıkar, göz ikisini rahat ayırır. Mevcut kümelerde zaten böyle:
Üretici örgütü ile Hayalet arasındaki kontrast oranı **1,01**. Doğru ölçü
CIE76 ΔE (Lab).

Ölçüm:

| | ΔE normal | ΔE deuteranopi |
|---|---:|---:|
| **Mevcut sekizin kendi içindeki en küçüğü** | 17,4 | **1,95** |
| Dokuzuncu kümenin en yakın kümeye mesafesi | **19,35** | **3,62** |

Yani: **dizi kurulduğundan beri kümeler renk körü okur için ayrışmıyor.**
Piyasa altyapısı ile Bilgi deuteranopi altında neredeyse aynı renk. Dokuzuncu
küme bu tabanın üstünde — ama tabanın kendisi çok alçak.

**Takas denendi ve reddedildi.** Deuteranopi ayrımını 10'un üstüne çıkaran
kapak vurguları bulundu (ör. `#47CC8A`, ΔE deut 9,9) ama hepsi normal
görüşteki ayrımı 45,2'den 23,7'ye ve altına düşürüyor — yani Finans'ın
nanesine yaklaşıyor. Okurların büyük çoğunluğu normal görüşlü; takas kabul
edilmedi.

**Karar: renk tek başına hiçbir yerde anlam taşımaz.** Bu `tasarim.json`'a
kural olarak, `_ortak/kontrast.py`'ye yorum olarak yazıldı.

> **KULLANICI KARARI BEKLİYOR.** Kalıcı çözüm renk değil: arşiv ve ana sayfa
> şeridi kümenin adını **yazıyla** da göstermeli. Bugün göstermiyor —
> `diger_dosyalar.dart` yalnız `editionLabel` basıyor ("Kurum Dosyası · 06").
> Bu ORTAK bir bileşen; değişiklik yayındaki beş dosyayı birden etkiler.

## Tahmin edilen sayı artık imkânsız

DSİ dosyasında dört şerit kontrastı betikten okunmayıp **tahmin edilmiş** ve
dördü de yanlış çıkmıştı (§8.14.3'ün "sessiz mayın"ı). Bu turda iki şey
yapıldı:

1. **`tasarim.json` elle yazılmadı, `_raw/kontrast.py`'den ÜRETİLDİ.**
2. **`dogrula_tasarim.py` her sayıyı yeniden ölçüyor** ve birebir tutmazsa
   üretim duruyor. Yirmi kontrast değerinin yirmisi de sınanıyor.

## Kurallar ateş ediyor mu — ölçüldü

| bozulan | yakalandı mı |
|---|---|
| şerit kontrastı 7,72 yerine 7,5 yazıldı | ✓ "yazılı 7.5, ölçülen 7.7" |
| vurgu AA altına düşürüldü | ✓ "yazılı 2.41, ölçülen 2.1" |
| `cizgi` 3:1'in üstüne çıkarıldı | ✓ "cizgiVurgu'dan ayrı durmuyor" |
| küme rengi Su-toprak'ınkiyle aynı yapıldı | ✓ "'Su-toprak' kümesiyle aynı" |
| tez cümlesinden payda silindi | ✓ "paydayı söylemiyor" |
| `_yasak` listesi boşaltıldı | ✓ "kapakta fotoğrafı yasaklamıyor" |

## Şeridin tek gerçek riski bu dosyada

Kümenin rengi yeşil ve **uygulamanın yapısal yeşili de yeşil** (#2F4B2E).
İkisi arasındaki oran **1,12**. Hollanda'da çöken desen 1,05, Avustralya'nın
ilk hâli 1,03 idi — bu onların üstünde ama **dizinin en dar aralığı**. Kart
sayfanın kendi renginden parlaklıkla değil, krem zemindeki 7,72'lik
kontrastıyla ve şerit çerçevesiyle ayrışıyor. Tur 9'da önizlemede gözle
doğrulanacak.

## Tanıtım cümlesi

> **TR:** Türkiye tarım arazisinin yüzde birinden azıyla, ülkede dağıtılan
> sertifikalı hububat tohumunun beşte birini veriyor: ürettiği gıda değil,
> girdi.

İki sayı da doğrulanmış ve ikisi de `build_data.py`'nin dokuzuncu
doğrulamasından geçiyor. **Cümle paydayı kendi içinde söylüyor** —
"dağıtılan". Dokuzuncu kural bunu da sınıyor: kelime silinirse üretim durur.

Cümlenin **demediği** şey de kayıtlı: "Türkiye'nin tohumunu TİGEM üretir"
demiyor. Pay beşte bir ve düşüyor.

## Kapak

Tipografik, kuruluş belgesinden. Fotoğraf kapak yine reddedildi (§8.8).

```
KURUM DOSYASI · 06 · ÜRETİM
TARIM İŞLETMELERİ
95 sayılı Kanun Hükmünde Kararname · Resmî Gazete 28 Ekim 1983 · 18205 Mükerrer
— Ana Statü · 2 Şubat 2022 · 31738
```

**Kapak bir düzeltme yapıyor:** kurumun kendi sayfası 1984 diyor, kapak
28 Ekim 1983 tarihli KHK/95'i gösteriyor.

## Bu dosyaya özel iki yasak

Dizinin genel yasaklarına (logo, arma, mühür, kapakta fotoğraf, stok "mutlu
çiftçi") iki tanesi eklendi:

- **Gün batımında altın başak tarlası.** Tarımın en yıpranmış stok karesi ve
  dosyanın anlattığı şey manzara değil, girdi.
- **Toprakta filizlenen yeşil fide makrosu.** "Büyüme" klişesi; kurumun
  ürettiği şey fide değil tohumluk, damızlık ve sperma.

## Tur 7'ye açık kalanlar

1. Yayın künyesi: on dört bölüm, on üç grafik eşlemesi, pencere 14 gün.
2. Görseller: her bölümde bir tane (kullanıcı kuralı). Atıfsız görsel
   yayımlanmaz; atıf görselin altında açıkta durur.
3. Hikâye slaytları: her slayt ayrı görsel, başlıklar vurucu ve doğrudan.

---

# Tur 7 — YAYIN KÜNYESİ VE GÖRSELLER

**On dört bölüm, on dört görsel, beş slayt, on kuralın onu da geçti.**

```
yayın künyesi kilitlendi · 14 bölüm · 13 grafik yerleşti · 14 görsel · 5 slayt · 10 kuralın 10'u geçti
```

Kapak **tipografik** — fotoğraf yok (§8.4, §8.8). DSİ'deki kararın aynısı:
dizinin görsel kimliği altıncı sayıda kırılırsa hiç kurulmamış olur.

## Kullanıcı kuralı koda çevrildi

*"Her bölümde bir görselin olmasını unutma."* (3 Kasım 2026) Bu artık benim
dikkatime bırakılmış bir not değil: `dogrula_yayin.py`'nin üçüncü kuralı
görselsiz bölümü **hata sayıyor** ve dosya tohumlanamıyor.

Aynı şekilde yedinci kural — *"her bir slayt ayrı görsel taşısın, aynı görsel
her slaytda tekrarlanmasın"* — ve sekizinci kural: başlık 60 karakteri
aşamaz, soru işaretiyle bitemez (*"bilmece gibi başlık koyuyorsun"*).

**Sekiz kural bilerek bozuldu, sekizi de yakaladı:** silinen görsel, göreli
adres, boş atıf, tekrarlanan slayt görseli, 64 karaktere çıkan başlık,
bölümsüz kalan grafik, fotoğrafa çevrilen kapak, anahtar kelimeye eklenen
"tarım".

## Görsel eşlemesi

| # | bölüm | kare |
|---|---|---|
| 1 | Tohumun geldiği yer | traktörle çalışan harman makinesi |
| 2 | Önce ödenek, sonra kanun | Orman Çiftliği'nde çelik tekerlekli traktör, 1929 |
| 3 | Haralar: ordunun atı | **Karacabey'de padoklar ve doru atlar** |
| 4 | Atatürk'ün mektubu | **Atatürk harman yığınının önünde, 14 Temmuz 1929** |
| 5 | 1949'da yazılan cümle | Suşehri'nde hasat öncesi buğday başakları |
| 6 | Kuruluş 1983, çerçeve 1984 | Resmî Gazete sayfası, 20 Nisan 1946 |
| 7 | Toprak 1990'da tapuya geçti | **Ceylanpınar'da bir Asya ceylanı** |
| 8 | Türkiye'nin yüzde birinden azı | Harran Ovası'nda sulama kanalı, 2011 |
| 9 | Ülkenin tohumu: doksandan yirmiye | **Harran'da orakla biçen kadın, 15 Haziran 1988** |
| 10 | Çiftçi tohumu nasıl alıyor | Sivas'ta olgun buğday tarlası |
| 11 | İşletmelerin yarısı, arazinin onda biri | Harran'da sulanan pamuk, 2012 |
| 12 | Tohumdan başkasını da koruyor | Kangal çoban köpeği |
| 13 | Bıraktığı iş | **Atatürk Orman Çiftliği'nin panoraması, 1939** |
| 14 | Dünyada benzeri: iki model | Pencap'ta buğday başakları |

İki eşleşme tesadüf değil ve ikisi de doğrulandı:

- **7. bölümün ceylanı gerçekten Ceylanpınar'dan.** Commons açıklaması
  Kürtçe: *"Ceylanek ji Serêkaniya Rihayê"* — Urfa'nın Serêkaniyê'sinden bir
  ceylan. Serêkaniyê, Ceylanpınar'ın Kürtçe adı; "Rihayê" (Urfa) niteleyicisi
  onu sınırın öte yanındaki Suriye Serêkaniyê'sinden ayırıyor. Yani kare,
  TİGEM'in en büyük işletmesinin bulunduğu ilçeden ve ilçeye adını veren
  hayvandan.
- **3. bölümün karesi Karacabey işletmesinin kendisi** — TİGEM'in üç at
  işletmesinden biri, Osmanlı harasının doğrudan devamı. Duvardaki
  madalyonlardan biri işletmenin armasını taşıyor; bu **tasarımda arma
  üretmek değil**, karede tesadüfen bulunan bir tabela.

## İKİ KARE GÖZLE AÇILDI VE REDDEDİLDİ

Commons'ta **"Wheat and Vegetable Seeds"** adıyla duran iki kare tohum çuvalı
sanılmıştı. Açılıp bakıldığında **Pakistan'da USAID yardım dağıtımı** çıktı:
çuvallarda "NOT FOR SALE", adamların başında USAID şapkası, elde "VEGETABLE
SEEDS" paketleri. Bir Türk kurumunun dosyasına koymak hem yanıltıcı olurdu
hem de kurumun yaptığı işi — bedeli karşılığında tohumluk satmayı — yardım
dağıtımına benzetirdi. İkisi de silindi.

Irak dosyasının dersi doğrulandı: **başlık yalan söyleyebilir, kare söylemez.**
Kullanılan on dört karenin on dördü de açılıp bakıldı.

## Bulunamayanlar — ve ne yapıldığı

| aranan | sonuç |
|---|---|
| Türkiye'de sertifikalı tohum çuvalı ya da TİGEM bayisi | Commons'ta YOK. Bulunan iki aday USAID dağıtımıydı, reddedildi |
| Safkan Arap Atı yakın planı | Atın kendisi yok; 3. bölüm Karacabey'in padoklarını gösteriyor ve altyazı ne görüldüğünü söylüyor |
| TİGEM'i kuran Resmî Gazete nüshası (18205) | Taranmış görüntüsü Commons'ta yok. 6. bölüm 1946 tarihli başka bir nüshayı gösteriyor ve **altyazı farkı açıkça yazıyor**: "TİGEM'i kuran 95 sayılı kararname başka bir nüshada, 28 Ekim 1983 tarihli 18205 Mükerrer sayıda yayımlandı" |

**Boş bırakılan bölüm YOK.**

## Kullanılmayan üç kare

İndirildi, atfı tam, `_raw/gorseller`'de duruyor:

- `tigem_orman_ciftligi_1929c` — aynı günün üçüncü karesi; üçünü birden koymak
  aynı günü üç kez göstermek olurdu.
- `tigem_tiftik_kecisi` — 3. bölüme konacaktı, Karacabey karesi sonradan indi
  ve bölüm atı anlattığı için o geçti.
- `tigem_koyun_karapinar` — 1989'da koyun sağımı; 12. bölüme uygundu ama
  Kangal karesi o bölümün cümlesini daha iyi karşılıyor.

## PNG'ler JPEG'e çevrildi — yayından ÖNCE

Dört kare PNG olarak inmişti ve optimizasyon betiği PNG'e dokunmuyor
(§22.1: "format JPEG KALIR"). Dördü fotoğraf; PNG'de 3,4 MB tutuyorlardı,
JPEG q88'de **365 KB**. Dosya henüz yayında olmadığı için adres değişikliği
hiçbir şeyi kırmadı — yayından sonra olsa yapılmazdı.

Toplam sayfa görsel yükü: **5,6 MB → 3,3 MB.**

## Hikâye slaytları

Beş kanca, beşi de ayrı görsel, beşi de 60 karakterin altında:

| | başlık | karakter |
|---|---|---:|
| 1 | Üç milyon lira ayrıldı, kurum daha yoktu | 40 |
| 2 | İlk sermayesi Atatürk'ün çiftlikleriydi | 39 |
| 3 | Aynı görev cümlesi üç belgede: 1949, 1983, 2022 | 47 |
| 4 | 2002'de ülkenin tohumu oydu, bugün beşte biri | 45 |
| 5 | Tohumun yanında Kangal'ı ve ceylanı da koruyor | 46 |

## Commons hız sınırı — ve nasıl uyulduğu

`upload.wikimedia.org` bu ağa 429 verdi ve indirmelerin yarısı düştü.
**Tarayıcı taklidi yapılmadı** — hız sınırı aşılacak bir engel değil, uyulacak
bir kuraldır. Üç şey yapıldı:

1. İstekler ham dosya yerine **küçük resim uç noktasına** çevrildi (2400 px;
   zaten 1440'a indiriliyor).
2. `User-Agent` Wikimedia'nın politikasına uyduruldu: projenin **kendi genel
   adresi** yazıldı. Kullanıcının kişisel bilgisi hiçbir isteğe konulmadı.
3. Dosya istekleri arasına **20 saniye**, yeniden denemeler arasına 30-120
   saniye kondu.

On yedi karenin on yedisi de indi.

## Tur 8'e açık kalanlar

1. Metin (TR + EN). **Gövde en az 4.000 kelime** — tur 3'te kilitlendi.
2. `dogrula_metin.py`: §8.11'in meta cümle avcıları + **bölüm 2'de "para"
   kökü yasağı** (kullanıcı kuralı, 10 Kasım 2026) + uzunluk tabanı.
3. Başlıklar metin yazıldıktan sonra metinle birebir hale getirilecek.
