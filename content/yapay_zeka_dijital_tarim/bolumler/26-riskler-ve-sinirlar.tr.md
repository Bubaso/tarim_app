# 26 · Riskler ve sınırlar

Tarımda yapay zekânın risklerinin bir kısmı ölçülmüş durumda. Tanzanya'da bir tarlada denenen manyok hastalığı modelinin F-1 skoru, erken ve hafif belirtilerde **%67** azaldı. Sorun yalnız modelin tarladaki başarısı değil: FAO'nun incelediği dijital otomasyon hizmet sağlayıcılarının çoğu kârlı ve finansal olarak sürdürülebilir değildi, kârlı olanlar da çoğunlukla büyük üreticilere hizmet veriyordu. Veri merkezlerinin elektrik tüketimi artıyor; ABD'de tarım kooperatifleri hasat döneminde fidye yazılımı saldırılarına uğradı. Türkiye'de bu riskler küçük işletmelerle ve yaşlanan bir tarım nüfusuyla karşılaşıyor.

## Model laboratuvardan çıkınca

Görüntüden hastalık tanıyan modellerin en çok anılan sınırı, eğitildikleri koşulların dışında başarılarının düşmesi. Mohanty ve arkadaşları (2016), kontrollü koşullarda çekilmiş **54.306** yaprak görüntüsüyle **14** ürün türünde **26** hastalığı tanıyan bir derin öğrenme modeli eğitti. Model aynı setten ayrılmış test görüntülerinde **%99,35** doğruluğa ulaştı. Ama tarım yayım servisleri gibi güvenilir çevrimiçi kaynaklardan toplanan, başka koşullarda çekilmiş iki küçük sette (**121** ve **119** görüntü) doğruluk **%31,40** ve **%31,69**'da kaldı; **38** sınıf arasında rastgele tahminin ortalama başarısı **%2,63**. Yazarlar bunu çalışmanın ilk sınırlılığı olarak yazıyor; ikincisi, modelin yalnız düz bir arka plan önünde, yüzü yukarı dönük tek yaprakları sınıflandırabilmesi. Yazarlara göre laboratuvar testleri yalnız görünür belirtiye dayanan teşhisten her zaman daha güvenilir; hastalığı erken evrede yalnız gözle teşhis etmek de çoğu zaman zor.

Ramcharan ve arkadaşları (2019), manyok hastalıklarını tanıyan bir modeli telefon uygulamasına koyup Tanzanya'da bir tarlada **720** hastalıklı yaprakçıkla denedi. Belirgin belirtilerde F-1 skoru test setindeki **0,79**'dan tarla fotoğraflarında **0,54**'e (**%32** düşüş), videoda **0,48**'e (**%39** düşüş) indi. Erken, hafif belirtilerde F-1 skoru fotoğrafta **0,26**'da, videoda **0,25**'te kaldı. Yani model, teşhisin en çok işe yarayacağı erken evrede en düşük başarıyı gösterdi. Yazarlara göre telefonda çalışan bir model ışık ve açı gibi yeni güçlüklerle karşılaşıyor ve bu tür modellerin gerçek koşullarda sınanması şart.

[[gorsel:b26-tanzanya-tarla-deneyinden-manyok]]

[[grafik:b26-manyok-f1-tarlada]]

## Kimin işine yarıyor

FAO'nun 2022 Gıda ve Tarımın Durumu raporuna göre dijital otomasyon teknolojilerinin kullanımı artıyor, ama çoğunlukla yüksek gelirli ülkelerde. Veri az olduğu için FAO, dijital otomasyon hizmeti sağlayan şirketlerle görüşmelere dayanan **27** vaka çalışması yaptı: bunlardan yalnız **10**'u kârlı ve finansal olarak sürdürülebilirdi. Bu şirketler çoğunlukla yüksek gelirli ülkelerde bulunuyor, yaygın biçimde benimsenmiş olgun çözümler kullanıyor ve çoğunlukla büyük üreticilere hizmet veriyor.

[[grafik:b26-fao-27-vaka]]

