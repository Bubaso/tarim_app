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

### 2.4 Bölüm sırası

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

Dosya testleri (şu an 71 test, hepsi yeşil):
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
