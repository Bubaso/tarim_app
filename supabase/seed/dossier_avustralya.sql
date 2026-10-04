-- Avustralya — Ülke Dosyası · seed
--
-- ÜRETİLMİŞ DOSYA — elle düzenlemeyin.
-- Kaynak:  content/dossiers/avustralya/
-- Üretim:  node content/dossiers/seed_dossier.mjs avustralya
-- Tarih:   2026-10-04T04:44:01.050Z
--
-- Bölüm: 18 · TR ~4.415 kelime · EN ~5.921 kelime
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
  'avustralya',
  'Avustralya',
  'Australia',
  'AUS',
  'ulke',
  null,
  4,
  $dsr$Avustralya'da suyun kendi sicili var: maliki adıyla kayıtlı, fiyatı belli, ipotek edilebilir. Taşıyacak nehir daraldığında sırayı kura belirliyor.$dsr$,
  $dsr$In Australia water has a register of its own: the owner recorded by name, the price known, the holding mortgageable. When the river that must carry it narrows, the queue is decided by lot.$dsr$,
  $dsr${"_dosya":"Avustralya — Ülke Dosyası · tasarım künyesi","_amac":"Görsel kararlar. DossierTheme bu dosyadan üretilir; kodda serbest renk yazılmaz.","_kural":"Bu dosyadaki hiçbir kontrast sayısı 'yaklaşık' değildir. Hepsi _raw/kontrast.py'den geliyor; palet değişirse betik yeniden koşar ve buradaki sayılar güncellenir.","_sureklilik":"Dört dosya, dört geometri: Hollanda dikey şeritler (polder), Rusya yatay bantlar (toprak profili), İspanya nokta ızgarası (dikilmiş zeytinlik), Avustralya ortogonal ızgara (sulama kanalı ağı). Dördü de İNSAN YAPIMI düzen — dizinin sessiz ortak fikri. Bu dosyada fikir bir adım ileri gidiyor: ızgara yalnızca düzenin izi değil, piyasayı MÜMKÜN KILAN altyapı. Suyun yağdığı yerden bağımsız taşınabilmesi o kanalların varlığına bağlı.","tez_cumlesi":{"tr":"Avustralya'da suyun kendi sicili var: maliki adıyla kayıtlı, fiyatı belli, ipotek edilebilir. Taşıyacak nehir daraldığında sırayı kura belirliyor.","en":"In Australia water has a register of its own: the owner recorded by name, the price known, the holding mortgageable. When the river that must carry it narrows, the queue is decided by lot.","gerekce":"Cümlenin iki yarısı arasındaki gerilim dosyanın omurgası: ilk yarı suyun ne kadar eksiksiz bir mülk olduğunu sayıyor, ikinci yarı o mülkün en kritik noktada tesadüfe bırakıldığını söylüyor. Rotasyon Avustralya'yı 'Model' diye kaydetmişti; veri daha keskin bir şey söyledi — suyu sicile bağlayan, fiyatlandıran ve ipotek edilebilir kılan idare, kapasitenin bittiği yerde kura çekiyor.","_dayanak":"Dört öğesinin dördü de birincil ya da sicil kaynaklı: malikin adıyla kaydı Water Act 1989 m. 84I'de, ipotek 'mortgage of a water share' ibaresinde (yedi yerde), fiyat sicilin Tablo 4'ünde, kura ise Temmuz 2026 açılış raporunda ve ACCC'nin imzalı yazısında.","_sayi_yok":"Cümlede rakam yok; ölçü sonraki bölümlerde veriliyor.","_olumsuz_yok":"Cümle 'toprağın parçası değil' diye kurulabilirdi — ayrışmayı bir yokluk üzerinden anlatırdı. Üç olumlu nitelikle (kayıtlı, fiyatı belli, ipotek edilebilir) aynı şey söyleniyor.","_metafor_siniri":"'Tapu' kelimesi kullanılmadı. Kanun 'water share' ve 'water register' diyor; tapu Türk hukukunda taşınmaza bağlı bir kurum ve benzetme okuru yanlış yere götürürdü. 'Sicil' kanunun kendi kelimesinin karşılığı."},"palet":{"ad":"Toprak ve Kanal","kaynak_fikir":"Palet manzaradan değil, AYRIŞMANIN KENDİSİNDEN türetildi: birbirine değen ama karışmayan iki madde. Kuru toprak ve kanal suyu bir sulama hendeğinin iki yanında yan yana durur, biri ötekinin rengini almaz. Dosyanın anlattığı hukuki ayrışmanın maddi karşılığı bu: su, üstünden geçtiği toprağın maliki olmayan birinin olabilir.","mod":"KOYU — dosya sayfası her zaman koyu. Uygulamanın açık/koyu tercihini izlemez.","mod_gerekcesi":"Dergi dosyası mantığı: içeri girdiğinizde başka bir yere geldiğinizi anlamalısınız (İspanya'dan devralınan karar). Ana sayfadaki şerit bunun istisnasıdır — sayfanın içinde yaşadığı için açık/koyu izler.","koyu":{"zemin":{"hex":"#11100D","rol":"Sayfa arka planı — gece, sulama bölgesi"},"yuzey":{"hex":"#1E1C17","rol":"Kart, tablo, alıntı bloğu","kontrast_zemin":1.12},"murekkep":{"hex":"#EFEBE1","rol":"Gövde metni","kontrast_zemin":15.98,"kontrast_yuzey":14.3},"sessiz":{"hex":"#A69D8D","rol":"Meta, kaynak satırı, altyazı","kontrast_zemin":7.09,"kontrast_yuzey":6.35},"vurgu":{"hex":"#5BC8C0","rol":"Kanal suyu — rakamlar, başlık vurguları, Avustralya serisi","kontrast_zemin":9.48,"kontrast_yuzey":8.48},"ikincil":{"hex":"#C9763C","rol":"Kuru toprak — karşılaştırmanın ikinci rengi","kontrast_zemin":5.56,"kontrast_yuzey":4.98},"cizgi":{"hex":"#2B2922","rol":"SADECE dekoratif ayırıcı","kontrast_zemin":1.31,"kontrast_yuzey":1.17,"_uyari":"3:1'in altında. Anlam taşıyan hiçbir yerde kullanılamaz — grafik ekseni, sınır, odak halkası için cizgiVurgu kullanılır."},"cizgiVurgu":{"hex":"#7A7363","rol":"Grafik ekseni, ızgara çizgisi, işlem akışı omurgası, odak halkası","kontrast_zemin":4.04,"kontrast_yuzey":3.62}},"acik_mod_seridi":{"_amac":"Ana sayfadaki dosya şeridi sayfanın içinde yaşıyor; krem zemin üstünde koyu gövdenin renkleri okunmuyor.","murekkep":{"hex":"#1A1813","kontrast_krem":15.76},"vurguKoyu":{"hex":"#0B4F4A","rol":"Kanal suyunun krem zemindeki karşılığı","kontrast_krem":8.36},"ikincilKoyu":{"hex":"#8A4414","rol":"Kuru toprağın krem zemindeki karşılığı","kontrast_krem":6.39}},"renk_korlugu_notu":"HOLLANDA DERSİ İKİ KEZ UYGULANDI. Orada sodyum turuncusu (0,4867) ile cam yeşili (0,4650) neredeyse eş parlaklıktaydı — oran 1,05 — ve deuteranopi altında ayırt edilemiyorlardı. (1) Koyu gövdede kanal suyu 0,4734, kuru toprak 0,2570; oran 1,84. (2) ŞERİTTE İLK HESAP 1,06 ÇIKTI — tam Hollanda hatası. Teal #0E5F5A'dan #0B4F4A'ya koyulaştırıldı, oran 1,56'ya çıktı. İlk denemeyi kontrast.py yakaladı; göz yakalamazdı.","_cizgivurgu_notu":"İlk seçim #6A6354 idi: zeminde 3,19 ile eşiği geçiyor ama YÜZEYDE 2,86 ile geçmiyordu. Yalnız zemine bakan bir denetim bunu kaçırırdı; betik iki zemini birlikte sınıyor. #7A7363 ikisinde de geçiyor (4,04 / 3,62).","denetim_betigi":"_raw/kontrast.py — `python3 content/dossiers/avustralya/_raw/kontrast.py`"},"motif":{"ad":"Kanal ızgarası","tanim":"Sulama bölgesinin ortogonal kanal ağı: taşkın ovasına dik açılarla oturtulmuş, iki yönde uzanan ince çizgi örgüsü.","gerekce":"Dizideki dördüncü geometri ve bilerek öteki üçünden farklı: Hollanda dikey şerit, Rusya yatay bant, İspanya nokta, burası İKİ YÖNLÜ ızgara. Ortak fikir aynı kalıyor — bu manzara doğal değil, kazılmış. Ama bu dosyada ızgara fazladan bir iş yapıyor: suyun yağdığı yerden bağımsız taşınabilmesi, yani piyasanın mümkün olması, o kanalların varlığına bağlı.","uygulama":{"opaklik":"%6","renk":"cizgiVurgu #7A7363 üzerine opaklık","bicim":"Vektör (CustomPainter) — raster değil. Ölçeklenebilir, dosya boyutu sıfır, telif sorunu yok.","yerlesim":"Bölüm ayırıcılarında ve kapak altı geçiş bandında. Gövde metninin ARKASINDA kullanılmaz.","moire_notu":"Izgara aralığı 24 px'in altına inmeyecek; iki yönlü örgü tek yönlüden daha çok titrer."},"_UYGULANMAMIŞ":"ÖNEMLİ — BU GEOMETRİ ŞU AN ÇİZİLMİYOR. Depodaki tek motif çizici `polder_motif.dart` ve `DossierTheme` motif bloğundan YALNIZCA opaklığı okuyor (`motifOpaklik`); `motifAralik` bile JSON'dan değil yedekten geliyor. Bir `yon` alanı da kodda hiçbir yerde okunmuyor — İspanya'nın tasarım künyesinde 'paylaşım kartı bu alanı okuyor' diye bir not var, kodda karşılığı yok. Bu yüzden burada `yon` alanı YAZILMADI: okunmayan bir alana değer yazmak, sonraki turda 'ızgara motifi bölüm ayırıcılarında görünüyor' diye yanlış bir cümle yazdırır. Izgara bir ŞARTNAMEDİR; çizici yazılana kadar sayfada polder motifi görünür."},"kapak":{"yon":"Sulama bölgesinin kanal ağı — havadan","gerekce":"Tezin doğrudan görselleştirmesi değil, zemini: dosyanın anlattığı bütün piyasa bu kazılmış ağın üstünde işliyor. Hollanda ve Rusya yörüngeden, İspanya yerden bakıyordu; burası yine yükseliyor çünkü ızgara ancak yukarıdan ızgara gibi görünüyor.","gorsel_kaynagi":{"tercih_1":"NASA Earth Observatory / ISS astronot fotoğrafı — kamu malı.","tercih_2":"Wikimedia Commons, açık lisanslı havadan çekim.","tercih_3":"data.gov.au / eyalet kurumlarının açık lisanslı havadan görüntüleri — bu ağdan açık olduğu ÖLÇÜLDÜ.","_karar":"Görsel BULUNANA KADAR kapak tipografik iskeletle çalışır — sayfa görselsiz de tam çalışmak zorunda (§3.5).","_yasak":"Telifi belirsiz hiçbir görsel kullanılmayacak. Google görsel araması kaynak değildir.","_erisim_uyarisi":"Bu dosyanın kaynak turlarında ölçüldü: agriculture.gov.au ve data.daff.gov.au bu ağdan 000, mdba.gov.au 403. Görsel aramasında o üç adrese gidilmesin."},"tipografi_katmani":{"ust_satir":"ÜLKE DOSYASI · 04","baslik":"AVUSTRALYA","alt_satir":"tez_cumlesi.tr","veri_rozeti":"Barmah darlığından geçen akış: günde yaklaşık 7.000 megalitre"},"_rozet_notu":"Rozet kasıtlı olarak kapasiteyi söylüyor, piyasa büyüklüğünü değil. Dosyanın sürprizi piyasanın büyüklüğü değil, piyasanın bittiği yer.","_baslik_notu":"En uzun kelime başlığın kendisi: 'AVUSTRALYA' (10 harf). _KapakAdi puntoyu en uzun kelimeye bakarak küçültüyor (§10.4); on harf İSPANYA'dan (7) uzun, KOOPERATİFLERİ'nden (14) kısa — ikisi de taşmadan çalıştığı için bu da çalışır.","okunurluk":"Görsel üzerine zemin renginden %0 → %85 dikey gradyan; metin yalnızca %60+ bölgede durur."},"_zorunluluklar":["Grafiklerde iki seri renkle BİRLİKTE biçimle de ayrılacak; bu dosyada parlaklık farkı da var (gövdede 1,84, şeritte 1,56) ve asıl güvence o.","Kanal ızgarası motifi CustomPainter ile çizilecek — ama çizici YAZILANA KADAR sayfada polder motifi görünür; bu dosyada aksini iddia eden cümle yazılmayacak.","Kapak görseli bulunamazsa sayfa yine de tam çalışacak.","Koyu sayfa sistem açık/koyu tercihini izlemeyecek; ana sayfa şeridi izleyecek.","Tüm renkler bu dosyadan türetilen DossierTheme üzerinden gelecek, kodda serbest hex yazılmayacak.","Palet değişirse _raw/kontrast.py yeniden çalıştırılacak ve buradaki kontrast alanları güncellenecek."],"_yasak":["Avustralya bayrağı, armaları ya da eyalet amblemleri","Stok \"kurak toprakta çatlak\" fotoğrafı — dosya kuraklığı değil su hakkını anlatıyor","Koala, kanguru ya da herhangi bir ülke klişesi","ACCC, DEECA ya da WaterNSW logoları; resmî yazı tıpkıbasımı","Kura/çekiliş çağrışımlı dekoratif ikon (zar, top, piyango makinesi) — mekanizma ciddi bir idari işlem, oyun değil"]}$dsr$::jsonb,
  $dsr${"_dosya":"Avustralya — Ülke Dosyası Sayı 04 · veri katmanı","_uretim":"build_data.py — elle düzenlenmez","_eksen":"Su, topraktan hukuken ayrılmış, fiyatı olan, alınıp satılan bir mülkiyet hakkıdır; kapasite bittiğinde sıra kurayla belirlenir.","kanun":{"_kaynak_niteligi":"BİRİNCİL — Water Act 1989 (Victoria), Tasdikli Sürüm No. 147","_kaynak":"legislation.vic.gov.au · Baş Parlamento Müşaviri tasdiki, 24 Haziran 2026","_kapsam":"Victoria eyaleti mevzuatı","surum":147,"sayfa":923,"tanim":"water share means a water share issued under Division 2 of Part 3A","ihdas":"The Minister may issue a water share in respect of a declared water system","dayanak_dipnot":"S. 33F inserted by No. 99/2005 s. 41","dayanak_kanun":"Water (Resource Management) Act 2005, No. 99/2005","tasdik_tarihi":"2005-12-07","yururluk_tarihi":"2006-08-03","yururluk_dayanagi":"Özel Resmî Gazete No. 191, 2.8.06 s. 1 — ss 35–57 bu tarihte","pay_kismi":"Part 3A—Water shares","kullanim_kismi":"Part 4B—Water-use licences and water use registrations","arazide_kullanim_yasagi":"use water on land","ipotek":"mortgage of a water share","sicil_kaydi":"the name and address of","sicil_gecis_sayisi":190,"memur_gecis_sayisi":154,"_not":"Kanunda 'separate from land' gibi bir BEYAN cümlesi YOK. Ayrışma iki ayrı kısmın varlığından okunuyor. Metinde kanundan böyle bir cümle alıntılanmayacak."},"ayrisma_takvimi":{"_kaynak_niteligi":"SİCİLİN BEYANI — Victoria Su Sicili, eğilim raporu Ek 1","_kapsam":"kuzey Victoria","ayrisma_gunu":"2007-07-01","ayrisma_alintisi":"When unbundling occurred in northern Victoria (1 July 2007)","ayrisma_notu":"all water shares were associated with land","tavan_yuzde":10,"tavan_alintisi":"no more than 10% of the water share volume in a system could be owned without being linked to land","tavan_kaldirildi":2009,"cikis_tavani_yuzde":4,"cikis_tavani_alintisi":"no more than 4% of the water share volume in an irrigation area could be moved out the area in a year","cikis_tavani_kaldirildi":2014,"birliktelik_kaldirildi":"2023-11-20","birliktelik_alintisi":"removed the ability to associate a water share with land","_yontem_uyarisi":"Rapor 2023 değişikliği nedeniyle 'linked to land' yöntemine geçti; eski 'tied to land' ile farkı Şekil 17'de, yani GRAFİKTE — metinden çıkarılamıyor. Tablo 6'nın başlığı eski ibareyi taşısa da verisi yeni yöntem (2023-24'te iki tablo da 1.262 GL). Metinde tied/linked ayrımı üzerine cümle kurulmayacak."},"sahiplik":{"_kaynak_niteligi":"SİCİLİN BEYANI — Victoria Su Sicili","_kapsam":"kuzey Victoria — Avustralya geneli DEĞİL","_tablo":"Table 2","_baslik":"Northern Victorian high-reliability water share volume at 30 June","_birim":"GL / %","kayitlar":[{"yil":"2000-01","cevre_gl":0,"su_kurumu_gl":0,"ozel_topraga_bagli_degil_gl":0,"ozel_topraga_bagli_gl":2283,"toplam_gl":2283,"topraga_bagli_pay_yuzde":100,"topraga_bagli_degil_pay_yuzde":0,"cevre_pay_yuzde":0,"yil_no":2000},{"yil":"2004-05","cevre_gl":0,"su_kurumu_gl":0,"ozel_topraga_bagli_degil_gl":0,"ozel_topraga_bagli_gl":2251,"toplam_gl":2251,"topraga_bagli_pay_yuzde":100,"topraga_bagli_degil_pay_yuzde":0,"cevre_pay_yuzde":0,"yil_no":2004},{"yil":"2008-09","cevre_gl":0,"su_kurumu_gl":0,"ozel_topraga_bagli_degil_gl":125,"ozel_topraga_bagli_gl":2163,"toplam_gl":2288,"topraga_bagli_pay_yuzde":94.5,"topraga_bagli_degil_pay_yuzde":5.5,"cevre_pay_yuzde":0,"yil_no":2008},{"yil":"2009-10","cevre_gl":160,"su_kurumu_gl":46,"ozel_topraga_bagli_degil_gl":128,"ozel_topraga_bagli_gl":1947,"toplam_gl":2280,"topraga_bagli_pay_yuzde":85.4,"topraga_bagli_degil_pay_yuzde":5.6,"cevre_pay_yuzde":7,"yil_no":2009},{"yil":"2010-11","cevre_gl":283,"su_kurumu_gl":64,"ozel_topraga_bagli_degil_gl":120,"ozel_topraga_bagli_gl":1813,"toplam_gl":2279,"topraga_bagli_pay_yuzde":79.6,"topraga_bagli_degil_pay_yuzde":5.3,"cevre_pay_yuzde":12.4,"yil_no":2010},{"yil":"2011-12","cevre_gl":463,"su_kurumu_gl":67,"ozel_topraga_bagli_degil_gl":117,"ozel_topraga_bagli_gl":1635,"toplam_gl":2281,"topraga_bagli_pay_yuzde":71.7,"topraga_bagli_degil_pay_yuzde":5.1,"cevre_pay_yuzde":20.3,"yil_no":2011},{"yil":"2012-13","cevre_gl":499,"su_kurumu_gl":74,"ozel_topraga_bagli_degil_gl":142,"ozel_topraga_bagli_gl":1569,"toplam_gl":2285,"topraga_bagli_pay_yuzde":68.7,"topraga_bagli_degil_pay_yuzde":6.2,"cevre_pay_yuzde":21.8,"yil_no":2012},{"yil":"2013-14","cevre_gl":539,"su_kurumu_gl":59,"ozel_topraga_bagli_degil_gl":146,"ozel_topraga_bagli_gl":1552,"toplam_gl":2295,"topraga_bagli_pay_yuzde":67.6,"topraga_bagli_degil_pay_yuzde":6.4,"cevre_pay_yuzde":23.5,"yil_no":2013},{"yil":"2014-15","cevre_gl":605,"su_kurumu_gl":62,"ozel_topraga_bagli_degil_gl":156,"ozel_topraga_bagli_gl":1516,"toplam_gl":2338,"topraga_bagli_pay_yuzde":64.8,"topraga_bagli_degil_pay_yuzde":6.7,"cevre_pay_yuzde":25.9,"yil_no":2014},{"yil":"2015-16","cevre_gl":648,"su_kurumu_gl":62,"ozel_topraga_bagli_degil_gl":197,"ozel_topraga_bagli_gl":1473,"toplam_gl":2380,"topraga_bagli_pay_yuzde":61.9,"topraga_bagli_degil_pay_yuzde":8.3,"cevre_pay_yuzde":27.2,"yil_no":2015},{"yil":"2016-17","cevre_gl":652,"su_kurumu_gl":63,"ozel_topraga_bagli_degil_gl":237,"ozel_topraga_bagli_gl":1428,"toplam_gl":2380,"topraga_bagli_pay_yuzde":60,"topraga_bagli_degil_pay_yuzde":10,"cevre_pay_yuzde":27.4,"yil_no":2016},{"yil":"2017-18","cevre_gl":661,"su_kurumu_gl":63,"ozel_topraga_bagli_degil_gl":272,"ozel_topraga_bagli_gl":1390,"toplam_gl":2386,"topraga_bagli_pay_yuzde":58.3,"topraga_bagli_degil_pay_yuzde":11.4,"cevre_pay_yuzde":27.7,"yil_no":2017},{"yil":"2018-19","cevre_gl":732,"su_kurumu_gl":61,"ozel_topraga_bagli_degil_gl":307,"ozel_topraga_bagli_gl":1355,"toplam_gl":2455,"topraga_bagli_pay_yuzde":55.2,"topraga_bagli_degil_pay_yuzde":12.5,"cevre_pay_yuzde":29.8,"yil_no":2018},{"yil":"2019-20","cevre_gl":732,"su_kurumu_gl":62,"ozel_topraga_bagli_degil_gl":330,"ozel_topraga_bagli_gl":1331,"toplam_gl":2455,"topraga_bagli_pay_yuzde":54.2,"topraga_bagli_degil_pay_yuzde":13.4,"cevre_pay_yuzde":29.8,"yil_no":2019},{"yil":"2020-21","cevre_gl":733,"su_kurumu_gl":62,"ozel_topraga_bagli_degil_gl":344,"ozel_topraga_bagli_gl":1317,"toplam_gl":2456,"topraga_bagli_pay_yuzde":53.6,"topraga_bagli_degil_pay_yuzde":14,"cevre_pay_yuzde":29.8,"yil_no":2020},{"yil":"2021-22","cevre_gl":733,"su_kurumu_gl":48,"ozel_topraga_bagli_degil_gl":397,"ozel_topraga_bagli_gl":1322,"toplam_gl":2500,"topraga_bagli_pay_yuzde":52.9,"topraga_bagli_degil_pay_yuzde":15.9,"cevre_pay_yuzde":29.3,"yil_no":2021},{"yil":"2022-23","cevre_gl":739,"su_kurumu_gl":48,"ozel_topraga_bagli_degil_gl":435,"ozel_topraga_bagli_gl":1285,"toplam_gl":2507,"topraga_bagli_pay_yuzde":51.3,"topraga_bagli_degil_pay_yuzde":17.4,"cevre_pay_yuzde":29.5,"yil_no":2022},{"yil":"2023-24","cevre_gl":747,"su_kurumu_gl":50,"ozel_topraga_bagli_degil_gl":456,"ozel_topraga_bagli_gl":1262,"toplam_gl":2515,"topraga_bagli_pay_yuzde":50.2,"topraga_bagli_degil_pay_yuzde":18.1,"cevre_pay_yuzde":29.7,"yil_no":2023}],"_2008_09_tutarsizligi":"KAYNAK KENDİ İÇİNDE ÇELİŞİYOR — yalnız bu satırda. Rapor yüzdeleri çevre %1, kurum %2, topraksız %12, bağlı %85 diyor; aynı satırın hacimleri 0 / 0 / 125 / 2.163 GL, toplam 2.288 GL. Hacimlerden hesap %0 / %0 / %5,5 / %94,5. Diğer on yedi satırın tamamında rapor kendi hacmine oturuyor. Buradaki yüzdeler HESAPLANMIŞ değerlerdir. METİNDE 2008-09 YÜZDESİ ÜZERİNE CÜMLE KURULMAZ; temiz seri 2009-10'da başlar.","ilk_yil":"2000-01","son_yil":"2023-24","ilk_topraga_bagli_yuzde":100,"son_topraga_bagli_yuzde":50.2,"son_topraksiz_yuzde":18.1,"son_cevre_yuzde":29.7},"kullanim":{"_kaynak_niteligi":"SİCİLİN BEYANI — Victoria Su Sicili","_kapsam":"kuzey Victoria — Avustralya geneli DEĞİL","_tablo":"Table 6","_baslik":"Volumes of high-reliability water share tied to land compared to annual water use","_birim":"GL / %","kayitlar":[{"yil":"2004-05","topraga_bagli_gl":2252,"kullanim_gl":2151,"kullanim_oran_yuzde":96,"yil_no":2004},{"yil":"2008-09","topraga_bagli_gl":2163,"kullanim_gl":925,"kullanim_oran_yuzde":43,"yil_no":2008},{"yil":"2009-10","topraga_bagli_gl":1947,"kullanim_gl":1135,"kullanim_oran_yuzde":58,"yil_no":2009},{"yil":"2010-11","topraga_bagli_gl":1813,"kullanim_gl":751,"kullanim_oran_yuzde":41,"yil_no":2010},{"yil":"2011-12","topraga_bagli_gl":1635,"kullanim_gl":1732,"kullanim_oran_yuzde":106,"yil_no":2011},{"yil":"2012-13","topraga_bagli_gl":1569,"kullanim_gl":2402,"kullanim_oran_yuzde":153,"yil_no":2012},{"yil":"2013-14","topraga_bagli_gl":1552,"kullanim_gl":1857,"kullanim_oran_yuzde":120,"yil_no":2013},{"yil":"2014-15","topraga_bagli_gl":1516,"kullanim_gl":2033,"kullanim_oran_yuzde":134,"yil_no":2014},{"yil":"2015-16","topraga_bagli_gl":1473,"kullanim_gl":1762,"kullanim_oran_yuzde":120,"yil_no":2015},{"yil":"2016-17","topraga_bagli_gl":1428,"kullanim_gl":1454,"kullanim_oran_yuzde":102,"yil_no":2016},{"yil":"2017-18","topraga_bagli_gl":1390,"kullanim_gl":1967,"kullanim_oran_yuzde":142,"yil_no":2017},{"yil":"2018-19","topraga_bagli_gl":1355,"kullanim_gl":1752,"kullanim_oran_yuzde":129,"yil_no":2018},{"yil":"2019-20","topraga_bagli_gl":1331,"kullanim_gl":1113,"kullanim_oran_yuzde":84,"yil_no":2019},{"yil":"2020-21","topraga_bagli_gl":1317,"kullanim_gl":1545,"kullanim_oran_yuzde":117,"yil_no":2020},{"yil":"2021-22","topraga_bagli_gl":1322,"kullanim_gl":1564,"kullanim_oran_yuzde":118,"yil_no":2021},{"yil":"2022-23","topraga_bagli_gl":1285,"kullanim_gl":1273,"kullanim_oran_yuzde":99,"yil_no":2022},{"yil":"2023-24","topraga_bagli_gl":1262,"kullanim_gl":1716,"kullanim_oran_yuzde":136,"yil_no":2023}],"en_yuksek_oran":{"yil":"2012-13","oran":153},"en_dusuk_oran":{"yil":"2010-11","oran":41}},"pay_fiyati":{"_kaynak_niteligi":"SİCİLİN BEYANI — Victoria Su Sicili","_kapsam":"kuzey Victoria — Avustralya geneli DEĞİL","_tablo":"Table 4","_baslik":"Transfers and price of high-reliability water shares in northern Victoria","_birim":"GL / AUD-ML","kayitlar":[{"yil":"2008-09","devlete_devir_gl":8,"diger_devir_gl":154,"medyan_fiyat_aud_ml":2175,"yil_no":2008},{"yil":"2009-10","devlete_devir_gl":127,"diger_devir_gl":210,"medyan_fiyat_aud_ml":2200,"yil_no":2009},{"yil":"2010-11","devlete_devir_gl":113,"diger_devir_gl":98,"medyan_fiyat_aud_ml":1940,"yil_no":2010},{"yil":"2011-12","devlete_devir_gl":174,"diger_devir_gl":93,"medyan_fiyat_aud_ml":1800,"yil_no":2011},{"yil":"2012-13","devlete_devir_gl":31,"diger_devir_gl":104,"medyan_fiyat_aud_ml":1500,"yil_no":2012},{"yil":"2013-14","devlete_devir_gl":10,"diger_devir_gl":93,"medyan_fiyat_aud_ml":1380,"yil_no":2013},{"yil":"2014-15","devlete_devir_gl":25,"diger_devir_gl":99,"medyan_fiyat_aud_ml":1500,"yil_no":2014},{"yil":"2015-16","devlete_devir_gl":1,"diger_devir_gl":124,"medyan_fiyat_aud_ml":2400,"yil_no":2015},{"yil":"2016-17","devlete_devir_gl":5,"diger_devir_gl":151,"medyan_fiyat_aud_ml":2600,"yil_no":2016},{"yil":"2017-18","devlete_devir_gl":3,"diger_devir_gl":66,"medyan_fiyat_aud_ml":2850,"yil_no":2017},{"yil":"2018-19","devlete_devir_gl":null,"diger_devir_gl":112,"medyan_fiyat_aud_ml":3700,"yil_no":2018},{"yil":"2019-20","devlete_devir_gl":0,"diger_devir_gl":156,"medyan_fiyat_aud_ml":4800,"yil_no":2019},{"yil":"2020-21","devlete_devir_gl":1,"diger_devir_gl":88,"medyan_fiyat_aud_ml":4500,"yil_no":2020},{"yil":"2021-22","devlete_devir_gl":null,"diger_devir_gl":112,"medyan_fiyat_aud_ml":4950,"yil_no":2021},{"yil":"2022-23","devlete_devir_gl":null,"diger_devir_gl":82,"medyan_fiyat_aud_ml":5000,"yil_no":2022},{"yil":"2023-24","devlete_devir_gl":null,"diger_devir_gl":60,"medyan_fiyat_aud_ml":4500,"yil_no":2023}],"_nitelik":"yüksek güvenilirlikli","en_dusuk":{"yil":"2013-14","devlete_devir_gl":10,"diger_devir_gl":93,"medyan_fiyat_aud_ml":1380,"yil_no":2013},"en_yuksek":{"yil":"2022-23","devlete_devir_gl":null,"diger_devir_gl":82,"medyan_fiyat_aud_ml":5000,"yil_no":2022},"kat":3.62},"pay_fiyati_dusuk":{"_kaynak_niteligi":"SİCİLİN BEYANI — Victoria Su Sicili","_kapsam":"kuzey Victoria — Avustralya geneli DEĞİL","_tablo":"Table 5","_baslik":"Transfers and price of low-reliability water shares in northern Victoria","_birim":"GL / AUD-ML","kayitlar":[{"yil":"2008-09","devlete_devir_gl":1,"diger_devir_gl":74,"medyan_fiyat_aud_ml":200,"yil_no":2008},{"yil":"2009-10","devlete_devir_gl":20,"diger_devir_gl":35,"medyan_fiyat_aud_ml":175,"yil_no":2009},{"yil":"2010-11","devlete_devir_gl":1,"diger_devir_gl":53,"medyan_fiyat_aud_ml":150,"yil_no":2010},{"yil":"2011-12","devlete_devir_gl":0,"diger_devir_gl":64,"medyan_fiyat_aud_ml":140,"yil_no":2011},{"yil":"2012-13","devlete_devir_gl":null,"diger_devir_gl":47,"medyan_fiyat_aud_ml":150,"yil_no":2012},{"yil":"2013-14","devlete_devir_gl":0,"diger_devir_gl":32,"medyan_fiyat_aud_ml":185,"yil_no":2013},{"yil":"2014-15","devlete_devir_gl":null,"diger_devir_gl":40,"medyan_fiyat_aud_ml":225,"yil_no":2014},{"yil":"2015-16","devlete_devir_gl":null,"diger_devir_gl":35,"medyan_fiyat_aud_ml":244,"yil_no":2015},{"yil":"2016-17","devlete_devir_gl":null,"diger_devir_gl":61,"medyan_fiyat_aud_ml":250,"yil_no":2016},{"yil":"2017-18","devlete_devir_gl":null,"diger_devir_gl":26,"medyan_fiyat_aud_ml":340,"yil_no":2017},{"yil":"2018-19","devlete_devir_gl":null,"diger_devir_gl":55,"medyan_fiyat_aud_ml":500,"yil_no":2018},{"yil":"2019-20","devlete_devir_gl":null,"diger_devir_gl":36,"medyan_fiyat_aud_ml":500,"yil_no":2019},{"yil":"2020-21","devlete_devir_gl":null,"diger_devir_gl":37,"medyan_fiyat_aud_ml":470,"yil_no":2020},{"yil":"2021-22","devlete_devir_gl":null,"diger_devir_gl":44,"medyan_fiyat_aud_ml":650,"yil_no":2021},{"yil":"2022-23","devlete_devir_gl":null,"diger_devir_gl":44,"medyan_fiyat_aud_ml":895,"yil_no":2022},{"yil":"2023-24","devlete_devir_gl":null,"diger_devir_gl":30,"medyan_fiyat_aud_ml":850,"yil_no":2023}],"_nitelik":"düşük güvenilirlikli"},"topraksiz_su":{"_kaynak_niteligi":"SİCİLİN BEYANI — Victoria Su Sicili","_kapsam":"kuzey Victoria — Avustralya geneli DEĞİL","_tablo":"Table 16","_baslik":"How allocations made to private water shares not linked to land were used","_birim":"GL / %","kayitlar":[{"yil":"2007-08","ticari_satildi_gl":45,"sifirla_devredildi_gl":21,"kayip_buharlasma_gl":17,"devreden_gl":37,"devreden_yuzde":30,"yil_no":2007},{"yil":"2008-09","ticari_satildi_gl":39,"sifirla_devredildi_gl":21,"kayip_buharlasma_gl":10,"devreden_gl":33,"devreden_yuzde":32,"yil_no":2008},{"yil":"2009-10","ticari_satildi_gl":26,"sifirla_devredildi_gl":34,"kayip_buharlasma_gl":1,"devreden_gl":29,"devreden_yuzde":33,"yil_no":2009},{"yil":"2010-11","ticari_satildi_gl":35,"sifirla_devredildi_gl":37,"kayip_buharlasma_gl":3,"devreden_gl":62,"devreden_yuzde":45,"yil_no":2010},{"yil":"2011-12","ticari_satildi_gl":85,"sifirla_devredildi_gl":35,"kayip_buharlasma_gl":13,"devreden_gl":48,"devreden_yuzde":27,"yil_no":2011},{"yil":"2012-13","ticari_satildi_gl":87,"sifirla_devredildi_gl":49,"kayip_buharlasma_gl":7,"devreden_gl":21,"devreden_yuzde":13,"yil_no":2012},{"yil":"2013-14","ticari_satildi_gl":90,"sifirla_devredildi_gl":46,"kayip_buharlasma_gl":4,"devreden_gl":9,"devreden_yuzde":6,"yil_no":2013},{"yil":"2014-15","ticari_satildi_gl":149,"sifirla_devredildi_gl":76,"kayip_buharlasma_gl":3,"devreden_gl":12,"devreden_yuzde":5,"yil_no":2014},{"yil":"2015-16","ticari_satildi_gl":148,"sifirla_devredildi_gl":83,"kayip_buharlasma_gl":5,"devreden_gl":51,"devreden_yuzde":18,"yil_no":2015},{"yil":"2016-17","ticari_satildi_gl":226,"sifirla_devredildi_gl":165,"kayip_buharlasma_gl":6,"devreden_gl":110,"devreden_yuzde":22,"yil_no":2016},{"yil":"2017-18","ticari_satildi_gl":293,"sifirla_devredildi_gl":238,"kayip_buharlasma_gl":5,"devreden_gl":59,"devreden_yuzde":10,"yil_no":2017},{"yil":"2018-19","ticari_satildi_gl":351,"sifirla_devredildi_gl":210,"kayip_buharlasma_gl":6,"devreden_gl":65,"devreden_yuzde":10,"yil_no":2018},{"yil":"2019-20","ticari_satildi_gl":222,"sifirla_devredildi_gl":266,"kayip_buharlasma_gl":8,"devreden_gl":121,"devreden_yuzde":20,"yil_no":2019},{"yil":"2020-21","ticari_satildi_gl":311,"sifirla_devredildi_gl":240,"kayip_buharlasma_gl":13,"devreden_gl":171,"devreden_yuzde":23,"yil_no":2020},{"yil":"2021-22","ticari_satildi_gl":362,"sifirla_devredildi_gl":285,"kayip_buharlasma_gl":19,"devreden_gl":216,"devreden_yuzde":24,"yil_no":2021},{"yil":"2022-23","ticari_satildi_gl":396,"sifirla_devredildi_gl":349,"kayip_buharlasma_gl":24,"devreden_gl":317,"devreden_yuzde":29,"yil_no":2022},{"yil":"2023-24","ticari_satildi_gl":538,"sifirla_devredildi_gl":459,"kayip_buharlasma_gl":30,"devreden_gl":270,"devreden_yuzde":21,"yil_no":2023}]},"tahsis_ticareti":{"_kaynak_niteligi":"SİCİLİN BEYANI — Victoria Su Sicili","_kapsam":"kuzey Victoria — Avustralya geneli DEĞİL","_tablo":"Table 9","_baslik":"Summary of private annual allocation trade in northern Victoria","_birim":"GL / adet / ML","kayitlar":[{"yil":"2007-08","ticari_hacim_gl":371,"sifir_fiyatli_hacim_gl":168,"toplam_hacim_gl":539,"ticari_islem":12996,"sifir_fiyatli_islem":4707,"toplam_islem":17703,"yuzde":38,"ort_parca_ticari_ml":29,"ort_parca_sifir_ml":36,"ort_parca_toplam_ml":30,"yil_no":2007},{"yil":"2008-09","ticari_hacim_gl":460,"sifir_fiyatli_hacim_gl":159,"toplam_hacim_gl":618,"ticari_islem":10810,"sifir_fiyatli_islem":4484,"toplam_islem":15294,"yuzde":59,"ort_parca_ticari_ml":43,"ort_parca_sifir_ml":35,"ort_parca_toplam_ml":40,"yil_no":2008},{"yil":"2009-10","ticari_hacim_gl":448,"sifir_fiyatli_hacim_gl":294,"toplam_hacim_gl":741,"ticari_islem":7277,"sifir_fiyatli_islem":3080,"toplam_islem":10357,"yuzde":39,"ort_parca_ticari_ml":62,"ort_parca_sifir_ml":95,"ort_parca_toplam_ml":72,"yil_no":2009},{"yil":"2010-11","ticari_hacim_gl":404,"sifir_fiyatli_hacim_gl":372,"toplam_hacim_gl":776,"ticari_islem":2209,"sifir_fiyatli_islem":1657,"toplam_islem":3866,"yuzde":28,"ort_parca_ticari_ml":183,"ort_parca_sifir_ml":225,"ort_parca_toplam_ml":201,"yil_no":2010},{"yil":"2011-12","ticari_hacim_gl":715,"sifir_fiyatli_hacim_gl":436,"toplam_hacim_gl":1150,"ticari_islem":3513,"sifir_fiyatli_islem":2283,"toplam_islem":5796,"yuzde":28,"ort_parca_ticari_ml":204,"ort_parca_sifir_ml":191,"ort_parca_toplam_ml":198,"yil_no":2011},{"yil":"2012-13","ticari_hacim_gl":1025,"sifir_fiyatli_hacim_gl":369,"toplam_hacim_gl":1394,"ticari_islem":7955,"sifir_fiyatli_islem":3832,"toplam_islem":11787,"yuzde":40,"ort_parca_ticari_ml":129,"ort_parca_sifir_ml":96,"ort_parca_toplam_ml":118,"yil_no":2012},{"yil":"2013-14","ticari_hacim_gl":902,"sifir_fiyatli_hacim_gl":382,"toplam_hacim_gl":1284,"ticari_islem":8410,"sifir_fiyatli_islem":4022,"toplam_islem":12432,"yuzde":58,"ort_parca_ticari_ml":107,"ort_parca_sifir_ml":95,"ort_parca_toplam_ml":103,"yil_no":2013},{"yil":"2014-15","ticari_hacim_gl":855,"sifir_fiyatli_hacim_gl":455,"toplam_hacim_gl":1310,"ticari_islem":9446,"sifir_fiyatli_islem":4653,"toplam_islem":14099,"yuzde":56,"ort_parca_ticari_ml":91,"ort_parca_sifir_ml":98,"ort_parca_toplam_ml":93,"yil_no":2014},{"yil":"2015-16","ticari_hacim_gl":794,"sifir_fiyatli_hacim_gl":523,"toplam_hacim_gl":1317,"ticari_islem":9424,"sifir_fiyatli_islem":5133,"toplam_islem":14557,"yuzde":66,"ort_parca_ticari_ml":84,"ort_parca_sifir_ml":102,"ort_parca_toplam_ml":90,"yil_no":2015},{"yil":"2016-17","ticari_hacim_gl":928,"sifir_fiyatli_hacim_gl":766,"toplam_hacim_gl":1694,"ticari_islem":7571,"sifir_fiyatli_islem":4517,"toplam_islem":12088,"yuzde":83,"ort_parca_ticari_ml":123,"ort_parca_sifir_ml":170,"ort_parca_toplam_ml":140,"yil_no":2016},{"yil":"2017-18","ticari_hacim_gl":1088,"sifir_fiyatli_hacim_gl":820,"toplam_hacim_gl":1908,"ticari_islem":10454,"sifir_fiyatli_islem":5051,"toplam_islem":15505,"yuzde":76,"ort_parca_ticari_ml":104,"ort_parca_sifir_ml":162,"ort_parca_toplam_ml":123,"yil_no":2017},{"yil":"2018-19","ticari_hacim_gl":1038,"sifir_fiyatli_hacim_gl":716,"toplam_hacim_gl":1754,"ticari_islem":14571,"sifir_fiyatli_islem":5194,"toplam_islem":19765,"yuzde":82,"ort_parca_ticari_ml":71,"ort_parca_sifir_ml":138,"ort_parca_toplam_ml":89,"yil_no":2018},{"yil":"2019-20","ticari_hacim_gl":914,"sifir_fiyatli_hacim_gl":965,"toplam_hacim_gl":1878,"ticari_islem":12518,"sifir_fiyatli_islem":7175,"toplam_islem":19693,"yuzde":119,"ort_parca_ticari_ml":73,"ort_parca_sifir_ml":134,"ort_parca_toplam_ml":95,"yil_no":2019},{"yil":"2020-21","ticari_hacim_gl":1212,"sifir_fiyatli_hacim_gl":884,"toplam_hacim_gl":2096,"ticari_islem":11151,"sifir_fiyatli_islem":4667,"toplam_islem":15818,"yuzde":91,"ort_parca_ticari_ml":109,"ort_parca_sifir_ml":189,"ort_parca_toplam_ml":133,"yil_no":2020},{"yil":"2021-22","ticari_hacim_gl":1224,"sifir_fiyatli_hacim_gl":820,"toplam_hacim_gl":2044,"ticari_islem":9510,"sifir_fiyatli_islem":3802,"toplam_islem":13312,"yuzde":81,"ort_parca_ticari_ml":129,"ort_parca_sifir_ml":216,"ort_parca_toplam_ml":154,"yil_no":2021},{"yil":"2022-23","ticari_hacim_gl":1252,"sifir_fiyatli_hacim_gl":911,"toplam_hacim_gl":2163,"ticari_islem":7039,"sifir_fiyatli_islem":2856,"toplam_islem":9895,"yuzde":88,"ort_parca_ticari_ml":178,"ort_parca_sifir_ml":319,"ort_parca_toplam_ml":219,"yil_no":2022},{"yil":"2023-24","ticari_hacim_gl":1445,"sifir_fiyatli_hacim_gl":1009,"toplam_hacim_gl":2454,"ticari_islem":10162,"sifir_fiyatli_islem":3614,"toplam_islem":13776,"yuzde":81,"ort_parca_ticari_ml":142,"ort_parca_sifir_ml":279,"ort_parca_toplam_ml":178,"yil_no":2023}]},"piyasa_katilimi":{"_kaynak_niteligi":"SİCİLİN BEYANI — Victoria Su Sicili","_kapsam":"kuzey Victoria — Avustralya geneli DEĞİL","_tablo":"Table 1","_baslik":"Number of unique allocation accounts involved in commercial trade in the Goulburn and Murray","_birim":"hesap adedi","kayitlar":[{"yil":"2015-16","sik_ticaret_yapan":50,"diger":6844,"toplam":6894,"sik_ticaret_yapan_yuzde":0.73,"yil_no":2015},{"yil":"2016-17","sik_ticaret_yapan":48,"diger":5540,"toplam":5588,"sik_ticaret_yapan_yuzde":0.86,"yil_no":2016},{"yil":"2017-18","sik_ticaret_yapan":68,"diger":7425,"toplam":7493,"sik_ticaret_yapan_yuzde":0.91,"yil_no":2017},{"yil":"2018-19","sik_ticaret_yapan":99,"diger":8617,"toplam":8716,"sik_ticaret_yapan_yuzde":1.14,"yil_no":2018},{"yil":"2019-20","sik_ticaret_yapan":104,"diger":7249,"toplam":7353,"sik_ticaret_yapan_yuzde":1.41,"yil_no":2019},{"yil":"2020-21","sik_ticaret_yapan":74,"diger":6919,"toplam":6993,"sik_ticaret_yapan_yuzde":1.06,"yil_no":2020},{"yil":"2021-22","sik_ticaret_yapan":76,"diger":6364,"toplam":6440,"sik_ticaret_yapan_yuzde":1.18,"yil_no":2021},{"yil":"2022-23","sik_ticaret_yapan":61,"diger":5188,"toplam":5249,"sik_ticaret_yapan_yuzde":1.16,"yil_no":2022},{"yil":"2023-24","sik_ticaret_yapan":84,"diger":6465,"toplam":6549,"sik_ticaret_yapan_yuzde":1.28,"yil_no":2023}],"_bulgu":"no evidence of systematic differences in the price"},"kaynak_dagilimi":{"_kaynak_niteligi":"SİCİLİN BEYANI — Victoria Su Sicili","_kapsam":"kuzey Victoria — Avustralya geneli DEĞİL","_tablo":"Table 19","_baslik":"Where did northern Victorian irrigators source their water from each year?","_birim":"GL","kayitlar":[{"yil":"2007-08","gmw_bolge":{"devreden_gl":40,"yeni_mevsimlik_gl":797,"net_ticaret_gl":-43,"kullanim_gl":657},"gmw_ceken":{"devreden_gl":10,"yeni_mevsimlik_gl":102,"net_ticaret_gl":-14,"kullanim_gl":61},"lmw_bolge":{"devreden_gl":21,"yeni_mevsimlik_gl":91,"net_ticaret_gl":30,"kullanim_gl":82},"lmw_ceken":{"devreden_gl":37,"yeni_mevsimlik_gl":141,"net_ticaret_gl":98,"kullanim_gl":201},"ara_toplam":{"devreden_gl":108,"yeni_mevsimlik_gl":1131,"net_ticaret_gl":72,"kullanim_gl":1001},"yil_no":2007},{"yil":"2008-09","gmw_bolge":{"devreden_gl":117,"yeni_mevsimlik_gl":473,"net_ticaret_gl":93,"kullanim_gl":556},"gmw_ceken":{"devreden_gl":19,"yeni_mevsimlik_gl":52,"net_ticaret_gl":0,"kullanim_gl":43},"lmw_bolge":{"devreden_gl":29,"yeni_mevsimlik_gl":52,"net_ticaret_gl":45,"kullanim_gl":89},"lmw_ceken":{"devreden_gl":53,"yeni_mevsimlik_gl":116,"net_ticaret_gl":115,"kullanim_gl":237},"ara_toplam":{"devreden_gl":218,"yeni_mevsimlik_gl":694,"net_ticaret_gl":254,"kullanim_gl":925},"yil_no":2008},{"yil":"2009-10","gmw_bolge":{"devreden_gl":120,"yeni_mevsimlik_gl":1029,"net_ticaret_gl":58,"kullanim_gl":745},"gmw_ceken":{"devreden_gl":14,"yeni_mevsimlik_gl":75,"net_ticaret_gl":-7,"kullanim_gl":33},"lmw_bolge":{"devreden_gl":35,"yeni_mevsimlik_gl":109,"net_ticaret_gl":1,"kullanim_gl":87},"lmw_ceken":{"devreden_gl":46,"yeni_mevsimlik_gl":246,"net_ticaret_gl":115,"kullanim_gl":269},"ara_toplam":{"devreden_gl":215,"yeni_mevsimlik_gl":1459,"net_ticaret_gl":167,"kullanim_gl":1135},"yil_no":2009},{"yil":"2010-11","gmw_bolge":{"devreden_gl":410,"yeni_mevsimlik_gl":1187,"net_ticaret_gl":105,"kullanim_gl":495},"gmw_ceken":{"devreden_gl":31,"yeni_mevsimlik_gl":87,"net_ticaret_gl":2,"kullanim_gl":19},"lmw_bolge":{"devreden_gl":52,"yeni_mevsimlik_gl":133,"net_ticaret_gl":-1,"kullanim_gl":43},"lmw_ceken":{"devreden_gl":125,"yeni_mevsimlik_gl":273,"net_ticaret_gl":211,"kullanim_gl":194},"ara_toplam":{"devreden_gl":618,"yeni_mevsimlik_gl":1680,"net_ticaret_gl":317,"kullanim_gl":751},"yil_no":2010},{"yil":"2011-12","gmw_bolge":{"devreden_gl":1201,"yeni_mevsimlik_gl":1171,"net_ticaret_gl":199,"kullanim_gl":1269},"gmw_ceken":{"devreden_gl":104,"yeni_mevsimlik_gl":102,"net_ticaret_gl":2,"kullanim_gl":58},"lmw_bolge":{"devreden_gl":139,"yeni_mevsimlik_gl":128,"net_ticaret_gl":-7,"kullanim_gl":84},"lmw_ceken":{"devreden_gl":434,"yeni_mevsimlik_gl":255,"net_ticaret_gl":34,"kullanim_gl":320},"ara_toplam":{"devreden_gl":1878,"yeni_mevsimlik_gl":1656,"net_ticaret_gl":229,"kullanim_gl":1732},"yil_no":2011},{"yil":"2012-13","gmw_bolge":{"devreden_gl":935,"yeni_mevsimlik_gl":1048,"net_ticaret_gl":297,"kullanim_gl":1777},"gmw_ceken":{"devreden_gl":115,"yeni_mevsimlik_gl":120,"net_ticaret_gl":-39,"kullanim_gl":104},"lmw_bolge":{"devreden_gl":153,"yeni_mevsimlik_gl":122,"net_ticaret_gl":-49,"kullanim_gl":114},"lmw_ceken":{"devreden_gl":347,"yeni_mevsimlik_gl":224,"net_ticaret_gl":97,"kullanim_gl":407},"ara_toplam":{"devreden_gl":1550,"yeni_mevsimlik_gl":1515,"net_ticaret_gl":306,"kullanim_gl":2402},"yil_no":2012},{"yil":"2013-14","gmw_bolge":{"devreden_gl":381,"yeni_mevsimlik_gl":999,"net_ticaret_gl":431,"kullanim_gl":1317},"gmw_ceken":{"devreden_gl":44,"yeni_mevsimlik_gl":117,"net_ticaret_gl":-15,"kullanim_gl":88},"lmw_bolge":{"devreden_gl":9,"yeni_mevsimlik_gl":119,"net_ticaret_gl":-1,"kullanim_gl":98},"lmw_ceken":{"devreden_gl":27,"yeni_mevsimlik_gl":228,"net_ticaret_gl":166,"kullanim_gl":354},"ara_toplam":{"devreden_gl":461,"yeni_mevsimlik_gl":1463,"net_ticaret_gl":581,"kullanim_gl":1857},"yil_no":2013},{"yil":"2014-15","gmw_bolge":{"devreden_gl":451,"yeni_mevsimlik_gl":981,"net_ticaret_gl":305,"kullanim_gl":1451},"gmw_ceken":{"devreden_gl":40,"yeni_mevsimlik_gl":116,"net_ticaret_gl":-21,"kullanim_gl":89},"lmw_bolge":{"devreden_gl":20,"yeni_mevsimlik_gl":118,"net_ticaret_gl":-15,"kullanim_gl":94},"lmw_ceken":{"devreden_gl":54,"yeni_mevsimlik_gl":232,"net_ticaret_gl":168,"kullanim_gl":399},"ara_toplam":{"devreden_gl":566,"yeni_mevsimlik_gl":1447,"net_ticaret_gl":437,"kullanim_gl":2033},"yil_no":2014},{"yil":"2015-16","gmw_bolge":{"devreden_gl":264,"yeni_mevsimlik_gl":907,"net_ticaret_gl":267,"kullanim_gl":1157},"gmw_ceken":{"devreden_gl":33,"yeni_mevsimlik_gl":104,"net_ticaret_gl":-14,"kullanim_gl":79},"lmw_bolge":{"devreden_gl":26,"yeni_mevsimlik_gl":118,"net_ticaret_gl":6,"kullanim_gl":102},"lmw_ceken":{"devreden_gl":48,"yeni_mevsimlik_gl":212,"net_ticaret_gl":260,"kullanim_gl":424},"ara_toplam":{"devreden_gl":371,"yeni_mevsimlik_gl":1341,"net_ticaret_gl":519,"kullanim_gl":1762},"yil_no":2015},{"yil":"2016-17","gmw_bolge":{"devreden_gl":238,"yeni_mevsimlik_gl":934,"net_ticaret_gl":372,"kullanim_gl":929},"gmw_ceken":{"devreden_gl":24,"yeni_mevsimlik_gl":114,"net_ticaret_gl":-5,"kullanim_gl":64},"lmw_bolge":{"devreden_gl":0,"yeni_mevsimlik_gl":118,"net_ticaret_gl":-3,"kullanim_gl":87},"lmw_ceken":{"devreden_gl":14,"yeni_mevsimlik_gl":207,"net_ticaret_gl":192,"kullanim_gl":374},"ara_toplam":{"devreden_gl":276,"yeni_mevsimlik_gl":1373,"net_ticaret_gl":556,"kullanim_gl":1454},"yil_no":2016},{"yil":"2017-18","gmw_bolge":{"devreden_gl":572,"yeni_mevsimlik_gl":900,"net_ticaret_gl":186,"kullanim_gl":1341},"gmw_ceken":{"devreden_gl":51,"yeni_mevsimlik_gl":115,"net_ticaret_gl":-24,"kullanim_gl":93},"lmw_bolge":{"devreden_gl":16,"yeni_mevsimlik_gl":115,"net_ticaret_gl":-10,"kullanim_gl":101},"lmw_ceken":{"devreden_gl":46,"yeni_mevsimlik_gl":232,"net_ticaret_gl":191,"kullanim_gl":432},"ara_toplam":{"devreden_gl":686,"yeni_mevsimlik_gl":1362,"net_ticaret_gl":342,"kullanim_gl":1967},"yil_no":2017},{"yil":"2018-19","gmw_bolge":{"devreden_gl":296,"yeni_mevsimlik_gl":873,"net_ticaret_gl":133,"kullanim_gl":1093},"gmw_ceken":{"devreden_gl":37,"yeni_mevsimlik_gl":111,"net_ticaret_gl":-23,"kullanim_gl":86},"lmw_bolge":{"devreden_gl":18,"yeni_mevsimlik_gl":109,"net_ticaret_gl":6,"kullanim_gl":110},"lmw_ceken":{"devreden_gl":28,"yeni_mevsimlik_gl":205,"net_ticaret_gl":268,"kullanim_gl":462},"ara_toplam":{"devreden_gl":379,"yeni_mevsimlik_gl":1298,"net_ticaret_gl":385,"kullanim_gl":1751},"yil_no":2018},{"yil":"2019-20","gmw_bolge":{"devreden_gl":192,"yeni_mevsimlik_gl":622,"net_ticaret_gl":71,"kullanim_gl":531},"gmw_ceken":{"devreden_gl":27,"yeni_mevsimlik_gl":83,"net_ticaret_gl":-13,"kullanim_gl":51},"lmw_bolge":{"devreden_gl":20,"yeni_mevsimlik_gl":70,"net_ticaret_gl":35,"kullanim_gl":98},"lmw_ceken":{"devreden_gl":42,"yeni_mevsimlik_gl":151,"net_ticaret_gl":304,"kullanim_gl":433},"ara_toplam":{"devreden_gl":281,"yeni_mevsimlik_gl":926,"net_ticaret_gl":398,"kullanim_gl":1112},"yil_no":2019},{"yil":"2020-21","gmw_bolge":{"devreden_gl":332,"yeni_mevsimlik_gl":819,"net_ticaret_gl":337,"kullanim_gl":942},"gmw_ceken":{"devreden_gl":36,"yeni_mevsimlik_gl":114,"net_ticaret_gl":-11,"kullanim_gl":69},"lmw_bolge":{"devreden_gl":25,"yeni_mevsimlik_gl":101,"net_ticaret_gl":14,"kullanim_gl":98},"lmw_ceken":{"devreden_gl":59,"yeni_mevsimlik_gl":225,"net_ticaret_gl":240,"kullanim_gl":436},"ara_toplam":{"devreden_gl":452,"yeni_mevsimlik_gl":1260,"net_ticaret_gl":580,"kullanim_gl":1545},"yil_no":2020},{"yil":"2021-22","gmw_bolge":{"devreden_gl":331,"yeni_mevsimlik_gl":1006,"net_ticaret_gl":281,"kullanim_gl":956},"gmw_ceken":{"devreden_gl":31,"yeni_mevsimlik_gl":121,"net_ticaret_gl":-2,"kullanim_gl":65},"lmw_bolge":{"devreden_gl":0,"yeni_mevsimlik_gl":99,"net_ticaret_gl":19,"kullanim_gl":93},"lmw_ceken":{"devreden_gl":7,"yeni_mevsimlik_gl":239,"net_ticaret_gl":254,"kullanim_gl":449},"ara_toplam":{"devreden_gl":369,"yeni_mevsimlik_gl":1465,"net_ticaret_gl":553,"kullanim_gl":1564},"yil_no":2021},{"yil":"2022-23","gmw_bolge":{"devreden_gl":-7,"yeni_mevsimlik_gl":1259,"net_ticaret_gl":315,"kullanim_gl":816},"gmw_ceken":{"devreden_gl":7,"yeni_mevsimlik_gl":124,"net_ticaret_gl":5,"kullanim_gl":53},"lmw_bolge":{"devreden_gl":0,"yeni_mevsimlik_gl":91,"net_ticaret_gl":22,"kullanim_gl":75},"lmw_ceken":{"devreden_gl":3,"yeni_mevsimlik_gl":247,"net_ticaret_gl":147,"kullanim_gl":329},"ara_toplam":{"devreden_gl":4,"yeni_mevsimlik_gl":1721,"net_ticaret_gl":489,"kullanim_gl":1272},"yil_no":2022},{"yil":"2023-24","gmw_bolge":{"devreden_gl":405,"yeni_mevsimlik_gl":1182,"net_ticaret_gl":297,"kullanim_gl":1130},"gmw_ceken":{"devreden_gl":35,"yeni_mevsimlik_gl":130,"net_ticaret_gl":-3,"kullanim_gl":73},"lmw_bolge":{"devreden_gl":7,"yeni_mevsimlik_gl":91,"net_ticaret_gl":32,"kullanim_gl":94},"lmw_ceken":{"devreden_gl":20,"yeni_mevsimlik_gl":237,"net_ticaret_gl":240,"kullanim_gl":418},"ara_toplam":{"devreden_gl":467,"yeni_mevsimlik_gl":1640,"net_ticaret_gl":566,"kullanim_gl":1716},"yil_no":2023}]},"darlik_fiyati":{"_kaynak_niteligi":"SİCİLİN BEYANI — Victoria Su Sicili, eğilim raporu","_kapsam":"kuzey Victoria, Murray 7. bölge (Barmah'ın aşağısı)","bolge":"Murray zone 7 — Barmah'ın aşağısı","dusuk_guvenilir_2018_07_aud_ml":444,"dusuk_guvenilir_2024_06_aud_ml":1861,"artis_kati":4.19,"alinti":"low-reliability water share prices increased from $444 per ML in July 2018 to $1,861 per ML in June 2024","neden_alintisi":"increasing allocation trade restrictions into the region","talep_alintisi":"growth in perennial horticulture demand downstream of Barmah","_not":"Rapor nedeni İKİ etkene bağlıyor: bahçe talebinin yüksek ödeme isteği VE bölgeye tahsis ticareti kısıtlarının artması. Tek nedene indirgenmeyecek."},"ticarete_bagimlilik":{"_kaynak_niteligi":"SİCİLİN BEYANI — Victoria Su Sicili, eğilim raporu","_kapsam":"kuzey Victoria","yil":"2023-24","alinti":"LMW diverters are the private water user group most dependent on trade","lmw_ceken_kendi_kaynagi_yuzde":61,"lmw_ceken_yeni_mevsimlik_gl":237,"lmw_ceken_devreden_gl":20,"gmw_bolge_yuzde":140,"gmw_ceken_yuzde":223,"lmw_bolge_yuzde":103,"oran_alintisi":"accounted for only 61% of LMW diverters"},"ticaret_gerekcesi":{"_kaynak_niteligi":"SİCİLİN BEYANI — Victoria Su Sicili, eğilim raporu","_kapsam":"kuzey Victoria","baslangic_yili":"2020-21","baslangic_alintisi":"2020-21 was the year collection for","kategori_alintisi":"standard commercial trade, related party trade, carryover parking, carryover parking return, private lease arrangement, allocation trade as part of a water share transfer, forward contract","kategori_sayisi":8,"_not":"Sekizinci kategori 'other'. Listede 'forward contract' ve 'private lease arrangement' var — vadeli sözleşme ve özel kira."},"kura":{"_kaynak_niteligi":"BİRİNCİL (ACCC beyanı) + SİCİLİN BEYANI (açılış raporu)","_kapsam":"Victoria ve NSW başvuruları, 2 Temmuz 2026 açılışı","_uyari":"İKİ AYRI AÇILIŞ. Barmah'ta darlık var, Goulburn→Murray'de yok. Rakamları karıştırmak kolay; ilk özette karıştırılmıştı.","basvuru_gunu":"2026-07-02","cekilis_gunu":"2026-07-03","bogaz_akis_siniri_ml_gun":7000,"bogaz_alintisi":"restricts the river flow to just around 7,000 ML per day","kura_alintisi":"eligible applications were randomised to determine the order in which they would be processed","gozlem_alintisi":"independently observed by the Australian Competition and Consumer Commission","gecici_cozum":"The randomisation approach has been implemented as an interim solution","accc":{"_kaynak_niteligi":"BİRİNCİL — ACCC'nin imzalı yazısı, 3 Ağustos 2026","imza":"Acting General Manager","kayit_incelemesi":"reviewed a recording of that process","duzenleme_yok":"did not observe any editing or changes to the output of the randomisation tool"},"barmah":{"_darlik":true,"kapasite_ml":24121.3,"kapasite_alintisi":"The total Barmah trade opportunity made available at 7:00 am 2 July was 24,121.3 ML","uygun_basvuru_toplam":214,"uygun_hacim_toplam_ml":67445.2,"talep_alintisi":"significantly exceeded the available trade oppor tunity","vic":{"alinan":138,"alinan_hacim_ml":31477.8,"uygun":136,"uygun_hacim_ml":31253.1,"onaylanan":33,"onaylanan_hacim_ml":8884.2,"reddedilen":103,"reddedilen_hacim_ml":22386.9},"nsw":{"uygun":78,"uygun_hacim_ml":36192.1,"onaylanan":29,"onaylanan_hacim_ml":15218.2},"vic_en_kucuk_ml":20.4,"vic_en_buyuk_ml":2484.4,"vic_ortanca_ml":110,"vic_ortalama_ml":230,"aracidan_basvuru":73,"aracidan_hacim_ml":17645.5,"cevrimici_basvuru":65,"cevrimici_hacim_ml":13832.3,"kanal_alintisi":"73 applications were received via the Broker Portal","ortanca_alintisi":"The median volume of Victorian applications was 110 ML","toplam_onaylanan":62,"onay_orani_yuzde":29,"vic_onay_orani_yuzde":24.3,"asim_kati":2.8},"goulburn_murray":{"_darlik":false,"_kapsam_notu":"Bu açılışın rakamları EYALET AYRIMI OLMADAN, iki eyaletin toplamı olarak yayımlanmış. Barmah rakamları ise eyalet eyalet. Karşılaştırma TOPLAMLAR üzerinden; Victoria'ya özel oranla yan yana konmaz.","kapasite_ml":112827.9,"kapasite_alintisi":"The total Goulburn-to-Murray trade opportunity made available at 7:00 am 2 July 2026 was 112,827.9 ML","alinan":290,"alinan_hacim_ml":120869.9,"uygun":286,"uygun_hacim_ml":119285.3,"onaylanan":282,"onaylanan_hacim_ml":112555.3,"reddedilen":4,"reddedilen_hacim_ml":6730,"onay_orani_yuzde":98.6,"asim_kati":1.07},"talep_kapasite_kati":2.8},"kuraklik":{"_kaynak_niteligi":"BAĞIMSIZ — Meteoroloji Bürosu","_kapsam":"Avustralya geneli; bildiriler BÖLGE bölge yazılmış","bildiri_sayisi":192,"ilk":"2000-01-10","son":"2016-08-04","bildirisiz_dizi_ay":8,"bildirisiz_dizi":"Ekim 2011 – Mayıs 2012","ilan_yok":"the Bureau does not declare a drought","ilan_yok_devam":"The Australian Government does not make drought declarations","eyalet_yetkisi":"State and territory governments administer and coordinate drought policies","tanim":"a prolonged, abnormally dry period when there's not enough water available for normal use","_bolge_uyarisi":"2011'de yayımlanan bildiriler güneybatı Batı Avustralya'yı anlatıyor, Murray-Darling'i değil. Doğudaki kuraklık o sırada kırılmıştı. 'Avustralya'nın kuraklığı' denmeyecek.","_zamanlama_uyarisi":"Bildirisiz dizi su yılı 2011-12'ye düşüyor (kullanım oranı %118). En düşük oran (%41) 2010-11'de. 'Büro susunca kullanım düştü' nedenselliği KURULAMAZ."},"ulusal":{"_kaynak_niteligi":"BAĞIMSIZ — Meteoroloji Bürosu, Water in Australia 2019–20","_kapsam":"Avustralya geneli","_zaman_farki":"Bu blok 2019-20'ye ait. Piyasa serileri 2023-24'e kadar geliyor. DÖRT YILLIK FARK; aynı cümlede aynı yılmış gibi sunulmayacak. Raporun 2020-21 ve sonrası sürümleri yayımda değil.","yil":"2019-20","tuketim_toplam_gl":14270,"tuketim_alintisi":"Total water taken in Australia for consumptive use was 14 270 GL","vic_nsw_payi":"Agricultural water-use in Victoria and New South Wales accounted for half of Australia","nsw_tarim_gl":2490,"depo_doluluk_gl":23140,"depo_doluluk_yuzde":46,"depo_kapasite_gl":50500,"piyasa_cirosu":"1–7 milyar AUD/yıl (BoM tahmini)","_ciro_uyarisi":"Aralık çok geniş; 'tahmini' ibaresi düşürülmeyecek."},"kronoloji":{"_kaynak_niteligi":"TÜRETİLMİŞ — yukarıdaki bloklardaki tarihlerin sayısal izdüşümü; yeni olgu içermez","_kapsam":"Victoria","kanun_yili":1989,"dayanak_tasdik_yili":2005,"yururluk_yili":2006,"ayrisma_yili":2007,"tavan_kaldirma_yili":2009,"cikis_tavani_kaldirma_yili":2014,"birliktelik_kaldirma_yili":2023,"kura_yili":2026,"ulusal_olcum_yili":2019}}$dsr$::jsonb,
  $dsr${"su_kimde":{"tur":"yigin","baslik":{"tr":"Kuzey Victoria'da yüksek güvenilirlikli su hakkı kimin elinde","en":"Who holds the high-reliability water entitlement in northern Victoria"},"not":{"tr":"Dört ayrı 30 Haziran. 2000-01'de suyun tamamı toprağa bağlıydı; 2023-24'te yarısı. Çevre, hiç yokken en büyük tarım dışı hak sahibi oldu. Kuzey Victoria — Avustralya geneli değil.","en":"Four separate 30 Junes. In 2000-01 all the water was linked to land; by 2023-24, half of it. The environment went from holding none to being the largest non-farm holder. Northern Victoria — not Australia as a whole."},"kaynak":"Victorian Water Register — Water Market Trends 2001–2024, Tablo 2","cubuklar":[{"etiket":{"tr":"2000-01","en":"2000-01"},"dilimler":[{"ad":{"tr":"Özel — toprağa bağlı","en":"Private — linked to land"},"deger":2283,"rol":"vurgu"},{"ad":{"tr":"Özel — toprağa bağlı değil","en":"Private — not linked to land"},"deger":0,"rol":"ikincil"},{"ad":{"tr":"Çevre","en":"Environment"},"deger":0,"rol":"sessiz"},{"ad":{"tr":"Su kurumu","en":"Water corporation"},"deger":0,"rol":"sessiz"}]},{"etiket":{"tr":"2008-09","en":"2008-09"},"dilimler":[{"ad":{"tr":"Özel — toprağa bağlı","en":"Private — linked to land"},"deger":2163,"rol":"vurgu"},{"ad":{"tr":"Özel — toprağa bağlı değil","en":"Private — not linked to land"},"deger":125,"rol":"ikincil"},{"ad":{"tr":"Çevre","en":"Environment"},"deger":0,"rol":"sessiz"},{"ad":{"tr":"Su kurumu","en":"Water corporation"},"deger":0,"rol":"sessiz"}]},{"etiket":{"tr":"2015-16","en":"2015-16"},"dilimler":[{"ad":{"tr":"Özel — toprağa bağlı","en":"Private — linked to land"},"deger":1473,"rol":"vurgu"},{"ad":{"tr":"Özel — toprağa bağlı değil","en":"Private — not linked to land"},"deger":197,"rol":"ikincil"},{"ad":{"tr":"Çevre","en":"Environment"},"deger":648,"rol":"sessiz"},{"ad":{"tr":"Su kurumu","en":"Water corporation"},"deger":62,"rol":"sessiz"}]},{"etiket":{"tr":"2023-24","en":"2023-24"},"dilimler":[{"ad":{"tr":"Özel — toprağa bağlı","en":"Private — linked to land"},"deger":1262,"rol":"vurgu"},{"ad":{"tr":"Özel — toprağa bağlı değil","en":"Private — not linked to land"},"deger":456,"rol":"ikincil"},{"ad":{"tr":"Çevre","en":"Environment"},"deger":747,"rol":"sessiz"},{"ad":{"tr":"Su kurumu","en":"Water corporation"},"deger":50,"rol":"sessiz"}]}]},"topraktan_ayrilma":{"tur":"cizgi","baslik":{"tr":"Suyun topraktan ayrılması, yirmi üç yılda","en":"Water's separation from land, over twenty-three years"},"birim":{"tr":"yüksek güvenilirlikli hakkın yüzdesi","en":"per cent of high-reliability entitlement"},"ondalik":1,"sonek":{"tr":"%","en":"%"},"not":{"tr":"Kanun 2006'da ayrışmaya izin verdi, ayrışma 1 Temmuz 2007'de uygulandı. Toprağa bağlı olmayan payın tavanı başta %10'du; 2009'da kaldırıldı. Yüzdeler hacimlerden hesaplandı: kaynağın 2008-09 satırında yazılı yüzdeler kendi hacimleriyle çelişiyor, diğer on yedi satırda çelişmiyor. Kuzey Victoria.","en":"The law permitted separation in 2006; separation was implemented on 1 July 2007. Holdings not linked to land were initially capped at 10 per cent; the cap was abolished in 2009. The percentages are computed from the volumes: in the source's 2008-09 row the printed percentages contradict its own volumes, which they do not in the other seventeen rows. Northern Victoria."},"kaynak":"Victorian Water Register — Water Market Trends 2001–2024, Tablo 2","seriler":[{"ad":{"tr":"Toprağa bağlı","en":"Linked to land"},"rol":"vurgu","noktalar":{"liste":[{"yil":"2000-01","cevre_gl":0,"su_kurumu_gl":0,"ozel_topraga_bagli_degil_gl":0,"ozel_topraga_bagli_gl":2283,"toplam_gl":2283,"topraga_bagli_pay_yuzde":100,"topraga_bagli_degil_pay_yuzde":0,"cevre_pay_yuzde":0,"yil_no":2000},{"yil":"2004-05","cevre_gl":0,"su_kurumu_gl":0,"ozel_topraga_bagli_degil_gl":0,"ozel_topraga_bagli_gl":2251,"toplam_gl":2251,"topraga_bagli_pay_yuzde":100,"topraga_bagli_degil_pay_yuzde":0,"cevre_pay_yuzde":0,"yil_no":2004},{"yil":"2008-09","cevre_gl":0,"su_kurumu_gl":0,"ozel_topraga_bagli_degil_gl":125,"ozel_topraga_bagli_gl":2163,"toplam_gl":2288,"topraga_bagli_pay_yuzde":94.5,"topraga_bagli_degil_pay_yuzde":5.5,"cevre_pay_yuzde":0,"yil_no":2008},{"yil":"2009-10","cevre_gl":160,"su_kurumu_gl":46,"ozel_topraga_bagli_degil_gl":128,"ozel_topraga_bagli_gl":1947,"toplam_gl":2280,"topraga_bagli_pay_yuzde":85.4,"topraga_bagli_degil_pay_yuzde":5.6,"cevre_pay_yuzde":7,"yil_no":2009},{"yil":"2010-11","cevre_gl":283,"su_kurumu_gl":64,"ozel_topraga_bagli_degil_gl":120,"ozel_topraga_bagli_gl":1813,"toplam_gl":2279,"topraga_bagli_pay_yuzde":79.6,"topraga_bagli_degil_pay_yuzde":5.3,"cevre_pay_yuzde":12.4,"yil_no":2010},{"yil":"2011-12","cevre_gl":463,"su_kurumu_gl":67,"ozel_topraga_bagli_degil_gl":117,"ozel_topraga_bagli_gl":1635,"toplam_gl":2281,"topraga_bagli_pay_yuzde":71.7,"topraga_bagli_degil_pay_yuzde":5.1,"cevre_pay_yuzde":20.3,"yil_no":2011},{"yil":"2012-13","cevre_gl":499,"su_kurumu_gl":74,"ozel_topraga_bagli_degil_gl":142,"ozel_topraga_bagli_gl":1569,"toplam_gl":2285,"topraga_bagli_pay_yuzde":68.7,"topraga_bagli_degil_pay_yuzde":6.2,"cevre_pay_yuzde":21.8,"yil_no":2012},{"yil":"2013-14","cevre_gl":539,"su_kurumu_gl":59,"ozel_topraga_bagli_degil_gl":146,"ozel_topraga_bagli_gl":1552,"toplam_gl":2295,"topraga_bagli_pay_yuzde":67.6,"topraga_bagli_degil_pay_yuzde":6.4,"cevre_pay_yuzde":23.5,"yil_no":2013},{"yil":"2014-15","cevre_gl":605,"su_kurumu_gl":62,"ozel_topraga_bagli_degil_gl":156,"ozel_topraga_bagli_gl":1516,"toplam_gl":2338,"topraga_bagli_pay_yuzde":64.8,"topraga_bagli_degil_pay_yuzde":6.7,"cevre_pay_yuzde":25.9,"yil_no":2014},{"yil":"2015-16","cevre_gl":648,"su_kurumu_gl":62,"ozel_topraga_bagli_degil_gl":197,"ozel_topraga_bagli_gl":1473,"toplam_gl":2380,"topraga_bagli_pay_yuzde":61.9,"topraga_bagli_degil_pay_yuzde":8.3,"cevre_pay_yuzde":27.2,"yil_no":2015},{"yil":"2016-17","cevre_gl":652,"su_kurumu_gl":63,"ozel_topraga_bagli_degil_gl":237,"ozel_topraga_bagli_gl":1428,"toplam_gl":2380,"topraga_bagli_pay_yuzde":60,"topraga_bagli_degil_pay_yuzde":10,"cevre_pay_yuzde":27.4,"yil_no":2016},{"yil":"2017-18","cevre_gl":661,"su_kurumu_gl":63,"ozel_topraga_bagli_degil_gl":272,"ozel_topraga_bagli_gl":1390,"toplam_gl":2386,"topraga_bagli_pay_yuzde":58.3,"topraga_bagli_degil_pay_yuzde":11.4,"cevre_pay_yuzde":27.7,"yil_no":2017},{"yil":"2018-19","cevre_gl":732,"su_kurumu_gl":61,"ozel_topraga_bagli_degil_gl":307,"ozel_topraga_bagli_gl":1355,"toplam_gl":2455,"topraga_bagli_pay_yuzde":55.2,"topraga_bagli_degil_pay_yuzde":12.5,"cevre_pay_yuzde":29.8,"yil_no":2018},{"yil":"2019-20","cevre_gl":732,"su_kurumu_gl":62,"ozel_topraga_bagli_degil_gl":330,"ozel_topraga_bagli_gl":1331,"toplam_gl":2455,"topraga_bagli_pay_yuzde":54.2,"topraga_bagli_degil_pay_yuzde":13.4,"cevre_pay_yuzde":29.8,"yil_no":2019},{"yil":"2020-21","cevre_gl":733,"su_kurumu_gl":62,"ozel_topraga_bagli_degil_gl":344,"ozel_topraga_bagli_gl":1317,"toplam_gl":2456,"topraga_bagli_pay_yuzde":53.6,"topraga_bagli_degil_pay_yuzde":14,"cevre_pay_yuzde":29.8,"yil_no":2020},{"yil":"2021-22","cevre_gl":733,"su_kurumu_gl":48,"ozel_topraga_bagli_degil_gl":397,"ozel_topraga_bagli_gl":1322,"toplam_gl":2500,"topraga_bagli_pay_yuzde":52.9,"topraga_bagli_degil_pay_yuzde":15.9,"cevre_pay_yuzde":29.3,"yil_no":2021},{"yil":"2022-23","cevre_gl":739,"su_kurumu_gl":48,"ozel_topraga_bagli_degil_gl":435,"ozel_topraga_bagli_gl":1285,"toplam_gl":2507,"topraga_bagli_pay_yuzde":51.3,"topraga_bagli_degil_pay_yuzde":17.4,"cevre_pay_yuzde":29.5,"yil_no":2022},{"yil":"2023-24","cevre_gl":747,"su_kurumu_gl":50,"ozel_topraga_bagli_degil_gl":456,"ozel_topraga_bagli_gl":1262,"toplam_gl":2515,"topraga_bagli_pay_yuzde":50.2,"topraga_bagli_degil_pay_yuzde":18.1,"cevre_pay_yuzde":29.7,"yil_no":2023}],"x":"yil_no","y":"topraga_bagli_pay_yuzde"}},{"ad":{"tr":"Çevrenin elinde","en":"Held by the environment"},"rol":"ikincil","noktalar":{"liste":[{"yil":"2000-01","cevre_gl":0,"su_kurumu_gl":0,"ozel_topraga_bagli_degil_gl":0,"ozel_topraga_bagli_gl":2283,"toplam_gl":2283,"topraga_bagli_pay_yuzde":100,"topraga_bagli_degil_pay_yuzde":0,"cevre_pay_yuzde":0,"yil_no":2000},{"yil":"2004-05","cevre_gl":0,"su_kurumu_gl":0,"ozel_topraga_bagli_degil_gl":0,"ozel_topraga_bagli_gl":2251,"toplam_gl":2251,"topraga_bagli_pay_yuzde":100,"topraga_bagli_degil_pay_yuzde":0,"cevre_pay_yuzde":0,"yil_no":2004},{"yil":"2008-09","cevre_gl":0,"su_kurumu_gl":0,"ozel_topraga_bagli_degil_gl":125,"ozel_topraga_bagli_gl":2163,"toplam_gl":2288,"topraga_bagli_pay_yuzde":94.5,"topraga_bagli_degil_pay_yuzde":5.5,"cevre_pay_yuzde":0,"yil_no":2008},{"yil":"2009-10","cevre_gl":160,"su_kurumu_gl":46,"ozel_topraga_bagli_degil_gl":128,"ozel_topraga_bagli_gl":1947,"toplam_gl":2280,"topraga_bagli_pay_yuzde":85.4,"topraga_bagli_degil_pay_yuzde":5.6,"cevre_pay_yuzde":7,"yil_no":2009},{"yil":"2010-11","cevre_gl":283,"su_kurumu_gl":64,"ozel_topraga_bagli_degil_gl":120,"ozel_topraga_bagli_gl":1813,"toplam_gl":2279,"topraga_bagli_pay_yuzde":79.6,"topraga_bagli_degil_pay_yuzde":5.3,"cevre_pay_yuzde":12.4,"yil_no":2010},{"yil":"2011-12","cevre_gl":463,"su_kurumu_gl":67,"ozel_topraga_bagli_degil_gl":117,"ozel_topraga_bagli_gl":1635,"toplam_gl":2281,"topraga_bagli_pay_yuzde":71.7,"topraga_bagli_degil_pay_yuzde":5.1,"cevre_pay_yuzde":20.3,"yil_no":2011},{"yil":"2012-13","cevre_gl":499,"su_kurumu_gl":74,"ozel_topraga_bagli_degil_gl":142,"ozel_topraga_bagli_gl":1569,"toplam_gl":2285,"topraga_bagli_pay_yuzde":68.7,"topraga_bagli_degil_pay_yuzde":6.2,"cevre_pay_yuzde":21.8,"yil_no":2012},{"yil":"2013-14","cevre_gl":539,"su_kurumu_gl":59,"ozel_topraga_bagli_degil_gl":146,"ozel_topraga_bagli_gl":1552,"toplam_gl":2295,"topraga_bagli_pay_yuzde":67.6,"topraga_bagli_degil_pay_yuzde":6.4,"cevre_pay_yuzde":23.5,"yil_no":2013},{"yil":"2014-15","cevre_gl":605,"su_kurumu_gl":62,"ozel_topraga_bagli_degil_gl":156,"ozel_topraga_bagli_gl":1516,"toplam_gl":2338,"topraga_bagli_pay_yuzde":64.8,"topraga_bagli_degil_pay_yuzde":6.7,"cevre_pay_yuzde":25.9,"yil_no":2014},{"yil":"2015-16","cevre_gl":648,"su_kurumu_gl":62,"ozel_topraga_bagli_degil_gl":197,"ozel_topraga_bagli_gl":1473,"toplam_gl":2380,"topraga_bagli_pay_yuzde":61.9,"topraga_bagli_degil_pay_yuzde":8.3,"cevre_pay_yuzde":27.2,"yil_no":2015},{"yil":"2016-17","cevre_gl":652,"su_kurumu_gl":63,"ozel_topraga_bagli_degil_gl":237,"ozel_topraga_bagli_gl":1428,"toplam_gl":2380,"topraga_bagli_pay_yuzde":60,"topraga_bagli_degil_pay_yuzde":10,"cevre_pay_yuzde":27.4,"yil_no":2016},{"yil":"2017-18","cevre_gl":661,"su_kurumu_gl":63,"ozel_topraga_bagli_degil_gl":272,"ozel_topraga_bagli_gl":1390,"toplam_gl":2386,"topraga_bagli_pay_yuzde":58.3,"topraga_bagli_degil_pay_yuzde":11.4,"cevre_pay_yuzde":27.7,"yil_no":2017},{"yil":"2018-19","cevre_gl":732,"su_kurumu_gl":61,"ozel_topraga_bagli_degil_gl":307,"ozel_topraga_bagli_gl":1355,"toplam_gl":2455,"topraga_bagli_pay_yuzde":55.2,"topraga_bagli_degil_pay_yuzde":12.5,"cevre_pay_yuzde":29.8,"yil_no":2018},{"yil":"2019-20","cevre_gl":732,"su_kurumu_gl":62,"ozel_topraga_bagli_degil_gl":330,"ozel_topraga_bagli_gl":1331,"toplam_gl":2455,"topraga_bagli_pay_yuzde":54.2,"topraga_bagli_degil_pay_yuzde":13.4,"cevre_pay_yuzde":29.8,"yil_no":2019},{"yil":"2020-21","cevre_gl":733,"su_kurumu_gl":62,"ozel_topraga_bagli_degil_gl":344,"ozel_topraga_bagli_gl":1317,"toplam_gl":2456,"topraga_bagli_pay_yuzde":53.6,"topraga_bagli_degil_pay_yuzde":14,"cevre_pay_yuzde":29.8,"yil_no":2020},{"yil":"2021-22","cevre_gl":733,"su_kurumu_gl":48,"ozel_topraga_bagli_degil_gl":397,"ozel_topraga_bagli_gl":1322,"toplam_gl":2500,"topraga_bagli_pay_yuzde":52.9,"topraga_bagli_degil_pay_yuzde":15.9,"cevre_pay_yuzde":29.3,"yil_no":2021},{"yil":"2022-23","cevre_gl":739,"su_kurumu_gl":48,"ozel_topraga_bagli_degil_gl":435,"ozel_topraga_bagli_gl":1285,"toplam_gl":2507,"topraga_bagli_pay_yuzde":51.3,"topraga_bagli_degil_pay_yuzde":17.4,"cevre_pay_yuzde":29.5,"yil_no":2022},{"yil":"2023-24","cevre_gl":747,"su_kurumu_gl":50,"ozel_topraga_bagli_degil_gl":456,"ozel_topraga_bagli_gl":1262,"toplam_gl":2515,"topraga_bagli_pay_yuzde":50.2,"topraga_bagli_degil_pay_yuzde":18.1,"cevre_pay_yuzde":29.7,"yil_no":2023}],"x":"yil_no","y":"cevre_pay_yuzde"}},{"ad":{"tr":"Özel ama toprağa bağlı değil","en":"Private but not linked to land"},"rol":"sessiz","noktalar":{"liste":[{"yil":"2000-01","cevre_gl":0,"su_kurumu_gl":0,"ozel_topraga_bagli_degil_gl":0,"ozel_topraga_bagli_gl":2283,"toplam_gl":2283,"topraga_bagli_pay_yuzde":100,"topraga_bagli_degil_pay_yuzde":0,"cevre_pay_yuzde":0,"yil_no":2000},{"yil":"2004-05","cevre_gl":0,"su_kurumu_gl":0,"ozel_topraga_bagli_degil_gl":0,"ozel_topraga_bagli_gl":2251,"toplam_gl":2251,"topraga_bagli_pay_yuzde":100,"topraga_bagli_degil_pay_yuzde":0,"cevre_pay_yuzde":0,"yil_no":2004},{"yil":"2008-09","cevre_gl":0,"su_kurumu_gl":0,"ozel_topraga_bagli_degil_gl":125,"ozel_topraga_bagli_gl":2163,"toplam_gl":2288,"topraga_bagli_pay_yuzde":94.5,"topraga_bagli_degil_pay_yuzde":5.5,"cevre_pay_yuzde":0,"yil_no":2008},{"yil":"2009-10","cevre_gl":160,"su_kurumu_gl":46,"ozel_topraga_bagli_degil_gl":128,"ozel_topraga_bagli_gl":1947,"toplam_gl":2280,"topraga_bagli_pay_yuzde":85.4,"topraga_bagli_degil_pay_yuzde":5.6,"cevre_pay_yuzde":7,"yil_no":2009},{"yil":"2010-11","cevre_gl":283,"su_kurumu_gl":64,"ozel_topraga_bagli_degil_gl":120,"ozel_topraga_bagli_gl":1813,"toplam_gl":2279,"topraga_bagli_pay_yuzde":79.6,"topraga_bagli_degil_pay_yuzde":5.3,"cevre_pay_yuzde":12.4,"yil_no":2010},{"yil":"2011-12","cevre_gl":463,"su_kurumu_gl":67,"ozel_topraga_bagli_degil_gl":117,"ozel_topraga_bagli_gl":1635,"toplam_gl":2281,"topraga_bagli_pay_yuzde":71.7,"topraga_bagli_degil_pay_yuzde":5.1,"cevre_pay_yuzde":20.3,"yil_no":2011},{"yil":"2012-13","cevre_gl":499,"su_kurumu_gl":74,"ozel_topraga_bagli_degil_gl":142,"ozel_topraga_bagli_gl":1569,"toplam_gl":2285,"topraga_bagli_pay_yuzde":68.7,"topraga_bagli_degil_pay_yuzde":6.2,"cevre_pay_yuzde":21.8,"yil_no":2012},{"yil":"2013-14","cevre_gl":539,"su_kurumu_gl":59,"ozel_topraga_bagli_degil_gl":146,"ozel_topraga_bagli_gl":1552,"toplam_gl":2295,"topraga_bagli_pay_yuzde":67.6,"topraga_bagli_degil_pay_yuzde":6.4,"cevre_pay_yuzde":23.5,"yil_no":2013},{"yil":"2014-15","cevre_gl":605,"su_kurumu_gl":62,"ozel_topraga_bagli_degil_gl":156,"ozel_topraga_bagli_gl":1516,"toplam_gl":2338,"topraga_bagli_pay_yuzde":64.8,"topraga_bagli_degil_pay_yuzde":6.7,"cevre_pay_yuzde":25.9,"yil_no":2014},{"yil":"2015-16","cevre_gl":648,"su_kurumu_gl":62,"ozel_topraga_bagli_degil_gl":197,"ozel_topraga_bagli_gl":1473,"toplam_gl":2380,"topraga_bagli_pay_yuzde":61.9,"topraga_bagli_degil_pay_yuzde":8.3,"cevre_pay_yuzde":27.2,"yil_no":2015},{"yil":"2016-17","cevre_gl":652,"su_kurumu_gl":63,"ozel_topraga_bagli_degil_gl":237,"ozel_topraga_bagli_gl":1428,"toplam_gl":2380,"topraga_bagli_pay_yuzde":60,"topraga_bagli_degil_pay_yuzde":10,"cevre_pay_yuzde":27.4,"yil_no":2016},{"yil":"2017-18","cevre_gl":661,"su_kurumu_gl":63,"ozel_topraga_bagli_degil_gl":272,"ozel_topraga_bagli_gl":1390,"toplam_gl":2386,"topraga_bagli_pay_yuzde":58.3,"topraga_bagli_degil_pay_yuzde":11.4,"cevre_pay_yuzde":27.7,"yil_no":2017},{"yil":"2018-19","cevre_gl":732,"su_kurumu_gl":61,"ozel_topraga_bagli_degil_gl":307,"ozel_topraga_bagli_gl":1355,"toplam_gl":2455,"topraga_bagli_pay_yuzde":55.2,"topraga_bagli_degil_pay_yuzde":12.5,"cevre_pay_yuzde":29.8,"yil_no":2018},{"yil":"2019-20","cevre_gl":732,"su_kurumu_gl":62,"ozel_topraga_bagli_degil_gl":330,"ozel_topraga_bagli_gl":1331,"toplam_gl":2455,"topraga_bagli_pay_yuzde":54.2,"topraga_bagli_degil_pay_yuzde":13.4,"cevre_pay_yuzde":29.8,"yil_no":2019},{"yil":"2020-21","cevre_gl":733,"su_kurumu_gl":62,"ozel_topraga_bagli_degil_gl":344,"ozel_topraga_bagli_gl":1317,"toplam_gl":2456,"topraga_bagli_pay_yuzde":53.6,"topraga_bagli_degil_pay_yuzde":14,"cevre_pay_yuzde":29.8,"yil_no":2020},{"yil":"2021-22","cevre_gl":733,"su_kurumu_gl":48,"ozel_topraga_bagli_degil_gl":397,"ozel_topraga_bagli_gl":1322,"toplam_gl":2500,"topraga_bagli_pay_yuzde":52.9,"topraga_bagli_degil_pay_yuzde":15.9,"cevre_pay_yuzde":29.3,"yil_no":2021},{"yil":"2022-23","cevre_gl":739,"su_kurumu_gl":48,"ozel_topraga_bagli_degil_gl":435,"ozel_topraga_bagli_gl":1285,"toplam_gl":2507,"topraga_bagli_pay_yuzde":51.3,"topraga_bagli_degil_pay_yuzde":17.4,"cevre_pay_yuzde":29.5,"yil_no":2022},{"yil":"2023-24","cevre_gl":747,"su_kurumu_gl":50,"ozel_topraga_bagli_degil_gl":456,"ozel_topraga_bagli_gl":1262,"toplam_gl":2515,"topraga_bagli_pay_yuzde":50.2,"topraga_bagli_degil_pay_yuzde":18.1,"cevre_pay_yuzde":29.7,"yil_no":2023}],"x":"yil_no","y":"topraga_bagli_degil_pay_yuzde"}}]},"kalici_hakkin_fiyati":{"tur":"cizgi","baslik":{"tr":"Kalıcı su hakkının megalitre fiyatı","en":"The price of a permanent water entitlement, per megalitre"},"birim":{"tr":"medyan devir fiyatı, AUD/ML","en":"median transfer price, AUD/ML"},"ondalik":0,"onek":{"tr":"$","en":"$"},"not":{"tr":"Medyan fiyat. Yüksek güvenilirlikli pay suyu önce alır; düşük güvenilirlikli pay ancak bol yıllarda su görür ve fiyatı bunu yansıtıyor. Medyan bölgeler arası ayrışmayı gizler — Barmah'ın aşağısındaki fark ayrı bir bölümde. Kuzey Victoria.","en":"Median price. A high-reliability share is served first; a low-reliability share receives water only in abundant years, and its price reflects that. A median conceals divergence between zones — the gap below Barmah has a section of its own. Northern Victoria."},"kaynak":"Victorian Water Register — Water Market Trends 2001–2024, Tablo 4 ve 5","seriler":[{"ad":{"tr":"Yüksek güvenilirlikli pay","en":"High-reliability share"},"rol":"vurgu","noktalar":{"liste":[{"yil":"2008-09","devlete_devir_gl":8,"diger_devir_gl":154,"medyan_fiyat_aud_ml":2175,"yil_no":2008},{"yil":"2009-10","devlete_devir_gl":127,"diger_devir_gl":210,"medyan_fiyat_aud_ml":2200,"yil_no":2009},{"yil":"2010-11","devlete_devir_gl":113,"diger_devir_gl":98,"medyan_fiyat_aud_ml":1940,"yil_no":2010},{"yil":"2011-12","devlete_devir_gl":174,"diger_devir_gl":93,"medyan_fiyat_aud_ml":1800,"yil_no":2011},{"yil":"2012-13","devlete_devir_gl":31,"diger_devir_gl":104,"medyan_fiyat_aud_ml":1500,"yil_no":2012},{"yil":"2013-14","devlete_devir_gl":10,"diger_devir_gl":93,"medyan_fiyat_aud_ml":1380,"yil_no":2013},{"yil":"2014-15","devlete_devir_gl":25,"diger_devir_gl":99,"medyan_fiyat_aud_ml":1500,"yil_no":2014},{"yil":"2015-16","devlete_devir_gl":1,"diger_devir_gl":124,"medyan_fiyat_aud_ml":2400,"yil_no":2015},{"yil":"2016-17","devlete_devir_gl":5,"diger_devir_gl":151,"medyan_fiyat_aud_ml":2600,"yil_no":2016},{"yil":"2017-18","devlete_devir_gl":3,"diger_devir_gl":66,"medyan_fiyat_aud_ml":2850,"yil_no":2017},{"yil":"2018-19","devlete_devir_gl":null,"diger_devir_gl":112,"medyan_fiyat_aud_ml":3700,"yil_no":2018},{"yil":"2019-20","devlete_devir_gl":0,"diger_devir_gl":156,"medyan_fiyat_aud_ml":4800,"yil_no":2019},{"yil":"2020-21","devlete_devir_gl":1,"diger_devir_gl":88,"medyan_fiyat_aud_ml":4500,"yil_no":2020},{"yil":"2021-22","devlete_devir_gl":null,"diger_devir_gl":112,"medyan_fiyat_aud_ml":4950,"yil_no":2021},{"yil":"2022-23","devlete_devir_gl":null,"diger_devir_gl":82,"medyan_fiyat_aud_ml":5000,"yil_no":2022},{"yil":"2023-24","devlete_devir_gl":null,"diger_devir_gl":60,"medyan_fiyat_aud_ml":4500,"yil_no":2023}],"x":"yil_no","y":"medyan_fiyat_aud_ml"}},{"ad":{"tr":"Düşük güvenilirlikli pay","en":"Low-reliability share"},"rol":"ikincil","noktalar":{"liste":[{"yil":"2008-09","devlete_devir_gl":1,"diger_devir_gl":74,"medyan_fiyat_aud_ml":200,"yil_no":2008},{"yil":"2009-10","devlete_devir_gl":20,"diger_devir_gl":35,"medyan_fiyat_aud_ml":175,"yil_no":2009},{"yil":"2010-11","devlete_devir_gl":1,"diger_devir_gl":53,"medyan_fiyat_aud_ml":150,"yil_no":2010},{"yil":"2011-12","devlete_devir_gl":0,"diger_devir_gl":64,"medyan_fiyat_aud_ml":140,"yil_no":2011},{"yil":"2012-13","devlete_devir_gl":null,"diger_devir_gl":47,"medyan_fiyat_aud_ml":150,"yil_no":2012},{"yil":"2013-14","devlete_devir_gl":0,"diger_devir_gl":32,"medyan_fiyat_aud_ml":185,"yil_no":2013},{"yil":"2014-15","devlete_devir_gl":null,"diger_devir_gl":40,"medyan_fiyat_aud_ml":225,"yil_no":2014},{"yil":"2015-16","devlete_devir_gl":null,"diger_devir_gl":35,"medyan_fiyat_aud_ml":244,"yil_no":2015},{"yil":"2016-17","devlete_devir_gl":null,"diger_devir_gl":61,"medyan_fiyat_aud_ml":250,"yil_no":2016},{"yil":"2017-18","devlete_devir_gl":null,"diger_devir_gl":26,"medyan_fiyat_aud_ml":340,"yil_no":2017},{"yil":"2018-19","devlete_devir_gl":null,"diger_devir_gl":55,"medyan_fiyat_aud_ml":500,"yil_no":2018},{"yil":"2019-20","devlete_devir_gl":null,"diger_devir_gl":36,"medyan_fiyat_aud_ml":500,"yil_no":2019},{"yil":"2020-21","devlete_devir_gl":null,"diger_devir_gl":37,"medyan_fiyat_aud_ml":470,"yil_no":2020},{"yil":"2021-22","devlete_devir_gl":null,"diger_devir_gl":44,"medyan_fiyat_aud_ml":650,"yil_no":2021},{"yil":"2022-23","devlete_devir_gl":null,"diger_devir_gl":44,"medyan_fiyat_aud_ml":895,"yil_no":2022},{"yil":"2023-24","devlete_devir_gl":null,"diger_devir_gl":30,"medyan_fiyat_aud_ml":850,"yil_no":2023}],"x":"yil_no","y":"medyan_fiyat_aud_ml"}}]},"hak_ve_kullanim":{"tur":"cizgi","baslik":{"tr":"Arazinin verdiği hak ile fiilen kullanılan su","en":"The entitlement the land provides, against the water actually used"},"birim":{"tr":"gigalitre","en":"gigalitres"},"ondalik":0,"not":{"tr":"İki çizginin kesiştiği yer, piyasanın işe karıştığı yerdir: kullanım, toprağa bağlı hakkın üstüne çıktığında fark ticaretle kapanıyor. Kuzey Victoria.","en":"Where the two lines cross is where the market enters: when use exceeds the land-linked entitlement, the difference is met by trade. Northern Victoria."},"kaynak":"Victorian Water Register — Water Market Trends 2001–2024, Tablo 6","seriler":[{"ad":{"tr":"Toprağa bağlı hak","en":"Entitlement linked to land"},"rol":"ikincil","noktalar":{"liste":[{"yil":"2004-05","topraga_bagli_gl":2252,"kullanim_gl":2151,"kullanim_oran_yuzde":96,"yil_no":2004},{"yil":"2008-09","topraga_bagli_gl":2163,"kullanim_gl":925,"kullanim_oran_yuzde":43,"yil_no":2008},{"yil":"2009-10","topraga_bagli_gl":1947,"kullanim_gl":1135,"kullanim_oran_yuzde":58,"yil_no":2009},{"yil":"2010-11","topraga_bagli_gl":1813,"kullanim_gl":751,"kullanim_oran_yuzde":41,"yil_no":2010},{"yil":"2011-12","topraga_bagli_gl":1635,"kullanim_gl":1732,"kullanim_oran_yuzde":106,"yil_no":2011},{"yil":"2012-13","topraga_bagli_gl":1569,"kullanim_gl":2402,"kullanim_oran_yuzde":153,"yil_no":2012},{"yil":"2013-14","topraga_bagli_gl":1552,"kullanim_gl":1857,"kullanim_oran_yuzde":120,"yil_no":2013},{"yil":"2014-15","topraga_bagli_gl":1516,"kullanim_gl":2033,"kullanim_oran_yuzde":134,"yil_no":2014},{"yil":"2015-16","topraga_bagli_gl":1473,"kullanim_gl":1762,"kullanim_oran_yuzde":120,"yil_no":2015},{"yil":"2016-17","topraga_bagli_gl":1428,"kullanim_gl":1454,"kullanim_oran_yuzde":102,"yil_no":2016},{"yil":"2017-18","topraga_bagli_gl":1390,"kullanim_gl":1967,"kullanim_oran_yuzde":142,"yil_no":2017},{"yil":"2018-19","topraga_bagli_gl":1355,"kullanim_gl":1752,"kullanim_oran_yuzde":129,"yil_no":2018},{"yil":"2019-20","topraga_bagli_gl":1331,"kullanim_gl":1113,"kullanim_oran_yuzde":84,"yil_no":2019},{"yil":"2020-21","topraga_bagli_gl":1317,"kullanim_gl":1545,"kullanim_oran_yuzde":117,"yil_no":2020},{"yil":"2021-22","topraga_bagli_gl":1322,"kullanim_gl":1564,"kullanim_oran_yuzde":118,"yil_no":2021},{"yil":"2022-23","topraga_bagli_gl":1285,"kullanim_gl":1273,"kullanim_oran_yuzde":99,"yil_no":2022},{"yil":"2023-24","topraga_bagli_gl":1262,"kullanim_gl":1716,"kullanim_oran_yuzde":136,"yil_no":2023}],"x":"yil_no","y":"topraga_bagli_gl"}},{"ad":{"tr":"Fiilî kullanım","en":"Actual use"},"rol":"vurgu","noktalar":{"liste":[{"yil":"2004-05","topraga_bagli_gl":2252,"kullanim_gl":2151,"kullanim_oran_yuzde":96,"yil_no":2004},{"yil":"2008-09","topraga_bagli_gl":2163,"kullanim_gl":925,"kullanim_oran_yuzde":43,"yil_no":2008},{"yil":"2009-10","topraga_bagli_gl":1947,"kullanim_gl":1135,"kullanim_oran_yuzde":58,"yil_no":2009},{"yil":"2010-11","topraga_bagli_gl":1813,"kullanim_gl":751,"kullanim_oran_yuzde":41,"yil_no":2010},{"yil":"2011-12","topraga_bagli_gl":1635,"kullanim_gl":1732,"kullanim_oran_yuzde":106,"yil_no":2011},{"yil":"2012-13","topraga_bagli_gl":1569,"kullanim_gl":2402,"kullanim_oran_yuzde":153,"yil_no":2012},{"yil":"2013-14","topraga_bagli_gl":1552,"kullanim_gl":1857,"kullanim_oran_yuzde":120,"yil_no":2013},{"yil":"2014-15","topraga_bagli_gl":1516,"kullanim_gl":2033,"kullanim_oran_yuzde":134,"yil_no":2014},{"yil":"2015-16","topraga_bagli_gl":1473,"kullanim_gl":1762,"kullanim_oran_yuzde":120,"yil_no":2015},{"yil":"2016-17","topraga_bagli_gl":1428,"kullanim_gl":1454,"kullanim_oran_yuzde":102,"yil_no":2016},{"yil":"2017-18","topraga_bagli_gl":1390,"kullanim_gl":1967,"kullanim_oran_yuzde":142,"yil_no":2017},{"yil":"2018-19","topraga_bagli_gl":1355,"kullanim_gl":1752,"kullanim_oran_yuzde":129,"yil_no":2018},{"yil":"2019-20","topraga_bagli_gl":1331,"kullanim_gl":1113,"kullanim_oran_yuzde":84,"yil_no":2019},{"yil":"2020-21","topraga_bagli_gl":1317,"kullanim_gl":1545,"kullanim_oran_yuzde":117,"yil_no":2020},{"yil":"2021-22","topraga_bagli_gl":1322,"kullanim_gl":1564,"kullanim_oran_yuzde":118,"yil_no":2021},{"yil":"2022-23","topraga_bagli_gl":1285,"kullanim_gl":1273,"kullanim_oran_yuzde":99,"yil_no":2022},{"yil":"2023-24","topraga_bagli_gl":1262,"kullanim_gl":1716,"kullanim_oran_yuzde":136,"yil_no":2023}],"x":"yil_no","y":"kullanim_gl"}}]},"topraksiz_suyun_akibeti":{"tur":"cizgi","baslik":{"tr":"Toprağa bağlı olmayan suyun tahsisi ne oluyor","en":"What becomes of the allocation on water not linked to land"},"birim":{"tr":"gigalitre","en":"gigalitres"},"ondalik":0,"not":{"tr":"Topraktan ayrılan su boş durmuyor. 'Kayıp' kalemi, kullanılmayıp silinen ya da buharlaşan tahsis. Kuzey Victoria.","en":"Water detached from land does not sit idle. 'Lost' is allocation written off unused or evaporated. Northern Victoria."},"kaynak":"Victorian Water Register — Water Market Trends 2001–2024, Tablo 16","seriler":[{"ad":{"tr":"Ticari olarak satıldı","en":"Sold commercially"},"rol":"vurgu","noktalar":{"liste":[{"yil":"2007-08","ticari_satildi_gl":45,"sifirla_devredildi_gl":21,"kayip_buharlasma_gl":17,"devreden_gl":37,"devreden_yuzde":30,"yil_no":2007},{"yil":"2008-09","ticari_satildi_gl":39,"sifirla_devredildi_gl":21,"kayip_buharlasma_gl":10,"devreden_gl":33,"devreden_yuzde":32,"yil_no":2008},{"yil":"2009-10","ticari_satildi_gl":26,"sifirla_devredildi_gl":34,"kayip_buharlasma_gl":1,"devreden_gl":29,"devreden_yuzde":33,"yil_no":2009},{"yil":"2010-11","ticari_satildi_gl":35,"sifirla_devredildi_gl":37,"kayip_buharlasma_gl":3,"devreden_gl":62,"devreden_yuzde":45,"yil_no":2010},{"yil":"2011-12","ticari_satildi_gl":85,"sifirla_devredildi_gl":35,"kayip_buharlasma_gl":13,"devreden_gl":48,"devreden_yuzde":27,"yil_no":2011},{"yil":"2012-13","ticari_satildi_gl":87,"sifirla_devredildi_gl":49,"kayip_buharlasma_gl":7,"devreden_gl":21,"devreden_yuzde":13,"yil_no":2012},{"yil":"2013-14","ticari_satildi_gl":90,"sifirla_devredildi_gl":46,"kayip_buharlasma_gl":4,"devreden_gl":9,"devreden_yuzde":6,"yil_no":2013},{"yil":"2014-15","ticari_satildi_gl":149,"sifirla_devredildi_gl":76,"kayip_buharlasma_gl":3,"devreden_gl":12,"devreden_yuzde":5,"yil_no":2014},{"yil":"2015-16","ticari_satildi_gl":148,"sifirla_devredildi_gl":83,"kayip_buharlasma_gl":5,"devreden_gl":51,"devreden_yuzde":18,"yil_no":2015},{"yil":"2016-17","ticari_satildi_gl":226,"sifirla_devredildi_gl":165,"kayip_buharlasma_gl":6,"devreden_gl":110,"devreden_yuzde":22,"yil_no":2016},{"yil":"2017-18","ticari_satildi_gl":293,"sifirla_devredildi_gl":238,"kayip_buharlasma_gl":5,"devreden_gl":59,"devreden_yuzde":10,"yil_no":2017},{"yil":"2018-19","ticari_satildi_gl":351,"sifirla_devredildi_gl":210,"kayip_buharlasma_gl":6,"devreden_gl":65,"devreden_yuzde":10,"yil_no":2018},{"yil":"2019-20","ticari_satildi_gl":222,"sifirla_devredildi_gl":266,"kayip_buharlasma_gl":8,"devreden_gl":121,"devreden_yuzde":20,"yil_no":2019},{"yil":"2020-21","ticari_satildi_gl":311,"sifirla_devredildi_gl":240,"kayip_buharlasma_gl":13,"devreden_gl":171,"devreden_yuzde":23,"yil_no":2020},{"yil":"2021-22","ticari_satildi_gl":362,"sifirla_devredildi_gl":285,"kayip_buharlasma_gl":19,"devreden_gl":216,"devreden_yuzde":24,"yil_no":2021},{"yil":"2022-23","ticari_satildi_gl":396,"sifirla_devredildi_gl":349,"kayip_buharlasma_gl":24,"devreden_gl":317,"devreden_yuzde":29,"yil_no":2022},{"yil":"2023-24","ticari_satildi_gl":538,"sifirla_devredildi_gl":459,"kayip_buharlasma_gl":30,"devreden_gl":270,"devreden_yuzde":21,"yil_no":2023}],"x":"yil_no","y":"ticari_satildi_gl"}},{"ad":{"tr":"Bedelsiz devredildi","en":"Transferred at no charge"},"rol":"ikincil","noktalar":{"liste":[{"yil":"2007-08","ticari_satildi_gl":45,"sifirla_devredildi_gl":21,"kayip_buharlasma_gl":17,"devreden_gl":37,"devreden_yuzde":30,"yil_no":2007},{"yil":"2008-09","ticari_satildi_gl":39,"sifirla_devredildi_gl":21,"kayip_buharlasma_gl":10,"devreden_gl":33,"devreden_yuzde":32,"yil_no":2008},{"yil":"2009-10","ticari_satildi_gl":26,"sifirla_devredildi_gl":34,"kayip_buharlasma_gl":1,"devreden_gl":29,"devreden_yuzde":33,"yil_no":2009},{"yil":"2010-11","ticari_satildi_gl":35,"sifirla_devredildi_gl":37,"kayip_buharlasma_gl":3,"devreden_gl":62,"devreden_yuzde":45,"yil_no":2010},{"yil":"2011-12","ticari_satildi_gl":85,"sifirla_devredildi_gl":35,"kayip_buharlasma_gl":13,"devreden_gl":48,"devreden_yuzde":27,"yil_no":2011},{"yil":"2012-13","ticari_satildi_gl":87,"sifirla_devredildi_gl":49,"kayip_buharlasma_gl":7,"devreden_gl":21,"devreden_yuzde":13,"yil_no":2012},{"yil":"2013-14","ticari_satildi_gl":90,"sifirla_devredildi_gl":46,"kayip_buharlasma_gl":4,"devreden_gl":9,"devreden_yuzde":6,"yil_no":2013},{"yil":"2014-15","ticari_satildi_gl":149,"sifirla_devredildi_gl":76,"kayip_buharlasma_gl":3,"devreden_gl":12,"devreden_yuzde":5,"yil_no":2014},{"yil":"2015-16","ticari_satildi_gl":148,"sifirla_devredildi_gl":83,"kayip_buharlasma_gl":5,"devreden_gl":51,"devreden_yuzde":18,"yil_no":2015},{"yil":"2016-17","ticari_satildi_gl":226,"sifirla_devredildi_gl":165,"kayip_buharlasma_gl":6,"devreden_gl":110,"devreden_yuzde":22,"yil_no":2016},{"yil":"2017-18","ticari_satildi_gl":293,"sifirla_devredildi_gl":238,"kayip_buharlasma_gl":5,"devreden_gl":59,"devreden_yuzde":10,"yil_no":2017},{"yil":"2018-19","ticari_satildi_gl":351,"sifirla_devredildi_gl":210,"kayip_buharlasma_gl":6,"devreden_gl":65,"devreden_yuzde":10,"yil_no":2018},{"yil":"2019-20","ticari_satildi_gl":222,"sifirla_devredildi_gl":266,"kayip_buharlasma_gl":8,"devreden_gl":121,"devreden_yuzde":20,"yil_no":2019},{"yil":"2020-21","ticari_satildi_gl":311,"sifirla_devredildi_gl":240,"kayip_buharlasma_gl":13,"devreden_gl":171,"devreden_yuzde":23,"yil_no":2020},{"yil":"2021-22","ticari_satildi_gl":362,"sifirla_devredildi_gl":285,"kayip_buharlasma_gl":19,"devreden_gl":216,"devreden_yuzde":24,"yil_no":2021},{"yil":"2022-23","ticari_satildi_gl":396,"sifirla_devredildi_gl":349,"kayip_buharlasma_gl":24,"devreden_gl":317,"devreden_yuzde":29,"yil_no":2022},{"yil":"2023-24","ticari_satildi_gl":538,"sifirla_devredildi_gl":459,"kayip_buharlasma_gl":30,"devreden_gl":270,"devreden_yuzde":21,"yil_no":2023}],"x":"yil_no","y":"sifirla_devredildi_gl"}},{"ad":{"tr":"Ertesi yıla devretti","en":"Carried over to the next year"},"rol":"sessiz","noktalar":{"liste":[{"yil":"2007-08","ticari_satildi_gl":45,"sifirla_devredildi_gl":21,"kayip_buharlasma_gl":17,"devreden_gl":37,"devreden_yuzde":30,"yil_no":2007},{"yil":"2008-09","ticari_satildi_gl":39,"sifirla_devredildi_gl":21,"kayip_buharlasma_gl":10,"devreden_gl":33,"devreden_yuzde":32,"yil_no":2008},{"yil":"2009-10","ticari_satildi_gl":26,"sifirla_devredildi_gl":34,"kayip_buharlasma_gl":1,"devreden_gl":29,"devreden_yuzde":33,"yil_no":2009},{"yil":"2010-11","ticari_satildi_gl":35,"sifirla_devredildi_gl":37,"kayip_buharlasma_gl":3,"devreden_gl":62,"devreden_yuzde":45,"yil_no":2010},{"yil":"2011-12","ticari_satildi_gl":85,"sifirla_devredildi_gl":35,"kayip_buharlasma_gl":13,"devreden_gl":48,"devreden_yuzde":27,"yil_no":2011},{"yil":"2012-13","ticari_satildi_gl":87,"sifirla_devredildi_gl":49,"kayip_buharlasma_gl":7,"devreden_gl":21,"devreden_yuzde":13,"yil_no":2012},{"yil":"2013-14","ticari_satildi_gl":90,"sifirla_devredildi_gl":46,"kayip_buharlasma_gl":4,"devreden_gl":9,"devreden_yuzde":6,"yil_no":2013},{"yil":"2014-15","ticari_satildi_gl":149,"sifirla_devredildi_gl":76,"kayip_buharlasma_gl":3,"devreden_gl":12,"devreden_yuzde":5,"yil_no":2014},{"yil":"2015-16","ticari_satildi_gl":148,"sifirla_devredildi_gl":83,"kayip_buharlasma_gl":5,"devreden_gl":51,"devreden_yuzde":18,"yil_no":2015},{"yil":"2016-17","ticari_satildi_gl":226,"sifirla_devredildi_gl":165,"kayip_buharlasma_gl":6,"devreden_gl":110,"devreden_yuzde":22,"yil_no":2016},{"yil":"2017-18","ticari_satildi_gl":293,"sifirla_devredildi_gl":238,"kayip_buharlasma_gl":5,"devreden_gl":59,"devreden_yuzde":10,"yil_no":2017},{"yil":"2018-19","ticari_satildi_gl":351,"sifirla_devredildi_gl":210,"kayip_buharlasma_gl":6,"devreden_gl":65,"devreden_yuzde":10,"yil_no":2018},{"yil":"2019-20","ticari_satildi_gl":222,"sifirla_devredildi_gl":266,"kayip_buharlasma_gl":8,"devreden_gl":121,"devreden_yuzde":20,"yil_no":2019},{"yil":"2020-21","ticari_satildi_gl":311,"sifirla_devredildi_gl":240,"kayip_buharlasma_gl":13,"devreden_gl":171,"devreden_yuzde":23,"yil_no":2020},{"yil":"2021-22","ticari_satildi_gl":362,"sifirla_devredildi_gl":285,"kayip_buharlasma_gl":19,"devreden_gl":216,"devreden_yuzde":24,"yil_no":2021},{"yil":"2022-23","ticari_satildi_gl":396,"sifirla_devredildi_gl":349,"kayip_buharlasma_gl":24,"devreden_gl":317,"devreden_yuzde":29,"yil_no":2022},{"yil":"2023-24","ticari_satildi_gl":538,"sifirla_devredildi_gl":459,"kayip_buharlasma_gl":30,"devreden_gl":270,"devreden_yuzde":21,"yil_no":2023}],"x":"yil_no","y":"devreden_gl"}},{"ad":{"tr":"Kayıp — silinen ya da buharlaşan","en":"Lost — written off or evaporated"},"rol":"sessiz","noktalar":{"liste":[{"yil":"2007-08","ticari_satildi_gl":45,"sifirla_devredildi_gl":21,"kayip_buharlasma_gl":17,"devreden_gl":37,"devreden_yuzde":30,"yil_no":2007},{"yil":"2008-09","ticari_satildi_gl":39,"sifirla_devredildi_gl":21,"kayip_buharlasma_gl":10,"devreden_gl":33,"devreden_yuzde":32,"yil_no":2008},{"yil":"2009-10","ticari_satildi_gl":26,"sifirla_devredildi_gl":34,"kayip_buharlasma_gl":1,"devreden_gl":29,"devreden_yuzde":33,"yil_no":2009},{"yil":"2010-11","ticari_satildi_gl":35,"sifirla_devredildi_gl":37,"kayip_buharlasma_gl":3,"devreden_gl":62,"devreden_yuzde":45,"yil_no":2010},{"yil":"2011-12","ticari_satildi_gl":85,"sifirla_devredildi_gl":35,"kayip_buharlasma_gl":13,"devreden_gl":48,"devreden_yuzde":27,"yil_no":2011},{"yil":"2012-13","ticari_satildi_gl":87,"sifirla_devredildi_gl":49,"kayip_buharlasma_gl":7,"devreden_gl":21,"devreden_yuzde":13,"yil_no":2012},{"yil":"2013-14","ticari_satildi_gl":90,"sifirla_devredildi_gl":46,"kayip_buharlasma_gl":4,"devreden_gl":9,"devreden_yuzde":6,"yil_no":2013},{"yil":"2014-15","ticari_satildi_gl":149,"sifirla_devredildi_gl":76,"kayip_buharlasma_gl":3,"devreden_gl":12,"devreden_yuzde":5,"yil_no":2014},{"yil":"2015-16","ticari_satildi_gl":148,"sifirla_devredildi_gl":83,"kayip_buharlasma_gl":5,"devreden_gl":51,"devreden_yuzde":18,"yil_no":2015},{"yil":"2016-17","ticari_satildi_gl":226,"sifirla_devredildi_gl":165,"kayip_buharlasma_gl":6,"devreden_gl":110,"devreden_yuzde":22,"yil_no":2016},{"yil":"2017-18","ticari_satildi_gl":293,"sifirla_devredildi_gl":238,"kayip_buharlasma_gl":5,"devreden_gl":59,"devreden_yuzde":10,"yil_no":2017},{"yil":"2018-19","ticari_satildi_gl":351,"sifirla_devredildi_gl":210,"kayip_buharlasma_gl":6,"devreden_gl":65,"devreden_yuzde":10,"yil_no":2018},{"yil":"2019-20","ticari_satildi_gl":222,"sifirla_devredildi_gl":266,"kayip_buharlasma_gl":8,"devreden_gl":121,"devreden_yuzde":20,"yil_no":2019},{"yil":"2020-21","ticari_satildi_gl":311,"sifirla_devredildi_gl":240,"kayip_buharlasma_gl":13,"devreden_gl":171,"devreden_yuzde":23,"yil_no":2020},{"yil":"2021-22","ticari_satildi_gl":362,"sifirla_devredildi_gl":285,"kayip_buharlasma_gl":19,"devreden_gl":216,"devreden_yuzde":24,"yil_no":2021},{"yil":"2022-23","ticari_satildi_gl":396,"sifirla_devredildi_gl":349,"kayip_buharlasma_gl":24,"devreden_gl":317,"devreden_yuzde":29,"yil_no":2022},{"yil":"2023-24","ticari_satildi_gl":538,"sifirla_devredildi_gl":459,"kayip_buharlasma_gl":30,"devreden_gl":270,"devreden_yuzde":21,"yil_no":2023}],"x":"yil_no","y":"kayip_buharlasma_gl"}}]},"ayrisma_zamani":{"tur":"zaman_cizelgesi","baslik":{"tr":"Suyu topraktan ayıran kararlar","en":"The decisions that separated water from land"},"not":{"tr":"Ayrışma tek bir kanunla olmadı: izin verildi, tavan kondu, tavan kaldırıldı, sonra birliktelik kurumu tasfiye edildi. Tarihler Water Act 1989'un kendi dipnotlarından ve sicilin raporundan.","en":"The separation was not accomplished by a single statute: it was permitted, capped, uncapped, and finally the instrument of association was abolished. Dates come from the Water Act 1989's own endnotes and from the register's report."},"kaynak":"Water Act 1989 (Victoria), Tasdikli Sürüm No. 147 — dipnotlar; Victorian Water Register","olaylar":[{"yil":1989,"baslik":{"tr":"Water Act 1989 kabul edilir","en":"The Water Act 1989 is enacted"},"aciklama":{"tr":"Victoria'nın su rejiminin çatı kanunu. Su payı henüz yok.","en":"The framework statute for Victoria's water regime. The water share does not yet exist."}},{"yil":2005,"baslik":{"tr":"Su payını kuran kanun tasdik edilir","en":"The statute creating the water share receives assent"},"aciklama":{"tr":"Water (Resource Management) Act 2005, No. 99/2005. Kırk birinci maddesi, Water Act 1989'a 33F'i — payın ihdasını ve niteliğini — ekler.","en":"The Water (Resource Management) Act 2005, No. 99/2005. Its section 41 inserts section 33F — the issuing and nature of the share — into the Water Act 1989."},"yil_ek":{"tr":"7 Aralık","en":"7 December"}},{"yil":2006,"baslik":{"tr":"Hüküm yürürlüğe girer","en":"The provision commences"},"aciklama":{"tr":"Özel Resmî Gazete No. 191 ile. Artık su payı olmadan su almak suç; payı Bakan ihdas ediyor, Sicil Memuru malikin adını ve adresini kaydediyor.","en":"By Special Gazette No. 191. Taking water without a water share is now an offence; the Minister issues the share and the Registrar records the owner's name and address."},"yil_ek":{"tr":"3 Ağustos","en":"3 August"}},{"yil":2007,"baslik":{"tr":"Kuzey Victoria'da ayrışma uygulanır","en":"Separation is implemented in northern Victoria"},"aciklama":{"tr":"Sicilin kendi ifadesiyle: o gün bütün paylar hâlâ toprakla birliktelik hâlindeydi. Sahipler ayırmayı seçebilirdi — tavanlar elverdiği ölçüde.","en":"In the register's own words: on that day every share was still associated with land. Holders could choose to disassociate — so far as the caps allowed."},"yil_ek":{"tr":"1 Temmuz","en":"1 July"}},{"yil":2009,"baslik":{"tr":"Yüzde on tavanı kaldırılır","en":"The ten per cent cap is abolished"},"aciklama":{"tr":"Bir sistemdeki pay hacminin en çok %10'u toprağa bağlı olmadan sahiplenilebiliyordu. Sınır kalkıyor.","en":"At most 10 per cent of a system's share volume could be owned without being linked to land. The limit is lifted."}},{"yil":2014,"baslik":{"tr":"Yüzde dört çıkış tavanı kaldırılır","en":"The four per cent export cap is abolished"},"aciklama":{"tr":"Bir sulama alanından yılda en çok %4 su çıkarılabiliyordu. O sınır da kalkıyor.","en":"At most 4 per cent of an irrigation area's water could be moved out in a year. That limit goes too."}},{"yil":2023,"baslik":{"tr":"Birliktelik kurumu tasfiye edilir","en":"The instrument of association is abolished"},"aciklama":{"tr":"Payı araziyle resmen bağlama imkânı kanundan çıkarılır. Sicil gerekçesini yazıyor: birliktelik, suyun nerede kullanılacağının anlamlı bir göstergesi olmaktan çıkmıştı.","en":"The ability to formally associate a share with land is removed from the statute. The register states the reason: association had ceased to be a meaningful indication of where the water would be used."},"yil_ek":{"tr":"20 Kasım","en":"20 November"}},{"yil":2026,"baslik":{"tr":"Sıra kurayla belirlenir","en":"The queue is decided by lot"},"aciklama":{"tr":"Barmah darlığından geçecek ticaretin sırası rastgeleleştirilir. Çekilişi iki eyaletin idaresi birlikte yapar, rekabet kurumu izler ve kaydı sonradan inceleyip yazılı beyan verir.","en":"The order of trades passing through the Barmah narrows is randomised. Two states' administrations run the draw jointly, the competition regulator observes it, then reviews the recording and attests to it in writing."},"yil_ek":{"tr":"3 Temmuz","en":"3 July"}}]},"kura_akisi":{"tur":"kartlar","baslik":{"tr":"Fiziksel kapasite yetmediğinde sıra nasıl belirleniyor","en":"How the queue is decided when physical capacity runs short"},"not":{"tr":"Temmuz 2026 Barmah açılışının işleyişi, adım adım. Sicil bu yöntemi kendi raporunda geçici bir çözüm olarak tanımlıyor.","en":"The procedure of the July 2026 Barmah opening, step by step. The register describes this method in its own report as an interim solution."},"kaynak":"Goulburn-to-Murray and Barmah Narrows Post Trade Opening Report, Temmuz 2026; ACCC'nin 3 Ağustos 2026 tarihli yazısı","kartlar":[{"ust":{"tr":"1 · Eyalet idaresi","en":"1 · State administration"},"baslik":{"tr":"Kapasite ilan edilir","en":"The capacity is announced"},"govde":{"tr":"Sabah yedide, darlıktan o dönem geçebilecek hacim duyurulur. Nehrin o noktadaki akışı günde yaklaşık yedi bin megalitreyle sınırlı.","en":"At seven in the morning the volume that can pass the narrows in that window is announced. The river's flow at that point is limited to roughly seven thousand megalitres a day."},"rakam":{"deger":24121.3,"bolen":1000,"ondalik":1,"etiket":{"tr":"bin megalitre ilan edildi","en":"thousand megalitres announced"}}},{"ust":{"tr":"2 · Hak sahipleri","en":"2 · Entitlement holders"},"baslik":{"tr":"Başvuru penceresi açılır","en":"The application window opens"},"govde":{"tr":"Suyunu aşağı taşımak isteyen herkes aynı gün başvurur; başvurular aracı portalından ya da çevrim içi ticaretten gelir.","en":"Anyone wishing to move water downstream applies the same day; applications arrive through the broker portal or through online trading."},"rakam":{"deger":214,"ondalik":0,"etiket":{"tr":"uygun başvuru, iki eyaletten","en":"eligible applications, from two states"}}},{"ust":{"tr":"3 · DEECA ile WaterNSW, birlikte","en":"3 · DEECA and WaterNSW, jointly"},"baslik":{"tr":"Sıra kurayla çekilir","en":"The order is drawn by lot"},"govde":{"tr":"Uygun başvurular, işlenme sırasını saptamak için rastgeleleştirilir. Önce başvuran önce geçmiyor, daha çok ödeyen de; sıra tesadüfe bırakılıyor.","en":"Eligible applications are randomised to determine the order in which they will be processed. First to apply does not go first, nor does whoever pays most; the order is left to chance."}},{"ust":{"tr":"4 · Rekabet ve Tüketici Kurumu","en":"4 · Competition and Consumer Commission"},"baslik":{"tr":"Çekiliş izlenir, kaydı incelenir","en":"The draw is observed, its recording reviewed"},"govde":{"tr":"Kurumun temsilcisi çekilişi yerinde izler, sonra kaydını yeniden inceler ve çıktıda hiçbir düzenleme veya değişiklik gözlemlemediğini imzasıyla beyan eder.","en":"The regulator's representative observes the draw in person, then reviews its recording and attests under signature to having observed no editing or change to the output."}},{"ust":{"tr":"5 · Eyalet idaresi","en":"5 · State administration"},"baslik":{"tr":"Kapasite dolana kadar işlenir","en":"Processing continues until capacity is full"},"govde":{"tr":"Başvurular çekilen sıraya göre işlenir. Hacim tükendiğinde kalanlar reddedilir — kuralı çiğnedikleri için değil, kuradaki yerleri yüzünden.","en":"Applications are processed in the order drawn. When capacity is exhausted the rest are refused — not for breaking a rule, but because of where they fell in the draw."},"rakam":{"deger":29,"ondalik":1,"sonek":{"tr":"%","en":"%"},"etiket":{"tr":"onaylanan başvuru oranı","en":"share of applications approved"}}}]},"iki_acilis":{"tur":"ikili_cubuk","baslik":{"tr":"Aynı gün, aynı kura, iki güzergâh","en":"The same day, the same draw, two routes"},"not":{"tr":"İki açılış da 2 Temmuz 2026'da açıldı, ikisinin sırası da kurayla belirlendi. Aradaki tek fark fiziksel: Barmah'ta nehir daralıyor. Her iki açılışın rakamları da eyalet ayrımı olmadan, toplam olarak alınmıştır.","en":"Both openings opened on 2 July 2026 and the order in both was decided by lot. The only difference between them is physical: at Barmah the river narrows. Figures for both openings are taken as totals, without splitting by state."},"kaynak":"Goulburn-to-Murray and Barmah Narrows Post Trade Opening Report, Temmuz 2026","seriler":[{"ad":{"tr":"Goulburn → Murray (darlık yok)","en":"Goulburn → Murray (no narrowing)"},"rol":"ikincil"},{"ad":{"tr":"Barmah darlığı","en":"The Barmah narrows"},"rol":"vurgu"}],"satirlar":[{"etiket":{"tr":"İlan edilen kapasite","en":"Capacity announced"},"birim":{"tr":"bin megalitre","en":"thousand megalitres"},"ondalik":1,"degerler":[112827.9,24121.3],"bolen":1000},{"etiket":{"tr":"Kuraya giren başvuru","en":"Applications entering the draw"},"birim":{"tr":"başvuru","en":"applications"},"ondalik":0,"degerler":[286,214]},{"etiket":{"tr":"Onaylanan","en":"Approved"},"birim":{"tr":"başvuru","en":"applications"},"ondalik":0,"degerler":[282,62]},{"etiket":{"tr":"Onay oranı","en":"Approval rate"},"birim":{"tr":"yüzde","en":"per cent"},"ondalik":1,"degerler":[98.6,29],"sonek":{"tr":"%","en":"%"},"rozet":{"tr":"aynı mekanizma","en":"same mechanism"}},{"etiket":{"tr":"Talebin kapasiteye oranı","en":"Demand as a multiple of capacity"},"birim":{"tr":"kat","en":"times"},"ondalik":2,"degerler":[1.07,2.8],"sonek":{"tr":"×","en":"×"}}]},"dosyanin_rakamlari":{"tur":"kunye","baslik":{"tr":"Dosyanın dört rakamı","en":"Four figures from this dossier"},"not":{"tr":"İlk üçü kuzey Victoria, dördüncüsü Avustralya geneli ve 2019-20 yılına ait — piyasa rakamlarından dört yıl eski. Aynı yılmış gibi okunmamalı.","en":"The first three are northern Victoria; the fourth is Australia-wide and belongs to 2019-20 — four years older than the market figures. They should not be read as the same year."},"kaynak":"Victorian Water Register; Bureau of Meteorology — Water in Australia 2019–20","kalemler":[{"deger":50.2,"ondalik":1,"sonek":{"tr":"%","en":"%"},"etiket":{"tr":"suyun toprağa bağlı kalan payı","en":"share of the water still linked to land"},"alt":{"tr":"2000-01'de yüzde yüzdü","en":"in 2000-01 it was one hundred per cent"}},{"deger":5000,"ondalik":0,"onek":{"tr":"$","en":"$"},"etiket":{"tr":"kalıcı hakkın megalitre fiyatı, en yüksek yıl","en":"price of a permanent entitlement per megalitre, peak year"},"alt":{"tr":"2013-14'te 1.380 dolardı","en":"in 2013-14 it was 1,380 dollars"}},{"deger":29,"ondalik":1,"sonek":{"tr":"%","en":"%"},"etiket":{"tr":"Barmah darlığında onaylanan başvuru oranı","en":"share of applications approved at the Barmah narrows"},"alt":{"tr":"aynı gün öteki güzergâhta yüzde 98,6","en":"on the same day, 98.6 per cent on the other route"}},{"deger":14270,"ondalik":0,"etiket":{"tr":"Avustralya'da tüketime alınan su, gigalitre","en":"water taken for consumptive use in Australia, gigalitres"},"alt":{"tr":"2019-20 — ulusal rakamın en güncel yılı","en":"2019-20 — the most recent year for the national figure"}}]}}$dsr$::jsonb,
  array['Avustralya', 'su hakkı', 'su piyasası', 'Murray-Darling', 'Victoria', 'sulama', 'kuraklık', 'su sicili', 'tahsis ticareti', 'Barmah', 'ACCC', 'su politikası', 'tarım ekonomisi']::text[],
  'https://tarimportali.net/dosya/avustralya/avustralya_kapak_havadan.jpg',
  $dsr$Willem van Aken, CSIRO — CC BY 3.0$dsr$,
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
  status       = excluded.status,
  -- Pencere KASITLI olarak korunuyor. Yayındaki bir dosyanın metninde yazım
  -- hatası düzeltmek için seed'i yeniden çalıştırmak, 28 günlük sayacı
  -- sıfırlamamalı. Pencereyi bilerek kaydırmak istiyorsanız elle update.
  starts_at    = coalesce(country_dossiers.starts_at,    excluded.starts_at),
  ends_at      = coalesce(country_dossiers.ends_at,      excluded.ends_at),
  published_at = coalesce(country_dossiers.published_at, excluded.published_at),
  updated_at   = now();

