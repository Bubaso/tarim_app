# 19 · Uydu ve uzaktan algılama

Tarımda yapay zekânın en geniş veri kaynağı olan uydu görüntüsünün herkese açık olması bir politika tercihi ve bu tercihin etkisi büyük: ABD 2008'de Landsat görüntülerini ücretsiz yapınca, NASA'nın aktardığına göre veri kullanımı **20** kat arttı. Türkiye'nin kendi yer gözlem uydusu İMECE tarımı kullanım alanları arasında sayıyor; ama görüntülerinin tarım kurumlarına ya da çiftçiye ulaştığı resmî bir kanal ya da somut bir tarım projesi açıklanmış değil.

## Ne yapıyor

Uydu, tarlayı birkaç günde bir, aynı yöntemle ve geniş alanda gören bir ölçüm aracı. Bitki örtüsünün yansıttığı ışık bitkinin gelişimini, su durumunu, hastalığını ele veriyor; radar uydular bulutun ardını da görebiliyor. Yapay zekâ bu görüntülerden ekili ürünü, verimi, kuraklığı, yanmış ya da işlenmemiş alanı çıkarıyor. Ürün izleme ve verim tahmini, su ürünlerinde gemi izleme, ormancılık ve sigorta bu katmanın üstünde duruyor.

[[gorsel:b19-uydunun-bitki-ortusunu-olcme-ilkesi]]

## Saha ne diyor

Landsat görüntülerini ücretsiz dağıtma kararını ABD Jeoloji Araştırmaları Kurumu (USGS) verdi. Landsat Bilim Ekibi'nden Zhu ve arkadaşlarının 2019 makalesini özetleyen NASA sayfasına göre karardan sonra Landsat'a dayanan bilimsel yayınlar da dört kat arttı; yazarlar açık veri politikasının kaybının araştırma topluluğunu ciddi biçimde etkileyeceğini söylüyor. USGS'nin kendi değerlemesine göre Landsat görüntülerinin ABD'deki ve ABD dışındaki kullanıcılara faydası 2017'de tahminen **3,45** milyar dolardı (2011'de **2,19** milyar); bu değerin büyük kısmı ücretsiz ve açık veri politikasından geliyor. Küçük bir ücret bile kullanıcı kaybına, büyük olasılıkla da indirilen görüntü miktarında keskin bir düşüşe yol açar; kullanıcıların **%50**'den fazlasının ödemeyi reddetmesi bekleniyor.

[[gorsel:b19-landsat-verisinin]]

[[grafik:b19-landsat-acik-veri]]

Avrupa'nın Copernicus programındaki Sentinel-2, aynı yörüngede uçan ikiz uydularla ekvatorda **5** günde bir geçiyor. Uydulardaki çok bantlı optik algılayıcı **13** bantta ölçüm yapıyor, en ince çözünürlüğü **10** metre; şerit genişliği **290** kilometre. Copernicus'a göre uydular tarım, ormancılık ve afet yönetimi gibi alanlarda kullanılıyor; Sentinel-2C 5 Eylül 2024'te fırlatıldı. Algılayıcı pasif: Dünya'dan yansıyan güneş ışığını topluyor, yani bulutun altını göremiyor. Copernicus, sık bulutla örtülen Avrupa'da ve Afrika ile Güney Amerika'nın tropik bölgelerinde geçiş sıklığını artıran ek bir kampanya da yürütüyor.

[[gorsel:b19-sentinel-2c-nin-vega-roketiyle]]

Bulut, optik uydunun tarımdaki asıl sınırı. Whitcraft ve arkadaşları (2015) **10-13** yıllık MODIS bulut verisiyle, ürün deseninin belirlenmesi ve verim tahmini için önemli olan sezon başı ve ortasının hem sık hem yaygın bulutla örtüldüğünü gösterdi. Birçok önemli tarım bölgesinde **8** günlük bileşik görüntülerin yarısından azı **%70** açık çıkabiliyor; yazarlara göre bu bölgelerde optik uydu, sürekli izleme için muhtemelen uygulanabilir bir seçenek değil ve radar gibi alternatiflere bakılmalı. Sabah çekimlerinin açık görüntü verme olasılığı daha yüksek.

