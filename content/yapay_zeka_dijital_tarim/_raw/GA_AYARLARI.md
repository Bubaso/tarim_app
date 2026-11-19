# Google Analytics paneli — ölçüm için kontrol listesi

Mülk: `G-0FF4T9BHJ4` (tarimportali.net web akışı). Bu adımlar koddan yapılamaz; GA
yönetim panelinden sahibin elle yapması gerekir. Sıra önemli: **özel boyutlar,
bölümün okuma olayları yayına çıkmadan ÖNCE** tanımlanmalı (geriye dönük dolmaz).

Panelin Türkçe ve İngilizce adları parantez içinde; Google menü adlarını zaman zaman
değiştiriyor, yol tutmazsa ayarı adıyla arayın (panelin üstündeki arama kutusu).

Karar (birleştirici): GA'nın site genelindeki çalışma biçimi (çerez / rıza modu)
DEĞİŞMİYOR. Gönderilen olaylar kişisel veri taşımıyor; aşağıdaki ayarlar GA'nın
kendi tarafında topladığını sınırlıyor.

---

## 1. Özel boyutlar — olaylardan ÖNCE

Yönetici (Admin) → Veri görüntüleme (Data display) → Özel tanımlar (Custom definitions)
→ Özel boyut oluştur (Create custom dimension). Kapsam (Scope): **Etkinlik (Event)**.
Boyut adı serbest; **etkinlik parametresi** aşağıdaki adla birebir aynı olmalı.

Sınır: mülk başına 50 etkinlik kapsamlı boyut. Sayısal olanlar (`bolum_sira`,
`bolum_sayisi`) ayrıca özel metrik olarak da tanımlanabilir; zorunlu değil.

- [ ] `adim` — okuma adımı: acildi / y25 / y50 / y75 / y100
- [ ] `sayfa` — bölüm sayfasının kısa adı (slug)
- [ ] `sayfa_turu` — başlık / teknoloji / merkez / arama
- [ ] `bolum_sira` — alt başlığın sırası (metni DEĞİL)
- [ ] `bolum_sayisi` — sayfadaki alt başlık sayısı
- [ ] `aktif_sure` — aktif okuma süresi kovası
- [ ] `hizli` — 1: o noktaya beklenenden çok hızlı gelindi
- [ ] `cihaz` — telefon / tablet / masaustu
- [ ] `dil` — tr / en
- [ ] `giris` — dis / merkez / serit / devam / arama / sozluk / komsu / bildirim
- [ ] `yazi_olcegi` — okurun seçtiği yazı boyu
- [ ] `ilk_kare` — açılış hızı kovası: <1 / 1-2 / 2-4 / >4 sn
- [ ] `yer` — haber kartının yeri (başlık sonu / merkez)
- [ ] `sira` — kartın sırası

Okuma grubunun kodu birleştiğinde son parametre listesi
`content/yapay_zeka_dijital_tarim/_raw/README.md` → "Ölçüm" bölümündedir; bu liste
oradan bir kez daha karşılaştırılmalı (çıkış olayına eklenen parametreler varsa
onlar da tanımlanır).

## 2. Veri saklama — 14 ay

Yönetici → Veri toplama ve değiştirme (Data collection and modification) →
Veri saklama (Data retention).

- [ ] Etkinlik verilerinin saklanması (Event data retention): **14 ay**
- [ ] Yeni etkinlikte kullanıcı verilerini sıfırla (Reset user data on new activity): açık kalsın

Not: süre değişikliği geriye dönük uygulanmaz; keşif (Explorations) raporları bu
süreyle sınırlıdır, standart raporlar etkilenmez.

## 3. Kullanıcı verisi toplama — kapalı

Yönetici → Veri toplama ve değiştirme → Veri toplama (Data collection).

- [ ] Kullanıcı tarafından sağlanan veri toplama (User-provided data collection): **kapalı**
- [ ] Web akışında kullanıcı tarafından sağlanan verinin otomatik algılanması
      (automatically detect user-provided data): **kapalı**
      (Ölçümde bu kapsayıcıda e-posta, telefon ve adres otomatik algılaması açık
      görüldü.)

