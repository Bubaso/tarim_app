-- TİGEM — Tarım İşletmeleri Genel Müdürlüğü — Ülke Dosyası · seed
--
-- ÜRETİLMİŞ DOSYA — elle düzenlemeyin.
-- Kaynak:  content/dossiers/tigem/
-- Üretim:  node content/dossiers/seed_dossier.mjs tigem
-- Tarih:   2026-11-11T23:45:42.937Z
--
-- Bölüm: 15 · TR ~4.620 kelime · EN ~6.150 kelime
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
  'tigem',
  'TİGEM — Tarım İşletmeleri Genel Müdürlüğü',
  'TİGEM — General Directorate of Agricultural Enterprises',
  null,
  'kurum',
  $dsr$95 sayılı Kanun Hükmünde Kararname · RG 28/10/1983 · 18205 Mükerrer — ve Ana Statü · RG 2/2/2022 · 31738$dsr$,
  6,
  $dsr$Türkiye tarım arazisinin yüzde birinden azıyla, ülkede dağıtılan sertifikalı hububat tohumunun beşte birini veriyor: ürettiği gıda değil, girdi.$dsr$,
  $dsr$With less than one per cent of Türkiye's farmland it supplies a fifth of the certified cereal seed distributed in the country: what it makes is not food but input.$dsr$,
  $dsr${"_dosya":"TİGEM — Kurum Dosyası Sayı 06 · tasarım künyesi","_amac":"Evrak görsel dilinin bu dosyadaki uygulaması. DossierTheme bu dosyadan üretilir.","_kural":"Buradaki hiçbir kontrast sayısı elle yazılmadı. Hepsi _raw/kontrast.py ile ÖLÇÜLDÜ ve bu dosya o betikten üretildi; dogrula_tasarim.py her sayıyı yeniden ölçüp karşılaştırıyor. DSİ dosyasında dört şerit kontrastı tahmin edilmiş ve yanlış çıkmıştı (§8.14.3'ün 'sessiz mayın'ı); bu yol o hatayı imkânsız kılıyor.","_kontrast_betigi":"content/dossiers/tigem/_raw/kontrast.py","tez_cumlesi":{"tr":"Türkiye tarım arazisinin yüzde birinden azıyla, ülkede dağıtılan sertifikalı hububat tohumunun beşte birini veriyor: ürettiği gıda değil, girdi.","en":"With less than one per cent of Türkiye's farmland it supplies a fifth of the certified cereal seed distributed in the country: what it makes is not food but input.","_ad":"Şemada `thesis_tr` ama bir TEZ değil, tanıtım cümlesi (§8.2).","gerekce":"Cümle iddia kurmuyor, ÖLÇÜ veriyor ve iki ucu da doğrulanmış: arazi payı %0,93 (TİGEM 3.602.454,68 da / Dünya Bankası 386.400 km²), tohum payı %19,9 (122.045 / 613.206 ton, 2022). İkisi de build_data.py'nin dokuzuncu doğrulamasından geçiyor — aralığın dışına çıkarsa üretim durur ve cümle yazılamaz.","_payda_uyarisi":"Tohum payının paydası DAĞITIM'dır, ihtiyaç değil. Aynı miktarın 790 bin tonluk ihtiyaca oranı %15,4 olur; cümle paydayı kendi içinde söylüyor.","_ne_demiyor":"'Türkiye'nin tohumunu TİGEM üretir' DEMİYOR. Pay beşte bir ve düşüyor; 2002'de %90'dı. Dosya bunu bölüm 9'da ayrıca anlatıyor."},"kume":{"ad":"Üretim","sira":9,"kagit_vurgu":"#1F5626","kapak_vurgu":"#4CC756","gerekce":"Dizinin DOKUZUNCU kümesi ve ilk kez burada kuruluyor. Mevcut sekizin hiçbiri tutmuyor: Kamu gücü piyasaya fiyatla müdahale eden KİT (TMO), Finans kredi açan (Ziraat), Üretici örgütü ortaklık (Tarım Kredi), Piyasa altyapısı borsa ve depoculuk, Bilgi araştırma (TAGEM), Su-toprak altyapı (DSİ), Meslek oda, Hayalet kapanmış kurum. TİGEM bunların hiçbiri değil: devletin BİZZAT ÜRETİCİ olması.","_tek_seferlik_degil":"Küme bu dosyaya özel değil. Rotasyonun 7. sırasındaki Türkşeker ve 8. sırasındaki Et ve Süt Kurumu da aynı kümeye girer — üçü de devletin kendi tesisinde üretim yapan KİT'i. Kapanmışları (SEK, Zirai Donatım) Hayalet kümesinde kalır.","_renk_gerekcesi":"Kümenin maddesi tarla. Ton 125° — kullanılmayan tek geniş aralık; Finans (160°, mavi-yeşil) ve Meslek (52°, sarı-zeytin) iki yanında duruyor."},"palet":{"ad":"Evrak — kağıt gövde","kaynak_fikir":"Kurumun manzarası yok; maddi karşılığı kağıttır. Kanun, tutanak, cetvel, yönerge. Bu dosyada kağıt fazladan bir şey daha yapıyor: dosyanın omurgası üç belgedeki AYNI CÜMLE (1949, 1983, 2022) ve o cümle ancak kağıtta yan yana konur.","mod":"KOYU KAPAK → KAĞIT GÖVDE. Dosya sayfası sistem açık/koyu tercihini izlemez.","mod_gerekcesi":"Fiziksel dosyanın kendisi: dışı mukavva kapak, içi kağıt.","sayfa":{"zemin":{"hex":"#E3E7E5","rol":"Sayfa zemini — arşiv kağıdı","kontrast_app_krem":1.109},"yuzey":{"hex":"#F0F2F0","rol":"Kart, tablo, kayıt bloğu","kontrast_zemin":1.11},"murekkep":{"hex":"#15191A","rol":"Gövde metni","kontrast_zemin":14.19,"kontrast_yuzey":15.74},"sessiz":{"hex":"#575F61","rol":"Meta, kaynak satırı, altyazı","kontrast_zemin":5.23,"kontrast_yuzey":5.81},"vurgu":{"hex":"#1F5626","rol":"Üretim — rakamlar, başlık vurguları, tohum serisi","kontrast_zemin":6.96,"kontrast_yuzey":7.72},"ikincil":{"hex":"#575F61","rol":"Karşılaştırmanın ikinci ölçüsü — ülke toplamı, kiraya verilen pay","kontrast_zemin":5.23,"kontrast_yuzey":5.81,"_not":"Kasıtlı olarak NÖTR. DSİ'de ikincil için başka bir kümenin rengi ödünç alınmıştı çünkü karşılaştırılan taraf gerçek bir kurum türüydü. Burada öyle değil: ikinci seri bir kez 'Türkiye toplamı', bir kez 'kiraya verilmiş pay'. İkisi de kurum değil; renk vermek onlara olmayan bir kimlik verirdi."},"cizgi":{"hex":"#C0C6C3","rol":"SADECE dekoratif ayırıcı — marj rayı","kontrast_zemin":1.39,"_uyari":"3:1'in altında. Anlam taşıyan hiçbir yerde kullanılamaz; eksen ve odak halkası için cizgiVurgu kullanılır."},"cizgiVurgu":{"hex":"#767E7C","rol":"Grafik ekseni, ızgara, odak halkası","kontrast_zemin":3.34,"kontrast_yuzey":3.7}},"kapak":{"zemin":{"hex":"#131718","rol":"Kapak zemini — mukavva"},"murekkep":{"hex":"#F0F2F0","rol":"Kapak başlığı","kontrast_zemin":16.04},"sessiz":{"hex":"#98A1A2","rol":"Seri etiketi, belge satırı","kontrast_zemin":6.84},"vurgu":{"hex":"#4CC756","rol":"Üretim, kapak karşılığı","kontrast_zemin":8.26},"yuzey":{"hex":"#1D2325","rol":"Kapak üstü blok","kontrast_zemin":1.13}},"serit":{"_amac":"Ana sayfadaki dosya şeridi sayfanın içinde yaşıyor; krem zemin.","murekkep":{"hex":"#15191A","kontrast_krem":15.73},"vurguKoyu":{"hex":"#1F5626","rol":"Üretim'in krem zemindeki karşılığı","kontrast_krem":7.72},"ikincilKoyu":{"hex":"#575F61","kontrast_krem":5.8},"_ayrisma":{"uygulamanin_yapisal_yesili":"#2F4B2E","oran":1.12,"_not":"ŞERİDİN TEK GERÇEK RİSKİ BU DOSYADA. Kümenin rengi yeşil ve uygulamanın yapısal yeşili de #2F4B2E; ikisi arasındaki oran 1,12. Hollanda'da çöken desen 1,05, Avustralya'nın ilk hâli 1,03 idi — bu onların üstünde ama dizinin en dar aralığı. Kart kendi zemininden PARLAKLIKLA değil, krem zemin üzerindeki 7,72'lik kontrastla ve şerit çerçevesiyle ayrışıyor. Önizlemede gözle doğrulanacak (tur 9)."}}},"renk_korlugu":{"_olcum":"_raw/kontrast.py · Viénot-Mollon benzetimi + CIE76 ΔE","kagit_vurgusu_en_yakin":{"normal_dE":19.35,"deuteranopi_dE":3.62,"protanopi_dE":10.5},"mevcut_sekizin_tabani":{"en_kucuk_normal_dE":17.43,"en_kucuk_deuteranopi_dE":1.95},"KARAR":"RENK TEK BAŞINA HİÇBİR YERDE ANLAM TAŞIMAZ. Ölçüm bunu zorunlu kıldı: dokuzuncu kümenin kağıt vurgusu deuteranopi altında Kamu gücü'ne ΔE 3,6 mesafede. Mevcut sekizin kendi tabanı zaten 2,0 — yani dizi kurulduğundan beri renk körü okur için kümeler ayrışmıyor. Dokuzuncu küme bunu kötüleştirmiyor ama düzeltmiyor da.","_denenen_ve_elenen":"Deuteranopi ayrımını 10'un üstüne çıkaran kapak vurguları arandı ve bulundu (ör. #47CC8A, ΔE deut 9,9) — ama hepsi normal görüşteki ayrımı 45,2'den 23,7'ye ve altına düşürüyor, yani Finans'ın nanesine yaklaşıyor. Okurların büyük çoğunluğu normal görüşlü; takas kabul edilmedi.","_gereken_degisiklik":"Arşiv ve şerit kümenin adını YAZIYLA da göstermeli. Bugün göstermiyor: diger_dosyalar.dart yalnız editionLabel basıyor. Bu, beş yayındaki dosyayı etkileyen ORTAK bileşen değişikliğidir; kullanıcı kararı bekliyor."},"motif":{"ad":"Cetvel çizgisi","tanim":"Defter ve resmî evrak kağıdının marj rayı: solda dikey ray, aralarda ince yatay kural çizgileri.","gerekce":"Kuruma göre DEĞİŞMEZ, dizi kimliğidir (§8.4). Değişen renktir.","uygulama":{"opaklik":"%8","renk":"cizgiVurgu #767E7C üzerine opaklık","bicim":"Vektör (CustomPainter) — telif yok, ölçeklenir","yerlesim":"Bölüm ayırıcılarında ve kapak altı geçiş bandında. Gövde metninin ARKASINDA kullanılmaz.","aralik_notu":"Izgara aralığı 24 px'in altına inmeyecek (moiré)."}},"kapak":{"yon":"Kuruluş belgesinden kurulan tipografik kapak","gerekce":"Fotoğraf kapak yine reddedildi (§8.8, DSİ'deki kararın aynısı): dizinin görsel kimliği altıncı sayıda kırılırsa hiç kurulmamış olur. Güçlü fotoğraflar metnin içine yayılıyor, kapağa değil.","sinir":"Kapak bir belgeyi ALINTILAR, TAKLİT ETMEZ. Resmî Gazete anteti, mühür, arma veya kurum logosu yeniden üretilmez. Kapakta her zaman seri etiketi ve sayı numarası bulunur.","tipografi_katmani":{"ust_satir":"KURUM DOSYASI · 06 · ÜRETİM","baslik":"TARIM İŞLETMELERİ","belge_satiri":"95 sayılı Kanun Hükmünde Kararname · Resmî Gazete 28 Ekim 1983 · 18205 Mükerrer — Ana Statü · 2 Şubat 2022 · 31738","alt_satir":"tez_cumlesi.tr","_belge_satiri_gerekcesi":"Kuruluş belgesi kapakta DÜZELTME yapıyor: kurumun kendi sayfası 1984 diyor, kapak 28 Ekim 1983 tarihli KHK/95'i gösteriyor. İki künye de birincil kaynaktan okundu."}},"_yasak":["Kurum logosu, arma, mühür, Resmî Gazete anteti — yeniden üretilmez.","Kapakta fotoğraf (§8.8).","Stok 'mutlu çiftçi' fotoğrafı ve dekoratif ikon seti.","Gün batımında altın başak tarlası: tarımın en yıpranmış stok karesi ve dosyanın anlattığı şey manzara değil, GİRDİ.","Toprakta filizlenen yeşil fide makrosu: 'büyüme' klişesi; kurumun ürettiği şey fide değil tohumluk, damızlık ve sperma.","Grafikte rengi tek ayırt edici işaret yapmak — ölçüldü, renk körü okur için çalışmıyor (renk_korlugu bloğu)."]}$dsr$::jsonb,
  $dsr${"_dosya":"TİGEM — Kurum Dosyası Sayı 06 · veri sayfası","_uretim":"build_data.py — elle düzenlenmez","_eksen":"Kurum Türkiye tarım arazisinin yüzde birinden azını tutuyor ama ülkede dağıtılan sertifikalı hububat tohumunun beşte birini veriyor; çünkü ürettiği şey gıda değil girdi.","_eksen_notu":"Pay 2002'de %90 idi. Kurum küçülmedi — ülke büyüdü. 2002-2022 arasında Türkiye'nin dağıtımı 7.28 kat, TİGEM'inki 1.61 kat arttı.","_eksenin_siniri":"Tohum payının paydası DAĞITIM'dır, ihtiyaç değil. İhtiyaç paydası kullanılırsa oran düşer. İki payda aynı cümlede karıştırılmaz.","kurulus_silsilesi":{"_kapsam":"Kurumun soyunu kuran ve bugünkü hâlini belirleyen belgeler; hepsi birincil metinden okundu","_kaynak_niteligi":"BİRİNCİL — TBMM Kanunlar Dergisi ve Resmî Gazete arşivi","halkalar":[{"yil":1937,"belge":"3130 sayılı Kanun","tur":"kanun","rg":"19/11/1937 · 3538","kabul":"12.II.1937","ne":"Ziraat Vekâleti bütçesinde 858'inci fasıl açıldı: 'Ziraî kombinalar kurumu masrafları' 3.000.000 lira","kaynak":"tbmm_kanun_3130_zirai_kombinalar_1937.pdf"},{"yil":1938,"belge":"3308 sayılı Kanun","tur":"kanun","rg":"13/1/1938 · 3807","kabul":"7.I.1938","ne":"Devlet Ziraat İşletmeleri Kurumu kuruldu; Atatürk'ün 11.VI.1937 tarihli mektupla Hazineye bağışladığı mallar kuruma geçti","kaynak":"tbmm_kanun_3308_dzik_1938.pdf"},{"yil":1948,"belge":"5254 sayılı Kanun","tur":"kanun","rg":"14/7/1948 · 6957","kabul":"8.VII.1948","ne":"Muhtaç çiftçiye Ziraat Bankası eliyle ödünç ve faizsiz tohumluk; 2001'de 4684 sayılı Kanunla mülga","kaynak":"tbmm_kanun_5254_odunc_tohumluk_1948.pdf"},{"yil":1949,"belge":"5433 sayılı Kanun","tur":"kanun","rg":"13/6/1949 · 7231","kabul":"7.VI.1949","ne":"Devlet Üretme Çiftlikleri Genel Müdürlüğü kuruldu; katma bütçeli, Tarım Bakanlığına bağlı","kaynak":"tbmm_kanun_5433_duc_1949.pdf"},{"yil":1950,"belge":"5659 sayılı Kanun","tur":"kanun","rg":"1/4/1950 · 7472","kabul":"24.III.1950","ne":"Atatürk Orman Çiftliği ayrı bir müdürlük oldu; sermayesi 7.500.000 lira","kaynak":"tbmm_kanun_5659_aoc_1950.pdf"},{"yil":1983,"belge":"95 sayılı KHK","tur":"khk","rg":"28/10/1983 · 18205 Mükerrer","kabul":"BKK 10/10/1983","ne":"TİGEM adıyla Kamu İktisadi Kuruluşu kuruldu; merkez Ankara, sermaye 30 milyar TL","kaynak":"rg_18205_khk95_tigem_kurulus.pdf"},{"yil":1984,"belge":"233 sayılı KHK","tur":"khk","rg":"18/6/1984 · 18435 Mükerrer","kabul":"8.6.1984","ne":"KİT çerçevesi 60 sayılı KHK'den 233'e geçti; TİGEM ekli cetvelde Kamu İktisadi Kuruluşu olarak yer aldı","kaynak":"rg_18435_khk233_tigem.pdf"},{"yil":1990,"belge":"3646 sayılı Kanun","tur":"kanun","rg":"25/5/1990 · 20528","kabul":"16 Mayıs 1990","ne":"Mülga 5433 ile Devlet Üretme Çiftlikleri'ne geçen taşınmazlar ve hara-inekhane arazileri TİGEM adına tapuya tescil edildi","kaynak":"kanun_3646_tescil.docx"},{"yil":1994,"belge":"4046 sayılı Kanun md. 35","tur":"kanun","rg":"24/11/1994","kabul":"24/11/1994","ne":"233 sayılı KHK'nin ekli cetvelleri yeniden tespit edildi; TİGEM İktisadi Devlet Teşekkülü bölümüne geçti","kaynak":"khk_233_kit.pdf — dipnot 47"},{"yil":2022,"belge":"Ana Statü · Cumhurbaşkanı Kararı 5141","tur":"karar","rg":"2/2/2022 · 31738","kabul":"1 Şubat 2022","ne":"Bugünkü kurucu metin; dayanağı 233 ve 399 sayılı KHK'ler","kaynak":"rg_2022_ana_statu_5141.pdf"}]},"gorev_cumlesi":{"_kapsam":"Kurumun görev tanımının üç ayrı belgedeki hâli; dosyanın omurgası","_kaynak_niteligi":"BİRİNCİL — üç belgeden de kendi metninden alıntılandı","halkalar":[{"yil":1949,"belge":"5433 sayılı Kanun, madde 1","alinti":"Yurt çiftçiliğinin zirai verimini artırmak, istihsalini çeşitlendirmek ve mahsulün kalitesini yükseltmek amacı ile iyi tohumluk, damızlık ve fidan ihtiyacını sağlamak, tarım alanında çiftçiye örneklik ve öğreticilik etmek üzere"},{"yil":1983,"belge":"95 sayılı KHK, madde 3/1","alinti":"Ülkenin bitkisel ve hayvansal üretimini artırmak, çeşitlendirmek ve ürün kalitesini iyileştirmek amacıyla yetiştirdiği damızlık hayvan, tohum, fidan, fide ve benzerleriyle ürettiği spermaları yetiştiricilere intikal ettirmek"},{"yil":2022,"belge":"Ana Statü, madde 5/1-a","alinti":"Ürettiği tohumluk, fidan, fide ve benzeri ürünler ile yetiştirdiği damızlık hayvanlar ve spermalarını üreticilere intikal ettirmek"}]},"arazi":{"_kapsam":"25.07.2023 · faaliyette olan 17 işletme + Genel Müdürlük yerleşkesi; kiraya verilen ve iştirak AYRI satırda","_kaynak_niteligi":"KURUMUN BEYANI — tigem.gov.tr arazi varlığı PDF'i; satır toplamları betikle yeniden hesaplandı","_birim":"dekar","tarih":"2023-07-25","genel_mudurluk":1771.22,"isletmeler":[{"sira":1,"isletme":"Altınova","toplam":310259,"kulturalti":299739,"tarla":234460,"yem_bitkileri":31530,"tabii_mera":25058,"bahce":8691,"kulturdisi":10520.2,"sulanan":41282},{"sira":2,"isletme":"Anadolu","toplam":44824,"kulturalti":42265,"tarla":18880,"yem_bitkileri":13441,"tabii_mera":9061,"bahce":883,"kulturdisi":2559,"sulanan":17636},{"sira":3,"isletme":"Boztepe","toplam":3208.4,"kulturalti":2951,"tarla":237,"yem_bitkileri":0,"tabii_mera":0,"bahce":2714,"kulturdisi":257.4,"sulanan":2882},{"sira":4,"isletme":"Ceylanpınar","toplam":1633157.3,"kulturalti":1435911.7,"tarla":902823,"yem_bitkileri":63613,"tabii_mera":403815,"bahce":65660,"kulturdisi":197245.6,"sulanan":696475},{"sira":5,"isletme":"Çukurova","toplam":42830,"kulturalti":40663,"tarla":36126,"yem_bitkileri":3902,"tabii_mera":0,"bahce":635,"kulturdisi":2167,"sulanan":15254},{"sira":6,"isletme":"Dalaman","toplam":33630,"kulturalti":26870,"tarla":13322,"yem_bitkileri":4312,"tabii_mera":704,"bahce":8532,"kulturdisi":6760,"sulanan":24369},{"sira":7,"isletme":"Gökhöyük","toplam":24881.9,"kulturalti":20451,"tarla":11010,"yem_bitkileri":9112,"tabii_mera":88,"bahce":241,"kulturdisi":4430.9,"sulanan":18169},{"sira":8,"isletme":"Gözlü","toplam":288297.89,"kulturalti":261705.49,"tarla":123439,"yem_bitkileri":26503,"tabii_mera":99095.49,"bahce":12668,"kulturdisi":26592.4,"sulanan":34999},{"sira":9,"isletme":"Karacabey","toplam":89001.7,"kulturalti":75241,"tarla":30827,"yem_bitkileri":18681,"tabii_mera":12380,"bahce":13353,"kulturdisi":13760.7,"sulanan":26994},{"sira":10,"isletme":"Kazım Karabekirekir","toplam":186993.9,"kulturalti":68700.4,"tarla":11500,"yem_bitkileri":783,"tabii_mera":55907.4,"bahce":510,"kulturdisi":118293.5,"sulanan":5939},{"sira":11,"isletme":"Koçaş","toplam":25075.94,"kulturalti":23196,"tarla":6733,"yem_bitkileri":15929,"tabii_mera":0,"bahce":534,"kulturdisi":1879.7,"sulanan":20151},{"sira":12,"isletme":"Konuklar","toplam":44570,"kulturalti":35397,"tarla":29867,"yem_bitkileri":3160,"tabii_mera":1240,"bahce":1130,"kulturdisi":9173,"sulanan":6835},{"sira":13,"isletme":"Malya","toplam":218828.7,"kulturalti":157662,"tarla":120428,"yem_bitkileri":34135,"tabii_mera":0,"bahce":3099,"kulturdisi":61167,"sulanan":2878},{"sira":14,"isletme":"Polatlı","toplam":211335.27,"kulturalti":208734,"tarla":169729,"yem_bitkileri":21432,"tabii_mera":14227,"bahce":3346,"kulturdisi":2601,"sulanan":6491},{"sira":15,"isletme":"Sultansuyu","toplam":27191,"kulturalti":22542,"tarla":12100,"yem_bitkileri":8188,"tabii_mera":500,"bahce":1754,"kulturdisi":4649,"sulanan":12017},{"sira":16,"isletme":"Türkgeldi","toplam":18244,"kulturalti":16434,"tarla":5649,"yem_bitkileri":8760,"tabii_mera":1800,"bahce":225,"kulturdisi":1810,"sulanan":4921},{"sira":17,"isletme":"Ulaş","toplam":71463.46,"kulturalti":49941.96,"tarla":29450,"yem_bitkileri":15039,"tabii_mera":5262,"bahce":190,"kulturdisi":21521.5,"sulanan":3276}],"pdf_toplam_satiri":3275563.68,"uzun_sureli_kiraya_verilen":238203,"istirak_seklinde":88688,"tigem_toplam_arazi":3602454.68,"pdf_yazdigi_kullanim_orani":90.93,"pdf_yazdigi_kira_orani":9.07,"sulu_tarim_arazi_varligi_2023":994798,"_sulu_tarim_notu":"2024-2028 Stratejik Plan Tablo 13, 2023 yılı. Arazi varlığı tablosundaki 940.568 dekarlık 'sulanan arazi' ile AYNI ŞEY DEĞİL: biri sulanan, öteki sulu tarım arazisi varlığı. İkisi birbirinin yerine kullanılamaz.","sulama_hedefi_2019_2023":{"baslangic_da":942500,"hedef_da":1090500,"gerceklesme_yuzde":92,"_kaynak":"2024-2028 Stratejik Plan, Tablo 2, Hedef 2.1"},"sulamaya_acilan_da":995000,"_sulamaya_acilan_notu":"Mart 2024 kurum sunumu: 'Yapılan yatırımlar ile 995 Bin dekar arazi sulamaya açılmış.'","_17_isletme_kulturalti":2788404.55,"_17_isletme_tarla":1756580,"_17_isletme_tabii_mera":629137.89,"_17_isletme_sulanan":940568,"_17_isletme_bahce":124165},"isletmeler":{"_kapsam":"tigem.gov.tr/Isletme/Index/1,2,3 — adlar tek tek sayıldı (tur 2)","_kaynak_niteligi":"KURUMUN BEYANI","faaliyette":17,"kiraya_verilmis":17,"istirak":2},"olcek":{"_kapsam":"TİGEM'in toplam arazisi (3.602.454,68 da) / Türkiye'nin tarım arazisi","_kaynak_niteligi":"BAĞIMSIZ — Dünya Bankası, Türkiye tarım arazisi 2024","turkiye_tarim_arazisi_km2":386400,"_turkiye_kaynak":"World Bank, Agricultural land (sq. km) — Türkiye, 2024","tigem_sulama_orani_yuzde":33.7,"turkiye_sulama_orani_yuzde":12.7,"_sulama_payda_uyarisi":"İKİ ORANIN PAYDASI FARKLI. TİGEM oranı KÜLTÜRALTI arazisine, Türkiye oranı BÜTÜN tarım arazisine göre. Fark bire bir bir üstünlük ölçüsü değildir ve metin bunu yazmadan oranları yan yana koyamaz."},"tohum_dagitim":{"_kapsam":"SERTİFİKALI HUBUBAT TOHUMU DAĞITIMI (ton). Ülke rakamının kaynağı TOB; TİGEM satırı kurumun kendi ekilişlerini de içeriyor (raporun dipnotu)","_kaynak_niteligi":"KARMA — ülke satırı BAĞIMSIZ (TOB), TİGEM satırı KURUMUN BEYANI","_uyari":"Bu seri DAĞITIM'dır; stratejik plandaki SATIŞ serisiyle aynı grafikte gösterilemez","_kaynak":"Tohumculuk Sektör Raporu 2022, Tablo 9 ve Tablo 10","_olcu":"dagitim","yillar":[2002,2010,2015,2020,2021,2022],"turkiye_bugday":[80089,262764,483819,485366,490027,443978],"turkiye_arpa":[4127,31822,124932,221526,139292,169228],"turkiye_toplam_rapor":[84216,294586,608751,706892,629319,613206],"tigem_bugday":[72059,156925,128383,136055,106631,104319],"tigem_arpa":[3753,16795,14484,19893,11168,17726],"rapor_pay_bugday":[90,60,27,28,22,23.5],"rapor_pay_arpa":[91,53,12,9,8,10.5],"ihtiyaci_karsilama_yuzde":[3.8,39.7,28.6,35.3,27.6,27.1]},"tohum_satis":{"_kapsam":"SATIŞ miktarı (ton) — kurumun kendi ekilişi hariç. Dağıtım serisiyle karıştırılmaz","_kaynak_niteligi":"KURUMUN BEYANI — 2024-2028 Stratejik Plan Tablo 6 (2018-2022) ve Mart 2024 sunumu (2023)","_olcu":"satis","yillar":[2018,2019,2020,2021,2022],"bugday_tohumu":[97423,97331,109569,84234,79561],"arpa_tohumu":[18200,15176,17706,8777,13586],"tritikale_tohumu":[3642,3490,4261,1701,2244],"hububat_2023_bin_ton":113,"_2023_notu":"Mart 2024 sunumu: '2023 yılında ülkemiz çiftçilerine 113 bin ton sertifikalı hububat tohumu satışı gerçekleşmiştir'"},"damizlik":{"_kapsam":"Damızlık hayvan varlığı ve sperma satışı","_kaynak_niteligi":"KURUMUN BEYANI — Mart 2024 sunumu; sperma serisi Stratejik Plan Tablo 6 ile çapraz okundu","sigir_varlik_2002":17000,"sigir_varlik_2023":27000,"sigir_isletme":14,"sigir_irk":6,"koyun_varlik_2002":71000,"koyun_varlik_2023":284000,"koyun_isletme":10,"koyun_irk":10,"koyun_irk_yerli":5,"koyun_irk_melez":5,"sperma_yillar":[2018,2020,2021,2022,2023],"sperma_doz":[460000,658000,874000,945000,1019000],"_sperma_notu":"Sultansuyu/Malatya Boğa Sperması Üretim Merkezi 2012'de açıldı","arap_ati_varlik":1549,"arap_ati_isletme":3,"arap_ati_isletmeler":["Karacabey/Bursa","Sultansuyu/Malatya","Anadolu/Eskişehir"],"yaris_tayi_yillik_ortalama":260,"halep_kecisi_ana_bas":1000,"halep_kecisi_yil":2013,"kovan":5000},"dagitim_kanallari":{"_kapsam":"Tohumluk Satış ve Dağıtım Yönergesi (YKK 10/03/2017-80, değişik 22.12.2022-401)","_kaynak_niteligi":"BİRİNCİL — kurumun yürürlükteki yönergesi","kanallar":["İşletmeler (doğrudan peşin satış)","TİGEM Bayileri","İl Müdürlükleri","Dağıtıcı kuruluşlar: Tarım Kredi Kooperatifleri ve Pankobirlik"],"bayi_sayisi":303,"_bayi_notu":"2003-2023 döneminde kurulmuş (Mart 2024 sunumu)","fiyat_belirleme_ayi":"Haziran-Ağustos","bayi_adimlari":[{"sira":1,"ad":"Ön talep","aktor":"Bayi","sure":null,"belge":"Bayi Otomasyon Sistemi"},{"sira":2,"ad":"Ön tahsis","aktor":"TİGEM","sure":null,"belge":"Bayi Otomasyon Sistemi bildirimi"},{"sira":3,"ad":"Kesin tahsis","aktor":"Bayi","sure":"5 iş günü","belge":"bedelin %10'u peşin"},{"sira":4,"ad":"Teslim alma","aktor":"Bayi","sure":"20 takvim günü","belge":"işletmeden teslim"},{"sira":5,"ad":"Ödeme","aktor":"Bayi","sure":null,"belge":"nakit veya teminat mektubu"},{"sira":6,"ad":"Sevkiyat","aktor":"Bayi","sure":null,"belge":"randevu"}],"ciftci_dogrudan":"Yönetim Kurulunun belirlediği peşin satış fiyatı üzerinden, Genel Müdürlüğe veya İşletmelere yazılı müracaat"},"kiralama":{"_kapsam":"Bazı İşletmelerin Uzun Süreli Kiraya Verilmesine İlişkin Yönerge; arazi payı arazi varlığı PDF'inden","_kaynak_niteligi":"BİRİNCİL — yönerge metni","karar_zinciri":[{"sira":1,"aktor":"Strateji Geliştirme Dairesi Başkanlığı","is":"teknik, malî ve ekonomik analiz; rapor"},{"sira":2,"aktor":"Yönetim Kurulu","is":"raporu inceler ve karar verir"},{"sira":3,"aktor":"İnşaat ve Emlak Dairesi Başkanlığı","is":"şartname ve sözleşmelerle Cumhurbaşkanlığına sunar"},{"sira":4,"aktor":"Cumhurbaşkanlığı","is":"süre ve şartları belirleyen karar"},{"sira":5,"aktor":"Kira Tespit Komisyonu","is":"en az üç kişi, işletmenin bulunduğu yerde, 30 gün, oybirliği"},{"sira":6,"aktor":"İhale Komisyonu","is":"ihale; Yönetim Kurulu onayıyla tamamlanır"}],"komisyon_asgari_uye":3,"komisyon_sure_gun":30,"ozel_sektore_tohum_uretim_alani_da":{"2020":96000,"2021":102000,"2022":133000,"2023":111000}},"koruma":{"_kapsam":"Kurumun tohum ve damızlık dışında koruduğunu bildirdiği varlıklar","_kaynak_niteligi":"KURUMUN BEYANI — Stratejik Plan, Mirasımız Yerel Tohum, Yerel Çeşit Listesi","ata_tohumu_cesit":1027,"_ata_notu":"2019-2023 Stratejik Planı hedefi: 1027 çeşitte Ata tohumunun çoğaltılması ve tanımlanması; gerçekleşme %92","varliklar":["yerel (Ata) tohumları","Safkan Arap Atı","Ankara Tiftik Keçisi","Kangal Köpeği","Asya Ceylanı"],"cesit_ornegi":{"ad":"Şahnalı Acı Biber","kod":"TGM18335"}},"kunye":{"_kapsam":"Kurumun bugünkü hukuki ve malî künyesi","_kaynak_niteligi":"KARMA — Ana Statü BİRİNCİL; bilanço satırı BAĞIMSIZ (Sayıştay)","hukuki_bunye":"İktisadi Devlet Teşekkülü","merkez":"Ankara","ilgili_bakanlik":"Tarım ve Orman Bakanlığı","denetim":"Türkiye Büyük Millet Meclisi ve Sayıştay","sermaye_serisi":[{"yil":2022,"tutar_tl":3316000000,"belge":"Ana Statü md. 4/4"},{"yil":2023,"tutar_tl":4356000000,"belge":"Cumhurbaşkanı Kararı 6650 · 6/1/2023"},{"yil":2024,"tutar_tl":9356000000,"belge":"Sayıştay Kamu İşletmeleri 2024 Genel Raporu — esas sermaye"}],"_sermaye_1983":"95 sayılı KHK md. 2: 30 milyar TL. ESKİ PARA — 2005 öncesi; bugünkü seriyle aynı eksende gösterilemez","sayistay_2024":{"donen_varlik_bin_tl":8001760,"duran_varlik_bin_tl":17137081,"ozkaynak_bin_tl":22856983,"kisa_vadeli_yabanci_bin_tl":2281859,"uzun_vadeli_yabanci_bin_tl":0,"odenmis_sermaye_bin_tl":7855747},"tohum_hazirlama_kapasite_ton_saat":341},"dunya":{"_kapsam":"Aynı sorunun — çiftçiye sertifikalı tohum ulaştırmanın — başka ülkelerde nasıl çözüldüğü","_kaynak_niteligi":"KARMA — OECD listesi BAĞIMSIZ ve birincil; Hindistan birleşmesi İKİNCİL (basın)","iki_model":[{"ad":"Devlet kendi çiftliğinde üretir","ornekler":["Türkiye — TİGEM","Hindistan — State Farms Corporation of India"]},{"ad":"Devlet üretmez, belgeler","ornekler":["OECD Tohum Şemaları — altmıştan fazla ülke"]}],"hindistan":{"nsc_kurulus":1963,"nsc_uretim_ton_yil":150000,"sfci":"State Farms Corporation of India — devletin büyük, makineli çiftliklerini sertifikalı tohum üretimi için işleten kuruluş","sfci_ciftlik":5,"sfci_alan_ha":21908,"_sfci_alan_notu":"2012 tarihli Hindistan hükûmeti duyurusundan aktarılan rakam; Rajasthan, Haryana ve Karnataka'da beş Merkezî Devlet Çiftliği. Sonraki bir Lok Sabha cevabı altı çiftlik diyor — sayı yıla göre değişiyor.","birlesme_yil":2013,"birlesme":"Bakanlar Kurulu, SFCI'nin NSC bünyesine katılmasını Aralık 2013'te onayladı","gerekce":"SFCI'nin arazisi ile NSC'nin dağıtım ağının birleştirilmesi","_kaynak":"Business Standard / ANI, Aralık 2013; Hindistan hükûmeti basın duyurusundan aktaran haberler"},"oecd_semalari":{"_kaynak":"OECD, 'List of countries participating in the OECD Seed Schemes' (PDF, oecd.org)","_kaynak_niteligi":"BAĞIMSIZ","turkiye_katiliyor":true,"listede_ayiklanan_ulke":64,"_sayi_uyarisi":"Listeden ayıklanan ülke sayısı 64; OECD'nin kendi sayfası 62, broşürü 64 diyor. Metinde kesin sayı yerine 'altmıştan fazla' yazılacak.","ayni_listede":["Hindistan","Mısır","Fas","Amerika Birleşik Devletleri","Rusya Federasyonu","İran"]}},"butce_1937":{"_kapsam":"3130 sayılı Kanun, CETVEL No. [2] — 1936 malî yılı bütçesinde YENİDEN AÇILAN fasıllara konulan fevkalade tahsisat. Munzam tahsisat (Cetvel 1) ve münakale (Cetvel 3) AYRI, bu listeye dahil değil","_kaynak_niteligi":"BİRİNCİL — TBMM Kanunlar Dergisi, basılı s. 247; tablo görüntüden okundu","_birim":"lira","_kaynak":"3130 sayılı Kanun · RG 19/11/1937 · 3538","yekun_basili":4512636,"fasillar":[{"fasil":80,"daire":"Başvekâlet","kalem":"Siyasî müsteşarlar tahsisatı","lira":10000},{"fasil":210,"daire":"Maliye Vekâleti","kalem":"Askerî Fabrikalar Umum Müdürlüğüne mütedavil sermaye karşılığı","lira":100000},{"fasil":235,"daire":"Düyunu Umumiye","kalem":"İstanbul Üniversitesi istikraz karşılığı","lira":229636},{"fasil":586,"daire":"Adliye Vekâleti","kalem":"Para cezalarını tahsile gideceklerin harcırahı","lira":3000},{"fasil":658,"daire":"Maarif Vekâleti","kalem":"Okullar için fizik, kimya ve tabiî ilimler ders ve tecrübe aletleri","lira":300000},{"fasil":706,"daire":"Nafia Vekâleti","kalem":"Dahiliye vekâleti","lira":20000},{"fasil":784,"daire":"İktisad Vekâleti","kalem":"Maden Tetkik ve Arama Enstitüsüne yardım","lira":500000},{"fasil":858,"daire":"Ziraat Vekâleti","kalem":"Ziraî kombinalar kurumu masrafları","lira":3000000},{"fasil":1023,"daire":"Askerî Fabrikalar Umum Md.","kalem":"Tank imalâtı için yapılacak tesisat bedel ve masrafları","lira":350000}],"kombinalar_fasli":858,"kredi_hesabi":"Ziraat Bankasında açtırılacak hususî bir kredi hesabı (madde 4)","madde4_alinti":"Bu krediden yapılacak masraflar hususî bir kanun ile tayin olunur. Ancak bu kanunun tanzim ve meriyete girmesine kadar İcra Vekilleri Heyeti kararile tayin edilecek işler için sarfiyat yapılır."},"turetilmis":{"_kapsam":"Hepsi yukarıdaki bloklardan HESAPLANDI; hiçbiri elle yazılmadı","_kaynak_niteligi":"TÜRETİLMİŞ","tigem_toplam_km2":3602.455,"turkiye_tarim_arazisi_payi_yuzde":0.93,"kullanimdaki_arazi_yuzde":90.93,"kiraya_verilen_arazi_yuzde":9.07,"kiraya_verilen_isletme_payi_yuzde":50,"ceylanpinar_da":1633157.3,"ceylanpinar_payi_toplam_yuzde":45.3,"ceylanpinar_payi_17_isletme_yuzde":49.9,"tigem_toplam_dagitim":[75812,173720,142867,155948,117799,122045],"tigem_birlesik_pay_yuzde":[90,59,23.5,22.1,18.7,19.9],"turkiye_buyume_kat":7.28,"tigem_buyume_kat":1.61,"sperma_buyume_kat":2.22,"koyun_buyume_kat":4,"sigir_buyume_kat":1.6,"kombinalar_fevkalade_tahsisat_payi_yuzde":66.5,"gorev_cumlesi_yil_araligi":73,"kurulus_silsilesi_yil_araligi":85,"dagitim_kayitlari":[{"yil":2002,"turkiye":84216,"tigem":75812,"pay":90},{"yil":2010,"turkiye":294586,"tigem":173720,"pay":59},{"yil":2015,"turkiye":608751,"tigem":142867,"pay":23.5},{"yil":2020,"turkiye":706892,"tigem":155948,"pay":22.1},{"yil":2021,"turkiye":629319,"tigem":117799,"pay":18.7},{"yil":2022,"turkiye":613206,"tigem":122045,"pay":19.9}],"sperma_kayitlari":[{"yil":2018,"doz":460000},{"yil":2020,"doz":658000},{"yil":2021,"doz":874000},{"yil":2022,"doz":945000},{"yil":2023,"doz":1019000}],"isletme_siralamasi":[{"isletme":"Ceylanpınar","toplam":1633157.3},{"isletme":"Altınova","toplam":310259},{"isletme":"Gözlü","toplam":288297.89},{"isletme":"Malya","toplam":218828.7},{"isletme":"Polatlı","toplam":211335.27},{"isletme":"Kazım Karabekirekir","toplam":186993.9},{"isletme":"Karacabey","toplam":89001.7},{"isletme":"Ulaş","toplam":71463.46},{"isletme":"diğer 9 işletme","toplam":264455.24}],"arazi_kullanimi":[{"tur":"Tarla arazisi","da":1756580},{"tur":"Tabii mera","da":629137.89},{"tur":"Yem bitkileri","da":278520},{"tur":"Bahçe arazisi","da":124165},{"tur":"Kültürdışı","da":485387.9}],"arazi_kullanimi_fark_da":1.67,"_arazi_kullanimi_fark_notu":"Kaynağın alt sütunları yuvarlanmış; altı işletme satırında birer dekarın altında fark var. Toplam fark 3,27 milyon dekarda 1,67 dekar.","kira_asimetrisi":{"isletme_kullanimda_yuzde":50,"isletme_kirada_yuzde":50,"arazi_kullanimda_yuzde":90.93,"arazi_kirada_yuzde":9.07},"kiraya_verilen_toplam_da":326891,"tigem_ha":360245,"sfci_kat":16.4,"tahsisat_1937_gruplu":[{"ad":"Ziraî kombinalar kurumu masrafları","lira":3000000},{"ad":"Maden Tetkik ve Arama Enstitüsüne yardım","lira":500000},{"ad":"Tank imalâtı tesisatı","lira":350000},{"ad":"Okullara fizik ve kimya aletleri","lira":300000},{"ad":"İstanbul Üniversitesi istikraz karşılığı","lira":229636},{"ad":"öteki dört fasıl","lira":133000}],"tahsisat_1937_aralik_kat":22.6}}$dsr$::jsonb,
  $dsr${"kunye_tigem":{"tur":"kunye","baslik":{"tr":"Kurum rakamlarla","en":"The institution in figures"},"not":{"tr":"Arazi 25.07.2023 tarihli; tohum satışı 2023, sperma satışı 2023. Otuz dört işletmenin on yedisi TİGEM'in kendi işletmesinde, on yedisi kiraya verilmiş durumda.","en":"Land as of 25 July 2023; seed sales and semen sales are 2023 figures. Of thirty-four enterprises, seventeen are run by TİGEM and seventeen are leased out."},"kaynak":"TİGEM · arazi varlığı tablosu, 2024-2028 Stratejik Plan, Mart 2024 sunumu","kalemler":[{"deger":3602454.68,"ondalik":0,"etiket":{"tr":"dekar arazi","en":"decares of land"},"alt":{"tr":"25.07.2023","en":"25 July 2023"}},{"deger":0.93,"ondalik":2,"sonek":{"tr":"%","en":"%"},"etiket":{"tr":"Türkiye tarım arazisinin","en":"of Türkiye's farmland"},"alt":{"tr":"Dünya Bankası, 2024","en":"World Bank, 2024"}},{"deger":113,"ondalik":0,"etiket":{"tr":"bin ton hububat tohumu","en":"thousand tonnes of cereal seed"},"alt":{"tr":"satış, 2023","en":"sold, 2023"}},{"deger":1019000,"ondalik":0,"etiket":{"tr":"doz boğa sperması","en":"doses of bull semen"},"alt":{"tr":"satış, 2023","en":"sold, 2023"}},{"deger":284000,"ondalik":0,"etiket":{"tr":"baş damızlık koyun","en":"head of breeding sheep"},"alt":{"tr":"2023","en":"2023"}},{"deger":303,"ondalik":0,"etiket":{"tr":"TİGEM bayisi","en":"TİGEM dealers"},"alt":{"tr":"2003-2023","en":"2003-2023"}},{"deger":341,"ondalik":0,"etiket":{"tr":"ton/saat tohum hazırlama","en":"tonnes/hour seed processing"},"alt":{"tr":"kurulu kapasite","en":"installed capacity"}},{"deger":1549,"ondalik":0,"etiket":{"tr":"baş Safkan Arap Atı","en":"head of Purebred Arabian horses"},"alt":{"tr":"üç işletmede","en":"at three enterprises"}}]},"fevkalade_tahsisat_1937":{"tur":"siralama","baslik":{"tr":"1937'de devletin yeni açtığı dokuz fasıl","en":"The nine new budget lines the state opened in 1937"},"birim":{"tr":"lira · 3130 sayılı Kanun, Cetvel 2","en":"lira · Law 3130, Schedule 2"},"ondalik":0,"not":{"tr":"Kanunun ikinci maddesi 1936 malî yılı bütçesine dokuz yeni fasıl açıp toplam 4.512.636 lira fevkalade tahsisat koydu. En büyüğü, yekûnun yüzde 66,5'i, Ziraat Vekâleti bütçesindeki 858'inci fasıldı. Dördüncü madde bu tahsisatın Ziraat Bankasında açılacak hususî bir kredi hesabına yatırılacağını, harcama esaslarının sonradan çıkarılacak hususî bir kanunla belirleneceğini yazıyor. En küçük dört fasıl son satırda toplandı; düşürülmedi, yekûn korundu.","en":"The law's second article opened nine new lines in the 1936 fiscal-year budget with 4,512,636 lira of extraordinary appropriation. The largest, 66.5 per cent of the total, was line 858 in the Ministry of Agriculture's budget. Article four states the money would be deposited in a special credit account at Ziraat Bankası and that the rules for spending it would be set by a law yet to be written. The four smallest lines are aggregated in the last row; they were not dropped and the total is preserved."},"kaynak":"3130 sayılı Kanun · RG 19/11/1937 · 3538, basılı s. 247","satirlar":[{"etiket":{"tr":"Ziraî kombinalar kurumu masrafları","en":"State Agricultural Combines expenses"},"deger":3000000,"rol":"vurgu"},{"etiket":{"tr":"Maden Tetkik ve Arama Enstitüsüne yardım","en":"Grant to the Mineral Research Institute"},"deger":500000,"rol":"ikincil"},{"etiket":{"tr":"Tank imalâtı tesisatı","en":"Tank manufacturing plant"},"deger":350000,"rol":"ikincil"},{"etiket":{"tr":"Okullara fizik ve kimya aletleri","en":"Physics and chemistry equipment for schools"},"deger":300000,"rol":"sessiz"},{"etiket":{"tr":"İstanbul Üniversitesi istikraz karşılığı","en":"Istanbul University loan"},"deger":229636,"rol":"sessiz"},{"etiket":{"tr":"öteki dört fasıl","en":"the other four lines"},"deger":133000,"rol":"sessiz"}]},"silsile":{"tur":"zaman_cizelgesi","baslik":{"tr":"Bir kurumun soyu: iki koldan bir çatıya","en":"The lineage of an institution: two branches, one roof"},"not":{"tr":"Kuruluş tarihi kurumun kendi sayfasında 1984 yazıyor. Birincil belge başka söylüyor: TİGEM 28 Ekim 1983 tarihli Resmî Gazete'de yayımlanan 95 sayılı Kanun Hükmünde Kararname ile kurulmuştur. 1984'te olan, bağlı olduğu KİT çerçevesinin değişmesidir.","en":"The institution's own page gives 1984 as its founding year. The primary document says otherwise: TİGEM was established by Decree-Law 95, published in the Official Gazette of 28 October 1983. What happened in 1984 was a change in the state-enterprise framework it was subject to."},"kaynak":"TBMM Kanunlar Dergisi ve Resmî Gazete arşivi","olaylar":[{"yil":1937,"baslik":{"tr":"858'inci fasıl açılıyor","en":"Budget line 858 is opened"},"aciklama":{"tr":"3130 sayılı Kanun, Ziraat Vekâleti bütçesine 'Ziraî kombinalar kurumu masrafları' faslını açıyor ve 3.000.000 lira koyuyor.","en":"Law 3130 opens the line 'State Agricultural Combines expenses' in the Ministry of Agriculture's budget with 3,000,000 lira."}},{"yil":1938,"baslik":{"tr":"Devlet Ziraat İşletmeleri Kurumu","en":"State Agricultural Enterprises Corporation"},"aciklama":{"tr":"3308 sayılı Kanun kurumu kuruyor; Atatürk'ün 11 Haziran 1937 tarihli mektupla Hazineye bağışladığı taşınmazlar kuruma geçiyor ve değerleri sermaye hesabına yazılıyor.","en":"Law 3308 establishes the corporation; the property Atatürk donated to the Treasury by his letter of 11 June 1937 passes to it and its value is credited to capital."}},{"yil":1949,"baslik":{"tr":"Devlet Üretme Çiftlikleri","en":"State Production Farms"},"aciklama":{"tr":"5433 sayılı Kanun iki kolu birleştiriyor. Birinci madde görevi sayıyor: iyi tohumluk, damızlık ve fidan.","en":"Law 5433 merges the two branches. Its first article states the task: good seed, breeding stock and saplings."}},{"yil":1950,"baslik":{"tr":"Atatürk Orman Çiftliği ayrılıyor","en":"Atatürk Forest Farm separates"},"aciklama":{"tr":"5659 sayılı Kanun çiftliği ayrı bir müdürlük yapıyor; sermayesi 7.500.000 lira.","en":"Law 5659 makes the farm a separate directorate with a capital of 7,500,000 lira."}},{"yil":1983,"baslik":{"tr":"TİGEM kuruluyor","en":"TİGEM is established"},"aciklama":{"tr":"95 sayılı Kanun Hükmünde Kararname, 28 Ekim 1983. Hara ve inekhaneler ile Devlet Üretme Çiftlikleri tek çatı altında; Kamu İktisadi Kuruluşu, merkez Ankara.","en":"Decree-Law 95, 28 October 1983. The studs and cattle farms and the State Production Farms come under one roof; a public economic establishment, headquartered in Ankara."}},{"yil":1984,"baslik":{"tr":"Çerçeve 233 sayılı KHK'ye geçiyor","en":"The framework moves to Decree-Law 233"},"aciklama":{"tr":"TİGEM 18 Haziran 1984 tarihli ekli cetvelde Kamu İktisadi Kuruluşu olarak yer alıyor.","en":"TİGEM appears in the schedule of 18 June 1984 as a public economic establishment."}},{"yil":1990,"baslik":{"tr":"Toprak tapuya geçiyor","en":"The land is entered in the register"},"aciklama":{"tr":"3646 sayılı Kanun, Devlet Üretme Çiftlikleri'nden gelen ve hara-inekhanelere tahsisli taşınmazları TİGEM adına tescil ettiriyor.","en":"Law 3646 registers in TİGEM's name the property inherited from the State Production Farms and allocated to the studs and cattle farms."}},{"yil":1994,"baslik":{"tr":"Statü İDT'ye dönüyor","en":"The status becomes a state economic enterprise"},"aciklama":{"tr":"4046 sayılı Kanunun 35'inci maddesi 233'ün ekli cetvellerini yeniden tespit ediyor; TİGEM İktisadi Devlet Teşekkülü bölümüne geçiyor.","en":"Article 35 of Law 4046 redraws the schedules of Decree-Law 233; TİGEM moves to the state economic enterprise section."}},{"yil":2022,"baslik":{"tr":"Bugünkü Ana Statü","en":"The current charter"},"aciklama":{"tr":"1 Şubat 2022 tarihli Cumhurbaşkanı Kararı. Beşinci maddenin ilk bendi 1983'teki cümlenin neredeyse aynısı.","en":"Presidential Decision of 1 February 2022. The first clause of its fifth article is almost identical to the 1983 sentence."}}]},"isletme_arazileri":{"tur":"siralama","baslik":{"tr":"Bir işletme, arazinin yarısı","en":"One enterprise, half the land"},"birim":{"tr":"bin dekar · faaliyetteki 17 işletme · 25.07.2023","en":"thousand decares · the 17 operating enterprises · 25 July 2023"},"bolen":1000,"ondalik":0,"not":{"tr":"Şanlıurfa'daki Ceylanpınar İşletmesi tek başına faaliyetteki arazinin yüzde 49,9'unu, TİGEM'in bütün arazisinin yüzde 45,3'ünü tutuyor. Sıralamanın sonundaki satır kalan dokuz işletmenin toplamıdır; düşürülmedi, toplandı. Kaynak tabloda işletmenin adı 'Kazım Karabekirekir' diye basılmış.","en":"The Ceylanpınar enterprise in Şanlıurfa alone holds 49.9 per cent of the land in operation and 45.3 per cent of all TİGEM land. The last row is the sum of the remaining nine enterprises; they were aggregated, not dropped. In the source table the enterprise name is printed as 'Kazım Karabekirekir'."},"kaynak":"TİGEM · işletme bazında arazi varlığı tablosu, 25.07.2023","satirlar":[{"etiket":{"tr":"Ceylanpınar · Şanlıurfa","en":"Ceylanpınar · Şanlıurfa"},"deger":1633157.3,"rol":"vurgu"},{"etiket":{"tr":"Altınova · Konya","en":"Altınova · Konya"},"deger":310259,"rol":"ikincil"},{"etiket":{"tr":"Gözlü · Konya","en":"Gözlü · Konya"},"deger":288297.89,"rol":"sessiz"},{"etiket":{"tr":"Malya · Kırşehir","en":"Malya · Kırşehir"},"deger":218828.7,"rol":"sessiz"},{"etiket":{"tr":"Polatlı · Ankara","en":"Polatlı · Ankara"},"deger":211335.27,"rol":"sessiz"},{"etiket":{"tr":"Kazım Karabekir · Karaman","en":"Kazım Karabekir · Karaman"},"deger":186993.9,"rol":"sessiz"},{"etiket":{"tr":"Karacabey · Bursa","en":"Karacabey · Bursa"},"deger":89001.7,"rol":"sessiz"},{"etiket":{"tr":"Ulaş · Sivas","en":"Ulaş · Sivas"},"deger":71463.46,"rol":"sessiz"},{"etiket":{"tr":"diğer dokuz işletme","en":"the other nine enterprises"},"deger":264455.24,"rol":"sessiz"}]},"arazi_kullanimi":{"tur":"siralama","baslik":{"tr":"Arazi ne için kullanılıyor","en":"What the land is used for"},"birim":{"tr":"bin dekar · faaliyetteki 17 işletme","en":"thousand decares · the 17 operating enterprises"},"bolen":1000,"ondalik":0,"not":{"tr":"Beş kalem faaliyetteki arazinin tamamını kapsıyor. Kaynağın alt sütunları yuvarlanmış: beş kalemin toplamı ile tablo toplamı arasında 3,27 milyon dekarda 1,67 dekar fark var.","en":"The five items cover all the land in operation. The source's sub-columns are rounded: the five items and the table total differ by 1.67 decares in 3.27 million."},"kaynak":"TİGEM · arazi varlığı tablosu, 25.07.2023","satirlar":[{"etiket":{"tr":"Tarla arazisi","en":"Field crops"},"deger":1756580,"rol":"vurgu"},{"etiket":{"tr":"Tabii mera","en":"Natural pasture"},"deger":629137.89,"rol":"ikincil"},{"etiket":{"tr":"Kültürdışı arazi","en":"Non-arable land"},"deger":485387.9,"rol":"sessiz"},{"etiket":{"tr":"Yem bitkileri","en":"Forage crops"},"deger":278520,"rol":"sessiz"},{"etiket":{"tr":"Bahçe arazisi","en":"Orchards and gardens"},"deger":124165,"rol":"sessiz"}]},"tohum_dagitimi":{"tur":"cizgi","baslik":{"tr":"Ülke yedi kat büyüdü, kurum bir buçuk","en":"The country grew sevenfold, the institution one and a half"},"birim":{"tr":"bin ton · sertifikalı buğday ve arpa tohumu DAĞITIMI","en":"thousand tonnes · certified wheat and barley seed DISTRIBUTED"},"bolen":1000,"ondalik":0,"not":{"tr":"Ülke rakamının kaynağı Tarım ve Orman Bakanlığı. TİGEM satırı kurumun kendi ekilişlerini de içeriyor; bu yüzden aynı yılın satış rakamından yüksektir. 2002'de 84.216 ton olan ülke dağıtımı 2022'de 613.206 tona çıktı; TİGEM'inki 75.812'den 122.045 tona.","en":"The country figure comes from the Ministry of Agriculture and Forestry. The TİGEM series includes the seed the institution sowed on its own land, which is why it exceeds the sales figure for the same year. Country-wide distribution rose from 84,216 tonnes in 2002 to 613,206 in 2022; TİGEM's from 75,812 to 122,045."},"kaynak":"Tohumculuk Sektör Raporu 2022, Tablo 9 ve 10 · ülke rakamı TOB","seriler":[{"ad":{"tr":"Türkiye toplamı","en":"Türkiye total"},"rol":"ikincil","noktalar":{"liste":[{"yil":2002,"turkiye":84216,"tigem":75812,"pay":90},{"yil":2010,"turkiye":294586,"tigem":173720,"pay":59},{"yil":2015,"turkiye":608751,"tigem":142867,"pay":23.5},{"yil":2020,"turkiye":706892,"tigem":155948,"pay":22.1},{"yil":2021,"turkiye":629319,"tigem":117799,"pay":18.7},{"yil":2022,"turkiye":613206,"tigem":122045,"pay":19.9}],"x":"yil","y":"turkiye"}},{"ad":{"tr":"TİGEM","en":"TİGEM"},"rol":"vurgu","noktalar":{"liste":[{"yil":2002,"turkiye":84216,"tigem":75812,"pay":90},{"yil":2010,"turkiye":294586,"tigem":173720,"pay":59},{"yil":2015,"turkiye":608751,"tigem":142867,"pay":23.5},{"yil":2020,"turkiye":706892,"tigem":155948,"pay":22.1},{"yil":2021,"turkiye":629319,"tigem":117799,"pay":18.7},{"yil":2022,"turkiye":613206,"tigem":122045,"pay":19.9}],"x":"yil","y":"tigem"}}]},"tigem_payi":{"tur":"cizgi","baslik":{"tr":"Doksandan yirmiye","en":"From ninety to twenty"},"birim":{"tr":"% · TİGEM'in ülke hububat tohumu dağıtımındaki payı","en":"% · TİGEM's share of national cereal seed distribution"},"ondalik":1,"not":{"tr":"2002'de ülkede dağıtılan sertifikalı buğday ve arpa tohumunun yüzde 90'ı TİGEM'den geliyordu; 2022'de yüzde 19,9'u. Rakamlar buğday ve arpanın toplamından hesaplandı. Raporun kendi ifadesiyle payın düşmesi, özel sektör firmalarının bu alanda hızla gelişmesinden kaynaklanıyor.","en":"In 2002, 90 per cent of the certified wheat and barley seed distributed in the country came from TİGEM; in 2022, 19.9 per cent. The figures are computed from wheat and barley combined. In the report's own words, the falling share reflects the rapid growth of private firms in this field."},"kaynak":"Tohumculuk Sektör Raporu 2022, Tablo 9 ve 10'dan hesaplandı","seriler":[{"ad":{"tr":"TİGEM'in payı","en":"TİGEM's share"},"rol":"vurgu","noktalar":{"liste":[{"yil":2002,"turkiye":84216,"tigem":75812,"pay":90},{"yil":2010,"turkiye":294586,"tigem":173720,"pay":59},{"yil":2015,"turkiye":608751,"tigem":142867,"pay":23.5},{"yil":2020,"turkiye":706892,"tigem":155948,"pay":22.1},{"yil":2021,"turkiye":629319,"tigem":117799,"pay":18.7},{"yil":2022,"turkiye":613206,"tigem":122045,"pay":19.9}],"x":"yil","y":"pay"}}]},"tohum_yolu":{"tur":"islem_akisi","baslik":{"tr":"Tohum bayiye nasıl ulaşıyor","en":"How the seed reaches the dealer"},"not":{"tr":"Adımlar ve süreler Tohumluk Satış ve Dağıtım Yönergesi'nin dokuzuncu maddesinde yazılı. Çiftçi bu yoldan geçmek zorunda değil: Yönetim Kurulunun belirlediği peşin satış fiyatı üzerinden Genel Müdürlüğe veya işletmeye yazılı başvurarak doğrudan da alabilir. Fiyatlar her yıl Haziran-Ağustos arasında belirleniyor.","en":"The steps and deadlines are set out in article nine of the Seed Sales and Distribution Directive. A farmer need not use this route: they may buy directly by applying in writing to the General Directorate or an enterprise at the cash price set by the Board. Prices are set each year between June and August."},"kaynak":"TİGEM Tohumluk Satış ve Dağıtım Yönergesi · YK kararı 10/03/2017-80, değişik 22.12.2022-401","adimlar":[{"baslik":{"tr":"Ön talep","en":"Preliminary request"},"aktor":{"tr":"Bayi","en":"Dealer"},"cikti":{"tr":"Bayi Otomasyon Sistemi kaydı","en":"Entry in the Dealer Automation System"}},{"baslik":{"tr":"Ön tahsis","en":"Preliminary allocation"},"aktor":{"tr":"TİGEM","en":"TİGEM"},"cikti":{"tr":"Kota ve ön talebe göre bildirim","en":"Notification based on quota and request"}},{"baslik":{"tr":"Kesin tahsise çevirme","en":"Confirming the allocation"},"aktor":{"tr":"Bayi","en":"Dealer"},"sure":{"tr":"5 iş günü","en":"5 working days"},"cikti":{"tr":"Bedelin %10'u peşin; çevrilmeyen tahsis sistemce iptal edilir","en":"10% of the price paid up front; an unconfirmed allocation is cancelled automatically"}},{"baslik":{"tr":"Teslim alma","en":"Collection"},"aktor":{"tr":"Bayi","en":"Dealer"},"sure":{"tr":"20 takvim günü","en":"20 calendar days"},"cikti":{"tr":"Tohumluk tahsis edilen işletmeden alınır","en":"The seed is collected from the allocated enterprise"}},{"baslik":{"tr":"Ödeme","en":"Payment"},"aktor":{"tr":"Bayi","en":"Dealer"},"cikti":{"tr":"Bayi Otomasyon Sistemi üzerinden","en":"Through the Dealer Automation System"},"secenekler":[{"tr":"nakit","en":"cash"},{"tr":"banka teminat mektubu","en":"bank letter of guarantee"}]},{"baslik":{"tr":"Sevkiyat","en":"Dispatch"},"aktor":{"tr":"Bayi","en":"Dealer"},"cikti":{"tr":"Randevuyla; yükleme işletmenin, nakliye bayinin","en":"By appointment; loading is the enterprise's duty, haulage the dealer's"}}]},"dagitim_kanallari":{"tur":"kartlar","baslik":{"tr":"Dört kapı","en":"Four doors"},"not":{"tr":"Yönergenin yedinci maddesi dağıtım araçlarını sayıyor. Dağıtıcı kuruluşlar bu dizinin başka iki kurumu: Tarım Kredi Kooperatifleri ve Pankobirlik.","en":"Article seven of the directive lists the distribution channels. The distributing organisations are two other institutions in this series: the Agricultural Credit Cooperatives and Pankobirlik."},"kaynak":"TİGEM Tohumluk Satış ve Dağıtım Yönergesi, madde 7-8","kartlar":[{"ust":{"tr":"Doğrudan","en":"Direct"},"baslik":{"tr":"İşletmeler","en":"The enterprises"},"govde":{"tr":"Çiftçi Genel Müdürlüğe ya da işletmeye yazılı başvuruyor, Yönetim Kurulunun belirlediği peşin fiyattan alıyor.","en":"The farmer applies in writing to the General Directorate or to an enterprise and buys at the cash price set by the Board."},"rakam":{"deger":17,"ondalik":0,"etiket":{"tr":"faaliyetteki işletme","en":"operating enterprises"}}},{"ust":{"tr":"Sözleşmeli","en":"Under contract"},"baslik":{"tr":"TİGEM bayileri","en":"TİGEM dealers"},"govde":{"tr":"Bakanlıktan Tohumluk Bayi Belgesi almış gerçek ve tüzel kişiler. Sözleşme bir yıllık ve kendiliğinden uzuyor; bayi yalnız başvurduğu il sınırları içinde satabiliyor.","en":"Natural and legal persons holding a Seed Dealer Certificate from the ministry. The contract runs for one year and renews automatically; a dealer may sell only within the province named in its application."},"rakam":{"deger":303,"ondalik":0,"etiket":{"tr":"bayi · 2003-2023","en":"dealers · 2003-2023"}}},{"ust":{"tr":"Kamu","en":"Public"},"baslik":{"tr":"İl müdürlükleri","en":"Provincial directorates"},"govde":{"tr":"İl Tarım ve Orman Müdürlüğü çeşit çeşit talebini yazıyla iletiyor, tahsis Genel Müdürlükçe işletmelerden yapılıyor.","en":"The provincial directorate submits its request by letter, variety by variety, and the General Directorate allocates from the enterprises."}},{"ust":{"tr":"Protokolle","en":"By protocol"},"baslik":{"tr":"Dağıtıcı kuruluşlar","en":"Distributing organisations"},"govde":{"tr":"Tarım Kredi Kooperatifleri ve Pankobirlik, TİGEM ile imzalanan Dağıtıcı Kuruluş Protokolü esaslarında tohumluk alıyor.","en":"The Agricultural Credit Cooperatives and Pankobirlik take seed under a Distributing Organisation Protocol signed with TİGEM."}}]},"kira_asimetrisi":{"tur":"ikili_cubuk","baslik":{"tr":"İşletmelerin yarısı, arazinin onda biri","en":"Half the enterprises, a tenth of the land"},"not":{"tr":"Otuz dört işletmenin on yedisi kiraya verilmiş durumda ama bu işletmeler TİGEM arazisinin yüzde 9,07'sini tutuyor: kiraya verilenler küçük işletmeler. Oranı kurumun kendi arazi tablosu yazıyor ve satırlardan yeniden hesaplandı. Her satır kendi içinde oranlanıyor; satırlar birbiriyle değil.","en":"Seventeen of thirty-four enterprises are leased out, but they hold 9.07 per cent of TİGEM's land: the leased ones are the small ones. The ratio is printed in the institution's own land table and was recomputed from the rows. Each row is scaled within itself, not against the other."},"kaynak":"TİGEM · arazi varlığı tablosu, 25.07.2023 · işletme sayıları tigem.gov.tr","seriler":[{"ad":{"tr":"TİGEM'in kullanımında","en":"Run by TİGEM"},"rol":"vurgu"},{"ad":{"tr":"Kiraya verilmiş","en":"Leased out"},"rol":"ikincil"}],"sonek":{"tr":"%","en":"%"},"ondalik":1,"satirlar":[{"etiket":{"tr":"İşletme sayısı","en":"Number of enterprises"},"degerler":[50,50],"ondalik":1,"sonek":{"tr":"%","en":"%"}},{"etiket":{"tr":"Arazi","en":"Land"},"degerler":[90.93,9.07],"ondalik":1,"sonek":{"tr":"%","en":"%"}}]},"sperma_satisi":{"tur":"cizgi","baslik":{"tr":"Beş yılda iki katından fazla","en":"More than double in five years"},"birim":{"tr":"bin doz · boğa sperması satışı","en":"thousand doses · bull semen sold"},"bolen":1000,"ondalik":0,"not":{"tr":"Üretim merkezi Malatya'daki Sultansuyu İşletmesinde 2012'de açıldı. 2018'de 460 bin doz satılmış, 2023'te 1 milyon 19 bin doz. Seride 2019 yılı yok; kurumun yayımladığı dizide o yıl bulunmuyor.","en":"The production centre opened in 2012 at the Sultansuyu enterprise in Malatya. 460,000 doses were sold in 2018 and 1,019,000 in 2023. The year 2019 is absent from the series; it is missing from the figures the institution published."},"kaynak":"TİGEM · Mart 2024 sunumu","seriler":[{"ad":{"tr":"Satılan doz","en":"Doses sold"},"rol":"vurgu","noktalar":{"liste":[{"yil":2018,"doz":460000},{"yil":2020,"doz":658000},{"yil":2021,"doz":874000},{"yil":2022,"doz":945000},{"yil":2023,"doz":1019000}],"x":"yil","y":"doz"}}]},"korunanlar":{"tur":"kartlar","baslik":{"tr":"Tohumdan başka ne koruyor","en":"What else it keeps alive"},"not":{"tr":"Kurum, sertifikalı tohum ve damızlığın yanında kaybolmakta olan yerel çeşitleri ve ırkları da elinde tutuyor. Atçılık Osmanlı'daki Çiftlikat-ı Hümayun'dan geliyor.","en":"Alongside certified seed and breeding stock, the institution maintains local varieties and breeds that are disappearing. The horse breeding descends from the Ottoman imperial farms."},"kaynak":"TİGEM · 2024-2028 Stratejik Plan, Mart 2024 sunumu, Yerel Çeşit Listesi","kartlar":[{"ust":{"tr":"Bitki","en":"Plant"},"baslik":{"tr":"Yerel Ata tohumları","en":"Ancestral local seeds"},"govde":{"tr":"Kaybolmakta olan yerel çeşitler toplanıp çoğaltılıyor ve tescil ettiriliyor. Listedeki her çeşidin kendi künyesi var: Şahnalı Acı Biber, kayıt numarası TGM18335.","en":"Disappearing local varieties are collected, propagated and registered. Each variety on the list has its own record: Şahnalı hot pepper, registration number TGM18335."},"rakam":{"deger":1027,"ondalik":0,"etiket":{"tr":"çeşit","en":"varieties"}}},{"ust":{"tr":"At","en":"Horse"},"baslik":{"tr":"Safkan Arap Atı","en":"The Purebred Arabian horse"},"govde":{"tr":"Karacabey, Sultansuyu ve Anadolu işletmelerinde sürdürülüyor; kurumun ifadesiyle Çiftlikat-ı Hümayun adı altında Osmanlı'nın kuruluşundan beri devam eden bir faaliyet. Her yıl ortalama 260 yarış tayı yetiştiriliyor.","en":"Continued at the Karacabey, Sultansuyu and Anadolu enterprises; in the institution's words an activity carried on since the founding of the Ottoman state under the name of the imperial farms. An average of 260 racing foals are raised each year."},"rakam":{"deger":1549,"ondalik":0,"etiket":{"tr":"baş","en":"head"}}},{"ust":{"tr":"Keçi","en":"Goat"},"baslik":{"tr":"Ankara Tiftik Keçisi","en":"The Angora goat"},"govde":{"tr":"Tiftiğiyle bir şehre adını veren ırk, kurumun koruduğu yerli ırklar arasında.","en":"The breed that gave a city its name through its mohair is among the native breeds the institution maintains."}},{"ust":{"tr":"Köpek ve ceylan","en":"Dog and gazelle"},"baslik":{"tr":"Kangal ve Asya Ceylanı","en":"The Kangal and the Asian gazelle"},"govde":{"tr":"Bir tohum kuruluşunun koruma listesinde bir çoban köpeği ve bir yaban hayvanı da var. Ceylanpınar, adını o ceylandan alıyor.","en":"A seed institution's conservation list also holds a shepherd dog and a wild animal. Ceylanpınar takes its name from that gazelle."}}]},"iki_model":{"tur":"kartlar","baslik":{"tr":"Aynı sorun, iki çözüm","en":"The same problem, two answers"},"not":{"tr":"Çiftçiye sertifikalı tohum ulaştırmanın iki yolu var: devlet ya kendi çiftliğinde üretir ya da üretileni belgeler. Türkiye ikisini birden yapıyor.","en":"There are two ways to get certified seed to the farmer: the state either grows it on its own farms or certifies what others grow. Türkiye does both."},"kaynak":"OECD Tohum Şemaları katılımcı ülke listesi · Hindistan rakamları hükûmet açıklamalarından aktaran basın, 2012-2013","kartlar":[{"ust":{"tr":"Üretim modeli","en":"The production model"},"baslik":{"tr":"Türkiye","en":"Türkiye"},"govde":{"tr":"Devlet otuz dört işletmede kendi tohumunu, damızlığını ve spermasını üretiyor; ayrıca dağıtım ağını da kendisi kuruyor.","en":"The state produces its own seed, breeding stock and semen at thirty-four enterprises, and builds the distribution network itself."},"rakam":{"deger":360245,"ondalik":0,"etiket":{"tr":"hektar","en":"hectares"}}},{"ust":{"tr":"Üretim modeli","en":"The production model"},"baslik":{"tr":"Hindistan","en":"India"},"govde":{"tr":"State Farms Corporation of India devletin büyük makineli çiftliklerini tohum için işletiyordu. Hindistan hükûmetinin bildirdiğine göre Rajasthan, Haryana ve Karnataka'da beş merkezî devlet çiftliği vardı. 2013'te bu yapı, 1963 kuruluşlu National Seeds Corporation bünyesine katıldı; gerekçe, çiftliklerin arazisiyle tohum kuruluşunun dağıtım ağını birleştirmekti.","en":"The State Farms Corporation of India ran the state's large mechanised farms for seed. According to the Indian government it held five central state farms in Rajasthan, Haryana and Karnataka. In 2013 it was merged into the National Seeds Corporation, founded in 1963, in order to combine the farms' land with the seed corporation's distribution network."},"rakam":{"deger":21908,"ondalik":0,"etiket":{"tr":"hektar","en":"hectares"}}},{"ust":{"tr":"Belgeleme modeli","en":"The certification model"},"baslik":{"tr":"OECD Tohum Şemaları","en":"The OECD Seed Schemes"},"govde":{"tr":"Bu modelde devlet tohum üretmez, üretilenin belgesini verir. Şemalara altmıştan fazla ülke katılıyor ve listede Türkiye de var: Hindistan, Mısır, Fas, İran, Rusya ve Amerika Birleşik Devletleri ile aynı listede.","en":"In this model the state does not grow seed; it certifies what others grow. More than sixty countries take part, Türkiye among them, on the same list as India, Egypt, Morocco, Iran, Russia and the United States."}}]}}$dsr$::jsonb,
  array['TİGEM', 'Tarım İşletmeleri Genel Müdürlüğü', 'sertifikalı tohum', 'tohumluk', 'Ceylanpınar', 'Devlet Üretme Çiftlikleri', 'hara', 'Zirai Kombinalar', 'tohum bayisi']::text[],
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
 where dossier_id = (select id from public.country_dossiers where slug = 'tigem');

