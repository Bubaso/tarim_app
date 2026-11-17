# 9 · Ürün izleme ve verim tahmini

> **Özet.** Hasattan önce rekolteyi bilmek; erken uyarı, piyasa ve stok kararları için gerekli. Avrupa Komisyonu'nun verim tahmin sistemi bunu bitki modeli çıktıları, hava, uydu ve toprak verisinden oluşan bir veritabanıyla yapıyor: 1993-2015 arasında **19.980** tahmin yayımladı; 2006-2015 değerlendirmesinde ortanca hata Fransa'da **%3,73**, Portekiz'de **%14,37** ve bu dönemde hiçbir üründe anlamlı bir iyileşme görülmedi. Makine öğrenmesi bu sisteme karşı sınandığında kimi üründe ona yetişti, kimisinde iki kat hata yaptı. Türkiye'de resmî rekolte tahmini, Bakanlığın metaverisine göre ilçe müdürlüklerinin kayıtlarına ve tarım teknisyenlerinin izlenimlerine dayanıyor; Bakanlık 2025'te uydu görüntüsü ve makine öğrenmesiyle hangi tarlada ne ekildiğini belirlemeye başladı.

## Ne yapıyor

Ürün izlemenin iki ayrı sorusu var. İlki: tarlada ne ekili? Uydu aynı tarlayı sezon boyunca tekrar tekrar görüntülediğinde her ürün kendine özgü bir yeşerme ve sararma eğrisi çiziyor; ekili ürünü bilinen tarlalardan bu eğrileri öğrenen bir model ötekileri sınıflandırıyor. İkincisi: ne kadar kalkacak? Verim tahmini bitki büyüme modellerini, hava verisini ve uydu göstergelerini birleştirip hasattan haftalar önce bir rakam üretmeye çalışıyor.

Yapay zekâ bu iki soruya farklı mesafede. Tarladaki ürünü bulmak, etiketli örneklerden öğrenen sınıflandırma modellerinin doğrudan işi; Türkiye'deki çalışmalar da Bakanlığın yeni sistemi de bu yolu izliyor. Verim tahmininde ise Avrupa Komisyonu'nun büyük ölçekli sistemi, 2021'de yayımlanan bir değerlendirmeye göre makine öğrenmesi kullanmıyordu.

## Verim tahmini ne kadar tutuyor

Avrupa Komisyonu'nun MARS verim tahmin sistemi (MCYFS) AB ülkeleri için 1993-2015 arasında **19.980** tahmin yayımladı. Van der Velde ve Nisini (2019) yumuşak ve makarnalık buğday, tane mısır, kolza, ayçiçeği, patates ve şeker pancarı tahminlerini gerçekleşen verimle karşılaştırdı. Hata ölçüsü MAPE: tahminin gerçekleşen verimden ortalama yüzde kaç saptığı.

| Ölçü (2006-2015) | Sonuç |
|---|---|
| En düşük ortanca hata | **%3,73** — Fransa |
| En yüksek ortanca hata | **%14,37** — Portekiz |
| Sezon içinde | Hasat yaklaştıkça hata da oynaklığı da azalıyor |
| Yıldan yıla | Hiçbir üründe anlamlı iyileşme yok |

Sezon içindeki iyileşme tahıllarda belirgin, yağlı tohumlarda daha zayıf. Tahminler genellikle gerçekleşen verimin altında kaldı; yumuşak buğday, kolza ve şeker pancarında bu eğilim bütün üye ülkelerde sistematik. Uzun dönemde ilk **12** üye için kolza, patates ve şeker pancarı tahminleri 1993-2015 arasında iyileşti; ama 2006-2015'te **27** üyeli AB düzeyinde hiçbir üründe anlamlı bir iyileşme görülmedi. Yazarlar verim istatistiklerinde oynaklığın arttığını görüyor ve operasyonel verim tahminini geliştirmek için yeni bir çabaya ihtiyaç olduğunu söylüyor.

## Yapay zekâ nerede duruyor

Paudel ve arkadaşları (2021), aynı sistemin veritabanındaki bitki modeli çıktıları, hava, uydu ve toprak verisiyle bir makine öğrenmesi modeli kurdu. Hollanda, Almanya ve Fransa'da beş ürünün verimini bölge düzeyinde tahmin etti, sonuçları ulusal düzeye toplayıp sistemin geçmiş tahminleriyle karşılaştırdı. Tohum ekiminden **30** gün sonraki erken sezon tahmininden iki örnek (normalleştirilmiş hata, NRMSE; düşük olan daha iyi):

