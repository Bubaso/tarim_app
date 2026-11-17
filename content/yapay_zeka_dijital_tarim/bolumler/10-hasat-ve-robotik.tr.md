# 10 · Hasat ve robotik

Hasatta en zor iş, olgun meyveyi seçip ezmeden koparmak; hasat robotları da bu yüzden uzun süre laboratuvardan çıkamadı. 2014'te yayımlanan bir derlemede incelenen **50** robotun ortalama hasat başarısı **%66**, bir meyveyi toplama süresi **33** saniyeydi. Ticari bir serada sınanan bir biber robotunda ise başarı, büyük ölçüde bitkinin ona göre yetiştirilip yetiştirilmediğine bağlı çıktı; 2022 tarihli bir derlemeye göre bahçelerde yaygın kullanım hâlâ yok. Türkiye'den yayımlanmış çalışmalar şimdilik görüntüde meyveyi tanıma aşamasında.

## Ne yapıyor

Hasat iki ayrı makine dünyası. Tahılda biçerdöver tarlanın tamamını tek geçişte hasat ediyor. Meyvede ve sebzede ise ürün aynı anda olgunlaşmıyor, hasat seçerek yapılıyor: elma, domates, brokoli gibi yüksek değerli ürünlerde bu iş bugün büyük ölçüde insan elinde ve tarımın en çok emek isteyen, en pahalı işlerinden biri. İşgücü sıkıntısı da robotlara ilginin nedenlerinden biri.

Seçici hasat robotu üç işi birden yapmak zorunda: meyveyi kameradan tanıyıp yerini bulmak, kolunu yaprakların ve dalların arasından ona ulaştırmak, meyveyi zarar vermeden koparmak. Yapay zekâ ilk işte, görüntüde meyveyi tanımakta. Zorluk ise robota yabancı bir ortamda: bitkiden bitkiye değişkenlik, eksik bilgi ve güvenlik.

## Saha ne diyor

Bac ve arkadaşları (2014), yüksek değerli ürünler için geliştirilmiş hasat robotlarını aynı ölçülerle karşılaştırdı:

| Ölçü (50 robotun ortalaması) | Değer |
|---|---|
| Meyvenin yerini bulma | **%85** |
| Koparma | **%75** |
| Hasat (işin tamamı) | **%66** |
| Meyve hasarı | **%5** |
| Sap hasarı | **%45** |
| Bir meyve için süre | **33** saniye |

En hızlısı bir kivi robotuydu: **1** saniye. Ama derlemenin asıl bulgusu başka: hasat robotlarının performansı son otuz yılda iyileşmemişti ve incelenen robotların hiçbiri ticarileşmemişti. Yazarların ilk önerisi de bu yüzden işi kolaylaştırmak.

Bu önerinin sahadaki karşılığını biber hasat robotu SWEEPER gösterdi (Arad ve arkadaşları, 2020). Robot ticari bir serada dört hafta boyunca **262** meyve üzerinde sınandı. Bir meyveyi toplama süresi ortalama **24** saniye, bunun yaklaşık yarısı lojistik; laboratuvarda kol daha hızlı çalıştırılarak süre **15** saniyeye indi. Hasat başarısı, bitki robota en uygun koşullarda yetiştirildiğinde **%61**, seranın olağan koşullarında **%18**. Yazarların vardığı sonuç: robotla hasatta başarı, ona uygun ürün koşullarını ve çeşitleri bulmaya bağlı.

[[grafik:b10-sweeper-kosullar]]

Zhou ve arkadaşlarının 2022 tarihli derlemesi, alandaki önemli ilerlemeye rağmen mevcut robotların performansının neden yetersiz kaldığını inceliyor.

## Yapay zekâ nerede duruyor

Yapay zekânın katkısı robotun gözünde: kamera görüntüsünde meyveyi bulmak ve olgunluğunu ayırt etmek. Ama derlemedeki sıralama darboğazın gözde değil elde olduğunu düşündürüyor: yer bulma (**%85**) koparmadan (**%75**), koparma da bütün hasattan (**%66**) daha başarılı. Biber robotunun olağan serada **%18**'e düşmesi aynı şeyi söylüyor: yaprak, dal ve meyve dizilişi robota göre düzenlenmedikçe daha iyi bir göz tek başına yetmiyor.

[[grafik:b10-hasat-robotu-basamaklari]]

## Türkiye

Türkiye'de hasadın makine tarafı klasik mekanizasyon. Bakanlığın verisine göre 2025'te **1.610.133** traktör ve **21.116** biçerdöver vardı; biçerdöverlerin **%49,3**'ü 10 yaşında ya da daha genç, traktörlerin **%71**'i 35-70 beygir gücünde.

2027 Programı, işletmelerin küçük ölçekli, parçalı ve dağınık arazi yapısının mekanizasyonun ve modern üretim tekniklerinin etkin kullanımını güçleştirdiğini yazıyor. Aralık 2025 tarihli kırsal kalkınma kararı ve Nisan 2026 tarihli tebliğ ise robotik ve otomasyon teknolojilerinin yaygınlaştırılmasını da hedefliyor; hibe, yatırımın niteliğine göre proje tutarının **%50-70**'i.

Araştırma tarafında Tekirdağ Namık Kemal Üniversitesi'nden Kahya, biri ekip arkadaşlarıyla yazdığı iki çalışmada (2024) patlıcan ve kabak hasadı için derin öğrenme tabanlı nesne tanıma modelleri eğitti. Ölçülen şey modelin doğrulama görüntülerinde meyveyi tanıma başarısı; robotun tarlada meyveyi koparıp koparamadığı değil. Bir hasat robotunun Türkiye'de tarlada ya da serada meyve topladığı ve başarısının ölçüldüğü bir deneme henüz yayımlanmadı. Hasat da yapabilecek otonom bir sera robotu ise TÜBİTAK desteğiyle 2026'da başlayan bir projede geliştiriliyor.
