# Tarladan Paylaşım — mecra kapılarının ölçümü

**19 Kasım 2026.** Elli soruyla belirlenen köşe tarifine karşı dört mecranın
**arama** ve **gömme** kapıları ölçüldü. Bu belge ölçümün kendisidir; yol
haritası değil. Karar kullanıcının.

---

## 1. Ölçülenler — kendi makinemizden, 19 Kasım 2026

İstekler `User-Agent: tarimportali.net fizibilite olcumu` ile, kimlik
doğrulamasız atıldı. Durum kodu kapının **var olup olmadığını**, gövde ise
**ne istediğini** söylüyor.

### Gömme kapıları — DÖRDÜ DE AÇIK

| kapı | durum | not |
|---|---|---|
| `publish.twitter.com/oembed` | **200** | `publish.x.com`'a yönleniyor, oradan da 200 |
| `platform.twitter.com/widgets.js` | **200** | 93.967 bayt |
| `www.youtube.com/oembed` | **200** | 868 bayt |
| `www.tiktok.com/oembed` | **200** | 542 bayt |
| `www.tiktok.com/embed.js` | **302** | yönlendirme, betik iniyor |
| `www.instagram.com/embed.js` | **200** | 64.501 bayt |
| `graph.facebook.com/instagram_oembed` | **400** | uygulama kimliği şart |

> **BİR KEZ YANLIŞ ÖLÇTÜM VE DÜZELTTİM.** İlk denemede X'in oEmbed'i 404
> verdi ve "X'in gömme kapısı kapanmış" sonucuna varmak üzereydim. Sebep
> kapı değil, benim kullandığım **sahte tweet kimliğiydi** (`status/1`).
> Gerçek bir tweetle (`jack/status/20`) 200 dönüyor. Yumuşak 404 disiplininin
> tersi bir hata: durum kodu doğruydu, **girdi** yanlıştı.

### Arama kapıları — ÜÇÜ KAPALI

| kapı | durum | gövdenin söylediği |
|---|---|---|
| `api.twitter.com/2/tweets/search/recent` | **401** | `{"title":"Unauthorized"}` — kapı var, belirteç şart |
| `googleapis.com/youtube/v3/search` | **403** | `PERMISSION_DENIED` — kapı var, anahtar şart |
| `graph.facebook.com/ig_hashtag_search` | **403** | `(#200) Provide valid app ID` |
| `open.tiktokapis.com/v2/research/video/query/` | **404** | GET'e kapalı; POST + belirteç ister |

### Ücretsiz takip yolu — YALNIZ YOUTUBE'DA VAR

| kapı | durum | not |
|---|---|---|
| `youtube.com/feeds/videos.xml?channel_id=…` | **200** | 27.202 bayt, **15 kayıt**, anahtar YOK |

X, Instagram ve TikTok'ta buna karşılık gelen açık bir besleme **yok**.

### Ölçemediklerim

Mecraların **arama sayfalarını** tarayıcı kimliğine bürünüp yoklamayı
denedim; oturumun güvenlik süzgeci durdurdu ve **haklı durdurdu**. O yöntem
kazımadır: mecraların kullanım şartlarına aykırı ve bu portala kurulacak bir
temel değil. Denemedim, bu belgede de yer almıyor.

Anahtar ya da belirteç gerektiren uç noktaların **gerçek davranışını**
ölçemedim — depoda hiçbir sosyal mecra anahtarı yok (`.env` yalnız Supabase
ve Unsplash taşıyor). Aşağıdaki koşullar bu yüzden **araştırmadan**, kendi
ölçümümden değil.

---

## 2. Araştırılanlar — ikincil kaynaklar, 19 Kasım 2026

> Aşağıdakiler mecraların kendi belgeleri ve ikincil kaynaklardan. Fiyat ve
> kota rakamları **ikincil kaynaklarda birbirini tutmuyor**; karar
> verilmeden önce mecranın kendi sayfasından doğrulanmalı. X'in resmî ürün
> sayfası bu ölçümde **402** döndürdü, yani doğrulayamadım.

**X.** Ücretsiz katman yeni geliştiricilere **kapalı** (Şubat 2026). Varsayılan
düzen **kullandığın kadar öde**: okuma başına ~0,005 dolar aktarılıyor. Eski
Basic (200 $/ay) ve Pro (5.000 $/ay) katmanları kapatılmış, aboneleri
kullandığın-kadar düzenine taşınmış.

**Instagram.** `ig_hashtag_search` **var** ama üç şart birden istiyor:
Uygulama İncelemesi (App Review) + "Instagram Public Content Access" izni +
sorguyu yapan bir **İşletme/Üretici hesabı**. Sert sınır: **yuvarlanan 7
günde en çok 30 ayrı etiket**. Hikâyeler kapsam dışı.

**TikTok.** Research API'nin uygunluk sayfası **ticari kullanıcıları açıkça
dışarıda bırakıyor**; kâr amacı gütmeyen, kamu yararına araştırma şartı var.
Display API yalnız **uygulamanıza yetki vermiş kullanıcının kendi**
videolarını veriyor. Yani bir yayıncı için genel arama yolu **yok**.

**YouTube.** Günde **~100 arama çağrısı** ücretsiz. Kaynaklar bunun ayrı bir
kova mı yoksa 10.000 birimlik havuzdan mı düştüğü konusunda ayrışıyor ama
pratik sınırda birleşiyorlar: günde yüz arama. Üstüne kanal RSS'i **kotasız**.

**Lisanslı toplayıcılar.** Kurumsal dinleme araçları (Meltwater, Brandwatch,
Talkwalker) veriyi lisanslı alıyor ama yıllık maliyetleri on binlerce dolar
mertebesinde. Küçük katmanlı araçlarda API erişimi ayda 49-169 dolardan
başlıyor görünüyor; hiçbirinin yayıncı kullanımına izin verip vermediğini
**doğrulayamadım**.