| Ürün ve ülke | Makine öğrenmesi | MARS sistemi |
|---|---|---|
| Yumuşak buğday, Hollanda | **7,87** | **6,32** |
| Şeker pancarı, Almanya | **8,21** | **8,79** |

Erken sezonda Hollanda'da bütün ürünlerde, Almanya'da yumuşak buğday dışındakilerde, Fransa'da yumuşak buğday, yazlık arpa ve ayçiçeğinde iki yöntem birbirine yakın. Ama Almanya'da yumuşak buğdayda, Fransa'da şeker pancarı ve patateste makine öğrenmesinin hatası sistemin iki katı. Sezon sonunda Hollanda'da yine yakın, Almanya ve Fransa'da daha kötü. Yazarlar çalışmayı bir başlangıç çizgisi olarak sunuyor: yeni veri kaynakları, daha iyi değişkenler ve başka algoritmalarla iyileştirilebilir. Bu karşılaştırmada makine öğrenmesi, büyük ölçekli verim tahmininde yerleşik sistemi geride bırakmadı.

AB'de ürün tespitinde uydu verisi artık yasal bir gereklilik. AB'nin ortak tarım politikasının finansmanını ve izlenmesini düzenleyen 2021/2116 sayılı Tüzük, üye ülkelerden bir alan izleme sistemi kurmalarını istiyor: tarımsal faaliyetin Copernicus Sentinel uydu verisiyle ya da en az onun değerinde veriyle düzenli ve sistematik olarak gözlenmesi, izlenmesi ve değerlendirilmesi. Sistemin 1 Ocak 2023'ten itibaren çalışır, en geç 1 Ocak 2024'te bütün üye ülkelerde tam işler olması gerekiyor; ülkeler kalitesini her yıl Birlik düzeyinde belirlenen yönteme göre değerlendiriyor. Tüzük Sentinel verisini ya da eşdeğerini şart koşuyor; analiz yöntemini belirlemiyor.

## Türkiye

Türkiye'de resmî bitkisel üretim tahminleri Bakanlığın Tarım Reformu Genel Müdürlüğü'nün istatistik bülteninde yayımlanıyor: mayıs ve ekimde birinci ve ikinci tahmin, aralıkta nihai sonuç. Bakanlığın metaverisi yöntemi şöyle tarif ediyor: veriler il ve ilçe müdürlüklerince toplanıp web tabanlı bir istatistik sistemine giriliyor; bunlar ilçe müdürlüklerinin elindeki kaynak bilgilere, ÇKS gibi idari kayıtlara ve tarım teknisyenlerinin kendi bölgeleri hakkındaki izlenimlerine dayanan bilgiler. Tarif edilen yöntemde uydu ya da model kullanılmıyor.

Modelle verim tahmini Türkiye'de yeni değil. 2005-2006 sezonunda, FAO destekli bir projeyle kışlık buğday için agrometeorolojik verim tahmini bültenleri başladı. FAO'nun simülasyon yöntemi, bitkinin su ihtiyacının yetişme dönemi boyunca karşılanıp karşılanmadığını hesaplıyor, sonucu Devlet İstatistik Enstitüsü'nün uzun yıllar verim istatistikleriyle ilişkilendiriyor ve her **10** günde bir yeniden çalışıyordu. Bültenler sürdü: Tarla Bitkileri Merkez Araştırma Enstitüsü'nün Mayıs 2020 bülteni il il buğday verim tahmini veriyor, Türkiye ortalamasını dekara **232,5** kg, uzun yıllar ortalamasının **%7,9** altında hesaplıyordu. Bülten, Bakanlığın İzleme, Erken Uyarı ve Tahmin Komitesi'ne bilgi taşıyordu.

Bu bültenlerin hepsi bugün Toprak Gübre ve Su Kaynakları Merkez Araştırma Enstitüsü'nün AGROSENS sayfasında listeleniyor ve adları yolculuğu anlatıyor: 2020'ye kadarki adların çoğunda verim tahmini geçiyor; 2022'den itibaren meteoroloji ve ürün izleme, son sayılarda uzaktan algılama destekli tarımsal izleme. Nisan 2026 sayısı (**58**. sayı) bitki gelişimini uydudan NDVI, tarımsal stres ve fotosentetik aktivite göstergeleriyle, yağış ve sıcaklık analizleriyle izliyor; verim için bölgesel gözleme dayalı nitel bir beklenti yazıyor, dekara rakam vermiyor. Mayıs 2024, Mayıs 2025 ve Kasım 2025 sayıları da dekara verim tahmini vermiyor. Bülten kendi sınırını da açıkça söylüyor: ilkbahar başındaki değerler yıl sonu performansı için belirleyici değil; asıl belirleyici dönem mayıs–temmuz.

