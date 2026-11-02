## 0. ÖNCE: ÖNERMENDE DÜZELTMEK İSTEDİĞİM DÖRT ŞEY

### 0.1 Sorun tasarımda değil, ÇEŞİTLİLİKTE

Tasarım, metin, sunuş diye saydın. Ölçtüm: bunların hiçbiri tek başına ele vermiyor. Ele veren şey **tekdüzelik**. Gerçek bir gazete düzensizdir — bugün 90 kelimelik bir not, yarın 1.400 kelimelik bir dosya; bir başlık üç kelime, öteki on dört; biri soru sorar, biri tırnak taşır. Bu portalda:

| ölçüm | bulunan | gerçek gazetede |
|---|---|---|
| Başlıkların her kelimesi büyük harfle başlıyor | **999 / 1.000** | ~0 |
| Başlık uzunluğu standart sapması | **6 karakter** | 15–25 |
| Tırnak taşıyan başlık | **0** | %10–20 |
| Soru başlığı | **1** | %3–8 |
| `summary` ile `spot` birebir aynı | **999 / 1.000** | 0 |
| Tam olarak 5 anahtar kelimesi olan haber | **671 / 1.000** | — |

Bir okur bunların hiçbirini tek tek fark etmez. Ama yirmi kartı yan yana görünce **aynı elden çıkmış** olduklarını anlar. "Yapay zeka kokusu" dediğin şeyin ölçülebilir karşılığı bu.

### 0.2 Amaç "izi gizlemek" değil, "güvenilir görünmek" — ve ikisi aynı şey değil

"Yapay zeka kokusunun esamesi okunmamalı" dedin. Buradaki tek düzeltmem bu cümleye: **gizlemeye çalışmak, profesyonel algıyı YÜKSELTMİYOR, düşürüyor.**

Üç sebeple:

1. **Google'ın kuralı yapay zekâyı yasaklamıyor**, "ölçekli içerik kötüye kullanımı"nı yasaklıyor — katma değer üretmeden sıralama için üretilen yığın içeriği. Ayrım, içeriğin NASIL yazıldığında değil, okura ne kattığında. Gizlemek bu ayrımda hiçbir şeyi değiştirmiyor.
2. **Ciddi kurumlar bunu açıkça yazıyor.** Reuters, AP ve Guardian'ın yayımlanmış yapay zekâ politikaları var ve bu onları amatör göstermiyor; tersine kurumsallaştırıyor. Saklayan taraf amatör görünüyor.
3. **Senin kendi disiplinin zaten bu yönde.** `CLAUDE.md` baştan sona "kaynağı olmayan sayı metne girmez", "atıfsız görsel yayımlanmaz", "uydurma veri yasak" diyor. Bu titizliği GİZLEMEK, sahip olduğun en güçlü güven kozunu çöpe atmak olur.

**Önerim:** izi silmek yerine **sahiplenmek**. Kısa, net bir "Nasıl Çalışıyoruz" sayfası ve her haberin altında tek satırlık künye, portalı amatör göstermez — tam tersine, çoğu Türk haber sitesinde **olmayan** bir şeydir. Asıl ayrışma oradan gelir.

### 0.3 "Senior yazılımcı anlamasın" yanlış hedef

Bir senior zaten anlar: yığın Flutter Web + CanvasKit + Supabase, kod yorumları hattı anlatıyor. Bunu gizleyemezsin ve gizlemeye çalışmak önceliklerini bozar — seni kozmetik değişikliklere iter.

Üstelik bir senior'ın asıl söyleyeceği şey "bu yapay zeka" değil; **"ana sayfa 4 MB indiriyor", "sayfalama yok", "15 ayrı kart sınıfı var"** olurdu. Yani onun eleştirisi, üç alan denetiminin zaten bulduğu şeylerdi — ve büyük kısmı bu hafta kapandı.

**Doğru hedef kitle okur ve Google.** İkisi için de iyileştirmeler somut ve ölçülebilir; hayali bir uzman için değil.

### 0.4 Künyesiz görsel — önermende hiç geçmeyen ama en riskli nokta

"Kaynaklardaki görselleri çekip tekrar yayınlıyoruz" dedin, sorun olarak saymadın. İki sebeple saymalısın:

- **Kendi kuralını ihlal ediyor.** §8.3: *"Atıfsız görsel yayımlanmaz"* — dosya dizisinde her görselin altında künye var. Haber tarafında `image_credit` diye bir **sütun bile yok**.
- **Algıyı doğrudan düşürüyor.** Fotoğraf altında kaynak olmaması, okurun bilinçsizce "bu görsel buraya ait değil" diye okuduğu bir işarettir.

Bu hem telif hem algı meselesi ve çözümü ucuz.

---

## 1. ÖLÇÜLEN PARMAK İZİ

