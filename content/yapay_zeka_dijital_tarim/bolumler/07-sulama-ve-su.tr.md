# 7 · Sulama ve su yönetimi

Tarım, dünyada çekilen tatlı suyun **%72**'sini kullanıyor; Türkiye'de bu pay daha da yüksek. Sulamada dijital teknolojinin en sağlam kanıtı yapay zekâdan değil, toprak nem sensöründen geliyor; sensörün sağladığı su tasarrufu ise neyle karşılaştırıldığına göre çok değişiyor. Yapay zekâ sulama kararında bugün simülasyonda umut verici, tarlada henüz az sınanmış.

## Ne yapıyor

Sulamada dijital teknoloji üç katmanda çalışıyor. Toprakta, nem sensörleri kök bölgesindeki suyu ölçüyor ve sulamanın zamanını takvimden toprağın kendisine bağlıyor. Gökte, uydu verisi bitkinin ne kadar su tükettiğini tarla ölçeğinde hesaplıyor. İkisinin üstünde bir model ya da karar destek sistemi ne zaman ve ne kadar sulanacağını öneriyor; otomasyon bu kararı vanaya taşıyor.

Yapay zekâ en üst katmanda devreye giriyor. Alttaki iki katman — ölçmek — yapay zekâ olmadan da çalışıyor ve sahadaki kanıtın büyük kısmı da oradan geliyor.

## Saha ne diyor

Datta ve Taghvaeian (2023), hakemli bir sistematik derlemede ABD'de son yirmi yılda yayımlanmış toprak nem sensörü çalışmalarını taradı. Sonuç iki parçalı:

| Sensörle zamanlama neye karşı | Ortalama su tasarrufu |
|---|---|
| Bitki örtüsü sıcaklığına dayalı zamanlama | **%1** |
| Geleneksel yöntemler | **%38** |

Verim, karşılaştırılan yöntemlere göre aynı ya da daha yüksek. Ama derlemenin en önemli bulgusu başka: sensörün doğruluğunu en çok etkileyen şey kalibrasyon. Fabrika ayarıyla takılmış bir sensör toprağı yanlış okuduğu sürece yanlış zamanda sulatır.

İki rakam arasındaki farkın sahadaki karşılığı şu: takvime göre sulayan bir çiftçi için sensör büyük fark yaratıyor; bitkiyi zaten ölçerek sulayan biri için neredeyse hiç.

## Yapay zekâ nerede duruyor

Saikai, Peake ve Chenu (2023), sulanan buğday için derin pekiştirmeli öğrenmeyle bir sulama kuralı geliştirdi. Kural her gün toprak suyuna, bitkinin gelişme evresine ve yağışa bakıp ne kadar sulanacağına karar veriyor. Model 1981-2010 hava verisiyle eğitildi ve 2011-2020 yıllarının her biri için ayrı ayrı sınandı: bölgede yaygın kurala göre kârı bütün sınama yıllarında artırdı, en büyük artış 2018'de **%17**.

[[gorsel:b07-derin-pekistirmeli-ogrenmeyle-sulama]]

Bu sonuç bir saha denemesinden değil, bir bitki büyüme modelinden geliyor: üretim sistemi Avustralya'nın Goondiwindi bölgesinde APSIM-Wheat modeliyle simüle edildi. Yazarlar da bu tekniğe dair araştırmanın seyrek kaldığını ve pratikten uzak olduğunu kendileri belirtiyor.

## Türkiye

FAO verisine göre Türkiye'de 2022'de çekilen tatlı suyun **%86,93**'ü tarıma gitti; sanayinin payı **%2,01**, belediyelerin **%11,06**. Toplam çekim **64,47** milyar m³.

[[grafik:b07-su-cekimi-paylari]]

2027 Yıllık Programı'na göre sulama oranı 2025'te **%68**, 2026 tahmini **%71**, 2027 hedefi **%72**. Sulamaya açılmış brüt alan 2025'te **7,28**, 2027 hedefinde **7,40** milyon hektar. 2027 için yazılan tedbirler: **61** bin hektar yeni sulama alanı; **16** bin hektarda açık kanalların kapalı boruya çevrilmesi; **30** bin hektarda yağmurlama ve damla sulama için hibe; suyun kullanılan miktara göre fiyatlandırılması için **100** tesise elektronik ölçüm sistemi. Su kısıtı olan **11** ilin **52** ilçesinde az su tüketen ürünlere ek destek veriliyor.

Dijital tarafta iki tedbir var. Uzaktan algılama ve coğrafi bilgi sistemleriyle sulama programı hazırlayacak Dijital Sulama Yönetim Sistemi projesi (DİSU) 2027'de tamamlanacak; su kullanıcı teşkilatlarında karar destek sistemlerinin kullanımı ve bunun mevzuatı üzerinde çalışılacak. Tarımsal Kuraklık İzleme Sistemi (TAKİS) kuraklığı uydu verisiyle **7** günlük periyotlarla izliyor; 2027'de yapay zekâ yöntemleriyle kuraklığı **1-4 hafta** önceden tahmin etmeye yönelik çalışmaların başlatılması planlanıyor. Bakanlığın araştırma kolu TAGEM'in geliştirdiği Sulama Yönetimi ve Bitki Su Tüketimi Sistemi (TAGEM-SuET) ise Tarım Cebimde uygulamasının Su sekmesinde ve webde üreticiye sulama konusunda hizmet veriyor.

[[gorsel:b07-tagem-suet-uygulama-ekrani-referans]]

Sahadan iki çalışma var ve ikisi de sensörü sınıyor; yapay zekâyla verilen bir sulama kararını Türkiye'de tarlada ölçen bir deneme henüz yayımlanmadı. Niğde'deki Patates Araştırma Enstitüsü'nün de yer aldığı bir çalışma (Akın ve Ünlenen, 2017), siltli tınlı toprakta farklı nem sensörlerini hassas damla sulama programı için karşılaştırdı; ölçtüğü şey tasarruf değil, hangi sensörün güvenilir okuduğu. Ege Üniversitesi'nin Wageningen'le ortak projesinde ise düşük maliyetli, kablosuz bir sensör Orhanlı Köyü'nde **9** üreticiyle denendi. Proje broşürü sensörle yönetilen parsellerde **%13-24**, organik üretimde **%12** su tasarrufu bildiriyor. Broşürü yazanlar arasında sensörü geliştiren firma da var; rakamlar bir proje beyanı.

[[gorsel:b07-aquatag-kablosuz-toprak-nem-sensoru]]