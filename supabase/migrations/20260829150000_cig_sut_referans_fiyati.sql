-- Çiğ inek sütü tavsiye fiyatı — Ulusal Süt Konseyi.
--
-- Türkşeker gibi ilan edilen, bir sonraki karara kadar yürürlükte kalan bir
-- fiyat: price_kind = 'administered'. Farkı: PDF değil, doğrudan okunabilir
-- bir HTML tablo — LLM okuyucu gerekmedi. Bkz.
-- tarim_ai_pipeline/src/commodities/sources/sut.py

insert into public.commodity_sources (key, label, url, scope) values
  ('sut', 'Ulusal Süt Konseyi', 'https://ulusalsutkonseyi.org.tr/kategori/cig-sut-fiyatlari/', 'Türkiye')
on conflict (key) do update
  set label = excluded.label,
      url   = excluded.url,
      scope = excluded.scope;

insert into public.commodities
  (slug, name_tr, name_en, category, unit, source, source_key, sort_order, is_active, price_kind)
values
  ('cig-sut', 'Çiğ İnek Sütü', 'Raw Cow Milk', 'hayvancilik', 'TL/lt', 'sut', 'cig-sut', 100, true, 'administered')
on conflict (slug) do update
  set name_tr    = excluded.name_tr,
      name_en    = excluded.name_en,
      category   = excluded.category,
      unit       = excluded.unit,
      source     = excluded.source,
      source_key = excluded.source_key,
      sort_order = excluded.sort_order,
      price_kind = excluded.price_kind;
