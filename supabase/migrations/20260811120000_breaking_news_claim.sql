-- Son dakika bildirimini haberin YAŞINDAN kopar.
--
-- Eski davranış: `breakingNewsCheck` yalnızca `created_at >= now() - 30 dakika`
-- olan haberlere bakıyordu. Yayında duran eski bir haberi sonradan "son dakika"
-- işaretlemek hiçbir zaman bildirim üretmiyordu — çünkü haberin oluşturulma
-- zamanı çoktan geçmişti.
--
-- Yeni davranış: haber ne zaman oluşturulmuş olursa olsun, `is_breaking`
-- işaretlendiği anda bildirime aday olur. Aynı haberin her 30 dakikada bir
-- tekrar tekrar gönderilmemesi için kalıcı bir damga tutuluyor.

alter table public.articles
  add column if not exists breaking_notified_at timestamptz;

-- ─── Adayı atomik olarak "sahiplen" ────────────────────────────────────────
-- Seçmek ve damgalamak tek ifadede yapılır. İki fonksiyon örneği aynı anda
-- çalışsa bile UPDATE yalnızca birinde satır döndürür; bildirim iki kez
-- gitmez.
--
-- SECURITY DEFINER: fonksiyon sahibinin yetkisiyle çalışır, böylece `anon`
-- rolüne `articles` üzerinde UPDATE yetkisi vermek gerekmez. Anon'un
-- yapabileceği tek şey bu fonksiyonu çağırmaktır.
--
-- Bilinen ödünleşme: anon anahtarı herkese açık olduğu için üçüncü bir kişi bu
-- RPC'yi çağırıp bekleyen bildirimi "tüketebilir" ve o haber için bildirim
-- gönderilmemiş olur. Etki tek bir kaçırılmış bildirimle sınırlı; veri
-- okunmuyor, değiştirilmiyor. `push_tokens` için verilen kararla aynı
-- çizgide bilinçli olarak kabul edildi.
create or replace function public.claim_breaking_article()
returns table (id uuid, title text)
language sql
security definer
set search_path = public
as $$
  with picked as (
    select a.id
      from public.articles a
     where a.status = 'published'
       and a.is_breaking is true
       and a.breaking_notified_at is null
     order by a.created_at desc
     limit 1
  )
  update public.articles a
     set breaking_notified_at = now()
    from picked p
   where a.id = p.id
  returning a.id, a.title;
$$;

revoke all on function public.claim_breaking_article() from public;
grant execute on function public.claim_breaking_article() to anon, authenticated;

-- ─── Yeniden işaretleme damgayı sıfırlasın ─────────────────────────────────
-- Bir haber "son dakika"dan çıkarılıp yeniden işaretlenirse yeni bir olay
-- sayılır ve tekrar bildirilir. Test ederken de yol budur: `is_breaking`
-- kapat, aç, fonksiyonu tetikle.
--
-- Koşul `old.is_breaking is distinct from true` olduğu için fonksiyonun kendi
-- damgalama UPDATE'i (is_breaking zaten true) damgayı sıfırlamaz; aksi hâlde
-- sonsuz döngü olurdu.
create or replace function public.reset_breaking_notified()
returns trigger
language plpgsql
as $$
begin
  if new.is_breaking is true and (old.is_breaking is distinct from true) then
    new.breaking_notified_at := null;
  end if;
  return new;
end;
$$;

drop trigger if exists articles_reset_breaking_notified on public.articles;
create trigger articles_reset_breaking_notified
  before update on public.articles
  for each row
  execute function public.reset_breaking_notified();

-- Şu an yayında olan son dakika haberi zaten bildirildi; migration'dan hemen
-- sonraki ilk çalıştırmada tekrar gönderilmesin.
update public.articles
   set breaking_notified_at = now()
 where is_breaking is true
   and breaking_notified_at is null;

notify pgrst, 'reload schema';
