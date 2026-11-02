## Panel — Onayda Bekleyen Haberler Ekranı · İnceleme Raporu

**Kapsam.** Kararın verildiği ekran: `lib/features/dashboard/presentation/screens/admin_statistics_screen.dart` → `_PendingArticlesSection` (satır 205–612) + `lib/features/dashboard/presentation/widgets/inceleme_karti.dart`. Veri yolu: `pendingArticlesProvider` (`home_providers.dart:197`) → `HomeRepository.watchPendingArticles` (`home_repository.dart:78`). Kuyruk `status = 'reviewing'` haberleri taşıyor.

---

## 1. BUGÜN NE İYİ ÇALIŞIYOR

- **Red artık yok etmiyor ve geri alınabiliyor.** `haberiReddet` (`home_repository.dart:246`) satırı silmek yerine `status = 'rejected'` yazıyor; `reddiGeriAl` (`home_repository.dart:184`) durumu `reviewing`e döndürüyor. Red hafızası tetikleyiciyle tutuluyor (`supabase/migrations/20261029020000_red_durumu_hafizasi.sql`), yani red hangi yoldan gelirse gelsin kayda geçiyor ve geri alma hafızayı da temizliyor. Bu, onay kuyruğunun en sağlam parçası.
- **İnceleme kartı gerçekten üç soruyu cevaplıyor.** `inceleme_karti.dart` gövde önizlemesini TR/EN sekmeli veriyor (satır 180–228), 5N1K + rakam + alıntıları gösteriyor (satır 330–430) ve gövdedeki her görseli ayrı ayrı listeleyip kapak yapma/kaldırma izni veriyor (satır 231–324). Görseli gövdeden çıkarırken desen değil **etiketin tamamı** eşleştiriliyor (satır 310–314, §39.6'ya uygun) — yayındaki metni süpürme riski yok.
- **Toplu red dürüst sayı veriyor.** `topluReddet` (`home_repository.dart:265`) tek tek dönüyor, biri patlasa diğerleri işleniyor ve arayüz **gerçekleşen** sayıyı yazıyor (`admin_statistics_screen.dart:578–581`): "3 reddedildi" deyip 1'ini yapmıyor.
- **Sessiz yazma başarısızlığı kuyruğun red yolunda çözülmüş.** `alanlariGuncelle` (`home_repository.dart:158`) `.select('id')` ile dönen satırı **sayıyor**; RLS'in hata vermeden satır süzdüğü (200 + `[]`) durum yakalanıyor. `20261029030000_articles_panel_yazma.sql` de UPDATE politikasını kurup kendi sağlamasını yazıyor — DELETE bilerek verilmemiş.
- **Kuyruk değişince hayalet seçim kalmıyor.** `admin_statistics_screen.dart:264` artık var olmayan kimlikleri seçimden düşürüyor; "3 seçili" deyip 1 haber reddetme durumu kapatılmış.

---

## 2. EN ÖNEMLİ EKSİKLER (etkiye göre sıralı)

### 2.1 Yayında haber yoksa onay kuyruğu HİÇ görünmüyor — yüksek etki / küçük maliyet
`AdminStatisticsScreen.build` tüm ekranı `latestArticlesProvider` üzerine kuruyor ve liste boşsa erken dönüyor:

```dart
// admin_statistics_screen.dart:25-27
if (articles.isEmpty) {
  return Center(child: Text(loc.translate('stats_no_data')));
}
```

Onay kuyruğu (satır 125) bu dalın **içinde**. Yani yayındaki haber listesi boş geldiği her durumda — ağ hatası, oturum sorunu, önbellek boş ilk açılış — bekleyen haberler ekranı yerine "veri yok" yazısı çıkıyor. Dahası kuyruk, tüm yayın arşivi inene kadar ekrana gelmiyor: sayfa tek bir `CircularProgressIndicator`la bekliyor (satır 141).

### 2.2 "Onayla" sonucu denetlenmiyor — yüksek etki / küçük maliyet
```dart
// admin_statistics_screen.dart:447-452
onPressed: ... () async {
  await ref.read(homeRepositoryProvider).approveArticle(article.id);
  _tazele();
},
```

Dönüş değeri okunmuyor, snackbar yok. `approveArticle` (`home_repository.dart:97–108`) ise `alanlariGuncelle`nin iki korumasının **ikisini de** taşımıyor: oturum denetimi yok, dönen satır sayılmıyor. Oturum düştüğünde panel `anon` olarak yazar; PostgREST hata vermez (§20.4'te ölçülmüş davranış) ve kart kuyruktan düşer gibi görünüp haber yayına **girmez**. Red yolunda bu sorun çözülmüş, onay yolunda açık.

### 2.3 Mükerrer denetimi hatada yeşil "temiz" diyor — yüksek etki / küçük maliyet
```dart
// inceleme_karti.dart:172-176
try {
  bulunan = await ref.read(homeRepositoryProvider).searchArticles(a.title);
} catch (_) {
  bulunan = const [];
}
```

`searchArticles` (`home_repository.dart:319–331`) RPC hatasında `throw` ediyor. O istisna burada yutuluyor, liste boş kalıyor ve kart satır 143'te **yeşil** olarak "Benzer haber bulunamadı." yazıyor. RPC düştüğünde moderatör "mükerrer yok" onayı almış oluyor — §17.1'de bir kez reddedilmiş olan sessiz sahte veri kalıbı.

### 2.4 Panelden kaydetme `article_format` ve `chart_data_en`'i NULL'a eziyor — yüksek etki / küçük maliyet
`dashboard_screen.dart:310–348`'deki `NewsArticle` kurulumu `facts/figures/quotes/turkiye_pin/chart_data`'yı özenle taşıyor (satır 335–347'deki yorum §25.1 tuzağını anlatıyor), ama **iki alan listede yok**: `articleFormat` ve `chartDataEn`. `toJson()` ikisini de yazıyor (`news_article.dart:223–224`) ve `updateArticle` tüm json'u gönderiyor (`home_repository.dart:899, 925–929`). Sonuç:

- `article_format` null'a düşüyor → `isBrief` false olur (`news_article.dart:74`) → "Kısa Kısa" için yazılmış haber kart ızgaralarına girer; §20.1 ve `briefArticlesProvider`'ın dayandığı ayrım bozulur.
- `chart_data_en` null'a düşüyor → İngilizce sayfa Türkçe grafiğe düşer.

§30.1 "`article_format` artık formdaki değer yazılıyor" diyor; depodaki kodda bu taşıma yok.

### 2.5 Kuyrukta haberin TARİHİ yok — yüksek etki / küçük-orta maliyet
Kart yalnızca başlık, kaynak adı ve iki satır özet gösteriyor (`admin_statistics_screen.dart:342–380`). İnceleme kartında da tarih yok (`inceleme_karti.dart:85–115`). Oysa `published_at` sütunu **tam bu iş için** açılmış:

> `supabase/migrations/20260816130000_yayin_tarihi_ve_red_hafizasi.sql:19-22` — "Kaynak sayfadan çıkarılan gerçek yayın tarihi. Besleme beyanı değildir." Aynı dosyanın başındaki ölçüm: yenisafak'ın 2025-05-27 tarihli haberi beslemede "1 gün" görünüp **447 günlük** haber taze diye içeri girmiş.

`NewsArticle` modeli bu sütunu hiç okumuyor (`news_article.dart` içinde `publishedAt` alanı yok, `toJson` listesinde `published_at` yok). Yani bayatlığı yakalamak için tutulan veri, kararı veren kişiye hiç ulaşmıyor.

### 2.6 Reddedilen habere 8 saniye sonra hiçbir yerden ulaşılamıyor — yüksek etki / orta maliyet
`reddiGeriAl`ın depodaki **tek** çağrı yeri snackbar aksiyonu (`admin_statistics_screen.dart:583–596`, `duration: 8 saniye`). Snackbar kapandıktan sonra:

- Kuyruk yalnızca `reviewing` çekiyor (`home_repository.dart:81`) → reddedilen görünmez.
- Tab 1'deki "Arşiv" düğmesi `a.status == 'draft'` süzüyor (`dashboard_screen.dart:1332`) ve beslediği `latestArticlesProvider` yalnızca `published` çekiyor (`home_repository.dart:46`) → **arşiv görünümü her zaman boş**.

§29.1 "haber arşivde duruyor ve geri alınabiliyor" diyor; veritabanı tarafı doğru (292 kayıt `rejected`, §40.2'de anılıyor) ama panelde o arşivi gösteren ekran yok.

### 2.7 Red gerekçesi hiç yazılmıyor — orta-yüksek etki / küçük maliyet
`haberiReddet`in `gerekce` parametresi var (`home_repository.dart:252`) ve `rejection_reason` sütununa yazıyor (satır 256). İki çağrı yerinin **ikisi de** bu parametreyi geçmiyor: `_tekReddet` (`admin_statistics_screen.dart:505–512`) ve `topluReddet` (`home_repository.dart:270–276`). Sonuç: `rejection_reason` daima null. Kaynak karnesi red **oranını** gösteriyor (`kaynak_karnesi_screen.dart:132`), ama "neden reddedildi" verisi hiçbir yerde olmadığı için bir kaynağı kapatma kararı gerekçelendirilemiyor.

### 2.8 Kuyruk canlı değil, buna karşılık her işlem tüm arşivi yeniden indiriyor — yüksek etki / orta maliyet
- `watchPendingArticles` `.asStream()` kullanıyor (`home_repository.dart:82`) — tek seferlik sorgu, Realtime değil. Hat gün içinde yeni haber yazdığında kuyruk kendiliğinden güncellenmiyor; sayfayı yenilemek gerekiyor ve ekranda "yenile" düğmesi de yok.
- Aynı sorgu `select('*')` ve **limitsiz** (satır 80–83): bekleyen her haberin `content` + `content_en` HTML gövdesi iniyor.
- `_tazele` (`admin_statistics_screen.dart:605–611`) her onay/red sonrası `latestArticlesProvider`'ı da geçersiz kılıyor. O sorgu da şu an `select('*')`, limitsiz (`home_repository.dart:44–48`).

**Not:** §20.1'de anlatılan daraltma (`_listeSutunlari` sekiz ağır sütunu dışarıda bırakıyor, `_listeSiniri = 500`) depoda **bulunamıyor** — bu iki ad hiçbir dosyada geçmiyor ve `home_repository.dart` içindeki tek `limit(` satır 360'ta (haftalık özet, 400). §40.5'teki kayıp listesiyle tutarlı bir gerileme olabilir; canlı derlemeyle karşılaştırılması gerekir. Mevcut hâlde: §30'daki ~39 haber/gün kararı × tüm yayın arşivi = günde onlarca kez tam arşiv indirmesi.

### 2.9 Kuyruk hatada sonsuz spinner gösteriyor — orta etki / küçük maliyet
```dart
// home_repository.dart:85-91
.handleError((e) {
  if (kDebugMode) print('watchPendingArticles error: $e');
  return <NewsArticle>[];
});
```
`handleError` geri dönüş değerini kullanmaz; hata yutulduğu için akış ne yayın yapar ne hata verir. `StreamProvider` `loading`de kalır ve `admin_statistics_screen.dart:286`'daki `error:` dalı bu yoldan hiç çalışmaz. Moderatör bozulma ile "bekleyen haber yok"u ayırt edemez.

### 2.10 Kuyrukta düzenleme yolu yok: bozuk başlık ya olduğu gibi onaylanıyor ya reddediliyor — orta etki / orta maliyet
İnceleme kartı yalnızca iki alanı yazabiliyor: `image_url` (`inceleme_karti.dart:300–306`) ve gövde (`content`/`content_en`, satır 316–322). Başlık, özet, spot, konu, bölge düzenlenemiyor. Editör formuna geçmek de çözüm değil: o liste `latestArticlesProvider`dan beslendiği için (`dashboard_screen.dart:497`) sadece **yayındaki** haberleri gösteriyor — bekleyen haber orada hiç listelenmiyor. §30'da "gelişmiş alanlar düzenlenebilir" diye geçen yetenek depoda yok; formdaki ilgili alanlar salt okunur bilgi satırı (`dashboard_screen.dart:991–996`).

### 2.11 Toplu işlemde yalnızca RED var — orta etki / küçük maliyet
`_topluCubuk` (`admin_statistics_screen.dart:289–330`) tek bir toplu düğme taşıyor: "Toplu red". §30 "toplu yayınla/reddet" diyor; toplu onay tarafı depoda yok. Günde ~39 haberin kabul edilenleri tek tek tıklanıyor.

### 2.12 Ekran "İstatistikler" sekmesinin ortasına gömülü ve bekleyen sayacı yok — orta etki / küçük maliyet
Kuyruk, `dash_tab_stats` etiketli grafik sekmesinin (`dashboard_screen.dart:457–460`) içinde, iki istatistik bloğunun arasında duruyor (`admin_statistics_screen.dart:118–128`: üstünde "En çok okunan", altında "Haber Okuma Sıralaması (İlk 50)"). Yedi sekmenin hiçbirinde "onay" sözcüğü ya da bekleyen sayısı yok. Panele giren kişi kaç haberin kararını beklediğini ekranı bulup aşağı kaydırmadan öğrenemiyor.

### 2.13 Hâlâ duran bir silme yolu ve yanlış bilgilendiren snackbar — orta etki / küçük maliyet
`dashboard_screen.dart:1475–1479` `isReviewing` dalında `rejectArticle`ı çağırıyor; o metot (`home_repository.dart:301–312`) §29.1'in kaldırdığı `delete()`'i yapıyor ve arayüz "Haber reddedildi ve silindi." yazıyor. İki ayrı sebeple yanlış: (a) `20261029030000_articles_panel_yazma.sql` `authenticated`'a DELETE **vermiyor**, dolayısıyla silme sessizce düşer ama mesaj "silindi" der; (b) dal zaten pratikte ölü, çünkü `latestArticlesProvider` yalnızca `published` çekiyor. Bu kod yolu kuyruğun doğru yoluyla çelişiyor.

### 2.14 Kuyruk sıralanmıyor, süzülmüyor, sayfalanmıyor — orta etki / orta maliyet
Tek sıralama `created_at desc` (`home_repository.dart:81`). Kaynağa, konuya (`topic`), bölgeye (`region`) ya da `hero_score`'a göre süzme/sıralama yok — üçü de modelde mevcut alanlar. Liste `shrinkWrap: true` + `NeverScrollableScrollPhysics` ile kuruluyor (`admin_statistics_screen.dart:266–273`), yani bütün kartlar bir kerede inşa ediliyor ve hemen altında 50 kayıtlık ikinci liste var (satır 633).

### 2.15 Oturum teşhisi kullanıcıya ulaşmıyor — orta etki / küçük maliyet
`_oturumSorunu` (`home_repository.dart:129–141`) "Oturum yok — panele yeniden giriş yapın." gibi işe yarar bir metin üretiyor, ama `alanlariGuncelle` onu yalnızca `kDebugMode` içinde basıp `false` dönüyor (satır 160–163). Release'de moderatörün gördüğü tek şey: "Reddetme başarısız — yetki yok ya da kayıt yazılamadı." (`admin_statistics_screen.dart:515`). `sonYazmaHatasi` alanı da tek yerde okunuyor: `admin_hero_screen.dart:386`.

### 2.16 Küçük dokunuşlar (düşük etki / küçük maliyet)
- İnceleme kartında kaynak adresi mavi yazılıyor ama **tıklanmıyor**: `SelectableText` (`inceleme_karti.dart:106–112`). Oysa aynı panelde çalışan bir `_launchUrl` var (`dashboard_screen.dart:1990`).
- `haberiReddet`in `title`, `sourceUrl`, `sourceName`, `lastStatus` parametreleri hiç kullanılmıyor (`home_repository.dart:246–258`); `topluReddet` bunları doldurmak için her haber adına sözlük kuruyor (`admin_statistics_screen.dart:567–575`) — ölü iş.
- "Tam haber" diyaloğu sabit `width: 640` (`admin_statistics_screen.dart:490`) — telefonda taşar.
- `_secili.removeWhere` `build` içinde durum değiştiriyor (`admin_statistics_screen.dart:264`).
- `withOpacity` kullanımı kalmış (`admin_statistics_screen.dart:650`), dosyanın geri kalanı `withValues` kullanıyor.

---

## 3. MODERN BİR HABER PORTALINDA OLMASI GEREKENLER (bu projede olmayan)

**a) Bekleyen sayısı — panele girince görünür.**
Mevcut malzeme: `source_scorecard` görünümünde `bekleyen` kolonu zaten var ve okunuyor (`kaynak_karnesi_screen.dart:132`). Ucuzu: `articles` üzerinde `status = 'reviewing'` için `count` sorgusu taşıyan ayrı bir `bekleyenSayisiProvider`; `dashboard_screen.dart:457`'deki `Tab`a `Badge` sarılır. `pendingArticlesProvider`'ı bu iş için beklemek, gövdeli tam kuyruğu indirmek demek olur.

**b) Bayatlık rozeti — "bu haber kaç günlük".**
`published_at` sütunu var (`20260816130000`), eksik olan modeldeki alan. `NewsArticle`'a `publishedAt` eklenip `fromJson`/`toJson`'a bağlanır; kartta `dashboard_screen.dart:852`'deki hazır `_buildBadge` kalıbıyla "Kaynak tarihi: … · 3 gün" rozeti basılır. Renk tek başına anlam taşımaz (§3.2) — rozette gün sayısı yazılı olur.

**c) Gerekçeli red — seçmeli liste.**
`rejection_reason` sütunu ve `haberiReddet(gerekce:)` zaten hazır; eksik olan diyalog. Sabit seçenekler (mükerrer / kaynak güvenilmez / bayat / konu dışı / çeviri bozuk / diğer) `kaynak_karnesi_screen.dart`'taki karneyle birleşince "bu kaynağı kapatalım mı" kararı veriye dayanır.

**d) Reddedilenler ekranı + geri alma.**
`reddiGeriAl` hazır. Gereken: `status = 'rejected'`, `order by rejected_at desc` okuyan `reddedilenlerProvider` (`home_providers.dart`'taki `pendingArticlesProvider` kalıbının aynısı) ve kuyruğun yanında bir "Reddedilenler" görünümü. `dashboard_screen.dart:1332`'deki `draft` süzgeci de bu durumu kapsayacak şekilde düzeltilir.

**e) Yayın öncesi gerçek önizleme.**
Kuyrukta "nasıl görünecek" sorusu cevapsız; CanvasKit tarafında metin tuvalde olduğu için ham HTML okumak bu soruyu cevaplamıyor. Mevcut yol hazır: `app_router.dart:194–201` `/haber/:id` rotası `extra` ile gelen `NewsArticle`'ı doğrudan `ArticleDetailScreen`e veriyor ve yayın durumuna bakmıyor. Kuyruktaki karta bir "Önizle" düğmesi, `reviewing` haberi okurun gördüğü düzende açar — yeni ekran yazmadan.

