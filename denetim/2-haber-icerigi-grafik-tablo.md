# Haber içeriği denetimi — metin, grafik, infografik, tablo

**Kapsam:** `/Users/BURHAN/Desktop/tarim_app` · haber gövdesi, `chart_data` çizicisi, editoryal kutular, sunucu tarafı metin.
**Yöntem:** dosyalar açılıp okundu; iddiaların sayısal olanları **yayındaki 1.047 haberin tamamı** üzerinde ölçüldü (Supabase anon, salt okuma), SSR çıktısı canlı siteden indirilip doğrulandı.

---

## 1. BUGÜN NE İYİ ÇALIŞIYOR

- **Grafik kapsaması gerçekten yüksek ve türü çeşitli.** Yayındaki 1.047 haberin **691'inde (%66) `chart_data` var**: 305 tablo, 168 rakam kartı, 107 yatay çubuk, 99 çubuk, 10 çizgi, 2 halka. Yedi tip `dynamic_chart_widget.dart:62-82`'de dağıtılıyor; bu, haber sitelerinde alışılmış orandan belirgin yüksek.
- **Tablo dar ekranda kırpmıyor, düzen değiştiriyor.** `_DataTable` sütun genişliğini içerikten hesaplıyor (`dynamic_chart_widget.dart:715-721`), sütun başına 120 px'in altına inince `_Yigin` blok düzenine geçiyor (`satır 736-748`) ve hiçbir hücrede `TextOverflow.ellipsis` yok. Dört widget testiyle korunuyor (`test/haber_tablosu_test.dart`). §10.1'de alınan karar kodda yaşıyor.
- **Tek rakamın kendi düzeni var.** `_TekRakam` (`satır 553-640`), bir rakamı üçte bir genişlikte rozet gibi bırakmak yerine gazetenin "büyük sayı" kutusuna çeviriyor; gerekçesi de kodun içinde ölçümle yazılı. 88 haber bu yola düşüyor.
- **İki dillilik metinde eksiksiz, grafikte denetimli.** `content_en` 1.000/1.000 dolu; `chart_data_en` 691 grafiğin **614'ünde** var, kalan 77'si §10.2'nin "yarısı çevrilmiş tablo hepsi Türkçe olandan kötüdür" kuralı gereği bilerek Türkçe kalıyor. `key_takeaways`/`expert_insight` 805 haberde var, 789'unda İngilizcesi de hazır.
- **Doğrulama verisi haber başına yapılandırılmış duruyor.** `facts` 919/1.000, `figures` 749/1.000, `quotes` 449/1.000 dolu — ve `figures` kalemlerinin her biri `label/value/unit/period/**source**` taşıyor. İnceleme masası bunu okuyor (`lib/features/dashboard/presentation/widgets/inceleme_karti.dart:350-455`).
- **Okuma künyesi ve kaynak şeffaflığı yerinde.** Okuma süresi 200 kelime/dk ile hesaplanıp basılıyor (`article_detail_screen.dart:271-283, 734`); `source_name` 1.000/1.000, `source_url` 397/400 dolu ve `_SourceButton` ile gösteriliyor.
- **Canlıda SSR gövdesi çalışıyor.** Ölçtüm: `/haber/d4a7606d…` sayfasında işaretler arası **3.809 karakter** `<article>`, JSON-LD `articleBody`, `hreflang="en"` bağlantısı dolu geliyor.

---

## 2. EN ÖNEMLİ EKSİKLER

### 2.1 Okura gösterilen tarih yayın tarihi değil, bizim kayda giriş saatimiz
**Etki: yüksek · Maliyet: küçük**

`article_detail_screen.dart:267-269`:

```dart
final formattedDate = DateFormat.yMMMd(isEn ? 'en_US' : 'tr_TR')
    .add_Hm()
    .format(article.createdAt);
```

Okur bunu `satır 734`'te `'$formattedDate • $readLabel'` olarak dakikasına kadar görüyor. Ama `created_at` haberin veritabanımıza yazıldığı andır. Haberin gerçek yayın tarihi ayrı bir kolonda duruyor ve ne anlama geldiği migration'da yazılı — `supabase/migrations/20260816130000_yayin_tarihi_ve_red_hafizasi.sql:19-23`:

> `published_at date` — *'Kaynak sayfadan çıkarılan gerçek yayın tarihi. Besleme beyanı değildir.'*

**Ölçüm (1.000 haber):** `published_at` ile `created_at` **981 haberde 1 saatten fazla** ayrışıyor; sapma örnekleri 24, 48, 72, **168 saat**. Yani kaynağın 22 Ekim'de yayımladığı bir haber sayfada "29 Eki 2026 23:47" damgasıyla duruyor.