Ürün izlemede resmî kullanıma yapay zekâ ürün tespitiyle girdi. Bakanlık 2025 üretim yılında Uzaktan Algılama ile Ürün Belirleme Çalışmaları'nı ilk kez uygulamaya aldı: sahadan toplanan referans parseller uydu görüntüleriyle birlikte değerlendiriliyor, makine öğrenmesiyle ekili ürünler tespit edilip sınıflandırılıyor ve üretim desenleri belirleniyor. Tarım Reformu Genel Müdürlüğü'nün Temmuz 2026 duyurusuna göre sistem için **12** bölge toplantısı yapıldı; ÇKS beyanlarının doğruluk kontrolü de bu kapsamda planlanıyor. Bakanlık alanların yüksek doğruluk oranlarıyla analiz edildiğini söylüyor, ama bir doğruluk oranı açıklamadı. Toplantılarda öne çıkan nokta öğretici: kışlık ürünlerde referans parsellerin hasattan önce hızlı, doğru ve yeterli yoğunlukta toplanması sistemin başarısını doğrudan etkiliyor.

Böyle bir sistemin ne kadar iyi çalışabileceğine dair en yakın ipuçları araştırmalardan geliyor. Mardin'de 2018 yılının altı farklı tarihli Sentinel-2 görüntüsüyle rastgele orman algoritması mısır, buğday, pamuk, nohut ve mercimeği parsel bazında ayırdı; doğruluk ÇKS kayıtlarına göre ölçüldü ve genel doğruluk **%96,35** çıktı (Altun ve Türker, 2021) — tek bölge, tek yıl. Tarım Reformu Genel Müdürlüğü'nde çalışan bir yazarın makalesi, Arazi Parsel Tanımlama Sistemi'ndeki **13,5** milyon fiziksel bloğu **370** Sentinel-2 karesiyle LightGBM algoritmasından geçirip 2021 için ülke ölçeğinde bir arazi örtüsü ve kullanımı haritası çıkardı; genel doğruluk **%86,07** (Şimşek, 2023). Yozgat'ta ise uydu verisi ve tapu kadastro parsel sınırlarıyla buğday ve arpa beyanlarını tam otomatik denetlemeyi amaçlayan bir sistem, sahada toplanan doğrulama verisiyle sınandı; bir parsele iki farklı ürün ekildiğinde yöntem hatalı sonuç verdi (Yaşar ve Yağcı, 2024).

2027 Programı tarım istatistiklerinin derlenmesi ve kontrolü için düzenleme yapılmasını; 2025 Genel Tarım Sayımı'nın verisiyle bütün tarım işletmelerini kaydeden ve kayıtları mekânsal veriyle gerçek zamanlı güncelleyen bir Tarımsal İşletme Kayıt Sistemi kurulmasını; kayıt ve bilgi sistemlerinin erken uyarı, piyasa kontrolü, üretim planlaması ve stok yönetimine hizmet edecek biçimde tasarlanmasını öngörüyor. Kuraklığın uydu verisiyle izlenmesi (TAKİS) ve yapay zekâyla tahmini §7'de.

Resmî rekolte tahmini ile yapay zekâlı ürün tespiti aynı genel müdürlükte duruyor; ama ikincisinin birincisine girip girmediği açıklanmadı. Eksik olan ise **Türkiye'de yapay zekâyla yapılmış bir rekolte tahminini resmî tahminle ya da gerçekleşen üretimle karşılaştıran, yayımlanmış bir değerlendirme.**

## Bu sayfa nasıl güncelleniyor

Bu sayfa iki şeyi izliyor: verim tahmini, ürün izleme ve ürün sınıflandırma alanındaki yeni gelişmeler — hakemli çalışmalar ve Bakanlığın ürün belirleme sistemi dâhil; ve buradaki sayıların kaynaklarının yeni sürümleri: yeni bitkisel üretim tahmini bültenleri, yeni AGROSENS sayıları. Yeni bilgi, editör onayından sonra sayfaya ekleniyor.
