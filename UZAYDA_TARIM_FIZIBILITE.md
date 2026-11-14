# Uzayda Tarım — Fizibilite ve Kaynak Haritası

**Durum:** Tarama bitti, inşa başlamadı. Yazıldığı tarih: 13 Kasım 2026.
**Karar verilen** (kullanıcı, 13 Kasım 2026):
- Biçim: **kendi etkileşimli bileşenleri olan bir sayfa** — ülke/kurum
  dosyalarının 18 bölümlük kalıbı değil, Turkuaz Nexus gibi kendi yapısı.
- Eksen: **Türkiye omurga + dünya gövde.**
- Bölüm sayısı: **sınır yok** — veri hacminin kaldırdığı kadar.
- Hakemli yayını olmayan Türkiye bulguları **şerhiyle birlikte** yer alabilir.
- Ege'nin domates çalışması sonuç verdiyse sonucu, vermediyse **süreci**
  anlatılır.
**Çıkış noktası:** National Geographic, Marina Koren, "Brazil space farming",
18 Ağustos 2026. Bu yazı **esin kaynağı**, veri kaynağı değil — gerekçesi
aşağıda.

---

## 0. Ölçülen mevcut durum

| Katman | Durum | Ölçüm |
|---|---|---|
| **NASA OSDR / GeneLab** | **AÇIK** · anahtarsız REST, JSON | `osdr.nasa.gov/osdr/data/search?term=&size=&type=cgene` · "plant" → **78 kürate çalışma** |
| **NASA Teknik Memorandum** | **AÇIK** · PDF indi, metni çıkarıldı | NASA/TM-20250001897 · 82 sayfa · 185.399 karakter |
| **NASA görsel kütüphanesi** | **AÇIK** · anahtarsız REST | `images-api.nasa.gov/search?q=&media_type=image` · "plant growth space station" → **441 kare**, kamu malı |
| **IAF / IAC-26 program dizini** | **AÇIK** · HTML | `iafastro.directory/iac/browse/IAC-26/A1/IP/` · en az **10 Türk bildirisi** |
| **TÜBİTAK UZAY deney sayfaları** | **KAPALI** · yumuşak 404 | HTTP **404** ama `text/html`, **330.739 bayt** gövde — durum koduna değil içeriğe bakıldı |
| **TÜBİTAK bilimteknik poster PDF** | **KAPALI** · yumuşak 404 | HTTP **404**, `text/html`, 183.958 bayt — PDF değil |
| **Wikimedia Commons** | gerekmiyor | NASA kamu malı; Commons'ın 429 derdi bu alanda yaşanmaz |

### Erişim notu
TÜBİTAK'ın iki ayrı yolu da **yumuşak 404** veriyor: durum kodu 404 ama gövde
yüz binlerce baytlık HTML. Yalnızca duruma bakan bir betik bunu "sayfa var"
sanmaz ama yalnızca gövde uzunluğuna bakan bir betik "içerik geldi" sanar.
İkisi birden sınanacak (§2.12.1 ile aynı tuzak).

**Birincil Türkiye kaynağı olarak kalan:** `axiomspace.com/research/
extremophyte-crispr` ve TÜBA'nın 13 deneyi listeleyen belgesi. İkisi de
henüz okunmadı.

---

## 1. Dosyanın omurga sayısı

NASA/TM-20250001897, Ek A ve Ek E'den **ölçülerek** okundu:

```
denenen ekin              376   (Kennedy 204 + Growing Beyond Earth 191)
CRL 3'te bekleyen         153
CRL 2'de bekleyen          47
uzayda yetişip YENEN        9
```

Dokuzun dökümü — belgedeki Tablo A-3, birebir:

| Tür | Ekin | Familya |
|---|---|---|
| Yapraklı yeşillik | 'Outredgeous' marul | Asteraceae |
| Yapraklı yeşillik | 'Waldmann's Green' marul | Asteraceae |
| Yapraklı yeşillik | Mizuna hardalı | Brassicaceae |
| Yapraklı yeşillik | 'Wasabi' hardalı | Brassicaceae |
| Yapraklı yeşillik | 'Amara' hardalı | Brassicaceae |
| Yapraklı yeşillik | 'Extra Dwarf' pak choi | Brassicaceae |
| Yapraklı yeşillik | 'Red Russian' kara lahana | Brassicaceae |
| Küçük meyveli | Española Improved biber | Solanaceae |
| Kök bölgesi | 'Cherry Belle' turp | Brassicaceae |
| **Ot** | **yok** | |
| **Mikro yeşillik** | **yok** | |
| **Baklagil** | **yok** | |

**Dokuzun yedisi yapraklı yeşillik. Tahıl yok, baklagil yok.** "Uzayda tarım"
manşetiyle fiilen yenebilmiş şey arasındaki mesafe bu.

> **BELGE KENDİ İÇİNDE TUTARSIZ.** Bir yerde "only 9 crops have passed CRL 9",
> Ek E'de "there are 10 crops that have passed CRL 9" yazıyor. Tablo A-3'te
> **dokuz** satır var. Metin hangisini kullanırsa kullansın, tutarsızlığı
> söyleyecek.

### Ölçülü eşikler — veri sayfasına girecek
Belge pass/fail ölçütlerini sayıyla veriyor:

- **CRL 3** · ISS benzeri ortam: ≈22°C, ≈%40 bağıl nem, ≈3000 ppm CO₂
- **CRL 4** · mikrobiyoloji: aerobik bakteri tek örnekte **>2×10⁴ CFU/g**
  kalır; beş örneğin ikisinde **>1×10⁴** kalır; maya ve küf **>1000 CFU/g**
  kalır. *E. coli*, koliform, *Salmonella*, *S. aureus* taranıyor
- **CRL 5** · kimya + kabul edilebilirlik: dokuz puanlık hedonik ölçekte
  ortalama **en az 6**. Radicchio **acılıktan kaldı**
- **CRL 6** · tohum yüzeyi: çimlenme **>%60** korunmalı ya da başlangıç
  çimlenmesinde **<%30** düşüş
- **CRL 9** · uzayda yetiştirip **yemek**

---

## 2. Veri katmanı — OSDR'ın gerçek şekli

"plant" sorgusu 78 kürate çalışma veriyor. Organizma dağılımı **ölçüldü**:

| Cins | Çalışma |
|---|---|
| *Arabidopsis thaliana* | **50** |
| Mikrobiyota (marul, biber, yapraklı yeşillik yüzeyleri) | 14 |
| *Fusarium* ve öteki mantarlar | 6 |
| **Gerçek ekin bitkisi** | **5** |

Beş ekin çalışması, erişim numaralarıyla:

| Erişim | Ekin | Başlık (kısalt.) |
|---|---|---|
| OSD-622 | **buğday** | Microgravity effects on leaf morphology, cell structure, carbon metabolism |
| OSD-767 | **domates** | Stress and light spectral quality influence the transcriptome of a tomato… |
| OSD-59 | lahanagiller (*Brassica rapa*) | RNA-Seq transcriptome, reactive oxygen species gene network |
| OSD-581 | İtalyan çimi | **A molecular study of Italian ryegrass grown on Martian regolith simulant** |
| OSD-375 | *Brachypodium* | Transcriptional profiling of roots and shoots |

**OSD-581 köprüdür:** Mars regolit simülantında bitki — Ege Üniversitesi'nin
domates çalışmasının doğrudan dünya karşılığı. Türkiye omurgasını dünya
gövdesine bağlayan ilk düğüm bu.

### Marul makalesi — ve içindeki ayrışma

Khodadad vd. 2020, *Frontiers in Plant Science* 11:199,
doi 10.3389/fpls.2020.00199, açık erişim. ISS'te Veggie'de yetişen
'Outredgeous' marulu, 24-72 saat gecikmeli yer kontrolüyle.

> **BU FİZİBİLİTENİN İLK SÜRÜMÜ BURAYI YANLIŞ YAZDI.** Tam metin
> okununca çıktı: **özet ile sonuçlar bölümü aynı şeyi söylemiyor.**
>
> **Özet:** *"Flight and ground tissue showed differences in Fe, K, Na, P, S,
> and Zn content and total phenolic levels…"*
>
> **Sonuçlar (Elemental Analysis):** *"There was no significant differences
> between ground and flight samples within each experiment, however when
> comparing among all three experiments, Fe and K content were significantly
> lower in VEG-03A…"*
>
> Özet farkı **uçuş ↔ yer** arasına koyuyor. Sonuçlar bölümü her deneyin
> **içinde uçuş-yer farkı OLMADIĞINI**, farkların **üç deney arasında**
> olduğunu söylüyor — yani fark uzaydan değil, hangi yetiştirme koşusunda
> olduğundan geliyor. Yayılan cümle özetinki; arama motorları ve ikincil
> kaynaklar onu tekrarlıyor, bu belgenin ilk sürümü de öyle yaptı.
>
> **Karar: dosya sonuçlar bölümünü esas alıyor.** *"Uzayda yetişen marulun
> besin içeriği değişiyor"* cümlesi bu makaleye **dayandırılamaz**;
> makalenin kendi ölçümü bunun tersini söylüyor.

Deneyler arası ölçülen farklar: Fe ve K **VEG-03A'da düşük** (P≤0,001 ve
P≤0,0001); Na, P, S, Zn **VEG-01B'de yüksek**; **Ca, Mg, Mn'de fark yok**.
Toplam fenolik VEG-03A'da en düşük — yer 15,0, uçuş 19,6 mg/g kuru ağırlık
(gallik asit eşdeğeri). Antosiyaninde üç deney arasında fark yok.
Mikrobiyal sayım 2,14-4,86 log10 CFU/g, insan patojeni çıkmamış.

Kilitli hâli: `content/uzay_tarimi/_raw/marul.json`.

---

## 3. Türkiye ayağı — iki deney, TEK görev

**Karışıklık çözüldü.** Bazı kaynaklar Extremophyte CRISPR'ı "ileride Ax-3
taşıyacak" diye yazıyor; oysa Ax-3 Gezeravcı'nın **zaten uçtuğu** görev.
İkinci bir görev yok, **ikinci bir deney** var.

### Ax-3 · 19 Ocak 2024 · ISS'te 14 gün · 13 deney

**Extremophyte** — Ege Üniversitesi Fen Fakültesi Biyoloji Bölümü.
Yürütücü **Doç. Dr. Barış Uzilday**, araştırmacı **Prof. Dr. İsmail Türkan**.

- Bitki: ***Schrenkiella parvula*** — **Tuz Gölü'ne özgü**, tuza dayanıklı,
  turpgiller (Brassicaceae). Eski adı *Thellungiella parvula*; taksonomi
  değişti, bu yüzden iki ad da dolaşıyor.
- Soru: yüksek tuzluluğa gösterdiği toleransı **çok zayıf yerçekiminde
  sürdürüyor mu**.
- Ön bulgu: tohumlar **2. ve 3. günde** çimlenmiş; bitkiler beklenen
  büyüklüğe ulaşmış; **yaprak ve gövde biçimleri mikroyerçekiminde
  farklılaşmış**.
- Örnekler Gezeravcı tarafından hasat edilip **−80°C**'de dondurularak
  Dünya'ya getirilmiş.

**Extremophyte CRISPR / CRISPR-GEM** — **Yıldız Teknik Üniversitesi**,
TÜBİTAK UZAY destekli. Mikroyerçekiminde CRISPR gen düzenleme etkinliği;
*Arabidopsis thaliana*'da **üç stres geni** baskılanıyor, iki bitkinin tuz
toleransı inceleniyor. ISS'te **6 haftalık** bitkilere uygulama yapılmış.

### Yerdeki hat — regolit simülantında domates
Ege Üniversitesi, TÜBİTAK destekli. Yürütücü **Doç. Dr. Rengin Özgür
Uzilday**; ekipte Doç. Dr. Barış Uzilday ve Dr. Tansel Kaygısız Aşçıoğul.
Proje adı: *"Ay ve Mars Regolit Simülantlarının Ekstremofit Öncül Bitkiler
Kullanılarak Tarıma Elverişli Hale Getirilmesi"*.

Yöntem iki aşamalı ve dosya için ilginç olan bu: regolit organik maddece
fakir, metal ve tuzca zengin. Ekip **önce toprağı iyileştiriyor** —
*Schrenkiella parvula*, *Arabis alpina*, *Noccaea sempervivum* gibi
ekstremofit **öncül bitkilerle** — **sonra** domates ekiyor. Bazı örneklerde
yüksek meyve alınmış.

