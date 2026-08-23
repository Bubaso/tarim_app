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

İzlenebilirlik zinciri, her halka denetlenebilir:

```
kaynak API/CSV → _raw/*.json → data.json → grafikler.json (@path)
              → charts jsonb → seed SQL → veritabanı
```

**Yuvarlama depoda değil çizimde yapılır.** Veritabanında tam değer durur.

Bulunamayan rakam gizlenmez: `yayin.json` içindeki boşluk kayıtları sayfada
**Veri Notları** panelinde açıkça gösterilir. Katlanabilir kutuda değil,
açıkta. Bu panel dosyanın en güçlü kısmı.

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
