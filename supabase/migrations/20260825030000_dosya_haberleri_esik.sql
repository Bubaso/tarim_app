-- dosya_haberleri: alaka eşiği parametresi.
--
-- İlk sürüm gövdede geçen haberi de listeliyordu (puan 1). Gerçek veriyle
-- bakınca gürültü çıktı: "Karacadağ'ın kuru domatesleri" haberinde Hollanda
-- yalnızca geçerken anılıyor ve o haberi "Hollanda dosyasıyla ilgili" diye
-- göstermek okuru yanıltır.
--
-- Eşik 2: başlıkta, anahtar kelimede, özette ya da spotta geçmesi gerekiyor.
-- Ters yöndeki `haber_dosyalari` zaten aynı eşiği kullanıyordu; iki yön
-- artık aynı ölçüyle çalışıyor.
create or replace function public.dosya_haberleri(
  p_slug text, p_limit int default 6, p_min_puan int default 2)
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
   where puan >= greatest(p_min_puan, 1)
   order by puan desc, published_at desc nulls last, created_at desc
   limit greatest(p_limit, 0);
$$;

grant execute on function public.dosya_haberleri(text, int, int) to anon, authenticated;
