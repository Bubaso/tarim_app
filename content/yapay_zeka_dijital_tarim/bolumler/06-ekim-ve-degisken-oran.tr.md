# 6 · Ekim ve değişken oranlı uygulama

Değişken oranlı uygulama; tohumu, gübreyi ya da ilacı tarlanın her yerine aynı dozda değil, her parçanın ihtiyacına göre vermek demek. Sahadaki kanıt tutarlı bir tasarruf gösteriyor ama tutarlı bir kâr göstermiyor; teknoloji de çiftliklerin ancak küçük bir kısmına yayılabildi. Yapay zekâ doz reçetesini yazmaya aday, ama verimi iyi tahmin etmek doğru dozu bulmakla aynı şey değil. Türkiye'de ise bir çalışma, Bakanlığın fosfor tavsiye yönteminin aynı arazinin beş parçasına birebir aynı dozu verdiğini buldu.

## Ne yapıyor

Klasik uygulamada makine tarlanın başından sonuna aynı ayarla gider: aynı tohum sıklığı, aynı gübre dozu. Oysa tarlanın bir yeri verimli, öbür yeri taşlı ya da kurak olabilir. Değişken oranlı teknoloji bu farkı makineye taşıyor: tohumun, gübrenin ve ilacın miktarı makine tarlada ilerlerken değişiyor.

Doz iki yoldan belirleniyor. Birincisinde önceden bir reçete haritası hazırlanıyor: toprak haritaları, önceki yılların verimi ve uydu görüntüleri tarlayı bölgelere ayırıyor. İkincisinde makinenin üstündeki sensör bitki örtüsünün yansımasını ölçüp azot dozunu o an ayarlıyor.

[[gorsel:b06-degisken-oranli-ekim-recete-haritasi]]

Yapay zekânın bu zincirdeki yeri karar halkası: hangi noktaya ne kadar azot ya da tohum verileceğini, tarlada farklı dozların denendiği çiftlik denemelerinin verisinden öğrenerek hesaplamak.

[[gorsel:b06-soya-ekim-sikligi-ciftlik]]

## Saha ne diyor

| Çalışma | Karşılaştırma | Sonuç |
|---|---|---|
| Aula ve arkadaşları (2020): **26** hakemli çalışmanın derlemesi, kışlık buğday | Sensörle azot yönetimi, geleneksel yönteme karşı | Azot kullanım etkinliği yaklaşık **%10,4** yüksek; verim benzer; hektarda **53** kg'a kadar azot tasarrufu |
| Kortbein ve arkadaşları (2026): Nebraska, **9** sulanmayan mısır tarlası, 2019-2020 | Sensörle azot, çiftçinin kendi uygulamasına karşı | Azot hektarda ortalama **38,7** kg az; tarlaların **%77**'sinde verim kaybı yok; kâr avantajı **%35**'inde |
| Dalla Betta ve arkadaşları (2026): Nebraska, **11** soya tarlasında tohum denemesi | En kârlı tohum sıklığı | Tarladan tarlaya hektarda **175.000** ile **350.000** tane arasında; **11** tarlanın **9**'unda tohum, verim ve kâr düşmeden azaltılabilirdi |

Tasarruf gerçek: sensörlü azot verimi düşürmeden gübreyi azaltıyor, soya denemeleri de tohumda benzer bir pay gösteriyor. Kâr tarafında ise sonuç değişiyor: Nebraska'da sensörlü uygulama tarlaların yalnız **%35**'inde daha kârlı çıktı. Derlemenin yazarları bu kazancın tek başına benimsemeyi artırmaya yetmeyebileceğini söylüyor; mısır denemesinin yazarları da sensörlerin yayılmasını tutarsız sonuçların, olası verim kayıplarının ve tarla ölçeğinde deneme eksikliğinin sınırladığını not ediyor.

[[gorsel:b06-bitki-ortusu-sensoruyle-azot]]

[[grafik:b06-sensorlu-azot-tarlalar]]

## Ne kadar yaygın

ABD Tarım Bakanlığı Ekonomik Araştırma Servisi'nin çiftlik anketine göre değişken oranlı teknoloji 1990'ların sonu ve 2000'lerin başında birçok tarla ürününde ekili alanın **%10**'unun altında kaldı. Sonra hızlandı: mısırda ekili alanın payı 2005'te **%11,5**'ten 2016'da **%37,4**'e, pamukta 2007'de **%5,4**'ten 2019'da **%22,7**'ye çıktı. Kışlık buğdayda 2017'de **%18,8**, soyada 2018'de **%25,3**. Büyük çiftlikler daha çok benimsiyor; Servis'e göre bunun bir nedeni, sabit maliyeti daha çok üretime yayabilmeleri.

[[grafik:b06-vrt-ekili-alan]]

