# DSİ — Kurum Dosyası Sayı 05 · ham kaynak kaydı

**Tur 1 (kaynak katmanı) tamam.** Dokuz kaynağın dokuzunun kimliği
`dogrula_kaynak.py` ile sınandı. Eksen HENÜZ SEÇİLMEDİ — §8.12'nin kuralı:
bir bölümün biçimi kaynaktan önce seçilmez.

```
bash cek.sh                                    # çekim
~/tarim_ai_pipeline/venv/bin/python dogrula_kaynak.py   # kimlik sınaması
```

> `pypdf` sistem Python'unda yok, hat venv'inde var. Bu dosyanın bütün PDF
> işleri o yorumlayıcıyla çalışıyor.

## Kaynaklar ve SINIFLARI (§2.2 — üç sınıf karıştırılmaz)

| dosya | sınıf | ne |
|---|---|---|
| `kanun_6200.pdf` | **BİRİNCİL** | DSİ Genel Müdürlüğünce Yürütülen Hizmetler Hakkında Kanun · kabul 18/12/1953 · RG **25/12/1953 · 8592** · 24 sayfa |
| `kanun_6172_sulama_birlikleri.pdf` | **BİRİNCİL** | Sulama Birlikleri Kanunu · kabul 8/3/2011 · RG **22/3/2011 · 27882** · 11 sayfa |
| `faaliyet_2025.pdf` | KURUMUN BEYANI | 136 sayfa |
| `faaliyet_2022.pdf` | KURUMUN BEYANI | 164 sayfa |
| `faaliyet_2019.pdf` | KURUMUN BEYANI | 181 sayfa |
| `site_hakkimizda.html` | KURUMUN BEYANI | misyon + kurumsal silsile |
| `site_toprak_su_kaynaklari.html` | KURUMUN BEYANI | ülke su potansiyeli |
| `site_sulama_dairesi.html` | KURUMUN BEYANI | sulama dairesi görevleri |
| `site_istatistik.html` | KURUMUN BEYANI | haritalı istatistik bültenleri dizini |

**RG künyeleri birincil kaynaktan okundu.** TMO dosyasında bu mümkün
olmamıştı (§8.7: "henüz birincil kaynaktan doğrulanmadı"); `mevzuat.gov.tr`
10 Eylül 2026'da açıldı (§8.14.1) ve bu, dizinin RG künyesi taşıyan ikinci
dosyası oluyor.

## İlk iki bulgu — ikisi de birincil/beyan kaynaktan

**1. Kuruluş maddesi mülga.** 6200'ün 1. maddesi:
`(Mülga: 2/7/2018 – KHK-703/69 md.)`. Kanun duruyor, kurumu tarif eden
madde yok. Neyin yerine geçtiği HENÜZ OKUNMADI — okunmadan yoruma
gidilmeyecek.

**2. Kurum kuraklıktan doğdu.** `site_hakkimizda.html` silsileyi veriyor:
1914 Nafıa Nezareti yeniden yapılanması → 1925 "Sular Fen Heyeti" →
**1929 şiddetli kuraklık ve kıtlık neticesinde "Sular Umum Müdürlüğü"** →
1953 DSİ. Kuruluş tarihi kanun metniyle BAĞIMSIZ OLARAK örtüşüyor
(18 Aralık 1953) — iki ayrı kaynak, aynı tarih.

## Tuzaklar — tekrar düşülmesin

**Dosya adı varsayımla verilmez.** `/Sayfa/Detay/754`'ü "tarihçe" sanıp öyle
kaydetmiştim; doğrulayıcı reddetti, sayfanın "Toprak Su Kaynakları" olduğu
çıktı. Kurumsal tarih ayrı bir sayfada değil, `hakkimizda`'nın içinde.
*Doğrulayıcının yakaladığı ilk şey bu oldu ve tek işi buydu.*

**CDN adresinde Türkçe harf.** 2019 raporunun dosya adında `İ` ve boşluk var;
curl ham hâlini `Malformed input to a URL function` diye **reddediyor**.
Yüzde kodlaması zorunlu: `İ` = `%C4%B0`, boşluk = `%20`. Sayfadan kopyalanan
adres olduğu gibi yapıştırılamaz.

**Yumuşak 404.** Kurum siteleri bilinmeyen adreste 200 + HTML döndürüyor
(§8.14.1, §2.12.1). `cek.sh` boyut eşiği koyuyor, `dogrula_kaynak.py` ise
sayfanın KENDİ başlığını arıyor. Durum kodu bu projede hiçbir şey kanıtlamaz.

**Doğrulayıcı üreticiden içe aktarmıyor** (§8.14.2). Normalleştirmeyi baştan
yazıyor; ortak yardımcı paylaşılsaydı ikisi de aynı yönde yanılırdı.

