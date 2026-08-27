-- Duyurunun aslını uygulamaya taşır.
--
-- Türkşeker fiyatı diğer emtialara benzemiyor. Buğdayda kartın gösterdiği rakam
-- kendi kendini açıklıyor: bir borsada, bir günde, işlem görmüş ortalama. Şekerde
-- ise rakam bir METNİN yorumu. 21.08.2026 duyurusu beş fabrikadan, 28 Ağustos'a
-- kadar, tonaja ve ödeme biçimine göre dört ayrı fiyat ilan ediyor:
--
--     0 – 5.000 ton        peşin 38,6139    3 taksit 43,4159
--     5.000 ton ve üzeri   peşin 37,6238    3 taksit 42,3269
--
-- Kartta bunlardan biri görünüyor (en düşüğü). Okuyucunun "neden bu rakam"
-- sorusunu sorması kaçınılmaz ve tek dürüst cevap duyurunun kendisi. Bu yüzden
-- ilanın tamamı — başlığı, kapsamı, bütün fiyat kademeleri, geçerlilik tarihi ve
-- PDF'ten çıkarılmış tablolu metni — fiyat satırıyla birlikte taşınıyor.
--
-- `raw` doğrudan açılmıyor, `price_kind` süzgecinden geçiriliyor: Polatlı
-- satırlarının `raw` alanında o günkü bültenin bütün kalemleri duruyor (yüzlerce
-- satır) ve şeridin her açılışında istemciye inmesinin hiçbir karşılığı yok.

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
  -- Yalnızca ilan fiyatlarında dolu.
  case when c.price_kind = 'administered' then p.raw end as notice
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

-- ─── Grafik verisi ────────────────────────────────────────────────────────
-- Duyuru geçmişe de bağlanıyor. Grafikteki her basamak bir ilan ve okuyucu
-- "temmuzda neden 38,61'e indi" diye sorduğunda cevabı o günün duyurusunda:
-- beş günlük bir kampanyaydı. Noktaya dokununca o günün ilanı açılıyor —
-- fiyat grafiği ile onu doğuran belge ayrı yerlerde durmuyor.

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
  case when c.price_kind = 'administered' then p.raw end as notice
from public.commodity_prices p
join public.commodities c on c.id = p.commodity_id
order by p.price_date;

grant select on public.commodity_price_history to anon, authenticated;

notify pgrst, 'reload schema';
