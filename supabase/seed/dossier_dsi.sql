-- DSİ — Devlet Su İşleri — Ülke Dosyası · seed
--
-- ÜRETİLMİŞ DOSYA — elle düzenlemeyin.
-- Kaynak:  content/dossiers/dsi/
-- Üretim:  node content/dossiers/seed_dossier.mjs dsi
-- Tarih:   2026-11-01T22:25:27.224Z
--
-- Bölüm: 9 · TR ~2.662 kelime · EN ~3.716 kelime
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
  'dsi',
  'DSİ — Devlet Su İşleri',
  'DSİ — State Hydraulic Works',
  null,
  'kurum',
  $dsr$6200 sayılı Kanun · RG 25/12/1953 · 8592 — ve Cumhurbaşkanlığı Kararnamesi No. 4, md. 120 (2018)$dsr$,
  5,
  $dsr$Kuraklıktan doğan kurum suyu getirdi, işletmesini devretti: elli üç yılda dokuz yüz otuz altı tesis.$dsr$,
  $dsr$An institution born of drought brought the water and handed over the running of it: 936 facilities across fifty-three years.$dsr$,
  $dsr${"_dosya":"DSİ — Kurum Dosyası Sayı 05 · tasarım künyesi","_amac":"Evrak görsel dilinin bu dosyadaki uygulaması. DossierTheme bu dosyadan üretilir; kodda serbest renk yazılmaz.","_kural":"Buradaki hiçbir kontrast sayısı 'yaklaşık' değil. Hepsi content/dossiers/_ortak/kontrast.py'den; palet değişirse betik yeniden koşar ve bu sayılar güncellenir.","_kontrast_betigi":"content/dossiers/_ortak/kontrast.py","tez_cumlesi":{"tr":"Kuraklıktan doğan kurum suyu getirdi, işletmesini devretti: elli üç yılda dokuz yüz otuz altı tesis.","en":"An institution born of drought brought the water and handed over the running of it: 936 facilities across fifty-three years.","gerekce":"Cümle İDDİA değil tarif (§8.2). Üç damarı da taşıyor: kuruluş sebebi (kuraklık), kurumun işi (suyu getirmek) ve dosyanın ekseni (devir). Ziraat'in kalıbı izlendi — tanıtıcı bir satır ve TEK ölçü.","_dayanak":"Kuraklık: kurumun kendi Hakkımızda sayfası, 1929'daki 'şiddetli kuraklık ve kıtlık'. Elli üç yıl: devir_serisi'nin ilk (1967) ve son (2020) kaydının farkı, turetilmis.devir_suresi_yil'den. Dokuz yüz otuz altı tesis: 2025 Faaliyet Raporu Tablo 14, satırlardan yeniden toplandı.","_sayi_yaziyla":"Türetilmiş sayı yazıyla yazılır (§8.14.2). 'Elli üç' iki tarihin farkı, 'dokuz yüz otuz altı' tablo toplamı — ikisi de havuzda kalem değil.","_ne_demiyor":"'Yapıyor ama işletmiyor' DEMİYOR ve diyemez: DSİ'nin kendi işlettiği ulusal alan hiçbir kaynakta tek rakam olarak yok. Cümle devrin ölçeğini ve süresini söylüyor, oranını değil."},"kume":{"ad":"Su-toprak","kagit_vurgu":"#11616B","kapak_vurgu":"#4FC0CB","gerekce":"Dizinin altıncı kümesi ve ilk kez kullanılıyor; kontrast.py'de baştan tanımlıydı. TMO kırmızı = kamu gücü (fiyat açıklayarak müdahale), Ziraat yeşil = finans (kredi açarak), Tarım Kredi toprak = üretici örgütü, TAGEM mor = bilgi. DSİ bunların hiçbiri değil: ne fiyat açıklıyor ne kredi veriyor ne örgüt. BETON VE SU döküyor. Arşivde beşinci bir renkle okunmalı."},"palet":{"ad":"Evrak — kağıt gövde","kaynak_fikir":"Kurumun manzarası yok; maddi karşılığı kağıttır. Zemin arşiv kağıdı: haberin sıcak kremine (#F6F1E7) karşı soğuk gri. Dizi kimliği; dosyaya göre değişmiyor.","mod":"KOYU KAPAK → KAĞIT GÖVDE. Sistem açık/koyu tercihini izlemez.","mod_gerekcesi":"Fiziksel dosyanın kendisi: dışı mukavva kapak, içi kağıt. Okur ana sayfadan girip tam ekran koyu kapakla karşılaşıyor, kaydırınca kağıda iniyor.","sayfa":{"zemin":{"hex":"#E3E7E5","rol":"Sayfa zemini — arşiv kağıdı","kontrast_app_krem":1.109},"yuzey":{"hex":"#F0F2F0","rol":"Kart, tablo, kayıt bloğu","kontrast_zemin":1.11},"murekkep":{"hex":"#15191A","rol":"Gövde metni","kontrast_zemin":14.19,"kontrast_yuzey":15.74},"sessiz":{"hex":"#575F61","rol":"Meta, kaynak satırı, altyazı","kontrast_zemin":5.23,"kontrast_yuzey":5.81},"vurgu":{"hex":"#11616B","rol":"Su-toprak — rakamlar, başlık vurguları, devir serisi","kontrast_zemin":5.71,"kontrast_yuzey":6.34},"ikincil":{"hex":"#8A5410","rol":"Karşılaştırmanın ikinci ölçüsü — tesis sayısı payı","kontrast_zemin":5.01,"kontrast_yuzey":5.56,"_not":"Üretici örgütü kümesinin rengi ödünç alındı. Gerekçesi var: ikili_cubuk'ta karşılaştırılan ikinci ölçü DEVRALANLARIN sayısı, yani üretici örgütlerinin kendisi. Küme kimliğiyle çakışmıyor çünkü bu dosyanın kümesi kapakta ve vurgularda okunuyor."},"cizgi":{"hex":"#C0C6C3","rol":"SADECE dekoratif ayırıcı — marj rayı","kontrast_zemin":1.39,"_uyari":"3:1'in altında. Anlam taşıyan hiçbir yerde kullanılamaz; eksen ve odak halkası için cizgiVurgu kullanılır."},"cizgiVurgu":{"hex":"#767E7C","rol":"Grafik ekseni, ızgara, odak halkası","kontrast_zemin":3.34,"kontrast_yuzey":3.7}},"kapak":{"zemin":{"hex":"#131718","rol":"Kapak zemini — mukavva"},"murekkep":{"hex":"#F0F2F0","rol":"Kapak başlığı","kontrast_zemin":16.04},"sessiz":{"hex":"#98A1A2","rol":"Seri etiketi, belge satırı","kontrast_zemin":6.84},"vurgu":{"hex":"#4FC0CB","rol":"Su-toprak, kapak karşılığı","kontrast_zemin":8.37},"yuzey":{"hex":"#1D2325","rol":"Kapak üstü blok","kontrast_zemin":1.13}},"serit":{"_amac":"Ana sayfadaki dosya şeridi sayfanın içinde yaşıyor; krem zemin.","murekkep":{"hex":"#15191A","kontrast_krem":15.73},"vurguKoyu":{"hex":"#11616B","rol":"Su-toprak'ın krem zemindeki karşılığı","kontrast_krem":6.33},"ikincilKoyu":{"hex":"#8A5410","kontrast_krem":5.56},"_ayrisma_notu":"Avustralya'da öğrenildi: şerit vurgusu uygulamanın yapısal yeşiline (#2F4B2E) PARLAKLIK bakımından yakın düşerse kart sayfanın kendi renginden ayrışmıyor. #11616B ile darkGreen arasındaki oran 1,36 — Avustralya'nın ilk hâlindeki 1,03'ün ve Hollanda'da belgelenen çökme deseninin (1,05) üstünde.","_olcum_hatasi":"BU DÖRT SAYI İLK YAZIMDA YANLIŞTI ve kayda geçiyor. Şerit kontrastlarını kontrast.py'den okumadım, TAHMİN ETTİM: 14,77 / 5,52 / 4,85 / 1,61 yazmıştım; doğrusu 15,73 / 6,33 / 5,56 / 1,36. Hiçbiri kararı değiştirmedi — üçü de AA üstünde, ayrışma hâlâ çökme deseninin üstünde — ama §8.4 'hiçbir kontrast sayısı yaklaşık değildir' diyor ve §8.14.3 ölçülmemiş varsayımın belgeye girmesini 'sessiz bir mayın' sayıyor. kontrast.py şerit zeminini (krem #F6F1E7) hesaplamıyor; bu dosyanın değerleri ayrıca hesaplandı."}},"motif":{"ad":"Cetvel çizgisi","tanim":"Defter ve resmî evrak kağıdının marj rayı: solda dikey ray, aralarda ince yatay kural çizgileri.","gerekce":"Kuruma göre DEĞİŞMEZ, dizi kimliğidir (§8.4). Ülke dosyalarında her dosyanın kendi geometrisi var (polder, bant, nokta, ızgara); kurum dizisinde geometri sabit, değişen renktir. Ray iş de yapıyor: bölüm numarası ve kayıt bloklarının girintisi ona hizalanıyor.","uygulama":{"opaklik":"%8","renk":"cizgiVurgu #767E7C üzerine opaklık","bicim":"Vektör (CustomPainter) — telif yok, ölçeklenir, dosya boyutu sıfır","yerlesim":"Bölüm ayırıcılarında ve kapak altı geçiş bandında. Gövde metninin ARKASINDA kullanılmaz.","aralik_notu":"Izgara aralığı 24 px'in altına inmeyecek (moiré)."}},"kapak":{"yon":"Kuruluş belgelerinden kurulan tipografik kapak","gerekce":"Fotoğraf kapak TARTIŞILDI VE REDDEDİLDİ — Ziraat'teki kararın aynısı (§8.8): dizinin görsel kimliği beşinci sayıda kırılırsa hiç kurulmamış olur. Bir kimlik ancak tekrarla kurulur. Güçlü fotoğraflar metnin içine yayılacak, kapağa değil. Tipografik kapak ASIL tasarım, yedek değil (§8.4).","sinir":"Kapak bir belgeyi ALINTILAR, TAKLİT ETMEZ. Resmî Gazete anteti, mühür, arma veya kurum logosu yeniden üretilmez. Kapakta her zaman seri etiketi ve sayı numarası bulunur; ekran görüntüsü bağlamından koparıldığında bile gerçek bir resmî belge sanılamaz.","tipografi_katmani":{"ust_satir":"KURUM DOSYASI · 05 · SU-TOPRAK","baslik":"DEVLET SU İŞLERİ","belge_satiri":"Sular Umum Müdürlüğü · 1929 — 6200 sayılı Kanun · 1953 — Cumhurbaşkanlığı Kararnamesi 4 · 2018","alt_satir":"tez_cumlesi.tr","_belge_satiri_gerekcesi":"Üç belge, üç hukuki kimlik — kapağın kendisi dosyanın ekseni. Üçünün de künyesi birincil kaynaktan okundu; ikisinin RG tarih ve sayısı var."}},"_yasak":["Kurum logosu, arma, mühür, Resmî Gazete anteti — yeniden üretilmez.","Stok 'mutlu çiftçi' fotoğrafı ve dekoratif ikon seti.","Barajın kendisini kahramanlaştıran havadan çekim: dosya inşaatı değil DEVRİ anlatıyor; görsel ekseni bozmaz.","Kapakta fotoğraf (§8.8)."]}$dsr$::jsonb,
  $dsr${"_dosya":"DSİ — Kurum Dosyası Sayı 05 · veri katmanı","_uretim":"build_data.py — elle düzenlenmez","_eksen":"Kuraklıktan doğan kurum ülkenin su altyapısını kurdu ve kurduğunun işletmesini 53 yılda başkalarına devretti.","_eksen_notu":"Süre SABİT YAZILMIYOR, turetilmis.devir_suresi_yil'den kuruluyor. İlk taslakta 'elli dört yıl' yazmıştım; seri 54 KAYIT taşıyor ama 1967-2020 arası 53 YIL. Metinle veri ayrışmasın diye sayı tek yerden geliyor.","_eksenin_siniri":"'Yapıyor ama işletmiyor' DENMİYOR. DSİ'nin kendi işlettiği ulusal alan hiçbir kaynakta tek rakam olarak yok; iddia devrin ÖLÇEĞİ ve SÜRESİ ile sınırlı.","kanun":{"_kaynak_niteligi":"BİRİNCİL — Kanun 6200, mevzuat.gov.tr tasdikli metin","_kapsam":"Türkiye · yürürlükteki metin","no":6200,"ad":"DEVLET SU İŞLERİ GENEL MÜDÜRLÜĞÜNCE YÜRÜTÜLEN","kabul_tarihi":"18/12/1953","rg_tarih":"25/12/1953","rg_sayi":8592,"mulga_maddeler":[1,2,3,4,5,6,7,14,18,19,20,21,22,23,37,38,39,56,57,58],"mulga_ek_maddeler":[3,4,8,14],"mulga_gecici_maddeler":[1,2,3,5,6,7,8],"mulga_dayanak":"2/7/2018 – KHK-703/69 md.","_mulga_onemi":"Mülga olanlar arasında Madde 1 (kuruluş), Madde 2 (vazife ve salahiyetler) ve Madde 3-7 (teşkilat) var. Kanun kurumun adını taşımaya devam ediyor; kurucu maddeleri taşımıyor.","ad_degisikligi_2011":"Devlet Su İşleri Umum Müdürlüğü Teşkilat ve Vazifeleri Hakkında Kanun","mulga_toplam":31},"kararname":{"_kaynak_niteligi":"BİRİNCİL — Cumhurbaşkanlığı Kararnamesi No. 4","_kapsam":"Türkiye · yürürlükteki metin","no":4,"ad":"BAKANLIKLARA BAĞLI, İLGİLİ, İLİŞKİLİ KURUM VE KURULUŞLAR","bolum":"Onuncu Bölüm","madde_amac":119,"madde_kurulus":120,"madde_gorev":121,"kurulus_cumlesi":"Devlet Su İşleri Genel Müdürlüğü kurulmuştur","bagli_oldugu":"Tarım ve Orman Bakanlığına bağlı","_elenen_yol":"Önce CBK 1'e (Cumhurbaşkanlığı Teşkilatı) bakıldı; 'Su İşleri' orada SIFIR kez geçiyor. Metin çıkarımı sağlamdı — 294 sayfa, metin çıkmayan sayfa yok. DSİ ana teşkilat kararnamesinde değil."},"devir_dagilimi":{"_kaynak_niteligi":"KURUMUN BEYANI — DSİ 2025 Faaliyet Raporu, Tablo 14, s. 47","_kapsam":"Türkiye · BÜTÜN sulama tesisleri · 31.12.2025","tarih":"2025-12-31","satirlar":[{"devralan":"Sulama Birliği","adet":181,"adet_yuzde":19,"alan_ha":2562855,"alan_yuzde":83.1},{"devralan":"Kooperatif","adet":414,"adet_yuzde":44,"alan_ha":193740,"alan_yuzde":6.3},{"devralan":"Belediye","adet":160,"adet_yuzde":17,"alan_ha":226146,"alan_yuzde":7.3},{"devralan":"Köy Tüzel Kişiliği","adet":164,"adet_yuzde":18,"alan_ha":29472,"alan_yuzde":1},{"devralan":"Diğer","adet":17,"adet_yuzde":2,"alan_ha":70987,"alan_yuzde":2.3}],"toplam_adet":936,"toplam_alan_ha":3083200,"_toplam_dogrulandi":"adet ve alan satırlardan yeniden hesaplandı; yüzdeler de"},"devir_serisi":{"_kaynak_niteligi":"KURUMUN BEYANI — DSİ 2021 Haritalı İstatistik Bülteni, s. 62","_kapsam":"Türkiye · YALNIZCA YERALTISUYU (YAS) tesisleri · kat'i devir sözleşmesi imzalananların kümülatifi","_kapsam_uyarisi":"Bu seri devir_dagilimi ile TOPLANMAZ ve onun yerine KULLANILMAZ. Sütun başlığı 'Devredilen Kuyu Sayısı'; bu YAS tesisleri, ötekiyse bütün sulama tesisleri.","_isletilen_devredilen_ayrimi_sayfa":64,"_ayrim_notu":"Bülten s. 64 (Çizelge 15-4) DSİ'ce işletilen ve devredilen sulamaları ayrı ayrı listeliyor ama tesis tesis; ulusal toplam yayımlanmıyor. Kaynakçada bu sayfa anılıyor.","_atlanan":"1999 satırının ünite değeri (151) kaynakta HATALI: 1998'de 1.187, 2000'de 1.295. Kümülatif seride düşüş imkânsız. Alan sütunu düzgün ilerliyor, o kullanılıyor; ünite değeri metne girmiyor.","kayitlar":[{"yil":1967,"unite":1,"alan_ha":50},{"yil":1968,"unite":1,"alan_ha":50},{"yil":1969,"unite":1,"alan_ha":50},{"yil":1970,"unite":3,"alan_ha":380},{"yil":1971,"unite":17,"alan_ha":5140},{"yil":1972,"unite":18,"alan_ha":5230},{"yil":1973,"unite":20,"alan_ha":10640},{"yil":1974,"unite":58,"alan_ha":29940},{"yil":1975,"unite":82,"alan_ha":38880},{"yil":1976,"unite":115,"alan_ha":55545},{"yil":1977,"unite":137,"alan_ha":66475},{"yil":1978,"unite":164,"alan_ha":79664},{"yil":1979,"unite":192,"alan_ha":88229},{"yil":1980,"unite":208,"alan_ha":93189},{"yil":1981,"unite":249,"alan_ha":102419},{"yil":1982,"unite":252,"alan_ha":102872},{"yil":1983,"unite":321,"alan_ha":121312},{"yil":1984,"unite":378,"alan_ha":133465},{"yil":1985,"unite":443,"alan_ha":153905},{"yil":1986,"unite":541,"alan_ha":179120},{"yil":1987,"unite":587,"alan_ha":192950},{"yil":1988,"unite":637,"alan_ha":200825},{"yil":1989,"unite":674,"alan_ha":206765},{"yil":1990,"unite":697,"alan_ha":210181},{"yil":1991,"unite":738,"alan_ha":217896},{"yil":1992,"unite":760,"alan_ha":222651},{"yil":1993,"unite":790,"alan_ha":230101},{"yil":1994,"unite":910,"alan_ha":253911},{"yil":1995,"unite":985,"alan_ha":268003},{"yil":1996,"unite":1029,"alan_ha":272878},{"yil":1997,"unite":1084,"alan_ha":281718},{"yil":1998,"unite":1187,"alan_ha":299728},{"yil":1999,"unite":null,"alan_ha":310548},{"yil":2000,"unite":1295,"alan_ha":319243},{"yil":2001,"unite":1368,"alan_ha":329235},{"yil":2002,"unite":1441,"alan_ha":340088},{"yil":2003,"unite":1511,"alan_ha":351361},{"yil":2004,"unite":1600,"alan_ha":361995},{"yil":2005,"unite":1680,"alan_ha":370937},{"yil":2006,"unite":1684,"alan_ha":371457},{"yil":2007,"unite":1728,"alan_ha":378111},{"yil":2008,"unite":1858,"alan_ha":398420},{"yil":2009,"unite":1986,"alan_ha":418247},{"yil":2010,"unite":2060,"alan_ha":427307},{"yil":2011,"unite":2112,"alan_ha":433339},{"yil":2012,"unite":2198,"alan_ha":443126},{"yil":2013,"unite":2228,"alan_ha":445934},{"yil":2014,"unite":2262,"alan_ha":449379},{"yil":2015,"unite":2302,"alan_ha":454486},{"yil":2016,"unite":2309,"alan_ha":455917},{"yil":2017,"unite":2357,"alan_ha":461794},{"yil":2018,"unite":2367,"alan_ha":462842},{"yil":2019,"unite":2371,"alan_ha":463246},{"yil":2020,"unite":2371,"alan_ha":464316}]},"kurulus_silsilesi":{"_kaynak_niteligi":"KURUMUN BEYANI — dsi.gov.tr/Sayfa/Detay/692 (Hakkımızda)","_kapsam":"Türkiye · kurumsal silsile","_not":"Kuruluş tarihi kanun metniyle BAĞIMSIZ OLARAK örtüşüyor: kanun 18/12/1953 kabul diyor, kurum 18 Aralık 1953 diyor. İki ayrı kaynak, aynı tarih.","adimlar":[{"yil":1914,"ad":"Nafıa Nezareti","aciklama":"su işlerinin örgütlü biçimde ele alınması"},{"yil":1925,"ad":"Sular Fen Heyeti","aciklama":"Umur-u Nafıa Müdüriyet-i Umumiyesi'ne bağlı"},{"yil":1929,"ad":"Sular Umum Müdürlüğü","aciklama":"şiddetli kuraklık ve kıtlık"},{"yil":1953,"ad":"Devlet Su İşleri Genel Müdürlüğü","aciklama":"18 Aralık 1953"}],"teskilatlanma_yili":1954},"olcek":{"_kaynak_niteligi":"KURUMUN BEYANI — DSİ 2025 Faaliyet Raporu","_kapsam":"Türkiye · 2025 yıl sonu, kümülatif","sulanabilir_arazi_milyon_ha":8.5,"_sulanabilir_alinti":"sulanabilir tarım arazisi miktarı","hedef_2028_brut_milyon_ha":5.56,"_hedef_alinti":"sulama şebekesi tamamlanan alan brüt","baraj_adet":1081,"golet_adet":750,"sulama_tesisi_adet":3654,"depolama_hm3":183819.9},"kanun_6172":{"_kaynak_niteligi":"BİRİNCİL — Kanun 6172, mevzuat.gov.tr tasdikli metin","_kapsam":"Türkiye · yürürlükteki metin","no":6172,"ad":"SULAMA BİRLİKLERİ KANUNU","kabul_tarihi":"8/3/2011","rg_tarih":"22/3/2011","rg_sayi":27882,"mulkiyet_gecis_sayisi":0,"_mulkiyet_notu":"SIFIR. Kanun devri tanımlıyor ama devredilen şeyler arasında mülkiyet yok.","devir_tanimi":"işletme, bakım, onarım ve yönetim sorumluluğunun","devir_tanimi_tam":"Devir: DSİ tarafından inşa edilmiş veya halen inşa edilmekte olan ya da inşa edilmesi planlanan sulama maksatlı tesislerin işletme, bakım, onarım ve yönetim sorumluluğunun, DSİ ve birlik arasında imzalanan sözleşme hükümleri uyarınca birliklere devredilmesini","_devir_tanimi_yeri":"Madde 2/e (Tanımlar)","sinir_dsi_belirler":"sınırları, kapsamı ve ismi DSİ tarafından belirlenir","_sinir_yeri":"Madde 3/1 — devirden sonra da görev alanını DSİ çiziyor","kar_gayesi":"kâr gayesi güdülemez","_kar_gayesi_yeri":"Madde 10/2","yatirim_bedeli_geri_odeme":"Devraldığı tesislerin yatırım bedellerini geri ödemek","_yatirim_bedeli_yeri":"Madde 3/4-c — devralan taraf tesisin yatırım bedelini de geri ödüyor","gelir_tahsisi":"işletme, bakım, onarım ve yönetim sorumluluğu devralınan tesis için sarf edilir","_gelir_tahsisi_yeri":"Madde 10/3 — toplanan paranın tamamı o tesise geri dönüyor","uyelik_zorunlu":"Birlik görev alanında yer alan her su kullanıcısı gerçek ve tüzel kişi sulama tesisinden faydalanabilmek için o birliğe üye olmak zorundadır","_uyelik_yeri":"Ek Madde 1/1 (Ek: 19/4/2018-7139/51 md.)","katilim_payi":"İlk üyelik kaydı sırasında bir defaya mahsus olmak üzere","_katilim_payi_yeri":"Ek Madde 1/2","ekim_planlamasi":"su yetersizliğine bağlı olarak yapılan ekim planlamasına uymak","munavebe":"sulama planlaması ve su dağıtım ve münavebe programlarına katılmak","arazi_girisi":"arazisine girilmesine izin vermek","gelir_katilim_payi":"Katılım payı","gelir_su_hizmet_bedeli":"Su kullanım hizmet bedeli","gelir_yatirim_geri_odeme":"Yatırım bedellerine ilişkin geri ödeme katkı payı","gelir_idari_para_cezasi":"idari para cezaları","_gelir_yeri":"Madde 11/1 — altı kalem; dördü doğrudan su kullanıcısından","_ek_madde_notu":"Üyelik, ekim planına uyma ve araziye giriş izni aynı fıkrada. Kurumla karşılaşma noktası burası: çiftçi suyu birlikten alıyor, birliğe üye olmak zorunda, ve suyun azaldığı yıl ne ekeceği planlamaya bağlanıyor."},"buyuk_projeler":{"_kaynak_niteligi":"KURUMUN BEYANI — DSİ 2025 Faaliyet Raporu, 2021 Haritalı İstatistik Bülteni Ek Çizelge 2-1, ve dsi.gov.tr Toprak ve Su Kaynakları sayfası","_kapsam":"Türkiye · bölgesel projeler 2025, teşkilat tarihleri Şubat 2020","gap":{"ad":"Güneydoğu Anadolu Projesi","il_sayisi":9,"nufus_milyon":9.59,"demet_sayisi":13,"demet_firat":7,"demet_dicle":6,"kurulu_guc_mw":7461,"yillik_enerji_milyar_kwh":27.3,"hedef_sulama_milyon_ha":1.058,"enerji_gerceklesme_yuzde":91,"sulama_gerceklesme_yuzde":64,"_alinti":"13 adet proje demetinden oluşmaktadır","_firat_barajlari":["Keban","Karakaya","Atatürk","Birecik","Karkamış"],"_dicle_barajlari":["Batman","Kralkızı","Dicle","Ilısu"],"_barajlar_alinti":"Fırat Nehri üzerinde Keban, Karakaya, Atatürk, Birecik, Karkamış Baraj ve HES’leri ile Dicle Nehri ve kolları üzerinde ise Batman, Kralkızı, Dicle, Ilısu Baraj ve HES’leri"},"dap":{"ad":"Doğu Anadolu Projesi","il_sayisi":15,"nufus_milyon":6.53,"hedef_sulama_ha":1377656,"isletmede_ha":602436,"isletmede_yuzde":44,"insaat_ha":263857,"planlama_ha":511363,"sulanabilir_arazi_payi_yuzde":16,"_alinti":"1.377.656 hektar alanın sulamaya açılması"},"kop":{"ad":"Konya Ovası Projesi","il_sayisi":8,"alan_km2":96627,"turkiye_yuzolcumu_payi_yuzde":12.4,"nufus_milyon":4.68,"yillik_yagis_mm":400,"turkiye_ortalamasindan_eksik_yuzde":30,"toplam_sulama_ha":1647239,"isletmede_yus_ha":717817,"isletmede_yas_ha":519601,"kalan_ha":409821,"_transfer_alinti":"Mavi Tünel vasıtasıyla su aktarılması","yaklasik_sulanan_yuzde":75,"_sulanan_alinti":"yaklaşık %75","_sulanan_notu":"Raporun KENDİ yuvarlaması. Dilimlerden hesaplanan değer %75,1; metinde raporun rakamı kullanılıyor.","_yagis_alinti":"Türkiye ortalamasından yaklaşık %30 daha eksik yağış"},"en_genis_rezervuarlar":[{"ad":"Atatürk","yuzey_km2":817},{"ad":"Keban","yuzey_km2":675},{"ad":"Ilısu","yuzey_km2":313},{"ad":"Karakaya","yuzey_km2":268},{"ad":"Hirfanlı","yuzey_km2":263}],"_rezervuar_alinti":"Atatürk Barajı 817 km2, Keban Barajı 675 km2, Ilısu Barajı 313 km2, Karakaya Barajı 268 km2, Hirfanlı Barajı 263 km2 yüzey alanına sahiptir","isletmedeki_baraj_adet":861,"_isletmedeki_baraj_uyarisi":"861 İŞLETMEDEKİ baraj sayısı (kurumun Toprak ve Su Kaynakları sayfası). Faaliyet raporundaki 1.081 ise İNŞA EDİLEN kümülatif sayı. İKİSİ AYNI ŞEY DEĞİL ve aynı cümlede yan yana yazılmaz — §2.2.1'in klasik sessiz hatası.","teskilat_takvimi":[{"birim":"Aşağı Seyhan Ovası Sulaması İşletme ve Bakım Şube Müdürlüğü","tarih":"7.06.1967","yil":1967},{"birim":"Konya Ovası Sulaması İşletme ve Bakım Şube Müdürlüğü","tarih":"3.07.1968","yil":1968},{"birim":"DSİ Aşağı Fırat Projesi 15.Bölge Müdürlüğü","tarih":"24.05.1976","yil":1976},{"birim":"Aşağı Ceyhan Ovası Sulaması İşletme ve Bakım Şube Müdürlüğü","tarih":"27.06.1977","yil":1977},{"birim":"Keban Barajı Su Ürünleri Şube Müdürlüğü","tarih":"1.09.1980","yil":1980},{"birim":"Şanlıurfa Ovaları Sulaması Şube Müdürlüğü","tarih":"10.01.1986","yil":1986},{"birim":"Şanlıurfa Tüneli ve Harran Kanalı Başmühendisliği","tarih":"10.07.1993","yil":1993},{"birim":"DSİ Çoruh Projeleri 26.Bölge Müdürlüğü","tarih":"13.06.1998","yil":1998},{"birim":"DSİ Ilısu Projesi 16.Bölge Müdürlüğü","tarih":"10.11.2008","yil":2008},{"birim":"Atatürk Barajı İşletme Başmühendisliği","tarih":"2.02.2012","yil":2012},{"birim":"Silvan Proje Müdürlüğü","tarih":"24.09.2014","yil":2014}],"_takvim_notu":"Bunlar BİRİM KURULUŞ tarihleridir, baraj açılış tarihleri DEĞİL. Metinde de öyle yazılır. Kurum bir projeye kendi idaresini kurduğunda o projenin artık sürekli bir iş olduğunu kabul etmiş oluyor; ölçtüğümüz şey bu.","_ilk_bolgeler_alinti":"Seyhan ve Hirfanlı’da da 2 adet olmak üzere toplam 12 adet Bölge Müdürlüğü","ilk_bolge_sayisi":12,"yururluge_giris":"28.02.1954"},"turetilmis":{"_kaynak_niteligi":"TÜRETİLMİŞ — yukarıdaki blokların hesabı","_kapsam":"Türetilmiş; her satırın kapsamı kendi kaynağınınkidir","devir_suresi_yil":53,"_devir_suresi_kapsam":"YAS tesisleri · ilk kat'i devir → son kayıt","birlik_alan_payi_yuzde":83.1,"birlik_adet_payi_yuzde":19,"kooperatif_alan_payi_yuzde":6.3,"kooperatif_adet_payi_yuzde":44,"devredilen_milyon_ha":3.083,"hedefe_oran_yuzde":55.5,"_hedefe_oran_uyarisi":"Payda 2028 HEDEFİ, gerçekleşen alan değil. 'Devredilen alan açılanın şu kadarı' DENMEZ — gerçekleşen kümülatif alan hiçbir kaynakta bulunamadı (README tur 3/3).","kronoloji":{"ilk_orgutlenme":1914,"sular_fen_heyeti":1925,"sular_umum_mudurlugu":1929,"dsi_kurulus":1953,"teskilatlanma":1954,"ilk_devir":1967,"sulama_birlikleri_kanunu":2011,"maddelerin_mulgasi":2018}},"metin_rakamlari":{"_kaynak_niteligi":"TÜRETİLMİŞ — metnin kullandığı dönüşümler","_kapsam":"Türetilmiş; her satırın kapsamı kendi kaynağınınkidir","birlik_ortalama_ha":14159,"kooperatif_ortalama_ha":468,"koy_ortalama_ha":180,"birlik_kooperatif_kat":30.3,"seri_ilk_yil":1967,"seri_ilk_alan_ha":50,"seri_son_yil":2020,"seri_son_alan_ha":464316,"seri_yarisini_gectigi_yil":1994,"seri_ilk_yari_yil":27,"seri_ikinci_yari_yil":26,"son_bes_yil_artis_ha":9830,"en_hizli_bes_yil_artis_ha":90078,"son_bes_yil_yavaslama_kat":9.2,"en_hizli_bes_yil_bitis":1987,"depolama_milyar_m3":183.8,"baraj_golet_toplam":1831,"hedefin_sulanabilire_orani_yuzde":65.4,"depolama_kup_kenari_km":5.7,"devredilen_km2":30832,"rapor_yili":2025,"firat_idaresinden_rapora_yil":49,"firat_idaresinden_tunele_yil":17,"seyhan_idaresinden_rapora_yil":58,"takvim_ilk_yil":1967,"takvim_son_yil":2014,"takvim_araligi_yil":47,"gap_kalan_sulama_yuzde":36,"dap_kalan_ha":775220,"kop_sulanan_yuzde":75.1,"ataturk_hirfanli_kat":3.1,"uc_proje_hedef_toplam_ha":3024895,"mulga_madde_toplam":31}}$dsr$::jsonb,
  $dsr${"devir_asimetrisi":{"tur":"ikili_cubuk","baslik":{"tr":"Tesislerin beşte biri, alanın beşte dördü","en":"A fifth of the facilities, four fifths of the area"},"not":{"tr":"Sulama birlikleri devredilen tesislerin yalnızca beşte birini aldı ama alanın beşte dördünden fazlasını. Kooperatiflerde tam tersi: tesis sayısının en büyük payı, alanın en küçüklerinden biri. Her satır kendi içinde oranlanıyor; satırlar birbiriyle değil.","en":"Irrigation associations took only a fifth of the transferred facilities but more than four fifths of the area. For cooperatives it is the reverse: the largest share of facilities, one of the smallest of area. Each row is scaled within itself, not against the others."},"kaynak":"DSİ · 2025 Faaliyet Raporu, Tablo 14 (31.12.2025)","seriler":[{"ad":{"tr":"Tesis sayısı payı","en":"Share of facilities"},"rol":"ikincil"},{"ad":{"tr":"Alan payı","en":"Share of area"},"rol":"vurgu"}],"sonek":{"tr":"%","en":"%"},"ondalik":1,"satirlar":[{"etiket":{"tr":"Sulama Birliği","en":"Irrigation association"},"degerler":[19,83.1]},{"etiket":{"tr":"Kooperatif","en":"Cooperative"},"degerler":[44,6.3]},{"etiket":{"tr":"Belediye","en":"Municipality"},"degerler":[17,7.3]},{"etiket":{"tr":"Köy Tüzel Kişiliği","en":"Village legal entity"},"degerler":[18,1]},{"etiket":{"tr":"Diğer","en":"Other"},"degerler":[2,2.3]}]},"devredilen_alan":{"tur":"siralama","baslik":{"tr":"Devredilen sulama alanı, devralana göre","en":"Transferred irrigation area, by recipient"},"birim":{"tr":"bin hektar · 31.12.2025","en":"thousand hectares · 31.12.2025"},"bolen":1000,"ondalik":1,"not":{"tr":"Toplam 936 tesis ve 3.083.200 hektar. Tablonun iki toplamı da satırlardan yeniden hesaplandı ve tutuyor.","en":"936 facilities and 3,083,200 hectares in total. Both totals in the table were recomputed from the rows and they check out."},"kaynak":"DSİ · 2025 Faaliyet Raporu, Tablo 14","satirlar":[{"etiket":{"tr":"Sulama Birliği","en":"Irrigation association"},"deger":2562855,"rol":"vurgu"},{"etiket":{"tr":"Kooperatif","en":"Cooperative"},"deger":193740,"rol":"sessiz"},{"etiket":{"tr":"Belediye","en":"Municipality"},"deger":226146,"rol":"sessiz"},{"etiket":{"tr":"Köy Tüzel Kişiliği","en":"Village legal entity"},"deger":29472,"rol":"sessiz"},{"etiket":{"tr":"Diğer","en":"Other"},"deger":70987,"rol":"sessiz"}]},"devir_egrisi":{"tur":"cizgi","baslik":{"tr":"Devir elli üç yıl sürdü","en":"The transfer took fifty-three years"},"birim":{"tr":"bin hektar · kümülatif · YALNIZCA yeraltısuyu tesisleri","en":"thousand hectares · cumulative · GROUNDWATER schemes only"},"bolen":1000,"ondalik":0,"not":{"tr":"KAPSAM: bu seri yalnızca yeraltısuyu (YAS) tesislerinin kat'i devrini gösteriyor — 2020'de 464.316 hektar. Öteki grafiklerdeki 3.083.200 hektar BÜTÜN sulama tesislerini kapsıyor ve 2025 tarihli; ikisi toplanmaz, biri ötekinin yerine kullanılmaz. 1999 satırının ünite değeri kaynakta hatalı ve kullanılmadı.","en":"SCOPE: this series covers the final transfer of groundwater schemes only — 464,316 hectares in 2020. The 3,083,200 hectares in the other charts covers all irrigation facilities and is dated 2025; the two are not additive and neither substitutes for the other. The 1999 row's unit count is wrong in the source and was not used."},"kaynak":"DSİ · 2021 Haritalı İstatistik Bülteni, s. 62","seriler":[{"ad":{"tr":"Devredilen alan (YAS)","en":"Transferred area (groundwater)"},"rol":"vurgu","noktalar":{"liste":[{"yil":1967,"unite":1,"alan_ha":50},{"yil":1968,"unite":1,"alan_ha":50},{"yil":1969,"unite":1,"alan_ha":50},{"yil":1970,"unite":3,"alan_ha":380},{"yil":1971,"unite":17,"alan_ha":5140},{"yil":1972,"unite":18,"alan_ha":5230},{"yil":1973,"unite":20,"alan_ha":10640},{"yil":1974,"unite":58,"alan_ha":29940},{"yil":1975,"unite":82,"alan_ha":38880},{"yil":1976,"unite":115,"alan_ha":55545},{"yil":1977,"unite":137,"alan_ha":66475},{"yil":1978,"unite":164,"alan_ha":79664},{"yil":1979,"unite":192,"alan_ha":88229},{"yil":1980,"unite":208,"alan_ha":93189},{"yil":1981,"unite":249,"alan_ha":102419},{"yil":1982,"unite":252,"alan_ha":102872},{"yil":1983,"unite":321,"alan_ha":121312},{"yil":1984,"unite":378,"alan_ha":133465},{"yil":1985,"unite":443,"alan_ha":153905},{"yil":1986,"unite":541,"alan_ha":179120},{"yil":1987,"unite":587,"alan_ha":192950},{"yil":1988,"unite":637,"alan_ha":200825},{"yil":1989,"unite":674,"alan_ha":206765},{"yil":1990,"unite":697,"alan_ha":210181},{"yil":1991,"unite":738,"alan_ha":217896},{"yil":1992,"unite":760,"alan_ha":222651},{"yil":1993,"unite":790,"alan_ha":230101},{"yil":1994,"unite":910,"alan_ha":253911},{"yil":1995,"unite":985,"alan_ha":268003},{"yil":1996,"unite":1029,"alan_ha":272878},{"yil":1997,"unite":1084,"alan_ha":281718},{"yil":1998,"unite":1187,"alan_ha":299728},{"yil":1999,"unite":null,"alan_ha":310548},{"yil":2000,"unite":1295,"alan_ha":319243},{"yil":2001,"unite":1368,"alan_ha":329235},{"yil":2002,"unite":1441,"alan_ha":340088},{"yil":2003,"unite":1511,"alan_ha":351361},{"yil":2004,"unite":1600,"alan_ha":361995},{"yil":2005,"unite":1680,"alan_ha":370937},{"yil":2006,"unite":1684,"alan_ha":371457},{"yil":2007,"unite":1728,"alan_ha":378111},{"yil":2008,"unite":1858,"alan_ha":398420},{"yil":2009,"unite":1986,"alan_ha":418247},{"yil":2010,"unite":2060,"alan_ha":427307},{"yil":2011,"unite":2112,"alan_ha":433339},{"yil":2012,"unite":2198,"alan_ha":443126},{"yil":2013,"unite":2228,"alan_ha":445934},{"yil":2014,"unite":2262,"alan_ha":449379},{"yil":2015,"unite":2302,"alan_ha":454486},{"yil":2016,"unite":2309,"alan_ha":455917},{"yil":2017,"unite":2357,"alan_ha":461794},{"yil":2018,"unite":2367,"alan_ha":462842},{"yil":2019,"unite":2371,"alan_ha":463246},{"yil":2020,"unite":2371,"alan_ha":464316}],"x":"yil","y":"alan_ha"}}]},"silsile":{"tur":"zaman_cizelgesi","baslik":{"tr":"Kuraklıktan bir idare doğuyor","en":"A drought produces an administration"},"not":{"tr":"Kuruluş tarihi iki bağımsız kaynakta aynı: kanun metni 18/12/1953 kabul diyor, kurumun kendi sayfası 18 Aralık 1953.","en":"The founding date agrees across two independent sources: the law says adopted 18/12/1953, the institution's own page says 18 December 1953."},"kaynak":"DSİ · Hakkımızda · ve Kanun 6200","olaylar":[{"yil":1914,"baslik":{"tr":"Nafıa Nezareti yeniden yapılanıyor","en":"The Ministry of Public Works is reorganised"},"aciklama":{"tr":"Su işlerinin örgütlü ve sürekli biçimde ele alınmasının başı.","en":"The start of water works being handled in an organised, continuous way."}},{"yil":1925,"baslik":{"tr":"Sular Fen Heyeti kuruluyor","en":"The Water Engineering Board is founded"},"aciklama":{"tr":"Umur-u Nafıa Müdüriyet-i Umumiyesi'ne bağlı.","en":"Attached to the General Directorate of Public Works."}},{"yil":1929,"baslik":{"tr":"Şiddetli kuraklık ve kıtlık · Sular Umum Müdürlüğü","en":"Severe drought and famine · General Directorate of Waters"},"aciklama":{"tr":"Kurum bir kıtlığın ardından kuruluyor; dosyanın açılışı burada.","en":"The institution is founded in the wake of a famine; this is where the dossier opens."}},{"yil":1953,"baslik":{"tr":"Devlet Su İşleri Genel Müdürlüğü · Kanun 6200","en":"General Directorate of State Hydraulic Works · Law 6200"},"aciklama":{"tr":"18 Aralık 1953'te kabul edildi, 1954'te teşkilatlandı.","en":"Adopted 18 December 1953, organised in 1954."}}]},"olcek":{"tur":"kunye","baslik":{"tr":"Kurumun kurduğu altyapı","en":"The infrastructure the institution built"},"not":{"tr":"Ülkenin ekonomik olarak sulanabilir arazisi 8,5 milyon hektar; kurumun 2028 hedefi brüt 5,56 milyon hektarlık şebeke. Baraj, gölet ve depolama rakamları 2025 yıl sonu kümülatifi.","en":"The country's economically irrigable land is 8.5 million hectares; the institution's 2028 target is a gross 5.56 million hectares of network. Dam, pond and storage figures are cumulative to end-2025."},"kaynak":"DSİ · 2025 Faaliyet Raporu","kalemler":[{"deger":1081,"ondalik":0,"etiket":{"tr":"baraj","en":"dams"},"alt":{"tr":"kümülatif, 2025","en":"cumulative, 2025"}},{"deger":750,"ondalik":0,"etiket":{"tr":"gölet","en":"ponds"},"alt":{"tr":"kümülatif, 2025","en":"cumulative, 2025"}},{"deger":3654,"ondalik":0,"etiket":{"tr":"sulama tesisi","en":"irrigation facilities"},"alt":{"tr":"kümülatif, 2025","en":"cumulative, 2025"}},{"deger":8.5,"ondalik":1,"sonek":{"tr":" milyon ha","en":"m ha"},"etiket":{"tr":"ekonomik olarak sulanabilir arazi","en":"economically irrigable land"},"alt":{"tr":"ülke geneli","en":"nationwide"}}]},"proje_takvimi":{"tur":"zaman_cizelgesi","baslik":{"tr":"Bir projeye idare kurmak, onu sürekli bir iş ilan etmektir","en":"Giving a project its own administration declares it permanent work"},"not":{"tr":"Bu tarihler BARAJ AÇILIŞ tarihleri değil; kurumun o projeye kendi taşra birimini kurduğu tarihlerdir. Kaynak kurumun kendi teşkilat çizelgesi (Ek Çizelge 2-1, Şubat 2020). Barajların işletmeye açılış yılları kurumun yayımlanmış belgelerinde tablo hâlinde bulunmuyor.","en":"These are not dam commissioning dates; they are the dates on which the institution set up its own field unit for that project. The source is the institution's own organisation table (Annex Table 2-1, February 2020). Dam commissioning years are not published as a table in the institution's documents."},"kaynak":"DSİ · 2021 Haritalı İstatistik Bülteni, Ek Çizelge 2-1","olaylar":[{"yil":1967,"baslik":{"tr":"Aşağı Seyhan Ovası sulaması kendi idaresini alıyor","en":"The Lower Seyhan Plain scheme gets its own administration"},"aciklama":{"tr":"Kurumun ilk iki bölge müdürlüğünden biri 1954'te zaten Seyhan'daydı.","en":"One of the institution's first two regional directorates was already at Seyhan in 1954."}},{"yil":1968,"baslik":{"tr":"Konya Ovası sulaması işletmeye ve bakıma geçiyor","en":"The Konya Plain scheme moves to operation and maintenance"},"aciklama":{"tr":"Çumra'da kurulan şube, kapalı havzada kalıcı bir idare demek.","en":"The branch set up at Çumra means a permanent administration in a closed basin."}},{"yil":1976,"baslik":{"tr":"Aşağı Fırat Projesi kendi bölge müdürlüğünü alıyor","en":"The Lower Euphrates Project gets its own regional directorate"},"aciklama":{"tr":"Şanlıurfa'da kurulan 15. Bölge, bugün GAP diye bilinen işin idari başlangıcı.","en":"The 15th Region, set up in Şanlıurfa, is the administrative start of what is known today as GAP."}},{"yil":1977,"baslik":{"tr":"Aşağı Ceyhan Ovası sulaması idareye kavuşuyor","en":"The Lower Ceyhan Plain scheme gains an administration"},"aciklama":{"tr":"Çukurova'nın ikinci büyük ovası da sürekli işletmeye giriyor.","en":"Çukurova's second great plain also enters continuous operation."}},{"yil":1980,"baslik":{"tr":"Keban'da su ürünleri şubesi kuruluyor","en":"A fisheries branch is established at Keban"},"aciklama":{"tr":"Baraj gölü artık yalnızca su değil, yönetilen bir kaynak.","en":"The reservoir is no longer just water but a managed resource."}},{"yil":1986,"baslik":{"tr":"Şanlıurfa Ovaları sulaması şube müdürlüğü kuruluyor","en":"The Şanlıurfa Plains irrigation branch directorate is established"},"aciklama":{"tr":"Aşağı Fırat idaresinden on yıl sonra, sulama tarafı ayrı bir birim oluyor.","en":"Ten years after the Lower Euphrates administration, the irrigation side becomes a separate unit."}},{"yil":1993,"baslik":{"tr":"Şanlıurfa Tüneli ve Harran Kanalı başmühendisliği kuruluyor","en":"The Şanlıurfa Tunnel and Harran Canal chief engineering office is established"},"aciklama":{"tr":"Suyun Harran Ovası'na indiği hat kendi idaresini alıyor.","en":"The line by which water descends to the Harran Plain gets its own administration."}},{"yil":1998,"baslik":{"tr":"Çoruh Projeleri bölge müdürlüğü kuruluyor","en":"The Çoruh Projects regional directorate is established"},"aciklama":{"tr":"Artvin'de kurulan 26. Bölge, dik vadili bir havzayı idareye bağlıyor.","en":"The 26th Region in Artvin brings a steep-valleyed basin under administration."}},{"yil":2008,"baslik":{"tr":"Ilısu Projesi kendi bölge müdürlüğünü alıyor","en":"The Ilısu Project gets its own regional directorate"},"aciklama":{"tr":"Mardin'de kurulan 16. Bölge, Dicle tarafının son büyük halkası.","en":"The 16th Region in Mardin is the last great link on the Tigris side."}},{"yil":2012,"baslik":{"tr":"Atatürk Barajı işletme başmühendisliği kuruluyor","en":"The Atatürk Dam operations chief engineering office is established"},"aciklama":{"tr":"Ülkenin en geniş rezervuarı için ayrı bir işletme idaresi.","en":"A separate operating administration for the country's widest reservoir."}},{"yil":2014,"baslik":{"tr":"Silvan Proje Müdürlüğü kuruluyor","en":"The Silvan Project Directorate is established"},"aciklama":{"tr":"Çizelgedeki en yeni büyük proje birimi.","en":"The newest large project unit in the table."}}]},"buyuk_rezervuarlar":{"tur":"siralama","baslik":{"tr":"Beş rezervuar, bir ülkenin su yüzeyi","en":"Five reservoirs, a country's water surface"},"birim":{"tr":"km² · göl yüzey alanı","en":"km² · reservoir surface area"},"ondalik":0,"not":{"tr":"Bunlar YÜZEY ALANI, depolama hacmi değil; iki ölçü farklı sıralama verir. Türkiye'de işletmede 861 baraj var — faaliyet raporundaki 1.081 ise inşa edilen kümülatif sayıdır ve aynı şey değildir.","en":"These are surface areas, not storage volumes; the two measures give different rankings. There are 861 dams in operation in Türkiye — the 1,081 in the annual report is the cumulative number built, which is not the same thing."},"kaynak":"DSİ · Toprak ve Su Kaynakları sayfası","satirlar":[{"etiket":{"tr":"Atatürk Barajı","en":"Atatürk Dam"},"deger":817,"rol":"vurgu"},{"etiket":{"tr":"Keban Barajı","en":"Keban Dam"},"deger":675,"rol":"ikincil"},{"etiket":{"tr":"Ilısu Barajı","en":"Ilısu Dam"},"deger":313,"rol":"ikincil"},{"etiket":{"tr":"Karakaya Barajı","en":"Karakaya Dam"},"deger":268,"rol":"ikincil"},{"etiket":{"tr":"Hirfanlı Barajı","en":"Hirfanlı Dam"},"deger":263,"rol":"ikincil"}]},"bolgesel_projeler":{"tur":"kartlar","baslik":{"tr":"Üç bölgesel proje, üçü de yarım","en":"Three regional projects, all three unfinished"},"not":{"tr":"Üç projenin de sulama tarafı hâlâ hedefin altında. Oranlar ve alanlar kurumun 2025 faaliyet raporundan; DAP'ın kalan alanı dilimlerden yeniden hesaplandı ve raporun kendi yazdığı rakamla birebir tuttu.","en":"The irrigation side of all three projects is still below target. The shares and areas come from the institution's 2025 annual report; DAP's remaining area was recomputed from its slices and matched the report's own figure exactly."},"kaynak":"DSİ · 2025 Faaliyet Raporu","kartlar":[{"ust":{"tr":"Güneydoğu Anadolu · 9 il","en":"Southeastern Anatolia · 9 provinces"},"baslik":{"tr":"GAP","en":"GAP"},"govde":{"tr":"Hedef 1,058 milyon hektar sulama. Enerjide %91, sulamada %64 gerçekleşme. 13 proje demeti, 7.461 MW kurulu güç.","en":"Target: 1.058 million hectares of irrigation. 91% realised in energy, 64% in irrigation. 13 project bundles, 7,461 MW installed capacity."}},{"ust":{"tr":"Doğu Anadolu · 15 il","en":"Eastern Anatolia · 15 provinces"},"baslik":{"tr":"DAP","en":"DAP"},"govde":{"tr":"Hedef 1.377.656 hektar. İşletmede 602.436 hektar (%44); 263.857 hektar inşaatta, 511.363 hektar planlamada.","en":"Target: 1,377,656 hectares. In operation: 602,436 hectares (44%); 263,857 under construction, 511,363 in planning."}},{"ust":{"tr":"Konya Ovası · 8 il","en":"Konya Plain · 8 provinces"},"baslik":{"tr":"KOP","en":"KOP"},"govde":{"tr":"1.647.239 hektarlık alanın %75'i sulanıyor — 717.817 hektarı yüzey suyuyla, 519.601 hektarı yeraltısuyuyla. Yıllık yağış 400 mm.","en":"75% of a 1,647,239-hectare area is irrigated — 717,817 hectares from surface water, 519,601 from groundwater. Annual rainfall: 400 mm."}}]}}$dsr$::jsonb,
  array['DSİ', 'Devlet Su İşleri']::text[],
  null,
  null,
  null,
  'draft',
  now(),
  (now() + interval '14 days'),
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
 where dossier_id = (select id from public.country_dossiers where slug = 'dsi');

