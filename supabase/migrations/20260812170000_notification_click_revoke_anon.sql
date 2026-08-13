-- notification_click: anon'un tablo düzeyindeki SELECT yetkisini geri al.
--
-- Bir önceki migration select yetkisini yalnızca `authenticated`'a VERMİŞTİ,
-- ama vermemek yetmiyor: Supabase yeni tablolar için `anon` rolüne varsayılan
-- yetkileri zaten tanımlıyor. Doğrulamada bu görüldü — anon isteği 403 değil,
-- 200 ve boş dizi döndü.
--
-- Satırların görünmemesinin tek sebebi RLS'te `anon` için bir politika
-- bulunmamasıydı. Yani "okuma kapalı" iddiası tek bir katmana yaslanıyordu.
-- Yetkinin kendisini geri almak bunu iki katmana çıkarıyor: ileride bu tabloya
-- yanlışlıkla geniş bir politika eklense bile anon'un okuma yetkisi olmayacak.
--
-- Veri sızıntısı YAŞANMADI; bu bir sıkılaştırma, bir düzeltme değil.
revoke select on public.notification_click from anon;

notify pgrst, 'reload schema';
