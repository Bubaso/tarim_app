-- Başlangıç ürün listesi.
--
-- Liste kısa, çünkü kaynak araştırması beklenenden dar bir sonuç verdi.
-- 93 işlem günü taranarak Polatlı bülteninde hangi ürünün kaç gün işlem
-- gördüğü sayıldı:
--
--     BUĞDAY     93/93      ARPA       93/93
--     MISIR      29/93      YULAF      22/93
--     TRİTİKALE  15/93      ÇAVDAR      9/93
--     KANOLA      5/93
--
-- Nohut, mercimek, fasulye, ayçiçeği bültende HİÇ geçmiyor — Polatlı bir
-- hububat borsası. Meyve/sebze için bakılan HalDeFiyat'ın kullanım koşulları
-- otomatik veri toplamayı ve ticari yeniden yayını açıkça yasaklıyor; yazılı
-- izin alınmadan eklenmiyor. Türkşeker fiyatı yalnızca düzensiz PDF
-- duyurularında yayımlanıyor, yapısal bir uç nokta yok.
--
-- Seyrek işlem gören ürünler yine de aktif bırakıldı: görünüm 14 günden eski
-- fiyatı zaten gizliyor, dolayısıyla kanola işlem gördüğü hafta şeritte
-- belirip sonra kendiliğinden kayboluyor. Listeyi elle açıp kapamaya gerek yok.

insert into public.commodities
  (slug, name_tr, name_en, category, unit, source, source_key, sort_order, is_active)
values
  -- source_key = Polatlı bülten hiyerarşisindeki ürün grubu kodu. Ayrıştırıcı
  -- bu önekle başlayan ve fiyatı sıfırdan büyük olan alt kalemleri toplar.
  ('bugday',    'Buğday',        'Wheat',      'hububat',    'TL/kg', 'polatli', '110', 10, true),
  ('arpa',      'Arpa',          'Barley',     'hububat',    'TL/kg', 'polatli', '111', 20, true),
  ('misir',     'Mısır',         'Corn',       'hububat',    'TL/kg', 'polatli', '114', 30, true),
  ('yulaf',     'Yulaf',         'Oats',       'hububat',    'TL/kg', 'polatli', '113', 40, true),
  ('tritikale', 'Tritikale',     'Triticale',  'hububat',    'TL/kg', 'polatli', '115', 50, true),
  ('cavdar',    'Çavdar',        'Rye',        'hububat',    'TL/kg', 'polatli', '112', 60, true),
  ('kanola',    'Kanola',        'Canola',     'yagli-tohum','TL/kg', 'polatli', '144', 70, true),

  -- Şeker fiyatı borsada oluşmuyor, Türkşeker ilan ediyor: bir sonraki ilana
  -- kadar yürürlükte kalıyor. Bu yüzden price_kind = 'administered'
  -- (20260814080000) ve bayatlık kuralı bu satıra işlemiyor.
  ('kristal-seker', 'Kristal Şeker', 'Crystal Sugar', 'seker', 'TL/kg', 'turkseker', 'kristal', 80, true)
on conflict (slug) do update
  set name_tr    = excluded.name_tr,
      name_en    = excluded.name_en,
      category   = excluded.category,
      unit       = excluded.unit,
      source     = excluded.source,
      source_key = excluded.source_key,
      sort_order = excluded.sort_order;
