-- Irak görsel altyazıları yeniden yazıldı · 3 Kasım 2026
--
-- Kullanıcı eleştirisi: altyazılar görselin ADI gibi sunulan yapay zekâ
-- çözümleme notlarıydı — "Tezgâhta satışa dizilmiş yufka ekmekler; arkasında
-- satıcı oturuyor." Bu bir altyazı değil, karenin tarifi. İlk sürüm "yalnız
-- karede görüleni yaz" disiplinine fazla sadık yazılmıştı ve o disiplin
-- DENETİM içindi, okur için değil.
--
-- Yeni altyazılar kareyi okura tanıtıyor ve yerinde olduğunda bölümün
-- ölçülmüş bir rakamını bağlıyor. Karede olmayan hiçbir şey iddia edilmiyor.
--
-- Kapak altyazısı da aynı şekilde yeniden yazıldı.

update public.country_dossiers
   set cover_credit = $g$"Taisir Mahdi — CC BY-SA 4.0"$g$::text
 where slug = 'irak';

update public.dossier_sections s set gorsel = $g${"url": "https://tarimportali.net/dosya/irak/irak_ekmek.jpg", "atif": "Omar Chatriwala of Al Jazeera English — CC BY-SA 2.0", "lisans": "CC BY-SA 2.0", "alt_tr": "Ekmek tezgâhı. Irak'a giden Türk tarım malının %31,1'i buğdayın bir hâli.", "alt_en": "A bread stall. 31.1% of the Turkish agricultural goods going to Iraq is wheat in some form.", "en_boy": 0.6667, "_commons": "https://commons.wikimedia.org/wiki/File:Fresh_bread_for_sale_-_Flickr_-_Al_Jazeera_English.jpg", "_gozle_dogrulandi": true}$g$::jsonb
  from public.country_dossiers d
 where s.dossier_id = d.id and d.slug = 'irak' and s.ord = 1;
update public.dossier_sections s set gorsel = $g${"url": "https://tarimportali.net/dosya/irak/irak_harman_ninova.jpg", "atif": "Matson Collection — Public domain", "lisans": "Public domain", "alt_tr": "Ninova yakınlarında eşeğin döndürdüğü un değirmeni, 20. yüzyılın başı.", "alt_en": "A donkey-driven flour mill near Nineveh, early twentieth century.", "en_boy": 1.3806, "_commons": "https://commons.wikimedia.org/wiki/File:Iraq._Nineveh._'The_Glory_of_Kingdoms.'_A_primitive_wheat_mill_near_shrine_of_Nebi_Yunis_LOC_matpc.16227.jpg", "_gozle_dogrulandi": true}$g$::jsonb
  from public.country_dossiers d
 where s.dossier_id = d.id and d.slug = 'irak' and s.ord = 2;
update public.dossier_sections s set gorsel = $g${"url": "https://tarimportali.net/dosya/irak/irak_sulama_kanali.jpg", "atif": "Tim Hunt, U.S. Army — Public domain", "lisans": "Public domain", "alt_tr": "Motopompla sulanan bir tarla.", "alt_en": "A field irrigated by motor pump.", "en_boy": 1.3967, "_commons": "https://commons.wikimedia.org/wiki/File:Irrigation_canal_Fira_Shia%2C_Iraq_(2).jpg", "_gozle_dogrulandi": true}$g$::jsonb
  from public.country_dossiers d
 where s.dossier_id = d.id and d.slug = 'irak' and s.ord = 3;
update public.dossier_sections s set gorsel = $g${"url": "https://tarimportali.net/dosya/irak/irak_tharthar.jpg", "atif": "MODIS Land Rapid Response Team, NASA GSFC — Public domain", "lisans": "Public domain", "alt_tr": "Tharthar Gölü ve Dicle'nin menderesleri, uydudan.", "alt_en": "Lake Tharthar and the meanders of the Tigris, from orbit.", "en_boy": 1.334, "_commons": "https://commons.wikimedia.org/wiki/File:Shrinking_Lake_Tharthar_(MODIS_2024-04-29).jpg", "_gozle_dogrulandi": true}$g$::jsonb
  from public.country_dossiers d
 where s.dossier_id = d.id and d.slug = 'irak' and s.ord = 4;
