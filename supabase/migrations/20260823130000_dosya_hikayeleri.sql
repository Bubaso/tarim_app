-- Dosya hikâyeleri — habere bağlı olmayan hikâye satırları.
--
-- Hikâye sistemi baştan "her hikâye bir haberden çıkar" varsayımıyla yazıldı:
-- `article_id` zorunlu, görsel `articles` tablosundan join ile geliyor ve
-- görüntüleyicideki düğme haberin adresine gidiyor.
--
-- Ülke ve Kurum Dosyası hikâyeleri bu üçünü de kırıyor. Bunlar bir haberden
-- türetilmiyor; okuru dosyanın kendisine çağıran tanıtım kartları.

-- Habersiz hikâye mümkün olsun.
alter table public.portal_stories alter column article_id drop not null;

-- Hikâyenin gideceği yer. null ise eski davranış: haberin adresine gider.
--
-- Neden serbest yol, neden `dossier_slug` değil: yarın bir emtia sayfası veya
-- bir hafta dosyası için de hikâye üretilebilir. Hedefi anlamlandırmak
-- istemcinin işi değil; satır nereye gideceğini kendisi söylüyor.
alter table public.portal_stories
  add column if not exists hedef_yol text;

-- Habersiz hikâyenin görseli. Haberli hikâyelerde null kalır ve görsel eskisi
-- gibi `articles` join'inden gelir.
--
-- Dosya hikâyelerinde bu alan dosyanın paylaşım kartını gösteriyor
-- (`/paylasim/<slug>.jpg`, 1200×630) — kart zaten dosyanın künyesini taşıyor
-- ve dosya yayımlanırken üretiliyor, ikinci bir görsel işi çıkmıyor.
alter table public.portal_stories
  add column if not exists gorsel_url text;

comment on column public.portal_stories.hedef_yol is
  'Hikâyeye tıklanınca gidilecek uygulama içi adres: /ulke/hollanda, /kurum/tmo. '
  'null ise haberin adresine gidilir.';
comment on column public.portal_stories.gorsel_url is
  'Habersiz hikâyenin görseli. null ise articles.image_url kullanılır.';

-- Habersiz satırın da hedefi olmalı; yoksa tıklanınca hiçbir yere gitmeyen
-- bir kart doğar.
do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'portal_stories_hedef_check'
  ) then
    alter table public.portal_stories
      add constraint portal_stories_hedef_check
      check (article_id is not null or (hedef_yol is not null and gorsel_url is not null));
  end if;
end $$;