insert into public.dossier_sections
  (dossier_id, ord, title_tr, title_en, body_tr, body_en, chart_keys, tur, gorsel)
select d.id, v.ord, v.title_tr, v.title_en, v.body_tr, v.body_en, v.chart_keys, v.tur, v.gorsel
from public.country_dossiers d
cross join (values
  (1::integer, $dsr$Suyu getiren kurum$dsr$, $dsr$The institution that brings the water$dsr$, $dsr$Türkiye'de 1.081 baraj ve 750 gölet var. Bu 1.831 yapının arkasındaki su
depolama kapasitesi 183,8 milyar metreküp. Hepsini tek bir kurum inşa etti:
Devlet Su İşleri Genel Müdürlüğü.

Aynı kurumun inşa ettiği sulama tesislerinden 936'sı bugün DSİ'de değil.
Sulama birliklerinde, kooperatiflerde, belediyelerde ve köy tüzel
kişiliklerinde. Devredilen alan 3.083.200 hektar, yani 30.832 kilometrekare.

Devir bir seferde olmadı ve bir tarihe sığmıyor. İlk kati devir sözleşmesi
1967'de imzalandı, elli hektarlık tek bir tesis için. Ardından elli üç yıl
süren, hız değiştiren, bazı on yıllarda kurumun ana işlerinden biri hâline
gelen bir program geldi.

Devredilen şeyin ne olduğu bu dosyanın asıl konusu, çünkü kelimenin günlük
anlamıyla hukuki anlamı aynı değil. Günlük dilde devir, bir şeyin elden
çıkması demek. 2011 tarihli Sulama Birlikleri Kanunu ise devri tanımlarken
dört şey sayıyor: işletme, bakım, onarım ve yönetim sorumluluğu. Beşinci bir
şey saymıyor, ve saymadığı şey tam olarak sahipliktir.

Bu yüzden ortaya alışılmadık bir yapı çıkıyor. Barajı, ana kanalı ve dağıtım
şebekesini devlet kurdu. Suyu tarlaya ulaştıran son halkada ise çiftçinin
karşısında çoğu zaman devlet değil, kendisinin de üyesi olduğu bir birlik
duruyor. Bu birlik tesisi devralmış ama satın almamış; işletiyor ama
sahiplenmiyor; parayı topluyor ama kâr edemiyor.

Bu dosyanın dayandığı belgeler üç cinsten ve karıştırılmıyor. Kurumu kuran ve
bugün yetkilendiren metinler birincil: 6200 sayılı Kanun, 6172 sayılı Kanun
ve 4 numaralı Cumhurbaşkanlığı Kararnamesi. Tesis ve alan rakamları kurumun
kendi faaliyet raporundan ve istatistik bülteninden, yani kurumun kendi
beyanından geliyor.$dsr$, $dsr$Türkiye has 1,081 dams and 750 ponds. Behind those 1,831 structures sits a
water storage capacity of 183.8 billion cubic metres. A single institution
built all of them: the General Directorate of State Hydraulic Works, known
in Turkish by its initials, DSİ.

936 of the irrigation schemes that same institution built are no longer with
DSİ. They are with irrigation associations, cooperatives, municipalities and
village legal entities. The transferred area is 3,083,200 hectares, or
30,832 square kilometres.

The transfer did not happen at once and does not fit on a single date. The
first definitive transfer contract was signed in 1967, for one scheme
covering fifty hectares. What followed was a programme that ran for
fifty-three years, changed pace, and in some decades became one of the
institution's principal activities.

What exactly was transferred is the real subject of this file, because the
everyday meaning of the word and its legal meaning are not the same. In
ordinary speech, transfer means a thing passing out of one's hands. When the
2011 Irrigation Associations Law defines transfer, it lists four things: the
responsibility for operation, maintenance, repair and management. It does
not list a fifth, and the thing it does not list is ownership.

An unusual arrangement follows from this. The state built the dam, the main
canal and the distribution network. But at the last link, where the water
reaches the field, what faces the farmer is usually not the state but an
association of which the farmer is a member. That association has taken the
scheme over without buying it; it operates without owning; it collects money
without being allowed to profit.

The documents behind this file come in three classes. The texts that
established the institution and that authorise it today are primary: Law
6200, Law 6172 and Presidential Decree No. 4. The figures for schemes and
areas come from the institution's own annual report and statistical
bulletin.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/dsi/dsi_harran_ana_kanal.jpg","atif":"Volker Höhfeld — CC BY-SA 4.0","kaynak":null,"alt_tr":"Harran Ovası'nda ana sulama kanalı, 8 Nisan 2004.","alt_en":"The main irrigation canal on the Harran Plain, 8 April 2004."}$dsr$::jsonb),
  (2, $dsr$Kıtlıktan doğan idare$dsr$, $dsr$An administration born of famine$dsr$, $dsr$Devlet Su İşleri 1953'te kuruldu ama hikâyesi otuz dokuz yıl daha eskiye
gidiyor. Kurumun kendi kronolojisi dört durak sayıyor ve dördü arasında
tırmanan bir şey var: yetki.

1914'te Nafıa Nezareti bünyesinde su işleri ilk kez örgütlü biçimde ele
alınıyor. Su, kendi başına bir idare değil, bayındırlık işlerinin bir konusu.

1925'te Umur-u Nafıa Müdüriyet-i Umumiyesi'ne bağlı bir Sular Fen Heyeti
kuruluyor. Adın her kelimesi bir sınır: *fen*, yani teknik; *heyet*, yani
karar değil görüş üreten bir kurul. Su artık kendi uzmanları olan bir konu
ama hâlâ kendi idaresi olan bir iş değil.

Dördüncü durağın tarihi değil, sebebi önemli. 1929'da Sular Umum Müdürlüğü
kuruluyor ve kurumun kendi kaydı sebebi tek bir ifadeyle veriyor: şiddetli
kuraklık ve kıtlık.

Su idaresinin kıtlıktan doğması tesadüf değil. Kurak bir yılda su sorunu
teknik bir mesele olmaktan çıkıp bir ekmek meselesine dönüşüyor ve o noktada
devletin karşılığı bir heyet değil bir müdürlük oluyor. Aradaki fark
yetkidir: heyet görüş verir, müdürlük bütçe harcar, personel çalıştırır,
inşaat yapar.

Yirmi dört yıl sonra, 18 Aralık 1953'te Devlet Su İşleri Genel Müdürlüğü
kuruluyor. Ad bir kez daha büyüyor — "sular"dan "devlet su işleri"ne, yani
bir konudan bir devlet işine. Kurum teşkilatlanmasını ertesi yıl, 1954'te
tamamlıyor; aradaki bir yıl, kâğıt üzerindeki kuruluşla fiilen çalışan
teşkilatın aynı şey olmadığını gösteriyor.

Bu silsilenin tamamı kurumun kendi anlatımı. Yalnızca son halkası bağımsız
bir belgeyle örtüşüyor: 6200 sayılı Kanun da kabul tarihini 18 Aralık 1953
olarak veriyor.$dsr$, $dsr$State Hydraulic Works was founded in 1953, but its story reaches thirty-nine
years further back. The institution's own chronology marks four stages, and
something climbs across them: authority.

In 1914, water affairs were taken up in an organised form for the first time
within the Ministry of Public Works. Water was not an administration in its
own right but a subject within public works.

In 1925 a Water Technical Board was established under the Directorate General
of Public Works. Every word of that name is a limit: *technical*, and
*board* — a body that produces opinions rather than decisions. Water now had
its own experts but still not its own administration.

What matters about the fourth stage is not its date but its cause. In 1929
the General Directorate of Waters was founded, and the institution's own
record gives the reason in a single phrase: severe drought and famine.

That a water administration should be born of famine is no accident. In a
dry year the water problem stops being a technical matter and becomes a
question of bread, and at that point the state's answer is not a board but a
directorate. The difference is authority: a board gives an opinion, a
directorate spends a budget, employs staff and builds.

Twenty-four years later, on 18 December 1953, the General Directorate of
State Hydraulic Works was founded. The name grew once more — from "waters"
to "state hydraulic works", that is, from a subject to a business of the
state. The institution completed its organisation the following year, in
1954; that gap of a year shows that an establishment on paper and an
organisation actually at work are not the same thing.

The whole of this sequence is the institution's own account. Only its last
link is corroborated by an independent document: Law 6200 also gives 18
December 1953 as its date of adoption.$dsr$, array['silsile']::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/dsi/dsi_hirfanli_baraji.jpg","atif":"Hajo-Muc — CC BY-SA 3.0","kaynak":null,"alt_tr":"Hirfanlı'da baraj gölü ve santralin şalt sahası.","alt_en":"The reservoir and the power plant's switchyard at Hirfanlı."}$dsr$::jsonb),
  (3, $dsr$6200: bir kanunun kurduğu teşkilat$dsr$, $dsr$Law 6200: the organisation a law established$dsr$, $dsr$Kurumu kuran metin 6200 sayılı *Devlet Su İşleri Genel Müdürlüğünce Yürütülen
Hizmetler Hakkında Kanun*. 18 Aralık 1953'te kabul edildi, 25 Aralık 1953
tarihli ve 8592 sayılı Resmî Gazete'de yayımlandı.

Kanunun bugünkü adı kuruluştaki adı değil. Metin uzun yıllar *Devlet Su
İşleri Umum Müdürlüğü Teşkilat ve Vazifeleri Hakkında Kanun* adını taşıdı;
2011'de bugünkü adını aldı. Değişiklik yalnızca sadeleştirme değil, bir
kapsam değişikliği: kanun artık teşkilatı değil, o teşkilatın yürüttüğü
hizmetleri düzenleyen bir metin olarak adlandırılıyor.

Kanunun bugünkü metninde 31 mülga madde var ve aralarında kuruluş, vazife
ve teşkilat maddeleri de bulunuyor. Bunun sebebi DSİ'ye özgü değil: 2018'de
cumhurbaşkanlığı hükümet sistemine geçilirken kurumların kuruluş ve teşkilat
hükümleri topluca cumhurbaşkanlığı kararnamelerine taşındı. DSİ'ninki 4
numaralı Kararname'nin Onuncu Bölümü'nde, 119 ilâ 121. maddelerde. Kanun
yürürlükte kalmaya devam ediyor ve kurumun yaptığı işlerin hukuki
ayrıntılarını düzenliyor.

Asıl mesele kurumun hangi metinden doğduğu değil, ne inşa ettiği — çünkü
devredilen şey o.$dsr$, $dsr$The founding text is Law 6200, the *Law on Services Carried Out by the
General Directorate of State Hydraulic Works*. It was adopted on 18 December
1953 and published in the Official Gazette of 25 December 1953, issue 8592.

The law's present title is not its founding title. For many years the text
was called the *Law on the Organisation and Duties of the General
Directorate of State Hydraulic Works*; it took its current name in 2011. The
change was not merely a simplification but a change of scope: the law is now
named as a text regulating not the organisation but the services that
organisation carries out.

The law's present text contains 31 repealed articles, among them those on
establishment, duties and organisation. The reason is not particular to DSİ:
when Türkiye moved to the presidential system of government in 2018, the
establishing and organisational provisions of public bodies were transferred
en bloc to presidential decrees. DSİ's sit in the Tenth Chapter of Decree
No. 4, articles 119 to 121. The law remains in force and goes on regulating
the legal detail of the institution's work.

What matters is not which text the institution was born from but what it
built — because that is what was transferred.$dsr$, '{}'::text[], 'belge', $dsr${"url":"https://tarimportali.net/dosya/dsi/dsi_harran_1989_sulamasiz.jpg","atif":"Volker Höhfeld — CC BY-SA 4.0","kaynak":null,"alt_tr":"Harran Ovası, 25 Eylül 1989 — GAP sulaması gelmeden önce. Arkadaki tarlalar anız ve nadas.","alt_en":"The Harran Plain, 25 September 1989 — before GAP irrigation arrived. The fields behind are stubble and fallow."}$dsr$::jsonb),
  (4, $dsr$Ne inşa edildi$dsr$, $dsr$What was built$dsr$, $dsr$Türkiye'nin sulanabilir tarım arazisi 8,5 milyon hektar. Kurumun kendi
raporundaki kalem adı "sulanabilir tarım arazisi miktarı". Bu, toprağın ve
suyun fiziksel olarak izin verdiği üst sınır; ekilen alan değil, sulanan alan
da değil, sulanabilecek alan.

DSİ'nin 2028 için ilan ettiği hedef bu sınırın tamamı değil. Raporun kendi
ifadesiyle "sulama şebekesi tamamlanan alan brüt" olarak 5,56 milyon hektar;
yani sulanabilir arazinin %65,4'ü. Üçte ikiye yakın bir oran ve kurumun kendi
koyduğu hedef.

Bu hedefin arkasındaki fiziki yapı tek tek sayılabiliyor. 1.081 baraj. 750
gölet. Kümülatif 3.654 sulama tesisi. Ve 183,8 milyar metreküp depolama
kapasitesi.

Son rakam soyut kaldığı için bir karşılığı olsun: 183,8 milyar metreküp,
kenarı 5,7 kilometre olan bir küp demek.

Barajın kendisi bir su yapısı değil, bir zaman yapısıdır. Yağışın düştüğü ay
ile suyun gerektiği ay aynı değil; Türkiye'de yağış kışın, sulama yazın. Depo
bu iki mevsimi birbirine bağlayan şey — kışın düşen suyu temmuzda tarlaya
verebilmenin tek yolu onu bir yerde tutmak. Kıtlıktan doğan bir idarenin ilk
işinin depolama olması bu yüzden şaşırtıcı değil.

Ama depolama tek başına bir şey yapmıyor. Barajdan tarlaya giden yolun
tamamlanması gerekiyor: ana kanal, yedek kanal, tersiyer, tarla içi tesis.
Sayılan 3.654 sulama tesisinin ve hedeflenen 5,56 milyon hektarın anlattığı
şey bu zincirin kendisi.

Ve zincir uzadıkça işletmesi ağırlaşıyor. Bir barajı yapmak bir projedir,
başı ve sonu vardır. Bir sulama şebekesini işletmek ise her yıl yeniden
başlayan bir iştir: kanalların temizlenmesi, kapakların açılıp kapanması, her
sezonun su dağıtım programı. İnşaatın bittiği yerde bitmeyen bir yük kalıyor,
ve devir meselesi tam olarak o yükün kimde duracağı meselesi.

Bu yapıları devlet kurdu. Ama hiçbiri bir yılda kurulmadı; en büyükleri
nesiller sürdü ve bir kısmı hâlâ sürüyor.$dsr$, $dsr$Türkiye's irrigable agricultural land is 8.5 million hectares. The line item
in the institution's own report reads "sulanabilir tarım arazisi miktarı" —
the quantity of irrigable agricultural land. This is the upper limit that
soil and water physically allow; not the cultivated area, not the irrigated
area, but the area that could be irrigated.

The target DSİ has declared for 2028 is not the whole of that limit. In the
report's own wording it is 5.56 million hectares of "sulama şebekesi
tamamlanan alan brüt" — gross area with a completed irrigation network —
that is, 65.4% of the irrigable land. Close to two-thirds, and a target the
institution set itself.

The physical fabric behind that target can be counted item by item. 1,081
dams. 750 ponds. A cumulative 3,654 irrigation schemes. And 183.8 billion
cubic metres of storage capacity.

Because the last figure stays abstract, here is a handle for it: 183.8
billion cubic metres is a cube 5.7 kilometres on each side.

A dam is not really a water structure but a time structure. The month the
rain falls and the month the water is needed are not the same; in Türkiye
the rain comes in winter and the irrigation in summer. Storage is the thing
that ties those two seasons together. That the first job of an
administration born of famine should be storage is therefore no surprise.

But storage on its own does nothing. The road from the dam to the field has
to be completed: main canal, secondary canal, tertiary, on-farm works. What
the 3,654 schemes counted and the 5.56 million hectares targeted describe is
that chain itself.

And the longer the chain, the heavier it is to run. Building a dam is a
project; it has a beginning and an end. Operating an irrigation network is
work that begins again every year: clearing the canals, opening and closing
the gates, the water distribution programme for each season. Where
construction ends, a burden remains that does not end — and the question of
transfer is precisely the question of who carries it.

The state built these structures. But none of them was built in a year; the
biggest of them took generations, and some are still under way.$dsr$, array['olcek']::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/dsi/dsi_seyhan_baraji.jpg","atif":"Zeynel Cebeci — CC BY-SA 4.0","kaynak":null,"alt_tr":"Seyhan Baraj Gölü, Adana.","alt_en":"Seyhan Reservoir, Adana."}$dsr$::jsonb),
  (5, $dsr$Yarım yüzyıl süren projeler$dsr$, $dsr$Projects measured in half-centuries$dsr$, $dsr$Kurum kurulduğunda taşrada on iki bölge müdürlüğü vardı ve ikisi Seyhan ile
Hirfanlı'daydı. Yani kurumun ilk haritası illere göre değil, yapılacak
barajlara göre çizilmişti. 6200 sayılı Kanun 28 Şubat 1954'te yürürlüğe
girdiğinde teşkilat zaten iki büyük şantiyenin üstüne oturmuştu.

Barajların tek tek ne zaman işletmeye açıldığı kurumun yayımlanmış
belgelerinde tablo hâlinde yok. Ama kurumun kendi teşkilat çizelgesi bir şey
söylüyor: bir projeye ne zaman kendi idaresini kurduğunu. Bir baraj için
bölge müdürlüğü, bir ova için işletme şubesi, bir tünel için başmühendislik
açmak, o işin artık kalıcı olduğunu kabul etmektir. O tarihler bir takvim
veriyor.

Takvim 1967'de Adana'da başlıyor: Aşağı Seyhan Ovası sulamasının işletme ve
bakım şubesi 7 Haziran 1967'de kuruluyor. Ertesi yıl, 3 Temmuz 1968'de,
Çumra'da Konya Ovası sulamasının karşılığı açılıyor. İki ova, iki şube, iki
yıl.

Sekiz yıl sonra çizelgeye bugün GAP diye bilinen işin ilk adı giriyor:
**DSİ Aşağı Fırat Projesi 15. Bölge Müdürlüğü, Şanlıurfa, 24 Mayıs 1976.**
Henüz GAP denmiyor; Aşağı Fırat deniyor. 1977'de Aşağı Ceyhan Ovası,
1980'de Keban'da su ürünleri şubesi, 1986'da Şanlıurfa Ovaları sulaması
şube müdürlüğü geliyor.

Suyun Harran Ovası'na indiği hattın kendi idaresi — Şanlıurfa Tüneli ve
Harran Kanalı Başmühendisliği — **10 Temmuz 1993'te** kuruluyor. Aşağı
Fırat'ın bölge müdürlüğünden on yedi yıl sonra.

Çizelge 1998'de Artvin'de Çoruh Projeleri bölge müdürlüğüyle, 2008'de
Mardin'de Ilısu Projesi bölge müdürlüğüyle, 2012'de Atatürk Barajı işletme
başmühendisliğiyle ve 2014'te Silvan Proje Müdürlüğüyle sürüyor. İlk
kayıttan sonuncusuna kırk yedi yıl var.

### Güneydoğu Anadolu Projesi

GAP dokuz ili kapsıyor ve bu illerde 2025 itibarıyla 9,59 milyon kişi
yaşıyor. Proje tek bir yapı değil; kurumun ifadesiyle "13 adet proje
demetinden oluşmaktadır" — yedisi Fırat, altısı Dicle havzasında. Fırat
üzerinde Keban, Karakaya, Atatürk, Birecik ve Karkamış; Dicle ve kolları
üzerinde Batman, Kralkızı, Dicle ve Ilısu baraj ve hidroelektrik
santralleri tamamlanmış durumda.

Enerji tarafı neredeyse bitmiş: kurulu güç 7.461 megavat, yıllık üretim
hedefi 27,3 milyar kilovatsaat, gerçekleşme %91. Sulama tarafı aynı yerde
değil. Hedef 1,058 milyon hektar, gerçekleşme **%64**. Yani Aşağı Fırat'a
ilk bölge müdürlüğünün kurulmasından kırk dokuz yıl sonra, projenin sulama
ayağının üçte birinden fazlası hâlâ yapılmamış.

Bu sıralama tesadüf değil. Bir hidroelektrik santral barajla birlikte
biter; sulama ise barajdan sonra başlar ve tarlaya kadar her metresi ayrı
bir inşaattır.

### Doğu Anadolu Projesi

DAP on beş ili kapsıyor, bölgede 6,53 milyon kişi yaşıyor ve Türkiye'nin
sulanabilir tarım arazisinin %16'sı burada. Hedef 1.377.656 hektar.

Bugün işletmede olan 602.436 hektar — hedefin %44'ü. 263.857 hektarda
inşaat sürüyor, 511.363 hektar hâlâ planlama ve proje aşamasında. Geriye
kalan 775.220 hektar, yani hedefin yarısından fazlası, henüz suya
kavuşmamış.

### Konya Ovası Projesi

KOP sekiz ili kapsıyor. Proje alanı 96.627 kilometrekare — Türkiye
yüzölçümünün %12,4'ü — ve burada 4,68 milyon kişi yaşıyor.

Bu projeyi ötekilerden ayıran şey suyun kendisinin olmaması. Konya kapalı
havzasının yıllık yağış ortalaması 400 milimetre; kurumun ifadesiyle
"Türkiye ortalamasından yaklaşık %30 daha eksik yağış" alıyor. Kapalı bir
havzada su dışarıdan gelmiyorsa, dışarıdan getirilmesi gerekiyor. Çözüm
başka bir havzadan aktarma oldu: Yukarı Göksu havzasından "Mavi Tünel
vasıtasıyla su aktarılması".

KOP'un sulama alanı 1.647.239 hektar ve bunun yaklaşık %75'i sulanıyor —
717.817 hektarı yüzey suyuyla, 519.601 hektarı yeraltısuyuyla. Yeraltısuyu
payının bu kadar yüksek olması tek başına bir ölçü: ovanın suyu yalnızca
kanaldan değil, kuyudan da geliyor.

### Beş rezervuar

Türkiye'de işletmede 861 baraj var. Yüzey alanı olarak en genişleri
Atatürk (817 km²), Keban (675 km²), Ilısu (313 km²), Karakaya (268 km²) ve
Hirfanlı (263 km²). Atatürk Barajı'nın göl yüzeyi, 1954'te kurumun ilk
bölge müdürlüklerinden birinin yanı başında olduğu Hirfanlı'nın 3,1 katı.

Beş rezervuarın dördü GAP'ın içinde. Beşincisi, Hirfanlı, kurumun en eski
işlerinden biri — ve kurum onun yanına daha ilk yılında bir bölge
müdürlüğü kurmuştu.

Bütün bunlar bu dosyanın asıl konusuna çıkıyor. Bu ölçekte bir şebeke
kurmak bir inşaat işi; kurulduktan sonra onu her yıl işletmek bambaşka bir
iş. Kurum birinciyi yaptı. İkincisini kimin yapacağı, sonraki bölümlerin
konusu.$dsr$, $dsr$When the institution was founded it had twelve regional directorates in the
field, and two of them were at Seyhan and Hirfanlı. Its first map, in other
words, was drawn not by provinces but by the dams that were to be built. By
the time Law 6200 entered into force on 28 February 1954, the organisation
was already sitting on top of two great construction sites.

The institution's published documents contain no table of when individual
dams were commissioned. But its own organisation chart says something else:
when it gave a project an administration of its own. Opening a regional
directorate for a dam, an operations branch for a plain, a chief
engineering office for a tunnel, is an admission that the work has become
permanent. Those dates give a calendar.

The calendar begins in Adana in 1967: the operation and maintenance branch
for the Lower Seyhan Plain scheme is established on 7 June 1967. The
following year, on 3 July 1968, its counterpart for the Konya Plain scheme
opens at Çumra. Two plains, two branches, two years.

Eight years later the chart acquires the first name of what is known today
as GAP: **the DSİ Lower Euphrates Project 15th Regional Directorate,
Şanlıurfa, 24 May 1976.** It is not yet called GAP; it is called the Lower
Euphrates. In 1977 comes the Lower Ceyhan Plain, in 1980 a fisheries branch
at Keban, in 1986 the branch directorate for the Şanlıurfa Plains scheme.

The line by which the water descends to the Harran Plain gets its own
administration — the Şanlıurfa Tunnel and Harran Canal chief engineering
office — on **10 July 1993.** Seventeen years after the Lower Euphrates
regional directorate.

The chart continues with the Çoruh Projects regional directorate at Artvin
in 1998, the Ilısu Project regional directorate at Mardin in 2008, the
Atatürk Dam operations chief engineering office in 2012 and the Silvan
Project Directorate in 2014. Forty-seven years separate the first entry
from the last.

### The Southeastern Anatolia Project

GAP covers nine provinces, home to 9.59 million people as of 2025. The
project is not a single structure; in the institution's words it "13 adet
proje demetinden oluşmaktadır" — it consists of thirteen project bundles,
seven in the Euphrates basin and six in the Tigris. On the Euphrates stand
Keban, Karakaya, Atatürk, Birecik and Karkamış; on the Tigris and its
tributaries, the Batman, Kralkızı, Dicle and Ilısu dams and hydroelectric
plants have been completed.

The energy side is all but finished: 7,461 megawatts of installed capacity,
a target of 27.3 billion kilowatt-hours a year, 91% realised. The
irrigation side is not in the same place. The target is 1.058 million
hectares and realisation stands at **64%**. Forty-nine years after the
first regional directorate was set up for the Lower Euphrates, more than a
third of the project's irrigation leg is still unbuilt.

That order is no accident. A hydroelectric plant is finished together with
its dam; irrigation begins after the dam, and every metre of it down to the
field is a separate construction.

### The Eastern Anatolia Project

DAP covers fifteen provinces, 6.53 million people live in the region, and
16% of Türkiye's irrigable agricultural land lies there. The target is
1,377,656 hectares.

In operation today: 602,436 hectares, 44% of the target. Construction is
under way on 263,857 hectares and 511,363 hectares are still at the
planning and project stage. The remaining 775,220 hectares — more than half
the target — have yet to receive water.

### The Konya Plain Project

KOP covers eight provinces. The project area is 96,627 square kilometres —
12.4% of Türkiye's surface — and 4.68 million people live in it.

What sets this project apart from the others is that the water is not
there. The Konya closed basin averages 400 millimetres of rainfall a year;
in the institution's words it receives "Türkiye ortalamasından yaklaşık %30
daha eksik yağış", about 30% less rainfall than the Turkish average. In a
closed basin, if water does not come from outside it has to be brought from
outside. The answer was a transfer from another basin: water conveyed from
the Upper Göksu basin "Mavi Tünel vasıtasıyla su aktarılması", by way of
the Blue Tunnel.

KOP's irrigation area is 1,647,239 hectares and roughly 75% of it is
irrigated — 717,817 hectares from surface water, 519,601 from groundwater.
That the groundwater share should be so high is a measure in itself: the
plain's water comes not only from the canal but from the well.

### Five reservoirs

There are 861 dams in operation in Türkiye. The widest by surface area are
Atatürk (817 km²), Keban (675 km²), Ilısu (313 km²), Karakaya (268 km²) and
Hirfanlı (263 km²). The lake surface of the Atatürk Dam is 3.1 times that
of Hirfanlı — beside which, in 1954, the institution placed one of its first
regional directorates.

Four of the five reservoirs lie within GAP. The fifth, Hirfanlı, is among
the institution's oldest works — and the institution set up a regional
directorate next to it in its very first year.

All of this leads back to the real subject of this file. Building a network
on this scale is a construction job; operating it every year afterwards is
an entirely different one. The institution did the first. Who does the
second is the subject of the sections that follow.$dsr$, array['proje_takvimi', 'buyuk_rezervuarlar', 'bolgesel_projeler']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/dsi/dsi_ataturk_baraji.jpg","atif":"Honacan — CC BY-SA 3.0","kaynak":null,"alt_tr":"Atatürk Barajı'nın mansap yüzü; gövdede kurumun kendi baş harfleri yazılı.","alt_en":"The downstream face of the Atatürk Dam; the institution's own initials are written on the embankment."}$dsr$::jsonb),
  (6, $dsr$Devir elli üç yıl sürdü$dsr$, $dsr$The transfer took fifty-three years$dsr$, $dsr$Devrin ne kadar sürdüğünü gösteren en uzun kesintisiz seri yeraltısuyu
tesislerine ait. **Aşağıdaki rakamlar yalnızca yeraltısuyu sulama
tesislerini kapsıyor**, bütün sulama tesislerini değil; 7. bölümün tablosuyla
toplanamazlar.

Seri 1967'de başlıyor: 50 hektar. Üç yıl boyunca rakam değişmiyor. Yani devir
programı bir ilanla ve bir kampanyayla değil, tek bir sözleşmeyle ve ardından
gelen uzun bir sessizlikle başlıyor.

1970'te rakam 380 hektar oluyor, ertesi yıl beş binin üstüne çıkıyor. Asıl
tırmanış bundan sonra geliyor: 1975'te 38.880 hektar, 1985'te 153.905,
1995'te 268.003, 2005'te 370.937, 2015'te 454.486. 2020'de kümülatif
devredilen alan 464.316 hektar.

Elli üç yıl. Ama bu sürenin içinde devir düzgün bir hızla ilerlemedi.

Serinin yarısı 1994'te geçiliyor — ilk yarı yirmi yedi yıl, ikinci yarı yirmi
altı yıl sürüyor. Ortadan bakıldığında neredeyse simetrik; eğri, sabit hızla
çalışan bir programa benziyor.

Asıl fark uçlarda. En hızlı beş yıllık dilim 1987'de kapanıyor ve o beş yılda
90.078 hektar devrediliyor. Serinin son beş yılında devredilen alan 9.830
hektar. Aradaki fark 9,2 kat.

Bir devir programının böyle bitmesi beklenir: devredilecek tesis azaldıkça
hız da düşer, çünkü geriye kalanlar ya çok küçüktür ya da devralacak bir yapı
bulunmamıştır. Eğrinin asıl söylediği uç değil, orta kısım. 1967'de elli
hektarla başlayan şey, 1980'lerde yılda on binlerce hektar devreden bir
yönetim programına dönüşmüş. Bu, bir anda alınmış bir karar değil; on yıllara
yayılmış, bütçesi ve personeli olan sürekli bir iş.

Bu seri devrin tamamı değil, ölçülebilen en uzun parçası. Yeraltısuyu
tesisleri genellikle küçük ölçekli; bir ovayı kateden büyük yüzey sulamaları
bu seride yok. Bütün tesisleri kapsayan güncel tablo bir sonraki bölümde.$dsr$, $dsr$The longest unbroken series showing how long the transfer took belongs to
groundwater schemes. **The figures below cover groundwater irrigation
schemes only**, not all irrigation schemes; they cannot be added to the
table in §7.

The series begins in 1967 at 50 hectares. For three years the figure does not
move. The transfer programme begins not with an announcement and a campaign
but with a single contract followed by a long silence.

In 1970 the figure becomes 380 hectares, and the following year it passes
five thousand. The real climb comes after that: 38,880 hectares in 1975;
153,905 in 1985; 268,003 in 1995; 370,937 in 2005; 454,486 in 2015. By 2020
the cumulative transferred area is 464,316 hectares.

Fifty-three years. But within that span the transfer did not advance at an
even pace.

The series passes its halfway point in 1994 — the first half takes
twenty-seven years, the second twenty-six. Seen from the middle it is almost
symmetrical. The real difference is at the ends. The fastest five-year
stretch closes in 1987, and in those five years 90,078 hectares were
transferred. In the final five years of the series the transferred area is
9,830 hectares. The difference between the two is a factor of 9.2.

A transfer programme is expected to end this way: as the stock of schemes
left to hand over shrinks, so does the pace, because what remains is either
very small or has found no body willing to take it on. What the curve really
reports is not its ends but its middle. What began in 1967 with fifty
hectares had become, by the 1980s, an administrative programme transferring
tens of thousands of hectares a year. That is not a decision taken at one
moment; it is continuous work, spread across decades, with a budget and
staff behind it.

This series is not the whole of the transfer but its longest measurable
part. Groundwater schemes are generally small; the large surface irrigation
systems that cross a whole plain are not in it. The current table covering
all schemes comes in the next section.$dsr$, array['devir_egrisi']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/dsi/dsi_koy_sulama_kanali.jpg","atif":"mhasras — CC BY 3.0","kaynak":null,"alt_tr":"Küllük köyünün sulama kanalı.","alt_en":"The irrigation canal at Küllük village."}$dsr$::jsonb),
  (7, $dsr$Tesislerin beşte biri, alanın beşte dördünden fazlası$dsr$, $dsr$A fifth of the schemes, more than four-fifths of the area$dsr$, $dsr$31 Aralık 2025 itibarıyla devredilmiş sulama tesisi sayısı 936, devredilen
alan 3.083.200 hektar. **Bu rakamlar bütün sulama tesislerini kapsıyor**,
yalnızca yeraltısuyunu değil.

Tesisleri devralan dört tür kuruluş var ve aralarındaki dağılım iki ayrı
soruya iki ayrı cevap veriyor.

Sayıya bakılırsa ilk sırada kooperatifler duruyor: 414 tesis, toplamın %44'ü.
Sulama birlikleri 181 tesisle %19'da kalıyor.

Alana bakılırsa tablo tersine dönüyor. Sulama birliklerinin devraldığı alan
2.562.855 hektar — toplamın %83,1'i. Kooperatiflerin payı 193.740 hektar,
yani %6,3.

Aynı iki kuruluş türü, bir ölçüde geride, öteki ölçüde ezici çoğunlukta.
Aradaki farkın sebebi devredilen tesisin büyüklüğü.

Bir sulama birliğinin devraldığı tesis ortalama 14.159 hektar suluyor. Bir
kooperatifinki 468 hektar. Köy tüzel kişiliğinin devraldığı tesis ortalama
180 hektarda kalıyor. Birlik başına düşen alan, kooperatif başına düşenin
30,3 katı.

Yani ortada iki ayrı devir var. Büyük şebekeler — bir ovayı baştan sona
kateden ana kanallar ve onların dağıtım ağı — sulama birliklerine gitti. Bu
ölçekte bir tesisi işletmek başlı başına bir kurum işi: on dört bin hektarlık
bir alanda su sırasını belirlemek, kanalları bakımda tutmak ve binlerce
kullanıcıdan ücret tahsil etmek gerekiyor. Birliklerin ayrı bir kanunla
düzenlenmiş olması bununla ilgili.

Küçük tesisler ise, çoğu tek bir köyün ya da birkaç yüz hektarlık bir alanın
suyunu taşıyanlar, kooperatiflere ve köy tüzel kişiliklerine gitti. Köy tüzel
kişiliğinin devraldığı 164 tesis toplam alanın yalnızca %1'ini buluyor —
sayıca kooperatiflerden çok uzak değil, ama ölçek olarak bambaşka bir
dünyada.

Belediyelerin devraldığı 160 tesis 226.146 hektarı suluyor, toplamın %7,3'ü;
ortalaması birliklerle kooperatifler arasında kalıyor. Geriye kalan 17 tesis
70.987 hektarla diğer kuruluşlarda.

Tablo bir bütün olarak okunduğunda ortaya çıkan şey şu: devir tek tip bir
işlem değil. Devralanın cinsi, devredilen tesisin büyüklüğüne göre
belirlenmiş. Bir köy kendi kanalını işletebilir; bir ovanın şebekesi için
ayrı bir tüzel kişilik gerekiyor.$dsr$, $dsr$As of 31 December 2025 the number of transferred irrigation schemes is 936
and the transferred area is 3,083,200 hectares. **These figures cover all
irrigation schemes**, not groundwater alone.

Four kinds of body have taken the schemes over, and the distribution between
them gives two different answers to two different questions.

By number, cooperatives come first: 414 schemes, 44% of the total. Irrigation associations stay at 19%, with 181 schemes.

By area the picture reverses. The area taken over by irrigation associations
is 2,562,855 hectares — 83.1% of the total. The cooperatives' share is
193,740 hectares, or 6.3%.

The same two kinds of body: second place on one measure, an overwhelming
majority on the other. The reason for the gap is the size of the schemes
transferred.

The scheme an irrigation association takes over irrigates 14,159 hectares on
average. A cooperative's averages 468 hectares. A scheme taken over by a
village legal entity averages 180 hectares. The area per association is 30.3
times the area per cooperative.

So there are in fact two separate transfers. The large networks — the main
canals that cross a plain end to end, and the distribution webs hanging off
them — went to the irrigation associations. Running a scheme on that scale
is institutional work in itself: setting the order of turns across fourteen
thousand hectares, keeping the canals maintained, collecting charges from
thousands of users. That the associations are regulated by a law of their
own follows from this.

The small schemes, most of them carrying water for a single village or a few
hundred hectares, went to cooperatives and village legal entities. The 164
schemes taken over by village legal entities come to just 1% of the total
area — not far behind the cooperatives in number, but in a different world
of scale.

The 160 schemes taken over by municipalities irrigate 226,146 hectares, 7.3%
of the total; their average falls between the associations and the
cooperatives. The remaining 17 schemes, with 70,987 hectares, sit with other
bodies.

Read as a whole, the table says this: the transfer was not a single uniform
operation. The kind of body receiving a scheme was matched to the size of
the scheme. A village can run its own canal; a plain-wide network needs a
legal person of its own.$dsr$, array['devir_asimetrisi', 'devredilen_alan']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/dsi/dsi_harran_2001_sulamali.jpg","atif":"Volker Höhfeld — CC BY-SA 4.0","kaynak":null,"alt_tr":"Aynı ova, 27 Ağustos 2001 — GAP sulamasıyla. Köy ve höyük aynı; arkadaki ova yeşil.","alt_en":"The same plain, 27 August 2001 — with GAP irrigation. The village and the mound are the same; the plain behind is green."}$dsr$::jsonb),
  (8, $dsr$Çiftçi kurumla nerede karşılaşıyor$dsr$, $dsr$Where the farmer meets the institution$dsr$, $dsr$Bir çiftçi için DSİ çoğu zaman uzaktaki bir kurum. Suyu getiren kanalı o inşa
etmiş olabilir ama suyun ne zaman geleceğini söyleyen, bedelini tahsil eden
ve kanalı onaran taraf genellikle başkası.

O başkasının ne olduğunu 8 Mart 2011 tarihli ve 6172 sayılı Sulama Birlikleri
Kanunu tanımlıyor (RG 22 Mart 2011 · 27882). Kanunun tanımlar maddesi devri
şöyle açıklıyor:

> **Devir:** DSİ tarafından inşa edilmiş veya halen inşa edilmekte olan ya da
> inşa edilmesi planlanan sulama maksatlı tesislerin işletme, bakım, onarım
> ve yönetim sorumluluğunun, DSİ ve birlik arasında imzalanan sözleşme
> hükümleri uyarınca birliklere devredilmesini
>
> — 6172 sayılı Kanun, Madde 2/e

Dört sorumluluk sayılıyor: işletme, bakım, onarım, yönetim. Sayılmayan şey
mülkiyet — ve bu bir yorum değil, ölçülebilir bir durum: *mülkiyet* kelimesi
6172 sayılı Kanunun tamamında bir kez bile geçmiyor.

Devirden sonra da bağ kopmuyor. Birliğin görev alanının "sınırları, kapsamı
ve ismi DSİ tarafından belirlenir" (Madde 3/1); yani birlik kendi sınırını
kendi çizmiyor. Birlik, devraldığı tesisin yatırım bedellerini geri ödemekle
yükümlü (Madde 3/4-c). Çalışmalarında "kâr gayesi güdülemez" (Madde 10/2) ve
topladığı paranın tamamı "işletme, bakım, onarım ve yönetim sorumluluğu
devralınan tesis için sarf edilir" (Madde 10/3).

Paranın nereden geldiği de sayılı. Madde 11 birliğin gelirlerini altı kalemde
topluyor; ilk ikisi doğrudan su kullanıcısından: "Katılım payı" ve "Su
kullanım hizmet bedeli". Üçüncü sırada bağışlar var, dördüncüde "Yatırım
bedellerine ilişkin geri ödeme katkı payı" — yani tesisin yatırım bedelinin
geri ödemesi de kullanıcıdan toplanıyor. Listede ayrıca ana statüye aykırı
hareket edenlerden alınan "idari para cezaları" bulunuyor.

Çiftçinin bu yapıyla temas noktası 2011'de değil, 2018'de bugünkü hâlini
aldı. O yıl kanuna eklenen Ek Madde 1 şöyle başlıyor: "Birlik görev alanında
yer alan her su kullanıcısı gerçek ve tüzel kişi sulama tesisinden
faydalanabilmek için o birliğe üye olmak zorundadır."

Üyelik seçimlik değil. Suyu kullanmak isteyen üye olmak zorunda, ilk kayıtta
bir defaya mahsus katılım payı ödüyor ve sonrasında su kullanım hizmet bedeli
tahakkuk ediyor. Üye olan çiftçi yalnızca ödeme yükümlülüğü de almıyor: suyun
yetmediği yıl "yapılan ekim planlamasına uymak", "sulama planlaması ve su
dağıtım ve münavebe programlarına katılmak" ve bakım çalışmaları için
"arazisine girilmesine izin vermek" aynı fıkrada yazılı.

Münavebe, suyun sırayla dağıtılması demek. Yeterli su olmadığında herkesin
aynı anda sulaması mümkün değil; sıra bir programa bağlanıyor ve o programa
uymak kanuni bir yükümlülük hâline geliyor.

Kurak bir yılda ne ekileceğinin bir plana bağlanması, kıtlıktan doğan bir
idarenin seksen dokuz yıl sonraki en somut izi.$dsr$, $dsr$For a farmer, DSİ is usually a distant institution. It may have built the
canal that brings the water, but the party that says when the water will
come, collects the charge for it and repairs the canal is generally somebody
else.

What that somebody else is, is defined by Law 6172, the Irrigation
Associations Law of 8 March 2011 (Official Gazette, 22 March 2011, issue
27882). The law's definitions article explains transfer as follows:

> **Transfer:** the handing over to the associations, under the terms of a
> contract signed between DSİ and the association, of the responsibility for
> the operation, maintenance, repair and management of irrigation schemes
> built, currently being built or planned to be built by DSİ
>
> — Law 6172, Article 2(e)

Four responsibilities are listed: operation, maintenance, repair,
management. What is not listed is ownership — and this is not an
interpretation but a measurable fact: the word *ownership* does not appear
even once in the whole of Law 6172.

Nor is the tie cut after the transfer. The "boundaries, scope and name of an
association's area of duty shall be determined by DSİ" (Article 3(1)).
The association is obliged to repay the investment costs of the scheme it
has taken over (Article 3(4)(c)). In its work "no profit motive may be
pursued" (Article 10(2)), and the whole of the money it collects "shall be
spent on the scheme for whose operation, maintenance, repair and management
responsibility has been taken over" (Article 10(3)).

Where the money comes from is listed as well. Article 11 gathers the
association's income under six headings; the first two come directly from
the water user: "Katılım payı", the participation fee, and "Su kullanım
hizmet bedeli", the water use service charge. Donations come third, and
fourth is the "Yatırım bedellerine ilişkin geri ödeme katkı payı" — the
contribution towards repaying the investment cost, which is therefore also
collected from users. The list further includes "idari para cezaları", the
administrative fines levied on those who act against the association's
charter.

The farmer's point of contact with this structure took its present form not
in 2011 but in 2018. The additional article inserted into the law that year
begins: "Every water user, natural or legal person, within an association's
area of duty is obliged to become a member of that association in order to
benefit from the irrigation scheme."

Membership is not optional. A one-off participation fee is charged at first
registration, and a water use service charge accrues thereafter. The member
farmer takes on more than a payment obligation: in a year when water falls
short, complying with "the planting plan drawn up", taking part in "the
irrigation planning and the water distribution and rotation programmes", and
granting "permission for entry onto their land" for maintenance work are all
written into the same paragraph.

Rotation here means distributing the water by turns. When there is not
enough, not everyone can irrigate at once; the order is set out in a
programme, and complying with that programme becomes a statutory obligation.

That what is planted in a dry year should be tied to a plan is the most
concrete trace, eighty-nine years on, of an administration born of famine.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/dsi/dsi_osmaniye_sulama.jpg","atif":"Ozgurmulazimoglu — CC BY-SA 3.0","kaynak":null,"alt_tr":"Osmaniye'de tarla başına su getiren kanalet.","alt_en":"A field-edge flume carrying water to a maize plot, Osmaniye."}$dsr$::jsonb),
  (9, $dsr$Kaynakça$dsr$, $dsr$Sources$dsr$, $dsr$**Birincil metinler.** 6200 sayılı *Devlet Su İşleri Genel Müdürlüğünce
Yürütülen Hizmetler Hakkında Kanun* (RG 25.12.1953 · 8592) ve 6172 sayılı
*Sulama Birlikleri Kanunu* (RG 22.03.2011 · 27882), mevzuat.gov.tr'nin
tasdikli yürürlükteki metinlerinden. 4 numaralı Cumhurbaşkanlığı
Kararnamesi'nin Onuncu Bölümü (md. 119–121) aynı kaynaktan. Mülga madde
sayıları ve mülga dayanağı (2/7/2018 – KHK-703/69) kanun metninin kendisinden
sayıldı; madde numaraları yürürlükteki nüshadan tek tek okundu.

**Kurumun beyanı.** Tesis, baraj, gölet, depolama ve hedef alan rakamları DSİ
2025 Faaliyet Raporu'ndan; devredilen tesislerin devralan kuruluşa göre
dağılımı aynı raporun 47. sayfasındaki Tablo 14'ten. Kuruluş silsilesi
kurumun kendi "Hakkımızda" sayfasından. Bu rakamlar kurumun kendi ölçümüdür
ve bağımsız bir kaynağa karşı doğrulanmamıştır; 1953 kuruluş tarihi
istisnadır, kanun metni aynı tarihi veriyor.

**Devir serisi.** 1967–2020 arası yıllık kümülatif devir rakamları DSİ 2021
Haritalı İstatistik Bülteni'nin 62. sayfasından. Bu çizelgenin kapsamı
**yalnızca yeraltısuyu sulama tesisleridir** ve bu dosyadaki 2025 tarihli
genel tabloyla aynı büyüklüğü ölçmez. Çizelgenin ünite sütununda 1999 satırı
kendi içinde tutarsız — kümülatif bir seride 1998'in altına düşüyor — bu
yüzden seri yalnızca alan sütunundan okunmuştur.

**Yayımlanmış kaynakların kapsamı.** Bültenin 64. sayfası DSİ'ce işletilen ve
devredilen sulamaları ayrı ayrı listeliyor, ancak bu ayrımı tesis tesis
veriyor; ulusal toplam olarak yayımlanmış bir rakam bulunmuyor. Bu nedenle bu
dosya devredilen tarafın ölçeğini anlatır, devredilmeyen tarafın büyüklüğünü
vermez.

**2028 hedefi bir hedeftir.** 5,56 milyon hektarlık brüt alan gerçekleşmiş
değil, ilan edilmiş plandır; devredilen alanla oranlanarak bir gerçekleşme
yüzdesi üretilmemiştir.$dsr$, $dsr$**Primary texts.** Law 6200, the *Law on Services Carried Out by the General
Directorate of State Hydraulic Works* (Official Gazette 25.12.1953, 8592),
and Law 6172, the *Irrigation Associations Law* (Official Gazette
22.03.2011, 27882), from the certified texts in force on mevzuat.gov.tr. The
Tenth Chapter of Presidential Decree No. 4 (arts. 119–121) from the same
source. The counts of repealed articles and the basis of repeal (2/7/2018 –
Decree-Law 703, art. 69) were counted from the text of the law itself.

**The institution's own statements.** The figures for schemes, dams, ponds,
storage and target area come from the DSİ 2025 Annual Report; the
distribution of transferred schemes by receiving body from Table 14 on page
47 of the same report. The chronology of establishment comes from the
institution's own "About Us" page. These are the institution's own
measurements and have not been verified against an independent source; the
1953 founding date is the exception, as the text of the law gives the same
date.

**The transfer series.** The annual cumulative transfer figures for
1967–2020 come from page 62 of the DSİ 2021 Illustrated Statistical
Bulletin. The scope of that table is **groundwater irrigation schemes only**
and it does not measure the same quantity as the 2025 general table used
here. In the table's unit column the 1999 row is internally inconsistent —
in a cumulative series it falls below 1998 — and for that reason the series
has been read from the area column alone.

**The scope of the published sources.** Page 64 of the bulletin lists
irrigation operated by DSİ and irrigation transferred by DSİ separately, but
it gives that distinction scheme by scheme; no national total is published.
For that reason this file describes the scale of the transferred side and
does not give the size of the side that was not transferred.

**The 2028 figure is a target.** The 5.56 million hectares of gross area is
a declared plan, not an achieved result, and no completion percentage has
been produced by setting the transferred area against it.$dsr$, '{}'::text[], 'belge', $dsr${"url":"https://tarimportali.net/dosya/dsi/dsi_kizilirmak_hirfanli.jpg","atif":"Hajo-Muc — CC BY-SA 3.0","kaynak":null,"alt_tr":"Hirfanlı'nın altında Kızılırmak; sağda barajın beton yapıları.","alt_en":"The Kızılırmak below Hirfanlı; the dam's concrete works on the right."}$dsr$::jsonb)
) as v(ord, title_tr, title_en, body_tr, body_en, chart_keys, tur, gorsel)
where d.slug = 'dsi';

-- Sağlama: beklenen bölüm sayısı yazılmadıysa işlem geri alınır.
do $kontrol$
declare n integer;
begin
  select count(*) into n
    from public.dossier_sections s
    join public.country_dossiers d on d.id = s.dossier_id
   where d.slug = 'dsi';
  if n <> 9 then
    raise exception 'Bölüm sayısı 9 olmalıydı, % yazıldı', n;
  end if;
end
$kontrol$;

commit;
