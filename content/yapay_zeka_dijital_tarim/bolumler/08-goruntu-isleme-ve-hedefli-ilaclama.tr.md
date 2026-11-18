# 8 · Görüntü işleme ve hedefli ilaçlama

Hedefli ilaçlamanın vaadi basit: ilacı bütün tarlaya değil, yalnız yabancı otun üstüne atmak. Hakemli saha denemeleri bu vaadin tuttuğunu gösteriyor: şeker kamışında ilaç **%35**, mısırda erken uygulamada **%47** azaldı, ot kontrolü ise yayma ilaçlamayla aynı düzeyde kaldı. Satıcıların bildirdiği tasarruf daha da büyük. Asıl açık ise laboratuvar ile tarla arasında: denetimli koşullarda neredeyse kusursuz çalışan bir bitki hastalığı modeli, başka koşullarda çekilmiş görüntülerde çoğu zaman yanıldı.

## Ne yapıyor

Geleneksel ilaçlama tarlanın tamamına aynı dozu atar; buna yayma ilaçlama deniyor. Hedefli ilaçlama ise tarlayı tek tek bitkilere ayırır. İlaçlayıcının üstündeki ya da bir insansız hava aracının taşıdığı kamera görüntü alır, bir model o görüntüde neyin ürün neyin yabancı ot olduğuna karar verir ve meme yalnız otun üstünden geçerken açılır.

[[gorsel:b08-hedefli-ilaclamanin-isleyisi-kamera]]

İki ayrı durum var ve ayrımı yapmadan hiçbir rakam okunamaz. **Çıplak toprakta yeşil ot** — nadasta, ekim öncesinde — görece kolay bir problem: kahverengi zemin üstünde yeşil olan her şey ottur. **Ürünün içinde yeşil ot** ise zor bir problem: yeşil bir bitkiyi yeşil bir bitkiden ayırmak gerekir, yapraklar örtüşür, ışık ve gölge değişir. Satıcı broşürlerindeki en yüksek rakamlar çoğunlukla ilk durumdan geliyor.

[[gorsel:b08-nadasta-ciplak-toprakta-yesil-ot]]

## Saha denemeleri ne diyor

Avustralya'daki ve Almanya'daki hakemli denemeler iki şeyi birlikte ölçtü: ilacın gerçekten azalıp azalmadığını ve ot kontrolünün bozulup bozulmadığını.

[[gorsel:b08-autoweed-spot-ilaclama-sistemi]]

| Deneme | Ürün | Ölçülen | Nitelik |
|---|---|---|---|
| Avustralya, 25 hektar (yayım 2025) | Şeker kamışı | İlaç **%35** azaldı; yayma ilaçlamanın etkinliğinin **%97**'si | Hakemli |
| Aynı deneme, ot yoğunluğu düşük şeritler | Şeker kamışı | İlaç **%65**'e kadar azaldı | Hakemli |
| Aynı deneme, ilaçlamadan 3-6 gün sonra | Şeker kamışı | Akış suyunda ilaç yoğunluğu **%39**, toplam yük **%54** düşük | Hakemli |
| Almanya, tarla denemesi (yayım 2024) | Tane mısır | Otların **%94**'ü doğru tanındı; etkinlik **%86**'ya kadar, yayma ilaçlamaya eşit; erken uygulamada ilaç **%47** azaldı | Hakemli |

Avustralya denemesinin en önemli bulgusu ortalamadan çok ortalamanın nasıl oluştuğu: kullanılan ilaç ot yoğunluğuyla orantılı, yani tasarruf ot azaldıkça büyüyor. Az otlu bir şeritte ilacın üçte ikisi kalkıyor, yoğun otlu bir şeritte ise hedefli ilaçlama yayma ilaçlamaya yaklaşıyor — çünkü her yere zaten ilaç gerekiyor. Yani hedefli ilaçlamanın getirisi teknolojiden çok tarlanın kendisine bağlı.

[[grafik:b08-hedefli-ilaclama-azalmalar]]

