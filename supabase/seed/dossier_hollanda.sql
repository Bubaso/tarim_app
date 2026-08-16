-- Hollanda — Ülke Dosyası · seed
--
-- ÜRETİLMİŞ DOSYA — elle düzenlemeyin.
-- Kaynak:  content/dossiers/hollanda/
-- Üretim:  node content/dossiers/seed_dossier.mjs hollanda
-- Tarih:   2026-08-16T10:36:29.131Z
--
-- Bölüm: 13 · TR ~4.826 kelime · EN ~6.328 kelime
-- Metindeki her rakam data.json'dan, data.json _raw/'dan geliyor.
--
-- Yeniden çalıştırılabilir: dosyayı günceller, bölümleri silip yeniden yazar.
-- Bölümler upsert değil sil-yaz, çünkü bir revizyonda bölüm sayısı azalırsa
-- upsert eski fazlalığı geride bırakırdı.

begin;

insert into public.country_dossiers
  (slug, name_tr, name_en, iso3, edition,
   thesis_tr, thesis_en, theme, data, charts,
   cover_url, cover_credit, status, starts_at, ends_at, published_at)
values (
  'hollanda',
  'Hollanda',
  'Netherlands',
  'NLD',
  1,
  $dsr$Hollanda'nın sırrı toprağında değil, toprağının üstüne kurduğu sistemde.$dsr$,
  $dsr$The Dutch secret is not in the soil, but in what they built on top of it.$dsr$,
  $dsr${"_dosya":"Hollanda — Ülke Dosyası · tasarım künyesi","_amac":"Faz 0.5'te onaylanan görsel kararlar. Faz 3'te DossierTheme bu dosyadan üretilir; kodda serbest renk yazılmaz.","_onay_tarihi":"2026-08-15","_kural":"Bu dosyadaki hiçbir renk 'yaklaşık' değildir. Hepsi WCAG 2.1 AA'ya karşı hesaplandı; hesap betiği aşağıda kayıtlı.","tez_cumlesi":{"tr":"Hollanda'nın sırrı toprağında değil, toprağının üstüne kurduğu sistemde.","en":"The Dutch secret is not in the soil, but in what they built on top of it.","gerekce":"Hem verim bölümünü (cam altı yoğunlaştırma) hem kurumlar bölümünü (kooperatif, PPS, ıslah) kapsıyor. 'Kurduğu' fiili kasıtlı: sistem miras değil, tasarım. Dosyanın Türkiye'ye bakan yüzü bu kelimede."},"palet":{"ad":"Cam ve Işık","kaynak_fikir":"Hollanda seralarının gece göğe vurduğu sodyum lambası parıltısı. Westland ve Oostland üzerindeki turuncu ışık kubbeleri uzaydan görülüyor — bu bir metafor değil, ölçülebilir bir olgu. Palet manzaradan değil, manzaraya YAPILAN müdahaleden türetildi.","mod":"KOYU — dosya sayfası her zaman koyu. Uygulamanın açık/koyu tercihini izlemez.","mod_gerekcesi":"Dergi dosyası mantığı: içeri girdiğinizde başka bir yere geldiğinizi anlamalısınız. Ayrıca sodyum turuncusu ancak koyu zeminde sodyum turuncusu gibi görünür; açık zeminde tuğla rengine döner ve fikir kaybolur. Ana sayfadaki şerit bunun istisnasıdır — o, sayfanın içinde yaşadığı için açık/koyu izler.","koyu":{"zemin":{"hex":"#0E1418","rol":"Sayfa arka planı — gece"},"yuzey":{"hex":"#18222A","rol":"Kart, tablo, alıntı bloğu"},"murekkep":{"hex":"#E8EDEF","rol":"Gövde metni","kontrast_zemin":15.72,"kontrast_yuzey":13.67},"sessiz":{"hex":"#9BAAB3","rol":"Meta, kaynak satırı, altyazı","kontrast_zemin":7.77,"kontrast_yuzey":6.76},"vurgu":{"hex":"#FF9E5E","rol":"Sodyum turuncusu — rakamlar, başlık vurguları, grafik ana serisi","kontrast_zemin":9.1,"kontrast_yuzey":7.92},"ikincil":{"hex":"#7FC8A9","rol":"Cam yeşili — Türkiye serisi, karşılaştırma ikinci rengi","kontrast_zemin":9.49,"kontrast_yuzey":8.25},"cizgi":{"hex":"#2A3740","rol":"SADECE dekoratif ayırıcı","kontrast_zemin":1.52,"_uyari":"3:1'in altında. Anlam taşıyan hiçbir yerde kullanılamaz — grafik ekseni, sınır, odak halkası için cizgiVurgu kullanılır."},"cizgiVurgu":{"hex":"#5A6E78","rol":"Grafik ekseni, ızgara çizgisi, odak halkası — anlam taşıyan çizgiler","kontrast_zemin":3.48,"kontrast_yuzey":3.03}},"acik_mod_seridi":{"_amac":"Ana sayfadaki dosya şeridi sayfanın içinde yaşıyor; açık modda sodyum turuncusu okunmuyor (beyaz üstünde 2,04:1). Şerit için koyulaştırılmış varyantlar kullanılır.","murekkep":{"hex":"#16222A","kontrast_krem":14.77},"vurguKoyu":{"hex":"#AB4F16","rol":"Turuncunun açık zemin karşılığı","kontrast_krem":4.96,"kontrast_beyaz":5.44},"ikincilKoyu":{"hex":"#1F6B4E","rol":"Cam yeşilinin açık zemin karşılığı","kontrast_krem":5.85}},"renk_korlugu_notu":"Turuncu (#FF9E5E) ve yeşil (#7FC8A9) parlaklıkları farklı (9,10 vs 9,49 — yakın), bu yüzden deuteranopia'da AYIRT EDİLEMEYEBİLİR. Grafiklerde iki seri asla yalnızca renkle ayrılmayacak: Hollanda dolu çizgi/dolu daire, Türkiye kesikli çizgi/içi boş daire. Bu Faz 3'ün zorunlu şartı.","denetim_betigi":"_raw/kontrast.cjs — `node content/dossiers/hollanda/_raw/kontrast.cjs`"},"motif":{"ad":"Polder geometrisi","tanim":"Denizden kazanılmış arazinin havadan görünen dikdörtgen parsel ve hendek ızgarası. Düzensiz genişlikte dikey şeritler, aralarında ince yatay bölmeler.","gerekce":"Doğrusal olduğu için düşük opaklıkta metin okunurluğunu bozmaz. Delft çinisinin figüratifliğinden ve lale şeritlerinin yanlış vaadinden kaçınır. En önemlisi tezi tekrar eder: bu manzara doğal değil, insan yapımı — tıpkı seranın kendisi gibi.","uygulama":{"opaklik":"%5 (kabul aralığı %4–8)","renk":"cizgiVurgu #5A6E78 üzerine opaklık","bicim":"Vektör (CustomPainter) — raster değil. Ölçeklenebilir, dosya boyutu sıfır, telif sorunu yok.","yerlesim":"Bölüm ayırıcılarında ve kapak altı geçiş bandında. Gövde metninin ARKASINDA kullanılmaz.","moire_notu":"Izgara aralığı 24 px'in altına inmeyecek; retina olmayan ekranlarda titreme yapar."}},"kapak":{"yon":"Gece sera parıltısı — havadan/yörüngeden Westland","gerekce":"Tezin doğrudan görselleştirmesi: karanlık arazide turuncu ışık adaları. Paletle aynı kaynaktan geliyor, o yüzden kapak ve sayfa aynı fikri söylüyor.","gorsel_kaynagi":{"tercih_1":"NASA Earth Observatory / ISS astronot fotoğrafı — KAMU MALI (public domain), atıf yeterli, ticari kullanım serbest. Hollanda sera ışıkları ISS gece çekimlerinde net görünüyor.","tercih_2":"Unsplash / Pexels lisanslı havadan gece çekimi","_karar":"Tercih 1 denenecek; bulunamazsa tercih 2. Görsel BULUNANA KADAR kapak tipografik iskeletle çalışır — Faz 3 görselsiz de tamamlanabilir olmalı.","_yasak":"Telifi belirsiz hiçbir görsel kullanılmayacak. Google görsel araması kaynak değildir."},"tipografi_katmani":{"ust_satir":"ÜLKE DOSYASI · 01","baslik":"HOLLANDA","alt_satir":"tez_cumlesi.tr","veri_rozeti":"Tarım arazisinin %0,56'sı cam altında"},"okunurluk":"Görsel üzerine zemin renginden %0 → %85 dikey gradyan; metin yalnızca %60+ bölgede durur. Gradyan olmadan hiçbir metin görsel üstüne konmaz."},"_faz3_zorunluluklari":["Grafiklerde iki seri renkle BİRLİKTE biçimle de ayrılacak (renk körlüğü)","Motif CustomPainter ile çizilecek, görsel dosyası olarak gömülmeyecek","Kapak görseli bulunamazsa sayfa yine de tam çalışacak","Koyu sayfa sistem açık/koyu tercihini izlemeyecek; ana sayfa şeridi izleyecek","Tüm renkler bu dosyadan türetilen DossierTheme üzerinden gelecek, kodda serbest hex yazılmayacak"]}$dsr$::jsonb,
  $dsr${"_dosya":"Hollanda — Ülke Dosyası · kilitli veri sayfası","_uretim_tarihi":"2026-08-16T10:36:03.869Z","_kural":"Dosya metninde geçen HER sayı bu dosyadan gelir. Buraya girmemiş bir sayı metne giremez. Bir sayı güncellenecekse önce burası güncellenir, sonra metin.","_kaynaklar":{"WB":{"ad":"World Bank Open Data","url":"https://data.worldbank.org","lisans":"CC BY 4.0","cekim":"2026-08-15T05:31:49.172Z"},"FAO_QCL":{"ad":"FAOSTAT — Production: Crops and livestock products","url":"https://www.fao.org/faostat/en/#data/QCL","cekim":"2026-08-15T00:32:33.122Z"},"FAO_QV":{"ad":"FAOSTAT — Value of Agricultural Production","url":"https://www.fao.org/faostat/en/#data/QV","cekim":"2026-08-15T00:32:33.122Z"},"FAO_TCL":{"ad":"FAOSTAT — Trade: Crops and livestock products","url":"https://www.fao.org/faostat/en/#data/TCL","cekim":"2026-08-15T00:37:10.558Z"},"FAO_TM":{"ad":"FAOSTAT — Detailed Trade Matrix","url":"https://www.fao.org/faostat/en/#data/TM","cekim":"2026-08-15T00:50:49.775Z"},"CBS":{"ad":"CBS StatLine — tablo 81302ned","url":"https://opendata.cbs.nl/statline/#/CBS/nl/dataset/81302ned/table","lisans":"CC BY 4.0 (CBS açık veri)","guncelleme":"2026-06-30T02:00:00","cekim":"2026-08-15T01:07:48.558Z"},"CBS_IHR":{"ad":"CBS (Centraal Bureau voor de Statistiek) — 'Waarde landbouwexport ruim 8 procent hoger in 2025'","url":"https://www.cbs.nl/nl-nl/nieuws/2026/03/waarde-landbouwexport-ruim-8-procent-hoger-in-2025","yayin":"2026-01-16","not":"ELLE GİRİLDİ — CBS bu seriyi OData API'sinden yayımlamıyor, haber bülteninden alındı ve birincil kaynaktan doğrulandı."},"KURUM":{"ad":"Kurumların kendi resmî yayınları — tek tek doğrulandı","dogrulama":"2026-08-15"},"TARIH":{"ad":"Rijkswaterstaat, Nieuw Land, Deltacommissie, WUR, AB tarihî arşivleri — elle doğrulandı","dogrulama":"2026-08-15"},"CEVRE":{"ad":"CBS, RIVM, Emissieregistratie, RVO, Raad van State, AB Konseyi — elle doğrulandı","dogrulama":"2026-08-16"}},"tez":{"cumle":"Hollanda'nın sırrı toprağında değil, toprağının üstüne kurduğu sistemde.","cumle_en":"The Dutch secret is not in the soil, but in what they built on top of it.","baslik":"Az üreten, çok satan ülke","ozet":"Türkiye tarımsal üretim değerinde Hollanda'nın yaklaşık dört buçuk katı. Hollanda tarımsal ihracatta Türkiye'nin yaklaşık dört katı. Aradaki fark toprakta değil, toprakla ürün arasındaki her adımda.","uretim_degeri":{"birim":"milyon I$ (sabit 2014-2016 uluslararası dolar)","NLD":{"yil":2023,"deger":17789},"TUR":{"yil":2023,"deger":79879},"kaynak":"FAO_QV"},"ihracat":{"birim":"milyon US$ (cari)","kalem":"Crops and livestock products","NLD":{"yil":2023,"deger":125753},"TUR":{"yil":2023,"deger":29502},"kaynak":"FAO_TCL"},"ithalat":{"birim":"milyon US$ (cari)","NLD":{"yil":2023,"deger":85753},"TUR":{"yil":2023,"deger":25413},"kaynak":"FAO_TCL"},"UYARI":"Üretim değeri sabit I$, ihracat cari US$ cinsinden. İkisinin ORANI (7,1 vs 0,37) ekonomik olarak birebir karşılaştırılabilir bir sayı DEĞİL; metinde oran olarak verilmeyecek, olgu olarak anlatılacak."},"makro":[{"kod":"NV.AGR.TOTL.ZS","etiket":"Tarımın GSYH içindeki payı","birim":"%","NLD":{"yil":2025,"deger":1.68323077210041},"TUR":{"yil":2025,"deger":5.20951196750004},"kaynak":"World Bank — World Development Indicators","kaynak_url":"https://data.worldbank.org/indicator/NV.AGR.TOTL.ZS","veri_guncelleme":"2026-07-13"},{"kod":"NV.AGR.TOTL.CD","etiket":"Tarımsal katma değer","birim":"cari US$","NLD":{"yil":2025,"deger":22433555223.9215},"TUR":{"yil":2025,"deger":83211181935.7741},"kaynak":"World Bank — World Development Indicators","kaynak_url":"https://data.worldbank.org/indicator/NV.AGR.TOTL.CD","veri_guncelleme":"2026-07-13"},{"kod":"SL.AGR.EMPL.ZS","etiket":"Tarımda istihdam payı","birim":"%","NLD":{"yil":2025,"deger":1.70416434849209},"TUR":{"yil":2025,"deger":14.2199829949572},"kaynak":"World Bank — World Development Indicators","kaynak_url":"https://data.worldbank.org/indicator/SL.AGR.EMPL.ZS","veri_guncelleme":"2026-07-13"},{"kod":"SP.POP.TOTL","etiket":"Nüfus","birim":"kişi","NLD":{"yil":2025,"deger":18087633},"TUR":{"yil":2025,"deger":85878556},"kaynak":"World Bank — World Development Indicators","kaynak_url":"https://data.worldbank.org/indicator/SP.POP.TOTL","veri_guncelleme":"2026-07-13"},{"kod":"SP.RUR.TOTL.ZS","etiket":"Kırsal nüfus payı","birim":"%","NLD":{"yil":2025,"deger":4.06140965188089},"TUR":{"yil":2025,"deger":10.505939997814},"kaynak":"World Bank — World Development Indicators","kaynak_url":"https://data.worldbank.org/indicator/SP.RUR.TOTL.ZS","veri_guncelleme":"2026-07-13"},{"kod":"NY.GDP.MKTP.CD","etiket":"GSYH","birim":"cari US$","NLD":{"yil":2025,"deger":1332767651100.39},"TUR":{"yil":2025,"deger":1597293229287},"kaynak":"World Bank — World Development Indicators","kaynak_url":"https://data.worldbank.org/indicator/NY.GDP.MKTP.CD","veri_guncelleme":"2026-07-13"},{"kod":"NY.GDP.PCAP.CD","etiket":"Kişi başına GSYH","birim":"cari US$","NLD":{"yil":2025,"deger":73683.917132794},"TUR":{"yil":2025,"deger":18599.4420922378},"kaynak":"World Bank — World Development Indicators","kaynak_url":"https://data.worldbank.org/indicator/NY.GDP.PCAP.CD","veri_guncelleme":"2026-07-13"}],"toprak_su":[{"kod":"AG.LND.TOTL.K2","etiket":"Kara alanı","birim":"km²","NLD":{"yil":2023,"deger":33670},"TUR":{"yil":2023,"deger":769630},"kaynak":"World Bank — World Development Indicators","kaynak_url":"https://data.worldbank.org/indicator/AG.LND.TOTL.K2","veri_guncelleme":"2026-07-13"},{"kod":"AG.LND.AGRI.K2","etiket":"Tarım arazisi","birim":"km²","NLD":{"yil":2023,"deger":18030},"TUR":{"yil":2023,"deger":385880},"kaynak":"World Bank — World Development Indicators","kaynak_url":"https://data.worldbank.org/indicator/AG.LND.AGRI.K2","veri_guncelleme":"2026-07-13"},{"kod":"AG.LND.AGRI.ZS","etiket":"Tarım arazisinin kara alanına oranı","birim":"%","NLD":{"yil":2023,"deger":53.5491535491536},"TUR":{"yil":2023,"deger":50.1383781817237},"kaynak":"World Bank — World Development Indicators","kaynak_url":"https://data.worldbank.org/indicator/AG.LND.AGRI.ZS","veri_guncelleme":"2026-07-13"},{"kod":"AG.LND.ARBL.HA","etiket":"İşlenebilir arazi","birim":"hektar","NLD":{"yil":2023,"deger":1009000},"TUR":{"yil":2023,"deger":20277000},"kaynak":"World Bank — World Development Indicators","kaynak_url":"https://data.worldbank.org/indicator/AG.LND.ARBL.HA","veri_guncelleme":"2026-07-13"},{"kod":"AG.LND.ARBL.HA.PC","etiket":"Kişi başına işlenebilir arazi","birim":"hektar","NLD":{"yil":2023,"deger":0.056440867954268},"TUR":{"yil":2023,"deger":0.237641613546357},"kaynak":"World Bank — World Development Indicators","kaynak_url":"https://data.worldbank.org/indicator/AG.LND.ARBL.HA.PC","veri_guncelleme":"2026-07-13"},{"kod":"AG.LND.IRIG.AG.ZS","etiket":"Sulanan arazi payı","birim":"%","NLD":{"yil":2023,"deger":21.5751525235718},"TUR":{"yil":2023,"deger":12.4676065097958},"kaynak":"World Bank — World Development Indicators","kaynak_url":"https://data.worldbank.org/indicator/AG.LND.IRIG.AG.ZS","veri_guncelleme":"2026-07-13"},{"kod":"ER.H2O.FWAG.ZS","etiket":"Tarımın tatlı su çekimindeki payı","birim":"%","NLD":{"yil":2022,"deger":3.219295516},"TUR":{"yil":2022,"deger":86.92701174},"kaynak":"World Bank — World Development Indicators","kaynak_url":"https://data.worldbank.org/indicator/ER.H2O.FWAG.ZS","veri_guncelleme":"2026-07-13"},{"kod":"AG.CON.FERT.ZS","etiket":"Gübre tüketimi","birim":"kg/ha","NLD":{"yil":2023,"deger":238.01982160555},"TUR":{"yil":2023,"deger":139.557478917},"kaynak":"World Bank — World Development Indicators","kaynak_url":"https://data.worldbank.org/indicator/AG.CON.FERT.ZS","veri_guncelleme":"2026-07-13"}],"verim":{"aciklama":"Fark tek bir sayı değil, üç kademe. (1) Örtüaltı sebzede 5–12 kat — bu kademe mühendislik ürünü. (2) Yumru ve kök ürünlerde 1,1–1,2 kat — pratikte fark yok. (3) Tahılda 2,2–2,6 kat — gerçek bir fark, ama kapanıyor. Hollanda mucizesi genel bir tarım üstünlüğü DEĞİL; farkın büyüklüğü ürünün cam altına alınıp alınmadığına göre değişiyor. Dosyanın en önemli tespiti budur.","ortualti":[{"urun":"Salatalık","fao_item":"Cucumbers and gherkins","birim":"t/ha","NLD":{"yil":2023,"deger":635.9},"TUR":{"yil":2023,"deger":53.1},"kat":12},{"urun":"Domates","fao_item":"Tomatoes","birim":"t/ha","NLD":{"yil":2023,"deger":410.2},"TUR":{"yil":2023,"deger":80},"kat":5.1},{"urun":"Biber","fao_item":"Chillies and peppers, green (Capsicum spp. and Pimenta spp.)","birim":"t/ha","NLD":{"yil":2023,"deger":269.2},"TUR":{"yil":2023,"deger":40.4},"kat":6.7}],"acik_tarla":[{"urun":"Patates","fao_item":"Potatoes","birim":"t/ha","NLD":{"yil":2023,"deger":41.8},"TUR":{"yil":2023,"deger":37.8},"kat":1.1},{"urun":"Kuru soğan","fao_item":"Onions and shallots, dry (excluding dehydrated)","birim":"t/ha","NLD":{"yil":2023,"deger":45.9},"TUR":{"yil":2023,"deger":43},"kat":1.1},{"urun":"Buğday","fao_item":"Wheat","birim":"t/ha","NLD":{"yil":2023,"deger":8.5},"TUR":{"yil":2023,"deger":3.2},"kat":2.6},{"urun":"Arpa","fao_item":"Barley","birim":"t/ha","NLD":{"yil":2023,"deger":6.5},"TUR":{"yil":2023,"deger":2.8},"kat":2.3},{"urun":"Şeker pancarı","fao_item":"Sugar beet","birim":"t/ha","NLD":{"yil":2023,"deger":86.3},"TUR":{"yil":2023,"deger":69.4},"kat":1.2}],"kaynak":"FAO_QCL (element 5412 Yield, kg/ha → t/ha)","tahil_farki":{"_neden_burada":"Tahıl farkı örtüaltı farkıyla aynı şey değil: sera farkı mühendislikle açılıyor, tahıl farkı girdi ve iklimle birlikte kapanıyor. Metinde bu ikisi birbirine karıştırılmayacak.","seyir":[{"yil":1990,"NLD":6990,"TUR":2214,"kat":3.16},{"yil":2000,"NLD":7906,"TUR":2371,"kat":3.33},{"yil":2010,"NLD":8569,"TUR":2726,"kat":3.14},{"yil":2020,"NLD":7944,"TUR":3342,"kat":2.38},{"yil":2023,"NLD":8080,"TUR":3659,"kat":2.21}],"seyir_birim":"kg/ha — Dünya Bankası AG.YLD.CREL.KG","girdi_farklari":[{"kod":"AG.LND.PRCP.MM","etiket":"Ortalama yağış","birim":"mm/yıl","NLD":{"yil":2022,"deger":778},"TUR":{"yil":2022,"deger":593},"kaynak":"World Bank — World Development Indicators","kaynak_url":"https://data.worldbank.org/indicator/AG.LND.PRCP.MM","veri_guncelleme":"2026-07-13"},{"kod":"AG.CON.FERT.ZS","etiket":"Gübre tüketimi","birim":"kg/ha","NLD":{"yil":2023,"deger":238.01982160555},"TUR":{"yil":2023,"deger":139.557478917},"kaynak":"World Bank — World Development Indicators","kaynak_url":"https://data.worldbank.org/indicator/AG.CON.FERT.ZS","veri_guncelleme":"2026-07-13"},{"kod":"AG.LND.IRIG.AG.ZS","etiket":"Sulanan arazi payı","birim":"%","NLD":{"yil":2023,"deger":21.5751525235718},"TUR":{"yil":2023,"deger":12.4676065097958},"kaynak":"World Bank — World Development Indicators","kaynak_url":"https://data.worldbank.org/indicator/AG.LND.IRIG.AG.ZS","veri_guncelleme":"2026-07-13"}],"yagis_uyarisi":"AG.LND.PRCP.MM YILLIK DEĞİL uzun dönem ortalamasıdır — 1990-2022 arasındaki 33 kaydın hepsi aynı sayıyı verir. \"2022 yağışı\" diye yazılamaz; \"uzun dönem ortalaması\" denir.","_yorum_siniri":"Bu üç girdi farkı tahıl farkıyla BİRLİKTE bulunuyor; nedensellik kanıtı değildir. Metin \"şu kadarı iklimden\" diye pay dağıtmayacak."}},"sera":{"aciklama":"Verim farkını yaratan alan, Hollanda tarım arazisinin yüzde birinden küçük. Üstelik 2000'den bu yana BÜYÜMEDİ, küçüldü. \"Hollanda mucizesi\" bir yayılma değil, sabit ve küçük bir alanın yoğunlaştırılması hikâyesi.","toplam_tarim_arazisi":{"alan":"Toplam tarım arazisi (ha)","yil":2025,"hektar":1793760},"ortualti":{"alan":"Örtüaltı toplam (ha)","yil":2025,"hektar":10030,"tarim_arazisi_payi_yuzde":0.56},"cam_alti_sebze":{"alan":"Cam altı sebze toplam (ha)","yil":2025,"hektar":5570,"tarim_arazisi_payi_yuzde":0.31},"sus_bitkisi":{"alan":"Süs bitkisi toplam (ha)","yil":2025,"hektar":3900,"tarim_arazisi_payi_yuzde":0.22},"sebzeler":[{"alan":"Domates (ha)","yil":2025,"hektar":1770},{"alan":"Biber (ha)","yil":2025,"hektar":1580},{"alan":"Salatalık (ha)","yil":2025,"hektar":630},{"alan":"Patlıcan (ha)","yil":2025,"hektar":110}],"susler":[{"alan":"Kesme çiçek toplam (ha)","yil":2025,"hektar":1710},{"alan":"Saksı bitkisi toplam (ha)","yil":2025,"hektar":1730},{"alan":"Krizantem (ha)","yil":2025,"hektar":470},{"alan":"Gül (ha)","yil":2025,"hektar":140},{"alan":"Orkide (ha)","yil":2025,"hektar":80},{"alan":"Lale — cam altı (ha)","yil":2025,"hektar":0}],"sera_alani_seyri":{"ilk_yil":2000,"ilk_deger":10520,"son_yil":2025,"son_deger":10030,"degisim_yuzde":-4.7},"isletme_sayisi_seyri":{"ilk_yil":2000,"ilk_deger":97390,"son_yil":2026,"son_deger":48570,"degisim_yuzde":-50.1},"ortualti_isletme":{"alan":"Örtüaltı işletme sayısı","yil":2025,"hektar":3030},"ortalama_sera_buyuklugu_ha":3.31,"capraz_dogrulama":"FAOSTAT'ın Hollanda domates hasat alanı (5312) ile CBS'nin cam altı domates alanı BİREBİR aynı: 1.770 ha. İki bağımsız kaynak aynı sayıyı veriyor — Hollanda'da domates neredeyse tamamen cam altında demektir.","turkiye_karsilastirmasi":{"urun":"Domates hasat alanı","birim":"hektar","TUR":{"yil":2023,"deger":166323},"NLD":{"yil":2023,"deger":1770},"kat":94},"kaynak":"CBS"},"ihracat_kompozisyonu":{"aciklama":"Hollanda'nın kendi istatistik kurumu, manşet ihracat rakamının Hollanda ekonomisine bıraktığı payı ayrı hesaplıyor. Dosyanın dürüstlük düzeltmesi burada.","yil":2025,"birim":"milyar EUR","toplam":137.5,"artis_yuzde":8.4,"hollanda_yapimi":88.4,"yeniden_ihracat":49.1,"yeniden_ihracat_payi_yuzde":35.7,"kazanc":{"toplam":49,"hollanda_yapimindan":43.5,"yeniden_ihracattan":5.7,"_not":"'Exportverdiensten' = ihracatın Hollanda ekonomisinde gerçekten bıraktığı katma değer. Ciro değil, kazanç.","_kritik_bulgu":"Yeniden ihracat, manşet rakamın %35,7'si ama kazancın yalnızca %11,6'sı. Yani 137,5 milyar avroluk başlık, Hollanda'nın gerçek başarısını yaklaşık üçte bir oranında ŞİŞİRİYOR — ve bunu söyleyen Hollanda'nın kendi istatistik kurumu."},"kazanc_icinde_yeniden_ihracat_payi_yuzde":11.6,"deger_tutma_orani":{"hollanda_yapimi_yuzde":49.2,"yeniden_ihracat_yuzde":11.6,"_not":"Hollanda'da üretilen her 100 avroluk ihracattan ~49 avro ülkede kalıyor; yeniden ihraç edilen her 100 avrodan ~12 avro."},"kritik_bulgu":"Yeniden ihracat, manşet rakamın %35,7'si ama kazancın yalnızca %11,6'sı. Yani 137,5 milyar avroluk başlık, Hollanda'nın gerçek başarısını yaklaşık üçte bir oranında ŞİŞİRİYOR — ve bunu söyleyen Hollanda'nın kendi istatistik kurumu.","buyume_nedeni":"Değer artışının üçte ikisinden fazlası FİYAT artışından; kalanı miktar artışından.","ilk_10_pazar":[{"ulke":"Almanya","milyar_eur":34,"pay_yuzde":25},{"ulke":"Belçika","milyar_eur":16.9},{"ulke":"Fransa","milyar_eur":11.4},{"ulke":"Birleşik Krallık","milyar_eur":9.8},{"ulke":"İspanya","milyar_eur":5.7},{"ulke":"İtalya","milyar_eur":5.6},{"ulke":"Polonya","milyar_eur":5.2},{"ulke":"ABD","milyar_eur":3.8},{"ulke":"İsveç","milyar_eur":3.1},{"ulke":"Çin","milyar_eur":3}],"ilk_10_notu":"Türkiye ilk 10'da yok. Hollanda ihracatının ezici çoğunluğu komşularına gidiyor — bu da 'küresel dev' imajını düzelten bir olgu.","UYARI":"Bu seri EUR ve CBS tanımlı 'landbouwgoederen'dir. FAOSTAT'ın USD cinsinden 'Crops and livestock products' serisiyle AYNI ŞEY DEĞİLDİR. İkisi asla aynı cümlede oran olarak kullanılmayacak.","kaynak":"CBS_IHR"},"kakao":{"aciklama":"Hollanda tek bir kakao ağacı yetiştirmez. Batı Afrika'dan çekirdek alır, öğütür, yağını ve ezmesini satar. Dosyanın tezinin en temiz örneği.","hollanda_uretimi":"FAOSTAT üretim kaydı yok — Hollanda kakao yetiştirmiyor","kalemler":[{"kalem":"Cocoa beans","ithalat":{"yil":2023,"milyon_usd":2399},"ihracat":{"yil":2023,"milyon_usd":594}},{"kalem":"Cocoa butter, fat and oil","ithalat":{"yil":2023,"milyon_usd":505},"ihracat":{"yil":2023,"milyon_usd":1624}},{"kalem":"Cocoa paste not defatted","ithalat":{"yil":2023,"milyon_usd":399},"ihracat":{"yil":2023,"milyon_usd":980}},{"kalem":"Cocoa powder and cake","ithalat":{"yil":2023,"milyon_usd":359},"ihracat":{"yil":2023,"milyon_usd":1034}}],"kaynak":"FAO_TCL"},"turkiye_ile":{"aciklama":"Türkiye Hollanda'ya kuru meyve ve sert kabuklu satıyor; Hollanda Türkiye'ye işlenmiş sanayi girdisi satıyor. İlişkinin kendisi dosyanın tezini tekrarlıyor.","raportor":"Hollanda (tek raportör — iki ülkenin beyanları birbirini tutmaz)","birim":"milyon US$ (cari)","yillar":[{"yil":2020,"hollandadan_turkiyeye":574,"turkiyeden_hollandaya":506},{"yil":2021,"hollandadan_turkiyeye":614,"turkiyeden_hollandaya":548},{"yil":2022,"hollandadan_turkiyeye":727,"turkiyeden_hollandaya":564},{"yil":2023,"hollandadan_turkiyeye":749,"turkiyeden_hollandaya":586},{"yil":2024,"hollandadan_turkiyeye":803,"turkiyeden_hollandaya":681}],"hollandanin_sattiklari":[{"kalem":"Food preparations n.e.c.","yil":2024,"milyon_usd":110.6},{"kalem":"Other manufactured tobacco and manufactured tobacco substitutes; 'homogenized' or 'reconstituted' tobacco; tobacco extracts and essences","yil":2024,"milyon_usd":83.6},{"kalem":"Cocoa powder and cake","yil":2024,"milyon_usd":80},{"kalem":"Cocoa paste not defatted","yil":2024,"milyon_usd":63.8},{"kalem":"Cocoa butter, fat and oil","yil":2024,"milyon_usd":60.9},{"kalem":"Other non-alcoholic caloric beverages","yil":2024,"milyon_usd":60},{"kalem":"Crude organic material n.e.c.","yil":2024,"milyon_usd":45.2},{"kalem":"Coffee, decaffeinated or roasted","yil":2024,"milyon_usd":29.9},{"kalem":"Food wastes","yil":2024,"milyon_usd":26.2},{"kalem":"Potatoes","yil":2024,"milyon_usd":22},{"kalem":"Chocolate products nes","yil":2024,"milyon_usd":20.3},{"kalem":"Extracts, essences and concentrates of tea or mate, and preparations with a basis thereof or with a basis of tea or maté","yil":2024,"milyon_usd":20.3},{"kalem":"Refined sugar","yil":2024,"milyon_usd":12},{"kalem":"Dog or cat food, put up for retail sale","yil":2024,"milyon_usd":11.7},{"kalem":"Cigarettes","yil":2024,"milyon_usd":10.1}],"turkiyenin_sattiklari":[{"kalem":"Prepared nuts","yil":2024,"milyon_usd":73.1},{"kalem":"Raisins","yil":2024,"milyon_usd":70.9},{"kalem":"Food preparations n.e.c.","yil":2024,"milyon_usd":47.1},{"kalem":"Crude organic material n.e.c.","yil":2024,"milyon_usd":46},{"kalem":"Fruit prepared n.e.c.","yil":2024,"milyon_usd":32.9},{"kalem":"Hazelnuts, shelled","yil":2024,"milyon_usd":32.7},{"kalem":"Vegetables, pulses and potatoes, preserved by vinegar or acetic acid","yil":2024,"milyon_usd":32.7},{"kalem":"Apple juice, concentrated","yil":2024,"milyon_usd":32},{"kalem":"Orange juice, concentrated","yil":2024,"milyon_usd":23.5},{"kalem":"Sugar confectionery","yil":2024,"milyon_usd":21.9},{"kalem":"Juice of fruits n.e.c.","yil":2024,"milyon_usd":18.1},{"kalem":"Pastry","yil":2024,"milyon_usd":17.9},{"kalem":"Apricots, dried","yil":2024,"milyon_usd":15.1},{"kalem":"Unmanufactured tobacco","yil":2024,"milyon_usd":14.4},{"kalem":"Other non-alcoholic caloric beverages","yil":2024,"milyon_usd":10.7}],"kaynak":"FAO_TM"},"ihracat_seyri":{"birim":"milyon US$ (cari)","kalem":"Crops and livestock products","seri":{"1961":1234,"1962":1322,"1963":1451,"1964":1595,"1965":1801,"1966":1819,"1967":1990,"1968":2281,"1969":2589,"1970":3100,"1971":3451,"1972":4164,"1973":5922,"1974":7027,"1975":8404,"1976":9195,"1977":10180,"1978":12088,"1979":14235,"1980":15797,"1981":15399,"1982":14916,"1983":14517,"1984":14775,"1985":14948,"1986":18980,"1987":22762,"1988":24680,"1989":26247,"1990":30616,"1991":30630,"1992":33450,"1993":29040,"1994":34690,"1995":36531,"1996":36917,"1997":31705,"1998":29924,"1999":34061,"2000":27878,"2001":27819,"2002":32514,"2003":41896,"2004":47787,"2005":50785,"2006":54891,"2007":67598,"2008":78998,"2009":74273,"2010":77260,"2011":89305,"2012":86569,"2013":90915,"2014":85286,"2015":73305,"2016":78823,"2017":95980,"2018":100117,"2019":97444,"2020":100825,"2021":113922,"2022":119850,"2023":125753},"kaynak":"FAO_TCL"},"dunya_siralamasi":{"tanim":"FAOSTAT \"Crops and livestock products\", ihracat değeri (element 5922), cari US$","kapsam":"198 ülke, beş bölge dosyasının tamamı; bölge ve grup agregaları elendi","UYARI":"Yaygın olarak tekrarlanan \"Hollanda dünyanın 2. büyük tarım ihracatçısı\" ifadesi FAOSTAT'ın BU tanımıyla 2023 için DOĞRU DEĞİL — Hollanda 3. sırada, Brezilya'nın arkasında. \"2. sıra\" iddiası genellikle WTO/Comtrade'in farklı \"tarım ürünleri\" tanımına dayanır. Metinde sıra verilirken TANIM ve YIL mutlaka yazılacak.","yillar":{"2022":{"kapsanan_ulke":198,"hollanda_sirasi":3,"turkiye_sirasi":21,"ilk_10":[{"sira":1,"ulke":"United States of America","milyon_usd":191567},{"sira":2,"ulke":"Brazil","milyon_usd":136402},{"sira":3,"ulke":"Netherlands (Kingdom of the)","milyon_usd":119850},{"sira":4,"ulke":"Germany","milyon_usd":91702},{"sira":5,"ulke":"France","milyon_usd":82254},{"sira":6,"ulke":"China, mainland","milyon_usd":66304},{"sira":7,"ulke":"Canada","milyon_usd":65260},{"sira":8,"ulke":"Spain","milyon_usd":64472},{"sira":9,"ulke":"Italy","milyon_usd":60409},{"sira":10,"ulke":"Indonesia","milyon_usd":57338}]},"2023":{"kapsanan_ulke":198,"hollanda_sirasi":3,"turkiye_sirasi":18,"ilk_10":[{"sira":1,"ulke":"United States of America","milyon_usd":170964},{"sira":2,"ulke":"Brazil","milyon_usd":146661},{"sira":3,"ulke":"Netherlands (Kingdom of the)","milyon_usd":125753},{"sira":4,"ulke":"Germany","milyon_usd":98515},{"sira":5,"ulke":"France","milyon_usd":82677},{"sira":6,"ulke":"Spain","milyon_usd":69066},{"sira":7,"ulke":"China, mainland","milyon_usd":68085},{"sira":8,"ulke":"Canada","milyon_usd":68014},{"sira":9,"ulke":"Italy","milyon_usd":64933},{"sira":10,"ulke":"Belgium","milyon_usd":60116}]}},"kaynak":"FAO_TCL"},"kurumlar":{"aciklama":"Boşluk 3 — Hollanda tarımını ayakta tutan kurumlar. Dosyanın 'nasıl' sorusunun cevabı burada: mucize iklimde değil, kurum tasarımında.","ozet_tez":"Beş kurum, beş farklı tasarım kararı: bilgiyi tek çatıda topla (WUR), fiyat mekanizmasının mülkiyetini üreticiye ver (FloraHolland), en yüksek katma değerli halkayı elde tut (tohum), üretimi coğrafi olarak sıkıştır (Greenport), araştırma parasını ortaklık şartına bağla (Topsector). Hiçbiri iklimle, toprakla veya arazi büyüklüğüyle ilgili değil. Hepsi kopyalanabilir.","liste":[{"id":"wur","ad":"Wageningen University & Research","tur":"Üniversite + araştırma enstitüsü (ikili yapı)","kurulus":1918,"neden_onemli":"Dünyanın tarım alanında 1 numaralı üniversitesi. Hollanda modelinin bilgi üretim motoru. Üniversite (WU) ile sözleşmeli araştırma vakfı (WR) tek çatı altında — akademik yayın ile saha uygulaması aynı kurumda buluşuyor.","veriler":{"calisan":{"deger":7800,"birim":"kişi","not":"Kurumun kendi tanıtım rakamı. 2023 tam zamanlı eşdeğeri (fte) 7.044."},"ogrenci":{"deger":12407,"birim":"kişi","tarih":"2025-10","detay":{"hollandali":9031,"yabanci":3376,"lisans":5175,"yuksek_lisans":6754,"hazirlik":99}},"doktora_adayi":{"deger":2440,"yil":2023},"profesor":{"deger":234,"yil":2023},"program":{"lisans":20,"yuksek_lisans":31,"mooc":49,"yil":2023},"mezun":{"deger":64117,"yil":2023},"qs_tarim_ormancilik":{"deger":1,"birim":"dünya sırası","ifade":"Wageningen University & Research excels in Agriculture & Forestry (1st globally)"},"the_genel":{"deger":67,"birim":"dünya sırası","yil":2025},"surdurulebilirlik":{"ifade":"UI GreenMetric'te 9 yıl üst üste dünya 1.'si — 'dünyanın en sürdürülebilir kampüsü'"}},"kritik_bulgu":null,"kaynak":"Wageningen University & Research — resmî 'Facts and figures' ve 'Rankings' sayfaları","kaynak_url":["https://www.wur.nl/en/about-wur/facts-figures","https://www.wur.nl/en/about-wur/facts-figures/rankings-and-scientific-awards"],"yayin_tarihi":null},{"id":"floraholland","ad":"Royal FloraHolland","tur":"Üretici kooperatifi — çiçek ve bitki müzayedesi","kurulus":1911,"neden_onemli":"Dosyanın en öğretici kurumu. Dünyanın en büyük çiçek ticaret platformu bir şirket değil, ÜRETİCİ KOOPERATİFİ. Hollanda fiyat oluşum mekanizmasının mülkiyetini üreticiye vermiş. 5,4 milyar avro içinden akıyor ama kurumun kendi cirosu 493 milyon, kârı 12 milyon — aradaki fark üreticide kalıyor.","veriler":{"urun_cirosu":{"deger":5.4,"birim":"milyar EUR","yil":2025,"onceki":{"2024":5.3},"rekor":{"yil":2021,"deger":5.6}},"kurum_cirosu":{"deger":493,"birim":"milyon EUR","yil":2025},"faaliyet_sonucu":{"deger":19,"birim":"milyon EUR","yil":2025},"net_sonuc":{"deger":12,"birim":"milyon EUR","yil":2025,"onceki":{"2024":5}},"fiyat_hacim":{"kesme_cicek_fiyat_yuzde":3,"bitki_fiyat_yuzde":1,"hacim_yuzde":-2,"yil":2025},"floriday_dijital":{"deger":75,"birim":"%","aciklama":"Alıcı yönlendirmeli bitki işlemlerinin Floriday üzerinden yapılan payı","yil":2025}},"kritik_bulgu":"Ciro/kâr oranı: 5.400 milyon avroluk ürün cirosunun yalnızca %9,1'i (493 milyon) kurumun kendi geliri, %0,2'si (12 milyon) kârı. Kooperatif modeli değeri üyede tutuyor — bu bir verimlilik değil, MÜLKİYET tasarımı meselesi.","kaynak":"NCR — Nationale Coöperatieve Raad (cooperatie.nl), Royal FloraHolland 2025 yıllık sonuçları haberi","kaynak_url":"https://www.cooperatie.nl/","yayin_tarihi":null},{"id":"uitgangsmateriaal","ad":"Tohum ve fide sektörü (uitgangsmateriaal) — Plantum çatısı altında","tur":"Sektör + meslek örgütü","kurulus":null,"neden_onemli":"Hollanda'nın gerçek ihracat ürünü domates değil, domatesin TOHUMU. Görünmez ama en yüksek katma değerli halka. Cironun %15'i, sebze ıslahçılarında %30'a kadarı Ar-Ge'ye gidiyor — bu oran ilaç sanayii seviyesinde.","veriler":{"ihracat":{"deger":5.02,"birim":"milyar EUR","yil":2024,"seyir":{"2000":1.3,"2020":3.8,"2024":5.02},"artis_2020_2024_yuzde":31},"kompozisyon_yuzde":{"sebze_tohumu":45,"cicek_sogani_ve_yumru":34,"tohumluk_patates":12,"yil":2024},"sebze_tohumu":{"ihracat_milyar_eur":2.25,"ithalat_milyon_eur":592,"ab_disi_pay_yuzde":58,"kuzey_amerika_pay_yuzde":19,"yil":2024},"ar_ge":{"ifade":"Gemiddeld wordt circa 15% van de omzet besteed aan onderzoek en ontwikkeling (R&D), oplopend tot ongeveer 30% bij groenteveredelaars","ceviri":"Ciroların ortalama %15'i Ar-Ge'ye ayrılıyor; sebze ıslahçılarında bu oran %30'a çıkıyor."},"istihdam":{"deger":14000,"birim":"kişi","seyir":{"2010":"8.000–10.000","2019":"~12.000 tam zamanlı","guncel":"14.000+"},"kaynak_ic":"Plantum tahmini"}},"kritik_bulgu":"5,02 milyar avroluk tohum/fide ihracatının %58'i AB DIŞINA gidiyor. Yani bu kalem, Hollanda'nın 'komşularına satıyor' genel örüntüsünün istisnası — ve tam da en yüksek katma değerli kalem olması bu yüzden anlamlı.","kaynak":"Agrimatie — Wageningen University & Research, 'Uitgangsmateriaal in de sector akker- en tuinbouw', Editie 2026","kaynak_url":"https://agrimatie.nl/internationalehandel/gepubliceerde-artikelen-en-rapporten/editie-2026/2026-uitgangsmateriaal/","yayin_tarihi":"2026-01-16"},{"id":"greenport","ad":"Greenports Nederland — bahçecilik kümeleri","tur":"Bölgesel küme ağı (ulusal koordinasyon)","kurulus":null,"neden_onemli":"Hollanda seracılığı dağınık işletmeler toplamı değil, coğrafi olarak sıkıştırılmış kümeler. Üretim, ticaret, teknoloji ve lojistik yan yana. 'Küme' kelimesi burada mecaz değil, fiziksel gerçek.","veriler":{"uretim_degeri":{"2020":26.8,"2024":33.3,"birim":"milyar EUR"},"katma_deger":{"2020":16.2,"2024":20.4,"birim":"milyar EUR"},"istihdam":{"2020":198000,"2024":208000,"birim":"iş yılı (arbeidsjaren)","ulusal_pay_yuzde":2.5},"zincir_ihracati":{"deger":28,"birim":"milyar EUR","yil":2024,"artis_2019_yuzde":25,"hollanda_yapimi_pay_yuzde":65},"zincir_ithalati":{"deger":11,"birim":"milyar EUR","yil":2024,"artis_2019_yuzde":15},"inovasyon_tesviki":{"deger":516,"birim":"milyon EUR","yil":2024,"arac":"WBSO Ar-Ge vergi teşviki","artis_2019_yuzde":25}},"kritik_bulgu":"Bahçecilik zinciri ihracatının %65'i Hollanda yapımı — genel tarım ihracatındaki %64,3 ile neredeyse aynı. Ama bahçecilik, tüm tarım arazisinin %0,56'sında duruyor. Yoğunluk farkı buradan okunuyor.","kaynak":"Greenports Nederland — 'Tuinbouw groeit naar ruim 33 miljard productiewaarde'; rakamlar Wageningen Social & Economic Research araştırması, CBS desteğiyle","kaynak_url":"https://www.greenports-nederland.nl/nl/tuinbouw-groeit-naar-ruim-33-miljard-productiewaarde-en-blijf-investeren-in-innovatie","yayin_tarihi":"2026-06-09"},{"id":"topsector","ad":"Topsector Tuinbouw & Uitgangsmaterialen (2026'dan itibaren: TKI T&U)","tur":"Kamu–özel araştırma finansman mekanizması","kurulus":2012,"neden_onemli":"Hollanda modelinin kurumsal kilit taşı. Devlet parayı doğrudan araştırmacıya değil, ŞİRKET–ARAŞTIRMACI ORTAKLIĞINA veriyor; şirket kendi payını koymazsa proje başlamıyor. Türkiye'ye en doğrudan aktarılabilir tasarım budur.","veriler":{"pps_2025":{"basvuru":147,"kabul":100,"kabul_orani_yuzde":68,"devlet_destegi_milyon_eur":66.5,"ozel_sektor_katkisi_milyon_eur":66.7,"toplam_yatirim_milyon_eur":133,"bakanlik_dagilimi":{"LVVN":45.2,"EZ":20.1,"IenW":1.2},"_not":"Özel sektör katkısı (66,7) devlet desteğini (66,5) AŞIYOR. Eşleştirme oranı 1:1'in biraz üzerinde."},"kia":{"ad":"Kennis- en Innovatieagenda Landbouw, Water, Voedsel","donem":"2024–2027","ortak_topsektorler":["Agri & Food","Tuinbouw & Uitgangsmaterialen","Water & Maritiem"],"bakanliklar":["LNV","VWS","I&W"]},"yapisal_degisiklik":{"tarih":"2026-01-01","aciklama":"Topsector politikası sanayi politikasına dönüştü; 'Topsector' adı kalktı, kurum TKI Tuinbouw & Uitgangsmaterialen olarak devam ediyor. PPS inovasyon desteği en az 2027 sonuna kadar yaklaşık sabit."}},"kritik_bulgu":"133 milyon avroluk toplam yatırımın yarısını özel sektör koyuyor. Devlet burada araştırmayı finanse etmiyor — özel sektörün araştırma yapmasını KÂRLI hale getiriyor. Aradaki fark, dosyanın Türkiye bölümünün ana argümanı.","kaynak":"Topsector Tuinbouw & Uitgangsmaterialen — '100 nieuwe PPS-projecten starten in 2025'","kaynak_url":"https://topsectortu.nl/nieuws/100-nieuwe-pps-projecten-starten-in-2025/","yayin_tarihi":"2025-01-15"}],"_dogrulanmamis_kalemler":[{"kurum":"Wageningen University & Research","kalemler":{"tasarruf_programi":"2027 sonuna kadar yılda 80 milyon avro tasarruf hedefi — 2024 yıllık raporundan arama sonucuyla geldi, birincil PDF'ten teyit edilmedi.","2025_geliri":"553,9 milyon avro (WU, bütçe projeksiyonu) — aynı şekilde teyit edilmedi."}},{"kurum":"Royal FloraHolland","kalemler":{"saat_hacmi":"Yıllık ~5 milyar dal/adet saat üzerinden, saat cirosu 2 milyar avronun biraz üzeri","kvv":"Doğrudan satış (KVV) 285 milyon EUR, +%10, ~%28 pay","gunluk_islem":"~100.000 işlem/gün","fsi_sertifikasyon":"2025 sonunda %78","ceo":"David van Mechelen, 2025-07-01'den beri vekâleten","_not":"Bu altı kalem yalnızca arama özetinden geldi; birincil kaynaktan teyit EDİLMEDİ. Metne girmeyecek."}},{"kurum":"Tohum ve fide sektörü (uitgangsmateriaal) — Plantum çatısı altında","kalemler":{"dunya_pazar_payi":"Plantum'a atfen 'dünya tohum pazarının ~%17'si, sebze tohumlarının %38'i'; PBL'e atfen 'dünya sebze tohumu ticaretinin ~%35'i, tohumluk patatesin ~%60'ı'. Agrimatie sayfası yüzde pay VERMİYOR; iki kaynak birbirinden farklı. Metinde pay yüzdesi kullanılmayacak, mutlak ihracat rakamı kullanılacak."}},{"kurum":"Greenports Nederland — bahçecilik kümeleri","kalemler":{"west_holland":"Greenport West-Holland: Avrupa'nın en büyük kümesi, 50.000+ istihdam, ~15 milyar EUR katma değer; Westland ~9.000 ha alanda brüt 4.500 ha cam sera, 16.000 işletme (2.000'i sera). greenportwestholland.nl WebFetch'te gövde metni döndürmedi — teyit edilemedi, metne girmeyecek."}},{"kurum":"Topsector Tuinbouw & Uitgangsmaterialen (2026'dan itibaren: TKI T&U)","kalemler":{"kumulatif":"2012'den beri 250+ araştırma/inovasyon projesi, ~400 şirket katılımı — arama özetinden geldi, birincil kaynaktan teyit edilmedi."}}],"_dogrulanmamis_kural":"Yukarıdaki liste METNE GİRMEZ. Yalnızca ileride doğrulanmak üzere kayıt altındadır.","kaynak":"KURUM"},"tarih":{"su_muhendisligi":{"sudan_kazanilan_pay":{"deger":18,"birim":"%","aciklama":"Hollanda'nın toplam yüzölçümünün sudan kazanılmış oranı","kaynak":"PBL — Planbureau voor de Leefomgeving, Atlas van de Regio","kaynak_url":"https://themasites.pbl.nl/atlas-regio/themas/water/","alinti":"In totaal is 18% van Nederland veroverd op het water"},"deniz_seviyesi_alti_pay":{"deger":26,"birim":"%","aciklama":"Hollanda'nın deniz seviyesinin altında kalan yaklaşık oranı","kaynak":"PBL, Atlas van de Regio","kaynak_url":"https://themasites.pbl.nl/atlas-regio/themas/water/","alinti":"Circa 26% van Nederland ligt onder zeeniveau"},"polder_sayisi":{"deger":3800,"birim":"adet (üzeri)","aciklama":"Alçak Hollanda'daki polder sayısı","kaynak":"PBL, Atlas van de Regio","kaynak_url":"https://themasites.pbl.nl/atlas-regio/themas/water/","alinti":"Voor de beheersing van het water omvat Laag-Nederland ruim 3.800 polders"}},"zuiderzee":{"yasa_yili":1918,"afsluitdijk":{"uzunluk_km":32,"tamamlanma_yili":1932,"son_kapanis":"28 Mayıs 1932 — Vlieter boşluğu","kaynak":"Rijkswaterstaat","kaynak_url":"https://www.rijkswaterstaat.nl/en/projects/iconic-structures/the-afsluitdijk","alinti":"The Afsluitdijk is a 32 km long dyke that separates the Wadden Sea from the IJsselmeer in the Netherlands. Built largely by hand and completed in 1932"},"toplam_kazanilan_alan_ha":165000,"toplam_kaynak":"Rijkswaterstaat — 100 jaar Zuiderzeewerken","toplam_kaynak_url":"https://www.rijkswaterstaat.nl/water/waterbeheer/bescherming-tegen-het-water/100-jaar-zuiderzeewet","toplam_alinti":"Met de aanleg van Wieringermeer (1930), Noordoostpolder (1942), oostelijk Flevoland (1957) en zuidelijk Flevoland (1968) ontstond er 165.000 ha nieuw land.","polderler":[{"ad":"Wieringermeer","yil":1930,"hektar":20000,"kaynak":"RCE — Rijksdienst voor het Cultureel Erfgoed","kaynak_url":"https://kennis.cultureelerfgoed.nl/index.php/Ontginningen_in_de_twintigste_eeuw"},{"ad":"Noordoostpolder","yil":1942,"hektar":48000,"kaynak":"RCE","kaynak_url":"https://kennis.cultureelerfgoed.nl/index.php/Ontginningen_in_de_twintigste_eeuw"},{"ad":"Oostelijk Flevoland","yil":1957,"hektar":54000,"kaynak":"Flevoland Erfgoed","kaynak_url":"https://www.flevolanderfgoed.nl/home/erfgoed/oostelijk-flevoland-2.html"},{"ad":"Zuidelijk Flevoland","yil":1968,"hektar":43000,"kaynak":"Flevoland Erfgoed","kaynak_url":"https://www.flevolanderfgoed.nl/home/erfgoed/zuidelijk-flevoland-2.html"}],"_toplama_uyarisi":"Polder alanları toplamı 165.000 ha veriyor ve Rijkswaterstaat'ın toplamıyla birebir uyuşuyor. Ancak RCE, Oostelijk+Zuidelijk Flevoland için 'birlikte 98.000 ha' diyor; Flevoland Erfgoed'un tek tek rakamları 97.000 veriyor. 1.000 ha'lık bu fark metinde tek tek rakam verilirken dikkate alınmalı — güvenli olan toplamı (165.000) kullanmaktır.","ijsselmeer_polderleri_pay":{"alan_km2":1600,"hollanda_yuzolcumu_payi":"yaklaşık %5","tarim_arazisi_payi":"yaklaşık %6","kaynak":"CBS","kaynak_url":"https://www.cbs.nl/nl-nl/achtergrond/2018/24/nieuw-land-wat-de-ijsselmeerpolders-nederland-brachten","alinti":"De totale landoppervlakte van de IJsselmeerpolders bedraagt 1 600 vierkante kilometer. Dat is bijna 5 procent van het totaal in Nederland."}},"sel_1953_ve_delta":{"tarih":"31 Ocak — 1 Şubat 1953 gecesi","can_kaybi":1836,"su_altinda_kalan_ha":150000,"kaynak":"Rijkswaterstaat","kaynak_url":"https://www.rijkswaterstaat.nl/water/waterbeheer/bescherming-tegen-het-water/watersnoodramp-1953","alinti":"De watersnoodramp kostte aan 1836 mensen het leven. Ruim 150.000 ha grond overstroomde.","delta_works":{"baslangic":1954,"bitis":1997,"son_yapi":"Maeslantkering","kaynak":"Rijkswaterstaat — Onze historie","kaynak_url":"https://www.rijkswaterstaat.nl/over-ons/onze-organisatie/onze-historie","alinti":"In 1954 gaat de bouw van het eerste Deltawerk van start en in 1997 is met de Maeslantkering het laatste werk opgeleverd.","_yapi_sayisi_uyarisi":"Rijkswaterstaat'ın iki sayfası çelişiyor: biri '13 Deltawerken', diğeri '12 waterverdedigingswerken' diyor. Metinde yapı sayısı verilmeyecek."}},"hongerwinter_1944_45":{"_neden_aralik":"Ölü sayısı için tek bir resmî rakam yok; kurumlar farklı tanımlar kullanıyor. Metinde tek sayı verilmeyecek, kaynaklar birlikte aktarılacak.","kayitlar":[{"deger":8305,"tanim":"Ölüm nedeni resmen 'açlık' kaydedilen vaka","kaynak":"NIDI (KNAW)","kaynak_url":"https://nidi.nl/demos/sterfte-door-hongerwinter-en-oorlog/"},{"deger":"20.000+","tanim":"Açlıktan ölen","kaynak":"Verzetsmuseum Amsterdam","kaynak_url":"https://www.verzetsmuseum.org/nl/kennisbank/1944-1945-hongersnood"},{"deger":"22.000+","tanim":"Batı Hollanda'da açlık ve soğuktan ölen","kaynak":"Nationaal Archief","kaynak_url":"https://www.nationaalarchief.nl/onderzoeken/nieuws/de-laatste-oorlogsmaanden-hongersnood-in-nederland","alinti":"in het laatste oorlogsjaar sterven in het westen van Nederland meer dan 22.000 mensen door honger en kou"},{"deger":"15.000–25.000","tanim":"Tahmin aralığı","kaynak":"tweedewereldoorlog.nl (NIOD + Nationaal Comité 4 en 5 mei)","kaynak_url":"https://www.tweedewereldoorlog.nl/75-jaar-vrijheid/kaartvanbevrijding/hongerwinter/"}],"nidi_ek":{"asiri_olum_eylul1944_mayis1945":56000,"hongerwinter_bolgesi_payi":"%38","kaynak_url":"https://nidi.nl/demos/sterfte-door-hongerwinter-en-oorlog/"}},"wageningen":{"tarim_okulu_devletlestirme":1876,"yuksekogretim_statusu":"9 Mart 1918","kaynak":"Wageningen University & Research — resmî tarihçe","kaynak_url":"https://www.wur.nl/en/about-wur/facts-and-figures-1/history-of-wageningen-university-research.htm","alinti_1876":"The state takes over the local council's Agricultural College in Wageningen: the start of National Agricultural Education in The Netherlands","alinti_1918":"Wageningen's status as an institute of higher education is legally ratified, and it becomes the National Agricultural College on 9 March 1918"},"mansholt":{"plan_tarihi":"21 Aralık 1968","plan_adi":"Agriculture 1980 / Mansholt Planı","belge_kunyesi":"Bulletin of the European Communities, Supplement 1/1969 — Office for Official Publications of the European Communities","kaynak":"CVCE / Université du Luxembourg","kaynak_url":"https://www.cvce.eu/en/obj/memorandum_on_agricultural_reform_in_the_european_economic_community_21_december_1968-en-aeeba4d9-1971-4e34-ae1c-ae90fc32c6ee.html","alinti":"On 21 December 1968, the European Commission submits to the Council a memorandum on agricultural reform. This is the Agriculture 1980 plan, also known as the Mansholt Plan","tarim_komiseri_baslangic":1958,"tarim_komiseri_kaynak":"Avrupa Birliği resmî portalı — EU pioneers","tarim_komiseri_kaynak_url":"https://european-union.europa.eu/principles-countries-history/history-eu/eu-pioneers/sicco-mansholt_en","tarim_komiseri_alinti":"he became Commissioner for Agriculture in the very first European Commission in 1958.","komisyon_baskanligi":"22 Mart 1972 — 5 Ocak 1973","komisyon_baskanligi_kaynak":"European Commission Library — History of the European Commission","komisyon_baskanligi_kaynak_url":"https://ec-europa-eu.libguides.com/ec-history/mansholt/ec-composition","ortak_pazar_plani_yili":1950},"_giris_yontemi":"Her kalem, adı geçen kurumun kendi sayfası WebFetch ile AÇILARAK doğrulandı. Hafızadan yazılan hiçbir tarih veya rakam yok.","_dogrulama_tarihi":"2026-08-15","_dogrulanmamis_kalemler":[{"kalem":"Hongerwinter'de etkilenen nüfus (4,5 veya 4,3 milyon)","not":"Hiçbir resmî kurum sayfasında bulunamadı."},{"kalem":"Mansholt Planı'nın '5 milyon çiftçi / 5 milyon hektar' hedefleri","not":"CVCE sayfasında geçmiyor, PDF açılamadı."},{"kalem":"Mansholt'un Tarım Komiserliğinin bitiş tarihi","not":"Yalnızca Komisyon Başkanlığının başlangıcı (22 Mart 1972) resmî kaynakta var."},{"kalem":"1953 selinin İngiltere/Belçika/deniz can kayıpları","not":"Rijkswaterstaat sayfasında yok."},{"kalem":"'Hollanda'nın %20'si / 7.150 km² sudan kazanıldı'","not":"Yalnızca Wikipedia'da. PBL'nin %18'i kullanılacak."},{"kalem":"NIOD'un kendi Hongerwinter rakamları","not":"Sayfa 5 denemede de HTTP 429 verdi."},{"kalem":"Delta Works'teki yapı sayısı","not":"Rijkswaterstaat kendi içinde 12 ve 13 diye çelişiyor."}],"_dogrulanmamis_kural":"Yukarıdaki liste METNE GİRMEZ. Yalnızca ileride doğrulanmak üzere kayıt altındadır."},"cevre":{"hayvan_sayilari":{"_kaynak":"CBS — Landbouwtelling / StatLine","_yil":2025,"domuz":{"deger":9960000,"degisim":"-%5,1 (2024'e göre)","not":"1979'dan bu yana ilk kez 10 milyonun altında","kaynak_url":"https://www.cbs.nl/nl-nl/nieuws/2025/28/minder-varkens-en-runderen-in-2025"},"sigir":{"deger":3650000,"degisim":"-%3,3"},"sut_inegi":{"deger":1530000},"etlik_pilic":{"deger":35100000},"yumurta_tavugu":{"deger":31800000},"_kumes_uyarisi":"CBS'in iki ayrı kümes serisi birbiriyle UYUŞMUYOR: Landbouwtelling boş kümes düzeltmesiyle ~67 milyon verirken StatLine 84952 ~100 milyon veriyor. Metinde toplam kümes hayvanı sayısı VERİLMEYECEK; yalnızca etlik piliç ve yumurta tavuğu ayrı ayrı anılabilir."},"amonyak":{"toplam_kg":116000000,"yil":2023,"tarim_payi":"yaklaşık %90","tarim_ici_dagilim":{"sigir":"%55","domuz":"%15","kumes":"%11"},"kaynak":"CBS","_birim_uyarisi":"Rakam kg NH3'tür, kg N değil. İkisi karıştırılmayacak."},"azot_cokelmesi":{"tarim_arazisi_1990_kg":75000000,"tarim_arazisi_2024_kg":34000000,"azalma":"%55","hollanda_tariminin_payi":"%56","_pay_uyarisi":"Bu %56, TARIM ARAZİSİNE düşen çökelmenin payıdır — Natura 2000 alanlarının payı DEĞİLDİR. İkisi metinde karıştırılmayacak.","net_ihrac":"Hollanda, aldığından yaklaşık 4 kat fazla azotu komşu ülkelere gönderiyor","kaynak":"CBS"},"pas_karari":{"tarih":"29 Mayıs 2019","mahkeme":"Raad van State (Danıştay)","konu":"Programma Aanpak Stikstof (PAS) — 'önce izin ver, sonra telafi et' yaklaşımı AB Habitat Direktifi'ne aykırı bulundu","_ecli_uyarisi":"Kararın ECLI numarası doğrulanamadı; metinde numara verilmeyecek."},"gubre_tavanlari":{"yil":2024,"azot":{"uretilen_kg":440000000,"tavan_kg":440000000,"durum":"tam tavanda"},"fosfat":{"uretilen_kg":142000000,"tavan_kg":135000000,"durum":"tavan aşıldı"},"kaynak":"CBS"},"cikis_semalari":{"lbv_butce_eur":1102000000,"lbv_plus_butce_eur":1820000000,"toplam_eur":2922000000,"basvuru":1576,"onaylanan":1438,"tamamlanan":243,"rvo_uyarisi":"RVO açıkça belirtiyor: onay, kapanışın gerçekleştiği anlamına gelmiyor.","kaynak":"Rijksoverheid / RVO"},"siyaset":{"bbb_eerste_kamer":{"sandalye":16,"toplam":75,"not":"en büyük grup","kaynak":"Kiesraad"},"_uyari":"BBB'nin eyalet meclislerindeki sandalye sayısı DOĞRULANAMADI — yazılmayacak."},"ab_derogasyonu":{"karar":"Decision (EU) 2022/2069","karar_tarihi":"30 Eylül 2022","bitis":"31 Aralık 2025","sonuc":"2026'dan itibaren genel sınır: 170 kg N/ha","kaynak":"Avrupa Komisyonu"},"sera_enerjisi":{"dogalgaz_m3":3900000000,"yil":2021,"hata_payi":"±%4","kaynak":"CBS","_uyari":"WUR Enerji Monitörü PDF'indeki rakamlar açılamadı; yalnızca CBS'in bu kalemi kullanılacak."},"_giris_yontemi":"Her kalem, adı geçen kurumun kendi sayfası açılarak doğrulandı. Hafızadan yazılan hiçbir rakam yok.","_dogrulama_tarihi":"2026-08-16","_dogrulanmamis_kalemler":[{"kalem":"BBB'nin eyalet meclisi sandalye sayıları","not":"Kiesraad sayfasında bulunamadı."},{"kalem":"WUR Enerji Monitörü'ndeki sera enerji rakamları","not":"PDF açılamadı."},{"kalem":"PAS kararının ECLI numarası","not":"Doğrulanamadı."},{"kalem":"Natura 2000 alanlarında kritik yük aşım yüzdesi","not":"Tek bir resmî güncel rakam bulunamadı."},{"kalem":"Toplam kümes hayvanı sayısı","not":"CBS'in iki serisi ~67M ve ~100M diye çelişiyor."},{"kalem":"Hedeflenen çiftlik kapatma sayısı / '3.000 çiftlik' türü rakamlar","not":"Resmî kaynakta bulunamadı."}],"_dogrulanmamis_kural":"Yukarıdaki liste METNE GİRMEZ. Yalnızca ileride doğrulanmak üzere kayıt altındadır."},"bosluklar":[{"konu":"Hollanda ürün bazlı üretim değeri","konu_en":"Dutch production value by commodity","sorun":"FAOSTAT QV'de Hollanda için ürün bazlı seri 2017'de kesiliyor (59 kalem). Türkiye 2023'e gidiyor.","sorun_en":"In FAOSTAT QV the Dutch commodity-level series stops in 2017 (59 items). The Turkish series runs to 2023.","cozum":"Ürün bazlı önem sıralaması üretim DEĞERİ ile değil, üretim MİKTARI (2024) ve TİCARET DEĞERİ (2023-24) ile kurulacak. 2017 rakamı güncelmiş gibi sunulmayacak.","cozum_en":"Commodity ranking is built from production VOLUME (2024) and TRADE VALUE (2023–24), not production value. The 2017 figure is never presented as current."},{"konu":"Sera alanı","konu_en":"Greenhouse area","sorun":"FAOSTAT ve Dünya Bankası sera alanı yayımlamıyor.","sorun_en":"Neither FAOSTAT nor the World Bank publishes greenhouse area.","cozum":"CBS StatLine tablo 81302ned'den 16 alan çekildi (`_raw/cbs_fetch.mjs`). FAOSTAT domates hasat alanıyla birebir çapraz doğrulandı (1.770 ha = 1.770 ha).","cozum_en":"16 fields were pulled from CBS StatLine table 81302ned (`_raw/cbs_fetch.mjs`) and cross-checked exactly against the FAOSTAT tomato harvested area (1,770 ha = 1,770 ha).","durum":"KAPANDI"},{"konu":"Yeniden ihracat payı","konu_en":"Share of re-exports","sorun":"FAOSTAT ihracatı brüt akış olarak verir; Hollanda ihracatının bir kısmı yeniden ihracattır (kendi üretimi değil). Bu ayrımı FAOSTAT yapmaz.","sorun_en":"FAOSTAT reports exports as gross flows; part of Dutch exports is re-export rather than domestic output, and FAOSTAT does not separate the two.","cozum":"CBS + Wageningen SER'in 2026-01-16 tarihli ortak yayınından alındı ve cbs.nl'den doğrulandı: 137,5 milyar EUR'nun 49,1'i yeniden ihracat, ama kazancın yalnızca 5,7/49,0'ı. Seri EUR cinsinden; FAOSTAT'ın USD serisiyle KARIŞTIRILMAYACAK.","cozum_en":"Taken from the joint CBS + Wageningen SER release of 16 Jan 2026 and verified on cbs.nl: of EUR 137.5 bn, 49.1 is re-export, yet it yields only 5.7 of 49.0 in earnings. This series is in EUR and is never mixed with the FAOSTAT USD series.","durum":"KAPANDI"},{"konu":"Dünya sıralaması","konu_en":"World ranking","sorun":"\"Dünyanın 2. büyük tarım ihracatçısı\" ifadesi çok tekrarlanıyor ama yıl ve tanım belirtilmeden kullanılıyor.","sorun_en":"The claim \"world's second-largest agricultural exporter\" is repeated everywhere, always without a year or a definition.","cozum":"198 ülke için sıralama hesaplandı. FAOSTAT tanımıyla Hollanda 2023 ve 2022'de 3. sırada (ABD ve Brezilya'nın arkasında). Metinde \"2.\" denmeyecek; sıra verilirken tanım ve yıl yazılacak.","cozum_en":"The ranking was computed for 198 countries. On the FAOSTAT definition the Netherlands is 3rd in both 2023 and 2022, behind the USA and Brazil. The text never says \"2nd\"; every rank is given with its definition and year.","durum":"KAPANDI"},{"konu":"Kurumlar (WUR, FloraHolland, ıslah, Greenport, Topsector)","konu_en":"Institutions (WUR, FloraHolland, plant breeding, Greenport, Topsector)","sorun":"Sayısal veri değil kurumsal bilgi; API yok.","sorun_en":"Institutional rather than numerical information; no API exists.","cozum":"Beş kurum kendi resmî yayınlarından tek tek doğrulandı (`_raw/kurumlar.json`). Teyit edilemeyen kalemler ayrı bir \"dogrulanmamis\" bloğuna alındı ve metne girmeyecek.","cozum_en":"All five institutions were verified one by one against their own official publications (`_raw/kurumlar.json`). Items that could not be confirmed were quarantined in a separate \"unverified\" block and kept out of the text.","durum":"KAPANDI","_kalan_belirsizlik":"Royal FloraHolland kendi sitesi 403 döndürdüğü için rakamlar çatı örgütü NCR üzerinden alındı. Greenport West-Holland bölgesel rakamları teyit edilemedi.","_kalan_belirsizlik_en":"Royal FloraHolland's own site returns 403, so its figures come via the umbrella body NCR. Greenport West-Holland regional figures could not be confirmed."}]}$dsr$::jsonb,
  $dsr${"tez_ikili":{"tur":"ikili_cubuk","baslik":{"tr":"Az üreten, çok satan","en":"Produces less, sells more"},"seriler":[{"ad":{"tr":"Hollanda","en":"Netherlands"},"rol":"vurgu"},{"ad":{"tr":"Türkiye","en":"Türkiye"},"rol":"ikincil"}],"satirlar":[{"etiket":{"tr":"Tarımsal üretim değeri","en":"Agricultural production value"},"birim":{"tr":"milyon I$ (sabit 2014-16)","en":"million I$ (constant 2014-16)"},"yil":2023,"ondalik":0,"degerler":[17789,79879]},{"etiket":{"tr":"Tarımsal ihracat","en":"Agricultural exports"},"birim":{"tr":"milyon US$ (cari)","en":"million US$ (current)"},"yil":2023,"ondalik":0,"degerler":[125753,29502]}],"not":{"tr":"İki satır kendi içinde karşılaştırılır, birbiriyle oranlanmaz: üstteki sabit uluslararası dolar, alttaki cari ABD doları cinsindendir.","en":"Each row compares within itself only. The two rows are not ratios of one another: the top is in constant international dollars, the bottom in current US dollars."},"kaynak":"FAOSTAT — Value of Agricultural Production (QV) · Crops and livestock products, trade (TCL)"},"makro_ikili":{"tur":"ikili_cubuk","baslik":{"tr":"İki ekonomide tarımın yeri","en":"Where agriculture sits in each economy"},"seriler":[{"ad":{"tr":"Hollanda","en":"Netherlands"},"rol":"vurgu"},{"ad":{"tr":"Türkiye","en":"Türkiye"},"rol":"ikincil"}],"satirlar":[{"etiket":{"tr":"Tarımın GSYH içindeki payı","en":"Agriculture, share of GDP"},"birim":{"tr":"%","en":"%"},"yil":2025,"ondalik":1,"degerler":[1.68323077210041,5.20951196750004]},{"etiket":{"tr":"Tarımsal katma değer","en":"Agricultural value added"},"birim":{"tr":"milyar cari US$","en":"bn current US$"},"yil":2025,"ondalik":1,"bolen":1000000000,"degerler":[22433555223.9215,83211181935.7741]},{"etiket":{"tr":"Tarımda istihdam payı","en":"Employment in agriculture"},"birim":{"tr":"%","en":"%"},"yil":2025,"ondalik":1,"degerler":[1.70416434849209,14.2199829949572]},{"etiket":{"tr":"Nüfus","en":"Population"},"birim":{"tr":"milyon kişi","en":"million people"},"yil":2025,"ondalik":1,"bolen":1000000,"degerler":[18087633,85878556]},{"etiket":{"tr":"Kırsal nüfus payı","en":"Rural population share"},"birim":{"tr":"%","en":"%"},"yil":2025,"ondalik":1,"degerler":[4.06140965188089,10.505939997814]},{"etiket":{"tr":"GSYH","en":"GDP"},"birim":{"tr":"milyar cari US$","en":"bn current US$"},"yil":2025,"ondalik":0,"bolen":1000000000,"degerler":[1332767651100.39,1597293229287]},{"etiket":{"tr":"Kişi başına GSYH","en":"GDP per capita"},"birim":{"tr":"cari US$","en":"current US$"},"yil":2025,"ondalik":0,"degerler":[73683.917132794,18599.4420922378]}],"kaynak":"World Bank — World Development Indicators"},"toprak_ikili":{"tur":"ikili_cubuk","baslik":{"tr":"Toprak ve su","en":"Land and water"},"seriler":[{"ad":{"tr":"Hollanda","en":"Netherlands"},"rol":"vurgu"},{"ad":{"tr":"Türkiye","en":"Türkiye"},"rol":"ikincil"}],"satirlar":[{"etiket":{"tr":"Kara alanı","en":"Land area"},"birim":{"tr":"bin km²","en":"thousand km²"},"yil":2023,"ondalik":1,"bolen":1000,"degerler":[33670,769630]},{"etiket":{"tr":"Tarım arazisi","en":"Agricultural land"},"birim":{"tr":"bin km²","en":"thousand km²"},"yil":2023,"ondalik":1,"bolen":1000,"degerler":[18030,385880]},{"etiket":{"tr":"Tarım arazisinin kara alanına oranı","en":"Agricultural land, share of land area"},"birim":{"tr":"%","en":"%"},"yil":2023,"ondalik":1,"degerler":[53.5491535491536,50.1383781817237]},{"etiket":{"tr":"İşlenebilir arazi","en":"Arable land"},"birim":{"tr":"milyon hektar","en":"million hectares"},"yil":2023,"ondalik":2,"bolen":1000000,"degerler":[1009000,20277000]},{"etiket":{"tr":"Kişi başına işlenebilir arazi","en":"Arable land per person"},"birim":{"tr":"hektar","en":"hectares"},"yil":2023,"ondalik":3,"degerler":[0.056440867954268,0.237641613546357]},{"etiket":{"tr":"Sulanan arazi payı","en":"Irrigated land share"},"birim":{"tr":"%","en":"%"},"yil":2023,"ondalik":1,"degerler":[21.5751525235718,12.4676065097958]},{"etiket":{"tr":"Tarımın tatlı su çekimindeki payı","en":"Agriculture, share of freshwater withdrawal"},"birim":{"tr":"%","en":"%"},"yil":2022,"ondalik":1,"degerler":[3.219295516,86.92701174]},{"etiket":{"tr":"Gübre tüketimi","en":"Fertilizer consumption"},"birim":{"tr":"kg/ha (işlenebilir arazi)","en":"kg per ha of arable land"},"yil":2023,"ondalik":0,"degerler":[238.01982160555,139.557478917]}],"kaynak":"World Bank — World Development Indicators"},"verim_ortualti":{"tur":"ikili_cubuk","baslik":{"tr":"Cam altında: 5–12 kat","en":"Under glass: 5–12 fold"},"seriler":[{"ad":{"tr":"Hollanda","en":"Netherlands"},"rol":"vurgu"},{"ad":{"tr":"Türkiye","en":"Türkiye"},"rol":"ikincil"}],"satirlar":[{"etiket":{"tr":"Salatalık","en":"Cucumber"},"birim":{"tr":"t/ha","en":"t/ha"},"yil":2023,"ondalik":1,"degerler":[635.9,53.1],"rozet":{"tr":"12 kat","en":"12×"}},{"etiket":{"tr":"Domates","en":"Tomato"},"birim":{"tr":"t/ha","en":"t/ha"},"yil":2023,"ondalik":1,"degerler":[410.2,80],"rozet":{"tr":"5,1 kat","en":"5.1×"}},{"etiket":{"tr":"Biber","en":"Pepper"},"birim":{"tr":"t/ha","en":"t/ha"},"yil":2023,"ondalik":1,"degerler":[269.2,40.4],"rozet":{"tr":"6,7 kat","en":"6.7×"}}],"kaynak":"FAOSTAT — Crops and livestock products (QCL), element 5412 Yield"},"verim_acik_tarla":{"tur":"ikili_cubuk","baslik":{"tr":"Açık tarlada: fark küçülüyor","en":"In the open field: the gap narrows"},"seriler":[{"ad":{"tr":"Hollanda","en":"Netherlands"},"rol":"vurgu"},{"ad":{"tr":"Türkiye","en":"Türkiye"},"rol":"ikincil"}],"satirlar":[{"etiket":{"tr":"Patates","en":"Potato"},"birim":{"tr":"t/ha","en":"t/ha"},"yil":2023,"ondalik":1,"degerler":[41.8,37.8],"rozet":{"tr":"1,1 kat","en":"1.1×"}},{"etiket":{"tr":"Kuru soğan","en":"Dry onion"},"birim":{"tr":"t/ha","en":"t/ha"},"yil":2023,"ondalik":1,"degerler":[45.9,43],"rozet":{"tr":"1,1 kat","en":"1.1×"}},{"etiket":{"tr":"Buğday","en":"Wheat"},"birim":{"tr":"t/ha","en":"t/ha"},"yil":2023,"ondalik":1,"degerler":[8.5,3.2],"rozet":{"tr":"2,6 kat","en":"2.6×"}},{"etiket":{"tr":"Arpa","en":"Barley"},"birim":{"tr":"t/ha","en":"t/ha"},"yil":2023,"ondalik":1,"degerler":[6.5,2.8],"rozet":{"tr":"2,3 kat","en":"2.3×"}},{"etiket":{"tr":"Şeker pancarı","en":"Sugar beet"},"birim":{"tr":"t/ha","en":"t/ha"},"yil":2023,"ondalik":1,"degerler":[86.3,69.4],"rozet":{"tr":"1,2 kat","en":"1.2×"}}],"kaynak":"FAOSTAT — Crops and livestock products (QCL), element 5412 Yield"},"sera_kunye":{"tur":"kunye","baslik":{"tr":"Mucizenin gerçek boyutu","en":"The actual size of the miracle"},"kalemler":[{"deger":0.56,"ondalik":2,"onek":{"tr":"%","en":""},"sonek":{"tr":"","en":"%"},"etiket":{"tr":"Tarım arazisinin örtüaltı payı","en":"Share of farmland under cover"},"alt":{"tr":"2025","en":"2025"}},{"deger":10030,"ondalik":0,"sonek":{"tr":" ha","en":" ha"},"etiket":{"tr":"Örtüaltı toplam alan","en":"Total area under cover"},"alt":{"tr":"2025","en":"2025"}},{"deger":-4.7,"ondalik":1,"onek":{"tr":"%","en":""},"sonek":{"tr":"","en":"%"},"etiket":{"tr":"Sera alanının değişimi","en":"Change in area under glass"},"alt":{"tr":"2000 → 2025","en":"2000 → 2025"}},{"deger":-50.1,"ondalik":1,"onek":{"tr":"%","en":""},"sonek":{"tr":"","en":"%"},"etiket":{"tr":"İşletme sayısının değişimi","en":"Change in number of holdings"},"alt":{"tr":"2000 → 2026","en":"2000 → 2026"}},{"deger":3.31,"ondalik":2,"sonek":{"tr":" ha","en":" ha"},"etiket":{"tr":"Ortalama sera büyüklüğü","en":"Average greenhouse size"},"alt":{"tr":"2026","en":"2026"}}],"not":{"tr":"Alan küçüldü, işletme sayısı yarıya indi, ortalama işletme büyüdü. Bu bir yayılma değil, yoğunlaşma.","en":"The area shrank, the number of holdings halved, the average holding grew. This is not expansion; it is concentration."},"kaynak":"CBS — Landbouwtelling / StatLine"},"sera_urunler":{"tur":"siralama","baslik":{"tr":"Cam altında ne var","en":"What is under the glass"},"birim":{"tr":"hektar","en":"hectares"},"ondalik":0,"satirlar":[{"etiket":{"tr":"Domates","en":"Tomato"},"deger":1770,"rol":"vurgu"},{"etiket":{"tr":"Biber","en":"Pepper"},"deger":1580,"rol":"vurgu"},{"etiket":{"tr":"Saksı bitkisi","en":"Pot plants"},"deger":1730,"rol":"ikincil"},{"etiket":{"tr":"Kesme çiçek","en":"Cut flowers"},"deger":1710,"rol":"ikincil"},{"etiket":{"tr":"Salatalık","en":"Cucumber"},"deger":630,"rol":"vurgu"},{"etiket":{"tr":"Krizantem","en":"Chrysanthemum"},"deger":470,"rol":"ikincil"},{"etiket":{"tr":"Gül","en":"Rose"},"deger":140,"rol":"ikincil"},{"etiket":{"tr":"Patlıcan","en":"Aubergine"},"deger":110,"rol":"vurgu"},{"etiket":{"tr":"Orkide","en":"Orchid"},"deger":80,"rol":"ikincil"},{"etiket":{"tr":"Lale","en":"Tulip"},"deger":0,"rol":"sessiz"}],"not":{"tr":"Cam altında lale yok. Lale tarlada yetişir; ülkenin simgesi ile ülkenin tarım motoru aynı şey değil.","en":"There are no tulips under glass. Tulips grow in open fields: the country's emblem and the country's agricultural engine are not the same thing."},"kaynak":"CBS — Landbouwtelling 2025"},"ihracat_yigin":{"tur":"yigin","baslik":{"tr":"Manşet ile kazanç aynı şey değil","en":"The headline and the earnings are not the same"},"cubuklar":[{"etiket":{"tr":"Ciro — 137,5 milyar €","en":"Turnover — €137.5 bn"},"dilimler":[{"ad":{"tr":"Hollanda yapımı","en":"Dutch-made"},"deger":88.4,"rol":"vurgu"},{"ad":{"tr":"Yeniden ihracat","en":"Re-export"},"deger":49.1,"rol":"sessiz"}]},{"etiket":{"tr":"Kazanç — 49 milyar €","en":"Earnings — €49 bn"},"dilimler":[{"ad":{"tr":"Hollanda yapımı","en":"Dutch-made"},"deger":43.5,"rol":"vurgu"},{"ad":{"tr":"Yeniden ihracat","en":"Re-export"},"deger":5.7,"rol":"sessiz"}]}],"not":{"tr":"Yeniden ihracat cironun %35,7'si, kazancın yalnızca %11,6'sı. Bu düzeltmeyi yapan, Hollanda'nın kendi istatistik kurumudur.","en":"Re-export is 35.7% of turnover but only 11.6% of earnings. This correction comes from the Dutch statistical office itself."},"kaynak":"CBS — Landbouwexport 2025 (milyar EUR)"},"ilk_10_pazar":{"tur":"siralama","baslik":{"tr":"Nereye satıyor","en":"Where it sells"},"birim":{"tr":"milyar €","en":"€ bn"},"ondalik":1,"satirlar":[{"etiket":{"tr":"Almanya","en":"Germany"},"deger":34,"rol":"vurgu"},{"etiket":{"tr":"Belçika","en":"Belgium"},"deger":16.9,"rol":"vurgu"},{"etiket":{"tr":"Fransa","en":"France"},"deger":11.4,"rol":"vurgu"},{"etiket":{"tr":"Birleşik Krallık","en":"United Kingdom"},"deger":9.8,"rol":"sessiz"},{"etiket":{"tr":"İspanya","en":"Spain"},"deger":5.7,"rol":"vurgu"},{"etiket":{"tr":"İtalya","en":"Italy"},"deger":5.6,"rol":"vurgu"},{"etiket":{"tr":"Polonya","en":"Poland"},"deger":5.2,"rol":"vurgu"},{"etiket":{"tr":"ABD","en":"United States"},"deger":3.8,"rol":"sessiz"},{"etiket":{"tr":"İsveç","en":"Sweden"},"deger":3.1,"rol":"vurgu"},{"etiket":{"tr":"Çin","en":"China"},"deger":3,"rol":"sessiz"}],"not":{"tr":"Turuncu olanlar AB üyesi. İlk on pazarın yedisi AB içinde; Türkiye listede yok. 'Küresel dev' tanımı bu tabloyla sınırlanmalı.","en":"Orange bars are EU members. Seven of the top ten markets are inside the EU; Türkiye is not on the list. The 'global giant' label has to be read against this."},"kaynak":"CBS — Landbouwexport 2025"},"kakao_ikili":{"tur":"ikili_cubuk","baslik":{"tr":"Tek bir kakao ağacı olmadan","en":"Without a single cocoa tree"},"seriler":[{"ad":{"tr":"İthalat","en":"Imports"},"rol":"ikincil"},{"ad":{"tr":"İhracat","en":"Exports"},"rol":"vurgu"}],"satirlar":[{"etiket":{"tr":"Kakao çekirdeği","en":"Cocoa beans"},"birim":{"tr":"milyon US$","en":"million US$"},"yil":2023,"ondalik":0,"degerler":[2399,594]},{"etiket":{"tr":"Kakao yağı","en":"Cocoa butter, fat and oil"},"birim":{"tr":"milyon US$","en":"million US$"},"yil":2023,"ondalik":0,"degerler":[505,1624]},{"etiket":{"tr":"Kakao ezmesi","en":"Cocoa paste"},"birim":{"tr":"milyon US$","en":"million US$"},"yil":2023,"ondalik":0,"degerler":[399,980]},{"etiket":{"tr":"Kakao tozu ve küspesi","en":"Cocoa powder and cake"},"birim":{"tr":"milyon US$","en":"million US$"},"yil":2023,"ondalik":0,"degerler":[359,1034]}],"not":{"tr":"Çekirdekte ithalatçı, dört üründe de ihracatçı. Aradaki fark öğütme tesisinin kendisi — dosyanın tezinin en temiz örneği.","en":"An importer of beans, an exporter of everything made from them. The difference is the grinding plant itself: the cleanest illustration of this dossier's thesis."},"kaynak":"FAOSTAT — Trade: Crops and livestock products (TCL), 2023"},"tarih_cizelge":{"tur":"zaman_cizelgesi","baslik":{"tr":"Sistem ne zaman kuruldu","en":"When the system was built"},"olaylar":[{"yil":1876,"baslik":{"tr":"Devlet, Wageningen'deki tarım okulunu devralır","en":"The state takes over the agricultural college at Wageningen"},"aciklama":{"tr":"Hollanda'da ulusal tarım eğitiminin başlangıcı.","en":"The start of national agricultural education in the Netherlands."}},{"yil":1918,"baslik":{"tr":"Wageningen yükseköğretim statüsü kazanır","en":"Wageningen gains higher-education status"},"aciklama":{"tr":"9 Mart 1918. Bilgi üretimi bir devlet işi olarak kurumsallaşıyor.","en":"9 March 1918. Knowledge production is institutionalised as a state function."}},{"yil":1918,"baslik":{"tr":"Zuiderzee Yasası","en":"The Zuiderzee Act"},"aciklama":{"tr":"Aynı yıl: bir iç denizin kapatılıp toprağa çevrilmesi yasayla kararlaştırılıyor.","en":"The same year: closing off an inland sea and turning it into land is written into law."}},{"yil":1932,"baslik":{"tr":"Afsluitdijk tamamlanır","en":"The Afsluitdijk is completed"},"aciklama":{"tr":"32 km'lik set, büyük ölçüde elle inşa edildi. Zuiderzee polderleri toplam 165.000 hektar yeni toprak verdi.","en":"A 32 km dyke, built largely by hand. The Zuiderzee polders yielded 165,000 hectares of new land in total."}},{"yil":1944,"yil_ek":{"tr":"–45","en":"–45"},"baslik":{"tr":"Hongerwinter","en":"The Hunger Winter"},"aciklama":{"tr":"Ölüm nedeni resmen 'açlık' kaydedilen 8.305 vaka (NIDI). Kurumlar farklı tanımlar kullandığı için tek bir resmî rakam yok.","en":"8,305 deaths officially recorded as caused by starvation (NIDI). There is no single official figure: institutions use different definitions."}},{"yil":1953,"baslik":{"tr":"Sel felaketi","en":"The North Sea flood"},"aciklama":{"tr":"31 Ocak – 1 Şubat gecesi: 1.836 can kaybı, 150.000 hektar su altında.","en":"The night of 31 January – 1 February: 1,836 lives lost, 150,000 hectares flooded."}},{"yil":1954,"yil_ek":{"tr":"–1997","en":"–1997"},"baslik":{"tr":"Delta Çalışmaları","en":"The Delta Works"},"aciklama":{"tr":"Kırk üç yıl süren savunma programı; son yapı Maeslantkering.","en":"A forty-three-year defence programme; the last structure was the Maeslantkering."}},{"yil":1968,"baslik":{"tr":"Mansholt Planı","en":"The Mansholt Plan"},"aciklama":{"tr":"21 Aralık 1968. Hollandalı tarım komiseri, Avrupa tarımının yeniden yapılandırılmasını önerir: daha az ve daha büyük işletme.","en":"21 December 1968. The Dutch agriculture commissioner proposes restructuring European farming: fewer and larger holdings."}}],"kaynak":"PBL · Rijkswaterstaat · RCE · NIDI · WUR · CVCE"},"kurumlar_kartlar":{"tur":"kartlar","baslik":{"tr":"Beş kurum, beş tasarım kararı","en":"Five institutions, five design decisions"},"kartlar":[{"ust":{"tr":"Üniversite + araştırma enstitüsü · 1918","en":"University + research institute · 1918"},"baslik":{"tr":"Wageningen University & Research","en":"Wageningen University & Research"},"govde":{"tr":"Akademik yayın ile saha uygulaması aynı çatı altında: üniversite (WU) ve sözleşmeli araştırma vakfı (WR) tek kurum. Bilgi üretimi ile bilginin kullanımı arasındaki mesafe kurumsal olarak kaldırılmış.","en":"Academic publishing and field application under one roof: the university (WU) and the contract-research foundation (WR) are a single institution. The distance between producing knowledge and using it has been removed by design."},"rakam":{"deger":1,"ondalik":0,"onek":{"tr":"","en":""},"sonek":{"tr":".","en":"st"},"etiket":{"tr":"dünyada — QS, Tarım ve Ormancılık","en":"worldwide — QS, Agriculture & Forestry"}}},{"ust":{"tr":"Üretici kooperatifi · 1911","en":"Growers' cooperative · 1911"},"baslik":{"tr":"Royal FloraHolland","en":"Royal FloraHolland"},"govde":{"tr":"Dünyanın en büyük çiçek ticaret platformu bir şirket değil, üretici kooperatifi. İçinden 5,4 milyar avro akıyor; kurumun kendi cirosu 493 milyon, net kârı 12 milyon. Fiyat oluşum mekanizmasının mülkiyeti üreticide.","en":"The world's largest flower trading platform is not a company but a growers' cooperative. €5.4 bn flows through it; the institution's own turnover is €493 m and its net result €12 m. Ownership of the price-formation mechanism sits with the growers."},"rakam":{"deger":5.4,"ondalik":1,"sonek":{"tr":" milyar €","en":"bn €"},"etiket":{"tr":"içinden akan ürün cirosu (2025)","en":"product turnover flowing through (2025)"}}},{"ust":{"tr":"Sektör + meslek örgütü","en":"Sector + trade association"},"baslik":{"tr":"Tohum ve fide (uitgangsmateriaal)","en":"Seed and propagating material (uitgangsmateriaal)"},"govde":{"tr":"Hollanda'nın asıl ihracat ürünü domates değil, domatesin tohumu. Cironun ortalama %15'i, sebze ıslahçılarında %30'a kadarı Ar-Ge'ye gidiyor — ilaç sanayii seviyesinde bir oran. Bu kalemin %58'i AB dışına satılıyor.","en":"The real Dutch export is not the tomato but the tomato's seed. On average 15% of turnover goes to R&D, rising to about 30% among vegetable breeders — a pharmaceutical-industry ratio. And 58% of this line is sold outside the EU."},"rakam":{"deger":5.02,"ondalik":2,"sonek":{"tr":" milyar €","en":"bn €"},"etiket":{"tr":"tohum ve fide ihracatı (2024)","en":"seed and propagating material exports (2024)"}}},{"ust":{"tr":"Bölgesel küme ağı","en":"Regional cluster network"},"baslik":{"tr":"Greenports Nederland","en":"Greenports Nederland"},"govde":{"tr":"Hollanda seracılığı dağınık işletmelerin toplamı değil, coğrafi olarak sıkıştırılmış kümeler: üretim, ticaret, teknoloji ve lojistik yan yana. Zincir ihracatının %65'i Hollanda yapımı — ve bu, tarım arazisinin %0,56'sında duruyor.","en":"Dutch horticulture is not a sum of scattered holdings but geographically compressed clusters: production, trade, technology and logistics side by side. 65% of the chain's exports are Dutch-made — and it all sits on 0.56% of the farmland."},"rakam":{"deger":28,"ondalik":0,"sonek":{"tr":" milyar €","en":"bn €"},"etiket":{"tr":"bahçecilik zinciri ihracatı (2024)","en":"horticulture chain exports (2024)"}}},{"ust":{"tr":"Kamu–özel araştırma finansmanı · 2012","en":"Public–private research funding · 2012"},"baslik":{"tr":"Topsector Tuinbouw & Uitgangsmaterialen","en":"Topsector Tuinbouw & Uitgangsmaterialen"},"govde":{"tr":"Devlet parayı araştırmacıya değil, şirket–araştırmacı ortaklığına veriyor; şirket kendi payını koymazsa proje başlamıyor. 2025'te 66,5 milyon avroluk devlet desteğine karşılık özel sektör 66,7 milyon koydu. Türkiye'ye en doğrudan aktarılabilir tasarım budur.","en":"The state funds not the researcher but the company–researcher partnership; without the company's own share the project does not start. In 2025 the state put in €66.5 m and the private sector €66.7 m. This is the most directly transferable design in the file."},"rakam":{"deger":66.7,"ondalik":1,"sonek":{"tr":" milyon €","en":"m €"},"etiket":{"tr":"özel sektör katkısı (2025) — devlet desteği 66,5","en":"private-sector contribution (2025) — state support €66.5 m"}}}],"kaynak":"WUR · Royal FloraHolland · Plantum · Greenports Nederland · Topsector T&U"},"ihracat_cizgi":{"tur":"cizgi","baslik":{"tr":"Altmış yılın eğrisi","en":"The curve of sixty years"},"birim":{"tr":"milyon US$ (cari)","en":"million US$ (current)"},"ondalik":0,"seriler":[{"ad":{"tr":"Hollanda tarımsal ihracatı","en":"Dutch agricultural exports"},"rol":"vurgu","noktalar":{"harita":{"1961":1234,"1962":1322,"1963":1451,"1964":1595,"1965":1801,"1966":1819,"1967":1990,"1968":2281,"1969":2589,"1970":3100,"1971":3451,"1972":4164,"1973":5922,"1974":7027,"1975":8404,"1976":9195,"1977":10180,"1978":12088,"1979":14235,"1980":15797,"1981":15399,"1982":14916,"1983":14517,"1984":14775,"1985":14948,"1986":18980,"1987":22762,"1988":24680,"1989":26247,"1990":30616,"1991":30630,"1992":33450,"1993":29040,"1994":34690,"1995":36531,"1996":36917,"1997":31705,"1998":29924,"1999":34061,"2000":27878,"2001":27819,"2002":32514,"2003":41896,"2004":47787,"2005":50785,"2006":54891,"2007":67598,"2008":78998,"2009":74273,"2010":77260,"2011":89305,"2012":86569,"2013":90915,"2014":85286,"2015":73305,"2016":78823,"2017":95980,"2018":100117,"2019":97444,"2020":100825,"2021":113922,"2022":119850,"2023":125753}}}],"not":{"tr":"Cari dolar; enflasyondan arındırılmamıştır. Eğrinin dikliği kısmen fiyat artışıdır.","en":"Current dollars, not inflation-adjusted. Part of the curve's steepness is price growth."},"kaynak":"FAOSTAT — Trade: Crops and livestock products (TCL), 1961–2023"},"dunya_ilk10":{"tur":"siralama","baslik":{"tr":"Dünya sıralaması, 2023","en":"World ranking, 2023"},"birim":{"tr":"milyon US$","en":"million US$"},"ondalik":0,"satirlar":[{"etiket":{"tr":"1 · ABD","en":"1 · United States"},"deger":170964,"rol":"sessiz"},{"etiket":{"tr":"2 · Brezilya","en":"2 · Brazil"},"deger":146661,"rol":"sessiz"},{"etiket":{"tr":"3 · Hollanda","en":"3 · Netherlands"},"deger":125753,"rol":"vurgu"},{"etiket":{"tr":"4 · Almanya","en":"4 · Germany"},"deger":98515,"rol":"sessiz"},{"etiket":{"tr":"5 · Fransa","en":"5 · France"},"deger":82677,"rol":"sessiz"},{"etiket":{"tr":"6 · İspanya","en":"6 · Spain"},"deger":69066,"rol":"sessiz"},{"etiket":{"tr":"7 · Çin (anakara)","en":"7 · China, mainland"},"deger":68085,"rol":"sessiz"},{"etiket":{"tr":"8 · Kanada","en":"8 · Canada"},"deger":68014,"rol":"sessiz"},{"etiket":{"tr":"9 · İtalya","en":"9 · Italy"},"deger":64933,"rol":"sessiz"},{"etiket":{"tr":"10 · Belçika","en":"10 · Belgium"},"deger":60116,"rol":"sessiz"}],"not":{"tr":"198 ülke tarandı, bölge ve grup toplamları elendi. Hollanda 3., Türkiye 18. sırada. Yaygın olarak tekrarlanan '2. sıra' ifadesi FAOSTAT'ın bu tanımıyla 2023 için doğru değildir; o iddia WTO/Comtrade'in farklı 'tarım ürünleri' tanımına dayanır.","en":"198 countries were screened and regional or group aggregates removed. The Netherlands ranks 3rd and Türkiye 18th. The widely repeated claim of '2nd place' is not correct for 2023 under this FAOSTAT definition; that claim rests on the different WTO/Comtrade definition of 'agricultural products'."},"kaynak":"FAOSTAT — TCL, export value (element 5922), current US$"},"ikili_ticaret_cizgi":{"tur":"cizgi","baslik":{"tr":"İki ülke arasında","en":"Between the two countries"},"birim":{"tr":"milyon US$","en":"million US$"},"ondalik":0,"seriler":[{"ad":{"tr":"Hollanda → Türkiye","en":"Netherlands → Türkiye"},"rol":"vurgu","noktalar":{"liste":[{"yil":2020,"hollandadan_turkiyeye":574,"turkiyeden_hollandaya":506},{"yil":2021,"hollandadan_turkiyeye":614,"turkiyeden_hollandaya":548},{"yil":2022,"hollandadan_turkiyeye":727,"turkiyeden_hollandaya":564},{"yil":2023,"hollandadan_turkiyeye":749,"turkiyeden_hollandaya":586},{"yil":2024,"hollandadan_turkiyeye":803,"turkiyeden_hollandaya":681}],"x":"yil","y":"hollandadan_turkiyeye"}},{"ad":{"tr":"Türkiye → Hollanda","en":"Türkiye → Netherlands"},"rol":"ikincil","noktalar":{"liste":[{"yil":2020,"hollandadan_turkiyeye":574,"turkiyeden_hollandaya":506},{"yil":2021,"hollandadan_turkiyeye":614,"turkiyeden_hollandaya":548},{"yil":2022,"hollandadan_turkiyeye":727,"turkiyeden_hollandaya":564},{"yil":2023,"hollandadan_turkiyeye":749,"turkiyeden_hollandaya":586},{"yil":2024,"hollandadan_turkiyeye":803,"turkiyeden_hollandaya":681}],"x":"yil","y":"turkiyeden_hollandaya"}}],"not":{"tr":"Tek raportör Hollanda'dır; iki ülkenin kendi beyanları birbirini tutmaz, bu yüzden karşılaştırma tek kaynaktan yapıldı.","en":"The Netherlands is the sole reporter: the two countries' own declarations do not agree, so the comparison uses a single source."},"kaynak":"FAOSTAT — Detailed trade matrix (TM), raportör Hollanda"},"ikili_hollanda_satar":{"tur":"siralama","baslik":{"tr":"Hollanda Türkiye'ye ne satıyor","en":"What the Netherlands sells to Türkiye"},"birim":{"tr":"milyon US$ · 2024","en":"million US$ · 2024"},"ondalik":1,"satirlar":[{"etiket":{"tr":"Gıda müstahzarları (b.y.s.)","en":"Food preparations n.e.c."},"deger":110.6,"rol":"vurgu"},{"etiket":{"tr":"İşlenmiş tütün ve tütün özleri","en":"Manufactured tobacco and extracts"},"deger":83.6,"rol":"vurgu"},{"etiket":{"tr":"Kakao tozu ve küspesi","en":"Cocoa powder and cake"},"deger":80,"rol":"vurgu"},{"etiket":{"tr":"Kakao ezmesi","en":"Cocoa paste"},"deger":63.8,"rol":"vurgu"},{"etiket":{"tr":"Kakao yağı","en":"Cocoa butter, fat and oil"},"deger":60.9,"rol":"vurgu"}],"not":{"tr":"Beşinin beşi de işlenmiş sanayi girdisi. Hiçbiri tarlada yetişen bir ürün değil.","en":"All five are processed industrial inputs. Not one of them is something grown in a field."},"kaynak":"FAOSTAT — Detailed trade matrix (TM), 2024"},"ikili_turkiye_satar":{"tur":"siralama","baslik":{"tr":"Türkiye Hollanda'ya ne satıyor","en":"What Türkiye sells to the Netherlands"},"birim":{"tr":"milyon US$ · 2024","en":"million US$ · 2024"},"ondalik":1,"satirlar":[{"etiket":{"tr":"İşlenmiş sert kabuklu","en":"Prepared nuts"},"deger":73.1,"rol":"ikincil"},{"etiket":{"tr":"Kuru üzüm","en":"Raisins"},"deger":70.9,"rol":"ikincil"},{"etiket":{"tr":"Gıda müstahzarları (b.y.s.)","en":"Food preparations n.e.c."},"deger":47.1,"rol":"ikincil"},{"etiket":{"tr":"Ham organik madde (b.y.s.)","en":"Crude organic material n.e.c."},"deger":46,"rol":"ikincil"},{"etiket":{"tr":"İşlenmiş meyve (b.y.s.)","en":"Fruit prepared n.e.c."},"deger":32.9,"rol":"ikincil"}],"not":{"tr":"İlk iki kalem tarlanın ve bahçenin doğrudan ürünü. İlişkinin kendisi dosyanın tezini tekrarlıyor.","en":"The top two lines come straight from the field and the orchard. The relationship itself restates the thesis of this file."},"kaynak":"FAOSTAT — Detailed trade matrix (TM), 2024"},"cevre_kunye":{"tur":"kunye","baslik":{"tr":"Faturanın kendisi","en":"The bill itself"},"kalemler":[{"deger":9960000,"ondalik":2,"bolen":1000000,"sonek":{"tr":" milyon","en":" million"},"etiket":{"tr":"Domuz","en":"Pigs"},"alt":{"tr":"2025 — 1979'dan bu yana ilk kez 10 milyonun altında","en":"2025 — below 10 million for the first time since 1979"}},{"deger":3650000,"ondalik":2,"bolen":1000000,"sonek":{"tr":" milyon","en":" million"},"etiket":{"tr":"Sığır","en":"Cattle"},"alt":{"tr":"2025","en":"2025"}},{"deger":116000000,"ondalik":0,"bolen":1000000,"sonek":{"tr":" milyon kg","en":" million kg"},"etiket":{"tr":"Amonyak salımı (NH₃)","en":"Ammonia emissions (NH₃)"},"alt":{"tr":"2023 — yaklaşık %90'ı tarımdan","en":"2023 — around 90% from agriculture"}},{"deger":34000000,"ondalik":0,"bolen":1000000,"sonek":{"tr":" milyon kg","en":" million kg"},"etiket":{"tr":"Tarım arazisine azot çökelmesi","en":"Nitrogen deposition on farmland"},"alt":{"tr":"2024 — 1990'da 75 milyon kg'dı (%55 azalma)","en":"2024 — it was 75 million kg in 1990 (a 55% fall)"}},{"deger":142000000,"ondalik":0,"bolen":1000000,"sonek":{"tr":" milyon kg","en":" million kg"},"etiket":{"tr":"Fosfat üretimi","en":"Phosphate production"},"alt":{"tr":"2024 — AB tavanı 135 milyon kg; tavan aşıldı","en":"2024 — the EU ceiling is 135 million kg; it was exceeded"}},{"deger":2922000000,"ondalik":2,"bolen":1000000000,"sonek":{"tr":" milyar €","en":"bn €"},"etiket":{"tr":"Çiftlik kapatma bütçesi","en":"Farm buy-out budget"},"alt":{"tr":"1.438 başvuru onaylandı, 243'ü tamamlandı","en":"1,438 applications approved, 243 completed"}},{"deger":3900000000,"ondalik":1,"bolen":1000000000,"sonek":{"tr":" milyar m³","en":"bn m³"},"etiket":{"tr":"Seraların doğalgaz tüketimi","en":"Natural gas used by greenhouses"},"alt":{"tr":"2021 — hata payı ±%4","en":"2021 — margin of error ±4%"}}],"not":{"tr":"29 Mayıs 2019: Danıştay, 'önce izin ver sonra telafi et' yaklaşımını AB Habitat Direktifi'ne aykırı buldu. Kararın adı PAS; sonrası bu tablodur.","en":"29 May 2019: the Council of State found the 'permit first, compensate later' approach incompatible with the EU Habitats Directive. The ruling is known as PAS; this table is what followed."},"kaynak":"CBS · RVO / Rijksoverheid · Raad van State · Avrupa Komisyonu"}}$dsr$::jsonb,
  null,
  null,
  'published',
  now(),
  (now() + interval '28 days'),
  now()
)
on conflict (slug) do update set
  name_tr      = excluded.name_tr,
  name_en      = excluded.name_en,
  iso3         = excluded.iso3,
  edition      = excluded.edition,
  thesis_tr    = excluded.thesis_tr,
  thesis_en    = excluded.thesis_en,
  theme        = excluded.theme,
  data         = excluded.data,
  charts       = excluded.charts,
  cover_url    = excluded.cover_url,
  cover_credit = excluded.cover_credit,
  status       = excluded.status,
  -- Pencere KASITLI olarak korunuyor. Yayındaki bir dosyanın metninde yazım
  -- hatası düzeltmek için seed'i yeniden çalıştırmak, 28 günlük sayacı
  -- sıfırlamamalı. Pencereyi bilerek kaydırmak istiyorsanız elle update.
  starts_at    = coalesce(country_dossiers.starts_at,    excluded.starts_at),
  ends_at      = coalesce(country_dossiers.ends_at,      excluded.ends_at),
  published_at = coalesce(country_dossiers.published_at, excluded.published_at),
  updated_at   = now();