## Henüz ALINMAMIŞ kaynaklar

- **Sulama devir rakamları** — DSİ'nin inşa edip birliklere devrettiği tesis
  alanı. Faaliyet raporlarında olması bekleniyor, çıkarılmadı.
- **KHK-703'ün 69. maddesi** — 6200'ün 1. maddesini neyin yerine geçirdiği.
- **Sulanan arazinin toplam tarım arazisine oranı** — TÜİK ya da raporlardan.
- **İstatistik bültenleri** — `site_istatistik.html` dizin sayfası; bültenlerin
  kendisi indirilmedi.

---

# Tur 2 — mülga maddeler ve devir rakamları

## 1. Kuruluş kanunu içi boşaltılmış (BİRİNCİL)

`kanun_6200.pdf`: **2/7/2018 tarihli KHK-703'ün 69. maddesi** tek seferde
şunları mülga etmiş:

| | |
|---|---|
| **Madde 1** | kuruluş |
| **Madde 2** | vazife ve salahiyetler |
| **Madde 3–7** | teşkilat |
| ayrıca | 14, 18–23, 37–39, 56–58 · Ek Madde 3, 4, 8, 14 · Geçici Madde 1, 2, 3, 5, 6, 7, 8 |

Yaklaşık **otuz madde**. Kanun DSİ'nin adını taşımaya devam ediyor; kurumu
kuran, görevini tanımlayan ve teşkilatını kuran maddelerin hiçbiri yok.

**Ad da iki kez değişmiş.** Dipnot 1: kanunun adı 11/10/2011 tarihli 662
sayılı KHK'nin 49. maddesiyle *"Devlet Su İşleri Umum Müdürlüğü Teşkilat ve
Vazifeleri Hakkında Kanun"* iken *"Devlet Su İşleri Genel Müdürlüğünün
Teşkilat ve Görevleri Hakkında Kanun"* olmuş. Bugünkü başlık ise
*"…Yürütülen **Hizmetler** Hakkında Kanun"* — yani üçüncü bir ad.

> §8.7'deki TMO desenin su tarafındaki karşılığı: aynı isim, ardışık hukuki
> kimlikler. **HENÜZ OKUNMADI:** mülga maddelerin yerine hangi
> Cumhurbaşkanlığı Kararnamesi geçti. Okunmadan metinde "yerine şu geçti"
> denmeyecek.

## 2. Devir tablosu (KURUMUN BEYANI — faaliyet_2025.pdf, s. 47)

**Tablo 14 — Sulama Tesislerinin Devredilen Kuruluşlara Göre Dağılımı
(31.12.2025)**

| devralan | adet | adet % | alan (ha) | alan % |
|---|---:|---:|---:|---:|
| Sulama Birliği | 181 | 19 | 2.562.855 | 83,1 |
| Kooperatif | 414 | 44 | 193.740 | 6,3 |
| Belediye | 160 | 17 | 226.146 | 7,3 |
| Köy Tüzel Kişiliği | 164 | 18 | 29.472 | 1,0 |
| Diğer | 17 | 2 | 70.987 | 2,3 |
| **TOPLAM** | **936** | **100** | **3.083.200** | **100** |

