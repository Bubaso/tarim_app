# Türkşeker — Kurum Dosyası Sayı 07 · araştırma günlüğü

Rotasyon §8.13 sıra 7. **Ağır dosya** (§8.1): 13 bölüm, ~4.000 kelime, tam
`data.json` + `_raw`. Pencere 14 gün.

Kullanıcı 23 Kasım 2026: *"Bu dosya çok önemli. çok kapsamlı hazırlamamız
gerekiyor."*

---

## Tur 1 — KAYNAK ERİŞİM HARİTASI VE EKSEN SORUSU

`erisim_haritasi.py` → `erisim.json`. **28 hedefin 22'si açık.**

### KURUMUN KENDİ SİTESİ TAMAMEN AÇIK — dizide nadir

Dokuz uç noktanın dokuzu da iş görüyor: tarihçe, şeker fabrikaları, makine
fabrikaları, faaliyet raporları, kuruluş mevzuatı ve üç PDF (**2025 sektör
raporu**, **ana statü**, **stratejik plan**). Bir kurum dosyası için en iyi
başlangıç: gövde birincil kaynaktan kurulabilir.

### KAPALI OLANLAR

| kaynak | teşhis |
|---|---|
| Şeker Kurumu | alan adı **çözülmüyor** — kurum 2018'de kapatıldı, sitesi de gitmiş |
| ISO (Uluslararası Şeker Örgütü) | bağlantı sıfırlanıyor |
| TBMM tutanak arşivi | 308 |
| FAOSTAT toplu indirme dizini | 200 ama gövde 0 bayt (Mısır dosyasında da böyleydi) |
| Mevzuat — 6747 mülga Şeker Kanunu | **şişman hata sayfası**, aşağıya bakın |
| Türkşeker kütüphanesi (Bakanlık kataloğu) | bağlantı sıfırlanıyor |

Şeker Kurumu'nun sitesinin yok olması dosyanın konusuyla doğrudan ilgili:
düzenleyici kurum kapatıldı ve kaydı da kapandı. Mevzuat ve Resmî Gazete
üzerinden aranacak.

### YENİ TUZAK — ŞİŞMAN HATA SAYFASI

Devraldığım betik gövde uzunluğuna bakıyordu (html için 2.000 bayt eşiği) ve
**ince kabuğu** yakalıyordu. Türkşeker'in sitesi bilinmeyen yolu **302 ile
`Hata.aspx`'e** yönlendiriyor; o sayfa **200 ve 45 KB**. Eşik bunu asla
yakalayamaz çünkü sorun boyut değil **kimlik**.

Önce üç adresi ben uydurdum (`Tarihce.aspx`, `Fabrikalarimiz.aspx`,
`FaaliyetRaporlari.aspx`) ve betik üçünü de **"açık"** saydı. Gerçek adresler
sorgu dizesiyle çalışıyor: `?ModulID=3&MenuID=3`.

Ayırt edici işaret **son adres**: istenen yol ile varılan yol başka. Betik
artık `r.geturl()` kaydediyor ve `hata/error/404/notfound` geçen bir adrese
varan isteği açık saymıyor. İkinci bir örneği hemen yakaladı:
`mevzuat.gov.tr` mülga kanunu `ErrorPage?code=404`'e yönlendiriyor — yine
200.

> **ÖLÇÜM HATASI BENDEYDİ, BETİKTE DEĞİL.** Önce `curl`'ü yönlendirmesiz
> koşturup "gövde 35 karakter" diye okudum ve betiği düzeltmeye kalktım.
> `curl -L` ile bakınca 45 KB çıktı: betik doğru ölçüyordu, ben yanlış.
> Düzeltilmesi gereken şey eşik değil, **son adresin hiç kaydedilmemesiydi.**

---

## EKSEN SORUSU — "100. KURULUŞ YILI" KAYNAKLA TUTMUYOR

Kullanıcı 23 Kasım 2026'da *"ayrıca TÜRKŞEKER'in 100. kuruluş yılı, bunu
eksen yapabiliriz"* dedi. **Kurumun kendi tarihçesi bunu söylemiyor.**

Türkşeker'in tarihçe sayfasından birebir (`?ModulID=3&MenuID=3`):

> "22.Aralık.1925 tarihinde Alpullu Şeker Fabrikasının temeli atılarak onbir
> ayda fabrikanın montajı bitirilmiş ve **26.11.1926** tarihinde fabrika
> işletmeye açılarak **ilk Türk şekerini üretmiştir**."

Yani 26 Kasım 2026'da yüzüncü yılı dolan şey **ilk Türk şekeri**, kurumun
kuruluşu değil. Türkşeker'in kendisi aynı sayfada şöyle anlatılıyor:

> "ayrı şirketler halindeki dört şeker fabrikası, üç milli bankamızın eşit
> paylarla ortak oldukları tek bir şirket çatısı altında toplanmıştır. 22
> milyon TL sermayeli **TÜRKİYE ŞEKER FABRİKALARI A.Ş.** olarak dört ayrı
> fabrika bu şirket tarafından devralınmıştır."

Bu birleşme Turhal'ın açılışından (19.10.1934) **sonra** anlatılıyor ve
**sayfa birleşmeye tarih vermiyor**. Dolayısıyla kurumun yüzüncü yılı 2026
değil; tarihi ayrıca belgelenmeli.

**Önerilen eksen:** yüzüncü yıl **ilk Türk şekerinin**. Bu hem doğru hem daha
belirli — ve dosyanın kendi hikâyesiyle örtüşüyor: dört ayrı şirketin tek
çatıya girmesi, yani Türkşeker'in kendisi, o ilk şekerin sonucu.

### YAN BULGU — ÜÇ HAFTALIK YARIŞ

Aynı sayfada: Uşak'ın şirketi **19.4.1923**'te kuruldu ve temeli
**6.11.1925**'te atıldı; Alpullu'nun temeli **22.12.1925**, yani bir buçuk ay
sonra. Ama Uşak fabrikası **17.12.1926**'da açıldı, Alpullu **26.11.1926**'da.
Sonra başlayan önce bitirdi — üç hafta farkla. "İlk Türk şekeri" unvanı bu üç
haftada belirlenmiş.

---

## Tur 2'ye kalanlar

1. Kuruluş tarihini belgeden doğrulamak: ana statü PDF'i, kuruluş mevzuatı,
   Resmî Gazete. Tarihçe sayfası birleşmeye tarih vermiyor.
2. 2025 sektör raporu, ana statü ve stratejik plan indirilip okunacak.
3. Özelleştirme: 2018'de kaç fabrika satıldı, bugün Türkşeker'de kaç kaldı.
   Tarihçe sayfası 2001'de bitiyor — **son yirmi beş yıl anlatılmıyor.**
4. Şeker Kurumu'nun kapatılması (2018) — mevzuattan.
5. Pancar ekicileri kooperatifleri (Pankobirlik) ile ilişki.
6. Kota rejimi: 4634 sayılı Şeker Kanunu, nişasta bazlı şeker kotası.
7. Eksen kullanıcı kararı (dizide hep öyle oldu).

---

## Tur 2 — KURUMUN KENDİ BELGELERİ

`pdf_metin.py` → üç PDF indirildi ve metne çevrildi.

| belge | sayfa | metin | durum |
|---|---|---|---|
| 2025 sektör raporu | 72 | 137.450 karakter · 70/72 sayfa | **açık, gövdenin omurgası** |
| stratejik plan 2024 | 106 | 135.291 karakter · 93/106 sayfa | açık |
| **ana statü** | 7 | **124 karakter · 0/7 sayfa** | **TARANMIŞ GÖRÜNTÜ — rakam okunamaz** |

Ana statünün görüntü olması tur 1'de yazılan bekçinin ilk yakaladığı şey:
sayfa başına karakter sayılmasaydı belge "indirildi" diye işaretlenip içinden
rakam aranacaktı.

### EKSEN DOĞRULANDI — VE KURUM DA BÖYLE SAYIYOR

Sektör raporu kuruluşu **tarih vererek** yazıyor; tarihçe sayfası
vermiyordu:

> "Ayrı şirketler halinde kurulan Alpullu, Uşak, Eskişehir ve Turhal Şeker
> Fabrikaları; **6 Temmuz 1935** tarihinde, üç milli bankamızın eşit paylarla
> ortak oldukları tek bir şirket çatısı altında toplanarak Türkiye Şeker
> Fabrikaları A.Ş."

Yani kurumun yüzüncü yılı **2035**. Ama aynı rapor Türkşeker için şunu
diyor:

> "sektörde 14 şeker fabrikasının yanı sıra ... **tam bir asırdır** ülkemizin
> önde gelen sanayi kuruluşlarındandır."

**Kurumun kendisi yüzyılı 1926'dan, ilk Türk şekerinden sayıyor.** Eksen
(kullanıcı kararı, 23 Kasım 2026) kurumun kendi saymasıyla örtüşüyor.

### DOSYANIN KALBİ — ALPULLU ARTIK TÜRKŞEKER'İN DEĞİL

> "Afyon, **Alpullu**, Bor, Çorum, Elbistan, Erzincan, Erzurum, Kırşehir,
> Muş, **Turhal** Şeker Fabrikaları ise Özelleştirme İdaresi Başkanlığı
> tarafından satışı yapılarak **2018 yılında özelleştirilmiştir**."

İlk Türk şekerini üreten fabrika yüzüncü yılında kurumun elinde değil.
Kurucu dört fabrikadan **Turhal** da aynı listede. Alpullu kota tablosunda
duruyor ama özel şirketler arasında:

```
(Alpullu)  26.680 ton A kotası  ·  pancar şekerinin %0,94'ü
```

Ve kurumun kendi mülkiyeti de değişmiş:

> "Türkiye Şeker Fabrikaları Anonim Şirketi **29/4/2021** tarihli ve 3923
> sayılı Cumhurbaşkanlığı Kararı ile özelleştirme kapsam ve programından
> çıkarılarak, sermayesinin tamamı **Türkiye Varlık Fonu'na** devredilmiştir."

Tarihçe sayfasının 2001'de bitmesinin sebebi bu olabilir: son yirmi beş yıl
kurumun kendi anlatısında yok.

### ÖLÇÜLEN GÖVDE SAYILARI (2025, sektör raporu)

| kalem | değer |
|---|---|
| TÜRKŞEKER fabrika sayısı | 14 şeker + 3 makine + EMAF + alkol + tohum işleme + Şeker Enstitüsü |
| TÜRKŞEKER'in pancar şekerindeki payı | **%32** |
| TÜRKŞEKER 2025/26 kotası | 1.023.820 ton |
| TÜRKŞEKER'in çiftçisi | 37 ilde, 1.173 köyde, **28.219 çiftçi** |
| TÜRKŞEKER ekilişi / üretimi | 1.081 bin dekar · 7.114 bin ton pancar |
| Ülke pancar üretimi | 20.801.254 ton · işlenen 20.277.129 ton |
| Ülke şeker üretimi (A kotası + C) | 2.915.953 ton |
| Pancar şekeri A kotası toplamı | 2.837.250 ton |
| Özel şeker şirketleri payı | 808.420 ton · **%28,49** |
| Kurulu tatlandırıcı kapasitesi | 4.398 bin ton (3.304 pancar + 1.094 NBŞ) |

### 2001 SONRASI — TARİHÇEDE OLMAYAN KATMAN

- **19 Nisan 2001**: 4634 sayılı Şeker Kanunu yürürlükte; kota rejimi.
- **7103 sayılı Kanun madde 47**: A ve B kotalarının belirlenme usulü
  değişti.
- **Pankobirlik'e geçiş**: Amasya 1991, Kayseri ve Konya 1992 — yönetim
  yetkilerini Türkşeker'den geri aldılar.
- **Özel fabrikalar**: Çumra 2004/05, Boğazlıyan ve Aksaray 2006/07.
- **NBŞ**: nişasta bazlı şeker ayrı kota; kapasitenin dörtte biri.

## Tur 3'e kalanlar

1. İstatistik katmanı: TÜİK pancar serisi, FAOSTAT, USDA PSD şeker, Comtrade.
2. Özelleştirme belgeleri — ÖİB'den satış kararları, bedelleri.
3. Şeker Kurumu'nun kapatılması: hangi mevzuatla, yetkileri nereye geçti.
4. Alpullu bugün üretim yapıyor mu — kota tahsisi var ama üretim ayrı soru.
5. Stratejik plan 2024'ün okunması (106 sayfa, henüz taranmadı).
6. Kuruluş belgesi: ana statü görüntü olduğu için Resmî Gazete'den aranacak.

---

## Tur 3 — İSTATİSTİK KATMANI VE MÜLKİYET HARİTASI

