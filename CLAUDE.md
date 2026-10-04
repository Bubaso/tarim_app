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

### 1.1 Alan adı ve CORS — dosya görselleri buna takıldı

**Canlı adres artık `tarimportali.net`.** `tarim-app-2026.web.app` de aynı
Firebase Hosting sitesini sunmaya devam ediyor.

29 Ağustos 2026'da alan adı bağlandıktan sonra **dosya görselleri görünmez
oldu, haber görselleri çalışmaya devam etti.** Sebep:

- Dosya görselleri veritabanında **mutlak adresle** duruyor ve konak
  `tarim-app-2026.web.app` (§2.4: `NewsArticleImage` göreli yol kabul etmiyor).
  Sayfa `tarimportali.net`'ten açılınca bu adres **çapraz köken** oldu.
- Flutter web (CanvasKit) görseli `<img>` ile değil **XHR ile** çekip tuvale
  çiziyor. Çapraz kökende bu CORS başlığı istiyor; Firebase Hosting varsayılan
  olarak `Access-Control-Allow-Origin` GÖNDERMİYOR.
- Haber görselleri Supabase Storage'dan geliyor ve o `*` ile CORS açıyor —
  bu yüzden yalnızca dosya görselleri kırıldı ve sebep gizlendi.

Çözüm `firebase.json`'da, tek kural:

```json
{ "source": "**/*.@(woff2|png|jpg|jpeg|webp|svg)",
  "headers": [
    { "key": "Access-Control-Allow-Origin", "value": "*" },
    { "key": "Cross-Origin-Resource-Policy", "value": "cross-origin" } ] }
```

Kural **her iki yönü** kapatıyor: hangi alan adından açılırsa açılsın görsel
öteki konaktan çekilebiliyor. Yeni bir alan adı eklenirse tekrar uğraşılmıyor.

**TEŞHİS TUZAĞI — bir kez yanlış yola sapıldı.** Tarayıcıda
`fetch(url).then(r => r.headers.get('access-control-allow-origin'))` çağırmak
düzeltmeden SONRA da `null` döndürüyor: bu başlık CORS güvenli listesinde
değil, `Access-Control-Expose-Headers` olmadan JavaScript'e hiç görünmüyor.
Doğru sınama **isteğin başarılı olup olmadığı**: CORS engellenmiş olsaydı
`fetch` reddedilirdi, 200 ile dönmezdi. Başlığı görmek için `curl -D-`.

İkinci tuzak: konsoldaki CORS hataları gezinti sonrası tamponda kalıyor.
Düzeltmeden sonraki ilk okumada eski hata hâlâ görünüyor — ekran görüntüsü
konsoldan daha güvenilir.

### 1.1.1 Kanonik alan adı taşıması — kısmen yapıldı (10 Eylül 2026)

**Yapılanlar.** Kullanıcı paylaşım kartında eski adresi gördü ve iz iki yere
çıktı:

- `content/dossiers/_ortak/paylasim_karti.mjs` — kartın altındaki GÖRÜNEN
  adres satırı.
- `content/dossiers/_ortak/statik_sayfa.mjs` → `ADRES` — bundan daha ciddisi:
  her dosyanın **`og:url` ve `og:image`** etiketi buradan kuruluyordu, yani
  **beş dosyanın da** paylaşım önizlemesi eski adresi gösteriyordu. `deploy.sh`
  her yayında bütün kabukları yeniden ürettiği için tek dağıtım hepsini
  düzeltti.

`web/index.html`'deki `tarim-app-2026` geçişleri Firebase **proje kimlikleri**
(`authDomain`, `projectId`, `storageBucket`) — alan adı değil, dokunulmaz.

**TAŞIMA TAMAMLANDI (10 Eylül 2026)** —
`20260910180000_kanonik_alan_adi.sql`. Veritabanındaki **45 görsel adresinin
tamamı** artık `tarimportali.net`; eski konakta kalan yok ve hepsi 200
dönüyor (tek tek denendi).

Kaynak dosyalar (`content/dossiers/*/yayin.json`) zaten yeni adresi
yazıyordu; taşınmamış olan yalnızca veritabanıydı — o satırlar alan adı
bağlanmadan önce yazılmış ve o günden beri yeniden seed edilmemişlerdi.

Kapsam: `country_dossiers.cover_url` (2) · `dossier_sections.gorsel->>'url'`
(34) · `portal_stories.gorsel_url` (11) · `portal_stories.items[].gorsel_url`
(29). Beş paylaşım kartı da yeni adresle yeniden basıldı.

> **jsonb DİZİSİNDE SIRA.** Slayt görselleri `items` dizisinin içinde ve
> `jsonb_agg` girdisini kendiliğinden sıralamıyor. Sıra `with ordinality`
> ile taşınıp `order by` ile geri verildi; verilmeseydi slaytlar karışır ve
> bu **sessiz** bir hata olurdu — hikâye yine dört slayt gösterirdi, sadece
> yanlış sırayla. Sağlama bloğu hem kalan eski adresi hem de slaytları
> boşalan hikâye olup olmadığını ayrıca sınıyor. Taşıma sonrası sıra elle
> de doğrulandı: her hikâyenin son slaytı hâlâ "→ dosyamıza göz atın".

Taşıma tek yönlü ve geri alınabilir: iki konak aynı Firebase sitesini
sunuyor, dosyalar ikisinde de duruyor.

### Ortam tuzağı — İKİ ayrı sebep var, ikincisi aylarca gizli kaldı

**1. Node sürümü.** `functions/package.json` → `engines: node 22`. Yerelde
node 24 kuruluysa kod tanıma adımı 2 GB heap'i tüketip çökebiliyor; hata
mesajı yanıltıcı biçimde "Timeout after 10000" diyor.

```
brew install node@22
export PATH="/opt/homebrew/opt/node@22/bin:$PATH"
```

