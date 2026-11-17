# Yapay Zeka ve Dijital Tarım — karar defteri

**Tur 0 · 16 Kasım 2026.** Elli soru soruldu, kullanıcı hepsini cevapladı.
Bu dosya o kararların kaydıdır; sonraki turlar buradan okur ve yeniden
sormaz.

## A · Kimlik ve kapsam

| # | karar |
|---|---|
| 1 | Ad **"Yapay Zeka ve Dijital Tarım"**, adres **`/yapay-zeka-dijital-tarim`** |
| 2 | **Pencere yok** — kalıcı. Ana sayfa kartında "şu an öne çıkan" başlık dönüyor |
| 3 | Kapsam **dijital tarım şemsiyesi**: yapay zeka çekirdek, sensör/İHA/robotik/büyük veri dahil |
| 4 | Okur **üçü birden, katmanlı** — her başlıkta özet katmanı + derinleşen katman |
| 5 | **Eşit ağırlık, ama Türkiye zorlanmayacak.** Kullanıcının kendi ifadesi: "her başlıkta Türkiye ile ilgili bir şey yazacağım diye kasmayalım. varsa yazılır yoksa dünya kalır." |
| 6 | **Tez yok.** Yerine "bugün nerede duruyoruz" — ölçülmüş, taramanın güncellediği durum özeti |
| 7 | **İki dilli** (TR + EN) |

## B · Yapı

| # | karar |
|---|---|
| 8 | **Merkez sayfa + alt sayfalar.** Her ana başlığın kendi adresi |
| 9 | Hacim **geniş: 25-30 başlık** |
| 10 | Tarama **yeni başlık ÖNEREBİLİR**, karar kullanıcıda |
| 11 | Gezinme **etkileşimli harita** |
| 12 | Başlık düzeni **konuya göre değişsin** — sabit şablon yok |
| 13 | Taksonomi **iki eksen birden**: ana iskelet süreç ekseninde, teknoloji etiketleriyle çapraz gezinme |
| 14 | Sözlük **kendi sayfası + metin içi balon** |
| 15 | Kaynakça **sade liste** (kaynak niteliği rakamın yanında duruyor, kaynakçada değil) |

## C · Otomatik güncelleme

| # | karar |
|---|---|
| 16 | Oto hedefler: **sayılar/seriler · Türkiye dizini · mevzuat ve politika · yeni gelişmeler + başlık önerisi** |
| 17 | **Tarama TASLAK üretir, kullanıcı onaylar.** Hiçbir şey onaysız yayına girmez |
| 18 | Ritim **ikisi birden**: her haber çekiminde hafif bağlama + elle çağrılan kapsamlı tarama |
| 19 | Kapsamlı tur **aylık** hatırlatılır |
| 20 | Bildirim yok — **yalnız kuyruğa düşsün** |
| 21 | Veri yeri **karma**: iskelet ve yazılı içerik gömülü (ağ düşse de sayfa çalışır), oto alanlar ve haber akışı veritabanından |
| 22 | İzlenecek kaynaklar: **Resmî Gazete/bakanlık · akademik (arXiv, hakemli) · kurumsal rapor (FAO, OECD, Dünya Bankası, AB) · sektör ve girişim haberleri** |
| 23 | Güncellik **başlık bazında** gösterilir |
| 24 | Kaynak düşerse **eski değeri tut, tarihini göster** |
| 25 | **Doğrulayıcılar tam** — dosya dizisindeki gibi |

## D · Haber kategorizasyonu

| # | karar |
|---|---|
| 26 | **ÇAPRAZ ETİKET.** Haber mevcut kategorisinde kalır, ayrıca bölüm etiketi alır. Mevcut bölümlerden haber çalınmaz |
| 28 | Etiket ölçütü **editör ajanının kararı** |
| 29 | Geriye dönük **son 300 haber** taranacak (kullanıcının kendi rakamı) |
| 31 | Çakışmada **haber iki bölümde birden** görünür |
| 32 | Haberler **ilgili başlığın altında** |
| 33 | Yanlış etiket **panelden tek tıkla** kaldırılır |

### Tur 2'de nasıl uygulandı (16 Kasım 2026)

