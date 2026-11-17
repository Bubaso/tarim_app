# 3 · Kısa tarihçe

> **Özet.** Tarımda bugünkü yapay zekâ üç eski damarın birleştiği yerde duruyor: uydudan ürün izleme (1972'den bu yana), bilgisayara karar verdirme (1980'lerin uzman sistemleri) ve tarlada konum bilgisi (1990'larda GPS ve hassas tarım). 1977'de uydu verisiyle yapılan bir tahmin Sovyet buğday hasadını resmî rakamın yaklaşık **%1** yakınında buldu; 1988'de **150**'ye yakın çiftçi bir pamuk uzman sistemini kullanıyordu; hassas tarıma ayrılmış ilk uluslararası konferans 1992'de toplandı. 2008'den sonra Landsat ve Sentinel verisi ücretsizleşti, 2012'de derin öğrenme görüntü tanımada sıçrama yaptı, 2022'den sonra yapay zekâlı sohbet robotları çiftçinin sorusunu yanıtlamaya başladı. Türkiye'de bu hikâyenin temelinde bir kayıt var: Dünya Bankası'nın Türkiye'nin temel kırsal veri tabanı dediği çiftçi kaydı, 2000'deki pilot uygulamanın ardından doğrudan gelir desteğiyle kuruldu.

## Uydudan ürün izleme (1972-1978)

Landsat 1, 23 Temmuz 1972'de fırlatıldı. NASA'nın anlatımına göre ABD, dünyadaki kıtlıktan habersiz, Sovyetler Birliği'ne **15** milyon ton buğdayı büyük bir indirimle sattı; Great Grain Robbery (Büyük Tahıl Soygunu) diye anılan bu satıştan sonra hükümet, ürünleri dünya ölçeğinde izleyecek doğru ve güncel bir sisteme ihtiyaç olduğunu gördü ve yeni fırlatılan Landsat 1'e yöneldi.

NASA, ABD Tarım Bakanlığı ve Ulusal Okyanus ve Atmosfer İdaresi'nin (NOAA) ortak deneyi LACIE 1974'te başladı ve 30 Haziran 1978'de tamamlandı. Hedef, hasat anındaki üretim tahmininin zamanın **%90**'ında gerçek ülke üretiminin ±**%10**'u içinde kalmasıydı; LACIE bu hedefi ABD'nin Büyük Ovalar bölgesinde ve Sovyetler Birliği'nde iki yıl üst üste tutturdu. Ağustos 1977'de Sovyet yazlık buğdayındaki açığı önceden gösterdi; son tahmini **91,4** milyon ton, Sovyetlerin resmî rakamı **92,0** milyon tondu. Kanada'daki uygulama daha az başarılı oldu. NASA'ya göre LACIE, uydu görüntüsünü gözle yorumlamaktan sayısal görüntü işlemeye geçişi işaret ediyordu; 1978'de ABD Tarım Bakanlığı'nın bu teknolojiye dayanan sistemi işletmeye başlamıştı.

## Bilgisayara karar verdirmek: uzman sistemler (1980-1988)

1980'de Michalski ve Chilausky, soya hastalıklarını teşhis eden bir uzman sistem için bilgi edinmenin iki yolunu karşılaştırdı: uzmanın kurallarını kodlamak ve bilgisayarın örneklerden kural çıkarması. Michalski ve Baskin'in 1983 tarihli bildirisine göre örneklerden kural çıkaran programın uzman sistemde kullanılabilirliği bu soya hastalığı sisteminde kanıtlandı. Çalışmanın veri seti 1988'de UCI Makine Öğrenmesi Deposu'na girdi; depo onu Michalski'nin ünlü soya hastalığı veritabanı olarak anıyor.

ABD Tarım Bakanlığı'nın araştırma servisi aynı yıllarda pamuk için COMAX'ı geliştirdi. Lemmon'ın 1986'da Science'ta anlattığı sistemin bilgi tabanı üç parçadan oluşuyordu: bir pamuk bitkisi simülasyon modeli (on iki yılda geliştirilen GOSSYM), eğer-ise (if-then) kuralları ve bir çıkarım motoru. Tarladaki sensörler hava koşullarını sisteme otomatik olarak bildiriyor, COMAX önerilerini her gün yeniden değerlendiriyordu; sistem üreticiye azot, sulama ve büyüme düzenleyici uygulamaları konusunda öneri veriyordu. 1988'de Kaliforniya'dan Kuzey Karolina'ya **150**'ye yakın çiftçi modeli kullandı; ABD Tarım Bakanlığı GOSSYM-COMAX'ı çiftlikte uygulanacak ilk ürün simülasyon modeli olarak seçmişti.

## Tarlada konum: GPS ve hassas tarım (1983-2000)

Hassas tarımın temeli uydudan konum. 16 Eylül 1983'te, Sovyetlerin bir Kore sivil yolcu uçağına saldırısı üzerine yapılan bir açıklamada ABD, Küresel Konum Belirleme Sistemi'ni (GPS) 1988'de işletime girdiğinde sivil uçaklara açmaya hazır olduğunu duyurdu. GPS 1995'te işletimde ilan edildi. 1 Mayıs 2000'de Başkan Clinton, kamuya açık GPS sinyallerinin kasıtlı olarak bozulmasının o gece yarısından itibaren durdurulacağını açıkladı; sivil kullanıcılar konumu öncekinden on kata kadar daha doğru bulabilecekti.

Hassas tarıma ayrılmış ilk uluslararası konferans Temmuz 1992'de Minnesota'nın St. Paul kentinde, Pierre Robert'in başkanlığında toplandı. Lowenberg-DeBoer ve Erickson'a göre ticari olarak başarılı ilk tahıl verim monitörleri de 1992'de piyasaya çıktı; uydu konumuyla otomatik yönlendirme 1990'ların sonunda önce Avustralya'da, kısa süre sonra Kuzey Amerika'da ticarileşti. ABD Tarım Bakanlığı Ekonomik Araştırma Servisi (ERS) ise verim monitörünün ticarileşmesini 1993'e, değişken oranlı uygulama ekipmanınınkini 1995'e tarihliyor.

## Açık veri ve derin öğrenme (2008-2019)

ABD 2008'de Landsat arşivini ücretsiz yaptı; NASA'ya göre veri kullanımı **20** kat arttı (§19). AB, 12 Temmuz 2013 tarihli bir tüzükle Sentinel uydularının verisine erişimin ücretsiz, tam ve açık olmasını kurala bağladı; Sentinel-2A 23 Haziran 2015'te fırlatıldı.

2012'de derin evrişimli bir sinir ağı ImageNet görüntü tanıma yarışmasını, en iyi beş tahminde **%15,3** hata oranıyla kazandı; ikinci gelenin hata oranı **%26,2**'ydi (Krizhevsky, Sutskever ve Hinton). Yöntem kısa sürede tarıma taşındı: Mohanty ve arkadaşları, Krizhevsky'nin çalışmasına dayanarak eğittikleri modelin kontrollü koşullarda çekilmiş **54.306** yaprak görüntüsünden ayrılmış test görüntülerinde **%99,35** doğruluğa ulaştığını 2016'da yayımladı ve bunu akıllı telefonla bitki hastalığı teşhisine doğru ilk adım saydı; başka koşullarda çekilmiş görüntülerde doğruluk **%31**'in biraz üstünde kaldı (§26).

John Deere Eylül 2017'de, bilgisayarlı görü ve makine öğrenmesiyle yalnız yabancı otun olduğu yere ilaç atan bir teknoloji geliştiren Blue River Technology'yi satın alacağını duyurdu. Şirketin 2019 raporuna göre See & Spray adlı bu teknoloji o tarihte henüz tam olarak ticarileşmemişti. Şirketin bugünkü kullanıma dair beyanları ve hedefli ilaçlamanın hakemli saha denemeleri §8'de.

## Tahmin ve dil (2022-2025)

ChatGPT 30 Kasım 2022'de kamuya açıldı. Ardından yapay zekâlı sohbet robotları çiftçi danışmanlığına girdi: Hindistan'ın sesle çalışan, yapay zekâlı sohbet robotu Kisan e-Mitra 2023'te devlet programlarına dair soruları yanıtlamaya başladı (§22); Digital Green'in üretken yapay zekâyla çalışan sohbet robotu FarmerChat, geliştiricilerinin hakem değerlendirmesinden geçmemiş çalışmasına göre dört ülkede **15.000**'i aşkın çiftçiye ulaştı. Hava tahmininde GraphCast 2023'te **1.380** doğrulama hedefinin **%90**'ında işletimdeki en doğru sistemleri geçti; Avrupa Orta Vadeli Hava Tahminleri Merkezi kendi yapay zekâ modelini 25 Şubat 2025'te işletime aldı (§17).

## Türkiye

Türkiye'de bu hikâyenin temelinde bir kayıt var. Dünya Bankası'na göre 2000 tarım yılında beş köyde yapılan pilot uygulamanın ardından doğrudan gelir desteğiyle birlikte Ulusal Çiftçi Kaydı kuruldu; Banka bu kaydı Türkiye'nin temel kırsal veri tabanı olarak niteliyor. Kayıt sistemi 14 Haziran 2002'de Resmî Gazete'de yayımlanan bir Bakanlar Kurulu kararıyla kurala bağlandı; 16 Nisan 2005'te çıkan Çiftçi Kayıt Sistemi Yönetmeliği, kurulan sistemin güncellenmesini düzenledi. Bakanlığın FAO ile hazırladığı, iklim verisiyle çalışan bir simülasyon yöntemine dayanan ilk kışlık buğday verim tahmini bülteni Ekim 2005-Ocak 2006 dönemini kapsadı; seri bugün uzaktan algılama destekli bir tarımsal izleme bülteni olarak sürüyor (§9).

Türkiye'nin ilk optik uzaktan algılama uydusu BİLSAT 2003'te teknoloji transferiyle fırlatıldı. TÜBİTAK UZAY'ın tasarlayıp ürettiği ilk yerli yer gözlem uydusu RASAT 17 Ağustos 2011'de fırlatıldı ve yaklaşık **11** yıl tarım dâhil pek çok alana veri sağladı; metre altı çözünürlüklü İMECE 15 Nisan 2023'te fırlatıldı (§19).

Bakanlığın sayfasına göre Tarımsal İzleme ve Bilgi Sistemi (TARBİL), 2008'de Devlet Planlama Teşkilatı'nın yönlendirmesiyle üç yıllık bir pilot olarak "Tarımsal Rekolte Tahmin ve Kuraklık İzleme" projesi (TARİT) adıyla başladı; ilk **25** istasyon Şanlıurfa'da kuruldu, 2012'de istasyon sayısı **100**'e ulaştı. FAO ile EBRD'nin 2025 raporuna göre ise proje tamamlanmadı; sahada yapılan görüşmeler kurulan istasyonların birçoğunun çalışmadığını gösterdi.

Tarımda yapay zekâya dönük kamu programları ise yakın tarihli: TÜBİTAK'ın yapay zekâ ekosistem çağrısının ilki 2022'de açıldı ve öncelikli alanlarından biri akıllı tarım, gıda ve hayvancılık; bakanlığın araştırma kolu TAGEM 2025'te üç yapay zekâ projesi başlattı (§23, §25).

## Bu sayfa nasıl güncelleniyor

Öbür başlıklara giren yeni gelişmelerden tarımda dijital teknolojinin dönüm noktası sayılanlar — işletime giren sistemler, kamu kurumlarının yeni kayıt ve izleme altyapıları, sahada ölçülen ilk sonuçlar — bu sayfaya da ekleniyor. Yeni bilgi, editör onayından sonra sayfaya ekleniyor.