[[gorsel:b19-dunyanin-ortalama-bulutlulugu]]

## Yapay zekâ nerede duruyor

Uydu verisiyle yapay zekâ gezegen ölçeğinde çalışabiliyor: tarımdaki en güçlü sonuçlarının birkaçı, örneğin küresel ağaç boyu haritası ve kamuya açık izlemede görünmeyen balıkçı gemilerinin tespiti, uydu görüntüsünden çıkarıldı. Açık veri politikası değişirse kullanıcı kaybı büyük olabilir. Fiziksel sınır ise bulut: optik görüntü en çok gereken haftalarda eksik kalabiliyor.

## Türkiye

İMECE, TÜBİTAK UZAY'ın tasarlayıp ürettiği ilk yerli metre altı çözünürlüklü uydu; 15 Nisan 2023'te fırlatıldı. Kurumun 2026 kataloğuna göre çözünürlüğü pankromatikte **0,99**, çok bantlı görüntüde **3,96** metre, yörüngesi **686** kilometre; görüntüleri savunma, afet yönetimi, çevre ve şehircilik, tarım ve ormancılık gibi alanlarda kullanılıyor. Proje 2017'de başladı ve Millî Savunma Bakanlığı ile Savunma Sanayii Başkanlığı'nın koordinasyonunda yürütüldü; TÜBİTAK'ın fırlatma öncesi duyurusuna göre uydu yörünge testlerinden sonra Hava Kuvvetleri Komutanlığı envanterine girecekti, tasarım görev ömrü **5** yıl. 2027 Programı'nda İMECE-2'nin entegrasyon, çevresel test ve fırlatma hazırlıklarının tamamlanması, İMECE-3'ün sistem entegrasyonu var; program bu çalışmaları tarımla ilişkilendirmiyor. Bakan ise Mayıs 2025'te bir tarımsal gözlem uydu ağını hayata geçireceklerini söylemişti.

[[gorsel:b19-imece-yer-gozlem-uydusu]]

Bakanlığın 2025 faaliyet raporu, işlenmeyen tarım arazilerinin ve dikili alanların tespiti için uydu görüntülerinin derin öğrenme ve yapay zekâyla analiz edildiğini yazıyor; raporun önsözü uydu temelli uzaktan algılama verisinin yapay zekâyla bütünleştirildiğini, ürün deseninin, işlenmeyen arazinin ve dikili alanın hassas biçimde tespit edildiğini söylüyor. Bakanlık bu tespitlerin doğruluğunu ya da kapsadığı alanı açıklamadı. Uydu verisiyle çalışan bir yapay zekâ uygulamasının Türkiye'de üretime, girdi kullanımına ya da çiftçi gelirine etkisini ortaya koyan yayımlanmış bir değerlendirme de yok. Dünya Bankası'nın finanse ettiği Türkiye İklim Akıllı ve Rekabetçi Tarımsal Büyüme Projesi kapsamında bir uzaktan algılama sistemi ve karar destek sistemi için ihale dokümanları hazırlandı; ihalenin 2026'da tamamlanması planlanıyor.

İşlenmeyen arazi aynı zamanda bir politika konusu: üst üste iki yıl işlenmeyen arazilerin re'sen kiralanması uygulaması başladı. 2027 Programı'na göre bu uygulamanın da etkisiyle 2024'te işlenmediği tespit edilen **29,5** bin hektarın **16,1** bin hektarında arazi sahipleri yeniden üretime başladı. Tespitin hangi yöntemle yapıldığı açıklanmadı.

TÜBİTAK UZAY'ın kataloğu, Güneydoğu Anadolu'da insansız hava aracı ve uydu görüntüsüyle yapılan değişken oranlı gübrelemede test tarlalarında gübre kullanımında **%25**'e kadar tasarruf sağlandığını ve analizlerin bölgedeki çiftçilere ve danışmanlara bir web arayüzünden sunulduğunu yazıyor. Bu, kurumun kendi açıklaması: yöntemi, yılı ve örneklemi açıklanmadı; bağımsız bir değerlendirmesi de bulunmuyor.