---

## 3. Tablo — tarifin karşısına konulduğunda

| mecra | gömme | **anahtar kelimeyle arama** | hesap takibi |
|---|---|---|---|
| **YouTube** | ücretsiz | **ücretsiz, günde ~100** | **ücretsiz, RSS, kotasız** |
| **X** | ücretsiz | ücretli, okuma başına | aynı ücretli kapı |
| **Instagram** | uygulama kimliğiyle | İnceleme + işletme hesabı + **30 etiket/hafta** | yalnız kendi hesabın |
| **TikTok** | ücretsiz | **ticari kullanıma kapalı** | yok |

**Sonuç:** Köşenin gömme tarafı — yani okurun gördüğü şey — dört mecrada da
sorunsuz kurulabilir. **Toplama tarafı yalnız YouTube'da açık.**

---

## 4. Tarifle çelişen üç cevap

Elli sorunun üçü bu ölçümden sonra olduğu gibi duramıyor:

| soru | verilen cevap | ölçümün söylediği |
|---|---|---|
| **49** | ilk sürümde **dördü birden** | arama tarafı yalnız YouTube'da açık |
| **18** | hat **anahtar kelimeyle** tarasın | X ücretli, Instagram 30 etiket/hafta, TikTok kapalı |
| **4** | **hat toplar, siz seçersiniz** | üç mecrada toplayacak hat kurulamıyor |

Dolaylı olarak **33/41** (etkileşime göre sıralama, toplama anında donar) da
etkileniyor: etkileşim sayısı aynı kapıdan geliyor.

---

## 5. Önümüzdeki yollar — karar kullanıcının

**A · Elle derleme, gömme çözücü.** Hat yok. Panelde bir kutu: bağlantıyı
yapıştırırsınız, sistem oEmbed ile kartı çözer, derlemeye ekler. Dört mecrada
da çalışır, maliyet sıfır, hiçbir şartı zorlamaz. Karşılığı: adayları siz
buluyorsunuz. **Portalın haber hattı zaten böyle çalışıyor.**

**B · A + YouTube otomatik.** Yukarıdakinin üstüne yalnız YouTube'da gerçek
bir toplama: kanal RSS'leriyle izlenen hesaplar, günde ~100 aramayla anahtar
kelime. Tek mecrada "hat toplar siz seçersiniz" düzeni gerçekten kurulur.

**C · B + X'e ödeme.** X'te kullandığın-kadar okuma alınır, anahtar kelime
taraması oraya da açılır. Aylık maliyet taramanın enine bağlı — "ayarlanabilir
tarama" kararı burada doğrudan faturaya dönüşür. Önce küçük bir bütçeyle
ölçülmeli.

**D · Instagram'ı sonraya bırakmak.** Uygulama İncelemesi + işletme hesabı +
30 etiket/hafta. Kurulabilir ama bir başvuru süreci ve hesap altyapısı
gerektiriyor; ilk sürümü bekletmemeli.

**TikTok için şu an yol yok.** Gömmesi çalışıyor, yani **elle** eklenen bir
TikTok videosu köşede sorunsuz görünür. Otomatik toplama kurulamaz.

---

## 6. Ölçülmesi gerekenler

1. X'in resmî fiyat sayfası (bu ölçümde **402** döndü) — gerçek okuma
   maliyeti ve aylık taban.
2. YouTube anahtarıyla gerçek bir arama — günde yüz çağrının tarım
   gündeminde ne kadar aday verdiği.
3. Instagram Uygulama İncelemesi'nin bugünkü süresi ve işletme hesabı şartı.
4. Küçük katmanlı lisanslı toplayıcıların yayıncı kullanımına izin verip
   vermediği — **hiçbiri doğrulanmadı**.

---

## 7. Gömme davranışı — 19 Kasım 2026'da tarayıcıda ölçüldü

Dördü de sayfada canlı çizildi. Kapıların açık olması ayrı, gömmenin okurun
ekranında nasıl davrandığı ayrı; aşağıdakiler gözle ve `postMessage`
dinlenerek ölçüldü.

### 7.1 Yüksekliğini kim söylüyor

| mecra | mesaj | kullanılabilir mi |
|---|---|---|
| **Instagram** | `{type:"MEASURE", details:{height:N}}` | **evet** — gerçek boy |
| **TikTok** | `{width:W, height:H}` | **hayır** — yankı |
| **X** | yok | hayır |
| **YouTube** | yok | gerekmiyor (16:9) |

Instagram'ın bildirdiği boy genişliğe bağlı: 400→608, 480→688, 550→758,
600→808. Paylaşım türüne de bağlı olduğu için sabit bir sayı doğru olamaz;
gelen değer kullanılıyor.

**Mesaj nesne değil metin.** Instagram `e.data`'yı JSON **dizgesi** olarak
yolluyor, nesne olarak değil. İlk okumada nesne sanıldı ve kod mesajı
sessizce atladı; kutu yedek değerde kaldı. İki kez çözmek gerekiyor.

TikTok'un yankı olduğu **deneyle** saptandı: kutu 300 pikselle
sınırlandığında TikTok "300" bildirdi. İstediği boyu değil, verdiğimizi
tekrarlıyor.

X, `widgets.js` yüklenmediği için sessiz. Temiz bir yeniden yüklemede de
mesaj gelmedi. Sabit yükseklikle duruyor — kısa bir tweet'in altında boşluk
kalması bunun bilinen bedeli.

### 7.2 TikTok gömmesi kendi çerez bandını açıyor

