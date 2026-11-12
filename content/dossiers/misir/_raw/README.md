# Mısır dosyası — araştırma günlüğü

Ülke Dosyası sayı 06 · rol **Rakip** (§2.11) · pencere 28 gün.
Irak'tan sonraki sıra; takvimdeki "Yakında" satırı 2 Kasım 2026'dan beri
Mısır diyor.

```
kaynak API/CSV → _raw/*.json → data.json → grafikler.json (@yol)
               → charts jsonb → seed SQL → veritabanı
```

---

## Önce okundu: beş dosyanın bıraktığı ders

Bu dosya sıfırdan başlamıyor. Yazmadan önce Hollanda, Rusya, İspanya,
Avustralya ve Irak dosyalarının tamamı okundu — ikisinin araştırma günlüğü
yok (İspanya'nınki 4 Ekim 2026 iCloud kaybında gitti, Avustralya'da hiç
yazılmamış), onlar **canlı metinlerinden** okundu.

### Her dosyanın bir YAPISAL İMZASI var, konusu değil

| dosya | imza |
|---|---|
| Hollanda | kurum katmanı — ülkenin kendi istatistik kurumu (CBS) birincil kaynak |
| Rusya | ayna istatistik — ülke yayımlamıyor, alıcının defterinden okunuyor |
| İspanya | **"Aynı yağ, üç defter"** — tek ürün üç ayrı kayıtta sayılıp fark gösteriliyor (502 kelime, dosyanın en uzun bölümü) |
| Avustralya | su topraktan ayrılıp fiyatlanıyor; `akis` grafiği, "Megalitrenin fiyatı" |
| Irak | ayna istatistik + savaşın seriye yazdığı kırılma |

**Mısır'ın imzası bunlardan biri OLAMAZ.** Aşağıdaki ilk ölçüm hemen bir
"iki defter" bulgusu verdi — ve o İspanya'nın hamlesinin tekrarı olurdu.
Veri dosyada yazılacak (kural: ayna olduğu her tabloda yazar), ama dosyanın
imzası başka bir yerden gelmeli.

### Ölçülen hacim — bu dosyanın tutması gereken çıta

| dosya | bölüm | kelime | **bölüm ort.** |
|---|---:|---:|---:|
| Hollanda | 17 | 5.761 | 338 |
| İspanya | 23 | 5.858 | 254 |
| Rusya | 20 | 5.449 | 272 |
| Avustralya | 17 | 4.134 | 243 |

§2.14: İspanya'nın ilk taslağı 138 kelime/bölümle reddedildi. Teşhisi veren
ölçü kelime değil **veri/metin oranıydı** — 637 sayısal kalemin 635'i metne
girmişti, yani hiçbir şey seçilmemişti. Hedef: kalem başına 9-11 kelime.

### Bölüm türü dağılımı — okur zemin değiştirmeli (§2.8)

İspanya 10 `anlati` · 10 `veri` · 3 `belge`
Avustralya 7 `anlati` · 7 `veri` · 2 `belge` · 1 `akis`

---

## Tur 1 — ERİŞİM HARİTASI

*(12 Kasım 2026, `erisim_haritasi.py`. Durum kodu TEK BAŞINA yalan söylüyor:
kod + content-type + gövde birlikte okunuyor — §2.12.1 İspanya vakası.)*

### Açık

| kaynak | sınıf | ne veriyor |
|---|---|---|
| UN Comtrade preview | BAĞIMSIZ | Türkiye–Mısır ticareti, fasıl ayrıntısında · **iki taraf da raporluyor** |
| FAOSTAT toplu indirme | BAĞIMSIZ | üretim serileri — dizin listesi boş döndü ama **gerçek zip iniyor** |
| USDA FAS PSD toplu | BAĞIMSIZ | pazarlama yılı serileri (buğday ithalatı için kritik) |
| **Mısır Tarım Bakanlığı** `moa.gov.eg` | BİRİNCİL | gerçek gövde döndü — Irak'ta bu katman hiç yoktu |
| Nile Basin Initiative | BAĞIMSIZ | havza belgeleri |
| Suez Canal Authority | BİRİNCİL | kanal istatistikleri |
| FAO belgeleri (`fao.org/4/...pdf`) | BAĞIMSIZ | gerçek PDF |
| Resmî Gazete arşivi | BİRİNCİL | antlaşma nüshaları |
| TÜİK · TİM | BİRİNCİL | Türkiye yakası |

### Kapalı — tekrar denenmesin

| kaynak | sonuç |
|---|---|
| CAPMAS (Mısır İstatistik Kurumu) | 200 ama gövde **1.421 bayt** — JS kabuğu |
| Mısır Merkez Bankası istatistik | 200 ama gövde **269 bayt** — kabuk |
| Mısır Su Kaynakları Bakanlığı | **bağlantı sıfırlanıyor** (Errno 54) |
| FAO AQUASTAT ülke profili | 200, 80 KB — ama gövdede **"Egypt" geçmiyor**: JS kabuğu. Irak'ta da böyleydi |
| FAOSTAT REST API (`fenixservices`) | **521** — Hollanda'dan beri böyle, toplu indirme zorunlu |

### Şu an düşük — KAPALI DEĞİL, tekrar denenecek

| kaynak | sonuç |
|---|---|
| Dünya Bankası API | **502 Bad Gateway** (https), http'de zaman aşımı |

Bu ayrım Rusya dosyasından: **veri yayımlanmıyor** (yöntem sorunu) ile
**sunucuya erişilemiyor** (geçici) aynı şey değil. 502 sunucu tarafı; dosya
metninde "erişilemedi" bile denmez, yeniden denenir. Makro göstergeler
(tarım/GSYH payı, sulanan arazi oranı, kişi başı yenilenebilir su) bu
kaynaktan gelecekti; alternatif FAOSTAT toplu + USDA PSD.

**Mısır'ın Irak'tan farkı:** ülkenin kendi tarım bakanlığı açık. Yani bu
dosya tamamen ayna istatistiğe mahkûm değil — ama istatistik kurumu (CAPMAS)
kapalı olduğu için sayısal omurga yine uluslararası kaynaklardan kurulacak.

---

## Tur 1 — ÖLÇÜLEN İLK RAKAMLAR

*(UN Comtrade, 2024, HS 01-24. Çift sayım süzgeci uygulandı: customsCode=C00,
motCode=0, partner2Code=0 — hem sorguya hem gelen satıra.)*

### İki defter, dört rakam — ve hiçbiri tutmuyor

| kim söylüyor | ne diyor | değer |
|---|---|---:|
| Türkiye | TR → Mısır tarım ihracatı | **424.023.474 $** |
| Mısır | TR'den tarım ithalatı | **267.043.295 $** |
| | *fark* | *156,98 milyon $ — Türkiye'nin beyanı %59 fazla* |
| Mısır | Mısır → TR tarım ihracatı | **281.951.889 $** |
| Türkiye | Mısır'dan tarım ithalatı | **184.199.173 $** |
| | *fark* | *97,75 milyon $ — Mısır'ın beyanı %53 fazla* |

**İki taraf da kendi GİDENİNİ, karşının GELENİNDEN fazla sayıyor.** Irak'ta
sorun ülkenin hiç raporlamamasıydı; burada ikisi de raporluyor ve ikisi de
aynı yöne sapıyor. Bu §2.2.1'in ikinci biçimi ve dosyada açıkça yazılacak.

**AMA DOSYANIN İMZASI BU OLAMAZ** — İspanya zaten "aynı yağ, üç defter"
bölümünü yazdı. Tekrar olurdu.

### Paylar

- Türkiye'nin dünyaya tarım ihracatı 32,54 milyar $; **Mısır'ın payı %1,30**
- Mısır'ın dünyaya tarım ihracatı 9,98 milyar $; **Türkiye'nin payı %2,82**
- Türkiye'nin Mısır'a toplam ihracatı 4,18 milyar $; **tarımın payı %10,2**

Yani ilişki Mısır için Türkiye'den daha önemli — iki kat.

### İKİ YÖNDE AKAN FASILLAR — "rakip" rolünün ölçülmüş hâli

| fasıl | giden | gelen |
|---|---:|---:|
| HS 07 Sebze | 57,84 M$ | **90,10 M$** |
| HS 08 Meyve | **56,95 M$** | 36,92 M$ |
| HS 20 Sebze-meyve hazırlıkları | 36,90 M$ | 8,95 M$ |
| HS 17 Şeker | 23,61 M$ | 10,12 M$ |
| HS 15 Katı/sıvı yağ | **84,06 M$** | 0,98 M$ |
| HS 04 Süt ürünleri | 31,59 M$ | 0,04 M$ |

