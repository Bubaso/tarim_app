# Tahmin modelleri

Tarımda tahmin modelleri havayı, verimi, fiyatı ve bir hayvanın genetik değerini öngörmeye çalışıyor. Yapay zekâ tahminde en sağlam sonucunu hava tahmininde veriyor; burada araştırmadan işletmeye geçti. Verimde, fiyatta ve ıslahta ise makine öğrenmesinin klasik yöntemlere üstünlüğü ürüne, ülkeye ve veriye göre değişiyor. Hemen her alanda ölçülen şey tahminin isabeti; daha iyi bir tahminin tarladaki kaybı ya da kazancı ne kadar değiştirdiği çoğunlukla ölçülmüyor. Bakanlığın tarifine göre Türkiye'de resmî rekolte tahmini model kullanmıyor; yapay zekâyla kuraklık tahmini ise 2027'de başlaması planlanan bir çalışma.

## Hava tahmininde araştırmadan işletmeye

Geçmiş hava verisinden öğrenen bir makine öğrenmesi modeli olan GraphCast (Lam ve arkadaşları, 2023), **10** günlük küresel tahminde **1.380** doğrulama hedefinin **%90**'ında işletimdeki en doğru sistemlerden belirgin biçimde iyi sonuç veriyor. Avrupa Orta Vadeli Hava Tahminleri Merkezi 25 Şubat 2025'ten beri kendi yapay zekâ sistemini fizik tabanlı modelinin yanında çalıştırıyor; kuruma göre sistem fizik tabanlı modelleri birçok ölçütte geçiyor, kazanç tropikal siklon rotası gibi ölçütlerde **%20**'ye varıyor.

[[gorsel:t-tahmin-graphcast-in-calisma-semasi-hava]]

Bu çalışmalar isabeti ölçüyor; daha iyi bir don ya da kuraklık tahmininin çiftçinin kaybını ne kadar azalttığını ölçmüyor. Tahminin karara dönüştüğünü gösteren bir ölçüm Hindistan'dan geliyor: yerel muson başlangıcına dair olasılıklı tahminler **13** eyalette **38,8** milyonu aşkın çiftçiye kısa mesajla gönderildi ve iki eyaletteki takip anketlerine göre çiftçilerin **%31-52**'si ekim kararını bu tahminlere göre değiştirdi.

## Klasik yöntemlerle yarışta kazanç değişken

Yerleşik bir sistemde bile isabet ülkeden ülkeye değişiyor: Avrupa Komisyonu'nun MARS verim tahmin sisteminde 2006-2015 döneminde ortanca hata Fransa'da **%3,73**, Portekiz'de **%14,37** çıktı (Van der Velde ve Nisini, 2019). Aynı sistemin verisiyle kurulan bir makine öğrenmesi modeli kimi üründe sisteme yetişti, kimisinde iki kat hata yaptı (Paudel ve arkadaşları, 2021).

Fiyatta yapay zekâ ölçülebilir bir iyileşme getiriyor. Hindistan'da günlük toptan fiyatlarda derin öğrenme modeli GRU, klasik ARIMA modelini açık farkla geçti: hata ölçüsü (RMSE) soğanda **370**'e karşı **1.565** (Manogna ve arkadaşları, 2025). Yine de bu modelin ortalama yüzde hatası domateste **%10,58**, soğanda **%14,59**; İtalyan bir gıda toptancısında ise ARIMA ile LSTM ağları benzer sonuç verdi (Menculini ve arkadaşları, 2021). Islahta derin öğrenme, genomik tahminde klasik modellere açık bir üstünlük göstermedi (Montesinos-López ve arkadaşları, 2021).

## Doğru tahmin her zaman doğru karar değil

De Lara ve arkadaşlarının (2023) buğday ve arpa denemelerinde makine öğrenmesi verimi ortalama **%13,7** hatayla tahmin etti, ama benzer doğruluktaki iki model ekonomik en uygun azot dozu için birbirinden çok farklı sonuçlar çıkardı. Etkisi ölçülmüş bir tahmin ise genomik seçilim: ABD'de Holstein ırkında boğa babalarının kuşak aralığını yaklaşık **7** yıldan **2,5** yılın altına indirdi, verim özelliklerinde yıllık genetik ilerlemeyi **%50-100** artırdı (García-Ruiz ve arkadaşları, 2016).

## Rekolte bülteninden kuraklık tahminine

Bakanlığa göre Türkiye'de resmî bitkisel üretim tahmini, ilçe müdürlüklerinin kayıtlarına ve tarım teknisyenlerinin izlenimlerine dayanıyor; uydu ya da model kullanılmıyor. Kışlık buğday için FAO destekli agrometeorolojik verim tahmini bültenleri 2005-2006 sezonunda başladı, ama son bültenler dekara rakam vermiyor. Bakanlık 2025'te makine öğrenmesini uydudan ürün tespitinde kullanmaya başladı; bunun rekolte tahminine girip girmediği açıklanmadı. Yapay zekâyla yapılmış bir rekolte tahminini resmî tahminle ya da gerçekleşen üretimle karşılaştıran, yayımlanmış bir Türkiye değerlendirmesi de bulunmuyor.

Meteoroloji Genel Müdürlüğü'nün Zirai Don Uyarı Sistemi bütün il ve ilçeler için bitki bazında **5** günlük don tahmini veriyor. Kurum 2025'ten bu yana yapay zekâ destekli tahmin sistemleri kullandığını söylüyor, ama hangi tahminlerde kullandığını ve isabetini açıklamadı. 2027 Yıllık Programı'nın tarım bölümündeki tek somut yapay zekâ işi de bir tahmin: Tarımsal Kuraklık İzleme Sistemi'yle kuraklığı **1-4** hafta önceden öngörmeye yönelik çalışmaların 2027'de başlatılması planlanıyor.