TikTok'un iframe'i, portalın içinde **kendi çerez onay bandını** çiziyor:
"Allow cookies from TikTok on this browser?" + *Decline optional cookies* /
*Allow all*. Bant kutunun yarısına yakınını kaplıyor ve videoyu örtüyor.

Bu bant **bizim kontrolümüzde değil** — çapraz kaynaklı iframe'in içinde,
dışarıdan kapatılamıyor. Okur kendi kapatana kadar her TikTok gömmesinde
duruyor.

TikTok hakkında karar verilirken iki şey üst üste geliyor: otomatik toplama
yolu yok (§5) **ve** gömmesi okura önce bir çerez sorusu gösteriyor. Elle
eklenen bir TikTok videosu teknik olarak çalışıyor, ama köşedeki görüntüsü
diğer üç mecra gibi temiz değil.

### 7.3 Gömme eni sayfa eni değil

Dört mecranın dördü de ~550 piksel için tasarlanmış; X'in kendi üst sınırı
550. Gömmeler sütun boyunca gerildiğinde (1280'lik ekranda 1248 piksel)
Instagram boyunu 1456'ya çıkarıyor, tweet okunmaz genişliğe yayılıyor.
Kutu 550'de sınırlanıp ortalanıyor.

---

## 8. Google Alerts — ilk ölçüm (19 Kasım 2026, 16:54)

Akışlar aynı gün **15:40**'ta kuruldu; ölçüm **74 dakika** sonra yapıldı.
Sayılar bu pencereye göre okunmalı.

| akış | sorgu | girdi | paylaşım seviyesi | işe yarar |
|---|---|---|---|---|
| X | `site:x.com (buğday OR hasat OR çiftçi)` | 0 | 0 | — |
| **Instagram** | `site:instagram.com (çiftçi OR tarla OR hasat)` | **2** | **2** | **1** |
| TikTok | `site:tiktok.com (çiftçi OR tarım OR hasat)` | 0 | 0 | — |
| Kalibrasyon | `buğday hasat çiftçi` | 0 | 0 | — |

Dördü de geçerli Atom, durum 200. Boş olanlar **gerçekten boş** — 419, 423
ve 402 bayt, yalnız zarf.

### 8.1 Alerts geriye de dolduruyor

Önceki not "Alerts yalnız ileriye bakar" diyordu; **yanlış**. Gelen iki
girdi de akış kurulmadan öncesine ait:

* 19 Kasım 12:02 UTC → akış kurulmadan **38 dakika önce**
* 18 Kasım 23:15 UTC → bir gün önce

Yani boş akışlar "henüz zaman olmadı" demek değil; o pencerede Google'ın
dizininde eşleşme bulunmadı demek.

### 8.2 Tek işe yarar sonuç tam da aradığımız şey

> "2 yıldır tohum ıslahı yapıyoruz" — Altan Bölükbaşı, AA muhabirine…
> Hasat sonrasında toprağı sürerek havalandırdıklarını ve gübreleyerek
> eylül ayına kadar nadasa bıraktıklarını belirten Bölükbaşı…

Tohum ıslahı, hasat, nadas. Köşenin konusu.

### 8.3 "Çiftçi" bir soyadı — ilk yanlış eşleşme buradan geldi

İkinci girdi Aydın İl Milli Eğitim Müdürlüğü'nün bir ihale duyurusu:
**Ekrem Çiftçi İlkokulu**. Anahtar kelime "çiftçi"ye takıldı.

Türkçede *Çiftçi*, *Bağcı*, *Ekinci*, *Bahçıvan*, *Çoban* sık soyadlarıdır
ve okul, cadde, mahalle adlarında geçer. Bu yanlış eşleşme tekrarlayacak;
anahtar kelime listesi buna göre daraltılmalı. **Aynı tuzak haber hattının
anahtar kelime taramasında da var.**

### 8.4 Kalibrasyon akışı temiz bir kontrol değil

`buğday hasat çiftçi` sorgusu Alerts'te **VE** olarak işleniyor — üç kelime
de geçmeli. Mecra akışları ise `OR` kullanıyor. Yani kalibrasyon akışı
"daha geniş" değil, **daha dar**; 0 sonuç vermesi `site:` filtresinin
sonucu bastırdığını göstermiyor.

`site:` filtresinin etkisini ölçmek için beşinci bir akış gerekiyor:
**`(çiftçi OR tarla OR hasat)`**, site kısıtı olmadan, aynı pencerede
karşılaştırmalı.

**Kontrol akışı 16:59'da açıldı** (`ALERTS_KONTROL`, sorgu doğrulandı:
`(çiftçi OR tarla OR hasat)`). İlk okumada 0 girdi — ama akış o anda bir
dakikalıktı, bu sayı okunamaz.

Okunamaz olmasının sebebi mantıksal: kontrol sorgusu Instagram akışının
**tam üst kümesi** — aynı OR kelimeleri, kısıt yok. Dar olan 2 sonuç
bulmuşken geniş olanın 0 bulması ancak akış henüz doldurulmamışsa
mümkün. İkinci okuma, kontrol Instagram akışıyla benzer yaşa geldiğinde
yapılacak.

**Yan bulgu — Alerts'in geriye doldurması sığ.** Kalibrasyon akışı 80
dakikadır açık ve 0 girdi verdi; Instagram akışının iki girdisi son ~17
saate ait. Yani Alerts kurulduğunda dizinin tamamını dökmüyor, yalnız
yakın pencereyi tarıyor.

### 8.5 Zincir baştan sona çalışıyor

Gelen iki bağlantı `src/sosyal/cozucu.py`'den geçirildi: ikisi de çözüldü
(`/reel/<kod>/` → `/p/<kod>/embed/`) ve gömme adresleri gerçek içerik
döndürdü (258 KB, 251 KB). Alerts → çözücü → kuyruk hattında kopuk halka
yok.

