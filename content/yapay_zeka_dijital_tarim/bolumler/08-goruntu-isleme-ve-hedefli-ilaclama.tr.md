# 8 · Görüntü işleme ve hedefli ilaçlama

> **Özet.** Bir kamera tarlaya bakıyor, bir model yabancı otu üründen ayırıyor ve ilaç yalnız otun olduğu yere atılıyor. Hakemli saha denemeleri bunun çalıştığını gösteriyor: şeker kamışında ilaç **%35**, mısırda erken uygulamada **%47** azalıyor ve ot kontrolü yayma ilaçlamayla aynı kalıyor. Satıcıların rakamları bundan büyük. Asıl açık ise başka yerde: laboratuvarda **%99,35** başarı gösteren bir hastalık modeli, sahadan gelen görüntülerde **%31'in hemen üstüne** düşüyor.

## Ne yapıyor

Geleneksel ilaçlama tarlanın tamamına aynı dozu atar; buna yayma ilaçlama deniyor. Hedefli ilaçlama ise tarlayı tek tek bitkilere ayırır. İlaçlayıcının üstündeki ya da bir insansız hava aracının taşıdığı kamera görüntü alır, bir model o görüntüde neyin ürün neyin yabancı ot olduğuna karar verir, ve meme yalnız otun üstünden geçerken açılır.

İki ayrı durum var ve ayrımı yapmadan hiçbir rakam okunamaz. **Çıplak toprakta yeşil ot** — nadasta, ekim öncesinde — görece kolay bir problem: kahverengi zemin üstünde yeşil olan her şey ottur. **Ürünün içinde yeşil ot** ise zor bir problem: yeşil bir bitkiyi yeşil bir bitkiden ayırmak gerekir, yapraklar örtüşür, ışık ve gölge değişir. Satıcı broşürlerindeki en yüksek rakamlar çoğunlukla ilk durumdan geliyor.

## Saha denemeleri ne diyor

Bu bölümün dayandığı rakamlar, ilacın gerçekten azaldığını ve ot kontrolünün bozulmadığını aynı anda ölçen hakemli saha denemelerinden.

| Deneme | Ürün | Ölçülen | Nitelik |
|---|---|---|---|
| Avustralya, 25 hektar, 2025 | Şeker kamışı | İlaç **%35** azaldı; yayma ilaçlamanın etkinliğinin **%97**'si | Hakemli |
| Aynı deneme, ot yoğunluğu düşük şeritler | Şeker kamışı | İlaç **%65**'e kadar azaldı | Hakemli |
| Aynı deneme, ilaçlamadan 3-6 gün sonra | Şeker kamışı | Akış suyunda ilaç yoğunluğu **%39**, toplam yük **%54** düşük | Hakemli |
| Almanya, tarla denemesi, 2024 | Tane mısır | Otların **%94**'ü doğru tanındı; etkinlik **%86**, yayma ilaçlamaya eşit; erken uygulamada ilaç **%47** azaldı | Hakemli |

Avustralya denemesinin en önemli bulgusu ortalamadan çok ortalamanın nasıl oluştuğu: tasarruf ot yoğunluğuyla orantılı. Az otlu bir şeritte ilacın üçte ikisi kalkıyor, yoğun otlu bir şeritte ise hedefli ilaçlama yayma ilaçlamaya yaklaşıyor — çünkü her yere zaten ilaç gerekiyor. Yani hedefli ilaçlamanın getirisi teknolojiden çok tarlanın kendisine bağlı.

Aynı deneme bir şeyi daha ölçtü: ilaçlamadan sonraki günlerde tarladan çıkan sudaki ilaç. Tarım ilacının akarsuya ve yeraltı suyuna karışması, ilacın maliyetinden bağımsız bir sorun. Hedefli ilaçlama orada da ölçülebilir bir fark yaratıyor.

Almanya'daki mısır denemesinde kamera ilaçlayıcının üstünde değil: önce bir insansız hava aracı tarlanın yüksek çözünürlüklü haritasını çıkarıyor, sonra ilaçlayıcı o haritayı izliyor. Yöntem farklı, sonuç aynı yönde.

## Satıcılar ne diyor

En yaygın ticari sistemlerden biri John Deere'nin See & Spray'i. Şirketin kendi rakamları:

| Yıl | Alan | Şirketin beyanı | Nitelik |
|---|---|---|---|
| 2024 | 1 milyon akre | Ortalama **%59** ilaç tasarrufu | Şirket beyanı |
| 2025 | 5 milyon akre | Kalıcı olmayan ilaçta ortalama yaklaşık **%50** azalma | Şirket beyanı |

İki rakam yan yana konunca bir düşüş görünüyor, ama bu dosya bir eğilim iddia etmiyor: 2025 rakamı açıkça "kalıcı olmayan ilaç" diyor ve 2024 rakamının aynı şeyi ölçüp ölçmediği belirsiz. Şirket verisi bağımsız olarak denetlenmedi.

Bazı sistemler için bundan da yüksek tasarruf rakamları dolaşıyor. Kaynakları satıcı beyanları ve çoğu çıplak toprak üstündeki ot senaryosuna ait — yani yukarıda anlatılan kolay duruma. Bu yüzden bu dosyada sayı olarak verilmiyor.

## Laboratuvar ile tarla arasındaki açık

Görüntü işlemenin tarımdaki en çok alıntılanan başarılarından biri 2016'da yayımlandı. Araştırmacılar 14 ürüne ve 26 hastalığa ait **54.306** yaprak görüntüsüyle bir model eğitti ve ayrı tutulan test görüntülerinde **%99,35** doğruluk elde etti.

Aynı makalenin daha az alıntılanan kısmı şu: model, farklı koşullarda çekilmiş görüntülerle sınandığında doğruluk **%31,40** ve **%31,69**'a düştü. Eğitim görüntüleri denetimli ışık ve sade bir arka planla çekilmişti; tarladaki görüntüde ise gölge, toprak, öteki yapraklar ve rastgele bir açı vardı. %31 rastgele tahminden — 38 sınıfta **%2,6** — çok daha iyi, ama %99'un yakınında değil. Yazarların kendi sonucu açık: daha çeşitli eğitim verisi gerekiyor.

Bu iki rakam arasındaki fark, bu alanda okunan her başarı oranının sorulması gereken soruyu gösteriyor: **hangi görüntüde ölçüldü?**

## Türkiye

Türkiye'de görüntü işlemeyle yabancı ot tespiti üniversitelerde tez düzeyinde çalışılıyor. Pamukkale Üniversitesi'ndeki bir yüksek lisans tezi mısırda yabancı otları tespit edip lokal ilaçlamayı hedefliyor; Tokat Gaziosmanpaşa Üniversitesi'nde buğdayda yabancı ot tespitine dair bir doktora tezi var. Türkçe literatürde insansız hava aracıyla ot tespitine dair derleme çalışmaları da yayımlanmış.

Bu dosyanın taramasında bulunamayan şey ise **ilaç tasarrufunu sahada ölçen, yayımlanmış bir Türkiye denemesi.** Tespit modeli ile tarladaki ilaç azalması arasındaki bu adım, yukarıdaki denemelerin ölçtüğü adım.

## Bu başlıkta otomatik güncellenenler

Bu başlık iki şeyi izliyor: hedefli ilaçlamaya dair yeni hakemli saha denemeleri ve satıcıların yeni beyanları. Yeni bir rakam bulunduğunda sayfaya doğrudan girmiyor; onaya düşüyor.
