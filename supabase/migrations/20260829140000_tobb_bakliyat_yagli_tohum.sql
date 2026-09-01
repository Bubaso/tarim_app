-- TOBB merkezi borsa portalı — hububat/emtia listesini genişletiyor.
--
-- Polatlı yalnızca hububat borsası: nohut, mercimek, fasulye, ayçiçeği hiç
-- işlem görmüyordu. TOBB (borsa.tobb.org.tr) Türkiye'deki tüm ticaret
-- borsalarının fiyatlarını tek merkezde topluyor. Bkz.
-- tarim_ai_pipeline/src/commodities/sources/tobb.py
--
-- source_key = 'ana_kod-alt_kod' (TOBB'un kendi ürün kodları, ör. '3-704'
-- = BAKLİYAT VE MAMÜLLERİ grubu / NOHUT). Yeni kategori: 'bakliyat'.

insert into public.commodity_sources (key, label, url, scope) values
  ('tobb', 'TOBB — Türkiye Odalar ve Borsalar Birliği', 'https://borsa.tobb.org.tr/fiyat_urun.php', 'Türkiye')
on conflict (key) do update
  set label = excluded.label,
      url   = excluded.url,
      scope = excluded.scope;

insert into public.commodities
  (slug, name_tr, name_en, category, unit, source, source_key, sort_order, is_active)
values
  ('nohut',            'Nohut',                    'Chickpeas',        'bakliyat',    'TL/kg', 'tobb', '3-704', 90, true),
  ('mercimek-kirmizi', 'Kırmızı Mercimek',          'Red Lentils',      'bakliyat',    'TL/kg', 'tobb', '3-601', 91, true),
  ('mercimek-yesil',   'Yeşil Mercimek',            'Green Lentils',    'bakliyat',    'TL/kg', 'tobb', '3-609', 92, true),
  ('kuru-fasulye',     'Kuru Fasulye',              'Dry Beans',        'bakliyat',    'TL/kg', 'tobb', '3-501', 93, true),
  ('aycicegi-yaglik',  'Ayçiçeği (Yağlık)',         'Sunflower Seed',   'yagli-tohum', 'TL/kg', 'tobb', '4-602', 71, true)
on conflict (slug) do update
  set name_tr    = excluded.name_tr,
      name_en    = excluded.name_en,
      category   = excluded.category,
      unit       = excluded.unit,
      source     = excluded.source,
      source_key = excluded.source_key,
      sort_order = excluded.sort_order;