**İki toplam da elle sınandı ve tutuyor** (§2.2'nin toplama kuralı):
181+414+160+164+17 = 936 · 2.562.855+193.740+226.146+29.472+70.987 = 3.083.200.

Asimetri dosyanın merkezinde duruyor: **birlikler tesislerin %19'u ama alanın
%83'ü.** Kooperatifler tam tersi — tesislerin %44'ü, alanın %6,3'ü.

## 3. Ölçek rakamları (KURUMUN BEYANI — faaliyet_2025.pdf)

| | değer | yer |
|---|---|---|
| Ekonomik olarak sulanabilir tarım arazisi | **8,5 milyon ha** | s. 43 |
| 2028 hedefi: sulama şebekesi tamamlanan alan (brüt) | **5,56 milyon ha** | s. 55, 111 |
| Tamamlanan sulama tesisi (kümülatif, 2025) | **3.654** (hedef 3.632 — aşıldı) | s. 111 |
| İnşa edilen baraj (kümülatif) | **1.081** (hedef 1.127 — ulaşılamadı) | s. 111 |
| İnşa edilen gölet (kümülatif) | **750** (hedef 760) | s. 111 |
| Su depolama kapasitesi (kümülatif) | **183.819,90 hm³** (hedef 190.951,80) | s. 111 |

Bölgesel sulama programları: GAP 1.057.803 ha · DAP 1.377.656 ha ·
KOP 1.647.239 ha (s. 48-49). **Bunlar birbirine ve yukarıdaki toplamlara
EKLENMEZ** — kapsamları ayrıca okunmadı.

## 4. Hâlâ eksik

- **DSİ'nin bugüne kadar sulamaya açtığı GERÇEKLEŞEN kümülatif alan.** Elde
  2028 hedefi (5,56 milyon ha) ve devredilen alan (3,08 milyon ha) var;
  gerçekleşen kümülatif rakam bu raporda bulunamadı. *"Devredilen = açılan"
  varsayılmayacak* — DSİ'nin kendi işlettiği tesisler de var (s. 45: "inşa
  edilerek işletilen veya sulama birliklerine devredilen pompaj…").
- **KHK-703'ün yerine koyduğu düzenleme** (muhtemelen 1 numaralı CBK).
- 2022 ve 2019 raporlarından aynı tablonun geçmiş değerleri — devrin zaman
  içindeki seyri için.

---

# Tur 3 — yerine ne geçti, devir ne zaman oldu

## 1. Kuruluş metni kararnameye taşınmış (BİRİNCİL)

`cbk_4_bagli_kuruluslar.pdf` — *Bakanlıklara Bağlı, İlgili, İlişkili Kurum ve
Kuruluşlar ile Diğer Kurum ve Kuruluşların Teşkilatı Hakkında Cumhurbaşkanlığı
Kararnamesi*, **Sayı 4**. Onuncu Bölüm:

| madde | ne diyor |
|---|---|
| **119** | Bölümün amacı: DSİ'nin kuruluş, teşkilat, görev, yetki ve sorumlulukları |
| **120** | *"Tarım ve Orman Bakanlığına bağlı, kamu tüzel kişiliğini haiz, merkezi Ankara'da bulunan özel bütçeli Devlet Su İşleri Genel Müdürlüğü **kurulmuştur**."* · (2) Kısa adı DSİ'dir. |
| **121** | Görev ve yetkiler — (a) taşkın sular ve sellere karşı koruyucu tesisler… |

**1953'ten beri var olan bir kurum, 2018'de bir kararnameyle yeniden
"kurulmuş".** 6200 adını taşımaya devam ediyor ama kurucu metin artık orada
değil.

> **ELENEN YOL, kayda geçsin:** önce CBK **1**'e (Cumhurbaşkanlığı Teşkilatı,
> RG 10/7/2018 – 30474) bakıldı. "Su İşleri" orada **sıfır kez** geçiyor —
> metin çıkarımı sağlam olduğu hâlde (294 sayfa, metin çıkmayan sayfa yok,
> "Genel Müdürlüğü" 627 kez). DSİ ana teşkilat kararnamesinde değil, bağlı
> kuruluşlar kararnamesinde.

## 2. Devir bir ANDA değil, elli dört yılda oldu

`istatistik_2021.pdf` s. 62 — *"II. KAT'İ DEVİR SÖZLEŞMESİ İMZALANMIŞ
OLANLARIN YILLARA GÖRE KÜMÜLATİF DEĞERLERİ"*, 1967–2020 kesintisiz seri:

| yıl | ünite | devredilen alan (ha) |
|---|---:|---:|
| 1967 | 1 | 50 |
| 1980 | 208 | 93.189 |
| 1990 | 697 | 210.181 |
| 2000 | 1.295 | 319.243 |
| 2010 | 2.060 | 427.307 |
| 2020 | 2.371 | 464.316 |

**KAPSAM UYARISI — bu iki rakam KARIŞTIRILAMAZ.** Sütun başlığı "Devredilen
**Kuyu** Sayısı": bu seri **yeraltısuyu (YAS)** tesislerinin devri, 2020'de
464.316 ha. Faaliyet raporundaki **3.083.200 ha** ise BÜTÜN sulama
tesislerini kapsıyor (31.12.2025). Biri ötekinin alt kümesi; toplanmaz,
birbirinin yerine kullanılmaz.

**KAYNAK KENDİYLE ÇELİŞİYOR — 1999 satırı.** Ünite sayısı 1998'de 1.187,
2000'de 1.295 iken 1999'da **151** yazıyor. Kümülatif bir seride düşüş
imkânsız; basım hatası (muhtemelen 1.251). Alan sütunu düzgün ilerliyor
(299.728 → 310.548 → 319.243). *O satırın ünite değeri metinde
KULLANILMAYACAK;* Avustralya'daki 2008-09 satırının aynısı.

## 3. Bulunamayan — ve varsayılmayacak olan

**DSİ'nin bugün KENDİ işlettiği ulusal sulama alanı tek bir rakam olarak
hiçbir kaynakta bulunamadı.** Arananlar: üç faaliyet raporu, 793 sayfalık
istatistik bülteni.