İki ülke **birbirine aynı fasılları satıyor**: sebzede Mısır öne geçiyor,
meyvede Türkiye. Yağ ve süt tek yönlü. Rotasyondaki "Rakip" rolü burada
soyut bir etiket değil, ölçülmüş bir desen.

---

## Tur 2'de karara bağlanacak — EKSEN

Üç aday var. Hiçbiri henüz veriyle kapatılmadı; tur 2'nin işi bu.

**A — Kirayla tarım.** Mısır toprağının çok küçük bir kısmını ekiyor, suyunun
neredeyse tamamı ülke dışından geliyor, ekmeğinin büyük kısmını satın alıyor;
buna rağmen Türkiye'nin sebze rafındaki rakibi. *Ölçülecek:* ekili alan payı,
Nil'in dış kaynak payı, buğday ithalatı sırası, sebze ihracatı.

**B — Yukarı havzanın kararı.** Ülkenin tarımı başka bir devletin barajına
bağlı (GERD). *Ölçülecek:* GERD'in doluluk takvimi ve Nil akışı; belgeli
olmayan hiçbir şey yazılmaz — bu siyasi bir konu ve dosya taraf tutmaz.

**C — Kalori ithal eden, değer ihraç eden ülke.** Dünyanın en büyük buğday
alıcılarından biri, aynı zamanda narenciye ihracatçısı. *Ölçülecek:* buğday
ithalatı (USDA PSD) ile narenciye ihracatı (Comtrade/FAOSTAT) aynı ölçüde.

**Eksen kullanıcı kararıdır** (Irak'ta da öyle oldu). Üçü de aynı veriyi
istiyor, o yüzden tur 2 veriyi çekip üçünü birden ölçecek; karar ondan sonra.

---

## Tur 2 — EKSEN A ÖLÇÜLDÜ

*(Kullanıcı kararı: "A olsun." — **Kirayla tarım**.)*

Eksenin dört ayağı da kaynağa bağlandı. Hiçbir rakam bellekten yazılmadı.

### 1. Toprak — ülkenin kırkta biri

FAOSTAT Arazi Kullanımı, 2024 (`arazi.json`):

| | Mısır | Türkiye |
|---|---:|---:|
| kara alanı | 99.545 bin ha | 76.963 bin ha |
| tarım arazisi | **4.229** | 38.640 |
| **payı** | **%4,25** | **%50,21** |
| fiilen sulanan / tarım arazisi | **%100,00** | %12,72 |

Türkiye toprağının yarısını ekiyor, sekizde birini suluyor. Mısır kırkta
birini ekiyor ve **hepsini suluyor**.

> **SINIR — iddia olarak yazılmadan teyit edilecek.** "Tarım arazisi =
> fiilen sulanan alan" eşitliği FAOSTAT'ta **yalnız 4 yıl** için var
> (2021-2024); ikisinde birden veri olan tek dönem o. Eşitlik birebir
> (4.229 = 4.229) ve bu bir atama (imputation) olabilir. İkinci kaynakla
> doğrulanmadan "Mısır tarımının tamamı sulamalıdır" cümlesi kurulmayacak.

Ayrıca ölçüldü: tarım arazisi **1961'de 2.568 bin ha, 2024'te 4.229** —
**%65 artış**. Ülke toprak üretiyor (ıslah projeleri). İç tutarlılık da
tuttu: işlenebilir 3.274 + daimi ürün 955 = 4.229.

### 2. Su — yüzde 97'si ülke dışından

Birincil belge: **FAO AQUASTAT, Irrigation in Africa in figures, 2016
taraması — Mısır ülke profili** (`kaynak_dosyalari/fao_aquastat_misir_2016.pdf`,
22 sayfa). AQUASTAT'ın web profili JS kabuğu olduğu için PDF yolundan alındı.

> *"Egypt's dependency ratio is one of the world's highest with **96,9 percent**
> of the total renewable water resources flowing into the country from
> neighbouring countries."*

| | değer | yılı |
|---|---:|---|
| dışa bağımlılık | **%96,9** (tabloda 97) | — |
| iç yenilenebilir kaynak | 1.800 milyon m³/yıl | uzun dönem ort. |
| toplam yenilenebilir | 58.300 milyon m³/yıl | — |
| kişi başı | 699 m³/yıl | 2014 |
| baraj kapasitesi | 168.200 milyon m³ | 2015 |
| toplam çekim | 68.300 milyon m³ | 2000 |
| çekimin dağılımı | tarım %86 · belediye %8 · sanayi %6 | 2000 |

> **İKİ TUZAK.**
> **(a)** Çekim (68.300) toplam kaynaktan (58.300) BÜYÜK. Hata değil:
> belge sebebini yazıyor — tahliye suyu yeniden kullanılıyor (*secondary
> freshwater*). Bu iki rakam yan yana yazılırsa açıklamasız bırakılmayacak.
> **(b)** Belge 2016 taraması ama içindeki rakamların kendi yılları ayrı
> (2000, 2014, 2015). Hiçbiri "bugün" diye yazılamaz; her cümlede yıl
> belirtilecek (§2.7).

### 3. Ekmek — dünyanın bir numaralı alıcısı

USDA PSD, 2024 **pazarlama yılı** (`bugday.json`). PSD'nin son iki yılı
tahmin olduğu için kesin son yıl 2024 alındı.

| buğday, bin ton | |
|---|---:|
| ithalat | **12.467** |
| üretim | 9.000 |
| tüketim | 20.000 |
| **tüketimin ithal payı** | **%62** |
| dünya sırası | **1** |
| dünya ithalatındaki payı | %6,2 |

İlk altı: **Mısır 12.467** · AB 10.715 · Endonezya 10.452 · Cezayir 9.100 ·
Brezilya 7.198 · Filipinler 6.351.

> **ÇİFT SAYIM ÖLÇÜLDÜ VE YOK.** PSD'de "World" satırı yok; dünya toplamı
> ülkeleri toplayarak bulunuyor. "European Union" bir KÜME satırı — ama
> PSD'de hiçbir AB üyesinin ayrı satırı yok, yani küme ile üyeler aynı
> toplamda buluşmuyor. Betiğe kalıcı kontrol kondu: üye satırları bir gün
> eklenirse `bugday_ayikla.py` hata verip durur.

**Bir anormallik doğrulandı:** dünyanın en büyük buğday alıcısı aynı yıl
**2.352 bin ton buğday ihraç ediyor**. Veri artefaktı değil — arz/kullanım
dengesi birebir tutuyor: 3.796 + 9.000 + 12.467 = 25.263 = 20.000 + 2.352 +
2.911.

Yanında iki rakam daha: **mısırda da ithalat üretimin üstünde** (10.564 /
7.000; yemlik tüketim 14.700), **pirinçte ülke kendine yetiyor** (üretim
3.900, ithalat 160). Su isteyen ürün ekilmiyor, su istemeyen alınıyor —
eksenin kendisi bu ayrımda.

### 4. Raf — aynı fasılları satıyoruz

Comtrade 2024 (tur 1): sebzede Mısır öne geçiyor (gelen 90,10 M$ / giden
57,84 M$), meyvede Türkiye (56,95 / 36,92). Yağ ve süt tek yönlü.

---

## Tur 2 — ERİŞİM HARİTASINA EKLEMELER

| kaynak | sonuç |
|---|---|
| FAOSTAT `production/` toplu (QCL, LandUse) | **açık** — dizin listesi boş ama gerçek zip iniyor |
| USDA PSD toplu CSV | **açık** |
| Dünya Bankası **belge arama** API'si | **açık** (veri API'sinden ayrı sunucu) |
| FAO belgeleri `fao.org/4/<ad>.pdf` | **açık**, gerçek PDF |
| FAOSTAT `Environment_Water` toplu | **403** |
| AQUASTAT veri API (`data.apps.fao.org`) | 200 ama **text/html** — JS kabuğu |
| Nile Basin Initiative belge sayfaları | **404** (ana sayfa açıktı, belge yolları değil) |
| Dünya Bankası **veri** API'si | **hâlâ 502/zaman aşımı** — tur 3'te yeniden |

Makro göstergeler (tarım/GSYH payı, kırsal nüfus, gıda ithalat payı) hâlâ
Dünya Bankası'na bağlı ve o kaynak düşük. Tur 3'te ya açılır ya FAOSTAT
üzerinden kurulur.

---

## Tur 3'e kalanlar

1. **Dünya Bankası yeniden denenecek** — makro göstergeler eksik.
2. **"Tamamı sulanıyor" eşitliği** ikinci kaynakla teyit edilecek.
3. **FAOSTAT üretim serileri** (QCL Afrika/Asya indi, henüz ayıklanmadı):
   narenciye, patates, soğan — rakip rolünün ürün bazlı karşılığı.
