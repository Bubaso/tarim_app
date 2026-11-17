# 4 · Toprak ve arazi

> **Özet.** Toprağı her metrede ölçmek mümkün değil: birkaç noktada ölçülür, aradaki boşluğu bir model doldurur. Dijital toprak haritacılığında bu model, ölçümleri uydu, arazi şekli ve iklim verisiyle ilişkilendiriyor; yapay zekâ bu modelin içinde. Küresel ölçekteki örneği SoilGrids: makine öğrenmesiyle, yaklaşık **240.000** noktadaki ölçümden bütün dünyayı **250** metrelik hücrelerle haritalıyor ve her hücre için ne kadar emin olmadığını da söylüyor. Kaba desenleri iyi yakalıyor, tarla ölçeğinde yanılabiliyor. Türkiye'de 2027 programı **15** ilde **3,5** milyon hektar tarım arazisinde detaylı toprak etüdünü sürdürmeyi öngörüyor; Bakanlık Aralık 2025'te Dünya Bankası kredisiyle detaylı dijital toprak haritaları için ihaleye çıktı.

## Ne yapıyor

Klasik toprak etüdünde uzman araziye çıkar, profil açar, örnek alır; toprak tiplerinin sınırını haritaya uzman bilgisiyle çizer. Dijital toprak haritacılığı aynı ölçümlerle başlıyor ama sınırı çizmeyi bir modele bırakıyor. Model, ölçülen noktalardaki toprak özelliğini — organik karbon, pH, kil oranı — o noktanın bitki örtüsü, eğimi, iklimi ve jeolojisi gibi ortam verileriyle ilişkilendiriyor; sonra ölçüm olmayan her hücre için bir tahmin üretiyor.

Yapay zekâ bu işin model kısmında. SoilGrids'in kullandığı yöntem kantil regresyon ormanları: çok sayıda karar ağacının tahminini bir arada tuttuğu için tek bir değer yerine bir dağılım veriyor. Her hücre için tahminin yanında, gerçek değerin **%90** olasılıkla içinde kalması beklenen bir aralık da hesaplanıyor. Haritayı kullanan için bu önemli: harita nerede emin olduğunu, nerede olmadığını da gösteriyor. Yazarlar bunu kullanıcıya hem bir ölçü hem bir uyarı olarak sunuyor.

## Küresel harita ne kadar tutuyor

SoilGrids'in 2.0 sürümünü anlatan makale (Poggio ve arkadaşları, 2021) haritanın nasıl üretildiğini ve ne kadar tuttuğunu birlikte veriyor:

| Ölçü | SoilGrids 2.0 |
|---|---|
| Hücre boyu | **250** m — bir hücre **6,25** hektar |
| Ölçüm noktası | yaklaşık **240.000** |
| Ortam verisi katmanı | **400**'den fazla |
| Derinlik | **6** standart aralık, **200** cm'ye kadar |
| Başarı puanı | özelliğe göre **0,31** ile **0,74** arası |

Başarı puanı (MEC), modelin ölçülen değerlerdeki değişkenliğin ne kadarını açıkladığını gösteriyor; **1** kusursuz tahmin demek. En zayıf tahmin, toprağın içindeki iri parçaların (taş ve çakıl) payında. Derine inildikçe başarı düşüyor.

Yazarların kendi değerlendirmesi iki yönlü. Kaba ölçekli desenler iyi yakalanıyor; ama belirsizlik haritası, özellikle yüksek enlemlerde daha çok toprak ölçümüne ihtiyaç olduğunu gösteriyor. Avrupa ve Kuzey Amerika'da her **10** km² için dörtten fazla toprak profili varken Kazakistan, Hindistan ve Moğolistan gibi büyük Asya ülkelerinde profil sayısı hâlâ oldukça sınırlı.

Tarla ölçeğinde ise harita yanılabiliyor. ABD'de, ayrıntılı saha etüdüne dayanan ulusal toprak veritabanıyla yapılan bir ön karşılaştırma, SoilGrids'in yerel ana materyal geçişlerini kaçırabildiğini gösterdi; yerel tane boyu deseni kimi yerde bir tane boyu sınıfının **%20-30**'u mertebesinde sapıyordu. Yazarlar ürünün asıl sınavını küresel ve geniş bölgesel uygulamalar olarak tarif ediyor.

