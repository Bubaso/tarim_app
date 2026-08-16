-- ═══════════════════════════════════════════════════════════════════════════
--  Arşiv görünümüne tema ve bölüm sayısı
--
--  /ulkeler sayfası Faz 5'te yazıldı ve `country_dossier_index` görünümünün
--  iki eksiği ortaya çıktı:
--
--   1) `theme` yok. Arşiv kartı ülkenin kendi vurgu rengini kullanamıyor,
--      hepsi DossierTheme.yedek'e düşüyordu — on iki ülkelik bir liste
--      tek renkte, dizinin bütün fikri (her ülkenin kendi paleti) kayıp.
--   2) `section_count` yok. Kartta "13 bölüm" yazılamıyordu.
--
--  İkisi de `data`'sız sütunlar; listenin ağırlığını değiştirmiyor.
--
--  Not: 20260816120000'deki tanım DEĞİŞTİRİLMEDİ. Uygulanmış bir migration'ı
--  elden geçirmek, aynı depoyu farklı zamanlarda kuranlarda iki farklı şema
--  üretir. Yeni sütunlar sona ekleniyor — `create or replace view` mevcut
--  sütunların adını, tipini ve sırasını korumak şartıyla buna izin veriyor.
-- ═══════════════════════════════════════════════════════════════════════════

create or replace view public.country_dossier_index
with (security_invoker = on) as
select
  d.slug,
  d.name_tr,
  d.name_en,
  d.iso3,
  d.edition,
  d.thesis_tr,
  d.thesis_en,
  d.cover_url,
  d.published_at,
  d.starts_at,
  d.ends_at,
  -- Şu an ana sayfada olan dosya listede de işaretlensin.
  (d.status = 'published'
    and (d.starts_at is null or d.starts_at <= now())
    and (d.ends_at   is null or d.ends_at   >  now())) as is_active,
  d.theme,
  (select count(*) from public.dossier_sections s where s.dossier_id = d.id)
    as section_count
from public.country_dossiers d
where d.status in ('published','archived')
order by d.edition desc;

comment on view public.country_dossier_index is
  'Arşiv listesi (/ulkeler). data sütununu taşımaz.';