insert into public.dossier_sections
  (dossier_id, ord, title_tr, title_en, body_tr, body_en, chart_keys, tur, gorsel)
select d.id, v.ord, v.title_tr, v.title_en, v.body_tr, v.body_en, v.chart_keys, v.tur, v.gorsel
from public.country_dossiers d
cross join (values
  (1::integer, $dsr$Tohumun geldiği yer$dsr$, $dsr$Where the seed comes from$dsr$, $dsr$Türkiye'de bir çiftçi tarlasına buğday ekerken elindeki tohumun beşte bir
ihtimalle geldiği tek bir adres var: Tarım İşletmeleri Genel Müdürlüğü.
Kısaca TİGEM.

Kurum 34 tarım işletmesine ve 3.602.455 dekar araziye sahip. Bu, Türkiye'nin
bütün tarım arazisinin **yüzde 0,93'ü** demek — yüzde birinden az. Buna
karşılık 2022'de ülkede dağıtılan sertifikalı buğday ve arpa tohumunun
yüzde 19,9'u TİGEM'den çıktı. 2023'te çiftçiye satılan sertifikalı hububat
tohumu 113 bin tona ulaştı.

Oran ile alanın bu kadar açılması bir başarı iddiası değil, bir iş
tanımıdır. TİGEM gıda üretmek için kurulmuş bir kurum değil. Ürettiği şey
**girdi**: tohumluk, fidan, fide, damızlık hayvan ve sperma. Çiftçi bu
kurumla pazarda, ürününü satarken karşılaşmıyor; tarlasına girerken, ekim
zamanında karşılaşıyor.

İkinci ürün hattı hayvancılık. 2023'te damızlık sığır varlığı 27 bin baş,
damızlık koyun varlığı 284 bin baş. Malatya'daki Sultansuyu İşletmesinde
2012'de açılan Boğa Sperması Üretim Merkezi aynı yıl 1 milyon 19 bin doz
sperma sattı. Kurum ayrıca 3 işletmede 1.549 baş Safkan Arap Atı tutuyor ve
yılda ortalama 260 yarış tayını sektöre veriyor.

Tohum hazırlama kapasitesi saatte 341 ton. Çiftçinin bu kapasiteye ulaştığı
nokta ise 2003 ile 2023 arasında kurulmuş **303 TİGEM bayisi**.

Hukuken kurum bir İktisadi Devlet Teşekkülü. Merkezi Ankara'da, ilgili
bakanlığı Tarım ve Orman Bakanlığı, denetimi Türkiye Büyük Millet Meclisi
ve Sayıştay'da.

Sayıştay'ın 2024 yılı Kamu İşletmeleri Genel Raporu kurumun bilanço satırını
veriyor: 8,0 milyar liralık dönen varlık, 17,1 milyar liralık duran varlık,
22,9 milyar liralık özkaynak. Uzun vadeli yabancı kaynağı yok. Esas sermayesi
9,4 milyar lira, ödenmiş sermayesi 7,9 milyar lira. Aynı tabloda Toprak
Mahsulleri Ofisi ve Devlet Demiryolları da var; TİGEM kamu işletmeleri
içinde bu ölçekte bir kuruluş.

Bu dosyanın anlattığı şey o bilanço değil. Anlattığı şey, bir kurumun yetmiş
üç yıldır aynı cümleyle tarif edilen işini nasıl yaptığı — ve o işin neden
ülkenin tarlalarında, kurumun kendi arazisinden çok daha geniş bir yer
kapladığı.$dsr$, $dsr$When a farmer in Türkiye sows wheat, there is one address the seed in their
hand has a one-in-five chance of having come from: the General Directorate of
Agricultural Enterprises, TİGEM for short.

The institution holds 34 agricultural enterprises and 3,602,455 decares of
land. That is **0.93 per cent** of all farmland in Türkiye — less than one per
cent. Against that, 19.9 per cent of the certified wheat and barley seed
distributed in the country in 2022 came from TİGEM. In 2023 certified cereal
seed sold to farmers reached 113,000 tonnes.

The gap between the share and the area is not a boast but a job description.
TİGEM was not founded to produce food. What it produces is **input**: seed,
saplings, seedlings, breeding animals and semen. The farmer does not meet this
institution at the market when selling a crop; they meet it on the way into
the field, at sowing time.

The second product line is livestock. In 2023 the stock of breeding cattle
stood at 27,000 head and breeding sheep at 284,000 head. The Bull Semen
Production Centre, opened in 2012 at the Sultansuyu enterprise in Malatya,
sold 1,019,000 doses of semen that year. The institution also keeps 1,549
Purebred Arabian horses at 3 enterprises and supplies an average of 260 racing
foals a year.

Seed processing capacity is 341 tonnes per hour. The point where the farmer
reaches that capacity is a network of **303 TİGEM dealers** set up between
2003 and 2023.

In law the institution is a state economic enterprise. Its headquarters are in
Ankara, its ministry is the Ministry of Agriculture and Forestry, and it is
audited by the Grand National Assembly and the Court of Accounts.

The Court of Accounts' 2024 General Report on Public Enterprises gives its
balance-sheet line: 8.0 billion lira of current assets, 17.1 billion lira of
fixed assets, 22.9 billion lira of equity. It has no long-term external
liabilities. Its authorised capital is 9.4 billion lira and its paid-in
capital 7.9 billion. The Turkish Grain Board and the State Railways appear in
the same table; TİGEM is a public enterprise of that order.

What this dossier describes is not that balance sheet. It is how an
institution does a job that has been defined by the same sentence for
seventy-three years — and why that job occupies a far wider place in the
country's fields than the institution's own land.$dsr$, array['kunye_tigem']::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/tigem/tigem_hasat.jpg","atif":"Ckoroglu — CC BY-SA 3.0","kaynak":null,"alt_tr":"Buğday harmanı, Tekmen. Fotoğrafın tarihi kayıtlı değil; kaynak künyesi 2010'dan önce diyor.","alt_en":"Threshing wheat at Tekmen. The date is not recorded; the source says before 2010."}$dsr$::jsonb),
  (2, $dsr$Önce ödenek, sonra kanun$dsr$, $dsr$The appropriation came first, the law second$dsr$, $dsr$TİGEM'in iki kolundan biri 1937'de başlıyor ve başlangıcı bir kuruluş kanunu
değil, bir **bütçe faslı**.

12 Şubat 1937 tarihli 3130 sayılı Kanun, 1936 malî yılı bütçesine dokuz yeni
fasıl açıyor ve bunlara toplam 4.512.636 lira fevkalade tahsisat koyuyor.
Dokuz fasıldan biri, Ziraat Vekâleti bütçesinde yeni açılan **858'inci
fasıl**, adı "Ziraî kombinalar kurumu masrafları". Ayrılan tutar
3.000.000 lira.

| fasıl | lira |
|---|---:|
| **858 · Ziraî kombinalar kurumu masrafları** | **3.000.000** |
| 784 · Maden Tetkik ve Arama Enstitüsüne yardım | 500.000 |
| 1023 · Tank imalâtı tesisatı | 350.000 |
| 658 · Okullara fizik ve kimya aletleri | 300.000 |
| 235 · İstanbul Üniversitesi istikraz karşılığı | 229.636 |
| öteki dört fasıl | 133.000 |

Tek bir fasıl, o kanunun koyduğu bütün fevkalade tahsisatın **yüzde
66,5'i**. Karşılaştırma için: aynı listede tank imalâtı tesisatına 350.000,
Maden Tetkik ve Arama Enstitüsüne 500.000 lira konmuş.

Kanunun dördüncü maddesi tahsisatın nereye yatırılacağını da yazıyor:
Ziraat Bankasında açtırılacak **hususî bir kredi hesabına**. Aynı madde
şöyle devam ediyor: *"Bu krediden yapılacak masraflar hususî bir kanun ile
tayin olunur. Ancak bu kanunun tanzim ve meriyete girmesine kadar İcra
Vekilleri Heyeti kararile tayin edilecek işler için sarfiyat yapılır."*

Yani kurumun kaynağı, kurumun kanunundan önce ayrılmış. Harcamanın esaslarını
belirleyecek kanun henüz yazılmamış; o gelene kadar neyin yapılacağına
Bakanlar Kurulu karar verecek. Beklenen kanun on bir ay sonra geldi.

Zirai Kombinaların ne iş yapacağı kurumun kendi anlatımında yazılı: ordunun
gerektiğinde halkın gıda ihtiyacını karşılaması. Bunun için yurdun değişik
yörelerindeki Hazineye ait boş araziler seçiliyor ve çiftliğe dönüştürülüyor.
Yani kuruluşun başlangıç mantığı ticaret değil **ihtiyat**: bir savaş ya da
kıtlık hâlinde devletin elinin altında ekilebilir, makineli, büyük ölçekli
tarla bulunması.

Aynı kanunun aynı cetvelinde tank imalâtı tesisatı için ayrılan tutarın
3.000.000 liralık tarım faslının yanında kalması bu mantığı birebir
gösteriyor. 1937'de devlet iki işe birden bütçe açıyordu ve ikisi de aynı
gerekçeyle açılmıştı.$dsr$, $dsr$One of TİGEM's two branches begins in 1937, and it begins not with a founding
law but with a **budget line**.

Law 3130 of 12 February 1937 opened nine new lines in the 1936 fiscal-year
budget and placed 4,512,636 lira of extraordinary appropriation in them. One
of the nine, newly opened in the Ministry of Agriculture's budget, was
**line 858**, named "expenses of the State Agricultural Combines". The sum
allocated was 3,000,000 lira.

| line | lira |
|---|---:|
| **858 · Expenses of the State Agricultural Combines** | **3,000,000** |
| 784 · Grant to the Mineral Research and Exploration Institute | 500,000 |
| 1023 · Tank manufacturing plant | 350,000 |
| 658 · Physics and chemistry equipment for schools | 300,000 |
| 235 · Istanbul University loan | 229,636 |
| the other four lines | 133,000 |

A single line took **66.5 per cent** of all the extraordinary appropriation
that law contained. For comparison: on the same list, tank manufacturing plant
received 350,000 lira and the Mineral Research Institute 500,000.

The law's fourth article also states where that appropriation was to go: into a
**special credit account** to be opened at Ziraat Bankası. The same article
continues: *"The expenses to be made from this credit shall be determined by a
special law. However, until that law is drawn up and enters into force,
expenditure shall be made for works to be determined by decision of the
Council of Ministers."*

So the institution's funding was set aside before the institution's law. The
law that would govern how that credit was to be spent had not yet been written; until
it arrived, the Council of Ministers would decide what to do. The awaited law
came eleven months later.

What the Agricultural Combines were for is stated in the institution's own
account: so that the army could meet the population's food needs if required.
For that purpose empty Treasury land in various parts of the country was
selected and turned into farms. The founding logic was not commerce but
**reserve**: in a war or a famine the state would have arable, mechanised,
large-scale fields within reach.

That the sum set aside for tank manufacturing plant sits on the same schedule
beside a 3,000,000-lira agricultural line shows the logic exactly. In 1937 the
state was opening budget lines for two kinds of work, and both were opened for
the same reason.$dsr$, array['fevkalade_tahsisat_1937']::text[], 'belge', $dsr${"url":"https://tarimportali.net/dosya/tigem/tigem_orman_ciftligi_1929b.jpg","atif":"Unknown authorUnknown author — kamu malı","kaynak":null,"alt_tr":"Mustafa Kemal, Ankara'daki örnek Orman Çiftliği'nde, 14 Temmuz 1929. Aynı ziyaretten ikinci kare; birincisi dördüncü bölümde.","alt_en":"Mustafa Kemal at the model Forest Farm in Ankara, 14 July 1929. A second frame from the same visit; the first is in section 4."}$dsr$::jsonb),
  (3, $dsr$Haralar: ordunun atı$dsr$, $dsr$The studs: the army's horse$dsr$, $dsr$Kurumun öteki kolu çok daha eski ve çiftlikle değil **harayla** başlıyor.

Haralar Osmanlı Devleti'nin ilk yıllarında kuruluyor; işleri ordunun ve
sarayın iaşesini karşılamak ve at yetiştirmek. Kurumun kendi anlatımına göre
hara arazileri bir dönem 3–4 milyon dekara ulaşıyor, devlet güç kaybettikçe
küçülüyor ve 450 bin dekara kadar iniyor. Bu rakamların bağımsız bir
karşılığı bulunamadı; kurumun kendi bildirimi olarak okunmalı.

Bu kolun bugün hâlâ duran yanı at. TİGEM atçılığı Bursa'daki Karacabey,
Malatya'daki Sultansuyu ve Eskişehir'deki Anadolu işletmelerinde sürdürüyor;
toplam hayvan varlığı 1.549 baş ve yılda ortalama 260 yarış tayı
yetiştiriliyor. Kurum bu faaliyeti "Çiftlikat-ı Hümayun adı altında
Osmanlı'nın kuruluşundan beri devam eden" bir iş olarak tanımlıyor.

Haraların yanında **inekhaneler** var. İkisi birlikte, Cumhuriyet'in kurduğu
çiftliklerden ayrı bir damar oluşturuyor: biri hayvan yetiştiriyor, öteki
tarla açıyor. 1983'te tek çatı altında toplanacak olan şey bu iki damardır
ve bunu kurumun anlatısından değil, bir kanun metninden okumak mümkün.
1990 tarihli 3646 sayılı Kanun, TİGEM adına tescil edilecek taşınmazları
sayarken iki kaynağı ayrı ayrı yazıyor: mülga 5433 sayılı Kanunla Devlet
Üretme Çiftlikleri'ne geçen taşınmazlar, ve Hazineye ait olup **hara ve
inekhanelere** tahsisli taşınmazlar.

İki soy, bir kanun maddesinin iki bendi.

İnekhaneler ise adından anlaşılacağı gibi süt sığırcılığı yapıyordu ve
haralarla birlikte Veteriner İşleri Genel Müdürlüğünün alanındaydı.
3646 sayılı Kanun, bu kuruluşların tasarrufundaki Hazine taşınmazlarını
TİGEM adına tescil ettirirken, Maliye ve Gümrük Bakanlığından alınacak
muvafakati de şart koşuyor — yani hara ve inekhane arazileri doğrudan değil,
bir onayla geçiyor.

Bugün kurumun hayvancılık kolunun bütün ağırlığı — 14 işletmede damızlık
sığır, 10 işletmede damızlık koyun, Ceylanpınar'da Halep ırkı keçi — bu
damardan geliyor. At yetiştiriciliği ise o damarın başladığı yerdeki işin
kendisi: ordunun atını yetiştirmek. Ordu artık at kullanmıyor, kurum atı
yetiştirmeye devam ediyor; müşterisi değişti, iş aynı kaldı.$dsr$, $dsr$The institution's other branch is far older and begins not with a farm but
with a **stud**.

The studs were founded in the first years of the Ottoman state; their work was
to supply the army and the palace and to breed horses. By the institution's
own account the stud lands reached 3–4 million decares at one point, shrank as
the state lost strength, and fell to 450,000 decares. No independent
counterpart to these figures was found; they should be read as the
institution's own statement.

The surviving side of this branch is the horse. TİGEM continues horse breeding
at the Karacabey enterprise in Bursa, Sultansuyu in Malatya and Anadolu in
Eskişehir; the total stock is 1,549 head and an average of 260 racing foals
are raised each year. The institution describes this work as one that has
"continued since the founding of the Ottoman state under the name of the
imperial farms".

Alongside the studs there were the **cattle farms**. Together the two form a
strand distinct from the farms founded by the Republic: one bred animals, the
other opened fields. What was brought under one roof in 1983 was these two
strands, and this can be read not from the institution's narrative but from a
law. Law 3646 of 1990, listing the immovables to be registered in TİGEM's
name, writes the two sources out separately: property that passed to the
General Directorate of State Production Farms under the repealed Law 5433, and
Treasury property allocated to the **studs and cattle farms**.

Two lineages, two clauses of one article.

The cattle farms, as the name suggests, were dairy operations and, with the
studs, fell within the remit of the former General Directorate of Veterinary
Affairs. When Law 3646 registered the Treasury property held by these bodies
in TİGEM's name, it also required the consent of the Ministry of Finance and
Customs — so the stud and cattle-farm land passed not directly but by
approval.

The whole weight of the institution's livestock side today — breeding cattle
at 14 enterprises, breeding sheep at 10, Aleppo goats at Ceylanpınar — comes
from this strand. Horse breeding is the original work itself: raising the
army's horse. The army no longer uses horses; the institution still breeds
them. The customer changed, the work did not.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/tigem/tigem_karacabey.jpg","atif":"Ufuk Önen — CC BY 3.0","kaynak":null,"alt_tr":"Karacabey, Bursa, 30 Temmuz 2008. Kaynak künyesi yerden başka bir şey söylemiyor; atların hangi işletmeye ait olduğu kayıtlı değil.","alt_en":"Karacabey, Bursa, 30 July 2008. The source records the place and nothing more; which enterprise the horses belong to is not stated."}$dsr$::jsonb),
  (4, $dsr$Atatürk'ün mektubu$dsr$, $dsr$Atatürk's letter$dsr$, $dsr$1937'de ayrılan tahsisatın beklediği "hususî kanun" 7 Ocak 1938'de kabul
edildi: **3308 sayılı Kanun**. Birinci maddesi, her türlü ziraat işleri ve
sanatlarıyla uğraşmak üzere, merkezi Ankara'da, Ziraat Vekâletine bağlı ve
hükmî şahsiyeti haiz bir **Devlet Ziraat İşletmeleri Kurumu** kuruyor.
İtibarî sermayesi 15.000.000 lira.

Kurumun o sermayeyi nasıl doldurduğu beşinci maddede yazılı:

*"Atatürkün 11-VI-1937 tarihli mektub ile Hazineye teberru ettiği bütün menkul
ve gayrimenkul mallar ve bunlara aid hak ve vecibeler bu kanunun neşri
tarihinden itibaren Devlet ziraat işletmeleri kurumuna intikal eder."*

Aynı maddenin devamı mekanizmayı da kuruyor. İntikal eden malların
1 İkinciteşrin 1937 tarihindeki bilanço durumu esas alınacak; Maliye,
Ziraat ve kurumdan birer kişiden oluşan üç kişilik bir komisyon kıymet
takdiri yapacak; ve bu kıymetler *"sermaye hesabına mahsuben vukubulmuş
tediye sayılır."*

Kurumun ilk ödenmiş sermayesi nakit değil **toprak**. Atatürk'ün muhtelif
tarihlerde kurduğu ve 11 Haziran 1937 tarihli bir mektupla Hazineye
bağışladığı çiftlikler, bir komisyonun biçtiği değerle sermaye hesabına
yazılıyor.

Kanunun kuruma verdiği işler bugünkü TİGEM'den geniş. Üçüncü madde, ziraî ve
sınaî müesseseleri işletmenin yanında, bölgelere göre gerekli ziraat
çeşitlerini ve usullerini gösterip yayacak **numune ve rehber** işletme
merkezleri, fabrika ve atölyeler kurmayı; **silo ve ambar işleriyle uğraşıp
silolarda varant muamelesi yapmayı**; ve iştigal konularıyla ilgili
teşekküller kurmayı ya da bunlara iştirak etmeyi sayıyor. Ticaret, nakliye ve
kredi işleri de madde metninde geçiyor.

Yönetimi de dönemin ölçüsünde geniş. Sekizinci maddeye göre kurum, Başvekilin
başkanlığında Maliye, İktisad ve Ziraat vekilleri ile Büyük Millet Meclisinin
Bütçe, Divanı Muhasebat, İktısad, Maliye ve Ziraat encümenlerinin kendi
üyeleri arasından seçecekleri üçer üyeden ve Şûrayı Devlet ile Divanı
Muhasebat reislerinden oluşan bir umumî heyet tarafından denetleniyor.
İdare meclisi üyelerinin ziraat, ziraat sanatları ya da toprak ekonomisi
alanında meslekî yüksek tahsil görmüş olması şart.

Bu çiftliklerin en ünlüsü uzun süre kurumda kalmadı. 24 Mart 1950'de kabul
edilen **5659 sayılı Kanun**, Ankara'da Tarım Bakanlığına bağlı ve tüzel
kişiliği haiz bir Atatürk Orman Çiftliği Müdürlüğü kurdu; sermayesi
7.500.000 lira. Soy yeni adını aldıktan dokuz ay sonra, en bilinen çiftliği
soydan ayrıldı.$dsr$, $dsr$The "special law" that the 1937 appropriation was waiting for was adopted on
7 January 1938: **Law 3308**. Its first article established a **State
Agricultural Enterprises Corporation** with legal personality, attached to the
Ministry of Agriculture, headquartered in Ankara, to engage in every kind of
agricultural work and craft. Its nominal capital was 15,000,000 lira.

How it filled that capital is written in the fifth article:

*"All movable and immovable property donated to the Treasury by Atatürk's
letter dated 11 June 1937, and the rights and obligations attached to them,
shall pass to the State Agricultural Enterprises Corporation from the date of
publication of this law."*

The rest of the article sets out the mechanism. The balance-sheet position of
the transferred property as at 1 November 1937 would be taken as the basis; a
three-person commission with one member each from the Ministry of Finance, the
Ministry of Agriculture and the corporation would assess its value; and those
values *"shall be deemed a payment made against the capital account."*

The institution's first paid-in capital was not cash but **land**. The farms
Atatürk had founded on various dates and donated to the Treasury by a letter
of 11 June 1937 were entered into the capital account at a value set by a
commission.

The duties the law gave the corporation were broader than today's TİGEM. The
third article lists, besides running agricultural and industrial
establishments, the founding and management of **model and guiding** farm
centres, factories and workshops that would demonstrate and spread the crops
and methods suited to each region; **handling silo and warehouse business and
conducting warrant transactions in silos**; and forming or joining bodies
related to its field of work. Trade, transport and credit operations also
appear in the text.

Its governance was broad by the standards of the day. Under the eighth
article the corporation was overseen by a general assembly chaired by the
Prime Minister and composed of the Ministers of Finance, Economy and
Agriculture, three members each elected by the Budget, Court of Accounts,
Economy, Finance and Agriculture committees of the Grand National Assembly
from among their own members, and the presidents of the Council of State and
the Court of Accounts. Members of the board of management were required to
hold a professional higher education in agriculture, agricultural crafts or
land economics.

The most famous of those farms did not stay with the institution for long.
**Law 5659**, adopted on 24 March 1950, established an Atatürk Forest Farm
Directorate in Ankara with legal personality, attached to the Ministry of
Agriculture, with a capital of 7,500,000 lira. Nine months after the lineage
took its new name, its best-known farm left it.$dsr$, '{}'::text[], 'belge', $dsr${"url":"https://tarimportali.net/dosya/tigem/tigem_orman_ciftligi_1929a.jpg","atif":"Unknown authorUnknown author — kamu malı","kaynak":null,"alt_tr":"Mustafa Kemal, Ankara'daki örnek Orman Çiftliği'nde, 14 Temmuz 1929.","alt_en":"Mustafa Kemal at the model Forest Farm in Ankara, 14 July 1929."}$dsr$::jsonb),
  (5, $dsr$1949'da yazılan cümle$dsr$, $dsr$The sentence written in 1949$dsr$, $dsr$7 Haziran 1949'da kabul edilen **5433 sayılı Devlet Üretme Çiftlikleri Genel
Müdürlüğü Görev ve Kuruluş Kanunu**, iki damarı tek bir genel müdürlükte
topluyor. Tarım Bakanlığına bağlı, tüzel kişiliği haiz, katma bütçeli.

Birinci maddesi kurumun ne için var olduğunu söylüyor:

*"Yurt Çiftçiliğinin zirai verimini artırmak, istihsalini çeşitlendirmek ve
mahsulün kalitesini yükseltmek amacı ile iyi tohumluk, damızlık ve fidan
ihtiyacını sağlamak, tarım alanında çiftçiye örneklik ve öğreticilik etmek
üzere…"*

İkinci maddenin (c) bendi işin ticari yanını da yazıyor: *"Yüksek vasıflı
tohum, damızlık ve fidanları bedeli karşılığında çiftçiye dağıtmak."*
Bedava değil, bedelle.

Aynı maddenin öteki bentleri kurumun o yıllardaki iş tarifini genişletiyor.
Genel müdürlük yalnız tohum ve damızlık değil, **arıcılık ve kümes
hayvancılığı** ihtiyacını da karşılayacak; işletmelerinde elde edilen
mahsulleri kıymetlendirmek için ziraat sanatlarıyla uğraşacak; çevresindeki
çiftçilere **örneklik** edecek; öğretici nitelikte kurslar açıp yayın
yapacak. Merkez teşkilatı on daireden kuruluyor ve bunlardan biri doğrudan
"Ekonomi ve Dağıtma İşleri Müdürlüğü" adını taşıyor — dağıtım, kuruluş
şemasının içinde bir daire.

Dördüncü madde, satış fiyat ve şartlarına ilişkin esasları Yönetim
Komisyonunun karara bağlayacağını, belli tutarın üstündeki kararların ise
bakan onayıyla yürürlüğe gireceğini söylüyor. Fiyatın nerede belirlendiği
1949'da da bugünkü gibi kurulun masasındaydı.

Şimdi aynı cümlenin yetmiş üç yıl sonraki hâline bakmak gerekiyor.
2 Şubat 2022 tarihli Resmî Gazete'de yayımlanan TİGEM Ana Statüsü'nün
beşinci maddesi, kurumun faaliyet konularını sıralarken ilk sıraya şunu
koyuyor:

*"Ürettiği tohumluk, fidan, fide ve benzeri ürünler ile yetiştirdiği damızlık
hayvanlar ve spermalarını üreticilere intikal ettirmek."*

Arada bir üçüncü belge daha var. 28 Ekim 1983 tarihli 95 sayılı Kanun
Hükmünde Kararname'nin üçüncü maddesi, 2022 metninden tek kelimeyle
ayrılıyor:

*"…yetiştirdiği damızlık hayvan, tohum, fidan, fide ve benzerleriyle ürettiği
spermaları **yetiştiricilere** intikal ettirmek."*

1983'ün "yetiştiricileri", 2022'de "üreticiler" oldu. Gerisi aynı. Üç ayrı
rejim, üç ayrı kurum adı, yetmiş üç yıl — ve değişmeyen bir görev tanımı.$dsr$, $dsr$**Law 5433 on the Duties and Establishment of the General Directorate of State
Production Farms**, adopted on 7 June 1949, brought the two strands together
in a single directorate: attached to the Ministry of Agriculture, with legal
personality and an annexed budget.

Its first article states what the institution exists for:

*"In order to increase the agricultural yield of the country's farming, to
diversify its output and raise the quality of the crop, to supply the need for
good seed, breeding stock and saplings, and to set an example and instruct the
farmer in the field of agriculture…"*

Clause (c) of the second article sets out the commercial side as well: *"To
distribute high-quality seed, breeding stock and saplings to the farmer
against payment."* Not free, but for a price.

The other clauses of the same article widen the job description of those
years. The directorate was to meet the country's need not only for seed and
breeding stock but also for **beekeeping and poultry**; to engage in
agricultural crafts in order to add value to the produce of its enterprises;
to set an **example** to the farmers around it; to open instructive courses
and publish. The central organisation was built from ten departments, one of
which was named "Directorate of Economy and Distribution Affairs" — in the
founding chart, distribution is a department.

The fourth article states that the principles governing sales prices and
conditions would be decided by the Management Commission, and that decisions
above a certain amount would take effect with the minister's approval. Where
the price is set was a board's table in 1949, as it is today.

Now look at the same sentence seventy-three years later. The fifth article of
the TİGEM Charter, published in the Official Gazette of 2 February 2022,
places this first among the institution's fields of activity:

*"To pass to producers the seed, saplings, seedlings and similar products it
produces and the breeding animals and their semen that it raises."*

There is a third document in between. The third article of Decree-Law 95,
dated 28 October 1983, differs from the 2022 text by a single word:

*"…to pass to **breeders** the breeding animals, seed, saplings, seedlings and
the like that it raises and the semen that it produces."*

The "breeders" of 1983 became "producers" in 2022. The rest is the same. Three
different regimes, three different institutional names, seventy-three years —
and an unchanged definition of the job.$dsr$, '{}'::text[], 'belge', $dsr${"url":"https://tarimportali.net/dosya/tigem/tigem_bugday_tarla.jpg","atif":"Maurice Flesier — CC BY-SA 4.0","kaynak":null,"alt_tr":"Hasat öncesi buğday tarlası, Suşehri, Sivas, 21 Temmuz 2021.","alt_en":"A wheat field before harvest, Suşehri, Sivas, 21 July 2021."}$dsr$::jsonb),
  (6, $dsr$Kuruluş 1983, çerçeve 1984$dsr$, $dsr$Founded in 1983, framed in 1984$dsr$, $dsr$Kurumun kendi sayfası kuruluş yılı olarak 1984'ü veriyor. Birincil belge
başka bir tarih söylüyor ve ikisi de doğru; farklı şeyleri anlatıyorlar.

**28 Ekim 1983 tarihli, 18205 Mükerrer sayılı Resmî Gazete** bütün kamu
iktisadi teşebbüslerinin kuruluş kararnamelerini bir arada yayımladı.
Fihristin 95'inci sırasında "Tarım İşletmeleri Genel Müdürlüğü Kuruluşu
Hakkında Kanun Hükmünde Kararname" duruyor. İkinci maddesi açık: *"Bu Kanun
Hükmünde Kararname ile Tarım İşletmeleri Genel Müdürlüğü (TİGEM) adında,
tüzel kişiliğe sahip, faaliyetlerinde özerk ve sorumluluğu sermayesiyle
sınırlı bir Kamu İktisadi Kuruluşu kurulmuştur."* Merkez Ankara, sermaye
30 milyar lira, Bakanlar Kurulu kararı 10 Ekim 1983.

Aynı nüsha, bu dizinin başka kurumlarını da taşıyor. Fihristte 97'nci sırada
Türkiye Zirai Donatım Kurumu, 107'nci sırada Türkiye Cumhuriyeti Ziraat
Bankası, 113'üncü sırada Toprak Mahsulleri Ofisi var. Dört kurum, bir gün,
bir gazete.

1984'te olan şey kuruluş değil, **çerçeve değişikliği**. 8 Haziran 1984
tarihli 233 sayılı Kanun Hükmünde Kararname, kamu iktisadi teşebbüslerinin
rejimini yeniden kurdu ve TİGEM o kararnamenin ekli cetveline, "Tarım,
Orman ve Köyişleri Bakanlığı" başlığı altında **Kamu İktisadi Kuruluşu**
olarak yazıldı.

Üçüncü bir tarih daha var. 233 sayılı Kararnamenin TİGEM satırındaki dipnot
şunu söylüyor: *"24/11/1994 tarih ve 4046 sayılı Kanun'un 35 inci maddesi
ile İktisadi Devlet Teşekkülü (İDT) bölümüne eklenmiştir."* O madde
kararnamenin ekli cetvellerini topluca yeniden tespit etti; TİGEM 1994'te
Kamu İktisadi Kuruluşu olmaktan çıkıp İktisadi Devlet Teşekkülü oldu ve
bugün hâlâ öyle.

Kuruluş 1983, çerçeve 1984, statü 1994.

1983 tarihli kuruluş kararnamesi, kurumun ne üreteceğini de ilk maddelerinde
yazıyor ve listede bugünkü TİGEM'in bütün hatları var: damızlık hayvan,
tohum, fidan, fide, sperma. Buna ek olarak işletmelerden elde edilecek
ürünlerle birlikte **çiftçilerden alınacak ürünleri kıymetlendirmek için**
tesis kurmak, kurdurmak ya da kurulanlara iştirak etmek; bitkisel ve
hayvansal üretim, yetiştirme ve ıslah konularında araştırma yapmak; ve
Bakanlığın ıslah ve araştırma birimleriyle gerektiğinde işbirliğinde
bulunmak sayılıyor.

Kararnamenin on dördüncü maddesi bir ayrıntı taşıyor: kurum adına kayıt ve
tescil olunacak gayrimenkuller, tapulama ve kadastro işlemleri ve
**çiftçilerle ilişkilerinde düzenlenen sözleşme ve borç senetleri** her türlü
vergi, resim ve harçtan muaf. Çiftçiyle yapılan sözleşmenin damga vergisinden
muaf olması küçük bir hüküm gibi duruyor; tohumluk satışının dört kanaldan
yürüdüğü bir kurumda her yıl binlerce belgeye dokunuyor.$dsr$, $dsr$The institution's own page gives 1984 as its founding year. The primary
document gives a different date, and both are right; they describe different
things.

The **Official Gazette of 28 October 1983, issue 18205 Repeated** published
the founding decrees of all state economic enterprises together. At number 95
in its index stands the "Decree-Law on the Establishment of the General
Directorate of Agricultural Enterprises". Its second article is explicit:
*"By this Decree-Law a Public Economic Establishment named the General
Directorate of Agricultural Enterprises (TİGEM) has been founded, with legal
personality, autonomous in its activities and with liability limited to its
capital."* Headquarters Ankara, capital 30 billion lira, Council of Ministers
decision of 10 October 1983.

The same issue carries other institutions in this series. At number 97 in the
index is the Turkish Agricultural Supply Organisation, at 107 the Agricultural
Bank of the Republic of Türkiye, at 113 the Turkish Grain Board. Four
institutions, one day, one gazette.

What happened in 1984 was not a founding but a **change of framework**.
Decree-Law 233 of 8 June 1984 reset the regime for state economic enterprises,
and TİGEM was written into its schedule as a **Public Economic Establishment**
under the heading "Ministry of Agriculture, Forestry and Rural Affairs".

There is a third date. The footnote on TİGEM's line in Decree-Law 233 reads:
*"Added to the State Economic Enterprise section by article 35 of Law 4046
dated 24 November 1994."* That article reset the decree's schedules as a
whole; in 1994 TİGEM ceased to be a Public Economic Establishment and became a
State Economic Enterprise, which it remains.

Founded in 1983, framed in 1984, reclassified in 1994.

The 1983 founding decree also writes out what the institution would produce,
and the list contains every line of today's TİGEM: breeding animals, seed,
saplings, seedlings, semen. To these it adds establishing, having established
or joining facilities **to add value to produce bought from farmers** along
with the output of its own enterprises; conducting research on crop and animal
production, raising and improvement; and cooperating where necessary with the
ministry's improvement and research units.

The decree's fourteenth article carries a detail: immovables registered in the
institution's name, cadastral operations, and **contracts and promissory notes
drawn up in its dealings with farmers** are exempt from every kind of tax,
duty and fee. A farmer's contract being exempt from stamp duty looks like a
small provision; in an institution whose seed sales run through four channels
it touches thousands of documents a year.$dsr$, array['silsile']::text[], 'belge', $dsr${"url":"https://tarimportali.net/dosya/tigem/tigem_resmi_gazete.jpg","atif":"Turkish government — kamu malı","kaynak":null,"alt_tr":"Resmî Gazete, 20 Nisan 1946, sayı 6288. TİGEM'i kuran 95 sayılı kararname bu nüshada değil: 28 Ekim 1983 tarihli 18205 Mükerrer sayıda yayımlandı.","alt_en":"The Official Gazette, 20 April 1946, issue 6288. Decree 95, which established TİGEM, is not in this issue: it appeared in 18205 Repeated, 28 October 1983."}$dsr$::jsonb),
  (7, $dsr$Toprak 1990'da tapuya geçti$dsr$, $dsr$The land entered the register in 1990$dsr$, $dsr$Kurum 1983'te kuruldu ama kullandığı toprağın tapusu altı yıl daha kendi
adına geçmedi. Bunu çözen kanunun adı meselenin kendisi:
**Tarım İşletmeleri Genel Müdürlüğü Adına Tescil Edilecek Taşınmaz Mallar
Hakkında Kanun**, 16 Mayıs 1990, numarası 3646.

Birinci madde tescil edilecek taşınmazları üç bent hâlinde sayıyor: mülga
5433 sayılı Kanunla Devlet Üretme Çiftlikleri Genel Müdürlüğüne intikal
edenler; Hazineye ait olup hara ve inekhanelere tahsisliler; ve bu
kuruluşların tasarrufundaki öteki Hazine taşınmazları. Dördüncü madde
tescili yapılan taşınmazların **sermayeye ilave** edilmesini Yüksek Planlama
Kurulunun kararına bağlıyor, altıncı madde işlemleri her türlü vergi, resim
ve harçtan muaf tutuyor.

Beşinci maddeye 2001'de eklenen bir fıkra, kanunun dışında kalanları
sayıyor: Bandırma-Marmara Hayvancılık, Lalahan Hayvancılık Merkez ve
Yerköy Tiftik Keçisi Araştırma Enstitüleri ile Konya/Ereğli Koyunculuk
Üretme İstasyonu. Araştırma enstitüleri TİGEM'e geçmedi.

Bugün o toprağın dökümü şöyle. 25 Temmuz 2023 tarihli arazi varlığı tablosu,
faaliyette olan 17 işletme ile Genel Müdürlük yerleşkesi için 3.275.564
dekar gösteriyor. Uzun süreli kiraya verilen işletmelerde 238.203 dekar,
iştirak şeklinde kullanılanlarda 88.688 dekar daha var. Toplam
**3.602.455 dekar**.

Bu toplamın içinde tek bir işletme fark yaratıyor: Şanlıurfa'daki
**Ceylanpınar**, 1.633.157 dekarla TİGEM arazisinin yüzde 45,3'ü.
Faaliyetteki 17 işletmenin arazisine oranlandığında yüzde 49,9 — tam yarısı.
Sıralamada onu 310.259 dekarla Konya'daki Altınova ve 288.298 dekarla yine
Konya'daki Gözlü izliyor.

Listenin devamı da aynı ölçek farkını sürdürüyor: Kırşehir'deki Malya
218.829, Ankara'daki Polatlı 211.335, Karaman'daki Kazım Karabekir 186.994,
Bursa'daki Karacabey 89.002 ve Sivas'taki Ulaş 71.463 dekar. Geriye kalan
dokuz işletmenin arazisi toplam 264.455 dekar — yani tek başına Altınova'dan
az.

Bu dağılım kurumun coğrafyasını da anlatıyor. Ağırlık Güneydoğu Anadolu'da
ve İç Anadolu'da; ilk sekiz işletmenin altısı bu iki bölgede. Kurumun
2022 tarihli sektör raporu, TİGEM buğday ekilişinin yüzde 62'sinin
Ceylanpınar İşletmesinde olduğunu ve Orta Anadolu'daki sekiz işletmenin
arazi varlığının yüzde 35'ini oluşturduğunu bildiriyor.$dsr$, $dsr$The institution was founded in 1983, but the title to the land it used did not
pass into its own name for another six years. The law that settled it is named
after the problem itself: the **Law on Immovable Property to be Registered in
the Name of the General Directorate of Agricultural Enterprises**, 16 May
1990, number 3646.

The first article lists the property to be registered in three clauses: that
which passed to the General Directorate of State Production Farms under the
repealed Law 5433; Treasury property allocated to the studs and cattle farms;
and other Treasury property held by those bodies. The fourth article makes the
**addition to capital** of registered property subject to a decision of the
Supreme Planning Council, and the sixth exempts the operations from every tax,
duty and fee.

A paragraph added to the fifth article in 2001 lists what falls outside the
law: the Bandırma-Marmara Livestock, Lalahan Central Livestock and Yerköy
Mohair Goat Research Institutes and the Konya/Ereğli Sheep Breeding Station.
The research institutes did not pass to TİGEM.

Today the land breaks down as follows. The land inventory of 25 July 2023
shows 3,275,564 decares for the 17 operating enterprises together with the
headquarters campus. There are a further 238,203 decares in enterprises leased
out long-term and 88,688 decares in those used through participation. The
total is **3,602,455 decares**.

Within that total a single enterprise makes the difference: **Ceylanpınar** in
Şanlıurfa, at 1,633,157 decares, is 45.3 per cent of TİGEM's land. Measured
against the land of the 17 operating enterprises it is 49.9 per cent — exactly
half. Next in the ranking are Altınova in Konya at 310,259 decares and Gözlü,
also in Konya, at 288,298.

The rest of the list keeps the same difference of scale: Malya in Kırşehir
218,829, Polatlı in Ankara 211,335, Kazım Karabekir in Karaman 186,994,
Karacabey in Bursa 89,002 and Ulaş in Sivas 71,463 decares. The remaining nine
enterprises hold 264,455 decares between them — less than Altınova alone.

This distribution also describes the institution's geography. The weight lies
in South-eastern and Central Anatolia; six of the first eight enterprises are
in those two regions. The institution's 2022 sector report states that 62 per
cent of TİGEM's wheat sowing is at the Ceylanpınar enterprise and that the
eight enterprises of Central Anatolia make up 35 per cent of its land.$dsr$, array['isletme_arazileri']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/tigem/tigem_ceylan.jpg","atif":"Dûrzan Cîrano — CC BY-SA 4.0","kaynak":null,"alt_tr":"Ceylanpınar'da bir Asya ceylanı, 6 Nisan 2018. İlçe adını bu hayvandan alıyor.","alt_en":"An Asian gazelle at Ceylanpınar, 6 April 2018. The district takes its name from the animal."}$dsr$::jsonb),
  (8, $dsr$Türkiye'nin yüzde birinden azı$dsr$, $dsr$Less than one per cent of Türkiye$dsr$, $dsr$3,6 milyon dekar büyük bir rakam gibi duruyor. Ülke ölçeğine konduğunda
değil.

Dünya Bankası'nın 2024 verisine göre Türkiye'nin tarım arazisi
386.400 kilometrekare. TİGEM'in 3.602.455 dekarı 3.602 kilometrekare eder.
Oran **yüzde 0,93**.

Kurumun ülke tarımındaki ağırlığı, tuttuğu topraktan gelmiyor. Nereden
geldiğini anlamak için arazinin ne işe yaradığına bakmak gerekiyor.
Faaliyetteki 17 işletmenin arazisi şöyle dağılıyor:

| kullanım | dekar |
|---|---:|
| Tarla arazisi | 1.756.580 |
| Tabii mera | 629.138 |
| Kültürdışı arazi | 485.388 |
| Yem bitkileri | 278.520 |
| Bahçe arazisi | 124.165 |

Tarla arazisi toplamın yarısından fazla, tabii mera ise beşte bire yakın.
İkisi birlikte kurumun iki ürün hattını açıklıyor: tarla tohumluk üretir,
mera damızlık hayvanı besler.

Bir de sulama var. Aynı tabloya göre faaliyetteki işletmelerde sulanan arazi
940.568 dekar; kurumun 2024–2028 Stratejik Planı 2023 için 994.798 dekarlık
bir sulu tarım arazisi varlığı bildiriyor. İki rakam aynı şeyi ölçmüyor —
biri sulanan, öteki sulanabilir arazi — ve bu yüzden birbirinin yerine
kullanılamaz.

Sulama oranı kurumu ülke ortalamasından ayıran yerlerden biri. Faaliyetteki
işletmelerin kültüraltı arazisinin yüzde 33,7'si sulanıyor; Dünya Bankası'nın
2024 verisine göre Türkiye'de tarım arazisinin yüzde 12,7'si sulanabilir
durumda. İki oranın **paydası farklı** — biri kültüraltı arazi, öteki bütün
tarım arazisi — ve bu yüzden aradaki fark bire bir bir üstünlük ölçüsü
değildir. Yine de yönü açık: kurum arazisinin suya erişimi ülke ortalamasının
üstünde ve bu, sertifikalı tohum üretiminin kuraklığa karşı güvence altına
alınmasıyla ilgili bir tercih.

Kurumun kendi bildirimine göre son yıllardaki yatırımlarla 995 bin dekar
arazi sulamaya açıldı ve 2019–2023 stratejik planının sulu tarım arazisini
942.500 dekardan 1.090.500 dekara çıkarma hedefi yüzde 92 oranında
gerçekleşti.

Kurumun ölçeği küçük, işlevi dar. Bir sonraki bölüm o dar işlevin ne kadar
büyük olduğunu gösteriyor.$dsr$, $dsr$3.6 million decares sounds like a large figure. Set against the country, it is
not.

According to World Bank data for 2024, Türkiye's agricultural land is 386,400
square kilometres. TİGEM's 3,602,455 decares come to 3,602 square kilometres.
The share is **0.93 per cent**.

The institution's weight in the country's agriculture does not come from the
land it holds. To see where it does come from, look at what the land is used
for. The land of the 17 operating enterprises divides like this:

| use | decares |
|---|---:|
| Field crops | 1,756,580 |
| Natural pasture | 629,138 |
| Non-arable land | 485,388 |
| Forage crops | 278,520 |
| Orchards and gardens | 124,165 |

Field land is more than half the total and natural pasture close to a fifth.
Together they explain the institution's two product lines: fields grow seed,
pasture feeds breeding animals.

There is also irrigation. The same table gives 940,568 decares of irrigated
land at the operating enterprises, while the institution's 2024–2028 Strategic
Plan reports 994,798 decares of irrigable farmland for 2023. The two figures
do not measure the same thing — one is irrigated, the other irrigable — and
cannot stand in for one another.

The irrigation ratio is one of the things that sets the institution apart from
the national average. 33.7 per cent of the cultivated land of the operating
enterprises is irrigated; according to World Bank data for 2024, 12.7 per cent
of Türkiye's agricultural land is irrigable. The two ratios have **different
denominators** — one cultivated land, the other all farmland — so the gap
between them is not a one-to-one measure of advantage. The direction is clear
all the same: the institution's land has above-average access to water, and
that is a choice bound up with securing certified seed production against
drought.

By the institution's own account, investment in recent years has brought
995,000 decares under irrigation, and the 2019–2023 strategic plan's target of
raising irrigated farmland from 942,500 to 1,090,500 decares was met to 92 per
cent.

The institution's scale is small and its function narrow. The next section
shows how large that narrow function is.$dsr$, array['arazi_kullanimi']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/tigem/tigem_harran_kanal.jpg","atif":"Volker Höhfeld — CC BY-SA 4.0","kaynak":null,"alt_tr":"Harran Ovası'nda ikincil sulama kanalı, Şanlıurfa ile Altınbaşak arası, 11 Eylül 2011.","alt_en":"A secondary irrigation canal on the Harran Plain, between Şanlıurfa and Altınbaşak, 11 September 2011."}$dsr$::jsonb),
  (9, $dsr$Ülkenin tohumu: doksandan yirmiye$dsr$, $dsr$The country's seed: from ninety to twenty$dsr$, $dsr$2002 yılında Türkiye'de 80.089 ton buğday ve 4.127 ton arpa sertifikalı
tohumu dağıtıldı. Toplam 84.216 ton. Aynı yıl TİGEM 72.059 ton buğday ve
3.753 ton arpa tohumu dağıttı: 75.812 ton.

Yani 2002'de ülkede dağıtılan sertifikalı hububat tohumunun **yüzde 90'ı**
tek bir kurumdan geliyordu.

| ton | 2002 | 2010 | 2015 | 2020 | 2021 | 2022 |
|---|---:|---:|---:|---:|---:|---:|
| Türkiye | 84.216 | 294.586 | 608.751 | 706.892 | 629.319 | 613.206 |
| TİGEM | 75.812 | 173.720 | 142.867 | 155.948 | 117.799 | 122.045 |
| TİGEM'in payı | %90,0 | %59,0 | %23,5 | %22,1 | %18,7 | %19,9 |

Pay düştü. Ama kurum küçülmedi.

Yirmi yılda Türkiye'nin sertifikalı hububat tohumu dağıtımı 84.216 tondan
613.206 tona, yani **7,28 kat** arttı. TİGEM'inki aynı dönemde 75.812 tondan
122.045 tona, **1,61 kat** çıktı. Kurum büyüdü; ülke çok daha hızlı büyüdü.

Sebebi, kurumun kendi sektör raporunda yazılı: payın düşmesi *"özel sektör
firmalarının da sertifikalı hububat tohumu üretimi alanında hızlı bir
şekilde geliştiğini net olarak göstermektedir."*

Bir ayrıntı: bu seri **dağıtımı** ölçüyor ve TİGEM satırı kurumun kendi
tarlalarına ektiği tohumu da içeriyor. Yalnızca çiftçiye yapılan **satış**
sayıldığında rakam farklı; kurum 2022'de 79.561 ton buğday tohumu, 2023'te
toplam 113 bin ton sertifikalı hububat tohumu satışı bildiriyor. İki ölçü
birbirinin yerine kullanılamaz.

Pay buğdayda ve arpada aynı seyretmedi. 2002'de TİGEM ülkede dağıtılan
buğday tohumunun yüzde 90'ını, arpa tohumunun yüzde 91'ini karşılıyordu.
2022'de buğdaydaki payı yüzde 23,5, arpadaki payı yüzde 10,5. Arpada düşüş
daha sert; aynı yirmi yılda ülkenin arpa tohumu dağıtımı 4.127 tondan
169.228 tona, yani kırk katının üstüne çıktı.

2004'te alınan üç tedbir bu tablonun bir yanını açıklıyor: tohum fiyatlarının
makul düzeyde tutulması, çiftçiye yönelik tanıtım, ve bayilik sisteminin
devreye girmesi. Kurum aynı dönemde tohum hazırlama kapasitesini saatte
341 tona çıkardı; otomatik paketleme, barkodlama, paletleme ve forkliftle
istifleme sistemlerini kurdu.

Bu rakamların hepsi hububatla ilgili. Kurum ayrıca tritikale, yulaf, yem
bitkileri, yağlı tohumlar ve baklagil tohumluğu da üretiyor; 2022'de
2.244 ton tritikale tohumu sattı. Hububat dışındaki türlerde ülke payı bu
dosyada ölçülmedi.$dsr$, $dsr$In 2002, 80,089 tonnes of certified wheat seed and 4,127 tonnes of certified
barley seed were distributed in Türkiye — 84,216 tonnes in all. That same year
TİGEM distributed 72,059 tonnes of wheat seed and 3,753 tonnes of barley seed:
75,812 tonnes.

In other words, **90 per cent** of the certified cereal seed distributed in
the country in 2002 came from a single institution.

| tonnes | 2002 | 2010 | 2015 | 2020 | 2021 | 2022 |
|---|---:|---:|---:|---:|---:|---:|
| Türkiye | 84,216 | 294,586 | 608,751 | 706,892 | 629,319 | 613,206 |
| TİGEM | 75,812 | 173,720 | 142,867 | 155,948 | 117,799 | 122,045 |
| TİGEM's share | 90.0% | 59.0% | 23.5% | 22.1% | 18.7% | 19.9% |

The share fell. But the institution did not shrink.

Over twenty years Türkiye's distribution of certified cereal seed rose from
84,216 to 613,206 tonnes — **7.28 times**. TİGEM's rose over the same period
from 75,812 to 122,045 tonnes, **1.61 times**. The institution grew; the
country grew far faster.

The reason is set out in the institution's own sector report: the fall in the
share *"clearly shows that private sector firms have also developed rapidly in
the field of certified cereal seed production."*

The share did not move the same way in wheat and barley. In 2002 TİGEM
supplied 90 per cent of the wheat seed and 91 per cent of the barley seed
distributed in the country. In 2022 its share was 23.5 per cent in wheat and
10.5 per cent in barley. The fall was sharper in barley; over the same twenty
years the country's barley seed distribution rose from 4,127 to 169,228
tonnes, more than fortyfold.

One detail: this series measures **distribution**, and the TİGEM line includes
the seed the institution sowed on its own fields. Counting only **sales** to
farmers gives a different figure; the institution reports 79,561 tonnes of
wheat seed sold in 2022 and 113,000 tonnes of certified cereal seed in total
in 2023. The two measures cannot stand in for one another.

Three measures taken in 2004 explain one side of this picture: keeping seed
prices at a reasonable level, promotion aimed at farmers, and the introduction
of the dealer system. Over the same period the institution raised its seed
processing capacity to 341 tonnes per hour and installed automatic packing,
barcoding, palletising and forklift stacking systems.

All these figures concern cereals. The institution also produces triticale,
oat, forage, oilseed and pulse seed; it sold 2,244 tonnes of triticale seed in
2022. Its national share in species other than cereals was not measured in
this dossier.$dsr$, array['tohum_dagitimi', 'tigem_payi']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/tigem/tigem_harran_hasat_1988.jpg","atif":"Volker Höhfeld — CC BY-SA 4.0","kaynak":null,"alt_tr":"Harran Ovası'nda tırpanla hububat hasadı, 15 Haziran 1988. Kaynak künyesi 1980'lerin sonunda ovada hasadın yer yer hâlâ tırpanla yapıldığını kaydediyor.","alt_en":"Cutting grain with a scythe on the Harran Plain, 15 June 1988. The source records that in the late 1980s grain there was still sometimes harvested by scythe."}$dsr$::jsonb),
  (10, $dsr$Çiftçi tohumu nasıl alıyor$dsr$, $dsr$How the farmer buys the seed$dsr$, $dsr$TİGEM'in ürettiği tohumluğun çiftçiye ulaşmasının dört yolu var ve dördü de
kurumun Tohumluk Satış ve Dağıtım Yönergesinde yazılı.

**Birincisi doğrudan.** Çiftçi Genel Müdürlüğe ya da bir işletmeye yazılı
başvurur; satış, Yönetim Kurulunun belirlediği peşin satış fiyatı üzerinden
yapılır. Fiyatlar her yıl **Haziran–Ağustos** arasında Yönetim Kurulunca
açıklanır.

**İkincisi bayi.** TİGEM bayisi olabilmek için Bakanlıktan Tohumluk Bayi
Belgesi almış olmak ve Bakanlığın yıllık denetiminden olumlu rapor almak
gerekiyor. Sözleşme bir yıllık ve taraflar en az bir ay önce yazılı
bildirmezse kendiliğinden uzuyor. Bayi yalnız başvurusunda bildirdiği il
sınırları içinde satış yapabiliyor. 2003–2023 arasında ülke genelinde
303 bayi kuruldu.

**Üçüncüsü il müdürlükleri**, dördüncüsü **dağıtıcı kuruluşlar**: yönerge
bunları adıyla sayıyor, Tarım Kredi Kooperatifleri ve Pankobirlik.

Bayinin izlediği yol adım adım ve süreli. Bayi ön talebini Bayi Otomasyon
Sistemi üzerinden iletir. TİGEM kotayı ve ön talepleri gözeterek bir ön
tahsis bildirir. Bayi **5 iş günü** içinde tahsis edilen tohumluk bedelinin
**yüzde 10'unu** peşin yatırırsa ön tahsis kesin tahsise döner; yatırmazsa
sistem tahsisi otomatik olarak iptal eder. Kesin tahsise çevrilen tohumluk
**20 takvim günü** içinde ilgili işletmeden teslim alınır. Ödeme nakit ya da
banka teminat mektubuyla yapılır, sevkiyat randevuyla gerçekleşir.
Tohumluğun araca yüklenmesi işletmenin, nakliyesi bayinin işidir.

Bir de şu: kesin tahsise çevrilen tohumluk iptal edilmiyor, ama teslim
alınmazsa yatırılan yüzde 10'luk peşinat bir sonraki satış sezonunda ödeme
olarak kullandırılıyor. Sertifika raporunun gecikmesi yüzünden teslim
alınamayan tohumluk için kurum ek süre veriyor; işletmede kamyon tonajı
aşıldığı için alınamayan miktar ise iptal edilip bedeli iade ediliyor.

Bayilik verilip verilmeyeceğine kurum karar veriyor ve ölçütlerini yönerge
sayıyor: il ya da ilçenin ekilebilir arazi miktarı, çiftçi kayıt sistemine
kayıtlı çiftçi sayısı, hububat üretim kapasitesi. Kurum uygun gördüğü
başvurular için yerinde inceleme yaptırıyor; büroyu, satış deposunu ve
tohum satış potansiyelini görevlendirdiği personele inceletiyor.

Yönergenin bir maddesi de kimlerin başvuramayacağını sayıyor: TİGEM'in bütün
personeli; daha önce taahhüdünü yerine getirmediği için bayilik sözleşmesi
feshedilenler; ve bayilik işlerini hazırlamak, yürütmek, sonuçlandırmak ya da
denetlemekle görevli olanlarla bunların eşleri, ikinci dereceye kadar kan ve
sıhrî hısımları ve ortakları.$dsr$, $dsr$There are four ways the seed TİGEM produces reaches the farmer, and all four
are written into the institution's Seed Sales and Distribution Directive.

**The first is direct.** The farmer applies in writing to the General
Directorate or to an enterprise; the sale is made at the cash price set by the
Board. Prices are announced by the Board each year between **June and
August**.

**The second is the dealer.** To become a TİGEM dealer one must hold a Seed
Dealer Certificate from the ministry and receive a favourable report in the
ministry's annual inspection. The contract runs for one year and renews itself
unless either side gives written notice at least a month in advance. A dealer
may sell only within the province named in its application. Between 2003 and
2023, 303 dealers were established across the country.

**The third is the provincial directorates**; the fourth, the **distributing
organisations**, which the directive names: the Agricultural Credit
Cooperatives and Pankobirlik.

The route a dealer follows is set out step by step, with deadlines. The dealer
submits a preliminary request through the Dealer Automation System. TİGEM
notifies a preliminary allocation, taking quota and requests into account. If
the dealer pays **10 per cent** of the price of the allocated seed within
**5 working days**, the preliminary allocation becomes final; if not, the
system cancels it automatically. Seed confirmed as a final allocation is
collected from the relevant enterprise within **20 calendar days**. Payment is
made in cash or by bank letter of guarantee, and dispatch takes place by
appointment. Loading the seed onto the vehicle is the enterprise's duty;
haulage is the dealer's.

One more thing: seed confirmed as a final allocation is not cancelled, but if
it is not collected the 10 per cent deposit paid is credited against payment
in the following sales season. Where seed cannot be collected because of a
delay in the certification report, the institution grants extra time; where a
quantity cannot be taken because a lorry's tonnage is exceeded, it is
cancelled and the price refunded.

The institution decides whether to grant a dealership, and the directive lists
its criteria: the arable area of the province or district, the number of
farmers registered in the farmer registration system, and cereal production
capacity. For applications it considers suitable, the institution has an
inspection carried out on site; the office, the sales depot and the seed sales
potential are examined by assigned staff.

One article of the directive lists who may not apply: all TİGEM personnel;
those whose dealership contract was terminated for failing to meet their
undertakings; and those charged with preparing, conducting, concluding or
auditing dealership business, together with their spouses, blood and marriage
relatives to the second degree, and their partners.$dsr$, array['tohum_yolu', 'dagitim_kanallari']::text[], 'akis', $dsr${"url":"https://tarimportali.net/dosya/tigem/tigem_bugday_sivas.jpg","atif":"Maurice Flesier — CC BY-SA 4.0","kaynak":null,"alt_tr":"Hasat öncesi buğday tarlası, Suşehri, Sivas, 18 Temmuz 2021.","alt_en":"A wheat field before harvest, Suşehri, Sivas, 18 July 2021."}$dsr$::jsonb),
  (11, $dsr$İşletmelerin yarısı, arazinin onda biri$dsr$, $dsr$Half the enterprises, a tenth of the land$dsr$, $dsr$TİGEM'in 34 tarım işletmesinden 17'si kurumun kendi işlettiği, 17'si kiraya
verilmiş durumda. İki ayrı işletme de iştirak modeliyle kullanılıyor.

Sayıya bakıldığında tam yarısı. Araziye bakıldığında tablo değişiyor.

| | işletme | arazi |
|---|---:|---:|
| TİGEM'in kullanımında | %50,0 | %90,93 |
| Kiraya verilmiş | %50,0 | %9,07 |

Kiraya verilen 17 işletme ile iştirakler toplam 326.891 dekar tutuyor;
TİGEM'in 3.602.455 dekarlık arazisinin **yüzde 9,07'si**. Bu oranı kurumun
kendi arazi varlığı tablosu yazıyor. Kiraya verilenler küçük işletmeler.

Kiralamanın kendi yönergesi var ve karar zinciri kurumun içinde bitmiyor.
Strateji Geliştirme Dairesi Başkanlığı teknik, malî ve ekonomik analizlerle
bir rapor hazırlayıp Yönetim Kuruluna sunar. Yönetim Kurulu raporu inceler
ve karar verir. İnşaat ve Emlak Dairesi Başkanlığı, şartname ve sözleşmelerle
birlikte işletme adlarını **Cumhurbaşkanlığına** sunar; süreyi ve şartları
Cumhurbaşkanlığı kararı belirler. Ardından en az üç kişilik bir Kira Tespit
Komisyonu işletmenin bulunduğu yerde çalışır, **30 gün** içinde yıllık kira
bedelini tespit eder ve kararını oybirliğiyle verir; çekimser kalınamaz.
Son adım ihale ve Yönetim Kurulu onayıdır.

Kiralama yalnız işletme ölçeğinde değil. Kurum, sertifikalı tohum üretim
alanlarının bir bölümünü özel sektör firmalarına kiraya veriyor: 2020'de
96 bin dekar, 2021'de 102 bin dekar, 2022'de 133 bin dekar, 2023'te
111 bin dekar. Bu arazilerde patates, hibrit mısır, ayçiçeği, sebze ve yem
bitkileri tohumu üretiliyor; yani kurum kendi üretmediği türlerde arazisini
ve sulama altyapısını başkalarının üretimine açıyor.

Ana Statü de kiralamayı yetki olarak sayıyor ama iki ayrı bağlamda. Beşinci
maddenin (f) bendi, üretim, işleme ve pazarlama faaliyetlerinde bulunmak ve
tesis kurmak üzere gerçek ve tüzel kişilerden **yer kiralamayı ve kiraya
vermeyi** sayıyor. (g) bendi ise zaman içinde fonksiyonunu yitirmiş kümes,
ahır, depo ve sundurma gibi binaların yıpranmaya terk edilmemesi ve ekonomiye
kazandırılması için, işletme bütünlüğüne zarar vermemek kaydıyla kiraya
verilmesini düzenliyor.

İşletmenin tamamının uzun süreli kiralanması ise bu iki bentten değil, ayrı
bir yönergeden yürüyor ve o yönerge dayanağını 233 sayılı Kanun Hükmünde
Kararname, Ana Statü, 641 sayılı Kanun Hükmünde Kararname ve Yönetim Kurulu
kararları olarak gösteriyor.$dsr$, $dsr$Of TİGEM's 34 agricultural enterprises, 17 are run by the institution itself
and 17 are leased out. Two further enterprises are used through a
participation model.

By number, exactly half. By land, the picture changes.

| | enterprises | land |
|---|---:|---:|
| Run by TİGEM | 50.0% | 90.93% |
| Leased out | 50.0% | 9.07% |

The 17 leased enterprises and the participations come to 326,891 decares
together — **9.07 per cent** of TİGEM's 3,602,455 decares. That ratio is
printed in the institution's own land inventory. The ones leased out are the
small ones.

Leasing has a directive of its own, and the chain of decision does not end
inside the institution. The Strategy Development Department prepares a report
with technical, financial and economic analyses and submits it to the Board.
The Board examines the report and decides. The Construction and Real Estate
Department submits the names of the enterprises, together with specifications
and contracts, to the **Presidency**; the term and the conditions are set by
a Presidential decision. A Rent Assessment Commission of at least three
members then works at the site of the enterprise, determines the annual rent
within **30 days** and decides unanimously; no member may abstain. The final
steps are the tender and the Board's approval.

Leasing is not only at the scale of whole enterprises. The institution leases
part of its certified seed production land to private firms: 96,000 decares in
2020, 102,000 in 2021, 133,000 in 2022 and 111,000 in 2023. Potato, hybrid
maize, sunflower, vegetable and forage seed are produced on this land — that
is, the institution opens its land and its irrigation infrastructure to others
for species it does not produce itself.

The Charter counts leasing as a power as well, but in two separate contexts.
Clause (f) of the fifth article covers **renting and letting places** from and
to natural and legal persons in order to carry out production, processing and
marketing and to build facilities. Clause (g) covers letting out coops,
barns, stores and sheds that have lost their function over time, so that they
are not left to decay and are returned to the economy, provided the integrity
of the enterprise is not harmed.

The long-term leasing of a whole enterprise runs not from these two clauses
but from a separate directive, which cites as its basis Decree-Law 233, the
Charter, Decree-Law 641 and decisions of the Board.$dsr$, array['kira_asimetrisi']::text[], 'belge', $dsr${"url":"https://tarimportali.net/dosya/tigem/tigem_harran_pamuk.jpg","atif":"Volker Höhfeld — CC BY-SA 4.0","kaynak":null,"alt_tr":"Sulanan tarlada pamuk bitkisi, Harran Ovası, 20 Eylül 2012.","alt_en":"A cotton plant on an irrigated field, Harran Plain, 20 September 2012."}$dsr$::jsonb),
  (12, $dsr$Tohumdan başkasını da koruyor$dsr$, $dsr$It keeps more than seed alive$dsr$, $dsr$Bir devlet çiftliği işletmesinin koruma listesinde beklenmeyecek adlar var.

**Yerel tohumlar.** Kurum, kaybolmakta olan yerel çeşitleri — "Ata
tohumları" — topluyor, çoğaltıyor ve tescil ettiriyor. 2019–2023 dönemi
stratejik planı 1.027 çeşitte bu çalışmayı hedef olarak koymuştu.
Listedeki her çeşidin kendi künyesi var; örneğin Şahnalı Acı Biber,
kayıt numarası TGM18335.

**Damızlık hayvan.** 14 işletmede 6 ırkla damızlık sığır, 10 işletmede
10 ırkla damızlık koyun yetiştiriliyor. Koyun ırklarının beşi yerli, beşi
TİGEM'in kendi ıslah çalışmalarıyla elde edilmiş melez. 2002'de 17 bin baş
olan damızlık sığır varlığı 2023'te 27 bin başa, 71 bin baş olan damızlık
koyun varlığı 284 bin başa çıktı. Son yirmi yılda 73 bin baş damızlık sığır
ve 273 bin baş damızlık koyun satıldı.

Sperma satışı aynı dönemde iki katından fazla arttı:

| doz | 2018 | 2020 | 2021 | 2022 | 2023 |
|---|---:|---:|---:|---:|---:|
| Boğa sperması | 460.000 | 658.000 | 874.000 | 945.000 | 1.019.000 |

**Ve ötekiler.** Kurum Safkan Arap Atının, Ankara Tiftik Keçisinin, Kangal
Köpeğinin ve Asya Ceylanının korunduğu yerlerden biri. Ceylanpınar
İşletmesinde 2013'ten beri 1.000 ana baş kapasiteyle Halep ırkı keçi
yetiştiriliyor; işletmelerde 5.000 kovanlık arıcılık yapılıyor.

Yerel tohum çalışması tek başına yürümüyor. Kurum, tarımsal araştırma
teşkilatıyla ortak bir "yerli ve millî sebze tohumları" çalışması yürüttü;
2019–2023 planında yer alan yerli sebze tohumculuğunun geliştirilmesi
projesi, talep ve satış durumu gözetilerek 2021 sonunda tamamlandı ve hedefe
yüzde 86 oranında ulaşıldı. Aynı dönemde kurumun tescilli bitki çeşidi sayısı
7'den 12'ye çıkarıldı ve kuraklığa toleranslı hububat çeşidi sayısını
artırma hedefi tam olarak gerçekleşti.

Koyunculukta da ıslah çalışması sürüyor. Konya'daki Gözlü İşletmesinde
2012'de başlatılan çalışma, Akkaraman ırkı koyunun verim düzeyi yüksek yerli
ırklarla melezlenmesini ve süt, döl ve et randımanı yüksek yeni saf ırklar
elde edilmesini hedefliyor.

Şanlıurfa'nın Ceylanpınar ilçesi adını o ceylandan alıyor.$dsr$, $dsr$The conservation list of a state farming enterprise holds names one would not
expect.

**Local seed.** The institution collects, propagates and registers
disappearing local varieties — "ancestral seed". Its 2019–2023 strategic plan
set this work as a target across 1,027 varieties. Each variety on the list has
its own record; the Şahnalı hot pepper, for instance, is registered as
TGM18335.

**Breeding animals.** Breeding cattle of 6 breeds are raised at 14
enterprises and breeding sheep of 10 breeds at 10. Five of the sheep breeds
are native and five are crosses obtained through TİGEM's own improvement work.
The stock of breeding cattle rose from 17,000 head in 2002 to 27,000 in 2023,
and breeding sheep from 71,000 to 284,000. Over the past twenty years 73,000
head of breeding cattle and 273,000 head of breeding sheep were sold.

Semen sales more than doubled over the same period:

| doses | 2018 | 2020 | 2021 | 2022 | 2023 |
|---|---:|---:|---:|---:|---:|
| Bull semen | 460,000 | 658,000 | 874,000 | 945,000 | 1,019,000 |

**And the others.** The institution is one of the places where the Purebred
Arabian horse, the Angora goat, the Kangal dog and the Asian gazelle are kept.
Aleppo goats have been raised at the Ceylanpınar enterprise since 2013 with a
capacity of 1,000 breeding females; beekeeping is carried out at the
enterprises with 5,000 hives.

The work on local seed does not run alone. The institution carried out a joint
"native and national vegetable seed" programme with the agricultural research
organisation; the project in the 2019–2023 plan for developing native
vegetable seed was completed at the end of 2021 in the light of demand and
sales, reaching 86 per cent of its target. Over the same period the number of
registered plant varieties held by the institution rose from 7 to 12, and the
target of increasing the number of drought-tolerant cereal varieties was met
in full.

Improvement work continues in sheep as well. The programme begun in 2012 at
the Gözlü enterprise in Konya aims to cross the Akkaraman breed with
high-yielding native breeds and to obtain new pure breeds with high milk,
fertility and meat performance.

The district of Ceylanpınar in Şanlıurfa takes its name from that gazelle.$dsr$, array['sperma_satisi', 'korunanlar']::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/tigem/tigem_kangal.jpg","atif":"Zeynel Cebeci — CC BY-SA 4.0","kaynak":null,"alt_tr":"Kangal çoban köpeği, Saimbeyli'nin Avcıpınarı mahallesi, Adana, 2 Nisan 2016.","alt_en":"A Kangal shepherd dog in the Avcıpınarı neighbourhood of Saimbeyli, Adana, 2 April 2016."}$dsr$::jsonb),
  (13, $dsr$Bıraktığı iş$dsr$, $dsr$The work it put down$dsr$, $dsr$Kurumun bugün yapmadığı işler, yaptıklarından daha az anlatılıyor ama
belgeleri aynı yerde duruyor.

**Faizsiz tohumluk.** 8 Temmuz 1948'de kabul edilen 5254 sayılı Kanun,
kuraklık, don, sel, haşere ve yangın gibi afetlerden mahsulü en az yüzde 40
zarar görmüş ve Ziraat Bankasından ya da Tarım Kredi Kooperatiflerinden
tohum kredisi alamayacak durumdaki çiftçilere, **Ziraat Bankası eliyle ödünç
ve faizsiz** buğday, arpa, mısır, çavdar ve yulaf tohumluğu dağıtma yetkisini
Tarım Bakanlığına verdi. Kurumun sektör raporuna göre Devlet Üretme
Çiftlikleri ve sonrasında TİGEM, ürettiği tohumun yarısından fazlasını bu
kanun çerçevesinde dağıttı. Kanun 2001'de 4684 sayılı Kanunla yürürlükten
kalktı; aynı raporun tespitine göre 2001 ve 2002'de ülkede sertifikalı
hububat tohumu kullanımı hızla azaldı.

**Çiftçinin aletini onarmak.** 5433 sayılı Kanunun ikinci maddesinin (g)
bendi, genel müdürlüğün atölye ve tamirhanelerinde, kendi işlerine engel
olmamak şartıyla, çiftçilerin ziraat alet ve makinalarını **bedeli
karşılığında onarmasını** görev olarak sayıyordu.

**Atatürk Orman Çiftliği.** 1950'de 5659 sayılı Kanunla ayrı bir müdürlük
oldu.

**Araştırma enstitüleri.** 3646 sayılı Kanunun beşinci maddesine 2001'de
eklenen fıkra, dört araştırma kuruluşunu kanunun dışında bıraktı; onlar
TİGEM'e değil, tarımsal araştırma teşkilatına kaldı.

Bir de 1983 tarihli kuruluş kararnamesinin on beşinci maddesi var:
TİGEM işletmelerinde çalışan sürekli ve geçici işçilerle, işletme
merkezinden uzakta görevli ve iş başından ayrılamayan memurlara **parasız
yemek** verilir.

Bu dört halka birlikte okunduğunda kurumun ne olmaktan çıktığı görünüyor.
1948–2001 arasında TİGEM bir **sosyal yardım kanalıydı**: afetten zarar gören
çiftçiye devletin faizsiz tohumluk ulaştırma yolu kurumun tarlasından
geçiyordu. 1949 tarifinde bir **hizmet atölyesiydi**: çiftçinin bozulan
makinesini ücretle onarırdı. 1950'ye kadar Atatürk Orman Çiftliğinin
sahibiydi. 2001'e kadar dört araştırma enstitüsü de aynı kanunun kapsamındaydı.

Bugün bunların hiçbiri kurumda değil. Geriye kalan iş, 1949'da yazılan
cümlenin kendisi: tohumluk, damızlık, fidan — ve bunları üreticiye
ulaştırmak. Kurum yüzyılın ikinci yarısında taşıdığı yüklerin çoğunu
bıraktı; bırakmadığı tek şey, kuruluş cümlesindeki iş oldu.$dsr$, $dsr$The things the institution no longer does are told less often than the things
it does, but their documents sit in the same place.

**Interest-free seed.** Law 5254, adopted on 8 July 1948, gave the Ministry of
Agriculture the power to distribute wheat, barley, maize, rye and oat seed
**on loan and interest-free through Ziraat Bankası** to farmers whose crop had
been damaged by at least 40 per cent by disasters such as drought, frost,
flood, pests and fire and who could not obtain seed credit from Ziraat Bankası
or the Agricultural Credit Cooperatives. According to the institution's sector
report, the State Production Farms and later TİGEM distributed more than half
the seed they produced under this law. The law was repealed in 2001 by Law
4684; according to the same report, the use of certified cereal seed in the
country fell rapidly in 2001 and 2002.

**Repairing the farmer's machine.** Clause (g) of the second article of Law
5433 listed among the directorate's duties the **repair for a fee** of
farmers' agricultural tools and machines in its workshops and repair shops,
provided this did not impede its own work.

**Atatürk Forest Farm.** It became a separate directorate in 1950 under Law
5659.

**The research institutes.** A paragraph added in 2001 to the fifth article of
Law 3646 placed four research bodies outside the law; they remained with the
agricultural research organisation, not TİGEM.

And there is the fifteenth article of the 1983 founding decree: permanent and
temporary workers at TİGEM enterprises, and officials posted away from the
enterprise centre who cannot leave their work, are given **meals free of
charge**.

Read together, these four links show what the institution stopped being.
Between 1948 and 2001 TİGEM was a **channel of social assistance**: the
state's route for getting interest-free seed to a disaster-struck farmer ran
through the institution's fields. In the 1949 definition it was a **service
workshop**: it would repair a farmer's broken machine for a fee. Until 1950 it
owned the Atatürk Forest Farm. Until 2001 four research institutes fell under
the same law.

None of that is with the institution today. What remains is the sentence
written in 1949: seed, breeding stock, saplings — and getting them to the
producer. The institution set down most of the loads it carried through the
second half of the century; the one thing it did not set down was the work in
its founding sentence.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/tigem/tigem_aoc_1939.jpg","atif":"Directorate General of Press and Information — No restrictions","kaynak":null,"alt_tr":"Atatürk Orman Çiftliği, 1939.","alt_en":"Atatürk Forest Farm, 1939."}$dsr$::jsonb),
  (14, $dsr$Dünyada benzeri: iki model$dsr$, $dsr$Elsewhere in the world: two models$dsr$, $dsr$Çiftçiye sertifikalı tohum ulaştırmanın dünyada iki yolu var ve Türkiye
ikisini birden kullanıyor.

**Birinci yol: devlet kendi çiftliğinde üretir.** Bu modelin en yakın örneği
Hindistan'da. **State Farms Corporation of India**, devletin büyük ve
makineli çiftliklerini sertifikalı tohum üretmek için işleten bir kuruluştu.
Hindistan hükûmetinin bildirdiğine göre Rajasthan, Haryana ve Karnataka'da
5 merkezî devlet çiftliği ve 21.908 hektar araziyle çalışıyordu.

2013'te bu yapı, 1963 kuruluşlu **National Seeds Corporation** bünyesine
katıldı. Gerekçe açıktı: çiftliklerin arazisi ile tohum kuruluşunun dağıtım
ağını birleştirmek. NSC yılda yaklaşık 150.000 ton tohum üretiyor.

Karşılaştırma kendiliğinden çıkıyor. TİGEM'in 360.245 hektarı, SFCI'nin
21.908 hektarının **16,4 katı**. Ve Hindistan iki kurumu birleştirmek zorunda
kaldı; TİGEM 1983'ten beri zaten ikisi birden — hem çiftliği işletiyor hem
303 bayilik bir dağıtım ağı kuruyor.

**İkinci yol: devlet üretmez, belgeler.** **OECD Tohum Şemaları** bu modelin
uluslararası çerçevesi. Altmıştan fazla ülke katılıyor ve listede Türkiye de
var — Hindistan, Mısır, Fas, İran, Rusya Federasyonu ve Amerika Birleşik
Devletleri ile aynı listede. Bu modelde devletin işi tohum yetiştirmek değil,
yetiştirilenin çeşit saflığını ve kalitesini belgelemek.

Türkiye her iki listede birden duruyor: hem belgeleyen devlet, hem çiftlik
işleten devlet.

İki modelin farkı çiftçinin tarafından da görülebiliyor. Belgeleme
modelinde devlet tohumun **ne olduğunu** garanti eder: çeşit saflığı,
çimlenme gücü, yabancı tohum oranı. Tohumu kimin ürettiği, hangi fiyata
sattığı ve hangi yıl ne kadar bulunacağı pazarın işidir. Üretim modelinde
devlet buna bir de **bulunurluk** ekler: fiyatı bir yönetim kurulu belirler,
miktarı bir üretim planı tutar, dağıtımı bir bayi ağı yapar.

TİGEM'in payındaki düşüş bu çerçevede okunduğunda anlamı değişiyor. 2002'de
ülkede dağıtılan sertifikalı hububat tohumunun neredeyse tamamı devletin
kendi tarlasından geliyordu; 2022'de beşte biri geliyor. Aradaki fark
kurumun küçülmesi değil, belgeleme modelinin Türkiye'de nihayet bir pazar
üretmiş olması. Kurum, var olmak için kurulduğu boşluğun bir bölümünü
doldurdu ve o boşluk kapandıkça payı düştü.$dsr$, $dsr$There are two ways of getting certified seed to the farmer, and Türkiye uses
both.

**The first: the state grows it on its own farms.** The closest example of
this model is in India. The **State Farms Corporation of India** ran the
state's large mechanised farms for the production of certified seed. According
to the Indian government it operated 5 central state farms and 21,908 hectares
of land in Rajasthan, Haryana and Karnataka.

In 2013 this structure was merged into the **National Seeds Corporation**,
founded in 1963. The reason was plain: to combine the farms' land with the
seed corporation's distribution network. NSC produces about 150,000 tonnes of
seed a year.

The comparison follows by itself. TİGEM's 360,245 hectares are **16.4 times**
SFCI's 21,908. And India had to merge two institutions; TİGEM has been both
since 1983 — running the farms and building a distribution network of 303
dealers.

**The second: the state does not grow, it certifies.** The **OECD Seed
Schemes** are this model's international framework. More than sixty countries
take part, Türkiye among them — on the same list as India, Egypt, Morocco,
Iran, the Russian Federation and the United States. In this model the state's
job is not to raise seed but to certify the varietal purity and quality of
what is raised.

Türkiye stands on both lists: a state that certifies and a state that farms.

The difference between the two models can also be seen from the farmer's side.
In the certification model the state guarantees **what the seed is**: varietal
purity, germination, the proportion of foreign seed. Who produced it, at what
price it is sold and how much will be available in a given year are the
market's business. In the production model the state adds **availability**: a
board sets the price, a production plan holds the quantity, a dealer network
does the distribution.

Read in that frame, the fall in TİGEM's share means something different. In
2002 almost all the certified cereal seed distributed in the country came from
the state's own fields; in 2022 a fifth does. The difference is not that the
institution shrank but that the certification model has finally produced a
market in Türkiye. The institution filled part of the gap it was founded to
fill, and as that gap closed its share fell.$dsr$, array['iki_model']::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/tigem/tigem_hindistan_bugday.jpg","atif":"Satpal Dandiwal — CC BY-SA 4.0","kaynak":null,"alt_tr":"Pencap'ta buğday, Hindistan, 5 Nisan 2018.","alt_en":"Wheat in Punjab, India, 5 April 2018."}$dsr$::jsonb),
  (15, $dsr$Kaynakça$dsr$, $dsr$Sources$dsr$, $dsr$**Birincil belgeler.** 3130 sayılı Kanun (Resmî Gazete 19 Kasım 1937,
sayı 3538), 3308 sayılı Kanun (13 Ocak 1938, sayı 3807), 5254 sayılı Kanun
(14 Temmuz 1948, sayı 6957), 5433 sayılı Kanun (13 Haziran 1949, sayı 7231)
ve 5659 sayılı Kanun (1 Nisan 1950, sayı 7472) Türkiye Büyük Millet Meclisi
Kanunlar Dergisi'nden; her birinin Resmî Gazete tarih ve sayısı kendi ilk
satırında yazılıdır. 95 sayılı Kanun Hükmünde Kararname 28 Ekim 1983 tarihli
18205 Mükerrer sayılı Resmî Gazete'den, 233 sayılı Kanun Hükmünde Kararname
18 Haziran 1984 tarihli 18435 Mükerrer sayılı nüshadan okundu. 3646 sayılı
Kanun ve TİGEM Ana Statüsü (2 Şubat 2022, sayı 31738) kurumun kendi mevzuat
sayfasından alındı.

**Kurumun beyanı.** Arazi varlığı tablosu (25 Temmuz 2023), Tohumluk Satış
ve Dağıtım Yönergesi, Bazı İşletmelerin Uzun Süreli Kiraya Verilmesine
İlişkin Yönerge, 2024–2028 Stratejik Plan, 2022 Tohumculuk Sektör Raporu ve
Mart 2024 tarihli kurum sunumu TİGEM'in kendi yayınlarıdır. İşletme sayıları
kurumun işletme listelerinden sayılmıştır.

**Bağımsız kaynaklar.** Türkiye'nin tarım arazisi rakamı Dünya Bankası'nın
2024 verisidir. Ülke genelindeki sertifikalı buğday ve arpa tohumu dağıtım
rakamlarının kaynağı Tarım ve Orman Bakanlığıdır; bu dosyada kurumun sektör
raporundaki tablodan okunmuştur. Bilanço ve sermaye satırı Sayıştay Kamu
İşletmeleri 2024 Yılı Genel Raporundandır. OECD Tohum Şemaları katılımcı
ülke listesi OECD'nindir.

**Payda uyarısı.** Bu dosyadaki tohum payı, ülkede **dağıtılan** sertifikalı
hububat tohumuna oranlanmıştır. Kurumun kendi kataloğu aynı büyüklüğü
Türkiye'nin yıllık tohumluk **ihtiyacına** oranlıyor ve daha düşük bir sayı
veriyor; iki payda aynı cümlede kullanılamaz.

**Ölçü uyarısı.** Dağıtım ve satış aynı şey değildir. Dağıtım rakamı kurumun
kendi ekilişlerini de içerir; satış rakamı içermez. Aynı yılın iki rakamı
arasındaki fark bundandır.

**Kapsam uyarısı.** Arazi tablolarının paydası her zaman aynı değildir.
3.275.564 dekar faaliyetteki 17 işletme ile Genel Müdürlük yerleşkesini,
3.602.455 dekar ise kiraya verilen ve iştirak şeklinde kullanılanlarla
birlikte kurumun tamamını kapsar. Sulanan arazi ile sulu tarım arazisi
varlığı da ayrı ölçülerdir.

**Doğrulanamayanlar.** Hara arazilerinin bir dönem 3–4 milyon dekara
ulaştığı ve 450 bin dekara düştüğü bilgisi kurumun kendi anlatımıdır;
bağımsız bir karşılığı bulunamamıştır. Hindistan'daki State Farms
Corporation of India'nın çiftlik sayısı ve arazi büyüklüğü, Hindistan
hükûmetinin açıklamalarını aktaran basından alınmıştır; birincil metne
ulaşılamamıştır. Arazi tablosunun alt sütunları kaynakta yuvarlanmıştır:
beş kullanım kaleminin toplamı ile tablo toplamı arasında 3,27 milyon
dekarda 1,67 dekar fark vardır.$dsr$, $dsr$**Primary documents.** Law 3130 (Official Gazette of 19 November 1937, issue
3538), Law 3308 (13 January 1938, issue 3807), Law 5254 (14 July 1948, issue
6957), Law 5433 (13 June 1949, issue 7231) and Law 5659 (1 April 1950, issue
7472) were read from the Journal of Laws of the Grand National Assembly of
Türkiye; each carries its Official Gazette date and issue in its own opening
line. Decree-Law 95 was read from the Official Gazette of 28 October 1983,
issue 18205 Repeated, and Decree-Law 233 from the issue of 18 June 1984, 18435
Repeated. Law 3646 and the TİGEM Charter (2 February 2022, issue 31738) were
taken from the institution's own legislation page.

**The institution's own statements.** The land inventory (25 July 2023), the
Seed Sales and Distribution Directive, the Directive on the Long-Term Leasing
of Certain Enterprises, the 2024–2028 Strategic Plan, the 2022 Seed Sector
Report and the institution's March 2024 presentation are TİGEM's own
publications. Enterprise counts were taken from the institution's own
enterprise lists.

**Independent sources.** The figure for Türkiye's agricultural land is World
Bank data for 2024. The source of the nationwide certified wheat and barley
seed distribution figures is the Ministry of Agriculture and Forestry; in this
dossier they were read from the table in the institution's sector report. The
balance-sheet and capital line comes from the Court of Accounts' 2024 General
Report on Public Enterprises. The list of countries participating in the OECD
Seed Schemes is the OECD's.

**A note on the denominator.** The seed share in this dossier is measured
against the certified cereal seed **distributed** in the country. The
institution's own catalogue measures the same quantity against Türkiye's
annual seed **requirement** and arrives at a lower figure; the two
denominators cannot be used in the same sentence.

**A note on the measure.** Distribution and sales are not the same thing. The
distribution figure includes the institution's own sowing; the sales figure
does not. That is where the difference between two figures for the same year
comes from.

**A note on scope.** The denominator of the land tables is not always the
same. 3,275,564 decares covers the 17 operating enterprises and the
headquarters campus; 3,602,455 decares covers the whole institution, including
the enterprises leased out and those used through participation. Irrigated
land and irrigable farmland are likewise separate measures.

**What could not be verified.** The statement that the stud lands reached 3–4
million decares at one point and fell to 450,000 is the institution's own
account; no independent counterpart was found. The number of farms and the
area held by the State Farms Corporation of India were taken from press
reports of Indian government statements; the primary text could not be
reached. The sub-columns of the land table are rounded at source: the five
use items and the table total differ by 1.67 decares in 3.27 million.$dsr$, '{}'::text[], 'anlati', null)
) as v(ord, title_tr, title_en, body_tr, body_en, chart_keys, tur, gorsel)
where d.slug = 'tigem';

-- Sağlama: beklenen bölüm sayısı yazılmadıysa işlem geri alınır.
do $kontrol$
declare n integer;
begin
  select count(*) into n
    from public.dossier_sections s
    join public.country_dossiers d on d.id = s.dossier_id
   where d.slug = 'tigem';
  if n <> 15 then
    raise exception 'Bölüm sayısı 15 olmalıydı, % yazıldı', n;
  end if;
end
$kontrol$;

commit;
