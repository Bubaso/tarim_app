-- push_tokens: cihaz kayıtlarının yazılabilmesi için RLS düzeltmesi.
--
-- SORUN: Tablo RLS açık ve INSERT için hiçbir permissive policy yoktu. Uygulama
-- bildirim izni alındıktan sonra token'ı yazmaya çalışıyor, Supabase 401 /
-- 42501 ("new row violates row-level security policy") dönüyor, hata Dart
-- tarafında `if (kDebugMode) print(...)` ile yutuluyordu. Sonuç: tablo boş
-- kaldı ve zamanlanmış Cloud Function'lar her çalışmada
-- "Kayıtlı cihaz bulunamadı." yazıp çıktı.
--
-- GÜVENLİK NOTU: Bu migration anon rolüne yazma ve okuma veriyor. anon anahtarı
-- derlenmiş web paketinde açıkta olduğu için pratikte tabloya isteyen herkes
-- satır ekleyebilir ve kayıtlı token'ları okuyabilir. Bu bilinçli bir tercihtir
-- (Cloud Function'lar token'ları aynı anon anahtarıyla okuyor). Daha sıkı
-- kurulum, tabloyu tamamen kapatıp kaydı SECURITY DEFINER bir RPC'ye almak ve
-- fonksiyonları service_role anahtarına geçirmektir.
--
-- Token'ın kendisi tek başına bildirim göndermeye yetmez; gönderim için FCM
-- sunucu kimlik bilgisi gerekir ve o gizli kalmaya devam eder.

-- ─── Tablo ────────────────────────────────────────────────────────────────
create table if not exists public.push_tokens (
  token      text primary key,
  platform   text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Tablo panelden elle oluşturulmuş olabilir; eksik sütunları tamamla.
alter table public.push_tokens add column if not exists platform   text;
alter table public.push_tokens add column if not exists created_at timestamptz not null default now();
alter table public.push_tokens add column if not exists updated_at timestamptz not null default now();

-- upsert'in çalışması için `token` üzerinde tekillik şart. PRIMARY KEY başka
-- bir sütundaysa (ör. id) burada ayrıca unique index kurulur.
create unique index if not exists push_tokens_token_key on public.push_tokens (token);

-- ─── RLS ──────────────────────────────────────────────────────────────────
alter table public.push_tokens enable row level security;

-- Policy'ler idempotent olsun diye önce düşürülüyor.
drop policy if exists "anon can register push token"    on public.push_tokens;
drop policy if exists "anon can refresh push token"     on public.push_tokens;
drop policy if exists "anon can read push tokens"       on public.push_tokens;

-- Yeni cihaz kaydı.
create policy "anon can register push token"
  on public.push_tokens for insert
  to anon, authenticated
  with check (
    token is not null
    and length(token) between 20 and 500
  );

-- Aynı token yeniden gönderildiğinde updated_at tazelensin (upsert'in UPDATE ayağı).
create policy "anon can refresh push token"
  on public.push_tokens for update
  to anon, authenticated
  using (true)
  with check (
    token is not null
    and length(token) between 20 and 500
  );

-- Cloud Function'lar (morningBriefing, weeklyBriefing, authorBulletin,
-- breakingNewsCheck) token listesini anon anahtarıyla okuyor.
create policy "anon can read push tokens"
  on public.push_tokens for select
  to anon, authenticated
  using (true);

-- PostgREST'in policy'leri görebilmesi için tablo düzeyi grant'lar da gerekli.
grant select, insert, update on public.push_tokens to anon, authenticated;

notify pgrst, 'reload schema';