## 4. Google sinyalleri ve reklam — kapalı

Aynı sayfa (Veri toplama):

- [ ] Google sinyalleri veri toplama (Google signals data collection): **kapalı**
- [ ] Reklam kişiselleştirme için ayrıntılı ayarlar (Advanced settings to allow for
      ads personalization): bütün ülkeler / bölgeler **kapalı**

Yönetici → Ürün bağlantıları (Product links):

- [ ] Google Ads, AdSense, Ad Manager vb. bağlantı **yok** (varsa kaldırılır)

## 5. Arama sözcüğü karartma

Kod, site içi geçişlerde adresten `q`, `ara`, `terim`, `geri` parametrelerini
zaten atıyor. Ama okur siteye doğrudan bir arama adresiyle girerse (`…/ara?q=…`)
ilk sayfa görüntülemesini `web/index.html`'deki SDK tam adresle gönderir; bölümün
okuma olayları da o anki adresi taşır. Bunu panel kapatır:

Yönetici → Veri akışları (Data streams) → web akışı → Veri karartma (Redact data).

- [ ] E-postaları karart (Redact email): **açık**
- [ ] Sorgu parametrelerini karart (Redact query parameters): **açık**; parametreler:
      `q`, `ara`, `terim`, `geri`

## 6. Gelişmiş ölçüm (Enhanced measurement)

Yönetici → Veri akışları → web akışı → Gelişmiş ölçüm → dişli simgesi.

- [ ] Sayfa görüntülemeleri (Page views) → Gelişmiş ayarlar → **Tarayıcı geçmişi
      etkinliklerine göre sayfa değişiklikleri (Page changes based on browser
      history events): KAPALI.** Site içi geçişleri artık kod gönderiyor; bu açık
      kalırsa her geçiş İKİ kez sayılır.
- [ ] Kaydırmalar (Scrolls): **kapalı** (belge hiç kaymıyor; ölçümde 0 olay. Okuma
      derinliğini bölümün kendi olayı ölçüyor.)
- [ ] Site araması (Site search): **kapalı** (açık kalırsa GA adresteki `q`'yu
      arama terimi olarak ayrı bir olaya yazar).

## 7. Yayın günü notu

Sayfa ve süre sayıları yayın gününden itibaren değişecek (o güne kadar yalnız ilk
sayfa sayılıyordu).

- [ ] Raporlar → herhangi bir zaman çizelgesi → Not ekle (Annotation): "Site içi
      sayfa görüntülemeleri başladı" — yayın tarihiyle.

## 8. Kabul testi (DebugView)

Yönetici → DebugView. Tarayıcıda "Google Analytics Debugger" eklentisi açıkken:

- [ ] Ana sayfa açılır: tek `page_view`.
- [ ] Ana sayfadan bölüme, oradan bir başlığa geçilir: her geçişte tek `page_view`;
      `page_title` "<başlık adı> | Tarım Portalı", `page_location` yalnız yol.
- [ ] Bölümde arama yapılır: `page_location`'da `q` yok.
- [ ] Geri tuşu: tek `page_view`, çift yok.
- [ ] Bir başlık açılır: `yz_okuma_adimi` (adim=acildi), `ilk_kare` dolu.
- [ ] İngilizceye geçilir: sekme başlığı İngilizce; geçişte `page_view` yok.

## 9. İsteğe bağlı

- [ ] Ayrıntılı konum ve cihaz verisi toplama (Granular location and device data
      collection): kapatılabilir. Bedeli: şehir ve cihaz modeli raporları boşalır.
      Bölümün kendi `cihaz` parametresi etkilenmez.
- [ ] `web/index.html`'deki ikinci Firebase SDK'sı (10.12.2) ileride kaldırılabilir;
      kaldırılırsa ilk sayfa görüntülemesini Dart tarafı göndermeli (bugün
      `send_page_view: false` ile kapalı). Ayrı bir iş, ayrı sınama ister.
