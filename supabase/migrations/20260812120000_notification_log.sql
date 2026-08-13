-- Gönderilen bildirimlerin defteri.
--
-- Dört zamanlanmış gönderici birbirinden habersiz çalışıyordu. Bunun üç
-- somut sonucu vardı:
--   1. Gece son dakika olarak duyurulan haber, sabah özetinde tekrar gidiyordu.
--   2. Bir göndericiyi seyrekleştirmenin yolu yoktu; "en son ne zaman
--      gönderdim" sorusunun cevabı hiçbir yerde durmuyordu.
--   3. Metin değişikliğinin işe yarayıp yaramadığı ölçülemiyordu — ne
--      gönderildiği bile kayıtlı değildi.
--
-- Bu defter üçünü de çözer. Tıklama ölçümü sonraki adımda buraya eklenecek.

create table if not exists public.notification_log (
  id            bigserial primary key,
  -- 'breaking' | 'morning' | 'weekly' | 'author'
  kind          text        not null,
  -- Haftalık özet ileride bir sayfaya işaret edeceği için null olabilir.
  article_id    uuid,
  path          text        not null,
  title         text,
  sent_at       timestamptz not null default now(),
  success_count integer     not null default 0,
  failure_count integer     not null default 0
);

-- "Bu haber son 24 saatte gönderildi mi?" ve "bu tür en son ne zaman gitti?"
-- sorgularının ikisi de bu iki indeksle nokta atışı çalışır.
create index if not exists notification_log_article_idx
  on public.notification_log (article_id, sent_at desc);
create index if not exists notification_log_kind_idx
  on public.notification_log (kind, sent_at desc);

-- ─── RLS ──────────────────────────────────────────────────────────────────
-- Okuma açık: Cloud Function'lar tekrar kontrolünü anon anahtarıyla yapıyor ve
-- defterde kişisel veri yok (haber kimliği, tür, zaman, sayaç).
--
-- Yazma açık DEĞİL. Anon'a doğrudan INSERT verilseydi üçüncü bir kişi sahte
-- kayıt atıp bir haberin bildirimini bastırabilirdi. Yazma yalnızca aşağıdaki
-- SECURITY DEFINER fonksiyonu üzerinden yapılır.
alter table public.notification_log enable row level security;

drop policy if exists "anon can read notification log" on public.notification_log;
create policy "anon can read notification log"
  on public.notification_log for select
  to anon, authenticated
  using (true);

grant select on public.notification_log to anon, authenticated;

-- ─── Kayıt ────────────────────────────────────────────────────────────────
create or replace function public.log_notification(
  p_kind    text,
  p_path    text,
  p_title   text default null,
  p_article uuid default null,
  p_success integer default 0,
  p_failure integer default 0
)
returns bigint
language sql
security definer
set search_path = public
as $$
  insert into public.notification_log
    (kind, article_id, path, title, success_count, failure_count)
  values
    (p_kind, p_article, p_path, left(p_title, 300), p_success, p_failure)
  returning id;
$$;

revoke all on function public.log_notification(text, text, text, uuid, integer, integer) from public;
grant execute on function public.log_notification(text, text, text, uuid, integer, integer)
  to anon, authenticated;

-- ─── Ölü token temizliği ──────────────────────────────────────────────────
-- FCM, kaydı iptal edilmiş token için gönderim başına hata döndürüyor. Bu
-- kayıtlar silinmezse liste sonsuza kadar büyür, her gönderim daha yavaş ve
-- daha hatalı görünür.
--
-- `push_tokens` üzerinde anon'a zaten select/insert/update verilmişti; DELETE
-- bilerek verilmiyor. Silme yalnızca burada, verilen token listesiyle sınırlı
-- olarak yapılabilir — "tabloyu boşalt" gibi bir çağrı mümkün değil.
create or replace function public.prune_push_tokens(p_tokens text[])
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  removed integer;
begin
  if p_tokens is null or array_length(p_tokens, 1) is null then
    return 0;
  end if;

  delete from public.push_tokens
   where token = any (p_tokens);

  get diagnostics removed = row_count;
  return removed;
end;
$$;

revoke all on function public.prune_push_tokens(text[]) from public;
grant execute on function public.prune_push_tokens(text[]) to anon, authenticated;

notify pgrst, 'reload schema';
