-- Irak — Ülke Dosyası Sayı 05 · İÇERİK YAZILIYOR, DEVİR YAPILMIYOR
--
-- ── BU GÖÇ DOSYAYI YAYINA ALMAZ ──────────────────────────────────────────
-- status = 'draft'. Dosya veritabanına yazılıyor ama ana sayfada ve ülke
-- rafında GÖRÜNMÜYOR. Devir (status → published, pencerenin başlatılması ve
-- Avustralya'nın arşive alınması) AYRI BİR GÖÇ ve AÇIK ONAY ister.
--
-- ── SIRA ÖNEMLİ (§2.12/4) ────────────────────────────────────────────────
-- Devir göçünden ÖNCE `./deploy.sh --hosting` çalışmalı ve Irak'ın on iki
-- görselinin content-type: image/* döndüğü doğrulanmalı. Ters sırada dosya
-- canlıda kırık görsellerle açılır (25 Ağustos 2026'da yaşandı). Bu göç
-- draft yazdığı için o sıra kısıtına tabi DEĞİL; devir göçü tabidir.
--
-- ── NE YAZILIYOR ─────────────────────────────────────────────────────────
-- 18 bölüm, 16 grafik, 18 bölüm görseli ve kapak, tema künyesi ve kilitli
-- veri sayfası. Hikâye slaytları AYRI betikle yazılıyor (dosya_hikayeleri.py).
--
-- İçteki begin/commit çıkarıldı: CLI her migration'ı zaten tek işlemde
-- çalıştırıyor (§4.1).

-- ════════════════════════════════════════════════════════════════════════
-- irak — ÜRETİLMİŞ seed (node content/dossiers/seed_dossier.mjs irak)
-- Göçe gömülmeden HEMEN ÖNCE yeniden üretildi: DSİ'de göç, düzeltme
-- öncesi bir seed'i gömmüştü ve on bölüm başlığı canlıya ### ile gitti.
-- ════════════════════════════════════════════════════════════════════════

-- Irak — Ülke Dosyası · seed
--
-- ÜRETİLMİŞ DOSYA — elle düzenlemeyin.
-- Kaynak:  content/dossiers/irak/
-- Üretim:  node content/dossiers/seed_dossier.mjs irak
-- Tarih:   2026-11-02T21:45:38.197Z
--
-- Bölüm: 18 · TR ~4.731 kelime · EN ~6.153 kelime
-- Metindeki her rakam data.json'dan, data.json _raw/'dan geliyor.
--
-- Yeniden çalıştırılabilir: dosyayı günceller, bölümleri silip yeniden yazar.
-- Bölümler upsert değil sil-yaz, çünkü bir revizyonda bölüm sayısı azalırsa
-- upsert eski fazlalığı geride bırakırdı.

insert into public.country_dossiers
  (slug, name_tr, name_en, iso3, tur, kurulus_belgesi, edition,
   thesis_tr, thesis_en, theme, data, charts, anahtar_kelimeler,
   cover_url, cover_credit, video_url, status, starts_at, ends_at, published_at)
values (
  'irak',
  'Irak',
  'Iraq',
  'IRQ',
  'ulke',
  null,
  5,
  $dsr$Tarımın doğduğu ovada ekili alanın %70'i tuzdan etkilenmiş, bir tahıl 64 yılın en düşük hasadını geçen yıl verdi, pirinç 2 yılda kaybolup 2 yılda geri geldi. Aynı ovaya komşusundan gelen tarım malı, oradan gidenin 154 katı.$dsr$,
  $dsr$On the plain where farming began, 70% of the cropland is affected by salt, one grain gave its lowest harvest in 64 years last season, and rice vanished in 2 years and came back in 2. Into that same plain the neighbour sends 154 times what it takes out.$dsr$,
  $dsr${"_dosya":"Irak — Ülke Dosyası Sayı 05 · tasarım künyesi","_amac":"Görsel kararlar. DossierTheme bu dosyadan üretilir; kodda serbest renk yazılmaz.","_kural":"Bu dosyadaki hiçbir kontrast sayısı 'yaklaşık' değildir. Hepsi _raw/kontrast.py'den geliyor; palet değişirse betik yeniden koşar ve buradaki sayılar güncellenir.","_sureklilik":"Beş dosya, beş geometri: Hollanda dikey şeritler (polder), Rusya yatay bantlar (toprak profili), İspanya nokta ızgarası (dikilmiş zeytinlik), Avustralya ortogonal ızgara (kanal ağı), Irak düzensiz poligon ağı (tuz kabuğu). İlk dördü İNSAN YAPIMI düzendi — dizinin sessiz ortak fikri buydu. BEŞİNCİSİ O FİKRİ BİLEREK KIRIYOR: tuz poligonu tasarlanmış bir desen değil, drenaj yetmediğinde toprağın kendiliğinden aldığı biçim. Irak'ın geometrisi dünyanın en eski sulama geometrisi ve dizide ilk kez çizilen şey düzenin kendisi değil, düzen çekildiğinde geriye kalan. Dosyanın ölçtüğü şeyle birebir: ekili alanın yüzde yetmişi tuzdan etkilenmiş.","tez_cumlesi":{"tr":"Tarımın doğduğu ovada ekili alanın %70'i tuzdan etkilenmiş, bir tahıl 64 yılın en düşük hasadını geçen yıl verdi, pirinç 2 yılda kaybolup 2 yılda geri geldi. Aynı ovaya komşusundan gelen tarım malı, oradan gidenin 154 katı.","en":"On the plain where farming began, 70% of the cropland is affected by salt, one grain gave its lowest harvest in 64 years last season, and rice vanished in 2 years and came back in 2. Into that same plain the neighbour sends 154 times what it takes out.","gerekce":"Cümlenin sırası kullanıcı şartının kendisi (2 Kasım 2026): 'yalnızca Türkiye ile ilişkileri üzerinden bir dosya oluşmasın'. Bu yüzden ÖNCE Irak'ın kendi tarımı — tuz, pirinç, bataklık — SONRA eksen geliyor. Eksen cümlenin sonunda duruyor ama cümleyi yönetmiyor; dosyanın gövdesi Irak'ın kendi toprağı.","_dayanak":"Dört öğenin dördü de ayrı kaynaktan: 'tarımın doğduğu ova' BM Irak Su Görev Gücü'nün 2011 raporundan ('as the birthplace of humanity and agricultural production'), ansiklopedik bilgiden değil (§2.14.1); tuz oranı Dünya Bankası PID P149803'ten (%70); pirincin çöküşü FAOSTAT serisinden HESAPLANMIŞ (2020→2022, %97,5); bataklığın kurutulup geri verilmesi yine BM raporundan (%90'dan fazlası kurutuldu, %38'i geri kazanıldı); 154 kat Comtrade'den.","_ayna_uyarisi":"154 kat TÜRKİYE'NİN BEYANINDAN okunuyor. Irak Comtrade'e muhabir olarak rapor vermiyor; ölçüldü (2016/2018/2020'de sıfır satır, 2022/2024'te bir satır). Cümle 'komşusundan gelen' diyerek Irak'ı özne yapıyor ama rakamın muhabiri Türkiye — metin bunu açıkça yazacak.","_olmayan_iddia":"'Türkiye'nin en büyük tarım pazarı' cümlesi KURULMADI. Comtrade ABD ve Fransa için boş dizi dönüyor (hata değil — boş sonuç sıfır değildir) ve ölçülmemiş bir üstünlük yazılmaz. Cümlenin taşıdığı oran ölçülmüş olan: 154 kat.","_sayi_rakamla":"KURAL DEĞİŞTİ (kullanıcı, 3 Kasım 2026). Dizide tez cümlesinde sayılar YAZIYLA yazılıyordu; bu dosyadan itibaren RAKAMLA yazılıyor. Gerekçe kullanıcının kendi ifadesi: büyük bir sayıyı yazıyla yazmak okuru yoruyor ve rakam zaten daha hızlı okunuyor. Metin gövdesindeki bütün kardinal sayılar ve bölüm göndermeleri de rakama çevrildi; kesir deyimleri (üçte ikisi, yarıya) Türkçede yazıyla yazıldığı için olduğu gibi bırakıldı."},"palet":{"ad":"Hurma ve Nehir","kaynak_fikir":"Palet manzaradan değil, Irak tarımının başka hiçbir yerden gelmeyen iki maddesinden türetildi: hurma ve nehir. Hurma ülkenin kendi ürünü — dosya onun dünya payının %18,9'dan %5,9'a inişini gösteriyor. Nehir ise ülkenin kendi ürünü DEĞİL: Dicle ve Fırat yukarıdan geliyor ve 1946 protokolü o suyun nasıl paylaşılacağını Irak kurulmadan önceki bir düzenle yazıyor. Amber Irak'ın kendi ürünü, mavi yukarıdan gelen su. Renklerin GRAFİKTEKİ işi ise bu ayrımı birebir taşımıyor: ikincil renk burada 'öteki ülke' değil 'ikinci seri' demek — bkz. koyu.ikincil._rol_notu. Üçüncü madde — tuz — renk değil MOTİF oldu: tuz bir madde değil, suyun gidemediği yerde ortaya çıkan biçim.","mod":"KOYU — dosya sayfası her zaman koyu. Uygulamanın açık/koyu tercihini izlemez.","mod_gerekcesi":"Dergi dosyası mantığı: içeri girdiğinizde başka bir yere geldiğinizi anlamalısınız (İspanya'dan devralınan karar). Ana sayfadaki şerit bunun istisnasıdır — sayfanın içinde yaşadığı için açık/koyu izler.","koyu":{"zemin":{"hex":"#12100C","rol":"Sayfa arka planı — gece, alüvyon ovası"},"yuzey":{"hex":"#1F1A12","rol":"Kart, tablo, alıntı bloğu","kontrast_zemin":1.1},"murekkep":{"hex":"#EFE8DA","rol":"Gövde metni","kontrast_zemin":15.59,"kontrast_yuzey":14.18},"sessiz":{"hex":"#A89B84","rol":"Meta, kaynak satırı, altyazı","kontrast_zemin":6.96,"kontrast_yuzey":6.33},"vurgu":{"hex":"#E3A94A","rol":"Hurma — rakamlar, başlık vurguları ve her grafiğin ÖNDEKİ serisi","kontrast_zemin":9.09,"kontrast_yuzey":8.27},"ikincil":{"hex":"#5F93AD","rol":"Nehir — karşılaştırmanın ikinci serisi","kontrast_zemin":5.67,"kontrast_yuzey":5.16,"_rol_notu":"DİZİDEN AYRILAN NOKTA. Öteki ülke dosyalarında ikincil renk 'Türkiye serisi' demekti: karşılaştırma hep iki ülke arasındaydı. Bu dosyada DEĞİL — ikinci seri sayıldı ve hiçbirinde Türkiye yok: arpa, ekilen alan, sığır, hasar sınıfı, ticaretin çıkan yakası. Sebebi kullanıcı şartı: dosya yalnızca Türkiye ilişkisi üzerinden kurulmuyor, gövdesi Irak'ın kendi tarımı. Dolayısıyla iki renk de çoğu grafikte Irak'ı gösteriyor. Künyeye 'Türkiye serisi' yazmak, sonraki turda grafiklerin yanlış okunmasına yol açardı."},"cizgi":{"hex":"#2B2418","rol":"SADECE dekoratif ayırıcı","kontrast_zemin":1.24,"kontrast_yuzey":1.13,"_uyari":"3:1'in altında. Anlam taşıyan hiçbir yerde kullanılamaz — grafik ekseni, sınır, odak halkası için cizgiVurgu kullanılır."},"cizgiVurgu":{"hex":"#7C7158","rol":"Grafik ekseni, ızgara çizgisi, ticaret akışı omurgası, odak halkası","kontrast_zemin":3.95,"kontrast_yuzey":3.59}},"acik_mod_seridi":{"_amac":"Ana sayfadaki dosya şeridi sayfanın içinde yaşıyor; krem zemin üstünde koyu gövdenin renkleri okunmuyor.","murekkep":{"hex":"#19150F","kontrast_krem":16.14},"vurguKoyu":{"hex":"#1D5587","rol":"Nehrin krem zemindeki karşılığı — kart kenarı ve açık moddaki tüm vurgu metni","kontrast_krem":6.91,"_anasayfadan_ayrisma":{"darkGreen_#2F4B2E":1.46,"primaryGreen_#5C8A4A":2.46,"wheat_#C9A15A":4.54,"marketDown_#9C4A3C":1.44,"alertRed_#D32F2F":1.89,"_notu":"Bu beş sayı ÖLÇÜLDÜ, elle yazılmadı — kontrast.py hesaplıyor. Avustralya'nın künyesinde aynı blok vardı ama betikte karşılığı yoktu."}},"ikincilKoyu":{"hex":"#3B1F0C","rol":"Hurmanın krem zemindeki karşılığı — ikinci vurgu","kontrast_krem":13.45,"_anasayfadan_ayrisma":{"darkGreen_#2F4B2E":3.01,"primaryGreen_#5C8A4A":10.82,"wheat_#C9A15A":19.96,"marketDown_#9C4A3C":6.35,"alertRed_#D32F2F":8.31}},"_rol_degisimi":"ŞERİTTE NEHİR ÖNDE, SAYFADA HURMA. Koyu sayfada vurgu hurma amberi (#E3A94A) — dosyanın konusu Irak'ın kendi tarımı. Ama ana sayfa krem ve kendi buğday rengi #C9A15A ile marketDown #9C4A3C aynı sıcak mahallede; hurmanın koyu sürümü oraya düşüyor ve ancak siyaha yaklaşarak ayrışıyor — o noktada da şeridin kendi mürekkebine karışıyor. Nehir mavisi tekerleğin soğuk yarısını tek başına kullanıyor. Renk uydurulmadı, dosyanın kendi ikinci rengi öne alındı. Hangi rengin önde durduğu ZEMİNE bağlı (Avustralya'da da böyle olmuştu, orada ters yönde)."},"renk_korlugu_notu":"HOLLANDA DERSİ BİR ADIM İLERİ GÖTÜRÜLDÜ. Orada sodyum turuncusu ile cam yeşilinin bağıl parlaklık oranı 1,05'ti ve deuteranopi altında ayırt edilemiyorlardı; o günden beri dizide bu oran ölçülüyor. AMA PARLAKLIK ORANI BİR VEKİL ÖLÇÜDÜR VE BU DOSYADA YANILDI: ikinci şerit denemesi (#1C3A54 / #3F240D) normal görmede 1,67 veriyordu — eşiği rahat geçiyor — deuteranopi altında 1,34'e düşüyordu. Bu yüzden kontrast.py artık üç körlük tipini DOĞRUDAN BENZETİYOR (Viénot-Mollon, LMS izdüşümü) ve oranı benzetim sonrasında ölçüyor. Ölçülen değerler düzyazıda değil `_olculen_ayrisma` alanında duruyor: düzyazıya gömülen sayı, paletin bir sonraki değişikliğinde sessizce yanlışa döner ve denetlenmesi için metin kazımak gerekir.","_ikincil_notu":"İlk nehir mavisi #5589A3 idi: zeminde 4,97 ile geçiyor ama YÜZEYDE 4,52 ile eşiğe iki yüzde birlik payla yaklaşıyordu. #5F93AD'ye açıldı (5,67 / 5,16). Eşiği kıl payı geçen bir renk, paletin bir sonraki küçük değişikliğinde sessizce altına düşer.","denetim_betigi":"_raw/kontrast.py — `python3 content/dossiers/irak/_raw/kontrast.py`","_olculen_ayrisma":{"_uretim":"_raw/kontrast.py — elle yazılmaz; dogrula_tasarim.py bu bloğu künyenin kendi hex'lerinden yeniden hesaplayıp karşılaştırır.","_esik":1.4,"_neden_benzetim":"Bağıl parlaklık oranı VEKİL ölçüdür ve bu dosyada yanıldı: #1C3A54 / #3F240D çifti normal görmede 1,67 veriyordu, deuteranopi altında 1,34'e düşüyordu.","govde":{"normal":1.72,"protanopi":1.59,"deuteranopi":1.99,"tritanopi":1.71},"serit":{"normal":4.39,"protanopi":5.17,"deuteranopi":3.5,"tritanopi":4.47}},"_vurgunun_ulasmadigi_yer":"ÖLÇÜLDÜ: `kartlar` türündeki grafiklerde vurgu rengi HİÇ KULLANILMIYOR. Tuzluluk kartının görüntüsünde amber piksel sayısı sıfır. Sebep çizicide: `dossier_chart_view.dart` kart başlığını `tema.murekkep`, üst satırını `tema.sessiz` ile çiziyor ve kartlarda `rol` alanı okumuyor. Bu dosyanın on iki grafiğinin ikisi (tuzluluk, protokol) bu yüzden vurgusuz. KÜNYEDEN DEĞİŞTİRİLEMEZ — değiştirmek ortak çiziciye dokunmayı, yani yayındaki beş dosyanın (Hollanda, Rusya, İspanya, Avustralya, DSİ) kart görünümünü birden değiştirmeyi gerektirir. Bu bir tasarım turu kararı değil, kullanıcı kararıdır ve sorulmadan yapılmaz. Bu dosyada 'tuzluluk rakamları amberle duruyor' gibi bir cümle YAZILMAYACAK."},"motif":{"ad":"Tuz poligonu","tanim":"Drenajı yetmeyen sulama alanında suyun buharlaşmasıyla oluşan tuz kabuğunun düzensiz çokgen ağı: eşit olmayan hücreler, kırık açılar, hiçbiri ötekine benzemeyen kenarlar.","gerekce":"Dizideki beşinci geometri ve ilk kez İNSAN YAPIMI OLMAYAN geometri. Hollanda dikey şerit, Rusya yatay bant, İspanya nokta, Avustralya ızgara — dördü de kazılmış, dikilmiş, ölçülmüş düzenlerdi. Tuz poligonu tasarlanmaz; sulama suyu toprağa girip çıkamadığında kendiliğinden belirir. Dosyanın ölçtüğü şeyin biçimi bu: ekili alanın %70'i tuzdan etkilenmiş, tarihsel olarak sulanmış alanın %40'ı üretim dışı. Dizinin 'bu manzara doğal değil, kazılmış' fikri burada tersine dönüyor — bu desen kazılmanın yetmediği yerde çıkıyor.","uygulama":{"opaklik":"%5","renk":"cizgiVurgu #7C7158 üzerine opaklık","bicim":"Vektör (CustomPainter) — raster değil. Ölçeklenebilir, dosya boyutu sıfır, telif sorunu yok.","yerlesim":"Bölüm ayırıcılarında ve kapak altı geçiş bandında. Gövde metninin ARKASINDA kullanılmaz.","moire_notu":"Hücre ortalama genişliği 28 px'in altına inmeyecek; düzensiz kenarlar ızgaradan daha çok titrer.","_opaklik_notu":"Izgaradan bir puan düşük (%6 → %5): düzensiz çokgen gözü ortogonal ızgaradan daha çok meşgul eder."},"_UYGULANMAMIŞ":"ÖNEMLİ — BU GEOMETRİ ŞU AN ÇİZİLMİYOR. Depodaki tek motif çizici `polder_motif.dart` ve `DossierTheme` motif bloğundan YALNIZCA opaklığı okuyor (`_yuzde`, `motif.uygulama.opaklik`, 0,02–0,10 arasına kırpılıyor). `motifAralik` bile JSON'dan değil yedekten geliyor (28). Avustralya'nın künyesi bunu aynı açıklıkla yazmıştı ve doğru yapmıştı: okunmayan bir alana değer yazmak, sonraki turda 'tuz poligonu bölüm ayırıcılarında görünüyor' diye yanlış bir cümle yazdırır. Tuz poligonu bir ŞARTNAMEDİR; çizici yazılana kadar sayfada polder motifi görünür ve bu dosyada aksini iddia eden cümle yazılmayacak.","_yon_alani_yazilmadi":"İspanya'nın künyesinde 'paylaşım kartı yon alanını okuyor' notu var; kodda karşılığı yok — grep ile doğrulandı, `'yon'` hiçbir yerde okunmuyor. Bu yüzden burada da yazılmadı."},"kapak":{"yon":"Tuzdan etkilenmiş sulama ovası — alçak eğik açıyla havadan; tuz poligonları yüzeyde görünecek kadar yakın","gerekce":"Kapak ile motif aynı şeyi gösteriyor: biri fotoğraf, öteki onun çizgiye indirgenmişi. Hollanda ve Rusya yörüngeden, İspanya yerden, Avustralya yüksekten baktı; burası ikisinin arası — poligon ancak yeterince yakından poligon gibi görünür, ama ancak yeterince yukarıdan ağ gibi.","gorsel_kaynagi":{"tercih_1":"NASA Earth Observatory / ISS astronot fotoğrafı — kamu malı; Mezopotamya ovası ve bataklıklar için arşivi geniş.","tercih_2":"Wikimedia Commons, açık lisanslı havadan çekim.","tercih_3":"FAO / BM fotoğraf kütüphaneleri — LİSANS TEK TEK OKUNACAK, 'BM yayını' açık lisans demek değildir.","_karar":"Görsel BULUNANA KADAR kapak tipografik iskeletle çalışır — sayfa görselsiz de tam çalışmak zorunda (§3.5).","_yasak":"Telifi belirsiz hiçbir görsel kullanılmayacak. Google görsel araması kaynak değildir.","_erisim_uyarisi":"Kaynak turlarında ölçüldü, görsel aramasında bu adreslere gidilmesin: cosit.gov.iq 404, mo-ag.gov.iq 000 (bağlantı kurulmuyor), mowr.gov.iq 200 ama gövde 139 karakter (kabuk), FAO AQUASTAT HTML 200 ama 1.659 karakter (JavaScript kabuğu), IPC 403, UN-ESCWA 403, ReliefWeb API 410, fao.org/3/<belge>.pdf 200 + text/html (YUMUŞAK 404 — durum koduna değil içerik türüne bakılacak)."},"tipografi_katmani":{"ust_satir":"ÜLKE DOSYASI · 05","baslik":"IRAK","alt_satir":"tez_cumlesi.tr","veri_rozeti":"Türkiye'nin tarım ihracatının %14,3'ü tek bir komşuya"},"_rozet_notu":"Rozet 154 katı DEĞİL, %14,3'ü söylüyor. Kat sayısı dosyanın en çarpıcı rakamı ama tek başına okunduğunda Irak'ı küçük gösteriyor; %14,3 ise Irak'ın Türkiye için ne kadar büyük olduğunu söylüyor. Dengesizlik zaten akış grafiğinde çizili.","_baslik_notu":"En uzun kelime başlığın kendisi: 'IRAK' (4 harf). _KapakAdi puntoyu en uzun kelimeye bakarak küçültüyor (§10.4); dört harf dizinin en kısası — İSPANYA 7, AVUSTRALYA 10, KOOPERATİFLERİ 14. Taşma riski yok; ters yönde kontrol edilecek, punto ÜST sınıra dayanabilir.","okunurluk":"Görsel üzerine zemin renginden %0 → %85 dikey gradyan; metin yalnızca %60+ bölgede durur."},"_zorunluluklar":["Grafiklerde iki seri renkle BİRLİKTE biçimle de ayrılacak; bu dosyada parlaklık farkı da var ve üç körlük tipinde benzetilerek ölçüldü (gövdede en kötü 1,59, şeritte en kötü 3,50).","Tuz poligonu motifi CustomPainter ile çizilecek — ama çizici YAZILANA KADAR sayfada polder motifi görünür; bu dosyada aksini iddia eden cümle yazılmayacak.","Kapak görseli bulunamazsa sayfa yine de tam çalışacak.","Koyu sayfa sistem açık/koyu tercihini izlemeyecek; ana sayfa şeridi izleyecek.","Tüm renkler bu dosyadan türetilen DossierTheme üzerinden gelecek, kodda serbest hex yazılmayacak.","Palet değişirse _raw/kontrast.py yeniden çalıştırılacak ve buradaki bütün kontrast, ayrışma ve körlük sayıları güncellenecek.","Ticaret rakamlarını gösteren her görsel öğe rakamların TÜRKİYE'NİN BEYANINDAN olduğunu söyleyecek — Irak muhabir olarak rapor vermiyor."],"_yasak":["Irak bayrağı, arması ya da herhangi bir devlet amblemi","Savaş görüntüsü: asker, tank, yanan petrol kuyusu, patlama, mülteci. Dosyada savaşın tarıma hasarını ölçen bir bölüm var ve o bölüm FAO'nun saha ölçümüne dayanıyor — görsel dil savaş muhabirliğine kaymayacak","IŞİD'e, herhangi bir silahlı örgüte ya da Saddam dönemi ikonografisine ait hiçbir imge","Dinî imge, cami silueti, hat sanatı süslemesi — dosya tarımı anlatıyor","Babil, Ur ya da harabe turizmi klişesi; 'medeniyetin beşiği' kartpostalı. Mezopotamya'nın tarımın doğduğu yer olması METİNDE kaynağıyla duruyor, kapakta dekor olarak değil","Stok 'çatlamış kurak toprak' fotoğrafı — dosya kuraklığı değil TUZLULUĞU ve drenajı anlatıyor; ikisi farklı şeyler","Deve, palmiye silueti, gün batımı — ülke klişesi","Resmî kurum logosu ya da yazı tıpkıbasımı"]}$dsr$::jsonb,
  $dsr${"_dosya":"Irak — Ülke Dosyası Sayı 05 · veri katmanı","_uretim":"build_data.py — elle düzenlenmez","_eksen":"Türkiye'nin tarım ihracatının %14,3'ü tek bir komşuya gidiyor; ters yön 154 kat daha küçük.","_gövde_notu":"Eksen ticaret ama dosyanın gövdesi Irak tarımının kendisi: savaş, su, tuzluluk, pirincin kayboluşu, hurmada kaybedilen yer ve hayvancılık kendi bölümlerini alıyor.","_ayna_siniri":"Bütün ticaret rakamları TÜRKİYE'NİN beyanından. Irak Comtrade'e muhabir olarak rapor vermiyor; metin bunu açıkça yazar.","ticaret":{"_kaynak_niteligi":"BAĞIMSIZ — UN Comtrade, muhabir Türkiye","_kapsam":"HS 01-24 · 2024 · Türkiye'nin beyanı","_ayna_uyarisi":"IRAK KENDİ BEYANINI VERMİYOR. Comtrade'de Irak muhabir olarak 2018'de 0, 2020'de 0, 2022'de 1 satır döndürüyor. Bütün ticaret rakamları Türkiye'nin beyanından okundu ve metinde bu açıkça yazılacak.","yil":2024,"tarim_ihracat_irak":4637303510,"tarim_ihracat_dunya":32541007957,"toplam_ihracat_irak":13001359310,"tarim_ithalat_irak":30197244,"fasillar":[{"fasil":"19","deger":538896931},{"fasil":"08","deger":498258441},{"fasil":"11","deger":496602372},{"fasil":"02","deger":444369283},{"fasil":"07","deger":432799391},{"fasil":"10","deger":408266750},{"fasil":"15","deger":339570443},{"fasil":"23","deger":298121833},{"fasil":"20","deger":182360515},{"fasil":"04","deger":179301541},{"fasil":"18","deger":171549235},{"fasil":"21","deger":168917360},{"fasil":"24","deger":151268681},{"fasil":"17","deger":131457913},{"fasil":"12","deger":74195833},{"fasil":"16","deger":54425489},{"fasil":"22","deger":41246697},{"fasil":"03","deger":8284331},{"fasil":"01","deger":6488556},{"fasil":"06","deger":5361864},{"fasil":"09","deger":5246790},{"fasil":"13","deger":262291},{"fasil":"14","deger":50914},{"fasil":"05","deger":56}],"ithalat_fasillar":[{"fasil":"22","deger":8186775},{"fasil":"10","deger":7885342},{"fasil":"02","deger":3008756},{"fasil":"08","deger":2845523},{"fasil":"20","deger":2791750},{"fasil":"07","deger":2604110},{"fasil":"14","deger":615000},{"fasil":"04","deger":580258},{"fasil":"17","deger":437496},{"fasil":"19","deger":324312},{"fasil":"21","deger":314396},{"fasil":"09","deger":237568},{"fasil":"18","deger":112925},{"fasil":"23","deger":93784},{"fasil":"12","deger":62277},{"fasil":"11","deger":58697},{"fasil":"24","deger":23041},{"fasil":"16","deger":10814},{"fasil":"15","deger":4420}],"irak_muhabir_satir":{"2016":0,"2018":0,"2020":0,"2022":1,"2024":1}},"makro":{"_kaynak_niteligi":"BAĞIMSIZ — Dünya Bankası göstergeleri","_kapsam":"Irak · en yeni dolu yıl; her kalem kendi yılını taşıyor","_sulanan_notu":"Sulanan arazi payı göstergesi Irak için BOŞ dönüyor. Suyun belirleyici olduğu bir ülkede bu kalem yayımlanmıyor; metinde boşluk olarak anılacak.","nufus":{"yil":2025,"deger":47020774},"tarim_gsyh_payi":{"yil":2025,"deger":3.41368848141125},"tarim_arazi_payi":{"yil":2024,"deger":21.6475019003524},"tarim_istihdam_payi":{"yil":2025,"deger":8.16872836237607},"tahil_verimi_kg_ha":{"yil":2024,"deger":2651},"gida_ithalat_payi":{"yil":2024,"deger":14.243534425089},"sulanan_arazi_payi":null,"kirsal_nufus_payi":{"yil":2025,"deger":30.0603260531895},"turkiye":{"tarim_gsyh_payi":{"yil":2025,"deger":5.20951196750004},"tahil_verimi_kg_ha":{"yil":2024,"deger":3428.7},"nufus":{"yil":2025,"deger":85878556}}},"uretim":{"_kaynak_niteligi":"BAĞIMSIZ — FAOSTAT","_kapsam":"Irak · yıllık · ton ve hektar; hayvan varlığı baş","_agrega_notu":"Alan ve ürün agregaları KULLANILMADI; yalnızca tek tek ürünler okundu. Hurmada dünya payı için Area='World' ayrıca alındı — tek kalem, toplama değil.","urunler":{"Barley|Area harvested":{"1961":900000,"1962":1000000,"1963":900000,"1964":800000,"1965":1000000,"1966":1000000,"1967":1000000,"1968":800000,"1969":750000,"1970":600000,"1971":395750,"1972":675000,"1973":464100,"1974":519000,"1975":567300,"1976":575700,"1977":535875,"1978":714324,"1979":760300,"1980":829625,"1981":983875,"1982":1110250,"1983":1216575,"1984":525425,"1985":1356600,"1986":1456000,"1987":972475,"1988":1313850,"1989":913175,"1990":1922100,"1991":1311250,"1992":2012000,"1993":2314000,"1994":1535000,"1995":1389000,"1996":1650000,"1997":1173000,"1998":1213000,"1999":1220000,"2000":1110000,"2001":1200000,"2002":1299640,"2003":1063250,"2004":957000,"2005":1063250,"2006":1026000,"2007":1093750,"2008":429625,"2009":390506,"2010":1005766,"2011":718549,"2012":525625,"2013":813548,"2014":1145814,"2015":265425,"2016":259859,"2017":197625,"2018":134328,"2019":897216,"2020":1123712,"2021":172822,"2022":91144,"2023":120131,"2024":173042},"Barley|Production":{"1961":911194,"1962":1125257,"1963":790328,"1964":622927,"1965":806903,"1966":832090,"1967":855000,"1968":992000,"1969":963000,"1970":682000,"1971":432000,"1972":980000,"1973":462000,"1974":533000,"1975":437000,"1976":579300,"1977":457700,"1978":617200,"1979":571400,"1980":682400,"1981":924700,"1982":902000,"1983":835500,"1984":482000,"1985":1331400,"1986":1046000,"1987":742900,"1988":1436800,"1989":663400,"1990":1854300,"1991":768400,"1992":1509000,"1993":1562000,"1994":971000,"1995":892000,"1996":1300000,"1997":778000,"1998":859000,"1999":500000,"2000":400000,"2001":550000,"2002":1032470,"2003":861000,"2004":805000,"2005":754000,"2006":919000,"2007":748000,"2008":403999,"2009":501508,"2010":1137169,"2011":820152,"2012":831990,"2013":1003198,"2014":1277796,"2015":499222,"2016":499222,"2017":303114,"2018":190647,"2019":1518471,"2020":1756200,"2021":266581,"2022":144493,"2023":105903,"2024":164495},"Dates|Area harvested":{"1985":105000,"1986":122130,"1987":107970,"1988":103370,"1989":119970,"1990":123510,"1991":115670,"1992":116000,"1993":136000,"1994":165000,"1995":168000,"1996":176000,"1997":156000,"1998":144000,"1999":90000,"2000":110000,"2001":101500,"2002":101500,"2003":101500,"2004":54623,"2005":50000,"2006":101500,"2007":105000,"2008":110000,"2009":101500,"2010":123000,"2011":123230,"2012":137458,"2013":195464,"2014":237394,"2015":218750,"2016":243863,"2017":253799,"2018":287020,"2019":246615,"2020":245030,"2021":279000,"2022":284552,"2023":259089,"2024":256758},"Dates|Production":{"1961":350000,"1962":420000,"1963":320000,"1964":310000,"1965":280000,"1966":380000,"1967":330000,"1968":260000,"1969":480000,"1970":300000,"1971":450000,"1972":310000,"1973":385000,"1974":360000,"1975":495608,"1976":371980,"1977":578300,"1978":389030,"1979":519170,"1980":596920,"1981":370180,"1982":373750,"1983":345290,"1984":251440,"1985":390200,"1986":434210,"1987":323540,"1988":356330,"1989":488390,"1990":544930,"1991":566220,"1992":447840,"1993":612580,"1994":675820,"1995":881020,"1996":797450,"1997":750000,"1998":913000,"1999":764000,"2000":932000,"2001":907000,"2002":866000,"2003":868000,"2004":448380,"2005":404030,"2006":432360,"2007":430861,"2008":476318,"2009":507002,"2010":567668,"2011":619182,"2012":655450,"2013":676111,"2014":662447,"2015":602348,"2016":615211,"2017":618818,"2018":646163,"2019":639315,"2020":735353,"2021":750225,"2022":703791.31,"2023":615247.43,"2024":587189.83},"Maize (corn)|Area harvested":{"1961":2000,"1962":2000,"1963":2000,"1964":2000,"1965":2500,"1966":4000,"1967":4000,"1968":3800,"1969":4000,"1970":4800,"1971":9000,"1972":12500,"1973":10000,"1974":7000,"1975":9445,"1976":27355,"1977":31590,"1978":32725,"1979":23475,"1980":23700,"1981":17625,"1982":11925,"1983":15000,"1984":18803,"1985":21417,"1986":26525,"1987":31225,"1988":49150,"1989":46225,"1990":69275,"1991":107975,"1992":129700,"1993":145000,"1994":60000,"1995":63000,"1996":60000,"1997":61000,"1998":61000,"1999":60000,"2000":72750,"2001":98250,"2002":101500,"2003":95250,"2004":185000,"2005":173750,"2006":164500,"2007":155000,"2008":122575,"2009":114050,"2010":113075,"2011":128736,"2012":150516,"2013":196938,"2014":84574,"2015":57260,"2016":66738,"2017":52012,"2018":50000,"2019":100594,"2020":90522,"2021":78042,"2022":82844,"2023":88812,"2024":100000},"Maize (corn)|Production":{"1961":1898,"1962":1983,"1963":2013,"1964":2800,"1965":3658,"1966":4317,"1967":4467,"1968":4389,"1969":4785,"1970":5902,"1971":15919,"1972":17703,"1973":19108,"1974":14639,"1975":23424,"1976":54980,"1977":82210,"1978":74800,"1979":58600,"1980":59600,"1981":39300,"1982":28200,"1983":28100,"1984":30930,"1985":40951,"1986":53000,"1987":61300,"1988":77200,"1989":103600,"1990":171900,"1991":236000,"1992":260000,"1993":280000,"1994":128000,"1995":90000,"1996":125000,"1997":121000,"1998":133000,"1999":115000,"2000":55000,"2001":232000,"2002":248000,"2003":233000,"2004":416000,"2005":401000,"2006":399000,"2007":384000,"2008":287955,"2009":238113,"2010":266699,"2011":335710,"2012":503389,"2013":831345,"2014":289288,"2015":182340,"2016":259546,"2017":185291,"2018":225000,"2019":473064,"2020":419345,"2021":374400,"2022":496003,"2023":538251,"2024":500000},"Rice|Area harvested":{"1961":25000,"1962":40000,"1963":55000,"1964":65000,"1965":65000,"1966":65000,"1967":103000,"1968":109000,"1969":106000,"1970":75000,"1971":109075,"1972":94000,"1973":63960,"1974":31415,"1975":29880,"1976":52407,"1977":63485,"1978":54717,"1979":58700,"1980":55450,"1981":54500,"1982":57625,"1983":48900,"1984":39150,"1985":52525,"1986":50200,"1987":70000,"1988":50475,"1989":72750,"1990":79200,"1991":85925,"1992":95000,"1993":110000,"1994":163000,"1995":175000,"1996":120000,"1997":121000,"1998":128000,"1999":130000,"2000":100000,"2001":100000,"2002":100000,"2003":29500,"2004":88000,"2005":107000,"2006":125750,"2007":124250,"2008":84750,"2009":54925,"2010":47974,"2011":65745,"2012":79471,"2013":95808,"2014":78949,"2015":24390,"2016":37731,"2017":54283,"2018":5423,"2019":127673,"2020":101594,"2021":96185,"2022":3839,"2023":3472,"2024":52372},"Rice|Production":{"1961":68453,"1962":113100,"1963":143216,"1964":184350,"1965":178434,"1966":182087,"1967":314921,"1968":353500,"1969":318000,"1970":180200,"1971":306700,"1972":268000,"1973":156620,"1974":69290,"1975":60540,"1976":163360,"1977":199240,"1978":172000,"1979":157800,"1980":166900,"1981":162200,"1982":163400,"1983":110500,"1984":108700,"1985":148900,"1986":141200,"1987":195900,"1988":140600,"1989":231800,"1990":228800,"1991":189103,"1992":180000,"1993":206000,"1994":383000,"1995":315000,"1996":270000,"1997":244000,"1998":300000,"1999":180000,"2000":60000,"2001":128000,"2002":250000,"2003":90000,"2004":250000,"2005":309000,"2006":363000,"2007":393000,"2008":248157,"2009":173074,"2010":155829,"2011":235118,"2012":361339,"2013":451849,"2014":403028,"2015":109209,"2016":181320,"2017":265852,"2018":18196,"2019":574705,"2020":464159,"2021":422463,"2022":11637,"2023":12602,"2024":227508},"Tomatoes|Area harvested":{"1961":19545,"1962":22162,"1963":22841,"1964":27659,"1965":27613,"1966":28660,"1967":32253,"1968":31543,"1969":29183,"1970":36770,"1971":37250,"1972":43370,"1973":43118,"1974":37898,"1975":44500,"1976":45630,"1977":40625,"1978":40328,"1979":28625,"1980":33550,"1981":40600,"1982":39550,"1983":37025,"1984":41950,"1985":47375,"1986":42925,"1987":41650,"1988":34700,"1989":54425,"1990":54550,"1991":33500,"1992":33000,"1993":56470,"1994":55253,"1995":65000,"1996":70000,"1997":75000,"1998":80000,"1999":87750,"2000":77250,"2001":80000,"2002":84500,"2003":23250,"2004":66500,"2005":67000,"2006":65750,"2007":59500,"2008":59614,"2009":53848,"2010":53195,"2011":61042,"2012":58864,"2013":53628,"2014":34820,"2015":23001,"2016":14279,"2017":13879,"2018":17404,"2019":22892,"2020":31979,"2021":32736,"2022":30607,"2023":21736,"2024":21985},"Tomatoes|Production":{"1961":138695,"1962":140341,"1963":143163,"1964":189147,"1965":195817,"1966":216405,"1967":241371,"1968":232157,"1969":220163,"1970":310680,"1971":383000,"1972":368000,"1973":355205,"1974":349557,"1975":389018,"1976":491842,"1977":401800,"1978":432272,"1979":266600,"1980":347800,"1981":425200,"1982":467900,"1983":439200,"1984":531100,"1985":611800,"1986":523100,"1987":594700,"1988":558400,"1989":709800,"1990":721500,"1991":437900,"1992":410000,"1993":794269,"1994":863489,"1995":870000,"1996":900000,"1997":1021514.52,"1998":1000000,"1999":1113000,"2000":989000,"2001":1321000,"2002":1309000,"2003":234000,"2004":988000,"2005":939000,"2006":1042000,"2007":955000,"2008":802386,"2009":913493,"2010":1013177,"2011":1059537,"2012":768375,"2013":903809,"2014":770564,"2015":388674,"2016":286596,"2017":123611,"2018":467579,"2019":619543,"2020":754759,"2021":744166,"2022":630160,"2023":534821,"2024":463214},"Wheat|Area harvested":{"1961":1100000,"1962":1400000,"1963":850000,"1964":1300000,"1965":1400000,"1966":1300000,"1967":1350000,"1968":1500000,"1969":1300000,"1970":1400000,"1971":948250,"1972":1910000,"1973":1156000,"1974":1633325,"1975":1407650,"1976":1499300,"1977":857600,"1978":1495650,"1979":1077800,"1980":1373975,"1981":1192500,"1982":1168450,"1983":1191325,"1984":492700,"1985":1540225,"1986":1240000,"1987":858975,"1988":1041125,"1989":586850,"1990":1180575,"1991":1832775,"1992":1677000,"1993":2013000,"1994":1806000,"1995":1535000,"1996":1500000,"1997":1405000,"1998":1400000,"1999":1300000,"2000":1200000,"2001":1220000,"2002":1648750,"2003":1713750,"2004":1539750,"2005":2549750,"2006":1513500,"2007":1569900,"2008":917546,"2009":906589,"2010":1383303,"2011":1436614,"2012":1266391,"2013":1811295,"2014":2109455,"2015":924311,"2016":920096,"2017":1047531,"2018":783721,"2019":1543316,"2020":2118691,"2021":1591803,"2022":997587,"2023":1668077,"2024":2029795},"Wheat|Production":{"1961":857350,"1962":1085494,"1963":488254,"1964":807013,"1965":1005288,"1966":825955,"1967":860000,"1968":1537000,"1969":1183000,"1970":1236000,"1971":822300,"1972":2625000,"1973":957000,"1974":1339000,"1975":845400,"1976":1302400,"1977":695700,"1978":909800,"1979":684800,"1980":975600,"1981":902000,"1982":965100,"1983":841000,"1984":470900,"1985":1405500,"1986":1036000,"1987":722200,"1988":929200,"1989":491400,"1990":1195800,"1991":1476400,"1992":1006000,"1993":1187000,"1994":1342000,"1995":1236000,"1996":1300000,"1997":1063000,"1998":1130000,"1999":800000,"2000":384000,"2001":903400,"2002":2589000,"2003":2329000,"2004":1832000,"2005":2228000,"2006":2086000,"2007":2202800,"2008":1255000,"2009":1700390,"2010":2748840,"2011":2808900,"2012":3062312,"2013":4178379,"2014":5055111,"2015":2645061,"2016":3052939,"2017":2974136,"2018":2177885,"2019":4343473,"2020":6238392,"2021":4233714,"2022":2764692,"2023":4247726,"2024":5234171}},"hayvan":{"Buffalo":{"1961":250000,"1962":245000,"1963":240000,"1964":230000,"1965":224622,"1966":240000,"1967":250000,"1968":260000,"1969":270000,"1970":288000,"1971":270000,"1972":250000,"1973":240000,"1974":184000,"1975":161000,"1976":146000,"1977":160000,"1978":170000,"1979":170000,"1980":170000,"1981":175000,"1982":174000,"1983":175000,"1984":170000,"1985":155000,"1986":141483,"1987":140000,"1988":141000,"1989":145000,"1990":150000,"1991":110000,"1992":105000,"1993":108000,"1994":87000,"1995":70000,"1996":50000,"1997":62250,"1998":80000,"1999":90000,"2000":115000,"2001":109000,"2002":120000,"2003":115000,"2004":111000,"2005":213000,"2006":410000,"2007":396000,"2008":285537,"2009":286000,"2010":295000,"2011":302000,"2012":312000,"2013":180662,"2014":187401,"2015":194391,"2016":201642,"2017":209163,"2018":216965,"2019":225058,"2020":233453,"2021":242161,"2022":251194,"2023":260564,"2024":269940},"Cattle":{"1961":1550000,"1962":1550000,"1963":1550000,"1964":1500000,"1965":1454923,"1966":1520000,"1967":1600000,"1968":1650000,"1969":1730000,"1970":1830000,"1971":1860000,"1972":1880000,"1973":1900000,"1974":2048000,"1975":1850000,"1976":1804000,"1977":1804235,"1978":1698000,"1979":1697665,"1980":1702000,"1981":1670000,"1982":1675000,"1983":1685000,"1984":1698000,"1985":1635000,"1986":1578418,"1987":1580000,"1988":1600000,"1989":1578000,"1990":1520000,"1991":1000000,"1992":1260000,"1993":1480000,"1994":1354380,"1995":1190000,"1996":1050000,"1997":1300375,"1998":1320000,"1999":1325000,"2000":1350000,"2001":1458000,"2002":1500000,"2003":1425000,"2004":1516000,"2005":1648000,"2006":1130000,"2007":1145000,"2008":1580000,"2009":2552000,"2010":2629000,"2011":2707000,"2012":2720000,"2013":2780000,"2014":2900000,"2015":1823184,"2016":1860887,"2017":1899370,"2018":1938649,"2019":1978740,"2020":2019660,"2021":2061427,"2022":2104057,"2023":2147569,"2024":2104351},"Chickens":{"1961":6500,"1962":7100,"1963":7500,"1964":7900,"1965":5290,"1966":5394,"1967":7000,"1968":8500,"1969":10000,"1970":11861,"1971":12400,"1972":13000,"1973":13900,"1974":14700,"1975":15404,"1976":15500,"1977":15395,"1978":20500,"1979":22000,"1980":27000,"1981":30000,"1982":70000,"1983":50000,"1984":55000,"1985":65000,"1986":70000,"1987":75000,"1988":76000,"1989":105000,"1990":80000,"1991":3600,"1992":11000,"1993":10500,"1994":15500,"1995":16800,"1996":17300,"1997":19000,"1998":20000,"1999":22000,"2000":23000,"2001":28000,"2002":32000,"2003":24000,"2004":30000,"2005":37000,"2006":40000,"2007":45000,"2008":27500,"2009":27000,"2010":34000,"2011":38000,"2012":38000,"2013":51198,"2014":37968,"2015":44802,"2016":44753,"2017":50073,"2018":54161,"2019":74302,"2020":78534,"2021":144702,"2022":162496,"2023":150905,"2024":140000},"Goats":{"1961":2600000,"1962":2400000,"1963":2200000,"1964":2000000,"1965":1845488,"1966":2000000,"1967":2100000,"1968":2150000,"1969":2200000,"1970":2301000,"1971":2350000,"1972":2400000,"1973":2500000,"1974":2584000,"1975":2785000,"1976":2989000,"1977":2320000,"1978":2059000,"1979":2060000,"1980":2080000,"1981":1950000,"1982":1680000,"1983":1800000,"1984":1610000,"1985":1550000,"1986":1475473,"1987":1500000,"1988":1550000,"1989":1476000,"1990":1550000,"1991":1070000,"1992":1250000,"1993":1550000,"1994":1425000,"1995":1450000,"1996":1105000,"1997":1465773,"1998":1450000,"1999":1400000,"2000":1300000,"2001":743000,"2002":740000,"2003":715000,"2004":549000,"2005":523000,"2006":645000,"2007":1078000,"2008":1095000,"2009":1475000,"2010":1519000,"2011":1565000,"2012":1612000,"2013":1195675,"2014":1216898,"2015":1238498,"2016":1260481,"2017":1282856,"2018":1305627,"2019":1328802,"2020":1352388,"2021":1376393,"2022":1400824,"2023":1425689,"2024":1353075},"Sheep":{"1961":9450000,"1962":9700000,"1963":10000000,"1964":10500000,"1965":11040205,"1966":11850000,"1967":12000000,"1968":13100000,"1969":12900000,"1970":13099000,"1971":11955000,"1972":10810000,"1973":9670000,"1974":8526000,"1975":8470000,"1976":8400939,"1977":9500000,"1978":9723301,"1979":9775000,"1980":11000000,"1981":11750000,"1982":10865000,"1983":10491000,"1984":9723000,"1985":8500000,"1986":8981260,"1987":9000000,"1988":9000000,"1989":8981000,"1990":9600000,"1991":5800000,"1992":7525000,"1993":9500000,"1994":8400000,"1995":7400000,"1996":5850000,"1997":6583940,"1998":6900000,"1999":6000000,"2000":6900000,"2001":6045000,"2002":6100000,"2003":6255000,"2004":4473000,"2005":4449000,"2006":5200000,"2007":6371000,"2008":7722375,"2009":7945000,"2010":7945000,"2011":8183000,"2012":8200000,"2013":6515825,"2014":6545146,"2015":6574599,"2016":6604185,"2017":6633904,"2018":6663757,"2019":6693744,"2020":6723866,"2021":6754123,"2022":6784517,"2023":6815047,"2024":6672540}},"hurma_dunya":{"1961":1852592,"1962":1809091,"1963":1839908,"1964":1830017,"1965":1880697,"1966":1890977,"1967":1866065,"1968":1821545,"1969":2126069,"1970":1881730,"1971":2109412,"1972":2031918,"1973":2179223,"1974":2289511,"1975":2423988,"1976":2256881,"1977":2659513,"1978":2459666,"1979":2683037,"1980":2659406,"1981":2372927,"1982":2601013,"1983":2685466,"1984":2631789,"1985":2819692,"1986":2966905,"1987":3051401,"1988":3155783,"1989":3430585,"1990":3430883,"1991":3698097.66,"1992":3646283.07,"1993":4376303.73,"1994":4560233.91,"1995":4841171.31,"1996":5009027.75,"1997":5078668.84,"1998":5722449.44,"1999":5936812.38,"2000":6428510.66,"2001":6646474.23,"2002":6705509.05,"2003":6733536.96,"2004":6609306.51,"2005":6533418.79,"2006":6750896.49,"2007":6939258.06,"2008":6994187.91,"2009":7158799.58,"2010":7501487.57,"2011":7236739.05,"2012":7400718.83,"2013":7489629.08,"2014":7395470.13,"2015":8060627.64,"2016":8281356.3,"2017":8366406.24,"2018":8721160.1,"2019":9164462.25,"2020":9413914.12,"2021":9784676.73,"2022":9201136.7,"2023":9968278.21,"2024":9946598.04}},"protokol":{"_kaynak_niteligi":"BİRİNCİL — TBMM S. Sayısı 241, 1947 onay tasarısı; antlaşma ve protokol metinleri ek olarak basılı","_kapsam":"Türkiye–Irak · 29 Mart 1946 · yürürlüğe giriş 1947","imza_tarihi":"29 Mart 1946","baslik":"DÎCLE, FIRAT VE KOLLARI SULARININ DÜZENE KONMASI PROTOKOLÜ","protokol_sayisi":6,"harcamalar_irakta":"bütün harcamaları Irak tarafından yüklenilecek","gozetleme_istasyonu":"Türkiye daimî gözetleme istasyonları kuracak","gider_yarisi":"Türkiye ve Irak tarafından yarı","telgraf_istasyonlari":"Dicle üzerindeki Diyarbakır, Cizre","keban":"Fırat üzerindeki Keban","turkiyenin_kendi_kullanimi":"Türkiye'nin sulama ve enerji elde etme maksadiyle onlardan faydalanması bakımından ayrı bir Anlaşmaya konu teşkil eyliyecektir","haber_verme":"Irak'a haber vermeyi kabul eyler","_keban_notu":"Keban 1946'da bir TELGRAF GÖZLEM İSTASYONU olarak geçiyor. Kurum Dosyası Sayı 05 (DSİ) aynı Keban'ı GAP'ın Fırat üzerindeki beş barajından biri sayıyor."},"savas":{"_kaynak_niteligi":"BAĞIMSIZ — FAO, Iraq Agriculture and Livelihoods Needs Assessment, Şubat 2016","_kapsam":"Kerkük, Ninova ve Selahaddin · yeni kurtarılmış alanlar · saha ölçümü","ninova_bugday":"In Ninewa on average 32% of acres dedicated to wheat cultivations were badly damaged resulting in a lower yields, and 68% was completely lost","ninova_arpa":"43% of the acres used for barley were damaged while 57% was completely destroyed","selahaddin":"About 70 to 80% of cultivated area with corn, wheat, and barley was damaged","sebepler":"massive displacement of the local population, looting and destruction of silos and seed and fertilizer storage facilities as well as the collapse of government support in providing inputs","ninova_bugday_agir_hasar_yuzde":32,"ninova_bugday_tam_kayip_yuzde":68,"ninova_arpa_hasar_yuzde":43,"ninova_arpa_tam_kayip_yuzde":57},"su":{"_kaynak_niteligi":"BAĞIMSIZ — Dünya Bankası, PID P149803 (2014)","_kapsam":"Irak · 2014 tarihli proje belgesi","dis_bagimlilik":"Iraq is heavily dependent on the external water resources that are not subject to well-established cross-border agreements","devre_disi_alan":"almost 40 percent of historically-irrigated areas out of production","tuzluluk":"70 percent of crop land is affected by high soil salinity","petrol_disi_gsyh":"The agricultural sector contributes to 35 percent of","devre_disi_yuzde":40,"tuzluluk_yuzde":70,"petrol_disi_gsyh_payi_yuzde":35,"_iki_payda_uyarisi":"Dünya Bankası API'si tarımın TOPLAM GSYH payını veriyor; bu belge PETROL DIŞI GSYH payını veriyor. İkisi çelişmiyor, paydaları farklı. Yalnızca birini yazmak Irak'ta tarımın yerini yanlış gösterir."},"dunya_su":{"_kaynak_niteligi":"BAĞIMSIZ — FAO, Review of World Water Resources by Country (AQUASTAT Water Reports 23)","_kapsam":"Dünya · ülke listesi","_tarih_uyarisi":"Belge ESKİ. Metinde yılı belirtilmeden kullanılmayacak; güncel bir rakam yerine NİTEL bir tespit için var.","yarisindan_fazlasi_disaridan":"other countries for over 50 percent of their renewable water resources","irak_listede":"Iraq"},"bataklik":{"_kaynak_niteligi":"BİRİNCİL — United Nations Integrated Water Task Force for Iraq, \"Managing Change in the Marshlands: Iraq's Critical Challenge\", BM Beyaz Kitap, 2011","_kapsam":"Güney Irak bataklıkları · 1970–2011 · BATAKLIK ölçeği","_olcek_uyarisi":"BU BLOĞUN RAKAMLARI BATAKLIK ÖLÇEĞİNDE. FAOSTAT'ın manda serisi ÜLKE ölçeğinde ve aynı yıl (2011) 302.000 baş veriyor; bu rapor bataklıkta ~5.000 diyor. Çelişki değil, farklı kapsam. Aynı cümlede kullanılmaz.","yayin_yili":2011,"kurutma_orani":"over 90% of the original Marshlands area were drained or destroyed","kurutma_donemi":"Since the 1970s and up to 2003","geri_kazanim":"roughly 38 per cent of the original Marshlands area has been restored","manda_onemi":"the most important animal in the Marshlands","manda_bataklik":"from a high 80,000 to a current meager","tarimin_dogusu":"as the birthplace of humanity and agricultural production","tuzluluk_iki_kat":"has doubled in salinity in recent years","tur_kaybi":"the variety of species also decreased from 70 to only 10","sulanan_alan_2006":"served 232,000 ha","yerel_urunler":"to harvest food grains such as rice and millet"},"gen_bankasi":{"_kaynak_niteligi":"BİRİNCİL — United Nations in Iraq / FAO Irak duyurusu, 19 Mayıs 2024","_kapsam":"Bağdat Ebu Garib tohum bankası ve Süleymaniye · 2024 projesi","_yazilmayacak":"Bankanın 2003'te yok edildiği, sınırdan kaçırılan bir yedek koleksiyon ve kaybedilen çeşit sayısı BU ARAŞTIRMADA birincil kaynağa bağlanamadı. Metin bu iddiaların hiçbirini kurmaz.","yil":2024,"banka":"the Abu Gharib seed bank in Baghdad","calisma_yili":"operational since 1977","hasar":"suffered from infrastructural damage","icarda":"International Center for Agricultural Research in the Dry Areas","yeni_banka":"establish a new seed bank in the Kurdistan Region of Iraq","amac":"conservation of plant genetic material in Iraq"},"turetilmis":{"_kaynak_niteligi":"TÜRETİLMİŞ — yukarıdaki blokların hesabı","_kapsam":"Türetilmiş; her satırın kapsamı kendi kaynağınınkidir","irak_payi_yuzde":14.3,"dengesizlik_kat":154,"tarimin_toplam_ihracattaki_payi_yuzde":35.7,"ekmek_zinciri_usd":1443766053,"ekmek_zinciri_payi_yuzde":31.1,"arpa_alan_2020":1123712,"arpa_alan_2022":91144,"hurma_1961":350000,"hurma_2024":587189.83,"hurma_zirve_yil":2000,"hurma_zirve":932000,"ithalat_toplam_kontrol":30197244,"verim_bugday":{"ilk_yil":1961,"son_yil":2024,"verim_ilk":0.78,"verim_son":2.58,"verim_kat":3.31,"alan_ilk":1100000,"alan_son":2029795,"alan_kat":1.85},"verim_arpa":{"ilk_yil":1961,"son_yil":2024,"verim_ilk":1.01,"verim_son":0.95,"verim_kat":0.94,"alan_ilk":900000,"alan_son":173042,"alan_kat":0.19},"verim_pirinc":{"ilk_yil":1961,"son_yil":2024,"verim_ilk":2.74,"verim_son":4.34,"verim_kat":1.59,"alan_ilk":25000,"alan_son":52372,"alan_kat":2.09},"verim_hurma":{"ilk_yil":1985,"son_yil":2024,"verim_ilk":3.72,"verim_son":2.29,"verim_kat":0.62,"alan_ilk":105000,"alan_son":256758,"alan_kat":2.45},"verim_misir":{"ilk_yil":1961,"son_yil":2024,"verim_ilk":0.95,"verim_son":5,"verim_kat":5.27,"alan_ilk":2000,"alan_son":100000,"alan_kat":50},"verim_domates":{"ilk_yil":1961,"son_yil":2024,"verim_ilk":7.1,"verim_son":21.07,"verim_kat":2.97,"alan_ilk":19545,"alan_son":21985,"alan_kat":1.12},"tavuk_1961":6500,"tavuk_2024":140000,"tavuk_zirve_yil":2022,"tavuk_zirve":162496,"tavuk_kat":21.5,"misir_alan_1961":2000,"misir_alan_2024":100000,"misir_2024":500000,"misir_zirve_yil":2013,"misir_zirve":831345,"domates_zirve_yil":2001,"domates_zirve":1321000,"domates_2024":463214,"domates_1961":138695,"pirinc_dusus_yuzde":97.5,"pirinc_2020":464159,"pirinc_2022":11637,"arpa_dusus_yuzde":91.8,"arpa_en_dusuk_yil":2023,"arpa_en_dusuk":105903,"arpa_2020":1756200,"arpa_2024":164495,"arpa_bugun_2020_yuzdesi":9.4,"pirinc_2024":227508,"pirinc_bugun_2020_yuzdesi":49,"pirinc_alan_2020":101594,"pirinc_alan_2022":3839,"bugday_en_dusuk_yil":2000,"bugday_en_dusuk":384000,"bugday_2014":5055111,"bugday_2015":2645061,"bugday_isid_dusus_yuzde":47.7,"manda_dip_yil":1996,"manda_dip":50000,"manda_bugun":269940,"manda_dipten_kat":5.4,"manda_1990_degisim_yuzde":80,"koyun_1990_degisim_yuzde":-30.5,"koyun_zirve_yil":1968,"koyun_zirve":13100000,"koyun_bugun":6672540,"keci_1990_degisim_yuzde":-12.7,"sigir_1990_degisim_yuzde":38.4,"bataklik_manda_payi_2011_yuzde":1.7,"manda_ulke_2011":302000,"hurma_ilk_yil":1961,"hurma_son_yil":2024,"hurma_pay_ilk_yuzde":18.9,"hurma_pay_son_yuzde":5.9,"hurma_irak_kat":1.7,"hurma_dunya_kat":5.4,"hurma_pay_serisi":{"1961":18.89,"1962":23.22,"1963":17.39,"1964":16.94,"1965":14.89,"1966":20.1,"1967":17.68,"1968":14.27,"1969":22.58,"1970":15.94,"1971":21.33,"1972":15.26,"1973":17.67,"1974":15.72,"1975":20.45,"1976":16.48,"1977":21.74,"1978":15.82,"1979":19.35,"1980":22.45,"1981":15.6,"1982":14.37,"1983":12.86,"1984":9.55,"1985":13.84,"1986":14.64,"1987":10.6,"1988":11.29,"1989":14.24,"1990":15.88,"1991":15.31,"1992":12.28,"1993":14,"1994":14.82,"1995":18.2,"1996":15.92,"1997":14.77,"1998":15.95,"1999":12.87,"2000":14.5,"2001":13.65,"2002":12.91,"2003":12.89,"2004":6.78,"2005":6.18,"2006":6.4,"2007":6.21,"2008":6.81,"2009":7.08,"2010":7.57,"2011":8.56,"2012":8.86,"2013":9.03,"2014":8.96,"2015":7.47,"2016":7.43,"2017":7.4,"2018":7.41,"2019":6.98,"2020":7.81,"2021":7.67,"2022":7.65,"2023":6.17,"2024":5.9},"_ortak_yil_notu":"Comtrade 2024 · FAOSTAT 2024 · Dünya Bankası kalem kalem değişiyor. Karşılaştırma ortak yıldan kurulur, ileri not atlanmaz.","comtrade_yil":2024,"faostat_son_yil":2024}}$dsr$::jsonb,
  $dsr${"fasillar":{"tur":"siralama","baslik":{"tr":"Türkiye Irak'a ne satıyor","en":"What Türkiye sells Iraq"},"birim":{"tr":"milyon dolar · 2024","en":"million dollars · 2024"},"bolen":1000000,"ondalik":1,"onek":{"tr":"$","en":"$"},"not":{"tr":"HS 01-24 fasıllarının en büyük onu; toplam 4,64 milyar dolar. Rakamlar TÜRKİYE'NİN beyanından: Irak Comtrade'e muhabir olarak rapor vermiyor. Çift sayıma karşı gümrük rejimi, taşıma türü ve ikinci partner boyutları süzüldü.","en":"The ten largest of the HS 01-24 chapters; 4.64 billion dollars in total. The figures come from TÜRKİYE's reporting: Iraq does not report to Comtrade. Customs procedure, mode of transport and second-partner dimensions were filtered against double counting."},"kaynak":"UN Comtrade, 2024 · muhabir Türkiye","satirlar":[{"etiket":{"tr":"Hamur işleri ve bisküvi","en":"Bakery and pasta"},"deger":538896931,"rol":"vurgu"},{"etiket":{"tr":"Meyve ve yemiş","en":"Fruit and nuts"},"deger":498258441,"rol":"sessiz"},{"etiket":{"tr":"Un ve değirmen ürünleri","en":"Flour and milling products"},"deger":496602372,"rol":"vurgu"},{"etiket":{"tr":"Et","en":"Meat"},"deger":444369283,"rol":"sessiz"},{"etiket":{"tr":"Sebze","en":"Vegetables"},"deger":432799391,"rol":"sessiz"},{"etiket":{"tr":"Hububat","en":"Cereals"},"deger":408266750,"rol":"vurgu"},{"etiket":{"tr":"Katı ve sıvı yağ","en":"Fats and oils"},"deger":339570443,"rol":"sessiz"},{"etiket":{"tr":"Yem artıkları","en":"Feed residues"},"deger":298121833,"rol":"sessiz"},{"etiket":{"tr":"İşlenmiş sebze-meyve","en":"Processed fruit and veg"},"deger":182360515,"rol":"sessiz"},{"etiket":{"tr":"Süt ürünleri, yumurta ve bal","en":"Dairy, eggs and honey"},"deger":179301541,"rol":"sessiz"}]},"akis":{"tur":"ticaret_akisi","baslik":{"tr":"Hat tek yönlü","en":"The line runs one way"},"birim":{"tr":"milyon dolar · 2024","en":"million dollars · 2024"},"bolen":1000000,"ondalik":1,"onek":{"tr":"$","en":"$"},"giren_basligi":{"tr":"Türkiye'den Irak'a","en":"From Türkiye to Iraq"},"cikan_basligi":{"tr":"Irak'tan Türkiye'ye","en":"From Iraq to Türkiye"},"not":{"tr":"Merkezde Irak duruyor ama rakamların ikisi de TÜRKİYE'NİN BEYANINDAN: Irak Comtrade'e muhabir olarak rapor vermiyor. İki yaka aynı cetvelle ölçülüyor; çıkan yakanın şeritleri bu yüzden neredeyse görünmüyor. Toplamda giren 4,64 milyar dolar, çıkan 30,2 milyon — oran 154 kat. Her iki yakada da en büyük altı fasıl gösteriliyor; farkın SEBEBİ bu grafikten okunmaz, yalnızca ölçüsü.","en":"Iraq stands at the centre but both sets of figures come from TÜRKİYE'S REPORTING: Iraq does not report to Comtrade. Both sides are measured against the same ruler, which is why the outbound bars are barely visible. In total 4.64 billion dollars inbound against 30.2 million outbound — a factor of 154. The six largest chapters are shown on each side; the chart gives the size of the gap, not its cause."},"kaynak":"UN Comtrade, 2024 · muhabir Türkiye","merkez":{"etiket":{"tr":"Irak","en":"Iraq"}},"giren":[{"etiket":{"tr":"Hamur işleri ve bisküvi","en":"Bakery and pasta"},"deger":538896931,"rol":"vurgu"},{"etiket":{"tr":"Meyve ve yemiş","en":"Fruit and nuts"},"deger":498258441,"rol":"sessiz"},{"etiket":{"tr":"Un ve değirmen ürünleri","en":"Flour and milling products"},"deger":496602372,"rol":"vurgu"},{"etiket":{"tr":"Et","en":"Meat"},"deger":444369283,"rol":"sessiz"},{"etiket":{"tr":"Sebze","en":"Vegetables"},"deger":432799391,"rol":"sessiz"},{"etiket":{"tr":"Hububat","en":"Cereals"},"deger":408266750,"rol":"sessiz"}],"cikan":[{"etiket":{"tr":"İçecek","en":"Beverages"},"deger":8186775,"rol":"ikincil"},{"etiket":{"tr":"Hububat","en":"Cereals"},"deger":7885342,"rol":"ikincil"},{"etiket":{"tr":"Et","en":"Meat"},"deger":3008756,"rol":"ikincil"},{"etiket":{"tr":"Meyve ve yemiş","en":"Fruit and nuts"},"deger":2845523,"rol":"ikincil"},{"etiket":{"tr":"İşlenmiş sebze-meyve","en":"Processed fruit and veg"},"deger":2791750,"rol":"ikincil"},{"etiket":{"tr":"Sebze","en":"Vegetables"},"deger":2604110,"rol":"ikincil"}]},"acilis":{"tur":"kunye","baslik":{"tr":"Dosyanın dört rakamı","en":"Four figures from this dossier"},"not":{"tr":"Rakamların hepsi Türkiye'nin beyanından ve Dünya Bankası'ndan; Irak'ın kendi istatistik kurumu bu araştırmaya kapalıydı.","en":"All figures come from Türkiye's reporting and from the World Bank; Iraq's own statistical office was closed to this research."},"kaynak":"UN Comtrade 2024 · Dünya Bankası","kalemler":[{"deger":14.3,"ondalik":1,"sonek":{"tr":"%","en":"%"},"etiket":{"tr":"Türkiye'nin tarım ihracatının Irak'a giden payı","en":"share of Türkiye's agricultural exports going to Iraq"},"alt":{"tr":"2024","en":"2024"}},{"deger":154,"ondalik":0,"sonek":{"tr":"×","en":"×"},"etiket":{"tr":"gidenin gelene oranı","en":"ratio of outbound to inbound"},"alt":{"tr":"2024 · HS 01-24","en":"2024 · HS 01-24"}},{"deger":47020774,"bolen":1000000,"ondalik":1,"etiket":{"tr":"Irak nüfusu, milyon","en":"Iraq's population, million"},"alt":{"tr":"2025","en":"2025"}},{"deger":97.5,"ondalik":1,"sonek":{"tr":"%","en":"%"},"etiket":{"tr":"Irak'ın pirinç üretimindeki düşüş","en":"fall in Iraq's rice production"},"alt":{"tr":"2020 → 2022","en":"2020 → 2022"}}]},"bugunku_irak":{"tur":"kunye","baslik":{"tr":"Petrol ülkesinde tarımın yeri","en":"Where agriculture stands in an oil economy"},"not":{"tr":"Tarımın payı İKİ FARKLI PAYDAYLA ölçülüyor ve ikisi de doğru: toplam gayrisafi yurt içi hasılanın %3,41'i, petrol dışı hasılanın %35'i. Yalnızca birincisi yazılsaydı tarımın yeri olduğundan küçük görünürdü.","en":"Agriculture's share is measured against TWO different denominators and both are correct: 3.41% of gross domestic product, 35% of non-oil output. Giving only the first would make agriculture look smaller than it is."},"kaynak":"Dünya Bankası göstergeleri · Dünya Bankası PID P149803 (2014)","kalemler":[{"deger":3.41368848141125,"ondalik":2,"sonek":{"tr":"%","en":"%"},"etiket":{"tr":"tarımın toplam GSYH payı","en":"agriculture in total GDP"},"alt":{"tr":"2025","en":"2025"}},{"deger":35,"ondalik":0,"sonek":{"tr":"%","en":"%"},"etiket":{"tr":"tarımın PETROL DIŞI hasıladaki payı","en":"agriculture in NON-OIL output"},"alt":{"tr":"2014","en":"2014"}},{"deger":8.16872836237607,"ondalik":1,"sonek":{"tr":"%","en":"%"},"etiket":{"tr":"tarımda çalışanların payı","en":"share employed in agriculture"},"alt":{"tr":"2025","en":"2025"}},{"deger":14.243534425089,"ondalik":1,"sonek":{"tr":"%","en":"%"},"etiket":{"tr":"gıdanın mal ithalatındaki payı","en":"food in merchandise imports"},"alt":{"tr":"2024","en":"2024"}}]},"savas_hasari":{"tur":"ikili_cubuk","baslik":{"tr":"Ninova'da tarlaya ne oldu","en":"What happened to the fields in Nineveh"},"not":{"tr":"FAO'nun Şubat 2016 saha değerlendirmesi. Her satır kendi içinde %100'e tamamlanıyor: ağır hasarlı alan düşük verim verdi, tamamen kayıp alan hiç vermedi. Selahaddin'de mısır, buğday ve arpa alanının %70-80'i hasarlı ya da yok.","en":"FAO's field assessment of February 2016. Each row sums to 100% within itself: the badly damaged area yielded less, the completely lost area nothing at all. In Salahadin 70-80% of the area under maize, wheat and barley was damaged or destroyed."},"kaynak":"FAO · Iraq Agriculture and Livelihoods Needs Assessment, Şubat 2016","sonek":{"tr":"%","en":"%"},"ondalik":0,"seriler":[{"ad":{"tr":"ağır hasarlı","en":"badly damaged"},"rol":"ikincil"},{"ad":{"tr":"tamamen kayıp","en":"completely lost"},"rol":"vurgu"}],"satirlar":[{"etiket":{"tr":"Buğday","en":"Wheat"},"degerler":[32,68]},{"etiket":{"tr":"Arpa","en":"Barley"},"degerler":[43,57]}]},"uc_sok":{"tur":"cizgi","baslik":{"tr":"Üç şok, tek seri","en":"Three shocks, one series"},"birim":{"tr":"bin ton · yıllık üretim","en":"thousand tonnes · annual production"},"bolen":1000,"ondalik":0,"not":{"tr":"1961'den bugüne. Buğdayın en düşük yılı 2000 — ambargo dibi, 384 bin ton. 2014'te 5.055 bin tona çıkıyor, ertesi yıl 2.645 bine, yani yarıya iniyor. ARPADA ASIL KIRILMA DAHA YENİ: serinin altmış dört yılı içinde en düşük yıl ambargo değil 2023, 106 bin ton. 2020'de 1.756 bin tondu; 2024'te 164 bin, yani 2020'nin onda biri bile değil. İki tahıl aynı tarlada ama aynı eğriyi izlemiyor. Grafik şokların NE ZAMAN olduğunu gösterir, sebeplerini kendi başına kanıtlamaz.","en":"From 1961 to today. Wheat's lowest year is 2000 — the embargo trough, 384 thousand tonnes. It reaches 5,055 thousand in 2014 and halves to 2,645 the next year. BARLEY'S REAL BREAK IS MORE RECENT: across sixty-four years its lowest year is not the embargo but 2023, at 106 thousand tonnes. In 2020 it was 1,756 thousand; in 2024, 164 thousand — less than a tenth of 2020. The two grains share a field but not a curve. The chart shows WHEN the shocks happened; it does not by itself prove their causes."},"kaynak":"FAOSTAT · Irak üretimi","seriler":[{"ad":{"tr":"Buğday","en":"Wheat"},"rol":"vurgu","noktalar":{"harita":{"1961":857350,"1962":1085494,"1963":488254,"1964":807013,"1965":1005288,"1966":825955,"1967":860000,"1968":1537000,"1969":1183000,"1970":1236000,"1971":822300,"1972":2625000,"1973":957000,"1974":1339000,"1975":845400,"1976":1302400,"1977":695700,"1978":909800,"1979":684800,"1980":975600,"1981":902000,"1982":965100,"1983":841000,"1984":470900,"1985":1405500,"1986":1036000,"1987":722200,"1988":929200,"1989":491400,"1990":1195800,"1991":1476400,"1992":1006000,"1993":1187000,"1994":1342000,"1995":1236000,"1996":1300000,"1997":1063000,"1998":1130000,"1999":800000,"2000":384000,"2001":903400,"2002":2589000,"2003":2329000,"2004":1832000,"2005":2228000,"2006":2086000,"2007":2202800,"2008":1255000,"2009":1700390,"2010":2748840,"2011":2808900,"2012":3062312,"2013":4178379,"2014":5055111,"2015":2645061,"2016":3052939,"2017":2974136,"2018":2177885,"2019":4343473,"2020":6238392,"2021":4233714,"2022":2764692,"2023":4247726,"2024":5234171}}},{"ad":{"tr":"Arpa","en":"Barley"},"rol":"ikincil","noktalar":{"harita":{"1961":911194,"1962":1125257,"1963":790328,"1964":622927,"1965":806903,"1966":832090,"1967":855000,"1968":992000,"1969":963000,"1970":682000,"1971":432000,"1972":980000,"1973":462000,"1974":533000,"1975":437000,"1976":579300,"1977":457700,"1978":617200,"1979":571400,"1980":682400,"1981":924700,"1982":902000,"1983":835500,"1984":482000,"1985":1331400,"1986":1046000,"1987":742900,"1988":1436800,"1989":663400,"1990":1854300,"1991":768400,"1992":1509000,"1993":1562000,"1994":971000,"1995":892000,"1996":1300000,"1997":778000,"1998":859000,"1999":500000,"2000":400000,"2001":550000,"2002":1032470,"2003":861000,"2004":805000,"2005":754000,"2006":919000,"2007":748000,"2008":403999,"2009":501508,"2010":1137169,"2011":820152,"2012":831990,"2013":1003198,"2014":1277796,"2015":499222,"2016":499222,"2017":303114,"2018":190647,"2019":1518471,"2020":1756200,"2021":266581,"2022":144493,"2023":105903,"2024":164495}}}]},"pirinc":{"tur":"cizgi","baslik":{"tr":"Kapatılıp açılan ürün","en":"A crop switched off and on"},"birim":{"tr":"bin ton ve bin hektar","en":"thousand tonnes and thousand hectares"},"bolen":1000,"ondalik":0,"not":{"tr":"Pirinç suda yetişir; su kıtlığı en net ondan okunur. Üretim 2020'de 464 bin ton, 2022'de 12 bin ton — %97,5 düşüş. Ekilen alan da aynı yönde: 102 bin hektardan 4 bine. Kayıp verimden değil ALANDAN geliyor. Ama 2024'te üretim 228 bin tona döndü, yani 2020'nin yarısına. Dört yılda inip çıkan bir eğri terk edilmiş bir ürünü değil, AÇILIP KAPATILAN bir ürünü gösterir. Grafik bunun kimin kararıyla olduğunu söylemez.","en":"Rice grows in water, so water scarcity reads most clearly from it. Output was 464 thousand tonnes in 2020 and 12 thousand in 2022 — a fall of 97.5%. The harvested area moved the same way: from 102 thousand hectares to 4 thousand. The loss comes from AREA, not yield. But in 2024 output returned to 228 thousand tonnes, half of the 2020 level. A curve that falls and rises within four years shows a crop being switched off and on, not one abandoned. The chart does not say whose decision that was."},"kaynak":"FAOSTAT · Irak","seriler":[{"ad":{"tr":"Üretim (bin ton)","en":"Production (thousand t)"},"rol":"vurgu","noktalar":{"harita":{"1961":68453,"1962":113100,"1963":143216,"1964":184350,"1965":178434,"1966":182087,"1967":314921,"1968":353500,"1969":318000,"1970":180200,"1971":306700,"1972":268000,"1973":156620,"1974":69290,"1975":60540,"1976":163360,"1977":199240,"1978":172000,"1979":157800,"1980":166900,"1981":162200,"1982":163400,"1983":110500,"1984":108700,"1985":148900,"1986":141200,"1987":195900,"1988":140600,"1989":231800,"1990":228800,"1991":189103,"1992":180000,"1993":206000,"1994":383000,"1995":315000,"1996":270000,"1997":244000,"1998":300000,"1999":180000,"2000":60000,"2001":128000,"2002":250000,"2003":90000,"2004":250000,"2005":309000,"2006":363000,"2007":393000,"2008":248157,"2009":173074,"2010":155829,"2011":235118,"2012":361339,"2013":451849,"2014":403028,"2015":109209,"2016":181320,"2017":265852,"2018":18196,"2019":574705,"2020":464159,"2021":422463,"2022":11637,"2023":12602,"2024":227508}}},{"ad":{"tr":"Ekilen alan (bin ha)","en":"Area harvested (thousand ha)"},"rol":"ikincil","noktalar":{"harita":{"1961":25000,"1962":40000,"1963":55000,"1964":65000,"1965":65000,"1966":65000,"1967":103000,"1968":109000,"1969":106000,"1970":75000,"1971":109075,"1972":94000,"1973":63960,"1974":31415,"1975":29880,"1976":52407,"1977":63485,"1978":54717,"1979":58700,"1980":55450,"1981":54500,"1982":57625,"1983":48900,"1984":39150,"1985":52525,"1986":50200,"1987":70000,"1988":50475,"1989":72750,"1990":79200,"1991":85925,"1992":95000,"1993":110000,"1994":163000,"1995":175000,"1996":120000,"1997":121000,"1998":128000,"1999":130000,"2000":100000,"2001":100000,"2002":100000,"2003":29500,"2004":88000,"2005":107000,"2006":125750,"2007":124250,"2008":84750,"2009":54925,"2010":47974,"2011":65745,"2012":79471,"2013":95808,"2014":78949,"2015":24390,"2016":37731,"2017":54283,"2018":5423,"2019":127673,"2020":101594,"2021":96185,"2022":3839,"2023":3472,"2024":52372}}}]},"verim_katlari":{"tur":"siralama","baslik":{"tr":"Hangi üründe verim arttı","en":"Where yield rose"},"not":{"tr":"İlk ölçüm yılı ile 2024 arasında hektar başına alınan ürünün katı. 1,00 çizgisi değişmedi demek; altı düştü demek. Mısır 5,27 katla ülkenin en büyük tarımsal kazancı. Arpa 0,94 ve hurma 0,62 ile altmış üç yıl önce alınandan AZ veriyor. Aynı ülkede, aynı yıllarda, bir ürün beş kat iyileşirken bir başkası geriledi.","en":"The multiple of harvest per hectare between each crop's first measured year and 2024. The 1.00 line means unchanged; below it means a fall. Maize, at 5.27, is the country's largest agricultural gain. Barley at 0.94 and dates at 0.62 give LESS than they gave sixty-three years ago. In the same country and the same years, one crop improved fivefold while another went backwards."},"kaynak":"FAOSTAT · üretim ve hasat edilen alan","sonek":{"tr":" kat","en":"×"},"ondalik":2,"satirlar":[{"etiket":{"tr":"Mısır","en":"Maize"},"deger":5.27,"rol":"vurgu"},{"etiket":{"tr":"Buğday","en":"Wheat"},"deger":3.31,"rol":"ikincil"},{"etiket":{"tr":"Domates","en":"Tomatoes"},"deger":2.97,"rol":"ikincil"},{"etiket":{"tr":"Pirinç","en":"Rice"},"deger":1.59,"rol":"ikincil"},{"etiket":{"tr":"Arpa","en":"Barley"},"deger":0.94,"rol":"sessiz"},{"etiket":{"tr":"Hurma","en":"Dates"},"deger":0.62,"rol":"sessiz"}]},"alan_katlari":{"tur":"siralama","baslik":{"tr":"Hangi ürüne daha çok yer ayrıldı","en":"Where more ground was given"},"not":{"tr":"Aynı dönemde ekilen alanın katı. Mısır 50 kat — 2.000 hektardan 100.000'e. Hurmada alan 2,45 kat arttı ama bir önceki grafikte verimi 0,62 kata inmişti: üretimin artmış görünmesi daha çok ağaçtan geliyor, daha iyi hasattan değil. Arpa 0,19 kat, yani beşte bire indi — dosyadaki tek gerçek terk. Mısırın katı ötekilerin yirmi katından büyük olduğu için kalan beş çubuk aynı cetvelde neredeyse görünmez kalıyor; sıfır oldukları için değil, mısır yanlarında durduğu için. Değerleri çubukların yanında yazılı.","en":"The multiple of sown area over the same period. Maize is 50 — from two thousand hectares to a hundred thousand. The date area rose 2.45-fold while the previous chart showed its yield falling to 0.62: output looks higher because there are more trees, not because the harvest improved. Barley fell to 0.19, a fifth — the only real abandonment in the dossier. Because maize's multiple is more than twenty times the others', the remaining five bars are almost invisible on the same ruler — not because they are zero but because maize stands beside them. Their values are printed next to the bars."},"kaynak":"FAOSTAT · üretim ve hasat edilen alan","sonek":{"tr":" kat","en":"×"},"ondalik":2,"satirlar":[{"etiket":{"tr":"Mısır","en":"Maize"},"deger":50,"rol":"vurgu"},{"etiket":{"tr":"Hurma","en":"Dates"},"deger":2.45,"rol":"ikincil"},{"etiket":{"tr":"Pirinç","en":"Rice"},"deger":2.09,"rol":"ikincil"},{"etiket":{"tr":"Buğday","en":"Wheat"},"deger":1.85,"rol":"ikincil"},{"etiket":{"tr":"Domates","en":"Tomatoes"},"deger":1.12,"rol":"ikincil"},{"etiket":{"tr":"Arpa","en":"Barley"},"deger":0.19,"rol":"sessiz"}]},"hurma_payi":{"tur":"cizgi","baslik":{"tr":"Irak hurmayı bırakmadı, dünya onu geçti","en":"Iraq did not abandon the date; the world overtook it"},"birim":{"tr":"Irak'ın dünya hurma üretimindeki payı, %","en":"Iraq's share of world date production, %"},"ondalik":1,"sonek":{"tr":"%","en":"%"},"not":{"tr":"Irak'ın üretimi 1961'den bugüne 1,7 kat arttı; dünyanınki 5,4 kat. Pay %18,9'dan %5,9'a indi. Kaybedilen şey üretim değil, YER. Ortak yılı olmayan yıl atlandı; eksik yıl sıfır sayılmadı.","en":"Iraq's output rose 1.7-fold between 1961 and today; the world's rose 5.4-fold. The share fell from 18.9% to 5.9%. What was lost is not production but PLACE. Years without a matching world figure were skipped, not counted as zero."},"kaynak":"FAOSTAT · Irak ve dünya","seriler":[{"ad":{"tr":"Irak'ın payı","en":"Iraq's share"},"rol":"vurgu","noktalar":{"harita":{"1961":18.89,"1962":23.22,"1963":17.39,"1964":16.94,"1965":14.89,"1966":20.1,"1967":17.68,"1968":14.27,"1969":22.58,"1970":15.94,"1971":21.33,"1972":15.26,"1973":17.67,"1974":15.72,"1975":20.45,"1976":16.48,"1977":21.74,"1978":15.82,"1979":19.35,"1980":22.45,"1981":15.6,"1982":14.37,"1983":12.86,"1984":9.55,"1985":13.84,"1986":14.64,"1987":10.6,"1988":11.29,"1989":14.24,"1990":15.88,"1991":15.31,"1992":12.28,"1993":14,"1994":14.82,"1995":18.2,"1996":15.92,"1997":14.77,"1998":15.95,"1999":12.87,"2000":14.5,"2001":13.65,"2002":12.91,"2003":12.89,"2004":6.78,"2005":6.18,"2006":6.4,"2007":6.21,"2008":6.81,"2009":7.08,"2010":7.57,"2011":8.56,"2012":8.86,"2013":9.03,"2014":8.96,"2015":7.47,"2016":7.43,"2017":7.4,"2018":7.41,"2019":6.98,"2020":7.81,"2021":7.67,"2022":7.65,"2023":6.17,"2024":5.9}}}]},"hayvan":{"tur":"cizgi","baslik":{"tr":"Sürü yarıya indi","en":"The flock halved"},"birim":{"tr":"bin baş","en":"thousand head"},"bolen":1000,"ondalik":0,"not":{"tr":"Koyun 1968'de 13,1 milyon başla zirvedeydi; bugün 6,7 milyon — yarıdan az. Yalnız 1990'dan bugüne düşüş %30,5. Keçi de %12,7 geriledi. Sığır ise %38,4 arttı: ahırda beslenen hayvan, merada otlayanın tersine çoğaldı. Üç eğri de ÜLKE geneli.","en":"Sheep peaked at 13.1 million head in 1968; today 6.7 million — less than half. Since 1990 alone the fall is 30.5%. Goats are down 12.7%. Cattle, by contrast, rose 38.4%: the barn-fed animal increased as the pasture-fed one declined. All three curves are country-wide."},"kaynak":"FAOSTAT · Irak hayvan varlığı","seriler":[{"ad":{"tr":"Koyun","en":"Sheep"},"rol":"vurgu","noktalar":{"harita":{"1961":9450000,"1962":9700000,"1963":10000000,"1964":10500000,"1965":11040205,"1966":11850000,"1967":12000000,"1968":13100000,"1969":12900000,"1970":13099000,"1971":11955000,"1972":10810000,"1973":9670000,"1974":8526000,"1975":8470000,"1976":8400939,"1977":9500000,"1978":9723301,"1979":9775000,"1980":11000000,"1981":11750000,"1982":10865000,"1983":10491000,"1984":9723000,"1985":8500000,"1986":8981260,"1987":9000000,"1988":9000000,"1989":8981000,"1990":9600000,"1991":5800000,"1992":7525000,"1993":9500000,"1994":8400000,"1995":7400000,"1996":5850000,"1997":6583940,"1998":6900000,"1999":6000000,"2000":6900000,"2001":6045000,"2002":6100000,"2003":6255000,"2004":4473000,"2005":4449000,"2006":5200000,"2007":6371000,"2008":7722375,"2009":7945000,"2010":7945000,"2011":8183000,"2012":8200000,"2013":6515825,"2014":6545146,"2015":6574599,"2016":6604185,"2017":6633904,"2018":6663757,"2019":6693744,"2020":6723866,"2021":6754123,"2022":6784517,"2023":6815047,"2024":6672540}}},{"ad":{"tr":"Sığır","en":"Cattle"},"rol":"ikincil","noktalar":{"harita":{"1961":1550000,"1962":1550000,"1963":1550000,"1964":1500000,"1965":1454923,"1966":1520000,"1967":1600000,"1968":1650000,"1969":1730000,"1970":1830000,"1971":1860000,"1972":1880000,"1973":1900000,"1974":2048000,"1975":1850000,"1976":1804000,"1977":1804235,"1978":1698000,"1979":1697665,"1980":1702000,"1981":1670000,"1982":1675000,"1983":1685000,"1984":1698000,"1985":1635000,"1986":1578418,"1987":1580000,"1988":1600000,"1989":1578000,"1990":1520000,"1991":1000000,"1992":1260000,"1993":1480000,"1994":1354380,"1995":1190000,"1996":1050000,"1997":1300375,"1998":1320000,"1999":1325000,"2000":1350000,"2001":1458000,"2002":1500000,"2003":1425000,"2004":1516000,"2005":1648000,"2006":1130000,"2007":1145000,"2008":1580000,"2009":2552000,"2010":2629000,"2011":2707000,"2012":2720000,"2013":2780000,"2014":2900000,"2015":1823184,"2016":1860887,"2017":1899370,"2018":1938649,"2019":1978740,"2020":2019660,"2021":2061427,"2022":2104057,"2023":2147569,"2024":2104351}}},{"ad":{"tr":"Keçi","en":"Goats"},"rol":"sessiz","noktalar":{"harita":{"1961":2600000,"1962":2400000,"1963":2200000,"1964":2000000,"1965":1845488,"1966":2000000,"1967":2100000,"1968":2150000,"1969":2200000,"1970":2301000,"1971":2350000,"1972":2400000,"1973":2500000,"1974":2584000,"1975":2785000,"1976":2989000,"1977":2320000,"1978":2059000,"1979":2060000,"1980":2080000,"1981":1950000,"1982":1680000,"1983":1800000,"1984":1610000,"1985":1550000,"1986":1475473,"1987":1500000,"1988":1550000,"1989":1476000,"1990":1550000,"1991":1070000,"1992":1250000,"1993":1550000,"1994":1425000,"1995":1450000,"1996":1105000,"1997":1465773,"1998":1450000,"1999":1400000,"2000":1300000,"2001":743000,"2002":740000,"2003":715000,"2004":549000,"2005":523000,"2006":645000,"2007":1078000,"2008":1095000,"2009":1475000,"2010":1519000,"2011":1565000,"2012":1612000,"2013":1195675,"2014":1216898,"2015":1238498,"2016":1260481,"2017":1282856,"2018":1305627,"2019":1328802,"2020":1352388,"2021":1376393,"2022":1400824,"2023":1425689,"2024":1353075}}}]},"manda":{"tur":"cizgi","baslik":{"tr":"Mandanın dibi 1996","en":"The buffalo bottomed in 1996"},"birim":{"tr":"bin baş · ülke geneli","en":"thousand head · country-wide"},"bolen":1000,"ondalik":0,"not":{"tr":"Eğri ÜLKE genelini sayıyor: 1996'da 50 bin başla dibe vurdu, bugün 270 bin — dipten 5,4 kat. BM'nin 2011 raporu ise ayrı bir şeyi, BATAKLIKTAKİ sürüyü sayıyor ve orada 80 binden 5 bine inildiğini yazıyor; aynı yıl ülke genelinde 302 bin baş vardı. İki rakam çelişmiyor, farklı alanları ölçüyor. Rapora göre bataklıkların %90'ından fazlası 1970'lerden 2003'e kadar kurutuldu, bugün %38'i geri kazanıldı; ülke eğrisinin dibi ve toparlanması bu takvime denk düşüyor. Grafik ZAMANLAMAYI gösterir, sebebi değil.","en":"The curve counts the country: a trough of 50 thousand head in 1996, 270 thousand today — 5.4 times the trough. The UN's 2011 report counts something else, the herd IN THE MARSHES, and records a fall there from 80 thousand to 5 thousand; the same year the country held 302 thousand. The two figures do not conflict; they measure different areas. The report states that over 90% of the marshlands were drained between the 1970s and 2003 and that roughly 38% has since been restored; the trough and recovery of the country curve fall on that calendar. The chart shows TIMING, not cause."},"kaynak":"FAOSTAT · Irak manda varlığı; bataklık rakamları BM Irak Su Görev Gücü, 2011","seriler":[{"ad":{"tr":"Manda","en":"Buffalo"},"rol":"vurgu","noktalar":{"harita":{"1961":250000,"1962":245000,"1963":240000,"1964":230000,"1965":224622,"1966":240000,"1967":250000,"1968":260000,"1969":270000,"1970":288000,"1971":270000,"1972":250000,"1973":240000,"1974":184000,"1975":161000,"1976":146000,"1977":160000,"1978":170000,"1979":170000,"1980":170000,"1981":175000,"1982":174000,"1983":175000,"1984":170000,"1985":155000,"1986":141483,"1987":140000,"1988":141000,"1989":145000,"1990":150000,"1991":110000,"1992":105000,"1993":108000,"1994":87000,"1995":70000,"1996":50000,"1997":62250,"1998":80000,"1999":90000,"2000":115000,"2001":109000,"2002":120000,"2003":115000,"2004":111000,"2005":213000,"2006":410000,"2007":396000,"2008":285537,"2009":286000,"2010":295000,"2011":302000,"2012":312000,"2013":180662,"2014":187401,"2015":194391,"2016":201642,"2017":209163,"2018":216965,"2019":225058,"2020":233453,"2021":242161,"2022":251194,"2023":260564,"2024":269940}}}]},"tuzluluk":{"tur":"kartlar","baslik":{"tr":"Toprak suyu aldı, tuzu bıraktı","en":"The soil took the water and kept the salt"},"not":{"tr":"İki rakam da Dünya Bankası'nın 2014 tarihli proje belgesinden. Belgenin tarihi metinde yazılacak; daha yeni bir ölçüm bu araştırmada bulunamadı.","en":"Both figures come from the World Bank project document of 2014. The document's date is given in the text; no more recent measurement was found in this research."},"kaynak":"Dünya Bankası · PID P149803 (2014)","kartlar":[{"ust":{"tr":"Üretim dışı","en":"Out of production"},"baslik":{"tr":"%40","en":"40%"},"govde":{"tr":"Tarihsel olarak sulanmış alanın bu kadarı üretim dışı kaldı.","en":"This much of the historically irrigated area has gone out of production."}},{"ust":{"tr":"Tuzdan etkilenen","en":"Affected by salt"},"baslik":{"tr":"%70","en":"70%"},"govde":{"tr":"Ekili alanın bu kadarı yüksek toprak tuzluluğundan etkileniyor ve bu verimi doğrudan sınırlıyor.","en":"This much of the crop land is affected by high soil salinity, which directly limits yields."}}]},"protokol":{"tur":"kartlar","baslik":{"tr":"1946: suyun protokolü","en":"1946: the protocol on water"},"not":{"tr":"29 Mart 1946 tarihli Dostluk ve İyi Komşuluk Andlaşması'nın altı ek protokolünden birincisi. Metin TBMM'nin 1947 tarihli onay tasarısında basılı. Protokolün ne öngördüğü yazılıdır; ne kadarının gerçekleştiği bu belgeden okunmaz.","en":"The first of six protocols annexed to the Treaty of Friendship and Good Neighbourliness of 29 March 1946. The text is printed in the Turkish parliament's ratification bill of 1947. What the protocol envisaged is on the record; how much of it came about cannot be read from this document."},"kaynak":"TBMM S. Sayısı 241 (1947) · birincil metin","kartlar":[{"ust":{"tr":"Madde 1","en":"Article 1"},"baslik":{"tr":"Parayı Irak öder","en":"Iraq pays"},"govde":{"tr":"Bentler ve gözetleme istasyonları için araştırmayı Irak'ın teknisyenleri yapacak, haritaları Türk kurumları hazırlayacak ve bütün harcamaları Irak ödeyecek.","en":"Iraq's technicians would carry out the surveys for dams and gauging stations, Turkish institutions would prepare the maps, and Iraq would pay all the costs."}},{"ust":{"tr":"Madde 3","en":"Article 3"},"baslik":{"tr":"Her sabah saat sekizde","en":"At eight every morning"},"govde":{"tr":"Taşkın zamanlarında nehir seviyesi her sabah telgrafla Irak'a bildirilecek. Adı geçen istasyonlar: Dicle'de Diyarbakır ve Cizre, Fırat'ta Keban.","en":"In flood season the river level would be telegraphed to Iraq each morning. The stations named: Diyarbakır and Cizre on the Tigris, Keban on the Euphrates."}},{"ust":{"tr":"Madde 4 ve 5","en":"Articles 4 and 5"},"baslik":{"tr":"Haber vermek, onay almak değil","en":"To inform, not to obtain consent"},"govde":{"tr":"Türkiye yapıları esas bakımından kabul ediyor; her biri ayrı bir anlaşmaya konu olacak ve o anlaşma Türkiye'nin kendi sulama ve enerji kullanımını da kapsayacak. Türkiye tasarılarını Irak'a \"haber vermeyi kabul eyler\".","en":"Turkey accepts the works in principle; each would be the subject of a separate agreement, and that agreement would cover Turkey's own use of them for irrigation and energy. Turkey \"accepts to inform\" Iraq of its plans."}}]},"tavuk":{"tur":"cizgi","baslik":{"tr":"En hızlı büyüyen sürü","en":"The fastest-growing flock"},"birim":{"tr":"milyon baş","en":"million head"},"bolen":1000,"ondalik":0,"not":{"tr":"Tavuk 1961'de 6,5 milyon baştı; 2022'de 162,5 milyonla zirveye çıktı, 2024'te 140 milyon. Altmış üç yılda 21,5 kat. Koyun aynı dönemde yarıya indi. Ahırda ve kümeste beslenen hayvan, merada otlayanın tersine çoğaldı — ve yemi büyük ölçüde dışarıdan geliyor.","en":"Chickens numbered 6.5 million head in 1961, peaked at 162.5 million in 2022 and stand at 140 million in 2024 — 21.5-fold over sixty-three years. Sheep halved in the same period. The barn- and coop-fed animal increased as the pasture-fed one declined, and its feed largely comes from outside."},"kaynak":"FAOSTAT · Irak hayvan varlığı","seriler":[{"ad":{"tr":"Tavuk","en":"Chickens"},"rol":"vurgu","noktalar":{"harita":{"1961":6500,"1962":7100,"1963":7500,"1964":7900,"1965":5290,"1966":5394,"1967":7000,"1968":8500,"1969":10000,"1970":11861,"1971":12400,"1972":13000,"1973":13900,"1974":14700,"1975":15404,"1976":15500,"1977":15395,"1978":20500,"1979":22000,"1980":27000,"1981":30000,"1982":70000,"1983":50000,"1984":55000,"1985":65000,"1986":70000,"1987":75000,"1988":76000,"1989":105000,"1990":80000,"1991":3600,"1992":11000,"1993":10500,"1994":15500,"1995":16800,"1996":17300,"1997":19000,"1998":20000,"1999":22000,"2000":23000,"2001":28000,"2002":32000,"2003":24000,"2004":30000,"2005":37000,"2006":40000,"2007":45000,"2008":27500,"2009":27000,"2010":34000,"2011":38000,"2012":38000,"2013":51198,"2014":37968,"2015":44802,"2016":44753,"2017":50073,"2018":54161,"2019":74302,"2020":78534,"2021":144702,"2022":162496,"2023":150905,"2024":140000}}}]},"yeni_urunler":{"tur":"cizgi","baslik":{"tr":"Sonradan gelenler","en":"The latecomers"},"birim":{"tr":"bin ton","en":"thousand tonnes"},"bolen":1000,"ondalik":0,"not":{"tr":"Mısır 1961'de Irak'ta neredeyse yoktu: 2 bin hektar. Bugün 100 bin hektar ve verimi 5,27 kat arttı. Domates ise başka bir eğri çiziyor — 2001'de 1.321 bin tonla zirve yaptı, 2024'te 463 bin ton. Alanı neredeyse aynı kaldı (19,5'ten 22 bin hektara) ama verimi 2,97 kat arttı; düşüş alandan değil, zirve yıllarının ekiminin sürdürülememesinden.","en":"Maize was almost absent from Iraq in 1961: two thousand hectares. Today it covers a hundred thousand and its yield has risen 5.27-fold. Tomatoes draw a different curve — a peak of 1,321 thousand tonnes in 2001 and 463 thousand in 2024. The area barely moved (19.5 to 22 thousand hectares) while the yield rose 2.97-fold; the fall comes not from area but from the peak years' planting not being sustained."},"kaynak":"FAOSTAT · Irak üretimi","seriler":[{"ad":{"tr":"Domates","en":"Tomatoes"},"rol":"vurgu","noktalar":{"harita":{"1961":138695,"1962":140341,"1963":143163,"1964":189147,"1965":195817,"1966":216405,"1967":241371,"1968":232157,"1969":220163,"1970":310680,"1971":383000,"1972":368000,"1973":355205,"1974":349557,"1975":389018,"1976":491842,"1977":401800,"1978":432272,"1979":266600,"1980":347800,"1981":425200,"1982":467900,"1983":439200,"1984":531100,"1985":611800,"1986":523100,"1987":594700,"1988":558400,"1989":709800,"1990":721500,"1991":437900,"1992":410000,"1993":794269,"1994":863489,"1995":870000,"1996":900000,"1997":1021514.52,"1998":1000000,"1999":1113000,"2000":989000,"2001":1321000,"2002":1309000,"2003":234000,"2004":988000,"2005":939000,"2006":1042000,"2007":955000,"2008":802386,"2009":913493,"2010":1013177,"2011":1059537,"2012":768375,"2013":903809,"2014":770564,"2015":388674,"2016":286596,"2017":123611,"2018":467579,"2019":619543,"2020":754759,"2021":744166,"2022":630160,"2023":534821,"2024":463214}}},{"ad":{"tr":"Mısır","en":"Maize"},"rol":"ikincil","noktalar":{"harita":{"1961":1898,"1962":1983,"1963":2013,"1964":2800,"1965":3658,"1966":4317,"1967":4467,"1968":4389,"1969":4785,"1970":5902,"1971":15919,"1972":17703,"1973":19108,"1974":14639,"1975":23424,"1976":54980,"1977":82210,"1978":74800,"1979":58600,"1980":59600,"1981":39300,"1982":28200,"1983":28100,"1984":30930,"1985":40951,"1986":53000,"1987":61300,"1988":77200,"1989":103600,"1990":171900,"1991":236000,"1992":260000,"1993":280000,"1994":128000,"1995":90000,"1996":125000,"1997":121000,"1998":133000,"1999":115000,"2000":55000,"2001":232000,"2002":248000,"2003":233000,"2004":416000,"2005":401000,"2006":399000,"2007":384000,"2008":287955,"2009":238113,"2010":266699,"2011":335710,"2012":503389,"2013":831345,"2014":289288,"2015":182340,"2016":259546,"2017":185291,"2018":225000,"2019":473064,"2020":419345,"2021":374400,"2022":496003,"2023":538251,"2024":500000}}}]}}$dsr$::jsonb,
  array['Irak', 'buğday', 'arpa', 'pirinç', 'hurma', 'tarım ticareti', 'ihracat', 'tarım ihracatı', 'sulama', 'tuzluluk', 'Dicle', 'Fırat', 'su', 'bataklık', 'manda', 'hayvancılık', 'gıda güvenliği', 'Mezopotamya']::text[],
  'https://tarimportali.net/dosya/irak/irak_kapak_uydu.jpg',
  $dsr$NASA — Public domain$dsr$,
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
 where dossier_id = (select id from public.country_dossiers where slug = 'irak');

insert into public.dossier_sections
  (dossier_id, ord, title_tr, title_en, body_tr, body_en, chart_keys, tur, gorsel)
select d.id, v.ord, v.title_tr, v.title_en, v.body_tr, v.body_en, v.chart_keys, v.tur, v.gorsel
from public.country_dossiers d
cross join (values
  (1::integer, $dsr$Bir ülkenin ekmeği$dsr$, $dsr$A country's bread$dsr$, $dsr$Türkiye 2024'te dünyaya 32,54 milyar dolarlık tarım ürünü sattı. Bunun 4,64
milyar doları tek bir ülkeye gitti: Irak. 7 liralık tarım ihracatının biri,
sınırın hemen güneyinde duran komşuya.

Ters yöne bakınca defter neredeyse boş. Aynı yıl Irak'tan Türkiye'ye gelen
tarım ürünü 30,2 milyon dolar. Oran **154 kat**. Bir ticaret ilişkisinde
tarafların dengesiz olması olağandır; bu ölçüde dengesiz olması değildir.
Karşılaştırma için: Türkiye'nin Avustralya ile ticareti üç kat Türkiye
lehineydi ve o bile dizide dengesiz sayılmıştı.

Rakamların hepsi Türkiye'nin beyanından okundu. Irak, Birleşmiş Milletler'in
ticaret veritabanına muhabir olarak rapor vermiyor: 2016, 2018 ve 2020 için
sıfır satır, 2022 ve 2024 için birer satır dönüyor. Dolayısıyla bu dosyadaki
her ticaret rakamı, hattın Türkiye tarafından görünen hâlidir. Bu, rakamların
yanlış olduğu anlamına gelmez; tek taraftan sayıldığı anlamına gelir.

Irak'a giden toplam Türk ihracatı 13,00 milyar dolar. Tarım bunun %35,7'si.
Yani Türkiye bu ülkeye neredeyse her 3 liralık malın birini tarladan
gönderiyor. Bu oran kendi başına dikkat çekici: Türkiye'nin dünyaya toplam
ihracatında tarımın payı bunun çok altında. Irak hattı, Türk ihracatının
genel bileşiminden farklı bir hat.

İçindeki en kalabalık grup tek bir zincir: hububat, un ve hamur işleri
birlikte 1,44 milyar dolar, tarım ihracatının %31,1'i. Yani Irak'a giden her 3 liralık tarım malının biri buğdayın bir hâli — tanesi, unu ya da pişmişi.

Bu dosya o hattı anlatıyor. Ama hattın bir ucunda duran ülkeyi de anlatıyor —
çünkü Irak'ın tarımı, Türkiye ile ilişkisinden çok daha eski ve çok daha
karışık bir hikâye. Sonraki 15 bölüm o hikâye; hat yalnızca son üçünde
geri dönüyor.$dsr$, $dsr$In 2024 Türkiye sold 32.54 billion dollars of agricultural produce to the
world. Of that, 4.64 billion dollars went to a single country: Iraq. 1 lira in every 7 of agricultural exports went to the neighbour lying just across
the southern border.

Look the other way and the ledger is almost empty. In the same year the
agricultural goods that came from Iraq to Türkiye were worth 30.2 million
dollars. The ratio is **154 to 1**. Imbalance in a trading relationship is
ordinary; imbalance on this scale is not. For comparison, Türkiye's trade with
Australia ran 3 times in Türkiye's favour, and even that counted as
lopsided in this series.

All of these figures are read from Türkiye's reporting. Iraq does not report
as a reporter to the United Nations trade database: for 2016, 2018 and 2020 it
returns zero rows, and for 2022 and 2024 a single row each. Every trade number
in this dossier is therefore the line as seen from the Turkish side. That does
not make the figures wrong; it makes them counted from one side.

Total Turkish exports to Iraq come to 13.00 billion dollars. Agriculture is
35.7% of that. Nearly 1 lira in every 3 that Türkiye sends to this
country leaves from a field. The share is striking on its own: in Türkiye's
exports to the world as a whole, agriculture's share is far below this. The
Iraq line has a different composition from Turkish exports in general.

Within it the most crowded group is a single chain: cereals, flour and bakery
goods together make 1.44 billion dollars, 31.1% of the agricultural exports.
1 lira in every 3 of agricultural goods going to Iraq is wheat in some
form — the grain, its flour, or the flour baked.

This dossier is about that line. But it is also about the country at one end
of it — because Iraq's agriculture is a far older and far more tangled story
than its relationship with Türkiye. The next 15 sections are that story;
the line returns only in the last three.$dsr$, array['acilis']::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/irak/irak_ekmek.jpg","atif":"Omar Chatriwala of Al Jazeera English — CC BY-SA 2.0","kaynak":null,"alt_tr":"Tezgâhta satışa dizilmiş yufka ekmekler; arkasında satıcı oturuyor.","alt_en":"Flatbreads laid out for sale; the seller sits behind them."}$dsr$::jsonb),
  (2, $dsr$Tarımın başladığı yer$dsr$, $dsr$Where farming began$dsr$, $dsr$Birleşmiş Milletler'in Irak Su Görev Gücü'nün 2011 tarihli raporu, Mezopotamya
ovasından söz ederken onu *"as the birthplace of humanity and agricultural
production"* diye tanımlıyor. Bu cümle bir BM belgesinin kendi ifadesidir;
dosya onu oradan alıyor ve bir genel kültür hatırlatması olarak değil, bu
dosyanın ölçtüğü şeylerin zeminini kurmak için yazıyor.

Bugün aynı ovada 47,0 milyon insan yaşıyor ve nüfusun %30,1'i kırsalda.
Tarımda çalışanların toplam istihdamdaki payı %8,17. Türkiye'nin nüfusu
85,9 milyon; yani Irak Türkiye'nin yarısından biraz fazla bir nüfusu aynı
havzanın aşağı ucunda besliyor.

Tarımın ekonomideki yeri iki ayrı paydayla iki ayrı cevap veriyor. Dünya
Bankası'nın göstergesine göre tarım, Irak'ın toplam gayrisafi yurt içi
hasılasının %3,41'i (2025). Aynı kurumun 2014 tarihli proje belgesi ise
**petrol dışı** GSYH'nin %35'ini tarıma bağlıyor. İki rakam çelişmiyor;
paydaları farklı. Petrol gelirinin şişirdiği bir toplamda tarımın payı küçük
görünür, petrol çıkarıldığında ülkenin üretken ekonomisinin üçte birinden
fazlası olur. Bu dosya ikisini birlikte yazıyor, çünkü yalnız ilkini yazmak
Irak'ta tarımın yerini olduğundan küçük gösterir. Karşılaştırma için
Türkiye'de aynı gösterge %5,21 — ama Türkiye'de petrol diye bir payda sorunu
yok, dolayısıyla iki ülkenin bu tek rakamı doğrudan karşılaştırılamaz.

Tarımın doğduğu yerde tohumun kendisi de bir kurumda tutuluyor. Bağdat'taki
Ebu Garib tohum bankası — belgenin yazımıyla *"the Abu Gharib seed bank in
Baghdad"* — *"operational since 1977"*, yani 40 yılı aşkın süredir çalışıyor,
ama *"suffered from infrastructural damage"*. FAO, Kurak Alanlarda Tarımsal
Araştırma Merkezi ile birlikte bankayı onarmaya ve Süleymaniye'de ikinci bir
tohum bankası kurmaya çalışıyor.

Bir ülkenin tohum bankası, o ülkenin tarımının yedeğidir. Tarla yanarsa
ertesi yıl ekilir; tohum koleksiyonu giderse yerine konamaz, çünkü o
koleksiyon yüzyıllarca bir yerde seçilmiş çeşitlerin kaydıdır. 5. bölümde anlatılan tarla hasarı ile bu bankanın altyapı hasarı farklı
büyüklükte iki kayıp değil; biri mevsimlik, öteki geri dönüşsüz olabilecek
iki ayrı kayıp cinsi.$dsr$, $dsr$The 2011 report of the United Nations Integrated Water Task Force for Iraq,
writing about the Mesopotamian plain, describes it as *"as the birthplace of
humanity and agricultural production"*. That phrase is the UN document's own;
the dossier takes it from there, not as a piece of general knowledge but to
set the ground for what it goes on to measure.

Today 47.0 million people live on that plain and 30.1% of the population is
rural. Those working in agriculture are 8.17% of total employment. Türkiye's
population is 85.9 million; Iraq feeds a little over half that number at the
lower end of the same basin.

Agriculture's place in the economy gives two different answers under two
different denominators. By the World Bank's indicator, farming is 3.41% of
Iraq's total gross domestic product (2025). The same institution's 2014
project document puts 35% of **non-oil** GDP in agriculture. The two do not
contradict each other; their denominators differ. In a total inflated by oil
revenue agriculture looks small, and with oil taken out it becomes more than a
third of the country's productive economy. This dossier writes both, because
writing only the first makes farming in Iraq look smaller than it is. For
comparison the same indicator in Türkiye is 5.21% — but Türkiye has no oil
denominator problem, so the two single figures cannot be compared directly.

In the place where farming began, the seed itself is also kept in an
institution. The seed bank at Abu Ghraib in Baghdad — in the document's own
spelling, *"the Abu Gharib seed bank in Baghdad"* — has been *"operational
since 1977"*, more than 40 years, but has *"suffered from infrastructural
damage"*. The FAO, together with the International Center for Agricultural
Research in the Dry Areas, is working to rehabilitate it and to establish a
second seed bank in Sulaymaniyah.

A country's seed bank is its agriculture's backup. A burned field is sown
again the following year; a lost seed collection cannot be replaced, because
that collection is the record of varieties selected in one place over
centuries. The field damage described in section 5 and this bank's
infrastructural damage are not two losses of different size; they are two
kinds of loss, one seasonal and the other possibly irreversible.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/irak/irak_harman_ninova.jpg","atif":"Matson Collection — Public domain","kaynak":null,"alt_tr":"Kerpiç bir değirmen: eşeğin çevirdiği büyük yuvarlak taş, yanında çuvallar ve bekleyen insanlar. Ninova yakınlarında, yirminci yüzyılın başı.","alt_en":"A mud-brick mill: a large round stone turned by a donkey, with sacks and waiting people beside it. Near Nineveh, early twentieth century."}$dsr$::jsonb),
  (3, $dsr$Bugünkü Irak$dsr$, $dsr$Iraq today$dsr$, $dsr$Irak yüzölçümünün %21,6'sı tarım arazisi. Bu oran, ülkenin büyük bölümünün
çöl olduğu düşünülürse yüksek sayılır; ama arazinin varlığı ile üretkenliği
ayrı şeylerdir.

Tahıl verimi hektar başına 2.651 kilogram. Aynı yıl Türkiye'de 3.428,7.
Aradaki fark toprak kalitesinden çok suyun ve girdinin düzeninden geliyor;
sonraki bölümler bunun neden böyle olduğunu tek tek gösteriyor.

Hektar başına 2.651 kilogram tahıl, pratikte şu demek: bir dönümden alınan
ürün, aynı tohumun Türkiye'deki karşılığının dörtte üçü kadar. Fark her yıl,
her tarlada ve her hasatta tekrarlanıyor; birikince ülkenin kendi ekmeğini
karşılama kapasitesini belirliyor.

Nüfusun %30,1'i kırsalda yaşıyor ama tarımda çalışanların toplam istihdamdaki
payı %8,17. Aradaki boşluk küçük değil: kırsalda yaşayan her 4 kişiden 3'ünden fazlası geçimini tarımdan sağlamıyor. Bu, tarımın kırsalı tek başına
taşıyamadığı bir yapıya işaret ediyor. Bir ülkede kırsal nüfusun tarımsal
istihdamın 3 katından fazla olması, kırsalda tarım dışı bir geçim
arayışının ya da geçimsizliğin işaretidir; bu dosyanın verisi ikisini
birbirinden ayırmaya yetmiyor.

Gıda ithalatının toplam mal ithalatındaki payı %14,2. Tarımın doğduğu ülke,
yediğinin önemli bir bölümünü dışarıdan alıyor. Bu oran tek başına bir kriz
göstergesi değil — zengin ülkelerin çoğu daha fazlasını ithal eder — ama
petrol ihracatına dayanan bir dış ticaret dengesinde gıdanın bu büyüklükte
yer tutması, petrol fiyatı ile ekmek fiyatı arasında doğrudan bir bağ kuruyor.

Bir rakam ise burada yok. Dünya Bankası'nın "sulanan arazinin tarım
arazisindeki payı" göstergesi Irak için boş dönüyor. Suyun her şeyi
belirlediği bir ülkede, sulanan alanın payı yayımlanmıyor. Bu dosya o boşluğu
doldurmuyor; boşluk olduğunu yazıyor — çünkü boşluğun kendisi de bir bilgidir:
ölçülmeyen şey yönetilmiyor olabilir.$dsr$, $dsr$Agricultural land is 21.6% of Iraq's surface. Given how much of the country is
desert that is a high share; but the existence of land and its productivity
are separate things.

Cereal yield is 2,651 kilograms per hectare. In the same year Türkiye's was
3,428.7. The gap comes less from soil quality than from the ordering of water
and inputs; the sections that follow show, one by one, why that is so.

In practice 2,651 kilograms per hectare means this: the harvest taken from a
given plot is about three quarters of what the same seed yields in Türkiye.
The difference repeats every year, in every field and at every harvest; it
accumulates into the country's capacity to cover its own bread.

30.1% of the population lives in the countryside while farming accounts for
8.17% of employment. The gap is not small: more than 3 in 4 people
living rurally do not make their living from agriculture. That points to a
structure in which farming cannot carry the countryside on its own. Where a
rural population is more than 3 times agricultural employment, it signals
either a search for non-farm income in the countryside or the absence of
income altogether; this dossier's data cannot separate the two.

Food imports are 14.2% of total merchandise imports. The country where farming
began buys a substantial part of what it eats from outside. That ratio is not
by itself a crisis indicator — most wealthy countries import more — but in a
trade balance resting on oil exports, food at this size ties the price of
bread directly to the price of oil.

One figure, however, is missing here. The World Bank's indicator for irrigated
land as a share of agricultural land returns empty for Iraq. In a country
where water decides everything, the share of irrigated land is not published.
This dossier does not fill that hole; it writes that the hole is there —
because the hole is information too: what is not measured may not be managed.$dsr$, array['bugunku_irak']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/irak/irak_sulama_kanali.jpg","atif":"Tim Hunt, U.S. Army — Public domain","kaynak":null,"alt_tr":"Bir motopompun kıyıya boşalttığı su; arkada yeşil ekili tarla.","alt_en":"Water discharged onto the bank by a motor pump; a green planted field behind."}$dsr$::jsonb),
  (4, $dsr$İki nehrin ülkesi$dsr$, $dsr$The country of two rivers$dsr$, $dsr$Irak'ın iki büyük nehri de ülke dışında doğuyor. Bu, coğrafi bir ayrıntı değil
ülkenin tarım politikasının çerçevesi.

Dünya Bankası'nın 2014 tarihli belgesi durumu şöyle yazıyor: *"Iraq is heavily
dependent on the external water resources that are not subject to
well-established cross-border agreements."* Cümlenin iki yarısı ayrı ayrı
önemli. Birincisi bağımlılığı söylüyor, ikincisi o bağımlılığın oturmuş bir
anlaşmaya bağlanmamış olduğunu.

FAO'nun dünya su kaynakları incelemesi, yenilenebilir su kaynaklarının
*"other countries for over 50 percent of their renewable water resources"*
yani yarısından fazlası için başka ülkelere bağlı olan ülkeleri sayarken
Irak'ı da listeye alıyor. Bu belge eskidir ve buradaki işi güncel bir oran
vermek değil, durumun cinsini göstermek.

Bir ülkenin suyunun yarısından fazlasının dışarıdan gelmesi, tek başına bir
kriz değildir; Hollanda da aşağı havzada oturur ve bunu bir mühendislik
meselesine çevirmiştir. Farkı yaratan, belgenin ikinci yarısındaki ifade:
oturmuş bir sınır ötesi anlaşmanın bulunmaması. Su bir anlaşmaya bağlı
olduğunda miktarı azalsa bile öngörülebilir; bağlı olmadığında az su ile çok
su arasındaki fark bir plana değil bir habere dönüşür. 16. bölümdeki
1946 protokolü bu cümlenin tarihsel karşılığıdır.

Suyun aşağıya ne kadar geleceği yalnızca yukarıdaki ülkelerin kararına değil,
yağışa ve havzadaki toplam tüketime de bağlı. Ama aşağı havzada oturan bir
ülke için önemli olan, miktarın kendisinden çok miktarın ÖNCEDEN BİLİNİP
BİLİNMEDİĞİ. Bir çiftçi ekim kararını mart ayında verir; o kararı verirken
temmuzda ne kadar su geleceğini bilmiyorsa, riski ekmeyerek azaltır.

Yukarıdan gelen suyun miktarı yıldan yıla değişiyor, ama değişenin yalnızca
miktar olmadığını sonraki bölümler gösterecek: su azaldığında Irak'ta
kaybolan şey verim değil, ekilen alanın kendisi oluyor. Bir çiftçi az suyla
aynı tarlayı daha kötü sulamıyor; tarlanın bir kısmını hiç ekmiyor. 7. bölümdeki pirinç ve 6. bölümdeki arpa, bu davranışın iki ayrı ölçümü.$dsr$, $dsr$Both of Iraq's great rivers rise outside the country. This is not a
geographical detail but the frame of the country's agricultural policy.

The World Bank's 2014 document puts it this way: *"Iraq is heavily dependent
on the external water resources that are not subject to well-established
cross-border agreements."* Each half of the sentence matters separately. The
first states the dependence; the second states that the dependence is not tied
to a settled agreement.

The FAO's review of world water resources, listing the countries that depend
on *"other countries for over 50 percent of their renewable water resources"*,
includes Iraq. That document is old, and its work here is not to supply a
current ratio but to show the kind of situation this is.

A country drawing more than half its water from outside is not in itself a
crisis; the Netherlands also sits in a lower basin and has turned that into a
question of engineering. What makes the difference is the second half of the
document's sentence: the absence of a settled cross-border agreement. Water
tied to an agreement is predictable even when it shrinks; untied, the
difference between little water and much water becomes a piece of news rather
than a plan. The 1946 protocol in section 16 is the historical
counterpart of that sentence.

How much water reaches downstream depends not only on upstream decisions but
on rainfall and on total consumption across the basin. But for a country in
the lower basin what matters is less the quantity itself than whether the
quantity is KNOWN IN ADVANCE. A farmer decides what to sow in March; if he
does not know in March how much water will arrive in July, he reduces the risk
by not sowing.

The quantity of water arriving from upstream changes from year to year, but
the sections that follow show that quantity is not the only thing that
changes: when water grows scarce in Iraq, what disappears is not yield but the
sown area itself. A farmer short of water does not irrigate the same field
worse; he leaves part of it unsown. The rice of section 7 and the
barley of the sixth are two separate measurements of that behaviour.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/irak/irak_tharthar.jpg","atif":"MODIS Land Rapid Response Team, NASA GSFC — Public domain","kaynak":null,"alt_tr":"Uydudan Tharthar Gölü ve Dicle'nin menderesleri; çölün içinde koyu bir su kütlesi ve kıyılarında açık renkli bir halka.","alt_en":"Lake Tharthar and the meanders of the Tigris from orbit; a dark body of water in the desert, ringed by a pale band."}$dsr$::jsonb),
  (5, $dsr$Savaş tarlaya ne yaptı$dsr$, $dsr$What the war did to the field$dsr$, $dsr$FAO'nun Şubat 2016 tarihli saha değerlendirmesi, yeni kurtarılmış alanlarda
tarlayı tek tek ölçtü. Çıkan tablo, savaşın tarımı arka plandan etkilediği
fikrini bozuyor.

Ninova'da buğday ekili alanın ortalama %32'si *"badly damaged resulting in a
lower yields"* ve **%68'i** *"completely lost"*. Aynı ilde arpada oranlar
%43 hasarlı, %57 tamamen yok. Selahaddin'de mısır, buğday ve arpa ekili
alanın *"About 70 to 80%"*'i hasar görmüş.

Sebepleri de belge sayıyor: *"massive displacement of the local population,
looting and destruction of silos and seed and fertilizer storage facilities
as well as the collapse of government support in providing inputs."* Yani
kayıp yalnız tarlada değil; tohumun, gübrenin ve siloların olduğu yerde.

İki hasar sınıfı arasındaki fark önemli. "Ağır hasarlı" bir tarla ertesi yıl
daha düşük verimle de olsa ürün verir; "tamamen kayıp" bir tarla vermez.
Ninova'da buğdayda tamamen kayıp oranı hasarlı oranın 2 katından fazla,
arpada ise ikisi birbirine yakın. Yani buğday tarlasının üçte ikisi o yıl
hiçbir şey üretmedi.

Bu rakamlar bir tahmin değil, saha ölçümü. Fark şurada: uydudan ya da
uzaktan yapılan bir kestirim ekili alanın yeşil olup olmadığını görür;
depolanmış tohumun, gübrenin ve silonun akıbetini görmez. Belge görmüş ve
saymış.

Ninova ve Selahaddin, Irak'ın buğday ve arpa üretiminin büyük bölümünü
taşıyan illerdir. Bir ülkenin tahıl haritasında bu iki ilin bir mevsim
boyunca büyük ölçüde devre dışı kalması, ulusal seriye tek bir yıl olarak
değil, birkaç yıl olarak yansır — çünkü ertesi yıl ekecek tohumu da aynı
yerde duruyordu.

Bir tarlanın yanması bir mevsimi götürür. Tohumluk deposunun ve silonun
gitmesi, devlet desteğinin çökmesiyle birleştiğinde, sonraki birkaç mevsimi de
götürür. Bir sonraki bölümün serilerindeki kırılmalar bu yüzden tek yıllık
değil. İkinci bölümde anlatılan Ebu Garib tohum bankasının altyapı hasarı da
aynı cümlenin bir parçası: bir ülkede tohumun saklandığı yer, tarlanın
kendisi kadar kritiktir.$dsr$, $dsr$The FAO's field assessment of February 2016 measured the fields one by one in
newly retaken areas. The table it produced breaks the idea that war affects
farming from the background.

In Nineveh, on average 32% of the wheat area was *"badly damaged resulting in
a lower yields"* and **68%** was *"completely lost"*. In the same governorate
barley stood at 43% damaged and 57% entirely destroyed. In Salahaddin
*"About 70 to 80%"* of the area under maize, wheat and barley was damaged.

The document lists the causes as well: *"massive displacement of the local
population, looting and destruction of silos and seed and fertilizer storage
facilities as well as the collapse of government support in providing
inputs."* The loss, in other words, is not only in the field; it is where the
seed, the fertiliser and the silos were.

The difference between the two damage classes matters. A badly damaged field
still produces the following year, at a lower yield; a completely lost field
does not. In Nineveh the completely-lost share of wheat is more than twice the
damaged share, while for barley the two are close. Two thirds of the wheat
field produced nothing at all that year.

These are not estimates but field measurements. The distinction is this: a
remote or satellite estimate sees whether a sown area is green; it does not
see what became of the stored seed, the fertiliser and the silo. The document
saw and counted.

Nineveh and Salahaddin carry a large part of Iraq's wheat and barley. When two
such governorates fall largely out of use for a season, the national series
registers it not as one year but as several — because next year's seed was
stored in the same place.

A burned field costs one season. The loss of the seed store and the silo,
combined with the collapse of government support, costs several seasons after
it. That is why the breaks in the next section's series are not single-year
breaks. The infrastructural damage to the Abu Ghraib seed bank described in
section 2 belongs to the same sentence: in any country, the place
where seed is kept is as critical as the field itself.$dsr$, array['savas_hasari']::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/irak/irak_silo_musul.jpg","atif":"الدبوني — CC BY-SA 4.0","kaynak":null,"alt_tr":"Musul'da tahıl silosu: betonarme siloların dizisi ve önünde boş bir yol.","alt_en":"A grain silo at Mosul: a row of concrete silos with an empty road in front."}$dsr$::jsonb),
  (6, $dsr$Üç şok ve geri gelmeyen tahıl$dsr$, $dsr$Three shocks and the grain that did not come back$dsr$, $dsr$Irak'ın buğday serisi 1961'den bugüne uzanıyor ve 3 ayrı yerde kırılıyor.

Serinin en düşük yılı 2000: 384 bin ton. Ambargo yıllarının dibi. İkinci
kırılma 2015'te: bir yıl önce 5.055 bin ton olan hasat 2.645 bine iniyor,
yani **%47,7** düşüyor. Üçüncüsü 2021 sonrasının kurak dönemi.

Ama asıl hikâye buğdayda değil. Arpada.

64 yıllık serinin **en düşük yılı ambargo değil, 2023**: 106 bin ton.
2020'de 1.756 bin tondu. 2024'te 164 bin tona çıktı — yani 2020 seviyesinin
%9,4'ü. Ekilen alan da aynı yoldan gitti: 1.123.712 hektardan 91.144 hektara.

Buğday her kırılmadan sonra geri geldi; 2024'te 5.234 bin ton. Arpa gelmedi.
İki tahıl aynı tarlada, aynı iklimde, aynı sulamayla duruyor ve aynı eğriyi
izlemiyor.

Farkın nerede olduğu bir sonraki bölümde sayıyla görünüyor: buğdayda hem alan
hem verim arttı, arpada ikisi de düştü. 1961'den 2024'e buğdayın ekili alanı
1,85 kat büyürken arpanınki 0,19 kata indi — yani beşte bire. Bu, kötü bir
mevsim değil, bir ürünün bırakılması.

Su kısıtlandığında önce bırakılan ürün arpa oldu — hayvan yemi, yani insanın
doğrudan yemediği tahıl. Bir devlet su tahsisini daralttığında ekmeklik
buğdayı korur, yemlik arpayı korumaz; bu bir tercih sırasıdır ve seride
açıkça okunuyor.

Bir ülkenin neyi ekmeyi bıraktığı, neyi ektiğinden daha çok şey söyler.
Irak'ın bıraktığı tahıl, sürüsünü beslediği tahıldı. 11. bölümdeki
koyun eğrisi ve 12. bölümdeki tavuk eğrisi bu cümlenin iki ayrı
devamıdır: merada otlayan hayvan azaldı, yemle beslenen hayvan çoğaldı — ve
yemin bir kısmı artık 14. bölümdeki ithalat listesinde duruyor.$dsr$, $dsr$Iraq's wheat series runs from 1961 to today and breaks in 3 places.

The lowest year in the series is 2000, at 384 thousand tonnes — the trough of
the embargo years. The second break is 2015: a harvest of 5,055 thousand
tonnes the year before falls to 2,645 thousand, a drop of **47.7%**. The third
is the dry period after 2021.

But the real story is not in wheat. It is in barley.

Across 64 years, the lowest year of the series **is not the embargo
but 2023**: 106 thousand tonnes. In 2020 it had been 1,756 thousand. In 2024
it rose to 164 thousand — 9.4% of the 2020 level. The sown area followed the
same road: from 1,123,712 hectares to 91,144.

Wheat came back after every break; in 2024 it reached 5,234 thousand tonnes.
Barley did not. The two grains stand in the same field, in the same climate,
under the same irrigation, and do not follow the same curve.

The next section shows where the difference lies, in numbers: in wheat both
area and yield rose, in barley both fell. Between 1961 and 2024 wheat's sown
area grew 1.85-fold while barley's fell to 0.19 — to a fifth. That is not a
bad season but a crop being dropped.

When water was restricted, the crop dropped first was barley — animal feed,
the grain people do not eat directly. A state narrowing its water allocation
protects bread wheat and does not protect feed barley; that is an order of
preference, and it is legible in the series.

What a country stops sowing says more than what it sows. The grain Iraq
dropped was the grain that fed its flocks. The sheep curve in section 11 and the chicken curve in the twelfth are two continuations of that
sentence: the pasture-grazed animal declined and the feed-fed animal
increased — and part of that feed now sits in the import list of section 14.$dsr$, array['uc_sok']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/irak/irak_bugday_tarlasi.jpg","atif":"Ruaa Jabbar — CC BY 4.0","kaynak":null,"alt_tr":"Başaklanmış buğday tarlasında çömelmiş bir kadın, başakları elliyor.","alt_en":"A woman crouching in a field of eared wheat, handling the ears."}$dsr$::jsonb),
  (7, $dsr$Kapatılıp açılan ürün$dsr$, $dsr$A crop switched off and on$dsr$, $dsr$Pirinç suda yetişir. Bu yüzden su kıtlığı en net ondan okunur.

2020'de Irak 464.159 ton pirinç üretti. 2022'de 11.637 ton. Düşüş **%97,5**.
Aynı iki yılda ekilen alan 101.594 hektardan 3.839 hektara indi. İki eğrinin
birlikte düşmesi kaybın nereden geldiğini söylüyor: verimden değil, alandan.
Tarla ekilmedi.

Burada duran bir metin, terk edilmiş bir ürün anlatırdı. Ama seri devam
ediyor. 2024'te üretim 227.508 tona döndü — 2020'nin %49'u. 4 yıl içinde
kırkta bire inip yarıya çıkan bir eğri, bırakılmış bir ürünü değil,
**kapatılıp açılan** bir ürünü gösteriyor.

Fark önemli. Bir ürün pazar yüzünden terk edilirse geri gelmesi onlarca yıl
alır; bir ürün su yüzünden ekilmezse ertesi yıl geri gelebilir. Pirinç
ikincisi. Bu dosya bu kararın kim tarafından ve nasıl verildiğini söylemiyor —
elindeki seriler ne olduğunu gösteriyor, neden olduğunu değil.

Uzun vadede pirincin yönü yine de yukarı. 1961'de 25.000 hektarda ekiliyordu,
2024'te 52.372 hektarda; alan 63 yılda 2,09 kat arttı. Verim de
hektar başına 2,74 tondan 4,34 tona çıktı, yani 1,59 kat. Yani Irak pirinçte
hem daha çok yer ayırdı hem daha iyi hasat aldı — ve buna rağmen tek bir
kurak dönemde üretimin kırkta birine inebiliyor. Bir ürünün uzun vadeli
eğilimi ile tek yıllık kırılganlığı aynı şey değil.

BM'nin bataklık raporu, güneydeki yerel toplulukların geleneksel olarak
*"to harvest food grains such as rice and millet"* diye yazıyor. Pirinç o
ovada bir ihracat ürünü değil; bir yeme biçimi. Bir yıl ekilmemesi bir
ihracat kaleminin kaybı değil, bir sofranın değişmesi demek.$dsr$, $dsr$Rice grows in water. That is why water scarcity reads most clearly from it.

In 2020 Iraq produced 464,159 tonnes of rice. In 2022, 11,637 tonnes. The fall
is **97.5%**. Across the same 2 years the sown area went from 101,594
hectares to 3,839. The two curves falling together say where the loss came
from: not from yield but from area. The field was not sown.

A text stopping here would describe an abandoned crop. But the series
continues. In 2024 output returned to 227,508 tonnes — 49% of 2020. A curve
that falls to a fortieth and climbs back to half within 4 years shows not a
crop given up but a crop **switched off and on**.

The difference matters. A crop abandoned because of the market takes decades
to return; a crop left unsown because of water can return the following year.
Rice is the second kind. This dossier does not say by whom or how that
decision was taken — the series in hand show what happened, not why.

Over the long run rice still points upward. It was sown on 25,000 hectares in
1961 and on 52,372 in 2024; the area rose 2.09-fold over 63 years.
Yield rose too, from 2.74 to 4.34 tonnes per hectare, a factor of 1.59. Iraq
gave rice more ground and took a better harvest from it — and can still fall
to a fortieth of its output in a single dry period. A crop's long-term trend
and its single-year fragility are not the same thing.

The UN's marshlands report writes that the communities of the south
traditionally work *"to harvest food grains such as rice and millet"*. In that
plain rice is not an export line; it is a way of eating. A year without it is
not the loss of an export item but a change at the table.$dsr$, array['pirinc']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/irak/irak_bataklik_uydu.jpg","atif":"Operators for the Moderate Resolution Imaging Spectroradiometer (MODIS) on NASA’s Aqua satellite (Image annotated by myself) — Public domain","kaynak":null,"alt_tr":"Uydudan güney Irak bataklıkları; Dicle ve Fırat'ın aşağı kolları ile Hawizeh, Merkez ve Hammar sulak alanları işaretli.","alt_en":"The southern Iraqi marshes from orbit, with the lower Tigris and Euphrates and the Hawizeh, Central and Hammar wetlands labelled."}$dsr$::jsonb),
  (8, $dsr$Verim mi, alan mı$dsr$, $dsr$Area or yield$dsr$, $dsr$Üretim iki şeyin çarpımıdır: ekilen alan ve hektar başına alınan ürün. Bir
üretim serisine tek başına bakmak, hangi yarının değiştiğini gizler — ve
bu dosyanın en yanıltıcı rakamı tam orada duruyor.

6 ürün için ilk ölçüm yılı ile 2024 arasındaki katlar şöyle:

| ürün | verim katı | alan katı |
|---|---|---|
| buğday | 3,31 | 1,85 |
| arpa | 0,94 | 0,19 |
| pirinç | 1,59 | 2,09 |
| hurma | 0,62 | 2,45 |
| mısır | 5,27 | 50,00 |
| domates | 2,97 | 1,12 |

Buğday ülkenin en dengeli başarısı: verim 3,31 kat arttı, alan 1,85 kat.
Yani hem daha çok yere ekildi hem de her yerden daha çok alındı. Mısırda
verim 5,27 kat arttı — altısı içindeki en büyük tarımsal kazanç.

Arpa tek düşen ürün: verim 0,94 kata indi, yani 63 yılda hektar başına
alınan ürün bugün 1961'dekinden az. Alan ise 0,19 kata indi. Bir ürünün hem
alanı hem verimi düşüyorsa, orada iyileşme değil çekilme vardır.

Ama tablonun asıl satırı hurma. Verim **0,62 kata indi** — yani bugün bir
hektar hurmalıktan 1985'tekinin üçte ikisi kadar ürün alınıyor. Alan ise
2,45 kat arttı. 9. bölümde Irak'ın hurma üretiminin 1,7 kat arttığını
yazacağız; o artışın tamamı ve fazlası alandan geliyor. Ülke daha çok ağaç
dikti ve her ağaçtan daha az aldı.

Bu, üretim serisine tek başına bakan bir okumanın göremeyeceği şey. "Hurma
üretimi arttı" cümlesi doğrudur ve yanıltıcıdır. 9. bölümdeki dünya
payı kaybının açıklaması burada: dünya hurmada verimini artırırken Irak
alanını artırdı.$dsr$, $dsr$Output is the product of two things: the area sown and the harvest taken per
hectare. Reading an output series alone hides which half moved — and this
dossier's most misleading figure sits exactly there.

For 6 crops, the multiples between the first measured year and 2024:

| crop | yield multiple | area multiple |
|---|---|---|
| wheat | 3.31 | 1.85 |
| barley | 0.94 | 0.19 |
| rice | 1.59 | 2.09 |
| dates | 0.62 | 2.45 |
| maize | 5.27 | 50.00 |
| tomatoes | 2.97 | 1.12 |

Wheat is the country's most balanced success: yield up 3.31-fold, area up
1.85-fold. It was sown in more places and more was taken from each. In maize
the yield rose 5.27-fold — the largest agricultural gain among the six.

Barley is the only crop falling on both counts: yield down to 0.94, meaning
that after 63 years a hectare gives less than it did in 1961, and
area down to 0.19. Where both the area and the yield of a crop fall, there is
not improvement but withdrawal.

But the row that matters most is dates. The yield fell **to 0.62** — a hectare
of date grove today gives two thirds of what it gave in 1985. The area rose
2.45-fold. Section 9 will record that Iraq's date output rose 1.7-fold;
all of that rise, and more, comes from area. The country planted more trees and
took less from each.

This is what a reading of the output series alone cannot see. "Date production
rose" is true and misleading. The explanation of the lost world share in section 9 is here: the world raised its date yield while Iraq raised its
date area.$dsr$, array['verim_katlari', 'alan_katlari']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/irak/irak_kolza_tarlasi.jpg","atif":"Almejwal — CC BY-SA 3.0","kaynak":null,"alt_tr":"Çiçeklenmiş bir tarlada duran dört adam; biri elinde bir demet tutuyor.","alt_en":"Four men standing in a field in flower; one holds a bunch in his hand."}$dsr$::jsonb),
  (9, $dsr$Hurmayı bırakmadı, dünya onu geçti$dsr$, $dsr$It did not drop the date; the world passed it$dsr$, $dsr$Hurma Irak'ın adıyla anılan ürün. Ve Irak hurmayı bırakmadı.

1961'de 350.000 ton hurma üretiyordu; 2024'te 587.190 ton. 63 yılda
üretim 1,7 kat arttı. Aynı dönemde dünyanın hurma üretimi 5,4 kat arttı.

Sonuç şu: Irak'ın dünya hurma üretimindeki payı **%18,9'dan %5,9'a** indi.
Kaybedilen şey üretim değil, yer. Ülke aynı işi yapmaya devam etti; başkaları
daha hızlı büyüdü.

Serinin zirvesi 2000 yılında, 932.000 ton. Bugünkü üretim o zirvenin altında
ve 1961'in üstünde — yani eğri bir yükseliş değil, bir tepe ve bir iniş.

Zirve ile bugün arasındaki fark da ayrıca okunmayı hak ediyor. 2000'de 932.000
ton üretilmişti; bugün 587.190. Yani Irak yalnız dünyaya göre geri kalmadı,
kendi en iyi yılına göre de geriledi.

8. bölümdeki tablo bu inişin mekanizmasını veriyor: hurmada ekili alan
1985'ten bugüne 2,45 kat arttı, ama hektar başına alınan ürün 0,62 kata
indi. Yani Irak hurmaya daha çok toprak ayırdı ve her topraktan daha az
aldı. Üretimin yine de artmış görünmesi bu iki hareketin birbirini kısmen
götürmesinden.

Verimin düşmesinin adayları dosyanın içinde duruyor: 10. bölümdeki
tuzlanma, 4. bölümdeki su düzensizliği ve 5. bölümdeki savaş
hasarı. Hangisinin ne kadar pay aldığını bu dosya ölçmüyor ve ölçmediğini
yazıyor.

Bu, dosyadaki en sessiz kayıp. Bir ürünün çöküşü sayılarla görülür; bir
ürünün yerini kaybetmesi ancak başkalarının sayısıyla birlikte bakıldığında
görülür. Irak hurmada bugün hâlâ büyük bir üretici. Ama 1961'de dünyadaki her 5 hurmadan biri buradan çıkıyordu; bugün her 17'den biri.

Bir ürünü bırakmak bir karardır ve genelde görünür. Bir üründe yerini
kaybetmek karar değildir, sonuçtur — ve kimse bir gün oturup buna karar
vermediği için kimse de fark etmez.$dsr$, $dsr$The date is the crop Iraq is named with. And Iraq did not drop the date.

In 1961 it produced 350,000 tonnes of dates; in 2024, 587,190. Over
63 years output rose 1.7-fold. Over the same period world date
production rose 5.4-fold.

The result: Iraq's share of world date production fell from **18.9% to 5.9%**.
What was lost is not production but place. The country went on doing the same
work; others grew faster.

The peak of the series is the year 2000, at 932,000 tonnes. Today's output is
below that peak and above 1961 — the curve is not a rise but a summit and a
descent.

The gap between the peak and today deserves its own reading. In 2000, 932,000
tonnes were produced; today, 587,190. Iraq has fallen behind not only the
world but its own best year.

The table in section 8 gives the mechanism of that descent: the date
area has risen 2.45-fold since 1985, while the harvest per hectare fell to
0.62. Iraq gave dates more ground and took less from each piece of it. Output
still looks higher because the two movements partly cancel.

The candidates for the falling yield stand inside this dossier: the
salinisation of section 10, the irregular water of the fourth and the
war damage of the fifth. This dossier does not measure how much each
contributes, and says that it does not.

This is the quietest loss in the file. A crop's collapse is visible in its own
numbers; a crop's loss of place is visible only when read alongside other
people's numbers. Iraq is still a large date producer. But in 1961 1 date in
every 5 in the world came from here; today it is 1 in 17.

Dropping a crop is a decision and usually visible. Losing one's place in a
crop is not a decision but an outcome — and because nobody ever sat down and
decided it, nobody notices either.$dsr$, array['hurma_payi']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/irak/irak_hurma_genis.jpg","atif":"Ahmed alsari — CC BY-SA 4.0","kaynak":null,"alt_tr":"Yeşil örtü üstünde hurma ağaçları; solda bir elektrik direği ve iletim hatları geçiyor.","alt_en":"Date palms above green ground cover; a power pylon and transmission lines pass on the left."}$dsr$::jsonb),
  (10, $dsr$Toprağın tuzu$dsr$, $dsr$The salt of the soil$dsr$, $dsr$Mezopotamya ovasında su yukarıdan gelir ve aşağıda bir yere gitmek zorundadır.
Gidemezse buharlaşır ve tuzunu bırakır. Bu dosyadaki en eski sorun bu ve
bugün hâlâ ölçülüyor.

Dünya Bankası'nın 2014 tarihli proje belgesi iki rakam veriyor. Ekili alanın
*"70 percent of crop land is affected by high soil salinity"*, yani %70'i yüksek toprak tuzluluğundan etkileniyor. Tarihsel olarak sulanmış
alanın *"almost 40 percent of historically-irrigated areas out of production"*,
yani yaklaşık %40'ı üretim dışı.

İkinci rakam birincisinden daha ağır. "Etkilenmiş" bir tarla az ürün verir;
"üretim dışı" bir tarla hiç vermez. Bir ülkenin tarihsel olarak sulanmış
arazisinin beşte ikisinin kullanılamaz hale gelmesi, ekilebilir alanın
haritasının küçülmesi demek — ve o harita geri büyümüyor.

Her iki oran da 2014 tarihli bir belgenin ölçümüdür ve bu dosyada yılıyla
birlikte duruyor. Tuzlanma yavaş ilerleyen bir süreçtir; 10 yıl önceki bir
ölçüm bugünü yaklaşık olarak tarif eder, ama bugünün ölçümü değildir.

Tuzluluk yalnız tarlada değil. BM'nin 2011 tarihli bataklık raporu, güneydeki
sulak alanların suyunun *"has doubled in salinity in recent years"* diyor ve
aynı belgede tür çeşitliliğinin *"the variety of species also decreased from
70 to only 10"* olduğu yazıyor. Bu rakamlar bataklık ölçeğindedir; yukarıdaki
iki oran ülke ölçeğinde, ekili alana aittir. İkisi aynı şeyi saymıyor.

Tuzlanma, kuraklıktan farklıdır. Kuraklık gelir ve geçer; tuz kalır. 7. bölümdeki pirinç bir yıl ekilmeyip ertesi yıl ekilebilir, ama tuzlanmış bir
tarla ertesi yıl kendini onarmaz. 8. bölümde hurmanın veriminin
düşmesi de bu çerçeveye oturuyor: ağaç yerinde duruyor, toprak değişiyor.

Tuzlanmanın teknik çaresi bilinir ve pahalıdır: drenaj. Suyun tarlaya
girmesi kadar çıkması da gerekir, ve çıkışı sağlayan kanal ağı sulama
kanalından daha az görünür, daha az oy getirir, daha çok bakım ister.
Dosyanın ölçebildiği şey sonucu; sebebin bu kısmını ölçmüyor.$dsr$, $dsr$On the Mesopotamian plain water comes from above and has to go somewhere
below. If it cannot, it evaporates and leaves its salt. This is the oldest
problem in the dossier and it is still being measured today.

The World Bank's 2014 project document gives two figures. Of the cropland,
*"70 percent of crop land is affected by high soil salinity"*. Of the land
historically irrigated, *"almost 40 percent of historically-irrigated areas
out of production"*.

The second figure is heavier than the first. An affected field gives less; a
field out of production gives nothing. Two fifths of a country's historically
irrigated land becoming unusable means the map of what can be sown has shrunk
— and that map is not growing back.

Both ratios are the measurement of a document dated 2014 and stand here with
their year. Salinisation is a slow process; a measurement from 10 years ago
describes today approximately, but it is not today's measurement.

Salinity is not confined to the field. The UN's 2011 marshlands report says
the water of the southern wetlands *"has doubled in salinity in recent years"*
and records in the same document that *"the variety of species also decreased
from 70 to only 10"*. Those figures are at marshland scale; the two ratios
above are at country scale and belong to cropland. The two are not counting
the same thing.

Salinisation differs from drought. Drought comes and goes; salt stays. The
rice of section 7 can go unsown one year and be sown the next, but a
salinised field does not repair itself the following year. The falling date
yield of section 8 fits the same frame: the tree stands where it
stood, and the soil changes under it.

The technical remedy for salinisation is known and expensive: drainage. Water
must leave a field as surely as it enters, and the network that carries it out
is less visible than the one that brings it in, wins fewer votes and demands
more maintenance. What this dossier can measure is the outcome; this part of
the cause it does not measure.$dsr$, array['tuzluluk']::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/irak/irak_hurma_bostan.jpg","atif":"Usamasaad — CC BY-SA 4.0","kaynak":null,"alt_tr":"Bir köy bostanında hurma ağaçları; gövdelerin arasında yoğun yeşil örtü.","alt_en":"Date palms in a village garden, with dense green cover between the trunks."}$dsr$::jsonb),
  (11, $dsr$Koyun, manda ve bataklık$dsr$, $dsr$Sheep, buffalo and the marshes$dsr$, $dsr$Irak'ın hayvan varlığı 1961'den bugüne sayılıyor ve meradaki sürü küçülüyor.

Koyun 1968'de 13,1 milyon başla zirvedeydi. Bugün 6.672.540 baş — yarıdan az.
Yalnız 1990'dan bugüne bakıldığında düşüş %30,5. Keçi de %12,7 geriledi.
Sığır ise %38,4 arttı. Merada otlayan hayvan azalırken ahırda beslenen hayvan
çoğaldı; 6. bölümdeki arpa eğrisi bu cümlenin öteki yarısıdır.

Mandanın eğrisi ayrı bir şey anlatıyor. Ülke genelinde 1996'da 50.000 başla
dibe vurdu; bugün 269.940 baş, yani dipten 5,4 kat. Bu rakamlar ülke
ölçeğindedir.

BM'nin 2011 tarihli raporu ise başka bir şeyi, **bataklıktaki sürüyü**
sayıyor. Mandayı *"the most important animal in the Marshlands"* diye
tanımlıyor ve oradaki sayının *"from a high 80,000 to a current meager"*
rakamlara indiğini yazıyor. Aynı yıl ülke genelinde 302.000 baş manda vardı.
İki rakam çelişmiyor; farklı alanları ölçüyor.

Aynı rapor bataklıkların *"over 90% of the original Marshlands area were
drained or destroyed"* olduğunu ve bunun *"Since the 1970s and up to 2003"*
sürdüğünü yazıyor. Bugün *"roughly 38 per cent of the original Marshlands
area has been restored"*. Yani bir ülkenin güneyindeki sulak alanın onda
dokuzu bir insan ömrü içinde kurutuldu ve sonra üçte birinden biraz fazlası
geri verildi.

Bu, dosyadaki tek geri dönüş hikâyesi. Tuzlanmış tarla geri gelmiyor, arpa
geri gelmedi, hurmada kaybedilen yer geri alınmadı — ama bataklığın bir
bölümü geri geldi ve ülke genelindeki manda eğrisinin dipten çıkışı aynı
takvime denk düşüyor.

Oradaki gündelik tarım sudan ayrılmıyor: sazdan yapılmış ev, kıyıya bağlı
uzun kayık, suyun içinde otlayan manda ve *"to harvest food grains such as
rice and millet"* diye yazılan ekim. Bir hayvanın, bir evin ve bir ürünün
aynı suya bağlı olduğu bir tarım biçimi. Sulak alan kuruduğunda yalnız bir
ekosistem değil, bir geçim düzeni de gidiyor — ve geri geldiğinde ikisi
birlikte geri gelmek zorunda.$dsr$, $dsr$Iraq's livestock has been counted since 1961, and the flock on the pasture is
shrinking.

Sheep peaked in 1968 at 13.1 million head. Today there are 6,672,540 — less
than half. Measured from 1990 alone the fall is 30.5%. Goats are down 12.7%.
Cattle, by contrast, rose 38.4%. The pasture-grazed animal declined while the
barn-fed animal increased; the barley curve of section 6 is the other
half of that sentence.

The buffalo curve tells something else. Across the country it bottomed in 1996
at 50,000 head; today it stands at 269,940, 5.4 times the trough. These
figures are at country scale.

The UN's 2011 report counts something else, **the herd in the marshes**. It
describes the buffalo as *"the most important animal in the Marshlands"* and
records the number there falling *"from a high 80,000 to a current meager"*
level. In that same year the country as a whole held 302,000 head. The two
figures do not contradict each other; they measure different areas.

The same report writes that *"over 90% of the original Marshlands area were
drained or destroyed"* and that this ran *"Since the 1970s and up to 2003"*.
Today *"roughly 38 per cent of the original Marshlands area has been
restored"*. Nine tenths of a country's southern wetland was dried within a
single human lifetime, and then a little over a third of it was given back.

This is the only story of return in the dossier. A salinised field does not
come back, barley did not come back, the lost place in dates was not
recovered — but part of the marsh did come back, and the rise of the
country-wide buffalo curve from its trough falls on the same calendar.

Everyday farming there does not separate from the water: a house built of
reed, a long boat moored at the bank, buffalo grazing in the water, and the
sowing written as *"to harvest food grains such as rice and millet"*. A way of
farming in which an animal, a house and a crop all depend on the same water.
When a wetland dries, it is not only an ecosystem that goes but a way of
making a living — and when it returns, the two have to return together.$dsr$, array['hayvan', 'manda']::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/irak/irak_bataklik_taisir.jpg","atif":"Taisir Mahdi — CC BY-SA 4.0","kaynak":null,"alt_tr":"Bataklıkta sazdan yapılmış bir ev; önündeki toprakta iki manda duruyor, kıyıya uzun bir kayık bağlı.","alt_en":"A reed house in the marshes; two water buffalo stand on the ground in front of it and a long boat is moored at the bank."}$dsr$::jsonb),
  (12, $dsr$En hızlı büyüyen sürü$dsr$, $dsr$The fastest-growing flock$dsr$, $dsr$Irak'ın hayvan serilerinde en hızlı büyüyen kalem ne koyun, ne sığır, ne
manda. Tavuk.

1961'de ülkede 6,5 milyon baş tavuk vardı. 2022'de 162,5 milyonla zirve
yaptı; 2024'te 140 milyon. 63 yılda **21,5 kat**. Aynı dönemde koyun
yarıya indi.

Bu eğri, 10. ve 11. bölümlerin anlattığı şeyin en keskin hâli.
Koyun meraya, meradaki ot da yağışa bağlıdır; su azaldığında hem mera hem
yemlik arpa daralır ve sürü küçülür. Tavuk ise meraya bağlı değil. Kümeste
beslenir, yemi satın alınır, su ihtiyacı sürüsü başına koyundan çok daha
azdır. Bir ülkede su kısıtlanırken protein üretimi tamamen durmuyorsa,
genellikle kümese taşınıyor demektir.

Ama bu taşınmanın bir bedeli var ve dosyanın başka bir bölümünde duruyor.
Kümes hayvanı yem yer; yem ya ekilir ya satın alınır. 6. bölümde
Irak'ın arpa ekimini 0,19 kata indirdiğini gördük. 14. bölümde
Türkiye'nin Irak'a 298,1 milyon dolarlık yem artığı sattığını göreceğiz.
Üçü yan yana konduğunda ortaya çıkan cümle şu: ülke yem tahılını ekmeyi
azalttı, hayvanını yeme bağladı ve yemin bir bölümünü dışarıdan almaya
başladı.

Bu bir başarısızlık anlatısı değil — 21,5 katlık bir büyüme, bir ülkenin
hayvansal protein üretiminde gerçek bir kazançtır ve kuraklığa koyundan çok
daha dayanıklıdır. Ama bağımsızlığı azaltır. Merada otlayan bir koyun
yağmura bağlıdır; kümesteki bir tavuk yem piyasasına. İkisi de riske açık,
ama riskin cinsi farklı ve ikincisi ülkenin dışında duruyor.$dsr$, $dsr$The fastest-growing line in Iraq's livestock series is neither sheep nor
cattle nor buffalo. It is chickens.

In 1961 the country held 6.5 million head. In 2022 the number peaked at 162.5
million; in 2024 it stands at 140 million. Over 63 years, **21.5
times**. Sheep halved in the same period.

This curve is the sharpest form of what the tenth and eleventh sections
describe. Sheep depend on pasture, and pasture on rainfall; when water grows
scarce, both the grazing and the feed barley narrow and the flock shrinks.
Chickens do not depend on pasture. They are kept in coops, their feed is
bought, and their water need per head is far smaller than a sheep's. Where a
country's water is restricted and protein production does not stop, it has
usually moved indoors.

But that move has a price, and it sits in another section of this dossier.
Coop animals eat feed; feed is either sown or bought. Section 6 showed
Iraq's barley area falling to 0.19. Section 14 will show Türkiye selling
Iraq 298.1 million dollars of feed residues. Put the three side by side and
the sentence is this: the country sowed less feed grain, tied its animals to
feed, and began buying part of that feed from outside.

This is not a story of failure — a 21.5-fold increase is a real gain in a
country's animal protein, and far more drought-resistant than sheep. But it
reduces independence. A sheep on pasture depends on rain; a chicken in a coop
depends on the feed market. Both carry risk, but the kind differs, and the
second sits outside the country.$dsr$, array['tavuk']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/irak/irak_kumes.jpg","atif":"Kani Ronningen, U.S. Army — Public domain","kaynak":null,"alt_tr":"Bir broyler kümesinin içi: toprak zeminde yüzlerce beyaz piliç, aralarında yemlikler ve suluklar; arkada çalışanlar.","alt_en":"Inside a broiler shed: hundreds of white birds on an earth floor among feeders and drinkers, with workers at the back."}$dsr$::jsonb),
  (13, $dsr$Sonradan gelenler$dsr$, $dsr$The latecomers$dsr$, $dsr$Irak'ın ürün haritası 63 yılda yalnız kaybetmedi; iki yerde de
belirgin biçimde değişti.

Mısır 1961'de Irak'ta neredeyse yoktu: 2.000 hektar. Bugün 100.000 hektar,
yani alan 50 kat arttı. Verim de 5,27 kat arttı ve bu, dosyadaki altı
ürünün en büyük verim kazancı. Üretim 2013'te 831 bin tonla zirve yaptı,
2024'te 500 bin ton.

Mısırın yükselişi tesadüf değil: 12. bölümdeki tavuk eğrisiyle aynı
yöne gidiyor. Kümes hayvanının yemi büyük ölçüde mısırdır. Bir ülkede tavuk
21,5 kat artarken mısır alanının 50 kat artması, iki ayrı tarım kararı
değil, aynı kararın iki yüzü.

Domates başka bir eğri çiziyor. 1961'de 138,7 bin tondu, 2001'de 1.321 bin
tonla zirve yaptı, 2024'te 463,2 bin ton. Alanı neredeyse hiç değişmedi —
19.545 hektardan 21.985 hektara, yani 1,12 kat. Verimi ise 2,97 kat arttı.

Yani domateste Irak doğru olanı yaptı: aynı toprakta 3 kat daha çok ürün
aldı. Ama zirveden bugüne üretim üçte bire indi ve bunun sebebi alan da
değil verim de değil — zirve yıllarındaki ekim düzeyinin sürdürülememesi.
Seri, 2001'den sonra bir platoya değil bir inişe geçiyor.

Bu iki ürün dosyanın geri kalanını dengeliyor. Buğdayda, arpada, hurmada ve
pirinçte anlatılan şey kısıt ve kayıptı. Mısır ve domates, aynı ülkede aynı
yıllarda verimin 2 ila 5 kat artabildiğini gösteriyor. Sorun toprağın
ya da çiftçinin kapasitesi değil; suyun ve girdinin öngörülebilirliği.$dsr$, $dsr$Iraq's crop map did not only lose over 63 years; in two places it
changed markedly.

Maize was almost absent from Iraq in 1961: 2,000 hectares. Today it covers
100,000 — the area rose 50-fold. The yield rose 5.27-fold as well, the
largest yield gain among the dossier's 6 crops. Output peaked at 831
thousand tonnes in 2013 and stands at 500 thousand in 2024.

Maize's rise is not a coincidence: it runs in the same direction as the
chicken curve of section 12. Coop feed is largely maize. A country
whose chickens rise 21.5-fold while its maize area rises 50-fold is not
making two separate agricultural decisions but showing two faces of one.

Tomatoes draw a different curve. Output was 138.7 thousand tonnes in 1961,
peaked at 1,321 thousand in 2001, and stands at 463.2 thousand in 2024. The
area barely moved — from 19,545 hectares to 21,985, a factor of 1.12. The
yield rose 2.97-fold.

So in tomatoes Iraq did the right thing: 3 times as much from the same
soil. But output has fallen to a third of its peak, and the cause is neither
area nor yield — it is that the planting level of the peak years was not
sustained. After 2001 the series does not level off; it descends.

These two crops balance the rest of the dossier. What wheat, barley, dates and
rice describe is constraint and loss. Maize and tomatoes show that in the same
country and the same years yields could rise 2 to 5 times. The problem is
not the capacity of the soil or of the farmer; it is the predictability of
water and inputs.$dsr$, array['yeni_urunler']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/irak/irak_souk_kerkuk.jpg","atif":"James (Jim) Gordon — CC BY 2.0","kaynak":null,"alt_tr":"Kerkük'te bir sokak satıcısı, önünde iki hasır sepet: birinde kırmızı meyve, ötekinde nohut.","alt_en":"A street seller in Kirkuk behind two wicker baskets, one of red fruit and one of chickpeas."}$dsr$::jsonb),
  (14, $dsr$Türkiye ne satıyor$dsr$, $dsr$What Türkiye sells$dsr$, $dsr$Türkiye'nin Irak'a sattığı 4,64 milyar dolarlık tarım ürünü 24 faslın tamamına yayılıyor, ama ağırlık birkaç yerde toplanıyor.

En büyük kalem hamur işleri ve bisküvi: 538,9 milyon dolar. Ardından meyve ve
yemiş 498,3 milyon, un ve değirmen ürünleri 496,6 milyon, et 444,4 milyon,
sebze 432,8 milyon, hububat 408,3 milyon geliyor. Katı ve sıvı yağ 339,6
milyon, yem artıkları 298,1 milyon.

Listeye tek tek bakmak yanıltıcı olabilir. Hububat, un ve hamur işleri aslında
tek bir zincirin üç halkası: buğday, buğdayın öğütülmüşü ve öğütülmüşün
pişmişi. Üçü birlikte 1,44 milyar dolar, yani Türkiye'nin Irak'a tarım
satışının %31,1'i.

Bu, ham madde satan bir ülkenin listesi değil. Un ve hamur işleri, hububatın
kendisinden daha büyük. Türkiye bu hatta tahıl değil, tahılın işlenmiş hâlini
gönderiyor.

Listenin ortası da bir şey söylüyor. Kakao ve çikolata 171,5 milyon, çeşitli
gıda müstahzarları 168,9 milyon, tütün 151,3 milyon, şeker ve şekerleme
131,5 milyon dolar. Bunların hiçbiri temel gıda değil; hepsi raf ürünü. Bir
ülkeye hem unu hem bisküviyi hem çikolatayı satıyorsanız, o ülkenin yalnız
açlığına değil market rafına da satıyorsunuz demektir.

Alt sıralarda ise liste neredeyse boşalıyor: canlı hayvan 6,5 milyon, çiçek
ve canlı bitki 5,4 milyon, kahve-çay-baharat 5,3 milyon dolar. En dipte
bitkisel örgü maddeleri 0,05 milyon ve hayvansal ürünler sıfır. 24 faslın hepsinde ticaret var ama son altısının toplamı, ilk kalemin yüzde
beşini bulmuyor.

Süt ürünleri, yumurta ve bal faslı 179,3 milyon dolarla ilk ona giriyor; yem
artıkları 298,1 milyon. Birincisi doğrudan sofraya giden bir kalem, ikincisi
Irak'ın kendi hayvanını beslemek için aldığı girdi. 6. bölümde arpa
ekiminin bırakıldığını gösteren eğri, 12. bölümdeki tavuk eğrisi ve bu
kalem aynı cümlenin üç parçası.

Rakamlar Türkiye'nin beyanından. Irak'ın bu malları kimden, hangi fiyatla ve
ne kadarını aldığına dair kendi beyanı bu veritabanında yok. Dolayısıyla
buradaki liste "Irak ne ithal ediyor" sorusunun cevabı değil; "Türkiye Irak'a
ne ihraç ediyor" sorusunun cevabı. İkisi aynı şey değildir ve bu dosya
ikincisini yazıyor.$dsr$, $dsr$The 4.64 billion dollars of agricultural produce Türkiye sells to Iraq spreads
across all 24 chapters, but the weight gathers in a few places.

The biggest single line is bakery goods and biscuits: 538.9 million dollars.
Then fruit and nuts at 498.3 million, flour and milling products at 496.6
million, meat at 444.4 million, vegetables at 432.8 million and cereals at
408.3 million. Fats and oils come to 339.6 million, feed residues to 298.1
million.

Reading the list item by item can mislead. Cereals, flour and bakery goods are
in fact three links of one chain: wheat, wheat ground, and the ground wheat
baked. Together they come to 1.44 billion dollars — 31.1% of Türkiye's
agricultural sales to Iraq.

This is not the list of a country selling raw material. Flour and bakery goods
are larger than the cereals themselves. On this line Türkiye sends not grain
but grain already worked.

The middle of the list says something too. Cocoa and chocolate at 171.5
million, miscellaneous food preparations at 168.9 million, tobacco at 151.3
million, sugar and confectionery at 131.5 million dollars. None of these is a
staple; all are shelf goods. Selling a country its flour, its biscuits and its
chocolate means selling not only to its hunger but to its supermarket shelf.

Lower down the list almost empties: live animals at 6.5 million, cut flowers
and live plants at 5.4 million, coffee, tea and spices at 5.3 million dollars.
At the very bottom, vegetable plaiting materials at 0.05 million and animal
products at zero. There is trade in all 24 chapters, but the last six
together do not reach 5% of the first line.

Dairy, eggs and honey enter the top ten at 179.3 million dollars; feed
residues stand at 298.1 million. The first goes straight to the table, the
second is an input Iraq buys to feed its own animals. The curve in section 6 showing barley abandoned, the chicken curve of the twelfth and this
line are three parts of one sentence.

The figures come from Türkiye's reporting. Iraq's own declaration of whom it
bought these goods from, at what price and in what quantity is not in this
database. The list is therefore not the answer to "what does Iraq import" but
to "what does Türkiye export to Iraq". They are not the same thing, and this
dossier writes the second.$dsr$, array['fasillar']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/irak/irak_pazar_musul.jpg","atif":"Abdulsalam Al Dabbagh — CC BY-SA 4.0","kaynak":null,"alt_tr":"Musul'da kapalı bir sebze-meyve halinin içi: ahşap tezgâhlar dizili, hal boş.","alt_en":"Inside a covered fruit and vegetable hall in Mosul: wooden stalls in rows, the hall empty."}$dsr$::jsonb),
  (15, $dsr$Ters yön neredeyse boş$dsr$, $dsr$The other direction is almost empty$dsr$, $dsr$Aynı defterin öteki sayfası 30,2 milyon dolar.

Irak'tan Türkiye'ye gelen tarım ürünlerinin en büyüğü içecekler: 8,19 milyon
dolar. Sonra hububat 7,89 milyon, et 3,01 milyon, meyve ve yemiş 2,85 milyon,
işlenmiş sebze-meyve 2,79 milyon, sebze 2,60 milyon.

Bu kalemlerin her biri, karşı yöndeki aynı fasıldan yüzlerce kat küçük. Giden
ile gelen arasındaki oran 154 kat. Somut bir karşılaştırma: Türkiye'nin
Irak'a sattığı yalnızca hamur işleri (538,9 milyon dolar), Irak'tan gelen
bütün tarım ürünlerinin 17 katından fazla.

Dengesizliğin sebebini bu rakamlar söylemiyor. Bir ülkenin satacak fazlası
olmayabilir; lojistiği, standardı ya da ticaret düzeni elverişsiz olabilir;
ya da ürettiğini kendi yiyordur. Dosyanın önceki bölümleri bu ihtimallerin
bir kısmına ölçü veriyor — tuzlanan tarla, bırakılan arpa, kapatılan pirinç,
hurmada düşen verim — ama hiçbiri tek başına 154 katı açıklamıyor.

3. bölümdeki nüfus ve tarım payı rakamları bir ipucu veriyor: 47,0
milyon nüfuslu, tarımın petrol dışı ekonominin %35'ini tuttuğu bir ülke,
ürettiğinin büyük bölümünü içeride tüketiyor olabilir. Bu bir açıklama
değil, ölçülmemiş bir ihtimal — Irak'ın kendi üretim-tüketim dengesi bu
dosyanın verisinde yok.

Gelen listenin başında içeceklerin durması ayrıca dikkat çekici. Bir tarım
ülkesinin komşusuna sattığı en büyük kalemin ham ürün değil şişelenmiş bir
içecek olması, ihracatın tarladan değil fabrikadan çıktığını gösteriyor.
Hububatın ikinci sırada olması ise mevsimlik: Irak bazı yıllar buğday fazlası
verir ve bir kısmını kuzeye satar.

Yine hatırlatmak gerekiyor: bu sayfanın iki yanı da Türkiye'nin beyanından.
Irak kendi ticaret istatistiğini bu veritabanına vermiyor, dolayısıyla "Irak
ne kadar ihraç etti" sorusunun cevabı burada yok; burada olan "Türkiye Irak'tan
ne kadar aldı" sorusunun cevabı. Bu ayrımı yapmayan bir okuma, Irak'ın hiç
tarım ihracatı olmadığı sonucuna varır ki bu dosya böyle bir şey söylemiyor.$dsr$, $dsr$The other page of the same ledger is 30.2 million dollars.

The largest agricultural line coming from Iraq to Türkiye is beverages: 8.19
million dollars. Then cereals at 7.89 million, meat at 3.01 million, fruit and
nuts at 2.85 million, processed fruit and vegetables at 2.79 million, and
vegetables at 2.60 million.

Each of these is hundreds of times smaller than the same chapter in the
opposite direction. The ratio between what goes and what comes is 154 to 1.
A concrete comparison: bakery goods alone, at 538.9 million dollars, are more
than 17 times everything agricultural that comes the other way.

These figures do not say why the imbalance exists. A country may have no
surplus to sell; its logistics, standards or trade arrangements may be
unfavourable; or it may be eating what it produces. The earlier sections give
measurements for some of those possibilities — the salting field, the dropped
barley, the switched-off rice, the falling date yield — but none of them alone
explains a factor of 154.

The population and agricultural-share figures of section 3 offer a
clue: a country of 47.0 million where farming holds 35% of the non-oil economy
may well consume most of what it produces. That is not an explanation but an
unmeasured possibility — Iraq's own production-consumption balance is not in
this dossier's data.

That beverages head the incoming list is itself notable. When a farming
country's largest line to its neighbour is not a raw crop but a bottled drink,
the export is leaving the factory rather than the field. Cereals in second
place is seasonal: in some years Iraq has a wheat surplus and sells part of it
north.

It bears repeating: both sides of this page come from Türkiye's reporting.
Iraq does not give its own trade statistics to this database, so the answer to
"how much did Iraq export" is not here; what is here is the answer to "how much
did Türkiye buy from Iraq". A reading that misses the distinction concludes
that Iraq has no agricultural exports at all, which is not what this dossier
says.$dsr$, array['akis']::text[], 'akis', $dsr${"url":"https://tarimportali.net/dosya/irak/irak_silo_bagdat.jpg","atif":"Hamody al-iraqi — CC BY-SA 4.0","kaynak":null,"alt_tr":"Bağdat'ta bir tahıl silosu, ağaçların arasından görünüyor.","alt_en":"A grain silo in Baghdad, seen through trees."}$dsr$::jsonb),
  (16, $dsr$1946: suyun protokolü$dsr$, $dsr$1946: the protocol of the water$dsr$, $dsr$Suyun yukarıdan gelmesi yeni bir mesele değil. İki ülke bunu 29 Mart 1946'da
yazılı hale getirdi.

Belgenin adı **DÎCLE, FIRAT VE KOLLARI SULARININ DÜZENE KONMASI PROTOKOLÜ**.
6 maddesi var ve her maddesi bugünkü tartışmanın bir parçasını önceden
kuruyor.

Birinci madde teknisyeni ve haritayı düzenliyor; *"bütün harcamaları Irak
tarafından yüklenilecek"*. Üçüncü madde Türkiye'nin *"daimî gözetleme
istasyonları kuracak"* olduğunu söylüyor, işletme giderinin *"Türkiye ve Irak
tarafından yarı"* yarıya paylaşılacağını ekliyor ve istasyonların yerini
sayıyor: Dicle üzerinde *"Dicle üzerindeki Diyarbakır, Cizre"*, Fırat üzerinde
*"Fırat üzerindeki Keban"*.

Masrafların bölüşümü de tek başına anlamlı. Ölçüm altyapısının kurulması
Irak'ın, işletilmesi iki ülkenin. Yani 1946'da ölçmek isteyen taraf aşağıdaki
ülkeydi ve bedelini de o üstlendi; yukarıdaki ülke yalnız istasyonu kurup
işletmeyi kabul etti.

Dördüncü madde en dikkat çekici olanı. Yapılacak düzenleme yapılarının her
biri ayrı bir anlaşmaya konu olacak — *"Türkiye'nin sulama ve enerji elde etme
maksadiyle onlardan faydalanması bakımından ayrı bir Anlaşmaya konu teşkil
eyliyecektir"*. 1946'da, Devlet Su İşleri kurulmadan 7 yıl önce, Türkiye'nin
kendi sulama ve enerji kullanımı protokolün dışında bırakılmış.

Beşinci madde ise tek bir fiille yazılmış: Türkiye tasarılarını *"Irak'a haber
vermeyi kabul eyler"*. Haber vermek, onay almak değildir. Aradaki fark
80 yıl sonra hâlâ duruyor — ve 4. bölümdeki Dünya Bankası
cümlesinin *"not subject to well-established cross-border agreements"*
ifadesi, tam da bu farkın bugünkü adıdır.

Bir ayrıntı da Keban'da. 1946'da Keban bu protokolde bir telgraf gözlem
noktasıdır: her sabah saat 8'de su seviyesinin bildirileceği yer. Bu
dizinin Kurum Dosyası Sayı 05'i aynı Keban'ı, Güneydoğu Anadolu Projesi'nin
Fırat üzerindeki 5 barajından biri olarak anlatıyor. Aynı ad, aynı nehir,
80 yıl arayla iki ayrı şey: önce suyun ölçüldüğü yer, sonra tutulduğu
yer.$dsr$, $dsr$That the water comes from upstream is not a new matter. The two countries put
it in writing on 29 March 1946.

The document is titled **DÎCLE, FIRAT VE KOLLARI SULARININ DÜZENE KONMASI
PROTOKOLÜ** — the protocol on the regulation of the waters of the Tigris, the
Euphrates and their tributaries. It has 6 articles, and each sets up part of
today's argument in advance.

The first article arranges the technicians and the maps; *"all expenses to be
borne by Iraq"*. The third says Türkiye *"shall establish permanent observation
stations"*, adds that the running cost shall be shared *"half by Türkiye and
half by Iraq"*, and names where they stand: on the Tigris *"Diyarbakır and
Cizre on the Tigris"*, on the Euphrates *"Keban on the Euphrates"*.

The division of costs is itself telling. Building the measuring infrastructure
falls to Iraq, running it to both. In 1946 the party that wanted measurement
was the downstream country, and it bore the cost; the upstream country only
agreed to build and operate the station.

The fourth article is the most striking. Each regulating structure to be built
will be the subject of a separate agreement — *"shall form the subject of a
separate Agreement as regards Türkiye's use of them for irrigation and the
generation of energy"*. In 1946, 7 years before the State Hydraulic Works
was founded, Türkiye's own irrigation and energy use was left outside the
protocol.

The fifth article is written with a single verb: Türkiye *"accepts to inform
Iraq"* of its projects. To inform is not to seek consent. The difference is
still standing 80 years later — and the World Bank's phrase from section 4, *"not subject to well-established cross-border agreements"*,
is that same difference under its present name.

One detail sits at Keban. In 1946 Keban is a telegraph observation point in
this protocol: the place where the water level is to be reported at 8 each
morning. Issue 05 of this series' Institution Dossier describes the same Keban
as one of the 5 dams of the Southeastern Anatolia Project on the Euphrates.
The same name, the same river, two different things 80 years apart: first
the place where water was measured, then the place where it is held.$dsr$, array['protokol']::text[], 'belge', $dsr${"url":"https://tarimportali.net/dosya/irak/irak_firat_kayik.jpg","atif":"Christiaan Briggs — CC BY-SA 3.0","kaynak":null,"alt_tr":"Fırat'ta iki kişinin kürek çektiği ahşap kayık; karşı kıyıda hurma ağaçları.","alt_en":"A wooden boat rowed by two people on the Euphrates; date palms on the far bank."}$dsr$::jsonb),
  (17, $dsr$Türkiye buradan ne görebilir$dsr$, $dsr$What Türkiye can see from here$dsr$, $dsr$Bu dosyanın ölçtüğü şeylerin çoğu Irak'a ait. Ama birkaçı, aynı havzanın
yukarısında duran ülke için de okunabilir.

Birincisi tuz. Irak'ta ekili alanın %70'i yüksek toprak tuzluluğundan
etkileniyor ve tarihsel olarak sulanmış alanın %40'ı üretim dışı. Bunun
sebebi iklim değil drenaj: suyun tarlaya girmesi kadar çıkması da gerekir.
Türkiye'nin sulama altyapısı genç ve büyük bölümü son 50 yılda kuruldu;
tuzlanma yavaş ilerleyen bir süreç olduğu için bir sulama sisteminin drenaj
açığı onlarca yıl sonra görünür. Irak'ın bugünü, drenaj olmadan sulamanın
uzun vadede ne ürettiğinin ölçülmüş bir örneği.

İkincisi alan ile verim ayrımı. 8. bölümdeki tablo gösteriyor ki bir
ülkenin üretimi artarken verimi düşebiliyor ve bu, uzun süre fark
edilmeyebiliyor. Hurmada Irak alanı 2,45 kat büyüttü, verimi 0,62 kata
düşürdü ve üretim serisi hâlâ "artıyor" diye okunabiliyordu. Aynı hesap her
ülkenin kendi ürün serileri için yapılabilir.

Üçüncüsü yem bağımlılığı. Irak arpa ekimini 0,19 kata indirdi, tavuğunu
21,5 kat artırdı ve yem artığını dışarıdan almaya başladı. Hayvansal
üretimi büyütmenin en hızlı yolu kümestir, ama kümes yemle çalışır ve yem
ithal edilebilir bir maldır. Bu, üretimi artırırken bağımlılığı da artıran
bir yoldur.

Dördüncüsü hattın kendisi. Türkiye'nin tarım ihracatının %14,3'ü tek bir
komşuya gidiyor ve o komşunun ters yöndeki satışı 154 kat küçük. Böyle bir
hat satıcı için kârlıdır ve kırılgandır: tek bir pazarın gümrük, kur ya da
politika kararı, Türkiye'nin tarım ihracatının yedide birini aynı anda
etkiler. Bu dosya o riski ölçmüyor; yalnız hattın ne kadar tek yönlü
olduğunu ölçüyor.

Beşincisi 1946'dan kalan fark. Protokol Türkiye'nin tasarılarını Irak'a
*"haber vermeyi kabul eyler"* diyor. 80 yıl sonra Dünya Bankası aynı
havza için *"not subject to well-established cross-border agreements"*
yazıyor. İki belge arasındaki mesafe, bir sınır ötesi su düzeninin
kurulmamış olmasının ne kadar uzun sürebileceğini gösteriyor.$dsr$, $dsr$Most of what this dossier measures belongs to Iraq. But a few of its
measurements can also be read by the country upstream in the same basin.

The first is salt. In Iraq 70% of cropland is affected by high soil salinity
and 40% of the historically irrigated area is out of production. The cause is
not climate but drainage: water must leave a field as surely as it enters.
Türkiye's irrigation infrastructure is young and largely built in the last 50 years; because salinisation advances slowly, a drainage shortfall in an
irrigation system becomes visible only decades later. Iraq's present is a
measured example of what irrigation without drainage produces in the long run.

The second is the distinction between area and yield. The table in section 8 shows that a country's output can rise while its yield falls, and that
this can go unnoticed for a long time. In dates Iraq grew the area 2.45-fold,
let the yield fall to 0.62, and the output series could still be read as
"rising". The same arithmetic can be done for any country's own crop series.

The third is feed dependence. Iraq cut its barley area to 0.19, raised its
chickens 21.5-fold and began buying feed residues from outside. The fastest
route to more animal production is the coop, but the coop runs on feed and
feed is an importable good. It is a route that raises output and dependence
together.

The fourth is the line itself. 14.3% of Türkiye's agricultural exports go to a
single neighbour, and that neighbour's sales in the other direction are 154
times smaller. Such a line is profitable for the seller and fragile: a single
market's customs, currency or policy decision affects one seventh of Türkiye's
agricultural exports at once. This dossier does not measure that risk; it
measures only how one-directional the line is.

The fifth is the gap left over from 1946. The protocol says Türkiye *"accepts
to inform Iraq"* of its projects. 80 years later the World Bank writes of
the same basin that it is *"not subject to well-established cross-border
agreements"*. The distance between the two documents shows how long the
absence of a cross-border water settlement can last.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/irak/irak_bataklik_mashoof.jpg","atif":"Hassan Janali, U.S. Army Corps of Engineers — Public domain","kaynak":null,"alt_tr":"Sazların arasındaki dar su yolunda uzun bir kayık; biri ayakta sırıkla, biri oturarak kürek çekiyor.","alt_en":"A long boat on a narrow channel between reeds; one person poles standing, another paddles seated."}$dsr$::jsonb),
  (18, $dsr$Kaynakça$dsr$, $dsr$Sources$dsr$, $dsr$**Ticaret.** UN Comtrade, muhabir Türkiye (reporterCode 792), partner Irak
(368), HS 01-24, 2024. Çift sayım süzgeci uygulandı: customsCode C00, motCode
0, partner2Code 0 — hem sorguda hem gelen satırda. Irak'ın muhabir olarak
döndürdüğü satır sayısı ayrıca ölçüldü: 2016, 2018 ve 2020 için sıfır; 2022 ve
2024 için bir.

**Üretim ve hayvan varlığı.** FAOSTAT, Production_Crops_Livestock toplu
indirmesi, Irak ve dünya satırları, 1961-2024. Alan ve ürün agregaları
kullanılmadı; yalnız tek tek ürünler okundu. Boş hücre atlandı, sıfır
yazılmadı. Verim değerleri üretimin hasat edilen alana bölünmesiyle
hesaplandı; FAOSTAT'ın kendi verim serisi kullanılmadı.

**Makro göstergeler.** Dünya Bankası açık veri API'si; her kalem kendi en
yeni dolu yılıyla. Sulanan arazi payı göstergesinin Irak karşılığı boştur;
3. bölüm bu boşluğu anıyor.

**Su ve tuzluluk.** Dünya Bankası, PID P149803 (2014). Tarımın petrol dışı
GSYH'deki payı da bu belgeden; toplam GSYH payı API'den. İki payda ayrı ayrı
yazıldı.

**Savaş hasarı.** FAO, Iraq Agriculture and Livelihoods Needs Assessment,
Şubat 2016. Kerkük, Ninova ve Selahaddin'de yeni kurtarılmış alanların saha
ölçümü.

**Bataklıklar.** United Nations Integrated Water Task Force for Iraq,
"Managing Change in the Marshlands: Iraq's Critical Challenge", BM Beyaz
Kitap, 2011. Bu belgedeki bütün rakamlar bataklık ölçeğindedir.

**Gen bankası.** United Nations in Iraq / FAO Irak duyurusu, 19 Mayıs 2024.
Ebu Garib tohum bankasının 1977'den beri çalıştığı ve altyapısının hasar
gördüğü bu belgeden okundu. Bankanın geçmişine dair ikincil anlatılar bu
dosyaya girmedi; yalnız duyurunun kendi ifadeleri kullanıldı.

**Su kaynakları.** FAO, Review of World Water Resources by Country. Belge
eskidir; burada güncel bir oran için değil, Irak'ın yenilenebilir suyunun
yarısından fazlası için başka ülkelere bağlı ülkeler arasında sayıldığını
göstermek için kullanıldı.

**1946 protokolü.** TBMM S. Sayısı 241, 1947 onay tasarısı; antlaşma ve
protokol metinleri ek olarak basılı. Alıntılar bu nüshanın kendi yazımıyla
verildi.$dsr$, $dsr$**Trade.** UN Comtrade, reporter Türkiye (reporterCode 792), partner Iraq
(368), HS 01-24, 2024. The double-counting filter was applied: customsCode
C00, motCode 0, partner2Code 0 — both in the query and on the returned rows.
The number of rows Iraq returns as a reporter was measured separately: zero
for 2016, 2018 and 2020; one each for 2022 and 2024.

**Production and livestock.** FAOSTAT, Production_Crops_Livestock bulk
download, Iraq and world rows, 1961-2024. Area and item aggregates were not
used; only individual items were read. Empty cells were skipped, not written
as zero. Yields were computed by dividing production by harvested area;
FAOSTAT's own yield series was not used.

**Macro indicators.** World Bank open data API, each item at its own most
recent filled year. The irrigated-land indicator has no Iraq value; section 3 notes that hole.

**Water and salinity.** World Bank, PID P149803 (2014). Agriculture's share of
non-oil GDP also comes from this document; the total-GDP share comes from the
API. The two denominators are written separately.

**War damage.** FAO, Iraq Agriculture and Livelihoods Needs Assessment,
February 2016. A field measurement of newly retaken areas in Kirkuk, Nineveh
and Salahaddin.

**The marshes.** United Nations Integrated Water Task Force for Iraq,
"Managing Change in the Marshlands: Iraq's Critical Challenge", UN White
Paper, 2011. Every figure from this document is at marshland scale.

**The seed bank.** United Nations in Iraq / FAO Iraq announcement, 19 May
2024. That the Abu Ghraib seed bank has been operational since 1977 and has
suffered infrastructural damage was read from this document. Secondary
accounts of the bank's history did not enter this dossier; only the
announcement's own wording was used.

**Water resources.** FAO, Review of World Water Resources by Country. The
document is old; it is used here not for a current ratio but to show that Iraq
is counted among the countries depending on others for more than half of their
renewable water.

**The 1946 protocol.** Turkish Grand National Assembly print no. 241, the 1947
ratification bill; the treaty and protocol texts are printed as annexes.
Quotations are given in translation from that print.$dsr$, '{}'::text[], 'belge', $dsr${"url":"https://tarimportali.net/dosya/irak/irak_manda.jpg","atif":"Adnan S mohmmod — CC BY-SA 4.0","kaynak":null,"alt_tr":"Nehir kıyısındaki toprak sette duran manda sürüsü; birkaçı suya inmiş.","alt_en":"A herd of water buffalo on an earth bank by the river, a few of them down at the water."}$dsr$::jsonb)
) as v(ord, title_tr, title_en, body_tr, body_en, chart_keys, tur, gorsel)
where d.slug = 'irak';

-- Sağlama: beklenen bölüm sayısı yazılmadıysa işlem geri alınır.
do $kontrol$
declare n integer;
begin
  select count(*) into n
    from public.dossier_sections s
    join public.country_dossiers d on d.id = s.dossier_id
   where d.slug = 'irak';
  if n <> 18 then
    raise exception 'Bölüm sayısı 18 olmalıydı, % yazıldı', n;
  end if;
end
$kontrol$;
-- ════════════════════════════════════════════════════════════════════════
-- SAĞLAMALAR — veritabanının KENDİ içeriğini sınıyor
-- ════════════════════════════════════════════════════════════════════════
do $kontrol_irak$
declare d_id uuid; n integer; t text;
begin
  select id into d_id from public.country_dossiers where slug = 'irak';
  if d_id is null then raise exception 'irak satırı yazılmadı'; end if;

  select status into t from public.country_dossiers where id = d_id;
  if t is distinct from 'draft' then
    raise exception 'irak durumu draft olmalıydı, % bulundu — bu göç devir göçü değil', t;
  end if;

  select count(*) into n from public.dossier_sections where dossier_id = d_id;
  if n <> 18 then raise exception 'Bölüm sayısı 18 olmalıydı, % bulundu', n; end if;

  -- Çizicinin tanımadığı biçim — DSİ'de canlıya giden hatanın karşılığı
  select count(*) into n from public.dossier_sections
   where dossier_id = d_id
     and (body_tr like '%###%' or body_en like '%###%'
          or body_tr ~ '(^|\n)>' or body_en ~ '(^|\n)>');
  if n > 0 then
    raise exception '% bölümün gövdesinde çizicinin tanımadığı biçim var', n;
  end if;

  -- Ölçek uyarısı: iki manda rakamı aynı bölümdeyse kapsam yazılmış olmalı
  select count(*) into n from public.dossier_sections
   where dossier_id = d_id
     and body_tr like '%80.000%' and body_tr like '%302.000%'
     and body_tr not like '%ülke ölçeğindedir%';
  if n > 0 then raise exception 'Ölçek uyarısı olmadan iki manda rakamı aynı bölümde'; end if;

  select count(*) into n
    from jsonb_object_keys((select charts from public.country_dossiers where id = d_id)) k;
  if n <> 16 then raise exception 'Grafik sayısı 16 olmalıydı, % bulundu', n; end if;

  select (theme->'palet'->'koyu'->'vurgu'->>'hex') into t
    from public.country_dossiers where id = d_id;
  if t is distinct from '#E3A94A' then
    raise exception 'Tema vurgusu tasarim.json''dan gelmedi: %', t;
  end if;

  -- UZUNLUK — dizinin ortalamasının altına düşmemeli (kullanıcı kuralı)
  -- KELİME SAYIMI: ayraç yalnız boşluk DEĞİL. Metin sabit genişlikte
  -- sarılmış, yani kelimelerin bir kısmını satır sonu ayırıyor. İlk sürüm
  -- yalnız boşluk sayıyordu ve 4.470 kelimelik gövdeyi 4.020 görüp göçü
  -- haksız yere durduruyordu. Satır sonu da ayraçtır.
  select sum(length(body_tr)
             - length(replace(replace(body_tr, ' ', ''), chr(10), '')) + 1) into n
    from public.dossier_sections where dossier_id = d_id and ord < 18;
  if n < 4300 then
    raise exception 'Gövde yaklaşık % kelime — Rusya/Avustralya ortalamasının (4358) altında', n;
  end if;

  -- HER BÖLÜMDE GÖRSEL (kullanıcı kuralı, 3 Kasım 2026)
  select count(*) into n from public.dossier_sections
   where dossier_id = d_id and (gorsel is null or gorsel->>'url' is null);
  if n > 0 then raise exception '% bölümün görseli yok', n; end if;

  -- TEZ CÜMLESİNDE RAKAM — sayılar artık yazıyla değil rakamla
  select thesis_tr into t from public.country_dossiers where id = d_id;
  if t !~ '[0-9]' then
    raise exception 'Tez cümlesinde hiç rakam yok — sayılar rakamla yazılıyor';
  end if;

  select status into t from public.country_dossiers where slug = 'avustralya';
  if t is distinct from 'published' then
    raise exception 'Avustralya durumu değişmiş (%) — bu göç ona dokunmamalıydı', t;
  end if;
end
$kontrol_irak$;
