-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  articles — görsel künyesi                                               ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
--
-- SORUN. Haber görselleri kaynak sayfadan alınıp kendi depomuza yükleniyor
-- ama ALTLARINDA KÜNYE YOK. Projenin kendi kuralı bunu zaten yasaklıyor —
-- §8.3: "Atıfsız görsel yayımlanmaz" — ve dosya dizisinde her görselin
-- altında atıf duruyor. Haber tarafında `image_credit` diye bir SÜTUN BİLE
-- YOKTU.
--
-- İki yönü var. Telif: başkasının fotoğrafını künyesiz yayımlamak savunulabilir
-- değil. Algı: fotoğraf altında kaynak olmaması, okurun bilinçsizce "bu görsel
-- buraya ait değil" diye okuduğu bir işarettir (2 Kasım 2026 denetimi).
--
-- İKİ AYRI ALAN, İKİ AYRI İŞ:
--   image_credit  — kimin fotoğrafı. "AA", "Tarım Pusulası", "sondakika.com".
--   image_caption — fotoğraf NE gösteriyor. Boş kalabilir; uydurulmaz.
--
-- Eski kayıtlarda ikisi de NULL kalıyor ve arayüz o zaman künye satırını HİÇ
-- çizmiyor. Boş bir "Fotoğraf:" satırı, hiç satır olmamasından kötü.

alter table public.articles
  add column if not exists image_credit  text,
  add column if not exists image_caption text;

comment on column public.articles.image_credit is
  'Görselin kaynağı (yayın organı ya da alan adı). §8.3: atıfsız görsel yayımlanmaz.';
comment on column public.articles.image_caption is
  'Görselin altyazısı — ne gösterdiği. Belgelenmemişse BOŞ bırakılır, uydurulmaz.';

-- ─── Sağlama ───────────────────────────────────────────────────────────────
do $$
declare n int;
begin
  select count(*) into n from information_schema.columns
   where table_schema = 'public' and table_name = 'articles'
     and column_name in ('image_credit', 'image_caption');
  if n <> 2 then
    raise exception 'görsel künyesi sütunları kurulamadi (bulunan: %)', n;
  end if;
end $$;
