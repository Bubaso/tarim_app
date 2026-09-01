-- Pirinç — TOBB'da hiç işlem görmüyor (üretimde doğrulandı: hem PİRİNÇ
-- KIRIK hem PİRİNÇ ORTA TANE hem ÇELTİK "veri girişinde bulunulmamıştır").
-- TMO'nun kendi günlük bülteninde "PİRİNÇ (Sektör)" bloğu var. Bkz.
-- tarim_ai_pipeline/src/commodities/sources/tmo.py
--
-- price_kind = 'administered': bu blok haftalık güncelleniyor, borsa
-- fiyatı gibi günlük "bayat" sayılmamalı (Türkşeker/çiğ süt ile aynı ilke).

insert into public.commodity_sources (key, label, url, scope) values
  ('tmo', 'Toprak Mahsulleri Ofisi — Günlük Piyasa Bülteni', 'https://www.tmo.gov.tr/Upload/Document/piyasabulteni/piyasabulteni_tr.pdf', 'Türkiye')
on conflict (key) do update
  set label = excluded.label,
      url   = excluded.url,
      scope = excluded.scope;

insert into public.commodities
  (slug, name_tr, name_en, category, unit, source, source_key, sort_order, is_active, price_kind)
values
  ('pirinc-osmancik', 'Pirinç (Osmancık)', 'Rice (Osmancık)', 'hububat', 'TL/kg', 'tmo', 'pirinc-osmancik', 94, true, 'administered'),
  ('pirinc-baldo',    'Pirinç (Baldo)',    'Rice (Baldo)',    'hububat', 'TL/kg', 'tmo', 'pirinc-baldo',    95, true, 'administered')
on conflict (slug) do update
  set name_tr    = excluded.name_tr,
      name_en    = excluded.name_en,
      category   = excluded.category,
      unit       = excluded.unit,
      source     = excluded.source,
      source_key = excluded.source_key,
      sort_order = excluded.sort_order,
      price_kind = excluded.price_kind;
