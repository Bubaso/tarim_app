-- Yayın tarihi sütunu + red hafızası
--
-- Aynı koşuda ortaya çıkan iki ayrı kusurun karşılığı.
--
-- 1) Haberin gerçek yayın tarihi hiçbir yerde tutulmuyordu. Yaş süzgeci
--    yalnızca RSS beslemesinin beyanına bakıyordu; Google Haberler ise yayın
--    tarihini değil KENDİ dizinleme tarihini bildiriyor. Ölçtük: yenisafak'ın
--    2025-05-27 tarihli haberi beslemede "1 gün" görünüyordu, 447 günlük
--    haber taze diye içeri girdi. Tarihi bundan sonra kaynak sayfadan
--    çıkarıp burada saklıyoruz — hem süzgeç buna baksın hem de bir haberin
--    neden geçtiği sonradan denetlenebilsin.
--
-- 2) Paneldeki "Reddet" düğmesi satırı tamamen siliyor (rejectArticle ->
--    delete). Silinen haberin adresi hiçbir yerde kalmadığı için bir sonraki
--    çekimde yeniden geliyor, yeniden Gemini harcıyor ve yeniden editörün
--    karşısına çıkıyordu. Artık siliniş anında adres hatırlanıyor.

alter table public.articles
  add column if not exists published_at date;

comment on column public.articles.published_at is
  'Kaynak sayfadan çıkarılan gerçek yayın tarihi. Besleme beyanı değildir.';

create table if not exists public.rejected_sources (
  id          uuid primary key default gen_random_uuid(),
  source_url  text not null unique,
  title       text,
  source_name text,
  -- Silinme anındaki durum. reviewing = editör reddi, published = yayından
  -- kaldırma, draft = temizlik. Üçü de "bir daha getirme" anlamına geliyor,
  -- ama hangisi olduğunu bilmek sonradan sorun ayıklarken işe yarıyor.
  last_status text,
  rejected_at timestamptz not null default now()
);

-- Silme hangi yoldan gelirse gelsin (panel, bakım betiği, elle SQL) kayda
-- geçsin diye uygulama katmanında değil tetikleyicide duruyor. Flutter'daki
-- rejectArticle'ı değiştirmek yalnızca paneli kapsardı.
create or replace function public.remember_rejected_source()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if old.source_url is not null and old.source_url <> '' then
    insert into public.rejected_sources (source_url, title, source_name, last_status)
    values (old.source_url, old.title, old.source_name, old.status)
    on conflict (source_url) do nothing;
  end if;
  return old;
end;
$$;

drop trigger if exists articles_remember_rejection on public.articles;
create trigger articles_remember_rejection
  after delete on public.articles
  for each row execute function public.remember_rejected_source();

-- Tabloya istemci hiç dokunmuyor; yalnızca hat (service_role) okuyup yazıyor,
-- o da RLS'i zaten atlıyor. Politika tanımlamıyoruz: RLS açık ve politika yok
-- demek anon/authenticated için tam kapalı demek.
alter table public.rejected_sources enable row level security;
