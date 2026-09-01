-- Dosya devri — 29 Ağustos 2026
--
-- Hollanda (ülke 01) ve TMO (kurum 01) pencereleri BUGÜN kapatılıyor;
-- Rusya (ülke 02) ve Ziraat Bankası (kurum 02) bugün açılıyor.
-- Kullanıcı kararı: devir takvimden öne çekildi (Hollanda 13 Eylül, TMO
-- 5 Eylül'dü).
--
-- ── SIRA ÖNEMLİ ───────────────────────────────────────────────────────────
-- Bu migration UYGULANMADAN ÖNCE `./deploy.sh --hosting` çalışmış ve
-- doğrulanmış olmalı. Ziraat'in yedi görseli ve paylaşım kartı henüz canlıda
-- YOK; migration önce giderse dosya sayfasındaki görseller kırık açılır.
-- 25 Ağustos 2026'da tam olarak bu sırayla bir kez yaşandı.
--
-- ── NE DEĞİŞİYOR ──────────────────────────────────────────────────────────
-- 1. Rusya ve Ziraat içeriği yazılıyor (üretilmiş seed'ler, aşağıda).
--    Pencere `now()`dan başlıyor: Rusya 28 gün, Ziraat 14 gün.
-- 2. Hollanda ve TMO `archived` yapılıyor, `ends_at` = now().
--    `archived` seçildi çünkü:
--      · country_dossier_index published VE archived'ı gösteriyor →
--        arşiv sayfasında "geçen dosya" olarak durmaya devam ediyorlar
--      · dosya_haberleri / haber_dosyalari ikisi de archived'ı kabul ediyor →
--        haber bağlantısı iki yönde de çalışmaya devam ediyor
--      · dosya_hikayeleri.py YALNIZCA published okuyor → ana sayfadaki eski
--        hikâye baloncukları kendiliğinden düşüyor. Sadece pencereyi
--        kapatsaydık, published kalan dosya hikâye üretmeye devam ederdi.
-- 3. Takvimdeki "Yakında" sözleri kapatılıyor: Rusya ve Ziraat artık
--    yaklaşan değil yayında.
--
-- active_country_dossier `distinct on (tur)` + pencere kuralıyla çalıştığı
-- için ana sayfada her diziden yalnızca yeni dosya görünüyor.
--
-- İçteki begin/commit çıkarıldı: CLI her migration'ı zaten tek işlemde
-- çalıştırıyor.

-- ════════════════════════════════════════════════════════════════════
-- rusya — üretilmiş seed (node content/dossiers/seed_dossier.mjs rusya)
-- ════════════════════════════════════════════════════════════════════
-- Rusya — Ülke Dosyası · seed
--
-- ÜRETİLMİŞ DOSYA — elle düzenlemeyin.
-- Kaynak:  content/dossiers/rusya/
-- Üretim:  node content/dossiers/seed_dossier.mjs rusya
-- Tarih:   2026-08-29T10:47:21.321Z
--
-- Bölüm: 20 · TR ~5.324 kelime · EN ~6.943 kelime
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
  'rusya',
  'Rusya',
  'Russia',
  'RUS',
  'ulke',
  null,
  2,
  $dsr$Rusya hem pazarımız hem tedarikçimiz. Ama ondan aldığımız bir yıl bekler, ona sattığımız birkaç hafta dayanır.$dsr$,
  $dsr$Russia is both our market and our supplier. But what we buy keeps for a year; what we sell keeps for weeks.$dsr$,
  $dsr${"_dosya":"Rusya — Ülke Dosyası · tasarım künyesi","_amac":"Görsel kararlar. DossierTheme bu dosyadan üretilir; kodda serbest renk yazılmaz.","_onay_tarihi":"2026-08-23","_kural":"Bu dosyadaki hiçbir renk 'yaklaşık' değildir. Hepsi WCAG 2.1 AA'ya karşı hesaplandı; hesap betiği _raw/kontrast.py.","_sureklilik":"Kullanıcı kararı: ülke dosyalarının tasarım dili ortak kalacak ki okurda aşinalık oluşsun. Yapı Hollanda'yla birebir aynı — koyu ada, tek vurgu, tek ikincil, doğrusal motif, aynı bölüm ritmi. Değişen yalnızca paletin ve motifin KAYNAĞI: her ülke kendi malzemesinden türetiliyor.","tez_cumlesi":{"tr":"Rusya hem pazarımız hem tedarikçimiz. Ama ondan aldığımız bir yıl bekler, ona sattığımız birkaç hafta dayanır.","en":"Russia is both our market and our supplier. But what we buy keeps for a year; what we sell keeps for weeks.","gerekce":"İki yarısı da dosyanın iki yarısını taşıyor: 'hem pazarımız hem tedarikçimiz' karşılıklılığı (12. bölüm), 'bir yıl / birkaç hafta' asimetriyi (1. ve 17. bölüm). Suçlayıcı değil, tarif edici — kimsenin hatası anlatılmıyor, bir yapı anlatılıyor."},"palet":{"ad":"Kara Toprak ve Kırağı","kaynak_fikir":"Çernozyomun rengi topraktan değil, onu yapan bozkır otundan geliyor — dosyanın 2. bölümünün bulgusu bu. Zemin kara toprak, vurgu ise o toprağı binlerce yılda yapan kuru otun rengi. Yani paletin vurgusu bir süs değil, tezin kendisi. İkincil renk kırağı: Rus tarımının asıl sınırı genişlik değil, soğuk.","hollandadan_farki":"Hollanda'nın zemini MAVİ-siyahtı (gece göğü). Rusya'nınki SICAK siyah (toprak). Yan yana konduklarında iki dosya aynı aileden ama aynı yer değil.","mod":"KOYU — dosya sayfası her zaman koyu, uygulamanın açık/koyu tercihini izlemez.","koyu":{"zemin":{"hex":"#14110D","rol":"Sayfa arka planı — çernozyom"},"yuzey":{"hex":"#221C15","rol":"Kart, tablo, alıntı bloğu","kontrast_zemin":1.12},"murekkep":{"hex":"#EFE9DF","rol":"Gövde metni","kontrast_zemin":15.59,"kontrast_yuzey":13.97},"sessiz":{"hex":"#ADA492","rol":"Meta, kaynak satırı, altyazı","kontrast_zemin":7.62,"kontrast_yuzey":6.83},"vurgu":{"hex":"#E8B94E","rol":"Bozkır otu — rakamlar, başlık vurguları, Rusya serisi","kontrast_zemin":10.29,"kontrast_yuzey":9.22},"ikincil":{"hex":"#6BA5BA","rol":"Kırağı — Türkiye serisi, karşılaştırma ikinci rengi","kontrast_zemin":6.92,"kontrast_yuzey":6.2},"cizgi":{"hex":"#302921","rol":"SADECE dekoratif ayırıcı","kontrast_zemin":1.31,"_uyari":"3:1'in altında. Anlam taşıyan hiçbir yerde kullanılamaz — grafik ekseni, sınır, odak halkası için cizgiVurgu kullanılır."},"cizgiVurgu":{"hex":"#6E6353","rol":"Grafik ekseni, ızgara çizgisi, odak halkası","kontrast_zemin":3.2,"kontrast_yuzey":2.87}},"acik_mod_seridi":{"_amac":"Ana sayfadaki dosya şeridi sayfanın içinde yaşıyor; açık modda bozkır sarısı krem üstünde 1,62:1 veriyor — okunmaz. Şerit için koyulaştırılmış varyantlar kullanılır.","murekkep":{"hex":"#1B1710","kontrast_krem":15.85},"vurguKoyu":{"hex":"#7A5306","rol":"Bozkır sarısının açık zemin karşılığı","kontrast_krem":6.08,"kontrast_beyaz":6.85},"ikincilKoyu":{"hex":"#1C5566","rol":"Kırağının açık zemin karşılığı","kontrast_krem":7.34,"kontrast_beyaz":8.27}},"renk_korlugu_notu":"Vurgu (L=0,524) ve ikincil (L=0,336) parlaklık oranı 1,56 — gri tonda da ayrışıyorlar. Hollanda'da bu oran 1'e yakındı ve tasarım notunda ayrı ayrı uyarı gerekiyordu. Ayrıca sarı-mavi çifti, kırmızı-yeşil körlüğünde KORUNAN eksendir; Hollanda'nın turuncu-yeşil çiftinden bu açıdan daha güvenli. Buna rağmen grafiklerde iki seri asla yalnızca renkle ayrılmayacak: Rusya dolu çizgi/dolu daire, Türkiye kesikli çizgi/içi boş daire.","denetim_betigi":"_raw/kontrast.py — `python3 content/dossiers/rusya/_raw/kontrast.py`"},"motif":{"ad":"Toprak kesiti","tanim":"Bir toprak profilinin yatay katmanları: farklı kalınlıkta yatay bantlar, aşağı indikçe koyulaşan. Üstte ince, ortada kalın humus katmanı, altta ana kaya.","gerekce":"Dokuçayev'in 1900 Paris Sergisi'nde sergilediği çernozyom monoliti tam olarak bu nesnedir — toprağın dikey kesiti. Motif bu yüzden dekoratif değil, dosyanın 2. bölümünün nesnesi. Ve tezi tekrar ediyor: bu manzaranın hikâyesi yatayda değil, DİKEYDE — katmanlarda, zamanda birikmiş. Hollanda'nın polderi insan yapımı bir ızgaraydı; Rusya'nın kesiti insansız bir birikim.","hollandadan_farki":"Polder motifi DİKEY şeritlerdi (parseller). Toprak kesiti YATAY bantlar. İki dosya yan yana konduğunda motifler birbirinin dikine bakıyor — aynı dil, ayrı cümle.","uygulama":{"opaklik":"%5 (kabul aralığı %4-8)","renk":"cizgiVurgu #6E6353 üzerine opaklık","bicim":"Vektör (CustomPainter) — raster değil. Ölçeklenebilir, dosya boyutu sıfır, telif sorunu yok.","yerlesim":"Bölüm ayırıcılarında ve kapak altı geçiş bandında. Gövde metninin ARKASINDA kullanılmaz.","bant_araligi":"Bant kalınlığı 18 px'in altına inmeyecek; daha incesi retina olmayan ekranlarda titriyor.","yon_notu":"Bantlar yatay olduğu için dikey kaydırmada göz izliyor; kaymayı yavaşlatmak üzere bant kalınlıkları düzensiz dağıtılacak — eşit aralık merdiven etkisi yapıyor.","yon":"yatay","_yon_notu":"Toprak profilinin katmanları yatay bantlar. Paylaşım kartı bu alanı okuyor; önceden Hollanda'nın dikey şeridi betiğe gömülüydü ve her dosyada dikey çiziliyordu."}},"kapak":{"yon":"Kara toprak. Tercih sırası: (1) çernozyom toprak kesiti/monoliti — dosyanın nesnesi, (2) hasat sonrası bozkır tarlası, ufka giden tek yatay çizgi.","gerekce":"Paletle aynı kaynaktan geliyor; kapak ve sayfa aynı şeyi söylüyor. Ayrıca 2. bölümün açılışını görselleştiriyor.","gorsel_kaynagi":{"tercih_1":"Wikimedia Commons — çernozyom profil fotoğrafı, CC lisanslı. Atıf zorunlu ve verilecek.","tercih_2":"NASA Earth Observatory / Landsat — kara toprak kuşağı, kamu malı","_karar":"Görsel BULUNANA KADAR kapak tipografik iskeletle çalışır. Görselsiz de tam çalışması şart.","_yasak":"Telifi belirsiz hiçbir görsel kullanılmayacak. Atıf zorunluysa atıf yapılır."},"tipografi_katmani":{"ust_satir":"ÜLKE DOSYASI · 02","baslik":"RUSYA","alt_satir":"tez_cumlesi.tr","veri_rozeti":"Türkiye, Rusya'nın 1 numaralı tarım müşterisi"},"okunurluk":"Görsel üzerine zemin renginden %0 → %85 dikey gradyan; metin yalnızca %60+ bölgede durur."},"_zorunluluklar":["Grafiklerde iki seri renkle BİRLİKTE biçimle de ayrılacak (Rusya dolu, Türkiye kesikli)","Motif CustomPainter ile çizilecek, görsel dosyası olarak gömülmeyecek","Kapak görseli bulunamazsa sayfa yine de tam çalışacak","Koyu sayfa sistem açık/koyu tercihini izlemeyecek; ana sayfa şeridi izleyecek","Tüm renkler bu dosyadan türetilen DossierTheme üzerinden gelecek","Kapak bloğu YOK — ülke dosyasında kapak ile gövde aynı koyu ada. Tema kapak renklerini gövdeden alıyor."]}$dsr$::jsonb,
  $dsr${"_dosya":"Rusya — Ülke Dosyası · kilitli veri sayfası","_uretim_tarihi":"2026-08-23T22:19:31.958Z","_kural":"Bu dosyadaki hiçbir rakam elle yazılmadı. Hepsi _raw/ altındaki ham çekimlerden türetildi. Metin bu dosyayı kaynak alır; buradaki bir sayı değişmeden metindeki karşılığı değişemez.","_yontem_uyarisi":"Rusya'ya ait rakamların çoğu AYNA İSTATİSTİKTİR: Rusya'nın kendi istatistik kurumu ve gümrük idaresi bu ağdan okunamadı. Türkiye–Rusya ticaretinde birincil kaynak Türkiye'nin kaydıdır. Bkz. _raw/README.md \"Kapalı kapılar\".","_kaynaklar":{"WB":{"ad":"World Bank — World Development Indicators","cekilme":"2026-08-23T12:21:13.761Z","lisans":"CC BY 4.0"},"PSD":{"ad":"USDA FAS — Production, Supply and Distribution","cekilme":"2026-08-23T12:26:50.485Z","lisans":"ABD kamu malı","kesin_son_yil":2024},"COMTRADE":{"ad":"UN Comtrade — Türkiye raporlayan (792), partner Rusya (643)","cekilme":"2026-08-23T12:25:50.404Z"},"FAO_QV":{"ad":"FAOSTAT — Value of Production","cekilme":"2026-08-23T12:31:25.945Z","lisans":"CC BY 4.0"},"FAO_QCL":{"ad":"FAOSTAT — Production: Crops and Livestock","cekilme":"2026-08-23T12:31:25.907Z","lisans":"CC BY 4.0"},"FAO_TM":{"ad":"FAOSTAT — Detailed Trade Matrix, Rusya raporlayan","cekilme":"2026-08-23T12:31:28.239Z","lisans":"CC BY 4.0"},"KURUM":{"ad":"Kurumsal ve mevzuat katmanı — elle doğrulanmış","dogrulama":"2026-08-23"},"TARIH":{"ad":"Tarih, bilim ve tarım kültürü katmanı — elle doğrulanmış","dogrulama":"2026-08-23"}},"tez":{"cumle":"Rusya hem pazarımız hem tedarikçimiz. Ama ondan aldığımız bir yıl bekler, ona sattığımız birkaç hafta dayanır.","cumle_en":"Russia is both our market and our supplier. But what we buy keeps for a year; what we sell keeps for weeks.","baslik":"Pazar dediğimiz ülke","dayanak":{"_aciklama":"Tez bir slogan değil, şu iki satırın farkı.","yil":2024,"rusyadan_aldigimiz_depolanabilir":{"tutar_usd":4520433426,"pay_yuzde":66.2},"rusyadan_aldigimiz_diger":{"tutar_usd":2304657766,"pay_yuzde":33.8},"rusyaya_sattigimiz_bozulur":{"tutar_usd":2799678998,"pay_yuzde":74.6},"rusyaya_sattigimiz_diger":{"tutar_usd":954064758,"pay_yuzde":25.4}}},"ikili_ticaret":{"_kaynak":"COMTRADE","_raporlayan":"Türkiye (792)","_raporlayan_notu":"Bütün rakamlar TÜRKİYE gümrük kaydıdır. Rusya kendi ayrıntılı ticaret verisini 2022'den beri yayımlamıyor; ayna istatistik zorunluluktur, tercih değil.","_birim":"cari ABD doları","_cift_sayim_kurali":"Yalnızca customsCode=C00 ve motCode=0 satırları toplanır.","son":{"yil":2024,"turkiyeden_rusyaya_usd":3753743756,"rusyadan_turkiyeye_usd":6825091192,"denge_usd":-3071347436},"seri":[{"yil":2013,"turkiyeden_rusyaya_usd":2369355430,"rusyadan_turkiyeye_usd":3726574110,"denge_usd":-1357218680,"gubre_rusyadan_usd":722593468},{"yil":2014,"turkiyeden_rusyaya_usd":2553370276,"rusyadan_turkiyeye_usd":5836116428,"denge_usd":-3282746152,"gubre_rusyadan_usd":730610514},{"yil":2015,"turkiyeden_rusyaya_usd":2223905784,"rusyadan_turkiyeye_usd":4270848840,"denge_usd":-2046943056,"gubre_rusyadan_usd":457419538},{"yil":2016,"turkiyeden_rusyaya_usd":1006381116,"rusyadan_turkiyeye_usd":3880827660,"denge_usd":-2874446544,"gubre_rusyadan_usd":553693212},{"yil":2017,"turkiyeden_rusyaya_usd":1659418698,"rusyadan_turkiyeye_usd":4024858812,"denge_usd":-2365440114,"gubre_rusyadan_usd":221517880},{"yil":2018,"turkiyeden_rusyaya_usd":1802754114,"rusyadan_turkiyeye_usd":4449313174,"denge_usd":-2646559060,"gubre_rusyadan_usd":272354168},{"yil":2019,"turkiyeden_rusyaya_usd":2128241010,"rusyadan_turkiyeye_usd":5226745440,"denge_usd":-3098504430,"gubre_rusyadan_usd":334298410},{"yil":2020,"turkiyeden_rusyaya_usd":2753522082,"rusyadan_turkiyeye_usd":6331385218,"denge_usd":-3577863136,"gubre_rusyadan_usd":156722358},{"yil":2021,"turkiyeden_rusyaya_usd":3298759140,"rusyadan_turkiyeye_usd":8651840244,"denge_usd":-5353081104,"gubre_rusyadan_usd":264540476},{"yil":2022,"turkiyeden_rusyaya_usd":4259664358,"rusyadan_turkiyeye_usd":10991702876,"denge_usd":-6732038518,"gubre_rusyadan_usd":710691376},{"yil":2023,"turkiyeden_rusyaya_usd":3824839336,"rusyadan_turkiyeye_usd":10462334182,"denge_usd":-6637494846,"gubre_rusyadan_usd":689092854},{"yil":2024,"turkiyeden_rusyaya_usd":3753743756,"rusyadan_turkiyeye_usd":6825091192,"denge_usd":-3071347436,"gubre_rusyadan_usd":376451288}],"fasil_kompozisyonu":{"yil":2024,"turkiyeden_rusyaya":[{"fasil":"08","deger_usd":1716586990},{"fasil":"03","deger_usd":866888838},{"fasil":"20","deger_usd":222843486},{"fasil":"07","deger_usd":216203170},{"fasil":"19","deger_usd":105056476},{"fasil":"18","deger_usd":103272316},{"fasil":"04","deger_usd":89469140},{"fasil":"12","deger_usd":87637008}],"rusyadan_turkiyeye":[{"fasil":"10","deger_usd":2909829552},{"fasil":"23","deger_usd":1555200884},{"fasil":"15","deger_usd":1520038938},{"fasil":"07","deger_usd":497623190},{"fasil":"24","deger_usd":101977216},{"fasil":"11","deger_usd":75335340},{"fasil":"12","deger_usd":55402990},{"fasil":"17","deger_usd":39846922}]}},"ambargo_2016":{"_aciklama":"Türkiye'nin Rusya'ya ihracatında 2015 → 2016 kırılması ve dokuz yıllık toparlanma. Tezin en somut kanıtı: bozulan ürünün pazarı geri gelmiyor.","_kaynak":"COMTRADE","_birim":"cari ABD doları","kalemler":[{"kod":"0702","ad":"Domates","seri":{"2013":549192574,"2014":551842210,"2015":517630196,"2016":0,"2017":4309960,"2018":60907160,"2019":170911716,"2020":123127698,"2021":134828238,"2022":66883828,"2023":79112100,"2024":87374328},"zirve_oncesi_2015":517630196,"dip_2016":0,"son":87374328,"toparlanma_orani_yuzde":16.9},{"kod":"0806","ad":"Üzüm","seri":{"2013":248531638,"2014":273800404,"2015":202002782,"2016":7818666,"2017":245782888,"2018":141766174,"2019":181225154,"2020":191423576,"2021":223264060,"2022":245266712,"2023":157331046,"2024":130379300},"zirve_oncesi_2015":202002782,"dip_2016":7818666,"son":130379300,"toparlanma_orani_yuzde":64.5},{"kod":"0805","ad":"Turunçgil","seri":{"2013":593885878,"2014":618271244,"2015":586913296,"2016":539010566,"2017":663520672,"2018":602208988,"2019":623877684,"2020":837061204,"2021":853108624,"2022":859084956,"2023":852423212,"2024":745991104},"zirve_oncesi_2015":586913296,"dip_2016":539010566,"son":745991104,"toparlanma_orani_yuzde":127.1}]},"tahil_donusumu":{"_aciklama":"SSCB dünyanın en büyük buğday alıcısıydı; Rusya en büyük satıcısı oldu. SSCB ve Rusya AYRI kayıtlardır, tek seri gibi birleştirilmez.","_kaynak":"PSD","_birim":"bin ton","_pazarlama_yili_notu":"Pazarlama yılı takvim yılı değildir. Buğdayda Rusya ve Türkiye için Temmuz-Haziran. \"2023\" = Temmuz 2023 - Haziran 2024.","_kesin_son_yil":2024,"sscb":{"_kapsam":"1960-1986, on beş cumhuriyet","ithalat":{"1960":585,"1961":239,"1962":242,"1963":9746,"1964":2222,"1965":8549,"1966":3082,"1967":1508,"1968":215,"1969":1147,"1970":484,"1971":3525,"1972":15590,"1973":4508,"1974":2500,"1975":10100,"1976":4600,"1977":6649,"1978":5142,"1979":12125,"1980":16000,"1981":20300,"1982":20800,"1983":20500,"1984":28100,"1985":15700,"1986":16000},"ihracat":{"1960":5020,"1961":5338,"1962":5744,"1963":2655,"1964":2197,"1965":2631,"1966":4387,"1967":5294,"1968":5829,"1969":6441,"1970":7203,"1971":5828,"1972":1300,"1973":5000,"1974":4000,"1975":500,"1976":1000,"1977":1000,"1978":1500,"1979":500,"1980":500,"1981":500,"1982":500,"1983":500,"1984":500,"1985":500,"1986":500},"uretim":{"1960":59350,"1961":61770,"1962":65735,"1963":46142,"1964":68874,"1965":55677,"1966":93227,"1967":71977,"1968":86526,"1969":73945,"1970":92601,"1971":91933,"1972":79571,"1973":102051,"1974":78272,"1975":61826,"1976":90097,"1977":86078,"1978":112948,"1979":83760,"1980":91485,"1981":75816,"1982":78886,"1983":72241,"1984":64175,"1985":72575,"1986":85998}},"rusya":{"_kapsam":"1987-, yalnızca Rusya Federasyonu","ithalat":{"1987":14900,"1988":9860,"1989":9100,"1990":10849,"1991":13645,"1992":14470,"1993":5000,"1994":2167,"1995":5316,"1996":2631,"1997":3120,"1998":2490,"1999":5083,"2000":1604,"2001":629,"2002":1045,"2003":1026,"2004":1225,"2005":1321,"2006":928,"2007":440,"2008":203,"2009":164,"2010":89,"2011":550,"2012":1172,"2013":862,"2014":330,"2015":819,"2016":505,"2017":467,"2018":446,"2019":325,"2020":400,"2021":300,"2022":300,"2023":300,"2024":300,"2025":300,"2026":300},"ihracat":{"1987":800,"1988":970,"1989":1150,"1990":1200,"1991":555,"1992":900,"1993":500,"1994":619,"1995":206,"1996":697,"1997":1111,"1998":1652,"1999":518,"2000":696,"2001":4372,"2002":12621,"2003":3114,"2004":7951,"2005":10664,"2006":10790,"2007":12220,"2008":18393,"2009":18556,"2010":3983,"2011":21627,"2012":11308,"2013":18609,"2014":22800,"2015":25546,"2016":27815,"2017":41447,"2018":35863,"2019":34485,"2020":39100,"2021":34000,"2022":49000,"2023":55500,"2024":43000,"2025":48000,"2026":46000},"uretim":{"1987":36868,"1988":39864,"1989":44004,"1990":49596,"1991":38900,"1992":46170,"1993":43500,"1994":32100,"1995":30100,"1996":34900,"1997":44250,"1998":27012,"1999":30995,"2000":34455,"2001":46982,"2002":50609,"2003":34070,"2004":45434,"2005":47615,"2006":44927,"2007":49368,"2008":63765,"2009":61770,"2010":41508,"2011":56240,"2012":37720,"2013":52091,"2014":59080,"2015":61044,"2016":72529,"2017":85167,"2018":71685,"2019":73610,"2020":85352,"2021":75158,"2022":92000,"2023":91500,"2024":81600,"2025":90300,"2026":88500}},"turkiye":{"ithalat":{"1960":373,"1961":1287,"1962":583,"1963":371,"1964":276,"1965":163,"1966":308,"1967":28,"1968":504,"1969":939,"1970":898,"1971":559,"1972":26,"1973":519,"1974":1059,"1975":20,"1976":0,"1977":6,"1978":0,"1979":0,"1980":0,"1981":748,"1982":49,"1983":350,"1984":1048,"1985":980,"1986":500,"1987":160,"1988":277,"1989":3698,"1990":291,"1991":172,"1992":997,"1993":650,"1994":500,"1995":2100,"1996":2630,"1997":1775,"1998":1862,"1999":1470,"2000":424,"2001":1037,"2002":1243,"2003":1089,"2004":390,"2005":125,"2006":1736,"2007":2160,"2008":3469,"2009":3192,"2010":3705,"2011":4066,"2012":1142,"2013":4070,"2014":5841,"2015":4087,"2016":4732,"2017":6222,"2018":6395,"2019":10851,"2020":8081,"2021":9421,"2022":12072,"2023":9350,"2024":3318,"2025":6321,"2026":5000},"ihracat":{"1960":1,"1961":1,"1962":0,"1963":0,"1964":0,"1965":0,"1966":0,"1967":0,"1968":2,"1969":0,"1970":0,"1971":17,"1972":560,"1973":19,"1974":0,"1975":0,"1976":52,"1977":1149,"1978":2023,"1979":440,"1980":530,"1981":337,"1982":573,"1983":600,"1984":517,"1985":112,"1986":52,"1987":933,"1988":1643,"1989":194,"1990":546,"1991":6241,"1992":2019,"1993":1065,"1994":1810,"1995":1054,"1996":967,"1997":1324,"1998":2626,"1999":2163,"2000":1601,"2001":753,"2002":794,"2003":839,"2004":2017,"2005":3214,"2006":2377,"2007":1722,"2008":2239,"2009":4266,"2010":3014,"2011":3670,"2012":1519,"2013":4449,"2014":4090,"2015":5878,"2016":6699,"2017":6698,"2018":6814,"2019":6534,"2020":6469,"2021":6714,"2022":6875,"2023":9950,"2024":7282,"2025":6468,"2026":6000},"uretim":{"1960":7000,"1961":6336,"1962":6804,"1963":7892,"1964":7000,"1965":7430,"1966":8200,"1967":9000,"1968":8400,"1969":8300,"1970":8000,"1971":10700,"1972":9500,"1973":8000,"1974":8300,"1975":11500,"1976":13000,"1977":13500,"1978":13300,"1979":13000,"1980":13000,"1981":13200,"1982":13800,"1983":13300,"1984":13300,"1985":12700,"1986":14000,"1987":13000,"1988":16000,"1989":12500,"1990":16000,"1991":16500,"1992":15500,"1993":16500,"1994":14700,"1995":15500,"1996":16000,"1997":16000,"1998":18000,"1999":16500,"2000":18000,"2001":15500,"2002":16800,"2003":16800,"2004":18500,"2005":18500,"2006":17500,"2007":15500,"2008":16800,"2009":18450,"2010":17000,"2011":18800,"2012":16000,"2013":18750,"2014":15250,"2015":19500,"2016":17250,"2017":21000,"2018":19000,"2019":17500,"2020":18250,"2021":16000,"2022":17250,"2023":21000,"2024":19000,"2025":16800,"2026":22500}}},"diger_tahillar":{"_aciklama":"Dönüşüm buğdayla sınırlı değil. Çavdar ters yöne gidiyor: dünya pazarı olmayan üründen vazgeçilmiş.","_kaynak":"PSD","_birim":"bin ton","urunler":[{"urun":"Barley","rusya_uretim":{"1987":26101,"1988":19418,"1989":22201,"1990":27235,"1991":22174,"1992":26989,"1993":26900,"1994":27000,"1995":15800,"1996":15932,"1997":20786,"1998":9797,"1999":10602,"2000":14078,"2001":19533,"2002":18738,"2003":18003,"2004":17180,"2005":15791,"2006":18155,"2007":15663,"2008":23148,"2009":17881,"2010":8350,"2011":16938,"2012":13952,"2013":15389,"2014":20026,"2015":17083,"2016":17547,"2017":20211,"2018":16737,"2019":19939,"2020":20629,"2021":17505,"2022":21500,"2023":20500,"2024":16250,"2025":19400,"2026":19500},"rusya_ihracat":{"1987":115,"1988":195,"1989":105,"1990":70,"1991":105,"1992":100,"1993":185,"1994":2031,"1995":800,"1996":149,"1997":1502,"1998":115,"1999":91,"2000":573,"2001":2593,"2002":3132,"2003":2318,"2004":1089,"2005":1726,"2006":1547,"2007":1046,"2008":3444,"2009":2657,"2010":267,"2011":3544,"2012":2237,"2013":2709,"2014":5348,"2015":4241,"2016":2951,"2017":5884,"2018":4661,"2019":4470,"2020":6259,"2021":3300,"2022":4500,"2023":6200,"2024":3400,"2025":4500,"2026":3500}},{"urun":"Corn","rusya_uretim":{"1987":3844,"1988":3814,"1989":4663,"1990":2451,"1991":1969,"1992":2135,"1993":2447,"1994":900,"1995":1700,"1996":1081,"1997":2652,"1998":800,"1999":1034,"2000":1489,"2001":808,"2002":1499,"2003":2031,"2004":3373,"2005":3060,"2006":3510,"2007":3798,"2008":6682,"2009":3963,"2010":3075,"2011":6962,"2012":8213,"2013":11635,"2014":11325,"2015":13168,"2016":15305,"2017":13201,"2018":11415,"2019":14275,"2020":13872,"2021":15225,"2022":15832,"2023":16600,"2024":14000,"2025":14800,"2026":17200},"rusya_ihracat":{"1987":500,"1988":100,"1989":150,"1990":400,"1991":300,"1992":100,"1993":4,"1994":1,"1995":0,"1996":0,"1997":16,"1998":13,"1999":0,"2000":1,"2001":0,"2002":12,"2003":0,"2004":44,"2005":53,"2006":77,"2007":49,"2008":1331,"2009":427,"2010":37,"2011":2027,"2012":1917,"2013":4194,"2014":3213,"2015":4691,"2016":5598,"2017":5532,"2018":2770,"2019":4072,"2020":3989,"2021":4000,"2022":5900,"2023":6600,"2024":3000,"2025":4000,"2026":3800}},{"urun":"Rye","rusya_uretim":{"1987":11079,"1988":12530,"1989":12593,"1990":16431,"1991":10624,"1992":13887,"1993":9151,"1994":6000,"1995":4100,"1996":5928,"1997":7476,"1998":3266,"1999":4781,"2000":5444,"2001":6632,"2002":7122,"2003":4147,"2004":2864,"2005":3622,"2006":2959,"2007":3909,"2008":4505,"2009":4333,"2010":1642,"2011":2967,"2012":2132,"2013":3360,"2014":3279,"2015":2084,"2016":2538,"2017":2540,"2018":1914,"2019":1424,"2020":2376,"2021":1716,"2022":2000,"2023":1700,"2024":1200,"2025":1000,"2026":900},"rusya_ihracat":{"1987":300,"1988":300,"1989":300,"1990":350,"1991":150,"1992":200,"1993":240,"1994":425,"1995":100,"1996":21,"1997":1,"1998":0,"1999":0,"2000":0,"2001":4,"2002":291,"2003":156,"2004":0,"2005":0,"2006":26,"2007":119,"2008":16,"2009":12,"2010":0,"2011":238,"2012":133,"2013":74,"2014":114,"2015":48,"2016":9,"2017":71,"2018":283,"2019":1,"2020":83,"2021":125,"2022":65,"2023":190,"2024":70,"2025":20,"2026":25}}]},"alan_ve_verim":{"_aciklama":"Buğday üretimi iki bileşene ayrılınca ayrışma görünüyor: iki ülke de verimini yaklaşık yüzde elli artırdı; Rusya alanı büyüttü, Türkiye küçülttü.","_kaynak":"PSD","_birimler":{"alan":"bin hektar","verim":"ton/hektar","uretim":"bin ton"},"RUS":{"alan":{"1987":23974,"1988":24575,"1989":24376,"1990":23540,"1991":22520,"1992":23550,"1993":23880,"1994":20990,"1995":21570,"1996":22540,"1997":24020,"1998":19950,"1999":19820,"2000":21300,"2001":22780,"2002":24430,"2003":20020,"2004":22920,"2005":24580,"2006":22960,"2007":23480,"2008":26100,"2009":26690,"2010":21750,"2011":24814,"2012":21296,"2013":23399,"2014":23636,"2015":25577,"2016":27004,"2017":27370,"2018":26344,"2019":27312,"2020":28683,"2021":27630,"2022":29000,"2023":28830,"2024":27800,"2025":26300,"2026":25100},"verim":{"1987":1.54,"1988":1.62,"1989":1.81,"1990":2.11,"1991":1.73,"1992":1.96,"1993":1.82,"1994":1.53,"1995":1.4,"1996":1.55,"1997":1.84,"1998":1.35,"1999":1.56,"2000":1.62,"2001":2.06,"2002":2.07,"2003":1.7,"2004":1.98,"2005":1.94,"2006":1.96,"2007":2.1,"2008":2.44,"2009":2.31,"2010":1.91,"2011":2.27,"2012":1.77,"2013":2.23,"2014":2.5,"2015":2.39,"2016":2.69,"2017":3.11,"2018":2.72,"2019":2.7,"2020":2.98,"2021":2.72,"2022":3.17,"2023":3.17,"2024":2.94,"2025":3.43,"2026":3.53}},"TUR":{"alan":{"1960":7700,"1961":7717,"1962":7800,"1963":7850,"1964":7870,"1965":7900,"1966":7950,"1967":8000,"1968":8100,"1969":8300,"1970":8200,"1971":8200,"1972":8100,"1973":8100,"1974":8200,"1975":8500,"1976":8600,"1977":8500,"1978":8600,"1979":8600,"1980":8600,"1981":8500,"1982":8600,"1983":8700,"1984":8600,"1985":8600,"1986":8700,"1987":8700,"1988":8750,"1989":8700,"1990":8750,"1991":8800,"1992":8800,"1993":8850,"1994":8600,"1995":8550,"1996":8450,"1997":8500,"1998":8550,"1999":8650,"2000":8700,"2001":8500,"2002":8550,"2003":8600,"2004":8600,"2005":8600,"2006":8600,"2007":7700,"2008":7700,"2009":7800,"2010":8000,"2011":7700,"2012":7800,"2013":7700,"2014":7710,"2015":7860,"2016":7815,"2017":7800,"2018":7615,"2019":7000,"2020":7100,"2021":7050,"2022":6800,"2023":7200,"2024":7250,"2025":7300,"2026":7450},"verim":{"1960":0.91,"1961":0.82,"1962":0.87,"1963":1.01,"1964":0.89,"1965":0.94,"1966":1.03,"1967":1.13,"1968":1.04,"1969":1,"1970":0.98,"1971":1.3,"1972":1.17,"1973":0.99,"1974":1.01,"1975":1.35,"1976":1.51,"1977":1.59,"1978":1.55,"1979":1.51,"1980":1.51,"1981":1.55,"1982":1.6,"1983":1.53,"1984":1.55,"1985":1.48,"1986":1.61,"1987":1.49,"1988":1.83,"1989":1.44,"1990":1.83,"1991":1.88,"1992":1.76,"1993":1.86,"1994":1.71,"1995":1.81,"1996":1.89,"1997":1.88,"1998":2.11,"1999":1.91,"2000":2.07,"2001":1.82,"2002":1.96,"2003":1.95,"2004":2.15,"2005":2.15,"2006":2.03,"2007":2.01,"2008":2.18,"2009":2.37,"2010":2.13,"2011":2.44,"2012":2.05,"2013":2.44,"2014":1.98,"2015":2.48,"2016":2.21,"2017":2.69,"2018":2.5,"2019":2.5,"2020":2.57,"2021":2.27,"2022":2.54,"2023":2.92,"2024":2.62,"2025":2.3,"2026":3.02}}},"karadeniz_havzasi":{"_aciklama":"Ayçiçeğinde ve buğdayda Rusya tek başına ele alınamaz. Kaynak çeşitlendirmesi Rusya'dan Ukrayna'ya geçmekle olmuyor: ikisi de aynı havzada.","_kaynak":"PSD","_birim":"bin ton","aycicegi_yagi_ihracat":{"RUS":{"1987":60,"1988":105,"1989":115,"1990":105,"1991":0,"1992":10,"1993":40,"1994":21,"1995":25,"1996":35,"1997":35,"1998":55,"1999":195,"2000":130,"2001":41,"2002":103,"2003":136,"2004":226,"2005":616,"2006":711,"2007":322,"2008":802,"2009":504,"2010":180,"2011":1427,"2012":1013,"2013":1800,"2014":1456,"2015":1541,"2016":2178,"2017":2310,"2018":2652,"2019":3830,"2020":3246,"2021":3250,"2022":4000,"2023":4400,"2024":4200,"2025":4200,"2026":5000},"UKR":{"1987":60,"1988":105,"1989":115,"1990":105,"1991":150,"1992":120,"1993":100,"1994":150,"1995":200,"1996":209,"1997":180,"1998":205,"1999":430,"2000":550,"2001":308,"2002":911,"2003":978,"2004":642,"2005":1514,"2006":1867,"2007":1325,"2008":2098,"2009":2645,"2010":2652,"2011":3263,"2012":3245,"2013":4181,"2014":3872,"2015":4500,"2016":5851,"2017":5342,"2018":6063,"2019":6686,"2020":5273,"2021":4465,"2022":5624,"2023":6264,"2024":4744,"2025":4100,"2026":4950}},"bugday_ihracat":{"RUS":{"1987":800,"1988":970,"1989":1150,"1990":1200,"1991":555,"1992":900,"1993":500,"1994":619,"1995":206,"1996":697,"1997":1111,"1998":1652,"1999":518,"2000":696,"2001":4372,"2002":12621,"2003":3114,"2004":7951,"2005":10664,"2006":10790,"2007":12220,"2008":18393,"2009":18556,"2010":3983,"2011":21627,"2012":11308,"2013":18609,"2014":22800,"2015":25546,"2016":27815,"2017":41447,"2018":35863,"2019":34485,"2020":39100,"2021":34000,"2022":49000,"2023":55500,"2024":43000,"2025":48000,"2026":46000},"UKR":{"1987":1675,"1988":2355,"1989":3000,"1990":2000,"1991":225,"1992":100,"1993":500,"1994":140,"1995":1343,"1996":1285,"1997":1364,"1998":4696,"1999":1952,"2000":78,"2001":5486,"2002":6569,"2003":66,"2004":4403,"2005":6461,"2006":3366,"2007":1236,"2008":13037,"2009":9337,"2010":4302,"2011":5436,"2012":7190,"2013":9755,"2014":11269,"2015":17431,"2016":18107,"2017":17775,"2018":16019,"2019":21016,"2020":16851,"2021":18844,"2022":17122,"2023":18577,"2024":15751,"2025":14104,"2026":13500}}},"isleme_makinesi":{"_aciklama":"Türkiye hammaddeyi alıp işleyip satıyor. Buğdayda un, ayçiçeğinde yağ. Haziran 2024'te durdurulan şey tam olarak bu zincirdi (bkz. kurumlar.turkiye_2024_karari).","_kaynak":"PSD","_birim":"bin ton","_yil":2024,"kalemler":[{"urun":"Buğday","turkiye":{"uretim":19000,"ithalat":3318,"ihracat":7282},"rusya":{"uretim":81600,"ihracat":43000},"turkiye_seri":{"uretim":{"1960":7000,"1961":6336,"1962":6804,"1963":7892,"1964":7000,"1965":7430,"1966":8200,"1967":9000,"1968":8400,"1969":8300,"1970":8000,"1971":10700,"1972":9500,"1973":8000,"1974":8300,"1975":11500,"1976":13000,"1977":13500,"1978":13300,"1979":13000,"1980":13000,"1981":13200,"1982":13800,"1983":13300,"1984":13300,"1985":12700,"1986":14000,"1987":13000,"1988":16000,"1989":12500,"1990":16000,"1991":16500,"1992":15500,"1993":16500,"1994":14700,"1995":15500,"1996":16000,"1997":16000,"1998":18000,"1999":16500,"2000":18000,"2001":15500,"2002":16800,"2003":16800,"2004":18500,"2005":18500,"2006":17500,"2007":15500,"2008":16800,"2009":18450,"2010":17000,"2011":18800,"2012":16000,"2013":18750,"2014":15250,"2015":19500,"2016":17250,"2017":21000,"2018":19000,"2019":17500,"2020":18250,"2021":16000,"2022":17250,"2023":21000,"2024":19000,"2025":16800,"2026":22500},"ithalat":{"1960":373,"1961":1287,"1962":583,"1963":371,"1964":276,"1965":163,"1966":308,"1967":28,"1968":504,"1969":939,"1970":898,"1971":559,"1972":26,"1973":519,"1974":1059,"1975":20,"1976":0,"1977":6,"1978":0,"1979":0,"1980":0,"1981":748,"1982":49,"1983":350,"1984":1048,"1985":980,"1986":500,"1987":160,"1988":277,"1989":3698,"1990":291,"1991":172,"1992":997,"1993":650,"1994":500,"1995":2100,"1996":2630,"1997":1775,"1998":1862,"1999":1470,"2000":424,"2001":1037,"2002":1243,"2003":1089,"2004":390,"2005":125,"2006":1736,"2007":2160,"2008":3469,"2009":3192,"2010":3705,"2011":4066,"2012":1142,"2013":4070,"2014":5841,"2015":4087,"2016":4732,"2017":6222,"2018":6395,"2019":10851,"2020":8081,"2021":9421,"2022":12072,"2023":9350,"2024":3318,"2025":6321,"2026":5000},"ihracat":{"1960":1,"1961":1,"1962":0,"1963":0,"1964":0,"1965":0,"1966":0,"1967":0,"1968":2,"1969":0,"1970":0,"1971":17,"1972":560,"1973":19,"1974":0,"1975":0,"1976":52,"1977":1149,"1978":2023,"1979":440,"1980":530,"1981":337,"1982":573,"1983":600,"1984":517,"1985":112,"1986":52,"1987":933,"1988":1643,"1989":194,"1990":546,"1991":6241,"1992":2019,"1993":1065,"1994":1810,"1995":1054,"1996":967,"1997":1324,"1998":2626,"1999":2163,"2000":1601,"2001":753,"2002":794,"2003":839,"2004":2017,"2005":3214,"2006":2377,"2007":1722,"2008":2239,"2009":4266,"2010":3014,"2011":3670,"2012":1519,"2013":4449,"2014":4090,"2015":5878,"2016":6699,"2017":6698,"2018":6814,"2019":6534,"2020":6469,"2021":6714,"2022":6875,"2023":9950,"2024":7282,"2025":6468,"2026":6000}}},{"urun":"Ayçiçeği yağı","turkiye":{"uretim":795,"ithalat":1236,"ihracat":1001},"rusya":{"uretim":6732,"ihracat":4200},"turkiye_seri":{"uretim":{"1972":226,"1973":226,"1974":170,"1975":197,"1976":204,"1977":184,"1978":196,"1979":196,"1980":245,"1981":223,"1982":228,"1983":275,"1984":284,"1985":279,"1986":380,"1987":355,"1988":312,"1989":540,"1990":406,"1991":299,"1992":420,"1993":319,"1994":445,"1995":482,"1996":410,"1997":506,"1998":512,"1999":520,"2000":383,"2001":280,"2002":430,"2003":525,"2004":486,"2005":473,"2006":516,"2007":516,"2008":516,"2009":624,"2010":667,"2011":688,"2012":720,"2013":774,"2014":677,"2015":587,"2016":761,"2017":881,"2018":1066,"2019":1088,"2020":1044,"2021":925,"2022":1066,"2023":696,"2024":795,"2025":1109,"2026":1077},"ithalat":{"1972":0,"1973":5,"1974":24,"1975":15,"1976":0,"1977":0,"1978":13,"1979":34,"1980":10,"1981":3,"1982":19,"1983":76,"1984":69,"1985":56,"1986":48,"1987":153,"1988":204,"1989":209,"1990":266,"1991":322,"1992":154,"1993":278,"1994":316,"1995":200,"1996":240,"1997":161,"1998":140,"1999":104,"2000":106,"2001":147,"2002":68,"2003":83,"2004":152,"2005":451,"2006":145,"2007":326,"2008":432,"2009":184,"2010":401,"2011":651,"2012":622,"2013":771,"2014":833,"2015":704,"2016":834,"2017":545,"2018":569,"2019":870,"2020":778,"2021":1308,"2022":1711,"2023":1491,"2024":1236,"2025":1300,"2026":1600},"ihracat":{"1972":0,"1973":0,"1974":0,"1975":0,"1976":0,"1977":0,"1978":0,"1979":0,"1980":5,"1981":5,"1982":0,"1983":1,"1984":5,"1985":20,"1986":33,"1987":38,"1988":74,"1989":99,"1990":88,"1991":182,"1992":73,"1993":122,"1994":167,"1995":65,"1996":65,"1997":122,"1998":85,"1999":62,"2000":4,"2001":1,"2002":29,"2003":16,"2004":22,"2005":99,"2006":34,"2007":54,"2008":131,"2009":68,"2010":157,"2011":271,"2012":288,"2013":588,"2014":644,"2015":613,"2016":685,"2017":418,"2018":496,"2019":715,"2020":639,"2021":889,"2022":1102,"2023":1189,"2024":1001,"2025":1000,"2026":1100}}},{"urun":"Ayçiçeği tohumu","turkiye":{"uretim":1350,"ithalat":789,"ihracat":174},"rusya":{"uretim":16900,"ihracat":200},"turkiye_seri":{"uretim":{"1972":560,"1973":560,"1974":420,"1975":488,"1976":505,"1977":455,"1978":485,"1979":590,"1980":750,"1981":575,"1982":600,"1983":685,"1984":710,"1985":700,"1986":940,"1987":895,"1988":1100,"1989":1200,"1990":860,"1991":650,"1992":980,"1993":700,"1994":600,"1995":750,"1996":545,"1997":650,"1998":650,"1999":800,"2000":575,"2001":520,"2002":820,"2003":600,"2004":650,"2005":750,"2006":850,"2007":700,"2008":830,"2009":800,"2010":1000,"2011":925,"2012":1125,"2013":1400,"2014":1200,"2015":1100,"2016":1320,"2017":1550,"2018":1800,"2019":1750,"2020":1560,"2021":1750,"2022":1900,"2023":1550,"2024":1350,"2025":1250,"2026":1825},"ithalat":{"1972":0,"1973":0,"1974":0,"1975":0,"1976":0,"1977":0,"1978":0,"1979":0,"1980":0,"1981":0,"1982":0,"1983":0,"1984":1,"1985":2,"1986":0,"1987":11,"1988":0,"1989":3,"1990":33,"1991":104,"1992":50,"1993":100,"1994":550,"1995":500,"1996":360,"1997":583,"1998":595,"1999":437,"2000":321,"2001":165,"2002":229,"2003":660,"2004":529,"2005":407,"2006":498,"2007":533,"2008":446,"2009":736,"2010":705,"2011":834,"2012":609,"2013":597,"2014":462,"2015":483,"2016":656,"2017":770,"2018":1116,"2019":1178,"2020":907,"2021":669,"2022":941,"2023":328,"2024":789,"2025":1700,"2026":1000},"ihracat":{"1972":0,"1973":0,"1974":0,"1975":0,"1976":0,"1977":0,"1978":0,"1979":0,"1980":0,"1981":0,"1982":0,"1983":0,"1984":0,"1985":0,"1986":0,"1987":0,"1988":0,"1989":0,"1990":0,"1991":2,"1992":2,"1993":2,"1994":2,"1995":2,"1996":0,"1997":0,"1998":0,"1999":0,"2000":2,"2001":2,"2002":4,"2003":5,"2004":7,"2005":9,"2006":12,"2007":8,"2008":13,"2009":20,"2010":26,"2011":38,"2012":50,"2013":57,"2014":41,"2015":109,"2016":126,"2017":148,"2018":116,"2019":99,"2020":123,"2021":118,"2022":102,"2023":102,"2024":174,"2025":125,"2026":100}}}]},"musteriler":{"_aciklama":"Rusya'nın tarım ihracatında Türkiye kaçıncı sırada. Bu tablo ilişkinin karşılıklı olduğunu gösteriyor: Rusya bizim en büyük tedarikçimiz, biz de onun en büyük müşterisiyiz.","_kaynak":"FAO_TM","_raporlayan":"Rusya Federasyonu","_uyari":"Bu tablo RUSYA raporlayanın kaydıdır. Türkiye-Rusya ikili ticaretinde birincil kaynak comtrade_ikili.json (Türkiye raporlayan) olarak kalır; bu tablo Rusya'nın DÜNYA müşterileri arasında Türkiye'nin yerini göstermek için var.","_kesinti_notu":"Rusya'nın FAOSTAT'a raporlaması 2021'de bitiyor. Sonraki yıllar yok. Bu, dosyanın yöntem iddiasının veriyle görünen hâli.","son_yil":2021,"birincilik":{"ilk_birincilik_yili":2012,"birinci_oldugu_yil_sayisi":9,"ilk_yildan_beri_istisnalar":[{"yil":2018,"sira":2}],"en_dusuk":{"yil":2001,"sira":18}},"son_siralama":{"yil":2021,"ilk_5":[{"sira":1,"ulke":"Türkiye","deger_1000usd":4329243},{"sira":2,"ulke":"Kazakhstan","deger_1000usd":2690417},{"sira":3,"ulke":"China, mainland","deger_1000usd":2236011},{"sira":4,"ulke":"Egypt","deger_1000usd":1834569},{"sira":5,"ulke":"Belarus","deger_1000usd":1707345}]},"seri":{"1998":{"turkiye_sirasi":2,"turkiye_1000usd":123102,"toplam_1000usd":1027910,"turkiye_payi_yuzde":12,"partner_sayisi":89,"ilk_5":[{"sira":1,"ulke":"Kazakhstan","deger_1000usd":158892},{"sira":2,"ulke":"Türkiye","deger_1000usd":123102},{"sira":3,"ulke":"Italy","deger_1000usd":87585},{"sira":4,"ulke":"Netherlands (Kingdom of the)","deger_1000usd":61499},{"sira":5,"ulke":"Spain","deger_1000usd":42480}]},"1999":{"turkiye_sirasi":4,"turkiye_1000usd":36777,"toplam_1000usd":608347,"turkiye_payi_yuzde":6,"partner_sayisi":89,"ilk_5":[{"sira":1,"ulke":"Kazakhstan","deger_1000usd":121772},{"sira":2,"ulke":"Italy","deger_1000usd":68901},{"sira":3,"ulke":"Azerbaijan","deger_1000usd":44328},{"sira":4,"ulke":"Türkiye","deger_1000usd":36777},{"sira":5,"ulke":"Ukraine","deger_1000usd":27794}]},"2000":{"turkiye_sirasi":3,"turkiye_1000usd":80974,"toplam_1000usd":1081245,"turkiye_payi_yuzde":7.5,"partner_sayisi":96,"ilk_5":[{"sira":1,"ulke":"Kazakhstan","deger_1000usd":212222},{"sira":2,"ulke":"Italy","deger_1000usd":94852},{"sira":3,"ulke":"Türkiye","deger_1000usd":80974},{"sira":4,"ulke":"Ukraine","deger_1000usd":80382},{"sira":5,"ulke":"Netherlands (Kingdom of the)","deger_1000usd":62389}]},"2001":{"turkiye_sirasi":18,"turkiye_1000usd":17648,"toplam_1000usd":1098996,"turkiye_payi_yuzde":1.6,"partner_sayisi":92,"ilk_5":[{"sira":1,"ulke":"Kazakhstan","deger_1000usd":203048},{"sira":2,"ulke":"Ukraine","deger_1000usd":126055},{"sira":3,"ulke":"Italy","deger_1000usd":107452},{"sira":4,"ulke":"Saudi Arabia","deger_1000usd":44845},{"sira":5,"ulke":"Greece","deger_1000usd":38175}]},"2002":{"turkiye_sirasi":11,"turkiye_1000usd":46356,"toplam_1000usd":1829956,"turkiye_payi_yuzde":2.5,"partner_sayisi":101,"ilk_5":[{"sira":1,"ulke":"Italy","deger_1000usd":200409},{"sira":2,"ulke":"Ukraine","deger_1000usd":169176},{"sira":3,"ulke":"Kazakhstan","deger_1000usd":169135},{"sira":4,"ulke":"Egypt","deger_1000usd":119836},{"sira":5,"ulke":"Saudi Arabia","deger_1000usd":91327}]},"2003":{"turkiye_sirasi":8,"turkiye_1000usd":84141,"toplam_1000usd":2322579,"turkiye_payi_yuzde":3.6,"partner_sayisi":105,"ilk_5":[{"sira":1,"ulke":"Ukraine","deger_1000usd":372539},{"sira":2,"ulke":"Kazakhstan","deger_1000usd":265098},{"sira":3,"ulke":"Saudi Arabia","deger_1000usd":166528},{"sira":4,"ulke":"Italy","deger_1000usd":112807},{"sira":5,"ulke":"Georgia","deger_1000usd":87342}]},"2004":{"turkiye_sirasi":7,"turkiye_1000usd":83038,"toplam_1000usd":2181326,"turkiye_payi_yuzde":3.8,"partner_sayisi":104,"ilk_5":[{"sira":1,"ulke":"Kazakhstan","deger_1000usd":352618},{"sira":2,"ulke":"Ukraine","deger_1000usd":257536},{"sira":3,"ulke":"Azerbaijan","deger_1000usd":147106},{"sira":4,"ulke":"Egypt","deger_1000usd":132967},{"sira":5,"ulke":"Georgia","deger_1000usd":123098}]},"2005":{"turkiye_sirasi":8,"turkiye_1000usd":79613,"toplam_1000usd":3434892,"turkiye_payi_yuzde":2.3,"partner_sayisi":104,"ilk_5":[{"sira":1,"ulke":"Kazakhstan","deger_1000usd":512070},{"sira":2,"ulke":"Ukraine","deger_1000usd":399925},{"sira":3,"ulke":"Egypt","deger_1000usd":344120},{"sira":4,"ulke":"Azerbaijan","deger_1000usd":211316},{"sira":5,"ulke":"Georgia","deger_1000usd":177721}]},"2006":{"turkiye_sirasi":9,"turkiye_1000usd":97677,"toplam_1000usd":4355646,"turkiye_payi_yuzde":2.2,"partner_sayisi":104,"ilk_5":[{"sira":1,"ulke":"Kazakhstan","deger_1000usd":704552},{"sira":2,"ulke":"Ukraine","deger_1000usd":442426},{"sira":3,"ulke":"Egypt","deger_1000usd":354195},{"sira":4,"ulke":"India","deger_1000usd":280581},{"sira":5,"ulke":"Georgia","deger_1000usd":238991}]},"2007":{"turkiye_sirasi":4,"turkiye_1000usd":353310,"toplam_1000usd":7720905,"turkiye_payi_yuzde":4.6,"partner_sayisi":115,"ilk_5":[{"sira":1,"ulke":"Kazakhstan","deger_1000usd":1058524},{"sira":2,"ulke":"Egypt","deger_1000usd":1052360},{"sira":3,"ulke":"Ukraine","deger_1000usd":672978},{"sira":4,"ulke":"Türkiye","deger_1000usd":353310},{"sira":5,"ulke":"India","deger_1000usd":344657}]},"2008":{"turkiye_sirasi":4,"turkiye_1000usd":538585,"toplam_1000usd":7886282,"turkiye_payi_yuzde":6.8,"partner_sayisi":116,"ilk_5":[{"sira":1,"ulke":"Kazakhstan","deger_1000usd":1294800},{"sira":2,"ulke":"Ukraine","deger_1000usd":731759},{"sira":3,"ulke":"Egypt","deger_1000usd":715987},{"sira":4,"ulke":"Türkiye","deger_1000usd":538585},{"sira":5,"ulke":"Azerbaijan","deger_1000usd":516985}]},"2009":{"turkiye_sirasi":3,"turkiye_1000usd":563448,"toplam_1000usd":7510201,"turkiye_payi_yuzde":7.5,"partner_sayisi":124,"ilk_5":[{"sira":1,"ulke":"Kazakhstan","deger_1000usd":1061634},{"sira":2,"ulke":"Egypt","deger_1000usd":893631},{"sira":3,"ulke":"Türkiye","deger_1000usd":563448},{"sira":4,"ulke":"Ukraine","deger_1000usd":513203},{"sira":5,"ulke":"Azerbaijan","deger_1000usd":429755}]},"2010":{"turkiye_sirasi":2,"turkiye_1000usd":547637,"toplam_1000usd":5849329,"turkiye_payi_yuzde":9.4,"partner_sayisi":126,"ilk_5":[{"sira":1,"ulke":"Egypt","deger_1000usd":893289},{"sira":2,"ulke":"Türkiye","deger_1000usd":547637},{"sira":3,"ulke":"Ukraine","deger_1000usd":538693},{"sira":4,"ulke":"Kazakhstan","deger_1000usd":498404},{"sira":5,"ulke":"Azerbaijan","deger_1000usd":340723}]},"2011":{"turkiye_sirasi":2,"turkiye_1000usd":1053786,"toplam_1000usd":8821287,"turkiye_payi_yuzde":11.9,"partner_sayisi":141,"ilk_5":[{"sira":1,"ulke":"Egypt","deger_1000usd":1355631},{"sira":2,"ulke":"Türkiye","deger_1000usd":1053786},{"sira":3,"ulke":"Ukraine","deger_1000usd":666455},{"sira":4,"ulke":"Azerbaijan","deger_1000usd":551096},{"sira":5,"ulke":"Saudi Arabia","deger_1000usd":383576}]},"2012":{"turkiye_sirasi":1,"turkiye_1000usd":1963653,"toplam_1000usd":14262480,"turkiye_payi_yuzde":13.8,"partner_sayisi":139,"ilk_5":[{"sira":1,"ulke":"Türkiye","deger_1000usd":1963653},{"sira":2,"ulke":"Egypt","deger_1000usd":1811068},{"sira":3,"ulke":"Kazakhstan","deger_1000usd":1341339},{"sira":4,"ulke":"Ukraine","deger_1000usd":673200},{"sira":5,"ulke":"Azerbaijan","deger_1000usd":582917}]},"2013":{"turkiye_sirasi":1,"turkiye_1000usd":1732425,"toplam_1000usd":13387031,"turkiye_payi_yuzde":12.9,"partner_sayisi":139,"ilk_5":[{"sira":1,"ulke":"Türkiye","deger_1000usd":1732425},{"sira":2,"ulke":"Kazakhstan","deger_1000usd":1565771},{"sira":3,"ulke":"Egypt","deger_1000usd":875194},{"sira":4,"ulke":"Ukraine","deger_1000usd":767245},{"sira":5,"ulke":"Belarus","deger_1000usd":747105}]},"2014":{"turkiye_sirasi":1,"turkiye_1000usd":2401104,"toplam_1000usd":16107697,"turkiye_payi_yuzde":14.9,"partner_sayisi":146,"ilk_5":[{"sira":1,"ulke":"Türkiye","deger_1000usd":2401104},{"sira":2,"ulke":"Kazakhstan","deger_1000usd":1680456},{"sira":3,"ulke":"Egypt","deger_1000usd":1386627},{"sira":4,"ulke":"Belarus","deger_1000usd":921749},{"sira":5,"ulke":"Azerbaijan","deger_1000usd":768697}]},"2015":{"turkiye_sirasi":1,"turkiye_1000usd":1816379,"toplam_1000usd":13353901,"turkiye_payi_yuzde":13.6,"partner_sayisi":148,"ilk_5":[{"sira":1,"ulke":"Türkiye","deger_1000usd":1816379},{"sira":2,"ulke":"Kazakhstan","deger_1000usd":1269796},{"sira":3,"ulke":"Egypt","deger_1000usd":1019391},{"sira":4,"ulke":"Belarus","deger_1000usd":700501},{"sira":5,"ulke":"Azerbaijan","deger_1000usd":667349}]},"2016":{"turkiye_sirasi":1,"turkiye_1000usd":1679933,"toplam_1000usd":13979969,"turkiye_payi_yuzde":12,"partner_sayisi":152,"ilk_5":[{"sira":1,"ulke":"Türkiye","deger_1000usd":1679933},{"sira":2,"ulke":"Kazakhstan","deger_1000usd":1291373},{"sira":3,"ulke":"Egypt","deger_1000usd":1238164},{"sira":4,"ulke":"Belarus","deger_1000usd":751688},{"sira":5,"ulke":"China, mainland","deger_1000usd":552898}]},"2017":{"turkiye_sirasi":1,"turkiye_1000usd":1788112,"toplam_1000usd":17077982,"turkiye_payi_yuzde":10.5,"partner_sayisi":151,"ilk_5":[{"sira":1,"ulke":"Türkiye","deger_1000usd":1788112},{"sira":2,"ulke":"Egypt","deger_1000usd":1779855},{"sira":3,"ulke":"Kazakhstan","deger_1000usd":1419373},{"sira":4,"ulke":"Belarus","deger_1000usd":934959},{"sira":5,"ulke":"China, mainland","deger_1000usd":661270}]},"2018":{"turkiye_sirasi":2,"turkiye_1000usd":1867850,"toplam_1000usd":20380049,"turkiye_payi_yuzde":9.2,"partner_sayisi":156,"ilk_5":[{"sira":1,"ulke":"Egypt","deger_1000usd":2147709},{"sira":2,"ulke":"Türkiye","deger_1000usd":1867850},{"sira":3,"ulke":"Kazakhstan","deger_1000usd":1485012},{"sira":4,"ulke":"Belarus","deger_1000usd":1155118},{"sira":5,"ulke":"China, mainland","deger_1000usd":984091}]},"2019":{"turkiye_sirasi":1,"turkiye_1000usd":2506994,"toplam_1000usd":19945947,"turkiye_payi_yuzde":12.6,"partner_sayisi":153,"ilk_5":[{"sira":1,"ulke":"Türkiye","deger_1000usd":2506994},{"sira":2,"ulke":"Kazakhstan","deger_1000usd":1806249},{"sira":3,"ulke":"Egypt","deger_1000usd":1469764},{"sira":4,"ulke":"China, mainland","deger_1000usd":1442675},{"sira":5,"ulke":"Belarus","deger_1000usd":1280642}]},"2020":{"turkiye_sirasi":1,"turkiye_1000usd":3125731,"toplam_1000usd":23409904,"turkiye_payi_yuzde":13.4,"partner_sayisi":155,"ilk_5":[{"sira":1,"ulke":"Türkiye","deger_1000usd":3125731},{"sira":2,"ulke":"China, mainland","deger_1000usd":2307591},{"sira":3,"ulke":"Kazakhstan","deger_1000usd":2010401},{"sira":4,"ulke":"Egypt","deger_1000usd":1954899},{"sira":5,"ulke":"Belarus","deger_1000usd":1309341}]},"2021":{"turkiye_sirasi":1,"turkiye_1000usd":4329243,"toplam_1000usd":26434619,"turkiye_payi_yuzde":16.4,"partner_sayisi":159,"ilk_5":[{"sira":1,"ulke":"Türkiye","deger_1000usd":4329243},{"sira":2,"ulke":"Kazakhstan","deger_1000usd":2690417},{"sira":3,"ulke":"China, mainland","deger_1000usd":2236011},{"sira":4,"ulke":"Egypt","deger_1000usd":1834569},{"sira":5,"ulke":"Belarus","deger_1000usd":1707345}]}}},"uretim_degeri":{"_aciklama":"Rusya'nın üstünlüğü neredeyse tamamen tahılda. Diğer her şeyde iki ülke yakın. Türk tarımı geride değil, farklı uzmanlaşmış.","_kaynak":"FAO_QV","_birim":"bin sabit 2014-2016 uluslararası dolar","_uyari":"SABİT 2014-16 uluslararası doları. Cari dolarlı ticaret rakamlarıyla aynı cümlede oran olarak KULLANILAMAZ.","kalemler":[{"kalem":"Agriculture","yil":2023,"RUS":111025504,"TUR":79879045,"oran_RUS_TUR":1.39,"_ileri_not":null},{"kalem":"Crops","yil":2023,"RUS":64519583,"TUR":54519696,"oran_RUS_TUR":1.18,"_ileri_not":null},{"kalem":"Livestock","yil":2023,"RUS":46505921,"TUR":25359349,"oran_RUS_TUR":1.83,"_ileri_not":null},{"kalem":"Cereals, primary","yil":2023,"RUS":30981859,"TUR":9387290,"oran_RUS_TUR":3.3,"_ileri_not":null}],"seyir":{"_aciklama":"Rusya 1990'larda çöktü ve geri geldi; Türkiye kesintisiz büyüdü.","yillar":[{"yil":1992,"RUS":92289307,"TUR":40030680},{"yil":2000,"RUS":61489643,"TUR":46312842},{"yil":2010,"RUS":65786430,"TUR":55529187},{"yil":2020,"RUS":99723089,"TUR":75351516},{"yil":2023,"RUS":111025504,"TUR":79879045}]}},"toprak_ve_verim":{"_aciklama":"Rusya'nın elinde beş buçuk kat arazi var. Ama hektar başına tahıl verimi Türkiye'ninkinden yüksek DEĞİL. Fark toprağın genişliğinde, veriminde değil.","_kaynak":"WB","satirlar":[{"etiket":"Tarım arazisi","birim":"Tarım arazisi (km²)","yil":2023,"RUS":2157010,"TUR":385880,"oran_RUS_TUR":5.59,"_ileri_not":null,"kaynak":"WB"},{"etiket":"Kişi başına işlenebilir arazi","birim":"İşlenebilir arazi (kişi başına hektar)","yil":2023,"RUS":0.845805974199542,"TUR":0.237641613546357,"oran_RUS_TUR":3.56,"_ileri_not":null,"kaynak":"WB"},{"etiket":"Kara alanı","birim":"Kara alanı (km²)","yil":2023,"RUS":16376870,"TUR":769630,"oran_RUS_TUR":21.28,"_ileri_not":null,"kaynak":"WB"},{"etiket":"Tahıl verimi","birim":"Tahıl verimi (kg/hektar)","yil":2023,"RUS":3166.6,"TUR":3659.1,"oran_RUS_TUR":0.87,"_ileri_not":{"TUR":{"yil":2024,"deger":3428.7}},"kaynak":"WB"},{"etiket":"Gübre tüketimi","birim":"Gübre tüketimi (kg/hektar işlenebilir arazi)","yil":2023,"RUS":28.7290072257067,"TUR":139.557478917,"oran_RUS_TUR":0.21,"_ileri_not":null,"kaynak":"WB"},{"etiket":"Tarımda istihdam payı","birim":"Tarımda istihdam (toplam istihdamın %si)","yil":2025,"RUS":5.10897725869351,"TUR":14.2199829949572,"oran_RUS_TUR":0.36,"_ileri_not":null,"kaynak":"WB"},{"etiket":"Nüfus","birim":"Nüfus","yil":2025,"RUS":143513328,"TUR":85878556,"oran_RUS_TUR":1.67,"_ileri_not":null,"kaynak":"WB"}],"olcu_catismasi":{"_aciklama":"İKİ KAYNAK TERS SONUÇ VERİYOR ve ikisi de doğru — farklı şey ölçüyorlar. Metinde ikisi birlikte verilir, biri seçilip diğeri gizlenmez.","dunya_bankasi_katma_deger":{"etiket":"Tarımsal katma değer (cari USD)","birim":"Tarım, ormancılık, balıkçılık — katma değer (cari USD)","yil":2025,"RUS":78308409212.0681,"TUR":83211181935.7741,"oran_RUS_TUR":0.94,"_ileri_not":null,"kaynak":"WB"},"fao_brut_uretim_degeri":"uretim_degeri.kalemler[0] — sabit 2014-16 I$","neden":"Biri net katma değer ve kur hareketi taşır; diğeri brüt üretim ve sabit fiyat."}},"girdi_kanali":{"_aciklama":"Rusya Türk tarımına üç kanaldan değiyor: gıda, yem ve GİRDİ. Gübre tarım faslı değil (HS31), bu yüzden tarım ticareti toplamlarının dışında kalıyor.","_kaynak":"COMTRADE","_birim":"cari ABD doları","gubre_rusyadan":{"2013":722593468,"2014":730610514,"2015":457419538,"2016":553693212,"2017":221517880,"2018":272354168,"2019":334298410,"2020":156722358,"2021":264540476,"2022":710691376,"2023":689092854,"2024":376451288},"fasil_serileri":{"tahil":{"2013":1800176976,"2014":2967735350,"2015":1885172650,"2016":1377012608,"2017":1763670222,"2018":3023843428,"2019":3316879170,"2020":3423716882,"2021":4951485602,"2022":6122623118,"2023":6716565986,"2024":2909829552},"yag":{"2013":980883426,"2014":1622200318,"2015":1341338498,"2016":1262862748,"2017":811036004,"2018":536760852,"2019":658985536,"2020":1077928338,"2021":2127559404,"2022":2445164710,"2023":1033052676,"2024":1520038938},"yem_kuspe":{"2013":492526584,"2014":568684376,"2015":516420566,"2016":540465358,"2017":588510074,"2018":559881814,"2019":617387298,"2020":704730546,"2021":887466340,"2022":1381150532,"2023":1483731418,"2024":1555200884}},"kalemler":[{"kod":"3102","ad":"Azotlu gübre","son_yil":2024,"son_deger_usd":75920150},{"kod":"3105","ad":"Bileşik gübre","son_yil":2024,"son_deger_usd":248103184}]},"tarih_kultur":{"_kaynak":"TARIH","_aciklama":"Dosyanın veriyle anlatılamayan yarısı. Buradaki her blok bir bölümü besliyor: çernozyom, Vavilov, ayçiçeği, kolhoz, çavdar, dacha, çay, sera.","_giris_yontemi":"Her kalem kaynağından tek tek okundu; kaynak niteliği (BİRİNCİL / HAKEMLİ / KURUMSAL / İKİNCİL) her blokta yazılı.","_dogrulama_tarihi":"2026-08-23","kara_toprak":{"baslik_tr":"Çernozyom — kara toprak","bulgu":"Çernozyomun ne olduğu sorusunun cevabı bir bitkidir: bozkır otu. Toprağın siyahlığı, binlerce yıl boyunca ölüp çürüyen bozkır otlarının biriktirdiği organik maddedir.","ruprecht":{"kisi":"Franz Joseph Ruprecht (1814-1870), Avusturya doğumlu Rus bilim insanı","eser":"'Geo-Botanical Researches into the Chernozem', Sankt-Peterburg, 1866","katki":"Saha çalışması ve mikroskobik örnek incelemesiyle, topraktaki organik maddenin ÇÜRÜMÜŞ BOZKIR OTLARI olduğunu ileri sürdü."},"dokuchaev":{"kisi":"Vasili Dokuçayev (1846-1903)","eser":"'Russkii chernozem' (Rus Çernozyomu), Sankt-Peterburg, 1883","katki":"Toprak biliminin kurucu metni sayılıyor. Dokuçayev bu eserinde Ruprecht'in görüşlerine özel yer ayırmış ve onu 'bu sorunun bilimsel incelemesinin babası' diye anmıştır.","doktora":"Doktora tezi 19 Aralık 1883'te Sankt-Peterburg Üniversitesi'nde savunuldu."},"kaynak":"Anastasia A. Fedotova, 'The Origins of the Russian Chernozem Soil (Black Earth): Franz Joseph Ruprecht's Geo-Botanical Researches into the Chernozem of 1866', Environment and History","_kaynak_niteligi":"HAKEMLİ makale"},"vavilov":{"baslik_tr":"Vavilov ve Anadolu","kisi":{"ad":"Nikolai İvanoviç Vavilov","dogum":"25 Kasım 1887, Moskova","gorev":"1917'de Uygulamalı Botanik Bürosu başkan yardımcılığı","tutuklanma":"1940, batı Ukrayna'da; vatana ihanet ve casusluk suçlamasıyla","olum":"26 Ocak 1943, Saratov hapishanesi — açlıktan"},"eser":{"sefer_sayisi":115,"ulke_sayisi":64,"ilk_sefer":"1916, İran ve Pamir","tohum_ornegi":250000,"tohum_ornegi_notu":"250.000'den fazla; dünyanın o zamanki en büyük bitki genetik kaynağı koleksiyonu","koken_merkezi_sayisi":8,"kitap":"'Kültür Bitkilerinin Kökeni ve Coğrafyası', 1926"},"yakin_dogu_merkezi":{"kapsam":"Küçük Asya (Anadolu), Kafkasya ötesi, İran, Türkmenistan","urunler":"Birçok Triticum (buğday) türü, çavdar, arpa, mercimek; ayrıca yonca, havuç, lahana, yulaf, soğan, marul, incir, nar, elma, armut, üzüm, badem, kestane, antep fıstığı","_kaynak_niteligi":"İKİNCİL — ders kitabı düzeyinde yerleşik bilgi"},"anadolu_seferi":{"yil":"1925 ve 1926","mesafe_km":12000,"toplanan_ornek":5700,"toplanan_ornek_notu":"5.700'den fazla kültür bitkisi örneği, bunların 291'i buğday","ek":"Sefer aynı zamanda dönemin tarım uygulamalarını belgeledi.","kaynak":"Morgounov, A., Keser, M., Kan, M., Küçükçongar, M., Özdemir, F., Gummadov, N., Muminjanov, H., Zuev, E., Qualset, C.O. (2016). 'Wheat landraces currently grown in Turkey: Distribution, diversity, and use.' Crop Science 56(6): 3112-3124.","_kaynak_niteligi":"HAKEMLİ makale"},"bugunku_anlami":{"bulgu":"2009-2014 arasında Türkiye'de yapılan yerel buğday çeşidi taraması 3 tür ve 6 alt türü temsil eden 95 morfotip buldu — bu, 1920'de kayda geçen çeşitliliğin yüzde 50 ila 70 oranında kaybı demek.","en_cesitli_iller":["Manisa","Konya","Diyarbakır","Adana"],"neden_onemli":"Türkiye'nin yerel buğday çeşitliliğinin bir asır önceki hâlini bilmemizi sağlayan kayıt, büyük ölçüde bu Rus seferinin kaydıdır.","kaynak":"aynı makale (Morgounov ve ark., 2016)","_kaynak_niteligi":"HAKEMLİ makale"},"leningrad":{"olay":"900 günlük Leningrad kuşatması sırasında enstitü çalışanları, korudukları tohum koleksiyonunu açlıktan ölürken bile yemeyi reddetti.","_uyari":"Ölen personel sayısı okunabilen kaynaklarda verilmiyor; bu dosyada sayı yazılmayacak.","kaynak":"Crop Trust, 'Nikolai Vavilov: The Father of Genebanks'","_kaynak_niteligi":"KURUMSAL"}},"aycicegi_ve_perhiz":{"baslik_tr":"Perhiz yağı","bulgu":"Rusya'nın dünya ayçiçeği devi olmasının kökeninde bir oruç kuralı var.","anlati":"18. yüzyılda Rus Ortodoks Kilisesi perhiz döneminde tüketilmesi yasak yağları listeledi; listede tereyağı ve domuz yağı vardı. Ayçiçeği o kadar yeni bir bitkiydi ki listeye girmemişti. Böylece perhizde serbest kalan tek yağ oldu ve talep patladı.","yayilma":"19. yüzyılın başlarında Rusya ve Ukrayna'da ayçiçeği ekim alanı 800.000 hektarı aştı; yüzyılın üçüncü on yılında ayçiçeği yağı Rusya'da büyük ölçekli ve kârlı bir sanayi hâline geldi.","kaynak":"NPR, 'How The Russians Saved America's Sunflower' ve Nuseed Europe, 'History of the Sunflower'","_kaynak_niteligi":"İKİNCİL","_not":"Rakamlar ikincil kaynaktan geldiği için metinde yuvarlak ve temkinli verilir; ayçiçeğinin bugünkü hacmi PSD'den gelir."},"kolhozdan_agroholdinge":{"baslik_tr":"Kolhozdan agroholdinge","kollektiflestirme":{"baslangic":"1929 sonu, Birinci Beş Yıllık Plan kapsamında","yapi":"kolhoz (kollektif çiftlik) ve tamamen devlet işletmesi olan sovhoz"},"sovyet_sonu_olcek":{"yil":1990,"sovhoz_sayisi":23500,"sovhoz_ortalama_ha":15300,"kolhoz_ortalama_ha":5900,"kolhoz_sayisi_1988":27000},"ozellestirme":{"kararname":"Aralık 1991 cumhurbaşkanlığı kararnamesi — üyelere arazi ve arazi dışı varlıklardan orantılı pay çekip bağımsız çiftlik kurma hakkı","yeniden_yapilanma_suresi":"Mart 1992'ye kadar üretim kooperatifi, limited ortaklık veya anonim şirkete dönüşme zorunluluğu","pay_ceken_hane":300000,"ozel_ciftlik_zirvesi":{"yil":1994,"sayi":284000,"ortalama_ha":40}},"bugun":{"yil":2024,"en_buyuk_sirket_sayisi":77,"kontrol_edilen_arazi_ha":18500000,"not":"Ağırlıklı olarak agroholdingler. En büyükleri yüz binlerce hektar araziyi ve 20.000'e varan tarım işçisini yönetiyor."},"_kaynak_niteligi":"İKİNCİL — ansiklopedik ve derleme kaynaklar","_uyari":"Bu bloktaki rakamlar birincil kaynaktan teyit edilmedi. Metinde 'yaklaşık' ve kaynak belirtilerek kullanılır; kesin iddia kurulmaz."},"cavdar":{"baslik_tr":"Çavdarın terk edilişi","kultur":{"anlati":"Kara ekmek Rusya'da 9.-10. yüzyıldan beri biliniyor. Dayanıklı çavdar, özellikle kuzeyde Rusya'nın sert ikliminine en uygun tahıldı ve 19. yüzyılda Avrupa Rusyası'nın 50 vilayetinin 40'ında başlıca üründü. Beyaz buğday ekmeği ancak 20. yüzyılın başında yaygınlaştı ve uzun süre varlık göstergesi sayıldı.","dusus":"İkinci Dünya Savaşı öncesinde Rusya'da üretilen ekmeğin yüzde 70'inde çavdar unu vardı; bugün bu oran yüzde 30 dolayında.","_kaynak_niteligi":"İKİNCİL — kültür yayınları","_uyari":"Yüzdeler ikincil kaynaktan. Metinde kaynak belirtilerek ve 'dolayında' diye verilir."},"veri_baglantisi":"Çavdarın terk edilişinin sayısal kanıtı USDA PSD'de: Rusya'nın çavdar üretimi 1992'de 13,89 milyon tondan 2024'te 1,20 milyon tona indi. Bu rakam data.json/diger_tahillar'dan gelir."},"dacha":{"baslik_tr":"Yirmi milyon bahçe","bulgu":"Dünyanın en büyük buğday ihracatçısı, patatesinin beşte dördünü hane bahçelerinde yetiştiriyor. Tek ülkenin içinde iki ayrı tarım var.","uretici_siniflari_2014":{"_kaynak":"Rosstat verisi, USDA FAS GAIN raporu üzerinden","_yil":2014,"tarim_kuruluslari":{"tahil_yuzde":73.8,"aycicegi_yuzde":70.1,"seker_pancari_yuzde":88.9,"patates_yuzde":12.3,"sebze_yuzde":16.7},"ozel_ciftlik_ve_girisimci":{"tahil_yuzde":25.4,"aycicegi_yuzde":29.5,"seker_pancari_yuzde":10.5,"patates_yuzde":7.6,"sebze_yuzde":14},"haneler":{"tahil_yuzde":0.8,"aycicegi_yuzde":0.4,"seker_pancari_yuzde":0.6,"patates_yuzde":80.1,"sebze_yuzde":69.3},"_haneler_notu":"Kaynak tahıl, ayçiçeği ve şeker pancarı için 'yüzde 1'den az' diyor, sayı vermiyor. Buradaki 0,8 / 0,4 / 0,6 değerleri diğer iki sınıfın toplamından ARTIK olarak hesaplandı ve kaynağın ifadesiyle tutarlı. Metinde 'yüzde 1'den az' denir; sayı yalnızca grafikte kullanılır."},"hukuki_dayanak":["7 Temmuz 2003 tarihli 112-FZ sayılı Federal Kanun — 'Hane Çiftlikleri Hakkında'","15 Nisan 1998 tarihli 66-FZ sayılı Federal Kanun — bahçecilik ve sebzecilik amaçlı kâr amacı gütmeyen birlikler"],"kaynak":"USDA FAS GAIN — 'Classification of Agricultural Producers in Russia', Moskova, 6 Kasım 2015","yerel_kopya":"_raw/belgeler/RS2015_uretici_siniflari.pdf","_kaynak_niteligi":"BİRİNCİL BELGE (ABD federal yayını, kamu malı); içindeki oranlar Rosstat kaynaklı"},"cay":{"baslik_tr":"Çayın kuzey sınırı","bulgu":"İki ülke arasında ters yöne akmış bir ürün var: Türk çayı, Sovyetler Birliği'nden alınan Gürcistan kökenli tohumla başladı.","turkiye":{"1888":"İlk çalışmalar. Ticaret Nazırı İsmail Paşa aracılığıyla Çin'den getirtilen tohumlar Bursa dolaylarında ekildi; olumlu sonuç alınamadı.","1917":"Batum ve havalisinde inceleme yapan heyette bulunan Halkalı Yüksek Ziraat Mektebi Müdür Vekili Ali Rıza Erten, İktisat Vekaleti'ne verdiği raporda aynı ekolojik şartların bulunduğu Rize ve civarında çay ve narenciye yetiştirilmesini önerdi. Rapor önce dikkate alınmadı.","1924":"407 Sayılı Kanun ile çay üretimi çalışmalarına başlandı.","1940":"29 Mart 1940 tarihli 3788 Sayılı Çay Kanunu ile çay tarımı ve üreticisi desteklendi. Kararname ile Araklı'dan Rus sınırına kadar 30 bin dönümlük alan çay tarımına ayrıldı ve Ziraat Bankası'ndan üreticilere 5 yıl süreyle faizsiz kredi verilmesi kararlaştırıldı.","istasyon":"Rize'de Bahçe Kültürleri İstasyonu kuruldu; başına Ziraat Umum Müfettişi Zihni Derin getirildi.","tohum_alimlari":[{"yil":1937,"ton":20,"kaynak_ulke":"Sovyetler Birliği","menşe":"Gürcistan kökenli"},{"yil":1939,"ton":30},{"yil":1940,"ton":20}],"kapasite":{"1973_ton_gun":2732,"2020_ton_gun":9020,"_tanim":"işlenen yaş çay yaprağı"},"kaynak":"ÇAYKUR — 'Kuruluşumuzun Tarihçesi, Türk Ekonomisindeki Yeri ve Gelişimi', kurumun kendi yayını","yerel_kopya":"_raw/belgeler/CAYKUR_tarihce.pdf","_kaynak_niteligi":"BİRİNCİL — kurumun kendi beyanı"},"rusya":{"anlati":"Gürcistan, Abhazya ve Türkiye'de çay tarlalarında çalışmış olan Yuda Koşman, 1901'de Soçi yakınlarındaki Soloh-aul köyünde bir arazi alıp çay yetiştirmeye başladı ve soğuğa dayanıklı bir çeşit geliştirdi.","kuzey_sinir":"Krasnodar çayı 2012'ye kadar dünyanın en kuzeydeki çayı olarak anıldı; o yıl Birleşik Krallık ilk yerel hasadını aldı.","_kaynak_niteligi":"İKİNCİL — Rusya Beyond ve turizm yayınları","_uyari":"Tarihler ve isim ikincil kaynaktan; metinde kaynak belirtilerek verilir."}},"sera_programi":{"baslik_tr":"2014 sonrası sera programı","bulgu":"Türk domatesinin neden geri dönmediğinin sebebi burada. Boşluk kendiliğinden dolmadı; devlet destekli bir yatırım programıyla dolduruldu.","destek":"2014 sonrasında yeni sera projelerine, sera inşası ve modernizasyonu için yapılan harcamanın bir bölümünün geri ödenmesi yoluyla maliyetin yüzde 20'sine kadar destek ve imtiyazlı yatırım kredisi sağlandı.","sonuc":{"sera_sebze_uretimi":"2014'e göre yüzde 65 artış","domates_ithalat_payi":[{"yil":2017,"tuketimdeki_pay_yuzde":60},{"yil":2018,"tuketimdeki_pay_yuzde":45}]},"kaynak":"HortiDaily derlemeleri ve USDA FAS GAIN — 'Government Import Substitution Measures in Agriculture', Moskova, 18 Eylül 2015","_kaynak_niteligi":"İKİNCİL (üretim rakamları) + BİRİNCİL BELGE (destek mekanizması)"},"_dogrulanmamis_kalemler":[{"kalem":"Dacha bahçelerinin patatesin yüzde 92'sini, sebzenin yüzde 77'sini ürettiği","neden":"Popüler yayınlarda dolaşıyor; USDA/Rosstat kaydı yüzde 80,1 ve yüzde 69,3 diyor. Doğrulanmış olan kullanılıyor.","gorulen_kaynak":"bahçecilik siteleri"},{"kalem":"Rusya'da 17 milyon ailenin bahçeli evi olduğu (2016)","neden":"Anket ve tanım farkları büyük; birincil kaynağa bağlanamadı.","gorulen_kaynak":"derleme yayınlar"},{"kalem":"Rusya'nın 2026 tahıl hasadı tahmini 137 milyon ton","neden":"Kota haberinde gerekçe olarak geçiyor; birincil kaynağa bağlanamadı.","gorulen_kaynak":"kota haberleri"},{"kalem":"Leningrad kuşatmasında ölen enstitü personelinin sayısı","neden":"Okunabilen kaynaklarda sayı verilmiyor.","gorulen_kaynak":"Crop Trust, Kew"},{"kalem":"Vavilov'un Anadolu seferine bizzat katılıp katılmadığı","neden":"Hakemli kaynak seferi 'Vavilov Enstitüsü'ne atfediyor, Vavilov'un kendisine değil. Metinde 'Vavilov Enstitüsü' denir.","gorulen_kaynak":"Morgounov ve ark., 2016"},{"kalem":"Rus agroholdinglerinin tek tek adları ve payları","neden":"Şirket bazlı doğrulanmış kaynak bulunamadı.","gorulen_kaynak":"—"}],"_dogrulanmamis_kural":"Yukarıdaki liste METNE GİRMEZ. Yalnızca ileride doğrulanmak üzere kayıt altındadır."},"kurumlar":{"_kaynak":"KURUM","_giris_yontemi":"WebFetch ile kaynağın kendi sayfasından ya da indirilen resmî belgeden okundu; her kalemin altında kaynağı ve doğrulama tarihi var.","_dogrulama_tarihi":"2026-08-23","kapali_kaynaklar":{"_not":"Ölçüm, iddia değil. 23 Ağustos 2026'da bu ağdan denendi. Erişimsizliğin ülke engellemesi mi yerel ağ mı olduğu ÇÖZÜLMEDİ — metinde 'erişilemedi' denir, 'yasaklandı' denmez.","denemeler":[{"adres":"rosstat.gov.ru","sonuc":"bağlantı kurulamadı","deneme_sayisi":2},{"adres":"customs.gov.ru","sonuc":"25 saniyede zaman aşımı","deneme_sayisi":1},{"adres":"government.ru / special.government.ru","sonuc":"yanıt alınamadı","deneme_sayisi":2},{"adres":"fenixservices.fao.org (FAOSTAT API)","sonuc":"HTTP 521","deneme_sayisi":1}],"sonuc":"Rusya'ya ait rakamların çoğu ayna istatistiktir: satın alan ülkelerin defterinden okunuyor."},"ihracat_vergisi":{"ad_tr":"Tahıl damperi — değişken ihracat vergisi","ad_ru":"зерновой демпфер","yururluge_giris":"2021-06-02","kapsam":["buğday","mısır","arpa"],"hesap":"Vergi = (gösterge fiyat − referans fiyat) × %70","hesap_sikligi":"haftalık","gosterge_kaynagi":"Moskova Borsası'na kayıtlı ihracat sözleşmelerinin fiyatları","referans_fiyat_seyri":[{"tarih":"2021-06-02","bugday_rub_ton":15000,"arpa_misir_rub_ton":13875},{"tarih":"2023-07","bugday_rub_ton":17000,"arpa_misir_rub_ton":15875},{"tarih":"2024-06-28","bugday_rub_ton":18000,"arpa_misir_rub_ton":16875}],"para_birimi_notu":"Vergi başlangıçta dolarla, Temmuz 2022'den beri rubleyle hesaplanıyor.","gelirin_kullanimi":"Toplanan tutar üreticiye sübvansiyon olarak geri veriliyor.","onemi_tr":"Fiyat eşiği aştığında vergi kendiliğinden yükseliyor, düştüğünde sıfıra inebiliyor. Yani Rus buğdayının dünya fiyatı ile iç fiyatı arasına ayarlanabilir bir vana konmuş durumda.","kaynak":"Rusya Tarım Bakanlığı duyurularının Interfax ve TASS üzerinden aktarımı","_kaynak_niteligi":"İKİNCİL. Birincil kaynak (Tarım Bakanlığı sitesi) bu ağdan okunamadı; bkz. kapali_kaynaklar.","_dogrulama_tarihi":"2026-08-23"},"ihracat_kotasi":{"ad_tr":"Tahıl ihracat tarife kotası","hukuki_dayanak":"Kararname No. 2089","duyuru_tarihi":"2025-12-24","yururluk":{"baslangic":"2026-02-15","bitis":"2026-06-30"},"hacim_ton":20000000,"hacim_notu":"10 Nisan 2026'da 5 milyon ton artırıldı. Bir önceki yıl (2025) kota 10,6 milyon tondu.","kapsam":["buğday","mahlut","çavdar","arpa","mısır"],"kapsam_notu":"Çavdar kapsamda ama kotası sıfır olarak bildirildi — iki kaynak bu noktada farklı okunuyor, ikisi de kayda geçti.","istisna":"Hükümet kararına dayalı uluslararası insani yardım sevkiyatları kotaya tabi değil.","cografi_kapsam":"Avrasya Ekonomik Birliği (AEB) dışına yapılan ihracat","kaynak":"Global Trade Alert — state act 95876","kaynak_url":"https://globaltradealert.org/state-act/95876-russia-temporary-export-tariff-quota-for-certain-grains-15-february-30-june-2026","_kaynak_niteligi":"İKİNCİL ama belge künyeli. Birincil metin (government.ru) okunamadı.","_dogrulama_tarihi":"2026-08-23"},"limanlar":{"_not":"Rus tahılının Türkiye'ye çıkış kapısı Karadeniz. Novorossiysk tek liman değil ama en büyüğü.","novorossiysk_terminalleri":[{"ad":"Novorossiysk Tahıl İşleme Tesisi (NKHP)","yillik_kapasite_mt":7.1,"tek_seferlik_depolama_ton":245000,"gemi_yukleme_ton_saat":2000,"sahiplik":"Demetra-Holding payı %35,36","kaynak":"Demetra-Holding kendi varlık sayfası","kaynak_url":"https://dholding.ru/en/assets/nkhp","_kaynak_niteligi":"BİRİNCİL — işletmecinin kendi beyanı"},{"ad":"Novorossiysk Tahıl Terminali (NZT/NGT)","yillik_kapasite_mt":8.5,"tek_seferlik_depolama_ton":200000,"hizmete_giris":2008,"sahiplik":"Demetra-Holding %100","kaynak":"Demetra-Holding kendi varlık sayfası","kaynak_url":"https://dholding.ru/en/assets/nzt","_kaynak_niteligi":"BİRİNCİL — işletmecinin kendi beyanı"}],"tarihsel_karsilastirma_2013":{"_uyari":"BU RAKAMLAR 2013'TEN. Güncel diye kullanılamaz — Rusya'nın buğday ihracatı o tarihten bu yana kat kat arttı. Yalnızca büyümeyi göstermek için var.","nkhp_mt":4.5,"ngt_mt":3.5,"ksk_mt":3.5,"toplam_mt":11.5,"kaynak":"USDA FAS GAIN — Russian Grain Port Capacity and Transportation Update, 16 Ağustos 2013","yerel_kopya":"_raw/belgeler/RS2013_liman_kapasitesi.pdf","_kaynak_niteligi":"BİRİNCİL BELGE (ABD federal yayını, kamu malı)"},"guncel_olay_2026_08_12":{"_uyari":"YAŞAYAN DURUM. Dosya yayına girdiğinde geçerliliği değişmiş olabilir; yayın öncesi yeniden doğrulanacak.","tarih":"2026-08-12","olay":"Novorossiysk'teki tahıl terminalleri insansız hava aracı saldırısının ardından işlemleri durdurdu.","dogrulanan_terminaller":[{"ad":"Novorossiysk Tahıl Terminali","kapasite_mt":8.5},{"ad":"NKHP","kapasite_mt":7.1}],"dogrulanan_kapasite_mt":15.6,"isletmeci_beyani":"NKHP'nin sahibi OZK ayrıntıları daha sonra paylaşacağını bildirdi; hasar tespiti sürüyor.","yeniden_calisma":"Kaynakta süre verilmiyor.","kaynak":"Reuters aktarımı, Ukrinform, 12 Ağustos 2026","kaynak_url":"https://www.ukrinform.net/rubric-economy/4153550-two-grain-terminals-in-novorossiysk-halt-operations-after-ukrainian-attack-reuters.html","_kaynak_niteligi":"İKİNCİL"}},"turkiye_2024_karari":{"ad_tr":"Dahilde İşleme Rejimi kapsamında buğday ithalatının durdurulması","duyuru_tarihi":"2024-06-06","yururluk":{"baslangic":"2024-06-21","bitis":"2024-10-15"},"bitis_notu":"Kaynak, piyasa koşullarına göre uzatılabileceğini yazıyor.","kapsam":"Dahilde İşleme Rejimi kapsamındaki buğday ithalatı","yani_sira_serbestlesenler":["Yerli buğdaydan üretilen unun ihracatı — Eylül 2018'den beri yasaktı, serbest bırakıldı.","Ekmeklik buğday, makarnalık buğday ve arpa ihracatı, TMO onayına bağlı olarak kontrollü biçimde serbest bırakıldı."],"tmo_mudahale_fiyatlari_2024":{"birim":"TL/ton","makarnalik_bugday":11750,"ekmeklik_bugday":11000,"arpa":8000,"not":"Rakamlar Bakanlık ödeme desteği dahildir: buğdayda 1.750 TL/ton, arpada 750 TL/ton.","anadolu_sert_bugday_mudahale":9250},"gerekce_kaynakta":"Üreticiyi fiyat dalgalanmasından korumak, yurt içi hammadde alımını güvenceye almak.","onemli_ayrinti":"Kaynak, Rusya Tahıl Birliği'nin uygulama tarihinin 30 Haziran'a çekilmesini istediğini, ancak kararın duyurulduğu gibi uygulandığını yazıyor.","onemi_tr":"Kararın hedefi doğrudan ithal-işle-ihraç zinciriydi. Türkiye'nin ihracat makinesinin hammadde musluğu bir yaz boyunca kendi eliyle kısıldı.","kaynak":"USDA FAS GAIN — 'Turkiye Announces Changes to Wheat Trade Policy', rapor no TU2024-0027, 5 Temmuz 2024, Ankara","yerel_kopya":"_raw/belgeler/TU2024-0027_bugday_politikasi.pdf","_kaynak_niteligi":"BİRİNCİL BELGE (ABD federal yayını, kamu malı); içindeki TMO duyurusu doğrudan alıntılanmış.","_dogrulama_tarihi":"2026-08-23"},"_dogrulanmamis_kalemler":[{"kalem":"KSK terminali yıllık kapasitesi 10,85 milyon ton","neden":"İşletmecinin kendi sayfasından teyit edilemedi; yalnızca haber kaynağında geçiyor.","gorulen_kaynak":"S&P Global haber metni"},{"kalem":"Novorossiysk üç terminalin toplam kapasitesi 26,1 milyon ton","neden":"KSK doğrulanmadığı için toplam da doğrulanmadı. Doğrulanan iki terminal 15,6 milyon ton.","gorulen_kaynak":"S&P Global, New Voice of Ukraine"},{"kalem":"12 Ağustos 2026'da ÜÇ terminalin birden durduğu","neden":"Okunabilen kaynak iki terminal adı veriyor; üçüncüsü yalnızca başka haber metinlerinde geçiyor.","gorulen_kaynak":"S&P Global, New Voice of Ukraine"},{"kalem":"Rusya'nın 2026 tahıl hasadı tahmini 137 milyon ton","neden":"Kota haberinde gerekçe olarak geçiyor ama birincil kaynağa bağlanamadı. USDA PSD ile çapraz kontrol edilmeli.","gorulen_kaynak":"kota haberleri"},{"kalem":"Rus tarım ihracatındaki büyük agroholdinglerin adları ve payları","neden":"Henüz araştırılmadı.","gorulen_kaynak":"—"}],"_dogrulanmamis_kural":"Yukarıdaki liste METNE GİRMEZ. Yalnızca ileride doğrulanmak üzere kayıt altındadır."},"bosluklar":[]}$dsr$::jsonb,
  $dsr${"ticaret_cizgi":{"tur":"cizgi","baslik":{"tr":"Açık on iki yıldır aynı yönde","en":"Twelve years, the same direction"},"birim":{"tr":"milyon $ (cari)","en":"million $ (current)"},"bolen":1000000,"ondalik":0,"seriler":[{"ad":{"tr":"Rusya → Türkiye","en":"Russia → Türkiye"},"rol":"vurgu","noktalar":{"liste":[{"yil":2013,"turkiyeden_rusyaya_usd":2369355430,"rusyadan_turkiyeye_usd":3726574110,"denge_usd":-1357218680,"gubre_rusyadan_usd":722593468},{"yil":2014,"turkiyeden_rusyaya_usd":2553370276,"rusyadan_turkiyeye_usd":5836116428,"denge_usd":-3282746152,"gubre_rusyadan_usd":730610514},{"yil":2015,"turkiyeden_rusyaya_usd":2223905784,"rusyadan_turkiyeye_usd":4270848840,"denge_usd":-2046943056,"gubre_rusyadan_usd":457419538},{"yil":2016,"turkiyeden_rusyaya_usd":1006381116,"rusyadan_turkiyeye_usd":3880827660,"denge_usd":-2874446544,"gubre_rusyadan_usd":553693212},{"yil":2017,"turkiyeden_rusyaya_usd":1659418698,"rusyadan_turkiyeye_usd":4024858812,"denge_usd":-2365440114,"gubre_rusyadan_usd":221517880},{"yil":2018,"turkiyeden_rusyaya_usd":1802754114,"rusyadan_turkiyeye_usd":4449313174,"denge_usd":-2646559060,"gubre_rusyadan_usd":272354168},{"yil":2019,"turkiyeden_rusyaya_usd":2128241010,"rusyadan_turkiyeye_usd":5226745440,"denge_usd":-3098504430,"gubre_rusyadan_usd":334298410},{"yil":2020,"turkiyeden_rusyaya_usd":2753522082,"rusyadan_turkiyeye_usd":6331385218,"denge_usd":-3577863136,"gubre_rusyadan_usd":156722358},{"yil":2021,"turkiyeden_rusyaya_usd":3298759140,"rusyadan_turkiyeye_usd":8651840244,"denge_usd":-5353081104,"gubre_rusyadan_usd":264540476},{"yil":2022,"turkiyeden_rusyaya_usd":4259664358,"rusyadan_turkiyeye_usd":10991702876,"denge_usd":-6732038518,"gubre_rusyadan_usd":710691376},{"yil":2023,"turkiyeden_rusyaya_usd":3824839336,"rusyadan_turkiyeye_usd":10462334182,"denge_usd":-6637494846,"gubre_rusyadan_usd":689092854},{"yil":2024,"turkiyeden_rusyaya_usd":3753743756,"rusyadan_turkiyeye_usd":6825091192,"denge_usd":-3071347436,"gubre_rusyadan_usd":376451288}],"x":"yil","y":"rusyadan_turkiyeye_usd"}},{"ad":{"tr":"Türkiye → Rusya","en":"Türkiye → Russia"},"rol":"ikincil","noktalar":{"liste":[{"yil":2013,"turkiyeden_rusyaya_usd":2369355430,"rusyadan_turkiyeye_usd":3726574110,"denge_usd":-1357218680,"gubre_rusyadan_usd":722593468},{"yil":2014,"turkiyeden_rusyaya_usd":2553370276,"rusyadan_turkiyeye_usd":5836116428,"denge_usd":-3282746152,"gubre_rusyadan_usd":730610514},{"yil":2015,"turkiyeden_rusyaya_usd":2223905784,"rusyadan_turkiyeye_usd":4270848840,"denge_usd":-2046943056,"gubre_rusyadan_usd":457419538},{"yil":2016,"turkiyeden_rusyaya_usd":1006381116,"rusyadan_turkiyeye_usd":3880827660,"denge_usd":-2874446544,"gubre_rusyadan_usd":553693212},{"yil":2017,"turkiyeden_rusyaya_usd":1659418698,"rusyadan_turkiyeye_usd":4024858812,"denge_usd":-2365440114,"gubre_rusyadan_usd":221517880},{"yil":2018,"turkiyeden_rusyaya_usd":1802754114,"rusyadan_turkiyeye_usd":4449313174,"denge_usd":-2646559060,"gubre_rusyadan_usd":272354168},{"yil":2019,"turkiyeden_rusyaya_usd":2128241010,"rusyadan_turkiyeye_usd":5226745440,"denge_usd":-3098504430,"gubre_rusyadan_usd":334298410},{"yil":2020,"turkiyeden_rusyaya_usd":2753522082,"rusyadan_turkiyeye_usd":6331385218,"denge_usd":-3577863136,"gubre_rusyadan_usd":156722358},{"yil":2021,"turkiyeden_rusyaya_usd":3298759140,"rusyadan_turkiyeye_usd":8651840244,"denge_usd":-5353081104,"gubre_rusyadan_usd":264540476},{"yil":2022,"turkiyeden_rusyaya_usd":4259664358,"rusyadan_turkiyeye_usd":10991702876,"denge_usd":-6732038518,"gubre_rusyadan_usd":710691376},{"yil":2023,"turkiyeden_rusyaya_usd":3824839336,"rusyadan_turkiyeye_usd":10462334182,"denge_usd":-6637494846,"gubre_rusyadan_usd":689092854},{"yil":2024,"turkiyeden_rusyaya_usd":3753743756,"rusyadan_turkiyeye_usd":6825091192,"denge_usd":-3071347436,"gubre_rusyadan_usd":376451288}],"x":"yil","y":"turkiyeden_rusyaya_usd"}}],"not":{"tr":"Türkiye'nin gümrük kaydı, HS 01-24.","en":"Türkiye's customs record, HS 01-24."}},"tez_yigin":{"tur":"yigin","baslik":{"tr":"Depolanan ve bozulan","en":"What keeps and what spoils"},"cubuklar":[{"etiket":{"tr":"Rusya'dan aldığımız","en":"What we buy from Russia"},"dilimler":[{"ad":{"tr":"Depolanabilir — tahıl, yağlı tohum, küspe","en":"Storable — grain, oilseed, meal"},"deger":4520433426,"rol":"vurgu"},{"ad":{"tr":"Diğer","en":"Other"},"deger":2304657766,"rol":"sessiz"}]},{"etiket":{"tr":"Rusya'ya sattığımız","en":"What we sell to Russia"},"dilimler":[{"ad":{"tr":"Bozulur — meyve, balık, sebze","en":"Perishable — fruit, fish, vegetables"},"deger":2799678998,"rol":"ikincil"},{"ad":{"tr":"Diğer","en":"Other"},"deger":954064758,"rol":"sessiz"}]}],"not":{"tr":"2024. Her çubuk kendi içinde yüzde yüze normalize edilir.","en":"2024. Each bar is normalised to 100%."}},"toprak_ikili":{"tur":"ikili_cubuk","baslik":{"tr":"Geniş toprak, düşük yoğunluk","en":"Wide land, low intensity"},"seriler":[{"ad":{"tr":"Rusya","en":"Russia"},"rol":"vurgu"},{"ad":{"tr":"Türkiye","en":"Türkiye"},"rol":"ikincil"}],"satirlar":[{"etiket":{"tr":"Tarım arazisi","en":"Agricultural land"},"birim":{"tr":"km²","en":"km²"},"yil":2023,"ondalik":0,"degerler":[2157010,385880]},{"etiket":{"tr":"Kişi başına işlenebilir arazi","en":"Arable land per person"},"birim":{"tr":"hektar","en":"hectares"},"yil":2023,"ondalik":2,"degerler":[0.845805974199542,0.237641613546357]},{"etiket":{"tr":"Tahıl verimi","en":"Cereal yield"},"birim":{"tr":"kg/hektar","en":"kg/hectare"},"yil":2023,"ondalik":0,"degerler":[3166.6,3659.1],"rozet":{"tr":"Türkiye önde","en":"Türkiye ahead"}},{"etiket":{"tr":"Gübre kullanımı","en":"Fertiliser use"},"birim":{"tr":"kg/hektar","en":"kg/hectare"},"yil":2023,"ondalik":1,"degerler":[28.7290072257067,139.557478917]}],"not":{"tr":"Her satır kendi içinde karşılaştırılır; satırlar birbiriyle oranlanmaz.","en":"Each row compares within itself; rows are not divided by one another."}},"uretim_degeri_ikili":{"tur":"ikili_cubuk","baslik":{"tr":"Fark tahılda toplanıyor","en":"The gap concentrates in cereals"},"seriler":[{"ad":{"tr":"Rusya","en":"Russia"},"rol":"vurgu"},{"ad":{"tr":"Türkiye","en":"Türkiye"},"rol":"ikincil"}],"satirlar":[{"etiket":{"tr":"Tüm tarım","en":"All agriculture"},"birim":{"tr":"bin sabit 2014-16 I$","en":"thousand constant 2014-16 I$"},"yil":2023,"ondalik":0,"degerler":[111025504,79879045]},{"etiket":{"tr":"Bitkisel üretim","en":"Crops"},"birim":{"tr":"bin sabit 2014-16 I$","en":"thousand constant 2014-16 I$"},"yil":2023,"ondalik":0,"degerler":[64519583,54519696]},{"etiket":{"tr":"Hayvancılık","en":"Livestock"},"birim":{"tr":"bin sabit 2014-16 I$","en":"thousand constant 2014-16 I$"},"yil":2023,"ondalik":0,"degerler":[46505921,25359349]},{"etiket":{"tr":"Tahıl","en":"Cereals"},"birim":{"tr":"bin sabit 2014-16 I$","en":"thousand constant 2014-16 I$"},"yil":2023,"ondalik":0,"degerler":[30981859,9387290],"rozet":{"tr":"3,3 kat","en":"3.3×"}}]},"bugday_donus_cizgi":{"tur":"cizgi","baslik":{"tr":"Alan ülkeden satan ülkeye","en":"From buyer to seller"},"birim":{"tr":"bin ton","en":"thousand tonnes"},"ondalik":0,"seriler":[{"ad":{"tr":"Rusya — buğday ihracatı","en":"Russia — wheat exports"},"rol":"vurgu","noktalar":{"harita":{"1987":800,"1988":970,"1989":1150,"1990":1200,"1991":555,"1992":900,"1993":500,"1994":619,"1995":206,"1996":697,"1997":1111,"1998":1652,"1999":518,"2000":696,"2001":4372,"2002":12621,"2003":3114,"2004":7951,"2005":10664,"2006":10790,"2007":12220,"2008":18393,"2009":18556,"2010":3983,"2011":21627,"2012":11308,"2013":18609,"2014":22800,"2015":25546,"2016":27815,"2017":41447,"2018":35863,"2019":34485,"2020":39100,"2021":34000,"2022":49000,"2023":55500,"2024":43000,"2025":48000,"2026":46000}}},{"ad":{"tr":"Rusya — buğday ithalatı","en":"Russia — wheat imports"},"rol":"ikincil","noktalar":{"harita":{"1987":14900,"1988":9860,"1989":9100,"1990":10849,"1991":13645,"1992":14470,"1993":5000,"1994":2167,"1995":5316,"1996":2631,"1997":3120,"1998":2490,"1999":5083,"2000":1604,"2001":629,"2002":1045,"2003":1026,"2004":1225,"2005":1321,"2006":928,"2007":440,"2008":203,"2009":164,"2010":89,"2011":550,"2012":1172,"2013":862,"2014":330,"2015":819,"2016":505,"2017":467,"2018":446,"2019":325,"2020":400,"2021":300,"2022":300,"2023":300,"2024":300,"2025":300,"2026":300}}}],"not":{"tr":"İki eğri 2001'de kesişiyor. Pazarlama yılı Temmuz-Haziran. Son iki yıl tahmindir.","en":"The curves cross in 2001. Marketing year July-June. The last two years are forecasts."}},"alan_verim_ikili":{"tur":"ikili_cubuk","baslik":{"tr":"Aynı verim artışı, zıt alan kararı","en":"Same yield gain, opposite land decision"},"seriler":[{"ad":{"tr":"1992","en":"1992"},"rol":"sessiz"},{"ad":{"tr":"2024","en":"2024"},"rol":"vurgu"}],"satirlar":[{"etiket":{"tr":"Rusya — buğday alanı","en":"Russia — wheat area"},"birim":{"tr":"bin hektar","en":"thousand hectares"},"ondalik":0,"degerler":[23550,27800]},{"etiket":{"tr":"Türkiye — buğday alanı","en":"Türkiye — wheat area"},"birim":{"tr":"bin hektar","en":"thousand hectares"},"ondalik":0,"degerler":[8800,7250]},{"etiket":{"tr":"Rusya — buğday verimi","en":"Russia — wheat yield"},"birim":{"tr":"ton/hektar","en":"t/hectare"},"ondalik":2,"degerler":[1.96,2.94]},{"etiket":{"tr":"Türkiye — buğday verimi","en":"Türkiye — wheat yield"},"birim":{"tr":"ton/hektar","en":"t/hectare"},"ondalik":2,"degerler":[1.76,2.62]}],"not":{"tr":"Verimde iki ülke de yaklaşık yüzde elli ilerledi. Ayrıldıkları yer alan.","en":"Both countries gained about 50% in yield. They parted ways on area."}},"uretim_degeri_cizgi":{"tur":"cizgi","baslik":{"tr":"Biri çöküp döndü, diğeri hiç durmadı","en":"One collapsed and returned, the other never stopped"},"birim":{"tr":"milyar sabit 2014-16 I$","en":"billion constant 2014-16 I$"},"bolen":1000000,"ondalik":1,"seriler":[{"ad":{"tr":"Rusya","en":"Russia"},"rol":"vurgu","noktalar":{"liste":[{"yil":1992,"RUS":92289307,"TUR":40030680},{"yil":2000,"RUS":61489643,"TUR":46312842},{"yil":2010,"RUS":65786430,"TUR":55529187},{"yil":2020,"RUS":99723089,"TUR":75351516},{"yil":2023,"RUS":111025504,"TUR":79879045}],"x":"yil","y":"RUS"}},{"ad":{"tr":"Türkiye","en":"Türkiye"},"rol":"ikincil","noktalar":{"liste":[{"yil":1992,"RUS":92289307,"TUR":40030680},{"yil":2000,"RUS":61489643,"TUR":46312842},{"yil":2010,"RUS":65786430,"TUR":55529187},{"yil":2020,"RUS":99723089,"TUR":75351516},{"yil":2023,"RUS":111025504,"TUR":79879045}],"x":"yil","y":"TUR"}}]},"cavdar_cizgi":{"tur":"cizgi","baslik":{"tr":"Bin yıllık ekmeğin tarladan çekilişi","en":"A thousand-year bread leaves the field"},"birim":{"tr":"bin ton","en":"thousand tonnes"},"ondalik":0,"seriler":[{"ad":{"tr":"Rusya — çavdar üretimi","en":"Russia — rye production"},"rol":"vurgu","noktalar":{"harita":{"1987":11079,"1988":12530,"1989":12593,"1990":16431,"1991":10624,"1992":13887,"1993":9151,"1994":6000,"1995":4100,"1996":5928,"1997":7476,"1998":3266,"1999":4781,"2000":5444,"2001":6632,"2002":7122,"2003":4147,"2004":2864,"2005":3622,"2006":2959,"2007":3909,"2008":4505,"2009":4333,"2010":1642,"2011":2967,"2012":2132,"2013":3360,"2014":3279,"2015":2084,"2016":2538,"2017":2540,"2018":1914,"2019":1424,"2020":2376,"2021":1716,"2022":2000,"2023":1700,"2024":1200,"2025":1000,"2026":900}}}]},"kim_uretiyor_yigin":{"tur":"yigin","baslik":{"tr":"Tek ülkede iki ayrı tarım","en":"Two agricultures in one country"},"cubuklar":[{"etiket":{"tr":"Tahıl","en":"Cereals"},"dilimler":[{"ad":{"tr":"Tarım kuruluşları","en":"Agricultural enterprises"},"deger":73.8,"rol":"vurgu"},{"ad":{"tr":"Özel çiftlik","en":"Private farms"},"deger":25.4,"rol":"sessiz"},{"ad":{"tr":"Haneler","en":"Households"},"deger":0.8,"rol":"ikincil"}]},{"etiket":{"tr":"Ayçiçeği","en":"Sunflower"},"dilimler":[{"ad":{"tr":"Tarım kuruluşları","en":"Agricultural enterprises"},"deger":70.1,"rol":"vurgu"},{"ad":{"tr":"Özel çiftlik","en":"Private farms"},"deger":29.5,"rol":"sessiz"},{"ad":{"tr":"Haneler","en":"Households"},"deger":0.4,"rol":"ikincil"}]},{"etiket":{"tr":"Patates","en":"Potatoes"},"dilimler":[{"ad":{"tr":"Tarım kuruluşları","en":"Agricultural enterprises"},"deger":12.3,"rol":"vurgu"},{"ad":{"tr":"Özel çiftlik","en":"Private farms"},"deger":7.6,"rol":"sessiz"},{"ad":{"tr":"Haneler","en":"Households"},"deger":80.1,"rol":"ikincil"}]},{"etiket":{"tr":"Sebze","en":"Vegetables"},"dilimler":[{"ad":{"tr":"Tarım kuruluşları","en":"Agricultural enterprises"},"deger":16.7,"rol":"vurgu"},{"ad":{"tr":"Özel çiftlik","en":"Private farms"},"deger":14,"rol":"sessiz"},{"ad":{"tr":"Haneler","en":"Households"},"deger":69.3,"rol":"ikincil"}]}],"not":{"tr":"2014, Rosstat. Tahıl, ayçiçeği ve şeker pancarında hanelerin payı kaynakta 'yüzde 1'den az' diye geçiyor; buradaki değerler artık paydır.","en":"2014, Rosstat. For cereals, sunflower and sugar beet the source states the household share as 'less than 1 percent'; the values here are residuals."}},"turkiye_bugday_cizgi":{"tur":"cizgi","baslik":{"tr":"İşleme kapasitesi hasadın önüne geçti","en":"Processing outgrew the harvest"},"birim":{"tr":"bin ton","en":"thousand tonnes"},"ondalik":0,"seriler":[{"ad":{"tr":"Türkiye — buğday ithalatı","en":"Türkiye — wheat imports"},"rol":"vurgu","noktalar":{"harita":{"1960":373,"1961":1287,"1962":583,"1963":371,"1964":276,"1965":163,"1966":308,"1967":28,"1968":504,"1969":939,"1970":898,"1971":559,"1972":26,"1973":519,"1974":1059,"1975":20,"1976":0,"1977":6,"1978":0,"1979":0,"1980":0,"1981":748,"1982":49,"1983":350,"1984":1048,"1985":980,"1986":500,"1987":160,"1988":277,"1989":3698,"1990":291,"1991":172,"1992":997,"1993":650,"1994":500,"1995":2100,"1996":2630,"1997":1775,"1998":1862,"1999":1470,"2000":424,"2001":1037,"2002":1243,"2003":1089,"2004":390,"2005":125,"2006":1736,"2007":2160,"2008":3469,"2009":3192,"2010":3705,"2011":4066,"2012":1142,"2013":4070,"2014":5841,"2015":4087,"2016":4732,"2017":6222,"2018":6395,"2019":10851,"2020":8081,"2021":9421,"2022":12072,"2023":9350,"2024":3318,"2025":6321,"2026":5000}}},{"ad":{"tr":"Türkiye — buğday ihracatı","en":"Türkiye — wheat exports"},"rol":"ikincil","noktalar":{"harita":{"1960":1,"1961":1,"1962":0,"1963":0,"1964":0,"1965":0,"1966":0,"1967":0,"1968":2,"1969":0,"1970":0,"1971":17,"1972":560,"1973":19,"1974":0,"1975":0,"1976":52,"1977":1149,"1978":2023,"1979":440,"1980":530,"1981":337,"1982":573,"1983":600,"1984":517,"1985":112,"1986":52,"1987":933,"1988":1643,"1989":194,"1990":546,"1991":6241,"1992":2019,"1993":1065,"1994":1810,"1995":1054,"1996":967,"1997":1324,"1998":2626,"1999":2163,"2000":1601,"2001":753,"2002":794,"2003":839,"2004":2017,"2005":3214,"2006":2377,"2007":1722,"2008":2239,"2009":4266,"2010":3014,"2011":3670,"2012":1519,"2013":4449,"2014":4090,"2015":5878,"2016":6699,"2017":6698,"2018":6814,"2019":6534,"2020":6469,"2021":6714,"2022":6875,"2023":9950,"2024":7282,"2025":6468,"2026":6000}}}],"not":{"tr":"1980'de ithalat sıfırdı. Son iki yıl tahmindir.","en":"Imports were zero in 1980. The last two years are forecasts."}},"musteriler_siralama":{"tur":"siralama","baslik":{"tr":"Rusya'nın tarım müşterileri","en":"Russia's agricultural customers"},"birim":{"tr":"bin $ (cari)","en":"thousand $ (current)"},"ondalik":0,"satirlar":[{"etiket":{"tr":"Türkiye","en":"Türkiye"},"deger":4329243,"rol":"vurgu"},{"etiket":{"tr":"Kazakistan","en":"Kazakhstan"},"deger":2690417},{"etiket":{"tr":"Çin","en":"China"},"deger":2236011},{"etiket":{"tr":"Mısır","en":"Egypt"},"deger":1834569},{"etiket":{"tr":"Belarus","en":"Belarus"},"deger":1707345}],"not":{"tr":"2021 — Rusya'nın FAOSTAT'a raporladığı son yıl.","en":"2021 — the last year Russia reported to FAOSTAT."}},"ambargo_ikili":{"tur":"ikili_cubuk","baslik":{"tr":"Dokuz yıl sonra geri dönenler ve dönmeyenler","en":"Nine years on: what came back and what didn't"},"seriler":[{"ad":{"tr":"2015 — kriz öncesi","en":"2015 — before"},"rol":"sessiz"},{"ad":{"tr":"2024","en":"2024"},"rol":"vurgu"}],"satirlar":[{"etiket":{"tr":"Domates","en":"Tomatoes"},"birim":{"tr":"$","en":"$"},"ondalik":0,"degerler":[517630196,87374328],"rozet":{"tr":"%16,9","en":"16.9%"}},{"etiket":{"tr":"Üzüm","en":"Grapes"},"birim":{"tr":"$","en":"$"},"ondalik":0,"degerler":[202002782,130379300],"rozet":{"tr":"%64,5","en":"64.5%"}},{"etiket":{"tr":"Turunçgil","en":"Citrus"},"birim":{"tr":"$","en":"$"},"ondalik":0,"degerler":[586913296,745991104],"rozet":{"tr":"%127,1","en":"127.1%"}}],"not":{"tr":"Türkiye'nin Rusya'ya ihracatı. Rozet, 2024'ün 2015'e oranıdır.","en":"Türkiye's exports to Russia. The badge is 2024 as a share of 2015."}},"isleme_ikili":{"tur":"ikili_cubuk","baslik":{"tr":"İthalatın üretimi geçtiği yer","en":"Where imports overtook production"},"seriler":[{"ad":{"tr":"Üretim","en":"Production"},"rol":"ikincil"},{"ad":{"tr":"İthalat","en":"Imports"},"rol":"vurgu"}],"satirlar":[{"etiket":{"tr":"Buğday","en":"Wheat"},"birim":{"tr":"bin ton","en":"thousand tonnes"},"yil":2024,"ondalik":0,"degerler":[19000,3318]},{"etiket":{"tr":"Ayçiçeği yağı","en":"Sunflower oil"},"birim":{"tr":"bin ton","en":"thousand tonnes"},"yil":2024,"ondalik":0,"degerler":[795,1236],"rozet":{"tr":"ithalat önde","en":"imports ahead"}},{"etiket":{"tr":"Ayçiçeği tohumu","en":"Sunflower seed"},"birim":{"tr":"bin ton","en":"thousand tonnes"},"yil":2024,"ondalik":0,"degerler":[1350,789]}]}}$dsr$::jsonb,
  array['Rusya', 'Rus buğdayı', 'Moskova', 'Novorossiysk', 'Karadeniz tahıl', 'Rosstat']::text[],
  'https://tarim-app-2026.web.app/dosya/rusya/rusya_kulunda_bozkiri.jpg',
  $dsr$NASA Goddard Space Flight Center / MODIS Land Rapid Response Team$dsr$,
  null,
  'published',
  now(),
  (now() + interval '28 days'),
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
  status       = excluded.status,
  -- Pencere KASITLI olarak korunuyor. Yayındaki bir dosyanın metninde yazım
  -- hatası düzeltmek için seed'i yeniden çalıştırmak, 28 günlük sayacı
  -- sıfırlamamalı. Pencereyi bilerek kaydırmak istiyorsanız elle update.
  starts_at    = coalesce(country_dossiers.starts_at,    excluded.starts_at),
  ends_at      = coalesce(country_dossiers.ends_at,      excluded.ends_at),
  published_at = coalesce(country_dossiers.published_at, excluded.published_at),
  updated_at   = now();

delete from public.dossier_sections
 where dossier_id = (select id from public.country_dossiers where slug = 'rusya');

insert into public.dossier_sections
  (dossier_id, ord, title_tr, title_en, body_tr, body_en, chart_keys, tur, gorsel)
select d.id, v.ord, v.title_tr, v.title_en, v.body_tr, v.body_en, v.chart_keys, v.tur, v.gorsel
from public.country_dossiers d
cross join (values
  (1::integer, $dsr$Pazar dediğimiz ülke$dsr$, $dsr$The country we call a market$dsr$, $dsr$2024'te Türkiye Rusya'ya 3,75 milyar dolarlık tarım ürünü sattı. Aynı yıl Rusya'dan
6,83 milyar dolarlık tarım ürünü aldı. Aradaki fark 3,07 milyar dolar ve yön
Türkiye'nin aleyhine.

Bu, o yılın istisnası değil. 2013'ten 2024'e kadar on iki yılın **on ikisinde** de
Türkiye bu ticarette alıcı taraftaydı. Açık 2022'de 6,73 milyar dolara kadar çıktı.

İki yıl eğrinin üstünde iz bırakıyor. 2016, Türkiye'nin ihracatının yarıya indiği
yıl. 2024, ithalatın üçte bir azaldığı yıl. Biri dışarıdan gelen bir karar, diğeri
içeriden verilen bir karar; ikisi de ilerideki bölümlerin konusu.

Rusya bizim müşterimiz. Ama önce tedarikçimiz.

Hacimden daha çok şey söyleyen, iki yönün neyden oluştuğu.

Rusya'dan aldığımızın yarısından fazlası tek bir fasılda toplanıyor: tahıl, 2,91
milyar dolar. Arkasından yem ve küspe geliyor, 1,56 milyar; sonra bitkisel yağ, 1,52
milyar. Üçü de dökme mal. Üçü de gemiyle gelir, siloya girer, bir hasat yılı boyunca
bekler.

Rusya'ya sattığımızın başında meyve ve sert kabuklu var, 1,72 milyar dolar. Sonra
balık, 867 milyon. Sonra işlenmiş sebze-meyve ve taze sebze. Bunlar soğuk zincirde
yürür, ömürleri haftalarla ölçülür.

Rakama dökülünce fark keskinleşiyor: Rusya'dan aldığımızın **yüzde 66,2'si**
depolanabilir, Rusya'ya sattığımızın **yüzde 74,6'sı** bozulur.

Üçte ikisi siloya giren bir ticaretle, dörtte üçü buzdolabına giren bir ticaret aynı
masada pazarlık ediyor.

Bu dosyanın tamamı bu iki yüzde arasındaki farkın açıklamasıdır. İki ülke de
birbirine muhtaç, ama muhtaçlığın **saati** farklı işliyor. Rusya Türk domatesinin
yerini bir mevsimde doldurabilir. Türkiye Rus buğdayının yerini bir hasat yılından
önce dolduramaz.

Bir uyarı gerekiyor: bu rakamların hepsi Türkiye'nin gümrük kaydıdır. Rusya'nın kendi
ayrıntılı ticaret istatistiği 2022'den beri yayımlanmıyor. Bu dosyada Rusya'ya
bakarken çoğunlukla Rusya'nın defterine değil, ondan alışveriş yapanların defterine
bakıyoruz.$dsr$, $dsr$In 2024 Türkiye sold Russia $3.75 billion of agricultural goods. In the same year it
bought $6.83 billion from Russia. The gap is $3.07 billion, and it runs against
Türkiye.

That year is no exception. In **all twelve** years from 2013 to 2024 Türkiye was the
buying side of this trade. The deficit reached $6.73 billion in 2022.

Two years leave a mark on the curve. 2016, when Türkiye's exports halved. 2024, when
imports fell by a third. One is a decision taken abroad, the other a decision taken
at home; both are the subject of later sections.

Russia is our customer. But it is our supplier first.

What the two directions consist of says more than their volume.

More than half of what we buy from Russia sits in a single chapter: cereals, $2.91
billion. Then animal feed and oilcake, $1.56 billion; then vegetable oil, $1.52
billion. All three are bulk goods. All three arrive by ship, go into a silo, and wait
out a harvest year.

At the head of what we sell Russia is fruit and nuts, $1.72 billion. Then fish, $867
million. Then processed fruit and vegetables, and fresh vegetables. These move in a
cold chain and their lives are measured in weeks.

In figures the difference sharpens: **66.2 per cent** of what we buy from Russia is
storable; **74.6 per cent** of what we sell Russia perishes.

A trade two-thirds of which goes into a silo bargains at the same table as a trade
three-quarters of which goes into a refrigerator.

This entire dossier is an explanation of the gap between those two percentages. Both
countries need each other, but the **clock** of that need runs at different speeds.
Russia can fill the place of the Turkish tomato in one season. Türkiye cannot fill
the place of Russian wheat before a harvest year is out.

One caution: every one of these figures is Türkiye's customs record. Russia has not
published its own detailed trade statistics since 2022. When this dossier looks at
Russia it is mostly looking not at Russia's ledger but at the ledgers of those who
trade with it.$dsr$, array['ticaret_cizgi', 'tez_yigin']::text[], 'anlati', null::jsonb),
  (2, $dsr$Kara toprak$dsr$, $dsr$The black earth$dsr$, $dsr$Rusya'nın tarımsal gücünün tek kelimelik açıklaması vardır ve o kelime bir renktir:
çernozyom, yani kara toprak.

Ne olduğu sorusunun cevabı ise bir bitkidir. Bozkır otu.

1866'da Sankt-Peterburg'da yayımlanan bir makalede, Avusturya doğumlu Rus bilim
insanı **Franz Joseph Ruprecht** (1814-1870), saha çalışmasına ve çernozyom
örneklerinin mikroskop altındaki incelemesine dayanarak şunu ileri sürdü: bu
toprağın içindeki organik madde, çürümüş bozkır otlarıdır. Toprağın siyahlığı bir
maden değil, binlerce yıl boyunca ölüp toprağa karışmış otların birikimidir.

On yedi yıl sonra, 1883'te, **Vasili Dokuçayev** (1846-1903) *Rus Çernozyomu*'nu
yayımladı ve aynı yılın 19 Aralık'ında Sankt-Peterburg Üniversitesi'nde tezini
savundu. Bu kitap bugün toprak biliminin kurucu metni sayılıyor. Dokuçayev eserinde
Ruprecht'e özel bir yer ayırdı ve onu "bu sorunun bilimsel incelemesinin babası"
diye andı.

Toprak biliminin ayrı bir bilim dalı olarak doğduğu yer Rusya'dır ve doğmasının
sebebi bu topraktır. Bir ülkenin altındaki şey, o ülkenin bilimini belirlemiş.

Buradan çıkan sonuç, dosyanın ilerisinde birkaç kez karşımıza çıkacak: çernozyom
insan yapımı değil. Sulama sistemi kurulabilir, sera kurulabilir, gübre alınabilir —
ama bozkır otunun binlerce yılda yaptığı şey satın alınamaz. Rusya'nın tarımdaki
avantajı bir politika tercihi değil, bir miras.

Bu mirasın da bir sınırı var, ve o sınır bir sonraki bölümün konusu: geniş toprak
otomatik olarak yüksek verim demek değil.$dsr$, $dsr$There is a one-word explanation for Russia's agricultural strength, and the word is a
colour: chernozem, the black earth.

The answer to what it actually is, however, is a plant. Steppe grass.

In an article published in St Petersburg in 1866, the Austrian-born Russian scientist
**Franz Joseph Ruprecht** (1814-1870) argued, on the basis of field work and
microscopic examination of chernozem samples, that the organic matter in this soil is
decayed steppe grasses. The blackness of the soil is not a mineral but the
accumulation of grasses that died and mixed into the ground over thousands of years.

Seventeen years later, in 1883, **Vasily Dokuchaev** (1846-1903) published *Russian
Chernozem* and defended his thesis at St Petersburg University on 19 December of that
year. The book is today regarded as the founding text of soil science. Dokuchaev gave
Ruprecht a special place in it, calling him "the father of scientific investigation
into the question".

Soil science was born as a separate discipline in Russia, and it was born because of
this soil. What lies beneath a country shaped that country's science.

The conclusion returns several times in this dossier: chernozem is not man-made. An
irrigation system can be built, a greenhouse can be built, fertiliser can be bought —
but what steppe grass did over thousands of years cannot be purchased. Russia's
agricultural advantage is not a policy choice but an inheritance.

That inheritance has a limit too, and the limit is the subject of the next section:
wide land does not automatically mean high yield.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarim-app-2026.web.app/dosya/rusya/rusya_cernozyom_monolit.jpg","atif":"Rockwurm, ISRIC World Soil Information — CC BY-SA 3.0","kaynak":"https://commons.wikimedia.org/wiki/File:Chernozem.JPG","alt_tr":"Çernozyom toprak profili: üstte kalın ve neredeyse siyah bir humus katmanı, aşağı indikçe açılan renk. Siyahlık bozkır otunun binlerce yıllık birikimi.","alt_en":"A chernozem soil profile: a thick, almost black humus horizon on top, lightening with depth. The blackness is millennia of accumulated steppe grass."}$dsr$::jsonb),
  (3, $dsr$Beş buçuk kat toprak, daha düşük verim$dsr$, $dsr$Five and a half times the land, lower yield$dsr$, $dsr$Rusya'nın tarım arazisi 2.157.010 km². Türkiye'nin **bütün ülkesi** 769.630 km².

Yani Rusya'nın yalnızca tarlaları, Türkiye'nin tamamından iki katı büyük bir yer
kaplıyor. Türkiye'nin tarım arazisiyle karşılaştırıldığında oran 5,59 kat. Kişi
başına düşen işlenebilir arazi Rusya'da 0,85 hektar, Türkiye'de 0,24 hektar.

Buraya kadarı beklenen tablo. Beklenmeyen şu:

**Rusya'nın hektar başına tahıl verimi Türkiye'ninkinden yüksek değil.** 2023'te
Rusya 3.166,6 kg/ha, Türkiye 3.659,1 kg/ha. Türkiye yüzde on üç önde.

*(Türkiye'de 2024 tahıl verimi 3.428,7 kg/ha oldu; Rusya için aynı yıl bulunamadı.
Karşılaştırma iki ülkede de veri bulunan son yıl olan 2023'ten kuruldu.)*

Rusya daha verimli çiftçilik yapmıyor. Daha geniş çiftçilik yapıyor.

Gübre bunu doğruluyor: Rusya hektara 28,73 kilogram gübre kullanıyor, Türkiye 139,56.
Türkiye neredeyse beş kat yoğun. Bir Rus tarlası ile bir Konya tarlası aynı işi
yapmıyor — biri kara toprağın kendi bereketini geniş alana yayıyor, diğeri dar alanda
girdiyle derinleşiyor.

İstihdam da aynı yöne bakıyor: Rusya'da çalışanların yüzde 5,11'i tarımda,
Türkiye'de yüzde 14,22 (2025).

**İki ölçü, iki sonuç.**

FAOSTAT brüt üretim değerini sabit uluslararası dolarla ölçüyor ve 2023 için Rusya'yı
111,0 milyar, Türkiye'yi 79,9 milyar gösteriyor. Dünya Bankası tarımsal katma değeri
cari dolarla ölçüyor ve 2025 için Rusya'yı 78,3 milyar, Türkiye'yi 83,2 milyar
gösteriyor — bu sefer Türkiye önde.

İkisi çelişmiyor, farklı şey ölçüyor. Biri brüt üretimin sabit fiyatla değeri; diğeri
ara girdiler düşüldükten sonra kalan net katma değer, üstelik cari kurla ve rublenin
oynaklığıyla. Karşılaştırma yapılacaksa aynı ölçünün iki ülkedeki değeri kullanılır.

**Farkın toplandığı yer.**

Üretim değeri kalem kalem ayrıldığında tablo netleşiyor. Tüm tarımda Rusya 1,39 kat
önde. Bitkisel üretimde fark 1,18 kata iniyor — neredeyse başa baş. Hayvancılıkta
1,83. Tahılda ise **3,30 kat**.

Rusya'nın üstünlüğü tahılda toplanmış durumda; geri kalan her şeyde iki ülke
birbirine yakın.

Türk tarımı Rus tarımının gerisinde değil; başka bir işte uzmanlaşmış. Rusya'nın
yaptığı iş, geniş kara toprakta düşük girdiyle yüksek hacimli tahıl üretmek.
Türkiye'nin yaptığı iş, dar alanda yüksek girdiyle çeşitli ve yüksek değerli ürün
üretmek.

İki ülke birbirinden bu kadar çok mal alıp satıyorsa, sebebi birinin diğerinden üstün
olması değil, farklı şeyler üretmesidir. Rusya'nın Türkiye'ye satacak tahılı var
çünkü tahıl için uygun geniş toprağı var. Türkiye'nin Rusya'ya satacak meyvesi var
çünkü Rusya'nın iklimi ona meyve vermiyor.$dsr$, $dsr$Russia's agricultural land is 2,157,010 km². **The whole of Türkiye** is 769,630 km².

Russia's fields alone therefore cover an area twice the size of all Türkiye. Compared
with Türkiye's agricultural land the ratio is 5.59. Arable land per person is 0.85
hectares in Russia, 0.24 in Türkiye.

So far, the expected picture. Here is the unexpected one:

**Russia's cereal yield per hectare is not higher than Türkiye's.** In 2023 Russia was
at 3,166.6 kg/ha, Türkiye at 3,659.1 kg/ha. Türkiye is thirteen per cent ahead.

*(Türkiye's 2024 cereal yield was 3,428.7 kg/ha; no figure was found for Russia in the
same year. The comparison is built on 2023, the last year with data for both.)*

Russia does not farm more efficiently. It farms more widely.

Fertiliser confirms it: Russia applies 28.73 kilograms per hectare, Türkiye 139.56.
Türkiye is nearly five times as intensive. A Russian field and a field in Konya are
not doing the same job — one spreads the black earth's own fertility across a wide
area, the other deepens a narrow area with inputs.

Employment points the same way: 5.11 per cent of Russian workers are in agriculture,
14.22 per cent of Turkish workers (2025).

**Two measures, two answers.**

FAOSTAT measures gross production value in constant international dollars and puts
Russia at $111.0 billion for 2023, Türkiye at $79.9 billion. The World Bank measures
agricultural value added in current dollars and puts Russia at $78.3 billion for 2025,
Türkiye at $83.2 billion — this time Türkiye is ahead.

They do not contradict each other; they measure different things. One is gross output
at constant prices; the other is net value added after intermediate inputs, in current
dollars, carrying the rouble's volatility. Any comparison must use the same measure
across both countries.

**Where the gap collects.**

Broken down item by item, the picture clarifies. Across all agriculture Russia is 1.39
times ahead. In crops the gap narrows to 1.18 — near parity. In livestock, 1.83. In
cereals, **3.30**.

Russia's advantage is concentrated in cereals; in everything else the two countries
are close.

Turkish agriculture is not behind Russian agriculture; it specialises in a different
job. Russia's job is producing high-volume cereals on wide black earth with low
inputs. Türkiye's job is producing varied, high-value crops on a narrow area with high
inputs.

If two countries buy and sell this much from each other, the reason is not that one is
superior but that they produce different things. Russia has cereals to sell Türkiye
because it has the wide land cereals need. Türkiye has fruit to sell Russia because
Russia's climate gives it none.$dsr$, array['toprak_ikili', 'uretim_degeri_ikili']::text[], 'veri', null),
  (4, $dsr$Anadolu'dan toplanan tohumlar$dsr$, $dsr$Seeds collected in Anatolia$dsr$, $dsr$1925 ve 1926 yıllarında Vavilov Enstitüsü'nden bir heyet Anadolu'da yaklaşık **12.000
kilometrelik** bir güzergâh boyunca ilerledi. Dönerken yanlarında **5.700'den fazla**
kültür bitkisi örneği vardı; bunların **291'i buğdaydı**. Heyet aynı zamanda dönemin
tarım uygulamalarını da kayda geçirdi.

Enstitüye adını veren adam Nikolai İvanoviç Vavilov'du.

Vavilov 1887'de Moskova'da doğdu. 1916'da İran ve Pamir'e yaptığı ilk seferden
başlayarak, ömrü boyunca **64 ülkeye 115 araştırma seferi** düzenledi. Topladığı
tohum örneği sayısı **250 bini** geçti — dünyanın o zamanki en büyük bitki genetik
kaynağı koleksiyonu.

Bu seferlerden çıkan fikir, 1926'da yayımlanan *Kültür Bitkilerinin Kökeni ve
Coğrafyası*'ydı. Vavilov, kültür bitkilerinin dünyaya rastgele dağılmadığını, her
birinin bir **köken merkezi** olduğunu ve bu merkezlerde o bitkinin genetik
çeşitliliğinin yoğunlaştığını ileri sürdü. Sekiz merkez tanımladı.

Bunlardan biri **Yakın Doğu merkezi**: Küçük Asya — yani Anadolu — Kafkasya ötesi,
İran ve Türkmenistan. Bu merkezin ürünleri arasında birçok buğday türü, çavdar, arpa
ve mercimek var; ayrıca yonca, havuç, lahana, yulaf, soğan, marul, incir, nar, elma,
armut, üzüm, badem, kestane ve antep fıstığı.

Yani bir Türk çiftçisinin toprağında olan şeyin dünya tarımı açısından ne anlama
geldiğini tarif eden çerçeveyi kuran adam Rustu.

**Bugün neden önemli.**

2009-2014 arasında Türkiye'de yapılan bir yerel buğday çeşidi taraması, üç tür ve
altı alt türü temsil eden 95 morfotip buldu. En çeşitli iller Manisa, Konya,
Diyarbakır ve Adana çıktı.

Aynı çalışma, bunun 1920'de kayda geçen çeşitliliğe göre **yüzde 50 ila 70 oranında
bir kayıp** olduğunu söylüyor.

Bu kaybı ölçebiliyor olmamızın sebebi, bir asır önce alınmış kayıttır. Türkiye'nin
yerel buğday çeşitliliğinin yüz yıl önceki hâlini biliyorsak, büyük ölçüde o Rus
seferinin defteri sayesinde biliyoruz.

**Sonu.**

Vavilov 1940'ta batı Ukrayna'da tutuklandı; suçlama vatana ihanet ve casusluktu. 26
Ocak 1943'te Saratov hapishanesinde açlıktan öldü.

Kurduğu koleksiyon ondan sağ çıktı. Leningrad'ın 900 günlük kuşatması sırasında
enstitünün çalışanları, korudukları tohumları açlıktan ölürken bile yemeyi reddetti.

Dünyanın en büyük tohum koleksiyonunu kuran adam açlıktan öldü; koleksiyonu koruyan
insanlar da açlıktan öldü; koleksiyon yaşadı.$dsr$, $dsr$In 1925 and 1926 a party from the Vavilov Institute travelled a route of roughly
**12,000 kilometres** across Anatolia. They returned with more than **5,700** samples
of cultivated plants; **291 of them were wheat**. The party also recorded the farming
practices of the period.

The man the institute is named after was Nikolai Ivanovich Vavilov.

Vavilov was born in Moscow in 1887. Beginning with his first expedition to Iran and
the Pamirs in 1916, he mounted **115 research expeditions to 64 countries** over his
lifetime. The seed samples he gathered passed **250,000** — the largest collection of
plant genetic resources in the world at the time.

The idea that came out of those journeys was *The Origin and Geography of Cultivated
Plants*, published in 1926. Vavilov argued that cultivated plants are not scattered
randomly across the world, that each has a **centre of origin**, and that a plant's
genetic diversity concentrates in that centre. He defined eight centres.

One of them is the **Near Eastern centre**: Asia Minor — that is, Anatolia — the
Transcaucasus, Iran and Turkmenistan. Among this centre's crops are many wheat
species, rye, barley and lentils; also alfalfa, carrot, cabbage, oats, onion, lettuce,
fig, pomegranate, apple, pear, grape, almond, chestnut and pistachio.

So the man who built the framework describing what a Turkish farmer has in his soil,
in world-agricultural terms, was Russian.

**Why it matters today.**

A survey of wheat landraces carried out in Türkiye between 2009 and 2014 found 95
morphotypes representing three species and six subspecies. The most diverse provinces
were Manisa, Konya, Diyarbakır and Adana.

The same study says this represents a **loss of 50 to 70 per cent** against the
diversity recorded in 1920.

The reason we can measure that loss is a record taken a century ago. If we know what
Türkiye's wheat diversity looked like a hundred years back, we largely know it thanks
to the ledger of that Russian expedition.

**The end.**

Vavilov was arrested in western Ukraine in 1940 on charges of treason and espionage.
He died of starvation in a Saratov prison on 26 January 1943.

The collection he built outlived him. During the 900-day siege of Leningrad the
institute's staff refused to eat the seeds they were guarding even as they starved to
death.

The man who built the world's largest seed collection starved; the people who guarded
the collection starved; the collection lived.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarim-app-2026.web.app/dosya/rusya/rusya_vavilov.jpg","atif":"Library of Congress, New York World-Telegram & Sun Collection — kamu malı","kaynak":"https://commons.wikimedia.org/wiki/File:Nikolai_Vavilov_NYWTS.jpg","alt_tr":"Nikolai İvanoviç Vavilov'un portresi. 64 ülkeye 115 sefer düzenleyen ve 250 binden fazla tohum örneği toplayan botanikçi.","alt_en":"Portrait of Nikolai Ivanovich Vavilov, the botanist who mounted 115 expeditions to 64 countries and gathered more than 250,000 seed samples."}$dsr$::jsonb),
  (5, $dsr$Perhiz yağı$dsr$, $dsr$The fasting oil$dsr$, $dsr$Rusya bugün dünyanın en büyük ayçiçeği yağı üreticilerinden biri. 2024'te 6.732 bin
ton üretti, 4.200 bin ton ihraç etti. Türkiye'nin şişelediği yağın hammaddesinin
önemli bir kısmı buradan geliyor.

Bunun kökeninde bir oruç kuralı var.

Ayçiçeği Amerika kıtası kökenli bir bitki ve Avrupa'ya 16. yüzyılda geldi. Uzun süre
süs bitkisi olarak kaldı. 18. yüzyılda Rus Ortodoks Kilisesi, perhiz dönemlerinde
tüketilmesi yasak olan yağları listeledi. Listede tereyağı vardı, domuz yağı vardı.

Ayçiçeği o kadar yeni bir bitkiydi ki listeye girmemişti.

Ortodoks takviminde perhiz günlerinin yılın önemli bir bölümünü kapladığı bir ülkede,
bu boşluk ayçiçeği yağını perhizde tüketilebilen tek yağ hâline getirdi. Talep
patladı. 19. yüzyılın başlarında Rusya ve Ukrayna'da ayçiçeği ekim alanı 800.000
hektarı aştı; yüzyılın üçüncü on yılında ayçiçeği yağı Rusya'da büyük ölçekli ve
kârlı bir sanayi olmuştu.

*(Bu bölümdeki tarihsel bilgi ikincil kaynaklara dayanıyor; üretim ve ticaret
rakamları USDA PSD'den geliyor.)*

Buradan iki şey çıkıyor.

Birincisi, bir ürünün bir ülkenin ürünü hâline gelmesi her zaman toprakla ya da
iklimle açıklanmıyor. Bazen kültürel bir kural, bir yasak listesindeki bir boşluk
kadar tesadüfi bir şey belirliyor.

İkincisi, Türkiye açısından pratik: Karadeniz'in kuzeyinden gelen ayçiçeği yağı
akımının arkasında iki yüzyıllık bir üretim geleneği ve ıslah birikimi var. Bu, bir
sezonda kurulmuş bir üstünlük değil.$dsr$, $dsr$Russia today is one of the world's largest producers of sunflower oil. In 2024 it
produced 6,732 thousand tonnes and exported 4,200 thousand tonnes. A significant share
of the raw material behind the oil Türkiye bottles comes from there.

At the root of this is a fasting rule.

The sunflower is a plant of the Americas and reached Europe in the 16th century. For a
long time it remained ornamental. In the 18th century the Russian Orthodox Church
listed the oils forbidden during fasting periods. Butter was on the list. Lard was on
the list.

The sunflower was such a new plant that it was not on the list at all.

In a country where the Orthodox calendar covered a substantial part of the year with
fast days, that gap made sunflower oil the only oil permissible during the fast. Demand
exploded. By the early 19th century the sunflower area in Russia and Ukraine passed
800,000 hectares; by the third decade of the century sunflower oil was a large-scale
and profitable industry in Russia.

*(Historical detail in this section rests on secondary sources; production and trade
figures come from USDA PSD.)*

Two things follow.

First, a crop becoming a country's crop is not always explained by soil or climate.
Sometimes it is decided by something as accidental as a cultural rule — a gap in a list
of prohibitions.

Second, and practical for Türkiye: behind the flow of sunflower oil from the northern
Black Sea lie two centuries of production tradition and breeding. This is not an
advantage built in a single season.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarim-app-2026.web.app/dosya/rusya/rusya_aycicegi_tarlasi.jpg","atif":"andrew, Wikimedia Commons — CC BY 3.0","kaynak":"https://commons.wikimedia.org/wiki/File:Sunflower_field_in_Russia.JPG","alt_tr":"Rusya'da ufka kadar uzanan ayçiçeği tarlası. İki yüzyıllık bir üretim geleneğinin bugünkü hâli.","alt_en":"A sunflower field stretching to the horizon in Russia — two centuries of production tradition as it stands today."}$dsr$::jsonb),
  (6, $dsr$Kolhozdan agroholdinge$dsr$, $dsr$From kolkhoz to agroholding$dsr$, $dsr$Rus tarlaları büyük. Bunun sebebi coğrafya kadar tarihtir.

Kollektifleştirme 1929'un sonunda, Birinci Beş Yıllık Plan kapsamında başladı.
Köylüler toprağını, hayvanını ve aletlerini kollektif çiftliklere — **kolhoz** — ya
da tamamen devlet işletmesi olan **sovhoz**lara devretti.

Sovyet döneminin sonundaki ölçek şöyleydi: 1990'da 23.500 sovhoz vardı ve ortalama
büyüklükleri **15.300 hektar**. Kolhozların ortalaması 5.900 hektardı; 1988'de sayıları
27.000 dolayına inmişti.

Karşılaştırma için: Türkiye'nin bugünkü toplam buğday ekim alanı 7,25 milyon hektar.
Yani tek bir ortalama sovhoz, Türkiye'nin buğday alanının yaklaşık beş yüzde biri
kadardı — ve bunlardan 23.500 tane vardı.

Aralık 1991'de çıkan bir kararname, üyelere arazi ve arazi dışı varlıklardan orantılı
pay çekip bağımsız çiftlik kurma hakkı verdi; kollektif işletmeler Mart 1992'ye kadar
üretim kooperatifi, limited ortaklık ya da anonim şirkete dönüşmek zorundaydı.

Yaklaşık 300.000 hane payını çekip aile çiftliği kurdu. Özel çiftlik sayısı 1994'te
284.000 ile zirve yaptı ve ortalama büyüklükleri **40 hektardı**.

Sonra yön tersine döndü. 2024'e gelindiğinde, ağırlıklı olarak agroholdinglerden
oluşan **77 büyük tarım şirketi yaklaşık 18,5 milyon hektar** araziyi kontrol
ediyordu. En büyükleri yüz binlerce hektarı ve 20.000'e varan tarım işçisini
yönetiyor.

18,5 milyon hektar, Türkiye'nin toplam buğday ekim alanının **iki buçuk katı**. Bu
alan 77 şirkete düşüyor.

*(Bu bölümdeki rakamlar ikincil ve derleme kaynaklardan; birincil kaynaktan teyit
edilemedi. Şirket adı ve şirket bazlı pay bu dosyada geçmiyor.)*

Türkiye açısından anlamı doğrudan: Rus buğdayının fiyatını belirleyen üretim yapısı,
milyonlarca küçük üreticinin toplamı değil. Sayılı sayıda büyük işletmenin kararı.
Bu, tedarikçinin davranışını daha öngörülebilir ama aynı zamanda daha
koordine edilebilir kılıyor.$dsr$, $dsr$Russian fields are large. The reason is history as much as geography.

Collectivisation began at the end of 1929 under the First Five-Year Plan. Peasants
handed over their land, livestock and tools to collective farms — **kolkhoz** — or to
fully state-run **sovkhoz** enterprises.

The scale at the end of the Soviet period: in 1990 there were 23,500 sovkhozes with an
average size of **15,300 hectares**. The kolkhoz average was 5,900 hectares; by 1988
their number had fallen to around 27,000.

For comparison: Türkiye's total wheat area today is 7.25 million hectares. A single
average sovkhoz was therefore about one five-hundredth of Türkiye's wheat area — and
there were 23,500 of them.

A decree issued in December 1991 gave members the right to withdraw a proportional
share of land and non-land assets and set up an independent farm; collective
enterprises had to convert into production cooperatives, limited partnerships or joint
stock companies by March 1992.

About 300,000 households withdrew their shares and started family farms. The number of
private farms peaked at 284,000 in 1994, with an average size of **40 hectares**.

Then the direction reversed. By 2024, **77 large agricultural companies**, mostly
agroholdings, controlled roughly **18.5 million hectares**. The largest of them manage
hundreds of thousands of hectares and up to 20,000 agricultural workers.

18.5 million hectares is **two and a half times** Türkiye's entire wheat area. That
area falls to 77 companies.

*(Figures in this section come from secondary and compiled sources and could not be
confirmed against a primary source. No company name or company-level share appears in
this dossier.)*

The meaning for Türkiye is direct: the production structure that sets the price of
Russian wheat is not the sum of millions of small producers. It is the decision of a
countable number of large enterprises. That makes the supplier's behaviour more
predictable — and also more coordinable.$dsr$, '{}'::text[], 'belge', $dsr${"url":"https://tarim-app-2026.web.app/dosya/rusya/rusya_1946_tahil_pulu.jpg","atif":"SSCB posta pulu, 1946 — kamu malı","kaynak":"https://commons.wikimedia.org/wiki/File:The_Soviet_Union_1946_CPA_1082_stamp_(Fourth_Five-Year_Plan._Give_the_country_each_year_127_million_tons_of_grain._Combine_harvester_and_wheat_sheaf)_large_resolution.jpg","alt_tr":"1946 tarihli Sovyet posta pulu: biçerdöver ve buğday demeti. Kollektif tarımın hedefi bir posta pulunda ilan ediliyordu.","alt_en":"A 1946 Soviet postage stamp showing a combine harvester and a wheat sheaf — collective agriculture's target announced on postage."}$dsr$::jsonb),
  (7, $dsr$Alan ülkeden satan ülkeye$dsr$, $dsr$From a buying country to a selling one$dsr$, $dsr$1980'de Sovyetler Birliği 16 milyon ton buğday ithal etti. Dünyanın en büyük tahıl
alıcısıydı ve bu, soğuk savaş boyunca dünya buğday fiyatını belirleyen olgulardan
biriydi.

Rusya Federasyonu'nun ayrı kayıtları 1987'de başlıyor. O yıl da ülke buğday alıyordu:
14,9 milyon ton.

Sonra eğri döndü.

Dönüşün tam yılı **2001**. Rusya'nın buğday ihracatı o yıl ithalatını ilk kez aştı,
hem de altı katına çıkarak. Bir yıl önce hâlâ net alıcıydı.

Yirmi iki yıl sonra, 2023'te, ihracat **55,5 milyon tondu**. İthalat pratikte
sıfırlanmıştı.

Bu rakamın büyüklüğünü görmek için Türkiye'ye bakmak yeterli: Rusya'nın tek bir yılda
sattığı buğday, Türkiye'nin o yıl hasat ettiği bütün buğdayın **iki buçuk katı**.

Dönüşüm buğdayla sınırlı değil. Arpa ve mısır ihracatı da 1992'de yüz biner tondan
milyonlarca tona çıktı; mısır üretimi aynı dönemde yedi katına çıktı.

**Alan mı, verim mi?**

Buğdayı iki bileşene ayırınca mekanizma çıplak görünüyor.

İki ülke de 1992'den 2024'e verimini yaklaşık **yüzde elli** artırdı — Rusya hektarda
1,96 tondan 2,94 tona, Türkiye 1,76'dan 2,62'ye. Tarımsal bilgi ve girdi tarafında
ikisi de benzer bir yol katetti.

Ayrıldıkları yer alan. Aynı otuz iki yılda Rusya buğday ektiği alanı **yüzde 18
büyüttü**, Türkiye **yüzde 18 küçülttü**.

Rusya'nın buğday ihracatındaki patlama bir verim mucizesi değil. Boş duran toprağın
yeniden ekilmesi ve o hasadın limana ulaştırılabilmesi.$dsr$, $dsr$In 1980 the Soviet Union imported 16 million tonnes of wheat. It was the world's
largest grain buyer, and this was one of the facts that set world wheat prices through
the cold war.

The Russian Federation's separate records begin in 1987. That year the country was
still buying wheat: 14.9 million tonnes.

Then the curve turned.

The exact year of the turn is **2001**. Russia's wheat exports exceeded its imports for
the first time that year, and by sixfold. A year earlier it had still been a net buyer.

Twenty-two years later, in 2023, exports stood at **55.5 million tonnes**. Imports had
effectively fallen to zero.

To grasp the size of that figure, look at Türkiye: the wheat Russia sold in a single
year is **two and a half times** all the wheat Türkiye harvested that year.

The transformation was not confined to wheat. Barley and maize exports also rose from
hundreds of thousands of tonnes in 1992 to millions; maize production rose sevenfold in
the same period.

**Area, or yield?**

Splitting wheat into its two components lays the mechanism bare.

Both countries raised their yield by roughly **fifty per cent** between 1992 and 2024 —
Russia from 1.96 to 2.94 tonnes per hectare, Türkiye from 1.76 to 2.62. On agricultural
knowledge and inputs, both travelled a similar distance.

Where they parted was area. Over the same thirty-two years Russia **expanded** its
wheat area by 18 per cent; Türkiye **contracted** its own by 18 per cent.

The explosion in Russian wheat exports is not a yield miracle. It is idle land put back
under the plough, and that harvest reaching a port.$dsr$, array['bugday_donus_cizgi', 'alan_verim_ikili']::text[], 'veri', null),
  (8, $dsr$Çöküş ve dönüş$dsr$, $dsr$Collapse and return$dsr$, $dsr$Rusya'nın tarım hikâyesi düz bir yükseliş değil. Önce çok sert bir düşüş var.

1992'de Rusya, Türkiye'nin 2,3 katı tarımsal üretim yapıyordu. 2000'e gelindiğinde
üretimi **üçte bir küçülmüştü** ve aradaki fark neredeyse kapanmıştı.

Buğdayda çöküşün mekaniği açık. 1990 ile 1998 arasında hem ekilen alan hem hektar
verimi düştü: alan 23,54 milyon hektardan 19,95 milyona, verim 2,11 tondan 1,35 tona.
Üretim 49,60 milyon tondan 27,01 milyon tona indi — neredeyse yarısı.

**Ekilen alan 3,6 milyon hektar azaldı.** Türkiye'nin bugünkü buğday alanının yarısı
kadar bir toprak üretimden çıktı.

Bunlar bir savaşın ya da kuraklığın rakamları değil. Girdi tedarik zincirinin, makine
parkının ve mülkiyet düzeninin aynı anda dağılmasının rakamları. İkinci bölümdeki
kara toprak yerinde duruyordu; onu işletecek yapı yoktu. Toprak bekleyebilir; traktör,
gübre ve alıcı bekleyemez.

Dip 1998'de. Sonra yirmi üç yılda tarımsal üretim değeri yüzde 80 arttı ve buğday
hasat alanı 27,80 milyon hektara döndü.

Aynı dönemde Türkiye kesintisiz büyüdü: otuz yılda üretimini ikiye katladı ve hiçbir
yılda Rusya'nınki gibi bir çöküş yaşamadı. Bu bölgede sıradan bir performans değil.$dsr$, $dsr$Russia's agricultural story is not a straight ascent. First there is a very steep fall.

In 1992 Russia produced 2.3 times Türkiye's agricultural output. By 2000 its output had
**shrunk by a third** and the gap had almost closed.

The mechanics of the collapse are clear in wheat. Between 1990 and 1998 both sown area
and yield per hectare fell: area from 23.54 million hectares to 19.95 million, yield
from 2.11 tonnes to 1.35. Production fell from 49.60 million tonnes to 27.01 million —
almost half.

**Sown area fell by 3.6 million hectares.** A stretch of land half the size of Türkiye's
current wheat area went out of production.

These are not the figures of a war or a drought. They are the figures of an input supply
chain, a machinery fleet and a system of ownership disintegrating at once. The black
earth of the second section was still there; the structure to work it was not. Soil can
wait; a tractor, fertiliser and a buyer cannot.

The floor is 1998. Over the following twenty-three years agricultural production value
rose by 80 per cent and the wheat area returned to 27.80 million hectares.

In the same period Türkiye grew without interruption: it doubled its output over thirty
years and suffered no collapse of the Russian kind in any year. In this region that is
not an ordinary performance.$dsr$, array['uretim_degeri_cizgi']::text[], 'veri', null),
  (9, $dsr$Çavdarın terk edilişi$dsr$, $dsr$The abandonment of rye$dsr$, $dsr$Rusya'da kara ekmek 9.-10. yüzyıldan beri biliniyor. Dayanıklı çavdar, özellikle
kuzeyde ülkenin sert iklimine en uygun tahıldı. 19. yüzyılda Avrupa Rusyası'nın elli
vilayetinin **kırkında** başlıca üründü. Köy sofrasında lahana çorbasının yanında
kişi başına günde bir kiloya varan miktarda tüketilirdi.

Beyaz buğday ekmeği ancak 20. yüzyılın başında yaygınlaştı ve uzun süre bir varlık
göstergesi sayıldı; sıradan insan için bayram yemeğiydi.

İkinci Dünya Savaşı öncesinde Rusya'da üretilen ekmeğin yüzde 70'inde çavdar unu
vardı. Bugün bu oran yüzde 30 dolayında.

*(Kültürel bilgi ve yüzdeler ikincil kaynaklardan.)*

Tarladaki karşılığı çok daha sert. Rusya'nın çavdar üretimi 1992'de 13,89 milyon
tondu. 2000'de 5,44 milyon, 2010'da 1,64 milyon, 2024'te 1,20 milyon ton. Otuz iki
yılda **on birde bire** indi.

Aynı dönemde buğday üretimi 46,17 milyon tondan 81,6 milyon tona, mısır 2,14 milyon
tondan 14,0 milyon tona çıktı.

Rusya çavdardan vazgeçip buğdaya ve mısıra geçti. Sebebi teknik değil ticari:
çavdarın dünya pazarı yok, buğdayın var. Rusya'nın çavdar ihracatı 2024'te 70 bin
tonda kaldı; buğday ihracatı 43 milyon ton. Aynı tarlada, aynı toprakta, biri diğerinin
altı yüz katı.

Bir ülkenin bin yıllık ekmeği, ihracata uygun olmadığı için tarladan çekildi.

Bu, yedinci bölümdeki soruyu tersinden cevaplıyor. Rusya'nın tarımsal dönüşümü iç
tüketim için değil, **ihracat için** tasarlandı. Ürün seçiminin kendisi bunu
söylüyor.

Türkiye açısından buradaki soru şu: bizim tarlalarımızda hangi ürünler dünya pazarına
uygun olmadığı için çekiliyor, ve bu her seferinde doğru karar mı?$dsr$, $dsr$Black bread has been known in Russia since the 9th and 10th centuries. Hardy rye was the
grain best suited to the country's harsh climate, especially in the north. In the 19th
century it was the principal crop in **forty** of the fifty provinces of European Russia.
At the village table, beside cabbage soup, it was eaten in quantities reaching a kilo a
day per person.

White wheat bread became widespread only at the start of the 20th century and was long
taken as a mark of wealth; for ordinary people it was festival food.

Before the Second World War, 70 per cent of the bread produced in Russia contained rye
flour. Today that share is around 30 per cent.

*(Cultural detail and percentages from secondary sources.)*

What happened in the fields is far harsher. Russia's rye production was 13.89 million
tonnes in 1992. In 2000, 5.44 million; in 2010, 1.64 million; in 2024, 1.20 million. It
fell to **one eleventh** in thirty-two years.

In the same period wheat production rose from 46.17 million tonnes to 81.6 million, and
maize from 2.14 million to 14.0 million.

Russia gave up rye and moved to wheat and maize. The reason is not technical but
commercial: rye has no world market, wheat does. Russia's rye exports in 2024 came to
70 thousand tonnes; its wheat exports, 43 million. On the same fields, in the same soil,
one is six hundred times the other.

A country's thousand-year bread was withdrawn from the fields because it did not suit
export.

This answers the question of the seventh section from the other side. Russia's
agricultural transformation was designed not for domestic consumption but **for export**.
The choice of crop says so by itself.

The question for Türkiye: which crops are being withdrawn from our fields because they do
not suit the world market, and is that the right decision every time?$dsr$, array['cavdar_cizgi']::text[], 'anlati', $dsr${"url":"https://tarim-app-2026.web.app/dosya/rusya/rusya_borodinski_ekmek.jpg","atif":"Tiraspolsky, Wikimedia Commons — CC BY-SA 4.0","kaynak":"https://commons.wikimedia.org/wiki/File:Бородинский_хлеб.jpg","alt_tr":"Dilimlenmiş Borodinski ekmeği: koyu renkli, çavdar unundan yapılan Rus kara ekmeğinin en bilinen türü.","alt_en":"Sliced Borodinsky bread: dark, made from rye flour, the best known of the Russian black breads."}$dsr$::jsonb),
  (10, $dsr$Yirmi milyon bahçe$dsr$, $dsr$Twenty million gardens$dsr$, $dsr$Rusya dünyanın en büyük buğday ihracatçısı. Aynı Rusya, patatesinin **beşte dördünü**
arka bahçelerde yetiştiriyor.

Rosstat'ın 2014 verisine göre tarım kuruluşları tahılın yüzde 73,8'ini, ayçiçeğinin
yüzde 70,1'ini, şeker pancarının yüzde 88,9'unu üretiyor. Aynı kuruluşların patatesteki
payı yüzde 12,3, sebzedeki payı yüzde 16,7.

Boşluğu dolduran hane bahçeleri. Tahılda, ayçiçeğinde ve şeker pancarında payları
kaynağın ifadesiyle "yüzde birden az". Patateste **yüzde 80,1**, sebzede yüzde 69,3.

Tek ülkenin içinde iki ayrı tarım var ve birbirlerine neredeyse hiç değmiyorlar.

Birincisi altıncı bölümde anlatılan yapı: yüz binlerce hektarlık işletmeler, kombayn
filoları, liman terminalleri, ihracat vergisi. İhracata giden her şey burada
üretiliyor.

İkincisi bahçe. Hukuki çerçevesi 7 Temmuz 2003 tarihli 112-FZ sayılı "Hane Çiftlikleri
Hakkında" Federal Kanun ve 15 Nisan 1998 tarihli bahçecilik birlikleri kanunu. Ölçek
küçük, mekanizasyon yok, satış çoğunlukla yok — üretilen şey satılmıyor, yeniyor. Ve
Rus sofrasındaki patatesin dört parçasından üçü buradan geliyor.

Bunun pratik sonucu, Rusya'nın gıda güvenliğini okurken akılda tutulmalı: ülkenin
ihracat kapasitesi ile ülkenin sofrası aynı yerden beslenmiyor. Tahıl ihracatı
dursa Rus mutfağındaki patates etkilenmez; patates zaten pazara hiç girmemiştir.

Türkiye'de de benzer bir katman var — köy bahçesi, kendi tüketimi için üretim, kayda
girmeyen küçük üretici. Ama Türkiye'nin istatistiği bu katmanı Rusya'nınki kadar
ayrıntılı ayırmıyor. Rusya'nın kendi verisi, ihracat devi bir tarımın altında ne kadar
büyük bir geçimlik tarımın durabildiğini gösteriyor.$dsr$, $dsr$Russia is the world's largest wheat exporter. The same Russia grows **four-fifths** of its
potatoes in back gardens.

According to Rosstat's 2014 data, agricultural enterprises produce 73.8 per cent of
cereals, 70.1 per cent of sunflower and 88.9 per cent of sugar beet. The same enterprises
account for 12.3 per cent of potatoes and 16.7 per cent of vegetables.

Household gardens fill the gap. In cereals, sunflower and sugar beet their share is, in
the source's phrase, "less than one per cent". In potatoes it is **80.1 per cent**, in
vegetables 69.3.

There are two separate agricultures inside one country, and they barely touch.

The first is the structure described in the sixth section: enterprises of hundreds of
thousands of hectares, combine fleets, port terminals, export duty. Everything that goes
to export is produced here.

The second is the garden. Its legal frame is Federal Law 112-FZ of 7 July 2003, "On
Household Farms", and the gardening-associations law of 15 April 1998. The scale is small,
there is no mechanisation, and mostly there is no sale — what is grown is not sold but
eaten. And three of every four potatoes on the Russian table come from here.

The practical consequence should be kept in mind when reading Russia's food security: the
country's export capacity and the country's table are not fed from the same place. If
grain exports stopped, the potato in the Russian kitchen would not be affected; that
potato never entered the market in the first place.

Türkiye has a similar layer — the village garden, growing for one's own table, the small
producer who never enters the record. But Turkish statistics do not separate that layer in
the detail Russia's do. Russia's own data shows how large a subsistence agriculture can
stand beneath an export giant.$dsr$, array['kim_uretiyor_yigin']::text[], 'veri', $dsr${"url":"https://tarim-app-2026.web.app/dosya/rusya/rusya_dacha_bahcesi.jpg","atif":"Vovs Vtoroi, Wikimedia Commons — CC BY 3.0","kaynak":"https://commons.wikimedia.org/wiki/File:Дача_-_panoramio_(25).jpg","alt_tr":"Bir dacha bahçesi: küçük parseller, sebze sıraları ve ahşap bir ev. Rusya'nın patatesinin beşte dördü bu ölçekten geliyor.","alt_en":"A dacha garden: small plots, rows of vegetables and a wooden house. Four-fifths of Russia's potatoes come from this scale."}$dsr$::jsonb),
  (11, $dsr$Türkiye ters yöne yürüdü$dsr$, $dsr$Türkiye walked the other way$dsr$, $dsr$1980'de Türkiye **sıfır ton** buğday ithal etti. O yıllarda ülke buğdayda kendine
yetiyor, hatta satıyordu.

2022'de Türkiye 12,07 milyon ton buğday ithal etti — o yılki kendi hasadının üçte
ikisi kadar.

Bu cümle üretim rakamı yanına konmadan yanlış anlaşılır.

Türkiye'nin buğday üretimi **düşmedi**. 1960'ta 7 milyon ton, 2023'te 21 milyon ton —
üç kat arttı. Aynı dönemde buğday ihracatı neredeyse yoktan 9,95 milyon tona çıktı.

Türkiye buğday üretmeyi bırakmadı. Türkiye'nin **buğday işleme kapasitesi kendi
hasadının önüne geçti**.

Ekim alanı ise daralıyor: 1992'de 8,8 milyon hektar, 2024'te 7,25 milyon hektar.
Verim aynı dönemde yüzde elli arttığı için üretim düşmedi — daha az alanda daha çok
ürün alındı. Tarım arazisi üzerinde başka baskılar varken üretimi korumak küçük bir
başarı değil.

Ama üretim korunurken talep büyüdü. Nüfus, un sanayii ve ihracat kapasitesi hep
birlikte arttı; ekilen alan artmadı. Aradaki farkı ithalat kapattı.

Yedinci bölümdeki eğriyle bu bölümdeki eğri aynı otuz yılda ters yöne gidiyor ve
birbirinden bağımsız değil: Rusya'nın sattığı, Türkiye'nin işleyip yeniden sattığı
maldır.$dsr$, $dsr$In 1980 Türkiye imported **zero tonnes** of wheat. In those years the country fed itself
in wheat and even sold it.

In 2022 Türkiye imported 12.07 million tonnes of wheat — about two-thirds of its own
harvest that year.

That sentence is misread unless the production figure sits beside it.

Türkiye's wheat production **did not fall**. It was 7 million tonnes in 1960 and 21
million in 2023 — a threefold rise. Over the same period wheat exports went from almost
nothing to 9.95 million tonnes.

Türkiye did not stop growing wheat. Türkiye's **wheat processing capacity outgrew its own
harvest**.

The sown area, though, is narrowing: 8.8 million hectares in 1992, 7.25 million in 2024.
Because yield rose by fifty per cent over the same period, production did not fall — more
was taken from less. Holding production steady while other pressures bear on farmland is
no small achievement.

But while production held, demand grew. Population, the milling industry and export
capacity all rose together; the sown area did not. Imports closed the gap.

The curve in the seventh section and the curve in this one run in opposite directions over
the same thirty years, and they are not independent: what Russia sells is what Türkiye
processes and sells on.$dsr$, array['turkiye_bugday_cizgi']::text[], 'veri', null),
  (12, $dsr$Onsekizinciden birinciye$dsr$, $dsr$From eighteenth to first$dsr$, $dsr$Rusya'nın raporladığı tarım ihracatını partner ülkelere göre ayırınca Türkiye'nin
konumu görünüyor — ve konum yirmi yılda baştan sona değişmiş.

2001'de Türkiye, Rusya'nın **on sekizinci** tarım müşterisiydi; aldığı pay yüzde 1,6.
2006'da dokuzuncu sıraya, 2009'da üçüncüye çıktı. **2012'de birinci oldu** ve
kayıtların bittiği 2021'e kadar on yılın dokuzunda birinciliği bırakmadı. Tek istisna
2018; o yıl Mısır öne geçti.

2021'de Türkiye tek başına Rusya'nın tarım ihracatının **yüzde 16,4'ünü** aldı — 159
partner ülke arasında, 4,33 milyar dolarlık alışverişle. İkinci sıradaki Kazakistan'ın
aldığı 2,69 milyar dolardı; Türkiye ondan yüzde 61 fazla alıyor.

Listenin üst sırasındaki iki ülke — Kazakistan ve Belarus — Rusya ile aynı gümrük
birliğinin üyesi. Komşuluk ve birlik ilişkisi olmadan bu hacme ulaşan tek ülke
Türkiye.

Rusya bizim en büyük tarım tedarikçimiz; biz de onun dünyadaki en büyük tarım
müşterisiyiz. İlişki asimetrik ama tek yönlü değil.

Ve Türkiye bu konuma doğmadı. Payı yüzde 1,6'dan yüzde 16,4'e, yirmi yılda on kat
arttı — tam da Rusya dünyanın en büyük buğday satıcısına dönüşürken. Yedinci
bölümdeki eğri ile bu bölümdeki tırmanış aynı yıllarda oluyor.

**Veri notu:** Rusya'nın FAOSTAT'a raporlaması 2021'de bitiyor. 2022, 2023 ve 2024
için satır yok; sonrasını Rusya'nın defterinden okuyamıyoruz.$dsr$, $dsr$Break Russia's reported agricultural exports down by partner country and Türkiye's position
appears — a position that changed completely over twenty years.

In 2001 Türkiye was Russia's **eighteenth** agricultural customer, taking 1.6 per cent. It
rose to ninth in 2006 and third in 2009. **In 2012 it became first**, and did not give up
that place in nine of the ten years to 2021, where the records end. The single exception is
2018, when Egypt moved ahead.

In 2021 Türkiye alone took **16.4 per cent** of Russia's agricultural exports — among 159
partner countries, in $4.33 billion of trade. Kazakhstan, in second place, took $2.69
billion; Türkiye takes 61 per cent more.

Two of the countries at the top of that list — Kazakhstan and Belarus — belong to the same
customs union as Russia. Türkiye is the only country to reach this volume without a
neighbourhood or union relationship.

Russia is our largest agricultural supplier; we are its largest agricultural customer in
the world. The relationship is asymmetric but not one-way.

And Türkiye was not born into that position. Its share rose from 1.6 to 16.4 per cent —
tenfold in twenty years — exactly as Russia was turning into the world's largest wheat
seller. The curve in the seventh section and the climb in this one happen in the same
years.

**Data note:** Russia's reporting to FAOSTAT ends in 2021. There are no rows for 2022,
2023 or 2024; beyond that point we cannot read Russia's own ledger.$dsr$, array['musteriler_siralama']::text[], 'veri', null),
  (13, $dsr$Çayın kuzey sınırı$dsr$, $dsr$The northern edge of tea$dsr$, $dsr$İki ülke arasında ters yöne akmış bir ürün var, ve bugün Türkiye'nin en tanınmış
tarım simgesi.

Türkiye'de çay yetiştirme çalışmaları 1888'de başladı. Ticaret Nazırı İsmail Paşa
aracılığıyla Çin'den tohum getirtildi ve Bursa dolaylarında ekildi. Olumlu sonuç
alınamadı.

1917'de Batum ve havalisinde inceleme yapan bir heyette bulunan Halkalı Yüksek Ziraat
Mektebi Müdür Vekili **Ali Rıza Erten**, İktisat Vekaleti'ne verdiği raporda Batum
çevresinde çay ve narenciyenin yetiştiğini, aynı ekolojik şartların bulunduğu Rize ve
civarında da denenmesini önerdi. Rapor önce dikkate alınmadı.

1924'te çıkarılan **407 Sayılı Kanun** ile çay üretimi çalışmaları başladı. Rize'de
bir Bahçe Kültürleri İstasyonu kuruldu ve başına Ziraat Umum Müfettişi **Zihni Derin**
getirildi.

Deneme çalışmaları olumlu sonuç verince, **1937'de Sovyetler Birliği'nden Gürcistan
kökenli 20 ton çay tohumu** alındı. 1939'da 30 ton, 1940'ta 20 ton daha alınıp
üreticiye dağıtıldı.

29 Mart 1940 tarihli **3788 Sayılı Çay Kanunu** ile çay tarımı ve üreticisi
desteklendi. Çıkarılan kararnameyle Araklı'dan Rus sınırına kadar uzanan bölgede 30
bin dönümlük bir alan çay tarımına ayrıldı ve Ziraat Bankası'ndan üreticilere beş yıl
süreyle faizsiz kredi verilmesi kararlaştırıldı.

Sonuç, rakamla: 1973'te günde 2.732 ton yaş çay yaprağı işleniyordu; 2020'de 9.020
ton.

Sınırın öbür tarafında da bir çay hikâyesi var. Gürcistan, Abhazya ve Türkiye'de çay
tarlalarında çalışmış olan Yuda Koşman, 1901'de Soçi yakınlarındaki Soloh-aul köyünde
bir arazi alıp çay yetiştirmeye başladı ve soğuğa dayanıklı bir çeşit geliştirdi.
Krasnodar çayı, 2012'de Birleşik Krallık ilk yerel hasadını alana kadar dünyanın en
kuzeydeki çayı olarak anıldı.

*(Rusya tarafındaki bilgiler ikincil kaynaklardan; Türkiye tarafı ÇAYKUR'un kendi
tarihçesinden.)*

Bu dosyadaki ticaret tablolarının hepsinde akış Rusya'dan Türkiye'ye. Çay, ters yöne
akmış olanı — ve akan şey mal değil, tohumdu. Bir kere alındı, yüz yıl boyunca
Türkiye'nin kendi ürünü oldu.$dsr$, $dsr$One product has flowed the other way between these two countries, and today it is Türkiye's
best-known agricultural symbol.

Work on growing tea in Türkiye began in 1888. Seed was brought from China through the
Minister of Trade İsmail Pasha and planted around Bursa. Nothing came of it.

In 1917 **Ali Rıza Erten**, acting director of the Halkalı Higher School of Agriculture and
a member of a party surveying Batumi and its surroundings, reported to the Ministry of
Economy that tea and citrus grew around Batumi and recommended trying them in Rize and its
district, where the same ecological conditions were found. The report was initially ignored.

**Law 407**, passed in 1924, began the work on tea production. A Garden Cultures Station was
established in Rize under the Inspector General of Agriculture, **Zihni Derin**.

When the trials succeeded, **20 tonnes of Georgian-origin tea seed were bought from the
Soviet Union in 1937**. A further 30 tonnes in 1939 and 20 tonnes in 1940 were purchased and
distributed to growers.

**Tea Law 3788** of 29 March 1940 supported tea farming and its producers. A decree set aside
30 thousand dönüm for tea in the region running from Araklı to the Russian border, and
provided interest-free credit from Ziraat Bankası to growers for five years.

The result, in figures: in 1973, 2,732 tonnes of fresh tea leaf were processed per day; in
2020, 9,020 tonnes.

There is a tea story on the other side of the border too. Yuda Koshman, who had worked on tea
plantations in Georgia, Abkhazia and Türkiye, bought land in the village of Solokh-aul near
Sochi in 1901, began growing tea and developed a frost-resistant variety. Krasnodar tea was
described as the world's northernmost until the United Kingdom took its first local harvest
in 2012.

*(Detail on the Russian side comes from secondary sources; the Turkish side from ÇAYKUR's own
history.)*

In every trade table in this dossier the flow runs from Russia to Türkiye. Tea is the one
that flowed the other way — and what flowed was not goods but seed. It was bought once, and
for a hundred years it has been Türkiye's own crop.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarim-app-2026.web.app/dosya/rusya/rusya_rize_cay.jpg","atif":"Wikimol, Wikimedia Commons — CC BY-SA 2.5","kaynak":"https://commons.wikimedia.org/wiki/File:Rize_Tea_Plantation_2005-jk.jpg","alt_tr":"Rize'de yamaca yayılmış çay bahçesi. Bu bitkinin atası 1937'de Batum'dan gelen tohumdan.","alt_en":"A tea garden spread across a hillside in Rize. The ancestor of this plant came from seed brought from Batumi in 1937."}$dsr$::jsonb),
  (14, $dsr$Vana: ihracat vergisi ve kota$dsr$, $dsr$The valve: export duty and quota$dsr$, $dsr$Rus tahılının dünya fiyatı ile iç fiyatı arasına ayarlanabilir bir vana konmuş
durumda. İki parçası var.

**Tahıl damperi.** 2 Haziran 2021'de yürürlüğe girdi. Buğday, mısır ve arpa
ihracatına değişken bir vergi uyguluyor:

> vergi = (gösterge fiyat − referans fiyat) × %70

Gösterge fiyat, Moskova Borsası'na kayıtlı ihracat sözleşmelerinin fiyatlarından
haftalık hesaplanıyor. Referans fiyat yönetimin belirlediği eşik ve zamanla
yükseltildi:

| | buğday | arpa ve mısır |
|---|---|---|
| 2 Haziran 2021 | 15.000 ₽/ton | 13.875 ₽/ton |
| Temmuz 2023 | 17.000 ₽/ton | 15.875 ₽/ton |
| 28 Haziran 2024 | 18.000 ₽/ton | 16.875 ₽/ton |

Fiyat eşiği aştığında vergi kendiliğinden yükseliyor; eşiğin altına düştüğünde sıfıra
inebiliyor. Toplanan tutar üreticiye sübvansiyon olarak geri veriliyor. Vergi
başlangıçta dolarla, Temmuz 2022'den beri rubleyle hesaplanıyor.

**Kota.** Kararname No. 2089 ile 24 Aralık 2025'te duyuruldu: 15 Şubat - 30 Haziran
2026 arasında Avrasya Ekonomik Birliği dışına tahıl ihracatı **20 milyon tonla**
sınırlandı; 10 Nisan 2026'da 5 milyon ton artırıldı. Bir önceki yıl kota 10,6 milyon
tondu. Kapsam buğday, mahlut, çavdar, arpa ve mısır; hükümet kararına dayalı insani
yardım sevkiyatları kotanın dışında.

Türk çiftçisi ve Türk değirmencisi için anlamı şu: **Rus buğdayının Türkiye'ye geliş
fiyatı yalnızca hasada bağlı değil.** Moskova'da belirlenen bir eşik ve bir tavan da
fiyatın içinde. Hasat iyi olduğu yıl bile ihracat vergisi yükselirse maliyet yukarı
gider; kota dolduğunda arz yılın ikinci yarısında daralır.

Türkiye'de un fiyatını tartışırken bakılan değişkenler — Konya Ovası'nın yağışı,
TMO'nun alım fiyatı, kur — listenin tamamı değil. Moskova'da haftalık ilan edilen bir
vergi oranı ve şubatta açıklanan bir kota rakamı da aynı listede. Bunlar gizli
değişkenler değil; ilan ediliyorlar. Ama Türk tarım gündeminde düzenli izlenen
kalemler arasında değiller.

Rusya'nın yaptığı, ihracat gelirini iç gıda fiyatından ayırmak — kendi tüketicisini
dünya fiyatından korumak için kurulmuş bir mekanizma. Türkiye'nin de benzer araçları
var ve on sekizinci bölümde biri çalışırken görülecek. Buradaki mesele ahlaki değil
yapısal: tedarik zincirinin fiyat düğmesi ithalatçı ülkede değil.

*(Bu bölümdeki mevzuat bilgileri Rusya Tarım Bakanlığı duyurularının haber ajansları
üzerinden aktarımına ve Global Trade Alert'in belge künyesine dayanıyor.)*$dsr$, $dsr$An adjustable valve has been placed between the world price and the domestic price of Russian
grain. It has two parts.

**The grain damper.** In force since 2 June 2021, it applies a floating duty to exports of
wheat, maize and barley:

> duty = (indicative price − reference price) × 70%

The indicative price is calculated weekly from the prices of export contracts registered on
the Moscow Exchange. The reference price is a threshold set by the administration and has
been raised over time:

| | wheat | barley and maize |
|---|---|---|
| 2 June 2021 | ₽15,000/t | ₽13,875/t |
| July 2023 | ₽17,000/t | ₽15,875/t |
| 28 June 2024 | ₽18,000/t | ₽16,875/t |

When the price passes the threshold the duty rises automatically; when it falls below, the
duty can go to zero. What is collected is returned to producers as subsidy. The duty was
initially calculated in dollars and, since July 2022, in roubles.

**The quota.** Announced on 24 December 2025 by Decree No. 2089: between 15 February and 30
June 2026, grain exports outside the Eurasian Economic Union were capped at **20 million
tonnes**; on 10 April 2026 this was raised by 5 million. The previous year's quota was 10.6
million tonnes. It covers wheat, meslin, rye, barley and maize; humanitarian shipments made
under government decision fall outside it.

For the Turkish farmer and the Turkish miller this means: **the price at which Russian wheat
reaches Türkiye does not depend on the harvest alone.** A threshold and a ceiling set in
Moscow are also inside that price. Even in a good harvest year, if the export duty rises the
cost goes up; when the quota fills, supply tightens in the second half of the year.

The variables watched when flour prices are discussed in Türkiye — rainfall on the Konya
plain, TMO's purchase price, the exchange rate — are not the whole list. A duty rate announced
weekly in Moscow and a quota figure published in February belong on the same list. These are
not hidden variables; they are announced. But they are not among the items routinely tracked
on Türkiye's agricultural agenda.

What Russia has done is separate export revenue from domestic food prices — a mechanism built
to shield its own consumer from world prices. Türkiye has similar instruments, and one of them
will be seen working in the eighteenth section. The point here is structural, not moral: the
price switch of the supply chain is not in the importing country.

*(Regulatory detail in this section rests on agency reporting of Russian Ministry of
Agriculture announcements and on Global Trade Alert's document record.)*$dsr$, '{}'::text[], 'belge', null),
  (15, $dsr$Novorossiysk$dsr$, $dsr$Novorossiysk$dsr$, $dsr$Rus tahılının Türkiye'ye çıkış kapısı Karadeniz. Karadeniz'in en büyük tahıl kapısı
Novorossiysk.

İşletmecilerinin kendi beyanına göre iki büyük terminalin kapasitesi:

| terminal | yıllık kapasite | tek seferlik depolama |
|---|---|---|
| Novorossiysk Tahıl Terminali (NZT) | 8,5 milyon ton | 200.000 ton |
| Novorossiysk Tahıl İşleme Tesisi (NKHP) | 7,1 milyon ton | 245.000 ton |

NZT 2008'de hizmete girmiş, derin su rıhtımları ve çift gemi yükleyicisi var.
NKHP'nin gemi yükleme hızı saatte 2.000 ton.

Büyümeyi görmek için on üç yıl öncesine bakmak yeterli. ABD Tarım Bakanlığı'nın 16
Ağustos 2013 tarihli liman raporunda aynı limandaki üç terminalin toplam kapasitesi
**11,5 milyon tondu**. Bugün yalnızca doğrulanabilen iki terminal 15,6 milyon ton.

*(2013 rakamları yalnızca büyümeyi göstermek için. Limandaki üçüncü terminalin
bugünkü kapasitesi işletmecisinin kendi kaynağından doğrulanamadığı için bu dosyada
toplam kapasite rakamı verilmiyor.)*

Asıl mesele kapasitenin büyüklüğü değil, darlığı.

Rusya 2023'te 55,5 milyon ton buğday ihraç etti. Novorossiysk'te doğrulanabilen iki
terminalin toplam yıllık kapasitesi 15,6 milyon ton — tek başına o buğday ihracatının
yaklaşık **dörtte biri**, üstelik arpa, mısır ve ayçiçeği yağı buna dahil değil.

Karşılaştırma için: bu iki terminalin kapasitesi, Türkiye'nin 2023'teki toplam buğday
ithalatının (9,35 milyon ton) bir buçuk katı. Türkiye'nin bir yıllık buğday
ithalatının tamamı, bu iki rıhtımın sekiz aylık işine denk geliyor.

Dünyanın en büyük buğday ihracatı, coğrafi olarak son derece dar bir boğazdan akıyor.

**12 Ağustos 2026'da** Novorossiysk'teki tahıl terminalleri insansız hava aracı
saldırısının ardından işlemlerini durdurdu. Doğrulanabilen iki terminalin yıllık
kapasitesi toplamı 15,6 milyon ton. NKHP'nin işletmecisi hasar tespitinin sürdüğünü,
ayrıntıları daha sonra paylaşacağını bildirdi; kaynakta yeniden çalışma süresi
verilmiyor. *(Reuters aktarımı, 12 Ağustos 2026. Yaşayan bir durum.)*

Olayın kendisinden bağımsız olarak kalıcı olan şudur: Türkiye'nin buğdayının önemli
bir kısmı sayılı sayıda rıhtımdan geçerek geliyor. Tedarik güvenliği yalnızca hasat
riskiyle değil, lojistik yoğunlaşmayla da ilgili.$dsr$, $dsr$The exit gate for Russian grain heading to Türkiye is the Black Sea. The Black Sea's largest
grain gate is Novorossiysk.

The capacity of the two large terminals, on their operators' own statements:

| terminal | annual capacity | single-load storage |
|---|---|---|
| Novorossiysk Grain Terminal (NZT) | 8.5 million t | 200,000 t |
| Novorossiysk Grain Processing Plant (NKHP) | 7.1 million t | 245,000 t |

NZT came into service in 2008 and has deep-water berths and twin shiploaders. NKHP loads ships
at 2,000 tonnes an hour.

To see the growth, look back thirteen years. In the US Department of Agriculture's port report
of 16 August 2013, the combined capacity of three terminals at the same port was **11.5 million
tonnes**. Today the two terminals that can be verified alone come to 15.6 million.

*(The 2013 figures are here only to show growth. Because the current capacity of the port's
third terminal could not be verified from its operator's own source, no total capacity figure
is given in this dossier.)*

The real point is not the size of the capacity but its narrowness.

Russia exported 55.5 million tonnes of wheat in 2023. The combined annual capacity of the two
verifiable terminals at Novorossiysk is 15.6 million tonnes — roughly **a quarter** of that
wheat export on its own, and that is before barley, maize and sunflower oil.

For comparison: the capacity of those two terminals is one and a half times Türkiye's total
wheat imports in 2023 (9.35 million tonnes). A whole year of Turkish wheat imports amounts to
eight months' work at these two berths.

The world's largest wheat export flows through a geographically very narrow throat.

**On 12 August 2026** the grain terminals at Novorossiysk suspended operations following a
drone attack. The combined annual capacity of the two verifiable terminals is 15.6 million
tonnes. NKHP's operator reported that damage assessment was under way and that details would
follow; the source gives no timeline for resumption. *(Reuters reporting, 12 August 2026. A
live situation.)*

What remains true independently of the event: a significant part of Türkiye's wheat arrives by
passing through a countable number of berths. Supply security is a matter not only of harvest
risk but of logistical concentration.$dsr$, '{}'::text[], 'belge', $dsr${"url":"https://tarim-app-2026.web.app/dosya/rusya/rusya_ksk_terminali.jpg","atif":"IvanStudenov, Wikimedia Commons — CC BY-SA 4.0","kaynak":"https://commons.wikimedia.org/wiki/File:Grain_shipments_at_KSK_terminal.jpg","alt_tr":"Novorossiysk'te KSK tahıl terminali: rıhtımda yükleme yapan gemi ve silolar. Türkiye'nin buğdayı bu rıhtımlardan geçiyor.","alt_en":"The KSK grain terminal at Novorossiysk: a ship loading at the berth, with silos behind. Türkiye's wheat passes through these piers."}$dsr$::jsonb),
  (16, $dsr$Üç kanal: gıda, yem, girdi$dsr$, $dsr$Three channels: food, feed, input$dsr$, $dsr$Rusya Türk tarımına üç ayrı kanaldan değiyor ve bunlardan biri tarım
istatistiklerine hiç girmiyor.

**Gıda.** İnsanın yediği: buğday, ayçiçeği yağı, sebze. 2024'te tahıl tek başına 2,91
milyar dolar.

**Yem.** Hayvanın yediği. 2024'te yem ve küspe faslı 1,56 milyar dolarla ikinci
sırada. Serisi, üç kanal içinde en dikkat çekici olanı (milyon $):

| 2013 | 2016 | 2019 | 2021 | 2022 | 2024 |
|---|---|---|---|---|---|
| 493 | 540 | 617 | 887 | 1.381 | 1.555 |

On iki yılda **üç kat** arttı ve — tahılın ve gübrenin aksine — neredeyse hiç geri
gitmedi. Ambargoda da, 2024'ün ithalat kısıtlamasında da yükselmeye devam etti. Buğday
ithalatı 2024'te üçte bire inerken yem ithalatı arttı; iki kanal birbirinden bağımsız
çalışıyor.

Süt ve et fiyatı tartışılırken bu satır nadiren anılıyor. Oysa maliyet tabanının bir
parçası.

**Girdi.** Gübre. HS31 faslı tarım faslı değil, bu yüzden "tarım ticareti"
toplamlarının hiçbirinde görünmüyor. Oysa doğrudan tarlaya giriyor.

Rusya'dan gübre ithalatı, milyon dolar:

| 2013 | 2015 | 2017 | 2020 | 2022 | 2024 |
|---|---|---|---|---|---|
| 723 | 457 | 222 | 157 | 711 | 376 |

2024'te bileşik gübre 248 milyon dolar, azotlu gübre 76 milyon dolar. Seri oynak:
2020'de 157 milyon dolara inmiş, iki yıl sonra 711 milyon dolara çıkmış — dört buçuk
kat.

Buğday fiyatı, yem fiyatı ve gübre fiyatı aynı ülkeden etkileniyor. Üç ayrı pazar,
tek bir tedarikçi coğrafyası.$dsr$, $dsr$Russia touches Turkish agriculture through three separate channels, and one of them never
appears in agricultural statistics at all.

**Food.** What people eat: wheat, sunflower oil, vegetables. In 2024 cereals alone came to
$2.91 billion.

**Feed.** What animals eat. In 2024 the feed and oilcake chapter stood second at $1.56 billion.
Its series is the most striking of the three channels ($ million):

| 2013 | 2016 | 2019 | 2021 | 2022 | 2024 |
|---|---|---|---|---|---|
| 493 | 540 | 617 | 887 | 1,381 | 1,555 |

It **tripled** in twelve years and — unlike cereals and fertiliser — barely ever went backwards.
It kept rising through the embargo and through the 2024 import restriction. While wheat imports
fell to a third in 2024, feed imports rose; the two channels run independently.

This line is rarely mentioned when milk and meat prices are discussed. Yet it is part of the
cost base.

**Input.** Fertiliser. Chapter HS31 is not an agricultural chapter, so it appears in none of the
"agricultural trade" totals. It nonetheless goes straight into the field.

Fertiliser imports from Russia, $ million:

| 2013 | 2015 | 2017 | 2020 | 2022 | 2024 |
|---|---|---|---|---|---|
| 723 | 457 | 222 | 157 | 711 | 376 |

In 2024 compound fertiliser came to $248 million and nitrogen fertiliser to $76 million. The
series is volatile: down to $157 million in 2020, up to $711 million two years later — four and a
half times.

The price of wheat, the price of feed and the price of fertiliser are all affected by the same
country. Three separate markets, one supplier geography.$dsr$, '{}'::text[], 'veri', null),
  (17, $dsr$2016: pazarın kapandığı yıl$dsr$, $dsr$2016: the year the market closed$dsr$, $dsr$2015'te Türkiye Rusya'ya 518 milyon dolarlık domates sattı.

2016'da sıfır.

Yuvarlanmış değil, tam olarak sıfır. Aynı yıl üzüm 202 milyon dolardan 8 milyon
dolara indi — yüzde 96 düşüş. Türkiye'nin Rusya'ya toplam tarım ihracatı 2,22 milyar
dolardan 1,01 milyar dolara, yarısının altına indi.

Asıl mesele krizin kendisi değil, dokuz yıl sonrası.

2024'te domates ihracatı 87 milyon dolar — 2015'in **yüzde 16,9'u**. Üzüm 130 milyon,
yüzde 64,5. Turunçgil 746 milyon, yani kriz öncesinin **yüzde 127'si**; o kalem
küçülmedi, büyüdü.

Üç ürün de bozulur. Üçü de aynı krizde vuruldu. Üçü aynı yere dönmedi.

Fark bozulmakta değil, **ikame edilebilmekte**. Ve ikame kendiliğinden olmadı.

2014'ten sonra Rusya'da yeni sera projelerine, inşa ve modernizasyon harcamasının bir
bölümünün geri ödenmesi yoluyla **maliyetin yüzde 20'sine kadar** destek ve imtiyazlı
yatırım kredisi verildi. Sera sebze üretimi 2014'e göre yüzde 65 arttı. Domates
ithalatının toplam tüketimdeki payı 2017'de yüzde 60'tan 2018'de yüzde 45'e indi.

*(Destek mekanizması USDA'nın 18 Eylül 2015 tarihli raporundan; üretim artışı ve
ithalat payları ikincil kaynaklardan.)*

Türk domatesinin yerini bir mevsimin fiyat hareketi almadı; bir yatırım programı aldı.
Cam kurulduktan sonra geri sökülmüyor.

Üzümde aynı yatırım yapılmadı, o yüzden pazar bir yılda geri geldi. Turunçgili Rusya
iklimi nedeniyle yetiştiremiyor — o kalemde Türkiye'nin yerini alacak yerli üretim
yok, ve kriz bittiğinde ticaret sadece geri gelmedi, büyüdü.

Buradan çıkan kural:

> **Risk, malın bozulmasında değil; alıcının onu kendi üretebilmesinde.**

Bir Türk üreticisi için pratik karşılığı doğrudan: serada yetişen her şey ikame
edilebilir. İklimin verdiği şey — turunçgil, incir, kayısı, fındık — çok daha zor
ikame edilir.$dsr$, $dsr$In 2015 Türkiye sold Russia $518 million of tomatoes.

In 2016, zero.

Not rounded — exactly zero. In the same year grapes fell from $202 million to $8 million, a 96
per cent drop. Türkiye's total agricultural exports to Russia fell from $2.22 billion to $1.01
billion, below half.

The real subject is not the crisis but what came nine years later.

In 2024 tomato exports were $87 million — **16.9 per cent** of 2015. Grapes were $130 million,
64.5 per cent. Citrus was $746 million, that is **127 per cent** of the pre-crisis level; that
item did not shrink, it grew.

All three products perish. All three were hit in the same crisis. The three did not return to
the same place.

The difference is not in perishing but in **being substitutable**. And the substitution did not
happen by itself.

After 2014, new greenhouse projects in Russia received support of **up to 20 per cent of cost**
through partial reimbursement of construction and modernisation spending, along with preferential
investment loans. Greenhouse vegetable production rose 65 per cent against 2014. The share of
imports in total tomato consumption fell from 60 per cent in 2017 to 45 per cent in 2018.

*(The support mechanism comes from the USDA report of 18 September 2015; the production increase
and import shares from secondary sources.)*

The Turkish tomato's place was not taken by one season's price movement; it was taken by an
investment programme. Once the glass is up it does not come down.

The same investment was not made in grapes, so that market returned within a year. Russia cannot
grow citrus because of its climate — there is no domestic production to take Türkiye's place in
that item, and when the crisis ended the trade did not merely return, it grew.

The rule that follows:

> **The risk is not in the goods perishing; it is in the buyer being able to produce them.**

For a Turkish grower the practical meaning is direct: anything that grows under glass can be
substituted. What the climate gives — citrus, figs, apricots, hazelnuts — is far harder to
substitute.$dsr$, array['ambargo_ikili']::text[], 'veri', null),
  (18, $dsr$Un, yağ, yem: bizim işleme makinemiz$dsr$, $dsr$Flour, oil, feed: our processing machine$dsr$, $dsr$On birinci bölümde bıraktığımız yerden: Türkiye ürettiğinden fazlasını satıyorsa,
aradaki fark nereden geliyor?

Cevap en çıplak hâliyle ayçiçeği yağında duruyor. Türkiye 2024'te 795 bin ton
ayçiçeği yağı üretti, **1.236 bin ton ithal etti**, 1.001 bin ton ihraç etti.

İthalat üretimden fazla. Üstelik ayrıca 789 bin ton da ham tohum alınıp burada
sıkılıyor.

Aynı yıl Rusya 6.732 bin ton ayçiçeği yağı üretti ve 4.200 bin ton ihraç etti.
Türkiye'nin şişelediği yağın hammaddesi bu iki satırın arasında.

Makinenin ne zaman kurulduğu seride görünüyor. 1992'de Türkiye 420 bin ton ayçiçeği
yağı üretiyor, 154 bin ton alıyor, 73 bin ton satıyordu. 2024'te üretim 795 bin tona
çıkmış — iki katı. İhracat 1.001 bin tona çıkmış — **on dört katı**. Aradaki farkı
ithalat kapattı; 154 bin tondan 1.236 bin tona.

Türkiye ayçiçeği yağı ihracatçısı olmayı, ayçiçeği üreticisi olarak değil ayçiçeği
**işleyicisi** olarak başardı.

Bu işte Rusya tek başına ele alınamaz. 2024'te Rusya 4,20 milyon ton ayçiçeği yağı
ihraç ederken Ukrayna 4,74 milyon ton ihraç etti; buğdayda Rusya 43,0 milyon ton,
Ukrayna 15,75 milyon ton. Türkiye'nin işleme sanayii için bu, tedarikin tek ülkeye
değil **tek havzaya** bağlı olduğu anlamına geliyor. Kaynak çeşitlendirmesi Rusya'dan
Ukrayna'ya geçmekle olmuyor; ikisi de aynı denizin kıyısında, aynı boğazdan çıkıyor.

Buğdayda mekanizmanın adı var: **dahilde işleme rejimi**. İthal buğday gümrük
muafiyetiyle giriyor, un ya da makarna olup çıkıyor.

Bu bir zayıflık değil, bir iş modeli. Türkiye'nin bu işteki avantajı coğrafi —
hammaddenin kaynağına yakınlık, limanlar, kurulmuş değirmen kapasitesi.

Modelin zayıf noktasını Türkiye 2024'te kendisi test etti.

6 Haziran 2024'te, dahilde işleme rejimi kapsamındaki buğday ithalatı 21 Haziran - 15
Ekim 2024 arasında durduruldu. Aynı duyuruda TMO 2024 müdahale fiyatlarını açıkladı:
makarnalık buğday 11.750 TL/ton, ekmeklik buğday 11.000 TL/ton, arpa 8.000 TL/ton —
Bakanlık ödeme desteği dahil. Eylül 2018'den beri yasak olan yerli buğdaydan un
ihracatı serbest bırakıldı; ekmeklik ve makarnalık buğday ile arpa ihracatı da TMO
onayına bağlı olarak kontrollü biçimde açıldı.

Gerekçe kaynakta açık: üreticiyi fiyat dalgalanmasından korumak ve yurt içi hammadde
alımını güvenceye almak.

Etkisi rakamda: Türkiye'nin buğday ithalatı 2023'te 9,35 milyon tondan 2024'te 3,32
milyon tona indi. Aynı yıl Rusya'dan toplam tarım ithalatı 10,46 milyar dolardan 6,83
milyar dolara geriledi. İki bağımsız kaynak — USDA'nın miktar serisi ve Türkiye'nin
gümrük kaydı — aynı yöne işaret ediyor.

Kaynakta kayıtlı bir ayrıntı daha var. Rus Tahıl Birliği uygulama tarihinin 30
Haziran'a ertelenmesini istemiş; karar duyurulduğu gibi uygulanmış.

Bu ilişkide Türkiye edilgen taraf değil. Elinde araç var ve kullanıyor.$dsr$, $dsr$Picking up where the eleventh section left off: if Türkiye sells more than it produces, where does
the difference come from?

The answer stands most nakedly in sunflower oil. In 2024 Türkiye produced 795 thousand tonnes of
sunflower oil, **imported 1,236 thousand tonnes** and exported 1,001 thousand tonnes.

Imports exceed production. And on top of that, another 789 thousand tonnes of raw seed is bought
and crushed here.

In the same year Russia produced 6,732 thousand tonnes of sunflower oil and exported 4,200
thousand. The raw material of the oil Türkiye bottles lies between those two lines.

When the machine was built is visible in the series. In 1992 Türkiye produced 420 thousand tonnes
of sunflower oil, bought 154 thousand and sold 73 thousand. By 2024 production had risen to 795
thousand — double. Exports had risen to 1,001 thousand — **fourteen times**. Imports closed the
gap, from 154 thousand tonnes to 1,236 thousand.

Türkiye became a sunflower oil exporter not as a sunflower producer but as a sunflower
**processor**.

Russia cannot be taken alone in this business. In 2024 Russia exported 4.20 million tonnes of
sunflower oil while Ukraine exported 4.74 million; in wheat, Russia 43.0 million tonnes and
Ukraine 15.75 million. For Türkiye's processing industry this means supply is tied not to a single
country but to a **single basin**. Diversifying the source is not a matter of moving from Russia to
Ukraine; both sit on the same sea and leave through the same strait.

In wheat the mechanism has a name: the **inward processing regime**. Imported wheat enters
duty-free and leaves as flour or pasta.

This is not a weakness but a business model. Türkiye's advantage in it is geographical — proximity
to the source of the raw material, ports, established milling capacity.

Türkiye tested the model's weak point itself in 2024.

On 6 June 2024 wheat imports under the inward processing regime were suspended between 21 June and
15 October 2024. In the same announcement TMO published its 2024 intervention prices: durum wheat
11,750 TL/tonne, milling wheat 11,000 TL/tonne, barley 8,000 TL/tonne — including the Ministry's
payment support. Flour exports from domestic wheat, banned since September 2018, were liberalised;
exports of milling wheat, durum wheat and barley were also opened on a controlled basis subject to
TMO approval.

The stated reason is clear in the source: to protect the producer from price fluctuation and to
secure domestic raw material purchasing.

The effect is in the figures: Türkiye's wheat imports fell from 9.35 million tonnes in 2023 to 3.32
million in 2024. In the same year total agricultural imports from Russia fell from $10.46 billion to
$6.83 billion. Two independent sources — USDA's volume series and Türkiye's customs record — point
the same way.

One more detail is on the record. The Russian Grain Union asked for the implementation date to be
moved to 30 June; the decision was applied as announced.

Türkiye is not the passive side of this relationship. It has instruments, and it uses them.$dsr$, array['isleme_ikili']::text[], 'veri', null),
  (19, $dsr$Türkiye ne alabilir$dsr$, $dsr$What Türkiye can take$dsr$, $dsr$Bu dosyanın en kolay yanlış sonucu şudur: "Rusya'ya bağımlıyız, kurtulmalıyız."

Rakamlar bu cümleyi hem eksik hem yanıltıcı kılıyor. Türkiye Rusya'nın dünyadaki en
büyük tarım müşterisi; 2021'de ihracatının yüzde 16,4'ünü tek başına aldı. Bu bir
bağımlılık ilişkisi değil, karşılıklı ve büyük bir ticaret ilişkisi. Kurtulmak
gereken bir şey değil, yönetilmesi gereken bir şey.

Altı şey söylenebilir.

**Bir: farkın nerede olduğunu bilmek.** Tüm tarımda Rusya 1,39 kat önde, bitkisel
üretimde 1,18 kat, tahılda 3,30 kat. Hektar verimi Türkiye'nin lehine. Türkiye'nin
tahılda Rusya'yı yakalama hedefi koyması, beş buçuk kat araziyle ve binlerce yıllık
çernozyomla yarışmak demektir. Rekabet edilecek yer orası değil.

**İki: ikame edilebilirliğe göre pazar seçmek.** Domates dokuz yıl sonra hâlâ eski
hacminin altıda birinde; turunçgil kriz öncesinin yüzde 127'sinde. Fark, ürünün alıcı
ülkede yetiştirilebilir olup olmamasında. İhracat teşviki, seranın altında yetişen
ürüne değil, iklimin verdiği ürüne gitmeli — orada Türkiye'nin yerini alacak kimse
yok.

**Üç: yem ve gübre kanalını gıda kadar ciddiye almak.** Gübre serisi dört buçuk kat
oynadı; yem ve küspe 1,56 milyar dolarla Rusya'dan ithalatın ikinci kalemi ve on iki
yılda hiç geri gitmedi. Süt ve et fiyatının maliyet tabanı burada.

**Dört: tek havzaya bağlılığı görmek.** Ayçiçeği yağında ithalat üretimi geçmiş
durumda ve tedarik Rusya ile Ukrayna'ya, yani tek bir denizin kıyısına bağlı.
Novorossiysk'teki iki terminal Türkiye'nin bir yıllık buğday ithalatını sekiz ayda
yüklüyor. Kaynak çeşitliliği bir maliyet kalemi değil, sigorta primi.

**Beş: yerel çeşitliliği kayıt altına almak.** Türkiye'nin yerel buğday çeşitliliği
bir asırda yüzde 50-70 azaldı ve bunu bilebiliyoruz çünkü 1925-26'da Anadolu'da
12.000 kilometre yol yapan bir heyet kayıt tutmuştu. O kaydı tutan biz değildik.
Bugün elimizde kalanın kaydını tutmak, yarın ne kaybettiğimizi bilebilmenin tek
yolu.

**Altı: verinin kendisini bir varlık saymak.** Rosstat okunamadı, gümrük idaresi
okunamadı, Rusya'nın FAOSTAT raporlaması 2021'de bitti. Buna karşılık Türkiye'nin
kendi ticaret kaydı eksiksiz — yirmi dört yılın her yılı, her fasıl, her kalem.
Bu bir avantajdır ve tarım politikası tartışmalarında yeterince kullanılmıyor.

---

Bu dosyanın tezi baştan beri tek cümleydi: Rusya hem pazarımız hem tedarikçimiz, ama
ondan aldığımız bir yıl bekler, ona sattığımız birkaç hafta dayanır.

On yedinci bölüm o cümleyi bir adım ilerletti. Mesele malın ne kadar dayandığı değil,
alıcının onu kendisi üretip üretemeyeceği. Silodaki buğday bekler ama Türkiye onu
kendi topraklarında yeterince üretemez. Kamyondaki domates beklemez ve Rusya onu cam
altında üretebilir.

Bir de ters yöne akmış bir şey vardı. 1937'de Batum'dan yirmi ton tohum geldi ve
Rize'ye ekildi. O tohumdan bugün günde dokuz bin ton yaş yaprak işleniyor. İki ülke
arasında taşınan en kalıcı şey mal değil, tohum oldu.$dsr$, $dsr$The easiest wrong conclusion from this dossier is: "We are dependent on Russia and must break free."

The figures make that sentence both incomplete and misleading. Türkiye is Russia's largest
agricultural customer in the world; in 2021 it took 16.4 per cent of its exports single-handed. This
is not a relationship of dependence but a large and reciprocal trading relationship. It is not
something to break free of but something to manage.

Six things can be said.

**One: knowing where the gap actually is.** Across all agriculture Russia is 1.39 times ahead, in
crops 1.18, in cereals 3.30. Yield per hectare favours Türkiye. For Türkiye to set a target of
catching Russia in cereals means competing with five and a half times the land and thousands of
years of chernozem. That is not where the competition is.

**Two: choosing markets by substitutability.** Nine years on, tomatoes are still at a sixth of their
old volume; citrus is at 127 per cent of pre-crisis. The difference lies in whether the product can
be grown in the buying country. Export support should go not to what grows under glass but to what
the climate gives — there, nobody can take Türkiye's place.

**Three: taking the feed and fertiliser channels as seriously as food.** The fertiliser series swung
four and a half times; feed and oilcake, at $1.56 billion, is the second item of imports from Russia
and has not gone backwards in twelve years. The cost base of milk and meat prices is here.

**Four: seeing the dependence on a single basin.** In sunflower oil imports have overtaken production,
and supply is tied to Russia and Ukraine — the shore of a single sea. Two terminals at Novorossiysk
load a whole year of Turkish wheat imports in eight months. Source diversity is not a cost item but
an insurance premium.

**Five: recording local diversity.** Türkiye's wheat landrace diversity fell by 50 to 70 per cent in a
century, and we can know this because a party that covered 12,000 kilometres across Anatolia in
1925-26 kept a record. We were not the ones who kept it. Recording what remains today is the only way
to know tomorrow what we have lost.

**Six: treating the data itself as an asset.** Rosstat could not be read, the customs administration
could not be read, Russia's FAOSTAT reporting ended in 2021. Against that, Türkiye's own trade record
is complete — every year of twenty-four, every chapter, every item. That is an advantage, and it is
not used enough in agricultural policy debate.

---

The thesis of this dossier was a single sentence from the beginning: Russia is both our market and our
supplier, but what we buy from it keeps for a year and what we sell to it keeps for weeks.

The seventeenth section carried that sentence one step further. The question is not how long the goods
last but whether the buyer can produce them. Wheat in a silo waits, but Türkiye cannot grow enough of
it on its own land. A tomato on a truck does not wait, and Russia can grow it under glass.

And one thing flowed the other way. In 1937 twenty tonnes of seed came from Batumi and were planted in
Rize. From that seed, nine thousand tonnes of fresh leaf are processed a day today. The most lasting
thing carried between the two countries was not goods but seed.$dsr$, '{}'::text[], 'anlati', null),
  (20, $dsr$Kaynakça$dsr$, $dsr$Sources$dsr$, $dsr$**World Bank Open Data — World Development Indicators** — Tarım arazisi, işlenebilir arazi, tahıl verimi, gübre tüketimi, tarımsal katma değer, istihdam ve nüfus göstergeleri. Lisans: CC BY 4.0

**USDA Foreign Agricultural Service — Production, Supply and Distribution (PSD)** — Buğday, arpa, mısır, çavdar ve ayçiçeği serileri, 1960-2026. SSCB ve Rusya ayrı kayıtlardır. ABD federal yayını, kamu malı

**UN Comtrade** — Türkiye–Rusya ikili tarım ticareti, 2013-2024. Raporlayan taraf Türkiye, partner Rusya

**FAOSTAT — Value of Production (QV)** — Brüt üretim değeri, sabit 2014-2016 uluslararası dolar. Lisans: CC BY 4.0

**FAOSTAT — Production: Crops and Livestock (QCL)** — Üretim miktarı ve hasat alanı. Lisans: CC BY 4.0

**FAOSTAT — Detailed Trade Matrix (TM)** — Rusya'nın tarım ihracatının partner kırılımı, 1998-2021. Lisans: CC BY 4.0

**Anastasia A. Fedotova** — "The Origins of the Russian Chernozem Soil (Black Earth): Franz Joseph Ruprecht's 'Geo-Botanical Researches into the Chernozem' of 1866", Environment and History. Ruprecht ve Dokuçayev bölümünün kaynağı

**Morgounov, A., Keser, M., Kan, M., Küçükçongar, M., Özdemir, F., Gummadov, N., Muminjanov, H., Zuev, E., Qualset, C.O. (2016)** — "Wheat landraces currently grown in Turkey: Distribution, diversity, and use", Crop Science 56(6): 3112-3124. Vavilov Enstitüsü'nün Anadolu seferi ve yerel çeşitlilik kaybının kaynağı

**Crop Trust** — "Nikolai Vavilov: The Father of Genebanks". Vavilov'un seferleri, koleksiyonu ve ölümü

**ÇAYKUR — "Kuruluşumuzun Tarihçesi, Türk Ekonomisindeki Yeri ve Gelişimi"** — Türk çayının Batum tohumuyla başlangıcı, 407 ve 3788 sayılı kanunlar, işleme kapasitesi. Kurumun kendi yayını

**USDA FAS GAIN — "Classification of Agricultural Producers in Russia"** — Moskova, 6 Kasım 2015. Hane bahçelerinin üretimdeki payının kaynağı; oranlar Rosstat kaynaklı. ABD federal yayını, kamu malı

**USDA FAS GAIN — "Turkiye Announces Changes to Wheat Trade Policy"** — Rapor no TU2024-0027, Ankara, 5 Temmuz 2024. Haziran 2024 kararının ve TMO müdahale fiyatlarının kaynağı

**USDA FAS GAIN — "Government Import Substitution Measures in Agriculture"** — Moskova, 18 Eylül 2015. Sera destek mekanizmasının kaynağı

**USDA FAS GAIN — "Russian Grain Port Capacity and Transportation Update"** — Moskova, 16 Ağustos 2013. Yalnızca tarihsel karşılaştırma için

**Demetra-Holding** — Novorossiysk Tahıl Terminali ve Novorossiysk Tahıl İşleme Tesisi kapasiteleri; işletmecinin kendi beyanı

**Global Trade Alert** — Kararname No. 2089 ve 2026 tahıl ihracat kotasının belge künyesi

**Rusya Tarım Bakanlığı duyurularının haber ajansları üzerinden aktarımı** — Tahıl damperi mekanizması ve referans fiyat seyri. Birincil metne erişilemedi; kaynak niteliği ikincildir

**NPR ve Nuseed Europe** — Ayçiçeğinin Rusya'da yayılması ve perhiz kuralı. İkincil

**Rusya Beyond ve kültür yayınları** — Kara ekmek ve çavdarın tarihi, Krasnodar çayı. İkincil

**Reuters aktarımı, 12 Ağustos 2026** — Novorossiysk terminallerinin işlemlerini durdurması$dsr$, $dsr$**World Bank Open Data — World Development Indicators** — Agricultural land, arable land, cereal yield, fertiliser consumption, agricultural value added, employment and population indicators. Licence: CC BY 4.0

**USDA Foreign Agricultural Service — Production, Supply and Distribution (PSD)** — Wheat, barley, maize, rye and sunflower series, 1960-2026. The USSR and Russia are separate records. US federal publication, public domain

**UN Comtrade** — Türkiye–Russia bilateral agricultural trade, 2013-2024. Reporter Türkiye, partner Russia

**FAOSTAT — Value of Production (QV)** — Gross production value, constant 2014-2016 international dollars. Licence: CC BY 4.0

**FAOSTAT — Production: Crops and Livestock (QCL)** — Production quantity and harvested area. Licence: CC BY 4.0

**FAOSTAT — Detailed Trade Matrix (TM)** — Partner breakdown of Russia's agricultural exports, 1998-2021. Licence: CC BY 4.0

**Anastasia A. Fedotova** — "The Origins of the Russian Chernozem Soil (Black Earth): Franz Joseph Ruprecht's 'Geo-Botanical Researches into the Chernozem' of 1866", Environment and History. Source for the Ruprecht and Dokuchaev section

**Morgounov, A., Keser, M., Kan, M., Küçükçongar, M., Özdemir, F., Gummadov, N., Muminjanov, H., Zuev, E., Qualset, C.O. (2016)** — "Wheat landraces currently grown in Turkey: Distribution, diversity, and use", Crop Science 56(6): 3112-3124. Source for the Vavilov Institute's Anatolian expedition and the loss of local diversity

**Crop Trust** — "Nikolai Vavilov: The Father of Genebanks". Vavilov's expeditions, collection and death

**ÇAYKUR — "The History of Our Institution, Its Place in the Turkish Economy and Its Development"** — The beginning of Turkish tea with Batumi seed, Laws 407 and 3788, processing capacity. The institution's own publication

**USDA FAS GAIN — "Classification of Agricultural Producers in Russia"** — Moscow, 6 November 2015. Source for the household share of production; the ratios originate with Rosstat. US federal publication, public domain

**USDA FAS GAIN — "Turkiye Announces Changes to Wheat Trade Policy"** — Report no. TU2024-0027, Ankara, 5 July 2024. Source for the June 2024 decision and TMO intervention prices

**USDA FAS GAIN — "Government Import Substitution Measures in Agriculture"** — Moscow, 18 September 2015. Source for the greenhouse support mechanism

**USDA FAS GAIN — "Russian Grain Port Capacity and Transportation Update"** — Moscow, 16 August 2013. For historical comparison only

**Demetra-Holding** — Capacities of the Novorossiysk Grain Terminal and the Novorossiysk Grain Processing Plant; the operator's own statement

**Global Trade Alert** — Document record for Decree No. 2089 and the 2026 grain export quota

**Agency reporting of Russian Ministry of Agriculture announcements** — The grain damper mechanism and the course of reference prices. The primary text could not be reached; the source is secondary

**NPR and Nuseed Europe** — The spread of the sunflower in Russia and the fasting rule. Secondary

**Russia Beyond and cultural publications** — The history of black bread and rye, and Krasnodar tea. Secondary

**Reuters reporting, 12 August 2026** — The suspension of operations at the Novorossiysk terminals$dsr$, '{}'::text[], 'anlati', null)
) as v(ord, title_tr, title_en, body_tr, body_en, chart_keys, tur, gorsel)
where d.slug = 'rusya';

-- Sağlama: beklenen bölüm sayısı yazılmadıysa işlem geri alınır.
do $kontrol$
declare n integer;
begin
  select count(*) into n
    from public.dossier_sections s
    join public.country_dossiers d on d.id = s.dossier_id
   where d.slug = 'rusya';
  if n <> 20 then
    raise exception 'Bölüm sayısı 20 olmalıydı, % yazıldı', n;
  end if;
end
$kontrol$;


-- ════════════════════════════════════════════════════════════════════
-- ziraat-bankasi — üretilmiş seed (node content/dossiers/seed_dossier.mjs ziraat-bankasi)
-- ════════════════════════════════════════════════════════════════════
-- Ziraat Bankası — Ülke Dosyası · seed
--
-- ÜRETİLMİŞ DOSYA — elle düzenlemeyin.
-- Kaynak:  content/dossiers/ziraat-bankasi/
-- Üretim:  node content/dossiers/seed_dossier.mjs ziraat-bankasi
-- Tarih:   2026-08-29T10:47:25.521Z
--
-- Bölüm: 13 · TR ~2.951 kelime · EN ~3.928 kelime
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
  'ziraat-bankasi',
  'Ziraat Bankası',
  'Ziraat Bankası',
  null,
  'kurum',
  $dsr$Memleket Sandıkları · 1863 — 4603 sayılı Kanun · kabul 25.11.2000$dsr$,
  2,
  $dsr$Türkiye'de tarıma açılan kredinin üçte ikisi, 1863'te bir kasabada kurulan sandıktan geliyor.$dsr$,
  $dsr$Two thirds of all agricultural credit in Türkiye comes from a fund set up in a small town in 1863.$dsr$,
  $dsr${"_dosya":"Ziraat Bankası — Kurum Dosyası · tasarım künyesi","_amac":"Evrak görsel dilinin bu dosyadaki uygulaması. Palet DİZİ paletidir ve dosyadan dosyaya değişmez; burada yalnızca kümenin vurgusu seçiliyor. Ülke Dosyası’nda her ülke kendi paletini alıyordu — haftalık ritimde o model çöker ve dizi kimliğini yok eder.","_kontrast_betigi":"content/dossiers/_ortak/kontrast.py","tez_cumlesi":{"tr":"Türkiye'de tarıma açılan kredinin üçte ikisi, 1863'te bir kasabada kurulan sandıktan geliyor.","en":"Two thirds of all agricultural credit in Türkiye comes from a fund set up in a small town in 1863.","_ad":"Şemada `thesis_tr` ama bir TEZ değil, tanıtım cümlesi (§8.2).","_neden":"Cümle iddia kurmuyor, ÖLÇÜ veriyor ve ölçünün iki ucu da birincil kaynaklı: pay bankanın faaliyet raporundan, payda BDDK'dan. Büyüklüğü kurumun kendi diliyle ('lider', 'öncü') değil oranla anlatıyor."},"kume":{"ad":"Finans","gerekce":"Ziraat piyasaya fiyat açıklayarak değil KREDİ AÇARAK giriyor; işlevi TMO'nunkinden farklı ve arşivde farklı renkle okunmalı. Finans vurgusu kontrast.py'de zaten tanımlıydı, bu dosyayla ilk kez kullanılıyor."},"palet":{"ad":"Evrak — kağıt gövde","kaynak_fikir":"Kurumun manzarası yok; maddi karşılığı kağıttır. Kanun, tutanak, rapor, makbuz. Zemin arşiv kağıdı: haberin sıcak kremine (#F6F1E7) karşı soğuk gri.","mod":"KOYU KAPAK → KAĞIT GÖVDE. Dosya sayfası sistem açık/koyu tercihini izlemez.","mod_gerekcesi":"Fiziksel dosyanın kendisi: dışı mukavva kapak, içi kağıt. Okur ana sayfadan girip tam ekran koyu kapakla karşılaşıyor, kaydırınca kağıda iniyor.","sayfa":{"zemin":{"hex":"#E3E7E5","rol":"Sayfa zemini — arşiv kağıdı"},"yuzey":{"hex":"#F0F2F0","rol":"Kart, tablo, kayıt bloğu"},"murekkep":{"hex":"#15191A","rol":"Gövde metni","kontrast_zemin":14.19,"kontrast_yuzey":15.74},"sessiz":{"hex":"#575F61","rol":"Meta, kaynak satırı","kontrast_zemin":5.23,"kontrast_yuzey":5.81},"vurgu":{"hex":"#1D5B4A","rol":"Finans — rakamlar, başlık vurguları","kontrast_zemin":6.36,"kontrast_yuzey":7.05},"ikincil":{"hex":"#575F61","rol":"Karşılaştırma ikinci serisi — kasıtlı olarak nötr","kontrast_zemin":5.23},"cizgi":{"hex":"#C0C6C3","rol":"SADECE dekoratif ayırıcı","kontrast_zemin":1.39,"_uyari":"3:1 altında. Anlam taşıyan hiçbir yerde kullanılamaz."},"cizgiVurgu":{"hex":"#767E7C","rol":"Eksen, ızgara, odak halkası","kontrast_zemin":3.34,"kontrast_yuzey":3.7}},"kapak":{"_amac":"Kapak gövdeden AYRI: dışı koyu mukavva, içi kağıt. Bu blok yoksa kapak gövde renklerini kullanır (ülke dosyalarında öyle).","zemin":{"hex":"#131718","rol":"Kapak zemini — mukavva"},"murekkep":{"hex":"#F0F2F0","rol":"Kurum adı, tez cümlesi","kontrast_zemin":16.04},"sessiz":{"hex":"#98A1A2","rol":"Belge satırı, pencere rozeti","kontrast_zemin":6.84},"vurgu":{"hex":"#6FC3A4","rol":"Finans — kapaktaki karşılığı","kontrast_zemin":8.61}},"serit":{"_amac":"Ana sayfa bandındaki kurum kartı sayfanın içinde yaşıyor; krem zemin üstünde çiziliyor.","murekkep":{"hex":"#15191A"},"vurguKoyu":{"hex":"#1D5B4A","rol":"Kağıt vurgusunun krem zemindeki karşılığı"},"ikincilKoyu":{"hex":"#575F61"}},"renk_korlugu_notu":"Vurgu (#1D5B4A, kağıtta 6,36) ile ikincil (#575F61, 5,23) arasındaki fark hem tonda hem parlaklıkta. Sıralama grafiğinde tek seri var; vurgu yalnızca EN BÜYÜK satırı işaretliyor ve o satır zaten en uzun çubuk — renk ikinci işaret, tek işaret değil."},"motif":{"ad":"Cetvel çizgisi","tanim":"Defter ve resmî evrak kağıdının marj rayı: solda dikey ray, aralarda ince yatay kural çizgileri.","gerekce":"Polder Hollanda’nın geometrisiydi; kurumun geometrisi kağıdın kendisidir. Doğrusal olduğu için düşük opaklıkta metni bozmuyor — ama polderden farklı olarak İŞ YAPIYOR: bölüm numarası ve kayıt bloklarının girintisi bu raya hizalanıyor.","uygulama":{"opaklik":"%8","renk":"cizgiVurgu #767E7C üzerine opaklık","bicim":"Vektör (CustomPainter) — telif yok, ölçeklenir, dosya boyutu sıfır","yerlesim":"Bölüm ayırıcılarında ve kapak altı geçiş bandında. Gövde metninin ARKASINDA kullanılmaz.","aralik_notu":"Izgara aralığı 24 px’in altına inmeyecek."}},"kapak":{"yon":"Kuruluş belgesinden kurulan tipografik kapak","gerekce":"Kurum fotoğrafı ve logosu lisanslı değil. Kapak kuruluş belgesinden kuruluyor; tipografik kapak ASIL tasarım, yedek değil (§8.4). Dizinin ikinci sayısında kapak dili kırılmadı — bir kimlik ancak tekrarla kurulur.","sinir":"Kapak bir belgeyi ALINTILAR, TAKLİT ETMEZ. Resmî Gazete anteti, mühür, arma veya kurum logosu yeniden üretilmez. Kapakta her zaman seri etiketi ve sayı numarası bulunur; ekran görüntüsü bağlamından koparıldığında bile gerçek bir resmî belge sanılamaz.","tipografi_katmani":{"ust_satir":"KURUM DOSYASI · 02 · FİNANS","baslik":"ZİRAAT BANKASI","belge_satiri":"Memleket Sandıkları · 1863 — 4603 sayılı Kanun · 2000","alt_satir":"tez_cumlesi.tr","veri_rozeti":"373 ilçe ve beldede tek banka"},"gorsel":"Yok ve aranmıyor. Sayfa tipografik kapakla tam çalışıyor.","_belge_satiri_notu":"İki tarih birden yazılıyor çünkü kurumun hukuki kimliği tek bir belgeye dayanmıyor: 1863'te sandık, 2000'de bugünkü anonim şirket. Aradaki zincirin tamamı bankanın kendi tarihçesinde yazılı değil ve uydurulmuyor."},"_yasak":["Kurum logosu, resmî arma, mühür veya antet taklidi","Resmî Gazete sayfasının tıpkıbasım görünümü","Stok \"mutlu çiftçi\" fotoğrafı","Kurumu simgeleyen dekoratif ikon seti"]}$dsr$::jsonb,
  $dsr${"_dosya":"Ziraat Bankası — Kurum Dosyası · veri katmanı","_uretim":"build_data.py ile üretildi; elle düzenlenmez.","_kural":"Buradaki hiçbir rakam bellekten yazılmadı. Elle girilen her kalem ham metindeki alıntısıyla birlikte taşınıyor ve alıntı bulunamazsa üretim duruyor. Kaynağı olmayan kalem bu dosyaya girmez.","olcu":{"_amac":"Dosyanın omurgası. İddia değil, iki birincil kaynağın oranı.","cumle":"Türkiye'de tarıma açılan kredinin yaklaşık üçte ikisi tek bir bankadan geçiyor.","dayanak":"Pay bankanın kendi faaliyet raporundan, payda BDDK'nın sektör toplamından. Oran yuvarlanarak veriliyor: iki kaynağın tanımları birebir örtüşmeyebilir."},"kunye":{"ad":"Türkiye Cumhuriyeti Ziraat Bankası A.Ş.","kisa_ad":"Ziraat Bankası","kurulus":{"yil":1863,"yer":"Pirot","kuran":"Mithat Paşa","ilk_bicim":"Memleket Sandıkları","tarih":"20 Kasım","kaynak":"site_tarihce.html → tarihce.json · 1863"},"yas":{"deger":162,"kaynak":"faaliyet_2025.pdf · s. 58","alinti":"162 yıldır"},"bugunku_bicim":{"deger":"Anonim şirket","dayanak":"4603 sayılı Kanun (kabul 25 Kasım 2000)","kaynak":"site_tarihce.html → tarihce.json · 2000","_not":"Banka 1924'te de anonim şirket yapılmıştı (444 sayılı Bütçe Kanunu). Aradaki dönüşüm zinciri bankanın tarihçesinde yazılı değil; metin o geçişi ATLAR."}},"tarih_zinciri":{"_amac":"Seçilmiş kilometre taşları. Cümleler bankanın kendi metni, kısaltılmadan taşınıyor.","_kaynak":"site_tarihce.html → tarihce.json (51 yıl, 221 madde)","yillar":[{"yil":1863,"maddeler":["Mithat Paşa tarafından Pirot kasabasında bugünkü Ziraat Bankası'nın temelini oluşturan Memleket Sandıkları kuruldu (20 Kasım).","3-12 ay vadeli ve kişi başına azami 20 liralık ilk tarımsal kredi uygulaması başladı."]},{"yil":1867,"maddeler":["Memleket Sandıkları Nizamnamesi yürürlüğe girdi.","Ülkemizde ilk kez teşkilatlı kredi sistemi mevzuatı oluştu."]},{"yil":1881,"maddeler":["Edirne vilayetinde bir Ziraat Bankası kurulması için iki yabancıya hükümetçe izin verildi ancak sonuç başarısız oldu.","Banka yabancı ortak konusunda ilk girişimde bulundu."]},{"yil":1883,"maddeler":["Menafi Sandıkları, Memleket Sandıkları'nın yerini aldı.","Aşar vergisine ''Menafi Hissesi'' zammı yapılarak sandıklara daimi ve istikrarlı bir mali kaynak yaratıldı.","Sandıklar güçlü ve sürekli bir yapıya kavuşturuldu."]},{"yil":1888,"maddeler":["Ziraat Bankası Nizamnamesi yürürlüğe girdi (28 Ağustos).","Ziraat Bankası Umum Müdürlüğü faaliyete geçti (17 Eylül).","Mikail PORTAKALYAN Banka Umum Müdürlüğü görevine getirildi.","İlk defa faiz karşılığı mevduat kabul edildi.","Nominal sermayesi 10 milyon TL olan Ziraat Bankası hükümetin himayesinde ve Ticaret ve Nafia Nezareti'nin kontrolü altında bir devlet müessesesi oldu."]},{"yil":1892,"maddeler":["Bankanın teftiş hizmetlerini kendi müfettişleri görmeye başladı.","Hazineye ilk kredi verildi.","Banka faaliyetleri daha etkin bir şekilde denetlenmeye başlandı."]},{"yil":1916,"maddeler":["Ziraat Bankası Kanunu çıkarıldı (23 Mart).","Emil Kautz, Genel Müdürlük görevine getirildi.","Tarımsal işletmelere kredi, tahvil ve kefalet karşılığı avans kullandırılmaya başlandı.","İlk devlet tahvili satışı yapıldı.","Bugünkü Mevduat Sertifikası benzeri \"Tevdiatı Nakdiye Senetleri\" çıkarıldı.","Zirai alacaklarda ilk toplu erteleme yapıldı.","İlk tohumluk kredisi verildi."]},{"yil":1919,"maddeler":["İzmir'i işgal eden Yunanlılar burada ayrı bir Ziraat Bankası İdare Merkezi oluşturarak, işgalleri altına giren şube ve sandıkları bu merkeze bağladılar.","Kurtuluş Savaşı sırasında oluşturulan Kuvâ-yi Milliye müfrezelerinin giderlerinin karşılanabilmesi için Ziraat Bankası sandıklarından para alınıp askerlere teçhizat sağlandı.","İşgal, Banka bünyesini olumsuz şekilde etkiledi."]},{"yil":1920,"maddeler":["Ankara'da TBMM'nin açılmasıyla birlikte, TBMM'nin nüfuzu altındaki topraklarda bulunan şube ve sandıkların idaresi görevi; Ziraat Bankası Ankara Şubesi'ne verildi (23 Nisan).","Böylece Ziraat Bankası Milli Mücadele'de yerini aldı.","23 Haziran 1920'de Ahmet Kemal ILGAZ, Genel Müdürlük görevine getirildi.","06 Aralık 1920'de Hüseyin Avni ŞUŞUD, Genel Müdürlük görevine getirildi."]},{"yil":1922,"maddeler":["İzmir teşkilatı Ankara'ya tabi oldu (9 Eylül). İstanbul teşkilatı Ankara'ya tabi oldu.","Milli Mücadele'nin kazanılması ile Banka tekrar bütünlüğüne kavuştu (23 Ekim)."]},{"yil":1924,"maddeler":["Ziraat Bankası'nı, kaynaklarını günlük ihtiyaçlara harcayan hükümetlerin siyasi etkisinden kurtarmak, gerçek sahipleri olan çiftçilerin eline ve yönetimine teslim etmek ve tarımsal kredilerle sınırlanmış olan faaliyetlerini genişletmek amacıyla; TBMM'de 444 sayılı Bütçe Kanunu kabul edildi (19 Mart).","Banka organları Umumi Heyet, Umumi Heyet Müfettişleri, İdare Meclisi ve Umum Müdürlük biçiminde oluşturuldu.","Prof. Leon MORF, Genel Müdürlük görevine getirildi.","Bütçe Kanunu ile Ziraat Bankası bir devlet müessesesi olmaktan çıkarıldı ve Anonim Şirket hâline geldi."]},{"yil":1938,"maddeler":["Umumi Heyet'in yetkilerini genişletmek üzere \"Sermayesinin Tamamı Devlet Tarafından Verilmek Suretiyle Kurulan İktisadi Teşekküllerin Teşkilatıyla İdare ve Murakebeleri Hakkında Kanun\" kabul edildi.","3202 sayılı Kanun'da yer alan Murakıplar Heyeti 3460 sayılı Kanun'la kaldırılarak, bu görev Başbakanlığa bağlı olarak kurulan Umumi Murakebe Heyeti'ne verildi.","Nusret M. MERAY, Genel Müdürlük görevine getirildi.","Banka, bugünkü adıyla Yüksek Denetleme Kurulu tarafından denetlenmeye başlandı."]},{"yil":1945,"maddeler":["3202 sayılı Kanun'da hazırlanacağı belirtilen ve 198 maddeden oluşan Türkiye Cumhuriyeti Ziraat Bankası (TCZB) Tüzüğü tamamlanarak yürürlüğe girdi.","TCZB Tüzüğü, Genel Müdürlük birimlerinde büyük çapta bir yeniden yapılanmayı gündeme getirdi."]},{"yil":1964,"maddeler":["\"Kamu İktisadi Teşebbüslerinin Türkiye Büyük Millet Meclisi'nce Denetlenmesinin Düzenlenmesi Hakkındaki Kanun\" ile \"Umumi Heyet\", TBMM Genel Kurulu ve onun adına hareket eden \"Kamu İktisadi Teşebbüsleri Karma Komisyonu\" oluştu.","Umumi Murakebe Heyeti'nin görevini Başbakanlık Yüksek Denetleme Kurulu üstlendi."]},{"yil":1977,"maddeler":["Alınan yeni bir Yönetim Kurulu kararıyla, \"Yurt düzeyinde yaygın Ziraat Bankası teşkilatının verimli ve etkili bir yönetime kavuşması için gereken tedbirleri almak, faaliyetlerini yakından izlemek ve Genel Müdürlük'te oluşan kararların şubelerce tam ve doğru olarak uygulanmasını sağlamak amacıyla\" Ege (İzmir), Marmara (İstanbul), İç Anadolu (Ankara), Doğu Anadolu (Erzurum) ve Güneydoğu Anadolu (Diyarbakır) Bölge Müdürlükleri kuruldu.","Artan şube sayısının bir gereği olarak merkezi yönetimden, yerinden yönetime geçilmeye başlandı."]},{"yil":2000,"maddeler":["25 Kasım 2000 tarihinde kabul edilen 4603 sayılı kanunla T.C. Ziraat Bankası, Anonim Şirket hâline getirildi."]},{"yil":2001,"maddeler":["Kamu bankalarının yeniden yapılandırılmaları kapsamında, Ziraat Bankası 2001 yılından başlayarak büyük bir değişim içine girdi.","Şubat 2001 Krizi'nin ardından kamu bankaları, Vural Akışık başkanlığında ortak bir yönetim kurulu tarafından yönetilmeye başlandı.","Ziraat Bankası Genel Müdürlüğü'ne Dr. Niyazi Erdoğan atandı.","Bankanın organizasyon yapısı, çağdaş bankacılığın ve uluslararası rekabetin gereklerine göre tamamen değiştirildi.","Operasyon ağırlıklı bankacılık anlayışına, pazarlama nosyonu eklendi.","Emlak Bankası, Ziraat Bankası ile birleştirilerek kapatıldı.","37 adet merkez şube seçilerek, merkezi yönetimin bazı yetkileri bu şubelere devredildi.","Banka çalışanları özel hukuk hükümlerine göre çalıştırılmaya başlandı."]},{"yil":2025,"maddeler":["​Ziraat Leasing faaliyetlerine başladı.","Türkiye'nin en büyük bankası konumundaki Ziraat Bankası'nın aktif büyüklüğü 8 trilyon TL'yi aştı.","Efelerimiz, Türk voleybol tarihine altın harflerle yazılacak büyük bir başarıya imza attı. Takımımız, 2024-2025 sezonunda CEV Kupası'nı kazanarak Avrupa Şampiyonu oldu.","Bankamız, finans sektörünün en büyük yenilenebilir enerji santrali ile öz tüketim GES projesini hayata geçirdi.","Sardis Awards; Finans ekosisteminde hayata geçirilen inovasyon ve pazarlama alanında; Bankamız, Cumhuriyet filmi ile \"En İyi Kurumsal İmaj Filmi\" kategorisinde altın ödül,","İş Bankası'nın 100. Yılını Sosyal Medyada Kutlama Mesajı ile \"En İyi Sosyal Medya Kampanyası\" kategorisinde altın ödül,","\"En Özgün İçerik Üretimi\" kategorisinde gümüş ödüllerine layık görüldü.","Bankamız, 2024 yılında faaliyete başlayan Birleşik Arap Emirlikleri ve Mısır'daki hizmet noktalarından sonra Cezayir Şubesi ile dünya genelinde hizmet sunduğu ülke sayısını 20'ye çıkardı.","Global Finance; World's Best SME Banks 2025 Awards'ta (Dünyanın En İyi KOBİ Bankası Ödülleri'nde) birincilik ödülünü kazandı.","Bankamız Su Güvenliği kategorisinde A puan alarak CDP'nin en üst seviyedeki A Listesi'ne girmeye hak kazandı, İklim Değişikliği kategorisinde ise B puan alarak kayda değer bir başarı elde etti.","Bankamızın Azerbaycan'daki 10. şubesi olan Nahçıvan Şubesi ile 11. şubesi olan Neftçiler Şubesi'nin açılışı gerçekleştirildi.","\"Ziraat Bankası 4. Tarım Ekosistemi Buluşması\" gerçekleştirildi.","162. Kuruluş Yıl Dönümümüz gurur ve coşkuyla kutlandı.","Bankamız; Türkiye Varlık Fonu tarafından düzenlenen 2025 Yılı Raporlama Dönemi toplantısında \"Hızlı ve Doğru Raporlama\" alanında plaket ile ödüllendirildi.","​Türk iş dünyasındaki kurumların, pazarlama süreçlerindeki faaliyetlerini değerlendiren İstanbul Marketing Awards ödüllerinde, Bankamız \"Orkestra\" isimli tarım filmiyle Marka İletişiminde En İyi Ses Kullanımı ödülünün sahibi oldu."]}]},"sektor_payi":{"_amac":"Dosyanın ölçüsü. Enflasyondan etkilenmiyor — oran.","birim":"milyar TL · yıl sonu bakiyesi","seri":[{"yil":2021,"ziraat_milyar_tl":109,"turkiye_milyar_tl":166.2,"ziraat_payi_yuzde":66,"turkiye_milyar_tl_yuvarlak":166,"kaynak_pay":"faaliyet_2021.pdf · s. 15","kaynak_payda":"BDDK Aylık Bülten · Sektörel Kredi Dağılımı · 2021/12 · Tarım satırı, toplam nakdi krediler"},{"yil":2023,"ziraat_milyar_tl":437,"turkiye_milyar_tl":584.1,"ziraat_payi_yuzde":75,"turkiye_milyar_tl_yuvarlak":584,"kaynak_pay":"faaliyet_2023.pdf · s. 80","kaynak_payda":"BDDK Aylık Bülten · Sektörel Kredi Dağılımı · 2023/12 · Tarım satırı, toplam nakdi krediler"},{"yil":2025,"ziraat_milyar_tl":831,"turkiye_milyar_tl":1224.5,"ziraat_payi_yuzde":68,"turkiye_milyar_tl_yuvarlak":1225,"kaynak_pay":"faaliyet_2025.pdf · s. 59","kaynak_payda":"BDDK Aylık Bülten · Sektörel Kredi Dağılımı · 2025/12 · Tarım satırı, toplam nakdi krediler"}]},"tarim_kredisi_2025":{"bakiye_milyar_tl":{"deger":831,"kaynak":"faaliyet_2025.pdf · s. 59","alinti":"tarım kredileri bakiyesi 831 milyar TL’ye ulaşırken"},"kredi_kullanan_musteri":{"deger":"684 bin+","kaynak":"faaliyet_2025.pdf · s. 59","alinti":"684 binden fazla müşteriye tarım kredisi kullandırmıştır"},"yeni_musteri":{"deger":"61 bin","kaynak":"faaliyet_2025.pdf · s. 59","alinti":"Bu müşterilerin 61 bini yeni müşteri olup"},"yil_sonu_kredili_musteri":{"deger":"924 bin+","kaynak":"faaliyet_2025.pdf · s. 59","alinti":"kredili müşteri sayısı 924 binin üzerinde gerçekleşmiştir"},"ortalama_kredi_tl":{"tam":899000,"deger":900000,"_hesap":"831 milyar TL ÷ 924 bin müşteri = 899.350 TL; tam alan on bine, gösterilen alan yüz bine yuvarlandı","kaynak":"faaliyet_2025.pdf · s. 59 (iki kalemden türetildi)"},"kirilim":{"_kaynak":"faaliyet_2025.pdf · s. 60 · tablo","_sutunlar":["kredi kullanan müşteri","kullandırılan tutar","yıl sonu bakiyesi","yıl sonu kredili müşteri"],"_alinti_bitkisel":"Bitkisel Üretim Kredileri 433 Bin 257 milyar TL 263 milyar TL 518 Bin","_alinti_hayvansal":"Hayvansal Üretim Kredileri 321 Bin 320 milyar TL 418 milyar TL 401 Bin","bitkisel":{"musteri":"433 bin","kullandirilan":257,"bakiye":263,"kredili_musteri":"518 bin"},"hayvansal":{"musteri":"321 bin","kullandirilan":320,"bakiye":418,"kredili_musteri":"401 bin"},"mekanizasyon":{"musteri":"64 bin","kullandirilan":30,"bakiye":89,"kredili_musteri":"295 bin"},"basincli_sulama":{"musteri":"12 bin","kullandirilan":11,"bakiye":22,"kredili_musteri":"56 bin"},"_not":"Hayvansal bakiye bitkiselden BÜYÜK (418'e karşı 263 milyar TL) ama kredili müşteri sayısı daha AZ (401 bine karşı 518 bin). Sıralama sezgiye aykırı ve doğrudan tablodan."}},"kredili_musteri_serisi":{"_amac":"Enflasyondan etkilenmeyen ikinci ölçü: kaç çiftçinin bankada kredisi var. Seri DÜZ ARTAN DEĞİL — 2023'te tepe yapıp iniyor.","seri":[{"yil":2021,"musteri":"725 bin","kaynak":"faaliyet_2021.pdf · s. 15"},{"yil":2023,"musteri":"1.207 bin","kaynak":"faaliyet_2023.pdf · s. 80"},{"yil":2025,"musteri":"924 bin+","kaynak":"faaliyet_2025.pdf · s. 59"}],"_uyari":"Metinde ARTIŞ diye anlatılmaz. Üç nokta olduğu gibi verilir; düşüşün sebebi hakkında iddia kurulmaz (§8.2)."},"portfoy_bilesimi":{"_amac":"Yatırım/işletme kredisi oranı — enflasyondan etkilenmeyen üçüncü ölçü.","seri":[{"yil":2021,"yatirim_yuzde":36,"isletme_yuzde":64,"kaynak":"faaliyet_2021.pdf · s. 15","alinti":"%36’sı yatırım kredilerinden, %64’ü işletme kredilerinden"},{"yil":2023,"yatirim_yuzde":31,"isletme_yuzde":69,"kaynak":"faaliyet_2023.pdf · s. 80","alinti":"%31’i yatırım kredilerinden, %69’u işletme kredilerinden"}],"_not":"2025 raporu bu oranı vermiyor; seri iki noktada kalıyor ve metinde de öyle söylenir."},"subvansiyon":{"_amac":"10. bölüm. Mekanizma anlatılır, değerlendirilmez.","belge":"Tarım ve Orman Bakanlığı Tebliği · üretim alanına göre faiz indirim oranı","kapsam":{"deger":"589 bin üretici · 565 milyar TL+","kaynak":"faaliyet_2025.pdf · s. 60","alinti":"tarım sektöründe 589 bin üretici ve toplam 565 milyar TL’nin üzerinde sübvansiyonlu kredi sağlamıştır"}},"kucuk_krediler":{"_amac":"11. bölüm. Kredinin insan ölçeğindeki hâli.","aricilik":{"deger":"5.700+ üretici · 890 milyon TL","kaynak":"faaliyet_2025.pdf · s. 62","alinti":"5.700’den fazla üreticiye toplam 890 milyon TL tutarında kredi kullandırılmıştır"},"aricilik_limit":{"deger":"300.000 TL","kaynak":"faaliyet_2025.pdf · s. 62","alinti":"300.000 TL’ye kadar kredi imkânı sağlanmakta"},"balikci":{"deger":"600 üretici · 523 milyon TL","kaynak":"faaliyet_2025.pdf · s. 63","alinti":"600 üreticiye toplam 523 milyon TL tutarında kredi kullandırılmıştır"},"lisansli_depoculuk":{"deger":"8,2 milyar TL","kaynak":"faaliyet_2025.pdf · s. 60","alinti":"lisanslı depoculuk kredilerinin toplam bakiyesi 8,2 milyar TL"},"yenilenebilir_enerji":{"deger":"987 milyon TL","kaynak":"faaliyet_2025.pdf · s. 63","alinti":"Tarımsal Yenilenebilir Enerji Yatırımları Kredisinden, toplam 987 milyon TL"},"kooperatif_katma_deger":{"deger":"40 kooperatif/üretici · 445 milyon TL","kaynak":"faaliyet_2025.pdf · s. 63","alinti":"40 kooperatif/üreticiye toplam 445 milyon TL finansman sağlanmıştır"},"soguk_hava_deposu":{"deger":"507 milyon TL","kaynak":"faaliyet_2025.pdf · s. 60","alinti":"yeni soğuk hava deposu yatırımları ve mevcut depoların modernizasyonuna yönelik finansman desteği sağlanmıştır. Bu kapsamda kullandırılan kredilerin toplam bakiyesi 2025 yılı itibarıyla 507 milyon TL"},"hayvancilik_projeleri":{"deger":"Köyümde Yaşamak İçin Bir Sürü Nedenim Var · Kırsalda Bereket","kaynak":"faaliyet_2025.pdf · s. 60","alinti":"“Köyümde Yaşamak İçin Bir Sürü Nedenim Var” projeleri kapsamında kredi kullandırımları sürdürülmüş; kırmızı et arzında sürdürülebilirliğin sağlanmasına yönelik “Kırsalda Bereket- Hayvancılığa Destek Projesi” 2025 yılında uygulamaya alınmıştır"},"elus":{"deger":"474 milyon TL","kaynak":"faaliyet_2025.pdf · s. 60","alinti":"Elektronik Ürün Senetleri (ELÜS) karşılığı kullandırılan kredilerin bakiyesi ise 474 milyon TL"}},"banka_geneli_2025":{"_amac":"Ölçek göstermek için, argüman kurmak için değil (§8.2).","aktif":{"deger":"8.474 milyar TL","kaynak":"faaliyet_2025.pdf · s. 37","alinti":"Aktif büyüklüğü: 8.474 milyar TL"},"aktif_pazar_payi":{"deger":"%18,1","kaynak":"faaliyet_2025.pdf · s. 37","alinti":"%18,1 aktif büyüklük pazar payı"},"mevduat":{"deger":"5.405 milyar TL","kaynak":"faaliyet_2025.pdf · s. 37","alinti":"Mevduat büyüklüğü: 5.405 milyar TL"},"nakdi_krediler":{"deger":"4.240 milyar TL","kaynak":"faaliyet_2025.pdf · s. 37","alinti":"Nakdi krediler: 4.240 milyar TL"},"net_kar":{"deger":"161 milyar TL","kaynak":"faaliyet_2025.pdf · s. 37","alinti":"Net dönem kârı: 161 milyar TL"}},"sube_agi_2025":{"_amac":"Kırsalda erişimin ölçüsü. Kredinin büyüklüğünden çok, kredinin NEREYE ulaştığını anlatan rakam.","sube":{"deger":"1.745 şube · 373 ilçe ve beldede tek banka","kaynak":"faaliyet_2025.pdf · s. 38","alinti":"1.745 hizmet noktası ve Türkiye’de 373 ilçe ve beldede tek banka olarak"},"yeni_sube":{"deger":"7 yeni şube","kaynak":"faaliyet_2025.pdf · s. 160","alinti":"yurt içinde 7 yeni şubeyi müşteriyle buluşturarak 2025 yıl sonu itibarıyla 1.745 şubesiyle"}},"tarim_sigortasi":{"_amac":"Kredinin yanındaki ikinci ürün. TARSİM devlet destekli tarım sigortası havuzu.","portfoy_payi":{"deger":"%46","kaynak":"faaliyet_2025.pdf · s. 65","alinti":"tarımsal sigortaların payı %46"}},"credit_agricole":{"_amac":"12. bölüm. Karşılaştırmanın ekseni BÜYÜKLÜK DEĞİL SAHİPLİK.","_kaynak":"site_creditagricole_tarih.html, site_creditagricole_profil.html","ilk_kasa":{"yil":1885,"yer":"Salins-les-Bains (Jura)","kuran":"Louis Milcent, Alfred Bouvet"},"kurulus_kanunu":{"tarih":"5 Kasım 1894","ilke":"karşılıklılık (mutualité)","arkasindaki_isim":"Jules Méline"},"oy_ilkesi":"kişi başına tek oy, hisse sayısından bağımsız","devlet_destegi":"1897 · Banque de France'tan 40 milyon altın frank bağış ve yılda 2 milyon frank","bugun":{"perakende_musteri":"55 milyon","ortak":"12,3 milyon","calisan":"160 bin"},"sayilar":{"orgutlenme_kanunu_yili":1884,"ilk_kasa_yili":1885,"kurulus_kanunu_yili":1894,"bolge_bankalari_yili":1899,"ortak_milyon":12.3,"perakende_musteri_milyon":55},"_eksen":"İkisi de devlet parasıyla ayağa kalktı — biri aşar vergisine zamla (1883), öteki Banque de France bağışıyla (1897). Ayrım oyların kimde olduğunda.","_zaman_farki":"Ziraat'in sandıkları (1863) Fransa'nın ilk yerel kasasından (1885) 22 yıl önce."},"tmo_baglantisi":{"_amac":"Sayı 01'e köprü. KAYNAK ZİRAAT'TE DEĞİL, TMO DOSYASINDA.","_uyari":"Ziraat'in kendi tarihçesi bu olaydan hiç söz etmiyor. Atıf TMO belgesine yapılır, Ziraat'e değil.","fiyat_cokusu":{"deger":"1928 sonrası","kaynak":"content/dossiers/tmo/_raw/kurum_hakkinda.pdf","alinti":"özellikle 1928 sonrasında birçok ülkede buğday fiyatları hızla düşmeye başlamıştır"},"gorevlendirme":{"deger":"3/7/1932 tarihli ve 2056 sayılı Kanun","kaynak":"content/dossiers/tmo/_raw/kurum_hakkinda.pdf","alinti":"10/7/1932 tarihli ve 2146 sayılı Resmî Gazete’de yayımlanan 3/7/1932 tarihli ve 2056 sayılı Kanunla Ziraat Bankasını buğday alımıyla görevlendirmiştir"},"depo_gorevi":{"deger":"11/6/1933 tarihli ve 2303 sayılı Kanun","kaynak":"content/dossiers/tmo/_raw/kurum_hakkinda.pdf","alinti":"Ziraat Bankasına depo ihtiyacını karşılamak üzere 11/6/1933 tarihli ve 2303 sayılı Kanunla hububat muhafaza tesisleri kurma görevi de verilmiştir"},"alim_merkezleri":{"deger":"1932–1933 · çoğu Orta Anadolu'da","kaynak":"content/dossiers/tmo/_raw/kurum_hakkinda.pdf","alinti":"Ziraat Bankası 1932 -1933 yıllarında çoğu Orta Anadolu'da olmak üzere alım merkezleri açmıştır"},"ayrilma":{"deger":"Buğday Masası Şefliği","kaynak":"content/dossiers/tmo/_raw/kurum_hakkinda.pdf","alinti":"Ziraat Bankası bünyesinde Buğday Masası Şefliği adı altında yürütülen işlerin başka bir kuruluşa devredilmesini zorunlu kılmıştır"}},"kredi_sartlari":{"_amac":"9. bölüm. Kredinin ŞARTLARI — limit, vade, ödemesiz dönem. Başvuru sürecinin adımları hiçbir çekilen kaynakta yok; akış şeması UYDURULMADI, onun yerine belgelenmiş şartlar veriliyor.","faiz_dayanagi":{"deger":"Tarım ve Orman Bakanlığı Tebliği","kaynak":"faaliyet_2025.pdf · s. 59","alinti":"Tarım ve Orman Bakanlığı Tebliğ’i çerçevesinde, üretim alanlarına göre belirlenen faiz indirim oranları doğrultusunda"},"ciftci_destek_limiti":{"deger":"1.000.000 TL","kaynak":"faaliyet_2025.pdf · s. 62","alinti":"1.000.000 TL’ye kadar kredi imkânı sunulmaktadır"},"ciftci_destek_kullanim":{"deger":"38 bin müşteri · 18 milyar TL","kaynak":"faaliyet_2025.pdf · s. 62","alinti":"38 bin müşteriye 18 milyar TL kredi kullandırılmıştır"},"uretici_orgutu_limiti":{"deger":"1.200.000 TL","kaynak":"faaliyet_2025.pdf · s. 61","alinti":"600.000 TL’den 1.200.000 TL’ye yükseltilmiş"},"uretici_orgutu_vade":{"deger":"2 yıl ödemesiz · 5–7 yıl vade","kaynak":"faaliyet_2025.pdf · s. 61","alinti":"2 yıla kadar ödemesiz, toplamda 5 veya 7 yıl vadeli"},"tarimsal_elektrik":{"deger":"4 bin+ müşteri · 2,9 milyar TL","kaynak":"faaliyet_2025.pdf · s. 63","alinti":"4 bini aşkın müşteriye toplam 2,9 milyar TL"}},"bosluklar":[]}$dsr$::jsonb,
  $dsr${"sektor_payi":{"tur":"kunye","baslik":{"tr":"Türkiye'de tarıma açılan kredinin ne kadarı Ziraat'ten","en":"How much of Türkiye's agricultural credit comes from Ziraat"},"not":{"tr":"Pay bankanın kendi faaliyet raporundan, payda BDDK'nın sektör toplamından. İki kaynağın tanımları birebir örtüşmeyebilir; oran yuvarlanarak veriliyor.","en":"The numerator is from the bank's own annual report, the denominator from the banking regulator's sector total. The two definitions may not match exactly; the ratio is rounded."},"kaynak":"Ziraat Bankası Entegre Faaliyet Raporları · BDDK Aylık Bülten","kalemler":[{"deger":66,"ondalik":0,"onek":{"tr":"%","en":""},"sonek":{"tr":"","en":"%"},"etiket":{"tr":"2021","en":"2021"},"alt":{"tr":"109 / 166 milyar TL","en":"TRY 109bn of 166bn"}},{"deger":75,"ondalik":0,"onek":{"tr":"%","en":""},"sonek":{"tr":"","en":"%"},"etiket":{"tr":"2023","en":"2023"},"alt":{"tr":"437 / 584 milyar TL","en":"TRY 437bn of 584bn"}},{"deger":68,"ondalik":0,"onek":{"tr":"%","en":""},"sonek":{"tr":"","en":"%"},"etiket":{"tr":"2025","en":"2025"},"alt":{"tr":"831 / 1.225 milyar TL","en":"TRY 831bn of 1,225bn"}}]},"hukuki_omurga":{"tur":"zaman_cizelgesi","baslik":{"tr":"Sandıktan anonim şirkete","en":"From a village fund to a joint-stock company"},"not":{"tr":"1924 ile 2000 arasındaki dönüşüm zinciri bankanın kendi tarihçesinde yazılı değil; çizelge o aralığı boş bırakıyor.","en":"The chain of transformations between 1924 and 2000 is not set out in the bank's own history; the timeline leaves that gap open."},"kaynak":"Ziraat Bankası · Bankamız Tarihçesi","olaylar":[{"yil":1863,"baslik":{"tr":"Memleket Sandıkları","en":"The Country Funds"},"aciklama":{"tr":"Mithat Paşa, Pirot kasabasında kurdu. İlk kredi: 3–12 ay vade, kişi başına azami 20 lira.","en":"Founded by Mithat Pasha in the town of Pirot. The first loan: 3–12 months, at most 20 lira per person."}},{"yil":1883,"baslik":{"tr":"Menafi Sandıkları","en":"The Benefit Funds"},"aciklama":{"tr":"Aşar vergisine \"Menafi Hissesi\" zammı yapıldı; sandıklar sürekli bir gelire kavuştu.","en":"A \"benefit share\" surcharge was added to the tithe, giving the funds a permanent income."}},{"yil":1888,"baslik":{"tr":"Ziraat Bankası","en":"Ziraat Bankası"},"aciklama":{"tr":"Nizamname 28 Ağustos'ta yürürlüğe girdi, Umum Müdürlük 17 Eylül'de açıldı. İlk defa faiz karşılığı mevduat kabul edildi.","en":"The charter took effect on 28 August and the head office opened on 17 September. Interest-bearing deposits were accepted for the first time."}},{"yil":1916,"baslik":{"tr":"Ziraat Bankası Kanunu","en":"The Ziraat Bankası Act"},"aciklama":{"tr":"İlk tohumluk kredisi verildi; zirai alacaklarda ilk toplu erteleme yapıldı.","en":"The first seed loan was issued, and farm debts were rescheduled en masse for the first time."}},{"yil":1924,"baslik":{"tr":"444 sayılı Bütçe Kanunu","en":"Budget Act no. 444"},"aciklama":{"tr":"Banka devlet müessesesi olmaktan çıkarılıp anonim şirket hâline getirildi.","en":"The bank ceased to be a state institution and was turned into a joint-stock company."}},{"yil":2000,"baslik":{"tr":"4603 sayılı Kanun","en":"Act no. 4603"},"aciklama":{"tr":"25 Kasım'da kabul edildi; banka yeniden anonim şirket hâline getirildi.","en":"Passed on 25 November; the bank was made a joint-stock company once again."}}]},"kredi_kirilimi":{"tur":"siralama","baslik":{"tr":"Tarım kredisi bakiyesi neye gidiyor","en":"Where the agricultural loan book sits"},"not":{"tr":"Hayvansal üretimin bakiyesi bitkiselden büyük, ama kredili müşterisi daha az: 401 bine karşı 518 bin. Basınçlı sulama bitkiselin içinde de sayılıyor.","en":"Livestock carries a larger balance than crops, yet fewer borrowers: 401,000 against 518,000. Pressurised irrigation is also counted within crops."},"kaynak":"Ziraat Bankası · 2025 Entegre Faaliyet Raporu, s. 60","birim":{"tr":"milyar TL · 2025 yıl sonu bakiyesi","en":"TRY bn · year-end 2025 balance"},"ondalik":0,"satirlar":[{"etiket":{"tr":"Hayvansal üretim","en":"Livestock production"},"deger":418,"rol":"vurgu"},{"etiket":{"tr":"Bitkisel üretim","en":"Crop production"},"deger":263},{"etiket":{"tr":"Tarımsal mekanizasyon","en":"Farm machinery"},"deger":89},{"etiket":{"tr":"Basınçlı sulama","en":"Pressurised irrigation"},"deger":22}]},"kredinin_sartlari":{"tur":"kartlar","baslik":{"tr":"Kredinin şartları","en":"The terms of the loan"},"not":{"tr":"Başvurunun adım adım yolu bankanın yayımladığı belgelerde yok; burada yalnızca ilan edilmiş şartlar var.","en":"The step-by-step application path is not set out in the bank's published documents; only the announced terms appear here."},"kaynak":"Ziraat Bankası · 2025 Entegre Faaliyet Raporu, s. 59–63","kartlar":[{"ust":{"tr":"FAİZ","en":"INTEREST"},"baslik":{"tr":"Oranı banka tek başına belirlemiyor","en":"The rate is not the bank's alone to set"},"govde":{"tr":"Faiz destekli kredide indirim oranları Tarım ve Orman Bakanlığı Tebliği ile, üretim alanına göre belirleniyor.","en":"For subsidised loans the discount rates are set by a Ministry of Agriculture and Forestry communiqué, according to the line of production."},"rakam":{"deger":68,"ondalik":0,"onek":{"tr":"%","en":""},"sonek":{"tr":"","en":"%"},"etiket":{"tr":"Ziraat'in tarım kredisindeki payı, 2025","en":"Ziraat's share of agricultural credit, 2025"}}},{"ust":{"tr":"ÇİFTÇİ DESTEK KREDİSİ","en":"FARMER SUPPORT LOAN"},"baslik":{"tr":"Bir milyon liraya kadar","en":"Up to one million lira"},"govde":{"tr":"Üretime dair ya da üretim dışı, kısa, orta ve uzun vadeli ihtiyaçlar için. 2025'te 38 bin müşteri kullandı.","en":"For production and non-production needs alike, at short, medium and long term. 38,000 customers used it in 2025."}},{"ust":{"tr":"ÜRETİCİ ÖRGÜTÜ KREDİSİ","en":"PRODUCER ORGANISATION LOAN"},"baslik":{"tr":"İki yıl ödemesiz","en":"Two years before the first payment"},"govde":{"tr":"Limit 2025'te 600 bin liradan 1,2 milyon liraya çıkarıldı. Geri ödeme 2 yıla kadar ödemesiz, toplam vade 5 ya da 7 yıl.","en":"The ceiling was raised from 600,000 to 1.2 million lira in 2025. Repayment can start after up to two years, over a total term of five or seven."}}]},"iki_banka":{"tur":"kunye","baslik":{"tr":"Aynı sorun, iki cevap: Ziraat ve Crédit Agricole","en":"One problem, two answers: Ziraat and Crédit Agricole"},"not":{"tr":"İkisi de devlet parasıyla ayağa kalktı — biri aşar vergisine zamla, öteki Banque de France'ın bağışıyla. Ayrım oyların kimde olduğunda.","en":"Both were raised on state money — one through a surcharge on the tithe, the other through an endowment from the Banque de France. The difference is who holds the votes."},"kaynak":"Ziraat Bankası · Bankamız Tarihçesi — Crédit Agricole · History of the group","kalemler":[{"deger":1863,"ondalik":0,"etiket":{"tr":"Memleket Sandıkları kuruldu","en":"The Country Funds founded"},"alt":{"tr":"Pirot · Mithat Paşa","en":"Pirot · Mithat Pasha"}},{"deger":1885,"ondalik":0,"etiket":{"tr":"İlk yerel kasa kuruldu","en":"The first local fund founded"},"alt":{"tr":"Salins-les-Bains · Milcent ve Bouvet","en":"Salins-les-Bains · Milcent and Bouvet"}},{"deger":12.3,"ondalik":1,"sonek":{"tr":" milyon","en":"m"},"etiket":{"tr":"Crédit Agricole'un ortağı","en":"Crédit Agricole's members"},"alt":{"tr":"Kişi başına tek oy, hisseden bağımsız","en":"One member, one vote, whatever the holding"}}]}}$dsr$::jsonb,
  array['Ziraat Bankası', 'Ziraat Bank']::text[],
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
  status       = excluded.status,
  -- Pencere KASITLI olarak korunuyor. Yayındaki bir dosyanın metninde yazım
  -- hatası düzeltmek için seed'i yeniden çalıştırmak, 28 günlük sayacı
  -- sıfırlamamalı. Pencereyi bilerek kaydırmak istiyorsanız elle update.
  starts_at    = coalesce(country_dossiers.starts_at,    excluded.starts_at),
  ends_at      = coalesce(country_dossiers.ends_at,      excluded.ends_at),
  published_at = coalesce(country_dossiers.published_at, excluded.published_at),
  updated_at   = now();

delete from public.dossier_sections
 where dossier_id = (select id from public.country_dossiers where slug = 'ziraat-bankasi');

insert into public.dossier_sections
  (dossier_id, ord, title_tr, title_en, body_tr, body_en, chart_keys, tur, gorsel)
select d.id, v.ord, v.title_tr, v.title_en, v.body_tr, v.body_en, v.chart_keys, v.tur, v.gorsel
from public.country_dossiers d
cross join (values
  (1::integer, $dsr$Bir bankanın tarımla ne işi var$dsr$, $dsr$What business does a bank have with farming$dsr$, $dsr$Türkiye'de bir çiftçi tohumu ekmeden önce parayı bulmak zorunda. Gübre peşin, mazot peşin, işçilik peşin; ürünün parası ise en iyi ihtimalle beş ay sonra geliyor. Aradaki boşluğu birinin doldurması gerekiyor.

2025 yılı sonunda Türkiye'deki bankaların tarım sektörüne açtığı toplam kredi 1.225 milyar liraydı. Bunun 831 milyar lirası tek bir bankanın defterindeydi.

Yani tarıma açılan her yüz liralık kredinin yaklaşık altmış sekizi Ziraat Bankası'ndan geliyor. Oran 2021'de yüzde 66, 2023'te yüzde 75'ti. Üç yılın üçünde de aynı büyüklük sırası: Türkiye'de tarımın finansmanı esas olarak tek bir kurumun işi.

Bu kurum aynı zamanda Türkiye'nin en büyük bankası. 2025 sonunda aktif büyüklüğü 8.474 milyar lira, bankacılık sektöründeki payı yüzde 18,1. Mevduatı 5.405 milyar, nakdi kredileri 4.240 milyar lira. Tarım, bu büyük bilançonun içinde tek başına yüzde yirmiye yakın bir yer tutuyor.

Ama tarımsal kredide bu kadar baskın olmasının sebebi yalnızca büyüklük değil. Coğrafya da var. Bankanın 1.745 şubesi var ve bunların bir kısmı başka hiçbir bankanın gitmediği yerlerde: **Türkiye'de 373 ilçe ve beldede tek banka Ziraat Bankası.** Tarımın yapıldığı yerlerle bankacılığın gittiği yerler her zaman örtüşmüyor; örtüşmediği 373 noktada tek adres var.

Ama bankanın hikâyesi bilançosundan çok daha eski. Ziraat Bankası 1863'te, henüz banka bile değilken, bir Tuna kasabasında kurulmuş bir yardımlaşma sandığı olarak başladı. Bu dosya o sandığın nasıl bugünkü kuruma dönüştüğünü, bu dönüşüm sırasında hangi hukuki kimlikleri denediğini ve bugün çiftçiyle tam olarak nerede karşılaştığını anlatıyor.$dsr$, $dsr$Before a farmer in Türkiye can sow, they have to find the money. Fertiliser is paid for up front, so is diesel, so is labour; the crop pays out five months later at best. Somebody has to bridge the gap.

At the end of 2025, the total credit extended to the agricultural sector by all banks in Türkiye stood at 1,225 billion lira. Of that, 831 billion sat on the books of a single bank.

So roughly sixty-eight of every hundred lira lent to farming comes from Ziraat Bankası. The share was 66 per cent in 2021 and 75 per cent in 2023. In all three years the order of magnitude is the same: financing agriculture in Türkiye is, in the main, one institution's business.

That institution is also the country's largest bank. At the end of 2025 its assets came to 8,474 billion lira, giving it an 18.1 per cent share of the banking sector. Deposits stood at 5,405 billion and cash loans at 4,240 billion lira. Agriculture alone accounts for close to a fifth of that balance sheet.

But its dominance in farm credit is not only a matter of size. Geography matters too. The bank has 1,745 branches, and some of them stand where no other bank has gone: **in 373 districts and towns across Türkiye, Ziraat Bankası is the only bank.** The places where farming happens and the places banking reaches do not always overlap; at 373 of those points there is one address.

The bank's story, though, is much older than its balance sheet. Ziraat Bankası began in 1863 — before it was a bank at all — as a mutual-aid fund in a town on the Danube. This dossier traces how that fund became the institution it is today, which legal identities it tried along the way, and where exactly it meets the farmer now.$dsr$, array['sektor_payi']::text[], 'anlati', $dsr${"url":"https://tarim-app-2026.web.app/dosya/ziraat-bankasi/ziraat_konya_subesi.jpg","atif":"Dosseman · CC BY-SA 4.0 · Wikimedia Commons","kaynak":"https://commons.wikimedia.org/wiki/File:Konya_Ziraat_Bankası_3798.jpg","alt_tr":"Konya'da bir Ziraat Bankası binası. Türkiye'de 373 ilçe ve beldede başka banka yok.","alt_en":"A Ziraat Bankası building in Konya. In 373 districts and towns in Türkiye there is no other bank."}$dsr$::jsonb),
  (2, $dsr$Pirot'ta bir sandık$dsr$, $dsr$A fund in Pirot$dsr$, $dsr$1863'ün Kasım ayında, bugün Sırbistan sınırları içinde kalan Pirot kasabasında, Niş valisi Mithat Paşa bir sandık kurdu. Adı Memleket Sandığı'ydı.

Çözmeye çalıştığı sorun basitti ve çok eskiydi: köylü, hasada kadar dayanacak parayı bulamıyordu. Bulduğu yerde de şartlar ağırdı. Sandık fikri, köylünün kendi arasında biriktirdiği ortak bir kaynaktan, makul şartlarla borç almasıydı.

İlk uygulamanın şartları kayıtlı: vade üç ilâ on iki ay, kişi başına azami yirmi lira. Bugünden bakıldığında mütevazı görünen bu iki rakam, Osmanlı topraklarında tarımsal kredinin ilk yazılı kuralıdır.

Fikir tuttu. Dört yıl sonra, 1867'de Memleket Sandıkları Nizamnamesi yürürlüğe girdi ve bankanın kendi ifadesiyle "ülkemizde ilk kez teşkilatlı kredi sistemi mevzuatı" oluştu. Artık sandıklar tek tek valilerin inisiyatifi değil, kurallı bir sistemdi.

Ama bir sorun sürüyordu: sandıkların parası nereden gelecekti?$dsr$, $dsr$In November 1863, in the town of Pirot — today inside Serbia — the governor of Niş, Mithat Pasha, set up a fund. It was called the Country Fund.

The problem it addressed was simple and very old: the peasant could not find money to last until harvest. Where money could be found, the terms were heavy. The idea behind the fund was that the villager would borrow on reasonable terms from a common pool built up among villagers themselves.

The terms of that first scheme are on record: a maturity of three to twelve months, at most twenty lira per person. Modest as those two figures look today, they are the first written rule of agricultural credit in Ottoman lands.

The idea took. Four years later, in 1867, the Regulation on Country Funds came into force and, in the bank's own words, "for the first time in our country a body of legislation for an organised credit system" came into being. The funds were no longer the initiative of individual governors but a system with rules.

One problem remained: where would the funds' money come from?$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarim-app-2026.web.app/dosya/ziraat-bankasi/ziraat_mithat_pasa.jpg","atif":"Nadar · Kamu malı · Wikimedia Commons","kaynak":"https://commons.wikimedia.org/wiki/File:Nadar_-_Portrait_of_Midhat_Pasha.jpg","alt_tr":"Mithat Paşa. 1863'te Niş valisiyken Pirot'ta ilk Memleket Sandığı'nı kurdu.","alt_en":"Mithat Pasha, who as governor of Niş founded the first Country Fund at Pirot in 1863."}$dsr$::jsonb),
  (3, $dsr$Aşarın içinden gelen para$dsr$, $dsr$Money out of the tithe$dsr$, $dsr$Cevap 1883'te geldi ve alışılmış bir cevap değildi.

O yıl Menafi Sandıkları, Memleket Sandıkları'nın yerini aldı. Yeni sandıkların kaynağı için aşar vergisine bir zam yapıldı: **Menafi Hissesi**. Yani çiftçiden alınan öşrün üstüne konan küçük bir pay, doğrudan çiftçiye kredi açacak sandıklara aktarılmaya başlandı.

Bu düzenlemenin mantığı şuydu: sandıklar bağışa ya da yıllık bütçe kararlarına bağlı kalırsa dalgalanır. Vergiye bağlanırsa, tarım üretimi devam ettiği sürece kaynak da devam eder. Bankanın kendi tarihçesi bunu "sandıklara daimi ve istikrarlı bir mali kaynak yaratıldı" diye anlatıyor.

Bu ayrıntı bugün de anlamlı, çünkü kurumun karakterini baştan belirledi. Ziraat Bankası hiçbir zaman ortakların parasını toplayıp işleten bir kuruluş olmadı. Kaynağı en başından itibaren kamusal bir düzenlemeyle sağlandı. İlerideki bölümlerde göreceğimiz üzere, dünyanın başka yerlerinde aynı sorun aynı yıllarda başka türlü çözüldü — ve o fark kurumların bugünkü yapısını hâlâ ayırıyor.$dsr$, $dsr$The answer came in 1883, and it was not a conventional one.

That year the Benefit Funds replaced the Country Funds. To provide the new funds with resources, a surcharge was added to the tithe: the **Benefit Share**. A small levy on top of the tithe collected from farmers was channelled directly to the funds that lent to those same farmers.

The reasoning ran like this: funds dependent on donations or annual budget decisions fluctuate. Tie them to a tax and the money keeps coming as long as farming does. The bank's own history puts it as "a permanent and stable financial resource was created for the funds."

The detail still matters, because it set the institution's character from the start. Ziraat Bankası was never a body that pooled and deployed its members' own money. From the very beginning its resources were secured by a public arrangement. As later sections show, the same problem was solved differently elsewhere in the same years — and that difference still separates the institutions today.$dsr$, '{}'::text[], 'anlati', null),
  (4, $dsr$Sandıktan bankaya$dsr$, $dsr$From fund to bank$dsr$, $dsr$1881'de bir deneme yapıldı: Edirne vilayetinde bir Ziraat Bankası kurulması için hükümet iki yabancıya izin verdi. Girişim sonuçsuz kaldı. Bankanın yabancı sermayeyle ilk teması böyle başladı ve böyle bitti.

1888 ise kurumun adını aldığı yıl.

28 Ağustos'ta Ziraat Bankası Nizamnamesi yürürlüğe girdi. 17 Eylül'de Ziraat Bankası Umum Müdürlüğü faaliyete geçti. İlk umum müdür Mikail Portakalyan oldu.

Aynı yıl banka ilk defa faiz karşılığı mevduat kabul etmeye başladı. Bu, sandıktan bankaya geçişin teknik işareti: artık kurum sadece borç veren değil, borç da alan bir yapıydı. Nominal sermayesi 10 milyon lira olarak belirlendi ve banka, hükümetin himayesinde, Ticaret ve Nafia Nezareti'nin denetiminde bir devlet müessesesi hâline geldi.

Dört yıl sonra, 1892'de, kurumun bugün de tanıdık iki özelliği yerleşti: banka kendi müfettişleriyle kendi teftişini yapmaya başladı, ve Hazineye ilk kredisini verdi. Çiftçiye borç vermek için kurulan sandık, otuz yıl içinde devlete borç verecek büyüklüğe ulaşmıştı.

23 Mart 1916'da çıkarılan Ziraat Bankası Kanunu, bankacılık işlerini belirgin biçimde genişletti. Genel müdürlüğe Emil Kautz getirildi. Tarımsal işletmelere kredinin yanı sıra tahvil ve kefalet karşılığı avans kullandırılmaya başlandı, ilk devlet tahvili satışı yapıldı, bugünkü mevduat sertifikasına benzeyen "Tevdiatı Nakdiye Senetleri" çıkarıldı.

Aynı yılın kayıtlarında iki kalem daha var ve ikisi de tarımsal kredinin kendine has gerçeklerini gösteriyor: **ilk tohumluk kredisi** verildi, ve **zirai alacaklarda ilk toplu erteleme** yapıldı.

Birincisi şunu söylüyor: çiftçiye lazım olan çoğu zaman nakit değil, girdinin kendisidir. İkincisi şunu: hasat tutmadığı yıl borç ertelenmezse geri de dönmez. Bu iki kural yüz yıl sonra hâlâ geçerli; bugünkü ürün kredisi ve yapılandırma uygulamalarının atası burada.$dsr$, $dsr$In 1881 an experiment was tried: the government granted two foreigners permission to establish a Ziraat Bankası in the province of Edirne. Nothing came of it. The bank's first contact with foreign capital began and ended there.

1888 is the year the institution took its name.

On 28 August the Regulation of Ziraat Bankası came into force. On 17 September the bank's head office began operating. Mikail Portakalyan became its first director general.

That same year the bank began accepting interest-bearing deposits for the first time. This is the technical marker of the shift from fund to bank: the institution now not only lent but also borrowed. Its nominal capital was set at 10 million lira, and the bank became a state establishment under the government's protection and the supervision of the Ministry of Trade and Public Works.

Four years later, in 1892, two features that are still familiar took hold: the bank began conducting its own audits with its own inspectors, and it extended its first loan to the Treasury. The fund founded to lend to farmers had, within thirty years, grown large enough to lend to the state.

The Ziraat Bankası Act of 23 March 1916 widened its banking business considerably. Emil Kautz was appointed director general. Alongside loans to farm businesses, the bank began advancing money against bonds and guarantees, sold government bonds for the first time, and issued "cash deposit notes" resembling today's certificates of deposit.

Two more entries from that year point to realities peculiar to agricultural credit: **the first seed loan** was made, and **farm debts were rescheduled en masse for the first time**.

The first says this: what a farmer needs is often not cash but the input itself. The second says this: in a year when the harvest fails, a debt that is not rescheduled is not repaid either. Both rules still hold a century later; today's input loans and restructuring arrangements descend from them.$dsr$, array['hukuki_omurga']::text[], 'belge', $dsr${"url":"https://tarim-app-2026.web.app/dosya/ziraat-bankasi/ziraat_ankara_1930lar.jpg","atif":"Directorate General of Press and Information · Kısıtlama yok · Wikimedia Commons","kaynak":"https://commons.wikimedia.org/wiki/File:Banks_Street_(Atatürk_Boulevard)_the_Building_of_Ziraat_Bankası_(Agricultural_Bank),_1930s_(16851305342).jpg","alt_tr":"1930'larda Ankara'da Ziraat Bankası binası. Bankalar Caddesi adını buradaki binalardan aldı.","alt_en":"The Ziraat Bankası building in 1930s Ankara. Banks Street took its name from the buildings here."}$dsr$::jsonb),
  (5, $dsr$İki merkez: 1919–1922$dsr$, $dsr$Two head offices: 1919–1922$dsr$, $dsr$Kurumların tarihinde savaş yılları genellikle bir duraklama olarak geçiştirilir. Ziraat Bankası'nda geçiştirilemiyor, çünkü banka o yıllarda ikiye bölündü.

1919'da İzmir'i işgal eden kuvvetler şehirde ayrı bir Ziraat Bankası İdare Merkezi kurdular ve işgal altına giren şubelerle sandıkları buraya bağladılar. Aynı dönemde, TBMM'nin 23 Nisan 1920'de Ankara'da açılmasıyla, Meclis'in nüfuz alanındaki şube ve sandıkların idaresi Ziraat Bankası Ankara Şubesi'ne verildi.

Yani 1920–1922 arasında aynı adı taşıyan iki banka teşkilatı vardı: biri İzmir'de, işgal yönetimi altında; öteki Ankara'da, Millî Mücadele'nin yanında. Bankanın kendi kayıtlarına göre Kuvâ-yi Milliye müfrezelerinin giderleri için Ziraat Bankası sandıklarından para alındı ve askerlere teçhizat sağlandı.

Bölünme 1922'de kapandı. 9 Eylül'de İzmir teşkilatı Ankara'ya bağlandı; aynı yıl İstanbul teşkilatı da Ankara'ya tabi oldu ve 23 Ekim'de banka yeniden bütünlüğüne kavuştu.

Ertesi yıl kurum kendini toparlamaya girişti: genel müdürlük iki kez el değiştirdi ve ilk tahsil senedi çıkarıldı. Savaştan çıkan bir kredi kurumunun ilk işi, dağılan alacaklarını toplayacak aracı kurmaktı.

Bu üç yıl, bir kredi kurumunun yalnızca ekonomik bir aygıt olmadığını gösteriyor. Şube ağı, kasa ve tahsilat teşkilatı, bulunduğu toprakta kim hüküm sürüyorsa ona bağlanır.$dsr$, $dsr$In institutional histories the war years are usually passed over as a pause. They cannot be with Ziraat Bankası, because in those years the bank split in two.

In 1919 the forces occupying İzmir set up a separate Ziraat Bankası administrative centre in the city and attached to it the branches and funds that fell under occupation. In the same period, once the Grand National Assembly opened in Ankara on 23 April 1920, administration of the branches and funds within the Assembly's reach was given to the Ankara branch of Ziraat Bankası.

So between 1920 and 1922 two bank organisations bore the same name: one in İzmir under occupation administration, the other in Ankara on the side of the national struggle. By the bank's own records, money was taken from Ziraat Bankası funds to cover the expenses of the national militia units and to equip soldiers.

The split closed in 1922. On 9 September the İzmir organisation was attached to Ankara; the İstanbul organisation followed in the same year, and on 23 October the bank was whole again.

The following year the institution set about putting itself back together: the director generalship changed hands twice, and the first collection note was issued. The first task of a credit institution emerging from war was to build the instrument that would gather in its scattered debts.

These three years show that a credit institution is not purely an economic device. A branch network, its tills and its collection organisation answer to whoever holds the ground beneath them.$dsr$, '{}'::text[], 'anlati', null),
  (6, $dsr$Çiftçinin eline$dsr$, $dsr$Into the farmers' hands$dsr$, $dsr$Cumhuriyet'in ilk yıllarında banka üzerine düşünülen soru şuydu: bu kurum kimin?

Cevap 19 Mart 1924'te TBMM'de kabul edilen 444 sayılı Bütçe Kanunu'yla verildi. Kanunun amacı bankanın kendi tarihçesinde şöyle yazılı: bankayı "kaynaklarını günlük ihtiyaçlara harcayan hükümetlerin siyasi etkisinden kurtarmak, gerçek sahipleri olan çiftçilerin eline ve yönetimine teslim etmek ve tarımsal kredilerle sınırlanmış olan faaliyetlerini genişletmek."

Bu kanunla Ziraat Bankası **devlet müessesesi olmaktan çıkarıldı ve anonim şirket hâline getirildi**. Organları yeniden kuruldu: Umumi Heyet, Umumi Heyet Müfettişleri, İdare Meclisi ve Umum Müdürlük.

Cümlenin içindeki fikir dikkate değer. 1924'te bir devlet bankasının sorunu, devlete fazla yakın olması diye tarif edilmiş; çözüm de kurumu çiftçiye devretmek diye kurgulanmış.

Sonraki on yıllar bu çerçeveyi tekrar tekrar değiştirdi. 1938'de kabul edilen 3460 sayılı Kanunla denetim Başbakanlığa bağlı Umumi Murakebe Heyeti'ne geçti ve banka bugünkü adıyla Yüksek Denetleme Kurulu'nun denetimine girdi. 1945'te, 3202 sayılı Kanunda hazırlanacağı belirtilen 198 maddelik Türkiye Cumhuriyeti Ziraat Bankası Tüzüğü yürürlüğe girdi; tüzük genel müdürlük birimlerinde büyük çaplı bir yeniden yapılanmayı da beraberinde getirdi. 1964'te kamu iktisadi teşebbüslerinin TBMM'ce denetlenmesi düzenlenince Umumi Heyet'in yerini TBMM Genel Kurulu ve onun adına çalışan KİT Karma Komisyonu aldı.

Aynı dönemde banka Türkiye dışına da açıldı. 1975'te Hamburg temsilciliği ve Kıbrıs'ta Lefkoşa, Gazimağusa ve Güzelyurt şubeleri, 1978'de Londra temsilciliği açıldı. Yurt içinde ise 1977'de beş bölge müdürlüğü kuruldu — İzmir, İstanbul, Ankara, Erzurum ve Diyarbakır. Gerekçe şubelerin artmasıydı: merkezden yönetilemeyecek kadar yaygınlaşan bir ağ, yerinden yönetime geçiyordu.

Halka 25 Kasım 2000'de kabul edilen 4603 sayılı Kanun döndü: T.C. Ziraat Bankası yeniden anonim şirket hâline getirildi. Bankanın bugünkü hukuki kimliği bu kanundan geliyor.

Kurumun hukuki kimliği yüz yıl boyunca en az dört kez yeniden yazıldı: devlet müessesesi, anonim şirket, kamu iktisadi teşebbüsü, yeniden anonim şirket. Değişmeyen tek şey, kime kredi açtığıydı.

4603 sayılı Kanunun hemen ardından gelen 2001, kamu bankaları için sert bir yıl oldu. Şubat 2001 krizinin ardından kamu bankaları ortak bir yönetim kuruluyla yönetilmeye başlandı, Ziraat Bankası'nın organizasyon yapısı baştan kuruldu, otuz yedi merkez şube seçilerek merkezî yönetimin bazı yetkileri bu şubelere devredildi ve banka çalışanları özel hukuk hükümlerine göre çalıştırılmaya başlandı. Aynı yıl **Emlak Bankası, Ziraat Bankası ile birleştirilerek kapatıldı.** Krizden sonraki ilk krediler 2002'de verilmeye başlandı.$dsr$, $dsr$In the early years of the Republic the question asked about the bank was: whose is this institution?

The answer came with Budget Act no. 444, passed by the Grand National Assembly on 19 March 1924. The purpose of the act is set out in the bank's own history: to save the bank "from the political influence of governments that spend its resources on daily needs, to hand it over to the hands and the management of its true owners, the farmers, and to broaden its activities, which had been confined to agricultural credit."

Under this act Ziraat Bankası **ceased to be a state establishment and was turned into a joint-stock company**. Its organs were rebuilt: a General Assembly, General Assembly Inspectors, a Board of Administration and a Directorate General.

The idea inside that sentence is worth pausing on. In 1924 the problem with a state bank was defined as its being too close to the state; the remedy was framed as handing the institution to the farmer.

The decades that followed rewrote the framework again and again. Act no. 3460 of 1938 moved supervision to a General Audit Board attached to the prime ministry, and the bank came under the scrutiny of what is today the High Audit Board. In 1945 the 198-article Statute of the Ziraat Bankası of the Republic of Türkiye, foreshadowed in Act no. 3202, came into force and brought a large-scale reorganisation of head-office units with it. When parliamentary supervision of state economic enterprises was regulated in 1964, the General Assembly gave way to the plenary of parliament and the joint committee acting on its behalf.

The bank also opened beyond Türkiye in this period. A Hamburg representative office and branches in Nicosia, Famagusta and Güzelyurt opened in 1975, a London representative office in 1978. At home, five regional directorates were established in 1977 — İzmir, İstanbul, Ankara, Erzurum and Diyarbakır. The reason was the growth in branches: a network too widespread to run from the centre was moving to local management.

Act no. 4603, passed on 25 November 2000, closed the circle: Ziraat Bankası was made a joint-stock company once again. The bank's present legal identity comes from this act.

The institution's legal identity was rewritten at least four times over a century: state establishment, joint-stock company, state economic enterprise, joint-stock company again. The one thing that did not change was who it lent to.

The year after act no. 4603 was a hard one for state banks. Following the February 2001 crisis the state banks came under a joint board, Ziraat Bankası's organisational structure was rebuilt from scratch, thirty-seven central branches were selected and some head-office powers devolved to them, and bank staff began to be employed under private law. In the same year **Emlak Bankası was merged into Ziraat Bankası and closed.** Lending resumed in 2002.$dsr$, '{}'::text[], 'belge', null),
  (7, $dsr$Buğday masası ayrılıyor$dsr$, $dsr$The wheat desk splits off$dsr$, $dsr$1928 sonrasında birçok ülkede buğday fiyatları hızla düşmeye başladı. Türkiye'de hükümet piyasaya bir alıcı sokmaya karar verdi. Bu işi yapacak hazır bir kurum yoktu; olan kurum Ziraat Bankası'ydı.

3 Temmuz 1932 tarihli ve 2056 sayılı Kanunla **buğday alımı görevi Ziraat Bankası'na verildi**. Ertesi yıl, 11 Haziran 1933 tarihli ve 2303 sayılı Kanunla bankaya bir görev daha eklendi: hububat muhafaza tesisleri kurmak. Yani Türkiye'nin ilk devlet silolarını yapma işi de bankanın üstüne kaldı.

Banka 1932–1933 yıllarında, çoğu Orta Anadolu'da olmak üzere alım merkezleri açtı. Bir kredi kurumu, birdenbire buğday satın alan, depolayan ve fiyat belirleyen bir yapıya dönüşmüştü.

Bu iş bankanın içinde **Buğday Masası Şefliği** adıyla yürütüldü. Adın kendisi ölçeği anlatıyor: ülkenin buğday piyasasına müdahalesi, bir bankanın organizasyon şemasında bir şeflikti. Ama buğday üretimi arttıkça ve İkinci Dünya Savaşı'nın belirtileri çoğaldıkça, masanın taşıdığı yük bir bankanın bir biriminin taşıyabileceğini aştı. 1938'de bu işler başka bir kuruluşa devredildi.

Devredildiği kuruluş Toprak Mahsulleri Ofisi'ydi.

Bu dizinin birinci sayısı, işte o masanın hikâyesidir. TMO sıfırdan kurulmadı; altı yıl boyunca Ziraat Bankası'nın içinde bir masada yürüyen işin ayrılmasıyla doğdu. Bugün Türkiye'de tahıl piyasasını düzenleyen kurumla tarımı finanse eden kurum, aynı binada başlamış iki iştir.$dsr$, $dsr$World wheat prices collapsed at the start of the 1930s. As prices fell sharply in many countries after 1928, the government in Türkiye decided to put a buyer into the market. There was no institution ready to do it; the institution that existed was Ziraat Bankası.

Act no. 2056 of 3 July 1932 **assigned the purchase of wheat to Ziraat Bankası**. The following year, act no. 2303 of 11 June 1933 added another duty: building grain storage facilities. The job of constructing Türkiye's first state silos also fell to the bank.

In 1932 and 1933 the bank opened purchasing centres, most of them in Central Anatolia. A credit institution had suddenly become a body that bought, stored and priced wheat.

The work was carried on inside the bank under the name **Wheat Desk Directorate**. The name itself conveys the scale: a country's intervention in its wheat market was one directorate on a bank's organisation chart.

But as wheat production grew and the signs of the Second World War multiplied, the load the desk carried outgrew what a single unit of a bank could bear. In 1938 the work was transferred to another organisation.

That organisation was the Turkish Grain Board.

The first issue in this series tells the story of that desk. TMO was not created from nothing; it was born when work that had run for six years at a desk inside Ziraat Bankası was hived off. The institution that regulates Türkiye's grain market today and the institution that finances its farming began as two jobs in the same building.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarim-app-2026.web.app/dosya/ziraat-bankasi/ziraat_bugday_sivas.jpg","atif":"Maurice Flesier · CC BY-SA 4.0 · Wikimedia Commons","kaynak":"https://commons.wikimedia.org/wiki/File:Wheat_harvest_in_Sivas,_Turkey.jpg","alt_tr":"Sivas'ta buğday hasadı. 1932'de bu ürünü satın alma görevi bankaya verilmişti.","alt_en":"The wheat harvest in Sivas. In 1932 the task of buying this crop was assigned to the bank."}$dsr$::jsonb),
  (8, $dsr$Bugünkü Ziraat$dsr$, $dsr$Ziraat today$dsr$, $dsr$2025 yılı sonunda bankanın tarım kredisi bakiyesi 831 milyar liraydı. Yıl içinde 684 binden fazla müşteri tarım kredisi kullandı; bunların 61 bini bankaya o yıl gelen yeni müşterilerdi. Yıl sonunda kredisi devam eden müşteri sayısı 924 binin üzerindeydi.

Ölçü fikri vermesi için: 831 milyar lirayı 924 bin müşteriye böldüğünüzde kişi başına yaklaşık 900 bin lira düşüyor. Yani ortalama bir Ziraat tarım kredisi, orta boy bir traktörün fiyatı civarında.

Kredinin neye gittiğine bakıldığında beklenmedik bir sıralama çıkıyor:

| Kredi türü | Yıl sonu bakiyesi | Kredili müşteri |
|---|---|---|
| Hayvansal üretim | 418 milyar TL | 401 bin |
| Bitkisel üretim | 263 milyar TL | 518 bin |
| Tarımsal mekanizasyon | 89 milyar TL | 295 bin |
| Basınçlı sulama | 22 milyar TL | 56 bin |

Hayvancılığın bakiyesi bitkisel üretimden büyük, ama kredili müşterisi daha az. Yani hayvancılık kredileri daha az sayıda kişiye, daha büyük tutarlarda veriliyor. Bunun sebebi açık: bir ahır ya da bir sürü, bir mevsimlik gübre ve tohumdan pahalıdır ve daha uzun vadede geri döner.

Kaç çiftçinin bankada kredisi olduğu ise düz bir çizgi izlemiyor. 2021 sonunda kredili müşteri sayısı 725 bindi. 2023 sonunda 1.207 bine çıktı. 2025 sonunda 924 bin oldu.

Portföyün bileşimi de değişti. 2021'de tarım kredilerinin yüzde 36'sı yatırım, yüzde 64'ü işletme kredisiydi. 2023'te bu oran yüzde 31'e karşı yüzde 69 oldu. Yani ağırlık, ahır ve makine gibi kalıcı yatırımlardan, mevsimlik masrafları karşılayan işletme kredilerine doğru kaydı. 2025 raporu bu ayrımı vermiyor; seri iki noktada duruyor.

Kredinin yanında ikinci bir ürün daha var: sigorta. Bankanın hayat dışı sigorta portföyünün yüzde 46'sı TARSİM, yani devlet destekli tarım sigortası. Portföyün neredeyse yarısı dolu ve kırağıya, dolüya, kuraklığa karşı yazılmış poliçelerden oluşuyor. Tarımsal kredi ile tarımsal sigorta çoğu zaman aynı masada konuşuluyor — teminatı hasat olan bir kredide, hasadı sigortalamak alacaklının da işine geliyor.$dsr$, $dsr$At the end of 2025 the bank's agricultural loan balance stood at 831 billion lira. During the year more than 684,000 customers took out an agricultural loan; 61,000 of them were new to the bank that year. At year end more than 924,000 customers had a loan outstanding.

For a sense of scale: divide 831 billion lira among 924,000 customers and you get roughly 900,000 lira each. An average Ziraat agricultural loan is about the price of a mid-sized tractor.

Look at where the credit goes and an unexpected order emerges:

| Type of loan | Year-end balance | Borrowers |
|---|---|---|
| Livestock production | TRY 418bn | 401,000 |
| Crop production | TRY 263bn | 518,000 |
| Farm machinery | TRY 89bn | 295,000 |
| Pressurised irrigation | TRY 22bn | 56,000 |

Livestock carries a larger balance than crop production but has fewer borrowers. Livestock loans go to fewer people in larger amounts. The reason is plain: a barn or a herd costs more than a season's fertiliser and seed, and pays back over a longer horizon.

How many farmers hold a loan does not follow a straight line. At the end of 2021 there were 725,000 borrowers. At the end of 2023 there were 1,207,000. At the end of 2025 there were 924,000.

The composition of the portfolio shifted too. In 2021, 36 per cent of agricultural loans were investment loans and 64 per cent working-capital loans. By 2023 the split was 31 to 69. The weight moved from lasting investments such as barns and machinery towards working capital covering seasonal costs. The 2025 report does not give this breakdown; the series stops at two points.

Alongside credit sits a second product: insurance. Agricultural cover accounts for 46 per cent of the bank's non-life insurance portfolio through the state-backed pool. Almost half the portfolio consists of policies written against frost, hail and drought. Agricultural credit and agricultural insurance are usually discussed at the same desk — where the collateral is a harvest, insuring that harvest suits the lender too.$dsr$, array['kredi_kirilimi']::text[], 'veri', $dsr${"url":"https://tarim-app-2026.web.app/dosya/ziraat-bankasi/ziraat_koyun_egribel.jpg","atif":"Zeynel Cebeci · CC BY-SA 4.0 · Wikimedia Commons","kaynak":"https://commons.wikimedia.org/wiki/File:Sheep_flock_in_Eğribel,_Giresun_01-8.jpg","alt_tr":"Giresun Eğribel'de koyun sürüsü. Hayvancılık kredisinin bakiyesi bitkisel üretimden büyük.","alt_en":"A flock at Eğribel, Giresun. The livestock loan book is larger than the crop loan book."}$dsr$::jsonb),
  (9, $dsr$Kredinin şartları$dsr$, $dsr$The terms of the loan$dsr$, $dsr$Tarımsal kredi, sıradan bir tüketici kredisi gibi işlemiyor. Farkı üç yerde görünüyor: faizin nasıl belirlendiğinde, vadenin nasıl kurulduğunda ve limitin neye göre çizildiğinde.

**Faizi banka tek başına belirlemiyor.** Faiz destekli — yaygın adıyla sübvansiyonlu — tarım kredilerinde indirim oranları Tarım ve Orman Bakanlığı Tebliği ile, üretim alanına göre belirleniyor. Yani arıcılık yapan bir üreticinin faiz indirimi ile sera işletenin faiz indirimi aynı olmak zorunda değil; oran, hangi üretim dalının desteklendiğine göre değişiyor.

Bu mekanizmanın 2025'teki kapsamı şu: banka tarım sektöründe 589 bin üreticiye toplam 565 milyar liranın üzerinde sübvansiyonlu kredi kullandırdı.

**Vade hasada göre kuruluyor.** Tarımsal üretici örgütlerine açılan kredilerde geri ödeme iki yıla kadar ödemesiz bırakılabiliyor, toplam vade beş ya da yedi yıl olabiliyor. Bir meyve bahçesi diktiğinizde ilk hasat üçüncü yılda gelir; ödemesiz dönem tam bu gerçeği karşılamak için var.

**Limitler ürüne göre çiziliyor.** Çiftçi Destek Kredisi'nde üst sınır bir milyon lira; 2025'te bu krediyi 38 bin müşteri kullandı ve toplam 18 milyar lira kullandırıldı. Üretici örgütlerine yönelik projede limit 2025'te 600 bin liradan 1 milyon 200 bin liraya çıkarıldı. Arıcılıkta üst sınır 300 bin lira.

Üçü birlikte tarımsal kredinin şeklini veriyor: faizi bir tebliğ, vadeyi hasat takvimi, limiti de üretim dalı belirliyor.$dsr$, $dsr$Agricultural credit does not work like an ordinary consumer loan. The difference shows in three places: how the interest rate is set, how the maturity is built, and how the ceiling is drawn.

**The bank does not set the rate alone.** On interest-supported — commonly, subsidised — agricultural loans, the discount rates are set by a communiqué of the Ministry of Agriculture and Forestry, according to the line of production. The discount available to a beekeeper need not equal the one available to a greenhouse grower; the rate follows which branch of production is being supported.

The scope of that mechanism in 2025: the bank extended more than 565 billion lira in subsidised credit to 589,000 producers.

**Maturity is built around the harvest.** On loans to producer organisations, repayment can be deferred for up to two years, with a total term of five or seven. Plant an orchard and the first harvest comes in the third year; the grace period exists to meet exactly that fact.

**Ceilings are drawn by product.** The Farmer Support Loan is capped at one million lira; in 2025, 38,000 customers used it and 18 billion lira was disbursed. On the scheme for producer organisations the ceiling was raised in 2025 from 600,000 to 1,200,000 lira. In beekeeping the cap is 300,000 lira.

Taken together the three give agricultural credit its shape: a communiqué sets the rate, the harvest calendar sets the maturity, and the line of production sets the ceiling.$dsr$, array['kredinin_sartlari']::text[], 'akis', null),
  (10, $dsr$Kovan, tekne, elektrik$dsr$, $dsr$Hives, boats, electricity$dsr$, $dsr$Tarım kredisi denince akla traktör ve gübre geliyor. Bankanın 2025 defterinde bunların yanında çok daha küçük ve çok daha özel kalemler var.

**Arıcılık.** Arılı kovan alımı ve arıcılık işletme giderleri için 300 bin liraya kadar kredi açılıyor. 2025'te 5.700'den fazla üretici bu krediyi kullandı, toplam 890 milyon lira kullandırıldı. Kredinin şartlarından biri dikkat çekici: üretici arıcılık yapıyor ya da geçmişte yapmış olabilir. Yani mesleğe dönenler de kapsamda.

**Balıkçılık.** Denizlerde ve iç sularda su ürünleri avcılığı yapanlara, işletme giderleri için Balıkçı Destek Kredisi veriliyor. 2025'te 600 üretici kullandı, toplam 523 milyon lira.

**Elektrik.** Sulama birlikleri, sulama kooperatifleri ve tarımsal üreticiler için ayrı bir Tarımsal Elektrik Kredisi var. 2025'te dört binden fazla müşteriye 2,9 milyar lira kullandırıldı. Kalem sıradan görünüyor ama Türkiye'de sulamanın büyük kısmı elektrikle çalışan pompalara bağlı; elektrik faturası, tarımsal maliyetin sessiz ve büyük bir parçası.

**Soğuk hava.** Meyve ve sebze üreticileriyle tarımsal örgütlerin ürünlerini saklama kapasitesini artırmak için yeni soğuk hava depolarına ve mevcut depoların yenilenmesine kredi açılıyor. Bu kalemin bakiyesi 2025 sonunda 507 milyon liraydı. Kalem küçük ama sorunu büyük: Türkiye'de sebze ve meyve kaybının önemli kısmı tarlada değil, tarlayla pazar arasında oluyor.

**Güneş.** Tarımsal yenilenebilir enerji yatırımları için açılan krediden 2025'te toplam 987 milyon lira kullandırıldı. Sulama pompasını şebeke yerine güneş panelinden çalıştırmak, tarımsal elektrik faturasının cevabı olarak görülüyor; iki kalem birbirine bakıyor.

**Kooperatif.** Tarım ürünlerinden katma değerli ürünlere geçişi desteklemeye yönelik kredi kapsamında 40 kooperatif ve üreticiye toplam 445 milyon lira sağlandı. Sayı küçük — kırk kooperatif, bütün Türkiye'de. Ama kalemin varlığı bankanın kime kredi açtığını gösteriyor: yalnız tek tek çiftçilere değil, onların kurduğu örgütlere de.

**Sürü.** Hayvancılıkta işletme ölçeğini büyütmeye ve atıl kapasiteyi üretime döndürmeye yönelik kredilerin bir kısmı adlandırılmış projeler üzerinden yürüyor. Birinin adı "Köyümde Yaşamak İçin Bir Sürü Nedenim Var". 2025'te kırmızı et arzını sürdürülebilir kılmak için "Kırsalda Bereket — Hayvancılığa Destek Projesi" uygulamaya alındı. Kredi ürünlerinin isimlendirilmesi teknik bir mesele değil; bu isimler kredinin kime, hangi hikâyeyle anlatıldığını gösteriyor.

**Ürün senedi.** Lisanslı depoculuk sistemi kapsamındaki kredilerin bakiyesi 2025 sonunda 8,2 milyar liraydı. Bunun içinde özel bir kalem var: depolanan ürünün mülkiyetini temsil eden Elektronik Ürün Senetleri karşılığında açılan krediler, 474 milyon lira.

Bu son kalem küçük görünüyor ama fikir olarak yeni. Çiftçi ürününü satmadan, deposundaki ürünü teminat göstererek borçlanabiliyor. Yani hasat zamanı fiyat düşükken satmak zorunda kalmıyor. Aynı sistemin depolama ve standart tarafı, bu dizinin birinci sayısındaki kurumun işi.$dsr$, $dsr$Agricultural credit brings tractors and fertiliser to mind. Alongside those, the bank's 2025 books hold much smaller and much more particular items.

**Beekeeping.** Up to 300,000 lira is available for buying stocked hives and covering the running costs of beekeeping. In 2025 more than 5,700 producers used it, for a total of 890 million lira. One condition is striking: the producer may be keeping bees now or may have done so in the past. Those returning to the trade are covered too.

**Fishing.** Those catching fish at sea and in inland waters can borrow against their operating costs through the Fisherman Support Loan. In 2025, 600 producers used it, for a total of 523 million lira.

**Electricity.** There is a separate Agricultural Electricity Loan for irrigation associations, irrigation cooperatives and farmers. In 2025 more than four thousand customers drew 2.9 billion lira. The item looks unremarkable, but most irrigation in Türkiye runs on electric pumps; the electricity bill is a quiet and large part of the cost of farming.

**Cold storage.** Credit is available to fruit and vegetable growers and farm organisations for new cold stores and for modernising existing ones, to increase the capacity to keep produce. The balance on this item stood at 507 million lira at the end of 2025. The item is small but the problem behind it is not: much of Türkiye's fruit and vegetable loss happens not in the field but between the field and the market.

**Sun.** A total of 987 million lira was drawn in 2025 under the loan for renewable energy investments in farming. Running an irrigation pump from a solar panel rather than the grid is treated as the answer to the agricultural electricity bill; the two items face each other.

**Herds.** Part of the lending aimed at increasing herd size and bringing idle capacity back into production runs through named projects. One is called "I Have a Whole Herd of Reasons to Live in My Village". In 2025 the "Abundance in the Countryside — Support for Livestock" project was launched to sustain the supply of red meat. Naming loan products is not a technical matter; the names show who the credit is being explained to, and with what story.

**Cooperatives.** Under the loan supporting the shift from raw produce to higher-value goods, 40 cooperatives and producers received a total of 445 million lira. The number is small — forty cooperatives, in the whole country. But the item's existence shows who the bank lends to: not only individual farmers but the organisations they build.

**Warehouse receipts.** Loans under the licensed warehousing system stood at 8.2 billion lira at the end of 2025. Within that sits a particular item: loans made against electronic warehouse receipts, which represent title to stored produce, came to 474 million lira.

That last item looks small but the idea behind it is new. A farmer can borrow against produce sitting in a warehouse without selling it — and so is not forced to sell at harvest time when prices are low. The storage and standards side of the same system is the business of the institution in this series' first issue.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarim-app-2026.web.app/dosya/ziraat-bankasi/ziraat_aricilik_adana.jpg","atif":"Zeynel Cebeci · CC BY-SA 4.0 · Wikimedia Commons","kaynak":"https://commons.wikimedia.org/wiki/File:Beekeeping,_Adana_01.jpg","alt_tr":"Adana'da arı kovanları. Kovan alımı için açılan kredinin üst sınırı 300 bin lira.","alt_en":"Beehives in Adana. The loan for buying stocked hives is capped at 300,000 lira."}$dsr$::jsonb),
  (11, $dsr$Aynı sorun, iki cevap$dsr$, $dsr$One problem, two answers$dsr$, $dsr$19. yüzyılın sonunda Fransız çiftçisi de Anadolu çiftçisiyle aynı sorunu yaşıyordu: uygun şartlı kredi bulamıyordu. Fransa'nın verdiği cevap, Osmanlı'nınkinden yirmi iki yıl sonra ve bambaşka bir yapıyla geldi.

1884'te çıkarılan mesleki örgütlenme kanunu çiftçi birliklerinin kurulmasına izin verdi. Ertesi yıl, 1885'te, Jura bölgesindeki Salins-les-Bains'de Louis Milcent ve Alfred Bouvet adında iki kişi ilk yerel tarım kredi kasasını kurdu. Bu kasa bir prototip oldu.

5 Kasım 1894 tarihli kanunla Crédit Agricole resmen doğdu. Kanunun dayandığı ilke **karşılıklılık**tı: çiftçi birliği üyeleri, sorumluluğu kendilerine ait olmak üzere yerel kredi kasaları kurabiliyordu. Yönetim ilkesi de buradan çıktı — kişi başına tek oy, elindeki hisse ne olursa olsun.

Ama kasalar kısa sürede sermayesiz kaldı. 1897'de hükümet Banque de France'ı görevlendirdi: 40 milyon altın franklık bir bağış ve yılda 2 milyon franklık ödeme. 1899 kanunuyla bölge bankaları kuruldu ve yapı bugünkü piramidini aldı.

Karşılaştırmanın ilginç yeri burası. İki kurum da devlet parasıyla ayağa kalktı — biri aşar vergisine yapılan zamla, öteki merkez bankası bağışıyla. Yani "biri devletçi, öteki serbest" gibi bir ayrım tarihe uymuyor.

Fark sahiplikte. Ziraat Bankası bir devlet müessesesi olarak kuruldu, arada anonim şirket oldu, bugün yine anonim şirket. Crédit Agricole ise üyelerinin ortak olduğu bir yapı olarak kaldı: bugün 55 milyon perakende müşterisi ve **12,3 milyon ortağı** var.

İki cevap da aynı soruya verildi. Biri "devlet çiftçiye kredi versin" dedi, öteki "çiftçiler kendi bankalarını kursun, devlet destek olsun". Türkiye'de tarımsal kredinin bugün neden tek bir kurumda toplandığını anlamak için bu ayrım işe yarıyor.

Zamanlama da öğretici. Mithat Paşa'nın sandığı 1863'te kuruldu; Fransa'nın ilk yerel kasası 1885'te. Yani tarımsal kredi fikri Anadolu'ya Avrupa'dan gelmedi, aksine yirmi iki yıl önce burada denendi. Fark, fikrin nereden çıktığında değil, nasıl kurumsallaştığında.$dsr$, $dsr$At the end of the nineteenth century the French farmer faced the same problem as the Anatolian one: no credit on workable terms. France's answer came twenty-two years later than the Ottoman one, and with an entirely different structure.

The professional association act of 1884 permitted farmers' unions to form. The following year, in 1885, two men named Louis Milcent and Alfred Bouvet set up the first local agricultural credit fund at Salins-les-Bains in the Jura. That fund became a prototype.

Crédit Agricole was formally born with the act of 5 November 1894. Its founding principle was **mutuality**: members of farmers' unions could establish local credit funds for which they themselves were liable. The governing rule followed from it — one member, one vote, whatever the size of the holding.

The funds soon ran out of capital. In 1897 the government instructed the Banque de France to help: an endowment of 40 million gold francs and an annual payment of 2 million. The act of 1899 created the regional banks and the structure took its present pyramid form.

Here is where the comparison gets interesting. Both institutions were raised on state money — one through a surcharge on the tithe, the other through a central bank endowment. A distinction along the lines of "one statist, the other free" does not fit the history.

The difference is ownership. Ziraat Bankası was founded as a state establishment, became a joint-stock company along the way, and is a joint-stock company today. Crédit Agricole remained a structure owned by its members: it has 55 million retail customers and **12.3 million member-shareholders**.

Both answers addressed the same question. One said "let the state lend to the farmer"; the other, "let farmers build their own bank and the state support it." The distinction helps explain why agricultural credit in Türkiye is concentrated in a single institution today.

The timing is instructive too. Mithat Pasha's fund was founded in 1863; France's first local fund in 1885. The idea of agricultural credit did not arrive in Anatolia from Europe — it was tried here twenty-two years earlier. The difference lies not in where the idea came from but in how it was institutionalised.$dsr$, array['iki_banka']::text[], 'veri', $dsr${"url":"https://tarim-app-2026.web.app/dosya/ziraat-bankasi/ziraat_salins_les_bains.jpg","atif":"Jean-Baptiste Béchet · Kamu malı · Wikimedia Commons","kaynak":"https://commons.wikimedia.org/wiki/File:Salins-les-Bains.jpg","alt_tr":"Salins-les-Bains. Fransa'nın ilk yerel tarım kredi kasası 1885'te bu kasabada kuruldu.","alt_en":"Salins-les-Bains, where France's first local agricultural credit fund was founded in 1885."}$dsr$::jsonb),
  (12, $dsr$Bir bankanın yüz altmış iki yılı$dsr$, $dsr$A bank's hundred and sixty-two years$dsr$, $dsr$Bir kasaba sandığı olarak başlayan kurum, Türkiye'nin en büyük bankası hâline geldi. Aradaki yol düz değildi.

Sandık, kaynağını 1883'te bir vergi zammından aldı. 1888'de banka oldu ve mevduat kabul etmeye başladı. 1892'de devlete borç verecek büyüklüğe ulaştı. 1919–1922 arasında ikiye bölündü. 1924'te "çiftçilerin eline teslim etmek" gerekçesiyle anonim şirket yapıldı. 1932'de buğday alımıyla görevlendirildi, 1933'te silo kurmakla; 1938'de bu işler ayrılıp Toprak Mahsulleri Ofisi'ne devredildi. 2000'de yeniden anonim şirket hâline getirildi. 2001'de, kamu bankalarının yeniden yapılandırılması sırasında Emlak Bankası kendisiyle birleştirilerek kapatıldı.

2025'te 162. yılını doldurduğunda aktif büyüklüğü 8 trilyon lirayı aşmış, hizmet verdiği ülke sayısı yirmiye çıkmıştı.

Çiftçi açısından bakıldığında ise değişen çok az şey var. 1863'te sorun şuydu: ürün olgunlaşana kadar geçecek aylarda para nereden bulunacak. 2025'te de sorun bu. Değişen, cevabın ölçeği: yirmi liralık kredi 900 bin liraya, tek bir kasabadaki sandık 1.745 şubeye çıktı.

Türkiye'de tarımın finansmanı bugün büyük ölçüde tek bir kurumun defterinde duruyor. O defter 1863'te, yirmi liralık bir borçla açıldı.$dsr$, $dsr$An institution that began as a small-town fund became Türkiye's largest bank. The road between was not straight.

The fund drew its resources from a tax surcharge in 1883. In 1888 it became a bank and began taking deposits. By 1892 it was large enough to lend to the state. Between 1919 and 1922 it split in two. In 1924 it was made a joint-stock company on the grounds of "handing it over to the farmers". In 1932 it was charged with buying wheat and in 1933 with building silos; in 1938 that work was hived off to the Turkish Grain Board. In 2000 it was made a joint-stock company again. In 2001, during the restructuring of the state banks, Emlak Bankası was merged into it and closed.

By 2025, its hundred and sixty-second year, its assets had passed 8 trillion lira and it was serving customers in twenty countries.

Seen from the farmer's side, very little has changed. In 1863 the problem was where to find money in the months before the crop ripens. In 2025 it is the same problem. What has changed is the scale of the answer: a twenty-lira loan has become 900,000 lira, and a fund in a single town has become 1,745 branches.

The financing of farming in Türkiye today sits largely on one institution's books. That ledger was opened in 1863, with a loan of twenty lira.$dsr$, '{}'::text[], 'anlati', null),
  (13, $dsr$Kaynakça$dsr$, $dsr$Sources$dsr$, $dsr$**Kurumun kendi belgeleri**

Ziraat Bankası, *Bankamız Tarihçesi* — 1863'ten 2025'e kilometre taşları. Kuruluş, Menafi Hissesi, 1888 nizamnamesi, 1924 tarihli 444 sayılı Bütçe Kanunu, 2000 tarihli 4603 sayılı Kanun ve 2001'deki Emlak Bankası birleşmesi bu kaynaktan.

Ziraat Bankası, *2025 Entegre Faaliyet Raporu* — tarım kredisi bakiyesi, müşteri sayıları, kredi türlerine göre kırılım, sübvansiyonlu kredi kapsamı, arıcılık, balıkçılık, tarımsal elektrik ve lisanslı depoculuk kalemleri, banka geneli büyüklükler.

Ziraat Bankası, *2023* ve *2021 Entegre Faaliyet Raporları* — kredili müşteri sayısı ve portföy bileşimi serileri.

**Sektör verisi**

Bankacılık Düzenleme ve Denetleme Kurumu, *Aylık Bülten — Sektörel Kredi Dağılımı*. Türkiye'deki bütün bankaların tarım sektörüne açtığı toplam nakdi kredi; bu dosyadaki pay hesabının paydası.

**Karşılaştırma**

Crédit Agricole, *History of the Crédit Agricole group* ve *Discover the Crédit Agricole Group* — 1885'teki ilk yerel kasa, 5 Kasım 1894 kanunu, karşılıklılık ilkesi, 1897'deki Banque de France desteği ve bugünkü ortak sayısı.

**Dizinin birinci sayısı**

Toprak Mahsulleri Ofisi, *Kurum Hakkında* — 1932 tarihli ve 2056 sayılı Kanunla buğday alımının Ziraat Bankası'na verilmesi, 1933 tarihli ve 2303 sayılı Kanunla depo görevi, Buğday Masası Şefliği ve 1938'de TMO'ya devir. Bu olaylar Ziraat Bankası'nın kendi tarihçesinde yer almıyor; kaynak TMO'nun belgesidir.$dsr$, $dsr$**The institution's own documents**

Ziraat Bankası, *Our Bank's History* — milestones from 1863 to 2025. The founding, the Benefit Share, the 1888 regulation, Budget Act no. 444 of 1924, Act no. 4603 of 2000 and the 2001 merger with Emlak Bankası come from this source.

Ziraat Bankası, *2025 Integrated Annual Report* — agricultural loan balance, customer numbers, breakdown by loan type, scope of subsidised credit, the beekeeping, fishing, agricultural electricity and licensed warehousing items, and bank-wide figures.

Ziraat Bankası, *2023* and *2021 Integrated Annual Reports* — borrower numbers and portfolio composition series.

**Sector data**

Banking Regulation and Supervision Agency, *Monthly Bulletin — Sectoral Distribution of Loans*. Total cash loans extended to the agricultural sector by all banks in Türkiye; the denominator of the share calculated in this dossier.

**Comparison**

Crédit Agricole, *History of the Crédit Agricole group* and *Discover the Crédit Agricole Group* — the first local fund of 1885, the act of 5 November 1894, the principle of mutuality, the Banque de France support of 1897 and today's membership.

**The first issue in this series**

Turkish Grain Board, *About the Institution* — the assignment of wheat purchasing to Ziraat Bankası under act no. 2056 of 1932, the storage duty under act no. 2303 of 1933, the Wheat Desk Directorate and the 1938 transfer to TMO. These events do not appear in Ziraat Bankası's own history; the source is TMO's document.$dsr$, '{}'::text[], 'anlati', null)
) as v(ord, title_tr, title_en, body_tr, body_en, chart_keys, tur, gorsel)
where d.slug = 'ziraat-bankasi';

-- Sağlama: beklenen bölüm sayısı yazılmadıysa işlem geri alınır.
do $kontrol$
declare n integer;
begin
  select count(*) into n
    from public.dossier_sections s
    join public.country_dossiers d on d.id = s.dossier_id
   where d.slug = 'ziraat-bankasi';
  if n <> 13 then
    raise exception 'Bölüm sayısı 13 olmalıydı, % yazıldı', n;
  end if;
end
$kontrol$;



-- ════════════════════════════════════════════════════════════════════════
-- Eski dosyaları arşive al
-- ════════════════════════════════════════════════════════════════════════
-- ends_at = now(): pencere bugün kapanıyor. active_country_dossier
-- `ends_at > now()` istiyor, dolayısıyla ikisi de ana sayfadan düşüyor.
update public.country_dossiers
   set status     = 'archived',
       ends_at    = now(),
       updated_at = now()
 where slug in ('hollanda', 'tmo')
   and status = 'published';

-- ════════════════════════════════════════════════════════════════════════
-- Takvim: "Yakında" sözü devrediliyor
-- ════════════════════════════════════════════════════════════════════════
-- Yakında kartı BOŞ BIRAKILMIYOR (kullanıcı kararı): Rusya yayına girdiğine
-- göre ülke tarafında sıradaki söz İspanya.
--
-- Rotasyon Model → Pazar → Rakip döngüsünde ilerliyor ve tamamı CLAUDE.md
-- §2.11'e yazıldı. Sıradaki üç sayı: İspanya (Rakip) · Avustralya (Model) ·
-- Irak (Pazar).
--
-- SIRA ÖNEMLİ: unique(tur, sira) var. Eski satır sira 1'i BIRAKMADAN yeni
-- satır eklenemez, o yüzden önce eski kayıt 90'lara taşınıp kapatılıyor.
-- Satır silinmiyor — tablonun kendi yorumu "takvimin geçmişi kayıtta kalsın"
-- diyor.
update public.dossier_takvim
   set etkin = false,
       sira  = 90 + sira
 where sira < 90
   and (   (tur = 'ulke'  and ad_tr = 'Rusya')
        or (tur = 'kurum' and ad_tr = 'Ziraat Bankası'));

insert into public.dossier_takvim (tur, ad_tr, ad_en, sira, etkin)
values ('ulke', 'İspanya', 'Spain', 1, true)
on conflict (tur, sira) do update set
  ad_tr = excluded.ad_tr,
  ad_en = excluded.ad_en,
  etkin = true;

-- Kurum tarafında sıradaki: Tarım Kredi Kooperatifleri (Sayı 03).
-- Dizinin tamamı CLAUDE.md §8.13'te.
insert into public.dossier_takvim (tur, ad_tr, ad_en, sira, etkin)
values ('kurum', 'Tarım Kredi Kooperatifleri',
        'Agricultural Credit Cooperatives', 1, true)
on conflict (tur, sira) do update set
  ad_tr = excluded.ad_tr,
  ad_en = excluded.ad_en,
  etkin = true;

-- ════════════════════════════════════════════════════════════════════════
-- Sağlama — devir gerçekten oldu mu
-- ════════════════════════════════════════════════════════════════════════
do $dev$
declare
  n_aktif int;
  n_arsiv int;
begin
  select count(*) into n_aktif from public.active_country_dossier;
  if n_aktif <> 2 then
    raise exception 'Devir bozuk: aktif dosya sayısı % (2 bekleniyordu)', n_aktif;
  end if;

  if not exists (select 1 from public.active_country_dossier
                  where tur = 'ulke' and slug = 'rusya') then
    raise exception 'Devir bozuk: ülke dizisinin aktifi rusya değil';
  end if;

  if not exists (select 1 from public.active_country_dossier
                  where tur = 'kurum' and slug = 'ziraat-bankasi') then
    raise exception 'Devir bozuk: kurum dizisinin aktifi ziraat-bankasi değil';
  end if;

  select count(*) into n_arsiv from public.country_dossiers
   where slug in ('hollanda', 'tmo') and status = 'archived';
  if n_arsiv <> 2 then
    raise exception 'Devir bozuk: arşivlenen dosya sayısı % (2 bekleniyordu)', n_arsiv;
  end if;

  -- Haber bağlantısının iki yönü de dört dosyada da çalışmalı: arşivlenen
  -- dosya haber göstermeye devam ediyor, haber de ona işaret ediyor.
  if not exists (select 1 from public.dosya_haberleri('tmo', 3)) then
    raise exception 'Arşivlenen dosyanın haber bağlantısı koptu (tmo)';
  end if;
  if not exists (select 1 from public.dosya_haberleri('rusya', 3)) then
    raise exception 'Yeni dosyanın haber bağlantısı çalışmıyor (rusya)';
  end if;

  -- Ülke tarafındaki "Yakında" sözü boş kalmamalı.
  if not exists (select 1 from public.dossier_takvim
                  where tur = 'ulke' and etkin and ad_tr = 'İspanya') then
    raise exception 'Ülke takvimindeki Yakında kartı boş';
  end if;
  if exists (select 1 from public.dossier_takvim
              where tur = 'ulke' and etkin and ad_tr = 'Rusya') then
    raise exception 'Rusya hem yayında hem Yakında görünüyor';
  end if;

  -- Kurum tarafındaki "Yakında" sözü de boş kalmamalı.
  if not exists (select 1 from public.dossier_takvim
                  where tur = 'kurum' and etkin
                    and ad_tr = 'Tarım Kredi Kooperatifleri') then
    raise exception 'Kurum takvimindeki Yakında kartı boş';
  end if;
  if exists (select 1 from public.dossier_takvim
              where tur = 'kurum' and etkin and ad_tr = 'Ziraat Bankası') then
    raise exception 'Ziraat Bankası hem yayında hem Yakında görünüyor';
  end if;
end
$dev$;
