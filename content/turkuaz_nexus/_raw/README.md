# Turkuaz Bağlantısallık Girişimi — araştırma günlüğü

Anasayfada kendi kartı olan, ülke/kurum dosyalarından **bilinçli olarak ayrı**
tasarlanmış etkileşimli bir sayfa. 12 Kasım 2026'da başlandı.

```
kaynak → _raw/kaynak_dosyalari/ → veri.json → sayfa
```

## Tur 1 — tarama

### Birincil belge bulundu

FAO'nun beş sayfalık `ce0820en` dokümanı: yönetici özeti, gerekçe, üç sütunun
uygulama planı, değişim teorisi, üyelik yapısı, kaynakça.

`_raw/kaynak_dosyalari/fao_tni_ce0820en.pdf`
sha256 `c5cde369bb54704d4cd985770a70c78844699d7653f5abd7502259caa81e3f0c`

**Metin çıkarımında tuzak:** PDF'in "ti" bağ karakteri bozuk çıkıyor
(`Ini/a/ve` = `Initiative`, `transforma6on` = `transformation`). Rakamlar temiz
geliyor ama metne girecek her rakam PDF'in kendisinden teyit edilecek.

### İki ad meselesi

| kaynak | ad |
|---|---|
| T.C. Tarım ve Orman Bakanlığı | **Turkuaz Bağlantısallık Girişimi** |
| FAO, IISD, uluslararası basın | **Turquoise Nexus Initiative (TNI)** |
| Anadolu Ajansı + bizim haberimiz | Turkuaz Nexus |

Sayfa iki resmî adı da gösterecek.

**ADIN GEREKÇESİ ARANDI, BULUNAMADI.** "Turkuaz" neden seçilmiş — hiçbir
birincil ya da ikincil kaynak açıklamıyor. Su mavisi + tarım yeşili = turkuaz
okuması TASARIM FİKRİ olarak kullanılıyor; sayfada bu konuda **iddia
kurulmayacak** ve altbilgide bulunamadığı yazılacak.

### Erişim

| kaynak | sonuç |
|---|---|
| FAO climate-change / FAST sayfaları | açık, zengin |
| FAO belge PDF'i (`fao.org/3/…` → `openknowledge.fao.org`) | 301 yönlendirmeden sonra açık |
| IISD Earth Negotiations Bulletin | WebFetch'e **403**, tarayıcı panelinden **açık** |
| openknowledge.fao.org arama | JS kabuğu, metin dönmüyor |
| Bakanlık haber sayfaları | açık |

ENB'nin 16 Haziran Bonn tutanağı en zengin bağımsız kaynak: konuşmacılar,
ülke tepkileri, girişimin iç mantığı.

### Canlı haber katmanı — ÖLÇÜLDÜ

1.365 yayımlanmış haber tarandı (ölçü: dosya hattının `terim_geciyor`
eşdeğeri, kelime sınırlı, büyük/küçük harf duyarsız):

| terim | başlık/seo | özet |
|---|---:|---:|
| Turkuaz | 3 | 0 |
| Bağlantısallık | 1 | 0 |
| Nexus | 2 | 0 |
| Turquoise Nexus · FAST Ortaklığı · gıda-su-iklim | 0 | 0 |
| COP31 | 38 | 0 |

**Girişimi adıyla anan haber: 3.** COP31 geçen: 38.

