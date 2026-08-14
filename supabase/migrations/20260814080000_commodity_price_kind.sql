-- İdari fiyat ile işlem gören fiyatı ayır.
--
-- İlk tasarım her fiyatın bir borsada işlem görerek oluştuğunu varsayıyordu.
-- Kristal şeker öyle değil: Türkşeker bir fiyat İLAN ediyor ve o fiyat bir
-- sonraki ilana kadar geçerli kalıyor. Aradaki fark görünüme gömülü iki kuralı
-- bozuyor:
--
--   1. "14 günden eski fiyatı gizle" — buğdayda doğru (dünkü bülten bugünün
--      fiyatı değil), şekerde yanlış. 27 Temmuz'da ilan edilen 42,00 TL bugün
--      hâlâ yürürlükte; gizlemek doğru fiyatı saklamak olurdu.
--
--   2. "İki kayıt arası 7 günü aşarsa değişim gösterme" — buğdayda doğru
--      (çavdarın bir aylık farkını günlük değişim diye göstermemek için),
--      şekerde yanlış. Şeker fiyatı yılda birkaç kez değişiyor; 34,70 → 40,00
--      gerçek ve haber değeri olan bir hareket, sırf araya beş ay girdi diye
--      tire koymak bilgiyi çöpe atmak olur.
--
-- Bu yüzden kural ürünün türüne bağlanıyor, hepsine birden uygulanmıyor.

alter table public.commodities
  add column if not exists price_kind text not null default 'traded';

-- Kısıt ayrı ifadede: `add column ... check` tekrar çalıştırıldığında
-- "constraint already exists" veriyor, `if not exists` sütunu koruyor ama
-- kısıtı korumuyor.
alter table public.commodities
  drop constraint if exists commodities_price_kind_check;
alter table public.commodities
  add constraint commodities_price_kind_check
  check (price_kind in ('traded', 'administered'));

comment on column public.commodities.price_kind is
  'traded = borsada işlem görmüş fiyat (Polatlı). '
  'administered = ilan edilmiş, bir sonraki ilana kadar geçerli fiyat (Türkşeker).';

update public.commodities set price_kind = 'administered' where source = 'turkseker';

-- Kristal şeker açılıyor. Seed yazıldığında kapalıydı çünkü Türkşeker'in
-- yapısal bir uç noktası yok; duyuru PDF'lerinin metin katmanı olduğu ve
-- ülke geneli fiyatın bölgesel/paketli/vadeli kampanyalardan ayrılabildiği
-- doğrulandıktan sonra açıldı (bkz. sources/turkseker.py).
update public.commodities set is_active = true where slug = 'kristal-seker';

-- ─── Şerit görünümü, tür farkını gözeterek ────────────────────────────────
-- Önce düşürülüyor: `create or replace view` var olan sütunların arasına yeni
-- sütun ekleyemiyor, "cannot change name of view column" hatası veriyor.
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
  (current_date - p.price_date) as staleness_days
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

notify pgrst, 'reload schema';