Aynı yanlış tarih arama motoruna da gidiyor: `functions/index.js:356` `article:published_time`'ı, `satır 382-383` JSON-LD `datePublished`/`dateModified`'ı `article.created_at`'ten yazıyor; canlı SSR çıktısındaki `<time datetime="2026-09-09T08:15:40">` de aynı alandan.

Ek engel: **`published_at` modelde hiç yok.** `lib/features/home/data/models/news_article.dart` içinde `publishedAt` diye bir alan bulunmuyor (grep: 0 sonuç) — kolon veritabanında dolu, uygulamaya hiç alınmıyor.

Bu, §27.1'in ruhuyla doğrudan çelişiyor: hat, **yaşı doğrulanamayan içeriği yayınlamamak** için trafilatura'nın uydurduğu tarihleri YouTube akışından düzeltiyor; ekran ise o doğrulanmış tarihi hiç göstermiyor.

### 2.2 Ana sayfa sorgusu bütün arşivi gövdesiyle indiriyor — §20.1 düzeltmesi depoda yok
**Etki: yüksek · Maliyet: küçük (geri yazım)**

`lib/features/home/data/repositories/home_repository.dart:43-48`:

```dart
yield* _supabaseClient
    .from('articles')
    .select('*')
    .eq('status', 'published')
    .order('created_at', ascending: false)
```

Ne `_listeSutunlari` ne `_listeSiniri` var (grep: 0 sonuç) — oysa §20.1 tam olarak bu ikisini getirmiş ve **2,62 MB → 0,22 MB** ölçmüştü. Üstelik düzeltmenin **yorumu hâlâ ayakta**: aynı dosyanın `satır 192`'si "`[watchLatestArticles]` en yeni 500 haberi taşıyor" diyor. Kod gitmiş, cümle kalmış (§8.5'teki 4 Ekim iCloud kaybıyla aynı imza).

**Yeniden ölçtüm (bugün, canlı):**

| | §20.1 (6 Eyl) | bugün |
|---|---|---|
| gzip | 2,74 MB | **4,08 MB** |
| açılmış | 6,4 MB | **10,67 MB** |
| kayıt | 771 | 1.000 (PostgREST üst sınırı) |

Yükün dökümü — ve burası bu raporun alanı: toplam 9,4 MB JSON'un **6,2 MB'ı (%66)** §20.1'in dışarı aldığı sekiz ağır sütun (`content` 2,00 MB, `content_en` 2,12 MB, `chart_data` 0,36 MB, `chart_data_en` 0,34 MB, `key_takeaways(_en)` 0,73 MB, `expert_insight(_en)` 0,69 MB). Üstüne **okura hiç gösterilmeyen** `figures` 0,62 MB + `quotes` 0,48 MB + `facts` 0,45 MB geliyor (%16,5). Kartta kullanılmayan içerik, ana sayfa yükünün **%82'si**.

Ayrıca `satır 56-64` bu 10 MB'ın tamamını Hive'a yazıyor — §20.3'te "çevrimdışı tam metin okuma düştü" diye kabul edilen bedel de geri gelmiş durumda.

### 2.3 Grafikteki sayı Türkçe biçimlenmiyor; birim sayıya yapışık yazılıyor
**Etki: yüksek · Maliyet: küçük**

`dynamic_chart_widget.dart:16-20`:

```dart
String _formatValue(dynamic val) {
  if (val is String && double.tryParse(val.replaceAll(',', '.')) == null) return val;
  final d = _parseDouble(val);
  return d % 1 == 0 ? d.toInt().toString() : d.toStringAsFixed(1);
}
```

`toInt().toString()` binlik ayıraç koymuyor. Değer dört ayrı yerde birimle **boşluksuz** birleştiriliyor: `satır 180` (çubuk), `280` (yatay çubuk), `427` (halka döküm), `508` (rakam kartı) — hepsi `Text('$formatted$unit')`.

**Ölçüm:** tablo dışı grafiklerde **180 hücre / 69 haber** dört haneden büyük sayı basıyor. Ekranda görünen:

- `45000TL/ton` (doğrusu *45.000 TL/ton*) — pirinç çeşit fiyatları, `0d8e6c55-…`
- `200000tenge/ton` — Kazakistan ayçiçeği, `8b429366-…`
- `1083000TL / Adet`, `19adet`, `50Değer` — **69 çok kartlı rakam grafiğinde** birim harfle başlıyor ve sayıya yapışıyor.

**Çözüm zaten projede var ve gerekçesi yazılı** — `lib/features/dossiers/data/models/dossier_chart.dart:146-156`:

