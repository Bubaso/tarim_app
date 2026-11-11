-- ════════════════════════════════════════════════════════════════════════
-- SAĞLAMA — on beş kontrol. Biri bile tutmazsa göç geri alınır.
-- ════════════════════════════════════════════════════════════════════════
do $kontrol_tigem$
declare d_id bigint; n integer; t text;
begin
  select id into d_id from public.country_dossiers where slug = 'tigem';
  if d_id is null then raise exception 'tigem satırı yazılmadı'; end if;

  -- 1. Bu göç devir göçü DEĞİL
  select status into t from public.country_dossiers where id = d_id;
  if t is distinct from 'draft' then
    raise exception 'tigem durumu draft olmalıydı, % bulundu — bu göç devir göçü değil', t;
  end if;

  -- 2. Kurum dosyası
  select tur into t from public.country_dossiers where id = d_id;
  if t is distinct from 'kurum' then raise exception 'tur kurum olmalıydı, % bulundu', t; end if;

  -- 3. Bölüm sayısı
  select count(*) into n from public.dossier_sections where dossier_id = d_id;
  if n <> 15 then raise exception 'Bölüm sayısı 15 olmalıydı, % bulundu', n; end if;

  -- 4. Çizicinin tanımadığı biçim — DSİ'de canlıya giden hatanın karşılığı
  select count(*) into n from public.dossier_sections
   where dossier_id = d_id
     and (body_tr like '%###%' or body_en like '%###%'
          or body_tr ~ '(^|\n)>' or body_en ~ '(^|\n)>'
          or body_tr ~ '(^|\n)[-*+] ' or body_en ~ '(^|\n)[-*+] ');
  if n > 0 then
    raise exception '% bölümün gövdesinde çizicinin tanımadığı biçim var', n;
  end if;

  -- 5. Grafik sayısı
  select count(*) into n
    from jsonb_object_keys((select charts from public.country_dossiers where id = d_id)) k;
  if n <> 13 then raise exception 'Grafik sayısı 13 olmalıydı, % bulundu', n; end if;

  -- 6. Dokuzuncu kümenin vurgusu tasarim.json'dan geliyor
  select (theme->'palet'->'sayfa'->'vurgu'->>'hex') into t
    from public.country_dossiers where id = d_id;
  if t is distinct from '#1F5626' then
    raise exception 'Kağıt vurgusu tasarim.json''dan gelmedi: %', t;
  end if;
  select (theme->'kume'->>'ad') into t from public.country_dossiers where id = d_id;
  if t is distinct from 'Üretim' then
    raise exception 'Küme adı Üretim olmalıydı, % bulundu', t;
  end if;

  -- 7. UZUNLUK TABANI — 4.000 kelime (tur 3'te kilitlendi, kullanıcı kuralı)
  -- KELİME SAYIMI: ayraç yalnız boşluk DEĞİL. Metin sabit genişlikte
  -- sarılmış; satır sonu da ayraçtır. Irak göçünde ilk sürüm yalnız boşluk
  -- sayıyordu ve 4.470 kelimelik gövdeyi 4.020 görüp göçü haksız durduruyordu.
  select sum(length(body_tr)
             - length(replace(replace(body_tr, ' ', ''), chr(10), '')) + 1) into n
    from public.dossier_sections where dossier_id = d_id and ord < 15;
  if n < 4000 then
    raise exception 'Gövde yaklaşık % kelime — taban 4.000', n;
  end if;

  -- 8. HER BÖLÜMDE GÖRSEL (kullanıcı kuralı, 3 Kasım 2026)
  --    Kaynakça (ord 15) hariç: kaynak listesinin görseli yok.
  select count(*) into n from public.dossier_sections
   where dossier_id = d_id and ord < 15
     and (gorsel is null or gorsel->>'url' is null or gorsel->>'atif' is null);
  if n > 0 then raise exception '% bölümün görseli ya da atfı yok', n; end if;

  -- 9. BÖLÜM 2'DE "PARA" YASAĞI (kullanıcı kuralı, 10 Kasım 2026)
  select count(*) into n from public.dossier_sections
   where dossier_id = d_id and ord = 2 and body_tr ~* '\mpara';
  if n > 0 then
    raise exception '2. bölümde "para" kelimesi var — kullanıcı kuralı yasaklıyor';
  end if;

  -- 10. ÖLÇÜ AYRIMI — 9. bölüm dağıtım ile satışı ayırmak zorunda
  select count(*) into n from public.dossier_sections
   where dossier_id = d_id and ord = 9
     and body_tr like '%dağıtım%' and body_tr like '%satış%';
  if n <> 1 then
    raise exception '9. bölüm dağıtım ile satışı ayırmıyor — iki rakam karışır';
  end if;

  -- 11. TEZ CÜMLESİ ÖLÇÜ TAŞIMALI — iddia değil, ölçü (§8.2)
  --
  -- BU SAĞLAMA 12 KASIM 2026'DA DÜZELTİLDİ. Önceki hâli tez cümlesinde
  -- RAKAM arıyordu ("sayılar yazıyla değil rakamla") ve devir göçünde
  -- patladı. Ölçtüm: yayındaki 10 dosyanın 8'i bu kuraldan geçemezdi.
  --
  --   dsi        "elli üç yılda dokuz yüz otuz altı..."
  --   tmo        "seksen sekiz yıldır dengeleyen kurum"
  --   avustralya "tarım ekonominin yirmi beşte biri"
  --   ziraat     "tarıma açılan kredinin üçte ikisi"
  --
  -- Yani kural dizinin kendi uygulamasının tersiydi. "Sayılar rakamla"
  -- kuralı GÖVDE metni için: 3.602.455 dekar yazıyla yazılmaz. Tez cümlesi
  -- gövde değil, belgenin açılış satırı; orada sayı OKUNUR.
  --
  -- Korunması gereken şey rakam değil ÖLÇÜ: cümle bir iddia kurmamalı,
  -- bir büyüklük vermeli. Sağlama artık onu arıyor — rakam ya da yazıyla
  -- yazılmış bir oran/miktar.
  --
  -- ON BİR CÜMLE ÖLÇÜLDÜ: dokuzu geçiyor. Geçmeyen ikisi dizinin EN ESKİ
  -- dosyaları (hollanda, ispanya) ve ikisi de gerçekten ölçüsüz — "sırrı
  -- toprağında değil, sistemde", "rakibimiz değil, müşterimiz". Yani kural
  -- zamanla sıkılaşmış: ilk dosyaların tezi bir İDDİA, sonrakilerinki bir
  -- ÖLÇÜ. Bu sağlama yalnızca bu dosyaya bakıyor; geriye dönük uygulanacak
  -- bir şey değil.
  select thesis_tr into t from public.country_dossiers where id = d_id;
  if t !~ '[0-9]'
     and lower(t) !~ ('(yüzde|yarısı|yarısında|çeyre[gğ]|'
                      'ikide|üçte|dörtte|beşte|altıda|yedide|sekizde|dokuzda|onda|'
                      'yirmi ?beşte|bin|milyon|milyar|'
                      'bir|iki|üç|dört|beş|altı|yedi|sekiz|dokuz|on|yirmi|otuz|'
                      'kırk|elli|altmış|yetmiş|seksen|doksan|yüz)') then
    raise exception 'Tez cümlesi ÖLÇÜ taşımıyor — iddia değil büyüklük '
      'vermeli (§8.2): %', t;
  end if;

  -- 12. BU GÖÇ DSİ'YE DOKUNMAMALI
  select status into t from public.country_dossiers where slug = 'dsi';
  if t is distinct from 'published' then
    raise exception 'DSİ durumu değişmiş (%) — bu göç ona dokunmamalıydı', t;
  end if;

  -- 13. ALTYAZI KÜNYEDİR, TAHLİL DEĞİL (kullanıcı kuralı, iki kez verildi)
  --
  -- 12 Kasım 2026: on dört altyazının tamamı kareye bakıp yazılmıştı ve dört
  -- maddi hata bu yoldan girmişti. Altyazı artık konu+yer+tarih söylüyor.
  -- Buradaki üç ölçü dogrula_yayin.py'nin 11. kuralının karşılığı: depo
  -- doğrulaması atlanırsa göç yine durur.
  select count(*) into n from public.dossier_sections
   where dossier_id = d_id
     and gorsel is not null
     and (
       -- kadraj sözcükleri
       lower(gorsel->>'alt_tr') ~ '(arkada|ön planda|yakın planda|kadrajda|solda|sağda|görülüyor|görünüyor)'
       or lower(gorsel->>'alt_en') ~ '(foreground|background|on the left|on the right)'
       -- görünüş envanteri
       or lower(gorsel->>'alt_tr') ~ '(rengi|renkli|desenli|şapkalı|parmaklıklı|çatılı)'
       or lower(gorsel->>'alt_en') ~ '(patterned|coloured|colored|wearing)'
     );
  if n > 0 then
    raise exception '% görselin altyazısı kareyi TAHLİL ediyor — altyazı '
      'fotoğrafın ne olduğunu söyler (kullanıcı kuralı, iki kez verildi)', n;
  end if;

  -- 14. Altyazıda tarih zorunlu. Kaynak tarihi vermiyorsa altyazı bunu
  --     AÇIKÇA yazacak; sessizce atlanmayacak.
  select count(*) into n from public.dossier_sections
   where dossier_id = d_id
     and gorsel is not null
     and gorsel->>'alt_tr' !~ '(1[89][0-9][0-9]|20[0-9][0-9])'
     and lower(gorsel->>'alt_tr') not like '%tarihi kayıtlı değil%'
     and lower(gorsel->>'alt_tr') not like '%tarihi bilinmiyor%';
  if n > 0 then
    raise exception '% görselin altyazısında tarih yok — künye tarih ister', n;
  end if;

  -- 15. "PARA" YASAĞI İKİ DİLDE (kullanıcı kuralı, 10 Kasım 2026)
  --
  -- İlk sürüm yalnızca Türkçeye bakıyordu. 12 Kasım 2026 ölçümü: İngilizce
  -- §2 iki yerde "the money" diyordu — kural Türkçede tutuluyor,
  -- çevirisinde çiğneniyordu. Kural bir üslup kararı, dile göre değişmez.
  select count(*) into n from public.dossier_sections
   where dossier_id = d_id and ord = 2
     and (body_tr ~* '\mpara' or body_en ~* '\m(money|monies|cash)\M');
  if n > 0 then
    raise exception '2. bölümde "para" karşılığı geçiyor — kullanıcı kuralı '
      'bunu yasaklıyor, ödenek/kaynak/appropriation kullanılacak';
  end if;

end
$kontrol_tigem$;