update public.dossier_sections s set gorsel = $g${"url": "https://tarimportali.net/dosya/irak/irak_silo_musul.jpg", "atif": "الدبوني — CC BY-SA 4.0", "lisans": "CC BY-SA 4.0", "alt_tr": "Musul'da tahıl silosu. FAO'nun savaş değerlendirmesi, yıkılan siloları kaybın sebepleri arasında sayıyor.", "alt_en": "A grain silo at Mosul. The FAO's war assessment lists destroyed silos among the causes of loss.", "en_boy": 1.3333, "_commons": "https://commons.wikimedia.org/wiki/File:Silo_Mosul_2.jpg", "_gozle_dogrulandi": true}$g$::jsonb
  from public.country_dossiers d
 where s.dossier_id = d.id and d.slug = 'irak' and s.ord = 5;
update public.dossier_sections s set gorsel = $g${"url": "https://tarimportali.net/dosya/irak/irak_bugday_tarlasi.jpg", "atif": "Ruaa Jabbar — CC BY 4.0", "lisans": "CC BY 4.0", "alt_tr": "Buğday tarlasında başak kontrolü.", "alt_en": "Checking the ears in a wheat field.", "en_boy": 0.5611, "_commons": "https://commons.wikimedia.org/wiki/File:In_the_wheat_field.jpg", "_gozle_dogrulandi": true}$g$::jsonb
  from public.country_dossiers d
 where s.dossier_id = d.id and d.slug = 'irak' and s.ord = 6;
update public.dossier_sections s set gorsel = $g${"url": "https://tarimportali.net/dosya/irak/irak_bataklik_uydu.jpg", "atif": "Operators for the Moderate Resolution Imaging Spectroradiometer (MODIS) on NASA’s Aqua satellite (Image annotated by myself) — Public domain", "lisans": "Public domain", "alt_tr": "Güney Irak'ın sulak alanları, uydudan. Pirinç bu ovanın ürünü.", "alt_en": "The wetlands of southern Iraq from orbit. Rice is a crop of this plain.", "en_boy": 1.3333, "_commons": "https://commons.wikimedia.org/wiki/File:IraqMarshesAnnotated.jpg", "_gozle_dogrulandi": true}$g$::jsonb
  from public.country_dossiers d
 where s.dossier_id = d.id and d.slug = 'irak' and s.ord = 7;
update public.dossier_sections s set gorsel = $g${"url": "https://tarimportali.net/dosya/irak/irak_kolza_tarlasi.jpg", "atif": "Almejwal — CC BY-SA 3.0", "lisans": "CC BY-SA 3.0", "alt_tr": "Çiçeklenmiş bir tarlada çiftçiler.", "alt_en": "Farmers in a field in flower.", "en_boy": 1.3913, "_commons": "https://commons.wikimedia.org/wiki/File:Field_of_Rape_seeds_in_Salah_Alden_Governance.jpg", "_gozle_dogrulandi": true}$g$::jsonb
  from public.country_dossiers d
 where s.dossier_id = d.id and d.slug = 'irak' and s.ord = 8;
update public.dossier_sections s set gorsel = $g${"url": "https://tarimportali.net/dosya/irak/irak_hurma_genis.jpg", "atif": "Ahmed alsari — CC BY-SA 4.0", "lisans": "CC BY-SA 4.0", "alt_tr": "Hurma bahçesi. Irak'ın dünya hurma üretimindeki payı %18,9'dan %5,9'a indi.", "alt_en": "A date grove. Iraq's share of world date production fell from 18.9% to 5.9%.", "en_boy": 1.3333, "_commons": "https://commons.wikimedia.org/wiki/File:%D9%86%D8%AE%D9%8A%D9%84_%D8%A7%D9%84%D8%B9%D8%B1%D8%A7%D9%82.jpg", "_gozle_dogrulandi": true}$g$::jsonb
  from public.country_dossiers d
 where s.dossier_id = d.id and d.slug = 'irak' and s.ord = 9;