**f) Toplu onay.**
`topluReddet` (`home_repository.dart:265`) birebir kalıp: `topluOnayla` aynı döngüyü `approveArticle` ile kurar ve gerçekleşen sayıyı döner; `_topluCubuk`'a ikinci düğme girer.

**g) Klavyeyle karar.**
Günde ~39 karar (§30) fare ile veriliyor. Flutter `CallbackShortcuts`/`Shortcuts` ile `j/k` gezinme, `a` onayla, `r` reddet — `_PendingArticlesSection` içinde, yeni paket gerekmez.

**h) Onay denetim izi.**
`rejected_at` var, karşılığı yok: `approved_at` ve karar verenin kimliği (`auth.uid()`) tutulmuyor; panelde rol ayrımı da yok (`20261029030000` politikası `to authenticated using (true)`). Tek kişilik kullanımda sorun değil; ikinci bir editör girdiği anda "bunu kim yayınladı" sorusunun cevabı yok. Yeri: yeni bir migration + `approveArticle` içinde alan yazımı.

**i) Zamanlanmış yayın.**
§30 Aşama 3'te `publish_at` + `scheduled` + `publish_scheduled_articles()` RPC anlatılıyor; depoda bu adların **hiçbiri** geçmiyor (ne `lib/`, ne `supabase/`, ne `functions/`). Kurulacaksa: migration ile sütun + durum, `functions/index.js` içindeki bulut fonksiyon kalıbıyla beş dakikalık tetik, yazma SECURITY DEFINER RPC'den (anon'un UPDATE yetkisi olmadığı için mevcut kalıp bu).

**j) Onaylanan haberin listeye nereye girdiği.**
Ana sayfa `created_at desc` sıralıyor (`home_repository.dart:47`). Kuyrukta iki gün bekleyip onaylanan haber, listeye iki gün derinden giriyor — yani pratikte görünmeden yayınlanıyor. `hero_pinned_at` için benzer sorun bilinçli olarak çözülmüş (`news_article.dart:27–33`: "eski bir haberi bugün öne çıkarmak isteyen editörün müdahalesi doğduğu anda ölürdü"). Aynı akıl yürütme onay anı için de geçerli: onay damgası tutulup sıralamada kullanılabilir. Karar kullanıcının.