4. **İskelet** — §2.8'in beş kategorisi Mısır'da neye denk geliyor.
5. **Dosyanın YAPISAL İMZASI.** Eksen A ölçüldü ama imza henüz yok.
   İspanya'nın "üç defter"ini, Avustralya'nın "su piyasası"nı tekrar
   etmeyen bir kurgu gerekiyor. İlk aday: ülkenin her girdisinin başka
   birinden geldiği — toprak ıslahla üretilmiş, su yukarı havzadan,
   ekmek Karadeniz'den — ama rafta bizimle yarışan ürünün kendi.

---

## Tur 3 — ÜRÜNLER, VE DOSYANIN İMZASI

### Önce bir düzeltme

Tur 2'de "su isteyen ürün ekilmiyor, su istemeyen alınıyor" diye yazmıştım.
**Yanlıştı.** Ölçüldü: Mısır pirinçte Türkiye'nin **6,31 katını** üretiyor
(6.430.000 t / 1.019.000 t, 2024) ve pirinç alanı 1990'dan beri %62 büyümüş
(435.908 → 704.158 ha). Dünyanın en su-bağımlı ülkelerinden biri, en çok su
isteyen ürünü genişletiyor. Cümle veriden değil sezgiden yazılmıştı —
Hollanda dosyasında aynı hata "açık tarla ürünlerinde fark yok" diye
yazılmış ve veri onu da yalanlamıştı.

### Rakip rolünün ürün karşılığı

FAOSTAT QCL, ortak son yıl 2024 (`uretim.json`):

| ürün | Mısır (t) | Türkiye (t) | oran |
|---|---:|---:|---:|
| **portakal** | 4.200.000 | 1.610.000 | **2,61×** |
| **pirinç** | 6.430.000 | 1.019.000 | **6,31×** |
| kuru soğan | 3.439.646 | 2.632.000 | 1,31× |
| patates | 8.082.291 | 6.900.000 | 1,17× |
| narenciye toplam | 5.857.700 | 5.481.576 | 1,07× |
| mandalina | 1.265.813 | 1.988.000 | 0,64× |
| domates | 7.521.071 | 14.617.000 | 0,51× |
| buğday | 9.400.000 | 20.800.000 | 0,45× |
| limon | 381.921 | 1.730.000 | 0,22× |
| **çiğit pamuk** | 228.179 | 2.243.000 | **0,10×** |

Portakalda rakiplik **artıyor**: 1990'da 2,14× iken 2024'te 2,61×.

### §2.8/5 — TERK EDİLEN ÜRÜN bulundu: pamuk

| | zirve | bugün | değişim |
|---|---|---|---:|
| çiğit pamuk | 1.481.700 t (1965) | 228.179 t (2024) | **%−85** |
| pamuk lifi | 541.450 t (1969) | 77.530 t (2023) | **%−86** |
| ekili alan | 834.385 ha (1961) | 81.499 ha (2024) | **%−90** |

Adı hâlâ dünya markası olan ürün, ülkede onda bire inmiş. Türkiye'nin çiğit
üretimi Mısır'ın on katı. Sebep tur 4'te aranacak — **henüz kaynağı yok,
yazılmayacak.**

### BİÇİM TUZAĞI — betik sessizce boş döndü

`uretim_ayikla.py` ilk yazımda on iki ürünün hepsine "—" verdi ve **hata
vermedi.** Sebep: FAOSTAT'ın QCL **bölge** dosyaları GENİŞ biçimde (Y1961,
Y1961F, Y1962… sütunları), Arazi Kullanımı dosyası ise NORMALİZE
(Year/Value sütunlu). İkisi aynı sanılmıştı.

Rusya günlüğündeki "tek bölge okunursa karşılaştırmanın yarısı sessizce boş
gelir" uyarısının kardeşi. Betiğe iki koruma kondu: yıl sütunu bulunamazsa
**durur**, ve `Y<yıl>F` bayrak sütunu seriyle birlikte taşınır (E=tahmin,
I=atama) — tahmin edilmiş hücre ölçülmüş gibi yazılamaz.

---

## DOSYANIN YAPISAL İMZASI — **BİR FEDDAN**

İspanya'nın "üç defter"i, Avustralya'nın "su piyasası" vardı. Mısır'ınki
bir ÖLÇÜ BİRİMİ olacak: **feddan** (0,42 hektar).

Gerekçe, dördü de AQUASTAT ülke profilinden (2016 taraması):

1. **Ülkenin yarısı bu birimin altında.** *"about 50 percent of holdings
   having an area less than 0.42 ha (1 feddan)"*
2. **O tarla yılda bir kereden fazla hasat ediliyor.** Sulanan alanda ekim
   yoğunluğu **%175** (2010). Toprağı olmayan ülke aynı toprağı iki kez
   kullanıyor.
3. **İki cins toprak var ve biri üretilmiş.** *Old Lands* — Nil vadisi ve
   deltası. *New Lands* — 1970'teki Asvan Barajı'ndan sonra ıslah edilmiş,
   "genellikle daha az verimli". Tarım arazisinin 1961'den beri %65
   büyümesi (2.568 → 4.229 bin ha) bu.
4. **O feddanın suyu ülkenin değil.** Yenilenebilir kaynağın %96,9'u
   komşu ülkelerden geliyor.

Dosyanın birimi ülke değil **bir tarla**: üstünde ne yetişiyor, yılda kaç
kez, kimin suyuyla, ve rafta bizimle neyde yarışıyor. §2.9'un istediği
"tutamak" da kendiliğinden geliyor — 0,42 hektar, okurun gözünde
canlanabilen bir büyüklük.

Bu kurgu önceki dört dosyanın hiçbirini tekrar etmiyor: ayna istatistik
değil (Mısır raporluyor), defter karşılaştırması değil (İspanya), piyasa
değil (Avustralya), kurum katmanı değil (Hollanda).

---

## §2.8'in beş kategorisi — Mısır'da durum

| | kategori | Mısır'da | durum |
|---|---|---|---|
| 1 | Bilim ve kişi | ? | **AÇIK** — tur 4 |
| 2 | Kültürel açıklama | ? | **AÇIK** — tur 4 |
| 3 | Gündelik tarım | holdinglerin ~%50'si 1 feddanın altında | ✓ kaynaklı |
| 4 | Türkiye bağı | ? | **AÇIK** — tur 4 |
| 5 | Terk edilen ürün | pamuk, %−86 | ✓ ölçüldü (sebebi açık) |

İkisi kaynaklı, üçü açık. Hiçbiri uydurulmayacak; bulunamazsa boş kalır
(§2.8: "hepsini doldurmak zorunlu değil").

## Tur 4'e kalanlar

1. Pamuğun çöküş **sebebi** — birincil kaynak gerekiyor.
2. §2.8'in üç boş kategorisi.
3. Türkiye–Mısır tarım ilişkisinin belgesi (ticaret anlaşması, Resmî Gazete).
4. Makro göstergeler — Dünya Bankası tur 3'te **açıldı**, çekim sürüyor.
5. İskelet taslağı: 17-20 bölüm, bölüm ortalaması 250+ kelime (§2.14).

---

## Tur 4 — BELGELER VE AÇIK KATEGORİLER

### §2.8/4 TÜRKİYE BAĞI — kapandı, birincil belgeyle

**Türkiye Cumhuriyeti ile Mısır Arap Cumhuriyeti Arasında Bir Serbest
Ticaret Alanı Tesis Eden Anlaşma.**

| | |
|---|---|
| imza | 27 Aralık 2005, **Kahire** |
| uygun bulma | **5563 sayılı Kanun**, 13/12/2006 |
| Bakanlar Kurulu kararı | **2007/11557**, 15/1/2007 |
| Resmî Gazete | **30 Ocak 2007 · sayı 26419 MÜKERRER** |
| yürürlük | 1 Mart 2007 |

Nüsha indirildi: `kaynak_dosyalari/rg_26419_sta_metin.htm`.

> **MÜKERRER TUZAĞI — ikinci kez.** Belge ana nüshanın dizininde YOK;
> Mükerrer ekte. 30 Ocak 2007 sayısının içindekiler listesine bakan biri
> "böyle bir karar yok" sonucuna varırdı. TİGEM'i kuran 95 sayılı KHK de
> 18205 **Mükerrer**'deydi. Resmî Gazete'de belge aranırken Mükerrer eki
> ayrıca sorulacak.

