-- Dağıtım defteri: hangi haber, hangi kanala, ne zaman gitti.
--
-- NEDEN VAR. 8 Kasım 2026 ölçümü: ayda 281 haber üretiliyor, push
-- kanalından ayda ~16 tıklanma geliyor. Dağıtım kanalları açılmaya
-- başlıyor (Telegram ilk) ve iki soru hemen ortaya çıkıyor:
--
--   1. "Bu haberi gönderdim mi?" — Cevabı hiçbir yerde durmazsa her
--      çalıştırma aynı haberleri yeniden gönderir. GitHub Actions
--      koşucusu her sabah sıfırdan ayağa kalkıyor; yerel bir durum
--      dosyası bu yüzden işe yaramıyor, defter veritabanında olmalı.
--   2. "Hangi kanal gerçekten tıklanma getiriyor?" — Gönderim sayısı
--      burada, tıklanma UTM ile Analytics'te; ikisi bu tabloyla
--      eşleşiyor.
--
-- `notification_log` ile karışmasın: o tablo PUSH gönderimlerinin
-- defteri ve `kind` alanı gönderici türünü tutuyor. Bu tablo dış
-- platformlara gönderimi tutuyor ve haber bazında tekilleştiriyor.

create table if not exists public.dagitim_log (
  id          bigserial   primary key,
  article_id  uuid        not null,
  -- 'telegram' | 'x' | 'bluesky' | 'facebook' | 'linkedin' | ...
  kanal       text        not null,
  sent_at     timestamptz not null default now(),
  -- Platformun verdiği kimlik: sonradan düzeltmek ya da silmek için.
  dis_id      text,
  hata        text
);

-- Tekilleştirmenin DAYANAĞI. Uygulama katmanında "önce sor, sonra yaz"
-- yapmak iki eşzamanlı çalıştırmada aynı haberi iki kez gönderir;
-- kısıt veritabanında olmalı.
create unique index if not exists dagitim_log_tekil
  on public.dagitim_log (article_id, kanal);

create index if not exists dagitim_log_kanal_idx
  on public.dagitim_log (kanal, sent_at desc);

-- ─── RLS ──────────────────────────────────────────────────────────────
-- Yalnızca sunucu yazıyor (hat, service_role ile). Tarayıcıya ne okuma
-- ne yazma veriliyor: defterin içeriği okura bir şey anlatmıyor ama
-- hangi haberin nereye gittiğini dışarıya açmanın da gereği yok.
alter table public.dagitim_log enable row level security;

revoke all on public.dagitim_log from anon, authenticated;
