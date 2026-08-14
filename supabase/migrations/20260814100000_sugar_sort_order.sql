-- Kristal şekeri şeridin 3. sırasına alıyor.
--
-- Seed sıralaması hububatı işlem hacmine göre dizip şekeri (80) sona koymuştu.
-- Okuyucu için doğru sıra bu değil: şeker kendi başına bir gündem kalemi ve
-- fiyatı hububat gibi her gün değil, yılda birkaç kez değişiyor — yani şeridin
-- sonunda kaydırmadan görünmediği için kaçırılıyordu.
--
-- 25 seçildi: arpa (20) ile mısır (30) arasına giriyor. Mısır şu an işlem
-- görmediği için kartta yok; geri geldiğinde de şeker 3. sırada kalacak.
-- Aradaki boşluğu kullanmak diğer ürünlerin numaralarını yeniden yazmaktan
-- iyi — seed dosyası olduğu gibi kalıyor.

update public.commodities
set sort_order = 25
where slug = 'kristal-seker';