**Ekler açılamadı.** Tarım tavizlerinin listesi `Mısır STA Türkçe.rar`
dosyasında (298.052 bayt, indirildi: `indirilen_ek/`). Bu makinede unrar,
unar ve 7z yok. İki rakip ülkenin birbirine tarımda hangi tavizi verdiği
dosyanın en iyi belge bölümü olabilir — açıcı kurulursa tur 5'te okunur.

### §2.8/5 TERK EDİLEN ÜRÜN — sebebi kısmen belgelendi

Kaynak: **FAO için hazırlanan ülke incelemesi, Dr. Gamal M. Siam** (FAO
yayını, tarihsiz; en yeni verisi 2001, kaynakçasında 2002 var).

Belgenin söyledikleri:
- Pamuğun **tarım ihracatındaki payı**: %59,6 (1985-89) → **%27,0**
  (1990-94) → %30,0 (1995-2000)
- 1990'ların ikinci yarısında *"liberalization of cotton marketing and trade"*
- Tahıl alanı **pamuğun alanı pahasına** genişledi (*"at the expense of the
  cultivated area of cotton and green fodder crops"*)
- Devlet *"pirinç ve pamukta desteği kaldırdı"*
- Kamu şirketleri ihracatın **dörtte üçünü** yapıyor

> **BU BELGEDEKİ BİR RAKAM KULLANILMAYACAK.** Tablo 9 pamuk ihracatını
> 1985-89 için **3.250 bin ton** diyor. Mısır'ın TÜM lif üretimi zirvede
> 541.450 tondu (FAOSTAT, 1969). Üç milyon ton pamuk ihracatı mümkün değil;
> tablonun birimi ya da tabanı başka bir şey. Paylar (%59,6 → %27,0)
> kullanılabilir, tonajlar KULLANILMAZ. Kaynağa güvenip rakamı taşımak
> §2.2'nin ihlali olurdu.

Belge 2002 civarı; **2000 sonrası çöküşü açıklamıyor.** FAOSTAT'ta asıl
düşüş ondan sonra: 2000'de 553.883 t çiğit → 2020'de 160.000 t. Sebebin
bu kısmı hâlâ kaynaksız ve **yazılmayacak**.

### §2.8/1 ve §2.8/2 — HÂLÂ AÇIK

Bilim-kişi ve kültürel açıklama kategorileri için kaynak bulunamadı.
§2.8 "hepsini doldurmak zorunlu değil" diyor; tur 5'te bir kez daha
aranacak, bulunmazsa boş kalacak. Uydurulmayacak.

### Dünya Bankası — KARARSIZ, güvenilmeyecek

| tur | sonuç |
|---|---|
| 1 | zaman aşımı |
| 2 | **502 Bad Gateway** |
| 3 | **açıldı** — tek çağrı başarılı (AG.LND.AGRI.ZS 2024 = %4,25) |
| 4 | 8 göstergenin 8'i de hata |

Kaynak kapalı değil, **kararsız**. Tur 3'teki tek başarılı çağrı FAOSTAT
hesabımı doğruladı (%4,25 birebir) ama o da bağımsız teyit SAYILMAZ: Dünya
Bankası'nın arazi serisi zaten FAOSTAT kaynaklı.

**Karar: makro katman FAOSTAT'tan kurulacak.** Dünya Bankası'na bağlı
kalan hiçbir rakam dosyaya girmeyecek; `banka.json` şu an hata dolu ve
öyle duruyor — boş değil, "HATA" yazıyor ki sessiz sıfır sanılmasın.

## Tur 5'e kalanlar

1. Makro katman FAOSTAT'tan (tarım/GSYH yerine üretim değeri serileri).
2. §2.8/1 ve §2.8/2 için son bir arama.
3. STA eklerinin açılması (unrar gerekiyor — **kullanıcı kararı**).
4. İskelet taslağı: 17-20 bölüm, ortalama 250+ kelime, tür dağılımı
   dengeli (§2.14, §2.8).

---

## Tur 5 — MAKRO KATMAN VE İSKELET

### Dünya Bankası bırakıldı, makro FAOSTAT'tan kuruldu

Beşinci turda da zaman aşımı verdi. Karar uygulandı: `makro.json`
FAOSTAT'ın Macro-Statistics, Population ve Employment toplu dosyalarından
üretiliyor. `banka.json` "HATA" dolu hâliyle duruyor — silinmedi ki
kaynağın kararsızlığı kayıtta kalsın.

**ÜÇ TUZAK ÇIKTI, ÜÇÜ DE SESSİZDİ.**

**(a) Nüfus serisi 2100'e kadar gidiyor.** FAOSTAT "Population - Est. &
Proj." veriyor ve **bayrak ayırmıyor**: 1950-2100 arası her yıl `X`
("dış kuruluş rakamı"). Yani tahmin ile projeksiyon bayrakla ayrılamıyor.
İlk çalıştırmada "son yıl" 2100 çıktı ve Mısır'ın nüfusu **201.895 bin**
göründü. Betik artık yıla göre kesiyor: 2026'dan sonrası ayrı bir
`projeksiyon` alanında ve başında *"metne giremez"* uyarısı var.

**(b) Tarım istihdamında CİNSİYET boyutu var.** Gösterge aynı ülke-yıl
için Total/Male/Female satırları veriyor. Süzülmeyince sözlük son geleni
tuttu ve Mısır'ın tarım istihdamı **1.102 bin** göründü. Doğrusu
**5.898 bin** — beş katı. Hata vermiyor, makul görünüyor; §2.2.1'in tarifi.

**(c) Saf tarım kalemi bu iki ülke için YOK.** FAOSTAT'ta "Value Added
(Agriculture)" (22010) Mısır ve Türkiye'de boş; mevcut olan 22016,
**ormancılık ve balıkçılık dahil**. Pay bu kalemden hesaplandığı için
"tarımın GSYH payı" diye yazılamaz, kapsamı her cümlede belirtilecek.

### Ölçülen makro

| | Mısır | Türkiye |
|---|---:|---:|
| nüfus (2026) | 120.101 bin | 87.926 bin |
| **kırsal payı** | **%53,1** | %20,9 |
| tarım istihdamı (2025) | 5.898 bin | 4.899 bin |
| tarım+ormancılık+balıkçılık / GSYH (2025, türetilmiş) | %11,39 | %4,42 |

### EKSENİN TEK SAYISI

```
Mısır    4.229.000 ha / 5.898.480 kişi = 0,72 ha  (1,71 feddan)
Türkiye 38.640.000 ha / 4.898.750 kişi = 7,89 ha
                                         ───────
                              Türkiye'de 11,0 KATI
```

Dosyanın imzası olan feddan burada sayıya dönüyor: Mısırlı tarım
çalışanının elinde iki feddandan az toprak var.

---

## İSKELET TASLAĞI — 18 bölüm + kaynakça

§2.14 hedefi: bölüm ortalaması 250+ kelime, toplam 4.500-5.500.
§2.6 sırası: ayrıntı → bilgi → gösterge → kurum → tarih → ürün.
Tür dağılımı: **6 anlatı · 8 veri · 4 belge** (İspanya 10/10/3,
Avustralya 7/7/2 — okur birkaç kez zemin değiştirmeli).

| # | tür | başlık | omurga |
|---|---|---|---|
| 1 | anlatı | Bir feddan | 0,42 ha; holdinglerin ~%50'si bunun altında |
| 2 | veri | Kırkta bir | tarım arazisi %4,25 · Türkiye %50,21 |
| 3 | veri | On bir kat | çalışan başına 0,72 ha / 7,89 ha |
| 4 | belge | Suyun yüzde doksan yedisi | AQUASTAT bağımlılık oranı %96,9 |
| 5 | veri | Aynı tarla, yılda bir buçuk kez | ekim yoğunluğu %175 (2010) |
| 6 | anlatı | Eski toprak, yeni toprak | Old/New Lands; 1961→2024 %+65 |
| 7 | veri | Dünyanın en büyük buğday alıcısı | 12.467 bin ton, sıra 1, %62 ithal |
| 8 | veri | Ama pirinci kendi yetiştiriyor | 6,31× — su paradoksu |
| 9 | veri | Mısırda da aynı | ithalat 10.564 / üretim 7.000 |
| 10 | anlatı | Adı marka olan ürün | pamuk, zirve 1965 |
| 11 | veri | Pamuğun kırk yılı | %−85 üretim, %−90 alan, ihracat payı %59,6→%27 |
| 12 | veri | Portakalda ikiye bir | 2,61× ve ARTIYOR (1990: 2,14×) |
| 13 | veri | Aynı fasılları satıyoruz | HS 07/08 iki yönlü |
| 14 | belge | İki defter, dört rakam | ayna farkı %59 ve %53 |
| 15 | belge | Kahire'de imzalandı | STA · RG 26419 Mükerrer |
| 16 | anlatı | Kırsalda yaşayan çoğunluk | %53,1 kırsal · 5,9 milyon tarım çalışanı |
| 17 | anlatı | Türkiye buradan ne görebilir | kapanış |
| 18 | belge | Kaynakça | |

**§2.8 karşılığı:** 3 (gündelik tarım) → §1 ve §16 · 4 (Türkiye bağı) →
§15 · 5 (terk edilen ürün) → §10-11. **1 (bilim-kişi) ve 2 (kültürel
açıklama) BOŞ** — kaynak bulunamadı, uydurulmayacak.

**§14 neden imza değil:** ayna farkı dosyada duracak ama İspanya'nın
"üç defter" hamlesinin tekrarı olmaması için tek bir belge bölümüne
sıkıştırıldı, dosyanın kurgusu yapılmadı.

## Tur 6'ya kalanlar

1. STA ekleri — `sudo chown -R $(whoami) /opt/homebrew && brew install unar`
   kullanıcıda; açılırsa §15 belge bölümü tarife dayanır.
2. §2.8/1 ve /2 için son arama.
3. `build_data.py` — veri sayfasının kilitlenmesi (metinden ÖNCE).
4. Grafik tipi seçimi ve `grafikler.json`.

---

## Tur 6 — VERİ SAYFASI KİLİTLENDİ

`build_data.py` → `data.json`. **9 blok · ~69 kalem · 12 doğrulama.**
Metin bundan sonra yazılabilir; önce veri, sonra cümle (§2.2).

### Doğrulamalar — hepsi GERÇEKTEN yaşanmış bir tuzağı bekliyor

| # | ne bekliyor | tuzağın yaşandığı yer |
|---|---|---|
| 1 | her blok `_kapsam` + `_kaynak_niteligi` | §2.2 |
| 2 | **projeksiyon gövdeye girmesin** | nüfus serisi 2100'e gidiyor, bayrak ayırmıyor |
| 3 | **cinsiyet dilimi** — istihdam Total olmalı | ilk ölçümde 1.102 bin çıktı, doğrusu 5.898 |
| 4 | kapsam etiketi — ormancılık+balıkçılık dahil | FAOSTAT'ta saf tarım kalemi bu iki ülkede yok |
| 5 | ayna farkı hesaplanıyor, iddia edilmiyor | iki taraf da kendi gidenini fazla sayıyor |
| 6 | fasıl dökümü manşetle tutuyor | Comtrade çift sayımı |
| 7 | boş sonuç sıfır yazılmamış | Comtrade boş dizi döndürüyor |
| 8 | PSD **kesin** yılı kullanılıyor | son iki yıl tahmin/öngörü |
| 9 | buğday dengesi tutarlı | ihracat anormalliği doğrulandı |
| 10 | sulama eşitliğinin **sınırı** yazılı | eşitlik yalnız 4 yıl için var |
| 11 | **eksen cümlesinin iki sayısı aralıkta** | dışına çıkarsa cümle yazılamaz |
| 12 | birim/toplam tutuyor | bin ha ile ha karışmasın |

Üçü olumsuz denendi (projeksiyon · cinsiyet dilimi · eksen aralığı);
üçü de bozulunca **durdu**.

### TÜRKÇE KÜÇÜLTME TUZAĞI — doğrulamanın kendisi düştü

Dördüncü kural ilk yazımda `"ORMANCILIK".lower()` ile arıyordu ve metin
DOĞRU yazıldığı hâlde hata verdi. Sebep: Python'ın `lower()`'ı Türkçe
bilmiyor, noktasız **I**'yı noktalı **i**'ye çeviriyor —
`"ORMANCILIK".lower()` → `"ormancilik"`, aranan `"ormancılık"` ile
eşleşmiyor. Projenin kayıtlı tuzağı; bu kez doğrulayıcının kendisinde
çıktı. Çözüm kuralı gevşetmek değil, küçültmeyi bırakmak oldu.

### Kilitlenen eksen rakamları

```
arazi payı        Mısır %4,25        Türkiye %50,21
sulanan payı      Mısır %100,00      Türkiye %12,72   (sınırı yazılı)
kişi başına       0,72 ha = 1,71 feddan · Türkiye 7,89 ha → 11,0 KAT
buğday            dünya 1.si · tüketimin %62,3'ü ithal · dünya payı %6,2
ayna farkı        giden %58,8 · gelen %53,1
pamuk             üretim %−84,6 (1965→2024) · alan %−90,2 (1961→2024)
kırsal payı       Mısır %53,1        Türkiye %20,9
katma değer payı  Mısır %11,39       Türkiye %4,42  (ormancılık+balıkçılık dahil)
portakal oranı    2,61×   pirinç 6,31×   çiğit pamuk 0,10×
```

`data.bosluklar` boş (§2.2). Veri notları canlıda GÖSTERİLMEZ.

## Tur 7'ye kalanlar

1. `grafikler.json` — tip seçimi. `siralama`'da 40 kat kuralı (TİGEM tur 5),
   `ikili_cubuk`'ta satır düzeyinde sayı biçimi (TİGEM tur 9).
2. `tasarim.json` — küme ve kontrast; `_raw/kontrast.py` ile ÖLÇÜLEREK.
3. STA ekleri (kullanıcıda: `sudo chown -R $(whoami) /opt/homebrew`).
4. §2.8/1 ve /2 için son arama.

---

## Tur 7 — GRAFİKLER VE TASARIM

`grafikler.json` (16 grafik) · `dogrula_grafik.py` (20 kural) ·
`tasarim.json` · `_raw/kontrast.py` · `dogrula_tasarim.py` (9 kural) ·
`_raw/bolum28.json`. Veri sayfası üç yerde genişletildi ve tur 6'nın
doğrulama sayısı 12'den 17'ye çıktı.

### Grafik turu veri sayfasında ÜÇ BOŞLUK açığa çıkardı

Üçü de tur 3'te **ölçülmüştü** ama `data.json`'a girmemişti. İskeletin
§8, §9 ve §12'si o rakamlara dayanıyor; veri sayfası onlar olmadan metni
taşıyamıyordu.

| ne eksikti | nerede duruyordu | şimdi |
|---|---|---|
| tane mısır ve pirinç dengesi | `_raw/x/psd_grains_pulses.csv` okunmamış | `tahil.tane_misir`, `tahil.pirinc` |
| buğday ithalat serisi 1960-2024 | `_raw/bugday.json` içinde, aktarılmamış | `tahil.bugday_ithalat_serisi` |
| portakalın iki ülkedeki seyri | `_raw/uretim.json` içinde | `urunler.portakal_cizgi` |

`bugday_ayikla.py` ikinci bir tarama kazandı. **Yemlik niteliğinin adı
`Feed Dom. Consumption`** — ilk yazımda `Feed and Residual Use` yazıldı ve
alan sessizce boş döndü; PSD'de o ad yok. Ürün adı değişirse betik artık
duruyor (olumsuz denendi: `Rice, Milled` → `Rice` yapıldı, durdu).

**ADLANDIRMA:** çıktıda tane mısır `tane_misir`, ülke her yerde `misir`.
İki kelime Türkçede aynı; karıştırılırsa hata vermez, **sessizce yanlış
rakam yazar**.

### Yeni veri doğrulamaları — 13'ten 17'ye

| # | ne bekliyor | neden |
|---|---|---|
| 13 | öteki taneler buğdayla **aynı yıldan** | üç tane tek grafikte yan yana; PSD ürünleri ayrı revize ediyor |
| 14 | pirinçte boş yemlik alanı **sıfıra çevrilmemiş** | PSD'de boş; sıfır yazılırsa ölçülmüş sıfır gibi görünür |
| 15 | pamuk indeksinin **tabanı 1961 = 100** ve iki seri her noktada dolu | eksik y değeri olan noktayı çizici DÜŞÜRÜR, iki seri ayrı yıllarda biter |
| 16 | portakalda **"artıyor" iddiası ölçülü** | tek yıldan iddia kurulamaz; ters çıkarsa cümle YANLIŞ |
| 17 | **üç tanenin payları aralıkta** | grafiğin tek cümlesi bu; aralık dışına çıkarsa cümle yazılamaz |

Üçü olumsuz denendi (13 · 16 · 17); üçü de durdu.

### Pamuk neden İNDEKS çizildi

Üretim ton, alan hektar: tek y ekseninde yan yana konamazlar. Taban
1961 = 100 yapıldı ve grafiğin söylediği şey ortaya çıktı — **iki eğri
açılıyor**: alan tabanın %9,8'ine indi, üretim %23,0'ına. Aradaki fark
verimin **2,35 katına** çıkması. Mutlak rakamlarla bu görünmüyordu.

Yan ürün: iki düşüş oranının **ayrı tabanlardan** ölçüldüğü fark edildi
(üretim 1965 zirvesinden %−84,6, alan 1961 başından %−90,2). Aynı cümlede
yan yana konamazlar; ortak tabanlı karşılık eklendi
(`pamuk_dusus_1961_tabanli_yuzde` = %−77,0).

### Grafik doğrulayıcısı — 11 devralındı, 9 burada doğdu

TİGEM'in on bir kuralı alındı. Yeni dokuzu:

| # | kural | nereden geldi |
|---|---|---|
| 12 | **sıralı listeden indeksle okuma sınanıyor** (`_kimlik`) | etiket elle yazılıyor; kaynak sıralaması değişirse çubuk sessizce başka ülkeyi gösterir ve kimse görmez |
| 13 | yigin notu çubukların **kendi** bütününe oranlandığını söylüyor | yoksa okur çubukları birbiriyle karşılaştırır |
| 14 | `cizgi` **harita** biçimi: anahtar sayısal yıl, değer sayı, artan | TİGEM yalnız `liste` biçimini sınıyordu |
| 15 | **yüzde işaretinin yeri** — Türkçede başa, İngilizcede sona | `DossierText.birebir`in beklediği şey; tersi `4,25%` çizdirir |
| 16 | **nottaki ondalık sayı data.json'da VAR** | elle yazılan oran, kaynak güncellenince sessizce yanlışa döner |
| 17 | `ikili_cubuk`'ta sayı biçimi **her satırda** | TİGEM tur 9: %90,93 "91" çiziliyordu |
| 18 | kunye/kartlar rakamlarının **etiketi** var | etiketsiz rakam künye değil |
| 19 | **yigin çubukları aynı dilim adlarını taşıyor** | kod okunarak bulundu |
| 20 | yığılmış türlerde seri rolü **vurgu + ikincil**, sessiz olamaz | kod okunarak bulundu |

Dokuzu da olumsuz denendi; dokuzu da durdu.

#### Kural 16 İLK KOŞUDA ÜÇ ŞEY BULDU

1. `4.200,833 m²` — feddan tanımı. `data.json` `feddan_ha` alanını
   `round(...,4)` ile **0,4201** yazıyordu, not ise 0,4200833 diyordu.
   İkisi ayrışmıştı. Tam değer saklanıyor artık; gösterimdeki basamak
   grafiğin işi (`kunye`'de `ondalik: 2`), veri sayfasının değil.
2. `1.102 bin` — istihdamın **reddedilmiş ilk ölçümü**. Kasıtlı olarak
   data.json'da yok; `_olcum_disi` alanıyla gerekçesi yazıldı.
3. `281,9 milyon` — **gerçek bir hesap hatası**. 281.951.888,598 doları
   milyona çevirip bir basamağa yuvarlayınca **282,0** çıkıyor. Not
   düzeltildi.

#### Kural 19 ve 20 — ÇİZİCİYİ OKUMAK

`dossier_chart_view.dart`, `_Yigin`: `final ilk = c.cubuklar.first` —
**gösterge yalnız ilk çubuktan kuruluyor.** İlk yazımdaki su grafiği tam
bu hataya düşmüştü (bir çubuk kaynak dağılımı, öteki çekim dağılımı) ve
`siralama`ya çevrildi.

> **Yayındaki Rusya dosyasının `tez_yigin` grafiği de bu durumda:** iki
> çubuğun dilim adları ayrı ("Depolanabilir — tahıl, yağlı tohum, küspe"
> ile "Bozulur — meyve, balık, sebze") ve göstergede yalnız ilki
> görünüyor. Her çubuğun altındaki kendi etiketleri doğru, yani maddi
> hata değil; gösterge yanıltıcı. **Dokunulmadı — yayındaki dosya,
> kullanıcı kararı.**

`dossier_chart.dart`, `ChartRole`: `taramali => this == ChartRole.ikincil`
— **yalnız ikincil taramalı çiziliyor.** Yani vurgu ile sessiz aynı
çubukta yan yana durduğunda ayrımı taşıyan tek şey renk. `kirkta_bir` ve
`tarimin_agirligi` bu yüzden `sessiz`'den `ikincil`'e çevrildi.

### Palet — "Mil ve Portakal"

Her iki renk dosyanın **ölçtüğü** bir şeyden geliyor, manzaradan değil:
mil (ve onu getiren su) ülkenin kendi ürünü **değil** — %96,9'u dışarıdan;
portakal ise kendi ürünü ve dizide ilk kez Türkiye'nin **geride** olduğu
kalem (1990'da 2,14 kat, 2024'te 2,61 kat, makas açılıyor).

```
zemin      #0F1311   yuzey      #19201D
murekkep   #E8E4DA   sessiz     #9BA39C
vurgu      #7CC9C2   (mil)      ikincil  #CC7A30  (portakal)
cizgi      #222B27   cizgiVurgu #717D77
şerit      #0B403C ↔ #8A3410   krem #F6F1E7
```

**Dizide ilk kez soğuk renk önde** ve Irak'ın tersine **rol zemine göre
değişmiyor** — mil hem koyu sayfada hem krem şeritte önde. Bu da ölçüm:
milin koyu sürümü ana sayfanın beş renginin en yakınından 1,44 uzakta,
portakalın koyu sürümü 1,35; ikisi de eşiği (1,25) geçiyor, rol
değiştirmeye gerek yok. İlk deneme `#14544E` ana sayfanın yapısal
yeşiliyle **1,21** veriyordu ve koyulaştırıldı.

### Kontrast betiğine eklenen sınama: VURGU ↔ MÜREKKEP

Vurgu yalnız grafikte değil, **gövde metninin içinde** rakam rengi. Bu
sınama olmadan arama şu paleti öneriyordu: vurgu `#F5C689`, mürekkepten
oranı **1,25**. Bütün öteki eşikleri geçiyordu ve cümlenin içinde vurgu
değildi. Eşik seri ayrımıyla aynı: 1,4.

### ÜÇ YOLLU LADDER DENENDİ VE MÜMKÜN DEĞİL

`sessiz` bu dosyada dört grafikte çubuk rengi, o yüzden "üç rolün üçü de
birbirinden 1,4 ayrışsın" kuralı denendi. **Renk uzayı tarandı:** 4,5
eşiğini geçen 2.374 renk, vurgu adayı olarak mürekkepten de ayrışan 1.668
renk.

- Geçen üçlüler **var** — ama hepsinde en çok **bir** rol renkli,
  ötekiler gri: `#928787 / #AAA1A1 / #CFC9C9`.
- Doygun bir vurguyla (s ≥ 0,40) geçenlerde de ikincil griye düşüyor:
  `#C76B6B / #B6AFAF / #D9CCBF`.
- Yani **iki renkli bir palet bu ladder'ı sağlayamıyor.** Arayış değil,
  aritmetik: üç rol de koyu zeminde metin olarak okunacaksa (bağıl
  parlaklık ≥ 0,235) ve aralarında 1,4 basamak olacaksa en parlak rol
  mürekkebin mahallesine çıkıyor.

**Karar:** ladder zorunlu kılınmadı. Yerine (1) sessiz yığılmış türlerde
seri olarak yasaklandı (grafik kural 20), (2) sessiz çiftleri
`kontrast.py`'de **ölçülüyor ama durdurmuyor**, ve (3) `dogrula_tasarim.py`
9. kuralla **muafiyetin gerekçesini denetliyor**: çift bir gün eşiği
geçerse muafiyet ölür ve künyeden kaldırılması gerekir.

### ΔE denendi ve BIRAKILDI

CIELAB ΔE76 ikinci bir vekil olarak ölçüldü, kalibrasyon **başarısız**:

| çift | durum | deuteranopi parlaklık oranı | deuteranopi ΔE |
|---|---|---|---|
| Hollanda `#FF9E5E / #7FC8A9` | **çökmüş** | 1,17 | 52,2 |
| Irak `#E3A94A / #5F93AD` | **yayında çalışıyor** | 1,99 | 87,9 |

Eşiği 52'nin üstüne koymak çalışan paletleri de keserdi. Vekili vekille
denetlemek yerine kayıtlı ölçü (benzetim sonrası parlaklık oranı)
korundu.

### Motif — "Bölünen tarla"

Altıncı geometri ve ilk kez bir **desen değil bir işlem**: önceki beşi
(şerit, bant, nokta, ızgara, poligon) tek seferde kurulmuş biçimlerdi; bu,
aynı hareketin tekrarı. Bir dikdörtgen eşit olmayan parçalara bölünüyor,
parçalar yine bölünüyor. Dosyanın ölçtüğü şey bu: tarım arazisi 1961'den
beri %64,7 büyüdü ama bir çalışana düşen 0,72 hektar.

**ÇİZİLMİYOR.** Depodaki tek motif çizici `polder_motif.dart` ve
`DossierTheme` motif bloğundan yalnız opaklığı okuyor. Bölünen tarla bir
**şartnamedir**; çizici yazılana kadar sayfada polder motifi görünür ve bu
dosyada aksini iddia eden cümle yazılmayacak.

### §2.8'in iki açık kategorisi KAPANDI

`_raw/bolum28.json`.

**1 · Bilim ve kişi — Louis Alexis Jumel** (1785-1823). 1817'de bir iplik
fabrikasını yönetmek üzere Mısır'a geldi, Kahire'de bir bahçede uzun
elyaflı pamuk veren bir çalı buldu, Mehmet Ali çalışmayı mali olarak
destekledi ve fellahlara deltada ektirildi. Dosyanın en büyük düşüşü
(%−84,6) bir kişinin adıyla başlamış bir ürünün düşüşü.
**TARİH ÇELİŞKİSİ:** keşif/ilk ekim yılı kaynaklarda 1818, 1819 ve 1821
olarak ayrışıyor. Metin tek yıl iddia etmeyecek. Birincil kaynak
bulunamadı — bölüm **anlatı** olarak yazılacak, belge olarak değil.

**2 · Kültürel açıklama — pirinç neden ekiliyor.** Su altında tutulan
pirinç tarlasının fazla suyu kıyı akiferine süzülüp deniz suyunu geri
itiyor. Kuzey deltada tuz hacminde %19 azalma; deniz seviyesi yükselmesi
de katıldığında %17. Kaynak **birincil**: Abd-Elaty vd. (2023),
*Journal of Hydrology: Regional Studies* 48, 101466,
doi 10.1016/j.ejrh.2023.101466.
**SINIRLAR:** bulgu **sayısal modelden** (SEAWAT), saha ölçümünden değil;
sonuç nereye ekildiğine bağlı ve orta bölge rakamı kaynaklar arasında
tutarsız, **kullanılmayacak**; pirincin **bu amaçla** ekildiğini doğrulayan
kaynak yok — yan etki; devlet deltanın bazı yerlerinde pirinci su
tasarrufu için kısıtlıyor, yani politika bu yan etkiyi desteklemiyor.

### Grafik takımı — 16 grafik, 18 bölüm

| § | grafik | tür |
|---|---|---|
| 1 | `feddan` | kunye |
| 2 | `kirkta_bir` | ikili_cubuk |
| 3 | `on_bir_kat` | siralama |
| 4 | `suyun_defteri` | siralama |
| 5 | `ayni_tarla` | kartlar |
| 6 | `arazinin_egrisi` | cizgi |
| 7 | `dunyanin_alicisi` · `ithalatin_egrisi` | siralama · cizgi |
| 8-9 | `uc_tane` | yigin |
| 11 | `pamuk_endeksi` | cizgi |
| 12 | `portakalda_ikiye_bir` | cizgi |
| 13 | `ayni_fasillar` | ikili_cubuk |
| 14 | `iki_defter` | siralama |
| 15 | `kahirede_imzalandi` | zaman_cizelgesi |
| 16 | `kirsalda_cogunluk` | ikili_cubuk |
| 17 | `tarimin_agirligi` | ikili_cubuk |

`ticaret_akisi` ve `islem_akisi` **bilerek kullanılmadı**: ilki Irak
dosyasının imzasıydı, ikincisi TİGEM'in.

`suyun_defteri`'nin aralığı **37,9 kat** — 40 kat eşiğinin hemen altında.
En küçük çubuk (iç yenilenebilir su) bilerek orada: grafiğin söylediği şey
onun ne kadar küçük olduğu.

## Tur 8'e kalanlar

1. `metin_tr.md` ve `metin_en.md` — 18 bölüm, ~250+ kelime/bölüm.
   **"2. bölümde para kelimesi kullanılmayacak"** (kullanıcı, 10 Kasım
   2026) ve kural İKİ DİLDE geçerli.
2. Görseller ve altyazılar — **altyazı künyedir**, karede ne görüldüğü
   yazılmaz. Her bölümde bir görsel olmasına özen gösterilecek.
3. `dogrula_metin.py` ve `dogrula_yayin.py`.
4. STA ekleri (kullanıcıda: `sudo chown -R $(whoami) /opt/homebrew && brew install unar`).

### TUR 7 EKİ — STA EKLERİ AÇILDI

`sudo` kullanılamıyor: hesap **sudoers'da değil**. Homebrew yolu kapandı ve
**gerekmedi**:

```
tar -xf indirilen_ek/misir_sta_ekler.rar      # bsdtar/libarchive 3.7.4 RAR okuyor
textutil -convert txt -encoding UTF-8 ...     # macOS'un kendi .doc çeviricisi
```

İkisi de macOS'ta hazır. 19 dosya çıktı. **Tarım tavizleri yalnız
`protokolII.doc`'ta**; Protokol I, Liste 1-4, `ekler.xls` ve EK I **sanayi**
ürünlerine ait — Liste 1 tuz ve mineralle başlıyor (2.082 satır), Liste 4
otomobil ve elektrik motoru (35 satır).

> **DİKKAT — yanlış okunmaya açık bulgu.** Protokol I'de gerçek bir asimetri
> var: Türkiye, Mısır menşeli ürünlerin vergisini **yürürlükle birlikte**
> (1 Mart 2007) kaldırıyor; Mısır ise Liste 1-4 takvimiyle **1 Ocak 2020'ye
> kadar** kademeli iniyor. Ama bu **sanayi** ürünlerine ait. Tarım dosyasında
> tarım tavizi gibi yazılırsa yanlış olur. Metne girerse "sanayi" diye
> etiketlenecek.

`_raw/sta_ayikla.py` → `_raw/sta_ekler.json`. Tablolar betiğe yazıldı,
**toplamlar hesaplandı** (elle toplanmadı):

| | kota grubu | tarife pozisyonu | toplam kota | "Sınırsız" |
|---|---|---|---|---|
| **Tablo A** · TR → EG | 16 | 18 | 54.500 ton | **0** |
| **Tablo B** · EG → TR | 22 | 27 | 58.015 ton | **2** |

**Üç bulgu — üçü de veri sayfasına bağlandı:**

1. **Pirinç, Tablo B'nin %68,9'u.** 30.000 ton kahverengi pirinçte vergi
   tamamen kalkıyor, 10.000 tonda %50 iniyor. Türkiye'nin tarımda açtığı en
   büyük kapı, Mısır'ın **zaten fazlası olan** ürün için (üretim 6,31 kat,
   arzın yalnız %3,9'u ithal).
2. **Yağ, Tablo A'nın %75,2'si.** 41.000 ton, hepsinde vergi tamamen
   kalkıyor. On yedi yıl sonra, 2024'te Türkiye'nin Mısır'a en çok sattığı
   fasıl **hâlâ 15. fasıl**. Belge rafı önceden söylemiş.
3. **Altı sebze pozisyonu TEK 600 tonu paylaşıyor.** Aynı tabloda pirinç tek
   başına 40.000 alıyor. Oysa 2024'te Türkiye'nin Mısır'dan en çok aldığı
   fasıl sebze ve Mısır o fasılda iki yönlü akışın %60,9'unu tutuyor.
   Belgenin en dar kapısı, rafın en kalabalık rafı.

İşlenmiş gıda (1704, 1806, 1902, 1905, 2001.10, 2008, 2009, 2102.10) iki
tabloda da **birebir aynı** kota ve aynı %15 ile duruyor.

**Veri doğrulamaları 17'den 21'e:**

| # | ne bekliyor |
|---|---|
| 18 | taviz toplamı kalemlerden yeniden hesaplanıyor — **kota başına**, pozisyon başına değil |
| 19 | **"Sınırsız" sıfıra çevrilmemiş** — sıfır "taviz yok" diye okunur, oysa tersi |
| 20 | pirinç kapısı Tablo B'nin **en büyüğü** ve Mısır'ın üretimi Türkiye'nin **üstünde** |
| 21 | 2024'te en büyük giden fasıl **hâlâ 15** — yağ cümlesi buna dayanıyor |

Dördü de olumsuz denendi; dördü de durdu. (20'nin ilk denemesi kuralı değil
denemeyi yanlış kurmuştu: eklediğim satır da `1006` ile başlıyordu, kural
haklı olarak susuyordu.)

**Grafik 16'dan 17'ye:** `taviz_degisimi` (kartlar, §15b). Ve **kural 16
genişletildi** — artık kart gövdelerini ve künye alt satırlarını da tarıyor.
İlk hâli yalnız `not` ve `baslik`'a bakıyordu; STA kartları sayıyı tam
gövdeye yazıyor, yani kural boşa düşecekti.

**İki yanlış cümle düzeltildi:** `data.json`'ın `belge._ekler` alanı ve §15
grafiğinin notu "bu makinede açılamadı" diyordu. Artık ne olduğunu söylüyor.

---

## Tur 8 — METİN

`metin_tr.md` (18 bölüm · 4.447 kelime) · `metin_en.md` (18 bölüm · 5.677
kelime) · `dogrula_metin.py` (13 avcı). Veri sayfası 21'den **23**
doğrulamaya çıktı; iki yeni kural anlatı kaynaklarını bekliyor.

### Bölüm uzunluğu BİLEREK şişirilmedi

Bölümler 202-439 kelime, ortanca ~235. Yayındaki dosyaların ortancaları:
Avustralya 230, Rusya 248, Irak 274, Hollanda 314. Yani aralık içinde.

**§2.14.1 bunu zaten yazıyor:** "Metni 138'den 250 kelimeye çıkarmak,
aradaki boşluğu DÜZYAZIYLA doldurmak demek — ve o düzyazıya dokuz kaynaksız
iddia sızdı." Hedef kelime sayısına ulaşmak için cümle eklemek, bu projenin
kayıtlı hatası. Eklenmedi.

### Kendi metnimde §2.14.1 denetimi — DOKUZ DÜZELTME

Yazdıktan sonra kendi cümlelerimi aynı ölçütle taradım. Dokuz yerde
düzeltme gerekti:

| ne | ne yapıldı |
|---|---|
| §5 "yılda ikinci, bazı ürünlerde üçüncü bir ekim mümkün olur" | kaynaksız agronomik iddia — kaldırıldı, yerine ölçülen oran ve "kaç ürünün üst üste ekildiği ölçülmedi" notu |
| §6 "çölde açılan toprak deltanın alüvyonuyla aynı verimi vermez" | kaynaksız iddia — soruya çevrildi |
| §14 "bir komşuluk hattı tarım ihracatının yedide birini taşıyordu" | BAŞKA dosyanın rakamı, bu dosyanın veri katmanında yok — kaldırıldı |
| §15, §17 "bir belgenin on yedi yıl sonra geçerli olması olağan değil" | kaynaksız nadirlik yargısı — olguya indirildi |
| §16 "her on bir kişiden biri" | cümlede bölme — `kirsal_nufusun_tarim_calisani_payi_yuzde` eklendi (%9,3) |
| §16 "kırsal nüfusun payı yüz yıl içinde tersine döndü" | kaynaksız tarihsel iddia — ölçülen iki orana indirildi |
| §17 "iki buçuk kat daha ağır" | cümlede bölme — `katma_deger_payi_kat` eklendi (2,58) |
| §3 "999 bin kişi daha fazla" | yuvarlama 1.000 veriyor — yazıyla "yaklaşık bir milyon" |
| §17 "bir çalışanın tarlasının 1,71 katı kadar" | **TERS YAZILMIŞ** — tarla feddanın 1,71 katı, tersi değil |

Son madde maddi hataydı ve hiçbir betik onu yakalayamazdı: ilişki ters
kurulmuştu, sayı doğruydu.

### Avcının yakaladığı asıl şey: TIRNAK İÇİNDE PARAPHRASE

§4'teki FAO alıntısı **iki dilde de kaynağın sözcükleriyle değil benim
sözcüklerimle** yazılmıştı:

| | metin |
|---|---|
| yazdığım | …total renewable water resources **coming from outside the country**. |
| kaynak | …total renewable water resources **flowing into the country from neighbouring countries**. |

Anlam aynı, sözcükler değil — ve tırnak içinde paraphrase **uydurma
alıntıdır**. Rakam izi avcısı bunu göremezdi (rakam yok); alıntı izi avcısı
yakaladı. Nereden geldiği de belli: ilk tur aramasının özetinden, belgenin
kendisinden değil. Veri katmanı PDF'ten çıkarılmış doğru cümleyi tutuyordu.

Kural bu yüzden **uyarıdan hataya çıkarıldı**. Muafiyet iki yerde: kaynakça
bölümü (orada italik eser ADI demek) ve satırında "(çeviri)" işareti taşıyan
alıntılar.

### Biçim kuralı netleşti

Birebir kaynak metni `*"..."*` yazılır. **Düzyazı çift tırnak kullanmaz.**
İlk yazımda retorik ibareler de tırnaklıydı ("hangi fasıl daha büyük",
"ne yetiştireceğini seçiyor") ve avcı onları kaynak alıntısı sanıp dört
bölümde sahte parite hatası verdi. On dokuz yerde düzyazı tırnağı söküldü.

### On üç avcı

| # | avcı | nereden |
|---|---|---|
| 1 | sayı izi, TR ve EN ayrı kalıpla | dizi |
| 2 | **alıntı izi — birebir, hata** | bu dosya; bir paraphrase yakaladı |
| 3 | çizicinin tanımadığı biçim | dizi |
| 4 | yapı — 18 bölüm, iki dilde ardışık | dizi |
| 5 | alıntı paritesi | dizi |
| 6 | ölçülmemiş üstünlük | dizi |
| 7 | **"para" yasağı §2'de, iki dilde** | kullanıcı kuralı, 10 Kasım 2026 |
| 8 | **sulama sınırı aynı bölümde yazılı** | bu dosya |
| 9 | **katma değer kapsamı aynı bölümde yazılı** | bu dosya |
| 10 | **projeksiyon gövdede değil** | bu dosya |
| 11 | **tane mısır ayrımı — kesme işaretiyle** | bu dosya |
| 12 | **Protokol I asimetrisi 'sanayi' etiketli** | bu dosya |
| 13 | **iddia edilmeyenler yazılı** | bu dosya |

On ikisi olumsuz denendi; on ikisi de durdu.

#### İki avcı ilk kurguda KAÇIRDI

**11 · tane mısır.** İlk hâli "tane " ekini aynı satırda ve küçük harfle
arıyordu — satır sarması ve başlıktaki büyük harf yüzünden dört sahte hata.
İkinci hâli yalnız küçük harfli biçimi tarıyordu ve olumsuz denemede
**"Mısırın hasat alanı" kaçtı**. Çözüm Türkçe yazımın kendisinde: özel ad
ekini **kesme işaretiyle** alıyor. Ülke `Mısır'ın`, ürün `mısırın`. Ekli bir
biçim kesme işareti taşımıyorsa üründür ve başında "tane" olmak zorunda.
Şimdi iki biçimi de yakalıyor.

**13 · model etiketi.** İlk hâli §8'de "model" kelimesinin GEÇMESİNİ
yetiyor sayıyordu. Olumsuz denemede etiket cümlesi silindi ama bölümün
başka bir yerinde "modele katıldığında" geçtiği için kural sustu. Artık
bulgunun **saha ölçümü olmadığını** söyleyen ibare de aynı cümlede aranıyor.

### Veri sayfası 23 doğrulama

| # | ne bekliyor |
|---|---|
| 22 | **Jumel'in yıl çelişkisi yazılı** — üç yıl (1818/1819/1821) notta geçmeli, tarihler sıralı |
| 23 | **pirinç süzülmesi 'model' etiketli** ve deniz yükselmesiyle azalma daha KÜÇÜK |

Metnin kullandığı yedi rakam daha veri sayfasına taşındı: PSD'de Türkiye'nin
sırası (21), reddedilen ilk istihdam ölçümü (1.102 — **yanlış rakam, kasıtlı
kayıtlı**), iki arazi artış farkı, üç tanenin alan toplamı, kırsalın tarım
çalışanı payı, katma değer payı katı.

## Tur 9'a kalanlar

1. **Görseller ve altyazılar.** Altyazı **künyedir** — fotonun NE OLDUĞU
   yazılır, karede ne görüldüğü tahlil edilmez (kullanıcı bu düzeltmeyi iki
   kez verdi). Her bölümde bir görsel olmasına özen gösterilecek.
2. `yayin.json` — pencere, kapak, bölüm türleri, bölüm-grafik eşlemesi,
   anahtar kelimeler, ana sayfa hikâyesi.
3. `dogrula_yayin.py`.
4. Devir ve dağıtım — **kullanıcı onayı olmadan yapılmaz.**