Yayındaki 1.000 haber ve canlı sitenin ağ izi üzerinden.

### 1.1 En yüksek sesli işaret: başlıklar

**999 / 1.000 başlıkta her kelime büyük harfle başlıyor.**

```
Meksika Tohum Kurdu Nedeniyle Avokado İhracatını Durdurdu
Tarım Bakanlığı Sapanca Havzası İçin Eylem Planını Açıkladı
Kayseri'nin Elma Pazarı Modeli 81 İle Yayılıyor
```

Bu bir İngilizce yazım geleneği (*Title Case*) ve Türkçede **kullanılmıyor.** Hürriyet, AA, Dünya — hiçbiri böyle yazmaz. Türkçe haber başlığı cümle düzenindedir: ilk harf ve özel adlar büyük, gerisi küçük.

Hattın tamamını taradım: **büyük/küçük harf hakkında tek bir talimat yok.** Yani bu bir karar değil, modelin talimatsız bırakılmış varsayılan alışkanlığı. Ve ana sayfadaki her kartta, akan şeritte, her sekme başlığında görünüyor.

**Bu tek değişiklik, algıda en büyük sıçramayı yapacak olan şey.**

### 1.2 Başlıklar aynı kalıptan çıkıyor

Ortanca 54 karakter, **standart sapma 6**. Yani neredeyse bütün başlıklar aynı uzunlukta. Sebebi `reporter.py`'de yazılı:

> `- title: Maksimum 4-6 kelimelik...` · `5-9 kelimelik...` · `5-8 kelimelik...`

Dosyadaki yorum sorunu doğru teşhis etmiş: *"12 farklı kaynağın başlık uzunluğu 6.1-6.7 kelime arasındaydı... Aradaki fark 0.6 kelime — bu editoryal seçim değil, tek şablon."* Ama çözüm **ortalamayı kopyalamış**, dağılımı değil. Gerçek gazetede ortalama 6 kelimedir *ama* varyans büyüktür.

En sık biten kelimeler de tek bir kipi gösteriyor: **Başladı (68)**, Dağıtıldı (20), Yapıldı (15), Açıkladı (15), Etti (16). Hepsi edilgen/geçmiş zaman duyuru kipi.

### 1.3 Kısa haber, tam haber kılığında

**520 haber 200 kelimeden kısa. Bunların yalnızca 178'i `kisa` etiketli — 342 tanesi "tam" haber olarak sunuluyor:** büyük görsel bandı, grafik, "Öne Çıkanlar" kutusu, "Uzman Görüşü" kutusu.

150 kelimelik bir habere bu mobilyayı giydirmek, okurun gözünde içeriği küçültüyor. Gerçek gazetelerin **kısa haber sütunu** vardır ve oradaki haber küçük, görselsiz, yan yana dizilidir — bu bir kusur değil, bir biçimdir.

Buna karşılık **649 / 1.000 haberde hiç ara başlık yok, ama 706'sında grafik var.** Mobilya ters takılmış: metni bölen şey yok, ama süsleyen şey var.

### 1.4 İmza yok, "Google Haberler" var

44 farklı `source_name` var ve en büyüğü:

```
219  Google Haberler      ← bir kaynak değil, bir toplayıcı
216  Tarım Pusulası
128  GıdaTarım
 87  Tarım TV
```

Haberin künyesinde "Google Haberler" yazması, okura **"bunu kim yazdı bilmiyoruz"** demektir. Hiçbir gerçek portal Google'ı kaynak olarak göstermez.

Ve portalda **hiçbir haberin insan imzası yok.** Haber merkezi adı da yok. Okur, 1.000 haberin kim tarafından derlendiğini hiçbir yerde göremiyor.

### 1.5 Sayfa 50 saniyede tamamlanıyor — en ağır algı kaybı

Canlı ana sayfanın ağ izini ölçtüm:

```
 0,6 sn   SSR metni boyanıyor            ✓ iyi
 5,4 sn   motor (main.dart.js) indi
 6,4 sn   articles sorgusu BAŞLIYOR
15,5 sn   biter — 4 MB için 9,1 saniye
20-25 sn  43 görsel isteği ancak burada BAŞLIYOR
24,9 sn   öteki bütün sorgular yeni başlıyor
45-50 sn  son 13 görsel
```

Ekran görüntüsü bunun karşılığını gösteriyor: ana sayfanın tepesinde, yirmi saniye boyunca **on tane siyah daire** duruyor. Toplam görsel yükü yalnızca 0,25 MB — yani sorun bant genişliği değil, **sıra**. Liste sorgusu bitmeden hiçbir kart kurulmuyor, kart kurulmadan hiçbir görsel istenmiyor.

Hiçbir tipografi düzeltmesi bu kadar etki etmez. **Fotoğrafları 20 saniye sonra gelen bir site, hiçbir okura profesyonel görünmez.**