### IAC-26 kongre programı — en az 10 Türk bildirisi
İki tanesi doğrudan Ax-3 sonuçlarını sunuyor (durum: *confirmed*):
- *"Schrenkiella parvula, an extreme halophyte preserves salt-tolerance
  programs under microgravity"* — Dr. Barış Uzilday, Ege Üniversitesi
- *"Synergistic Effects of Microgravity and Salinity on the Global Gene
  Expression of Arabidopsis thaliana: Data from ISS"* — Dr. Rengin Özgür
  Uzilday, Ege Üniversitesi

Ötekiler: buğday köklerinin doğru akım elektrik alanıyla yönlendirilmesi
(Muhammed Yücedağ), Mars'ta patatesin kuramsal temelleri (Yağmur Şenbakan),
sentetik bitki-mikrop ekosistemleri (Rana Aleyna Dal), regolitten toprağa
minimal ekosistem (Beril Sayınhan), mikroalg sistemleri (Simge Sertgümeç),
Antarktika bitkilerinin uyumu (Suveybe Yüksel), CRISPR ile mantar protein
sistemleri (Serpil Korkmaz).

**Yani bu alan Türkiye'de tek bir deneyden ibaret değil; çalışan bir
topluluk var.**

---

## 4. Mimari kararı — Türkiye omurga, dünya gövde

Kullanıcının endişesi kayda değer ve mimariyi kendisi çözüyor: *"sadece
Türkiye'de kalırsak dar ve kısır olmasından endişeleniyorum."*

Çözüm Türkiye'yi küçültmek değil, **her Türkiye kalemini bir dünya katmanına
bağlamak**:

| Türkiye omurgası | açıldığı dünya gövdesi |
|---|---|
| Tuz Gölü bitkisi ISS'e gitti | OSDR'ın tuzluluk + mikroyerçekimi çalışmaları; Dünya'da tuzlu toprak tarımı |
| Regolit simülantında domates | **OSD-581** (Mars regolitinde çim); NASA'nın 376 ekinlik eleme hattı |
| Gezeravcı'nın 13 deneyi | ISS'in bitki tarihi: Veggie, APH, CRL 9'u geçen 9 ekin |
| IAC-26'daki Türk bildirileri | aynı kongrede Brezilya, Japonya, Meksika, Peru, Azerbaycan |
| — | Chang'e-4'ün pamuk filizi (3 Ocak 2019) ve **ay gecesinde ölmesi** |

Türkiye "neden umursayalım"ı, dünya verisi "ne biliniyor"u veriyor. Ayrı
bölümler değil, **aynı bölümün iki yarısı**.

---

## 5. Tuzaklar — yazmadan önce kayıtlı

**1 · Esin kaynağı makale veri kaynağı DEĞİL.** NG yazısında ölçülmüş tek bir
verim, büyüme hızı ya da deney sonucu yok. Dahası gama ışını doz etiketlerini
**"0, 50, 100, 150, 200, 250 gram"** diye veriyor. **Radyasyon dozu gramla
ölçülmez** — birim neredeyse kesinlikle **Gray (Gy)**. Olduğu gibi
aktarılırsa hata yayılır. Makale yalnız **anlatı** için kullanılacak;
Brezilya ağının varlığı, kurumları ve yöntemi için. Rakam için değil.

