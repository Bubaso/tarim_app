# Ziraat Bankası — ham kaynaklar

Zincir: **kaynak → `_raw/` → `data.json` → `grafikler.json` → seed → veritabanı.**
Bu klasör zincirin ilk halkası. Buradaki hiçbir dosya elle düzenlenmez;
`./cek.sh` ve `./bddk_cek.py` yeniden çalıştırılarak tazelenir.

## Çekilenler

| Dosya | Kaynak | Ne için |
|---|---|---|
| `site_tarihce.html` → `tarihce.json` | Ziraat Bankası · Bankamız Tarihçesi | 1863–2025 kilometre taşları, 51 yıl |
| `faaliyet_2025.pdf` (344 s.) | Ziraat · 2025 Entegre Faaliyet Raporu | Tarım Bankacılığı bölümü, mali tablolar |
| `faaliyet_2023.pdf` (496 s.) | aynı, 2023 | Seri: 2022–2023 |
| `faaliyet_2021.pdf` (217 s.) | aynı, 2021 | Seri: 2020–2021 |
| `bddk_sektorel_kredi.json` | BDDK Aylık Bülten · Sektörel Kredi Dağılımı | **Payda:** Türkiye'nin toplam tarımsal kredisi |
| `site_bugun.html` | Ziraat · Günümüzde Ziraat Bankası | Kurumun kendi anlatısı — tanıtım metni, veri değil |
| `site_tarim_bankaciligi.html` | Ziraat · Ticari → Tarım | Ürün adları ve limitler |
| `site_tarimkredi.html` | Tarım Kredi Koop. · Biz Kimiz | Bugünkü iş bölümü |
| `site_creditagricole_tarih.html` | Crédit Agricole · History | 12. bölüm: karşılaştırma |
| `site_creditagricole_profil.html` | Crédit Agricole · Discover the Group | Bugünkü ortak sayısı |

**Üç faaliyet raporu, beş değil.** Her biri ~16 MB; beşi 80 MB ederdi. Her rapor
bir önceki yılın karşılaştırmalı rakamını taşıdığı için 2025/2023/2021 üçlüsü
2020–2025 aralığını kapatıyor.

## Ağ sınırı — TMO dosyasındaki tuzağın aynısı

`mevzuat.gov.tr` ve `resmigazete.gov.tr` bu ağdan **açılmıyor** (bağlantı hiç
kurulmuyor, curl `000`). Kanun ve nizamname künyeleri bu yüzden yalnızca
bankanın kendi belgelerinden geliyor.

**Kural: birincil kaynaktan doğrulanamayan Resmî Gazete tarih/sayısı metne
YAZILMAZ.** TMO'da kuruluş kanununun RG sayısı bu sebeple hiç yazılmadı;
burada da aynısı geçerli.

`data.tuik.gov.tr` JavaScript istiyor, curl ile okunmuyor. **Sonucu aşağıda,
"Enflasyon" başlığında.**

## Doğrulanmış — birincil kaynaktan okundu

### Kuruluş ve hukuki kimlik zinciri
`tarihce.json` (bankanın kendi metni):

