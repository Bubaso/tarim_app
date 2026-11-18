# 16 · Pazar, fiyat ve tedarik zinciri

Tarım ürünlerinin fiyatını tahmin etmede derin öğrenme modelleri klasik yöntemlerin önüne geçebiliyor, ama hatasız değil: Hindistan'da klasik modeli açık farkla geride bırakan bir derin öğrenme modelinin ortalama yüzde hatası bile domateste **%10,58**, soğanda **%14,59**. İzlenebilirlikte blokzincir akademide çok konuşuluyor. Türkiye'de ise sebze ve meyvede dijital izlenebilirlik zaten bir yönetmelik yükümlülüğü; ama bunu sağlayan Hal Kayıt Sistemi ne yapay zekâ ne de blokzincir: merkezi bir kayıt.

## Ne yapıyor

Pazarda ve tedarik zincirinde dijital teknoloji üç işe yarıyor: fiyatı tahmin etmek, talebi ve stoku planlamak, ürünün tarladan rafa yolunu izlemek. İlk ikisinde yapay zekâ geçmiş fiyat ve satış serilerinden, hava ve stok gibi dış etkenlerden örüntü çıkarıyor; üretici ne ekeceğine, tüccar ne zaman satacağına, kamu ne zaman müdahale edeceğine karar verirken bir tahmin sunuyor. Üçüncüsünde asıl iş kayıt: malın nerede üretildiğinin, kimden kime geçtiğinin yazılması. Blokzincir bu kaydı değiştirilemez kılmak için öneriliyor.

## Saha ne diyor

Buğday, mısır ve pirinç fiyatlarının makine öğrenmesi, derin öğrenme ve zaman serisi yöntemleriyle tahminini inceleyen bir sistematik tarama (Theofilou ve arkadaşları, 2025), hibrit derin öğrenme modellerinin geleneksel yöntemleri tutarlı biçimde geçtiğini yazıyor; ama modellerin yorumlanabilirliğini ve bölgeye özgü veri setlerine dayanmasını önemli sınırlar olarak gösteriyor.

Hindistan'da **23** ürünün Ocak 2010–Haziran 2024 arasındaki günlük toptan fiyatlarıyla yapılan bir karşılaştırmada (Manogna ve arkadaşları, 2025) derin öğrenme modellerinden GRU, klasik ARIMA modelinden belirgin biçimde iyi sonuç verdi: hata ölçüsü (RMSE) soğanda **370**'e karşı **1.565**, domateste **210**'a karşı **1.299**. Yazarlar güvenilirliği artırmak için hava verisi gibi dış etkenlerin modele katılmasını öneriyor.

[[grafik:b16-gru-arima-hata]]

Üstünlük her yerde görülmüyor. İtalyan bir gıda toptancısının satış fiyatlarında (Menculini ve arkadaşları, 2021) klasik ARIMA ile LSTM ağları benzer sonuç verdi; en iyi doğruluğu iki derin öğrenme yöntemini birleştiren model sağladı, ama ayarlanması daha uzun sürdü.

İzlenebilirlik tarafında, tarımda blokzinciri inceleyen bir tarama (Sendros ve arkadaşları, 2022) Nisan 2021'de **104** araştırma makalesini ele aldı: alan hâlâ erken aşamada ve çalışmaların çoğu tasarım aşamasında, önemli bir kısmı ise uygulama ya da pilot aşamasına geçmiş. Kullanım çoğunlukla üretim kayıtlarının bütünlüğü, üretim adımlarının ve ürünlerin izlenmesi üzerine. Avrupa'daki ve dünyadaki pilot uygulamaları karşılaştıran yeni bir çalışma (Karkanias ve arkadaşları, 2026), blokzincirin ürün düzeyinde izlenebilirliği ve sürdürülebilirlik ve gıda güvenliği beyanlarının doğrulanmasını güçlendirebileceğini gösteriyor; ama dağınık teknik standartların, sınırlı birlikte çalışabilirliğin, küçük üretici için yüksek kurulum maliyetinin ve konsorsiyumların yönettiği platformlardaki yönetişim riskinin sürdüğünü de.

