-- Dizi türü — ülke dosyası yanına kurum dosyası.
--
-- Tablo baştan "ülke" varsayımıyla yazılmıştı. İkinci dizi (Türkiye'de tarımı
-- ilgilendiren kuruluşlar) aynı iskeleti kullanıyor: aynı bölümler, aynı
-- grafikler, aynı tema mekanizması, aynı arşiv. Ayrı bir tablo açmak bunların
-- hepsini ikiye çıkarırdı; ayıran tek şey `tur`.

alter table public.country_dossiers
  add column if not exists tur text not null default 'ulke';

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'country_dossiers_tur_check') then
    alter table public.country_dossiers
      add constraint country_dossiers_tur_check check (tur in ('ulke', 'kurum'));
  end if;
end $$;

-- Kurumun ISO kodu yok. `iso3` ülke dosyasında rakamların kaynağına dönmenin
-- anahtarıydı (FAOSTAT, World Bank); kurumda o işi kuruluş belgesi görüyor.
alter table public.country_dossiers alter column iso3 drop not null;

alter table public.country_dossiers
  add column if not exists kurulus_belgesi text;

comment on column public.country_dossiers.kurulus_belgesi is
  'Kurumu kuran belge: "3491 sayılı Kanun · RG 13/7/1938". Kurum dosyasında '
  'iso3 neyse bu odur — bir iddia tartışmaya açılırsa kaynağa dönmenin anahtarı.';

-- İki dizi de 01''den başlıyor. Tekil `edition` indeksi ikinci dizinin ilk
-- sayısında çakışırdı; numara artık dizi içinde tekil.
drop index if exists public.country_dossiers_edition_idx;
create unique index if not exists country_dossiers_tur_edition_idx
  on public.country_dossiers (tur, edition);

-- ─── Aktif dosya görünümü ─────────────────────────────────────────────────
-- Önceki hâli `limit 1` ile TEK aktif dosya varsayıyordu. Artık iki dizi aynı
-- anda yayında olabiliyor, o yüzden `distinct on (tur)`: her diziden en yeni
-- başlayan bir satır. İstemci `tur` ile süzüyor.
--
-- Görünüme yeni sütunlar YALNIZCA SONA eklendi; eski sütunların adı, tipi ve
-- sırası korundu — eski bir istemci sürümü bu görünümü okumaya devam edebilmeli.
create or replace view public.active_country_dossier
with (security_invoker = on) as
select distinct on (d.tur)
  d.slug, d.name_tr, d.name_en, d.iso3, d.edition, d.thesis_tr, d.thesis_en,
  d.theme, d.cover_url, d.cover_credit, d.starts_at, d.ends_at,
  case
    when d.ends_at is not null
    then greatest(0, ceil(extract(epoch from (d.ends_at - now())) / 86400)::integer)
  end as days_remaining,
  (select count(*) from public.dossier_sections s where s.dossier_id = d.id)
    as section_count,
  d.tur,
  d.kurulus_belgesi
from public.country_dossiers d
where d.status = 'published'
  and (d.starts_at is null or d.starts_at <= now())
  and (d.ends_at   is null or d.ends_at   >  now())
order by d.tur, d.starts_at desc nulls last;

create or replace view public.country_dossier_index
with (security_invoker = on) as
select
  d.slug, d.name_tr, d.name_en, d.iso3, d.edition, d.thesis_tr, d.thesis_en,
  d.cover_url, d.published_at, d.starts_at, d.ends_at,
  (d.status = 'published'
    and (d.starts_at is null or d.starts_at <= now())
    and (d.ends_at   is null or d.ends_at   >  now())) as is_active,
  d.theme,
  (select count(*) from public.dossier_sections s where s.dossier_id = d.id)
    as section_count,
  -- Yeni sütunlar YALNIZCA SONA. Mevcut sütunların adı, tipi ve sırası
  -- korunuyor; `create or replace view` başka türlüsüne izin vermiyor
  -- ("cannot change name of view column").
  d.tur,
  d.kurulus_belgesi
from public.country_dossiers d
where d.status in ('published', 'archived')
order by d.tur, d.edition desc;