update public.dossier_sections s set gorsel = $g${"url": "https://tarimportali.net/dosya/irak/irak_hurma_bostan.jpg", "atif": "Usamasaad — CC BY-SA 4.0", "lisans": "CC BY-SA 4.0", "alt_tr": "Bir köy bostanında hurmalık.", "alt_en": "A date grove in a village garden.", "en_boy": 0.75, "_commons": "https://commons.wikimedia.org/wiki/File:%D8%A8%D8%B3%D8%AA%D8%A7%D9%86_%D9%86%D8%AE%D9%8A%D9%84_%D9%81%D9%8A_%D9%82%D8%B1%D9%8A%D8%A9_%D8%B4%D8%B1%D9%82_%D8%A7%D9%84%D8%B9%D8%B1%D8%A7%D9%82_06.jpg", "_gozle_dogrulandi": true}$g$::jsonb
  from public.country_dossiers d
 where s.dossier_id = d.id and d.slug = 'irak' and s.ord = 10;
update public.dossier_sections s set gorsel = $g${"url": "https://tarimportali.net/dosya/irak/irak_bataklik_mashoof.jpg", "atif": "Hassan Janali, U.S. Army Corps of Engineers — Public domain", "lisans": "Public domain", "alt_tr": "Bataklıkta meşhufla yol alan iki kişi.", "alt_en": "Two people travelling by mashoof through the marshes.", "en_boy": 1.3662, "_commons": "https://commons.wikimedia.org/wiki/File:Marsh_Arabs_in_a_mashoof.jpg", "_gozle_dogrulandi": true}$g$::jsonb
  from public.country_dossiers d
 where s.dossier_id = d.id and d.slug = 'irak' and s.ord = 11;
update public.dossier_sections s set gorsel = $g${"url": "https://tarimportali.net/dosya/irak/irak_kumes.jpg", "atif": "Kani Ronningen, U.S. Army — Public domain", "lisans": "Public domain", "alt_tr": "Broyler kümesi. Tavuk 1961'den bugüne 21,5 kat arttı.", "alt_en": "A broiler shed. Chicken numbers have risen 21.5-fold since 1961.", "en_boy": 1.5031, "_commons": "https://commons.wikimedia.org/wiki/File:Chicken_farm_in_Iraq.JPG", "_gozle_dogrulandi": true}$g$::jsonb
  from public.country_dossiers d
 where s.dossier_id = d.id and d.slug = 'irak' and s.ord = 12;
update public.dossier_sections s set gorsel = $g${"url": "https://tarimportali.net/dosya/irak/irak_souk_kerkuk.jpg", "atif": "James (Jim) Gordon — CC BY 2.0", "lisans": "CC BY 2.0", "alt_tr": "Kerkük çarşısında bir satıcı.", "alt_en": "A seller in the Kirkuk souk.", "en_boy": 1.3994, "_commons": "https://commons.wikimedia.org/wiki/File:Fruit_and_vegetable_merchant_in_a_souk%2C_Kirkuk.jpg", "_gozle_dogrulandi": true}$g$::jsonb
  from public.country_dossiers d
 where s.dossier_id = d.id and d.slug = 'irak' and s.ord = 13;
update public.dossier_sections s set gorsel = $g${"url": "https://tarimportali.net/dosya/irak/irak_pazar_musul.jpg", "atif": "Abdulsalam Al Dabbagh — CC BY-SA 4.0", "lisans": "CC BY-SA 4.0", "alt_tr": "Musul'da kapalı sebze-meyve hali.", "alt_en": "A covered fruit and vegetable hall in Mosul.", "en_boy": 1.7778, "_commons": "https://commons.wikimedia.org/wiki/File:Fruit_%26_Vegetables_Market-Mosul_01.jpg", "_gozle_dogrulandi": true}$g$::jsonb
  from public.country_dossiers d
 where s.dossier_id = d.id and d.slug = 'irak' and s.ord = 14;
