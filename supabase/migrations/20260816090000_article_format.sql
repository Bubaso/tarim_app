-- Haberin hangi biçimde yazıldığını kayda geçirir: kısa haber mi, tam haber mi.
--
-- Neden ayrı bir sütun
-- --------------------
-- Karar zaten editörde veriliyor (src/agents/editor.py → kisa_haber_mi).
-- Sorun, kararın uygulama tarafından yeniden ÜRETİLEMEZ olması:
--
--   * source_depth yetmiyor. Ölçümde üç kısa haberin ikisi 'full' idi —
--     kaynak sayfası alınmıştı ama sayfanın kendisi 100 kelimeydi. Yani
--     "brief" bir gerek şart değil, yeter şart.
--   * "key_takeaways boş + expert_insight boş + chart_data null" üçlüsünden
--     çıkarım yapmak da olmaz: bu, modelin bir alanı doldurmayı unuttuğu
--     haberi de kısa haber sayar. Biçim kararı ile modelin arızası aynı
--     sinyale düşer.
--
-- Karar bir kez veriliyor; kararı taşımanın doğru yolu yazmak. Uygulama da,
-- 'Kısa Kısa' sayfası da tek bir indeksli filtreyle sorabiliyor.

alter table public.articles
  -- 'kisa' : ara başlık, çıkarım listesi, analiz kutusu ve görsel öğe YOK.
  --          Gövde en fazla iki paragraf, ana eylem kaynağa gitmek.
  -- 'tam'  : tam donanımlı haber.
  -- null   : eski hat çıktısı (bu göçten önceki 507 haber). Uygulama bunları
  --          'tam' sayıyor — hepsi tam haber olarak üretilmişti.
  add column if not exists article_format text;

alter table public.articles
  drop constraint if exists articles_article_format_check;

alter table public.articles
  add constraint articles_article_format_check
  check (article_format is null or article_format in ('kisa', 'tam'));

-- 'Kısa Kısa' sayfası: yayındaki kısa haberleri tarihe göre çekiyor.
-- Kısmi indeks, çoğunluğu oluşturan 'tam' satırlarını indekse almıyor.
create index if not exists articles_kisa_published_idx
  on public.articles (created_at desc)
  where article_format = 'kisa' and status = 'published';

comment on column public.articles.article_format is
  'kisa = zenginleştirme öğeleri kapalı iki paragraflık haber; tam = tam haber. null = eski hat.';
