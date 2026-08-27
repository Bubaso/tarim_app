-- Duyurunun tam metni artık istemciye gönderilmiyor.
--
-- Metin, fiyatın nereden geldiğini denetlemek için hattın `commodity_prices.raw`
-- alanına yazdığı kayıtta DURMAYA DEVAM EDİYOR. Değişen tek şey görünümlerin
-- neyi dışarı verdiği.
--
-- Sebebi: duyurunun tıpkıbasımı bir dönem detay kartında gösteriliyordu, sonra
-- karttan çıkarıldı (kullanıcı kararı, 25 Ağustos 2026) — belgenin kendisi zaten
-- bir tık ötede ve sayfada kalması gereken şey bizim yorumumuz. Metin dışarı
-- verilmeye devam etseydi hiçbir yerde çizilmeyen ~1,7 KB, hem şerit sorgusunda
-- hem de grafiğin sekiz geçmiş satırının her birinde istemciye inecekti.
--
-- `- 'text'` jsonb'den anahtarı düşürüyor; anahtar yoksa da hata vermiyor,
-- dolayısıyla hattın eski sürümüyle yazılmış satırlarda da güvenli.

drop view if exists public.commodity_latest_prices;

create view public.commodity_latest_prices
with (security_invoker = on) as
select
  c.slug,
  c.name_tr,
  c.name_en,
  c.category,
  c.unit,
  c.sort_order,
  c.price_kind,
  p.price_date,
  p.avg_price,
  p.min_price,
  p.max_price,
  p.volume_kg,
  p.source,
  s.label        as source_label,
  s.url          as source_url,
  s.scope        as source_scope,
  prev.avg_price as prev_avg_price,
  prev.price_date as prev_price_date,
  case
    when prev.avg_price is null or prev.avg_price <= 0 then null
    -- İdari fiyatta aradaki gün sayısı önemsiz: iki ilan arasındaki fark her
    -- zaman gerçek bir fiyat değişikliğidir.
    when c.price_kind = 'administered'
      then round((p.avg_price - prev.avg_price) / prev.avg_price * 100, 2)
    when (p.price_date - prev.price_date) <= 7
      then round((p.avg_price - prev.avg_price) / prev.avg_price * 100, 2)
  end as change_pct,
  (current_date - p.price_date) as staleness_days,
  -- Yalnızca ilan fiyatlarında dolu; belgenin tam metni hariç.
  case when c.price_kind = 'administered' then p.raw - 'text' end as notice
from public.commodities c
join public.commodity_sources s on s.key = c.source
join lateral (
  select cp.*
    from public.commodity_prices cp
   where cp.commodity_id = c.id
   order by cp.price_date desc
   limit 1
) p on true
left join lateral (
  select cp.avg_price, cp.price_date
    from public.commodity_prices cp
   where cp.commodity_id = c.id
     and cp.price_date < p.price_date
   order by cp.price_date desc
   limit 1
) prev on true
where c.is_active
  -- Bayatlık kuralı yalnızca işlem gören fiyatlara. İdari fiyat "eski" olmaz,
  -- yürürlükten kalkar — ve kalktığında yerine yeni ilan gelir.
  and (c.price_kind <> 'traded' or (current_date - p.price_date) <= 14)
order by c.sort_order, c.name_tr;

grant select on public.commodity_latest_prices to anon, authenticated;

drop view if exists public.commodity_price_history;

create view public.commodity_price_history
with (security_invoker = on) as
select
  c.slug,
  p.price_date,
  p.avg_price,
  p.min_price,
  p.max_price,
  p.volume_kg,
  p.source,
  case when c.price_kind = 'administered' then p.raw - 'text' end as notice
from public.commodity_prices p
join public.commodities c on c.id = p.commodity_id
order by p.price_date;

grant select on public.commodity_price_history to anon, authenticated;

notify pgrst, 'reload schema';