`pancar_ayikla.py` → `pancar.json` · `seker_ayikla.py` → `seker.json`

### FAOSTAT — şeker pancarı, 64 yıl

QCL Asya dosyası Mısır turunda indirilmişti; **yeniden indirilmedi**.

| | 1961 | 2024 | kat |
|---|---|---|---|
| üretim | 2.877.113 t | **23.000.000 t** | 8,0 |
| alan | 130.344 ha | 324.286 ha | 2,5 |
| verim | 22.073 kg/ha | **70.925 kg/ha** | 3,2 |

Zirve **2023: 25.250.213 ton**. 2024'ün bayrağı `A` — resmî, tahmin değil.

> **SERİNİN SINIRI YAZILI:** FAOSTAT 1961'de başlıyor, ilk Türk şekeri
> 1926'da üretildi. **Yüzyılın ilk otuz beş yılı bu seride YOK** ve başka
> kaynaktan gelmek zorunda. `pancar.json/_seri_siniri`.

### USDA PSD — Türkiye dünya dördüncüsü

2024 pazarlama yılı (bin ton): üretim **3.100** · ithalat 235 · ihracat 115 ·
tüketim 3.220 · stok 10.

**Kamış şekeri 0.** Bu ölçülmüş bir sıfır, boş hücre değil: Türkiye şekerinin
tamamı pancardan.

| # | ülke | pancar şekeri (bin ton) |
|---|---|---|
| 1 | Avrupa Birliği *(küme)* | 16.546 |
| 2 | Rusya | 6.900 |
| 3 | ABD | 4.871 |
| **4** | **Türkiye** | **3.100** |
| 5 | Mısır | 2.400 |

Çift sayım ölçüldü: AB küme satırı var, üye satırı yok. Üretim serisi
1960'ta 618 bin tondan 2024'te 3.100 bin tona — **5 kat**.

### DÜZENLEYİCİ KURUM — KANUNDAN BELGELENDİ

Ne sektör raporunda ne stratejik planda **"Şeker Kurumu" ifadesi geçiyor.**
4634 sayılı Şeker Kanunu'nun kendi metni sebebini söylüyor:

```
ÜÇÜNCÜ BÖLÜM  Teşkilat
Şeker Kurumu   Madde 7 –  (Mülga: 20/11/2017-KHK-696/74 md.)
Şeker Kurulu   Madde 8 –  (Mülga: 20/11/2017-KHK-696/74 md.)
               Madde 9 –  (Mülga: 20/11/2017-KHK-696/74 md.)
Hizmet birimleri Madde 10 – (Mülga: 20/11/2017-KHK-696/74 md.)
```

> **Ek Madde 1** — "Mevzuatta Şeker Kurumuna ve Şeker Kuruluna yapılmış olan
> atıflar Gıda, Tarım ve Hayvancılık Bakanlığına yapılmış sayılır."
> *(Ek: 20/11/2017-KHK-696/72 md.; Aynen kabul: 1/2/2018-7079/67 md.)*

Kota rejimi ayrıca **21/3/2018 tarihli 7103 sayılı Kanun**'un 46-49.
maddeleriyle değişti.

### MÜLKİYET HARİTASI — KURUCU DÖRT FABRİKANIN İZİ

2025 sektör raporu bugünkü üreticileri sayıyor: **15 pancar şekeri + 5 NBŞ
şirketi.**

| kurucu fabrika (1926-1934) | bugün |
|---|---|
| **Alpullu** · ilk Türk şekeri | **BİNBİRGIDA TARIM ÜRÜNLERİ A.Ş.** — özel, 2018'de satıldı |
| **Uşak** · ilk temel atılan | **bugünkü üretici listesinde YOK** |
| **Turhal** | **KAYSERİ ŞEKER A.Ş.** — kooperatif, 2018'de satıldı |
| **Eskişehir** | TÜRKŞEKER'de |

Uşak için rapor kapanma tarihi vermiyor; dosya da **vermeyecek** — söylenecek
olan, 2025 listesinde bulunmadığı.

Alpullu'nun kotası: **26.680 ton · pancar şekerinin %0,94'ü.**

### §2.8 KATEGORİSİ KAYNAKTAN GELDİ — "BİLİM VE KİŞİ"

> "Şeker fabrikası kurma çalışmaları ilk defa, **Uşak'lı Molla Ömeroğlu Nuri
> (Şeker)** adında bir çiftçi tarafından Uşak'ta başlatılmıştır."

Türkiye'nin şeker sanayii bir çiftçinin girişimiyle başlıyor ve o çiftçi
soyadını üründen alıyor. Bölüm bu adamla açılabilir.

# TUR 4 — ÖLÇÜM

Tur 4'te ağa hiç çıkılmadı. Elde duran dört belge (sektör raporu, stratejik
plan, ana statü, 4634 sayılı kanun) sonuna kadar okundu ve beş çıkarıcı yazıldı.
Her biri kendi doğrulamasını taşıyor; üçü ilk koşuda düştü ve düştükleri için
yanlış veri dosyaya girmedi.

## Dosyanın omurgası çıktı

**Yüzüncü yıl üç gün sonra.** İlk Türk şekeri 26 Kasım 1926'da Alpullu'da
üretildi. Dosyanın yayın hedefi 26 Kasım 2026 — günü gününe yüzüncü yıl.

Çizelgenin kendisi `tarih.json`'da ve her maddesi kaynak metinden birebir bir
cümleye bağlı: `tarih_kur.py` o cümlenin belgede durduğunu sınıyor, tutmayan
madde çizelgeye giremiyor. İlk koşuda iki madde düştü — kaynak kıvrık kesme
işareti kullanıyordu (`15'e`, `A.Ş'ye`), ben düzünü yazmıştım.

### Önce başlayan, sonra bitiren

| | temel | açılış |
|---|---|---|
| **Uşak** | 6 Kasım 1925 | 17 Aralık 1926 |
| **Alpullu** | 22 Aralık 1925 | **26 Kasım 1926** |

Uşak bir buçuk ay önce başladı; Alpullu onbir ayda bitti ve ilk şekeri o
üretti. Uşak yirmi bir gün sonra açıldı. Bugün Uşak'ta şeker fabrikası yok,
Alpullu ise özelleştirildi ve 15 üreticinin en küçüğü.

## Otuzdan on dörde

| | |
|---|---|
| 1990 öncesi TÜRKŞEKER | **30 fabrika** |
| 2025/26 TÜRKŞEKER | **14 fabrika** |
| 2002/03 pancar şekerindeki payı | **%74** |
| 2025/26 payı | **%32** |

**15↔14 çelişkisi çözüldü.** Stratejik plan 15 fabrika diyor, sektör raporu 14.
Aradaki fark Çarşamba: 25/12/2024 tarihli 9315 ve 9316 sayılı Cumhurbaşkanı
kararlarıyla MKE'ye devredildi, devir 2025'te tamamlandı. İki belge çelişmiyor,
farklı tarihlerde duruyorlar.

## Şeker üçe bölünmüş · `kota.json`

2025/26 pancar şekeri A kotası, 2.837.250 ton:

| | pay |
|---|---|
| **Kamu** (TÜRKŞEKER, 14 fabrika) | %36,08 |
| **Kooperatif** (Kayseri, Konya, Amasya) | %35,42 |
| **Özel** (11 şirket) | %28,49 |

Üç kesim neredeyse eşit. Yüz yaşındaki kurum, kurduğu sanayinin üçte birinden
biraz fazlasını tutuyor. **Alpullu 26.680 ton · %0,94** — listenin en küçüğü.

## Nişasta bazlı şekerin kotası dörtte bire indi

| pazarlama yılı | NBŞ kotası | toplamdaki payı |
|---|---|---|
| 2017/2018 | 267 bin ton | %9,57 |
| 2018/2019 | 135 bin ton | %5,00 |
| 2019/2020 | 67,5 bin ton | **%2,50** |
| 2025/2026 | 72,75 bin ton | %2,50 |

İki yılda **%-74,7**. Kanun metni ile hesap birbirini tutuyor: 7103 sayılı
Kanunun 47. maddesi %10'u %5'e indirdi, Geçici 11. madde ortaya çıkan kota
fazlasını **TÜRKŞEKER'e aktardı**, 2019/20'den sonra Cumhurbaşkanı kararıyla
%2,5'te tutuldu.

Aynı yıllarda NBŞ ihracatı yükseldi (2018: 232.000 t → 2021: 408.117 t) ve
ihracat ithalatın 10-19 katında seyrediyor. **İki olgu da ölçülmüştür; aradaki
bağı belgeler kurmuyor, dosya da nedensellik yazmayacak.**

## İnsan · `kurum.json`, `ciftci.json`

| | 2018 | 2019 | 2022 |
|---|---|---|---|
| TÜRKŞEKER personeli (fiili ortalama) | 7.563 | **5.487** | 5.652 |

On fabrikanın özelleştirildiği yılın ardından personel bir yılda 2.076 kişi
azaldı (%-27,4). Aynı yıla düşmeleri ölçülmüş bir gerçek; nedenselliği bu
belgeler vermiyor.

Çiftçi tarafında düşüş daha uzun soluklu:

| | çiftçi | üretim |
|---|---|---|
| 2017 | **110.131** | 21.149.020 t |
| 2025 | **76.767** | 20.801.254 t |

(ülke geneli)

**Çiftçi sayısı %-30,3, üretim yerinde.** Dosyanın en güçlü tek cümlesi bu
olabilir — ama **hangi rakamın kime ait olduğuna dikkat.** Çapraz sınama
ikisini ayırdı (2017-2025):

| | 2017 | 2025 | değişim |
|---|---|---|---|
| ülke | 110,131 | 76,767 | **%-30.3** |
| TÜRKŞEKER | 38,028 | 28,219 | %-25.8 |
| TÜRKŞEKER dışı | 72,103 | 48,548 | %-32.7 |

Düşüş her iki tarafta da ağır, dışarıda biraz daha sert. **%-30,3 ülke
rakamıdır**; TÜRKŞEKER'in kendi düşüşü %-25,8'dir ve yayında biri diğerinin
yerine yazılamaz. Uyarı `ciftci.json` içindeki `ciftci_dususu_kimin`
alanında duruyor.

