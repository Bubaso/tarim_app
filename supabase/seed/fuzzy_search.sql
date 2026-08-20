-- 1. pg_trgm (Trigram) Eklentisini aktif edelim
-- Bu eklenti yazım hatalarını tolere eden (fuzzy) benzerlik araması yapmamızı sağlar.
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- 2. Sorguların hızlı çalışması için gerekli indeksleri oluşturalım
-- 'gin' indeksleri trigram operatörleriyle uyumlu çalışarak devasa verilerde bile milisaniyelik sonuç verir.
CREATE INDEX IF NOT EXISTS articles_title_trgm_idx ON public.articles USING gin (title gin_trgm_ops);
CREATE INDEX IF NOT EXISTS articles_content_trgm_idx ON public.articles USING gin (content gin_trgm_ops);

-- 3. Gelişmiş Arama Fonksiyonunu (RPC) Oluşturalım
CREATE OR REPLACE FUNCTION search_articles_fuzzy(search_term text, max_limit int DEFAULT 20)
RETURNS SETOF public.articles AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.articles
  WHERE status = 'published'
    AND (
      -- a. Birebir veya parçalı eşleşme (Klasik yaklaşım)
      title ILIKE '%' || search_term || '%' OR
      content ILIKE '%' || search_term || '%' OR
      
      -- b. Typo-tolerance: Kelimenin veya cümlenin büyük ölçüde benzemesi
      -- Örneğin "budğay" -> "buğday" gibi (%15 benzerlik eşiği)
      similarity(title, search_term) > 0.15 OR
      
      -- c. Cümle içinde kelime olarak benzerlik
      word_similarity(search_term, title) > 0.3 OR
      word_similarity(search_term, content) > 0.3
    )
  ORDER BY 
    -- Sonuçları rastgele değil, en çok benzeyene göre puanlayarak sırala
    GREATEST(
      similarity(title, search_term),
      word_similarity(search_term, title)
    ) DESC,
    created_at DESC
  LIMIT max_limit;
END;
$$ LANGUAGE plpgsql;
