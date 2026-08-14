-- Türkiye tarım emtia fiyatları.
--
-- Uygulamada zaten bir "borsa" modülü var ama o Yahoo Finance'ten KÜRESEL
-- vadeli işlem çekiyor: CBOT buğdayı sent/bushel, ICE şekeri sent/libre.
-- Ankara'daki okuyucunun "buğday bugün kaç lira?" sorusuna o rakamlar cevap
-- vermiyor. Bu tablolar o boşluğu dolduruyor: Türkiye borsalarında GERÇEKTEN
-- işlem görmüş fiyatlar, TL/kg.
--
-- Veriyi Python hattı yazıyor, Flutter yalnızca okuyor. Mevcut modüldeki
-- CORS proxy zinciri (dört katman, ~36 sn timeout) burada tekrarlanmıyor:
-- tarayıcı kendi veritabanımızdan tek sorguyla alıyor.

-- ─── Kaynaklar ────────────────────────────────────────────────────────────
-- Ayrı tablo, çünkü karta basan okuyucuya "bu rakam nereden geldi" sorusunun
-- cevabı tıklanabilir bir bağlantı olarak gösteriliyor. Etiketi her fiyat
-- satırında tekrarlamak yerine tek yerde tutuyoruz.
create table if not exists public.commodity_sources (
  key         text primary key,
  label       text not null,
  url         text,
  -- Kaynağın kapsadığı coğrafya. "Polatlı" fiyatı Türkiye ortalaması değil;
  -- kartın altındaki etiket bunu saklamamalı.
  scope       text not null default 'Türkiye'
);

insert into public.commodity_sources (key, label, url, scope) values
  ('polatli',   'Polatlı Ticaret Borsası', 'https://www.polatliborsa.org.tr/gunluk-bulten.html', 'Polatlı'),
  ('turkseker', 'Türkiye Şeker Fabrikaları', 'https://www.turkseker.gov.tr', 'Türkiye'),
  ('haldefiyat','HalDeFiyat',               'https://haldefiyat.com', 'Türkiye')
on conflict (key) do update
  set label = excluded.label,
      url   = excluded.url,
      scope = excluded.scope;

-- ─── Ürünler ──────────────────────────────────────────────────────────────
create table if not exists public.commodities (
  id          bigserial primary key,
  -- Adres satırında görünür: /emtia/bugday. Ürün adı değişse bile slug sabit
  -- kalır — paylaşılan bağlantı kırılmasın.
  slug        text not null unique,
  name_tr     text not null,
  name_en     text not null,
  -- 'hububat' | 'yagli-tohum' | 'seker' | 'meyve-sebze' | 'hayvancilik'
  category    text not null,
  -- Şimdilik hepsi TL/kg. Sütun yine de var: canlı hayvan (TL/adet) ve
  -- yumurta (TL/koli) eklenirse kartın birimi satırdan gelsin, koda gömülmesin.
  unit        text not null default 'TL/kg',
  source      text not null references public.commodity_sources(key),
  -- Kaynağın kendi ürün anahtarı. Polatlı'da bülten hiyerarşisindeki ürün
  -- kodu öneki ('110' = BUĞDAY), HalDeFiyat'ta productSlug.
  source_key  text not null,
  sort_order  integer not null default 100,
  -- Seyrek işlem gören ürün (yılda birkaç gün) şeritte sürekli "bayat" görünür.
  -- Kapatmak için kod değişikliği değil tek satır update yeter.
  is_active   boolean not null default true,
  created_at  timestamptz not null default now(),
  unique (source, source_key)
);

-- ─── Fiyatlar ─────────────────────────────────────────────────────────────
create table if not exists public.commodity_prices (
  id           bigserial primary key,
  commodity_id bigint      not null references public.commodities(id) on delete cascade,
  -- Kaynağın KENDİ bülten tarihi; çekme tarihi değil. TOBB sayfalarında
  -- ağustosta mayıs verisi durduğu görüldü — çekme tarihini yazsaydık üç aylık
  -- bayat rakam bugünün fiyatı gibi görünecekti.
  price_date   date        not null,
  -- Hacim ağırlıklı ortalama: sum(işlem tutarı) / sum(miktar). Alt kalemlerin
  -- ortalamasını almak 31 tonluk partiyle 2.080 tonluk partiyi eşitliyordu.
  avg_price    numeric(12,4) not null,
  min_price    numeric(12,4),
  max_price    numeric(12,4),
  volume_kg    numeric(16,2),
  source       text        not null references public.commodity_sources(key),
  -- Kaynağın ham satırları. Bir gün fiyat şüpheli görünürse ayrıştırma
  -- hatası mı kaynak hatası mı olduğu ancak buradan anlaşılır.
  raw          jsonb,
  fetched_at   timestamptz not null default now(),
  unique (commodity_id, price_date, source)
);

-- Hem "bu ürünün son iki kaydı" (kart) hem "son 90 gün" (grafik) sorgusu
-- bu tek indeksle çalışır.
create index if not exists commodity_prices_lookup_idx
  on public.commodity_prices (commodity_id, price_date desc);

