-- TÜRKŞEKER — Kurum Dosyası Sayı 07 · İÇERİK (draft)
--
-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  BU DOSYA supabase/migrations/ ALTINDA DEĞİL — ÖYLE OLMASI GEREKİYOR ║
-- ╚══════════════════════════════════════════════════════════════════════╝
--
-- `supabase db push` klasördeki HER ŞEYİ uygular. Göç migrations/ altında
-- dursa, ilgisiz bir sebeple atılan tek bir push dosyayı onay alınmadan
-- veritabanına yazardı. TMO, TİGEM ve Mısır göçleri aynı gerekçeyle burada
-- beklemişti.
--
-- ÖN KOŞUL: 20261123140000_dossier_bolum_turu_galeri.sql ÖNCE uygulanmalı.
-- Galeri bölümü tur='galeri' taşıyor ve dossier_sections_tur_check bunu
-- 24 Kasım 2026'ya kadar tanımıyordu; `supabase db push` tam burada düştü.
--
-- ONAY ALINDIĞINDA, SIRAYLA:
--   ls supabase/migrations/ | tail        # damga bundan SONRA mı, bak
--   mv content/dossiers/turkseker/beklemede/*.sql supabase/migrations/
--   supabase db push
--
-- DAMGA UYARISI: CLI, uygulanmış son göçten ESKİ damgalı bir göçü SESSİZCE
-- atlıyor ve "Remote database is up to date" diyor. 23 Kasım 2026'da
-- uygulanmış son göç 20261123120000; bu damga ondan sonra.
--
-- NE YAPAR: içeriği DRAFT olarak yazar. Taslak satır anon anahtarıyla
-- görünmüyor (RLS), yani içerik sessizce yerleşir. Durum değişikliği
-- ikinci göçte.
--
-- DIŞ begin/commit SÖKÜLDÜ: CLI her göçü tek işlemde çalıştırıyor. İçeride
-- bir commit kalsaydı, sondaki sağlamalar düşse bile içerik yazılmış olurdu.
-- Kaynak dosya supabase/seed/dossier_turkseker.sql olduğu gibi duruyor.

-- TÜRKŞEKER — Türkiye Şeker Fabrikaları A.Ş. — Ülke Dosyası · seed
--
-- ÜRETİLMİŞ DOSYA — elle düzenlemeyin.
-- Kaynak:  content/dossiers/turkseker/
-- Üretim:  node content/dossiers/seed_dossier.mjs turkseker
-- Tarih:   2026-11-24T11:34:25.384Z
--
-- Bölüm: 22 · TR ~5.164 kelime · EN ~7.070 kelime
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
  'turkseker',
  'TÜRKŞEKER — Türkiye Şeker Fabrikaları A.Ş.',
  'TÜRKŞEKER — Turkish Sugar Factories Inc.',
  null,
  'kurum',
  $dsr$Türkiye Şeker Fabrikaları A.Ş. · 6 Temmuz 1935 — ve Ana Statü · 233 sayılı KHK uyarınca$dsr$,
  7,
  $dsr$Alpullu'dan bugüne yüz yıl: pancarı şekere çeviren kurum.$dsr$,
  $dsr$A hundred years from Alpullu: the institution that turns beet into sugar.$dsr$,
  $dsr${"_dosya":"Türkşeker — Kurum Dosyası Sayı 07 · tasarım künyesi","_amac":"Evrak görsel dilinin bu dosyadaki uygulaması. DossierTheme bu dosyadan üretilir.","_kural":"Buradaki hiçbir kontrast sayısı elle yazılmadı. Hepsi _ortak/kontrast.py'nin ölçü fonksiyonuyla ÖLÇÜLDÜ ve bu dosya _raw/kur_tasarim.py'den üretildi; dogrula_tasarim.py her sayıyı yeniden ölçüp karşılaştırıyor.","_uretec":"content/dossiers/turkseker/_raw/kur_tasarim.py","tez_cumlesi":{"tr":"Alpullu'dan bugüne yüz yıl: pancarı şekere çeviren kurum.","en":"A hundred years from Alpullu: the institution that turns beet into sugar.","_not":"§8.2 — tez cümlesi İDDİA KURMAZ, tanıtır. Dizinin bir kez durdurulma sebebi iddianame tonuydu."},"kume":{"ad":"Üretim","sira":9,"kagit_vurgu":"#1F5626","kapak_vurgu":"#4CC756","_devralindi":"Küme TİGEM dosyasında (Sayı 06) kuruldu ve Türkşeker orada ADIYLA anıldı. Yeni küme açılmadı, yeni renk üretilmedi.","gerekce":"Devletin BİZZAT ÜRETİCİ olması. TÜRKŞEKER kendi fabrikasında pancarı şekere çeviriyor; kota bölüştüren düzenleyici değil, üreten KİT."},"palet":{"ad":"Evrak — kağıt gövde","kaynak_fikir":"Kurumun manzarası yok; maddi karşılığı kağıttır. Bu dosyada kağıt ayrıca konunun kendisi: şeker rejimi 1925'ten beri özel mevzuatla yürüyor ve üretim kotayla planlanıyor. Çiftçinin pancarı da bir kağıtla başlıyor — Şeker Pancarı Üretim Sözleşmesi.","mod":"KOYU KAPAK → KAĞIT GÖVDE. Dosya sayfası sistem açık/koyu tercihini izlemez.","mod_gerekcesi":"Fiziksel dosyanın kendisi: dışı mukavva kapak, içi kağıt.","sayfa":{"zemin":{"hex":"#E3E7E5","rol":"Sayfa zemini — arşiv kağıdı","kontrast_app_krem":1.109},"yuzey":{"hex":"#F0F2F0","rol":"Kart, tablo, kayıt bloğu","kontrast_zemin":1.11},"murekkep":{"hex":"#15191A","rol":"Gövde metni","kontrast_zemin":14.19,"kontrast_yuzey":15.74},"sessiz":{"hex":"#575F61","rol":"Meta, kaynak satırı, altyazı","kontrast_zemin":5.23,"kontrast_yuzey":5.81},"vurgu":{"hex":"#1F5626","rol":"Üretim — rakamlar, başlık vurguları, ülke serisi","kontrast_zemin":6.96,"kontrast_yuzey":7.72},"ikincil":{"hex":"#575F61","rol":"Karşılaştırmanın ikinci ölçüsü — TÜRKŞEKER satırı, şirket sayısı","kontrast_zemin":5.23,"kontrast_yuzey":5.81,"_not":"Kasıtlı olarak NÖTR, TİGEM'deki kararın aynısı. Bu dosyada ikinci seri bir kez 'TÜRKŞEKER', bir kez 'şirket sayısı' — ikisi de başka bir KURUM TÜRÜ değil, aynı şeyin başka ölçüsü. Başka kümenin rengi ödünç alınsaydı okur orada bir kurum türü arardı."},"cizgi":{"hex":"#C0C6C3","rol":"Marj rayı, tablo kuralı","kontrast_zemin":1.39},"cizgiVurgu":{"hex":"#767E7C","rol":"Bölüm ayırıcı, motif","kontrast_zemin":3.34}},"kapak":{"zemin":{"hex":"#131718","rol":"Kapak zemini — mukavva"},"yuzey":{"hex":"#1D2325","rol":"Kapak üstü blok","kontrast_zemin":1.13},"murekkep":{"hex":"#F0F2F0","rol":"Kapak başlığı","kontrast_zemin":16.04},"sessiz":{"hex":"#98A1A2","rol":"Seri etiketi, belge satırı","kontrast_zemin":6.84},"vurgu":{"hex":"#4CC756","rol":"Üretim, kapak karşılığı","kontrast_zemin":8.26}},"serit":{"_amac":"Ana sayfadaki dosya şeridi sayfanın içinde yaşıyor; krem zemin.","murekkep":{"hex":"#15191A","kontrast_krem":15.73},"vurguKoyu":{"hex":"#1F5626","rol":"Üretim'in krem zemindeki karşılığı","kontrast_krem":7.72},"ikincilKoyu":{"hex":"#575F61","kontrast_krem":5.8},"_ayrisma":{"uygulamanin_yapisal_yesili":"#2F4B2E","oran":1.12,"_not":"Aynı risk TİGEM'de ölçülmüştü ve bu dosyada aynen duruyor: kümenin rengi yeşil, uygulamanın yapısal yeşili #2F4B2E. Kart kendi zemininden parlaklıkla değil, krem zemin üzerindeki konumuyla ayrışıyor. Dizinin en dar aralığı."}}},"motif":{"ad":"Cetvel çizgisi","tanim":"Defter ve resmî evrak kağıdının marj rayı: solda dikey ray, aralarda ince yatay kural çizgileri.","gerekce":"Kuruma göre DEĞİŞMEZ, dizi kimliğidir (§8.4). Değişen renktir.","uygulama":{"opaklik":"%8","renk":"cizgiVurgu #767E7C üzerine opaklık","bicim":"Vektör (CustomPainter) — telif yok, ölçeklenir","yerlesim":"Bölüm ayırıcılarında ve kapak altı geçiş bandında. Gövde metninin ARKASINDA kullanılmaz.","aralik_notu":"Izgara aralığı 24 px'in altına inmeyecek (moiré)."}},"kapak":{"yon":"Kuruluş belgesinden kurulan tipografik kapak","gerekce":"Fotoğraf kapak yine reddedildi (§8.8). Bu dosyada ayrıca bir sebep daha var: kurumun kuruluş karesi YOK. Commons'ta Alpullu Şeker Fabrikası'nın hiçbir fotoğrafı bulunmuyor.","sinir":"Kapak bir belgeyi ALINTILAR, TAKLİT ETMEZ. Resmî Gazete anteti, mühür, arma veya kurum logosu yeniden üretilmez. Kapakta her zaman seri etiketi ve sayı numarası bulunur.","tipografi_katmani":{"ust_satir":"KURUM DOSYASI · 07 · ÜRETİM","baslik":"TÜRKİYE ŞEKER FABRİKALARI","_baslik_notu":"Büyük harfler ELLE yazıldı. Türkçede upper() 'i' harfini 'I' yapıyor ve TÜRKIYE çıkıyor; dizide aynı hata iki kez yaşandı (§8.5, _Kartlar ve yaka başlığı).","belge_satiri":"Türkiye Şeker Fabrikaları A.Ş. · 6 Temmuz 1935 — ilk Türk şekeri · Alpullu · 26 Kasım 1926","_iki_tarih_notu":"Kurumun iki doğum tarihi var ve ikisi de doğru: tüzel kişilik 1935'te, şeker 1926'da. Dosyanın ekseni 1926 (kullanıcı kararı), kuruluş belgesi 1935. Kapak ikisini de taşıyor."}},"_yasak":["Kurum logosu, arma, mühür, Resmî Gazete anteti — yeniden üretilmez.","Kapakta fotoğraf (§8.8).","Stok 'mutlu çiftçi' fotoğrafı ve dekoratif ikon seti.","Şekerlikte küp şeker, fincan yanında şeker, kaşıkta dökülen şeker: 'şeker' kelimesinin en yıpranmış stok karesi ve dosyanın anlattığı şey sofra değil, SANAYİ.","Şekerleme, pasta, tatlı — her türlü şekerli mamul. Türkçede 'şeker' hem ürünü hem şekerlemeyi anlatıyor; dosya pancardan kristal şeker üreten bir KİT'i anlatıyor.","Toprakta filizlenen fide makrosu: 'büyüme' klişesi. Kurumun ürettiği şey fide değil, kristal şeker.","Grafikte rengi tek ayırt edici işaret yapmak (bkz. renk_korlugu)."],"renk_korlugu":{"_olcum":"TİGEM · _raw/kontrast.py · Viénot-Mollon benzetimi + CIE76 ΔE","_ayni_kume":"Küme TİGEM ile aynı olduğu için ayrışma ölçümü de aynı; yeniden ölçülmedi, kararı devralındı.","KARAR":"RENK TEK BAŞINA HİÇBİR YERDE ANLAM TAŞIMAZ. Üretim kümesinin kağıt vurgusu deuteranopi altında Kamu gücü'ne ΔE 3,6 mesafede; dizinin mevcut tabanı zaten 2,0. Her grafikte rol BİÇİMLE de ayrışıyor (etiket, tarama, konum)."}}$dsr$::jsonb,
  $dsr${"_dosya":"Türkşeker — Kurum Dosyası Sayı 07","_kural":"KİLİTLİ KATMAN. Metindeki her rakam buradan okunur; metne elle rakam yazılmaz. Kaynaklar _raw/ altındaki çıkarımlar, onlar da kurumun kendi belgelerine ve FAOSTAT/USDA'ya bağlı.","_uretim":"build_data.py · 2026-11-23","kimlik":{"ilk_seker_tarihi":"26 Kasım 1926","ilk_seker_yeri":"Alpullu","yuzuncu_yil":2026,"sirket_kurulus":"6 Temmuz 1935","sirket_kurulus_sermaye_tl":22000000,"fabrika_1990_oncesi":30,"fabrika_bugun":14,"_sermaye_dayanak":"22 milyon TL sermayeli Türkiye Şeker Fabrikaları A.Ş."},"tarih":{"maddeler":[{"yil":1925,"tarih":"6 Kasım 1925","baslik":"Uşak'ta ilk şeker fabrikasının temeli atıldı","_dayanak":"6 Kasım 1925 tarihinde ilk şeker fabrikasının temeli atılmıştır.","_kaynak":"TÜRKŞEKER, Şeker Sektör Raporu 2025"},{"yil":1925,"tarih":"22 Aralık 1925","baslik":"Alpullu'nun temeli atıldı","_dayanak":"22 Aralık 1925 tarihinde Alpullu Şeker Fabrikasının temeli atılarak","_kaynak":"TÜRKŞEKER, Şeker Sektör Raporu 2025"},{"yil":1926,"tarih":"26 Kasım 1926","baslik":"Alpullu'da ilk Türk şekeri üretildi","_dayanak":"26 Kasım 1926 tarihinde fabrika işletmeye açılarak ilk Türk şekeri üretilmiştir.","_kaynak":"TÜRKŞEKER, Şeker Sektör Raporu 2025"},{"yil":1926,"tarih":"17 Aralık 1926","baslik":"Uşak Şeker Fabrikası işletmeye açıldı","_dayanak":"Uşak Şeker Fabrikası ise 17 Aralık 1926 tarihinde işletmeye açılmıştır.","_kaynak":"TÜRKŞEKER, Şeker Sektör Raporu 2025"},{"yil":1933,"tarih":"5 Aralık 1933","baslik":"Eskişehir Şeker Fabrikası açıldı","_dayanak":"05/12/1933 tarihinde Eskişehir Şeker Fabrikası","_kaynak":"TÜRKŞEKER, Şeker Sektör Raporu 2025"},{"yil":1934,"tarih":"19 Ekim 1934","baslik":"Turhal Şeker Fabrikası açıldı","_dayanak":"19/10/1934 tarihinde Turhal Şeker Fabrikası işletmeye açılmıştır.","_kaynak":"TÜRKŞEKER, Şeker Sektör Raporu 2025"},{"yil":1935,"tarih":"6 Temmuz 1935","baslik":"Dört fabrika tek şirkette birleşti: Türkiye Şeker Fabrikaları A.Ş.","_dayanak":"6 Temmuz 1935 tarihinde, üç milli bankamızın eşit paylarla ortak oldukları tek bir şirket çatısı altında toplanarak Türkiye Şeker Fabrikaları A.Ş. kurulmuştur.","_kaynak":"TÜRKŞEKER, Şeker Sektör Raporu 2025"},{"yil":1956,"tarih":"1956","baslik":"Fabrika sayısı 15'e ulaştı","_dayanak":"1956 yılında fabrika sayısı 15'e ulaşmıştır.","_kaynak":"TÜRKŞEKER, Şeker Sektör Raporu 2025"},{"yil":1956,"tarih":"22 Haziran 1956","baslik":"6747 sayılı Şeker Kanunu","_dayanak":"22 Haziran 1956 tarihli ve 6747 sayılı Şeker Kanunu","_kaynak":"TÜRKŞEKER, Şeker Sektör Raporu 2025"},{"yil":2001,"tarih":"19 Nisan 2001","baslik":"4634 sayılı Şeker Kanunu yürürlüğe girdi","_dayanak":"19 Nisan 2001 tarihinde 4634 sayılı Şeker Kanununun yürürlüğe girmesinden önce","_kaynak":"TÜRKŞEKER, Şeker Sektör Raporu 2025"},{"yil":2017,"tarih":"20 Kasım 2017","baslik":"Şeker Kurumu kaldırıldı","_dayanak":"KHK-696/74, 20 Kasım 2017 — Resmî Gazete. Bu madde Türkşeker'in kendi iki belgesinde GEÇMİYOR; dayanağı mevzuattır.","_belge_disi":true},{"yil":2018,"tarih":"2018","baslik":"On şeker fabrikası özelleştirildi","_dayanak":"Afyon, Alpullu, Bor, Çorum, Elbistan, Erzincan, Erzurum, Kırşehir, Muş, Turhal Şeker Fabrikaları ise Özelleştirme İdaresi Başkanlığı tarafından satışı yapılarak 2018 yılında özelleştirilmiştir.","_kaynak":"TÜRKŞEKER, Şeker Sektör Raporu 2025"},{"yil":2021,"tarih":"29 Nisan 2021","baslik":"Sermayenin tamamı Türkiye Varlık Fonu'na geçti","_dayanak":"29/04/2021 tarihli ve 3923 sayılı Cumhurbaşkanı Kararı ile özelleştirme kapsam ve programından","_kaynak":"TÜRKŞEKER, 2024-2028 Stratejik Plan"},{"yil":2025,"tarih":"2025","baslik":"Çarşamba Şeker Fabrikası MKE'ye devredildi","_dayanak":"Çarşamba Şeker Fabrikasının taşınmazları ve üzerinde bulunan yapıların Makine ve Kimya Endüstrisi A.Ş'ye (MKE) devredilmesine karar verilmiş, 2025 yılında devir işlemi tamamlanmıştır.","_kaynak":"TÜRKŞEKER, Şeker Sektör Raporu 2025"}],"_yontem":"Her madde kaynak metinden birebir bir cümleye bağlı; tarih_kur.py o cümlenin metinde durduğunu sınıyor. Dayanağı tutmayan madde çizelgeye giremiyor."},"kota":{"yil":"2025/26","pancar_sekeri_toplam_ton":2837250,"ulke_toplam_ton":2910000,"uc_kesim_yuzde":{"kamu":36.08,"kooperatif":35.42,"ozel":28.49},"turkseker_a_kotasi_ton":1023820,"alpullu":{"ad":"Binbirgıda Tarım Ürünleri Sanayi Ve Ticaret A.Ş. (Alpullu)","a_kotasi_ton":26680,"pancar_sekerinde_pay_yuzde":0.94,"b_kotasi_ton":1334},"sirketler":[{"ad":"KAMU TÜRKŞEKER (14 Fabrika)","a_kotasi_ton":1023820,"pancar_sekerinde_pay_yuzde":36.08,"b_kotasi_ton":51191},{"ad":"Kayseri Şeker Fabrikası A.Ş. (Kayseri, Boğazlıyan, Turhal)","a_kotasi_ton":473240,"pancar_sekerinde_pay_yuzde":16.68,"b_kotasi_ton":23662},{"ad":"Konya Şeker San. Ve Tic. A.Ş. (Konya, Çumra)","a_kotasi_ton":457280,"pancar_sekerinde_pay_yuzde":16.12,"b_kotasi_ton":22864},{"ad":"Amasya Şeker Fabrikası A.Ş","a_kotasi_ton":74490,"pancar_sekerinde_pay_yuzde":2.63,"b_kotasi_ton":3725},{"ad":"KOOPERATİF FAB. TOPLAMI","a_kotasi_ton":1005010,"pancar_sekerinde_pay_yuzde":35.42,"b_kotasi_ton":50251},{"ad":"Doğuş Yiyecek Ve İçecek Üretim San. Tic. A.Ş.(Afyon)","a_kotasi_ton":131810,"pancar_sekerinde_pay_yuzde":4.65,"b_kotasi_ton":6591},{"ad":"Keskinkılıç Gıda San. Tic. A.Ş","a_kotasi_ton":112360,"pancar_sekerinde_pay_yuzde":3.96,"b_kotasi_ton":5618},{"ad":"Çorum Şeker Fabrikası A.Ş","a_kotasi_ton":105670,"pancar_sekerinde_pay_yuzde":3.72,"b_kotasi_ton":5284},{"ad":"Sukkar Şeker Üretim A.Ş. (Erzurum-Erzincan)","a_kotasi_ton":75610,"pancar_sekerinde_pay_yuzde":2.66,"b_kotasi_ton":3781},{"ad":"Tutgu Gıda A.Ş.(Kırşehir)","a_kotasi_ton":75600,"pancar_sekerinde_pay_yuzde":2.66,"b_kotasi_ton":3780},{"ad":"Bor Şeker A.Ş","a_kotasi_ton":71290,"pancar_sekerinde_pay_yuzde":2.51,"b_kotasi_ton":3564},{"ad":"Adapazarı Şeker Fabrikası A.Ş","a_kotasi_ton":69840,"pancar_sekerinde_pay_yuzde":2.46,"b_kotasi_ton":3492},{"ad":"Mutlucan Şeker Üretim Gıda San. Ve Tic. A.Ş.(Elbistan)","a_kotasi_ton":50380,"pancar_sekerinde_pay_yuzde":1.78,"b_kotasi_ton":2519},{"ad":"Kütahya Şeker Fabrikası A.Ş","a_kotasi_ton":47670,"pancar_sekerinde_pay_yuzde":1.68,"b_kotasi_ton":2383},{"ad":"Muş Şeker Üretim A.Ş","a_kotasi_ton":41510,"pancar_sekerinde_pay_yuzde":1.46,"b_kotasi_ton":2075},{"ad":"Binbirgıda Tarım Ürünleri Sanayi Ve Ticaret A.Ş. (Alpullu)","a_kotasi_ton":26680,"pancar_sekerinde_pay_yuzde":0.94,"b_kotasi_ton":1334},{"ad":"ÖZEL ŞEKER ŞİRKETLERİ TOPLAMI","a_kotasi_ton":808420,"pancar_sekerinde_pay_yuzde":28.49,"b_kotasi_ton":40421},{"ad":"PANCAR ŞEKERİ TOPLAMI","a_kotasi_ton":2837250,"pancar_sekerinde_pay_yuzde":100,"b_kotasi_ton":141863}],"nbs_seyri":{"2017":{"pancar_bin_ton":2523,"nbs_bin_ton":267,"toplam_bin_ton":2790,"nbs_pay_yuzde":9.57},"2018":{"pancar_bin_ton":2565,"nbs_bin_ton":135,"toplam_bin_ton":2700,"nbs_pay_yuzde":5},"2019":{"pancar_bin_ton":2633,"nbs_bin_ton":67.5,"toplam_bin_ton":2700,"nbs_pay_yuzde":2.5},"2020":{"pancar_bin_ton":2633,"nbs_bin_ton":67.5,"toplam_bin_ton":2700,"nbs_pay_yuzde":2.5},"2021":{"pancar_bin_ton":2633,"nbs_bin_ton":67.5,"toplam_bin_ton":2700,"nbs_pay_yuzde":2.5},"2022":{"pancar_bin_ton":2681,"nbs_bin_ton":68.75,"toplam_bin_ton":2750,"nbs_pay_yuzde":2.5},"2023":{"pancar_bin_ton":2837,"nbs_bin_ton":72.75,"toplam_bin_ton":2910,"nbs_pay_yuzde":2.5},"2024":{"pancar_bin_ton":2837,"nbs_bin_ton":72.75,"toplam_bin_ton":2910,"nbs_pay_yuzde":2.5},"2025":{"pancar_bin_ton":2837,"nbs_bin_ton":72.75,"toplam_bin_ton":2910,"nbs_pay_yuzde":2.5}},"nbs_dusus":{"_2017_18_bin_ton":267,"_2019_20_bin_ton":67.5,"degisim_yuzde":-74.7},"nbs_sirketler":[{"ad":"Cargill Tarım ve Gıda San. ve Tic. A.Ş.","a_kotasi_ton":31892,"nbs_icinde_pay_yuzde":43.84},{"ad":"ADM Besin ve Tarım A.Ş.","a_kotasi_ton":22632,"nbs_icinde_pay_yuzde":31.11},{"ad":"PNS Pendik Nişasta Tic. A.Ş.","a_kotasi_ton":10331,"nbs_icinde_pay_yuzde":14.2},{"ad":"Sunar Mısır Entegre Tesisleri","a_kotasi_ton":3211,"nbs_icinde_pay_yuzde":4.41},{"ad":"Tat Nişasta San. ve Tic. A.Ş.","a_kotasi_ton":4684,"nbs_icinde_pay_yuzde":6.44}]},"pancar":{"ilk_yil":1961,"son_yil":2024,"verim_ilk":22073.2,"verim_son":70925,"verim_artis_yuzde":221,"uretim":{"1961":2877113,"1962":2730932,"1963":3280715,"1964":4705783,"1965":3421353,"1966":4422085,"1967":5253492,"1968":4715578,"1969":3356472,"1970":4253631,"1971":5956178,"1972":5896042,"1973":5095156,"1974":5707147,"1975":6948637,"1976":9406150,"1977":8994906,"1978":8836818,"1979":8759726,"1980":6766017,"1981":11165105,"1982":12732461,"1983":12769569,"1984":11108375,"1985":9830060,"1986":10662346,"1987":12717321,"1988":11534153,"1989":10928903,"1990":13985741,"1991":15474097,"1992":15126116,"1993":15620514,"1994":12944223,"1995":11170569,"1996":14543277,"1997":18400734,"1998":22282539,"1999":17102326,"2000":18821033,"2001":12632522,"2002":16523166,"2003":12622934,"2004":13517241,"2005":15181247,"2006":14452162,"2007":12414715,"2008":15488332,"2009":17274674,"2010":17942112,"2011":16126489,"2012":14919940,"2013":16488590,"2014":16743045,"2015":16022783,"2016":19592731,"2017":21149020,"2018":17436100,"2019":18054320,"2020":23025738,"2021":17767085,"2022":19253962,"2023":25250213,"2024":23000000},"alan":{"1961":130344,"1962":125739,"1963":134585,"1964":186750,"1965":157749,"1966":153254,"1967":149578,"1968":126539,"1969":101924,"1970":123016,"1971":159012,"1972":148289,"1973":153204,"1974":184959,"1975":212530,"1976":250405,"1977":248937,"1978":275905,"1979":267589,"1980":263384,"1981":358230,"1982":371400,"1983":358831,"1984":350191,"1985":319598,"1986":347364,"1987":384886,"1988":315897,"1989":339731,"1990":377543,"1991":400081,"1992":396243,"1993":421582,"1994":405512,"1995":309417,"1996":416300,"1997":466736,"1998":500950,"1999":415040,"2000":408179,"2001":356609,"2002":371817,"2003":314463,"2004":315053,"2005":335556,"2006":323714,"2007":298869,"2008":320731,"2009":323970,"2010":328651,"2011":293841,"2012":280186,"2013":290910,"2014":287461,"2015":273991,"2016":321953,"2017":338883,"2018":290698,"2019":310081,"2020":336348,"2021":302349,"2022":295405,"2023":364070,"2024":324286},"verim":{"1961":22073.2,"1962":21719.1,"1963":24376.5,"1964":25198.3,"1965":21688.6,"1966":28854.6,"1967":35122.1,"1968":37265.8,"1969":32931.1,"1970":34577.9,"1971":37457.4,"1972":39760.5,"1973":33257.3,"1974":30856.3,"1975":32694.9,"1976":37563.7,"1977":36133.3,"1978":32028.5,"1979":32735.7,"1980":25688.8,"1981":31167.4,"1982":34282.3,"1983":35586.6,"1984":31720.9,"1985":30757.6,"1986":30695,"1987":33041.8,"1988":36512.4,"1989":32169.3,"1990":37044.1,"1991":38677.4,"1992":38173.8,"1993":37052.1,"1994":31920.7,"1995":36102,"1996":34934.6,"1997":39424.3,"1998":44480.6,"1999":41206.5,"2000":46109.8,"2001":35424,"2002":44439,"2003":40141.2,"2004":42904.7,"2005":45242.1,"2006":44644.8,"2007":41539,"2008":48290.7,"2009":53321.8,"2010":54593.2,"2011":54881.7,"2012":53250.1,"2013":56679.4,"2014":58244.6,"2015":58479.2,"2016":60855.9,"2017":62408,"2018":59980.1,"2019":58224.6,"2020":68458.1,"2021":58763.6,"2022":65178.1,"2023":69355.4,"2024":70925},"_seri_siniri":"FAOSTAT 1961'de başlıyor. İlk Türk şekeri 1926'da üretildi; yüzyılın ilk otuz beş yılı taranan hiçbir kaynakta sayı olarak YOK."},"seker":{"yil":2024,"uretim_bin_ton":3100,"pancar_sekeri_bin_ton":3100,"kamis_sekeri_bin_ton":0,"tuketim_bin_ton":3220,"ithalat_bin_ton":235,"ihracat_bin_ton":115,"stok_bin_ton":10,"dunya_toplam_bin_ton":41865,"dunya_ilk_10":[{"ulke":"European Union","bin_ton":16546},{"ulke":"Russia","bin_ton":6900},{"ulke":"United States","bin_ton":4871},{"ulke":"Turkey","bin_ton":3100},{"ulke":"Egypt","bin_ton":2400},{"ulke":"Ukraine","bin_ton":1800},{"ulke":"China","bin_ton":1500},{"ulke":"United Kingdom","bin_ton":1225},{"ulke":"Iran","bin_ton":950},{"ulke":"Belarus","bin_ton":688}],"turkiye_sirasi":4,"randiman_yuzde":13.8},"ciftci":{"zirve_yil":"2017","zirve_sayi":110131,"son_yil":"2025","son_sayi":76767,"ulke":{"2016":{"ciftci":105460,"alan_dekar":3219533,"uretim_ton":19592731,"verim_ton_dekar":6.086,"baz_fiyat_tl_ton":194},"2017":{"ciftci":110131,"alan_dekar":3388829,"uretim_ton":21149020,"verim_ton_dekar":6.241,"baz_fiyat_tl_ton":210},"2018":{"ciftci":106237,"alan_dekar":2906976,"uretim_ton":17436100,"verim_ton_dekar":5.998,"baz_fiyat_tl_ton":235},"2019":{"ciftci":88279,"alan_dekar":3100807,"uretim_ton":18054320,"verim_ton_dekar":5.822,"baz_fiyat_tl_ton":300},"2020":{"ciftci":93812,"alan_dekar":3363483,"uretim_ton":23025738,"verim_ton_dekar":6.846,"baz_fiyat_tl_ton":336},"2021":{"ciftci":86097,"alan_dekar":3023486,"uretim_ton":17767086,"verim_ton_dekar":5.876,"baz_fiyat_tl_ton":420},"2022":{"ciftci":77065,"alan_dekar":2954052,"uretim_ton":19253962,"verim_ton_dekar":6.518,"baz_fiyat_tl_ton":1400},"2023":{"ciftci":99714,"alan_dekar":3628146,"uretim_ton":25250213,"verim_ton_dekar":6.96,"baz_fiyat_tl_ton":1750},"2024":{"ciftci":93293,"alan_dekar":3281033,"uretim_ton":22413958,"verim_ton_dekar":6.831,"baz_fiyat_tl_ton":2375},"2025":{"ciftci":76767,"alan_dekar":3065844,"uretim_ton":20801254,"verim_ton_dekar":6.785,"baz_fiyat_tl_ton":3100}},"turkseker":{"2016":{"ciftci":36400,"alan_dekar":1066470,"uretim_ton":6556324,"verim_ton_dekar":6.148,"baz_fiyat_tl_ton":190},"2017":{"ciftci":38028,"alan_dekar":1109462,"uretim_ton":6936251,"verim_ton_dekar":6.252,"baz_fiyat_tl_ton":210},"2018":{"ciftci":40240,"alan_dekar":953602,"uretim_ton":5763711,"verim_ton_dekar":6.044,"baz_fiyat_tl_ton":235},"2019":{"ciftci":34424,"alan_dekar":1105924,"uretim_ton":6651672,"verim_ton_dekar":6.015,"baz_fiyat_tl_ton":300},"2020":{"ciftci":38238,"alan_dekar":1241827,"uretim_ton":8582038,"verim_ton_dekar":6.911,"baz_fiyat_tl_ton":336},"2021":{"ciftci":36821,"alan_dekar":1194881,"uretim_ton":6470264,"verim_ton_dekar":5.415,"baz_fiyat_tl_ton":420},"2022":{"ciftci":28427,"alan_dekar":1037468,"uretim_ton":6350317,"verim_ton_dekar":6.121,"baz_fiyat_tl_ton":1400},"2023":{"ciftci":40132,"alan_dekar":1483800,"uretim_ton":9698334,"verim_ton_dekar":6.536,"baz_fiyat_tl_ton":1750},"2024":{"ciftci":36109,"alan_dekar":1144108,"uretim_ton":7314019,"verim_ton_dekar":6.393,"baz_fiyat_tl_ton":2262},"2025":{"ciftci":28219,"alan_dekar":1081266,"uretim_ton":7113547,"verim_ton_dekar":6.579,"baz_fiyat_tl_ton":2980}},"dusus":{"_uyari":"Ülke rakamı ile TÜRKŞEKER rakamı ayrı şeylerdir ve yayında biri diğerinin yerine yazılamaz. Düşüş iki tarafta da ağırdır.","_karsilastirma_yili":"2017-2025 (iki tablonun ortak aralığı)","ulke_degisim_yuzde":-30.3,"turkseker_degisim_yuzde":-25.8,"turkseker_disi_degisim_yuzde":-32.7,"ulke_ilk":110131,"ulke_son":76767,"turkseker_ilk":38028,"turkseker_son":28219,"turkseker_disi_ilk":72103,"turkseker_disi_son":48548},"dusus_yuzde":-30.3},"kurum":{"personel_yillik":{"2018":{"memur_sozlesmeli":1473,"daimi_isci":4495,"kampanya_mevsimlik":1595,"toplam":7563},"2019":{"memur_sozlesmeli":1021,"daimi_isci":3285,"kampanya_mevsimlik":1181,"toplam":5487},"2020":{"memur_sozlesmeli":904,"daimi_isci":3548,"kampanya_mevsimlik":1134,"toplam":5586},"2021":{"memur_sozlesmeli":832,"daimi_isci":3999,"kampanya_mevsimlik":1024,"toplam":5855},"2022":{"memur_sozlesmeli":828,"daimi_isci":3826,"kampanya_mevsimlik":998,"toplam":5652}},"personel_dusus":{"_2018":7563,"_2019":5487,"_2022":5652,"ozellestirme_yili_degisim_yuzde":-27.4,"_2018_2022_degisim_yuzde":-25.3,"_not":"On fabrikanın özelleştirildiği 2018'in ardından personel bir yılda 2.076 kişi azaldı. İki olayın aynı yıla düşmesi ölçülmüş bir gerçek; nedensellik bu belgelerden okunamaz."},"personel_2022":{"memur":147,"sozlesmeli":1088,"daimi_isci":3551,"kampanya_mevsimlik":1238,"toplam":6024,"alt_isverenle_toplam":10535,"_dayanak":"147 memur, 1.088 sözleşmeli personel, 3.551 daimi işçi ve 1.238 geçici işçi olmak üzere toplam 6.024 kişi istihdam edilmiştir. Alt-işverenle birlikte toplam 10.535 kişi"},"cinsiyet":{"erkek_yuzde":91,"kadin_yuzde":9,"_dayanak":"çalışan personelin %91'i erkek, %9'u kadındır"},"_veri_yili_siniri":"Stratejik plan 2024-2028 dönemi için hazırlandı; içindeki en yeni personel verisi 2022'ye ait. 2023 sonrası personel sayısı taranan belgelerde YOK."},"ticaret":{"yillar":{"2016":{"kristal_seker_ithalat_ton":280000,"nbs_ithalat_ton":56200,"nbs_ihracat_ton":193400},"2017":{"kristal_seker_ithalat_ton":230000,"nbs_ithalat_ton":28300,"nbs_ihracat_ton":232100},"2018":{"kristal_seker_ithalat_ton":201000,"nbs_ithalat_ton":22700,"nbs_ihracat_ton":232000},"2019":{"kristal_seker_ithalat_ton":169000,"nbs_ithalat_ton":26100,"nbs_ihracat_ton":268000},"2020":{"kristal_seker_ithalat_ton":221000,"nbs_ithalat_ton":22500,"nbs_ihracat_ton":326000},"2021":{"kristal_seker_ithalat_ton":48699,"nbs_ithalat_ton":21044,"nbs_ihracat_ton":408117},"2022":{"kristal_seker_ithalat_ton":602479,"nbs_ithalat_ton":23406,"nbs_ihracat_ton":346049},"2023":{"kristal_seker_ithalat_ton":302570,"nbs_ithalat_ton":20139,"nbs_ihracat_ton":267503},"2024":{"kristal_seker_ithalat_ton":202000,"nbs_ithalat_ton":20700,"nbs_ihracat_ton":345100},"2025":{"kristal_seker_ithalat_ton":110000,"nbs_ithalat_ton":23000,"nbs_ihracat_ton":321500}},"ithalat_dalgasi":{"zirve_yil":"2022","zirve_ton":602479,"onceki_yil":"2021","onceki_ton":48699,"kat":12.4,"dip_yil":"2021","dip_ton":48699},"nbs":{"ihracat_ithalat_orani":{"2016":3.4,"2017":8.2,"2018":10.2,"2019":10.3,"2020":14.5,"2021":19.4,"2022":14.8,"2023":13.3,"2024":16.7,"2025":14},"_2018_ihracat":232000,"_2021_ihracat":408117,"_serh":"NBŞ yurt içi kotası 2018/19'dan başlayarak kesildi ve aynı yıllarda NBŞ ihracatı yükseldi. İki olgu ÖLÇÜLMÜŞTÜR; aralarındaki bağı bu belge kurmuyor, yayına nedensellik olarak yazılamaz."}},"metin_dayanaklari":{"_kaynak":"TÜRKŞEKER · Şeker Sektör Raporu 2025 ve 2024-2028 Stratejik Plan","ankara_kastamonu_yerli_imalat_yuzde":65,"afyon_elbistan_yerli_imalat_yuzde":95,"turkseker_2002_03_pay_yuzde":74,"kapasite_2018_bin_ton":1176,"kapasite_2023_bin_ton":1235,"kapasite_artis_esigi_yuzde":90,"turkseker_b_kotasi_ton":51191,"avans_orani_yuzde":35,"pancar_sekeri_ihtiyac_payi_yuzde":95,"nbs_ihtiyac_payi_yuzde":5,"konya_ekim_alani_yuzde":26,"konya_uretim_yuzde_alt":30,"konya_uretim_yuzde_ust":33,"eskisehir_uretim_yuzde_alt":7,"eskisehir_uretim_yuzde_ust":9,"pancar_oksijen_kat":3,"biyoetanol_hibrit_yuzde":85,"biyoetanol_emisyon_azaltma_yuzde":74,"melas_2020_ton":31200,"alkol_2020_bin_litre":8957,"melas_2023_ton":5660,"alkol_2023_bin_litre":1556,"personel_lisans_yuzde":15.26,"personel_lisansustu_yuzde":2.63,"personel_lise_yuzde":53.61,"usak_sirket_sermaye_tl":600000,"istanbul_trakya_sermaye_tl":500000,"iki_sirket_sermaye_toplam_tl":1100000,"ab_kota_kaldirma_yili":2017,"verim_1961_ton_hektar":22,"verim_2024_ton_hektar":71},"turetilmis":{"_ne":"Çizici kayıt listeleri. Hepsi yukarıdaki bloklardan türetildi.","verim_kayitlari":[{"yil":1961,"verim":22073.2},{"yil":1962,"verim":21719.1},{"yil":1963,"verim":24376.5},{"yil":1964,"verim":25198.3},{"yil":1965,"verim":21688.6},{"yil":1966,"verim":28854.6},{"yil":1967,"verim":35122.1},{"yil":1968,"verim":37265.8},{"yil":1969,"verim":32931.1},{"yil":1970,"verim":34577.9},{"yil":1971,"verim":37457.4},{"yil":1972,"verim":39760.5},{"yil":1973,"verim":33257.3},{"yil":1974,"verim":30856.3},{"yil":1975,"verim":32694.9},{"yil":1976,"verim":37563.7},{"yil":1977,"verim":36133.3},{"yil":1978,"verim":32028.5},{"yil":1979,"verim":32735.7},{"yil":1980,"verim":25688.8},{"yil":1981,"verim":31167.4},{"yil":1982,"verim":34282.3},{"yil":1983,"verim":35586.6},{"yil":1984,"verim":31720.9},{"yil":1985,"verim":30757.6},{"yil":1986,"verim":30695},{"yil":1987,"verim":33041.8},{"yil":1988,"verim":36512.4},{"yil":1989,"verim":32169.3},{"yil":1990,"verim":37044.1},{"yil":1991,"verim":38677.4},{"yil":1992,"verim":38173.8},{"yil":1993,"verim":37052.1},{"yil":1994,"verim":31920.7},{"yil":1995,"verim":36102},{"yil":1996,"verim":34934.6},{"yil":1997,"verim":39424.3},{"yil":1998,"verim":44480.6},{"yil":1999,"verim":41206.5},{"yil":2000,"verim":46109.8},{"yil":2001,"verim":35424},{"yil":2002,"verim":44439},{"yil":2003,"verim":40141.2},{"yil":2004,"verim":42904.7},{"yil":2005,"verim":45242.1},{"yil":2006,"verim":44644.8},{"yil":2007,"verim":41539},{"yil":2008,"verim":48290.7},{"yil":2009,"verim":53321.8},{"yil":2010,"verim":54593.2},{"yil":2011,"verim":54881.7},{"yil":2012,"verim":53250.1},{"yil":2013,"verim":56679.4},{"yil":2014,"verim":58244.6},{"yil":2015,"verim":58479.2},{"yil":2016,"verim":60855.9},{"yil":2017,"verim":62408},{"yil":2018,"verim":59980.1},{"yil":2019,"verim":58224.6},{"yil":2020,"verim":68458.1},{"yil":2021,"verim":58763.6},{"yil":2022,"verim":65178.1},{"yil":2023,"verim":69355.4},{"yil":2024,"verim":70925}],"ciftci_kayitlari":[{"yil":2016,"ulke":105460,"turkseker":36400,"uretim":19592731},{"yil":2017,"ulke":110131,"turkseker":38028,"uretim":21149020},{"yil":2018,"ulke":106237,"turkseker":40240,"uretim":17436100},{"yil":2019,"ulke":88279,"turkseker":34424,"uretim":18054320},{"yil":2020,"ulke":93812,"turkseker":38238,"uretim":23025738},{"yil":2021,"ulke":86097,"turkseker":36821,"uretim":17767086},{"yil":2022,"ulke":77065,"turkseker":28427,"uretim":19253962},{"yil":2023,"ulke":99714,"turkseker":40132,"uretim":25250213},{"yil":2024,"ulke":93293,"turkseker":36109,"uretim":22413958},{"yil":2025,"ulke":76767,"turkseker":28219,"uretim":20801254}],"nbs_kayitlari":[{"yil":2017,"kota":267,"pay":9.57},{"yil":2018,"kota":135,"pay":5},{"yil":2019,"kota":67.5,"pay":2.5},{"yil":2020,"kota":67.5,"pay":2.5},{"yil":2021,"kota":67.5,"pay":2.5},{"yil":2022,"kota":68.75,"pay":2.5},{"yil":2023,"kota":72.75,"pay":2.5},{"yil":2024,"kota":72.75,"pay":2.5},{"yil":2025,"kota":72.75,"pay":2.5}],"ithalat_kayitlari":[{"yil":2016,"kristal":280000,"nbs_ihracat":193400},{"yil":2017,"kristal":230000,"nbs_ihracat":232100},{"yil":2018,"kristal":201000,"nbs_ihracat":232000},{"yil":2019,"kristal":169000,"nbs_ihracat":268000},{"yil":2020,"kristal":221000,"nbs_ihracat":326000},{"yil":2021,"kristal":48699,"nbs_ihracat":408117},{"yil":2022,"kristal":602479,"nbs_ihracat":346049},{"yil":2023,"kristal":302570,"nbs_ihracat":267503},{"yil":2024,"kristal":202000,"nbs_ihracat":345100},{"yil":2025,"kristal":110000,"nbs_ihracat":321500}],"kesimler":[{"ad":"kamu","sirket_yuzde":6.67,"kota_yuzde":36.08,"sirket_sayisi":1},{"ad":"kooperatif","sirket_yuzde":20,"kota_yuzde":35.42,"sirket_sayisi":3},{"ad":"ozel","sirket_yuzde":73.33,"kota_yuzde":28.49,"sirket_sayisi":11}],"kota_siralamasi":[{"ad":"KAMU TÜRKŞEKER (14 Fabrika)","a_kotasi_ton":1023820,"pancar_sekerinde_pay_yuzde":36.08,"b_kotasi_ton":51191},{"ad":"Kayseri Şeker Fabrikası A.Ş. (Kayseri, Boğazlıyan, Turhal)","a_kotasi_ton":473240,"pancar_sekerinde_pay_yuzde":16.68,"b_kotasi_ton":23662},{"ad":"Konya Şeker San. Ve Tic. A.Ş. (Konya, Çumra)","a_kotasi_ton":457280,"pancar_sekerinde_pay_yuzde":16.12,"b_kotasi_ton":22864},{"ad":"Doğuş Yiyecek Ve İçecek Üretim San. Tic. A.Ş.(Afyon)","a_kotasi_ton":131810,"pancar_sekerinde_pay_yuzde":4.65,"b_kotasi_ton":6591},{"ad":"Keskinkılıç Gıda San. Tic. A.Ş","a_kotasi_ton":112360,"pancar_sekerinde_pay_yuzde":3.96,"b_kotasi_ton":5618},{"ad":"Çorum Şeker Fabrikası A.Ş","a_kotasi_ton":105670,"pancar_sekerinde_pay_yuzde":3.72,"b_kotasi_ton":5284},{"ad":"Sukkar Şeker Üretim A.Ş. (Erzurum-Erzincan)","a_kotasi_ton":75610,"pancar_sekerinde_pay_yuzde":2.66,"b_kotasi_ton":3781},{"ad":"Tutgu Gıda A.Ş.(Kırşehir)","a_kotasi_ton":75600,"pancar_sekerinde_pay_yuzde":2.66,"b_kotasi_ton":3780},{"ad":"Amasya Şeker Fabrikası A.Ş","a_kotasi_ton":74490,"pancar_sekerinde_pay_yuzde":2.63,"b_kotasi_ton":3725},{"ad":"Bor Şeker A.Ş","a_kotasi_ton":71290,"pancar_sekerinde_pay_yuzde":2.51,"b_kotasi_ton":3564},{"ad":"Adapazarı Şeker Fabrikası A.Ş","a_kotasi_ton":69840,"pancar_sekerinde_pay_yuzde":2.46,"b_kotasi_ton":3492},{"ad":"Mutlucan Şeker Üretim Gıda San. Ve Tic. A.Ş.(Elbistan)","a_kotasi_ton":50380,"pancar_sekerinde_pay_yuzde":1.78,"b_kotasi_ton":2519},{"ad":"Kütahya Şeker Fabrikası A.Ş","a_kotasi_ton":47670,"pancar_sekerinde_pay_yuzde":1.68,"b_kotasi_ton":2383},{"ad":"Muş Şeker Üretim A.Ş","a_kotasi_ton":41510,"pancar_sekerinde_pay_yuzde":1.46,"b_kotasi_ton":2075},{"ad":"Binbirgıda Tarım Ürünleri Sanayi Ve Ticaret A.Ş. (Alpullu)","a_kotasi_ton":26680,"pancar_sekerinde_pay_yuzde":0.94,"b_kotasi_ton":1334}],"dunya_siralamasi":[{"ulke":"European Union","bin_ton":16546},{"ulke":"Russia","bin_ton":6900},{"ulke":"United States","bin_ton":4871},{"ulke":"Turkey","bin_ton":3100},{"ulke":"Egypt","bin_ton":2400},{"ulke":"Ukraine","bin_ton":1800},{"ulke":"China","bin_ton":1500},{"ulke":"United Kingdom","bin_ton":1225},{"ulke":"Iran","bin_ton":950},{"ulke":"Belarus","bin_ton":688}]},"_uc_pay":{"kota_payi_yuzde":36.08,"pancar_payi_yuzde":34.2,"uretim_payi_yuzde":32,"_uyari":"Üçü AYRI şeyi ölçer: kota bölüşümü · işlenen pancar · üretilen şeker. Yayında biri diğerinin yerine yazılamaz."},"haber":{"imalat_yuzde":70,"imalat_ton_2025":3920,"tanker_adet":250,"tanker_ton":3,"pts_dekar":1000000,"kantar_ton_ilgin":60,"ges_ankara_mw":4,"ges_ercis_mw":20,"ges_ercis_kwh":48000000,"ges_ercis_co2":30000,"ges_toplam_mw":24,"ges_toplam_co2":23000,"kazan_buhar_ton":75,"malatya_kapasite":3800,"malatya_kampanya":71,"melas_ulke":135,"melas_ton":317000,"posa_ton":2080000,"posa_pay_ercis":20,"ekosistem_trilyon":1,"ihracat_milyar_dolar":4.5,"katki_dogrudan":275,"katki_dolayli":750,"pancar_degeri":96,"seker_degeri":105,"yan_urun_degeri":15,"gida_sanayi_degeri":575,"ureticiye_nakit":80,"sektor_istihdam":20000,"tasima_ton":33500000,"tasima_sefer":1500000,"sanayi_sirasi":37,"dunya_sirasi":7,"koy_sayisi":1300,"uretici_2026":30000,"pancar_2026":6900000,"seker_hedef_2026":910000,"rafa_saat":36,"fabrika_toplam":32,"fabrika_ozel":12,"fabrika_kooperatif":6,"burdur_yil":30,"elazig_yatirim":800,"ilgin_2025":260,"ilgin_2026":907,"ilgin_2027":2.51,"difuzyon_ton":3000,"kirec_m3":125,"susurluk_pancar":695000,"susurluk_seker":85000,"ilgin_kapasite":8100,"sera_m2":20000,"tagem_enstitu":49,"rolyef_yil":92,"kampanya_usak_alpullu":101,"kampanya_ankara":65,"ankara_yil":64,"kampanya_susurluk":72,"kampanya_kastamonu":64,"kampanya_ercis":39,"kampanya_yozgat":29},"yurtdisi":{"ozbekistan_kapasite":3000,"ozbekistan_yil_acilis":1998,"ozbekistan_yil_baslangic":1996,"ozbekistan_sure_yil":2,"ozbekistan_bedel_dolar":83250000,"ozbekistan_pay_yuzde":53.7,"cumhuriyet_yil":75},"galeri":{"_amac":"Dosya sonundaki kare galerisi. Bölüm görselleri yerinde duruyor; bunlar onların dışında, sonradan bulunan kareler.","_kural":"Atıfsız kare yayımlanmıyor (§2.4). Atıf ızgarada açıkta, dokunuşun ardında değil.","_kaynaklar":"İki kaynak: Wikimedia Commons (atıf ve lisans API'den) ve turkseker.gov.tr (kurumun kendi yayını; kullanıcı 23 Kasım 2026'da yetkilendirdi).","baslik_tr":"Yüzüncü yıl galerisi","baslik_en":"The centenary gallery","kareler":[{"url":"https://tarimportali.net/dosya/turkseker/galeri_alpullu_kopru_21.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_alpullu_kopru_21.jpg","atif":"Machiel Kiel — CC BY 4.0","lisans":"CC BY 4.0","alt_tr":"Alpullu Köprüsü, Babaeski yakını, 1970'ler. Machiel Kiel fotoğrafı.","alt_en":"The Alpullu bridge near Babaeski, 1970s. Photograph by Machiel Kiel.","en_boy":1.495,"kaynak":"https://commons.wikimedia.org/wiki/File:Alpullu_(near_Babaeski),_Sokollu_era_bridge_over_Ergene_(L48a-21,_1970s).jpg","_kimlik":"galeri_alpullu_kopru_21","_obek":"alpullu","_kaynak_turu":"commons","_dayanak":"nesne_adi 'Alpullu (near Babaeski), Sokollu era bridge over Ergene (L48a-21, 1970s)' + açıklama: 'Alpullu Köprüsü'nün bu fotoğrafı Machiel Kiel tarafından serbest kullanımına izin verilerek NIT (Hollanda Araştırma Enstitüsü) web sitesinde erişime sunulmuştur.' Künyedeki 2012 tarihi YÜKLEME tarihi; çekim 1970'ler."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_alpullu_gar.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_alpullu_gar.jpg","atif":"Ihsan Dolguner — CC BY-SA 4.0","lisans":"CC BY-SA 4.0","alt_tr":"Alpullu istasyon binası, 2016.","alt_en":"The Alpullu station building, 2016.","en_boy":1.3333,"kaynak":"https://commons.wikimedia.org/wiki/File:Alpullu_gari.jpg","_kimlik":"galeri_alpullu_gar","_obek":"alpullu","_kaynak_turu":"commons","_dayanak":"nesne_adi 'Alpullu gari' + açıklama 'Alpullu station house.' + tarih 2016"},{"url":"https://tarimportali.net/dosya/turkseker/galeri_alpullu_istasyon_2026.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_alpullu_istasyon_2026.jpg","atif":"Alicembasli — CC BY-SA 4.0","lisans":"CC BY-SA 4.0","alt_tr":"Alpullu Tren İstasyonu, 29 Ağustos 2026.","alt_en":"Alpullu railway station, 29 August 2026.","en_boy":1.3333,"kaynak":"https://commons.wikimedia.org/wiki/File:Alpullu_Tren_%C4%B0stasyonu_2026-08-29_20.02.24_1788088213.jpg","_kimlik":"galeri_alpullu_istasyon_2026","_obek":"alpullu","_kaynak_turu":"commons","_dayanak":"nesne_adi 'Alpullu Tren İstasyonu 2026-08-29 …' + tarih 2026-08-29"},{"url":"https://tarimportali.net/dosya/turkseker/galeri_alpullu_peron.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_alpullu_peron.jpg","atif":"CeeGee — CC BY-SA 4.0","lisans":"CC BY-SA 4.0","alt_tr":"Alpullu tren istasyonu, Babaeski, Kırklareli, 4 Ağustos 2018.","alt_en":"Alpullu railway station, Babaeski, Kırklareli, 4 August 2018.","en_boy":1.5094,"kaynak":"https://commons.wikimedia.org/wiki/File:AlpulluTrainStation_(2).jpg","_kimlik":"galeri_alpullu_peron","_obek":"alpullu","_kaynak_turu":"commons","_dayanak":"açıklama 'Alpullu train station in Babaeski, Kırklareli Province, Turkey.' + tarih 2018-08-04"},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_alb_kapak.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_alb_kapak.jpg","atif":"İstanbul ve Trakya Şeker Fabrikaları T.A.Ş. Alpullu Şeker ve İspirto Fabrikaları · 1928-1929 · AHTURAL013 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Alpullu Şeker ve İspirto Fabrikaları albümünden bir sayfa: Albüm kapağı. 1928-1929.","alt_en":"A page from the album of the Alpullu Sugar and Spirit Factories: Cover of album. 1928-1929.","en_boy":1.4519,"kaynak":"https://archives.saltresearch.org/handle/123456789/195731","_kimlik":"galeri_salt_alb_kapak","_obek":"alpullu","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHTURAL013 (https://archives.saltresearch.org/handle/123456789/195731). Albüm sayfasının kendi açıklaması (dataItemFiles)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_alb_istasyon.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_alb_istasyon.jpg","atif":"İstanbul ve Trakya Şeker Fabrikaları T.A.Ş. Alpullu Şeker ve İspirto Fabrikaları · 1928-1929 · AHTURAL013 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Alpullu Şeker ve İspirto Fabrikaları albümünden bir sayfa: Kırklareli Alpullu Şeker Fabrikası. Kırklareli Alpullu Tren İstasyonu. 1928-1929.","alt_en":"A page from the album of the Alpullu Sugar and Spirit Factories: Kırklareli Alpullu Sugar Factory. Kırklareli Alpullu Train Station. 1928-1929.","en_boy":1.4545,"kaynak":"https://archives.saltresearch.org/handle/123456789/195731","_kimlik":"galeri_salt_alb_istasyon","_obek":"alpullu","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHTURAL013 (https://archives.saltresearch.org/handle/123456789/195731). Albüm sayfasının kendi açıklaması (dataItemFiles)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_alb_kusat.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_alb_kusat.jpg","atif":"İstanbul ve Trakya Şeker Fabrikaları T.A.Ş. Alpullu Şeker ve İspirto Fabrikaları · 1928-1929 · AHTURAL013 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Alpullu Şeker ve İspirto Fabrikaları albümünden bir sayfa: \"Alpullu İspirto Fabrikası Resmi Küşadi, 28 Kanunievvel 1928\". 1928-1929.","alt_en":"A page from the album of the Alpullu Sugar and Spirit Factories: “Opening ceremony of the Alpullu Spirit Factory, 28 December 1928”. 1928-1929.","en_boy":1.4545,"kaynak":"https://archives.saltresearch.org/handle/123456789/195731","_kimlik":"galeri_salt_alb_kusat","_obek":"alpullu","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHTURAL013 (https://archives.saltresearch.org/handle/123456789/195731). Albüm sayfasının kendi açıklaması (dataItemFiles)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_alb_acilis.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_alb_acilis.jpg","atif":"İstanbul ve Trakya Şeker Fabrikaları T.A.Ş. Alpullu Şeker ve İspirto Fabrikaları · 1928-1929 · AHTURAL013 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Alpullu Şeker ve İspirto Fabrikaları albümünden bir sayfa: Alpullu İspirto Fabrikası'nın açılış töreni, 28 Aralık 1928. 1928-1929.","alt_en":"A page from the album of the Alpullu Sugar and Spirit Factories: Opening ceremony of the Alpullu Spirit Factory, 28 December 1928. 1928-1929.","en_boy":1.4506,"kaynak":"https://archives.saltresearch.org/handle/123456789/195731","_kimlik":"galeri_salt_alb_acilis","_obek":"alpullu","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHTURAL013 (https://archives.saltresearch.org/handle/123456789/195731). Albüm sayfasının kendi açıklaması (dataItemFiles)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_alb_genel.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_alb_genel.jpg","atif":"İstanbul ve Trakya Şeker Fabrikaları T.A.Ş. Alpullu Şeker ve İspirto Fabrikaları · 1928-1929 · AHTURAL013 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Alpullu Şeker ve İspirto Fabrikaları albümünden bir sayfa: Alpullu Şeker Fabrikası'nın genel görünümü. 1928-1929.","alt_en":"A page from the album of the Alpullu Sugar and Spirit Factories: General view of the Alpullu Sugar Factory. 1928-1929.","en_boy":1.4559,"kaynak":"https://archives.saltresearch.org/handle/123456789/195731","_kimlik":"galeri_salt_alb_genel","_obek":"alpullu","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHTURAL013 (https://archives.saltresearch.org/handle/123456789/195731). Albüm sayfasının kendi açıklaması (dataItemFiles)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_alb_ispirto.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_alb_ispirto.jpg","atif":"İstanbul ve Trakya Şeker Fabrikaları T.A.Ş. Alpullu Şeker ve İspirto Fabrikaları · 1928-1929 · AHTURAL013 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Alpullu Şeker ve İspirto Fabrikaları albümünden bir sayfa: Alpullu İspirto Fabrikası. 1928-1929.","alt_en":"A page from the album of the Alpullu Sugar and Spirit Factories: The Alpullu Spirit Factory. 1928-1929.","en_boy":1.4519,"kaynak":"https://archives.saltresearch.org/handle/123456789/195731","_kimlik":"galeri_salt_alb_ispirto","_obek":"alpullu","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHTURAL013 (https://archives.saltresearch.org/handle/123456789/195731). Albüm sayfasının kendi açıklaması (dataItemFiles)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_alb_pancar.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_alb_pancar.jpg","atif":"İstanbul ve Trakya Şeker Fabrikaları T.A.Ş. Alpullu Şeker ve İspirto Fabrikaları · 1928-1929 · AHTURAL013 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Alpullu Şeker ve İspirto Fabrikaları albümünden bir sayfa: Alpullu Şeker Fabrikası ve şeker pancarları. Fabrikanın iç mekânı. 1928-1929.","alt_en":"A page from the album of the Alpullu Sugar and Spirit Factories: The Alpullu Sugar Factory and sugar beets. Interior of the factory. 1928-1929.","en_boy":1.4453,"kaynak":"https://archives.saltresearch.org/handle/123456789/195731","_kimlik":"galeri_salt_alb_pancar","_obek":"alpullu","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHTURAL013 (https://archives.saltresearch.org/handle/123456789/195731). Albüm sayfasının kendi açıklaması (dataItemFiles)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_turhal_istasyon_1930.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_turhal_istasyon_1930.jpg","atif":"Unknown photographer — Public domain","lisans":"Public domain","alt_tr":"Mustafa Kemal Turhal istasyonunda, 22 Kasım 1930.","alt_en":"Mustafa Kemal at Turhal station, 22 November 1930.","en_boy":0.8778,"kaynak":"https://commons.wikimedia.org/wiki/File:Atat%C3%BCrk_1930_Turhal_%C4%B0stasyonu.jpg","_kimlik":"galeri_turhal_istasyon_1930","_obek":"tarih","_kaynak_turu":"commons","_dayanak":"açıklama 'Mustafa Kemal at Turhal station, 1930' + tarih 1930-11-22"},{"url":"https://tarimportali.net/dosya/turkseker/galeri_turhal_ziyaret_1930.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_turhal_ziyaret_1930.jpg","atif":"Unknown photographer — Public domain","lisans":"Public domain","alt_tr":"Mustafa Kemal'in Turhal ziyareti, 22 Kasım 1930.","alt_en":"Mustafa Kemal's visit to Turhal, 22 November 1930.","en_boy":1.3274,"kaynak":"https://commons.wikimedia.org/wiki/File:Atat%C3%BCrk_1930_Turhal.jpg","_kimlik":"galeri_turhal_ziyaret_1930","_obek":"tarih","_kaynak_turu":"commons","_dayanak":"açıklama 'Mustafa Kemal's Turhal visit, 1930' + tarih 1930-11-22"},{"url":"https://tarimportali.net/dosya/turkseker/galeri_eskisehir_1934.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_eskisehir_1934.jpg","atif":"Seltundo26 — CC BY-SA 4.0","lisans":"CC BY-SA 4.0","alt_tr":"Eskişehir Şeker Fabrikası, 1934.","alt_en":"The Eskişehir sugar factory, 1934.","en_boy":1.7778,"kaynak":"https://commons.wikimedia.org/wiki/File:Eskisehir-seker-fabrikasi-90inci-kurulus-yilini-kutluyor-r3gk_cover_(1).webp","_kimlik":"galeri_eskisehir_1934","_obek":"tarih","_kaynak_turu":"commons","_dayanak":"Commons açıklama alanı birebir: '1934'. Künyedeki 2024-08-25 YÜKLEME tarihi."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_eskisehir_kart.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_eskisehir_kart.jpg","atif":"Seltundo26 — CC BY-SA 4.0","lisans":"CC BY-SA 4.0","alt_tr":"Eskişehir Şeker Fabrikası. Kaynak karenin tarihini kaydetmiyor.","alt_en":"The Eskişehir sugar factory. The source does not record when it was made.","en_boy":1.6168,"kaynak":"https://commons.wikimedia.org/wiki/File:Eski%C5%9Fehir-%C5%9Eeker-Fabrikas%C4%B1.jpg","_kimlik":"galeri_eskisehir_kart","_obek":"tarih","_kaynak_turu":"commons","_dayanak":"nesne_adi ve açıklama 'Eskişehir Şeker Fabrikası'. Künyedeki 2025-09-28 tarihi TARAMA/yükleme tarihi; kare eski bir basılı görüntü ve çekim tarihi kaynakta YOK."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_eskisehir.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_eskisehir.jpg","atif":"Eskişehir Şeker Fabrikası çizimi · AHESK033 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Eskişehir Şeker Fabrikası çizimi.","alt_en":"A drawing of the Eskişehir Sugar Factory.","en_boy":1.564,"kaynak":"https://archives.saltresearch.org/handle/123456789/236467","_kimlik":"galeri_salt_eskisehir","_obek":"tarih","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHESK033 (https://archives.saltresearch.org/handle/123456789/236467). Kaydın başlığı."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_hasat.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_hasat.jpg","atif":"Şeker pancarı tarlasında hasat yapılırken · AFDIVH215 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Şeker pancarı tarlasında hasat yapılırken. Fotokartın ön yüzünde “Fabrika için pancar toplanırken” yazıyor.","alt_en":"Harvesting in a sugar beet field. The front of the photocard reads “gathering beet for the factory”.","en_boy":1.5733,"kaynak":"https://archives.saltresearch.org/handle/123456789/196846","_kimlik":"galeri_salt_hasat","_obek":"tarla","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AFDIVH215 (https://archives.saltresearch.org/handle/123456789/196846). Kaydın başlığı."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_hasat_mektup.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_hasat_mektup.jpg","atif":"Şeker pancarı tarlasında hasat yapılırken · AFDIVH215 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Aynı fotokartın arka yüzü: Azize'nin ablası Betül'e mektubu.","alt_en":"The reverse of the same photocard: a letter from Azize to her sister Betül.","en_boy":0.6325,"kaynak":"https://archives.saltresearch.org/handle/123456789/196846","_kimlik":"galeri_salt_hasat_mektup","_obek":"tarla","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AFDIVH215 (https://archives.saltresearch.org/handle/123456789/196846). Kaydın başlığı."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_alb_personel.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_alb_personel.jpg","atif":"İstanbul ve Trakya Şeker Fabrikaları T.A.Ş. Alpullu Şeker ve İspirto Fabrikaları · 1928-1929 · AHTURAL013 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Alpullu Şeker ve İspirto Fabrikaları albümünden bir sayfa: Fabrikanın personeli ve yöneticiler. 1928-1929.","alt_en":"A page from the album of the Alpullu Sugar and Spirit Factories: Staff and administrators of the factory. 1928-1929.","en_boy":1.4559,"kaynak":"https://archives.saltresearch.org/handle/123456789/195731","_kimlik":"galeri_salt_alb_personel","_obek":"isci","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHTURAL013 (https://archives.saltresearch.org/handle/123456789/195731). Albüm sayfasının kendi açıklaması (dataItemFiles)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_alb_laboratuvar.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_alb_laboratuvar.jpg","atif":"İstanbul ve Trakya Şeker Fabrikaları T.A.Ş. Alpullu Şeker ve İspirto Fabrikaları · 1928-1929 · AHTURAL013 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Alpullu Şeker ve İspirto Fabrikaları albümünden bir sayfa: Fabrikanın laboratuvarı ve personeli. 1928-1929.","alt_en":"A page from the album of the Alpullu Sugar and Spirit Factories: Laboratory and staff of the factory. 1928-1929.","en_boy":1.4559,"kaynak":"https://archives.saltresearch.org/handle/123456789/195731","_kimlik":"galeri_salt_alb_laboratuvar","_obek":"isci","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHTURAL013 (https://archives.saltresearch.org/handle/123456789/195731). Albüm sayfasının kendi açıklaması (dataItemFiles)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_alb_personel2.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_alb_personel2.jpg","atif":"İstanbul ve Trakya Şeker Fabrikaları T.A.Ş. Alpullu Şeker ve İspirto Fabrikaları · 1928-1929 · AHTURAL013 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Alpullu Şeker ve İspirto Fabrikaları albümünden bir sayfa: Fabrika personeli. 1928-1929.","alt_en":"A page from the album of the Alpullu Sugar and Spirit Factories: Sections of the factory and staff. 1928-1929.","en_boy":1.4625,"kaynak":"https://archives.saltresearch.org/handle/123456789/195731","_kimlik":"galeri_salt_alb_personel2","_obek":"isci","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHTURAL013 (https://archives.saltresearch.org/handle/123456789/195731). Albüm sayfasının kendi açıklaması (dataItemFiles)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_usak_makine_isci.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_usak_makine_isci.jpg","atif":"Uşak Şeker Fabrikası'nın makine dairesi ve çalışanları · AHUSA007 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Uşak Şeker Fabrikası'nın makine dairesi ve çalışanları.","alt_en":"The engine room of the Uşak Sugar Factory and its workers.","en_boy":1.5267,"kaynak":"https://archives.saltresearch.org/handle/123456789/196978","_kimlik":"galeri_salt_usak_makine_isci","_obek":"isci","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHUSA007 (https://archives.saltresearch.org/handle/123456789/196978). Kaydın başlığı."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_vagon.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_vagon.jpg","atif":"Uşak Şeker Fabrikası'na gelen şeker pancarları vagonlardan aktarılırken · AHUSA006 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Uşak Şeker Fabrikası'na gelen şeker pancarları vagonlardan aktarılırken.","alt_en":"Sugar beet arriving at the Uşak Sugar Factory being transferred from railway wagons.","en_boy":1.5009,"kaynak":"https://archives.saltresearch.org/handle/123456789/196977","_kimlik":"galeri_salt_vagon","_obek":"yukleme","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHUSA006 (https://archives.saltresearch.org/handle/123456789/196977). Kaydın başlığı."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_silo.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_silo.jpg","atif":"Alpullu Şeker Fabrikası · AHKIR008 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Alpullu Şeker Fabrikası.","alt_en":"The Alpullu Sugar Factory.","en_boy":0.7194,"kaynak":"https://archives.saltresearch.org/handle/123456789/208326","_kimlik":"galeri_salt_silo","_obek":"yukleme","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHKIR008 (https://archives.saltresearch.org/handle/123456789/208326). Kaydın başlığı."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_silo_arka.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_silo_arka.jpg","atif":"Alpullu Şeker Fabrikası · AHKIR008 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Aynı fotoğrafın arka yüzü: “Pancar silolarının su tazyiki ile tahliyesi, Alpullu”.","alt_en":"The reverse of the same photograph: “emptying the beet silos by water pressure, Alpullu”.","en_boy":0.7225,"kaynak":"https://archives.saltresearch.org/handle/123456789/208326","_kimlik":"galeri_salt_silo_arka","_obek":"yukleme","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHKIR008 (https://archives.saltresearch.org/handle/123456789/208326). Kaydın başlığı."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_usak_pancar.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_usak_pancar.jpg","atif":"Uşak Şeker Fabrikası · AHUSA003 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Uşak Şeker Fabrikası.","alt_en":"The Uşak Sugar Factory.","en_boy":1.5873,"kaynak":"https://archives.saltresearch.org/handle/123456789/103306","_kimlik":"galeri_salt_usak_pancar","_obek":"yukleme","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHUSA003 (https://archives.saltresearch.org/handle/123456789/103306). Kaydın başlığı."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_fab_ankara.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_fab_ankara.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Ankara Şeker Fabrikası.","alt_en":"The Ankara sugar factory.","en_boy":1.4842,"kaynak":"https://www.turkseker.gov.tr/?ModulID=11&MenuID=57","_kimlik":"galeri_fab_ankara","_obek":"fabrikalar","_kaynak_turu":"kurum","_dayanak":"turkseker.gov.tr fabrika detay sayfasındaki başlık: 'Ankara Şeker Fabrikası'"},{"url":"https://tarimportali.net/dosya/turkseker/galeri_fab_agri.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_fab_agri.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Ağrı Şeker Fabrikası.","alt_en":"The Ağrı sugar factory.","en_boy":1.7778,"kaynak":"https://www.turkseker.gov.tr/?ModulID=11&MenuID=57","_kimlik":"galeri_fab_agri","_obek":"fabrikalar","_kaynak_turu":"kurum","_dayanak":"kurum sayfası başlığı"},{"url":"https://tarimportali.net/dosya/turkseker/galeri_fab_burdur.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_fab_burdur.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Burdur Şeker Fabrikası.","alt_en":"The Burdur sugar factory.","en_boy":1.7778,"kaynak":"https://www.turkseker.gov.tr/?ModulID=11&MenuID=57","_kimlik":"galeri_fab_burdur","_obek":"fabrikalar","_kaynak_turu":"kurum","_dayanak":"kurum sayfası başlığı"},{"url":"https://tarimportali.net/dosya/turkseker/galeri_fab_elazig.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_fab_elazig.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Elazığ Şeker Fabrikası.","alt_en":"The Elazığ sugar factory.","en_boy":1.514,"kaynak":"https://www.turkseker.gov.tr/?ModulID=11&MenuID=57","_kimlik":"galeri_fab_elazig","_obek":"fabrikalar","_kaynak_turu":"kurum","_dayanak":"kurum sayfası başlığı"},{"url":"https://tarimportali.net/dosya/turkseker/galeri_fab_ercis.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_fab_ercis.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Erciş Şeker Fabrikası.","alt_en":"The Erciş sugar factory.","en_boy":1.534,"kaynak":"https://www.turkseker.gov.tr/?ModulID=11&MenuID=57","_kimlik":"galeri_fab_ercis","_obek":"fabrikalar","_kaynak_turu":"kurum","_dayanak":"kurum sayfası başlığı"},{"url":"https://tarimportali.net/dosya/turkseker/galeri_fab_eregli.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_fab_eregli.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Ereğli Şeker Fabrikası.","alt_en":"The Ereğli sugar factory.","en_boy":1.7778,"kaynak":"https://www.turkseker.gov.tr/?ModulID=11&MenuID=57","_kimlik":"galeri_fab_eregli","_obek":"fabrikalar","_kaynak_turu":"kurum","_dayanak":"kurum sayfası başlığı"},{"url":"https://tarimportali.net/dosya/turkseker/galeri_fab_eskisehir.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_fab_eskisehir.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Eskişehir Şeker Fabrikası.","alt_en":"The Eskişehir sugar factory.","en_boy":1.5009,"kaynak":"https://www.turkseker.gov.tr/?ModulID=11&MenuID=57","_kimlik":"galeri_fab_eskisehir","_obek":"fabrikalar","_kaynak_turu":"kurum","_dayanak":"kurum sayfası başlığı"},{"url":"https://tarimportali.net/dosya/turkseker/galeri_fab_ilgin.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_fab_ilgin.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Ilgın Şeker Fabrikası.","alt_en":"The Ilgın sugar factory.","en_boy":1.5267,"kaynak":"https://www.turkseker.gov.tr/?ModulID=11&MenuID=57","_kimlik":"galeri_fab_ilgin","_obek":"fabrikalar","_kaynak_turu":"kurum","_dayanak":"kurum sayfası başlığı"},{"url":"https://tarimportali.net/dosya/turkseker/galeri_fab_kars.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_fab_kars.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Kars Şeker Fabrikası.","alt_en":"The Kars sugar factory.","en_boy":1.5009,"kaynak":"https://www.turkseker.gov.tr/?ModulID=11&MenuID=57","_kimlik":"galeri_fab_kars","_obek":"fabrikalar","_kaynak_turu":"kurum","_dayanak":"kurum sayfası başlığı"},{"url":"https://tarimportali.net/dosya/turkseker/galeri_fab_kastamonu.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_fab_kastamonu.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Kastamonu Şeker Fabrikası.","alt_en":"The Kastamonu sugar factory.","en_boy":1.4286,"kaynak":"https://www.turkseker.gov.tr/?ModulID=11&MenuID=57","_kimlik":"galeri_fab_kastamonu","_obek":"fabrikalar","_kaynak_turu":"kurum","_dayanak":"kurum sayfası başlığı"},{"url":"https://tarimportali.net/dosya/turkseker/galeri_fab_malatya.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_fab_malatya.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Malatya Şeker Fabrikası.","alt_en":"The Malatya sugar factory.","en_boy":2.4915,"kaynak":"https://www.turkseker.gov.tr/?ModulID=11&MenuID=57","_kimlik":"galeri_fab_malatya","_obek":"fabrikalar","_kaynak_turu":"kurum","_dayanak":"kurum sayfası başlığı"},{"url":"https://tarimportali.net/dosya/turkseker/galeri_fab_susurluk.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_fab_susurluk.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Susurluk Şeker Fabrikası.","alt_en":"The Susurluk sugar factory.","en_boy":1.4519,"kaynak":"https://www.turkseker.gov.tr/?ModulID=11&MenuID=57","_kimlik":"galeri_fab_susurluk","_obek":"fabrikalar","_kaynak_turu":"kurum","_dayanak":"kurum sayfası başlığı"},{"url":"https://tarimportali.net/dosya/turkseker/galeri_fab_usak.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_fab_usak.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Uşak Şeker Fabrikası.","alt_en":"The Uşak sugar factory.","en_boy":1.5009,"kaynak":"https://www.turkseker.gov.tr/?ModulID=11&MenuID=57","_kimlik":"galeri_fab_usak","_obek":"fabrikalar","_kaynak_turu":"kurum","_dayanak":"kurum sayfası başlığı"},{"url":"https://tarimportali.net/dosya/turkseker/galeri_fab_yozgat.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_fab_yozgat.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Yozgat Şeker Fabrikası.","alt_en":"The Yozgat sugar factory.","en_boy":1.5429,"kaynak":"https://www.turkseker.gov.tr/?ModulID=11&MenuID=57","_kimlik":"galeri_fab_yozgat","_obek":"fabrikalar","_kaynak_turu":"kurum","_dayanak":"kurum sayfası başlığı"},{"url":"https://tarimportali.net/dosya/turkseker/galeri_adapazari.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_adapazari.jpg","atif":"Acar54 — CC BY-SA 3.0","lisans":"CC BY-SA 3.0","alt_tr":"Adapazarı Şeker Fabrikası'nın giriş kapısı, 20 Mayıs 2016.","alt_en":"The entrance gate of the Adapazarı sugar factory, 20 May 2016.","en_boy":1.3333,"kaynak":"https://commons.wikimedia.org/wiki/File:Adapazar%C4%B1_%C5%9Eeker_Farikas%C4%B1.jpg","_kimlik":"galeri_adapazari","_obek":"fabrikalar","_kaynak_turu":"commons","_dayanak":"açıklama 'Adapazarı Şeker Farikası giriş kapısı.' + tarih 'according to Exif data' 20 May 2016"},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_usak_genel.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_usak_genel.jpg","atif":"Uşak Şeker Fabrikası · AHUSA004 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Uşak Şeker Fabrikası.","alt_en":"The Uşak Sugar Factory.","en_boy":1.4967,"kaynak":"https://archives.saltresearch.org/handle/123456789/97324","_kimlik":"galeri_salt_usak_genel","_obek":"fabrikalar","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHUSA004 (https://archives.saltresearch.org/handle/123456789/97324). Kaydın başlığı."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_usak_avlu.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_usak_avlu.jpg","atif":"Uşak Şeker Fabrikası · AHUSA004 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Uşak Şeker Fabrikası.","alt_en":"The Uşak Sugar Factory.","en_boy":1.4829,"kaynak":"https://archives.saltresearch.org/handle/123456789/97324","_kimlik":"galeri_salt_usak_avlu","_obek":"fabrikalar","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHUSA004 (https://archives.saltresearch.org/handle/123456789/97324). Kaydın başlığı."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_usak_kart.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_usak_kart.jpg","atif":"Uşak Şeker Fabrikası · AHUSA001 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Uşak Şeker Fabrikası.","alt_en":"The Uşak Sugar Factory.","en_boy":1.5889,"kaynak":"https://archives.saltresearch.org/handle/123456789/116005","_kimlik":"galeri_salt_usak_kart","_obek":"fabrikalar","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHUSA001 (https://archives.saltresearch.org/handle/123456789/116005). Kaydın başlığı."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_etim_fabrika.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_etim_fabrika.jpg","atif":"Etimesgut Şeker Fabrikası · AHANKA191 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Etimesgut Şeker Fabrikası. Etimesgut, Ankara.","alt_en":"The Etimesgut Sugar Factory, Ankara.","en_boy":1.3617,"kaynak":"https://archives.saltresearch.org/handle/123456789/196860","_kimlik":"galeri_salt_etim_fabrika","_obek":"fabrikalar","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHANKA191 (https://archives.saltresearch.org/handle/123456789/196860). Kaydın başlığı."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_turhal.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_turhal.jpg","atif":"Turhal Şeker Fabrikası · AHTOK001 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Turhal Şeker Fabrikası. Turhal, Tokat.","alt_en":"The Turhal Sugar Factory, Turhal, Tokat.","en_boy":1.5889,"kaynak":"https://archives.saltresearch.org/handle/123456789/105027","_kimlik":"galeri_salt_turhal","_obek":"fabrikalar","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHTOK001 (https://archives.saltresearch.org/handle/123456789/105027). Kaydın başlığı."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_alb_ic1.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_alb_ic1.jpg","atif":"İstanbul ve Trakya Şeker Fabrikaları T.A.Ş. Alpullu Şeker ve İspirto Fabrikaları · 1928-1929 · AHTURAL013 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Alpullu Şeker ve İspirto Fabrikaları albümünden bir sayfa: Fabrikanın iç mekânı ve personeli. 1928-1929.","alt_en":"A page from the album of the Alpullu Sugar and Spirit Factories: Interior of the factory and staff. 1928-1929.","en_boy":1.4532,"kaynak":"https://archives.saltresearch.org/handle/123456789/195731","_kimlik":"galeri_salt_alb_ic1","_obek":"fabrika_ici","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHTURAL013 (https://archives.saltresearch.org/handle/123456789/195731). Albüm sayfasının kendi açıklaması (dataItemFiles)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_alb_ic2.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_alb_ic2.jpg","atif":"İstanbul ve Trakya Şeker Fabrikaları T.A.Ş. Alpullu Şeker ve İspirto Fabrikaları · 1928-1929 · AHTURAL013 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Alpullu Şeker ve İspirto Fabrikaları albümünden bir sayfa: Fabrikanın iç mekânı ve personeli. 1928-1929.","alt_en":"A page from the album of the Alpullu Sugar and Spirit Factories: Interior of the factory and staff. 1928-1929.","en_boy":1.448,"kaynak":"https://archives.saltresearch.org/handle/123456789/195731","_kimlik":"galeri_salt_alb_ic2","_obek":"fabrika_ici","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHTURAL013 (https://archives.saltresearch.org/handle/123456789/195731). Albüm sayfasının kendi açıklaması (dataItemFiles)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_alb_ic3.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_alb_ic3.jpg","atif":"İstanbul ve Trakya Şeker Fabrikaları T.A.Ş. Alpullu Şeker ve İspirto Fabrikaları · 1928-1929 · AHTURAL013 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Alpullu Şeker ve İspirto Fabrikaları albümünden bir sayfa: Fabrikanın iç mekânı. 1928-1929.","alt_en":"A page from the album of the Alpullu Sugar and Spirit Factories: Interior of the factory. 1928-1929.","en_boy":1.4519,"kaynak":"https://archives.saltresearch.org/handle/123456789/195731","_kimlik":"galeri_salt_alb_ic3","_obek":"fabrika_ici","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHTURAL013 (https://archives.saltresearch.org/handle/123456789/195731). Albüm sayfasının kendi açıklaması (dataItemFiles)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_usak_salon1.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_usak_salon1.jpg","atif":"Uşak Şeker Fabrikası · AHUSA004 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Uşak Şeker Fabrikası.","alt_en":"The Uşak Sugar Factory.","en_boy":1.4911,"kaynak":"https://archives.saltresearch.org/handle/123456789/97324","_kimlik":"galeri_salt_usak_salon1","_obek":"fabrika_ici","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHUSA004 (https://archives.saltresearch.org/handle/123456789/97324). Kaydın başlığı."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_usak_salon2.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_usak_salon2.jpg","atif":"Uşak Şeker Fabrikası · AHUSA004 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Uşak Şeker Fabrikası.","alt_en":"The Uşak Sugar Factory.","en_boy":1.4995,"kaynak":"https://archives.saltresearch.org/handle/123456789/97324","_kimlik":"galeri_salt_usak_salon2","_obek":"fabrika_ici","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHUSA004 (https://archives.saltresearch.org/handle/123456789/97324). Kaydın başlığı."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_usak_salon3.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_usak_salon3.jpg","atif":"Uşak Şeker Fabrikası · AHUSA004 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Uşak Şeker Fabrikası.","alt_en":"The Uşak Sugar Factory.","en_boy":1.4981,"kaynak":"https://archives.saltresearch.org/handle/123456789/97324","_kimlik":"galeri_salt_usak_salon3","_obek":"fabrika_ici","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHUSA004 (https://archives.saltresearch.org/handle/123456789/97324). Kaydın başlığı."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_usak_makine.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_usak_makine.jpg","atif":"Uşak Şeker Fabrikası'nın makine dairesi · AHUSA008 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Uşak Şeker Fabrikası'nın makine dairesi.","alt_en":"The engine room of the Uşak Sugar Factory.","en_boy":1.5564,"kaynak":"https://archives.saltresearch.org/handle/123456789/196979","_kimlik":"galeri_salt_usak_makine","_obek":"fabrika_ici","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHUSA008 (https://archives.saltresearch.org/handle/123456789/196979). Kaydın başlığı."},{"url":"https://tarimportali.net/dosya/turkseker/turkseker_s06_makine.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/turkseker_s06_makine.jpg","atif":"İstanbul ve Trakya Şeker Fabrikaları T.A.Ş. Alpullu Şeker ve İspirto Fabrikaları · 1928-1929 · AHTURAL013 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Alpullu Şeker ve İspirto Fabrikaları albümünden bir sayfa: Fabrikanın iç mekânı ve personeli. 1928-1929.","alt_en":"A page from the album of the Alpullu Sugar and Spirit Factories: Interior of the factory and staff. 1928-1929.","en_boy":1.4506,"kaynak":"https://archives.saltresearch.org/handle/123456789/195731","_kimlik":"galeri_turkseker_s06_makine","_obek":"fabrika_ici","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHTURAL013 (https://archives.saltresearch.org/handle/123456789/195731). Albüm sayfasının kendi açıklaması (dataItemFiles). §6 bölüm görseliyken kullanıcı kararıyla galeriye taşındı."},{"url":"https://tarimportali.net/dosya/turkseker/turkseker_s11_tohum.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/turkseker_s11_tohum.jpg","atif":"İstanbul ve Trakya Şeker Fabrikaları T.A.Ş. Alpullu Şeker ve İspirto Fabrikaları · 1928-1929 · AHTURAL013 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Alpullu Şeker ve İspirto Fabrikaları albümünden bir sayfa: Fabrikanın bölümleri ve personeli. 1928-1929.","alt_en":"A page from the album of the Alpullu Sugar and Spirit Factories: Sections of the factory and staff. 1928-1929.","en_boy":1.4506,"kaynak":"https://archives.saltresearch.org/handle/123456789/195731","_kimlik":"galeri_turkseker_s11_tohum","_obek":"fabrika_ici","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHTURAL013 (https://archives.saltresearch.org/handle/123456789/195731). Albüm sayfasının kendi açıklaması (dataItemFiles). §11 bölüm görseliyken kullanıcı kararıyla galeriye taşındı."},{"url":"https://tarimportali.net/dosya/turkseker/turkseker_s14_uydu.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/turkseker_s14_uydu.jpg","atif":"Uşak Şeker Fabrikası · AHUSA004 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Uşak Şeker Fabrikası.","alt_en":"The Uşak Sugar Factory.","en_boy":1.4967,"kaynak":"https://archives.saltresearch.org/handle/123456789/97324","_kimlik":"galeri_turkseker_s14_uydu","_obek":"fabrika_ici","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHUSA004 (https://archives.saltresearch.org/handle/123456789/97324). Kaydın başlığı. §14 bölüm görseliyken kullanıcı kararıyla galeriye taşındı."},{"url":"https://tarimportali.net/dosya/turkseker/turkseker_s18_yatirim.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/turkseker_s18_yatirim.jpg","atif":"Uşak Şeker Fabrikası · AHUSA004 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Uşak Şeker Fabrikası.","alt_en":"The Uşak Sugar Factory.","en_boy":1.4884,"kaynak":"https://archives.saltresearch.org/handle/123456789/97324","_kimlik":"galeri_turkseker_s18_yatirim","_obek":"fabrika_ici","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHUSA004 (https://archives.saltresearch.org/handle/123456789/97324). Kaydın başlığı. §18 bölüm görseliyken kullanıcı kararıyla galeriye taşındı."},{"url":"https://tarimportali.net/dosya/turkseker/turkseker_s20_enerji.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/turkseker_s20_enerji.jpg","atif":"İstanbul ve Trakya Şeker Fabrikaları T.A.Ş. Alpullu Şeker ve İspirto Fabrikaları · 1928-1929 · AHTURAL013 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Alpullu Şeker ve İspirto Fabrikaları albümünden bir sayfa: Fabrikanın iç mekânı. 1928-1929.","alt_en":"A page from the album of the Alpullu Sugar and Spirit Factories: Interior of the factory and staff. 1928-1929.","en_boy":1.4506,"kaynak":"https://archives.saltresearch.org/handle/123456789/195731","_kimlik":"galeri_turkseker_s20_enerji","_obek":"fabrika_ici","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHTURAL013 (https://archives.saltresearch.org/handle/123456789/195731). Albüm sayfasının kendi açıklaması (dataItemFiles). §20 bölüm görseliyken kullanıcı kararıyla galeriye taşındı."},{"url":"https://tarimportali.net/dosya/turkseker/turkseker_s21_deprem.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/turkseker_s21_deprem.jpg","atif":"İstanbul ve Trakya Şeker Fabrikaları T.A.Ş. Alpullu Şeker ve İspirto Fabrikaları · 1928-1929 · AHTURAL013 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Alpullu Şeker ve İspirto Fabrikaları albümünden bir sayfa: Fabrikanın iç mekânı. 1928-1929.","alt_en":"A page from the album of the Alpullu Sugar and Spirit Factories: Interior of the factory. 1928-1929.","en_boy":1.4453,"kaynak":"https://archives.saltresearch.org/handle/123456789/195731","_kimlik":"galeri_turkseker_s21_deprem","_obek":"fabrika_ici","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHTURAL013 (https://archives.saltresearch.org/handle/123456789/195731). Albüm sayfasının kendi açıklaması (dataItemFiles). §21 bölüm görseliyken kullanıcı kararıyla galeriye taşındı."},{"url":"https://tarimportali.net/dosya/turkseker/turkseker_s25_rolyef.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/turkseker_s25_rolyef.jpg","atif":"Turhal Şeker Fabrikası · AHTOK001 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Turhal Şeker Fabrikası kartpostalının arka yüzü. Turhal, Tokat.","alt_en":"The reverse of a postcard of the Turhal Sugar Factory. Turhal, Tokat.","en_boy":1.5905,"kaynak":"https://archives.saltresearch.org/handle/123456789/105027","_kimlik":"galeri_turkseker_s25_rolyef","_obek":"fabrika_ici","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHTOK001 (https://archives.saltresearch.org/handle/123456789/105027). Kaydın başlığı; dosya kaydın ikinci belgesi (arka yüz). §25 bölüm görseliyken kullanıcı kararıyla galeriye taşındı."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_mak_ankara.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_mak_ankara.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Ankara Makine Fabrikası.","alt_en":"The Ankara machine factory.","en_boy":1.4995,"kaynak":"https://www.turkseker.gov.tr/?ModulID=11&MenuID=57","_kimlik":"galeri_mak_ankara","_obek":"kendi_makinesi","_kaynak_turu":"kurum","_dayanak":"kurum sayfası başlığı"},{"url":"https://tarimportali.net/dosya/turkseker/galeri_mak_eskisehir.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_mak_eskisehir.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Eskişehir Makine Fabrikası.","alt_en":"The Eskişehir machine factory.","en_boy":1.7778,"kaynak":"https://www.turkseker.gov.tr/?ModulID=11&MenuID=57","_kimlik":"galeri_mak_eskisehir","_obek":"kendi_makinesi","_kaynak_turu":"kurum","_dayanak":"kurum sayfası başlığı"},{"url":"https://tarimportali.net/dosya/turkseker/galeri_mak_turhal.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_mak_turhal.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Turhal Makine Fabrikası.","alt_en":"The Turhal machine factory.","en_boy":1.7778,"kaynak":"https://www.turkseker.gov.tr/?ModulID=11&MenuID=57","_kimlik":"galeri_mak_turhal","_obek":"kendi_makinesi","_kaynak_turu":"kurum","_dayanak":"kurum sayfası başlığı"},{"url":"https://tarimportali.net/dosya/turkseker/galeri_mak_elektromekanik.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_mak_elektromekanik.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Elektromekanik Aygıtlar Fabrikası.","alt_en":"The Electromechanical Devices factory.","en_boy":1.4995,"kaynak":"https://www.turkseker.gov.tr/?ModulID=11&MenuID=57","_kimlik":"galeri_mak_elektromekanik","_obek":"kendi_makinesi","_kaynak_turu":"kurum","_dayanak":"kurum sayfası başlığı"},{"url":"https://tarimportali.net/dosya/turkseker/galeri_enstitu.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_enstitu.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Şeker Enstitüsü.","alt_en":"The Sugar Institute.","en_boy":1.4995,"kaynak":"https://www.turkseker.gov.tr/?ModulID=11&MenuID=57","_kimlik":"galeri_enstitu","_obek":"kendi_makinesi","_kaynak_turu":"kurum","_dayanak":"kurum sayfası başlığı"},{"url":"https://tarimportali.net/dosya/turkseker/galeri_seker_sokak_1.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_seker_sokak_1.jpg","atif":"Dosseman — CC BY-SA 4.0","lisans":"CC BY-SA 4.0","alt_tr":"Eskişehir'de Şeker Sokak çevresi, 18 Aralık 2007.","alt_en":"The Şeker Sokak area in Eskişehir, 18 December 2007.","en_boy":1.5052,"kaynak":"https://commons.wikimedia.org/wiki/File:Eski%C5%9Fehir_%C5%9Eeker_Sokak_area_Old_situation_in_2007_1780.jpg","_kimlik":"galeri_seker_sokak_1","_obek":"cevresi","_kaynak_turu":"commons","_dayanak":"nesne_adi 'Eskişehir Şeker Sokak area Old situation in 2007 1780' + tarih 2007-12-18"},{"url":"https://tarimportali.net/dosya/turkseker/galeri_seker_sokak_2.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_seker_sokak_2.jpg","atif":"Dosseman — CC BY-SA 4.0","lisans":"CC BY-SA 4.0","alt_tr":"Eskişehir'de Şeker Sokak çevresi, 18 Aralık 2007.","alt_en":"The Şeker Sokak area in Eskişehir, 18 December 2007.","en_boy":1.5052,"kaynak":"https://commons.wikimedia.org/wiki/File:Eski%C5%9Fehir_%C5%9Eeker_Sokak_area_Old_situation_in_2007_1782.jpg","_kimlik":"galeri_seker_sokak_2","_obek":"cevresi","_kaynak_turu":"commons","_dayanak":"nesne_adi '… 1782' + tarih 2007-12-18"},{"url":"https://tarimportali.net/dosya/turkseker/galeri_etimesgut_lojman.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_etimesgut_lojman.jpg","atif":"Balışeyh71 — CC0","lisans":"CC0","alt_tr":"Ankara Şeker Fabrikası yerleşkesinde yıkım sürecine giren B tipi lojman. Etimesgut, Ankara, 16 Şubat 2026.","alt_en":"A type-B staff house on the Ankara sugar factory estate, under demolition. Etimesgut, Ankara, 16 February 2026.","en_boy":0.75,"kaynak":"https://commons.wikimedia.org/wiki/File:Etimesgut_Seker_Fabrikasi_B_Tipi_Lojman_Yikimi_2026.jpg","_kimlik":"galeri_etimesgut_lojman","_obek":"cevresi","_kaynak_turu":"commons","_dayanak":"açıklama: 'Etimesgut Havalimanı genişletme çalışmaları kapsamında yıkım sürecine girmiş olan, Ankara Şeker Fabrikası yerleşkesindeki tarihi B tipi lojman binası' + tarih 2026-02-16"},{"url":"https://tarimportali.net/dosya/turkseker/galeri_etimesgut_cay.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_etimesgut_cay.jpg","atif":"Balışeyh71 — CC0","lisans":"CC0","alt_tr":"Ankara Şeker Fabrikası yerleşkesinin yıkıma uğrayan çay bahçesi. Etimesgut, Ankara, 6 Kasım 2025.","alt_en":"The demolished tea garden of the Ankara sugar factory estate. Etimesgut, Ankara, 6 November 2025.","en_boy":1.3333,"kaynak":"https://commons.wikimedia.org/wiki/File:Etimesgut_Seker_Fabrikasi_Cay_Bahces%C4%B1_Yikimi_2026.jpg","_kimlik":"galeri_etimesgut_cay","_obek":"cevresi","_kaynak_turu":"commons","_dayanak":"açıklama: 'Etimesgut Havalimanı genişletme çalışmaları kapsamında, Ankara Şeker Fabrikası yerleşkesinde yıkıma uğrayan tarihi çay bahçesi ve çevreleyen ağaçlık alan' + tarih 06.11.2025"},{"url":"https://tarimportali.net/dosya/turkseker/galeri_etimesgut_lojmanlar.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_etimesgut_lojmanlar.jpg","atif":"Balışeyh71 — CC0","lisans":"CC0","alt_tr":"Ankara Şeker Fabrikası lojmanlarının yıkıldığı alan. Etimesgut, Ankara, 4 Ocak 2026.","alt_en":"The site where the Ankara sugar factory staff houses stood. Etimesgut, Ankara, 4 January 2026.","en_boy":1.3333,"kaynak":"https://commons.wikimedia.org/wiki/File:Etimesgut_Seker_Fabrikasi_Lojmanlari_Yikimii_2026.jpg","_kimlik":"galeri_etimesgut_lojmanlar","_obek":"cevresi","_kaynak_turu":"commons","_dayanak":"açıklama: 'Ankara'nın Etimesgut ilçesinde, Etimesgut Havalimanı pist uzatma ve altyapı çalışmaları nedeniyle yıkılan Ankara Şeker Fabrikası lojmanları…' + tarih 04.01.2026"},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_usak_havuz.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_usak_havuz.jpg","atif":"Uşak Şeker Fabrikası Sosyal Tesisleri · AHUSA002 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Uşak Şeker Fabrikası Sosyal Tesisleri.","alt_en":"The social facilities of the Uşak Sugar Factory.","en_boy":0.6369,"kaynak":"https://archives.saltresearch.org/handle/123456789/117021","_kimlik":"galeri_salt_usak_havuz","_obek":"cevresi","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHUSA002 (https://archives.saltresearch.org/handle/123456789/117021). Kaydın başlığı."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_etim_2.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_etim_2.jpg","atif":"Türkiye Şeker Fabrikası Etimesgut Kompleksi'ne dair fotoğraflar · Ali Mukbil Gökdoğan · TMGH007 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Türkiye Şeker Fabrikası Etimesgut Kompleksi'ne dair fotoğraflar Ali Mukbil Gökdoğan fotoğrafı. Etimesgut, Ankara.","alt_en":"Photographs of the Etimesgut Complex of Türkiye Şeker Fabrikası. Photograph by Ali Mukbil Gökdoğan. Etimesgut, Ankara.","en_boy":1.4109,"kaynak":"https://archives.saltresearch.org/handle/123456789/215423","_kimlik":"galeri_salt_etim_2","_obek":"cevresi","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı TMGH007 (https://archives.saltresearch.org/handle/123456789/215423). Kaydın başlığı."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_etim_3.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_etim_3.jpg","atif":"Türkiye Şeker Fabrikası Etimesgut Kompleksi'ne dair fotoğraflar · Ali Mukbil Gökdoğan · TMGH007 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Türkiye Şeker Fabrikası Etimesgut Kompleksi'ne dair fotoğraflar Ali Mukbil Gökdoğan fotoğrafı. Etimesgut, Ankara.","alt_en":"Photographs of the Etimesgut Complex of Türkiye Şeker Fabrikası. Photograph by Ali Mukbil Gökdoğan. Etimesgut, Ankara.","en_boy":1.4072,"kaynak":"https://archives.saltresearch.org/handle/123456789/215423","_kimlik":"galeri_salt_etim_3","_obek":"cevresi","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı TMGH007 (https://archives.saltresearch.org/handle/123456789/215423). Kaydın başlığı."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_etim_4.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_etim_4.jpg","atif":"Türkiye Şeker Fabrikası Etimesgut Kompleksi'ne dair fotoğraflar · Ali Mukbil Gökdoğan · TMGH007 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Türkiye Şeker Fabrikası Etimesgut Kompleksi'ne dair fotoğraflar Ali Mukbil Gökdoğan fotoğrafı. Etimesgut, Ankara.","alt_en":"Photographs of the Etimesgut Complex of Türkiye Şeker Fabrikası. Photograph by Ali Mukbil Gökdoğan. Etimesgut, Ankara.","en_boy":1.4134,"kaynak":"https://archives.saltresearch.org/handle/123456789/215423","_kimlik":"galeri_salt_etim_4","_obek":"cevresi","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı TMGH007 (https://archives.saltresearch.org/handle/123456789/215423). Kaydın başlığı."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_etim_5.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_etim_5.jpg","atif":"Türkiye Şeker Fabrikası Etimesgut Kompleksi'ne dair fotoğraflar · Ali Mukbil Gökdoğan · TMGH007 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Türkiye Şeker Fabrikası Etimesgut Kompleksi'ne dair fotoğraflar Ali Mukbil Gökdoğan fotoğrafı. Etimesgut, Ankara.","alt_en":"Photographs of the Etimesgut Complex of Türkiye Şeker Fabrikası. Photograph by Ali Mukbil Gökdoğan. Etimesgut, Ankara.","en_boy":1.3962,"kaynak":"https://archives.saltresearch.org/handle/123456789/215423","_kimlik":"galeri_salt_etim_5","_obek":"cevresi","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı TMGH007 (https://archives.saltresearch.org/handle/123456789/215423). Kaydın başlığı."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_etim_6.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_etim_6.jpg","atif":"Türkiye Şeker Fabrikası Etimesgut Kompleksi'ne dair fotoğraflar · Ali Mukbil Gökdoğan · TMGH007 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Türkiye Şeker Fabrikası Etimesgut Kompleksi'ne dair fotoğraflar Ali Mukbil Gökdoğan fotoğrafı. Etimesgut, Ankara.","alt_en":"Photographs of the Etimesgut Complex of Türkiye Şeker Fabrikası. Photograph by Ali Mukbil Gökdoğan. Etimesgut, Ankara.","en_boy":1.4911,"kaynak":"https://archives.saltresearch.org/handle/123456789/215423","_kimlik":"galeri_salt_etim_6","_obek":"cevresi","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı TMGH007 (https://archives.saltresearch.org/handle/123456789/215423). Kaydın başlığı."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_etim_7.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_etim_7.jpg","atif":"Türkiye Şeker Fabrikası Etimesgut Kompleksi'ne dair fotoğraflar · Ali Mukbil Gökdoğan · TMGH007 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Türkiye Şeker Fabrikası Etimesgut Kompleksi'ne dair fotoğraflar Ali Mukbil Gökdoğan fotoğrafı. Etimesgut, Ankara.","alt_en":"Photographs of the Etimesgut Complex of Türkiye Şeker Fabrikası. Photograph by Ali Mukbil Gökdoğan. Etimesgut, Ankara.","en_boy":1.4324,"kaynak":"https://archives.saltresearch.org/handle/123456789/215423","_kimlik":"galeri_salt_etim_7","_obek":"cevresi","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı TMGH007 (https://archives.saltresearch.org/handle/123456789/215423). Kaydın başlığı."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_alb_010.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_alb_010.jpg","atif":"İstanbul ve Trakya Şeker Fabrikaları T.A.Ş. Alpullu Şeker ve İspirto Fabrikaları · 1928-1929 · AHTURAL013 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Alpullu Şeker ve İspirto Fabrikaları albümünden bir sayfa: Alpullu Şeker Fabrikası'nın genel görünümü. 1928-1929.","alt_en":"A page from the album of the Alpullu Sugar and Spirit Factories: General view of the Alpullu Sugar Factory. 1928-1929.","en_boy":1.4545,"kaynak":"https://archives.saltresearch.org/handle/123456789/195731","_kimlik":"galeri_salt_alb_010","_obek":"alpullu","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHTURAL013 (https://archives.saltresearch.org/handle/123456789/195731). Albüm sayfasının kendi açıklaması (dataItemFiles)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_alb_013.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_alb_013.jpg","atif":"İstanbul ve Trakya Şeker Fabrikaları T.A.Ş. Alpullu Şeker ve İspirto Fabrikaları · 1928-1929 · AHTURAL013 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Alpullu Şeker ve İspirto Fabrikaları albümünden bir sayfa: Alpullu İspirto Fabrikası. 1928-1929.","alt_en":"A page from the album of the Alpullu Sugar and Spirit Factories: The Alpullu Spirit Factory. 1928-1929.","en_boy":1.4506,"kaynak":"https://archives.saltresearch.org/handle/123456789/195731","_kimlik":"galeri_salt_alb_013","_obek":"alpullu","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHTURAL013 (https://archives.saltresearch.org/handle/123456789/195731). Albüm sayfasının kendi açıklaması (dataItemFiles)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_alpullu_peron_4.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_alpullu_peron_4.jpg","atif":"CeeGee — CC BY-SA 4.0","lisans":"CC BY-SA 4.0","alt_tr":"Alpullu tren istasyonu, Babaeski, Kırklareli, 4 Ağustos 2018.","alt_en":"Alpullu railway station, Babaeski, Kırklareli, 4 August 2018.","en_boy":1.5094,"kaynak":"https://commons.wikimedia.org/wiki/File:AlpulluTrainStation_(4).jpg","_kimlik":"galeri_alpullu_peron_4","_obek":"alpullu","_kaynak_turu":"commons","_dayanak":"Commons künyesi: nesne_adi 'AlpulluTrainStation (4)' + açıklama 'Alpullu train station in Babaeski, Kırklareli Province, Turkey.' + tarih 2018-08-04 12:31:52."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_alpullu_peron_6.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_alpullu_peron_6.jpg","atif":"CeeGee — CC BY-SA 4.0","lisans":"CC BY-SA 4.0","alt_tr":"Alpullu tren istasyonu, Babaeski, Kırklareli, 4 Ağustos 2018.","alt_en":"Alpullu railway station, Babaeski, Kırklareli, 4 August 2018.","en_boy":0.6625,"kaynak":"https://commons.wikimedia.org/wiki/File:AlpulluTrainStation_(6).jpg","_kimlik":"galeri_alpullu_peron_6","_obek":"alpullu","_kaynak_turu":"commons","_dayanak":"Commons künyesi: nesne_adi 'AlpulluTrainStation (6)' + açıklama 'Alpullu train station in Babaeski, Kırklareli Province, Turkey.' + tarih 2018-08-04 16:19:01."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_kurum_rolyef_2.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_kurum_rolyef_2.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"1934'te Turhal Şeker Fabrikası'nın açılışı için yapılan ahşap rölyefin kuruma teslimi, 31 Mart 2026.","alt_en":"The wooden relief made for the 1934 opening of the Turhal Sugar Factory being handed back to the company, 31 March 2026.","en_boy":1.5015,"kaynak":"https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=5127","_kimlik":"galeri_kurum_rolyef_2","_obek":"tarih","_kaynak_turu":"kurum","_dayanak":"turkseker.gov.tr haberi 5127 (https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=5127); haberin başlığı ve tarihi."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_kurum_tohum_avuc.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_kurum_tohum_avuc.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"İlk yerli şeker pancarı tohumlarının hasadı, 6 Ağustos 2024.","alt_en":"The harvest of the first domestically bred sugar beet seed, 6 August 2024.","en_boy":1.5022,"kaynak":"https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=1077","_kimlik":"galeri_kurum_tohum_avuc","_obek":"tarla","_kaynak_turu":"kurum","_dayanak":"turkseker.gov.tr haberi 1077 (https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=1077); haberin başlığı ve tarihi."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_kurum_tohum_bitki.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_kurum_tohum_bitki.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"İlk yerli şeker pancarı tohumlarının hasadı, 6 Ağustos 2024.","alt_en":"The harvest of the first domestically bred sugar beet seed, 6 August 2024.","en_boy":1.5015,"kaynak":"https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=1077","_kimlik":"galeri_kurum_tohum_bitki","_obek":"tarla","_kaynak_turu":"kurum","_dayanak":"turkseker.gov.tr haberi 1077 (https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=1077); haberin başlığı ve tarihi."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_kurum_tohum_ciftci.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_kurum_tohum_ciftci.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Sezonun ilk pancar tohumunun ekimi, 18 Şubat 2022.","alt_en":"The sowing of the season's first beet seed, 18 February 2022.","en_boy":1.2656,"kaynak":"https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=71","_kimlik":"galeri_kurum_tohum_ciftci","_obek":"tarla","_kaynak_turu":"kurum","_dayanak":"turkseker.gov.tr haberi 71 (https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=71); haberin başlığı ve tarihi."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_kurum_haymana_2.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_kurum_haymana_2.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"TÜRKŞEKER'in Haymana'da çiftçilerle buluşması, 5 Ağustos 2026.","alt_en":"TÜRKŞEKER meeting farmers at Haymana, 5 August 2026.","en_boy":1.5015,"kaynak":"https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=5132","_kimlik":"galeri_kurum_haymana_2","_obek":"tarla","_kaynak_turu":"kurum","_dayanak":"turkseker.gov.tr haberi 5132 (https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=5132); haberin başlığı ve tarihi."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_alb_003.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_alb_003.jpg","atif":"İstanbul ve Trakya Şeker Fabrikaları T.A.Ş. Alpullu Şeker ve İspirto Fabrikaları · 1928-1929 · AHTURAL013 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Alpullu Şeker ve İspirto Fabrikaları albümünden bir sayfa: Bir yönetici. 1928-1929.","alt_en":"A page from the album of the Alpullu Sugar and Spirit Factories: An administrator. 1928-1929.","en_boy":1.4559,"kaynak":"https://archives.saltresearch.org/handle/123456789/195731","_kimlik":"galeri_salt_alb_003","_obek":"isci","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHTURAL013 (https://archives.saltresearch.org/handle/123456789/195731). Albüm sayfasının kendi açıklaması (dataItemFiles)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_alb_015.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_alb_015.jpg","atif":"İstanbul ve Trakya Şeker Fabrikaları T.A.Ş. Alpullu Şeker ve İspirto Fabrikaları · 1928-1929 · AHTURAL013 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Alpullu Şeker ve İspirto Fabrikaları albümünden bir sayfa: Fabrikanın personeli ve yöneticiler. 1928-1929.","alt_en":"A page from the album of the Alpullu Sugar and Spirit Factories: Staff and administrators of the factory. 1928-1929.","en_boy":1.4519,"kaynak":"https://archives.saltresearch.org/handle/123456789/195731","_kimlik":"galeri_salt_alb_015","_obek":"isci","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHTURAL013 (https://archives.saltresearch.org/handle/123456789/195731). Albüm sayfasının kendi açıklaması (dataItemFiles)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_alb_017.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_alb_017.jpg","atif":"İstanbul ve Trakya Şeker Fabrikaları T.A.Ş. Alpullu Şeker ve İspirto Fabrikaları · 1928-1929 · AHTURAL013 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Alpullu Şeker ve İspirto Fabrikaları albümünden bir sayfa: Fabrikanın personeli ve yöneticiler. 1928-1929.","alt_en":"A page from the album of the Alpullu Sugar and Spirit Factories: Staff and administrators of the factory. 1928-1929.","en_boy":1.4532,"kaynak":"https://archives.saltresearch.org/handle/123456789/195731","_kimlik":"galeri_salt_alb_017","_obek":"isci","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHTURAL013 (https://archives.saltresearch.org/handle/123456789/195731). Albüm sayfasının kendi açıklaması (dataItemFiles)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_alb_018.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_alb_018.jpg","atif":"İstanbul ve Trakya Şeker Fabrikaları T.A.Ş. Alpullu Şeker ve İspirto Fabrikaları · 1928-1929 · AHTURAL013 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Alpullu Şeker ve İspirto Fabrikaları albümünden bir sayfa: Fabrikanın personeli ve yöneticiler. 1928-1929.","alt_en":"A page from the album of the Alpullu Sugar and Spirit Factories: Staff and administrators of the factory. 1928-1929.","en_boy":1.4519,"kaynak":"https://archives.saltresearch.org/handle/123456789/195731","_kimlik":"galeri_salt_alb_018","_obek":"isci","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHTURAL013 (https://archives.saltresearch.org/handle/123456789/195731). Albüm sayfasının kendi açıklaması (dataItemFiles)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_alb_019.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_alb_019.jpg","atif":"İstanbul ve Trakya Şeker Fabrikaları T.A.Ş. Alpullu Şeker ve İspirto Fabrikaları · 1928-1929 · AHTURAL013 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Alpullu Şeker ve İspirto Fabrikaları albümünden bir sayfa: Fabrikanın personeli ve yöneticiler. 1928-1929.","alt_en":"A page from the album of the Alpullu Sugar and Spirit Factories: Staff and administrators of the factory. 1928-1929.","en_boy":1.4532,"kaynak":"https://archives.saltresearch.org/handle/123456789/195731","_kimlik":"galeri_salt_alb_019","_obek":"isci","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHTURAL013 (https://archives.saltresearch.org/handle/123456789/195731). Albüm sayfasının kendi açıklaması (dataItemFiles)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_alb_045.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_alb_045.jpg","atif":"İstanbul ve Trakya Şeker Fabrikaları T.A.Ş. Alpullu Şeker ve İspirto Fabrikaları · 1928-1929 · AHTURAL013 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Alpullu Şeker ve İspirto Fabrikaları albümünden bir sayfa: Fabrika personeli. 1928-1929.","alt_en":"A page from the album of the Alpullu Sugar and Spirit Factories: Staff of the factory. 1928-1929.","en_boy":1.448,"kaynak":"https://archives.saltresearch.org/handle/123456789/195731","_kimlik":"galeri_salt_alb_045","_obek":"isci","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHTURAL013 (https://archives.saltresearch.org/handle/123456789/195731). Albüm sayfasının kendi açıklaması (dataItemFiles)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_usak_makine_isci_arka.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_usak_makine_isci_arka.jpg","atif":"Uşak Şeker Fabrikası'nın makine dairesi ve çalışanları · AHUSA007 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Uşak Şeker Fabrikası'nın makine dairesini ve çalışanlarını gösteren fotokartın arka yüzü: Trabzon'a gönderilmiş bir mektup.","alt_en":"The reverse of the photocard showing the engine room of the Uşak Sugar Factory and its workers: a letter sent to Trabzon.","en_boy":1.5278,"kaynak":"https://archives.saltresearch.org/handle/123456789/196978","_kimlik":"galeri_salt_usak_makine_isci_arka","_obek":"isci","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHUSA007 (https://archives.saltresearch.org/handle/123456789/196978). Kaydın başlığı; dosya kaydın ikinci belgesi."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_kurum_laboratuvar_2.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_kurum_laboratuvar_2.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Kâzım Taşkent Eskişehir Şeker Fabrikası'nın laboratuvarı, 21 Eylül 2026.","alt_en":"The laboratory of the Kâzım Taşkent Eskişehir Sugar Factory, 21 September 2026.","en_boy":1.3333,"kaynak":"https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=5138","_kimlik":"galeri_kurum_laboratuvar_2","_obek":"isci","_kaynak_turu":"kurum","_dayanak":"turkseker.gov.tr haberi 5138 (https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=5138); haberin başlığı ve tarihi."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_kurum_pancar_bandi.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_kurum_pancar_bandi.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Kâzım Taşkent Eskişehir Şeker Fabrikası'nda pancar numune hattı, 21 Eylül 2026.","alt_en":"The beet sampling line at the Kâzım Taşkent Eskişehir Sugar Factory, 21 September 2026.","en_boy":1.3333,"kaynak":"https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=5138","_kimlik":"galeri_kurum_pancar_bandi","_obek":"isci","_kaynak_turu":"kurum","_dayanak":"turkseker.gov.tr haberi 5138 (https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=5138); haberin başlığı ve tarihi."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_kurum_numune_1.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_kurum_numune_1.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Ankara Şeker Fabrikası'nda pancar numune hattı, 21 Eylül 2026.","alt_en":"The beet sampling line at the Ankara Sugar Factory, 21 September 2026.","en_boy":1.5015,"kaynak":"https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=5139","_kimlik":"galeri_kurum_numune_1","_obek":"isci","_kaynak_turu":"kurum","_dayanak":"turkseker.gov.tr haberi 5139 (https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=5139); haberin başlığı ve tarihi."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_kurum_numune_2.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_kurum_numune_2.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Uşak, Elazığ ve Ağrı fabrikalarında kantarların açılışı, 23 Eylül 2026.","alt_en":"The opening of the weighbridges at the Uşak, Elazığ and Ağrı factories, 23 September 2026.","en_boy":1.3368,"kaynak":"https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=5141","_kimlik":"galeri_kurum_numune_2","_obek":"isci","_kaynak_turu":"kurum","_dayanak":"turkseker.gov.tr haberi 5141 (https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=5141); haberin başlığı ve tarihi."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_kurum_isciler.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_kurum_isciler.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Kastamonu Şeker Fabrikası'nın çalışanları, 2 Ekim 2026.","alt_en":"The workers of the Kastamonu Sugar Factory, 2 October 2026.","en_boy":1.5015,"kaynak":"https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=5145","_kimlik":"galeri_kurum_isciler","_obek":"isci","_kaynak_turu":"kurum","_dayanak":"turkseker.gov.tr haberi 5145 (https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=5145); haberin başlığı ve tarihi."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_kurum_malatya_bosaltma.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_kurum_malatya_bosaltma.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Malatya Şeker Fabrikası'nda 71. kampanya döneminin açılışı, 4 Eylül 2026.","alt_en":"The opening of the 71st campaign at the Malatya Sugar Factory, 4 September 2026.","en_boy":0.7995,"kaynak":"https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=5133","_kimlik":"galeri_kurum_malatya_bosaltma","_obek":"yukleme","_kaynak_turu":"kurum","_dayanak":"turkseker.gov.tr haberi 5133 (https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=5133); haberin başlığı ve tarihi."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_kurum_kantar_1.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_kurum_kantar_1.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Ereğli Şeker Fabrikası'nın kantarı, 18 Eylül 2026.","alt_en":"The weighbridge of the Ereğli Sugar Factory, 18 September 2026.","en_boy":0.75,"kaynak":"https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=5137","_kimlik":"galeri_kurum_kantar_1","_obek":"yukleme","_kaynak_turu":"kurum","_dayanak":"turkseker.gov.tr haberi 5137 (https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=5137); haberin başlığı ve tarihi."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_kurum_pancar_sahasi.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_kurum_pancar_sahasi.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Yozgat Şeker Fabrikası'nda 29. pancar alım kampanyasının açılışı, 30 Eylül 2026.","alt_en":"The opening of the 29th beet procurement campaign at the Yozgat Sugar Factory, 30 September 2026.","en_boy":1.3333,"kaynak":"https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=5143","_kimlik":"galeri_kurum_pancar_sahasi","_obek":"yukleme","_kaynak_turu":"kurum","_dayanak":"turkseker.gov.tr haberi 5143 (https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=5143); haberin başlığı ve tarihi."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_usak_pancar_arka.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_usak_pancar_arka.jpg","atif":"Uşak Şeker Fabrikası · AHUSA003 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Uşak Şeker Fabrikası fotokartının arka yüzü: İstanbul'a, Göztepe'ye gönderilmiş bir mektup.","alt_en":"The reverse of a photocard of the Uşak Sugar Factory: a letter sent to Göztepe, İstanbul.","en_boy":1.5779,"kaynak":"https://archives.saltresearch.org/handle/123456789/103306","_kimlik":"galeri_salt_usak_pancar_arka","_obek":"fabrikalar","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHUSA003 (https://archives.saltresearch.org/handle/123456789/103306). Kaydın başlığı; dosya kaydın ikinci belgesi."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_kurum_ilgin_hava.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_kurum_ilgin_hava.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Ilgın Şeker Fabrikası, 18 Eylül 2026.","alt_en":"The Ilgın Sugar Factory, 18 September 2026.","en_boy":0.7995,"kaynak":"https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=5137","_kimlik":"galeri_kurum_ilgin_hava","_obek":"fabrikalar","_kaynak_turu":"kurum","_dayanak":"turkseker.gov.tr haberi 5137 (https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=5137); haberin başlığı ve tarihi."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_kurum_kastamonu_saha.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_kurum_kastamonu_saha.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Kastamonu Şeker Fabrikası'nda 64. pancar alım kampanyasının açılışı, 2 Ekim 2026.","alt_en":"The opening of the 64th beet procurement campaign at the Kastamonu Sugar Factory, 2 October 2026.","en_boy":1.5015,"kaynak":"https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=5145","_kimlik":"galeri_kurum_kastamonu_saha","_obek":"fabrikalar","_kaynak_turu":"kurum","_dayanak":"turkseker.gov.tr haberi 5145 (https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=5145); haberin başlığı ve tarihi."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_alb_012.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_alb_012.jpg","atif":"İstanbul ve Trakya Şeker Fabrikaları T.A.Ş. Alpullu Şeker ve İspirto Fabrikaları · 1928-1929 · AHTURAL013 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Alpullu Şeker ve İspirto Fabrikaları albümünden bir sayfa: Fabrikanın iç mekânı. 1928-1929.","alt_en":"A page from the album of the Alpullu Sugar and Spirit Factories: Interior of the factory. 1928-1929.","en_boy":1.4453,"kaynak":"https://archives.saltresearch.org/handle/123456789/195731","_kimlik":"galeri_salt_alb_012","_obek":"fabrika_ici","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHTURAL013 (https://archives.saltresearch.org/handle/123456789/195731). Albüm sayfasının kendi açıklaması (dataItemFiles)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_usak_makine_arka.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_usak_makine_arka.jpg","atif":"Uşak Şeker Fabrikası'nın makine dairesi · AHUSA008 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Uşak Şeker Fabrikası'nın makine dairesini gösteren fotokartın arka yüzü: Trabzon'a gönderilmiş bir mektup.","alt_en":"The reverse of the photocard showing the engine room of the Uşak Sugar Factory: a letter sent to Trabzon.","en_boy":1.5779,"kaynak":"https://archives.saltresearch.org/handle/123456789/196979","_kimlik":"galeri_salt_usak_makine_arka","_obek":"fabrika_ici","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHUSA008 (https://archives.saltresearch.org/handle/123456789/196979). Kaydın başlığı; dosya kaydın ikinci belgesi."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_kurum_kazan_atesleme.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_kurum_kazan_atesleme.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Ilgın Şeker Fabrikası'nda kazanın ateşlenmesi, 20 Kasım 2026.","alt_en":"The firing of the boiler at the Ilgın Sugar Factory, 20 November 2026.","en_boy":1.7778,"kaynak":"https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=5157","_kimlik":"galeri_kurum_kazan_atesleme","_obek":"fabrika_ici","_kaynak_turu":"kurum","_dayanak":"turkseker.gov.tr haberi 5157 (https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=5157); haberin başlığı ve tarihi."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_pancar_yazisi.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_pancar_yazisi.jpg","atif":"Satirdan kahraman — CC BY-SA 4.0","lisans":"CC BY-SA 4.0","alt_tr":"Bir ambalajın üzerindeki “pancar şekerinden üretilmiştir” ibaresi, 23 Eylül 2021.","alt_en":"The phrase “made from beet sugar” on a package, 23 September 2021.","en_boy":1.3333,"kaynak":"https://commons.wikimedia.org/wiki/File:Pancar_%C5%9Fekerinden_%C3%BCretilmi%C5%9Ftir_yaz%C4%B1s%C4%B1.jpg","_kimlik":"galeri_pancar_yazisi","_obek":"urun","_kaynak_turu":"commons","_dayanak":"Commons künyesi: nesne_adi 'Pancar şekerinden üretilmiştir yazısı' + açıklama 'pancar şekerinden üretilmiştir yazısı. Türkiye'de özellikle 2010'ların' + tarih 2021-09-23."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_kurum_sam_fuari.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_kurum_sam_fuari.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"TÜRKŞEKER'in Şam'daki 360 Food Syria & Agritech Expo'daki standı, 5 Ekim 2026.","alt_en":"TÜRKŞEKER's stand at the 360 Food Syria & Agritech Expo in Damascus, 5 October 2026.","en_boy":1.7778,"kaynak":"https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=5148","_kimlik":"galeri_kurum_sam_fuari","_obek":"urun","_kaynak_turu":"kurum","_dayanak":"turkseker.gov.tr haberi 5148 (https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=5148); haberin başlığı ve tarihi."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_etim_k004.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_etim_k004.jpg","atif":"Türkiye Şeker Fabrikası Etimesgut Kompleksi'ne dair fotoğraflar · Ali Mukbil Gökdoğan · TMGH007 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Türkiye Şeker Fabrikası Etimesgut Kompleksi'ne dair fotoğraflar Ali Mukbil Gökdoğan fotoğrafı. Etimesgut, Ankara.","alt_en":"Photographs of the Etimesgut Complex of Türkiye Şeker Fabrikası. Photograph by Ali Mukbil Gökdoğan. Etimesgut, Ankara.","en_boy":1.4184,"kaynak":"https://archives.saltresearch.org/handle/123456789/215423","_kimlik":"galeri_salt_etim_k004","_obek":"cevresi","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı TMGH007 (https://archives.saltresearch.org/handle/123456789/215423). Kaydın başlığı ve üreteni."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_etim_k006.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_etim_k006.jpg","atif":"Türkiye Şeker Fabrikası Etimesgut Kompleksi'ne dair fotoğraflar · Ali Mukbil Gökdoğan · TMGH007 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Türkiye Şeker Fabrikası Etimesgut Kompleksi'ne dair fotoğraflar Ali Mukbil Gökdoğan fotoğrafı. Etimesgut, Ankara.","alt_en":"Photographs of the Etimesgut Complex of Türkiye Şeker Fabrikası. Photograph by Ali Mukbil Gökdoğan. Etimesgut, Ankara.","en_boy":1.4184,"kaynak":"https://archives.saltresearch.org/handle/123456789/215423","_kimlik":"galeri_salt_etim_k006","_obek":"cevresi","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı TMGH007 (https://archives.saltresearch.org/handle/123456789/215423). Kaydın başlığı ve üreteni."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_etim_k007.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_etim_k007.jpg","atif":"Türkiye Şeker Fabrikası Etimesgut Kompleksi'ne dair fotoğraflar · Ali Mukbil Gökdoğan · TMGH007 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Türkiye Şeker Fabrikası Etimesgut Kompleksi'ne dair fotoğraflar Ali Mukbil Gökdoğan fotoğrafı. Etimesgut, Ankara.","alt_en":"Photographs of the Etimesgut Complex of Türkiye Şeker Fabrikası. Photograph by Ali Mukbil Gökdoğan. Etimesgut, Ankara.","en_boy":1.4122,"kaynak":"https://archives.saltresearch.org/handle/123456789/215423","_kimlik":"galeri_salt_etim_k007","_obek":"cevresi","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı TMGH007 (https://archives.saltresearch.org/handle/123456789/215423). Kaydın başlığı ve üreteni."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_etim_k008.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_etim_k008.jpg","atif":"Türkiye Şeker Fabrikası Etimesgut Kompleksi'ne dair fotoğraflar · Ali Mukbil Gökdoğan · TMGH007 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Türkiye Şeker Fabrikası Etimesgut Kompleksi'ne dair fotoğraflar Ali Mukbil Gökdoğan fotoğrafı. Etimesgut, Ankara.","alt_en":"Photographs of the Etimesgut Complex of Türkiye Şeker Fabrikası. Photograph by Ali Mukbil Gökdoğan. Etimesgut, Ankara.","en_boy":1.4072,"kaynak":"https://archives.saltresearch.org/handle/123456789/215423","_kimlik":"galeri_salt_etim_k008","_obek":"cevresi","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı TMGH007 (https://archives.saltresearch.org/handle/123456789/215423). Kaydın başlığı ve üreteni."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_etim_k011.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_etim_k011.jpg","atif":"Türkiye Şeker Fabrikası Etimesgut Kompleksi'ne dair fotoğraflar · Ali Mukbil Gökdoğan · TMGH007 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Türkiye Şeker Fabrikası Etimesgut Kompleksi'ne dair fotoğraflar Ali Mukbil Gökdoğan fotoğrafı. Etimesgut, Ankara.","alt_en":"Photographs of the Etimesgut Complex of Türkiye Şeker Fabrikası. Photograph by Ali Mukbil Gökdoğan. Etimesgut, Ankara.","en_boy":1.3937,"kaynak":"https://archives.saltresearch.org/handle/123456789/215423","_kimlik":"galeri_salt_etim_k011","_obek":"cevresi","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı TMGH007 (https://archives.saltresearch.org/handle/123456789/215423). Kaydın başlığı ve üreteni."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_usak_havuz_arka.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_usak_havuz_arka.jpg","atif":"Uşak Şeker Fabrikası Sosyal Tesisleri · AHUSA002 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Uşak Şeker Fabrikası Sosyal Tesisleri fotokartının arka yüzü: Betül'e yazılmış bir mektup.","alt_en":"The reverse of a photocard of the social facilities of the Uşak Sugar Factory: a letter written to Betül.","en_boy":1.5534,"kaynak":"https://archives.saltresearch.org/handle/123456789/117021","_kimlik":"galeri_salt_usak_havuz_arka","_obek":"cevresi","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHUSA002 (https://archives.saltresearch.org/handle/123456789/117021). Kaydın başlığı; dosya kaydın ikinci belgesi."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_usak_havuz_2.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_usak_havuz_2.jpg","atif":"Uşak Şeker Fabrikası Sosyal Tesisleri · AHUSA002 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Uşak Şeker Fabrikası Sosyal Tesisleri.","alt_en":"The social facilities of the Uşak Sugar Factory.","en_boy":1.5717,"kaynak":"https://archives.saltresearch.org/handle/123456789/117021","_kimlik":"galeri_salt_usak_havuz_2","_obek":"cevresi","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHUSA002 (https://archives.saltresearch.org/handle/123456789/117021). Kaydın başlığı; dosya kaydın ikinci belgesi."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_salt_usak_havuz_2_arka.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_salt_usak_havuz_2_arka.jpg","atif":"Uşak Şeker Fabrikası Sosyal Tesisleri · AHUSA002 · Salt Araştırma · CC BY-NC-ND 4.0","lisans":"CC BY-NC-ND 4.0","alt_tr":"Aynı fotokartın arka yüzü: ablasına yazılmış bir mektup.","alt_en":"The reverse of the same photocard: a letter written to an elder sister.","en_boy":0.6344,"kaynak":"https://archives.saltresearch.org/handle/123456789/117021","_kimlik":"galeri_salt_usak_havuz_2_arka","_obek":"cevresi","_kaynak_turu":"salt","_dayanak":"SALT Araştırma kaydı AHUSA002 (https://archives.saltresearch.org/handle/123456789/117021). Kaydın başlığı; dosya kaydın ikinci belgesi."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_adapazari_sehir.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_adapazari_sehir.jpg","atif":"Acar54 — CC BY-SA 4.0","lisans":"CC BY-SA 4.0","alt_tr":"Serdivan'dan Adapazarı Şeker Fabrikası, Sakarya, 24 Aralık 2014. Fabrika şehrin büyümesiyle şehir içinde kalmış.","alt_en":"The Adapazarı Sugar Factory seen from Serdivan, Sakarya, 24 December 2014. The city grew around the factory.","en_boy":1.4939,"kaynak":"https://commons.wikimedia.org/wiki/File:Serdivan,_Sakarya.jpg","_kimlik":"galeri_adapazari_sehir","_obek":"cevresi","_kaynak_turu":"commons","_dayanak":"Commons künyesi: nesne_adi 'Serdivan, Sakarya' + açıklama 'Serdivan AVM çevresi. Arkada şehrin büyümesiyle şehir içinde kalmış Ad' + tarih 2014-12-24 13:34:32."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_tarla_mibzer.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_tarla_mibzer.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Mibzerle pancar ekimi.","alt_en":"Sowing beet with a seed drill.","en_boy":1.5009,"kaynak":"https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=62","_kimlik":"galeri_tarla_mibzer","_obek":"tarla","_kaynak_turu":"kurum","_dayanak":"turkseker.gov.tr haberi 62, “Türkşeker'den Çiftçimize 650 Milyon TL Destek!”, 1 Eylül 2021 (https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=62)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_tarla_makine.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_tarla_makine.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Pancar tarlasında tarım makinesi.","alt_en":"An agricultural machine in a beet field.","en_boy":1.5,"kaynak":"https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=72","_kimlik":"galeri_tarla_makine","_obek":"tarla","_kaynak_turu":"kurum","_dayanak":"turkseker.gov.tr haberi 72, “Türkşeker Pancar Avans Fiyatını Artırdı!”, 18 Mart 2022 (https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=72)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_tarla_sulama_1.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_tarla_sulama_1.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Sulanan şeker pancarı tarlası.","alt_en":"A sugar beet field under irrigation.","en_boy":1.5,"kaynak":"https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=73","_kimlik":"galeri_tarla_sulama_1","_obek":"tarla","_kaynak_turu":"kurum","_dayanak":"turkseker.gov.tr haberi 73, “Avans Ödemesi”, 24 Haziran 2022 (https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=73)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_tarla_sulama_isci.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_tarla_sulama_isci.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Şeker pancarı tarlasında çalışanlar ve sulama.","alt_en":"Workers and irrigation in a sugar beet field.","en_boy":1.5,"kaynak":"https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=73","_kimlik":"galeri_tarla_sulama_isci","_obek":"tarla","_kaynak_turu":"kurum","_dayanak":"turkseker.gov.tr haberi 73, “Avans Ödemesi”, 24 Haziran 2022 (https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=73)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_tarla_sulama_2.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_tarla_sulama_2.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Sulanan şeker pancarı tarlası.","alt_en":"A sugar beet field under irrigation.","en_boy":1.5111,"kaynak":"https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=73","_kimlik":"galeri_tarla_sulama_2","_obek":"tarla","_kaynak_turu":"kurum","_dayanak":"turkseker.gov.tr haberi 73, “Avans Ödemesi”, 24 Haziran 2022 (https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=73)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_tarla_siralar.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_tarla_siralar.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Tarlada şeker pancarı sıraları.","alt_en":"Rows of sugar beet in a field.","en_boy":0.7081,"kaynak":"https://www.turkseker.gov.tr/Belgeler/stratejik_plan_12_09_2024_v4.pdf","_kimlik":"galeri_tarla_siralar","_obek":"tarla","_kaynak_turu":"kurum","_dayanak":"TÜRKŞEKER 2024-2028 Stratejik Planı (https://www.turkseker.gov.tr/Belgeler/stratejik_plan_12_09_2024_v4.pdf); yayının kendi fotoğrafı."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_tarla_traktor_plan.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_tarla_traktor_plan.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Pancar tarlasında traktör.","alt_en":"A tractor in a beet field.","en_boy":0.7081,"kaynak":"https://www.turkseker.gov.tr/Belgeler/stratejik_plan_12_09_2024_v4.pdf","_kimlik":"galeri_tarla_traktor_plan","_obek":"tarla","_kaynak_turu":"kurum","_dayanak":"TÜRKŞEKER 2024-2028 Stratejik Planı (https://www.turkseker.gov.tr/Belgeler/stratejik_plan_12_09_2024_v4.pdf); yayının kendi fotoğrafı."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_tarla_pelet_tohum.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_tarla_pelet_tohum.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Pelet kaplı şeker pancarı tohumu.","alt_en":"Pelleted sugar beet seed.","en_boy":1.7582,"kaynak":"https://www.turkseker.gov.tr/Belgeler/stratejik_plan_12_09_2024_v4.pdf","_kimlik":"galeri_tarla_pelet_tohum","_obek":"tarla","_kaynak_turu":"kurum","_dayanak":"TÜRKŞEKER 2024-2028 Stratejik Planı (https://www.turkseker.gov.tr/Belgeler/stratejik_plan_12_09_2024_v4.pdf); yayının kendi fotoğrafı."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_ciftci_pancarla.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_ciftci_pancarla.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Elinde şeker pancarıyla bir üretici, pancar tarlasında.","alt_en":"A grower holding sugar beet in a beet field.","en_boy":1.5009,"kaynak":"https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=62","_kimlik":"galeri_ciftci_pancarla","_obek":"ciftci","_kaynak_turu":"kurum","_dayanak":"turkseker.gov.tr haberi 62, “Türkşeker'den Çiftçimize 650 Milyon TL Destek!”, 1 Eylül 2021 (https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=62)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_ciftci_traktor.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_ciftci_traktor.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Ekim yapılan tarlada bir üretici ve mibzerli traktör.","alt_en":"A grower and a tractor with a seed drill in a field being sown.","en_boy":1.8412,"kaynak":"https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=62","_kimlik":"galeri_ciftci_traktor","_obek":"ciftci","_kaynak_turu":"kurum","_dayanak":"turkseker.gov.tr haberi 62, “Türkşeker'den Çiftçimize 650 Milyon TL Destek!”, 1 Eylül 2021 (https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=62)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_ciftci_lokal_masa.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_ciftci_lokal_masa.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Çiftçi Lokali'nde üreticiler.","alt_en":"Growers at a Çiftçi Lokali, the company's rest house for growers.","en_boy":1.6394,"kaynak":"https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=63","_kimlik":"galeri_ciftci_lokal_masa","_obek":"ciftci","_kaynak_turu":"kurum","_dayanak":"turkseker.gov.tr haberi 63, “Türkşeker Çiftçi Lokalleri Yeni Üretim Sezonuna Hazır!”, 6 Eylül 2021 (https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=63)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_ciftci_lokal_gece.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_ciftci_lokal_gece.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Bir Çiftçi Lokali, gece.","alt_en":"A Çiftçi Lokali at night.","en_boy":1.5015,"kaynak":"https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=63","_kimlik":"galeri_ciftci_lokal_gece","_obek":"ciftci","_kaynak_turu":"kurum","_dayanak":"turkseker.gov.tr haberi 63, “Türkşeker Çiftçi Lokalleri Yeni Üretim Sezonuna Hazır!”, 6 Eylül 2021 (https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=63)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_ciftci_lokal_cay.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_ciftci_lokal_cay.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Çiftçi Lokali'nde çay içen üreticiler.","alt_en":"Growers drinking tea at a Çiftçi Lokali.","en_boy":1.9069,"kaynak":"https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=63","_kimlik":"galeri_ciftci_lokal_cay","_obek":"ciftci","_kaynak_turu":"kurum","_dayanak":"turkseker.gov.tr haberi 63, “Türkşeker Çiftçi Lokalleri Yeni Üretim Sezonuna Hazır!”, 6 Eylül 2021 (https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=63)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_ciftci_sozlesme_imza.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_ciftci_sozlesme_imza.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Pancar sözleşmelerinin imzalanması.","alt_en":"Beet contracts being signed.","en_boy":1.4072,"kaynak":"https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=72","_kimlik":"galeri_ciftci_sozlesme_imza","_obek":"ciftci","_kaynak_turu":"kurum","_dayanak":"turkseker.gov.tr haberi 72, “Türkşeker Pancar Avans Fiyatını Artırdı!”, 18 Mart 2022 (https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=72)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_isci_montaj.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_isci_montaj.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"TÜRKŞEKER çalışanları bir tesisin montajında.","alt_en":"TÜRKŞEKER staff assembling a plant unit.","en_boy":0.7081,"kaynak":"https://www.turkseker.gov.tr/Belgeler/stratejik_plan_12_09_2024_v4.pdf","_kimlik":"galeri_isci_montaj","_obek":"isci","_kaynak_turu":"kurum","_dayanak":"TÜRKŞEKER 2024-2028 Stratejik Planı (https://www.turkseker.gov.tr/Belgeler/stratejik_plan_12_09_2024_v4.pdf); yayının kendi fotoğrafı."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_tarla_hasat_makinesi.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_tarla_hasat_makinesi.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Şeker pancarı hasadı.","alt_en":"The sugar beet harvest.","en_boy":0.7081,"kaynak":"https://www.turkseker.gov.tr/Belgeler/stratejik_plan_12_09_2024_v4.pdf","_kimlik":"galeri_tarla_hasat_makinesi","_obek":"hasat","_kaynak_turu":"kurum","_dayanak":"TÜRKŞEKER 2024-2028 Stratejik Planı (https://www.turkseker.gov.tr/Belgeler/stratejik_plan_12_09_2024_v4.pdf); yayının kendi fotoğrafı."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_yukleme_su_kanali.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_yukleme_su_kanali.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Fabrikaya gelen pancarın su kanalına verilmesi.","alt_en":"Beet arriving at the factory being fed into the water flume.","en_boy":1.5,"kaynak":"https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=72","_kimlik":"galeri_yukleme_su_kanali","_obek":"yukleme","_kaynak_turu":"kurum","_dayanak":"turkseker.gov.tr haberi 72, “Türkşeker Pancar Avans Fiyatını Artırdı!”, 18 Mart 2022 (https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=72)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_yukleme_silo_bant.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_yukleme_silo_bant.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Fabrika sahasında pancar siloları ve taşıma bandı.","alt_en":"Beet silos and a conveyor in a factory yard.","en_boy":0.7646,"kaynak":"https://www.turkseker.gov.tr/Belgeler/stratejik_plan_12_09_2024_v4.pdf","_kimlik":"galeri_yukleme_silo_bant","_obek":"yukleme","_kaynak_turu":"kurum","_dayanak":"TÜRKŞEKER 2024-2028 Stratejik Planı (https://www.turkseker.gov.tr/Belgeler/stratejik_plan_12_09_2024_v4.pdf); yayının kendi fotoğrafı."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_urun_cuvallama.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_urun_cuvallama.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"TÜRKŞEKER şekerinin çuvallanması.","alt_en":"TÜRKŞEKER sugar being bagged.","en_boy":0.705,"kaynak":"https://www.turkseker.gov.tr/Belgeler/stratejik_plan_12_09_2024_v4.pdf","_kimlik":"galeri_urun_cuvallama","_obek":"urun","_kaynak_turu":"kurum","_dayanak":"TÜRKŞEKER 2024-2028 Stratejik Planı (https://www.turkseker.gov.tr/Belgeler/stratejik_plan_12_09_2024_v4.pdf); yayının kendi fotoğrafı."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_urun_market_raf.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_urun_market_raf.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"TÜRKŞEKER Tarım Ekolojik Market'te raflar.","alt_en":"The shelves of a TÜRKŞEKER agricultural ecological market.","en_boy":1.5015,"kaynak":"https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=3080","_kimlik":"galeri_urun_market_raf","_obek":"urun","_kaynak_turu":"kurum","_dayanak":"turkseker.gov.tr haberi 3080, “Türkşeker'in İlk Tarım Ekolojik Marketi Ankara'da Açıldı!”, 22 Nisan 2025 (https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=3080)."},{"url":"https://tarimportali.net/dosya/turkseker/galeri_cevresi_sera.jpg","kucuk":"https://tarimportali.net/dosya/turkseker/k/galeri_cevresi_sera.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","lisans":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","alt_tr":"Ankara Şeker Fabrikası yerleşkesindeki serada TAGEM protokolünün imzalanması.","alt_en":"The TAGEM protocol being signed in the greenhouse on the Ankara Sugar Factory estate.","en_boy":1.5015,"kaynak":"https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=5099","_kimlik":"galeri_cevresi_sera","_obek":"cevresi","_kaynak_turu":"kurum","_dayanak":"turkseker.gov.tr haberi 5099, “TAGEM Ürünleri TÜRKŞEKER Ekolojik Marketlerinde”, 19 Aralık 2025 (https://www.turkseker.gov.tr/?ModulID=1&MenuID=53&ID=5099)."}]}}$dsr$::jsonb,
  $dsr${"kunye_turkseker":{"tur":"kunye","baslik":{"tr":"Kurum rakamlarla","en":"The institution in figures"},"kaynak":"TÜRKŞEKER · Şeker Sektör Raporu 2025 ve 2024-2028 Stratejik Plan","not":{"tr":"Kota 2025/26 pazarlama yılına ait. Fabrika sayısı TESİS sayısıdır; kota tablosundaki 15 kalem ŞİRKET sayar ve bir şirketin birden çok fabrikası olabilir. Personel rakamı 2022 fiili ortalamasıdır; taranan belgelerde daha yenisi yok.","en":"The quota is for the 2025/26 marketing year. The factory count is of PLANTS; the 15 entries in the quota table count COMPANIES, and one company may own several plants. The staff figure is the 2022 actual average; the documents scanned carry nothing more recent."},"kalemler":[{"deger":14,"ondalik":0,"etiket":{"tr":"şeker fabrikası","en":"sugar factories"},"alt":{"tr":"1990 öncesi 30","en":"30 before 1990"}},{"deger":1023820,"ondalik":0,"bolen":1000,"etiket":{"tr":"bin ton A kotası","en":"thousand tonnes, A quota"},"alt":{"tr":"pancar şekerinin %36,08'i","en":"36.08% of beet sugar"}},{"deger":76767,"ondalik":0,"etiket":{"tr":"pancar üreticisi","en":"beet growers"},"alt":{"tr":"2025 · ülke geneli","en":"2025 · nationwide"}},{"deger":6024,"ondalik":0,"etiket":{"tr":"çalışan","en":"staff"},"alt":{"tr":"alt işverenle 10.535","en":"10,535 with contractors"}}]},"fabrikalarin_acilisi":{"tur":"zaman_cizelgesi","baslik":{"tr":"Dört fabrikadan bir sanayiye","en":"From four factories to an industry"},"kaynak":"TÜRKŞEKER · Şeker Sektör Raporu 2025, Sektörün Tarihsel Gelişimi","not":{"tr":"Uşak'ın temeli Alpullu'dan bir buçuk ay önce atıldı; Alpullu onbir ayda bitti ve ilk Türk şekerini o üretti. Uşak yirmi bir gün sonra açıldı.","en":"Uşak's foundations were laid six weeks before Alpullu's; Alpullu was finished in eleven months and made the first Turkish sugar. Uşak opened twenty-one days later."},"olaylar":[{"yil":1925,"baslik":{"tr":"İki temel atılıyor","en":"Two foundations are laid"},"aciklama":{"tr":"6 Kasım'da Uşak'ta, 22 Aralık'ta Alpullu'da şeker fabrikalarının temeli atılır.","en":"On 6 November at Uşak and on 22 December at Alpullu, the foundations are laid."}},{"yil":1926,"baslik":{"tr":"İlk Türk şekeri","en":"The first Turkish sugar"},"aciklama":{"tr":"26 Kasım'da Alpullu işletmeye açılır ve ilk Türk şekeri üretilir. Uşak 17 Aralık'ta açılır.","en":"On 26 November Alpullu opens and the first Turkish sugar is made. Uşak opens on 17 December."}},{"yil":1933,"baslik":{"tr":"Eskişehir","en":"Eskişehir"},"aciklama":{"tr":"5 Aralık'ta üçüncü fabrika işletmeye açılır.","en":"The third factory opens on 5 December."}},{"yil":1934,"baslik":{"tr":"Turhal","en":"Turhal"},"aciklama":{"tr":"19 Ekim'de dördüncü fabrika işletmeye açılır.","en":"The fourth factory opens on 19 October."}},{"yil":1935,"baslik":{"tr":"Dört şirket tek çatıda","en":"Four companies, one roof"},"aciklama":{"tr":"6 Temmuz'da üç milli banka eşit paylarla ortak olur; 22 milyon TL sermayeli Türkiye Şeker Fabrikaları A.Ş. kurulur.","en":"On 6 July three national banks take equal shares; Türkiye Şeker Fabrikaları A.Ş. is founded with a capital of 22 million lira."}},{"yil":1956,"baslik":{"tr":"Fabrika sayısı on beşe çıkıyor","en":"The count reaches fifteen"},"aciklama":{"tr":"1951-1956 arasında on bir yeni fabrika kurulur. Aynı yıl 6747 sayılı Şeker Kanunu çıkar.","en":"Eleven new factories are built between 1951 and 1956. The Sugar Law 6747 is passed the same year."}},{"yil":2001,"baslik":{"tr":"4634 sayılı Şeker Kanunu","en":"Sugar Law 4634"},"aciklama":{"tr":"19 Nisan'da yürürlüğe girer; üretim kotayla planlanmaya başlar.","en":"In force from 19 April; production begins to be planned by quota."}},{"yil":2018,"baslik":{"tr":"On fabrika el değiştirir","en":"Ten factories change hands"},"aciklama":{"tr":"Afyon, Alpullu, Bor, Çorum, Elbistan, Erzincan, Erzurum, Kırşehir, Muş ve Turhal özelleştirilir.","en":"Afyon, Alpullu, Bor, Çorum, Elbistan, Erzincan, Erzurum, Kırşehir, Muş and Turhal are privatised."}},{"yil":2021,"baslik":{"tr":"Sermaye Varlık Fonu'na","en":"Capital to the Wealth Fund"},"aciklama":{"tr":"29 Nisan tarihli Cumhurbaşkanı Kararı ile sermayenin tamamı devredilir.","en":"A Presidential Decision of 29 April transfers the entire capital."}},{"yil":2025,"baslik":{"tr":"Çarşamba MKE'ye geçer","en":"Çarşamba passes to MKE"},"aciklama":{"tr":"Devir tamamlanır; TÜRKŞEKER 14 fabrika ile üretim yapar.","en":"The transfer is completed; TÜRKŞEKER operates 14 factories."}}]},"kota_uc_kesim":{"tur":"ikili_cubuk","baslik":{"tr":"Bir şirket, üçte birden fazlası","en":"One company, more than a third"},"kaynak":"TÜRKŞEKER · Şeker Sektör Raporu 2025, Tablo 24","seriler":[{"ad":{"tr":"şirket sayısı","en":"share of companies"},"rol":"ikincil"},{"ad":{"tr":"kota payı","en":"share of quota"},"rol":"vurgu"}],"not":{"tr":"Pancar şekeri A kotası 2025/26 için 2.837.250 ton. On beş üreticinin biri TÜRKŞEKER ve tek başına %36,08 tutuyor; üç kooperatif şirketi %35,42, on bir özel şirket %28,49. Her satır kendi içinde oranlanıyor; satırlar birbiriyle değil.","en":"The beet sugar A quota for 2025/26 is 2,837,250 tonnes. One of the fifteen producers is TÜRKŞEKER, holding 36.08% on its own; three cooperative companies hold 35.42% and eleven private companies 28.49%. Each row is scaled within itself, not against the others."},"satirlar":[{"etiket":{"tr":"Kamu · TÜRKŞEKER","en":"Public · TÜRKŞEKER"},"degerler":[6.67,36.08],"ondalik":2,"onek":{"tr":"%","en":""},"sonek":{"tr":"","en":"%"}},{"etiket":{"tr":"Kooperatif · 3 şirket","en":"Cooperative · 3 companies"},"degerler":[20,35.42],"ondalik":2,"onek":{"tr":"%","en":""},"sonek":{"tr":"","en":"%"}},{"etiket":{"tr":"Özel · 11 şirket","en":"Private · 11 companies"},"degerler":[73.33,28.49],"ondalik":2,"onek":{"tr":"%","en":""},"sonek":{"tr":"","en":"%"}}]},"sirket_kotalari":{"tur":"siralama","bolen":1000,"ondalik":0,"baslik":{"tr":"On beş üretici, en büyükten en küçüğe","en":"Fifteen producers, largest to smallest"},"birim":{"tr":"bin ton · A kotası","en":"thousand tonnes · A quota"},"kaynak":"TÜRKŞEKER · Şeker Sektör Raporu 2025, Tablo 24","not":{"tr":"Listenin en küçüğü Alpullu: 26.680 ton, pancar şekerinin %0,94'i. İlk Türk şekeri 1926'da bu fabrikada üretilmişti; 2018'de özelleştirildi.","en":"The smallest on the list is Alpullu: 26,680 tonnes, 0.94% of beet sugar. The first Turkish sugar was made at this factory in 1926; it was privatised in 2018."},"satirlar":[{"etiket":{"tr":"KAMU TÜRKŞEKER (14 Fabrika)","en":"KAMU TÜRKŞEKER (14 Fabrika)"},"deger":1023820,"rol":"vurgu"},{"etiket":{"tr":"Kayseri Şeker Fabrikası A.Ş. (Kayseri, Boğazlı","en":"Kayseri Şeker Fabrikası A.Ş. (Kayseri, Boğazlı"},"deger":473240,"rol":"sessiz"},{"etiket":{"tr":"Konya Şeker San. Ve Tic. A.Ş. (Konya, Çumra)","en":"Konya Şeker San. Ve Tic. A.Ş. (Konya, Çumra)"},"deger":457280,"rol":"sessiz"},{"etiket":{"tr":"Doğuş Yiyecek Ve İçecek Üretim San. Tic. A.Ş.(","en":"Doğuş Yiyecek Ve İçecek Üretim San. Tic. A.Ş.("},"deger":131810,"rol":"sessiz"},{"etiket":{"tr":"Keskinkılıç Gıda San. Tic. A.Ş","en":"Keskinkılıç Gıda San. Tic. A.Ş"},"deger":112360,"rol":"sessiz"},{"etiket":{"tr":"Çorum Şeker Fabrikası A.Ş","en":"Çorum Şeker Fabrikası A.Ş"},"deger":105670,"rol":"sessiz"},{"etiket":{"tr":"Sukkar Şeker Üretim A.Ş. (Erzurum-Erzincan)","en":"Sukkar Şeker Üretim A.Ş. (Erzurum-Erzincan)"},"deger":75610,"rol":"sessiz"},{"etiket":{"tr":"Tutgu Gıda A.Ş.(Kırşehir)","en":"Tutgu Gıda A.Ş.(Kırşehir)"},"deger":75600,"rol":"sessiz"},{"etiket":{"tr":"Binbirgıda · Alpullu","en":"Binbirgıda · Alpullu"},"deger":26680,"rol":"ikincil"}]},"pancar_verimi":{"tur":"cizgi","bolen":1000,"ondalik":1,"baslik":{"tr":"Aynı dönümden üç katı pancar","en":"Three times the beet from the same field"},"birim":{"tr":"ton/hektar · şeker pancarı verimi","en":"tonnes per hectare · sugar beet yield"},"kaynak":"FAOSTAT · Üretim, Türkiye (Alan Kodu 223)","not":{"tr":"1961'de hektar başına 22,1 ton olan verim 2024'te 70,9 tona çıktı: %221 artış. FAOSTAT serisi 1961'de başlıyor; ilk Türk şekeri 1926'da üretildi ve aradaki otuz beş yılın sayısı bu seride yok.","en":"Yield rose from 22.1 tonnes per hectare in 1961 to 70.9 in 2024, a rise of 221%. The FAOSTAT series begins in 1961; the first Turkish sugar was made in 1926 and the thirty-five years between are not in it."},"seriler":[{"ad":{"tr":"Verim","en":"Yield"},"rol":"vurgu","noktalar":{"liste":[{"yil":1961,"verim":22073.2},{"yil":1962,"verim":21719.1},{"yil":1963,"verim":24376.5},{"yil":1964,"verim":25198.3},{"yil":1965,"verim":21688.6},{"yil":1966,"verim":28854.6},{"yil":1967,"verim":35122.1},{"yil":1968,"verim":37265.8},{"yil":1969,"verim":32931.1},{"yil":1970,"verim":34577.9},{"yil":1971,"verim":37457.4},{"yil":1972,"verim":39760.5},{"yil":1973,"verim":33257.3},{"yil":1974,"verim":30856.3},{"yil":1975,"verim":32694.9},{"yil":1976,"verim":37563.7},{"yil":1977,"verim":36133.3},{"yil":1978,"verim":32028.5},{"yil":1979,"verim":32735.7},{"yil":1980,"verim":25688.8},{"yil":1981,"verim":31167.4},{"yil":1982,"verim":34282.3},{"yil":1983,"verim":35586.6},{"yil":1984,"verim":31720.9},{"yil":1985,"verim":30757.6},{"yil":1986,"verim":30695},{"yil":1987,"verim":33041.8},{"yil":1988,"verim":36512.4},{"yil":1989,"verim":32169.3},{"yil":1990,"verim":37044.1},{"yil":1991,"verim":38677.4},{"yil":1992,"verim":38173.8},{"yil":1993,"verim":37052.1},{"yil":1994,"verim":31920.7},{"yil":1995,"verim":36102},{"yil":1996,"verim":34934.6},{"yil":1997,"verim":39424.3},{"yil":1998,"verim":44480.6},{"yil":1999,"verim":41206.5},{"yil":2000,"verim":46109.8},{"yil":2001,"verim":35424},{"yil":2002,"verim":44439},{"yil":2003,"verim":40141.2},{"yil":2004,"verim":42904.7},{"yil":2005,"verim":45242.1},{"yil":2006,"verim":44644.8},{"yil":2007,"verim":41539},{"yil":2008,"verim":48290.7},{"yil":2009,"verim":53321.8},{"yil":2010,"verim":54593.2},{"yil":2011,"verim":54881.7},{"yil":2012,"verim":53250.1},{"yil":2013,"verim":56679.4},{"yil":2014,"verim":58244.6},{"yil":2015,"verim":58479.2},{"yil":2016,"verim":60855.9},{"yil":2017,"verim":62408},{"yil":2018,"verim":59980.1},{"yil":2019,"verim":58224.6},{"yil":2020,"verim":68458.1},{"yil":2021,"verim":58763.6},{"yil":2022,"verim":65178.1},{"yil":2023,"verim":69355.4},{"yil":2024,"verim":70925}],"x":"yil","y":"verim"}}]},"dunya_pancar_sekeri":{"tur":"siralama","ondalik":0,"baslik":{"tr":"Dünyada pancar şekeri: Türkiye dördüncü","en":"Beet sugar worldwide: Türkiye is fourth"},"birim":{"tr":"bin ton","en":"thousand tonnes"},"kaynak":"USDA Foreign Agricultural Service · Production, Supply and Distribution","not":{"tr":"Türkiye 3.100 bin tonla dördüncü sırada. Ülkenin kamış şekeri üretimi sıfır: şekerin tamamı pancardan geliyor.","en":"Türkiye is fourth with 3,100 thousand tonnes. The country's cane sugar output is zero: all of its sugar comes from beet."},"satirlar":[{"etiket":{"tr":"Avrupa Birliği","en":"European Union"},"deger":16546,"rol":"sessiz"},{"etiket":{"tr":"Rusya","en":"Russia"},"deger":6900,"rol":"sessiz"},{"etiket":{"tr":"ABD","en":"United States"},"deger":4871,"rol":"sessiz"},{"etiket":{"tr":"Türkiye","en":"Türkiye"},"deger":3100,"rol":"vurgu"},{"etiket":{"tr":"Mısır","en":"Egypt"},"deger":2400,"rol":"sessiz"},{"etiket":{"tr":"Ukrayna","en":"Ukraine"},"deger":1800,"rol":"sessiz"},{"etiket":{"tr":"Çin","en":"China"},"deger":1500,"rol":"sessiz"}]},"nbs_kotasi":{"tur":"cizgi","ondalik":1,"baslik":{"tr":"Nişasta bazlı şekerin kotası dörtte bire indi","en":"The starch-based sugar quota fell to a quarter"},"birim":{"tr":"bin ton · A kotası","en":"thousand tonnes · A quota"},"kaynak":"TÜRKŞEKER · Şeker Sektör Raporu 2025, Tablo 23","not":{"tr":"2017/18'de 267 bin ton olan kota 2019/20'de 67,5 bin tona indi: %74,7 azalma. 7103 sayılı Kanunun 47. maddesi ülke toplam A kotasının %10'u olan payı %5'e indirdi; 2019/20'den sonra Cumhurbaşkanı kararıyla %2,5'te tutuluyor. Aynı kanunun Geçici 11. maddesi ortaya çıkan kota fazlasını TÜRKŞEKER'e aktardı.","en":"The quota fell from 267 thousand tonnes in 2017/18 to 67.5 in 2019/20, a fall of 74.7%. Article 47 of Law 7103 cut the share from 10 per cent of the national A quota to 5; since 2019/20 a Presidential Decision has held it at 2.5. Provisional Article 11 of the same law transferred the resulting surplus quota to TÜRKŞEKER."},"seriler":[{"ad":{"tr":"NBŞ kotası","en":"Starch-based sugar quota"},"rol":"vurgu","noktalar":{"liste":[{"yil":2017,"kota":267,"pay":9.57},{"yil":2018,"kota":135,"pay":5},{"yil":2019,"kota":67.5,"pay":2.5},{"yil":2020,"kota":67.5,"pay":2.5},{"yil":2021,"kota":67.5,"pay":2.5},{"yil":2022,"kota":68.75,"pay":2.5},{"yil":2023,"kota":72.75,"pay":2.5},{"yil":2024,"kota":72.75,"pay":2.5},{"yil":2025,"kota":72.75,"pay":2.5}],"x":"yil","y":"kota"}}]},"pancarin_yolu":{"tur":"islem_akisi","baslik":{"tr":"Çiftçi pancarını nasıl satar","en":"How a grower sells their beet"},"kaynak":"TÜRKŞEKER · Şeker Sektör Raporu 2025 · 4634 sayılı Şeker Kanunu, madde 4","not":{"tr":"Sözleşmeli üretimin Türkiye'de ilk ve en yaygın uygulandığı ürün şeker pancarıdır. Pancar bir münavebe bitkisi: bölgeye göre üç ya da dört yılda bir ekiliyor. Süreler belgelerde yazılı olmadığı için boş bırakıldı.","en":"Sugar beet is the crop for which contract farming was first and is most widely used in Türkiye. Beet is a rotation crop, sown every three or four years depending on the region. Durations are left blank because the documents do not state them."},"adimlar":[{"aktor":{"tr":"Üretici ve şirket","en":"Grower and company"},"baslik":{"tr":"Sözleşme imzalanır","en":"The contract is signed"},"aciklama":{"tr":"Her yıl ekimden önce Şeker Pancarı Üretim Sözleşmesi yapılır.","en":"A Sugar Beet Production Contract is made each year before sowing."},"belge":{"tr":"Şeker Pancarı Üretim Sözleşmesi","en":"Sugar Beet Production Contract"}},{"aktor":{"tr":"Şirket","en":"Company"},"baslik":{"tr":"Fiyat ekimden önce belirlenir","en":"The price is set before sowing"},"aciklama":{"tr":"A kotası pancar fiyatı; yıllık enflasyon, üretici maliyetlerindeki artış, dünya pancar fiyatları ve alternatif ürün paritesi dikkate alınarak belirlenir.","en":"The A quota beet price is set with regard to annual inflation, the rise in growers' costs, world beet prices and the parity of alternative crops."}},{"aktor":{"tr":"Şirket","en":"Company"},"baslik":{"tr":"Avans verilir","en":"An advance is paid"},"aciklama":{"tr":"Tohum ve gübre gibi ayni destekler ile nakdi avanslar. Pancar teslim edilmeden önce bedelin yaklaşık yüzde 35'i faiz yansıtılmaksızın ödenir.","en":"Support in kind, such as seed and fertiliser, and cash advances. About 35 per cent of the price is paid before delivery, with no interest charged."}},{"aktor":{"tr":"Üretici","en":"Grower"},"baslik":{"tr":"Ekim ve hasat","en":"Sowing and harvest"},"aciklama":{"tr":"Pancar münavebe ile ekilir; bölgeye göre üç ya da dört yılda bir.","en":"Beet is sown in rotation, every three or four years by region."}},{"aktor":{"tr":"Üretici","en":"Grower"},"baslik":{"tr":"Pancar teslim edilir","en":"The beet is delivered"},"aciklama":{"tr":"Teslimle birlikte nakliye destek ödemesi devreye girer.","en":"Delivery brings the transport support payment into play."}},{"aktor":{"tr":"Şirket","en":"Company"},"baslik":{"tr":"Bedel ve primler ödenir","en":"Price and premiums are paid"},"aciklama":{"tr":"Kota tamamlama primi, pancar üretimini teşvik primi, temizleme ve yükleme primi.","en":"Quota completion premium, production incentive premium, cleaning and loading premium."},"secenekler":[{"tr":"İstihkak posa bedelsiz verilir","en":"Pulp is supplied free of charge"}]}]},"ciftci_sayisi":{"tur":"cizgi","bolen":1000,"ondalik":1,"baslik":{"tr":"Çiftçi azaldı, üretim yerinde durdu","en":"Fewer growers, the same harvest"},"birim":{"tr":"bin kişi · pancar üreticisi","en":"thousand people · beet growers"},"kaynak":"TÜRKŞEKER · Şeker Sektör Raporu 2025, Tablo 26 ve Tablo 27","not":{"tr":"Ülke genelinde üretici sayısı 2017'de 110.131 ile zirve yaptı, 2025'te 76.767'e indi: %30,3 azalma. Aynı aralıkta TÜRKŞEKER'in üreticisi %25,8, TÜRKŞEKER dışı %32,7 azaldı. İki satır ayrı ölçüdür ve biri diğerinin yerine kullanılamaz.","en":"Nationwide the number of growers peaked at 110,131 in 2017 and fell to 76,767 in 2025, a fall of 30.3%. Over the same span TÜRKŞEKER's growers fell by 25.8% and growers outside TÜRKŞEKER by 32.7%. The two lines are separate measures and neither stands for the other."},"seriler":[{"ad":{"tr":"Ülke geneli","en":"Nationwide"},"rol":"vurgu","noktalar":{"liste":[{"yil":2016,"ulke":105460,"turkseker":36400,"uretim":19592731},{"yil":2017,"ulke":110131,"turkseker":38028,"uretim":21149020},{"yil":2018,"ulke":106237,"turkseker":40240,"uretim":17436100},{"yil":2019,"ulke":88279,"turkseker":34424,"uretim":18054320},{"yil":2020,"ulke":93812,"turkseker":38238,"uretim":23025738},{"yil":2021,"ulke":86097,"turkseker":36821,"uretim":17767086},{"yil":2022,"ulke":77065,"turkseker":28427,"uretim":19253962},{"yil":2023,"ulke":99714,"turkseker":40132,"uretim":25250213},{"yil":2024,"ulke":93293,"turkseker":36109,"uretim":22413958},{"yil":2025,"ulke":76767,"turkseker":28219,"uretim":20801254}],"x":"yil","y":"ulke"}},{"ad":{"tr":"TÜRKŞEKER","en":"TÜRKŞEKER"},"rol":"ikincil","noktalar":{"liste":[{"yil":2016,"ulke":105460,"turkseker":36400,"uretim":19592731},{"yil":2017,"ulke":110131,"turkseker":38028,"uretim":21149020},{"yil":2018,"ulke":106237,"turkseker":40240,"uretim":17436100},{"yil":2019,"ulke":88279,"turkseker":34424,"uretim":18054320},{"yil":2020,"ulke":93812,"turkseker":38238,"uretim":23025738},{"yil":2021,"ulke":86097,"turkseker":36821,"uretim":17767086},{"yil":2022,"ulke":77065,"turkseker":28427,"uretim":19253962},{"yil":2023,"ulke":99714,"turkseker":40132,"uretim":25250213},{"yil":2024,"ulke":93293,"turkseker":36109,"uretim":22413958},{"yil":2025,"ulke":76767,"turkseker":28219,"uretim":20801254}],"x":"yil","y":"turkseker"}}]},"bugun_turkseker":{"tur":"kartlar","baslik":{"tr":"Bugün TÜRKŞEKER","en":"TÜRKŞEKER today"},"kaynak":"TÜRKŞEKER · Şeker Sektör Raporu 2025 ve 2024-2028 Stratejik Plan","not":{"tr":"Şeker fabrikalarının yanı sıra üç makine fabrikası, Elektromekanik Aygıtlar Fabrikası, Alkol Fabrikası, Tohum İşleme Fabrikası ve Şeker Enstitüsü kurumun bünyesinde. Personel rakamı 2022 fiili ortalamasıdır.","en":"Besides the sugar factories the institution runs three machine works, an electromechanical devices plant, an alcohol plant, a seed processing plant and the Sugar Institute. The staff figure is the 2022 actual average."},"kartlar":[{"ust":{"tr":"Fabrika","en":"Factories"},"baslik":{"tr":"14 şeker fabrikası","en":"14 sugar factories"},"govde":{"tr":"1990 öncesinde 30 fabrikası vardı. 2018'de on fabrika özelleştirildi, 2025'te Çarşamba MKE'ye devredildi.","en":"Before 1990 it had 30. Ten were privatised in 2018 and Çarşamba passed to MKE in 2025."}},{"ust":{"tr":"Kota","en":"Quota"},"baslik":{"tr":"%36,08 pay","en":"36.08% share"},"govde":{"tr":"2025/26 pazarlama yılında 1.023.820 ton A kotası. Pancar şekeri üretimindeki payı ise %32.","en":"An A quota of 1,023,820 tonnes for 2025/26. Its share of beet sugar production is 32%."}},{"ust":{"tr":"Çalışan","en":"Staff"},"baslik":{"tr":"6.024 kişi","en":"6,024 people"},"govde":{"tr":"2018'de 7.563 olan fiili ortalama 2022'de 5.652. Alt işverenle birlikte 10.535 kişi.","en":"The actual average was 7,563 in 2018 and 5,652 in 2022. With contractors, 10,535 people."}},{"ust":{"tr":"Sermaye","en":"Capital"},"baslik":{"tr":"Türkiye Varlık Fonu","en":"Türkiye Wealth Fund"},"govde":{"tr":"29 Nisan 2021 tarihli Cumhurbaşkanı Kararı ile sermayenin tamamı devredildi; aynı yıl Tarım ve Orman Bakanlığı ile ilgilendirildi.","en":"A Presidential Decision of 29 April 2021 transferred the entire capital; the same year it was attached to the Ministry of Agriculture and Forestry."}}]},"iki_model":{"tur":"kartlar","baslik":{"tr":"Pancar şekerini kim, nasıl üretiyor","en":"Who makes beet sugar, and how"},"kaynak":"USDA Foreign Agricultural Service · Production, Supply and Distribution","not":{"tr":"Dünya pancar şekeri üretimi 41.865 bin ton. Kartlar üretim büyüklüğünü ve örgütlenme biçimini yan yana koyuyor; rakamlar USDA'nın 2024 tahminleridir.","en":"World beet sugar output is 41,865 thousand tonnes. The cards set output against the form of organisation; the figures are USDA estimates for 2024."},"kartlar":[{"ust":{"tr":"Birinci","en":"First"},"baslik":{"tr":"Avrupa Birliği · 16.546 bin ton","en":"European Union · 16,546 thousand tonnes"},"govde":{"tr":"Dünya pancar şekerinin en büyük üreticisi; üretim kotası 2017'de kaldırıldı.","en":"The largest producer of beet sugar; its production quota was abolished in 2017."}},{"ust":{"tr":"İkinci","en":"Second"},"baslik":{"tr":"Rusya · 6.900 bin ton","en":"Russia · 6,900 thousand tonnes"},"govde":{"tr":"Pancar şekerinde ikinci sırada.","en":"Second in beet sugar."}},{"ust":{"tr":"Dördüncü","en":"Fourth"},"baslik":{"tr":"Türkiye · 3.100 bin ton","en":"Türkiye · 3,100 thousand tonnes"},"govde":{"tr":"Üretim kotayla planlanıyor; kamu, kooperatif ve özel sektör kotayı %36,08 · %35,42 · %28,49 paylaşıyor.","en":"Production is planned by quota; public, cooperative and private sectors hold 36.08% · 35.42% · 28.49% of it."}}]}}$dsr$::jsonb,
  array['TÜRKŞEKER', 'Türkiye Şeker Fabrikaları', 'şeker pancarı', 'pancar üreticisi', 'Şeker Fabrikası', 'şeker kotası', 'nişasta bazlı şeker', 'şeker üretimi', 'PANKOBİRLİK', 'Alpullu']::text[],
  null,
  null,
  null,
  'draft',
  '2026-11-25T21:00:00Z'::timestamptz,
  ('2026-11-25T21:00:00Z'::timestamptz + interval '14 days'),
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
 where dossier_id = (select id from public.country_dossiers where slug = 'turkseker');

insert into public.dossier_sections
  (dossier_id, ord, title_tr, title_en, body_tr, body_en, chart_keys, tur, gorsel)
select d.id, v.ord, v.title_tr, v.title_en, v.body_tr, v.body_en, v.chart_keys, v.tur, v.gorsel
from public.country_dossiers d
cross join (values
  (1::integer, $dsr$Alpullu, 26 Kasım 1926$dsr$, $dsr$Alpullu, 26 November 1926$dsr$, $dsr$26 Kasım 1926 günü Trakya'da, Babaeski yakınlarındaki Alpullu'da bir fabrika
işletmeye açıldı ve ilk Türk şekeri üretildi. O günün üzerinden bu kasımda
**100 yıl** geçiyor.

Fabrikanın temeli bir yıl kadar önce, 22 Aralık 1925'te atılmıştı. Montajı
**on bir ayda** bitirildi. Aynı yıl bir başka fabrikanın temeli daha
atılmıştı: Uşak'ta, 6 Kasım 1925'te. Uşak bir buçuk ay önce başladı, Alpullu
önce bitti. Uşak Şeker Fabrikası 17 Aralık 1926'da, Alpullu'dan 21 gün
sonra açıldı.

İki fabrika da ayrı birer şirkete aitti ve ikisi de Cumhuriyet'in ilk
yıllarının girişimleriydi. Şeker fabrikaları, Türkiye Cumhuriyeti'nin ilk
sanayi işletmeleri arasında sayılıyor. Türkiye'de şeker rejimi 1925'ten bu
yana özel mevzuat hükümlerine göre düzenleniyor; yani kanun, şekerden bir yıl
önce geldi.

O yıllarda şeker ithal edilen bir üründü ve pancar, iklimi ve toprak koşulları
uygun olan bu ülkede henüz sanayiye bağlanmamıştı. Alpullu ve Uşak bu bağı
kuran ilk iki tesis oldu.

1933 yılına kadar ülkenin şeker ihtiyacı bu iki fabrikanın üretimiyle kısmen
karşılandı. Sonra sırasıyla Eskişehir (5 Aralık 1933) ve Turhal (19 Ekim
1934) açıldı. Dört ayrı şirket halindeki bu dört fabrika, 6 Temmuz 1935'te üç
milli bankanın eşit paylarla ortak olduğu tek bir çatı altında toplandı:
**Türkiye Şeker Fabrikaları A.Ş.**, kısaca TÜRKŞEKER.

Bugün TÜRKŞEKER **14 şeker fabrikası** işletiyor. Bunların yanında üç makine
fabrikası, Elektromekanik Aygıtlar Fabrikası, Alkol Fabrikası, Tohum İşleme
Fabrikası ve Şeker Enstitüsü de kurumun bünyesinde.$dsr$, $dsr$On 26 November 1926, at Alpullu in Thrace, near Babaeski, a factory began
operating and the first Turkish sugar was produced. This November marks
**100 years** since that day.

The factory's foundations had been laid about a year earlier, on 22 December
1925. Its assembly was completed in **eleven months**. Another factory's
foundations had been laid that same year: at Uşak, on 6 November 1925. Uşak
started six weeks earlier; Alpullu finished first. The Uşak Sugar Factory
opened on 17 December 1926, 21 days after Alpullu.

Both factories belonged to separate companies, and both were ventures of the
Republic's first years. Sugar factories are counted among the first
industrial enterprises of the Republic of Türkiye. Sugar in Türkiye has been
governed by dedicated legislation since 1925 — which is to say the law
arrived a year before the sugar.

In those years sugar was an imported commodity, and beet, in a country whose
climate and soils suited it, had not yet been tied to industry. Alpullu and
Uşak were the first two plants to make that connection.

Until 1933 the country's sugar needs were met in part by these two
factories. Eskişehir followed on 5 December 1933 and Turhal on 19 October
1934. On 6 July 1935 these four factories, each held by a separate company,
were gathered under a single roof in which three national banks held equal
shares: **Türkiye Şeker Fabrikaları A.Ş.**, TÜRKŞEKER for short.

Today TÜRKŞEKER operates **14 sugar factories**. Alongside them the
institution runs three machine works, an electromechanical devices plant, an
alcohol plant, a seed processing plant and the Sugar Institute.$dsr$, array['kunye_turkseker']::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/turkseker/turkseker_alpullu_1928.jpg","atif":"Unknown author — CC BY 4.0","kaynak":null,"alt_tr":"İstanbul ve Trakya Şeker Fabrikaları'nın Alpullu Şeker ve İspirto Fabrikaları albümünden bir sayfa: Alpullu Sinanlı Köprüsü, 29 Aralık 1928.","alt_en":"A page from the Alpullu Sugar and Spirit Factories album of Istanbul and Trakya Sugar Factories: the Alpullu Sinanlı Bridge, 29 December 1928.","en_boy":1.4512}$dsr$::jsonb),
  (2, $dsr$İki şirket, iki temel$dsr$, $dsr$Two companies, two foundations$dsr$, $dsr$Türkiye'de şeker fabrikası kurma çalışmaları ilk defa **Uşaklı Molla
Ömeroğlu Nuri** adında bir çiftçi tarafından başlatıldı. Soyadı kanunundan
sonra aldığı soyadı Şeker'dir.

Girişim yalnız onun değildi. Uşak'ta çok sayıda yerel müteşebbisin
katılımıyla 19 Nisan 1923'te **600.000 lira** sermayeli **Uşak Terakki Ziraat
Türk Anonim Şirketi** kuruldu. Şirket, Cumhuriyet ilan edilmeden altı ay önce
kurulmuştu.

Bu ayrıntı kurumun karakteri hakkında bir şey söylüyor. Türkiye'nin şeker
sanayii bir bakanlık kararıyla değil, pancar yetiştiren bir adamın
girişimiyle ve hemşehrilerinin biriktirdiği sermayeyle başladı. Kanun, fabrika ve devlet şirketi
sonra geldi.

Uşak Terakki Ziraat T.A.Ş., 6 Kasım 1925'te ilk şeker fabrikasının temelini
attı; fabrika 17 Aralık 1926'da işletmeye açıldı.

Şirketin hisse senedi bugün elimizde. Üzerinde adı Osmanlı harfleriyle
yazılı, kenarlarında pancar ve başak motifleri, ortasında tarlada çalışan bir
traktör var. Senedin altında ellinin üzerinde kâr payı kuponu sıralanıyor.
Bir fabrikanın nasıl finanse edildiğini anlatan bir belge: hisse hisse,
kupon kupon.

Uşak'ta çalışmalar sürerken İstanbul'da da bir girişim vardı. Özel şahısların
ve bazı milli bankaların iştirakiyle 14 Haziran 1925'te **500.000 lira**
sermayeli **İstanbul ve Trakya Şeker Fabrikaları T.A.Ş.** kuruldu. Bu şirket
22 Aralık 1925'te Alpullu Şeker Fabrikası'nın temelini attı ve ilk Türk
şekerini üreten fabrika bu oldu.

İki şirketin sermayesi toplamda 1.100.000 lira. İkisi de hisse senedi
çıkardı.

Dört fabrika 1935'te birleştiğinde kurulan Türkiye Şeker Fabrikaları A.Ş.'nin
sermayesi **22 milyon lira**ydı. 10 yıl içinde ölçek 20 kat büyümüştü.
Birleşmenin gerekçesi belgede şöyle yazılı: tarımsal, teknik ve idari
çalışmaların koordine edilmesi, sermaye kaynaklarının birleştirilmesi ve
şeker politikasının tek elden yürütülmesi.

Bu üç gerekçeden sonuncusu kurumun bugünkü işini de tarif ediyor. TÜRKŞEKER
yalnız şeker üreten bir şirket değil; üretim planlamasının, pancar fiyatının
ve çiftçiyle yapılan sözleşmenin merkezinde duran bir kamu iktisadi
teşebbüsü.

Kuruluşun biçimi de dikkat çekici. Ortaklar üç milli bankaydı ve payları
eşitti — yani şirket doğrudan bir bakanlığın değil, bankaların elinde kuruldu.
Bugünkü sahiplik yapısı bunun uzağında: sermayenin tamamı 2021'den bu yana
Türkiye Varlık Fonu'nda ve kurum Tarım ve Orman Bakanlığı ile ilgilendirilmiş
durumda.

Bugün Uşak'ta pancar şekeri üreten bir fabrika bulunmuyor. 2025/26 pazarlama
yılında kota tahsis edilen 15 üreticinin listesinde Uşak yok. Buna karşılık
kurumun gayrimenkul kayıtlarında Uşak hâlâ duruyor.$dsr$, $dsr$Efforts to build a sugar factory in Türkiye were first begun by a farmer from
Uşak named **Molla Ömeroğlu Nuri**. The surname he took after the surname law
was Şeker — sugar.

The venture was not his alone. With the participation of many local
entrepreneurs in Uşak, **Uşak Terakki Ziraat Türk Anonim Şirketi** was
founded on 19 April 1923 with a capital of **600,000 lira**. The company was
established six months before the Republic was proclaimed.

The detail says something about the institution's character. Türkiye's sugar
industry began not with a ministerial decision but with the initiative of a
man who grew beet and with capital his fellow townspeople had put together.
The law, the factory and the state company came afterwards.

Uşak Terakki Ziraat laid the foundations of the first sugar factory on
6 November 1925; the factory opened on 17 December 1926.

The company's share certificate survives. Its name is printed on it in
Ottoman script, with beet and wheat-ear motifs along the edges and a tractor
working a field in the centre. More than fifty dividend coupons are arranged
below. It is a document that explains how a factory was financed: share by
share, coupon by coupon.

While work continued at Uşak, there was also a venture in Istanbul. With the
participation of private individuals and several national banks,
**İstanbul ve Trakya Şeker Fabrikaları T.A.Ş.** was founded on 14 June 1925
with a capital of **500,000 lira**. This company laid the foundations of the
Alpullu Sugar Factory on 22 December 1925, and it was this factory that made
the first Turkish sugar.

The two companies' capital came to 1,100,000 lira in total. Both issued
shares.

When the four factories merged in 1935, the capital of the resulting Türkiye
Şeker Fabrikaları A.Ş. was **22 million lira**. In 10 years the scale had
grown twentyfold. The reasons for the merger are set out in the record:
coordinating agricultural, technical and administrative work, combining
sources of capital, and conducting sugar policy from a single centre.

The last of those three also describes the institution's work today.
TÜRKŞEKER is not simply a company that makes sugar; it is a state economic
enterprise standing at the centre of production planning, of the beet price
and of the contract made with the grower.

The form of its founding is striking too. The partners were three national
banks and their shares were equal — the company was established in the hands
of banks rather than directly under a ministry. Today's ownership is some
distance from that: since 2021 the entire capital has been held by the
Türkiye Wealth Fund, and the institution is attached to the Ministry of
Agriculture and Forestry.

There is no beet sugar factory at Uşak today. Uşak does not appear among the
15 producers allocated quota for the 2025/26 marketing year. The
institution's property records, however, still list Uşak.$dsr$, '{}'::text[], 'belge', $dsr${"url":"https://tarimportali.net/dosya/turkseker/turkseker_usak_kurucular.jpg","atif":"The original uploader was chansey at Turkish Wikipedia — CC0","kaynak":null,"alt_tr":"Uşak Şeker Fabrikası'nın kurucuları. Tanju Bilgen'in kamuya bağışı. Kaynak çekim tarihini kaydetmiyor.","alt_en":"The founders of the Uşak Sugar Factory. Donated to the public by Tanju Bilgen. The source does not record when it was taken.","en_boy":1.3333}$dsr$::jsonb),
  (3, $dsr$Dört fabrika, tek çatı$dsr$, $dsr$Four factories, one roof$dsr$, $dsr$6 Temmuz 1935'te Alpullu, Uşak, Eskişehir ve Turhal fabrikaları tek şirkete
devredildi. Ortaklar üç milli bankaydı ve payları eşitti.

Şeker üretimi 1950 yılına kadar, zaman zaman genişletilen bu dört fabrikayla
yürüdü. 15 yıl boyunca ülkenin şekeri dört bacadan çıktı.

Aynı dönemde bir başka örgütlenme hattı kuruldu: pancar ekicilerinin
kooperatifleşmesi. Bu hareket, bugün Türkiye şekerinin üçte birini üreten
kooperatif şirketlerinin kökenidir. Amasya, Kayseri ve Konya şeker
fabrikaları kuruluşlarından 1990'ların başına kadar kendi yönetim kurulları
adına TÜRKŞEKER tarafından sevk ve idare edildi; Amasya 1991'de, Kayseri ve
Konya 1992'de bu yetkiyi kaldırarak PANKOBİRLİK bünyesine geçti.

Kooperatifleşme hareketinin kendisi de kurumun işiydi. PANKOBİRLİK —
Pancar Ekicileri Kooperatifleri Birliği — mahalli pancar ekicileri
kooperatifleri ile TÜRKŞEKER'in ortak teşebbüsleriyle kuruldu. Amacı pancar
tarımının gelişmesi ve mahalli kooperatiflerin ekonomik ve teknik
noksanlıklarını gidererek haklarının korunmasıydı. Yani bugün TÜRKŞEKER ile
kotayı paylaşan kooperatif şirketleri, bir zamanlar aynı kurumun kurduğu
yapıdan çıktı.

Kurumun yaptığı iş bu yıllarda yalnız şeker üretmek değildi. Pancar tarımında
maliyetleri düşürmek ve üretici gelirini yükseltmek için toprak işleme,
kaliteli tohum kullanımı, gübreleme, sulama ve mekanizasyon çalışmaları
yürütüldü. Çiftçiye tarım aleti, gübre ve nakdi yardım verildi; çiftçinin
eğitimine ve kültürüne katkı sağlandığı da kurumun kendi kaydında yazılı.

Şeker sanayii bu yıllarda bir başka şey daha yaptı: pancar yetiştiren geniş
bir çiftçi ailesiyle sürekli bir ilişki kurdu. Bu ilişkinin biçimi sözleşmeydi
ve Türkiye'de sözleşmeli üretimin ilk örneklerinden biri olarak kaldı.$dsr$, $dsr$On 6 July 1935 the Alpullu, Uşak, Eskişehir and Turhal factories were
transferred to a single company. The partners were three national banks and
their shares were equal.

Sugar production was carried on until 1950 by these four factories, expanded
from time to time. For 15 years the country's sugar came from four chimneys.

A second line of organisation was built in the same period: the formation of
beet growers' cooperatives. This movement is the origin of the cooperative
companies that today produce a third of Türkiye's sugar. The Amasya, Kayseri
and Konya sugar factories were run by TÜRKŞEKER on behalf of their own boards
from their founding until the early 1990s; Amasya withdrew that authority in
1991 and Kayseri and Konya in 1992, passing to PANKOBİRLİK.

The cooperative movement was itself the institution's work. PANKOBİRLİK — the
Union of Beet Growers' Cooperatives — was founded through the joint ventures
of local beet growers' cooperatives and TÜRKŞEKER. Its purpose was to develop
beet farming and to protect the rights of local cooperatives by making good
their economic and technical shortcomings. The cooperative companies that
share the quota with TÜRKŞEKER today thus came out of a structure the same
institution built.

The institution's work in these years was not only making sugar. To lower
costs in beet farming and raise growers' incomes, it carried out work on soil
preparation, the use of quality seed, fertilisation, irrigation and
mechanisation. Growers were given implements, fertiliser and cash support;
the institution's own record also notes its contribution to their education.

The sugar industry did something else in these years: it built a continuing
relationship with a large family of beet growers. The form of that
relationship was the contract, and it remains one of the first examples of
contract farming in Türkiye.$dsr$, '{}'::text[], 'belge', $dsr${"url":"https://tarimportali.net/dosya/turkseker/turkseker_usak_disaridan.jpg","atif":"The original uploader was chansey at Turkish Wikipedia — CC0","kaynak":null,"alt_tr":"Uşak Şeker Fabrikası, kuruluş dönemi. Mehmet Hacım'ın arşivinden; torunu Tanju Bilgen'in kamuya bağışı.","alt_en":"The Uşak Sugar Factory in its founding years. From the archive of Mehmet Hacım, donated to the public by his grandchild Tanju Bilgen.","en_boy":1.3333}$dsr$::jsonb),
  (4, $dsr$Dörtten otuza, sonra Özbekistan'a$dsr$, $dsr$From four to thirty, then Uzbekistan$dsr$, $dsr$1951'de hazırlanan **Şeker Sanayii'nin Tevsi Programı** ile yeni fabrika
kurma dönemine girildi. 1951-1956 arasında on bir yeni fabrika inşa edildi:
Adapazarı, Amasya, Konya, Kütahya, Burdur, Susurluk, Kayseri, Erzincan,
Erzurum, Elazığ ve Malatya. 1956'da fabrika sayısı **15**'e ulaştı.

Sonraki fabrikalarda dikkat çeken şey makinelerin nereden geldiğidir. 1962'de
Ankara ve 1963'te Kastamonu fabrikaları, sanayinin kendi geliştirdiği bir
makine fabrikası ile iki atölyede **%65'i imal edilerek** işletmeye alındı.
1977'de Afyon, 1982'de Muş ve Ilgın, 1983'te Bor, 1984'te Ağrı ve 1985'te
Elbistan fabrikalarının makine ve tesislerinin **%95'e varan** bölümü, beş
makine fabrikasında yapıldı.

Yani şeker sanayii bir noktadan sonra kendi fabrikasını kurmayı da öğrendi.
TÜRKŞEKER'in bugün hâlâ üç makine fabrikası ve bir Elektromekanik Aygıtlar
Fabrikası işletmesinin sebebi budur.

Yeni fabrikaların yer seçimi de bir tercihti. Ağrı, Erciş, Kars, Muş,
Elbistan, Erzurum — listenin önemli bir bölümü Doğu ve Güneydoğu Anadolu'da.
Pancar verimi bu bölgelerde ekolojik koşullar gereği düşük; bugün hâlâ Ağrı,
Erciş ve Kars üreticilerine bölgede pancar tarımının sürdürülebilmesi için
ayrı bir teşvik primi veriliyor.

Genişleme 1989'da Erciş, Ereğli ve Çarşamba, 1991'de Çorum, 1993'te Kars,
1998'de Yozgat ve 2001'de Kırşehir fabrikalarıyla sürdü. 1990'lara
gelindiğinde TÜRKŞEKER **30 fabrikayla** sektörde tek başınaydı. Yetmiş yılda
dört bacadan otuza çıkılmıştı.

Kendi fabrikasını kurabilen bir sanayinin bir sonraki adımı, başkası için
fabrika kurmaktır. TÜRKŞEKER bu adımı 1990'ların sonunda attı.

Kurum, 1996'da bir Türk inşaat firmasıyla konsorsiyum ortağı olarak
Özbekistan'da Horezm Şeker Fabrikası'nın yapımına başladı. Günde **3.000
ton** pancar işleme kapasitesine sahip fabrika 2 yılda tamamlandı ve
Cumhuriyet'in **75**'inci kuruluş yılı olan 1998'de işletmeye açıldı.

Fabrikanın makine ekipmanının tamamına yakını kurumun kendi makine
fabrikalarında imal edildi; yapım tamamen Türk mühendis ve işçisi
tarafından gerçekleştirildi.

Projenin bedeli **83.250.000 dolar**dı ve TÜRKŞEKER'in payı **%53,7**.

Alpullu'da bir fabrikanın montajı 11 ayda bitirilmişti. Yetmiş yıl sonra
aynı kurum, bir başka ülkede 2 yılda anahtar teslimi fabrika kuruyordu.$dsr$, $dsr$The **Programme for the Expansion of the Sugar Industry**, drawn up in 1951,
opened a period of factory building. Eleven new factories were built between
1951 and 1956: Adapazarı, Amasya, Konya, Kütahya, Burdur, Susurluk, Kayseri,
Erzincan, Erzurum, Elazığ and Malatya. By 1956 the number of factories had
reached **15**.

What stands out about the factories that followed is where their machinery
came from. The Ankara factory in 1962 and the Kastamonu factory in 1963 were
brought into operation with **65 per cent** of their equipment manufactured
in a machine works the industry had developed itself, together with two
workshops. For the Afyon factory in 1977, Muş and Ilgın in 1982, Bor in 1983,
Ağrı in 1984 and Elbistan in 1985, up to **95 per cent** of the machinery and
plant was made in five machine works.

The sugar industry, in other words, learned past a certain point to build its
own factories as well. That is why TÜRKŞEKER still runs three machine works
and an electromechanical devices plant today.

The siting of the new factories was a choice too. Ağrı, Erciş, Kars, Muş,
Elbistan, Erzurum — a substantial part of the list lies in Eastern and
South-Eastern Anatolia. Beet yields are low in these regions for ecological
reasons; growers in Ağrı, Erciş and Kars are still given a separate incentive
premium so that beet farming can be sustained there.

Expansion continued with Erciş, Ereğli and Çarşamba in 1989, Çorum in 1991,
Kars in 1993, Yozgat in 1998 and Kırşehir in 2001. By the 1990s TÜRKŞEKER
stood alone in the sector with **30 factories**. In seventy years four
chimneys had become thirty.

The next step for an industry that can build its own factory is to build one
for somebody else. TÜRKŞEKER took that step at the end of the 1990s.

In 1996 the company began building the Khorezm Sugar Factory in Uzbekistan
as a consortium partner with a Turkish construction firm. With a capacity of
**3,000 tonnes** of beet a day, the factory was completed in 2 years and
opened in 1998, the **75th** anniversary of the Republic.

Almost all of the factory's machinery was manufactured in the company's own
machine works, and the construction was carried out entirely by Turkish
engineers and workers.

The project was worth **83,250,000 dollars**, and TÜRKŞEKER's share of it
was **53.7%**.

At Alpullu, the assembly of a factory had been finished in 11 months. Seventy
years later the same company was building a turnkey factory in another
country in 2 years.$dsr$, array['fabrikalarin_acilisi']::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/turkseker/turkseker_eskisehir.jpg","atif":"Aycan at Turkish Wikipedia — CC BY-SA 3.0","kaynak":null,"alt_tr":"Eskişehir Şeker Fabrikası. Kaynak çekim tarihini kaydetmiyor.","alt_en":"The Eskişehir Sugar Factory. The source does not record when it was taken.","en_boy":1.3343}$dsr$::jsonb),
  (5, $dsr$Şeker Kanunu: 1956'dan 2001'e$dsr$, $dsr$The Sugar Law: from 1956 to 2001$dsr$, $dsr$Şeker, Türkiye'de serbest piyasada kendi haline bırakılmış bir ürün değil.
Sektör 1925'ten bu yana özel mevzuatla düzenleniyor. İlk kapsamlı çerçeveyi
22 Haziran 1956 tarihli **6747 sayılı Şeker Kanunu** kurdu.

Bugünkü düzeni ise 19 Nisan 2001'de yürürlüğe giren **4634 sayılı Şeker
Kanunu** belirliyor. Kanunun getirdiği temel araç **kota**dır: ülke içinde
pazarlanacak şeker miktarı Cumhurbaşkanı tarafından tahsis edilen kotalarla
belirleniyor.

Üretim planlaması "yıllık yurtiçi şeker ihtiyacı ve güvenlik stoku" esasına
göre yapılıyor. Gerekçesi belgede üç başlıkta yazılı: ülkenin coğrafi konumu
nedeniyle şeker fiyatlarının dünya fiyatlarına göre yüksek olması, Dünya
Ticaret Örgütü taahhütleri kapsamında şeker ihracatına sübvansiyon
uygulanamaması ve pancardan şeker üretiminin yarattığı katma değer.

Kanun fiyatı da düzenliyor. A kotası pancar fiyatı, fabrika işleten gerçek ve
tüzel kişilerle üretici temsilcileri arasında **pancar ekiminden önce**;
yıllık enflasyon oranı, üretici maliyetlerindeki artış, dünya pancar
fiyatları ve alternatif ürün paritesi dikkate alınarak belirleniyor. Şekerin
satış fiyatını ise fabrikalar serbestçe belirliyor.

Kotanın üç harfi var. **A kotası**, yurt içinde pazarlanacak şeker.
**B kotası**, A kotasının güvenlik payı. **C şekeri** ise A ve B kotaları
dışında üretilen, yurt içinde pazarlanamayan ve ihraç kaydıyla satılabilen
şeker. Şirketler pazarlanamayan A kotasının tamamını ya da bir bölümünü,
aynı pazarlama yılı içinde ihraç edilmek kaydıyla C şekerine aktarabiliyor;
bu yetki Cumhurbaşkanı'nda.

Kanun ayrıca bir **depolama prim ve kesinti sistemi** kurdu. Amacı belgede
şöyle yazılı: şekerin üreticiden tüketiciye istikrarlı bir fiyattan
ulaşmasını sağlamak ve şeker arzını spekülatif amaçlı girişimlerden
koruyarak düzenliliğini sürdürmek.

Bu araçların gerekçesi 1990'ların deneyiminde. Kanun yürürlüğe girmeden önce
sektör, dönemsel olarak değişen ithalatçı ve ihracatçı konumuyla istikrarsız
bir üretim seyri izliyordu; özellikle 1990'lı yıllarda üretimdeki
dalgalanmalar sektörü kimi zaman ithalat riskiyle, kimi zaman stok sorunuyla
karşı karşıya bıraktı.

4634 sayılı Kanun öncesinde kurma izni almış üç özel fabrika da bu dönemde
üretime başladı: Çumra 2004/2005, Boğazlıyan ve Aksaray 2006/2007 pazarlama
yıllarında.$dsr$, $dsr$Sugar in Türkiye is not a product left to itself in an open market. The
sector has been governed by dedicated legislation since 1925. The first
comprehensive framework was established by **Sugar Law 6747** of 22 June 1956.

Today's order is set by **Sugar Law 4634**, in force since 19 April 2001. The
instrument the law introduced is the **quota**: the amount of sugar to be
marketed within the country is set by quotas allocated by the President.

Production planning follows the principle of "annual domestic sugar
requirement and safety stock". Three reasons are given in the record: sugar
prices are high relative to world prices because of the country's geographic
position; export subsidies for sugar cannot be applied under commitments to
the World Trade Organization; and beet sugar production creates value added
that cannot be disregarded.

The law regulates price as well. The A quota beet price is set **before
sowing**, between the natural and legal persons operating factories and
growers' representatives, with regard to the annual rate of inflation, the
rise in growers' costs, world beet prices and the parity of alternative
crops. The sale price of sugar is set freely by the factories.

The quota has three letters. **A quota** is the sugar to be marketed
domestically. **B quota** is its safety margin. **C sugar** is sugar produced
outside the A and B quotas, which cannot be marketed domestically and may be
sold only on condition of export. Companies may transfer all or part of an
unmarketed A quota to C sugar, provided it is exported within the same
marketing year; the authority to allow this rests with the President.

The law also established a **storage premium and deduction system**. Its
purpose is recorded as ensuring that sugar reaches the consumer from the
producer at a stable price, and that the regularity of sugar supply is
protected from speculative ventures.

The reason for these instruments lies in the experience of the 1990s. Before
the law came into force the sector followed an unstable course, its position
shifting between importer and exporter from period to period; fluctuations in
output in the 1990s in particular left it facing now the risk of imports, now
the problem of stocks.

Three private factories that had obtained permits before Law 4634 also began
production in this period: Çumra in the 2004/2005 marketing year, Boğazlıyan
and Aksaray in 2006/2007.$dsr$, '{}'::text[], 'belge', $dsr${"url":"https://tarimportali.net/dosya/turkseker/turkseker_bogazliyan.jpg","atif":"JFLM — Public domain","kaynak":null,"alt_tr":"Boğazlıyan Şeker Fabrikası, Türkiye, Ocak 2007. 2006'da Fransız ve Türk şirketlerinden kurulu bir ortaklıkça yapıldı.","alt_en":"The Boğazlıyan sugar factory, Türkiye, January 2007. Built in 2006 by a consortium of French and Turkish companies.","en_boy":1.3333}$dsr$::jsonb),
  (6, $dsr$Kota üçe bölünür$dsr$, $dsr$The quota divides in three$dsr$, $dsr$2025/26 pazarlama yılında Türkiye'nin toplam A kotası **2.910.000 ton**.
Bunun 2.837.250 tonu pancar şekeri, 72.750 tonu nişasta bazlı şeker.

Pancar şekeri kotası 15 üreticiye dağıtılmış durumda ve dağılım üç kesime
ayrılıyor:

| kesim | şirket | A kotası (ton) | pay |
|---|---|---|---|
| Kamu · TÜRKŞEKER | 1 | 1.023.820 | **%36,08** |
| Kooperatif | 3 | 1.005.010 | **%35,42** |
| Özel | 11 | 808.420 | **%28,49** |

Üç kesim neredeyse eşit. Tek bir şirket olan TÜRKŞEKER, 14 fabrikasıyla
kotanın üçte birinden biraz fazlasını tutuyor. Kooperatif kesimi üç şirketten
oluşuyor: Kayseri Şeker (Kayseri, Boğazlıyan, Turhal), Konya Şeker (Konya,
Çumra) ve Amasya Şeker. Özel kesimde 11 şirket var ve en büyüğü Afyon'daki
Doğuş Yiyecek ve İçecek, %4,65 payla.

Listenin en küçüğü ise bir adı taşıyor: **Binbirgıda Tarım Ürünleri A.Ş.,
Alpullu**. Kotası 26.680 ton, pancar şekerinin **%0,94**'ü. İlk Türk şekerinin
üretildiği fabrika, bugün 15 üreticinin en küçüğü.

Kooperatif kesiminin iki büyük şirketi tek başına TÜRKŞEKER'in yarısına
yaklaşıyor: Kayseri Şeker %16,68, Konya Şeker %16,12 payla. Özel kesim ise
dağınık: on bir şirketin **hepsinin** payı %5'in altında ve en büyüğü
%4,65.

Kota yalnız şeker için değil, pancar için de bağlayıcı. Üretim, şirketlere
tahsis edilen pancar şekeri kotalarının üretim garantisi için, belirlenen
ekim alanlarında, üreticiler ve temsilcileriyle şirketler arasında sözleşme
düzenlenerek kotalı yapılıyor. Yani kota tarladan başlıyor.

TÜRKŞEKER'in payı zaman içinde değişti. 2002/03 pazarlama yılında Türkiye
toplam pancar şekeri üretiminin **%74'ü** TÜRKŞEKER tarafından üretiliyordu;
2025/26'da bu oran **%32**. Fabrika sayısıyla orantılı olarak azaldı.$dsr$, $dsr$For the 2025/26 marketing year Türkiye's total A quota is **2,910,000
tonnes**: 2,837,250 tonnes of beet sugar and 72,750 tonnes of starch-based
sugar.

The beet sugar quota is distributed among 15 producers, and the distribution
falls into three sectors:

| sector | companies | A quota (tonnes) | share |
|---|---|---|---|
| Public · TÜRKŞEKER | 1 | 1,023,820 | **36.08%** |
| Cooperative | 3 | 1,005,010 | **35.42%** |
| Private | 11 | 808,420 | **28.49%** |

The three sectors are almost equal. TÜRKŞEKER, a single company, holds a
little more than a third of the quota with its 14 factories. The cooperative
sector consists of three companies: Kayseri Şeker (Kayseri, Boğazlıyan,
Turhal), Konya Şeker (Konya, Çumra) and Amasya Şeker. The private sector has
eleven companies, the largest being Doğuş Yiyecek ve İçecek at Afyon with
4.65%.

The two large cooperative companies together approach TÜRKŞEKER's own share:
Kayseri Şeker holds 16.68% and Konya Şeker 16.12%. The private sector is
scattered: **all eleven** of its companies hold less than 5%, and the largest
holds 4.65%.

The quota binds beet as well as sugar. Production is carried out under quota,
in designated sowing areas, through contracts drawn up between growers or
their representatives and the companies, in order to guarantee the output of
the beet sugar quota allocated to each company. The quota, in other words,
begins in the field.

The smallest entry on the list carries a particular name: **Binbirgıda Tarım
Ürünleri A.Ş., Alpullu**. Its quota is 26,680 tonnes, **0.94%** of beet
sugar. The factory where the first Turkish sugar was made is today the
smallest of the 15 producers.

TÜRKŞEKER's share has changed over time. In the 2002/03 marketing year
**74 per cent** of Türkiye's total beet sugar output was produced by
TÜRKŞEKER; in 2025/26 the figure is **32 per cent**. It fell in proportion to
the number of factories.$dsr$, array['kota_uc_kesim', 'sirket_kotalari']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/turkseker/turkseker_pancar_tarla.jpg","atif":"Rasbak — CC BY-SA 3.0","kaynak":null,"alt_tr":"Şeker pancarı tarlası, 30 Temmuz 2018. Kaynak ülkeyi kaydetmiyor.","alt_en":"A sugar beet field, 30 July 2018. The source does not record the country.","en_boy":1.4988}$dsr$::jsonb),
  (7, $dsr$Nişastadan gelen şeker$dsr$, $dsr$Sugar from starch$dsr$, $dsr$Türkiye'de iki tür şeker üretiliyor. Biri pancardan gelen sakaroz kökenli
şeker; diğeri mısır, buğday ve patates gibi nişasta içeren hammaddelerden
elde edilen **nişasta bazlı şeker** — kısaca NBŞ. Sektörde 15 pancar şekeri
üreticisinin yanında 5 NBŞ üreticisi bulunuyor.

NBŞ de kotaya tabi ve kotası son sekiz yılda köklü biçimde değişti:

| pazarlama yılı | NBŞ kotası | toplam A kotası içindeki payı |
|---|---|---|
| 2017/2018 | 267 bin ton | %9,57 |
| 2018/2019 | 135 bin ton | %5,00 |
| 2019/2020 | 67,5 bin ton | %2,50 |
| 2025/2026 | 72,75 bin ton | %2,50 |

İki yılda **%74,7** azalma. Değişikliğin dayanağı 7103 sayılı Kanun: 47'nci
madde, ülke toplam A kotasının %10'u olan NBŞ kotasını %5'e indirdi. Aynı
kanuna eklenen Geçici 11'inci madde ise kota indiriminden doğan fazlayı
**Türkiye Şeker Fabrikaları A.Ş.'ye aktardı**. 2019/2020 pazarlama yılından
itibaren oran her yıl Cumhurbaşkanı kararıyla %2,5 olarak belirleniyor.

Bugün ülkenin yıllık şeker ihtiyacının %95'i pancar şekeri, %5'i nişasta bazlı
şeker ile karşılanmak üzere programlanıyor.

2025/26 NBŞ kotası beş şirkete dağılmış durumda: Cargill %43,84, ADM %31,11,
PNS Pendik Nişasta %14,20, Tat Nişasta %6,44 ve Sunar Mısır %4,41. NBŞ için B
kotası tahsis edilmiyor.

Kotanın kapsamadığı bir alan daha var: ihraç amaçlı üretim. Nişasta bazlı
şekerde dış ticaret yurt içi kotadan bağımsız işliyor ve ihracat ithalatın
çok üzerinde. 2025'te 23.000 ton NBŞ ithal edilirken 321.500 ton ihraç
edildi. 2021'de ihracat 408.117 tona kadar çıkmıştı.

Nişasta bazlı tatlandırıcılar doğrudan tüketilmiyor; daha çok şekerli mamul
sanayiinde, hammadde olarak kullanılıyor.$dsr$, $dsr$Two kinds of sugar are produced in Türkiye. One is sucrose-based sugar from
beet; the other is **starch-based sugar**, obtained from raw materials
containing starch such as maize, wheat and potato. Alongside the 15 beet
sugar producers the sector has 5 starch-based sugar producers.

Starch-based sugar is subject to quota as well, and its quota has changed
fundamentally over the past eight years:

| marketing year | starch-based quota | share of total A quota |
|---|---|---|
| 2017/2018 | 267 thousand tonnes | 9.57% |
| 2018/2019 | 135 thousand tonnes | 5.00% |
| 2019/2020 | 67.5 thousand tonnes | 2.50% |
| 2025/2026 | 72.75 thousand tonnes | 2.50% |

A fall of **74.7 per cent** in two years. The basis for the change is Law
7103: article 47 reduced the starch-based quota from 10 per cent of the
national A quota to 5 per cent. Provisional article 11, added to the same
law, transferred the surplus arising from the reduction **to Türkiye Şeker
Fabrikaları A.Ş.** From the 2019/2020 marketing year the rate has been set at
2.5 per cent each year by Presidential decision.

The country's annual sugar requirement is now programmed to be met 95 per
cent from beet sugar and 5 per cent from starch-based sugar.

The 2025/26 starch-based quota is divided among five companies: Cargill
43.84%, ADM 31.11%, PNS Pendik Nişasta 14.20%, Tat Nişasta 6.44% and Sunar
Mısır 4.41%. No B quota is allocated for starch-based sugar.

There is one area the quota does not cover: production for export. Foreign
trade in starch-based sugar runs independently of the domestic quota, and
exports stand far above imports. In 2025, 23,000 tonnes were imported and
321,500 tonnes exported; exports had reached 408,117 tonnes in 2021.

Starch-based sweeteners are not consumed directly; they are used mainly as a
raw material in the confectionery and processed food industries.$dsr$, array['nbs_kotasi']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/turkseker/turkseker_misir_tesisi.jpg","atif":"Ammodramus — Public domain","kaynak":null,"alt_tr":"Archer Daniels Midland'ın mısır işleme tesisi, Columbus, Nebraska, ABD, 15 Aralık 2009.","alt_en":"The Archer Daniels Midland corn-processing plant, Columbus, Nebraska, USA, 15 December 2009.","en_boy":2.6928}$dsr$::jsonb),
  (8, $dsr$Tohumdan şekere$dsr$, $dsr$From seed to sugar$dsr$, $dsr$Pancarın şekere dönüşü tarlada değil, tohumda başlıyor. TÜRKŞEKER tohumu
dışarıdan almıyor; kendi üretiyor.

Kurumun bünyesinde bir Tohum İşleme Fabrikası ve bir Şeker Enstitüsü var.
Enstitüde yürütülen ıslah çalışmaları sonucunda iki yerli pancar çeşidi
tescil edildi: **Türkşeker 2023** ve **Türkşeker 2053**. İki çeşit de
üreticiyle buluşturuldu ve tarlaya girdi.

Kurumun kendi anlatımında zincir şöyle kuruluyor: tohum Ar-Ge merkezinde
geliştiriliyor, sözleşmeyle çiftçiye ektiriliyor, lojistik firmalar
aracılığıyla fabrikaya taşınıyor, işleniyor ve paketleniyor.

Tohumun yerli olması bir tercih değil, bir bağımlılık meselesi. Şeker
pancarı tohumu dünyada birkaç şirketin elinde; kendi çeşidini tescil
ettirebilen bir ülke, ekeceği şeyin kaynağını da elinde tutuyor.

Türkiye'de şeker pancarı; Doğu Karadeniz, Ege ve Akdeniz'in sahil şeridi ile
Güneydoğu Anadolu dışındaki bütün bölgelerde yetiştiriliyor. 2025'te ekilen
alanların **%26'sından fazlası** Konya'da; onu Eskişehir ve Yozgat izliyor.

Pancar bir münavebe bitkisidir: aynı tarlaya bölgesel özelliklere göre dört
ya da üç yılda bir ekilir. Bu, pancar üreticisinin sayısıyla ekim alanı
arasındaki ilişkiyi de açıklıyor — aynı çiftçi her yıl pancar ekmiyor.

Sektörün kendi tarifine göre pancarın tarladaki karşılığı şekerden ibaret
değil. Kendinden sonra ekilecek üründe verim artışı sağlıyor; ekim yapılan
alana eşdeğer bir orman alanına kıyasla üç kat daha fazla oksijen üretiyor;
alternatif ürünlere göre daha fazla istihdam imkânı veriyor. Pancar tarımı
ayrıca taşımacılık ile tarım alet ve makineleri başta olmak üzere birçok
sanayinin gelişmesine katkı sağlıyor, gübre ve ilaç gibi girdilerin
kullanımıyla endüstriyel sektörü besliyor.

Kurumun kendi değerlendirmesinde bir başlık daha var: şeker pancarı tarımı
çiftçiyi köye ve tarlaya bağlayarak ailenin bütün fertlerine iş imkânı
sağlıyor, göçün önlenmesinde ve bölgelerarası gelişmişlik farkının
azaltılmasında rol oynuyor.

Hektar başına alınan pancar altmış yılda üçe katlandı. 1961'de hektardan
**22.073 kilogram** pancar alınıyordu; 2024'te **70.925 kilogram**. Artış
**%221**.

Pancardan şekere geçişte oran şöyle: 2024'te işlenen 22,4 milyon ton pancardan
yaklaşık 3,1 milyon ton şeker çıktı. Yani pancarın ağırlıkça **%13,8**'i
şeker olarak elde ediliyor.

Üretimin coğrafyası da yoğun. 2025'te toplam pancar üretiminin %30-33'ü
Konya'dan, %7-9'u Eskişehir'den karşılandı; bir bölümü de Yozgat'tan geldi.
Kayseri ve Afyonkarahisar da listenin üst sıralarında. Ekim alanı ile üretim
sıralaması birbirini izliyor: pancar, ekildiği yerde işleniyor, çünkü
hasattan sonra uzağa taşınması ekonomik değil. Fabrikaların yer seçimini de
bu belirledi.

Bir rakam daha var ve ölçülmüş bir sıfırdır: Türkiye'nin **kamış şekeri
üretimi yok**. Ülkede tüketilen kristal şekerin tamamı pancardan geliyor.

Dünya ölçeğinde pancar şekeri üretimi 41,9 milyon ton civarında. Sıralamada
Avrupa Birliği 16,5 milyon tonla birinci, Rusya 6,9 milyon tonla ikinci,
Amerika Birleşik Devletleri 4,9 milyon tonla üçüncü. **Türkiye 3,1 milyon
tonla dördüncü.**$dsr$, $dsr$The turning of beet into sugar does not begin in the field but in the seed.
TÜRKŞEKER does not buy its seed from outside; it produces its own.

The company runs a Seed Processing Factory and a Sugar Institute. Breeding
work at the institute has produced two registered domestic beet varieties:
**Türkşeker 2023** and **Türkşeker 2053**. Both have been put into growers'
hands and sown.

In the company's own account the chain runs like this: the seed is developed
at the R&D centre, sown by contracted farmers, carried to the factory by
logistics firms, processed and packed.

Domestic seed is not a preference but a question of dependence. Sugar beet
seed worldwide is in the hands of a few companies; a country able to register
its own variety also keeps hold of the source of what it sows.

Sugar beet is grown in every region of Türkiye except the Eastern Black Sea,
the coastal strips of the Aegean and the Mediterranean, and South-Eastern
Anatolia. More than **26 per cent** of the area sown in 2025 was in Konya,
followed by Eskişehir and Yozgat.

Beet is a rotation crop: it is sown in the same field once every four or
three years depending on regional conditions. This also explains the relation
between the number of beet growers and the area sown — the same farmer does
not sow beet every year.

By the sector's own account what beet leaves in the field is not only sugar.
It raises the yield of the crop that follows it; it produces three times as
much oxygen as an equivalent area of forest; and it offers more employment
than the alternatives. Beet farming also contributes to the development of
many industries, transport and agricultural machinery above all, and feeds
the industrial sector through the use of inputs such as fertiliser and crop
protection.

There is a further heading in the institution's own assessment: beet farming
ties the farmer to the village and the field, provides work for every member
of the family, and plays a part in preventing migration and in reducing
differences in development between regions.

The beet taken from a hectare has tripled in sixty years. In 1961 a hectare
yielded **22,073 kilograms** of beet; in 2024, **70,925 kilograms**. The rise
is **221 per cent**.

Production is geographically concentrated. In 2025, 30 to 33 per cent of
total beet output came from Konya and 7 to 9 per cent from Eskişehir, with a
further share from Yozgat; Kayseri and Afyonkarahisar also stand near the top
of the list. The rankings for sown area and for output follow one another:
beet is processed where it is grown, because carrying it far after harvest is
not economic. This governed the siting of the factories as well.

The ratio in the passage from beet to sugar runs as follows: in 2024 some 3.1
million tonnes of sugar came from 22.4 million tonnes of beet processed.
About **13.8 per cent** of the beet, by weight, is obtained as sugar.

There is one more figure, and it is a measured zero: Türkiye produces **no
cane sugar**. All of the crystal sugar consumed in the country comes from
beet.

World beet sugar output is around 41.9 million tonnes. The European Union
ranks first with 16.5 million tonnes, Russia second with 6.9 million, the
United States third with 4.9 million. **Türkiye is fourth with 3.1 million
tonnes.**$dsr$, array['pancar_verimi', 'dunya_pancar_sekeri']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/turkseker/turkseker_s11_tohum_el.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","kaynak":null,"alt_tr":"Ekimi yapılan tarlada şeker pancarı tohumu, 18 Şubat 2022.","alt_en":"Sugar beet seed in a field being sown, 18 February 2022.","en_boy":1.4869}$dsr$::jsonb),
  (9, $dsr$Çiftçi pancarını nasıl satar$dsr$, $dsr$How a grower sells their beet$dsr$, $dsr$Şeker pancarı, sözleşmeli üretimin Türkiye'de **ilk ve en yaygın** uygulandığı
üründür. Çiftçi pancarını pazara götürüp satmıyor; ekimden önce imzaladığı bir
sözleşmeyle satıyor.

Yol şöyle işliyor.

**Sözleşme.** Her yıl, üreticiler ile şirketler arasında "Şeker Pancarı
Üretim Sözleşmesi" düzenleniyor. Sözleşme kotaya bağlı: şirkete tahsis edilen
pancar şekeri kotasının üretim garantisi için, belirlenen ekim alanlarında
yapılıyor.

**Fiyat.** A kotası pancar fiyatı ekimden önce belli oluyor. Çiftçi tarlaya
girerken ürününün fiyatını biliyor.

**Avans.** Şirketler sözleşme yapan üreticilere tohum ve gübre gibi ayni
destekler ile nakdi avanslar veriyor. Bu ödemelerle, pancar teslim
edilmeden önce bedelin yaklaşık **%35'i faiz yansıtılmaksızın** üreticiye
ödeniyor.

**Teslim ve primler.** Teslimin ardından kota tamamlama primi, pancar
üretimini teşvik primi, pancar temizleme ve yükleme primi ile nakliye destek
ödemesi devreye giriyor. Ekolojik özellikleri gereği verimi düşük olan Doğu
Anadolu'da — Ağrı, Erciş, Kars — ayrıca pancar üretimini teşvik primi
veriliyor. Şeker üretiminden artan posa, üreticiye bedelsiz veriliyor.

Bu düzenin bir de şirket tarafı var. Pancar üreticiden **peşin** alınıyor;
şekerin satış geliri ise üretimin ardından yıl boyunca yapılan satışlardan
elde ediliyor. Arada kalan süre, dünyadaki bütün şeker üreticileri gibi
Türkiye'dekileri de hammadde alım ve üretim döneminde ciddi bir finansman
ihtiyacıyla karşı karşıya bırakıyor. Kullanılan kredinin büyük bölümü,
çiftçiye faizsiz ödenen avanslarla nakliye ve diğer destek ödemelerinin
zamanında yapılabilmesi için kullanılıyor.

Üretici sayısı son yıllarda azaldı. Ülke genelinde pancar üreticisi 2017'de
**110.131** kişiyle zirve yaptı; 2025'te **76.767**. Düşüş **%30,3**. Aynı
aralıkta TÜRKŞEKER'in üreticisi %25,8, TÜRKŞEKER dışındaki üreticiler %32,7
azaldı. Buna karşılık pancar üretimi yerinde durdu: 2017'de 21,1 milyon ton,
2025'te 20,8 milyon ton. Daha az çiftçi, aynı hasat.$dsr$, $dsr$Sugar beet is the crop for which contract farming was **first and is most
widely** used in Türkiye. The grower does not take beet to a market and sell
it; they sell it under a contract signed before sowing.

The route runs as follows.

**The contract.** Each year a "Sugar Beet Production Contract" is drawn up
between growers and companies. The contract is tied to quota: it is made in
designated sowing areas, to guarantee the output of the beet sugar quota
allocated to the company.

**The price.** The A quota beet price is known before sowing. The grower
knows the price of the crop as they enter the field.

**The advance.** Companies provide growers who sign contracts with support in
kind, such as seed and fertiliser, and with cash advances. Through these
payments about **35 per cent** of the price is paid to the grower before the
beet is delivered, with no interest charged.

**Delivery and premiums.** After delivery the quota completion premium, the
production incentive premium, the cleaning and loading premium and the
transport support payment come into play. In Eastern Anatolia — Ağrı, Erciş,
Kars — where yields are low for ecological reasons, a further production
incentive premium is paid. The pulp left over from sugar production is
supplied to the grower free of charge.

There is a company side to this arrangement as well. Beet is bought from the
grower **for cash**, while the revenue from sugar is earned through sales
made over the course of the year that follows production. The interval
leaves Turkish sugar producers, like all others in the world, with a
substantial financing requirement during the raw material purchase and
production season. Most of the credit used goes to making the interest-free
advances to growers, and the transport and other support payments, on time.

The number of growers has fallen in recent years. Beet growers nationwide
peaked at **110,131** in 2017; in 2025 there were **76,767**. The fall is
**30.3 per cent**. Over the same span TÜRKŞEKER's growers fell by 25.8 per
cent and growers outside TÜRKŞEKER by 32.7 per cent. Beet output, by
contrast, held steady: 21.1 million tonnes in 2017 and 20.8 million tonnes in
2025. Fewer growers, the same harvest.$dsr$, array['pancarin_yolu', 'ciftci_sayisi']::text[], 'akis', $dsr${"url":"https://tarimportali.net/dosya/turkseker/turkseker_pancar.jpg","atif":"Okt154 — CC BY-SA 4.0","kaynak":null,"alt_tr":"Şeker pancarı, 25 Mart 2016. Kaynak ili kaydetmiyor.","alt_en":"Sugar beet, 25 March 2016. The source does not record the province.","en_boy":0.9248}$dsr$::jsonb),
  (10, $dsr$Uydudan tarlaya$dsr$, $dsr$From satellite to field$dsr$, $dsr$Sözleşme ekimden önce imzalanıyor, ama tarlada olup biten yıl boyunca
izleniyor — artık uydudan.

Kurumun **Pancar Takip Sistemi**, yaklaşık **1 milyon dekar**lık ekim alanını
uydu görüntüleriyle izliyor. Sistem üzerinden bitkinin su stresi, azot
noksanlığı ve hastalık durumu takip ediliyor; rekolte tahminleri dijital
ortamda yapılıyor. Ziraat ekipleri sulama, gübreleme ve hastalık konusunda
buradan yol alıyor.

Teslim tarafında da bir sistem var: **PANTES**, çiftçinin pancarını fabrikaya
hangi gün ve saatte getireceğini internet üzerinden randevuyla belirlemesini
sağlıyor.

Kantarlar da değişiyor. Ankara Şeker Fabrikası'nda 2026 kampanyasında ilk
kez kâğıtsız, elektronik pancar tartımına geçildi; uygulamayı kurumun Bilgi
İşlem Dairesi ile Elektromekanik Aygıtlar Fabrikası birlikte kurdu. Ilgın'da
üç kantar **60 ton**luk elektronik sisteme dönüştürüldü.

Genel müdürün bu düzeni özetleyişi şöyle: "Gözümüz gökte, ayağımız tarlada,
kulağımız çiftçide."$dsr$, $dsr$The contract is signed before sowing, but what happens in the field is
watched all year — now from orbit.

The company's **Beet Tracking System** follows some **1 million decares** of
sown area by satellite image. Water stress, nitrogen deficiency and disease
are tracked through the system, and yield forecasts are made digitally.
Agronomy teams take their cue from it on irrigation, fertilising and disease.

There is a system on the delivery side too: **PANTES** lets the farmer book
online the day and hour at which the beet will reach the factory.

The weighbridges are changing as well. At the Ankara Sugar Factory the 2026
campaign brought the first paperless, electronic weighing of beet; the
company's IT department and the Electromechanical Devices factory built it
together. At Ilgın three weighbridges were converted to **60-tonne**
electronic systems.

The general manager sums the arrangement up this way: "Our eye is on the sky,
our foot in the field, our ear with the farmer."$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/turkseker/turkseker_s14_haymana.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","kaynak":null,"alt_tr":"Haymana'da pancar tarlasında inceleme, 5 Ağustos 2026.","alt_en":"An inspection in a beet field at Haymana, 5 August 2026.","en_boy":1.5015}$dsr$::jsonb),
  (11, $dsr$2018: on fabrika el değiştirdi$dsr$, $dsr$2018: ten factories change hands$dsr$, $dsr$Türkiye Şeker Fabrikaları A.Ş., Özelleştirme Yüksek Kurulu'nun 20 Aralık 2000
tarihli kararıyla özelleştirme kapsamına, 2008 tarihli kararıyla özelleştirme
programına alındı.

2018 yılında Özelleştirme İdaresi Başkanlığı tarafından **on şeker
fabrikasının** satışı yapıldı: Afyon, Alpullu, Bor, Çorum, Elbistan,
Erzincan, Erzurum, Kırşehir, Muş ve Turhal.

Listede iki ad özellikle dikkat çekiyor. **Alpullu**, ilk Türk şekerinin
üretildiği fabrika. **Turhal**, 1935'te tek çatı altında toplanan dört
kurucu fabrikadan biri. Bugün Alpullu Binbirgıda'ya, Turhal ise Kayseri
Şeker'e ait.

Özelleştirmenin ardından TÜRKŞEKER'in yıllık şeker üretim kapasitesi
**1 milyon 176 bin ton** oldu. 2023'te toplam pancar şekeri kotasının kotaya
esas kapasitenin %90'ına ulaşması nedeniyle kapasite %5 artırılarak 1 milyon
235 bin tona çıktı.

Kurumun kendi kadrosu da aynı dönemde küçüldü. Fiili ortalama personel sayısı
2018'de **7.563** iken 2019'da **5.487** oldu.

Özelleştirilen fabrikalar üretimden çıkmadı; el değiştirdi. Bugün Afyon'da
Doğuş Yiyecek ve İçecek, Çorum'da Çorum Şeker, Erzurum ve Erzincan'da Sukkar
Şeker, Kırşehir'de Tutgu Gıda, Bor'da Bor Şeker, Elbistan'da Mutlucan Şeker,
Muş'ta Muş Şeker Üretim, Alpullu'da Binbirgıda üretim yapıyor. Turhal ise
kooperatif kesimine geçti ve Kayseri Şeker'in üç fabrikasından biri oldu.

Daha önceki yıllarda da el değiştirmeler olmuştu. TÜRKŞEKER'in bağlı
ortaklığı statüsündeki Kütahya Şeker Fabrikası 2004'te Torunlar Gıda'ya,
Adapazarı Şeker Fabrikası ise Adapazarı Pancar Ekicileri Kooperatifi'ne
satıldı; Adapazarı bugün Yıldız Holding bünyesinde üretime devam ediyor.
Aksaray'daki Keskinkılıç ise kuruluşundan bu yana özel statüde.

Kurum 29 Nisan 2021 tarihli ve 3923 sayılı Cumhurbaşkanı Kararı ile
özelleştirme kapsam ve programından çıkarıldı ve sermayesinin tamamı
**Türkiye Varlık Fonu'na** devredildi. 12 Kasım 2021 tarihli kararla da Tarım
ve Orman Bakanlığı ile ilgilendirildi. Yirmi yılı aşkın süre özelleştirme
kapsam ve programında kalmış bir kurum için bu, bir dönemin kapanması oldu.$dsr$, $dsr$Türkiye Şeker Fabrikaları A.Ş. was brought within the scope of privatisation
by a decision of the Privatisation High Council dated 20 December 2000, and
into the privatisation programme by a decision of 2008.

In 2018 the Privatisation Administration carried out the sale of **ten sugar
factories**: Afyon, Alpullu, Bor, Çorum, Elbistan, Erzincan, Erzurum,
Kırşehir, Muş and Turhal.

Two names on the list stand out. **Alpullu** is the factory where the first
Turkish sugar was made. **Turhal** is one of the four founding factories
gathered under one roof in 1935. Alpullu today belongs to Binbirgıda, Turhal
to Kayseri Şeker.

The privatised factories did not leave production; they changed hands. Doğuş
Yiyecek ve İçecek produces at Afyon today, Çorum Şeker at Çorum, Sukkar Şeker
at Erzurum and Erzincan, Tutgu Gıda at Kırşehir, Bor Şeker at Bor, Mutlucan
Şeker at Elbistan, Muş Şeker Üretim at Muş and Binbirgıda at Alpullu. Turhal
passed to the cooperative sector and became one of Kayseri Şeker's three
factories.

There had been changes of hands in earlier years as well. The Kütahya Sugar
Factory, a subsidiary of TÜRKŞEKER, was sold to Torunlar Gıda in 2004, and
the Adapazarı Sugar Factory to the Adapazarı Beet Growers' Cooperative;
Adapazarı continues in production today within Yıldız Holding. Keskinkılıç at
Aksaray has been privately held since its founding.

After privatisation TÜRKŞEKER's annual sugar production capacity stood at
**1,176 thousand tonnes**. In 2023, because the total beet sugar quota
reached 90 per cent of the capacity on which quota is based, capacity was
raised by 5 per cent to 1,235 thousand tonnes.

The institution's own staff shrank in the same period. The actual average
number of staff was **7,563** in 2018 and **5,487** in 2019.

By Presidential Decision 3923 of 29 April 2021 the institution was removed
from the scope and programme of privatisation and the whole of its capital
was transferred to the **Türkiye Wealth Fund**. A decision of 12 November
2021 attached it to the Ministry of Agriculture and Forestry. For an
institution that had spent more than twenty years within the scope and
programme of privatisation, this closed a period.$dsr$, '{}'::text[], 'belge', $dsr${"url":"https://tarimportali.net/dosya/turkseker/turkseker_erzurum.jpg","atif":"Eğitmen Mahmut — CC BY-SA 3.0","kaynak":null,"alt_tr":"Erzurum Şeker Fabrikası'nın girişi, 25 Ağustos 2012.","alt_en":"The entrance of the Erzurum Sugar Factory, 25 August 2012.","en_boy":1.3333}$dsr$::jsonb),
  (12, $dsr$Bugün: on dört fabrika$dsr$, $dsr$Today: fourteen factories$dsr$, $dsr$2025/26 pazarlama yılında TÜRKŞEKER **14 şeker fabrikasıyla** üretim yapıyor.
Bir önceki stratejik planda sayı 15'ti; aradaki fark Çarşamba'dır. 25 Aralık
2024 tarihli Cumhurbaşkanı kararlarıyla Çarşamba Şeker Fabrikası'nın
taşınmazlarının Makine ve Kimya Endüstrisi A.Ş.'ye devredilmesine karar
verildi ve devir 2025'te tamamlandı.

Kuruma 2025/26 için **1.023.820 ton** A kotası ve 51.191 ton B kotası tahsis
edildi.

Şeker fabrikalarının yanında üç makine fabrikası, Elektromekanik Aygıtlar
Fabrikası, Alkol Fabrikası, Tohum İşleme Fabrikası ve Şeker Enstitüsü de
kurumun bünyesinde. Eskişehir'deki tesiste melastan alkol üretiliyor.

Şeker fabrikasından yalnız şeker çıkmıyor. Üretimin yan ürünü olan
**melas**taki şeker, enzimlerle fermantasyona uğratılarak etil alkole ve
karbondioksite ayrıştırılabiliyor. TÜRKŞEKER bu işi Eskişehir Alkol Üretim
Tesisi'nde yapıyor. Üretilen alkol alkollü içecek, sağlık, sanayi imalatı,
kozmetik ve dezenfektan sektörlerinde kullanılıyor. Kurumun işlediği melas
yıllara göre değişiyor: 2020'de 31.200 ton melastan 8,96 milyon litre etil
alkol üretildi, 2023'te 5.660 tondan 1,56 milyon litre. 2025'te alkol
üretimi yapılmadı.

Melasın bir başka kullanım alanı biyoetanol. Motorlu taşıt yakıtlarına belli
oranlarda yerli tarım ürünlerinden elde edilen biyoetanol katılması
uygulaması son yıllarda arttı; hibrit araçlarda %85'e kadar kullanılabilen
biyoetanol, kullanım oranına göre egzoz gazı emisyonlarını %74'e kadar
azaltıyor.

Arz ve talep tarafında 2024 tablosu şöyle: üretim 3,1 milyon ton, tüketim
3,22 milyon ton, ithalat 235 bin ton, ihracat 115 bin ton. Yani ülke
şekerinin neredeyse tamamını üretiyor, aradaki farkı ithalatla kapatıyor.

Personel tarafında 2022 yıl sonu rakamları şöyle: 147 memur, 1.088 sözleşmeli
personel, 3.551 daimi işçi ve 1.238 kampanya ve mevsimlik işçi; toplam
**6.024 kişi**. Alt işverenle birlikte istihdam **10.535 kişi**. Çalışanların
%91'i erkek, %9'u kadın. Öğrenim durumuna göre bakıldığında çalışanların
%15,26'sı lisans, %2,63'ü yüksek lisans ve doktora mezunu; en kalabalık grup
%53,61 ile lise mezunları.

Dış ticarette son on yılın en belirgin hareketi 2022'de yaşandı. Kristal
şeker ithalatı 2021'de 48.699 tonla dip yaptıktan sonra 2022'de **602.479
tona** çıktı; on yılın en yükseği. 2025'te ithalat 110.000 ton.

Kurumun 2026/27 pancar işleme kampanyası sürüyor. Rakamları kendi
açıklamasında şöyle:

**1.300**'ü aşkın köyde **30 bine** yakın üreticiyle çalışılıyor. Kampanyada
**6,9 milyon ton** pancar işlenerek **910 bin ton** şeker üretilmesi
hedefleniyor.

Pancarın fabrikaya girişinden paketlenmiş şekerin rafa çıkışına kadar geçen
süre kurumun tarifinde **36 saat**.

Ülke ölçeğinde tablo da verilmiş durumda: Türkiye'de toplam **32** şeker
fabrikası çalışıyor; **14**'ü TÜRKŞEKER'e, **12**'si özel sektöre, **6**'sı
pancar kooperatiflerine ait.

Kampanya sayıları fabrikaların yaşını da gösteriyor. 2026/27 döneminde
Susurluk **72**'nci, Malatya **71**'inci, Ankara **65**'inci, Kastamonu
**64**'üncü, Erciş **39**'uncu ve Yozgat **29**'uncu kampanyasına girdi.$dsr$, $dsr$In the 2025/26 marketing year TÜRKŞEKER produces with **14 sugar factories**.
The previous strategic plan gave the number as 15; the difference is
Çarşamba. By Presidential decisions of 25 December 2024 it was decided to
transfer the real estate of the Çarşamba Sugar Factory to Makine ve Kimya
Endüstrisi A.Ş., and the transfer was completed in 2025.

For 2025/26 the institution was allocated an A quota of **1,023,820 tonnes**
and a B quota of 51,191 tonnes.

Alongside the sugar factories the institution runs three machine works, an
electromechanical devices plant, an alcohol plant, a seed processing plant
and the Sugar Institute. Alcohol is produced from molasses at the plant in
Eskişehir.

Sugar is not the only thing that leaves a sugar factory. The sugar in
**molasses**, a by-product of production, can be fermented with enzymes and
broken down into ethyl alcohol and carbon dioxide. TÜRKŞEKER does this at the
Eskişehir Alcohol Production Plant. The alcohol produced is used in alcoholic
drinks, health care, industrial manufacturing, cosmetics and disinfectants.
The quantity of molasses the institution processes varies by year: in 2020,
8.96 million litres of ethyl alcohol were produced from 31,200 tonnes of
molasses, and in 2023, 1.56 million litres from 5,660 tonnes. No alcohol was
produced in 2025.

Molasses has another use: bioethanol. The practice of blending set
proportions of bioethanol obtained from domestic agricultural products into
motor fuels has grown in recent years; bioethanol, which can make up as much
as 85 per cent of the fuel in hybrid vehicles, reduces exhaust emissions by
up to 74 per cent depending on the proportion used.

On the supply and demand side the 2024 picture runs as follows: production
3.1 million tonnes, consumption 3.22 million tonnes, imports 235 thousand
tonnes, exports 115 thousand tonnes. The country produces very nearly all of
its own sugar and closes the gap with imports.

The staff figures for the end of 2022 are these: 147 civil servants, 1,088
contracted staff, 3,551 permanent workers and 1,238 campaign and seasonal
workers, **6,024 people** in all. Together with contractors, employment comes
to **10,535 people**. Of the staff, 91 per cent are men and 9 per cent women.
By education, 15.26 per cent hold a bachelor's degree and 2.63 per cent a
master's or doctorate; the largest group, at 53.61 per cent, are secondary
school graduates.

The clearest movement in foreign trade over the past decade came in 2022.
Crystal sugar imports, having bottomed at 48,699 tonnes in 2021, rose to
**602,479 tonnes** in 2022, the highest in ten years. Imports stood at
110,000 tonnes in 2025.

The company's 2026/27 beet processing campaign is under way. In its own
statement the figures run as follows.

Work is under way with close to **30,000** growers in more than **1,300**
villages. The campaign aims to process **6.9 million tonnes** of beet and
produce **910,000 tonnes** of sugar.

The time from the beet entering the factory to packed sugar reaching the
shelf is given by the company as **36 hours**.

The national picture is on record too: **32** sugar factories are working in
Türkiye — **14** belonging to TÜRKŞEKER, **12** to the private sector and
**6** to beet growers' cooperatives.

The campaign numbers also show the age of the factories. In 2026/27 Susurluk
entered its **72nd** campaign, Malatya its **71st**, Ankara its **65th**,
Kastamonu its **64th**, Erciş its **39th** and Yozgat its **29th**.$dsr$, array['bugun_turkseker']::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/turkseker/turkseker_gm_binasi.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","kaynak":null,"alt_tr":"Türkiye Şeker Fabrikaları A.Ş. Genel Müdürlüğü, Ankara. Kurumun kendi tanıtım görseli.","alt_en":"The head office of Türkiye Şeker Fabrikaları A.Ş., Ankara. The company's own promotional image.","en_boy":2.8235}$dsr$::jsonb),
  (13, $dsr$Kendi tezgâhı, kendi yatırımı$dsr$, $dsr$Its own workshop, its own investment$dsr$, $dsr$Makine fabrikaları kurulduğunda amaç bir fabrikanın parçalarını yurt içinde
yapabilmekti. Bugün kurumun kendi kaydına göre bir şeker fabrikasının
yaklaşık **%70'i** bu tesislerde üretilebiliyor.

Ölçek de kayıtlı: yalnız 2025 yılında **3.920 ton** makine ve tesis imalatı
yapıldı. Üç makine fabrikası ve Elektromekanik Aygıtlar Fabrikası bu işi
sürdürüyor.

Tezgâhlardan çıkan her şey şekerle ilgili değil. Makine fabrikalarında
ormanda kullanılmak üzere 3 ton su kapasiteli **250 yangın söndürme
tankeri** imal ediliyor. Traktörden hareket alan santrifüj pompayla
çalışan tanker; yangına müdahalenin yanı sıra arazi ve yol sulama, tesis
içi temizlik ve su taşıma işlerini de görüyor. Pompası, vana düzeni, lansı,
hortum hattı ve malzeme dolabıyla birlikte tasarlandı.

Bir şeker şirketinin orman için yangın tankeri yapması ilk bakışta
şaşırtıcı görünüyor. Kurumun kendi tarihinde ise olağan: fabrikayı kuran
atölye, sırası geldiğinde başka bir şey de kuruyor.

Özelleştirme programından çıkan kurum 2020'lerde fabrikalarına dönük bir
yatırım dönemine girdi. Kendi duyurularından birkaç kalem:

**Burdur**'da son **30** yılın en kapsamlı revizyon ve modernizasyon
çalışması 2026'da tamamlandı ve fabrika pancar işlemeye başladı.

**Elazığ**'a 2025-2026 yıllarını kapsayan **800 milyon lira**lık bir yatırım
yapıldı. Gerekçe bölgede devreye giren yeni sulama alanlarıyla artan pancar
üretim potansiyeli.

**Ilgın**'da 2025'te yaklaşık **260 milyon lira**, 2026'da **907 milyon
lira** yatırım gerçekleştirildi; 2027 yatırım programı teklifinde fabrika
için yaklaşık **2,51 milyar lira** öngörülüyor. Fabrikaya kurulan üçüncü
difüzyon ünitesi günde **3.000 ton** pancar işleme kapasitesine sahip;
**125 metreküp**lük üçüncü kireç ocağı da kullanıma açıldı. Fabrikanın
günlük pancar işleme kapasitesi **8.100 ton**.

Ilgın'daki yatırımın bir ayrıntısı dosyanın başka bir bölümüne bağlanıyor.
Çarşamba Şeker Fabrikası'ndan taşınan makine ve ekipman, fabrika ekiplerinin
bakım ve yenileme çalışmalarıyla yeniden üretime kazandırıldı. Devredilen
bir fabrikanın tezgâhları, başka bir fabrikada çalışmaya devam ediyor.

**Susurluk**'a yeni bir Big-Bag paketleme tesisi kazandırıldı; fabrikada
**695 bin ton** pancardan yaklaşık **85 bin ton** şeker üretilmesi
hedefleniyor. **Kars**'ta ise otomasyon dönüşümü tamamlandı.$dsr$, $dsr$The machine factories were founded so that the parts of a sugar factory
could be made at home. Today, by the company's own account, about **70%** of
a sugar factory can be produced in these works.

The scale is on record too: in 2025 alone **3,920 tonnes** of machinery and
plant were manufactured. Three machine factories and the Electromechanical
Devices factory carry the work.

Not everything that leaves the benches has to do with sugar. The machine
factories are building **250 fire-fighting tankers** of 3 tonnes' water
capacity for forestry use. Driven by a centrifugal pump off a tractor's
power take-off, the tanker also serves for irrigating land and roads,
cleaning inside plants and carrying water. It was designed complete with its
pump, valve set, lance, hose line and equipment lockers.

A sugar company building forest fire tankers looks surprising at first. In
the company's own history it is ordinary: the workshop that built the
factory builds something else when the turn comes.

Out of the privatisation programme, the company entered a period of
investment in its factories in the 2020s. A few items from its own
announcements:

At **Burdur**, the most extensive revision and modernisation of the past
**30** years was completed in 2026 and the factory began processing beet.

**Elazığ** received an investment of **800 million lira** covering 2025 and
2026. The reason given is the beet potential created by new irrigated land
coming into use in the region.

At **Ilgın**, some **260 million lira** was invested in 2025 and **907
million lira** in 2026; the 2027 investment programme proposes about **2.51
billion lira** for the factory. A third diffusion unit installed there can
process **3,000 tonnes** of beet a day, and a third lime kiln of **125 cubic
metres** was brought into use. The factory's daily beet processing capacity
is **8,100 tonnes**.

One detail of the Ilgın investment ties back to another section of this
dossier. Machinery and equipment moved from the Çarşamba Sugar Factory were
overhauled by the factory's own teams and returned to production. The benches
of a transferred factory are still working, in another factory.

**Susurluk** gained a new big-bag packing plant; the factory aims to produce
about **85,000 tonnes** of sugar from **695,000 tonnes** of beet. At
**Kars**, the conversion to automation was completed.$dsr$, '{}'::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/turkseker/turkseker_s06_tanker.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","kaynak":null,"alt_tr":"Makine fabrikalarında üretilen orman yangın söndürme tankerleri. Kurumun duyuru görseli, 4 Eylül 2026.","alt_en":"Forest fire-fighting tankers built in the machine factories. The company's announcement image, 4 September 2026.","en_boy":0.7995}$dsr$::jsonb),
  (14, $dsr$Şekerden sonra kalanlar$dsr$, $dsr$What is left after the sugar$dsr$, $dsr$Bir şeker fabrikasından çıkan tek şey şeker değil. Kurumun bütün tesisleri
Sıfır Atık Belgesi taşıyor ve yan ürünlerin her birinin bir alıcısı var.

**Posa.** Kampanya sonunda **2,08 milyon ton** yaş pancar posası elde
edilmesi öngörülüyor. Posa hayvancılığın temel yem kaynaklarından biri ve
üreticiye bedelsiz veriliyor; Erciş'te teslim edilen ürünün **%20**'si
oranında dağıtılıyor. Şap hastalığıyla mücadele döneminde bu ürünlere talep
arttı.

**Melas.** Kampanyada **317 bin ton** melas bekleniyor. Melas, Türkiye'nin
**135** ülkeye ihraç ettiği mayanın hammaddesi. Eskişehir'deki tesiste
melastan etil alkol üretiliyor; kolonyanın, dezenfektanın ve tıbbi alkolün
asıl unsuru da bu. Kurumun Ilgın için açıkladığı bir hedef daha var: melası
ülkede sitrik asit üretiminde değerlendirmek.

**Toprak.** Genel müdürün ifadesiyle: "Açıkçası pancarın etrafındaki toprağı
bile satıyoruz; toprağı peyzajcılar alıyor."

Pancarın tarladan gelen her parçası bir yere gidiyor — kökü şekere, yaprağı
ve posası yemliğe, şurubu mayaya ve alkole, üstündeki toprak bahçeye.$dsr$, $dsr$Sugar is not the only thing that leaves a sugar factory. All of the
company's plants hold a Zero Waste Certificate, and every by-product has a
buyer.

**Pulp.** Some **2.08 million tonnes** of wet beet pulp is expected by the
end of the campaign. Pulp is one of the staple feeds of livestock farming and
is given to growers free of charge; at Erciş it is distributed at **20%** of
the crop delivered. Demand for these products rose during the campaign
against foot-and-mouth disease.

**Molasses.** The campaign expects **317,000 tonnes** of molasses. Molasses
is the raw material of the yeast Türkiye exports to **135** countries. At the
Eskişehir plant it is turned into ethyl alcohol — the basis of cologne,
disinfectant and medical alcohol. The company has announced a further aim for
Ilgın: to use molasses in citric acid production at home.

**Soil.** In the general manager's words: "Frankly we even sell the soil
around the beet; landscapers buy it."

Every part of the beet that comes in from the field goes somewhere — the root
to sugar, the leaf and pulp to the feed trough, the syrup to yeast and
alcohol, the soil on it to the garden.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/turkseker/turkseker_s14_melas.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","kaynak":null,"alt_tr":"Melas, şeker üretiminin yan ürünü.","alt_en":"Molasses, a by-product of sugar production.","en_boy":0.8593}$dsr$::jsonb),
  (15, $dsr$Fabrikanın kendi elektriği$dsr$, $dsr$The factory's own electricity$dsr$, $dsr$Şeker fabrikaları elektriklerini şebekeden almıyor; kojenerasyon sistemiyle
kendileri üretiyor. Yakıt fuel-oil, doğal gaz ve kömür.

Son yıllarda bu düzene yenilenebilir kaynak eklendi. Ankara kampüsünde 4
megavatlık bir çatı güneş enerjisi santrali devreye alındı. Erciş Şeker
Fabrikası'nın arazisinde kurulan **20 megavat**lık santral ise 2026'nın
kasım ayında işletmeye alındı; yılda **48 milyon kilovatsaat** elektrik
üretmesi ve yaklaşık **30 bin ton** karbondioksit salımını önlemesi
öngörülüyor.

İki santralin toplamı **24 megavat**. Kurumun hesabına göre bu yatırımlar
tamamlandığında fabrikalar şebekeden satın aldıkları elektrikten fazlasını
üretecek ve yılda **23 bin ton** karbon salımı önlenecek.

Kazan tarafında da değişiklik var. Ilgın'a her biri saatte **75 ton** buhar
üretme kapasitesinde iki akışkan yataklı kazan için sözleşme imzalandı;
düşük kalorili yerli kömürle çalışacak kazanların 2027-2028 kampanyasında
devreye alınması planlanıyor. Elazığ'da ise doğal gazlı kazanlara geçildi;
kurumun kaydında bunun baca gazı emisyonu sorununu da çözdüğü yazılı.

Kendi elektriğini üreten bir fabrikanın ne anlama geldiği 6 Şubat 2023
depremlerinde görüldü.

Malatya Şeker Fabrikası 1 Ekim 1956'da hizmete girdi ve günlük **3.800 ton**
pancar işleme kapasitesiyle çalışıyor. 2026'da **71**'inci kampanyasına
girdi; fabrika müdürünün ifadesiyle "bu fabrikanın hikâyesi, Türk şeker
sanayii tarihinin yaklaşık dörtte üçüdür."

Genel müdür o geceyi şöyle anlatıyor: "Deprem oldu, Malatya kapkaranlık.
Şeker fabrikası ışıl ışıl. Aynı gece binlerce insanı içeri alıp bir
ekosistemi besledi."

Fabrika müdürünün değerlendirmesi de kurumun kaydında duruyor: "Üretmek için
kurulan bu tesisin, 6 Şubat depremlerinde gerektiğinde yaraları sarmak için
de orada olduğunu hep birlikte gördük."

Kojenerasyon bir maliyet kalemi olarak kurulmuştu. Şebeke düştüğünde başka
bir şeye yaradı.$dsr$, $dsr$Sugar factories do not take their electricity from the grid; they generate it
themselves by cogeneration. The fuel is fuel oil, natural gas and coal.

Renewable sources have been added to this arrangement in recent years. A
4-megawatt rooftop solar plant was brought into service on the Ankara campus.
The **20-megawatt** plant built on the land of the Erciş Sugar Factory came
into operation in November 2026; it is expected to generate **48 million
kilowatt-hours** a year and to prevent some **30,000 tonnes** of carbon
dioxide emissions.

The two plants together come to **24 megawatts**. By the company's reckoning,
once these investments are complete the factories will generate more than the
electricity they buy from the grid, and **23,000 tonnes** of carbon emissions
a year will be avoided.

There are changes on the boiler side too. A contract was signed for two
fluidised-bed boilers at Ilgın, each able to raise **75 tonnes** of steam an
hour; running on low-calorie domestic coal, they are planned to come on
stream in the 2027-2028 campaign. At Elazığ the move was to gas-fired
boilers, which the company's record says also solves its flue gas emission
problem.

What it means for a factory to generate its own electricity was seen in the
earthquakes of 6 February 2023.

The Malatya Sugar Factory opened on 1 October 1956 and works with a capacity
of **3,800 tonnes** of beet a day. In 2026 it entered its **71st** campaign;
in its director's words, "the story of this factory is about three quarters
of the history of the Turkish sugar industry."

The general manager describes that night like this: "The earthquake struck,
Malatya was pitch dark. The sugar factory was ablaze with light. That same
night it took thousands of people in and fed an ecosystem."

The factory director's assessment is on the company's record as well: "We all
saw that this plant, built to produce, was also there in the earthquakes of 6
February to bind wounds when it was needed."

Cogeneration had been installed as a matter of cost. When the grid went down
it turned out to be good for something else.$dsr$, '{}'::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/turkseker/turkseker_s20_ercis_ges.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","kaynak":null,"alt_tr":"Erciş Şeker Fabrikası arazisinde kurulan güneş enerjisi santrali. Kurumun duyuru görseli, 4 Kasım 2026.","alt_en":"The solar power plant built on the land of the Erciş Sugar Factory. The company's announcement image, 4 November 2026.","en_boy":0.7995}$dsr$::jsonb),
  (16, $dsr$Bir trilyonluk ekosistem$dsr$, $dsr$A trillion-lira ecosystem$dsr$, $dsr$Kurum şeker sanayiinin ülke ekonomisindeki yerini de sayılarla tarif ediyor.
Aşağıdakiler kurumun kendi açıklamalarındaki rakamlar.

Sektörün Türkiye için oluşturduğu ekosistem yaklaşık **1 trilyon lira**
büyüklüğünde ve **4,5 milyar dolar**lık ihracat yapılıyor. 2025 fiyatlarıyla
yıllık katkı **275 milyar lira** doğrudan, **750 milyar lira** dolaylı olarak
hesaplanıyor.

Zincirin halkaları ayrı ayrı da verilmiş: pancarın değeri **96 milyar lira**,
üretilen şekerin değeri **105 milyar lira**, yan ürünlerin değeri **15
milyar lira**. Şekerin beslediği gıda, içecek ve unlu mamuller sanayiinin
üretim değeri ise **575 milyar lira**ya ulaşıyor.

Üreticiye giden para da kayıtlı: sektör genelinde üreticilere yapılan nakit
ödeme **80 milyar lira**yı aştı. Şeker sanayii **20 bin**den fazla kişiye
istihdam sağlıyor.

Taşımacılığa katkı ayrı bir kalem. Bir kampanya döneminde **33,5 milyon ton**
taşıma yapılıyor ve bu **1,5 milyon** sefere denk geliyor.

Kurumun kendi yeri de tarif edilmiş: TÜRKŞEKER aktif varlık büyüklüğüyle
Türkiye'nin en büyük **37**'nci sanayi şirketi, kendi alanında dünyanın en
büyük 7'nci şirketi.$dsr$, $dsr$The company also describes the place of the sugar industry in the national
economy in figures. What follows are the numbers in its own statements.

The ecosystem the sector creates for Türkiye is about **1 trillion lira** in
size, with **4.5 billion dollars** of exports. At 2025 prices the annual
contribution is reckoned at **275 billion lira** directly and **750 billion
lira** indirectly.

The links of the chain are given separately too: the value of the beet is
**96 billion lira**, of the sugar produced **105 billion lira**, and of the
by-products **15 billion lira**. The production value of the food, drink and
bakery industries that sugar feeds reaches **575 billion lira**.

The money that reaches the grower is on record as well: cash payments to
growers across the sector have passed **80 billion lira**. The sugar industry
employs more than **20,000** people.

Its contribution to haulage is a separate item. A single campaign season
involves **33.5 million tonnes** of transport, which comes to **1.5 million**
journeys.

The company places itself too: by total assets TÜRKŞEKER is Türkiye's
**37th** largest industrial company, and the 7th largest in the world in its
own field.$dsr$, '{}'::text[], 'veri', $dsr${"url":"https://tarimportali.net/dosya/turkseker/turkseker_s22_ekonomi.jpg","atif":"İstanbul ve Trakya Şeker Fabrikaları T.A.Ş. Alpullu Şeker ve İspirto Fabrikaları · 1928-1929 · AHTURAL013 · Salt Araştırma · CC BY-NC-ND 4.0","kaynak":null,"alt_tr":"Alpullu Şeker ve İspirto Fabrikaları albümünden bir sayfa: Fabrikanın bölümleri ve personeli. 1928-1929.","alt_en":"A page from the album of the Alpullu Sugar and Spirit Factories: Sections of the factory and staff. 1928-1929.","en_boy":1.4532}$dsr$::jsonb),
  (17, $dsr$Dünyada benzeri$dsr$, $dsr$Comparable cases elsewhere$dsr$, $dsr$Pancardan şeker üretmek Türkiye'ye özgü değil; aksine, pancar şekeri ılıman
kuşağın şekeri. Dünyada tatlandırıcı talebi üç kaynaktan karşılanıyor:
sakaroz kökenli şekerler, nişasta bazlı şekerler ve yüksek yoğunluklu
tatlandırıcılar.

Pancar şekeri üretiminde sıralama şöyle: Avrupa Birliği 16,5 milyon ton,
Rusya 6,9 milyon ton, Amerika Birleşik Devletleri 4,9 milyon ton, **Türkiye
3,1 milyon ton**, Mısır 2,4 milyon ton.

Düzenleme biçimleri farklı. Avrupa Birliği uzun yıllar kota sistemiyle
çalıştı ve üretim kotasını 2017'de kaldırdı. Türkiye'de kota sistemi
sürüyor ve ülke içinde pazarlanacak miktar her yıl Cumhurbaşkanı kararıyla
belirleniyor.

Türkiye'yi ayıran bir özellik de üretimin mülkiyet yapısı. Kota kamu,
kooperatif ve özel sektör arasında neredeyse üçe bölünmüş durumda: %36,08,
%35,42 ve %28,49. Yani ülkede şekeri ne yalnız devlet üretiyor, ne yalnız
özel sektör.

Bir fark daha var: hammadde. Dünyada şekerin büyük bölümü şeker kamışından
geliyor ve kamış tropik kuşağın bitkisi. Pancar ise ılıman ve karasal iklim
bölgelerinin ürünü. Türkiye bu ikinci kuşakta ve kamış şekeri üretimi yok;
ülkenin şekerinin tamamı pancardan geliyor. Bu, Türkiye'yi pancar şekeri
sıralamasında dördüncü, toplam şeker üretiminde ise çok daha geride
bırakıyor.

Türkiye'de ayrıca pancar şekerinin yanında nişasta bazlı şeker üretiliyor ve
ikisi arasındaki oran kanunla belirleniyor. Pek çok ülkede bu ayrımı piyasa
yapıyor; Türkiye'de Cumhurbaşkanı kararıyla her yıl yeniden tespit ediliyor.

Üretim kotaları, tarife kotaları, yüksek korumalar ve tercihli ticaret
anlaşmaları dünya şeker ticaretini kısıtlayan başlıca araçlar. Bu yüzden
şeker, dünya ticaretinde en çok düzenlenen tarım ürünlerinden biri.$dsr$, $dsr$Producing sugar from beet is not peculiar to Türkiye; on the contrary, beet
sugar is the sugar of the temperate belt. World demand for sweeteners is met
from three sources: sucrose-based sugars, starch-based sugars and
high-intensity sweeteners.

The ranking in beet sugar production runs: the European Union with 16.5
million tonnes, Russia with 6.9 million, the United States with 4.9 million,
**Türkiye with 3.1 million** and Egypt with 2.4 million.

The forms of regulation differ. The European Union worked with a quota system
for many years and abolished its production quota in 2017. In Türkiye the
quota system continues, and the amount to be marketed domestically is set
each year by Presidential decision.

One feature that sets Türkiye apart is the ownership structure of production.
The quota is divided almost in three between the public, cooperative and
private sectors: 36.08%, 35.42% and 28.49%. Sugar in the country is made
neither by the state alone nor by private companies alone.

There is another difference: the raw material. Most of the world's sugar
comes from sugar cane, and cane is a plant of the tropics. Beet belongs to
temperate and continental climates. Türkiye lies in that second belt and
produces no cane sugar; all of its sugar comes from beet. That places Türkiye
fourth in beet sugar and considerably further down in total sugar output.

Türkiye also produces starch-based sugar alongside beet sugar, and the ratio
between the two is set by law. In many countries that balance is struck by
the market; in Türkiye it is fixed afresh each year by Presidential decision.

Production quotas, tariff quotas, high protection and preferential trade
agreements are the main instruments restricting world trade in sugar. Sugar
is, for that reason, among the most heavily regulated agricultural products
in world trade.$dsr$, array['iki_model']::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/turkseker/turkseker_chino_1906.jpg","atif":"Rieder, M. — Public domain","kaynak":null,"alt_tr":"Şeker pancarı işleme tesisi, Chino Vadisi, Kaliforniya, ABD, 1906 civarı. USC Dijital Kütüphanesi.","alt_en":"A sugar beet processing plant, Chino Valley, California, USA, circa 1906. USC Digital Library.","en_boy":1.2938}$dsr$::jsonb),
  (18, $dsr$Yerleşkede bir hayat$dsr$, $dsr$A life on the estate$dsr$, $dsr$Şeker fabrikaları kurulduğu yere yalnız baca değil, mahalle de getirdi.
Lojman, kreş, çay bahçesi, spor sahası. Ankara Etimesgut yerleşkesi bu
geleneğin bugün de sürdüğü yer.

Yerleşkede sırasıyla Kitap Kafe, Kreş, Taş Bina ve spor tesisleri açıldı.
Beşincisi 2026'nın ocak ayında hizmete giren Etiler Misafirhanesi oldu: atıl
durumdaki tarihi yapı kurumun öz kaynakları ve personelinin emeğiyle
yenilendi.

Aynı yerleşkede Ankara Şeker Fabrikası'nın yanında **20 bin metrekare**lik
bir sera var. Sera tamamen kadınların çalıştığı bir sosyal sorumluluk
projesi; iyi tarım uygulamasıyla ve yerli tohumla topraksız tarım yapılıyor.
Isıtması bedava: üretim sürecinde soğutulması gereken atık ısı seranın
içinde dolaşıp sisteme geri dönüyor. Serada yetişen TÜRKŞEKER markalı ilk
yerli domatesler 2026'nın mart ayında hasat edildi.

Kastamonu'da ise 2026'nın nisan ayında bir ekolojik market açıldı. Markette
kadın kooperatiflerinin el emeği ürünleri ile TİGEM, TMO, ÇAYKUR, TAGEM ve
TKDK ürünleri bir arada satılıyor; "Kastamonu Şekeri" de ilk kez burada
tanıtıldı. 2025'in aralık ayında imzalanan protokolle TAGEM'e bağlı **49**
araştırma enstitüsünde geliştirilen ürünler de bu rafa girdi.

Yerleşke hikâyesinin bir de öteki yüzü var. Etimesgut Havalimanı'nın pist
uzatma çalışmaları kapsamında Ankara Şeker Fabrikası yerleşkesindeki tarihi
lojmanlar ve çay bahçesi 2025-2026'da yıkıldı.$dsr$, $dsr$Sugar factories brought more than a chimney to the places where they were
built: they brought a neighbourhood. Staff housing, a nursery, a tea garden,
sports grounds. The Ankara Etimesgut estate is where that tradition still
carries on.

A Book Café, a nursery, the Stone Building and sports facilities opened on
the estate in turn. The fifth was the Etiler Guest House, which came into
service in January 2026: a disused historic building renewed with the
company's own funds and the labour of its staff.

On the same estate, beside the Ankara Sugar Factory, stands a greenhouse of
**20,000 square metres**. It is a social responsibility project staffed
entirely by women, growing soil-free crops under good agricultural practice
with domestic seed. The heating costs nothing: waste heat that has to be
cooled in the production process circulates through the greenhouse and
returns to the system. The first TÜRKŞEKER-branded domestic tomatoes grown
there were harvested in March 2026.

In Kastamonu, an ecological market opened in April 2026. It sells the
handwork of women's cooperatives alongside products from TİGEM, TMO, ÇAYKUR,
TAGEM and TKDK; "Kastamonu Sugar" was first presented there. A protocol
signed in December 2025 brought products developed at **49** research
institutes under TAGEM onto the same shelves.

The story of the estate has another side. As part of the runway extension at
Etimesgut Airport, the historic staff houses and the tea garden on the Ankara
Sugar Factory estate were demolished in 2025 and 2026.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/turkseker/turkseker_s24_yerleske.jpg","atif":"Türkiye Şeker Fabrikası Etimesgut Kompleksi'ne dair fotoğraflar · Ali Mukbil Gökdoğan · TMGH007 · Salt Araştırma · CC BY-NC-ND 4.0","kaynak":null,"alt_tr":"Türkiye Şeker Fabrikası Etimesgut Kompleksi'ne dair fotoğraflar Ali Mukbil Gökdoğan fotoğrafı. Etimesgut, Ankara.","alt_en":"Photographs of the Etimesgut Complex of Türkiye Şeker Fabrikası. Photograph by Ali Mukbil Gökdoğan. Etimesgut, Ankara.","en_boy":1.4147}$dsr$::jsonb),
  (19, $dsr$Bir rölyef, bir türbin$dsr$, $dsr$A relief and a turbine$dsr$, $dsr$1934'te Turhal Şeker Fabrikası'nın açılışı anısına ahşap bir rölyef tablo
hazırlanmıştı. Genç Cumhuriyet'in kalkınma hamlesini özetleyen bir eserdi.

Tablo yıllar önce demirbaş kaydından çıkarıldı. Oradan sonrası bir koruma
hikâyesi: eseri Amasya Tren İstasyon şefi Mehmet Canyurt korudu, sonra iş
insanı Taner Canyurt'un koleksiyonunda muhafaza edildi.

2026'nın mart ayında tablo kuruma iade edildi ve Genel Müdürlük'te
sergilenmeye başlandı. Yapıldığında **92** yaşındaydı.

Bir fabrikanın açılışı için yapılan bir tablonun demirbaştan düşüp bir
istasyon şefinin elinde kalması, sonra 92 yıl sonra kurduğu kuruma
dönmesi — şeker sanayiinin kendi belgesini nasıl koruduğunu anlatan küçük
bir örnek.

Kurumun fabrikalarında kuruluş yıllarından beri kullanılan makineler var.
Genel müdürün anlattığına göre fabrikalardan birinde elektrik üretiminde
kullanılan bir türbin yaklaşık bir asırdır görevde.

Kampanya sayıları da bu sürekliliğin sayacı. Uşak ve Alpullu'da — ilk iki
fabrikada — **101**'inci kampanya yürütülüyor. İki fabrika da artık
TÜRKŞEKER'e ait değil; ama bacaları tütüyor ve sayaç işliyor.

Ankara Şeker Fabrikası'nın yeri ayrı. Kurumun tarifiyle "yerli imkânlarla
kurulan ilk şeker fabrikamız": "Burası, Türkiye'nin 'şeker fabrikasını ben
de yaparım' dediği yerdir ve **64** yıldır başkentin bacası tüten
hafızasıdır." Aynı yerleşkede makine fabrikası, elektromekanik aygıtlar
fabrikası, tohum işleme tesisi ve Şeker Enstitüsü bulunuyor; kurumun
kaydında tohumdan makineye, Ar-Ge'den şekere bütün zincirin tek adreste
bulunduğu başka bir yer olmadığı yazılı.

Yüz yıl önce kurulan bir sanayiden geriye kalan yalnız fabrikalar değil:
hâlâ dönen bir türbin, hâlâ sayılan kampanyalar, Genel Müdürlük'te asılı
duran bir tablo ve hâlâ aynı kampüste duran bir zincir.$dsr$, $dsr$In 1934 a wooden relief panel was made to mark the opening of the Turhal
Sugar Factory. It was a work summing up the young Republic's drive to
industrialise.

The panel was struck off the inventory years ago. What follows is a story of
safekeeping: it was kept by Mehmet Canyurt, stationmaster at Amasya, and
later held in the collection of the businessman Taner Canyurt.

In March 2026 the panel was returned to the company and put on display at the
head office. By then it was **92** years old.

A panel made for a factory's opening, struck off the books, left in a
stationmaster's hands and returning 92 years later to the institution it was
made for — a small example of how the sugar industry has kept its own
record.

There are machines in the company's factories that have been in use since its
founding years. By the general manager's account, a turbine used to generate
electricity in one of the factories has been at work for roughly a century.

The campaign numbers are a counter of the same continuity. At Uşak and
Alpullu — the first two factories — the **101st** campaign is under way.
Neither belongs to TÜRKŞEKER any longer; but their chimneys are smoking and
the counter is running.

The Ankara Sugar Factory stands apart. In the company's description it is
"the first sugar factory we built with domestic means": "This is where
Türkiye said 'I can build a sugar factory too', and for **64** years it has
been the smoking chimney of the capital's memory." The machine factory, the
electromechanical devices factory, the seed processing plant and the Sugar
Institute all stand on the same campus; the company's record says there is
nowhere else where the whole chain, from seed to machine and from research to
sugar, sits at a single address.

What remains of an industry founded a hundred years ago is not only the
factories: a turbine still turning, campaigns still being counted, a panel
hanging at the head office, and a chain still standing on the same campus.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/turkseker/turkseker_s25_rolyef_teslim.jpg","atif":"Türkiye Şeker Fabrikaları A.Ş. — kurumun kendi yayını","kaynak":null,"alt_tr":"1934'te Turhal Şeker Fabrikası'nın açılışı için yapılan ahşap rölyefin kuruma teslimi, 31 Mart 2026.","alt_en":"The wooden relief made for the opening of the Turhal Sugar Factory in 1934 being handed back to the company, 31 March 2026.","en_boy":0.7995}$dsr$::jsonb),
  (20, $dsr$Yüzüncü yıl$dsr$, $dsr$The hundredth year$dsr$, $dsr$26 Kasım 2026, Alpullu'da ilk Türk şekerinin üretilmesinin **yüzüncü yılı**.

Yüz yılda ölçek değişti. 1926'da iki fabrika vardı ve ülkenin ihtiyacı kısmen
karşılanıyordu; bugün 15 üretici, 2,8 milyon tonluk pancar şekeri kotası ve
76.767 pancar üreticisi var. Hektardan alınan pancar üçe katlandı.

Mülkiyet de değişti. 1990'lara kadar 30 fabrikayla sektörde tek başına olan
TÜRKŞEKER bugün 14 fabrika işletiyor ve pancar şekeri üretiminin %32'sini
yapıyor. Kurduğu sanayinin üçte birinden biraz fazlası elinde; gerisini
kooperatifler ve özel şirketler üretiyor — ki kooperatiflerin kökeni de aynı
kurumun 1950'lerde başlattığı kooperatifleşme hareketine dayanıyor.

Değişmeyen üç şey var. Birincisi hammadde: ülkede tüketilen kristal şekerin
tamamı hâlâ pancardan geliyor. İkincisi yöntem: çiftçi pancarını hâlâ
ekimden önce imzaladığı bir sözleşmeyle satıyor ve bedelinin bir bölümünü
hâlâ teslimden önce alıyor. Üçüncüsü de kurumun kendi tarifi: TÜRKŞEKER, bir
asra yakındır pancar üretiminde sözleşmeli tarım modelini uygulayan kuruluş.

Yüz yılın en görünür değişimi ise tarlada. 1961'de hektardan 22 ton pancar
alınıyordu, bugün 71 ton. Buna karşılık pancar üreticisi sayısı 2017'den bu
yana üçte bir azaldı ve üretim aynı kaldı. Aynı hasadı daha az çiftçi
kaldırıyor; tarla büyüdü, makine girdi, verim arttı.

Kurum da bu süre içinde yeniden tanımlandı. Yirmi yılı aşkın süre
özelleştirme programında kaldı, on fabrikasını devretti, sermayesi bir fona
geçti ve bugün 14 fabrikasıyla piyasanın üçte birinden biraz fazlasını
tutuyor. Kendi belgesinde yazdığı misyon ise değişmedi: gıda enflasyonunu
düşürmek ve piyasayı regüle etmek.

Bir çiftçinin Uşak'ta başlattığı iş, yüz yıl sonra ülkenin bütün şekerini
veren bir sanayi.$dsr$, $dsr$26 November 2026 is the **hundredth year** since the first Turkish sugar was
made at Alpullu.

The scale has changed over the century. In 1926 there were two factories and
the country's requirement was met only in part; today there are 15 producers,
a beet sugar quota of 2.8 million tonnes and 76,767 beet growers. The beet
taken from a hectare has tripled.

Ownership has changed too. TÜRKŞEKER, which stood alone in the sector with 30
factories until the 1990s, today operates 14 and produces 32 per cent of the
beet sugar. A little more than a third of the industry it built is in its
hands; the rest is produced by cooperatives and private companies — and the
cooperatives themselves trace back to the movement the same institution began
in the 1950s.

Three things have not changed. The first is the raw material: all of the
crystal sugar consumed in the country still comes from beet. The second is
the method: the grower still sells beet under a contract signed before sowing
and still receives part of the price before delivery. The third is the
institution's own description of itself: TÜRKŞEKER has applied the contract
farming model in beet production for close to a century.

The most visible change of the century is in the field. In 1961 a hectare
gave 22 tonnes of beet; today it gives 71. Against that, the number of beet
growers has fallen by a third since 2017 while output has held. The same
harvest is being brought in by fewer growers; fields have grown, machinery
has come in, yields have risen.

The institution has been redefined in the same period. It spent more than
twenty years in the privatisation programme, handed over ten of its
factories, saw its capital pass to a fund, and today holds a little more than
a third of the market with 14 factories. The mission set out in its own
record has not changed: to bring down food inflation and to regulate the
market.

Work begun by a farmer at Uşak is, a hundred years on, the industry that
supplies all of the country's sugar.$dsr$, '{}'::text[], 'anlati', $dsr${"url":"https://tarimportali.net/dosya/turkseker/turkseker_usak_ic.jpg","atif":"The original uploader was chansey at Turkish Wikipedia — CC0","kaynak":null,"alt_tr":"Uşak Şeker Fabrikası'nın içi, kuruluş dönemi. Mehmet Hacım'ın arşivinden; torunu Tanju Bilgen'in kamuya bağışı.","alt_en":"Inside the Uşak Sugar Factory in its founding years. From the archive of Mehmet Hacım, donated to the public by his grandchild Tanju Bilgen.","en_boy":1.3333}$dsr$::jsonb),
  (21, $dsr$Yüzüncü yıl galerisi$dsr$, $dsr$The centenary gallery$dsr$, $dsr$Alpullu'nun köprüsü, garı ve 1928'de açılan ispirto fabrikası; Turhal
istasyonunda Mustafa Kemal; fabrika için pancar toplayan eller; vagonlardan
boşalan pancar; Uşak'ın makine salonları ve çalışanları; Alpullu'nun
laboratuvarı; Anadolu'ya yayılmış şeker fabrikaları; kurumun kendi makinesini
yaptığı atölyeler ve fabrikaların çevresinde kurulan mahalleler.

Kareler Salt Araştırma arşivinden, Türkiye Şeker Fabrikaları A.Ş.'nin kendi
yayınından ve Wikimedia Commons'tan. Her karenin altında konusu, kaydı ve
üreteni yazıyor.$dsr$, $dsr$The bridge, the station and the spirit factory opened in 1928 at Alpullu;
Mustafa Kemal at Turhal station; the hands gathering beet for the factory;
beet unloaded from railway wagons; the engine rooms of Uşak and the people
who worked them; the laboratory at Alpullu; the sugar factories spread across
Anatolia; the workshops where the company builds its own machinery; and the
neighbourhoods that grew around the factories.

The frames come from the Salt Research archive, from Türkiye Şeker
Fabrikaları A.Ş.'s own publications and from Wikimedia Commons. Each frame
carries its subject, its record and its author beneath it.$dsr$, '{}'::text[], 'galeri', null),
  (22, $dsr$Kaynakça$dsr$, $dsr$Sources$dsr$, $dsr$- **TÜRKŞEKER — Şeker Sektör Raporu 2025.** Türkiye Şeker Fabrikaları A.Ş.
  Sektörün tarihsel gelişimi, kota tabloları (Tablo 23, 24), üretici ve
  üretim tabloları (Tablo 26, 27), ithalat tablosu (Tablo 36).
- **TÜRKŞEKER — 2024-2028 Stratejik Plan.** Türkiye Şeker Fabrikaları A.Ş.
  Kurumsal tarihçe, personel tabloları (Tablo 16, 17, 18), gayrimenkul
  tablosu (Tablo 21).
- **4634 sayılı Şeker Kanunu.** 19 Nisan 2001. Kota rejimi, fiyat esasları.
- **Türkiye Şeker Fabrikaları A.Ş. Ana Statüsü.**
- **FAOSTAT — Production: Crops and livestock products.** Türkiye şeker
  pancarı üretim, alan ve verim serisi, 1961-2024.
- **USDA Foreign Agricultural Service — Production, Supply and
  Distribution.** Dünya ve Türkiye şeker üretim, tüketim ve ticaret verileri.$dsr$, $dsr$- **TÜRKŞEKER — Sugar Sector Report 2025.** Türkiye Şeker Fabrikaları A.Ş.
  Historical development of the sector, quota tables (Tables 23, 24), grower
  and production tables (Tables 26, 27), import table (Table 36).
- **TÜRKŞEKER — Strategic Plan 2024-2028.** Türkiye Şeker Fabrikaları A.Ş.
  Institutional history, staff tables (Tables 16, 17, 18), property table
  (Table 21).
- **Sugar Law 4634.** 19 April 2001. Quota regime, pricing principles.
- **Articles of Association of Türkiye Şeker Fabrikaları A.Ş.**
- **FAOSTAT — Production: Crops and livestock products.** Türkiye sugar beet
  production, area and yield series, 1961-2024.
- **USDA Foreign Agricultural Service — Production, Supply and
  Distribution.** World and Türkiye sugar production, consumption and trade.$dsr$, '{}'::text[], 'anlati', null)
) as v(ord, title_tr, title_en, body_tr, body_en, chart_keys, tur, gorsel)
where d.slug = 'turkseker';

-- Sağlama: beklenen bölüm sayısı yazılmadıysa işlem geri alınır.
do $kontrol$
declare n integer;
begin
  select count(*) into n
    from public.dossier_sections s
    join public.country_dossiers d on d.id = s.dossier_id
   where d.slug = 'turkseker';
  if n <> 22 then
    raise exception 'Bölüm sayısı 22 olmalıydı, % yazıldı', n;
  end if;
end
$kontrol$;

-- Sağlama: beklenen bölüm sayısı yazılmadıysa işlem geri alınır.
do $kontrol$
declare n integer;
begin
  select count(*) into n
    from public.dossier_sections s
    join public.country_dossiers d on d.id = s.dossier_id
   where d.slug = 'turkseker';
  if n <> 22 then
    raise exception 'Bölüm sayısı 22 olmalıydı, % yazıldı', n;
  end if;
end
$kontrol$;
