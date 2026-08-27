-- Dosya ↔ haber bağlantısı, iki yönlü.
--
-- Dosya sayfasının altında "bu konuyla ilgili haberler", haberin içinde de
-- "bu konuda yayında bir dosyamız var".
--
-- NEDEN ANAHTAR KELİME, NEDEN OTOMATİK DEĞİL. Haberin hangi dosyaya ait
-- olduğunu metinden sezmeye çalışmak sessiz yanlış üretir: "Rusya" kelimesi
-- geçen her haber Rusya dosyasıyla ilgili değildir. Eşleşme, dosyanın kendi
-- ilan ettiği terimlerle kurulur — editör kararıdır, kod tahmini değil.
alter table public.country_dossiers
  add column if not exists anahtar_kelimeler text[] not null default '{}';

comment on column public.country_dossiers.anahtar_kelimeler is
  'Haber eşleştirmesinde aranacak terimler. yayin.json/anahtar_kelimeler''den '
  'seed ile gelir. Boşsa dosya hiçbir haberle eşleşmez — sessizce yanlış '
  'haber göstermektense hiç göstermemek doğru.';

-- ─────────────────────────────────────────────────────────────────────────
-- Bir terim metinde KELİME OLARAK geçiyor mu?
--
-- Alt dize araması yetmiyor: "Rus" araması "Rusya"yı da "Prusya"yı da
-- yakalar. \m ve \M sözcük sınırı; ILIKE yerine regex bu yüzden.
create or replace function public.terim_geciyor(metin text, terim text)
returns boolean language sql immutable parallel safe as $$
  select metin is not null
     and metin ~* ('\m' || regexp_replace(terim, '([\\.^$|()\[\]*+?{}])', '\\\1', 'g') || '\M');
$$;

-- ─────────────────────────────────────────────────────────────────────────
-- Dosyaya ait haberler, alaka sırasına göre.
--
-- Puanlama nerede geçtiğine bakıyor: başlık ve anahtar kelime editörün
-- seçtiği alanlar, gövde ise geçerken anılmış olabilir.
--   başlık            3
--   anahtar kelime    3
--   özet / spot       2
--   gövde             1
-- Yalnızca gövdede geçen haber de listeye giriyor ama en sona düşüyor.
create or replace function public.dosya_haberleri(p_slug text, p_limit int default 6)
returns table (
  id uuid, title text, title_en text, summary text, summary_en text,
  image_url text, published_at date, created_at timestamptz,
  source_name text, topic text, slug text, puan int
)
language sql stable security definer set search_path = public as $$
  with d as (
    select anahtar_kelimeler
      from country_dossiers
     where country_dossiers.slug = p_slug
       and status in ('published', 'archived')
  ), puanli as (
    select a.id, a.title, a.title_en, a.summary, a.summary_en,
           a.image_url, a.published_at, a.created_at,
           a.source_name, a.topic, a.slug,
           max(
             case
               when terim_geciyor(a.title, t) then 3
               when exists (select 1 from unnest(coalesce(a.seo_keywords, '{}')) k
                             where terim_geciyor(k, t)) then 3
               when terim_geciyor(a.summary, t) or terim_geciyor(a.spot, t) then 2
               when terim_geciyor(a.content, t) then 1
               else 0
             end
           )::int as puan
      from articles a
      cross join d
      cross join unnest(d.anahtar_kelimeler) as t
     where a.status = 'published'
     group by a.id, a.title, a.title_en, a.summary, a.summary_en,
              a.image_url, a.published_at, a.created_at,
              a.source_name, a.topic, a.slug
  )
  select * from puanli
   where puan > 0
   order by puan desc, published_at desc nulls last, created_at desc
   limit greatest(p_limit, 0);
$$;

comment on function public.dosya_haberleri is
  'Dosyanın anahtar kelimeleriyle eşleşen yayımlanmış haberler, alaka sırasına göre.';

-- ─────────────────────────────────────────────────────────────────────────
-- Haberin ilgili olduğu dosyalar.
--
-- Ters yön. Haber sayfasında "bu konuda bir dosyamız var" şeridi için.
-- Aynı puanlama; yalnızca gövdede geçmek YETMİYOR (puan > 1), çünkü bir
-- haberin gövdesinde adı geçen her ülke için şerit çıkarmak gürültü olurdu.
create or replace function public.haber_dosyalari(p_article_id uuid)
returns table (
  slug text, name_tr text, name_en text, tur text, edition int,
  thesis_tr text, thesis_en text, cover_url text, theme jsonb, puan int
)
language sql stable security definer set search_path = public as $$
  with a as (
    select title, summary, spot, content, coalesce(seo_keywords, '{}') as kw
      from articles where id = p_article_id and status = 'published'
  )
  select d.slug, d.name_tr, d.name_en, d.tur, d.edition,
         d.thesis_tr, d.thesis_en, d.cover_url, d.theme,
         max(
           case
             when terim_geciyor(a.title, t) then 3
             when exists (select 1 from unnest(a.kw) k where terim_geciyor(k, t)) then 3
             when terim_geciyor(a.summary, t) or terim_geciyor(a.spot, t) then 2
             when terim_geciyor(a.content, t) then 1
             else 0
           end
         )::int as puan
    from country_dossiers d
    cross join a
    cross join unnest(d.anahtar_kelimeler) as t
   where d.status in ('published', 'archived')
   group by d.slug, d.name_tr, d.name_en, d.tur, d.edition,
            d.thesis_tr, d.thesis_en, d.cover_url, d.theme
  having max(
           case
             when terim_geciyor(a.title, t) then 3
             when exists (select 1 from unnest(a.kw) k where terim_geciyor(k, t)) then 3
             when terim_geciyor(a.summary, t) or terim_geciyor(a.spot, t) then 2
             when terim_geciyor(a.content, t) then 1
             else 0
           end
         ) > 1
   order by puan desc, d.edition desc;
$$;

comment on function public.haber_dosyalari is
  'Haberin ilgili olduğu yayımlanmış dosyalar. Yalnızca gövdede geçmek yetmez.';

grant execute on function public.terim_geciyor(text, text)   to anon, authenticated;
grant execute on function public.dosya_haberleri(text, int)  to anon, authenticated;
grant execute on function public.haber_dosyalari(uuid)       to anon, authenticated;