Karar: şerit **dar kümeyi** gösterecek. 12 Kasım 2026'da TİGEM dosyasında tam
bu hata düzeltildi — bir şeridi gevşek ilgili haberlerle doldurmak okuru
yanıltıyor ("damızlık" vakası: 29 haberin 27'si konuyla ilgisizdi). Üç haber
azdır ama dürüsttür; zamanla büyür.

### Görseller

Dosya hattının `gorsel_ara.mjs` aracı kopyalandı. **User-Agent'taki kişisel
e-posta çıkarıldı** — dış servise giden isteğe kişisel veri konmuyor.

Aday kareler lisans ve atıfla geliyor; GAP'tan damla sulama ve Türkiye'den
bahçe sulama kareleri mevcut.

**ALTYAZI KURALI BURADA DA GEÇERLİ:** altyazı fotoğrafın NE OLDUĞUNU söyler
(konu + yer + tarih), karede ne görüldüğünü anlatmaz. Ek bir tehlike var:
girişimin henüz hiçbir projesi YOK, dolayısıyla hiçbir fotoğraf "girişimin
işi" gibi sunulamaz.

## Kullanıcı kararları (12 Kasım 2026)

1. **Kendi etkileşimli bileşenleri** — ülke/kurum dosyalarından gözle görünür
   derecede farklı: tasarım, renk, yapı, kurgu, grafik, görsel, çizelge.
2. **Omurga: taahhüt takipçisi.** Bölümler: boşluğun haritası · gerekçe
   panosu · Türkiye'nin modeli · henüz bilinmeyenler.
3. **İki dilli.**
4. Belgedeki kişisel kurumsal e-posta sayfaya **konmayacak**.
5. Anasayfada **kendi kartı**.
6. Veri katmanı **karma**: bir kısmı gömülü, bir kısmı canlı.

## Açık kalan

- 10 Kasım lansmanının çıktısı hiçbir yerde yayımlanmadı. IISD'nin o günkü
  COP31 raporunda girişim geçmiyor. Takipçinin o halkası "çıktısı
  yayımlanmadı" durumunda duruyor — sessizce tamamlanmış sayılmıyor.
- Katılımcı ülke listesi, bütçe, sayısal hedef: üçü de yok.

## Tur 2 — SAYFA KURULDU

Yedi bileşen vardı, onları birleştiren ekran yoktu. Bu turda ekran, rota ve
anasayfa kartı yazıldı; sayfa yerel derlemede baştan sona çizildi.

| dosya | ne |
|---|---|
| `presentation/screens/tni_ekrani.dart` | Sekiz bölümü sıraya koyan ekran |
| `presentation/widgets/tni_anasayfa_karti.dart` | Anasayfa kartı |
| `core/router/app_router.dart` | `turkuazPath` + rota + `routeFor` kaydı |
| `features/home/.../home_screen.dart` | Kart üç yerleşime de eklendi |

**Bölüm numaraları bileşenlerin kendinde.** 01-06 başlıklarını bileşenler
çiziyor; ekran yalnız sıralıyor. Ekranın eklediği iki bölüm: **07 henüz
bilinmeyenler** (verisi `TniSayfaVerisi`'nden geliyor) ve **08 haberlerde**.

### Bu turda çıkan üç şey

**1. `TniKart.kesikKenar` okunmuyordu.** Alan tanımlıydı, `build` onu hiç
kullanmıyordu: kesik kenar isteyen çağrı sessizce düz kenar alıyordu.
Tasarım künyesinin kendi kuralı ("durumun üç ayrı işareti var: renk, simge,
dolgu") bu yüzden yarım kalıyordu. Alan gerçek yapıldı
(`_KesikKenarBoyaci`, 5/4 çizgi-boşluk).

**2. `/turkuaz` adresi ÇAKIŞIYOR.** Görseller `web/turkuaz/` klasöründe ve
derlemede `build/web/turkuaz/` oluyor. Yerel SPA sunucusu `/turkuaz`
isteğine o klasörün DİZİN LİSTESİNİ döndürdü, sayfa hiç açılmadı. Firebase
Hosting'de statik eşleşme bulunamayıp yeniden yazmaya düşeceği için orada
çalışması muhtemeldi — ama adresin açılması sunucunun bakma sırasına bağlı
kalmamalı. Adres `/turkuaz-girisimi` oldu; görsellerin yayımlanmış adresleri
(`tarimportali.net/turkuaz/...`) değişmedi.

**3. Kartta sayı YOK — bilerek.** Takipçinin sayıları canlı örtüden
güncellenebiliyor. Aynı sayıları karta koymak anasayfanın her açılışına bir
Supabase sorgusu daha eklerdi ve örtü okunamadığında kartla sayfa AYRI sayı
gösterirdi. Teaser'ın işi saymak değil çağırmak; durum rozeti ("ÖNERİLEN")
gömülü katmanda, bayatlayamaz.

### Yerel doğrulama (12 Kasım 2026)

`flutter build web --release` → `tool/spa_sunucu.py 8131`.

- `/turkuaz-girisimi` açılıyor; sekiz bölümün sekizi de çiziliyor.
- Anasayfa kartı üç yerleşimde de görünüyor ve sayfayı açıyor.
- **Canlı örtü OKUNAMIYOR.** `tni_ortu` ve `tni_haberleri` istekleri 404;
  göçler depoda (`20261112170000`, `20261112180000`) ama veritabanına
  uygulanmamış. Sayfa gömülü katmanla çizildi ve künyede bunu AÇIKÇA
  söyledi — tasarlandığı gibi. 08. bölüm (haberler) bu yüzden hiç
  çizilmiyor; boş şerit göstermiyor.
- **Görseller 404.** `tarimportali.net/turkuaz/*.jpg` henüz yayımlanmadı;
  `web/turkuaz/` yerelde duruyor. Dağıtımdan sonra çözülür.
- Adres çubuğu uygulama içi gezinmede değişmiyor — bu sayfaya özgü DEĞİL,
  haber ve dosya bağlantılarında da aynı. Önceden var olan davranış.

## Tur 3'e kalanlar

1. Göçleri uygula (`supabase db push`) — kullanıcı onayı ister.
2. Dağıt — görseller ve uygulama birlikte; kullanıcı onayı ister.
3. Açık mod kartı ince kalıyor: `gunZemin #F0F5F4` ile anasayfanın kremi
   birbirine yakın. Koyu modda pano güçlü. Kullanıcı kararı.

## Tur 3 — DİL, ÇEMBERLER, ŞERİT, GÖRSELLER

Kullanıcının dört düzeltmesi uygulandı.

### 1. Çerçeve değişti: takipçi DEĞİL, tanıtım

Kullanıcı (12 Kasım): *"bizim amacımız 2030'a kadar bu taahhütü takip etmek
olamaz. çok uzun bir vaat. sadece girişimi tanıtıyoruz. ne olduğu ne
hedeflediği ve ne olması beklendiği."*

"Taahhüt takipçisi" ifadesi ve ondan türeyen bütün dil kaldırıldı:

| eski | yeni |
|---|---|
| OMURGA · Taahhüt takipçisi | GİDİŞAT · Nereden geldi, nereye gidiyor |
| GERÇEKLEŞTİ | OLDU |
| ÇIKTISI YAYIMLANMADI | SONUÇ DUYURULMADI |
| BEKLİYOR | BEKLENİYOR |
| TAKİPÇİYİ AÇ | SAYFAYI AÇ |

### 2. Üslup: okura konuşuyoruz, kendimize değil

Sayfanın KENDİNDEN bahseden cümleler ayıklandı. Kaldırılan kalıplar:
"sayfa şunu gösteriyor", "halka", "kalem", "gömülü katman", "canlı katman",
"aranıp bulunamadı", "sessizce tamamlanmış sayılmaz".

Örnek — künyedeki durum satırı:
> eski: *"Canlı katman okunamadı; sayfa 2026-11-12 tarihinde kilitlenen gömülü
> katmanla çizildi."*
> yeni: *"Sayfayı 12 Kasım 2026 tarihindeki hâliyle görüyorsunuz. Daha yeni bir
> gelişme varsa henüz buraya ulaşmamış olabilir."*

### 3. Çemberler kendiliğinden birleşiyor

Düğme kaldırıldı. En yakın `Scrollable`'ın konumu dinleniyor
(`visibility_detector` paketi projede yok, bir görünürlük sezgisi için paket
eklemek fazlaydı); bölümün üstü ekranın alt dörtte birine girince birleşme
başlıyor. **Tek yönlü:** geri alınmıyor, yoksa çizim gördüğünü geri alan bir
oyuncağa dönüyor.

Üç yeni şey: adlar küçülerek dairelerin sol üst / sağ üst / alt ortasına
kayıyor · ortak küme `Path.combine` ile GERÇEKTEN çiziliyor (elle değil, yani
daireler kımıldadıkça kesişim de kımıldıyor) · TNI ortak kümenin ağırlık
merkezinde, büyük ve soluk geçişle beliriyor (birleşme %55'i geçtikten sonra —
iki hareket aynı anda olursa göz ikisini de kaçırıyor).

### 4. Görseller YÜKLENMİYORDU — sebep bulundu

`veri.json` görselleri `https://tarimportali.net/turkuaz/...` ile çağırıyordu;
o adresler **henüz dağıtılmadı**, üçü de 404 veriyordu. Dosyalar ise
`web/turkuaz/` altında, yani derlemenin İÇİNDE duruyor.

Göreli yol yazmak çözüm DEĞİL: `NewsArticleImage` http/https ile başlamayan
adresi reddedip yerine ışıltı kutusu koyuyor — sessizce. Çözüm `TniGorsel.adres()`:
adresi sayfanın kendi kaynağından kuruyor (`Uri.base.origin`), web dışında
yayımlanmış adrese düşüyor. `veri.json`'daki `adres` alanına dokunulmadı —
o alan karenin yayımlanmış adresinin KAYDI ve paylaşım kartı onu kullanıyor.

### 5. Kart gitti, ŞERİT geldi

Kullanıcı kartın yerini ve tasarımını beğenmedi. Yeni hâli (kullanıcı kararı):
**Dünyadan Haberler ile Sektörler arasında, tam genişlikte, alçak, görsel
kapaklı bant.**

- `tni_anasayfa_karti.dart` silindi → `tni_anasayfa_seridi.dart`
- Zemin Atatürk Barajı karesi; soldan sağa perde (sol %96 opak, sağ %34) —
  düz karartma hem fotoğrafı hem yazıyı bulandırıyordu
- Yükseklik 124 / 140 / 156; üç satırı zor geçiyor
- `isDark` parametresi YOK: şerit iki temada da koyu. Önceki kartın açık modda
  krem zemine karışması sorunu kökünden böyle çözüldü
- Karenin künyesi sağ altta: adı ve çekeni görünen bir fotoğraf "bu onların
  işi" diye okunmaz — girişimin henüz hiçbir projesi yok

### Yerel doğrulama

Üç kare de yükleniyor (175 KB / 269 KB / 372 KB, sayfanın kendi kaynağından).
Çemberler kaydırmada birleşiyor, TNI ortada beliriyor. Şerit masaüstünde ve
375 px telefonda doğru yerde, alçak ve iki yana dayalı.

## Tur 4 — OKURUN GÖZÜYLE GEÇİŞ

Kullanıcı sayfayı okuyup madde madde düzelttirdi. Hepsi aynı kökten: sayfa
yer yer kendinden, yöntemden ya da arayüzden bahsediyordu.

| ne | neden |
|---|---|
| TNI puntosu r*0.5 → r*0.3 | Yazı ortak kümenin dışına taşıyordu; ad, içinde durduğu şeklin sınırını aşınca "ortak küme" fikri görünmez oluyor |
| "≈ ya…" | `gosterim_tr` = "≈ yarısı" 48 punto ile kesiliyordu. `FittedBox(scaleDown)`: rakam kartlarında bir şey değişmiyor, kelime olan tek kartta yazı sığacak kadar küçülüyor |
| Uydu karesinin notu silindi | "Commons künyesinde açıklama alanı boş" — okura söylenecek bir şey değil |
| Amu Derya notu | "Kaynak künyesi … kaydediyor" iskelesi kalktı, bilgi kaldı |
| §07 girişi | "Bir girişimi anlatmanın en kolay yolu bilinmeyenleri hiç anmamaktır" haberi yapılan kuruma laf atmak gibi okunuyordu. Yeni hâli: "Girişim yeni; bazı başlıkları henüz netleşmedi." Nasıl çalıştığına dair açıklamalar kaldırıldı |
| "Adın neden Turkuaz olduğunu bulamadık" | Kullanıcı: *"kullanıcı senin neyi neden bulamadığınla ilgilenmez, neyi bulduğunla ilgilenir."* Cümle silindi — adın anlamına dair iddia kurmamak için onu söylemek gerekmiyor |
| Gerekçe panosu girişi | "dokununca kaynak ve varsa çekince açılıyor" bir kullanım kılavuzu cümlesiydi |
| Antalya lansmanındaki sarı kutu | Kaldırıldı |
| "ÖNERİLEN" rozeti | Sayfadan ve şeritten kaldırıldı |
| İki tepki notu | "Bu kayıt … gösteriyor" kalıbı ayıklandı |

### Alıntı bloğu yenilendi

Kullanıcı: *"insanların söylediği atıfları daha belirgin, estetik, modern yap."*
`TniSoz` artık yüzeyi, sol turkuaz rayı, arkada soluk bir tırnak, ayırıcı ve
künye satırı olan bir blok. Künyede kişinin baş harfi bir daire içinde —
fotoğraf değil: konuşanların çoğu kamu görevlisi ve resmî fotoğraflarının
lisansı belirsiz. Harf yüzün yerini tutmuyor, sözün bir KİŞİYE ait olduğunu
söylüyor. Tepki kartlarında da kişi unvandan öne çıkarıldı.

### Yabancı sesler eklendi

Kullanıcı *"bulabilirsen birkaç yabancı kişinin de alıntılarını ekle"* dedi.
Aramaya gerek kalmadı: veri katmanında zaten vardı, sayfaya konmamıştı.

- **Martial Bernoux** (FAO) → kapağın hemen altına. Yukarıdaki kart girişimin
  çatısının FAO olduğunu söylüyor; hemen ardından FAO'dan birinin girişimi
  nasıl tarif ettiği geliyor. Sayfanın ilk yabancı sesi.
- **Fatma Varank** (COP31 Başkanlığı) → §01'in sonuna.

Tepkiler bölümünde zaten duranlar: Kaveh Zahedi (FAO), Andrea Porro (Dünya
Çiftçi Örgütü), Thomas Patriota (Brezilya), Sally Higgins (COP31 Gençlik
Şampiyonu), Mısır, YOUNGO. Yani ENB tutanağındaki yabancı konuşmacıların
tamamı sayfada.

## GÖÇLER UYGULANDI VE DAĞITILDI — 12 Kasım 2026

Kullanıcı onayıyla. Üç göç birden gitti:

    20261112170000_tni_ortu      ✓
    20261112180000_tni_haberleri ✓
    20261112190000_sergi         ✓   (sergi oturumunun göçü)

Uygulama sonrası anon anahtarla ölçüldü:

| ne | sonuç |
|---|---|
| `sergi_yarismalari` (anon) | `[]` — yarışma **yayında DEĞİL**, olması gereken bu |
| `tni_ortu` (anon) | `[]` — örtü boş; göçün kendi sınama satırları silinmiş |
| `tni_haberleri` RPC | üç haber döndü |

**Dağıtım: `./deploy.sh --hosting`.** Fonksiyon dağıtılmadı — bu değişiklik
yalnız web içeriği, ve depodaki `functions/` canlının gerisinde (betiğin kendi
bekçisi de bu durumda `--hosting` diyor). `--dart-define` kullanılmadı.
355 dosya, 120'si yeni.

Canlı denetim (durum kodu değil içerik türü ve gövde):

    200 image/jpeg 269354  tarimportali.net/turkuaz/tni_ataturk_baraji.jpg
    200 image/jpeg 175290  tarimportali.net/turkuaz/tni_amu_derya.jpg
    200 image/jpeg 372309  tarimportali.net/turkuaz/tni_ataturk_uydu.jpg
    200 image/jpeg  69932  tarimportali.net/sergi/utoify-16/odul-01-…jpg

Sayfa canlıda açılıyor ve künyedeki satır artık **"Güncel"** diyor — yani
canlı katman okunuyor, göç öncesi gömülü katmana düşen hâl geçti. Haberler
bölümü de artık çiziliyor.

**Tarayıcı panelinin kısıtı, sitenin değil:** panel bu görselleri çözemiyor
(`EncodingError`), bu yüzden ekran görüntülerinde kutular boş çıkıyor.
Kullanıcı kendi tarayıcısında görsellerin geldiğini doğruladı. Dosyalar
yukarıdaki ölçümle zaten sağlam.

## Sırada — KULLANICI KARARI

1. **Sergi yarışmasını yayına alma** ayrı bir karar ve kullanıcınındır. Sergi
   oturumunun verdiği komut:

       update public.sergi_yarismalari set yayinda = true, guncellendi = now()
       where kod = 'utoify-16';

   Kareler dağıtıldı, yani artık yayına alınabilir durumda — ama söylenmeden
   yapılmıyor.
2. TNI örtüsü boş. Takipçideki durumlar bugün gömülü katmandan geliyor; bir
   adımın durumu değişince `tni_ortu`'ya satır girilecek, yeni dağıtım
   gerekmiyor.

