-- Tıklanan bildirimlerin defteri.
--
-- `notification_log` "ne gönderdik"i biliyor; bu tablo "ne işe yaradı"yı.
-- İkisi olmadan bildirim metni üzerine yapılan her değişiklik bir tahmin
-- olarak kalıyor: sabah özetinin başlığını manşete çevirmenin işe yarayıp
-- yaramadığını bugün ölçebileceğimiz hiçbir yer yok.
--
-- `kind` + `sent_at` / `clicked_at` ikilisiyle tür bazında dönüşüm oranı
-- çıkarılabiliyor. Gönderime BAĞLANMIYOR (log id'si taşınmıyor): defter kaydı
-- gönderimden SONRA yazıldığı için o kimlik payload hazırlanırken henüz yok
-- ve bunu değiştirmek çalışan gönderim sırasını bozmayı gerektirirdi.

create table if not exists public.notification_click (
  id         bigserial primary key,
  -- 'breaking' | 'morning' | 'weekly' | 'author'
  kind       text        not null,
  path       text,
  clicked_at timestamptz not null default now()
);

create index if not exists notification_click_kind_idx
  on public.notification_click (kind, clicked_at desc);

-- ─── RLS ──────────────────────────────────────────────────────────────────
-- Bu tabloyu `notification_log`'dan ayıran şey, yazanın SUNUCU değil TARAYICI
-- olması: tıklamayı yalnızca okuyucunun cihazı görüyor. Yani yazma yolu
-- güvenilmeyen bir taraftan geliyor ve sayaç şişirilebilir. Bir reklam ölçümü
-- değil, kendi metnimizi değerlendirdiğimiz bir gösterge olduğu için bu kabul
-- edilebilir; yine de zarar üç noktadan sınırlanıyor:
--   1. Yazma yalnızca aşağıdaki fonksiyondan yapılabiliyor (tabloya doğrudan
--      INSERT yok), yani şema serbestçe kullanılamıyor.
--   2. `kind` dört bilinen değerle sınırlı — tanımadığımız türler yazılamıyor.
--   3. `path` 300 karaktere kırpılıyor; tablo metin deposuna çevrilemiyor.
--
-- OKUMA anon'a KAPALI. `notification_log`'da okuma açıktı çünkü Cloud
-- Function'lar tekrar kontrolünü anon anahtarıyla yapıyor; burada öyle bir
-- ihtiyaç yok. Bu sayıları yalnızca giriş yapmış editör görüyor.
alter table public.notification_click enable row level security;

drop policy if exists "authenticated can read notification clicks"
  on public.notification_click;
create policy "authenticated can read notification clicks"
  on public.notification_click for select
  to authenticated
  using (true);

grant select on public.notification_click to authenticated;

-- ─── Kayıt ────────────────────────────────────────────────────────────────
create or replace function public.log_notification_click(
  p_kind text,
  p_path text default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  -- Bilinmeyen tür sessizce yok sayılıyor. Hata fırlatmak, uygulamanın
  -- yönlendirme akışının içinde bir istisna üretirdi: okuyucunun habere
  -- gitmesi bir ÖLÇÜM kaydının başarısına asla bağlı olmamalı.
  if p_kind is null
     or p_kind not in ('breaking', 'morning', 'weekly', 'author') then
    return;
  end if;

  insert into public.notification_click (kind, path)
  values (p_kind, left(p_path, 300));
end;
$$;

revoke all on function public.log_notification_click(text, text) from public;
grant execute on function public.log_notification_click(text, text)
  to anon, authenticated;

notify pgrst, 'reload schema';
