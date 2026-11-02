-- Avustralya penceresi üç gün daha uzatılıyor — 2 Kasım 2026
--
-- Kullanıcı kararı. Bir saat önceki uzatma (20261102150000) pencereyi
-- 3 Kasım 12:00'ye taşımıştı; Irak dosyası o süreye yetişmiyor.
--
-- NEDEN TEK SEFERDE: her gün bir migration yazmak hem gürültü hem risk.
-- Üç gün, kalan turların (veri katmanı, grafikler, tasarım, künye,
-- görseller, metin, hikâye, dağıtım) sığacağı bir pencere.
--
-- Yeni bitiş: 6 Kasım 2026, 12:00 UTC.
--
-- BU BİR DEVİR DEĞİL. Avustralya published kalıyor, takvime ve kurum
-- dizisine dokunulmuyor.
update public.country_dossiers
   set ends_at    = ends_at + interval '3 days',
       updated_at = now()
 where slug = 'avustralya'
   and tur = 'ulke'
   and status = 'published';

do $$
declare n integer; bitis timestamptz;
begin
  select ends_at into bitis from public.country_dossiers where slug = 'avustralya';
  if bitis::date <> date '2026-11-06' then
    raise exception 'Yeni bitiş % — 6 Kasım olmalıydı', bitis;
  end if;

  select count(*) into n from public.country_dossiers
   where tur = 'ulke' and status = 'published' and ends_at > now();
  if n <> 1 then
    raise exception 'Ülke rafında % aktif dosya var, 1 olmalı', n;
  end if;

  if not exists (select 1 from public.country_dossiers
                  where slug = 'dsi' and status = 'published' and ends_at > now()) then
    raise exception 'DSİ etkilendi — bu migration kurum dizisine dokunmamalıydı';
  end if;
end $$;