delete from public.dossier_sections
 where dossier_id = (select id from public.country_dossiers where slug = 'avustralya');

insert into public.dossier_sections
  (dossier_id, ord, title_tr, title_en, body_tr, body_en, chart_keys, tur, gorsel)
select d.id, v.ord, v.title_tr, v.title_en, v.body_tr, v.body_en, v.chart_keys, v.tur, v.gorsel
from public.country_dossiers d
cross join (values
  (1::integer, $dsr$Suyun kendi sicili$dsr$, $dsr$Water's own register$dsr$, $dsr$Victoria'da bir kadastro memurunun masasında, toprak tapularının yanında
ikinci bir defter duruyor. O defterde arsa yok, parsel yok, dönüm yok.
Suyun kendisi var — kim sahibi, adresi ne, üzerinde ipotek var mı.

Bu defterin adı su sicili. Victoria'nın 1989 tarihli Su Kanunu'nun tasdikli
metni dokuz yüz yirmi üç sayfa ve içinde "su sicili" ibaresi yüz doksan
yerde, "Sicil Memuru" yüz elli dört yerde geçiyor. Memur, kamu personeli
mevzuatına göre istihdam ediliyor. Kanun, sicile su payıyla ilgili olarak
neyin kaydedileceğini madde madde sayıyor ve ilk sırada şu duruyor:
malikin adı ve adresi.

Türkiyeli okur için buradaki tuhaflık suyun kayıt altında olması değil.
Bizde de su kullanımı izne bağlı, kuyu ruhsatlı, sulama birliğinin kaydı
var. Tuhaflık, kaydın neye bağlandığı. Bizde su hakkı araziye bağlıdır:
tarlayı satarsınız, suyu da gider. Victoria'da su payı ayrı bir mülk.
Araziniz olmadan sahip olabilirsiniz. İki kişi onu müşterek ya da iştirak
halinde tutabilir — yani ortak mülkiyetin, taşınmazlarda kullanılan klasik
biçimleri suya uygulanıyor. Üstüne ipotek konabilir; kanun "bir su payının
ipoteği" ibaresini yedi ayrı yerde kullanıyor ve ipoteğin değişmesi
Sicil Memuruna bildiriliyor.

Defterin arkasında bir icra düzeni de var. Kanunun su paylarını düzenleyen
kısmı bir yetkiyle değil, bir **suçla** açılıyor: su payı olmaksızın su
almak. Hemen ardından iki hüküm daha geliyor — biri bu suça ilişkin ispat
kurallarını düzenliyor, öteki bir fıkrasındaki ihlal için **ihbarname
düzenleme yetkisi** veriyor. Yani sicil yalnızca bir kayıt defteri değil;
kaydın dışına çıkmak cezalandırılabilir bir fiil.

Bankaya gidip suyunuzu teminat göstermek. Dosyanın anlattığı şey bu
cümlenin nasıl mümkün olduğu, kaç adımda olduğu, ve en sonunda neyin hâlâ
tesadüfe bırakıldığı.$dsr$, $dsr$On a Victorian registry officer's desk, beside the registers of land title,
sits a second book. It contains no plots, no parcels, no acreage. It
contains the water itself — who owns it, at what address, and whether
anything is charged against it.

That book is the water register. The authorised text of Victoria's Water
Act 1989 runs to nine hundred and twenty-three pages, and within it the
phrase "water register" appears in a hundred and ninety places and
"Registrar" in a hundred and fifty-four. The Registrar is employed under
the public administration statute. The Act sets out, item by item, what
must be recorded in the register about a water share, and the first item
is the owner's name and address.

For a Turkish reader the strangeness here is not that water is registered.
Water use requires permits here too; wells are licensed, irrigation unions
keep records. The strangeness is what the record attaches to. In Türkiye a
water right attaches to land: sell the field and the water goes with it.
In Victoria a water share is a separate holding. You can own one without
owning any land. Two people may hold it as joint tenants or as tenants in
common — the classic forms of co-ownership used for real property, applied
to water. It can be mortgaged; the Act uses the phrase "mortgage of a
water share" in seven separate places, and a change to the mortgage is
notified to the Registrar.

Behind the register stands an enforcement regime. The part of the Act that
governs water shares opens not with a power but with an **offence**: taking
water without a water share. Two provisions follow immediately — one
setting out evidentiary rules for that offence, the other conferring the
power to issue an **infringement notice** for a breach of one of its
subsections. The register is not merely a ledger; stepping outside it is a
punishable act.

Going to a bank and offering your water as security. What this dossier
describes is how that sentence became possible, in how many steps, and what
is still left to chance at the end of it.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/avustralya/avustralya_torrumbarry_bent.jpg","atif":"Chicken-7 — Public domain","kaynak":null,"alt_tr":"Torrumbarry Bendi, Murray nehri. Kapaklardan geçen su ölçülüyor ve pay sahiplerine yazılıyor; sicilin kağıttaki kaydının sudaki karşılığı bu yapılar.","alt_en":"Torrumbarry Weir on the Murray. Water passing the gates is measured and booked to shareholders; these structures are the register's counterpart in the water itself."}$dsr$::jsonb),
  (2, $dsr$Aynı kanunun iki kısmı$dsr$, $dsr$Two parts of the same Act$dsr$, $dsr$Suyun topraktan ayrılmasını arayan biri, kanunda bunu ilan eden bir cümle
bulmayı bekler. Böyle bir hüküm yok. Ayrışma bir beyanla değil, kanunun
**yapısıyla** kurulmuş.

Water Act 1989'un Kısım 3A'sının adı "Su payları". Bölüm 1 bir suçla
başlıyor: su payı olmaksızın su almak. Bölüm 2 payın ihdasını ve niteliğini
düzenliyor — payı Bakan ihdas ediyor, beyan edilmiş bir su sistemine ilişkin
olarak, ve pay o mevsim için tahsis edilen suyun alınmasına yetki veriyor.

Sonra, aynı kanunun çok daha ilerisinde, Kısım 4B geliyor: "Su kullanım
izinleri ve su kullanım kayıtları". Bu kısım da bir suçla açılıyor ve o
suçun tanımı ilkinden farklı: kişi, beyan edilmiş bir su sisteminden gelen
suyu, kaydı ya da izni olmaksızın **arazide kullanamaz**.

İki ayrı kısım. İki ayrı belge. İki ayrı suç. Biri suyun kendisine dair
hakkı düzenliyor; öteki o suyun belirli bir toprak parçası üzerinde
kullanılmasını. Bir çiftçinin ikisine de ihtiyacı var, ama ikisini aynı
kişide toplaması gerekmiyor. Payı olan suyu satabilir; arazisi ve kullanım
izni olan başkasının suyunu kullanabilir.

Ayrışma, kanunun bir yerinde ilan edilmek yerine iki yerinde ayrı ayrı
düzenlenerek kurulmuş. Bu, hukuk tekniği açısından önemsiz bir ayrıntı
değil: ilan edilen bir ilke geri alınabilir, iki ayrı kısma yerleşmiş bir
mimari ancak baştan kurgulanarak değiştirilebilir. On yedi yıl sonra
değiştirmeye kalktıklarında — ki kalktılar — ellerinden gelen, ikisi
arasındaki bağı kaldırmak oldu, mimariyi yıkmak değil.$dsr$, $dsr$Anyone looking for the separation of water from land expects to find a
provision announcing it. There is no such provision. The separation was
built not by declaration but by the **structure** of the Act.

Part 3A of the Water Act 1989 is headed "Water shares". Its first division
begins with an offence: taking water without a water share. Its second
division governs the issuing and nature of the share — the Minister issues
it, in respect of a declared water system, and the share authorises the
taking of water under the allocation made to it for that season.

Then, much further on in the same Act, comes Part 4B: "Water-use licences
and water use registrations". This part also opens with an offence, and the
offence is a different one: a person must not **use water on land**, where
that water comes from a declared water system, without a registration or
licence.

Two separate parts. Two separate instruments. Two separate offences. One
governs the right to the water itself; the other governs the use of that
water on a particular piece of ground. A farmer needs both, but need not
hold both. Whoever holds a share can sell the water; whoever holds land and
a use licence can use someone else's water.

The separation was constructed by being regulated in two places rather than
proclaimed in one. In legal-technical terms this is not a trivial detail: a
proclaimed principle can be withdrawn, whereas an architecture settled into
two separate parts can only be changed by redesign. Seventeen years later,
when they did set about changing it, what they could reach was the link
between the two — not the architecture.$dsr$, '{}'::text[], 'belge', $dsr${"url":"https://tarimportali.net/dosya/avustralya/avustralya_mulwala_kanal_basi.jpg","atif":"Mattinbgn — CC BY-SA 3.0","kaynak":null,"alt_tr":"Mulwala Kanalı'nın başı — suyun nehirden ayrılıp sulama şebekesine girdiği nokta.","alt_en":"The head of the Mulwala Canal — where water leaves the river and enters the irrigation network."}$dsr$::jsonb),
  (3, $dsr$Yüzde yüzden yüzde elliye$dsr$, $dsr$From a hundred per cent to fifty$dsr$, $dsr$Kuzey Victoria'nın yüksek güvenilirlikli su hakkı, her yılın 30 Haziran'ında
sayılıyor. Yüksek güvenilirlikli pay, su kıt olduğunda sırada önce gelen
pay; düşük güvenilirlikli olan ancak bol yıllarda su görüyor.

2000-01 sayımında kuzey Victoria'da iki bin iki yüz seksen üç gigalitre
yüksek güvenilirlikli hak vardı ve bunun **tamamı** toprağa bağlıydı. Yüz
üzerinden yüz. Çevrenin hakkı yoktu, su kurumlarının hakkı yoktu, toprağa
bağlı olmayan özel hak yoktu. Su, üstünde kullanıldığı arazinin bir
niteliğiydi.

2023-24 sayımında aynı bölgede toplam hak iki bin beş yüz on beş
gigalitreye çıkmış. Toprağa bağlı kalan kısım bin iki yüz altmış iki
gigalitre — yüzde elli virgül iki. Yarısı.

Geri kalan yarının nereye gittiği iki yere bölünüyor. Dört yüz elli altı
gigalitre — yüzde on sekiz — özel kişilerin elinde ama hiçbir araziye bağlı
değil. Yedi yüz kırk yedi gigalitre — yüzde yirmi dokuz virgül yedi —
çevrenin. Elli gigalitre su kurumlarında.

Arada bir ara durak var. 2015-16'da toprağa bağlı kısım bin dört yüz
yetmiş üç gigalitreydi, yüzde altmış iki. Yani düşüşün büyük bölümü ilk on
beş yılda olmuş, sonraki sekiz yılda ivme yavaşlamış ama durmamış.

Bu rakamların hepsi kuzey Victoria'ya ait. Avustralya'nın tamamı için
böyle bir seri bu dosyanın kaynaklarında yok; ulusal kurumun kendi veri
ambarı kapalı. Elimizdeki, piyasayı işleten eyalet idaresinin kendi
defteri — ve o defterin gösterdiği şey, bir bölgedeki suyun yarısının
yirmi üç yılda toprağı terk etmesi.$dsr$, $dsr$Northern Victoria's high-reliability water entitlement is counted on the
thirtieth of June each year. A high-reliability share is the one served
first when water is scarce; a low-reliability share receives water only in
abundant years.

At the 2000-01 count, northern Victoria held two thousand two hundred and
eighty-three gigalitres of high-reliability entitlement, and **all of it**
was linked to land. A hundred out of a hundred. The environment held none,
the water corporations held none, and no private holding stood apart from
land. Water was an attribute of the ground on which it was used.

At the 2023-24 count the total in the same region had risen to two thousand
five hundred and fifteen gigalitres. The portion still linked to land is
one thousand two hundred and sixty-two gigalitres — fifty point two per
cent. Half.

Where the other half went divides in two. Four hundred and fifty-six
gigalitres — eighteen per cent — is in private hands but tied to no land at
all. Seven hundred and forty-seven gigalitres — twenty-nine point seven per
cent — belongs to the environment. Fifty gigalitres sits with water
corporations.

There is an intermediate station. In 2015-16 the land-linked portion was
one thousand four hundred and seventy-three gigalitres, or sixty-two per
cent. Most of the decline therefore happened in the first fifteen years;
over the following eight the pace slowed without stopping.

All of these figures belong to northern Victoria. No comparable series for
Australia as a whole appears in this dossier's sources; the national
agency's own data warehouse is closed. What we have is the ledger of the
state administration that operates the market — and what that ledger shows
is half the water in one region leaving the land over twenty-three years.$dsr$, array['su_kimde']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/avustralya/avustralya_bugday_kirsali.jpg","atif":"David Edwards — CC BY 3.0","kaynak":null,"alt_tr":"Orta Victoria'da tahıl arazisi.","alt_en":"Grain country in central Victoria."}$dsr$::jsonb),
  (4, $dsr$Toprağı terk eden su$dsr$, $dsr$The water that left the land$dsr$, $dsr$Suyun topraktan ayrılması tek bir olay değil, bir eğri. Ve eğrinin şekli
hikâyenin kendisi.

Toprağa bağlı payın oranı 2000-01'de yüzde yüz, 2004-05'te yine yüzde yüz.
İki sayım, hiç değişmemiş. Değişim 2009-10'da görünür hale geliyor: o yıl
özel ellerde olup hiçbir araziye bağlı olmayan pay yüzde beş virgül altı.
Oradan itibaren her sayımda artıyor — 2016-17'de yüzde on, 2020-21'de
yüzde on dört, 2023-24'te yüzde on sekiz virgül bir.

Burada bir kaynak notu gerekiyor. Sicilin tablosunda 2008-09 satırı kendi
içinde çelişiyor: bastığı yüzdeler o satırın kendi hacimleriyle
uyuşmuyor. Diğer on yedi satırın tamamında uyuşuyor. Bu dosyadaki
yüzdeler hacimlerden hesaplandı, çünkü hacimler kendi toplamına tam
oturuyor. 2008-09 bu yüzden eğrinin anlatısında kullanılmıyor; temiz seri
2009-10'da başlıyor.

Eğrinin ikinci çizgisi çevrenin payı ve o daha dik yükseliyor: 2009-10'da
yüzde yedi, 2011-12'de yüzde yirmi, 2014-15'te yüzde yirmi altı,
2023-24'te yüzde yirmi dokuz virgül yedi. Çevre, on dört yılda sıfırdan
bölgenin en büyük tarım dışı hak sahibine dönüşmüş.

Üçüncü çizgi — toprağa bağlı kalan pay — bu ikisinin aynasında düşüyor.
Yüzde yüzden yüzde elliye.

Eğrinin yanında, piyasanın ne kadar olgunlaştığını gösteren ikinci bir
gelişme var. Victoria 2020-21'den itibaren her tahsis ticaretinin
**gerekçesini** de toplamaya başladı ve kategorileri saydı: standart
ticari işlem, ilişkili taraf işlemi, devir parkı, devir parkı dönüşü,
özel kira düzenlemesi, su payı devrinin parçası olarak yapılan tahsis
ticareti, **vadeli sözleşme**, ve diğer. Sekiz kategori.

Bu listeye dikkat etmek gerekiyor. Vadeli sözleşme ve özel kira, mal
piyasalarının sözlüğünden gelen terimler. Suyun bir mülke dönüşmesi
yalnızca alınıp satılabilmesi değil; kiralanabilmesi, ileri bir tarih
için sözleşmeye bağlanabilmesi, ve park edilebilmesi.

Eğriye bakan birinin sorması gereken soru şu: bu düşüş bir çöküş mü, bir
tasarım mı? Cevap bir sonraki bölümde ve cevabın adı tavan.$dsr$, $dsr$The separation of water from land is not a single event but a curve. And
the shape of the curve is the story.

The land-linked share stood at a hundred per cent in 2000-01 and again at a
hundred per cent in 2004-05. Two counts, no movement. The change becomes
visible in 2009-10, when holdings in private hands attached to no land
reach five point six per cent. From there they rise at every count — ten
per cent in 2016-17, fourteen per cent in 2020-21, eighteen point one per
cent in 2023-24.

A note on the source is needed here. The 2008-09 row of the register's
table is internally inconsistent: the percentages it prints do not agree
with its own volumes. In all seventeen other rows they do agree. The
percentages used in this dossier are computed from the volumes, because the
volumes sum exactly to their own total. For that reason 2008-09 plays no
part in the account of the curve; the clean series begins in 2009-10.

The curve's second line is the environment's share, and it climbs more
steeply: seven per cent in 2009-10, twenty per cent in 2011-12, twenty-six
per cent in 2014-15, twenty-nine point seven per cent in 2023-24. In
fourteen years the environment went from nothing to being the region's
largest non-farm holder.

Beside the curve sits a second development that shows how far the market
has matured. From 2020-21 Victoria began collecting the **reason** for each
allocation trade, and enumerated the categories: standard commercial trade,
related party trade, carryover parking, carryover parking return, private
lease arrangement, allocation trade as part of a water share transfer,
**forward contract**, and other. Eight categories.

That list deserves attention. Forward contract and private lease are terms
from the vocabulary of commodity markets. Water becoming a holding is not
only about being bought and sold; it is about being leased, contracted for a
future date, and parked.

The question a reader of the curve should ask is this: is the decline a
collapse or a design? The answer is in the next section, and its name is
the cap.$dsr$, array['topraktan_ayrilma']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/avustralya/avustralya_ana_kanal.jpg","atif":"Willem van Aken, CSIRO — CC BY 3.0","kaynak":null,"alt_tr":"Griffith'te ana sulama kanalı, 1989. Kanaldaki su hiçbir tarlanın değil; geçtiği arazilerin sahipleriyle de ilgisi yok.","alt_en":"The main irrigation channel at Griffith, 1989. The water in the channel belongs to no field, and has no connection to the owners of the land it passes."}$dsr$::jsonb),
  (5, $dsr$İzin, tavan, tavanın kalkması$dsr$, $dsr$Permission, a cap, and the lifting of the cap$dsr$, $dsr$Suyun topraktan ayrılmasını mümkün kılan hüküm kanuna 2005'te eklendi.
Ekleyen kanunun adı Water (Resource Management) Act 2005; tasdik tarihi
7 Aralık 2005. O kanunun kırk birinci maddesi, Su Kanunu'na payın ihdasını
ve niteliğini düzenleyen hükmü yerleştiriyor. Hüküm 3 Ağustos 2006'da
yürürlüğe giriyor — Özel Resmî Gazete'nin yüz doksan bir sayılı nüshasıyla.

Ama ayrışma o gün olmuyor.

Kuzey Victoria'da ayrışma **1 Temmuz 2007'de** uygulanıyor ve sicil o günü
kendi raporunda tarif ederken şunu söylüyor: ayrışma gerçekleştiğinde
bütün su payları hâlâ toprakla birliktelik halindeydi. Yani kanun kapıyı
açtı, kapıdan kimse geçmedi. Sahipler ayırmayı **seçebilirdi**.

Seçim serbest de değildi. İki tavan vardı. Birincisi: bir sistemdeki pay
hacminin en çok yüzde onu toprağa bağlı olmaksızın sahiplenilebilirdi.
İkincisi: bir sulama alanından yılda en çok yüzde dört su dışarı
taşınabilirdi. Birinci tavan **2009'da** kaldırıldı. İkincisi **2014'te**.

Sıralamaya dikkat: izin 2006, uygulama 2007, birinci tavanın kalkması
2009, ikincisinin 2014. Dört ayrı karar, sekiz yıla yayılmış. Suyun
topraktan ayrılması bir reform değil, bir dizi.

Dizinin son halkası 20 Kasım 2023'te geldi. O tarihte Su Kanunu'nda
yapılan değişiklikle, bir su payını araziyle resmen **birleştirme**
imkânı kanundan çıkarıldı. Sicil gerekçesini de yazıyor: tavanlar artık
yürürlükte olmadığı için birlikteliğin yönetsel bir işlevi kalmamıştı ve
suyun nerede kullanılacağının anlamlı bir göstergesi olmaktan çıkmıştı.
Giderek daha çok kişi payını, resmî birliktelik kurmadan, başka bir onay
yoluyla araziye bağlı tutmayı tercih ediyordu.$dsr$, $dsr$The provision that made the separation of water from land possible was
inserted into the Act in 2005. The inserting statute is the Water (Resource
Management) Act 2005; it received assent on 7 December 2005. Its
forty-first section places into the Water Act the provision governing the
issuing and nature of the share. That provision commenced on 3 August 2006,
by the hundred and ninety-first Special Gazette.

But the separation did not happen that day.

In northern Victoria the separation was implemented on **1 July 2007**, and
in describing that day the register says this in its own report: when
unbundling occurred, all water shares were still associated with land. The
law opened a door and nobody walked through it. Holders **could choose** to
disassociate.

Nor was the choice unrestricted. There were two caps. The first: at most ten
per cent of a system's share volume could be owned without being linked to
land. The second: at most four per cent of an irrigation area's water could
be moved out of the area in a year. The first cap was abolished in **2009**.
The second in **2014**.

Note the sequence: permission in 2006, implementation in 2007, the first cap
lifted in 2009, the second in 2014. Four separate decisions spread over
eight years. The separation of water from land was not a reform but a
series.

The last link in that series arrived on 20 November 2023. Amendments to the
Water Act made on that date removed from the statute the ability to
formally **associate** a water share with land. The register gives its
reasoning too: with the caps no longer in force, association had lost its
administrative function and had ceased to be a meaningful indication of
where water would be used. More and more holders were choosing to keep a
share linked to land through a different approval, without forming a formal
association at all.$dsr$, array['ayrisma_zamani']::text[], 'belge', $dsr${"url":"https://tarimportali.net/dosya/avustralya/avustralya_goulburn_benti.jpg","atif":"Mattinbgn (talk · contribs) — CC BY 3.0","kaynak":null,"alt_tr":"Goulburn Bendi, Goulburn nehri. Kapaklar ne kadar suyun aşağı geçeceğini belirliyor.","alt_en":"Goulburn Weir on the Goulburn River. The gates determine how much water passes downstream."}$dsr$::jsonb),
  (6, $dsr$Megalitrenin fiyatı$dsr$, $dsr$The price of a megalitre$dsr$, $dsr$Bir şeyin mülk olup olmadığını anlamanın en kısa yolu fiyatına bakmaktır.
Kuzey Victoria'da yüksek güvenilirlikli su payının devir fiyatı sicilin
kaydında, medyan olarak, yıl yıl duruyor.

2008-09'da megalitresi iki bin yüz yetmiş beş Avustralya doları. Sonra
düşüyor: 2010-11'de bin dokuz yüz kırk, 2012-13'te bin beş yüz,
2013-14'te **bin üç yüz seksen** — serinin en düşüğü.

Oradan sonra yükseliş başlıyor ve durmuyor. 2015-16'da iki bin dört yüz,
2017-18'de iki bin sekiz yüz elli, 2018-19'da üç bin yedi yüz,
2019-20'de dört bin sekiz yüz. Zirve 2022-23'te: megalitresi **beş bin
dolar**. 2023-24'te dört bin beş yüze geriliyor.

En düşük yıldan zirveye **üç virgül altı kat**. Dokuz yıl.

Bir karşılaştırma daha var ve o da öğretici. Düşük güvenilirlikli pay —
yani ancak bol yıllarda su gören pay — 2008-09'da iki yüz dolardı,
2023-24'te sekiz yüz elli. Aynı dönemde yüksek güvenilirlikli payın
kaç katıydı diye bakarsanız: 2010-11'de neredeyse on üç katı, 2023-24'te
beş katından biraz fazla. Yani güvenilirliğin primi azalmış; kuraklıkta
bile su görmeyen pay bile değerlenmiş.

Bu fiyatların okuru yanıltabilecek bir yanı var. Beş bin dolar bir
megalitrenin fiyatı değil; bir megalitreyi **her yıl** alma hakkının
fiyatı. Yani bir gelir akışının bugünkü değeri. Bir çiftçinin yüz
megalitrelik payı, zirve fiyatında beş yüz bin dolarlık bir varlık
demek — ve bu, Kısım 3A'nın ipotek hükümlerinin neden yedi yerde
geçtiğini açıklıyor.

Bu rakamlar aynı zamanda bölgeler arası medyan. Medyan, bölgeler
arasındaki ayrışmayı gizler; Barmah'ın aşağısında ne olduğu ayrı bir
bölümün konusu.$dsr$, $dsr$The shortest way to tell whether something is property is to look at its
price. In northern Victoria the transfer price of a high-reliability water
share sits in the register's records, as a median, year by year.

In 2008-09 it was two thousand one hundred and seventy-five Australian
dollars a megalitre. Then it falls: one thousand nine hundred and forty in
2010-11, one thousand five hundred in 2012-13, **one thousand three hundred
and eighty** in 2013-14 — the lowest point in the series.

After that the rise begins and does not stop. Two thousand four hundred in
2015-16, two thousand eight hundred and fifty in 2017-18, three thousand
seven hundred in 2018-19, four thousand eight hundred in 2019-20. The peak
comes in 2022-23: **five thousand dollars** a megalitre. In 2023-24 it eases
back to four thousand five hundred.

From the lowest year to the peak, **three point six times**. Nine years.

There is a second comparison, and it instructs as well. A low-reliability
share — one that receives water only in abundant years — was two hundred
dollars in 2008-09 and eight hundred and fifty in 2023-24. Measured against
the high-reliability share: almost thirteen times cheaper in 2010-11, a
little over five times cheaper in 2023-24. The premium on reliability
narrowed; even the share that goes dry in a drought gained value.

These prices carry something that can mislead a reader. Five thousand
dollars is not the price of a megalitre; it is the price of the right to
take a megalitre **every year**. It is the present value of an income
stream. A farmer's hundred-megalitre share, at the peak price, is a
five-hundred-thousand-dollar asset — which explains why the mortgage
provisions of Part 3A appear in seven places.

These are also medians across the region, and a median conceals divergence
between trading zones. One such divergence matters enough that it has a
section of its own further on.$dsr$, array['kalici_hakkin_fiyati']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/avustralya/avustralya_mildura_bagi.jpg","atif":"Longhair at English Wikipedia — Public domain","kaynak":null,"alt_tr":"Mildura'da bağ. Çok yıllık bahçe, parasını her yıl su alarak kazanıyor.","alt_en":"Vines at Mildura. Perennial horticulture earns its return by buying water every year."}$dsr$::jsonb),
  (7, $dsr$Çevre bir hak sahibi oldu$dsr$, $dsr$The environment became a holder$dsr$, $dsr$Kuzey Victoria'nın su defterinde 2000-01'de çevrenin hiç hakkı yoktu.
2023-24'te yedi yüz kırk yedi gigalitresi var — toplamın yüzde yirmi
dokuz virgül yedisi. Toprağa bağlı özel paydan sonra en büyük ikinci
kalem, ve tarım dışındaki en büyük kalem.

Burada olan şey, su piyasasının kurulmasının en az beklenen sonucu.
Suyu alınıp satılabilir bir mülk haline getirdiğinizde, onu **satın
alabilecek** yeni bir alıcı sınıfı da yaratıyorsunuz. Ve o alıcılardan
biri, suyu kullanmak için değil, nehirde bırakmak için alıyor.

Çevrenin payı tek bir seferde oluşmamış. Seri, artışın kademeli olduğunu
gösteriyor: 2009-10'da yüz altmış gigalitre, 2011-12'de dört yüz altmış
üç, 2014-15'te altı yüz beş, 2018-19'da yedi yüz otuz iki. Son beş yılda
yedi yüz otuz iki ile yedi yüz kırk yedi arasında, neredeyse yatay.

Toplam hakkın kendisi de bu arada büyüdü — 2000-01'de iki bin iki yüz
seksen üç gigalitre, 2023-24'te iki bin beş yüz on beş. Sicil bu artışın
bir bölümünü bir altyapı projesi kapsamında kurtarılan suyun hak
değişikliklerine yansımasına bağlıyor: aynı dönemde kuzey Victoria'daki
yüksek güvenilirlikli pay hacmi yüz yirmi dokuz gigalitre arttı. Yani
defterin toplamı sabit bir pastanın bölüşümü değil; pasta da değişiyor.

Çevrenin hak sahibi olması, dosyanın başındaki cümleye bir şey ekliyor.
Su payı yalnızca ticari bir varlık değil; kamusal bir amacın da
taşıyıcısı olabilen bir araç. Aynı sicil, aynı kayıt biçimi, aynı
devir kuralları — ama malik hanesinde bir çiftçi yerine bir çevre
kuruluşu yazıyor.$dsr$, $dsr$In northern Victoria's water ledger the environment held nothing in
2000-01. In 2023-24 it holds seven hundred and forty-seven gigalitres —
twenty-nine point seven per cent of the total. The second largest item after
privately held land-linked shares, and the largest outside farming.

What happened here is the least anticipated consequence of establishing a
water market. When you make water into a holding that can be bought and
sold, you also create a new class of buyer able to **buy** it. And one of
those buyers purchases water not to use it but to leave it in the river.

The environment's share did not form at once. The series shows a staged
rise: a hundred and sixty gigalitres in 2009-10, four hundred and sixty-three
in 2011-12, six hundred and five in 2014-15, seven hundred and thirty-two in
2018-19. Over the last five years it moves between seven hundred and
thirty-two and seven hundred and forty-seven — nearly flat.

The total entitlement itself also grew over the period: two thousand two
hundred and eighty-three gigalitres in 2000-01, two thousand five hundred
and fifteen in 2023-24. The register attributes part of that growth to
entitlement changes reflecting water recovered under an infrastructure
project: over the same period the volume of high-reliability shares in
northern Victoria increased by one hundred and twenty-nine gigalitres. The
ledger's total is not the division of a fixed pie; the pie changes too.

The environment holding entitlement adds something to the sentence at the
start of this dossier. A water share is not only a commercial asset; it is
an instrument capable of carrying a public purpose. The same register, the
same form of record, the same transfer rules — but in the owner's column
stands an environmental body instead of a farmer.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/avustralya/avustralya_kerang_kugu.jpg","atif":"Gypsy Denise — CC BY-SA 4.0","kaynak":null,"alt_tr":"Kerang Gölleri, Victoria. Çevrenin elindeki su hakkı bu tür sulak alanlara bırakılmak üzere tutuluyor.","alt_en":"The Kerang Lakes, Victoria. Entitlement held by the environment is kept to be released into wetlands such as these."}$dsr$::jsonb),
  (8, $dsr$Arazinin verdiği, çiftçinin kullandığı$dsr$, $dsr$What the land gives, what the farmer uses$dsr$, $dsr$Kuzey Victoria'da iki rakam yan yana tutuluyor: toprağa bağlı yüksek
güvenilirlikli hakkın hacmi, ve o yıl fiilen kullanılan su. İkisinin
oranı piyasanın ne iş yaptığını gösteriyor.

2004-05'te toprağa bağlı hak iki bin iki yüz elli iki gigalitre,
kullanım iki bin yüz elli bir. Oran yüzde doksan altı. Arazinin verdiği
su, kullanılan sudan biraz fazla; piyasaya pek ihtiyaç yok.

2010-11'de hak bin sekiz yüz on üç gigalitre, kullanım yedi yüz elli
bir. Oran yüzde kırk bir — serinin en düşüğü. Çiftçiler haklarının
yarısından azını kullanmış.

2012-13'te tablo tersine dönüyor: hak bin beş yüz altmış dokuz
gigalitre, kullanım iki bin dört yüz iki. Oran yüzde yüz elli üç —
serinin en yükseği. Kullanılan su, toprağa bağlı hakkın bir buçuk katı.

2023-24'te hak bin iki yüz altmış iki, kullanım bin yedi yüz on altı.
Oran yüzde yüz otuz altı.

Yüzde yüzün üstündeki her rakam aynı şeyi söylüyor: arazinin verdiği su
yetmiyor ve fark başka yerden geliyor. O başka yer piyasa. 2023-24'te
kuzey Victoria'daki özel kullanıcıların su kaynağı dört kalemden
oluşuyor — önceki yıldan devreden dört yüz altmış yedi gigalitre, o yılın
yeni mevsimlik tahsisi bin altı yüz kırk, ticaretle net giren beş yüz
altmış altı, ve toplam kullanım bin yedi yüz on altı.

Net ticaret girişi beş yüz altmış altı gigalitre. Kullanımın üçte birine
yakını, o yıl o araziye ait olmayan sudan geliyor.

Bu bağımlılık bölgenin tamamına eşit dağılmamış. Sicil dört kullanıcı
grubunu ayrı ayrı hesaplıyor ve 2023-24 için şunu buluyor: aşağı Murray
bölgesinde nehirden doğrudan su çeken kullanıcıların kendi kaynakları —
yani o yılın yeni mevsimlik tahsisi olan iki yüz otuz yedi gigalitre ile
önceki yıldan devreden yirmi gigalitre — kullanımlarının yalnızca **yüzde
altmış birini** karşılıyor. Aynı hesap öteki üç grup için yüzde yüz kırk,
yüzde iki yüz yirmi üç ve yüzde yüz üç veriyor.

Rapor bu grubu kendi diliyle niteliyor: su kullanımını desteklemek için
ticarete en bağımlı özel kullanıcı grubu. Öteki üç grup çoğu yıl
ihtiyacını kendi tahsisiyle karşılıyor; biri karşılamıyor ve farkı her
yıl piyasadan alıyor.$dsr$, $dsr$Two figures are kept side by side in northern Victoria: the volume of
high-reliability entitlement linked to land, and the water actually used
that year. The ratio between them shows what the market is for.

In 2004-05 the land-linked entitlement was two thousand two hundred and
fifty-two gigalitres and use was two thousand one hundred and fifty-one. The
ratio: ninety-six per cent. The land gives slightly more water than is used;
there is little need for a market.

In 2010-11 the entitlement was one thousand eight hundred and thirteen
gigalitres and use was seven hundred and fifty-one. The ratio: forty-one per
cent — the lowest in the series. Farmers used less than half of what they
held.

In 2012-13 the picture inverts: entitlement one thousand five hundred and
sixty-nine gigalitres, use two thousand four hundred and two. The ratio: a
hundred and fifty-three per cent — the highest in the series. The water used
was half again the land-linked entitlement.

In 2023-24 the entitlement is one thousand two hundred and sixty-two and use
is one thousand seven hundred and sixteen. The ratio: a hundred and
thirty-six per cent.

Every figure above a hundred says the same thing: the land does not supply
enough water, and the difference comes from somewhere else. That somewhere
is the market. In 2023-24 the water sourced by private users in northern
Victoria came from four items — four hundred and sixty-seven gigalitres
carried over from the previous year, one thousand six hundred and forty in
new seasonal allocations for that year, five hundred and sixty-six entering
net through trade, and total use of one thousand seven hundred and sixteen.

Net trade in: five hundred and sixty-six gigalitres. Close to a third of all
use arrives as water that did not belong to that land that year.

That dependence is not spread evenly across the region. The register
calculates four user groups separately, and for 2023-24 it finds this: for
users drawing directly from the river in the lower Murray region, their own
sources — two hundred and thirty-seven gigalitres of new seasonal allocation
for the year plus twenty gigalitres carried over from the previous one —
cover only **sixty-one per cent** of their use. The same calculation gives a
hundred and forty, two hundred and twenty-three, and a hundred and three per
cent for the other three groups.

The report characterises this group in its own words: the private water user
group most dependent on trade to support their water use. Three groups meet
their needs from their own allocations in most years; one does not, and buys
the difference every year.$dsr$, array['hak_ve_kullanim']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/avustralya/avustralya_sulama_ciftligi.jpg","atif":"Liese Coulter, CSIRO — CC BY 3.0","kaynak":null,"alt_tr":"Kuru bir tarlada duran pivot sulama makinesi. Donanım yerinde; su ayrı bir mesele.","alt_en":"A centre-pivot irrigator standing on a dry paddock. The equipment is in place; the water is a separate question."}$dsr$::jsonb),
  (9, $dsr$Topraksız suyun işi ne$dsr$, $dsr$What landless water is for$dsr$, $dsr$Kuzey Victoria'da toprağa bağlı olmayan dört yüz elli altı gigalitrelik
pay bir soru doğuruyor: arazisi olmayan biri suyla ne yapıyor?

Sicil bunu da tutuyor. Toprağa bağlı olmayan özel paylara yapılan
tahsisin akıbeti dört kaleme ayrılıyor.

2007-08'de — ayrışmadan sonraki ilk tam yıl — o paylara yapılan tahsisin
kırk beş gigalitresi ticari olarak satılmış, yirmi bir gigalitresi
bedelsiz olarak başka bir hesaba devredilmiş, on yedi gigalitresi
silinmiş ya da buharlaşmış, otuz yedi gigalitresi ertesi yıla
devretmiş. Dördünün toplamı yüz yirmi gigalitre civarı.

2023-24'te aynı dört kalem: ticari satış **beş yüz otuz sekiz**
gigalitre, bedelsiz devir dört yüz elli dokuz, kayıp otuz, ertesi yıla
devreden iki yüz yetmiş.

Ticari satış on altı yılda on iki kat artmış. Bedelsiz devir yirmi iki
kat. İkisi birlikte bin gigalitrenin üzerinde — yani topraksız payların
tahsisi ağırlıkla **el değiştiriyor**, ya satılarak ya da bir hesaptan
başka bir hesaba aktarılarak.

Bedelsiz devir kalemi dikkat çekici. Fiyatı sıfır olan bir devir, piyasa
işlemi gibi görünmüyor; aynı işletmenin iki hesabı arasındaki aktarma da
olabilir, bir kira düzenlemesinin parçası da. Sicilin bu dosyadaki
kaynaklarında kalemin kırılımı yok, o yüzden ne olduğu üzerine cümle
kurulmuyor.

"Kayıp" kalemi küçük ama anlamlı: on yedi gigalitreden otuza çıkmış.
Kâğıt üzerinde var olup kullanılmayan ve silinen ya da buharlaşan su.
Bir mülkün, kullanılmadığında yok olabilmesi — taşınmaz mülkiyetinden
farkı bu. Arsa durur; su buharlaşır.$dsr$, $dsr$In northern Victoria the four hundred and fifty-six gigalitres of holdings
not linked to land raise a question: what does someone without land do with
water?

The register tracks this too. The fate of allocations made to private shares
not linked to land divides into four items.

In 2007-08 — the first full year after separation — forty-five gigalitres of
those allocations were sold commercially, twenty-one were transferred to
another account at no charge, seventeen were written off or lost to
evaporation, and thirty-seven were carried over to the following year. The
four together come to roughly a hundred and twenty gigalitres.

In 2023-24 the same four items read: commercial sales **five hundred and
thirty-eight** gigalitres, no-charge transfers four hundred and fifty-nine,
losses thirty, carried over two hundred and seventy.

Commercial sales grew twelvefold in sixteen years. No-charge transfers
twenty-twofold. Together they exceed a thousand gigalitres — meaning the
allocations on landless shares predominantly **change hands**, either by
sale or by moving from one account to another.

The no-charge item is notable. A transfer priced at zero does not look like a
market transaction; it might be a movement between two accounts of the same
business, or part of a leasing arrangement. The register's sources used here
do not break the item down, so nothing is asserted about what it is.

The "lost" item is small but telling: it rose from seventeen gigalitres to
thirty. Water that exists on paper, goes unused, and is written off or
evaporates. A holding that can cease to exist when it is not used — that is
the difference from ownership of real property. Land stays; water
evaporates.$dsr$, array['topraksiz_suyun_akibeti']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/avustralya/avustralya_mulwala_bosalan.jpg","atif":"Mattinbgn — CC BY-SA 3.0","kaynak":null,"alt_tr":"Mulwala Gölü düşük seviyede; su çekilince dip ve kütükler açığa çıkıyor.","alt_en":"Lake Mulwala at a low level; as the water draws back, the bed and old stumps are exposed."}$dsr$::jsonb),
  (10, $dsr$Altı bin beş yüz hesap$dsr$, $dsr$Six and a half thousand accounts$dsr$, $dsr$Piyasa kaç kişi? Sicil, Goulburn ve Murray sistemlerinde ticari işlem
yapan tahsis hesaplarını sayıyor.

2015-16'da altı bin sekiz yüz doksan dört hesap ticaret yapmış. 2023-24'te
altı bin beş yüz kırk dokuz. Arada dalgalanma var — 2018-19'da sekiz bin
yedi yüz on altıya çıkıp 2022-23'te beş bin iki yüz kırk dokuza
inmiş — ama ölçek sabit: binlerce hesap, on binlerce değil, yüzlerce de
değil.

Bu hesapların içinde sicilin ayrı saydığı bir grup var: "sık ticaret
yapan" hesaplar. 2015-16'da elli taneydiler, 2023-24'te seksen dört.
Toplamın yüzde bir virgül yirmi sekizi.

Bu noktada okurun aklına gelecek soruyu sicil kendisi sormuş ve
kendisi cevaplamış. Rapor, bu grubun işlem hacminin orantısız büyük bir
bölümünde yer aldığını söylüyor. Aynı cümlenin devamında da şunu
söylüyor: bu işlemlerin fiyatında, daha az sıklıkla ticaret yapanların
işlemlerine kıyasla sistematik bir farklılığa dair **kanıt yok**.

Yani kuzey Victoria'da seksen dört hesap hacmin büyük kısmını çeviriyor,
ama sicilin ölçümüne göre farklı bir fiyattan çevirmiyor. Bulguyu
yayımlayan da piyasayı işleten idarenin kendisi — yani kendi
piyasasındaki en görünür aktör grubunu ölçüp fark bulamadığını yazıyor.

Piyasanın bir aracı katmanı da var. Temmuz 2026'daki Barmah açılışında
Victoria'ya gelen başvuruların yetmiş üçü **aracı portalı** üzerinden
geldi — toplam on yedi bin altı yüz kırk beş virgül beş megalitre — altmış
beşi ise çevrim içi ticaret üzerinden, on üç bin sekiz yüz otuz iki
virgül üç megalitre. Yani aracıdan gelen başvurular hem sayıca hem
hacimce daha ağır.

İşlem ölçeği de değişmiş. 2007-08'de on yedi bin yedi yüz üç işlemle
beş yüz otuz dokuz gigalitre el değiştirmiş; ortalama parça otuz
megalitre. 2023-24'te on üç bin yedi yüz yetmiş altı işlemle iki bin
dört yüz elli dört gigalitre; ortalama parça yüz yetmiş sekiz
megalitre. Daha az işlem, çok daha büyük parçalar.$dsr$, $dsr$How many people is the market? The register counts the allocation accounts
that traded commercially in the Goulburn and Murray systems.

In 2015-16 six thousand eight hundred and ninety-four accounts traded. In
2023-24, six thousand five hundred and forty-nine. There is fluctuation in
between — up to eight thousand seven hundred and sixteen in 2018-19, down to
five thousand two hundred and forty-nine in 2022-23 — but the order of
magnitude holds: thousands of accounts, not tens of thousands and not
hundreds.

Within those accounts the register counts a group separately: "frequent
trader" accounts. There were fifty in 2015-16 and eighty-four in 2023-24.
One point two eight per cent of the total.

At this point the register asked the question a reader would ask, and
answered it itself. The report says this group is involved in a
disproportionately large share of traded volume. In the continuation of the
same sentence it says there is **no evidence** of systematic differences in
the price of those trades compared with trades by less frequent traders.

So in northern Victoria eighty-four accounts turn over most of the volume
but, by the register's measurement, not at a different price. The body
publishing that finding is the one that operates the market — it measured
the most visible group of actors in its own market and recorded that it
found no difference.

The market has an intermediary layer as well. At the July 2026 Barmah
opening, seventy-three of the applications received in Victoria came through
the **broker portal** — seventeen thousand six hundred and forty-five point
five megalitres in total — and sixty-five through online trading, thirteen
thousand eight hundred and thirty-two point three megalitres. Applications
arriving through brokers were the heavier side both in number and in volume.

The scale of transactions has changed too. In 2007-08, five hundred and
thirty-nine gigalitres changed hands across seventeen thousand seven hundred
and three transactions; the average parcel was thirty megalitres. In 2023-24,
two thousand four hundred and fifty-four gigalitres across thirteen thousand
seven hundred and seventy-six transactions; the average parcel was a hundred
and seventy-eight megalitres. Fewer transactions, far larger parcels.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/avustralya/avustralya_bugday_tarlasi.jpg","atif":"malleefarmscapes — CC BY 2.0","kaynak":null,"alt_tr":"Victoria'da buğday tarlaları.","alt_en":"Wheat fields in Victoria."}$dsr$::jsonb),
  (11, $dsr$Nehrin daraldığı yer$dsr$, $dsr$Where the river narrows$dsr$, $dsr$Şimdiye kadar anlatılan her şey hukuk ve defterdi. Bu bölümde coğrafya
söze giriyor ve hukuku yeniyor.

Murray nehri, Barmah denen bir noktada daralıyor. Açılış raporunun
ifadesiyle, bu darlık nehrin akışını günde yaklaşık **yedi bin
megalitre** ile sınırlıyor.

Bu cümlenin sonucu şudur: suyun hakkı devredilebilir, fiyatı vardır,
sicile kayıtlıdır, ipotek edilebilir — ama su nehirden geçmek
zorundadır. Ve nehrin o noktadaki kapasitesi bir hukuk kurumu değil, bir
yatak genişliği.

Dolayısıyla aşağı taraftaki bir alıcı yukarı taraftaki bir satıcıdan su
aldığında, sözleşme kurulsa bile suyun fiilen taşınması ayrı bir izne
bağlı. Ve o izin, darlıktan geçebilecek hacimle sınırlı.

Temmuz 2026'da bu kapasite sayıyla ilan edildi: 2 Temmuz sabahı saat
yedide Barmah için açılan ticaret imkânı **yirmi dört bin yüz yirmi bir
virgül üç megalitre**.

Aynı gün kapanan başvuru penceresine iki eyaletten iki yüz on dört uygun
başvuru geldi ve bu başvuruların toplam hacmi **altmış yedi bin dört yüz
kırk beş virgül iki megalitre** oldu. Rapor bunu kendi diliyle
değerlendiriyor: uygun başvuruların toplam hacmi, mevcut ticaret
imkânını belirgin biçimde aştı.

Kapasitenin **iki virgül sekiz katı** talep.

Başvuruların boyutu da anlatıcı. Victoria'dan gelen uygun başvuruların
hacmi yirmi virgül dört megalitreyle iki bin dört yüz seksen dört virgül
dört megalitre arasında değişiyor; ortancası **yüz on megalitre**,
ortalaması iki yüz otuz. Yani kuyruktaki tipik başvuru büyük bir yatırım
fonu değil, orta ölçekli bir sulayıcı.

Darlığın bir de fiyat imzası var ve bu, kuradan daha sessiz ama daha
kalıcı bir etki.

Sicil, su payı fiyatlarının tarihsel olarak farklı su kaynakları arasında
birbirine yakın seyrettiğini söylüyor. 2018'den sonra bu yakınlık bozulmuş
ve bozulma en çok tek bir yerde olmuş: Barmah'ın **aşağısındaki** Murray
bölgesinde. Orada düşük güvenilirlikli su payının fiyatı Temmuz 2018'de
megalitresi **dört yüz kırk dört dolar** iken Haziran 2024'te **bin
sekiz yüz altmış bir dolara** çıkmış. Dört virgül iki kat; ve raporun
ifadesiyle artış hiçbir bölgede bu kadar belirgin değil.

Rapor nedeni iki etkene bağlıyor. Birincisi, Barmah'ın aşağısında çok
yıllık bahçe tarımının büyümesi ve bu tarımın suya yüksek ödeme isteği.
İkincisi — ve dosya için asıl olan — bölgeye tahsis ticareti kısıtlarının
**artması**.

Yani darlık, aşağıda olan suyu değerli kılıyor. Yukarıdan yeni su
gelmesi zorlaştıkça, zaten aşağıda bulunan hakkın fiyatı yükseliyor.
Fiziksel bir yatak genişliği, bir mülkiyet hakkının fiyatına geçiyor.

İki virgül sekiz kat talep, yedi bin megalitrelik bir yatak, ve yüz on
megalitrelik bir ortanca başvuru. Sıra birine verilecek. Soru, kime.$dsr$, $dsr$Everything described so far has been law and ledger. In this section
geography enters, and it defeats the law.

The Murray narrows at a place called Barmah. In the words of the opening
report, that narrowing restricts the river's flow to just around **seven
thousand megalitres a day**.

The consequence of that sentence is this: the right to water is
transferable, it has a price, it is recorded in a register, it can be
mortgaged — but the water has to pass through the river. And the river's
capacity at that point is not a legal institution. It is the width of a bed.

So when a buyer downstream purchases water from a seller upstream, even with
a contract concluded, physically moving the water requires a separate
approval. And that approval is limited by the volume the narrowing can pass.

In July 2026 this capacity was announced as a figure: the total Barmah trade
opportunity made available at seven o'clock on the morning of 2 July was
**twenty-four thousand one hundred and twenty-one point three megalitres**.

Into the application window that closed the same day came two hundred and
fourteen eligible applications from two states, with a total volume of
**sixty-seven thousand four hundred and forty-five point two megalitres**.
The report assesses this in its own language: the total volume of eligible
applications significantly exceeded the available trade opportunity.

Demand at **two point eight times** capacity.

The size of the applications tells its own story. Eligible Victorian
application volumes ranged from twenty point four megalitres to two thousand
four hundred and eighty-four point four; the median was **a hundred and ten
megalitres** and the average two hundred and thirty. The typical applicant
in the queue is not a large investment fund but a mid-sized irrigator.

The narrowing has a price signature too, and this effect is quieter than the
lottery but more lasting.

The register says water share prices have historically run fairly close to
one another across different water sources. After 2018 that closeness broke
down, and it broke down most in one place: the Murray region **downstream**
of Barmah. There, the price of a low-reliability water share rose from **four
hundred and forty-four dollars** a megalitre in July 2018 to **one thousand
eight hundred and sixty-one dollars** in June 2024. Four point two times;
and in the report's words, the increase was most significant there of
anywhere.

The report attributes this to two factors. First, the growth of perennial
horticulture downstream of Barmah and that sector's high willingness to pay
for water. Second — and this is the one that matters for the dossier —
**increasing** restrictions on allocation trade into the region.

So the narrowing makes the water already below it valuable. As new water
from upstream becomes harder to bring in, the price of the entitlement
already sitting downstream rises. The width of a river bed passes into the
price of a property right.

Demand at two point eight times capacity, a bed of seven thousand
megalitres, and a median application of a hundred and ten. The queue will be
given to someone. The question is to whom.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/avustralya/avustralya_barmah_murray.jpg","atif":"AndreB94 — CC BY-SA 4.0","kaynak":null,"alt_tr":"Murray nehri, Barmah'ta. Nehrin bu noktadaki genişliği bir hukuk kurumu değil; aşağı geçebilecek su miktarını o belirliyor.","alt_en":"The Murray at Barmah. The river's width at this point is not a legal institution; it is what determines how much water can pass downstream."}$dsr$::jsonb),
  (12, $dsr$Sıra kurayla belirleniyor$dsr$, $dsr$The queue is decided by lot$dsr$, $dsr$Cevap, dosyanın en şaşırtıcı cümlesi: sıra kurayla belirleniyor.

İşleyiş şöyle. Kapasite sabah yedide ilan ediliyor. Başvuru penceresi
açılıyor; suyunu aşağı taşımak isteyen herkes başvuruyor — bir kısmı
aracı portalından, bir kısmı çevrim içi ticaret üzerinden. Pencere
kapandıktan sonra başvurular uygunluk denetiminden geçiyor; kurallara
uymayanlar kuraya hiç girmeden reddediliyor.

Sonra, raporun kendi ifadesiyle, uygun başvurular **işlenme sırasını
saptamak için rastgeleleştiriliyor.**

Önce başvuran önce geçmiyor. Daha çok ödeyen önce geçmiyor. Daha büyük
hacim isteyen önce geçmiyor. Sıra tesadüfe bırakılıyor ve sonra
başvurular o sırayla işleniyor. Kapasite tükendiğinde geri kalanlar
reddediliyor — kuralı çiğnedikleri için değil, kurada arkada
kaldıkları için.

Barmah darlığı başvurularının çekilişini Victoria'nın ilgili bakanlığı
ile Yeni Güney Vales'in su kurumu **birlikte** yapıyor. İki eyalet, aynı
masada.

Sicil bu yöntem için kendi raporunda bir nitelik kullanıyor ve kullandığı
nitelik önemli: rastgeleleştirme yaklaşımı, ticaret açılışlarındaki
aksaklıkları yönetmek üzere **geçici bir çözüm** olarak uygulanmaya
başlandı.

Yani suyu sicile bağlayan, fiyatlandıran ve ipotek edilebilir hale
getiren idare, piyasanın fiziksel olarak işleyemediği noktada fiyat
mekanizmasını bir kenara bırakıp kura çekiyor — ve bunun kalıcı bir
çözüm olduğunu da iddia etmiyor.

Bir açık artırma kurulabilirdi. Kapasiteyi en yüksek teklif verene
satmak, iktisadi olarak savunulabilir bir seçenekti. Bu dosyanın
kaynaklarında o seçeneğin neden tercih edilmediğine dair bir gerekçe yok;
elimizde yalnızca tercih edilenin ne olduğu var.$dsr$, $dsr$The answer is this dossier's most surprising sentence: the queue is decided
by lot.

The mechanism runs as follows. Capacity is announced at seven in the
morning. The application window opens; everyone wishing to move water
downstream applies — some through the broker portal, some through online
trading. After the window closes the applications are checked for
eligibility; those that fail the rules are refused without entering the draw
at all.

Then, in the report's own words, the eligible applications are
**randomised to determine the order in which they will be processed.**

First to apply does not go first. Whoever pays most does not go first.
Whoever wants the larger volume does not go first. The order is left to
chance, and the applications are then processed in that order. When capacity
is exhausted the rest are refused — not for breaking a rule, but for falling
late in the draw.

The draw for Barmah narrows applications is conducted **jointly** by the
relevant Victorian department and the water authority of New South Wales.
Two states at the same table.

The register applies a characterisation to this method in its own report,
and the characterisation matters: the randomisation approach has been
implemented as an **interim solution** to manage disruptions to trade
openings.

So the administration that bound water to a register, priced it and made it
mortgageable sets the price mechanism aside at the point where the market
cannot physically function, and draws lots — without claiming that this is a
permanent answer.

An auction could have been constructed. Selling the capacity to the highest
bidder was an economically defensible option. This dossier's sources contain
no reasoning for why that option was not taken; what we have is only what
was.$dsr$, array['kura_akisi']::text[], 'akis', $dsr${"url":"https://tarimportali.net/dosya/avustralya/avustralya_barmah_ormani.jpg","atif":"Neuronicles — CC BY-SA 4.0","kaynak":null,"alt_tr":"Barmah Ormanı, Victoria.","alt_en":"The Barmah Forest, Victoria."}$dsr$::jsonb),
  (13, $dsr$Aynı gün, iki güzergâh$dsr$, $dsr$The same day, two routes$dsr$, $dsr$Kuranın ne yaptığı, aynı gün yapılan iki açılış yan yana konduğunda
görünüyor. Çünkü 2 Temmuz 2026'da iki ayrı güzergâh için iki ayrı pencere
açıldı ve ikisinin sırası da aynı yöntemle, kurayla belirlendi.

Birinci güzergâh Goulburn sisteminden Murray'e. İlan edilen kapasite
**yüz on iki bin sekiz yüz yirmi yedi virgül dokuz megalitre**. Kuraya
giren uygun başvuru sayısı iki yüz seksen altı. Onaylanan **iki yüz
seksen iki**. Reddedilen dört. Onay oranı **yüzde doksan sekiz virgül
altı**. Gelen başvuruların hacmi kapasiteyi yalnızca **bir virgül sıfır
yedi kat** aşmış.

İkinci güzergâh Barmah darlığından geçiyor. Kapasite **yirmi dört bin yüz
yirmi bir virgül üç megalitre**. Kuraya giren uygun başvuru iki yüz on
dört. Onaylanan **altmış iki**. Onay oranı **yüzde yirmi dokuz**. Talep
kapasitenin **iki virgül sekiz katı**.

Aynı gün. Aynı idare. Aynı kura yöntemi. Aynı gözlemci kurum. Yüzde
doksan sekiz virgül altıya karşı yüzde yirmi dokuz.

Aradaki tek fark fiziksel: birinde nehir daralıyor, ötekinde daralmıyor.

Victoria'nın kendi başvurularına ayrıca bakıldığında tablo daha da
keskinleşiyor. Barmah için Victoria'ya yüz otuz sekiz başvuru gelmiş,
yüz otuz altısı kuraya girmiş, otuz üçü onaylanmış, **yüz üçü
reddedilmiş**. Yüz üç başvurunun her biri kurallara uygundu.

Bu iki sütun, piyasanın sınırının nerede olduğunu gösteriyor. Piyasa,
kapasite bol olduğu sürece neredeyse herkesi geçiriyor. Kapasite
kıtlaştığında ise fiyat değil, kura karar veriyor.$dsr$, $dsr$What the draw does becomes visible when two openings held on the same day are
set side by side. On 2 July 2026 two separate windows opened for two separate
routes, and the order in both was decided by the same method.

The first route runs from the Goulburn system to the Murray. Announced
capacity: **a hundred and twelve thousand eight hundred and twenty-seven
point nine megalitres**. Eligible applications entering the draw: two hundred
and eighty-six. Approved: **two hundred and eighty-two**. Refused: four.
Approval rate: **ninety-eight point six per cent**. The volume of
applications exceeded capacity by only **one point zero seven times**.

The second route passes the Barmah narrows. Capacity: **twenty-four thousand
one hundred and twenty-one point three megalitres**. Eligible applications:
two hundred and fourteen. Approved: **sixty-two**. Approval rate: **twenty-nine
per cent**. Demand at **two point eight times** capacity.

The same day. The same administration. The same method of draw. The same
observing body. Ninety-eight point six per cent against twenty-nine.

The only difference between them is physical: in one the river narrows, in
the other it does not.

Looking separately at Victoria's own applications sharpens the picture
further. A hundred and thirty-eight applications were received in Victoria
for Barmah, a hundred and thirty-six entered the draw, thirty-three were
approved and **a hundred and three were refused**. Every one of those
hundred and three complied with the rules.

These two columns show where the market's limit lies. So long as capacity is
ample, the market passes nearly everyone through. When capacity grows scarce,
it is not price that decides but the draw.$dsr$, array['iki_acilis']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/avustralya/avustralya_goulburn_nehri.jpg","atif":"Yun Huang Yong — CC BY 2.0","kaynak":null,"alt_tr":"Goulburn nehri, Victoria — Temmuz 2026'daki iki ticaret açılışından birinin güzergâhı.","alt_en":"The Goulburn River, Victoria — the route of one of the two trade openings of July 2026."}$dsr$::jsonb),
  (14, $dsr$Rekabet kurumunun imzası$dsr$, $dsr$The competition regulator's signature$dsr$, $dsr$Kura 3 Temmuz 2026'da çekildi — başvuruların alındığı günün ertesi günü.
Ve çekilişin başında, Avustralya Rekabet ve Tüketici Kurumu'ndan bir
temsilci vardı.

Kurumun Su Birimi Genel Müdür Vekili, 3 Ağustos 2026 tarihli yazısında
dört madde halinde beyanda bulunuyor. Birincisi: Su Birimi'nden bir
temsilci, Victoria'nın bakanlığı ile Yeni Güney Vales su kurumu
tarafından yürütülen ticaret rastgeleleştirme işlemini 3 Temmuz 2026
Cuma günü gözlemledi. İkincisi: aynı temsilci işlemin **kaydını**
sonradan inceledi ve kaydın, gözlemlenen işlemin gerçek, tam ve doğru
bir temsili olduğunu doğruladı. Üçüncüsü: temsilci, rastgeleleştirme
işlemi sırasında aracın **çıktısında herhangi bir düzenleme ya da
değişiklik gözlemlemedi.**

Üçüncü maddenin üzerinde durmak gerekiyor. Bir devlet kurumu, başka iki
devlet kurumunun çektiği kurayı izliyor, kaydını yeniden seyrediyor, ve
çıktıya dokunulmadığını yazılı olarak beyan ediyor.

Bu, bir usul ayrıntısı olarak okunabilir. Ama ne olduğuna bakmak daha
verimli: kura, kaydı alınan bir işlem.

Kurumun orada bulunma gerekçesi bu dosyanın kaynaklarında yazılı değil;
elimizde yalnızca bulunduğu ve ne beyan ettiği var. Ama hangi kurumun
geldiğini kaydetmek gerekiyor: Barmah'tan geçme hakkını dağıtan çekilişi
izlemeye bir su kurumu değil, rekabet ve tüketici kurumu gelmiş.

Dosyanın başındaki cümle buraya geldiğinde tamamlanıyor. Suyun sicili
var, fiyatı var, ipoteği var. Ve en kritik noktada, o suyun kime
geçeceğini bir çekiliş belirliyor; çekilişi de rekabet kurumu izliyor.$dsr$, $dsr$The draw was conducted on 3 July 2026 — the day after applications were
received. And at its head stood a representative of the Australian
Competition and Consumer Commission.

In a letter dated 3 August 2026 the Commission's Acting General Manager of
the Water Branch makes a statement in four numbered paragraphs. First: a
representative from the Water Branch observed the trade randomisation process
conducted by Victoria's department and the New South Wales water authority on
Friday 3 July 2026. Second: the same representative subsequently reviewed a
**recording** of that process and confirmed the recording to be a true,
complete and accurate representation of the process observed. Third: the
representative did not observe any **editing or change to the output** of the
randomisation tool during the process.

The third paragraph is worth dwelling on. One arm of government watches a
draw conducted by two others, reviews the recording of it afterwards, and
attests in writing that the output was not touched.

This can be read as a procedural detail. It is more productive to look at
what it is: the draw is a recorded process.

The reasoning behind the Commission's presence is not written down in this
dossier's sources; what we have is only that it was present and what it
declared. But it is worth recording which body came: the one that attended
the draw allocating the right to pass Barmah was not a water authority but
the competition and consumer regulator.

The sentence at the start of this dossier completes itself here. Water has a
register, a price, a mortgage. And at the most critical point, who it passes
to is settled by a draw — with the competition regulator watching.$dsr$, '{}'::text[], 'belge', null),
  (15, $dsr$Kuraklığı kimse ilan etmiyor$dsr$, $dsr$Nobody declares a drought$dsr$, $dsr$Avustralya'da kuraklıkla ilgili en şaşırtıcı kurumsal olgu, kuraklığın
ilan edilmemesi.

Meteoroloji Bürosu kendi sayfasında bunu açıkça yazıyor: Avustralya
Hükûmeti'nin bir kurumu olarak Büro kuraklık ilan etmiyor, ve Avustralya
Hükûmeti kuraklık ilanı yapmıyor. Kuraklık politikalarını ve
programlarını eyalet ve bölge yönetimleri kendi yetki alanlarında
yürütüyor ve eşgüdümlüyor.

Büro kuraklığı tanımlıyor da. Tanım şöyle: normal kullanım için yeterli
su bulunmayan, uzun süreli ve olağan dışı kuru dönem. Ve hemen ardından
bir uyarı geliyor — kuraklık yalnızca az yağış değil; öyle olsaydı iç
Avustralya'nın büyük bölümü neredeyse her zaman kurak sayılırdı. Büro
kuraklık koşullarını genellikle en az üç aylık dönemler üzerinden
ölçüyor, ama süreye göre ad da değişiyor: haftalarla ölçülene ani
kuraklık, aylarla ölçülene meteorolojik kuraklık, birkaç yıla
yayılana hidrolojik kuraklık deniyor.

Büro ilan etmiyor ama ölçüyor ve yayımlıyor. Kuraklık Bildirisi adlı
belgenin arşivinde 10 Ocak 2000 ile 4 Ağustos 2016 arasında **yüz doksan
iki** bildiri duruyor.

Arşivin en ilginç yanı bildirilerin kendisi değil, yayımlanmadığı aylar.
Ekim 2011'den Mayıs 2012'ye kadar **sekiz ay** üst üste bildiri
yayımlanmamış. Büro, o aylara ait sayfaları boş bırakmamış; sayfa var ve
üzerinde o ay için bildiri yayımlanmadığı yazıyor.

Burada iki şeyi ayırmak gerekiyor. Birincisi: 2011'de yayımlanan
bildiriler ağırlıkla **güneybatı Batı Avustralya'yı** anlatıyor —
Murray-Darling havzasını değil. Aynı dönemde doğuda yağış dönmüştü. Yani
"Avustralya'nın kuraklığı" diye tek bir olgudan söz etmek bu kayıtla
mümkün değil; Büro bölge bölge yazıyor.

İkincisi, iki defteri birbirine bağlama iştahı. Bildirisiz sekiz ay, su
yılı 2011-12'ye düşüyor ve o yılın kullanım oranı yüzde yüz on sekiz —
yani yüksek. Serinin en düşük oranı ise yüzde kırk bir ile bir önceki
yıl, 2010-11'de. Tarihler örtüşmüyor. Meteoroloji kaydı ile su
defterinin aynı dönemi anlatması, birinin ötekini açıkladığı anlamına
gelmiyor.$dsr$, $dsr$The most surprising institutional fact about drought in Australia is that
drought is not declared.

The Bureau of Meteorology states it plainly on its own pages: as an agency of
the Australian Government, the Bureau does not declare a drought, and the
Australian Government does not make drought declarations. State and territory
governments administer and coordinate drought policies and programs for their
own jurisdictions.

The Bureau does define drought. The definition: a prolonged, abnormally dry
period when there is not enough water available for normal use. A caution
follows immediately — drought is not simply low rainfall; if it were, much of
inland Australia would almost always be considered in drought. The Bureau
generally measures drought conditions over periods of at least three months,
and the name changes with the duration: measured in weeks it is flash
drought, in months meteorological drought, over several years hydrological
drought.

The Bureau does not declare, but it measures and publishes. The archive of
the document called the Drought Statement holds **a hundred and ninety-two**
statements between 10 January 2000 and 4 August 2016.

The most interesting thing in the archive is not the statements but the
months without them. From October 2011 to May 2012, for **eight** consecutive
months, no statement was issued. The Bureau did not leave those months blank;
the page exists, and on it stands a line recording that no statement was
issued for that month.

Two things must be kept apart here. First: the statements published during
2011 largely describe **southwest Western Australia** — not the
Murray-Darling Basin. Rainfall had returned in the east over the same period.
Speaking of "Australia's drought" as a single phenomenon is not possible from
this record; the Bureau writes region by region.

Second, the appetite to tie two ledgers together. The eight months without
statements fall in water year 2011-12, and that year's use ratio was a
hundred and eighteen per cent — which is high. The lowest ratio in the series,
forty-one per cent, belongs to the year before, 2010-11. The dates do not
line up. That the meteorological record and the water ledger describe the same
period does not mean that one explains the other.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/avustralya/avustralya_kuraklik_uydu.jpg","atif":"NASA image of NDVI anomaly by Jesse Allen using MODIS data provided by Inbal Reshef as part of the Global Agricultural Monitoring Project involving NASA, USDA’s Foreign Agricultural Service (FAS), and the University of Maryland. Assaf Anyamba from the Goddard Earth Sciences Technology Center, and James Crutchfield with FAS, contributed to the caption as part of the same partnership. More data and information about this joint project is available at Satellite Information for Agricultural Monitoring. — Public domain","kaynak":null,"alt_tr":"Doğu Avustralya'da bitki örtüsünün normalden sapması; kahverengi normalin altını, yeşil üstünü gösteriyor. Büro kuraklık ilan etmiyor, ölçüyor — ve ölçüm aynı anda bir bölgede kuru, başka bir bölgede yeşil olabiliyor.","alt_en":"Vegetation anomaly across eastern Australia; brown is below normal, green above. The Bureau does not declare drought, it measures it — and the measurement can be dry in one region and green in another at the same moment."}$dsr$::jsonb),
  (16, $dsr$Ülke ölçeğinde ne kadar su$dsr$, $dsr$How much water at national scale$dsr$, $dsr$Buraya kadarki bütün piyasa rakamları kuzey Victoria'ya aitti. Ülkenin
tamamı ne kadar su kullanıyor sorusu başka bir kaynağa, başka bir
kuruma ve başka bir yıla ait.

Meteoroloji Bürosu'nun ulusal su raporuna göre 2019-20'de Avustralya'da
tüketim amacıyla alınan toplam su **on dört bin iki yüz yetmiş
gigalitre**. Önceki yıla göre yüzde altı daha az.

Aynı rapor, Victoria ile Yeni Güney Vales'teki tarımsal su kullanımının
Avustralya'nın tarımsal su kullanımının yarısını oluşturduğunu
söylüyor. Yani bu dosyanın anlattığı bölge, ülkenin tarımsal suyunun
yarısını kullanan iki eyaletten birinin kuzeyi.

İki eyaletten birinin rakamı ayrıca veriliyor: Yeni Güney Vales'te
2019-20'de tarım için alınan su **iki bin dört yüz doksan gigalitre**.
Bu, aynı yıl ülke genelinde tüketime alınan on dört bin iki yüz yetmiş
gigalitrenin yaklaşık altıda biri — ve yalnızca bir eyaletin tarımı.

Depolama tarafı: 30 Haziran 2020'de ülkedeki depolarda yirmi üç bin yüz
kırk gigalitre su vardı — kapasitenin yüzde kırk altısı. 2019-20'nin
başında doğrudan su temini amaçlı toplam depolama kapasitesi elli bin
beş yüz gigalitreydi.

Piyasanın ulusal ölçeği için elimizde yalnızca bir aralık var. Büro'nun
su piyasası sayfası, Avustralya'daki su piyasalarının yıllık cirosunu
**tahmini bir ile yedi milyar dolar** arasında veriyor. Aralığın
genişliği kendi başına bir bilgi: ulusal ölçekte bu piyasanın
büyüklüğü, onu izleyen kurumun kendi ifadesiyle yedi kat belirsizlikle
biliniyor.

Bir zaman farkını da söylemek gerekiyor. Ulusal rakamlar 2019-20'ye
ait; Büro'nun bu raporunun daha yeni yılları yayımda değil. Piyasa
rakamları ise 2023-24'e kadar geliyor. Yani bu bölümdeki ülke ölçeği,
önceki bölümlerdeki piyasa ölçeğinden dört yıl geride ve ikisi aynı
yılın fotoğrafı değil.$dsr$, $dsr$Every market figure to this point has belonged to northern Victoria. The
question of how much water the whole country uses belongs to a different
source, a different body and a different year.

According to the Bureau of Meteorology's national water report, the total
water taken for consumptive use in Australia in 2019-20 was **fourteen
thousand two hundred and seventy gigalitres**. Six per cent less than the
year before.

The same report states that agricultural water use in Victoria and New South
Wales accounted for half of Australia's agricultural water use. The region
this dossier describes is therefore the northern part of one of the two
states that between them use half the country's agricultural water.

One of those two states is reported separately: water taken for agriculture in
New South Wales in 2019-20 was **two thousand four hundred and ninety
gigalitres**. That is roughly a sixth of the fourteen thousand two hundred and
seventy gigalitres taken for consumptive use nationally in the same year — and
it is one state's farming alone.

On the storage side: at 30 June 2020 the country's storages held twenty-three
thousand one hundred and forty gigalitres — forty-six per cent of capacity. At
the start of 2019-20 total storage capacity for direct water supply was fifty
thousand five hundred gigalitres.

For the national scale of the market we have only a range. The Bureau's water
market page gives annual turnover of water markets in Australia as an
**estimated one to seven billion dollars**. The width of the range is itself
information: at national scale the size of this market is known, on the
measuring body's own statement, to within a factor of seven.

A difference in timing has to be stated as well. The national figures belong
to 2019-20; more recent years of this Bureau report are not in publication.
The market figures run to 2023-24. The national scale in this section is four
years behind the market scale in the preceding ones, and the two are not
photographs of the same year.$dsr$, array['dosyanin_rakamlari']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/avustralya/avustralya_hume_baraji.jpg","atif":"Steve Bennett (stevage) — CC BY 3.0","kaynak":null,"alt_tr":"Hume Barajı, Murray nehri üzerinde.","alt_en":"The Hume Dam on the Murray River."}$dsr$::jsonb),
  (17, $dsr$Türkiye buradan ne görebilir$dsr$, $dsr$What Türkiye can see from here$dsr$, $dsr$Bu dosya bir model önermiyor. Avustralya'nın kurduğu şey belirli bir
coğrafyanın, belirli bir hukuk geleneğinin ve belirli bir federal
yapının ürünü. Ama aktarılabilir olan şey mekanizma değil, mekanizmanın
ortaya çıkardığı sorular.

Birinci soru ölçmeyle ilgili. Victoria'nın yapabildiği şeyin temeli bir
sicil: her payın maliki, hacmi, güvenilirlik sınıfı ve üzerindeki
takyidat kayıtlı. Suyun fiyatlanabilmesi, devredilebilmesi, hatta
çevre adına satın alınabilmesi bu kaydın varlığına bağlı. Bir ülke suyu
kim kullanıyor sorusunu parsel düzeyinde cevaplayamıyorsa, bunun
üzerine kurulacak hiçbir mekanizma işlemez.

İkinci soru ayrışmanın maliyetiyle ilgili. Kuzey Victoria'da suyun
yarısı toprağı terk etti ve kalıcı hakkın fiyatı dokuz yılda üçe
katlandı. Bu, suyu satın alabilen için bir fırsat, satmak zorunda kalan
için bir çıkış. Hangisi olduğu kimin elinde ne olduğuna bağlı.

Üçüncü soru en keskini ve dosyanın asıl dersi burada. Avustralya suyun
hukukunu kurdu, sicilini kurdu, piyasasını kurdu, fiyatını kurdu. Ve
bütün bunların sonunda, nehrin daraldığı noktada, elinde kalan yöntem
kura oldu. Fiziksel kapasite kıt olduğunda piyasanın cevabı yok; sıraya
kim girecek sorusunu piyasa cevaplamıyor.

Türkiye'nin havzalarında da taşıma kapasitesi sınırlı. Oradaki soru,
"su piyasası kurulsun mu" değil; kapasite yetmediğinde sıranın hangi
kurala göre belirlendiğinin yazılı olup olmadığı. Avustralya'da bu kural
yazılı, geçici olduğu kabul edilmiş, ve uygulaması bağımsız bir kurum
tarafından izleniyor.$dsr$, $dsr$This dossier proposes no model. What Australia built is the product of a
particular geography, a particular legal tradition and a particular federal
structure. What transfers is not the mechanism but the questions the
mechanism exposes.

The first question concerns measurement. The foundation of what Victoria can
do is a register: every share's owner, volume, reliability class and
encumbrances recorded. Water's being priceable, transferable, even
purchasable on behalf of the environment, depends on the existence of that
record. If a country cannot answer the question of who uses water at the level
of the parcel, no mechanism built on top of it will function.

The second question concerns the cost of separation. In northern Victoria half
the water left the land and the price of the permanent right tripled in nine
years. For anyone able to buy water that is an opportunity; for anyone forced
to sell it is an exit. Which of the two it is depends on what is in whose
hands.

The third question is the sharpest, and the dossier's real lesson sits here.
Australia built water's law, built its register, built its market, built its
price. And at the end of all of it, at the point where the river narrows, the
method left in its hands was a draw. Where physical capacity is scarce the
market has no answer; the question of who joins the queue is not one the
market answers.

Carrying capacity is limited in Türkiye's basins too. The question there is not
whether a water market should be established; it is whether the rule that
settles the queue when capacity falls short is written down. In Australia that
rule is written, acknowledged to be interim, and its application is observed by
an independent body.$dsr$, '{}'::text[], 'anlati', null),
  (18, $dsr$Toprak ve kanal$dsr$, $dsr$Earth and channel$dsr$, $dsr$Bir sulama hendeğinin iki yanında iki madde durur. Biri kuru toprak,
öteki akan su. Yan yanadırlar, birbirine değerler, ama biri ötekinin
rengini almaz.

Victoria'nın yaptığı şey bu ayrımı hukuka geçirmek oldu. Su Kanunu'nun
bir kısmı suyun kendisine dair hakkı düzenliyor, başka bir kısmı o suyun
belirli bir arazide kullanılmasını. Kuzey Victoria'da 2000-01'de suyun
tamamı toprağa bağlıydı; 2023-24'te yarısı. Dört yüz elli altı
gigalitre özel elde ama arazisiz, yedi yüz kırk yedi gigalitre çevrenin.

Megalitrenin fiyatı bin üç yüz seksen dolardan beş bin dolara çıktı.
Altı bin beş yüz hesap ticaret yapıyor. Toprağa bağlı olmayan payların
tahsisinin beş yüz otuz sekiz gigalitresi ticari olarak satılıyor.
Defter işliyor.

Sonra nehir daralıyor ve defter duruyor. Yedi bin megalitrelik bir
yatak, yirmi dört bin megalitrelik bir kapasite ilanı, altmış yedi bin
megalitrelik bir talep. Yüz üç uygun başvuru reddediliyor. Kim geçecek
sorusunu bir çekiliş cevaplıyor ve çekilişi rekabet kurumu izliyor,
kaydını inceliyor, çıktıya dokunulmadığını imzasıyla beyan ediyor.

Dosyanın başında suyun kendi sicili olduğunu söylemiştik. Sonunda
söylenebilecek olan şu: sicil suyun kimin olduğunu kaydedebiliyor, ama
nehrin ne kadar taşıyacağını kaydetmiyor. O rakamı yatak belirliyor ve
yatak pazarlık etmiyor.

Avustralya'nın kurduğu piyasa, suyu toprağın bir niteliği olmaktan
çıkarıp ayrı bir mülk haline getirebildi. Nehri ayrı bir mülk haline
getiremedi.$dsr$, $dsr$On either side of an irrigation ditch stand two materials. One is dry earth,
the other running water. They lie side by side and touch, and neither takes
the other's colour.

What Victoria did was carry that distinction into law. One part of the Water
Act governs the right to the water itself, another part the use of that water
on particular ground. In northern Victoria all of the water was linked to land
in 2000-01; by 2023-24, half of it. Four hundred and fifty-six gigalitres in
private hands but landless, seven hundred and forty-seven gigalitres with the
environment.

The price of a megalitre rose from one thousand three hundred and eighty
dollars to five thousand. Six and a half thousand accounts trade. Five hundred
and thirty-eight gigalitres of the allocations on landless shares are sold
commercially. The ledger works.

Then the river narrows and the ledger stops. A bed of seven thousand
megalitres, a capacity announcement of twenty-four thousand, a demand of
sixty-seven thousand. A hundred and three eligible applications refused. The
question of who passes is answered by a draw, and the draw is observed by the
competition regulator, which reviews the recording and attests under signature
that the output was untouched.

At the start of this dossier we said water has a register of its own. What can
be said at the end is this: the register can record who owns the water, but it
does not record how much the river will carry. That figure is set by the bed,
and the bed does not negotiate.

The market Australia built was able to take water out of being an attribute of
land and make it a separate holding. It was not able to make the river a
separate holding.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/avustralya/avustralya_insan_yapimi_kanal.jpg","atif":"division, CSIRO — CC BY 3.0","kaynak":null,"alt_tr":"Kazılmış bir sulama kanalı. Bir yanda su, öbür yanda kuru set; yan yana duruyorlar ve biri ötekinin rengini almıyor.","alt_en":"An excavated irrigation channel. Water on one side, dry bank on the other; they lie side by side and neither takes the other's colour."}$dsr$::jsonb)
) as v(ord, title_tr, title_en, body_tr, body_en, chart_keys, tur, gorsel)
where d.slug = 'avustralya';

-- Sağlama: beklenen bölüm sayısı yazılmadıysa işlem geri alınır.
do $kontrol$
declare n integer;
begin
  select count(*) into n
    from public.dossier_sections s
    join public.country_dossiers d on d.id = s.dossier_id
   where d.slug = 'avustralya';
  if n <> 18 then
    raise exception 'Bölüm sayısı 18 olmalıydı, % yazıldı', n;
  end if;
end
$kontrol$;

commit;