**2. iCloud — ASIL SEBEP (6 Eylül 2026'da bulundu).** Depo `~/Desktop`
altında ve orası iCloud senkronizasyonuna dahil. `functions/node_modules`
senkronizasyon altındayken `index.js`in yüklenmesi **386 saniye** sürüyordu;
Firebase'in kod tanıma penceresi 120 saniye. Sonuç: fonksiyonlar aylarca
yayınlanamadı ve hata her seferinde "Cannot determine backend specification.
Timeout after 120000" olarak göründü — node sürümü doğru olduğunda bile.

Aynı kök sebep derleme sırasındaki `Operation timed out, errno = 60`
görsel kopyalama hatalarını da açıklıyor.

Çözüm — macOS'ta `.nosync` uzantılı yollar iCloud'a alınmıyor:

```
cd functions
mv node_modules node_modules.nosync
ln -s node_modules.nosync node_modules
```

Ölçüldü: **386 sn → 3,8 sn.** `npm install` sonrası sembolik bağ korunuyor;
bozulursa yukarıdaki iki satır yeniden çalıştırılır.

`firebase deploy --only hosting` her iki tuzaktan da etkilenmez.

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

- **UN Comtrade — ÜÇ boyut, üçü de aynı desende.** `customsCode` (C00 = tüm
  gümrük rejimleri, C01/C04/C06 = kırılım), `motCode` (0 = tüm taşıma türleri,
  2100/3200 = kırılım) ve **`partner2Code`** (0 = tüm ikinci partnerler,
  ülke kodları = kırılım). Kural: `customsCode='C00'` **ve** `motCode=0`
  **ve** `partner2Code=0`. Süzgeç hem sorguya hem gelen satıra uygulanır; iki
  kere, çünkü sunucu süzgeci sessizce yok sayabilir.

  > **Üçüncüsü 11 Eylül 2026'da bulundu ve yayında olan bir hatayı ortaya
  > çıkardı.** Bu maddede uzun süre şöyle yazıyordu: *"Ölçüldü (2023, HS 1001,
  > Rusya→Türkiye): doğru 5.321.335.842 $, tüm satırlar toplanınca
  > 10.642.671.684 $ — tam iki katı."* O "doğru" da iki katıydı. Gerçek rakam
  > **2.660.667.921 $**. İlk tur bir katmanı soydu, altındakini görmedi.
  >
  > Dersi tek cümle: **bir çift sayım bulmak, çift sayımın bittiği anlamına
  > gelmiyor.** Aynı API aynı deseni üç ayrı boyutta tekrarlıyor olabilir.
  > Yeni bir uç noktada kural artık şu: satırları toplamadan önce, toplulaştırıcı
  > satır içeren HER boyut tek tek aranır — "toplam × 2 mi?" diye değil,
  > "hangi boyutlar toplam satırı taşıyor?" diye sorulur.

  Rusya dosyasındaki etkisi (`comtrade_fetch.mjs` partner2 süzmüyordu):
  `ikili_ticaret`, `ambargo_2016` ve `girdi_kanali` blokları, `ticaret_cizgi`
  grafiği ve iki dilde yirmi kadar cümle **tam iki katı**. İki yönde de her
  yılda da oran 2,000× — yani dosyadaki bütün ORANLAR (yüzdeler, "yarısının
  altına indi", denge yönü, sıralamalar) korunuyor; yanlış olan yalnızca
  mutlak dolar rakamları. Hollanda dosyası temiz: Comtrade değil FAOSTAT
  ikili kullanmış.
> **DOKUZUNCU TUZAK — TOPLAYICI SATIRIN KENDİSİ EKSİK OLABİLİR VE SIFIR
> GÖRÜNÜR** *(12 Eylül 2026, İspanya 11. bölüm sondası).* `partnerCode=0`
> (dünya) ile Türkiye'nin 2020 zeytinyağı ithalatı **0** dönüyor. Aynı yıl
> `partnerCode=760` (Suriye) **40.848 ton** veriyor. Yani dünya satırı sıfır
> değil, YOK — ve API bunu hata olarak değil boş sonuç olarak bildiriyor.
>
> Bu sıfıra dayanarak "Türkiye'nin ithalat yapmadığı yıl iki defter uyuşuyor"
> diye bir bulgu kurulmuştu ve yanlıştı; kırılım sorgusu onu çürüttü. §2.2.1'in
> baştaki kuralı toplayıcı satırın FAZLA saymasına karşıydı; bu, aynı satırın
> EKSİK olmasına karşı. **Kural: toplayıcı satır, en az bir kırılım sorgusuyla
> karşılaştırılmadan kullanılmaz.** Eksik toplayıcı, fazla toplayıcı kadar
> sessizdir ve ters yönde yanıltır.

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

**Ve tam olarak bu kontrol Rusya'da hiç yapılmadı.** Yukarıdaki cümlenin son
yarısı — "çift sayım olsaydı ~2× olurdu" — partner2 hatasını bir sorguda
yakalardı. Rusya dosyası Comtrade'i tek kaynak olarak kullandı ve bağımsız bir
yakaya karşı hiç ölçülmedi; hata on sekiz gün yayında kaldı. **Kural: tek
kaynaktan gelen her manşet rakamı, yayından ÖNCE bağımsız bir kaynağa karşı
oranlanır.** Beklenen oran 1'e yakın (ölçü farkı kadar); 2'ye yakın çıkan her
oran çift sayım sayılır ve aksi kanıtlanana kadar öyle kalır.

### 2.2.2 `dogrula_metin.py` neyi kanıtlar, neyi kanıtlamaz

*(11 Eylül 2026, Rusya çift sayım düzeltmesinden çıktı.)*

Bu betik dosyanın en sıkı denetimi sayılıyordu. Çift sayım hatası boyunca
**yeşil yandı** — hatadan önce de sonra da "Temiz: metinde veri katmanına
dayanmayan sayı yok" dedi.

Yanlış değil, dar: betik **metnin veri katmanından sapmadığını** kanıtlıyor.
Veri katmanının kendisi yanlışsa metin ona sadık kalır ve denetim geçer.

```
kaynak → data.json → metin
         └────────────┘  dogrula_metin.py burayı sınıyor
  └──────┘               burayı KİMSE sınamıyordu
```

Kaynak ile veri arasındaki halkanın karşılığı, §2.2.1'in sonundaki çapraz
kontrol kuralıdır. İkisi birlikte zinciri kapatıyor; biri tek başına yetmiyor.

İki ek zayıflık ölçüldü, ikisi de düzeltilmedi çünkü gevşekliğin kendisi
bilinçli (yanlış alarm metni yazdırmaz hâle getirirdi) — ama bilinmeli:

- **Havuz fazla geniş.** `v`, `v/1e3`, `v/1e6`, `v/1e9`, `v*100` ve en büyük
  400 değerin bütün ikili oranları havuza giriyor. Veri tam ikiye bölününce
  etkilenen otuz kadar sayıdan yalnızca **12'si** işaretlendi; gerisi havuzda
  tesadüfen bir karşılık buldu. Yani betik veri kaymasına bile zayıf duyarlı.
- **Tablo hücreleri birimsiz.** "1,56 milyar" aramasıyla bulunan bir kalem,
  tabloda `| 1.555 |` diye geçtiğinde bulunamıyor. Sayı düzeltmesi yapılırken
  tablolar AYRI taranır; birim kelimesine dayanan arama onları göremez.

---

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
| 3 | İspanya | Rakip | Zeytinyağı + narenciye — **yayımlandı 13 Eylül 2026** |
| 4 | **Avustralya** | Model | Su ve kuraklık — **sıradaki** |
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

**Sıradaki Avustralya.** İspanya 13 Eylül 2026'da yayımlandı; takvimdeki
"Yakında" satırı Avustralya'ya devredildi. Mısır altıncı — bir kez üçüncü
sanılmıştı.

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

#### 2.12.1 İspanya devri — ve yayına çıkan sessiz bir kırık görsel

*(13 Eylül 2026. Kullanıcı kararı: devir takvimden 13 gün öne çekildi.)*

Sıra §2.12'deki gibi yürütüldü: paylaşım kartı → `./deploy.sh --hosting` →
görsel/rota doğrulaması → `supabase db push` → hikâyeler. On üç görselin
content-type'ı, CORS başlıkları, `/ulke/ispanya`nın eğik çizgisiz 200'ü ve og
etiketleri migration'dan ÖNCE tek tek sınandı. Migration'ın sekiz sağlaması da
geçti: aktif dosya sayısı, ülke aktifinin ispanya olması, **kurum aktifinin
değişmemiş olması**, Rusya'nın archived olması, takvimde Avustralya'nın olması,
takvimde İspanya'nın ETKİN OLMAMASI, 23 bölüm, 12 görsel, 11 grafikli bölüm.

**Ama bir görsel yine de kırık yayına çıktı ve durum kodu onu gizledi.**

`yayin.json/hikaye` bloğunun üçüncü slaydı `ispanya_almazara_aulago.jpg`
istiyordu. O ad, içerik hatası yüzünden reddedilmiş bir görsele aitti; bölüm
görsellerinde `..._garciez.jpg` ile değiştirilmiş ama **hikâye bloğunda eski ad
kalmıştı.** Dosya depoda yok ve Firebase var olmayan yola SPA yönlendirmesiyle
`index.html` veriyor:

```
curl -o /dev/null -w '%{http_code}'               → 200      ✅ temiz görünür
curl -o /dev/null -w '%{http_code} %{content_type}' → 200 text/html  ❌ gerçek
```

Yayın öncesi görsel denetimim `web/dosya/ispanya/` altındaki dosyaları
tarıyordu; hikâye slaytları oradaki listede olmayan bir ada işaret ettiği için
denetimin kapsamı dışında kaldı. Slayt yayında siyah çıktı.

*Kural, iki parçalı ve ikisi de artık koda gömülü:*

1. **Görsel varlığı durum koduyla sınanmaz, CONTENT-TYPE ile sınanır.** Bu
   projede 404 diye bir şey yok; olmayan yol 200 + HTML dönüyor. Aynı tuzak
   §8.14.1'de kurumun kendi sitesi için de yazılıydı — orada "yumuşak 404"
   deniyordu. Kendi konağımızda da var.
2. **Denetim, dosya listesinden değil KAYITTAN yürür.** Depodaki dosyaları
   saymak, kaydın neyi istediğini söylemiyor. `scripts/dosya_hikayeleri.py`
   artık her slaydın adresini tek tek çekiyor, `image/` ile başlamayan
   content-type'ta o dosyanın hikâyesini HİÇ YAZMIYOR ve sıfırdan farklı
   çıkış kodu veriyor. Yarısı siyah bir hikâye, hiç hikâye olmamasından kötü.

*Üçüncü ders, daha genel:* bir görsel reddedildiğinde adı depodan silinmekle
kalmıyor, ona işaret eden HER kayıt aranmalı. Bu dosyada `yayin.json` içinde
iki ayrı yer görsel adı taşıyor (`bolum_gorselleri` ve `hikaye.slaytlar`) ve
`_raw/gorseller/kunye.json` hâlâ reddedilmiş adı listeliyor.

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

### 2.14 Bölüm hacmi — veriyi toplamak yazmak değildir

*(İspanya dosyası, 12 Eylül 2026. Kullanıcı ilk taslağı reddetti: "kısa kısa
bölümler, başından savma iş, hikâye yok, bağlam yok, lise kompozisyonu gibi.")*

Ölçüldü ve şikâyet doğru çıktı:

| | bölüm | toplam | **bölüm ortalaması** |
|---|---|---|---|
| Hollanda | 17 | 5.761 | 338 |
| Rusya | 20 | 5.449 | 272 |
| İspanya (ilk taslak) | 22 | 3.189 | **138** |

İspanya'nın EN UZUN bölümü (232), Rusya'nın ORTALAMASININ altındaydı.

**Teşhisi veren ölçü kelime sayısı değil, veri/metin oranıydı.** `data.json`'daki
637 sayısal kalemin **635'i** metne girmişti — yani veri sayfası düzyazıya
çevrilmiş, hiçbir şey seçilmemiş, hiçbir şey dışarıda bırakılmamıştı.

```
kalem başına kelime:  Hollanda 10,6 · Rusya 2,6 (zaman serisi ağırlıklı)
İspanya ilk taslak 5,3  →  yeniden yazımdan sonra 9,1
```

Rakamlar aynı kaldı; değişen etraflarındaki metin. **Araştırmayı genişletmek
yazıyı genişletmiyor** — ikisi ayrı iş ve ikincisi atlanabiliyor.

Üç alışkanlık dosyayı "başından savma" gösteriyordu:

1. **Her bölüm aynı kalıpta.** 3-5 kısa paragraf rakam, sonunda tek satırlık bir
   vecize ("Altyapı var, su yok." / "Mutasyonu yapan ağaçtı."). Yirmi iki bölümde
   yirmi iki kez. Bir üslup değil tik, ve açıklamanın YERİNE geçiyor. Yeniden
   yazımda 3'e indi.
2. **Dizinin iç iskeleti metnin içinde ilan ediliyordu.** "Bu dizide dördüncü
   anlatı kategorisi ... arıyor" (§2.8) üç bölümde geçiyordu. Bu, §2.10'un
   yasakladığı meta cümlenin kılık değiştirmiş hâli: öğrencinin hangi rubrik
   maddesini doldurduğunu yüksek sesle söylemesi. **§2.8 bir kontrol listesidir,
   metinde adı geçmez.** Kategorinin içeriği kalır, adı gider.
3. **Açılış bölümü tezi bildirip susuyordu** (97 kelime). Ölçü Rusya'nın açılışı:
   rakamla başlar, bir ÇELİŞKİ kurar, çelişkiyi tek bir orana indirir ve dosyanın
   tamamını o oranın açıklaması ilan eder. Ayrıca kanıtın CİNSİNİ söyler
   ("Rusya'nın ticaret istatistiği 2022'den beri yayımlanmıyor").

**Kaynakça bir bölümdür, unutulmaz.** İspanya'da hiç yoktu; Rusya'da 415 kelime.
Veri kaynakları KUSURLARIYLA yazılır (IOC'nin donmuş AB satırları, embalses.net'in
ikincil oluşu, Eurostat yapı tablolarında Türkiye'nin bulunmaması) — bu bir veri
notu paneli değil, okurun kaynağıdır (§8.2).

#### 2.14.1 Genişletmenin kendi tuzağı: bellekten gelen iddia

Metni 138'den 250 kelimeye çıkarmak, aradaki boşluğu DÜZYAZIYLA doldurmak demek —
ve o düzyazıya dokuz kaynaksız iddia sızdı. Hepsi makul, hepsi muhtemelen doğru,
hiçbiri belgeli: zeytinin periyodisitesi, "toplandığı gün işlenmezse asitlenir",
şaraplık bağda düşük verimin tercih olduğu, bademin dağlık arazide yetiştiği,
safranın her çiçekten üç tel verdiği, "mar de plástico" adı, tüketimin ayçiçeğine
kaydığı, şişeleme tesisinin barajdan ucuz olduğu, mahkemenin beş yüz yıllık
olduğu.

**`dogrula_metin.py` bunların hiçbirini göremez** — yalnızca RAKAM izler, ve bu
iddiaların çoğunda rakam yok ya da yazıyla yazılmış ("üç tel", "beş yüz yıl").
§2.2.2 betiğin dar olduğunu yazıyordu; bu, darlığın ikinci yüzü.

*Kural: bir bölüm genişletildiğinde yeni düzyazı AYRICA elden geçirilir. Sorulacak
soru "bu doğru mu" değil, "bunu nereden biliyorum" — cevap `data.json` ya da
`_raw/` değilse cümle çıkar. Çıkarmak zorunda kalınan yerde çoğu zaman daha iyi
bir cümle var: safranın botaniği yerine bakanlığın kendi kalem adı
(*azafrán, estigmas tostados*), ağacın periyodisitesi yerine Konsey'in kendi
serisindeki bir yıl aşağı bir yıl yukarı salınım.*

#### 2.14.2 Eksik hikâye kaynakla kapatılır, hayalle değil

Su mahkemeleri bölümü kanun metnine dayanıyordu ve ham kayıttaki `_sinir` alanı
açıkça "toplanma biçimi ve sözlü yargılama usulü BELGELENMEDİ" diyordu. Sahne
uydurmak yerine kaynak arandı: mahkemenin kendi resmî sitesi
(`tribunaldelasaguas.org`) perşembe 12.00'yi, Havariler Kapısı'nı, sekiz
acequia'yı, mübaşirin pirinç zıpkınını, çağrı sırasının kanalların sudan
yararlanma sırası olduğunu ve gıyapta yargılamanın "hiç gerekmediğini" veriyor.

Kaynak niteliği **kurumun kendi beyanı** olarak işaretlendi (kanun metniyle aynı
ağırlıkta değil) ve metinde belirtildi. UNESCO'nun kaydı da denendi; sayfa
CAPTCHA istiyor ve bu yol kapalıdır.

*Kural: bir bölümün hikâyesi yoksa önce KAYNAK aranır. Bulunamazsa bölüm kısa
kalır — ama uydurulmaz. Ham kayıttaki `_sinir` alanları bu aramanın listesidir.*

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

**Yayında:** İspanya dosyası (edition 3, 23 bölüm, TR ~5.978 / EN ~7.965
kelime). `/ulke/ispanya` 200 dönüyor, pencere 10 Ekim 2026'da kapanıyor.
Rusya ve Hollanda arşivde.

**Yayında (kurum):** TAGEM dosyası (Sayı 04, 13 bölüm). `/kurum/tagem`
statik kabuğu dosyanın kendi og etiketleriyle dönüyor (§2.5); pencere
29 Eylül 2026'da açıldı, 13 Ekim 2026'da kapanıyor. Kapak görseli yok,
tipografik iskelete düşüyor (§3.5, §8.8). TMO, Ziraat Bankası ve Tarım
Kredi arşivde.

**Eski kayıt:** Hollanda dosyası (edition 1, 13 bölüm, TR ~4.826 / EN ~6.328
kelime). `/ulke/hollanda` ve `/ulkeler` 200 dönüyor.

**Açık:**

1. ~~`dossierRenderer` + `sitemap` yayınlanamadı~~ — **ÇÖZÜLDÜ (6 Eylül 2026).**
   Sebep node sürümü değil iCloud'du (bkz. §1). Dokuz fonksiyonun tamamı
   yayında; `dossierRenderer` ilk kez oluşturuldu, `sitemap` artık 798 adresi
   doğru alan adıyla üretiyor.

   `/ulke/**` yönlendirmesi yine de **eklenmedi**: dosya sayfaları statik
   kabukla çalışıyor (§2.5) ve o yol sınanmış durumda. Eklenecekse
   `/sitemap.xml` girdisinden önce gelmeli.

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

> **Bu kutu tarihî kayıttır: RAF KALKTI.** `/kurum/` ve `/kurumlar`
> rotaları geri geldi, dizi yürüyor ve dört sayı yayımlandı (§8.13). Kutu,
> dizinin bir kez TON yüzünden durdurulduğunu kaydettiği için duruyor —
> gerekçesi §8.2 (duruş) ve §8.11 (ton artık betikle sınanıyor) oldu.

**Durum: dizi yürüyor, Sayı 04 (TAGEM) yayında** (§7, §8.13). Sayı 01 (TMO)
için ham kaynaklar `content/dossiers/tmo/_raw/` altında; `data.json` kilitli
ve 21 kalemi `dogrula_veri.py` ile ham kaynağa karşı doğrulanıyor. Metin
yazıldı (TR ~3.670, EN ~4.700 kelime) ve Sayı 01 olarak yayımlandı
(22 Ağustos 2026); bugün arşivde.

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
  **YAZILDI (10 Eylül 2026, Sayı 03 için.)** `dossier_chart.dart`
  (`IslemAkisiChart` + `AkisAdimi`), `dossier_chart_view.dart` (`_IslemAkisi`),
  `seed_dossier.mjs/TURLER`. İki yıl gecikmesinin sebebi kod değil kaynaktı
  (§8.12). Kararlar: düğüm KARE ve içinde adım numarası var — zaman
  çizelgesinin dairesinden ve yılından biçimle ayrılıyor, çünkü ikisi aynı
  dosyada yan yana geçebiliyor. `secenekler` alanı bir adımın alternatif
  yollarını AYRI satırlara koyuyor ("noterde" *ya da* "ihtiyar heyetinde");
  tek satıra sıkışırsa okur seçim olduğunu fark etmiyor. `sure` belgelenmemişse
  boş kalır, tahmin yazılmaz.
- `ticaret_akisi` — bir malın nereden gelip nereye gittiği; kalınlık MİKTARLA
  orantılı. **YAZILDI (11 Eylül 2026, İspanya dosyası için.)**
  `dossier_chart.dart` (`TicaretAkisiChart` + `AkisMerkezi` + `AkisKolu`),
  `dossier_chart_view.dart` (`_TicaretAkisi`), `seed_dossier.mjs/TURLER`.
  Kullanıcı onayı alındı; İspanya'nın omurgası bir akış (dökme yağ Türkiye'den
  çıkıyor, İspanyol şişesinde dünyaya dönüyor) ve mevcut sekiz tipin hiçbiri
  miktar akışı çizmiyordu.

  `islem_akisi` ile karıştırılmaz: o bir SIRA çiziyor (adımlar eşit ağırlıkta,
  bağ "önce/sonra"), bu bir MİKTAR (kollar eşit değil, bağ "ne kadarı").

  Üç çizim kararı, üçü de bilerek:

  1. **Yamuk yok.** İlk taslak iki şeridi merkez kutusuna yamuklarla
     bağlıyordu; şerit kutudan darsa yamuk genişleyerek iniyor ve gözde
     "arttı" izlenimi bırakıyor. Oysa kutu bir etiket, miktar değil. Bağ düz
     bir ok; karşılaştırma şeritlerin kendi uzunluğundan okunuyor.
  2. **Her şeridin arkasında sönük bir cetvel var**, cetvel iki yakanın
     büyüğü. Giren çıkandan azsa şerit cetveli doldurmuyor ve eksik pay
     BOŞLUK olarak görünüyor.
  3. **Fark için cümle üretilmiyor.** Grafiğin elinde farkın sebebi yok —
     stok mu, iç tüketim mi, yeniden ihracat mı bilmiyor. `fark` alanı sayıyı
     verir, yorum `not` alanına yazılır (§2.2).

  `merkez.kendi` merkezin kendi ürettiği payı ayrı bir kol gibi, listenin
  sonunda ve taramalı çiziyor: dışarıdan gelenle içeride üretilen aynı
  desende olsaydı şerit tek yığına dönerdi. Değeri bilinmeyen kol listeden
  DÜŞER — sıfır genişlikte çizmek okura "hiç almadı" demek olurdu.

  **`giren_basligi` / `cikan_basligi` yaka başlıkları geçici bir altın dosya
  denemesinde bulundu.** İki şerit ve iki döküm listesi birbirinin aynıydı;
  aralarındaki boşluk tek başına "burada yaka değişti" demiyordu. Başlıklar
  hem şeridin hem dökümün üstünde tekrarlanıyor. Dart'ta varsayılan metin
  YOK — "Giren"/"Çıkan" koda gömülseydi İngilizcesi de gömülürdü ve
  `dossier_chart.dart` başındaki kural (etiketler veritabanından gelir)
  kırılırdı. Yazılmazsa başlık çizilmez.

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

**Sayı 03'te tersi oldu ve kural doğrulandı.** Tarım Kredi Kooperatifi Ana
Sözleşmesi'nin 8. maddesi ortaklığa girmenin dört adımını tek tek sayıyor:
beyanname → noterden *ya da köy ve mahalle ihtiyar heyetinden* tasdikli
taahhütname → yönetim kurulu kararı → ortaklık payının 1/4'ünün ödenmesi.
Kaynak belgelenmiş olduğu için tür yazıldı. Beklemek doğru karardı: Ziraat'te
yazılsaydı boş dururdu.

---

### 8.13 Kurum rotasyonu

*(Kullanıcı listesi, 29 Ağustos 2026. Pencere 14 gün.)*

| # | kurum | durum |
|---|---|---|
| 1 | Toprak Mahsulleri Ofisi | yayımlandı |
| 2 | Ziraat Bankası | yayımlandı |
| 3 | **Tarım Kredi Kooperatifleri** | yayımlandı 10 Eylül 2026 — §8.14 |
| 4 | **TAGEM ve araştırma enstitüleri** | yayımlandı 29 Eylül 2026 |
| 5 | **DSİ — Devlet Su İşleri** | **sıradaki** |
| 6 | TİGEM | |
| 7 | Türkşeker | |
| 8 | Et ve Süt Kurumu (ESK) | |
| 9 | TZOB / Ziraat Odaları | |
| 10 | TARSİM | |
| 11 | Tarım Satış Kooperatifleri Birlikleri | kaynağı hazır — §8.14 |
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

*(Durumlar 4 Ekim 2026'da canlı `country_dossiers` tablosundan okundu.
Pencereler: TMO 22–29 Ağustos · Ziraat 29 Ağustos–10 Eylül · Tarım Kredi
10–24 Eylül · TAGEM 29 Eylül–13 Ekim 2026. Tarım Kredi ile TAGEM arasında
beş günlük boşluk var — kurum şeridi 24–29 Eylül arası boş kalmış.)*

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

### 8.14 Sayı 03 — Tarım Kredi Kooperatifleri

**Küme: Üretici örgütü** (`#8A5410` kağıt / `#E0A54F` kapak). Dizinin üçüncü
vurgusu, ilk kez kullanılıyor. TMO kırmızı = kamu gücü, Ziraat yeşil = finans,
Tarım Kredi toprak = üretici örgütü — üç sayıda üç kurum türü görünür oldu.
Slug `tarim-kredi`, adres `/kurum/tarim-kredi`.

**Eksen cümlesi:** *Kooperatifin genel kurulu 1935'ten beri karar alıyor;
kararın kesinleşmesi hiçbir dönemde yalnız ona bağlı olmadı. Değişen, onayın
kimde olduğu.* Üç belgenin yan yana okunması:

| | belge | onay kimde |
|---|---|---|
| 1935 | 2836 s. Kanun Md. 25 | Ziraat Bankası |
| 1972 | 1581 s. Kanun Md. 8 | Merkez Birliği (onunki Bakanlıkta) |
| bugün | Kooperatif Ana Sözleşmesi s. 8 | ortağın oyu: bir, vekâletsiz |

İddia değil okuma. Sayı 02 Crédit Agricole'ü **sahiplik** ekseninde
kullanmıştı; bu dosya bir adım ötesini soruyor.

**Sayı 02'nin AÇIK maddesi 2 kapandı.** Ziraat ↔ Tarım Kredi halkası
**1581'in geçici maddelerinde**: Geç. Md. 3 bankanın birlikler kuruluncaya
kadar onların görevlerini yaptığını yazıyor, Geç. Md. 4 banka memurlarını beş
yıllığına birliklere veriyor, Geç. Md. 5 bütçeden 5 yılda 100 milyon lira
ayırıyor. Yani **1972'ye kadar kooperatiflerin üst yapısı bankaydı.**

**Dizi üçüncü kez kendi içine bağlandı.** TMO 1938'de Ziraat'in buğday
masasından ayrıldı, Tarım Kredi 1972'de Ziraat'in vesayetinden. Aynı banka,
iki ayrılık, 34 yıl arayla — ve Sayı 02 o bankanın kendisiydi.

**Görseller — yedi, hepsi atıflı.** §1 Mithat Paşa ve vilayet erkânı (SALT
Research, 1870) · §2 Adana Beynelmilel Ziraat Sergisi (Mayıs 1924) · §3
Ballıkpınar köyü, 1930'lar (DGPI arşivi) · §5 Tekir Ambarı, Silifke (CC0) ·
§9 Harran, Şanlıurfa · §11 Sarıçam'da gübre taşıyan traktör · §12 Bredenbek'te
eski bir Raiffeisenbank binası.

*Ziraat'in Mithat Paşa portresi TEKRARLANMADI.* Sayı 02'de Nadar'ın portresi
var; burada 1870 tarihli SALT karesi seçildi. İki dosya aynı atayı anlatıyor
ama aynı resmi göstermiyor — dizide görsel tekrarı kimliği değil tembelliği
gösterir.

*Altyazı kuralı bu dosyada bir kez daha iş yaptı:* Tekir Ambarı'nın altyazısı
"kurumun kendi kronolojisine göre" kaydını taşıyor, çünkü 1936 tarihi
karantinada (tek kaynak kurumun sayfası). Karantina veri katmanında kalmıyor,
altyazıya kadar iniyor.

**Karşılaştırma kaynağı Almanya** (`gesetze-im-internet.de`, birincil).
Crédit Agricole tekrarlanmadı; eksen bu kez **kararı kim onaylar / hesabı kim
denetler**. GenG 01.05.1889'dan beri yürürlükte (Türkiye'de aynı konu üç kez
baştan yazıldı: 1470/1929 → 2836/1935 → 1581/1972). §43(3) bir ortak bir oy —
ama tüzük 3'e kadar çoklu oy verebiliyor; §53 zorunlu denetim; §54 denetim
birliğine üyelik zorunlu. **İki ülke de üst kuruluşa üyeliği zorunlu tutuyor;
ayrım üst kuruluşun ne yaptığında — biri denetliyor, öteki onaylıyor.**

**Kaynak dengesi Ziraat'in TERSİ.** Orada üç entegre faaliyet raporu vardı,
hukuk yoktu. Burada iki kanunun tam metni ve üç ana sözleşme var, **mali tablo
hiç yok** — kurum faaliyet raporu yayımlamıyor. 219 milyar TL aktif, 18 milyar
TL kâr, 1.598 kooperatif gibi rakamların tek kaynağı bir basın açıklaması, ve
kurumun kendi iki sayfası şirket sayısında çelişiyor (19'a karşı 18).
**Karar: omurga mali değil yapısal.** Bu rakamlar girerse "kurumun ifadesi"
olarak girer; çelişen sayı hiç verilmez.

**Ortak sayısı ile kredili müşteri sayısı toplanmaz.** Tarım Kredi "900 binden
fazla ortak", Ziraat 2025'te "924 bin kredili tarım müşterisi". Yakın rakamlar,
farklı tanımlar, muhtemelen aynı çiftçiler. §2.2.1'in klasik sessiz hatası.

**Anahtar kelime sınandı ve Ziraat'in tersi çıktı.** 927 yayımlanmış haberde
"Tarım Kredi" başlıkta beş kez geçiyor, **beşi de gerçekten kurum**. "tarım
kredisi" tuzağı yok: başlıkta hiç geçmiyor, ayrıca `terim_geciyor` sözcük
sınırı (`\m..\M`) kullandığı için "Kredisi" zaten eşleşmiyor. Gübretaş, KOOP
Market, Tarım Kredi Holding listede YOK — ayrı tüzel kişilik.

**Bilinerek kabul edilen gerilim:** eşleşen haberlerin başlıkları zarar
manşetleri ("Tarım Kredi Market Yılın İlk Yarısında Milyarlık Zarar
Açıkladı"). Tanıtım dosyasının altında günün haberi duracak. Gizlenmiyor:
dosya mekanizmayı anlatır, şerit günün gerçeğini taşır, iki iş ayrıdır
(kullanıcı kararı, 10 Eylül 2026).

#### 8.14.1 AĞ SINIRI KALKTI — dizinin en eski kısıtı

TMO ve Ziraat dosyalarında `mevzuat.gov.tr` ve `resmigazete.gov.tr` bu ağdan
**hiç açılmıyordu** (curl `000`) ve kural oradan doğmuştu: *birincil kaynaktan
doğrulanamayan Resmî Gazete tarih/sayısı METNE YAZILMAZ.* TMO'nun kuruluş
kanununun RG sayısı bu yüzden hiç yazılamadı.

**10 Eylül 2026'da yeniden ölçüldü: ikisi de `200`.**

- `mevzuat.gov.tr/mevzuat?MevzuatNo=..&MevzuatTur=1&MevzuatTertip=..` → künye
- `mevzuat.gov.tr/MevzuatMetin/1.5.<no>.pdf` → yürürlükteki tam metin
- `resmigazete.gov.tr/arsiv/<sayi>.pdf` → **07.02.1921'den beri** taranmış nüsha

**Kural kalkmadı, sınır kalktı.** Künye yine yalnızca çekilmiş belgeden yazılır.
Sayı 03 dizinin RG künyesi taşıyan ilk dosyası: 1581 → RG 28.04.1972 · 14172;
2836 → RG 2 Teşrinisani 1935 · 3146 (kabul 27/10/1935).

**Mülga kanun mevzuat.gov.tr'de YOK.** 2836 için tertip 1–5 ve
`MevzuatMetin/{1..5}.{3,5}.2836.pdf` denendi, hepsi **yumuşak 404** — yani
`200` + "Sayfa Bulunamadı" HTML'i. Durum kodu tek başına yeterli değil,
içerik sınanmalı. Mülga kanuna tek yol RG arşivi ve sayı numarası bilinmiyorsa
aranması gerekiyor: 1935 nüshalarından "Kanun No: 28xx" başlıkları çıkarılıp
aralık daraltıldı, sonra hedef dize için tarandı. Yöntem
`content/dossiers/tarim-kredi/_raw/cek.sh` içinde yazılı.

> **Aynı tuzak kurumun kendi sitesinde de var.** `tarimkredi.org.tr` bilinmeyen
> adreste 404 dönmüyor, **anasayfayı 200 ile** veriyor. `/tr/kurumsal/tarihce`
> böyle "başarılı" göründü ve anasayfaydı. `cek.sh` her dosyayı içeriğe karşı
> sınıyor; sınama HTML **varlıklarını çözmek** zorunda, çünkü site Türkçe
> harfleri `B&ouml;lge Birli&#287;i` diye yazıyor ve ham metinde aranan ifade
> hiç geçmiyor.

**Yan kazanç — Sayı 11 hazır.** RG 3146'nın içindekiler listesi: *2834 Tarım
Satış Kooperatifleri ve Birlikleri Hakkında Kanun* (s. 2), *2836 Tarım Kredi
Kooperatifleri Kanunu* (s. 4). İki kooperatif düzeni aynı gün, aynı gazetede
kuruldu.

**Hâlâ açık:** Ziraat'in 3202 sayılı Kanunu (1937) bulunamadı — mülga.
`MevzuatNo=3202&Tertip=5` **başka bir kanunu** veriyor: Köy Hizmetleri Genel
Müdürlüğü Teşkilat ve Görevleri Hakkında Kanun, RG 22.05.1985 · 18761.
Rotasyonun 13. sırası için kaynak; Ziraat'in açık maddesi için değil.

#### 8.14.2 Beşinci sessiz hata: aynı gazetede iki kanun, aynı açılış cümlesi

§8.10 dört sessiz hata yazmıştı. Beşincisi Sayı 03'te çıktı ve dizinin en
tehlikelisi olabilir, çünkü **yanlış sonuç tamamen makul görünüyor.**

RG 3146 iki kanun taşıyor — 2834 (Tarım Satış) ve 2836 (Tarım Kredi) — madde
numaraları aynı aralıkta **ve ikisi de aynı cümleyle açılıyor:** *"Bu kanunda
yazılı hükümlerden faydalanmak üzere..."* Ayrım devamında: 2834 "en az on
çiftçi aralarında değişir kapitalli", 2836 "çiftçiler aralarında buçsuz ve
zincirleme soravlı".

İki kez hata yaptırdı. `'Madde 25 —'` araması nüsha başından yapılınca 2834'ün
25. maddesini buldu. Sonra `dogrula_veri.py` gövdeyi kısa bir çapayla kesti ve
çapa 2834'ün 1. maddesine oturdu — doğrulayıcı bütün 2836 alıntılarını yanlış
kanunda aramaya başladı.

**İkinci hatayı yakalayan şey doğrulayıcının BAĞIMSIZ yazılmış olmasıydı.**
Ortak yardımcı paylaşılsaydı ikisi de aynı yönde yanılırdı. *Kural: doğrulayıcı
üreticiden fonksiyon içe aktarmaz — normalleştirmeyi de, dilimlemeyi de baştan
yazar.*

**Genel kural:** birden çok belge taşıyan bir kaynakta (Resmî Gazete nüshası,
toplu mevzuat PDF'i, birleşik faaliyet raporu) arama **belgenin gövdesine
kesilerek** yapılır; çapa o belgeye ÖZGÜ bir ibare olmalı ve dilimin komşu
belgenin ayırt edici ibaresini taşımadığı ayrıca sınanmalı. Alıntının
bulunması yetmez: **madde numarasının da o gövdede bulunduğu** sınanır.

**Künye eşlemesi de çakışabiliyor.** "1581 sayılı Kanun" hem kanun metnine hem
`mevzuat.gov.tr` künye sayfasının adına uyuyordu; alıntı yanlış dosyada
arandı. Doğrulayıcı artık bir künye birden çok kaynağa uyarsa **hata veriyor**,
sözlük sırasına bırakmıyor.

**Altıncı tuzak: kelime ortasına giren BOŞLUK — işaretsiz.** PDF çıkarıcı
kelimeyi ikiye bölüp arada hiçbir karakter bırakmıyor: `'kurulmas ına'`,
`'dest ekleme'`, `'ç alışma alanı'`. Yumuşak tirenin aksine silinecek bir şey
yok; boşluk metnin normal parçası, toptan silinemez. Çözüm iki aşamalı — önce
tam eşleşme, başarısız olursa **bütün boşluklar atılıp harf dizisi** (yalnızca
40+ karakterlik alıntılarda). Gevşek olduğu için **sessizce geçmiyor**: hangi
kalemlerin toleransla doğrulandığı üretimde ve doğrulamada tek tek yazdırılıyor.

**`dogrula_metin.py`'ye üçüncü bir avcı eklendi: REKLAM DİLİ.** §8.2 kurumun
tanıtım dilinin alıntılanmamasını istiyordu ama bunu sınayan bir şey yoktu.
Artık "en büyük çiftçi kuruluşu", "tarımsal sanayinin lideri/lokomotifi",
"öncü rol" kalıpları **tırnaksız** kullanıldığında hata veriyor — alıntı içinde
serbest, kendi cümlemiz olarak yasak.

**Türetilmiş sayı YAZIYLA yazılır.** "otuz yedi yıl", "doksan yılda", "kırk
yılın" — bunlar iki tarihin farkı ve veri katmanında kalem olarak durmuyorlar.
Rakamla yazılsalardı ya havuza sahte kalem eklemek ya da denetimi gevşetmek
gerekirdi; üçüncü yol yazıyla yazmak. Aynı kural İngilizce metinde de geçerli.

**Noktalı tarih havuza yıl olarak girmiyor.** `"01.05.1889"` dizesinden nokta
silinerek **1051889** üretiliyor, 1889 üretilmiyor. Metinde yıl yazılacaksa
veri katmanında **yıl olarak da** bulunmalı (`almanya.kanun_yili`). Havuz artık
dizelerdeki 4 haneli yılları ayrıca topluyor, ama kalemi yıl alanı olarak
koymak yine de doğru olan.

**1935 taramasının kendi tuzakları** (§8.10'un 2. maddesinin devamı):
yumuşak tire U+00AD (124 tane, hepsi satır sonunda), OCR'ın sert tireli
bölmesi (`koo- peratifleri` — kural dar tutulmalı, `a - En az` liste imi
bozulmasın), sütun ayırıcısının metne `j`/`I` diye karışması, ve **madde
numarasının yanlış okunması**: 2836'nın 13. maddesi taramada "Madde 43"
çıkıyor. Numaraya değil sıraya bakılır.

#### 8.14.3 Önizlemenin yakaladığı iki çizim hatası (10 Eylül 2026)

Sürüm derlemesi alınıp `--dart-define=DOSYA_ONIZLEME=tarim-kredi` ile yerelde
açıldı. İkisi de testten değil GÖZDEN çıktı; ikisi de artık testli.

**1. Türkçe büyük harf.** Dart'ın `toUpperCase()`'i değişmez kültür kullanıyor
ve noktalı i'yi bilmiyor: işlem akışının aktör etiketi **"ÜRETICI"**, §12
tablosunun başlığı **"TÜRKIYE"** çıkıyordu. Yeni yardımcı
`lib/core/utils/turkce_metin.dart` → `buyukHarf(metin, isEn)`.

*Dil şartı ihmal edilemez:* kuralı İngilizceye uygulamak ters yönde bozuyor —
`"Institution"` → `"INSTİTUTİON"`. Bu yüzden bayraksız kısayol bilerek yok.
Üç çağrı yeri düzeltildi (kart künyesi, akış aktörü, tablo başlığı). Uygulamada
düz `toUpperCase()` kullanan **14 yer daha var**, dokunulmadı.

**2. Bölüm görseli kutusu sabit 4:3'tü ve dikey kareyi kırpıyordu.** Bredenbek
karesi 1440×2222 ve kutuda yalnızca bir şeridi görünüyordu (kullanıcı yakaladı).

Sabit oranın bir gerekçesi vardı ve koda yazılıydı: kare uydu görselleri 720 px
olukta ekranın tamamını yiyip metni aşağı itiyordu. Ama o gerekçe **alt sınır**
ister, sabit oran değil. Yeni hâli:

- Oran görselin KENDİSİNDEN geliyor — `gorsel.en_boy`, indirilen dosyadan
  ölçülüp `kunye.json` → `yayin.json` → seed → modele akıyor.
- Çizici iki uçtan sıkıştırıyor: **en dikey 3:4, en yatay 16:9.**
- `en_boy` VARSA `BoxFit.cover` değil **`contain` + ortalama**: kutu görselin
  oranını aldığı için ikisi çoğunlukla aynı; fark sıkıştırmanın devreye
  girdiği uçta ve orada kırpmak değil tamamını göstermek doğru.
- `en_boy` YOKSA 4:3 kutu **+ `cover`** — yani eski davranışın tamamı.

**Son madde 11 Eylül 2026'da üretimde kırıldı ve sebebi bu belgede yazılı bir
VARSAYIMDI.** Yukarıdaki madde eskiden şöyleydi: *"`en_boy` yoksa eski varsayım
(4:3) sürüyor — Hollanda, TMO, Ziraat ve Rusya dosyalarında alan bulunmuyor ve
hepsinin görselleri yatay."* Son cümle hiç ölçülmemişti ve yanlıştı: Rusya
dosyasının çernozyom moniliti **802×3008** (1:3,75), yani dizinin en dikey
görseli. Kutu 4:3 varsayıyor, çizim `contain` yapıyordu; sonuç ortada ince bir
şeritti. Kullanıcı yakaladı.

```
kutu 4:3 (1,333)  ·  görsel 1:3,75 (0,267)  ·  ayrışma 5 kat
contain → görselin genişliği kutunun %7'si = şerit
cover   → kutu dolu, toprak kesiti görünüyor  ✓
```

Kural netleşti: **oranını BİLDİĞİMİZ görselin tamamını göster, BİLMEDİĞİMİZ
görselde kutuyu doldur.** `en_boy` böylece bir opsiyon değil bir taahhüt —
yazan kişi "bu görsel bütün olarak görünmeli" diyor. Beyan yoksa kırpmak,
şeride dönmekten iyidir.

Regresyon testi eklendi (`dossier_screen_test.dart`): sayfa gerçekten çizilip
iki görselin `BoxFit` değeri okunuyor. İfadeyi aynalayan bir birim testi bunu
yakalayamazdı — kırılma ifadenin kendisinde değil, ifadeyle kutunun
ayrışmasındaydı. Test, düzeltme geri alınarak sınandı: düşüyor.

*İki ders. Birincisi: dosya sayfası yalnızca metin ve rakamla değil, GÖRSELİN
BİÇİMİYLE de sınanmalı. İkincisi ve daha pahalısı: bu belgeye yazılan
"hepsinin görselleri yatay" gibi bir cümle ÖLÇÜM DEĞİLSE, sonraki kararların
altına konmuş sessiz bir mayındır. Ölçülmemiş varsayım belgeye girerse
'ölçülmedi' diye işaretlenir.*

#### 8.14.4 Devir uygulandı — ve takvim ifadesi bir kez düştü

**10 Eylül 2026.** Ziraat'in penceresi 12 Eylül yerine bugün kapatıldı,
Tarım Kredi açıldı (kullanıcı kararı). Sıra: paylaşım kartı → `deploy.sh
--hosting` → görsel/kart/rota doğrulaması → `supabase db push` → hikâyeler.
Ülke dizisine dokunulmadı; Rusya 26 Eylül'e kadar sürüyor.

**Migration ilk denemede düştü ve sebebi önceki devirdi.** 29 Ağustos'taki
devir takvim satırını emekliye ayırırken `sira = 90 + sira` yazmıştı. O ifade
dizi başına **yalnızca bir kez** çalışıyor: Ziraat o gün 1'den 91'e taşındı,
bugün Tarım Kredi de 91'i istedi ve

```
ERROR: duplicate key value violates unique constraint
       "dossier_takvim_tur_sira_key"  Key (tur, sira)=(kurum, 91) already exists
```

Migration tek işlem olduğu için **hiçbir şey uygulanmadı** — kontrol edildi,
Ziraat hâlâ published, Tarım Kredi yok. Atomikliğin karşılığı burada görüldü.

Düzeltme, hedef sırayı hesaplıyor:

```sql
sira = 1 + coalesce((select max(x.sira) from public.dossier_takvim x
                      where x.tur = t.tur and x.sira >= 90), 89)
```

*Kural: devir migration'ında sabit sıra sayısı yazılmaz. Her devir bir öncekinin
bıraktığı durumun üstüne geliyor; "90 + sira" gibi ifadeler ikinci turda
çakışır. Bir sonraki devir bu ifadeyi olduğu gibi kopyalayabilir.*

**Sağlama bloğu işini yaptı:** sekiz `raise exception` — aktif dosya sayısı,
kurum aktifi, **ülke aktifinin değişmemiş olması**, Ziraat'in published
olmayıp archived olması, takvimde TAGEM, ve yedi bölüm görseli. Hepsi geçti.

**Yayın sonrası ölçüm:** 13 bölüm · 7 görsel (hepsi `tarimportali.net`) ·
dört bölüm türü de mevcut · `dosya_haberleri` yedi haber döndürüyor ·
hikâye baloncuğu 24 Eylül'e kadar · kapak başlığı canlıda ilk karede doğru.

#### 8.14.5 Pencere rozeti — görünümdeki hesap kodda yoktu

Kapaktaki **"13 bölüm · 14 gün kaldı"** rozeti canlıda hiç çizilmiyordu.
Sebep: `days_remaining` ve `section_count` **tabloda sütun değil**;
`active_country_dossier` ve `country_dossier_index` görünümleri hesaplıyor.
Dosya sayfası ise ham tabloyu okuyor (`fetchBySlug`), iki alan null geliyordu.

**Görünüme geçilmedi**, hesap Dart'a taşındı — çünkü `active_country_dossier`
yalnızca AKTİF dosyaları veriyor ve `fetchBySlug` arşivdekileri de açıyor.
Görünüme geçilseydi TMO, Hollanda ve Ziraat sayfaları hiç açılmazdı.

`kalanGun()` (country_dossier.dart) görünümdeki ifadenin **birebir**
karşılığı:

```
greatest(0, ceil(extract(epoch from (ends_at - now())) / 86400))
```

*Yaklaşık değil birebir olmak zorunda:* aynı dosya ana sayfada görünümden,
kapağında bu koddan besleniyor. Formüller ayrışsaydı aynı dosya iki yerde
farklı gün gösterirdi ve bunu kimse fark etmezdi. Yayın sonrası ölçüldü —
Tarım Kredi 14/14, Rusya 16/16.

İki tuzak testle sabitlendi: **yukarı yuvarlama** (13 gün 1 saat → 14; aşağı
yuvarlansa okur iki gün üst üste "13 gün" görürdü) ve **saat dilimi**
(`ends_at` ofsetli geliyor; iki taraf UTC'ye çevrilmezse gün kayar).

Arşivdeki dosyada gün yazılmıyor: rozet `daysRemaining > 0` şartı arıyor,
"0 gün kaldı" demiyor.

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

## 19. SEO — gövde metni sunucudan gidiyor (6 Eylül 2026)

### 19.1 Sorun: CanvasKit arama motoruna hiçbir şey göstermiyordu

Ölçüldü, canlı sitede: bir haber sayfası TAM YÜKLENDİĞİNDE
`document.body.innerText.length` = **0**, `<a>` = **0**, `<h1>` = **0**.

Sebep motorun kendisi: CanvasKit metni DOM'a değil **tuvale piksel olarak**
çiziyor. Flutter 3.41'de HTML motoru tamamen kaldırıldığı için bu bir ayar
meselesi değil. Erişilebilirlik katmanı (`semantics`) metni gizli bir DOM'a
yazabilirdi ama varsayılan kapalı ve hiçbir yerde açılmamıştı.

Sonuç: Google yalnızca `<head>`'i okuyabiliyordu — haber başına ~250 karakter,
oysa haberler 2.000–8.000 karakter. Ayrıca **hiç link olmadığı için** tarayıcı
siteye girip hiçbir yere gidemiyordu.

### 19.2 Çözüm: işaretler arasına sunucudan HTML

`web/index.html` gövdesinde bir işaret çifti var:

```html
<!-- SSR_CONTENT_START --><!-- SSR_CONTENT_END -->
```

Arası iki yoldan doluyor:

- **Haber sayfaları** — `ogRenderer` (`functions/index.js`). Haberin gövdesini
  zaten Supabase'den çekiyordu ve yalnızca 160 karakterlik açıklamayı üretip
  gerisini atıyordu; artık tam metni `<article>` olarak yazıyor.
- **Ana sayfa ve diğer statik rotalar** — `scripts/ana_sayfa_linkleri.py`,
  DERLEME ANINDA. Son 60 haberin başlık+link listesini gömüyor.

**`homeRenderer` fonksiyonu yazıldı, yayında, ama KULLANILMIYOR.** Sebep:
Firebase Hosting statik dosyaları yönlendirmelerden ÖNCE sunuyor; kökte bir
`index.html` durduğu sürece `"source": "/"` rewrite'ı hiç devreye girmiyor
(aynı davranış §2.5'te dosya sayfaları için de not edilmiş). Denendi ve
doğrulandı; `firebase.json`'daki rewrite geri alındı. Fonksiyon duruyor —
ileride kökteki dosya adı değişirse hazır.

Derleme anında gömmenin fonksiyonla elde edilemeyecek bir yan faydası var:
`**` yakalayıcısı TÜM rotaları aynı `index.html` ile sunduğu için link listesi
`/piyasalar`, `/yazarlar` ve kategori sayfalarında da bulunuyor.

### 19.3 Kullanıcı bunu görmüyor

Üstünde `z-index: 2147483647` ile tam ekran `#splash` var ve Flutter ilk
kareyi çizer çizmez `hide()` bloğu `#ssr-content` düğümünü DOM'dan siliyor —
`#splash`ten ÖNCE, çünkü oradaki erken `return` bu satırı atlatabilirdi.

Silme şart: bırakılırsa ekran okuyucu aynı haberi iki kez okur ve klavyeyle
gezinen kullanıcı görünmeyen bağlantılara takılır.

**Gizleme (cloaking) değil:** sunulan metin ile uygulamanın gösterdiği metin
birebir aynı, yalnızca biri ötekinin üstünü örtüyor.

### 19.4 Temizlik pazarlık konusu değil

Gövde artık SUNUCUDAN, kabuğun içine gömülü gidiyor. Oraya sızacak bir
`<script>` sitenin kendi kökeninde çalışırdı. `sanitizeHtml` script/iframe/
object/embed/form bloklarını, `on*` olay özniteliklerini ve
`javascript:`/`data:` bağlantılarını siliyor. Dokuz saldırı vektörüne karşı
sınandı; `<p>Bakan "şöyle dedi"</p>` gibi meşru içerik korunuyor.

### 19.5 `deploy.sh` iki koruma taşıyor

Kabukta `SOCIAL_META_START` **veya** `SSR_CONTENT_START` yoksa dağıtım durur.
İkincisi olmadan site arama motorlarına sessizce yeniden görünmez olurdu —
hiçbir hata vermeden.

### 19.6 Ölçüm (öncesi → sonrası)

| | önce | sonra |
|---|---|---|
| Ana sayfa metni | 0 | 3.401 karakter |
| Ana sayfa linki | 0 | 60 |
| Haber metni | 0 | 1.650 karakter |
| Haber linki | 0 | 11 |
| Sitemap'te eski alan adı | 793 | 0 |

### 19.7 İngilizce içeriğin kendi adresi var

`/en/haber/<id>`. 771 haberin çevirisi veritabanında hazırdı ama dil yalnızca
istemci durumu olduğu için hiçbir adresi yoktu ve Google hiç göremiyordu.

- `ogRenderer` aynı fonksiyon içinde iki dili birden karşılıyor; ayrımı
  `req.path` üzerindeki `/^\/en(\/|$)/` yapıyor. Desen `/enerji/...` gibi
  adreslere YANLIŞ eşleşmiyor — sınandı.
- Çeviri eksikse Türkçeye düşülüyor: yarım çevrilmiş bir sayfa, hiç açılmayan
  bir adresten iyi. Çeviri hattı başarısızlıkta bu alanları NULL bıraktığı
  için (`tarim_ai_pipeline/translator.py`) bu yedek gerçekten devreye
  girebiliyor.
- `hreflang` KARŞILIKLI olmak zorunda: tek yönlü bildirim Google tarafından
  sessizce yok sayılıyor. `x-default` Türkçeye gidiyor.
- Sitemap her habere İKİ giriş yazıyor. Yalnızca `xhtml:link` ile bildirmek
  yetmiyor; alternatif taranır ama bağımsız bir giriş sayılmaz ve indeksleme
  gecikir. `xmlns:xhtml` ad alanı ZORUNLU — tanımsız önek sitemap'in tamamını
  geçersiz kılar.

**Flutter tarafı:** `/en/haber/:id` rotası `Localizations.override` ile alt
ağacı İngilizceye sabitliyor. Global `localeProvider`'a DOKUNULMUYOR — bir
rotanın çizim sırasında provider yazması Riverpod'da hatalı olurdu ve
okuyucunun dil tercihi tek bir bağlantıyla kalıcı olarak değişirdi.

### 19.8 Kategori sayfaları açıldı

`robots.txt`teki `Disallow: /kategori/` kaldırıldı. Oradaki gerekçe
("adresten yeniden kurulamıyor") eskimişti; `categoryBySlug` slug'ı çözüyor.

Ama engeli kaldırmak TEK BAŞINA yanlış olurdu: altı kategori `**`
yakalayıcısıyla aynı `index.html`i alıyordu, yani Google'a altı yinelenen
sayfa görünürdü. `categoryRenderer` her kategoriye kendi başlığını,
açıklamasını ve kendi haber listesini veriyor.

**Süzgeçler istemcidekiyle birebir olmak zorunda** (`home_providers.dart`:
`_articleIsTurkey`, `_articleIsWorld`, `_articleIsScience`,
`categoryArticlesProvider`). Ayrışırlarsa kategori sayfası arama sonucunda
uygulamadakinden başka haberler vaat eder.

### 19.9 IndexNow — yeni haber dakikalar içinde

`indexNowPing`, her 30 dakikada son 45 dakikanın haberlerini Bing/Yandex/
Seznam'a bildiriyor. Örtüşme bilerek: bir çalıştırma hata alırsa haber
kaybolmasın. Aynı adresin bazen iki kez gitmesi IndexNow'da hata değil.

Anahtar `functions/config.js` → `INDEXNOW_KEY`, doğrulama dosyası
`web/<anahtar>.txt`. **Anahtar değişirse dosyanın adı da değişmek zorunda,**
yoksa bütün gönderimler sessizce reddedilir. Kurulum canlıda sınandı: HTTP 202.

**Google IndexNow'a katılmıyor.** Oraya sitemap'teki `lastmod` üzerinden haber
gidiyor; bu fonksiyon Google'ı etkilemiyor.

### 19.10 Açılış hızı — ölçüldü, çoğu zaten iyiydi

- Zorunlu açılış ekranı 3.000 ms → 400/700/1.500 ms. (Kaynakta zaten
  düzeltilmişti, canlıdaki 3 saniye yayınlanmamış eski sürümdendi.)
- Brotli tüm varlıklarda AÇIK: `canvaskit.wasm` 7 MB → 2,2 MB.
- **CanvasKit yerelden yüklenmiyor.** Ağ istekleri ölçüldü: dosyalar
  `www.gstatic.com/flutter-canvaskit/<engineRevision>/chromium/` adresinden,
  yani SÜRÜMLÜ ve kalıcı önbelleklenen bir Google CDN'inden geliyor.
  `build/web/canvaskit/` altındaki ~20 MB hiç istenmiyor; yalnızca yedek.
  Oradaki `Cache-Control` başlığını uzatmanın bir karşılığı YOK — bu bir kez
  denendi ve ölçümle elendi.
- `main.dart.js` için `no-cache` DOĞRU: dosya adı içerik özetiyle
  damgalanmıyor, önbelleklenirse dağıtımdan sonra eski uygulama servis edilir.

Ölçüm (masaüstü, sıcak önbellek): TTFB 147 ms, domInteractive 234 ms.

### 19.11 Kapanış ölçümü (6 Eylül 2026)

| sayfa | metin | link |
|---|---|---|
| Ana sayfa | 3.401 | 60 |
| Haber (TR) | 1.774 | 18 |
| Haber (EN) | 1.916 | 18 |
| Kategori | 3.645 | 77 |

Sitemap 793 → **1.575 adres**. Denetimdeki her ölçüm sıfırdan çıktı.

### 19.12 Kalan (manuel — hesap erişimi gerekiyor)

- **Google Search Console** — alan adı doğrulaması + sitemap gönderimi.
- **Bing Webmaster Tools** — IndexNow zaten çalışıyor ama panel raporlama için.
- **Google Publisher Center** — Google Haberler ve Discover'ın ön koşulu.

Bunlar kod işi değil; kullanıcının kendi Google/Bing hesabından yapılmalı.

## 20. Yayın öncesi kapasite denetimi — 6 Eylül 2026

### 20.1 Liste sorgusu ziyaretçi başına 2,7 MB indiriyordu

`watchLatestArticles()` `select('*')` yapıyordu ve **limiti yoktu**. Ölçüldü:

    2,74 MB (gzip) · 6,4 MB açılmış · 771 kayıt · 41 sütun · 2,6 saniye

Bunu her ziyaretçi, HER açılışta indiriyordu. Asıl tehlike rakam değil
**bileşik büyüme**: arşiv günde ~32 haber alıyor (30 günde 738 ölçüldü). Üç ay
sonra ziyaretçi başına ~13 MB, bir yıl sonra ~44 MB olacaktı — maliyetten önce
ana sayfa mobil bağlantıda açılamaz hale gelirdi.

**Çözüm iki parçalı** (`home_repository.dart`):

- `_listeSutunlari` — sekiz ağır sütun dışarıda: `content`, `content_en`,
  `chart_data`, `chart_data_en`, `key_takeaways`, `key_takeaways_en`,
  `expert_insight`, `expert_insight_en`. Bunlar kayıt başına 7.795 baytın
  6.215'iydi (%80) ve hiçbiri KART çiziminde kullanılmıyor.
- `_listeSiniri = 500` — sütun daraltma yükü düşürüyor ama büyümeyi
  durdurmuyor; sınırsız sorgu arşivle birlikte sonsuza kadar şişer.

Ölçülen sonuç: **2,62 MB → 0,22 MB (%91,5 azalma, 11,8 kat), 2,99 sn → 0,45 sn.**

### 20.2 Detay ekranı artık listeden gelen nesneye güvenmiyor

Bu, daraltmanın en tehlikeli yan etkisiydi. Rotalar
(`/haber/:id`, `/en/haber/:id`) `_resolveExtra` ile listeden gelen
`NewsArticle`'ı doğrudan kullanıyordu. Gövde artık o nesnede olmadığı için her
haber **BOŞ METİNLE** çizilirdi — üstelik sessizce, hiçbir hata vermeden.

Rotalar artık gövdeyi sınıyor; boşsa `_ArticleLoader` devreye girip tam kaydı
`fetchArticleById` ile çekiyor. Canlıda doğrulandı — ağ izinde iki ayrı sorgu
görünüyor:

    ana sayfa  articles?select=id,title,…            1.312 ms
    haber      articles?select=*&id=eq.<uuid>          539 ms

### 20.3 Kabul edilen iki bedel

- **Kategori listelerinde en yeni 500 haber var.** Arama motoru tarafı
  etkilenmiyor: sitemap tüm arşivi taşıyor, `categoryRenderer` kendi sorgusunu
  sunucuda yapıyor (§19). Arşivin tamamında gezinme gerektiğinde doğru çözüm
  sınırı büyütmek DEĞİL, kategori ekranına kendi sayfalanmış sorgusunu vermek.
- **Çevrimdışı tam metin okuma düştü.** Hive önbelleği artık gövde taşımıyor;
  liste çevrimdışı görünüyor ama haber açmak ağ istiyor. Alternatif her
  cihazda 6,4 MB tutmaktı.

### 20.4 Temiz çıkanlar (sınandı, sorun yok)

- **Anon YAZAMIYOR.** İlk ölçüm `204` döndürüp yanıltıcı göründü; RLS'in
  UPDATE/DELETE'i hata yerine SATIR SÜZEREK engellediği ayrıca doğrulandı
  (alanın kendi değeriyle güncellenmesi denendi, `[]` döndü).
- **`service_role` sızmamış.** İstemci paketinde yalnızca `anon` anahtarı var.
- **CDN önbelleği çalışıyor** — `x-cache: HIT`, 133 ms.
- **Ziyaretçi başına kalıcı bağlantı yok.** `watchLatestArticles` Realtime
  değil, `.asStream()` ile tek seferlik sorgu; eşzamanlılık limiti devreye
  girmiyor.

### 20.5 `agent_logs` kapatıldı

678 kayıt anon anahtarıyla dışarıdan okunabiliyordu; içinde
`raw_ai_output`, yani ajanların ham editoryal önerileri vardı. Sır yok ama
içeriğin NASIL YAPILDIĞINI açık ediyordu — §2.10 ve §8.2 ile doğrudan
çelişiyor. Migration `20260906040000_agent_logs_gizle.sql`; tabloyu okuyan
hiçbir istemci olmadığı doğrulandıktan sonra uygulandı.

### 20.6 Gemini anahtarı istemciden çıkarıldı

`api_constants.dart` içinde canlı bir Gemini anahtarı varsayılan olarak
yazılıydı ve `main.dart.js` ile herkese iniyordu. Anahtar zaten geçersizdi
(Google `API key not valid` dönüyor), yani fatura oluşmamıştı — ama kalıp
tehlikeliydi. Varsayılan boşaltıldı.

**Kural: istemcide API anahtarı gizlenemez.** `--dart-define` de çözüm değil —
değer yine derlenmiş pakete gömülüyor. Bu sabiti kullanan tek yer
`updateSuggestionStatus` (panelde "öneriyi onayla → makale üret"); o çağrının
yeri sunucu. Taşınana kadar özellik anahtarsız duruyor.

### 20.7 AÇIK — `push_tokens` hâlâ dışarıdan okunabiliyor

17 cihaz jetonu, dil ve platform bilgisi anon anahtarıyla okunuyor. Jetonla
bildirim GÖNDERİLEMEZ (FCM sunucu kimliği ayrı ve güvende), ama veri
kullanıcıya ait ve gizlilik metnimizle çelişiyor.

**Neden kapatılmadı:** Cloud Function'lar (`morningBriefing`, `weeklyBriefing`,
`authorBulletin`, `breakingNewsCheck`) bu tabloyu ANON anahtarıyla okuyor
(`index.js` → `supabaseGet`). Politikayı kaldırmak bütün bildirimleri kırardı.

**Doğru çözüm:** `service_role` anahtarını Google Secret Manager'a koyup
fonksiyonların `push_tokens` okumasını ona geçirmek, sonra anon `SELECT`'i
kaldırmak. Anahtar `~/tarim_ai_pipeline/.env` içinde `SUPABASE_KEY` adıyla
duruyor (rolü doğrulandı: `service_role`). Kullanıcı kararıyla ertelendi.

### 20.8 AÇIK — bütçe uyarısı ve hata izleme yok

Şu anda bir fonksiyon hata vermeye başlasa ya da Supabase yanıt vermese kimse
öğrenmiyor. Google Cloud ve Supabase için harcama eşiği de tanımlı değil.
İkisi de hesap erişimi gerektiriyor, kod işi değil.

### 20.9 Bilinen kırık test (bu çalışmadan ÖNCE de kırıktı)

`test/author_article_detail_test.dart` geçmiyor. İki gerçek kusuru düzeltildi
(beklenti düz `toUpperCase()` kullanıyordu, ekran `toTurkishUpperCase()`
kullanıyor; ve test dili sabitlenmemişti, ortam diline göre sonuç
değiştiriyordu). Üçüncü ve daha derin bir neden kaldı: ekran test ortamında
hiç içerik çizmiyor, yazar adı bile bulunamıyor — muhtemelen sağlayıcı
sahtelemesi gerekiyor. Kapasite çalışmasıyla ilgisi yok.

`test/widget_test.dart` de kırık: test bağlaması tüm HTTP'yi 400 döndürüyor ve
hava durumu çağrısı bilerek hata fırlatıyor (§17.1).

## 21. Lighthouse denetimi — 6 Eylül 2026

Skorlar: **Performans 74 · Erişilebilirlik 93 · En İyi Uygulamalar 81 · SEO 100.**

### 21.1 SEO 100 — §19/§20 çalışması doğrulandı

Ölçüm, SSR ve veri yükü düzeltmelerinden SONRA alındı (rapor 09:58, deploy
~04:00). Yani bu skorlar düzeltilmiş halin.

### 21.2 Performans metrikleri: biri hariç hepsi mükemmel

    FCP  0,4 sn  ✓        LCP  0,8 sn  ✓ (eşik 2,5)
    CLS  0,029   ✓        TBT  430 ms  ✗ (eşik 200)
    Speed Index 2,9 sn

**LCP'nin 0,8 saniye çıkması SSR'ın yan faydası:** sayfa artık Flutter'ı
beklemeden gerçek metin boyuyor. SEO için yapılan iş performansı da düzeltti.

Skoru düşüren tek şey TBT — Flutter/CanvasKit'in ana iş parçacığını meşgul
etmesi (JS yürütme 3,2 sn, ana iş parçacığı 3,5 sn, 9 uzun görev). Bu motorun
doğasında; Flutter'da kalındığı sürece kökten çözümü yok.

### 21.3 Yakınlaştırma engeli kaldırıldı

`web/index.html` viewport'unda `maximum-scale=1.0, user-scalable=no` vardı ve
parmakla büyütmeyi tamamen yasaklıyordu. Bu, okurlardan gelen "metinler
okunamayacak kadar küçük" şikayetiyle doğrudan çelişiyordu: puntoları
büyütürken kullanıcının kendi çözümünü elinden alıyorduk.

**Grep tuzağı:** düzeltmeyi doğrularken `grep 'user-scalable=no'` YANLIŞ
pozitif verdi — eklenen açıklama yorumu o metni içeriyor. Doğrulama meta
etiketinin kendisine bakarak yapılmalı.

### 21.4 Güvenlik başlıkları eklendi

`firebase.json`'a `**` kuralı olarak: güçlendirilmiş HSTS
(`max-age=63072000; includeSubDomains; preload`), `X-Content-Type-Options`,
`X-Frame-Options: SAMEORIGIN`, `Cross-Origin-Opener-Policy: same-origin`,
`Referrer-Policy`. Fonksiyon rotalarında da geçerli olduğu doğrulandı.

COOP güvenle eklenebildi çünkü giriş **parola tabanlı**
(`signInWithPassword`) — popup akışı olsaydı `same-origin` onu kırardı.

### 21.5 CSP BİLEREK EKLENMEDİ

Lighthouse CSP istiyor ama uygulama on ikiden fazla dış kökene bağlanıyor:
Open-Meteo (üç ayrı alan adı), Nominatim, Yahoo Finance, er-api, YouTube
küçük görselleri, Unsplash, Google Translate, gstatic, Supabase ve iki CORS
proxy'si (`allorigins`, `codetabs`).

Eksik tek bir `connect-src` girdisi o özelliği **sessizce** kırar — hava
durumu ya da piyasa kartı hiçbir hata vermeden boş kalır. Trafik almadan önce
bu kumar oynanmadı. Doğru yol `Content-Security-Policy-Report-Only` ile
başlayıp ihlalleri toplamak, sonra zorunlu kılmak.

### 21.6 Görseller — asıl sorun dosya sayfalarında

Ana sayfanın kritik yolu temiz (~200 KB). Ama `web/dosya/` altında **25,2 MB
/ 69 dosya** var ve tekil görseller 0,8–1,9 MB (`kokboya.jpg` 1,9 MB). Bir
dosya sayfası yedi görsel taşıyor (§8.3) — yani birkaç MB'lık sayfa demek.

Lighthouse bu raporu ANA SAYFA için aldı, o yüzden bu maddeyi görmedi. Dosya
sayfaları ayrıca ölçülmeli; çözüm görselleri yayın öncesi yeniden boyutlandırıp
WebP'ye çevirmek (`paylasim_karti.mjs` ile aynı hatta eklenebilir).

### 21.7 Kalan

- **TBT 430 ms** — Flutter'ın doğası, kökten çözümü yok.
- **Kullanılmayan JS 675 KiB** — aynı gerekçe.
- **bfcache reddi (1 neden)** — kodda `unload`/`beforeunload` dinleyicisi YOK;
  neden büyük olasılıkla service worker. Araştırılmadı.
- **CSP** — §21.5, report-only ile başlanmalı.
- **Dosya sayfası görselleri** — §21.6.

## 22. Ağ yükü — Lighthouse dökümü (6 Eylül 2026)

Ana sayfa toplam ~5,4 MB. Dağılım ve ne yapıldığı:

| kaynak | boyut | durum |
|---|---|---|
| `canvaskit.wasm` (gstatic) | 1.592 KB | Google'ın SÜRÜMLÜ CDN'i, kalıcı önbellekli — dokunulmadı |
| `main.dart.js` | 1.171 KB | Flutter'ın doğası — dokunulmadı |
| dosya görselleri ×2 | 1.251 KB | **→ 516 KB** (§22.1) |
| Google Fonts ×3 | 682 KB | AÇIK (§22.3) |
| Supabase görselleri | 476 KB | AÇIK (§22.4) |
| `articles` sorgusu | 229 KB | §20'de düzeltilmişti ✓ |

### 22.1 Dosya görselleri ana sayfayı da yüklüyordu

Sürpriz buydu: `web/dosya/` görselleri yalnızca dosya sayfalarında değil ANA
SAYFADA da iniyor — `hikaye/slaytlar[].gorsel` üzerinden hikâye baloncuğuna
bağlanıyorlar (§12). Kapalı baloncuk onları ~64 pikselde gösterirken 600+ KB
indiriliyordu.

`scripts/dosya_gorsel_optimize.py` yazıldı: 1440 px (okuma oluğunun 2 katı,
§4), JPEG kalite 78, `optimize` + `progressive`.

**Sonuç: 20,1 MB → 9,8 MB (%51).** Ana sayfadaki iki görsel 647→261 KB ve
604→255 KB.

**Format JPEG kaldı.** WebP denendi, bu görsellerde JPEG'e üstünlük sağlamadı
(1440 px'te 233 KB'a karşı 261 KB) ama uzantı değişikliği `yayin.json`,
`country_dossiers.cover_url`, `dossier_sections.gorsel` ve
`portal_stories.gorsel_url` içindeki bütün adresleri kırardı.

**Betikteki tuzak — ilk sürüm ÜÇ GÖRSELİ BÜYÜTTÜ.** Zaten 1440 px altında olan
ve kaynak sıkıştırması q78'den ekonomik olan dosyalarda yeniden kodlama zarar
verdi. Toplamda kazanç göründüğü için fark edilmiyordu. Betik artık önce
belleğe yazıyor ve yalnızca gerçekten küçüldüyse diske geçiyor; tekrar
çalıştırıldığında hiçbir şeyi bozmuyor.

Geri alma: bütün görseller git'te izleniyor. `_raw/gorseller/` her görselin
karşılığını TAŞIMIYOR (on üç dosya farklı adla kaydedilmiş), o yüzden tek
güvence git.

### 22.2 iCloud yinelenenleri dağıtıma giriyordu

`build/web` altında `"* 2.jpg"` biçiminde **44 dosya / 38,7 MB** birikmişti —
iCloud'un yinelenen kopyaları, hepsi optimize edilmemiş eski sürümler. Hiçbir
şey onlara bağlanmıyordu ama her dağıtımda yükleniyorlardı.

`functions/shell 2.html` de aynı kökenden. iCloud bu depoda üçüncü kez sorun
çıkarıyor (bkz. §1 node_modules, derleme `errno 60`).

Dağıtımdan önce kontrol edilmeli: `find build/web -name "* 2.*"`.

### 22.3 AÇIK — yazı tipleri 682 KB

Ana sayfada üç aile ağdan iniyor: Inter (374 KB woff2), Playfair Display ve
Lora (154 KB'lık ikişer `.ttf`). `google_fonts` çalışma anında çekiyor;
`GoogleFonts.config` hiç yapılandırılmamış.

**Basit bir "paketle" çözümü YOK: Flutter woff2'yi bundled font olarak kabul
etmiyor,** yalnızca `.ttf`/`.otf`. Yani paketlemek, alt küme çıkarılmadığı
sürece dosyaları BÜYÜTÜR. Doğru yol `fonttools` ile Latin+Türkçe alt kümesine
indirmek, `assets/google_fonts/` altına koymak ve
`GoogleFonts.config.allowRuntimeFetching = false` yapmak. `fonttools` kurulu
değil; eksik glif riski gerçek olduğu için yapılmadı.

Not: ilk ziyaretten sonra Google Fonts CDN'i uzun süre önbellekliyor.

### 22.4 AÇIK — Supabase hero görseli 306 KB

`image_fallback_helper.dart` hattı iyi kurulmuş (webp + genişlik/kalite
kıskacı). Hero `highQuality: true` ile `width=2000&quality=90` istiyor.
`1600` ve `quality=80`'e çekmek ~150 KB kazandırır; ama bu LCP öğesi ve
sayfanın en görünür görseli — kalite düşürmek bir yayın kararı.

## 23. İki hata — 6 Eylül 2026

### 23.1 Bildirimden gelen okuyucu sayfada kilitleniyordu

Haftalık özet (`/hafta/:slug`) ve yazar sayfası (`/yazar/:name`)
`SliverAppBar` kullanıyor ve `leading` YAZILMAMIŞTI. Flutter'ın varsayılan geri
düğmesi yalnızca `Navigator.canPop()` true iken çıkıyor; bildirime tıklayan ya
da paylaşılan bağlantıyı doğrudan açan okuyucunun altında hiçbir sayfa
olmadığı için düğme HİÇ görünmüyordu ve sayfadan çıkış yoktu.

İkisine de açık `leading` + `popScreen(context)` eklendi. `popScreen` zaten
doğru davranıyordu: geri gidilecek sayfa varsa ona döner, yoksa `/`'a gider.
Aynı kusur `LegalPageScreen`'de daha önce çözülmüş ve gerekçesi oraya
yazılmıştı; bu iki ekran atlanmış.

**Kural:** derin bağlantıyla açılabilen HER ekran `leading`'i açıkça
yazmalı. `kisa_kisa_screen` ve `yyt_dosyasi_screen` zaten doğruydu.

### 23.2 Dosya hikâyesinde bütün slaytlarda aynı görsel

`story_providers.dart` slayt başına görseli hesaplıyordu (`slaytGorsel` →
`gorsel`, üstünde neden gerektiğini anlatan yorumla birlikte) ama `StoryItem`
kurulurken `imageUrl: rawImage` yazılmıştı — yani SATIR düzeyindeki tek
görsel. Hesaplanan `gorsel` hiçbir yerde kullanılmıyordu.

Sonuç: Rusya'da beş, Ziraat/TMO'da dört slaydın hepsinde aynı fotoğraf.

**Teşhis sırası — veri masumdu:** `yayin.json` slaytları farklı görsellerle
doluydu; `portal_stories.items` içinde de her slaydın kendi `gorsel_url`'i
vardı; adreslerin hepsi 200 dönüyordu; süresi dolmuş satırlar sorguda zaten
eleniyordu. Kod okumakla bulunamadı — tarayıcıda hikâye açılıp slayt
ilerletildiğinde ağda YENİ GÖRSEL İNMEDİĞİ görülünce yer daraldı.

Değişken hesaplanıp kullanılmadığı için derleyici de uyarmıyor: `gorsel` bir
ifadenin içinde tanımlanmış sayılıyor.

### 23.3 Slayt görselleri artık önden indiriliyor

§23.2'nin düzeltilmesi ikinci bir sorunu açığa çıkardı: her slaydın kendi
fotoğrafı olunca, slayt açılırken görsel henüz inmemiş oluyor ve ekran SİYAH
kalıyordu. Görseller 250-450 KB, slayt süresi birkaç saniye — indirme çoğu
zaman yetişmiyor. Canlıda gözlendi.

Mevcut `_precacheNeighbours()` yalnızca komşu GRUPLARIN ilk slaydını alıyordu;
bu, bütün slaytların aynı görseli paylaştığı (hatalı) dünyada yeterliydi.
`_precacheNextSlides()` eklendi: `_startStory()` her çalıştığında gruptaki
sonraki iki slaydın görselini önden indiriyor (biri sıradaki, öteki okuyucu
dokunarak atlarsa diye).

**Ders:** bir hatayı düzeltmek, o hatanın gizlediği maliyeti ortaya çıkarabilir.
Aynı görseli göstermek yanlıştı ama bedava görünüyordu.

## 24. Gerçek köşe yazarı — Halil ETYEMEZ (6 Eylül 2026)

"Yazarlarımız" bölümündeki ilk GERÇEK kişi. Diğer beş yazar kurgusal persona
ve yazıları üretiliyor (`columnist.py`); bu yazarın yazıları
`yazarakademisi.com`dan olduğu gibi alınıyor.

**İzin:** tam metin yayını için izin kullanıcı tarafından açıkça bildirildi.
Her kayıtta `source_url` duruyor. (Projenin §11.1'deki kuralı gereği bu
sorulmadan yapılmazdı.)

### 24.1 Kazıma değil API

Kaynak WordPress ve REST API'si açık:
`/wp-json/wp/v2/posts?author=1003`. Alanlar adlarıyla geliyor, sitenin teması
değişince kırılmıyor. `src/yazar_akademisi.py` (hat deposunda).

Kapsam kullanıcı kararıyla **son 20 yazı**. Kaynakta toplam 111 var.

### 24.2 Metne DOKUNULMUYOR

Kullanıcı kararı: "orjinal yazıyı değiştirme." Yazılar `reporter`/`editor`/
`designer` adımlarından geçmiyor — yalnızca `translator_node`'dan. WordPress'in
verdiği HTML olduğu gibi yazılıyor.

Çeviri başarısızsa yazı TÜRKÇE olarak yayınlanıyor ve İngilizce sayfada
Türkçesine düşüyor; yayınlanmamasından iyi.

### 24.3 Görsel: olanda var, olmayanda yok

**İlk varsayım YANLIŞTI.** "Kaynakta hiç görsel yok" sonucu en yeni ÜÇ yazıya
bakılarak çıkarılmıştı. Yirmisi birden ölçülünce **14'ünde** birer görsel
olduğu görüldü; yalnızca en yeni 6 tanesi görselsiz.

Kullanıcı kararı (7 Eylül 2026): görseli olan yazı görseliyle, olmayan
görselsiz yayınlanır.

- İçerikteki **ilk** görsel kart görseli oluyor — WordPress'te açılış görseli
  oraya konuyor, sonrakiler metin arası ikincil görseller.
- Görsel KENDİ DEPOMUZA alınıyor (`upload_article_images`): hotlink onların
  bant genişliğini harcar ve dosya taşınınca sessizce kırılır. Aynı yardımcı
  1200×630 paylaşım kartını da üretiyor, yani bu yazıların WhatsApp
  önizlemesi öteki haberlerle aynı ölçüde çıkıyor.
- Görseli olmayanlarda `image_url` NULL: manşete girmiyorlar (manşet zaten
  dolu olanlar arasından seçiyor) ve `NewsCard` görselsiz varyantı çiziyor —
  16:9 alan HİÇ kurulmuyor, kazanılan yer metne veriliyor (başlık 18→21
  punto, 3→4 satır; özet 2→7 satır). Bu kural yazara özel DEĞİL,
  `image_url` boş olan her yazı için geçerli.

**Metne dokunulmuyor:** `content` WordPress'in verdiği HTML olarak yazılıyor.
Bir ara görselleri metinden ayıklamak yazıldı ve kullanıcı kararıyla geri
alındı.

**Ders (bu işte İKİNCİ kez):** birkaç örneğe bakıp "hiç yok" sonucuna
varılmaz. Aynı hata profil fotoğrafında da yapıldı (§24.5) — orada da
sayfadaki ilk birkaç `<img>` yer tutucuydu ve fotoğraf yok sanıldı.

### 24.4 Eşleşme tek bir dizeye bağlı

`ai_columnists.dart` içindeki `name` ile veritabanındaki `source_name` BİREBİR
aynı olmak zorunda: yazar sayfası yazıları `a.sourceName == columnist.name`
ile buluyor. Tek harflik fark sayfayı boş gösterir ve hiçbir hata üretmez.
İkisi de `'Halil ETYEMEZ'`.

### 24.5 Profil fotoğrafı kendi sunucumuzda

`web/yazarlar/halil-etyemez.jpg` (400×400). Kaynağın adresine hotlink
yapılmadı: onların bant genişliğini harcar ve dosya taşınınca sessizce kırılır.

**İlk aramada bulunamadı, kullanıcı düzeltti.** Sayfadaki ilk `<img>`
etiketleri tema yer tutucularıydı (`noimage.png`/`noauthor.png`) ve Gravatar da
varsayılan döndürüyordu (`d=404` → 404); bu ikisine bakıp "fotoğraf yok" sonucu
çıkarılmıştı. Gerçek fotoğraf listenin ilerisinde, lazy-load olmayan bir
`src` içindeydi. **Ders: bir sayfadaki ilk birkaç eşleşmeye bakıp yokluk
sonucuna varılmaz.**

Kare kırpma dikeyde ÜSTTEN alındı (%25) — portrede yüz üst yarıdadır, ortadan
kırpmak çeneyi keserdi.

`all_columnists_screen.dart`'ta gizli bir hata da bu sırada düzeltildi:
avatar `DecorationImage(NetworkImage(...))` ile çiziliyordu ve
`DecorationImage`in hata yedeği YOK — fotoğrafsız bir yazarda çizim sırasında
patlardı. Artık adres boşsa baş harf çiziliyor. (Öteki iki avatar noktası
zaten `Image.network` + `errorBuilder` kullanıyordu.)

### 24.6 Yeni yazı kontrolü hatta bağlı

`src/main.py` her çalıştığında, ajans akışlarından ÖNCE `senkronize()`
çağrılıyor. Yeni yazı yoksa tek API isteğiyle 0 dönüyor. Mükerrer ölçütü
`source_url` — başlığa bakmak yanlış olurdu, yazar aynı başlığı yıllar sonra
yeniden kullanabilir.

Hata kendi içinde yakalanıyor: kaynak sitesi erişilemez olduğunda haber
hattının tamamı durmamalı.

`created_at` kaynaktaki yayın tarihinden yazılıyor — `now()` olsaydı yirmi
yazının hepsi aynı ana yığılır ve sıralama bozulurdu.

### 24.7 Kaynak sunucu hız sınırlaması

`yazarakademisi.com` art arda isteklerde bağlantıyı sıfırlıyor
(`Connection reset by peer`) ve User-Agent'sız/otomatik görünen isteklere 403
dönüyor. İnceleme sırasında çok istek atıldığı için kaynak bir süre tamamen
kapandı; sonra kendiliğinden açıldı.

`_api` artık geri çekilmeli yeniden deniyor (2/4/8 sn) ve tarayıcı benzeri bir
User-Agent gönderiyor. Not: 14 saniyelik toplam bekleme sınırlama penceresini
kapatmaya YETMEDİ — engel dakikalarca sürdü. Hat günde birkaç kez çalıştığı
için bu sorun değil (bir sonraki çalışmada alınır), ama elle çalıştırırken
"kaynak okunamadı" görülürse beklemek gerekiyor.

## 25. Panelde metin kaybı ve sabitlenemeyen manşet — 7 Eylül 2026

İki ayrı şikâyet, iki ayrı kök neden. İkisi de aynı türden: **liste sorgusunun
taşımadığı bir alanı, taşıyormuş gibi kullanmak.**

### 25.1 Panel haberin metnini siliyordu (veri kaybı)

Belirti: "yönetim panelinde yayınlanan habere tıklayınca sağda metin yok,
'metin oluşturun' yazıyor — ama habere gidince metin var."

Zincir:

1. Ağ yükünü düşürmek için liste sorgusu daraltıldı (`_listeSutunlari`,
   bkz. §22). `content`, `content_en`, `key_takeaways`, `expert_insight`,
   `chart_data` artık listede GELMİYOR — 2.62 MB → 0.22 MB kazancı bundan.
2. Panel düzenleyiciyi bu liste nesnesiyle dolduruyordu → metin alanı boş.
3. `_submitArticle` kaydı `_editingArticle`'daki alanlardan yeniden kuruyor,
   `updateArticle` da `toJson()` ile **bütün satırı** yazıyor.
4. Sonuç: kaydet'e basmak, veritabanındaki dolu metni boş metinle eziyordu.
   `content_en` de gidiyordu, çünkü boş içeriğin çevirisi boş.

Üretimde bir haber tam olarak böyle kayboldu (`content=0`, `content_en=0`,
`article_format=null` üçlüsü bu hatanın imzasıdır). Tarama sonucu hasar tek
kayıtla sınırlıydı: 1 Ağustos'tan beri 907 haberden 1'i.

İki katmanlı düzeltme:

- **Kök neden**: düzenlemeye açarken kayıt `fetchArticleById` ile TAM haliyle
  yeniden çekiliyor; liste nesnesi yalnızca yedek.
- **Güvenlik ağı**: veritabanında metin varken düzenleyici boş dönüyorsa kayıt
  durduruluyor. Bu bir yükleme arızasıdır, kullanıcının niyeti değil.

**Kural**: `_listeSutunlari`'ndan bir alan çıkarıldığında, o alanı `_editingArticle`
üzerinden okuyan HER yazma yolu gözden geçirilir. Dar liste sorgusu okuma için
güvenlidir, yazma için değildir.

### 25.2 Manşetin 1. sırası sabitlenemiyordu

Belirti: "ilk 3'e sabitlenen haber, sayfadan çıkıp geri gelince kayboluyor."

Kök neden §25.1 ile aynı biçimde bir süzgeç uyuşmazlığı:

- Seçim penceresi **yayında + görselli** her haberi sunuyordu (kısa haberler
  dahil).
- `heroArticlesProvider` havuzu ise `_yayindaVeTam` ile süzüyordu — kısa
  haberler havuza hiç girmiyor.
- Yani kısa bir haber seçilince `hero_order = -1` veritabanına yazılıyor, ama
  haber havuzda olmadığı için `pinnedMap`'e giremiyor: slot ekranda
  "(Otomatik seçiliyor)" olarak kalıyordu. Yönetim ekranı da sabit durumu bu
  havuzdan okuduğu için sabitleme kaybolmuş görünüyordu.
- Sessiz kalmasının sebebi: yazma başarılıydı, hata yoktu. Yalnızca okuma
  tarafı o satırı görmüyordu. Üretimde doğrulandı — slot 1'de `kisa` formatlı
  bir haber `hero_order=-1` ile duruyordu, slot 2 ve 3'teki `tam` haberler
  çalışıyordu. Son 7 günün yayınlı haberlerinin %23'ü kısa formatlı.

Düzeltme: `_heroHavuzunaGirer` — **açık sabitleme, kısa haber elemesini
geçersiz kılar.** `_yayindaVeTam`'daki eleme bir OTOMATİK seçim kuralıdır
(§ "Kısa Kısa"); yönetici bir slotu elle doldurduğunda o kararı zaten bilerek
veriyor. Görsel şartı duruyor: manşet kartı büyük görselin üstüne kuruluyor.
Sabitlenmiş kısa haber ayrıca 'Kısa Kısa' bloğundan düşülüyor ki aynı ekranda
iki kez çıkmasın.

**Kural**: bir yazma eylemini sunan seçici, o yazmanın okuma tarafındaki
süzgeciyle AYNI süzgeci uygulamalı — ya da okuma tarafı eylemi istisna
tanımalı. İkisi ayrıştığı anda kullanıcı, kaydedilen ama hiç görünmeyen bir
işlem yapar.

### 25.3 Yayında olmayan haberin hikâyesi

`portal_stories` sorgusu `articles(...)` ile SOL join yapıyor. Haber taslağa
çekilince RLS onu gizliyor, join null dönüyor ama hikâye şeritte kalabiliyordu.
Artık `article_id` dolu olan bir hikâye, join'i boşsa gösterilmiyor. Dosya
hikâyeleri (`article_id` null) bu kuralın dışında — hedeflerini `hedef_yol`
üzerinden veriyorlar (bkz. §12). Silme tarafı ayrıca `on delete cascade` ile
kapatıldı (`20260907010000_hikaye_cascade.sql`).

## 26. Köşe yazarları — kurgusallar kaldırıldı, gerçek yazar oturtuldu (7 Eylül 2026)

Kullanıcı kararı: **portal yalnızca gerçek yazarlarla yürüyor.** Beş kurgusal
("mock") yazar ve 55 yazısı silindi; geriye tek gerçek yazar kaldı
(Halil ETYEMEZ, `src/yazar_akademisi.py` ile kaynağından alınıyor).

Silinenler: `articles` içindeki 55 kayıt, `src/agents/columnist.py` (üretici
ajan), `main.py`'deki çağrısı, ve kök dizindeki tek seferlik tohumlama
dosyaları (`seed_op_eds.py`, `ai_columnist_bot.py`, `generate_sql.py`,
`seed_op_eds.sql`). `src/scripts/temizlik.py` bu adları eski kayıtları tanımak
için kullanıyordu; ajana bağımlı kalmasın diye liste oraya kopyalandı.

### 26.1 Liste kısalınca tasarım çökmesin — hayalet yuvalar

Ana sayfadaki "Yazarlarımız" kutusu yuva sayısını listeden alıyordu; beş yazar
gidince kutu tek satıra düşüp sayfanın sağ sütununu boşaltıyordu. Kutu artık
**her zaman üç yuvalı** (`_opEdYuvaSayisi`): gerçek yazarlar baştan yerleşir,
kalanlar `_OpEdGhostCard` ile dolar. Aynısı yazarlar sayfasının ızgarasında da
var (`_HayaletYazarKarti`, en az bir tam satır).

Hayaletler **isimsiz**: boş profil çemberi ve metnin geleceği yeri işaretleyen
soluk çubuklar. Uydurma isim yazmak, kullanıcının künye/hakkımızda alanları
için verdiği "yanlış isim yerine boş kalsın" kararının ihlali olurdu.

### 26.2 Yazar arşivi tarih penceresine sıkışıyordu

Yazar sayfası [latestArticlesProvider]'ı süzüyordu. O sağlayıcı en yeni 500
haberi taşıyor (`_listeSiniri`) ve hat günde ~130 haber çekiyor: pencere ancak
son birkaç haftayı kapsıyor. Sonuç, 20 yazısı olan yazarın profilinde **3 yazı**
görünmesiydi. Arşiv artık kendi sorgusuyla geliyor
(`fetchArticlesBySourceName` → `columnistArticlesProvider`).

**Kural**: "bir varlığın TÜM kayıtları" isteyen hiçbir ekran, tarihe göre
sınırlanmış ortak listeyi süzerek çalışmamalı. Sınır sessizdir: hata vermez,
sadece eksik gösterir.

### 26.3 İngilizce'de Türkçe metin

`summary_en` ve `spot_en` 20 yazının yalnızca 5'inde doluydu; boş kalınca
uygulama Türkçesine düşüyor ve İngilizce arayüzde Türkçe özet çıkıyordu.
Çevirmen bu alanları her zaman üretmiyor. Artık üretmezse **İngilizce gövdenin
ilk paragrafından türetiliyor** (`_ilk_paragraf`) — Türkçe tarafta `summary`
zaten kaynağın ilk paragrafı olduğu için iki dil aynı hizada kalıyor.

Bir yazının `content_en`'i bozuk geldi: **metnin tamamı `<figcaption>` içine
sarılmıştı**, yani İngilizce'de yazı resim altyazısı gibi görünecekti. Çözüldü
ve `_ilk_paragraf` figürü atan yolun yanına tüm etiketleri sıyıran bir yedek
yol aldı.

### 26.4 Spot, gövdenin ilk paragrafını tekrarlıyordu

Kaynağın "excerpt" alanı WordPress tarafından yazının ilk paragrafından
üretiliyor; spot olarak gösterilince okuyucu aynı metni iki kez okuyordu.
`_spotMetniTekrarliyor` spot ile gövdenin başını sadeleştirip karşılaştırıyor,
örtüşüyorsa spot gizleniyor.

Kontrol **iki dilde de** yapılıyor: İngilizce spot ve gövde ayrı ayrı
çevrildiğinde kelimeler birebir tutmayabiliyor ve önek karşılaştırması
kaçırıyor; Türkçe çift kaynaktan birebir geldiği için kesin sonuç veriyor.
Biri "tekrar" diyorsa spot gizlenir.

### 26.5 Görselsiz yazı ve kart yüksekliği

- Yazının kendi sayfasındaki hero görsel bloğu, görsel yoksa **hiç kurulmuyor**;
  eskiden tepede boş bir bant kalıyordu. (Kart tarafı bunu `NewsCard.gorselsiz`
  ile zaten çözmüştü — eksik olan yazının sayfasıydı.)
- "Son Okuduklarınız" şeridinde görselsiz köşe yazısı için **yazarın profil
  fotoğrafı** kullanılıyor (`kartGorseli`).
- Yazar arşivinde özet 20 kelimeyle sınırlı (`NewsCard.ozetKelimeSiniri`) ve
  kart boyu 440 → 340 indi. Kelimeden kesmek satırdan kesmekten iyi: kart
  yüksekliği içeriğe göre değil, verilen sınıra göre öngörülebilir oluyor.

### 26.6 Görseli olmayan yazıda boş görsel kutusu

Yazarın 20 yazısından 6'sında (arşivin 15. sırasından itibaren) kart boş bir
görsel kutusu çiziyordu. `image_url` DOLUYDU ama adres **404** veriyordu — ve
adres bizim depomuzu değil, doğrudan `yazarakademisi.com`'u gösteriyordu.

Kök neden `upload_article_images`: **başarısızlıkta gelen adresi olduğu gibi
geri veriyor** (`image_storage.py`, belgelenmiş davranış). Bu 6 görsel çekim
anında kaynakta zaten silinmişti; yükleme başarısız oldu ve kayda kaynağın ölü
adresi yazıldı. Kart tarafındaki ölçüt "adres boş mu" olduğu için dolu-ama-ölü
adres "görsel var" sayılıyor ve `gorselsiz` düzenine geçilmiyordu.

İki taraflı düzeltme:

- **Veri**: bu 6 kaydın `image_url`/`story_image_url` alanları boşaltıldı;
  kartlar artık görselsiz düzende çiziliyor (kullanıcının kararı: "görselsiz
  olanları görselsiz kullan").
- **Hat**: `yazar_akademisi.py` artık yalnızca KENDİ depomuzu gösteren adresi
  kabul ediyor; başka her şey görselsiz sayılıyor. Böylece hem hotlink hem de
  ölü adres kayda giremiyor.

Site genelinde tarandı: 1 Ağustos'tan beri 774 yayınlı haberin yalnızca 2'sinde
depo dışı adres vardı (biri bozuk göreli yol — temizlendi, biri çalışan
hotlink). Yani sorun yaygın değil, içe aktarma yoluna özgüydü.

**Kural**: "görsel var mı" sorusunun cevabı adresin DOLU olması değil,
adresin BİZİM olması. Dış adres her an ölebilir ve ölünce kullanıcıya boş kutu
olarak görünür — hata olarak değil.

## 27. Tarım TV kaynak olarak eklendi (7 Eylül 2026)

`tarimtv.gov.tr` (Tarım Bakanlığı Web TV) artık `fetch_official_channels`
içinde tanımlı bir kaynak. Öncesinde tanımlı DEĞİLDİ; veritabanındaki tek
Tarım TV haberi `news.google.com` toplayıcısı üzerinden tek seferlik gelmişti.

**Neden kazıma**: sitede RSS yok (`/rss`, `/feed`, `/rss.xml`, `/sitemap.xml`
hepsi 404). Site bir video portalı, içerik `/tr/video-detay/...` sayfalarında.

**Neden yine de kullanılabilir**: her video sayfasının altında gerçek bir
açıklama metni var. Ölçüldü: 1.087–4.438 karakter. `raw_source` olarak bu metin
veriliyor — **başlıktan haber uydurulmuyor.** Metin 120 karakterin altındaysa
kayıt atlanıyor; yarım veriyle haber üretmek, haber üretmemekten kötü.

**Gövde nasıl bulunuyor**: `div.col-md-9` içindeki en uzun metin alınıyor,
sonra `og:description` ile DOĞRULANIYOR (çapanın ilk 40 karakteri gövdede
geçmiyorsa yanlış kutu alınmış demektir; o durumda yalnızca `og:description`
kullanılıyor). Sayfa iskeleti değişirse kazıyıcı sessizce menü metni
toplamıyor, düşüyor.

**Doğrulama**: mevcut tek Tarım TV haberi kaynağıyla karşılaştırıldı. Adres
slug'ı ("yumakli-gelecegi-planliyoruz") ile bizdeki başlık ("Havza Bazlı Su
Yönetiminde Dijital Dönüşüm") farklı görünüyor ama içerik birebir örtüşüyor —
fark editöryel yeniden yazımdan geliyor, uydurma değil.

### 27.1 Tarih sorunu — trafilatura tarihsiz sayfada TARİH UYDURUYOR

Tarım TV eklendikten sonraki ilk çalışmada 30 aday kazındı ve **hiçbiri**
veritabanına girmedi. Kara liste ve anahtar kelime filtresi değil, yaş süzgeci
elemişti: hepsi "10-11 günlük" görünüyordu.

Bu tarihler UYDURMAYDI. Site hiçbir yerde yayın tarihi vermiyor (detay sayfası,
liste, meta etiketleri, JSON-LD, `player.tvkur.com` gömme — hepsi bakıldı).
`fulltext.yayin_tarihi` bu durumda `trafilatura`'ya düşüyor ve trafilatura
tarihsiz sayfada tarih ÜRETİYOR:

- 31 Ağustos'ta yayımlanmış videoya "2026-08-12" dedi — bu dize sayfanın
  HTML'inde hiç geçmiyor.
- 404 sayfasına "2024-01-01" dedi.

Sonuç, filtrenin yokluğundan kötüydü: gerçekte **7 günlük** olan içerikler
"10 gün" damgası yiyip sessizce eleniyordu.

**Çözüm — gerçek tarih YouTube'dan.** Tarım TV'nin YouTube kanalı
(`UCAjGzaa7ktrF6A9kC1Jfhhg`) RSS akışında hem gerçek yayın tarihini hem de
siteyle BİREBİR AYNI başlığı veriyor. `tarim_tv_tarihleri()` bu akıştan
`{sadeleştirilmiş başlık: tarih}` haritası kuruyor; kazıyıcı eşleşen videoya
`published_at` ve `tarih_kesin = True` yazıyor.

`fulltext.py` artık `tarih_kesin` işaretli haberin tarihini sayfadan okunan
tarihle EZMİYOR. İşaret yoksa davranış eskisi gibi.

Eşleşmeyen video tarihsiz kalır ve yaş süzgecinde elenir — bilerek: yaşı
doğrulanamayan içeriği yayınlamaktansa atlamak yeğdir (`yas_suzgeci`'nin
"kapalı başarısız" kuralıyla aynı çizgi).

**Sınır**: YouTube akışı yalnızca son 15 videoyu taşıyor. Günde ~2-3 video
hızında bu 5-6 günü kapsıyor, yani bir haftalık pencere için sınırda. Site
yayın hızını artırırsa taze videolar tarihsiz kalıp elenebilir.

**Doğrulanmış sonuç** (7 Eylül 2026): 30 aday → 14'ü YouTube'da eşleşti →
6'sı 7 günlük sınırı geçti → 5'i panele düştü. Altıncısı (Alanya tropikal
meyve) `articles_slug_key` çakışmasıyla reddedildi çünkü aynı haberi Anadolu
Ajansı 28 Ağustos'ta zaten yayınlamıştı — mükerrer koruması doğru çalıştı.
Beş haberin de görseli kendi depomuza yüklendi.

**Bilinen kusur (düzeltilmedi)**: DB kaydı `duplicate key` ile başarısız
olduğunda hat yine de `✅ [ONAY BEKLİYOR]` yazıyor. Kayıt olmadığı hâlde
başarı bildiren bu satır, gerçek hataları gizleyebilir.

## 28. Emtia — eski fiyat gizlenmiyor, tarihiyle gösteriliyor (7 Eylül 2026)

`commodity_latest_prices` görünümü işlem gören ürünlerde 14 günü aşan fiyatı
şeritten TAMAMEN düşürüyordu:

```sql
and (c.price_kind <> 'traded' or (current_date - p.price_date) <= 14)
```

Sonuç: Polatlı'da 30 Haziran'dan beri işlem görmeyen **mısır** ve 3
Ağustos'tan beri işlem görmeyen **kanola** vitrinden kayboldu. Kullanıcı için
bu "fiyat eski" değil "ürün yok" gibi görünüyordu.

**Ayrıştırıcıda hata yoktu.** Mısırın 30 Haziran fiyatı düzgün okunmuş; son 21
günün Polatlı bültenlerinde yalnızca buğday ve arpa geçiyor — mısır gerçekten
işlem görmemiş (hasadı eylül-ekimde başlıyor). Bunu `--dump-raw` ile doğruladık.

Kural kaldırıldı (`20260907120000_emtia_bayatlik_gorunur.sql`). Göstermek
güvenli, çünkü arayüz zaten hazırdı:

- Kart fiyatın TARİHİNİ kaynağın yanında yazıyor ("Polatlı Ticaret Borsası ·
  30 Haz").
- `CommodityPrice.isStale` (3 günden eski) için ayrı bir işaret noktası var.
- `change_pct` yalnızca iki ölçüm arası 7 günden azsa hesaplanıyor; eski
  fiyatta yüzde gösterilmiyor, yani yanıltıcı bir "değişim" çıkmıyor.

**Kural**: veri eskidiğinde onu gizlemek, kullanıcıya "veri yok" demektir.
Doğrusu veriyi tarihiyle birlikte göstermek — okuyucu ne gördüğünü bilsin.
Gizlemek yalnızca veri YANLIŞ olabilecekse doğrudur.

## 29. İnceleme masası — Aşama 1 (7 Eylül 2026)

Yayın kararı, hattın ürettiği verinin neredeyse tamamı görünmeden veriliyordu.
Onay kuyruğu (`admin_statistics_screen.dart` → `_PendingArticlesSection`)
kartta yalnızca **başlık ve iki satır özet** gösteriyor, altına iki düğme
koyuyordu. Gövde yok, kaynak adresi yok, görsel yok, İngilizce sürüm yok.

> Not: haberi DÜZENLEME ekranında ("Orijinal Link") kaynak bağlantısı zaten
> vardı. Eksik olan, kararın verildiği onay kuyruğuydu — ayrı ekran.

### 29.1 Reddetme artık silmiyor

`rejectArticle` doğrudan `delete()` çağırıyordu. Yanlış basılan bir düğme
geri getirilemeyecek bir kaydı yok ediyordu: kaynak bir daha çekilmiyor (adres
red hafızasına yazılıyor) ve hikâye `on delete cascade` ile gidiyordu.

Artık durum `rejected` oluyor, gerekçesi ve zamanı saklanıyor, arşivden geri
alınabiliyor. Kısıt (`articles_status_check`) yalnızca genişletildi.

**Kritik etkileşim — atlanırsa hat bozulur**: `rejected_sources` şimdiye kadar
`AFTER DELETE` tetikleyicisiyle doluyordu. Silme kalkınca o tetikleyici
çalışmayacaktı ve hat reddedilen haberi ertesi gün yeniden çekecekti. Bu
yüzden iki tetikleyici eklendi:

- `articles_remember_rejection_status` — durum `rejected` olunca adresi
  hafızaya yazar.
- `articles_forget_rejection_status` — red geri alınınca adresi hafızadan
  siler; yoksa "geri al" yarım kalır, hat o haberi bir daha getirmez.

### 29.2 Doğrulama verisi kaydediliyor

Muhabir ajanı her haber için `facts` (5N1K), `figures` (rakam + dönem +
açıklayan kurum) ve `quotes` (doğrudan alıntılar) üretiyordu; bunlar hat içinde
kullanılıp ATILIYORDU. Artık `articles` tablosunda saklanıyor ve inceleme
kartında "Kaynak doğrulama" bölümünde gösteriliyor.

Yeni yapay zekâ maliyeti yok: veri zaten üretiliyordu, sadece yazılmıyordu.
Eski kayıtlarda alanlar boş — kart bunu açıkça yazıyor.

### 29.3 İnceleme kartı

`inceleme_karti.dart`. Tek ekranda üç soruyu cevaplıyor: **ne yayınlanacak**
(gövde önizlemesi, Türkçe/İngilizce sekmeli), **doğru mu** (kaynak bağlantısı
+ doğrulama verisi), **eksik var mı** (bütünlük uyarıları).

İngilizce sekmesi bilerek eşit ağırlıkta: site iki dilli ve İngilizce sürüm
bugüne kadar hiçbir aşamada insan gözünden geçmiyordu.

### 29.4 Köşe yazıları — hazırlık süreci

- **Yayına değil incelemeye.** `yazar_akademisi.py` `status: "published"`
  yazıyordu: gerçek bir kişinin adıyla, hiç kimse görmeden yayına giriyordu.
  Artık `reviewing`.
- **Bütünlük kontrolü.** Gövde kısa mı, İngilizce alanlar eksik mi, görsel var
  mı — içe aktarımda uyarı basılıyor, kartta da gösteriliyor. Yazıyı
  ENGELLEMİYOR: eksik bir yazıyı incelemeye göndermek, hiç göndermemekten iyi.
- **Bozuk sarma açılıyor.** `_figcaption_ac`: gövdenin tamamı `<figcaption>`
  içine sarılmış geldiğinde paragraflara açılıyor (kaynakta bir örnek böyleydi;
  İngilizce'de yazı resim altyazısı gibi görünüyordu).
- **İzin kaydı.** `content_licenses` tablosu. İzin sözlü alınmıştı ve yalnızca
  bir kod yorumunda duruyordu. Kaydı olmayan kaynaktan içe aktarma
  YAPILMIYOR — telif "muhtemelen vardır" ile yürütülmez.
- **Kaynak senkronu.** WordPress `modified_gmt` veriyor, tek liste çağrısıyla
  karşılaştırılıyor (yazı başına ek istek yok). Kaynakta **güncellenmiş** yazı
  yalnızca işaretleniyor (`source_drift`) — metni kendiliğinden değiştirmiyoruz,
  hangi sürümün yayınlanacağı editör kararı. Kaynaktan **kaldırılmış** yazı
  otomatik yayından çekiliyor: kaldırılmış bir yazıyı yayında tutmak, izin
  verilmiş olsa bile savunulabilir değil.

**Kural**: bir ajan karar vermek için veri üretiyorsa, o veriyi kararı VEREN
kişi de görmeli. Terminale basılıp atılan her sinyal, yöneticinin körlemesine
karar vermesi demek.

## 30. İnceleme masası — Aşama 2 ve 3 (7 Eylül 2026)

**Aşama 2**
- **Toplu işlem**: onay kuyruğunda çoklu seçim, toplu yayınla/reddet. Günde
  ~39 haber tek tek karara bağlanıyordu.
- **Benzer haber uyarısı**: kartta, son 30 günün yayınları arasında başlık
  benzerliği (`search_articles_fuzzy`, pg_trgm — mevcut altyapı). Mükerreri
  şimdiye kadar yalnızca `articles_slug_key` kısıtı yakalıyordu.
- **Hat geçmişi**: `agent_logs.article_id` artık DOLU yazılıyor ve kartta
  gösteriliyor. 697 kaydın hepsi NULL'dı, yani hiçbir günlük okunamıyordu.
- **Gelişmiş alanlar düzenlenebilir**: spot, öne çıkanlar, uzman görüşü, SEO,
  konu, bölge, biçim, İngilizce başlık/özet. Boş bırakılan alan mevcut değeri
  KORUYOR (boşla ezmemek için — §25.1).

**Aşama 3**
- **Zamanlanmış yayın**: `publish_at` + `scheduled` durumu; `publishScheduled`
  bulut fonksiyonu beş dakikada bir `publish_scheduled_articles()` RPC'sini
  çağırıyor. Anon anahtarın UPDATE yetkisi yok, yazma SECURITY DEFINER
  fonksiyondan geçiyor (mevcut kalıp).
- **Kaynak karnesi**: `source_scorecard` görünümü + panelde tablo. Red oranı
  ancak reddedilenler silinmediği için anlamlı (§29.1).
- **Öneri kuyruğu**: toplu arşivleme. 772 öneri birikmişti; silinmiyor,
  `archived` oluyor.

### 30.1 Bulunan iki kusur

- **`chief.py`'deki insert ÖLÜ KOD.** Haberler `main.py`'deki `db_payload` ile
  yazılıyor. Doğrulama alanlarını önce chief'e eklemiştim; sessizce etkisiz
  kalıyordu. Yeni bir alan eklenecekse `main.py`'ye eklenmeli; chief'in
  başına bu uyarı yazıldı.
- **`article_format` panelden HİÇ yazılmıyordu.** Kaydetme rutini bu alanı
  taşımıyordu, dolayısıyla panelden kaydedilen her haberin biçimi null'a
  düşüyordu. Artık formdaki değer yazılıyor.

## 31. Gövde görselleri — paketin sessiz hatası (8-9 Eylül 2026)

Panelden haberin metnine yerleştirilen görsel kaydediliyor ama haber sayfasında
**görünmüyordu.** Hata yoktu, panel "başarılı" diyordu, veritabanında adres
duruyordu ve adres tarayıcıda açılıyordu.

### 31.1 Teşhis sırası — dört yanlış iz

Sırayla elenenler, tekrar araştırılmasın diye: veritabanı boyut sınırı (287 KB
gövde sorunsuz yazılıyor), yükleme MIME türü (`image/jpg` geçersizdi,
`image/jpeg`'e çevrildi — düzelmedi), gömülü `style="width:576px"` (render
anında temizlendi — düzelmedi), Supabase dönüştürme uç noktası (200 dönüyor).

**Kapak görselinin de bozuk olduğu sanıldı ve bu yanlış izi uzattı.** Kapak
çalışıyordu; yalnızca bu sitede görseller 10 saniyeden geç boyanıyor ve erken
alınan ekran görüntüsü onları "kırık" gösteriyor. **Ders: bu sitede görsel
teşhisinde tek bir ekran görüntüsüne güvenilmez, beklenip tekrar bakılır.**

Aynı kusur içe aktarılan köşe yazılarındaki `<figure><img>` görsellerinde de
vardı — yani editöre özgü değildi, ortak yol `flutter_html`di.

### 31.2 Kök neden — birim atılıyor, sayı kalıyor

`flutter_html` 3.0.0, `image_builtin.dart`:

```dart
Image.network(
  element.src,
  width: imageStyle.width?.value,    // Width(100, Unit.percent) → 100 piksel
  height: imageStyle.height?.value,  // Height.auto() → super(0, Unit.auto) → 0
  fit: BoxFit.fill,
)
```

Eklenti **stilin birimini okumuyor, yalnızca sayısını** veriyor. Bizim
`"img": Style(width: Width(100, Unit.percent), height: Height.auto())`
stilimiz orada "100 piksel genişlik, **0 piksel yükseklik**" oluyordu. Görsel
iniyor, satır kutusu yer ayırıyor, hiçbir piksel boyanmıyor.

Kapak görselinin çalışmasının sebebi de bu: kapak `NewsArticleImage`'dan
geçiyor, `flutter_html`e hiç uğramıyor.

### 31.3 Çözüm — etiket devralındı

**Yüzdeyi düzeltmek yetmezdi:** eklenti hiçbir birimi okumuyor, dolayısıyla
duyarlı bir genişlik o yoldan verilemiyor. `<img>` tamamen devralındı:
`lib/features/home/presentation/widgets/govde_gorseli.dart`.

Kullanıcı eklentileri yerleşiklerden ÖNCE deneniyor (`html_parser.dart:105`),
yani bu eklenti varken `ImageBuiltIn` hiç çalışmıyor. `htmlStyle`daki `"img"`
girdisi KALDIRILDI — geri konursa hiçbir işe yaramaz, yalnızca yanıltır.

Eklenti üç yerde: makale sayfasının iki `Html` bloğu ve inceleme kartı.
İnceleme masası yayınlanacak hâli göstermeli.

**Paket sürümü yükseltilirse bu eklenti gözden geçirilir**; yukarıdaki hata
düzeltilmiş olabilir ama eklenti yine de doğru çalışır (yerleşiği bastırıyor).

### 31.4 Denenip GERİ ALINAN: panel ölçüsüne uymak

Editör `style="width: 25%; float: left"` yazabiliyor ve render tarafında bu
öznitelik siliniyordu, yani yöneticinin verdiği ölçü sessizce kayboluyordu.
Ölçüyü okuyan bir sürüm yazıldı (yüzde/piksel ayrıştırma, `float` → hizalama,
görseli saran boş `<h2>`'nin açılması) ve **kullanıcı kararıyla geri alındı** —
sorunu kendi yöntemiyle çözdü, dağıtılmadı.

Tekrar gerekirse bilinsin: **metin görselin etrafından DOLANAMAZ.** Flutter'ın
metin yerleşimi CSS `float`'ı tanımıyor; taklit etmek paragrafı elle parçalamayı
gerektirir. `float` en fazla bir hizalamaya çevrilebilir.

## 32. Yazar avatarı — üçüncü deneme: buğday başağı (9 Eylül 2026)

Fotoğrafı olmayan yazar için ne gösterileceği **üç kez** değişti. Sıra ve
gerekçeler, dördüncü kez tartışılmasın diye:

1. **Baş harfler ("HE").** Bırakıldı: kimlik işareti gibi değil, eksik bir veri
   gibi duruyordu.
2. **İnsan silueti** (baş + omuz, dolu kütle). Bırakıldı: doğru çalışıyordu ama
   ana sayfayı sadeleştiriyordu — "fotoğraf yok"un daha kibar biçiminden
   öteye geçmiyordu (kullanıcı gözlemi).
3. **Buğday başağı.** Yürürlükte.

Başak bir eksiği işaret etmiyor, portalın kendi işaretini taşıyor. Ayırt etme
işini adın kendisi yapıyor; avatarın işi yer tutup vitrini boş bırakmamak.
**Bütün yazarlarda aynı görünmesi bilinçli.**

Kullanıcıya altı seçenek sunuldu ve seçilmeyenler de kayıtlı: kontur portre
(44 pikselde çizgi inceliyor), iki renkli geometrik (fazla "uygulama ikonu"),
tarla ufku, monogram (bkz. 1. madde).

**Ölçüler yarıçapa oranlı, çizgi kalınlığında ALT SINIR var.** Oranla küçülen
çizgi panelin 44 pikselinde 1 pikselin altına düşüp soluyordu. Çizim 44'ten
100 piksele kadar aynı görünüyor.

**Koyu temada başak buğday rengine dönüyor** — koyu yeşil orada okunmuyor;
`AppColors.accentFor` içinde yazılı olan kuralın aynısı.

Uçtaki dolu tane şart: çizgilerin bittiği yeri kapatan bir şey olmadan çizim
başaktan çok bir oka benziyor.

## 33. Renk seçimi ölçülür, beğenilmez (9 Eylül 2026)

Haber şeridinin rengi iki turda değişti ve ikisi de aynı disiplinle yürüdü:
**önce kontrast hesaplanır, sonra uygulanır.**

### 33.1 Reddedilen: buğday zemin + yeşil yazı

İstenen `#C9A15A` zemin + `#5C8A4A` yazı. İkisi de paletimizde
(`wheat` / `primaryGreen`) ama birbirinin üstünde **1,7:1** veriyor; okunabilirlik
eşiği 4,5:1 ve şeritteki yazı 13 punto. `app_colors.dart` bunu zaten bir yerde
not etmiş: *"Koyu zeminde primaryGreen yeterli kontrast vermediği için wheat'e
döner."* İkisi ayrı ayrı vurgu renkleri; birlikte çalışmıyorlar.

Ölçümler kullanıcıya gösterildi, `#1F3320` (5,6:1) seçildi ve `deepGreen` adıyla
palete girdi. Sonra zemin tamamen değişince başak avatarına devredildi.

### 33.2 Yürürlükte: `earthText` zemin

| öğe | renk | kontrast |
|---|---|---|
| zemin | `earthText` `#3A2E20` | — |
| akan başlıklar | `creamBackground` `#F6F1E7` | 11,7:1 |
| "SON HABERLER" etiketi, ◆ ayracı | `wheat` | 5,5:1 |

Beyaz elendi (13,2:1 ama soğuk, sıcak paletin dışına düşüyor); `primaryGreen`
elendi (3,3:1). Krem sayfanın kendi zemin rengi — şerit siteden kopmuyor, koyu
bir kesit gibi duruyor. Etiketin buğdayda kalması iki kademeli hiyerarşi veriyor.

**Zemin değişince o zemindeki HER rengi yeniden ölç.** Buğday zemine geçildiğinde
etiket ve ◆ ayracı da buğdaydı, yani görünmez olacaklardı; ikisi de metinle
birlikte değiştirildi. Bir sonraki zemin değişiminde aynı beş nokta gözden geçirilir.

## 34. Yazarlar artık veriden yönetiliyor

Yazar listesi kodda sabitti (`ai_columnists.dart`); sıra `sort_order` ile
belirleniyor ve tek değiştirme yolu elle SQL yazmaktı.

`columnists` tablosu + `admin_yazarlar_screen.dart`: sıra **sürükleyerek**
veriliyor (beş yazarda yukarı/aşağı düğmeleri idare eder, on beşte etmez),
unvan düzenlenebiliyor, yazar gizlenebiliyor. **Kaydetme ayrı bir adım değil** —
bırakıldığı anda yazılıyor; yarım kalmış bir sıralama vitrinde karşılığı olmayan
bir durum. Gizlenen yazar listede kalır ama soluk görünür: "yok" ile "gizli"
farkı yöneticiye açık olmalı.

**Kaynak adı yazar sanılıyordu.** Panelden güncellenip yayınlanan her haberin
`source_name` alanı (GıdaTarım, Google Haberler, Tarım Dünyası) yazar listesine
düşüyordu. Kullanıcı kuralı: **yalnızca elle girilen yazarlar görünür.**
Koruma iki katmanlı — kural kodda, ayrıca veritabanı tetikleyicisinde.

Eşleşme hâlâ tek bir dizeye bağlı (§24.4): yazar sayfası `source_name`'i
BİREBİR karşılaştırıyor. Tek harflik fark sayfayı boş gösterir, hata üretmez.

## 35. Word belgesinden köşe yazısı — elle içe aktarma

Bazı yazılar kaynak sitesinden değil, doğrudan yazarın gönderdiği `.docx`
dosyasından geliyor (Ali Kemal ASLAN, Yörük Kızı, Ezher Eren ÖZ).

- **Metne DOKUNULMAZ.** Paragraf sırası, noktalama ve KALIN işaretlemeleri
  belgedeki gibi kalır; yalnızca Word'ün kabuğu HTML'e çevrilir.
- **Bitişik kalın parçalar birleştirilir.** Word bir cümleyi imla denetimi
  yüzünden onlarca `run`'a bölebiliyor; her birine ayrı `<strong>` yazmak metni
  değiştirmez ama HTML'i şişirir.
- **Durum `reviewing`.** Gerçek bir kişinin adıyla, hiç kimse görmeden yayına
  girmez (§29.4).
- **Özet = gövdenin ilk paragrafı**, iki dilde de. Çevirmen daha uzun bir özet
  üretirse Türkçesiyle hizasız kalıyor (§26.3).

### 35.1 İki tuzak

**Türkçe büyük harf kuralı İngilizceye uygulanamaz.** Başlık büyük harfe
çevrilirken aynı fonksiyon İngilizce başlığa da uygulandı ve
"FROM FİELD TO FUTURE ... İN AGRİCULTURE" çıktı. TR'de `i → İ`, EN'de `i → I`.

**Reddedilmiş kayıt güncellenebilir, yenisini açmak gerekmez.** Aynı yazı daha
önce içe aktarılıp reddedilmişti. Durum `rejected`'ten çıkınca
`articles_forget_rejection_status` tetikleyicisi adresi red hafızasından da
siliyor (§29.1), yani kayıt normal işlemeye dönüyor. Yeni kayıt açmak sitede
biri gizli iki kayıt bırakırdı.

`slug` eski tarihin damgasını taşımaya devam eder ve **düzeltilmez**: adres
yazının kimliği, değiştirilirse paylaşılmış bağlantılar kırılır.

## 36. Kısa notlar

- **Başlıklar Outfit.** Site genelindeki başlık yazı tipi `GoogleFonts.outfit`
  (35 dosya). Puntolar değişmedi, yalnızca aile.
- **PWA güncellenmiyordu.** Tarayıcı yeni sürümü alıyor, PWA eski sürümde
  kalıyordu. `flutter_service_worker.js` → `tarim-offline-v4` + uygulama kabuğu
  için **önce ağ** stratejisi.
- **Çeviri gövdeyi parçalıyor.** `translateTextToEnglish` uzun gövdede adres
  uzunluğu sınırına takılıyordu; metin `</p>` sınırlarından bölünüyor.
- **Tek habere özel grafik kaldırma veri işidir.** Bir haberin infografiği
  istenmiyorsa `chart_data` (ve `chart_data_en`) boşaltılır; dağıtım gerekmez,
  grafik motoruna ve diğer haberlere dokunulmaz. Silinen veri geri istenebilir,
  o yüzden boşaltmadan önce içeriği yazdır.

## 37. Köşe yazısı seslendirmesi — onay, ses, sonra yayın (11 Eylül 2026)

### 37.1 Sistem kurulmuştu ama hiçbir şeye bağlı değildi

`gemini_tts_service.dart` içindeki `generateAndAttachColumnistAudio` doğru
yazılmıştı — sesler, tonlar, dosya yolu yerindeydi — ama **kodda tek bir
çağrı yeri yoktu.** Paneldeki çalışan tek ses düğmesi
`generateAndAttachRadioAudio`, o da haber/radyo bülteni için. Sonuç: 45 köşe
yazısının 42'sinde ses yok ve yazı sayfasındaki "sesli dinle" barı hiç
görünmüyor. Yönetici sesin onayla birlikte geldiğini sanıyordu.

**İkinci kusur sessizdi:** Dart tarafı metni 7000 karakterde KESİYORDU.
Köşe yazıları 9-14 bin karakter; dinleyen kişi yazının ortasında sesin
bittiğini fark ediyor, hiçbir yerde uyarı çıkmıyor.

### 37.2 Akış: `sesleniyor` durumu

```
panel onayı → status = 'sesleniyor' → columnistAudio (5 dk'da bir)
            → ses üretilir, depoya yüklenir → status = 'published'
```

Yazı inceleme kuyruğundan ÇIKTI ama yayında DEĞİL. Okur sesi olmayan bir
köşe yazısı sayfası hiç görmüyor.

**Neden panel değil sunucu:** (a) Gemini anahtarı tarayıcıya inen pakete
gömülemez (§20.6), (b) uzun yazıda seslendirme 8-10 dakika sürüyor ve onaya
basan kişi o kadar bekletilemez.

### 37.3 Üç tasarım kararı

- **Sayaç denemenin BAŞINDA artıyor** (`ses_isine_basla`). Bulut
  fonksiyonunun süresi dolarsa hiçbir kapanış kodu çalışmaz; sayaç sonda
  artsaydı aynı yazı sonsuza kadar yeniden denenirdi. Böylece zaman aşımı da
  bir deneme sayılıyor.
- **İki deneme, sonra SESSİZ yayın** (kullanıcı kararı). Sonsuza kadar
  `sesleniyor`da asılı kalmak, sessiz yayınlanmaktan beterdir — ses bir
  katman, yazının kendisi asıl iş. Neden `ses_hatasi`'na yazılıyor.
- **Çalışma başına TEK yazı.** İki uzun yazı 540 saniyeye (olay tabanlı
  fonksiyon tavanı) sığmaz ve ikincisi boşuna bir deneme harcardı.
  `retryCount: 0` — deneme hakkını veritabanı sayacı yönetiyor, ikisi birden
  olsaydı hak iki katına çıkardı.

### 37.4 Uzun metin: parçala, birleştir, SONRA normalize et

Metin **cümle sınırından** bölünüyor (kelime ortasından bölmek birleşme
noktasında duyulabilir bir kekemelik yapıyor), her parça ayrı seslendiriliyor,
PCM düzeyinde birleştiriliyor. Oynatıcı tek adres aldığı için okuyucuya tek
kesintisiz dosya iniyor.

**Normalizasyon birleştirmeden SONRA, tek seferde.** Parçalar ayrı ayrı
normalize edilseydi ekleme yerinde ses seviyesi duyulur biçimde atlardı.
Değerler (-16 dBFS RMS, -1 dBFS tepe tavanı) Dart tarafıyla aynı.

Aynı iş iki yerde: `functions/index.js` (otomatik akış) ve
`~/tarim_ai_pipeline/src/yazar_sesi.py` (elle/toplu üretim). **Ses seçimi
üçünde de aynı olmak zorunda** — "Sabit Standart": erkek yazarlar Charon,
kadın yazarlar Erinome, İngilizcede de aynı. Ayrışırlarsa aynı yazar iki
farklı sesle okunur.

### 37.5 Karar `approveArticle`'da, çağrı yerlerinde değil

Üç ayrı ekran bu fonksiyonu çağırıyor. Kural dışarıda olsaydı dördüncü çağrı
yeri sessizce kuralın dışında kalırdı. Sesi ZATEN OLAN yazı beklemeye
alınmıyor: tekrar seslendirmek hem gereksiz maliyet hem yayını on dakika
geciktirmek olurdu.

**Yazarın kim olduğu `columnists` tablosundan soruluyor, `content_type`'tan
değil.** O alanda üç ayrı değer dolaşıyordu: `"Köşe Yazısı"`, `kose_yazisi`
(bu oturumda yanlışlıkla eklendi) ve boş. İçerik türüne bakan her süzgeç
listeyi ikiye bölüyordu; 5 kayıt standarda çekildi.

**Bilinen boşluk:** `publish_scheduled_articles()` zamanlanmış yazıyı
doğrudan `published` yapıyor, yani zamanlanmış bir köşe yazısı ses adımını
atlar. Bugüne kadar yaşanmadı; gerekirse o RPC de `sesleniyor`a yönlendirilir.

### 37.6 §4.1 ihlali — uygulanmış migration düzenlendi

`20260911090000_yazar_sesi_yayin.sql` uzaktaki veritabanına uygulandıktan
SONRA düzenlendi (paralel bir oturumun `db push`'u dosyayı yakalamıştı).
Sonuç kısmi şema: sütunlar ve `sesli_yayinla` vardı, iki RPC yoktu — ve hata
sessizdi, çünkü sürüm "uygulandı" sayıldığı için `db push` bir şey yapmıyordu.

Düzeltme kurala uygun yapıldı: uygulanmış dosyaya dokunulmadan yeni bir
migration (`20260911120000`) eksik iki fonksiyonu kurdu, ölü kalanı düşürdü.

**Ders:** `db push` çalıştırıldıktan sonra o migration dosyası KİLİTLİDİR.
Paralel bir oturum varken bu, dosyayı yazdıktan dakikalar sonra bile geçerli
olabilir.

## 38. Bir blogdan köşe yazarı içe aktarma — Ömer DEMİR örneği

### 38.1 Araştırma önce, karar sonra

`omer-demir.net` WordPress ve REST API'si açık, yani teknik olarak kolay.
Ama dört bulgu tabloyu değiştirdi:

- **Blog ölü.** Son yazı 28 Kasım 2023; toplam 52 yazı. Kurulacak bir akış
  yok — bu bir ARŞİV AKTARIMI, besleme değil.
- **İçerik tarım değil.** İktisat, sosyoloji, eğitim reformu. 45 yazının
  yalnızca 6'sında tarım terimi 3'ten fazla geçiyor.
- **Sitede iki yazar var.** 45 yazı hocanın, 7'si başkasının. Ayırmadan
  çekmek başkasının yazısını hocanın adıyla yayınlamak olurdu.
- **Kategori listesinde spam izleri** ("Betmakerz Casino", "betting",
  "Без рубрики") — geçmişte ele geçirilmiş bir WordPress işareti. Yazılar
  şu an temiz ama **otomatik hat kurulmadı** (kullanıcı kararı): site tekrar
  ele geçirilirse spam doğrudan portala akardı.

### 38.2 Kaynak bağlantısı gösterilmiyor — `source_url` BOŞ

Kullanıcı kararı: yazı portalın kendi köşe yazarının yazısı gibi dursun.
Makale sayfasındaki "Orijinal Kaynağa Git" düğmesi `source_url` dolu olduğu
an çıkıyor (`article_detail_screen.dart:312`), o yüzden alan boş bırakıldı.

Bu yalnızca otomatik hat OLMADIĞI için güvenli: mükerrer kontrolü
`source_url` üzerinden yürüyor (§24.6) ve tek seferlik alımda mükerrer diye
bir şey yok. Kaynağın adresi `content_licenses` kaydında duruyor — izin
kaydı olmadan içe aktarma yapılmıyor (§29.4).

### 38.3 Metne dokunulmuyor, KABUĞU temizleniyor

- **Sözlük bağlantıları çözüldü.** Bir eklenti her yazıya 70-100 arası
  `sosyalbilimlervakfi.org` bağlantısı gömmüş. `<a>` sarmaları kaldırıldı,
  kelimeler yerinde kaldı.
- **Künye satırı silindi.** Gövdenin ilk paragrafı "ÖMER DEMİR"di ve yazı
  sayfasında yazarın adı zaten yazıyor. Silme YALNIZCA baştaki paragrafla
  sınırlı: metnin içinde adı geçiyorsa dokunulmuyor.
- **Özetler de künyeliydi.** `summary`/`spot` gövdenin ilk 400 karakterinden
  türetiliyor; künye oradayken üretildikleri için kartlarda "ÖMER DEMİR"
  görünüyordu. Gövdeyi düzeltmek YETMİYOR, türev alanlar da yenilenmeli.
- **Dizi ayrı bölümler olarak.** Dört parçalı yazı birleştirilmedi; her
  bölüm ayrı yazı, tarihler eskiden yeniye (son bölüm bugün, öncekiler
  haftalık geriye) — okur diziyi sırayla okuyor.

### 38.4 Yazar kaydı YAZILARDAN ÖNCE açılır

`kaynak_yazar_olmasin` tetikleyicisi (§34) aynı adla 3+ haber varsa kaydı
reddediyor. Yazıları önce eklemek bu yüzden kaydı engelledi. Doğru sıra:
önce yazar, sonra yazıları.

### 38.5 Görsel kaynağı

- **Metropolitan Museum açık erişim API'si** (anahtarsız,
  `isPublicDomain=true`): gerçek çizim ve gravür, telif kısıtı ve atıf
  zorunluluğu yok. Eskiz istendiğinde ilk tercih.
  **Tuzak:** "charity/almsgiving" araması ağırlıkla Hristiyan alegorisi ve
  çıplak figür getiriyor. Sorgu seküler ve kırsal temaya çekilmeli
  ("peasants", "village life", "harvest") ve sonuçlar gözle elenmeli.
  Yelpaze/madalyon biçimli eserler siyah zemine oturuyor; dikdörtgen kapakta
  köşelerde bant kalıyor — köşelerden taşkın dolguyla zemin krem yapılıyor,
  dikdörtgen kırpma bunu çözmüyor.
- **Unsplash** (`UNSPLASH_ACCESS_KEY`, hatta kayıtlı): fotoğraf gerektiğinde.

## 39. Dosya haberi — TKDK örneği ve tasarım istisnası (16 Eylül - 2 Ekim 2026)

Bir kurumun gönderdiği bilgi notu + 19 saha fotoğrafından üretilen uzun haber.
Biçim seçimi tartışıldı ve **Kurum Dosyası dizisi REDDEDİLDİ**: o dizinin
görsel dili "Evrak" (tipografik kapak, belge), fotoğraf oraya girmiyor (§8.4)
ve Ziraat dosyasında fotoğraf kapak zaten bilerek reddedilmişti (§8.8).
Elimizdeki en güçlü varlık fotoğraflardı. Seçilen biçim: `content_type`
**"Rapor"**, bizim kalemimizden, üçüncü şahıs, rakamlar kuruma atıflı.

### 39.1 Sınıfa bağlı stil — tek habere özel tasarım

`flutter_html` stil haritasını **tam CSS seçicisiyle** eşleştiriyor
(`tree/styled_element.dart` → `matchesSelector` → `matches(element, selector)`).
Yani stil anahtarı `.sinif` olabiliyor.

Bu, "yalnızca bu haber farklı görünsün" isteğinin temiz çözümü: stiller
`article_detail_screen.dart` içinde `.dsy-kunye`, `.dsy-h2`, `.dsy-alinti`,
`.dsy-foto` olarak tanımlı; sınıflar **yalnızca o haberin gövdesinde** var.
Kodda haber kimliği yok, veritabanında yeni sütun yok, diğer 900+ haber
etkilenmiyor. Yeni bir dosya haberi aynı sınıfları kullanır.

### 39.2 Izgara galeri HTML olarak mümkün DEĞİL

Gövde `flutter_html` ile çiziliyor; görseller alt alta diziliyor, yan yana
ızgara kurulamıyor. On iki kareyi tek tek koymak "tepih" görünümü yaptı.

Çözüm: **kompoze ızgara görseli** — kareler Pillow ile 2 sütun × 3 satır tek
bir JPEG'e yerleştiriliyor. Hem masaüstünde hem telefonda ızgara gibi
görünüyor. **İki sütun**, üç değil: üç sütunda telefonda hücre 110 pikselin
altına düşüp okunmaz oluyor.

Kareler tek tek görülebilsin diye gövdedeki her görsele **dokununca tam
ekran** eklendi (`InteractiveViewer`, 5 kata kadar).

### 39.3 Grafik kapak — manşette kırpılmaz, başlık basılmaz

Kapak bir fotoğraf değil de yazı taşıyan bir GRAFİKSE iki şey bozuluyor:
`BoxFit.cover` kenardaki öğeleri kesiyor ve üstüne manşet başlığı binince iki
metin üst üste geliyor.

Ayrım **dosya adından** okunuyor: adında `_grafikkapak` geçen kapakta
`hero_fold.dart` `BoxFit.contain` kullanıyor, zemini beyaza boyuyor, başlık
ve degrade katmanını hiç çizmiyor. Koda haber kimliği gömülmedi; yeni bir
grafik kapak yalnızca doğru adla yüklenir.

Kapak 1200×630'a **kırpılarak değil sığdırılarak** üretiliyor
(`normalize_for_social` kullanılmıyor): grafiklerde logo ve balon kuyrukları
kenara yakın.

### 39.4 Gövde görseli telefonda ekrandan taşıyordu

`govde_gorseli.dart` çizim genişliğini paragrafın kısıtından alıp okuma oluğu
için 800'e sınırlıyordu. Telefonda kısıt yine 800 geliyor ve görsel 375
piksellik ekranın dışına taşıp **iki yandan kırpılmış** görünüyordu.
Masaüstünde görünmeyen bir kusur. Genişlik artık ekran genişliğini aşamıyor.

### 39.5 Metin denetimi tahminle değil ölçümle

Kurum metni "hiçbir ifade atlanmasın" koşuluyla yazıldı. İlk sürüm beş yeri
atlamıştı. Kapsama **ölçüldü**: bilgi notunun her paragrafından ayırt edici
"çapa" terimler çıkarılıp yazıda arandı (89 çapa).

**Türkçe tuzağı:** Python'da `'İ'.lower()` birleşik noktalı bir karakter
üretiyor ve eşleşmeyi sessizce düşürüyor. Beş "eksik" bu yüzden yanlış
alarmdı. Karşılaştırmadan önce `İ→I`, `ı→i` dönüşümü ve `NFD` ile
birleştirici işaretlerin atılması gerekiyor.

Word belgesinden gelen yazılarda yayın sonrası **birebir denetim** yapılıyor:
belge sıfırdan okunup sıra, tür (başlık/paragraf) ve metin karakter karakter
karşılaştırılıyor.

### 39.6 Yayındaki gövdeden bir şey silerken desen körlemesine uygulanmaz

Ali Kemal ASLAN'ın yazısından fotoğraf künyelerini silerken
`<p class="dsy-foto">.*?</p>` deseni künyeyi değil **sonraki paragrafı**
yakaladı ve üç gövde paragrafı yayındaki metinden silindi. Hata, silinenler
ekrana basıldığı için fark edildi.

Kural: yayındaki bir gövdeden silme yapılmadan önce desenin **kaç şeyle ve
NEYLE** eşleştiği yazdırılır ve doğrulanır. Düzeltme tahminle değil, metni
kaynak belgeden **yeniden kurarak** yapıldı.

Aynı dersin ikinci uygulaması: galeri başlığına görsel eklerken desen Türkçe
metni arıyordu, İngilizce gövdede "Glimpses of Projects" diye çevrildiği için
sıfır eşleşti — `assert` durdurdu, hiçbir şey yazılmadı. **Her iki dil için
ayrı metin aranır; iki dilde başlıklar birebir aynı değildir.**

### 39.7 Özet kesmek: kısaltmalar cümle sonu değildir

Spot, gövdenin ilk paragrafından 400. karakterde kesiliyordu ve kelimenin
ortasında bitiyordu. Cümle sınırına çekilince bu sefer **"Dr."** kısaltmasını
cümle sonu sandı ve "…TKDK Başkanımız Dr." diye bitti.

Nokta, ancak ardından büyük harfle yeni kelime geliyorsa **ve** öncesindeki
parça bilinen bir kısaltma (`dr`, `prof`, `sn`, `doç`, `av`, `vb`, `örn`…)
DEĞİLSE cümle sonu sayılır.

Spot gövdede **tekrarlanmaz**: başlığın altında zaten duruyor, gövde onunla
başlayınca okur aynı cümleyi iki kez okuyor. Gövdenin ilk paragrafından spot
cümlesi düşülüyor.

### 39.8 iCloud dördüncü kez — artık deploy.sh kendi çözüyor

`web/dosya/ispanya/*.jpg` buluta atılmıştı; derleme `errno 60 — Operation
timed out` ile düştü (§1'deki tuzağın aynısı). `web/` altındaki dosyaları
okumak iCloud'a indirmeyi tetikliyor ve sorun geçiyor.

Bu adım `deploy.sh`'a eklendi: derlemeden önce varlıklar okunuyor, okunamazsa
20 saniye bekleyip bir kez daha deneniyor, yine olmazsa **dağıtım duruyor** —
yarım bir paketle sessizce yayınlamaktansa durması doğru.

**`web/` için `.nosync` YAPILMADI ve yapılmamalı:** klasör git tarafından
izleniyor (113 dosya, `.gitignore`'da değil). Taşınıp yerine sembolik bağ
konsaydı git `index.html`, dosya görselleri, ikonlar ve SSR işaretleri dahil
hepsini silinmiş görürdü. `node_modules`'de sorun yoktu, orası zaten yok
sayılıyor.

**Teşhis notu:** macOS'ta `timeout` komutu YOK. Dosya okunabilirliğini
sınarken kullanıldı ve her şey okunamıyormuş gibi göründü; `head -c` ile
bakılınca hepsinin okunduğu ortaya çıktı.