## Yapay zekâ nerede duruyor

Fiyat tahmininde yapay zekâ ölçülebilir bir iyileşme getiriyor, ama kazancın büyüklüğü ürüne, pazara ve veriye bağlı: Hindistan'daki büyük fark İtalyan toptancıda görülmüyor. İyi sonuç veren modeller de yanıldığı için tahmin, karar verene kesinlik değil bir yön veriyor. İzlenebilirlikte ise engel teknolojinin kendisi değil: standart, birlikte çalışabilirlik ve küçük üreticiye düşen maliyet.

## Türkiye

Sebze ve Meyve Ticareti ve Toptancı Halleri Hakkında Yönetmelik'e (2012; son değişiklik 2023) göre Hal Kayıt Sistemi (HKS), ticaretten sorumlu bakanlığın bünyesinde kurulan, internet tabanlı merkezi bir kayıt sistemi. Bildirim eşiğindeki ya da üzerindeki mal (kilogramla satışta **100** kilogram, adetle **150** adet, bağla **50** bağ) üretildiği yerden ya da girdiği gümrük kapısından sevk edilmeden önce sisteme bildiriliyor. Her bildirim için sistem malın üretim yerini, cinsini, miktarını, hangi üreticiye ait olduğunu ve varsa sertifika bilgisini içeren, özgün numaralı bir künye üretiyor; toptan ve perakende satışta künyenin malın üstünde herkesin görebileceği bir yerde bulunması zorunlu.

[[gorsel:b16-hal-kayit-sistemi-nin-karekodlu-urun]]

[[gorsel:b16-toptanci-hali]]

Bu kaydın verisi araştırmada da kullanılıyor. Türkiye'den hakemli bir makine öğrenmesi denemesi (Özden, 2023), patates, soğan ve sarımsağın 2018 başından Kasım 2022'ye kadarki **1.791** günlük işlem hacmini ve fiyatını Ticaret Bakanlığı'nın resmî hal sitesinden elle derleyerek **10** günlük fiyat tahmini denedi. Ama yapay zekânın Türkiye'de fiyat tahminine, talep planlamasına ya da izlenebilirliğe gerçekte ne kattığını gösteren yayımlanmış bir değerlendirme yok.

2027 Programı, tarım ürünü fiyatlarının sağlıklı oluşması ve gıda arz zincirinin etkinliği için kayıt sistemlerinin güçlendirilmesini, lisanslı depoculuğun yaygınlaştırılmasını ve yaş meyve-sebze tedarik zincirinde lojistik altyapının geliştirilmesini öngörüyor; kayıt ve bilgi sistemleri erken uyarı, piyasa kontrolü, üretim planlaması ve stok yönetimine hizmet edecek biçimde tasarlanacak. 2025'te **265** olan lisanslı depo sayısının 2026'da **288** olması bekleniyor; 2027 hedefi **295**. Lisanslı depoculuk desteklerinin etki analizi ise yapılacak işler arasında. Program tarım ürünü fiyat tahminine yer vermiyor; blokzinciri yalnız gümrük ve dış ticaret işlemleri için öngörüyor.

Bakanlığa bağlı Tarımsal Ekonomi ve Politika Geliştirme Enstitüsü'nün (TEPGE) ürün raporları içinde bulunulan yılın gelişmelerini "Tahmin", bir sonraki yılınkileri "Öngörü" başlığı altında inceliyor. Buğday için 2025 raporu tahminlerini hangi yöntemle yaptığını açıklamıyor. Raporun Türkiye'ye dair öngörü bölümü ABD Tarım Bakanlığı'nın (USDA) tahminleriyle açılıyor.