delete from public.dossier_sections
 where dossier_id = (select id from public.country_dossiers where slug = 'hollanda');

insert into public.dossier_sections
  (dossier_id, ord, title_tr, title_en, body_tr, body_en, chart_keys)
select d.id, v.ord, v.title_tr, v.title_en, v.body_tr, v.body_en, v.chart_keys
from public.country_dossiers d
cross join (values
  (1::integer, $dsr$Paradoks$dsr$, $dsr$The paradox$dsr$, $dsr$Türkiye 2023'te 79,9 milyar uluslararası dolarlık tarımsal üretim yaptı. Hollanda
aynı ölçüyle 17,8 milyar. Türkiye dört buçuk kat fazla üretti.

Aynı yıl Hollanda 125,8 milyar dolarlık tarım ürünü ihraç etti. Türkiye 29,5 milyar.
Bu sefer Hollanda dört kat fazla sattı.

İki oran neredeyse birbirinin aynısı — 4,49 ve 4,26 — ama yönleri ters. Üretimde
önde olan ülke ihracatta geride, ihracatta önde olan ülke üretimde geride. Bu
dosyanın tamamı bu tek cümlelik çelişkinin açıklamasıdır.

Bir uyarı gerekiyor. Bu iki rakam birbirine bölünemez: üretim değeri sabit 2014-16
uluslararası dolarıyla, ihracat cari dolarla ölçülür. "Hollanda 17,8 milyar üretip
125,8 milyar sattı" cümlesi yanlıştır ve bu dosyada geçmeyecek. Karşılaştırılabilir
olan, her iki ölçünün de iki ülke arasındaki oranıdır. O oran da tersine dönüyor.

Hollanda 33.670 km²'lik bir ülke. Türkiye 769.630 km². Hollanda'nın **tamamı**,
Türkiye'nin yalnızca tarım arazisinin on birde biri kadar. Kişi başına düşen
işlenebilir arazi de Türkiye'dekinin dörtte biri: 0,06 hektara karşılık 0,24 hektar.

Bu tabloya bakıp "Hollanda daha iyi çiftçilik yapıyor" demek kolay ve yanlış. Bu
dosyanın vardığı sonuç şu: Hollanda **her alanda** daha iyi çiftçilik yapmıyor.
Patateste Türkiye'den yalnızca yüzde on önde. Kuru soğanda yine yüzde on. Şeker
pancarında yüzde yirmi. Bunlar istatistiksel olarak vardır ama bir mucizeyi
açıklamaz.

Fark tek bir yerde patlıyor: camın altında. Salatalıkta on iki kat, biberde altı
buçuk, domateste beş. Ve o cam, Hollanda tarım arazisinin **yüzde 0,56'sını**
kaplıyor.

Yani soru "Hollandalılar tarımı nasıl bu kadar iyi yapıyor" değil. Soru şu:
*bir ülke tarım arazisinin yüzde yarımını kullanarak dünyanın en büyük üçüncü tarım
ihracatçısı nasıl olur?* Cevap toprakta değil. Toprağın üstüne kurulmuş olanda.$dsr$, $dsr$In 2023 Türkiye produced 79.9 billion international dollars' worth of agricultural
output. By the same measure, the Netherlands produced 17.8 billion. Türkiye produced
four and a half times more.

That same year the Netherlands exported 125.8 billion dollars of agricultural goods.
Türkiye exported 29.5 billion. This time the Netherlands sold four times more.

The two ratios are almost identical — 4.49 and 4.26 — but they point in opposite
directions. The country ahead in production is behind in exports; the country ahead
in exports is behind in production. This entire dossier is an explanation of that
one-sentence contradiction.

A warning is needed. These two figures cannot be divided by one another: production
value is measured in constant 2014-16 international dollars, exports in current
dollars. The sentence "the Netherlands produced 17.8 billion and sold 125.8 billion"
is false and will not appear in this dossier. What is comparable is the ratio between
the two countries **within** each measure. And that ratio reverses.

The Netherlands is a country of 33,670 km². Türkiye is 769,630 km². **All** of the
Netherlands is about one eleventh of Türkiye's agricultural land alone. Arable land
per person is likewise a quarter of Türkiye's: 0.06 hectares against 0.24.

Looking at this picture and concluding "the Dutch are better farmers" is easy and
wrong. The conclusion this dossier reaches is that the Netherlands is **not** better
at farming across the board. In potatoes it leads Türkiye by only ten percent. In
dry onions, again ten percent. In sugar beet, twenty. These gaps exist statistically,
but they do not explain a miracle.

The gap detonates in exactly one place: under glass. Twelve times in cucumbers, six
and a half in peppers, five in tomatoes. And that glass covers **0.56 percent** of
Dutch agricultural land.

So the question is not "how are the Dutch so good at farming?" The question is:
*how does a country become the world's third largest agricultural exporter using
half a percent of its farmland?* The answer is not in the soil. It is in what was
built on top of it.$dsr$, array['tez_ikili']::text[]),
  (2, $dsr$Rakamla iki ülke$dsr$, $dsr$Two countries in figures$dsr$, $dsr$Karşılaştırma yapmadan önce iki ekonominin ölçeğini yan yana koymak gerekiyor,
çünkü bu dosyadaki her oranın anlamı bu zemine oturuyor.

Hollanda'da 18,1 milyon kişi yaşıyor, Türkiye'de 85,9 milyon — Türkiye 4,7 kat
kalabalık. Buna karşılık iki ülkenin toplam ekonomik büyüklüğü şaşırtıcı biçimde
yakın: Hollanda 1,33 trilyon dolar, Türkiye 1,60 trilyon dolar (2025). Türkiye
yüzde yirmi daha büyük bir ekonomi.

Kişi başına düştüğünde tablo değişiyor. Hollanda'da kişi başına gelir 73.684 dolar,
Türkiye'de 18.599 dolar. Aradaki fark yaklaşık dört kat.

Tarımın bu ekonomiler içindeki yeri de birbirine benzemiyor. Türkiye'de tarım
GSYH'nin yüzde 5,21'i, Hollanda'da yüzde 1,68'i. Ama yüzdeler yanıltıcı olabilir;
mutlak rakama bakmak gerekiyor: Türkiye'nin tarımsal katma değeri 83,2 milyar dolar,
Hollanda'nınki 22,4 milyar dolar. Türkiye'nin tarımı, Hollanda'nınkinin 3,7 katı
büyüklüğünde bir sektör.

Asıl fark istihdamda. Türkiye'de çalışan her yedi kişiden biri tarımda — yüzde
14,22. Hollanda'da elli dokuz kişiden biri: yüzde 1,7. Sekiz buçuk kat.

Bu iki sayıyı katma değerle birleştirdiğinizde dosyanın en sade göstergesi çıkıyor.
Türkiye tarımı, ülkenin işgücünün yüzde 14'ünü kullanarak GSYH'nin yüzde 5'ini
üretiyor. Hollanda tarımı, işgücünün yüzde 1,7'sini kullanarak GSYH'nin yüzde 1,68'ini
üretiyor. Hollanda'da tarımda çalışan bir kişi ortalama bir Hollandalı kadar değer
üretiyor. Türkiye'de tarımda çalışan bir kişi, ortalama bir Türkiyelinin yaklaşık
üçte biri kadar.

Bu bir çalışkanlık farkı değil, bir sermaye ve ölçek farkıdır. Ve dosyanın geri
kalanı, o sermayenin nereye ve nasıl yerleştirildiğiyle ilgili.

Son bir sayı: kırsal nüfus. Hollanda'da nüfusun yüzde 4,06'sı kırsalda yaşıyor,
Türkiye'de yüzde 10,51. Hollanda tarımı kırsal bir faaliyet değil; şehirlerin
arasına sıkışmış, sanayi mantığıyla işleyen bir üretim biçimi. Bunun coğrafi
karşılığını beşinci bölümde göreceğiz.$dsr$, $dsr$Before any comparison, the scale of the two economies has to be set side by side,
because every ratio in this dossier rests on that ground.

18.1 million people live in the Netherlands, 85.9 million in Türkiye — Türkiye is
4.7 times more populous. Yet the total size of the two economies is surprisingly
close: the Netherlands 1.33 trillion dollars, Türkiye 1.60 trillion (2025). Türkiye
is a twenty percent larger economy.

Per capita, the picture inverts. Income per person is 73,684 dollars in the
Netherlands and 18,599 in Türkiye — roughly a fourfold gap.

Agriculture's place inside these economies also differs. In Türkiye agriculture is
5.21 percent of GDP, in the Netherlands 1.68 percent. But percentages can mislead;
the absolute figures matter: Türkiye's agricultural value added is 83.2 billion
dollars, the Netherlands' 22.4 billion. Türkiye's agriculture is a sector 3.7 times
the size of the Dutch one.

The real difference is in employment. In Türkiye one in every seven working people
is in agriculture — 14.22 percent. In the Netherlands, one in fifty-nine: 1.7 percent.
Eight and a half times.

Combining those two numbers with value added produces the plainest indicator in this
dossier. Turkish agriculture uses 14 percent of the country's labour force to produce
5 percent of GDP. Dutch agriculture uses 1.7 percent of the labour force to produce
1.68 percent of GDP. A person working in Dutch agriculture produces about as much
value as the average Dutch person. A person working in Turkish agriculture produces
about a third of what the average Turkish person does.

This is not a difference in diligence. It is a difference in capital and scale. And
the rest of this dossier is about where and how that capital was placed.

One last number: rural population. In the Netherlands 4.06 percent of people live
rurally, in Türkiye 10.51 percent. Dutch agriculture is not a rural activity; it is
a mode of production wedged between cities and run on industrial logic. We will see
the geographical form of that in the fifth section.$dsr$, array['makro_ikili']::text[]),
  (3, $dsr$Coğrafyanın sınırları$dsr$, $dsr$The limits of geography$dsr$, $dsr$Hollanda'nın tarımsal başarısını "verimli toprak" ile açıklamak yaygın bir
alışkanlıktır. Veri bunu desteklemiyor — ama beklenmedik bir yerden desteklemiyor.

Tarım arazisinin toplam kara alanına oranında iki ülke neredeyse eşit: Hollanda
yüzde 53,55, Türkiye yüzde 50,14 (2023). Yani her iki ülke de topraklarının yarısını
tarıma ayırmış durumda. Hollanda bu konuda özel değil.

Mutlak büyüklükte ise kıyas yok. Türkiye'nin tarım arazisi 385.880 km², Hollanda'nın
18.030 km². Türkiye 21 kat fazla. İşlenebilir arazide fark daha da açılıyor:
20,3 milyon hektara karşılık 1,0 milyon hektar — yirmi kat.

Kişi başına işlenebilir arazi, bu dosyanın en az konuşulan ama en açıklayıcı
sayılarından biri: Türkiye'de 0,24 hektar, Hollanda'da 0,06 hektar. Hollandalı
başına düşen toprak, Türkiyeli başına düşenin dörtte biri kadar. Bir ülke bu
kısıtla dünyanın üçüncü büyük tarım ihracatçısı olmuşsa, kısıt bir mazeret değil
bir tasarım girdisidir.

Suda tablo tersine dönüyor ve çok keskinleşiyor. Türkiye'de çekilen tatlı suyun
yüzde 86,93'ü tarıma gidiyor (2022). Hollanda'da yüzde 3,22. Yirmi yedi kat fark.
Bu, Hollanda'nın az su kullandığı anlamına gelmiyor — Hollanda'nın toplam su
çekiminde sanayinin ve soğutmanın payı çok yüksek. Ama tarımın su üzerindeki
baskısı bakımından iki ülke aynı gezegende değil. Türkiye'nin tarımı su kıtlığına
karşı savunmasız; Hollanda'nınki değil.

Sulama oranında Hollanda önde: tarım arazisinin yüzde 21,58'i sulanıyor, Türkiye'de
yüzde 12,47. Yağış alan bir ülkenin daha çok sulama yapması ilk bakışta tuhaf
görünür; açıklaması Hollanda sulamasının büyük ölçüde kapalı devre, geri kazanımlı
ve yüksek değerli ürüne yönelik olmasıdır.

Gübrede de Hollanda önde: hektar başına 238,02 kg, Türkiye'de 139,56 kg (2023).
Yaklaşık 1,7 kat fazla girdi. Bu rakamı aklınızda tutun — on ikinci bölümde geri
gelecek, çünkü Hollanda'nın bugün yaşadığı en büyük tarımsal kriz tam olarak
buradan çıkıyor.

Yağışta Hollanda'nın avantajı var ama sanıldığı kadar büyük değil: uzun dönem
ortalaması Hollanda'da yılda 778 mm, Türkiye'de 593 mm. Yüzde otuz bir fark.
(Dünya Bankası'nın bu göstergesi yıllık değil, uzun dönem ortalamasıdır; tek bir
yılın yağışı olarak okunamaz.)

Özetle: Hollanda'nın toprağı daha bol değil, daha kıt. Suyu daha bol ama tarımı
suya daha az bağımlı. Girdisi daha yoğun. Coğrafya bu dosyayı açıklamıyor.$dsr$, $dsr$Explaining Dutch agricultural success through "fertile soil" is a common habit. The
data does not support it — but it fails to support it from an unexpected direction.

In the share of land given over to agriculture the two countries are nearly equal:
the Netherlands 53.55 percent, Türkiye 50.14 percent (2023). Both have committed
about half their territory to farming. The Netherlands is not special here.

In absolute size there is no contest. Türkiye's agricultural land is 385,880 km²,
the Netherlands' 18,030 km². Türkiye has 21 times more. In arable land the gap widens
further: 20.3 million hectares against 1.0 million — twenty times.

Arable land per person is one of the least discussed and most explanatory figures in
this dossier: 0.24 hectares in Türkiye, 0.06 in the Netherlands. The land available
per Dutch person is a quarter of that available per Turkish person. If a country has
become the world's third largest agricultural exporter under that constraint, the
constraint is not an excuse — it is a design input.

In water the picture reverses, sharply. In Türkiye 86.93 percent of freshwater
withdrawal goes to agriculture (2022). In the Netherlands, 3.22 percent. A
twenty-sevenfold difference. This does not mean the Netherlands uses little water —
industry and cooling take a very large share of total Dutch withdrawal. But in terms
of agriculture's pressure on water, the two countries are not on the same planet.
Turkish agriculture is exposed to water scarcity; Dutch agriculture is not.

In irrigation the Netherlands leads: 21.58 percent of agricultural land is irrigated,
against 12.47 percent in Türkiye. That a rainy country irrigates more seems odd at
first; the explanation is that Dutch irrigation is largely closed-loop, recirculating,
and directed at high-value crops.

In fertiliser the Netherlands also leads: 238.02 kg per hectare against 139.56 kg in
Türkiye (2023). Roughly 1.7 times the input. Hold on to that figure — it returns in
the twelfth section, because the greatest agricultural crisis the Netherlands faces
today comes precisely from there.

In rainfall the Netherlands has an advantage, but a smaller one than assumed: the
long-term average is 778 mm a year in the Netherlands and 593 mm in Türkiye. A
thirty-one percent difference. (This World Bank indicator is not annual but a
long-term average; it cannot be read as the rainfall of any single year.)

In short: Dutch soil is not more abundant, it is scarcer. Its water is more abundant
but its agriculture depends on water less. Its inputs are more intensive. Geography
does not explain this dossier.$dsr$, array['toprak_ikili']::text[]),
  (4, $dsr$Verimin üç kademesi$dsr$, $dsr$The three tiers of yield$dsr$, $dsr$Bu dosyanın en keskin bulgusu burada. Ve ilk yazıldığında yanlış yazılmıştı;
düzeltilmesi gerekti.

İlk taslak şöyle diyordu: "Örtüaltı ürünlerde fark 5–12 kat; açık tarla ürünlerinde
fark neredeyse yok." Cümlenin ilk yarısı doğru. İkinci yarısı veriye bakılmadan
yazılmış bir sezgiydi ve veri onu yalanladı. Doğrusu şu: fark tek bir sayı değil,
**üç kademe**.

**Birinci kademe — cam altı: 5 ila 12 kat.**
Salatalıkta Hollanda hektardan 635,9 ton alıyor, Türkiye 53,1 ton. On iki kat.
Biberde 269,2'ye karşılık 40,4 ton — altı buçuk kat. Domateste 410,2'ye karşılık
80 ton — beş kat (2023, FAOSTAT). Bu kademede karşılaştırılan şey iki çiftçilik
değil, iki farklı üretim biçimi: biri tarla, öteki fabrika.

**İkinci kademe — yumru ve kök: 1,1 ila 1,2 kat.**
Patateste 41,8'e karşılık 37,8 ton. Kuru soğanda 45,9'a karşılık 43,0 ton. Şeker
pancarında 86,3'e karşılık 69,4 ton. Bu kademede fark yüzde on ile yirmi arasında.
İstatistiksel olarak vardır, ama bir üstünlük anlatısı kuramaz. Türk çiftçisi
patateste Hollandalı meslektaşıyla aynı ligde oynuyor.

**Üçüncü kademe — tahıl: 2,2 ila 2,6 kat.**
Buğdayda 8,5'e karşılık 3,2 ton, arpada 6,5'e karşılık 2,8 ton. Bu, "fark yok"
denemeyecek kadar büyük bir aralık. Ama sera farkıyla aynı şey de değil — ve
farkın **yönü** bunu kanıtlıyor.

Dünya Bankası'nın tahıl verimi serisi 1990'dan bugüne şunu gösteriyor: 1990'da
Hollanda hektardan 6.990 kg, Türkiye 2.214 kg alıyordu — 3,16 kat. 2000'de fark
3,33 kata çıktı. Sonra kapanmaya başladı: 2010'da 3,14, 2020'de 2,38, 2023'te 2,21.

Otuz üç yılda Türkiye'nin tahıl verimi yüzde 65 arttı, Hollanda'nınki yüzde 16.
Tahıl farkı kapanıyor. Sera farkı kapanmıyor.

Bu ikisini ayırmak dosyanın belkemiği. Tahıl açık tarlada yetişir; orada iklim,
gübre ve sulama belirleyicidir ve bu girdiler zamanla eşitlenebilir — nitekim
eşitleniyor. Hollanda'nın uzun dönem yağış ortalaması Türkiye'nin 1,31 katı,
gübre kullanımı 1,71 katı, sulanan arazi payı 1,73 katı. Bu üç fark tahıl farkıyla
*birlikte* bulunuyor. Hangisinin ne kadar pay sahibi olduğunu bu veri söyleyemez
ve bu dosya söylemeyecek.

Cam altında ise iklim değişkeni ortadan kalkar. Sıcaklık, nem, ışık, karbondioksit
ve besin çözeltisi ayarlanır. Orada ölçülen şey coğrafya değil, sermaye ve
mühendisliktir. Kapanmamasının sebebi de bu: kapanması için Türkiye'nin iklimini
değil, yatırım kararını değiştirmesi gerekiyor.

Bir sonraki bölümün konusu, bu birinci kademenin ne kadar küçük bir alanda
gerçekleştiği.$dsr$, $dsr$The sharpest finding in this dossier is here. And it was written wrongly the first
time; it had to be corrected.

The first draft said: "in protected crops the gap is 5–12 times; in open-field crops
there is almost no gap." The first half is right. The second half was an intuition
written without looking at the data, and the data refuted it. The truth is that the
gap is not a single number but **three tiers**.

**First tier — under glass: 5 to 12 times.**
In cucumbers the Netherlands takes 635.9 tonnes per hectare, Türkiye 53.1. Twelve
times. In peppers 269.2 against 40.4 tonnes — six and a half times. In tomatoes
410.2 against 80 tonnes — five times (2023, FAOSTAT). What is being compared at this
tier is not two kinds of farming but two different modes of production: one a field,
the other a factory.

**Second tier — tubers and roots: 1.1 to 1.2 times.**
Potatoes, 41.8 against 37.8 tonnes. Dry onions, 45.9 against 43.0. Sugar beet, 86.3
against 69.4. At this tier the gap runs between ten and twenty percent. It exists
statistically, but it cannot carry a narrative of superiority. In potatoes the Turkish
farmer plays in the same league as the Dutch one.

**Third tier — cereals: 2.2 to 2.6 times.**
Wheat, 8.5 against 3.2 tonnes; barley, 6.5 against 2.8. That is too wide a range to
call "no gap". But it is not the same thing as the greenhouse gap either — and the
**direction** of the gap proves it.

The World Bank cereal yield series shows the following since 1990: in 1990 the
Netherlands took 6,990 kg per hectare and Türkiye 2,214 — 3.16 times. By 2000 the gap
widened to 3.33. Then it began to close: 3.14 in 2010, 2.38 in 2020, 2.21 in 2023.

Over thirty-three years Turkish cereal yield rose 65 percent, Dutch yield 16 percent.
The cereal gap is closing. The greenhouse gap is not.

Separating those two is the backbone of this dossier. Cereals grow in open fields,
where climate, fertiliser and irrigation are decisive — and those inputs can equalise
over time, as indeed they are doing. The Dutch long-term rainfall average is 1.31
times Türkiye's, fertiliser use 1.71 times, the irrigated share of land 1.73 times.
Those three differences are found *alongside* the cereal gap. This data cannot say
how much of the gap belongs to which, and this dossier will not say either.

Under glass the climate variable disappears. Temperature, humidity, light, carbon
dioxide and nutrient solution are all set. What is measured there is not geography but
capital and engineering. That is also why the gap does not close: closing it would
require Türkiye to change not its climate but its investment decision.

The subject of the next section is how small an area this first tier occupies.$dsr$, array['verim_ortualti', 'verim_acik_tarla']::text[]),
  (5, $dsr$Yüzde yarım$dsr$, $dsr$Half a percent$dsr$, $dsr$Hollanda'nın toplam tarım arazisi 1.793.760 hektar (2025, CBS). Bunun **10.030
hektarı** örtüaltı. Oran: **yüzde 0,56**.

Bir önceki bölümde on iki kat verim farkı ürettiğini gördüğümüz üretim biçimi,
ülkenin tarım toprağının iki yüzde birinden azına sığıyor. 10.030 hektar 100,3 km²
demektir — kenarı on kilometre olan bir kare.

Bu 10.030 hektarın 5.570'i cam altı sebze (arazinin yüzde 0,31'i), 3.900'ü süs
bitkisi (yüzde 0,22). Sebze tarafında domates 1.770 hektar, biber 1.580, salatalık
630, patlıcan 110 hektar kaplıyor.

Şu karşılaştırma bölümün özeti sayılabilir: Türkiye'de domates hasat alanı 166.323
hektar, Hollanda'da 1.770 hektar (2023, FAOSTAT). Türkiye **94 kat** geniş bir alanda
domates yetiştiriyor. Hektar verimi ise Hollanda'nın beşte biri.

Buradaki 1.770 rakamı ayrıca bir doğrulama noktası. FAOSTAT'ın "Hollanda domates
hasat alanı" verisiyle CBS'nin "cam altı domates alanı" verisi birebir aynı çıkıyor:
1.770 hektar. Birbirinden bağımsız iki istatistik kurumu aynı sayıyı veriyorsa,
Hollanda'da domatesin **tamamına yakınının** cam altında yetiştiği söylenebilir.
Açık tarlada Hollanda domatesi pratikte yok.

Şimdi bu bölümün asıl bulgusuna geliyoruz. Sera alanı **büyümüyor**.

2000 yılında Hollanda'da 10.520 hektar örtüaltı alan vardı. 2025'te 10.030 hektar.
Yirmi beş yılda yüzde 4,7 **küçülme**. "Hollanda mucizesi" yayılarak değil,
yoğunlaşarak gerçekleşmiş.

Aynı çeyrek yüzyılda tarım işletmesi sayısı 97.390'dan 48.570'e düştü — yüzde 50,1.
Hollanda tarımı yarı yarıya azalan bir işletme nüfusuyla çalışıyor. Bugün örtüaltı
üretim yapan 3.030 işletme var ve ortalama sera büyüklüğü 3,31 hektar.

Bu üç sayının birlikte anlattığı şey açık: alan sabit, işletme sayısı yarıya inmiş,
demek ki işletme başına düşen alan ve sermaye katlanmış. Hollanda tarımının motoru
büyüme değil, **konsolidasyon ve derinleşme**.

Türkiye açısından buradaki ders yatırımın ölçeğiyle değil, hedefiyle ilgili.
On bin hektar, Türkiye'nin domates alanının on altıda biri kadar bir yer. Sorun
"Hollanda kadar toprağımız yok" değil — fazlasıyla var. Sorun o toprağın hangi
kısmına, ne yoğunlukta sermaye konduğu.$dsr$, $dsr$Total Dutch agricultural land is 1,793,760 hectares (2025, CBS). Of that, **10,030
hectares** are under cover. The share: **0.56 percent**.

The mode of production that in the previous section produced a twelvefold yield gap
fits into less than two hundredths of the country's farmland. 10,030 hectares is
100.3 km² — a square ten kilometres on a side.

Of those 10,030 hectares, 5,570 are vegetables under glass (0.31 percent of the land)
and 3,900 are ornamentals (0.22 percent). On the vegetable side, tomatoes occupy 1,770
hectares, peppers 1,580, cucumbers 630 and aubergines 110.

This comparison may serve as the section's summary: the tomato harvested area in
Türkiye is 166,323 hectares, in the Netherlands 1,770 (2023, FAOSTAT). Türkiye grows
tomatoes on an area **94 times** larger. Its yield per hectare is a fifth of the Dutch
figure.

That 1,770 is also a verification point. FAOSTAT's "Dutch tomato harvested area" and
CBS's "tomato area under glass" come out identical: 1,770 hectares. When two
independent statistical agencies give the same number, one may say that **very nearly
all** Dutch tomatoes are grown under glass. Open-field Dutch tomatoes effectively do
not exist.

Now to this section's real finding. The greenhouse area is **not growing**.

In 2000 the Netherlands had 10,520 hectares under cover. In 2025, 10,030. A 4.7
percent **contraction** over twenty-five years. The "Dutch miracle" happened not by
spreading but by concentrating.

Over the same quarter century the number of agricultural holdings fell from 97,390 to
48,570 — down 50.1 percent. Dutch agriculture runs on a farm population that has
halved. Today 3,030 holdings produce under cover, with an average greenhouse size of
3.31 hectares.

What those three numbers say together is plain: the area is flat, the number of
holdings has halved, therefore the area and capital per holding have multiplied. The
engine of Dutch agriculture is not growth but **consolidation and deepening**.

For Türkiye the lesson here is about the target of investment, not its scale. Ten
thousand hectares is about one sixteenth of Türkiye's tomato area. The problem is not
"we do not have as much land as the Netherlands" — there is far more. The problem is
which part of that land receives capital, and at what density.$dsr$, array['sera_kunye', 'sera_urunler']::text[]),
  (6, $dsr$Manşetin yarısı kime ait$dsr$, $dsr$Who owns half the headline$dsr$, $dsr$Hollanda tarım ihracatı 2025'te **137,5 milyar avro** oldu; bir önceki yıla göre
yüzde 8,4 artış (CBS). Bu, dünyanın herhangi bir yerinde manşet olacak bir rakam ve
oluyor da.

Hollanda'nın kendi istatistik kurumu bu manşetin altına bir dipnot düşüyor. Dosyanın
en dürüst bölümü burada başlıyor.

137,5 milyar avronun **88,4 milyarı** Hollanda'da üretilmiş mal. Geri kalan
**49,1 milyarı yeniden ihracat** — yani başka bir ülkede üretilip Hollanda'ya
girmiş, orada belki paketlenmiş, belki hiçbir işlem görmemiş ve tekrar ihraç
edilmiş mal. Manşet rakamın **yüzde 35,7'si**.

Bu tek başına bir kusur değil; aracılık meşru bir iştir. Asıl mesele bir sonraki
adımda ortaya çıkıyor.

CBS "exportverdiensten" — ihracat kazançları — diye ayrı bir hesap tutuyor: ihracatın
Hollanda ekonomisinde gerçekten bıraktığı katma değer. Ciro değil, kazanç. Bu hesaba
göre 137,5 milyar avroluk ihracat Hollanda'ya **49,0 milyar avro** kazandırıyor.

Bu 49,0 milyarın **43,5'i** Hollanda yapımı mallardan, yalnızca **5,7'si** yeniden
ihracattan geliyor.

İki oranı yan yana koyun:

| | Cirodaki payı | Kazançtaki payı |
|---|---|---|
| Hollanda yapımı | %64,3 | ~%88 |
| Yeniden ihracat | %35,7 | **%11,6** |

(CBS'nin yayımladığı bileşenler 43,5 + 5,7 = 49,2 veriyor, toplam ise 49,0 olarak
açıklanıyor; aradaki 0,2'lik fark yuvarlamadan geliyor. Bu yüzden kazanç payları
tam sayıya oturtulmadan verildi.)

Değer tutma oranı olarak bakıldığında fark daha da netleşiyor. Hollanda'da üretilen
her 100 avroluk ihracattan yaklaşık 49 avro ülkede kalıyor. Yeniden ihraç edilen
her 100 avrodan yaklaşık 12 avro.

Yani 137,5 milyar avroluk başlık, Hollanda'nın gerçek tarımsal başarısını kabaca
üçte bir oranında şişiriyor. Ve bunu iddia eden bir eleştirmen değil, Hollanda'nın
kendi merkezi istatistik bürosu.

Artışın kaynağı da düşündürücü: CBS'ye göre 2025'teki değer artışının üçte ikisinden
fazlası **fiyat** artışından geliyor, kalanı miktardan. Yani rekor rakamın önemli
bir kısmı daha çok mal satmaktan değil, aynı malı daha pahalıya satmaktan.

Coğrafi dağılım da "küresel dev" imajını düzeltiyor. En büyük pazar Almanya:
34,0 milyar avro, toplamın dörtte biri. Ardından Belçika 16,9, Fransa 11,4,
Birleşik Krallık 9,8, İspanya 5,7, İtalya 5,6, Polonya 5,2 milyar. ABD sekizinci
sırada 3,8 milyar avroyla, Çin onuncu 3,0 milyar avroyla. İlk üç ülke tek başına
toplamın yüzde 45'ini alıyor; ilk ikisi Hollanda'nın kara sınırı komşusu, üçüncüsü
bir gün mesafede.

Hollanda tarım ihracatı esasen bir **Kuzeybatı Avrupa iç pazarı** faaliyeti.
Türkiye ilk on pazarda yok.

Bu bölüm dosyanın tezini zayıflatmıyor, keskinleştiriyor. Hollanda'nın asıl başarısı
137,5 milyar avroluk ciroda değil; 18 milyonluk bir ülkenin tarımdan 49 milyar avro
net kazanç çıkarmasında. O 49 milyarın nereden geldiğini anlamak için bir sonraki
iki bölüme bakmak gerekiyor.$dsr$, $dsr$Dutch agricultural exports reached **137.5 billion euro** in 2025, up 8.4 percent on
the previous year (CBS). That is a figure that would make headlines anywhere in the
world, and it does.

The Dutch statistical agency itself attaches a footnote beneath that headline. The
most honest section of this dossier begins here.

Of the 137.5 billion euro, **88.4 billion** is goods produced in the Netherlands. The
remaining **49.1 billion is re-export** — goods produced in another country, brought
into the Netherlands, perhaps repackaged there, perhaps not touched at all, and
exported again. That is **35.7 percent** of the headline figure.

This alone is not a flaw; intermediation is legitimate business. The real issue
appears at the next step.

CBS keeps a separate account called "exportverdiensten" — export earnings — the value
added that exports actually leave behind in the Dutch economy. Not turnover, but
earnings. On that account, 137.5 billion euro of exports earns the Netherlands
**49.0 billion euro**.

Of that 49.0 billion, **43.5** comes from Dutch-made goods and only **5.7** from
re-exports.

Set the two ratios side by side:

| | Share of turnover | Share of earnings |
|---|---|---|
| Dutch-made | 64.3% | ~88% |
| Re-export | 35.7% | **11.6%** |

(CBS's published components sum to 43.5 + 5.7 = 49.2, while the total is published as
49.0; the 0.2 discrepancy comes from rounding. The earnings shares are therefore given
without forcing them to a single exact figure.)

Read as a value-retention rate the difference is starker still. Of every 100 euro of
exports produced in the Netherlands, roughly 49 euro stays in the country. Of every
100 euro re-exported, roughly 12.

So the 137.5 billion euro headline inflates the Netherlands' real agricultural
achievement by roughly a third. And the party making that claim is not a critic but
the Dutch central statistical bureau itself.

The source of the increase is also worth noting: according to CBS, more than
two-thirds of the 2025 value increase comes from **price**, the rest from volume. A
significant part of the record figure comes not from selling more goods but from
selling the same goods for more.

The geographical distribution corrects the "global giant" image too. The largest
market is Germany: 34.0 billion euro, a quarter of the total. Then Belgium 16.9,
France 11.4, the United Kingdom 9.8, Spain 5.7, Italy 5.6, Poland 5.2 billion. The
United States is eighth at 3.8 billion, China tenth at 3.0. The top three countries
alone take 45 percent of the total; the first two share a land border with the
Netherlands and the third is a day away.

Dutch agricultural export is essentially a **North-West European internal market**
activity. Türkiye is not among the top ten markets.

This section does not weaken the dossier's thesis; it sharpens it. The real Dutch
achievement is not the 137.5 billion euro of turnover; it is that a country of 18
million extracts 49 billion euro of net earnings from agriculture. To understand where
those 49 billion come from, we turn to the next two sections.$dsr$, array['ihracat_yigin', 'ilk_10_pazar']::text[]),
  (7, $dsr$Hiç kakao yetiştirmeyen kakao devi$dsr$, $dsr$The cocoa giant that grows no cocoa$dsr$, $dsr$Hollanda'da kakao yetişmez. Kakao ağacı ekvator kuşağında, yıl boyu sıcak ve nemli
iklimde yetişir; Hollanda'nın enlemi bunun çok kuzeyindedir. Hollanda'nın ürettiği
kakao miktarı sıfırdır.

Hollanda dünyanın en büyük kakao işleme merkezidir.

2023 rakamları (FAOSTAT, milyon dolar):

| Kalem | İthalat | İhracat |
|---|---|---|
| Kakao çekirdeği | 2.399 | 594 |
| Kakao yağı | 505 | 1.624 |
| Kakao ezmesi | 399 | 980 |
| Kakao tozu ve küspesi | 359 | 1.034 |

Örüntü tek bakışta okunuyor. Hollanda **çekirdek** alıyor — 2,4 milyar dolarlık.
Ve **işlenmiş ürün** satıyor: yağ, ezme, toz olarak toplam 3,6 milyar dolar.

Ham çekirdekte Hollanda net ithalatçı: 2.399 alıp 594 satıyor, arada 1,8 milyar
dolarlık açık var. İşlenmiş üç kalemde ise net ihracatçı: 1.263 milyon dolarlık
ithalata karşılık 3.638 milyon dolarlık ihracat. Net 2,4 milyar dolarlık fazla.

Bu, bir tarım ülkesinin değil, bir **sanayi ülkesinin** ticaret örüntüsü. Hollanda
kakao ticaretinde toprağıyla değil, limanı, fabrikası, finansmanı ve ticaret ağıyla
yer alıyor.

Buradan çıkan sonuç dosyanın tezini bir adım öteye taşıyor. Beşinci bölümde
Hollanda'nın toprağını yoğunlaştırarak değer ürettiğini gördük. Kakao gösteriyor ki
Hollanda **hiç toprağı olmadan da** değer üretebiliyor. Katma değer üretimin kendisinde
değil, üretimden sonraki halkalarda yaratılıyor: işleme, standardizasyon, lojistik,
finansman, marka.

Türkiye açısından bu bölümün ağırlığı büyük. Türkiye de kakao yetiştirmez —
Hollanda gibi. Ama Türkiye Hollanda'dan kakao **alır**: on birinci bölümde
göreceğiz, Hollanda'nın Türkiye'ye sattığı ilk beş kalemin üçü kakao ürünüdür.
Aynı bölümde bunun tersini de göreceğiz — Türkiye Hollanda'ya kabuklu fındık
satıyor.

Toprağı olan taraf çekirdeği veriyor; toprağı olmayan taraf işlenmiş ürünü.
Bu, iklimle veya toprakla açıklanamayacak bir farktır. Bir tercih farkıdır.$dsr$, $dsr$Cocoa does not grow in the Netherlands. The cocoa tree grows in the equatorial belt,
in a climate that is hot and humid year round; the Dutch latitude is far north of
that. Dutch cocoa production is zero.

The Netherlands is the world's largest cocoa processing centre.

2023 figures (FAOSTAT, million dollars):

| Item | Imports | Exports |
|---|---|---|
| Cocoa beans | 2,399 | 594 |
| Cocoa butter | 505 | 1,624 |
| Cocoa paste | 399 | 980 |
| Cocoa powder and cake | 359 | 1,034 |

The pattern reads at a glance. The Netherlands buys **beans** — 2.4 billion dollars'
worth. And it sells **processed goods**: butter, paste and powder totalling 3.6
billion dollars.

In raw beans the Netherlands is a net importer: buying 2,399 and selling 594, a
deficit of 1.8 billion dollars. In the three processed items it is a net exporter:
1,263 million dollars of imports against 3,638 million of exports. A net surplus of
2.4 billion dollars.

This is the trade pattern of an **industrial** country, not an agricultural one. The
Netherlands participates in the cocoa trade not through its soil but through its port,
its factories, its financing and its trading network.

The conclusion carries the dossier's thesis one step further. In the fifth section we
saw the Netherlands generating value by concentrating its land. Cocoa shows that the
Netherlands can generate value **with no land at all**. Value added is created not in
production itself but in the links that follow it: processing, standardisation,
logistics, financing, branding.

For Türkiye the weight of this section is considerable. Türkiye does not grow cocoa
either — like the Netherlands. But Türkiye **buys** cocoa from the Netherlands: as we
will see in the eleventh section, three of the top five items the Netherlands sells to
Türkiye are cocoa products. In the same section we will see the reverse — Türkiye
sells shelled hazelnuts to the Netherlands.

The side with the soil supplies the bean; the side without supplies the processed
good. That is a difference that cannot be explained by climate or soil. It is a
difference of choice.$dsr$, array['kakao_ikili']::text[]),
  (8, $dsr$Kendi toprağını yapan ülke$dsr$, $dsr$The country that made its own land$dsr$, $dsr$Hollanda tarımını anlamak için önce şunu kabul etmek gerekiyor: bu ülkenin
toprağının önemli bir kısmı **yapılmıştır**. Doğal değildir.

Hollanda Çevre Değerlendirme Kurumu PBL'in rakamı şu: ülkenin **yüzde 18'i**
sudan kazanılmış. Yüzde 26'sı deniz seviyesinin altında. Alçak Hollanda'da
3.800'den fazla polder — yani sürekli pompalanarak kuru tutulan, çevresi setle
kapatılmış arazi parçası — var.

Bu, tarım politikası tartışmasının başlangıç noktasıdır. Toprağı miras almamış,
üretmiş bir ülkeden söz ediyoruz.

**Zuiderzee.** 1918'de Zuiderzee Yasası imzalandı. 1932'de, 28 Mayıs günü,
32 kilometrelik Afsluitdijk barajının son boşluğu kapatıldı ve Kuzey Denizi'nin
büyük bir körfezi tatlı su gölüne dönüştü. Ardından dört polder geldi:
Wieringermeer 1930'da (20.000 hektar), Noordoostpolder 1942'de — savaşın
ortasında — 48.000 hektar, Oostelijk Flevoland 1957'de 54.000 hektar, Zuidelijk
Flevoland 1968'de 43.000 hektar.

Rijkswaterstaat'ın kendi ifadesiyle: toplam **165.000 hektar yeni toprak**.

Bu alanın büyüklüğünü kavramak için beşinci bölümdeki sayıya dönün. Hollanda'nın
tüm örtüaltı üretimi 10.030 hektarda yapılıyor. Zuiderzee projesiyle kazanılan
toprak bunun **on altı katı**. Yani Hollanda, seralarının kapladığı alanın on altı
katı büyüklüğünde bir araziyi denizden çıkardı — ve tarım mucizesi o arazide değil,
seralarda gerçekleşti. Toprak yapmak bile tek başına yetmiyor.

**1953.** 31 Ocak'ı 1 Şubat'a bağlayan gece Kuzey Denizi setleri aştı. 1.836 kişi
öldü. 150.000 hektardan fazla arazi su altında kaldı. Hollanda'nın yirminci
yüzyıldaki en büyük doğal afetiydi.

Tepki, bu dosyanın tekrar eden örüntüsünü gösteriyor: felaketten sonra kırk üç yıl
sürecek bir mühendislik programı başlatıldı. Delta Works 1954'te başladı, 1997'de
Maeslantkering ile tamamlandı.

**Açlık kışı.** 1944-45 kışında Hollanda'nın batısı açlık çekti. Ölü sayısı
konusunda tek bir resmî rakam yok ve bu dosya tek bir rakam vermeyecek. NIDI'nin
demografik çalışmasına göre ölüm nedeni **resmen "açlık" kaydedilen** 8.305 vaka
var. Hollanda Devlet Arşivi batıda açlık ve soğuktan **22.000'den fazla** ölüm
belirtiyor. NIOD ortaklığındaki resmî platform tahmini **15.000–25.000** aralığında
veriyor. Verzetsmuseum "20.000'den fazla" diyor.

Hangi rakamı alırsanız alın, sonuç aynı: Avrupa'nın en gelişmiş ülkelerinden biri,
seksen yıl önce kendi vatandaşlarını besleyemedi. Bugünkü gıda güvenliği takıntısı
soyut bir politika tercihi değil, yaşanmış bir hafızadır.

**Kurumlaşma.** Wageningen'deki belediye tarım okulu 1876'da devletleştirildi;
9 Mart 1918'de yükseköğretim statüsü aldı. Yani Hollanda, tarımı bir bilim dalı
olarak örgütlemeye Zuiderzee Yasası'yla **aynı yıl** karar verdi. Toprağı yapma
kararıyla o toprağı işleyecek bilgiyi üretme kararı yan yana alınmış.

**Mansholt.** Groningen'li bir çiftçi ailesinden gelen Sicco Mansholt, 1958'de
ilk Avrupa Komisyonu'nun Tarım Komiseri oldu. 21 Aralık 1968'de Komisyon'a
"Agriculture 1980" başlıklı bir muhtıra sundu — literatüre Mansholt Planı olarak
geçen belge. Mansholt 22 Mart 1972'den 5 Ocak 1973'e kadar Avrupa Komisyonu
Başkanlığı yaptı.

Buradaki nokta şu: Avrupa'nın ortak tarım politikasının mimarı bir Hollandalıydı.
Hollanda yalnızca kendi tarımını tasarlamadı; içinde satış yapacağı pazarın
kurallarını da yazdı. Altıncı bölümde ihracatının yüzde 45'inin en yakın üç pazara
gittiğini görmüştük. O pazarın kurallarının Hollandalı bir komiser tarafından
şekillendirilmiş olması tesadüf değil.$dsr$, $dsr$To understand Dutch agriculture one first has to accept this: a significant part of
this country's land was **made**. It is not natural.

The figure from PBL, the Netherlands Environmental Assessment Agency: **18 percent**
of the country was won from water. 26 percent lies below sea level. Low-lying
Netherlands contains more than 3,800 polders — parcels of land enclosed by dykes and
kept dry by continuous pumping.

This is the starting point of any Dutch agricultural policy discussion. We are talking
about a country that did not inherit its soil but produced it.

**The Zuiderzee.** The Zuiderzee Act was signed in 1918. On 28 May 1932 the final gap
in the 32-kilometre Afsluitdijk was closed, and a great bay of the North Sea became a
freshwater lake. Four polders followed: Wieringermeer in 1930 (20,000 hectares),
Noordoostpolder in 1942 — in the middle of the war — 48,000 hectares, Oostelijk
Flevoland in 1957 with 54,000, Zuidelijk Flevoland in 1968 with 43,000.

In Rijkswaterstaat's own words: a total of **165,000 hectares of new land**.

To grasp the size of that, return to the number in the fifth section. All Dutch
protected cultivation happens on 10,030 hectares. The land won by the Zuiderzee
project is **sixteen times** that. The Netherlands lifted out of the sea an area
sixteen times the size of all its greenhouses — and the agricultural miracle happened
not on that land but in the greenhouses. Making land is not, by itself, enough.

**1953.** On the night of 31 January into 1 February the North Sea overtopped the
dykes. 1,836 people died. More than 150,000 hectares were flooded. It was the
Netherlands' greatest natural disaster of the twentieth century.

The response shows this dossier's recurring pattern: after the catastrophe, an
engineering programme was launched that would run for forty-three years. The Delta
Works began in 1954 and were completed in 1997 with the Maeslantkering.

**The Hunger Winter.** In the winter of 1944-45 the west of the Netherlands starved.
There is no single official death toll, and this dossier will not give one. NIDI's
demographic study records 8,305 cases in which the cause of death was **officially
registered as starvation**. The National Archives of the Netherlands state that **more
than 22,000** died of hunger and cold in the west. The official platform run in
partnership with NIOD gives an estimated range of **15,000–25,000**. The Verzetsmuseum
says "more than 20,000".

Whichever figure you take, the conclusion is the same: one of Europe's most developed
countries could not feed its own citizens eighty years ago. Today's preoccupation with
food security is not an abstract policy preference but a lived memory.

**Institutionalisation.** The municipal agricultural school at Wageningen was taken
over by the state in 1876; on 9 March 1918 it received higher-education status. That
is, the Netherlands decided to organise agriculture as a science in the **same year**
as the Zuiderzee Act. The decision to make land and the decision to produce the
knowledge to work that land were taken side by side.

**Mansholt.** Sicco Mansholt, from a farming family in Groningen, became Commissioner
for Agriculture in the very first European Commission in 1958. On 21 December 1968 he
submitted to the Commission a memorandum titled "Agriculture 1980" — the document that
entered the literature as the Mansholt Plan. Mansholt served as President of the
European Commission from 22 March 1972 to 5 January 1973.

The point is this: the architect of Europe's common agricultural policy was a
Dutchman. The Netherlands did not merely design its own agriculture; it also wrote the
rules of the market it would sell into. In the sixth section we saw that 45 percent of
its exports go to its three nearest markets. That the rules of that market were shaped
by a Dutch commissioner is not a coincidence.$dsr$, array['tarih_cizelge']::text[]),
  (9, $dsr$Beş kurum, beş tasarım kararı$dsr$, $dsr$Five institutions, five design decisions$dsr$, $dsr$Buraya kadarki bölümler Hollanda tarımının **ne** yaptığını gösterdi. Bu bölüm
**kim** tarafından yapıldığını gösteriyor. Beş kurum, beş ayrı tasarım kararı.

**1 — Bilgiyi tek çatı altında topla: Wageningen.**
WUR bugün 12.407 öğrencisi (Ekim 2025), 2.440 doktora adayı, 234 profesörü ve
7.800 çalışanı olan bir kurum. QS sıralamasında Tarım ve Ormancılık alanında
**dünya birincisi**.

Asıl özelliği büyüklüğü değil, yapısı. WUR bir üniversite ile bir araştırma
enstitüsünün birleşiminden oluşur; temel araştırma ile uygulamalı araştırma aynı
kurumun içindedir. Bir sera teknolojisi burada geliştirilir, burada denenir ve
buradan yayılır.

**2 — Fiyat mekanizmasının mülkiyetini üreticiye ver: Royal FloraHolland.**
Dünyanın en büyük çiçek müzayedesi. Üzerinden geçen ürün cirosu **5,4 milyar avro**.
Ama kurumun kendi geliri yalnızca **493 milyon avro**, faaliyet kârı 19 milyon,
net kârı **12 milyon avro**.

Bu rakamları yan yana koyduğunuzda kurumun ne olduğu anlaşılıyor: FloraHolland bir
şirket değil, bir **kooperatif**. 5,4 milyar avronun neredeyse tamamı üreticiye
gidiyor; kurum yalnızca işletme masrafını alıyor. Kâr maksimizasyonu yapmıyor,
çünkü sahibi satıcının kendisi.

Bu bir verimlilik kararı değil, bir **mülkiyet** kararıdır. Fiyatın oluştuğu yerin
mülkiyeti kimde sorusu, Türkiye'deki hal tartışmasının da tam merkezinde durur.

**3 — En yüksek katma değerli halkayı elde tut: tohum ve fide.**
Hollanda'nın "uitgangsmateriaal" — başlangıç materyali — ihracatı 2024'te
**5,02 milyar avro**. 2000'de 1,3 milyar avroydu, 2020'de 3,8 milyar. Dört yılda
yüzde 31 büyüme.

Bileşimi: sebze tohumu yüzde 45, çiçek soğanı yüzde 34, tohumluk patates yüzde 12.
Sebze tohumunda 2,25 milyar avro ihracata karşılık 592 milyon avro ithalat var ve
ihracatın yüzde 58'i AB dışına gidiyor — yani bu, komşu pazarına değil dünyaya
satılan bir ürün.

En çarpıcı rakam Ar-Ge yoğunluğu: sektör cirosunun **yaklaşık yüzde 15'ini**,
sebze ıslahçılarında **yüzde 30'a varan** oranını araştırmaya ayırıyor. Bu, ilaç
sanayii seviyesinde bir Ar-Ge payıdır. Sektör 14.000'den fazla kişi istihdam ediyor.

Tohum, tarım zincirinin en başındaki ve en yüksek katma değerli halkasıdır.
Hollanda'nın oraya yerleşmiş olması stratejik bir tercihtir.

**4 — Üretimi coğrafi olarak sıkıştır: Greenports.**
Hollanda bahçe tarımı 2024'te **33,3 milyar avro** üretim değeri, **20,4 milyar avro**
katma değer üretti ve **208.000 iş yılı** istihdam sağladı. Zincirin ihracatı
28 milyar avro — 2019'a göre yüzde 25 artış — ve bunun yüzde 65'i Hollanda yapımı.

2020'de üretim değeri 26,8 milyar avroydu; dört yılda 33,3'e çıktı. Aynı dönemde
katma değer 16,2'den 20,4 milyar avroya, istihdam 198.000'den 208.000 iş yılına
yükseldi. WBSO kapsamındaki yenilik harcaması 516 milyon avro, yüzde 25 artış.

Greenport modeli üretimi belirli coğrafi kümelerde yoğunlaştırır: sera, ıslah
şirketi, lojistik, ambalaj, atık ısı hattı ve araştırma birimi yürüme mesafesinde
olur. Bu, beşinci bölümdeki "alan büyümüyor, yoğunluk artıyor" bulgusunun mekânsal
karşılığıdır.

**5 — Araştırma parasını ortaklık şartına bağla: Topsector Tuinbouw & Uitgangsmaterialen.**
2025'te 147 proje önerisi geldi, 100'ü kabul edildi. Devlet desteği **66,5 milyon
avro**, özel sektörün kendi katkısı **66,7 milyon avro**, toplam **133 milyon avro**.

Bu tek satır, Hollanda'nın araştırma modelinin tamamını özetliyor. Özel sektörün
koyduğu para devletin koyduğundan **fazla**. Devlet araştırmayı finanse etmiyor;
özel sektörün araştırma yapmasını kârlı hâle getiriyor. Kamu parası ancak bir şirket
kendi parasını da koyduğunda akıyor — hangi araştırmanın yapılacağına büyük ölçüde
piyasa karar veriyor.

Bakanlıklar arası dağılım da anlamlı: Tarım Bakanlığı (LVVN) 45,2 milyon, Ekonomi
Bakanlığı 20,1 milyon, Altyapı ve Su Yönetimi 1,2 milyon avro. Tarım araştırması
Hollanda'da tek bakanlığın işi değil.

**Beş kararın ortak yanı.** Hiçbiri iklimle, toprakla veya arazi büyüklüğüyle ilgili
değil. Beşi de kurumsal tasarım kararı. Ve bu yüzden beşi de kopyalanabilir.$dsr$, $dsr$The sections up to here have shown **what** Dutch agriculture does. This one shows
**who** does it. Five institutions, five separate design decisions.

**1 — Put knowledge under one roof: Wageningen.**
WUR today has 12,407 students (October 2025), 2,440 doctoral candidates, 234
professors and 7,800 staff. It ranks **first in the world** in Agriculture and Forestry
in the QS rankings.

Its distinguishing feature is not size but structure. WUR is a merger of a university
and a research institute; basic research and applied research sit inside the same
organisation. A greenhouse technology is developed here, trialled here and diffused
from here.

**2 — Give producers ownership of the price mechanism: Royal FloraHolland.**
The world's largest flower auction. The turnover of product passing through it is
**5.4 billion euro**. Yet the organisation's own revenue is only **493 million euro**,
its operating profit 19 million, its net profit **12 million euro**.

Setting those figures side by side reveals what the institution is: FloraHolland is
not a company but a **cooperative**. Nearly all of the 5.4 billion goes to the
producer; the organisation takes only its running costs. It does not maximise profit,
because its owner is the seller.

This is not an efficiency decision but an **ownership** decision. The question of who
owns the place where price is formed sits at the very centre of Türkiye's own debate
over wholesale markets.

**3 — Keep the highest value-added link: seed and propagation material.**
Dutch exports of "uitgangsmateriaal" — starting material — reached **5.02 billion
euro** in 2024. In 2000 it was 1.3 billion, in 2020 3.8 billion. Growth of 31 percent
in four years.

Composition: vegetable seed 45 percent, flower bulbs 34 percent, seed potatoes 12
percent. In vegetable seed there is 2.25 billion euro of exports against 592 million
of imports, and 58 percent of exports go outside the EU — this is a product sold to
the world, not to the neighbouring market.

The most striking figure is research intensity: the sector devotes **about 15 percent**
of turnover to research, rising to **as much as 30 percent** among vegetable breeders.
That is a pharmaceutical-industry level of R&D. The sector employs more than 14,000
people.

Seed is the first and highest value-added link in the agricultural chain. That the
Netherlands positioned itself there is a strategic choice.

**4 — Compress production geographically: the Greenports.**
Dutch horticulture generated **33.3 billion euro** of production value and **20.4
billion euro** of value added in 2024, and supported **208,000 work years** of
employment. The chain's exports are 28 billion euro — up 25 percent on 2019 — and 65
percent of that is Dutch-made.

In 2020 production value was 26.8 billion euro; in four years it reached 33.3. Over
the same period value added rose from 16.2 to 20.4 billion euro and employment from
198,000 to 208,000 work years. Innovation spending under the WBSO scheme was 516
million euro, up 25 percent.

The Greenport model concentrates production in defined geographical clusters: the
greenhouse, the breeding company, logistics, packaging, the waste-heat line and the
research unit are all within walking distance. This is the spatial counterpart of the
fifth section's finding that the area is not growing but the density is.

**5 — Tie research money to a partnership condition: Topsector Tuinbouw &
Uitgangsmaterialen.**
In 2025, 147 project proposals were submitted and 100 accepted. State support was
**66.5 million euro**, the private sector's own contribution **66.7 million euro**, a
total of **133 million euro**.

That single line summarises the whole Dutch research model. The private sector puts in
**more** than the state. The state does not finance research; it makes it profitable
for the private sector to do research. Public money flows only when a company puts in
its own — which means the market largely decides which research gets done.

The split between ministries is also telling: the Ministry of Agriculture (LVVN) 45.2
million, the Ministry of Economic Affairs 20.1 million, Infrastructure and Water
Management 1.2 million euro. Agricultural research in the Netherlands is not one
ministry's business.

**What the five decisions share.** None of them has anything to do with climate, soil
or the size of holdings. All five are institutional design decisions. And that is
precisely why all five are copyable.$dsr$, array['kurumlar_kartlar']::text[]),
  (10, $dsr$Altmış yılın eğrisi$dsr$, $dsr$The curve of sixty years$dsr$, $dsr$Hollanda'nın tarım ihracatı FAOSTAT'ın kaydına göre 1961'de **1,2 milyar dolardı**.
2023'te **125,8 milyar dolar**. Altmış iki yılda yüz kat.

Ara duraklar şöyle (milyon dolar, cari):

| Yıl | İhracat |
|---|---|
| 1961 | 1.234 |
| 1970 | 3.100 |
| 1980 | 15.797 |
| 1990 | 30.616 |
| 2000 | 27.878 |
| 2010 | 77.260 |
| 2020 | 100.825 |
| 2023 | 125.753 |

Bu tablo cari dolarla ölçülüdür; yani enflasyonu ve döviz kuru hareketlerini içerir.
"Yüz kat" ifadesi bu yüzden bir reel büyüme ölçüsü değildir ve bu dosyada reel
büyüme iddiası olarak kullanılmayacaktır.

Yine de eğrinin **şekli** kendi başına bilgi taşıyor ve iki noktası dikkat çekiyor.

**Birinci nokta: 1990-2000 arasındaki düşüş.** İhracat 30,6 milyar dolardan
27,9 milyar dolara geriliyor. On yılda yüzde 9 kayıp. Bu, seride bu ölçekte tek
gerileme. Ölçünün cari dolar olduğunu hatırlayın: bu dönemde gulden ve ardından
yeni kurulan avro dolar karşısında değer kaybetti, dolayısıyla düşüşün ne kadarının
gerçek hacim daralması, ne kadarının kur etkisi olduğunu bu seri tek başına
söyleyemez. Bu dosya bir açıklama iddia etmiyor; yalnızca düşüşün kayıtta
bulunduğunu not ediyor.

**İkinci nokta: 2000-2010 sıçraması.** 27,9 milyar dolardan 77,3 milyar dolara —
on yılda 2,8 kat. Serideki en hızlı dönem. Aynı on yıl, beşinci bölümde gördüğümüz
konsolidasyonun da yaşandığı dönem: sera alanı büyümezken işletme sayısı hızla
düşüyordu.

**Dünya sıralaması ve yaygın bir hata.**
Bu dosya için FAOSTAT'ın "Crops and livestock products" ihracat serisi 198 ülke
için baştan hesaplandı; bölge ve grup toplamları elendi. Sonuç şu:

| Sıra | 2023 | milyon $ |
|---|---|---|
| 1 | ABD | 170.964 |
| 2 | Brezilya | 146.661 |
| 3 | **Hollanda** | **125.753** |
| 4 | Almanya | 98.515 |
| 5 | Fransa | 82.677 |

Türkiye 2023'te **18.** sırada. Bir yıl önce 21. sıradaydı — üç basamak yükselmiş.
Hollanda ise hem 2022'de hem 2023'te üçüncü.

Burada bir düzeltme gerekiyor. Türkçe ve İngilizce kaynaklarda çok sık tekrarlanan
"Hollanda dünyanın ikinci büyük tarım ihracatçısı" ifadesi, FAOSTAT'ın bu tanımıyla
ve bu yılda **doğru değil**. Hollanda üçüncü; ikinci sırada Brezilya var.

Bu bir yakalama oyunu değil, bir yöntem uyarısı. "İkinci" iddiası genellikle
WTO veya Comtrade'in farklı "tarım ürünleri" tanımına dayanır — o tanımlar bazı
işlenmiş gıdaları ve içecekleri kapsar, bazı ham maddeleri kapsamaz. Sıralama,
tanımı değiştirdiğinizde değişir.

Bu dosyada verilen her sıra, tanımı ve yılıyla birlikte verilmiştir. Sıra
verilirken hangi kaynağın hangi tanımını kullandığınızı söylemiyorsanız, verdiğiniz
sıra bir bilgi değil bir slogandır.$dsr$, $dsr$According to FAOSTAT's record, Dutch agricultural exports stood at **1.2 billion
dollars** in 1961. In 2023, **125.8 billion**. A hundredfold in sixty-two years.

The intermediate stops (million dollars, current):

| Year | Exports |
|---|---|
| 1961 | 1,234 |
| 1970 | 3,100 |
| 1980 | 15,797 |
| 1990 | 30,616 |
| 2000 | 27,878 |
| 2010 | 77,260 |
| 2020 | 100,825 |
| 2023 | 125,753 |

This table is measured in current dollars, meaning it contains inflation and exchange
rate movements. The phrase "a hundredfold" is therefore not a measure of real growth
and will not be used in this dossier as a claim of real growth.

Even so, the **shape** of the curve carries information of its own, and two points
stand out.

**First point: the decline between 1990 and 2000.** Exports fall from 30.6 billion
dollars to 27.9 billion. A 9 percent loss over a decade. It is the only setback of
that magnitude in the series. Remember the measure is current dollars: over this period
the guilder, and then the newly created euro, lost value against the dollar, so this
series alone cannot say how much of the decline is real volume contraction and how much
is an exchange rate effect. This dossier claims no explanation; it merely notes that
the decline is in the record.

**Second point: the 2000-2010 jump.** From 27.9 billion dollars to 77.3 — 2.8 times in
a decade. The fastest period in the series. That same decade is also when the
consolidation described in the fifth section took place: greenhouse area was not
growing while the number of holdings fell sharply.

**World ranking, and a common error.**
For this dossier, FAOSTAT's "Crops and livestock products" export series was
recalculated from scratch for 198 countries, with regional and group aggregates
removed. The result:

| Rank | 2023 | million $ |
|---|---|---|
| 1 | United States | 170,964 |
| 2 | Brazil | 146,661 |
| 3 | **Netherlands** | **125,753** |
| 4 | Germany | 98,515 |
| 5 | France | 82,677 |

Türkiye ranks **18th** in 2023. A year earlier it was 21st — up three places. The
Netherlands was third in both 2022 and 2023.

A correction is needed here. The statement so often repeated in Turkish and English
sources — "the Netherlands is the world's second largest agricultural exporter" — is
**not correct** under this FAOSTAT definition and in this year. The Netherlands is
third; second place belongs to Brazil.

This is not a game of catching people out but a warning about method. The "second"
claim usually rests on the different "agricultural products" definitions used by the
WTO or Comtrade — definitions that include some processed foods and beverages and
exclude some raw materials. Rankings change when you change the definition.

Every rank given in this dossier is given together with its definition and its year. If
you state a rank without saying whose definition you are using, what you have given is
not information but a slogan.$dsr$, array['ihracat_cizgi', 'dunya_ilk10']::text[]),
  (11, $dsr$Türkiye ile$dsr$, $dsr$With Türkiye$dsr$, $dsr$İki ülkenin birbiriyle tarım ticareti, bu dosyanın tezini bir kez daha, bu sefer
Türkiye'nin kendi verisiyle tekrarlıyor.

Hacim (milyon dolar, Hollanda raportör):

| Yıl | Hollanda → Türkiye | Türkiye → Hollanda |
|---|---|---|
| 2020 | 574 | 506 |
| 2021 | 614 | 548 |
| 2022 | 727 | 564 |
| 2023 | 749 | 586 |
| 2024 | 803 | 681 |

Beş yılın tamamında Hollanda daha çok satıyor. Açık 2020'de 68 milyon dolarken
2022'de 163 milyona çıkıyor, 2024'te 122 milyona iniyor. Türkiye bu ilişkide sürekli
net ithalatçı.

(Bu rakamlar tek raportörden — Hollanda'dan — alınmıştır. İki ülkenin karşılıklı
beyanları hiçbir zaman birebir tutmaz; navlun, sigorta ve transit farkları vardır.
Aynı raportörü kullanmak, seriyi kendi içinde tutarlı kılar.)

Asıl bilgi hacimde değil, **bileşimde**.

**Hollanda'nın Türkiye'ye sattığı ilk kalemler** (2024, milyon dolar):
tanımlanmamış gıda müstahzarları 110,6 · işlenmiş tütün ve tütün özleri 83,6 ·
**kakao tozu ve küspesi 80,0** · **kakao ezmesi 63,8** · **kakao yağı 60,9** ·
alkolsüz içecekler 60,0 · ham organik madde 45,2 · kavrulmuş veya kafeinsiz
kahve 29,9 · gıda atıkları 26,2 · patates 22,0.

İlk beş kalemin üçü kakao. Ve yedinci bölümden biliyoruz ki Hollanda'da kakao
yetişmez.

**Türkiye'nin Hollanda'ya sattığı ilk kalemler** (2024, milyon dolar):
hazırlanmış sert kabuklu meyveler 73,1 · kuru üzüm 70,9 · tanımlanmamış gıda
müstahzarları 47,1 · ham organik madde 46,0 · hazırlanmış meyve 32,9 ·
**kabuklu fındık (iç) 32,7** · sirkeyle konserve edilmiş sebze 32,7 ·
konsantre elma suyu 32,0.

İki listeyi yan yana koyun.

Türkiye, güneşinin ve toprağının ürününü satıyor: fındık, üzüm, meyve, sebze.
Hollanda, hiç yetiştirmediği bir tropik ürünü işleyip satıyor: kakao. Türkiye'nin
en büyük kaleminin (73,1) yanında Hollanda'nın yalnızca kakao üçlüsü 204,7 milyon
dolar tutuyor.

Bu, "Türkiye kötü ürün satıyor" demek değil. Fındık ve kuru üzüm Türkiye'nin
gerçek ve değerli varlıklarıdır. Söylenen şu: Türkiye zincirin **başında**,
Hollanda **ortasında** duruyor. Zincirin ortası, hammaddeyi standart, izlenebilir
ve marka değeri taşıyan bir girdiye çevirdiği için daha fazla değer tutar.

Ve dikkat edin — Hollanda'nın Türkiye'ye sattıklarının hiçbiri Hollanda toprağıyla
ilgili değil. Patates dışında listede Hollanda'da yetişen tek bir ürün yok. Bu
ticaret ilişkisinde Hollanda'nın sattığı şey tarım ürünü değil, **işleme
kapasitesi**.

Bir ayrıntı daha: her iki listede de "tanımlanmamış gıda müstahzarları" (food
preparations n.e.c.) üst sıralarda. Hollanda 110,6 milyon dolarlık satıyor,
Türkiye 47,1 milyonluk. Bu kalem karışımları, katkıları, yarı mamulleri kapsar —
yani sanayinin sanayiye sattığı şeyleri. İki ülke arasındaki tarım ticaretinin
büyük kısmı, çiftçiden tüketiciye değil, fabrikadan fabrikaya akıyor.$dsr$, $dsr$Agricultural trade between the two countries repeats this dossier's thesis once more,
this time in Türkiye's own data.

Volume (million dollars, Netherlands reporting):

| Year | Netherlands → Türkiye | Türkiye → Netherlands |
|---|---|---|
| 2020 | 574 | 506 |
| 2021 | 614 | 548 |
| 2022 | 727 | 564 |
| 2023 | 749 | 586 |
| 2024 | 803 | 681 |

In all five years the Netherlands sells more. The deficit was 68 million dollars in
2020, widened to 163 million in 2022 and narrowed to 122 million in 2024. Türkiye is a
consistent net importer in this relationship.

(These figures are taken from a single reporter — the Netherlands. Two countries'
mutual declarations never match exactly; there are freight, insurance and transit
differences. Using one reporter keeps the series internally consistent.)

The real information is not in the volume but in the **composition**.

**Top items the Netherlands sells to Türkiye** (2024, million dollars): food
preparations n.e.c. 110.6 · manufactured tobacco and extracts 83.6 · **cocoa powder
and cake 80.0** · **cocoa paste 63.8** · **cocoa butter 60.9** · non-alcoholic
beverages 60.0 · raw organic material 45.2 · roasted or decaffeinated coffee 29.9 ·
food waste 26.2 · potatoes 22.0.

Three of the top five items are cocoa. And from the seventh section we know that cocoa
does not grow in the Netherlands.

**Top items Türkiye sells to the Netherlands** (2024, million dollars): prepared nuts
73.1 · raisins 70.9 · food preparations n.e.c. 47.1 · raw organic material 46.0 ·
prepared fruit 32.9 · **shelled hazelnuts 32.7** · vegetables preserved in vinegar
32.7 · concentrated apple juice 32.0.

Set the two lists side by side.

Türkiye sells the produce of its sun and its soil: hazelnuts, grapes, fruit,
vegetables. The Netherlands processes and sells a tropical crop it does not grow at
all: cocoa. Against Türkiye's largest item (73.1), the Dutch cocoa trio alone comes to
204.7 million dollars.

This does not mean "Türkiye sells the wrong products". Hazelnuts and raisins are real
and valuable Turkish assets. The point is this: Türkiye stands at the **beginning** of
the chain, the Netherlands in the **middle**. The middle of the chain retains more
value because it converts a raw material into a standardised, traceable input carrying
brand value.

And note — none of what the Netherlands sells to Türkiye has anything to do with Dutch
soil. Apart from potatoes there is not a single item on the list that grows in the
Netherlands. In this trading relationship what the Netherlands sells is not an
agricultural product but **processing capacity**.

One more detail: "food preparations n.e.c." sits near the top of both lists. The
Netherlands sells 110.6 million dollars' worth, Türkiye 47.1 million. This item covers
blends, additives and semi-finished goods — the things industry sells to industry. Most
of the agricultural trade between these two countries flows not from farmer to consumer
but from factory to factory.$dsr$, array['ikili_ticaret_cizgi', 'ikili_hollanda_satar', 'ikili_turkiye_satar']::text[]),
  (12, $dsr$Gölgeler$dsr$, $dsr$Shadows$dsr$, $dsr$Üçüncü bölümde bir sayıyı aklınızda tutmanızı istemiştim: hektar başına 238,02
kilogram gübre (2023), Türkiye'nin yaklaşık 1,7 katı. Şimdi o sayının nereye
gittiğini konuşalım.

Hollanda'nın 18.030 kilometrekarelik tarım arazisinde 2025'te 9,96 milyon domuz,
3,65 milyon sığır — bunun 1,53 milyonu süt ineği —, 35,1 milyon etlik piliç ve
31,8 milyon yumurta tavuğu bulunuyor. Domuz sayısı bir önceki yıla göre yüzde 5,1,
sığır yüzde 3,3 azaldı. Domuzun 10 milyonun altına inmesi 1979'dan bu yana ilk kez
oldu. Yani bu bir zirve tablosu değil; **düşüşün** tablosu. Düşerken bile bu.

Bu yoğunluğun bir çıktısı var ve havada duruyor. Hollanda 2023'te 116 milyon
kilogram amonyak saldı; bunun yaklaşık yüzde 90'ı tarımdan geliyor. Tarımın kendi
içinde payların dağılımı sığır yüzde 55, domuz yüzde 15, kümes yüzde 11. Sera
değil, hayvan. Dosyanın başında anlattığımız cam altı mucizesi bu faturanın
neredeyse hiç içinde değil.

Gübrenin de bir tavanı var ve Hollanda oraya dayanmış durumda. 2024'te hayvan
gübresinden çıkan azot 440 milyon kilogram — yasal tavan da tam olarak 440 milyon
kilogram. Fosfatta tavan aşılmış: 142 milyon kilograma karşılık 135 milyon
kilogramlık sınır. Bir ülkenin tarımı, kendi mevzuatının tavanına milimetre kala
çalışıyorsa, o tarımın büyüme yönü yoktur.

Burada dürüst olmak gerekir, çünkü bu bölüm bir suçlama değil bir ölçüm: **durum
düzeliyor.** Tarım arazisine düşen azot çökelmesi 1990'da 75 milyon kilogramdı,
2024'te 34 milyon kilograma indi — yüzde 55 azalma. Otuz dört yılda yarıdan fazla
düşürmek küçük bir başarı değil. Ama iki şey bu tabloyu yumuşamaktan çıkarıyor.
Birincisi, tarım arazisine düşen çökelmenin yüzde 56'sı hâlâ Hollanda'nın kendi
tarımından geliyor: sorun ithal değil, yerli. İkincisi, Hollanda aldığından
yaklaşık dört kat fazla azotu komşularına gönderiyor. Yani ulusal sınır içinde
iyileşen bir tablo, sınır dışında bir dışsallık üretiyor.

Kriz bir mahkeme kararıyla patladı. 29 Mayıs 2019'da Raad van State, Hollanda'nın
azot yönetim programı PAS'ı — "önce izin ver, sonra telafi et" mantığını — AB
Habitat Direktifi'ne aykırı buldu. Karar bir gecede inşaat, altyapı ve çiftlik
izinlerini askıya aldı. Bir tarım politikası tartışması değildi bu; ülkenin izin
verme kapasitesinin durmasıydı.

Devletin cevabı para oldu. İki çıkış şeması — Lbv için 1,102 milyar avro, Lbv-plus
için 1,820 milyar avro, toplam 2,92 milyar avro — çiftçilere kapanmaları karşılığında
ödeme öneriyor. Sonuç şu: 1.576 başvuru geldi, 1.438'i onaylandı, ama yalnızca
243'ü fiilen tamamlandı. RVO bunu açıkça söylüyor — onay, kapanışın gerçekleştiği
anlamına gelmiyor. Onaylanan her on çiftlikten sekizinden fazlası hâlâ çalışıyor.

Sandıkta da karşılığı oldu. Çiftçi hareketinden doğan BoerBurgerBeweging, Eerste
Kamer'de 75 sandalyenin 16'sını alarak meclisin en büyük grubu haline geldi. Bir
tarım düzenlemesi, bir ülkenin üst meclisinin aritmetiğini değiştirdi.

Ve süre doldu. Avrupa Komisyonu'nun 30 Eylül 2022 tarihli 2022/2069 sayılı kararıyla
uzatılan derogasyon — Hollanda'nın hektar başına AB genel sınırının üzerinde azot
kullanmasına izin veren istisna — 31 Aralık 2025'te sona erdi. 2026'dan itibaren
genel sınır geçerli: hektar başına 170 kilogram azot.

Bir gölge daha var, bu kez cam altında. Hollanda seraları 2021'de 3,9 milyar
metreküp doğal gaz tüketti. Dosyanın anlattığı verim mucizesi ısıtılmış, aydınlatılmış
ve iklimlendirilmiş bir mucizedir. Salatalıkta on iki kat verim, enerjinin fiyatı
sabitken bir mühendislik zaferidir; enerji fiyatı üç katına çıktığında bir kırılganlık
haline gelir.

Bu bölümün özeti tek cümlede toplanabilir: Hollanda modelinin sınırı toprak değil,
**tavan** oldu. Ve tavana çarpan şey seralar değil, ahırlar.$dsr$, $dsr$In the third section I asked you to hold on to a number: 238.02 kilograms of
fertiliser per hectare (2023), roughly 1.7 times Türkiye's. Now let us talk about
where that number goes.

On the Netherlands' 18,030 km² of agricultural land there were, in 2025, 9.96 million
pigs, 3.65 million cattle — 1.53 million of them dairy cows — 35.1 million broilers
and 31.8 million laying hens. Pig numbers fell 5.1 percent on the previous year,
cattle 3.3 percent. Pigs dropping below 10 million happened for the first time since
1979. So this is not a picture of a peak; it is a picture of the **decline**. And this
is what it looks like while declining.

That density has an output, and it hangs in the air. In 2023 the Netherlands emitted
116 million kilograms of ammonia; roughly 90 percent of it comes from agriculture.
Within agriculture the shares break down as cattle 55 percent, pigs 15 percent,
poultry 11 percent. Not greenhouses — animals. The under-glass miracle described at
the start of this dossier is almost entirely absent from this bill.

Manure has a ceiling too, and the Netherlands is pressed against it. In 2024 the
nitrogen from animal manure was 440 million kilograms — and the legal ceiling is
exactly 440 million kilograms. In phosphate the ceiling has been breached: 142 million
kilograms against a limit of 135 million. When a country's agriculture operates
millimetres from the ceiling of its own legislation, that agriculture has no direction
of growth.

Honesty is required here, because this section is a measurement and not an accusation:
**the situation is improving.** Nitrogen deposition on agricultural land was 75 million
kilograms in 1990 and fell to 34 million in 2024 — a 55 percent reduction. Cutting it
by more than half in thirty-four years is no small achievement. But two things stop
this from being a picture of relief. First, 56 percent of the deposition on
agricultural land still comes from Dutch agriculture itself: the problem is not
imported but domestic. Second, the Netherlands sends its neighbours roughly four times
more nitrogen than it receives. A picture that improves inside the national border
produces an externality outside it.

The crisis broke through a court ruling. On 29 May 2019 the Raad van State found that
the Netherlands' nitrogen management programme, PAS — the logic of "permit first,
compensate later" — was contrary to the EU Habitats Directive. Overnight the ruling
suspended construction, infrastructure and farm permits. This was not a debate about
agricultural policy; it was the halting of a country's capacity to issue permits.

The state's answer was money. Two exit schemes — 1.102 billion euro for Lbv and 1.820
billion for Lbv-plus, 2.92 billion in total — offer farmers payment in return for
closing down. The result: 1,576 applications were received, 1,438 approved, but only
243 actually completed. RVO says so explicitly — approval does not mean the closure has
taken place. More than eight in every ten approved farms are still operating.

There was a consequence at the ballot box too. The BoerBurgerBeweging, born out of the
farmers' movement, took 16 of the 75 seats in the Eerste Kamer, becoming the chamber's
largest group. An agricultural regulation changed the arithmetic of a country's upper
house.

And time has run out. The derogation extended by the European Commission's Decision
2022/2069 of 30 September 2022 — the exemption allowing the Netherlands to use nitrogen
above the general EU limit per hectare — expired on 31 December 2025. From 2026 the
general limit applies: 170 kilograms of nitrogen per hectare.

There is one more shadow, this time under glass. Dutch greenhouses consumed 3.9 billion
cubic metres of natural gas in 2021. The yield miracle this dossier describes is a
heated, lit and climate-controlled miracle. A twelvefold cucumber yield is a triumph of
engineering while the price of energy holds; when the price of energy triples, it
becomes a vulnerability.

This section can be summarised in one sentence: the limit of the Dutch model turned out
to be not soil but a **ceiling**. And what hit the ceiling was not the greenhouses but
the barns.$dsr$, array['cevre_kunye']::text[]),
  (13, $dsr$Türkiye ne alabilir$dsr$, $dsr$What Türkiye can take$dsr$, $dsr$Bu dosyanın en kolay yanlış sonucu şudur: "Türkiye de sera kursun."

Rakamlar bu cümleyi anlamsız kılıyor. Hollanda'nın toplam cam altı alanı 10.030
hektar — kendi tarım arazisinin yüzde 0,56'sı. Türkiye'nin yalnızca domates ekim
alanı 166.323 hektar; yani Hollanda'nın bütün seralarının on altı katı. Ölçek
kopyalanacak şey değil. Üstelik Hollanda'nın sera alanı 2000'den bu yana yüzde 4,7
**küçüldü** — büyüyen alan değil, işletme başına düşen alan oldu.

Alınabilecek dört şey var, ve dördü de donanım değil.

**Bir: farkın nerede olduğunu bilmek.** Dördüncü bölümdeki üç kademe bu dosyanın en
kullanışlı bulgusudur. Örtüaltı sebzede fark 5–12 kat, yumru ve kök ürünlerde
1,1–1,2 kat, tahılda 2,2–2,6 kat. Patateste ve soğanda Türkiye zaten Hollanda
seviyesinde üretiyor. Oraya yatırım yapmanın getirisi yok. Fark mühendislikle
açılan yerde açılıyor; kaynak da oraya gitmeli.

**İki: kapanan farkı görmezden gelmemek.** Tahıl verimindeki fark 1990'da 3,16
kattı, 2023'te 2,21 kata indi. Türkiye'nin tahıl verimi bu sürede yüzde 65 arttı,
Hollanda'nınki yüzde 16. Bu, Türkiye'nin mevcut yayım, tohum ve girdi politikasının
işlediğinin verisidir. Yeni bir model aramadan önce, çalışan bir şeyin çalıştığını
kabul etmek gerekir.

**Üç: zincirde bir adım aşağı inmek.** Altıncı bölümdeki oran bu dosyanın en sert
sayısıdır: Hollanda kendi ürettiğini sattığında değerin yüzde 49,2'sini tutuyor,
başkasının malını yeniden ihraç ettiğinde yüzde 11,6'sını. Türkiye bugün fındığı,
üzümü, meyveyi ham ya da yarı işlenmiş satıyor — zincirin başında. Bir adım aşağı
inmek, verimi bir kat artırmaktan daha fazla kazandırır ve daha az su ister.

**Dört: kurumu kopyalamak, makineyi değil.** Dokuzuncu bölümdeki beş kurum — bir
üniversite, bir müzayede, bir tohum sanayii, bir bölgesel küme, bir kamu-özel
program — hiçbiri sera teknolojisi değil. Hepsi kurumsal tasarım. Türkiye'nin
ihtiyacı bir Westland değil, Westland'i mümkün kılan koordinasyon biçimidir.

Ve bir uyarı, on ikinci bölümden. Hollanda yoğunlaşmanın faturasını azotla ödedi;
tavan oradan geldi. Türkiye'nin tavanı azot değil, **su**: çekilen tatlı suyun
yüzde 86,93'ü tarıma gidiyor (2022), Hollanda'da bu oran yüzde 3,22. Hollanda'nın
sınırı kendi ahırlarıydı ve mahkeme kararıyla göründü. Türkiye'nin sınırı kendi
havzaları ve mahkeme kararı beklemeden görülebilir.

Bu dosyanın tezi baştan beri tek cümleydi: Hollanda'nın tarımsal gücü toprağında
değil, toprağının üstüne kurduğu sistemde. Sistem ise taşınabilir — çünkü sistem
coğrafya değil, karardır.$dsr$, $dsr$The easiest wrong conclusion to draw from this dossier is: "Türkiye should build
greenhouses too."

The numbers render that sentence meaningless. Total Dutch area under glass is 10,030
hectares — 0.56 percent of its own agricultural land. Türkiye's tomato area alone is
166,323 hectares, sixteen times all the greenhouses in the Netherlands. Scale is not
the thing to copy. What is more, the Dutch greenhouse area has **shrunk** 4.7 percent
since 2000 — what grew was not the area but the area per holding.

There are four things worth taking, and none of them is hardware.

**One: knowing where the gap actually is.** The three tiers in the fourth section are
this dossier's most useful finding. Under cover the gap is 5–12 times, in tubers and
roots 1.1–1.2, in cereals 2.2–2.6. In potatoes and onions Türkiye already produces at
Dutch levels. Investment there has no return. The gap opens where engineering opens it,
and that is where resources should go.

**Two: not ignoring the gap that is closing.** The cereal yield gap was 3.16 times in
1990 and 2.21 in 2023. Turkish cereal yield rose 65 percent over that period, Dutch
yield 16 percent. That is evidence that Türkiye's existing extension, seed and input
policy works. Before looking for a new model, one has to acknowledge that something
working is working.

**Three: moving one step down the chain.** The ratio in the sixth section is the
harshest number in this dossier: when the Netherlands sells what it produces itself it
retains 49.2 percent of the value; when it re-exports someone else's goods, 11.6
percent. Türkiye today sells its hazelnuts, its grapes and its fruit raw or
semi-processed — at the beginning of the chain. Moving one step down earns more than
doubling yield, and asks for less water.

**Four: copying the institution, not the machine.** The five institutions in the ninth
section — a university, an auction, a seed industry, a regional cluster, a public-private
programme — are none of them greenhouse technology. All are institutional design. What
Türkiye needs is not a Westland but the form of coordination that made Westland
possible.

And a warning, from the twelfth section. The Netherlands paid the bill for
intensification in nitrogen; that is where its ceiling came from. Türkiye's ceiling is
not nitrogen but **water**: 86.93 percent of freshwater withdrawal goes to agriculture
(2022), against 3.22 percent in the Netherlands. The Dutch limit was its own barns, and
it became visible through a court ruling. Türkiye's limit is its own basins, and it can
be seen without waiting for a court.

The thesis of this dossier has been one sentence from the start: Dutch agricultural
power lies not in its soil but in the system built on top of that soil. And a system is
portable — because a system is not geography, it is a decision.$dsr$, '{}'::text[])
) as v(ord, title_tr, title_en, body_tr, body_en, chart_keys)
where d.slug = 'hollanda';

-- Sağlama: beklenen bölüm sayısı yazılmadıysa işlem geri alınır.
do $kontrol$
declare n integer;
begin
  select count(*) into n
    from public.dossier_sections s
    join public.country_dossiers d on d.id = s.dossier_id
   where d.slug = 'hollanda';
  if n <> 13 then
    raise exception 'Bölüm sayısı 13 olmalıydı, % yazıldı', n;
  end if;
end
$kontrol$;

commit;
