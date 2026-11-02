-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  Etiket sayfası — /etiket/<slug>                                         ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
--
-- `articles.seo_keywords` her haberde dolu (ölçüm: 1.000 haberin 671'inde tam
-- 5 etiket) ve haber sayfasında ÇİP OLARAK ÇİZİLİYOR — ama tıklanmıyor.
-- Ekranda yer kaplayan, hiçbir yere götürmeyen bir süs (denetim M4/E4).
--
-- ADRES ASCII OLMAK ZORUNDA (§2.1): Türkçe karakterli adres mesajlaşma
-- uygulamalarında yüzde kodlamasına dönüşüp okunmaz hâle geliyor. Yani
-- "süt üretimi" etiketinin adresi /etiket/sut-uretimi olmalı.
--
-- Eşleştirme SUNUCUDA yapılıyor. İstemcide yapmanın tek yolu bütün etiketleri
-- indirip orada slug'lamaktı; 1.500 haberin etiket dizisi demek.
--
-- `etiket_slug` ÖNCE translate SONRA lower çağırıyor: Postgres'in `lower()`
-- fonksiyonu 'İ' harfini veritabanı sıralamasına göre çeviriyor ve birleşik
-- karakter üretebiliyor (§39.5'in SQL karşılığı). Harf eşlemesi önce
-- yapılınca `lower()`a yalnızca ASCII kalıyor.

create or replace function public.etiket_slug(metin text)
returns text
language sql
immutable
as $$
  select nullif(
    trim(both '-' from
      regexp_replace(
        lower(translate(coalesce(metin, ''),
                        'ıİşŞğĞüÜöÖçÇâÂîÎûÛ',
                        'iissgguuooccaaiiuu')),
        '[^a-z0-9]+', '-', 'g')),
    '')
$$;

-- Etikete göre yayındaki haberler, en yeniden eskiye.
--
-- `setof public.articles` dönüyor: PostgREST çağıranın `select=` ile sütun
-- daraltmasına izin veriyor, yani istemci `_listeSutunlari` disiplinini
-- (§20.1) burada da sürdürebiliyor.
create or replace function public.haberler_etikete_gore(
  p_slug text,
  p_limit int default 40,
  p_offset int default 0
)
returns setof public.articles
language sql
stable
as $$
  select a.*
    from public.articles a
   where a.status = 'published'
     and a.seo_keywords is not null
     and exists (
       select 1 from unnest(a.seo_keywords) k
        where public.etiket_slug(k) = public.etiket_slug(p_slug)
     )
   order by a.created_at desc
   limit greatest(1, least(p_limit, 100))
  offset greatest(0, p_offset)
$$;

grant execute on function public.etiket_slug(text) to anon, authenticated;
grant execute on function public.haberler_etikete_gore(text, int, int) to anon, authenticated;

-- ─── Sağlama ───────────────────────────────────────────────────────────────
do $$
declare s text;
begin
  select public.etiket_slug('Süt Üretimi') into s;
  if s <> 'sut-uretimi' then
    raise exception 'etiket_slug yanlis: % (beklenen sut-uretimi)', s;
  end if;
  select public.etiket_slug('İhracat Rakamları') into s;
  if s <> 'ihracat-rakamlari' then
    raise exception 'etiket_slug noktali i yanlis: %', s;
  end if;
end $$;