---

## 4. ÖNCELİKLİ YOL HARİTASI

### HEMEN — küçük maliyet / yüksek etki

| # | İş | Dosya | Tahmini boy |
|---|---|---|---|
| 1 | Onay kuyruğunu `latestArticlesProvider`ın `isEmpty` dalından çıkarmak (§2.1) — kuyruk kendi `when`'ine alınır | `admin_statistics_screen.dart:23–30, 114–125` | ~20 satır, 30 dk |
| 2 | `approveArticle`'ı `alanlariGuncelle` üzerinden geçirmek (oturum denetimi + satır sayımı) ve çağrı yerinde sonucu snackbar'la söylemek (§2.2) | `home_repository.dart:97–108`, `admin_statistics_screen.dart:447–452` | ~15 satır, 30 dk |
| 3 | `article_format` + `chart_data_en`'i form kaydında taşımak (§2.4) — veri kaybı durur | `dashboard_screen.dart:310–348` | 2 satır, 10 dk |
| 4 | Mükerrer denetiminde hatayı yeşil "temiz" olarak göstermeyi bırakmak (§2.3) — ayrı bir `_hata` durumu | `inceleme_karti.dart:168–180, 134–150` | ~15 satır, 30 dk |
| 5 | Red gerekçesi diyaloğu + `gerekce` parametresini geçmek (§2.7) | `admin_statistics_screen.dart:505–512, 546–582`, `home_repository.dart:270–276` | ~60 satır, 1,5 sa |
| 6 | `publishedAt` alanını modele ekleyip kartta tarih/bayatlık rozeti göstermek (§2.5, §3-b) | `news_article.dart` (alan + `fromJson`/`toJson`), `admin_statistics_screen.dart:342–380` | ~40 satır, 1,5 sa |
| 7 | Sekmede bekleyen sayacı (§3-a) + `handleError` yerine hatayı yayan akış (§2.9) | `dashboard_screen.dart:457`, yeni `bekleyenSayisiProvider`, `home_repository.dart:85–91` | ~50 satır, 2 sa |
| 8 | Ölü ve yanlış bilgilendiren silme yolunu kaldırmak (§2.13); kaynak adresini tıklanabilir yapmak, 640 px diyaloğu esnetmek (§2.16) | `dashboard_screen.dart:1468–1500`, `inceleme_karti.dart:106–112`, `admin_statistics_screen.dart:490` | ~30 satır, 1 sa |

