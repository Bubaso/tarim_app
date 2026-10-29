-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  Red hafızası — DURUM değişikliğinde de çalışsın                         ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
--
-- 20260816130000 reddi SİLME üzerinden kuruyordu: `articles_remember_rejection`
-- AFTER DELETE tetikleyicisi, silinen haberin adresini `rejected_sources`'a
-- yazıyor ve hat o haberi bir daha getirmiyor.
--
-- Sonra red SİLMEKTEN çıkarıldı (§29.1): yanlış basılan bir düğme geri
-- getirilemeyecek bir kaydı yok ediyordu. Red artık `status = 'rejected'`.
-- Veritabanında bunun izi var — 292 haber bu durumda — ama o geçişi yapan
-- migration 4 Ekim tahliyesinde gitti (§40.2).
--
-- SONUÇ: silme tetikleyicisi artık hiç çalışmıyor, çünkü kimse silmiyor.
-- Durum değişikliğiyle reddedilen haberin adresi hafızaya YAZILMIYOR ve hat
-- aynı haberi ertesi gün yeniden getirebiliyor.
--
-- Bu dosya eksik iki tetikleyiciyi kuruyor. İkisi de `drop if exists` ile
-- başlıyor: zaten varsa sorunsuz yeniden kuruluyor.

-- ─── Reddedilince hatırla ──────────────────────────────────────────────────
create or replace function public.remember_rejected_status()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.source_url is not null and new.source_url <> '' then
    insert into public.rejected_sources (source_url, title, source_name, last_status)
    values (new.source_url, new.title, new.source_name, old.status)
    on conflict (source_url) do nothing;
  end if;
  return new;
end;
$$;

drop trigger if exists articles_remember_rejection_status on public.articles;
create trigger articles_remember_rejection_status
  after update of status on public.articles
  for each row
  when (new.status = 'rejected' and old.status is distinct from 'rejected')
  execute function public.remember_rejected_status();

-- ─── Red geri alınınca unut ────────────────────────────────────────────────
-- Yoksa "geri al" yarım kalır: haber kuyruğa döner ama adresi hafızada kalır
-- ve hat onu bir daha hiç getirmez (§29.1).
create or replace function public.forget_rejected_status()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if old.source_url is not null and old.source_url <> '' then
    delete from public.rejected_sources where source_url = old.source_url;
  end if;
  return new;
end;
$$;

drop trigger if exists articles_forget_rejection_status on public.articles;
create trigger articles_forget_rejection_status
  after update of status on public.articles
  for each row
  when (old.status = 'rejected' and new.status is distinct from 'rejected')
  execute function public.forget_rejected_status();

-- ─── Sağlama ───────────────────────────────────────────────────────────────
do $$
declare n int;
begin
  select count(*) into n from pg_trigger
   where tgrelid = 'public.articles'::regclass
     and tgname in ('articles_remember_rejection_status',
                    'articles_forget_rejection_status');
  if n <> 2 then
    raise exception 'red durumu tetikleyicileri kurulamadi (bulunan: %)', n;
  end if;
end $$;
