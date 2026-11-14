-- ═══════════════════════════════════════════════════════════════════════════
--  Panel altyapısı — 15 Kasım 2026
--  Denetim raporunun 5, 15, 20 ve 21 numaralı maddeleri.
-- ═══════════════════════════════════════════════════════════════════════════

-- ── 1. İŞ KUYRUĞU (madde 15) ───────────────────────────────────────────────
-- Panel "Haber çek" düğmesi buraya bir satır yazıyor; Mac'teki `listener.py`
-- satırı görüp hattı çalıştırıyor. Tablo zaten vardı ama yalnız üç sütunu
-- (id, status, created_at); koşunun sonucunu ve hatasını taşıyacak yeri yoktu.
alter table public.agent_jobs
  add column if not exists job_type    text        not null default 'haber_cek',
  add column if not exists started_at  timestamptz,
  add column if not exists finished_at timestamptz,
  add column if not exists sonuc       jsonb,
  add column if not exists hata        text,
  add column if not exists baslatan    uuid references auth.users(id);

-- Bekleyen işi dinleyici sürekli sorguluyor.
create index if not exists agent_jobs_bekleyen_idx
  on public.agent_jobs (created_at)
  where status = 'pending';

-- ── 2. DİNLEYİCİ DURUMU (madde 15) ─────────────────────────────────────────
-- Düğme yalnız dinleyici açıkken işe yarıyor. Panelin bunu BİLMESİ gerekiyor:
-- aksi hâlde kullanıcı düğmeye basıyor, hiçbir şey olmuyor ve sebebi
-- görünmüyor. Dinleyici 20 saniyede bir buraya damga basıyor.
create table if not exists public.dinleyici_durumu (
  id          smallint primary key default 1,
  son_goruldu timestamptz not null default now(),
  constraint dinleyici_tek_satir check (id = 1)
);
insert into public.dinleyici_durumu (id) values (1) on conflict (id) do nothing;

-- ── 3. ZAMANLANMIŞ YAYIN (madde 20) ────────────────────────────────────────
-- Haber `reviewing` olarak durur, `scheduled_at` dolu olur; zamanı gelince
-- Firebase'deki zamanlanmış fonksiyon `published` yapar.
--
-- `published_at` KULLANILMADI: o alan haberin KAYNAKTA yayımlandığı günü
-- tutuyor ve yaş süzgeci ona bakıyor. İkisini aynı sütuna koymak süzgeci
-- bozardı.
alter table public.articles
  add column if not exists scheduled_at timestamptz;

comment on column public.articles.scheduled_at is
  'Zamanlanmış yayın anı. Dolu ve status=reviewing ise fonksiyon vakti '
  'gelince yayına alır. Yayına alınınca null''lanır.';

-- Fonksiyon beş dakikada bir yalnız vakti gelenleri arıyor; kısmi dizin
-- tam bu sorgu için.
create index if not exists articles_zamanlanmis_idx
  on public.articles (scheduled_at)
  where scheduled_at is not null and status = 'reviewing';

-- ── 4. KAYNAK KARNESİ KALDIRILDI (madde 5) ─────────────────────────────────
-- Görünüm red sayısını `articles` tablosundan okuyordu. 11 Kasım 2026'da red
-- politikası satırı SİLMEYE çevrildi; o günden sonra görünüm 206 kaynağın
-- hepsi için "0 red" döndürmeye başladı — gerçek red sayısı 1.400'ün
-- üzerindeyken. Ekranın tek işi bu sayıyı göstermekti.
drop view if exists public.source_scorecard;

-- ── 5. YAPAY ZEKÂ ÖNERİLERİ KALDIRILDI (madde 2-4) ─────────────────────────
-- Panel sekmesi 15 Kasım'da, üreten ajan aynı gün kaldırıldı. Tabloda 1.647
-- satır birikmişti ve hiçbiri okunmamıştı (hepsi 'pending'; panel 'reviewing'
-- sorguluyordu, yani sekme hiçbir zaman bir şey göstermedi).
drop table if exists public.ai_suggestions;

-- ── 6. HERKESE AÇIK OKUMA KAPATILDI (madde 21) ─────────────────────────────
-- Üç tablo anon anahtarla dışarıdan okunabiliyordu. İçerikleri bugün zararsız
-- ama hiçbiri okuyucuya ait değil: ikisi hattın iç günlüğü, biri iş kuyruğu.
alter table public.agent_jobs          enable row level security;
alter table public.live_terminal_logs  enable row level security;
alter table public.dinleyici_durumu    enable row level security;

drop policy if exists "Allow anon read access"        on public.agent_jobs;
drop policy if exists "Allow anon read access"        on public.live_terminal_logs;
drop policy if exists "anon can read jobs"            on public.agent_jobs;
drop policy if exists "anon can read logs"            on public.live_terminal_logs;

drop policy if exists "panel isleri okur"   on public.agent_jobs;
drop policy if exists "panel is yazar"      on public.agent_jobs;
drop policy if exists "panel gunlugu okur"  on public.live_terminal_logs;
drop policy if exists "panel dinleyiciyi okur" on public.dinleyici_durumu;

create policy "panel isleri okur" on public.agent_jobs
  for select to authenticated using (true);
create policy "panel is yazar" on public.agent_jobs
  for insert to authenticated with check (true);
create policy "panel gunlugu okur" on public.live_terminal_logs
  for select to authenticated using (true);
create policy "panel dinleyiciyi okur" on public.dinleyici_durumu
  for select to authenticated using (true);

-- Dinleyici ve hat servis anahtarıyla bağlanıyor; service_role RLS'i zaten
-- atlıyor, ayrıca politika gerekmiyor.

-- ── 7. GÜNLÜK TEMİZLİĞİ ────────────────────────────────────────────────────
-- Haziran'dan kalma 978 satır duruyor. Günlük canlı izleme için; eskisi
-- kimseye lazım değil ve tablo sınırsız büyüyor.
delete from public.live_terminal_logs where created_at < now() - interval '7 days';
