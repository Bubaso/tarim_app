-- Haber grafiğinin/tablosunun İngilizcesi.
--
-- Uygulama başından beri iki dilli ama çeviri yalnızca DÜZ METNİ kapsıyordu:
-- başlık, spot, gövde, anahtar çıkarımlar. Haberin içindeki grafik ve tablo
-- `chart_data` alanında yapılandırılmış veri olarak duruyor ve İngilizce
-- sayfada olduğu gibi, Türkçe görünüyordu:
--
--     DEĞER            DÖNEM              ÖLÇÜM
--     564.188.810 dolar  1 Ocak-31 Temmuz 2026  Yaş meyve ve sebze ihracat geliri
--
-- Sütun adları da hücreler de çevrilmiyordu. 200 haberin 96'sı tablo taşıyor;
-- yani İngilizce okuyan okur haberlerin yarısında Türkçe bir veri bloğuyla
-- karşılaşıyordu.
--
-- Neden ayrı sütun: çeviri doğrulamadan geçiyor (her hücrenin rakam dizisi
-- Türkçesiyle karşılaştırılıyor) ve geçmezse İngilizce sürüm ÜRETİLMİYOR.
-- Boş kalan sütun, uygulamanın Türkçesine düşmesi demek — yanlış çevrilmiş bir
-- sayı göstermekten iyi.

alter table public.articles
  add column if not exists chart_data_en jsonb;

comment on column public.articles.chart_data_en is
  'chart_data alanının İngilizcesi. null ise uygulama Türkçesini gösteriyor: '
  'çeviri ya hiç yapılmadı ya da rakam doğrulamasından geçemedi.';

notify pgrst, 'reload schema';