FAO benimsemenin önündeki en büyük engelleri kırsalda düşük dijital okuryazarlık, küçük üreticiye uygun teknolojilerin bulunmaması ve bu teknolojilerin görece yüksek maliyeti olarak sayıyor; bunlara çoğu zaman yaşlanan çiftçi nüfusuyla ilişkilendirilen bir değişim isteksizliği ekleniyor. Rapor otomasyonun toplumsal eşitsizlikleri derinleştirme riski taşıdığını da yazıyor: daha büyük ve daha eğitimli üreticilerin yeni teknolojiye yatırım yapacak, yeniden eğitim alıp yeni beceri öğrenecek kapasitesi daha fazla. Büyük ve küçük çiftlik arasındaki farkı ABD'nin ve AB'nin benimseme verileri de gösteriyor.

## Emek

FAO'ya göre kırsalda işgücünün bol, ücretlerin düşük olduğu yerlerde tarımsal otomasyon işsizliğe yol açabilir; bu özellikle sübvansiyonlar otomasyonu yapay olarak ucuzlattığında ya da ani teknolojik atılımlar maliyeti hızla düşürdüğünde olabilir. Ama rapor, otomasyonun işsizliği artıracağına dair yaygın korkuların anlaşılır olsa da tarihsel gerçeklerce genellikle desteklenmediğini yazıyor. Beklenen değişim işin niteliğinde: ekim ve hasat gibi rutin işlerin azalması, örneğin ortaöğretim gerektiren nitelikli işlerin artması bekleniyor.

Kanada'ya odaklanan Rotz ve arkadaşları (2019), literatür ve alan verisiyle tarımsal üretim, teknoloji ve emek arasında üç gerilim saptıyor:

- Yükselen arazi maliyetleri ve otomasyon
- Yüksek ve düşük becerili diye ikiye bölünen bir emek piyasası
- Dijital verinin kimin denetiminde olduğu

Yazarlar, dijital tarıma duyulan güncel heyecanın, yeni teknolojilerin sömürüyü yoğunlaştırdığı ve hem emeği hem mekânı daha da kenara ittiği somut yolları gözden kaçırtmaması gerektiğini vurguluyor; tarım emeğindeki ırksal sömürüye özellikle dikkat çekiyor.

## Sistemik riskler ve güvenlik

Tzachor ve arkadaşları (2022) tarımda yapay zekânın risklerini üç başlıkta topluyor:

- Tarım verisinin birlikte çalışabilirliği, güvenilirliği ve temsil gücü
- Yalnız verime göre eniyilenmiş makine öğrenmesi modellerinin istenmeyen toplumsal ve ekolojik sonuçları
- Bu sistemlerin geniş ölçekte kurulmasının emniyet ve güvenlik kaygıları

Yazarlara göre makine öğrenmesi modellerinin, uzman sistemlerin ve otonom makinelerin çiftliklere, çiftçilere ve gıda güvenliğine etkileri yeterince anlaşılmış değil. Önerdikleri önlemler arasında teknoloji tasarımına kırsal antropologların ve uygulamalı ekologların katılması, veri şeffaflığı ve sahiplik hakları için veri kooperatifleri kurulması ve tarımsal yapay zekânın önce dijital deneme ortamlarında kullanılması var.

Güvenlik riskinin somut örnekleri de var. ABD Federal Soruşturma Bürosu'nun (FBI) Nisan 2022 uyarısına göre fidye yazılımcılar tarım kooperatiflerine ekim ve hasat gibi kritik dönemlerde saldırmaya daha yatkın olabilir; kooperatifler, üretimdeki zamana bağlı rolleri nedeniyle ödemeye istekli hedefler olarak görülebiliyor. 15 Eylül-6 Ekim 2021 arasında altı tahıl kooperatifi fidye yazılımı saldırısına uğradı; bazıları üretimi tamamen durdurmak zorunda kaldı, bazıları idari işlevlerini kaybetti. 2022 başındaki iki saldırı tohum ve gübre arzını aksatarak ekim dönemini etkileyebilirdi. Temmuz 2021'de bir işletme yönetimi yazılımı şirketine yapılan saldırıda saldırgan **30** milyon dolar fidye istedi; saldırı, şirketin müşterileri arasındaki birkaç tarım kooperatifine de sıçradı. FBI'ın saydığı ilk giriş yolları arasında bilinen ama yaması yapılmamış güvenlik açıkları ve ortak ağ kaynakları ya da dışarıdan yönetilen hizmetler üzerinden bulaşma var.