```dart
/// Binlik ve ondalık ayıracı yerele göre değişiyor: `1.234,5` ve `1,234.5`.
/// Elle yazmak yerine intl'e bırakıldı…
final govde = NumberFormat(desen, isEn ? 'en_US' : 'tr_TR').format(v);
```

`SayiBicimi` ayrıca `bolen` ile "58.900.000 kg → 58,9 milyon kg" indirgemesini ve `onek`/`sonek`'i yapıyor. Haber grafiği bu sınıfın hiçbirini kullanmıyor.

### 2.4 Türkçe büyük harf tuzağı haber grafiğinde duruyor — 43 haberde yanlış harf
**Etki: yüksek · Maliyet: küçük**

İki ham çağrı var:

- `dynamic_chart_widget.dart:597` → `label.toUpperCase()` (tek rakam kutusunun etiketi)
- `dynamic_chart_widget.dart:913` → `giris.key.toUpperCase()` (dar ekran blok düzeninde sütun başlığı)

Oysa doğru araç yazılmış ve **neden var olduğu** `lib/core/utils/turkce_metin.dart:1-25`'te anlatılmış: *"Yanlış harf de bir büyük harf olduğu için gözle fark edilmesi zor"*; `buyukHarf(metin, isEn)` bayrak zorunlu tutuyor. §8.5 bu hatanın `_Kartlar.ust`'ta da bulunup çevrildiğini not ediyor — haber grafiği o turda atlanmış.

**Ölçüm:** 88 tek-kart grafiğinin **43'ünde** çıktı yanlış:

| veride | ekranda | olması gereken |
|---|---|---|
| Hibe desteği üst sınırı | HIBE DESTEĞI ÜST SINIRI | HİBE DESTEĞİ ÜST SINIRI |
| Kapasite | KAPASITE | KAPASİTE |
| Ekim 2026 | EKIM 2026 | EKİM 2026 |
| Sezon İçi Uygulama | SEZON İÇI UYGULAMA | SEZON İÇİ UYGULAMA |
| Görev Dönemi | GÖREV DÖNEMI | GÖREV DÖNEMİ |

`satır 913` şu an sessiz: yayındaki 305 tablonun sütun şablonu 269 kez `Değer | Dönem | Ölçüm`, 36 kez `Değer | Ölçüm` — hiçbirinde noktalı `i` yok. Ama "Birim", "Bitki", "İhracat" gibi bir başlık geldiği gün aynı hata üretime çıkar.

### 2.5 Grafiğin kaynağı ve metodoloji notu için alan yok
**Etki: yüksek · Maliyet: küçük-orta**

`chart_data` şeması `type / title / subtitle / unit / data` (`ai_columnist_bot.py:88-96`); `DynamicChartWidget.build` (`satır 52-56`) yalnızca bunları okuyor. Kaynak için ayrı alan yok — `subtitle` ("Veri kaynağı veya tarih aralığı") bu işe koşulmuş.

**Ölçüm: 691 grafiğin 221'inde (%32) `subtitle` boş.** Yani her üç grafikten biri, altında tek satır kaynak olmadan rakam yayınlıyor. 310'unda `unit` da boş.

Bu, projenin kendi standardının altında kalıyor iki yönden:

- §2.2: *"Kaynağı olmayan sayı metne girmez."* ve *"Yuvarlamayı tercih et."*
- `dossier_chart.dart:170-178` — dosya grafiklerinin **`not`** (metodoloji uyarısı: *"cari dolar, enflasyondan arındırılmamıştır"*) ve **`kaynak`** diye iki ayrı alanı var. Haber grafiğinde ikisi de yok.

En can sıkıcısı: **veri elimizde.** `figures` kolonunun her kalemi `source` ve `period` taşıyor (örnek: `{"label":"Faydalanan çiftçi sayısı","value":167,"unit":"kişi","period":"","source":"Mazıdağı İlçe Tarım ve Orman Müdürlüğü"}`) — 749 haberde dolu, yalnızca inceleme masasında okunuyor, okura hiç ulaşmıyor.

### 2.6 Grafik ve tablo yalnızca tuvalde — ne aramada ne ekran okuyucuda
**Etki: yüksek · Maliyet: orta**

Canlı SSR çıktısını satır satır okudum: `<h1>`, `<time>`, kapak `<img>`, spot, `<h2>`'ler, `<blockquote>`, `hreflang` var. **`chart_data`'dan tek karakter yok.** `functions/index.js` dosyasının tamamında `chart` dizesi **0 kez** geçiyor. `dynamic_chart_widget.dart` içinde `Semantics` **0 kez** geçiyor.

Sonuç: 691 haberin en alıntılanabilir içeriği — "442 TL/dekar", 305 tablonun bütün hücreleri, 180 büyük rakam — §19.1'in tarif ettiği duruma geri düşüyor: CanvasKit metni tuvale piksel olarak çiziyor, DOM'da yok. Google bu sayıları göremiyor, ekran okuyucu okuyamıyor, okur kopyalayamıyor.

