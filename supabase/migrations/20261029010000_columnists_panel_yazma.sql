-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  columnists — panelin yazma yetkisi                                      ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
--
-- SORUN. Panelden yazar sırası değiştiriliyordu, ekran "kaydedildi" diyordu,
-- ama hiçbir şey yazılmıyordu. Yazar listesine dönünce eski sıra geri
-- geliyordu.
--
-- SEBEP. `columnists` üzerinde RLS açık ve yalnızca okuma politikası var;
-- UPDATE için politika YOK. PostgREST bu durumda HATA VERMİYOR — satırları
-- süzüyor ve `HTTP 200` + `[]` dönüyor. Yani istemci tarafındaki try/catch
-- hiç tetiklenmiyor ve başarısız yazma BAŞARILI görünüyor. (Aynı sessiz
-- davranış CLAUDE.md §20.4'te de ölçülmüştü.)
--
-- Ölçüm (29 Ekim 2026):
--   anon PATCH columnists  → 200, []          (sıfır satır)
--   service_role aynı PATCH → 200, [{...}]    (yazdı)
--
-- `columnists` için depoda HİÇBİR migration yok: tablonun politikaları
-- 4 Ekim iCloud tahliyesinde giden 23 migration'dan birindeydi (§40.2).
--
-- ÇÖZÜM. `video_haberleri`deki kalıbın aynısı (bkz.
-- 20260825140000_video_haberleri.sql): yönetim tablosunda okuma herkese,
-- yazma giriş yapmış kullanıcıya. Panel zaten `signInWithPassword` ile
-- korunuyor.
--
-- SECURITY DEFINER rpc YAZILMADI: o kalıp (§30) anon anahtarıyla çalışan
-- BULUT FONKSİYONLARI için. Buradaki yazmayı insan yapıyor ve oturumu var;
-- politikayla çözmek daha az kod ve daha az gizli yetki demek.

alter table public.columnists enable row level security;

-- ─── Okuma ────────────────────────────────────────────────────────────────
-- Siteye yalnızca aktif yazarlar gidiyor; panel gizlileri de görmeli,
-- çünkü "yok" ile "gizli" farkı yöneticiye açık olmalı (§34).

drop policy if exists "anon aktif yazarlari okur" on public.columnists;
create policy "anon aktif yazarlari okur"
  on public.columnists for select
  to anon using (is_active = true);

drop policy if exists "authenticated tum yazarlari okur" on public.columnists;
create policy "authenticated tum yazarlari okur"
  on public.columnists for select
  to authenticated using (true);

-- ─── Yazma ────────────────────────────────────────────────────────────────
-- Sıra, unvan ve görünürlük panelden değişiyor.

drop policy if exists "authenticated yazar duzenler" on public.columnists;
create policy "authenticated yazar duzenler"
  on public.columnists for update
  to authenticated using (true) with check (true);

drop policy if exists "authenticated yazar ekler" on public.columnists;
create policy "authenticated yazar ekler"
  on public.columnists for insert
  to authenticated with check (true);

-- Silme BİLEREK verilmedi: yazarın kaydı silinince yazıları sayfasız kalır
-- (bağ `articles.source_name` üzerinden, §24.4). Kaldırmanın doğru yolu
-- `is_active = false` — yazılar yerinde kalıyor, yazar vitrinden çıkıyor.

-- ─── Sağlama ──────────────────────────────────────────────────────────────
do $$
declare
  n_select int;
  n_update int;
begin
  select count(*) into n_select from pg_policies
   where schemaname = 'public' and tablename = 'columnists' and cmd = 'SELECT';
  select count(*) into n_update from pg_policies
   where schemaname = 'public' and tablename = 'columnists' and cmd = 'UPDATE';

  if n_select < 2 then
    raise exception 'columnists SELECT politikasi eksik (bulunan: %)', n_select;
  end if;
  if n_update < 1 then
    raise exception 'columnists UPDATE politikasi yazilamadi';
  end if;
end $$;
