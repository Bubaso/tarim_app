-- Hikaye ekranı için dikey görsel türevi.
--
-- Neden ayrı bir sütun
-- --------------------
-- `image_url` paylaşım kartının ölçüsünü taşıyor: 1200×630, yatay. Bu ölçü
-- WhatsApp ve Facebook önizlemesi için gerekli ve pazarlığa açık değil.
--
-- Hikaye ekranı ise tam ekran ve dikey. Aynı dosyayı ikisine birden servis
-- ettiğimizde hikaye tarafı şunu yapmak zorunda kalıyordu: 1200×630'un orta
-- şeridini alıp ekrana yaymak. Ölçtük — iPhone 12'de (1170×2532) 960×540 bir
-- kaynağın 134 bin pikseli 2,96 milyon ekran pikseline dağılıyor, 22 kat
-- seyrelme. Kullanıcının "berbat" dediği görüntü bu.
--
-- İki ölçü tek sütuna sığmıyor çünkü ikisi de zorunlu ve birbirinden farklı.
-- Bu yüzden hat, aynı kaynaktan ikinci bir türev üretip buraya yazıyor.
--
-- Neden okuma anında dönüştürmüyoruz
-- ----------------------------------
-- Supabase'in `render/image/...` uçnoktası ASLA büyütme yapmıyor: depodaki
-- dosya 1200×630 iken `width=1920` istemek yine 1200×630 döndürüyor. Üstelik
-- yükseklik verilmeden istenen genişlik oranı korumuyor, ortadan KIRPIYOR
-- (piksel farkı ölçüldü: kırpma 0,94, sıkıştırma 43,93). Yani okuma anında
-- dönüştürme bu sorunu çözemezdi, sessizce büyütürdü.

alter table public.articles
  -- 1080×2340 (9:19,5) dikey JPEG. Kaynağın merkezinden kırpılıp tek adımda
  -- Lanczos ile ölçekleniyor, ardından maskeli keskinleştirme uygulanıyor.
  --
  -- null : hat bu görsel için türev üretemedi (bozuk dosya, PIL'in tanımadığı
  --        biçim) ya da haber bu göçten önce işlendi. Uygulama o durumda
  --        `image_url`'e düşüyor — eski davranış, yani gerileme değil.
  add column if not exists story_image_url text;

comment on column public.articles.story_image_url is
  'Hikaye ekranı için 1080x2340 dikey türev. null ise uygulama image_url''e düşer.';
