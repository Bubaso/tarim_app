-- ═══════════════════════════════════════════════════════════════════════════
--  Sesli haber özelliği kaldırıldı — 15 Kasım 2026
-- ═══════════════════════════════════════════════════════════════════════════
--
-- Kullanıcı kararı: "sesle ilgili her şeyi silebilirsin, kullanmıyorum."
--
-- Özellik zaten ölüydü, ölçüldü:
--   · Uygulamada tek bir yerde bile okunmuyordu. `NewsArticle` modelinde
--     karşılığı olan alan yok; sütunlar yalnızca depo katmanındaki
--     `select` dizesinde adı geçiyordu, hiçbir ekran kullanmıyordu.
--   · `pubspec.yaml`'da ses çalan bir paket yok.
--   · `article-audios` kovası BOŞ — yalnız iki `.emptyFolderPlaceholder`
--     dosyası var. 38 satırdaki `audio_url` ölü adres gösteriyordu.
--   · Üreten `columnistAudio` fonksiyonu beş dakikada bir, 1 GB bellekle
--     koşuyor ve hiçbir şey üretmiyordu (günlükte "This operation was
--     aborted"). 15 Kasım'da silindi.
--
-- Altı sütun da kaldırılıyor. Veri kaybı yok: işaret ettikleri dosyalar
-- zaten yok.

alter table public.articles
  drop column if exists audio_url,
  drop column if exists audio_url_en,
  drop column if exists is_radio,
  drop column if exists radio_order,
  drop column if exists ses_deneme,
  drop column if exists ses_hatasi;

-- `publish_at` de burada gidiyor: 1.412 satırın hiçbirinde dolu değil,
-- uygulamada okunmuyor ve adı `published_at` ile karışıyor. Zamanlanmış
-- yayın artık `scheduled_at` sütununda (bkz. 20261115120000).
alter table public.articles
  drop column if exists publish_at;
