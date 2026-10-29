-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  articles — panelin yazma yetkisi                                        ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
--
-- SORUN. Panelden "Yayından Çek" denince haber yayında kalıyordu. Aynı
-- sınıftan: reddetme de, yazar sıralaması da aynı sebeple sessizce
-- düşüyordu.
--
-- SEBEP. `articles` üzerinde RLS açık ve depodaki migration'ların hiçbiri
-- UPDATE politikası tanımlamıyor. PostgREST politikasız UPDATE'te HATA
-- VERMİYOR — satırları süzüyor ve `200` + `[]` döndürüyor.
--
-- Ölçüm (29 Ekim 2026):
--   anon PATCH articles {status}  → 200, []   (sıfır satır)
--
-- Yazmayı bugüne kadar yalnızca hat (service_role) yapıyordu ve o RLS'i
-- zaten atlıyor; panelin yazdığı sanılan her şey aslında yazılmıyordu.
--
-- ÇÖZÜM. `video_haberleri` ve `columnists`'teki kalıbın aynısı: okuma
-- herkese (mevcut politikalara DOKUNULMUYOR), yazma giriş yapmış
-- kullanıcıya. Panel `signInWithPassword` ile korunuyor.
--
-- DELETE VERİLMİYOR. Red artık silmiyor, durum değiştiriyor (§29.1) ve
-- silme yolu açık kalırsa yanlış basılan bir düğme geri getirilemeyecek bir
-- kaydı yok eder. Hattın temizlik işleri service_role ile yürüyor.

alter table public.articles enable row level security;

-- Panel taslağı, reddedileni ve zamanlanmışı da görmek zorunda; anon'un
-- mevcut (yalnızca yayındakileri veren) politikasına dokunulmuyor.
drop policy if exists "authenticated tum haberleri okur" on public.articles;
create policy "authenticated tum haberleri okur"
  on public.articles for select
  to authenticated using (true);

-- Yayınla / yayından çek / reddet / sabitle / alan düzenle.
drop policy if exists "authenticated haber duzenler" on public.articles;
create policy "authenticated haber duzenler"
  on public.articles for update
  to authenticated using (true) with check (true);

-- Panelden elle haber girişi.
drop policy if exists "authenticated haber ekler" on public.articles;
create policy "authenticated haber ekler"
  on public.articles for insert
  to authenticated with check (true);

-- ─── Sağlama ───────────────────────────────────────────────────────────────
do $$
declare
  n_update int;
  n_anon_select int;
begin
  select count(*) into n_update from pg_policies
   where schemaname = 'public' and tablename = 'articles' and cmd = 'UPDATE';
  if n_update < 1 then
    raise exception 'articles UPDATE politikasi yazilamadi';
  end if;

  -- Anon'un okuma politikası DURMALI: kaybolursa site tamamen boşalır.
  --
  -- Rol adı 'anon' DİYE ARANMAZ: mevcut politika `public` rolüne tanımlı ve
  -- anon onun içinde. İlk sürüm yalnızca 'anon' arıyordu ve migration kendi
  -- sağlamasında düştü — atomik olduğu için hiçbir şey uygulanmadı.
  select count(*) into n_anon_select from pg_policies
   where schemaname = 'public' and tablename = 'articles' and cmd = 'SELECT'
     and (roles && array['anon','public']::name[]);
  if n_anon_select < 1 then
    raise exception 'anon/public SELECT politikasi yok — site haberleri okuyamaz';
  end if;
end $$;
