-- Avustralya görsel adresleri: Supabase deposu → tarimportali.net
--
-- Kullanıcı onayı alındı (12 Kasım 2026).
--
-- ── BU BİR GÖÇ DEĞİL, AYRIŞMA DÜZELTMESİ ─────────────────────────────────
-- Dosya taşınmıyor; dosyalar HER İKİ YERDE DE duruyor. Düzeltilen şey
-- veritabanının deponun gösterdiği yeri göstermesi:
--
--   content/dossiers/avustralya/yayin.json → tarimportali.net   (14 görsel)
--   canlı country_dossiers + dossier_sections → supabase.co     (14 görsel)
--
-- Depo yeni şemaya geçirilmiş, veritabanı hiç yeniden seed edilmemiş. İkisi
-- aylardır ayrı yeri gösteriyordu ve kimse görmedi: Avustralya 2 Kasım'da
-- arşive düştü ve arşiv sayfalarına bakılmıyor. 12 Kasım 2026'da
-- durum_bekcisi.mjs'ye görsel adresi kontrolü eklenince çıktı.
--
-- ── HEDEF ADRESLER ZATEN AYAKTA ──────────────────────────────────────────
-- On dördünün tamamı göçten ÖNCE tek tek sınandı: 14/14 → 200 +
-- content-type: image/jpeg. Dosyalar web/dosya/avustralya altında, hosting
-- statik olarak sunuyor. Yani kırılma penceresi YOK — yeni adres şu an
-- çalışıyor, eski adres de çalışmaya devam ediyor.
--
-- ── HOLLANDA'NIN VİDEOSUNA DOKUNULMUYOR ──────────────────────────────────
-- country_folder_videos kovasındaki .mp4 hem depoda hem veritabanında
-- supabase.co; orada ayrışma YOK ve o gerçekten taşınacak tek kalem.
-- Kapsam bilerek `dossier-images/avustralya/` önekiyle sınırlı.
--
-- ── SIRA (paralel oturumla kararlaştırıldı) ──────────────────────────────
-- ÖNCE veritabanı, SONRA kova. Ters sırada, kova boşalıp veritabanı
-- güncellenmeden önce Avustralya'nın arşiv sayfası ve paylaşım kartları
-- kırılırdı.

-- Eski önek → yeni önek. replace() dosya adını olduğu gibi taşıyor.
update public.country_dossiers
   set cover_url = replace(
         cover_url,
         'https://xkwcyavcltrweunvooeu.supabase.co/storage/v1/object/public/dossier-images/avustralya/',
         'https://tarimportali.net/dosya/avustralya/')
 where slug = 'avustralya'
   and cover_url like '%/dossier-images/avustralya/%';

update public.dossier_sections s
   set gorsel = jsonb_set(
         s.gorsel, '{url}',
         to_jsonb(replace(
           s.gorsel->>'url',
           'https://xkwcyavcltrweunvooeu.supabase.co/storage/v1/object/public/dossier-images/avustralya/',
           'https://tarimportali.net/dosya/avustralya/')))
  from public.country_dossiers d
 where d.id = s.dossier_id
   and d.slug = 'avustralya'
   and s.gorsel->>'url' like '%/dossier-images/avustralya/%';

-- portal_stories.items bir DİZİ; her öğenin gorsel_url'ü ayrı ayrı yazılıyor.
update public.portal_stories p
   set items = (
         select jsonb_agg(
                  case
                    when e->>'gorsel_url' like '%/dossier-images/avustralya/%'
                      then jsonb_set(e, '{gorsel_url}',
                             to_jsonb(replace(
                               e->>'gorsel_url',
                               'https://xkwcyavcltrweunvooeu.supabase.co/storage/v1/object/public/dossier-images/avustralya/',
                               'https://tarimportali.net/dosya/avustralya/')))
                    else e
                  end
                  order by sira)
           from jsonb_array_elements(p.items) with ordinality t(e, sira))
 where p.items::text like '%/dossier-images/avustralya/%';

update public.portal_stories
   set gorsel_url = replace(
         gorsel_url,
         'https://xkwcyavcltrweunvooeu.supabase.co/storage/v1/object/public/dossier-images/avustralya/',
         'https://tarimportali.net/dosya/avustralya/')
 where gorsel_url like '%/dossier-images/avustralya/%';

-- ════════════════════════════════════════════════════════════════════════
-- SAĞLAMA — biri tutmazsa düzeltme tümden geri alınır
-- ════════════════════════════════════════════════════════════════════════
do $kontrol$
declare n integer; t text;
begin
  -- 1. SATIR DEĞİL ADRES SAYILIYOR.
  --    Paralel oturum ilk ölçümünde dossier_sections'ı dossier_id'ye göre
  --    gruplayıp "1 satır" demişti; gerçek 13 satır. "3 satır güncellendi"
  --    diye bir kontrol bu göçü GEÇİRİR ve on iki görseli eski adreste
  --    bırakırdı. Tek güvenli ölçü: hiç kalmamış olması.
  select count(*) into n from public.country_dossiers
   where coalesce(cover_url, '') like '%/dossier-images/avustralya/%';
  if n > 0 then raise exception '% kapak hâlâ eski adreste', n; end if;

  select count(*) into n from public.dossier_sections
   where coalesce(gorsel->>'url', '') like '%/dossier-images/avustralya/%';
  if n > 0 then raise exception '% bölüm görseli hâlâ eski adreste', n; end if;

  select count(*) into n from public.portal_stories
   where items::text like '%/dossier-images/avustralya/%'
      or coalesce(gorsel_url, '') like '%/dossier-images/avustralya/%';
  if n > 0 then raise exception '% hikâye hâlâ eski adreste', n; end if;

  -- 2. Yeni adresler gerçekten yazılmış olmalı — "hiç kalmadı" boş bir
  --    tablodan da gelebilirdi.
  select count(*) into n from public.dossier_sections s
    join public.country_dossiers d on d.id = s.dossier_id
   where d.slug = 'avustralya'
     and s.gorsel->>'url' like 'https://tarimportali.net/dosya/avustralya/%';
  if n <> 13 then
    raise exception 'Avustralya bölüm görseli %, 13 olmalı', n;
  end if;

  select cover_url into t from public.country_dossiers where slug = 'avustralya';
  if t not like 'https://tarimportali.net/dosya/avustralya/%' then
    raise exception 'Avustralya kapağı yeni adrese geçmedi: %', t;
  end if;

  -- 3. HOLLANDA'NIN VİDEOSUNA DOKUNULMAMIŞ OLMALI.
  select video_url into t from public.country_dossiers where slug = 'hollanda';
  if t is null or t not like '%country_folder_videos%' then
    raise exception 'Hollanda videosu değişmiş (%) — bu göç ona dokunmamalıydı', t;
  end if;

  -- 4. Başka hiçbir dosyanın görseli bu göçten etkilenmemiş olmalı.
  select count(*) into n from public.dossier_sections s
    join public.country_dossiers d on d.id = s.dossier_id
   where d.slug <> 'avustralya'
     and s.gorsel->>'url' like '%/dosya/avustralya/%';
  if n > 0 then
    raise exception '% bölüm yanlışlıkla avustralya adresine çevrilmiş', n;
  end if;
end
$kontrol$;
