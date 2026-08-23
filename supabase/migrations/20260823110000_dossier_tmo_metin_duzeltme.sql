-- TMO dosyası — metin ve panel düzeltmeleri.
--
-- Üç düzeltme:
--   1. `bosluklar` ve `_kaynaklar` data.json'dan çıkarıldı. Tanıtım dosyasında
--      Veri Notları ve Kaynak Künyesi panelleri görünmüyor; okurun kaynağı
--      metnin sonundaki Kaynakça bölümü.
--   2. Metindeki `###` alt başlıkları kaldırıldı — DossierProse yalnızca
--      paragraf ve tablo çiziyor, `###` olduğu gibi yazıya düşüyordu.
--   3. Kaynakça maddeleri ayrı paragraflara bölündü; tek blokta yan yana
--      akıyorlardı.
--
-- Seed yeniden çalıştırılabilir: dosyayı upsert eder, bölümleri silip yazar.

-- Toprak Mahsulleri Ofisi — Ülke Dosyası · seed
--
-- ÜRETİLMİŞ DOSYA — elle düzenlemeyin.
-- Kaynak:  content/dossiers/tmo/
-- Üretim:  node content/dossiers/seed_dossier.mjs tmo
-- Tarih:   2026-08-22T23:00:41.123Z
--
-- Bölüm: 11 · TR ~2.988 kelime · EN ~3.855 kelime
-- Metindeki her rakam data.json'dan, data.json _raw/'dan geliyor.
--
-- Yeniden çalıştırılabilir: dosyayı günceller, bölümleri silip yeniden yazar.
-- Bölümler upsert değil sil-yaz, çünkü bir revizyonda bölüm sayısı azalırsa
-- upsert eski fazlalığı geride bırakırdı.


insert into public.country_dossiers
  (slug, name_tr, name_en, iso3, tur, kurulus_belgesi, edition,
   thesis_tr, thesis_en, theme, data, charts,
   cover_url, cover_credit, video_url, status, starts_at, ends_at, published_at)