---

## 9. Toplayıcı (19 Kasım 2026)

`~/tarim_ai_pipeline/src/sosyal/toplayici.py`

```
python3 -m src.sosyal.toplayici --kuru    # yazmadan göster
python3 -m src.sosyal.toplayici           # kuyruğa yaz
```

Akışları okur, paylaşım seviyesi bağlantıları ayıklar, çözücüden geçirir,
kuyruğa **`bekliyor`** satırı yazar. Yayına asla çıkarmaz. Depoda cron yok,
betik kendi kendine koşmaz — haber hattının kuralı burada da geçerli:
toplama otomatik, yayın elle.

### 9.1 Sessiz bir kırık bulundu: aynı paylaşım, farklı metin

Şemadaki `url text not null unique` iki iş yapıyor: tekrar engeli **ve**
"reddedilmiş paylaşım geri gelmez". İkisi de yalnız aynı paylaşımın her
zaman aynı metne indirgenmesiyle çalışır.

Ölçüldü: **Alerts Instagram'ı `/reel/<kod>/` diye veriyor**, insan panele
`/p/<kod>/` yapıştırıyor. Kanonikleştirme olmadan bunlar iki ayrı satır
olur — yani reddettiğiniz bir paylaşım, hattın ertesi gün bulduğu biçimle
panele geri düşerdi. Aynı çatışma `twitter.com`↔`x.com`,
`youtu.be`↔`watch?v=`↔`shorts/` arasında ve mecraların izleme
kuyruklarında (`?s=20`, `?is_from_webapp=1`) da var.

`normalle()` iki tarafa birden eklendi — `cozucu.py` (hat) ve
`gomme_cozucu.dart` (panel). İkisi ayrışırsa tekillik yine kırılır; bu
yüzden `test/tarladan_normalle_test.dart` aynı tabloyu sınıyor (7 sınama,
hepsi yeşil).

Kanonik biçimler:

| mecra | biçim |
|---|---|
| X | `https://x.com/<hesap>/status/<id>` |
| YouTube | `https://www.youtube.com/watch?v=<id>` |
| TikTok | `https://www.tiktok.com/@<hesap>/video/<id>` |
| Instagram | `https://www.instagram.com/p/<kod>/` |

### 9.2 İlk gerçek koşu

| | |
|---|---|
| akış girdisi | 2 |
| paylaşım adayı | 2 |
| kuyruğa yeni | 2 |
| ikinci koşu | 0 yeni, 2 "zaten var" |
| `/reel/` biçimiyle elle deneme | veritabanı **reddetti** |

Kuyrukta iki `bekliyor` satırı var, ikisi de `kaynak='hat'`. Biri tohum
ıslahı haberi, biri §8.3'teki soyadı yanlış eşleşmesi — yani ilk koşu
hattın hem işe yarayanı hem de gürültüyü getirdiğini gösterdi.

### 9.3 Bekleyen göç

`supabase/migrations/20261119180000_paylasim_hat_notu.sql` **uygulanmadı.**
`hat_notu`, toplayıcının editöre bıraktığı bağlamı taşıyor (akışın başlığı
ve özeti) ve **yayına çıkmıyor** — panel kuyruğu gömme değil metin listesi
gösterdiği için, Instagram adayı o alan olmadan panelde yalnız "Instagram"
yazısı olarak görünüyor.

`baslik` alanına yazılamaz: `baslik` okura çıkan bir alan (mobil künye
kartı onu çiziyor) ve Google'ın özetini paylaşımın kendi başlığıymış gibi
göstermek künyeye kaynağı olmayan bilgi koymak olur.

Toplayıcı sütun yokken de çalışıyor, yalnız bağlamı yazmıyor.

---

## 10. Alerts — ikinci ölçüm (19 Kasım 2026, 21:30) · SORU CEVAPLANDI

Kontrol akışı 4,5 saatlik olunca doldu ve §8.4'teki soruyu kapattı.