Bir hücre **6,25** hektarlık bir kare. 2027 Programı Türkiye'de işletmelerin arazi yapısını küçük ölçekli, parçalı ve dağınık diye tanımlıyor; böyle bir arazide küresel haritanın tek hücresi birden fazla tarlayı kapsayabilir. Küresel harita bir bölgenin toprağını anlamak için güçlü bir başlangıç; tarla ölçeğinde bir karar için — örneğin değişken oranlı gübreleme (§6) — yerel ölçümün yerini tutması beklenmemeli. Tahminler CC BY 4.0 lisansıyla herkese açık.

## Türkiye

Türkiye'nin ulusal ölçekte toprak verisi yeni değil. TAGEM'in 2017 tarihli duyurusuna göre Toprak Gübre ve Su Kaynakları Merkez Araştırma Enstitüsü, FAO destekli ve 2012-2015'te yürütülen bir projeyle tarım topraklarının pH, tuzluluk, kireç, alınabilir fosfor ve potasyum, katyon değişim kapasitesi ve bünye haritalarını; organik karbon dağılımı ve karbon bütçesi haritalarıyla birlikte üretti. Haritalar, standart harita servisleriyle Ülkesel Toprak Bilgi Sistemi portalında paylaşıma açıldı.

2027 Yıllık Programı toprak verisini arazi kullanım kararlarının dayanağı sayıyor ve detaylı toprak etüdüne bir takvim veriyor. 2024'te **755** bin hektarda detaylı toprak etüdü ve haritalama tamamlandı; 2026 sonuna kadar **2,4** milyon hektarın daha bitmesi öngörülüyor. Çalışmaların sürdüğü **6,8** milyon hektarlık proje sahasının **3,5** milyon hektarının 2027'de, kalan **3,3** milyon hektarının 2028'de tamamlanması öngörülüyor. 2027 tedbiri olarak **15** ilde **3,5** milyon hektar tarım arazisinde etüt ve haritalamaya devam edilecek. Ölçek için: Türkiye'nin tarım arazisi 2025 itibarıyla **24** milyon hektar.

Program bunun yanında ulusal arazi örtüsü haritasının her yıl üretilmesini, iklim projeksiyonlarına dayalı su erozyonu ve sediment analizleri için de veri altyapısı ve yöntem geliştirme çalışmalarını öngörüyor.

Bakanlık Aralık 2025'te, Dünya Bankası kredisiyle yürütülen Türkiye İklim Akıllı ve Rekabetçi Tarımsal Büyüme Projesi kapsamında toprak etüdü, toprak analizleri ve detaylı dijital toprak haritalarının hazırlanması için ihaleye çıktı. İhale **13** ilde **5,16** milyon hektar tarım alanını kapsıyor (proje sınırının tamamı **12,3** milyon hektar); iş **10** kısma bölünmüş, süresi **600** gün. Haritaların hangi yöntemle, makine öğrenmesiyle mi üretileceği açıklanmadı.

Akademide de bu yöntemle çalışılıyor: Kaya ve arkadaşlarının 2022 çalışması kuzeybatı Türkiye'de toprak bünye sınıfını farklı makine öğrenmesi algoritmalarıyla tahmin edip haritaladı.

Eksik olan ise **yapay zekâyla üretilmiş bir toprak haritasının Türkiye'de tarladaki kararı nasıl değiştirdiğini ölçen, yayımlanmış bir değerlendirme.**

## Bu sayfa nasıl güncelleniyor

Bu sayfa üç şeyi izliyor: dijital toprak haritacılığı, toprak organik karbonu ve arazi uygunluğu üzerine yeni hakemli çalışmalar; detaylı toprak etüdü ve arazi kullanım planlamasına dair resmî gelişmeler; ve buradaki sayıların kaynaklarının yeni sürümleri — yeni yıllık program, SoilGrids'in yeni sürümü. Yeni bilgi, editör onayından sonra sayfaya ekleniyor.