values (
  'tmo',
  'Toprak Mahsulleri Ofisi',
  'Turkish Grain Board (TMO)',
  null,
  'kurum',
  $dsr$3491 sayılı Kanun · RG 13.07.1938$dsr$,
  1,
  $dsr$Buğdaydan afyona: Türkiye tarımının en eski ve en geniş yetkili kurumu.$dsr$,
  $dsr$From wheat to opium: the oldest and most broadly mandated institution in Turkish agriculture.$dsr$,
  $dsr${"_dosya":"Toprak Mahsulleri Ofisi — Kurum Dosyası · tasarım künyesi","_amac":"Evrak görsel dilinin bu dosyadaki uygulaması. Palet DİZİ paletidir ve dosyadan dosyaya değişmez; burada yalnızca kümenin vurgusu seçiliyor. Ülke Dosyası’nda her ülke kendi paletini alıyordu — haftalık ritimde o model çöker ve dizi kimliğini yok eder.","_kontrast_betigi":"content/dossiers/_ortak/kontrast.py","tez_cumlesi":{"tr":"Buğdaydan afyona: Türkiye tarımının en eski ve en geniş yetkili kurumu.","en":"From wheat to opium: the oldest and most broadly mandated institution in Turkish agriculture.","_ad":"Bu alan şemada `thesis_tr` ama artık bir TEZ değil, tanıtım cümlesi. Kurum Dosyası bir iddia kurmuyor; kapakta, ana sayfa kartında ve paylaşım kartında görünen bu satır kurumu tanıtıyor.","_eski":"Önceki hâli bir iddia cümlesiydi (\"kendi kanunundan öğrenmedi\"). Dosya tanıtım tarzına geçince kaldırıldı — bkz. CLAUDE.md §8.2."},"kume":{"ad":"Kamu gücü","gerekce":"TMO fiyat açıklayarak piyasaya doğrudan müdahale eden bir KİT. Arşivde bu vurguyu taşıyan ilk dosya."},"palet":{"ad":"Evrak — kağıt gövde","kaynak_fikir":"Kurumun manzarası yok; maddi karşılığı kağıttır. Kanun, tutanak, rapor, makbuz. Zemin arşiv kağıdı: haberin sıcak kremine (#F6F1E7) karşı soğuk gri.","mod":"KOYU KAPAK → KAĞIT GÖVDE. Dosya sayfası sistem açık/koyu tercihini izlemez.","mod_gerekcesi":"Fiziksel dosyanın kendisi: dışı mukavva kapak, içi kağıt. Okur ana sayfadan girip tam ekran koyu kapakla karşılaşıyor, kaydırınca kağıda iniyor.","sayfa":{"zemin":{"hex":"#E3E7E5","rol":"Sayfa zemini — arşiv kağıdı"},"yuzey":{"hex":"#F0F2F0","rol":"Kart, tablo, kayıt bloğu"},"murekkep":{"hex":"#15191A","rol":"Gövde metni","kontrast_zemin":14.19,"kontrast_yuzey":15.74},"sessiz":{"hex":"#575F61","rol":"Meta, kaynak satırı","kontrast_zemin":5.23,"kontrast_yuzey":5.81},"vurgu":{"hex":"#8E2B24","rol":"Kamu gücü — rakamlar, başlık vurguları","kontrast_zemin":6.67,"kontrast_yuzey":7.4},"ikincil":{"hex":"#575F61","rol":"Karşılaştırma ikinci serisi — kasıtlı olarak nötr","kontrast_zemin":5.23},"cizgi":{"hex":"#C0C6C3","rol":"SADECE dekoratif ayırıcı","kontrast_zemin":1.39,"_uyari":"3:1 altında. Anlam taşıyan hiçbir yerde kullanılamaz."},"cizgiVurgu":{"hex":"#767E7C","rol":"Eksen, ızgara, odak halkası","kontrast_zemin":3.34,"kontrast_yuzey":3.7}},"kapak":{"_amac":"Kapak gövdeden AYRI: dışı koyu mukavva, içi kağıt. Bu blok yoksa kapak gövde renklerini kullanır (ülke dosyalarında öyle).","zemin":{"hex":"#131718","rol":"Kapak zemini — mukavva"},"murekkep":{"hex":"#F0F2F0","rol":"Kurum adı, tez cümlesi","kontrast_zemin":16.04},"sessiz":{"hex":"#98A1A2","rol":"Belge satırı, pencere rozeti","kontrast_zemin":6.84},"vurgu":{"hex":"#E88079","rol":"Kamu gücü — kapaktaki karşılığı","kontrast_zemin":6.7}},"serit":{"_amac":"Ana sayfa bandındaki kurum kartı sayfanın içinde yaşıyor; krem zemin üstünde çiziliyor.","murekkep":{"hex":"#15191A"},"vurguKoyu":{"hex":"#8E2B24","rol":"Kağıt vurgusunun krem zemindeki karşılığı"},"ikincilKoyu":{"hex":"#575F61"}},"renk_korlugu_notu":"Vurgu ile ikincil arasındaki fark parlaklıkta (6,67 ve 5,23) ve ikincil zaten nötr gri — ikili çubukta seriler renkle BİRLİKTE biçimle de ayrılıyor. Mevzuat zincirinde belge türü yalnızca biçimle ayrılır; renk orada sadece yürürlükte olup olmadığını söyler."},"motif":{"ad":"Cetvel çizgisi","tanim":"Defter ve resmî evrak kağıdının marj rayı: solda dikey ray, aralarda ince yatay kural çizgileri.","gerekce":"Polder Hollanda’nın geometrisiydi; kurumun geometrisi kağıdın kendisidir. Doğrusal olduğu için düşük opaklıkta metni bozmuyor — ama polderden farklı olarak İŞ YAPIYOR: bölüm numarası ve kayıt bloklarının girintisi bu raya hizalanıyor.","uygulama":{"opaklik":"%8","renk":"cizgiVurgu #767E7C üzerine opaklık","bicim":"Vektör (CustomPainter) — telif yok, ölçeklenir, dosya boyutu sıfır","yerlesim":"Bölüm ayırıcılarında ve kapak altı geçiş bandında. Gövde metninin ARKASINDA kullanılmaz.","aralik_notu":"Izgara aralığı 24 px’in altına inmeyecek."}},"kapak":{"yon":"Kuruluş belgesinden kurulan tipografik kapak","gerekce":"Kurum fotoğrafı ve logosu lisanslı değil. Kapak kurumun kuruluş belgesinden kuruluyor; bu bir zorunluluk olarak başlayıp dizinin karakteri hâline geliyor. Tipografik kapak ASIL tasarım, yedek değil.","sinir":"Kapak bir belgeyi ALINTILAR, TAKLİT ETMEZ. Resmî Gazete anteti, mühür, arma veya kurum logosu yeniden üretilmez. Kapakta her zaman seri etiketi ve sayı numarası bulunur; ekran görüntüsü bağlamından koparıldığında bile gerçek bir resmî belge sanılamaz.","tipografi_katmani":{"ust_satir":"KURUM DOSYASI · 01 · KAMU GÜCÜ","baslik":"TOPRAK MAHSULLERİ OFİSİ","belge_satiri":"3491 sayılı Kanun · RG 13.07.1938","alt_satir":"tez_cumlesi.tr","veri_rozeti":"Sermaye dört yılda beş kez yazıldı"},"gorsel":"Yok ve aranmıyor. Sayfa tipografik kapakla tam çalışıyor."},"_yasak":["Kurum logosu, resmî arma, mühür veya antet taklidi","Resmî Gazete sayfasının tıpkıbasım görünümü","Stok \"mutlu çiftçi\" fotoğrafı","Kurumu simgeleyen dekoratif ikon seti"]}$dsr$::jsonb,
  $dsr${"_dosya":"Toprak Mahsulleri Ofisi — Kurum Dosyası · kilitli veri sayfası","_uretim_tarihi":"2026-08-21T21:42:21.677687+00:00","_kural":"Buradaki hiçbir rakam bellekten yazılmadı. Her kalemin kaynak alanı, _raw/ altındaki dosyayı ve yerini gösterir. Kaynağı olmayan kalem bu dosyaya girmez; girmesi gereken ama bulunamayan kalem \"bosluklar\" bloğuna yazılır ve sayfada Veri Notları panelinde açıkta gösterilir.","tez":{"cumle":"TMO ne alacağını, kaça alacağını ve ne kadar sermayesi olacağını hiçbir zaman kendi kanunundan öğrenmedi.","dayanak":["1938 kanunu buğdayı \"Bakanlar Kurulu Kararı ile tespit edilecek yerlerde ve tayin edilecek fiyatlarla\" aldırıyor: kanun kabı kuruyor, içini karar dolduruyor.","Ürün yetkisi 1939–41 arasında dört ayrı kararla genişledi; savaşta tarım dışına taştı.","Sermaye 2021–2025 arasında beş kez Cumhurbaşkanı kararıyla yeniden belirlendi.","2025 kuraklık yılında alım fiyatı piyasanın üzerinde belirlendi ve buğday alımı programın %54 üzerine çıktı; aynı yıl arpada tersi oldu."],"sayi_manseti":{"deger":5,"birim":"sermaye kararı","donem":"2021–2025","ifade":"Sermaye dört yılda beş kez yeniden yazıldı","kaynak":"ana_statu.pdf · dipnot 1–4 ve md. 4/4"}},"kunye":{"ad":"Toprak Mahsulleri Ofisi","kisa_ad":"TMO","kurulus_yili":{"deger":1938,"kaynak":"kurum_hakkinda.pdf"},"kurulus_belgesi":{"tur":"Kanun","no":3491,"kabul":"1938-06-24","rg_tarih":"1938-07-13","rg_sayi":null,"_rg_sayi_notu":"RG sayısı hiçbir kaynakta geçmiyor; künyede tarih kullanılıyor.","kaynak":"kurum_hakkinda.pdf"},"hukuki_statu":{"deger":"İktisadi Devlet Teşekkülü (İDT)","kaynak":"ana_statu.pdf · MADDE 4/1","alinti":"TMO; tüzel kişiliğe sahip, faaliyetlerinde özerk ve sorumluluğu sermayesiyle sınırlı iktisadi devlet teşekkülüdür."},"_statu_tutarsizligi":"Aynı Ana Statü’nün MADDE 1’i ve MADDE 3(i) tanımı kurumu \"Toprak Mahsulleri Ofisi Anonim Şirketi\" diye anıyor. Hukuki bünyeyi kuran MADDE 4 ve belgenin bütün dipnotları ise \"iktisadi devlet teşekkülü\" / \"kamu iktisadi teşebbüsü\" diyor. Belirleyici olan MADDE 4. Bu tutarsızlık metne İDDİA olarak değil, belgedeki hâliyle aktarılır.","bagli_makam":{"deger":"Tarım ve Orman Bakanlığı — ilgili kuruluş","kaynak":"ana_statu.pdf · MADDE 4/5"},"merkez":{"deger":"Ankara","kaynak":"ana_statu.pdf · MADDE 4/3"},"denetim_mercii":{"deger":["Türkiye Büyük Millet Meclisi","Sayıştay"],"kaynak":"ana_statu.pdf · MADDE 4/6"},"faaliyet_alani":{"hububat":["buğday","arpa","çavdar","tritikale","yulaf","mısır","çeltik"],"bakliyat":["kuru fasulye","mercimek","nohut"],"hashas":["haşhaş kapsülü","haşhaş tohumu"],"kaynak":"ana_statu.pdf · MADDE 3"},"tekel":{"deger":"Afyon alkaloidleri — piyasada tekel","tesis":"Afyon Alkaloidleri Fabrikası İşletme Müdürlüğü, Bolvadin / Afyonkarahisar","kaynak":"faaliyet_2025.pdf · s. 283"}},"mevzuat_zinciri":{"_amac":"Kuruluş belgesinden bugüne yürürlükteki metinler. Grafik tipi: mevzuat_zinciri.","dugumler":[{"tur":"Kanun","no":2056,"ad":"Ziraat Bankasını buğday alımıyla görevlendiren Kanun","kabul":"1932-07-03","rg_tarih":"1932-07-10","rg_sayi":2146,"mukerrer":false,"yururlukte":false,"kaynak":"kurum_hakkinda.pdf"},{"tur":"Kanun","no":2303,"ad":"Ziraat Bankasına hububat muhafaza tesisleri kurma görevi veren Kanun","kabul":"1933-06-11","rg_tarih":null,"rg_sayi":null,"mukerrer":false,"yururlukte":false,"kaynak":"kurum_hakkinda.pdf"},{"tur":"Kanun","no":3491,"ad":"Toprak Mahsulleri Ofisi Kanunu","kabul":"1938-06-24","rg_tarih":"1938-07-13","rg_sayi":null,"mukerrer":false,"yururlukte":true,"kaynak":"kurum_hakkinda.pdf"},{"tur":"KHK","no":233,"ad":"Kamu İktisadi Teşebbüsleri Hakkında KHK","kabul":"1984-06-08","rg_tarih":"1984-06-18","rg_sayi":18435,"mukerrer":true,"yururlukte":true,"kaynak":"rg_ikincil"},{"tur":"Ana Statü","no":null,"ad":"Toprak Mahsulleri Ofisi Ana Statüsü (mülga)","kabul":null,"rg_tarih":"1984-12-11","rg_sayi":18602,"mukerrer":false,"yururlukte":false,"kaynak":"ana_statu.pdf · MADDE 27"},{"tur":"KHK","no":399,"ad":"KİT Personel Rejiminin Düzenlenmesi ve 233 sayılı KHK’nın Bazı Maddelerinin Yürürlükten Kaldırılmasına Dair KHK","kabul":"1990-01-22","rg_tarih":"1990-01-29","rg_sayi":20417,"mukerrer":true,"yururlukte":true,"kaynak":"rg_ikincil"},{"tur":"CBK","no":4,"ad":"Bakanlıklara Bağlı, İlgili, İlişkili Kurum ve Kuruluşlar ile Diğer Kurum ve Kuruluşların Teşkilatı Hakkında CBK","kabul":null,"rg_tarih":"2018-07-15","rg_sayi":30479,"mukerrer":false,"yururlukte":true,"kaynak":"rg_ikincil"},{"tur":"CB Kararı","no":4518,"ad":"Toprak Mahsulleri Ofisi Genel Müdürlüğü Ana Statüsü","kabul":null,"rg_tarih":"2021-09-30","rg_sayi":null,"mukerrer":false,"yururlukte":true,"kaynak":"ana_statu.pdf · rg_ikincil"}],"_not":"Zincir 1938’de değil 1932’de başlıyor: Ofis kurulmadan altı yıl önce aynı iş Ziraat Bankası’na kanunla verilmişti."},"sermaye":{"_amac":"Tezin en sert kanıtı: dört yılda beş kez yeniden belirlenmiş nominal sermaye.","birim":"milyar TL · nominal","kaynak":"ana_statu.pdf · MADDE 4/4 ve dipnot 1–4","seri":[{"deger":2.55,"tarih":"2021-09-30","karar":"Ana Statü ana metni","karar_no":4518},{"deger":12.55,"tarih":"2022-07-27","karar":"Cumhurbaşkanı Kararı","karar_no":5893},{"deger":52.55,"tarih":"2023-08-07","karar":"Cumhurbaşkanı Kararı","karar_no":7479},{"deger":124.55,"tarih":"2023-12-22","karar":"Cumhurbaşkanı Kararı","karar_no":7974},{"deger":94.55,"tarih":"2025-04-17","karar":"Cumhurbaşkanı Kararı","karar_no":9730,"_not":"Artış değil AZALIŞ — seride tek düşüş."}]},"urun_yetkisi":{"_amac":"Yetki alanı kanunla değil kararla genişledi. Grafik tipi: zaman_cizelgesi.","kaynak":"kurum_hakkinda.pdf","olaylar":[{"tarih":"1938-07-13","olay":"Kuruluş — buğday ve uyuşturucu madde tekeli"},{"tarih":"1939-10-27","olay":"Arpa ve yulaf"},{"tarih":"1940-11-28","olay":"Çavdar"},{"tarih":"1941-04-25","olay":"Mısır"},{"tarih":"1941-08-13","olay":"Kuru fasulye ve pirinç"}],"savas_donemi":{"_aciklama":"İkinci Dünya Savaşı yıllarında ve sonrasında liste tarımın dışına taştı.","kalemler":["benzin","otomobil lastiği","et kavurması","margarin","kahve","nohut","akdarı","fasulye","mercimek","bakla","börülce","susam","yağlı tohum","kasaplık hayvan","balık"]},"bugun":{"deger":"Cumhurbaşkanı Kararları ile hububat ve bakliyat dışındaki tarım ürünlerinde verilen görevler","kaynak":"faaliyet_2025.pdf · s. 283"}},"alim_2025":{"kaynak":"faaliyet_2025.pdf · Tablo 29","toplam":{"miktar":{"deger":6150332,"birim":"ton"},"odeme":{"deger":81624184,"birim":"bin TL"}},"ticari_mallar":{"miktar":{"deger":6142994,"birim":"ton"},"odeme":{"deger":80904779,"birim":"bin TL"}},"ic_dis":{"ic_pay":{"deger":86,"birim":"%"},"dis_pay":{"deger":14,"birim":"%"}},"program_gerceklesme":[{"urun":"Buğday","program":2500000,"gerceklesen":3841000,"birim":"ton"},{"urun":"Arpa","program":1000000,"gerceklesen":171000,"birim":"ton"}],"fiyatlar":[{"urun":"Buğday","fiyat":13500,"birim":"TL/ton"},{"urun":"Arpa","fiyat":11000,"birim":"TL/ton"},{"urun":"Mısır — 1. sınıf","fiyat":11400,"birim":"TL/ton"},{"urun":"Mısır — 2. sınıf","fiyat":11300,"birim":"TL/ton"}]},"kuraklik_2025":{"kaynak":"faaliyet_2025.pdf · s. 27 — rapor kaynak olarak MGM’yi gösteriyor","su_yili":"1 Ekim 2024 – 30 Eylül 2025","yagis":{"deger":422.5,"birim":"mm"},"normal_1991_2020":{"deger":573.4,"birim":"mm"},"onceki_yil":{"deger":597,"birim":"mm"},"_rapor_ifadesi":"Rapor bunu \"son 52 yılın en düşük seviyesi\" olarak niteliyor.","uretim_kaybi":[{"urun":"Buğday","kayip":13.7,"birim":"%"},{"urun":"Arpa","kayip":25.9,"birim":"%"}],"_kurumun_aciklamasi":"Buğdayda alım fiyatı iç ve dış piyasa fiyatlarının üzerinde belirlendi; tüccar ve sanayici yüksek finansman maliyeti nedeniyle çekimser kaldı ve üretici ürününü Ofis’e yöneltti. Arpada piyasa fiyatı üretici lehine seyredince ürün Ofis’e gelmedi. BU, KURUMUN KENDİ AÇIKLAMASIDIR; 11. bölümde bağımsız kayıtlarla karşılaştırılır."},"mali_seri":{"_amac":"Kurumun beş yıllık mali iskeleti. Tezin ikinci ayağı: sermaye ve öz kaynak kararla yazılıyor, sonuç zararla kapanıyor.","kaynak":"faaliyet_2025.pdf · Tablo 1 — Kuruluşumuz Hakkında Toplu Bilgiler (2021-2025)","kalemler":[{"ad":"Sermaye","birim":"milyon TL","degerler":[{"yil":2021,"deger":2550},{"yil":2022,"deger":12550},{"yil":2023,"deger":124550},{"yil":2024,"deger":124550},{"yil":2025,"deger":94550}]},{"ad":"Ödenmiş sermaye","birim":"milyon TL","degerler":[{"yil":2021,"deger":2550},{"yil":2022,"deger":12550},{"yil":2023,"deger":52550},{"yil":2024,"deger":124460},{"yil":2025,"deger":94550}]},{"ad":"Öz kaynaklar","birim":"milyon TL","degerler":[{"yil":2021,"deger":4375},{"yil":2022,"deger":14638},{"yil":2023,"deger":54882},{"yil":2024,"deger":165693},{"yil":2025,"deger":132170}]},{"ad":"Yabancı kaynaklar","birim":"milyon TL","degerler":[{"yil":2021,"deger":13900},{"yil":2022,"deger":59523},{"yil":2023,"deger":133876},{"yil":2024,"deger":67455},{"yil":2025,"deger":79556}]},{"ad":"Finansman giderleri","birim":"milyon TL","degerler":[{"yil":2021,"deger":454},{"yil":2022,"deger":3232},{"yil":2023,"deger":14521},{"yil":2024,"deger":19128},{"yil":2025,"deger":4156}]},{"ad":"Faaliyet kârı","birim":"milyon TL","degerler":[{"yil":2021,"deger":767},{"yil":2022,"deger":2310},{"yil":2023,"deger":2482},{"yil":2024,"deger":348},{"yil":2025,"deger":-3894}]},{"ad":"Dönem kârı","birim":"milyon TL","degerler":[{"yil":2021,"deger":102},{"yil":2022,"deger":384},{"yil":2023,"deger":675},{"yil":2024,"deger":-12096},{"yil":2025,"deger":-3677}]}],"_not":"Kayıtlı sermaye ile ödenmiş sermaye 2023 ve 2024’te ayrışıyor: 2023’te kayıtlı 124.550, ödenmiş 52.550 milyon TL."},"hazine_iliskisi":{"_amac":"Zararın nasıl karşılandığı. 9. bölümün omurgası.","gorevlendirme_bedeli":{"deger":33535639613.09,"birim":"TL","aciklama":"Hazine ve Maliye Bakanlığından görevlendirme bedeli alacakları karşılığı nakden yapılan tahsilat. \"İlgili görevlendirme bedelleri kesinleştiğinde kapatılacaktır.\"","kaynak":"faaliyet_2025.pdf · I.C.1 Ortaklara Borçlar"},"donem_zarari_2025":{"deger":3677187124.8,"birim":"TL","kaynak":"faaliyet_2025.pdf · III.F Dönem Net Kârı (Zararı)"}},"denetim":{"_amac":"Kurumun kime, ne zaman hesap verdiği. 10. bölüm.","mercii":["Türkiye Büyük Millet Meclisi","Sayıştay"],"mercii_kaynak":"ana_statu.pdf · MADDE 4/6","kit_komisyonu":{"program":"Kamu İktisadi Teşebbüslerinin 2023-2024 Yılı Hesaplarına İlişkin Komisyon Denetim Programı","gorusulecek_hesap_yillari":[2023,2024],"tarih":"2026-10-21","gun":"Çarşamba","saat":"14.30","sira":"Programın ilk sırası","ayni_oturum":["Türkiye Şeker Fabrikaları AŞ","Çay İşletmeleri Genel Müdürlüğü"],"programdaki_kurulus_sayisi":37,"kaynak":"kit_komisyonu_programi.pdf · TBMM","_not":"Program belgesi 19 Ağustos 2026 tarihli. 2023 hesaplarının görüşülmesi 2026 sonuna kalıyor."}},"sektordeki_yer":{"_amac":"TMO’nun Türkiye tarımındaki ağırlığı. Tek başına alım miktarı bir şey söylemiyor; üretime oranı söylüyor.","kaynak":"faaliyet_2025.pdf · Tablo 3 (üretim) ve Tablo 29 (alım)","turkiye_bugday_uretimi":{"birim":"milyon ton","_kaynak_notu":"Rapor bu satırı TÜİK’e dayandırıyor; 2025/26 değeri tahmin (*) işaretli.","seri":[{"yil":"2021/22","deger":17.7},{"yil":"2022/23","deger":19.8},{"yil":"2023/24","deger":22},{"yil":"2024/25","deger":20.8},{"yil":"2025/26","deger":17.95}]},"tmo_bugday_payi_2025":{"deger":21.4,"birim":"%","hesap":"3.841.000 ton alım ÷ 17.950.000 ton üretim","_uyari":"Pay, alım yılı ile pazarlama yılının birebir örtüşmediği kabulüyle hesaplandı; üretim değeri tahmindir. Yuvarlanarak \"beşte bir\" denir."},"stok_degeri":{"birim":"bin TL","kaynak":"faaliyet_2025.pdf · Tablo 1","seri":[{"yil":2021,"deger":10996775},{"yil":2022,"deger":54759156},{"yil":2023,"deger":147688217},{"yil":2024,"deger":169051451},{"yil":2025,"deger":138235987}]},"alim_primi_2024":{"bugday":1750,"arpa":750,"birim":"TL/ton","aciklama":"Açıklanan alım fiyatına EK olarak Bakanlıkça verilen TMO alım primi desteği.","kaynak":"faaliyet_2025.pdf · s. 27"}},"dunya_karsiligi":{"_amac":"12. bölüm. Karşılaştırma ölçüsü tek: devlet ulusal üretimin ne kadarını satın alıyor. Kurum adları değil, mekanizmalar karşılaştırılıyor.","modeller":[{"ulke":"Türkiye","kurum":"Toprak Mahsulleri Ofisi","alim":3.841,"uretim":17.95,"pay":21.4,"birim":"milyon ton","fiyat":"13.500 TL/ton (2025 buğday)","mekanizma":"Kurum piyasadan alır; fiyatı Ana Statü uyarınca kendisi belirler.","kaynak":"faaliyet_2025.pdf"},{"ulke":"Hindistan","kurum":"Food Corporation of India ve eyalet kurumları","alim":29.7,"uretim":115.43,"pay":25.7,"birim":"milyon ton","fiyat":"2.425 rupi/kental (2025-26 MSP)","mekanizma":"Asgari Destek Fiyatı (MSP) üzerinden alım. 2025-26 sezonu hedefi 31 milyon tondu; gerçekleşen 29 milyon tonun üzerinde bildirildi.","kaynak":"ikincil basın kaynakları — birincil FCI verisiyle doğrulanmadı"},{"ulke":"Avrupa Birliği","kurum":"Üye devlet müdahale kurumları","alim":3,"uretim":144,"pay":2.1,"birim":"milyon ton","fiyat":"101,31 €/ton müdahale fiyatı","mekanizma":"Kamu müdahale alımı 1308/2013 sayılı Ortak Piyasa Düzeni tüzüğüne dayanıyor; ekmeklik buğdayda alım 3 milyon tonla SINIRLI, bu tavanın üzerinde alım ihale yoluyla yapılıyor.","kaynak":"EUR-Lex 1308/2013 ve 1370/2013; AB üretimi faaliyet_2025.pdf Tablo 3"},{"ulke":"ABD","kurum":"Commodity Credit Corporation","alim":null,"uretim":54,"pay":null,"birim":"milyon ton","fiyat":"Referans fiyat ve kredi oranı — alım fiyatı değil","mekanizma":"Devlet rutin olarak tahıl SATIN ALMIYOR. Pazarlama kredisi (nonrecourse marketing assistance loan) ile üretici ürününü teminat gösteriyor ve isterse krediyi ürünü CCC’ye teslim ederek kapatabiliyor; gelir desteği ARC ve PLC programlarıyla ödeme olarak veriliyor.","kaynak":"USDA FSA ve CRS R45165; ABD üretimi faaliyet_2025.pdf Tablo 3"}],"_okuma":"Dört model iki kümeye ayrılıyor: Türkiye ve Hindistan üretimin beşte biriyle dörtte biri arasında ALIM yapıyor; AB tavanlı ve piyasanın çok altında bir fiyatla yalnızca kriz sigortası tutuyor; ABD hiç almıyor, doğrudan ödeme yapıyor."},"tarihce":{"_amac":"Kurumun 1938 öncesi kökü ve 1938 sonrası yetki genişlemesi. 3. ve 7. bölüm.","kaynak":"kurum_hakkinda.pdf","oncesi":{"baglam":"Birinci Dünya Savaşı sonrasında sanayi tesislerinin büyük ölçüde yok olması pek çok ülkede tarıma yönelmeyi zorunlu kıldı; üretim artınca üretici ülkelerde buğday stokları büyüdü, dış piyasada rekabet ve fiyat düşüşü başladı. Özellikle 1928 sonrasında birçok ülkede buğday fiyatları hızla düştü.","olaylar":[{"yil":1932,"olay":"2056 sayılı Kanun ile Ziraat Bankası buğday alımıyla görevlendirildi"},{"yil":1933,"olay":"2303 sayılı Kanun ile Ziraat Bankasına hububat muhafaza tesisleri kurma görevi verildi"},{"yil":"1932-1933","olay":"Ziraat Bankası çoğu Orta Anadolu’da olmak üzere alım merkezleri açtı"},{"yil":1938,"olay":"Buğday Masası Şefliği’nin işleri TMO’ya devredildi"}]},"modern_gorevler":[{"yil":"2006-2009","urun":"Kabuklu fındık"},{"yil":2017,"urun":"Kabuklu fındıkta yeniden görevlendirme (Nisan)"},{"yil":2017,"urun":"Çekirdeksiz kuru üzüm — tarihinde ilk defa"},{"yil":2019,"urun":"Kuru incir"},{"yil":2020,"urun":"Kuru kayısı"},{"yil":2021,"urun":"Kuru soğan ve yemeklik patates — üreticinin piyasaya arz edemediği ürünler alınıp ihtiyaç sahiplerine ücretsiz dağıtıldı"}],"kenevir":"İlaç Etken Maddesi Üretimi Amaçlı Kenevir Yetiştiriciliği ve Kontrolü görevi de TMO’ya verildi."},"kapasite":{"_amac":"Kurumun fiziki ağırlığı ve piyasa altyapısındaki rolü. 8. bölüm.","kaynak":"kurum_hakkinda.pdf","tmo_depolama":{"deger":4,"birim":"milyon ton","detay":"Yaklaşık 500 bin tonu limanlarda."},"lisansli_depo":{"2016":{"deger":805,"birim":"bin ton"},"bugun":{"deger":14.2,"birim":"milyon ton"},"artis_kati":17.6,"sebep":"TMO’nun 2016’dan itibaren lisanslı depolara teslim edilen ürünlere alım garantisi vermesi ve uzun süreli kira garantili depo yapım projesini başlatması."},"elus":"TMO, lisanslı depolara teslim edilen ürünleri temsil eden Elektronik Ürün Senetlerinin (ELÜS) alımını yapıyor."},"_panel_notu":"Veri Notları ve Kaynak Künyesi panelleri BİLEREK boş: tanıtım dosyasında yazarın eksikleri okura gösterilmiyor. Okurun kaynağı metnin sonundaki Kaynakça bölümü. Doğrulanmayanlar _raw/README.md’de duruyor."}$dsr$::jsonb,
  $dsr${"urun_yetkisi_cizelge":{"tur":"zaman_cizelgesi","baslik":{"tr":"Yetki alanı kanunla değil kararla genişledi","en":"The mandate widened by decree, not by law"},"olaylar":[{"yil":1938,"yil_ek":{"tr":"13 Temmuz","en":"13 July"},"baslik":{"tr":"Kuruluş: buğday ve uyuşturucu madde tekeli","en":"Founding: wheat and the narcotics monopoly"},"aciklama":{"tr":"3491 sayılı Kanun. Alım yeri ve fiyatı Bakanlar Kurulu kararına bırakıldı.","en":"Law 3491. Where and at what price to buy was left to cabinet decision."}},{"yil":1939,"yil_ek":{"tr":"27 Ekim","en":"27 Oct"},"baslik":{"tr":"Arpa ve yulaf","en":"Barley and oats"},"aciklama":{"tr":"","en":""}},{"yil":1940,"yil_ek":{"tr":"28 Kasım","en":"28 Nov"},"baslik":{"tr":"Çavdar","en":"Rye"},"aciklama":{"tr":"","en":""}},{"yil":1941,"yil_ek":{"tr":"25 Nisan","en":"25 Apr"},"baslik":{"tr":"Mısır","en":"Maize"},"aciklama":{"tr":"","en":""}},{"yil":1941,"yil_ek":{"tr":"13 Ağustos","en":"13 Aug"},"baslik":{"tr":"Kuru fasulye ve pirinç","en":"Dry beans and rice"},"aciklama":{"tr":"Savaş yıllarında liste tarımı aştı: benzin, otomobil lastiği, kahve, margarin, et kavurması.","en":"During the war the list outgrew agriculture: petrol, tyres, coffee, margarine, tinned meat."}},{"yil":2017,"baslik":{"tr":"Kuru üzüm — tarihinde ilk defa","en":"Raisins — for the first time"},"aciklama":{"tr":"Aynı yıl kabuklu fındıkta yeniden görevlendirme.","en":"The same year, hazelnuts were assigned again."}},{"yil":2019,"baslik":{"tr":"Kuru incir","en":"Dried figs"},"aciklama":{"tr":"","en":""}},{"yil":2020,"baslik":{"tr":"Kuru kayısı","en":"Dried apricots"},"aciklama":{"tr":"","en":""}},{"yil":2021,"baslik":{"tr":"Kuru soğan ve yemeklik patates","en":"Onions and table potatoes"},"aciklama":{"tr":"Üreticinin piyasaya arz edemediği ürünler alınıp ihtiyaç sahiplerine ücretsiz dağıtıldı.","en":"Crops producers could not place on the market were bought and distributed free of charge."}}]},"alim_program":{"tur":"ikili_cubuk","baslik":{"tr":"2025: kuraklık yılında buğday hedefi aşıldı, arpa hedefi tutmadı","en":"2025: the wheat target overshot in a drought year, the barley target missed"},"seriler":[{"ad":{"tr":"Program","en":"Programmed"},"rol":"sessiz"},{"ad":{"tr":"Gerçekleşen","en":"Actual"},"rol":"vurgu"}],"satirlar":[{"etiket":{"tr":"Buğday","en":"Wheat"},"birim":{"tr":"milyon ton","en":"m tonnes"},"yil":2025,"ondalik":2,"degerler":[2500000,3841000],"bolen":1000000,"rozet":{"tr":"%54 üzerinde","en":"54% over"}},{"etiket":{"tr":"Arpa","en":"Barley"},"birim":{"tr":"milyon ton","en":"m tonnes"},"yil":2025,"ondalik":2,"degerler":[1000000,171000],"bolen":1000000,"rozet":{"tr":"%83 altında","en":"83% under"}}]},"dunya_pay":{"tur":"siralama","baslik":{"tr":"Devlet ulusal buğday üretiminin ne kadarını satın alıyor","en":"How much of the national wheat crop the state buys"},"not":{"tr":"ABD listede yok: orada devlet rutin olarak tahıl satın almıyor, destek doğrudan ödeme olarak veriliyor.","en":"The United States is absent: there the state does not routinely buy grain; support is paid directly instead."},"birim":{"tr":"% · ulusal üretim payı","en":"% of national production"},"ondalik":1,"satirlar":[{"etiket":{"tr":"Hindistan · FCI ve eyalet kurumları","en":"India · FCI and state agencies"},"deger":25.7},{"etiket":{"tr":"Türkiye · TMO","en":"Türkiye · TMO"},"deger":21.4,"rol":"vurgu"},{"etiket":{"tr":"Avrupa Birliği · müdahale alımı tavanı","en":"European Union · intervention ceiling"},"deger":2.1}]}}$dsr$::jsonb,
  null,
  null,
  null,
  'published',
  now(),
  (now() + interval '14 days'),
  now()
)
on conflict (slug) do update set
  name_tr      = excluded.name_tr,
  name_en      = excluded.name_en,
  iso3            = excluded.iso3,
  tur             = excluded.tur,
  kurulus_belgesi = excluded.kurulus_belgesi,
  edition         = excluded.edition,
  thesis_tr    = excluded.thesis_tr,
  thesis_en    = excluded.thesis_en,
  theme        = excluded.theme,
  data         = excluded.data,
  charts       = excluded.charts,
  cover_url    = excluded.cover_url,
  cover_credit = excluded.cover_credit,
  video_url    = excluded.video_url,
  status       = excluded.status,
  -- Pencere KASITLI olarak korunuyor. Yayındaki bir dosyanın metninde yazım
  -- hatası düzeltmek için seed'i yeniden çalıştırmak, 28 günlük sayacı
  -- sıfırlamamalı. Pencereyi bilerek kaydırmak istiyorsanız elle update.
  starts_at    = coalesce(country_dossiers.starts_at,    excluded.starts_at),
  ends_at      = coalesce(country_dossiers.ends_at,      excluded.ends_at),
  published_at = coalesce(country_dossiers.published_at, excluded.published_at),
  updated_at   = now();

