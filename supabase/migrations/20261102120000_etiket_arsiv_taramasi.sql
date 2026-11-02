-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  Etiket sayfası GERÇEK arşiv taraması yapıyor                            ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
--
-- SORUN. `haberler_etikete_gore` yalnızca `seo_keywords` dizisinde BİREBİR
-- eşleşme arıyordu. Etiketler haber başına ~5 tane ve yazımları değişiyor;
-- sonuç olarak çoğu etikete tıklandığında yalnızca TIKLANAN HABER çıkıyordu.
-- "Recep Tayyip Erdoğan" etiketinde tek haber görünmesi mümkün değil —
-- arşivde o konuyla ilgili çok daha fazlası var.
--
-- ÇÖZÜM: etiket bir ARAMA TERİMİ gibi davranıyor. Üç yerde aranıyor —
-- anahtar kelimeler, başlık, ve gövde/spot — ve sonuç ALAKAYA göre
-- sıralanıyor: önce etiketi gerçekten taşıyanlar, sonra başlığında geçenler,
-- sonra metninde geçenler. Her grup kendi içinde yeniden eskiye.
--
-- EŞLEŞME SLUG ÜZERİNDEN. `ilike` kullanılmadı: Postgres'in büyük/küçük harf
-- katlaması Türkçe 'İ'/'ı' çiftinde veritabanı sıralamasına bağlı ve
-- "İHRACAT" ile "ihracat" eşleşmeyebiliyor (§39.5'in SQL karşılığı).
-- `etiket_slug` hem harf eşlemesini hem noktalamayı tekdüzeleştiriyor;
-- "Recep Tayyip Erdoğan'ın" da "recep-tayyip-erdogan" içeriyor.
--
-- TERİM SLUG'DAN GERİ ÇÖZÜLÜYOR. Adresle doğrudan gelindiğinde elimizde
-- yalnızca slug var; aynı slug'a düşen EN SIK kullanılan özgün yazım
-- bulunuyor. Böylece çipten gelmekle adresi paylaşmak aynı sonucu veriyor.

create or replace function public.haberler_etikete_gore(
  p_slug text,
  p_limit int default 40,
  p_offset int default 0
)
returns setof public.articles
language plpgsql
stable
as $$
declare
  v_slug text := public.etiket_slug(p_slug);
begin
  if v_slug is null or length(v_slug) < 2 then
    return;
  end if;

  -- Alaka ORDER BY içinde hesaplanıyor, CTE sütunu olarak DEĞİL: fazladan
  -- bir sütun `setof public.articles` dönüşünü bozuyor ("cannot cast type
  -- record to articles"). İfade iki kez yazılmış görünüyor ama planlayıcı
  -- `exists` alt sorgusunu bir kez değerlendiriyor.
  return query
  select a.*
    from public.articles a
   where a.status = 'published'
     and (
       exists (select 1 from unnest(a.seo_keywords) k
                where public.etiket_slug(k) = v_slug)
       or public.etiket_slug(a.title) like '%' || v_slug || '%'
       or public.etiket_slug(coalesce(a.spot, '')) like '%' || v_slug || '%'
       or public.etiket_slug(coalesce(a.content, '')) like '%' || v_slug || '%'
     )
   order by
     case
       when exists (select 1 from unnest(a.seo_keywords) k
                     where public.etiket_slug(k) = v_slug) then 3
       when public.etiket_slug(a.title) like '%' || v_slug || '%' then 2
       else 1
     end desc,
     a.created_at desc
   limit greatest(1, least(p_limit, 100))
  offset greatest(0, p_offset);
end $$;

grant execute on function public.haberler_etikete_gore(text, int, int) to anon, authenticated;

-- ─── Sağlama ───────────────────────────────────────────────────────────────
do $$
declare n int;
begin
  select count(*) into n
    from public.haberler_etikete_gore('tarim', 100, 0);
  if n < 1 then
    raise exception 'etiket taramasi hic sonuc dondurmedi';
  end if;
end $$;