Bu ayrım ilk denemede yanlış ölçüldü: TÜRKŞEKER tablosunu 2024'te biter
sanıp ülkenin 2025'iyle karşılaştırdım ve %-5 gibi gerçek dışı bir fark
çıktı. İki tablo da 2025'i taşıyor. Karşılaştırma artık ortak aralığı
betikte hesaplıyor, elle seçilen yıla güvenmiyor. Tablo 26 (ülke) ile Tablo 27 (TÜRKŞEKER) ayrı ayrı okunuyor; ilk
yazımda `rfind` yanlış tabloyu almıştı ve FAOSTAT çapraz denetimi %+198 sapma
vererek yakaladı. Düzeltilmiş seri FAOSTAT ile **2016-2023 arası yedi yıl
birebir aynı**; yalnız 2024 ayrışıyor (rapor 22.413.958, FAOSTAT 23.000.000 —
FAOSTAT'ınki fazla yuvarlak).

## Dış ticaret · `ticaret.json`

2022'de kristal şeker ithalatı **602.479 ton** — bir önceki yılın 12,4 katı,
on yılın zirvesi. 2021'de 48.699 tonla dip yapmıştı.

## Ölçülmüş yokluklar

Bunlar aranıp bulunamadı. Kayda geçiyor ki yayın metni bu boşlukları
doldurmaya kalkmasın:

- **1926-1961 üretim serisi**: iki belgede de yok. FAOSTAT 1961'de başlıyor;
  yüzyılın ilk otuz beş yılı taranan hiçbir kaynakta sayı olarak durmuyor.
- **Uşak'ın kapanış tarihi**: rapor vermiyor. Dosya yalnız 2025 üretici
  listesinde bulunmadığını söyleyecek.
- **Özelleştirme bedelleri**: ÖİB kararları iki belgede de geçmiyor.
- **Şeker Kurumu**: KHK-696/74 ile 20 Kasım 2017'de kaldırıldı ve kurumun
  kendi iki belgesinde **adı hiç geçmiyor**. Çizelgede `_belge_disi` işaretli.

## Şerh düşülen tek kalem

`kurum.json` içindeki gayrimenkul listesi 2022 tarihli, 20,3 km² ve 26 yer —
içinde özelleştirilen fabrikaların yerleri de var (Alpullu 179.383 m², Turhal,
Uşak). Bu kalemlerin neden listede durduğu belgede açıklanmıyor. Tek başına
yayına gerekçe yapılamaz.

# TUR 5 — İSKELET

Tur 5'te dosyanın iskeleti kuruldu: bölüm planı, veri katmanı, grafik seti,
görsel adayları. Metin henüz yazılmadı.

## Seri kuralı önce okundu, sonra iş yapıldı

İki kural bu turun yönünü belirledi ve ikisi de CLAUDE.md'den geldi:

**§8.2 — bu bir TANITIM dosyası.** Kurumu anlatır, yargılamaz. Dizi bir kez
tam da ton yüzünden durdurulmuş. Metne girmeyecekler listesi uzun: tez
cümlesi, belgelerdeki çelişkiler, denetim bulgusu, "açık sorular", veri
notları, meta cümleler. **Tur 4'ün bazı bulguları bu yüzden yayına
giremez** — örneğin Şeker Kurumu'nun kurumun kendi belgelerinde hiç
geçmemesi bir araştırmacı notudur, okurun derdi değil. `tarih.json`'da
`_belge_disi` işaretiyle duruyor ve orada kalacak.

**§8.4 — görsel dil "Evrak", palet dosya başına üretilmez.** Vurgu kuruma
değil KÜMEYE ait. Ve TİGEM'in tasarım dosyası Türkşeker'i adıyla anıyor:

> "Rotasyonun 7. sırasındaki **Türkşeker** ve 8. sırasındaki Et ve Süt
> Kurumu da aynı kümeye girer — üçü de devletin kendi tesisinde üretim
> yapan KİT'i."

Yani palet bir sayı önceden kararlaştırılmış: **Üretim kümesi, kağıt
vurgusu `#1F5626`, kapak vurgusu `#4CC756`.** Yeni palet üretilmeyecek.

## Bölüm planı · `yayin.json`

On dört bölüm + kaynakça. Ritim TİGEM'inkiyle aynı mantıkta: anlatı açılış →
belge bloğu → veri çekirdeği → akış → kapanış.

| | bölüm | tür |
|---|---|---|
| 1 | Alpullu, 26 Kasım 1926 | anlatı |
| 2 | Uşaklı bir çiftçi | anlatı |
| 3 | İki şirket, iki temel | belge |
| 4 | Dört fabrika, tek çatı | belge |
| 5 | Dörtten on beşe | anlatı |
| 6 | Şeker Kanunu: 1956'dan 2001'e | belge |
| 7 | Kota üçe bölünür | veri |
| 8 | Pancardan şekere | veri |
| 9 | Nişastadan gelen şeker | veri |
| 10 | Çiftçi pancarını nasıl satar | akış |
| 11 | 2018: on fabrika el değiştirdi | belge |
| 12 | Bugün: on dört fabrika | veri |
| 13 | Dünyada benzeri | anlatı |
| 14 | Yüzüncü yıl | anlatı |

**§8.9'un beş kategorisinin beşi de karşılığını buldu:** kurucu kişi §2'de
(Uşaklı Molla Ömeroğlu Nuri), para §3'te (Uşak Terakki Ziraat T.A.Ş.,
19/04/1923, 600.000 TL), gündelik karşılık §10'da, dünyada benzeri §13'te,
bıraktığı iş §11-12'de.

## Çiftçi bölümünün omurgası kaynaktan geldi

> "Sözleşmeli üretimin ülkemizde **ilk ve en yaygın** uygulandığı ürün
> şeker pancarıdır."

Ve akışın her adımı belgede yazılı: sözleşme → fiyat ekimden ÖNCE belirlenir
→ ayni ve nakdi avans (**bedelin ~%35'i teslimden önce, faizsiz**) → ekim
(münavebe, üç-dört yılda bir) → teslim → primler → bedelsiz posa.

## Veri katmanı · `data.json`

Yedi çıkarım tek dosyada toplandı, **16 çapraz sınama** geçti. İkisi ilk
koşuda düştü:

- `dunya_siralamasi` yanlışlıkla bir SAYIYA bağlanmıştı (dünya toplamı
  41.865), listeye değil. 14. sınama "boş mu" diye baktığı için float
  sessizce geçti. Sınama artık TÜR de arıyor.
- Şirket sayısı elle yazılmıştı; 15. sınama tabloyla karşılaştırıyor.

Randıman sınaması üç bağımsız kaynağı birbirine bağlıyor: USDA'nın şekeri
÷ TÜRKŞEKER'in pancarı = **%13,8** — pancar şekeri için makul aralıkta.

## Grafik seti · `grafikler.json` + `dogrula_grafik.py`

On bir grafik, yedi ayrı çizici tipi. **Notlardaki rakamlar elle yazılmıyor,
`data.json`'dan okunuyor** (`_raw/kur_grafikler.py` üretiyor) — Mısır'da
elle yazılan bir notta yuvarlama hatası çıkmıştı, burada hata hiç doğmasın
diye kaynağından geliyor.

Denetim 12 kural, 29 bağ. Üç şey denetimin kendisinde düzeltildi:

1. **Pazarlama yılı tuzağı.** "2025/26" sayı kalıbıyla 2025 ve 26'ya
   bölünüyor, 26 ölçüm sanılıyordu. YYYY/YY kalıbı artık önce çıkarılıyor.
2. **Mevzuat numarası ölçüm değildir.** 7103, 4634, 47, Geçici 11 — hiçbiri
   bir şey ölçmez. `OLCUM_DISI` listesinde, her biri adıyla gerekçeli.
3. **Kural 12 iki koşu boyunca sessiz kaldı.** "Üç pay karışmasın" kuralı
   yalnız `not` alanını tarıyordu, oysa iki ölçü en çok KART içinde yan yana
   geliyor; üstelik kalıbı `%32,0` arıyordu, metinde `%32` yazıyor. İkisi de
   düzeltildi ve kural artık `bugun_turkseker` kartını işaret ediyor — o
   metin ayrımı doğru yapıyor (gözle bakıldı), uyarı yerinde duruyor.

## Görsel adayları · `gorsel_adaylari.json`

On dört kare, her bölüme bir tane. Atıf ve lisans Commons API'sinden geldi,
elle yazılmadı.

**En güçlü üçü Uşak'tan:** fabrikanın **hisse senedi** (kamu malı — §8.4'ün
"Evrak" diliyle birebir örtüşüyor), **kurucularının fotoğrafı**, ve kuruluş
yılından iç/dış kareler. Künyeleri şunu söylüyor: bunlar **Mehmet Hacım'ın
aile fotoğrafları**, torunu Tanju Bilgen tarafından kamuya bağışlanmış.
Alpullu karesi **SALT Research** arşivinden, 29 Aralık 1928.

**Ölçülmüş kıtlık:** Commons Türk şeker sanayiinde yoksul. "Sugar refineries
in Turkey" kategorisinde 5 dosya var. Alpullu Şeker Fabrikası'nın kendi
fotoğrafı YOK — eldeki tek 1920'ler karesi fabrikanın albümünden çıkan bir
KÖPRÜ fotoğrafı. Turhal, Kütahya, Kayseri, Amasya, Afyon fabrikalarının
hiçbiri Commons'ta yok. On dört karenin dokuzu Türkiye'den, beşi genel.

**Reddedilenler gerekçeli:** Resmî Gazete karesi (TİGEM tam onu kullandı,
bir sayı sonra tekrar olmaz), Ankara Şeker Fabrikası lojmanlarının yıkımı
(belgeli ve güncel ama tanıtım dosyasının tonunu iddianameye çeker),
İş Bankası hisse senedi (1935'in üç milli bankası iki belgede de
ADLANDIRILMIYOR — yerleştirmenin kendisi ima olurdu).

## Zincir sınandı · `yenile.sh`

Turun sonunda her şey **sıfırdan** koşturuldu ve bir hata çıktı: tek tek
koşunca hepsi geçiyordu, zinciri koşunca `build_data` düştü.

Sebep: `ciftci_dususu_kimin` alanını tek seferlik bir yamayla
`ciftci.json`'a eklemiştim, çıkarıcının içine değil. Çıkarıcı yeniden
koşunca alan silindi. Hesap artık `ciftci_ayikla.py`'nin içinde, kendi
doğrulamasıyla (TÜRKŞEKER çiftçisi ülke toplamını aşarsa betik düşüyor).

`yenile.sh` bütün zinciri doğru sırayla koşturuyor. İki koşu birebir aynı
çıktıyı veriyor — sınandı.

**Ders:** bir veri dosyasına elle dokunulduysa, onu üreten betiğe de
dokunulmalı. Yoksa düzeltme bir sonraki koşuda sessizce kayboluyor.

# TUR 6 — DOSYA

Tur 6'da dosya tamamlandı: tasarım, görseller, metin, anahtar kelime,
hikâye kartı ve dört denetçi. `yenile.sh` on altı adımı sırayla koşturuyor
ve iki koşu birebir aynı çıktıyı veriyor.

## Tasarım · palet ÜRETİLMEDİ, devralındı

TİGEM'in Üretim kümesi aynen alındı (`#1F5626` kağıt, `#4CC756` kapak).
Yirmi kontrast sayısının hiçbiri kopyalanmadı, `_ortak/kontrast.py` ile
yeniden **ölçüldü** — ve TİGEM'inkiyle birebir aynı çıktı (14,19 · 5,23 ·
6,96 · 16,04 · 8,26 · şerit 1,12). `dogrula_tasarim.py` hepsini bir kez
daha ölçüyor.

Kapak başlığı **elle** büyük harfle yazıldı: `upper()` Türkçede "TÜRKIYE"
veriyor; dizide aynı hata iki kez yaşanmış.

Yasak listesine bu dosyaya özgü iki madde eklendi: şekerlikte küp şeker
klişesi ve her türlü şekerli mamul. Türkçede "şeker" hem ürünü hem
şekerlemeyi anlatıyor; dosya pancardan kristal şeker üreten bir KİT'i
anlatıyor.

## Görseller · 1440 değil 1920

On dört kare indi. İki varsayımım da yanlış çıktı ve içerik sınaması
yakaladı:

- API `thumb.wikimedia.org` döndürdü, ben bunu "tarayıcı yeniden
  yazmıştır" sanıp `upload.wikimedia.org`'a çevirdim. Küçük resimlerin
  gerçek hostu artık `thumb`.
- İstediğim 1440 px'e çektim; Commons yalnız standart kovaları sunuyor.
  Ölçüldü: `1440px-` → **400**, `1920px-` → **200**, `1024px-` → **400**.

Sekiz dosya HTML hata sayfası olarak indi ve `curl` buna **0** dedi.
Betik çıkış kodunu değil **içeriği** sınadığı için yakalandı (ilk dört
bayt JPEG/PNG imzası mı). Mısır dosyasındaki `| tail` dersi: çıkış koduna
güvenme.

**Dört kare gözle açıldı.** `turkseker_ankara`'nın Commons açıklaması
yalnız "Ankara'dan çeşitli görüntüler" diyordu; cephede **TÜRKİYE ŞEKER
FABRİKALARI A.Ş.**, kapıda Genel Müdürlüğü yazdığı görüldü.
`turkseker_alpullu_1928` bir **albüm sayfası** çıktı: üç kare Alpullu
Köprüsü, alttakinin ardında fabrika bacası. `turkseker_usak_hisse` ise
Osmanlıca antetli bir hisse senedi — **Uşak Terakki Ziraat Türk Anonim
Şirketi**, yani stratejik planda adı geçen şirketin ta kendisi, altında
basılı "Uşak Şeker Fabrikası Hisse Senedi (1926)".

Uşak karelerinin üçü bir aile arşivinden: **Mehmet Hacım'ın fotoğrafları,
torunu Tanju Bilgen'in kamuya bağışı.** Altyazılar bunu anıyor.

Beş karenin yeri ya da tarihi kaynakta yok ve altyazılar bunu **açıkça
söylüyor** — tahmin edilmedi.

## Metin · TR 3.478 · EN 4.702

On dört bölüm + kaynakça. Oran TİGEM'inkiyle aynı (EN/TR 1,35).

`dogrula_metin.py` on kural taşıyor ve dördü bu dosyada kuruldu:

- **Süreç dili yasak** (§8.2): "bu dosya", "bulunamadı", "taranan"…
- **İddianame dili yasak**: dizi bir kez tam bu yüzden durdurulmuştu.
- **2. bölümde "para" kelimesi yok** — kullanıcı kuralı. **İhlal ettim**
  ("hemşehrilerinin parasıyla"); kural yazıldıktan sonra yakalandı ve
  "biriktirdiği sermayeyle" oldu.
- **Sayı izi**: metindeki her ölçüm `data.json`'da olmalı.