| Yıl | Olay |
|---|---|
| **1863** | Mithat Paşa, Pirot kasabası, **Memleket Sandıkları** (20 Kasım). İlk tarımsal kredi: 3–12 ay vade, kişi başına azami 20 lira. |
| 1867 | Memleket Sandıkları Nizamnamesi — "ülkemizde ilk kez teşkilatlı kredi sistemi mevzuatı" |
| 1881 | Edirne'de yabancı sermayeyle banka kurma girişimi — başarısız |
| **1883** | **Menafi Sandıkları.** Aşar vergisine "**Menafi Hissesi**" zammı yapılarak sandıklara daimi kaynak yaratıldı. |
| **1888** | Ziraat Bankası Nizamnamesi (28 Ağustos), Umum Müdürlüğü faaliyete geçti (17 Eylül). İlk umum müdür **Mikail Portakalyan**. İlk faizli mevduat. Nominal sermaye 10 milyon TL; **devlet müessesesi**. |
| 1892 | Hazineye ilk kredi verildi |
| 1916 | Ziraat Bankası Kanunu (23 Mart). İlk tohumluk kredisi. Zirai alacaklarda ilk toplu erteleme. |
| **1919** | İzmir'i işgal eden kuvvetler ayrı bir Ziraat Bankası İdare Merkezi kurdu; işgal altındaki şube ve sandıkları ona bağladı. |
| **1920** | TBMM'nin açılmasıyla (23 Nisan) nüfuz alanındaki şubelerin idaresi Ankara Şubesi'ne verildi. Kuvâ-yi Milliye müfrezelerinin giderleri banka sandıklarından karşılandı. |
| 1922 | İzmir teşkilatı Ankara'ya bağlandı (9 Eylül); banka bütünlüğüne kavuştu (23 Ekim). |
| **1924** | **444 sayılı Bütçe Kanunu** (19 Mart). Gerekçe bankanın kendi ifadesiyle: "kaynaklarını günlük ihtiyaçlara harcayan hükümetlerin siyasi etkisinden kurtarmak, gerçek sahipleri olan çiftçilerin eline ve yönetimine teslim etmek." Banka devlet müessesesi olmaktan çıktı, **anonim şirket** oldu. |
| 1938 | 3460 sayılı Kanun; denetim Umumi Murakebe Heyeti'ne geçti. |
| 1945 | **3202 sayılı Kanun**'da öngörülen 198 maddelik TCZB Tüzüğü yürürlüğe girdi. |
| 1964 | KİT'lerin TBMM'ce denetimi; Umumi Heyet'in yerini KİT Karma Komisyonu aldı. |
| 1977 | Beş bölge müdürlüğü kuruldu (İzmir, İstanbul, Ankara, Erzurum, Diyarbakır) — merkezî yönetimden yerinden yönetime. |
| **2000** | **4603 sayılı Kanun** (kabul 25 Kasım 2000) ile T.C. Ziraat Bankası **yeniden anonim şirket** hâline getirildi. |
| 2001 | Kamu bankaları yeniden yapılandırması. **Emlak Bankası, Ziraat Bankası ile birleştirilerek kapatıldı.** |
| 2025 | Aktif büyüklüğü 8 trilyon TL'yi aştı. 162. kuruluş yılı. 20 ülkede hizmet. |

> **İki kez anonim şirket.** 1924'te devlet müessesesi olmaktan çıkarılıp A.Ş.
> yapıldı, 2000'de 4603 ile yine A.Ş. yapıldı. Aradaki dönüşüm zinciri
> `tarihce.json`'da tek tek yazılı değil; **"1924'te A.Ş. oldu, 2000'de tekrar
> A.Ş. oldu" diye yazmak arada ne olduğunu sormayı gerektirir.** 3202 sayılı
> Kanun (1945 maddesinde geçiyor) muhtemelen cevabın bir parçası ama TARİHİ
> BANKANIN METNİNDE YOK. Doğrulanana kadar metin bu geçişi ATLAR, uydurmaz.

### DÜZELTİLEN İKİ OKUMA HATASI
Sayfanın düzleştirilmiş metninden ilk okumada iki yanlış çıkarıldı; yapısal
ayrıştırma (`tarihce.json`) düzeltti:

- Menafi Hissesi **1867 değil 1883**.
- 10 milyon TL nominal sermaye ve "devlet müessesesi" **1916 değil 1888**.

*Ders: yıl listesi ile açıklama listesi ayrı HTML bloklarında; düz metin
okumasında hizalama kayıyor. Eşleştirme etiket yapısından yapılır.*

### 2025 tarım bankacılığı — `faaliyet_2025.pdf` s.59–63

