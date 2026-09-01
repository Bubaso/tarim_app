# Tarım Portalı — proje hafızası

Bu dosya her oturum açılışında otomatik okunur. Sohbet geçmişi kaybolsa,
sıkıştırılsa veya yeni bir oturuma geçilse bile buradaki kurallar geçerlidir.

**Kural değişirse burası güncellenir.** Bir karar yalnızca sohbette kalıyorsa
üç hafta sonra yoktur.

---

## 1. Uygulama

Flutter web + PWA tarım haber portalı. Canlı: https://tarim-app-2026.web.app
Arka uç Supabase (PostgREST + RLS), sunucu tarafı render ve bildirimler
Firebase Cloud Functions (`functions/index.js`, ESM, `europe-west1`).

Yönlendirme `MaterialApp.router` + GoRouter (`lib/core/router/app_router.dart`).

### Ortam tuzağı

`functions/package.json` → `engines: node 22`. Yerelde node 24 kuruluysa
`firebase deploy` fonksiyonları **yayınlayamaz**: kod tanıma adımı 2 GB heap'i
tüketip çöker, hata mesajı yanıltıcı biçimde "Timeout after 10000" der.
Kendi kodunda hata arama — node sürümüne bak.

```
brew install node@22
export PATH="/opt/homebrew/opt/node@22/bin:$PATH"
```

`firebase deploy --only hosting` bundan etkilenmez; fonksiyon gerektirmez.

---

## 2. Ülke Dosyası dizisi