### SONRA — orta maliyet

| # | İş | Dosya | Tahmini boy |
|---|---|---|---|
| 9 | **Reddedilenler görünümü + geri alma** (§2.6): `reddedilenlerProvider` + kuyruğun yanında ikinci sekme/segment; `dashboard_screen.dart:1332`'deki `draft` süzgeci düzeltilir | `home_providers.dart`, `home_repository.dart`, `admin_statistics_screen.dart` | ~150 satır, yarım gün |
| 10 | **Önizleme düğmesi** (§3-e): `/haber/:id` + `extra: article` ile okur düzeninde açma | `admin_statistics_screen.dart:420–460` | ~15 satır, 1 sa (rota hazır) |
| 11 | **Toplu onay** (§2.11): `topluOnayla` + `_topluCubuk`'a ikinci düğme, gerçekleşen sayı raporu | `home_repository.dart` (`topluReddet` kalıbı), `admin_statistics_screen.dart:289–330` | ~70 satır, 2 sa |
| 12 | **Kuyrukta düzenleme** (§2.10): başlık/özet/spot için `alanlariGuncelle` tabanlı satır içi düzenleme — `toJson` yolu kullanılmaz (§25.1) | `inceleme_karti.dart` | ~200 satır, 1 gün |
| 13 | **Sorgu yükü** (§2.8): `watchPendingArticles`a sütun daraltma + `limit`; `_tazele`nin `latestArticlesProvider`ı geçersiz kılmasını gözden geçirmek; §20.1 daraltmasının canlıda duruyor mu ölçülmesi | `home_repository.dart:44–48, 78–91`, `admin_statistics_screen.dart:605–611` | ~80 satır + ölçüm, yarım gün |
| 14 | **Klavye kısayolları** (§3-g) ve kaynağa/konuya göre süzme, `hero_score`'a göre sıralama (§2.14) | `admin_statistics_screen.dart` | ~150 satır, yarım gün |
| 15 | **Oturum teşhisini ekrana taşımak** (§2.15): `alanlariGuncelle` `_oturumSorunu` metnini `sonYazmaHatasi`'na yazsın, kuyruk onu göstersin | `home_repository.dart:158–176`, `admin_statistics_screen.dart:505–520` | ~20 satır, 1 sa |