update public.dossier_sections s set gorsel = $g${"url": "https://tarimportali.net/dosya/irak/irak_silo_bagdat.jpg", "atif": "Hamody al-iraqi — CC BY-SA 4.0", "lisans": "CC BY-SA 4.0", "alt_tr": "Bağdat'ta tahıl silosu.", "alt_en": "A grain silo in Baghdad.", "en_boy": 2.1622, "_commons": "https://commons.wikimedia.org/wiki/File:Grain_Silo_in_baghdad.jpg", "_gozle_dogrulandi": true}$g$::jsonb
  from public.country_dossiers d
 where s.dossier_id = d.id and d.slug = 'irak' and s.ord = 15;
update public.dossier_sections s set gorsel = $g${"url": "https://tarimportali.net/dosya/irak/irak_firat_kayik.jpg", "atif": "Christiaan Briggs — CC BY-SA 3.0", "lisans": "CC BY-SA 3.0", "alt_tr": "Fırat'ta kayık. Nehir Irak'ın dışında doğuyor.", "alt_en": "A boat on the Euphrates. The river rises outside Iraq.", "en_boy": 1.3333, "_commons": "https://commons.wikimedia.org/wiki/File:Boat_on_Euphrates.jpg", "_gozle_dogrulandi": true}$g$::jsonb
  from public.country_dossiers d
 where s.dossier_id = d.id and d.slug = 'irak' and s.ord = 16;
update public.dossier_sections s set gorsel = $g${"url": "https://tarimportali.net/dosya/irak/irak_manda.jpg", "atif": "Adnan S mohmmod — CC BY-SA 4.0", "lisans": "CC BY-SA 4.0", "alt_tr": "Nehir kıyısında manda sürüsü.", "alt_en": "A herd of water buffalo by the river.", "en_boy": 1.6054, "_commons": "https://commons.wikimedia.org/wiki/File:River_buffalo.jpg", "_gozle_dogrulandi": true}$g$::jsonb
  from public.country_dossiers d
 where s.dossier_id = d.id and d.slug = 'irak' and s.ord = 17;
update public.dossier_sections s set gorsel = $g${"url": "https://tarimportali.net/dosya/irak/irak_kapak_uydu.jpg", "atif": "NASA — Public domain", "lisans": "Public domain", "alt_tr": "Irak, uydudan: çölün içinden geçen ince yeşil koridor.", "alt_en": "Iraq from orbit: a thin green corridor through the desert.", "en_boy": 0.9632, "_commons": "https://commons.wikimedia.org/wiki/File:Satellite_image_of_Iraq_in_August_2003.jpg", "_gozle_dogrulandi": true}$g$::jsonb
  from public.country_dossiers d
 where s.dossier_id = d.id and d.slug = 'irak' and s.ord = 18;

do $kontrol_altyazi$
declare n integer;
begin
  -- Eski çözümleme dili kalmamalı
  select count(*) into n from public.dossier_sections s
    join public.country_dossiers d on d.id = s.dossier_id
   where d.slug = 'irak'
     and (s.gorsel->>'alt_tr' like '%arkasında satıcı oturuyor%'
       or s.gorsel->>'alt_tr' like '%önündeki toprakta%'
       or s.gorsel->>'alt_tr' like '%tezgâhlar dizili%');
  if n > 0 then raise exception '% bölümde eski çözümleme altyazısı kaldı', n; end if;

  -- Her bölümde hâlâ altyazılı görsel var
  select count(*) into n from public.dossier_sections s
    join public.country_dossiers d on d.id = s.dossier_id
   where d.slug = 'irak'
     and (s.gorsel->>'url' is null or coalesce(s.gorsel->>'alt_tr','') = '');
  if n > 0 then raise exception '% bölümün görseli ya da altyazısı yok', n; end if;
end
$kontrol_altyazi$;