-- ─── Çekme defteri ────────────────────────────────────────────────────────
-- Kaynak sitenin HTML'i değiştiğinde ayrıştırıcı hata vermez, sessizce sıfır
-- satır döndürür. Şerit birkaç gün eski fiyatı gösterip donar ve kimse fark
-- etmez. Bu defter "dün 7 satır, bugün 0" farkını görünür kılıyor.
create table if not exists public.commodity_fetch_log (
  id          bigserial primary key,
  source      text        not null,
  run_at      timestamptz not null default now(),
  price_date  date,
  row_count   integer     not null default 0,
  ok          boolean     not null default true,
  message     text
);

create index if not exists commodity_fetch_log_source_idx
  on public.commodity_fetch_log (source, run_at desc);

-- ─── Şerit görünümü ───────────────────────────────────────────────────────
-- Kartın ihtiyacı olan her şey tek satırda: fiyat, günlük değişim, kaynak
-- etiketi, tarih. Değişim yüzdesini istemcide hesaplamak, "önceki fiyat" için
-- ikinci bir sorgu ya da tüm geçmişi indirmek demekti.
--
-- security_invoker: görünüm, çağıranın yetkisiyle çalışsın. Aksi halde
-- görünüm sahibinin yetkisiyle çalışır ve altındaki tabloların RLS'i baypas
-- edilir.
create or replace view public.commodity_latest_prices
with (security_invoker = on) as
select
  c.slug,
  c.name_tr,
  c.name_en,
  c.category,
  c.unit,
  c.sort_order,
  p.price_date,
  p.avg_price,
  p.min_price,
  p.max_price,
  p.volume_kg,
  p.source,
  s.label       as source_label,
  s.url         as source_url,
  s.scope       as source_scope,
  prev.avg_price as prev_avg_price,
  -- "Günlük değişim" ancak önceki kayıt gerçekten yakın bir güne aitse
  -- anlamlı. Çavdar ayda birkaç gün işlem görüyor; bir aylık farkı günlük
  -- değişim diye göstermek okuyucuya yalan söylemek olur. Böyle durumda
  -- yüzde null döner ve kart yerine tire koyar.
  case
    when prev.avg_price is not null
     and prev.avg_price > 0
     and (p.price_date - prev.price_date) <= 7
    then round((p.avg_price - prev.avg_price) / prev.avg_price * 100, 2)
  end as change_pct,
  (current_date - p.price_date) as staleness_days
from public.commodities c
join public.commodity_sources s on s.key = c.source
-- lateral: her ürün için yalnızca en son satır okunur. Tüm tabloyu tarayıp
-- gruplamaya göre indeksle nokta atışı çalışır.
join lateral (
  select cp.*
    from public.commodity_prices cp
   where cp.commodity_id = c.id
   order by cp.price_date desc
   limit 1
) p on true
-- Bir ÖNCEKİ işlem günü — takvimdeki dün değil. Hafta sonu ve tatilde borsa
-- kapalı; "dün" diye boş güne bakan bir hesap her pazartesi değişim
-- üretemezdi.
left join lateral (
  select cp.avg_price, cp.price_date
    from public.commodity_prices cp
   where cp.commodity_id = c.id
     and cp.price_date < p.price_date
   order by cp.price_date desc
   limit 1
) prev on true
where c.is_active
  -- İki haftadan eski fiyat gösterilmez. Bir ürün sezon dışıysa kartı hiç
  -- olmasın; "17,65 TL" yazıp yanına küçük harfle "23 gün önce" yazmak
  -- okuyucuyu yanıltıyor.
  and (current_date - p.price_date) <= 14
order by c.sort_order, c.name_tr;

-- ─── Geçmiş görünümü ──────────────────────────────────────────────────────
-- Detay sayfasındaki grafik slug ile sorgular. Bu görünüm olmasaydı istemci
-- önce id çözmek için ikinci bir gidiş dönüş yapacaktı.
create or replace view public.commodity_price_history
with (security_invoker = on) as
select
  c.slug,
  p.price_date,
  p.avg_price,
  p.min_price,
  p.max_price,
  p.volume_kg,
  p.source
from public.commodity_prices p
join public.commodities c on c.id = p.commodity_id
order by p.price_date;

-- ─── RLS ──────────────────────────────────────────────────────────────────
-- Fiyat verisi kamuya açık bültenlerden geliyor; okuma herkese açık.
-- Yazma yalnızca service_role: hattın dışından kimse fiyat uyduramasın.
alter table public.commodities        enable row level security;
alter table public.commodity_prices   enable row level security;
alter table public.commodity_sources  enable row level security;
alter table public.commodity_fetch_log enable row level security;

drop policy if exists "anon can read commodities" on public.commodities;
create policy "anon can read commodities"
  on public.commodities for select
  to anon, authenticated using (true);

drop policy if exists "anon can read commodity prices" on public.commodity_prices;
create policy "anon can read commodity prices"
  on public.commodity_prices for select
  to anon, authenticated using (true);

drop policy if exists "anon can read commodity sources" on public.commodity_sources;
create policy "anon can read commodity sources"
  on public.commodity_sources for select
  to anon, authenticated using (true);

-- Çekme defterinde politika yok: RLS açık ve hiçbir select politikası
-- tanımlanmadığı için anon hiçbir satır göremez. Operasyon kaydı, okuyucunun
-- işi değil.

grant select on public.commodities            to anon, authenticated;
grant select on public.commodity_prices       to anon, authenticated;
grant select on public.commodity_sources      to anon, authenticated;
grant select on public.commodity_latest_prices to anon, authenticated;
grant select on public.commodity_price_history to anon, authenticated;

notify pgrst, 'reload schema';