Bülten s. 64'teki *Çizelge 15-4* ayrımı YAPIYOR — "A. DSİ'CE İNŞA EDİLEN VE
İŞLETİLEN SULAMALAR" / "B. DSİ'CE İNŞA EDİLEN VE DEVREDİLEN SULAMALAR" — ama
tesis tesis listeliyor, ulusal toplam vermiyor. Ek çizelge 17-1'in bu ayrımı
toplamıyla verdiği yazılı (s. 74) ancak çizelgenin kendisi 793 sayfalık
dökümün içinde ayrıştırılamadı.

**Sonuç: "DSİ yapıyor ama işletmiyor" cümlesi BU HÂLİYLE YAZILAMAZ.**
Elimizde devredilen alan var (3.083.200 ha), devredilmeyen alan yok. Rapor
s. 45 DSİ'nin kendi işlettiği tesisler olduğunu açıkça söylüyor. Eksen ya bu
rakam bulunduktan sonra kurulur, ya da iddia "devrin ÖLÇEĞİ ve SÜRESİ"
üzerine daraltılır — ikisi de dürüst, üçüncü bir yol yok.

---

# Tur 7 — dünyada benzeri

**ABD · Bureau of Reclamation (USBR).** Aynı yapı, adı konmuş hâliyle: USBR
tesislerini resmen ikiye ayırıyor —

| | |
|---|---|
| **reserved works** | mülkiyeti de işletmesi de Reclamation'da |
| **transferred works** | mülkiyet Reclamation'da, işletme ve bakım sözleşmeyle yerel sulama bölgelerine (*irrigation districts*) devredilmiş |

Birincil alıntı, *Reclamation Manual* FAC 01-09 (`usbr_fac01-09.pdf`):
**"O&M is planned and managed by operating entities."**

Ölçü (usbr.gov/main/about/fact.html — kurumun kendi sayfası):

| | |
|---|---|
| Sulanan alan | **10 milyon akr** ≈ 4,05 milyon ha |
| Çiftçi | 140.000 — batıdaki her beş çiftçiden biri |
| Rezervuar | 296 · depolama 140 milyon akr-fit |
| Kanal | ~10.000 mil, **mülkiyeti Reclamation'da** |

**Neden bu karşılaştırma işe yarıyor:** DSİ verisinde EKSİK olan ayrımın ta
kendisi USBR'da resmî bir kategori. Türkiye'de "DSİ kendi işlettiği alan"
rakamı bulunamadı (tur 3/3); ABD'de aynı ayrım tesis sınıfı olarak tanımlı ve
raporlanıyor. Karşılaştırma bir eksikliği de görünür kılıyor.

~~**KULLANILMAYACAK:** arama sonuçları USBR tesislerinin "üçte ikisinin"
transferred works olduğunu söylüyor ama bu oranı birincil belgede
DOĞRULAYAMADIM.~~

**DÜZELTİLDİ (tur 9, metin yazımından önce). ORAN BİRİNCİL BELGEDE VAR** ve
belge o sırada zaten indirilmişti: `usbr_fac01-09.pdf`, 1/C fıkrası —

> *"Approximately one-third of Reclamation's constructed assets, referred to
> as reserved works, are operated and maintained by Reclamation personnel or
> by contract. The remaining two-thirds ... referred to as transferred works,
> are operated and maintained under a transfer agreement by operating
> entities..."*

**Hatanın cinsi kayda değer, çünkü §2.2'nin kuralını TERS yönde kırıyor.**
"Getir, hatırlama" bir rakamın bellekten YAZILMASINI yasaklıyor; burada
bellekten yazılan şey rakam değil, rakam hakkındaki HÜKÜMDÜ — "bu
doğrulanamadı". Oran arama sonucunda görülmüş, belgede aranmamış, ve
"doğrulanamadı" notu belgeye bakmayı gereksiz kılmıştı. Not bir kez
yazıldıktan sonra kendini doğrulayan bir engele dönüştü.

*Kural: "doğrulanamadı" notu, HANGİ belgede arandığını yazmak zorundadır.
Yazmıyorsa arama yapılmamış olabilir ve not sonraki turda yeniden sınanır.*
Aynı dersin §8.14.3'teki karşılığı: belgeye yazılan ölçülmemiş cümle,
sonraki kararların altına konmuş sessiz bir mayındır.

**Türkiye ile ABD arasındaki asıl soru, karşılaştırmanın kendisinden çıkıyor:**
devirden sonra mülkiyet kimde? USBR'da açık — Reclamation'da kalıyor. Türkiye
için 6172 sayılı Kanun okunmalı; **henüz okunmadı.**
