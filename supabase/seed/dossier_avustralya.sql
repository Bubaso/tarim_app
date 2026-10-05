-- Avustralya — Ülke Dosyası · seed
--
-- ÜRETİLMİŞ DOSYA — elle düzenlemeyin.
-- Kaynak:  content/dossiers/avustralya/
-- Üretim:  node content/dossiers/seed_dossier.mjs avustralya
-- Tarih:   2026-10-05T08:56:20.340Z
--
-- Bölüm: 17 · TR ~4.134 kelime · EN ~4.706 kelime
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
  $dsr$Kıtanın yarısı tarım arazisi ama tarım ekonominin yirmi beşte biri. Beş yüz hektarlık işletmeler devletten destek almadan çalışıyor; en kıt girdileri olan su ise topraktan ayrılıp fiyatlanmış.$dsr$,
  $dsr$Half the continent is farmland, yet farming is one twenty-fifth of the economy. Five-hundred-hectare holdings work without state support, and their scarcest input — water — has been separated from the land and priced.$dsr$,
  $dsr${"_dosya":"Avustralya — Ülke Dosyası · tasarım künyesi","_amac":"Görsel kararlar. DossierTheme bu dosyadan üretilir; kodda serbest renk yazılmaz.","_kural":"Bu dosyadaki hiçbir kontrast sayısı 'yaklaşık' değildir. Hepsi _raw/kontrast.py'den geliyor; palet değişirse betik yeniden koşar ve buradaki sayılar güncellenir.","_sureklilik":"Dört dosya, dört geometri: Hollanda dikey şeritler (polder), Rusya yatay bantlar (toprak profili), İspanya nokta ızgarası (dikilmiş zeytinlik), Avustralya ortogonal ızgara (sulama kanalı ağı). Dördü de İNSAN YAPIMI düzen — dizinin sessiz ortak fikri. Bu dosyada fikir bir adım ileri gidiyor: ızgara yalnızca düzenin izi değil, piyasayı MÜMKÜN KILAN altyapı. Suyun yağdığı yerden bağımsız taşınabilmesi o kanalların varlığına bağlı.","tez_cumlesi":{"tr":"Kıtanın yarısı tarım arazisi ama tarım ekonominin yirmi beşte biri. Beş yüz hektarlık işletmeler devletten destek almadan çalışıyor; en kıt girdileri olan su ise topraktan ayrılıp fiyatlanmış.","en":"Half the continent is farmland, yet farming is one twenty-fifth of the economy. Five-hundred-hectare holdings work without state support, and their scarcest input — water — has been separated from the land and priced.","gerekce":"Cümlenin üç yarısı dosyanın üç katmanı: ölçek (geniş ama ince bir tarım), destek (yokluğu) ve suyun ayrışması. İlk hâli yalnız suyu anlatıyordu ve bu bir TARIM portalının ülke dosyası için yanlış kapıydı — dosya su hukukuna dönmüştü. Rotasyon Avustralya'yı 'Model' diye kaydetti ve ağırlık merkezini 'su ve kuraklık' koydu; merkez bir ağırlıktır, konunun tamamı değil.","_dayanak":"Üç öğesinin üçü de bağımsız kaynaktan: arazi payı ve GSYH payı Dünya Bankası'nda (%47,22 ve %2,04); işletme başına ekilen alan ABS'in alan ve işletme sayısının bölümünden (531 ha); destek payı OECD Üretici Destek Tahmini'nde (%2,71). Suyun ayrışması Water Act 1989'un Kısım 3A ve Kısım 4B'sinin ayrı durmasından.","_sayi_yok":"Cümlede rakam yazıyla var, hanesiyle yok; ölçü sonraki bölümlerde veriliyor.","_olumsuz_yok":"'Destek almadan' bir yokluk; ama ölçünün kendisi (%2,71) pozitif ve bölüm bunu söylüyor. Avustralya dünyanın en düşüğü DEĞİL — Yeni Zelanda daha aşağıda.","_metafor_siniri":"'Tapu' kelimesi kullanılmadı. Kanun 'water share' ve 'water register' diyor; tapu Türk hukukunda taşınmaza bağlı bir kurum ve benzetme okuru yanlış yere götürürdü. 'Sicil' kanunun kendi kelimesinin karşılığı.","_eski_tez":"Su sürümü: 'Avustralya'da suyun kendi sicili var: maliki adıyla kayıtlı, fiyatı belli, ipotek edilebilir. Taşıyacak nehir daraldığında sırayı kura belirliyor.' Cümle doğruydu ama dosyanın tamamını suya bağlıyordu; §13 hâlâ onu anlatıyor."},"palet":{"ad":"Toprak ve Kanal","kaynak_fikir":"Palet manzaradan değil, AYRIŞMANIN KENDİSİNDEN türetildi: birbirine değen ama karışmayan iki madde. Kuru toprak ve kanal suyu bir sulama hendeğinin iki yanında yan yana durur, biri ötekinin rengini almaz. Dosyanın anlattığı hukuki ayrışmanın maddi karşılığı bu: su, üstünden geçtiği toprağın maliki olmayan birinin olabilir.","mod":"KOYU — dosya sayfası her zaman koyu. Uygulamanın açık/koyu tercihini izlemez.","mod_gerekcesi":"Dergi dosyası mantığı: içeri girdiğinizde başka bir yere geldiğinizi anlamalısınız (İspanya'dan devralınan karar). Ana sayfadaki şerit bunun istisnasıdır — sayfanın içinde yaşadığı için açık/koyu izler.","koyu":{"zemin":{"hex":"#11100D","rol":"Sayfa arka planı — gece, sulama bölgesi"},"yuzey":{"hex":"#1E1C17","rol":"Kart, tablo, alıntı bloğu","kontrast_zemin":1.12},"murekkep":{"hex":"#EFEBE1","rol":"Gövde metni","kontrast_zemin":15.98,"kontrast_yuzey":14.3},"sessiz":{"hex":"#A69D8D","rol":"Meta, kaynak satırı, altyazı","kontrast_zemin":7.09,"kontrast_yuzey":6.35},"vurgu":{"hex":"#5BC8C0","rol":"Kanal suyu — rakamlar, başlık vurguları, Avustralya serisi","kontrast_zemin":9.48,"kontrast_yuzey":8.48},"ikincil":{"hex":"#C9763C","rol":"Kuru toprak — karşılaştırmanın ikinci rengi","kontrast_zemin":5.56,"kontrast_yuzey":4.98},"cizgi":{"hex":"#2B2922","rol":"SADECE dekoratif ayırıcı","kontrast_zemin":1.31,"kontrast_yuzey":1.17,"_uyari":"3:1'in altında. Anlam taşıyan hiçbir yerde kullanılamaz — grafik ekseni, sınır, odak halkası için cizgiVurgu kullanılır."},"cizgiVurgu":{"hex":"#7A7363","rol":"Grafik ekseni, ızgara çizgisi, işlem akışı omurgası, odak halkası","kontrast_zemin":4.04,"kontrast_yuzey":3.62}},"acik_mod_seridi":{"_amac":"Ana sayfadaki dosya şeridi sayfanın içinde yaşıyor; krem zemin üstünde koyu gövdenin renkleri okunmuyor.","murekkep":{"hex":"#1A1813","kontrast_krem":15.76},"vurguKoyu":{"hex":"#8A4414","rol":"Kuru toprağın krem zemindeki karşılığı — kart kenarı ve açık moddaki tüm vurgu metni","kontrast_krem":6.39,"kontrast_beyaz":7.2,"_anasayfadan_ayrisma":{"darkGreen_#2F4B2E":1.35,"primaryGreen_#5C8A4A":1.84,"wheat_#C9A15A":2.99,"marketDown_#9C4A3C":1.19,"alertRed_#D32F2F":1.45,"_notu":"Ton 24° — marketDown'ın 9°'si ile wheat'in 38°'si arasında, yeşilin 103°'sinden uzak. Kırmızıyla karışma riski yok: alertRed son dakika demek ve o rozet küçük, doygun ve tam kırmızı (0°)."}},"ikincilKoyu":{"hex":"#0B4F4A","rol":"Kanal suyunun krem zemindeki karşılığı — ikinci vurgu","kontrast_krem":8.36},"_rol_degisimi":"ŞERİTTE TOPRAK ÖNDE, SAYFADA SU. Koyu dosya sayfasında vurgu kanal suyu (#5BC8C0) — dosyanın tezi suyun ayrışması. Ama ana sayfa krem ve kendi yapısal yeşili #2F4B2E; şeridin eski vurgusu #0B4F4A o yeşille arasında 1,03 PARLAKLIK ORANI bırakıyordu, yani kart sayfanın kendi rengiyle aynı ağırlıktaydı ve ayrışmıyordu. Hollanda'da belgelenen çökme deseninin (1,05) aynısı. Paletin fikri 'birbirine değen ama karışmayan iki madde'ydi; hangisinin önde durduğu ZEMİNE bağlı. Krem zeminde kuru toprak önde. Renk uydurulmadı — dosyanın kendi ikincil rengi öne alındı, teal ikinciye geçti."},"renk_korlugu_notu":"HOLLANDA DERSİ İKİ KEZ UYGULANDI. Orada sodyum turuncusu (0,4867) ile cam yeşili (0,4650) neredeyse eş parlaklıktaydı — oran 1,05 — ve deuteranopi altında ayırt edilemiyorlardı. (1) Koyu gövdede kanal suyu 0,4734, kuru toprak 0,2570; oran 1,84. (2) ŞERİTTE İLK HESAP 1,06 ÇIKTI — tam Hollanda hatası. Teal #0E5F5A'dan #0B4F4A'ya koyulaştırıldı, oran 1,56'ya çıktı. İlk denemeyi kontrast.py yakaladı; göz yakalamazdı.","_cizgivurgu_notu":"İlk seçim #6A6354 idi: zeminde 3,19 ile eşiği geçiyor ama YÜZEYDE 2,86 ile geçmiyordu. Yalnız zemine bakan bir denetim bunu kaçırırdı; betik iki zemini birlikte sınıyor. #7A7363 ikisinde de geçiyor (4,04 / 3,62).","denetim_betigi":"_raw/kontrast.py — `python3 content/dossiers/avustralya/_raw/kontrast.py`"},"motif":{"ad":"Kanal ızgarası","tanim":"Sulama bölgesinin ortogonal kanal ağı: taşkın ovasına dik açılarla oturtulmuş, iki yönde uzanan ince çizgi örgüsü.","gerekce":"Dizideki dördüncü geometri ve bilerek öteki üçünden farklı: Hollanda dikey şerit, Rusya yatay bant, İspanya nokta, burası İKİ YÖNLÜ ızgara. Ortak fikir aynı kalıyor — bu manzara doğal değil, kazılmış. Ama bu dosyada ızgara fazladan bir iş yapıyor: suyun yağdığı yerden bağımsız taşınabilmesi, yani piyasanın mümkün olması, o kanalların varlığına bağlı.","uygulama":{"opaklik":"%6","renk":"cizgiVurgu #7A7363 üzerine opaklık","bicim":"Vektör (CustomPainter) — raster değil. Ölçeklenebilir, dosya boyutu sıfır, telif sorunu yok.","yerlesim":"Bölüm ayırıcılarında ve kapak altı geçiş bandında. Gövde metninin ARKASINDA kullanılmaz.","moire_notu":"Izgara aralığı 24 px'in altına inmeyecek; iki yönlü örgü tek yönlüden daha çok titrer."},"_UYGULANMAMIŞ":"ÖNEMLİ — BU GEOMETRİ ŞU AN ÇİZİLMİYOR. Depodaki tek motif çizici `polder_motif.dart` ve `DossierTheme` motif bloğundan YALNIZCA opaklığı okuyor (`motifOpaklik`); `motifAralik` bile JSON'dan değil yedekten geliyor. Bir `yon` alanı da kodda hiçbir yerde okunmuyor — İspanya'nın tasarım künyesinde 'paylaşım kartı bu alanı okuyor' diye bir not var, kodda karşılığı yok. Bu yüzden burada `yon` alanı YAZILMADI: okunmayan bir alana değer yazmak, sonraki turda 'ızgara motifi bölüm ayırıcılarında görünüyor' diye yanlış bir cümle yazdırır. Izgara bir ŞARTNAMEDİR; çizici yazılana kadar sayfada polder motifi görünür."},"kapak":{"yon":"Sulama bölgesinin kanal ağı — havadan","gerekce":"Tezin doğrudan görselleştirmesi değil, zemini: dosyanın anlattığı bütün piyasa bu kazılmış ağın üstünde işliyor. Hollanda ve Rusya yörüngeden, İspanya yerden bakıyordu; burası yine yükseliyor çünkü ızgara ancak yukarıdan ızgara gibi görünüyor.","gorsel_kaynagi":{"tercih_1":"NASA Earth Observatory / ISS astronot fotoğrafı — kamu malı.","tercih_2":"Wikimedia Commons, açık lisanslı havadan çekim.","tercih_3":"data.gov.au / eyalet kurumlarının açık lisanslı havadan görüntüleri — bu ağdan açık olduğu ÖLÇÜLDÜ.","_karar":"Görsel BULUNANA KADAR kapak tipografik iskeletle çalışır — sayfa görselsiz de tam çalışmak zorunda (§3.5).","_yasak":"Telifi belirsiz hiçbir görsel kullanılmayacak. Google görsel araması kaynak değildir.","_erisim_uyarisi":"Bu dosyanın kaynak turlarında ölçüldü: agriculture.gov.au ve data.daff.gov.au bu ağdan 000, mdba.gov.au 403. Görsel aramasında o üç adrese gidilmesin."},"tipografi_katmani":{"ust_satir":"ÜLKE DOSYASI · 04","baslik":"AVUSTRALYA","alt_satir":"tez_cumlesi.tr","veri_rozeti":"Barmah darlığından geçen akış: günde yaklaşık 7.000 megalitre"},"_rozet_notu":"Rozet kasıtlı olarak kapasiteyi söylüyor, piyasa büyüklüğünü değil. Dosyanın sürprizi piyasanın büyüklüğü değil, piyasanın bittiği yer.","_baslik_notu":"En uzun kelime başlığın kendisi: 'AVUSTRALYA' (10 harf). _KapakAdi puntoyu en uzun kelimeye bakarak küçültüyor (§10.4); on harf İSPANYA'dan (7) uzun, KOOPERATİFLERİ'nden (14) kısa — ikisi de taşmadan çalıştığı için bu da çalışır.","okunurluk":"Görsel üzerine zemin renginden %0 → %85 dikey gradyan; metin yalnızca %60+ bölgede durur."},"_zorunluluklar":["Grafiklerde iki seri renkle BİRLİKTE biçimle de ayrılacak; bu dosyada parlaklık farkı da var (gövdede 1,84, şeritte 1,56) ve asıl güvence o.","Kanal ızgarası motifi CustomPainter ile çizilecek — ama çizici YAZILANA KADAR sayfada polder motifi görünür; bu dosyada aksini iddia eden cümle yazılmayacak.","Kapak görseli bulunamazsa sayfa yine de tam çalışacak.","Koyu sayfa sistem açık/koyu tercihini izlemeyecek; ana sayfa şeridi izleyecek.","Tüm renkler bu dosyadan türetilen DossierTheme üzerinden gelecek, kodda serbest hex yazılmayacak.","Palet değişirse _raw/kontrast.py yeniden çalıştırılacak ve buradaki kontrast alanları güncellenecek."],"_yasak":["Avustralya bayrağı, armaları ya da eyalet amblemleri","Stok \"kurak toprakta çatlak\" fotoğrafı — dosya kuraklığı değil su hakkını anlatıyor","Koala, kanguru ya da herhangi bir ülke klişesi","ACCC, DEECA ya da WaterNSW logoları; resmî yazı tıpkıbasımı","Kura/çekiliş çağrışımlı dekoratif ikon (zar, top, piyango makinesi) — mekanizma ciddi bir idari işlem, oyun değil"]}$dsr$::jsonb,
  $dsr${"_dosya":"Avustralya — Ülke Dosyası Sayı 04 · veri katmanı","_uretim":"build_data.py — elle düzenlenmez","_eksen":"Desteksiz, az sayıda ve çok büyük işletmeyle çalışan bir tarım; ve o tarımın en kıt girdisi olan suyun topraktan ayrılıp fiyatlanması — kapasite bittiğinde sıra kurayla belirleniyor.","makro":{"_kaynak_niteligi":"BAĞIMSIZ — Dünya Bankası","_kapsam":"Avustralya geneli","tarim_arazisi_yuzde":{"2010":48.9920987204353,"2011":51.5628132199992,"2012":50.3854314463116,"2013":48.3937102169923,"2014":48.7383986566523,"2015":45.3144240657095,"2016":44.5399257932247,"2017":48.3406179391109,"2018":46.6580950127535,"2019":47.1237724290889,"2020":46.2524798427461,"2021":47.2592374954823,"2022":47.2592374954823,"2023":47.2234443228177},"tarim_gsyh_yuzde":{"2010":2.21824837320556,"2011":2.30485962261499,"2012":2.27317856495351,"2013":2.29076813252161,"2014":2.22695769265967,"2015":2.37664391487055,"2016":2.41300232330254,"2017":2.72098319651067,"2018":2.47191752630847,"2019":2.12424911197662,"2020":2.01512715396535,"2021":2.30537875480088,"2022":2.67242699950618,"2023":2.57169831894523,"2024":2.03565265249391},"tarim_istihdam_yuzde":{"2010":3.52628341594719,"2011":3.08249791970705,"2012":3.06391361624626,"2013":2.86527758750488,"2014":2.79831970596916,"2015":2.63650803423428,"2016":2.61998324165225,"2017":2.59605335120917,"2018":2.61685053200616,"2019":2.55829744516573,"2020":2.7659977760499,"2021":2.4984121870069,"2022":2.1974275768901,"2023":2.14974802026124,"2024":2.2305246861444},"islenebilir_arazi_ha":{"2010":25591750,"2011":31694900,"2012":31637400,"2013":31220800,"2014":31960300,"2015":31090700,"2016":30057000,"2017":30752000,"2018":30974000,"2019":30573000,"2020":30644000,"2021":31265000,"2022":31265000,"2023":30989678.2},"son_arazi_yuzde":{"yil":"2023","deger":47.2234443228177},"son_gsyh_yuzde":{"yil":"2024","deger":2.03565265249391},"son_istihdam_yuzde":{"yil":"2024","deger":2.2305246861444},"son_islenebilir_ha":{"yil":"2023","deger":30989678.2}},"urunler":{"_kaynak_niteligi":"BAĞIMSIZ — ABS, Australian Agriculture: Broadacre Crops","_kapsam":"Avustralya geneli, 2023","_not":"Pamukta üretim ve değer alanları boş geliyor; yalnız alan var.","kayitlar":[{"urun":"Wheat","alan_ha":10506997,"uretim_t":28028429,"deger_aud":8830461592,"isletme":19800,"ha_isletme":531,"aud_isletme":445983,"verim_t_ha":2.67},{"urun":"Barley","alan_ha":4001070,"uretim_t":10961886,"deger_aud":3167700550,"isletme":12440,"ha_isletme":322,"aud_isletme":254638,"verim_t_ha":2.74},{"urun":"Canola","alan_ha":3714751,"uretim_t":7504667,"deger_aud":4483016863,"isletme":11095,"ha_isletme":335,"aud_isletme":404057,"verim_t_ha":2.02},{"urun":"Lentils","alan_ha":804131,"uretim_t":1412950,"deger_aud":1194301286,"isletme":2380,"ha_isletme":338,"aud_isletme":501807,"verim_t_ha":1.76},{"urun":"Sorghum","alan_ha":774646,"uretim_t":2441091,"deger_aud":764560811,"isletme":1960,"ha_isletme":395,"aud_isletme":390082,"verim_t_ha":3.15},{"urun":"Cotton","alan_ha":644536,"uretim_t":null,"deger_aud":null,"isletme":null},{"urun":"Lupins","alan_ha":604423,"uretim_t":831186,"deger_aud":306560129,"isletme":2355,"ha_isletme":257,"aud_isletme":130174,"verim_t_ha":1.38},{"urun":"Oats","alan_ha":541563,"uretim_t":737119,"deger_aud":267724486,"isletme":2080,"ha_isletme":260,"aud_isletme":128714,"verim_t_ha":1.36},{"urun":"Sugarcane","alan_ha":340590,"uretim_t":29855156,"deger_aud":2202739243,"isletme":3640,"ha_isletme":94,"aud_isletme":605148,"verim_t_ha":87.66},{"urun":"Chickpeas","alan_ha":288825,"uretim_t":545767,"deger_aud":400274083,"isletme":1090,"ha_isletme":265,"aud_isletme":367224,"verim_t_ha":1.89},{"urun":"Maize","alan_ha":75132,"uretim_t":447027,"deger_aud":168679207,"isletme":425,"ha_isletme":177,"aud_isletme":396892,"verim_t_ha":5.95},{"urun":"Rice","alan_ha":51969,"uretim_t":619180,"deger_aud":241857560,"isletme":455,"ha_isletme":114,"aud_isletme":531555,"verim_t_ha":11.91}],"bugday":{"urun":"Wheat","alan_ha":10506997,"uretim_t":28028429,"deger_aud":8830461592,"isletme":19800,"ha_isletme":531,"aud_isletme":445983,"verim_t_ha":2.67}},"hayvan":{"_kaynak_niteligi":"BAĞIMSIZ — ABS, Livestock slaughtered","_kapsam":"Avustralya geneli","_birim":"bin baş (UNIT_MULT=3)","_seri_notu":"1973'ten beri; çeyreklik veriden yıla toplandı ve dört çeyreği tam olmayan yıl DIŞARIDA bırakıldı.","kuzu":{"_birim":"bin baş (UNIT_MULT=3)","ilk_yil":"1973","son_yil":"2025","zirve_yil":"2024","zirve_bin_bas":26389,"son_bin_bas":24564,"zirveye_oran_yuzde":93.1,"seri":{"1973":15553,"1974":14895,"1975":15564,"1976":16221,"1977":15298,"1978":15485,"1979":15950,"1980":15736,"1981":16179,"1982":17128,"1983":16804,"1984":16542,"1985":18759,"1986":18356,"1987":17516,"1988":16675,"1989":16864,"1990":16549,"1991":15818,"1992":15595,"1993":14668,"1994":15718,"1995":14680,"1996":14069,"1997":14924,"1998":15724,"1999":16346,"2000":18507,"2001":17896,"2002":17086,"2003":16430,"2004":16675,"2005":18228,"2006":19483,"2007":20971,"2008":19970,"2009":20493,"2010":18609,"2011":17793,"2012":20009,"2013":21886,"2014":22251,"2015":22876,"2016":22956,"2017":22431,"2018":22725,"2019":21624,"2020":20421,"2021":20790,"2022":21495,"2023":24863,"2024":26389,"2025":24564}},"domuz":{"_birim":"bin baş (UNIT_MULT=3)","ilk_yil":"1973","son_yil":"2025","zirve_yil":"2023","zirve_bin_bas":5802,"son_bin_bas":5753,"zirveye_oran_yuzde":99.2,"seri":{"1973":4711,"1974":3707,"1975":3302,"1976":3384,"1977":3595,"1978":3646,"1979":3661,"1980":4155,"1981":4153,"1982":4017,"1983":4292,"1984":4473,"1985":4539,"1986":4633,"1987":4793,"1988":4962,"1989":4940,"1990":4949,"1991":4942,"1992":5228,"1993":5260,"1994":5365,"1995":5191,"1996":4840,"1997":4899,"1998":5212,"1999":5037,"2000":5014,"2001":5172,"2002":5603,"2003":5723,"2004":5440,"2005":5372,"2006":5320,"2007":5327,"2008":4796,"2009":4500,"2010":4617,"2011":4663,"2012":4728,"2013":4777,"2014":4812,"2015":4958,"2016":5080,"2017":5275,"2018":5424,"2019":5141,"2020":5346,"2021":5568,"2022":5437,"2023":5802,"2024":5787,"2025":5753}},"koyun":{"_birim":"bin baş (UNIT_MULT=3)","ilk_yil":"1973","son_yil":"2025","zirve_yil":"1991","zirve_bin_bas":18750,"son_bin_bas":10193,"zirveye_oran_yuzde":54.4,"seri":{"1973":16790,"1974":10896,"1975":14935,"1976":17467,"1977":15238,"1978":12079,"1979":13550,"1980":14590,"1981":12726,"1982":14016,"1983":9719,"1984":9306,"1985":11742,"1986":14223,"1987":15314,"1988":13130,"1989":13698,"1990":17254,"1991":18750,"1992":18186,"1993":18047,"1994":17991,"1995":15228,"1996":14447,"1997":15552,"1998":15589,"1999":15457,"2000":16379,"2001":15789,"2002":14873,"2003":10522,"2004":11145,"2005":11636,"2006":13113,"2007":11661,"2008":11236,"2009":9411,"2010":6158,"2011":4933,"2012":6064,"2013":9615,"2014":10086,"2015":8487,"2016":6965,"2017":7536,"2018":9521,"2019":9344,"2020":6142,"2021":5804,"2022":6640,"2023":9817,"2024":11784,"2025":10193}},"sigir":{"_birim":"bin baş (UNIT_MULT=3)","ilk_yil":"1973","son_yil":"2025","zirve_yil":"1977","zirve_bin_bas":10327,"son_bin_bas":9284,"zirveye_oran_yuzde":89.9,"seri":{"1973":7086,"1974":5745,"1975":7715,"1976":8938,"1977":10327,"1978":10159,"1979":8262,"1980":7320,"1981":6652,"1982":7790,"1983":6645,"1984":5608,"1985":5958,"1986":6611,"1987":6860,"1988":6696,"1989":6511,"1990":7205,"1991":7385,"1992":7713,"1993":7353,"1994":7299,"1995":6914,"1996":6897,"1997":7868,"1998":8105,"1999":7653,"2000":7702,"2001":7808,"2002":7969,"2003":7806,"2004":7894,"2005":7643,"2006":7986,"2007":8000,"2008":7854,"2009":7583,"2010":7472,"2011":7261,"2012":7352,"2013":8344,"2014":9226,"2015":9007,"2016":7288,"2017":7158,"2018":7873,"2019":8482,"2020":7145,"2021":6018,"2022":5850,"2023":7020,"2024":8296,"2025":9284}},"dana":{"_birim":"bin baş (UNIT_MULT=3)","ilk_yil":"1973","son_yil":"2025","zirve_yil":"1976","zirve_bin_bas":2496,"son_bin_bas":409,"zirveye_oran_yuzde":16.4,"seri":{"1973":1358,"1974":1243,"1975":1881,"1976":2496,"1977":2464,"1978":2186,"1979":1577,"1980":1512,"1981":1447,"1982":1669,"1983":1474,"1984":1217,"1985":1193,"1986":1272,"1987":1188,"1988":1026,"1989":972,"1990":1048,"1991":1042,"1992":1018,"1993":990,"1994":1067,"1995":991,"1996":1071,"1997":1280,"1998":1202,"1999":1103,"2000":1080,"2001":956,"2002":1081,"2003":1100,"2004":910,"2005":823,"2006":869,"2007":901,"2008":798,"2009":828,"2010":801,"2011":682,"2012":625,"2013":690,"2014":688,"2015":667,"2016":542,"2017":413,"2018":468,"2019":565,"2020":414,"2021":285,"2022":265,"2023":374,"2024":394,"2025":409}}},"destek":{"_kaynak_niteligi":"BAĞIMSIZ — OECD, Üretici Destek Tahmini","_kapsam":"ülke karşılaştırması","_uyari":"Avustralya DÜNYANIN EN DÜŞÜĞÜ DEĞİL. Yeni Zelanda daha düşük (%1,53) ve bazı OECD dışı ekonomilerde destek NEGATİF (Vietnam, Hindistan, Arjantin) — orada üretici destekleniyor değil, örtülü olarak vergileniyor. Metinde 'en düşük' denmez.","_olcu":"PSEP — Üretici Destek Tahmini, brüt çiftlik hasılatının yüzdesi","_birim":"PT_REC_FRM","son_yil":"2023","ulkeler":{"ARG":{"2021":-27.19,"2022":-17.91,"2023":-4.93},"AUS":{"2021":2.01,"2022":3.1,"2023":2.71},"BRA":{"2021":3.26,"2022":4.37,"2023":4.37},"CAN":{"2021":11.52,"2022":7.87,"2023":7.71},"CHE":{"2021":50.02,"2022":45.19,"2023":49.36},"CHL":{"2021":2.74,"2022":2.96,"2023":3.34},"CHN":{"2021":15.3,"2022":13.68,"2023":13.22},"COL":{"2021":4,"2022":5.64,"2023":14.16},"CRI":{"2021":2.67,"2022":2.01,"2023":3.54},"EU":{"2021":15.95,"2022":14.94,"2023":17.05},"GBR":{"2021":18.14,"2022":13.6,"2023":15.91},"IDN":{"2021":3.45,"2022":3.27,"2023":11.29},"IND":{"2021":-15.88,"2022":-19.57,"2023":-9.98},"ISL":{"2021":50.36,"2022":44.53,"2023":44.55},"ISR":{"2021":12.58,"2022":12.81,"2023":12.8},"JPN":{"2021":36.8,"2022":29.72,"2023":30.35},"KAZ":{"2021":7.02,"2022":4.49,"2023":9.19},"KOR":{"2021":46.74,"2022":40.89,"2023":40.07},"MEX":{"2021":9.19,"2022":6.58,"2023":12.15},"NOR":{"2021":50.04,"2022":44.18,"2023":48.19},"NZL":{"2021":0.75,"2022":0.69,"2023":1.53},"OECD":{"2021":15.1,"2022":12.09,"2023":13.53},"PHL":{"2021":22.67,"2022":22.11,"2023":19.56},"RUS":{"2021":3.48,"2022":3.35,"2023":3.49},"TUR":{"2021":13.76,"2022":7.24,"2023":9.32},"UKR":{"2021":2.54,"2022":-1.74,"2023":2.97},"USA":{"2021":10.32,"2022":7.18,"2023":6.79},"VNM":{"2021":-11.03,"2022":-10.94,"2023":-14.55},"ZAF":{"2021":2.5,"2022":3.21,"2023":2.61}},"en_dusuk_bes":[["VNM",-14.55],["IND",-9.98],["ARG",-4.93],["NZL",1.53],["ZAF",2.61]],"avustralya":2.71,"turkiye":9.32,"oecd":13.53},"ticaret_dis":{"_kaynak_niteligi":"BAĞIMSIZ — UN Comtrade","_kapsam":"Avustralya geneli","_cift_sayim":"customsCode='C00' ve motCode=0 ve partner2Code=0 süzgeci uygulandı (§2.2.1).","_agirlik_uyarisi":"Bu muhabir için netWgt/qty SIFIR geliyor; tonaj kullanılmıyor, yalnızca değer.","dunyaya_tarim_2024":{"toplam_usd":41868857139.17999,"fasillar":[{"hs":"02","deger_usd":13992221025.745},{"hs":"10","deger_usd":8250390292.121},{"hs":"12","deger_usd":3990709823.048},{"hs":"07","deger_usd":2570010677.333},{"hs":"04","deger_usd":2283357716.443},{"hs":"22","deger_usd":2164696287.101},{"hs":"08","deger_usd":1937422871.915},{"hs":"21","deger_usd":1140768872.618},{"hs":"15","deger_usd":1003306643.567},{"hs":"03","deger_usd":781681729.114},{"hs":"11","deger_usd":753317993.374},{"hs":"01","deger_usd":735399302.688},{"hs":"19","deger_usd":684555051.387},{"hs":"23","deger_usd":488112087.331},{"hs":"05","deger_usd":271741791.12},{"hs":"18","deger_usd":251974268.721},{"hs":"20","deger_usd":177424291.744},{"hs":"17","deger_usd":152283670.193},{"hs":"16","deger_usd":151798499.045},{"hs":"09","deger_usd":44332166.54},{"hs":"13","deger_usd":18837435.936},{"hs":"24","deger_usd":13320110.143},{"hs":"06","deger_usd":11012190.227},{"hs":"14","deger_usd":182341.726}]},"dunyaya_lif_2024":{"yun":{"hs":"51","deger_usd":1792163246.68},"pamuk":{"hs":"52","deger_usd":2432356752.992}},"seri_2005_2024":{"2005":{"yun":1781124621,"et":5142985863,"hububat":2915392721},"2010":{"yun":2055809883,"et":6101456037,"hububat":4705078784},"2015":{"yun":2200388109,"et":9815384902,"hububat":6427636896},"2020":{"yun":1536611753.269,"et":10050609657.916,"hububat":3751740937.177},"2024":{"yun":1792163246.68,"et":13992221025.745,"hububat":8250390292.121}},"yun_et_orani_2005_yuzde":34.6,"yun_et_orani_2024_yuzde":12.8,"harita_yun_milyar":{"2005":1.781,"2010":2.056,"2015":2.2,"2020":1.537,"2024":1.792},"harita_et_milyar":{"2005":5.143,"2010":6.101,"2015":9.815,"2020":10.051,"2024":13.992},"harita_hububat_milyar":{"2005":2.915,"2010":4.705,"2015":6.428,"2020":3.752,"2024":8.25}},"turkiye":{"_kaynak_niteligi":"BAĞIMSIZ — UN Comtrade","_kapsam":"iki ülke arası, HS 01-24, 2024","aus_tur":{"toplam_usd":59222883.717000015,"fasillar":[{"hs":"08","deger_usd":54007715.56},{"hs":"05","deger_usd":3227514.469},{"hs":"02","deger_usd":753357.273},{"hs":"04","deger_usd":333422.852},{"hs":"22","deger_usd":248165.773},{"hs":"07","deger_usd":241515.86},{"hs":"23","deger_usd":207552.929},{"hs":"21","deger_usd":117540.538},{"hs":"20","deger_usd":49312.438},{"hs":"19","deger_usd":25645.424},{"hs":"18","deger_usd":11140.601}],"hs08_kirilim":[{"hs":"0802","deger_usd":53984288.753},{"hs":"0806","deger_usd":23426.807}]},"tur_aus":{"toplam_usd":181882222,"fasillar":[{"hs":"08","deger_usd":84889962},{"hs":"20","deger_usd":44955842},{"hs":"15","deger_usd":13728582},{"hs":"19","deger_usd":8756429},{"hs":"17","deger_usd":6125879},{"hs":"07","deger_usd":5344555},{"hs":"09","deger_usd":4362515},{"hs":"21","deger_usd":3576927},{"hs":"11","deger_usd":3447914},{"hs":"22","deger_usd":3017894},{"hs":"18","deger_usd":1389470},{"hs":"12","deger_usd":1100734},{"hs":"23","deger_usd":534595},{"hs":"04","deger_usd":300250},{"hs":"24","deger_usd":190437},{"hs":"13","deger_usd":118105},{"hs":"10","deger_usd":37796},{"hs":"14","deger_usd":3602},{"hs":"06","deger_usd":636},{"hs":"05","deger_usd":98}],"hs08_kirilim":[{"hs":"0802","deger_usd":27266707},{"hs":"0813","deger_usd":21801609},{"hs":"0806","deger_usd":21465272},{"hs":"0804","deger_usd":14142321},{"hs":"0811","deger_usd":206459},{"hs":"0814","deger_usd":4549},{"hs":"0809","deger_usd":1445},{"hs":"0803","deger_usd":1058},{"hs":"0805","deger_usd":510},{"hs":"0810","deger_usd":32}]},"denge_lehine":"Türkiye","kat":3.07},"kanun":{"_kaynak_niteligi":"BİRİNCİL — Water Act 1989 (Victoria), Tasdikli Sürüm No. 147","_kaynak":"legislation.vic.gov.au · Baş Parlamento Müşaviri tasdiki, 24 Haziran 2026","_kapsam":"Victoria eyaleti mevzuatı","surum":147,"sayfa":923,"tanim":"water share means a water share issued under Division 2 of Part 3A","ihdas":"The Minister may issue a water share in respect of a declared water system","dayanak_dipnot":"S. 33F inserted by No. 99/2005 s. 41","dayanak_kanun":"Water (Resource Management) Act 2005, No. 99/2005","tasdik_tarihi":"2005-12-07","yururluk_tarihi":"2006-08-03","yururluk_dayanagi":"Özel Resmî Gazete No. 191, 2.8.06 s. 1 — ss 35–57 bu tarihte","pay_kismi":"Part 3A—Water shares","kullanim_kismi":"Part 4B—Water-use licences and water use registrations","arazide_kullanim_yasagi":"use water on land","ipotek":"mortgage of a water share","sicil_kaydi":"the name and address of","sicil_gecis_sayisi":190,"memur_gecis_sayisi":154,"_not":"Kanunda 'separate from land' gibi bir BEYAN cümlesi YOK. Ayrışma iki ayrı kısmın varlığından okunuyor. Metinde kanundan böyle bir cümle alıntılanmayacak."},"ayrisma_takvimi":{"_kaynak_niteligi":"SİCİLİN BEYANI — Victoria Su Sicili, eğilim raporu Ek 1","_kapsam":"kuzey Victoria","ayrisma_gunu":"2007-07-01","ayrisma_alintisi":"When unbundling occurred in northern Victoria (1 July 2007)","ayrisma_notu":"all water shares were associated with land","tavan_yuzde":10,"tavan_alintisi":"no more than 10% of the water share volume in a system could be owned without being linked to land","tavan_kaldirildi":2009,"cikis_tavani_yuzde":4,"cikis_tavani_alintisi":"no more than 4% of the water share volume in an irrigation area could be moved out the area in a year","cikis_tavani_kaldirildi":2014,"birliktelik_kaldirildi":"2023-11-20","birliktelik_alintisi":"removed the ability to associate a water share with land","_yontem_uyarisi":"Rapor 2023 değişikliği nedeniyle 'linked to land' yöntemine geçti; eski 'tied to land' ile farkı Şekil 17'de, yani GRAFİKTE — metinden çıkarılamıyor. Tablo 6'nın başlığı eski ibareyi taşısa da verisi yeni yöntem (2023-24'te iki tablo da 1.262 GL). Metinde tied/linked ayrımı üzerine cümle kurulmayacak."},"sahiplik":{"_kaynak_niteligi":"SİCİLİN BEYANI — Victoria Su Sicili","_kapsam":"kuzey Victoria — Avustralya geneli DEĞİL","_tablo":"Table 2","_baslik":"Northern Victorian high-reliability water share volume at 30 June","_birim":"GL / %","kayitlar":[{"yil":"2000-01","cevre_gl":0,"su_kurumu_gl":0,"ozel_topraga_bagli_degil_gl":0,"ozel_topraga_bagli_gl":2283,"toplam_gl":2283,"topraga_bagli_pay_yuzde":100,"topraga_bagli_degil_pay_yuzde":0,"cevre_pay_yuzde":0,"yil_no":2000},{"yil":"2004-05","cevre_gl":0,"su_kurumu_gl":0,"ozel_topraga_bagli_degil_gl":0,"ozel_topraga_bagli_gl":2251,"toplam_gl":2251,"topraga_bagli_pay_yuzde":100,"topraga_bagli_degil_pay_yuzde":0,"cevre_pay_yuzde":0,"yil_no":2004},{"yil":"2008-09","cevre_gl":0,"su_kurumu_gl":0,"ozel_topraga_bagli_degil_gl":125,"ozel_topraga_bagli_gl":2163,"toplam_gl":2288,"topraga_bagli_pay_yuzde":94.5,"topraga_bagli_degil_pay_yuzde":5.5,"cevre_pay_yuzde":0,"yil_no":2008},{"yil":"2009-10","cevre_gl":160,"su_kurumu_gl":46,"ozel_topraga_bagli_degil_gl":128,"ozel_topraga_bagli_gl":1947,"toplam_gl":2280,"topraga_bagli_pay_yuzde":85.4,"topraga_bagli_degil_pay_yuzde":5.6,"cevre_pay_yuzde":7,"yil_no":2009},{"yil":"2010-11","cevre_gl":283,"su_kurumu_gl":64,"ozel_topraga_bagli_degil_gl":120,"ozel_topraga_bagli_gl":1813,"toplam_gl":2279,"topraga_bagli_pay_yuzde":79.6,"topraga_bagli_degil_pay_yuzde":5.3,"cevre_pay_yuzde":12.4,"yil_no":2010},{"yil":"2011-12","cevre_gl":463,"su_kurumu_gl":67,"ozel_topraga_bagli_degil_gl":117,"ozel_topraga_bagli_gl":1635,"toplam_gl":2281,"topraga_bagli_pay_yuzde":71.7,"topraga_bagli_degil_pay_yuzde":5.1,"cevre_pay_yuzde":20.3,"yil_no":2011},{"yil":"2012-13","cevre_gl":499,"su_kurumu_gl":74,"ozel_topraga_bagli_degil_gl":142,"ozel_topraga_bagli_gl":1569,"toplam_gl":2285,"topraga_bagli_pay_yuzde":68.7,"topraga_bagli_degil_pay_yuzde":6.2,"cevre_pay_yuzde":21.8,"yil_no":2012},{"yil":"2013-14","cevre_gl":539,"su_kurumu_gl":59,"ozel_topraga_bagli_degil_gl":146,"ozel_topraga_bagli_gl":1552,"toplam_gl":2295,"topraga_bagli_pay_yuzde":67.6,"topraga_bagli_degil_pay_yuzde":6.4,"cevre_pay_yuzde":23.5,"yil_no":2013},{"yil":"2014-15","cevre_gl":605,"su_kurumu_gl":62,"ozel_topraga_bagli_degil_gl":156,"ozel_topraga_bagli_gl":1516,"toplam_gl":2338,"topraga_bagli_pay_yuzde":64.8,"topraga_bagli_degil_pay_yuzde":6.7,"cevre_pay_yuzde":25.9,"yil_no":2014},{"yil":"2015-16","cevre_gl":648,"su_kurumu_gl":62,"ozel_topraga_bagli_degil_gl":197,"ozel_topraga_bagli_gl":1473,"toplam_gl":2380,"topraga_bagli_pay_yuzde":61.9,"topraga_bagli_degil_pay_yuzde":8.3,"cevre_pay_yuzde":27.2,"yil_no":2015},{"yil":"2016-17","cevre_gl":652,"su_kurumu_gl":63,"ozel_topraga_bagli_degil_gl":237,"ozel_topraga_bagli_gl":1428,"toplam_gl":2380,"topraga_bagli_pay_yuzde":60,"topraga_bagli_degil_pay_yuzde":10,"cevre_pay_yuzde":27.4,"yil_no":2016},{"yil":"2017-18","cevre_gl":661,"su_kurumu_gl":63,"ozel_topraga_bagli_degil_gl":272,"ozel_topraga_bagli_gl":1390,"toplam_gl":2386,"topraga_bagli_pay_yuzde":58.3,"topraga_bagli_degil_pay_yuzde":11.4,"cevre_pay_yuzde":27.7,"yil_no":2017},{"yil":"2018-19","cevre_gl":732,"su_kurumu_gl":61,"ozel_topraga_bagli_degil_gl":307,"ozel_topraga_bagli_gl":1355,"toplam_gl":2455,"topraga_bagli_pay_yuzde":55.2,"topraga_bagli_degil_pay_yuzde":12.5,"cevre_pay_yuzde":29.8,"yil_no":2018},{"yil":"2019-20","cevre_gl":732,"su_kurumu_gl":62,"ozel_topraga_bagli_degil_gl":330,"ozel_topraga_bagli_gl":1331,"toplam_gl":2455,"topraga_bagli_pay_yuzde":54.2,"topraga_bagli_degil_pay_yuzde":13.4,"cevre_pay_yuzde":29.8,"yil_no":2019},{"yil":"2020-21","cevre_gl":733,"su_kurumu_gl":62,"ozel_topraga_bagli_degil_gl":344,"ozel_topraga_bagli_gl":1317,"toplam_gl":2456,"topraga_bagli_pay_yuzde":53.6,"topraga_bagli_degil_pay_yuzde":14,"cevre_pay_yuzde":29.8,"yil_no":2020},{"yil":"2021-22","cevre_gl":733,"su_kurumu_gl":48,"ozel_topraga_bagli_degil_gl":397,"ozel_topraga_bagli_gl":1322,"toplam_gl":2500,"topraga_bagli_pay_yuzde":52.9,"topraga_bagli_degil_pay_yuzde":15.9,"cevre_pay_yuzde":29.3,"yil_no":2021},{"yil":"2022-23","cevre_gl":739,"su_kurumu_gl":48,"ozel_topraga_bagli_degil_gl":435,"ozel_topraga_bagli_gl":1285,"toplam_gl":2507,"topraga_bagli_pay_yuzde":51.3,"topraga_bagli_degil_pay_yuzde":17.4,"cevre_pay_yuzde":29.5,"yil_no":2022},{"yil":"2023-24","cevre_gl":747,"su_kurumu_gl":50,"ozel_topraga_bagli_degil_gl":456,"ozel_topraga_bagli_gl":1262,"toplam_gl":2515,"topraga_bagli_pay_yuzde":50.2,"topraga_bagli_degil_pay_yuzde":18.1,"cevre_pay_yuzde":29.7,"yil_no":2023}],"_2008_09_tutarsizligi":"KAYNAK KENDİ İÇİNDE ÇELİŞİYOR — yalnız bu satırda. Rapor yüzdeleri çevre %1, kurum %2, topraksız %12, bağlı %85 diyor; aynı satırın hacimleri 0 / 0 / 125 / 2.163 GL, toplam 2.288 GL. Hacimlerden hesap %0 / %0 / %5,5 / %94,5. Diğer on yedi satırın tamamında rapor kendi hacmine oturuyor. Buradaki yüzdeler HESAPLANMIŞ değerlerdir. METİNDE 2008-09 YÜZDESİ ÜZERİNE CÜMLE KURULMAZ; temiz seri 2009-10'da başlar.","ilk_yil":"2000-01","son_yil":"2023-24","ilk_topraga_bagli_yuzde":100,"son_topraga_bagli_yuzde":50.2,"son_topraksiz_yuzde":18.1,"son_cevre_yuzde":29.7},"kullanim":{"_kaynak_niteligi":"SİCİLİN BEYANI — Victoria Su Sicili","_kapsam":"kuzey Victoria — Avustralya geneli DEĞİL","_tablo":"Table 6","_baslik":"Volumes of high-reliability water share tied to land compared to annual water use","_birim":"GL / %","kayitlar":[{"yil":"2004-05","topraga_bagli_gl":2252,"kullanim_gl":2151,"kullanim_oran_yuzde":96,"yil_no":2004},{"yil":"2008-09","topraga_bagli_gl":2163,"kullanim_gl":925,"kullanim_oran_yuzde":43,"yil_no":2008},{"yil":"2009-10","topraga_bagli_gl":1947,"kullanim_gl":1135,"kullanim_oran_yuzde":58,"yil_no":2009},{"yil":"2010-11","topraga_bagli_gl":1813,"kullanim_gl":751,"kullanim_oran_yuzde":41,"yil_no":2010},{"yil":"2011-12","topraga_bagli_gl":1635,"kullanim_gl":1732,"kullanim_oran_yuzde":106,"yil_no":2011},{"yil":"2012-13","topraga_bagli_gl":1569,"kullanim_gl":2402,"kullanim_oran_yuzde":153,"yil_no":2012},{"yil":"2013-14","topraga_bagli_gl":1552,"kullanim_gl":1857,"kullanim_oran_yuzde":120,"yil_no":2013},{"yil":"2014-15","topraga_bagli_gl":1516,"kullanim_gl":2033,"kullanim_oran_yuzde":134,"yil_no":2014},{"yil":"2015-16","topraga_bagli_gl":1473,"kullanim_gl":1762,"kullanim_oran_yuzde":120,"yil_no":2015},{"yil":"2016-17","topraga_bagli_gl":1428,"kullanim_gl":1454,"kullanim_oran_yuzde":102,"yil_no":2016},{"yil":"2017-18","topraga_bagli_gl":1390,"kullanim_gl":1967,"kullanim_oran_yuzde":142,"yil_no":2017},{"yil":"2018-19","topraga_bagli_gl":1355,"kullanim_gl":1752,"kullanim_oran_yuzde":129,"yil_no":2018},{"yil":"2019-20","topraga_bagli_gl":1331,"kullanim_gl":1113,"kullanim_oran_yuzde":84,"yil_no":2019},{"yil":"2020-21","topraga_bagli_gl":1317,"kullanim_gl":1545,"kullanim_oran_yuzde":117,"yil_no":2020},{"yil":"2021-22","topraga_bagli_gl":1322,"kullanim_gl":1564,"kullanim_oran_yuzde":118,"yil_no":2021},{"yil":"2022-23","topraga_bagli_gl":1285,"kullanim_gl":1273,"kullanim_oran_yuzde":99,"yil_no":2022},{"yil":"2023-24","topraga_bagli_gl":1262,"kullanim_gl":1716,"kullanim_oran_yuzde":136,"yil_no":2023}],"en_yuksek_oran":{"yil":"2012-13","oran":153},"en_dusuk_oran":{"yil":"2010-11","oran":41}},"pay_fiyati":{"_kaynak_niteligi":"SİCİLİN BEYANI — Victoria Su Sicili","_kapsam":"kuzey Victoria — Avustralya geneli DEĞİL","_tablo":"Table 4","_baslik":"Transfers and price of high-reliability water shares in northern Victoria","_birim":"GL / AUD-ML","kayitlar":[{"yil":"2008-09","devlete_devir_gl":8,"diger_devir_gl":154,"medyan_fiyat_aud_ml":2175,"yil_no":2008},{"yil":"2009-10","devlete_devir_gl":127,"diger_devir_gl":210,"medyan_fiyat_aud_ml":2200,"yil_no":2009},{"yil":"2010-11","devlete_devir_gl":113,"diger_devir_gl":98,"medyan_fiyat_aud_ml":1940,"yil_no":2010},{"yil":"2011-12","devlete_devir_gl":174,"diger_devir_gl":93,"medyan_fiyat_aud_ml":1800,"yil_no":2011},{"yil":"2012-13","devlete_devir_gl":31,"diger_devir_gl":104,"medyan_fiyat_aud_ml":1500,"yil_no":2012},{"yil":"2013-14","devlete_devir_gl":10,"diger_devir_gl":93,"medyan_fiyat_aud_ml":1380,"yil_no":2013},{"yil":"2014-15","devlete_devir_gl":25,"diger_devir_gl":99,"medyan_fiyat_aud_ml":1500,"yil_no":2014},{"yil":"2015-16","devlete_devir_gl":1,"diger_devir_gl":124,"medyan_fiyat_aud_ml":2400,"yil_no":2015},{"yil":"2016-17","devlete_devir_gl":5,"diger_devir_gl":151,"medyan_fiyat_aud_ml":2600,"yil_no":2016},{"yil":"2017-18","devlete_devir_gl":3,"diger_devir_gl":66,"medyan_fiyat_aud_ml":2850,"yil_no":2017},{"yil":"2018-19","devlete_devir_gl":null,"diger_devir_gl":112,"medyan_fiyat_aud_ml":3700,"yil_no":2018},{"yil":"2019-20","devlete_devir_gl":0,"diger_devir_gl":156,"medyan_fiyat_aud_ml":4800,"yil_no":2019},{"yil":"2020-21","devlete_devir_gl":1,"diger_devir_gl":88,"medyan_fiyat_aud_ml":4500,"yil_no":2020},{"yil":"2021-22","devlete_devir_gl":null,"diger_devir_gl":112,"medyan_fiyat_aud_ml":4950,"yil_no":2021},{"yil":"2022-23","devlete_devir_gl":null,"diger_devir_gl":82,"medyan_fiyat_aud_ml":5000,"yil_no":2022},{"yil":"2023-24","devlete_devir_gl":null,"diger_devir_gl":60,"medyan_fiyat_aud_ml":4500,"yil_no":2023}],"_nitelik":"yüksek güvenilirlikli","en_dusuk":{"yil":"2013-14","devlete_devir_gl":10,"diger_devir_gl":93,"medyan_fiyat_aud_ml":1380,"yil_no":2013},"en_yuksek":{"yil":"2022-23","devlete_devir_gl":null,"diger_devir_gl":82,"medyan_fiyat_aud_ml":5000,"yil_no":2022},"kat":3.62},"pay_fiyati_dusuk":{"_kaynak_niteligi":"SİCİLİN BEYANI — Victoria Su Sicili","_kapsam":"kuzey Victoria — Avustralya geneli DEĞİL","_tablo":"Table 5","_baslik":"Transfers and price of low-reliability water shares in northern Victoria","_birim":"GL / AUD-ML","kayitlar":[{"yil":"2008-09","devlete_devir_gl":1,"diger_devir_gl":74,"medyan_fiyat_aud_ml":200,"yil_no":2008},{"yil":"2009-10","devlete_devir_gl":20,"diger_devir_gl":35,"medyan_fiyat_aud_ml":175,"yil_no":2009},{"yil":"2010-11","devlete_devir_gl":1,"diger_devir_gl":53,"medyan_fiyat_aud_ml":150,"yil_no":2010},{"yil":"2011-12","devlete_devir_gl":0,"diger_devir_gl":64,"medyan_fiyat_aud_ml":140,"yil_no":2011},{"yil":"2012-13","devlete_devir_gl":null,"diger_devir_gl":47,"medyan_fiyat_aud_ml":150,"yil_no":2012},{"yil":"2013-14","devlete_devir_gl":0,"diger_devir_gl":32,"medyan_fiyat_aud_ml":185,"yil_no":2013},{"yil":"2014-15","devlete_devir_gl":null,"diger_devir_gl":40,"medyan_fiyat_aud_ml":225,"yil_no":2014},{"yil":"2015-16","devlete_devir_gl":null,"diger_devir_gl":35,"medyan_fiyat_aud_ml":244,"yil_no":2015},{"yil":"2016-17","devlete_devir_gl":null,"diger_devir_gl":61,"medyan_fiyat_aud_ml":250,"yil_no":2016},{"yil":"2017-18","devlete_devir_gl":null,"diger_devir_gl":26,"medyan_fiyat_aud_ml":340,"yil_no":2017},{"yil":"2018-19","devlete_devir_gl":null,"diger_devir_gl":55,"medyan_fiyat_aud_ml":500,"yil_no":2018},{"yil":"2019-20","devlete_devir_gl":null,"diger_devir_gl":36,"medyan_fiyat_aud_ml":500,"yil_no":2019},{"yil":"2020-21","devlete_devir_gl":null,"diger_devir_gl":37,"medyan_fiyat_aud_ml":470,"yil_no":2020},{"yil":"2021-22","devlete_devir_gl":null,"diger_devir_gl":44,"medyan_fiyat_aud_ml":650,"yil_no":2021},{"yil":"2022-23","devlete_devir_gl":null,"diger_devir_gl":44,"medyan_fiyat_aud_ml":895,"yil_no":2022},{"yil":"2023-24","devlete_devir_gl":null,"diger_devir_gl":30,"medyan_fiyat_aud_ml":850,"yil_no":2023}],"_nitelik":"düşük güvenilirlikli"},"topraksiz_su":{"_kaynak_niteligi":"SİCİLİN BEYANI — Victoria Su Sicili","_kapsam":"kuzey Victoria — Avustralya geneli DEĞİL","_tablo":"Table 16","_baslik":"How allocations made to private water shares not linked to land were used","_birim":"GL / %","kayitlar":[{"yil":"2007-08","ticari_satildi_gl":45,"sifirla_devredildi_gl":21,"kayip_buharlasma_gl":17,"devreden_gl":37,"devreden_yuzde":30,"yil_no":2007},{"yil":"2008-09","ticari_satildi_gl":39,"sifirla_devredildi_gl":21,"kayip_buharlasma_gl":10,"devreden_gl":33,"devreden_yuzde":32,"yil_no":2008},{"yil":"2009-10","ticari_satildi_gl":26,"sifirla_devredildi_gl":34,"kayip_buharlasma_gl":1,"devreden_gl":29,"devreden_yuzde":33,"yil_no":2009},{"yil":"2010-11","ticari_satildi_gl":35,"sifirla_devredildi_gl":37,"kayip_buharlasma_gl":3,"devreden_gl":62,"devreden_yuzde":45,"yil_no":2010},{"yil":"2011-12","ticari_satildi_gl":85,"sifirla_devredildi_gl":35,"kayip_buharlasma_gl":13,"devreden_gl":48,"devreden_yuzde":27,"yil_no":2011},{"yil":"2012-13","ticari_satildi_gl":87,"sifirla_devredildi_gl":49,"kayip_buharlasma_gl":7,"devreden_gl":21,"devreden_yuzde":13,"yil_no":2012},{"yil":"2013-14","ticari_satildi_gl":90,"sifirla_devredildi_gl":46,"kayip_buharlasma_gl":4,"devreden_gl":9,"devreden_yuzde":6,"yil_no":2013},{"yil":"2014-15","ticari_satildi_gl":149,"sifirla_devredildi_gl":76,"kayip_buharlasma_gl":3,"devreden_gl":12,"devreden_yuzde":5,"yil_no":2014},{"yil":"2015-16","ticari_satildi_gl":148,"sifirla_devredildi_gl":83,"kayip_buharlasma_gl":5,"devreden_gl":51,"devreden_yuzde":18,"yil_no":2015},{"yil":"2016-17","ticari_satildi_gl":226,"sifirla_devredildi_gl":165,"kayip_buharlasma_gl":6,"devreden_gl":110,"devreden_yuzde":22,"yil_no":2016},{"yil":"2017-18","ticari_satildi_gl":293,"sifirla_devredildi_gl":238,"kayip_buharlasma_gl":5,"devreden_gl":59,"devreden_yuzde":10,"yil_no":2017},{"yil":"2018-19","ticari_satildi_gl":351,"sifirla_devredildi_gl":210,"kayip_buharlasma_gl":6,"devreden_gl":65,"devreden_yuzde":10,"yil_no":2018},{"yil":"2019-20","ticari_satildi_gl":222,"sifirla_devredildi_gl":266,"kayip_buharlasma_gl":8,"devreden_gl":121,"devreden_yuzde":20,"yil_no":2019},{"yil":"2020-21","ticari_satildi_gl":311,"sifirla_devredildi_gl":240,"kayip_buharlasma_gl":13,"devreden_gl":171,"devreden_yuzde":23,"yil_no":2020},{"yil":"2021-22","ticari_satildi_gl":362,"sifirla_devredildi_gl":285,"kayip_buharlasma_gl":19,"devreden_gl":216,"devreden_yuzde":24,"yil_no":2021},{"yil":"2022-23","ticari_satildi_gl":396,"sifirla_devredildi_gl":349,"kayip_buharlasma_gl":24,"devreden_gl":317,"devreden_yuzde":29,"yil_no":2022},{"yil":"2023-24","ticari_satildi_gl":538,"sifirla_devredildi_gl":459,"kayip_buharlasma_gl":30,"devreden_gl":270,"devreden_yuzde":21,"yil_no":2023}]},"tahsis_ticareti":{"_kaynak_niteligi":"SİCİLİN BEYANI — Victoria Su Sicili","_kapsam":"kuzey Victoria — Avustralya geneli DEĞİL","_tablo":"Table 9","_baslik":"Summary of private annual allocation trade in northern Victoria","_birim":"GL / adet / ML","kayitlar":[{"yil":"2007-08","ticari_hacim_gl":371,"sifir_fiyatli_hacim_gl":168,"toplam_hacim_gl":539,"ticari_islem":12996,"sifir_fiyatli_islem":4707,"toplam_islem":17703,"yuzde":38,"ort_parca_ticari_ml":29,"ort_parca_sifir_ml":36,"ort_parca_toplam_ml":30,"yil_no":2007},{"yil":"2008-09","ticari_hacim_gl":460,"sifir_fiyatli_hacim_gl":159,"toplam_hacim_gl":618,"ticari_islem":10810,"sifir_fiyatli_islem":4484,"toplam_islem":15294,"yuzde":59,"ort_parca_ticari_ml":43,"ort_parca_sifir_ml":35,"ort_parca_toplam_ml":40,"yil_no":2008},{"yil":"2009-10","ticari_hacim_gl":448,"sifir_fiyatli_hacim_gl":294,"toplam_hacim_gl":741,"ticari_islem":7277,"sifir_fiyatli_islem":3080,"toplam_islem":10357,"yuzde":39,"ort_parca_ticari_ml":62,"ort_parca_sifir_ml":95,"ort_parca_toplam_ml":72,"yil_no":2009},{"yil":"2010-11","ticari_hacim_gl":404,"sifir_fiyatli_hacim_gl":372,"toplam_hacim_gl":776,"ticari_islem":2209,"sifir_fiyatli_islem":1657,"toplam_islem":3866,"yuzde":28,"ort_parca_ticari_ml":183,"ort_parca_sifir_ml":225,"ort_parca_toplam_ml":201,"yil_no":2010},{"yil":"2011-12","ticari_hacim_gl":715,"sifir_fiyatli_hacim_gl":436,"toplam_hacim_gl":1150,"ticari_islem":3513,"sifir_fiyatli_islem":2283,"toplam_islem":5796,"yuzde":28,"ort_parca_ticari_ml":204,"ort_parca_sifir_ml":191,"ort_parca_toplam_ml":198,"yil_no":2011},{"yil":"2012-13","ticari_hacim_gl":1025,"sifir_fiyatli_hacim_gl":369,"toplam_hacim_gl":1394,"ticari_islem":7955,"sifir_fiyatli_islem":3832,"toplam_islem":11787,"yuzde":40,"ort_parca_ticari_ml":129,"ort_parca_sifir_ml":96,"ort_parca_toplam_ml":118,"yil_no":2012},{"yil":"2013-14","ticari_hacim_gl":902,"sifir_fiyatli_hacim_gl":382,"toplam_hacim_gl":1284,"ticari_islem":8410,"sifir_fiyatli_islem":4022,"toplam_islem":12432,"yuzde":58,"ort_parca_ticari_ml":107,"ort_parca_sifir_ml":95,"ort_parca_toplam_ml":103,"yil_no":2013},{"yil":"2014-15","ticari_hacim_gl":855,"sifir_fiyatli_hacim_gl":455,"toplam_hacim_gl":1310,"ticari_islem":9446,"sifir_fiyatli_islem":4653,"toplam_islem":14099,"yuzde":56,"ort_parca_ticari_ml":91,"ort_parca_sifir_ml":98,"ort_parca_toplam_ml":93,"yil_no":2014},{"yil":"2015-16","ticari_hacim_gl":794,"sifir_fiyatli_hacim_gl":523,"toplam_hacim_gl":1317,"ticari_islem":9424,"sifir_fiyatli_islem":5133,"toplam_islem":14557,"yuzde":66,"ort_parca_ticari_ml":84,"ort_parca_sifir_ml":102,"ort_parca_toplam_ml":90,"yil_no":2015},{"yil":"2016-17","ticari_hacim_gl":928,"sifir_fiyatli_hacim_gl":766,"toplam_hacim_gl":1694,"ticari_islem":7571,"sifir_fiyatli_islem":4517,"toplam_islem":12088,"yuzde":83,"ort_parca_ticari_ml":123,"ort_parca_sifir_ml":170,"ort_parca_toplam_ml":140,"yil_no":2016},{"yil":"2017-18","ticari_hacim_gl":1088,"sifir_fiyatli_hacim_gl":820,"toplam_hacim_gl":1908,"ticari_islem":10454,"sifir_fiyatli_islem":5051,"toplam_islem":15505,"yuzde":76,"ort_parca_ticari_ml":104,"ort_parca_sifir_ml":162,"ort_parca_toplam_ml":123,"yil_no":2017},{"yil":"2018-19","ticari_hacim_gl":1038,"sifir_fiyatli_hacim_gl":716,"toplam_hacim_gl":1754,"ticari_islem":14571,"sifir_fiyatli_islem":5194,"toplam_islem":19765,"yuzde":82,"ort_parca_ticari_ml":71,"ort_parca_sifir_ml":138,"ort_parca_toplam_ml":89,"yil_no":2018},{"yil":"2019-20","ticari_hacim_gl":914,"sifir_fiyatli_hacim_gl":965,"toplam_hacim_gl":1878,"ticari_islem":12518,"sifir_fiyatli_islem":7175,"toplam_islem":19693,"yuzde":119,"ort_parca_ticari_ml":73,"ort_parca_sifir_ml":134,"ort_parca_toplam_ml":95,"yil_no":2019},{"yil":"2020-21","ticari_hacim_gl":1212,"sifir_fiyatli_hacim_gl":884,"toplam_hacim_gl":2096,"ticari_islem":11151,"sifir_fiyatli_islem":4667,"toplam_islem":15818,"yuzde":91,"ort_parca_ticari_ml":109,"ort_parca_sifir_ml":189,"ort_parca_toplam_ml":133,"yil_no":2020},{"yil":"2021-22","ticari_hacim_gl":1224,"sifir_fiyatli_hacim_gl":820,"toplam_hacim_gl":2044,"ticari_islem":9510,"sifir_fiyatli_islem":3802,"toplam_islem":13312,"yuzde":81,"ort_parca_ticari_ml":129,"ort_parca_sifir_ml":216,"ort_parca_toplam_ml":154,"yil_no":2021},{"yil":"2022-23","ticari_hacim_gl":1252,"sifir_fiyatli_hacim_gl":911,"toplam_hacim_gl":2163,"ticari_islem":7039,"sifir_fiyatli_islem":2856,"toplam_islem":9895,"yuzde":88,"ort_parca_ticari_ml":178,"ort_parca_sifir_ml":319,"ort_parca_toplam_ml":219,"yil_no":2022},{"yil":"2023-24","ticari_hacim_gl":1445,"sifir_fiyatli_hacim_gl":1009,"toplam_hacim_gl":2454,"ticari_islem":10162,"sifir_fiyatli_islem":3614,"toplam_islem":13776,"yuzde":81,"ort_parca_ticari_ml":142,"ort_parca_sifir_ml":279,"ort_parca_toplam_ml":178,"yil_no":2023}]},"piyasa_katilimi":{"_kaynak_niteligi":"SİCİLİN BEYANI — Victoria Su Sicili","_kapsam":"kuzey Victoria — Avustralya geneli DEĞİL","_tablo":"Table 1","_baslik":"Number of unique allocation accounts involved in commercial trade in the Goulburn and Murray","_birim":"hesap adedi","kayitlar":[{"yil":"2015-16","sik_ticaret_yapan":50,"diger":6844,"toplam":6894,"sik_ticaret_yapan_yuzde":0.73,"yil_no":2015},{"yil":"2016-17","sik_ticaret_yapan":48,"diger":5540,"toplam":5588,"sik_ticaret_yapan_yuzde":0.86,"yil_no":2016},{"yil":"2017-18","sik_ticaret_yapan":68,"diger":7425,"toplam":7493,"sik_ticaret_yapan_yuzde":0.91,"yil_no":2017},{"yil":"2018-19","sik_ticaret_yapan":99,"diger":8617,"toplam":8716,"sik_ticaret_yapan_yuzde":1.14,"yil_no":2018},{"yil":"2019-20","sik_ticaret_yapan":104,"diger":7249,"toplam":7353,"sik_ticaret_yapan_yuzde":1.41,"yil_no":2019},{"yil":"2020-21","sik_ticaret_yapan":74,"diger":6919,"toplam":6993,"sik_ticaret_yapan_yuzde":1.06,"yil_no":2020},{"yil":"2021-22","sik_ticaret_yapan":76,"diger":6364,"toplam":6440,"sik_ticaret_yapan_yuzde":1.18,"yil_no":2021},{"yil":"2022-23","sik_ticaret_yapan":61,"diger":5188,"toplam":5249,"sik_ticaret_yapan_yuzde":1.16,"yil_no":2022},{"yil":"2023-24","sik_ticaret_yapan":84,"diger":6465,"toplam":6549,"sik_ticaret_yapan_yuzde":1.28,"yil_no":2023}],"_bulgu":"no evidence of systematic differences in the price"},"kaynak_dagilimi":{"_kaynak_niteligi":"SİCİLİN BEYANI — Victoria Su Sicili","_kapsam":"kuzey Victoria — Avustralya geneli DEĞİL","_tablo":"Table 19","_baslik":"Where did northern Victorian irrigators source their water from each year?","_birim":"GL","kayitlar":[{"yil":"2007-08","gmw_bolge":{"devreden_gl":40,"yeni_mevsimlik_gl":797,"net_ticaret_gl":-43,"kullanim_gl":657},"gmw_ceken":{"devreden_gl":10,"yeni_mevsimlik_gl":102,"net_ticaret_gl":-14,"kullanim_gl":61},"lmw_bolge":{"devreden_gl":21,"yeni_mevsimlik_gl":91,"net_ticaret_gl":30,"kullanim_gl":82},"lmw_ceken":{"devreden_gl":37,"yeni_mevsimlik_gl":141,"net_ticaret_gl":98,"kullanim_gl":201},"ara_toplam":{"devreden_gl":108,"yeni_mevsimlik_gl":1131,"net_ticaret_gl":72,"kullanim_gl":1001},"yil_no":2007},{"yil":"2008-09","gmw_bolge":{"devreden_gl":117,"yeni_mevsimlik_gl":473,"net_ticaret_gl":93,"kullanim_gl":556},"gmw_ceken":{"devreden_gl":19,"yeni_mevsimlik_gl":52,"net_ticaret_gl":0,"kullanim_gl":43},"lmw_bolge":{"devreden_gl":29,"yeni_mevsimlik_gl":52,"net_ticaret_gl":45,"kullanim_gl":89},"lmw_ceken":{"devreden_gl":53,"yeni_mevsimlik_gl":116,"net_ticaret_gl":115,"kullanim_gl":237},"ara_toplam":{"devreden_gl":218,"yeni_mevsimlik_gl":694,"net_ticaret_gl":254,"kullanim_gl":925},"yil_no":2008},{"yil":"2009-10","gmw_bolge":{"devreden_gl":120,"yeni_mevsimlik_gl":1029,"net_ticaret_gl":58,"kullanim_gl":745},"gmw_ceken":{"devreden_gl":14,"yeni_mevsimlik_gl":75,"net_ticaret_gl":-7,"kullanim_gl":33},"lmw_bolge":{"devreden_gl":35,"yeni_mevsimlik_gl":109,"net_ticaret_gl":1,"kullanim_gl":87},"lmw_ceken":{"devreden_gl":46,"yeni_mevsimlik_gl":246,"net_ticaret_gl":115,"kullanim_gl":269},"ara_toplam":{"devreden_gl":215,"yeni_mevsimlik_gl":1459,"net_ticaret_gl":167,"kullanim_gl":1135},"yil_no":2009},{"yil":"2010-11","gmw_bolge":{"devreden_gl":410,"yeni_mevsimlik_gl":1187,"net_ticaret_gl":105,"kullanim_gl":495},"gmw_ceken":{"devreden_gl":31,"yeni_mevsimlik_gl":87,"net_ticaret_gl":2,"kullanim_gl":19},"lmw_bolge":{"devreden_gl":52,"yeni_mevsimlik_gl":133,"net_ticaret_gl":-1,"kullanim_gl":43},"lmw_ceken":{"devreden_gl":125,"yeni_mevsimlik_gl":273,"net_ticaret_gl":211,"kullanim_gl":194},"ara_toplam":{"devreden_gl":618,"yeni_mevsimlik_gl":1680,"net_ticaret_gl":317,"kullanim_gl":751},"yil_no":2010},{"yil":"2011-12","gmw_bolge":{"devreden_gl":1201,"yeni_mevsimlik_gl":1171,"net_ticaret_gl":199,"kullanim_gl":1269},"gmw_ceken":{"devreden_gl":104,"yeni_mevsimlik_gl":102,"net_ticaret_gl":2,"kullanim_gl":58},"lmw_bolge":{"devreden_gl":139,"yeni_mevsimlik_gl":128,"net_ticaret_gl":-7,"kullanim_gl":84},"lmw_ceken":{"devreden_gl":434,"yeni_mevsimlik_gl":255,"net_ticaret_gl":34,"kullanim_gl":320},"ara_toplam":{"devreden_gl":1878,"yeni_mevsimlik_gl":1656,"net_ticaret_gl":229,"kullanim_gl":1732},"yil_no":2011},{"yil":"2012-13","gmw_bolge":{"devreden_gl":935,"yeni_mevsimlik_gl":1048,"net_ticaret_gl":297,"kullanim_gl":1777},"gmw_ceken":{"devreden_gl":115,"yeni_mevsimlik_gl":120,"net_ticaret_gl":-39,"kullanim_gl":104},"lmw_bolge":{"devreden_gl":153,"yeni_mevsimlik_gl":122,"net_ticaret_gl":-49,"kullanim_gl":114},"lmw_ceken":{"devreden_gl":347,"yeni_mevsimlik_gl":224,"net_ticaret_gl":97,"kullanim_gl":407},"ara_toplam":{"devreden_gl":1550,"yeni_mevsimlik_gl":1515,"net_ticaret_gl":306,"kullanim_gl":2402},"yil_no":2012},{"yil":"2013-14","gmw_bolge":{"devreden_gl":381,"yeni_mevsimlik_gl":999,"net_ticaret_gl":431,"kullanim_gl":1317},"gmw_ceken":{"devreden_gl":44,"yeni_mevsimlik_gl":117,"net_ticaret_gl":-15,"kullanim_gl":88},"lmw_bolge":{"devreden_gl":9,"yeni_mevsimlik_gl":119,"net_ticaret_gl":-1,"kullanim_gl":98},"lmw_ceken":{"devreden_gl":27,"yeni_mevsimlik_gl":228,"net_ticaret_gl":166,"kullanim_gl":354},"ara_toplam":{"devreden_gl":461,"yeni_mevsimlik_gl":1463,"net_ticaret_gl":581,"kullanim_gl":1857},"yil_no":2013},{"yil":"2014-15","gmw_bolge":{"devreden_gl":451,"yeni_mevsimlik_gl":981,"net_ticaret_gl":305,"kullanim_gl":1451},"gmw_ceken":{"devreden_gl":40,"yeni_mevsimlik_gl":116,"net_ticaret_gl":-21,"kullanim_gl":89},"lmw_bolge":{"devreden_gl":20,"yeni_mevsimlik_gl":118,"net_ticaret_gl":-15,"kullanim_gl":94},"lmw_ceken":{"devreden_gl":54,"yeni_mevsimlik_gl":232,"net_ticaret_gl":168,"kullanim_gl":399},"ara_toplam":{"devreden_gl":566,"yeni_mevsimlik_gl":1447,"net_ticaret_gl":437,"kullanim_gl":2033},"yil_no":2014},{"yil":"2015-16","gmw_bolge":{"devreden_gl":264,"yeni_mevsimlik_gl":907,"net_ticaret_gl":267,"kullanim_gl":1157},"gmw_ceken":{"devreden_gl":33,"yeni_mevsimlik_gl":104,"net_ticaret_gl":-14,"kullanim_gl":79},"lmw_bolge":{"devreden_gl":26,"yeni_mevsimlik_gl":118,"net_ticaret_gl":6,"kullanim_gl":102},"lmw_ceken":{"devreden_gl":48,"yeni_mevsimlik_gl":212,"net_ticaret_gl":260,"kullanim_gl":424},"ara_toplam":{"devreden_gl":371,"yeni_mevsimlik_gl":1341,"net_ticaret_gl":519,"kullanim_gl":1762},"yil_no":2015},{"yil":"2016-17","gmw_bolge":{"devreden_gl":238,"yeni_mevsimlik_gl":934,"net_ticaret_gl":372,"kullanim_gl":929},"gmw_ceken":{"devreden_gl":24,"yeni_mevsimlik_gl":114,"net_ticaret_gl":-5,"kullanim_gl":64},"lmw_bolge":{"devreden_gl":0,"yeni_mevsimlik_gl":118,"net_ticaret_gl":-3,"kullanim_gl":87},"lmw_ceken":{"devreden_gl":14,"yeni_mevsimlik_gl":207,"net_ticaret_gl":192,"kullanim_gl":374},"ara_toplam":{"devreden_gl":276,"yeni_mevsimlik_gl":1373,"net_ticaret_gl":556,"kullanim_gl":1454},"yil_no":2016},{"yil":"2017-18","gmw_bolge":{"devreden_gl":572,"yeni_mevsimlik_gl":900,"net_ticaret_gl":186,"kullanim_gl":1341},"gmw_ceken":{"devreden_gl":51,"yeni_mevsimlik_gl":115,"net_ticaret_gl":-24,"kullanim_gl":93},"lmw_bolge":{"devreden_gl":16,"yeni_mevsimlik_gl":115,"net_ticaret_gl":-10,"kullanim_gl":101},"lmw_ceken":{"devreden_gl":46,"yeni_mevsimlik_gl":232,"net_ticaret_gl":191,"kullanim_gl":432},"ara_toplam":{"devreden_gl":686,"yeni_mevsimlik_gl":1362,"net_ticaret_gl":342,"kullanim_gl":1967},"yil_no":2017},{"yil":"2018-19","gmw_bolge":{"devreden_gl":296,"yeni_mevsimlik_gl":873,"net_ticaret_gl":133,"kullanim_gl":1093},"gmw_ceken":{"devreden_gl":37,"yeni_mevsimlik_gl":111,"net_ticaret_gl":-23,"kullanim_gl":86},"lmw_bolge":{"devreden_gl":18,"yeni_mevsimlik_gl":109,"net_ticaret_gl":6,"kullanim_gl":110},"lmw_ceken":{"devreden_gl":28,"yeni_mevsimlik_gl":205,"net_ticaret_gl":268,"kullanim_gl":462},"ara_toplam":{"devreden_gl":379,"yeni_mevsimlik_gl":1298,"net_ticaret_gl":385,"kullanim_gl":1751},"yil_no":2018},{"yil":"2019-20","gmw_bolge":{"devreden_gl":192,"yeni_mevsimlik_gl":622,"net_ticaret_gl":71,"kullanim_gl":531},"gmw_ceken":{"devreden_gl":27,"yeni_mevsimlik_gl":83,"net_ticaret_gl":-13,"kullanim_gl":51},"lmw_bolge":{"devreden_gl":20,"yeni_mevsimlik_gl":70,"net_ticaret_gl":35,"kullanim_gl":98},"lmw_ceken":{"devreden_gl":42,"yeni_mevsimlik_gl":151,"net_ticaret_gl":304,"kullanim_gl":433},"ara_toplam":{"devreden_gl":281,"yeni_mevsimlik_gl":926,"net_ticaret_gl":398,"kullanim_gl":1112},"yil_no":2019},{"yil":"2020-21","gmw_bolge":{"devreden_gl":332,"yeni_mevsimlik_gl":819,"net_ticaret_gl":337,"kullanim_gl":942},"gmw_ceken":{"devreden_gl":36,"yeni_mevsimlik_gl":114,"net_ticaret_gl":-11,"kullanim_gl":69},"lmw_bolge":{"devreden_gl":25,"yeni_mevsimlik_gl":101,"net_ticaret_gl":14,"kullanim_gl":98},"lmw_ceken":{"devreden_gl":59,"yeni_mevsimlik_gl":225,"net_ticaret_gl":240,"kullanim_gl":436},"ara_toplam":{"devreden_gl":452,"yeni_mevsimlik_gl":1260,"net_ticaret_gl":580,"kullanim_gl":1545},"yil_no":2020},{"yil":"2021-22","gmw_bolge":{"devreden_gl":331,"yeni_mevsimlik_gl":1006,"net_ticaret_gl":281,"kullanim_gl":956},"gmw_ceken":{"devreden_gl":31,"yeni_mevsimlik_gl":121,"net_ticaret_gl":-2,"kullanim_gl":65},"lmw_bolge":{"devreden_gl":0,"yeni_mevsimlik_gl":99,"net_ticaret_gl":19,"kullanim_gl":93},"lmw_ceken":{"devreden_gl":7,"yeni_mevsimlik_gl":239,"net_ticaret_gl":254,"kullanim_gl":449},"ara_toplam":{"devreden_gl":369,"yeni_mevsimlik_gl":1465,"net_ticaret_gl":553,"kullanim_gl":1564},"yil_no":2021},{"yil":"2022-23","gmw_bolge":{"devreden_gl":-7,"yeni_mevsimlik_gl":1259,"net_ticaret_gl":315,"kullanim_gl":816},"gmw_ceken":{"devreden_gl":7,"yeni_mevsimlik_gl":124,"net_ticaret_gl":5,"kullanim_gl":53},"lmw_bolge":{"devreden_gl":0,"yeni_mevsimlik_gl":91,"net_ticaret_gl":22,"kullanim_gl":75},"lmw_ceken":{"devreden_gl":3,"yeni_mevsimlik_gl":247,"net_ticaret_gl":147,"kullanim_gl":329},"ara_toplam":{"devreden_gl":4,"yeni_mevsimlik_gl":1721,"net_ticaret_gl":489,"kullanim_gl":1272},"yil_no":2022},{"yil":"2023-24","gmw_bolge":{"devreden_gl":405,"yeni_mevsimlik_gl":1182,"net_ticaret_gl":297,"kullanim_gl":1130},"gmw_ceken":{"devreden_gl":35,"yeni_mevsimlik_gl":130,"net_ticaret_gl":-3,"kullanim_gl":73},"lmw_bolge":{"devreden_gl":7,"yeni_mevsimlik_gl":91,"net_ticaret_gl":32,"kullanim_gl":94},"lmw_ceken":{"devreden_gl":20,"yeni_mevsimlik_gl":237,"net_ticaret_gl":240,"kullanim_gl":418},"ara_toplam":{"devreden_gl":467,"yeni_mevsimlik_gl":1640,"net_ticaret_gl":566,"kullanim_gl":1716},"yil_no":2023}]},"darlik_fiyati":{"_kaynak_niteligi":"SİCİLİN BEYANI — Victoria Su Sicili, eğilim raporu","_kapsam":"kuzey Victoria, Murray 7. bölge (Barmah'ın aşağısı)","bolge":"Murray zone 7 — Barmah'ın aşağısı","dusuk_guvenilir_2018_07_aud_ml":444,"dusuk_guvenilir_2024_06_aud_ml":1861,"artis_kati":4.19,"alinti":"low-reliability water share prices increased from $444 per ML in July 2018 to $1,861 per ML in June 2024","neden_alintisi":"increasing allocation trade restrictions into the region","talep_alintisi":"growth in perennial horticulture demand downstream of Barmah","_not":"Rapor nedeni İKİ etkene bağlıyor: bahçe talebinin yüksek ödeme isteği VE bölgeye tahsis ticareti kısıtlarının artması. Tek nedene indirgenmeyecek."},"ticarete_bagimlilik":{"_kaynak_niteligi":"SİCİLİN BEYANI — Victoria Su Sicili, eğilim raporu","_kapsam":"kuzey Victoria","yil":"2023-24","alinti":"LMW diverters are the private water user group most dependent on trade","lmw_ceken_kendi_kaynagi_yuzde":61,"lmw_ceken_yeni_mevsimlik_gl":237,"lmw_ceken_devreden_gl":20,"gmw_bolge_yuzde":140,"gmw_ceken_yuzde":223,"lmw_bolge_yuzde":103,"oran_alintisi":"accounted for only 61% of LMW diverters"},"ticaret_gerekcesi":{"_kaynak_niteligi":"SİCİLİN BEYANI — Victoria Su Sicili, eğilim raporu","_kapsam":"kuzey Victoria","baslangic_yili":"2020-21","baslangic_alintisi":"2020-21 was the year collection for","kategori_alintisi":"standard commercial trade, related party trade, carryover parking, carryover parking return, private lease arrangement, allocation trade as part of a water share transfer, forward contract","kategori_sayisi":8,"_not":"Sekizinci kategori 'other'. Listede 'forward contract' ve 'private lease arrangement' var — vadeli sözleşme ve özel kira."},"kura":{"_kaynak_niteligi":"BİRİNCİL (ACCC beyanı) + SİCİLİN BEYANI (açılış raporu)","_kapsam":"Victoria ve NSW başvuruları, 2 Temmuz 2026 açılışı","_uyari":"İKİ AYRI AÇILIŞ. Barmah'ta darlık var, Goulburn→Murray'de yok. Rakamları karıştırmak kolay; ilk özette karıştırılmıştı.","basvuru_gunu":"2026-07-02","cekilis_gunu":"2026-07-03","bogaz_akis_siniri_ml_gun":7000,"bogaz_alintisi":"restricts the river flow to just around 7,000 ML per day","kura_alintisi":"eligible applications were randomised to determine the order in which they would be processed","gozlem_alintisi":"independently observed by the Australian Competition and Consumer Commission","gecici_cozum":"The randomisation approach has been implemented as an interim solution","accc":{"_kaynak_niteligi":"BİRİNCİL — ACCC'nin imzalı yazısı, 3 Ağustos 2026","imza":"Acting General Manager","kayit_incelemesi":"reviewed a recording of that process","duzenleme_yok":"did not observe any editing or changes to the output of the randomisation tool"},"barmah":{"_darlik":true,"kapasite_ml":24121.3,"kapasite_alintisi":"The total Barmah trade opportunity made available at 7:00 am 2 July was 24,121.3 ML","uygun_basvuru_toplam":214,"uygun_hacim_toplam_ml":67445.2,"talep_alintisi":"significantly exceeded the available trade oppor tunity","vic":{"alinan":138,"alinan_hacim_ml":31477.8,"uygun":136,"uygun_hacim_ml":31253.1,"onaylanan":33,"onaylanan_hacim_ml":8884.2,"reddedilen":103,"reddedilen_hacim_ml":22386.9},"nsw":{"uygun":78,"uygun_hacim_ml":36192.1,"onaylanan":29,"onaylanan_hacim_ml":15218.2},"vic_en_kucuk_ml":20.4,"vic_en_buyuk_ml":2484.4,"vic_ortanca_ml":110,"vic_ortalama_ml":230,"aracidan_basvuru":73,"aracidan_hacim_ml":17645.5,"cevrimici_basvuru":65,"cevrimici_hacim_ml":13832.3,"kanal_alintisi":"73 applications were received via the Broker Portal","ortanca_alintisi":"The median volume of Victorian applications was 110 ML","toplam_onaylanan":62,"onay_orani_yuzde":29,"vic_onay_orani_yuzde":24.3,"asim_kati":2.8},"goulburn_murray":{"_darlik":false,"_kapsam_notu":"Bu açılışın rakamları EYALET AYRIMI OLMADAN, iki eyaletin toplamı olarak yayımlanmış. Barmah rakamları ise eyalet eyalet. Karşılaştırma TOPLAMLAR üzerinden; Victoria'ya özel oranla yan yana konmaz.","kapasite_ml":112827.9,"kapasite_alintisi":"The total Goulburn-to-Murray trade opportunity made available at 7:00 am 2 July 2026 was 112,827.9 ML","alinan":290,"alinan_hacim_ml":120869.9,"uygun":286,"uygun_hacim_ml":119285.3,"onaylanan":282,"onaylanan_hacim_ml":112555.3,"reddedilen":4,"reddedilen_hacim_ml":6730,"onay_orani_yuzde":98.6,"asim_kati":1.07},"talep_kapasite_kati":2.8},"kuraklik":{"_kaynak_niteligi":"BAĞIMSIZ — Meteoroloji Bürosu","_kapsam":"Avustralya geneli; bildiriler BÖLGE bölge yazılmış","bildiri_sayisi":192,"ilk":"2000-01-10","son":"2016-08-04","bildirisiz_dizi_ay":8,"bildirisiz_dizi":"Ekim 2011 – Mayıs 2012","ilan_yok":"the Bureau does not declare a drought","ilan_yok_devam":"The Australian Government does not make drought declarations","eyalet_yetkisi":"State and territory governments administer and coordinate drought policies","tanim":"a prolonged, abnormally dry period when there's not enough water available for normal use","_bolge_uyarisi":"2011'de yayımlanan bildiriler güneybatı Batı Avustralya'yı anlatıyor, Murray-Darling'i değil. Doğudaki kuraklık o sırada kırılmıştı. 'Avustralya'nın kuraklığı' denmeyecek.","_zamanlama_uyarisi":"Bildirisiz dizi su yılı 2011-12'ye düşüyor (kullanım oranı %118). En düşük oran (%41) 2010-11'de. 'Büro susunca kullanım düştü' nedenselliği KURULAMAZ."},"ulusal":{"_kaynak_niteligi":"BAĞIMSIZ — Meteoroloji Bürosu, Water in Australia 2019–20","_kapsam":"Avustralya geneli","_zaman_farki":"Bu blok 2019-20'ye ait. Piyasa serileri 2023-24'e kadar geliyor. DÖRT YILLIK FARK; aynı cümlede aynı yılmış gibi sunulmayacak. Raporun 2020-21 ve sonrası sürümleri yayımda değil.","yil":"2019-20","tuketim_toplam_gl":14270,"tuketim_alintisi":"Total water taken in Australia for consumptive use was 14 270 GL","vic_nsw_payi":"Agricultural water-use in Victoria and New South Wales accounted for half of Australia","nsw_tarim_gl":2490,"depo_doluluk_gl":23140,"depo_doluluk_yuzde":46,"depo_kapasite_gl":50500,"piyasa_cirosu":"1–7 milyar AUD/yıl (BoM tahmini)","_ciro_uyarisi":"Aralık çok geniş; 'tahmini' ibaresi düşürülmeyecek."},"kronoloji":{"_kaynak_niteligi":"TÜRETİLMİŞ — yukarıdaki bloklardaki tarihlerin sayısal izdüşümü; yeni olgu içermez","_kapsam":"Victoria","kanun_yili":1989,"dayanak_tasdik_yili":2005,"yururluk_yili":2006,"ayrisma_yili":2007,"tavan_kaldirma_yili":2009,"cikis_tavani_kaldirma_yili":2014,"birliktelik_kaldirma_yili":2023,"kura_yili":2026,"ulusal_olcum_yili":2019},"metin_rakamlari":{"_kaynak_niteligi":"TÜRETİLMİŞ — yukarıdaki blokların ölçek çevrimleri","_amac":"Metnin kullandığı ölçek çevrimleri ve türetmeler. Kaynağı bu dosyanın kendi blokları; buradaki her değer yukarıdaki ham sayıdan hesaplandı.","_kapsam":"Türetilmiş — kaynağı her satırın kendi bloğu","dunyaya_tarim_milyar_usd":41.869,"dunyaya_fasil_milyon_usd":{"10":8250.39,"12":3990.71,"15":1003.307,"22":2164.696,"02":13992.221,"07":2570.011,"04":2283.358,"08":1937.423,"03":781.682},"lif_milyon_usd":{"yun":1792.163,"pamuk":2432.357},"seri_milyon_usd":{"2005":{"yun":1781.125,"et":5142.986,"hububat":2915.393},"2010":{"yun":2055.81,"et":6101.456,"hububat":4705.079},"2015":{"yun":2200.388,"et":9815.385,"hububat":6427.637},"2020":{"yun":1536.612,"et":10050.61,"hububat":3751.741},"2024":{"yun":1792.163,"et":13992.221,"hububat":8250.39}},"tur_aus_milyon_usd":181.882,"aus_tur_milyon_usd":59.223,"tur_aus_fasil_milyon_usd":{"15":13.729,"19":8.756,"20":44.956,"08":84.89},"aus_tur_fasil_milyon_usd":{"05":3.228,"02":0.753,"04":0.333,"07":0.242},"tur_aus_hs08_milyon_usd":{"0802":27.267,"0813":21.802,"0806":21.465,"0804":14.142},"aus_tur_hs08_milyon_usd":{"0802":53.984},"denge_kat":3.07,"turkiye_payi_yuzde":0.141,"alan_milyon_ha":{"Wheat":10.507,"Barley":4.001,"Canola":3.715},"uretim_milyon_t":{"Barley":10.962,"Canola":7.505,"Lentils":1.413,"Sugarcane":29.855,"Rice":0.619},"deger_milyon_aud":{"Wheat":8830.462,"Canola":4483.017,"Lentils":1194.301},"mercimek_ton_isletme":593.7,"sekerkamisi_t_ha":87.7,"kalan_onbir_ha":11841636,"bugday_pay_yuzde":47,"bugday_kat_arpa":2.63,"sekerkamisi_kat_bugday":32.8}}$dsr$::jsonb,
  $dsr${"dort_rakam":{"tur":"kunye","baslik":{"tr":"Dosyanın dört rakamı","en":"Four figures from this dossier"},"not":{"tr":"Ülkenin yarıya yakını tarım arazisi; tarım ekonominin yirmi beşte biri, istihdamın kırk beşte biri. Ve bu kadar az insanla kırk bir milyar dolarlık ihracat yapılıyor.","en":"Nearly half the country is agricultural land; agriculture is a twenty-fifth of the economy and a forty-fifth of employment. And that few people export forty-one billion dollars' worth."},"kaynak":"Dünya Bankası; UN Comtrade","kalemler":[{"deger":47.2234443228177,"ondalik":1,"sonek":{"tr":"%","en":"%"},"etiket":{"tr":"ülke yüzölçümünün tarım arazisi olan payı","en":"share of the country's land area that is agricultural"},"alt":{"tr":"2023","en":"2023"}},{"deger":2.03565265249391,"ondalik":2,"sonek":{"tr":"%","en":"%"},"etiket":{"tr":"tarımın gayrisafi yurt içi hasıladaki payı","en":"agriculture's share of gross domestic product"},"alt":{"tr":"2024","en":"2024"}},{"deger":2.2305246861444,"ondalik":2,"sonek":{"tr":"%","en":"%"},"etiket":{"tr":"tarımda çalışanların toplam istihdamdaki payı","en":"agriculture's share of total employment"},"alt":{"tr":"2024","en":"2024"}},{"deger":41868857139.17999,"bolen":1000000000,"ondalik":2,"onek":{"tr":"$","en":"$"},"etiket":{"tr":"tarım ihracatı, milyar dolar","en":"agricultural exports, billion dollars"},"alt":{"tr":"2024 · HS 01-24","en":"2024 · HS 01-24"}}]},"tarim_ihracati":{"tur":"siralama","baslik":{"tr":"Avustralya dünyaya ne satıyor","en":"What Australia sells the world"},"birim":{"tr":"milyar dolar, 2024","en":"billion dollars, 2024"},"bolen":1000000000,"ondalik":2,"onek":{"tr":"$","en":"$"},"not":{"tr":"HS 01-24 fasılları. Yün ve pamuk bu aralığın dışında kalır — ikisi ayrı bölümde. Çift sayıma karşı gümrük rejimi, taşıma türü ve ikinci partner boyutları süzüldü.","en":"HS chapters 01-24. Wool and cotton fall outside this range — both have their own section. Customs procedure, mode of transport and second-partner dimensions were filtered against double counting."},"kaynak":"UN Comtrade, 2024","satirlar":[{"etiket":{"tr":"Et","en":"Meat"},"deger":13992221025.745,"rol":"vurgu"},{"etiket":{"tr":"Hububat","en":"Cereals"},"deger":8250390292.121,"rol":"vurgu"},{"etiket":{"tr":"Yağlı tohum","en":"Oilseeds"},"deger":3990709823.048,"rol":"sessiz"},{"etiket":{"tr":"Sebze ve bakliyat","en":"Vegetables and pulses"},"deger":2570010677.333,"rol":"sessiz"},{"etiket":{"tr":"Süt ürünleri","en":"Dairy"},"deger":2283357716.443,"rol":"sessiz"},{"etiket":{"tr":"İçecek — şarap dahil","en":"Beverages, incl. wine"},"deger":2164696287.101,"rol":"sessiz"},{"etiket":{"tr":"Meyve ve yemiş","en":"Fruit and nuts"},"deger":1937422871.915,"rol":"sessiz"},{"etiket":{"tr":"Yağlar","en":"Fats and oils"},"deger":1003306643.567,"rol":"sessiz"}]},"urun_alanlari":{"tur":"siralama","baslik":{"tr":"Hangi ürün ne kadar yer kaplıyor","en":"How much ground each crop takes"},"birim":{"tr":"milyon hektar, 2023","en":"million hectares, 2023"},"bolen":1000000,"ondalik":2,"not":{"tr":"Buğday tek başına kalan on bir ürünün toplamından geniş. Pamukta ABS yalnız alanı veriyor; üretim ve değer alanları boş.","en":"Wheat alone covers more ground than the other eleven crops combined. For cotton the ABS publishes only the area; production and value fields are empty."},"kaynak":"ABS, Australian Agriculture: Broadacre Crops, 2023","satirlar":[{"etiket":{"tr":"Buğday","en":"Wheat"},"deger":10506997,"rol":"vurgu"},{"etiket":{"tr":"Arpa","en":"Barley"},"deger":4001070,"rol":"sessiz"},{"etiket":{"tr":"Kanola","en":"Canola"},"deger":3714751,"rol":"sessiz"},{"etiket":{"tr":"Mercimek","en":"Lentils"},"deger":804131,"rol":"sessiz"},{"etiket":{"tr":"Sorgum","en":"Sorghum"},"deger":774646,"rol":"sessiz"},{"etiket":{"tr":"Pamuk","en":"Cotton"},"deger":644536,"rol":"sessiz"},{"etiket":{"tr":"Acı bakla","en":"Lupins"},"deger":604423,"rol":"sessiz"},{"etiket":{"tr":"Yulaf","en":"Oats"},"deger":541563,"rol":"sessiz"},{"etiket":{"tr":"Şeker kamışı","en":"Sugarcane"},"deger":340590,"rol":"sessiz"},{"etiket":{"tr":"Nohut","en":"Chickpeas"},"deger":288825,"rol":"sessiz"}]},"isletme_olcegi":{"tur":"siralama","baslik":{"tr":"Bir işletme kaç hektar işliyor","en":"How many hectares one holding works"},"birim":{"tr":"hektar, işletme başına, 2023","en":"hectares per holding, 2023"},"ondalik":0,"not":{"tr":"Buğdayda ülke genelinde on dokuz bin sekiz yüz işletme var ve her biri ortalama beş yüz otuz bir hektar ekiyor. Şeker kamışında alan küçük ama işletme başına değer en yüksek.","en":"Nationally there are nineteen thousand eight hundred wheat holdings, each sowing an average of five hundred and thirty-one hectares. Sugarcane covers less ground but earns the most per holding."},"kaynak":"ABS, Australian Agriculture: Broadacre Crops, 2023","satirlar":[{"etiket":{"tr":"Sorgum","en":"Sorghum"},"deger":395,"rol":"sessiz"},{"etiket":{"tr":"Mercimek","en":"Lentils"},"deger":338,"rol":"sessiz"},{"etiket":{"tr":"Kanola","en":"Canola"},"deger":335,"rol":"sessiz"},{"etiket":{"tr":"Arpa","en":"Barley"},"deger":322,"rol":"sessiz"},{"etiket":{"tr":"Buğday","en":"Wheat"},"deger":531,"rol":"vurgu"},{"etiket":{"tr":"Acı bakla","en":"Lupins"},"deger":257,"rol":"sessiz"},{"etiket":{"tr":"Yulaf","en":"Oats"},"deger":260,"rol":"sessiz"},{"etiket":{"tr":"Şeker kamışı","en":"Sugarcane"},"deger":94,"rol":"sessiz"}]},"koyun_ve_kuzu":{"tur":"cizgi","baslik":{"tr":"Koyun azaldı, kuzu arttı","en":"Fewer sheep, more lambs"},"birim":{"tr":"bin baş, yıllık kesim","en":"thousand head slaughtered a year"},"ondalik":0,"not":{"tr":"Elli iki yıllık seri. Koyun kesimi 1991'de zirve yaptı ve bugün onun yarısına yakın; kuzu kesimi 2024'te zirve yaptı. Aynı hayvan, değişen amaç. Çeyreklik veriden toplandı; dört çeyreği tam olmayan yıl dışarıda bırakıldı.","en":"A fifty-two year series. Sheep slaughter peaked in 1991 and stands near half that today; lamb slaughter peaked in 2024. The same animal, a changed purpose. Aggregated from quarterly data; years without four complete quarters were excluded."},"kaynak":"ABS, Livestock slaughtered","seriler":[{"ad":{"tr":"Kuzu","en":"Lambs"},"rol":"vurgu","noktalar":{"harita":{"1973":15553,"1974":14895,"1975":15564,"1976":16221,"1977":15298,"1978":15485,"1979":15950,"1980":15736,"1981":16179,"1982":17128,"1983":16804,"1984":16542,"1985":18759,"1986":18356,"1987":17516,"1988":16675,"1989":16864,"1990":16549,"1991":15818,"1992":15595,"1993":14668,"1994":15718,"1995":14680,"1996":14069,"1997":14924,"1998":15724,"1999":16346,"2000":18507,"2001":17896,"2002":17086,"2003":16430,"2004":16675,"2005":18228,"2006":19483,"2007":20971,"2008":19970,"2009":20493,"2010":18609,"2011":17793,"2012":20009,"2013":21886,"2014":22251,"2015":22876,"2016":22956,"2017":22431,"2018":22725,"2019":21624,"2020":20421,"2021":20790,"2022":21495,"2023":24863,"2024":26389,"2025":24564}}},{"ad":{"tr":"Koyun","en":"Sheep"},"rol":"ikincil","noktalar":{"harita":{"1973":16790,"1974":10896,"1975":14935,"1976":17467,"1977":15238,"1978":12079,"1979":13550,"1980":14590,"1981":12726,"1982":14016,"1983":9719,"1984":9306,"1985":11742,"1986":14223,"1987":15314,"1988":13130,"1989":13698,"1990":17254,"1991":18750,"1992":18186,"1993":18047,"1994":17991,"1995":15228,"1996":14447,"1997":15552,"1998":15589,"1999":15457,"2000":16379,"2001":15789,"2002":14873,"2003":10522,"2004":11145,"2005":11636,"2006":13113,"2007":11661,"2008":11236,"2009":9411,"2010":6158,"2011":4933,"2012":6064,"2013":9615,"2014":10086,"2015":8487,"2016":6965,"2017":7536,"2018":9521,"2019":9344,"2020":6142,"2021":5804,"2022":6640,"2023":9817,"2024":11784,"2025":10193}}},{"ad":{"tr":"Sığır","en":"Cattle"},"rol":"sessiz","noktalar":{"harita":{"1973":7086,"1974":5745,"1975":7715,"1976":8938,"1977":10327,"1978":10159,"1979":8262,"1980":7320,"1981":6652,"1982":7790,"1983":6645,"1984":5608,"1985":5958,"1986":6611,"1987":6860,"1988":6696,"1989":6511,"1990":7205,"1991":7385,"1992":7713,"1993":7353,"1994":7299,"1995":6914,"1996":6897,"1997":7868,"1998":8105,"1999":7653,"2000":7702,"2001":7808,"2002":7969,"2003":7806,"2004":7894,"2005":7643,"2006":7986,"2007":8000,"2008":7854,"2009":7583,"2010":7472,"2011":7261,"2012":7352,"2013":8344,"2014":9226,"2015":9007,"2016":7288,"2017":7158,"2018":7873,"2019":8482,"2020":7145,"2021":6018,"2022":5850,"2023":7020,"2024":8296,"2025":9284}}}]},"yun_ve_et":{"tur":"cizgi","baslik":{"tr":"Yünün yerini et aldı","en":"Meat took wool's place"},"birim":{"tr":"milyar dolar, ihracat","en":"billion dollars of exports"},"ondalik":2,"onek":{"tr":"$","en":"$"},"not":{"tr":"Yirmi yılda et ihracatı neredeyse üçe katlandı, yün yerinde saydı. 2005'te yün etin yüzde otuz dördü kadardı; 2024'te yüzde on üçü. Kesim defteriyle ticaret defteri aynı şeyi söylüyor.","en":"Over twenty years meat exports nearly tripled while wool stood still. In 2005 wool was thirty-four per cent of meat; in 2024, thirteen. The slaughter ledger and the trade ledger say the same thing."},"kaynak":"UN Comtrade, 2005–2024","seriler":[{"ad":{"tr":"Et (HS 02)","en":"Meat (HS 02)"},"rol":"vurgu","noktalar":{"harita":{"2005":5.143,"2010":6.101,"2015":9.815,"2020":10.051,"2024":13.992}}},{"ad":{"tr":"Hububat (HS 10)","en":"Cereals (HS 10)"},"rol":"sessiz","noktalar":{"harita":{"2005":2.915,"2010":4.705,"2015":6.428,"2020":3.752,"2024":8.25}}},{"ad":{"tr":"Yün (HS 51)","en":"Wool (HS 51)"},"rol":"ikincil","noktalar":{"harita":{"2005":1.781,"2010":2.056,"2015":2.2,"2020":1.537,"2024":1.792}}}]},"destek":{"tur":"siralama","baslik":{"tr":"Çiftçi hasılatının ne kadarı destekten geliyor","en":"How much of farm receipts comes from support"},"birim":{"tr":"brüt çiftlik hasılatının yüzdesi, 2023","en":"per cent of gross farm receipts, 2023"},"ondalik":2,"sonek":{"tr":"%","en":"%"},"not":{"tr":"Avustralya dünyanın en düşüğü değil: Yeni Zelanda daha aşağıda, ve bazı OECD dışı ekonomilerde ölçü negatif çıkıyor — orada üretici desteklenmiyor, örtülü olarak vergileniyor.","en":"Australia is not the world's lowest: New Zealand sits below it, and in some non-OECD economies the measure is negative — there the producer is not supported but implicitly taxed."},"kaynak":"OECD, Üretici Destek Tahmini (PSE)","satirlar":[{"etiket":{"tr":"İsviçre","en":"Switzerland"},"deger":49.36,"rol":"sessiz"},{"etiket":{"tr":"Norveç","en":"Norway"},"deger":48.19,"rol":"sessiz"},{"etiket":{"tr":"Kore","en":"Korea"},"deger":40.07,"rol":"sessiz"},{"etiket":{"tr":"Japonya","en":"Japan"},"deger":30.35,"rol":"sessiz"},{"etiket":{"tr":"OECD ortalaması","en":"OECD average"},"deger":13.53,"rol":"ikincil"},{"etiket":{"tr":"Türkiye","en":"Türkiye"},"deger":9.32,"rol":"ikincil"},{"etiket":{"tr":"ABD","en":"United States"},"deger":6.79,"rol":"sessiz"},{"etiket":{"tr":"Avustralya","en":"Australia"},"deger":2.71,"rol":"vurgu"},{"etiket":{"tr":"Yeni Zelanda","en":"New Zealand"},"deger":1.53,"rol":"sessiz"}]},"turkiye_yemis":{"tur":"ikili_cubuk","baslik":{"tr":"İki ülke birbirine aynı rafı satıyor","en":"The two countries sell each other the same shelf"},"not":{"tr":"2024, HS 08 — yenilebilir meyve ve sert kabuklu yemiş. Avustralya'nın bize sattığı tarım ürününün neredeyse tamamı tek alt fasılda toplanıyor; biz dört ayrı alt fasılda satıyoruz. Tonaj verilmiyor: bu muhabir için Comtrade ağırlık alanlarını boş döndürüyor.","en":"2024, HS 08 — edible fruit and nuts. Almost all of Australia's agricultural sales to Türkiye sit in a single subheading; Türkiye sells across four. No tonnage is given: for this reporter Comtrade returns empty weight fields."},"kaynak":"UN Comtrade, 2024","seriler":[{"ad":{"tr":"Avustralya → Türkiye","en":"Australia → Türkiye"},"rol":"ikincil"},{"ad":{"tr":"Türkiye → Avustralya","en":"Türkiye → Australia"},"rol":"vurgu"}],"satirlar":[{"etiket":{"tr":"Sert kabuklu yemiş (0802)","en":"Nuts (0802)"},"birim":{"tr":"milyon dolar","en":"million dollars"},"bolen":1000000,"ondalik":1,"onek":{"tr":"$","en":"$"},"degerler":[53984288.753,27266707],"rozet":{"tr":"aynı alt fasıl","en":"the same subheading"}},{"etiket":{"tr":"Kuru meyve (0813)","en":"Dried fruit (0813)"},"birim":{"tr":"milyon dolar","en":"million dollars"},"bolen":1000000,"ondalik":1,"onek":{"tr":"$","en":"$"},"degerler":[0,21801609]},{"etiket":{"tr":"Üzüm, taze ya da kuru (0806)","en":"Grapes, fresh or dried (0806)"},"birim":{"tr":"milyon dolar","en":"million dollars"},"bolen":1000000,"ondalik":1,"onek":{"tr":"$","en":"$"},"degerler":[23426.807,21465272]},{"etiket":{"tr":"İncir, hurma ve benzeri (0804)","en":"Figs, dates and the like (0804)"},"birim":{"tr":"milyon dolar","en":"million dollars"},"bolen":1000000,"ondalik":1,"onek":{"tr":"$","en":"$"},"degerler":[0,14142321]},{"etiket":{"tr":"Tarım toplamı (HS 01-24)","en":"Agriculture total (HS 01-24)"},"birim":{"tr":"milyon dolar","en":"million dollars"},"bolen":1000000,"ondalik":1,"onek":{"tr":"$","en":"$"},"degerler":[59222883.717000015,181882222],"rozet":{"tr":"denge Türkiye lehine","en":"the balance favours Türkiye"}}]},"su_kimde":{"tur":"yigin","baslik":{"tr":"Kuzey Victoria'da yüksek güvenilirlikli su hakkı kimin elinde","en":"Who holds the high-reliability water entitlement in northern Victoria"},"not":{"tr":"Dört ayrı 30 Haziran. 2000-01'de suyun tamamı toprağa bağlıydı; 2023-24'te yarısı. Çevre, hiç yokken en büyük tarım dışı hak sahibi oldu. Kuzey Victoria — Avustralya geneli değil.","en":"Four separate 30 Junes. In 2000-01 all the water was linked to land; by 2023-24, half of it. The environment went from holding none to being the largest non-farm holder. Northern Victoria — not Australia as a whole."},"kaynak":"Victorian Water Register — Water Market Trends 2001–2024, Tablo 2","cubuklar":[{"etiket":{"tr":"2000-01","en":"2000-01"},"dilimler":[{"ad":{"tr":"Özel — toprağa bağlı","en":"Private — linked to land"},"deger":2283,"rol":"vurgu"},{"ad":{"tr":"Özel — toprağa bağlı değil","en":"Private — not linked to land"},"deger":0,"rol":"ikincil"},{"ad":{"tr":"Çevre","en":"Environment"},"deger":0,"rol":"sessiz"},{"ad":{"tr":"Su kurumu","en":"Water corporation"},"deger":0,"rol":"sessiz"}]},{"etiket":{"tr":"2008-09","en":"2008-09"},"dilimler":[{"ad":{"tr":"Özel — toprağa bağlı","en":"Private — linked to land"},"deger":2163,"rol":"vurgu"},{"ad":{"tr":"Özel — toprağa bağlı değil","en":"Private — not linked to land"},"deger":125,"rol":"ikincil"},{"ad":{"tr":"Çevre","en":"Environment"},"deger":0,"rol":"sessiz"},{"ad":{"tr":"Su kurumu","en":"Water corporation"},"deger":0,"rol":"sessiz"}]},{"etiket":{"tr":"2015-16","en":"2015-16"},"dilimler":[{"ad":{"tr":"Özel — toprağa bağlı","en":"Private — linked to land"},"deger":1473,"rol":"vurgu"},{"ad":{"tr":"Özel — toprağa bağlı değil","en":"Private — not linked to land"},"deger":197,"rol":"ikincil"},{"ad":{"tr":"Çevre","en":"Environment"},"deger":648,"rol":"sessiz"},{"ad":{"tr":"Su kurumu","en":"Water corporation"},"deger":62,"rol":"sessiz"}]},{"etiket":{"tr":"2023-24","en":"2023-24"},"dilimler":[{"ad":{"tr":"Özel — toprağa bağlı","en":"Private — linked to land"},"deger":1262,"rol":"vurgu"},{"ad":{"tr":"Özel — toprağa bağlı değil","en":"Private — not linked to land"},"deger":456,"rol":"ikincil"},{"ad":{"tr":"Çevre","en":"Environment"},"deger":747,"rol":"sessiz"},{"ad":{"tr":"Su kurumu","en":"Water corporation"},"deger":50,"rol":"sessiz"}]}]},"iki_acilis":{"tur":"ikili_cubuk","baslik":{"tr":"Aynı gün, aynı kura, iki güzergâh","en":"The same day, the same draw, two routes"},"not":{"tr":"İki açılış da 2 Temmuz 2026'da açıldı, ikisinin sırası da kurayla belirlendi. Aradaki tek fark fiziksel: Barmah'ta nehir daralıyor. Her iki açılışın rakamları da eyalet ayrımı olmadan, toplam olarak alınmıştır.","en":"Both openings opened on 2 July 2026 and the order in both was decided by lot. The only difference between them is physical: at Barmah the river narrows. Figures for both openings are taken as totals, without splitting by state."},"kaynak":"Goulburn-to-Murray and Barmah Narrows Post Trade Opening Report, Temmuz 2026","seriler":[{"ad":{"tr":"Goulburn → Murray (darlık yok)","en":"Goulburn → Murray (no narrowing)"},"rol":"ikincil"},{"ad":{"tr":"Barmah darlığı","en":"The Barmah narrows"},"rol":"vurgu"}],"satirlar":[{"etiket":{"tr":"İlan edilen kapasite","en":"Capacity announced"},"birim":{"tr":"bin megalitre","en":"thousand megalitres"},"ondalik":1,"degerler":[112827.9,24121.3],"bolen":1000},{"etiket":{"tr":"Kuraya giren başvuru","en":"Applications entering the draw"},"birim":{"tr":"başvuru","en":"applications"},"ondalik":0,"degerler":[286,214]},{"etiket":{"tr":"Onaylanan","en":"Approved"},"birim":{"tr":"başvuru","en":"applications"},"ondalik":0,"degerler":[282,62]},{"etiket":{"tr":"Onay oranı","en":"Approval rate"},"birim":{"tr":"yüzde","en":"per cent"},"ondalik":1,"degerler":[98.6,29],"sonek":{"tr":"%","en":"%"},"rozet":{"tr":"aynı mekanizma","en":"same mechanism"}},{"etiket":{"tr":"Talebin kapasiteye oranı","en":"Demand as a multiple of capacity"},"birim":{"tr":"kat","en":"times"},"ondalik":2,"degerler":[1.07,2.8],"sonek":{"tr":"×","en":"×"}}]},"kalici_hakkin_fiyati":{"tur":"cizgi","baslik":{"tr":"Kalıcı su hakkının megalitre fiyatı","en":"The price of a permanent water entitlement, per megalitre"},"birim":{"tr":"medyan devir fiyatı, AUD/ML","en":"median transfer price, AUD/ML"},"ondalik":0,"onek":{"tr":"$","en":"$"},"not":{"tr":"Medyan fiyat. Yüksek güvenilirlikli pay suyu önce alır; düşük güvenilirlikli pay ancak bol yıllarda su görür ve fiyatı bunu yansıtıyor. Medyan bölgeler arası ayrışmayı gizler — Barmah'ın aşağısındaki fark ayrı bir bölümde. Kuzey Victoria.","en":"Median price. A high-reliability share is served first; a low-reliability share receives water only in abundant years, and its price reflects that. A median conceals divergence between zones — the gap below Barmah has a section of its own. Northern Victoria."},"kaynak":"Victorian Water Register — Water Market Trends 2001–2024, Tablo 4 ve 5","seriler":[{"ad":{"tr":"Yüksek güvenilirlikli pay","en":"High-reliability share"},"rol":"vurgu","noktalar":{"liste":[{"yil":"2008-09","devlete_devir_gl":8,"diger_devir_gl":154,"medyan_fiyat_aud_ml":2175,"yil_no":2008},{"yil":"2009-10","devlete_devir_gl":127,"diger_devir_gl":210,"medyan_fiyat_aud_ml":2200,"yil_no":2009},{"yil":"2010-11","devlete_devir_gl":113,"diger_devir_gl":98,"medyan_fiyat_aud_ml":1940,"yil_no":2010},{"yil":"2011-12","devlete_devir_gl":174,"diger_devir_gl":93,"medyan_fiyat_aud_ml":1800,"yil_no":2011},{"yil":"2012-13","devlete_devir_gl":31,"diger_devir_gl":104,"medyan_fiyat_aud_ml":1500,"yil_no":2012},{"yil":"2013-14","devlete_devir_gl":10,"diger_devir_gl":93,"medyan_fiyat_aud_ml":1380,"yil_no":2013},{"yil":"2014-15","devlete_devir_gl":25,"diger_devir_gl":99,"medyan_fiyat_aud_ml":1500,"yil_no":2014},{"yil":"2015-16","devlete_devir_gl":1,"diger_devir_gl":124,"medyan_fiyat_aud_ml":2400,"yil_no":2015},{"yil":"2016-17","devlete_devir_gl":5,"diger_devir_gl":151,"medyan_fiyat_aud_ml":2600,"yil_no":2016},{"yil":"2017-18","devlete_devir_gl":3,"diger_devir_gl":66,"medyan_fiyat_aud_ml":2850,"yil_no":2017},{"yil":"2018-19","devlete_devir_gl":null,"diger_devir_gl":112,"medyan_fiyat_aud_ml":3700,"yil_no":2018},{"yil":"2019-20","devlete_devir_gl":0,"diger_devir_gl":156,"medyan_fiyat_aud_ml":4800,"yil_no":2019},{"yil":"2020-21","devlete_devir_gl":1,"diger_devir_gl":88,"medyan_fiyat_aud_ml":4500,"yil_no":2020},{"yil":"2021-22","devlete_devir_gl":null,"diger_devir_gl":112,"medyan_fiyat_aud_ml":4950,"yil_no":2021},{"yil":"2022-23","devlete_devir_gl":null,"diger_devir_gl":82,"medyan_fiyat_aud_ml":5000,"yil_no":2022},{"yil":"2023-24","devlete_devir_gl":null,"diger_devir_gl":60,"medyan_fiyat_aud_ml":4500,"yil_no":2023}],"x":"yil_no","y":"medyan_fiyat_aud_ml"}},{"ad":{"tr":"Düşük güvenilirlikli pay","en":"Low-reliability share"},"rol":"ikincil","noktalar":{"liste":[{"yil":"2008-09","devlete_devir_gl":1,"diger_devir_gl":74,"medyan_fiyat_aud_ml":200,"yil_no":2008},{"yil":"2009-10","devlete_devir_gl":20,"diger_devir_gl":35,"medyan_fiyat_aud_ml":175,"yil_no":2009},{"yil":"2010-11","devlete_devir_gl":1,"diger_devir_gl":53,"medyan_fiyat_aud_ml":150,"yil_no":2010},{"yil":"2011-12","devlete_devir_gl":0,"diger_devir_gl":64,"medyan_fiyat_aud_ml":140,"yil_no":2011},{"yil":"2012-13","devlete_devir_gl":null,"diger_devir_gl":47,"medyan_fiyat_aud_ml":150,"yil_no":2012},{"yil":"2013-14","devlete_devir_gl":0,"diger_devir_gl":32,"medyan_fiyat_aud_ml":185,"yil_no":2013},{"yil":"2014-15","devlete_devir_gl":null,"diger_devir_gl":40,"medyan_fiyat_aud_ml":225,"yil_no":2014},{"yil":"2015-16","devlete_devir_gl":null,"diger_devir_gl":35,"medyan_fiyat_aud_ml":244,"yil_no":2015},{"yil":"2016-17","devlete_devir_gl":null,"diger_devir_gl":61,"medyan_fiyat_aud_ml":250,"yil_no":2016},{"yil":"2017-18","devlete_devir_gl":null,"diger_devir_gl":26,"medyan_fiyat_aud_ml":340,"yil_no":2017},{"yil":"2018-19","devlete_devir_gl":null,"diger_devir_gl":55,"medyan_fiyat_aud_ml":500,"yil_no":2018},{"yil":"2019-20","devlete_devir_gl":null,"diger_devir_gl":36,"medyan_fiyat_aud_ml":500,"yil_no":2019},{"yil":"2020-21","devlete_devir_gl":null,"diger_devir_gl":37,"medyan_fiyat_aud_ml":470,"yil_no":2020},{"yil":"2021-22","devlete_devir_gl":null,"diger_devir_gl":44,"medyan_fiyat_aud_ml":650,"yil_no":2021},{"yil":"2022-23","devlete_devir_gl":null,"diger_devir_gl":44,"medyan_fiyat_aud_ml":895,"yil_no":2022},{"yil":"2023-24","devlete_devir_gl":null,"diger_devir_gl":30,"medyan_fiyat_aud_ml":850,"yil_no":2023}],"x":"yil_no","y":"medyan_fiyat_aud_ml"}}]}}$dsr$::jsonb,
  array['Avustralya', 'buğday', 'yün', 'merinos', 'et ihracatı', 'bakliyat', 'tarım politikası', 'tarım destekleri', 'su hakkı', 'su piyasası', 'Murray-Darling', 'kuraklık', 'kuru meyve', 'yemiş', 'tarım ticareti']::text[],
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
  (1::integer, $dsr$Rakip mi, müşteri mi$dsr$, $dsr$Rival or customer$dsr$, $dsr$Avustralya, Türkiye'nin tarım haritasında uzak bir yerde durur. Aynı
yarıkürede değiliz, aynı mevsimde hasat etmiyoruz, aynı pazarlarda da pek
karşılaşmıyoruz. Buğdayda onun müşterisi Asya, bizimki kendi değirmenimiz. Et
ihracatında onun rakamları bizim bütün tarım ihracatımıza yakın.

Ama iki ülkenin ticaret defteri açıldığında beklenmedik bir şey çıkıyor.

2024'te Avustralya Türkiye'ye elli dokuz milyon iki yüz bin dolarlık tarım
ürünü sattı. Aynı yıl Türkiye Avustralya'ya **yüz seksen bir milyon dokuz yüz
bin dolarlık** sattı. Denge üç kat Türkiye lehine.

Daha da tuhafı, iki yönde de en büyük kalem aynı fasıl: yenilebilir meyve ve
sert kabuklu yemiş. Avustralya'nın bize sattığı tarım ürününün neredeyse
tamamı — elli dört milyon doları — tek bir alt fasılda, sert kabuklu yemişte
toplanıyor. Biz de onlara yemiş satıyoruz, üstüne kuru meyve, üzüm, incir ve
hurma.

Yani iki ülke birbirine aynı rafı satıyor. Bu dosyanın sonunda o rafa
döneceğiz.

Önce daha büyük bir soru var. Avustralya'nın tarımı hangi ölçekte çalışıyor,
neyi yetiştiriyor, ve neden çiftçisi devletten destek almıyor? Çünkü almıyor —
ve bu, dosyanın en keskin rakamı.$dsr$, $dsr$Australia sits a long way off on Türkiye's agricultural map. We are not in the
same hemisphere, we do not harvest in the same season, and we rarely meet in
the same markets. In wheat, its customer is Asia; ours is our own mill. Its
meat exports alone approach the value of Türkiye's entire agricultural export.

But open the trade ledger between the two countries and something unexpected
appears.

In 2024 Australia sold Türkiye 59.2 million dollars of agricultural produce.
In the same year Türkiye sold Australia **181.9 million dollars.** The balance
runs three times in Türkiye's favour.

Stranger still, the largest item in both directions is the same chapter:
edible fruit and nuts. Almost all of what Australia sells us — 54.0 million
dollars of it — sits in a single sub-chapter, nuts. We sell them nuts too, and
on top of that dried fruit, grapes, figs and dates.

The two countries are selling each other the same shelf. We will come back to
that shelf at the end of this file.

First there is a larger question. At what scale does Australian agriculture
operate, what does it grow, and why does its farmer receive no state support?
Because he does not — and that is the sharpest number in this dossier.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/avustralya/avustralya_bugday_tarlasi.jpg","atif":"malleefarmscapes — CC BY 2.0","kaynak":null,"alt_tr":"Victoria'da buğday tarlaları.","alt_en":"Wheat fields in Victoria."}$dsr$::jsonb),
  (2, $dsr$Yüzde kırk yedi toprak, yüzde iki ekonomi$dsr$, $dsr$Forty-seven per cent land, two per cent economy$dsr$, $dsr$Dünya Bankası'nın serisinde Avustralya'nın üç rakamı yan yana durduğunda tuhaf
görünüyor.

Ülke yüzölçümünün **yüzde kırk yedi virgül yirmi ikisi** tarım arazisi (2023).
Yani kıtanın yarısına yakını, bir biçimde, tarıma ayrılmış.

Aynı ülkede tarımın gayrisafi yurt içi hasıladaki payı **yüzde iki virgül
sıfır dört** (2024). İstihdamdaki payı **yüzde iki virgül yirmi üç**.

Ve işlenebilir arazi otuz milyon dokuz yüz seksen dokuz bin hektar (2023) —
Türkiye'nin bütün tarım arazisinden geniş bir alan, yüz kişiden ikisinin
çalıştığı bir sektörde.

Dördüncü rakam bu üçlüyü tamamlıyor: 2024'te Avustralya dünyaya **kırk bir
milyar sekiz yüz altmış dokuz milyon dolarlık** tarım ürünü sattı (gümrük
fasılları 01-24). Yün ve pamuk bu aralığın dışında kalıyor ve ayrıca sayılıyor
— ikisi birlikte dört milyar doların üzerinde.

Bu dört rakamın birlikte anlattığı şey şu: Avustralya tarımı **geniş ama
ince**. Çok yer kaplıyor, az insan çalıştırıyor, ekonominin küçük bir dilimi,
ve ürettiğinin büyük kısmını dışarı satıyor.

Bir ülke bunu nasıl yapar? Cevabın ilk yarısı bir sonraki bölümde: işletme
ölçeği.$dsr$, $dsr$Three of Australia's figures look odd when the World Bank series puts them
side by side.

**47.22 per cent** of the country's land area is agricultural land (2023).
Close to half the continent is, in some form, given over to farming.

In the same country, agriculture's share of gross domestic product is **2.04
per cent** (2024). Its share of employment is **2.23 per cent.**

And the arable area is 30,989,678 hectares (2023) — a span larger than all of
Türkiye's agricultural land, worked by a sector that employs two people in
every hundred.

A fourth figure completes the set: in 2024 Australia sold the world **41.87
billion dollars** of agricultural produce (customs chapters 01–24). Wool and
cotton fall outside that range and are counted separately — together they
exceed four billion dollars.

What these four numbers say together is that Australian agriculture is **wide
but thin.** It occupies a great deal of ground, employs few people, makes up a
small slice of the economy, and sells most of what it produces abroad.

How does a country do that? The first half of the answer is in the next
section: holding size.$dsr$, array['dort_rakam']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/avustralya/avustralya_bugday_kirsali.jpg","atif":"David Edwards — CC BY 3.0","kaynak":null,"alt_tr":"Orta Victoria'da tahıl arazisi.","alt_en":"Grain country in central Victoria."}$dsr$::jsonb),
  (3, $dsr$Beş yüz hektarlık çiftçi$dsr$, $dsr$The five-hundred-hectare farmer$dsr$, $dsr$Rusya dosyasında gündelik tarımın cevabı yirmi milyon dacha'ydı; Hollanda'da
şehir bahçeleriydi. Avustralya'da aynı soru sorulduğunda cevap tersine
dönüyor.

Avustralya İstatistik Kurumu 2023 için buğdayı iki ayrı rakamla veriyor:
ekilen alan **on milyon beş yüz altı bin dokuz yüz doksan yedi hektar**, ve bu
alanı eken işletme sayısı **on dokuz bin sekiz yüz**.

Bölündüğünde: işletme başına **beş yüz otuz bir hektar.**

Türkiye'den bakınca bu rakam bir çiftlik değil, bir ilçe gibi duruyor. Ve
buğday istisna da değil. Sorgumda işletme başına üç yüz doksan beş hektar,
mercimekte üç yüz otuz sekiz, kanolada üç yüz otuz beş, arpada üç yüz yirmi
iki. Yulafta ve acı baklada iki yüz altmış civarı.

Tek istisna şeker kamışı: işletme başına doksan dört hektar. Ama orada da
başka bir rakam büyük — işletme başına altı yüz beş bin Avustralya dolarlık
üretim değeri, bütün ürünlerin en yükseği. Dar alan, yoğun ürün.

Buğdayda işletme başına üretim değeri dört yüz kırk beş bin dokuz yüz seksen
üç Avustralya doları. Mercimekte beş yüz bir bin sekiz yüz yedi.

Bu ölçek bir tercih değil, bir zorunluluk. Yağış düşük, verim düşük: buğdayda
hektar başına iki virgül altmış yedi ton, arpada iki virgül yetmiş dört,
kanolada iki virgül sıfır iki. Avrupa'nın yarısı kadar. Düşük verimle para
kazanmanın tek yolu çok geniş alan ekmek ve makineyle çalışmak — yani az
insanla.

Yüzde iki virgül yirmi üçlük istihdam payının açıklaması burada.$dsr$, $dsr$In the Russia dossier, the answer to everyday farming was twenty million
dachas; in the Netherlands, city allotments. Ask the same question of
Australia and the answer inverts.

The Australian Bureau of Statistics gives wheat for 2023 as two separate
figures: an area sown of **10,506,997 hectares**, and a number of holdings
sowing that area of **19,800.**

Divided: **531 hectares per holding.**

Seen from Türkiye, that is not a farm, it is a district. And wheat is not the
exception. Sorghum runs at 395 hectares per holding, lentils 338, canola 335,
barley 322. Oats and lupins sit around 260.

The one exception is sugar cane: 94 hectares per holding. But another figure
there is large — 605,148 Australian dollars of production value per holding,
the highest of any crop. Narrow ground, intense crop.

Wheat's production value per holding is 445,983 Australian dollars. Lentils,
501,807.

This scale is not a preference but a necessity. Rainfall is low and so is
yield: 2.67 tonnes per hectare for wheat, 2.74 for barley, 2.02 for canola.
Half of Europe's. The only way to make money at low yields is to sow a very
large area and work it with machinery — that is, with few people.

That is where the 2.23 per cent employment share comes from.$dsr$, array['isletme_olcegi']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/avustralya/avustralya_sulama_ciftligi.jpg","atif":"Liese Coulter, CSIRO — CC BY 3.0","kaynak":null,"alt_tr":"Kuru bir tarlada duran pivot sulama makinesi. Donanım yerinde; su ayrı bir mesele.","alt_en":"A centre-pivot irrigator standing on a dry paddock. The equipment is in place; the water is a separate question."}$dsr$::jsonb),
  (4, $dsr$Buğday, arpa, kanola$dsr$, $dsr$Wheat, barley, canola$dsr$, $dsr$Avustralya'nın tarla bitkileri haritası birkaç ürüne sıkışmış durumda ve
sıralama net.

Buğday, on milyon beş yüz altı bin dokuz yüz doksan yedi hektarla listedeki on
iki ürünün ektiği alanın **yüzde kırk yedisini** tek başına kaplıyor ve
arpanın iki virgül altmış üç katı. Kalan on bir ürünün toplamı buğdaydan biraz
geniş: on bir milyon sekiz yüz kırk bir bin altı yüz otuz altı hektar. 2023'te
yirmi sekiz milyon yirmi sekiz bin ton üretildi; ABS'in verdiği üretim değeri
sekiz milyar sekiz yüz otuz milyon Avustralya doları.

Arpa dört milyon hektar, on bir milyona yakın ton. Kanola üç milyon yedi yüz
bin hektar, yedi buçuk milyon ton — ve değer olarak arpayı geçiyor: dört
milyar dört yüz seksen üç milyon Avustralya doları. Yağlı tohumun ton başına
fiyatı hububattan yüksek.

Sonra ölçek hızla düşüyor. Mercimek sekiz yüz dört bin hektar, sorgum yedi yüz
yetmiş beş bin, pamuk altı yüz kırk dört bin, acı bakla altı yüz dört bin,
yulaf beş yüz kırk bir bin.

Şeker kamışı üç yüz kırk bin hektarla listenin ortasında ama üretim rakamıyla
hepsini aşıyor: **yirmi dokuz milyon sekiz yüz elli beş bin ton.** Şeker
kamışı ağır bir bitkidir; hektardan seksen yedi virgül yedi ton kalkıyor,
buğdayın otuz iki virgül sekiz katı. Tonajla alan karşılaştırmak bu yüzden
yanıltıcı olur.

Listenin sonunda mısır yetmiş beş bin hektar, çeltik elli iki bin hektar.
Çeltiğin yeri bu dosyada ayrıca anlamlı: altı yüz on dokuz bin ton pirinç
üretiliyor ve bunun tamamı sulanan arazide. Suyun pahalandığı yıl ilk
vazgeçilen ürün o oluyor — dosyanın ikinci yarısında sebebini göreceğiz.

Pamukta bir veri boşluğu var ve gizlenmiyor: ABS altı yüz kırk dört bin
hektarlık alanı veriyor ama üretim ve değer alanları boş geliyor. Pamuğun
ihracat değeri ancak gümrük kaydından okunabiliyor — 2024'te iki milyar dört
yüz otuz milyon dolar.$dsr$, $dsr$Australia's field-crop map is compressed into a few commodities, and the
ranking is clear.

Wheat alone, at 10,506,997 hectares, covers **47.0 per cent** of the area sown
to the twelve crops on this list, and is 2.63 times barley. The other eleven
together are slightly wider than wheat: 11,841,636 hectares. In 2023 it
produced 28,028,429 tonnes; ABS gives the production value as 8,830 million
Australian dollars.

Barley covers 4.0 million hectares and close to 11 million tonnes. Canola, 3.7
million hectares and 7.5 million tonnes — and in value it passes barley: 4,483
million Australian dollars. Oilseed fetches more per tonne than cereal.

Then the scale falls away quickly. Lentils 804,131 hectares, sorghum 774,646,
cotton 644,536, lupins 604,423, oats 541,563.

Sugar cane sits mid-list at 340,590 hectares but exceeds everything on
production: **29,855,156 tonnes.** Cane is a heavy crop; it yields 87.7 tonnes
to the hectare, 32.8 times wheat. Comparing tonnage against area is misleading
for exactly this reason.

At the bottom, maize covers 75,132 hectares and rice 51,969. Rice matters
particularly in this file: 619,180 tonnes are produced and all of it on
irrigated ground. In a year when water becomes expensive, it is the first crop
abandoned — the second half of this file shows why.

There is a gap in the cotton data, and it is not concealed: ABS gives the
644,536-hectare area but returns production and value as empty. Cotton's
export value can only be read from the customs record — 2,432 million dollars
in 2024.$dsr$, array['urun_alanlari']::text[], 'veri', null),
  (5, $dsr$Mercimek ve nohut$dsr$, $dsr$Lentils and chickpeas$dsr$, $dsr$Türkiyeli okur için listenin en tanıdık iki satırı mercimek ve nohut, ve ikisi
de beklenenden büyük.

Avustralya 2023'te sekiz yüz dört bin hektar mercimek ekti ve **bir milyon
dört yüz on üç bin ton** kaldırdı. Nohut iki yüz seksen dokuz bin hektar, beş
yüz kırk altı bin ton.

Mercimeği eken işletme sayısı iki bin üç yüz seksen. Yani iki bin beş yüze
yakın çiftlik, bir buçuk milyon tona yakın mercimek üretiyor — işletme başına
beş yüz doksan dört ton civarı. Türkiye'nin mercimek üretimi aynı büyüklük
sınıfında ama çok daha fazla üreticiye dağılmış.

Değer tarafında mercimek, ektiği alana göre iyi para getiriyor: bir milyar yüz
doksan dört milyon Avustralya doları, yani sekiz yüz dört bin hektardan. Aynı
alanda buğday ekilse daha az ederdi. Bakliyat Avustralya için yan ürün değil,
bilinçli bir rotasyon kalemi — baklagil toprağa azot bırakıyor ve ertesi yılın
buğdayı ondan faydalanıyor.

Bu, dosyanın "sebze ve bakliyat" faslının (gümrük kodu 07) neden iki milyar
beş yüz yetmiş milyon dolarlık ihracat yaptığını açıklıyor. Avustralya
bakliyatı büyük ölçüde Güney Asya ve Orta Doğu'ya satıyor.

Türkiye'ye ise satmıyor. 2024'te o fasıldan bize gelen yalnızca iki yüz bin
dolar — yani neredeyse hiç. İki ülke aynı ürünü üretiyor ve birbirine
satmıyor; ticaret başka bir kalemde kurulmuş.$dsr$, $dsr$For a Turkish reader the two most familiar lines on the list are lentils and
chickpeas, and both are larger than expected.

In 2023 Australia sowed 804,131 hectares of lentils and took off **1,412,950
tonnes.** Chickpeas: 288,825 hectares, 545,767 tonnes.

The number of holdings growing lentils is 2,380. So fewer than 2,500 farms
produce close to one and a half million tonnes of lentils — about 594 tonnes
each. Türkiye's lentil production is in the same size class but spread across
far more growers.

On value, lentils pay well for the ground they occupy: 1,194 million
Australian dollars from 804,131 hectares. Wheat on the same ground would be
worth less. Pulses are not a by-product for Australia but a deliberate
rotation item — a legume leaves nitrogen in the soil and next year's wheat
draws on it.

This is why the vegetables-and-pulses chapter (customs code 07) exports 2,570
million dollars. Australia sells its pulses largely to South Asia and the
Middle East.

Not to Türkiye. In 2024 that chapter sent us 0.2 million dollars — effectively
nothing. Two countries grow the same crop and do not sell it to each other;
the trade was built on a different item.$dsr$, '{}'::text[], 'anlati', null),
  (6, $dsr$En büyük kalem et$dsr$, $dsr$Meat is the largest item$dsr$, $dsr$Avustralya tarımının en büyük ihracat kalemi tahıl değil, et.

2024'te et ve yenilebilir sakatat ihracatı **on üç milyar dokuz yüz doksan iki
milyon dolar.** Hububatın (sekiz milyar iki yüz elli milyon) bir buçuk
katından fazla, yağlı tohumun (üç milyar dokuz yüz doksan bir milyon) üç
katından fazla.

Sıralamanın devamı: sebze ve bakliyat iki milyar beş yüz yetmiş milyon, süt
ürünleri iki milyar iki yüz seksen üç milyon, içecekler — şarap bu fasılda —
iki milyar yüz altmış beş milyon, meyve ve yemiş bir milyar dokuz yüz otuz
yedi milyon.

Bu listeye pamuk ve yün girmiyor; onlar dokuma fasıllarında. Pamuk iki milyar
dört yüz otuz iki milyon, yün bir milyar yedi yüz doksan iki milyon dolar.

Şu karşılaştırma dosyanın bir sonraki bölümünü açıyor: **pamuk artık yünden
büyük.** Avustralya denince akla gelen lif yün; ama gümrük kaydında pamuk onu
geçmiş durumda.

Et tarafında hayvan sayıları ABS'in kesim serisinde duruyor ve seri uzun —
1973'ten bugüne, çeyrek çeyrek. 2025'te dokuz milyon iki yüz seksen dört bin
sığır, yirmi dört milyon beş yüz altmış dört bin kuzu, on milyon yüz doksan üç
bin koyun kesildi.

Kuzu rakamı sığırın iki buçuk katı. Bu, Avustralya hayvancılığının son otuz
yılda yaşadığı değişimin işareti — ve o değişim bir sonraki bölümün konusu.$dsr$, $dsr$The largest export item in Australian agriculture is not grain. It is meat.

In 2024, exports of meat and edible offal came to **13,992 million dollars.**
More than one and a half times cereals (8,250 million) and more than three
times oilseeds (3,991 million).

The rest of the ranking: vegetables and pulses 2,570 million, dairy 2,283
million, beverages — wine sits in this chapter — 2,165 million, fruit and nuts
1,937 million.

Cotton and wool are not on that list; they fall under textile chapters. Cotton
is 2,432 million dollars, wool 1,792 million.

One comparison opens the next section: **cotton is now larger than wool.** The
fibre Australia brings to mind is wool, but in the customs record cotton has
passed it.

On the meat side, the animal numbers sit in the ABS slaughter series, and the
series is long — quarterly, from 1973 to today. In 2025, 9,284 thousand
cattle, 24,564 thousand lambs and 10,193 thousand sheep were slaughtered.

The lamb figure is two and a half times the cattle figure. That is the marker
of what has happened to Australian livestock over thirty years — and it is the
subject of the next section.$dsr$, array['tarim_ihracati']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/avustralya/avustralya_sigir_surusu.jpg","atif":"Jim Bendon from Karratha, Australia — CC BY-SA 2.0","kaynak":null,"alt_tr":"Batı Avustralya'da sığır sürüsü toplanıyor.","alt_en":"Cattle being mustered in Western Australia."}$dsr$::jsonb),
  (7, $dsr$Sürü kaldı, yapağı gitti$dsr$, $dsr$The flock stayed, the fleece left$dsr$, $dsr$Avustralya'nın tarım tarihinde yün, uzun süre her şeyin önündeydi. Tom
Roberts'ın 1890 tarihli tablosu bir kırkım barakasını anlatır: kırkıcılar
eğilmiş, yerde yapağı yığılı, kapıda ışık. Resim 1890 tarihli ve adı *Kırkım*;
künyesinde bundan fazlası yok.

Bugün o barakanın hikâyesi tersine dönmüş durumda — ama beklenen biçimde
değil.

ABS'in kesim serisi 1973'ten başlıyor ve elli iki yıl sürüyor. **Koyun kesimi
1991'de zirve yaptı: on sekiz milyon yedi yüz elli bin baş.** 2025'te on
milyon yüz doksan üç bin. Zirvenin **yüzde elli dördü**.

Aynı seride kuzu tam ters yönde ilerliyor. **Kuzu kesimi 2024'te zirve yaptı:
yirmi altı milyon üç yüz seksen dokuz bin baş.** 2025'te yirmi dört milyon beş
yüz altmış dört bin — zirvenin yüzde doksan üçü.

Yani koyun azalırken kuzu artmış. Sürü ortadan kalkmamış; **sürünün amacı
değişmiş.** Yün için büyütülen, uzun ömürlü, defalarca kırkılan koyunun yerini
ete giden genç hayvan almış.

Sığırda tablo daha durağan: zirve 1977'de on milyon üç yüz yirmi yedi bin,
2025'te dokuz milyon iki yüz seksen dört bin — zirvenin yüzde doksanı. Elli
yılda neredeyse yerinde saymış.

En sert düşüş danada. 1976'da iki milyon dört yüz doksan altı bin dana
kesilmiş; 2025'te dört yüz dokuz bin. **Zirvenin yüzde on altısı.** Dana eti
Avustralya'nın kesim defterinde artık küçük bir kalem.

Bu dört eğri birlikte okununca ortaya tek bir cümle çıkıyor: Avustralya
hayvancılığı yünden ete, uzun ömürden kısa ömre, lif üretiminden protein
üretimine geçmiş.$dsr$, $dsr$For a long stretch of Australia's agricultural history, wool came before
everything. Tom Roberts's 1890 painting shows a shearing shed: shearers bent
over, fleece piled on the floor, light in the doorway. The painting is dated
1890 and titled *Shearing the rams*; its credit says no more than that.

Today that shed's story has reversed — but not in the way one expects.

The ABS slaughter series begins in 1973 and runs fifty-two years. **Sheep
slaughter peaked in 1991 at 18,750 thousand head.** In 2025 it was 10,193
thousand. **54.4 per cent** of the peak.

In the same series, lamb moves in the opposite direction. **Lamb slaughter
peaked in 2024 at 26,389 thousand head.** In 2025, 24,564 thousand — 93.1 per
cent of the peak.

So sheep fell while lambs rose. The flock has not disappeared; **the flock's
purpose has changed.** The long-lived animal raised for wool and shorn many
times has given way to the young animal that goes for meat.

Cattle are steadier: a peak of 10,327 thousand in 1977, 9,284 thousand in 2025
— 89.9 per cent of the peak. Almost flat across fifty years.

The sharpest fall is in calves. In 1976, 2,496 thousand calves were
slaughtered; in 2025, 409 thousand. **16.4 per cent of the peak.** Veal is now
a minor line in Australia's slaughter ledger.

Read together, these four curves make one sentence: Australian livestock has
moved from wool to meat, from long life to short, from fibre to protein.$dsr$, array['koyun_ve_kuzu']::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/avustralya/avustralya_koyun_kirkimi.jpg","atif":"Tom Roberts, Shearing the rams, 1890 — Public domain","kaynak":null,"alt_tr":"Tom Roberts, Kırkım (1890). Bir kırkım barakasında kırkıcılar, yerde yapağı; sağda yün balyalanmayı bekliyor.","alt_en":"Tom Roberts, Shearing the rams (1890). Shearers in a shearing shed, fleece on the floor, wool waiting to be baled at the right."}$dsr$::jsonb),
  (8, $dsr$Aynı hikâyenin ikinci defteri$dsr$, $dsr$The second ledger tells the same story$dsr$, $dsr$Kesim defteri bir şey söylüyor. Ticaret defteri aynı şeyi bağımsız olarak
doğruluyor. Tek kaynağa dayanmanın tehlikesine karşı elde olan tek şey de
budur.

Gümrük kaydında yün ihracatı 2005'te bir milyar yedi yüz seksen bir milyon
dolardı. 2024'te **bir milyar yedi yüz doksan iki milyon.** Yirmi yılda
neredeyse hiç değişmemiş — ve arada dalgalanmış: 2015'te iki milyar iki yüz
milyona çıkmış, 2020'de bir milyar beş yüz otuz yedi milyona inmiş.

Aynı yirmi yılda et ihracatı beş milyar yüz kırk üç milyon dolardan **on üç
milyar dokuz yüz doksan iki milyona** çıktı. Neredeyse üç katı.

Oranla bakmak daha açık: 2005'te yün, etin **yüzde otuz dört virgül altısı**
kadardı. 2024'te **yüzde on iki virgül sekizi.**

Hububat da aynı dönemde iki milyar dokuz yüz on beş milyondan sekiz milyar iki
yüz elli milyona çıktı, ama düzgün bir çizgiyle değil — 2020'de üç milyar yedi
yüz elli iki milyona düşmüş. Tahıl ihracatı yağışa bağlı ve dalgalanıyor; et
ise istikrarlı biçimde büyüyor.

İki defterin aynı şeyi söylemesi önemli, çünkü ikisi birbirinden bağımsız
toplanıyor: biri mezbaha kayıtlarından, öteki gümrükten. Kesimde koyun
azalıyor, ticarette yün yerinde sayıyor. Kesimde kuzu artıyor, ticarette et
üçe katlanıyor.

Avustralya'nın terk ettiği şey koyun değil, **yapağı.**$dsr$, $dsr$The slaughter ledger says one thing. The trade ledger confirms it
independently. Against the danger of resting on a single source, that is the
only guard there is.

In the customs record, wool exports were 1,781 million dollars in 2005. In
2024, **1,792 million.** Almost unchanged over twenty years — and it
fluctuated in between: 2,200 million in 2015, 1,537 million in 2020.

Across the same twenty years, meat exports went from 5,143 million dollars to
**13,992 million.** Nearly triple.

The ratio is plainer. In 2005 wool was **34.6 per cent** of meat. In 2024,
**12.8 per cent.**

Cereals also rose over the period, from 2,915 million to 8,250 million, but
not in a straight line — they fell to 3,752 million in 2020. Grain exports
follow the rain and swing; meat grows steadily.

That the two ledgers agree matters, because they are collected independently
of one another: one from abattoir records, the other from customs. In
slaughter, sheep fall and in trade wool stands still. In slaughter, lambs rise
and in trade meat triples.

What Australia abandoned was not sheep. It was **fleece.**$dsr$, array['yun_ve_et']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/avustralya/avustralya_merinos.jpg","atif":"Cgoodwin — CC BY-SA 3.0","kaynak":null,"alt_tr":"Merinos koyunları ve kuzular.","alt_en":"Merino ewes and lambs."}$dsr$::jsonb),
  (9, $dsr$Desteksiz çiftçi$dsr$, $dsr$The unsupported farmer$dsr$, $dsr$Buraya kadar anlatılan her şey — beş yüz hektarlık işletmeler, düşük verim,
makineleşme, yünden ete geçiş — bir soruyu askıda bırakıyor: bütün bunları
yaparken çiftçi devletten ne alıyor?

Cevap: neredeyse hiçbir şey.

OECD, üye ülkelerde çiftçinin brüt hasılatının ne kadarının devlet desteğinden
geldiğini her yıl ölçüyor. 2023 için Avustralya'nın rakamı **yüzde iki virgül
yetmiş bir.**

Aynı yıl OECD ortalaması **yüzde on üç virgül elli üç.** Türkiye **yüzde dokuz
virgül otuz iki.** Amerika Birleşik Devletleri yüzde altı virgül yetmiş dokuz.

Üst uçta tablo bambaşka: Japonya yüzde otuz virgül otuz beş, Kore yüzde kırk
virgül sıfır yedi, Norveç yüzde kırk sekiz virgül on dokuz, İsviçre yüzde kırk
dokuz virgül otuz altı. İsviçreli çiftçinin hasılatının neredeyse yarısı
destekten geliyor; Avustralyalının kırkta biri.

Bir ayrım gerekiyor: Avustralya dünyanın en düşüğü **değil.** Yeni Zelanda
daha aşağıda, yüzde bir virgül elli üçte. Ve ölçü bazı ekonomilerde negatif
çıkıyor — orada üretici destekleniyor değil, fiyat politikalarıyla örtülü
olarak vergileniyor. Avustralya'nın yeri, desteğin pozitif ama çok küçük
olduğu uçta.

Bunun pratik karşılığı şu: Avustralyalı çiftçi kuraklıkta, fiyat düşüşünde ya
da pazar kaybında devletin fiyat garantisine yaslanamıyor. Riski kendi taşıyor
— ve riski taşımanın yolu ya ölçek büyütmek ya da kıt girdiyi satın alabilmek
oluyor.

O kıt girdi su. Ve Avustralya onu da bir piyasaya bağlamış durumda.$dsr$, $dsr$Everything described so far — 500-hectare holdings, low yields, mechanisation,
the shift from wool to meat — leaves one question hanging. While doing all of
this, what does the farmer receive from the state?

Almost nothing.

Each year the OECD measures what share of a farmer's gross receipts comes from
government support. For 2023, Australia's figure is **2.71 per cent.**

The OECD average that year was **13.53 per cent.** Türkiye, **9.32 per cent.**
The United States, 6.79 per cent.

At the top end the picture is entirely different: Japan 30.35 per cent, Korea
40.07, Norway 48.19, Switzerland 49.36. Almost half a Swiss farmer's receipts
come from support; one fortieth of an Australian's.

A distinction is needed: Australia is **not** the world's lowest. New Zealand
is lower, at 1.53 per cent. And the measure comes out negative in some
economies — there the producer is not supported but implicitly taxed through
price policy. Australia's place is at the end where support is positive but
very small.

What that means in practice: in a drought, a price collapse or a lost market,
the Australian farmer cannot lean on a state price guarantee. He carries the
risk himself — and the way to carry risk is either to grow in scale or to be
able to buy the scarce input.

That scarce input is water. And Australia has tied that to a market too.$dsr$, array['destek']::text[], 'veri', null),
  (10, $dsr$Suyun kendi sicili$dsr$, $dsr$Water has a register of its own$dsr$, $dsr$Victoria eyaletinde bir kadastro memurunun masasında, toprak kayıtlarının
yanında ikinci bir defter duruyor. O defterde parsel yok; suyun kendisi var —
kim sahibi, adresi ne, üzerinde ipotek var mı.

Bu defterin adı su sicili. Victoria'nın 1989 tarihli Su Kanunu'nun tasdikli
metni dokuz yüz yirmi üç sayfa ve içinde "su sicili" ibaresi yüz doksan yerde,
"Sicil Memuru" yüz elli dört yerde geçiyor. Kanun, sicile su payıyla ilgili
neyin kaydedileceğini sayıyor ve ilk sırada malikin adı ve adresi duruyor.

Bizde su hakkı araziye bağlıdır: tarlayı satarsınız, suyu da gider.
Victoria'da su payı ayrı bir mülk. Araziniz olmadan sahip olabilirsiniz, iki
kişi onu ortak tutabilir, üstüne ipotek konabilir — kanun "bir su payının
ipoteği" ibaresini yedi ayrı yerde kullanıyor.

Ayrışma kanunun bir yerinde ilan edilmiyor; **yapısından** okunuyor. Kısım 3A
suyun kendisine dair hakkı düzenliyor ve su payı olmaksızın su almayı suç
sayıyor. Çok daha ilerideki Kısım 4B ise o suyun **belirli bir arazide**
kullanılmasını düzenliyor ve ayrı bir suç tanımlıyor. İki ayrı kısım, iki ayrı
belge, iki ayrı suç.

Bunun sonucu defterde görünüyor. Kuzey Victoria'da yüksek güvenilirlikli su
hakkı her yılın 30 Haziran'ında sayılıyor. 2000-01 sayımında iki bin iki yüz
seksen üç gigalitrenin **tamamı** toprağa bağlıydı — yüz üzerinden yüz.
2023-24 sayımında toprağa bağlı kalan pay **yüzde elli virgül iki.**

Geri kalanın yüzde on sekiz virgül biri özel ellerde ama hiçbir araziye bağlı
değil; yüzde yirmi dokuz virgül yedisi çevrenin. Su piyasası kurulunca, suyu
kullanmak için değil nehirde bırakmak için satın alan bir alıcı da ortaya
çıkmış.

Bu rakamların hepsi kuzey Victoria'ya ait; Avustralya'nın tamamı için böyle
bir seri bu dosyanın kaynaklarında yok.$dsr$, $dsr$In the state of Victoria, on a land registrar's desk, a second ledger sits
beside the land records. There are no parcels in it. The water itself is there
— who owns it, what their address is, whether there is a mortgage over it.

That ledger is the water register. The authorised text of Victoria's Water Act
1989 runs 923 pages, and the phrase "water register" appears in 190 places,
"the Registrar" in 154. The Act lists what must be recorded in the register
about a water share, and the owner's name and address come first.

Here, a water right attaches to land: you sell the field and the water goes
with it. In Victoria a water share is separate property. You can hold one
without owning land, two people can hold it jointly, and it can be mortgaged —
the Act uses the phrase "mortgage of a water share" in seven separate places.

The separation is not declared anywhere in the Act; it is read from its
**structure.** Part 3A governs the right to the water itself and makes it an
offence to take water without a water share. Part 4B, much later, governs the
use of that water **on particular land** and defines a separate offence. Two
parts, two documents, two offences.

The consequence shows in the ledger. High-reliability water entitlement in
northern Victoria is counted each 30 June. In the 2000-01 count, **all** 2,283
gigalitres were tied to land — a hundred out of a hundred. In the 2023-24
count, the share still tied to land is **50.2 per cent.**

Of the remainder, 18.1 per cent is in private hands but attached to no land;
29.7 per cent belongs to the environment. Once a water market existed, a buyer
appeared who purchases water not to use it but to leave it in the river.

All of these figures are for northern Victoria; no such series for Australia
as a whole exists among this file's sources.$dsr$, array['su_kimde']::text[], 'belge', $dsr${"url":"https://tarimportali.net/dosya/avustralya/avustralya_torrumbarry_bent.jpg","atif":"Chicken-7 — Public domain","kaynak":null,"alt_tr":"Torrumbarry Bendi, Murray nehri. Kapaklardan geçen su ölçülüyor ve pay sahiplerine yazılıyor.","alt_en":"Torrumbarry Weir on the Murray. Water passing the gates is measured and booked to shareholders."}$dsr$::jsonb),
  (11, $dsr$Megalitrenin fiyatı$dsr$, $dsr$The price of a megalitre$dsr$, $dsr$Bir şeyin mülk olup olmadığını anlamanın en kısa yolu fiyatına bakmaktır.

Kuzey Victoria'da yüksek güvenilirlikli su payının devir fiyatı sicilin
kaydında yıl yıl duruyor. 2013-14'te megalitresi **bin üç yüz seksen**
Avustralya doları — serinin en düşüğü. 2022-23'te **beş bin dolar.** Dokuz
yılda **üç virgül altı kat.**

Beş bin dolar bir megalitre suyun fiyatı değil; bir megalitreyi **her yıl**
alma hakkının fiyatı. Bir gelir akışının bugünkü değeri. Yüz megalitrelik bir
pay, zirve fiyatında beş yüz bin dolarlık bir varlık demek — ve kanunun ipotek
hükümlerinin neden yedi yerde geçtiğini bu açıklıyor.

Düşük güvenilirlikli pay — ancak bol yıllarda su gören pay — 2008-09'da iki
yüz dolardı, 2023-24'te sekiz yüz elli. Güvenilirliğin primi azalmış;
kuraklıkta su görmeyen pay bile değerlenmiş.

Bu fiyatlar bölgeler arası medyan ve medyan bir şeyi gizliyor. Sicil, su payı
fiyatlarının tarihsel olarak birbirine yakın seyrettiğini söylüyor; 2018'den
sonra bu yakınlık bozulmuş. Bozulma en çok tek bir yerde: Barmah darlığının
**aşağısındaki** Murray bölgesinde. Orada düşük güvenilirlikli payın fiyatı
Temmuz 2018'de megalitresi **dört yüz kırk dört dolar** iken Haziran 2024'te
**bin sekiz yüz altmış bir dolara** çıkmış — dört virgül iki kat, ve raporun
ifadesiyle artış hiçbir bölgede bu kadar belirgin değil.

Sicil nedeni iki etkene bağlıyor: o bölgede çok yıllık bahçe tarımının
büyümesi ve suya yüksek ödeme isteği; ve bölgeye tahsis ticareti kısıtlarının
**artması.**

İkinci etken bir sonraki bölümün konusu — ve dosyanın en şaşırtıcı yeri.$dsr$, $dsr$The shortest way to tell whether something is property is to look at its
price.

The transfer price of a high-reliability water share in northern Victoria
stands year by year in the register's record. In 2013-14 it was **1,380
Australian dollars** per megalitre — the lowest in the series. In 2022-23,
**5,000 dollars.** **3.6 times** in nine years.

Five thousand dollars is not the price of a megalitre of water; it is the
price of the right to take a megalitre **every year.** The present value of an
income stream. A hundred-megalitre share, at peak price, is a
half-million-dollar asset — which explains why the Act's mortgage provisions
appear in seven places.

A low-reliability share — one that sees water only in wet years — was 200
dollars in 2008-09 and 850 in 2023-24. The premium on reliability has
narrowed; even the share that sees no water in a drought has gained value.

These prices are medians across regions, and a median conceals something. The
register says water share prices historically moved closely together; after
2018 that closeness broke. The break is concentrated in one place: the Murray
region **below** the Barmah choke. There, the price of a low-reliability share
went from **444 dollars** per megalitre in July 2018 to **1,861 dollars** in
June 2024 — 4.2 times, and in the report's own words the rise was not this
pronounced in any other region.

The register attributes it to two factors: growth in perennial horticulture in
that region and a high willingness to pay for water; and an **increase** in
restrictions on allocation trade into the region.

The second factor is the subject of the next section — and the most surprising
part of this file.$dsr$, array['kalici_hakkin_fiyati']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/avustralya/avustralya_ana_kanal.jpg","atif":"Willem van Aken, CSIRO — CC BY 3.0","kaynak":null,"alt_tr":"Griffith'te ana sulama kanalı, 1989. Kanaldaki su hiçbir tarlanın değil; geçtiği arazilerin sahipleriyle de ilgisi yok.","alt_en":"The main irrigation channel at Griffith, 1989. The water in the channel belongs to no field, and has no connection to the owners of the land it passes."}$dsr$::jsonb),
  (12, $dsr$Nehrin daraldığı yer$dsr$, $dsr$Where the river narrows$dsr$, $dsr$Şimdiye kadar anlatılan her şey hukuk, defter ve fiyattı. Burada coğrafya söze
giriyor ve hepsini yeniyor.

Murray nehri, Barmah denen bir noktada daralıyor. Açılış raporunun ifadesiyle
bu darlık nehrin akışını günde yaklaşık **yedi bin megalitre** ile sınırlıyor.

Sonucu şudur: suyun hakkı devredilebilir, fiyatı vardır, sicile kayıtlıdır,
ipotek edilebilir — ama su nehirden geçmek zorundadır. Ve nehrin o noktadaki
kapasitesi bir hukuk kurumu değil, bir yatak genişliği.

Aşağı taraftaki bir alıcı yukarıdaki bir satıcıdan su aldığında, sözleşme
kurulsa bile suyun fiilen taşınması ayrı bir izne bağlı. O izin de darlıktan
geçebilecek hacimle sınırlı.

Temmuz 2026'da bu kapasite sayıyla ilan edildi: 2 Temmuz sabahı yedide Barmah
için açılan ticaret imkânı **yirmi dört bin yüz yirmi bir virgül üç
megalitre.**

Aynı gün kapanan başvuru penceresine iki eyaletten iki yüz on dört uygun
başvuru geldi ve toplam hacimleri **altmış yedi bin dört yüz kırk beş virgül
iki megalitre** oldu. Rapor bunu kendi diliyle değerlendiriyor: uygun
başvuruların toplam hacmi mevcut ticaret imkânını belirgin biçimde aştı.

Kapasitenin **iki virgül sekiz katı** talep.

Başvuruların boyutu da anlatıcı. Victoria'dan gelenlerin hacmi yirmi virgül
dört megalitreyle iki bin dört yüz seksen dört virgül dört megalitre arasında;
ortancası **yüz on megalitre.** Kuyruktaki tipik başvuru büyük bir yatırım
fonu değil, orta ölçekli bir sulayıcı.

İki virgül sekiz kat talep, yedi bin megalitrelik bir yatak. Sıra birine
verilecek. Soru, kime.$dsr$, $dsr$Everything so far has been law, ledger and price. Here geography enters and
beats all of it.

The Murray narrows at a place called Barmah. In the opening report's words,
that choke limits the river's flow to approximately **7,000 megalitres per
day.**

The consequence: a water right can be transferred, it has a price, it is
recorded in a register, it can be mortgaged — but the water has to travel down
the river. And the river's capacity at that point is not a legal institution.
It is a width of channel.

When a buyer downstream takes water from a seller upstream, even with a
contract in place, the physical transfer depends on a separate approval. And
that approval is limited by the volume that can pass the choke.

In July 2026 this capacity was announced as a number: at seven in the morning
on 2 July, the trade opportunity opened for Barmah was **24,121.3
megalitres.**

Into the application window that closed the same day came 214 eligible
applications from two states, with a combined volume of **67,445.2
megalitres.** The report assesses this in its own language: the total volume
of eligible applications significantly exceeded the available trade
opportunity.

Demand at **2.8 times** capacity.

The size of the applications is telling too. Those from Victoria ranged from
20.4 to 2,484.4 megalitres, with a median of **110 megalitres.** The typical
applicant in that queue is not a large investment fund but a mid-sized
irrigator.

Demand at 2.8 times capacity, against a 7,000-megalitre channel. The queue
will be given to someone. The question is to whom.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/avustralya/avustralya_barmah_murray.jpg","atif":"AndreB94 — CC BY-SA 4.0","kaynak":null,"alt_tr":"Murray nehri, Barmah'ta. Nehrin bu noktadaki genişliği bir hukuk kurumu değil; aşağı geçebilecek su miktarını o belirliyor.","alt_en":"The Murray at Barmah. The river's width at this point is not a legal institution; it is what determines how much water can pass downstream."}$dsr$::jsonb),
  (13, $dsr$Sıra kurayla belirleniyor$dsr$, $dsr$The order is settled by ballot$dsr$, $dsr$Cevap beklenmedik: sıra kurayla belirleniyor.

İşleyiş şöyle. Kapasite sabah yedide ilan ediliyor, başvuru penceresi
açılıyor, pencere kapandıktan sonra başvurular uygunluk denetiminden geçiyor.
Sonra, raporun kendi ifadesiyle, uygun başvurular **işlenme sırasını saptamak
için rastgeleleştiriliyor.**

Önce başvuran önce geçmiyor. Daha çok ödeyen önce geçmiyor. Sıra tesadüfe
bırakılıyor ve başvurular o sırayla işleniyor; kapasite tükendiğinde geri
kalanlar reddediliyor — kuralı çiğnedikleri için değil, kurada arkada
kaldıkları için.

Çekilişi Victoria'nın ilgili bakanlığı ile Yeni Güney Vales'in su kurumu
**birlikte** yapıyor, ve çekilişin başında Avustralya Rekabet ve Tüketici
Kurumu'ndan bir temsilci bulunuyor. Kurumun Su Birimi Genel Müdür Vekili, 3
Ağustos 2026 tarihli yazısında temsilcinin çekilişi gözlemlediğini, kaydını
sonradan incelediğini ve **çıktıda hiçbir düzenleme ya da değişiklik
gözlemlemediğini** beyan ediyor.

Sicil bu yöntem için kendi raporunda bir nitelik kullanıyor: rastgeleleştirme
yaklaşımı, ticaret açılışlarındaki aksaklıkları yönetmek üzere **geçici bir
çözüm** olarak uygulanmaya başlandı.

Kuranın ne yaptığı, aynı gün yapılan iki açılış yan yana konduğunda görünüyor.
2 Temmuz 2026'da iki ayrı güzergâh için iki pencere açıldı ve ikisinin sırası
da aynı yöntemle belirlendi.

Goulburn sisteminden Murray'e giden güzergâhta ilan edilen kapasite yüz on iki
bin sekiz yüz yirmi yedi virgül dokuz megalitre; kuraya giren iki yüz seksen
altı başvurudan **iki yüz seksen ikisi onaylandı. Onay oranı yüzde doksan
sekiz virgül altı.**

Barmah darlığından geçen güzergâhta kapasite yirmi dört bin yüz yirmi bir
virgül üç megalitre; iki yüz on dört başvurudan **altmış ikisi onaylandı. Onay
oranı yüzde yirmi dokuz.**

Aynı gün, aynı idare, aynı kura yöntemi, aynı gözlemci kurum. Aradaki tek fark
fiziksel: birinde nehir daralıyor, ötekinde daralmıyor.

Yalnız Victoria'nın başvurularına bakıldığında tablo keskinleşiyor: Barmah
için yüz otuz altı başvuru kuraya girmiş, otuz üçü onaylanmış, **yüz üçü
reddedilmiş** — ve yüz üç başvurunun her biri kurallara uygundu.

Piyasa, kapasite bol olduğu sürece neredeyse herkesi geçiriyor. Kapasite
kıtlaştığında fiyat değil, kura karar veriyor.$dsr$, $dsr$The answer is unexpected: the order is settled by ballot.

It works like this. Capacity is announced at seven in the morning, the
application window opens, and after it closes the applications are checked for
eligibility. Then, in the report's own words, eligible applications are
**randomised to determine the order of processing.**

First to apply does not go first. Highest bidder does not go first. The order
is left to chance, and applications are processed in that order; when capacity
runs out the rest are refused — not for breaking a rule, but for coming late
in the draw.

The draw is conducted **jointly** by Victoria's responsible department and New
South Wales's water authority, with a representative of the Australian
Competition and Consumer Commission present at it. In a letter dated 3 August
2026, the Commission's Acting General Manager for its Water Unit states that
the representative observed the draw, subsequently reviewed its record, and
**observed no adjustment or alteration to the output.**

The register applies one qualifier to the method in its own report: the
randomisation approach was introduced as an **interim solution** for managing
the difficulties in trade openings.

What the ballot does becomes visible when two openings held the same day are
placed side by side. On 2 July 2026 two windows opened for two different
routes, and both orders were set by the same method.

On the route from the Goulburn system to the Murray, the announced capacity
was 112,827.9 megalitres; of 286 applications entering the ballot, **282 were
approved. An approval rate of 98.6 per cent.**

On the route through the Barmah choke, capacity was 24,121.3 megalitres; of
214 applications, **62 were approved. An approval rate of 29.0 per cent.**

The same day, the same administration, the same ballot method, the same
observing body. The only difference between them is physical: in one the river
narrows, in the other it does not.

Looking at Victoria's applications alone sharpens it: 136 applications entered
the ballot for Barmah, 33 were approved, **103 were refused** — and every one
of those 103 complied with the rules.

As long as capacity is ample, the market passes nearly everyone. When capacity
grows scarce, it is not price that decides. It is the ballot.$dsr$, array['iki_acilis']::text[], 'akis', $dsr${"url":"https://tarimportali.net/dosya/avustralya/avustralya_goulburn_benti.jpg","atif":"Mattinbgn (talk · contribs) — CC BY 3.0","kaynak":null,"alt_tr":"Goulburn Bendi, Goulburn nehri. Kapaklar ne kadar suyun aşağı geçeceğini belirliyor.","alt_en":"Goulburn Weir on the Goulburn River. The gates determine how much water passes downstream."}$dsr$::jsonb),
  (14, $dsr$Kuraklığı kimse ilan etmiyor$dsr$, $dsr$Nobody declares the drought$dsr$, $dsr$Avustralya'da kuraklıkla ilgili en şaşırtıcı kurumsal olgu, kuraklığın ilan
edilmemesi.

Meteoroloji Bürosu kendi sayfasında bunu açıkça yazıyor: Avustralya
Hükûmeti'nin bir kurumu olarak Büro kuraklık ilan etmiyor, ve Avustralya
Hükûmeti kuraklık ilanı yapmıyor. Kuraklık politikalarını eyalet ve bölge
yönetimleri kendi yetki alanlarında yürütüyor.

Büro kuraklığı tanımlıyor da: normal kullanım için yeterli su bulunmayan, uzun
süreli ve olağan dışı kuru dönem. Ve hemen ardından bir uyarı geliyor —
kuraklık yalnızca az yağış değil; öyle olsaydı iç Avustralya'nın büyük bölümü
neredeyse her zaman kurak sayılırdı. Süreye göre ad da değişiyor: haftalarla
ölçülene ani kuraklık, aylarla ölçülene meteorolojik kuraklık, birkaç yıla
yayılana hidrolojik kuraklık deniyor.

Büro ilan etmiyor ama ölçüyor ve yayımlıyor. Kuraklık Bildirisi adlı belgenin
arşivinde 10 Ocak 2000 ile 4 Ağustos 2016 arasında **yüz doksan iki** bildiri
duruyor.

Arşivin en ilginç yanı bildirilerin kendisi değil, yayımlanmadığı aylar. Ekim
2011'den Mayıs 2012'ye kadar **sekiz ay** üst üste bildiri yayımlanmamış. Büro
o ayların sayfalarını boş bırakmamış; sayfa var ve üzerinde o ay için bildiri
yayımlanmadığı yazıyor.

Burada iki şeyi ayırmak gerekiyor. Birincisi: 2011'de yayımlanan bildiriler
ağırlıkla güneybatı Batı Avustralya'yı anlatıyor, Murray-Darling havzasını
değil; aynı dönemde doğuda yağış dönmüştü. "Avustralya'nın kuraklığı" diye tek
bir olgudan söz etmek bu kayıtla mümkün değil — Büro bölge bölge yazıyor.

İkincisi, iki defteri birbirine bağlama iştahı. Bildirisiz sekiz ay su yılı
2011-12'ye düşüyor ve o yılın su kullanım oranı yüksek. Tarihler örtüşmüyor;
meteoroloji kaydı ile su defterinin aynı dönemi anlatması, birinin ötekini
açıkladığı anlamına gelmiyor.

Ülke ölçeğinde su rakamı Büro'nun ulusal raporunda duruyor: 2019-20'de tüketim
amacıyla alınan toplam su **on dört bin iki yüz yetmiş gigalitre.** Aynı
rapor, Victoria ile Yeni Güney Vales'teki tarımsal su kullanımının
Avustralya'nın tarımsal su kullanımının yarısını oluşturduğunu söylüyor. Bu
rakamlar 2019-20'ye ait; su piyasası rakamları 2023-24'e kadar geliyor ve
ikisi aynı yılın fotoğrafı değil.$dsr$, $dsr$The most surprising institutional fact about drought in Australia is that
drought is not declared.

The Bureau of Meteorology says so plainly on its own page: as an agency of the
Australian Government, the Bureau does not declare drought, and the Australian
Government does not make drought declarations. Drought policy is administered
by state and territory governments within their own jurisdictions.

The Bureau does define drought: a prolonged, abnormally dry period when there
is not enough water for normal use. And a warning follows immediately —
drought is not simply low rainfall; if it were, much of inland Australia would
be in drought almost permanently. The name changes with duration too: measured
in weeks it is flash drought, in months meteorological drought, across several
years hydrological drought.

The Bureau does not declare, but it measures and publishes. The archive of the
document called the Drought Statement holds **192** statements between 10
January 2000 and 4 August 2016.

The most interesting thing in the archive is not the statements but the months
without one. From October 2011 to May 2012, **eight consecutive months** carry
no statement. The Bureau did not leave those pages blank; the page exists and
says that no statement was issued for that month.

Two things have to be kept apart here. First: the statements published in 2011
describe mainly south-west Western Australia, not the Murray-Darling Basin; in
the same period the rain had returned in the east. This record does not permit
speaking of "Australia's drought" as a single phenomenon — the Bureau writes
region by region.

Second, the appetite for tying the two ledgers together. The eight
statement-free months fall in the 2011-12 water year, and water use that year
was high. The dates do not line up; a meteorological record and a water ledger
describing the same period does not mean one explains the other.

The national water figure sits in the Bureau's national report: in 2019-20,
total water taken for consumptive use was **14,270 gigalitres.** The same
report says agricultural water use in Victoria and New South Wales makes up
half of Australia's agricultural water use. These figures are for 2019-20; the
water market figures run to 2023-24, and the two are not a photograph of the
same year.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/avustralya/avustralya_kuraklik_uydu.jpg","atif":"NASA image of NDVI anomaly by Jesse Allen using MODIS data provided by Inbal Reshef as part of the Global Agricultural Monitoring Project involving NASA, USDA’s Foreign Agricultural Service (FAS), and the University of Maryland. Assaf Anyamba from the Goddard Earth Sciences Technology Center, and James Crutchfield with FAS, contributed to the caption as part of the same partnership. More data and information about this joint project is available at Satellite Information for Agricultural Monitoring. — Public domain","kaynak":null,"alt_tr":"Doğu Avustralya'da bitki örtüsünün normalden sapması; kahverengi normalin altını, yeşil üstünü gösteriyor. Büro kuraklık ilan etmiyor, ölçüyor.","alt_en":"Vegetation anomaly across eastern Australia; brown is below normal, green above. The Bureau does not declare drought, it measures it."}$dsr$::jsonb),
  (15, $dsr$Yemişin iki yönlü yolculuğu$dsr$, $dsr$The two-way journey of a nut$dsr$, $dsr$Dosyanın başındaki rakama dönelim. 2024'te Türkiye Avustralya'ya yüz seksen
bir milyon dokuz yüz bin dolarlık tarım ürünü sattı; Avustralya bize elli
dokuz milyon iki yüz bin dolarlık. Denge üç kat bizim lehimize.

Kalemlere bakıldığında ilişkinin ne kadar dar bir yerde kurulduğu görünüyor.

Avustralya'nın bize sattığı tarım ürününün neredeyse tamamı tek bir alt
fasılda: **sert kabuklu yemiş, elli dört milyon dolar.** Gümrük tarifesinde bu
kalem hindistan cevizi, Brezilya cevizi ve kaju dışındaki yemişleri kapsıyor —
badem, ceviz, fıstık, fındık. Geri kalan kalemler küçük: işlenmiş hayvansal
ürünler üç milyon iki yüz bin, et sekiz yüz bin, süt üç yüz bin dolar.

Türkiye'nin sattığı taraf daha dağınık ve daha büyük. Aynı yemiş faslında
yirmi yedi milyon üç yüz bin dolar; üstüne **kuru meyve yirmi bir milyon sekiz
yüz bin**, taze ya da kuru üzüm **yirmi bir milyon beş yüz bin**, incir ve
hurma gibi kalemler **on dört milyon yüz bin dolar.** Ayrıca hazır meyve-sebze
ürünleri kırk beş milyon, katı ve sıvı yağlar on üç milyon yedi yüz bin,
fırıncılık ürünleri sekiz milyon sekiz yüz bin dolar.

Yani ilişki şöyle kurulmuş: Avustralya bize bir şey satıyor — yemiş. Biz ona
dört şey satıyoruz — yemiş, kuru meyve, üzüm ve incir.

İki ülke aynı rafta buluşuyor ve her ikisi de o rafın üreticisi. Avustralya
bademi Murray boyunca, bu dosyanın anlattığı sulama bölgelerinde yetişiyor;
sicilin kuzey Victoria için kaydettiği beş bin dolarlık megalitre fiyatını
ödeyen çok yıllık bahçe tarımı tam da bu — bahçeler Murray boyunca üç eyalete
yayılıyor, fiyat kaydı ise yalnız bir eyaletin. Türkiye'nin kuru üzümü Ege'de,
inciri Aydın'da, fındığı Karadeniz'de.

Ticaretin bu kadar dar bir yerde yoğunlaşması bir fırsat da gösteriyor:
Avustralya'nın büyük ihracat kalemlerinin — et, hububat, bakliyat, süt —
hiçbiri Türkiye'ye gelmiyor. Kırk bir milyar sekiz yüz altmış dokuz milyon
dolarlık ihracatın bize düşen payı binde bir virgül dört.$dsr$, $dsr$Return to the figure at the start of this file. In 2024 Türkiye sold Australia
181.9 million dollars of agricultural produce; Australia sold us 59.2 million.
The balance runs three times in our favour.

Looking at the items shows how narrow a place the relationship was built in.

Almost all of what Australia sells us sits in a single sub-chapter: **nuts,
54.0 million dollars.** In the customs tariff that item covers nuts other than
coconuts, Brazil nuts and cashews — almonds, walnuts, pistachios, hazelnuts.
The remaining items are small: processed animal products 3 million, meat 0.8
million, dairy 0.3 million dollars.

Türkiye's side is more dispersed and larger. In the same nut chapter, 27.3
million dollars; on top of that **dried fruit 21.8 million**, fresh or dried
grapes **21.5 million**, items such as figs and dates **14.1 million
dollars.** Also prepared fruit and vegetable products 45 million, fats and
oils 13.7 million, bakery products 8.8 million dollars.

So the relationship is built like this: Australia sells us one thing — nuts.
We sell them four — nuts, dried fruit, grapes and figs.

The two countries meet on the same shelf and both produce it. Australia's
almonds grow along the Murray, in the irrigation districts this file has been
describing; the perennial horticulture paying the 5,000-dollar megalitre price
the register records for northern Victoria is precisely this — the orchards
run along the Murray across three states, while the price record covers only
one of them. Türkiye's sultanas are in the Aegean, its figs in Aydın, its
hazelnuts on the Black Sea.

That the trade concentrates in so narrow a place also shows an opening: none
of Australia's large export items — meat, cereals, pulses, dairy — comes to
Türkiye. Our share of a 41.87-billion-dollar export is 0.14 per cent.$dsr$, array['turkiye_yemis']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/avustralya/avustralya_mildura_bagi.jpg","atif":"Longhair at English Wikipedia — Public domain","kaynak":null,"alt_tr":"Mildura'da bağ. Avustralya ile Türkiye birbirine aynı rafı satıyor: yemiş, kuru meyve ve üzüm.","alt_en":"Vines at Mildura. Australia and Türkiye sell each other the same shelf: nuts, dried fruit and grapes."}$dsr$::jsonb),
  (16, $dsr$Türkiye buradan ne görebilir$dsr$, $dsr$What Türkiye can see from here$dsr$, $dsr$Bu dosya bir model önermiyor. Avustralya'nın kurduğu şey belirli bir
coğrafyanın, belirli bir hukuk geleneğinin ve belirli bir federal yapının
ürünü. Aktarılabilir olan mekanizma değil, mekanizmanın ortaya çıkardığı
sorular.

**Birincisi ölçek.** Beş yüz otuz bir hektarlık buğday işletmesi, düşük
verimle para kazanmanın bir yolu. Türkiye'nin tarım yapısı bunun tersi: çok
üretici, küçük parsel, yüksek verim hedefi. İki model farklı sorunlara cevap
veriyor ve biri ötekine çevrilemez. Ama Avustralya'nın verim rakamları —
buğdayda hektardan iki virgül altmış yedi ton — bir şeyi gösteriyor: verim
düşük olduğunda ölçek zorunlu hale geliyor.

**İkincisi destek.** Avustralyalı çiftçinin hasılatının yüzde iki virgül
yetmiş biri destekten geliyor; Türk çiftçisinin yüzde dokuz virgül otuz ikisi.
Bu bir iyi-kötü karşılaştırması değil, bir risk dağılımı farkı. Desteği düşük
bir sistemde riski üretici taşıyor ve ayakta kalanlar ölçek büyütenler oluyor.
Rakamın kendisi bir tercih değil, bir tercihin sonucu.

**Üçüncüsü ölçmeyle ilgili ve en aktarılabilir olanı bu.** Victoria'nın
yapabildiği her şeyin temeli bir sicil: her su payının maliki, hacmi,
güvenilirlik sınıfı ve üzerindeki takyidat kayıtlı. Suyun fiyatlanabilmesi,
devredilebilmesi, hatta çevre adına satın alınabilmesi bu kaydın varlığına
bağlı. Bir ülke "suyu kim kullanıyor" sorusunu parsel düzeyinde
cevaplayamıyorsa, bunun üstüne kurulacak hiçbir mekanizma işlemez.

**Dördüncüsü ve en keskini:** Avustralya suyun hukukunu kurdu, sicilini kurdu,
piyasasını kurdu, fiyatını kurdu. Ve bütün bunların sonunda, nehrin daraldığı
noktada elinde kalan yöntem kura oldu. Fiziksel kapasite kıt olduğunda
piyasanın cevabı yok.

Türkiye'nin havzalarında da taşıma kapasitesi sınırlı. Oradaki soru "su
piyasası kurulsun mu" değil; kapasite yetmediğinde sıranın hangi kurala göre
belirlendiğinin yazılı olup olmadığı. Avustralya'da bu kural yazılı, geçici
olduğu kabul edilmiş, ve uygulaması bağımsız bir kurum tarafından izleniyor.

**Beşincisi ticaret.** Kırk bir milyar sekiz yüz altmış dokuz milyon dolarlık
bir tarım ihracatçısıyla yılda elli dokuz milyon iki yüz bin dolarlık
alışverişimiz var ve onun da tamamına yakını tek kalemde. Avustralya'nın
sattığı et, bakliyat ve süt ürünleri bize hiç gelmiyor. Bu bir boşluk mu yoksa
mesafenin ve mevsim farkının doğal sonucu mu — cevabı bu dosyanın verisinde
yok, ama sorunun kendisi burada duruyor.$dsr$, $dsr$This file proposes no model. What Australia has built is the product of a
particular geography, a particular legal tradition and a particular federal
structure. What transfers is not the mechanism but the questions the mechanism
raises.

**First, scale.** A 531-hectare wheat holding is one way of making money at
low yields. Türkiye's agricultural structure is the inverse: many growers,
small parcels, a high-yield objective. The two models answer different
problems and neither converts into the other. But Australia's yield figures —
2.67 tonnes to the hectare in wheat — show one thing: when yield is low, scale
becomes compulsory.

**Second, support.** 2.71 per cent of an Australian farmer's receipts comes
from support; 9.32 per cent of a Turkish farmer's. This is not a
good-versus-bad comparison but a difference in how risk is distributed. In a
low-support system the producer carries the risk, and those who survive are
those who grow in scale. The figure itself is not a choice but the consequence
of one.

**Third — and this is the most transferable — measurement.** Everything
Victoria is able to do rests on a register: the owner, volume, reliability
class and encumbrances of every water share are recorded. That water can be
priced, transferred, even bought on behalf of the environment depends on that
record existing. If a country cannot answer "who is using the water" at parcel
level, no mechanism built on top of that will function.

**Fourth, and sharpest:** Australia built the law of water, built its
register, built its market, built its price. And at the end of all of it, at
the point where the river narrows, the method left in its hand was a ballot.
When physical capacity is scarce, the market has no answer.

Carrying capacity is limited in Türkiye's basins too. The question there is
not whether to establish a water market; it is whether the rule determining
the queue, when capacity falls short, is written down. In Australia that rule
is written, is acknowledged to be interim, and its application is observed by
an independent body.

**Fifth, trade.** We do 59.2 million dollars a year of business with a
41.87-billion-dollar agricultural exporter, and nearly all of it in one item.
The meat, pulses and dairy Australia sells never reach us. Whether that is a
gap or the natural consequence of distance and opposite seasons is not
answered by this file's data — but the question stands here.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/avustralya/avustralya_insan_yapimi_kanal.jpg","atif":"division, CSIRO — CC BY 3.0","kaynak":null,"alt_tr":"Kazılmış bir sulama kanalı. Bir yanda su, öbür yanda kuru set; yan yana duruyorlar ve biri ötekinin rengini almıyor.","alt_en":"An excavated irrigation channel. Water on one side, dry bank on the other; they lie side by side and neither takes the other's colour."}$dsr$::jsonb),
  (17, $dsr$Kaynakça$dsr$, $dsr$Sources$dsr$, $dsr$Bu dosyanın rakamları beş kaynaktan geliyor ve her birinin kendi sınırı var.

**Avustralya İstatistik Kurumu (ABS).** Tarla bitkisi rakamları *Australian
Agriculture: Broadacre Crops* serisinden; alan, üretim, değer ve işletme
sayısı 2023 yılına ait ve ulusal toplam. Seri yalnızca son üç yılı kapsıyor,
yani uzun dönemli ürün karşılaştırması bu kaynaktan yapılamıyor. Pamukta alan
verisi var, üretim ve değer alanları boş. Hayvan kesimi rakamları *Livestock
slaughtered* serisinden ve bu seri 1973'e kadar gidiyor; çeyreklik
yayımlanıyor, bu dosyada yıla toplandı ve dört çeyreği tam olmayan yıllar
dışarıda bırakıldı. Değerler bin baş.

**OECD.** Üretici Destek Tahmini, çiftçinin brüt hasılatının yüzdesi olarak.
2023 yılı. Ölçü bazı ekonomilerde negatif çıkabiliyor; bu, üreticinin
desteklenmediğini değil örtülü olarak vergilendirildiğini gösteriyor.
Avustralya'nın rakamı düşük ama en düşük değil — Yeni Zelanda daha aşağıda.

**UN Comtrade.** Dış ticaret rakamları, ABD doları, 2024 (zaman serisinde
2005'ten itibaren). Bu kaynakta aynı hücre hem toplu hem kırılımlı geliyor ve
hepsi toplanırsa sonuç gerçeğin katı çıkıyor; gümrük rejimi, taşıma türü ve
ikinci partner boyutlarında yalnızca toplam satır alındı. Ayrıca bu muhabir
için ağırlık alanları boş geliyor — dosyada hiçbir yerde tonaj verilmedi,
yalnızca değer.

**Victoria Su Sicili (DEECA).** Su piyasası rakamları *Water Market Trends
2001–2024* ve Temmuz 2026 ticaret açılışı raporundan. **Bu rakamların kapsamı
kuzey Victoria'dır, Avustralya geneli değil** — ulusal su piyasası verisi bu
dosya için erişilebilir olmadı. Kaynak piyasayı işleten idarenin kendi
defteridir; bağımsız bir denetim raporu değildir. Tablolardan birinde 2008-09
satırının yazılı yüzdeleri kendi hacimleriyle çelişiyor; bu dosyada yüzdeler
hacimlerden hesaplandı ve o satır metinde kullanılmadı.

**Meteoroloji Bürosu (BoM).** Kuraklık Bildirisi arşivi ve *Water in Australia
2019–20*. Ulusal su rakamı 2019-20'de kalıyor; raporun daha yeni yılları
yayımda değil. Büronun kuraklık tanımı ve "ilan etmiyoruz" ifadesi kurumun
kendi sayfasından.

**Water Act 1989 (Victoria).** Tasdikli Sürüm No. 147, 24 Haziran 2026
itibarıyla, dokuz yüz yirmi üç sayfa. Su payının niteliği, sicil ve ipotek
hükümleri doğrudan bu metinden. Kanunda suyun topraktan ayrı olduğunu ilan
eden bir cümle bulunmuyor; ayrışma iki ayrı kısmın varlığından okunuyor.

Ulaşılamayan kaynaklar da kayda değer: Avustralya'nın tarımsal araştırma
kurumunun ve eyalet tarım bakanlıklarının siteleri bu çalışmada açılmadı, bu
yüzden kurum tarihçesi ve araştırma kayıtları dosyaya giremedi.$dsr$, $dsr$The figures in this file come from five sources, each with its own limits.

**Australian Bureau of Statistics (ABS).** Field-crop figures from the
*Australian Agriculture: Broadacre Crops* series; area, production, value and
holdings are for 2023 and are national totals. The series covers only the last
three years, so no long-run commodity comparison can be made from it. For
cotton there is area data but production and value are empty. Livestock
slaughter figures are from the *Livestock slaughtered* series, which goes back
to 1973; it is published quarterly, was aggregated to years here, and years
without four complete quarters were excluded. Values are in thousand head.

**OECD.** Producer Support Estimate, as a percentage of gross farm receipts.
Year 2023. The measure can be negative in some economies; that indicates not
that the producer is unsupported but that he is implicitly taxed. Australia's
figure is low but not the lowest — New Zealand is lower.

**UN Comtrade.** Foreign trade figures, US dollars, 2024 (from 2005 in the
time series). In this source the same cell arrives both aggregated and
disaggregated, and summing everything multiplies the truth; only the total row
was taken on the customs regime, mode of transport and second-partner
dimensions. The weight fields also arrive empty for this reporter — no tonnage
is given anywhere in this file, only value.

**Victorian Water Register (DEECA).** Water market figures from *Water Market
Trends 2001–2024* and the July 2026 trade opening report. **These figures
cover northern Victoria, not Australia as a whole** — national water market
data was not accessible for this file. The source is the ledger of the
administration that operates the market; it is not an independent audit. In
one of the tables the printed percentages of the 2008-09 row contradict its
own volumes; the percentages were computed from the volumes here, and that row
was not used in the text.

**Bureau of Meteorology (BoM).** The Drought Statement archive and *Water in
Australia 2019–20*. The national water figure stops at 2019-20; the report's
more recent years are not published. The Bureau's definition of drought and
its "we do not declare" statement are from its own page.

**Water Act 1989 (Victoria).** Authorised Version No. 147 as at 24 June 2026,
923 pages. The nature of a water share and the register and mortgage
provisions come directly from this text. The Act contains no sentence
declaring water to be separate from land; the separation is read from the
existence of two distinct parts.

The sources that could not be reached are also worth recording: the websites
of Australia's agricultural research body and of the state agriculture
departments would not open during this work, so institutional history and
research records could not enter the file.$dsr$, '{}'::text[], 'belge', null)
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
  if n <> 17 then
    raise exception 'Bölüm sayısı 17 olmalıydı, % yazıldı', n;
  end if;
end
$kontrol$;

commit;