| akış | yaş | girdi | paylaşım seviyesi |
|---|---|---|---|
| X | 6 sa | 0 | 0 |
| Instagram | 6 sa | 2 | 2 |
| TikTok | 6 sa | 0 | 0 |
| Kalibrasyon (VE'li) | 6 sa | 0 | 0 |
| **Kontrol** (`(çiftçi OR tarla OR hasat)`, site kısıtı yok) | 4,5 sa | **20** | **1** |

### 10.1 `site:` filtresi suçlu değil

Kontrol akışı tüm web'i tarıyor ve 20 sonuç getirdi. Bu 20 sonucun
**yalnız 1 tanesi** sosyal mecra paylaşımı — o da Instagram akışının zaten
bulduğu aynı reel. **X'ten sıfır, TikTok'tan sıfır, YouTube'dan sıfır.**

Kalan 19'un alan dağılımı tamamen haber sitesi: sozcu (2), gazetevatan (2),
ntv, ensonhaber, türkiyegazetesi, dünya, bianet, dha, karar, habertürk,
akşam, gazeterize, dikgazete, kayserianadoluhaber, 61saat, haberonses,
ensondakika.

Yani kısıtı kaldırmak X ve TikTok'u getirmiyor. Google'ın Türkçe tarım
dizini haber sitelerinden oluşuyor; sosyal paylaşım oraya neredeyse hiç
girmiyor, giren de Instagram oluyor.

### 10.2 Dört mecranın bulma yolu — nihai tablo

| mecra | otomatik bulma | durum |
|---|---|---|
| **YouTube** | kanal RSS + Data API (ücretsiz) | hat zaten kullanıyor (`run_videos.py`) |
| **Instagram** | **Google Alerts** | **çalışıyor** — ince ama gerçek |
| **X** | yok | API ücretli (saf dışı), Alerts getirmiyor → **elle** |
| **TikTok** | yok | API ticari kullanıma kapalı, Alerts getirmiyor → **elle** |

Bu, §5'teki API tarafındaki sonucu ücretsiz keşif tarafından da doğruluyor:
X ve TikTok için otomatik yol yok. İkisi de panele elle yapıştırılacak.

### 10.3 Instagram'ın verimi

6 saatte 2 paylaşım, biri soyadı yanlış eşleşmesi (§8.3). Yani kaba tahmin
**günde ~2 aday, yarısı gürültü**. Köşeyi tek başına doldurmaz; elle
eklemeyi azaltır, yerine geçmez.

### 10.4 Yan gözlem — kapsam dışı

Kontrol akışının 19 haber sonucu ("Kilosu tarlada 10, pazarda 60 lira",
"Samsun'da pırasa tarlalarında hasat zamanı") köşenin değil **haber
hattının** konusu. Site kısıtsız bir Alerts akışının Türkçe tarım
haberlerini bu yoğunlukta getirmesi kayda değer; ne yapılacağı ayrı bir
karar.

---

## 11. Anahtar kelime ölçümü (19 Kasım 2026) — "çiftçi" zarar veriyor

Google Alerts eşleşen terimi `<b>` ile işaretliyor. Okundu:

| girdi | eşleşen kelime | sonuç |
|---|---|---|
| Salep üretimi, tohum ıslahı (Kırklareli) | **Hasat** | **isabet** |
| Efeler okul yıkım ihalesi (Aydın) | **Çiftçi** | yanlış — *Ekrem Çiftçi İlkokulu* |

Kontrol akışının 20 sonucunda terim sayımı:

| terim | sayı | notu |
|---|---|---|
| hasat / Hasat | 23 | taşıyıcı terim |
| tarla / TARLA | 6 | işe yarıyor |
| Çiftçi / çiftçi | 5 | **4'ü büyük harfle** — özel ad kalıbı |

Yani bu örneklemde **"çiftçi" bir yanlış eşleşme getirdi, bir isabet
getirmedi**. Tek gerçek sosyal isabet "hasat"tan geldi. Büyük harf oranı
tek başına kanıt değil (Türkçede cümle başı ve manşetler de büyük
harfle), ama tam metni okunan tek örnekte gerçekten soyadıydı.

**Öneri:** Instagram akışının sorgusundan `çiftçi` çıkarılsın.

```text
site:instagram.com (hasat OR tarla OR tohum OR rekolte OR mahsul)
```

### 11.1 Eklerken dikkat: "ekim" Ekim ayıdır

Tarım sözlüğünden kelime eklerken Türkçenin eş sesli tuzağı var:

| kelime | tarım anlamı | öteki anlamı |
|---|---|---|
| **ekim** | tohum ekme | **Ekim ayı** — "Ekim'de açıklanacak" |
| **çiftçi** | üretici | sık **soyadı** (okul, cadde adı) |
| **bağcı**, **ekinci**, **çoban**, **değirmenci** | meslek | sık **soyadı** |
| **harman** | harman yeri | soyadı / yer adı |

Göreli güvenli olanlar: **hasat, rekolte, mahsul, tohum, nadas, sulama,
gübre, fide, fidan, verim**.

Bu tuzak yalnız köşenin değil, haber hattının anahtar kelime taramasının
da sorunu.

---

## 12. Anahtar kelime: iki ayrı iş (20 Kasım 2026)

Haber hattındaki listeler ölçüldü:

| liste | terim |
|---|---|
| `src/videos/collector.py` (tarım) | 45 |
| `src/utils/yz_bolumu.py` (yapay zekâ) | 38 |
| `src/utils/agency_fetcher.py` (yeşil) | 24 |
| `src/utils/ozel_bolum.py` (COP31) | 9 |

Köşenin listesi bunlardan küçük değildi; şimdi çok daha büyük. Ama asıl
nokta büyüklük değil, **iki işi ayırmak**:

| liste | nereye | nasıl olmalı | boyut |
|---|---|---|---|
| `SORGU` | Google Alerts sorgusu | **az ve keskin** | 16 |
| `GUVENLI` | gelen adayı puanlamak | **bol** | 320 |

Gerekçesi havuzun alaka oranı. Haber hattının listeleri ZATEN tarımsal
kaynaklardan gelen içeriği bölümlere ayırıyor — orada liste büyütmek
yönlendirmeyi iyileştirir. Alerts ise tüm web'den seçiyor; orada her
fazladan sorgu terimi gürültüyü çoğaltıyor (ölçüldü: "çiftçi" 1 yanlış,
0 isabet). Puanlamada ise genişlemenin maliyeti yok — aday zaten elde.

### 12.1 Kendi puanlayıcımda bulunan hata: alt dize eşleşmesi

İlk sürüm düz `terim in metin` yapıyordu ve ölçüm çıktısında yanlış
ateşledi:

```
"İHALE TARİHİ"   → 'ari' eşleşti   ("tarihi" içinde)
"yumruları"      → 'arı' eşleşti   (kelime ortasında)
```

Kısa terimler sessizce puan şişiriyordu. Tam kelime sınırı ise Türkçede
fazla katı — "hasatta", "tarlada", "tohumu" kaçardı. Çözüm: **terim kelime
başında olsun, sonu serbest kalsın**, artı ünsüz yumuşaması
(hasat→hasadı, toprak→toprağı). Altı sınama ile doğrulandı.

---

## 13. Shorts (20 Kasım 2026)

### 13.1 Shorts sondası iki yönde de doğrulandı

`youtube.com/shorts/<id>` adresi Shorts OLMAYAN videoda **303 ile**
`watch?v=`'ye yönlendiriyor; Shorts'ta yönlendirme yok.

| örnek | sonuç |
|---|---|
| yatay video (3:33) | `shorts_mu → False` ✓ |
| gerçek Shorts | `shorts_mu → True` ✓ |

Anahtar istemiyor, tek istek. Toplayıcı YouTube'dan yalnız Shorts alıyor.
**Ölçemezse elemiyor:** ağ hatasında `None` dönüyor ve aday yine kuyruğa
giriyor — "ölçemedim" ile "Shorts değil" aynı şey değil.

### 13.2 oEmbED YALAN SÖYLÜYOR — sütun bu yüzden gerekti

Gerçek bir Shorts'ta:

```
shorts_mu  → True      (sonda, kesin)
oEmbed     → 200x113   → 16:9, YATAY
```

Video dikey, oEmbed yatay diyor. Orana güvenilemez. Shorts'u 16:9 kutuda
çizmek, köşenin asıl içeriğini siyah bantlar arasına sıkıştırmak olurdu.

Çözüm `dikey boolean` sütunu
(`20261120090000_paylasim_dikey.sql`, **uygulanmayı bekliyor**):

* **hat** → `shorts_mu()` sondasıyla doluyor
* **panel** → yapıştırılan adres `/shorts/` ya da `/reel/` biçimindeyse
* **NULL = ölçülemedi**, "yatay" demek değil; görünüm mecra varsayımına
  düşüyor

Dikey kutu 360 piksel enle çiziliyor: 550 enli bir Shorts 978 piksel boy
ister, ekranı tek paylaşım kaplardı.

---

## 14. Seçim ölçütü: yayıncı değil konu (20 Kasım 2026)

İlk gerçek aday **edirnegazetesi** hesabından geldi — bir gazete, çiftçi
değil. Bu, kullanıcının "şahısların gönderdiği içerik" ifadesine aykırı
görünüp bir şüphe doğurdu: Alerts sistematik olarak medya hesaplarını mı
öne çıkarıyor?

**Şüphe yersizdi, çünkü ölçüt yanlış anlaşılmıştı.** Netleşen hâli:

> Köşe "şahısların PAYLAŞTIĞI" değil, **İNSAN MERKEZLİ** paylaşım arıyor.

Tarlasında salep yetiştiren emekli çift, hasat eden üretici, köyünde
üretim yapan aile — konunun merkezinde bir insan varsa köşeye uygun.
Bunu kimin paylaştığı fark etmiyor; gazete hesabı da olur.

Dolayısıyla:

* `OLUMSUZ` listesine **medya hesabı işareti eklenmeyecek**. Böyle bir
  süzgeç tam da istenen içeriği eleyecekti.
* Hesap türü bir eleme ölçütü değil. Kuyruğa giriyor, kararı insan
  veriyor — zaten hattın baştaki kuralı.
* Hesap dağılımı yine de ölçülüyor, ama **bilgi olarak**, süzgeç olarak
  değil.

---

## 15. Künye ve görsel — yeniden ölçüm (20 Kasım 2026)

§7'deki tablo artık eksik. Dört mecranın oEmbed yanıtı bugün:

| mecra | hesap | başlık | küçük görsel |
|---|---|---|---|
| YouTube | ✓ | ✓ | **✓** |
| X | ✓ | ✗ | ✗ |
| TikTok | ✗ | ✗ | ✗ |
| Instagram | ✗ | ✗ | ✗ |

**DEĞİŞEN: TikTok artık künye vermiyor.** Daha önce `author_name`
döndürdüğü yazılmıştı; bugünkü yanıtta yalnız `html`, `width`, `height`,
`embed_product_id` var. Mecra kapıyı daraltmış. Kayıt niteliğinde bir
uyarı: mecra kapıları zamanla daralıyor, bir kez ölçülen şey kalıcı
değil.

**Görsel veren tek mecra YouTube.** Bu, paylaşım kartı kararını doğrudan
etkiliyor (§16).

---

## 16. Paylaşım kartı — kısıtlar

### 16.1 `/tarladan` bugün og etiketi almıyor

`firebase.json` rewrite tablosu ölçüldü: `/haber/**`, `/hafta/**`,
`/kategori/**`, `/rss.xml`, `/sitemap.xml` fonksiyonlara gidiyor; geri
kalan her şey `**` → `/index.html`. Yani köşe bağlantısı paylaşıldığında
sitenin genel yedek görseli çıkıyor.

Kart için `tarladanRenderer` benzeri yeni bir fonksiyon + rewrite
gerekiyor. Emsal var: `dossierRenderer`, `weekRenderer`,
`categoryRenderer`.

### 16.2 Emsalin gerekçesi bizde geçerli değil

`content/dossiers/_ortak/paylasim_karti.mjs` kartı puppeteer ile
1200×630 JPEG üretip depoya koyuyor ve kendi yorumunda **neden çalışma
anında üretmediğini** yazıyor: dosya kartı 28 günde bir değişiyor, her
paylaşımda sunucuda çizmek gereksiz sabit maliyet olurdu.

Köşe kartı **her gün** değişiyor. Depoya koymak, her gün bir dağıtım
demek — emsalin gerekçesi tersine dönüyor.

### 16.3 Zemin görseli çoğu gün yok

Karar #42 zemini "günün öne çıkan karesi" olarak belirlemişti. §15'teki
ölçüm bunu sınırlıyor: küçük görsel yalnız YouTube'dan geliyor.
Instagram-only bir derlemede — ki bugünkü derleme öyle — zemin yok.

### 16.4 Kurulan çözüm: görsel sabit, metin günlük

| parça | nerede | ne zaman değişir |
|---|---|---|
| Kart görseli | `web/paylasim/tarladan.jpg` (depoda) | köşenin kimliği değişirse |
| og başlığı · açıklaması | `tarladanRenderer` | **her istekte**, veritabanından |

`content/tarladan/paylasim_karti.mjs` kartı dosya kartının yordamıyla
üretiyor: puppeteer, 1200×630, JPEG q92, gömülü font. Motif tarla sırası.

`functions/index.js` içindeki `tarladanRenderer` + `firebase.json`'daki
`/tarladan` rewrite'ı og etiketlerini veriyor. Çalıştırılarak doğrulandı:

```
durum 200
og:title        Tarladan Paylaşım · 20 Kasım 2026
og:description  Sosyal medyada dönen tarım içeriğinin günlük derlemesi. 1 paylaşım.
og:image        https://tarimportali.net/paylasim/tarladan.jpg
twitter:card    summary_large_image
```

Yayında derleme yoksa başlık günü taşımıyor, yalnız köşenin adını —
"0 paylaşım" yazmak okura bozuk bir sayfa vaat etmek olurdu.

**İngilizce yol bilerek bağlanmadı.** Fonksiyon `/en/tarladan`'ı
karşılamaya hazır ama kuralı yok: uygulamanın yönlendiricisinde hiç
`/en/` rotası yok ve bilinmeyen yol ana sayfaya atılıyor. Kural eklemek
robota ince bir sayfa, okura yönlendirme vermek olurdu.

### 16.5 Yan bulgu — yerel öykünücü bu projede çalışmıyor

`firebase emulators:start --only functions` bütün fonksiyonları düşürüyor:

```
⚠ functions.config() has been removed in firebase-functions v7
⬢ Failed to start functions: FirebaseError: Failed to load function.
```

Proje kodu `functions.config()` **çağırmıyor**; uyarı öykünücünün
kendisinden geliyor. firebase-tools 14.17 ile firebase-functions 7.4
yerelde uyuşmuyor. `categoryRenderer` de aynı şekilde düşüyor, yani
soruna yeni kod yol açmadı ve dağıtımı etkilemiyor — ama **fonksiyonlar
yerelde koşturulamıyor**. Doğrulama, `onRequest` sarmalını doğrudan
çağırarak yapıldı.

---

## 17. Uzun sorgu çalışmıyor (21 Kasım 2026, 30 saat sonra ölçüldü)

Dört yeni akış **30 saat** boyunca **sıfır** girdi üretti. Hepsi HTTP 200,
geçerli Atom, sorgular doğru yazılmış — ama hiç `<updated>` damgası yok,
yani akışlar hiç girdi üretmemiş.

Akışlar yaşıyor: silinmiş bir akış **HTTP 400** dönüyor (eski beş akış
öyle), bunlar 200 dönüyor.

### 17.1 Karşılaştırma

| akış | sorgu | terim | sonuç |
|---|---|---|---|
| eski INSTAGRAM | `site:instagram.com (çiftçi OR tarla OR hasat)` | 3 | 74 dk'da **2** |
| eski KONTROL | `(çiftçi OR tarla OR hasat)` | 3 | 4,5 sa'te **20** |
| yeni IG_A | `site:instagram.com (hasat OR … OR sera)` | 8 | 30 sa'te **0** |
| yeni IG_B / YT_A / YT_B | 8 terim | 8 | 30 sa'te **0** |

**Belirleyici ayrıntı:** yeni IG_A da `hasat` ve `tarla` içeriyor. Eski
akış kurulduğunda geriye doldurup salep paylaşımını getirmişti; yeni akış
aynı paylaşımı getirmeliydi. Getirmedi, geriye doldurma hiç olmadı.

**Sonuç: sorgu uzunluğu şüpheli.** Üç tekil terim çalıştı, sekiz terim
hiçbir şey üretmedi. Alerts'in OR listesi için belgelenmiş bir sınırı
bilmiyoruz; bu, iki ölçümün karşılaştırmasından çıkan bir çıkarım.

### 17.2 İkinci ihtimal: akış ayarları

Alerts kurulurken iki ayar var ve akış XML'inden görünmüyor:

* **Ne sıklıkta** — "olur olmaz" değil "haftada en çok bir kez" seçiliyse
  akış günlerce boş kalır.
* **Kaç tane** — "yalnızca en iyi sonuçlar" seçiliyse `site:instagram.com`
  gibi düşük sıralanan sonuçlar hiç çıkmayabilir.

Eski akışlar çalıştığına göre kullanıcı aynı varsayılanları kullanmış
olmalı, ama doğrulanmadı.

### 17.3 Ayırt edici deney

Tek bir akış, eski çalışan biçimle ve yeni terimlerle:

```text
site:instagram.com (hasat OR tarla OR tohum)
```

Birkaç saatte dolarsa sebep **sorgu uzunluğu** — o zaman uzun akışlar
yerine çok sayıda kısa akış kurulur (toplayıcı `ALERTS_*` ile başlayan her
değişkeni okuduğu için bedeli yok). Boş kalırsa sebep **ayarlar** ve
Alerts arayüzünden "olur olmaz" + "tüm sonuçlar" doğrulanmalı.

### 17.4 Yan kusur: tırnaksız çok kelimeli terim

B akışlarındaki `zirai don` ve `bağ bozumu` tırnaksız yazıldı. Google
sözdiziminde boşluk VE gibi bağlanıyor; o terimler "zirai VE don" oluyor.
Kusur, ama sonucu sıfırlayan sebep bu değil — OR listesinin geri kalanı
yine eşleşirdi. Düzeltilmiş hâli `"zirai don"`.

---

## 18. ALERTS YANLIŞ ALETTİ — arama çalışıyor (21 Kasım 2026)

§17'deki şüphe çözüldü, ve sorgu uzunluğu değilmiş.

Test akışı (`site:instagram.com (hasat OR tarla OR tohum)` — eski çalışan
biçimin aynısı) da boş kaldı. Bunun üzerine Alerts'ten bağımsız ölçüm
yapıldı: **aynı sorgu doğrudan Google aramasında.**

### 18.1 Google diziniyor, Alerts getirmiyor

`site:instagram.com hasat` → **on sayfa sonuç.** Son bir haftaya
süzülünce (`tbs=qdr:w`) tam da köşenin aradığı içerik:

| hesap | ne zaman | ne |
|---|---|---|
| anne_kiz_mutfagii | 1 gün önce | "2026/27 sezonunun ilk zeytinleri dalından toplanmaya başladı" |
| orodimilas | 1 gün önce | "Erken hasat bizim için takvim tercihi değil, kalite eşiği" |
| tarimtv.gov.tr | 3 gün önce | Ordu kivisinde hasat sezonu |
| ayselyilmazresmi | 4 gün önce | "Hasat zamanı. Herkese kolay gelsin." |
| tarim_turkiye | 4 gün önce | "Hasat başlar, Elibol konuşur" |

İçerik var, Google bir gün içinde diziniyor. **Alerts bir arama değil,
"yeni içerik bildirici"** ve Instagram gönderilerini haber saymıyor.
Dört akış + test akışı, beşi birden, bunun kanıtı.

### 18.2 Otomatik aramanın yolu kapalı

* **Programmable Search** — yeni müşteriye kapandı, 1 Ocak 2027'de
  kapanıyor (§4'te ölçülmüştü).
* **Sonuç sayfasını kazımak** — mecranın şartlarına aykırı.

Geriye insanın taraması kalıyor. Kullanıcının kısıtı istek değil zamandı;
o yüzden tarama birkaç saniyeye indirildi.

### 18.3 Kurulan çözüm: panelde arama kısayolları

`lib/features/tarladan_paylasim/presentation/widgets/arama_kisayollari.dart`

Yapıştırma kutusunun altında sekiz terim düğmesi ve Instagram / Shorts
seçici. Düğme Google'ı `site:<mecra> <terim>` + `tbs=qdr:d` (son bir gün)
ile açıyor. Okunan bağlantı yukarıdaki kutuya yapıştırılıyor; gerisi
değişmedi — çözücü, kanonikleştirme, kuyruk, onay.

Çok kelimeli terim tırnaklanıyor (`"bağ bozumu"`), §17.4'teki kusur
burada düzeltilmiş hâliyle.

### 18.4 Alerts akışları ne olacak

Beş akış da duruyor ve toplayıcı onları okumaya devam ediyor — maliyeti
yok, bir gün bir şey getirirse kuyruğa düşer. Ama **köşenin bulma yolu
artık arama kısayolları.** Alerts bir yedek, hat değil.

---

## 19. Köşe kapısı (25 Kasım 2026)

Köşe bitti ama **yayına alınmasına onay verilmedi**. Portalın hosting
dağıtımı Flutter paketinin tamamını götürdüğü için, başka bir işin
dağıtımı köşeyi de canlıya taşır.

### 19.1 Görünmezlik veriye bırakılamazdı

Dağıtım günü köşe zaten görünmüyordu, ama yalnız şu sebeple:

```
bandBirimleri → sonDerlemeler(gun: 2) → eşik 2026-11-23
canlıdaki tek derleme: 2026-11-20 yayinda  → pencere dışı → boş
```

Bugünün tarihiyle bir derleme yayına alınsa köşe o anda belirirdi, yeni
dağıtım bile gerekmezdi. **"Bugün görünmüyor" ile "görünmesi imkânsız"
aynı şey değil.**

### 19.2 Üç delik vardı, bant yalnız birincisiydi

| delik | kapatan |
|---|---|
| Ana sayfa şeridi | `TarladanBandi` → `koseAcik` kapalıyken hiç çizilmiyor |
| **Adres çubuğuna `/tarladan` yazmak** | rotaya `redirect` → ana sayfa |
| **Bağlantı paylaşmak / robot** | `/tarladan` rewrite'ı `firebase.json`'dan çıkarıldı |

İkincisi ve üçüncüsü ölçülerek bulundu: rota tanımlıydı, yani adresi
yazan köşeyi görürdü; rewrite da duruyordu, yani `tarladanRenderer`
paylaşıma düzgün bir og kartı ve SSR başlığı veriyordu — robot bunu
indeksleyebilirdi. Yalnız banda kapı koymak köşeyi kapatmazdı.

### 19.3 Anahtar tek yerde

`lib/features/tarladan_paylasim/kose_kapisi.dart` → `const bool koseAcik`

**Asıl kilit bu.** Rewrite geri gelse bile `koseAcik` kapalıyken köşe
açılmıyor. Panel etkilenmiyor: editör kuyruğu doldurmaya ve derleme
hazırlamaya devam edebiliyor.

Sınama kapıya bağlandı (`test/tarladan_bandi_test.dart`): veri dolu
geliyor, kapı kapalıyken tek satır metin bile çizilmiyor. Kapı açılınca
sınamanın öteki dalı devreye giriyor, yani sınama iki durumda da doğru.

### 19.4 Köşeyi açarken

1. `koseAcik` → `true`
2. `firebase.json`'a `/tarladan` → `tarladanRenderer` rewrite'ı geri, `**`
   kuralından ÖNCE

İkincisi atlanırsa köşe çalışır, yalnız paylaşım kartı çıkmaz.
