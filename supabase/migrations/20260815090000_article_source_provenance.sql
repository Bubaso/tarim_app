-- Haberin kaynağına ne kadar dayandığını kayda geçirir.
--
-- Neden gerekiyor
-- ---------------
-- Hattın iki ayrı arızası var ve ikisi de ancak kaynakla karşılaştırınca
-- görülüyor:
--
--   * Zengin kaynakta bilgi kaybı — Medical News Today'in 7.022 kelimelik
--     yazısından 273 kelime kalmıştı (%4).
--   * Kısa kaynakta uydurma — Dünya Gazetesi'nin 32 kelimelik duyurusundan
--     130 kelimelik haber çıkmıştı (%406). Aradaki fark modelin kendi
--     cümleleriydi.
--
-- Elde yalnızca çıktı varken bu ikisi ayırt edilemez: 130 kelimelik haber
-- tek başına gayet normal görünür. Ayırt eden şey oran, oranı hesaplamak
-- için de kaynağın boyutunu saklamak gerekiyor. Bu sütunlar onun için.
--
-- src/quality.py bu alanları okuyup "%40 altı = kayıp, %120 üstü = uydurma"
-- bandını raporluyor. Sütunlar boşken o ölçüt hiç hesaplanamıyordu.

alter table public.articles
  -- Modele giden gövdenin karakter sayısı. 0 ise kaynak metni alınamamış.
  add column if not exists source_chars integer,

  -- 'full'  : kaynak sayfadan gövde alındı, tam haber yazılabilir.
  -- 'brief' : yalnızca RSS özeti var; kısa haber yazılır, şişirilmez.
  add column if not exists source_depth text,

  -- Hangi basamaktan geldi: 'content_encoded', 'trafilatura', 'rss',
  -- 'http_403' gibi. Bir kaynak sessizce bozulduğunda buradan görülür.
  add column if not exists extraction_method text;

alter table public.articles
  drop constraint if exists articles_source_depth_check;

alter table public.articles
  add constraint articles_source_depth_check
  check (source_depth is null or source_depth in ('full', 'brief'));

-- Kalite raporu bu iki alan üzerinden dönem karşılaştırması yapıyor.
create index if not exists articles_source_depth_created_idx
  on public.articles (source_depth, created_at desc);

comment on column public.articles.source_chars is
  'Modele giden kaynak gövdesinin karakter sayısı; kaynak/çıktı oranı için.';
comment on column public.articles.source_depth is
  'full = kaynak gövdesi alındı, brief = yalnızca RSS özeti vardı.';
comment on column public.articles.extraction_method is
  'Gövdenin hangi yöntemle elde edildiği (content_encoded/trafilatura/rss/http_*).';