Sayı izi ilk koşuda **30 hata** verdi ve hepsi kuralın kendi körlüğüydü:
ayın günü ("26 Kasım"), mevzuat numarası, kaynakçadaki tablo numarası ve
bileşik sayı ("1 milyon 176 bin" → 1 ve 176). Dördü de kalıba yazıldı.
Geri kalanlar gerçek boşluktu ve `data.json`'a `metin_dayanaklari` bloğu
olarak eklendi — kurumun belgelerinden gelen ama ölçüm olarak hesaplanmayan
otuz rakam. **Hiçbiri gevşetilerek geçilmedi.**

Rakam kuralı da daraltıldı: ilk kalıp "milyon" sözcüğünü arayıp "22,4
milyon ton" gibi rakamla yazılmış her ölçümü yakalıyordu (25 uyarının 19'u
yanlış pozitif). Başlıklar muaf tutuldu — dizinin kendi başlıkları sayıyı
yazıyla taşıyor ("doksandan yirmiye", "arazinin onda biri").

## Anahtar kelimeler · 1.555 habere karşı ÖLÇÜLDÜ

§8.10/1 gereği liste gerçek haberle sınandı. Ölçü dosya hattının kendi
ölçüsü: sözcük sınırı, büyük/küçük harf duyarsız, eşik 2.

| terim | eşleşme |
|---|---|
| TÜRKŞEKER | 37 |
| şeker pancarı | 42 |
| Şeker Fabrikası | 23 |
| şeker üretimi | 9 |
| pancar üreticisi | 5 |
| şeker kotası | 3 |
| Türkiye Şeker Fabrikaları · nişasta bazlı şeker · PANKOBİRLİK | 2 |
| Alpullu · Şeker Kurumu | 0 |

**Tuzak doğrulandı: "şeker" tek başına 65 haber buluyor ve 15'i öbek
terimlerin hiçbirine düşmüyor.** İçlerinde küresel emtia fiyat haberleri,
içme sütü standartları, arı probiyotiği, sorbitol araştırması ve
**gebelik diyabeti** var. Elendi; "pancar" da elendi.

Ölçüm sırasında kendi hızlı süzgecimde bir hata buldum: kök olarak "şeker
pancar" yazmıştım, başlıkta "şeker pancarı" geçiyor ve sondaki "ı" sözcük
sınırını bozuyor. Eşleştiricinin kendisi doğruydu; süzgeç yanlıştı.
Türkçe sonekleri kök kesmekle yakalanmıyor.

## Hikâye kartı