### BÜYÜK İŞ — mimari

| # | İş | Neden mimari | Dokunulacak yer |
|---|---|---|---|
| 16 | **Onay kuyruğunu kendi ekranına taşımak** — `/panel/onay` rotası, kendi sekmesi, istatistik ekranından ayrılması (§2.1, §2.12). Kuyruk bugün istatistik ekranının yaşam döngüsüne ve veri bağımlılığına bağlı; ayrılmadan 1 ve 13 kalıcı çözülmüyor | yeni `features/dashboard/presentation/screens/onay_kuyrugu_screen.dart`, `app_router.dart:369`, `dashboard_screen.dart:435–489` | 1–2 gün |
| 17 | **Gerçek canlı kuyruk** — `.asStream()` yerine Supabase Realtime abonesi; §20.4'te ziyaretçi tarafı için bilerek Realtime kullanılmıyor, ama panel tek haneli kullanıcı demek, eşzamanlılık limiti sorunu değil. Ölçüm olmadan yapılmaz | `home_repository.dart:78–91`, `home_providers.dart:197` | 1 gün + ölçüm |
| 18 | **Zamanlanmış yayın** (§3-i): `publish_at` + `scheduled` durumu + SECURITY DEFINER RPC + bulut fonksiyonu tetiği | yeni migration, `functions/index.js`, `news_article.dart`, kuyruk ekranı | 2 gün |
| 19 | **Denetim izi ve rol ayrımı** (§3-h): `approved_at`/`approved_by`, muhabir–editör ayrımı, RLS politikasının rol bazlı yazılması | yeni migration (`20261029030000` kalıbı), `home_repository.dart`, `login_screen.dart` | 2–3 gün |
| 20 | **Onay anının sıralamada kullanılması** (§3-j) — kullanıcı kararı gerektirir: kuyrukta bekleyen haber onaylandığında ana sayfada nereye girecek | `home_repository.dart:44–48`, `home_providers.dart`, yeni sütun | yarım gün + karar |

**Dağıtım notu:** maddelerin hiçbiri yayına alma adımı içermiyor; `deploy.sh` ancak açık onayla çalıştırılır.