**28 · Editör ajanı karar veriyor — ama KANITLA.** İlk soru ("haberin
KONUSU bu teknoloji mi") son 300 haberde ölçüldü ve COP31'in kusurunu
tekrarladı: aynı olayın üç haberi bir EVET iki HAYIR aldı. Soru bir
çıkarma sorusuna çevrildi: "haberde somut bir bilgi var mı — varsa o
cümleyi metinden kelimesi kelimesine kopyala". Kanıt cümlesi metinde
bulunmazsa etiket konmaz. Kullanıcının ilk ifadesine de daha yakın:
"içinde yapay zeka geçen tüm haberler".

**33 · Tek tıkla kaldır — ve tek tıkla ekle.** Ajanın kanıtlı EVET
vermediği her kapı isabeti "sınırda" durumunda kaydediliyor; bölümde
görünmüyor, panelde tek tıkla ekleniyor. Editörün kaldırdığı ya da elle
verdiği karara hat ve geriye dönük tarama dokunmuyor.

### Karara bağlanmamış, varsayımla ilerlenen iki teknik nokta

**27 · Etiket nerede duracak.** `articles`'a tek sütun DEĞİL, ayrı bir
ilişki tablosu. Gerekçe: çapraz etiket seçildi ve çakışma kararı (31) bir
haberin birden çok özel bölüme ait olabileceğini söylüyor. Tek sütun bunu
taşıyamaz. Kullanıcı aksini söylerse değişir.

**30 · Türkçe terim varyantları.** Aday bulmada "yapay zeka", "yapay zekâ"
(şapkalı), "YZ", "AI", "makine öğrenmesi", "derin öğrenme", "LLM", "dil
modeli", "görüntü işleme", "akıllı tarım", "dijital tarım" aranacak.
**Türkçe küçültme tuzağı geçerli** — `.lower()` doğrudan çağrılmaz
(noktasız I → noktalı i), projenin `buyult`/`kucult` yardımcıları kullanılır.

## E · İçerik

| # | karar |
|---|---|
| 34 | Rakam eşiği **kurumsal + sektör raporu, kaynak adıyla.** Satıcı rakamı girer ama "satıcı beyanı" diye etiketlenir |
| 35 | Şirket adı **geçsin, ölçülen örnekle** ve satıcı beyanı etiketiyle |
| 36 | Eleştirel katman **kendi ana bölümü** |
| 37 | **"Başarısız örnekler ve abartılar" ayrı bölüm** |
| 38 | Türkiye dizini **otomatik güncellenen** |
| 39 | İç bağlar **tek yönlü** — yayındaki sayfalara dokunulmaz |
| 40 | Gerçekleşmemiş kalemler **"beklemede"** olarak gösterilir |
| 41 | Anlatı **ikisi birden**: tarihçe + güncel saha hikâyeleri |

## F · Tasarım

| # | karar |
|---|---|
| 42 | **Kendi dili, AÇIK zemin.** Dizide ilk kez: dosyalar koyu, bu açık |
| 43 | Palet **"makine ve bitki"** |
| 44 | Motif **veri-tarla ızgarası** — tarlanın sıra düzeni ile veri ızgarasının üst üste binmesi |
| 45 | **Bol etkileşimli** |
| 46 | Ana sayfada **kart + canlı haber şeridi** |

## G · Bakım

| # | karar |
|---|---|
| 47 | Onay **yönetim panelinde kuyruk** |
| 48 | Doğrulayıcılar **tam** |
| 49 | Büyüme **alt sayfalara bölünerek** |
| 50 | İlk tur: **ölçüm + iskelet + bir örnek bölüm** · örnek başlık **"Görüntü işleme ve hedefli ilaçlama"** |

## Tur 0'da ölçülenler

**Kod tarafı.** Kategori tek seçimli: `editor.py` altı kategoriden
(`Hayvancılık`, `Bitkisel Üretim`, `Ekonomi`, `Tarım-Bilim`, `YYT`, `Genel`)
yalnız birini atıyor. İki emsal: `uzay_tarimi` gömülü `.g.dart` ve ağa bağlı
değil; `turkuaz_nexus` veritabanlı. İçerik hattı
`content/<bölüm>/_raw → build_data.py → data.json → dart_uret.py`.

**Türkiye.** TAGEM bünyesinde **Yapay Zeka ve Dijital Tarım Teknolojileri
Araştırma Merkezi** kuruldu. Bakanlığın **Yapay Zeka Destekli Dijital
Dönüşüm Strateji Belgesi ve Eylem Planı** hazır ama yayımlanmadı —
"beklemede" kaleminin ilk örneği. KKYDP yapay zeka tabanlı karar destek
sistemlerini destekliyor. İlk **Dijital Toprak Haritası** hazırlanıyor.
TAGEM'in zaten bir kurum dosyası var (sayı 04).

**Alan.** Hakemli kaynak görüntü işleme, hedefli ilaçlama, sulama ve
hastalık tespitinde gerçek ilerleme gösteriyor. **Rakamların neredeyse
tamamı satıcı bloglarından ve birbirini tutmuyor** — 34. kararın sebebi bu.

**Eleştirel katman.** Dijital uçurum, model yanlılığı (modeller büyük
mekanize çiftliklerde eğitiliyor, karışık ekim yapan küçük parsele yanlış
öneri veriyor), veri sahipliği ve maliyet — dördü de kaynaklı.

**Ölçülen engel.** FAO ve OECD'nin kullanılabilir bir **açık API'si
bulunamadı**; kurumsal katman için yayın sayfalarının izlenmesi gerekecek.
Tur 1'de her kaynağın erişilebilirliği tek tek ölçülecek (yumuşak 404'e
karşı durum koduna değil içerik türüne ve gövde uzunluğuna bakılarak).

