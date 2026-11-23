-- Mısır — Ülke Dosyası · seed
--
-- ÜRETİLMİŞ DOSYA — elle düzenlemeyin.
-- Kaynak:  content/dossiers/misir/
-- Üretim:  node content/dossiers/seed_dossier.mjs misir
-- Tarih:   2026-11-23T06:57:50.748Z
--
-- Bölüm: 18 · TR ~3.999 kelime · EN ~5.135 kelime
-- Metindeki her rakam data.json'dan, data.json _raw/'dan geliyor.
--
-- Yeniden çalıştırılabilir: dosyayı günceller, bölümleri silip yeniden yazar.
-- Bölümler upsert değil sil-yaz, çünkü bir revizyonda bölüm sayısı azalırsa
-- upsert eski fazlalığı geride bırakırdı.

begin;

insert into public.country_dossiers
  (slug, name_tr, name_en, iso3, tur, kurulus_belgesi, edition,
   thesis_tr, thesis_en, theme, data, charts, anahtar_kelimeler,
   cover_url, cover_credit, video_url, status, starts_at, ends_at, published_at)
values (
  'misir',
  'Mısır',
  'Egypt',
  'EGY',
  'ulke',
  null,
  6,
  $dsr$Mısır toprağının %4,25'ini ekiyor ve ektiği yerin tamamı sulanıyor; suyunun %96,9'u ülke dışından geliyor. Bir tarım çalışanına 0,72 hektar — 1,71 feddan — düşüyor, Türkiye'de 7,89 hektar. Dünyanın en büyük buğday alıcısı aynı ülke, portakalda bizi 2,61 kat geçmiş durumda.$dsr$,
  $dsr$Egypt sows 4.25% of its land and every sown hectare is irrigated; 96.9% of its water originates outside the country. One agricultural worker has 0.72 hectares — 1.71 feddans — against 7.89 hectares in Türkiye. The world's largest wheat buyer is the same country, and in oranges it stands 2.61 times ahead of us.$dsr$,
  $dsr${"_dosya":"Mısır — Ülke Dosyası Sayı 06 · tasarım künyesi","_amac":"Görsel kararlar. DossierTheme bu dosyadan üretilir; kodda serbest renk yazılmaz.","_kural":"Bu dosyadaki hiçbir kontrast sayısı 'yaklaşık' değildir. Hepsi _raw/kontrast.py'den geliyor ve bu künye o betiğin çıktısından ÜRETİLDİ, elle yazılmadı. Palet değişirse betik yeniden koşar.","_sureklilik":"Altı dosya, altı geometri: Hollanda dikey şeritler (polder), Rusya yatay bantlar (toprak profili), İspanya nokta ızgarası (dikilmiş zeytinlik), Avustralya ortogonal ızgara (kanal ağı), Irak düzensiz poligon ağı (tuz kabuğu), Mısır EŞİT OLMAYAN BÖLÜNME. İlk dördü insan yapımı DÜZEN, beşincisi düzen çekildiğinde kalan biçimdi. Altıncısı ikisi de değil: bir işlemin kendi kendine tekrarı. Aynı tarla bölünüyor, bölünen parça yine bölünüyor; hücreler küçülüyor ve hiçbiri ötekine eşit değil. Dosyanın imzası bu — birimi ülke değil bir tarla, ve o tarla feddan.","tez_cumlesi":{"tr":"Mısır toprağının %4,25'ini ekiyor ve ektiği yerin tamamı sulanıyor; suyunun %96,9'u ülke dışından geliyor. Bir tarım çalışanına 0,72 hektar — 1,71 feddan — düşüyor, Türkiye'de 7,89 hektar. Dünyanın en büyük buğday alıcısı aynı ülke, portakalda bizi 2,61 kat geçmiş durumda.","en":"Egypt sows 4.25% of its land and every sown hectare is irrigated; 96.9% of its water originates outside the country. One agricultural worker has 0.72 hectares — 1.71 feddans — against 7.89 hectares in Türkiye. The world's largest wheat buyer is the same country, and in oranges it stands 2.61 times ahead of us.","gerekce":"Sıra Irak dosyasından devralındı ve kullanıcı şartının kendisi: dosya yalnız Türkiye ilişkisi üzerinden kurulmuyor. Bu yüzden ÖNCE Mısır'ın kendi tarımı — arazi, su, bir çalışanın tarlası — SONRA eksen geliyor. Türkiye cümlede iki kez var ama cümleyi yönetmiyor; gövdenin konusu Mısır'ın kendi toprağı.","_dayanak":"Beş sayının beşi de ölçüldü ve data.json'da duruyor: arazi payı FAOSTAT LandUse 2024'ten hesaplandı (4.229 / 99.545 bin ha); sulama oranı aynı kaynakta BİREBİR eşitlik olarak duruyor ve sınırı yazılı (yalnız 2021-2024); su bağımlılığı FAO AQUASTAT'ın kendi ifadesi (%96,9); çalışan başına arazi arazi ile İSTİHDAM'dan hesaplandı (nüfustan değil); portakal oranı FAOSTAT QCL'nin ortak son yılından.","_olmayan_iddia":"'Mısır'ın tarımı dışa bağımlı' gibi bir yargı cümleye KONULMADI. Cümlenin taşıdığı şey ölçülmüş olan: suyun %96,9'u dışarıdan geliyor ve buğdayda dünyanın en büyük alıcısı. 'Kendine yetmiyor' denmedi, çünkü pirinçte yetiyor ve dosyanın bir bölümü tam bunu gösteriyor.","_sayi_rakamla":"Dizide tez cümlesinde sayılar YAZIYLA yazılıyordu; kullanıcının 3 Kasım 2026 kararıyla RAKAMLA yazılıyor. Kesir deyimleri Türkçede yazıyla yazıldığı için istisna; bu cümlede kesir yok."},"palet":{"ad":"Mil ve Portakal","kaynak_fikir":"Palet manzaradan değil, dosyanın ÖLÇTÜĞÜ iki şeyden türedi. Mil (alüvyon ve onu getiren su) ülkenin kendi ürünü DEĞİL: suyun %96,9'u yukarıdan geliyor ve dosyanın ekseni bu. Portakal ise Mısır'ın kendi ürünü ve dizide ilk kez bir karşılaştırmada Türkiye'nin GERİDE olduğu kalem: 1990'da 2,14 kat, 2024'te 2,61 kat ve makas açılıyor. Yani iki renk 'ülke ve Türkiye' demiyor; 'dışarıdan gelen' ve 'burada yetişen' diyor. Üçüncü madde — bölünen tarla — renk değil MOTİF oldu.","mod":"KOYU — dosya sayfası her zaman koyu. Uygulamanın açık/koyu tercihini izlemez.","mod_gerekcesi":"Dergi dosyası mantığı: içeri girdiğinizde başka bir yere geldiğinizi anlamalısınız (İspanya'dan devralınan karar). Ana sayfadaki şerit bunun istisnasıdır — sayfanın içinde yaşadığı için açık/koyu izler.","koyu":{"zemin":{"hex":"#0F1311","rol":"Sayfa arka planı — ıslak mil, gece"},"yuzey":{"hex":"#19201D","rol":"Kart, tablo, alıntı bloğu","kontrast_zemin":1.13},"murekkep":{"hex":"#E8E4DA","rol":"Gövde metni","kontrast_zemin":14.75,"kontrast_yuzey":13.07},"sessiz":{"hex":"#9BA39C","rol":"Meta, kaynak satırı, altyazı ve YALNIZ siralama'da bağlam satırı","kontrast_zemin":7.23,"kontrast_yuzey":6.41,"_rol_siniri":"Yığılmış türlerde (ikili_cubuk, yigin) seri rengi OLAMAZ. Gerekçe ölçülü: `ChartRole.taramali` yalnız ikincil için true, yani vurgu ile sessiz aynı çubukta yan yana durduğunda ayrımı taşıyan tek şey renk olur — ve bu paletin vurgu↔sessiz oranı deuteranopi altında 1,31'e düşüyor. dogrula_grafik.py kural 20 bunu durduruyor."},"vurgu":{"hex":"#7CC9C2","rol":"Mil — rakamlar, başlık vurguları ve her grafiğin ÖNDEKİ serisi","kontrast_zemin":9.8,"kontrast_yuzey":8.68,"kontrast_murekkep":1.56,"_murekkep_notu":"Vurgu gövde metninin İÇİNDE rakam rengi olarak da kullanılıyor, o yüzden mürekkepten de 1,4 ayrışmak zorunda. Bu sınama bu dosyada kondu: onsuz arama #F5C689'u öneriyordu, mürekkepten oranı 1,25 — bütün öteki eşikleri geçiyor ve cümlenin içinde vurgu değil."},"ikincil":{"hex":"#CC7A30","rol":"Portakal — karşılaştırmanın ikinci serisi","kontrast_zemin":5.7,"kontrast_yuzey":5.05,"_rol_notu":"Irak dosyasında olduğu gibi ikincil renk 'Türkiye serisi' DEMİYOR. Bu dosyanın ikincil rollü serileri: ithalat, Mısır'ın sattığı, kentli nüfus, hasat alanı, geri kalan yüzey, ekonominin geri kalanı, yenilenebilir kaynağın tamamı — ve iki grafikte Türkiye. Yani çoğunda Türkiye yok; künyeye 'Türkiye serisi' yazmak sonraki turda grafiklerin yanlış okunmasına yol açardı.","_doygunluk_notu":"#C9772F ile #D07F33 arasında tarandı. İlki metin eşiğinde (4,87) rahat değil, ikincisinin deuteranopi altındaki seri ayrımı 1,41 — eşiğe bir yüzde birlik payla. #CC7A30 ikisinin ortası: metin 5,05, deuteranopi 1,51. Eşiği kıl payı geçen renk bir sonraki küçük değişiklikte sessizce altına düşer."},"cizgi":{"hex":"#222B27","rol":"SADECE dekoratif ayırıcı","kontrast_zemin":1.29,"kontrast_yuzey":1.14,"_uyari":"3:1'in altında. Anlam taşıyan hiçbir yerde kullanılamaz — grafik ekseni, sınır, odak halkası için cizgiVurgu kullanılır."},"cizgiVurgu":{"hex":"#717D77","rol":"Grafik ekseni, ızgara çizgisi, odak halkası","kontrast_zemin":4.37,"kontrast_yuzey":3.87}},"acik_mod_seridi":{"_amac":"Ana sayfadaki dosya şeridi sayfanın içinde yaşıyor; krem zemin üstünde koyu gövdenin renkleri okunmuyor.","murekkep":{"hex":"#161917","kontrast_krem":15.74},"vurguKoyu":{"hex":"#0B403C","rol":"Milin krem zemindeki karşılığı — kart kenarı ve açık moddaki tüm vurgu metni","kontrast_krem":10.29,"kontrast_serit_murekkebi":4.38,"_anasayfadan_ayrisma":{"darkGreen_#2F4B2E":1.44,"primaryGreen_#5C8A4A":5.15,"wheat_#C9A15A":9.51,"marketDown_#9C4A3C":3.02,"alertRed_#D32F2F":3.96}},"ikincilKoyu":{"hex":"#8A3410","rol":"Portakalın krem zemindeki karşılığı — ikinci vurgu","kontrast_krem":7.23,"kontrast_serit_murekkebi":8.51,"_anasayfadan_ayrisma":{"darkGreen_#2F4B2E":1.35,"primaryGreen_#5C8A4A":2.65,"wheat_#C9A15A":4.89,"marketDown_#9C4A3C":1.56,"alertRed_#D32F2F":2.04}},"_rol_degismedi":"IRAK'TAN AYRILAN NOKTA. Orada hangi rengin önde durduğu ZEMİNE bağlıydı: koyu sayfada hurma amberi, krem şeritte nehir mavisi. Burada DEĞİŞMİYOR — mil her iki zeminde de önde. Bu da bir ölçüm: milin koyu sürümü #0B403C ana sayfanın beş renginin en yakınından 1,44 uzakta, portakalın koyu sürümü #8A3410 ise 1,35. İkisi de eşiği (1,25) geçiyor, yani rol değiştirmeye gerek yok. İlk deneme #14544E ana sayfanın yapısal yeşiliyle 1,21 veriyordu ve koyulaştırıldı."},"renk_korlugu_notu":"Bağıl parlaklık oranı VEKİL ölçüdür ve dizide bir kez yanıldı (Hollanda: oran 1,05, deuteranopi altında ayırt edilemiyordu). O günden beri kontrast.py üç körlük tipini DOĞRUDAN benzetiyor (Viénot-Mollon, LMS izdüşümü) ve oranı benzetim sonrasında ölçüyor. Bu dosyada ikinci bir vekil — CIELAB ΔE76 — denendi ve BIRAKILDI: kalibrasyon başarısız. Hollanda'da çöken çift deuteranopi benzetimi sonrası ΔE 52,2 veriyor, yayında ÇALIŞAN Irak paleti 87,9; eşiği 52'nin üstüne koymak çalışan paletleri de keserdi. Vekili vekille denetlemek yerine kayıtlı ölçü korundu. Ölçülen değerler düzyazıda değil `_olculen_ayrisma` alanında duruyor.","_uc_yollu_ladder_denendi":"Bu dosyada 'üç rolün üçü de birbirinden 1,4 ayrışsın' kuralı denendi, çünkü sessiz dört grafikte çubuk rengi. RENK UZAYI TARANDI: 4,5 eşiğini geçen 2.374 renk, vurgu adayı olarak mürekkepten de ayrışan 1.668 renk. Geçen üçlüler VAR ama hepsinde en çok BİR rol renkli, ötekiler gri (#928787 / #AAA1A1 / #CFC9C9); doygun bir vurguyla geçen üçlülerde de ikincil griye düşüyor (#C76B6B / #B6AFAF / #D9CCBF). Yani İKİ RENKLİ bir palet bu ladder'ı sağlayamıyor — arayış değil, aritmetik. KARAR: ladder zorunlu kılınmadı; yerine sessiz yığılmış türlerde seri olarak yasaklandı (dogrula_grafik.py kural 20) ve sessiz çiftleri burada ÖLÇÜLÜ ama durdurmuyor.","_olculen_ayrisma":{"_uretim":"_raw/kontrast.py — elle yazılmaz; bu künye o betiğin çıktısından üretildi, dogrula_tasarim.py bloğu künyenin kendi hex'lerinden yeniden hesaplayıp karşılaştırır.","_esik":1.4,"_durduran":["govde","serit","vurgu_murekkep"],"_olculen_ama_durdurmayan":["vurgu_sessiz","ikincil_sessiz"],"govde":{"normal":1.85,"protanopi":2.1,"deuteranopi":1.51,"tritanopi":1.85},"serit":{"normal":1.94,"protanopi":1.54,"deuteranopi":2.78,"tritanopi":1.92},"vurgu_sessiz":{"normal":1.4,"protanopi":1.45,"deuteranopi":1.31,"tritanopi":1.41},"ikincil_sessiz":{"normal":1.32,"protanopi":1.44,"deuteranopi":1.15,"tritanopi":1.31},"vurgu_murekkep":{"normal":1.56}},"denetim_betigi":"_raw/kontrast.py — `python3 content/dossiers/misir/_raw/kontrast.py`"},"motif":{"ad":"Bölünen tarla","tanim":"Bir dikdörtgenin kendi içinde eşit olmayan parçalara bölünmesi, sonra parçaların yine bölünmesi: hücreler küçülüyor, hiçbiri ötekine eşit değil, kenarlar dik ama ritim düzensiz.","gerekce":"Dizideki altıncı geometri ve ilk kez bir DESEN değil bir İŞLEM: önceki beşi (şerit, bant, nokta, ızgara, poligon) tek seferde kurulmuş biçimlerdi; bu, aynı hareketin tekrarı. Dosyanın ölçtüğü şey bu: tarım arazisi 1961'den bu yana %64,7 büyüdü ama bir tarım çalışanına düşen alan 0,72 hektar — Türkiye'dekinin on birde biri. Toprak artıyor, pay küçülüyor. Dosyanın imzası da aynı yerden: feddan (0,42 ha) bir ülkenin değil bir tarlanın birimi.","uygulama":{"opaklik":"%4","renk":"cizgiVurgu #717D77 üzerine opaklık","bicim":"Vektör (CustomPainter) — raster değil. Ölçeklenebilir, dosya boyutu sıfır, telif sorunu yok.","yerlesim":"Bölüm ayırıcılarında ve kapak altı geçiş bandında. Gövde metninin ARKASINDA kullanılmaz.","moire_notu":"En küçük hücre kenarı 28 px'in altına inmeyecek; özyineleme derinliği buna göre durur.","_opaklik_notu":"Tuz poligonundan bir puan düşük (%5 → %4): özyinelemeli bölünme kenar sayısını katlıyor ve aynı opaklıkta gözü poligondan daha çok meşgul ediyor."},"_UYGULANMAMIŞ":"ÖNEMLİ — BU GEOMETRİ ŞU AN ÇİZİLMİYOR. Depodaki tek motif çizici `polder_motif.dart` ve `DossierTheme` motif bloğundan YALNIZCA opaklığı okuyor (`motif.uygulama.opaklik`, 0,02-0,10 arasına kırpılıyor); `motifAralik` bile JSON'dan değil yedekten geliyor. Avustralya ve Irak künyeleri bunu aynı açıklıkla yazdı ve doğru yaptı: okunmayan bir alana değer yazmak, sonraki turda 'bölünen tarla bölüm ayırıcılarında görünüyor' diye yanlış bir cümle yazdırır. Bölünen tarla bir ŞARTNAMEDİR; çizici yazılana kadar sayfada polder motifi görünür ve bu dosyada aksini iddia eden cümle yazılmayacak."},"kapak":{"yon":"Nil vadisinin çöl sınırı — yüksekten, ekili yeşil ile kumun kesiştiği çizgi kadrajın içinden geçecek kadar yakın","gerekce":"Kapak dosyanın ilk sayısını gösteriyor: %4,25. Dünyada ekili alan ile ekilmeyen arasındaki en keskin sınır burada ve sınırın kendisi bir fotoğrafta görünüyor — başka hiçbir ülke dosyasında böyle bir çizgi yoktu. Hollanda ve Rusya yörüngeden, İspanya yerden, Avustralya yüksekten, Irak alçak eğik açıdan baktı; burası yüksekten ama tek bir çizgiye odaklı.","gorsel_kaynagi":{"tercih_1":"NASA Earth Observatory / ISS astronot fotoğrafı — kamu malı; Nil vadisi ve deltası için arşivi geniş.","tercih_2":"Wikimedia Commons, açık lisanslı havadan çekim.","tercih_3":"FAO / BM fotoğraf kütüphaneleri — LİSANS TEK TEK OKUNACAK, 'BM yayını' açık lisans demek değildir.","_karar":"Görsel BULUNANA KADAR kapak tipografik iskeletle çalışır — sayfa görselsiz de tam çalışmak zorunda (§3.5).","_yasak":"Telifi belirsiz hiçbir görsel kullanılmayacak. Google görsel araması kaynak değildir.","_altyazi_kurali":"Altyazı KÜNYEDİR: konu + yer + tarih, kaynağın kendi künyesinden yazılır. Karede ne görüldüğü anlatılmaz. Kullanıcı bu düzeltmeyi iki kez verdi (8 ve 12 Kasım 2026) ve TİGEM dosyasında bu yoldan dört maddi hata girmişti.","_erisim_uyarisi":"Kaynak turlarında ölçüldü: Dünya Bankası API'si sekiz göstergenin yedisinde hata verdi, biri açıldı; FAO AQUASTAT'ın HTML sayfası JavaScript kabuğu, rakamlar yalnız PDF'te. Yumuşak 404'e karşı durum koduna değil İÇERİK TÜRÜNE ve gövde uzunluğuna bakılacak (§2.12.1)."},"tipografi_katmani":{"ust_satir":"ÜLKE DOSYASI · 06","baslik":"MISIR","alt_satir":"tez_cumlesi.tr","veri_rozeti":"Tarım çalışanı başına 1,71 feddan"},"_rozet_notu":"Rozet %96,9'u ya da dünya birinciliğini DEĞİL, feddanı söylüyor. Dosyanın imzası o birim ve rozetin işi dosyanın ölçeğini bir bakışta vermek: 1,71 feddan bir tarla, 'suyun %96,9'u' bir ülke. Dosya tarlanın hikâyesi.","_baslik_notu":"Başlık 'MISIR' — 5 harf, dizinin en kısalarından (IRAK 4, İSPANYA 7, AVUSTRALYA 10, KOOPERATİFLERİ 14). `kapakAdiOlcegi` puntoyu EN GENİŞ kelimeye bakarak küçültüyor (TİGEM turunda düzeltildi: önce harf sayısına bakıyordu ve kelimeyi ortadan bölüyordu). Taşma riski yok; ters yönde kontrol edilecek, punto ÜST sınıra dayanabilir. BÜYÜTMEDE TUZAK: 'Mısır' kelimesini büyütürken Türkçe kuralı şart — 'mısır'.upper() noktasız I vermiyor, projenin `buyult` yardımcısı kullanılacak.","okunurluk":"Görsel üzerine zemin renginden %0 → %85 dikey gradyan; metin yalnızca %60+ bölgede durur."},"_zorunluluklar":["Grafiklerde iki seri renkle BİRLİKTE biçimle de ayrılacak; bu dosyada parlaklık farkı da var ve üç körlük tipinde benzetilerek ölçüldü (gövdede en kötü 1,51, şeritte en kötü 1,54).","Yığılmış türlerde (ikili_cubuk, yigin) seri rolü vurgu + ikincil olacak; sessiz seri olarak kullanılmayacak (ölçüm: vurgu↔sessiz deuteranopi altında 1,31).","Bölünen tarla motifi CustomPainter ile çizilecek — ama çizici YAZILANA KADAR sayfada polder motifi görünür; bu dosyada aksini iddia eden cümle yazılmayacak.","Kapak görseli bulunamazsa sayfa yine de tam çalışacak.","Koyu sayfa sistem açık/koyu tercihini izlemeyecek; ana sayfa şeridi izleyecek.","Tüm renkler bu dosyadan türetilen DossierTheme üzerinden gelecek, kodda serbest hex yazılmayacak.","Palet değişirse _raw/kontrast.py yeniden çalıştırılacak ve bu künye onun çıktısından YENİDEN ÜRETİLECEK.","Ticaret rakamlarını gösteren her görsel öğe rakamın HANGİ TARAFIN beyanından olduğunu söyleyecek — iki taraf da kendi gidenini fazla sayıyor (%58,8 ve %53,1).","Sulama oranının (%100) yanında eşitliğin yalnız 2021-2024 için geçerli olduğu yazılacak."],"_yasak":["Mısır bayrağı, arması ya da herhangi bir devlet amblemi","Piramit, Sfenks, tapınak, hiyeroglif, mumya, firavun ikonografisi — dosya tarımı anlatıyor ve bu imgeler ülkeyi müzeye çeviriyor","Nil'de feluka silueti, gün batımı, palmiye — ülke kartpostalı. DEVE İÇİN GEREKÇELİ İSTİSNA (kullanıcı kararı, 13 Kasım 2026): yasak klişe ÇERÇEVEYİ hedefliyor, hayvanın kendisini değil. Deve bir manzara süsü olarak kadraja girerse bu madde geçerli; bir TARIM ALETİNİN parçası olarak girerse değil. §4'ün karesi deveyle döndürülen bir su dolabı — sakiye — ve o bölümün konusu zaten suyun tarlaya nasıl çıkarıldığı. İstisna bu kareye değil, bu AYRIMA veriliyor: aleti çalıştıran hayvan konunun kendisidir, kartpostal değil.","Dinî imge, cami silueti, hat sanatı süslemesi","Süveyş Kanalı, konteyner gemisi, liman — dosya ticareti ölçüyor ama konusu tarla","Tahrir Meydanı, kalabalık, protesto, asker — dosyada siyasi olay anlatılmıyor","Yoksulluk tasviri: yalınayak çocuk, yıkık ev, dilenen el. Dosya kırsalda yaşayan 63,7 milyon kişiyi SAYIYLA anlatıyor, görsel dil sefalet turizmine kaymayacak","Stok 'çatlamış kurak toprak' fotoğrafı — Mısır'ın tarım arazisinin tamamı sulanıyor; kuraklık bu dosyanın konusu değil","Resmî kurum logosu ya da Resmî Gazete yazı tıpkıbasımı"]}$dsr$::jsonb,
  $dsr${"arazi":{"_kapsam":"Mısır ve Türkiye'nin arazi kullanımı, 2024","_kaynak_niteligi":"BAĞIMSIZ — FAOSTAT Inputs/LandUse toplu indirme","_birim":"bin hektar","misir":{"kara_alani":99545,"tarim_arazisi":4229,"ekili_arazi":4229,"islenebilir_arazi":3274,"daimi_urun":955,"fiilen_sulanan_tarim":4229},"turkiye":{"kara_alani":76963,"tarim_arazisi":38640,"ekili_arazi":24024,"islenebilir_arazi":20224,"daimi_urun":3799,"fiilen_sulanan_tarim":4914},"misir_tarim_arazisi_serisi":{"1961":2568,"1990":2648,"2010":3671,"2020":3971,"2024":4229},"_sulama_esitligi_siniri":"FAOSTAT'ta 'fiilen sulanan tarım alanı' ile 'tarım arazisi' Mısır için BİREBİR EŞİT, ama ikisinde birden veri olan tek dönem 2021-2024 (4 yıl). Atama olabilir. 'Mısır tarımının tamamı sulamadır' cümlesi bu veriye dayanarak kurulmayacak; AQUASTAT ikinci kaynak olarak kullanılacak.","feddan_ha":0.4200833,"_feddan_tanimi":"1 feddan = 4.200,833 m² = 0,4200833 ha. Mısır'ın kendi arazi birimi; resmî istatistik hektarla yayımlanıyor, tarla hâlâ feddanla konuşuluyor."},"su":{"_kapsam":"Mısır'ın su kaynakları ve bağımlılığı","_kaynak_niteligi":"BİRİNCİL — FAO AQUASTAT ülke profili, 2016 taraması","_belge":"kaynak_dosyalari/fao_aquastat_misir_2016.pdf","disa_bagimlilik_yuzde":96.9,"_bagimlilik_alinti":"Egypt's dependency ratio is one of the world's highest with 96.9 percent of the total renewable water resources flowing into the country from neighbouring countries.","ic_yenilenebilir_milyon_m3":1800,"toplam_yenilenebilir_milyon_m3":58300,"kisi_basi_m3":699,"kisi_basi_yil":2014,"toplam_cekim_milyon_m3":68300,"cekim_yil":2000,"cekim_dagilim_yuzde":{"tarim":86,"belediye":8,"sanayi":6},"ekim_yogunlugu_yuzde":175,"ekim_yogunlugu_yil":2010,"_cekim_kaynaktan_buyuk":"DİKKAT: çekim (68.300) toplam yenilenebilir kaynaktan (58.300) BÜYÜK. Hata değil: belge sebebini yazıyor — tahliye suyu yeniden kullanılıyor ('secondary freshwater', bir kez çekilip sisteme geri dönen su). Bu iki rakam yan yana yazılırsa açıklamasız bırakılmayacak, yoksa okur veriyi yanlış sanır.","_yil_uyarisi":"Belge 2016 taraması; içindeki rakamların KENDİ yılları ayrı (çekim 2000, kişi başı 2014, baraj 2015). Hiçbiri 'bugün' diye yazılamaz — her cümlede rakamın yılı belirtilecek (§2.7)."},"tahil":{"_kapsam":"Mısır'ın buğday, mısır ve pirinç dengesi · PSD pazarlama yılı","_kaynak_niteligi":"BAĞIMSIZ — USDA FAS PSD toplu CSV","_birim":"bin ton","_pazarlama_yili_notu":"PSD pazarlama yılı. Mısır'da buğday Temmuz-Haziran; takvim yılı serileriyle oran kurulamaz.","kesin_son_yil":2024,"_ham_son_yil":2026,"bugday":{"ithalat":12467,"uretim":9000,"tuketim":20000,"ihracat":2352,"hasat_alani":1300},"bugday_turkiye":{"ithalat":3318,"uretim":19000,"tuketim":18400,"ihracat":7282,"hasat_alani":7250},"dunya_bugday_ithalati":201487,"misir_dunya_sirasi":1,"turkiye_dunya_sirasi":21,"ithalat_ilk_6":[{"ulke":"Egypt","bin_ton":12467},{"ulke":"European Union","bin_ton":10715},{"ulke":"Indonesia","bin_ton":10452},{"ulke":"Algeria","bin_ton":9100},{"ulke":"Brazil","bin_ton":7198},{"ulke":"Philippines","bin_ton":6351}],"_dunya_notu":"PSD'de World satırı yok; toplam ülkelerin toplamı. AB küme satırı var, üye satırı YOK — çift sayım ölçüldü ve yok.","tane_misir":{"ithalat":10564,"uretim":7000,"tuketim":17300,"ihracat":1,"hasat_alani":920,"yemlik":14700},"tane_misir_turkiye":{"ithalat":5654,"uretim":6800,"tuketim":11700,"ihracat":392,"hasat_alani":560,"yemlik":10300},"pirinc":{"ithalat":160,"uretim":3900,"tuketim":4050,"ihracat":154,"hasat_alani":670,"yemlik":null},"pirinc_turkiye":{"ithalat":358,"uretim":580,"tuketim":795,"ihracat":248,"hasat_alani":97,"yemlik":null},"_oteki_tane_yili":2024,"_ad_notu":"'tane_misir' TANE MISIR (Corn). Ülke Mısır her yerde 'misir'. İki kelime Türkçede aynı; karıştırılırsa betik hata vermez, sessizce yanlış rakam yazar.","bugday_ithalat_serisi":{"1960":996,"1961":1709,"1962":1730,"1963":1933,"1964":1977,"1965":2344,"1966":2498,"1967":2782,"1968":1940,"1969":2220,"1970":2835,"1971":2590,"1972":3040,"1973":3180,"1974":3490,"1975":3800,"1976":3883,"1977":4344,"1978":5119,"1979":4906,"1980":5423,"1981":5878,"1982":5503,"1983":5857,"1984":6302,"1985":6236,"1986":7022,"1987":7473,"1988":7408,"1989":7258,"1990":5680,"1991":5807,"1992":6004,"1993":5866,"1994":5856,"1995":5932,"1996":6893,"1997":7134,"1998":7454,"1999":5872,"2000":6050,"2001":6944,"2002":6327,"2003":7295,"2004":8150,"2005":7771,"2006":7300,"2007":7700,"2008":9900,"2009":10500,"2010":10600,"2011":11650,"2012":8400,"2013":10150,"2014":11300,"2015":11925,"2016":11181,"2017":12407,"2018":12354,"2019":12811,"2020":12149,"2021":11256,"2022":11218,"2023":12440,"2024":12467}},"urunler":{"_kapsam":"Rakip ürünlerde Mısır–Türkiye karşılaştırması, ortak son yıl","_kaynak_niteligi":"BAĞIMSIZ — FAOSTAT QCL toplu CSV","_birim":"ton","_ortak_son_yil":{"narenciye_toplam":2024,"portakal":2024,"mandalina":2024,"limon":2024,"patates":2024,"kuru_sogan":2024,"domates":2024,"pirinc":2024,"cigit_pamuk":2024,"pamuk_lifi":2023,"bugday":2024},"karsilastirma":{"portakal":{"yil":2024,"misir":4200000,"turkiye":1610000},"pirinc":{"yil":2024,"misir":6430000,"turkiye":1019000},"kuru_sogan":{"yil":2024,"misir":3439646.05,"turkiye":2632000},"patates":{"yil":2024,"misir":8082290.82,"turkiye":6900000},"narenciye_toplam":{"yil":2024,"misir":5857699.84,"turkiye":5481576},"mandalina":{"yil":2024,"misir":1265813.33,"turkiye":1988000},"domates":{"yil":2024,"misir":7521071.26,"turkiye":14617000},"bugday":{"yil":2024,"misir":9400000,"turkiye":20800000},"limon":{"yil":2024,"misir":381920.58,"turkiye":1730000},"cigit_pamuk":{"yil":2024,"misir":228179.22,"turkiye":2243000}},"pamuk_serisi":{"1961":{"uretim":994098,"alan":834385},"1965":{"uretim":1481700,"alan":798200},"1980":{"uretim":1408267,"alan":522701},"2000":{"uretim":553883,"alan":217781},"2010":{"uretim":377527,"alan":155039},"2020":{"uretim":160000,"alan":76918},"2024":{"uretim":228179.22,"alan":81499}},"pamuk_endeks":[{"yil":1961,"uretim":100,"alan":100},{"yil":1966,"uretim":129.7,"alan":93.6},{"yil":1971,"uretim":142.6,"alan":76.8},{"yil":1976,"uretim":108,"alan":62.8},{"yil":1981,"uretim":133.4,"alan":59.3},{"yil":1986,"uretim":112.7,"alan":53.1},{"yil":1991,"uretim":81.9,"alan":42.9},{"yil":1996,"uretim":96.6,"alan":46.4},{"yil":2001,"uretim":83.7,"alan":36.8},{"yil":2006,"uretim":59.4,"alan":27},{"yil":2011,"uretim":63.8,"alan":26.2},{"yil":2016,"uretim":14.6,"alan":6.6},{"yil":2021,"uretim":30.7,"alan":12},{"yil":2024,"uretim":23,"alan":9.8}],"_pamuk_endeks_notu":"Taban 1961 = 100. İki seri aynı birimde (indeks) olduğu için tek eksende çizilebiliyor; ton ile hektar çizilemez.","portakal_cizgi":[{"yil":1961,"misir":157000,"turkiye":177836},{"yil":1970,"misir":567000,"turkiye":445000},{"yil":1980,"misir":920881,"turkiye":679000},{"yil":1990,"misir":1574287,"turkiye":735000},{"yil":2000,"misir":1610520,"turkiye":1070000},{"yil":2010,"misir":2401015,"turkiye":1710500},{"yil":2020,"misir":3966200,"turkiye":1333975},{"yil":2024,"misir":4200000,"turkiye":1610000}]},"ticaret":{"_kapsam":"Türkiye–Mısır tarım ticareti, 2024 · HS 01-24","_kaynak_niteligi":"BAĞIMSIZ — UN Comtrade; İKİ TARAFIN da beyanı alındı","_birim":"ABD doları","_suzgec":"customsCode=C00, motCode=0, partner2Code=0 (çift sayım)","tr_beyani_giden":424023474,"misir_beyani_gelen":267043294.82699996,"misir_beyani_giden":281951888.598,"tr_beyani_gelen":184199173,"tr_dunyaya_tarim":32541007957,"misir_dunyaya_tarim":9983528366.859999,"tr_misira_toplam":4175857770,"fasil_giden":[{"fasil":"15","deger":84061216},{"fasil":"07","deger":57844083},{"fasil":"08","deger":56949173},{"fasil":"20","deger":36895237},{"fasil":"04","deger":31591683},{"fasil":"11","deger":23897136},{"fasil":"17","deger":23614584},{"fasil":"10","deger":21395459},{"fasil":"16","deger":20511910},{"fasil":"24","deger":16005371},{"fasil":"18","deger":14593608},{"fasil":"12","deger":7820532},{"fasil":"23","deger":7684298},{"fasil":"09","deger":7310166},{"fasil":"19","deger":7293196},{"fasil":"21","deger":4950914},{"fasil":"05","deger":677454},{"fasil":"22","deger":422607},{"fasil":"03","deger":167879},{"fasil":"14","deger":153595},{"fasil":"02","deger":83284},{"fasil":"01","deger":74488},{"fasil":"13","deger":14882},{"fasil":"06","deger":10719}],"fasil_gelen":[{"fasil":"07","deger":90098423},{"fasil":"08","deger":36916476},{"fasil":"12","deger":19286988},{"fasil":"17","deger":10119238},{"fasil":"20","deger":8945537},{"fasil":"21","deger":4226068},{"fasil":"19","deger":3542751},{"fasil":"03","deger":3436149},{"fasil":"09","deger":3180169},{"fasil":"10","deger":1264786},{"fasil":"15","deger":975574},{"fasil":"14","deger":769482},{"fasil":"22","deger":526360},{"fasil":"06","deger":435986},{"fasil":"18","deger":210223},{"fasil":"23","deger":123223},{"fasil":"04","deger":42140},{"fasil":"01","deger":39410},{"fasil":"13","deger":38900},{"fasil":"05","deger":13905},{"fasil":"11","deger":7375},{"fasil":"16","deger":10}]},"makro":{"_kapsam":"Nüfus, tarım istihdamı ve katma değer","_kaynak_niteligi":"BAĞIMSIZ — FAOSTAT Macro-Statistics / Population / Employment","_kapsam_uyarisi":"Katma değer kalemi ORMANCILIK VE BALIKÇILIK DAHİL (22016). Saf tarım kalemi (22010) bu iki ülke için FAOSTAT'ta yok.","_projeksiyon_uyarisi":"Nüfus serisi FAOSTAT'ta 2100'e kadar gidiyor ve BAYRAK AYIRMIYOR (1950-2100 arası hepsi 'X' = dış kuruluş rakamı). Tahmin ile PROJEKSİYON yıla göre ayrıldı: 2026'den sonrası projeksiyondur ve ayrı alanda duruyor. 'Mısır'ın nüfusu' cümlesi projeksiyon yılından kurulamaz.","_taban_notu":"GSYH payı US$ tabanlı (eleman 6103). Yerel para tabanıyla (61570) AYNI DEĞİL.","misir":{"nufus_bin":120101.175,"nufus_yil":2026,"kirsal_bin":63741.94,"tarim_istihdami_bin":5898.48,"tarim_istihdami_yil":2025,"katma_deger_milyon_usd":41971.684437,"gsyh_milyon_usd":368415.967998,"katma_deger_yil":2025},"turkiye":{"nufus_bin":87926.082,"nufus_yil":2026,"kirsal_bin":18414.903,"tarim_istihdami_bin":4898.75,"tarim_istihdami_yil":2025,"katma_deger_milyon_usd":68840.436456,"gsyh_milyon_usd":1557458.045609,"katma_deger_yil":2025},"_reddedilen_ilk_olcum_bin":1102,"_reddedilen_olcum_notu":"YANLIŞ RAKAM, kasıtlı olarak kayıtlı. Cinsiyet boyutu süzülmediği için yalnız bir dilim okunduğunda Mısır tarım istihdamı 1.102 bin çıkıyor. Doğrusu 5.898 bin. Metin bunu uyarı olarak anıyor."},"belge":{"_kapsam":"Türkiye–Mısır Serbest Ticaret Anlaşması","_kaynak_niteligi":"BİRİNCİL — Resmî Gazete nüshası","ad":"Türkiye Cumhuriyeti ile Mısır Arap Cumhuriyeti Arasında Bir Serbest Ticaret Alanı Tesis Eden Anlaşma","imza":"27 Aralık 2005, Kahire","uygun_bulma_kanunu":"5563 sayılı Kanun, 13/12/2006","karar":"2007/11557, 15/1/2007","resmi_gazete":"30 Ocak 2007 · sayı 26419 MÜKERRER","yururluk":"1 Mart 2007","_mukerrer_notu":"Belge ana nüshanın içindekiler listesinde YOK, Mükerrer ekte. TİGEM'i kuran KHK de 18205 Mükerrer'deydi.","_ekler":"Açıldı: 19 dosya. Tarım tavizleri PROTOKOL II'de, iki tablo halinde. Protokol I, Liste 1-4, ekler.xls ve EK I sanayi ürünlerine ait.","taviz":{"_kaynak_niteligi":"BİRİNCİL — anlaşmanın Türkçe nüshasının eki, Protokol II","_kapsam":"Temel tarım, işlenmiş tarım ve balıkçılık ürünlerinde taviz değişimi","tablo_a_kota_ton":54500,"tablo_a_kota_grubu":16,"tablo_a_pozisyon":18,"tablo_a_sinirsiz":0,"tablo_b_kota_ton":58015,"tablo_b_kota_grubu":22,"tablo_b_pozisyon":27,"tablo_b_sinirsiz":2,"pirinc_kotasi_ton":40000,"pirinc_kahverengi_ton":30000,"pirinc_degirmen_ton":10000,"pirinc_degirmen_indirim_yuzde":50,"pirinc_payi_tablo_b_yuzde":68.9,"yag_kotasi_ton":41000,"yag_payi_tablo_a_yuzde":75.2,"sebze_kotasi_ton":600,"sebze_pozisyon_sayisi":6,"_sinirsiz_notu":"'Sınırsız' SIFIR DEĞİL, sınır yok demek. Tablo B'de iki satır böyle (balıkçılık faslı %50, canlı bitkiler %100); Tablo A'da hiç yok. Toplam kotaya girmiyorlar, ayrıca sayılıyorlar.","_simetrik_blok":"1704, 1806, 1902, 1905, 2001.10, 2008, 2009 ve 2102.10 iki tabloda da AYNI kota ve AYNI %15 indirimle duruyor — işlenmiş gıdada taviz birebir aynalı."}},"anlati":{"_kapsam":"§2.8'in iki kategorisi — bilim/kişi ve kültürel açıklama","_kaynak_niteligi":"KARMA — ayrıntı ve nitelik _raw/bolum28.json'da","jumel":{"dogum":1785,"olum":1823,"misira_gelis":1817,"ilk_ekim_denemesi":1821,"_yil_celiskisi":"Keşif/ilk ekim yılı kaynaklarda 1818, 1819 ve 1821 olarak AYRIŞIYOR. 1821 yalnız Al Manassa'nın cümlesine dayanıyor. Metin TEK YIL İDDİA ETMEYECEK; 1817 (Mısır'a geliş) sağlam, ekim yılı aralık.","kantar_kg":45,"ilk_uretim_kantar":1000,"kirk_yil_sonra_kantar":1180000,"_kantar_notu":"Kantar pamuğa mahsus tarihsel birim, kabaca 45 kg. İki üretim rakamı da Al Manassa'nın aktarımı — İKİNCİL kaynak, birincil belge bulunamadı."},"pirinc_suzulmesi":{"yil":2023,"kuzey_azalma_yuzde":19,"kuzey_azalma_deniz_yukselmesiyle_yuzde":17,"_nitelik":"BİRİNCİL — Abd-Elaty vd., Journal of Hydrology: Regional Studies 48, 101466, doi 10.1016/j.ejrh.2023.101466","_sinir":"Bulgu SAYISAL MODELDEN (SEAWAT), saha ölçümünden değil. Sonuç nereye ekildiğine bağlı; orta ve güney bölge rakamları kaynaklar arasında tutarsız ve KULLANILMIYOR. Pirincin bu amaçla ekildiğini doğrulayan kaynak yok — yan etki. Devlet deltanın bazı yerlerinde pirinci su tasarrufu için kısıtlıyor."}},"turetilmis":{"_kapsam":"Metnin kullanacağı oranlar — cümlede hesap yapılmaz","_kaynak_niteligi":"TÜRETİLMİŞ — yukarıdaki bloklardan hesaplandı","tarim_arazisi_payi_misir":4.25,"tarim_arazisi_payi_turkiye":50.21,"sulanan_payi_misir":100,"sulanan_payi_turkiye":12.72,"ha_kisi_misir":0.72,"ha_kisi_turkiye":7.89,"ha_kisi_kat":11,"feddan_kisi_misir":1.71,"arazi_buyumesi_1961_2024_yuzde":64.7,"bugday_ithal_payi_yuzde":62.3,"bugday_dunya_payi_yuzde":6.2,"ayna_fark_giden_yuzde":58.8,"ayna_fark_gelen_yuzde":53.1,"misir_payi_tr_tarim_ihracatinda_yuzde":1.3,"tr_payi_misir_tarim_ihracatinda_yuzde":2.82,"kirsal_payi_misir_yuzde":53.1,"kirsal_payi_turkiye_yuzde":20.9,"katma_deger_payi_misir_yuzde":11.39,"katma_deger_payi_turkiye_yuzde":4.42,"pamuk_dusus_yuzde":-84.6,"pamuk_alan_dusus_yuzde":-90.2,"pamuk_dusus_1961_tabanli_yuzde":-77,"oran_portakal":2.61,"oran_pirinc":6.31,"oran_kuru_sogan":1.31,"oran_patates":1.17,"oran_narenciye_toplam":1.07,"oran_mandalina":0.64,"oran_domates":0.51,"oran_bugday":0.45,"oran_limon":0.22,"oran_cigit_pamuk":0.1,"bugday_ithal_payi_arzda_yuzde":58.1,"tane_misir_ithal_payi_arzda_yuzde":60.1,"pirinc_ithal_payi_arzda_yuzde":3.9,"oran_portakal_1990":2.14,"oran_portakal_2024":2.61,"tarim_disi_payi_misir":95.75,"tarim_disi_payi_turkiye":49.79,"kentli_payi_misir_yuzde":46.9,"kentli_payi_turkiye_yuzde":79.1,"ic_kaynak_payi_yuzde":3.1,"tarim_istihdami_fark_bin":1000,"arazi_artis_1961_1990_bin_ha":80,"arazi_artis_1990_2010_bin_ha":1023,"kirsal_nufusun_tarim_calisani_payi_yuzde":9.3,"katma_deger_payi_kat":2.58,"uc_tane_hasat_alani_bin_ha":2890,"bugday_tane_misir_alani_bin_ha":2220,"su_aralik_kati":37.9,"katma_deger_disi_payi_misir_yuzde":88.61,"katma_deger_disi_payi_turkiye_yuzde":95.58,"bugday_ithalat_ilk_yil":1960,"bugday_ithalat_kati":12.5,"pamuk_verim_kati":2.35,"fasil_iki_yonlu":[{"fasil":"07","toplam_usd":147942506,"giden_yuzde":39.1,"gelen_yuzde":60.9},{"fasil":"08","toplam_usd":93865649,"giden_yuzde":60.7,"gelen_yuzde":39.3},{"fasil":"15","toplam_usd":85036790,"giden_yuzde":98.9,"gelen_yuzde":1.1},{"fasil":"20","toplam_usd":45840774,"giden_yuzde":80.5,"gelen_yuzde":19.5},{"fasil":"17","toplam_usd":33733822,"giden_yuzde":70,"gelen_yuzde":30}],"_fasil_iki_yonlu_notu":"Pay O FASLIN iki yönlü toplamına göre, bütün ticarete göre değil. Yalnız iki yönde de satır bulunan fasıllar var; tek yönlü olanlar (yağ, süt) buraya girmiyor — tek yönlü faslın 'payı' yoktur."},"bosluklar":[],"_dosya":"Mısır — Ülke Dosyası sayı 06","_eksen":"Kirayla tarım: toprağının kırkta birini ekiyor, suyunun %96,9'u dışarıdan geliyor, buğdayda dünyanın en büyük alıcısı — ve rafımızdaki rakip.","_imza":"Feddan (0,42 ha). Dosyanın birimi ülke değil bir tarla.","_uretim":"build_data.py · 12 Kasım 2026"}$dsr$::jsonb,
  $dsr${"feddan":{"tur":"kunye","baslik":{"tr":"Dosyanın birimi","en":"The unit of this dossier"},"not":{"tr":"Feddan Mısır'ın kendi arazi birimi: 4.200,833 m², hektarın biraz altında. Resmî istatistik hektarla yayımlanıyor, tarla hâlâ feddanla konuşuluyor. Dört rakamın üçü 2024-2025 ölçümü; su bağımlılığı FAO'nun 2016 taramasından ve belgenin kendi içindeki rakamların yılları ayrı.","en":"The feddan is Egypt's own land unit: 4,200.833 m², a little under a hectare. Official statistics are published in hectares; the field is still spoken of in feddans. Three of the four figures are 2024-2025 measurements; the water dependency comes from FAO's 2016 review, whose internal figures carry their own separate years."},"kaynak":"FAOSTAT 2024-2025 · FAO AQUASTAT 2016","kalemler":[{"deger":0.4200833,"ondalik":2,"sonek":{"tr":" ha","en":" ha"},"etiket":{"tr":"Bir feddan","en":"One feddan"},"alt":{"tr":"4.200,833 m²","en":"4,200.833 m²"}},{"deger":1.71,"ondalik":2,"sonek":{"tr":" feddan","en":" feddan"},"etiket":{"tr":"Tarım çalışanı başına arazi","en":"Farmland per agricultural worker"},"alt":{"tr":"arazi 2024 · çalışan 2025","en":"land 2024 · workers 2025"}},{"deger":4.25,"ondalik":2,"onek":{"tr":"%","en":""},"sonek":{"tr":"","en":"%"},"etiket":{"tr":"Ülke yüzeyinin tarım arazisi olan payı","en":"Share of the country's surface that is farmland"},"alt":{"tr":"2024","en":"2024"}},{"deger":96.9,"ondalik":1,"onek":{"tr":"%","en":""},"sonek":{"tr":"","en":"%"},"etiket":{"tr":"Suyun ülke dışından gelen payı","en":"Share of water originating outside the country"},"alt":{"tr":"AQUASTAT, 2016 taraması","en":"AQUASTAT, 2016 review"}}]},"kirkta_bir":{"tur":"ikili_cubuk","baslik":{"tr":"Kırkta bir","en":"One part in forty"},"not":{"tr":"Mısır'ın yüzeyinin %4,25'i tarım arazisi; Türkiye'nin %50,21'i. Oran ülke yüzeyine göre, ekilebilir toprağa göre değil: Mısır'ın geri kalanı çöl ve tarım arazisi sayılmıyor. Her satır KENDİ içinde oranlanıyor; iki satır birbiriyle karşılaştırılmıyor — ülkelerin yüzeyleri farklı.","en":"4.25% of Egypt's surface is agricultural land; 50.21% of Türkiye's. The ratio is against total land area, not against arable soil: the rest of Egypt is desert and is not counted as farmland. Each row is scaled within itself; the two rows are not compared with each other — the countries' surfaces differ."},"kaynak":"FAOSTAT Inputs/LandUse, 2024","seriler":[{"ad":{"tr":"Tarım arazisi","en":"Agricultural land"},"rol":"vurgu"},{"ad":{"tr":"Geri kalan yüzey","en":"The rest of the surface"},"rol":"ikincil"}],"satirlar":[{"etiket":{"tr":"Mısır","en":"Egypt"},"yil":2024,"degerler":[4.25,95.75],"ondalik":2,"onek":{"tr":"%","en":""},"sonek":{"tr":"","en":"%"},"rozet":{"tr":"99.545 bin ha yüzey","en":"99,545 thousand ha of land"}},{"etiket":{"tr":"Türkiye","en":"Türkiye"},"yil":2024,"degerler":[50.21,49.79],"ondalik":2,"onek":{"tr":"%","en":""},"sonek":{"tr":"","en":"%"},"rozet":{"tr":"76.963 bin ha yüzey","en":"76,963 thousand ha of land"}}]},"on_bir_kat":{"tur":"siralama","baslik":{"tr":"Bir çalışanın tarlası","en":"One worker's field"},"birim":{"tr":"hektar · tarım çalışanı başına tarım arazisi","en":"hectares · agricultural land per agricultural worker"},"ondalik":2,"not":{"tr":"Mısır'da tarımda çalışan 5.898 bin kişiye 4.229 bin hektar tarım arazisi düşüyor: kişi başına 0,72 hektar, yani 1,71 feddan. Türkiye'de 4.899 bin kişiye 38.640 bin hektar düşüyor: 7,89 hektar. Arada 11,0 kat var. Payda İSTİHDAM, nüfus değil; cinsiyet dilimi Total alındı (ilk ölçümde yalnız bir dilim okunmuş ve Mısır 1.102 bin çıkmıştı).","en":"In Egypt 5,898 thousand people working in agriculture share 4,229 thousand hectares of farmland: 0.72 hectares each, that is 1.71 feddans. In Türkiye 4,899 thousand people share 38,640 thousand hectares: 7.89 hectares. The gap is 11.0 fold. The denominator is EMPLOYMENT, not population; the sex dimension was taken as Total (the first measurement read a single slice and returned 1,102 thousand for Egypt)."},"kaynak":"FAOSTAT LandUse 2024 · FAOSTAT Employment Indicators 2025","satirlar":[{"etiket":{"tr":"Türkiye","en":"Türkiye"},"deger":7.89,"rol":"ikincil"},{"etiket":{"tr":"Mısır","en":"Egypt"},"deger":0.72,"rol":"vurgu"}]},"suyun_defteri":{"tur":"siralama","baslik":{"tr":"Çekilen su, kaynaktan fazla","en":"More water withdrawn than the source holds"},"birim":{"tr":"milyon m³ · yıl","en":"million m³ · year"},"ondalik":0,"not":{"tr":"Üç rakam aynı suyu üç ayrı yerden sayıyor. Ülke içinde yenilenen su 1.800 milyon m³; bütün yenilenebilir kaynak 58.300 milyon m³, yani %96,9'u ülke dışından geliyor. Çekim ise 68.300 milyon m³ — kaynağın kendisinden BÜYÜK. Veri hatası değil: belge sebebini yazıyor, tahliye suyu yeniden kullanılıyor ve bir kez çekilen su sisteme geri dönüyor. Çekimin %86'sı tarıma gidiyor. Üç rakamın yılları ayrı (kaynak 2016 taraması, çekim 2000) ve bu grafikte toplanmıyorlar.","en":"Three figures count the same water in three different places. Water renewed inside the country is 1,800 million m³; all renewable resources are 58,300 million m³, so 96.9% originates outside. Withdrawal is 68,300 million m³ — LARGER than the resource itself. This is not a data error: the source document explains it, drainage water is reused and water withdrawn once returns to the system. 86% of withdrawal goes to agriculture. The three figures carry different years (resources from the 2016 review, withdrawal from 2000) and are not added together here."},"kaynak":"FAO AQUASTAT · Mısır ülke profili, 2016 taraması","satirlar":[{"etiket":{"tr":"Çekilen su · 2000","en":"Water withdrawn · 2000"},"deger":68300,"rol":"vurgu"},{"etiket":{"tr":"Yenilenebilir kaynağın tamamı","en":"All renewable resources"},"deger":58300,"rol":"ikincil"},{"etiket":{"tr":"Ülke içinde yenilenen","en":"Renewed inside the country"},"deger":1800,"rol":"sessiz"}]},"ayni_tarla":{"tur":"kartlar","baslik":{"tr":"Aynı tarla, yılda bir buçuk kez","en":"The same field, one and a half times a year"},"not":{"tr":"Üç rakam tek bir düzeni anlatıyor: arazi az, su dışarıdan geliyor, o yüzden aynı toprak yılda birden fazla hasat veriyor. Ekim yoğunluğu 2010 taramasından; kişi başına su 2014. Kartlardaki rakamlar ayrı yıllardan ve birbirine oranlanmıyor.","en":"Three figures describe one arrangement: land is scarce, water comes from outside, and so the same soil yields more than one harvest a year. The cropping intensity is from the 2010 review, the per capita water figure from 2014. The figures on the cards come from different years and are not ratios of one another."},"kaynak":"FAO AQUASTAT 2016 taraması · FAOSTAT LandUse 2024","kartlar":[{"ust":{"tr":"AQUASTAT · 2010","en":"AQUASTAT · 2010"},"baslik":{"tr":"Ekim yoğunluğu","en":"Cropping intensity"},"govde":{"tr":"Yüzde yüzün üstündeki her puan, aynı tarlanın yıl içinde ikinci kez ekildiği anlamına geliyor. 175, ortalama bir tarlanın yılda bir buçuk kattan fazla hasat verdiğini söylüyor.","en":"Every point above one hundred per cent means the same field was sown a second time within the year. 175 says the average field yields more than one and a half harvests a year."},"rakam":{"deger":175,"ondalik":0,"onek":{"tr":"%","en":""},"sonek":{"tr":"","en":"%"},"etiket":{"tr":"ekilen alan / tarım arazisi","en":"area sown / agricultural land"}}},{"ust":{"tr":"FAOSTAT · 2024","en":"FAOSTAT · 2024"},"baslik":{"tr":"Sulanan tarım arazisi","en":"Irrigated agricultural land"},"govde":{"tr":"FAOSTAT'ta Mısır'ın fiilen sulanan alanı ile tarım arazisi BİREBİR aynı sayı. Eşitlik yalnız 2021-2024 için var; daha eski yıllarda iki kalem ayrışıyor. Sulanmayan tarım arazisi kaydı yok demek daha doğru.","en":"In FAOSTAT the area actually irrigated and the agricultural land of Egypt are the SAME number. The identity holds only for 2021-2024; in earlier years the two items diverge. It is more accurate to say no unirrigated farmland is recorded."},"rakam":{"deger":100,"ondalik":0,"onek":{"tr":"%","en":""},"sonek":{"tr":"","en":"%"},"etiket":{"tr":"2021-2024 için","en":"for 2021-2024"}}},{"ust":{"tr":"AQUASTAT · 2014","en":"AQUASTAT · 2014"},"baslik":{"tr":"Kişi başına yenilenebilir su","en":"Renewable water per person"},"govde":{"tr":"Bin metreküpün altı uluslararası tanımda su kıtlığı sayılıyor. Rakam 2014'e ait; nüfus o yıldan bugüne yirmi milyondan fazla arttı, yani pay azaldı.","en":"Below one thousand cubic metres counts as water scarcity in the international definition. The figure is for 2014; the population has since grown by more than twenty million, so the share has fallen."},"rakam":{"deger":699,"ondalik":0,"sonek":{"tr":" m³","en":" m³"},"etiket":{"tr":"kişi başına · yıl","en":"per person · year"}}}]},"arazinin_egrisi":{"tur":"cizgi","baslik":{"tr":"Altmış üç yılda kazanılan toprak","en":"Land gained in sixty-three years"},"birim":{"tr":"bin hektar · tarım arazisi","en":"thousand hectares · agricultural land"},"ondalik":0,"not":{"tr":"Mısır'ın tarım arazisi 1961'de 2.568 bin hektardı, 2024'te 4.229 bin hektar: %64,7 artış. Artışın kaynağı çölde açılan yeni araziler. Eğri beş ölçüm noktasından geçiyor (1961, 1990, 2010, 2020, 2024) — aradaki yıllar çizilmedi, ara dalgalanma bu grafikte görünmez.","en":"Egypt's agricultural land was 2,568 thousand hectares in 1961 and 4,229 thousand in 2024: a 64.7% increase. The increase comes from new land opened in the desert. The curve passes through five measured points (1961, 1990, 2010, 2020, 2024) — the years between were not plotted, so intermediate swings are invisible here."},"kaynak":"FAOSTAT Inputs/LandUse · 1961-2024","seriler":[{"ad":{"tr":"Mısır · tarım arazisi","en":"Egypt · agricultural land"},"rol":"vurgu","noktalar":{"harita":{"1961":2568,"1990":2648,"2010":3671,"2020":3971,"2024":4229}}}]},"dunyanin_alicisi":{"tur":"siralama","baslik":{"tr":"Dünyanın en büyük buğday alıcısı","en":"The world's largest wheat buyer"},"birim":{"tr":"bin ton · ithalat · 2024/25 pazarlama yılı","en":"thousand tonnes · imports · 2024/25 marketing year"},"ondalik":0,"not":{"tr":"Mısır 12.467 bin ton buğday ithal ediyor ve listenin başında. İkinci sıradaki Avrupa Birliği bir KÜME satırı; PSD'de hiçbir AB üyesinin ayrı satırı yok, yani küme ile üyeler aynı toplamda buluşmuyor ve çift sayım ölçülerek yok olduğu doğrulandı. Dünya toplamı ülkelerin toplanmasıyla bulundu — PSD'de World satırı yok.","en":"Egypt imports 12,467 thousand tonnes of wheat and heads the list. The European Union in second place is an AGGREGATE row; PSD carries no separate row for any EU member, so the aggregate and its members never meet in the same total, and the absence of double counting was verified by measurement. The world total was obtained by summing countries — PSD has no World row."},"kaynak":"USDA FAS PSD · 2024/25 pazarlama yılı","satirlar":[{"etiket":{"tr":"Mısır","en":"Egypt"},"deger":12467,"rol":"vurgu"},{"etiket":{"tr":"Avrupa Birliği · küme","en":"European Union · aggregate"},"deger":10715,"rol":"sessiz"},{"etiket":{"tr":"Endonezya","en":"Indonesia"},"deger":10452,"rol":"sessiz"},{"etiket":{"tr":"Cezayir","en":"Algeria"},"deger":9100,"rol":"sessiz"},{"etiket":{"tr":"Brezilya","en":"Brazil"},"deger":7198,"rol":"sessiz"},{"etiket":{"tr":"Filipinler","en":"Philippines"},"deger":6351,"rol":"sessiz"}]},"ithalatin_egrisi":{"tur":"cizgi","baslik":{"tr":"Altmış dört yılda on iki kat","en":"Twelvefold in sixty-four years"},"birim":{"tr":"bin ton · Mısır'ın buğday ithalatı","en":"thousand tonnes · Egypt's wheat imports"},"ondalik":0,"not":{"tr":"1960'ta 996 bin ton, 2024'te 12.467 bin ton: 12,5 kat. Aynı dönemde nüfus da dört kattan fazla arttı, yani eğrinin tamamı nüfusla açıklanmıyor ama bir kısmı onunla açıklanıyor. Seri KESİN son yılda kesildi; PSD'nin yayımladığı son iki pazarlama yılı tahmin ve öngörü, çizgiye katılmadı.","en":"996 thousand tonnes in 1960, 12,467 thousand in 2024: 12.5 fold. Over the same period the population more than quadrupled, so the curve is not fully explained by population growth — but part of it is. The series was cut at the last DEFINITE year; the two most recent marketing years PSD publishes are an estimate and a forecast and were left out of the line."},"kaynak":"USDA FAS PSD · 1960-2024 pazarlama yılları","seriler":[{"ad":{"tr":"Mısır · buğday ithalatı","en":"Egypt · wheat imports"},"rol":"vurgu","noktalar":{"harita":{"1960":996,"1961":1709,"1962":1730,"1963":1933,"1964":1977,"1965":2344,"1966":2498,"1967":2782,"1968":1940,"1969":2220,"1970":2835,"1971":2590,"1972":3040,"1973":3180,"1974":3490,"1975":3800,"1976":3883,"1977":4344,"1978":5119,"1979":4906,"1980":5423,"1981":5878,"1982":5503,"1983":5857,"1984":6302,"1985":6236,"1986":7022,"1987":7473,"1988":7408,"1989":7258,"1990":5680,"1991":5807,"1992":6004,"1993":5866,"1994":5856,"1995":5932,"1996":6893,"1997":7134,"1998":7454,"1999":5872,"2000":6050,"2001":6944,"2002":6327,"2003":7295,"2004":8150,"2005":7771,"2006":7300,"2007":7700,"2008":9900,"2009":10500,"2010":10600,"2011":11650,"2012":8400,"2013":10150,"2014":11300,"2015":11925,"2016":11181,"2017":12407,"2018":12354,"2019":12811,"2020":12149,"2021":11256,"2022":11218,"2023":12440,"2024":12467}}}]},"uc_tane":{"tur":"yigin","baslik":{"tr":"Susuz taneyi alıyor, susuz olmayanı ekiyor","en":"It buys the thirsty-less grain and grows the thirsty one"},"not":{"tr":"Üç çubuk, üç tane. Her çubuk kendi arzına oranlanıyor: üretim artı ithalat. Buğdayda arzın %58,1'i, tane mısırda %60,1'i dışarıdan geliyor; pirinçte yalnız %3,9'u. Pirinç üçünün en çok su isteyeni ve ülke onu kendisi yetiştiriyor. Çubuklar arz; tüketim, stok ve ihracat bu grafikte yok — dengenin tamamı değil, arzın kaynağı çiziliyor. 'Tane mısır' TANE MISIR; ülkenin adıyla karıştırılmaz.","en":"Three bars, three grains. Each bar is scaled to its own supply: production plus imports. In wheat 58.1% of supply comes from outside, in maize 60.1%; in rice only 3.9%. Rice is the thirstiest of the three and the country grows it itself. The bars show supply; consumption, stocks and exports are not in this chart — what is drawn is the origin of supply, not the full balance."},"kaynak":"USDA FAS PSD · 2024/25 pazarlama yılı","cubuklar":[{"etiket":{"tr":"Buğday","en":"Wheat"},"dilimler":[{"ad":{"tr":"Kendi üretimi","en":"Own production"},"deger":9000,"rol":"vurgu"},{"ad":{"tr":"İthalat","en":"Imports"},"deger":12467,"rol":"ikincil"}]},{"etiket":{"tr":"Tane mısır","en":"Maize"},"dilimler":[{"ad":{"tr":"Kendi üretimi","en":"Own production"},"deger":7000,"rol":"vurgu"},{"ad":{"tr":"İthalat","en":"Imports"},"deger":10564,"rol":"ikincil"}]},{"etiket":{"tr":"Pirinç · kabuğu alınmış","en":"Rice · milled"},"dilimler":[{"ad":{"tr":"Kendi üretimi","en":"Own production"},"deger":3900,"rol":"vurgu"},{"ad":{"tr":"İthalat","en":"Imports"},"deger":160,"rol":"ikincil"}]}]},"pamuk_endeksi":{"tur":"cizgi","baslik":{"tr":"Mısır pamuğunun altmış üç yılı","en":"Sixty-three years of Egyptian cotton"},"birim":{"tr":"indeks · 1961 = 100","en":"index · 1961 = 100"},"ondalik":0,"not":{"tr":"İki seri de indeks, taban 1961. Mutlak rakamlarla çizilemezdi: üretim ton, alan hektar ve tek eksende yan yana konamazlar. Grafiğin söylediği şey iki eğrinin AÇILMASI: alan 1961'in %9,8'ine indi, üretim %23,0'ına — aradaki fark verimin 2,35 katına çıkması. Zirve 1965'te; üretim o yıl tabanın %129,7'siydi.","en":"Both series are indices with 1961 as the base. They could not be drawn in absolute terms: production is in tonnes, area in hectares, and the two cannot share an axis. What the chart says is that the curves SEPARATE: area fell to 9.8% of its 1961 level, production to 23.0% — the gap is yield rising to 2.35 times its starting value. The peak is 1965, when production stood at 129.7% of the base."},"kaynak":"FAOSTAT QCL · çiğit pamuk, 1961-2024","seriler":[{"ad":{"tr":"Üretim","en":"Production"},"rol":"vurgu","noktalar":{"liste":[{"yil":1961,"uretim":100,"alan":100},{"yil":1966,"uretim":129.7,"alan":93.6},{"yil":1971,"uretim":142.6,"alan":76.8},{"yil":1976,"uretim":108,"alan":62.8},{"yil":1981,"uretim":133.4,"alan":59.3},{"yil":1986,"uretim":112.7,"alan":53.1},{"yil":1991,"uretim":81.9,"alan":42.9},{"yil":1996,"uretim":96.6,"alan":46.4},{"yil":2001,"uretim":83.7,"alan":36.8},{"yil":2006,"uretim":59.4,"alan":27},{"yil":2011,"uretim":63.8,"alan":26.2},{"yil":2016,"uretim":14.6,"alan":6.6},{"yil":2021,"uretim":30.7,"alan":12},{"yil":2024,"uretim":23,"alan":9.8}],"x":"yil","y":"uretim"}},{"ad":{"tr":"Hasat alanı","en":"Area harvested"},"rol":"ikincil","noktalar":{"liste":[{"yil":1961,"uretim":100,"alan":100},{"yil":1966,"uretim":129.7,"alan":93.6},{"yil":1971,"uretim":142.6,"alan":76.8},{"yil":1976,"uretim":108,"alan":62.8},{"yil":1981,"uretim":133.4,"alan":59.3},{"yil":1986,"uretim":112.7,"alan":53.1},{"yil":1991,"uretim":81.9,"alan":42.9},{"yil":1996,"uretim":96.6,"alan":46.4},{"yil":2001,"uretim":83.7,"alan":36.8},{"yil":2006,"uretim":59.4,"alan":27},{"yil":2011,"uretim":63.8,"alan":26.2},{"yil":2016,"uretim":14.6,"alan":6.6},{"yil":2021,"uretim":30.7,"alan":12},{"yil":2024,"uretim":23,"alan":9.8}],"x":"yil","y":"alan"}}]},"portakalda_ikiye_bir":{"tur":"cizgi","baslik":{"tr":"Portakalda açılan makas","en":"The widening gap in oranges"},"birim":{"tr":"ton · portakal üretimi","en":"tonnes · orange production"},"bolen":1000,"ondalik":0,"not":{"tr":"1961'de Türkiye öndeydi. 1970'te Mısır geçti ve bir daha geri vermedi: 1990'da oran 2,14 kat, 2024'te 2,61 kat. Oranın ARTTIĞI iki yılın ölçümüdür, tek yılın değil. İki ülkenin ortak veri yılları alındı; bir ülkede olup ötekinde olmayan yıl atlandı, doldurulmadı. Eksen bin tona bölünmüş.","en":"In 1961 Türkiye was ahead. In 1970 Egypt passed it and never gave the lead back: the ratio was 2.14 fold in 1990 and 2.61 fold in 2024. That the ratio is RISING is a measurement of two years, not one. Years with data in both countries were used; a year present in one and missing in the other was skipped, not filled. The axis is divided by one thousand tonnes."},"kaynak":"FAOSTAT QCL · portakal, 1961-2024","seriler":[{"ad":{"tr":"Mısır","en":"Egypt"},"rol":"vurgu","noktalar":{"liste":[{"yil":1961,"misir":157000,"turkiye":177836},{"yil":1970,"misir":567000,"turkiye":445000},{"yil":1980,"misir":920881,"turkiye":679000},{"yil":1990,"misir":1574287,"turkiye":735000},{"yil":2000,"misir":1610520,"turkiye":1070000},{"yil":2010,"misir":2401015,"turkiye":1710500},{"yil":2020,"misir":3966200,"turkiye":1333975},{"yil":2024,"misir":4200000,"turkiye":1610000}],"x":"yil","y":"misir"}},{"ad":{"tr":"Türkiye","en":"Türkiye"},"rol":"ikincil","noktalar":{"liste":[{"yil":1961,"misir":157000,"turkiye":177836},{"yil":1970,"misir":567000,"turkiye":445000},{"yil":1980,"misir":920881,"turkiye":679000},{"yil":1990,"misir":1574287,"turkiye":735000},{"yil":2000,"misir":1610520,"turkiye":1070000},{"yil":2010,"misir":2401015,"turkiye":1710500},{"yil":2020,"misir":3966200,"turkiye":1333975},{"yil":2024,"misir":4200000,"turkiye":1610000}],"x":"yil","y":"turkiye"}}]},"ayni_fasillar":{"tur":"ikili_cubuk","baslik":{"tr":"Aynı rafta iki satıcı","en":"Two sellers on the same shelf"},"not":{"tr":"Beş fasılda da iki yön birden var: hem satıyoruz hem alıyoruz. Pay O FASLIN iki yönlü toplamına göre, bütün ticarete göre değil — her satır kendi içinde oranlanıyor. Sebzede Mısır önde (%60,9), meyvede Türkiye (%60,7). Yağda tek yönlülüğe yakın bir denge var (%98,9). Tek yönlü fasıllar listede yok: tek yönlü faslın payı olmaz. Rakamlar TÜRKİYE'NİN beyanından.","en":"In all five chapters both directions exist at once: we sell and we buy. The share is against THAT CHAPTER's two-way total, not against all trade — each row is scaled within itself. In vegetables Egypt leads (60.9%), in fruit Türkiye (60.7%). In fats the balance is close to one-directional (98.9%). One-directional chapters are not on the list: a one-way chapter has no share. The figures come from TÜRKİYE's reporting."},"kaynak":"UN Comtrade, 2024 · muhabir Türkiye · HS 01-24","seriler":[{"ad":{"tr":"Türkiye satıyor","en":"Türkiye sells"},"rol":"vurgu"},{"ad":{"tr":"Mısır satıyor","en":"Egypt sells"},"rol":"ikincil"}],"satirlar":[{"etiket":{"tr":"07 · Sebzeler","en":"07 · Vegetables"},"yil":2024,"degerler":[39.1,60.9],"ondalik":1,"onek":{"tr":"%","en":""},"sonek":{"tr":"","en":"%"}},{"etiket":{"tr":"08 · Meyveler ve yemişler","en":"08 · Fruit and nuts"},"yil":2024,"degerler":[60.7,39.3],"ondalik":1,"onek":{"tr":"%","en":""},"sonek":{"tr":"","en":"%"}},{"etiket":{"tr":"15 · Katı ve sıvı yağlar","en":"15 · Fats and oils"},"yil":2024,"degerler":[98.9,1.1],"ondalik":1,"onek":{"tr":"%","en":""},"sonek":{"tr":"","en":"%"}},{"etiket":{"tr":"20 · Sebze ve meyve müstahzarları","en":"20 · Preparations of vegetables and fruit"},"yil":2024,"degerler":[80.5,19.5],"ondalik":1,"onek":{"tr":"%","en":""},"sonek":{"tr":"","en":"%"}},{"etiket":{"tr":"17 · Şeker ve şeker mamulleri","en":"17 · Sugars and sugar confectionery"},"yil":2024,"degerler":[70,30],"ondalik":1,"onek":{"tr":"%","en":""},"sonek":{"tr":"","en":"%"}}]},"iki_defter":{"tur":"siralama","baslik":{"tr":"İki defter, iki rakam","en":"Two ledgers, two figures"},"birim":{"tr":"milyon dolar · tarım ürünleri · 2024","en":"million dollars · agricultural goods · 2024"},"bolen":1000000,"ondalik":1,"onek":{"tr":"$","en":"$"},"not":{"tr":"Aynı iki akış, iki ayrı defterden okunuyor. Türkiye'den Mısır'a giden mal Türkiye'nin defterinde 424,0 milyon, Mısır'ın defterinde 267,0 milyon: arada %58,8 fark var. Ters yönde Mısır'ın beyanı 282,0 milyon, Türkiye'nin beyanı 184,2 milyon: %53,1 fark. İki taraf da kendi GİDENİNİ fazla sayıyor — fark hesaplandı, sebebi iddia edilmedi; navlun, sigorta, serbest bölge ve kayıt zamanı farkları ayrı ayrı ölçülmedi.","en":"The same two flows, read from two separate ledgers. Goods going from Türkiye to Egypt are 424.0 million in Türkiye's ledger and 267.0 million in Egypt's: a gap of 58.8%. In the other direction Egypt declares 282.0 million and Türkiye 184.2 million: a gap of 53.1%. Each side counts its own OUTGOING flow higher — the gap was computed, its cause was not asserted; freight, insurance, free-zone treatment and timing differences were not measured separately."},"kaynak":"UN Comtrade, 2024 · iki muhabirin beyanı · HS 01-24","satirlar":[{"etiket":{"tr":"Türkiye → Mısır · Türkiye'nin beyanı","en":"Türkiye → Egypt · as Türkiye reports"},"deger":424023474,"rol":"vurgu"},{"etiket":{"tr":"Türkiye → Mısır · Mısır'ın beyanı","en":"Türkiye → Egypt · as Egypt reports"},"deger":267043294.82699996,"rol":"sessiz"},{"etiket":{"tr":"Mısır → Türkiye · Mısır'ın beyanı","en":"Egypt → Türkiye · as Egypt reports"},"deger":281951888.598,"rol":"ikincil"},{"etiket":{"tr":"Mısır → Türkiye · Türkiye'nin beyanı","en":"Egypt → Türkiye · as Türkiye reports"},"deger":184199173,"rol":"sessiz"}]},"kahirede_imzalandi":{"tur":"zaman_cizelgesi","baslik":{"tr":"Kahire'de imzalandı, Mükerrer'de yayımlandı","en":"Signed in Cairo, published in a supplement"},"not":{"tr":"Serbest Ticaret Anlaşması'nın yürürlüğe giriş yolu. Belge ana nüshanın içindekiler listesinde YOK; Mükerrer ekte. Bu tuzak bu projede daha önce de çıktı: TİGEM'i kuran kararname de 1984'te Mükerrer'de yayımlanmıştı. Anlaşmanın ekleri okundu: 19 dosya, tarım tavizleri Protokol II'de. Öteki ekler — Protokol I ve Liste 1-4 — sanayi ürünlerine ait ve bu dosyanın konusu değil.","en":"The route by which the Free Trade Agreement entered into force. The document is NOT in the table of contents of the main issue; it is in a supplement. This trap has appeared in this project before: the decree establishing TİGEM was likewise published in a supplement in 1984. The annexes were read: 19 files, with the agricultural concessions in Protocol II. The other annexes — Protocol I and Lists 1 to 4 — cover industrial goods and are not this dossier's subject."},"kaynak":"Resmî Gazete 30 Ocak 2007 · sayı 26419 Mükerrer","olaylar":[{"yil":2005,"baslik":{"tr":"Kahire'de imza","en":"Signed in Cairo"},"aciklama":{"tr":"27 Aralık 2005.","en":"27 December 2005."}},{"yil":2006,"baslik":{"tr":"Uygun bulma kanunu","en":"Act of approval"},"aciklama":{"tr":"5563 sayılı Kanun, 13 Aralık 2006.","en":"Act no. 5563, 13 December 2006."}},{"yil":2007,"baslik":{"tr":"Bakanlar Kurulu kararı","en":"Council of Ministers decision"},"aciklama":{"tr":"2007/11557, 15 Ocak 2007.","en":"2007/11557, 15 January 2007."}},{"yil":2007,"baslik":{"tr":"Resmî Gazete · Mükerrer","en":"Official Gazette · supplement"},"aciklama":{"tr":"30 Ocak 2007, sayı 26419 Mükerrer. Ana nüshanın içindekiler listesinde görünmüyor.","en":"30 January 2007, issue 26419 supplement. It does not appear in the main issue's table of contents."}},{"yil":2007,"baslik":{"tr":"Yürürlük","en":"Entry into force"},"aciklama":{"tr":"1 Mart 2007.","en":"1 March 2007."}}]},"taviz_degisimi":{"tur":"kartlar","baslik":{"tr":"İki tablo, iki kapı","en":"Two tables, two doors"},"not":{"tr":"Protokol II tarım tavizlerini iki tabloda sıralıyor: Tablo A Türkiye'nin Mısır'a sattıklarını, Tablo B Mısır'ın Türkiye'ye sattıklarını. Toplam kota Tablo A'da 54.500 ton, Tablo B'de 58.015 ton — ama toplamlar değil, hangi ürüne ne kadar yer açıldığı anlamlı. Kota KOTA BAŞINA sayıldı, tarife pozisyonu başına değil: tabloda birleştirilmiş hücreler var. Tablo B'de iki satır 'Sınırsız' diyor, Tablo A'da hiç yok.","en":"Protocol II lists the agricultural concessions in two tables: Table A what Türkiye sells to Egypt, Table B what Egypt sells to Türkiye. The total quota is 54,500 tonnes in Table A and 58,015 in Table B — but the totals are not the point; what matters is how much room was made for which product. Quotas were counted PER QUOTA, not per tariff line: the table has merged cells. Two lines in Table B read 'Unlimited'; Table A has none."},"kaynak":"Türkiye–Mısır STA · Protokol II · RG 26419 Mükerrer, 30 Ocak 2007","kartlar":[{"ust":{"tr":"Tablo B · Mısır → Türkiye","en":"Table B · Egypt → Türkiye"},"baslik":{"tr":"Pirinç","en":"Rice"},"govde":{"tr":"Türkiye'nin tarımda açtığı en büyük kapı pirinç: 30.000 ton kahverengi pirinçte vergi tamamen kalkıyor, 10.000 ton değirmenden geçmiş pirinçte %50 iniyor. İkisi Tablo B'nin bütün kotasının %68,9'u. Mısır'ın pirinçte fazlası var — üretimi Türkiye'nin 6,31 katı ve arzının yalnız %3,9'u ithal.","en":"The largest agricultural door Türkiye opened is rice: duties go entirely on 30,000 tonnes of brown rice and down by 50% on 10,000 tonnes of milled rice. Together that is 68.9% of all quota in Table B. Egypt has a surplus in rice — it produces 6.31 times Türkiye's output and imports only 3.9% of its supply."},"rakam":{"deger":40000,"ondalik":0,"sonek":{"tr":" ton","en":" t"},"etiket":{"tr":"iki pozisyonda toplam kota","en":"total quota across two lines"}}},{"ust":{"tr":"Tablo A · Türkiye → Mısır","en":"Table A · Türkiye → Egypt"},"baslik":{"tr":"Yağ","en":"Oils"},"govde":{"tr":"Mısır'ın açtığı en büyük kapı bitkisel yağ: ham ayçiçeği ve aspir yağında 20.000 ton, soya ve ham mısır yağında 10.000 ton, margarinde 1.000 ton — hepsinde vergi tamamen kalkıyor. Tablo A'nın bütün kotasının %75,2'si. On yedi yıl sonra, 2024'te Türkiye'nin Mısır'a en çok sattığı fasıl hâlâ 15. fasıl, yani yağ.","en":"The largest door Egypt opened is vegetable oil: 20,000 tonnes of crude sunflower and safflower oil, 10,000 tonnes each of soy and crude maize oil, 1,000 tonnes of margarine — duties go entirely in all of them. That is 75.2% of all quota in Table A. Seventeen years later, in 2024, the chapter Türkiye sells most to Egypt is still chapter 15: fats and oils."},"rakam":{"deger":41000,"ondalik":0,"sonek":{"tr":" ton","en":" t"},"etiket":{"tr":"yağ ve margarin kotası","en":"oil and margarine quota"}}},{"ust":{"tr":"Tablo B · altı pozisyon","en":"Table B · six lines"},"baslik":{"tr":"Sebze","en":"Vegetables"},"govde":{"tr":"Marul, havuç, diğer taze sebzeler, dondurulmuşlar, geçici konserveler ve kurutulmuş sebzeler — altı tarife pozisyonu TEK kotayı paylaşıyor: 600 ton. Aynı tabloda pirinç tek başına 40.000 ton alıyor. Oysa 2024'te Türkiye'nin Mısır'dan en çok aldığı fasıl sebze (7. fasıl) ve o fasılda Mısır iki yönlü akışın %60,9'unu tutuyor. Belgenin en dar kapısı, rafın en kalabalık rafı.","en":"Lettuce, carrots, other fresh vegetables, frozen ones, provisionally preserved ones and dried vegetables — six tariff lines SHARE a single quota of 600 tonnes. In the same table rice alone gets 40,000. Yet in 2024 the chapter Türkiye buys most from Egypt is vegetables (chapter 7), where Egypt holds 60.9% of the two-way flow. The document's narrowest door is the shelf's busiest."},"rakam":{"deger":600,"ondalik":0,"sonek":{"tr":" ton","en":" t"},"etiket":{"tr":"altı pozisyon paylaşıyor","en":"shared by six lines"}}}]},"kirsalda_cogunluk":{"tur":"ikili_cubuk","baslik":{"tr":"Hâlâ kırsalda yaşayan çoğunluk","en":"A majority still living in the countryside"},"not":{"tr":"Mısır nüfusunun %53,1'i kırsalda; Türkiye'de %20,9. Mısır'da kırsalda yaşayan 63,7 milyon kişi var — Türkiye'nin bütün nüfusundan fazla. Her satır kendi nüfusuna oranlanıyor; iki satır birbiriyle karşılaştırılmıyor. Nüfus 2026 kalemi ve FAOSTAT'ın serisi 2100'e kadar gidiyor; projeksiyon yılları bu dosyaya alınmadı.","en":"53.1% of Egypt's population lives in rural areas; in Türkiye 20.9%. Egypt has 63.7 million people living in rural areas — more than Türkiye's entire population. Each row is scaled to its own population; the two rows are not compared with each other. The population item is for 2026 and FAOSTAT's series runs to 2100; projection years were not taken into this dossier."},"kaynak":"FAOSTAT Population · 2026","seriler":[{"ad":{"tr":"Kırsal","en":"Rural"},"rol":"vurgu"},{"ad":{"tr":"Kentli","en":"Urban"},"rol":"ikincil"}],"satirlar":[{"etiket":{"tr":"Mısır","en":"Egypt"},"yil":2026,"degerler":[53.1,46.9],"ondalik":1,"onek":{"tr":"%","en":""},"sonek":{"tr":"","en":"%"},"rozet":{"tr":"120,1 milyon kişi","en":"120.1 million people"}},{"etiket":{"tr":"Türkiye","en":"Türkiye"},"yil":2026,"degerler":[20.9,79.1],"ondalik":1,"onek":{"tr":"%","en":""},"sonek":{"tr":"","en":"%"},"rozet":{"tr":"87,9 milyon kişi","en":"87.9 million people"}}]},"tarimin_agirligi":{"tur":"ikili_cubuk","baslik":{"tr":"Ekonomide tarımın ağırlığı","en":"Agriculture's weight in the economy"},"not":{"tr":"Mısır'da tarım, ormancılık ve balıkçılık gayrisafi yurt içi hasılanın %11,39'u; Türkiye'de %4,42. Kalem ORMANCILIK VE BALIKÇILIK DAHİL: FAOSTAT'ın saf tarım kalemi bu iki ülke için boş ve boş sonuç sıfır değildir, o yüzden geniş kalem alındı ve kapsamı burada yazılıyor. Pay dolar tabanlı; yerel para tabanlı seriyle aynı değildir. Her satır kendi hasılasına oranlanıyor.","en":"In Egypt agriculture, forestry and fishing account for 11.39% of gross domestic product; in Türkiye 4.42%. The item INCLUDES FORESTRY AND FISHING: FAOSTAT's pure-agriculture item is empty for both countries, and an empty result is not a zero, so the wider item was used and its scope is stated here. The share is on a dollar basis and is not the same as the local-currency series. Each row is scaled to its own output."},"kaynak":"FAOSTAT Macro-Statistics · 2025 · kalem 22016","seriler":[{"ad":{"tr":"Tarım, ormancılık ve balıkçılık","en":"Agriculture, forestry and fishing"},"rol":"vurgu"},{"ad":{"tr":"Ekonominin geri kalanı","en":"The rest of the economy"},"rol":"ikincil"}],"satirlar":[{"etiket":{"tr":"Mısır","en":"Egypt"},"yil":2025,"degerler":[11.39,88.61],"ondalik":2,"onek":{"tr":"%","en":""},"sonek":{"tr":"","en":"%"}},{"etiket":{"tr":"Türkiye","en":"Türkiye"},"yil":2025,"degerler":[4.42,95.58],"ondalik":2,"onek":{"tr":"%","en":""},"sonek":{"tr":"","en":"%"}}]}}$dsr$::jsonb,
  array['Mısır', 'Nil', 'feddan', 'buğday', 'buğday ithalatı', 'pirinç', 'tane mısır', 'pamuk', 'portakal', 'narenciye', 'sulama', 'su', 'tarım arazisi', 'tarım ticareti', 'serbest ticaret anlaşması', 'gıda güvenliği', 'kırsal nüfus', 'delta']::text[],
  'https://tarimportali.net/dosya/misir/misir_kapak_vadi.jpg',
  $dsr$Planet Labs, Inc.$dsr$,
  null,
  'draft',
  now(),
  (now() + interval '28 days'),
  null
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
  anahtar_kelimeler = excluded.anahtar_kelimeler,
  cover_url    = excluded.cover_url,
  cover_credit = excluded.cover_credit,
  video_url    = excluded.video_url,
  -- DURUM GERİYE ALINMIYOR. Seed, dosya taslakken üretilmiş olabilir; o
  -- seed'i yayındaki bir dosya üzerinde yeniden koşmak dosyayı RAFTAN
  -- İNDİRİRDİ ve kimse görmezdi — çünkü göçün sonundaki "durum draft
  -- olmalı" sağlaması, draft'ı bu satır yazdığı için GEÇERDİ.
  --
  -- 12 Kasım 2026'da TİGEM devrinden hemen sonra fark edildi:
  -- 20261111090000 göçü hâlâ 'draft' taşıyor ve yeniden uygulansaydı
  -- (migration repair, sıfırlama, yeni ortam) kurum rafı sessizce boşalırdı.
  --
  -- Mantık hemen aşağıdaki pencere kuralıyla AYNI: seed'i yeniden koşmak
  -- metni günceller, YAYIN KARARINI değiştirmez. Yayına almak ve arşive
  -- atmak devir göçünün işi.
  status       = case
                   when country_dossiers.status in ('published', 'archived')
                        and excluded.status = 'draft'
                     then country_dossiers.status
                   else excluded.status
                 end,
  -- Pencere KASITLI olarak korunuyor. Yayındaki bir dosyanın metninde yazım
  -- hatası düzeltmek için seed'i yeniden çalıştırmak, 28 günlük sayacı
  -- sıfırlamamalı. Pencereyi bilerek kaydırmak istiyorsanız elle update.
  starts_at    = coalesce(country_dossiers.starts_at,    excluded.starts_at),
  ends_at      = coalesce(country_dossiers.ends_at,      excluded.ends_at),
  published_at = coalesce(country_dossiers.published_at, excluded.published_at),
  updated_at   = now();

delete from public.dossier_sections
 where dossier_id = (select id from public.country_dossiers where slug = 'misir');

insert into public.dossier_sections
  (dossier_id, ord, title_tr, title_en, body_tr, body_en, chart_keys, tur, gorsel)
select d.id, v.ord, v.title_tr, v.title_en, v.body_tr, v.body_en, v.chart_keys, v.tur, v.gorsel
from public.country_dossiers d
cross join (values
  (1::integer, $dsr$Bir feddan$dsr$, $dsr$One feddan$dsr$, $dsr$Mısır'ın kendi arazi birimi feddan. Bir feddan 4.200,833 metrekare, yani
hektarın biraz altında: 0,42 hektar. Resmî istatistik hektarla yayımlanıyor,
uluslararası veritabanları hektarla tutuyor, ama tarla hâlâ feddanla
konuşuluyor. Mısır tarımının ölçeği bir ülke değil bir tarla, ve o tarlanın
birimi feddan.

Rakam şu: Mısır'da tarımda çalışan bir kişiye 0,72 hektar tarım arazisi
düşüyor. Feddana çevirince **1,71 feddan**. Türkiye'de aynı hesap 7,89
hektar veriyor. Arada 11,0 kat var.

Bu oranın paydası nüfus değil, istihdam. Yani 1,71 feddan, Mısır'da yaşayan
herkese düşen pay değil; tarımda çalışan kişiye düşen pay. Ayrımın önemi
şurada: Mısır'ın tarım çalışanı sayısı 5.898 bin, Türkiye'nin 4.899 bin.
Mısır'da tarımda Türkiye'den **daha fazla** insan çalışıyor — ve bunu
Türkiye'nin tarım arazisinin dokuzda birinden azıyla yapıyor.

İki rakam daha, dosyanın çerçevesini kuran rakamlar. Birincisi: ülke
yüzeyinin yalnız **%4,25'i** tarım arazisi. İkincisi: o araziyi sulayan
suyun **%96,9'u** ülke dışından geliyor — Birleşmiş Milletler Gıda ve Tarım
Örgütü'nün kendi ifadesiyle, bağımlılık oranı dünyanın en yükseklerinden
biri.

Bir ülkenin tarımını anlatmanın alışılmış yolu toplamlardan geçer: kaç ton
buğday, kaç milyar dolar ihracat, kaç hektar ekiliş. Mısır'da o toplamlar
yanıltıcı, çünkü hepsi çok büyük bir nüfusla çok küçük bir tarlanın
çarpımından çıkıyor. 120,1 milyon insan, 4.229 bin hektar. Toplamı değil
payı okumak gerekiyor — ve payın birimi feddan.

Sonraki 17 bölüm o tarlayı anlatıyor. Türkiye bağı dosyanın sonunda, üç
bölümde geri dönüyor; gövdesi Mısır'ın kendi toprağı.$dsr$, $dsr$Egypt's own land unit is the feddan. One feddan is 4,200.833 square metres,
a little under a hectare: 0.42 hectares. Official statistics are published in
hectares and international databases keep them in hectares, but the field is
still spoken of in feddans. The scale of Egyptian agriculture is less a
country than a field, and that field's unit is the feddan.

The figure is this: in Egypt one person working in agriculture has 0.72
hectares of farmland. Converted, **1.71 feddans**. The same calculation for
Türkiye gives 7.89 hectares. The gap is 11.0 fold.

The denominator here is employment, not population. So 1.71 feddans is not the
share of everyone living in Egypt; it is the share of a person working in
agriculture. The distinction matters because Egypt has 5,898 thousand
agricultural workers and Türkiye 4,899 thousand. **More** people work in
agriculture in Egypt than in Türkiye — on less than a ninth of Türkiye's
farmland.

Two more figures frame the dossier. First: only **4.25%** of the country's
surface is agricultural land. Second: **96.9%** of the water that irrigates it
originates outside the country — in the wording of the United Nations Food and
Agriculture Organization, a dependency ratio among the world's highest.

The usual way to describe a country's agriculture runs through totals: tonnes
of wheat, billions in exports, hectares sown. In Egypt those totals mislead,
because each is the product of a very large population and a very small field.
120.1 million people, 4,229 thousand hectares. The share has to be read rather
than the total — and the share is measured in feddans.

The next 17 sections are about that field. The link to Türkiye returns at the
end, in three sections; the body is Egypt's own soil.$dsr$, array['feddan']::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/misir/misir_tarla_at.jpg","atif":"AmiraAdel93","kaynak":null,"alt_tr":"Atla tarla hazırlığı. Dakahliye, Mısır, 19 Mayıs 2024.","alt_en":"Preparing a field with a horse. Dakahlia, Egypt, 19 May 2024."}$dsr$::jsonb),
  (2, $dsr$Kırkta bir$dsr$, $dsr$One part in forty$dsr$, $dsr$Mısır'ın kara yüzeyi 99.545 bin hektar. Bunun 4.229 bin hektarı tarım
arazisi. Oran **%4,25**: kırkta bir kadar.

Türkiye'nin kara yüzeyi 76.963 bin hektar, tarım arazisi 38.640 bin hektar.
Oran **%50,21**. Yani Türkiye kendi yüzeyinin yarısını ekerken Mısır kırkta
birini ekiyor; Mısır'ın yüzeyi Türkiye'den daha geniş olduğu hâlde.

Bu oran ülke yüzeyine göre hesaplanıyor, ekilebilir toprağa göre değil. Ayrım
önemli: Mısır'ın geri kalan %95,75'i çöl ve tarım arazisi sayılmıyor. Yani
%4,25 oranı, toprağın geri kalanının işlenmediğini değil, geri kalanın toprak
olmadığını söylüyor. Dosyanın bütün geri kalanı bu kısıtın üzerine kuruluyor.

Dört bin iki yüz yirmi dokuz bin hektarın içi de ayrı duruyor. 3.274 bin
hektar işlenebilir arazi, 955 bin hektar daimi ürün — meyve bahçesi,
narenciye, hurma. İkisinin toplamı tarım arazisinin tamamını veriyor; yani
Mısır'ın tarım arazisi içinde çayır ve mera kalemi kayıtlı değil. Bir ülkede
hayvancılığın geçtiği yer olarak mera görünmüyorsa, hayvan ya ekili alanda
besleniyor ya da yemi dışarıdan geliyor. 9. bölüm bunun hangisi olduğunu
gösteriyor.

Kırkta bir oranı, dosyanın en çok tekrarlanacak sayısı. Ama tek başına
okunduğunda Mısır'ı küçük gösterir, ki değil: aynı kırkta birin üstünde
dünyanın en büyük portakal üreticilerinden biri duruyor, pirinçte ülke
kendine yetiyor ve 5.898 bin kişi geçimini oradan sağlıyor. Küçük olan ülke
değil, paya düşen yer.$dsr$, $dsr$Egypt's land area is 99,545 thousand hectares. Of that, 4,229 thousand
hectares are agricultural land. The ratio is **4.25%**: about one part in
forty.

Türkiye's land area is 76,963 thousand hectares and its agricultural land
38,640 thousand. The ratio is **50.21%**. So Türkiye sows half its surface
while Egypt sows a fortieth — even though Egypt's surface is the larger of the
two.

The ratio is calculated against total land area, not against arable soil. The
distinction matters: the remaining **95.75%** of Egypt is desert and is not
counted as farmland. So the 4.25% ratio says not that the rest of the soil is
left unworked but that the rest is not soil. Everything else in this dossier
rests on that constraint.

The 4,229 thousand hectares break down further. 3,274 thousand hectares are
arable land and 955 thousand are under permanent crops — orchards, citrus,
dates. The two together account for all of the agricultural land, which means
no item for meadows and pasture is recorded within Egypt's farmland. Where
pasture does not appear as the place livestock is kept, the animals are either
fed on cropped land or their feed comes from outside. Section 9 shows which.

One part in forty is the figure this dossier repeats most. Read alone it makes
Egypt look small, which it is not: on that same fortieth stand one of the
world's larger orange producers, a country self-sufficient in rice, and 5,898
thousand people who live from it. What is small is not the country but the
share of ground each worker has.$dsr$, array['kirkta_bir']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/misir/misir_kapak_vadi.jpg","atif":"Planet Labs, Inc.","kaynak":null,"alt_tr":"Nil vadisi, Mısır. Planet Labs uydu görüntüsü, 13 Ağustos 2016.","alt_en":"The Nile valley, Egypt. Planet Labs satellite image, 13 August 2016."}$dsr$::jsonb),
  (3, $dsr$On bir kat$dsr$, $dsr$Eleven fold$dsr$, $dsr$Bir çalışana düşen arazi, iki sayının bölümü: tarım arazisi ve tarım
istihdamı.

Mısır'da 4.229 bin hektar tarım arazisine 5.898 bin tarım çalışanı düşüyor.
Bölüm **0,72 hektar** — yani 1,71 feddan. Türkiye'de 38.640 bin hektara
4.899 bin çalışan düşüyor: **7,89 hektar**. Oran **11,0 kat**.

Paydanın hangi sayı olduğu bu hesapta belirleyici. Nüfus alınırsa 120,1
milyona bölmek gerekir ve sonuç hem Mısır hem Türkiye için anlamsız küçülür.
Kırsal nüfus alınırsa Mısır'da 63.742 bin kişiye bölünür ve bu da yanlış
olur, çünkü kırsalda yaşayan herkes tarımda çalışmıyor. Doğru payda
istihdam: tarımda fiilen çalışan kişi sayısı.

İki ülkenin bu rakamları yan yana konduğunda çıkan tablo şu: Mısır tarımda
Türkiye'den yaklaşık bir milyon kişi daha fazla çalıştırıyor ve bunu
Türkiye'nin tarım arazisinin onda birinden biraz fazlasıyla yapıyor. Böyle bir orana iki şeyden
biri eşlik eder — ya kişi başına üretim çok düşüktür, ya aynı toprak yılda
birden fazla hasat verir. Mısır'da ikincisi geçerli ve 5. bölüm onu ölçüyor.

Arazi rakamı 2024, istihdam rakamı 2025 yılına ait. Oran bu yüzden tek bir
tarihin fotoğrafı değil, birbirine yakın iki yılın bileşimi.$dsr$, $dsr$The land each worker has is the quotient of two numbers: agricultural land and
agricultural employment.

In Egypt 4,229 thousand hectares of farmland are shared by 5,898 thousand
agricultural workers. The quotient is **0.72 hectares** — 1.71 feddans. In
Türkiye 38,640 thousand hectares are shared by 4,899 thousand workers:
**7.89 hectares**. The ratio is **11.0 fold**.

Which number serves as the denominator decides this calculation. Take
population and you divide by 120.1 million, and the result shrinks to
meaninglessness for both countries. Take rural population and in Egypt you
divide by 63,742 thousand, which is also wrong, because not everyone living
in a rural area works in agriculture. The right denominator is employment:
the number of people actually working the land.

Set the two countries side by side and the picture is this: Egypt employs
roughly a million more people in agriculture than Türkiye, and does so on a
little more than a tenth of Türkiye's farmland. A ratio like that comes with
one of two things — either output per person is very low, or the same soil
yields more than one harvest a year. In Egypt it is the second, and section 5
measures it.

The land figure is for 2024 and the employment figure for 2025. The ratio is
therefore not a snapshot of one date but a composite of two adjacent years.$dsr$, array['on_bir_kat']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/misir/misir_ciftciler.jpg","atif":"Hbegzee","kaynak":null,"alt_tr":"Mısırlı çiftçiler, 15 Mart 2023. Kaynak ili kaydetmiyor.","alt_en":"Egyptian farmers, 15 March 2023. The source does not record the governorate."}$dsr$::jsonb),
  (4, $dsr$Suyun yüzde doksan yedisi$dsr$, $dsr$Ninety-seven per cent of the water$dsr$, $dsr$Birleşmiş Milletler Gıda ve Tarım Örgütü'nün su veritabanı AQUASTAT, Mısır
ülke profilinde şunu yazıyor:
*"Egypt's dependency ratio is one of the world's highest with 96.9 percent
of the total renewable water resources flowing into the country from
neighbouring countries."*

Rakamlar bu cümlenin arkasında duruyor. Ülke içinde yenilenen su 1.800 milyon
metreküp. Bütün yenilenebilir kaynak 58.300 milyon metreküp. Aradaki fark
yukarıdan geliyor.

Üçüncü bir rakam var ve ilk bakışta imkânsız görünüyor: çekilen su **68.300**
milyon metreküp. Yani kaynağın kendisinden büyük. Bu bir veri hatası değil;
belge sebebini yazıyor. Tahliye suyu yeniden kullanılıyor, bir kez çekilen su
sisteme geri dönüyor ve ikinci kez sayılıyor. Rakam, Mısır'ın kaynağından fazla su
tükettiğini değil, aynı suyun birden çok kez kullanıldığını söylüyor.

Çekilen suyun dağılımı tek bir yöne ağır basıyor: **%86 tarım**, %8 belediye,
%6 sanayi. Yani ülkenin su hesabı neredeyse tarım hesabı.

Kişi başına yenilenebilir su 699 metreküp. Uluslararası tanımda bin
metreküpün altı su kıtlığı sayılıyor; Mısır o eşiğin belirgin biçimde
altında.

Bu rakamların yılları ayrı ve belge bunu kendisi söylüyor: tarama 2016'da
yapıldı, çekim verisi 2000'e, kişi başına su 2014'e ait. Dolayısıyla üç
rakam aynı yılın fotoğrafı değil ve birbirine oranlanmıyor. Kişi başına su
rakamı için ayrıca bir not gerekiyor: 2014'ten bu yana nüfus yirmi milyondan
fazla arttı, yani bugünkü pay o rakamın altında.

Dosyanın ekseni bu bölümde kuruluyor. Mısır'ın tarımı kendi suyuyla değil,
yukarıdan gelen suyla yapılıyor ve o suyun nasıl paylaşılacağı Mısır'ın tek
başına verdiği bir karar değil.$dsr$, $dsr$AQUASTAT, the water database of the United Nations Food and Agriculture
Organization, writes this in its Egypt country profile:
*"Egypt's dependency ratio is one of the world's highest with 96.9 percent
of the total renewable water resources flowing into the country from
neighbouring countries."*

The figures stand behind that sentence. Water renewed inside the country is
1,800 million cubic metres. All renewable resources come to 58,300 million
cubic metres. The difference arrives from upstream.

There is a third figure, and at first sight it looks impossible: water
withdrawn is **68,300** million cubic metres — larger than the resource
itself. This is not a data error; the document explains it. Drainage water is
reused, water withdrawn once returns to the system and is counted a second
time. The figure says not that Egypt consumes more water than its resource holds
but that the same water is used more than once.

The split of withdrawal leans heavily one way: **86% agriculture**, 8%
municipal, 6% industry. The country's water account is very nearly its
agriculture account.

Renewable water per person is 699 cubic metres. In the international
definition, below one thousand cubic metres counts as water scarcity; Egypt
is clearly beneath that threshold.

The years of these figures differ, and the document says so itself: the review
was carried out in 2016, the withdrawal data are for 2000, and the per capita
figure for 2014. So the three are not a snapshot of one year and are not
ratios of one another. The per capita figure needs one further note: the
population has grown by more than twenty million since 2014, so today's share
is below it.

The dossier's axis is set in this section. Egypt's agriculture runs not on its
own water but on water that arrives from upstream, and how that water is
shared is not a decision Egypt makes alone.$dsr$, array['suyun_defteri']::text[], 'belge', $dsr${"url":"https://tarimportali.net/dosya/misir/misir_sakiye_deve.jpg","atif":"Matson Collection","kaynak":null,"alt_tr":"Deveyle döndürülen su dolabı, Mısır, 1900. G. Eric ve Edith Matson Fotoğraf Koleksiyonu.","alt_en":"A water wheel turned by a camel, Egypt, 1900. G. Eric and Edith Matson Photograph Collection."}$dsr$::jsonb),
  (5, $dsr$Aynı tarla, yılda bir buçuk kez$dsr$, $dsr$The same field, one and a half times a year$dsr$, $dsr$Üçüncü bölümün sorusu şuydu: 0,72 hektarla nasıl geçinilir. Cevabın bir
parçası bu bölümde.

AQUASTAT'ın 2010 için verdiği ekim yoğunluğu **%175**. Ekim yoğunluğu, bir
yıl içinde ekilen alanın toplamının tarım arazisine oranı. Yüzün üstündeki
her puan aynı tarlanın yıl içinde yeniden ekildiği anlamına geliyor. 175,
ortalama bir tarlanın yılda bir buçuk kattan fazla hasat verdiğini söylüyor.

Bunu mümkün kılan şey ikinci rakam: sulama. Kaynak veritabanında Mısır'ın
fiilen sulanan tarım alanı ile tarım arazisi **birebir aynı sayı** —
ikisi de 4.229 bin hektar. Oran **%100**. Türkiye'de aynı oran %12,72.

Eşitliğin bir sınırı var: kayıtlarda yalnız 2021-2024 yılları için
görünüyor, daha eski yıllarda iki kalem ayrışıyor. Yani Mısır'ın tarım
arazisinin tamamının sulandığı, bir ölçümden çok bir kayıt durumu —
sulanmayan tarım arazisi ayrıca kaydedilmiyor.

%175'lik yoğunluğun kendisi, sulamanın ekim takvimini yağışa bağlı bir
tarladan farklı kıldığının ölçüsü: aynı arazi bir yıl içinde birden fazla kez
ekiliyor. Mısır'ın %4,25'lik tarım arazisinden çıkan üretimin bir kısmı
buradan geliyor — aynı hektar, yılda birden fazla kez sayılıyor. Hangi
ürünlerin üst üste ekildiğini bu oran tek başına söylemiyor.

Üçüncü rakam bu düzenin bedelini söylüyor. Kişi başına 699 metreküp suyla,
%86'sı tarıma giden bir çekimle ve dışarıdan gelen bir kaynakla yürüyen bir
sistem, suyun miktarına değil **akışının sürekliliğine** bağımlı. Yukarıdaki
havzada değişen her şey bu takvimi doğrudan etkiliyor.$dsr$, $dsr$Section 3 asked how a living is made from 0.72 hectares. Part of the answer is
here.

The cropping intensity AQUASTAT gives for 2010 is **175%**. Cropping intensity
is the total area sown within a year as a ratio of agricultural land. Every
point above one hundred means the same field was sown again within the year.
175 says the average field yields more than one and a half harvests a year.

What makes that possible is the second figure: irrigation. In the source
database the area actually irrigated and the agricultural land of Egypt are
**the same number** — 4,229 thousand hectares each. The ratio is **100%**. In
Türkiye the same ratio is 12.72%.

That identity has a limit: in the records it appears only for the years 2021
to 2024, and in earlier years the two items diverge. So saying that all of
Egypt's farmland is irrigated describes a recording state more than a
measurement — unirrigated farmland is not separately recorded.

The 175% figure is itself the measure of how far irrigation separates the
sowing calendar from a rain-fed field: the same land is sown more than once
within a year. Part of the output from Egypt's 4.25% of farmland comes from
there — the same hectare counted more than once a year. Which crops are
stacked on one another the ratio alone does not say.

The third figure names the cost of the arrangement. A system running on 699
cubic metres per person, with 86% of withdrawal going to agriculture and the
resource arriving from outside, depends not on the quantity of water but on
**the continuity of its flow**. Everything that changes in the upstream basin
bears directly on that calendar.$dsr$, array['ayni_tarla']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/misir/misir_su_cekme_1934.jpg","atif":"Matson Collection","kaynak":null,"alt_tr":"Kanaldan su çıkarmakta kullanılan burgulu boru, Mısır, 1934. Matson Fotoğraf Koleksiyonu.","alt_en":"A spiral tube used to raise water from a canal, Egypt, 1934. Matson Photograph Collection."}$dsr$::jsonb),
  (6, $dsr$Eski toprak, yeni toprak$dsr$, $dsr$Old land, new land$dsr$, $dsr$Mısır'ın tarım arazisi 1961'de 2.568 bin hektardı. 2024'te 4.229 bin hektar.
Artış **%64,7**.

Bu rakam, çölde açılmış yeni araziden geliyor. Nil vadisi ve deltası
yüzyıllardır aynı yerde duruyor; büyüyen şey o değil, kenarına eklenenler.
Seri beş noktadan geçiyor: 1961'de 2.568, 1990'da 2.648, 2010'da 3.671,
2020'de 3.971, 2024'te 4.229 bin hektar.

Eğrinin biçimi kendi başına bir şey söylüyor. 1961 ile 1990 arasındaki yirmi
dokuz yılda arazi yalnız 80 bin hektar arttı; 1990 ile 2010 arasındaki yirmi
yılda 1.023 bin hektar. Yani genişleme ikinci dönemde hızlandı.

Ama aynı dönemde ikinci bir sayı da büyüdü: nüfus. Ve tarım çalışanı başına
düşen arazi, 3. bölümde ölçüldüğü gibi, bugün 0,72 hektar. Toprak artarken
paya düşen yer azaldı. Bir ülkenin tarım arazisini %64,7 büyütmesi olağan
değil, hatta nadir; ama nüfus daha hızlı büyüdüyse çiftçinin tarlası yine
küçülür.

Nüfus rakamı 2026 yılına ait.

Arazi kayıtları kaç hektar olduğunu söylüyor, o hektarın ne verdiğini
söylemiyor. Çölde açılan toprağın deltanın alüvyonuyla aynı verimi verip
vermediği, sulama altyapısının ve tuzlanma riskinin orada nasıl
farklılaştığı ayrı bir soru.$dsr$, $dsr$Egypt's agricultural land was 2,568 thousand hectares in 1961. In 2024 it is
4,229 thousand. The increase is **64.7%**.

That figure comes from new land opened in the desert. The Nile valley and
delta have stood in the same place for centuries; what has grown is not them
but what has been added at the edges. The series passes through five
points: 2,568 thousand hectares in 1961, 2,648 in 1990, 3,671 in 2010, 3,971
in 2020 and 4,229 in 2024.

The shape of the curve says something by itself. Across the twenty-nine years
from 1961 to 1990 the land grew by only 80 thousand hectares; across the
twenty years from 1990 to 2010, by 1,023 thousand. The expansion accelerated
in the second period.

But a second number grew over the same period: population. And the land per
agricultural worker, as measured in section 3, is 0.72 hectares today. While
the soil increased, the share each worker holds fell. For a country to enlarge
its agricultural land by 64.7% is not ordinary, and is rare; but if the
population grows faster, the farmer's field shrinks all the same.

The population figure is for 2026.

The land records say how many hectares there are, not what those hectares
produce. Whether soil opened in the desert yields as the delta's alluvium
does, and how irrigation infrastructure and salinity risk differ there, is a
separate question.$dsr$, array['arazinin_egrisi']::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/misir/misir_col_tarimi.jpg","atif":"NASA Goddard Photo and Video","kaynak":null,"alt_tr":"Batı Çölü'nde sulamalı tarım, Nil'in batısı, Mısır. NASA, 9 Şubat 2018.","alt_en":"Irrigated farming in the Western Desert, west of the Nile, Egypt. NASA, 9 February 2018."}$dsr$::jsonb),
  (7, $dsr$Dünyanın en büyük buğday alıcısı$dsr$, $dsr$The world's largest wheat buyer$dsr$, $dsr$2024/25 pazarlama yılında Mısır 12.467 bin ton buğday ithal etti. Dünya
buğday ithalatı sıralamasında **birinci**.

Listenin ilk altısı şöyle: Mısır 12.467, Avrupa Birliği 10.715, Endonezya
10.452, Cezayir 9.100, Brezilya 7.198, Filipinler 6.351 bin ton. İkinci
sıradaki Avrupa Birliği bir küme satırı — kaynak veritabanında hiçbir üye
ülkenin ayrı satırı yok, dolayısıyla küme ile üyeler aynı toplamda
buluşmuyor ve çift sayım yok. Dünya toplamı 201.487 bin ton; Mısır'ın payı
**%6,2**.

Aynı yıl Mısır'ın buğday tüketimi 20.000 bin ton, üretimi 9.000 bin ton.
Yani tüketimin **%62,3'ü** ithal. Hasat alanı 1.300 bin hektar — ülkenin
tarım arazisinin yaklaşık üçte biri buğdayda.

Karşılaştırma için Türkiye: üretim 19.000, tüketim 18.400, ithalat 3.318 bin
ton. Türkiye dünya sıralamasında 21. sırada.

Bir anormallik var ve veri hatası değil: dünyanın en büyük buğday alıcısı
aynı yıl **2.352 bin ton buğday ihraç ediyor**. Arz ve kullanım dengesi
birebir tutuyor, yani rakam tutarlı. İhracatın bir kısmı un ve mamul olarak
bölgeye gidiyor; ülke hem alıcı hem satıcı.

İthalatın tarihi de kısa değil. 1960'ta Mısır 996 bin ton buğday ithal
ediyordu, 2024'te 12.467 bin ton: **12,5 kat**. Aynı dönemde nüfus dört
kattan fazla arttı, yani eğrinin tamamı nüfusla açıklanmıyor ama bir kısmı
onunla açıklanıyor.

Buradaki rakamlar pazarlama yılına ait, takvim yılına değil; Mısır'da buğday
pazarlama yılı Temmuz-Haziran. Kaynak veritabanının yayımladığı son iki
pazarlama yılı tahmin ve öngörü; yukarıdaki rakamlar kesin veriye dayanan son
yıla, **2024**'e ait.$dsr$, $dsr$In the 2024/25 marketing year Egypt imported 12,467 thousand tonnes of wheat.
In the world ranking of wheat imports it is **first**.

The first six on the list run: Egypt 12,467, European Union 10,715, Indonesia
10,452, Algeria 9,100, Brazil 7,198 and the Philippines 6,351 thousand
tonnes. The European Union in second place is an aggregate row — in the source
database no member state has a row of its own, so the aggregate and its
members never meet in the same total and there is no double counting. The
world total is 201,487 thousand tonnes; Egypt's share is **6.2%**.

In the same year Egypt's wheat consumption was 20,000 thousand tonnes and its
production 9,000 thousand. So **62.3%** of consumption is imported. The
harvested area is 1,300 thousand hectares — roughly a third of the country's
farmland is in wheat.

For comparison, Türkiye: production 19,000, consumption 18,400, imports 3,318
thousand tonnes. Türkiye ranks 21st in the world.

There is an anomaly, and it is not a data error: the world's largest wheat
buyer **exports 2,352 thousand tonnes of wheat** in the same year. The supply
and use balance adds up exactly, so the figure is consistent. Part of the
export leaves as flour and processed goods for the region; the country is both
buyer and seller.

The history of those imports is not short either. In 1960 Egypt imported 996
thousand tonnes of wheat; in 2024, 12,467 thousand — **12.5 fold**. Over the
same period the population more than quadrupled, so the curve is not fully
explained by population growth, though part of it is.

These figures belong to the marketing year, not the calendar year; in Egypt
the wheat marketing year runs July to June. The last two marketing years the
source database publishes are an estimate and a forecast; the figures above
belong to the last year resting on definite data, **2024**.$dsr$, array['dunyanin_alicisi', 'ithalatin_egrisi']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/misir/misir_bugday_hasadi.jpg","atif":"Doaa Adel","kaynak":null,"alt_tr":"Buğday hasadı. Şarkiye, Mısır, 1 Mayıs 2024.","alt_en":"Wheat harvest. Sharqia, Egypt, 1 May 2024."}$dsr$::jsonb),
  (8, $dsr$Ama pirinci kendi yetiştiriyor$dsr$, $dsr$But it grows its own rice$dsr$, $dsr$Üç tane, üç ayrı tablo.

Buğdayda arzın — üretim artı ithalat — **%58,1'i** dışarıdan geliyor. Tane
mısırda **%60,1'i**. Pirinçte **%3,9'u**.

Üçüncü rakam ilk ikisiyle aynı ülkeye ait. Pirinç, üçünün en çok su isteyeni;
ve ülke onu kendisi yetiştiriyor. Pirinç üretimi 3.900 bin ton, ithalat 160
bin ton. Aynı yıl Mısır'ın çeltik üretimi Türkiye'nin **6,31 katı**.

Suyunun %96,9'u dışarıdan gelen, kişi başına 699 metreküp suyu olan bir ülke
neden en çok su isteyen taneyi ekiyor — bunun bir cevabı var ve cevap
beklenenin tersi yönde.

Su altında tutulan bir pirinç tarlasının fazla suyu toprağa süzülüyor ve kıyı
akiferine tatlı su olarak geri dönüyor. O tatlı su, deniz suyunun karaya
doğru ilerlemesini geri itiyor. 2023 tarihli hakemli bir çalışma bunu
ölçtü: kuzey deltada pirinç ekimi akiferdeki tuz hacminde **%19** azalma
veriyor; deniz seviyesi yükselmesi de hesaba katıldığında azalma **%17**.

Bulgunun sınırları var. Sayısal bir **modelden** geliyor, uzun süreli saha
ölçümünden değil; ve sonuç pirincin nereye ekildiğine bağlı — kuzey dışındaki
bölgeler için aynı etki gösterilmiş değil. Pirincin **bu amaçla** ekildiğini
gösteren bir kayıt da yok: tuzlanmayı yavaşlatması sulamanın yan etkisi,
gerekçesi değil. Devlet deltanın bazı yerlerinde pirinç ekimini su tasarrufu
için kısıtlıyor; yani kamu politikası bu yan etkiyi desteklemiyor.

Dosyanın çelişkisi burada tam olarak görünüyor: su istemeyen taneler
dışarıdan alınıyor, su isteyen tane içeride yetiştiriliyor.$dsr$, $dsr$Three grains, three different accounts.

In wheat, **58.1%** of supply — production plus imports — arrives from
outside. In maize, **60.1%**. In rice, **3.9%**.

The third figure belongs to the same country as the first two. Rice is the
thirstiest of the three, and the country grows it itself. Rice production is
3,900 thousand tonnes and imports 160 thousand. In the same year Egypt's paddy
output was **6.31 times** Türkiye's.

Why a country with 96.9% of its water arriving from outside and 699 cubic
metres per person sows the thirstiest grain has an answer, and the answer runs
opposite to expectation.

Surplus water from a flooded rice field seeps into the soil and returns to the
coastal aquifer as fresh water. That fresh water pushes back the advance of
seawater inland. A peer-reviewed study published in 2023 measured it: rice
cultivation in the northern delta gives a **19%** reduction in the salt volume
of the aquifer, and **17%** when sea level rise is included in the model.

The finding has its limits. It comes from a numerical **model**, not from
long-term field monitoring, and the result depends on where the rice is
planted — for regions other than the north the same effect has not been
shown. Nor is there any record of rice being grown **for** this purpose:
slowing salinisation is a side effect of irrigation, not its rationale. The
state restricts rice cultivation in parts of the delta to conserve water, so
public policy does not support the side effect.

Here the dossier's contradiction stands fully visible: the grains that need
little water are bought from outside, and the grain that needs the most is
grown at home.$dsr$, array['uc_tane']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/misir/misir_pirinc_hasat.jpg","atif":"Doaa Adel","kaynak":null,"alt_tr":"Pirinç hasadı, Mısır, 12 Ekim 2024. Kaynak ili kaydetmiyor.","alt_en":"Rice harvest, Egypt, 12 October 2024. The source does not record the governorate."}$dsr$::jsonb),
  (9, $dsr$Tane mısırda da aynı$dsr$, $dsr$The same in maize$dsr$, $dsr$2024/25 pazarlama yılında Mısır 7.000 bin ton tane mısır üretti, 10.564 bin
ton ithal etti. İthalat üretimin üstünde ve arzın **%60,1'i** dışarıdan
geliyor; üç tanenin en yükseği.

Tüketim 17.300 bin ton. Bunun 14.700 bin tonu **yemlik** — yani tane mısırın
dörtte üçünden fazlası insana değil hayvana gidiyor. İhracat 1 bin ton, yani
pratikte sıfır: üretilen ve ithal edilen her şey içeride kalıyor.

İkinci bölümdeki soru burada cevabını buluyor. Mısır'ın tarım arazisi içinde
çayır ve mera kalemi kayıtlı değil; hayvancılığın yemi ya ekili alandan ya da
dışarıdan geliyor. Rakamlar ikincisini gösteriyor. Ülke hayvanını, büyük
ölçüde ithal taneyle besliyor.

Alan hesabı bunun nedenini açıklıyor. Tane mısırın hasat alanı 920 bin
hektar, buğdayın 1.300 bin hektar. İkisi birlikte 2.220 bin hektar — ülkenin
4.229 bin hektarlık tarım arazisinin yarısından fazlası. Üstüne pirincin 670
bin hektarı ekleniyor. Üç tane, mevcut arazinin neredeyse tamamını talep
ediyor; oysa aynı arazide portakal, domates, patates ve soğan da yetişiyor ve
bunlarda ülke ihracatçı. Ekim yoğunluğunun %175 olmasının anlamı tam burada
görünür hâle geliyor: tarla aynı yıl içinde birden fazla ürüne yetişmek
zorunda.

İki tanede ithalatın arzın yarısından fazlası olması, bir tercih değil bir
denklemin sonucu. 120,1 milyon insanı 4.229 bin hektarla beslemek, tahılın
bir kısmını dışarıdan almayı gerektiriyor. Mısır'ın tarımı bu yüzden yetersiz
sayılmamalı; ölçülen şey neyi yetiştirmeyi seçtiği. Seçtiği şeyler 7. ve 12.
bölümlerde duruyor.$dsr$, $dsr$In the 2024/25 marketing year Egypt produced 7,000 thousand tonnes of maize
and imported 10,564 thousand. Imports exceed production and **60.1%** of
supply arrives from outside — the highest of the three grains.

Consumption is 17,300 thousand tonnes. Of that, 14,700 thousand is **feed** —
more than three quarters of the maize goes to animals rather than to people.
Exports are 1 thousand tonnes, which is to say practically nothing:
everything produced and everything imported stays inside.

The question raised in section 2 finds its answer here. No item for meadows
and pasture is recorded within Egypt's farmland; livestock feed comes either
from cropped land or from outside. The figures point to the second. The
country feeds its animals largely on imported grain.

The area account explains why. Maize is harvested from 920 thousand hectares
and wheat from 1,300 thousand. Together that is 2,220 thousand hectares — more
than half of the country's 4,229 thousand hectares of farmland. Add rice's 670
thousand and the three grains claim 2,890 thousand hectares, very nearly all
of the available land. Yet oranges, tomatoes, potatoes and onions grow on that
same land, and in those the country is an exporter. This is exactly where a
cropping intensity of 175% becomes legible: the field has to serve more than
one crop within the same year.

That imports exceed half of supply in two of the grains is not a preference
but the outcome of an equation. Feeding 120.1 million people from 4,229
thousand hectares requires buying part of the grain abroad. Egypt's
agriculture should therefore not be read as insufficient; what is measured is
which crops it chooses to grow. What it chooses stands in sections 7 and 12.$dsr$, '{}'::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/misir/misir_tane_misir_1934.jpg","atif":"Matson Collection","kaynak":null,"alt_tr":"Nil boyunca tane mısır ekilişi, Mısır, 1934. Matson Fotoğraf Koleksiyonu.","alt_en":"Maize growing along the Nile, Egypt, 1934. Matson Photograph Collection."}$dsr$::jsonb),
  (10, $dsr$Adı bir kişiden gelen ürün$dsr$, $dsr$A crop that takes its name from a person$dsr$, $dsr$Mısır pamuğu, tarım tarihinde adı bir markaya dönüşmüş az sayıda üründen
biri. O adın arkasında bir kişi var.

Louis Alexis Jumel 1785'te doğmuş bir Fransız tekstil mühendisi. 1817'de bir
iplik fabrikasını yönetmek üzere Mısır'a geldi. Birkaç yıl sonra Kahire'de
bir bahçede, uzun elyaflı ve güçlü lifli pamuk veren bir çalı buldu. Çalıyı
kendisi yetiştirdi ve ülkede o güne dek elde edilenden belirgin biçimde daha
iyi kalitede pamuk aldı. Mehmet Ali Paşa çalışmayı mali olarak destekledi;
ardından fellahlara Nil deltasında bu pamuk ektirildi ve pamuk ticareti devlet
denetimine girdi. Jumel 1823'te öldü.

Keşfin ya da ilk ekim denemesinin hangi yılda olduğu kaynaklar arasında
ayrışıyor: 1818, 1819 ve 1821 ayrı ayrı geçiyor. Kesin olan tarih 1817,
Jumel'in Mısır'a gelişi.

Ölçeğe dair bir rakam: 1821'de ilk
denemelerde toplam üretim bin kantarı geçmiyordu; kantar pamuğa mahsus
tarihsel bir birim ve kabaca 45 kilogram. Kırk yıl sonra üretim 1.180.000
kantara çıkmıştı.

Bu bölümün dosyadaki yeri şu: bir ürünün adı bir kişiden geliyorsa, o ürünün
yükselişi ve düşüşü de bir ülkenin kararlarının izini taşır. Pamuk Mısır'a
rastgele gelmedi; getirildi, desteklendi, devlet eliyle yayıldı. Bir sonraki
bölüm aynı ürünün altmış üç yılını gösteriyor ve orada görülen şey doğal bir
gerileme değil.$dsr$, $dsr$Egyptian cotton is one of the few agricultural products whose name became a
brand. Behind that name stands a person.

Louis Alexis Jumel was a French textile engineer born in 1785. He came to
Egypt in 1817 to direct a spinning mill. A few years later he found, in a
garden in Cairo, a bush yielding cotton with a long staple and strong fibre.
He grew the plant himself and obtained cotton of markedly better quality than
anything the country had produced until then. Muhammad Ali Pasha supported the
work financially; the fellahin were then set to plant this cotton in the Nile
delta and the cotton trade came under state control. Jumel died in 1823.

In which year the discovery, or the first planting trial, took place differs
between sources: 1818, 1819 and 1821 each appear. The firm date is 1817,
Jumel's arrival in Egypt.

One figure speaks to scale: in the first trials of 1821 total output did not exceed a thousand
qantars, a qantar being a historical unit specific to cotton of roughly 45
kilograms. Forty years later output had reached 1,180,000 qantars.

The place of this section in the dossier is this: where a crop takes its name
from a person, its rise and its fall both carry the mark of a country's
decisions. Cotton did not arrive in Egypt by chance; it was brought,
supported and spread by the state. The next section shows sixty-three years of
the same crop, and what is visible there is not a natural decline.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/misir/misir_pamuk_muzesi.jpg","atif":"Amr F.Nagy","kaynak":null,"alt_tr":"Pamuk Müzesi, Mısır, 27 Ağustos 2025.","alt_en":"The Cotton Museum, Egypt, 27 August 2025."}$dsr$::jsonb),
  (11, $dsr$Pamuğun altmış üç yılı$dsr$, $dsr$Sixty-three years of cotton$dsr$, $dsr$Pamuğun seyri mutlak rakamlarla çizilemiyor, çünkü üretim ton, alan hektar ve
ikisi tek ölçekte yan yana konamaz. İkisi de 1961 yılına göre indekslendi:
1961 = 100.

Tablo şu:

| Yıl | Üretim indeksi | Alan indeksi |
|---|---|---|
| 1961 | 100,0 | 100,0 |
| 1966 | 129,7 | 93,6 |
| 1981 | 133,4 | 59,3 |
| 2001 | 83,7 | 36,8 |
| 2024 | 23,0 | 9,8 |

İki eğri birlikte başlıyor ve açılıyor. 2024'te hasat alanı 1961'in
**%9,8'ine** inmiş durumda; üretim **%23,0'ına**. Aradaki fark verimin
artışı: aynı hektardan alınan ürün 1961'in **2,35 katı**.

Mutlak oranlar da ölçüldü ve iki ayrı tabandan okunuyor. Üretim, 1965
zirvesinden 2024'e **%84,6** düştü. Alan, 1961'den 2024'e **%90,2** düştü.
İki rakam aynı cümlede yan yana konamaz çünkü tabanları ayrı; ortak taban
1961 alındığında üretimin düşüşü **%77,0**.

Bugünkü ölçek şu: Mısır'ın çiğit pamuk üretimi Türkiye'nin **0,10 katı**.
Yani adını bir ülkeye vermiş ürün, bugün komşusunun onda biri kadar
üretiliyor.

Verimin iki kattan fazla artmış olması, düşüşün bir teknik yetersizlik
olmadığını gösteriyor. Tarla daha verimli; sadece tarla kalmamış. Alanın
onda birine inmesi bir tercih zincirinin sonucu — hangi ürünün ekileceği,
hangi suyun nereye gideceği, hangi ürünün desteklendiği.

Serinin en dibi 2016: indeks 14,6. Tek yıllık çöküşler bu tür serilerde
olağan ve eğriyi tek yıldan okumak yanıltıcı — 2021'de indeks 30,7'ye
çıkmış, 2024'te 23,0.$dsr$, $dsr$Cotton's course cannot be drawn in absolute terms, because production is in
tonnes and area in hectares and the two cannot share an axis. Both were
indexed to 1961: 1961 = 100.

| Year | Production index | Area index |
|---|---|---|
| 1961 | 100.0 | 100.0 |
| 1966 | 129.7 | 93.6 |
| 1981 | 133.4 | 59.3 |
| 2001 | 83.7 | 36.8 |
| 2024 | 23.0 | 9.8 |

The two curves begin together and separate. By 2024 the harvested area has
fallen to **9.8%** of its 1961 level and production to **23.0%**. The gap
between them is the rise in yield: output from the same hectare is **2.35
times** its 1961 level.

The absolute declines were measured too, and they read from two different
bases. Production fell **84.6%** from its 1965 peak to 2024. Area fell
**90.2%** from 1961 to 2024. The two cannot sit in the same sentence because
their bases differ; on a common 1961 base, the fall in production is
**77.0%**.

Today's scale is this: Egypt's seed cotton output is **0.10 times** Türkiye's.
A crop that gave its name to a country is now produced at about a tenth of its
neighbour's level.

That yield more than doubled shows the decline was not a technical failure.
The field is more productive; there is simply less field. Falling to a tenth
of the area is the outcome of a chain of choices — which crop is sown, where
the water goes, which product is supported.

The lowest point in the series is 2016, at 14.6. Single-year collapses are
common in series of this kind and reading the curve from one year misleads —
the index stood at 30.7 in 2021 and 23.0 in 2024.$dsr$, array['pamuk_endeksi']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/misir/misir_pamuk_toplama.jpg","atif":"Matson Collection","kaynak":null,"alt_tr":"Pamuk toplama, Mısır, 1934-1939 arası. Matson Fotoğraf Koleksiyonu.","alt_en":"Picking cotton, Egypt, between 1934 and 1939. Matson Photograph Collection."}$dsr$::jsonb),
  (12, $dsr$Portakalda ikiye bir$dsr$, $dsr$Two to one in oranges$dsr$, $dsr$1961'de Türkiye öndeydi: Türkiye 177.836 ton portakal, Mısır 157.000 ton.
1970'te Mısır geçti — 567.000 tona karşı 445.000 ton — ve bir daha geri
vermedi.

| Yıl | Mısır | Türkiye |
|---|---|---|
| 1961 | 157.000 | 177.836 |
| 1980 | 920.881 | 679.000 |
| 1990 | 1.574.287 | 735.000 |
| 2010 | 2.401.015 | 1.710.500 |
| 2024 | 4.200.000 | 1.610.000 |

Oran 1990'da **2,14 kat**, 2024'te **2,61 kat**. Yani makas yalnız açık
değil, açılmaya devam ediyor. Makasın açılmaya devam ettiği, tek yılın değil iki
yılın ölçümü; tek bir yıldan böyle bir yön okunamaz.

Narenciyenin tamamına bakınca tablo daha dengeli: Mısır 5.857.700 ton,
Türkiye 5.481.576 ton, oran **1,07 kat**. Yani Mısır narenciyede bir bütün
olarak Türkiye'nin hemen önünde; portakalda ise açık ara önde. Ayrımı
yapan şey ürün kompozisyonu — mandalinada Türkiye önde, oran **0,64 kat**;
limonda çok daha önde, **0,22 kat**.

Bu dört oran birlikte okunduğunda ortaya çıkan şey bir üstünlük sıralaması
değil, iki ayrı uzmanlaşma. Mısır portakala yoğunlaşmış, Türkiye mandalina
ve limona. İki ülke aynı rafı paylaşıyor ama aynı kutuyu paylaşmıyor.

Bütün karşılaştırmalar 2024 yılına ait.

Portakalın dosyadaki yeri 11. bölümle birlikte okunduğunda beliriyor: aynı
ülke, aynı altmış üç yılda bir üründe onda bire indi, başka bir üründe
komşusunun iki buçuk katına çıktı. Mısır tarımının hikâyesi bir gerileme
hikâyesi değil; bir yer değiştirme hikâyesi.$dsr$, $dsr$In 1961 Türkiye was ahead: 177,836 tonnes of oranges against Egypt's 157,000.
In 1970 Egypt passed it — 567,000 tonnes against 445,000 — and never gave the
lead back.

| Year | Egypt | Türkiye |
|---|---|---|
| 1961 | 157,000 | 177,836 |
| 1980 | 920,881 | 679,000 |
| 1990 | 1,574,287 | 735,000 |
| 2010 | 2,401,015 | 1,710,500 |
| 2024 | 4,200,000 | 1,610,000 |

The ratio was **2.14 fold** in 1990 and **2.61 fold** in 2024. The gap is not
merely open; it is still widening — and that widening is a measurement of two
years, not one. No such direction can be read from a single year.

Across all citrus the picture is more even: Egypt 5,857,700 tonnes, Türkiye
5,481,576, a ratio of **1.07 fold**. So in citrus as a whole Egypt stands just
ahead of Türkiye, while in oranges it is clearly ahead. What makes the
difference is the mix of crops — in mandarins Türkiye leads, with a ratio of
**0.64 fold**, and in lemons it leads by much more, **0.22 fold**.

Read together, these four ratios do not give a ranking of superiority but two
different specialisations. Egypt has concentrated on oranges, Türkiye on
mandarins and lemons. The two countries share a shelf without sharing a box.

All the comparisons belong to 2024.

The place of oranges in the dossier appears when read alongside section 11:
the same country, over the same sixty-three years, fell to a tenth in one crop
and rose to two and a half times its neighbour in another. The story of
Egyptian agriculture is not a story of decline; it is a story of relocation.$dsr$, array['portakalda_ikiye_bir']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/misir/misir_portakal_bahcesi.jpg","atif":"LBM1948","kaynak":null,"alt_tr":"Hurma ağaçlı portakal bahçesi, Aşağı Mısır, Mart 1999.","alt_en":"An orange orchard with date palms, Lower Egypt, March 1999."}$dsr$::jsonb),
  (13, $dsr$Aynı rafta iki satıcı$dsr$, $dsr$Two sellers on the same shelf$dsr$, $dsr$Türkiye ile Mısır arasındaki tarım ticaretinde beş fasılda iki yön birden
var: aynı ürün grubunda hem satıyoruz hem alıyoruz.

| Fasıl | Türkiye satıyor | Mısır satıyor |
|---|---|---|
| 07 · Sebzeler | %39,1 | %60,9 |
| 08 · Meyveler ve yemişler | %60,7 | %39,3 |
| 15 · Katı ve sıvı yağlar | %98,9 | %1,1 |
| 20 · Sebze ve meyve müstahzarları | %80,5 | %19,5 |
| 17 · Şeker ve şeker mamulleri | %70,0 | %30,0 |

Paylar o faslın iki yönlü toplamına göre, bütün ticarete göre değil. Yani
tablo hangi faslın daha büyük olduğunu değil, o fasılda hangi tarafın ağır
bastığını söylüyor.

Sebzede Mısır önde ve bu fasıl aynı zamanda Türkiye'nin Mısır'dan en çok
aldığı kalem: 90.098.423 dolar. Meyvede Türkiye önde, 56.949.173 dolarla.
Yağda neredeyse tek yönlü bir denge var ve bu fasıl Türkiye'nin Mısır'a en
çok sattığı kalem: 84.061.216 dolar.

Tek yönlü fasıllar bu listede yok, çünkü tek yönlü bir faslın payı olmaz.
Listeye yalnız iki yönde de kaydı bulunan fasıllar girdi.

Rakamların hepsi Türkiye'nin beyanından. Mısır da ticaret veritabanına
muhabir olarak rapor veriyor ve iki beyan birbirini tutmuyor; 14. bölüm o
farkı gösteriyor. Buradaki paylar tek bir beyandan okunuyor, çünkü iki
defterin rakamları yan yana konduğunda oranlar anlamını yitiriyor.$dsr$, $dsr$In the agricultural trade between Türkiye and Egypt, five chapters carry both
directions at once: in the same product group we both sell and buy.

| Chapter | Türkiye sells | Egypt sells |
|---|---|---|
| 07 · Vegetables | 39.1% | 60.9% |
| 08 · Fruit and nuts | 60.7% | 39.3% |
| 15 · Fats and oils | 98.9% | 1.1% |
| 20 · Preparations of vegetables and fruit | 80.5% | 19.5% |
| 17 · Sugars and sugar confectionery | 70.0% | 30.0% |

The shares are against that chapter's two-way total, not against all trade. So
the table says not which chapter is larger but which side weighs more within
each chapter.

In vegetables Egypt leads, and that chapter is also the item Türkiye buys most
from Egypt: 90,098,423 dollars. In fruit Türkiye leads, with 56,949,173
dollars. In fats the balance is close to one-directional, and that chapter is
the item Türkiye sells most to Egypt: 84,061,216 dollars.

One-directional chapters are absent from this list, because a one-way chapter
has no share. Only chapters with records in both directions were included.

All the figures come from Türkiye's reporting. Egypt also reports to the
trade database as a correspondent, and the two declarations do not agree;
section 14 shows that gap. The shares here are read from a single ledger,
because set side by side the two sets of figures leave the ratios without
meaning.$dsr$, array['ayni_fasillar']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/misir/misir_narenciye_kahire.jpg","atif":"Walter G Rodriguez","kaynak":null,"alt_tr":"Narenciye, Kahire, Mısır, 15 Mart 2012.","alt_en":"Citrus fruit, Cairo, Egypt, 15 March 2012."}$dsr$::jsonb),
  (14, $dsr$İki defter$dsr$, $dsr$Two ledgers$dsr$, $dsr$Aynı iki akış, iki ayrı defterden okunuyor ve iki defter aynı şeyi
söylemiyor.

Türkiye'den Mısır'a giden tarım malı, Türkiye'nin defterinde **424,0 milyon
dolar**. Aynı malın Mısır'ın defterindeki karşılığı **267,0 milyon dolar**.
Arada **%58,8** fark var.

Ters yönde Mısır'ın beyanı **282,0 milyon dolar**, Türkiye'nin beyanı
**184,2 milyon dolar**. Fark **%53,1**.

Yönü dikkat çekici: her iki taraf da kendi **gidenini** karşı tarafın
gördüğünden fazla sayıyor. Farkın sebebi açıklanmış değil — navlun ve
sigortanın hangi tarafta sayıldığı, serbest bölge işlemleri, kayıt zamanı
farkları ve yeniden ihracat hepsi olası, hiçbiri tek başına gösterilmiş
değil.

İki rakam da aynı yıla, 2024'e ve aynı fasıl aralığına (01-24) ait. Yani fark
bir yöntem farkından değil, iki gümrük kaydının birbirini tutmamasından
geliyor.

Bu hattın iki ülke için ne kadar büyük olduğu da ölçüldü ve cevap: iki taraf
için de küçük. Mısır, Türkiye'nin 32,54 milyar dolarlık tarım ihracatının
**%1,3'ü**. Türkiye, Mısır'ın 9,98 milyar dolarlık tarım ihracatının
**%2,82'si**. İki yüzde de kendi başına küçük ve bu, hattın
iki taraf için de ikincil olduğunu söylüyor.

Dolayısıyla bu dosya bir ticaret dosyası değil. Mısır'ın Türkiye için önemi
bir pazar olarak değil, aynı rafta duran bir üretici olarak; 12. ve 13.
bölümler bunu gösteriyor.$dsr$, $dsr$The same two flows are read from two separate ledgers, and the two ledgers do
not say the same thing.

Agricultural goods going from Türkiye to Egypt are **424.0 million dollars**
in Türkiye's ledger. The same goods in Egypt's ledger are **267.0 million
dollars**. The gap is **58.8%**.

In the other direction Egypt declares **282.0 million dollars** and Türkiye
**184.2 million**. The gap is **53.1%**.

The direction is notable: each side counts its own **outgoing** flow higher
than the other side sees it. The cause of the gap has not been established —
which side counts freight and insurance, free-zone treatment, differences in
recording time and re-exports are all possible, and none has been shown on
its own.

Both figures belong to the same year, 2024, and the same chapter range
(01-24). So the gap comes not from a difference of method but from two
customs records that do not match.

How large this line is for each country was measured too, and the answer is:
small for both. Egypt accounts for **1.3%** of Türkiye's 32.54 billion dollars
of agricultural exports. Türkiye accounts for **2.82%** of Egypt's 9.98
billion. Both percentages are small in their own right, which says the line is
secondary for each side.

This is therefore not a trade dossier. Egypt matters to Türkiye not as a
market but as a producer standing on the same shelf; sections 12 and 13 show
that.$dsr$, array['iki_defter']::text[], 'belge', $dsr${"url":"https://tarimportali.net/dosya/misir/misir_konteyner.jpg","atif":"TheEgyptian","kaynak":null,"alt_tr":"İskenderiye limanına götürülen yük konteyneri, Mısır, 2 Kasım 2008.","alt_en":"A freight container on its way to the port of Alexandria, Egypt, 2 November 2008."}$dsr$::jsonb),
  (15, $dsr$Kahire'de imzalandı, Mükerrer'de yayımlandı$dsr$, $dsr$Signed in Cairo, published in a supplement$dsr$, $dsr$Türkiye Cumhuriyeti ile Mısır Arap Cumhuriyeti Arasında Bir Serbest Ticaret
Alanı Tesis Eden Anlaşma, 27 Aralık 2005'te Kahire'de imzalandı. 5563 sayılı
Kanun'la 13 Aralık 2006'da uygun bulundu, 2007/11557 sayılı kararla 15 Ocak
2007'de onaylandı, 30 Ocak 2007 tarihli ve 26419 sayılı Resmî Gazete'de
yayımlandı, 1 Mart 2007'de yürürlüğe girdi.

Yayımlandığı nüsha **Mükerrer** ek. Yani 30 Ocak 2007 sayısının içindekiler
listesine bakan biri böyle bir karar bulamaz. Bu tuzak bu dizide ikinci kez
karşımıza çıkıyor; bir kurumu kuran kararname de yıllar önce Mükerrer ekte
yayımlanmıştı ve ana nüshanın dizininde görünmüyordu.

Anlaşmanın tarım tavizleri Protokol II'de, iki tablo halinde duruyor.

Tablo A, Türkiye menşeli ürünlerin Mısır'a girişini düzenliyor: 16 kota
grubu, 18 tarife pozisyonu, toplam **54.500 ton**. Tablo B, Mısır menşeli
ürünlerin Türkiye'ye girişini: 22 kota grubu, 27 tarife pozisyonu, toplam
**58.015 ton**. Tabloda birleştirilmiş hücreler var: birden çok tarife
pozisyonu tek kotayı paylaşıyor.

Toplamlar birbirine yakın. Anlamlı olan hangi ürüne ne kadar yer açıldığı.

**Türkiye'nin tarımda açtığı en büyük kapı pirinç.** 30.000 ton kahverengi
pirinçte vergi tamamen kalkıyor, 10.000 ton değirmenden geçmiş pirinçte
%50 iniyor. İkisi birlikte **40.000 ton**, yani Tablo B'nin bütün kotasının
**%68,9'u**. Sekizinci bölüm o ürünü ölçmüştü: Mısır pirinçte kendine
yetiyor, üretimi Türkiye'nin 6,31 katı ve arzının yalnız %3,9'u ithal.

**Mısır'ın açtığı en büyük kapı yağ.** Ham ayçiçeği ve aspir yağında 20.000
ton, soya ve ham mısır yağında 10.000 ton, margarinde 1.000 ton — toplam
**41.000 ton**, Tablo A'nın **%75,2'si** ve hepsinde vergi tamamen kalkıyor.
On yedi yıl sonra, 2024'te Türkiye'nin Mısır'a en çok sattığı fasıl hâlâ
15. fasıl: yağ. Belgenin en geniş kapısı ile bugünkü en büyük akış aynı
fasılda duruyor.

Üçüncü bulgu ters yönde. Marul, havuç, diğer taze sebzeler, dondurulmuşlar,
geçici konserveler ve kurutulmuş sebzeler — **altı tarife pozisyonu tek
kotayı paylaşıyor: 600 ton**. Aynı tabloda pirinç tek başına 40.000 ton
alıyor. Oysa 13. bölümde ölçüldü: Türkiye'nin Mısır'dan en çok aldığı fasıl
sebze ve Mısır o fasılda iki yönlü akışın %60,9'unu tutuyor. Belgenin en dar
kapısı, rafın en kalabalık rafı.

İki tabloda birebir aynı duran bir blok da var: şeker mamulleri, çikolata,
makarna, ekmekçi mamulleri, turşu, meyve müstahzarları, meyve suları ve
canlı maya. Aynı kotalar, aynı %15 indirim. İşlenmiş gıdada taviz tam
aynalı.

Son bir ayrım, yanlış okunmaya en açık nokta: Tablo B'de iki satır
*"Sınırsız"* diyor — balıkçılık faslı ve canlı bitkiler. Tablo A'da hiç yok.
Sınırsız, sıfır değil; sınır yok demek ve toplam kotaya girmiyor.

Anlaşmanın öteki ekleri — Protokol I ve onun Liste 1-4 takvimleri — **sanayi**
ürünlerine ait. Orada da gerçek bir asimetri var: Türkiye vergileri
yürürlükle birlikte kaldırıyor, Mısır 2020'ye kadar kademeli iniyor. Ama o
asimetri bu dosyanın konusu değil ve tarım tavizi gibi okunmamalı.$dsr$, $dsr$The Agreement Establishing a Free Trade Area between the Republic of Türkiye
and the Arab Republic of Egypt was signed in Cairo on 27 December 2005. It was
approved by Act no. 5563 on 13 December 2006, ratified by decision 2007/11557
on 15 January 2007, published in the Official Gazette of 30 January 2007,
issue 26419, and entered into force on 1 March 2007.

The issue in which it was published is a **supplement**. Anyone consulting the
table of contents of the 30 January 2007 issue will not find the decision.
This trap appears for the second time in this series; a decree establishing an
institution was likewise published in a supplement years ago and did not
appear in the main issue's index.

The agreement's agricultural concessions sit in Protocol II, in two tables.

Table A governs the entry of goods of Turkish origin into Egypt: 16 quota
groups, 18 tariff lines, **54,500 tonnes** in total. Table B governs the entry
of goods of Egyptian origin into Türkiye: 22 quota groups, 27 tariff lines,
**58,015 tonnes**. The table has merged cells: several tariff lines share a
single quota.

The totals are close to each other. What is meaningful is how much room was
made for which product.

**The largest agricultural door Türkiye opened is rice.** Duties go entirely
on 30,000 tonnes of brown rice and down by 50% on 10,000 tonnes of milled
rice. Together that is **40,000 tonnes**, or **68.9%** of all quota in Table B.
Section 8 measured that crop: Egypt is self-sufficient in rice, produces 6.31
times Türkiye's output and imports only 3.9% of its supply.

**The largest door Egypt opened is oil.** 20,000 tonnes of crude sunflower and
safflower oil, 10,000 tonnes each of soy and crude maize oil, 1,000 tonnes of
margarine — **41,000 tonnes** in total, **75.2%** of Table A, with duties
going entirely in all of them. Seventeen years later, in 2024, the chapter
Türkiye sells most to Egypt is still chapter 15: fats and oils. The widest
door in the document and the largest flow today sit in the same chapter.

The third finding runs the other way. Lettuce, carrots, other fresh
vegetables, frozen ones, provisionally preserved ones and dried vegetables —
**six tariff lines share a single quota of 600 tonnes**. In the same table rice
alone takes 40,000. Yet section 13 measured it: the chapter Türkiye buys most
from Egypt is vegetables, where Egypt holds 60.9% of the two-way flow. The
document's narrowest door is the shelf's busiest.

One block stands identically in both tables: sugar confectionery, chocolate,
pasta, bakery goods, pickles, fruit preparations, fruit juices and live yeast.
The same quotas, the same 15% reduction. In processed food the concession is
exactly mirrored.

A final distinction, and the point most open to misreading: two lines in Table
B read *"Unlimited"* — the fisheries chapter and live plants. Table A has
none. Unlimited is not zero; it means no limit, and it does not enter the
quota total.

The agreement's other annexes — Protocol I and its Lists 1 to 4 — cover
**industrial** goods. There too a real asymmetry exists: Türkiye abolishes
duties on entry into force while Egypt steps down gradually until 2020. But
that asymmetry is not this dossier's subject and should not be read as an
agricultural concession.$dsr$, array['kahirede_imzalandi', 'taviz_degisimi']::text[], 'belge', $dsr${"url":"https://tarimportali.net/dosya/misir/misir_pirinc_ekim.jpg","atif":"Doaa Adel","kaynak":null,"alt_tr":"Pirinç ekimi, Mısır, 21 Haziran 2023. Kaynak ili kaydetmiyor.","alt_en":"Rice planting, Egypt, 21 June 2023. The source does not record the governorate."}$dsr$::jsonb),
  (16, $dsr$Kırsalda yaşayan çoğunluk$dsr$, $dsr$A majority still in the countryside$dsr$, $dsr$Mısır'ın nüfusu 120.101 bin kişi. Bunun **63.742 bin'i** kırsalda yaşıyor:
oran **%53,1**.

Türkiye'nin nüfusu 87.926 bin, kırsalda yaşayan 18.415 bin kişi: **%20,9**.

İki rakam yan yana konduğunda çıkan sonuç şu: **Mısır'ın yalnız kırsal
nüfusu, Türkiye'nin bütün nüfusundan daha kalabalık.** Altmış üç milyon
insan, 4.229 bin hektarlık bir tarım arazisinin çevresinde yaşıyor.

Tarımda fiilen çalışanların sayısı 5.898 bin. Yani kırsal nüfusun
**%9,3'ü** tarımda çalışıyor; geri kalanı aynı yerde yaşıyor ama geçimini
başka yerden sağlıyor. Kırsal nüfus ile tarım istihdamı aynı şey
değil ve bu dosyada ikisi ayrı tutuldu.

Nüfus rakamı 2026 yılına ait. Kaynak serisi 2100'e kadar gidiyor ve ölçülen
yılı öngörülen yıldan ayıran bir işaret taşımıyor; o yüzden bu dosyaya yalnız
bugüne kadarki kalemler girdi. İleriki yıllar için hiçbir rakam
kullanılmadı.

Bu bölümün dosyadaki yeri, ilk bölümün rakamını başka bir açıdan tekrar
etmek. 1,71 feddan bir tarla ölçüsü; 63.742 bin kişi o tarlanın etrafındaki
insan sayısı. Bir ülkenin tarımını konuşurken hektar ve ton kadar belirleyici
olan üçüncü bir sayı var: aynı toprağa kaç kişi bakıyor.

Türkiye'de bu pay %20,9, Mısır'da %53,1. İki ülkenin tarım politikası aynı
araçlarla çalışmıyor, çünkü aynı sorunu çözmüyor.$dsr$, $dsr$Egypt's population is 120,101 thousand. Of that, **63,742 thousand** live in
rural areas: **53.1%**.

Türkiye's population is 87,926 thousand, with 18,415 thousand living in rural
areas: **20.9%**.

Set side by side, the result is this: **Egypt's rural population alone is
larger than Türkiye's entire population.** Sixty-three million people live
around 4,229 thousand hectares of farmland.

The number actually working in agriculture is 5,898 thousand. So **9.3%** of
the rural population works in agriculture; the rest live in the same places
but make their living elsewhere. Rural population and agricultural employment
are not the same thing, and the two were kept apart in this dossier.

The population figure is for 2026. The source series runs to 2100 and carries
no marker separating a measured year from a projected one, so only items up to
the present entered this dossier. No figure for later years was used.

The place of this section is to restate the first section's figure from
another angle. 1.71 feddans is a measure of field; 63,742 thousand is the
number of people around that field. Alongside hectares and tonnes, a third
number decides how a country's agriculture works: how many people look to the
same soil.

In Türkiye that share is 20.9%, in Egypt 53.1%. The two countries'
agricultural policies do not work with the same instruments, because they are
not solving the same problem.$dsr$, array['kirsalda_cogunluk']::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/misir/misir_tarlada_calisan.jpg","atif":"Evon2023","kaynak":null,"alt_tr":"Tarlasında yabancı ot temizleyen çiftçi, Mısır, 1 Temmuz 2023.","alt_en":"A farmer clearing weeds in his field, Egypt, 1 July 2023."}$dsr$::jsonb),
  (17, $dsr$Türkiye buradan ne görebilir$dsr$, $dsr$What Türkiye can see from here$dsr$, $dsr$Bir rakamla kapatmak gerekirse: tarım, ormancılık ve balıkçılık Mısır'ın
gayrisafi yurt içi hasılasının **%11,39'u**. Türkiye'de aynı kalem
**%4,42**.

Kalem ormancılık ve balıkçılığı içeriyor; kaynak veritabanının saf tarım
kalemi bu iki ülke için boş ve boş sonuç sıfır sayılmıyor, o yüzden geniş
kalem alındı. Pay dolar tabanlı; yerel para tabanlı seriyle aynı değil.

İki oran birlikte okunduğunda ortaya çıkan şey dosyanın özeti. Mısır'da bir
tarım çalışanının tarlası Türkiye'dekinin on birde biri kadar, ama tarımın
ekonomideki ağırlığı **2,58 kat** fazla. Küçük tarla, büyük yük.

Türkiye açısından üç şey öne çıkıyor.

Birincisi portakal. Makas 1990'da 2,14 kattı, 2024'te 2,61 kat ve açılmaya
devam ediyor. Mısır'ın portakalda yaptığı şey bir avantajın korunması değil,
büyütülmesi.

İkincisi sebze rafı. Türkiye'nin Mısır'dan en çok aldığı fasıl sebze ve Mısır
o fasılda iki yönlü akışın %60,9'unu tutuyor. Serbest Ticaret Anlaşması'nın
o fasla açtığı kapı altı pozisyon için tek bir 600 tonluk kota; yani bugünkü
akış o kapıdan değil, başka bir yerden geçiyor.

Üçüncüsü yağ. Türkiye'nin Mısır'a en çok sattığı fasıl 2007'de anlaşmanın en
büyük kotasını almış ve 2024'te hâlâ en büyük akış. İki uç arasında on yedi
yıl var ve ikisi aynı fasılı gösteriyor.

Üç soru açık kalıyor: yeni açılan çöl arazilerinin verimi, pamuktan çıkışın
hangi politika kararlarıyla olduğu ve suyun yukarı havzada nasıl
paylaşıldığı.

Dosyanın birimi feddan kaldı. Çünkü Mısır tarımını anlatan sayı toplam değil
pay: 4.200,833 metrekare, ve bir tarım çalışanının tarlası bunun **1,71
katı**.$dsr$, $dsr$To close with a figure: agriculture, forestry and fishing account for
**11.39%** of Egypt's gross domestic product. In Türkiye the same item is
**4.42%**.

The item includes forestry and fishing; the source database's pure-agriculture
item is empty for both countries and an empty result is not counted as a zero,
so the wider item was used. The share is on a dollar basis and is not the same
as the local-currency series.

Read together, the two ratios summarise the dossier. In Egypt an agricultural
worker's field is about a eleventh of Türkiye's, yet agriculture's weight in
the economy is **2.58 times** greater. A small field carrying a large load.

Three things stand out for Türkiye.

The first is oranges. The gap was 2.14 fold in 1990 and 2.61 fold in 2024, and
it is still widening. What Egypt has done in oranges is not the defence of an
advantage but its enlargement.

The second is the vegetable shelf. The chapter Türkiye buys most from Egypt is
vegetables, where Egypt holds 60.9% of the two-way flow. The door the Free
Trade Agreement opened for that chapter is a single 600-tonne quota shared by
six lines; today's flow passes not through that door but somewhere else.

The third is oil. The chapter Türkiye sells most to Egypt took the agreement's
largest quota in 2007 and is still the largest flow in 2024. Seventeen years
separate the two ends, and both point to the same chapter.

Three questions stay open: the yield of the desert land Egypt has newly
opened, the policy decisions behind the exit from cotton, and how the water is
shared in the upstream basin.

The dossier's unit remained the feddan. Because the number that describes
Egyptian agriculture is not a total but a share: 4,200.833 square metres, and
an agricultural worker's field is **1.71 times** that.$dsr$, array['tarimin_agirligi']::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/misir/misir_bugday_fayyum.jpg","atif":"Mohamed shokry algarnosy","kaynak":null,"alt_tr":"Feyyum'da buğday hasadı, Mısır, 3 Mayıs 2023.","alt_en":"Wheat harvest in Fayoum, Egypt, 3 May 2023."}$dsr$::jsonb),
  (18, $dsr$Kaynakça$dsr$, $dsr$Sources$dsr$, $dsr$| Kaynak | Nitelik | Ne için kullanıldı |
|---|---|---|
| FAOSTAT · Inputs/LandUse | Bağımsız | Arazi kullanımı, sulanan alan, 1961-2024 serisi |
| FAOSTAT · Production/Crops and Livestock | Bağımsız | Pamuk, portakal, pirinç ve öteki ürünlerin üretim ve alan serileri |
| FAOSTAT · Macro-Statistics Key Indicators | Bağımsız | Tarımın gayrisafi yurt içi hasıladaki payı (kalem ormancılık ve balıkçılık dahil) |
| FAOSTAT · Population | Bağımsız | Nüfus ve kırsal nüfus, 2026 |
| FAOSTAT · Employment Indicators Agriculture | Bağımsız | Tarım istihdamı, 2025, toplam cinsiyet dilimi |
| USDA FAS · Production, Supply and Distribution | Bağımsız | Buğday, tane mısır ve pirinç dengesi; dünya ithalat sıralaması; 1960-2024 ithalat serisi |
| UN Comtrade | Bağımsız | İki taraflı tarım ticareti, fasıl dökümü, iki muhabirin beyanı |
| FAO AQUASTAT · Mısır ülke profili, 2016 taraması | Birincil | Su kaynakları, dışa bağımlılık oranı, çekim dağılımı, ekim yoğunluğu |
| Resmî Gazete · 30 Ocak 2007, sayı 26419 Mükerrer | Birincil | Serbest Ticaret Anlaşması ve Protokol II tarım tavizleri |
| Abd-Elaty ve diğerleri, 2023 · *Journal of Hydrology: Regional Studies* 48, 101466 | Birincil | Pirinç sulamasının kıyı akiferine süzülmesi ve tuzlanmaya etkisi (sayısal model) |
| *Encyclopedia of Western Colonialism since 1450* · *Cotton* maddesi | İkincil | Jumel'in Mısır'a gelişi ve uzun elyaflı pamuğun bulunuşu |
| Osama Diab · *Cotton Specters*, Al Manassa, 27 Temmuz 2026 | İkincil | 1821 denemesi ve kantar cinsinden üretim rakamları |$dsr$, $dsr$| Source | Standing | Used for |
|---|---|---|
| FAOSTAT · Inputs/LandUse | Independent | Land use, irrigated area, the 1961-2024 series |
| FAOSTAT · Production/Crops and Livestock | Independent | Production and area series for cotton, oranges, rice and other crops |
| FAOSTAT · Macro-Statistics Key Indicators | Independent | Agriculture's share of gross domestic product (item includes forestry and fishing) |
| FAOSTAT · Population | Independent | Population and rural population, 2026 |
| FAOSTAT · Employment Indicators Agriculture | Independent | Agricultural employment, 2025, total sex slice |
| USDA FAS · Production, Supply and Distribution | Independent | Wheat, maize and rice balances; world import ranking; the 1960-2024 import series |
| UN Comtrade | Independent | Bilateral agricultural trade, chapter breakdown, both correspondents' declarations |
| FAO AQUASTAT · Egypt country profile, 2016 review | Primary | Water resources, dependency ratio, withdrawal split, cropping intensity |
| Official Gazette · 30 January 2007, issue 26419 supplement | Primary | The Free Trade Agreement and the Protocol II agricultural concessions |
| Abd-Elaty et al., 2023 · *Journal of Hydrology: Regional Studies* 48, 101466 | Primary | Recharge from rice irrigation into the coastal aquifer and its effect on salinity (numerical model) |
| *Encyclopedia of Western Colonialism since 1450* · *Cotton* entry | Secondary | Jumel's arrival in Egypt and the discovery of long-staple cotton |
| Osama Diab · *Cotton Specters*, Al Manassa, 27 July 2026 | Secondary | The 1821 trial and output figures in qantars |$dsr$, '{}'::text[], 'belge', $dsr${"url":"https://tarimportali.net/dosya/misir/misir_pamuk_tarlasi_1934.jpg","atif":"Matson Collection","kaynak":null,"alt_tr":"Toplanmaya hazır pamuk tarlası, Mısır, 1934. Matson Fotoğraf Koleksiyonu.","alt_en":"A cotton field ready to be picked, Egypt, 1934. Matson Photograph Collection."}$dsr$::jsonb)
) as v(ord, title_tr, title_en, body_tr, body_en, chart_keys, tur, gorsel)
where d.slug = 'misir';

-- Sağlama: beklenen bölüm sayısı yazılmadıysa işlem geri alınır.
do $kontrol$
declare n integer;
begin
  select count(*) into n
    from public.dossier_sections s
    join public.country_dossiers d on d.id = s.dossier_id
   where d.slug = 'misir';
  if n <> 18 then
    raise exception 'Bölüm sayısı 18 olmalıydı, % yazıldı', n;
  end if;
end
$kontrol$;

commit;
