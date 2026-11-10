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
| **3130** sayılı Kanun | kabul 12.II.1937 | 19/11/1937 · 3538 | Zirai Kombinalar Kurumu'nun **parası** |
| **3308** sayılı Kanun | kabul 7.I.1938 | 13/1/1938 · 3807 | Devlet Ziraat İşletmeleri Kurumu; **Atatürk'ün bağışı sermaye oluyor** |
| **5254** sayılı Kanun | kabul 8.VII.1948 | 14/7/1948 · 6957 | Muhtaç çiftçiye ödünç tohumluk — 2001'de mülga |
| **5433** sayılı Kanun | kabul 7.VI.1949 | 13/6/1949 · 7231 | Devlet Üretme Çiftlikleri; **görev cümlesi** |
| **5659** sayılı Kanun | kabul 24.III.1950 | 1/4/1950 · 7472 | Atatürk Orman Çiftliği ayrı müdürlük oluyor |
| **3646** sayılı Kanun | kabul 16.V.1990 | 25/5/1990 · 20528 | Arazi TİGEM adına tapuya geçiyor |
| **233** sayılı KHK | 8.6.1984 | 18435 | TİGEM ekli cetvelde; dipnot 47 |
| **Ana Statü** · CB Kararı 5141 | 1.2.2022 | 2/2/2022 · 31738 | Bugünkü kurucu metin |

### 1. Paranın kanundan önce geldiği yer — 3130 (1937)

Zirai Kombinalar Kurumu'nu kuran bir kanun yok. **3130 sayılı Kanun bir ek
bütçe kanunu**: 1936 malî yılı muvazenei umumiyesine 4.512.636 liralık
fevkalade tahsisat koyuyor ve bunun **3.000.000 lirası** tek bir fasla,
Ziraat Vekâleti bütçesinde yeni açılan **858'inci fasıl, "Ziraî kombinalar
kurumu masrafları"** faslına gidiyor. Tek fasıl, o kanunun koyduğu bütün
fevkalade tahsisatın üçte ikisi.

Dördüncü madde parayı nereye koyduğunu da yazıyor: **Ziraat Bankasında
açtırılacak hususî bir kredi hesabına.** Ve şu cümleyi kuruyor —
*"Bu krediden yapılacak masraflar hususî bir kanun ile tayin olunur. Ancak
bu kanunun tanzim ve meriyete girmesine kadar İcra Vekilleri Heyeti kararile
tayin edilecek işler için sarfiyat yapılır."*

Yani kurumun parası, kurumun kanunundan on bir ay önce yatırılmış. §8.9/2'nin
("parayı nereden buldu") karşılığı bu. Ve para **Ziraat Bankası'nda** duruyor —
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

Kurumun ilk sermayesi para değil **toprak**. Kurumun sitesi bunu "Atatürk'ün
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
| 2 | **Önce para geldi, kanun sonra** | belge | 3130 md. 2 ve 4; fasıl 858 | 1, 2 |
| 3 | **Haralar: ordunun atı** | anlatı | kurumun `/Tarih` beyanı; 3646 md. 1-b | 1 |
| 4 | **Atatürk'ün mektubu** | belge | 3308 md. 1, 5, 6 | 1, 2 |
| 5 | **1949'da yazılan cümle** | belge | 5433 md. 1, 2; Ana Statü md. 5 | — |
| 6 | **İki soy tek çatı: 1984** | belge | 233 KHK ekli cetvel + dipnot 47 | — |
| 7 | **Toprak 1990'da tapuya geçti** | veri | 3646; arazi varlığı tablosu | 2 |
| 8 | **Türkiye'nin yüzde birinden azı** | veri | arazi 3.273.792 da; DB 386.400 km² | — |
| 9 | **Ülkenin tohumu: doksandan yirmiye** | veri | Tablo 9–10 serisi 2002–2022 | — |
| 10 | **Çiftçi tohumu nasıl alıyor** | akış | Tohumluk Satış ve Dağıtım Yönergesi | 3 |
| 11 | **Çiftliklerin yarısı kirada** | belge | Uzun Süreli Kira Yönergesi; Ana Statü 5/1-f,g | — |
| 12 | **Tohumdan başkasını da koruyor** | anlatı | Yerel Çeşit Listesi; At Yetiştirme Yönergesi | 3 |
| 13 | **Bıraktığı iş** | anlatı | 5254 (mülga 2001); 5433 md. 2-g; 5659; 3646 md. 5 | 5 |
| 14 | **Dünyada benzeri** | anlatı | **TUR 4'TE ARANACAK** | 4 |
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

- **2, 3, 4 bilerek kronolojik değil.** Para (1937) → haralar (Osmanlı) →
  mektup (1937) sırası, iki soyun aynı yıla düğümlendiğini gösteriyor:
  1937'de hem Zirai Kombinalar'ın parası yatırılıyor hem Atatürk mektubunu
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
| 3 milyon lira **Ziraat Bankası**'nda hususî hesapta | bölüm 2 | Sayı 02 |
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
