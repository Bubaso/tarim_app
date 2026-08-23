-- Bölüm görseli.
--
-- Dosya on üç bölüm boyunca yalnızca grafik gösteriyordu; tek bir görsel yoktu.
-- Grafik veriyi anlatır, görsel konuyu gösterir — ikisi birbirinin yerine
-- geçmiyor. "Kendi toprağını yapan ülke" bölümünde polderin uydudan hâli,
-- metnin anlattığı şeyin kendisi.
--
-- NEDEN jsonb, NEDEN text DEĞİL. Görselin adresi tek başına kullanılamaz:
-- atıf zorunlu (telifi belirsiz görsel bu dizide kullanılmıyor) ve alt metni
-- iki dilli olmalı. Üç ayrı sütun açmak yerine tek bir nesne; şekli şöyle:
--
--   {
--     "url":     "/dosya/hollanda/zuiderzee.jpg",
--     "atif":    "NASA image by Alan Holmes/ NASA's Ocean Color Web…",
--     "kaynak":  "https://science.nasa.gov/…",
--     "alt_tr":  "…", "alt_en": "…"
--   }
--
-- null ise bölümde görsel yok ve hiçbir şey eksilmez — kapakta olduğu gibi
-- görsel bir katman, taşıyıcı değil.
alter table public.dossier_sections
  add column if not exists gorsel jsonb;

comment on column public.dossier_sections.gorsel is
  'Bölüm görseli: {url, atif, kaynak, alt_tr, alt_en}. Atıfsız görsel yayımlanmaz.';
