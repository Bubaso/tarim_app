# Tarım Portalı

Türkiye tarımına odaklanmış, iki dilli (TR/EN) haber portalı. Flutter web + PWA
olarak derleniyor, Firebase Hosting'den sunuluyor, verisini Supabase'den
okuyor.

**Canlı:** https://tarimportali.net · https://tarim-app-2026.web.app (aynı site)

Portal üç ayrı içerik akışını tek yerde topluyor:

- **Haber akışı** — kurumsal ve ajans kaynaklarından toplanıp bir yapay zekâ
  hattında yeniden yazılan, panelde insan onayından geçen haberler.
- **Dosya dizileri** — 28 günde bir yayımlanan **Ülke Dosyası** ve 14 günde bir
  yayımlanan **Kurum Dosyası**: elle yazılmış, kaynağı tek tek doğrulanmış uzun
  okuma dosyaları.
- **Piyasa verisi** — borsa ve ilan kaynaklarından çekilen emtia fiyatları,
  zirai hava durumu, video şeridi ve köşe yazıları.

---

## ⚠️ Depo durumu — klonlayıp dağıtmadan önce okuyun

Bu depo şu anda **canlı sürümün gerisinde.** `lib/` en son **2 Eylül 2026**'da
değişti; Eylül–Ekim 2026 çalışması (gerçek köşe yazarı altyapısı, inceleme
masası, köşe yazısı seslendirmesi, `Outfit` başlık fontu, dosya haberi stilleri)
ve İspanya · Tarım Kredi · TAGEM · Avustralya dosyalarının içeriği **commit
edilmedi.**

Pratik sonucu: **bu ağaçtan yapılan bir dağıtım üretime Eylül öncesi bir
uygulama basar.** Bu iki kez yaşandı. Dağıtımdan önce ağacın doğru olduğunu
sınayın:

```bash
grep -rl Outfit lib/core/theme/ | head -1      # çıktı VERMELİYSE ağaç günceldir
ls lib/core/utils/turkce_metin.dart            # VAR olmalı
```

