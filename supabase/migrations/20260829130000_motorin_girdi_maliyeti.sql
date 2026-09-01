-- Motorin — ilk "tarım maliyet girdisi" kalemi.
--
-- Şimdiye kadar tablodaki her satır çiftçinin SATTIĞI şeyi gösteriyordu
-- (buğday, şeker). Motorin ilk kez ALDIĞI bir şeyi gösteriyor: mazot, ekim-
-- hasat maliyetinin en büyük tek kalemlerinden biri.
--
-- Kaynak notu: EPDK'nin kendi XML web servisi artık erişilebilir değil
-- (eski dokümantasyonda geçen dbs.epdk.org.tr / dbs.epdk.gov.tr adresleri
-- DNS'te hiç çözülmüyor, bildirim.epdk.gov.tr yalnızca elle doldurulan bir
-- form). Bu yüzden EPDK verisini kendi derlediğini belirten, ücretsiz ve
-- anahtar istemeyen bir aracı kullanılıyor: ucuzyakitbul.com.tr. Kaynak
-- etiketi bunu saklamıyor — "EPDK (ucuzyakitbul.com.tr aracılığıyla)".
-- Bkz. tarim_ai_pipeline/src/commodities/sources/motorin.py

insert into public.commodity_sources (key, label, url, scope) values
  ('motorin', 'EPDK (ucuzyakitbul.com.tr aracılığıyla)', 'https://ucuzyakitbul.com.tr', 'Türkiye')
on conflict (key) do update
  set label = excluded.label,
      url   = excluded.url,
      scope = excluded.scope;

insert into public.commodities
  (slug, name_tr, name_en, category, unit, source, source_key, sort_order, is_active)
values
  ('motorin', 'Motorin', 'Diesel', 'girdi', 'TL/lt', 'motorin', 'motorin', 5, true)
on conflict (slug) do update
  set name_tr    = excluded.name_tr,
      name_en    = excluded.name_en,
      category   = excluded.category,
      unit       = excluded.unit,
      source     = excluded.source,
      source_key = excluded.source_key,
      sort_order = excluded.sort_order;