Lowenberg-DeBoer ve Erickson (2019) dünyadaki kamuya açık verileri tarayıp ayrımı netleştiriyor: uydu güdümlü dümenleme ve ona bağlı otomasyonlar (ilaçlama bumu denetimi, ekim makinesinde sıra ya da bölüm kapatma gibi) tarihteki her büyük tarım teknolojisi kadar hızlı yayıldı. Değişken oranlı teknoloji ise 2019 itibarıyla nadiren çiftliklerin **%20**'sini aşıyordu. Yazarlara göre bu, çiftçinin fikri sevdiğini ama değerine ikna olmadığını gösteriyor. Hassas tarımın en büyük boşluğu da gelişmekte olan ülkelerde motorlu mekanizasyon kullanmayan küçük ve orta ölçekli çiftlikler.

## Yapay zekâ nerede duruyor

Değişken oranlı uygulamanın zor kısmı makine değil, reçete: tarlanın hangi noktasına ne kadar? De Lara ve arkadaşları (2023), buğday ve arpada **20** çiftlik denemesinin verisini toprak, arazi ve uydu değişkenleriyle iki makine öğrenmesi yöntemine (genelleştirilmiş toplamsal model ve rastgele orman) verdi. Modeller verimi ortalama **%13,7** hatayla tahmin etti. Ama benzer doğrulukla tahmin eden iki model, ekonomik en uygun azot dozu için birbirinden çok farklı sonuçlar çıkardı. Etkili değişkenlerin büyüklüğü ve yönü tarladan tarlaya değişti; yazarlar, başka tarlaların verisiyle eğitilen bir modelin yeni bir tarlada güvenilmez doz önerebileceği uyarısında bulunuyor.

## Türkiye

2027 Programı, hassas tarım ve dijital teknolojilerle gübre, tohum ve diğer girdilerin etkin kullanılmasını bitkisel üretimin öncelikli konuları arasında sayıyor. Program 2026'da küresel gübre arzının aksadığını ve özellikle üre fiyatlarının arttığını da kaydediyor. Engeli de yazıyor: işletmelerin küçük ölçekli, parçalı ve dağınık arazi yapısı, mekanizasyonun ve modern üretim tekniklerinin etkin kullanımını güçleştiriyor.

2027 için iki somut tedbir yazılı: **14** tarımsal üretici örgütünde ortak makine parkı kurulmasına destek verilecek; akıllı tarım yazılım ve ekipmanının yerli üretimi desteklenecek. Aralık 2025 tarihli kırsal kalkınma kararı ve Nisan 2026 tarihli tebliğ de dijitalleşme, yapay zekâ, akıllı tarım, robotik ve otomasyon teknolojilerinin yaygınlaştırılmasını hedefliyor; hibe, yatırımın niteliğine göre proje tutarının **%50-70**'i.

Türkiye'de benimsemeye dair yayımlanmış veri ise eski. Çukurova'da **164** tarım mühendisi, bayi ve çiftçiyle yapılan ve 2016'da yayımlanan ankette katılımcıların **%51,8**'i hassas tarım terimini hiç duymamıştı; terimi duyanların yalnız **%29,3**'ü kavramı biliyordu. Uydu konumlamayı katılımcıların **%81,7**'si tanıyordu; değişken oranlı uygulama ise en az bilinen teknolojiydi (**%33,5**). Buna karşılık katılımcıların **%97,6**'sı bu teknolojilerin Türkiye tarımına bir ölçüde yararlı olacağını düşünüyordu, **%88,4**'ü daha ayrıntılı eğitim istiyordu (Keskin ve Sekerli, 2016).

[[grafik:b06-cukurova-farkindalik]]

Sahadan bir ölçüm de var. Çankırı merkezine **20** km uzaklıkta, **70** yılı aşkın süredir kuru tarımla buğday ekilen **300** hektarlık eğimli bir arazide **155** toprak örneği alındı (Wardamı, Erşahin ve Karahan, 2024). Bitkinin alabileceği fosfor arazinin içinde orta düzeyde değişiyordu (değişkenlik katsayısı **%21,3**) ve arazi düşük, orta ve yüksek olmak üzere üç gübreleme bölgesine ayrılabildi. Bakanlığın gübre tavsiye yöntemiyle aynı büyüklükteki beş alt bölge için hesaplanan fosfor dozları ise birebir aynı çıktı: yazarlara göre yöntem, bu topraklardaki fosfor farkına duyarsız. Değişken fosfor uygulamasının etkinliğini ve maliyet-faydasını ölçmek için daha kapsamlı bir çalışma gerektiğini yazarlar kendileri belirtiyor. Değişken oranlı gübre ya da tohum uygulamasının verime ve kâra etkisini Türkiye'de tarlada ölçen, yayımlanmış bir deneme de henüz yok.

[[gorsel:b06-cankiri-da-300-hektarlik-bugday]]

Makine tarafında da bir çalışma var: Tekirdağ Namık Kemal Üniversitesi'nden bir ekip, zeytin bahçeleri için çoklu gübre dağıtma makinesi ve değişken oranlı denetleyici geliştirdi (Akdemir ve arkadaşları, 2022).