| Kalem | Değer |
|---|---|
| Tarım kredileri bakiyesi (yıl sonu) | **831 milyar TL** |
| Yıl içinde tarım kredisi kullanan müşteri | 684 bin+ (61 bini yeni) |
| Yıl sonu kredili müşteri sayısı | 924 bin+ |
| Sübvansiyonlu kredi | 589 bin üretici · 565 milyar TL+ |
| Bitkisel üretim — bakiye / kredili müşteri | 263 milyar TL · 518 bin |
| **Hayvansal üretim — bakiye / kredili müşteri** | **418 milyar TL** · 401 bin |
| Mekanizasyon — bakiye / kredili müşteri | 89 milyar TL · 295 bin |
| Basınçlı sulama — bakiye / kredili müşteri | 22 milyar TL · 56 bin |
| Arıcılık | 5.700+ üretici · 890 milyon TL · azami 300.000 TL |
| Balıkçı Destek Kredisi | 600 üretici · 523 milyon TL |
| Lisanslı depoculuk kredileri | 8,2 milyar TL (ELÜS karşılığı 474 milyon TL) |
| TARSİM'in hayat dışı sigorta portföyündeki payı | %46 |

Banka geneli 2025: aktif 8.474 milyar TL (pazar payı %18,1), mevduat 5.405,
nakdi krediler 4.240, net dönem kârı 161 milyar TL.

> **Hayvansal kredi bitkiselden büyük** — 418'e karşı 263 milyar TL. Bakiye
> sıralaması müşteri sayısı sıralamasının tersi (bitkisel 518 bin, hayvansal
> 401 bin). Sezgiye aykırı ve doğrudan rapordan.

### Ziraat'in Türkiye tarımsal kredisindeki payı
Pay: `faaliyet_*.pdf` · Payda: `bddk_sektorel_kredi.json` (BDDK, "Tarım" satırı,
toplam nakdi krediler, tüm bankalar):

| Yıl | Ziraat | Türkiye (BDDK) | Ziraat payı |
|---|---|---|---|
| 2021 | 109 milyar TL | 166,2 milyar TL | ~%66 |
| 2023 | 437 milyar TL | 584,1 milyar TL | ~%75 |
| 2025 | 831 milyar TL | 1.224,5 milyar TL | ~%68 |

> **Tanım sınırı.** BDDK'nın "Tarım" sektör kodu ile bankanın kendi "tarım
> kredileri" tanımı birebir örtüşmeyebilir. Oran **yaklaşık** verilir; ondalıklı
> kesinlik iddia edilmez. Bu sınır metinde de belirtilir.

### Enflasyon — nominal seri GRAFİĞE KONMAYACAK
2021→2025 arası tarım kredisi bakiyesi 109 → 831 milyar TL; nominal 7,6 kat.
Bu yıllar yüksek enflasyon yılları ve **reel karşılığı bambaşka.**

`data.tuik.gov.tr` JavaScript istiyor, TÜFE endeksi birincil kaynaktan
çekilemiyor. TCMB EVDS anahtar istiyor. **Karar: çekilemeyen bir deflatörle
düzeltme yapılmaz, düzeltilmemiş seri de büyüme diye gösterilmez.**

Büyüme bunun yerine enflasyondan etkilenmeyen üç ölçüyle anlatılır:
1. **Kredili müşteri sayısı** — 725 bin (2021) → 924 bin (2025)
2. **Ziraat'in sektör payı** — yukarıdaki oran
3. **Portföy bileşimi** — yatırım/işletme kredisi oranı: %36/%64 (2021),
   %31/%69 (2023)

Tek yıla ait tutar (831 milyar TL) **anlık fotoğraf** olarak verilebilir.