Aynı deneme bir şeyi daha ölçtü: ilaçlamadan sonraki günlerde tarladan çıkan sudaki ilaç. Tarım ilacının akarsuya ve yer altı suyuna karışması, ilacın maliyetinden bağımsız bir sorun. Hedefli ilaçlama orada da ölçülebilir bir fark yaratıyor.

[[gorsel:b08-seker-kamisi-hedefli-ilaclama]]

Almanya'daki mısır denemesinde kamera ilaçlayıcının üstünde değil: önce bir insansız hava aracı tarlanın yüksek çözünürlüklü haritasını çıkarıyor, sonra ilaçlayıcı o haritayı izliyor. Yöntem farklı, sonuç aynı yönde.

[[gorsel:b08-iha-ot-haritasiyla-misirda-spot]]

## Satıcılar ne diyor

En yaygın ticari sistemlerden biri John Deere'nin See & Spray'i. Şirketin kendi rakamları:

[[gorsel:b08-john-deere-see-spray-ultimate]]

| Yıl | Alan | Şirketin beyanı | Nitelik |
|---|---|---|---|
| 2024 | 1 milyonu aşkın akre | Ortalama **%59** ilaç tasarrufu | Şirket beyanı |
| 2025 | 5 milyonu aşkın akre | Kalıcı olmayan ilaçta ortalama yaklaşık **%50** azalma | Şirket beyanı |

İki rakam yan yana konunca bir düşüş görünüyor, ama bu bir eğilim sayılamaz: 2025 rakamı açıkça kalıcı olmayan (non-residual) ilaca ait ve 2024 rakamının aynı şeyi ölçüp ölçmediği belirsiz.

## Laboratuvar ile tarla arasındaki açık

Görüntü işlemenin tarımdaki en çok alıntılanan başarılarından biri 2016'da yayımlandı. Araştırmacılar 14 ürüne ve 26 hastalığa ait **54.306** yaprak görüntüsüyle bir model eğitti ve ayrı tutulan test görüntülerinde **%99,35** doğruluk elde etti.

[[gorsel:b08-plantvillage-veri-setinden-yaprak]]

Aynı makalenin daha az alıntılanan kısmı şu: model, farklı koşullarda çekilmiş görüntülerle sınandığında doğruluk **%31,40** ve **%31,69**'a düştü. Eğitim görüntüleri denetimli koşullarda, sade bir arka plan üzerinde tek yaprak olarak çekilmişti; sınama görüntüleri ise tarım yayım servisleri gibi güvenilir çevrim içi kaynaklardan toplandı. Yazarlar, gerçek bir uygulamanın hastalığı doğrudan bitkinin üzerinde göründüğü hâliyle tanıyabilmesi gerektiğini yazıyor. %31 rastgele tahminden — 38 sınıfta **%2,6** — çok daha iyi, ama %99'un yakınında değil. Yazarların kendi sonucu açık: daha çeşitli eğitim verisi gerekiyor.

[[grafik:b08-laboratuvar-tarla-dogruluk]]

Bu iki rakam arasındaki fark, bu alanda okunan her başarı oranının sorulması gereken soruyu gösteriyor: hangi görüntüde ölçüldü?

## Türkiye

Türkiye'de görüntü işlemeyle yabancı ot tespiti çoğunlukla üniversitelerde tez düzeyinde çalışılıyor. Pamukkale Üniversitesi'ndeki bir yüksek lisans tezi mısırda yabancı otları tespit edip lokal ilaçlamayı hedefliyor; Tokat Gaziosmanpaşa Üniversitesi'nde buğdayda yabancı ot tespitine dair bir doktora tezi var. Türkçe literatürde insansız hava aracıyla ot tespitine dair bir derleme de yayımlanmış. Ama tespit modelinden tarladaki ilaç azalmasına giden adımı, Avustralya ve Almanya'daki denemeler gibi sahada ölçen, yayımlanmış bir Türkiye denemesi henüz yok.

TAGEM'in 2025'te başlattığı projenin hedefi ise bir hassas ilaçlama makinesi prototipi: makine mısır ve pamukta yabancı otun yerini kamerayla tespit edecek ve ilaç memelerini yalnız hedefin üstünde açacak.
