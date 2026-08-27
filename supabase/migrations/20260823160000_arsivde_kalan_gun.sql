-- Arşiv görünümüne kalan gün sayacı.
--
-- "Yakında" kartı sıradaki dosyanın ne zaman açılacağını söylüyor ve o tarih
-- takvimde yazılı değil: yayındaki dosyanın penceresi kapandığında sıradaki
-- açılıyor. Sayaç bu yüzden arşiv listesinden okunuyor.
--
-- İstemcide hesaplanmadı — `active_country_dossier`'daki kuralın aynısı:
-- cihaz saatinin doğru olduğunu varsaymak, saati kaymış bir telefonda
-- "-3 gün sonra" yazdırır.
--
-- Sütun SONA ekleniyor; `create or replace view` başka türlüsüne izin vermiyor.
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
  d.tur,
  d.kurulus_belgesi,
  case
    when d.ends_at is not null
    then greatest(0, ceil(extract(epoch from (d.ends_at - now())) / 86400)::integer)
  end as days_remaining
from public.country_dossiers d
where d.status in ('published', 'archived')
order by d.tur, d.edition desc;