**2 · Türkiye sonuçları henüz hakemli değil.** IAC-26'da iki onaylı sunum
var, **yayımlanmış makale bulunamadı**. Basın düzeyindeki bulgular ("2-3.
günde çimlendi", "biçimleri farklılaştı") **ön sonuç** diye etiketlenmeden
yazılmaz. Dosya yazılırken yeniden aranacak — Ocak 2024'ten bu yana iki yıl
geçti, makale çıkmış olabilir.

**3 · "Ay'da domates" yanlış başlık.** Deney **Dünya'da**, ABD'den getirilen
**simülantlarla** yapıldı. Haber başlıkları bunu silikleştiriyor. Metin
"simülant" kelimesini kullanacak.

**4 · Chang'e-4'ün filizi öldü.** Pamuk tohumu 3 Ocak 2019'da filizlendi ve
**ay gecesinin soğuğunu geçiremedi**. Zafer anlatısı bu düzeltme olmadan
yazılamaz.

**5 · NASA belgesi kendi içinde tutarsız** (9 vs 10 ekin — §1).

**6 · OSDR'ın "plant" sayısı yanıltıcı.** `type=cgene` süzgeci olmadan
"Arabidopsis" sorgusu 4.760 sonuç veriyor; bunlar çalışma değil örnek ve
dosya kayıtları. **Kürate çalışma sayısı için `type=cgene` şart.**

**7 · Türkçe adlandırma.** *"Mısır"* bu portalda hem ülke hem tane. Uzay
dosyasında ülke geçmeyecek ama **tane mısır** geçebilir; Mısır dosyasının
kesme işareti kuralı buraya da taşınır (`mısırın` ürün, `Mısır'ın` ülke).

---

## 6. Görsel katmanı

NASA görsel kütüphanesi (`images-api.nasa.gov`) kamu malı ve künyesi
yapılandırılmış: `title`, `date_created`, `center`, `nasa_id`. "plant growth
space station" → **441 kare**. Örnek: `KSC-20180307-PH_CSH01_0015`, PONDS
sulama sistemi, 7 Mart 2018, Kennedy.

**Avantajı Commons'a göre üç kat:** telif sorunu yok, künye alanları zaten
ayrı, ve 429 kısıtlaması yaşanmadı.

**Altyazı kuralı aynen geçerli:** altyazı **künyedir** — konu + yer + tarih,
kaynağın kendi açıklamasından. Karede ne görüldüğü yazılmaz.

Türkiye tarafının görseli ayrı sorun: Ax-3 ve Ege Üniversitesi kareleri
NASA/Axiom/üniversite elinde ve lisansları **tek tek okunacak**. "Basında
yayımlandı" açık lisans demek değildir.

---

## 7. Sonraki turlar

**Tur 7 · veri sayfasının kilidi — KOŞULDU (13 Kasım 2026)**

Çıktılar `content/uzay_tarimi/_raw/` altında, üç betik ve üç veri dosyası:

| betik | çıktı | ne |
|---|---|---|
| `osdr_cek.py` | `osdr.json` | 78 kürate çalışma · 50 Arabidopsis · **5 ekin** |
| `nasa_ekin_ayikla.py` | `ekinler.json` | 13 tablo · **419 kültivar** · CRL 9'u geçen 9 |
| `marul_ayikla.py` | `marul.json` | Khodadad 2020, özet↔sonuç ayrışmasıyla |

**Ayrıştırma iki kez yanlış sayıp düzeltildi.** İlk kalıp kültivar adı satır
sonuna taştığında satırı hiç saymıyordu (297 kültivar, dokuzu tam geçen 1).
Hata ancak belgenin **kendi Tablo A-3'üne** karşı çapraz sınama konunca
görüldü — betik kendi başına "başardım" diyordu.

**İkinci ve daha önemli bulgu: "dokuz işaret = CRL 9'u geçti" ölçütü
GEÇERSİZ.** Waldmann marulunun satırında sekiz işaret var (CRL 5 hücresi
boş) ama ekin A-3'te CRL 9 listesinde. Yani bir ürün ara düzeyi boş bırakıp
dokuzu geçmiş sayılabiliyor. **CRL 9 listesi artık çıkarımla değil, doğrudan
Tablo A-3'ten okunuyor.**

**Üçüncü ayrışma — sayım. ÖLÇÜLDÜ VE ÜÇ SAYIYA ÇIKTI.** Önce "iki sayım
tutmuyor, sebebi ölçülmedi" yazılmıştı; bölümün grafikleri kurulurken
tabloların satır numaraları sırayla sayıldı ve durum netleşti:

| sayı | nereden | not |
|---|---|---|
| **376** | belgenin kendi yazdığı toplam | sayfanın kullandığı sayı |
| **395** | belgenin kendi bileşenleri: GBE 191 + KSC 204 | belge aynı cümlede 376 yazıyor — **toplama hatası kaynağın kendisinde** |
| **419** | tabloların ayrıştırması | belgenin tür tür sayımıyla yedi tablodan **beşinde birebir** tutuyor |

Belgenin cümlesi birebir şöyle: *"the Growing Beyond Earth program has
tested 191 crops and KSC has tested 204 crops listed above and in Appendix
E (total 376)"*. Belge ayrıca tür tür sayıyor — 37 yeşillik, 10 domates,
41 biber, 16 ot, 25 baklagil, 67 mikro yeşillik, 3 çilek, 2 salatalık, 2
kavun — ki o liste de 203 ediyor, yani aynı belge KSC için iki cümlede iki
sayı veriyor (203 ve 204).

Ayrıştırma bu tür tür sayımla **domates, biber, ot, baklagil ve mikro
yeşillikte birebir** tutuyor. Tutmayan iki tablonun ikisi de açıklanabilir:
E-7'de ayrıştırma 8, düzyazı 7 diyor — düzyazı çilek/salatalık/kavun
sayıyor ama aynı tablodaki 'Cherry Belle' turbunu anmıyor, oysa o turp CRL
9'u geçen dokuz ekinden biri. E-1'de ayrıştırma 38, düzyazı 37 "yeşillik"
diyor — tabloda iki baklagil satırı var ('Dwarf Grey' Sugar Pea ve Kudzu),
düzyazının hangisini saymadığı belli değil.

**Metin rakam kullanırsa belgenin kendi sayısını (376) yazacak ve ayrışmayı
söyleyecek.** Sayfadaki "Üç ayrı toplam var ve üçü de tutmuyor" açılır notu
bunu okura anlatıyor.

**Dördüncü bulgu — ayrıştırıcı SESSİZCE SATIR DÜŞÜRÜYORDU.** 392'den 419'a
çıkışın sebebi bu. Üç ayrı kusur vardı ve hiçbiri hata vermiyordu:

1. **Sarkan kültivar kodu satır başı sanılıyordu.** `"Snap Pea/351-6-\n1"`
   içindeki `1`, yeni bir tablo satırı okunuyor ve önceki satırı ortadan
   bölüyordu; bölünen satırda familya kalmadığı için satır düşüyordu.
   E-4'ün 25 baklagilinden 21'i geliyordu. Çözüm: tablo satır numaraları
   sırayla sayılıyor, beklenen sayıyı tutmayan aday satır başı sayılmıyor.
   Aynı kural Ek E sonundaki kaynakça dipnotlarını da eliyor.
2. **Familya yalnız dilimin SONUNDA aranıyordu.** Satırın ardından sayfa
   altlığı ya da sonraki tablonun başlığı geldiğinde kalıp tutmuyordu.
3. **PDF metin katmanı bazı familya adlarının son harfini düşürüyor**
   (`Fabacea`, `Asteracea`, `Brassicacea`, `Chenopodiacea`). Kırpılmış ad
   ancak belgenin BAŞKA YERDE tam yazdığı bir familyanın ön eki ise
   onarılıyor; sözlük dışarıdan değil kaynağın kendi dağarcığından. Altı
   onarımın her biri gerekçesiyle `_ONARIM_GUNLUGU`'nda. Bir satırda
   (`Honey Snap (yellow)/274-1-2-1`) familya metinde hiç yok; tahmin
   edilmedi, **okunamadı** diye duruyor ve defterde kendi kovasında.

**Beşinci bulgu — kültivar adları SAYFADA görülerek düzeltildi.** Üçü de
hiçbir sayımı bozmuyordu, yalnız okura yanlış ad gösteriyordu: adın başında
satır numarası (`"1 'Vit Mache"` — 419 adın hepsinde, çünkü dilim `\n` ile
başlıyor ve `^\d` çapası ona takılıyordu), ortasında kapanmamış açılış
tırnağı (`"Mustard, 'Wasabi"` — 22 adda, kaynak adı ters çevirdiği için),
sonunda dipnot rakamı (`"Cherry Belle Radish1"`). `build_data.py`'ye
doğrulama **9b** eklendi: üçü de geri gelirse veri sayfası kilitlenmiyor.

**Altıncı — belgenin kendi kısaltması.** Tokyo Bekana ve Cherry Belle
Radish satırlarını belge `…` ile kısaltmış; o iki satırda işaret sayısı
eksik. Alan `isaret_guvenilir: false` ile işaretli ve defterde göze
görünüyor.

**Tur 8 · Türkiye kaynaklarının birincilleştirilmesi**
- `axiomspace.com/research/extremophyte-crispr` ve TÜBA'nın 13 deney belgesi
- IAC-26 bildiri özetleri (sunum kimliği 109010 ve eşi)
- Ege ve YTÜ'ye ait hakemli yayın araması — **yeniden**
- TÜBİTAK'ın yumuşak 404'lerine alternatif yol

**Tur 9 · görsel envanteri ve erişim haritası — KOŞULDU (13 Kasım 2026)**

İki betik, iki veri dosyası: `erisim_haritasi.py` → `erisim.json`,
`gorsel_envanter.py` → `gorseller.json`.

### Erişim — 10/12 açık, ölçülerek

Teşhis **dört ölçütle** veriliyor: durum kodu · içerik türü · gövde
uzunluğu · **bot duvarı imzası**. Dördüncüsü bu turda eklendi.

| kaynak | teşhis |
|---|---|
| TÜBİTAK UZAY — biyoloji deneyleri | **YUMUŞAK 404** · kod 404, 330.739 bayt HTML |
| TÜBİTAK bilimteknik — deney posteri | **YUMUŞAK 404** · kod 404, 183.958 bayt HTML |
| öteki on kaynak | açık |

**PMC notu — pratik ve önemli.** PMC düz bir HTTP isteğine **tam makaleyi**
veriyor (266 KB, doğru başlık, içerik yerinde) ama bazı getirici
istemcilere *"Checking your browser"* doğrulama sayfası çıkarıyor. Kaynak
açık; engel **istemciye bağlı**. Kural: PMC'den içerik alınacaksa düz istek
kullanılır, getirici değil.

### Görsel — 3,069 sonuç, 12 konu

| konu | sonuç |
|---|---|
| veggie | 786 |
| marul | 637 |
| hasat | 558 |
| regolit | 235 |
| mikroyercekimi_bitki | 221 |
| apdh | 186 |
| bitki_odasi | 168 |
| turp | 88 |
| arabidopsis | 75 |
| biber | 64 |
| tohum | 42 |
| bugday | 9 |

Merkez dağılımı: {'KSC': 188, 'JSC': 88, 'MSFC': 5, 'JPL': 2, 'SSC': 1}

> **SORGU TUZAĞI — ÖLÇÜLDÜ VE İLK ÖLÇÜM YANLIŞTI.** API terimleri VE'liyor;
> uzun betimleyici sorgu sonuç kümesini çökertiyor. Aynı arşivde
> *"Arabidopsis seedling spaceflight experiment"* **1** sonuç veriyor,
> *"Arabidopsis"* **75**. *"astronaut tending plants space station"* **0**,
> *"astronaut plants harvest"* **558**.
>
> İlk ölçüm üç konuda **sıfır** dönmüştü. O hâliyle kaydedilseydi "bu
> konuda NASA'da görsel yok" diye yazılacaktı — yanlış olurdu. Sorgular
> kısaltıldı, toplam 403'ten **3,069**'e çıktı.

**223 kaydın `fotografci` alanı dolu.** NASA medyası genel olarak
kamu malı ama kütüphanede NASA dışı kaynaklı kareler de var. Bu kayıtlar
**kullanılmadan önce tek tek okunacak**; envanterde ayrı liste olarak
duruyor.

### Türkiye karelerinin lisansı — ÖLÇÜLDÜ (`turkiye_gorsel.json`)

| konu | NASA | Commons | lisansı uygun |
|---|---|---|---|
| Ax-3 | 17 | **310** | 12/12 |
| Ax-3 mürettebatı | 31 | **259** | 12/12 |
| Alper Gezeravcı | 0 | **17** | 12/12 |
| TUA | 6 | 6.593 | 12/12 |
| Tuz Gölü | 0 | **38.157** | 12/12 |
| Tuva Cihangir Atasever | **0** | **0** | — |
| **Schrenkiella parvula** | **0** | **0** | — |

> **DOSYANIN OMURGASINDAKİ BİTKİNİN AÇIK LİSANSLI FOTOĞRAFI YOK.**
> Eş adlarıyla ve ayrı havuzlarda ölçüldü:
> - Commons: *Schrenkiella*, *Schrenkiella parvula*, *Thellungiella parvula*
>   → **sıfır**. *Eutrema parvulum* → 2, ikisi de 19. yüzyıl kitap taraması.
> - **Sayı tuzağı:** *"Thellungiella"* 126 sonuç veriyor ama hepsi **wasabi**
>   (bir zamanlar aynı cinse konulmuş başka bir tür). Sayıya aldanılmaz.
> - iNaturalist: takson kayıtlı, **dünyada 4 gözlem**, tek fotoğraf
>   **CC BY-NC**. Ticari kullanıma açık gözlem: **0**. NC portalın kabul
>   listesinde (CC0, CC BY, CC BY-SA, kamu malı) **yok** — kullanılamaz.
>
> **Tasarım sonucu ve KULLANICI KARARI (13 Kasım 2026):** Schrenkiella
> bölümü bitkinin açık lisanslı fotoğrafıyla kurulamaz. İki yol birden
> kullanılacak:
> 1. **Yaşam alanının karesi** — türün değil, geldiği yerin. Tuz Gölü'nde
>    38.157 açık lisanslı seçenek var. Altyazı "Tuz Gölü" der, bitkiyi
>    göstermez.
> 2. **Ege Üniversitesi'nin laboratuvar ve ISS kareleri, kaynak ve atıf
>    verilerek.**
>
> **İkincisi için şerh — bir kez söylendi, kullanıcı kararını yineledi.**
> Atıf vermek telif izni doğurmaz; portalın kendi kabul listesi (CC0,
> CC BY, CC BY-SA, kamu malı) bir üniversitenin basın karesini kapsamaz.
> Kullanıcı e-postaya gerek olmadığını ve kaynak-atıf vererek
> kullanılmasını söyledi; karar yayıncınındır ve burada tarihiyle kayıtlı.
> **Uygulama şartı:** her kare için kaynak kurum, varsa fotoğrafçı ve
> erişim adresi künyede ayrı ayrı yazılacak; "basında yayımlandı" künye
> sayılmayacak.

**Atasever'in görseli de yok** (her iki havuzda sıfır) ama dosya için
gerekmeyebilir: o uçuşta bitki deneyi de yoktu.

**Tur 10 · eksen cümlesi ve iskelet — KOŞULDU (13 Kasım 2026)**

### Eksen cümlesi

> **TR:** Dünyada 376 ekin denendi, dokuzu uzayda yenebildi — aralarında
> ne bir tahıl var ne bir baklagil. Türkiye'nin ilk insanlı görevindeki 13
> deneyin 4'ü bitki ve mikroalgdi, biri Tuz Gölü'nden gitti.
>
> **EN:** 376 crops were tested, nine have been eaten in space — not one
> grain, not one legume. Of the 13 experiments on Türkiye's first crewed
> mission, 4 were plants and microalgae, and one came from a salt lake in
> Anatolia.

Cümlenin beş sayısının beşi de kilitli: 376 ve 9 NASA/TM-20250001897'den
(`ekinler.json`), 13 ve 4 TÜBA'nın resmî listesinden (`ax3.json`), Tuz Gölü
Extremophyte deneyinin kendi misyon adından.

**İki yarı bilerek eşit ağırlıkta.** İlk cümle dünya, ikinci cümle Türkiye;
aralarındaki tire bir geçiş değil bir **kavşak**. Dosyanın bütün bölümleri
bu iki yarının birbirine açıldığı yerler.

### Yeni veri dosyası · `ax3.json`

Ax-3'ün 13 deneyi, TÜBA'nın resmî listesinden. **Sınıflandırma ELLE
yapıldı** — otomatik anahtar kelime eşleştirmesi denendi, alaşım ve akışkan
deneylerini "biyolojik" işaretledi, PRANET'i hiç görmedi.

| # | deney | kurum | sınıf |
|---|---|---|---|
| 3 | UzMAn | Boğaziçi Üniversitesi | mikroalg · yaşam destek |
| 4 | EXTREMOPHYTE | Ege Üniversitesi | bitki · halofit |
| 8 | ALGALSPACE | Yıldız Teknik Üniversitesi | mikroalg · kutup/ılıman |
| 9 | CRISPR-GEM | Yıldız Teknik Üniversitesi | bitki · gen düzenleme |

PRANET (propolis) **sınır durum**: arı ürünü, yani tarımsal — ama deney
yetiştirme değil antibakteriyel etki ölçümü. Dörde **katılmadı**;
katılırsa beş olur ve bu ayrım dosyada yazılı kalacak.

**Dördün ikisi mikroalg ve ikisi de yaşam destek amaçlı** — CO₂'den O₂,
su iyileştirme, ek gıda. ESA'nın MELiSSA'sı ve Çin'in Lunar Palace'ıyla
aynı soruna çalışıyorlar: kapalı döngü.

### DÖNÜŞ — dosya baştan kuruldu

**İlk sürüm reddedildi ve haklı olarak.** On bölümün onu da veri bileşeniydi:
raf, tırmanış, familya defteri, yük şeridi, oransızlık, alıntı
karşılaştırması, çizilemeyen eşik. Araştırma sağlamdı, bileşenler
çalışıyordu, erişilebilirlik ölçülmüştü — ve ortaya çıkan şey bir dosya
değil bir **denetim raporu**ydu.

Kullanıcının teşhisi birebir şuydu: *"derin bir kaynak araştırması
yapıyorsun, verileri kilitleyip oraya hapsoluyorsun."* Olan tam buydu. Veri
katmanı önce kilitlendi, sonra FORM da ondan türedi: her veri bloğu bir
bölüm, her bölüm bir sayı ve onun şerhi. Doğrulama aygıtı — yumuşak 404
çizelgesi, P değerleri, ayrıştırma günlüğü — okurun önüne kondu.

**İkinci hata daha pahalıydı: portalın kendi dosya kalıbına hiç
bakılmamıştı.** Hollanda dosyasının `bolum_turleri` notunda şu yazıyor:
*"Rusya dosyası yazılırken yalnızca veriye dayanan bir metnin okuru
YORDUĞU görüldü; dört anlatı bölümü eklendi."* Portal bu dersi almıştı.
Ayrıca `tasarim.json`: *"KOYU — dosya sayfası her zaman koyu. Dergi dosyası
mantığı: içeri girdiğinizde başka bir yere geldiğinizi anlamalısınız."*
Yeni sayfa bu iki kuralı da uyguluyor.

**Kullanıcının "kendi etkileşimli bileşenleri olan bir sayfa" tercihi
yanlış okundu.** O cümle "ev kalıbının yanında kendi bileşenleri de olsun"
demekti; "metin yok, görsel yok, hepsi bileşen" diye anlaşıldı.

### Yeni biçim

| katman | nerede | ne |
|---|---|---|
| anlatı | `content/uzay_tarimi/akis.json` → `uzay_akis.g.dart` | bölüm metinleri ve görsel künyeleri |
| ölçüm | `content/uzay_tarimi/data.json` → `uzay_veri.g.dart` | kilitli rakamlar, 9 blok, doğrulamalı |
| kareler | `web/dosya/uzay-tarimi/` | portalda barındırılıyor |

İkisi AYRI çünkü ayrı şeyler: biri kilitli ölçüm, öteki yazılmış metin.
Aynı dosyada olsalardı bir cümle düzeltmek veri doğrulamasını yeniden
koşturmak demek olurdu.

**Kareler neden portalda.** İlk kurulumda doğrudan `images-assets.nasa.gov`
adresleri kullanıldı ve hiçbiri görünmedi: Flutter web görseli XHR ile
alıyor, NASA CORS başlığı vermiyor. Dokuz kare indirildi, 1400 piksele
ölçeklendi, `web/dosya/uzay-tarimi/` altına kondu — ülke dosyalarıyla aynı
düzen. `nasa_id` ve `kaynak` alanları duruyor: okur aslına dönebilsin.

### Akış — kurulan ve bekleyen

| § | başlık | sahne | kare |
|---|---|---|---|
| 1 | Bir yaprak marul | 10 Ağustos 2015, ilk tadım | `iss044e045825` |
| 2 | Yüz yıllık fikir | Tsiolkovski 1926 → Lucid, Mir, 1996 | `s79e5277` |
| 3 | Suyun düşmediği yerde nasıl sulanır | yastık, fitil, LED | `iss052e002352` |
| 4 | Çiçek açtı | zinnia, Ocak 2016 | `iss046e017204` |
| 5 | En zor ekin | biber, Temmuz-Kasım 2021 | `iss066e008125` |
| 6 | Türkiye sahneye çıkıyor | Ax-3'ün dördü, adlarıyla | `iss070e064263` |
| 7 | Elenenler | 376'da dokuz | **raf illüstrasyonu** |
| 8 | Gölden istasyona, istasyondan göle | Tuz Gölü ↔ Schrenkiella | `iss069e033759` |
| 9 | Taşımak yerine üretmek | Artemis II, 6 Nisan 2026 | `art002e014251` |
| 10 | Aynı soruya çalışan dört hat | Kennedy 1988-95, MELiSSA, Lunar Palace, Chang'e-4 | `KSC-95pc1196` |
| 11 | Tatlı patatesin yolculuğu | Space Farming Brazil Network | — |
| 12 | Dünya'yı Mars'a çevirmek | pivot sulama daireleri, güney Mısır | `iss074e0247459` |

**Akış tamamlandı: 12 bölüm · 10 fotoğraf · 1 şekil · 63 paragraf.**

### Kaynak turu — §10-§12 (13 Kasım 2026)

Yeni blok: `_raw/dunya.json` → `data.json["dunya"]`, **doğrulama 9d** ile
bağlı. Bu blok ötekilerden farklı türde ve bunu KENDİSİ söylüyor: ekin
tabloları ve Ax-3 listesi birincil belgelerden ayrıştırılmıştı, burada
kaynak çoğunlukla kurum duyurusu ve haber. Her kalem `_nitelik` taşıyor
ve niteliksiz kalem kilidi açtırmıyor.

Doğrulama 9d'nin beklediği üç tuzak — altısı da olumsuz sınamada ateşliyor:
- **Brezilya ağının büyüklüğü kullanılmayacak.** Kaynaklar tutmuyor
  (45 araştırmacı/12 kurum ve 56/22); makalenin kendisi sayı vermiyor.
  Belirsizlik kaydı düşerse metin sayı yazmaya kalkabilir.
- **Chang'e-4 tam yazılmalı.** "Ay'da pamuk çimlendi" tek başına
  yanıltıcı: kapsüldeki öteki tohumlar çimlenmedi ve filiz ay gecesinde
  dondu. İkisi de kayıtta zorunlu.
- **Lunar Palace'ın 370 günü vardiyalı.** Sürekli tek ekip sanılırsa rekor
  yanlış anlatılır.

**BİR ÇELİŞKİ ÇIKTI VE METNE YAZILDI.** §7 "tahıl sıraya hiç girmedi"
diyor; §10'un karesi 1988'de Kennedy'de yetiştirilmiş cüce buğdayı
gösteriyor. İkisi de doğru ve fark şurada: dokuz basamaklı merdiven UÇUŞ
için, yerdeki kapalı odalarda buğday ve patates onlarca yıldır
yetiştiriliyor. §10 bu ayrımı bir şerh kutusunda değil, kendi
paragrafında açıkça kuruyor — yerdeki yetenekle yörüngedeki yetenek
arasındaki boşluk zaten dosyanın konusu.

### Aygıt nereye gitti

Doğrulama aygıtı silinmedi, YER DEĞİŞTİRDİ. `uzay_kunye.dart` sayfanın
sonunda, akışın dışında, **kapalı** kutularda duruyor: üç toplam, onarım
günlüğü, konum kısıtı, Poaceae'nin yokluğu, dünya hatlarının kaynak türü
ve görsellerin durumu. Altında beş künye ve 12 adresin ölçülmüş erişimi.
Merak eden açar; okuyan metni okur.

Eski veri bileşenlerinden familya defteri, oransızlık ve alıntı
karşılaştırması artık sayfada DEĞİL — söyledikleri §7, §10 ve künye
paneline dağıldı. Dosyaları `scratchpad/eski_bilesenler/` altında.

**Veri bileşenleri yok olmadı, YER DEĞİŞTİRDİ.** Raf §7'nin içinde bir
şekil olarak duruyor — başlığı yok, manşeti yok, altında tek satır künye
var, tıpkı bir fotoğraf gibi. Tırmanış aynı bölüme girecek. Familya
defteri, oransızlık ve alıntı karşılaştırması §12'nin veri notları
paneline inecek. Eski dosyalar
`scratchpad/eski_bilesenler/` altında duruyor.

**§11 bir bölüm olarak duruyor çünkü bir YANLIŞ ANLAMAYI düzeltiyor:**
Türkiye'nin ikinci astronotu uçtu ama o uçuşta bitki deneyi yoktu, ve
sebebi yapısal — yörünge altında mikroyerçekimi penceresi dakikalarla
ölçülüyor, bitki biyolojisi gün istiyor.

### Etkileşimli bileşenler — dördü, ve biri KISITLI

| bileşen | veri | ne yapar |
|---|---|---|
| **Raf** | `ekinler.json` | on iki yuva: dokuz dolu, üçü kaynağın "None" satırı |
| **Tırmanış** | `ekinler.json` | dokuz basamak, ÖLÇÜLÜ eşikleriyle; ara kademeler KESİK |
| **Familya defteri** | `ekinler.json` | 419 kültivar · 25 familya · denenen/kalan oranı |
| **Yük listesi** | `ax3.json` | 13 segmentlik şerit + dört derin panel + kalan sekiz |
| **Oransızlık** | `osdr.json` | 50 ↔ 5 ↔ 23, punto ve çizgi boyuyla |
| **Alıntı karşılaştırması** | `marul.json` | özet ≠ sonuçlar, hangisinin esas alındığı işaretli |
| **Çizilemeyen eşik** | `yorunge_alti.json` | 20.160 dakika ↔ 3 dakika; pencere gerçek boyunda |
| **Kaynakça** | `erisim.json` | beş künye + 12 adresin ölçülmüş erişim durumu |

> **CRL MERDİVENİ ARA ÜRÜNLERİ GÖSTEREMEZ — TASARIM KISITI.** Tablolardaki
> boş hücreler PDF metninde konumunu kaybediyor ve bir ürünün hangi
> basamakta kaldığı okunamıyor (Waldmann marulu sekiz işaretle CRL 9
> listesinde). Merdiven **eşikleri** ve **CRL 9'u geçen dokuzu**
> gösterebilir; ara ürünü basamağa yerleştirirse veri UYDURUR. Bileşen bu
> kısıtla tasarlanacak: basamağa tıklanınca ölçütü açılır, ürün listesi
> yalnız dokuzuncuda doludur.

---

## 8. Tur 8 — Türkiye kaynaklarının birincilleştirilmesi

**13 Kasım 2026'da koşuldu. Beş açık sorunun beşi de kapandı ya da sınırı
çizildi.**

### Yeni birincil kaynak · Extremophyte CRISPR (Axiom Space deney sayfası)

Tam ad: *"Extreme Salt Stress and CRISPR Gene Editing Efficiency in Plants
Under Microgravity"*.

| Alan | Değer |
|---|---|
| Yürütücü | **Tuğçe Celayir, M.Sc.** — Yıldız Teknik Üniversitesi, Davutpaşa/Esenler, İstanbul |
| Ayrıca listelenen | **Prof. Dr. İsmail Türkan** — Ege Üniversitesi, İzmir |
| Destek | **TÜBİTAK UZAY** |
| Görev | Axiom Mission 3 |

İki amacı var: (1) *Arabidopsis thaliana*'da stres tepkisinde görevli **üç
genin** CRISPR ile baskılanması; (2) **tuza duyarlı bir bitki ile tuza
dayanıklı bir bitkinin** ISS'te yetiştirilerek tuz stresi toleransının
karşılaştırılması.

> **İki Türk deneyi tasarımla birbirine bağlı.** "Tuza duyarlı" Arabidopsis,
> "tuza dayanıklı" ise Extremophyte deneyindeki *Schrenkiella parvula*.
> Yani Ege ile YTÜ ayrı iki iş değil, aynı karşılaştırmanın iki ucu.

### Sınır çizildi · ikinci astronotun uçuşunda BİTKİ YOK

Türkiye'nin ikinci astronotu **Tuva Cihangir Atasever**, Virgin Galactic'in
**Galactic 07** görevinde **8 Haziran 2024**'te uçtu. VSS Unity, yörünge
altı, yaklaşık **90 km**. TÜBİTAK'ın kendi haberinden okunan yedi deney:

BEACON (beyin görüntüleme, NIRS) · IvmeRad (radyasyon dozimetresi) ·
uzayda insülin kalemi testi (TUA + Axiom ortak) · vezikül analizi
(mikroakışkan çip) · MESSAGE · METABOLOM · MİYELOİD.

**Hiçbiri bitki, tohum ya da tarım deneyi değil.** Bu sınır yazılacak:
Türkiye'nin uzay tarımı işi **tamamen Ax-3'te** (yörüngesel, Ocak 2024)
artı yerdeki regolit çalışması. Yörünge altı uçuş bu hatta girmiyor.

> **YAPISAL SEBEP, dosyada anlatılmaya değer:** yörünge altı uçuşta
> mikroyerçekimi penceresi **dakikalarla** ölçülüyor; Atasever'in kendi
> ifadesiyle üç deney için "3 dakikalık sürem olacak". Bitki biyolojisi
> günler ister. Yörünge altı ile yörüngesel arasındaki fark, uzay tarımı
> için bir ayrıntı değil **eşik**.
>
> **İrtifa rakamı kaynaklar arasında ayrışıyor:** 87,5 km / 90 km / ~80 km.
> TÜBİTAK'ın kendi haberi **90 km** diyor; kullanılacaksa o, ve ayrışma
> söylenecek.

### Soru 3 · Schrenkiella'nın hakemli yayını — YOK

İki ayrı aramada bulunamadı. Elde olan: IAC-26'da **durumu onaylı** bir
sunum (*"Schrenkiella parvula, an extreme halophyte preserves salt-tolerance
programs under microgravity"*, Dr. Barış Uzilday) ve basın düzeyindeki ön
bulgular.

**Kullanıcı kararı:** şerhiyle birlikte yer alabilir. Metin "ön sonuç" ve
"henüz hakemli yayını yok" diye yazacak; sunum başlığının kendisi bir iddia
taşıyor (*preserves* — yani toleransı **koruyor**) ve o iddia özetine
ulaşılmadan kesin diye aktarılmayacak.

### Soru 4 · Ege'nin domatesi — süreç var, sayı yok

TÜBİTAK destekli proje **yaklaşık 15 ay** sürmüş, regolit simülantları
**ABD'den** getirilmiş. İki aşamalı:

1. **Toprağın iyileştirilmesi** — regolit organik maddece fakir, metal ve
   tuzca zengin. Ekstremofit **öncül bitkilerle** (*Schrenkiella parvula*,
   *Arabis alpina*, *Noccaea sempervivum*) tuz ve metal içeriği azaltılmış.
2. **Domates ekimi** — "bazılarında yüksek miktarda meyve" alınmış.

**Sayısal verim verisi YOK.** Meyve kalitesi ve moleküler mekanizmalar
henüz incelenmemiş; tüketilebilirlik analize bağlı. Kaynaklar **yalnız
basın haberleri** (≈Şubat 2026), hakemli yayın ya da proje raporu
bulunamadı.

**Kullanıcı kararı uyarınca:** süreç anlatılacak, sonuç sayı olarak
verilmeyecek. İki aşamalı yöntem — önce öncül bitkiyle toprak, sonra ekin —
zaten dosyanın en anlatılabilir fikri.

### Soru 5 · İkinci görev — zaten olmuş, üçüncüsü yok

Atasever'in uçuşu Türkiye'nin **ikinci** görevi ve 2024'te tamamlandı.
**Üçüncü bir insanlı görev için doğrulanmış duyuru bulunamadı.** Gezeravcı
(şimdi TUA yönetim kurulunda) mevcut önceliğin **Ay Araştırma Programı**
olduğunu söylüyor. Axiom'un genel müdürü Türkiye ile görüşmelerin sürdüğünü
ve NASA sözleşmeli bir Axiom görevinin **2027**'de planlandığını belirtiyor;
o görevde Türk astronot olacağı **doğrulanmadı**.

### Bağlam · IAC 2026 Antalya'daydı

Türk bildirilerinin çokluğunun sebebi bu: **77. Uluslararası Astronotik
Kongresi, 5-9 Ekim 2026, NEST Kongre Merkezi, Belek/Antalya.** Türkiye
Uzay Ajansı ev sahibi, SAHA Kümelenmesi eş ev sahibi, **Türkiye'de ilk
kez**. Rekor: **108 ülkeden 8.325 bildiri özeti**.

Kongre bu dosyadan **beş hafta önce** bitti. Yani alan yalnız kaynak değil,
**güncel** bir kaynak.

---

## 9. Kalan sorular

1. **Sayfanın etkileşimli bileşenleri ne olacak?** Biçim kararı verildi
   (kendi sayfası), bileşenler verilmedi. CRL merdiveni gezinilebilir bir
   öğe olabilir; 376 → 9 elemesi bir süzgeç olabilir.
2. **IAC-26 bildiri özetlerine ulaşılabiliyor mu?** Program dizini
   başlıkları veriyor, özetleri vermiyor. Sunum kimliği 109010 denenmedi.
3. **Ax-3'ün öteki 11 deneyi ne?** TÜBA'nın 13 deneyi listeleyen belgesi
   henüz okunmadı; içinde başka bitki/yosun deneyi olabilir (bir kaynak
   "yosun ve propolis" diyor).
4. **Khodadad 2020'nin besin tablosu** — hangi mineral hangi yönde
   değişiyor, hâlâ bilinmiyor. Tam metin okunacak.

---

## 10. Tek cümlelik verdikt

Sepet doluyor: **açık API'li bir veri katmanı**, **ölçülü eşikleri olan bir
NASA birincil belgesi**, **kamu malı görsel arşivi** ve dizinin hiçbir
dosyasında olmayan bir şey — **Tuz Gölü'nden çıkıp ISS'e giden, portalın
kendi konusuyla (tuzluluk) kesişen bir Türkiye hikâyesi.**


---

## ÜÇÜNCÜ DÖNÜŞ — belgesel akış (13 Kasım 2026)

İkinci sürüm de reddedildi. Kullanıcının teşhisi: *"şimdi de bizim ülke ve
kurum klasörleri biçimine hapsolmuşun. hep bir tasarımı biçime hapsediyorsun
kendini en başından."* Doğru. İlk sürüm "veri bileşenleri sayfası" kalıbına,
ikincisi "ülke dosyası" kalıbına oturdu. İkisinde de önce KUTU seçildi,
sonra içi dolduruldu.

İstenen: metne boğulmayan, bol görselli, sayfa geçişleri animasyonlu,
grafikli, etkileşimli, özgün bir **story telling** tasarımı.

### Yirmi soruluk mutabakat

Kullanıcı "15-20 soruluk bir quiz yap ve anlaşalım" dedi. Yapıldı; kararlar:

| | |
|---|---|
| omurga | dikey tam ekran duraklar; kaydırma hem geçişi hem sahne içi hareketi sürükler |
| yapı | ana akış + her durakta "derine in" kapısı |
| açılış | tohumdan yaprağa, ~3 sn, her zaman atlanabilir |
| uzunluk | 5-8 dakika · 14 durak |
| metin | ekranda en fazla iki cümle; tam metin ikinci katmanda; sıfırdan yazılacak; iki dilli |
| yerleşim | durağa göre değişir: üstünde · yanında · altında |
| görsel | fotoğraf + video + özgün şema + katmanlı derinlik |
| atmosfer | bölüme göre değişir — karanlık modül → beyaz göl → kum çöl |
| hareket | dört tür de var, **ağırlık "vurgu"** |
| grafik | anlatan şema · oynanan araç · veri grafiği · sayılar sade |
| etkileşim | açılan katman · seç-ve-gör · karşılaştırma sürgüsü · zaman çizgisi |
| ton | merak ve hayret |
| ekran | telefon ve masaüstü **ayrı kurgu** |
| Türkiye | kendi durağında |

**ÇÖZÜLEN GERİLİM.** Kullanıcı hem "vurgu" (sakin akış, 4-5 güçlü an) hem
dört etkileşim türünün hepsini seçti. Her durağa etkileşim koymak vurguyu
düzleştirirdi. Çözüm: on dört durağın **beşi an**, dokuzu sahne; her an bir
tane güçlü şey yapıyor.

### Dört katmanlı veri

| katman | dosya | ne |
|---|---|---|
| ölçüm | `data.json` → `uzay_veri.g.dart` | kilitli rakamlar, 10 blok, doğrulamalı |
| omurga | `duraklar.json` → `uzay_duraklar.g.dart` | durak sırası, atmosfer, ekrandaki iki cümle |
| derin | `akis.json` → `uzay_akis.g.dart` | "derine in" katmanının uzun metni |
| kare | `web/dosya/uzay-tarimi/` | portalda barındırılan 11 NASA karesi |

`duraklar_uret.py` beş şeyi sınıyor ve tutmazsa omurga kilitlenmiyor:
ekrandaki metin 190 karakteri aşamaz (dosya bir kez metne boğuldu — kural
artık kodda, iyi niyette değil) · hazır durak tam olmalı · görsel künyesi
tam olmalı · giriş animasyonu atlanabilir olmalı · **zemin parlaklığı ile
'acik' alanı tutmalı** (yoksa beyaz durakta beyaz metin yazılır).

### Kurulan

- `uzay_giris.dart` — tohumdan yaprağa. Kök ve gövde `PathMetric` ile
  ÇİZİLİYOR, yani gerçekten büyüyor; ölçeklenen şekil değil. LED huzmesi,
  yaprağın renk alması, karenin yaprağın bulunduğu noktadan daire olarak
  açılması. Oturumda bir kez oynuyor, her an atlanabiliyor.
- `uzay_durak.dart` — sahne durağı, üç yerleşim, kaydırmaya bağlı parallax.
  **Sahne erimesi**: durak çıkarken zemin rengine eriyor; ilk kurulumda iki
  karenin kenarı sert bir dikişle çarpışıyordu.
- `uzay_ekrani.dart` — ListView `itemExtent` = ekran boyu, zemin rengi iki
  durak arasında yumuşakça geçiyor, sağda ince ilerleme rayı, "derine in"
  alttan açılan katman.

Sert "snap" denendi ve bırakıldı: ara konumlar hiç görünmediği için
kaydırmaya bağlı sahne içi animasyonu öldürüyor.

### Bekleyen

On dört durağın **altısı kuruldu**: 1 · 2 · 3 · 6 · 7 sahne, **4 ilk AN**.

### İlk an — sürüklenen zaman çizgisi (durak 4)

On bir kilometre taşı, 1926'dan 2026'ya. Yıllar çizgiye **gerçek oranda**
yerleşiyor; eşit aralığa dağıtılmadı. Sebebi şu: 1926 ile 1988 arasında
altmış iki yıl var ve o aralıkta bu dosyanın gösterebileceği hiçbir şey
yok. Sürüklerken o boşluk uzun sürüyor — **boşluk da bilgi**, ve bir liste
onu gösteremezdi. Son kırk yıldaki yığılma da aynı sebeple duruyor.

Sürükleme yalnız alttaki şeritte çalışıyor; bütün durağa yayılsaydı okur
sayfayı aşağı kaydıramazdı. Etkileşim akışı kilitlemiyor. Durak ekranın
ortasına gelince kafa ilk düğüme **kayarak** gidiyor — hareket eden bir şey
"beni sürükle" der, duran bir çizgi demez. Bırakınca en yakın düğüme
oturuyor.

Her kilometre taşının yılı ve olgusu dosyanın kilitli kaynaklarından:
NASA görsel künyeleri, NASA/TM-20250001897, TÜBA'nın Ax-3 listesi,
`_raw/dunya.json`. Üretici çizgideki notun 230 karakteri aşmasına da izin
vermiyor — sürüklerken okunan metin uzarsa okur sürüklemeyi bırakıp
okumaya geçiyor ve etkileşim ölüyor.

Doğrulama türe göre ayrıldı: **sahne karesiz olmaz, an da malzemesiz
olmaz.** İlk kural her hazır duraktan fotoğraf istiyordu ve zaman çizgisi
durağında düştü — o durağın taşıyıcısı fotoğraf değil.

### İkinci an — kutunun içi şeması (durak 5)

Altı parça, adım adım, biriken bir kesit: yastık · su · ışık · hava · CO₂ ·
tutucular. Durak ekranın ortasına gelince şema kendi oynuyor; okur
dokunduğu anda kumanda ona geçiyor. Hiç dokunmayan biri de şemayı baştan
sona görmüş oluyor — düğmeye basılmasını beklemek, çoğu okurun o şemayı hiç
görmemesi demek.

**ÇİZİMİN KAYNAĞI OLMAK ZORUNDA.** Bir şema her şeyi söyleyebilir ve kimse
sormaz; kaynağı olmayan bir ok, kaynağı olmayan bir cümleden daha
tehlikelidir çünkü cümle sorgulanır, ok sorgulanmaz. Yeni bir ayrıştırıcı
yazıldı — `_raw/oda_ayikla.py` — NASA/TM-20250001897'den beş pasajı ve iki
elenme sebebini PDF'ten ÇEKİYOR. Elle kopyalanmadı; belge sürümü değişip
cümle kaybolursa betik düşer.

Çekilen malzeme beklenenden iyi çıktı ve bir hatayı da düzeltti: yastığın
körüğü **su** dolunca değil **kökler** dolunca genişliyormuş. Ezberden
yazılsaydı yanlış çizilecekti. Ayrıca iki adım artık soyut değil — ikisi de
birer ekini düşürmüş somut sebep: *"Shungiku · severe tip burn attributed
to reduced airflow"* ve *"Tokyo Bekana · did not grow well under ISS
conditions due to elevated CO₂"*.

### Bir borç kapatıldı — Mir'in etileni

Durak 2 bir süre şu cümleyle yayındaydı: *"istasyon havasındaki eser etilen
bitkiyi kısırlaştırıyordu."* Doğru çıktı — ama yazıldığı anda **kilitli
kaynağı yoktu** ve dosyanın kendi kuralını deliyordu. Şema aynı iddiaya
yaslanacağı için önce kaynak arandı.

İki hakemli makale bulundu, indirildi ve `_raw/mir_ayikla.py` ile pasajları
çekildi:
- **Salisbury vd.** — *"the ca. 280 wheat heads that were produced in 1996
  contained no seeds"*
- **Campbell vd. 2001**, J. Plant Physiol. 158: 1051-1060 — Mir'de ölçülen
  etilen **1,1-1,7 µmol·mol⁻¹**; anterler açılmadı; polen tanelerinde üç
  çekirdek yerine sıfır, bir, bazen iki

**Nedensellik iddiası gözleme değil ÇAPRAZ DENEYE dayanıyor:** Campbell
ekibi yerdeki buğdayı Mir'de ölçülen etilen aralığına maruz bıraktı ve aynı
kısırlığı üretti. "Birlikte bulundu" değil, "tekrarlandı". Doğrulama **9f**
bu notun kaybolmasına izin vermiyor — kaybolursa cümle sıradan bir
birliktelik iddiasına döner.

Durak 2 bu sayılarla yeniden yazıldı. Veri katmanı 12 bloğa çıktı.

### Üçüncü an — seç ve gör (durak 8)

Dosyanın tezi oyun olarak. "376 ekin denendi, dokuzu yenebildi, aralarında
tahıl yok" cümlesi doğru ve okunduğu anda unutuluyor; aynı şeyi okur KENDİ
ELİYLE bulduğunda unutmuyor.

Sürpriz buğdayda. Okur büyük ihtimalle buğdayı seçecek ve yüksek bir yere
çıkmasını bekleyecek; cevap "merdivende takıldı" değil **sıraya hiç
girmedi**. Merdiven tamamen sönüyor, işaretçi birinci basamağın ALTINDA
kalıyor. Doğrulama bunu koruyor: sıfır basamaklı seçenek kalkarsa durak
sıradan bir sıralama aracına döner.

**Basamakların adı var, ölçütü yok.** Dokuz basamağın her birinin ölçülü
bir eşiği var — mikrobiyolojik sınırlar, hedonik ölçek ortalamaları.
Hiçbiri yüzeyde yazmıyor; hepsi "derine in" katmanında.

### İskelette bir değişiklik

Durak 11 ikinci bir şema olacaktı (MELiSSA'nın beş bölmesi). **Sahneye
çevrildi**: 1995'te Kennedy'de kapalı odada patates hasadı. Sebebi iki
katlı — üst üste iki şema hem tekrar, hem de kullanıcının uyardığı yönde
fazla teknik. MELiSSA ve Lunar Palace sayıları artık o sahnenin "derine
in" katmanında.

**Kullanıcının notu:** *"çok fazla teknik detaylara inmemeye dikkat et.
çizgini koru."* Doğru uyarı — şema durağı ve Mir'in etilen ölçümleri
belgesel kaydından mühendislik kaydına doğru kaymıştı. Kural netleşti:
**yüzeyde insan ve sahne, teknik derinlik "derine in" katmanında.**

### Dördüncü an — yolculuğun iki ucu (durak 10)

Klasik "önce/sonra" değil. Solda otun GELDİĞİ yer — Tuz Gölü, yörüngeden
çekilmiş. Sağda GİTTİĞİ yer — istasyonun içi. Çizgiyi sürüklemek okuru
420 kilometre aşağı ve yukarı taşıyor. Bu durağın söylediği şey bir
simetri: bitki yukarı çıktı, istasyon aşağı baktı. İki kare yan yana
durduğunda cümleye gerek kalmıyor.

**Sağdaki kare o deneyin değil, ve bu yazıyor.** Schrenkiella parvula'nın
açık lisanslı tek bir fotoğrafı bulunamadı; sağdaki kare aynı aylarda aynı
istasyonda büyüyen başka bir bitki. Künyesi bunu söylüyor ve durağın derin
katmanı da. Deneyin karesiymiş gibi göstermek, dosyanın bütün geri kalanını
şüpheye düşürürdü.

### Durak 13 — Campinas

Brezilya sahnesinin karesi beklenmedik biçimde yerli yerine oturdu:
`iss074e0361940`, **Campinas** şehri, istasyondan. Campinas, makaledeki
ekinleri seçen ziraat enstitüsünün bulunduğu şehir.

### Künye — akışın sonu

Bir önceki sürümde sonda altı katlanır kutu vardı: üç toplam, onarım
günlüğü, erişim ölçümü. Hepsi doğruydu ve hepsi okuru dosyanın sonunda bir
denetim raporuna sokuyordu. Künye artık altı kaynak künyesi ve bir görsel
notundan ibaret. Dosyanın denetlenebilirliği kaybolmadı — ölçümler
`data.json`'da doğrulamalarıyla duruyor ve depoda açık. Okurun sonda
görmesi gereken şey başka: neye dayandığı ve kimin çektiği.

Künye kendi koyu zeminini boyuyor; son durak açık zeminli (çölün kumu) ve
devraldığında beyaz metin kreme düşüp okunmuyordu.

### AKIŞ TAMAMLANDI

**14 durak · 4 an · 10 sahne · 11 kare · giriş animasyonu · künye.**

| | |
|---|---|
| anlar | zaman çizgisi (4) · şema (5) · seçim (8) · sürgü (10) |
| açık zeminli duraklar | 10 (Tuz Gölü) · 14 (çöl) |
| veri katmanı | 12 blok, doğrulamalı |
| üreticiler | `duraklar_uret.py` · `akis_uret.py` · `dart_uret.py` · `build_data.py` |

### Son kalem — video (durak 3)

Akıştaki tek video. Yeri seçerken ölçü şuydu: **fotoğrafın
gösteremediği bir şey var mı?** On dört durağın on üçünde yok — duran
kare her şeyi anlatıyor. Üçüncü durakta var. Konusu suyun düşmemesi, ve
havada asılı duran bir su küresinin duran fotoğrafı, yakın çekilmiş
sıradan bir damlacıktan ayırt edilemiyor. Düşmediğini yalnız zaman
gösteriyor. Video oraya kondu, başka hiçbir yere konmadı.

**Kayıt.** NASA · `art002m1200950026` · Artemis II mürettebatı
(Wiseman, Koch, Hansen) · 4 Nisan 2026 · 43 saniye · kamu malı.
Sessiz oynuyor: ham kayıtta İngilizce mürettebat konuşması var, dosyanın
Türkçe akışında anlamsız kalırdı. Afiş fotoğrafı önce yükleniyor, video
hazır olunca üstüne eriyor; video hiç gelmezse durak sessizce fotoğrafla
devam ediyor.

**İki tuzak, ikisi de kayıtlı.**

İlki: ilk seçilen VEG-01B marul kaydı NASA künye kartıyla açılıyordu.
Kartı atlamak için ileri sarmak gerekti, çalışmadı — oynatıcı "oynuyor"
diyordu ama konum sıfırda takılıydı. Sebep geliştirme sunucusu:
`tool/spa_sunucu.py` HTTP parça isteğine (Range) `200` dönüyor, yani
tarayıcı videonun ortasına atlayamıyor. Çözüm ileri sarmayı zorlamak
değil, **jeneriksiz bir kayıt seçmek** oldu. `baslangic_sn` alanı yerinde
duruyor ama bu dosyada sıfır.

İkincisi aynı sebebin ikinci yüzü: kaynağın 4K aslı ve iki ara sürümü
geliştirme sunucusunda hiç açılmıyor — tarayıcı büyük dosyanın
üstverisini parça isteği olmadan okuyamıyor.

| sürüm | boyut | yerel sunucu |
|---|---|---|
| mobile 320×180 | 1,8 MB | **açılıyor** |
| preview | 3,4 MB | açılmıyor |
| small | 8,1 MB | açılmıyor |
| medium | 12,4 MB | açılmıyor |

Ölçülmüş, tahmin değil: `curl -r` `HTTP/1.0 200 OK` ve tam
`Content-Length` döndürüyor. Üretimde (Firebase Hosting) parça isteği
destekleniyor, ama yerelde doğrulayamadığım davranışa yaslanmadım.
**1,8 MB'lik sürüm seçildi** — portalın mobil okuru için de doğru
ağırlık, ve yumuşaklığı arşiv kaydı gibi okunuyor. Not hem
`duraklar.json`'un video bloğunda hem `uzay_video.dart`'ın başında
duruyor; üretime taşınırken daha yüksek çözünürlük denenebilir.

Doğrulandı: masaüstünde ve 375×812'de oynuyor, döngüye giriyor, sessiz,
durak ekrandan çıkınca duruyor.

### AKIŞ KAPANDI

**14 durak · 4 an · 10 sahne · 11 kare · 1 video · giriş animasyonu ·
künye.** Eksik kalem yok.

Sayfa **dağıtılmadı** ve portalda **hiçbir yerden bağlantısı yok** —
yalnız adresi yazarak açılıyor. Anasayfaya giriş koymak vitrin
yerleşimine dokunuyor; söylenmeden yapılmadı.

---

## DÖRDÜNCÜ TUR — on üç maddelik geri bildirim (14 Kasım 2026)

Kullanıcı akışı baştan sona izledi ve on üç madde yazdı. Maddelerin dokuzu
doğrudan uygulandı; dördü farklı yollara açıldığı için önce dört soruluk
bir mutabakat yapıldı.

### Mutabakat

| soru | karar |
|---|---|
| çizelge nasıl idare edilsin | parmak eşit adımlasın + ‹ › düğmeleri |
| gelecek ne anlatsın | dördü de: Ay/Mars · sıradaki deneyler · yerde ne değişecek · Türkiye |
| gelecek nereye girsin | sondan bir önce; son söz yeryüzünde kalsın |
| kapanış ikinci karesi | tuzlanan toprak **ve** dikey tarım, ikisi de |

Kullanıcının bir uyarısı kaydedildi: **gelecek, zaman çizelgesine yıl
eklemek değil.** Ayrı bölümler. Çizelge 1926-2026 aralığında kaldı.

### Çizelge — iki uzayın ayrılması

Sorun ölçülebilirdi: on bir durağın yedisi 2015-2026 arasında, yani
çizginin son yüzde onunda. Yıllar gerçek oranda durduğu için orada
sürüklemek işe yaramıyordu.

Çizgiyi eşit aralığa dağıtmak çözüm değildi — bölümün söylediği şey tam
da o yığılma ve ondan önceki altmış iki yıllık boşluk. Onun yerine iki
uzay ayrıldı:

```
ÇİZGİ   yıl uzayında çiziliyor   → boşluk olduğu gibi duruyor
PARMAK  durak uzayında geziyor   → her durak eşit sürükleme mesafesi
```

Kafa artık ekranda düzgün hızla gitmiyor: sıkışık uçta ağır, boş aralıkta
hızlı. Kusur değil, bölümün kendisi — altmış iki yıl tek adımda geçilirken
kafa ekranda uçuyor.

Yanına ‹ › adım düğmeleri ve `4 / 11` sayacı kondu. Uçtaki düğme
gizlenmiyor, pasifleşiyor; gizlenseydi düğmelerin yeri her adımda kayardı.

Bu arada sessiz bir kusur da çıktı: giriş animasyonu hiç oynamıyordu.
`_otur(ilkYılınOranı)` çağrılıyordu ve o oran sıfırdı — kafa sıfırdan
sıfıra gidiyordu. Artık sağdan gelip ilk durağa oturuyor.

### Çizelgenin kareleri

Her kilometre taşının arkasına kendi karesi kondu; duraklar arası geçişte
eriyor, perdeyle metnin önüne geçmiyor. On bir taştan dokuzunun karesi
var. İkisi (Lunar Palace 1, Chang'e-4 kapsülü) açık lisanslı kare
bulunamadığı için zeminle devam ediyor.

İki yeni kare indirildi:

| kare | kaynak |
|---|---|
| `tsiolkovski_1913.jpg` | Wikimedia Commons · Assonov · kamu malı. Dosyadaki tek NASA dışı kare. |
| `bpc_1988.jpg` | NASA · KSC-388c2096-08. Künyesi birebir: *"22 Haziran 1988 — 'Yecoro Rojo' cüce buğdayı KSC'nin Biyokütle Üretim Odası'nda."* |

### "Yeşil daireler" meselesi

Kullanıcı kapanış karesine bakıp "resimde pek de yeşil daire falan fark
edilmiyor" dedi ve haklıydı: daireler sağ kenarda minik koyu noktalardı.
Kare, 4928×2768'lik aslından yeniden kırpıldı — daireler artık kumun
içinde tek tek sayılabiliyor. Cümle de gördüğünü söyleyecek biçimde
yeniden yazıldı: "yeşil daireler" değil, "kumun içine basılmış yüzlerce
koyu daire".

### Numaralı göndermeler kaldırıldı

Metinde "sekizinci duraktaki tablo" ve "dördüncü duraktaki kadife çiçeği"
gibi göndermeler vardı. İkisi de okuru dışarı atıyordu — ve ikincisi
yanlıştı: kadife çiçeği dördüncü durakta değil, altıncıda. Kural artık
şu: **başka bir durağa numarayla değil içeriğiyle gönderme yapılır.**

### Gelecek bölümü — gelecekten değil, yazılı hedeften

Bu dosyanın kuralı kaynağı olmayan bilgiyi yayına çıkarmamak; gelecek de
o kuralın en zorlandığı yer. Çözüm: gelecekten değil **kurumların yazılı
hedefinden** söz etmek. Hedefin kendisi bir belge.

Üç yeni birincil kaynak indirildi ve `_raw/gelecek_ayikla.py` ile
cümleler desenle çekildi:

| belge | ne verdi |
|---|---|
| NASA BPS Space Crops Program and Goal Update · 22 Kas 2024 | M2M hedefi **AS-5LM**, vizyon basamakları, LEAF'in üç türü |
| Wheeler · NASA/TM-20205008832 · Ekim 2020 | Yerdeki odanın dikey tarıma dönüşü, LED patenti 1990, alan oranları |
| TUA · 2025 İdare Faaliyet Raporu · Şubat 2026 | AYAP, ve Türkiye'nin **ilk uzay ıslahı** çalışması |

### Bir yokluk iddiası yanlış ölçüldü ve doğrulama yakaladı

Betiğin ilk hâli TUA raporunda "bitki" ve "biyoloji" arıyordu, bulamadı,
ve dosya "Türkiye'nin sıradaki adımında bitki yok" diyecekti.

Tarama kusurluydu: PDF sözcükleri satır sonunda bölüyor ve bölünmüş
sözcük kalıba uymuyordu. Boşluk tekleştirilince çıkan cümle, yazılacak
olanın tam tersiydi — Çin'in Shijian-19 geri dönebilen uydusuna, Ege
Üniversitesi Biyoloji Bölümü'nün önerdiği **iki tohum yükü** eklenmiş ve
rapor bunu Türkiye'nin ilk uzay ıslahı çalışması olarak tanımlıyor.

**Ders kaydedildi: bir yokluk iddiası, bir varlık iddiasından daha
tehlikeli.** Varlığı yanlış çekersen betik durur; yokluğu yanlış ölçersen
betik memnuniyetle devam eder.

Bulgu dosyaya iki bağ kazandırdı: Ege Üniversitesi hem Tuz Gölü
halofitini yörüngeye çıkaran kurum hem de tohum yüklerini öneren kurum; ve
uzay ıslahı, Brezilya'nın nohut tohumlarını yerde gama ışınına tutmasıyla
aynı fikrin iki ucu.

### Bir tarih düşmedi

LEAF, Mart 2024'te Artemis III'ün Ay yüzeyine bırakacağı aygıtlar
arasından seçilmişti. Şubat 2026'da NASA Artemis III'ü yeniden tanımladı:
artık Ay'a iniş değil, Dünya yörüngesinde bir iniş aracı denemesi, 2027
yazı hedefli; ilk insanlı iniş Artemis IV'e, 2028 başına taşındı. İnişi
olmayan bir görev yüzeye bir şey bırakamaz.

Dosya bu yüzden LEAF'i "sıradaki deney" diye değil **"hazır ama sırasını
bekleyen deney"** diye anlatıyor — ki bu zaten dosyanın baştan beri
söylediği şey.

### Schrenkiella'nın fotoğrafı — yeniden arandı, yine yok

Üç ayrı bilimsel adıyla tarandı: *Schrenkiella parvula*, *Thellungiella
parvula*, *Eutrema parvulum*. Wikimedia Commons'ta açık lisanslı fotoğraf
yok (yalnız eski bitki listelerinin taranmış sayfaları). NASA arşivinde de
yok; zaten NASA'nın deneyi değil.

Not kalıyor ama artık özür gibi değil, anlatının parçası gibi: marul
fotoğraflanıyor, çiçek fotoğraflanıyor, biber fotoğraflanıyor; tuzlu
toprakta yaşayan, görmeye değer hiçbir yanı olmayan ot fotoğraflanmıyor —
ve işe yarayacak olan o.

**Kapatılmamış tek yol:** Ege Üniversitesi ekibinden lisanslı kare
istemek. Ekibin kendi laboratuvar ve ISS kareleri var; izin verilirse en
doğru çözüm bu olur.

### AKIŞIN YENİ HÂLİ

**19 durak · 4 an · 15 sahne · 19 kare · 1 video · giriş animasyonu ·
künye.**

| | |
|---|---|
| gelecek bölümü | 14 Ay'a gidecek saksı · 15 Hedef yazıya döküldü · 16 Tohum yukarı |
| kapanış | 17 Yeryüzüne dönen · 18 Aynı beyazlık · 19 Zaten inmişti |
| açık zeminli | 10 · 17 · 18 · 19 — dosya koyudan aydınlığa çıkarak bitiyor |
| künyedeki belge | 9 |
| karesiz konu | Schrenkiella parvula · Lunar Palace 1 · Chang'e-4 kapsülü |

Üreteçte bir kural daha: `derin_yok` alanı. Bir durağın derin katmanından
**bilerek** vazgeçilebilir ama gerekçe yazmak zorunlu. Sessizce eksik
bırakmakla bilerek vazgeçmek arasındaki fark, yazılı gerekçe. Şimdilik tek
kullanıcısı durak 4: çizelgenin kendisi zaten on bir kare ve on bir not,
yani derin katman ekranın üstünde duruyor.

Sayfa hâlâ **dağıtılmadı** ve portalda **hiçbir yerden bağlantısı yok**.

### Dördüncü turun ikinci geçişi — altı düzeltme

**Çizelgeden sürükleme kaldırıldı.** Denemede kontrolden çıktı: şeridin her
yeri dokunağa açık olduğu için okur kaydırmak isterken yıl değiştiriyor,
yıl seçmek isterken sayfayı kaydırıyordu — iki niyet tek alanda
çarpışıyordu. Şerit artık `IgnorePointer` içinde: hiçbir dokunağı
dinlemiyor, hatta yutmuyor. Yıl yalnız ‹ › ile değişiyor.

Kaybedilen "zamanı parmağıyla geçmek" duygusuydu; ama çalışmayan bir
duygu, duygu değil. Boşluk hâlâ görülüyor: her basış eşit bir adım ama
ekranda eşit olmayan bir yol, ve 1926→1988 sıçraması hepsinden uzun.

Sürükleme kalkınca iki kusur daha çıktı ve ikisi de onarıldı:

- **Hızlı basışlar yutuluyordu.** Düğme hedefi o anki animasyon
  konumundan hesaplıyordu; kafa daha 0,3'teyken basılan ikinci "ileri"
  yine 1'i hedefliyordu. Okur altı kez bassa bir adım gidiyordu. Hedef
  artık `_hedef` alanında ayrı tutuluyor, animasyon ona yetişiyor. Kart,
  arka kare, sayaç ve künye basışla birlikte değişiyor; çizgi arkadan
  geliyor.
- **Düğmeler yer değiştiriyordu.** Karesi olmayan durakta künye satırı
  kayboluyor ve ‹ › yukarı sıçrıyordu; okur her durakta hedefini yeniden
  arıyordu. Satır artık koşullu değil, boş olarak duruyor.

**2019'un gerçek karesi bulundu.** CNSA'nın kendi yayını: Yutu-2 gezgini
Chang'e-4'ten ayrılırken, 15 Şubat 2019. Dosyadaki ilk **CC BY 4.0** kare
— kamu malı değil, atıf şartlı; künye bunu söylüyor.

**2018'in karesi yok ve olmayacak.** Lunar Palace 1 dört adla (Lunar
Palace, Yuegong-1, 月宫一号, Beihang) ve üç dilde arandı; İngilizce ve
Çince Wikipedia maddelerinde bile tek görsel yok. Gerekçe o kilometre
taşının `_KARESIZ_NEDEN` alanında duruyor. Kapatılmamış yol: Beihang
Üniversitesi'nden lisanslı kare istemek — Schrenkiella'da Ege
Üniversitesi için söylenenin aynısı.

**2018 ne ölçtüğünü söylüyor artık.** Eski not tarih ve süre veriyordu
ama ölçülen şeyi vermiyordu. Yenisi veriyor: kabin kendi havasını, suyunu
ve yiyeceğini ne oranda geri kazanabiliyor? Yüzde 98 — dışarıdan yalnızca
yüzde 2. Başlık da değişti: *Kapı 370 gün kapalı kaldı.*

**Tohum durağının karesi değişti.** Eskisinde eldivenli eller ve siyah
torbalar vardı, tohum hiç görünmüyordu. Yenisi cımbızın ucunda tek bir
biber tohumu — uzaya gönderilmeden önce, NASA laboratuvarında.

**Kapanışın son cümlesi kapağa çıktı.** *"Uzayda aradığımız çözümler,
zaten burada ihtiyacımız olanlardı."* Derin katmanın sonundaydı, artık
son durağın ekranında. Yerini aldığı LED patenti cümlesi kapaktan
kalktı ama kaybolmadı; derin katmanın üçüncü paragrafında duruyor.

**Kare sayımı:** 20 kare. On sekizi NASA ve kamu malı; Tsiolkovski
(Wikimedia, kamu malı) ve Chang'e-4 (CNSA, CC BY 4.0) ayrı. Açık lisanslı
kare bulunamayan iki konu kaldı: Schrenkiella parvula ve Lunar Palace 1.

### Anasayfa kapısı — şerit kart

İlk deneme tam genişlikte bir **bant**tı, sergi bandının üstünde. Kullanıcı
reddetti: bant değil **kart** olacak, Nexus şeridi gibi alçak yatay bir
şerit, ve **Tarım-Bilim ve Raporlar'ın altında**. Nexus yalnız BİÇİM
örneği — tasarım, renk ve içerik dosyanın kendinden gelecek.

**Komşuluk konuya göre.** Bilim ve rapor okuyan okur zaten orada; dosya o
akışın doğal devamı. Sayfanın sonuna konduğunda okurların çoğu oraya hiç
inmiyordu.

**Fotoğraf yok, bilerek.** Anasayfada zaten iki fotoğraflı koyu blok var:
sergi bandı ve Nexus şeridi. Üçüncüsü "üç ayrı koyu fotoğraflı kutu"
demek olurdu ve okur hangisinin ne olduğunu kareden ayıramazdı. Şerit
onun yerine DOSYANIN ATMOSFERİNİ taşıyor: karanlık modül içi ve sol üstten
gelen pembe yetiştirme ışığı. Dosyayı açan okur aynı karanlığa giriyor —
şerit bir afiş değil, kapının kendisi.

İlk hâlde ışık tek bir zayıf radyal gradyandı ve şerit düz siyah bir çubuk
gibi okunuyordu. Artık yatay bir geçişle destekleniyor: sol aydınlık, sağ
karanlığa düşüyor.

**Grafik süs değil, veri.** Sağ taraftaki çizgi dosyanın kendi zaman
çizelgesi: on bir kilometre taşı GERÇEK yıl oranlarında. 1926-1988
arasındaki altmış iki yıllık boşluk şeritte de görünüyor, sağ uçtaki
yığılma da. Son nokta — bugün — halesiyle duruyor. Yıllar
`uzay_duraklar.g.dart`'tan okunuyor; hiçbir nokta elle yerleştirilmedi.
Çizelge önce metnin altındaydı ve sağ yarı bomboş kalıyordu; yana alınınca
hem boşluk doldu hem çizgiye nefes alanı kaldı. 900 pikselin altında
metnin altına iniyor, 600'ün altında yıl etiketleri düşüyor.

**Filiz.** Açılış animasyonunun küçük kardeşi, şeridin sol ucunda — ışığın
zaten düştüğü yerde. Açılıştaki boyacı tam ekran için ölçülmüş (ışık
konisi, bulanıklık yarıçapları, kök dallanması); altmış piksellik kutuda
lekeye dönüyordu, o yüzden şeridin kendi daha yalın çizimi var: tohum,
gövde, iki yaprak, üstte LED çubuğu. Teknik aynı — yol ölçeklenmiyor,
`extractPath` ile gerçekten çiziliyor.

Döngü sekiz buçuk saniye: çizim üç saniye, uzun bir duruş, sönüş, yeniden.
Haber akışının içinde sürekli dönen bir animasyon okuma sırasını keser ve
reklam gibi okunur. Cihazda hareket azaltma açıksa animasyon hiç
kurulmuyor; filiz çizilmiş hâliyle duruyor.

Telefonda da var, küçülerek: animasyon bu kartın karakteri ve okurların
çoğu telefondan bakıyor.

**Sayı hafızadan yazılmıyor.** "19 durak" sayılıyor; dosyaya durak
eklenince cümle kendiliğinden düzeliyor.

`push` kullanılıyor, `go` değil — okur geri döndüğünde anasayfada
kaydırdığı yeri kaybetmiyor.

### İlk dağıtım ve canlıda çıkan iki kusur (14 Kasım 2026)

`./deploy.sh --hosting` ile dağıtıldı — **fonksiyonlara dokunulmadı**.
Çıplak `./deploy.sh` depoda karşılığı olmayan dört fonksiyonu (columnistAudio,
homeRenderer, indexNowPing, publishScheduled) silmeye kalkıyor; değişiklik
zaten tamamen ön yüz olduğu için hosting yeterliydi.

Bekçilerin hepsi geçti: durum bekçisi 11 veritabanı satırını depoyla
karşılaştırdı, ayrışma yok; sürüm bekçisi 25 belirtecin tamamını derlemede
buldu. Başka bir forkun yarım kalan Mısır dosyası `draft` olduğu için
statik sayfası üretilmedi — yani canlıya çıkmadı.

Canlıda iki kusur çıktı ve ikisi de ölçülerek düzeltildi:

**Şeritteki cümle kesiliyordu.** 1024 piksellik ekranda "…çabasının y…"
diye bitiyordu. Sebep: çizelgenin metnin yanına geçme eşiği 900'dü ve bu
sayı ölçülmeden seçilmişti. Hesap: yanlar 54 + filiz ve boşluğu 78 + ok 36
+ aradaki boşluklar 48 ≈ 216 piksel metne kalmıyor; geri kalanın metne
düşen payı cümleyi tek satırda taşımalı. 1024'te taşımıyor. Eşik **1150**
oldu ve metnin payı 5/11'den 6/11'e çıktı. Altındaki genişliklerde çizelge
metnin altına iniyor; orada bütün satır onun.

**Giriş animasyonu çok hızlıydı.** Kullanıcının sözüyle "ne olduğunu
anlamadan geçip bitiyor". Yedi evre 3200 ms'ye sıkışınca her birine yarım
saniye düşüyordu. Süre **6000 ms** oldu ve eşit dağıtılmadı: anlamı taşıyan
evreler (tohum, kök, gövde) payın çoğunu aldı — animasyonun söylediği şey
bir tohumun kendini kurması. Kapanış (kare büyümesi, başlık) kısa kaldı;
orada okur zaten ne olacağını biliyor. Atlama düğmesi her an duruyor.

### Canlıdan gelen dört kusur daha

**Giriş animasyonu görünmeden akıyordu.** Süreyi 3200'den 6000 ms'ye
çıkarmak yetmedi; kullanıcı yine "1 saniyeye bile varmadan kayboluyor"
dedi. Sebep süre değilmiş: `AnimationController` GERÇEK ZAMANLA ilerliyor
ve soğuk açılışta CanvasKit ısınırken, yazı tipleri inerken, ilk kareler
düşerken animasyon arka planda akıp bitiyordu. Okur çizimin sonunu, bazen
hiçbir şeyini görmüyordu.

Artık `forward()` `initState`'te çağrılmıyor. İki şey bekleniyor: kapak
karesinin çözülmesi (animasyonun sonunda o kare açılıyor) ve bir GERÇEK
karenin ekrana çizilmesi (`endOfFrame`) — motorun ısındığının tek dürüst
işareti. Kare gelmezse üç saniyede vazgeçiliyor; giriş bir fotoğraf
yüzünden hiç oynamamaktansa fotoğrafsız oynasın.

**Telefonda kareler tanınmıyordu.** "Astronotlar ekran dışında, ne görseli
olduğu belli olmuyor." Geometrik bir kusurdu: kareler yatay (≈3:2), telefon
ekranı dikey (≈0,46), ve `BoxFit.cover` ikisini eşitlemek için karenin
GENİŞLİĞİNİN yüzde yetmişini kırpıyordu. İlk yemek karesinde iki astronot
da kenarda duruyor, yani ikisi birden düşüyordu.

Dar ekran artık masaüstünün 'ustunde' bileşimine zorlanmıyor; kendi
bileşimi var: kare 4:3'lük bir bantta tam genişlikte (kaynaktan yüzde on
bir kırpıyor, yetmiş değil), metin karenin ÜSTÜNDE değil ALTINDA, durağın
kendi zemininde. Hem kare tam görünüyor hem metin fotoğrafla yarışmıyor.

**Şemanın dokunma hedefi iki pikseldi.** Telefonda adım etiketi
gizleniyordu ve geriye yalnız iki piksellik çizgi kalıyordu — dokunma
hedefi o kadardı. Çizginin ince olması tasarım; dokunağın ince olması
kusur. İkisi ayrıldı: çizgi iki piksel kaldı, hedef 44 noktaya çıktı.
Telefonda çizginin altına SIRA NUMARASI kondu — altı parça gerçek bir
sıra, yani numara süs değil bilgi.

**Şeritteki cümle 1024'te kesiliyordu** (yukarıda anlatıldı): eşik 900'den
1150'ye, metnin payı 5/11'den 6/11'e.

### Mobilde beş onarım daha

**Çift geçiş.** Kullanıcı: "önce tam ekran görselli kareye geçiyor, 1 sn
kalmadan asıl ilk kareye geçiyor." Giriş kapağı TAM EKRAN açıyordu ama
telefonda ilk durak kareyi 4:3 bantta gösteriyor; devir anında kare bir
büyüyüp bir küçülüyordu. Giriş artık durağın bileşimini taklit ediyor —
aynı bant, aynı zemin. Devredilen şey zaten aynı olduğu için devir
görünmüyor. Üstüne devir de ani değil: 560 ms'de eriyor.

**Sondaki acele.** Kare açılımı ile başlık son yüzde on sekize sıkışmış
ve birbirinin üstüne biniyordu. Çizim öne alındı, ikisine yer açıldı,
sona kısa bir duruş kondu (0,96-1,0). Süre 6600 ms.

**Derin katman alttan yavaş açılıyor** — 640 ms, kapanış 380. Derin
katman bir bildirim değil, okurun bilerek açtığı ikinci bir oda; açılışı
o ağırlıkta. Kapanış kısa, çünkü okur kapatmaya karar verdiğinde
beklemek istemiyor.

**Altı parçada 'derine in' yok.** Şemanın kendisi altı adım ve her adımın
notu ekranda; derin katman zaten görünür. Durak 4'teki gerekçenin aynısı,
`derin_yok` alanına yazıldı.

**Künyedeki giriş cümlesi kaldırıldı.** Belgelerin kendisi aynı şeyi
söylüyordu; cümle listenin üstünde onu bir de ilan ediyordu.

### Paylaşım

**Kart — fotoğraflı**, 1200×630, `web/paylasim/uzayda-tarim.jpg`. Ülke
dosyalarının kartı tipografik çünkü kapakları da tipografik; bu dosya öyle
değil, on dokuz durağın on beşi bir fotoğrafla açılıyor ve kapak karesi
dosyanın en güçlü anı. Önizleme kartının işi merak uyandırmak.

Perde soldan sağa koyulaşıyor: metnin durduğu yan neredeyse opak, sağ
taraf açık — şeritteki çözümün aynısı. "19 durak" elle yazılmadı,
`duraklar.json`'dan sayılıyor. Fontlar base64 gömülü; ağdan çekilse
Chromium yavaş ağda SESSİZCE sistem fontuyla ekran görüntüsü alır ve fark
ancak kart paylaşıldığında görülürdü.

**Statik kabuk** — `build/web/uzayda-tarim/index.html`. Firebase statik
dosyayı yönlendirmeden önce sunuyor; og etiketleri içinde, Flutter yine
normal açılıyor. Cloud Function yok. Kanonik alan adı `statik_sayfa.mjs`
ile aynı tutuldu — ikisi ayrıştığında site kendini bir alan adıyla tanıtıp
başkasına çağırır, hiçbir şey kırılmaz ve kimse fark etmez.
`deploy.sh`'nin HAZIRLIK adımına bağlandı.

**Paylaş satırı** künyenin en altında: dört küçük düğme (paylaş, bağlantı,
WhatsApp, X), 36 nokta. Dosyanın üstünde geri düğmesinden başka hiçbir şey
yok ve bu bilerek — akış on dokuz durak, her çerçeve okumayı böler. Düğme
okurun dosyayı BİTİRDİĞİ yerde; paylaşmaya karar vermek için önce okumak
gerekiyor. Portalın kendi geleneği de bu.

**Giriş animasyonu için ek iş gerekmedi.** Animasyon oturum başına bir kez
oynuyor ve paylaşılan bağlantı her zaman yeni oturum demek — bağlantıyı
açan kişi zaten animasyondan başlıyor. Sorgu parametresi ya da işaret
koymak gereksiz karmaşa olurdu.

Canlıda doğrulandı: `<title>`, description, canonical, og:title,
og:description, og:url, og:image (+ boyut/tür/alt) ve twitter etiketleri
doğru; kart 200 ve image/jpeg olarak sunuluyor; sayfa kabuktan açılıyor.

### Canlıdan dört kusur daha

**Derin katman hızlı açılıyor ve BİR DAHA KAPANMIYORDU.** Denetleyiciyi
elle kurup `vsync: this` ile EKRANA bağlamıştım. Kipli pencere altındaki
ekranı örtünce Flutter o ekranın `TickerMode`'unu kapatıyor — görünmeyen
sayfanın animasyonları pil harcamasın diye. Denetleyici ekrana bağlı
olduğu için o susturmadan payını alıyordu: açılış yarıda kalıyor, kapanış
hiç ilerlemiyor, pencere ekranda asılı kalıyordu.

`sheetAnimationStyle` bunun için var: denetleyiciyi Flutter kendi kuruyor
ve PENCERENİN rotasına bağlıyor, yani örtülen ekranla birlikte susmuyor.
Hem gidiş hem dönüş süresini tanıyor. 620 ms açılış, 360 ms kapanış.

**Paylaş satırı görünmüyordu.** Künyenin EN SONUNA koymuştum — "okur
dosyayı bitirdiği yerde" diye. Kâğıtta doğru, ekranda yanlış: künye dokuz
belge ve uzun bir görsel notu taşıyor, kimse o kadar aşağı inmiyor.
Kullanıcı: "varsa da ben görmedim." Görülmeyen düğme yok demektir. Satır
başlığın hemen altına alındı.

**Künye kart gibi inmiyordu.** Dış liste `itemExtent` ile her öğeyi tam
ekran boyuna zorluyordu; künye o boya sığmadığı için kendi içinde
kaydırılıyor, dış liste duruyordu. Ekranda görünen: duraklar donuyor,
künyenin METNİ tek başına yukarı akıp durakların altına giriyor.

`itemExtent` kaldırıldı. Duraklar kendi `SizedBox`larıyla tam ekran
boyunda, künye İÇERİĞİ KADAR uzun (en az bir ekran) ve iç kaydırması yok.
Dış liste onun üstünden geçiyor — künye bir kart gibi yukarı çıkıyor.
Durakların ilerleme hesabı bozulmadı: hepsi künyeden önce ve hepsi hâlâ
tam ekran boyunda. Durak gövdesi `_durakIcerigi` yöntemine alındı, çünkü
boy sarmalayıcısı tek yerde durmalıydı; altı dönüş noktasının her birine
ayrı `SizedBox` koymak aynı kararı altı kez tekrarlamak olurdu.

**Masaüstünde kaydırma oku.** İlk durak tam ekran bir fotoğraf ve devamın
aşağıda olduğunu söyleyen hiçbir işaret yoktu. Alt ortaya ince bir ok
kondu: dolgu yok, çerçeve yok, yazı yok — yumuşak bir iniş-çıkış ve okur
kaydırmaya başlar başlamaz siliniyor. Telefonda yok: orada metnin ekran
altında kesilmesi zaten "devamı var" diyor. Hareket azaltma açıksa ok
duruyor ama kıpırdamıyor.

### Devir: mobil ile masaüstü arasındaki üç fark

Kullanıcı masaüstündeki devri doğru buldu, mobildekini bulmadı: "ilk kareye
geçtiği an UZAYDA TARIM metni hâlâ görünüyor, saniyenin altında bir sürede
ilk kare ikinci kez fade in yapıp metin öyle kayboluyor."

Giriş kapağı ile durağın ilk karesi arasında ÜÇ fark vardı. Üçü de
masaüstünde de vardı ama orada kare tam ekran olduğu için gözden
kaçıyordu; dar ekranda 4:3 bandın kenarları sabit olduğu için içindeki
her kayma görülüyor.

| fark | eski | şimdi |
|---|---|---|
| ölçek | kapak 1,0 · durak 1,06 | ikisi de 1,06 |
| başlık | devir boyunca tam opak | girişin içinde sönüyor (0,93-1,0) |
| alt geçiş | durakta var, kapakta yok | ikisinde de var |

Ölçek farkı en can alıcıydı: yüzde altılık fark, 560 ms'lik erime boyunca
karenin "nefes almasına" yol açıyordu — kullanıcının "ikinci kez fade in"
diye tarif ettiği şey buydu.

Başlık artık devir başlamadan önce siliniyor, yani erime sırasında ekranda
iki metin birden durmuyor. Giriş 7200 ms'ye çıktı ki başlığın görünme ve
sönme payı olsun.

**Doğrulanamayan:** devir anının kendisi 560 ms sürüyor ve ekran
görüntüsüyle o pencereyi yakalamak güvenilir değil. Üç fark kod
düzeyinde giderildi ve ölçüldü; devrin gözle nasıl durduğu kullanıcının
bakmasıyla anlaşılacak.