İkisi de boşsa bu ağaç eski demektir; dağıtmayın. Ayrıntılı liste için
[Bilinen eksikler](#bilinen-eksikler-ve-tuzaklar).

---

## Mimari

```
                 ┌──────────────────────────────────────────┐
  okuyucu ──────▶│ Firebase Hosting (build/web)             │
                 │  · statik index.html  (SPA, ** yakalayıcı)│
                 │  · /ulke/<slug>/index.html  statik kabuk  │
                 └───────────┬──────────────────────────────┘
                             │ rewrite
                 ┌───────────▼──────────────────────────────┐
                 │ Cloud Functions (europe-west1, Node 22)  │
                 │  ogRenderer · weekRenderer · sitemap …   │
                 └───────────┬──────────────────────────────┘
                             │ PostgREST
                 ┌───────────▼──────────────────────────────┐
                 │ Supabase — Postgres + RLS + Storage      │
                 └───────────▲──────────────────────────────┘
                             │ service_role
                 ┌───────────┴──────────────────────────────┐
                 │ tarim_ai_pipeline  (AYRI DEPO)           │
                 │  haber çekme · çeviri · emtia · TTS      │
                 └──────────────────────────────────────────┘
```

Flutter istemcisi Supabase'i **doğrudan** `anon` anahtarıyla okuyor; yazma
yetkisi yok, görünürlük RLS politikalarıyla belirleniyor. Cloud Functions
yalnızca sunucu tarafı render (og etiketleri, gövde metni, sitemap) ve
bildirim gönderimi için var.

**Haber üretim hattı bu depoda değil:** `~/tarim_ai_pipeline` (Python). Bu depo
hattın yazdığı veriyi okuyan istemci + dağıtım katmanı.

---

## Teknoloji

| katman | seçim |
|---|---|
| İstemci | Flutter (SDK `>=3.3.0 <4.0.0`), web hedefi, CanvasKit |
| Durum yönetimi | `flutter_riverpod` ^2.5 |
| Yönlendirme | `go_router` ^14.1 + `MaterialApp.router` |
| Arka uç | `supabase_flutter` ^2.5 (PostgREST + RLS) |
| Grafikler | `fl_chart` ^1.2 + elle yazılmış dosya grafikleri |
| HTML gövde | `flutter_html` ^3.0 (özel `<img>` eklentisiyle) |
| Bildirim/analitik | `firebase_core` · `firebase_messaging` · `firebase_analytics` |
| Yerel önbellek | `hive` ^2.2 (liste önbelleği; gövde taşımaz) |
| Sunucu | Cloud Functions v2, ESM, Node **22**, `europe-west1` |

---

## Depo yapısı

```
lib/
  main.dart                     uygulama girişi
  firebase_options.dart         Firebase proje kimlikleri (alan adı DEĞİL)
  core/
    constants/api_constants.dart    Supabase adresi/anahtarı (--dart-define)
    network/supabase_client.dart
    router/app_router.dart          19 rota, tek yerde
    services/                       bildirim tercihleri, depolama
    theme/                          app_colors · app_typography · dark mode
    utils/                          responsive, görsel yedeği, PWA, url stratejisi
    widgets/
  features/                     9 özellik, her biri data/presentation/providers
    home/        44 dosya — haber akışı, manşet, panel, hava durumu
    dossiers/    20 dosya — ülke/kurum dosyası ekranları ve grafikleri
    stories/      8 dosya — hikâye şeridi
    commodities/  6 dosya — emtia fiyat şeridi ve grafik sayfası
    videos/       5 dosya — video şeridi
    dashboard/    3 dosya — yönetim paneli
    auth · legal · settings
test/                           22 test dosyası + support/
functions/
  index.js                      Cloud Functions (ESM, tek dosya)
  config.js                     anahtarlar ve sabitler
  shell.html                    derlemeden ÜRETİLİR, elle düzenlenmez
supabase/
  migrations/                   56 migration, zaman damgalı
  seed/                         dossier_<slug>.sql + fuzzy_search.sql
content/dossiers/               dosya dizilerinin kaynağı (aşağıda)
web/                            index.html, service worker, dosya görselleri
scripts/                        hikâye üreticileri
deploy.sh                       derleme + dağıtım, bekçileriyle
CLAUDE.md                       proje hafızası — kararlar ve gerekçeleri
```

`CLAUDE.md` bu depoda en değerli dosya: alınan her kararın **gerekçesini** ve
reddedilen alternatifleri taşıyor. Koda dokunmadan önce ilgili bölümünü okuyun.

---

## Rotalar

| rota | ekran |
|---|---|
| `/` | ana sayfa — manşet, akış, şeritler |
| `/haber/:id` | haber detayı |
| `/kategori/:slug` | kategori listesi |
| `/kisa-kisa` | kısa haberler |
| `/hafta/:slug` | haftalık özet |
| `/yazarlar` · `/yazar/:name` | köşe yazarları |
| `/ulke/:slug` · `/ulkeler` | Ülke Dosyası ve arşivi |
| `/kurum/:slug` · `/kurumlar` | Kurum Dosyası ve arşivi |
| `/piyasalar` · `/emtia/:slug` | emtia fiyatları ve grafik |
| `/hava-durumu` | zirai hava durumu |
| `/yyt-dosyasi` · `/hakkimizda` | özel sayfalar |
| `/panel` · `/giris` · `/ayarlar` | yönetim, oturum, tercihler |

**Adresler ASCII.** `/ulke/`, `/ülke/` değil: Türkçe karakterli adres
mesajlaşma uygulamalarında yüzde kodlamasına dönüşüp okunmaz hâle geliyor
(`CLAUDE.md` §2.1).

---

## Cloud Functions

Bu ağaçta sekiz fonksiyon tanımlı (`functions/index.js`):

| fonksiyon | tür | tetik |
|---|---|---|
| `ogRenderer` | HTTP | `/haber/**`, `/en/haber/**` — og etiketleri + gövde metni |
| `weekRenderer` | HTTP | `/hafta/**` |
| `dossierRenderer` | HTTP | yazılı, **rewrite'ı bilerek eklenmemiş** (statik kabuk kullanılıyor) |
| `sitemap` | HTTP | `/sitemap.xml` — iki dilde, `hreflang` karşılıklı |
| `morningBriefing` | zamanlı | `0 7 * * *` |
| `authorBulletin` | zamanlı | `0 18 * * *` |
| `weeklyBriefing` | zamanlı | `0 19 * * 0` |
| `breakingNewsCheck` | zamanlı | `*/30 * * * *` |

> **`/kategori/**` rewrite'ı `categoryRenderer`'a işaret ediyor ama o fonksiyon
> bu ağaçta YOK.** Buradan `functions` dağıtılırsa kategori sayfaları **404**
> döner. Var olmayan bir fonksiyona yönlendirme bir kez yayınlandı ve üretimi
> kırdı (`CLAUDE.md` §2.5, §7).

### SEO — gövde metni sunucudan gidiyor

CanvasKit metni DOM'a değil tuvale çiziyor; arama motoru boş sayfa görüyordu
(ölçüldü: `document.body.innerText.length` = 0). Çözüm `web/index.html`
içindeki işaret çifti:

```html
<!-- SSR_CONTENT_START --><!-- SSR_CONTENT_END -->
```

Arası iki yoldan doluyor: haber sayfalarında `ogRenderer` tam metni yazıyor,
ana sayfa ve statik rotalarda derleme anında son 60 haberin link listesi
gömülüyor. Flutter ilk kareyi çizer çizmez bu düğüm DOM'dan siliniyor — gizleme
(cloaking) değil, sunulan metin uygulamanın gösterdiğiyle birebir aynı.

---

## Yerel kurulum

Gerekenler: Flutter (web hedefi açık), Node **22** (fonksiyonlar için),
Python 3.11+, `firebase-tools`, `supabase` CLI.

```bash
flutter pub get
cd functions && npm install && cd ..
```

Supabase adresi ve `anon` anahtarı koda gömülü **değil**, derleme anında
geçiliyor:

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://<proje>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-anahtar>
```

> **İstemcide API anahtarı gizlenemez.** `--dart-define` de çözüm değil; değer
> derlenmiş pakete gömülüyor. Bu yüzden istemciye yalnızca `anon` anahtarı
> iniyor ve yetkilendirme tamamen RLS'te. `service_role` anahtarı bu depoya
> hiçbir biçimde girmez (`CLAUDE.md` §20.6).

Yayımlanmamış bir dosyayı yerelde önizlemek için:

```bash
flutter build web --release --dart-define=DOSYA_ONIZLEME=<slug>
```

---

## Derleme ve dağıtım

```bash
./deploy.sh              # derle + hosting & functions
./deploy.sh --hosting    # yalnızca hosting (fonksiyon değişmediyse)
./deploy.sh --no-build   # mevcut build/web ile dağıt
```

`deploy.sh` sırayla şunları yapıyor — her adımın bir yanık geçmişi var:

1. **Varlıkları yerele çeker.** Depo iCloud altındayken `web/` dosyaları
   "veri yok" yer tutucusu olabiliyor ve derleme `errno 60` ile düşüyor.
   Okunamazsa 20 sn bekleyip bir kez daha dener, yine olmazsa **durur**.
2. `flutter build web --release --pwa-strategy=none --no-tree-shake-icons`.
   Flutter'ın service worker'ı sonsuz yenileme döngüsü yapıyordu; elle yazılmış
   temizleyici worker `web/` altından kopyalanıyor.
3. `functions/shell.html`i **derlemeden üretir**. Bu dosya elle düzenlenmez:
   içindeki `flutter_bootstrap.js` sürüm damgası her derlemede değişiyor.
4. **İki bekçi:** kabukta `SOCIAL_META_START` veya `SSR_CONTENT_START` yoksa
   dağıtım durur. İkincisi olmadan site arama motorlarına sessizce görünmez
   olurdu.
5. Ana sayfa link listesini gömer, `node --check` ile fonksiyonları sınar.
6. Yayımlanmış her dosya için `build/web/ulke/<slug>/index.html` statik kabuğunu
   yazar.
7. `NODE_OPTIONS=--max-old-space-size=8192` ve `FUNCTIONS_DISCOVERY_TIMEOUT=120`
   ile dağıtır. Bunlar olmadan CLI fonksiyon keşfinde yanıltıcı bir
   "Timeout after 10000" veriyor; asıl sebep V8 bellek taşması.

`"trailingSlash": false` **zorunlu**: olmadan Firebase `/ulke/hollanda` →
`/ulke/hollanda/` 301'i veriyor, adres ise dosyanın kimliği.

### Veritabanı

```bash
supabase db push        # migration'ları uygula
```

- **Uygulanmış bir migration asla düzenlenmez**, yeni dosya yazılır.
- İki migration aynı sürüm numarasını taşıyamaz; `ls supabase/migrations | tail`
  ile bakın.
- `psql` kurulu değil; uzak veritabanına yazmanın yolu `supabase db push`.

---

## Dosya dizileri (içerik hattı)

Her dosya kendi klasöründe, kaynağından metne kadar izlenebilir:

```
content/dossiers/<slug>/
  _raw/            kaynaktan ham çekim + çekme betikleri + README
  build_data.mjs   _raw → data.json
  data.json        kilitli veri sayfası
  grafikler.json   grafik tarifleri, sayılara @path ile bağlanır
  metin_tr.md      bölümler
  metin_en.md
  tasarim.json     palet, motif, kapak kararları
  yayin.json       pencere, kaynak künyesi, bölüm türleri, görseller
```

Üretim ve doğrulama:

```bash
node content/dossiers/seed_dossier.mjs <slug>     # → supabase/seed/dossier_<slug>.sql
node content/dossiers/dogrula_seed.mjs <slug>
python3 content/dossiers/<slug>/dogrula_metin.py  # metin veri katmanından sapmış mı
node content/dossiers/_ortak/paylasim_karti.mjs <slug>   # 1200×630 paylaşım kartı
```

### Sayı disiplini

Bu dizinin varlık sebebi güvenilirlik; uydurma tek bir rakam diziyi bitirir.
Kurallar `CLAUDE.md` §2.2'de, özeti:

- **Veri sayfası metinden önce kilitlenir.** Önce `data.json`, sonra cümle.
- **Getir, hatırlama.** Hiçbir rakam bellekten yazılmaz.
- Kaynağı olmayan sayı metne girmez; bellekten türetilmiş her iddia karantinada.
- Toplulaştırıcı satır içeren kaynakta **çift sayım** sessiz bir hatadır — her
  manşet rakamı yayından önce bağımsız bir kaynağa karşı oranlanır.
- Yuvarlama depoda değil çizimde yapılır; veritabanında tam değer durur.

`dogrula_metin.py` metnin veri katmanından sapmadığını kanıtlar — **veri
katmanının kendisinin doğruluğunu kanıtlamaz.** İki denetim birlikte çalışır.

### Görsel kuralı

**Atıfsız görsel yayımlanmaz**; kural üretim betiğinde, doğrulayıcıda ve modelde
ayrı ayrı sınanıyor. Görsel dosyaları `web/dosya/<slug>/`, adresler **mutlak**
yazılıyor (`NewsArticleImage` göreli yol kabul etmiyor).

> **Görsel varlığı durum koduyla sınanmaz, CONTENT-TYPE ile sınanır.** Bu
> projede 404 diye bir şey yok: olmayan yol SPA yönlendirmesiyle `200 + text/html`
> dönüyor. `curl -o /dev/null -w '%{http_code} %{content_type}'` kullanın.

---

## Test

```bash
flutter test
```

22 test dosyası var (artı `test/support/` yardımcıları); ağırlık dosya
dizilerinde (grafik, ekran, şerit, arşiv) ve emtia kartlarında.

- **Testler üretilmiş seed'e bağlanır**, elle yazılmış sahte veriye değil:
  `test/support/dossier_fixture.dart` `supabase/seed/dossier_hollanda.sql`
  dosyasını ayrıştırıyor. İçerik bozulursa test kırılıyor.
- **Taşma testleri 360 / 768 / 1200 px × tr/en** olarak yazılır. `flutter_test`
  varsayılan fontu her glifi yazı boyu kadar kare çiziyor; metin gerçekte
  olduğundan geniş görünüyor — kötümser, dolayısıyla iyi bir taşma dedektörü.

**Bilinen iki kırık test:** `author_article_detail_test.dart` (ekran test
ortamında içerik çizmiyor, sağlayıcı sahtelemesi gerekiyor) ve
`widget_test.dart` (test bağlaması tüm HTTP'yi 400 döndürüyor, hava durumu
çağrısı bilerek hata fırlatıyor).

---

## Kod alışkanlıkları

- **Tanımlayıcılar ve yorumlar Türkçe.** Yorum "ne" değil **"neden"** anlatır;
  özellikle bir kararın alternatifinin neden reddedildiğini yazar.
- Okuma oluğu dosyada 720 px, haberde 800 px. Uzun paragrafta geniş satır göz
  satır atlatıyor.
- Uzun listeler tembel (`SliverList.builder`).
- **Renk tek başına anlam taşımaz.** "ŞİMDİ" rozeti bir kelime, sadece vurgu
  rengi değil; grafik serileri renkle birlikte biçimle de ayrılır.
- Dosya sayfası bilerek koyu bir "ada" ve sistem açık/koyu tercihini izlemez;
  dosya ekranlarında `Theme.of(context).brightness` okunmaz.

---

## Bilinen eksikler ve tuzaklar

| konu | durum |
|---|---|
| **Depo üretimin gerisinde** | `lib/` 2 Eylül 2026'da kaldı; Eylül–Ekim işi ve dört dosyanın içeriği commit edilmedi |
| `scripts/ana_sayfa_linkleri.py` | `deploy.sh` çağırıyor ama **dosya depoda yok** → dağıtım o adımda düşer |
| `categoryRenderer` | `firebase.json` `/kategori/**`i ona yönlendiriyor, fonksiyon bu ağaçta **yok** |
| `/en/haber/**` | `firebase.json` bu adresi `ogRenderer`'a yönlendiriyor ama **Flutter rotası bu ağaçta yok**; sunucu kabuğu veriyor, istemci rotayı çözemiyor |
| `build` · `.dart_tool` | `.nosync` hedeflerine sembolik bağ olarak **commit edilmiş** (macOS/iCloud çözümü); Linux'ta ölü bağ |
| Kırık testler | `author_article_detail_test.dart`, `widget_test.dart` |
| `push_tokens` RLS | `anon` okuyabiliyor; fonksiyonlar bu tabloyu anon anahtarıyla okuduğu için kapatılamadı (`CLAUDE.md` §20.7) |
| Bütçe/hata izleme | Google Cloud ve Supabase için harcama eşiği ve uyarı tanımlı değil (§20.8) |
| CSP | Bilerek eklenmedi: uygulama on ikiden fazla dış kökene bağlanıyor, eksik tek bir `connect-src` özelliği **sessizce** kırar. Doğru yol `Content-Security-Policy-Report-Only` ile başlamak (§21.5) |

---

## İlgili depolar

- **`tarim_ai_pipeline`** (ayrı, bu depoda değil) — haber çekme ve yeniden yazma
  ajanları, çeviri, emtia fiyat toplayıcıları, köşe yazısı içe aktarma,
  seslendirme. Supabase'e `service_role` anahtarıyla yazıyor.

## Lisans

Özel depo; lisans tanımlanmadı.
