# Tarım Portalı — Sayfa Tasarımı ve Düzeni Denetimi
**Alan:** anasayfa · kategori · haber detay — masaüstü + mobil
**Tarih:** 30 Ekim 2026 · **Depo:** `/Users/BURHAN/Desktop/tarim_app`

Tüm bulgular dosya açılarak doğrulandı. CLAUDE.md'de bilinçli karar olarak yazılı şeyler (dosya sayfasının karanlık adası §3.1, ses kapsam dışı, AppBar yerleşimi) eksik sayılmadı.

---

## 1. BUGÜN NE İYİ ÇALIŞIYOR

**Kırılma noktaları gerçekten tek kaynakta.** `ResponsiveBreakpoints.contentWide = 900` (`lib/core/utils/responsive_breakpoints.dart:26`) ve eski yerel kopyalar artık ona bağlı takma adlar: `hero_fold.dart:35` ve `agenda_bento_grid.dart:20` ikisi de `const … = ResponsiveBreakpoints.contentWide`. Dosyanın 18-25. satırlarındaki yorum "kabuk 650/1100'de kırılır, bileşenin içi 900'de" ayrımını yazılı hale getirmiş — bu ayrım kodda da tutuyor.

**Üç ekran boyu için üç ayrı düzen yazılmış, "sıkıştırılmış masaüstü" değil.** `turkey_news_grid.dart:38-46` mobil/tablet/masaüstü için `_MobileGrid` / `_TabletGrid` / `_DesktopGrid`'e dallanıyor; tablet "1 tam + 2 sütunda 4", masaüstü "üstte 2 büyük + altta 4". Hero da öyle: `_DesktopHeroFold` 7:3 satır (`hero_fold.dart:79-113`), tablet 2 sütunlu yazar ızgarası, mobil yatay şerit.

**Okuma oluğu disiplini §4'le birebir.** Haber gövdesi 800 px (`article_detail_screen.dart:369`), hero görseli 900 (`:316`), liste kabukları 1200 (`home_screen.dart:147`, `category_articles_screen.dart:108`), tablet için 960 karşılığı (`home_screen.dart:497`) ve gerekçesi yorumda yazılı.

**Boş durum çökmesi düşünülmüş.** Bölüm veri bulamazsa `SizedBox.shrink()` dönüyor ve boşluğu sarmalayan `Padding` değil bölümün kendisi yayıyor — gerekçe `home_screen.dart:598-601`'de yazılı. Ayrıca kısa yazar listesi için hayalet yuvalar (§26.1), manşet yoksa `_EmptySlot` (`hero_fold.dart:770`), bölüm başlığı dar ekranda kırpmak yerine iki satıra sarıyor (`section_container.dart:37-70`).

**Anasayfanın yükleme ve hata hâli gerçek.** `HomeSkeletonLoader` + `_HomeErrorView` (`home_screen.dart:118-123`) ve iskelet hero'nun kendi 900 px eşiğini izliyor (`home_skeleton.dart:17, 88-98`). Ölçüm de bunu doğruluyor: §21.2'de CLS 0,029 · LCP 0,8 sn.

**Detay sayfasının okuma kurgusu gerekçeli.** Kısa haberde 21:9, uzun haberde 16:9 bant (`article_detail_screen.dart:333-343`); okuma ilerleme çizgisi (`:666-677`); gövde → dosya şeridi → sonraki haber → ilgili haberler sırası ve neden bu sırada olduğu `:540-585` arasında yazılı. İlgili haberler karıştırıcısı haber kimliğinden tohumlanıyor, yani kart sırası kaydırmada yerinden oynamıyor (`:1145-1147`).

---

## 2. EN ÖNEMLİ EKSİKLER

### E1 · Kategori sayfası "yükleniyor"u "haber yok" diye gösteriyor
**Etki: yüksek · Maliyet: küçük**