## H · Yayın ve çalışma düzeni (Tur 4 sonunda eklendi · 16 Kasım 2026)

Tur 4'ün sonunda kullanıcı dağıtım önerisini geri çevirdi ("bu haliyle
yayımlayamayız. okura açılmasına daha var.") ve şunu söyledi: "tamamı
yazılınca açılsın, dala commit et, tur 5'e geç. açılış eşiği: tamamı.
paneli şimdi açabilirsin. sorun yok. commit konusunda sen karar ver."

| # | karar |
|---|---|
| 51 | **Açılış eşiği: tamamı.** Bölüm okura 30 başlığın hepsi yazılınca açılır. Bayrak `yayin.json` → `okura_acik`; `dart_uret.py` eksik başlıkla `true`'yu reddeder (çıkış 1). Kapalıyken okur rotaları derlemeden düşer, ana sayfa şeridi çizilmez |
| 52 | **Panel okura kapalıyken de canlıda.** Etiketleme, kuyruk ve "YZ Bölümü" sekmesi 16 Kasım 2026'da dağıtıldı (`./deploy.sh --hosting`) |
| 53 | **Dalda çalış, commit kararı Claude'da.** Her başlık `yapay-zeka-bolumu` dalına ayrı commit. GitHub'a gönderme ve her dağıtım yine kullanıcının açık onayıyla |
| 54 | **Kaynak toplamayı araştırma ajanları yapabilir; kayda giren her şeyi Claude yeniden sınar** (Tur 7). Ajan kaynakları geçici bir çalışma klasörüne indirir ve aday kayıt (`bNN_aday.json`) üretir; aday kilitli kayıt değildir. Kilitli kayda giren her alıntı `dogrula_alintilar.py`'den geçer; metne giren her "geçmiyor", "bulunamadı", "ölçülmemiş" iddiası belgenin kendisinde ayrıca aranır, sayfa bağlamı okunur. Ajanın notu kaynak değildir |
| 55 | **Yayına giden metin okur içindir** (kullanıcı, 17 Kasım 2026: "canlıya yansıyan metinler her zaman kullanıcı içindir"). Yazım notu, gerekçe, şerh ve süreç dili ("bu taramada bulunamadı", "belgede geçmiyor", "kipinde yazılmış", kaynak seçiminin gerekçesi) metne girmez; yeri kayıttaki `_not`, `_denetim`, `_reddedilen` alanları. Okurun bir rakamı doğru okuması için gereken çekince olgu olarak ve atıfla yazılır: "kurumun kendi açıklaması", "doğruluk oranı açıklanmadı", "… ölçen yayımlanmış bir değerlendirme bulunmuyor". Kapanış kalıbı: "Eksik olan ise **…**" |

## I · Metin üslubu (Tur 10 sonrası · 17 Kasım 2026)

Kullanıcı: "her metinde 'özet' adı altında bir bölüm var. buna gerek yok. bu
çok amatör gösteriyor dosyayı. hem de her metinde olduğu için çok tekdüze.
bu özet kısmını metinlere yedirmeliyiz. bir başlığı açınca metin direk
başlamalı. … metinlerin hiçbir yerinde §23, §25 vb. gibi bizim kendi
planlarımıza işaret eden şey, veya dosya hazırlanırken kullanılan prensipler,
referanslar, gerekçeler vs. bulunmamalı." Ayrıntılar soruyla netleşti.

| # | karar |
|---|---|
| 56 | **Metin doğrudan başlar; tekrar eden kalıp yok.** (a) Ayrı özet bloğu yok: özetin içeriği giriş paragrafına yedirilir; §1'in giriş paragrafı merkez sayfada da gösterilir, paylaşım açıklaması da ilk paragraftan. (b) Metinlerde § göndermesi ve başka başlığa işaret eden cümle yok. (c) Başlıklarda "Bu sayfa nasıl güncelleniyor" bölümü yok; güncelleme anlatımı merkez sayfada tek yerde. (d) "Eksik olan ise **…**" kapanış kalıbı yok (55'teki kapanış kalıbını kaldırır); eksik bilgi metnin akışında, her başlıkta farklı söylenir. (e) Hazırlık ilkesi ve gerekçe cümlesi yok; bilginin kaynağını söyleyen atıf kalır (yazar-yıl atıfları dâhil). (f) Okurun gördüğü arayüzde başlık numarası yok (üst etiket, harita karosu, önceki/sonraki, haber satırı, ana sayfa şeridi, paylaşım başlığı); sözlük ve kaynakça numara yerine başlığın kısa adını yazar. Editör paneli numarayı kullanmaya devam eder. `dogrula_bolumler.py` (a)-(d)'yi sınar |