> İyi haber: bunun sebebi olan `select('*')` sorgusu bu hafta depoda düzeltildi (**4,00 MB → 0,25 MB, 15,9 kat**). Henüz dağıtılmadı. Yani bu maddenin büyük kısmı bir dağıtım kararı kadar uzakta.

### 1.6 Küçük ama biriken işaretler

- **`summary` ile `spot` 999 haberde birebir aynı** — okur aynı cümleyi iki kez okuyor.
- **671 haberde tam 5 anahtar kelime**, 222'sinde 6. İnsan böyle bir dağılım üretmez. Üstelik bu çipler ekranda **tıklanmıyor** (ölü süs).
- **Üç köşe yazarından ikisinin fotoğrafı var, birinde aynı buğday başağı** — şeridin içinde tek bir yeşil ikon, "veri eksik" gibi duruyor.
- **Yayın ritmi 09:00'da zirve yapıyor** (197 haber). Gerçek bir haber merkezinde gün boyunca daha düz bir dağılım olur.
- **889 haberde okunma sıfır.** Sayaç `> 0` korumalı, yani görünmüyor — ama %11'lik bir azınlıkta görünüyor, bu da tutarsız.

---

## 2. SOMUT DEĞİŞİKLİK ÖNERİLERİ

### A. METİN — hat tarafı (`~/tarim_ai_pipeline`)

**A1. Başlıkları Türkçe cümle düzenine geçir.** *(en yüksek etki / en düşük maliyet)*
- `reporter.py` → her üç `baslik_talimati` dalına tek satır: *"Başlığı CÜMLE DÜZENİNDE yaz: yalnızca ilk harf ve özel adlar büyük. Her kelimeyi büyük harfle başlatma — bu İngilizce geleneği, Türkçede yanlış."*
- Arşivdeki 1.000 başlık için geri yazım betiği. Özel adlar gövdeden çıkarılabilir: cümle ortasında büyük harfle geçen kelime özel addır.
- Doğrulayıcı: `denetle_baslik`'e kural eklenir, bir daha geri gelmez.

**A2. Başlık uzunluğuna gerçek dağılım ver.**
- Sabit pencere yerine haber başına hedef **çekilsin**: %15 çok kısa (3-5 kelime), %60 orta (6-9), %25 uzun (10-14).
- Tırnaklı başlığı aç: kaynakta güçlü bir alıntı varsa `Bakan Yumaklı: "..."` biçimi serbest olsun. Şu an 0 tane var.
- Soru başlığını `bilim` dalının dışına da aç.

**A3. Kısa haberi kısa haber olarak etiketle.**
- `kisa_haber_mi` eşiği gövde uzunluğuna göre de çalışsın: 200 kelimenin altındaki çıktı `article_format = 'kisa'` olsun. 342 kayıt için tek seferlik geri yazım.

