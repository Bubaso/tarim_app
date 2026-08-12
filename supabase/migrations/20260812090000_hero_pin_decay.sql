-- Editör sabitlemesini kalıcı kilitten "o ana ait" bir itkiye çevir.
--
-- Eski davranış: `is_hero` işaretli haberler manşetin ilk sıralarını koşulsuz
-- işgal ediyordu. İşaret elle konuyor, kaldırılması unutuluyordu; panelde 21
-- işaretli haber birikmişti ve en eskisi 40 günlüktü.
--
-- Yeni davranış: `is_hero` yalnızca skoru çarpan, zamanla eriyen bir itki.
-- Sıralamaya sistem karar veriyor; editör sadece o an öne çıkarmak istediğini
-- itiyor. İtki ~10 saatte yarıya iner, 36 saatte pratikte biter. Böylece
-- unutulan işaretler kendiliğinden zararsızlaşıyor, temizlik gerekmiyor.
--
-- Bunun için itkinin ne zaman verildiğini bilmek gerekiyor. `created_at`
-- yetmiyor: eski bir haberi bugün öne çıkarmak isteyen editörün müdahalesi
-- doğduğu anda ölürdü. `updated_at` de yetmiyor: haberin herhangi bir alanı
-- düzeltildiğinde de değişiyor, yani sabitlemeyi farkında olmadan tazeliyor.

alter table public.articles
  add column if not exists hero_pinned_at timestamptz;

-- Hâlihazırda işaretli haberler için damgayı `updated_at`ten geriye doldur.
-- Panel `is_hero` dışında bir şey yazmadığı için bu satırlarda `updated_at`
-- işaretlenme anının iyi bir yaklaşımı: veriye bakıldığında iki ayrı küme
-- görülüyor — ~8 saat önce düzenlenmiş güncel seçki ve 78-150 saat önce
-- kalmış eski seçki. Geriye doldurma güncel seçkinin itkisini korur, eskisini
-- doğrudan sönmüş hâlde bırakır.
update public.articles
   set hero_pinned_at = updated_at
 where is_hero is true
   and hero_pinned_at is null;