## Enerji

Uluslararası Enerji Ajansı'na (IEA) göre veri merkezleri 2024'te dünya elektrik tüketiminin yaklaşık **%1,5**'ini, **415** teravatsaati kullandı. Tüketimin 2030'a kadar iki katından fazlasına, yaklaşık **945** teravatsaate çıkması bekleniyor; bu, Japonya'nın bugünkü toplam elektrik tüketiminden biraz fazla. Bu artışın en önemli sürücüsü yapay zekâ. Yine de veri merkezleri, 2030'a kadarki küresel elektrik talebi artışının yaklaşık onda birini oluşturuyor; sanayi motorlarının, ev ve ofis klimalarının ya da elektrikli araçların payından az. Gelişmekte olan ekonomilerde veri merkezlerinin 2030'a kadarki talep artışındaki payı yaklaşık **%5**. IEA'nın rakamları bütün veri merkezlerini kapsıyor; tarımın payını ayırmıyor.

## Türkiye'de riskin zemini

Tarım ve Orman Bakanlığı'nın Ulusal Kırsal Kalkınma Stratejisi'ne (2024-2028) göre Çiftçi Kayıt Sistemi'ndeki ortalama işletme büyüklüğü 2023'te **6,9** hektar; 2020'den beri **6,9** ile **7,1** hektar arasında. Aynı yıl ÇKS'de **2.245.215** işletme ve **306.033** genç çiftçi kayıtlıydı. Strateji, Türk tarımında dünya pazarlarına üreten orta ve büyük işletmelerle yerel pazara ve hane tüketimine üreten geleneksel küçük aile işletmelerinin bir arada olduğunu yazıyor. Zayıf yönler arasında tarımsal nüfusun yaşlanması ve gençlerin tarıma ilgisinin azalması, işletme ölçeğinin düşüklüğü ve akıllı tarım uygulamalarına erişim olanaklarının kısıtlı olması sayılıyor. Stratejinin tedbirleri arasında yapay zekâ ve akıllı teknoloji uygulamalarının kullanımının artırılması ve dijital okuryazarlığa yönelik eğitimler var.

IV. Tarım Orman Şûrası'nın kırsal kalkınma çalışma belgesi, TÜİK'in 2023 işgücü verisine dayanarak tarımda çalışanların yaş ortalamasını **46**, bütün istihdamda yaklaşık **39** olarak veriyor; tarımda çalışanların **%68,4**'ü **40** yaşın üzerinde, genel istihdamda bu oran **%47,1**. Tarım istihdamı 2014'te **5** milyon **220** binken 2023'te **4** milyon **695** bine indi.

[[grafik:b26-tarim-yaslanma]]

2027 Yıllık Programı'na göre işletmelerin küçük ölçekli, parçalı ve dağınık arazi yapısı üretim maliyetlerini artırıyor, tarımsal mekanizasyonun ve modern üretim tekniklerinin etkin kullanımını güçleştiriyor. Köylerde **65** yaş ve üzeri nüfus **1.159.477** kişi. Tarımın toplam istihdamdaki payı 2025'te **%14**, 2026'nın ilk yarısında **%13,4**. Program tarım işletmelerinin ve üretici örgütlerinin akıllı tarım konusundaki beşeri ve teknik altyapısının geliştirilmesini desteklemeyi öngörüyor; 2025 Genel Tarım Sayımı'nın sonuçlarının 2026 sonunda paylaşılması bekleniyor.

Türkiye'de çiftçilerin dijital araçları ve yapay zekâyı ne ölçüde kullandığını düzenli olarak ölçen resmî bir istatistik yayımlanmıyor. Bir ölçüm bakanlığın 2020 anketinden geliyor: FAO ile EBRD'nin 2025 raporu, bu ankete dayanarak çiftçilerin **%3**'ünden azının uzaktan algılama, sensör, çiftlik ya da sürü yönetimi yazılımı, hassas tarım ya da robotik gibi akıllı tarım teknolojilerini kullandığını aktarıyor.
