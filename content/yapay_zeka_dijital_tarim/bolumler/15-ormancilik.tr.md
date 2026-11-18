# 15 · Ormancılık

Yapay zekâ ormancılıkta iki işte öne çıkıyor: ormanın yapısını uydudan haritalamak ve yangını erken görmek. Türkiye'de yangın yükü artıyor; resmî istatistiklerin başladığı 1988'den 2025'e kadar yanan **634.575** hektarın **%43,6**'sı son beş yılda yandı. Orman Genel Müdürlüğü önce kule kameralarına dayanan bir yangın uyarı sistemi kurdu, sonra yapay zekâ destekli bir karar destek sistemini devreye aldı. Ama iki sistemin de tespit süresine, yanan alana ya da yanlış alarm oranına etkisini ölçen bağımsız bir değerlendirme yayımlanmış değil.

[[grafik:b15-yanan-alan-son-bes-yil]]

## Ne yapıyor

Ormancılıkta dijital teknoloji üç işe yarıyor: ormanın ne kadar ve nasıl olduğunu ölçmek (alan, ağaç boyu, karbon), değişimi yakalamak (ormansızlaşma, yangın, zararlı ve hastalık) ve yangına karşı erken uyarı ve müdahale. Uydular ve uzaydaki lazer ölçerler geniş alanı görüyor; yapay zekâ bu verilerden ağaç boyunu, yanmış alanı ya da dumanı çıkarıyor. Yerdeki kameralar ve insansız hava araçları ise yangının ilk dakikalarını yakalamaya çalışıyor.

[[gorsel:b15-uydudan-orman-yangini-manavgat-ve]]

## Saha ne diyor

FAO'nun 2025 orman kaynakları değerlendirmesinden:

| Gösterge | Değer |
|---|---|
| Dünyanın orman alanı | **4,14** milyar hektar (karaların **%32**'si) |
| Ormansızlaşma, 1990-2000 | yılda **17,6** milyon hektar |
| Ormansızlaşma, 2015-2025 | yılda **10,9** milyon hektar |
| Net orman kaybı, 2015-2025 | yılda **4,12** milyon hektar |
| Yangının etkilediği alan | yılda ortalama **261** milyon hektar, yaklaşık yarısı orman |

FAO ormansızlaşmanın bütün bölgelerde yavaşladığını, ama bugünkü hızın hâlâ fazla yüksek olduğunu söylüyor.

Lang ve arkadaşları (2023), uzaydaki GEDI lazer ölçerinin seyrek yükseklik verisini Sentinel-2 uydu görüntüleriyle birleştiren olasılıksal bir derin öğrenme modeliyle 2020 yılı için **10** metre çözünürlüklü küresel bir ağaç boyu haritası üretti; model her tahminin belirsizliğini de veriyor. Haritaya göre karaların yalnız **%5**'i **30** metreden uzun ağaçlarla kaplı ve bu uzun ormanların yalnız **%34**'ü koruma alanlarında.

[[gorsel:b15-kuresel-agac-boyu-haritasi-2020]]

Govil ve arkadaşları (2020), Güney Kaliforniya'da yüzlerce kamerayı dakikada bir tarayan, makine öğrenmesiyle görüntü tanıyan bir duman tespit sistemi prototipi geliştirdi. Sistem dumanı çoğunlukla tutuşmadan sonraki **15** dakika içinde, kamera başına günde ortalama birden az yanlış alarmla yakalıyordu ve bazı yangınları ihbardan ya da uydu tespitinden önce gördü. Yazarlar yerdeki kameraların her yangını göremeyeceğini, bu yüzden kamera ile uydu tespitini birleştiren bir sistem kurduklarını da yazıyor.

[[gorsel:b15-kamerayla-orman-yangini-dumani]]

## Yapay zekâ nerede duruyor

Yapay zekâ ormancılıkta ölçeği değiştiriyor: tek bir modelle bütün gezegenin ağaç boyu çıkarılabiliyor, bir yazılım yüzlerce kamerayı aynı anda izleyebiliyor. Ama yangın tespitinde ölçülen başarı sistemin nerede ve hangi ölçütle sınandığına bağlı; kamera ancak dumanı görebildiği yangını yakalayabiliyor.

## Türkiye

Bakanlığın verisine göre Türkiye'nin orman alanı 2025'te **23.375.331** hektar. 2027 Programı'na göre 2025'te **3.224** yangında **81.473** hektar, 2026'nın ilk dokuz ayında **2.009** yangında **24.451** hektar orman yandı. Son on yılda çıkan yangınların **%41,1**'inin nedeni tespit edilemedi. 2026'da yangınlara **119** helikopter, **28** uçak ve **14** insansız hava aracıyla havadan müdahale edildi; yaklaşık **28** bin personel ve **142** bini aşan gönüllü görev alıyor.

Erken tespitte Türkiye'nin geçmişi uzun. TÜBİTAK'ın 2013 duyurusuna göre Orman Genel Müdürlüğü ile Bilkent Üniversitesi'nin TÜBİTAK desteğiyle geliştirdiği Orman Yangın Uyarı Sistemi, yangın gözetleme kulelerine kurulan kameraların görüntüsünü bir yazılımla işliyor. O tarihte **77** kulede **154** kamerayla **3,2** milyon hektar izleniyordu ve duyuru küçük bir yangının **15-25** saniyede tespit edildiğini söylüyor. Bu, kurumun kendi açıklaması; sistemin isabetini ve yanlış alarm oranını bağımsız olarak ölçen yayımlanmış bir değerlendirme bulunmuyor.

[[gorsel:b15-kamerali-insansiz-yangin-gozetleme]]

Bakanlığın 2024 tarihli haberine göre Orman Genel Müdürlüğü 2022'den beri yerli imkânlarla geliştirilmiş bir Karar Destek Sistemi kullanıyor: meteoroloji verisini, orman bilgi sistemi (ORBİS) verisini, İHA ve uydu görüntülerini birleştiriyor. Sistem yangın çıkma olasılığını ve nedenini tahmin ediyor ve yapay zekâ desteğiyle yangının davranışını ve ilerleyişini öngörüyor. Sistem, BM'ye bağlı Uluslararası Telekomünikasyon Birliği'nin Dünya Bilgi Toplumu Zirvesi Ödülleri'ne aday gösterildi.

[[gorsel:b15-orman-genel-mudurlugu-nun-yapay-zeka]]

Akademide de çalışmalar var. Karabük Üniversitesi'nden bir çalışma, yazarların tasarladığı dört rotorlu bir İHA'ya gömülü derin öğrenmeyle yangın tespitini sınadı ve sınıflandırmada **%96** doğruluk bildiriyor (Shamta ve Demir, 2024). Hacettepe Üniversitesi'nin de yer aldığı bir çalışma, Akdeniz ekosistemindeki bir kızılçam ormanında yanmış alanı radar, optik ve termal uydu verisi ve rastgele orman yöntemiyle **%96** genel doğrulukla haritaladı (Abdikan ve arkadaşları, 2022).

[[gorsel:b15-iha-ya-gomulu-derin-ogrenmeyle]]