Beş slayt, beş ayrı görsel, beş rakam `data.json`'dan okundu: 600.000 lira
→ 11 ay → %36,08 → 76.767 üretici → 100 yıl. Gösterim sınırları betikte
sınanıyor (Mısır'da etiketler 115-147 karakterdi ve ekranda kesilmişti).

## Dosyanın durumu

| | |
|---|---|
| bölüm | 14 + kaynakça |
| grafik | 11 · yedi çizici tipi |
| görsel | 14 · hepsi atıflı |
| kelime | TR 3.478 · EN 4.702 |
| denetçi | 4 · toplam 44 kural |
| anahtar kelime | 10 · ölçüldü |
| durum | **draft** |

# TUR 7 — ÖNİZLEME

Dosya derlenip tarayıcıda açıldı ve **gözle denetlendi**. Üç hata çıktı;
üçü de yalnız önizlemede görülebilirdi.

## 1. Bir grafik hiç çizilmedi

`kota_uc_kesim` (ikili çubuk) sayfada **boşluk** olarak duruyordu. Sebep:
satırlara `sol`/`sag` diye bir yapı yazmışım; çizicinin beklediği şema
`seriler` (grafik düzeyinde) + her satırda `degerler` dizisi.

**Denetimim bunu neden yakalamadı:** yalnız `@yol` bağlarının çözüldüğüne
bakıyordu. Bağlar çözülüyordu — şekil yanlıştı. *Bağın çözülmesi şeklin
doğru olduğunu göstermiyor.*

Artık **kural 13** var: her çizici tipinin zorunlu alanları sınanıyor
(`kunye→kalemler`, `siralama→satirlar[].deger`, `ikili_cubuk→seriler +
satirlar[].degerler`, `cizgi→seriler[].noktalar` …), `degerler` uzunluğu
`seriler` ile karşılaştırılıyor ve ikili çubukta **sayı biçiminin satırda**
olduğu aranıyor — çizici grafik düzeyindekini okumuyor (TİGEM'de ölçülmüş:
%90,93 "91" çiziliyordu).

Kural 2 de daraltıldı: nokta listesi araması yalnız `cizgi` için, çünkü
`ikili_cubuk` da `seriler` taşıyor ama oradakiler nokta değil.

## 2. %6,70 yazıyordu, doğrusu %6,67

Şirket payını bir ondalığa yuvarlayıp iki ondalıkla çizdirmişim. 1/15
gerçekte **%6,67**; ekranda **%6,70** görünüyordu. İki ondalığa çekildi;
üç kesim 6,67 + 20,00 + 73,33 = 100,00.

## 3. `yenile.sh` düşen denetçiye "temiz" diyordu

`dogrula_yayin.py` alan adı değişikliğinden çöktü, ama zincir yine
**"✓ zincir temiz"** yazdı. Sebep: denetçi `komut && echo "✓"` içinde
koşuyordu ve `set -e` bir `&&` zincirinin SOL tarafında devreye girmiyor.
Çıkış kodu artık ayrıca sınanıyor ve düşen denetçi zinciri düşürüyor.

**Bu üçüncüsü en tehlikesiydi:** bir denetçinin sessizce düşmesi, bütün
denetim katmanını işe yaramaz hâle getirir.

## Görseller yayımlanmadan önizlenemiyor

Kareler `tarimportali.net`'e işaret ediyor ve orada henüz yoklar. Adres
**HTTP 200** dönüyor ama içerik `text/html` — Firebase'in SPA yönlendirmesi
`index.html` veriyor. Yani "200 geldi, demek ki var" demek yanlış.

Kareler `web/dosya/turkseker/` altına kopyalandı (dizinin dağıtım yolu,
git'te izleniyor) ve **yalnız derlenmiş kopyadaki** adresler göreceli
yapıldı. Kaynak `web/onizleme/turkseker.json` mutlak adresleri koruyor.

## Gözle görülenler

On beş bölümün tamamı, yedi çizici tipi ve on dört görsel açıldı:

- **Kapak** — mukavva zemin, Üretim kümesinin yeşili, "KURUM DOSYASI · 07".
- **§1** — Alpullu albüm sayfası; "Evrak" diliyle birebir örtüşüyor.
- **§3** — Osmanlıca antetli hisse senedi.
- **§5** — zaman çizelgesi 1925'ten 2018'e.
- **§7** — üç kesim tablosu, ikili çubuk ve on beş üreticinin sıralaması
  (Alpullu en altta, 27 bin ton).
- **§8** — verim çizgisi 1961→2024 ve dünya sıralaması, Türkiye vurgulu.
- **§10** — işlem akışı: altı numaralı adım, seçenek ayrı satırda.
- **§12, §13** — kart setleri.
- **Dizin** — "07 TÜRKŞEKER [BURADASIN] · 06 TİGEM [ŞİMDİ]".

Hikâye kartı önizlenemedi: ana sayfa şeridi veritabanından okuyor, önizleme
yalnız dosyanın kendisini değiştiriyor. Slayt sınırları betikte sınanıyor.

## Pencere açıkça yazıldı

`pencere.baslangic` **null bırakılmadı**. null olsaydı seed hangi gün
uygulanırsa o an başlardı; 23 Kasım'da uygulansa yüzüncü yıl kaçardı ve
TİGEM iki gün erken düşerdi.

| | |
|---|---|
| başlangıç | `2026-11-25T21:00Z` = **26 Kasım 00:00 TR** |
| bitiş | 10 Aralık 00:00 TR (14 gün) |
| TİGEM'in bitişi | 26 Kasım 02:30 TR |

2,5 saatlik örtüşmede `active` görünümü en yeni başlangıcı seçiyor; devir
boşluksuz.

## Göçler hazır — UYGULANMADI

İkisi de `content/dossiers/turkseker/beklemede/` altında, **`migrations/`
altında değil**. Gerekçe dizinin kendi kuralı: `supabase db push` klasördeki
her şeyi uygular; göç orada dursa ilgisiz bir push dosyayı onay alınmadan
yayına sokardı.

| dosya | ne yapar |
|---|---|
| `20261123150000_turkseker_icerik_draft.sql` | içeriği **draft** yazar; dış `begin/commit` söküldü |
| `20261123151000_dosya_devri_turkseker.sql` | durumu published yapar, pencereyi 26 Kasım'a kurar, "Yakında" kartını **Et ve Süt Kurumu**'na devreder |

Devir göçünde **sekiz sağlama** var. TİGEM'in arşivlenmesi **koşullu**:
yalnız penceresi dolmuşsa. Koşulsuz olsaydı ve göç 26 Kasım'dan önce
uygulansaydı kurum dizisi üç gün boş kalırdı.

Takvimde Türkşeker'in "Yakında" kartı zaten duruyor ve müjdesi yüzüncü yılı
söylüyor: *"İlk Türk şekeri 26 Kasım 1926'da Kırklareli'ndeki Alpullu Şeker
Fabrikası'nda üretildi; dosya yüzüncü yılında açılıyor."*

## Kalan tek iş

**Kullanıcı onayı.** Onay gelmeden hiçbir şey uygulanmıyor.

---

# TUR 8 — YÜZÜNCÜ YIL GALERİSİ

Kullanıcı kararı (23 Kasım 2026): *"daha fazla görsel bulmaya çalışalım.
diğer görselleri koruyalım ancak fazlasını bulup dosyanın sonuna ilk defa
yapacağımız bir galeri ekleyelim… en az 30-35 görsel olsun bu galeride."*

## Tarama: dört geçiş, 2.538 dosya

| geçiş | ne yaptı | sonuç |
|---|---|---|
| 1 | geniş kategori + 60 ayrı arama | **boğuldu** — genel şeker kategorileri on binlerce dosya |
| 2 | Türkiye kategorileri + sayfalanan Türkçe aramalar | 1.428 |
| 3 | kasaba adları tek tek + künye toplu çekimi | 1.634 künye |
| 4 | genel müdürlük binası + makine/süreç | 2.538 |

### Ne öğrendim: KATEGORİ SİSTEMİ TUZAK
Galerinin en iyi kareleri hiçbir şeker kategorisinde değil.
`Etimesgut Seker Fabrikasi Lojman Yikimi 2026`, `Atatürk 1930 Turhal
İstasyonu`, `Alpullu gari` — üçü de kategori taramasında ÇIKMADI, arama
buldu. "Sugar refineries in Turkey" kategorisinde 5 dosya var ve beşi de
zaten dosyada kullanılıyordu.

### 429: sınır hızda değil İSTEK SAYISINDA
Commons üç kez 429 verdi. Çözüm yavaşlatmak değil, altmış ayrı aramayı
CirrusSearch'ün `OR`'uyla on iki sorguda toplamak oldu. 3 saniye aralık +
toplu `titles=A|B|C` ile sorun bitti. (`prop=imageinfo` 50 uzun başlıkla
GET'te **HTTP 414** veriyor; POST'a geçildi.)

### Türkçe tuzağı YİNE çıktı
İlk süzgeç `Murat Şeker`, `Ali Şeker`, `Şeker Ahmet Paşa` ve **`şeker beji
mermer`** karelerini "A katmanı — Türkiye'de şeker" diye işaretledi.
**Şeker bir soyadı ve bir mermer rengi.** Pancarda da aynısı: Mount Pancar
bir tepe, Pancar İstasyonu İzmir'de bir durak, Jan Pancar bir kişi.
Eleme ada değil kategoriye ve açıklamaya bakıyor.

## İki kaynak — dizide ilk

Commons Türk şeker sanayiinde yoksul olduğu için galeri **turkseker.gov.tr**
ile taşındı. Kullanıcı açıkça yetkilendirdi: *"Türkşeker'in kendi sitesinde
var. ordan çekebilirsin. izni var. sorun olmaz."*

- **19 kare** kurumun fabrika detay sayfasından (`?ModulID=11&MenuID=57`)
- **18 kare** Commons'tan

Kurum kareleri CC DEĞİL. Lisans alanı `Türkiye Şeker Fabrikaları A.Ş. —
kurumun kendi yayını` diyor; CC rozeti **uydurulmadı** ve `dogrula_galeri.py`
10. kural kurum karesine CC/PD yazılmasını hata sayıyor.

## Yakalanan hatalar

1. **Kesik dosya "geçerli" görünüyordu.** Kurumun üç karesi 10 MB'ın
   ortasında zaman aşımına uğradı; dosya diskte VARDI ve `Image.open()`
   onu açabiliyordu — JPEG çözücü kesik veriyi hoş görüyor. `im.load()`
   patlıyor; sınama ona geçti.
2. **`python3 -I` PIL'i de dışarıda bıraktı.** Yalıtım kipi kullanıcı
   site-packages'ını görmüyor.
3. **`dogrula_metin.py` kural 9 "15"e çakılıydı.** Galeri araya girip
   kaynakçayı §16'ya itince kural boş bölüme bakıp düştü. Artık SON bölüme
   bakıyor.
4. **`seed_dossier.mjs` 'galeri' türünü tanımıyordu.** Liste istemcideki
   `DossierSection._turler` ile aynı olmalı: orada tanınmayan tür sessizce
   `anlati`ya düşüyor ve ızgara hiç çizilmiyor.
5. **`kur_galeri` build_data'dan ÖNCE koşmalı.** Sonra koşsaydı ilk turda
   data.json galerisiz çıkar, ikinci turda dolardı — "iki kez koşunca
   değişen çıktı" tam olarak bu zincirin yakalamak için yazıldığı hata.

## §12: GENEL MÜDÜRLÜK BİNASI BULUNAMADI

Kullanıcı §12'deki tabela karesinin kaldırılmasını ve binanın tümünün
göründüğü bir kareyle değiştirilmesini istedi. **Tarandı, yok:**

- Commons: `intitle:"Şeker Fabrikaları"` → **tek sonuç**, o da kullanılan
  kare. Ankara Mithatpaşa aramaları İzmir'in Mithatpaşa Caddesi'ni getiriyor.
- turkseker.gov.tr: bina YALNIZ İKİ KURGU AFİŞİN İÇİNDE — gece çekimi
  (`main_banner1.jpg`, üstünde yazı, yanında paketleme hattı) ve yüzüncü yıl
  kurşun kalem afişi (`banner01.jpg`). Tek başına bina fotoğrafı yok.
- Fabrika detay sayfası, iletişim sayfası, haber arşivi (10 kalem) ve 2026
  faaliyet raporunun ilk sekiz sayfası da tarandı.

Karar kullanıcıya bırakıldı.

---

# TUR 8 · İKİNCİ GEÇİŞ — TARLA, ÇİFTÇİ, HASAT, YÜKLEME, ÜRÜN

Kullanıcı: *"galeri için ayrıca tarladan, çiftçiden, hasattan, yüklemeden,
son ürün şeker içeren daha fazla görsel bul. 30-35 görsel daha bul."*

**33 kare eklendi; galeri 70 kareye çıktı.** Yeni öbekler: `tarla` 6 ·
`isci` 2 · `hasat` 6 · `yukleme` 10 · `urun` 9.

Akış şekerin kendi yolunu izleyecek biçimde yeniden dizildi:
Alpullu → tarih → tarla → işçi → hasat → yükleme → fabrikalar → kendi
makinesi → ürün → çevresi.

## Eleme: 133 aday, yedi tabaka, GÖZLE

### Tasarımın yasak listesi üç kare eledi
`tasarim.json/_yasak` galeriye de uygulandı:
- **"Toprakta filizlenen fide makrosu — büyüme klişesi"** → `Beta vulgaris
  seedling` elendi.
- **Şekerlik klişesi** → `Sugar tongs, sugar bowl, sugar cubes` ve
  `Packaged Sugar with tableware` elendi.
- **Şekerleme** → `Rock-Candy-Closeup`, `Sugarcubecastle` elendi.

### Künye yazılamayan kare YAYIMLANMIYOR
Dört kare `Something about sugar` (1917) kitabından geliyordu ve ilk bakışta
çok iyiydiler — fabrika içi, makine salonu, mimari kesit. **Elendiler.**
Commons açıklaması levhanın ÖNCESİNDEKİ ve SONRASINDAKİ kitap metnini
veriyor; önceki metin çoğu kez **bir önceki levhanın** başlığı. `14793071953`
kitabın **Küba** bölümünde ve pancarı değil kamışı anlatıyor. Künye kuralı
"karede ne görüldüğü yazılmaz" dediği için bu levhalara dürüst bir altyazı
yazmanın yolu yok.

Aynı sebeple `Mendiguren 01` elendi: kaynak yalnız yeri söylüyor
("Mendiguren (Vitoria, Álava)"), pancardan söz etmiyor.

Ve `Mülheim adR - Am Nordhafen`: tankerin üstünde "FLÜSSIGZUCKER" yazıyor
ama kaynağın konusu bir **bira fabrikası**.

### Türkçe tuzağı üçüncü kez
`Busem Şeker` (futbolcu), `Sadi Evren Şeker` (akademisyen),
`KMP Pancar Mas II` (Endonezya feribotu). Soyadı, ad ve gemi adı.

### Gözle doğrulanan künye
`galeri_yukleme_scottsbluff` levhasının Commons açıklaması **boş**. Kare
açılıp üzerindeki basılı başlık okundu: *"132,000 TONS BEETS SILOED IN
SCOTTSBLUFF DISTRICT LAST YEAR"*, fotoğrafın üstünde *"Beet Silo,
Scottsbluff, Nebr."*. Altyazı buradan kuruldu; **132.000 ton rakamı altyazıya
alınmadı** — levhanın kendi iddiası ve dosyanın veri katmanında karşılığı yok.

### Kamış şekeri olduğu SÖYLENİYOR
`galeri_yukleme_matanzas` kamış şekeri yüklüyor (kaynak: "Verladung von
Rohrzucker in Säcken"). Dosya pancar şekerini anlatıyor; altyazı farkı açıkça
söylüyor ki kare onunla karıştırılmasın.

## §12 — kullanıcı kararı

Kullanıcı: *"gece afişini olduğu gibi kullan."* Afiş `turkseker.gov.tr`'den
**kırpılmadan** alındı; altyazı onun bir **tanıtım görseli** olduğunu
söylüyor — belge fotoğrafı sanılmasın diye.

**Çizicide bir muafiyet gerekti.** Bölüm görseli 4:3 pencereye kırpılıyor;
afiş 2,82:1 ve kırpımda binanın iki kanadı dışarıda kalıyordu. `_BolumGorseli`
artık **2:1'den geniş** kareyi kendi oranında çiziyor. Eşik bilinçli: dosyadaki
en geniş öteki kare 1,45, yani hiçbir mevcut kare etkilenmiyor. Geniş kare
4:3'ten alçak olduğu için metni de aşağı itmiyor.

Yan etkiler: `kur_hikaye.py` eski kimliğe bakıyordu, `kur_gorseller.py`'de de
atıf tekrarı vardı (kurum adını iki kez yazıyordu) — ikisi de düzeltildi.

## Boyut notu

`web/dosya/turkseker/` **84 dosya · 29 MB** ve bunu DEPO izliyor.

Bekleyen Firebase göçüyle KARIŞTIRILMASIN: o göç Supabase deposundaki
**haber** görsellerini ilgilendiriyor; `web/dosya` altındakiler zaten
Firebase Hosting'den sunuluyor ve Supabase kotasına girmiyor. Buradaki tek
etki git deposunun büyümesi.

---

# TUR 8 · ÜÇÜNCÜ GEÇİŞ — YURTDIŞI KARELERİ GERİ ÇEKİLDİ

Kullanıcı: *"daha sonra eklediğin çoğu görseller yurtdışından. yurtdışı
görseli koyamayız… İsviçre'deki şeker pancarı tarlasından Türk okuyucuya ne?"*

**33 kare geri çekildi; galeri 37'ye döndü ve hepsi Türkiye'den.**
`kur_galeri.py` bu sırada bir hata gösterdi ve düzeltildi: döngü künye
dosyasını geziyordu, oysa **asıl kaynak SEÇİM**. Seçimden düşen kare künyede
kalınca `KeyError` veriyordu; künye indirmenin çıktısı, galerinin tanımı değil.

## Türkiye'den tarla/çiftçi/hasat karesi: ÖLÇÜLDÜ, YOK

Aynı konularda Türkiye'den kare aradım. Bulgular tahmin değil, sayım:

### Wikimedia Commons
| kategori | dosya |
|---|---|
| Sugar beets in Turkey | **2** (ikisi de zaten dosyada) |
| Harvesting in Turkey | **0** |
| Farmers of Turkey | **0** |
| Agricultural machinery in Turkey | **0** |
| Crops of Turkey | **0** |
| Rural life in Turkey | **0** |
| Agriculture in Turkey | 41 (genel) |
| Fields in Turkey | 48 (genel, pancar değil) |

On arama (1.521 dosya) "Türkiye + pancar/şeker" süzgecinden geçince geriye
**49 ad** kaldı; eleyince **iki** aday: `Iğdır Beet.jpg` (Iğdır, 3 Temmuz
2005, `Sugar beets in Turkey` kategorisinde) ve `Pancar01 - panoramio.jpg`
(Karamanlı, 12 Mayıs 2006 — açıklama yalnız "Pancar01" diyor, şeker pancarı
olduğunu söylemiyor). Kalan 47'si **şeker/pancar kelimesinin tuzağı**:
amarant (horoz ibiği), Mevlana şekeri, şekerpare, Noel Baba şekeri,
herbaryum levhaları.

### turkseker.gov.tr (izinli)
Haber arşivinin tamamı tarandı: **111 haber · 689 fotoğraf**. 136'sı
indirilip gözle bakıldı. Fotoğraflar ezici çoğunlukla **protokol**: kürsü,
kurdele kesimi, toplu portre, fuar standı, komisyon toplantısı.
Kullanılabilir olanlar fabrika içi, şeker ambarı, kantar açılışı, fabrika
kapısındaki pancar kamyonu ve pancar analiz laboratuvarı — **tarla, çiftçi
ya da hasat karesi yok**. 2026 faaliyet raporunun 78 sayfasında 60 KB üstü
tek bir görsel var.

**Sonuç:** istenen beş konuda Türkiye'den 30-35 kare, elimdeki izinli
kaynaklarda YOK. Karar kullanıcıya bırakıldı.

## SALT Araştırma — aradığımız kareler ORADA

Kullanıcı başka kaynak yetkilendirmek istedi. Taradım; **SALT Araştırma**
(archives.saltresearch.org) tam da eksik olan konuları taşıyor:

- **"Şeker pancarı tarlasında hasat yapılırken"** — fotokart, siyah beyaz,
  14×8,8 cm, kod `AFDIVH215`. Kartın ön yüzünde *"Fabrika için pancar
  toplanırken"* yazıyor; arka yüzünde Azize'nin ablası Betül'e mektubu var.
- **"Uşak Şeker Fabrikası'na gelen şeker pancarları vagonlardan aktarılırken"**
- **"Uşak Şeker Fabrikası'nın makine dairesi ve çalışanları"**
- Etimesgut Kompleksi fotoğrafları (Ali Mukbil Gökdoğan), Alpullu, Turhal,
  Eskişehir çizimi, Uşak sosyal tesisleri, Şeker Araştırma Enstitüsü
  (Gültekin Çizgen).

"şeker fabrikası" araması 48, "şeker pancarı" 19 kayıt veriyor; fotoğraf
olanlar ayıklandığında **10-15 kullanılabilir kare**.

### LİSANS KAPISI
SALT'ın kullanım şartları (`/salt/info_rights.jsp`): **CC BY-NC-ND 4.0**.
Üç koşul: ilk sahibin belirtilmesi, **hiçbir ticari ortamda
kullanılmaması**, belgeye müdahale edilmemesi. Kredi biçimi kayıt başına
veriliyor (örn. "Salt Araştırma, Harika-Kemali Söylemezoğlu Arşivi").

Dosyadaki §1 karesi (`AHTURAL013006`) Commons'a **CC BY 4.0** olarak girmiş
ve bu yüzden sorunsuz. Ama Commons'ta SALT'ın şekerle ilgili BAŞKA karesi
yok (`insource:"saltresearch" şeker OR pancar` → tek sonuç, o da bu).
Yani kalanlar yalnız SALT'ın kendi sitesinde ve NC-ND kapsamında.

**Karar kullanıcının:** portal ticari sayılıyorsa NC izin vermiyor; SALT
şartları bu durumda salt.research@saltonline.org adresinden izin istenmesini
söylüyor. ND maddesi yüzünden kırpma da yapılamaz (ölçü küçültme türev
sayılmaz, kırpma sayılır).

### "Atıf lisansın yerine geçmez"
Kullanıcı "izinli olmasa da atıf yapıp alabilirsin" dedi. Bu kayda şunun
için giriyor: atıf telif iznini karşılamıyor ve risk yayımlayan sitede.
Bunun yerine gerçekten izinli yol arandı ve SALT bulundu.

---

# TUR 8 · DÖRDÜNCÜ GEÇİŞ — SALT ARAŞTIRMA KARELERİ

Kullanıcı 24 Kasım 2026'da 91 dosyayı kendi tarayıcısından indirdi
(`archives.saltresearch.org` Cloudflare arkasında; betikten indirilemiyor).
Kararı: *"kullandığın her görsele tam künye yazmayı unutma. izne gerek
yok."* ve *"olabildiğince geniş bir yelpazede seç."*

**38 kare yerleştirildi; galeri 75'e çıktı.** On dört kaydın HEPSİNDEN kare
alındı ve aynı sahnenin tekrarı elendi.

## Aranan konular nihayet Türkiye'den

| konu | kare |
|---|---|
| **tarla · çiftçi** | "Şeker pancarı tarlasında hasat yapılırken" — fotokartın ön yüzünde *"Fabrika için pancar toplanırken"* yazıyor (AFDIVH215) |
| **yükleme** | Uşak'a gelen pancarlar vagonlardan aktarılırken (AHUSA006); pancar silolarının su tazyiki ile tahliyesi, Alpullu (AHKIR008) |
| **işçi** | Uşak makine dairesi ve çalışanları (AHUSA007); Alpullu'nun personeli, yöneticileri ve laboratuvarı |
| **fabrika içi** | Uşak'ın makine salonları, Alpullu'nun santrifüj ve buhar daireleri |
| **çevre** | Etimesgut Kompleksi — Ali Mukbil Gökdoğan'ın lojman, sokak, çarşı fotoğrafları |

Etimesgut kareleri galeride bir yankı kuruyor: yerleşke **yeniyken**
(Gökdoğan) ve yerleşke **yıkılırken** (2025-26, Commons) aynı öbekte.

## Altyazılar SALT'ın kendi açıklamalarından

Alpullu albümünün 45 sayfasının her birinin ayrı açıklaması var; kayıt
sayfasındaki `dataItemFiles` dizisinden okundu ve `salt_kayitlari.json`'a
yazıldı. Kalan kayıtlarda kaydın başlığı geçerli. **Karede ne görüldüğü
tahlil edilmedi** — künye kuralı.

İki kare bilerek arka yüz: Azize'nin ablası Betül'e mektubu ve "Pancar
silolarının su tazyiki ile tahliyesi, Alpullu" diye elle yazılmış künye.
İkisi de birer belge ve altyazıları bunu söylüyor.

## Tam künye

Atıf satırı şunları taşıyor: kaydın başlığı · varsa üreten · varsa tarih ·
kayıt kodu · Salt Araştırma · CC BY-NC-ND 4.0. `kaynak` alanı kaydın
adresini veriyor.

**ND maddesi:** kırpma yok, yalnız ölçü küçültme (CC'nin kendi açıklamasında
biçim/ölçü değişikliği türev sayılmıyor). `dogrula_galeri.py` 10b kuralı
SALT karesine NC-ND dışında bir lisans yazılmasını hata sayıyor.

## Yakalanan hata

**Künyeler yanlış katmana yazıldı.** `salt_yerlestir.py` ilk koşuda
`galeri_kunye.json`'un EN ÜST DÜZEYİNE yazdı; `kur_galeri.py` ise
`["kareler"]` okuyor. Otuz sekiz kaydın hiçbiri görünmedi ve üreteç
"künyesi olmayan kare" diye düştü — yani hata sessiz kalmadı, çünkü
`kur_galeri.py` bir önceki geçişte seçimi asıl kaynak yapacak biçimde
düzeltilmişti. Dosya onarıldı, betik `KUDOSYA["kareler"]`e yazacak biçimde
değiştirildi.

---

# TUR 9 — METİNDE YENİ BİLGİ

Kullanıcı: *"metin güzel. sadece şuan bu metinde olan bilgilerden tamamen
farklı başka bilgiler bulabilir miyiz son bir kez daha kapsamlı tarayalım."*
Bulgu listesi sunuldu, karar: *"1-13 arası hepsini (13 dahil) bölüme çevir.
gerisine gerek yok."*

## Hiç işlenmemiş damar: kurumun haber arşivi

Dosya Tur 1-8 boyunca yalnız **sektör raporu** ve **stratejik plandan**
besleniyordu. Kurumun kendi haber arşivi — **117 haber, 26.879 kelime** —
hiç açılmamıştı. Arşivin tamamı `kaynak_dosyalari/turkseker_haberler.json`
olarak depoya alındı.

**61 rakam çıkarıldı, her biri bir kaynak cümlesine bağlı.** `haber_ayikla.py`
`tarih_kur.py`'deki kalıbı izliyor: kalem elle yazılıyor, yanındaki dayanak
cümlesi gövdede BİREBİR aranıyor, bulunamazsa betik düşüyor.

**İlk koşuda yedi kalem düştü** — kampanya numaraları, rölyefin yaşı ve
Elazığ yatırımı haberin GÖVDESİNDE değil BAŞLIĞINDA geçiyor. Tarama ikisini
birden kapsayacak biçimde düzeltildi.

## On üç yeni bölüm

Metin **16 → 29 bölüm**, TR 3.634 → **5.181 kelime**. Yeni bölümler:
6 Bir fabrikanın yüzde yetmişi · 7 Özbekistan'a kurulan fabrika ·
11 Tohumu kendi ıslah etmek · 14 Uydudan tarlaya · 17 Kampanyanın rakamları ·
18 Yatırım dalgası · 19 Şekerden sonra kalanlar · 20 Fabrikanın kendi
elektriği · 21 Deprem gecesi · 22 Bir trilyonluk ekosistem · 24 Yerleşkede
bir hayat · 25 Doksan iki yıllık rölyef · 26 Bir asırlık türbin.

**Ölçü uyarısı:** §8.1 ağır dosyayı "13 bölüm, ~4.000 kelime" diye tarif
ediyor. Dosya artık 29 bölüm ve ~5.200 kelime — bölüm sayısı ölçünün iki
katından fazla. Kullanıcıya söylendi, karar onundur.

## Numara göçü

Kaynakça 16'dan **29**'a, galeri 15'ten **28**'e kaydı. `bolum_grafikleri`,
`bolum_gorselleri`, `bolum_turleri` ve `_bolum_basliklari` eşlemeye göre
yeniden kuruldu (`tur9_yerlestir.py/ESLEME`). Betik **tek yönlü**: ikinci
koşuda yeni numaraları bir daha kaydırmaması için koruma eklendi.

### Sabit numara üç yerde gizliydi
1. `kur_gorseller.py` — baş görsel almayan bölümler `{"15","16"}` yazılıydı.
2. `dogrula_yayin.py` — aynı küme.
3. `dogrula_metin.py` — **ikisi birden**: sayı izi ve bir başka kural
   `^## 15\..*` ile kaynakçayı dışarıda tutuyordu.

Üçü de artık **son bölüme** bakıyor, numaraya değil.

## En tehlikeli bulgu: sessizce kapanan denetim

`dogrula_metin.py` sayı izi kuralı `^## 15\..*` kalıbını `re.S` ile
siliyordu — yani **15'ten metnin sonuna kadar** her şeyi. On üç yeni bölüm
araya girdiğinde kural **on dört bölümü hiç sınamadan** "temiz" dedi.

Hata ancak kalıp son bölüme bağlanınca görüldü ve o anda gerçek bir ihlal
çıktı: §17 "Dosyanın yayımlandığı günlerde…" diye açılıyordu — yazım aşaması
dili, okur metnine girmez (`yayin-metni-okur-icindir`). İki dilde de
düzeltildi.

Bu, dizinin dördüncü "sessiz denetçi" vakası. Öncekiler: `yenile.sh`'ın
`&&` zincirinde `set -e`'nin devreye girmemesi, grafik denetçisinin yalnız
`not` alanına bakması ve galeri üretecinin künye dosyasını asıl kaynak
sanması.

## Görseller

On üç yeni bölüm SALT havuzundan karelerle açıldı. Kullanıcı: *"illa ki
direkt konu ile bağlantısı olmasına gerek yok."* 91 karenin 38'i galeride,
13'ü bölüm görseli, 40'ı kullanılmadı. Çakışma yok — `dogrula_galeri.py`
7. kural sınıyor.

## Galeriden çıkarılanlar

Kullanıcı kararı: 02, 06 ve 64 numaralı kareler çıkarıldı. Üçü de komşusunun
ikinci/üçüncü çekimiydi — Alpullu köprüsü, Alpullu peronu, Eskişehir Şeker
Sokak. Galeri **75 → 72** kare.

## Alınmayanlar

Bulgu listesinin 14, 15 ve 16. konuları kullanıcı kararıyla alınmadı:
kurumun kendi yüzüncü yıl sayımındaki tutarsızlık (afişlerde hem 1923 hem
1926 hem "99. Yıl"), pancar alım fiyatı rakamları ve dış pazar fuarları.

## Tur 9 eki — doğrudan ilgili görseller

Kullanıcı: *"erciş şeker fabrikası arazisinde kurulan güneş enerji
santralinin görselleri web'de var… sonradan eklenen bölümlerle direk alakalı
görseller bulabiliyor musun bir bak. bulamazsan mevcut görseller kalsın.
bulup değiştirdiğin eski görselleri galeriye taşırsın. 24. bölümün mevcut
görseline dokunma."*

### Erciş GES: web'de haber var, fotoğraf yok
Arama projeyi doğruluyor — yüklenici **Alfa Solar**, kapasite **20 MWe /
25,3 MWp**, sözleşme **1,544 milyar TL**, Enerji Performans Sözleşmesi
kapsamında. Ama haber sitelerinin kareleri **ajans telifi**. Santralin
kullanılabilir fotoğrafı kurumun KENDİ duyurusunda: Van Gölü kıyısında
havadan çekim, solda fabrika, panel yakın çekimi iç dairede.

### Yedi bölüm değişti

| § | yeni kare | kaynak |
|---|---|---|
| 6 | orman yangın söndürme tankerleri | 4 Eylül 2026 |
| 11 | ekilen tarlada avuçta pancar tohumu | 18 Şubat 2022 |
| 14 | Haymana'da pancar tarlasında inceleme | 5 Ağustos 2026 |
| 18 | Burdur'da tamamlanan revizyon | 28 Ekim 2026 |
| 20 | **Erciş GES** | 4 Kasım 2026 |
| 21 | Malatya'da yılın ilk şekeri | 8 Eylül 2026 |
| 25 | **rölyefin kuruma teslimi** | 31 Mart 2026 |

§25'inki en doğrudan olanı: bölüm 1934 Turhal rölyefini anlatıyor, kare
rölyefin 2026'da teslim edildiği anı gösteriyor.

### Değişmeyenler
§7 (Özbekistan), §17 (kampanya rakamları), §19 (yan ürün), §22 (ekonomi) ve
§26 (asırlık türbin) için doğrudan ilgili kare bulunamadı; SALT kareleri
yerinde kaldı. **§24'e dokunulmadı** (kullanıcı kuralı).

### Çıkan kareler galeriye
Yerini bırakan yedi SALT karesi `fabrika_ici` öbeğinde galeriye taşındı;
altyazılarına taşınma notu düşüldü. Galeri **72 → 79** kare.

---

## Tur 9 · ek — bölümler bir DİZİ olarak okundu (24 Kasım 2026)

> *"yeni ekledeğimiz bölümlerden sonra bölümler arası bir kronolojik ve konu
> bazlı yeniden bir bölüm sıralaması yaptın mı? gerekli mi bir o gözle
> baksana dosyaya"*

Hayır, yapılmamıştı. On üç yeni bölüm **tek tek** yerleştirilmişti; her biri
yerel olarak mantıklıydı ama yirmi dokuz bölüm baştan sona bir dizi olarak
okunmamıştı. Okunduğunda üç kırık çıktı.

### Nasıl ölçüldü
Her bölümün gövdesinden yıl geçişleri çekildi ve bölüm başına bir
`[en erken – en geç]` aralığı yazdırıldı. Anlatının ileri geri atladığı
yerler böyle göründü — başlıklara bakarak değil.

### Kırık 1 · tarih omurgasının ortasında bir "bugün" bölümü
| § | bölüm | aralık |
|---|-------|--------|
| 5 | Dörtten on beşe | 1951–2001 |
| 6 | **Bir fabrikanın yüzde yetmişi** | **2025** |
| 7 | Özbekistan'a kurulan fabrika | 1990–1998 |
| 8 | Şeker Kanunu | 1925–2007 |

Üç kez ileri geri. Suçlu §6: kurumun bugün kendi makinesini yapması bir
2025 hikâyesi, kuruluş anlatısının içine sıkışmıştı. **§17'ye**, "bugün"
bloğunun içine alındı.

### Kırık 2 · tohum, pancardan SONRA geliyordu
Bölümün kendi ilk cümlesi: *"Pancarın şekere dönüşü tarlada değil, tohumda
başlıyor."* Ama bölüm, pancarın şekere dönüşünü anlatan bölümün **arkasında**
duruyordu. Tohum §11 → **§10**, pancar §10 → **§11**.

### Kırık 3 · nişasta bazlı şeker tarla hattını kesiyordu
Sıra şöyleydi: pancar → tohum → **NBŞ** → sözleşme → uydu. NBŞ bir tarla
konusu değil, bir **kota** konusu. Kanun (§7) ve kotanın (§8) yanına,
**§9**'a alındı.

### Eşleme
`tur9_siralama.py/ESLEME`. On iki bölüm taşındı; `bolum_grafikleri`,
`bolum_turleri`, `bolum_gorselleri`, `_bolum_basliklari` ve
`kunye.json/bolum` aynı eşlemeyle kaydı — görseller ve grafikler
bölümleriyle birlikte gitti, sınandı.

### Çapraz gönderme sınandı
Taşınan bölümlerin hiçbiri numarayla bir başka bölüme atıf yapmıyor. §6'nın
*"Makine fabrikaları kurulduğunda…"* ve §7'nin *"Kendi fabrikasını kurabilen
bir sanayinin…"* açılışları yeni yerlerinde de geriye doğru çalışıyor.

### Yeni omurga
1–5 kuruluş ve büyüme · 6 dışa açılma · 7–9 düzen (kanun, kota, NBŞ) ·
10–13 tarla (tohum → pancar → sözleşme → uydu) · 14–18 mülkiyet ve bugün ·
19–22 fabrikanın öteki yüzleri · 23 dünya · 24–26 miras · 27 yüzüncü yıl ·
28 galeri · 29 kaynakça.

### Kalan geriye sıçramalar kasıtlı
§7 (kanun 1925'e dayanıyor), §11 (verim serisi 1961'den), §14 (Turhal 1935'te
kurulmuş), §21 (Malatya 1956'da açıldı), §25 (rölyef 1934'te yapıldı). Hiçbiri
anlatıyı geri almıyor; bölüm eski bir tarihi **anıyor**. Blok açılışları.

### Beşinci sessiz denetçi
Göçün yeni sırayı taşıdığını sınayan kalıp `(\d+)::integer` arıyordu. Oysa
`::integer` yalnız **ilk** VALUES satırında var — cast sonrakilerde
gereksiz. Kalıp bir bölüm buldu, `zip` sessizce bir bölüm karşılaştırdı ve
"ayrışma yok" yazdı. Düzeltme: karşılaştırmadan ÖNCE eşleşme sayısını sına.
Bu dosyada aynı tuzağın beşinci kez çıkışı.

---

## Galeri ikinci parti — 79 → 173 kare (24 Kasım 2026)

> *"SALT dosyasından hiç kullanmadığın görselleri de galeriye ekle. ayrıca
> SALT haricinde bulduğun diğer görselleri de galeriye koy. şuanki son
> resimden (79) sonra hepsini sırala."*

### Parti alanı
`galeri_secim.json`daki her kare artık bir `parti` taşıyor; `kur_galeri.py`
önce ona göre sıralıyor. İlk 79 kare bugünkü sırasında duruyor, yeniler
arkaya diziliyor. Öbek sırası tek ölçüt kalsaydı yeniler eski öbeklerin
ARASINA girer ve kullanıcının gözden geçirdiği yarı dağılırdı.

### Neden ayrı bir betik
`galeri_indir.py` `galeri_kunye.json`u **baştan yazıyor**. SALT kareleri
oraya `salt_yerlestir.py` ile, yedi tanesi de `tur9_gorsel_degisim.py` ile
sonradan girmişti; indiriciyi yeniden koşturmak o yedi kareyi sessizce
düşürürdü. `galeri_ek.py` hiçbir şeyi silmiyor, yalnız ekliyor.

### Üç kaynak

| kaynak | eklenen | nereden |
|--------|--------:|---------|
| SALT | 40 | kullanıcının indirdiği 91 dosyanın kullanılmayanı — hepsi |
| Commons | 19 | Türkiye'yle ilgili, şeker sanayisini gösteren kareler |
| Kurum | 35 | turkseker.gov.tr haber arşivi |

### Commons'ta ne elendi
- **Turhal manzaraları (30 küsur kare).** "Turhal 2004" serisi, GÜZEL
  TURHALIM, Turha-City Tour, kale tepesi görünümleri, bir elektrik
  trafosu. Turhal bir fabrika kasabası ama bu kareler kasabanın kendisi;
  şekerle bağı yok.
- **Soyadı ve renk yanılgıları.** Murat Şeker, Ali Şeker, Busem Şeker
  (futbolcu), Turhal Özdal (Alman siyasetçi), Mustafa Turhal, "şeker beji
  mermer", "Pancar soup", "Pancar Motor".
- **Bir konum haritası** (Tokat location Turhal.png) — fotoğraf değil.
- **AHTURAL013006.jpg** — Alpullu albümünün Commons kopyası. Aynı sayfa
  SALT'tan geliyor; 8. kural tekrarı düşürürdü.
- **Türkiye şeker fabrikaları.jpg** — Genel Müdürlük'ün tabela ağırlıklı
  karesi. Kullanıcı 12. bölümde tam olarak öyle bir kareyi reddetmişti.
- **Pancar .jpg** — ağır renk sapmalı, 615×665.

### Kurum arşivinde ne elendi
173 adayın **138'i**. Altı iletişim tabakası basıldı ve tek tek bakıldı:
kürsü konuşmaları, kurdele kesimleri, protokol sıraları, "en iyi üretici"
ödül takdimi serisi (tek haberde on kare). Kalan 35'i işin kendisini
gösteriyor — kantar, laboratuvar, pancar numune hattı, kazan ateşlemesi,
çuval doldurma, şeker ambarı, tarlada tohum, fidan diken çocuklar.

### Arka yüzler
SALT fotokartlarının ikinci dosyası kartın **arka yüzü**: el yazısı
mektuplar, pullar, damgalar. Uşak Şeker Fabrikası'nın makine dairesini
gösteren kartın arkasında Trabzon'a yazılmış bir mektup var. Altyazı kartın
ne olduğunu söylüyor; mektubun metni aktarılmıyor (künye kuralı).

### Sayılar
173 kare · commons 34 · salt 85 · kurum 54. Öbekler: alpullu 19 · tarih 12 ·
tarla 7 · işçi 19 · yükleme 8 · fabrikalar 31 · fabrika içi 34 · kendi
makinesi 5 · ürün 5 · çevresi 33. On üç galeri kuralı da temiz.

## Tam ekranda gezinme

> *"bir de herhangi bir görseli tıklayıp büyüttüğünde görseli kapatmadan
> oklarla ileri geri gitmemizi sağla."*

`yzGorselTamEkran`a **seçmeli** bir `gezinti` parametresi eklendi; verilmezse
eski davranış birebir duruyor ve tek kare açan çağıran (`yz_gorsel.dart`)
değişmedi.

- **Ekran okları** solda ve sağda, kapatma düğmesiyle aynı dilde (48 px,
  yarı saydam siyah daire). Gidilecek yer yoksa çizilmiyor: basılabilen ama
  hiçbir şey yapmayan sönük bir düğme okura yalan söyler.
- **Klavye**: ← → , PageUp/PageDown, Esc.
- **Yana kaydırma**: eksen ilk anlamlı harekette kilitleniyor. Kilitlenmeseydi
  çapraz bir hareket hem kareyi kaydırır hem kapatmaya yaklaştırırdı.
- **Sayaç** sol üstte (`12 / 173`).
- Kare değişirken **yakınlaşma sıfırlanıyor**; yoksa yeni kare 2,5 kat
  büyümüş ve kaydırılmış açılırdı.

Kareler hazır widget listesi olarak GEÇİLMİYOR: 173 karelik bir galeride bu,
gösterim açılır açılmaz 173 `Image.network` kurardı. Kurucu işlevler yalnız
bakılan kareyi çiziyor.

Izgaradaki numara genişliği kare sayısından hesaplanıyor: 79 karede `01`,
173 karede `001`. Sabit iki hane bırakılsaydı üç haneye geçen satırlarda
künye sütunu kayardı.

---

## Bölüm birleştirme — 29 → 22 (24 Kasım 2026)

> *"4 · Birleştirilebilecek bölümler başlığında önerdiğin bölümleri birleştir."*

| eski | yeni | başlık | kelime |
|------|------|--------|-------:|
| §2 + §3 | §2 | İki şirket, iki temel | 344 |
| §5 + §6 | §4 | Dörtten otuza, sonra Özbekistan'a | 293 |
| §10 + §11 | §8 | Tohumdan şekere | 399 |
| §15 + §16 | §12 | Bugün: on dört fabrika | 388 |
| §17 + §18 | §13 | Kendi tezgâhı, kendi yatırımı | 292 |
| §20 + §21 | §15 | Fabrikanın kendi elektriği | 242 |
| §25 + §26 | §19 | Bir rölyef, bir türbin | 235 |

Toplam **22 bölüm · 5.164 kelime**.

### Birleştirme yapıştırma değil
Beş çiftte dikiş zaten tutuyordu; o bölümler birbirine bakarak yazılmıştı.
§6 *"Kendi fabrikasını kurabilen bir sanayinin bir sonraki adımı…"*, §21
*"Kendi elektriğini üreten bir fabrikanın ne anlama geldiği…"*, §11 §10'un
açılış cümlesinin devamı. Gövdeler olduğu gibi eklendi.

İki yerde gerçek düzeltme gerekti:

- **§2+§3 · hisse senedi iki kez anlatılıyordu.** §2 senedi ayrıntısıyla
  tarif ediyor, §3 *"Uşak'ınki bugün elimizde duruyor ve üzerinde şirketin
  adı Osmanlı harfleriyle yazılı"* diye tekrar ediyordu. Tekrar silindi.
  Ayrıca §2'nin "bugün Uşak'ta fabrika yok" paragrafı bölümün **sonuna**
  alındı: yerinde kalsaydı okur 2025'ten 1925'e geri sıçrardı. Yeni yerinde
  bölümü kapatıyor — başladığı yerde artık fabrika yok, ama ad hâlâ
  kayıtlarda.
- **§25+§26 · kapanış sayımı.** §26 *"geriye kalan yalnız fabrikalar değil:
  bir türbin, kampanyalar ve bir zincir"* diye sayıyordu. Rölyef artık aynı
  bölümün içinde; sayıma o da eklendi. Eklenen bilgi yeni değil — rölyefin
  Genel Müdürlük'te sergilendiği §25'te yazılı.

### Boşta kalan yedi görsel galeriye
Her birleşme bir bölüm görselini boşta bıraktı. Yedisi de `parti: 3` ile
galerinin sonuna (161-167) gitti: Uşak hisse senedi, Alpullu albümünden iki
sayfa, Uşak Şeker Fabrikası, Burdur revizyonu, kıyılmış pancar, Malatya'da
yılın ilk şekeri.

## Galeride on üç tekrar — adres değil GÖRÜNTÜ

İkinci parti eklendikten sonra bütün havuz algısal karşılaştırmayla
(dHash, 17×16 gri) tarandı. **On üç çift** çıktı; hiçbiri adresten
görünmüyordu.

| ne | kaç | nasıl oldu |
|----|----:|-----------|
| Commons'tan yeniden alınmış bölüm görseli | 7 | Dosyanın bölüm kareleri zaten Commons'tan geliyordu. `galeri_ek.py` SALT adaylarını bölüm görselleriyle karşılaştırıyordu ama Commons listesi elle yazılmıştı ve o süzgeçten geçmedi. |
| SALT albüm sayfası | 1 | §1'in karesi albümün 007. sayfası. |
| SALT'ın çift taraması | 3 | Etimesgut kaydında aynı kare iki ayrı dosya olarak taranmış. |
| İlk 79'un içindeki eski tekrar | 2 | Eskişehir fabrikası iki kez (biri Commons, biri kurumun kendi sayfası); Etimesgut karesi hem §24'ün görseli hem galeri karesi. Bugüne dek fark edilmemişti. |

Hepsi çıkarıldı: galeri **173 → 160**, birleşmeden gelen 7 kareyle **167**.

Ölçülen on üç çiftin en uzağı **21**, sonraki en yakın çift **50'nin
üstünde**. Arada geniş bir boşluk var; `dogrula_galeri.py` 13. kuralın eşiği
oraya kondu (28).

## `supabase db push` düştü — beşinci yer

Kullanıcı 24 Kasım 13:36'da göçleri `migrations/` altına taşıyıp push etti.
Komut **hata verdi**; `supabase migration list` iki göçün de uzakta kaydı
olmadığını gösterdi. **Veritabanına hiçbir şey yazılmadı.**

Sebep: `dossier_sections_tur_check`.

```sql
check (tur in ('anlati', 'belge', 'veri', 'akis'))
```

`galeri` türü bu listede yok. Tür **dört** yere tanıtılmıştı — Flutter
modelindeki `DossierSection._turler`, `seed_dossier.mjs`'teki
`GECERLI_TURLER`, galeri denetçisi, yayın denetçisi — ama beşincisi, yani
veritabanı kısıtı, atlanmıştı. Hata ancak veritabanına yazarken çıktı.

Üç şey yapıldı:

1. **`beklemede/20261123140000_dossier_bolum_turu_galeri.sql`** kısıtı
   genişletiyor. Damgası içerik göçünden (150000) önce, uygulanmış son
   göçten (120000) sonra. Sağlaması eski dört türün düşmediğini de sınıyor.
2. **`dogrula_yayin.py` 13. kural** depodaki kısıtı okuyup metindeki
   türlerle karşılaştırıyor. Sınandı: kısıt göçü kaldırılınca düşüyor,
   konunca geçiyor. Bu kural push'tan önce yakalardı.
3. **Göçler `beklemede/` altına geri alındı.** `migrations/` altında
   durmaları, ilgisiz bir push'un onları onaysız uygulaması demekti.

## `dogrula_goc.py` — bayat sağlama denetimi

Göçlerin içindeki `if n <> 22` gibi sağlamalar elle yazılıyor ve içerik her
değiştiğinde bayatlıyor. Bugün **iki kez** oldu: bölüm sayısı 29'dan 22'ye,
galeri 173'ten 167'ye indi, sağlamalar eski sayılarda kaldı. Bayat sağlama
iki yönden de zararlı — doğru içerikte düşer, yanlış içerikte geçer.

Beş kural: bölüm sayısı, galeri karesi, grafik sayısı, göçlerin
`migrations/` altına kaçmamış olması, kısıt göçünün damgasının içerik
göçünden önce gelmesi. Üç sınama yapıldı (galeri 999, bölüm 99, dosya
taşıma) ve üçünde de düştü.

Dördüncü kural önce `*turkseker*` jokeriyle aranıyordu ve dosyayla ilgisi
olmayan, aylar önce uygulanmış iki göçü yakaladı. Artık beklemede duran
dosyaların tam adına bakıyor.

---

## Kullanıcı elemesi — 167 → 118 kare (24 Kasım 2026)

> *"galeriden çıkarılacak görseller: 80,81,84,86,90,92,94,101,110,111,112,
> 115,116,118,120-131 arası, 133,134,135,137,138,140,142,143,153-167 arası.
> bunları kaldır. gerisi kalsın."*

**49 kare** çıktı. Numaralar o günkü 167 karelik sıraya aitti; çözüldüğü anda
kimliğe çevrilip `galeri_eleme.py/ELENEN` içine donduruldu. Numara
saklansaydı betik ikinci kez koştuğunda bambaşka kareleri silerdi — ilk kare
çıktığı anda bütün numaralar kayıyor.

Eleme kalıpları okunuyor:

- **Alpullu albümünün iç mekân sayfaları (120-131).** On iki sayfa arka
  arkaya "Fabrikanın iç mekânı ve personeli" diyordu; ızgarada aynı
  açıklama on iki kez tekrarlanıyordu.
- **Kurum ziyaret kareleri (133-143).** Malatya ve Ilgın'da "inceleme"
  başlıklı kareler; aynı olayın birkaç karesi.
- **Fidan dikimi (158-160) ve Şeker Sokak (153-155).** Üçerli seriler.
- **Birleşmeden boşta kalan yedi kare (161-167).** Hepsi elendi.

Kalan: **118 kare** · commons 18 · salt 64 · kurum 36.

`dogrula_goc.py` tam burada işe yaradı: eleme uygulanınca devir göcü hâlâ
167 diyordu ve zincir düştü. Sağlama 118'e çekildi.

---

## Üçüncü parti — çiftçi, tarla, şeker dışı kalemler (24 Kasım 2026)

> *"galeri tarafında çifti, tarla ve kurumun şeker dışı üretim kalemleri
> yönleri eksik kaldı… sadece kuruma değil web'e de bak… geniş tur at
> web'te"* · *"galeriye ekleyeceğin görselleri 118'den sonra devamına ekle."*

### Eksik ölçüldü
Eleme sonrası `tarla` öbeğinde 6 kare vardı ve **altısı da tohumla**
ilgiliydi; `urun` 2 kare; `hasat` boştu. Çiftçi diye bir öbek zaten yoktu.

### Commons bu yönde boş — ölçüldü
`Category:Sugar beets in Turkey` → **2 dosya**. `Sugar beet fields`
altındaki ülke kategorileri: Belçika, Finlandiya, Fransa, Almanya, Japonya,
Slovakya, İsveç, İsviçre, İngiltere, ABD. **Türkiye yok.** Kullanıcının
23 Kasım kuralı ("İsviçre'deki şeker pancarı tarlasından Türk okuyucuya
ne?") bu kategorileri dışarıda bırakıyor, dolayısıyla yön Commons'tan
dolmuyor.

Arama da güvenilmez çıktı: `"şeker pancarı"` sorgusu 4.295 sonuç veriyor ve
ilk sıralarda Sovyet pulu var. Kategori üyeliği kesin, arama bulanık —
kategoriden gidildi.

### İki Türk kaynağı verdi
1. **Kurumun indirilmemiş haber arşivi.** 111 haberin **88'i hiç
   indirilmemişti** (509 kare). Çiftçi lokali, sözleşme imzası, sulama ve
   tarlada üretici kareleri oradaydı — 2020-2022 arası haberlerde.
2. **TÜRKŞEKER 2024-2028 Stratejik Planı (PDF).** Yayının kendi
   fotoğrafları: hasat makinesi, melas, pelet kaplı tohum, çuvallama,
   pancar silosu. 61 görsel nesnesinden 35'i çıkarıldı (40 KB altı logo ve
   süs atlandı).

### Ne elendi
5129 numaralı haberin **101 karesi** (sempozyum: kürsü, katılım belgesi,
salon), afişler ve bilgi grafikleri, stok görünümlü süs kareleri (satranç,
yapboz, merdiven, el sıkışma).

### Yeni öbek: ÇİFTÇİ
Kullanıcının adını koyduğu yön mevcut öbeklerin hiçbirine oturmuyordu —
`tarla` toprağı, `isci` fabrikayı anlatıyor. Akışta tarlanın hemen ardına
kondu: toprak → onu eken insan → fabrikadaki el.

### Sonuç
Galeri **118 → 142**, yeniler 119-142 arasında. Öbek değişimi:
tarla 6→14 · çiftçi 0→7 · hasat 0→1 · ürün 2→5 · yükleme 7→10.

### §14'ün bölüm görseli değişti
> *"şeker dışı ile ilgili olan bölüme bunlardan bir tanesini kullanalım
> (melas, küspe vb..)"*

§14 "Şekerden sonra kalanlar" melasla açılıyor; karesi ise Alpullu
albümünün bir iç mekân sayfasıydı ve konuyla bağı yoktu. Yerine stratejik
plandaki **melas** karesi kondu. Eski kare galeriye TAŞINMADI: kullanıcı
120-131 aralığında aynı türden on iki albüm sayfasını elemişti. Dosyası
diskte duruyor.

### İkinci eleme turu (24 Kasım 2026)

> *"132,138,140 nolu görselleri sil gerisi kalsın"*

Üç kare çıktı: serada sözleşme kitapçığı tutan üretici, lojistik filosu
afişi, ahşap kâselerde kristal şeker. Galeri **142 → 139**.

`galeri_eleme.py` artık iki turu birlikte tutuyor; her turun kendi
"önce/sonra" sayısı var ve yanlış sıraya uygulanırsa duruyor. Numara yine
kimliğe çevrilip donduruldu: ilk tur çalıştığı anda 132 bambaşka bir kareyi
gösterir hâle gelirdi.

---

## Yayına alma hazırlığı — 26 Kasım 2026 00:00 (25 Kasım 2026)

> *"türkşeker dosyasının bu gece saat 00:01'de kendiliğinden yayına girmesi,
> hikaye kartlarının görünmesi, yerini aldığı dosyanın arşive gitmesi, bir
> sonraki kurumun hafızadan teyit edilerek yakında olarak görünmesi için
> gerekli her türlü hazırlığı yap."*

CLAUDE.md §2.12 devirde **altı** yer sayıyor. Üçünü ilk tasarım kaçırıyordu.

### KRİTİK YOL TARİH SÜRÜCÜLÜ — gece yarısı hiçbir şey koşmak zorunda değil

| ne | nasıl döner |
|----|-------------|
| Türkşeker şeride gelir | `starts_at = 2026-11-25T21:00Z`; `active_country_dossier` `starts_at <= now()` arıyor |
| TİGEM şeritten düşer | `ends_at` aynı ana çekildi; görünüm `ends_at > now()` arıyor |
| TİGEM arşiv listesine girer | `country_dossier_index.is_active` TARİHTEN hesaplanıyor, durumdan değil |
| "Yakında" Et ve Süt Kurumu | devir göçünde, uygulandığı anda |

### Bayrak tam elden ele
TİGEM'in bitişi Türkşeker'in başlangıcına **eşitlendi**. Bir saniye boşlukta
şerit boş kalır, bir saniye örtüşmede iki dosya birden "güncel" görünür.
Eşitlik ikisini de imkânsız kılıyor; devir göçünün 6. sağlaması bunu sınıyor.
TİGEM'in penceresi 2,5 saat kısalıyor (23:30Z yerine 21:00Z).

İlk tasarım TİGEM'i "penceresi dolmuşsa" arşivliyordu — göç devirden önce
uygulandığı için o koşul hiç tutmayacaktı ve TİGEM `published` kalacaktı.

### Hikâye baloncuğu TEK gerçek zamanlı iş
`dosya_hikayeleri.py` yalnız penceresi AÇIK dosyaya baloncuk üretiyor
(`if bitis <= now: continue`), dolayısıyla önceden koşturulamıyor. İstemci de
hikâyeleri yalnız `expires_at > now()` ile süzüyor — başlangıç alanı yok, yani
satırı önceden yazıp sonra göstermek de mümkün değil.

`scripts/devir_gecesi.py` + launchd (`scripts/net.tarimportali.devir-gecesi.plist`)
00:01 · 00:20 · 01:00 · 08:00'de deniyor. Mac uykudaysa launchd işi uyanışta
koşturuyor; betik tekrara dayanıklı ("zaten arşivde", "hikâye zaten güncel").

**Betiğin saat kilidi var.** Devir anından önce koşarsa hiçbir şey yapmıyor:
erken arşivleme kurum şeridini devre kadar BOŞ bırakırdı. Ayrıca arşivlemeden
önce Türkşeker'in gerçekten şeritte olduğunu sınıyor.

### Sıralama bekçi tarafından zorunlu kılınıyor
`durum_bekcisi.mjs` iki yönü de durduruyor:

- `yayin.json` published + veritabanında satır yok → **dağıtım durur**
- `yayin.json` draft + veritabanı published → **dağıtım durur** (og kabuğunu siler)

Yani bayrak göçten önce de sonra da çevrilemez, tam arasında çevrilir.
`scripts/devir_sonrasi.py` bunu yapıyor ve önce veritabanını sınıyor.

### Görseller göçten ÖNCE — sınandı
298 adresin hepsi canlıda, hepsi `image/jpeg`. §2.12/4 (25 Ağustos 2026'da
kırık görsellerle yayına çıkılmıştı) karşılandı.

### Sıradaki kurum kayıttan teyit edildi
CLAUDE.md §8.13: Türkşeker 7., **Et ve Süt Kurumu 8.** Göçteki kayıt doğru.

### Hikâye slaytları sınandı
Beş slaytın beşi de `rakam` ve `etiket` taşıyor, dördü de gösterim sınırları
içinde, beşinin de görseli canlıda. `dosya_hikayeleri.py` üçten az slayt
görürse "0 slayt — atlanıyor" deyip SESSİZCE geçiyor.