**A4. Mobilya kuralını içeriğe bağla.**
- **Grafik**, ancak karşılaştırılabilir ≥3 rakam varsa. (Şu an 706/1.000 — fazla.)
- **"Öne Çıkanlar"** kutusu, ancak gövde 400 kelimeden uzunsa. 193 kelimelik habere özet kutusu koymak, metni tekrar etmek demek.
- **Ara başlık**, 300 kelimeden uzun her haberde zorunlu. (Şu an 649'unda hiç yok.)

**A5. `spot`u `summary`den ayır.**
- `summary` meta açıklama olarak kalsın (160 karakter, arama motoru için).
- `spot` okura yazılsın ve **farklı bir iş yapsın**: "bu neden önemli" cümlesi. Aynı metni iki kez göstermek şu an 999 haberde oluyor.

**A6. Anahtar kelime sayısını serbest bırak.**
- "5 tane üret" yerine "2 ile 7 arasında, yalnızca metinde gerçekten geçen terimler".

### B. SUNUŞ — uygulama tarafı

**B1. Hızı dağıt.** *(en yüksek etki)*
- Depodaki liste daraltması canlıya çıksın: 4,00 MB → 0,25 MB.
- Ana sayfa bölümleri tembelleştirilsin (denetim E7): tek `SliverToBoxAdapter` yerine çoklu sliver. Bu, görsellerin 20. saniye yerine ilk ekranda istenmesini sağlar.
- İlk ekrandaki 3-4 görsele `precache`.

**B2. Künye satırını yeniden kur.**
- "Google Haberler" **imza olarak gösterilmesin.** Yerine iki ayrı satır:
  - **Derleyen:** Tarım Portalı Haber Merkezi
  - **Kaynak:** Anadolu Ajansı *(bağlantılı)*
- `source_name` değeri "Google Haberler" olan 219 kayıt için gerçek kaynak `source_url`in alan adından çıkarılabilir.

**B3. Görsel künyesi.**
- `articles.image_credit` + `image_caption` sütunları (yeni migration).
- Hero görselin hemen altında küçük puntoyla: *"Fotoğraf: AA"*. `.dsy-foto` sınıfı zaten tanımlı (§39.1).
- Bu madde §8.3'ün kendi kuralının haber tarafına uygulanması.

**B4. Kısa haber için ayrı düzen.**
- `article_format == 'kisa'` olan haberde: hero bandı yok, grafik yok, kutular yok. Kart da küçük. Zaten var olan "Kısa Kısa" bölümünün mantığı detay sayfasına da taşınsın.

**B5. Etiket çiplerini canlandır ya da kaldır.**
- `/etiket/:slug` rotası (denetim M4) — çipler tıklanır olsun. Olmayacaksa çizilmesinler; ölü süs, boş süsten kötü.

**B6. Yazar şeridini farklılaştır.**
- Fotoğrafı olmayan yazarda aynı başak yerine, yazarın adının baş harfleriyle **birleştirilmiş** bir işaret ya da gerçek fotoğraf. Üç yazardan birinin jenerik ikon taşıması, üçünü birden şüpheli gösteriyor.

### C. GÜVEN — kurumsal katman (en az yapılmış, en çok ayrıştıracak olan)

**C1. "Nasıl Çalışıyoruz" sayfası.** Kısa, net, savunmacı olmayan. İçinde:
- hangi kaynaklardan derlendiği,
- metnin nasıl üretildiği ve **nasıl denetlendiği** (kaynaktaki her rakamın metinde aranması, uydurma yasağı, kaynaksız sayının yayına girmemesi — bunlar zaten var, yazılı değil),
- görsel politikası,
- düzeltme politikası ve iletişim.

Bu sayfa, §2.2'de ve §8.2'de zaten uyguladığın disiplinin okura görünür hâli. Şu an bu titizliği **sadece sen biliyorsun.**

**C2. Düzeltme kaydı.**
- `duzeltme_notu` + `duzeltildi_at` sütunları. Yayındaki metin değiştiğinde altta tek satır: *"3 Kasım 2026'da güncellendi: ..."*.
- `updated_at` bu işe yaramıyor — ölçüldü, her yazma (okunma sayacı dâhil) onu değiştiriyor.
- Düzeltmesini gösteren bir site, hiç hata yapmıyormuş gibi duran bir siteden daha güvenilirdir.

**C3. Haber merkezi kimliği.**
- Künyede gerçek bir sorumlu ad. İmzasız 1.000 haber, en çok "arkasında kimse yok" hissi veren şey.

**C4. Yayın ritmini düzle.**
- 09:00'daki 197'lik yığın gün içine dağıtılsın. Zamanlanmış yayın altyapısı (`publish_at`) için denetimde zaten madde var.

---

## 3. ÖNCELİK SIRASI

### Hemen — birkaç saat, etki büyük

| # | iş | neden ilk |
|---|---|---|
| 1 | **Liste daraltmasını dağıt** | siyah dairelerin ve 50 saniyenin tek sebebi; kod hazır |
| 2 | **Başlıkları cümle düzenine çevir** (hat + 1.000 geri yazım) | %100 içeriği etkileyen tek işaret |
| 3 | **"Google Haberler" imzasını kaldır** | 219 haberde güven kaybı |
| 4 | **`spot`u `summary`den ayır** | 999 haberde tekrar |

### Sonra — birkaç gün

| # | iş |
|---|---|
| 5 | Başlık uzunluk dağılımı + tırnaklı/soru başlık |
| 6 | Kısa haber etiketi (342 kayıt) ve kısa haber düzeni |
| 7 | Mobilya kuralı: grafik/kutu/ara başlık eşikleri |
| 8 | Görsel künyesi (migration + hat + arayüz) |
| 9 | Ana sayfayı tembelleştir (denetim E7) |
| 10 | `/etiket/:slug` (denetim M4) |

### Yapısal — bir hafta

| # | iş |
|---|---|
| 11 | "Nasıl Çalışıyoruz" + düzeltme politikası + haber merkezi künyesi |
| 12 | Düzeltme kaydı sütunları ve gösterimi |
| 13 | Tek kart bileşeni (denetim E11) — 15 kart sınıfının tekdüzeliği buradan geliyor |

---

## 4. TEK CÜMLE

Bu portalı "yapay zeka ürünü" gösteren şey yapay zekâ kullanması değil; **her haberin birbirine fazla benzemesi ve sayfanın yavaş açılması.** İkisi de ölçüldü, ikisinin de kaynağı belli, ikisi de düzeltilebilir — ve düzeltmenin hiçbir adımı bir şeyi gizlemeyi gerektirmiyor.
