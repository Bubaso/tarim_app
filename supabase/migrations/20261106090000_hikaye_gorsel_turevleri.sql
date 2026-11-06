-- Hikâye görsellerinin iki yeni türevi
--
-- NEDEN. Denetim (6 Kasım 2026) iki şeyi ölçtü:
--
--   1. Ana sayfadaki hikâye şeridi, kenarı 152 piksel olan dokuz baloncuğu
--      çizmek için 17 adet 1200×630 basın fotoğrafı indiriyordu — ~1,6 MB,
--      ekranın en üstünde. Hiçbir görsel gösterileceği kutuya göre
--      ölçeklenmiyordu çünkü Supabase'in görsel dönüştürme uç noktası bu
--      abonelikte kapalı (403 FeatureNotEnabled).
--
--   2. Görsel gelene kadar bulanık bir önizleme gösteren mekanizma yazılmış
--      ama aynı kapalı özelliğe bağlı olduğu için hiç devreye girmiyordu.
--      Slaytın ilk 0,7–3,4 saniyesi düz koyu bir dikdörtgendi.
--
-- ÇÖZÜM dönüştürmeyi satın almak değil, türevi YAZMA ANINDA üretmek. Hat
-- zaten 1200×630 ve 1080×2340 üretiyor; bu iki sütun üçüncü ve dördüncüyü
-- ekliyor.

-- 320×320 kare türev — şerit baloncuğu ve görüntüleyici başlık avatarı.
-- 320: 152 logical piksel × 2 cihaz pikseli, pay bırakılmış. ~15 KB.
alter table public.articles
  add column if not exists thumb_image_url text;

-- 24 piksellik kopyanın base64 data URI'si (~400 bayt).
--
-- Neden sütunda, neden ayrı dosya değil: tek işi görselin RENGİNİ ilk karede
-- ekrana koymak. Ayrı bir dosya olsaydı yine bir ağ isteği beklenecekti,
-- yani çözmeye çalıştığı sorunu yeniden üretecekti. Satırla birlikte gelen
-- bir dize hiçbir şey beklemiyor.
alter table public.articles
  add column if not exists image_lqip text;

comment on column public.articles.thumb_image_url is
  '320×320 kare türev; hikâye baloncuğu ve avatar. image_storage.normalize_for_thumb üretir.';
comment on column public.articles.image_lqip is
  '24 px bulanık önizlemenin base64 data URI''si. Ağ isteği gerektirmez, ilk karede çizilir.';