### 12. bölüm — Crédit Agricole
`site_creditagricole_tarih.html`, `site_creditagricole_profil.html`
(Crédit Agricole'un kendi tarih ve profil sayfaları):

- 19. yüzyıl sonunda Fransız çiftçisi uygun kredi bulamıyordu — **1863
  Osmanlı'sındaki sorunun aynısı.**
- 1884 mesleki örgütlenme kanunu çiftçi birliklerine izin verdi.
- **1885** · Louis Milcent ve Alfred Bouvet, Salins-les-Bains'de (Jura) ilk
  yerel tarım kredi kasasını kurdu — *Ziraat'in Memleket Sandıkları'ndan
  22 yıl SONRA.*
- **5 Kasım 1894 Kanunu** · Crédit Agricole resmen doğdu. Dayanak **karşılıklılık
  (mutualité)**: çiftçi birliği üyeleri kendi sorumluluklarında yerel kasa
  kurabiliyor. Kanunun arkasındaki isim Jules Méline.
- Yönetim ilkesi: **kişi başına tek oy**, hisse sayısından bağımsız.
- 1897 · Kasalar sermayesiz kalınca hükümet Banque de France'ı görevlendirdi:
  40 milyon altın frank bağış + yılda 2 milyon frank.
- 1899 Kanunu · Bölge Bankaları — piramidin ikinci katı.
- Bugün (kendi profil sayfası): 55 milyon perakende müşteri, **12,3 milyon
  ortak (mutual shareholder)**, 160 bin çalışan.

> **Karşılaştırmanın ekseni sahiplik, büyüklük değil.** İkisi de devlet parasıyla
> ayağa kalktı — biri aşar zammıyla, öteki Banque de France bağışıyla. Ayrım
> oyların kimde olduğunda: Ziraat'in tek sahibi var, Crédit Agricole'un 12,3
> milyon ortağı.

**Rabobank ve Raiffeisen kapsam dışı kaldı.** `rabobank.com`, `rabobank.nl` ve
`media.rabobank.com` bu ağdan **403** dönüyor (tarayıcı kimliğiyle de).
`raiffeisen.ch` tarih sayfaları 404. Üç bankayı yüzeysel anlatmaktansa tek
bankayı derin anlatmak seçildi; 12. bölüm Crédit Agricole üzerine kurulu.

## ŞÜPHELİ — kullanılmayacak

**"Genç çiftçilere 172,3 milyar TL."** Aynı rakam (172,3 milyar TL) aynı raporda
s.65'te "2025 ihtiyaç kredisi kullandırımı" olarak da geçiyor. İki farklı kalem
için aynı ondalıklı rakam tesadüf olamayacak kadar spesifik; rapor hatası veya
çıkarma karışması olabilir. **Doğrulanana kadar metne girmez.**

**İnfografik sayfaları kaynak değil.** s.7'de sayılar etiketlerinden kopuk
çıkıyor (`"8,5 Trilyon TL 1.745 Adet 24,8 Milyon..."` — hangi sayı hangi
başlığa ait belli değil). Rakam yalnızca anlatı metninden veya mali tablodan
alınır.

## AÇIK — kaynak aranıyor

1. **3202 sayılı Kanun'un tarihi.** 1945 maddesinde adı geçiyor, tarihi yok.
   Bulunamazsa metin 1924–2000 arası hukuki geçişi ATLAR, tarih uydurmaz.
2. **Ziraat ↔ Tarım Kredi Kooperatifleri tarihi.** Kooperatiflerin kuruluşu ve
   bankadan ayrılışı hiçbir çekilen kaynakta yok; `site_tarimkredi.html`
   yalnızca bugünü anlatıyor. Kaynaksız tarih yazılmayacak.
3. **Buğday Masası → TMO.** Kaynak Ziraat'te değil, TMO dosyasında
   (`content/dossiers/tmo/_raw/kurum_hakkinda.pdf`): iş 1932'de Ziraat
   Bankası'na verilmiş, 1938'de "Buğday Masası Şefliği" ayrılarak TMO olmuş.
   Ziraat'in kendi tarihçesi bundan söz etmiyor — **atıf TMO belgesine yapılır**,
   Ziraat'e değil.
4. **Bankacılık Müzesi.** Faaliyet raporunda yalnızca adı geçiyor, içerik yok.
   Bu yüzden müze bölüm olmaktan çıkarıldı; 11. bölüm ("Kovan, tekne, ELÜS")
   yerine geçti ve tamamı faaliyet raporundan kaynaklı.
5. **Görseller.** Wikimedia Commons taraması yapılmadı. Elde hazır tek görsel:
   1930'lar Ankara'daki Ziraat Bankası binası (Directorate General of Press and
   Information · No restrictions), şu an TMO dosyasının 2. bölümünde kullanılıyor.
