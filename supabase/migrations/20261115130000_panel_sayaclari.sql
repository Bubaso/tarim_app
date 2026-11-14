-- ═══════════════════════════════════════════════════════════════════════════
--  Panel sayaçları — 15 Kasım 2026
--  Denetim raporunun 8, 17 ve 22 numaralı maddeleri.
-- ═══════════════════════════════════════════════════════════════════════════
--
-- NEDEN VERİTABANINDA HESAPLANIYOR
-- İstatistik sekmesi sayıları `latestArticlesProvider` listesinden topluyordu.
-- O akış 500 satırla sınırlı; arşivde 1.400'den fazla yayında haber var.
-- Sonuç: "toplam haber" ve "toplam görüntülenme" kutuları yanlış sayı
-- gösteriyordu ve yanlış olduklarını söylemiyorlardı. Ölçüldüğünde toplam
-- görüntülenmenin %81'i panele hiç girmiyordu.
--
-- Satırları uygulamaya çekip orada toplamak da çözüm değil: 1.400 satır için
-- iki sayfalık istek, her sekme açılışında. Toplam veritabanının işi.

create or replace function public.panel_sayaclari()
returns jsonb
language sql
stable
security invoker
as $$
  with
  y as (select * from public.articles where status = 'published'),
  k as (select * from public.articles where status = 'reviewing')
  select jsonb_build_object(
    -- ── Madde 8: gerçek toplamlar ──────────────────────────────────────
    'yayinda',            (select count(*) from y),
    'goruntulenme',       (select coalesce(sum(coalesce(view_count, 0)), 0) from y),
    'kuyrukta',           (select count(*) from k),

    -- ── Madde 22: günlük akış ──────────────────────────────────────────
    'bugun_gelen',        (select count(*) from public.articles
                             where created_at >= date_trunc('day', now())),
    'bugun_yayinlanan',   (select count(*) from y
                             where created_at >= date_trunc('day', now())),
    'hafta_yayinlanan',   (select count(*) from y
                             where created_at >= now() - interval '7 days'),
    'gun_ortalamasi',     (select round(count(*)::numeric / 14, 1) from public.articles
                             where created_at >= now() - interval '14 days'),
    -- Kuyrukta en bayat haberin KAYNAKTAKİ yayın tarihinden bu yana geçen gün.
    -- `published_at` boş olanlar sayılmıyor: tarihi bilinmeyen haber bir
    -- bayatlık derecesi değil.
    'en_bayat_gun',       (select coalesce(max(
                             (current_date - published_at::date)), 0) from k
                             where published_at is not null),
    'zamanlanmis',        (select count(*) from public.articles
                             where scheduled_at is not null and status = 'reviewing'),

    -- ── Madde 17: görsel sağlığı ───────────────────────────────────────
    -- Yayındaki haberin kapağı yoksa manşete giremiyor; kare türevi yoksa
    -- baloncuklarda, hikâye türevi yoksa hikâye şeridinde görünmüyor.
    'kapaksiz',           (select count(*) from y
                             where image_url is null or image_url = ''),
    'kare_eksik',         (select count(*) from y
                             where image_url is not null and image_url <> ''
                               and (thumb_image_url is null or thumb_image_url = '')),
    'hikaye_eksik',       (select count(*) from y
                             where image_url is not null and image_url <> ''
                               and (story_image_url is null or story_image_url = ''))
  );
$$;

comment on function public.panel_sayaclari() is
  'Yönetim panelinin sayaçları. Tek çağrı, tek satır; sayılar burada '
  'hesaplanıyor ki 500 satırlık liste akışıyla sınırlı kalmasın.';

revoke all on function public.panel_sayaclari() from public, anon;
grant execute on function public.panel_sayaclari() to authenticated;