`categoryArticlesProvider` yükleme ve hatayı boş listeye indiriyor:
```
loading: () => [],
error: (e, s) => [],
```
`lib/features/home/providers/home_providers.dart:738-739` (aynı desen `turkeyNewsProvider:672-673`, `worldNewsProvider`, `scienceAndReportsProvider`'da da var).

Ekran ise boş listeyi tek bir anlamla karşılıyor:
`category_articles_screen.dart:93-103` → `if (articles.isEmpty)` → **"Bu kategoride haber bulunmuyor."**

Yani mobil bağlantıda `/kategori/hayvancilik` bağlantısını açan okuyucu, veri gelene kadar "bu kategoride haber yok" cümlesini okuyor; ağ koparsa da aynı cümleyi görüyor.

**Neden önemli:** proje bu ilkeyi başka yerde açıkça yazmış — `home_repository.dart:345-348`: *"Hata burada YUTULMUYOR: boş liste 'o hafta haber yayımlanmamış' demek, ağ hatası ise bambaşka bir şey."* Haftalık özet ekranı da üç durumu ayırıyor (`weekly_recap_screen.dart:113` loading, `:121` error). Kategori sayfası aynı ilkeden dışarıda kalmış. Üstelik kategori sayfaları §19.8 ile SEO'ya açılmış giriş sayfaları.

---

### E2 · Kategori gövdesi tembel değil ve sayfalama yok
**Etki: yüksek · Maliyet: orta**

`_MixedGrid` tüm haberleri tek seferde kuruyor — `category_articles_screen.dart:202` `while (i < articles.length)`, sonuç `:308-318`'de tek `Column`, ve o Column tek bir `SliverToBoxAdapter` içinde (`:105`). Dosyanın 185-187. satırındaki yorum bunun bilinçli olduğunu söylüyor ama gerekçesi farklı: *"so there are ZERO Expanded widgets in a scrollable context."* Yani amaç `Expanded` kaçınmakmış, tembelliği feda etmek değil.

Kaynak tarafında sınır da yok: `categoryArticlesProvider` `latestArticlesProvider`'ı süzüyor, o da `watchLatestArticles()`'a dayanıyor ve orada `select('*')` var, `.limit()` **yok** (`home_repository.dart:44-50`).

**Ek olarak doğrulanması gereken bir çelişki:** §20.1 `_listeSutunlari` (sekiz ağır sütunu dışarıda bırakan liste) ve `_listeSiniri = 500` eklendiğini yazıyor. Depoda ikisi de yok:
```
grep -rn "_listeSutunlari\|_listeSiniri" lib/   → hiç sonuç yok
```
Aynı dosyadaki 192-195. satırlardaki yorum hâlâ "watchLatestArticles en yeni 500 haberi taşıyor" diyor — yani yorum sınırdan söz ediyor, kod sınır içermiyor. Bu, düzen alanının dışına (veri yükü, §20) taşan bir konu; **harekete geçmeden önce canlı derlemenin bu düzeltmeyi taşıyıp taşımadığı doğrulanmalı** (hafızadaki "depo canlının gerisinde" vakası 28 Ekim'de kapatılmıştı, bu kalıntı o hizalamadan sağ çıkmış olabilir).

**Düzen tarafındaki eksik net:** kategori sayfasında sayfalama ya da "daha fazla yükle" arayüzü hiç yok. §20.3 doğru çözümü zaten yazmış: *"Arşivin tamamında gezinme gerektiğinde doğru çözüm sınırı büyütmek DEĞİL, kategori ekranına kendi sayfalanmış sorgusunu vermek."*

---

### E3 · Haber detayında alt bilgi ve gezinme yok — en çok trafik alan sayfada
**Etki: yüksek · Maliyet: küçük**

`PortalFooter` yalnızca üç ekranda:
```
category_articles_screen.dart:175
weekly_recap_screen.dart:213
home_screen.dart:461, 536, 637
```
`article_detail_screen.dart` listede yok; sayfa `SliverToBoxAdapter(child: SizedBox(height: 48))` ile bitiyor (`:586`).

Bu, portalın kendi yorumuyla çelişiyor — `portal_footer.dart:40-44`: *"Ayarların ASIL giriş noktası burası. AppBar'daki hesap menüsü yalnızca masaüstünde çıkıyor… Footer üç ekranda birden (ana sayfa, haftalık özet, kategori) ve her ekran boyutunda görünüyor."* Demek ki arama motorundan `/haber/:id`'ye inen okuyucu ayarlara, künyeye, iletişime, gizlilik ve çerez sayfalarına hiçbir yoldan ulaşamıyor.

Üst çubuk da en yalın hâlde: `article_detail_screen.dart:613-658` arasında yalnızca geri düğmesi ve kaydırmada belirlen başlık var. Logo/anasayfa bağlantısı, arama, kategori şeridi yok. `CategoryNavBar` yalnızca tek yerde çağrılıyor — `home_screen.dart:100`. Arama da öyle: `showSearch` yalnızca `home_screen.dart:262` ve `:275`'te.

**Neden önemli:** §19 tüm SSR çalışması haber ve kategori sayfalarını arama motoruna açmak içindi. O sayfalara inen okuyucunun tek çıkışı geri düğmesi. (Geri düğmesinin kendisi doğru çalışıyor — `popScreen` yığın boşsa `/`'a gidiyor, `fade_page_route.dart:47-55`.)

---

### E4 · Haberden kategoriye ve etikete dönüş yolu yok
**Etki: yüksek · Maliyet: küçük**

`_MetaRow` kaynak etiketi + tarih + okuma süresi + okunma sayacı gösteriyor (`article_detail_screen.dart:690-757`). `article.topic` ve `article.region` modelde var (`news_article.dart:21-22`) ama detay sayfasında hiç görünmüyor. Okuyucu "Hayvancılık" haberi okuyup "bu kategoride başka ne var?" diyemiyor.

Etiketler çiziliyor ama **ölü**: `_KeywordsRow` çipleri düz `Container` + `Text`, ne `onTap` ne `InkWell` var (`:797-816`). `/etiket/:slug` rotası da yok — `app_router.dart:188-370` arasındaki rota listesinde yer almıyor. Yani `seo_keywords` ekranda yer kaplıyor, hiçbir yere götürmüyor.

---

### E5 · Yazı boyutu denetimi anasayfada hiç çalışmıyor
**Etki: orta-yüksek · Maliyet: orta**

`fontScaleProvider` (0,8×–1,5×, kalıcı — `font_scale_provider.dart`) yalnızca üç ekranda okunuyor:
```
grep -rln "fontScale" lib/features/home/presentation/
→ article_detail_screen.dart · category_articles_screen.dart · weekly_recap_screen.dart
```
`FontSizeControlBar` de yalnızca o üç ekranda (`weekly_recap_screen.dart:96`, `category_articles_screen.dart:85`, `article_detail_screen.dart:394`).

Anasayfanın hiçbir bölümü ölçeği almıyor: `hero_fold`, `turkey_news_grid`, `world_news_row`, `science_reports_dossier`, `icymi_section`, `kisa_kisa_section` `fontScale` parametresi taşımıyor. Okuyucu haber detayında puntoyu 1,4×'e çıkarıp anasayfaya döndüğünde her şey eski boyuna düşüyor — ve orada büyütecek bir denetim de yok.

**Hafifletici:** §21.3 ile tarayıcı yakınlaştırma engeli kaldırıldı, yani okuyucunun bir çıkış yolu var. Yine de denetimin sayfadan sayfaya kaybolması, kendisi bir tasarım tutarsızlığı. Kararın gerekçesi CLAUDE.md'de yazılı değil — ya yayılmalı ya karar olarak yazılmalı. (`app_typography.dart:13-14` "scale yalnızca okuma içeriğine, asla arayüz kromuna" diyor; kart başlıkları hangi tarafta sayıldığı belirsiz.)

---

### E6 · Aynı sayfadaki kart başlıkları hem uyumsuz hem kırılma noktasına tepkisiz
**Etki: orta · Maliyet: orta**

Masaüstü anasayfasında, üst üste gelen bölümlerde:

| yer | masaüstü punto | mobil punto | dosya:satır |
|---|---|---|---|
| `AppTypography.headlineCard` (sistem rolü) | 21 | 18 | `app_typography.dart:85-93` |
| Türkiye ızgarası — büyük / küçük | 22 / 16 | **22 / 16** | `turkey_news_grid.dart:308` |
| Dünya şeridi | 16 | **16** | `world_news_row.dart:168` |
| Bilim — öne çıkan / liste | 26 / 16 | **26 / 16** | `science_reports_dossier.dart:208, 302` |
| Kategori `_LargeCard` | 34 | 23 | `category_articles_screen.dart:526` |
| Kategori `_HeroArticle` | 48 | 27 | `category_articles_screen.dart:420` |

Koyu yazılan sütun kritik: Türkiye, Dünya ve Bilim kartlarının punto'su 360 px'te de 1920 px'te de aynı. `AppTypography` tam bu iş için var ve kırılma noktalarını paylaşıyor (`app_typography.dart:7-11`), hatta bir önizleme ekranı bile var (`typography_preview_screen.dart`) — ama benimsenmemiş:

```
AppTypography. kullanımı: turkey_news_grid 0 · world_news_row 1 (sadece minLabelSize)
                          category_articles_screen 0
GoogleFonts.  doğrudan:   category_articles_screen 12 · hero_fold 12 · home_screen 12
```

---

### E7 · Masaüstü anasayfa ve kategori sayfası ilk karede baştan sona çiziliyor
**Etki: orta · Maliyet: orta**

`_DesktopContent` on altı bölümün tamamını **tek** `SliverToBoxAdapter` içindeki bir `Column`'a koyuyor (`home_screen.dart:568-572`). Kategori sayfası aynı desende (`category_articles_screen.dart:105`). Mobilde `ListView(children: […])` en azından eleman oluşturmayı erteliyor (`:424`); masaüstünde o kazanç yok — sliver tek kutu olduğu için tamamı ölçülüp yerleştiriliyor.

§4 kuralı net: *"Uzun listeler tembel (`SliverList.builder`). 13 bölümü tek seferde kurmak açılışta gözle görülür duraklama yapıyordu."* Dosya ekranında uygulanmış kural anasayfada uygulanmamış. §21.2'de kırmızı olan tek metrik de bu: TBT 430 ms.

---

### E8 · Mobilde manşetten sonra haber gelmiyor
**Etki: orta · Maliyet: küçük-orta**

`_MobileContent` sırası (`home_screen.dart:426-441`):
```
StoryAvatarStrip → _PortalHeroSection (manşet karüseli + "YAZARLARIMIZ")
→ IosPwaPrompt → NotificationPromptStrip → CommodityStrip
→ Son Okuduklarınız → YYT Dosyası → ancak burada _TurkeyNewsSection
```
Manşet karüselinde aynı anda **tek** başlık görünüyor (`hero_fold.dart:146` tam en karüsel) ve hemen altına yazar bölümü geliyor (`:140-172`). Yani ilk haber ızgarasına inmek için okuyucu manşet dışında beş haber-dışı bloğu geçmek zorunda. Haber portalında manşetin hemen altında "diğer öne çıkanlar" listesi beklenir; burada ikinci haberi görmenin tek yolu karüseli kaydırmak.

(Not: şeridin manşetin üstünde durmasının gerekçesi `:433-436`'da yazılı ve geçerli — eleştirilen şey o sıra değil, manşetle ilk ızgara arasındaki mesafe.)

---

### E9 · Kırık görsel sonsuza kadar "yükleniyor" gibi duruyor
**Etki: orta · Maliyet: küçük**

`image_fallback_helper.dart:150-151`:
```dart
placeholder:  (context, url) => ShimmerPlaceholder(width: width, height: height),
errorWidget:  (context, url, error) => ShimmerPlaceholder(width: width, height: height),
```
Boş/geçersiz URL de aynı yere düşüyor (`:116, 119`). Yükleniyor, boş ve kırık üç durum tek görünüşe indirgenmiş — okuyucu parlayan kutuya bakıp bekliyor. §3.5 "kapak görselsiz de tam çalışır, görsel bir katman" ilkesi dosya kapağında tipografik iskelete düşüyor; haber kartının böyle bir yedeği yok.

---

### E10 · Izgara kartları klavyeyle gezilemiyor, dokunulabilir olduğunu söylemiyor
**Etki: orta · Maliyet: küçük**

Ev deseni zaten var ve doğru: `MergeSemantics` + `GestureDetector` + görsele `semanticLabel` — `hero_fold.dart:696, 707` ve `news_card.dart:57`. `NewsArticleImage` de etiketsizken `ExcludeSemantics`'e düşüyor, yani yanlış alt metin üretmiyor (`image_fallback_helper.dart:154-162`). Bu iyi.

Sorun: desen yeni ızgaralara uygulanmamış.
```
category_articles_screen.dart : 5 GestureDetector · 0 Semantics
turkey_news_grid.dart         : 2 GestureDetector · 0 Semantics
world_news_row.dart           : 1 GestureDetector · 0 Semantics
science_reports_dossier.dart  : 2 GestureDetector · 0 Semantics
icymi_section.dart            : 1 GestureDetector · 0 Semantics
kisa_kisa_section.dart        : 1 GestureDetector · 0 Semantics
```
`InkWell` kullanan yerler (`next_article_card.dart`, `portal_footer.dart`, `news_ticker.dart`) Tab ile odaklanabiliyor; sayfanın ana ızgaraları odaklanamıyor. §21'de Erişilebilirlik 93 — kalan boşluğun bir kısmı burada.

---

### E11 · Paylaşılan kart bileşeni fiilen kullanılmıyor; 15+ ayrı kart sınıfı var
**Etki: orta · Maliyet: büyük**

`lib/features/home/presentation/widgets/news_card.dart` paylaşılan `NewsCard` bileşeni — tek çağrı yeri var: `author_article_detail_screen.dart:176`. Geri kalan her bölüm kendi özel kartını yazmış:

`_TurkeyNewsCard` (`turkey_news_grid.dart:188`) · `_WorldNewsCard` (`world_news_row.dart:61`) · `_DossierFeaturedCard`, `_DossierListCard` (`science_reports_dossier.dart:134, 241`) · `_IcymiCard` (`icymi_section.dart:64`) · `_RecentlyReadCard` (`home_screen.dart:1084`) · `_RelatedCard` (`article_detail_screen.dart:1281`) · `NextArticleCard` · `_HeroArticle`, `_LargeCard`, `_StdCard`, `_CompactCard`, `_SideCard` (`category_articles_screen.dart:322, 475, 555, 622, 689`) · `_YYTArticleCard`, `_YYTPreviewCard` · `_RecapCard`.

E6 ve E10'un kök nedeni bu: her yeni kart punto skalasını, semantiği, hover'ı, zaman damgasını yeniden keşfediyor. Görünür bir sonuç: kategori/konu etiketi kartlarda yalnızca `news_card.dart` ve `icymi_section.dart`'ta gösteriliyor — yani fiilen hiç. `ArticleTimestamp` ise on bir dosyada tutarlı kullanılıyor; demek ki paylaşım mümkün, yalnızca kart gövdesi için yapılmamış.

---

### E12 · Üç paralel anasayfa sırası elle bakımda
**Etki: düşük-orta · Maliyet: orta**

Aynı on altı bölüm üç kez ayrı ayrı sıralanmış: `_MobileContent` (`home_screen.dart:426-456`), `_TabletContent` (`:500-528`), `_DesktopContent` (`:573-633`). Bugün sıralar birbiriyle tutuyor; tek fark boşluk sabitleri (28 / 36 / 40). Ama yeni bir bölüm üç yere elle eklenmek zorunda ve biri atlandığında hiçbir hata çıkmaz — yalnızca o ekran boyutunda bölüm yok olur.

---

## 3. MODERN BİR HABER PORTALINDA OLMASI GEREKENLER

Her madde için bu projede hangi mevcut tablo/kolon/bileşenle yapılacağı yazılı.

### M1 · "En çok okunan" listesi (okur tarafı)
Veri hazır: `articles.view_count` → `NewsArticle.viewCount` (`news_article.dart:17`); sayaç gerçek ve korumalı (`incrementArticleViewCount`, okuma eşiği + cihaz başına bir kez, `home_repository.dart:400-412`). Sıralayan metot da var: `watchTopReadArticles(limit)` (`:481-502`) — **ama yalnızca panelde** (`adminTopReadArticlesProvider`, `home_providers.dart:888`).

**Dikkat:** o metot `.stream(primaryKey: ['id'])` kullanıyor, yani Realtime aboneliği. Okur tarafına doğrudan bağlanırsa §20.4'teki "ziyaretçi başına kalıcı bağlantı yok" ilkesi kırılır ve eşzamanlılık limiti devreye girer. Doğru yol: `latestArticlesProvider`'dan `viewCount`'a göre sıralanmış türev bir `Provider` (ek ağ yükü sıfır) ya da `.limit(10)`'lu tek seferlik sorgu.
**Yerleşim:** `SectionContainer` (`lib/core/widgets/section_container.dart`) + mevcut kompakt kart; masaüstünde M2'nin rayında.

### M2 · Masaüstünde içerik + kenar sütunu (sağ ray)
Şu an her sayfa tek sütun: anasayfa 1200 (`home_screen.dart:147`), kategori 1200, detay 800. 1600 px üstü ekranda `_buildBody` hâlâ 1200 veriyor (`:140-148`), yani kenarlarda kullanılmayan alan var.

Desen zaten projede: `_DesktopHeroFold` 7:3 `Row` (`hero_fold.dart:79-113`) — hatta yorumunda `IntrinsicHeight`'ın neden kullanılmadığı bile yazılı. Aynı desen sayfa kabuğuna taşınırsa detayda 800 px okuma oluğu (§4) bozulmadan yanına 300–320 px ray girer: en çok okunan (M1) + ilgili haberler (`_RelatedSection` zaten var) + emtia şeridi (`CommodityStrip` zaten var).

### M3 · Sayfalama / "daha fazla yükle"
§20.3'ün yazdığı çözüm. Yeni repository metodu `fetchArticlesByTopic(topic, {offset, limit})` — kalıp dosyada iki kez var: `fetchArticlesBetween` (`home_repository.dart:350-363`) ve `fetchArticlesBySourceName` (`:196+`). İkisi de "ortak listeyi süzme, kendi sorgunu yap" ilkesini uyguluyor (§26.2 kuralı `home_providers.dart:867-870`'te yazılı). Kolonlar: `articles.topic` + `status = 'published'` + `created_at desc`.
Arayüz tarafı: `_MixedGrid`'in Column'u `SliverList.builder`'a dönerse hem tembellik hem sayfalama aynı değişiklikle gelir.

### M4 · Etiket sayfası
`articles.seo_keywords` (`news_article.dart:10`) hazır ve detayda zaten çiziliyor. Gereken: `app_router.dart`'a `/etiket/:slug` (ASCII slug kuralı §2.1 ile aynı gerekçe), ekran olarak `CategoryArticlesScreen`'in ikizi, sorgu olarak `seo_keywords` üzerinde `contains`. Bu, `_KeywordsRow` çiplerini ölü süsten gezinmeye çevirir.

### M5 · Haberde kategori künyesi / ekmek kırıntısı
`article.topic` → slug çevirisi **zaten yazılmış**: `categoryTopicSlug(topic)` (`category_catalog.dart:67-76`) ve rota hazır (`/kategori/:slug`, `app_router.dart:222`). `_MetaRow`'a (`article_detail_screen.dart:690`) kaynak etiketinin yanına tıklanabilir bir konu çipi eklemek yeterli.

### M6 · "SON DAKİKA" bandı
`articles.is_breaking` kolonu var (`news_article.dart:33`), panelde anahtarı var (`dashboard_screen.dart:1190`), ama okur tarafında yalnızca akan şeritte rozete dönüşüyor (`news_ticker.dart:195-209`). Manşetin üstünde bir bant ve detay sayfasında bir etiket yok. §3.2 gereği renk değil **kelime** taşımalı — şeritteki mevcut rozet bu kurala zaten uyuyor, onun dili kopyalanabilir.

### M7 · "Güncellendi" damgası
`NewsArticle` modelinde `updated_at` **yok** (`news_article.dart:1-70`); yalnızca `createdAt` var. §39.6'da yayındaki gövdeye dokunulan vakalar yazılı — okuyucu haberin düzeltildiğini göremiyor. Gereken: yeni migration (§4.1: uygulanmış migration düzenlenmez, yeni dosya yazılır) + modele alan + `ArticleTimestamp`'a (`lib/core/widgets/article_timestamp.dart`) ikinci satır.

### M8 · Görsel altyazısı ve foto kaynağı
Ne kolon ne arayüz var. Ajans görseli kullanan bir portalda foto künyesi beklenir (§24.2'nin metne dokunmama disiplinini görsele taşıyan karşılığı). Gereken: `articles.image_credit` / `image_caption` + detayda hero'nun hemen altına küçük punto satır (`article_detail_screen.dart:312-360` bloğunun altı).

### M9 · Paylaşılabilir arama sonucu sayfası
Altyapı tam: `search_articles_fuzzy` RPC + `searchArticlesProvider` (`home_providers.dart:855-859`). Ama arama bir örtü (`showSearch`) ve yalnızca anasayfada (`home_screen.dart:262, 275`) — sonuç adresi yok, paylaşılamıyor, SSR göremiyor. Gereken: `/ara` rotası + `NewsSearchDelegate`'in sonuç gövdesini bir ekrana taşımak.

### M10 · Footer'da kategori sütunu ve arşiv girişi
`PortalFooter` şu an iki bağlantı kümesi taşıyor: kurumsal ve yasal (`portal_footer.dart:35-51`). Kategori yok. `homeCategorySlugs` (`category_catalog.dart:57-64`) olduğu gibi üçüncü sütun olur.
Ayrıca **haftalık özet ekranı arayüzden erişilemiyor**: `WeeklyRecapScreen` yalnızca router'da ve bir bildirim derin bağlantısı olarak var (`app_router.dart:244-250`); `grep` ile hiçbir ekranda ona giden `pushScreen` yok. Footer'a "Haftalık özet" bağlantısı, yazılmış bir ekranı ücretsiz geri kazandırır.

### M11 · Kategori şeridinin etkin durumu ve alt sayfalarda görünmesi
`CategoryNavBar` iyi yazılmış (ASCII slug, kısa etiket, yatay kaydırma — `category_nav_bar.dart`) ama (a) hangi kategoride olduğunu göstermiyor, (b) yalnızca anasayfada çağrılıyor. Şeridin kategori ve detay sayfalarına taşınması E3'ün gezinme yarısını da kapatır.

---

## 4. ÖNCELİKLİ YOL HARİTASI

### HEMEN — küçük maliyet, yüksek etki

| # | İş | Süre | Dokunulacak dosyalar |
|---|---|---|---|
| 1 | **Kategori sayfasında yükleniyor / boş / hata ayrımı.** Bölüm sağlayıcılarını `AsyncValue` döndürür hale getir ya da ekranda `latestArticlesProvider`'ın `AsyncValue`'sunu izle. İskelet için mevcut `SkeletonBox`/`ShimmerPlaceholder` yeniden kullanılır. | ~2 sa | `lib/features/home/providers/home_providers.dart` (726-741), `…/screens/category_articles_screen.dart` (56-103), `…/widgets/home_skeleton.dart` |
| 2 | **Detay sayfasına `PortalFooter`.** Son `SliverToBoxAdapter`'dan sonra ekle. | ~30 dk | `…/screens/article_detail_screen.dart` (586) |
| 3 | **Kırık/boş görseli iskeletten ayır.** `errorWidget` için tipografik yedek (§3.5'in haber kartı karşılığı). | ~1 sa | `lib/core/utils/image_fallback_helper.dart` (116, 150-151) |
| 4 | **Izgara kartlarına `MergeSemantics` + görsele `semanticLabel`.** `hero_fold.dart:696`'daki deseni kopyala. | ~2 sa | `category_articles_screen.dart`, `portal_sections/turkey_news_grid.dart`, `…/world_news_row.dart`, `…/science_reports_dossier.dart`, `icymi_section.dart`, `kisa_kisa_section.dart` |
| 5 | **Detayda tıklanabilir konu çipi.** `categoryTopicSlug` hazır. | ~1 sa | `article_detail_screen.dart` (`_MetaRow`, 690-757), `data/category_catalog.dart` |
| 6 | **Footer'a kategori sütunu + "Haftalık özet" bağlantısı.** | ~1 sa | `widgets/portal_footer.dart` (35-51), `data/category_catalog.dart` |
| 7 | **`CategoryNavBar`'a etkin kategori göstergesi** (`slug` parametresi + alt çizgi). | ~1 sa | `widgets/category_nav_bar.dart` |
| 8 | **Detay üst çubuğuna anasayfa + arama eylemi.** `AppBar` geometrisine dokunmadan, yalnızca `Row`'a iki eylem. | ~1,5 sa | `article_detail_screen.dart` (613-658) |

### SONRA — orta maliyet

| # | İş | Süre | Dokunulacak dosyalar |
|---|---|---|---|
| 9 | **Kategori ekranına kendi sayfalanmış sorgusu + `SliverList.builder`.** E2'nin kalıcı çözümü; §20.3'ün yazdığı yol. Bu işle birlikte `_listeSutunlari`/`_listeSiniri` çelişkisi de canlıya karşı doğrulanmalı. | ~1 gün | `data/repositories/home_repository.dart` (yeni `fetchArticlesByTopic`), `providers/home_providers.dart`, `screens/category_articles_screen.dart` (105, 196-318) |
| 10 | **Kart tipografisini `AppTypography`'ye bağla + `fontScale`'i anasayfaya yay.** Gerekirse yeni rol (`headlineCardSmall`). 360/768/1200 × tr/en taşma testi zorunlu (§5). | ~1,5 gün | `core/theme/app_typography.dart`, `turkey_news_grid.dart` (259, 308), `world_news_row.dart` (168), `science_reports_dossier.dart` (208, 227, 302), `icymi_section.dart`, `hero_fold.dart`, `category_articles_screen.dart` (420-535) |
| 11 | **"En çok okunan" bölümü** — Realtime DEĞİL, `latestArticlesProvider`'dan türev. | ~0,5 gün | `providers/home_providers.dart`, yeni `widgets/portal_sections/most_read.dart`, `home_screen.dart` (üç içerik ağacı) |
| 12 | **Masaüstü anasayfayı tembelleştir:** tek `SliverToBoxAdapter` → çoklu sliver / `SliverList`. TBT öncesi-sonrası ölçülmeli (§21.2). | ~1 gün | `screens/home_screen.dart` (563-640) |
| 13 | **Etiket sayfası `/etiket/:slug`.** | ~1 gün | `core/router/app_router.dart`, `category_articles_screen.dart` (yeniden kullanım), `home_repository.dart`, `article_detail_screen.dart` (`_KeywordsRow`, 797-816) |
| 14 | **Arama sonuç rotası `/ara`.** | ~1 gün | `core/router/app_router.dart`, `widgets/news_search_delegate.dart`, yeni ekran |
| 15 | **SON DAKİKA bandı** (manşet üstü + detay etiketi), `is_breaking`. | ~0,5 gün | `widgets/hero_fold.dart`, `screens/article_detail_screen.dart` |
| 16 | **Mobilde manşetin altına "diğer öne çıkanlar" listesi.** `homeAllocationProvider`'ın hero'dan artan ilk 4-5 başlığı; dağıtım bütçesi zaten tekilleştiriyor. | ~0,5 gün | `providers/home_providers.dart` (559-650), `screens/home_screen.dart` (426-441) |

### BÜYÜK İŞ — mimari

| # | İş | Süre | Dokunulacak dosyalar / risk |
|---|---|---|---|
| 17 | **Tek haber kartı bileşeni.** `news_card.dart`'ı `ArticleCard(variant: hero / large / standard / compact / list)` olarak genişlet, 15+ özel sınıfı tek tek taşı. Kazanç: E6, E10, kart kategori etiketi ve `fontScale` tek yerden çözülür. **Risk:** her bölümün ölçüsü yazılı gerekçeyle seçilmiş (örn. §14.2 kart yüksekliği 108/128 → 100/104). Taşıma ölçü değiştirmeden yapılmalı: bölüm başına ayrı commit + 360/768/1200 taşma testi. | 3-5 gün | `widgets/news_card.dart` + yukarıdaki tüm kart dosyaları |
| 18 | **Anasayfa bölüm sırasını veriye çevir.** Tek `List<PortalSection>` tanımı (`{bileşen, mobilBoşluk, tabletBoşluk, masaüstüBoşluk}`), üç kabuk onu çizsin. E12'yi kapatır, 12. maddeyle birlikte yapılırsa iki iş bir arada. | 2-3 gün | `screens/home_screen.dart` (426, 500, 573), yeni `data/portal_layout.dart` |
| 19 | **Masaüstü iki sütunlu sayfa kabuğu (içerik + ray).** `hero_fold.dart:79`'daki 7:3 desenini sayfa seviyesine taşı. 800 px okuma oluğu (§4) korunur, ray yanına girer. | 3-5 gün | `screens/home_screen.dart` (`_DesktopContent`), `category_articles_screen.dart`, `article_detail_screen.dart` (316, 369, 554) |
| 20 | **Şema borcu: `updated_at`, `image_credit`, `image_caption`.** Yeni migration (§4.1), model, panel formu, detay arayüzü. Hat tarafında da alan doldurulmalı. | 1-2 gün + hat | `supabase/migrations/` (yeni dosya), `data/models/news_article.dart`, `features/dashboard/presentation/screens/dashboard_screen.dart`, `article_detail_screen.dart` |

---

## Küçük dokunuşlar (düşük etkili, ayrı iş açmaya değmez)

- `category_articles_screen.dart:522-523` — üst üste `SizedBox(height: 20)` ve `SizedBox(height: 10)`; kaldırılmış bir öğeden kalma 30 px. Aynı desen `_StdCard` ve `_CompactCard`'da da tekrarlanıyor olabilir.
- `category_articles_screen.dart:519` — `withOpacity(0.12)`; proje başka yerlerde `withValues(alpha:)`a geçmiş (ör. `section_container.dart`, `article_detail_screen.dart:297`).
- `category_articles_screen.dart:185-186, 203, 223, 471, 553, 620` — yorumlar ve bölüm başlıkları İngilizce ("Mobile pattern", "Desktop: 4-pattern rotation", "STANDARD CARD"); §4 Türkçe yorum kuralı. Aynısı `home_repository.dart:19-20, 77, 96` ve `home_screen.dart:179`'da da var.
- Kartlarda kategori/konu etiketi yok — `article.topic` yalnızca `news_card.dart` ve `icymi_section.dart`'ta gösteriliyor; ikisi de fiilen görünmeyen yerler.
- `science_reports_dossier.dart:227` — liste özeti 15 punto; `AppTypography.minLabelSize` 11 olduğu için kural ihlali değil, ama sayfadaki en küçük gövde metni.
- §22.3 (yazı tipleri 682 KB) ve §22.4 (hero görseli 306 KB) hâlâ açık. Görsel tarafının **kodu hazır**: `image_fallback_helper.dart:78-93` WebP + genişlik dönüştürmesini `--dart-define=GORSEL_DONUSTURME=true` ile açıyor, `memCacheWidth` zaten yerinde (`:144`). Yani bu bir kod işi değil, Supabase Pro kararı — açıldığında dosya düzenlenmeyecek, yalnızca derleme bayrağı eklenecek.