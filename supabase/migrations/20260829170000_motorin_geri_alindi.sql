-- Motorin / "girdi maliyetleri" fikri geri alındı.
--
-- Tek kalemle bir kategori açmak erkendi ("girdi maliyetleri iptal, yeteri
-- kadar ürün yok" — kullanıcı, 29 Ağustos 2026). Motorin kaynağı
-- (ucuzyakitbul.com.tr aracılığıyla) ve `commodities.category = 'girdi'`
-- kavramı tamamen kaldırılıyor; kod tarafı da temizlendi (bkz.
-- tarim_ai_pipeline/src/commodities/sources/ — motorin.py silindi).
--
-- Geçmişi ayrı tutmaya değecek kadar veri yoktu (bir günlük), bu yüzden
-- diğer üründe olduğu gibi `is_active = false` değil, tam silme.

delete from public.commodity_prices
where commodity_id in (select id from public.commodities where slug = 'motorin');

delete from public.commodities where slug = 'motorin';

delete from public.commodity_sources where key = 'motorin';