28 günde bir ülke. Ana sayfada künyenin hemen üstünde bir şerit, tıklanınca
tam sayfa dosya. Rotasyon **Model → Pazar → Rakip**. İlk sayı Hollanda
(edition 1). Sırada Mısır var (İsrail'in yerine, kullanıcı kararı).

Adresler:
- `/ulke/<slug>` — dosyanın kendisi
- `/ulkeler` — arşiv

### 2.1 Adresler ASCII

`/ulke/`, `/ülke/` değil. Türkçe karakterli adres mesajlaşma uygulamalarında
yüzde kodlamasına dönüşüp okunmaz hâle geliyor. Aynı gerekçe `legalPath` için
de yazılı. Dosya 28 gün boyunca paylaşılmak üzere duruyor; adres onun kimliği.

### 2.2 Sayı disiplini — pazarlık konusu değil

Bu dizinin varlık sebebi güvenilirlik. Uydurma tek bir rakam diziyi bitirir.

- **Veri sayfası metinden önce kilitlenir.** Önce `data.json`, sonra cümle.
- **Getir, hatırlama.** Hiçbir rakam bellekten yazılmaz.
- **Kaynağı olmayan sayı metne girmez.**
- **Bellekten türetilmiş her iddia karantinadadır** — kaynakla doğrulanana
  kadar kullanılmaz.
- **Yuvarlamayı tercih et.** Sahte kesinlik, yanlışlıktan beter.
- **Toplulaştırılmış kalem ile ayrıntı kalemi aynı toplamda buluşmaz.**
  Toplama yapan her satırın yanında bunu sınayan bir kontrol olur.
- **Karşılaştırma ortak yıldan kurulur, ileri not atlanmaz** (§2.7).

İzlenebilirlik zinciri, her halka denetlenebilir:

```
kaynak API/CSV → _raw/*.json → data.json → grafikler.json (@path)
              → charts jsonb → seed SQL → veritabanı
```

**Yuvarlama depoda değil çizimde yapılır.** Veritabanında tam değer durur.

**VERİ NOTLARI CANLI YAYINDA DOSYA İÇİNDE GÖSTERİLMEZ.** Kural mutlaktır,
dosyaya göre değişmez.

Panel bir dönem "dosyanın en güçlü kısmı" sayılıyordu. Kullanıcı kararı (24
Ağustos 2026) bunu kaldırdı: hangi rakamın neden bulunamadığı bir ÜRETİM
GÜNLÜĞÜDÜR, okuma malzemesi değil.

Panel **veriyi boşaltarak değil, KODDAN ÇIKARILARAK** kaldırıldı
(`country_dossier_screen.dart`). Boş dizi bırakmak, her yeni dosyada tekrar
dolmasına açık kapı bırakırdı; kod yoksa geri gelemez.

Kayıt yok olmuyor, yeri değişiyor:

- `_raw/README.md` — yöntem ve tuzaklar
- `_raw/*.json → dogrulanamadi` — metne giremeyen kalemler
- **metnin kendi içinde**, cümlenin yanındaki parantez: *(Kültürel bilgi ve
  yüzdeler ikincil kaynaklardan.)* Okurun ihtiyacı olan yer burası.

`data.bosluklar` her dosyada boş bırakılır; seed'e gereksiz veri yazılmasın.

### 2.2.1 Çift sayım — sessiz hata

Veri kaynakları aynı hücreyi çoğu zaman **hem toplu hem kırılımlı** verir.
Hepsi toplanırsa sonuç gerçeğin katı çıkar ve **hata sessizdir**: yanlış rakam
makul görünür, hiçbir şey uyarı vermez.

İki biçimi görüldü:

- **UN Comtrade** — `customsCode` (C00 = tüm gümrük rejimleri, C01/C04/C06 =
  kırılım) ve `motCode` (0 = tüm taşıma türleri, 2100/3200 = kırılım). Ölçüldü
  (2023, HS 1001, Rusya→Türkiye): doğru 5.321.335.842 $, tüm satırlar
  toplanınca 10.642.671.684 $ — **tam iki katı**. Kural: yalnızca
  `customsCode='C00'` **ve** `motCode=0`. Süzgeç hem sorguya hem gelen satıra
  uygulanır; iki kere, çünkü sunucu süzgeci sessizce yok sayabilir.
- **FAOSTAT** — "Crops and livestock products", "Cereals, primary",
  "Food, Total" gibi kalemler tek tek ürünlerin *yanında* durur ve onları
  içerir. Ayrıca *alan* agregaları vardır (Avrupa, Dünya, AB); `fao_rank.mjs`
  bunları `alan kodu ≥ 1000 veya M49 boş` ile eler.
  **"n.e.c." topluluştırıcı DEĞİLDİR** — "başka yere girmeyen" artık
  kategorisidir, içinde başka kalem taşımaz.

**Hollanda dosyası bu açıdan denetlendi (23 Ağustos 2026) ve temiz çıktı.**
Manşet rakamları toplama ürünü değil, tek kaynak satırı. Dünya sıralaması tek
kalem. Toplama yapan tek yer ikili ticaret (`build_data.mjs:337`); ikili
matriste topluluştırıcı kalem bulunmuyor ve bağımsız çapraz kontrol
doğruladı — Comtrade 1.061 milyon $ (CIF) / FAOSTAT 749 milyon $ (FOB),
oran 1,42×. Çift sayım olsaydı ~2× olurdu.

### 2.3 İçerik klasörü

```
content/dossiers/<slug>/
  _raw/           kaynaktan ham çekim + çekme betikleri + README
  build_data.mjs  _raw → data.json
  data.json       kilitli veri sayfası
  grafikler.json  grafik tarifleri, sayılara @path ile bağlanır
  metin_tr.md     13 bölüm
  metin_en.md     13 bölüm
  tasarim.json    palet, motif, kapak kararları
  yayin.json      pencere, kaynak künyesi, veri boşlukları
```

Üretim ve doğrulama:

```
node content/dossiers/seed_dossier.mjs <slug>   → supabase/seed/dossier_<slug>.sql
node content/dossiers/dogrula_seed.mjs <slug>
```

Seed **yeniden çalıştırılabilir**: dosyayı upsert eder, bölümleri silip
yeniden yazar. Bölümler upsert değil sil-yaz, çünkü revizyonda bölüm sayısı
azalırsa upsert eski fazlalığı geride bırakırdı.

### 2.4 Bölüm türü ve görseli

Her bölümün bir **türü** var (`dossier_sections.tur`), `yayin.json/bolum_turleri`
yazıyor: `anlati` | `belge` | `veri` | `akis`. `veri` bölümlerinde **grafik**
okuma oluğunu kırıp 1040'a çıkıyor; **metin hiçbir zaman kırmıyor** — geniş
satır uzun okumada göz satır atlatıyor ve bu bölüm türünden bağımsız.

Tür `chart_keys`'ten türetilmiyor. "Grafiği olan bölüm geniştir" kuralı iki
yerde kırılıyor: grafiksiz bir `belge` bölümü olabiliyor, ve 9. bölüm kart
grafiği taşıdığı hâlde anlatı ritminde kalmalı. Tür bir yayın kararıdır.

Bölüm görseli (`dossier_sections.gorsel`, jsonb) `yayin.json/bolum_gorselleri`
üzerinden geliyor. **Atıfsız görsel yayımlanmaz** — kural üretim betiğinde,
doğrulayıcıda ve modelde ayrı ayrı sınanıyor. Görsel dosyaları depoda
`web/dosya/<slug>/`, ham hâlleri `content/dossiers/<slug>/_raw/gorseller/`.
Adres **mutlak** yazılıyor: `NewsArticleImage` göreli yolu kabul etmiyor.

Reddedilen kaynak, tekrar araştırılmasın diye kayıtlı: JPL PIA21986 (Westland,
ASTER) alınmadı — atfı `NASA/METI/AIST/Japan Space Systems` ve JPL politikası
JPL/NASA dışı sahipliği ticari kullanımda kısıtlı sayıyor, yani telif belirsiz.
NASA Earth Observatory'nin Landsat/SeaHawk üretimleri temiz.

### 2.5 Paylaşım kartı — yayın adımı

**Her dosya için kart üretilir:**

```
node content/dossiers/_ortak/paylasim_karti.mjs <slug>
```

`web/paylasim/<slug>.jpg` (1200×630) çıkar. `functions/index.js` kapak görseli
yoksa buna düşüyor; kart da yoksa sitenin genel yedeğine. Kart üretilmezse
dosya bağlantısı sıradan bir haber kartıyla paylaşılır.

Kart `tasarim.json`'dan okuyor, betikte ülkeye özel değer yok. Yazı tipleri
`_ortak/fontlar/` altında **gömülü**: ağdan çekilince tarayıcı takılıyor ve
yavaş ağda ekran görüntüsü sessizce sistem fontuyla alınabiliyor — fark ancak
paylaşınca görülür.

**Dosya sayfası fonksiyonla değil, STATİK KABUKLA paylaşılıyor.**

`deploy.sh` derlemeden sonra her yayımlanmış dosya için
`build/web/ulke/<slug>/index.html` yazıyor: `index.html`in kopyası, og
etiketleri dosyanınkiyle değiştirilmiş. Firebase statik dosyayı
yönlendirmelerden **önce** sunduğu için `/ulke/<slug>` doğrudan onu alıyor;
Flutter yine normal açılıp GoRouter ile dosyaya gidiyor.

Neden fonksiyon değil: haber sayfası binlerce kayıt ve saatlik değişen içerik
demek, orada sunucu render'ı gerekli. Dosya 28 günde bir değişen, elle yazılmış
tek bir metin ve künyesi zaten depoda. Sabit bir şeyi her istekte üretmenin
karşılığı yok — üstelik fonksiyon dağıtımı node 22 istiyor (§1) ve o tuzağa
hiç girmemek daha iyi.

`"trailingSlash": false` **zorunlu.** Olmadan Firebase `/ulke/hollanda` →
`/ulke/hollanda/` 301'i veriyor; adres dosyanın kimliği ve eğik çizgi eklenmemeli.

`dossierRenderer` yazılmış ama **hiç dağıtılmamış** ve artık gerekmiyor.
`/ulke/**` yönlendirmesi **eklenmemeli**: bir kez eklendi ve üretimi kırdı —
Firebase var olmayan fonksiyona yönlendirip **404** döndürdü. Dağıtım çıktısında
uyarı var ama dağıtımı durdurmuyor:

```
⚠ Unable to find a valid endpoint for function `dossierRenderer`,
  but still including it in the config
```

### 2.6 Bölüm sırası

Önem sırasına göre: ayrıntılı alt dosyalar → bilgi yazıları → ekonomik
göstergeler → kurumlar → tarım tarihi → tarım ürünleri.

### 2.7 Ortak yıl + ileri not

*(Kullanıcı kararı, 23 Ağustos 2026. Dizinin tamamı için geçerli.)*

Karşılaştırma, **iki ülkede de veri bulunan en son ortak yıldan** kurulur.
Bir ülkede daha yeni veri varsa, karşılaştırmanın **hemen altına** düşülür:

> Rusya'nın tahıl verimi 2023'te 3.167 kg/ha, Türkiye'nin 3.659 kg/ha.
> *(Türkiye'de 2024 rakamı 3.429 kg/ha; Rusya için aynı yıl bulunamadı.)*

Kural iyi niyete bırakılmaz, çekme betiklerine gömülür:
`_ortak_son_yil` + `_ileri_not` alanları. `_ileri_not` doluysa metinde
karşılığı **olmak zorunda**.

**Tahmin yılı karşılaştırmaya girmez.** USDA PSD yürüyen ve gelecek pazarlama
yılını da yayımlıyor; ham ortak yıl bir öngörü çıkabiliyor. Bunun için ayrı
bir `kesin_ortak_son_yil` alanı var.

---

### 2.8 Beş anlatı kategorisi — kontrol listesi, iskelet değil

*(Kullanıcı kararı, 24 Ağustos 2026.)*

**Yalnızca veriye dayanan bir dosya bir süre sonra usandırıyor.** Bu, Rusya
dosyasının ilk taslağında görüldü ve Hollanda dosyası da bu gözle yeniden
okununca aynı eksik çıktı: on üç bölümün dokuzu saf veriydi.

Okur bir ülke dosyasını pazar eğlencesi, genel kültür ya da "o ülkeyi tarım
gözüyle öğrenme" niyetiyle de açabilir. Veri o niyetin yalnızca bir kısmını
karşılıyor.

Her ülke dosyası şu beş soruyu **sorar**:

| | kategori | soru |
|---|---|---|
| 1 | **Bilim ve kişi** | Bu ülkenin tarımında adı olan bir insan ve bir keşif var mı? |
| 2 | **Kültürel açıklama** | Tarımsal bir olgunun tarım dışı bir sebebi var mı? |
| 3 | **Gündelik tarım** | Sıradan insan orada nasıl çiftçilik yapıyor, ne yiyor? |
| 4 | **Türkiye bağı** | İki ülke arasında yolculuk etmiş bir bitki, kurum ya da fikir var mı? |
| 5 | **Terk edilen ürün** | Ülke neyi ekmeyi bıraktı ve neden? |

**Hepsini doldurmak zorunlu değil.** Bir ülkede biri boş kalır, bir başkasında
iki tane çıkar. Bu bir iskelet değil, unutmamak için tutulan bir listedir —
tarz, şekil, sıralama ve hacim her dosyada değişir.

İlk iki dosyadaki karşılıkları:

| | Rusya | Hollanda |
|---|---|---|
| Bilim ve kişi | Dokuçayev, Ruprecht, Vavilov | Mansholt'un 1972 mektubu |
| Kültürel açıklama | Perhiz kuralı → ayçiçeği | — |
| Gündelik tarım | Dacha | Volkstuin |
| Türkiye bağı | Batum'dan gelen çay tohumu | Anadolu'dan giden lale |
| Terk edilen ürün | Çavdar (pazar terk etti) | Kökboya (laboratuvar iptal etti) |

Dördüncü satır dizinin kendi içinde bir simetri kurdu: iki dosya birbirinin
aynasında bitiyor. Beşinci satırdaki fark da bilinçli — bir ürünü pazarın terk
etmesiyle ürünün gereksizleşmesi aynı şey değil.

**Anlatı bölümü veri bölümünü seyreltir.** Bölüm türü (`yayin.json/bolum_turleri`)
buna göre dağıtılır; okur dosya boyunca birkaç kez zemin değiştirmeli.

### 2.9 Tablo yükü — okuru yoran şey sayı değil

Rusya dosyasının ilk taslağında okurun hangi bölümlerde boğulduğu ölçüldü.
Şikâyet edilen bölümlerde ortalama **11,4 tablo satırı** vardı, edilmeyenlerde
2,2. Ayırt edici olan sayı yoğunluğu **değildi**: sıfır tablosu olan bir bölüm,
en yüksek sayı oranlarından birine sahip olduğu hâlde yormuyordu.

Tablo bir okuma duraklamasıdır — göz metinden çıkıp ızgara çözmeye geçer.

- **Zaman serisi tabloya değil GRAFİĞE gider.** Okunacak değil, bakılacak şeydir.
- **İki sütunlu, dört satırlı bir şey tablo değil, cümledir.**
- **Grafiğin gösterdiği veri metinde tabloyla tekrarlanmaz.**
- Tablo yalnızca gerçekten iki boyutlu bir karşılaştırmada kalır.
- Her veri bölümüne bir **tutamak**: soyut bir rakamı bedenin görebileceği bir
  şeye çeviren tek cümle. (`Hollanda'nın bütün seraları 10.030 hektar — kenarı
  on kilometre olan bir kare.`)

Uygulandı: Rusya 129 → 15 tablo satırı, Hollanda 34 → 4.

### 2.10 Meta cümle yasağı

Araştırma süreci metne girmez. "Veri sayfası kilitlendiğinde", "bu bölümün asıl
bulgusu", "bu dosyayı yazarken", "buraya kadarı bir tespit" gibi cümleler
okurun işine yaramaz. Okur dosyayı okur, dosyanın yapılışını değil.

Aynı kural §8.2'de kurum dosyası için yazılıydı; ülke dosyasında da geçerli.

---

### 2.11 Ülke rotasyonu — sıra kayıtlı, tarih değil

*(Kullanıcı listesi, 29 Ağustos 2026.)*

Döngü **Model → Pazar → Rakip**. Sıra bu; tarihler her devirde bugünden
yeniden hesaplanıyor (28 gün), çünkü devir öne çekilebiliyor.

| # | ülke | rol | ağırlık merkezi |
|---|---|---|---|
| 1 | Hollanda | Model | Lojistik + sera |
| 2 | Rusya | Pazar | Buğday ticareti |
| 3 | **İspanya** | Rakip | Zeytinyağı + narenciye |
| 4 | Avustralya | Model | Su ve kuraklık |
| 5 | Irak | Pazar | İhracat pazarı |
| 6 | Mısır | Rakip | Nil, narenciye, patates |
| 7 | Danimarka | Model | Kooperatifçilik |
| 8 | Almanya | Pazar | AB kapısı + diaspora |
| 9 | İtalya | Rakip | Fındık/domates işleme |
| 10 | Yeni Zelanda | Model | Desteksiz reform |
| 11 | Çin | Pazar | Büyüyen hedef |
| 12 | Ukrayna | Rakip | Tahılda rekabet |
| 13 | Japonya | Model | Yaşlanan çiftçi |

Dağılım: 5 Model · 4 Pazar · 4 Rakip.

**Sıradaki Mısır DEĞİL, İspanya.** Bir kez Mısır sanıldı; Mısır altıncı.

Kurum rotasyonu §8.13'te; pencere orada 14 gün.

### 2.12 Devir — pencereyi kapatmak yetmiyor

29 Ağustos 2026'da Hollanda→Rusya ve TMO→Ziraat devri takvimden öne çekildi.
Devirde dokunulması gereken **dört** yer var; üçü kolay unutuluyor:

1. **Yeni dosya:** `status: published`, `pencere.baslangic: null` (seed `now()`
   yazar). Eski pencere ileri bir tarihe ayarlıysa MUTLAKA null'a çekilir,
   yoksa dosya yayına girer ama şeritte görünmez.
2. **Eski dosya:** `status = 'archived'` **ve** `ends_at = now()`.
   Yalnızca pencereyi kapatmak YETMEZ: `dosya_hikayeleri.py` pencereye değil
   `status = 'published'` alanına bakıyor ve arşivlenmeyen dosya ana sayfada
   hikâye baloncuğu üretmeye devam eder.
3. **Takvim:** yeni dosyanın "Yakında" satırı kapatılır ve SIRADAKİ eklenir.
   `unique(tur, sira)` yüzünden eski satır önce sira 90+'a taşınır.
4. **Görseller ÖNCE.** `./deploy.sh --hosting` migration'dan önce çalışır ve
   `content-type: image/jpeg` döndüğü doğrulanır. Ters sırada dosya canlıda
   kırık görsellerle açılır (25 Ağustos 2026'da yaşandı).

Arşive düşen dosya kaybolmuyor: `country_dossier_index`, `dosya_haberleri` ve
`haber_dosyalari` üçü de `archived`'ı kabul ediyor.

### 2.13 Dizinin tamamı her dosyanın içinde

*(Kullanıcı kararı, 29 Ağustos 2026.)*

**Kapakta arşiv bağlantısı var.** Eskiden yalnızca dosyanın sonundaydı ve
gerekçesi koda yazılıydı: "on üç bölümü bitiren okuyucu dizinin devamını ancak
burada öğrenmeli; yukarı konsaydı okunmakta olan dosyadan çıkmaya davet
ederdi." **Gerekçe tersine döndü:** sonuna kadar okumayan okur —ki çoğunluk
odur— başka dosya olduğunu hiç öğrenmiyordu. Bağlantı kapağın en altında, tez
cümlesinin ve pencere rozetinin ardında; ilk göze çarpan şey hâlâ dosyanın
kendisi. Hedef KENDİ dizisinin arşivi, ortak bir sayfa değil.

**Dosyanın sonunda iki dizi birden listeleniyor** (`DigerDosyalar`): "Ülke
dosyaları" ve "Kurum dosyaları" ayrı başlıklarla, hepsi tek listede. Okunan
dosya listede KALIYOR ama "BURADASIN" etiketiyle işaretli ve tıklanamaz —
çıkarılsaydı okur dizinin kaç sayı olduğunu sayamazdı.

Kart değil SATIR: arşivdeki kartlar kapak görseli ve tez cümlesi taşıyor,
dosyanın sonuna konsaydı okuma bittiği yerde ikinci bir arşiv açılırdı.

"Yakında" kartları bu listeye GİRMİYOR, yalnızca arşiv sayfalarında duruyor:
dosyanın sonu okunacak şeyleri gösteriyor.

"BURADASIN" ile "ŞİMDİ" ayrı şeyler — biri okunan dosya, öteki penceresi açık
olan. Arşivden eski bir dosya okunurken ikisi farklı satırda.

---

## 3. Görsel kurallar

### 3.1 Dosya sayfası bilerek bir "karanlık ada"

Uygulamanın geri kalanı krem zeminli ve tek modlu. Dosya sayfası koyu ve
**sistem açık/koyu tercihini izlemez**. Okur haber akışından çıkıp başka bir
şeye girdiğini renkten anlar. Sisteme bağlansaydı ada cihaz ayarına göre
bazen var bazen yok olurdu.

Bu yüzden sayfadaki her renk `DossierTheme`'den gelir ve dosya ekranlarında
**hiçbir yerde `Theme.of(context).brightness` okunmaz.**

Tek istisna ana sayfa şeridi: o sayfanın içinde durur ve sayfayı izler —
`seritMurekkep` / `seritVurgu` / `seritIkincil` bunun için var.

### 3.2 Renk tek başına anlam taşımaz

Renk körlüğünde kaybolacak hiçbir bilgi yok. "ŞİMDİ" rozeti bir **kelime**,
sadece vurgu rengi değil. "KAPANDI" etiketi de öyle. Grafiklerde seriler
renkle birlikte biçimle (çizgi deseni, işaretçi) ayrılır.

### 3.3 `cizgi` ve `cizgiVurgu` karıştırılmaz

- `cizgi` (1.52:1) — yalnızca dekoratif ayırıcı
- `cizgiVurgu` (3.48:1) — eksen, ızgara çizgisi, odak halkası

Eksen `cizgi` ile çizilirse grafik düşük görüşte okunmaz olur.

### 3.4 Raf tek renk, kitaplar renkli

Arşiv sayfasının (`/ulkeler`) kabuğu kimliksiz `DossierTheme.yedek`
kullanır; kartlar her biri kendi ülkesinin vurgusunu taşır. Kabuk aktif
dosyanın paletini alsaydı arşivin tamamı 28 günde bir renk değiştirir, okur
aynı sayfaya döndüğünde başka bir yere geldiğini sanırdı.

Polder motifi Hollanda'nın geometrisidir — ortak rafa serilmez.

### 3.5 Kapak görselsiz de tam çalışır

`cover_url` null geldiğinde kapak tipografik iskelete düşer ve sayfanın
hiçbir bölümü eksilmez. Görsel bir katman, taşıyıcı değil.

---

## 4. Kod alışkanlıkları

- Tanımlayıcılar ve yorumlar Türkçe. Yorum "ne" değil **"neden"** anlatır;
  özellikle bir kararın alternatifi neden reddedildiğini yazar.
- Okuma oluğu dosyada 720 px (haberde 800). Uzun paragrafta geniş satır
  göz satır atlatıyor.
- Uzun listeler tembel (`SliverList.builder`). 13 bölümü tek seferde kurmak
  açılışta gözle görülür duraklama yapıyordu.

### 4.1 Migration kuralları

- **Uygulanmış bir migration asla düzenlenmez.** Yeni dosya yazılır. Aksi
  hâlde depoyu farklı zamanlarda kuranlarda iki farklı şema oluşur.
- `create or replace view` yalnızca **sona sütun ekleyebilir**; mevcut
  sütunların adı, tipi ve sırası korunmak zorundadır.
- **İki migration aynı sürüm numarasını taşıyamaz.** `supabase db push`
  sürüme göre iz sürer; çakışma sessizce kırar. Yeni dosya adı verirken
  `ls supabase/migrations/ | tail` ile bak.
- Seed migration'a taşınırken içteki `begin;` / `commit;` çıkarılır — CLI
  zaten her migration'ı tek işlemde çalıştırır, iç `commit` sarmalayan
  işlemi erken kapatır.

`psql` kurulu değil. Uzak veritabanına yazmanın yolu `supabase db push`.

---

## 5. Test alışkanlıkları

Dosya testleri (şu an 80 test, hepsi yeşil):
`dossier_chart_test` 15 · `dossier_chart_view_test` 7 · `dossier_screen_test` 11
· `dossier_strip_test` 21 · `dossier_index_test` 17

- **Testler üretilmiş seed'e bağlanır**, elle yazılmış sahte veriye değil.
  `test/support/dossier_fixture.dart` `supabase/seed/dossier_hollanda.sql`
  dosyasını ayrıştırır. Böylece içerik bozulursa test kırılır.
- **Taşma testleri 360 / 768 / 1200 px × tr/en** olarak yazılır.
  `flutter_test` varsayılan yazı tipi her glifi yazı boyu kadar kare çizer;
  metin gerçekte olduğundan geniş görünür — kötümser, dolayısıyla iyi bir
  taşma dedektörü.

### İki tuzak

1. **Material 3 `IconButton` kendi içinde `InkWell` taşır.** `findsNWidgets`
   ile dokunma hedefi sayarken bulucuyu listeye daralt, yoksa AppBar'ın geri
   düğmesini de sayarsın.

2. **Aynı test içinde `ProviderScope` override'ını değiştirmek sağlayıcıyı
   yeniden çözmez.** Flutter eleman ağacını yeniden kullanır, kapsam yerinde
   güncellenir ve çözülmüş sağlayıcı eski değerini korur — test sessizce ilk
   hâli ölçer. Çözüm: her kuruluma taze `ValueKey` ver.

---

## 6. Bildirimler

Türler: `breaking`, `morning`, `weekly`, `author`.

`NotificationKind.wireName` değerleri `functions/index.js` içindeki
`sendToAll({ kind: … })` çağrılarıyla **birebir** aynı olmak zorunda.
Uyuşmayan tek harf, o türü isteyen cihazın onu hiç almamasına yol açar ve
**hiçbir yerde hata üretmez**.

Yeni bir tür eklerken dört yer birden güncellenir:
1. `lib/core/services/notification_prefs.dart` — enum
2. `settings_screen.dart` `_KindSwitches._labels` — (TR başlık, TR alt,
   EN başlık, EN alt)
3. `push_tokens` RLS `with check` içindeki `kinds <@ array[…]`
4. `log_notification_click()` içindeki `p_kind not in (…)`

3 ve 4 migration'dır. Biri unutulursa tür sessizce düşer.

`kinds` sütununda **null ile boş dizi farklıdır**: null "hepsini istiyorum",
boş dizi "hiçbirini istemiyorum". Bu ayrım olmadan "hepsini kapat" ile "hiç
dokunmadım" aynı görünürdü.

---

## 7. Durum ve açık işler

**Yayında:** Hollanda dosyası (edition 1, 13 bölüm, TR ~4.826 / EN ~6.328
kelime). `/ulke/hollanda` ve `/ulkeler` 200 dönüyor.

**Açık:**

1. `dossierRenderer` + `sitemap` fonksiyonları **yayınlanamadı** (bkz. §1
   node sürümü). Sonuç: `/ulke/` bağlantılarının paylaşım önizleme kartı yok
   ve sitemap'te dosya görünmüyor. Kod yazılı ve `node --check` temiz.
   Fonksiyon yayına girince `firebase.json`'a şu yeniden eklenmeli
   (`/sitemap.xml` girdisinden **önce**, `**` yakalayıcısından önce):

   ```json
   { "source": "/ulke/**",
     "function": { "functionId": "dossierRenderer", "region": "europe-west1" } }
   ```

   **Dikkat:** var olmayan bir fonksiyona işaret eden yönlendirme yayınlanırsa
   `/ulke/hollanda` 404 verir. Bir kez yaşandı.

2. Faz 7 — `kind: 'dossier'` bildirimi (bkz. §6) yazılmadı.

3. `country_dossier_screen.dart:279` — Hollanda videosunun URL'i **koda
   gömülü**, `ozet.slug.contains('hollanda')` koşuluyla. Aynı kontrol satır
   334'teki padding hesabında tekrar ediyor. Mısır'dan önce veritabanına
   taşınmalı, yoksa her yeni ülke kod değişikliği ve deploy gerektirir.

**Tasarım geliştirme turu** (kullanıcı onaylı, dosya 28 gün yayında kalırken
sürekli geliştirilen bir belge izlenimi hedefleniyor):

- Tur 1 — içindekiler paneli (üst çubukta açılır), okuma ilerleme çubuğu
  (`ReadingProgressBar` zaten var, haber sayfasında kullanılıyor, dosyaya
  bağlanmamış), videonun veritabanına taşınması
- Tur 2 — bölüm beliriş geçişleri, motifin bölüme göre çeşitlenmesi, kapak
  paralaks
- Tur 3 — grafiklerde dokunarak değer okuma, tablo sıralama, bölüm bağlantısı

Animasyonda ölçü: sayfanın karakteri sakin ve ciddi. Yumuşak beliriş uygun,
kayan/zıplayan öğe dosyanın tonunu bozar.

**Ertelenmiş:** yer imleri; UI/UX maddeleri 3, 4, 5, 7, 8, 10 ve D bölümü;
bülten kaydı; Android'de push ulaşmama sorunu.

---

## 8. Kurum Dosyası dizisi — kararlar

> ## ⏸ RAFA KALDIRILDI — 22 Ağustos 2026
>
> **Uygulama kodu kurum dosyası hiç yokmuş gibi eski hâline döndürüldü.**
> Ana sayfada yalnızca ülke dosyası şeridi var; `/kurum/` ve `/kurumlar`
> rotaları, `tur` süzgeçleri, `mevzuat_zinciri` grafik tipi ve kapak teması
> geri alındı. Aşağıdaki kararlar ve `content/dossiers/tmo/` altındaki içerik
> **duruyor** — dönüldüğünde sıfırdan başlanmayacak.
>
> **Geri dönüş nedeni bilinsin:** yazılan metin bir haber portalı için fazla
> iddianame tonundaydı. İçerik yaklaşımı (§8.2 duruş) yeniden konuşulacak;
> kullanıcı açıklamaları verecek. Bu, kayıt disiplininin değil TONUN sorunu —
> kaynak zinciri ve doğrulama altyapısı olduğu gibi kullanılabilir.
>
> Uygulanmamış migration `content/dossiers/tmo/beklemede/` altına taşındı;
> `supabase db push` ile yanlışlıkla uygulanmasın diye. Oradaki `OKU.md`
> geri alma sırasını yazıyor — migration ile istemci aynı pakette gitmeli,
> yoksa ana sayfa şeridi kaybolur.

**Durum: dosya taslak, dizi rafta.** Sayı 01 (TMO) için ham kaynaklar
`content/dossiers/tmo/_raw/` altında; `data.json` kilitli ve 21 kalemi
`dogrula_veri.py` ile ham kaynağa karşı doğrulanıyor. Metin yazıldı
(TR ~3.670, EN ~4.700 kelime) ama **revizyon bekliyor**.

### 8.1 Ne olduğu

Türkiye'de tarımı ilgilendiren kuruluşların dosyası. Ülke Dosyası'ndan
**tamamen bağımsız** yürür; takvimleri birbirine bağlı değil.

Ritim: **haftada bir yayın, ağır ve hafif dönüşümlü.** Her kalıp kendi içinde
14 günde bir gelir.

- **Ağır dosya** — 13 bölüm, ~4.000 kelime, tam `data.json` + `_raw`
- **Hafif dosya** — 7 bölüm, ~1.800 kelime, künye + en çok iki grafik

Kapsam: kamu kurumları, üretici örgütleri (kooperatif, birlik, oda), piyasa
altyapısı (borsa, lisanslı depoculuk) ve **kapanmış kurumlar**. Özel sektör ve
uluslararası aktörler kapsam dışı.

Adresler `/kurum/<slug>` ve `/kurumlar`. İçerik klasörü `content/dossiers/<slug>/`
(ülke dosyalarıyla aynı düzlemde; ayrımı `yayin.json → tur` yapar).
Dizi-geneli kaynaklar `content/dossiers/_ortak/`.

**Zemin dosyası:** ilk sayıdan önce yayımlanan tek seferlik Bakanlık haritası.
Sayı numarası almaz. Sonraki dosyalar örgütlenme paragrafını tekrar yazmaz,
ona bağlanır.

### 8.2 Tarz — tanıtım dosyası

**Bu bir tanıtım dosyası.** Kurumu anlatır, yargılamaz. Okur tarımla ilgilenen biri,
belki çiftçi; amaç kurumu tanıtmak, anlaşılır kılmak, işine yarar bilgi vermek.

Cevaplanan sorular: ne zaman kuruldu · hangi ihtiyaçtan doğdu · hangi merhalelerden geçti
· Türk tarımına ne faydası oldu · bugün ne iş yapıyor · çiftçiyi nasıl ilgilendiriyor ·
dünyada örnekleri var mı.

**Metne GİRMEYECEKLER — ilk denemede hepsi girmişti ve dosyayı iddianameye çevirmişti:**

- **Tez cümlesi.** İddia kuran bir üst cümle yok. `thesis_tr` alanı tanıtıcı bir satır
  taşır: "Buğdaydan afyona: Türkiye tarımının en eski ve en geniş yetkili kurumu."
- **Belgelerdeki çelişkiler.** "1. madde şöyle diyor ama 4. madde böyle", dipnot
  gözlemleri, redaksiyon hataları. Bunlar araştırmacının notu, okurun derdi değil.
- **Denetim bulgusu / hesap verme sorgulaması** ve "Kayıtlar" diye bir bölüm.
- **"Açık sorular" bölümü.** Sayıştay müfettişi değiliz.
- **"Veri notları" paneli.** Yazarın bulamadıkları okurun sorunu değil. Doğrulanmayanlar
  `_raw/README.md`'de kalır.
- **Meta cümleler.** "Bu dosya hazırlanırken", "kurum cevap vermedi", "sayfa sonunda
  yazılı", "doğrulanamadı" türü her şey.

**KALACAKLAR:** Rakam — ölçü göstermek için, argüman kurmak için değil. Ve **kaynakça**:
sonda, derli toplu. Veri notundan farkı şu — biri yazarın eksiği, diğeri okurun kaynağı.

Kaynak zinciri ve doğrulama disiplini (§2.2, `dogrula_veri.py`) aynen geçerli. Değişen
tondur, titizlik değil.

### 8.3 İskelet — sabit değil

**Her dosya aynı iskelete oturmaz.** Genel bir çerçeve vardır; tarz, sıralama, bölüm
sayısı ve hacim konuya göre değişir. Bir bankayla bir silo işletmesi aynı sırayla
anlatılmaz.

TMO dosyasında kullanılan on bölüm, o kuruma uyduğu için öyle:

1. Kurum nedir · 2. Kuruluş · 3. Genişleme ve merhaleler · 4. Bugünkü hâli ·
5. Ne iş yapar · 6. Çiftçi için ne anlama geliyor · 7. Kurumun özel/az bilinen ayağı ·
8. Altyapıdaki rolü · 9. Dünyada benzerleri · 10. Rakamlarla + **Kaynakça**

Anlatı kronolojik ve açıklayıcı ilerler. Görsel metne yayılır: TMO dosyasında yedi görsel
var, hepsi Wikimedia Commons'tan ve **hepsi atıflı** — atıf görselin altında açıkta durur,
künyeleri `_raw/gorseller/kunye.json` içinde.

### 8.4 Görsel dil — "Evrak"

Kurumun manzarası yok; maddi karşılığı kağıttır. Kanun, tutanak, rapor, makbuz.
Bu dil üç sorunu birden çözüyor: telif (arşiv belgesi kamuya açık), tarafsızlık
(belge taraf tutmaz) ve ölçek (her kurumun kendi kuruluş belgesi var).

Görsel künye: https://claude.ai/code/artifact/8ea789e0-2c1a-4020-be73-e21a3957e993

- **Koyu kapak → kağıt gövde.** Fiziksel dosyanın kendisi: dışı mukavva, içi
  kağıt. Ülke dosyasının "karanlık ada" kuralı burada kapağa devrolur; gövde
  arşiv kağıdıdır. Ayrımı üç işaret birlikte taşır: kağıdın soğukluğu
  (`#E3E7E5`, haberin sıcak kremine `#F6F1E7` karşı), sol marj rayı ve farklı
  yazı ailesi. Hiçbiri tek başına yeterli sayılmadı.
- **Tek dizi paleti, kurum başına tek vurgu.** Dosya başına palet üretmek
  haftalık ritimde çöker ve dizi kimliğini yok eder. Vurgu kuruma değil
  **kümeye** ait (8 küme); arşiv renkle okunur. Kontrast bir kez hesaplanır:
  `content/dossiers/_ortak/kontrast.py`.
- **Üç kayıt ekseni.** `anlati` (bizim cümlemiz, serif) · `kayit` (belgeden,
  mono, ray girintili, zorunlu kaynak satırı) · `cevap` (kurumun ifadesi,
  ters girinti). Üçü **renkle değil biçimle** ayrılır. Tarafsızlık iddia
  edilmez, gösterilir — 8.2'nin görsel karşılığı.
- **Tipografi üç katman:** Source Serif 4 (okuma) · IBM Plex Mono (kayıt,
  künye, rakam) · Libre Franklin (etiket, mevcut aile). İki yeni aile
  **paketlenecek**, `google_fonts` ile ağdan çekilmeyecek. Tablolarda tabular
  figures zorunlu.
- **Motif:** cetvel çizgisi (sol ray, iş yapar — girintiler ona hizalanır) ve
  ortogonal teşkilat çizgisi (bölüm ayırıcı). Kuruma göre değişmez, dizi
  kimliğidir.
- **Kapak kuruluş belgesinden kurulur.** Tipografik kapak *asıl tasarım*,
  yedek değil. Hayalet dosyalarda kapanış belgesi + "KAPANDI" kelimesi.

**Sınır — kapak belgeyi alıntılar, taklit etmez.** Resmî Gazete anteti, mühür,
arma veya kurum logosu yeniden üretilmez. Kapakta her zaman seri etiketi ve
sayı numarası bulunur; ekran görüntüsü bağlamından koparıldığında bile gerçek
bir resmî belge sanılamaz. Estetik tercih değil, güvenilirlik sınırı.
Üretilmeyecek diğerleri: stok "mutlu çiftçi" fotoğrafı, kurumu simgeleyen
dekoratif ikon seti.

### 8.5 Yeni bileşenler

Mevcut yedi grafik tipi kurumun iki temel şeklini çizemiyor:

- `mevzuat_zinciri` — kuruluş belgesinden bugüne dikey omurga. Düğümler olay
  değil **yürürlükteki metin**; belge türü (kanun/KHK/CBK/yönetmelik) biçimle
  ayrılır, renkle değil.
- `bagimlilik_haritasi` — iki sütun: solda "kime bağımlı", sağda "kim ona
  bağımlı", aralarında ilişki fiili. 360 px'te kuvvet grafiği okunmaz.
- `islem_akisi` — bir işlemin adım adım yolu: aktör, süre, çıktı belgesi.
  Bölüm 5'in omurgası; grafik tipi olmazsa metne gömülür ve kaybolur.

### 8.6 Şema borcu

Tek yeni migration (uygulanmış olan düzenlenmez):

- `country_dossiers.tur` (`ulke` | `kurum`), varsayılan `ulke`
- `country_dossiers_edition_idx` → **`unique(tur, edition)`** — iki dizi de
  01'den başlıyor, mevcut tekil indeks çakışır
- `iso3` nullable + `kurulus_belgesi text` — kurumda kaynağa dönmenin anahtarı
- `dossier_sections.tur` — `anlati|belge|veri|akis`, `chart_keys`'ten
  türetilemez (grafiksiz `belge` bölümü var)
- `revizyonlar jsonb`
- `active_country_dossier` görünümü `limit 1` ile tek aktif dosya varsayıyor;
  türe göre parametreli hâle gelmeli

### 8.7 Sayı 01 — TMO

Tez ekseni: **1938'de kurulan ofis bugün bir anonim şirket.** Aynı isim, ardışık
tüzel kişilikler. Ana Statü kurumu "Toprak Mahsulleri Ofisi Anonim Şirketi"
diye tanımlıyor; dayanağı 3491 değil, 233 (1984) ve 399 (1990) sayılı KHK'lar.

Kuruluş kanununun Resmî Gazete tarih ve sayısı **henüz birincil kaynaktan
doğrulanmadı** — `mevzuat.gov.tr` bu ağdan çekilmiyor.

### 8.8 Sayı 02 — Ziraat Bankası

**Küme: Finans** (`#1D5B4A` kağıt / `#6FC3A4` kapak). Dizinin ikinci vurgusu;
`kontrast.py`'de tanımlıydı, ilk kez kullanıldı. TMO'nun kırmızısı "kamu gücü"
(fiyat açıklayarak müdahale), Ziraat'in yeşili "finans" (kredi açarak).

Ölçü cümlesi: **Türkiye'de tarıma açılan kredinin yaklaşık üçte ikisi tek
bankadan.** Pay bankanın faaliyet raporundan, payda BDDK'dan. İddia değil oran
— ve enflasyondan etkilenmiyor.

**Kapak yine tipografik.** Fotoğraf kapak tartışıldı ve reddedildi: dizinin
görsel kimliği ikinci sayıda kırılırsa hiç kurulmamış olur (kullanıcı kararı,
29 Ağustos 2026). Güçlü fotoğraflar metnin içine yayıldı — yedi görsel.

### 8.9 Kurum dosyasının beş anlatı kategorisi

§2.8 ülke dosyası için yazılmıştı. Kurum dosyasının karşılığı:

| | kategori | soru |
|---|---|---|
| 1 | **Kurucu kişi ve fikir** | Kurumu kim, hangi fikirle kurdu? |
| 2 | **Parayı nereden buldu** | İlk kaynağı neydi; bu onun karakterini nasıl belirledi? |
| 3 | **Gündelik karşılık** | Sıradan üretici bu kurumla nerede karşılaşıyor? |
| 4 | **Dünyada benzeri** | Aynı sorun başka yerde nasıl çözüldü? |
| 5 | **Bıraktığı iş** | Kurum neyi yapmayı bıraktı, kime devretti? |

Ziraat'teki karşılıkları: Mithat Paşa/Pirot 1863 · aşara "Menafi Hissesi"
zammı 1883 · kovan, tekne, elektrik kredileri · Crédit Agricole · buğday
masasının 1938'de TMO olması.

**Beşinci satır diziyi kendi içine bağlıyor:** Sayı 01 bu masadan doğdu,
Sayı 02 masanın sahibi. Ülke dosyalarındaki lale/çay simetrisinin kurum
karşılığı.

### 8.10 Dört sessiz hata — Ziraat dosyasında yakalandı

**1. Anahtar kelime "Ziraat" olamaz.** Yayındaki 520 haberde ölçüldü:
"Ziraat" başlıkta beş kez geçiyor ve **beşi de Ziraat ODASI**. Sözcük sınırı
regex'i korumuyor, çünkü "Ziraat" gerçekten ayrı bir kelime. Doğru liste
`["Ziraat Bankası", "Ziraat Bank"]`. "Tarım Kredi" de yok — ayrı tüzel kişilik.
*Genel kural: anahtar kelime, kurumun adının BAŞKA bir kurumun adında geçmeyen
en kısa parçası olmalı ve liste yayına girmeden gerçek habere karşı denenmeli.*

**2. PDF'te sayı ile birimi arasına satır sonu ve BÖLÜNMEYEN BOŞLUK giriyor.**
`'589 \nbin üretici'`, `'109\xa0milyar\xa0TL'`. İkisi de gözle görünmez ve tam
eşleşmeli aramayı sessizce düşürür — rakam doğruyken kontrol düşer; kontrol
gevşetilirse yanlış rakam geçer. Çözüm: aramadan önce **hem samanlığı hem
iğneyi** `\s+ → tek boşluk` normalleştirmek. Rakam ve kelime sırası korunur,
yalnızca boşluk türü serbest bırakılır.

**3. Python'un `round()`'u bankacı yuvarlaması yapıyor.** `round(1224.5)` →
**1224**, 1225 değil. Metin "1.225 milyar" yazarken veri katmanı 1224 tutuyordu
ve sayı izi denetimi bunu yakaladı. Yayına giden rakam okurun beklediği gibi
yuvarlanmalı: `Decimal(...).quantize(..., ROUND_HALF_UP)`.

**4. İngilizce metin ayrı bir sayı biçimi.** TR "1.225" / EN "1,225" — aynı
desenle taranırsa EN'deki her binlik ondalık okunur. Ayrıca TR "924 bin" ↔ EN
"924,000": ölçek dönüşümü **iki yönlü** olmak zorunda (havuz yalnızca bölmeye
izin verirken EN metnin yarısı yanlış işaretlendi). `dogrula_metin.py` artık
iki metni de kendi biçimiyle sınıyor.

### 8.11 `dogrula_metin.py` meta cümle avlıyor

Dizi bir kez TON yüzünden rafa kalktı (§8). Ton artık elle değil betikle
sınanıyor: yasak kalıplar TR ve EN için ayrı listelerde, gövde metninde
aranıyor, bulunursa çıkış kodu 1.

**Ayrım fiilde:** "Bu dosya ... *anlatıyor*" okura yol gösteren bir cümle ve
dizide yerleşik. Yasak olan dosyanın NASIL YAPILDIĞI — "hazırlanırken",
"yazarken", "doğrulanamadı", "erişilemedi". İlk sürüm ikisini ayırmıyordu ve
meşru cümleleri işaretliyordu.

### 8.12 Var olmayan grafik tipi için metin uydurulmaz

§8.5'te tanımlı `islem_akisi` kodda yok ve Ziraat dosyasında **kullanılmadı** —
ama sebebi kodun eksikliği değil: **başvurunun adım adım yolu bankanın hiçbir
yayımlanmış belgesinde geçmiyor.** Grafik tipi yazılsaydı bile içini
dolduracak kaynak yoktu.

Yerine `kartlar` ile ilan edilmiş ŞARTLAR verildi: limit, vade, ödemesiz
dönem, faizin dayanağı. Hepsi faaliyet raporunda yazılı.

*Kural: bir bölümün biçimi kaynaktan önce seçilmez. Önce neyin belgelendiğine
bakılır, sonra o şeye uyan biçim seçilir.*

---

### 8.13 Kurum rotasyonu

*(Kullanıcı listesi, 29 Ağustos 2026. Pencere 14 gün.)*

| # | kurum | durum |
|---|---|---|
| 1 | Toprak Mahsulleri Ofisi | yayımlandı |
| 2 | Ziraat Bankası | yayımlandı |
| 3 | **Tarım Kredi Kooperatifleri** | sıradaki |
| 4 | TAGEM ve araştırma enstitüleri | |
| 5 | DSİ | |
| 6 | TİGEM | |
| 7 | Türkşeker | |
| 8 | Et ve Süt Kurumu (ESK) | |
| 9 | TZOB / Ziraat Odaları | |
| 10 | TARSİM | |
| 11 | Tarım Satış Kooperatifleri Birlikleri | |
| 12 | TKDK / IPARD | |
| 13 | Köy Hizmetleri Genel Müdürlüğü | kapanmış kurum |
| 14 | TÜRİB | |
| 15 | Zirai Donatım Kurumu | kapanmış kurum |
| 16 | Ulusal Süt Konseyi | |
| 17 | Sulama Birlikleri | |
| 18 | Devlet Üretme Çiftlikleri | kapanmış kurum |
| 19 | Pankobirlik | |
| 20 | SEK | kapanmış kurum |
| 21 | Ziraat Mühendisleri Odası | |
| 22 | Toprak Koruma Kurulları | |
| 23 | Fiskobirlik | |
| 24 | ÇKS ve tarımsal veri sistemleri | |
| 25 | Toptancı Hal Sistemi | |

Liste §8.1'deki kapsamı doğruluyor: kamu kurumu, üretici örgütü, piyasa
altyapısı ve **kapanmış kurumlar** (Köy Hizmetleri, Zirai Donatım, Devlet
Üretme Çiftlikleri, SEK) bir arada. Kapanmış kurumların kapağı "KAPANDI"
kelimesini taşıyor (§8.4).

**Sayı 03'ün özel bağı:** Tarım Kredi Kooperatifleri, Ziraat Bankası
dosyasında aranıp bulunamayan halkanın kendisi — kooperatiflerin kuruluşu ve
bankadan ayrılışı hiçbir çekilen kaynakta yoktu ve Sayı 02'de o geçiş bilerek
atlandı (`ziraat-bankasi/_raw/README.md`, AÇIK maddesi 2). Sayı 03'ün ilk işi
o kaynağı bulmak.

---

## 9. Emtia fiyatları — Türkşeker ayrı bir vaka

Fiyatları toplayan hat bu depoda değil: `~/tarim_ai_pipeline`, launchd her gün
19:00'da `run_commodities_daily.sh`'i çağırıyor. Uygulama yalnızca
`commodity_latest_prices` ve `commodity_price_history` görünümlerini okuyor.

### 9.1 İki fiyat türü aynı dille anlatılamaz

`commodities.price_kind`:

- `traded` (Polatlı) — rakam kendini açıklıyor: bir borsada, bir günde, işlem
  görmüş hacim ağırlıklı ortalama.
- `administered` (Türkşeker) — rakam bir METNİN yorumu.

Türkşeker duyurusu tek bir fiyat ilan etmiyor. 21.08.2026 ilanı beş fabrikadan,
28 Ağustos'a kadar, tonaja ve ödeme biçimine göre **dört** fiyat veriyor:

```
0 – 5.000 ton        peşin 38,6139    3 taksit 43,4159
5.000 ton ve üzeri   peşin 37,6238    3 taksit 42,3269
```

### 9.2 Kararlar (kullanıcı, 24 Ağustos 2026)

- **Kampanya fiyatı da güncel fiyattır.** Bölgesel ya da süreli olması onu
  ilan edilmiş bir satış fiyatı olmaktan çıkarmıyor: Türkşeker o gün o
  fabrikalardan o fiyata satıyor. Kapsam artık ELEME SEBEBİ DEĞİL.
- **Gösterilen rakam ilandaki EN DÜŞÜK fiyat.**
- **Duyuruya erişim her zaman fiyat/grafik kartının içinde.**
  Sırası: en düşük fiyat → şart/kapsam/geçerlilik → ilandaki diğer fiyatlar →
  duyurunun PDF'ini doğrudan açan bağlantı.

  Duyurunun tam metni bir dönem kartın içinde, tablosuyla birlikte gösteriliyordu;
  **çıkarıldı (25 Ağustos 2026).** PDF'ten çıkarılan tablo dar ekranda zaten yana
  kaydırılmadan okunmuyordu ve belge bir tık ötede duruyor. Kartta kalması gereken
  şey bizim YORUMUMUZ — hangi rakamı neden gösterdiğimiz; tıpkıbasım üçüncü kez
  aynı şeyi söylüyordu. Metin `commodity_prices.raw` içinde duruyor ama
  görünümler onu dışarı vermiyor (`raw - 'text'`), çizilmeyen 1,7 KB her sorguda
  istemciye inmesin diye.

  **Doğrudan PDF'i açan bağlantı kaldırılmaz.** Bir kez kaynak notundaki
  "Resmî ilan" düğmesiyle aynı işi yaptığı düşünülüp sadeleştirilmek istendi;
  ikisi farklı yere gidiyor (biri belgeye, diğeri duyuru listesine) ve ikisi de
  duruyor.
- **ÜRÜN farkı hâlâ eliyor:** C şekeri, paketli şeker, ihraç kayıtlı satış.
  Seri kristal dökme şekerin serisi; 5 kg paket fiyatı (182,50) TL/kg ile aynı
  grafikte duramaz.

### 9.3 Fiyat dönemi modeli

Her duyurudan `(başlangıç, bitiş, fiyat, kapsam)` dönemleri çıkarılıyor. Bir
günün fiyatı = o gün **yürürlükte olan** dönemlerin en düşüğü. Üç şeyi
kendiliğinden çözüyor:

1. Aynı belgedeki farklı tarihli fiyatlar karışmıyor (17.07 ilanı hem 27.07'den
   itibaren süresiz 42,00 hem de 20–24.07 arası 38,6139 veriyor).
2. Kampanya bitince fiyat kendiliğinden geri dönüyor — 29.08'de yeniden 42,00
   ve o gün için satır yazılıyor. Elle müdahale yok.
3. Yeni **ülke geneli** ilan öncekileri kapatıyor; bölgesel ilan yalnızca aynı
   kapsamlı olanı kapatıyor. Olmasa 04.07'nin 40,00'ı sonsuza kadar "en düşük"
   kalırdı.

### 9.4 Duyuruyu model okuyor, doğrulamayı kod yapıyor

Düzenli ifadeyle okumak denendi ve her seferinde bir sonraki duyuru kalıbı
kırdı — en kötüsü de sessiz yanlıştı: 26.03.2026 **C şekeri** duyurusundaki
21,75'i kristal şeker fiyatı sanıp 42,00'ı yarıya düşürmüştü.

Okuma `ilan_okur` rolüne verildi (`turkseker_reader.py`). Ama **model
doğrulanmadan kabul edilmiyor**: dönen her rakam duyurunun kendi metninde
harfi harfine aranıyor, tarihler ayrıştırılıyor ve ilan gününe 400 günden
uzaksa reddediliyor. Tek bir rakam bulunamazsa duyurunun TAMAMI reddediliyor —
bir rakamı uyduran çıkarımın diğerine de güvenilmez. Çıkarımlar
`.cache/turkseker/` altına yazılıyor: belge değişmiyor, o hâlde okuma da
değişmemeli.

`test_turkseker_parser.py` on gerçek duyuru + yedi tarihli beklenti üzerinde
koşuyor; önbellek doluyken ağ da model de istemiyor.

### 9.5 Karar defteri

Eskiden kabul edilen duyuru da elenen duyuru da aynı sessizlikle sonuçlanıyordu
ve "sistem bu duyuruyu gördü mü" sorusunun cevabı yoktu. Artık her PDF için
karar ve GEREKÇESİ `logs/commodities.log` içine basılıyor. Sıfır satırlı gün de
`commodity_fetch_log`'a yazılıyor: "çalıştı ama bir şey yoktu" ile "hiç
çalışmadı" ayrı şeyler.

### 9.6 Şerit kartında dokunmanın iki anlamı

*(Kullanıcı kararı, 24 Ağustos 2026.)*

```
kapalı kart → dokunma açar        (ayrıntı görünür)
açık kart   → dokunma grafiği açar (her yeri, sadece "Grafik →" bağlantısı değil)
```

Eskiden açık kartın bütün yüzeyi KAPATMA tuşuydu; grafiğe yalnızca sağ alttaki
11 puntoluk bağlantıdan gidiliyordu. Yüzeyin tamamı nadir istenen işe, sık
istenen iş ise en küçük hedefe ayrılmıştı.

**Kapatma gesti bilerek kaldırıldı.** Karşılığı yok: aynı anda tek kart açık
kalıyor ve başka bir karta dokunmak bunu zaten kapatıyor. `_expandedSlug`
artık `null`'a dönmüyor; `_seededFirstCard` bayrağı yine de gerekli, yoksa her
çizimde açık kart baştakine geri düşer.

"Grafik →" bağlantısı duruyor ama **kendi dokunma hedefi yok** — iç içe iki
InkWell aynı işi yapınca dalga iki kez çiziliyor ve okuyucu bağlantının dışına
basınca başka bir şey olacağını sanıyor. Kalan tek işi işaret vermek.

---

## 10. Tablo, dil ve kapak — 25 Ağustos 2026

### 10.1 Haber tablosu genişliği içerikten hesaplanır

`DynamicChartWidget` içindeki tablo sabit `columnWidths: {0: FlexColumnWidth(2)}`
kullanıyordu: ilk sütun, ne yazdığına bakılmaksızın diğerlerinin iki katı. Bu
tablolarda sütun sırası **Değer | Dönem | Ölçüm** ve en kısa içerik ilk sütunda
("1 %"), en uzunu sonda ("Kışlık ürün verim tahmini üst düşüş oranı"). Yani
genişliğin yarısı boş duran bir sütuna gidiyor, açıklama dörtte bire sıkışıp
`ClipRRect` tarafından kesiliyordu.

Artık genişlik her sütunun **en uzun hücresinden** hesaplanıyor (8–34 karakter
arasına kırpılarak) ve hücrelerde `TextOverflow.ellipsis` **yok** — sarmak,
kesmekten iyidir.

**Dar ekranda tablo bırakılır, blok düzenine geçilir.** Sütun başına 120 px'in
altına inildiğinde satırlar blok olarak diziliyor: üstte satırın ne anlattığı,
altında diğer sütunlar başlıklarıyla. Eşik 120, çünkü 11 punto Inter'de 24 px iç
boşluktan sonra ~16 karakter kalıyor; altında "564.188.810" gibi bölünemeyen bir
hücre ortadan ikiye ayrılıyor. Dar ekranda kart iç boşluğu da 24 → 16.

### 10.2 Grafik verisi de çevrilir — ama doğrulanarak

Çeviri yalnızca düz metni kapsıyordu; 335 haberin grafiği İngilizce sayfada
Türkçe kalıyordu. Artık `articles.chart_data_en` var.

- Çeviriyi `src/utils/chart_translate.py` yapıyor, çevirmen ajanından **ayrı**
  bir çağrıyla: yapılandırılmış veri + rakam, on bin karakterlik HTML gövdesiyle
  aynı isteme sıkıştırılamaz.
- **Her hücrenin rakam dizisi karşılaştırılıyor.** "564.188.810 dolar" →
  "564,188,810 dollars" ikisinde de `564188810`. Tek bir hücre uymazsa çevirinin
  TAMAMI reddediliyor ve `chart_data_en` boş kalıyor; uygulama Türkçesini
  gösteriyor. Yarısı çevrilmiş bir tablo, hepsi Türkçe olandan kötüdür.
- **Sütun adları yalnızca `type: table` iken çevrilir.** Çubuk, çizgi, halka ve
  rakam kartları `item['label']` / `item['value']` anahtarlarını ADIYLA arıyor;
  çeviri onları yeniden adlandırsa grafik hata vermeden boşalırdı. Tablo dışı
  tiplerde anahtarlar Türkçe kaynaktan alınıyor, hücreler konuma göre eşleşiyor.
- Arşiv `backfill_chart_translations.py` ile dolduruldu: 305 çeviri yazıldı,
  30 haber doğrulamadan geçemeyip Türkçe kaldı.

### 10.3 Türkşeker ilan alanları iki dilli

Arayüz metinleri baştan iki dilliydi ama duyurudan gelen ALANLAR (başlık, şart,
kapsam, kademe etiketleri) Türkçe kalıyordu. Artık `ilan_okur` aynı geçişte
İngilizcesini de üretiyor: fabrika ADLARI çevrilmez, "Tüm fabrikalar" →
"All factories", sayı biçimi değişir (5.000 → 5,000).

Satırın neden o gün yazıldığını anlatan `reason` alanı **cümle değil ANAHTAR**
tutuyor (`kampanya_bitti`); metni arayüz üretiyor. Veride saklanan Türkçe bir
cümle İngilizce arayüzde olduğu gibi görünüyordu.

### 10.4 Kapakta ad kelimesinin ortasından bölünmez

Masaüstünde 132 punto "Netherlands" 720 px'lik oluğu birkaç piksel aşıyor ve
"Netherland" + "s" gibi görünüyordu. `_KapakAdi` puntoyu adın TAMAMINA değil
**en uzun kelimesine** bakarak küçültüyor: tek kelimelik ad tek satıra sığacak
kadar iner, "Birleşik Krallık" tam puntosunu koruyup kelime arasından sarar.
Harf aralığı da (-0.022 em) puntoyla birlikte ölçekleniyor.

---

## 11. Video haber bölümü — 25 Ağustos 2026

Anasayfada, kurumsal YouTube kanallarından toplanıp **panelde onaylandıktan
sonra** yayına alınan video şeridi.

### 11.1 Video gömülüyor, indirilmiyor

Veritabanında `video_id` var, dosya yok. Video kaynağın sunucusunda kalıyor,
oynatıcı YouTube'un kendi oynatıcısı, izlenme kaynağa sayılıyor. **İndirip
kendi sunucumuzda yayınlamak telif ihlalidir** ve "kaynak belirttik" demek
bunu değiştirmez. Ajans videoları (AA, İHA, DHA) lisanslı içerik; abonelik
olmadan gömme hakkı da yok — kanal listesine girmezler.

Kart künyesi (kanal adı + kaynağa bağlantı) **zorunlu**: kaynağını
göstermeyen gömülü video, dosya dizisindeki atıfsız görselin karşılığıdır.

### 11.2 RSS, arama değil

Her kanalın kimlik doğrulaması gerektirmeyen bir Atom akışı var:
`https://www.youtube.com/feeds/videos.xml?channel_id=UC...` — anahtar yok,
kota yok, son 15 video. `search.list` ise sorgu başına 100 birim kota yiyor ve
karşılığında panele yeniden yükleme ve klikbeyt düşürüyor. Arama yolu kapalı
değil, ikinci aşamaya bırakıldı; kanal listesi veritabanında (`video_kanallari`)
olduğu için şema değişmeden eklenebilir.

**Kanal listesi kodda değil veriden.** Yeni kurum kanalı eklemek dağıtım
gerektirmemeli.

Kanalların yayın sıklığı çok farklı — akışlar tek tek doğrulandı: Bakanlık gün
aşırı video koyuyor, TMO ve TAGEM ayda birden seyrek, GAPTAEM neredeyse durgun.
Bahri Dağdaş UTAEM eklenmedi (son video 2016). Bölüm ilk aşamada ağırlıkla
Bakanlık içeriğiyle dolacak.

### 11.3 Onay insanın işi

Toplayıcı **hiçbir videoyu yayına almaz**, hepsi `bekliyor` yazılır. Sebebi:
toplayıcı videoyu izlemiyor, başlığını ve açıklamasını okuyor. Bakanlık
kanalında "Başkent Kulisi" de var "Büyükbaş Hayvan Küpe Takma Programı" da;
ikisini ayıran şey metinde yazmıyor.

**Reddedilen kayıt silinmez.** Silinseydi toplayıcı aynı videoyu ertesi gün
yeniden bulur, editör aynı kararı her gün yeniden verirdi.

Görünürlük süzgeci **RLS'te, görünümde değil**: `anon` rolü yalnızca
`durum = 'onaylandi'` satırlarını görüyor. Görünüm atlanabilir, politika
atlanamaz.

### 11.4 Kartta gömülü oynatıcı YOK

Anasayfaya altı YouTube iframe'i koymak, her açılışta YouTube betiğini altı kez
yükletir. Kartlar küçük görsel gösteriyor, dokunulan video kaynağında açılıyor.
Uygulama içi oynatma (`youtube_player_iframe`) ayrı bir adım — yeni bağımlılık
demek ve anasayfa hızını ölçmeden eklenmemeli.

### 11.5 Komutlar

```
python3 run_videos.py --days 400 --dry-run   # yazmadan bak
./run_videos_daily.sh                        # günlük toplama (launchd'ye bağlanmadı)
```

---

## 12. Hikâye şeridi — dosya kartları pencere boyunca sabit

*(Kullanıcı kararı, 29 Ağustos 2026.)*

Ülke ve kurum dosyasının hikâye kartı, dosya **yayında olduğu sürece** şeritte
durur. Diğer hikâyeler etrafında döner; dosya kartları düşmez.

### 12.1 İki ayrı sebep vardı, ikisi de sessizdi

**1. Ömür.** `dosya_hikayeleri.py` hikâyeye 24 saat veriyordu. Rusya dosyası
26 Eylül'e kadar yayında ama onu tanıtan baloncuk 30 Ağustos'ta düşüyordu.
Artık ömür = dosyanın penceresi (`ends_at`); 24 saat yalnızca pencere boş
geldiğinde devreye giren yedek.

**2. Sıralama.** Şerit tazelik puanına göre diziliyor, puan 8 saatte
yarılanıyor ve liste `maxGroups` ile kesiliyor. Haftalarca yayında kalan bir
dosyanın puanı sıfıra yaklaşıyor, kesintinin altında kalıyor ve **teknik olarak
"yayında" olduğu hâlde hiç görünmüyordu.**

### 12.2 `portal_stories.sabit`

- Sabit grup **kesintiden muaf**, ama listeye eklenmiyor — **yer ayırıyor**.
  Şeridin uzunluğu değişmiyor; sabitler kalan yerleri en taze haberlerle
  paylaşıyor. İstenen buydu: dosya kartları diğer hikâyelerin arasına katılsın,
  onların yerine geçmesin.
- Puanın **tabanı** var (`sabitTabanPuan = 0.35`, kabaca 12 saatlik bir haber).
  Muafiyet tek başına yetmiyordu: kart listede kalır ama en sona düşerdi.
  Dosya günün taze haberlerinin ARDINDA, dünkülerin ÖNÜNDE duruyor —
  başa geçirmek de yanlış olurdu, dosya son dakika değil.
- **İzlenmişse arkaya geçiyor**, düşmüyor. İzlendi defteri bir hafta sonra
  sıfırlandığı için kart 28 günlük pencerede kendiliğinden birkaç kez öne
  geliyor.
- Sabitlik **sonsuza kadar değil**: ömrü `expires_at` belirliyor. Pencere
  kapanınca kart düşer — kapanmış bir dosyaya çağıran baloncuk kalmaz.

**`hedef_yol is not null` koşulundan TÜRETİLMEDİ.** `hedef_yol` bilerek genel
bırakılmıştı ("yarın bir emtia sayfası için de hikâye üretilebilir"); öyle bir
hikâyenin sabitlenmesi gerekmeyebilir. Sabitlik bir yayın kararıdır, satır
bunu kendisi söyler.

### 12.3 Üretici artık idempotent

Betik elle ve tekrar tekrar çalıştırılıyor. Her çalışmada satırı silip yeniden
yazmak iki şeyi bozuyordu: hikâye kimliği değiştiği için **izlendi defteri
sıfırlanıyor** ve baloncuk okura her seferinde "izlenmemiş" görünüyordu;
ayrıca `created_at` tazelenip 28 günlük bir dosya sürekli en yeni hikâyeymiş
gibi başa geçiyordu.

Artık: canlı ve içeriği aynı satır varsa **dokunulmuyor**; yalnızca pencere
uzamışsa `expires_at` güncelleniyor, kimlik korunuyor.

### 12.4 Gelecek tarihli hikâye

`created_at` veritabanı saatiyle yazılıyor, tazelik puanı cihaz saatiyle
hesaplanıyor. İkisi kaydığında yaş NEGATİF çıkıyor ve `0.5^(-12) = 4096` gibi
bir puan doğuyordu; dört gün ileri tarihli tek bir satır şeridi ele
geçiriyordu. **Üretimde görüldü.** Yaş artık sıfıra kırpılıyor: böyle bir satır
elenmiyor (saat kayması hikâyenin suçu değil), "az önce yayımlanmış" sayılıyor.

## 13. Emtia genişletmesi — 29 Ağustos 2026

Emtia şeridi sekiz üründe (hepsi Polatlı hububat/yağlı tohum + Türkşeker
şeker) sıkışıp kalmıştı. İki ayrı eksiklik konuşuldu: (a) hububat/bakliyat
listesi dar, (b) çiftçinin **sattığı** şey dışında bir kalem yok — **aldığı**
şeyler (mazot, gübre, yem) hiç yok. Öncelik sırası: motorin → TOBB borsa
portalı → çiğ süt → TÜİK girdi endeksi. TMO taban fiyatları ve perakende
gübre fiyatı ertelendi (biri düzensiz/yıllık, diğeri kaynak güvenilirliği
sorunlu — bkz. 13.3).

### 13.1 Motorin — GERİ ALINDI

Motorin eklenmişti (EPDK verisi, `ucuzyakitbul.com.tr` aracılığıyla — bkz.
altta eski not) ve `commodities.category = 'girdi'` diye yeni bir kategori
açılmıştı. Aynı gün kullanıcı geri aldı: **"girdi maliyetleri iptal, yeteri
kadar ürün yok. motorini de sil."** Tek kalemlik bir kategori kendi başına
bölüm olmayı hak etmiyordu — bkz. §14 (iki şerit) de aynı gerekçeyle geri
alındı. Kaynak modülü (`motorin.py`), veritabanı satırı ve fiyat geçmişi
tamamen silindi (geçmiş bir günlüktü, saklamaya değecek veri yoktu — diğer
ürünlerdeki gibi `is_active = false` değil, tam silme).

Kaynak araştırması kendi başına değerliydi, ileride tekrar gündeme gelirse
diye not: EPDK'nin kendi web servisi artık yok (eski dokümantasyondaki SOAP
adresi `dbs.epdk.org.tr`/`dbs.epdk.gov.tr` DNS'te hiç çözülmüyor,
`bildirim.epdk.gov.tr` yalnızca elle doldurulan form). `ucuzyakitbul.com.tr/
api/prices/national` ücretsiz/anahtar istemeyen bir aracıydı ama birincil
kaynak değildi.

### 13.2 TOBB — hububat/bakliyat/yağlı tohum listesi genişledi

`tarim_ai_pipeline/src/commodities/sources/tobb.py`. TOBB'un merkezi portalı
(`borsa.tobb.org.tr/fiyat_urun3.php?ana_kod=X&alt_kod=Y`) Türkiye'deki TÜM
ticaret borsalarının fiyatlarını tek yerde topluyor. Beş ürün eklendi: nohut,
kırmızı/yeşil mercimek, kuru fasulye (kategori: yeni `'bakliyat'`) ve
ayçiçeği yağlık (`'yagli-tohum'`) — hepsi `source_key = 'ana_kod-alt_kod'`.

Polatlı'dan iki farkı var, ikisi de kod düzeyinde ele alındı:

  * **Bülten değil, anlık durum.** Sayfa tarih parametresi almıyor, her
    borsanın SON fiyatını gösteriyor — bugün de olabilir dört ay önce de.
    `fetch()` yalnızca gerçek bugün için çalışıyor, geçmiş doldurma yok.
    Her borsa satırı kendi tarihine göre ayrıca süzülüyor
    (`FRESHNESS_WINDOW_DAYS = 21`); süzgeçten hiç satır geçmezse o ürün o
    gün hiç yazılmıyor — sessizce, hata değil.
  * **Sayı biçimi tuzağı — üretimde yakalandı.** Miktar sütunu ondalık
    virgül OLMADAN binlik nokta kullanıyor ("18.200" = 18.200 kg). Ortak
    `parse_tr_number` noktayı yalnızca virgül de varsa siliyor, bu da
    fiyatı ~1000 kat şişiriyordu (ilk dry-run'da görüldü: 42.304 TL/kg).
    `tobb.py` kendi `_yerel_sayi()`'sini yazdı: nokta HER ZAMAN binlik.

Veri kalitesi notu: merkezi sistem elle dolduruluyor, ara sıra bariz hatalı
satır çıkıyor (Edirne/ayçiçeği: Ortalama alanına 39.436 TL girilmiş, gerçek
~40 TL'nin ~1000 katı — biçim hatasından ayrı, kaynağın kendi giriş hatası).
`_gurultu_ayikla()` medyandan 3 kattan fazla sapan satırı eliyor.

### 13.3 Çiğ süt — Türkşeker'den daha basit çıktı

`tarim_ai_pipeline/src/commodities/sources/sut.py`. Ulusal Süt Konseyi de
Türkşeker gibi fiyat İLAN ediyor (`price_kind = 'administered'`) ama PDF
değil, doğrudan okunabilir bir HTML tablo — her yıl tek bir sayfa, yeni karar
geldikçe tabloya satır ekleniyor:

    1 Ocak 2026 – 21 Ocak 2026     19,60
    22 Ocak 2026 – 30 Nisan 2026   22,22
    1 Mayıs 2026 –                 24,30   (bitiş yok = yürürlükte)

Türkşeker'in LLM okuyucusu (`turkseker_reader.py`) hiç gerekmedi — tablo
zaten yapılandırılmış veri. Türkşeker'in kampanya/bölgesel kapsam mantığı da
taşınmadı: süt tek ulusal fiyat, dönemler ÇAKIŞMIYOR, "o günü kapsayan dönem"
yeterli. Yıl sayfasının adresi tahmin edilemiyor (WordPress kendi ID'sini
veriyor); her çalışmada önce kategori listesinden o yılın linki bulunuyor —
yıl döndüğünde elle URL güncellemeye gerek kalmasın diye.

### 13.4 TÜİK Tarımsal Girdi Fiyat Endeksi — ertelendi

MEDAS (`biruni.tuik.gov.tr/medas`) TÜİK'in gerçek yapısal veri sistemi;
"Tarımsal Girdi Fiyat Endeksi" konu listesinde var. Ama arayüz ağır bir
ASP.NET etkileşimli seçim ekranı (konu → ölçüm → zaman → düzey seçilip
"getir" ile sorgu çalıştırılıyor); tarayıcı otomasyonu sayfayı boş
render etti, gerçek API çağrısını yakalayamadım. Ayrıca veri **aylık** ve
**endeks/% değişim** formatında — mevcut günlük "TL/birim" kart tipinden
farklı bir gösterim gerektirecek. Bir sonraki oturumda ya MEDAS'ın
ağ isteğini elle (tarayıcı geliştirici araçlarıyla) bulmak ya da
`data.tuik.gov.tr` üzerindeki aylık basın bülteni sayfasını (HTML, daha
basit ama daha az yapılandırılmış) okumak gerekiyor.

### 13.5 Ertelenenler

TMO taban fiyatları idari ama yıllık/kampanya bazlı duyuru — Türkşeker
modeliyle uygulanabilir, öncelik değil. Perakende gübre fiyatı (Üre, DAP)
**kasıtlı olarak eklenmedi**: haber sitelerinde aynı tarih aralığında
birbirini tutmayan rakamlar bulundu (Üre için aynı hafta içinde hem 26.000
TL hem 33.900 TL) — tek/yapısal bir kaynak yok, güvenilmez.

## 14. Emtia / girdi ayrımı, kart yüksekliği — 29 Ağustos 2026

### 14.1 İki ayrı şerit — GERİ ALINDI

Motorin eklendiğinde tek şerit iki farklı soruyu karıştırmaya başlamıştı:
"bugün ne kadara satıyorum" ile "bugün ne kadara alıyorum". Dört seçenek
sunulup (tek şerit + rozet, tek bölüm + sekme, gruplu tek şerit, iki ayrı
şerit) **iki ayrı şerit** seçilmiş, `CommodityStripsRow` ile masaüstünde yan
yana yerleştirilmişti (bkz. §14.3). Aynı gün motorinle birlikte GERİ ALINDI:
girdi tarafında tek kalem (motorin) vardı, bölüm açmaya değecek genişlik
yoktu. `girdi` parametresi, `girdiPricesProvider`/`emtiaPricesProvider` ve
`CommodityStripsRow` kaldırıldı; `CommodityStrip` tek şeride, anasayfanın
üç düzeninde de eski tek çağrısına döndü.

TÜİK'in girdi endeksi ileride gerçek çok kalemli bir veri getirirse (bkz.
§16), iki-şerit deseni burada nasıl yapıldığı biliniyor — sıfırdan
tasarlamaya gerek yok, sadece geri getirilir.

### 14.2 Kart yüksekliği 108/128 → 100/104

Bu değişiklik KALICI — motorin/girdi geri alımından etkilenmedi, tek şerit
için de geçerliliğini koruyor.

Kullanıcı gözlemi doğruydu: `_Summary`/`_Details` içindeki
`mainAxisAlignment: MainAxisAlignment.spaceBetween` içeriği kartın TAMAMINA
yayıyordu, kısa içerikli kartlarda (özellikle aralığı olmayan idari
fiyatlarda — Türkşeker, çiğ süt) altta boş bir bant kalıyordu. İki şerit yan
yana durunca bu boşluk iki kat önemli hale geldi.

`spaceBetween` → `MainAxisSize.min` + küçük sabit boşluklar (içerik artık
üstte topluca duruyor). Yükseklik tahmin değil, ölçümle belirlendi:
`test/emtia_kart_yukseklik_test.dart` en kötü senaryoyu (uzun kaynak adı —
"TOBB — Türkiye Odalar ve Borsalar Birliği" — + aralık bloğu + dar ekran)
üretip `tester.takeException()` ile taşma arıyor. 88 px'te 9 px taşıyordu;
100 px'te taşmıyor, üstüne pay bırakıldı (gerçek cihaz fontları test
fontundan sapabilir). Son değerler: 100 (dar ekran), 104 (geniş ekran).

### 14.3 Masaüstünde yan yana — `CommodityStripsRow` (GERİ ALINDI, §14.1 ile birlikte)

İki şerit masaüstünde alt alta dikeyde çok yer kaplıyordu. `DossierStrip`nin
zaten kullandığı desen tekrarlanmıştı (ülke/kurum dosyası kartları aynı
satırda yan yana duruyor): `CommodityStripsRow` widget'ı iki
`CommodityStrip`'i `Expanded` ile bir `Row`a koyuyordu, boşluğu tek kendisi
yönetiyordu (çocuklar kendi `spacing`'ini 0 verirdi). Widget'ın kendisi
`commodity_strip.dart`tan silindi — §14.1'deki geri alımla birlikte artık
yan yana koyacak iki şerit yok. Yaklaşımın notu (kart yüksekliği `MediaQuery`
genişliğine bakıyor, Row'un ayırdığı yarı genişliğe değil — o yüzden yan
yana durmak kart boyunu etkilemiyordu) ileride tekrar gerekirse diye burada
duruyor.

## 15. Pirinç — TOBB'da yok, TMO bülteninden

TOBB'da pirinç HİÇ işlem görmüyor — üretimde doğrulandı (29.08.2026): hem
"PİRİNÇ KIRIK" hem "PİRİNÇ ORTA TANE" hem "ÇELTİK" için "Bu ürün için veri
girişinde bulunulmamıştır." TMO'nun kendi günlük bülteninde
(`tarim_ai_pipeline/src/commodities/sources/tmo.py`) "PİRİNÇ (Sektör)"
bloğu var — Osmancık ve Baldo toptan fiyatı. Blok haftalık güncelleniyor,
`price_kind = 'administered'`. PDF metne dönüşünce sütunlar üst üste
biniyor (iki sütunlu sayfa düzeni); ayrıştırıcı ürün etiketinin hemen
ardından gelen ilk TL/ton rakamını alıyor, makul aralık kontrolüyle (5-300
TL/kg) satır kayması riskine karşı korunuyor.

## 16. TÜİK Tarımsal Girdi Fiyat Endeksi — MEDAS otomatikleştirilemez

Tarayıcıyla gerçekten denendi: Konu → "Tarımsal Girdi Fiyat Endeksi" → Ölçüm
→ Kırılım akışı çalıştırıldı, 22 alt kalemli bir kırılım listesi bulundu
(`[20] Tarımda Kullanılan Mal ve Hizmetler (Girdi 1)` ve devamı — muhtemelen
gübre/yem/tohum/enerji/ilaç/makine ayrı kalemler olarak burada). AMA: ağ
istekleri incelenince MEDAS'ın bir **ZK Framework** uygulaması olduğu
görüldü — her etkileşim tek bir genel `/medas/zkau` uç noktasına, sunucu
taraflı SESSION durumuyla gidiyor. Temiz bir REST/JSON API yok; güvenilir
otomasyon gerçek bir tarayıcı oturumu (Selenium/Playwright benzeri)
gerektirir — bu hattın hiçbir kaynağının kullanmadığı ağır bir bağımlılık.
**Vazgeçildi.**

**Alternatif bulundu, henüz uygulanmadı:** TÜİK'in aylık basın bülteni
sayfaları (`veriportali.tuik.gov.tr/tr/press/...`) düz HTML — MEDAS'ın
ZK uygulaması değil. İçerik anlatı/metin formatında ama alt grup adları ve
% değişimleri açıkça geçiyor: "gübre ve toprak geliştiriciler" (Temmuz
2026'da yıllık +%63,56), "enerji ve yağlayıcılar", "tarımda kullanılan mal
ve hizmetler", "tarımsal yatırıma katkı sağlayan mal ve hizmetler". Bu
Türkşeker'in ilan-okuma desenine (metin + doğrulama) uyar ama veri türü
FARKLI: TL/birim değil, aylık %değişim/endeks — mevcut kart tipi
("38,55 TL/kg ▲%5,01") buna uymuyor, ayrı bir kart tasarımı gerekiyor. Sıradaki
adım budur.

**Gübre/küspe için doğrudan TL fiyatı: bulunamadı.** Gübretaş resmi sitesi
ürün kataloğu, fiyat yok (B2B, bayi belirliyor). Türkiye Yem Sanayicileri
Birliği hammadde fiyatları sayfası yalnızca ÜYELERE açık. TOBB'un KÜSPELER
kategorisi tamamen boş ("henüz fiyat bilgisi girilmemiştir", üretimde
doğrulandı). Bu yüzden girdi çeşitliliğinin gerçekçi yolu TÜİK'in endeks
verisi — mutlak TL fiyatı değil, ama resmi ve güvenilir.

## 17. Hava durumu sayfası — inceleme ve düzeltmeler (29 Ağustos 2026)

Kullanıcı isteğiyle `weather_detail_screen.dart` (1461 satır),
`home_repository.dart`'taki `fetchAgricultureWeather`, model ve konum
sağlayıcıları uçtan uca incelendi; canlı sitede masaüstü + mobil test
edildi. Bulunan zayıflıklar önem sırasına göre düzeltildi.

### 17.1 En ciddi: sessiz sahte veri geri alındı

`fetchAgricultureWeather` eskiden Open-Meteo isteği başarısız olduğunda
(zaman aşımı, ağ hatası) sabit kodlanmış bir "mock" hava durumu
döndürüyordu (24,5°C, "Parçalı Bulutlu"...) — ekranda hâlâ yeşil "CANLI"
rozetiyle. Don riski ya da ilaçlama tavsiyesi gibi gerçek sonucu olan bir
bilgi, kaynak çökmüşken bile "canlı" görünüyordu. Bu, projenin geri
kalanının ilkesiyle (Türkşeker'in rakam doğrulaması, TOBB'un medyan-sapma
filtresi — "kaynağa körü körüne güvenme") doğrudan çelişiyordu.

Artık istek başarısız olursa hata YUKARI FIRLATILIYOR. Bu, kodda zaten
hazır ama hiç tetiklenmeyen iki hata ekranını devreye sokuyor:
`WeatherDetailScreen._buildErrorState` ve `app_router.dart`'taki
`_WeatherLoader`'ın `error` dalı — ikisi de geliştirici tarafından
yazılmış ama `fetchAgricultureWeather` hiç throw etmediği için ölü kod
olarak duruyordu. Hata ekranına ayrıca bir "Tekrar Dene" düğmesi eklendi
(`ref.invalidate(weatherProvider)`) — yoksa `FutureProvider` hata
durumunda kendiliğinden yeniden denemediği için okuyucu tıkanıp kalırdı.

Geçmiş yıl karşılaştırması (archive API) bu davranışı PAYLAŞMIYOR —  o
zaten "olursa iyi olur" niteliğinde, başarısız olursa kart hiç
gösterilmiyor, dokunulmadı.

### 17.2 Don riski artık BU GECEyi soruyor, ŞU ANI değil

`hasFrostRisk` hem `home_repository.dart`'ta (genel açıklama/uyarı metni
için) hem `weather_detail_screen.dart`'ta (metrik kartı için) `temperature
<= 4.0` kontrolüydü — yani ŞU ANKİ sıcaklık. Uyarı metni açıkça "Bu Gece
Don Riski Var!" diyordu ama kontrol öğlen 15°C'deyken bile "GÜVENLİ"
yazabiliyordu, gecenin -2°C'ye düşeceği hiç sorulmadan. İkisi de
`dailyForecast.first.minTemp`e (bugünün 0-24 saat tahmini düşüğü)
çevrildi. Sayfanın en somut, en çok başvurulan uyarısı olduğu için bu
bulgular arasında en yüksek öncelikliydi.

### 17.3 Konuma özel fotoğraf kaldırıldı

`location_image_provider.dart` (Unsplash arama) tamamen silindi.
`ApiConstants.unsplashApiKey`'in varsayılanı `'YOUR_UNSPLASH_ACCESS_KEY'`
placeholder'ıydı ve `deploy.sh` hiçbir yerde `--dart-define=
UNSPLASH_API_KEY` geçmiyordu — yani canlıda her kullanıcı, her şehirde,
AYNI sabit stok fotoğrafı görüyordu (doğrulandı: kutu taşıyan gönüllüleri
gösteren, Türkiye/tarımla ilgisi belirsiz bir görsel). Kod "konum ismine
göre görsel bulan akıllı provider" diyordu ama pratikte hiç öyle
çalışmıyordu. Anahtarı tedarik etmek yerine özellik kaldırıldı —
fotoğrafsız hâli (düz gradyan) tek başına yeterince şıktı.

### 17.4 Küçük düzeltmeler

- **Yağış miktarı eklendi.** Open-Meteo isteğine `precipitation_sum`
  eklendi (`DailyForecastItem.precipitation`), 7 günlük şeritte kuru
  günlerde boş bırakılan, yağışlı günlerde "X,Xmm" gösteren bir satır
  oldu — ikon tek başına "yağmurlu"nun 0,2 mm mi 40 mm mi olduğunu
  söylemiyordu.
- **Son güncelleme + kaynak künyesi eklendi.** "CANLI" rozetinin boş bir
  iddia olmaması için (bkz. 17.1). `WeatherInfo.fetchedAt` yeni alan.
- **Hafta günü kısaltması "PTS" → "PZT"** (Pazartesi için yerleşik olmayan
  bir kısaltmaydı).
- **Aynı rakamın iki farklı hassasiyeti birleştirildi.** Bugünün maksimum/
  minimum sıcaklığı 7 günlük şeritte tam sayı, geçmiş yıl kartında bir
  ondalıkla gösteriliyordu — aynı sayfada aynı değer iki farklı rakam gibi
  okunuyordu. İkisi de tam sayıya çekildi (geçen yılın değeri ve "Fark"
  başka bir rakam, ondalık kaldı).

### 17.5 Ertelenen

Hava durumu, uygulamanın geri kalanından farklı olarak üç dış API'ye
(Open-Meteo, Open-Meteo Archive, Nominatim) doğrudan istemciden,
önbelleksiz bağlı — Python hattından Supabase'e önceden çekilip
doğrulanmış diğer verilerin aksine. Bir önbellek katmanı eklemek
düşünüldü ama ertelendi: yanlış yapılırsa (taze göstererek bayat veri
sunmak) tam olarak 17.1'de düzeltilen sorunu farklı bir biçimde geri
getirir. Süresi/dayanıklılığı doğru tasarlanmış bir önbellek ayrı bir iş.

### 17.6 Test kapsamı

Bu özellik daha önce hiç test edilmiyordu. `test/hava_durumu_test.dart`
beş test ekledi: don riski gece düşüğüne bakıyor (iki yönde), PZT
kısaltması, fotoğrafın gerçekten kalktığı, ve hata durumunda "Tekrar Dene"
düğmesinin çıktığı. `_PulseDot`ın sonsuz döngüsü yüzünden bu dosyada
`pumpAndSettle` yerine sabit `pump()` kullanılıyor — aksi hâlde zaman
aşımına uğruyor.

## 18. Hava durumu — tasarım geçişi (29 Ağustos 2026)

§17'deki analizin ardından kullanıcı tasarım önerilerinin hepsini istedi,
tek bir kısıtla: **sayfa uygulamanın rengiyle aynı olmasın, "başka bir
alana girildiği" hissi kasıtlı korunsun.** Bu yüzden çözüm "hava durumunu
`AppColors`a bağla" değil, modülün KENDİ disiplinli paletini kurmak oldu —
bkz. `weather_detail_screen.dart` başındaki `_WeatherTheme` sınıfı.

### 18.1 Renk — altı rastgele Apple rengi → üç anlamlı renk

Eskiden altı metrik kartının her biri sabit bir Apple iOS sistem rengi
taşıyordu (renk hiçbir şey söylemiyordu). Şimdi `_Seviye` enum'u (iyi /
dikkat / tehlike) her kartın KENDİ tavsiye mantığından (`windRec`,
`humRisk`, `soilRec`...) türüyor — renk artık dekor değil bilgi taşıyor.
`tehlike` (kırmızı) BİLEREK yalnızca don riskine ayrıldı — ana uygulamanın
"kırmızı tek anlam taşır, her yere dağılırsa değersizleşir" ilkesiyle aynı
disiplin, farklı bir palet üzerinden.

### 18.2 Tema desteği — ama kirece dönmeden

Sayfa artık `Theme.of(context).brightness` okuyor (`isDark`), eskiden hiç
tanımıyordu — uygulama açık temadayken bile zorla koyu ekrana düşülüyordu.
Ama açık temada `AppColors.creamBackground`a dönmüyor: kendi açık-gökyüzü
gradyanları var (`_WeatherTheme.gradient`). Tek istisna GECE: `iconCode`
'n' ile bitiyorsa uygulamanın teması ne olursa olsun ekran koyu kalıyor —
dışarıda gerçekten karanlıksa açık temada bile gökyüzünü mavi göstermek
yanlış olurdu (`_koyuGorunum = isDark || isNight`).

### 18.3 Tipografi ve köşe dili

App bar başlığı, kart üst etiketleri ("ZİRAİ HAVA DURUMU TAHMİNİ" vb.) ve
sıcaklık/description artık `Playfair Display` — uygulamanın bölüm
başlıklarıyla aynı ses. Sayısal değerler (dev sıcaklık, 7 günlük şerit,
geçmiş yıl karşılaştırması, metrik kartı değerleri) `Roboto Mono`ya
taşındı — uygulamanın "rakamlar özel yazı tipiyle" ilkesiyle örtüşüyor.
Kart/etiket puntoları 9-10px'ten 11-13px'e çıkarıldı. Köşe yarıçapı tek bir
değerde (`_kRadius = 16`) birleşti — eskiden hero 32px yuvarlak, kartlar
0px keskindi, sayfa kendi içinde bile tutarsızdı.

### 18.4 Breakpoint sabiti

`_MetricsGrid`'in masaüstü eşiği artık `ResponsiveBreakpoints.
isDesktopOrLarger` (1100) — eskiden sabit `700` uygulamanın tablet/masaüstü
tanımıyla (1100) örtüşmüyordu.

### 18.5 Üretimde yakalanan gerçek hata

Uyarı durumundaki kartın üst kenarını vurgu rengine, diğer üç kenarını nötr
renge boyayıp `borderRadius` eklemek Flutter'da patlıyor: *"A borderRadius
can only be given on borders with uniform colors."* Bunu elle fark etmedim
— `test/hava_durumu_test.dart`'taki mevcut testler yakaladı (`paint()`
sırasında `RenderDecoratedBox` istisnası). Çözüm: uyarı durumunda TÜM
kenarlık vurgu rengine dönüyor (`Border.all`, tek renk) — tek başına daha
güçlü bir işaret oldu, köşe yarıçapıyla da uyumlu.

### 18.6 Test kapsamı genişledi

İki yeni test eklendi: açık temada hatasız çizildiği, ve gece ikonunun açık
temada bile koyu kaldığı (`test/hava_durumu_test.dart`, toplam 7 test).
**Görsel doğrulama henüz yapılmadı** — bu oturumda deploy kullanıcıya
bırakıldığı için açık/koyu tema ve masaüstü/mobil görünümü gerçek
tarayıcıda gözle kontrol edilmedi, yalnızca kod + testlerle doğrulandı.
Deploy sonrası bir gözden geçirme öneriliyor.