delete from public.dossier_sections
 where dossier_id = (select id from public.country_dossiers where slug = 'tmo');

insert into public.dossier_sections
  (dossier_id, ord, title_tr, title_en, body_tr, body_en, chart_keys, tur, gorsel)
select d.id, v.ord, v.title_tr, v.title_en, v.body_tr, v.body_en, v.chart_keys, v.tur, v.gorsel
from public.country_dossiers d
cross join (values
  (1::integer, $dsr$TMO nedir$dsr$, $dsr$What TMO is$dsr$, $dsr$Ekmeğin fiyatı, un fabrikasının maliyeti, çiftçinin hasat sonrası eline geçen para —
bunların hepsinin ucunda, çoğu zaman görünmeden, aynı kurum durur: Toprak Mahsulleri
Ofisi.

TMO bir devlet kuruluşu. Sermayesinin tamamı devlete ait, Tarım ve Orman Bakanlığı'na
bağlı, merkezi Ankara'da. Yaptığı iş tek cümleyle şu: hububat ve bakliyat piyasasında
fiyat dengesini korumak.

Bunu iki yönlü yapar. Hasat mevsiminde ürün bollaşıp fiyat çiftçinin aleyhine düşerse,
TMO alıcı olarak piyasaya girer ve bir taban kurar. Yıl içinde ürün azalıp fiyat
tüketicinin aleyhine yükselirse, stoklarından satar ve tavanı aşağı çeker.

Bu ikili görev bir yorum değil, kurumun kuruluş belgesinde yazılı. 1938 tarihli kanun,
Ofis'in işini fiyatın "üreticiler bakımından normalin altına düşmesini ve halk aleyhine
yükselmesini" engellemek diye tarif ediyordu. Yani TMO baştan beri ne yalnızca çiftçinin
ne yalnızca tüketicinin kurumu; ikisinin arasındaki dengeye bakmakla görevli.

Bugün TMO'nun ilgi alanında buğday, arpa, çavdar, tritikale, yulaf, mısır ve çeltik var;
kuru fasulye, mercimek ve nohut var. Bir de çoğu kişinin bilmediği bir alan: haşhaş.
Türkiye'de afyon alkaloidlerini üretme ve satma yetkisi tek bir kurumda, TMO'da.

Ölçü fikri vermesi için: 2025 yılında Ofis 6 milyon 150 bin ton ürün satın aldı ve bunun
için 81,6 milyar lira ödedi. Aynı yıl Türkiye'de yetişen her beş buğdaydan biri TMO'ya
gitti.

Bu dosya kurumun nasıl doğduğunu, neler yaptığını, bugün nasıl çalıştığını ve çiftçiyi
neresinden ilgilendirdiğini anlatıyor.$dsr$, $dsr$The price of bread, the cost base of a flour mill, the money a farmer holds after harvest — at the end of each of these, usually unseen, stands the same institution: the Turkish Grain Board, TMO.

TMO is a state body. Its capital is wholly state-owned, it reports to the Ministry of Agriculture and Forestry, and it is based in Ankara. Its job, in one sentence: to keep price balance in the cereals and pulses market.

It does this in two directions. When the crop is abundant at harvest and the price falls against the farmer, TMO enters as a buyer and sets a floor. When supply tightens during the year and the price rises against the consumer, it sells from stock and pulls the ceiling down.

This double duty is not an interpretation; it is written into the founding document. The 1938 law described the Office's task as preventing prices from "falling below normal for producers and rising abnormally against the public". TMO has never been only the farmer's institution or only the consumer's; it was set up to watch the balance between them.

Today TMO's remit covers wheat, barley, rye, triticale, oats, maize and paddy rice; dry beans, lentils and chickpeas. And one field most people do not know about: opium poppy. In Türkiye the authority to produce and sell opium alkaloids sits with a single institution — TMO.

For a sense of scale: in 2025 the Office bought 6,150,000 tonnes of produce and paid ₺81.6 billion for it. That same year, one in every five grains of wheat grown in the country went to TMO.

This dossier traces how the institution was born, what it has done, how it works today, and where it touches the farmer.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarim-app-2026.web.app/dosya/tmo/bugday_hasadi.jpg","atif":"mhasras · CC BY 3.0 · Wikimedia Commons","kaynak":"https://commons.wikimedia.org/wiki/File:Yayc%C4%B1_k%C3%B6y%C3%BC_bu%C4%9Fday_hasad%C4%B1_-_panoramio.jpg","alt_tr":"Orta Anadolu’da buğday hasadı. TMO’nun bütün işi bu andan sonra başlıyor.","alt_en":"Wheat harvest in Central Anatolia. Everything TMO does begins after this moment."}$dsr$::jsonb),
  (2, $dsr$Kuruluş: 1932'den 1938'e$dsr$, $dsr$Founding: from 1932 to 1938$dsr$, $dsr$TMO'nun hikâyesi kendi kuruluşundan altı yıl önce başlar.

Birinci Dünya Savaşı'ndan sonra sanayi tesislerinin büyük ölçüde yok olması pek çok ülkeyi tarıma yöneltmişti. Üretim hızla arttı, üretici ülkelerde buğday stokları büyüdü, dış piyasada rekabet sertleşti. 1928'den sonra dünya buğday fiyatları hızla düşmeye başladı. Türkiye'de de çiftçi, ürününü hasat mevsiminde yok pahasına elden çıkarmak zorunda kalıyordu.

Hükümetin buna ilk cevabı yeni bir kurum kurmak değil, mevcut bir bankaya görev vermek oldu. 3 Temmuz 1932 tarihli ve 2056 sayılı Kanun, **Ziraat Bankası'nı buğday alımıyla görevlendirdi**. Bir yıl sonra, 11 Haziran 1933 tarihli ve 2303 sayılı Kanunla aynı bankaya hububat muhafaza tesisleri kurma görevi de verildi — çünkü ürünü almak yetmiyordu, saklamak da gerekiyordu.

Banka 1932 ve 1933 yıllarında, çoğu Orta Anadolu'da olmak üzere alım merkezleri açtı. İş, banka bünyesinde **Buğday Masası Şefliği** adıyla yürütülüyordu.

Ama iş büyüdü. Buğday üretimi arttı, İkinci Dünya Savaşı'nın belirtileri çoğaldı ve bir bankanın içindeki bir masa bu yükü taşıyamaz hâle geldi. 24 Haziran 1938'de kabul edilip 13 Temmuz 1938'de Resmî Gazete'de yayımlanan **3491 sayılı Kanun** ile Toprak Mahsulleri Ofisi kuruldu.

Kanunun Ofis'e verdiği görevler baştan geniş tutulmuştu: buğday fiyatını iki yönden korumak, piyasayı düzenlemek, gerektiğinde buğday ithal ve ihraç etmek, dünya buğday üretimini ve ticaretini izlemek, gerekli görülen yerlerde un ve ekmek fabrikaları kurmak — ve uyuşturucu maddelerle ilgili devlet tekelini yürütmek.

Bu son madde şaşırtıcı gelebilir. Ama TMO haşhaşla sonradan tanışmadı; kurumun kuruluş belgesinde afyon tekeli en baştan yazılıydı.$dsr$, $dsr$TMO's story begins six years before its own founding.

After the First World War, the destruction of industrial capacity pushed many countries towards agriculture. Output rose quickly, wheat stocks grew in producing countries, competition on export markets hardened. After 1928 world wheat prices fell sharply. In Türkiye too, farmers were forced to sell their crop for next to nothing at harvest.

The government's first answer was not to create an institution but to assign the task to an existing bank. Law no. 2056 of 3 July 1932 — published in the Official Gazette of 10 July 1932, no. 2146 — **charged Ziraat Bankası with buying wheat**. A year later, Law no. 2303 of 11 June 1933 gave the same bank the job of building grain storage facilities, because buying the crop was not enough; it had to be kept.

In 1932 and 1933 the bank opened purchasing centres, most of them in Central Anatolia. Inside the bank, the work ran under the name **Wheat Desk**.

But the work outgrew the desk. Wheat production rose, the signs of a second world war multiplied, and a section inside a bank could no longer carry the load. Law no. 3491, adopted on 24 June 1938 and published in the Official Gazette on 13 July 1938, created the Turkish Grain Board.

The duties the law gave were broad from the start: protect the wheat price in both directions, regulate the market, import and export wheat when needed, follow world wheat production and trade, establish flour and bread factories where necessary — and operate the state monopoly on narcotic substances.

That last item may come as a surprise. But TMO did not meet the poppy later; the opium monopoly was written into its founding document from the beginning.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarim-app-2026.web.app/dosya/tmo/ziraat_bankasi_1930lar.jpg","atif":"Directorate General of Press and Information · No restrictions · Wikimedia Commons","kaynak":"https://commons.wikimedia.org/wiki/File:Banks_Street_(Atat%C3%BCrk_Boulevard)_the_Building_of_Ziraat_Bankas%C4%B1_(Agricultural_Bank),_1930s_(16851305342).jpg","alt_tr":"1930’larda Ankara’da Ziraat Bankası binası. TMO’nun işi 1932’de bu bankaya verilmişti; Ofis altı yıl sonra o masadan doğdu.","alt_en":"The Ziraat Bankası building in 1930s Ankara. TMO’s work was first assigned to this bank in 1932; the Office was born from that desk six years later."}$dsr$::jsonb),
  (3, $dsr$Savaş yılları ve genişleme$dsr$, $dsr$The war years and the widening remit$dsr$, $dsr$Ofis kurulduktan bir yıl sonra dünya savaşa girdi. Türkiye savaşa girmedi ama ekonomisi
savaş şartlarına girdi — ve TMO'nun görev listesi hızla uzadı.

27 Ekim 1939'da arpa ve yulaf eklendi. 28 Kasım 1940'ta çavdar. 25 Nisan 1941'de mısır.
13 Ağustos 1941'de kuru fasulye ve pirinç. Üç yıl içinde tek ürünlü bir kurum, hububat ve
bakliyatın neredeyse tamamını kapsayan bir kuruma dönüştü.

Sonra liste tarımın da dışına taştı. O yıllarda ve sonrasında TMO benzin, otomobil
lastiği, et kavurması, margarin, kahve, nohut, akdarı, fasulye, mercimek, bakla, börülce,
susam, yağlı tohum, kasaplık hayvan, balık ve yonca tohumu alımıyla da görevlendirildi.

Bu liste bir kurumun görev tanımından çok bir ülkenin ihtiyaç listesi gibi okunuyor —
çünkü öyle. Kıtlık döneminde temel malların toplanması ve dağıtılması işini büyük ölçüde
bu kurum yürüttü. Ekmeklik buğdayı toplayan aynı ofis, benzin ve otomobil lastiği de
dağıtıyordu.

Savaş bitince liste daraldı; TMO asıl alanına, hububat ve bakliyata döndü. Ama o dönemden
kalıcı bir ilke miras kaldı: **ihtiyaç doğduğunda Ofis'e yeni görev verilir.** Kanunu
değiştirmeye gerek yoktur; bir kararla ürün listesine ekleme yapılır.

Bu mekanizmanın bugün de çalıştığını görmek zor değil:

- **2006–2009** arasında ve yeniden **Nisan 2017**'de kabuklu fındık alımıyla
  görevlendirildi. Fındık, Türkiye'nin dünya pazarında lider olduğu bir üründür ve fiyat
  dalgalanması doğrudan Karadeniz'in gelirini etkiler.
- **2017**'de, tarihinde ilk defa, çekirdeksiz kuru üzüm aldı.
- **2019**'da kuru incir, **2020**'de kuru kayısı listeye girdi. Üçü de Ege ve Akdeniz'in
  ihracat ürünleri; üçünde de fiyat, dünya talebine bağlı olarak sert oynayabiliyor.
- **2021**'de kuru soğan ve yemeklik patates alındı. Bu sonuncusu farklıydı: üreticinin
  piyasaya arz edemediği ürün satın alındı ve ihtiyaç sahiplerine ücretsiz dağıtıldı.
  Yani yapılan iş bir piyasa müdahalesi değil, bir yardım operasyonuydu.

Son yıllarda kuruma tarım dışından sayılabilecek bir görev daha verildi: ilaç etken
maddesi üretimi amaçlı kenevir yetiştiriciliğinin kontrolü.

Seksen sekiz yılda kurumun ne yaptığı defalarca değişti. Değişmeyen, kurumun ne için var
olduğu: fiyat çiftçinin aleyhine döndüğünde devletin sahaya inebileceği bir eli olması.$dsr$, $dsr$A year after the Office was founded, the world went to war. Türkiye did not enter the war, but its economy entered war conditions — and TMO's list of duties grew quickly.

Barley and oats were added on 27 October 1939. Rye on 28 November 1940. Maize on 25 April 1941. Dry beans and rice on 13 August 1941. Within three years a single-product institution came to cover almost all cereals and pulses.

Then the list spilled outside agriculture. In those years and after, TMO was also charged with buying petrol, car tyres, tinned meat, margarine, coffee, chickpeas, millet, beans, lentils, broad beans, cowpeas, sesame, oilseeds, slaughter animals, fish and alfalfa seed.

That list reads less like an institution's mandate than a country's list of needs — because that is what it was. During shortage, the work of collecting and distributing basic goods fell largely to this body. The same office that collected bread wheat was also distributing petrol and tyres.

When the war ended the list narrowed and TMO returned to its core field. But one principle survived: **when a need arises, the Office is given a new duty.** No change of law is required; a decision adds a product to the list.

It is not hard to see the same mechanism working today:

- Between **2006 and 2009**, and again in **April 2017**, it was charged with buying hazelnuts. Türkiye leads the world market in hazelnuts, and price swings feed straight into the income of the Black Sea coast.
- In **2017**, for the first time in its history, it bought raisins.
- **2019** brought dried figs, **2020** dried apricots. All three are export crops of the Aegean and Mediterranean, and in all three the price can swing hard with world demand.
- In **2021** it bought onions and table potatoes. This one was different: crops the producer could not place on the market were purchased and distributed free of charge to those in need. What was done there was not a market intervention but a relief operation.

In recent years one more duty arrived, arguably from outside agriculture: control of hemp cultivation for pharmaceutical active ingredients.

Over eighty-eight years what the institution does has changed many times. What has not changed is why it exists: so that the state has a hand it can put into the field when the price turns against the farmer.$dsr$, array['urun_yetkisi_cizelge']::text[], 'veri', null),
  (4, $dsr$Bugünkü TMO$dsr$, $dsr$TMO today$dsr$, $dsr$TMO bugün, sermayesinin tamamı devlete ait bir **iktisadi devlet teşekkülü**. Tüzel
kişiliği var, faaliyetlerinde özerk, sorumluluğu sermayesiyle sınırlı. Tarım ve Orman
Bakanlığı'nın ilgili kuruluşu; Türkiye Büyük Millet Meclisi ve Sayıştay denetimine tabi.

Bu hukuki tanım kulağa kuru gelebilir ama pratikte bir anlamı var: TMO ne bir bakanlık
birimi ne de sıradan bir şirket. Bakanlık birimi olsaydı her alım kararı bakanlık
bürokrasisinden geçerdi ve hasat mevsiminin hızına yetişemezdi. Şirket olsaydı kâr
etmediği yıl alım yapmazdı. Aradaki statü, ticari esneklikle kamu görevini birleştirmek
için var.

Karar organı altı kişilik bir Yönetim Kurulu: bir başkan ve beş üye. Genel Müdür aynı
zamanda Yönetim Kurulu'nun başkanı. Alım fiyatları da dâhil, kurumun temel kararları
buradan çıkıyor.

Kurumun asıl gövdesi ise Ankara'da değil, sahada. Taşra teşkilatı başmüdürlükler, şube
müdürlükleri, ajans amirlikleri ve tesisli ekiplerden oluşuyor. Hasat yoğunlaştığında bu
ağa **geçici alım merkezleri** ekleniyor — kamyonla ürün getiren çiftçinin yüz kilometre
yol yapmaması için, üretimin olduğu yere gidiliyor.

Bu, kurumun sahadaki büyüklüğünün yıl içinde nefes alıp verdiği anlamına geliyor.
Temmuz'daki TMO ile Şubat'taki TMO aynı boyda değil. Buğday hasadının sürdüğü haftalarda
Ofis, ülkenin dört bir yanında yüzlerce noktada aynı anda tartı yapan bir ağa dönüşüyor;
kışın o ağ büzülüyor.

Bir de fabrikası var: Afyonkarahisar'ın Bolvadin ilçesindeki Afyon Alkaloidleri
Fabrikası. Yedinci bölümde ona ayrıca bakacağız.$dsr$, $dsr$TMO today is a **state economic enterprise** whose capital is wholly state-owned. It has legal personality, is autonomous in its activities, and its liability is limited to its capital. It is a related organisation of the Ministry of Agriculture and Forestry, and subject to the oversight of the Grand National Assembly and the Court of Accounts.

That legal definition may sound dry, but it has a practical meaning. TMO is neither a ministry department nor an ordinary company. As a department, every purchasing decision would pass through ministry bureaucracy and never keep pace with harvest. As a company, it would not buy in a year it could not turn a profit. The status in between exists to join commercial flexibility to a public duty.

The deciding body is a six-member Board of Directors: a chairman and five members. The Director General also chairs the Board. The institution's core decisions, purchase prices included, are taken here.

But the bulk of the institution is not in Ankara; it is in the field. Its provincial organisation consists of regional directorates, branch offices, agency posts and equipped teams. When harvest intensifies, **temporary purchasing centres** are added to that network — so that a farmer arriving by truck does not have to drive a hundred kilometres, the Office goes where the crop is.

This means the institution's footprint breathes through the year. The TMO of July and the TMO of February are not the same size. In the weeks of the wheat harvest the Office becomes a network weighing grain at hundreds of points across the country at once; in winter that network contracts.

It also has a factory: the Opium Alkaloids Plant in Bolvadin, Afyonkarahisar. Section seven takes that up separately.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarim-app-2026.web.app/dosya/tmo/tmo_silolari_izmir.jpg","atif":"Levent · Public domain · Wikimedia Commons","kaynak":"https://commons.wikimedia.org/wiki/File:Turkish_Grain_Board_main_silos_in_Izmir.JPG","alt_tr":"TMO’nun İzmir’deki silolarından biri. Kurumun kendi depolama kapasitesi yaklaşık 4 milyon ton.","alt_en":"One of TMO’s silo complexes in İzmir. The institution’s own storage capacity is around 4 million tonnes."}$dsr$::jsonb),
  (5, $dsr$Ne iş yapar$dsr$, $dsr$What it does$dsr$, $dsr$TMO'nun işini dört adımda anlatmak mümkün: fiyat açıklamak, almak, saklamak, satmak.

**Fiyat açıklamak**

Yılın en görünür anı budur. Ofis, ilgi alanındaki ürünler için hasat öncesinde alım
fiyatını ilan eder. Bu ilan tarım basınında manşet olur, çünkü o rakam yalnızca TMO'ya
satacak çiftçiyi değil, bütün piyasayı ilgilendirir.

2025 takvimi şöyle işledi. Ekmeklik ve makarnalık buğday fiyatı 3 Haziran'da açıklandı:
ton başına 13.500 lira. Arpa aynı gün 11.000 lira. Mısır 15 Ağustos'ta ilan edildi —
birinci sınıf için 11.400, ikinci sınıf için 11.300 lira. Kuru fasulyede Dermason çeşidi
için 7 Ekim'de 42.000 lira açıklandı.

Tarihlerin hasat takvimini izlediğine dikkat: buğday Haziran'da, mısır Ağustos'ta, kuru
fasulye Ekim'de. Fiyat, ürün tarladan kalkmadan önce belli olur ki çiftçi ne yapacağına
karar verebilsin.

Fiyatı Ofis kendisi belirler. Tek bir rakam değildir — ürünün cinsine, çeşidine ve üretim
yerine göre her yıl yeniden tespit edilir. Kararı altı kişilik Yönetim Kurulu verir.

**Almak**

Fiyat açıklandıktan sonra üretici ürününü alım noktalarına getirir. Ürün burada sınıfına
ve kalitesine göre değerlendirilir; TMO ilgili mevzuat kapsamında gerektiğinde fiyat farkı
uygulayarak alım yapabilir. Yani aynı üründe herkes aynı parayı almaz — kalite fiyata
yansır.

2025'te toplam alım 6 milyon 150 bin tonu buldu. Bunun büyük kısmı hububat; buğdayda
3 milyon 841 bin ton alındı. Alımların yüzde 86'sı iç piyasadan geldi, yüzde 14'ü
ithalattan. İthalat, iç üretimin yetmediği ya da belirli bir kalitenin bulunamadığı
durumlarda devreye giriyor.

**Saklamak**

Alınan ürün depolanır. TMO kuruluşundan bu yana limanları ve yoğun üretim bölgelerini
gözeterek depo yaptırdı; bugün yaklaşık 4 milyon ton depolama kapasitesi var ve bunun
500 bin tonu limanlarda. Liman depolarının ayrı tutulması tesadüf değil — ithalat ve
ihracat oradan geçiyor.

Depolama, ürünü korumak kadar zamanı yönetmek demek. 2025 sonunda TMO'nun elindeki
stokların değeri 138,2 milyar liraydı. Bu stok, yıl içinde piyasaya ne zaman ve ne kadar
mal verileceğinin de karşılığı.

**Satmak**

Stok, ihtiyaca göre piyasaya verilir. Un ve yem sanayii için TMO'nun satış kararları
hammadde maliyetini doğrudan etkiler; Ofis'in ne zaman satışa çıkacağı sanayici için
fiyattan bile daha belirleyici olabiliyor.

**Ve bazen hiçbiri**

Bu dört adımın en önemli özelliği şu: **hepsi her yıl, her üründe çalışmaz.**

2025'te çeltik, kırmızı mercimek, yeşil mercimek ve nohutta alım için tüm hazırlıklar
tamamlanmıştı. Ama serbest piyasada oluşan fiyatlar üreticinin beklentisini karşıladığı
için bu ürünlerde fiyat açıklanmadı.

TMO piyasada sürekli duran bir alıcı değil. Piyasa çiftçiye yeterli fiyatı veriyorsa
ortaya çıkmaz; vermiyorsa devreye girer. Kurumu anlamanın en kısa yolu bu cümledir.$dsr$, $dsr$TMO's work can be told in four steps: announce a price, buy, store, sell.

**Announcing a price**

This is the most visible moment of the year. Before harvest, the Office announces its purchase price for the products in its remit. The announcement makes headlines in the farming press, because that figure concerns not only the farmers who will sell to TMO but the whole market.

The 2025 calendar ran as follows. Bread and durum wheat were announced on 3 June: ₺13,500 per tonne. Barley the same day at ₺11,000. Maize was announced on 15 August — ₺11,400 for grade 1, ₺11,300 for grade 2. Dry beans, Dermason variety, came on 7 October at ₺42,000.

Note that the dates track the harvest calendar: wheat in June, maize in August, dry beans in October. The price is known before the crop leaves the field, so the farmer can decide what to do.

The Office sets the price itself. It is not a single figure — it is determined afresh each year by type, variety and place of production. The decision rests with the six-member Board.

**Buying**

Once the price is out, producers bring their crop to purchasing points. The crop is assessed by class and quality; where the rules allow, TMO can buy with a price differential. So not everyone receives the same money for the same product — quality shows up in the price.

Total purchases reached 6,150,000 tonnes in 2025, most of it cereals; 3,841,000 tonnes of wheat were bought. Eighty-six per cent of purchases came from the domestic market, fourteen per cent from imports. Imports come into play when domestic output falls short or a particular quality cannot be found.

**Storing**

What is bought is stored. Since its founding TMO has built warehouses with ports and intensive production areas in mind; today it holds around 4 million tonnes of capacity, some 500,000 tonnes of it at ports. Port storage is separated for a reason — imports and exports pass through there.

Storage is as much about managing time as protecting grain. At the end of 2025 the value of TMO's stocks stood at ₺138.2 billion. That stock is also the answer to when and how much will be released to the market during the year.

**Selling**

Stock is released as needed. For the flour and feed industries, TMO's selling decisions feed directly into raw material costs; when the Office comes to market can matter more to a processor than the price itself.

**And sometimes none of the above**

The most important feature of these four steps is that **they do not all run every year in every product.**

In 2025 all preparations for buying paddy rice, red lentils, green lentils and chickpeas had been completed. But because the free market prices that formed met producer expectations, no price was announced for those products.

TMO is not a buyer permanently present in the market. If the market pays the farmer enough, it does not appear; if it does not, it steps in. That sentence is the shortest way to understand the institution.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarim-app-2026.web.app/dosya/tmo/tmo_satis_ofisi.jpg","atif":"Elenktra · CC0 · Wikimedia Commons","kaynak":"https://commons.wikimedia.org/wiki/File:Toprak_Mahsulleri_Ofisi_sat%C4%B1%C5%9F_ofisi.jpg","alt_tr":"Bir TMO satış ofisi. Alım kadar satış da kurumun işi: stoktan piyasaya verilen ürün fiyatın tavanını belirliyor.","alt_en":"A TMO sales office. Selling is as much its business as buying: stock released to the market sets the ceiling on price."}$dsr$::jsonb),
  (6, $dsr$Çiftçi için ne anlama geliyor$dsr$, $dsr$What it means for the farmer$dsr$, $dsr$Bir çiftçi açısından TMO üç şekilde işe yarar: fiyata taban koyar, ek ödeme getirir ve
ürünü satmadan bekleme imkânı verir.

**Taban fiyat**

Ofis bir üründe alım fiyatı açıkladığında, o rakam piyasanın alt sınırı hâline gelir.
Tüccar, TMO'nun verdiği fiyatın çok altında bir teklifle üreticiye gidemez; çünkü
üreticinin elinde her zaman başka bir alıcı vardır. Devletin bu politikadaki ifadesi
açık: eşik fiyat ilanı ve alım garantisiyle, hasat yoğunluğu yüzünden fiyatların
düşmesini önlemek.

Etkinin ne kadar gerçek olduğu 2025'te görüldü. O yıl Türkiye kuraklık yaşadı; su yılı
yağışı 422,5 milimetrede kaldı, uzun yıllar ortalaması 573,4 milimetredir. Buğday
üretimi yüzde 13,7 geriledi.

Böyle bir yılda TMO'ya daha az ürün gelmesi beklenirdi. Tersi oldu: programlanan 2,5
milyon tona karşılık 3 milyon 841 bin ton buğday alındı. Sebebi basit — açıklanan fiyat
piyasa fiyatının üzerinde kalmıştı ve çiftçi ürününü Ofis'e götürdü.

Aynı yıl arpada tam tersi yaşandı. Arpa üretimi yüzde 25,9 düşmüştü ama hayvancılığın
talebi arpa fiyatını yukarı itmişti. Piyasa üreticiye daha iyi para veriyordu ve ürün
serbest piyasada satıldı; TMO'nun alımı 171 bin tonda kaldı — hedefinin çok altında.

İkisi birlikte sistemin nasıl çalıştığını gösterir. **Piyasa iyiyse çiftçi piyasaya
gider, kötüyse Ofis'e.** TMO'nun alım rakamının düşük olması bir başarısızlık değil, çoğu
zaman piyasanın iyi çalıştığının işaretidir.

**Prim**

Açıklanan alım fiyatı çiftçinin eline geçen tek rakam değil. Alım fiyatına ek olarak
destekleme primi ödenebiliyor. 2024'te Bakanlık, TMO'ya ürün veren üreticiye ton başına
buğdayda 1.750, arpada 750 lira alım primi verdi.

Bunun anlamı şu: TMO'ya satmak, ilan edilen fiyatın ötesinde bir avantaj taşıyabiliyor.
Çiftçinin karşılaştırma yaparken iki rakamı toplaması gerekiyor.

**Ürünü taşımadan satmak**

Üçüncü yol daha yeni ve daha az biliniyor. Çiftçi ürününü lisanslı bir depoya teslim
edip karşılığında **Elektronik Ürün Senedi (ELÜS)** alabiliyor. Ürün depoda kalıyor;
alınıp satılan belge oluyor.

TMO 2016'dan beri lisanslı depolara teslim edilen ürünler için alım garantisi veriyor ve
bu senetleri satın alıyor. Yani senedin alıcısı çıkmazsa arkada Ofis duruyor.

Pratikte bu, hasat anında satmak zorunda kalmamak demek. Ürün depoda beklerken çiftçi
fiyatın yükselmesini bekleyebiliyor, senedi teminat gösterip kredi kullanabiliyor ya da
uygun gördüğü anda borsada satabiliyor. Hasat anında herkesin aynı anda satmak zorunda
kalması, tarımda fiyatı aşağı çeken en eski mekanizmadır; ELÜS tam olarak bunu kırmak
için var.

**Peki ya fiyat açıklanmazsa**

TMO her yıl her üründe fiyat açıklamıyor. 2025'te çeltik, kırmızı mercimek, yeşil
mercimek ve nohutta bütün hazırlıklar tamamlanmıştı; ama serbest piyasada oluşan fiyatlar
üreticinin beklentisini karşıladığı için fiyat ilan edilmedi.

Bu, çiftçi için şu anlama geliyor: TMO'nun sessiz kaldığı ürün, o yıl piyasanın iyi
çalıştığı üründür.$dsr$, $dsr$From a farmer's point of view TMO does three things: it puts a floor under the price, it brings an extra payment, and it makes it possible to wait without selling.

**A floor price**

When the Office announces a purchase price in a product, that figure becomes the market's lower bound. A trader cannot approach the producer with an offer far below TMO's price, because the producer always has another buyer. The state's own formulation is clear: through threshold price announcement and a purchase guarantee, prevent prices from falling because everyone harvests at once.

How real the effect is became visible in 2025. That year Türkiye had a drought; water-year rainfall came in at 422.5 mm against a long-term average of 573.4 mm. Wheat production fell 13.7 per cent.

In such a year one would expect less crop to reach TMO. The opposite happened: against a programme of 2.5 million tonnes, 3,841,000 tonnes of wheat were bought. The reason is simple — the announced price stayed above the market price and the farmer took the crop to the Office.

In barley the same year, the reverse. Barley output had fallen 25.9 per cent, but livestock demand pushed the barley price up. The market was paying the producer better, the crop was sold on the open market, and TMO's purchases stopped at 171,000 tonnes — far below target.

Together, the two show how the system works. **If the market is good the farmer goes to the market; if it is not, to the Office.** A low purchase figure at TMO is not a failure; more often it is a sign that the market is working.

**The premium**

The announced purchase price is not the only figure that reaches the farmer. A support premium can be paid on top. In 2024 the Ministry paid producers selling to TMO a purchase premium of ₺1,750 per tonne for wheat and ₺750 for barley.

Which means selling to TMO can carry an advantage beyond the published price. The farmer comparing offers has to add two figures.

**Selling without moving the crop**

The third route is newer and less known. A farmer can deliver the crop to a licensed warehouse and receive an **Electronic Warehouse Receipt (ELÜS)** in return. The crop stays in the warehouse; what is bought and sold is the document.

Since 2016 TMO has given a purchase guarantee for crops delivered to licensed warehouses, and buys those receipts. If no buyer appears for the receipt, the Office stands behind it.

In practice this means not having to sell at the moment of harvest. While the crop waits in the warehouse the farmer can wait for the price to rise, pledge the receipt for credit, or sell it on the exchange when the moment suits. Everyone being forced to sell at once at harvest is the oldest mechanism pushing farm prices down; ELÜS exists precisely to break it.

**And if no price is announced**

TMO does not announce a price every year in every product. In 2025 all preparations for paddy rice, red lentils, green lentils and chickpeas were complete, but the prices forming on the open market met producer expectations and no announcement was made.

For the farmer this means something specific: the product on which TMO stays silent is the product where the market is working that year.$dsr$, array['alim_program']::text[], 'veri', $dsr${"url":"https://tarim-app-2026.web.app/dosya/tmo/hasat_tarlada.jpg","atif":"mhasras · CC BY 3.0 · Wikimedia Commons","kaynak":"https://commons.wikimedia.org/wiki/File:Yayc%C4%B1_k%C3%B6y%C3%BC_bu%C4%9Fday_hasad%C4%B1_-_panoramio_(1).jpg","alt_tr":"Hasat makinesi tarlada. Çiftçinin ürününü ne zaman ve kime satacağı kararı bu haftalarda veriliyor.","alt_en":"A combine in the field. The decision of when and to whom to sell is taken in these weeks."}$dsr$::jsonb),
  (7, $dsr$Haşhaş ve afyon alkaloidleri$dsr$, $dsr$Poppy and opium alkaloids$dsr$, $dsr$TMO'nun en az bilinen, ama en özel yetkisi bu.

Türkiye'de haşhaş ekimi serbest değil. Yalnızca belirlenen illerde ve ilçelerde ekim
yapılabiliyor; ekim yapacak üreticiler her yıl için **ayrı izin belgesi** alıyor. Ekim
ve üretim denetleniyor, hasat kontrol altında yapılıyor. Ürünü satın alan da TMO ve
fiyatı yine Ofis belirliyor.

Bu sıkı düzenin sebebi tarımsal değil, uluslararası. Haşhaş kapsülünden elde edilen
alkaloidler hem ağrı kesici ilaçların hammaddesi hem de uyuşturucu maddelerin kaynağı.
Türkiye, yasal afyon üretimi yapan sayılı ülkeden biri ve bu üretim uluslararası
anlaşmalarla çerçevelenmiş durumda. Denetimin sıkılığı, üretim izninin sürmesinin şartı.

Zincirin ikinci halkası Bolvadin'de. **Afyon Alkaloidleri Fabrikası İşletme
Müdürlüğü**'nde haşhaş kapsülünden morfin ve türevleri üretiliyor; ürün yurt içine ve
yurt dışına satılıyor. Bu alanda TMO piyasada tekel.

Yani TMO'nun bu ayağı bir tarımsal alım işinden çok bir **sanayi ve kontrol işi**.
Buğdayda kurum bir alıcıdır; haşhaşta hem tek alıcı, hem üretici, hem denetçidir.

Çiftçi tarafından bakınca ise haşhaş, garantili bir ürün: alıcı belli, fiyat önceden
açıklanıyor, satış riski yok. Karşılığında ekim serbestisi yok.

Bu düzenin kökeni de kurumun kuruluşunda. 1938 tarihli kanunun Ofis'e verdiği görevler
arasında "uyuşturucu maddelerle ilgili devlet tekelinin yürütülmesi" de sayılıyordu.
Buğdayla afyonun aynı kurumda buluşması bugünden bakınca tuhaf görünebilir; ama o
dönemde ikisi de sıkı devlet kontrolü gerektiren stratejik ürün sayılıyordu. Aradan
seksen sekiz yıl geçti, düzenleme hâlâ ayakta.

Son yıllarda buna bir görev daha eklendi: ilaç etken maddesi üretimi amaçlı kenevir
yetiştiriciliğinin kontrolü de TMO'ya verildi. Mantık aynı — tıbbi değeri olan, ama
kontrolsüz bırakılamayacak bir bitki.$dsr$, $dsr$This is TMO's least known and most particular authority.

Poppy cultivation is not free in Türkiye. It is permitted only in designated provinces and districts, and growers obtain a **separate licence for each year**. Sowing and production are inspected; harvest takes place under control. The buyer is TMO, and the Office sets the price.

The reason for this tight regime is not agricultural but international. The alkaloids obtained from the poppy capsule are both the raw material of painkillers and the source of narcotics. Türkiye is one of a handful of countries producing opium legally, and that production is framed by international agreements. The strictness of the oversight is the condition on which the licence to produce continues.

The second link in the chain is at Bolvadin. At the **Opium Alkaloids Plant** morphine and its derivatives are produced from poppy capsules and sold at home and abroad. In this field TMO holds a market monopoly.

So this leg of TMO is less an agricultural purchasing operation than an **industrial and control operation**. In wheat the institution is a buyer; in poppy it is at once the only buyer, the producer and the inspector.

From the grower's side, poppy is a guaranteed crop: the buyer is known, the price is announced in advance, there is no sales risk. In exchange, there is no freedom to plant.

The roots of this arrangement lie in the founding as well. Among the duties the 1938 law gave the Office was "operating the state monopoly on narcotic substances". Wheat and opium meeting in one institution may look odd from here; but at the time both were treated as strategic products requiring tight state control. Eighty-eight years on, the arrangement still stands.

In recent years one more duty was added: control of hemp cultivation for pharmaceutical active ingredients. The logic is the same — a plant with medicinal value that cannot be left uncontrolled.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarim-app-2026.web.app/dosya/tmo/hashas_tarlasi.jpg","atif":"Bernard Gagnon · CC BY-SA 3.0 · Wikimedia Commons","kaynak":"https://commons.wikimedia.org/wiki/File:Poppy_field,_Turkey_03.jpg","alt_tr":"Türkiye’de bir haşhaş tarlası. Ekim izne bağlı, alıcı tek: TMO.","alt_en":"A poppy field in Türkiye. Cultivation requires a licence and there is a single buyer: TMO."}$dsr$::jsonb),
  (8, $dsr$Depolar ve lisanslı depoculuk$dsr$, $dsr$Warehouses and licensed storage$dsr$, $dsr$Tarımda ürünü almak kadar saklamak da meseledir. Depolanamayan ürün hasat anında
satılmak zorundadır — ve o an, herkesin aynı anda sattığı için, fiyatın en düşük olduğu
andır. Türkiye'de çiftçinin klasik çıkmazı budur.

TMO'nun kendi kapasitesi yaklaşık 4 milyon ton. Ülkenin yıllık buğday üretiminin
yanında bu tek başına yeterli değil ve olması da beklenmez; devletin bütün ürünü
depolaması gibi bir hedef yok.

Kurumun son on yıldaki asıl etkisi kendi depolarını büyütmekle değil, **başkalarının depo
yapmasını mümkün kılmakla** oldu.

Lisanslı depoculuk şöyle işler: özel bir şirket, belirli standartlarda depo kurar ve
Ticaret Bakanlığı'ndan lisans alır. Çiftçi ürününü bu depoya teslim eder ve karşılığında
elektronik bir belge alır — Elektronik Ürün Senedi, kısaca ELÜS. Ürün depoda kalır,
alınıp satılan senet olur. Senet borsada işlem görebilir, kredi teminatı olarak
kullanılabilir.

Sistemin kâğıt üstünde işlemesi için bir şeye ihtiyaç vardı: depo yatırımcısının riski
üstlenecek birine. Depo kurmak pahalı bir yatırım ve talep gelmezse yatırımcı batar.

2016'da TMO iki adım attı. Lisanslı depolara teslim edilen ürünler için **alım garantisi**
vermeye başladı — yani senedin alıcısı çıkmazsa Ofis alacaktı. Ve uzun süreli **kira
garantili depo yapım projesini** başlattı. Özel sektöre verilen mesaj netti: sen depoyu
yap, arkanda ben varım.

Sonuç çarpıcı. 2016'da 805 bin ton olan Türkiye'nin lisanslı depo kapasitesi bugün
**14,2 milyon tona** ulaştı. Dokuz yılda on yedi katından fazla.

Bu, Türkiye tarımında sessiz bir altyapı değişimi. Çiftçi artık ürününü hasat anında
satmak zorunda değil: depoya koyar, senedini elinde tutar, fiyat yükselene kadar bekler
ya da senedi teminat gösterip nakit ihtiyacını karşılar. TMO bu sistemin kurucusu değil,
ama büyümesini mümkün kılan garantörü oldu — ve bu, kurumun alım fiyatı açıklamak kadar
görünür olmayan, ama uzun vadede belki daha kalıcı işlevi.$dsr$, $dsr$In farming, keeping the crop matters as much as buying it. A crop that cannot be stored must be sold at harvest — and that, because everyone is selling at the same time, is the moment the price is lowest. This is the classic bind of the Turkish farmer.

TMO's own capacity is around 4 million tonnes. Set against the country's annual wheat crop that is not enough on its own, nor is it meant to be; there is no goal of the state storing the whole harvest.

The institution's real effect over the past decade came not from enlarging its own warehouses but from **making it possible for others to build them**.

Licensed storage works like this: a private company builds a warehouse to defined standards and obtains a licence from the Ministry of Trade. The farmer delivers the crop to that warehouse and receives an electronic document in return — the Electronic Warehouse Receipt, ELÜS for short. The crop stays put; what changes hands is the receipt. It can be traded on the exchange or pledged as collateral for credit.

For the system to work on paper, one thing was needed: someone to carry the warehouse investor's risk. Building a warehouse is expensive, and if the crop does not come the investor goes under.

In 2016 TMO took two steps. It began giving a **purchase guarantee** for crops delivered to licensed warehouses — meaning that if no buyer appeared for the receipt, the Office would buy. And it launched a long-term **rent-guaranteed warehouse construction project**. The message to the private sector was plain: you build the warehouse, I stand behind you.

The result is striking. Türkiye's licensed storage capacity, 805,000 tonnes in 2016, has reached **14.2 million tonnes** today. More than seventeenfold in nine years.

This is a quiet infrastructure shift in Turkish agriculture. The farmer no longer has to sell at harvest: the crop goes into the warehouse, the receipt stays in hand, and the wait for a better price becomes possible — or the receipt can be pledged to cover an immediate need for cash. TMO did not found this system, but it became the guarantor that made it grow — and that may be the institution's less visible but more lasting function.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarim-app-2026.web.app/dosya/tmo/tmo_silolari_ek.jpg","atif":"Levent · Public domain · Wikimedia Commons","kaynak":"https://commons.wikimedia.org/wiki/File:Turkish_Grain_Board_additional_silos_in_Izmir.JPG","alt_tr":"TMO’nun İzmir’deki ek siloları. Depolama, ürünü korumak kadar zamanı yönetmek demek.","alt_en":"TMO’s additional silos in İzmir. Storage is as much about managing time as protecting grain."}$dsr$::jsonb),
  (9, $dsr$Dünyada benzerleri$dsr$, $dsr$Counterparts elsewhere$dsr$, $dsr$Devletin tahıl piyasasına girmesi Türkiye'ye özgü değil. Dünyanın büyük tarım
ülkelerinin çoğunda benzer bir mekanizma var. Ama nasıl girdiği ülkeden ülkeye değişiyor
ve dört ayrı model ortaya çıkıyor.

**Hindistan — devlet en büyük alıcı.** Food Corporation of India ve eyalet kurumları,
merkezî olarak belirlenen Asgari Destek Fiyatı (MSP) üzerinden alım yapar. 2025-26
sezonunda 29 milyon tonun üzerinde buğday alındı; ülkenin üretimi yaklaşık 115 milyon ton.
Yani devlet, ülkede yetişen buğdayın dörtte birine yakınını satın alıyor. Alınan ürünün
önemli bir kısmı kamu dağıtım sistemi üzerinden düşük gelirli hanelere ulaştırılıyor.
TMO'nun yaptığı işin çok daha büyük ölçekli ve sosyal politikaya doğrudan bağlanmış hâli.

**Avrupa Birliği — kriz sigortası.** AB'de de kamu müdahale alımı var ve Ortak Piyasa
Düzeni mevzuatına dayanıyor. Ama iki sınırla çevrili: ekmeklik buğdayda alım 3 milyon
tonla tavanlı, bu tavanın üzerindeki alım ihale usulüyle yapılıyor; müdahale fiyatı ise
ton başına 101,31 avro. AB'nin yıllık buğday üretimi 144 milyon ton olduğuna göre tavan,
üretimin yaklaşık yüzde ikisi. Fiyat da piyasanın belirgin biçimde altında.

Buradaki fark yalnızca ölçek değil, amaç. AB sistemi çiftçinin eline geçen fiyatı
yükseltmek için değil, fiyat çökerse altına zemin koymak için tasarlanmış. Bir taban
fiyat aracından çok bir kriz sigortası. Normal yıllarda hiç çalışmaz.

**Amerika Birleşik Devletleri — alım yok, ödeme var.** ABD'de devlet rutin olarak tahıl
satın almıyor. Bunun yerine iki mekanizma çalışıyor. Üretici ürününü teminat göstererek
pazarlama kredisi alabiliyor ve isterse krediyi ürünü teslim ederek kapatabiliyor.
Ayrıca gelir desteği, fiyat ve gelir düştüğünde devreye giren programlar üzerinden
doğrudan ödeme olarak veriliyor. Destek var, ama devletin elinde depo dolusu buğday yok.

**Türkiye — ikisinin arasında.** TMO 2025'te 3 milyon 841 bin ton buğday aldı; ülke
üretimi 17,95 milyon tondu. Pay yaklaşık yüzde 21.

Bu dört model iki gruba ayrılıyor. Türkiye ve Hindistan'da devlet piyasanın en büyük
alıcılarından biri; fiyat, kurumun açıkladığı rakamla şekilleniyor. AB ve ABD'de o işlev
bir kuruma değil bir ödeme mekanizmasına devredilmiş; devletin deposu yok, bütçesi var.

TMO ölçek ve yöntem bakımından Hindistan modeline daha yakın duruyor. Aradaki fark,
Türkiye'de sistemin sosyal dağıtımdan çok piyasa dengesine odaklanmış olması.$dsr$, $dsr$The state entering the grain market is not particular to Türkiye. Most large agricultural countries have some version of this mechanism. But how the state enters differs from country to country, and four distinct models emerge.

**India — the state as the largest buyer.** The Food Corporation of India and state agencies buy at a centrally determined Minimum Support Price (MSP). In the 2025-26 season more than 29 million tonnes of wheat were procured against national output of about 115 million tonnes. The state buys close to a quarter of the wheat grown in the country. A significant share of it reaches low-income households through the public distribution system. It is the same work TMO does, at far greater scale and tied directly to social policy.

**European Union — crisis insurance.** The EU also has public intervention buying, resting on Common Market Organisation legislation. But it is hemmed in by two limits: buying-in of common wheat is capped at 3 million tonnes, with purchases above that ceiling made by tender; and the intervention price is €101.31 per tonne. Against annual EU wheat output of 144 million tonnes, the ceiling is about two per cent of the crop. The price sits well below the market.

The difference here is not only scale but purpose. The EU system is not designed to raise the price the farmer receives but to put a floor under a collapse. Less a support-price instrument than a crisis insurance. In normal years it does not operate at all.

**United States — no buying, but payments.** The American state does not routinely purchase grain. Two mechanisms work instead. A producer can pledge the crop as collateral for a marketing loan and, if they choose, repay the loan by delivering the crop. And income support is paid directly through programmes that engage when price and revenue fall. There is support, but no warehouse full of government wheat.

**Türkiye — between the two.** TMO bought 3,841,000 tonnes of wheat in 2025 against national output of 17.95 million tonnes. The share is about 21 per cent.

The four models fall into two groups. In Türkiye and India the state is among the market's largest buyers, and the price takes shape around the figure the institution announces. In the EU and the US that function has been handed not to an institution but to a payment mechanism; the state has no warehouse, it has a budget line.

In scale and method TMO sits closer to the Indian model. The difference is that in Türkiye the system is focused less on social distribution than on market balance.$dsr$, array['dunya_pay']::text[], 'veri', null),
  (10, $dsr$Rakamlarla TMO$dsr$, $dsr$TMO in figures$dsr$, $dsr$| | |
|---|---|
| Kuruluş | 1938 · 3491 sayılı Kanun |
| Öncesi | 1932 · Ziraat Bankası buğday alımıyla görevlendirildi |
| Hukuki statü | İktisadi devlet teşekkülü |
| Bağlı olduğu makam | Tarım ve Orman Bakanlığı |
| Merkez | Ankara |
| Karar organı | Yönetim Kurulu · 6 kişi |
| 2025 alımı | 6.150.332 ton |
| 2025 alım ödemesi | 81,6 milyar TL |
| Buğday alımı (2025) | 3.841.000 ton |
| Türkiye buğday üretimi (2025/26) | 17,95 milyon ton |
| Üretimdeki payı | yaklaşık %21 |
| İç alım / ithalat | %86 / %14 |
| Yıl sonu stok değeri | 138,2 milyar TL |
| Kendi depolama kapasitesi | ~4 milyon ton |
| Bunun limanlardaki payı | ~500 bin ton |
| Lisanslı depo kapasitesi (ülke) | 14,2 milyon ton |
| 2016'daki lisanslı depo kapasitesi | 805 bin ton |
| Afyon alkaloidleri | piyasada tekel · Bolvadin |

2025'in alım fiyatları şöyleydi: ekmeklik ve makarnalık buğday ton başına 13.500 lira,
arpa 11.000 lira, birinci sınıf mısır 11.400, kuru fasulyede Dermason çeşidi 42.000 lira.
Bunlara 2024'te ton başına buğdayda 1.750, arpada 750 liralık alım primi eklenmişti.

Seksen sekiz yıl önce tek bir ürün için, bir bankanın içindeki masadan ayrılarak kurulmuş
bir ofis; bugün Türkiye'nin tahıl dengesini, ekmeğinin hammaddesini, ihracat meyvelerinin
fiyat tabanını ve ilaç sanayiinin bir halkasını aynı anda taşıyor.$dsr$, $dsr$| | |
|---|---|
| Founded | 1938 · Law no. 3491 |
| Before that | 1932 · Ziraat Bankası charged with buying wheat |
| Legal status | State economic enterprise |
| Reports to | Ministry of Agriculture and Forestry |
| Headquarters | Ankara |
| Deciding body | Board of Directors · 6 members |
| 2025 purchases | 6,150,332 tonnes |
| 2025 purchase payments | ₺81.6 billion |
| Wheat bought (2025) | 3,841,000 tonnes |
| Turkish wheat production (2025/26) | 17.95 million tonnes |
| Share of the crop | about 21% |
| Domestic / imported | 86% / 14% |
| Year-end value of stocks | ₺138.2 billion |
| Own storage capacity | ~4 million tonnes |
| Of which at ports | ~500,000 tonnes |
| Licensed storage capacity (national) | 14.2 million tonnes |
| Licensed storage capacity in 2016 | 805,000 tonnes |
| Opium alkaloids | market monopoly · Bolvadin |

The 2025 purchase prices were: bread and durum wheat ₺13,500 per tonne, barley ₺11,000, grade 1 maize ₺11,400, and Dermason dry beans ₺42,000. On top of these, in 2024 a purchase premium of ₺1,750 per tonne for wheat and ₺750 for barley had been paid.

An office founded eighty-eight years ago for a single product, split off from a desk inside a bank, today carries at once the country's grain balance, the raw material of its bread, the price floor under its export fruits, and one link of its pharmaceutical industry.$dsr$, '{}'::text[], 'veri', null),
  (11, $dsr$Kaynakça$dsr$, $dsr$Sources$dsr$, $dsr$**Toprak Mahsulleri Ofisi Genel Müdürlüğü Ana Statüsü** — Resmî Gazete, 30 Eylül 2021

**TMO 2025 Yılı Faaliyet Raporu** (88. Hesap Dönemi) — Toprak Mahsulleri Ofisi

**TMO Kurum Tarihçesi** — Toprak Mahsulleri Ofisi Genel Müdürlüğü

**3491 sayılı Toprak Mahsulleri Ofisi Kanunu** — 24 Haziran 1938, Resmî Gazete 13 Temmuz 1938

**2056 sayılı Kanun** (Ziraat Bankası'nın buğday alımıyla görevlendirilmesi) — Resmî Gazete, 10 Temmuz 1932, sayı 2146

**233 sayılı Kamu İktisadi Teşebbüsleri Hakkında Kanun Hükmünde Kararname** — Resmî Gazete, 18 Haziran 1984, sayı 18435 (mükerrer)

**Türkiye buğday üretim verileri** — TÜİK, TMO faaliyet raporu üzerinden

**Hindistan buğday alım verileri** — 2025-26 rabi sezonu, basın kaynakları

**Avrupa Birliği kamu müdahale alımı** — 1308/2013 sayılı Ortak Piyasa Düzeni Tüzüğü, EUR-Lex

**ABD tarımsal destek programları** — USDA Farm Service Agency; Congressional Research Service, R45165$dsr$, $dsr$**Statute of the Turkish Grain Board (Toprak Mahsulleri Ofisi Ana Statüsü)** — Official Gazette, 30 September 2021

**TMO 2025 Annual Report** (88th accounting period) — Toprak Mahsulleri Ofisi

**TMO institutional history** — Toprak Mahsulleri Ofisi

**Law no. 3491 on the Turkish Grain Board** — 24 June 1938, Official Gazette 13 July 1938

**Law no. 2056** (charging Ziraat Bankası with wheat purchasing) — Official Gazette, 10 July 1932, no. 2146

**Decree Law no. 233 on Public Economic Enterprises** — Official Gazette, 18 June 1984, no. 18435 (repeated)

**Turkish wheat production data** — TurkStat, via the TMO annual report

**Indian wheat procurement data** — 2025-26 rabi season, press sources

**EU public intervention buying** — Common Market Organisation Regulation 1308/2013, EUR-Lex

**US farm support programmes** — USDA Farm Service Agency; Congressional Research Service, R45165$dsr$, '{}'::text[], 'anlati', null)
) as v(ord, title_tr, title_en, body_tr, body_en, chart_keys, tur, gorsel)
where d.slug = 'tmo';

-- Sağlama: beklenen bölüm sayısı yazılmadıysa işlem geri alınır.
do $kontrol$
declare n integer;
begin
  select count(*) into n
    from public.dossier_sections s
    join public.country_dossiers d on d.id = s.dossier_id
   where d.slug = 'tmo';
  if n <> 11 then
    raise exception 'Bölüm sayısı 11 olmalıydı, % yazıldı', n;
  end if;
end
$kontrol$;