### 2.7 Depodaki `ogRenderer` canlının gerisinde — bir `functions` deploy'u SEO gövdesini sessizce siler
**Etki: yüksek · Maliyet: orta**

`deploy.sh:97-106` şunu söylüyor:

```
# Aynı gerekçe gövde işaretleri için: bunlar olmadan `ogRenderer` ve
# `homeRenderer` haber metnini sayfaya yazamaz…
```

ve `satır 108-114` ekliyor: *"`functions/shell.html` işaretleri BOŞ haliyle alıyor, çünkü `ogRenderer` oraya haberin kendi gövdesini yazacak."*

Depodaki `ogRenderer` bunu **yapmıyor**. `functions/index.js:418-478` yalnızca `inject(SHELL, block, jsonLd(...))` çağırıyor; `inject` (`satır 403-414`) `SOCIAL_META_START/END` arasını değiştiriyor — `MARKER_START`/`MARKER_END` sabitleri `satır 63-64`'te o işaretlere bağlı. `SSR_CONTENT` dizisi `functions/` altında **hiç geçmiyor**. `jsonLd` (`satır 375-398`) `articleBody` yazmıyor. §19.4'ün anlattığı `sanitizeHtml` fonksiyonu depoda **yok** (grep, `node_modules` hariç: 0 sonuç).

Canlıda ikisi de çalışıyor (3.809 karakter gövde + `articleBody`). Yani §19'un en önemli parçası **canlıda var, depoda yok** — tıpkı §20.1 gibi. `deploy.sh`'in bekçisi işaretin *varlığını* denetliyor, *dolup dolmadığını* denetlemiyor; bu yüzden depodan yapılacak tek bir `functions` dağıtımı siteyi §19.1'deki duruma geri döndürür — ve bekçi "✓" der.

### 2.8 Gövde metninin iç yapısı zayıf: ara başlık yok, liste yok, görsel künyesi yok
**Etki: orta · Maliyet: orta**

Yayındaki 1.000 haberin gövdesinde (`content`) ölçtüm:

| öğe | kaç haberde |
|---|---|
| `<h2>` ara başlık | **339** (661 haberde hiç yok) |
| `<ul>` / `<ol>` liste | **0** |
| `<a href>` gövde bağlantısı | **0** |
| `<img>` gövde görseli | 386 |
| `<figcaption>` görsel künyesi | **0** |
| `<blockquote>` | 185 |
| `<table>` | 1 |

Gövde ortancası 1.491 karakter (≈240 kelime), %95'lik dilim 4.438. Yani 4.400 karakterlik haberlerin çoğu **tek bir ara başlık olmadan** akıyor; §39.1'de tanımlanmış `.dsy-h2` sınıfı tüm arşivde 10 kez kullanılmış.

Buna karşılık `article_detail_screen.dart:443-490` `<table>`, `<th>`, `<td>`, `<blockquote>`, `<img>`, `<h2>` için stil tanımlıyor — yani kabiliyet var, içerik yok. Gövde içinde tek bir bağlantı olmaması aynı zamanda §19.1'in *"hiç link olmadığı için tarayıcı siteye girip hiçbir yere gidemiyordu"* teşhisinin haber-içi karşılığı: iç bağlantı dokusu sıfır.

### 2.9 Yazı boyu denetimi grafiğe ve editoryal kutulara işlemiyor
**Etki: orta · Maliyet: küçük**

`fontScaleProvider` 0,8×–1,5× arası kalıcı bir okur tercihi (`font_scale_provider.dart:8-12`). `article_detail_screen.dart`'ta **dört** yere uygulanıyor: başlık (`402`), spot (`412`), gövde (`450`), `h2` (`465`).

Uygulanmadığı yerler:
- **Öne Çıkanlar kutusu** — `satır 1491` `fontSize: 16` sabit
- **Uzman Görüşü kutusu** — `fontSize: 17` sabit
- **Grafiğin tamamı** — `DynamicChartWidget` `satır 439`'da ölçek parametresi almıyor; içinde tablo hücresi 11 pt (`satır 799`), sütun başlığı 10 pt (`satır 783`), kart etiketi 10 pt (`satır 497`), halka döküm 10 pt (`satır 427`) sabit.

Okur yazıyı 1,5 katına çıkardığında gövde büyüyor, tablo 11 puntoda kalıyor — yani en çok büyütmeye ihtiyaç duyan öğe hiç büyümüyor.

### 2.10 Grafik her zaman gövdeden önce, haber başına bir tane
**Etki: orta · Maliyet: orta**

`article_detail_screen.dart:437-441` grafiği `Html` gövdesinden **önce**, sabit bir yere koyuyor. `news_article.dart:57` tekil: `final Map<String, dynamic>? chartData;`

İki sonuç: (a) 442 TL/dekar rakamını tartışan paragraf üç ekran aşağıdayken grafik en üstte duruyor — okur ikisini birbirine bağlayamıyor; (b) üç ayrı sayısal bulgusu olan uzun haberde (95'lik dilim 4.438 karakter) ikinci ve üçüncü bulgunun grafiği **yazılamıyor**, ya tek grafiğe sıkıştırılıyor ya düşüyor.

§39.2'de "ızgara galeri HTML olarak mümkün değil" diye not düşülen kısıt burada da geçerli ama çözümü farklı: `flutter_html` **tam CSS seçicisiyle** eşleşiyor (§39.1), yani gövdeye konan bir yer tutucu sınıf grafiği paragrafın yanına çağırabilir.

### 2.11 Tablo başlıkları yalnızca ilk satırdan okunuyor
**Etki: düşük (şimdilik) · Maliyet: küçük**

`dynamic_chart_widget.dart:721`: `final basliklar = data.first.keys.toList();`

İlk satırda olmayan bir sütun çizilmez, eksik anahtar boş hücre olur — **hata vermeden**. Ölçtüm: 305 tablonun **0'ında** satırlar farklı anahtar taşıyor, yani bugün zarar yok. Ama veri bir dil modelinden geliyor; sessiz veri kaybına açık bir kapı.

### 2.12 Küçük dokunuşlar (ölçüldü, etkisi düşük)

- **Ana sayfadaki SSR bağlantılarının bir kısmı ölü.** Ana sayfada gömülü 60 bağlantının ilki (`haber/3db979bc-…`) anon'a kapalı; o adres **HTTP 200** dönüyor ama içinde haberin meta'sı değil **ana sayfanın jenerik `og:title`'ı** ("Tarım Portalı - Tarımın Doğru Adresi") ve **hiç JSON-LD** yok — `ogRenderer`'ın `satır 436-439` erken dönüşü. Liste derleme anında üretildiği için (`scripts/ana_sayfa_linkleri.py`) sonradan yayından kaldırılan haberler yumuşak-404'e dönüşüyor.
- **Dört haberde boş WordPress kabuğu kalmış:** `<figure class="wp-block-image size-large"></figure>` — içi yok (§38.3 kabuk temizliğinin artığı).
- **`summary` 997/1.000 haberde `spot` ile birebir aynı.** Ayrı bir kolon, ayrı bir değer taşımıyor; meta açıklama zaten 160'a kırpılıyor (`functions/index.js:446`).
- **Gövdeye bağlantı eklendiği gün tıklanmaz.** `article_detail_screen.dart:444` `Html(...)` çağrısında `onLinkTap` yok; `flutter_html 3.0.0` `lib/src/html_parser.dart:93` `onLinkTap?.call(url, …)` yapıyor — null ise dokunma sessizce yutulur. Bugün gövdede 0 bağlantı olduğu için görünmüyor.
- **`_parseDouble` aralık değerini sıfırlıyor.** `satır 9-13` rakam dışını atıyor; `"15-20"` → `0.0`. Bugün bu 10 hücrenin **tamamı `stat` tipinde** (`"15-20"`, `"600-650 gram"`, `"2027-2029"`), yani çubuk uzunluğu hesaplanmıyor ve görünür etkisi yok. Çubuk/çizgi tipinde bir aralık yazıldığı gün grafik boş çizilir.
- **`unit` alanı bazen birim değil.** `"Standart"`, `"Değer"`, `"Sayı"` gibi değerler 69 grafikte sayıya ekleniyor ("40-50Standart").
- **Renk tek ayırt edici kalan tek yer halka grafiği.** `_DonutChart` döküm listesi 10×10 px renk karesiyle eşleşiyor (`satır 420-429`), biçim ayrımı yok — §3.2'nin *"Grafiklerde seriler renkle birlikte biçimle ayrılır"* kuralının dışında. Yalnızca **2 haberi** etkiliyor; dosya grafiklerindeki `_TaramaBoyaci` deseni buraya taşınabilir.

---

## 3. MODERN BİR HABER PORTALINDA OLMASI GEREKENLER

Her madde için projede **zaten duran** tablo/kolon/bileşen yazıldı.

### 3.1 Rakam künyesi — her grafiğin altında kaynak ve dönem satırı
- **Nasıl:** `chart_data` jsonb; migration gerekmez. İki anahtar eklenir: `kaynak` ve `not` — adları `dossier_chart.dart:175-178`'den birebir alınır ki iki dizi aynı sözlüğü kullansın.
- **Veri nereden:** `figures` kolonu zaten `source` + `period` taşıyor (749/1.000). Hat tarafında `figures[i].source` → `chart_data.kaynak` eşlemesi yazılır; boşsa grafik **kaynaksız yayınlanmaz** (§2.2'nin "kaynağı olmayan sayı metne girmez" kuralının grafik karşılığı).
- **Çizim:** `DynamicChartWidget.build`'deki filigran bloğunun (`satır 126-136`) üstüne iki satır; `not` varsa `_subtle` renkte, `kaynak` ondan bir tık koyu.

### 3.2 Türkçe sayı biçimi ve birim ayrımı
- **Nasıl:** `_formatValue` (`dynamic_chart_widget.dart:16-20`) `NumberFormat('#,##0', isEn ? 'en_US' : 'tr_TR')` kullanır; `dossier_chart.dart:130-156`'daki `SayiBicimi` sınıfı olduğu gibi `lib/core/`'a taşınıp iki dizi tarafından paylaşılabilir (`bolen` sayesinde "58.900.000 kg → 58,9 milyon kg" indirgemesi de bedava gelir).
- Birim ayrımı: dört `'$formatted$unit'` çağrısı (`180, 280, 427, 508`) birimi ayrı `Text`'e alır — `_TekRakam` (`satır 610-630`) bunu zaten doğru yapıyor, gerekçesi de kodda: *"aynı puntoda yazıldığında '16500TL/ton' tek bir simge yığınına dönüşüyor"*.

### 3.3 Grafik ve tablonun metin karşılığı sunucudan gitsin
- **Nasıl:** `ogRenderer`'a `select` listesine `chart_data` eklenir; `chart_data.type == 'table'` ise gerçek `<table><caption>` + `<th>` + `<td>` HTML'i, diğer tiplerde `<figure><figcaption>başlık + kaynak</figcaption>` + `<dl>` etiket/değer listesi yazılır. `inject` ikinci bir işaret çifti (`SSR_CONTENT`) için genelleştirilir.
- **Yan kazanç:** HTML tablo, Google'ın zengin sonuçlarında ve alıntılarda görünür; `<dl>` ekran okuyucuda sıralı okunur.
- **İstemci tarafı:** `DynamicChartWidget`'ın en dış `Container`'ı (`satır 87`) bir `Semantics(label: …)` ile sarılır — etiket metni aynı üreticiden gelir, tek kaynak.

### 3.4 Gövde içine gömülü grafik ve haber başına çoklu grafik
- **Nasıl:** `chart_data` tek nesneden **diziye** çıkar (jsonb, migration'sız; `news_article.dart:57` `List<Map>`'e döner, eski tek nesne `[tek]` olarak okunur). Gövdeye yer tutucu konur: `<div class="dsy-grafik" data-i="1"></div>`.
- **Neden mümkün:** §39.1'in bulduğu şey — `flutter_html` stil haritasını **tam CSS seçicisiyle** eşliyor (`tree/styled_element.dart` → `matchesSelector`). Aynı mekanizma `extensions` ile sınıfa bağlı **widget** döndürmek için de kullanılabilir; kodda haber kimliği, veritabanında yeni kolon gerekmez.
- Yer tutucu yoksa davranış bugünküyle aynı kalır: grafikler gövdenin üstünde.

### 3.5 Alıntı bloğu bileşeni — `quotes` kolonu
- **Veri hazır:** 449/1.000 haberde `[{"text": "...", "speaker": "Ömer Faruk Beyaz", "title": "Fındık Üreticisi"}]`.
- **Nasıl:** `_ExpertInsightBox` (`article_detail_screen.dart:1504+`) kardeşi bir `_AlintiBlogu` yazılır; konuşanın adı **ve sıfatı** ayrı satır. Bugün gövdedeki 185 `<blockquote>` sıfatsız: §39.1'de tanımlı `.dsy-alinti` sınıfı tüm arşivde 2 kez kullanılmış.

### 3.6 5N1K kutusu — `facts` kolonu
- **Veri hazır:** 919/1.000 haberde `{who, what, when, where, why, how}` dolu (örnek: `"when": "Güncel sezon"`, `"where": "Mardin, Mazıdağı"`).
- **Nasıl:** `_KeyTakeawaysBox` ile aynı kalıpta altı satırlık bir kutu; `_Yigin`'in etiket/değer deseni (`dynamic_chart_widget.dart:896-930`) hazır örnek. Boş alan **çizilmez** (§3.5'in "görsel bir katman, taşıyıcı değil" mantığı).
- Bu kutu aynı zamanda §2.8'deki yapı boşluğunu kapatıyor: ara başlığı olmayan 661 haber en azından tarayıcı bir çatı kazanır.

### 3.7 Görsel künyesi ve altyazı
- **Nasıl:** `.dsy-foto` sınıfı §39.1'de tanımlı ve `article_detail_screen.dart` stil haritasında duruyor; gövdede 7 kez kullanılmış. Hat tarafında her `<img>`'den sonra `<p class="dsy-foto">Kaynak: …</p>` üretmek yeterli — yeni kod gerekmiyor.
- **Dikkat:** §39.6 — yayındaki gövdede desenle oynanmaz; eklemeden önce kaç şeyle eşleştiği yazdırılıp doğrulanır.

### 3.8 Düzeltme / güncelleme kaydı
- **Nasıl:** `updated_at` **bu işe yaramaz** — ölçtüm, 1.000/1.000 kayıtta `created_at`'ten farklı (her yazma, `view_count` dahil, onu bozuyor). Ayrı bir kolon gerekir: `duzeltme_notu text` + `duzeltildi_at timestamptz`.
- Gösterim: gövdenin altında, §28'in emtia kararıyla aynı çizgide — *eski bilgi gizlenmez, tarihiyle gösterilir*.

### 3.9 Tabloyu veri olarak alabilmek
- **Nasıl:** `_DataTable` başlığının yanına "kopyala" düğmesi; `chart_data.data` → TSV. Tuvaldeki tablodan okur bugün hiçbir şey seçemiyor.

---

## 4. ÖNCELİKLİ YOL HARİTASI

### HEMEN — küçük maliyet, yüksek etki

| # | İş | Süre | Dokunulacak dosyalar |
|---|---|---|---|
| H1 | **`_listeSutunlari` + `_listeSiniri = 500` geri yazılır.** §20.1'in reçetesi CLAUDE.md'de tam duruyor; `satır 192`'deki yorum koda yeniden uyar. §20.2 uyarısı geçerli: detay rotası gövdeyi sınayıp `fetchArticleById`'ye düşüyor mu, canlıda doğrula. | 1-2 s | `lib/features/home/data/repositories/home_repository.dart:43-48, 56-64` |
| H2 | **Türkçe büyük harf.** İki çağrı `buyukHarf(metin, isEn)`'e çevrilir; widget'a `isEn` parametresi geçilir (`article_detail_screen.dart:439`). 43 haber aynı anda düzelir. | 1 s | `dynamic_chart_widget.dart:597, 913` · `lib/core/utils/turkce_metin.dart` |
| H3 | **Sayı biçimi + birim boşluğu.** `_formatValue` `NumberFormat(…,'tr_TR')` kullanır; dört `'$formatted$unit'` ayrılır. 69 haberde görünür düzelme. | 2 s | `dynamic_chart_widget.dart:16-20, 180, 280, 427, 508` |
| H4 | **Yazı ölçeği grafiğe ve iki editoryal kutuya.** `DynamicChartWidget`'a `scale` parametresi; sabit puntolar `* scale`. | 2 s | `dynamic_chart_widget.dart` (punto sabitleri) · `article_detail_screen.dart:439, 1491, _ExpertInsightBox` |
| H5 | **Tarih kararı ve uygulaması.** `publishedAt` modele eklenir; ekranda `published_at` (tarih) esas alınır, `created_at` gerekiyorsa "portala giriş" olarak ikincil kalır. **Bu bir editoryal karar** — hangisinin künye tarihi olacağı kullanıcı onayı ister; kodu küçük, sonucu 981 haberi etkiliyor. `functions/index.js`'teki `article:published_time` ve JSON-LD `datePublished` aynı karara bağlanır. | 2-3 s | `news_article.dart` · `article_detail_screen.dart:267-269` · `functions/index.js:356, 382-383` · `home_repository.dart` select listesi |
| H6 | **`deploy.sh` bekçisi gerçek koruma yapsın.** İşaretin varlığı yetmez; `functions/index.js` içinde `SSR_CONTENT` dizisi ve `sanitizeHtml` aranır, yoksa dağıtım durur. Depo-canlı ayrışmasını bir daha sessiz bırakmaz. | 1 s | `deploy.sh:97-106` |

### SONRA — orta maliyet

| # | İş | Süre | Dokunulacak dosyalar |
|---|---|---|---|
S1 | **`ogRenderer` depoya geri yazılır.** Canlıdaki davranış (gövde `<article>` + `articleBody` + `sanitizeHtml`) §19.2/§19.4'teki tarife göre yeniden kurulur; dokuz saldırı vektörü testi de yeniden yazılır. Bu yapılmadan hiçbir `functions` dağıtımı güvenli değil. | 1 gün | `functions/index.js:63-64, 375-398, 403-414, 418-478`
S2 | **Grafik künyesi: `kaynak` + `not`.** Alanlar `chart_data`'ya eklenir, çizici basar, hat `figures[i].source`'tan doldurur; kaynaksız grafik yayına çıkmaz. Arşivdeki 221 kaynaksız grafik için `figures`'tan geri doldurma betiği. | 1-1,5 gün | `dynamic_chart_widget.dart:52-56, 126-136` · hat deposu (ev dizini) · geri doldurma betiği
S3 | **Grafik/tablonun SSR karşılığı.** `table` → gerçek `<table><caption>`; diğer tipler → `<figure><figcaption>` + `<dl>`. Aynı üreticiden `Semantics` etiketi. | 1-1,5 gün | `functions/index.js` (select + gövde üretimi) · `dynamic_chart_widget.dart:87`
S4 | **`facts` 5N1K kutusu + `quotes` alıntı bloğu.** Veri hazır (919 ve 449 haber); iki yeni bileşen, mevcut kutu kalıbıyla. | 1 gün | `article_detail_screen.dart` (yeni `_BesNBirK`, `_AlintiBlogu`) · `news_article.dart` (alanlar parse edilmiş durumda)
S5 | **Gövde yapısı hat tarafında zorunlu olur.** `<h2>` ve madde listesi üretimi; 661 haberde ara başlık yok, 1.000 haberde liste yok. Arşive **geriye dönük dokunulmaz** (§39.6). | 1 gün | hat deposu (istem + doğrulayıcı)
S6 | **Görsel künyesi.** `.dsy-foto` paragrafı 386 gövde görselinin altına; desen önce **kaç şeyle eşleştiği yazdırılarak** doğrulanır (§39.6). | yarım gün | hat deposu · `article_detail_screen.dart` stil haritası (sınıf zaten tanımlı)
S7 | **Ölü SSR bağlantıları.** `ana_sayfa_linkleri.py` yalnızca anon'un okuyabildiği kayıtları yazar; `ogRenderer` bulunamayan haberde **404** döner, ana sayfa meta'sıyla 200 dönmez. | yarım gün | `scripts/ana_sayfa_linkleri.py:55-80` · `functions/index.js:426-439`

### BÜYÜK İŞ — mimari

| # | İş | Süre | Dokunulacak dosyalar |
|---|---|---|---|
B1 | **`chart_data` dizi olur, grafik gövdenin içine yerleşir.** `.dsy-grafik` yer tutucusu + `flutter_html` `extensions` ile sınıfa bağlı widget; yer tutucu yoksa bugünkü davranış korunur. Haber başına birden çok sayısal bulgu ilk kez yayınlanabilir hale gelir. | 3-4 gün | `news_article.dart:57` · `article_detail_screen.dart:437-490` · `dynamic_chart_widget.dart` (çoklu örnek) · hat deposu · `functions/index.js` (SSR karşılığı)
B2 | **Haber grafiği ile dosya grafiği tek sözlükte buluşur.** `SayiBicimi`, `kaynak`/`not`, `_TaramaBoyaci` deseni ve `buyukHarf` `lib/core/`'a taşınır; iki dizi aynı biçimlendiriciyi kullanır. Bugün `dossier_chart.dart` doğruyu yapıyor, `dynamic_chart_widget.dart` aynı sorunları yeniden çözüyor — ve bazılarını yanlış çözüyor. | 3-4 gün | `lib/core/` (yeni ortak katman) · `lib/features/dossiers/data/models/dossier_chart.dart:130-178` · `dynamic_chart_widget.dart` bütünü
B3 | **Grafik testleri koşuma bağlanır.** Bugün `test/haber_tablosu_test.dart` yalnızca tablo yerleşimini koruyor (4 test); rakam kartı, sayı biçimi, büyük harf, aralık değeri ve kaynak satırı için test yok — §8.5'in *"on altı test yeşilken yerleşim yanlıştı"* dersiyle birlikte, örnekler gerçek veriden okunur (`test/support/` kalıbı). | 2 gün | `test/haber_tablosu_test.dart` · yeni `test/haber_grafik_test.dart` · `test/support/`

---

**Kapsam dışı bıraktıklarım (bilinçli kararlar, "eksik" diye raporlanmadı):** dosya sayfasının koyu adası (§3.1); 77 grafiğin İngilizce sayfada Türkçe kalması (§10.2'nin doğrulama kuralı); ızgara galerinin HTML yerine kompoze JPEG olması (§39.2); AppBar yerleşimi; seslendirme. `google_fonts` çalışma anında indirme (Lora/Inter/Outfit) §22.3'te **zaten AÇIK** kalem olarak duruyor, yeniden bulgu sayılmadı.